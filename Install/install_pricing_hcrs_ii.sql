-- ============================================================================================
-- File		: Insert Biogen/Bioverativ Pricing Data into HCRS
--
-- Author	: John Tronoski, (IntegriChain)
-- Created	: February, 2021
--
-- Modified 	: 
--		  ...JTronoski (IntegriChain) 02.09.2021
--
-- Purpose  	: This SQL will be used to load the Biogen and Bioverativ products from the 
--                IntegriChain FLEX tables to the BIVV Staging Tables.
--
--                The following steps will be executed:
--                  1. Display Biogen and Bioverativ pricing in the HCRS Pricing tables before the script runs
--                  2. Insert Biogen and Bioverativ pricing into hcrs.prfl_t
--                  3. Insert Biogen and Bioverativ pricing into hcrs.prfl_calc_typ_t
--                  4. Insert Biogen and Bioverativ pricing into hcrs.prfl_co_t
--                  5. Insert Biogen and Bioverativ pricing into hcrs.prfl_var_t
--                  6. Insert Biogen and Bioverativ pricing into hcrs.prfl_prod_fmly_t
--                  7. Insert Biogen and Bioverativ pricing into hcrs.prfl_prod_t
--                  8. Insert Biogen and Bioverativ pricing into hcrs.prfl_calc_prod_fmly_t
--                  9. Insert Biogen and Bioverativ pricing into hcrs.prfl_calc_prod_t
--                 10. Insert Biogen and Bioverativ pricing into hcrs.prfl_prod_fmly_calc_t
--                 11. Insert Biogen and Bioverativ pricing into hcrs.prfl_prod_calc_t
--                 12. Display Biogen and Bioverativ pricing in the HCRS Pricing tables after the script runs
--
-- Parameters  	: N/A
--
-- Status  	: N/A
--
-- Information 	: This script should be run in the HCRS Instance
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
-- Show affected records before change
--------------------------------------------------------------------------------

SELECT *
  FROM hcrs.prfl_t x
 WHERE prfl_nm LIKE '%Bioverativ LOADED'
   AND EXISTS (SELECT 'x'
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY prfl_id
;

SELECT *
  FROM hcrs.prfl_calc_typ_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY prfl_id
;

SELECT *
  FROM hcrs.prfl_co_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY prfl_id
;

SELECT *
  FROM hcrs.prfl_var_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 1,2,3
;

SELECT *
  FROM hcrs.prfl_prod_fmly_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 1,2,3
;

SELECT *
  FROM hcrs.prfl_prod_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 4,1,2,3
;

SELECT *
  FROM hcrs.prfl_calc_prod_fmly_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 1,3,4
;

SELECT *
  FROM hcrs.prfl_calc_prod_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 1,3,4,5
;

SELECT *
  FROM hcrs.prfl_prod_fmly_calc_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 2,1,3
;

SELECT *
  FROM hcrs.prfl_prod_calc_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 4,1,2,3
;

--------------------------------------------------------------------------------
-- P-03: Insert Bioverativ profiles into hcrs.prfl_t
--------------------------------------------------------------------------------

INSERT INTO hcrs.prfl_t
(prfl_id, snpsht_id, prfl_stat_cd, agency_typ_cd, tim_per_cd, prcss_typ_cd
,prfl_nm, begn_dt, end_dt, copy_hist_ind, prelim_ind, mtrx_ind)
SELECT prfl_id, snpsht_id, prfl_stat_cd, agency_typ_cd, tim_per_cd, prcss_typ_cd
      ,prfl_nm, begn_dt, end_dt, copy_hist_ind, prelim_ind, mtrx_ind
  FROM bivv.prfl_t_ii
;

--------------------------------------------------------------------------------
-- This routine will increase the sequence for hcrs.prfl_t so that the value of
-- the sequence is equal to the last prfl_id in hcrs.prfl_t.
--------------------------------------------------------------------------------

DECLARE
   v_hcrs_cnt_start NUMBER := 0;
   v_bivv_cnt_start NUMBER := 0;
   v_bivv_cnt_end   NUMBER := 0;
   v_cnt            NUMBER := 0;

BEGIN
  
   SELECT MAX(prfl_id) 
     INTO v_hcrs_cnt_start
     FROM hcrs.prfl_t;

   SELECT MIN(prfl_id) 
     INTO v_bivv_cnt_start
     FROM bivv.prfl_t_ii;

   SELECT MAX(prfl_id) 
     INTO v_bivv_cnt_end
     FROM bivv.prfl_t_ii;

   dbms_output.put_line( 'HCRS PRFL_ID Start: ' || v_hcrs_cnt_start);
   dbms_output.put_line( 'BIVV PRFL_ID Start: ' || v_bivv_cnt_start);
   dbms_output.put_line( 'BIVV PRFL_ID End: ' || v_bivv_cnt_end);
   
   LOOP
      EXIT WHEN v_cnt = v_bivv_cnt_end;
      SELECT hcrs.prfl_s.nextval INTO v_cnt FROM dual;
   END LOOP;
   dbms_output.put_line( 'Final HCRS PRFL_T Sequence Value: ' || v_cnt);

END;
/

--------------------------------------------------------------------------------
-- P-04: Insert Bioverativ Calculation Types into hcrs.prfl_calc_typ_t
-- Create profile calculation records
--------------------------------------------------------------------------------

INSERT INTO hcrs.prfl_calc_typ_t
(prfl_id, calc_typ_cd, calc_mthd_cd)
SELECT prfl_id, TRIM(calc_typ_cd), TRIM(calc_mthd_cd)
  FROM bivv.prfl_calc_typ_t_ii
;

--------------------------------------------------------------------------------
-- P-05: Insert Bioverativ profiles into hcrs.prfl_co_t
-- Create profile company records
--------------------------------------------------------------------------------

INSERT INTO hcrs.prfl_co_t
(prfl_id, co_id)
SELECT prfl_id, co_id
  FROM bivv.prfl_co_t_ii
;

--------------------------------------------------------------------------------
-- P-06: Insert Bioverativ varaibles into hcrs.prfl_var_t
-- Create profile variable records
--------------------------------------------------------------------------------

INSERT INTO hcrs.prfl_var_t
(prfl_id, agency_typ_cd, var_cd, val_txt, prcss_typ_cd)
SELECT prfl_id, agency_typ_cd, var_cd, val_txt, prcss_typ_cd
  FROM bivv.prfl_var_t_ii 
;

--------------------------------------------------------------------------------
-- P-07: Insert Bioverativ data into hcrs.prfl_prod_fmly_t
-- Create profile product family records
--------------------------------------------------------------------------------

INSERT INTO hcrs.prfl_prod_fmly_t
(prfl_id, ndc_lbl, ndc_prod)
SELECT prfl_id, ndc_lbl, ndc_prod
  FROM bivv.prfl_prod_fmly_t_ii
;

--------------------------------------------------------------------------------
-- P-08: Insert Bioverativ data into hcrs.prfl_prod_t
-- Create profile product records
--------------------------------------------------------------------------------

INSERT INTO hcrs.prfl_prod_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd, calc_stat_cd, shtdwn_ind)
SELECT prfl_id, ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd, calc_stat_cd, shtdwn_ind
  FROM bivv.prfl_prod_t_ii
