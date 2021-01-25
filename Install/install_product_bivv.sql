-- ============================================================================================
-- File		: Create BIVV Product Data
--
-- Author	: John Tronoski, (IntegriChain)
-- Created	: September, 2020
--
-- Modified 	: Modified the creation of the table bivv.prod_fmly_ppaca_t
--                  - The column eff_end_dt is now defaulted to 01.01.2100
--                  - The column tim_per_end_dt is now defaulted to 01.01.2100
--                Modified the creation of the table bivv.co_prod_mstr_t
--                  - The column eff_dt is now the 1st day of the quarter of the product market entry date
--		  ...JTronoski (IntegriChain) 01.06.2021
--
-- Purpose  	: This SQL will be used to load the Biogen and Bioverativ products from the 
--                IntegriChain FLEX tables to the BIVV Staging Tables.
--
--                The following steps will be executed:
--                  1. The view bivv.ic_product_v will be created
--                  2. The table bivv.ic_product_t will be created
--                  3. Create bivv.lbl_t
--                  4. Create bivv.co_prod_mstr_t
--                  5. Create bivv.prod_fmly_t
--                  6. Create bivv.prod_fmly_drug_catg_t
--                  7. Create bivv.prod_fmly_ppaca_t
--                  8. Create bivv.prod_mstr_t
--                  9. Validate the data in the product tables
--
-- Parameters  	: N/A
--
-- Status  	: N/A
--
-- Information 	: This script should be run in the BIVV Instance
--
-- Issues  	: N/A
--
-- SQL  	: N/A
--
-- ============================================================================================

SET PAGESIZE 50000
SET LINESIZE 10000
SET ECHO ON
SET TAB OFF
SET FEEDBACK ON
SET DEFINE OFF
SET TRIMSPOOL ON
SET SERVEROUTPUT ON SIZE 1000000
SET SQLBLANKLINES ON
SET TIMING ON

-- Alter Date and Time Format
ALTER SESSION SET NLS_DATE_FORMAT = 'MM/DD/YYYY HH24:MI:SS';
COMMIT;

-- In what database instance is this run?
SELECT * FROM global_name;

-- What time did this start running?
SELECT SYSDATE FROM dual;

--------------------------------------------------------------------------------
-- P-01: Create IntegriChain Product Master view and table
--------------------------------------------------------------------------------
@@../Views/BIVV/ic_product_v.sql

DROP TABLE bivv.ic_product_t;
CREATE TABLE bivv.ic_product_t
   TABLESPACE bivvdata
   COMPRESS
   AS
      SELECT *
        FROM bivv.ic_product_v;

GRANT SELECT ON bivv.ic_product_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;


--------------------------------------------------------------------------------
-- P-02: Insert 2 Labelers into bivv.lbl_t
--------------------------------------------------------------------------------

DROP TABLE bivv.lbl_t;
CREATE TABLE bivv.lbl_t
    AS (SELECT DISTINCT SUBSTR(ndc,1,5) ndc_lbl
              ,SYSDATE eff_dt
              ,to_date('2100-01-01','yyyy-mm-dd') end_dt
              ,'Y' va_active_flg
              ,121 co_id
          FROM bivv.ic_product_t);

-- Grants
GRANT SELECT ON bivv.lbl_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-03: Insert 32 Products into bivv.co_prod_mstr_t
--------------------------------------------------------------------------------

DROP TABLE bivv.co_prod_mstr_t;
CREATE TABLE bivv.co_prod_mstr_t
    AS (SELECT SUBSTR(ndc,1,5) ndc_lbl
              ,SUBSTR(ndc,6,4) ndc_prod
              ,SUBSTR(ndc,10,2) ndc_pckg
              ,TRUNC(mrkt_entry_dt_ndc11, 'q') eff_dt
              ,to_date('2100-01-01','yyyy-mm-dd') end_dt
              ,121 co_id
          FROM bivv.ic_product_t);

-- Grants
GRANT SELECT ON bivv.co_prod_mstr_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-04: Insert 32 Products into bivv.prod_fmly_t
--------------------------------------------------------------------------------

DROP TABLE bivv.prod_fmly_t;
CREATE TABLE bivv.prod_fmly_t
    AS (SELECT SUBSTR(ndc,1,5) ndc_lbl
              ,SUBSTR(ndc,6,4) ndc_prod
              ,fda_desi_cd
              ,drug_typ_cd
              ,fda_thera_cd
              ,UPPER(prod_fmly_nm) prod_fmly_nm
              ,mkt_entry_dt
              ,hcfa_unit_typ_cd
              ,potency_flg
              ,ndc_id
              ,UPPER(form) form
              ,UPPER(strength) strength
              ,purchase_prod_dt
              ,nonrtl_route_of_admin
              ,nonrtl_drug_ind
              ,cod_stat
              ,otc_mono_num
              ,fda_application_num
              ,line_extension_ind
          FROM bivv.ic_product_t);

