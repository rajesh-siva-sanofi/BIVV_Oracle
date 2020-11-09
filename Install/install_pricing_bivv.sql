-- ============================================================================================
-- File		: Create BIVV Pricing Data
--
-- Author	: John Tronoski, (IntegriChain)
-- Created	: September, 2020
--
-- Modified 	: Only load the Bioverativ labeler into these tables.
--		  ...JTronoski 11.09.2020  (IntegriChain)
--
-- Purpose  	: This SQL will be used to load the Biogen and Bioverativ products from the 
--                IntegriChain FLEX tables to the BIVV Staging Tables.
--
--                The following steps will be executed:
--                  1. The view bivv.ic_pricing_v will be created
--                  2. The table bivv.ic_pricing_t will be created
--                  3. Create bivv.prod_trnsmsn_t
--                  4. Create bivv.prod_price_t
--                  5. Create bivv.prfl_t
--                  6. Create bivv.calc_mthd_t
--                  7. Create bivv.prfl_calc_typ_t
--                  8. Create bivv.prfl_co_t
--                  9. Create bivv.prfl_var_t
--                 10. Create bivv.prfl_prod_fmly_t
--                 11. Create bivv.prfl_prod_t
--                 12. Create bivv.prfl_calc_prod_fmly_t
--                 13. Create bivv.prfl_calc_prod_t
--                 14. Create bivv.prfl_prod_fmly_calc_t
--                 15. Create bivv.prfl_prod_calc_t
--                 16. Create bivv.prfl_prod_bp_pnt_t
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
@@ic_pricing_v.sql

DROP TABLE bivv.ic_pricing_t;
CREATE TABLE bivv.ic_pricing_t
   TABLESPACE bivvdata
   COMPRESS
   AS
      SELECT *
        FROM bivv.ic_pricing_v;

GRANT SELECT ON bivv.ic_pricing_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor;

--------------------------------------------------------------------------------
-- P-03: Insert into bivv.prod_trnsmsn_t
-- Create Bioverativ Data
--------------------------------------------------------------------------------

DROP TABLE bivv.prod_trnsmsn_t;
CREATE TABLE bivv.prod_trnsmsn_t
    AS (SELECT SUBSTR(x.ndc11,1,5) ndc_lbl
              ,SUBSTR(x.ndc11,6,4) ndc_prod
              ,p.period_id
              ,1 trnsmsn_seq_no
              ,'TR' prod_trnsmsn_stat_cd
              ,'QTR' prod_trnsmsn_rsn_cd
              ,amp_qtrly amp_amt
              ,CASE WHEN SUBSTR(x.ndc11,6,4) = '0809'
                     AND x.year_qtr = '20172'
                     THEN COALESCE(x.bp_qtrly, x.ddr_parent_bp, x.ddr_bp)
               ELSE NVL(COALESCE(x.bp_qtrly, x.ddr_bp, x.ddr_parent_bp),0)
               END bp_amt
              ,'Y' actv_flg
              ,'Y' amp_apprvl_flg
              ,'Y' bp_apprvl_flg
              ,SYSDATE trnsmsn_dt
              ,'N' dra_baseline_flg
          FROM bivv.ic_pricing_t x
              ,hcrs.period_t p
         WHERE TO_NUMBER(SUBSTR(x.year_qtr,1,4)) = p.yr
           AND TO_NUMBER(SUBSTR(x.year_qtr,5,1)) = p.qtr
           AND TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
           AND SUBSTR(x.ndc11,1,5) = '71104'
       )
;

-- Grants
GRANT SELECT ON bivv.prod_trnsmsn_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;


--------------------------------------------------------------------------------
-- P-04: Insert into bivv.prod_price_t
-- Create Bioverativ product price records
--------------------------------------------------------------------------------

DROP TABLE bivv.prod_price_t;

CREATE TABLE bivv.prod_price_t
(NDC_LBL VARCHAR2(5)
,NDC_PROD VARCHAR2(4) 
,NDC_PCKG VARCHAR2(2)
,PROD_PRICE_TYP_CD VARCHAR2(10) 
,EFF_DT DATE 
,END_DT DATE 
,PRICE_AMT NUMBER 
,REC_SRC_IND VARCHAR2(1) 
)
;

INSERT INTO bivv.prod_price_t
(ndc_lbl, ndc_prod, ndc_pckg, prod_price_typ_cd, eff_dt, end_dt, price_amt, rec_src_ind)
SELECT xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,xx.prod_price_typ_cd
      ,xx.eff_dt
      ,xx.end_dt
      ,xx.price_amt
      ,xx.rec_src_ind
  FROM (SELECT SUBSTR(x.ndc11,1,5) ndc_lbl
              ,SUBSTR(x.ndc11,6,4) ndc_prod
              ,SUBSTR(x.ndc11,10,4) ndc_pckg
              ,'WAC' prod_price_typ_cd
              ,x.wac_strt_dt eff_dt
              ,CASE WHEN x.wac_end_dt = TO_DATE('20991231','yyyymmdd')
                    THEN TO_DATE('21000101','yyyymmdd')
               ELSE x.wac_end_dt
               END end_dt
              ,x.wac price_amt
              ,'M' rec_src_ind -- 'M' for Manual
          FROM bivv.ic_pricing_t x
         WHERE wac IS NOT NULL
           AND SUBSTR(x.ndc11,1,5) = '71104'
        ORDER BY x.ndc11, x.wac_strt_dt) xx
;

COMMIT;

