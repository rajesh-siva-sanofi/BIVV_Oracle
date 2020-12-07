CREATE OR REPLACE VIEW HCRS.BIVV_RECON_URA_LOAD_V AS
WITH
pgm AS (
   SELECT
      cp.pur_catg_cd
      ,pp.pgm_id
      ,pp.ndc_lbl, pp.ndc_prod, pp.ndc_pckg
      ,cp.begin_qtr_dt, cp.end_qtr_dt
   FROM hcrs.prod_mstr_pgm_t pp
      ,hcrs.pur_catg_pgm_t cp
   WHERE 1=1
      AND pp.pgm_id = cp.pgm_id),
j AS (
   SELECT
      r.period_id, to_char(r.per_begin_dt, 'yyyy"Q"q') AS qtr
      ,pgm.ndc_lbl, pgm.ndc_prod, pgm.ndc_pckg
--      ,pgm.eff_dt, pgm.end_dt
      ,pm.first_dt_sld
      ,pgm.pur_catg_cd, pgm.pgm_id
      ,br.calc_amt AS src_ura
      ,hcrs.f_get_pur (pgm.pgm_id, pgm.ndc_lbl, pgm.ndc_prod, r.period_id, SYSDATE, 'N') AS intrm_ura
      ,hcrs.f_get_pur (pgm.pgm_id, pgm.ndc_lbl, pgm.ndc_prod, r.period_id, SYSDATE, 'Y') AS activ_ura
      ,t.ura AS ddr_ura
   FROM pgm
   INNER JOIN hcrs.prod_mstr_t pm ON pm.ndc_lbl = pgm.ndc_lbl AND pm.ndc_prod = pgm.ndc_prod AND pm.ndc_pckg = pgm.ndc_pckg
   INNER JOIN hcrs.pur_final_results_t r ON
      pgm.pgm_id = r.pgm_id
      AND pgm.ndc_lbl = r.ndc_lbl AND pgm.ndc_prod = r.ndc_prod AND pgm.ndc_pckg = r.ndc_pckg
      AND r.per_begin_dt BETWEEN pgm.begin_qtr_dt AND pgm.end_qtr_dt
   LEFT OUTER JOIN bivv.temp_ddr_amp_bp_ura_t t ON
      t.ndc = pgm.ndc_lbl ||'-'|| pgm.ndc_prod
      AND REGEXP_REPLACE(t.period, '[^0-9A-Za-z/]', '') = to_char(r.per_begin_dt, 'q/yyyy')
      AND pgm.pur_catg_cd = 'FDRL' -- only get it for Federal URA, DDR only has FDRL URAs
   LEFT OUTER JOIN bivv.bivv_pur_final_results_v br ON
      pgm.pgm_id = br.pgm_id
      AND pgm.ndc_lbl = br.ndc_lbl AND pgm.ndc_prod = br.ndc_prod AND pgm.ndc_pckg = br.ndc_pckg
      AND r.period_id = br.period_id
   WHERE 1=1
),
cmp AS (
   SELECT
      CASE
         WHEN activ_ura IS NULL THEN 'Loaded URA does not exist'
         WHEN activ_ura != src_ura THEN 'Loaded URA does not match source Flex URA'
         WHEN activ_ura != ddr_ura THEN 'Loaded URA does not match DDR URA'
         WHEN activ_ura != intrm_ura THEN 'Loaded URA does not match calculated URA'
         WHEN intrm_ura IS NULL THEN 'Calculated URA does not exist'
      ELSE 'OK'
      END AS val_msg
      ,j.*
   FROM j)
SELECT cmp."VAL_MSG",cmp."PERIOD_ID",cmp."QTR",cmp."NDC_LBL",cmp."NDC_PROD",cmp."NDC_PCKG",cmp."FIRST_DT_SLD",cmp."PUR_CATG_CD",cmp."PGM_ID",cmp."SRC_URA",cmp."INTRM_URA",cmp."ACTIV_URA",cmp."DDR_URA", p.pgm_cd
FROM cmp
   ,hcrs.pgm_t p
WHERE 1=1
   AND cmp.pgm_id = p.pgm_id
   AND cmp.ndc_lbl = '71104'
ORDER BY
   period_id
   ,ndc_lbl, ndc_prod, ndc_pckg
   ,pur_catg_cd, cmp.pgm_id;
