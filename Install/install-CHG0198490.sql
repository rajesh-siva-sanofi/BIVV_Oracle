-- Setup Environment
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
TIMING START entire_script

-- Turn on the audit report.
--SPOOL C:\temp\CHG0198490_hcrsd.log

-- Alter Date and Time Format
ALTER SESSION SET NLS_DATE_FORMAT = 'MM/DD/YYYY HH24:MI:SS';
COMMIT;

-- In what database instance is this run?
SELECT * FROM global_name;

-- What time did this start running?
SELECT SYSDATE FROM dual;

------------------------------------------------------------------------------------
-- ITS-CHG0198490: GPCS/HCRS: Add Biogen products to Bioverative NFAMP profiles
------------------------------------------------------------------------------------
------------------------------------------------------------------------

-- ========================================
-- Step 1: Display Table Data Before The Change
-- ========================================

-- ========================================
-- hcrs.prfl_prod_t
-- ========================================

SELECT ndc_lbl
      ,ndc_prod
      ,ndc_pckg
      ,COUNT(DISTINCT prfl_id) prfl_id_count
  FROM hcrs.prfl_prod_t x
 WHERE x.prfl_id IN (SELECT prfl_id
                       FROM hcrs.prfl_t
                      WHERE prfl_nm LIKE '%Bioverativ LOADED'
                        AND agency_typ_cd = 'VA'
                        AND prcss_typ_cd IN ('VA_QTRLY','VA_ANNL'))
   AND x.ndc_lbl IN ('71104','64406')
GROUP BY ndc_lbl
        ,ndc_prod
        ,ndc_pckg
ORDER BY ndc_lbl
        ,ndc_prod
        ,ndc_pckg
;

-- =================================================
-- hcrs.prfl_calc_prod_t
-- =================================================

SELECT ndc_lbl
      ,ndc_prod
      ,ndc_pckg
      ,COUNT(DISTINCT prfl_id) prfl_id_count
  FROM hcrs.prfl_calc_prod_t  x
 WHERE x.prfl_id IN (SELECT prfl_id
                       FROM hcrs.prfl_t
                      WHERE prfl_nm LIKE '%Bioverativ LOADED'
                        AND agency_typ_cd = 'VA'
                        AND prcss_typ_cd IN ('VA_QTRLY','VA_ANNL'))
   AND x.ndc_lbl IN ('71104','64406')
   AND x.calc_typ_cd = 'NFAMP'
GROUP BY ndc_lbl
        ,ndc_prod
        ,ndc_pckg
ORDER BY ndc_lbl
        ,ndc_prod
        ,ndc_pckg
;

-- ===================================
-- hcrs.prfl_prod_calc_t
-- ===================================

SELECT ndc_lbl
      ,ndc_prod
      ,ndc_pckg
      ,COUNT(DISTINCT prfl_id) prfl_id_count
  FROM hcrs.prfl_prod_calc_t x
 WHERE x.prfl_id IN (SELECT prfl_id
                       FROM hcrs.prfl_t
                      WHERE prfl_nm LIKE '%Bioverativ LOADED'
                        AND agency_typ_cd = 'VA'
                        AND prcss_typ_cd IN ('VA_QTRLY','VA_ANNL'))
   AND x.ndc_lbl IN ('71104','64406')
   AND x.calc_typ_cd = 'NFAMP'
   AND x.comp_typ_cd = 'NFAMP'
GROUP BY ndc_lbl
        ,ndc_prod
        ,ndc_pckg
ORDER BY ndc_lbl
        ,ndc_prod
        ,ndc_pckg
;


-- ========================================
-- Step 2: Insert Biogen Products for NFAMP
-- ========================================

-- ========================================
-- hcrs.prfl_prod_t
-- ========================================

INSERT INTO hcrs.prfl_prod_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd, calc_stat_cd, shtdwn_ind)
SELECT prfl_id
      ,'64406' ndc_lbl
      ,ndc_prod
      ,ndc_pckg
      ,pri_whls_mthd_cd
      ,calc_stat_cd
      ,shtdwn_ind
  FROM hcrs.prfl_prod_t x
 WHERE x.prfl_id IN (SELECT prfl_id
                       FROM hcrs.prfl_t
                      WHERE prfl_nm LIKE '%Bioverativ LOADED'
                        AND agency_typ_cd = 'VA'
                        AND prcss_typ_cd IN ('VA_QTRLY','VA_ANNL'))
   AND x.ndc_lbl = '71104'
;

-- =================================================
-- hcrs.prfl_calc_prod_t
-- =================================================