INSERT INTO bivv.prod_price_t
(ndc_lbl, ndc_prod, ndc_pckg, prod_price_typ_cd, eff_dt, end_dt, price_amt, rec_src_ind)
SELECT xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,xx.prod_price_typ_cd
      ,xx.eff_dt
      ,xx.end_dt
      ,xx.price_amt
      ,xx.rec_src_ind
  FROM (SELECT SUBSTR(x.ndc11,1,5) ndc_lbl
              ,SUBSTR(x.ndc11,6,4) ndc_prod
              ,SUBSTR(x.ndc11,10,4) ndc_pckg
              ,'LP' prod_price_typ_cd
              ,x.wac_strt_dt eff_dt
              ,CASE WHEN x.wac_end_dt = TO_DATE('20991231','yyyymmdd')
                    THEN TO_DATE('21000101','yyyymmdd')
               ELSE x.wac_end_dt
               END end_dt
              ,x.wac price_amt
              ,'M' rec_src_ind -- 'M' for Manual
          FROM bivv.ic_pricing_t x
         WHERE wac IS NOT NULL
           AND SUBSTR(x.ndc11,1,5) = '71104'
        ORDER BY x.ndc11, x.wac_strt_dt) xx
;

COMMIT;


-- Grants
GRANT SELECT ON bivv.prod_price_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-05: Insert profiles into bivv.prfl_t
-- Create profile records
--   - Monthly AMP	-- 25 rows
--   - Quarterly AMP/BP	-- 15 rows
--   - Quarterly ASP	-- 9 rows
--   - Quarterly NFAMP	-- 9 rows
--   - Annual NFAMP/FCP	-- 1 row
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_t;

CREATE TABLE bivv.PRFL_T 
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
INSERT INTO bivv.prfl_t
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
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_1 IS NOT NULL) OR
                        (x.amp_mth_1 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                      ,TO_CHAR( x.amp_mth_2_strt_dt,'FMYYYY Month') || ' Bioverativ LOADED' prfl_nm
                      ,x.amp_mth_2_strt_dt begn_dt
                      ,x.amp_mth_2_end_dt end_dt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_2 IS NOT NULL) OR
                        (x.amp_mth_2 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                      ,TO_CHAR( x.amp_mth_3_strt_dt,'FMYYYY Month') || ' Bioverativ LOADED' prfl_nm
                      ,x.amp_mth_3_strt_dt begn_dt
                      ,x.amp_mth_3_end_dt end_dt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_3 IS NOT NULL) OR
                        (x.amp_mth_3 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104')
        ORDER BY begn_dt
       ) p
;

COMMIT;


-- Quarterly AMP/BP
INSERT INTO bivv.prfl_t
(prfl_id, snpsht_id, prfl_stat_cd, agency_typ_cd, tim_per_cd, prcss_typ_cd, prfl_nm, begn_dt, end_dt, copy_hist_ind, prelim_ind, mtrx_ind)
SELECT ((SELECT MAX(prfl_id) FROM bivv.prfl_t) + rownum) prfl_id
      ,0 snpsht_id
      ,'TRANSMITTED' prfl_stat_cd
      ,'MEDICAID' agency_typ_cd
      ,p.tim_per_cd
      ,'MED_QTRLY' prcss_typ_cd
      ,p.prfl_nm
      ,p.begn_dt
      ,p.end_dt
      ,'N' copy_hist_ind
      ,'N' prelim_ind
      ,'N' mtrx_ind
  FROM (SELECT tim_per_cd
              ,prfl_nm
              ,begn_dt
              ,add_months(trunc(begn_dt,'Y') -1 ,to_number(to_char(begn_dt,'Q')) * 3) end_dt
          FROM (SELECT DISTINCT year_qtr
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) || ' AMP/BP Bioverativ LOADED' prfl_nm
                               ,add_months(to_date(substr(year_qtr,1,4)||'01','YYYYMM'),3*(to_number(substr(year_qtr,5))-1)) begn_dt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND amp_qtrly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
        ORDER BY begn_dt
       ) p
;

COMMIT;

-- Quarterly ASP
INSERT INTO bivv.prfl_t
(prfl_id, snpsht_id, prfl_stat_cd, agency_typ_cd, tim_per_cd, prcss_typ_cd, prfl_nm, begn_dt, end_dt, copy_hist_ind, prelim_ind, mtrx_ind)
SELECT ((SELECT MAX(prfl_id) FROM bivv.prfl_t) + rownum) prfl_id
      ,0 snpsht_id
      ,'TRANSMITTED' prfl_stat_cd
      ,'MEDICARE' agency_typ_cd
      ,p.tim_per_cd
      ,'MEDICARE_QTRLY' prcss_typ_cd
      ,p.prfl_nm
      ,p.begn_dt
      ,p.end_dt
      ,'N' copy_hist_ind
      ,'N' prelim_ind
      ,'N' mtrx_ind
  FROM (SELECT tim_per_cd
              ,prfl_nm
              ,begn_dt
              ,add_months(trunc(begn_dt,'Y') -1 ,to_number(to_char(begn_dt,'Q')) * 3) end_dt
          FROM (SELECT DISTINCT year_qtr
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) || ' ASP Bioverativ LOADED' prfl_nm
                               ,add_months(to_date(substr(year_qtr,1,4)||'01','YYYYMM'),3*(to_number(substr(year_qtr,5))-1)) begn_dt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.asp_qrtly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
        ORDER BY begn_dt
       ) p
;

COMMIT;

