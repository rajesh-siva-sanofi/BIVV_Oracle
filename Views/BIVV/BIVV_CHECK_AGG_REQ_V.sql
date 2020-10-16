CREATE OR REPLACE VIEW BIVV.BIVV_CHECK_AGG_REQ_V AS
WITH v AS (
   SELECT v.pgm_id, v.period_id, v.ndc_lbl, v.co_id, v.reb_clm_seq_no,
      v.check_id,(v.paid_amt + v.int_amt) AS paid_amt
   FROM valid_claim_chk_req_t v
   UNION ALL
   SELECT d.pgm_id, d.period_id, d.ndc_lbl, d.co_id, d.reb_clm_seq_no,
    d.check_id ,(d.paid_amt + d.int_amt) AS paid_amt
   FROM dspt_check_req_t d)
SELECT
   v.check_id,'MA' AS check_req_stat_cd, 'RO' AS pymnt_catg_cd, NULL AS credit_num
   ,SUM(v.paid_amt) AS check_req_amt, 0 AS cr_bal
   ,p.last_day_period + 55 AS check_input_dt
   ,p.last_day_period + 60 AS check_req_dt
   ,p.last_day_period + 68 AS pcrss_dt
   ,p.last_day_period + 69 AS conf_dt
   ,p.last_day_period + 70 AS check_dt
   ,p.last_day_period + 71 AS mail_dt
   ,v.pgm_id, v.co_id
   ,'NI' AS int_sel_meth_cd
   ,0 AS man_int_amt
   ,'Y' AS rosi_flg
   ,'N' AS pqas_flg
   ,p.last_day_period + 78 AS est_check_mail_dt
--   ,v.period_id, v.ndc_lbl, v.reb_clm_seq_no
FROM v, hcrs.period_t p
WHERE v.period_id = p.period_id
GROUP BY v.pgm_id, v.period_id, v.ndc_lbl, v.co_id, v.reb_clm_seq_no,
   v.check_id,p.last_day_period
;
