CREATE OR REPLACE VIEW bivv.BIVV_VALID_CLAIM_CHK_REQ_V AS
SELECT t.pgm_id, t.ndc_lbl, t.period_id, t.reb_clm_seq_no, t.co_id, t.ln_itm_seq_no
   ,t.ndc_prod, t.ndc_pckg, t.claim_amt, t.int_amt, 0 AS int_owed_amt, 0 AS int_wrt_off_amt
   ,'N' AS int_owed_flg
FROM bivv_valid_claim_v t
WHERE t.dspt_flg = 'N'
;
CREATE OR REPLACE VIEW bivv.BIVV_DSPT_CHECK_REQ_V AS
SELECT t.pgm_id, t.ndc_lbl, t.period_id, t.reb_clm_seq_no, t.co_id, t.ln_itm_seq_no, 1 AS dspt_seq_no
   ,t.ndc_prod, t.ndc_pckg, t.claim_amt, t.int_amt, 0 AS int_owed_amt, 0 AS int_wrt_off_amt
   ,'N' AS int_owed_flg
FROM bivv_valid_claim_v t
WHERE t.dspt_flg = 'Y'
;
CREATE OR REPLACE VIEW BIVV_CHECK_REQ_V2 AS
WITH v AS (
   SELECT
      vc.check_id, vc.pgm_id, vc.co_id, vc.period_id 
--         v.pgm_id, v.period_id, v.ndc_lbl, v.co_id, v.reb_clm_seq_no
      ,vc.paid_amt + vc.int_amt AS paid_amt
   FROM valid_claim_chk_req_t vc
   UNION ALL 
   SELECT 
      d.check_id, d.pgm_id, d.co_id, d.period_id 
--      d.pgm_id, d.period_id, d.ndc_lbl, d.co_id, d.reb_clm_seq_no
      ,d.paid_amt + d.int_amt AS paid_amt
   FROM dspt_check_req_t d)
SELECT 
   v.check_id, 'MA' AS check_req_stat_cd, 'RO' AS pymnt_catg_cd, NULL AS credit_num
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
GROUP BY v.check_id, v.pgm_id, v.co_id
   ,p.last_day_period
;

CREATE OR REPLACE VIEW BIVV_CHECK_REQ_V AS
WITH 
src AS (
   SELECT v.quarter_date, pm.hcrs_pgm_id
      ,SUM(v.adj_stlmnt_amt+v.adjreq_interest_amt) AS paid_amt
      ,MAX(s.stlmnt_dt_added) KEEP (DENSE_RANK LAST ORDER BY v.stlmnt_num) as check_input_dt
      ,MAX(sm.stlmntmthd_dt_requested) KEEP (DENSE_RANK LAST ORDER BY v.stlmnt_num) as check_req_dt
      ,MAX(sm.stlmntmthd_dt_docno) KEEP (DENSE_RANK LAST ORDER BY v.stlmnt_num) as pcrss_dt
      ,MAX(sm.stlmntmthd_dt_docno) KEEP (DENSE_RANK LAST ORDER BY v.stlmnt_num) as conf_dt
      ,MAX(sm.stlmntmthd_dt_docno) KEEP (DENSE_RANK LAST ORDER BY v.stlmnt_num) as check_dt
      ,MAX(sm.stlmntmthd_dt_sent) KEEP (DENSE_RANK LAST ORDER BY v.stlmnt_num) as mail_dt
      ,MAX(sm.stlmntmthd_dt_required) KEEP (DENSE_RANK LAST ORDER BY v.stlmnt_num) as est_check_mail_dt
      ,SUBSTR(MAX('Original Flex details. Invoice: '||v.invoice_num||', StlmntMthd DocNo: '||sm.stlmntmthd_docno||', Adj No: '||v.adj_num||', Stlmnt No: '||v.stlmnt_num) KEEP (DENSE_RANK LAST ORDER BY v.stlmnt_num),1,2000) as cmt_txt
--      ,s.stlmnt_dt_added, sm.stlmntmthd_docno, sm.stlmntmthd_dt_requested, sm.stlmntmthd_dt_required
--      ,sm.stlmntmthd_dt_docno, sm.stlmntmthd_dt_sent, v.stlmnt_num
   FROM bivvcars.v_medi_adjreq_by_stlmt_all v
      ,bivvcars.stlmntmthd sm
      ,bivvcars.stlmnt s
      ,bivv.medi_pgms_map_v pm
   WHERE 1=1
      AND v.stlmnt_num = s.stlmnt_num
      AND v.stlmnt_num = sm.stlmnt_num
      AND pm.cont_internal_id = v.cont_internal_id (+) 
      AND pm.state_cd = v.bunit_name (+)
      AND v.stlmnt_status_desc = 'Settled'
   GROUP BY v.quarter_date, pm.hcrs_pgm_id),
