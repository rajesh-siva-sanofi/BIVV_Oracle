-- validation view
CREATE OR REPLACE VIEW BIVV_MEDI_CLAIM_LINE_VAL_V AS
WITH 
si1 AS (
   -- IntegriChain tried to moved submissions from 22* contracts to the new 43* contracts, but missed few areas for this is just to make sure it does not impact migration
   SELECT DECODE (si.cont_num, 22001, 43001, 22003, 43002, si.cont_num) AS cont_num 
      ,si.bunit_num, si.prod_num, si.submitem_prod_id, si.submtyp_cd
      ,si.submitem_units, si.submitem_asking_dollars, si.submitem_rx, si.submitem_rpu
      ,si.submitem_total_reimb, si.submitem_medi_reimb, si.submitem_medi_nonreimb
      ,si.submdat_num, si.submitem_num, si.submitem_dt_start
   FROM bivvcars.submitem si
   WHERE si.status_num = 138 -- authorized 
      AND si.prod_num IS NOT NULL), -- get rid off error lines
si AS (
   SELECT si1.*, b.bunit_id_pri
   FROM si1, bivvcars.cont c, bivvcars.bunit b
      ,bivvcars.adj a
   WHERE si1.cont_num = c.cont_num
      AND si1.bunit_num = b.bunit_num
      AND si1.submdat_num = a.subm_num
      AND si1.submitem_dt_start = a.adj_dt_start
      AND c.num_sys_id = 102 -- Medicaid
      AND a.adj_stat IN (114, 1701) -- claim closed, interest recalc pending
), 
src AS (
   SELECT 
      si.prod_num, si.submitem_prod_id, pe.period_id, si.submitem_dt_start, si.cont_num, si.bunit_num, si.bunit_id_pri
      ,MAX(si.submitem_units) KEEP (DENSE_RANK LAST ORDER BY si.submitem_num) as submitem_units
      ,MAX(si.submitem_asking_dollars) KEEP (DENSE_RANK LAST ORDER BY si.submitem_num) AS submitem_asking_dollars
      ,MAX(si.submitem_rx) KEEP (DENSE_RANK LAST ORDER BY si.submitem_num) AS submitem_rx
      ,MAX(si.submitem_rpu) KEEP (DENSE_RANK LAST ORDER BY si.submitem_num) AS submitem_rpu
      ,COUNT(*) AS line_cnt
      ,MAX(si.submitem_total_reimb) KEEP (DENSE_RANK LAST ORDER BY si.submitem_num) AS total_reimbur_amt
      ,MAX(si.submitem_medi_reimb) KEEP (DENSE_RANK LAST ORDER BY si.submitem_num) AS reimbur_amt
      ,MAX(si.submitem_medi_nonreimb) KEEP (DENSE_RANK LAST ORDER BY si.submitem_num) AS nonmed_reimbur_amt
   FROM si
      ,hcrs.period_t pe
   WHERE 1=1   
      AND si.submitem_dt_start = pe.first_day_period
   GROUP BY si.prod_num, si.submitem_prod_id, pe.period_id, si.submitem_dt_start, si.cont_num, si.bunit_num, si.bunit_id_pri), 
v AS (
   SELECT 
      pm.hcrs_pgm_id AS pgm_id, SUBSTR(src.submitem_prod_id,1,5) AS ndc_lbl, src.period_id
      ,121 AS co_id, 1 AS reb_clm_seq_no, src.submitem_units
--      ,CASE WHEN NVL(src.submitem_asking_dollars, 0) = 0 THEN ROUND(src.submitem_units*src.submitem_rpu,2) ELSE src.submitem_asking_dollars END AS submitem_asking_dollars
      ,src.submitem_asking_dollars
      ,'CP' AS reb_claim_ln_itm_stat_cd
      ,CASE WHEN NVL(src.submitem_rx, 0) = 0 THEN 
         (SELECT si2.submitem_rx FROM si si2 
         WHERE si2.submtyp_cd = 'ORIGINAL' AND si2.cont_num = src.cont_num AND si2.prod_num = src.prod_num
            AND si2.bunit_num = src.bunit_num AND si2.submitem_dt_start = src.submitem_dt_start) ELSE src.submitem_rx END AS submitem_rx
      ,src.submitem_rpu, src.reimbur_amt, 0 AS corr_flg
      ,SUBSTR(src.submitem_prod_id,6,4) AS item_prod_fmly_ndc, SUBSTR(src.submitem_prod_id,10,2) AS item_prod_mstr_ndc
      ,src.nonmed_reimbur_amt, src.total_reimbur_amt
      ,src.line_cnt, src.prod_num, src.submitem_prod_id, src.submitem_dt_start, src.cont_num, src.bunit_num, src.bunit_id_pri, pm.pgm_cd
   FROM src
     ,bivv.medi_pgms_map_v pm
   WHERE 1=1
      AND src.cont_num = pm.cont_num (+)
      AND src.bunit_id_pri = pm.state_cd (+))
SELECT 
   CASE 
      WHEN v.pgm_id IS NULL THEN 'ERR: HCRS program not mapped'
      WHEN v.pgm_cd IS NULL THEN 'ERR: HCRS program not found'
      WHEN (SELECT COUNT(*) FROM hcrs.prod_mstr_t t 
            WHERE t.ndc_lbl = v.ndc_lbl AND t.ndc_prod = v.item_prod_fmly_ndc AND t.ndc_pckg = v.item_prod_mstr_ndc) = 0 THEN 'ERR: Product not in HCRS'
      WHEN (SELECT COUNT(*) FROM bivv.bivv_medi_claim_v t 
            WHERE t.pgm_id = v.pgm_id AND t.ndc_lbl = v.ndc_lbl AND t.period_id = v.period_id AND t.reb_clm_seq_no = v.reb_clm_seq_no) = 0 THEN 'ERR: Claim header not found in BIVVCARS'
      WHEN (SELECT COUNT(*) FROM bivv_pgm_prod_v t 
            WHERE t.pgm_id = v.pgm_id AND t.ndc_lbl = v.ndc_lbl AND t.ndc_prod = v.item_prod_fmly_ndc AND t.ndc_pckg = v.item_prod_mstr_ndc) = 0 THEN 'ERR: Product not eligible for the program'
   ELSE 'OK'
   END AS val_msg
   ,v.*
FROM v;

/*
SELECT *
FROM bivv.bivv_medi_claim_line_val_V
WHERE 1=1
--   AND cont_num = 1 AND submitem_prod_id = '71104080901' AND submitem_dt_start = to_date('7/1/2018','mm/dd/yyyy') AND Bunit_Num = (SELECT bunit_num FROM bivvcars.bunit WHERE bunit_name = 'Mississippi')
   AND cont_num = 1 AND submitem_prod_id = '71104080201' AND bunit_num = 6 AND submitem_dt_start = to_date('7/1/2018','mm/dd/yyyy')
ORDER BY 1,2,3;
*/

-- main view
CREATE OR REPLACE VIEW BIVV.BIVV_MEDI_CLAIM_LINE_V AS
SELECT row_number() OVER (PARTITION BY pgm_id, ndc_lbl, period_id, co_id, reb_clm_seq_no ORDER BY item_prod_fmly_ndc, item_prod_mstr_ndc) AS ln_itm_seq_no
   ,v.*
FROM bivv_medi_claim_line_val_v v
WHERE NVL(val_msg,'OK') NOT LIKE 'ERR%'
;
