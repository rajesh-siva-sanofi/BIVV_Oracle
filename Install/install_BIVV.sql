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
@@../Tables/BIVV/CONV_LOG_T.sql
@@../Tables/BIVV/MEDI_PGMS_MAP_T.sql
@@../Tables/BIVV/MEDI_PGMS_MAP_BIOGEN_T.sql

-- stage tables
@@../Tables/BIVV/REB_CLAIM_T.sql
@@../Tables/BIVV/REB_CLM_LN_ITM_T.sql
@@../Tables/BIVV/VALID_CLAIM_T.sql
@@../Tables/BIVV/DSPT_T.sql
@@../Tables/BIVV/DSPT_RSN_T.sql
@@../Tables/BIVV/VALID_CLAIM_CHK_REQ_T.sql
@@../Tables/BIVV/DSPT_CHECK_REQ_T.sql
@@../Tables/BIVV/CHECK_REQ_T.sql
@@../Tables/BIVV/CHECK_T.sql
@@../Tables/BIVV/CHECK_APPRVL_GRP_T.sql
@@../Tables/BIVV/CHECK_APPRVL_GRP_CHK_XREF_T.sql
@@../Tables/BIVV/CHECK_APPRVL_GRP_APPRVL_T.sql
@@../Tables/BIVV/PROD_MSTR_PGM_T.sql
@@../Tables/BIVV/PUR_FINAL_RESULTS_T.sql

-- BIVV views
@@../Views/BIVV/BIVV_MEDI_CLAIM_V.sql
@@../Views/BIVV/BIVV_MEDI_CLAIM_LINE_V.sql
@@../Views/BIVV/BIVV_MEDI_PAID_LINE_V.sql
@@../Views/BIVV/BIVV_VALID_CLAIM_V.sql
@@../Views/BIVV/BIVV_DSPT_V.sql
@@../Views/BIVV/BIVV_DSPT_RSN_V.sql
@@../Views/BIVV/BIVV_CHECK_REQ_3views.sql
@@../Views/BIVV/BIVV_CHECK_AGG_REQ_V.sql
@@../Views/BIVV/BIVV_CHECK_APPR_GRP_V.sql
@@../Views/BIVV/BIVV_PGM_PROD_V.sql
@@../Views/BIVV/BIVV_PUR_FINAL_RESULTS_V.sql
@@../Views/BIVV/BIVV_CONT_EXCL_V.sql

-- main packages
@@../Packages/BIVV/pkg_util.sql
@@../Packages/BIVV/pkg_stg_medi.sql

-- load Program mapping data
@@MEDI_PGMS_MAP_T_data.sql
@@MEDI_PGMS_MAP_BIOGEN_T_data.sql

-- JT's stuff (it needs view scripts to be in the same directory: ic_product_v.sql and ic_pricing_v.sql)
@@install_product_bivv.sql
@@install_pricing_bivv.sql

BEGIN
   dbms_utility.compile_schema('BIVV', FALSE);  -- only compile invalid
END;
/

-- What time did this end running?
SELECT SYSDATE FROM dual;
TIMING SHOW
TIMING STOP