-- Quarterly NFAMP
INSERT INTO bivv.prfl_t
(prfl_id, snpsht_id, prfl_stat_cd, agency_typ_cd, tim_per_cd, prcss_typ_cd, prfl_nm, begn_dt, end_dt, copy_hist_ind, prelim_ind, mtrx_ind)
SELECT ((SELECT MAX(prfl_id) FROM bivv.prfl_t) + rownum) prfl_id
      ,0 snpsht_id
      ,'TRANSMITTED' prfl_stat_cd
      ,'VA' agency_typ_cd
      ,p.tim_per_cd
      ,'VA_QTRLY' prcss_typ_cd
      ,p.prfl_nm
      ,p.begn_dt
      ,p.end_dt
      ,'N' copy_hist_ind
      ,'N' prelim_ind
      ,'N' mtrx_ind
  FROM (SELECT tim_per_cd
              ,prfl_nm
              ,begn_dt
              ,add_months(trunc(begn_dt,'Y') -1 ,to_number(to_char(begn_dt,'Q')) * 3) end_dt
          FROM (SELECT DISTINCT year_qtr
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) || ' NFAMP Bioverativ LOADED' prfl_nm
                               ,add_months(to_date(substr(year_qtr,1,4)||'01','YYYYMM'),3*(to_number(substr(year_qtr,5))-1)) begn_dt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.nfamp_qrtly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
        ORDER BY begn_dt
       ) p
;

COMMIT;

-- Annual NFAMP/FCP
INSERT INTO bivv.prfl_t
(prfl_id, snpsht_id, prfl_stat_cd, agency_typ_cd, tim_per_cd, prcss_typ_cd, prfl_nm, begn_dt, end_dt, copy_hist_ind, prelim_ind, mtrx_ind)
SELECT ((SELECT MAX(prfl_id) FROM bivv.prfl_t) + rownum) prfl_id
      ,0 snpsht_id
      ,'TRANSMITTED' prfl_stat_cd
      ,'VA' agency_typ_cd
      ,p.tim_per_cd
      ,'VA_ANNL' prcss_typ_cd
      ,p.prfl_nm
      ,p.begn_dt
      ,p.end_dt
      ,'N' copy_hist_ind
      ,'N' prelim_ind
      ,'N' mtrx_ind
  FROM (SELECT tim_per_cd
              ,prfl_nm
              ,begn_dt
              ,add_months(trunc(begn_dt,'Y') -1 ,to_number(to_char(begn_dt,'Q')) * 12) end_dt
          FROM (SELECT DISTINCT year_qtr
                               ,SUBSTR(year_qtr,1,4) tim_per_cd
                               ,SUBSTR(year_qtr,1,4) || ' NFAMP/FCP Bioverativ LOADED' prfl_nm
                               ,add_months(to_date(substr(year_qtr,1,4)||'01','YYYYMM'),3*(to_number(substr(year_qtr,5))-1)) begn_dt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.nfamp_annual IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT DISTINCT year_qtr
                               ,SUBSTR(year_qtr,1,4) tim_per_cd
                               ,SUBSTR(year_qtr,1,4) || ' NFAMP/FCP Bioverativ LOADED' prfl_nm
                               ,add_months(to_date(substr(year_qtr,1,4)||'01','YYYYMM'),3*(to_number(substr(year_qtr,5))-1)) begn_dt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.fcp_annual IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
        ORDER BY begn_dt
       ) p
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-06: Insert Calculation Types into bivv.prfl_calc_typ_t
-- Create profile calculation records
--   - Monthly AMP
--   - Quarterly AMP
--   - Quarterly BP
--   - Quarterly ASP
--   - Quarterly NFAMP
--   - Annual NFAMP
--   - Annual FCP
--------------------------------------------------------------------------------

-- This is for the following calculations:
--   - Quarterly ASP

DROP TABLE bivv.calc_mthd_t;

CREATE TABLE bivv.calc_mthd_t
    AS (SELECT 'ACTL-BIOV' calc_mthd_cd
              ,'Actual (Bioverativ Legacy)' calc_mthd_descr
          FROM dual
       )
;

-- Grants
GRANT SELECT ON bivv.calc_mthd_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;


DROP TABLE bivv.prfl_calc_typ_t;

CREATE TABLE BIVV.PRFL_CALC_TYP_T 
(PRFL_ID NUMBER NOT NULL ENABLE
,CALC_TYP_CD VARCHAR2(20) NOT NULL ENABLE
,CALC_MTHD_CD VARCHAR2(10) NOT NULL ENABLE
)
;

-- Monthly AMP/BP
INSERT INTO bivv.prfl_calc_typ_t
(prfl_id, calc_typ_cd, calc_mthd_cd)
SELECT p.prfl_id
      ,x.calc_typ_cd
      ,x.calc_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT 'AMP' calc_typ_cd
              ,'ACTL' calc_mthd_cd
          FROM dual) x
 WHERE p.agency_typ_cd = 'MEDICAID' 
   AND p.prcss_typ_cd = 'MED_MTHLY'
;

-- Quarterly AMP/BP
INSERT INTO bivv.prfl_calc_typ_t
(prfl_id, calc_typ_cd, calc_mthd_cd)
SELECT p.prfl_id
      ,x.calc_typ_cd
      ,x.calc_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT 'AMP' calc_typ_cd
              ,'ACTL' calc_mthd_cd
          FROM dual
        UNION
        SELECT 'BP' calc_typ_cd
              ,'ACTL' calc_mthd_cd
          FROM dual) x
 WHERE p.agency_typ_cd = 'MEDICAID' 
   AND p.prcss_typ_cd = 'MED_QTRLY'
;

-- Quarterly ASP
INSERT INTO bivv.prfl_calc_typ_t
(prfl_id, calc_typ_cd, calc_mthd_cd)
SELECT p.prfl_id
      ,x.calc_typ_cd
      ,x.calc_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT 'ASP' calc_typ_cd
              ,'ACTL-BIOV' calc_mthd_cd
          FROM dual) x
 WHERE p.agency_typ_cd = 'MEDICARE' 
   AND p.prcss_typ_cd = 'MEDICARE_QTRLY'
