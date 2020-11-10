CREATE OR REPLACE VIEW HCRS.BIVV_RECON_TOTALS_V AS
WITH src AS (
   SELECT p.prod_id_pri AS ndc11
--      ,to_char (ai.adjitm_dt_start,'yyyy"Q"q') AS qtr
      ,SUM(ai.adjitm_auth_units) AS adjitm_auth_units
      ,SUM(ai.adjitm_amt_final) AS adjitm_amt_final
      ,SUM(DECODE(i.adjitemint_flg_override, 'Y', i.adjitemint_override_amt, i.adjitemint_calc_amt)) AS int_amt
      ,COUNT(*)
   FROM bivvcars.adjitem ai
      ,bivvcars.adj a
      ,bivvcars.prod p
      ,bivvcars.cont c
      ,bivvcars.adjitemint i
   WHERE ai.adj_num = a.adj_num
      AND ai.prod_num = p.prod_num
      AND ai.cont_num = c.cont_num
      AND a.adj_stat IN (114, 1701) -- claim closed, interest recalc pending
      AND ai.adjitm_num = i.adjitm_num (+)
      AND ai.status_num != 1700 --error
      AND c.num_sys_id = 102 -- MEDI
      AND c.cont_num NOT IN (43001, 43002) -- for now exclude those 2 CA contracts in question
   GROUP BY p.prod_id_pri
--      ,to_char (ai.adjitm_dt_start,'yyyy"Q"q')
),
tgt AS (
   SELECT v.ndc_lbl||v.ndc_prod||v.ndc_pckg AS ndc11
      ,SUM(v.paid_amt) AS paid_amt
      ,SUM(v.int_amt) AS int_amt
      ,SUM(c.claim_units) AS paid_units
   FROM hcrs.check_v v
      ,(SELECT vc.pgm_id, vc.ndc_lbl, vc.period_id, vc.reb_clm_seq_no, vc.co_id, vc.ln_itm_seq_no
         ,vc.ndc_prod, vc.ndc_pckg, vc.claim_units
      FROM hcrs.valid_claim_t vc
      UNION
      SELECT d.pgm_id, d.ndc_lbl, d.period_id, d.reb_clm_seq_no, d.co_id, d.ln_itm_seq_no
         ,d.ndc_prod, d.ndc_pckg, d.paid_units
      FROM hcrs.dspt_t d) c
   WHERE v.pgm_id = c.pgm_id (+) AND v.ndc_lbl = c.ndc_lbl (+) AND v.period_id = c.period_id (+)
      AND v.reb_clm_seq_no = c.reb_clm_seq_no (+) AND v.co_id = c.co_id (+) AND v.ln_itm_seq_no = c.ln_itm_seq_no (+)
      AND v.ndc_prod = c.ndc_prod (+) AND v.ndc_pckg = c.ndc_pckg (+)
      AND v.ndc_lbl = '71104'
      AND v.reb_clm_seq_no = 1 -- include only migrated claims
   GROUP BY v.ndc_lbl||v.ndc_prod||v.ndc_pckg),
cmp AS (
   SELECT
      CASE
         WHEN src.adjitm_auth_units != tgt.paid_units THEN 'Paid units different'
         WHEN src.adjitm_amt_final != tgt.paid_amt THEN 'Paid amounts different'
         WHEN src.int_amt != tgt.int_amt THEN 'Interest amounts different'
      ELSE 'OK' END AS valid_msg
      ,src.ndc11, src.adjitm_auth_units AS flex_auth_units, tgt.paid_units AS hcrs_paid_units
      ,src.adjitm_amt_final AS flex_paid_amt, tgt.paid_amt AS hcrs_paid_amt
      ,src.int_amt AS flex_int_amt, tgt.int_amt AS hcrs_int_amt
   FROM src
   LEFT OUTER JOIN tgt ON tgt.ndc11 = src.ndc11)
SELECT "VALID_MSG","NDC11","FLEX_AUTH_UNITS","HCRS_PAID_UNITS","FLEX_PAID_AMT","HCRS_PAID_AMT","FLEX_INT_AMT","HCRS_INT_AMT"
FROM cmp
ORDER BY valid_msg, ndc11;
