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
-- 99-01: Drop original tables - Calc Engine
--------------------------------------------------------------------------------
DROP TABLE hcrs.prfl_prod_wrk_org_t;

DROP TABLE hcrs.prfl_sls_excl_org_t;

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
