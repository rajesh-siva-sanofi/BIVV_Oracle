CREATE OR REPLACE VIEW BIVV_PGM_PROD_VAL_V AS
WITH v AS (
   SELECT    
      b.bunit_id_pri, p.prod_id_pri,c.cont_internal_id, c.cont_num
      ,SUBSTR(p.prod_id_pri,1,5) AS ndc_lbl, SUBSTR(p.prod_id_pri,6,4) AS ndc_prod, SUBSTR(p.prod_id_pri,10,2) AS ndc_pckg
      ,pm.first_dt_sld, hcrs.prod_mstr.f_termdate(pm.ndc_lbl, pm.ndc_prod, pm.ndc_pckg) AS term_dt
      ,p.prod_dt_first_sale, p.prod_dt_cms_expire
      ,cp.cppt_dt_start, cp.cppt_dt_end    
      ,(SELECT COUNT(*) FROM bivvcars.adjitem ai WHERE pg.cpgrp_num = ai.cpgrp_num AND ai.bunit_num = b.bunit_num) AS adjitems_cnt
   FROM 
      bivvcars.cont c
      ,bivvcars.cpgrp pg
      ,bivvcars.cppt cp
      ,bivvcars.prod p
      ,hcrs.prod_mstr_t pm
      ,bivvcars.elig e
      ,bivvcars.bunit b
   WHERE 1=1
      AND c.cont_num = pg.cont_num
      AND c.num_sys_id = 102 -- MEDI
      AND pg.cpgrp_dt_end >= to_date('1/1/2018','mm/dd/yyyy')
      AND c.cont_internal_id NOT IN ('TEST', 'TESTING - DO NOT', 'do not use')
      AND UPPER(pg.cpgrp_desc) NOT LIKE 'HISTORIC%'
      AND p.prod_id_pri LIKE '71104%' -- only Bioverativ products
      AND pg.cpgrp_num = cp.cpgrp_num
      AND cp.status_num IN (60,61) -- Active, Edit Pending
      AND cp.prod_num = p.prod_num
      AND pg.eligset_num = e.eligset_num
      AND e.status_num IN (40,41) -- Active, Edit Pending
      AND e.bunit_num = b.bunit_num
      AND SUBSTR(p.prod_id_pri,1,5) = pm.ndc_lbl (+)
      AND SUBSTR(p.prod_id_pri,6,4) = pm.ndc_prod (+)
      AND SUBSTR(p.prod_id_pri,10,2) = pm.ndc_pckg (+)
)
SELECT 
   CASE 
      WHEN m.hcrs_pgm_id IS NULL AND v.adjitems_cnt > 0 THEN 'ERR: HCRS program not mapped and claim lines found'
      WHEN v.first_dt_sld IS NULL THEN 'ERR: Product not found in HCRS'
      WHEN m.hcrs_pgm_id IS NULL THEN 'WARN: HCRS program not mapped, but no claim lines found'
      WHEN (SELECT COUNT(*) FROM hcrs.pgm_t p WHERE p.pgm_id = m.hcrs_pgm_id) = 0 THEN 'ERR: Program not found in HCRS'
      ELSE 'OK' 
   END AS val_msg
   ,m.hcrs_pgm_id AS pgm_id, m.pgm_cd, m.pgm_nm, m.eff_dt AS pgm_eff_dt, m.end_dt AS pgm_end_dt
   ,v.*
FROM v
   ,medi_pgms_map_v m
WHERE 1=1
   AND v.cont_num = m.cont_num (+)
   AND v.bunit_id_pri = m.state_cd (+)
   -- for these 5 pgms only show eligbility where claims exists because otherwise we get eligbility for all 51 states
--   AND CASE WHEN v.cont_internal_id IN ('VAMCOCCCPL', 'VAMCOCCCPLEXP', 'VAMCOMD4', 'VAMCOMD4EXP', 'WICDP') THEN v.adjitems_cnt ELSE 1 END > 0
   AND CASE 
      -- for these pgms only show eligbility for the states they are intented
      WHEN v.cont_internal_id IN ('VAMCOCCCPL', 'VAMCOCCCPLEXP', 'VAMCOMD4', 'VAMCOMD4EXP') AND v.bunit_id_pri = 'VA' THEN 1
      WHEN v.cont_internal_id IN ('WICDP', 'WISENIOR') AND v.bunit_id_pri = 'WI' THEN 1 
      WHEN v.cont_internal_id IN ('KYMCOSH') AND v.bunit_id_pri = 'KY' THEN 1
      WHEN v.cont_internal_id IN ('VAMCOCCCPL', 'VAMCOCCCPLEXP', 'VAMCOMD4', 'VAMCOMD4EXP', 'WICDP', 'WISENIOR', 'KYMCOSH') THEN 0 -- exclude these programs for any other states            
      ELSE 1 END > 0 
   AND v.cont_internal_id NOT IN (SELECT cont_internal_id FROM bivv.bivv_cont_excl_v) -- exclude not needed contracts
;

CREATE OR REPLACE VIEW BIVV_PGM_PROD_V AS 
SELECT pgm_id, pgm_cd, pgm_nm, ndc_lbl, ndc_prod, ndc_pckg
   -- set eff date to 1/1/2018 (Q1 2018) for products launched before 2018. For products after 2018 the set the eff_dt to first day of a launch qtr.
   ,GREATEST (TRUNC(first_dt_sld, 'Q'), to_date('1/1/2018','mm/dd/yyyy'), pgm_eff_dt) AS eff_dt
   -- set to earliest of prod expiration (last day of qtr), pgm expiration dt, or "end of time"
   ,LEAST (NVL((ADD_MONTHS(TRUNC(term_dt, 'Q'), 3) - 1), pgm_end_dt), to_date('1/1/2100','mm/dd/yyyy')) AS end_dt
   ,first_dt_sld, term_dt, pgm_eff_dt, pgm_end_dt
   ,cont_internal_id
FROM BIVV_PGM_PROD_VAL_V
WHERE NVL(val_msg,'OK') = 'OK';
