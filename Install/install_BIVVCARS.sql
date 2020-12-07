-- Setup Environment
SET PAGESIZE 50000
SET LINESIZE 10000
SET ECHO ON
SET TAB OFF
SET FEEDBACK ON
SET DEFINE ON
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

-- views
@@../Views/BIVVCARS/V_TTBH.sql
@@../Views/BIVVCARS/V_TTBC.sql
@@../Views/BIVVCARS/V_CONT.sql
@@../Views/BIVVCARS/V_MEDI_ADJREQ_BY_STLMT_ALL.sql

-- grants access to BIVV
@@grants.sql 'BIVVCARS'

BEGIN
   dbms_utility.compile_schema('BIVVCARS', FALSE);  -- only compile invalid
END;
/

-- What time did this end running?
SELECT SYSDATE FROM dual;
TIMING SHOW
TIMING STOP
