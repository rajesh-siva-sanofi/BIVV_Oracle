CREATE OR REPLACE VIEW HCRS.BIVV_RECON_CLAIM_LOAD_V AS
WITH
a AS (SELECT * FROM bivvcars.adj WHERE adj_stat IN (114, 1701)), -- settled, , interest recalc pending
src_sub AS (
   -- the logic to get submission unit is to get the unit count from the last row
   -- in the hierarchy of adjitems connected by adjitm_num_prior
   SELECT ai.adjitm_num, ai.adjitm_num_prior, si.submitem_units, si.submitem_asking_dollars
   FROM a, bivvcars.adjitem ai, bivvcars.submitem SI
   WHERE 1=1
      AND CONNECT_BY_ISLEAF = 1
      AND a.adj_num = ai.adj_num
      AND si.status_num = 138
      AND ai.submitm_num = si.submitem_num
   CONNECT BY PRIOR ai.adjitm_num = ai.adjitm_num_prior
START WITH ai.adjitm_num_prior IS NULL),
src AS (
   -- STEP 1: Source
   SELECT
      p.prod_id_pri AS ndc11
      ,mp.hcrs_pgm_id AS pgm_id, mp.pgm_cd
      ,ai.cont_num, mp.cont_title, mp.bunit_name
      ,to_char(ai.adjitm_dt_start, 'yyyy"Q"q') AS qtr
      ,COUNT(*) AS cnt -- 4430
      ,SUM(ai.adjitm_amt_final) AS paid_amt
      ,SUM(ai.adjitm_pay_units) AS paid_units
      ,SUM(ai.adjitm_dispute_units) AS dspt_units
      ,SUM(DECODE(i.adjitemint_flg_override, 'Y', i.adjitemint_override_amt, 'N', i.adjitemint_calc_amt, 0)) AS int_amt
      ,SUM(src_sub.submitem_units) AS claim_units
      ,SUM(src_sub.submitem_asking_dollars) AS claim_amt
   FROM bivvcars.adjitem ai
   LEFT OUTER JOIN src_sub ON src_sub.adjitm_num = ai.adjitm_num
   INNER JOIN a ON ai.adj_num = a.adj_num
   INNER JOIN bivvcars.prod p ON ai.prod_num = p.prod_num
   INNER JOIN bivvcars.bunit b ON ai.bunit_num_pay_to = b.bunit_num
   LEFT OUTER JOIN bivvcars.submitem si ON ai.submitm_num = si.submitem_num
   LEFT OUTER JOIN bivvcars.adjitemint i ON ai.adjitm_num = i.adjitm_num
   LEFT OUTER JOIN bivv.medi_pgms_map_v mp ON ai.cont_num = mp.cont_num AND b.bunit_id_pri = mp.state_cd
   WHERE 1=1
      AND ai.adjtyp_cd = 'MEDI'
      AND ai.status_num != 1700 -- error
   GROUP BY p.prod_id_pri, mp.hcrs_pgm_id, mp.pgm_cd
      ,ai.cont_num, mp.cont_title, mp.bunit_name, to_char(ai.adjitm_dt_start, 'yyyy"Q"q')),
stg AS (
   -- STEP 2: Claim table (STAGING)
   SELECT
      t.ndc_lbl||t.item_prod_fmly_ndc||t.item_prod_mstr_ndc AS ndc11
      ,t.pgm_id
      ,to_char(p.first_day_period,'yyyy"Q"q') AS qtr
      ,COUNT(*) AS cnt
      ,SUM(t.claim_amt) AS claim_amt
      ,SUM(t.claim_units) AS claim_units
   FROM
      bivv.reb_clm_ln_itm_t t
      ,hcrs.period_t p
   WHERE t.period_id = p.period_id
   GROUP BY t.ndc_lbl||t.item_prod_fmly_ndc||t.item_prod_mstr_ndc, t.pgm_id, to_char(p.first_day_period,'yyyy"Q"q')),
tgt AS (
   -- STEP 3: Claim table
   SELECT
      t.ndc_lbl||t.item_prod_fmly_ndc||t.item_prod_mstr_ndc AS ndc11
      ,t.pgm_id
      ,to_char(p.first_day_period,'yyyy"Q"q') AS qtr
      ,COUNT(*) AS cnt
      ,SUM(t.claim_amt) AS claim_amt
      ,SUM(t.claim_units) AS claim_units
   FROM
      hcrs.reb_clm_ln_itm_t t
      ,hcrs.period_t p
   WHERE t.period_id = p.period_id
      AND t.ndc_lbl = '71104'
      AND t.reb_clm_seq_no = 1 -- migrated claims are = 1. Others that may have been created manually during testing are > 1
   GROUP BY t.ndc_lbl||t.item_prod_fmly_ndc||t.item_prod_mstr_ndc, t.pgm_id, to_char(p.first_day_period,'yyyy"Q"q')),
