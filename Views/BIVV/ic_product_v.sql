CREATE OR REPLACE VIEW BIVV.IC_PRODUCT_V AS
/****************************************************************************
 * View Name    : bivv.ic_product_v
 * Date Created : 08.18.2020
 * Author       : JTronoski (IntegriChain)
 * Description  : Bioverativ (FLEX IC) Product Master data
 *
 * MOD HISTORY
 *  Date        Modified by   Reason
 *  ----------  ------------  ------------------------------------------------
 *  10.27.2020  JTronoski     Added hard-coded purchase product dates
 *  10.28.2020  JTronoski     Change sap_prod_cd from 'US12' to NULL
 *  01.18.2021  JTronoski     For Biogen products, value change SAP Company Code from 'US12' to NULL
****************************************************************************/
WITH prod_ndc11
  AS (-- Extract product information from the NDC-11 level
      SELECT p.prod_num ndc11_prod_num
            ,p.prod_id_pri ndc11
            ,p.prod_desc ndc11_prod_desc
            ,p.prod_dt_intro ndc11_prod_dt_intro
            ,p.prod_dt_expire ndc11_prod_dt_expire
            ,p.prod_dt_cms_market ndc11_prod_dt_cms_market
            ,p.prod_dt_cms_expire ndc11_prod_dt_cms_expire
            ,p.prod_dt_first_sale ndc11_prod_dt_first_sale
            ,p.prod_dt_cms_lastmod ndc11_prod_dt_cms_lastmod
            ,p.prod_dt_asp_lastmod ndc11_prod_dt_asp_lastmod
            ,x.prod_num_parent ndc11_prod_num_parent
        FROM bivvcars.prod p
            ,(SELECT pr.prod_num, pr.prod_num_parent
                FROM bivvcars.prodrel pr
                    ,bivvcars.status s
               WHERE pr.status_num = s.status_num
                 AND s.status_abbr = 'ACT') x
       WHERE p.prod_num = x.prod_num
         AND p.pident_id_pri = 'NDC-11'
--     ) SELECT COUNT(*) OVER () cnt, prod_ndc11.* 
--         FROM prod_ndc11
--       ORDER BY 1,2
     ),
  prod_ndc9
  AS (-- Extract product information from the NDC-9 level
      SELECT p11.ndc11_prod_num
            ,p11.ndc11
            ,p11.ndc11_prod_desc
            ,p11.ndc11_prod_dt_intro
            ,p11.ndc11_prod_dt_expire
            ,p11.ndc11_prod_dt_cms_market
            ,p11.ndc11_prod_dt_cms_expire
            ,p11.ndc11_prod_dt_first_sale
            ,p11.ndc11_prod_dt_cms_lastmod
            ,p11.ndc11_prod_dt_asp_lastmod
            ,p11.ndc11_prod_num_parent
            ,p.prod_num ndc9_prod_num
            ,p.prod_id_pri ndc9
            ,p.prod_desc ndc9_prod_desc
            ,p.prod_dt_intro ndc9_prod_dt_intro
            ,p.prod_dt_expire ndc9_prod_dt_expire
            ,p.prod_dt_cms_market ndc9_prod_dt_cms_market
            ,p.prod_dt_cms_expire ndc9_prod_dt_cms_expire
            ,p.prod_dt_first_sale ndc9_prod_dt_first_sale
            ,p.prod_dt_cms_lastmod ndc9_prod_dt_cms_lastmod
            ,p.prod_dt_asp_lastmod ndc9_prod_dt_asp_lastmod
            ,x.prod_num_parent ndc9_prod_num_parent
        FROM prod_ndc11 p11
            ,bivvcars.prod p
            ,(SELECT pr.prod_num, pr.prod_num_parent
                FROM bivvcars.prodrel pr
                    ,bivvcars.status s
               WHERE pr.status_num = s.status_num
                 AND s.status_abbr = 'ACT') x
       WHERE p11.ndc11_prod_num_parent = p.prod_num
         AND p.prod_num = x.prod_num
         AND p.pident_id_pri = 'NDC-9'
--     ) SELECT COUNT(*) OVER () cnt, prod_ndc9.* 
--         FROM prod_ndc9
--       ORDER BY ndc9_prod_desc, ndc9, ndc11
     ),
  prod_brand
  AS (-- Extract product information from the Brand level
      SELECT p9.ndc11_prod_num
            ,p9.ndc11
            ,p9.ndc11_prod_desc
            ,p9.ndc11_prod_dt_intro
            ,p9.ndc11_prod_dt_expire
            ,p9.ndc11_prod_dt_cms_market
            ,p9.ndc11_prod_dt_cms_expire
            ,p9.ndc11_prod_dt_first_sale
            ,p9.ndc11_prod_dt_cms_lastmod
            ,p9.ndc11_prod_dt_asp_lastmod
            ,p9.ndc11_prod_num_parent
            ,p9.ndc9_prod_num
            ,p9.ndc9
            ,p9.ndc9_prod_desc
            ,p9.ndc9_prod_dt_intro
            ,p9.ndc9_prod_dt_expire
            ,p9.ndc9_prod_dt_cms_market
            ,p9.ndc9_prod_dt_cms_expire
            ,p9.ndc9_prod_dt_first_sale
            ,p9.ndc9_prod_dt_cms_lastmod
            ,p9.ndc9_prod_dt_asp_lastmod
            ,p9.ndc9_prod_num_parent
            ,p.prod_num brand_prod_num
            ,p.prod_desc brand_prod_desc
            ,p.prod_dt_cms_lastmod brand_prod_dt_cms_lastmod
            ,p.prod_dt_asp_lastmod brand_prod_dt_asp_lastmod
            ,x.prod_num_parent brand_prod_num_parent
        FROM prod_ndc9 p9
            ,bivvcars.prod p
            ,(SELECT pr.prod_num, pr.prod_num_parent
                FROM bivvcars.prodrel pr
                    ,bivvcars.status s
               WHERE pr.status_num = s.status_num
                 AND s.status_abbr = 'ACT') x
       WHERE p9.ndc9_prod_num_parent = p.prod_num
         AND p.prod_num = x.prod_num
--     ) SELECT COUNT(*) OVER () cnt, prod_brand.* 
--         FROM prod_brand
--       ORDER BY ndc9_prod_desc, ndc9, ndc11
     ),
  prod_generic
  AS (-- Extract product information from the Brand level
      SELECT pb.ndc11_prod_num
            ,pb.ndc11
            ,pb.ndc11_prod_desc
            ,pb.ndc11_prod_dt_intro
            ,pb.ndc11_prod_dt_expire
            ,pb.ndc11_prod_dt_cms_market
            ,pb.ndc11_prod_dt_cms_expire
            ,pb.ndc11_prod_dt_first_sale
            ,pb.ndc11_prod_dt_cms_lastmod
            ,pb.ndc11_prod_dt_asp_lastmod
            --,pb.ndc11_prod_num_parent
            ,pb.ndc9_prod_num
            ,pb.ndc9
            ,pb.ndc9_prod_desc
            ,pb.ndc9_prod_dt_intro
            ,pb.ndc9_prod_dt_expire
            ,pb.ndc9_prod_dt_cms_market
            ,pb.ndc9_prod_dt_cms_expire
            ,pb.ndc9_prod_dt_first_sale
            ,pb.ndc9_prod_dt_cms_lastmod
            ,pb.ndc9_prod_dt_asp_lastmod
            --,pb.ndc9_prod_num_parent
            ,pb.brand_prod_num
            ,pb.brand_prod_desc
            ,pb.brand_prod_dt_cms_lastmod
            ,pb.brand_prod_dt_asp_lastmod
            --,pb.brand_prod_num_parent
            ,p.prod_num generic_prod_num
            ,p.prod_desc generic_prod_desc
            ,p.prod_dt_cms_lastmod generic_prod_dt_cms_lastmod
            ,p.prod_dt_asp_lastmod generic_prod_dt_asp_lastmod
        FROM prod_brand pb
            ,bivvcars.prod p
       WHERE pb.brand_prod_num_parent = p.prod_num
--     ) SELECT COUNT(*) OVER () cnt, prod_generic.* 
--         FROM prod_generic
--       ORDER BY ndc9_prod_desc, ndc9, ndc11
     ),
  prod_char
  AS (-- Extract product characteristics
      SELECT prod_num
            ,prodchar_dt_start
            ,prodchar_dt_end
             -- prod_fmly_t.nonrtl_drug_ind and prod_fmly_ppaca_t.ppaca_rtl_ind
            --,MAX(CASE WHEN charset_id = '5I_IND'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) ind_5i
             -- prod_fmly_t.nonrtl_route_of_amdin
            --,MAX(CASE WHEN charset_id = '5I_RTE'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) rte_5i
             -- 5i Threshold is calculated
            --,MAX(CASE WHEN charset_id = '5I_THR'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) thr_5i
             -- prod_fmly_t.fda_desi_cd
            --,MAX(CASE WHEN charset_id = 'DESI'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) desi
             -- hcrs.prod_fmly_drug_catg_t
            ,MAX(CASE WHEN charset_id = 'DRUGCAT'
                      THEN charitm_desc
                 ELSE NULL
                 END) drugcat
             -- prod_fmly_t.drug_typ_cd
            --,MAX(CASE WHEN charset_id = 'DRUGTYPE'
            --          THEN CASE WHEN charitm_desc = 'RX'
            --                    THEN 1
            --               ELSE 2
            --               END
            --     ELSE NULL
            --     END) drugtype
             -- prod_mstr_t.fda_approval_dt
            --,MAX(CASE WHEN charset_id = 'FDA_PMAD'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) fda_apprvl_dt
             -- prod_fmly_t.fda_application_num
            --,MAX(CASE WHEN charset_id = 'FDAAN'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) fda_appl_num
             -- prod_fmly_t.fda_thera_cd
            --,MAX(CASE WHEN charset_id = 'FDAEQUIV'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) fda_thera_cd
             -- prod_fmly_t.cod_stat
            --,MAX(CASE WHEN charset_id = 'MEDICOD'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) cod_stat
             -- fda_approval_typ (hcrs.prod_fmly_cod_stat_t.cod_stat_desc)
            --,MAX(CASE WHEN charset_id = 'MKTCAT'
            --          THEN SUBSTR(charitm_desc,1,3)
            --     ELSE NULL
            --     END) fda_approval_typ
             -- This can be used for the EL/IN indicators
            --,MAX(CASE WHEN charset_id = 'PARTD'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) partd
             -- Product Strength
            --,MAX(CASE WHEN charset_id = 'PRODSTR'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) prod_str
             -- prod_mstr_t.va_drug_catg_cd
            --,MAX(CASE WHEN charset_id = 'SIN'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) va_drug_catg_cd
             -- prod_mstr_t.fda_reg_nm
            --,MAX(CASE WHEN charset_id = 'TRADE'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) fda_reg_nm
             -- prod_fmly_t.hcfa_unit_typ_cd
            --,MAX(CASE WHEN charset_id = 'UNITTYPE'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) hcfa_unit_typ_cd
             -- prod_mstr_t.volume_per_item
            --,MAX(CASE WHEN charset_id = 'VOLPERITM'
            --          THEN charitm_desc
            --     ELSE NULL
            --     END) vol_per_item
        FROM (SELECT pc.prod_num
                    ,pc.prodchar_dt_start
                    ,pc.prodchar_dt_end
                    ,ci.charitm_num
                    ,ci.charset_id
                    ,cs.charset_desc 
                    ,ci.charitm_desc
                FROM bivvcars.prodchar pc
                    ,bivvcars.status s1
                    ,bivvcars.charitm ci
                    ,bivvcars.charset cs
                    ,bivvcars.prod p
               WHERE p.prod_num = pc.prod_num
                 AND pc.status_num = s1.status_num
                 AND pc.charitm_num = ci.charitm_num
                 AND ci.charset_id = cs.charset_id
                 AND s1.status_abbr = 'ACT'
                 AND p.pident_id_pri = 'NDC-11')
      GROUP BY prod_num
              ,prodchar_dt_start
              ,prodchar_dt_end
--     ) SELECT COUNT(*) OVER () cnt, prod_char.* 
--         FROM prod_char
--       ORDER BY 1,2,3,4
--
     ),
  gp_prod
  AS (-- Extract GP product information
      SELECT product_id -- prod_num
            ,rec$_effective_start_date
            ,rec$_effective_end_date
             -- prod_fmly_t.nonrtl_drug_ind and prod_fmly_ppaca_t.ppaca_rtl_ind
            ,indicator_5i ind_5i
             -- prod_fmly_t.nonrtl_route_of_amdin
            ,route_5i rte_5i
             -- 5i Threshold is calculated
            --,threshold_5i thr_5i
             -- prod_fmly_t.fda_desi_cd
            ,desi_code desi
             -- hcrs.prod_fmly_drug_catg_t
            ,drug_category drugcat
             -- prod_fmly_t.drug_typ_cd
            ,drug_type drugtype
             -- prod_mstr_t.fda_approval_dt
            ,fda_approval_date fda_apprvl
             -- prod_fmly_t.fda_application_num
            ,fda_application_number fda_appl_num
             -- prod_fmly_t.fda_thera_cd
            ,fda_thera_eq_code fda_thera_cd
             -- prod_fmly_t.cod_stat
            ,medicaid_cod cod_stat
             -- Product Strength
            ,product_strength prod_str
             -- prod_mstr_t.va_drug_catg_cd
            ,sin va_drug_catg_cd
             -- prod_fmly_t.hcfa_unit_typ_cd
            ,unit_type hcfa_unit_typ_cd
             -- prod_mstr_t.volume_per_item
            ,volume_per_item vol_per_item
            ,brand_name gp_brand_name
            ,description gp_description
            ,secondary_description gp_secondary_description
            ,product_type gp_product_type
            ,units_of_measure gp_units_of_measure
            ,units_per_package_size gp_units_per_package_size
            ,units_per_pack gp_units_per_pack           
            ,package_size gp_package_size
            ,market_date_ndc9 gp_market_date_ndc9
            ,market_date_ndc11 gp_market_date_ndc11
            ,first_sale_date_ndc9 gp_first_sale_date_ndc9
            ,first_sale_date_ndc11 gp_first_sale_date_ndc11
            ,last_sale_date_ndc11 gp_last_sale_date_ndc11
            ,last_lot_expiration_date_ndc9 gp_last_lot_expirat_date_ndc9
            ,last_lot_expiration_date_ndc11 gp_last_lot_expirat_date_ndc11
            ,description_ndc9 gp_description_ndc9
            ,trade_name gp_trade_name
            ,cms_stop_report_date gp_cms_stop_report_date
            ,cms_market_date gp_cms_market_date
            ,cms_expiration_date gp_cms_expiration_date
            ,line_extension_drug_indicator gp_line_extension_drug_ind
        FROM bivvgp.product
--     ) SELECT COUNT(*) OVER () cnt, gp_prod.* 
--         FROM gp_prod
--       ORDER BY 1,2,3,4
     ),
  min_inv_date
  AS (-- Extract the earlies invoice date from the direct sales table for each product
      SELECT product
            ,((SELECT MAX(ndc_id) FROM hcrs.prod_mstr_t) + rownum) ndc_id
            ,min_inv_dt
        FROM (SELECT product
                    ,MIN(btds.invoice_date) min_inv_dt
                FROM bivvgp.bio_target_direct_sales btds
               WHERE btds.tran_type NOT IN ('FG','PPE')
                 AND btds.cust_number_soldto_source_id NOT IN ('92000000000','92999999000')
                 AND btds.rec$_current_row = 'Y'
              GROUP BY product
             )
--     ) SELECT COUNT(*) OVER () cnt, min_inv_date.* 
--         FROM min_inv_date
--       ORDER BY 1,2
--
    ),
  prod_all
  AS (-- Link all of the product information
      SELECT pg.ndc11_prod_num
            ,pg.ndc11
             -- The next two columns are the same
            ,pg.ndc11_prod_desc
            --,gp.gp_description
             --
             -- The next four columns are the same
            ,pg.ndc11_prod_dt_intro
            --,gp.gp_market_date_ndc11
            --,pg.ndc9_prod_dt_intro
            --,gp.gp_market_date_ndc9
             --
             -- The next two columns are the same
            ,pg.ndc11_prod_dt_cms_market
            --,gp.gp_cms_market_date
             --
            ,pg.ndc9_prod_dt_cms_market
             -- The next two columns are the same
            ,pg.ndc11_prod_dt_first_sale
            --,gp.gp_first_sale_date_ndc11
             --
            ,pg.ndc11_prod_dt_expire
            ,pg.ndc9_prod_dt_expire
             -- The next two columns are the same
            ,pg.ndc11_prod_dt_cms_expire
            --,gp.gp_cms_expiration_date
             --
            ,pg.ndc9_prod_dt_cms_expire
            ,pg.ndc11_prod_dt_cms_lastmod
            ,pg.ndc11_prod_dt_asp_lastmod
            ,pg.ndc9_prod_num
            ,pg.ndc9
             -- The next two columns are the same
            ,pg.ndc9_prod_desc
            --,gp.gp_description_ndc9
             --
            ,gp.gp_last_sale_date_ndc11
            ,gp.gp_last_lot_expirat_date_ndc9
            ,gp.gp_last_lot_expirat_date_ndc11
            ,gp.gp_cms_stop_report_date
             -- The next two columns are the same
            ,pg.ndc9_prod_dt_first_sale
            --,gp.gp_first_sale_date_ndc9
             --
            ,pg.ndc9_prod_dt_cms_lastmod
            ,pg.ndc9_prod_dt_asp_lastmod
            ,pg.brand_prod_num
             -- The next two columns are the same
            ,pg.brand_prod_desc
            --,gp.gp_brand_name
             --
            ,pg.brand_prod_dt_cms_lastmod
            ,pg.brand_prod_dt_asp_lastmod
            ,pg.generic_prod_num
            ,pg.generic_prod_desc
            ,pg.generic_prod_dt_cms_lastmod
            ,pg.generic_prod_dt_asp_lastmod
             -- prod_fmly_t.nonrtl_drug_ind and prod_fmly_ppaca_t.ppaca_rtl_ind
            ,gp.ind_5i
             -- prod_fmly_t.nonrtl_route_of_amdin
            ,gp.rte_5i
             -- prod_fmly_t.fda_desi_cd
            ,gp.desi
             -- hcrs.prod_fmly_drug_catg_t
            --,gp.drugcat
            ,pc.drugcat
            ,pc.prodchar_dt_start
            ,pc.prodchar_dt_end
             -- prod_fmly_t.drug_typ_cd
            ,gp.drugtype
             -- prod_mstr_t.fda_approval_dt
            ,CASE WHEN gp.fda_apprvl IS NULL
                  THEN CASE WHEN fda_appl_num = '125444'
                            THEN TO_DATE('20171103','yyyymmdd')
                       ELSE TO_DATE('20160108','yyyymmdd')
                       END
             ELSE gp.fda_apprvl
             END fda_apprvl
             -- prod_fmly_t.fda_application_num
            ,gp.fda_appl_num
             -- prod_fmly_t.fda_thera_cd
            ,gp.fda_thera_cd
             -- prod_fmly_t.cod_stat
            ,gp.cod_stat
             -- Product Strength
            ,gp.prod_str
             -- prod_mstr_t.va_drug_catg_cd
            ,gp.va_drug_catg_cd
             -- prod_fmly_t.hcfa_unit_typ_cd
            ,gp.hcfa_unit_typ_cd
             -- prod_mstr_t.volume_per_item
            ,gp.vol_per_item
            ,gp.gp_secondary_description
            ,gp.gp_product_type
            ,gp.gp_units_of_measure
            ,gp.gp_units_per_package_size
            ,gp.gp_units_per_pack           
            ,gp.gp_package_size
            ,gp.gp_trade_name
            ,NVL(gp.gp_line_extension_drug_ind,'N') gp_line_extension_drug_ind
            ,m.min_inv_dt
            ,m.ndc_id
        FROM prod_generic pg
            ,gp_prod gp
            ,prod_char pc
            ,min_inv_date m
       WHERE pg.ndc11_prod_num = gp.product_id
         AND pg.ndc11_prod_num = pc.prod_num
         AND pg.ndc11 = m.product
--     ) SELECT COUNT(*) OVER () cnt, prod_all.* 
--         FROM prod_all
--       ORDER BY ndc9_prod_desc, ndc9, ndc11
--
     ) SELECT CAST (ndc11 AS VARCHAR (11)) ndc
             ,CAST (ndc9 AS VARCHAR (9)) ndc9
             ,CAST (NULL AS VARCHAR (20)) src_sys_cd
             ,CAST (NULL AS VARCHAR (20)) bu_cde
              -------------------------------------------------------------------------
              -- prod_fmly_t fields
             ,CAST (ndc9_prod_desc AS VARCHAR (100)) prod_fmly_nm
             ,CAST (desi AS VARCHAR (1)) fda_desi_cd
             ,CAST (drugtype AS VARCHAR (1)) drug_typ_cd
             ,CAST (fda_thera_cd AS VARCHAR (2)) fda_thera_cd
             ,CAST (hcfa_unit_typ_cd AS VARCHAR (3)) hcfa_unit_typ_cd
             ,CAST ('N' AS VARCHAR (1)) potency_flg
             ,CAST ('VIAL' AS VARCHAR (10)) form
             ,CAST (prod_str AS VARCHAR (10)) strength

             ,CAST (CASE WHEN SUBSTR(ndc9,1,5) = '71104'
                          AND SUBSTR(ndc9,6,4) IN ('0801','0806','0808')
                         THEN TO_DATE('07302018','mmddyyyy')
                         WHEN SUBSTR(ndc9,1,5) = '71104'
                          AND SUBSTR(ndc9,6,4) IN ('0802','0807')
                         THEN TO_DATE('06252018','mmddyyyy')
                         WHEN SUBSTR(ndc9,1,5) = '71104'
                          AND SUBSTR(ndc9,6,4) IN ('0803','0805','0809')
                         THEN TO_DATE('06142018','mmddyyyy')
                         WHEN SUBSTR(ndc9,1,5) = '71104'
                          AND SUBSTR(ndc9,6,4) IN ('0804','0810','0911','0922','0933','0944','0966','0977')
                         THEN TO_DATE('07312018','mmddyyyy')
                    ELSE NULL
                    END AS DATE) purchase_prod_dt

             ,CAST (NVL(ind_5i,'Y') AS VARCHAR (1)) nonrtl_drug_ind
             ,CAST (rte_5i AS VARCHAR (3)) nonrtl_route_of_admin
             ,CAST (fda_appl_num AS VARCHAR2(7)) fda_application_num
             ,CAST (cod_stat AS VARCHAR (2)) cod_stat
             ,CAST (gp_line_extension_drug_ind AS VARCHAR (1)) line_extension_ind
             ,CAST (ndc9_prod_dt_cms_market AS DATE) mkt_entry_dt
             ,CAST (NULL AS VARCHAR2(7)) otc_mono_num
             ,CAST (ndc_id AS NUMBER(9,0)) ndc_id
              -------------------------------------------------------------------------
              -- prod_fmly_drug_catg_t
             ,CAST (drugcat AS VARCHAR (1)) drug_catg_cd
             ,CAST (drugcat AS VARCHAR (1)) medicare_drug_catg_cd
             ,CAST (prodchar_dt_start AS DATE) drug_catg_eff_dt
             ,CAST (NVL(prodchar_dt_end,TO_DATE('21000101','yyyymmdd')) AS DATE) drug_catg_end_dt
              -------------------------------------------------------------------------
              -- prod_fmly_ppaca_t
             ,CAST (NVL(ind_5i,'Y') AS VARCHAR (1)) ppaca_rtl_ind
              -------------------------------------------------------------------------
              -- prod_mstr_t (names)
             ,CAST (NULL AS VARCHAR (134)) prod_nm
             ,CAST (ndc11_prod_desc AS VARCHAR (30)) pckg_nm
             ,CAST (NULL AS VARCHAR (134)) fda_reg_nm
             ,CAST (generic_prod_desc AS VARCHAR (30)) gnrc_nm
             ,CAST ('Y' AS VARCHAR (1)) new_prod_flg
             ,CAST (SUBSTR(ndc11,1,5) || SUBSTR(ndc11,7,5) AS VARCHAR (10)) cosmis_ndc 
             ,CAST (NULL AS VARCHAR (30)) cosmis_descr
             ,CAST (NULL AS VARCHAR (4)) sap_prod_cd
             ,CAST (CASE WHEN SUBSTR(ndc9,1,5) = '71104'
                         THEN 'US12'
                    ELSE NULL
                    END AS VARCHAR (4)) sap_company_cd
             ,CAST (NULL AS VARCHAR (4)) cars_sap_prod_cd
              -------------------------------------------------------------------------
              -- prod_mstr_t (eligibility)
             ,CAST ('EL' AS VARCHAR (2)) elig_stat_cd
             ,CAST ('EL' AS VARCHAR (2)) medicare_elig_stat_cd
             ,CAST (NULL AS NUMBER(9,0)) inelig_rsn_id
             ,CAST (va_drug_catg_cd AS VARCHAR (15)) va_drug_catg_cd
             ,CAST ('EL' AS VARCHAR (2)) va_elig_stat_cd
             ,CAST ('EL' AS VARCHAR (2)) phs_elig_stat_cd
             ,CAST (0 AS NUMBER) elig_va
             ,CAST (0 AS NUMBER) elig_phs
              -------------------------------------------------------------------------
              -- prod_mstr_t (units)
             ,CAST (1 AS NUMBER) unit_per_pckg
             ,CAST (1 AS NUMBER(10,3)) hcfa_disp_units
             ,CAST (1 AS NUMBER) comm_unit_per_pckg
              -------------------------------------------------------------------------
              -- prod_mstr_t (fda)
             ,CAST ('BLA' AS VARCHAR (15)) fda_approval_typ
             --,CAST (fda_apprvl AS DATE) fda_approval_dt
             ,CAST (ndc11_prod_dt_intro AS DATE) fda_approval_dt
              -------------------------------------------------------------------------
              -- prod_mstr_t (dates)
             ,CAST (ndc9_prod_dt_cms_market AS DATE) mrkt_entry_dt_ndc11
             ,CAST (TO_DATE('21000101','yyyymmdd') AS DATE) first_dt_sld_dir
             ,CAST (NULL AS DATE) divestr_dt
             ,CAST (ADD_MONTHS(ndc11_prod_dt_expire,-12) AS DATE) final_lot_dt
             ,CAST (ndc11_prod_dt_expire AS DATE) term_dt
             ,CAST (ndc11_prod_dt_cms_expire AS DATE) liab_end_dt
             ,CAST (NULL AS DATE) medicare_exp_transmitted_dt
             ,CAST (NULL AS DATE) manu_term_date
              -------------------------------------------------------------------------
              -- prod_mstr_t (medicare submission)
             ,CAST (12 AS NUMBER(9,0)) shelf_life_mon
             ,CAST (12 AS NUMBER(5,0)) liablty_mon
             ,CAST ('NP' AS VARCHAR (3)) promo_stat_cd
             ,CAST (1 AS NUMBER) items_per_ndc
             ,CAST (1 AS NUMBER) volume_per_item
             ,CAST (brand_prod_desc AS VARCHAR (70)) pname_desc
             ,CAST (prod_str AS VARCHAR (50)) strngtyp_id
             ,CAST ('UNITS' AS VARCHAR (15)) sizetyp_id
             ,CAST ('PACKAGES' AS VARCHAR (15)) pkgtyp_id
             ,CAST ('VIAL' AS VARCHAR (50)) formtyp_id
             ,CAST (0 AS NUMBER(5,0)) coc_schm_id
             ,CAST ('I' AS VARCHAR (3)) rec_src_ind -- ICW2
             --,'B' rec_src_ind -- insert a row into hcrs.int_src_t
             ,CAST (NULL AS NUMBER) fdb_case_size 		-- Missing
             ,CAST (NULL AS NUMBER) fdb_package_size 		-- Missing
              -------------------------------------------------------------------------
              -- Additional needed fields
             ,CAST (NULL AS VARCHAR (4)) account_num
             ,CAST (NULL AS VARCHAR (4)) sub_acct_num
             ,CAST (NULL AS VARCHAR (4)) cost_center
             ,CAST (NULL AS VARCHAR (4)) project_num
             ,CAST (NULL AS DATE) bamp_date
             ,CAST (NULL AS DATE) revised_bamp_eff_date
             ,CAST (NULL AS VARCHAR (10)) special_item_number
             ,CAST (ndc11_prod_dt_first_sale AS DATE) ndc11_prod_dt_first_sale
             ,CAST (ndc9_prod_dt_first_sale AS DATE) ndc9_prod_dt_first_sale
             ,CAST (min_inv_dt AS DATE) min_inv_dt
         FROM prod_all
        ;





