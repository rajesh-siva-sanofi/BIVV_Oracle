-- validation view
CREATE OR REPLACE VIEW BIVV.BIVV_MEDI_CLAIM_LINE_VAL_V AS
WITH ai AS (
   SELECT p.prod_id_pri, pe.period_id, pe.first_day_period
      ,ai.cont_num
      ,ai.adjitm_pay_units, adjitm_dispute_units
      ,ai.adjitm_amt_final, ai.adjitm_dispute_amt, ai.clmadjitm_rpu, ai.adjitm_state_rpu
      ,COALESCE (aii.adjitemint_override_amt, aii.adjitemint_calc_amt, 0) AS int_amt
      ,ai.adjitm_auth_rx, ai.adjitem_nonmedi_reimb, ai.adjitem_medi_reimb
      ,coalesce(ai.adjitem_total_reimb, ai.clmadjitm_reimb, 0) AS total_reimbur_amt
      ,ai.bunit_num_pay_to, b.bunit_id_pri
      ,ai.adjitm_num, ai.adjitm_num_prior, ai.adj_num
      
   FROM 
      bivvcars.adjitem ai
      ,bivvcars.adj a
      ,bivvcars.adjitemint aii
      ,bivvcars.prod p
      ,hcrs.period_t pe
      ,bivvcars.bunit b
   WHERE 1=1
      AND ai.adjtyp_cd   = 'MEDI'
      AND ai.status_num <> 1700
      AND ai.adj_num = a.adj_num
      AND a.adj_stat IN (114, 1701) -- claim closed, interest recalc pending
      AND ai.adjitm_num = aii.adjitm_num (+)
      AND ai.prod_num = p.prod_num
      AND ai.adjitm_dt_start = pe.first_day_period
      AND ai.bunit_num_pay_to = b.bunit_num (+)
      -- TODO TODO!!! before going to UAT and production. These programs are mapped with claim lines. They just were not created in HCRS in time for SIT
--      AND ai.cont_num NOT IN (36002, 36001, 22005, 22004, 22002)
),
m AS (
   SELECT ai.*
      ,pm.hcrs_pgm_id, pm.pgm_cd
   FROM ai
     ,bivv.medi_pgms_map_v pm
   WHERE 1=1
      AND ai.cont_num = pm.cont_num
      AND ai.bunit_id_pri = pm.state_cd),
v AS (
   SELECT 
      m.hcrs_pgm_id AS pgm_id
      ,SUBSTR(m.prod_id_pri,1,5) AS ndc_lbl
      ,m.period_id, 121 AS co_id, 1 AS reb_clm_seq_no
      ,SUM(m.adjitm_pay_units) AS total_units_paid
      ,SUM(m.adjitm_amt_final) AS total_amt_paid
      ,MAX(m.adjitm_dispute_units) KEEP (DENSE_RANK LAST ORDER BY m.adjitm_num) as adjitm_dispute_units
      ,MAX(m.adjitm_dispute_amt) KEEP (DENSE_RANK LAST ORDER BY m.adjitm_num) as adjitm_dispute_amt
      ,'CP' AS reb_claim_ln_itm_stat_cd
      ,MAX(m.adjitm_auth_rx) KEEP (DENSE_RANK LAST ORDER BY m.adjitm_num) as adjitm_auth_rx
      ,MAX(m.adjitm_state_rpu) KEEP (DENSE_RANK LAST ORDER BY m.adjitm_num) AS pgm_pur
      ,MAX(m.adjitem_medi_reimb) KEEP (DENSE_RANK LAST ORDER BY m.adjitm_num) as reimbur_amt
      ,0 AS corr_flg
      ,SUBSTR(m.prod_id_pri,6,4) AS item_prod_fmly_ndc, SUBSTR(m.prod_id_pri,10,2) AS item_prod_mstr_ndc
      ,SYSDATE AS create_dt, 'HCRS' AS mod_by
      ,MAX(m.adjitem_nonmedi_reimb) KEEP (DENSE_RANK LAST ORDER BY m.adjitm_num) as nonmed_reimbur_amt
      ,MAX(m.total_reimbur_amt) KEEP (DENSE_RANK LAST ORDER BY m.adjitm_num) as total_reimbur_amt
      ,SUM(m.int_amt) AS total_int_amt
      ,COUNT(*) AS line_cnt
      ,m.prod_id_pri, m.cont_num, m.bunit_id_pri, m.first_day_period
   FROM m
   GROUP BY hcrs_pgm_id, prod_id_pri, period_id, cont_num, bunit_id_pri, first_day_period)
SELECT 
   CASE 
      WHEN v.pgm_id IS NULL THEN 'ERR: HCRS program not found'
      WHEN (SELECT COUNT(*) FROM hcrs.prod_mstr_t t 
            WHERE t.ndc_lbl = v.ndc_lbl AND t.ndc_prod = v.item_prod_fmly_ndc AND t.ndc_pckg = v.item_prod_mstr_ndc) = 0 THEN 'ERR: Product not in HCRS'
      WHEN (SELECT COUNT(*) FROM bivv.bivv_medi_claim_v t 
            WHERE t.pgm_id = v.pgm_id AND t.ndc_lbl = v.ndc_lbl AND t.period_id = v.period_id AND t.reb_clm_seq_no = v.reb_clm_seq_no) = 0 THEN 'ERR: Claim header not found in BIVVCARS'
--      WHEN (SELECT COUNT(*) FROM hcrs.reb_claim_t t 
--            WHERE t.pgm_id = v.pgm_id AND t.ndc_lbl = v.ndc_lbl AND t.period_id = v.period_id AND t.reb_clm_seq_no = v.reb_clm_seq_no) = 0 THEN 'Claim header not found in HCRS'
      WHEN (SELECT COUNT(*) FROM bivv_pgm_prod_v t 
            WHERE t.pgm_id = v.pgm_id AND t.ndc_lbl = v.ndc_lbl AND t.ndc_prod = v.item_prod_fmly_ndc AND t.ndc_pckg = v.item_prod_mstr_ndc) = 0 THEN 'ERR: Product not eligible for the program'
   END AS val_msg
   ,v.*
FROM v;

-- main view
CREATE OR REPLACE VIEW BIVV.BIVV_MEDI_CLAIM_LINE_V AS
SELECT row_number() OVER (PARTITION BY pgm_id, ndc_lbl, period_id, co_id, reb_clm_seq_no ORDER BY item_prod_fmly_ndc, item_prod_mstr_ndc) AS ln_itm_seq_no
   ,v.*
   ,CASE WHEN v.adjitm_dispute_units > 0 THEN 'Y' ELSE 'N' END AS dspt_flg
FROM bivv_medi_claim_line_val_v v
WHERE NVL(val_msg,'OK') = 'OK'
;

SELECT *
FROM bivv.bivv_medi_claim_line_val_v v
WHERE 
   v.pgm_id = 72
   AND v.first_day_period = to_date('1/1/2019','mm/dd/yyyy');