chk_stg AS (
   -- Step 4: Check view (STAGING)
   SELECT
      t.ndc_lbl||t.ndc_prod||t.ndc_pckg AS ndc11
      ,t.pgm_id
      ,p.yr || 'Q' || p.qtr AS qtr
      ,COUNT(*) AS cnt
      ,SUM(t.paid_amt) AS paid_amt
      ,SUM(t.int_amt) AS int_amt
      ,SUM(t.paid_units) AS paid_units
      ,SUM(t.dspt_units) AS dspt_units
   FROM
      hcrs.period_t p,
      (SELECT
         c.ndc_lbl, c.ndc_prod, c.ndc_pckg, 'VC' check_typ_cd, c.paid_amt, c.int_amt, v.claim_units AS paid_units, 0 AS dspt_units, c.period_id, c.pgm_id, c.co_id
      FROM
         bivv.valid_claim_chk_req_t c,
         bivv.valid_claim_t v
      WHERE 1=1
         AND c.pgm_id = v.pgm_id
         AND c.ndc_lbl = v.ndc_lbl
         AND c.period_id = v.period_id
         AND c.co_id = v.co_id
         AND c.reb_clm_seq_no = v.reb_clm_seq_no
         AND c.ln_itm_seq_no = v.ln_itm_seq_no
      UNION ALL
      SELECT d.ndc_lbl, d.ndc_prod, d.ndc_pckg, 'DC' check_typ_cd, d.paid_amt, d.int_amt, ds.paid_units, ds.dspt_units, d.period_id, d.pgm_id, d.co_id
      FROM
         bivv.dspt_check_req_t d,
         bivv.dspt_t ds
      WHERE 1=1
         AND d.pgm_id = ds.pgm_id
         AND d.ndc_lbl = ds.ndc_lbl
         AND d.period_id = ds.period_id
         AND d.co_id = ds.co_id
         AND d.reb_clm_seq_no = ds.reb_clm_seq_no
         AND d.ln_itm_seq_no = ds.ln_itm_seq_no) t
   WHERE t.period_id = p.period_id
      AND t.ndc_lbl = '71104'
   GROUP BY t.ndc_lbl||t.ndc_prod||t.ndc_pckg, t.pgm_id, p.yr || 'Q' || p.qtr),
chk AS (
   -- Step 5: Check view
   SELECT
      t.ndc_lbl||t.ndc_prod||t.ndc_pckg AS ndc11
      ,t.pgm_id
      ,p.yr || 'Q' || p.qtr AS qtr
      ,COUNT(*) AS cnt
      ,SUM(t.paid_amt) AS paid_amt
      ,SUM(t.int_amt) AS int_amt
      ,SUM(t.paid_units) AS paid_units
      ,SUM(t.dspt_units) AS dspt_units
   FROM
      hcrs.period_t p,
      (SELECT
         c.ndc_lbl, c.ndc_prod, c.ndc_pckg, 'VC' check_typ_cd, c.paid_amt, c.int_amt, v.claim_units AS paid_units, 0 AS dspt_units, c.period_id, c.pgm_id, c.co_id
      FROM
         hcrs.valid_claim_chk_req_t c,
         hcrs.valid_claim_t v
      WHERE 1=1
         AND c.pgm_id = v.pgm_id
         AND c.ndc_lbl = v.ndc_lbl
         AND c.period_id = v.period_id
         AND c.co_id = v.co_id
         AND c.reb_clm_seq_no = v.reb_clm_seq_no
         AND c.ln_itm_seq_no = v.ln_itm_seq_no
         AND c.reb_clm_seq_no = 1 -- migrated claims are = 1. Others that may have been created manually during testing are > 1
      UNION ALL
      SELECT d.ndc_lbl, d.ndc_prod, d.ndc_pckg, 'DC' check_typ_cd, d.paid_amt, d.int_amt, ds.paid_units, ds.dspt_units, d.period_id, d.pgm_id, d.co_id
      FROM
         hcrs.dspt_check_req_t d,
         hcrs.dspt_t ds
      WHERE 1=1
         AND d.pgm_id = ds.pgm_id
         AND d.ndc_lbl = ds.ndc_lbl
         AND d.period_id = ds.period_id
         AND d.co_id = ds.co_id
         AND d.reb_clm_seq_no = ds.reb_clm_seq_no
         AND d.ln_itm_seq_no = ds.ln_itm_seq_no
         AND d.reb_clm_seq_no = 1) t -- migrated claims are = 1. Others that may have been created manually during testing are > 1
   WHERE t.period_id = p.period_id
      AND t.ndc_lbl = '71104'
   GROUP BY t.ndc_lbl||t.ndc_prod||t.ndc_pckg, t.pgm_id, p.yr || 'Q' || p.qtr),