-- Grants
GRANT SELECT ON bivv.prod_fmly_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-05: Insert 32 Products into bivv.prod_fmly_drug_catg_t
--------------------------------------------------------------------------------

DROP TABLE bivv.prod_fmly_drug_catg_t;
CREATE TABLE bivv.prod_fmly_drug_catg_t
    AS (SELECT SUBSTR(ndc,1,5) ndc_lbl
              ,SUBSTR(ndc,6,4) ndc_prod
              ,drug_catg_eff_dt eff_dt
              ,drug_catg_cd
              ,drug_catg_end_dt end_dt
              ,medicare_drug_catg_cd
          FROM bivv.ic_product_t);

-- Grants
GRANT SELECT ON bivv.prod_fmly_drug_catg_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-06: Insert 32 Products into bivv.prod_fmly_ppaca_t
--------------------------------------------------------------------------------

DROP TABLE bivv.prod_fmly_ppaca_t;
CREATE TABLE bivv.prod_fmly_ppaca_t
    AS (SELECT SUBSTR(ndc,1,5) ndc_lbl
              ,SUBSTR(ndc,6,4) ndc_prod
              ,drug_catg_eff_dt eff_bgn_dt
              ,TO_DATE('01012100','ddmmyyyy') eff_end_dt
              ,drug_catg_eff_dt tim_per_bgn_dt
              ,TO_DATE('01012100','ddmmyyyy') tim_per_end_dt
              ,ppaca_rtl_ind
          FROM bivv.ic_product_t);

-- Grants
GRANT SELECT ON bivv.prod_fmly_ppaca_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-07: Insert 32 Products into bivv.prod_mstr_t
--------------------------------------------------------------------------------

DROP TABLE bivv.prod_mstr_t;
CREATE TABLE bivv.prod_mstr_t
    AS (SELECT SUBSTR(ndc,1,5) ndc_lbl
              ,SUBSTR(ndc,6,4) ndc_prod
              ,SUBSTR(ndc,10,2) ndc_pckg
              ,unit_per_pckg
              ,hcfa_disp_units
              ,first_dt_sld_dir
              ,shelf_life_mon
              ,elig_stat_cd
              ,inelig_rsn_id
              ,fda_approval_dt
              ,liablty_mon
              ,new_prod_flg
              ,CASE WHEN ndc IN ('71104080401','71104092201','71104093301','71104094401')
                    THEN ndc11_prod_dt_first_sale
               ELSE min_inv_dt
               END first_dt_sld
              ,divestr_dt
              ,final_lot_dt
              ,promo_stat_cd
              ,ndc_id
              ,cosmis_ndc 
              ,cosmis_descr
              ,UPPER(pckg_nm) pckg_nm
              ,coc_schm_id
              ,rec_src_ind
              ,mrkt_entry_dt_ndc11 mrkt_entry_dt
              ,gnrc_nm
              ,medicare_elig_stat_cd
              ,sap_prod_cd
              ,items_per_ndc
              ,volume_per_item
              ,medicare_exp_transmitted_dt medicare_exp_trnsmitted_dt
              ,comm_unit_per_pckg
              ,UPPER(pname_desc) pname_desc
              ,strngtyp_id
              ,sizetyp_id
              ,pkgtyp_id
              ,formtyp_id
              ,sap_company_cd
              ,cars_sap_prod_cd
              ,va_drug_catg_cd
              ,va_elig_stat_cd
              ,phs_elig_stat_cd
              ,fdb_case_size
              ,fdb_package_size
          FROM bivv.ic_product_t);

-- Grants
GRANT SELECT ON bivv.prod_mstr_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;


--------------------------------------------------------------------------------
-- Validate the counts in the BIVV Staging Tables
-- There should be 2 rows in bivv.lbl_t.
-- There should be 32 rows in all other tables.
--------------------------------------------------------------------------------

SELECT count(DISTINCT ndc_lbl)
  FROM bivv.lbl_t t
;

SELECT COUNT(*)
  FROM (SELECT DISTINCT ndc_lbl, ndc_prod, ndc_pckg
         FROM bivv.co_prod_mstr_t t
       )
;

SELECT COUNT(*)
  FROM (SELECT DISTINCT ndc_lbl, ndc_prod
         FROM bivv.prod_fmly_t t
       )
;

SELECT COUNT(*)
  FROM (SELECT DISTINCT ndc_lbl, ndc_prod
         FROM bivv.prod_fmly_drug_catg_t t
       )
;

SELECT COUNT(*)
  FROM (SELECT DISTINCT ndc_lbl, ndc_prod
         FROM bivv.prod_fmly_ppaca_t t
       )
;

SELECT COUNT(*)
  FROM (SELECT DISTINCT ndc_lbl, ndc_prod, ndc_pckg
         FROM bivv.prod_mstr_t t
       )
;

-- Commit changes
COMMIT;

-- What time did this end running?
SELECT SYSDATE FROM dual;
