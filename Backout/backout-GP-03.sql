-- Setup Environment
SET PAGESIZE 50000
SET LINESIZE 10000
SET ECHO ON
SET TAB OFF
SET FEEDBACK ON
SET DEFINE OFF
SET TRIMOUT ON
SET TRIMSPOOL ON
SET SERVEROUTPUT ON SIZE UNLIMITED FORMAT WRAPPED
SET SQLBLANKLINES ON
SET ARRAYSIZE 5000
SET TIMING ON
SET APPINFO ON
TIMING START entire_script

-- Alter Date and Time Format
ALTER SESSION SET NLS_DATE_FORMAT = 'MM/DD/YYYY HH24:MI:SS';
COMMIT;

-- In what database instance is this run?
SELECT * FROM global_name;

-- What time did this start running?
SELECT SYSDATE FROM dual;


--------------------------------------------------------------------------------
-- 04-01: Remove BIVV transaction adjustment linking codes
--------------------------------------------------------------------------------
SELECT *
  FROM hcrs.trans_adj_t t
 ORDER BY 1;

-- Bioverativ Line item rollup
-- Bioverativ adjustment
DELETE
   FROM hcrs.trans_adj_t t
  WHERE t.trans_adj_cd IN ('BIVV_ROLLUP', 'BIVV_ADJ');

SELECT *
  FROM hcrs.trans_adj_t t
 ORDER BY 1;


--------------------------------------------------------------------------------
-- 04-02: Remove Sales Exclusion Codes
--------------------------------------------------------------------------------
SELECT *
  FROM hcrs.cd_t t
 WHERE t.cd_typ_cd = 'SX'
 ORDER BY 1;

DELETE
  FROM hcrs.cd_t t
 WHERE t.cd_typ_cd = 'SX';

SELECT *
  FROM hcrs.cd_t t
 WHERE t.cd_typ_cd = 'SX'
 ORDER BY 1;

SELECT *
  FROM hcrs.cd_typ_t t
 ORDER BY 1;

DELETE
  FROM hcrs.cd_typ_t t
 WHERE t.cd_typ_cd = 'SX';

SELECT *
  FROM hcrs.cd_typ_t t
 ORDER BY 1;


--------------------------------------------------------------------------------
-- 04-03: Restore Sales Exclusion Views
--------------------------------------------------------------------------------
@@nom_excl_v.sql
@@fe_sls_excl_v.sql


--------------------------------------------------------------------------------
-- 04-04: Restore Interface Views
--------------------------------------------------------------------------------
@@int_intrfc_1215_v.sql
@@int_intrfc_1216_v.sql


--------------------------------------------------------------------------------
-- 04-05: Restore Calc Engine Views
--------------------------------------------------------------------------------
@@calc_csr_main_p0_0_v.sql
@@calc_csr_main_p0_1_v.sql
@@calc_csr_main_p0_2_v.sql
@@calc_csr_main_p0_3_v.sql
@@calc_csr_main_p0_4_v.sql
@@calc_csr_main_p0_v.sql
@@calc_csr_main_p1_v.sql
@@calc_csr_main_p2_v.sql
@@calc_csr_main_p3_v.sql
@@calc_csr_main_p4_v.sql
@@calc_csr_main_p5_v.sql
@@calc_csr_main_p6_v.sql
@@calc_csr_main_p7_v.sql
@@calc_csr_main_p8_v.sql
@@calc_csr_main_p9_v.sql
@@calc_csr_main_pa_v.sql
@@calc_csr_main_pb_v.sql
@@calc_csr_main_pc_v.sql
@@calc_csr_main_pd_v.sql
@@calc_csr_main_pe_v.sql
@@calc_csr_main_pf_v.sql
@@calc_csr_main_pg_v.sql
@@calc_csr_main_ph_v.sql
@@calc_csr_main_pi_v.sql
@@calc_csr_main_pj_v.sql
@@calc_csr_main_pk_v.sql
@@calc_csr_main_pl_v.sql
@@calc_csr_main_final_v.sql
@@calc_csr_bndl_cnfg_v.sql


--------------------------------------------------------------------------------
-- 04-06: Restore Calc Engine Packages
--------------------------------------------------------------------------------
@@pkg_constants.sql
@@pkg_common_cursors.sql
@@pkg_common_procedures.sql


-- Commit changes
COMMIT;

-- Compile invalid objects
BEGIN
   dbms_utility.compile_schema( 'HCRS', FALSE);  -- only compile invalid
END;
/

-- What time did this end running?
SELECT SYSDATE FROM dual;
TIMING STOP