claim_union AS (
   SELECT
      vc.check_id, vc.pgm_id, vc.co_id, vc.period_id 
      ,vc.paid_amt + vc.int_amt AS paid_amt
   FROM valid_claim_chk_req_t vc
   UNION ALL 
   SELECT 
      d.check_id, d.pgm_id, d.co_id, d.period_id 
      ,d.paid_amt + d.int_amt AS paid_amt
   FROM dspt_check_req_t d),
cr AS (
   SELECT 
      cu.check_id, 'MA' AS check_req_stat_cd, 'RO' AS pymnt_catg_cd, NULL AS credit_num
      ,SUM(cu.paid_amt) AS check_req_amt, 0 AS cr_bal
      ,p.last_day_period + 55 AS check_input_dt
      ,p.last_day_period + 60 AS check_req_dt
      ,p.last_day_period + 68 AS pcrss_dt
      ,p.last_day_period + 69 AS conf_dt
      ,p.last_day_period + 70 AS check_dt
      ,p.last_day_period + 71 AS mail_dt
      ,cu.pgm_id, cu.co_id
      ,'NI' AS int_sel_meth_cd
      ,0 AS man_int_amt
      ,'Y' AS rosi_flg
      ,'N' AS pqas_flg
      ,p.last_day_period + 78 AS est_check_mail_dt
      ,p.first_day_period, p.last_day_period
   FROM claim_union cu, hcrs.period_t p
   WHERE cu.period_id = p.period_id
   GROUP BY cu.check_id, cu.pgm_id, cu.co_id, p.first_day_period, p.last_day_period)
SELECT 
   cr.check_id, cr.check_req_stat_cd, cr.pymnt_catg_cd, cr.credit_num, cr.check_req_amt, cr.cr_bal
   ,NVL(src.check_input_dt, cr.check_input_dt) AS check_input_dt 
   ,NVL(src.check_req_dt, cr.check_req_dt) AS check_req_dt
   ,NVL(src.pcrss_dt, cr.pcrss_dt) AS pcrss_dt
   ,NVL(src.conf_dt, cr.conf_dt) AS conf_dt
   ,NVL(src.check_dt, cr.check_dt) AS check_dt
   ,NVL(src.mail_dt, cr.mail_dt) AS mail_dt
   ,cr.pgm_id, cr.co_id, cr.int_sel_meth_cd, cr.man_int_amt, cr.rosi_flg, cr.pqas_flg
   ,NVL(src.est_check_mail_dt, cr.est_check_mail_dt) AS est_check_mail_dt
   ,src.cmt_txt
FROM cr, src
WHERE 1=1
   AND cr.pgm_id = src.hcrs_pgm_id
   AND cr.first_day_period = src.quarter_date (+)
;
/*

WITH v AS (
   SELECT
--   SUM(check_req_amt) AS check_req_amt
--   ,COUNT(*)
      *
   FROM bivv_check_req_v
   UNION 
   SELECT * FROM bivv_check_req_v2
)
SELECT *
FROM v
WHERE v.pgm_id = 50
;
SELECT 
--   COUNT(*)
--   v.cont_internal_id, v.bunit_name, v.quarter_date, v.quarter
--   ,SUM(v.adj_stlmnt_amt) AS paid_amt
--   ,SUM(v.adjreq_interest_amt) AS paid_amt
   v.invoice_num, s.stlmnt_dt_added, sm.stlmntmthd_docno, sm.stlmntmthd_dt_requested, sm.stlmntmthd_dt_required
   ,sm.stlmntmthd_dt_docno AS pay_dt, sm.stlmntmthd_dt_sent
   ,sm.*
FROM 
   bivvcars.stlmntmthd sm
   ,bivvcars.stlmnt s
--   ,bivvcars.adjreq ar
   ,bivvcars.v_medi_adjreq_by_stlmt_all v
WHERE 1=1
--   AND ar.adj_type = 'MEDI'
--   AND ar.status_num = 83 -- settled
   AND v.stlmnt_num = s.stlmnt_num
   AND v.stlmnt_num = sm.stlmnt_num
   AND v.stlmnt_status_desc = 'Settled'
   AND v.cont_internal_id = 'MEDI'
   AND bunit_name = 'AK'
--GROUP BY v.cont_internal_id, v.bunit_name, v.quarter_date, v.quarter
ORDER BY v.quarter_date, v.stlmnt_num;

SELECT pgm_id, period_id, period
   ,SUM(paid_amt) AS paid_amt -- why Flex setlements don't include interest?
   ,SUM(c.int_amt) AS int_amt
FROM hcrs.check_v c
WHERE ndc_lbl = '71104'
   AND pgm_id = 1
GROUP BY pgm_id, period_id, period
ORDER BY 1,2,3
--WHERE c.
;
SELECT * FROM hcrs.check_req_t;

SELECT *
FROM bivvcars.status
WHERE status_cd = 'adjreq'
ORDER BY 1;

SELECT 
--   COUNT(*)
   *
FROM bivvcars.v_medi_adjreq_by_stlmt_all s
WHERE s.bunit_name = 'AK'
;
*/
