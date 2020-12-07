CREATE OR REPLACE VIEW HCRS.PUR_EVALUATE_V AS
WITH z AS(
/****************************************************************************
   * View Name : pur_evaluate_v
   * Date Created : 09/29/2014
   * Author : Tom Zimmerman
   *  Description : View detailing the URA Components. Report criteria should be Program, Claim Period, Product
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  02/13/2015  T. Zimmerman  Fixed issue with category level query
   *  05/23/2019  J. Tronoski   Added IQVIA Sourced formulas
   *                            Added CASE statements to Formula and CALC_DETAIL
   *  11/30/2020  M. Gedzior    Added BIVV (Bioverativ) for imported pur_final_results_t
   ****************************************************************************/
SELECT formula_descr AS Formula_title
       ,HCRS.PKG_PUR_CALC.f_get_calc_detail(
                                    --input
                                    i_ndc_lbl        => ndc_lbl,
                                    i_ndc_prod       => ndc_prod,
                                    i_ndc_pckg       => ndc_pckg,
                                    i_period_id      => period_id,
                                    --derived input
                                    i_formula_id     => t.formula_id,
                                    i_pgm_id         => pgm_id,
                                    i_pur_catg_cd    => pur_catg_cd,
                                    i_override_level => override_level
                                    ) AS calc_detail
       ,hcrs.pkg_pur_calc.f_get_pur_report(i_pgm_id       => t.pgm_id,
                                   i_ndc_lbl      => t.ndc_lbl,
                                   i_ndc_prod     => t.ndc_prod,
                                   i_period_id    => t.period_id,
                                   i_request_dt   => SYSDATE,
                                   i_active_flag  => 'Y',
                                   i_ndc_pckg     => t.ndc_pckg
                                   ) AS pur
       ,ndc_lbl
       ,ndc_prod
       ,ndc_pckg
       ,first_day_period
       ,last_day_period
       ,period
       --derived input
       ,period_id
       ,t.formula_id
       ,pgm_id
       ,pur_catg_cd
       ,override_level
FROM (-- Get the Category level
      SELECT distinct
             --input
              pfdc.ndc_lbl
             ,pfdc.ndc_prod
             ,NULL AS ndc_pckg
             ,p.first_day_period
             ,p.last_day_period
             --derived input
             ,p.period_id
             ,'Q'||p.qtr||'/'||p.yr AS period
             ,pcf.formula_id
             ,pcp.pgm_id AS pgm_id -- was -1???
             ,pcf.pur_catg_cd
             ,'CATG' AS override_level
             ,pf.formula_descr
      FROM     hcrs.period_t p,
               hcrs.prod_fmly_drug_catg_t pfdc,
               hcrs.drug_catg_grp_asgnmnt_t dcga,
               hcrs.pur_catg_formula_t pcf,
               hcrs.pur_catg_pgm_t pcp,
               hcrs.pur_formula_t pf,
               hcrs.prod_mstr_pgm_t pmp -- product must exist on a pgm using this category
      WHERE   1=1
      AND      TRUNC(p.first_day_period) BETWEEN pfdc.eff_dt AND pfdc.end_dt
      AND      dcga.drug_catg_cd = pfdc.drug_catg_cd
      AND      pcf.drug_catg_grp_cd = dcga.drug_catg_grp_cd
      AND      pcf.pur_catg_cd = pcp.pur_catg_cd
      AND      pf.formula_id = pcf.formula_id
      AND      SYSDATE BETWEEN pcf.eff_dt AND pcf.end_dt
      AND      TRUNC(p.first_day_period) BETWEEN TRUNC(pcf.begin_qtr_dt) AND TRUNC(pcf.end_qtr_dt)
      AND      sysdate BETWEEN pcp.eff_dt AND pcp.end_dt
      AND      TRUNC( p.first_day_period) BETWEEN TRUNC( pcp.begin_qtr_dt) AND TRUNC( pcp.end_qtr_dt)
      AND      pmp.pgm_id = pcp.pgm_id
      AND      TRUNC( p.first_day_period) BETWEEN pmp.eff_dt AND pmp.end_dt
      AND      pmp.ndc_lbl = pfdc.ndc_lbl
      AND      pmp.ndc_prod = pfdc.ndc_prod
      AND NOT EXISTS (
                  SELECT 1
                  FROM   hcrs.pur_formula_pgm_prod_assoc_t pfppa
                  WHERE  pfppa.ndc_lbl = pmp.ndc_lbl
                  AND    pfppa.ndc_prod =  pmp.ndc_prod
                  AND    pfppa.pgm_id = pcp.pgm_id
                  AND    SYSDATE BETWEEN pfppa.eff_dt AND pfppa.end_dt
                  AND    TRUNC( p.first_day_period) BETWEEN TRUNC(pfppa.begin_qtr_dt) AND TRUNC(pfppa.end_qtr_dt)
                  AND    pfppa.pur_catg_cd = pcf.pur_catg_cd
                  )
      -- line extension
      --If program is assigned pur_catg_cd = 'FDRL' we need to implement the logic below to properly handle line extension drugs.
      --for periods prior to Q1/2010 display CATG level for all NDC
      --for periods from Q1/2010 for line extension drugs display the PCKG level; for all other NDC display the CATG level
      AND (pfdc.ndc_lbl,pfdc.ndc_prod) NOT IN (SELECT DISTINCT x.extd_ndc_lbl,
                                                             x.extd_ndc_prod
                                               FROM  hcrs.pur_extd_ndc_xref_t x
                                               WHERE 1=1--to_date('01/01/2010','MM/DD/YYYY') BETWEEN TRUNC(x.begin_qtr_dt) AND TRUNC(x.end_qtr_dt)
                                               AND SYSDATE BETWEEN x.eff_dt AND x.end_dt
                                               AND pcf.pur_catg_cd = 'FDRL'
                                               AND p.first_day_period >= to_date('01/01/2010','MM/DD/YYYY')
                                               AND  x.eff_dt = (SELECT MAX( x2.eff_dt)
                                                                FROM   hcrs.pur_extd_ndc_xref_t x2
                                                                WHERE  x2.extd_ndc_lbl = x.extd_ndc_lbl
                                                                AND    x2.extd_ndc_prod = x.extd_ndc_prod
                                                                AND    TRUNC(x.begin_qtr_dt) BETWEEN TRUNC(x2.begin_qtr_dt) AND TRUNC(x2.end_qtr_dt)
                                                                AND    SYSDATE BETWEEN x2.eff_dt AND x2.end_dt))
      -- Get the Package level
      UNION ALL
      SELECT --input
              ndc_lbl
             ,ndc_prod
             ,ndc_pckg
             ,p.first_day_period
             ,p.last_day_period
             --derived input
             ,p.period_id
             ,'Q'||p.qtr||'/'||p.yr AS period
             ,pf.formula_id
             ,pfppa.pgm_id
             ,pfppa.pur_catg_cd
             ,'PCKG' AS override_level
             ,pf.formula_descr
      FROM     hcrs.pur_formula_pgm_prod_assoc_t pfppa,
               hcrs.period_t p,
               hcrs.pur_formula_t pf
      WHERE    SYSDATE BETWEEN pfppa.eff_dt AND pfppa.end_dt
      AND      TRUNC(p.first_day_period) BETWEEN TRUNC(pfppa.begin_qtr_dt) AND TRUNC(pfppa.end_qtr_dt)
      AND      pf.formula_id = pfppa.formula_id
      -- Get the IQVIA formulas
      UNION ALL
      SELECT --input
             pfr.ndc_lbl
            ,pfr.ndc_prod
            ,pfr.ndc_pckg
            ,p.first_day_period
            ,p.last_day_period
            --derived input
            ,p.period_id
            ,'Q'||p.qtr||'/'||p.yr    PERIOD
            ,NULL        FORMULA_ID
            ,pfr.pgm_id
            ,x.pur_catg_cd
            ,'PCKG'       OVERRIDE_LEVEL
            ,'Sourced from '||pfr.src_sys AS FORMULA_DESCR
        FROM hcrs.pur_final_results_t pfr
            ,hcrs.period_t p
            ,(SELECT pcp.pgm_id, MAX(pur_catg_cd)
                KEEP (DENSE_RANK LAST
                      ORDER BY pcp.end_qtr_dt) PUR_CATG_CD
                FROM hcrs.pur_catg_pgm_t pcp
               WHERE SYSDATE BETWEEN pcp.eff_dt AND pcp.end_dt
                 AND pcp.eff_dt = (SELECT MAX(pcp2.eff_dt)
                                     FROM hcrs.pur_catg_pgm_t pcp2
                                    WHERE pcp2.pgm_id   = pcp.pgm_id
                                      AND SYSDATE BETWEEN pcp2.eff_dt AND pcp2.end_dt)
              GROUP BY pcp.pgm_id) x
       WHERE pfr.period_id  = p.period_id
         AND pfr.pgm_id  = x.pgm_id (+)
         AND pfr.src_sys IN ('IQVIA','BIVV')
         AND TRUNC(pfr.end_dt)= TO_DATE('01012100','mmddyyyy')
         AND SYSDATE BETWEEN pfr.eff_dt AND pfr.end_dt
         AND p.period_id > 153
    )  t
  )
