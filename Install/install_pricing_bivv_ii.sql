-- ============================================================================================
-- File		: Create BIVV Pricing Data
--
-- Author	: John Tronoski, (IntegriChain)
-- Created	: February, 2021
--
-- Modified 	: Use bivv.ic_pricing_ii_v and bivv.ic_pricing_ii_t
--                All of the BIVV tables will have a ii suffix
--		  ...JTronoski (IntegriChain) 02.09.2021
--
-- Purpose  	: This SQL will be used to load the Biogen and Bioverativ products from the 
--                IntegriChain FLEX tables to the BIVV Staging Tables.
--
--                The following steps will be executed:
--                  1. The view bivv.ic_pricing_ii_v will be created
--                  2. The table bivv.ic_pricing_ii_t will be created
--                  5. Create bivv.prfl_t_ii
--                  7. Create bivv.prfl_calc_typ_t_ii
--                  8. Create bivv.prfl_co_t_ii
--                  9. Create bivv.prfl_var_t_ii
--                 10. Create bivv.prfl_prod_fmly_t_ii
--                 11. Create bivv.prfl_prod_t_ii
--                 12. Create bivv.prfl_calc_prod_fmly_t_ii
--                 13. Create bivv.prfl_calc_prod_t_ii
--                 14. Create bivv.prfl_prod_fmly_calc_t_ii
--                 15. Create bivv.prfl_prod_calc_t_ii
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
-- P-01: Create IntegriChain Pricing Master view and table
--------------------------------------------------------------------------------
@@../Views/BIVV/ic_pricing_ii_v.sql

DROP TABLE bivv.ic_pricing_ii_t;
CREATE TABLE bivv.ic_pricing_ii_t
   TABLESPACE bivvdata
   COMPRESS
   AS
      SELECT *
        FROM bivv.ic_pricing_ii_v;

GRANT SELECT ON bivv.ic_pricing_ii_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor;


--------------------------------------------------------------------------------
-- P-05: Insert profiles into bivv.prfl_t_ii
-- Create profile records
--   - Monthly AMP	-- 2 rows
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_t_ii;

CREATE TABLE bivv.prfl_t_ii 
(PRFL_ID NUMBER NOT NULL ENABLE 
,SNPSHT_ID NUMBER NOT NULL ENABLE
,PRFL_STAT_CD VARCHAR2(12) NOT NULL ENABLE
,AGENCY_TYP_CD VARCHAR2(12) NOT NULL ENABLE
,TIM_PER_CD VARCHAR2(12) NOT NULL ENABLE
,PRCSS_TYP_CD VARCHAR2(20) NOT NULL ENABLE
,PRFL_NM VARCHAR2(80)
,BEGN_DT DATE
,END_DT DATE
,COPY_HIST_IND CHAR(1) DEFAULT 'N' NOT NULL ENABLE
,PRELIM_IND CHAR(1) DEFAULT 'N' NOT NULL ENABLE
,MTRX_IND CHAR(1) DEFAULT 'N' NOT NULL ENABLE
)
;

