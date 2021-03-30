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

-- BIVV views
@@MEDI_PGMS_MAP_V.sql
@@BIVV_PUR_FINAL_RESULTS_V.sql

-- load table data
@@MEDI_PGMS_MAP_T_data.sql
@@PUR_FINAL_RESULTS_T_data.sql

-- grants access to BIVV
@@grants.sql 'BIVV'

BEGIN
   dbms_utility.compile_schema('BIVV', FALSE);  -- only compile invalid
END;
/

COMMIT;

-- What time did this end running?
SELECT SYSDATE FROM dual;
TIMING SHOW
TIMING STOP