;

-- Quarterly NFAMP
INSERT INTO bivv.prfl_calc_typ_t
(prfl_id, calc_typ_cd, calc_mthd_cd)
SELECT p.prfl_id
      ,x.calc_typ_cd
      ,x.calc_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT 'NFAMP' calc_typ_cd
              ,'ACTL-BIOV' calc_mthd_cd
          FROM dual) x
 WHERE p.agency_typ_cd = 'VA' 
   AND p.prcss_typ_cd = 'VA_QTRLY'
;

-- Annual NFAMP
INSERT INTO bivv.prfl_calc_typ_t
(prfl_id, calc_typ_cd, calc_mthd_cd)
SELECT p.prfl_id
      ,x.calc_typ_cd
      ,x.calc_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT 'NFAMP' calc_typ_cd
              ,'ACTL' calc_mthd_cd
          FROM dual) x
 WHERE p.agency_typ_cd = 'VA' 
   AND p.prcss_typ_cd = 'VA_ANNL'
;

COMMIT;

-- Annual NFAMP
INSERT INTO bivv.prfl_calc_typ_t
(prfl_id, calc_typ_cd, calc_mthd_cd)
SELECT p.prfl_id
      ,x.calc_typ_cd
      ,x.calc_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT 'FCP' calc_typ_cd
              ,'ACTL' calc_mthd_cd
          FROM dual) x
 WHERE p.agency_typ_cd = 'VA' 
   AND p.prcss_typ_cd = 'VA_ANNL'
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_calc_typ_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-07: Insert into bivv.prfl_co_t
-- Create profile company records
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_co_t;
CREATE TABLE bivv.prfl_co_t
    AS (SELECT p.prfl_id
              ,121 co_id
          FROM bivv.prfl_t p
       )
;

-- Grants
GRANT SELECT ON bivv.prfl_co_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-08: Insert into bivv.prfl_var_t
-- Create profile variable records
--   - Monthly AMP
--   - Quarterly AMP
--   - Quarterly BP
--   - Quarterly ASP
--   - Quarterly NFAMP
--   - Annual NFAMP
--   - Annual FCP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_var_t;

-- Monthly AMP
CREATE TABLE bivv.prfl_var_t
    AS (SELECT p.prfl_id
              ,p.agency_typ_cd
              ,'ADP' var_cd
              ,6 val_txt
              ,p.prcss_typ_cd
          FROM bivv.prfl_t p
         WHERE p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
        UNION ALL
        SELECT p.prfl_id
              ,p.agency_typ_cd
              ,'CDP' var_cd
              ,0.02 val_txt
              ,p.prcss_typ_cd
          FROM bivv.prfl_t p
         WHERE p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
        UNION ALL
        SELECT p.prfl_id
              ,p.agency_typ_cd
              ,'MAX_DPA_PCT' var_cd
              ,0.01 val_txt
              ,p.prcss_typ_cd
          FROM bivv.prfl_t p
         WHERE p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
        UNION ALL
        SELECT p.prfl_id
              ,p.agency_typ_cd
              ,'NTP' var_cd
              ,0.10 val_txt
              ,p.prcss_typ_cd
          FROM bivv.prfl_t p
         WHERE p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
        UNION ALL
        SELECT p.prfl_id
              ,p.agency_typ_cd
              ,'SO' var_cd
              ,0 val_txt
              ,p.prcss_typ_cd
          FROM bivv.prfl_t p
         WHERE p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
       )
;

-- Quarterly AMP/BP
INSERT INTO bivv.prfl_var_t
(prfl_id, agency_typ_cd, var_cd, val_txt, prcss_typ_cd)
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'ADP' var_cd
      ,6 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'BDP' var_cd
      ,6 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'CDP' var_cd
      ,.02 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'MAX_DPA_PCT' var_cd
      ,.016 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'NTP' var_cd
      ,0.10 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'PPAP' var_cd
      ,1 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'SO' var_cd
      ,0 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
;

COMMIT;


-- Quarterly ASP
INSERT INTO bivv.prfl_var_t
(prfl_id, agency_typ_cd, var_cd, val_txt, prcss_typ_cd)
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'ADP' var_cd
      ,3 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'MEDICARE'
   AND p.prcss_typ_cd = 'MEDICARE_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'APFDP' var_cd
      ,2 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'MEDICARE'
   AND p.prcss_typ_cd = 'MEDICARE_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'CDP' var_cd
      ,.02 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'MEDICARE'
   AND p.prcss_typ_cd = 'MEDICARE_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'MAX_DPA_PCT' var_cd
      ,.016 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'MEDICARE'
   AND p.prcss_typ_cd = 'MEDICARE_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'NTP' var_cd
      ,0.10 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'MEDICARE'
   AND p.prcss_typ_cd = 'MEDICARE_QTRLY'
;

COMMIT;

-- Quarterly NFAMP
INSERT INTO bivv.prfl_var_t
(prfl_id, agency_typ_cd, var_cd, val_txt, prcss_typ_cd)
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'NDP' var_cd
      ,2 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'SO' var_cd
      ,0 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'CDP' var_cd
      ,.02 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'MAX_DPA_PCT' var_cd
      ,.016 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_QTRLY'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'NTP' var_cd
      ,0.10 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_QTRLY'
;

COMMIT;

-- Annual NFAMP
INSERT INTO bivv.prfl_var_t
(prfl_id, agency_typ_cd, var_cd, val_txt, prcss_typ_cd)
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'NDP' var_cd
      ,2 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_ANNL'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'SO' var_cd
      ,0 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_ANNL'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'CDP' var_cd
      ,.02 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_ANNL'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'MAX_DPA_PCT' var_cd
      ,.016 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_ANNL'