INSERT INTO hcrs.prfl_calc_prod_t
(prfl_id, calc_typ_cd,  ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd)
SELECT prfl_id
      ,calc_typ_cd
      ,'64406' ndc_lbl
      ,ndc_prod
      ,ndc_pckg
      ,pri_whls_mthd_cd
  FROM hcrs.prfl_calc_prod_t  x
 WHERE x.prfl_id IN (SELECT prfl_id
                       FROM hcrs.prfl_t
                      WHERE prfl_nm LIKE '%Bioverativ LOADED'
                        AND agency_typ_cd = 'VA'
                        AND prcss_typ_cd IN ('VA_QTRLY','VA_ANNL'))
   AND x.ndc_lbl = '71104'
   AND x.calc_typ_cd = 'NFAMP'
;

-- ===================================
-- hcrs.prfl_prod_calc_t
-- ===================================

INSERT INTO hcrs.prfl_prod_calc_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, comp_typ_cd, calc_amt)
SELECT prfl_id
      ,'64406' ndc_lbl
      ,ndc_prod
      ,ndc_pckg
      ,calc_typ_cd
      ,comp_typ_cd
      ,calc_amt
  FROM hcrs.prfl_prod_calc_t x
 WHERE x.prfl_id IN (SELECT prfl_id
                       FROM hcrs.prfl_t
                      WHERE prfl_nm LIKE '%Bioverativ LOADED'
                        AND agency_typ_cd = 'VA'
                        AND prcss_typ_cd IN ('VA_QTRLY','VA_ANNL'))
   AND x.ndc_lbl = '71104'
   AND x.calc_typ_cd = 'NFAMP'
   AND x.comp_typ_cd = 'NFAMP'
;


-- ========================================
-- Step 3: Display Table Data After The Change
-- ========================================

-- ========================================
-- hcrs.prfl_prod_t
-- ========================================

SELECT ndc_lbl
      ,ndc_prod
      ,ndc_pckg
      ,COUNT(DISTINCT prfl_id) prfl_id_count
  FROM hcrs.prfl_prod_t x
 WHERE x.prfl_id IN (SELECT prfl_id
                       FROM hcrs.prfl_t
                      WHERE prfl_nm LIKE '%Bioverativ LOADED'
                        AND agency_typ_cd = 'VA'
                        AND prcss_typ_cd IN ('VA_QTRLY','VA_ANNL'))
   AND x.ndc_lbl IN ('71104','64406')
GROUP BY ndc_lbl
        ,ndc_prod
        ,ndc_pckg
ORDER BY ndc_lbl
        ,ndc_prod
        ,ndc_pckg
;

-- =================================================
-- hcrs.prfl_calc_prod_t
-- =================================================

SELECT ndc_lbl
      ,ndc_prod
      ,ndc_pckg
      ,COUNT(DISTINCT prfl_id) prfl_id_count
  FROM hcrs.prfl_calc_prod_t  x
 WHERE x.prfl_id IN (SELECT prfl_id
                       FROM hcrs.prfl_t
                      WHERE prfl_nm LIKE '%Bioverativ LOADED'
                        AND agency_typ_cd = 'VA'
                        AND prcss_typ_cd IN ('VA_QTRLY','VA_ANNL'))
   AND x.ndc_lbl IN ('71104','64406')
   AND x.calc_typ_cd = 'NFAMP'
GROUP BY ndc_lbl
        ,ndc_prod
        ,ndc_pckg
ORDER BY ndc_lbl
        ,ndc_prod
        ,ndc_pckg
;

-- ===================================
-- hcrs.prfl_prod_calc_t
-- ===================================

SELECT ndc_lbl
      ,ndc_prod
      ,ndc_pckg
      ,COUNT(DISTINCT prfl_id) prfl_id_count
  FROM hcrs.prfl_prod_calc_t x
 WHERE x.prfl_id IN (SELECT prfl_id
                       FROM hcrs.prfl_t
                      WHERE prfl_nm LIKE '%Bioverativ LOADED'
                        AND agency_typ_cd = 'VA'
                        AND prcss_typ_cd IN ('VA_QTRLY','VA_ANNL'))
   AND x.ndc_lbl IN ('71104','64406')
   AND x.calc_typ_cd = 'NFAMP'
   AND x.comp_typ_cd = 'NFAMP'
GROUP BY ndc_lbl
        ,ndc_prod
        ,ndc_pckg
ORDER BY ndc_lbl
        ,ndc_prod
        ,ndc_pckg
;

-- Commit changes
COMMIT;
   
-- What time did this end running?
SELECT SYSDATE FROM dual;

-- Turn off the audit report. 
--SPOOL OFF
