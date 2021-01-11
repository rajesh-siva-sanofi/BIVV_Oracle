-- Setup Environment
SET PAGESIZE 50000
SET LINESIZE 10000
SET ECHO ON
SET TAB OFF
SET FEEDBACK ON
SET DEFINE ON
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
-- Show count of new tables
--------------------------------------------------------------------------------
@@validate-tables.sql "02" "BEFORE"


--------------------------------------------------------------------------------
-- 02-01: Swap in new Profile Product Work table
--------------------------------------------------------------------------------
-- Rename original table
-- Rename contraints
ALTER TABLE hcrs.prfl_prod_wrk_t RENAME CONSTRAINT pk_prfl_prod_wrk_t TO pk_prfl_prod_wrk_org_t;
-- Rename indexes
ALTER INDEX hcrs.prfl_prod_wrk_ix1 RENAME TO prfl_prod_wrk_org_ix1;
-- Rename table
ALTER TABLE hcrs.prfl_prod_wrk_t RENAME TO prfl_prod_wrk_org_t;
-- (table will be dropped by final script)

-- Rename new table
-- Rename contraints
ALTER TABLE hcrs.prfl_prod_wrk_new_t RENAME CONSTRAINT pk_prfl_prod_wrk_new_t TO pk_prfl_prod_wrk_t;
-- Rename indexes
ALTER INDEX hcrs.prfl_prod_wrk_new_ix1 RENAME TO prfl_prod_wrk_ix1;
-- Rename table
ALTER TABLE hcrs.prfl_prod_wrk_new_t RENAME TO prfl_prod_wrk_t;


--------------------------------------------------------------------------------
-- 02-02: Swap in new Profile Sales Exclusion table
--------------------------------------------------------------------------------
-- Rename original table
-- Rename contraints
ALTER TABLE hcrs.prfl_sls_excl_t RENAME CONSTRAINT pk_prfl_sls_excl_t TO pk_prfl_sls_excl_org_t;
ALTER TABLE hcrs.prfl_sls_excl_t RENAME CONSTRAINT fk_prfl_sls_excl_prfl_co TO fk_prfl_sls_excl_org_prfl_co;
ALTER TABLE hcrs.prfl_sls_excl_t RENAME CONSTRAINT prfl_sls_excl_chk01 TO prfl_sls_excl_org_chk01;
ALTER TABLE hcrs.prfl_sls_excl_t RENAME CONSTRAINT prfl_sls_excl_chk02 TO prfl_sls_excl_org_chk02;
-- Rename indexes
ALTER INDEX hcrs.prfl_sls_excl_ix1 RENAME TO prfl_sls_excl_org_ix1;
ALTER INDEX hcrs.prfl_sls_excl_ix2 RENAME TO prfl_sls_excl_org_ix2;
-- Drop Trigger (renaming causes problems)
DROP TRIGGER hcrs.prfl_sls_excl_rbiu_tr;
-- Rename table
ALTER TABLE hcrs.prfl_sls_excl_t RENAME TO prfl_sls_excl_org_t;
-- (table will be dropped by final script)

-- Rename new table
-- Rename contraints
ALTER TABLE hcrs.prfl_sls_excl_new_t RENAME CONSTRAINT pk_prfl_sls_excl_new_t TO pk_prfl_sls_excl_t;
ALTER TABLE hcrs.prfl_sls_excl_new_t RENAME CONSTRAINT fk_prfl_sls_excl_new_prfl_co TO fk_prfl_sls_excl_prfl_co;
ALTER TABLE hcrs.prfl_sls_excl_new_t RENAME CONSTRAINT prfl_sls_excl_new_chk01 TO prfl_sls_excl_chk01;
ALTER TABLE hcrs.prfl_sls_excl_new_t RENAME CONSTRAINT prfl_sls_excl_new_chk02 TO prfl_sls_excl_chk02;
ALTER TABLE hcrs.prfl_sls_excl_new_t RENAME CONSTRAINT prfl_sls_excl_new_chk03 TO prfl_sls_excl_chk03;
-- Rename indexes
ALTER INDEX hcrs.prfl_sls_excl_new_ix1 RENAME TO prfl_sls_excl_ix1;
ALTER INDEX hcrs.prfl_sls_excl_new_ix2 RENAME TO prfl_sls_excl_ix2;
ALTER INDEX hcrs.prfl_sls_excl_new_ix3 RENAME TO prfl_sls_excl_ix3;
-- Rename table
ALTER TABLE hcrs.prfl_sls_excl_new_t RENAME TO prfl_sls_excl_t;
-- Add Trigger (renaming causes problems)
@@prfl_sls_excl_rbiu_tr.sql


--------------------------------------------------------------------------------
-- Show count of new tables
--------------------------------------------------------------------------------
@@validate-tables.sql "02" "AFTER"


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
