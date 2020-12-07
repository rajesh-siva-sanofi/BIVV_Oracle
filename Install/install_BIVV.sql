-- Setup Environment
SET PAGESIZE 50000
SET LINESIZE 10000
SET ECHO ON
SET TAB OFF
SET FEEDBACK ON
SET DEFINE OFF
SET TRIMOUT ON
SET TRIMSPOOL ON
SET SERVEROUTPUT ON SIZE UNLIMITED
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

-- supporting objects
--@@CONV_LOG_T.sql
--@@MEDI_PGMS_MAP_T.sql
--@@MEDI_PGMS_MAP_BIOGEN_T.sql

-- stage tables
--@@REB_CLAIM_T.sql
--@@REB_CLM_LN_ITM_T.sql
--@@VALID_CLAIM_T.sql
--@@DSPT_T.sql
--@@DSPT_RSN_T.sql
--@@VALID_CLAIM_CHK_REQ_T.sql
--@@DSPT_CHECK_REQ_T.sql
--@@CHECK_REQ_T.sql
--@@CHECK_T.sql
--@@CHECK_APPRVL_GRP_T.sql
--@@CHECK_APPRVL_GRP_CHK_XREF_T.sql
--@@CHECK_APPRVL_GRP_APPRVL_T.sql
--@@PROD_MSTR_PGM_T.sql
--@@PUR_FINAL_RESULTS_T.sql

-- BIVV views
@@BIVV_MEDI_CLAIM_V.sql
@@BIVV_MEDI_CLAIM_LINE_V.sql
@@BIVV_MEDI_PAID_LINE_V.sql
@@BIVV_VALID_CLAIM_V.sql
@@BIVV_DSPT_V.sql
@@BIVV_DSPT_RSN_V.sql
@@BIVV_CHECK_REQ_3views.sql
@@BIVV_CHECK_AGG_REQ_V.sql
@@BIVV_CHECK_APPR_GRP_V.sql
@@BIVV_PGM_PROD_V.sql
@@BIVV_PUR_FINAL_RESULTS_V.sql
@@BIVV_CONT_EXCL_V.sql

-- main packages
@@pkg_util.sql
@@pkg_stg_medi.sql

-- load Program mapping data
--@@MEDI_PGMS_MAP_T_data.sql
--@@MEDI_PGMS_MAP_BIOGEN_T_data.sql

-- JT's stuff (it needs view scripts to be in the same directory: ic_product_v.sql and ic_pricing_v.sql)
--@@install_product_bivv.sql
--@@install_pricing_bivv.sql

BEGIN
   dbms_utility.compile_schema('BIVV', FALSE);  -- only compile invalid
END;
/

-- What time did this end running?
SELECT SYSDATE FROM dual;
TIMING SHOW
TIMING STOP
