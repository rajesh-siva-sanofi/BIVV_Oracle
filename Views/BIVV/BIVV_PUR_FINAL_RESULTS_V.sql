CREATE OR REPLACE VIEW BIVV_PUR_FINAL_RESULTS_VAL_V AS
WITH src AS (
   SELECT 
      p.prod_id_pri as ndc11
      ,TO_CHAR(cqh.calcqtrhdr_dt_start,'YYYY"Q"Q') AS qtr
      ,cq.rpu
      ,cqh.calcqtrhdr_dt_start
      ,cqh.calcqtrhdr_dt_end
      ,f.formula_name, f.formula_desc
      ,s.status_desc
      ,cq.calcqtr_num
      ,cq.calcqtr_num_prior
      ,cppt.cont_num
      ,c.cont_title
   FROM
      bivvcars.calcqtr cq
      ,bivvcars.prod p
      ,bivvcars.calcqtrhdr cqh
      ,bivvcars.status s
      ,bivvcars.formula f
      ,bivvcars.cppt
      ,bivvcars.cont c
   WHERE 1=1
      AND cq.status_num = s.status_num
      AND cq.status_num = 2010 --Active
      AND p.prod_num  = cq.prod_num
      AND cqh.calcqtrhdr_num = cq.calcqtrhdr_num
      AND cq.formula_num = f.formula_num (+)
      AND cq.cppt_num = cppt.cppt_num
      AND cppt.cont_num = c.cont_num),
val AS (
   SELECT src.cont_num, src.ndc11, src.qtr, COUNT(*) AS cnt
   FROM src
   GROUP BY src.cont_num, src.ndc11, src.qtr)
SELECT 
   CASE 
      WHEN (SELECT cnt FROM val WHERE val.cont_num = src.cont_num AND val.ndc11 = src.ndc11 AND val.qtr = src.qtr) > 1 THEN 'ERR: Multiple URAs. Adjust query' 
      WHEN pm.hcrs_pgm_id IS NULL THEN 'ERR: Contract not mapped'
   ELSE 'OK' END AS val_msg
   ,DECODE(src.cont_num, 1, 1, pm.hcrs_pgm_id) AS pgm_id -- load Medicaid FDRL URAs under Alaska Fdrl program
   ,src.*
FROM src
   ,medi_pgms_map_v pm
WHERE src.cont_num = pm.cont_num (+)
;

CREATE OR REPLACE VIEW BIVV_PUR_FINAL_RESULTS_V AS
SELECT
   DISTINCT
   p.period_id, p.first_day_period AS per_begin_dt, p.last_day_period AS per_end_dt
   ,s.pgm_id -- load Medicaid FDRL URAs under Alaska Fdrl program
--   ,DECODE(s.cont_num, 1, 1, pm.hcrs_pgm_id) AS pgm_id -- load Medicaid FDRL URAs under Alaska Fdrl program
   ,SUBSTR(s.ndc11,1,5) AS ndc_lbl, SUBSTR(s.ndc11,6,4) AS ndc_prod, SUBSTR(s.ndc11,10,2) AS ndc_pckg
   ,s.rpu AS calc_amt, p.last_day_period + 1 AS eff_dt, to_date('1/1/2100','mm/dd/yyyy') AS end_dt, 'HCRS' AS src_sys, s.calcqtr_num AS src_sys_unique_id
   ,s.cont_num, s.cont_title, s.formula_name
FROM bivv_pur_final_results_val_v s
--   ,medi_pgms_map_v pm
   ,hcrs.period_t p
WHERE NVL(s.val_msg, 'OK') = 'OK'
--   AND s.cont_num = pm.cont_num
   AND s.calcqtrhdr_dt_start = p.first_day_period;

--SELECT COUNT(*)
--FROM bivv.bivv_pur_final_results_v
--WHERE 1=1
--   AND NVL(val_msg, 'OK') != 'OK'
--;
--SELECT 
----   COUNT(*)
--   v.*
--FROM pur_final_results_v v
--WHERE cont_num = 1
--ORDER BY cont_num, ndc_lbl, ndc_prod, ndc_pckg, period_id;
--
--SELECT f.pgm_id, p.pgm_nm, f.ndc_lbl, COUNT(*)
--FROM hcrs.pur_final_results_t f
--   ,hcrs.pgm_t p
--WHERE 1=1
--   AND f.pgm_id = p.pgm_id
--GROUP BY f.pgm_id, p.pgm_nm, f.ndc_lbl
--ORDER BY 1,2;
--
--SELECT * FROM hcrs.pur_final_results_t
--WHERE pgm_id IN (1640, 1660) -- BETWEEN 2 AND 50 OR pgm_id = 1544
--ORDER BY per_begin_dt DESC, pgm_id;
--
--
--SELECT 
----   hcrs_pgm_id, COUNT(*)
--   t.hcrs_pgm_id, state_cd, t.*
--FROM medi_pgms_map_v t
--WHERE t.cont_num = 2
----GROUP BY hcrs_pgm_id
----HAVING COUNT(*) > 1
--ORDER BY t.hcrs_pgm_id, t.state_cd
--;