UNION ALL
SELECT p.prfl_id
      ,p.agency_typ_cd
      ,'NTP' var_cd
      ,0.10 val_txt
      ,p.prcss_typ_cd
  FROM bivv.prfl_t p
 WHERE p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_ANNL'
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_var_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-09: Insert into bivv.prfl_prod_fmly_t
-- Create profile product family records
--   - Monthly AMP
--   - Quarterly AMP
--   - Quarterly BP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_prod_fmly_t;

-- Monthly AMP
CREATE TABLE bivv.prfl_prod_fmly_t
    AS (SELECT p.prfl_id
              ,x.ndc_lbl
              ,x.ndc_prod
          FROM bivv.prfl_t p
              ,(SELECT tim_per_cd
                      ,SUBSTR(ndc11,1,5) ndc_lbl
                      ,SUBSTR(ndc11,6,4) ndc_prod
                  FROM (SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_1 IS NOT NULL) OR
                                (x.amp_mth_1 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_2 IS NOT NULL) OR
                                (x.amp_mth_2 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_3 IS NOT NULL) OR
                                (x.amp_mth_3 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104') ) x
         WHERE p.tim_per_cd = x.tim_per_cd
           AND p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
       )
;

-- Quarterly AMP/BP
INSERT INTO bivv.prfl_prod_fmly_t
(prfl_id, ndc_lbl, ndc_prod)
SELECT p.prfl_id
      ,xx.ndc_lbl
      ,xx.ndc_prod
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND amp_qtrly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                  FROM (SELECT ndc11
                              ,year_qtr
                              ,COALESCE(x.bp_qtrly, x.ddr_bp, x.ddr_parent_bp) bp_amt
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND SUBSTR(x.ndc11,1,5) = '71104')
                 WHERE bp_amt IS NOT NULL)
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
;

-- Grants
GRANT SELECT ON bivv.prfl_prod_fmly_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-10: Insert into bivv.prfl_prod_t
-- Create profile product records
--   - Monthly AMP
--   - Quarterly AMP
--   - Quarterly BP
--   - Quarterly ASP
--   - Quarterly NFAMP
--   - Annual NFAMP
--   - Annual FCP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_prod_t;

-- Monthly AMP
CREATE TABLE bivv.prfl_prod_t
    AS (SELECT p.prfl_id
              ,x.ndc_lbl
              ,x.ndc_prod
              ,x.ndc_pckg
              ,'NONE' pri_whls_mthd_cd
              ,'COMPLETE' calc_stat_cd
              ,'N' shtdwn_ind
          FROM bivv.prfl_t p
              ,(SELECT tim_per_cd
                      ,SUBSTR(ndc11,1,5) ndc_lbl
                      ,SUBSTR(ndc11,6,4) ndc_prod
                      ,SUBSTR(ndc11,10,2) ndc_pckg
                  FROM (SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_1 IS NOT NULL) OR
                                (x.amp_mth_1 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_2 IS NOT NULL) OR
                                (x.amp_mth_2 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_3 IS NOT NULL) OR
                                (x.amp_mth_3 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104') ) x
         WHERE p.tim_per_cd = x.tim_per_cd
           AND p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
       )
;


-- Quarterly AMP/BP
INSERT INTO bivv.prfl_prod_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd, calc_stat_cd, shtdwn_ind)
SELECT p.prfl_id
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,'NONE' pri_whls_mthd_cd
      ,'COMPLETE' calc_stat_cd
      ,'N' shtdwn_ind
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND amp_qtrly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                  FROM (SELECT ndc11
                              ,year_qtr
                              ,COALESCE(x.bp_qtrly, x.ddr_bp, x.ddr_parent_bp) bp_amt
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND SUBSTR(x.ndc11,1,5) = '71104')
                 WHERE bp_amt IS NOT NULL)
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
;

COMMIT;

-- Quarterly ASP
INSERT INTO bivv.prfl_prod_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd, calc_stat_cd, shtdwn_ind)
SELECT p.prfl_id
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,'NONE' pri_whls_mthd_cd
      ,'COMPLETE' calc_stat_cd
      ,'N' shtdwn_ind
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.asp_qrtly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'MEDICARE'
   AND p.prcss_typ_cd = 'MEDICARE_QTRLY'
;

COMMIT;

-- Quarterly NFAMP
INSERT INTO bivv.prfl_prod_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd, calc_stat_cd, shtdwn_ind)
SELECT p.prfl_id
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,'NONE' pri_whls_mthd_cd
      ,'COMPLETE' calc_stat_cd
      ,'N' shtdwn_ind
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.nfamp_qrtly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_QTRLY'
;

COMMIT;

-- Annual NFAMP
INSERT INTO bivv.prfl_prod_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd, calc_stat_cd, shtdwn_ind)
SELECT p.prfl_id
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,'NONE' pri_whls_mthd_cd
      ,'COMPLETE' calc_stat_cd
      ,'N' shtdwn_ind
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) tim_per_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.nfamp_annual IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_ANNL'
;

COMMIT;

-- Annual FCP
INSERT INTO bivv.prfl_prod_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd, calc_stat_cd, shtdwn_ind)
SELECT p.prfl_id
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,'NONE' pri_whls_mthd_cd
      ,'COMPLETE' calc_stat_cd
      ,'N' shtdwn_ind
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) tim_per_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.fcp_annual IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_ANNL'
   AND NOT EXISTS (SELECT 'x'
                     FROM bivv.prfl_prod_t y
                    WHERE y.prfl_id = p.prfl_id
                      AND y.ndc_lbl = xx.ndc_lbl
                      AND y.ndc_prod = xx.ndc_prod
                      AND y.ndc_pckg = xx.ndc_pckg)
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_prod_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-11: Insert into bivv.prfl_calc_prod_fmly_t
-- Create profile calculation product family records
--   - Monthly AMP
--   - Quarterly AMP
--   - Quarterly BP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_calc_prod_fmly_t;