;

--------------------------------------------------------------------------------
-- P-09: Insert Bioverativ data into hcrs.prfl_calc_prod_fmly_t
-- Create profile calculation product family records
--------------------------------------------------------------------------------

INSERT INTO hcrs.prfl_calc_prod_fmly_t
(prfl_id, calc_typ_cd, ndc_lbl, ndc_prod, pri_whls_mthd_cd)
SELECT prfl_id, TRIM(calc_typ_cd), ndc_lbl, ndc_prod, pri_whls_mthd_cd
  FROM bivv.prfl_calc_prod_fmly_t_ii
;

--------------------------------------------------------------------------------
-- P-10: Insert Bioverativ data into hcrs.prfl_calc_prod_t
-- Create profile calculation product records
--------------------------------------------------------------------------------

INSERT INTO hcrs.prfl_calc_prod_t
(prfl_id, calc_typ_cd,  ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd)
SELECT prfl_id, TRIM(calc_typ_cd), ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd
  FROM bivv.prfl_calc_prod_t_ii
;

--------------------------------------------------------------------------------
-- P-11: Insert Bioverativ data into hcrs.prfl_prod_fmly_calc_t
-- Create profile product family calculation results records
--------------------------------------------------------------------------------

INSERT INTO hcrs.prfl_prod_fmly_calc_t
(prfl_id, ndc_lbl, ndc_prod, calc_typ_cd, comp_typ_cd, calc_amt)
SELECT prfl_id, ndc_lbl, ndc_prod, TRIM(calc_typ_cd), TRIM(comp_typ_cd), calc_amt
  FROM bivv.prfl_prod_fmly_calc_t_ii
;


--------------------------------------------------------------------------------
-- P-12: Insert Bioverativ data into hcrs.prfl_prod_calc_t
-- Create profile product calculation results records
--------------------------------------------------------------------------------

INSERT INTO hcrs.prfl_prod_calc_t
(prfl_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, comp_typ_cd, calc_amt)
SELECT prfl_id, ndc_lbl, ndc_prod, ndc_pckg, TRIM(calc_typ_cd), TRIM(comp_typ_cd), calc_amt
  FROM bivv.prfl_prod_calc_t_ii
;


--------------------------------------------------------------------------------
-- Show affected records after change
--------------------------------------------------------------------------------

SELECT *
  FROM hcrs.prfl_t x
 WHERE prfl_nm LIKE '%Bioverativ LOADED'
   AND EXISTS (SELECT 'x'
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY prfl_id
;

SELECT *
  FROM hcrs.prfl_calc_typ_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY prfl_id
;

SELECT *
  FROM hcrs.prfl_co_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY prfl_id
;

SELECT *
  FROM hcrs.prfl_var_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 1,2,3
;

SELECT *
  FROM hcrs.prfl_prod_fmly_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 1,2,3
;

SELECT *
  FROM hcrs.prfl_prod_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 4,1,2,3
;

SELECT *
  FROM hcrs.prfl_calc_prod_fmly_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 1,3,4
;

SELECT *
  FROM hcrs.prfl_calc_prod_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 1,3,4,5
;

SELECT *
  FROM hcrs.prfl_prod_fmly_calc_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 2,1,3
;

SELECT *
  FROM hcrs.prfl_prod_calc_t x
 WHERE EXISTS (SELECT prfl_id
                 FROM bivv.prfl_t_ii xx
                WHERE xx.prfl_id = x.prfl_id)
ORDER BY 4,1,2,3
;

-- Commit changes
COMMIT;

-- What time did this end running?
SELECT SYSDATE FROM dual;
