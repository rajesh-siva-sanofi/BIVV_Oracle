-- validation view
CREATE OR REPLACE VIEW BIVV.BIVV_MEDI_CLAIM_VAL_V AS 
WITH v AS (
   SELECT 
      m.hcrs_pgm_id AS pgm_id
      ,sd.labeler_cd AS ndc_lbl, p.period_id   
      ,a.adj_stat-- AS adj_status
      ,s.status_abbr, s.status_desc AS claim_status -- this needs to translate codes to HCRS codes
      ,sd.submdat_dt_postmk AS pstmrk_dt, sd.dat_dt_recv AS rcv_dt
      ,NVL (sd.dat_dt_recv, a.adj_dt_end + 55) as input_dt
      ,SUBSTR(sd.submdat_docno,1,20) AS invc_num
      ,sd.submdat_total_line_cnt AS tot_claim_units
      ,sd.cont_internal_id, sd.cont_num, b.bunit_id_pri AS bunit_state
      ,to_char(a.adj_dt_start,'yyyy"Q"q') AS qtr
      ,a.adj_num
      ,sd.status_num AS subm_status--, sd.status_desc AS subm_status_desc
      ,sd.submgrp_num
   FROM 
--      bivvcars.v_submdat_medi_all sd
      bivvcars.submdat sd
   INNER JOIN bivvcars.submgrp sg ON sd.submgrp_num = sg.submgrp_num
   INNER JOIN bivvcars.bunit b ON sg.bunit_num = b.bunit_num
   LEFT OUTER JOIN medi_pgms_map_v m ON
      m.cont_num = sd.cont_num
      AND m.state_cd = b.bunit_id_pri
   INNER JOIN bivvcars.adj a ON sd.submdat_num = a.subm_num
--   INNER JOIN bivvcars.adjstat ast ON ast.adj_num = a.adj_num
   INNER JOIN bivvcars.status s ON s.status_num = a.adj_stat
   INNER JOIN hcrs.period_t p ON p.first_day_period = a.adj_dt_start
   WHERE 1=1
      -- TODO TODO!!! before going to UAT and production. These programs are mapped with claim lines. They just were not created in HCRS in time for SIT
--      AND sd.cont_num NOT IN (36002, 36001, 22005, 22004, 22002)
)
SELECT 
   CASE 
      WHEN pgm_id IS NULL THEN 'ERR: Contract not mapped'  
      WHEN status_abbr != 'CLS' THEN 'WARN: Claim not settled'
      ELSE 'OK' END AS val_msg
   ,v.*
FROM v
;
-- main view
CREATE OR REPLACE VIEW BIVV.BIVV_MEDI_CLAIM_V AS
WITH v AS (
   SELECT 
      pgm_id, ndc_lbl, period_id
      ,MAX(pstmrk_dt) AS pstmrk_dt, MAX(rcv_dt) AS rcv_dt, MAX(input_dt) AS input_dt
      ,MAX(invc_num) KEEP (DENSE_RANK LAST ORDER BY submgrp_num) AS invc_num
   FROM bivv_medi_claim_val_v v
   WHERE NVL(val_msg,'OK') = 'OK'
   GROUP BY pgm_id, ndc_lbl, period_id)
SELECT v.*
   ,1 AS reb_clm_seq_no, 121 AS co_id, 'OR' as subm_typ_cd -- hard-coded values as per Genzyme integration (needs to be verified)
   ,'CP' AS reb_claim_stat_cd,  NULL as pyment_pstmrk_dt
   ,NULL AS extd_due_dt
   ,NULL AS tot_claim_units -- not sure if this needs to be populated. Ideally we should grab it from the claim line view but it give circular reference error because claim line view does a check on claim header
   ,NVL (rcv_dt, input_dt) as valid_dt
   ,NVL (rcv_dt, input_dt) as prelim_run_dt
   ,NVL (rcv_dt, input_dt) as prelim_sent_dt
   ,NVL (rcv_dt, input_dt) as prelim_apprv_dt
   ,NVL (rcv_dt, input_dt) as final_run_dt
   ,NVL (rcv_dt, input_dt) as dspt_prelim_sent_dt
   ,NVL (rcv_dt, input_dt) as dspt_prelim_apprv_dt
   ,NULL AS corr_int_flg, NULL AS attachment_ref_id
FROM v;