-- Quarterly AMP/BP
CREATE TABLE bivv.prfl_calc_prod_fmly_t
    AS (SELECT p.prfl_id
              ,'AMP' calc_typ_cd
              ,x.ndc_lbl
              ,x.ndc_prod
              ,'NONE' pri_whls_mthd_cd
          FROM bivv.prfl_t p
              ,(SELECT tim_per_cd
                      ,SUBSTR(ndc11,1,5) ndc_lbl
                      ,SUBSTR(ndc11,6,4) ndc_prod
                  FROM (SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_1 IS NOT NULL) OR
                                (x.amp_mth_1 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_2 IS NOT NULL) OR
                                (x.amp_mth_2 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_3 IS NOT NULL) OR
                                (x.amp_mth_3 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104') ) x
         WHERE p.tim_per_cd = x.tim_per_cd
           AND p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
       )
;


-- Quarterly AMP/BP
INSERT INTO bivv.prfl_calc_prod_fmly_t
(prfl_id, calc_typ_cd, ndc_lbl, ndc_prod, pri_whls_mthd_cd)
SELECT p.prfl_id
      ,xx.calc_typ_cd
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,'NONE' pri_whls_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,calc_typ_cd
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,'AMP' calc_typ_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND amp_qtrly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,'BP' calc_typ_cd
                  FROM (SELECT ndc11
                              ,year_qtr
                              ,COALESCE(x.bp_qtrly, x.ddr_bp, x.ddr_parent_bp) bp_amt
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND SUBSTR(x.ndc11,1,5) = '71104')
                 WHERE bp_amt IS NOT NULL)
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_calc_prod_fmly_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

--------------------------------------------------------------------------------
-- P-12: Insert into bivv.prfl_calc_prod_t
-- Create profile calculation product records
--   - Monthly AMP
--   - Quarterly AMP
--   - Quarterly BP
--   - Quarterly ASP
--   - Quarterly NFAMP
--   - Annual NFAMP
--   - Annual FCP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_calc_prod_t;

CREATE TABLE bivv.prfl_calc_prod_t
(PRFL_ID NUMBER
,CALC_TYP_CD VARCHAR2(20)
,NDC_LBL VARCHAR2(5)
,NDC_PROD VARCHAR2(4)
,NDC_PCKG VARCHAR2(2)
,PRI_WHLS_MTHD_CD VARCHAR2(12)
)
;

-- Monthly AMP
INSERT INTO bivv.prfl_calc_prod_t
(prfl_id, calc_typ_cd,  ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd)
SELECT p.prfl_id
      ,'AMP' calc_typ_cd
      ,x.ndc_lbl
      ,x.ndc_prod
      ,x.ndc_pckg
      ,'NONE' pri_whls_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
          FROM (SELECT x.ndc11
                      ,TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_1 IS NOT NULL) OR
                        (x.amp_mth_1 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT x.ndc11
                      ,TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_2 IS NOT NULL) OR
                        (x.amp_mth_2 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT x.ndc11
                      ,TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_3 IS NOT NULL) OR
                        (x.amp_mth_3 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104') ) x
 WHERE p.tim_per_cd = x.tim_per_cd
   AND p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_MTHLY'
;

COMMIT;

-- Quarterly AMP/BP
INSERT INTO bivv.prfl_calc_prod_t
(prfl_id, calc_typ_cd,  ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd)
SELECT p.prfl_id
      ,xx.calc_typ_cd
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,'NONE' pri_whls_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,calc_typ_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,'AMP' calc_typ_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND amp_qtrly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,'BP' calc_typ_cd
                  FROM (SELECT ndc11
                              ,year_qtr
                              ,COALESCE(x.bp_qtrly, x.ddr_bp, x.ddr_parent_bp) bp_amt
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND SUBSTR(x.ndc11,1,5) = '71104')
                 WHERE bp_amt IS NOT NULL)
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
;

COMMIT;

-- Quarterly ASP
INSERT INTO bivv.prfl_calc_prod_t
(prfl_id, calc_typ_cd,  ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd)
SELECT p.prfl_id
      ,xx.calc_typ_cd
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,'NONE' pri_whls_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,calc_typ_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,'ASP' calc_typ_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.asp_qrtly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'MEDICARE'
   AND p.prcss_typ_cd = 'MEDICARE_QTRLY'
;

COMMIT;

-- Quarterly NFAMP
INSERT INTO bivv.prfl_calc_prod_t
(prfl_id, calc_typ_cd,  ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd)
SELECT p.prfl_id
      ,xx.calc_typ_cd
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,'NONE' pri_whls_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
              ,calc_typ_cd
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,'NFAMP' calc_typ_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.nfamp_qrtly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_QTRLY'
;

COMMIT;

-- Annual NFAMP
INSERT INTO bivv.prfl_calc_prod_t
(prfl_id, calc_typ_cd,  ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd)
SELECT p.prfl_id
      ,xx.calc_typ_cd
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,'NONE' pri_whls_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
              ,calc_typ_cd
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) tim_per_cd
                               ,'NFAMP' calc_typ_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.nfamp_annual IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_ANNL'
;

COMMIT;