j AS (
   SELECT COALESCE(src.ndc11, stg.ndc11, tgt.ndc11) AS ndc11, NVL(src.pgm_cd, 'N/A') AS pgm_cd, src.pgm_id
      ,src.cont_num, src.cont_title, src.bunit_name
      ,COALESCE (src.qtr, stg.qtr, tgt.qtr) AS qtr
      ,src.claim_units AS src_claim_units, tgt.claim_units AS tgt_claim_units, stg.claim_units AS stg_claim_units
      ,src.paid_units AS src_paid_units
      ,chk.paid_units AS chk_paid_units, chk_stg.paid_units AS chk_stg_paid_units
      ,src.dspt_units AS src_dspt_units, chk.dspt_units AS chk_dspt_units, chk_stg.dspt_units AS chk_stg_dspt_units
      ,src.claim_amt AS src_claim_amt, tgt.claim_amt AS tgt_claim_amt
      ,src.paid_amt AS src_paid_amt, chk.paid_amt AS chk_paid_amt
      ,stg.claim_amt AS stg_claim_amt, chk_stg.paid_amt AS chk_stg_paid_amt
      ,src.int_amt AS src_int_amt, chk.int_amt AS chk_int_amt, chk_stg.int_amt AS chk_stg_int_amt
      ,src.cnt AS src_cnt, tgt.cnt AS tgt_cnt, stg.cnt AS stg_cnt
   FROM src
   FULL OUTER JOIN stg ON stg.ndc11 = src.ndc11 AND stg.pgm_id = src.pgm_id AND stg.qtr = src.qtr
   FULL OUTER JOIN tgt ON tgt.ndc11 = src.ndc11 AND tgt.pgm_id = src.pgm_id AND tgt.qtr = src.qtr
   FULL OUTER JOIN chk_stg ON chk_stg.ndc11 = src.ndc11 AND chk_stg.pgm_id = src.pgm_id AND chk_stg.qtr = src.qtr
   FULL OUTER JOIN chk ON chk.ndc11 = src.ndc11 AND chk.pgm_id = src.pgm_id AND chk.qtr = src.qtr
   ),
cmp AS (
   SELECT
      CASE
         WHEN pgm_id IS NULL THEN 'Contract not mapped'
         WHEN src_claim_amt IS NULL OR src_paid_amt IS NULL OR tgt_claim_amt IS NULL THEN 'Something wrong with amounts'
         WHEN src_claim_units IS NULL OR src_paid_units IS NULL OR tgt_claim_units IS NULL OR chk_paid_units IS null THEN 'Something wrong with units'
         WHEN src_claim_amt != tgt_claim_amt THEN 'Claim amount different (reb_clm_ln_itm_t)'
         WHEN src_paid_amt != chk_paid_amt THEN 'Paid amount different (check_v)'
         WHEN src_claim_units != tgt_claim_units THEN 'Claim units different (reb_clm_ln_itm_t)'
         WHEN src_paid_units != chk_paid_units THEN 'Paid units different (check_v)'
         WHEN src_dspt_units != chk_dspt_units THEN 'Disputed units different (check_v)'
         WHEN src_int_amt != chk_int_amt THEN 'Interest amount different'
      ELSE 'OK'
      END AS val_msg
      ,j.*
   FROM j)
SELECT "VAL_MSG","NDC11","PGM_CD","PGM_ID","CONT_NUM","CONT_TITLE","BUNIT_NAME","QTR","SRC_CLAIM_UNITS","TGT_CLAIM_UNITS","STG_CLAIM_UNITS","SRC_PAID_UNITS","CHK_PAID_UNITS","CHK_STG_PAID_UNITS","SRC_DSPT_UNITS","CHK_DSPT_UNITS","CHK_STG_DSPT_UNITS","SRC_CLAIM_AMT","TGT_CLAIM_AMT","SRC_PAID_AMT","CHK_PAID_AMT","STG_CLAIM_AMT","CHK_STG_PAID_AMT","SRC_INT_AMT","CHK_INT_AMT","CHK_STG_INT_AMT","SRC_CNT","TGT_CNT","STG_CNT"
FROM cmp
ORDER BY ndc11, qtr;