SELECT --input
        z.ndc_lbl
       ,z.ndc_prod
       ,z.ndc_pckg
       ,z.first_day_period
       ,z.last_day_period
       ,z.period
       --derived input
       ,z.period_id
       ,z.formula_id
       ,z.pgm_id
       ,p.pgm_cd
       ,p.pgm_nm
       ,z.pur_catg_cd
       ,z.override_level
       --output
       ,z.Formula_title
       ,trim(substr(calc_detail,INSTR(calc_detail,'|',1,1)+1,INSTR(calc_detail,'|',1,2)-INSTR(calc_detail,'|',1,1)-1 )) AS Formula_detail
       ,trim(substr(calc_detail,INSTR(calc_detail,'|',1,2)+1,INSTR(calc_detail,'|',1,3)-INSTR(calc_detail,'|',1,2)-1 )) AS Formula_top_values
       ,trim(substr(calc_detail,INSTR(calc_detail,'|',1,3)+1,INSTR(calc_detail,'|',1,4)-INSTR(calc_detail,'|',1,3)-1 )) AS Formula_detail_values
       ,trim(substr(calc_detail,INSTR(calc_detail,'|',1,4)+1,INSTR(calc_detail,'|',1,5)-INSTR(calc_detail,'|',1,4)-1 )) AS Formula_Missing_items
       ,trim(substr(calc_detail,INSTR(calc_detail,'|',1,5)+1,INSTR(calc_detail,'|',1,6)-INSTR(calc_detail,'|',1,5)-1 )) AS Formula_Calc
       ,CASE WHEN z.formula_title LIKE 'Sourced from %'
         THEN SUBSTR(z.formula_title, LENGTH('Sourced from ')+1, LENGTH(z.formula_title) - LENGTH('Sourced from '))
         ELSE trim(substr(calc_detail, INSTR(calc_detail,'|',1,6)+1, LENGTH(calc_detail) - INSTR(calc_detail,'|',1,6)))
        END AS Formula
       ,DECODE(z.pur,NULL,'N','Y') AS pur_active
       ,DECODE(z.pur,NULL,'NULL!',pur) AS active_pur_value
       ,CASE WHEN z.formula_title LIKE 'Sourced from %' THEN NULL ELSE calc_detail END AS CALC_DETAIL
FROM z,
     hcrs.pgm_t p
WHERE p.pgm_id = z.pgm_id
ORDER BY  z.ndc_lbl
       ,z.ndc_prod
       ,z.ndc_pckg
       ,z.first_day_period
;
