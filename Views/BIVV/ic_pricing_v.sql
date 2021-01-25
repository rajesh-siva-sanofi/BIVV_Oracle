CREATE OR REPLACE VIEW BIVV.IC_PRICING_V AS
/****************************************************************************
 * View Name    : bivv.ic_pricing_v
 * Date Created : 08.21.2020
 * Author       : JTronoski (IntegriChain)
 * Description  : Bioverativ (FLEX IC) Pricing Master data
 *
 * MOD HISTORY
 *  Date        Modified by   Reason
 *  ----------  ------------  ------------------------------------------------
 *  12.14.2020  JTronoski     Added uom_num filters to select from bivvcars.pbasis
****************************************************************************/
WITH ddr_qtr_data
  AS (-- Extract quarterly amp/bp data from ddr table
      SELECT SUBSTR(period,4,4) || SUBSTR(period,1,1) year_qtr
            --,CASE WHEN ndc = '64406-0811'
            --      THEN '64406-0911'
            -- ELSE ndc
            -- END ndc9
            ,ndc ndc9
            ,amp
            ,best_price
            ,base_amp_used_for_ura
            ,ura
        FROM bivv.temp_ddr_amp_bp_ura_t x
--     ) SELECT COUNT(*) OVER () cnt, ddr_qtr_data.* 
--         FROM ddr_qtr_data
--       ORDER BY 1,3,2
     ),
  ddr_qtr_data2
  AS (-- Align the Biogen/Bioverativ AMP and BP data by quarter and ndc product
      SELECT year_qtr
            ,SUBSTR(ndc9,7,4) ndc_prod
            ,SUM(CASE WHEN SUBSTR(ndc9,1,5) = '64406'
                      THEN amp
                 ELSE NULL
                 END) ddr_biogen_amp
            ,SUM(CASE WHEN SUBSTR(ndc9,1,5) = '64406'
                      THEN best_price
                 ELSE NULL
                 END) ddr_biogen_bp 
            ,SUM(CASE WHEN SUBSTR(ndc9,1,5) = '71104'
                      THEN amp
                 ELSE NULL
                 END) ddr_bioverativ_amp
            ,SUM(CASE WHEN SUBSTR(ndc9,1,5) = '71104'
                      THEN best_price
                 ELSE NULL
                 END) ddr_bioverativ_bp
        FROM ddr_qtr_data
      GROUP BY year_qtr, SUBSTR(ndc9,7,4)
--     ) SELECT COUNT(*) OVER () cnt, ddr_qtr_data2.* 
--         FROM ddr_qtr_data2
--       ORDER BY 1,2,3
     ),
  ddr_qtr_data3
  AS (-- Align the Biogen/Bioverativ AMP and BP data by quarter and ndc product
      SELECT x.year_qtr
            ,x.ndc9
            ,x.amp
            ,x.best_price
            ,x.base_amp_used_for_ura
            ,x.ura
            ,CASE WHEN SUBSTR(x.ndc9,1,5) = '71104'
                  THEN ddr_biogen_amp
             ELSE NULL
             END ddr_parent_amp
            ,CASE WHEN SUBSTR(x.ndc9,1,5) = '71104'
                  THEN ddr_biogen_bp
             ELSE NULL
             END ddr_parent_bp
        FROM ddr_qtr_data x
            ,ddr_qtr_data2 y
       WHERE x.year_qtr = y.year_qtr
         AND SUBSTR(x.ndc9,7,4) = y.ndc_prod
--     ) SELECT COUNT(*) OVER () cnt, ddr_qtr_data3.* 
--         FROM ddr_qtr_data3
--       ORDER BY 1,2,3
--     ) SELECT year_qtr, ndc9
--         FROM ddr_qtr_data
--       MINUS
--       SELECT year_qtr, ndc9
--         FROM ddr_qtr_data3
     ),
  ic_gp_amp_bp
  AS (-- Extract quarterly amp/bp data from IC GP tables
      SELECT ndc11
            ,ndc9
            ,year_qtr
            ,SUM(CASE WHEN pricing_type = 1
                      THEN price
                 ELSE NULL
                 END) gp_amp_qtrly 
            ,SUM(CASE WHEN pricing_type = 2
                      THEN price
                 ELSE NULL
                 END) gp_bp_qtrly
            ,SUM(CASE WHEN pricing_type = 66
                      THEN price
                 ELSE NULL
                 END) gp_amp_5i_qtrly
        FROM (SELECT p.ndc11
                    ,SUBSTR(p.ndc11,1,5) || '-' || SUBSTR(p.ndc11,6,4) ndc9
                    ,pb.product_id
                    ,pt.description AS price_type
                    ,pb.pricing_type
                    ,pb.effective_start_date
                    ,pb.effective_end_date
                    ,TO_CHAR(pb.effective_start_date,'YYYY""Q') year_qtr
                    ,pb.production_date
                    ,pb.obsolete_date
                    ,pb.price
                    ,pb.reason
                    ,pb.status
                FROM bivvgp.mdm_prod_vw p
                    ,bivvgp.gp_pbasis pb
                    ,bivvgp.gp_pricing_type pt
               WHERE 1=1 
                 AND pb.product_id = p.product_id
                 AND pb.pricing_type = pt.pricing_type 
                 AND pb.status = 'PRODUCTION'
                     -- ========================================
                     -- pb.pricing_type 1 = AMP - Quarterly
                     -- pb.pricing_type 66 = AMP 5i - Quarterly
                     -- pb.pricing_type 2 = BP - Quarterly 
                     -- ========================================
                 AND pb.pricing_type IN (1,2,66)
                 AND pb.obsolete_date = TO_DATE('12312099','mmddyyyy'))
      GROUP BY ndc11, ndc9, year_qtr
--     ) SELECT COUNT(*) OVER () cnt, ic_gp_amp_bp.* 
--         FROM ic_gp_amp_bp
--       ORDER BY 1,2,3
     ),
  ic_rm_amp_bp
  AS (-- Extract quarterly amp/bp data from IC RM tables
      SELECT ndc11
            ,ndc9
            ,year_qtr
            ,SUM(CASE WHEN pbasiscd_num = 23
                      THEN pbasis_unit
                 ELSE NULL
                 END) rm_amp_qtrly
            ,SUM(CASE WHEN pbasiscd_num = 24
                      THEN pbasis_unit
                 ELSE NULL
                 END) rm_bp_qtrly
            ,SUM(CASE WHEN pbasiscd_num = 1033
                      THEN pbasis_unit
                 ELSE NULL
                 END) rm_amp_5i_qtrly
        FROM (SELECT p.prod_id_pri ndc11
                    ,SUBSTR(p.prod_id_pri,1,5) || '-' || SUBSTR(p.prod_id_pri,6,4) ndc9
                    ,TRUNC(g.pbasis_dt_effective)
                    ,TO_CHAR(g.pbasis_dt_effective,'YYYY""Q') year_qtr
                    ,g.pbasis_unit
                    ,g.pbasiscd_num
                FROM bivvcars.pbasis g
                    ,bivvcars.prod p
                    ,bivvcars.status s
               WHERE g.prod_num = p.prod_num
                 AND g.status_num = s.status_num
                     -- ========================================
                     -- g.pbasiscd_num 23 = AMP - Quarterly
                     -- g.pbasiscd_num 1033 = AMP_5i - Quarterly
                     -- g.pbasiscd_num 24 = BP - Quarterly 
                     -- g.uom_num = 1 - Unit
                     -- ========================================
                 AND g.pbasiscd_num IN (23,24,1033)
                 AND g.uom_num = 1
                 AND p.pident_id_pri = 'NDC-11'
                 AND s.status_abbr = 'ACT')
      GROUP BY ndc11, ndc9, year_qtr
--     ) SELECT COUNT(*) OVER () cnt, ic_rm_amp_bp.* 
--         FROM ic_rm_amp_bp
--       ORDER BY 1,2,3
--     ) SELECT ndc9, year_qtr
--         FROM ic_rm_amp_bp
--       MINUS
--       SELECT ndc9, year_qtr
--         FROM ic_gp_amp_bp
     ),
  ic_amp_bp
  AS (-- Merge the quarterly amp/bp data from IC RM tables and IC GP Tables
      -- Determine an AMP/BP Value
      SELECT x.ndc11
            ,x.ndc9
            ,x.year_qtr
            ,x.rm_amp_qtrly
            ,x.rm_amp_5i_qtrly
            ,x.rm_bp_qtrly
            ,y.gp_amp_qtrly
            ,y.gp_amp_5i_qtrly
            ,y.gp_bp_qtrly
            ,COALESCE(x.rm_amp_qtrly, x.rm_amp_5i_qtrly, y.gp_amp_qtrly, y.gp_amp_5i_qtrly) amp_qtrly
            ,COALESCE(x.rm_bp_qtrly, y.gp_bp_qtrly) bp_qtrly
        FROM ic_rm_amp_bp x
            ,ic_gp_amp_bp y
       WHERE x.ndc9 = y.ndc9 (+)
         AND x.year_qtr = y.year_qtr (+)
--     ) SELECT COUNT(*) OVER () cnt, ic_amp_bp.* 
--         FROM ic_amp_bp
--       ORDER BY 1,2,3
--     ) SELECT ndc9, year_qtr
--         FROM ic_rm_amp_bp
--         FROM ic_gp_amp_bp
--       MINUS
--       SELECT ndc9, year_qtr
--         FROM ic_amp_bp
     ),
  gp_prod
  AS (-- Extract GP product information
      SELECT x.ndc11
            ,SUBSTR(x.ndc11,6,4) ndc_prod
            ,x.market_date_ndc9
            ,CASE WHEN x.first_sale_date_ndc9 IS NULL
                  THEN xx.min_lfs
             ELSE x.first_sale_date_ndc9
             END first_sale_date_ndc9
            ,x.first_sale_date_ndc11
        FROM bivvgp.product x
            ,(SELECT ndc_prod, MIN(least_first_sale) min_lfs
                FROM (SELECT SUBSTR(ndc11,6,4) ndc_prod
                            ,LEAST(NVL(first_sale_date_ndc9,SYSDATE)
                                  ,NVL(first_sale_date_ndc11,SYSDATE)) least_first_sale
                        FROM bivvgp.product)
              GROUP BY ndc_prod) xx
       WHERE SUBSTR(x.ndc11,6,4) = xx.ndc_prod
--     ) SELECT COUNT(*) OVER () cnt, gp_prod.* 
--         FROM gp_prod
--       ORDER BY 1,2,3,4
     ),
  ic_qtr_data
  AS (-- Merge the market/first sale date with the AMP/BP IC Data
      SELECT a.ndc11
            ,a.ndc9
            ,a.year_qtr
            ,b.market_date_ndc9
            ,b.first_sale_date_ndc9
            ,b.first_sale_date_ndc11
            ,a.amp_qtrly
            ,a.bp_qtrly
            ,add_months(TRUNC(LEAST(b.first_sale_date_ndc9
                                   ,b.first_sale_date_ndc11), 'q'), 3) base_amp_qtr_start
        FROM ic_amp_bp a
            ,gp_prod b
       WHERE a.ndc11 = b.ndc11
--     ) SELECT COUNT(*) OVER () cnt, ic_qtr_data.* 
--         FROM ic_qtr_data
--       ORDER BY 1,2,3
     ),
  ic_qtr_data2
  AS (-- Using the first sale date, find the base amp
      SELECT ndc11
            ,ndc9
            ,year_qtr
            ,market_date_ndc9
            ,first_sale_date_ndc9
            ,first_sale_date_ndc11
            ,amp_qtrly
            ,bp_qtrly
            ,base_amp_qtr_start
            ,TO_CHAR(base_amp_qtr_start,'YYYY""Q') base_amp_qtr
            ,CASE WHEN TO_CHAR(base_amp_qtr_start,'YYYY""Q') = year_qtr
                  THEN amp_qtrly
             ELSE NULL
             END base_amp
        FROM ic_qtr_data
--     ) SELECT COUNT(*) OVER () cnt, ic_qtr_data2.* 
--         FROM ic_qtr_data2
--       ORDER BY 1,2,4
--     ),
     ),
  ic_asp_qrtly
  AS (-- Extract ASP Quarterly from IC GP tables
      -- !!!! NDC11 and Year/Qtr exist in ic_asp_qrtly but NOT in ic_qtr_data2
      SELECT ndc11
            ,TO_CHAR(pb.effective_start_date,'YYYY""Q') year_qtr
            ,pb.price asp_qrtly
        FROM bivvgp.gp_pbasis pb
            ,bivvgp.product p
       WHERE 1=1
         AND pb.product_id = p.product_id
         AND pb.pricing_type = 30 -- ASP Quarterly
         AND pb.status = 'PRODUCTION'
         AND pb.obsolete_date = TO_DATE('12312099','mmddyyyy')
--     ) SELECT COUNT(*) OVER () cnt, ic_asp_qrtly.* 
--         FROM ic_asp_qrtly
--       ORDER BY 1,2,3
--     ) SELECT ndc11, year_qtr
--         FROM ic_asp_qrtly
--       MINUS
--       SELECT ndc11, year_qtr
--         FROM ic_qtr_data2
--     ) SELECT count(*) 
--         FROM ic_asp_qrtly x
--             ,ic_qtr_data2 y
--        WHERE x.ndc11 = y.ndc11
--          AND x.year_qtr = y.year_qtr
     ),
  ic_qtr_data3
  AS (-- Add the Quarterly ASP information
      SELECT z.ndc11
            ,z.ndc9
            ,z.year_qtr
            ,z.market_date_ndc9
            ,z.first_sale_date_ndc9
            ,z.first_sale_date_ndc11
            ,z.amp_qtrly
            ,z.bp_qtrly
            ,z.base_amp
            ,z.base_amp_qtr
            ,x.asp_qrtly
        FROM ic_qtr_data2 z
            ,ic_asp_qrtly x
        WHERE z.ndc11 = x.ndc11 (+)
          AND z.year_qtr = x.year_qtr (+)
--     ) SELECT COUNT(*) OVER () cnt, ic_qtr_data3.* 
--         FROM ic_qtr_data3
--       ORDER BY 1,2,3
     ),
  ic_gp_amp_mth
  AS (-- Extract AMP Monthly and AMP 5i Monthly from the IC GP Tables
      SELECT ndc11
            ,ndc9
            ,year_qtr
            ,SUM(CASE WHEN pricing_type = 41
                       AND TO_CHAR(effective_start_date,'MM') IN ('01','04','07','10')
                      THEN price
                 ELSE NULL
                 END) gp_amp_mth_1
            ,SUM(CASE WHEN pricing_type = 41
                       AND TO_CHAR(effective_start_date,'MM') IN ('02','05','08','11')
                      THEN price
                 ELSE NULL
                 END) gp_amp_mth_2
            ,SUM(CASE WHEN pricing_type = 41
                       AND TO_CHAR(effective_start_date,'MM') IN ('03','06','09','12')
                      THEN price
                 ELSE NULL
                 END) gp_amp_mth_3
            ,SUM(CASE WHEN pricing_type = 65
                       AND TO_CHAR(effective_start_date,'MM') IN ('01','04','07','10')
                      THEN price
                 ELSE NULL
                 END) gp_amp_5i_mth_1
            ,SUM(CASE WHEN pricing_type = 65
                       AND TO_CHAR(effective_start_date,'MM') IN ('02','05','08','11')
                      THEN price
                 ELSE NULL
                 END) gp_amp_5i_mth_2
            ,SUM(CASE WHEN pricing_type = 65
                       AND TO_CHAR(effective_start_date,'MM') IN ('03','06','09','12')
                      THEN price
                 ELSE NULL
                 END) gp_amp_5i_mth_3
            ,MAX(CASE WHEN TO_CHAR(effective_start_date,'MM') IN ('01','04','07','10')
                      THEN effective_start_date
                 ELSE NULL
                 END) gp_amp_mth_1_strt_dt
            ,MAX(CASE WHEN TO_CHAR(effective_start_date,'MM') IN ('01','04','07','10')
                      THEN effective_end_date
                 ELSE NULL
                 END) gp_amp_mth_1_end_dt
            ,MAX(CASE WHEN TO_CHAR(effective_start_date,'MM') IN ('02','05','08','11')
                      THEN effective_start_date
                 ELSE NULL
                 END) gp_amp_mth_2_strt_dt
            ,MAX(CASE WHEN TO_CHAR(effective_start_date,'MM') IN ('02','05','08','11')
                      THEN effective_end_date
                 ELSE NULL
                 END) gp_amp_mth_2_end_dt
            ,MAX(CASE WHEN TO_CHAR(effective_start_date,'MM') IN ('03','06','09','12')
                      THEN effective_start_date
                 ELSE NULL
                 END) gp_amp_mth_3_strt_dt
            ,MAX(CASE WHEN TO_CHAR(effective_start_date,'MM') IN ('03','06','09','12')
                      THEN effective_end_date
                 ELSE NULL
                 END) gp_amp_mth_3_end_dt
        FROM (SELECT p.ndc11
                    ,SUBSTR(p.ndc11,1,5) || '-' || SUBSTR(p.ndc11,6,4) ndc9
                    ,pb.product_id
                    ,pt.description AS price_type
                    ,pb.pricing_type
                    ,pb.effective_start_date
                    ,pb.effective_end_date
                    ,TO_CHAR(pb.effective_start_date,'YYYY""Q') year_qtr
                    ,pb.production_date
                    ,pb.obsolete_date
                    ,pb.price
                    ,pb.reason
                    ,pb.status
                FROM bivvgp.mdm_prod_vw p
                    ,bivvgp.gp_pbasis pb
                    ,bivvgp.gp_pricing_type pt
               WHERE 1=1 
                 AND pb.product_id = p.product_id
                 AND pb.pricing_type = pt.pricing_type 
                 AND pb.status = 'PRODUCTION'
                     -- ========================================
                     -- pb.pricing_type 41 = AMP - Monthly
                     -- pb.pricing_type 65 = AMP_5i - Monthly
                     -- ========================================
                 AND pb.pricing_type IN (41,65)
                 AND pb.obsolete_date = TO_DATE('12312099','mmddyyyy'))
      GROUP BY ndc11, ndc9, year_qtr
--     ) SELECT COUNT(*) OVER () cnt, ic_gp_amp_mth.* 
--         FROM ic_gp_amp_mth
--       ORDER BY 1,2,3
     ),
  ic_amp_mth
  AS (-- Using monthly amp and monthly 5i amp, determine a monthly amp
      SELECT ndc11
            ,ndc9
            ,year_qtr
            ,gp_amp_mth_1
            ,gp_amp_5i_mth_1
            ,COALESCE(gp_amp_mth_1, gp_amp_5i_mth_1) amp_mth_1
            ,gp_amp_mth_2
            ,gp_amp_5i_mth_2
            ,COALESCE(gp_amp_mth_2, gp_amp_5i_mth_2) amp_mth_2
            ,gp_amp_mth_3
            ,gp_amp_5i_mth_3
            ,COALESCE(gp_amp_mth_3, gp_amp_5i_mth_3) amp_mth_3
            ,gp_amp_mth_1_strt_dt amp_mth_1_strt_dt
            ,gp_amp_mth_1_end_dt amp_mth_1_end_dt
            ,gp_amp_mth_2_strt_dt amp_mth_2_strt_dt
            ,gp_amp_mth_2_end_dt amp_mth_2_end_dt
            ,gp_amp_mth_3_strt_dt amp_mth_3_strt_dt
            ,gp_amp_mth_3_end_dt amp_mth_3_end_dt
        FROM ic_gp_amp_mth
--     ) SELECT COUNT(*) OVER () cnt, ic_amp_mth.* 
--         FROM ic_amp_mth
--       ORDER BY 1,2,3
     ),
  ic_qtr_data4
  AS (-- Add the Montly AMP information
      SELECT z.ndc11
            ,z.ndc9
            ,z.year_qtr
            ,z.market_date_ndc9
            ,z.first_sale_date_ndc9
            ,z.first_sale_date_ndc11
            ,z.amp_qtrly
            ,z.bp_qtrly
            ,z.base_amp
            ,z.base_amp_qtr
            ,z.asp_qrtly
            ,x.amp_mth_1
            ,x.amp_mth_2
            ,x.amp_mth_3
            ,x.amp_mth_1_strt_dt
            ,x.amp_mth_1_end_dt
            ,x.amp_mth_2_strt_dt
            ,x.amp_mth_2_end_dt
            ,x.amp_mth_3_strt_dt
            ,x.amp_mth_3_end_dt
        FROM ic_qtr_data3 z
            ,ic_amp_mth x
        WHERE z.ndc11 = x.ndc11 (+)
          AND z.year_qtr = x.year_qtr (+)
--     ) SELECT COUNT(*) OVER () cnt, ic_qtr_data4.* 
--         FROM ic_qtr_data4
--       ORDER BY 1,2,3
     ),
  ic_fcp_annual
  AS (-- Extract FCP Annual from the IC GP Tables
      SELECT ndc11
            ,TO_CHAR(pb.effective_start_date,'YYYY""Q') year_qtr
            ,pb.price fcp_annual
        FROM bivvgp.gp_pbasis pb
            ,bivvgp.product p
       WHERE 1=1
         AND pb.product_id = p.product_id
         AND pb.pricing_type = 11 -- FCP - Annual 
         AND pb.status = 'PRODUCTION'
         AND pb.obsolete_date = TO_DATE('12312099','mmddyyyy')
--     ) SELECT COUNT(*) OVER () cnt, ic_fcp_annual.* 
--         FROM ic_fcp_annual
--       ORDER BY 1,2,3
     ),
  ic_qtr_data5
  AS (-- Add the FCP Annual information
      SELECT z.ndc11
            ,z.ndc9
            ,z.year_qtr
            ,z.market_date_ndc9
            ,z.first_sale_date_ndc9
            ,z.first_sale_date_ndc11
            ,z.amp_qtrly
            ,z.bp_qtrly
            ,z.base_amp
            ,z.base_amp_qtr
            ,z.asp_qrtly
            ,z.amp_mth_1
            ,z.amp_mth_2
            ,z.amp_mth_3
            ,z.amp_mth_1_strt_dt
            ,z.amp_mth_1_end_dt
            ,z.amp_mth_2_strt_dt
            ,z.amp_mth_2_end_dt
            ,z.amp_mth_3_strt_dt
            ,z.amp_mth_3_end_dt
            ,x.fcp_annual
        FROM ic_qtr_data4 z
            ,ic_fcp_annual x
        WHERE z.ndc11 = x.ndc11 (+)
          AND z.year_qtr = x.year_qtr (+)
--     ) SELECT COUNT(*) OVER () cnt, ic_qtr_data5.* 
--         FROM ic_qtr_data5
--       ORDER BY 1,2,3
--     ) SELECT ndc11, ndc9, year_qtr
--         FROM ic_qtr_data4
--       MINUS
--       SELECT ndc11, ndc9, year_qtr
--         FROM ic_qtr_data5
     ),
  ic_nfamp_annual_qtrly
  AS (-- Extract NFAMP Annual and Quarterly from the IC GP Tables
      SELECT ndc11
            ,year_qtr
            ,SUM(CASE WHEN pricing_type = 3
                      THEN price
                 ELSE NULL
                 END) nfamp_qrtly
            ,SUM(CASE WHEN pricing_type = 4
                      THEN price
                 ELSE NULL
                 END) nfamp_annual
        FROM (SELECT ndc11
                    ,TO_CHAR(pb.effective_start_date,'YYYY""Q') year_qtr
                    ,pb.pricing_type
                    ,pb.price
                FROM bivvgp.gp_pbasis pb
                    ,bivvgp.product p
               WHERE 1=1
                 AND pb.product_id = p.product_id
                     -- ========================================
                     -- pb.pricing_type 3 = NFAMP - Quarterly
                     -- pb.pricing_type 4 = NFAMP - Annual 
                     -- ========================================
                 AND pb.pricing_type IN (3,4)
                 AND pb.status = 'PRODUCTION'
                 AND pb.obsolete_date = TO_DATE('12312099','mmddyyyy'))
      GROUP BY ndc11, year_qtr
--     ) SELECT COUNT(*) OVER () cnt, ic_nfamp_annual_qtrly.* 
--         FROM ic_nfamp_annual_qtrly
--       ORDER BY 1,2,3
     ),
  ic_qtr_data6
  AS (-- Add the NFAMP information
      SELECT z.ndc11
            ,z.ndc9
            ,z.year_qtr
            ,z.market_date_ndc9
            ,z.first_sale_date_ndc9
            ,z.first_sale_date_ndc11
            ,z.amp_qtrly
            ,z.bp_qtrly
            ,z.base_amp
            ,z.base_amp_qtr
            ,z.asp_qrtly
            ,z.amp_mth_1
            ,z.amp_mth_2
            ,z.amp_mth_3
            ,z.amp_mth_1_strt_dt
            ,z.amp_mth_1_end_dt
            ,z.amp_mth_2_strt_dt
            ,z.amp_mth_2_end_dt
            ,z.amp_mth_3_strt_dt
            ,z.amp_mth_3_end_dt
            ,z.fcp_annual
            ,x.nfamp_qrtly
            ,x.nfamp_annual
        FROM ic_qtr_data5 z
            ,ic_nfamp_annual_qtrly x
        WHERE z.ndc11 = x.ndc11 (+)
          AND z.year_qtr = x.year_qtr (+)
--     ) SELECT COUNT(*) OVER () cnt, ic_qtr_data6.* 
--         FROM ic_qtr_data6
--       ORDER BY 1,2,3
--     ) SELECT ndc11, ndc9, year_qtr
--         FROM ic_qtr_data5
--       MINUS
--       SELECT ndc11, ndc9, year_qtr
--         FROM ic_qtr_data6
     ),
  ic_gp_wac
  AS (-- Extract WAC and WAC Units from IC GP tables
      -- Please note, when WAC is valued, it is always equal to WAC Units.
      -- Therefore, WAC Units is all that is required.
      SELECT ndc11
            ,ndc9
            ,year_qtr
            ,SUM(CASE WHEN pricing_type = 7
                      THEN price
                 ELSE NULL
                 END) gp_wac
            ,MAX(CASE WHEN pricing_type = 7
                      THEN effective_start_date
                 ELSE NULL
                 END) gp_wac_start_date
            ,MAX(CASE WHEN pricing_type = 7
                      THEN effective_end_date
                 ELSE NULL
                 END) gp_wac_end_date
            ,SUM(CASE WHEN pricing_type = 67
                      THEN price
                 ELSE NULL
                 END) gp_wac_unit
            ,MAX(CASE WHEN pricing_type = 67
                      THEN effective_start_date
                 ELSE NULL
                 END) gp_wac_unit_start_date
            ,MAX(CASE WHEN pricing_type = 67
                      THEN effective_end_date
                 ELSE NULL
                 END) gp_wac_unit_end_date
        FROM (SELECT p.ndc11
                    ,SUBSTR(p.ndc11,1,5) || '-' || SUBSTR(p.ndc11,6,4) ndc9
                    ,pb.product_id
                    ,pt.description AS price_type
                    ,pb.pricing_type
                    ,pb.effective_start_date
                    ,pb.effective_end_date
                    ,TO_CHAR(pb.effective_start_date,'YYYY""Q') year_qtr
                    ,pb.production_date
                    ,pb.obsolete_date
                    ,pb.price
                    ,pb.reason
                    ,pb.status
                FROM bivvgp.mdm_prod_vw p
                    ,bivvgp.gp_pbasis pb
                    ,bivvgp.gp_pricing_type pt
               WHERE 1=1 
                 AND pb.product_id = p.product_id
                 AND pb.pricing_type = pt.pricing_type 
                 AND pb.status = 'PRODUCTION'
                     -- ========================================
                     -- pb.pricing_type 7 = WAC
                     -- pb.pricing_type 67 = WAC_UNIT
                     -- ========================================
                 AND pb.pricing_type IN (7,67)
                 AND pb.obsolete_date = TO_DATE('12312099','mmddyyyy'))
      GROUP BY ndc11, ndc9, year_qtr
--     ) SELECT COUNT(*) OVER () cnt, ic_gp_wac.* 
--         FROM ic_gp_wac
--       ORDER BY 1,2,3
     ),
  ic_rm_wac
  AS (-- Extract WAC and WAC Unit from IC RM tables
      -- Please note, when WAC is valued, it is always equal to WAC Units.
      -- Therefore, WAC Units is all that is required.
      SELECT ndc11
            ,ndc9
            ,year_qtr
            ,SUM(CASE WHEN pbasiscd_num = 5
                      THEN pbasis_unit
                 ELSE NULL
                 END) rm_wac
            ,SUM(CASE WHEN pbasiscd_num = 33
                      THEN pbasis_unit
                 ELSE NULL
                 END) rm_wac_unit
        FROM (SELECT p.prod_id_pri ndc11
                    ,SUBSTR(p.prod_id_pri,1,5) || '-' || SUBSTR(p.prod_id_pri,6,4) ndc9
                    ,TRUNC(g.pbasis_dt_effective)
                    ,TO_CHAR(g.pbasis_dt_effective,'YYYY""Q') year_qtr
                    ,g.pbasis_unit
                    ,g.pbasiscd_num
                FROM bivvcars.pbasis g
                    ,bivvcars.prod p
                    ,bivvcars.status s
               WHERE g.prod_num = p.prod_num
                 AND g.status_num = s.status_num
                     -- ========================================
                     -- g.pbasiscd_num 5 = WAC
                     -- g.pbasiscd_num 33 = WAC Unit
                     -- g.uom_num = 3 = Unit 
                     -- ========================================
                 AND g.pbasiscd_num IN (5,33)
                 AND p.pident_id_pri = 'NDC-11'
                 AND g.uom_num = 3
                 AND s.status_abbr = 'ACT')
      GROUP BY ndc11, ndc9, year_qtr
--     ) SELECT COUNT(*) OVER () cnt, ic_rm_wac.* 
--         FROM ic_rm_wac
--       ORDER BY 1,2,3
--     ) SELECT ndc9, year_qtr
--         FROM ic_rm_wac
--       MINUS
--       SELECT ndc9, year_qtr
--         FROM ic_gp_wac
     ),
  ic_wac
  AS (-- Merge the WAC and WAC Unit from IC RM tables and IC GP Tables
      -- Determine WAC Value and WAC Unit Value
      SELECT x.ndc11
            ,x.ndc9
            ,x.year_qtr
            ,x.rm_wac
            ,x.rm_wac_unit
            ,y.gp_wac
            ,y.gp_wac_unit
            ,COALESCE(x.rm_wac, y.gp_wac) wac
            ,COALESCE(x.rm_wac_unit, y.gp_wac_unit) wac_unit
            ,COALESCE(y.gp_wac_unit_start_date, y.gp_wac_start_date) wac_strt_dt
            ,COALESCE(y.gp_wac_unit_end_date, y.gp_wac_end_date) wac_end_dt
        FROM ic_rm_wac x
            ,ic_gp_wac y
       WHERE x.ndc9 = y.ndc9 (+)
         AND x.year_qtr = y.year_qtr (+)
--     ) SELECT COUNT(*) OVER () cnt, ic_wac.* 
--         FROM ic_wac
--       ORDER BY 1,2,3
--     ) SELECT ndc9, year_qtr
--         FROM ic_rm_wac
--         FROM ic_gp_wac
--       MINUS
--       SELECT ndc9, year_qtr
--         FROM ic_wac
     ),
  ic_qtr_data7
  AS (-- Add the WAC and WAC Unit
      SELECT z.ndc11
            ,z.ndc9
            ,z.year_qtr
            ,z.market_date_ndc9
            ,z.first_sale_date_ndc9
            ,z.first_sale_date_ndc11
            ,z.amp_qtrly
            ,z.bp_qtrly
            ,z.base_amp
            ,z.base_amp_qtr
            ,z.asp_qrtly
            ,z.amp_mth_1
            ,z.amp_mth_2
            ,z.amp_mth_3
            ,z.amp_mth_1_strt_dt
            ,z.amp_mth_1_end_dt
            ,z.amp_mth_2_strt_dt
            ,z.amp_mth_2_end_dt
            ,z.amp_mth_3_strt_dt
            ,z.amp_mth_3_end_dt
            ,z.fcp_annual
            ,z.nfamp_qrtly
            ,z.nfamp_annual
            ,COALESCE(x.wac_unit, x.wac) wac
            ,x.wac_strt_dt
            ,x.wac_end_dt
        FROM ic_qtr_data6 z
            ,ic_wac x
        WHERE z.ndc11 = x.ndc11 (+)
          AND z.year_qtr = x.year_qtr (+)
--     ) SELECT COUNT(*) OVER () cnt, ic_qtr_data7.* 
--         FROM ic_qtr_data7
--       ORDER BY 1,2,3
--     ) SELECT ndc11, ndc9, year_qtr
--         FROM ic_qtr_data6
--       MINUS
--       SELECT ndc11, ndc9, year_qtr
--         FROM ic_qtr_data7
--     ),
--  ic_gp_fss_annual
--  AS (-- Extract Annual FSS from the IC GP Tables
--      SELECT ndc11
--            ,TO_CHAR(pb.effective_start_date,'YYYY""Q') year_qtr
--            ,pb.effective_start_date fss_strt_dt
--            ,pb.effective_end_date fss_end_dt
--            ,pb.price fss_annual
--        FROM bivvgp.gp_pbasis pb
--            ,bivvgp.product p
--       WHERE 1=1
--         AND pb.product_id = p.product_id
--         AND pb.pricing_type = 31 -- FSS
--         AND pb.status = 'PRODUCTION'
--         AND pb.obsolete_date = TO_DATE('12312099','mmddyyyy')
--     ) SELECT COUNT(*) OVER () cnt, ic_gp_fss_annual.* 
--         FROM ic_gp_fss_annual
--       ORDER BY 1,2,3
     ),
  ic_rm_awp
  AS (-- Extract quarterly amp/bp data from IC RM tables
      -- !!!! Please note, as of 08.21.2020, there is no AWP in the RM Tables
      SELECT p.prod_id_pri ndc11
            ,SUBSTR(p.prod_id_pri,1,5) || '-' || SUBSTR(p.prod_id_pri,6,4) ndc9
            ,TRUNC(g.pbasis_dt_effective)
            ,TO_CHAR(g.pbasis_dt_effective,'YYYY""Q') year_qtr
            ,g.pbasis_unit rm_awp_annual
        FROM bivvcars.pbasis g
            ,bivvcars.prod p
            ,bivvcars.status s
       WHERE g.prod_num = p.prod_num
         AND g.status_num = s.status_num
             -- ========================================
             -- g.pbasiscd_num 31 = AWP
             -- ========================================
         AND g.pbasiscd_num = 31
         AND p.pident_id_pri = 'NDC-11'
         AND s.status_abbr = 'ACT'
--     ) SELECT COUNT(*) OVER () cnt, ic_rm_awp.* 
--         FROM ic_rm_awp
--       ORDER BY 1,2,3
     ),
  ic_qtr_data8
  AS (-- Add the Annual AWP
      SELECT z.ndc11
            ,z.ndc9
            ,z.year_qtr
            ,z.market_date_ndc9
            ,z.first_sale_date_ndc9
            ,z.first_sale_date_ndc11
            ,z.amp_qtrly
            ,z.bp_qtrly
            ,z.base_amp
            ,z.base_amp_qtr
            ,z.asp_qrtly
            ,z.amp_mth_1
            ,z.amp_mth_2
            ,z.amp_mth_3
            ,z.amp_mth_1_strt_dt
            ,z.amp_mth_1_end_dt
            ,z.amp_mth_2_strt_dt
            ,z.amp_mth_2_end_dt
            ,z.amp_mth_3_strt_dt
            ,z.amp_mth_3_end_dt
            ,z.fcp_annual
            ,z.nfamp_qrtly
            ,z.nfamp_annual
            ,z.wac
            ,z.wac_strt_dt
            ,z.wac_end_dt
            ,x.rm_awp_annual
        FROM ic_qtr_data7 z
            ,ic_rm_awp x
        WHERE z.ndc11 = x.ndc11 (+)
          AND z.year_qtr = x.year_qtr (+)
--     ) SELECT COUNT(*) OVER () cnt, ic_qtr_data8.* 
--         FROM ic_qtr_data8
--       ORDER BY 1,2,3
--     ) SELECT ndc11, ndc9, year_qtr
--         FROM ic_qtr_data7
--       MINUS
--       SELECT ndc11, ndc9, year_qtr
--         FROM ic_qtr_data8
     ),
  ura_qtr_hdr_max
  AS (-- Extract max quarterly header number
      -- Quarter with Active Headers....
      SELECT TO_CHAR(cqh.calcqtrhdr_dt_start,'YYYY""Q') year_qtr
            ,cq.prod_num
            ,MAX(cqh.calcqtrhdr_num) max_calcqtrhdr_num
        FROM bivvcars.calcqtr cq
            ,bivvcars.status s
            ,bivvcars.calcqtrhdr cqh
            ,bivvcars.status s2
            ,bivvcars.formula f
       WHERE 1=1
         AND cqh.calcqtrhdr_num = cq.calcqtrhdr_num
         AND cq.formula_num = f.formula_num 
         AND cq.status_num = s.status_num
         AND cqh.status_num = s2.status_num
         AND s.status_abbr = 'ACT'
         AND s2.status_abbr = 'ACT'
         AND cq.formula_num = 4085 -- Medicaid
      GROUP BY TO_CHAR(cqh.calcqtrhdr_dt_start,'YYYY""Q')
              ,cq.prod_num
      -- ==============
      UNION ALL
      -- ==============
      -- Quarter with In-Process and no Active      
      SELECT TO_CHAR(cqh.calcqtrhdr_dt_start,'YYYY""Q') year_qtr
            ,cq.prod_num
            ,MAX(cqh.calcqtrhdr_num) max_calcqtrhdr_num
        FROM bivvcars.calcqtr cq
            ,bivvcars.status s
            ,bivvcars.calcqtrhdr cqh
            ,bivvcars.status s2
            ,bivvcars.formula f
       WHERE 1=1
         AND cqh.calcqtrhdr_num = cq.calcqtrhdr_num
         AND cq.formula_num = f.formula_num 
         AND cq.status_num = s.status_num
         AND cqh.status_num = s2.status_num
         AND s.status_abbr = 'ACT'
         AND s2.status_abbr = 'IP'
         AND cq.formula_num = 4085 -- Medicaid
         AND NOT EXISTS (SELECT 'x'
                           FROM (SELECT DISTINCT TO_CHAR(cqh1.calcqtrhdr_dt_start,'YYYY""Q') year_qtr
                                                ,cq1.prod_num
                                   FROM bivvcars.calcqtr cq1
                                       ,bivvcars.status s1
                                       ,bivvcars.calcqtrhdr cqh1
                                       ,bivvcars.status s12
                                       ,bivvcars.formula f1
                                  WHERE 1=1
                                    AND cqh1.calcqtrhdr_num = cq1.calcqtrhdr_num
                                    AND cq1.formula_num = f1.formula_num 
                                    AND cq1.status_num = s1.status_num
                                    AND cqh1.status_num = s12.status_num
                                    AND s1.status_abbr = 'ACT'
                                    AND s12.status_abbr = 'ACT'
                                    AND cq1.formula_num = 4085 -- Medicaid
                                 ) xx
                          WHERE xx.year_qtr = TO_CHAR(cqh.calcqtrhdr_dt_start,'YYYY""Q')
                            AND xx.prod_num = cq.prod_num)
      GROUP BY TO_CHAR(cqh.calcqtrhdr_dt_start,'YYYY""Q')
              ,cq.prod_num
--     ) SELECT COUNT(*) OVER () cnt, ura_qtr_hdr_max.* 
--         FROM ura_qtr_hdr_max
--       ORDER BY 1,2,3
     ),
  ura_max_calcqtr_num
  AS (-- For each quarter and each MAX header, identify the max calcqtr_num
      SELECT u.year_qtr
            ,u.prod_num
            ,u.max_calcqtrhdr_num
            ,MAX(cq.calcqtr_num) max_calcqtr_num
        FROM ura_qtr_hdr_max u
            ,bivvcars.calcqtr cq
            ,bivvcars.status s
            ,bivvcars.formula f
       WHERE 1=1
         AND u.max_calcqtrhdr_num = cq.calcqtrhdr_num
         AND u.prod_num = cq.prod_num
         AND cq.formula_num = f.formula_num 
         AND cq.status_num = s.status_num
         AND s.status_abbr = 'ACT'
         AND cq.formula_num = 4085 -- Medicaid
      GROUP BY u.year_qtr
              ,u.prod_num
              ,u.max_calcqtrhdr_num
--     ) SELECT COUNT(*) OVER () cnt, ura_max_calcqtr_num.* 
--         FROM ura_max_calcqtr_num
--       ORDER BY 1,2,3
     ),
  ura_per_qtr
  AS (-- For each quarter and product, extract the URA
      SELECT u.year_qtr
            ,u.max_calcqtrhdr_num
            ,u.max_calcqtr_num
            ,p.prod_id_pri ndc11
            ,p9.prod_id_pri_disp ndc9
            ,cq.rpu
            ,cqh.calcqtrhdr_dt_start
            ,cqh.calcqtrhdr_dt_end
            ,f.formula_name, f.formula_desc, f.formula_num
            ,cq.calcqtr_num_prior
        FROM ura_max_calcqtr_num u
            ,bivvcars.calcqtr cq
            ,bivvcars.prod p
            ,bivvcars.calcqtrhdr cqh
            ,bivvcars.formula f
            ,(SELECT pr.prod_num, pr.prod_num_parent
                FROM bivvcars.prodrel pr
                    ,bivvcars.status s
               WHERE pr.status_num = s.status_num
                 AND s.status_abbr = 'ACT') x
            ,bivvcars.prod p9
       WHERE 1=1
         AND u.max_calcqtrhdr_num = cqh.calcqtrhdr_num
         AND u.max_calcqtrhdr_num = cq.calcqtrhdr_num
         AND u.max_calcqtr_num = cq.calcqtr_num
         AND u.prod_num = cq.prod_num
         AND cqh.calcqtrhdr_num = cq.calcqtrhdr_num
         AND cq.prod_num = p.prod_num
         AND cq.formula_num = f.formula_num (+)
         AND p.prod_num = x.prod_num
         AND x.prod_num_parent = p9.prod_num
         AND cq.formula_num = 4085  -- Medicaid
         AND p.pident_id_pri = 'NDC-11'
--     ) SELECT COUNT(*) OVER () cnt, ura_per_qtr.* 
--         FROM ura_per_qtr
--       ORDER BY 1,2,3
     ),
  ic_qtr_data_final
  AS (-- Merge IC quarterly data with IC Quarterly URA
      SELECT x.ndc11
            ,x.ndc9
            ,x.year_qtr
            ,x.market_date_ndc9
            ,x.first_sale_date_ndc9
            ,x.first_sale_date_ndc11
            ,x.amp_qtrly
            ,x.bp_qtrly
            ,x.base_amp
            ,x.base_amp_qtr
            ,x.asp_qrtly
            ,x.amp_mth_1
            ,x.amp_mth_2
            ,x.amp_mth_3
            ,x.amp_mth_1_strt_dt
            ,x.amp_mth_1_end_dt
            ,x.amp_mth_2_strt_dt
            ,x.amp_mth_2_end_dt
            ,x.amp_mth_3_strt_dt
            ,x.amp_mth_3_end_dt
            ,x.fcp_annual
            ,x.nfamp_qrtly
            ,x.nfamp_annual
            ,x.wac
            ,x.wac_strt_dt
            ,x.wac_end_dt
            ,x.rm_awp_annual
            ,y.rpu ura
        FROM ic_qtr_data8 x
            ,ura_per_qtr y
       WHERE x.ndc9 = y.ndc9 (+)
         AND x.year_qtr = y.year_qtr (+)
--     ) SELECT COUNT(*) OVER () cnt, ic_qtr_data_final.* 
--         FROM ic_qtr_data_final
--       ORDER BY 1,2,3
--     ) SELECT year_qtr, ndc9
--         FROM ddr_qtr_data
--       MINUS
--       SELECT year_qtr, ndc9
--         FROM ddr_qtr_data3
     ),
  ic_ddr_data
  AS (-- Merge IC quarterly data with the DDR Quarterly Data
      SELECT x.ndc11
            ,x.ndc9
            ,x.year_qtr
            ,x.market_date_ndc9
            ,x.first_sale_date_ndc9
            ,x.first_sale_date_ndc11
            ,x.amp_qtrly
            ,x.bp_qtrly
            ,x.base_amp
            ,x.base_amp_qtr
            ,x.asp_qrtly
            ,x.amp_mth_1
            ,x.amp_mth_2
            ,x.amp_mth_3
            ,x.amp_mth_1_strt_dt
            ,x.amp_mth_1_end_dt
            ,x.amp_mth_2_strt_dt
            ,x.amp_mth_2_end_dt
            ,x.amp_mth_3_strt_dt
            ,x.amp_mth_3_end_dt
            ,x.fcp_annual
            ,x.nfamp_qrtly
            ,x.nfamp_annual
            ,x.wac
            ,x.wac_strt_dt
            ,x.wac_end_dt
            ,x.rm_awp_annual
            ,x.ura
            ,y.amp ddr_amp
            ,y.best_price ddr_bp
            ,y.base_amp_used_for_ura
            ,y.ura ddr_ura
            ,CASE WHEN SUBSTR(x.ndc9,1,5) = '71104'
                  THEN y.ddr_parent_amp
             ELSE NULL
             END ddr_parent_amp
            ,CASE WHEN SUBSTR(x.ndc9,1,5) = '71104'
                  THEN y.ddr_parent_bp
             ELSE NULL
             END ddr_parent_bp
        FROM ic_qtr_data_final x
            ,ddr_qtr_data3 y
       WHERE x.ndc9 = y.ndc9 (+)
         AND x.year_qtr = y.year_qtr (+)
--     ) SELECT COUNT(*) OVER () cnt, ic_ddr_data.* 
--         FROM ic_ddr_data
--       ORDER BY 1,2,3
--     ) SELECT year_qtr, ndc9
--         FROM ddr_qtr_data
--       MINUS
--       SELECT year_qtr, ndc9
--         FROM ddr_qtr_data3
     )
      SELECT x.ndc11
            ,x.ndc9
            ,x.year_qtr
            ,x.market_date_ndc9
            ,x.first_sale_date_ndc9
            ,x.first_sale_date_ndc11
            ,x.amp_qtrly
            ,x.bp_qtrly
            ,x.base_amp
            ,x.base_amp_qtr
            ,x.asp_qrtly
            ,x.amp_mth_1
            ,x.amp_mth_2
            ,x.amp_mth_3
            ,x.amp_mth_1_strt_dt
            ,x.amp_mth_1_end_dt
            ,x.amp_mth_2_strt_dt
            ,x.amp_mth_2_end_dt
            ,x.amp_mth_3_strt_dt
            ,x.amp_mth_3_end_dt
            ,x.fcp_annual
            ,x.nfamp_qrtly
            ,x.nfamp_annual
            ,x.wac
            ,x.wac_strt_dt
            ,x.wac_end_dt
            ,x.rm_awp_annual
            ,x.ura
            ,x.ddr_amp
            ,x.ddr_bp
            ,x.base_amp_used_for_ura
            ,x.ddr_ura
            ,x.ddr_parent_amp
            ,x.ddr_parent_bp
        FROM ic_ddr_data x
;