-- Monthly AMP
INSERT INTO bivv.prfl_t_ii
(prfl_id, snpsht_id, prfl_stat_cd, agency_typ_cd, tim_per_cd, prcss_typ_cd, prfl_nm, begn_dt, end_dt, copy_hist_ind, prelim_ind, mtrx_ind)
SELECT ((SELECT MAX(prfl_id) FROM hcrs.prfl_t) + rownum) prfl_id
      ,0 snpsht_id
      ,'TRANSMITTED' prfl_stat_cd
      ,'MEDICAID' agency_typ_cd
      ,p.tim_per_cd
      ,'MED_MTHLY' prcss_typ_cd
      ,p.prfl_nm
      ,p.begn_dt
      ,p.end_dt
      ,'N' copy_hist_ind
      ,'N' prelim_ind
      ,'N' mtrx_ind
  FROM (SELECT tim_per_cd
              ,prfl_nm
              ,begn_dt
              ,end_dt
          FROM (SELECT TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                      ,TO_CHAR( x.amp_mth_1_strt_dt,'FMYYYY Month') || ' AMP Bioverativ LOADED' prfl_nm
                      ,x.amp_mth_1_strt_dt begn_dt
                      ,x.amp_mth_1_end_dt end_dt
                  FROM bivv.ic_pricing_ii_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_1 IS NOT NULL) OR
                        (x.amp_mth_1 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                      ,TO_CHAR( x.amp_mth_2_strt_dt,'FMYYYY Month') || ' Bioverativ LOADED' prfl_nm
                      ,x.amp_mth_2_strt_dt begn_dt
                      ,x.amp_mth_2_end_dt end_dt
                  FROM bivv.ic_pricing_ii_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_2 IS NOT NULL) OR
                        (x.amp_mth_2 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                      ,TO_CHAR( x.amp_mth_3_strt_dt,'FMYYYY Month') || ' Bioverativ LOADED' prfl_nm
                      ,x.amp_mth_3_strt_dt begn_dt
                      ,x.amp_mth_3_end_dt end_dt
                  FROM bivv.ic_pricing_ii_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_3 IS NOT NULL) OR
                        (x.amp_mth_3 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104')
        ORDER BY begn_dt
       ) p
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_t_ii TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-06: Insert Calculation Types into bivv.prfl_calc_typ_t_ii
-- Create profile calculation records
--   - Monthly AMP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_calc_typ_t_ii;

CREATE TABLE bivv.prfl_calc_typ_t_ii 
(PRFL_ID NUMBER NOT NULL ENABLE
,CALC_TYP_CD VARCHAR2(20) NOT NULL ENABLE
,CALC_MTHD_CD VARCHAR2(10) NOT NULL ENABLE
)
;

-- Monthly AMP/BP
INSERT INTO bivv.prfl_calc_typ_t_ii
(prfl_id, calc_typ_cd, calc_mthd_cd)
SELECT p.prfl_id
      ,x.calc_typ_cd
      ,x.calc_mthd_cd
  FROM bivv.prfl_t_ii p
      ,(SELECT 'AMP' calc_typ_cd
              ,'ACTL' calc_mthd_cd
          FROM dual) x
 WHERE p.agency_typ_cd = 'MEDICAID' 
   AND p.prcss_typ_cd = 'MED_MTHLY'
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_calc_typ_t_ii TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-07: Insert into bivv.prfl_co_t_ii
-- Create profile company records
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_co_t_ii;
CREATE TABLE bivv.prfl_co_t_ii
    AS (SELECT p.prfl_id
              ,121 co_id
          FROM bivv.prfl_t_ii p
       )
;

-- Grants
GRANT SELECT ON bivv.prfl_co_t_ii TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-08: Insert into bivv.prfl_var_t_ii
-- Create profile variable records
--   - Monthly AMP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_var_t_ii;

-- Monthly AMP
CREATE TABLE bivv.prfl_var_t_ii
    AS (SELECT p.prfl_id
              ,p.agency_typ_cd
              ,'ADP' var_cd
              ,6 val_txt
              ,p.prcss_typ_cd
          FROM bivv.prfl_t_ii p
         WHERE p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
        UNION ALL
        SELECT p.prfl_id
              ,p.agency_typ_cd
              ,'CDP' var_cd
              ,0.02 val_txt
              ,p.prcss_typ_cd
          FROM bivv.prfl_t_ii p
         WHERE p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
        UNION ALL
        SELECT p.prfl_id
              ,p.agency_typ_cd
              ,'MAX_DPA_PCT' var_cd
              ,0.01 val_txt
              ,p.prcss_typ_cd
          FROM bivv.prfl_t_ii p
         WHERE p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
        UNION ALL
        SELECT p.prfl_id
              ,p.agency_typ_cd
              ,'NTP' var_cd
              ,0.10 val_txt
              ,p.prcss_typ_cd
          FROM bivv.prfl_t_ii p
         WHERE p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
        UNION ALL
        SELECT p.prfl_id
              ,p.agency_typ_cd
              ,'SO' var_cd
              ,0 val_txt
              ,p.prcss_typ_cd
          FROM bivv.prfl_t_ii p
         WHERE p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
       )
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_var_t_ii TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-09: Insert into bivv.prfl_prod_fmly_t_ii
-- Create profile product family records
--   - Monthly AMP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_prod_fmly_t_ii;

-- Monthly AMP
CREATE TABLE bivv.prfl_prod_fmly_t_ii
    AS (SELECT p.prfl_id
              ,x.ndc_lbl
              ,x.ndc_prod
          FROM bivv.prfl_t_ii p
              ,(SELECT tim_per_cd
                      ,SUBSTR(ndc11,1,5) ndc_lbl
                      ,SUBSTR(ndc11,6,4) ndc_prod
                  FROM (SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_ii_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_1 IS NOT NULL) OR
                                (x.amp_mth_1 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_ii_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_2 IS NOT NULL) OR
                                (x.amp_mth_2 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_ii_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_3 IS NOT NULL) OR
                                (x.amp_mth_3 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104') ) x
         WHERE p.tim_per_cd = x.tim_per_cd
           AND p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
       )
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_prod_fmly_t_ii TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-10: Insert into bivv.prfl_prod_t_ii
-- Create profile product records
--   - Monthly AMP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_prod_t_ii;

-- Monthly AMP
CREATE TABLE bivv.prfl_prod_t_ii
    AS (SELECT p.prfl_id
              ,x.ndc_lbl
              ,x.ndc_prod
              ,x.ndc_pckg
              ,'NONE' pri_whls_mthd_cd
              ,'COMPLETE' calc_stat_cd
              ,'N' shtdwn_ind
          FROM bivv.prfl_t_ii p
              ,(SELECT tim_per_cd
                      ,SUBSTR(ndc11,1,5) ndc_lbl
                      ,SUBSTR(ndc11,6,4) ndc_prod
                      ,SUBSTR(ndc11,10,2) ndc_pckg
                  FROM (SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_ii_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_1 IS NOT NULL) OR
                                (x.amp_mth_1 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_ii_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_2 IS NOT NULL) OR
                                (x.amp_mth_2 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_ii_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_3 IS NOT NULL) OR
                                (x.amp_mth_3 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104') ) x
         WHERE p.tim_per_cd = x.tim_per_cd
           AND p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
       )
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_prod_t_ii TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-11: Insert into bivv.prfl_calc_prod_fmly_t_ii
-- Create profile calculation product family records
--   - Monthly AMP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_calc_prod_fmly_t_ii;

-- Quarterly AMP/BP
CREATE TABLE bivv.prfl_calc_prod_fmly_t_ii
    AS (SELECT p.prfl_id
              ,'AMP' calc_typ_cd
              ,x.ndc_lbl
              ,x.ndc_prod
              ,'NONE' pri_whls_mthd_cd
          FROM bivv.prfl_t_ii p
              ,(SELECT tim_per_cd
                      ,SUBSTR(ndc11,1,5) ndc_lbl
                      ,SUBSTR(ndc11,6,4) ndc_prod
                  FROM (SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_ii_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_1 IS NOT NULL) OR
                                (x.amp_mth_1 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_ii_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_2 IS NOT NULL) OR
                                (x.amp_mth_2 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_ii_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_3 IS NOT NULL) OR
                                (x.amp_mth_3 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104') ) x
         WHERE p.tim_per_cd = x.tim_per_cd
           AND p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
       )
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_calc_prod_fmly_t_ii TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-12: Insert into bivv.prfl_calc_prod_t_ii
-- Create profile calculation product records
--   - Monthly AMP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_calc_prod_t_ii;

CREATE TABLE bivv.prfl_calc_prod_t_ii
(PRFL_ID NUMBER
,CALC_TYP_CD VARCHAR2(20)
,NDC_LBL VARCHAR2(5)
,NDC_PROD VARCHAR2(4)
,NDC_PCKG VARCHAR2(2)
,PRI_WHLS_MTHD_CD VARCHAR2(12)
)
;

-- Monthly AMP
INSERT INTO bivv.prfl_calc_prod_t_ii
(prfl_id, calc_typ_cd,  ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd)
SELECT p.prfl_id
      ,'AMP' calc_typ_cd
      ,x.ndc_lbl
      ,x.ndc_prod
      ,x.ndc_pckg
      ,'NONE' pri_whls_mthd_cd
  FROM bivv.prfl_t_ii p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
          FROM (SELECT x.ndc11
                      ,TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                  FROM bivv.ic_pricing_ii_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_1 IS NOT NULL) OR
                        (x.amp_mth_1 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT x.ndc11
                      ,TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                  FROM bivv.ic_pricing_ii_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_2 IS NOT NULL) OR
                        (x.amp_mth_2 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT x.ndc11
                      ,TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                  FROM bivv.ic_pricing_ii_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_3 IS NOT NULL) OR
                        (x.amp_mth_3 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104') ) x
 WHERE p.tim_per_cd = x.tim_per_cd
   AND p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_MTHLY'
;

COMMIT;


-- Grants
GRANT SELECT ON bivv.prfl_calc_prod_t_ii TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

-------------------------------------------------------------------------------
-- P-13: Insert into bivv.prfl_prod_fmly_calc_t_ii
-- Create profile product family calculation results records
--   - Monthly AMP
--------------------------------------------------------------------------------


DROP TABLE bivv.prfl_prod_fmly_calc_t_ii;

-- Monthly AMP
CREATE TABLE bivv.prfl_prod_fmly_calc_t_ii
    AS (SELECT p.prfl_id
              ,x.ndc_lbl
              ,x.ndc_prod
              ,'AMP' calc_typ_cd
              ,'AMP' comp_typ_cd
              ,x.calc_amt
          FROM bivv.prfl_t_ii p
              ,(SELECT tim_per_cd
                      ,SUBSTR(ndc11,1,5) ndc_lbl
                      ,SUBSTR(ndc11,6,4) ndc_prod
                      ,calc_amt
                  FROM (SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                              ,x.amp_mth_1 calc_amt
                          FROM bivv.ic_pricing_ii_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_1 IS NOT NULL) OR
                                (x.amp_mth_1 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                              ,x.amp_mth_2 calc_amt
                          FROM bivv.ic_pricing_ii_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_2 IS NOT NULL) OR
                                (x.amp_mth_2 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                              ,x.amp_mth_3 calc_amt
                          FROM bivv.ic_pricing_ii_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_3 IS NOT NULL) OR
                                (x.amp_mth_3 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104') ) x
         WHERE p.tim_per_cd = x.tim_per_cd
           AND p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
       )
;


COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_prod_fmly_calc_t_ii TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

-------------------------------------------------------------------------------
-- P-14: Insert into bivv.prfl_prod_calc_t_ii
-- Create profile product calculation results records
--   - Monthly AMP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_prod_calc_t_ii;

CREATE TABLE bivv.prfl_prod_calc_t_ii
(PRFL_ID NUMBER
,NDC_LBL VARCHAR2(5)
,NDC_PROD VARCHAR2(4)
,NDC_PCKG VARCHAR2(2)
,CALC_TYP_CD VARCHAR2(20)
,COMP_TYP_CD VARCHAR2(12)
,CALC_AMT NUMBER
)
;

-- Monthly AMP
INSERT INTO bivv.prfl_prod_calc_t_ii
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, comp_typ_cd, calc_amt)
SELECT p.prfl_id
      ,x.ndc_lbl
      ,x.ndc_prod
      ,x.ndc_pckg
      ,'AMP' calc_typ_cd
      ,'AMP' comp_typ_cd
      ,x.calc_amt
  FROM bivv.prfl_t_ii p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
              ,calc_amt
          FROM (SELECT x.ndc11
                      ,TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                      ,x.amp_mth_1 calc_amt
                  FROM bivv.ic_pricing_ii_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_1 IS NOT NULL) OR
                        (x.amp_mth_1 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT x.ndc11
                      ,TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                      ,x.amp_mth_2 calc_amt
                  FROM bivv.ic_pricing_ii_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_2 IS NOT NULL) OR
                        (x.amp_mth_2 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT x.ndc11
                      ,TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                      ,x.amp_mth_3 calc_amt
                  FROM bivv.ic_pricing_ii_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_3 IS NOT NULL) OR
                        (x.amp_mth_3 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104') ) x
 WHERE p.tim_per_cd = x.tim_per_cd
   AND p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_MTHLY'
;

COMMIT;


-- Grants
GRANT SELECT ON bivv.prfl_prod_calc_t_ii TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;


-- Commit changes
COMMIT;

-- What time did this end running?
SELECT SYSDATE FROM dual;