-- Annual FCP
INSERT INTO bivv.prfl_calc_prod_t
(prfl_id, calc_typ_cd,  ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd)
SELECT p.prfl_id
      ,xx.calc_typ_cd
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,'NONE' pri_whls_mthd_cd
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
              ,calc_typ_cd
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) tim_per_cd
                               ,'FCP' calc_typ_cd
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.fcp_annual IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_ANNL'
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_calc_prod_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

-------------------------------------------------------------------------------
-- P-13: Insert into bivv.prfl_prod_fmly_calc_t
-- Create profile product family calculation results records
--   - Monthly AMP
--   - Quarterly AMP
--   - Quarterly BP
--------------------------------------------------------------------------------


DROP TABLE bivv.prfl_prod_fmly_calc_t;

-- Monthly AMP
CREATE TABLE bivv.prfl_prod_fmly_calc_t
    AS (SELECT p.prfl_id
              ,x.ndc_lbl
              ,x.ndc_prod
              ,'AMP' calc_typ_cd
              ,'AMP' comp_typ_cd
              ,x.calc_amt
          FROM bivv.prfl_t p
              ,(SELECT tim_per_cd
                      ,SUBSTR(ndc11,1,5) ndc_lbl
                      ,SUBSTR(ndc11,6,4) ndc_prod
                      ,calc_amt
                  FROM (SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                              ,x.amp_mth_1 calc_amt
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_1 IS NOT NULL) OR
                                (x.amp_mth_1 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                              ,x.amp_mth_2 calc_amt
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_2 IS NOT NULL) OR
                                (x.amp_mth_2 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104'
                        UNION
                        SELECT x.ndc11
                              ,TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                              ,x.amp_mth_3 calc_amt
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND ((x.amp_mth_3 IS NOT NULL) OR
                                (x.amp_mth_3 > 0))
                           AND SUBSTR(x.ndc11,1,5) = '71104') ) x
         WHERE p.tim_per_cd = x.tim_per_cd
           AND p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_MTHLY'
       )
;

-- Quarterly AMP/BP
INSERT INTO bivv.prfl_prod_fmly_calc_t
(prfl_id, ndc_lbl, ndc_prod, calc_typ_cd, comp_typ_cd, calc_amt)
SELECT p.prfl_id
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.calc_typ_cd
      ,xx.comp_typ_cd
      ,xx.calc_amt
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,calc_typ_cd
              ,comp_typ_cd
              ,calc_amt
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,'AMP' calc_typ_cd
                               ,'AMP' comp_typ_cd
                               ,amp_qtrly calc_amt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND amp_qtrly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,'BP' calc_typ_cd
                               ,'BP' comp_typ_cd
                               ,bp_amt calc_amt
                  FROM (SELECT ndc11
                              ,year_qtr
                              ,COALESCE(x.bp_qtrly, x.ddr_bp, x.ddr_parent_bp) bp_amt
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND SUBSTR(x.ndc11,1,5) = '71104')
                 WHERE bp_amt IS NOT NULL)
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_prod_fmly_calc_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

-------------------------------------------------------------------------------
-- P-14: Insert into bivv.prfl_prod_calc_t
-- Create profile product calculation results records
--   - Monthly AMP
--   - Quarterly AMP
--   - Quarterly BP
--   - Quarterly ASP
--   - Quarterly NFAMP
--   - Annual NFAMP
--   - Annual FCP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_prod_calc_t;

CREATE TABLE bivv.prfl_prod_calc_t
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
INSERT INTO bivv.prfl_prod_calc_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, comp_typ_cd, calc_amt)
SELECT p.prfl_id
      ,x.ndc_lbl
      ,x.ndc_prod
      ,x.ndc_pckg
      ,'AMP' calc_typ_cd
      ,'AMP' comp_typ_cd
      ,x.calc_amt
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
              ,calc_amt
          FROM (SELECT x.ndc11
                      ,TO_CHAR( x.amp_mth_1_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_1_strt_dt,'"M"MM') tim_per_cd
                      ,x.amp_mth_1 calc_amt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_1 IS NOT NULL) OR
                        (x.amp_mth_1 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT x.ndc11
                      ,TO_CHAR( x.amp_mth_2_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_2_strt_dt,'"M"MM') tim_per_cd
                      ,x.amp_mth_2 calc_amt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_2 IS NOT NULL) OR
                        (x.amp_mth_2 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT x.ndc11
                      ,TO_CHAR( x.amp_mth_3_strt_dt,'YYYY"Q"Q') || TO_CHAR( x.amp_mth_3_strt_dt,'"M"MM') tim_per_cd
                      ,x.amp_mth_3 calc_amt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND ((x.amp_mth_3 IS NOT NULL) OR
                        (x.amp_mth_3 > 0))
                   AND SUBSTR(x.ndc11,1,5) = '71104') ) x
 WHERE p.tim_per_cd = x.tim_per_cd
   AND p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_MTHLY'
;

COMMIT;

-- Quarterly AMP/BP
INSERT INTO bivv.prfl_prod_calc_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, comp_typ_cd, calc_amt)
SELECT p.prfl_id
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,xx.calc_typ_cd
      ,xx.comp_typ_cd
      ,xx.calc_amt
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
              ,calc_typ_cd
              ,comp_typ_cd
              ,calc_amt
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,'AMP' calc_typ_cd
                               ,'AMP' comp_typ_cd
                               ,amp_qtrly calc_amt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND amp_qtrly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104'
                UNION
                SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,'BP' calc_typ_cd
                               ,'BP' comp_typ_cd
                               ,bp_amt calc_amt
                  FROM (SELECT ndc11
                              ,year_qtr
                              ,COALESCE(x.bp_qtrly, x.ddr_bp, x.ddr_parent_bp) bp_amt
                          FROM bivv.ic_pricing_t x
                         WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                           AND SUBSTR(x.ndc11,1,5) = '71104')
                 WHERE bp_amt IS NOT NULL)
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'MEDICAID'
   AND p.prcss_typ_cd = 'MED_QTRLY'
