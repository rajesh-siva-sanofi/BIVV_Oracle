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

-- package
@@pkg_load_bivv_medi_data.sql

-- view
@@BIVV_RECON_CLAIM_LOAD_V.sql
@@BIVV_RECON_TOTALS_BY_NDC_QTR_V.sql

-- grants access to HCRS
@@grants.sql 'HCRS'

BEGIN
   dbms_utility.compile_schema('HCRS', FALSE);  -- only compile invalid
END;
/

COMMIT;

-- What time did this end running?
SELECT SYSDATE FROM dual;
TIMING SHOW
TIMING STOP