;

COMMIT;


-- Quarterly ASP
INSERT INTO bivv.prfl_prod_calc_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, comp_typ_cd, calc_amt)
SELECT p.prfl_id
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,xx.calc_typ_cd
      ,xx.comp_typ_cd
      ,xx.calc_amt
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
              ,calc_typ_cd
              ,comp_typ_cd
              ,calc_amt
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,'ASP' calc_typ_cd
                               ,'ASP' comp_typ_cd
                               ,x.asp_qrtly calc_amt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.asp_qrtly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'MEDICARE'
   AND p.prcss_typ_cd = 'MEDICARE_QTRLY'
;

COMMIT;

-- Quarterly NFAMP
INSERT INTO bivv.prfl_prod_calc_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, comp_typ_cd, calc_amt)
SELECT p.prfl_id
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,xx.calc_typ_cd
      ,xx.comp_typ_cd
      ,xx.calc_amt
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
              ,calc_typ_cd
              ,comp_typ_cd
              ,calc_amt
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                               ,'NFAMP' calc_typ_cd
                               ,'NFAMP' comp_typ_cd
                               ,x.nfamp_qrtly calc_amt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.nfamp_qrtly IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_QTRLY'
;

COMMIT;

-- Annual NFAMP
INSERT INTO bivv.prfl_prod_calc_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, comp_typ_cd, calc_amt)
SELECT p.prfl_id
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,xx.calc_typ_cd
      ,xx.comp_typ_cd
      ,xx.calc_amt
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
              ,calc_typ_cd
              ,comp_typ_cd
              ,calc_amt
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) tim_per_cd
                               ,'NFAMP' calc_typ_cd
                               ,'NFAMP' comp_typ_cd
                               ,x.nfamp_annual calc_amt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.nfamp_annual IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_ANNL'
;

COMMIT;

-- Annual FCP
INSERT INTO bivv.prfl_prod_calc_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, comp_typ_cd, calc_amt)
SELECT p.prfl_id
      ,xx.ndc_lbl
      ,xx.ndc_prod
      ,xx.ndc_pckg
      ,xx.calc_typ_cd
      ,xx.comp_typ_cd
      ,xx.calc_amt
  FROM bivv.prfl_t p
      ,(SELECT tim_per_cd
              ,SUBSTR(ndc11,1,5) ndc_lbl
              ,SUBSTR(ndc11,6,4) ndc_prod
              ,SUBSTR(ndc11,10,2) ndc_pckg
              ,calc_typ_cd
              ,comp_typ_cd
              ,calc_amt
          FROM (SELECT DISTINCT ndc11
                               ,SUBSTR(year_qtr,1,4) tim_per_cd
                               ,'FCP' calc_typ_cd
                               ,'FCP' comp_typ_cd
                               ,x.fcp_annual calc_amt
                  FROM bivv.ic_pricing_t x
                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                   AND x.fcp_annual IS NOT NULL
                   AND SUBSTR(x.ndc11,1,5) = '71104')
       ) xx
 WHERE p.tim_per_cd = xx.tim_per_cd
   AND p.agency_typ_cd = 'VA'
   AND p.prcss_typ_cd = 'VA_ANNL'
;

COMMIT;

-- Grants
GRANT SELECT ON bivv.prfl_prod_calc_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;


-------------------------------------------------------------------------------
-- P-15: Insert into bivv.prfl_prod_bp_pnt_t
-- Create profile product calculation results records
--   - Quarterly BP
--------------------------------------------------------------------------------

DROP TABLE bivv.prfl_prod_bp_pnt_t;

CREATE TABLE bivv.prfl_prod_bp_pnt_t
    AS (SELECT p.prfl_id
              ,xx.ndc_lbl
              ,xx.ndc_prod
              ,'RM' bp_mthd_typ_cd 
              ,xx.calc_amt price_amt
              ,1 occurs_cnt
              ,'Y' bp_ind
              ,'Y' manual_add_ind
          FROM bivv.prfl_t p
              ,(SELECT tim_per_cd
                      ,SUBSTR(ndc11,1,5) ndc_lbl
                      ,SUBSTR(ndc11,6,4) ndc_prod
                      ,calc_amt
                  FROM (SELECT DISTINCT ndc11
                                       ,SUBSTR(year_qtr,1,4) || 'Q' || SUBSTR(year_qtr,5,1) tim_per_cd
                                       ,bp_amt calc_amt
                          FROM (SELECT ndc11
                                      ,year_qtr
                                      ,COALESCE(x.bp_qtrly, x.ddr_bp, x.ddr_parent_bp) bp_amt
                                  FROM bivv.ic_pricing_t x
                                 WHERE TO_NUMBER(x.base_amp_qtr) <= TO_NUMBER(x.year_qtr)
                                   AND SUBSTR(x.ndc11,1,5) = '71104')
                         WHERE bp_amt IS NOT NULL)
               ) xx
         WHERE p.tim_per_cd = xx.tim_per_cd
           AND p.agency_typ_cd = 'MEDICAID'
           AND p.prcss_typ_cd = 'MED_QTRLY'
       )
;

-- Grants
GRANT SELECT ON bivv.prfl_prod_bp_pnt_t TO hcrs_connect, hcrs_crm_select, hcrs_data_entry, hcrs_manager, hcrs_select, hcrs_supervisor, hcrs;

-- Commit changes
COMMIT;

-- What time did this end running?
SELECT SYSDATE FROM dual;
