-- Test GP interface for prod family table
-- test URAs against production

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

-- Add/modify columns for Clotting Factor (CF)
--ALTER TABLE HCRS.PROD_FMLY_T DROP COLUMN CLOTTING_FACTOR_IND;
ALTER TABLE HCRS.PROD_FMLY_T ADD CLOTTING_FACTOR_IND VARCHAR2(1);
-- for some reason I get ORA-28133 if I do it in one statement, works fine if split into two.
ALTER TABLE HCRS.PROD_FMLY_T MODIFY CLOTTING_FACTOR_IND DEFAULT 'N';

-- Add comments to the columns 
COMMENT ON COLUMN HCRS.PROD_FMLY_T.CLOTTING_FACTOR_IND IS 'Indicates whether an NDC family is a clotting factor treatment';

-- Packages
@@pkg_ui_dm_pur_catg_comp_val.sql
@@pkg_pur_calc.sql

-- update all products accordingly
UPDATE hcrs.prod_fmly_t f
SET f.clotting_factor_ind = DECODE (f.ndc_lbl, '71104', 'Y', 'N');

--SELECT f.clotting_factor_ind, COUNT(*)
--FROM hcrs.prod_fmly_t f
--GROUP BY f.clotting_factor_ind;

--SELECT f.ndc_lbl, f.ndc_prod, f.line_extension_ind, f.clotting_factor_ind, f.*
--FROM 
--   hcrs.prod_fmly_t f
----   hcrs.drug_catg_grp_asgnmnt_t
--WHERE 1=1
--   AND f.ndc_lbl||'-'||f.ndc_prod IN ('71104-0911', '00024-5401')
----   AND f.line_extension_ind IS NULL;

-- 1. add new drug catg group for reduced %
SELECT * FROM hcrs.drug_catg_grp_t t;
--add new drug_catg_grp_cd: 'CF', 'I AND S WITH CF'
INSERT INTO hcrs.drug_catg_grp_t VALUES ('CF', 'I AND S WITH CF',SYSDATE,NULL,'HCRS');

-- 2. assign S and I drugs to be part of reduced % group
SELECT * FROM hcrs.drug_catg_grp_asgnmnt_t t
WHERE t.drug_catg_cd IN ('S','I');
--map new drug_catg_grp_cd to 'S' and 'I' drugs: 
--'S','CF'
--'I','CF'
INSERT INTO hcrs.drug_catg_grp_asgnmnt_t VALUES ('S','CF',SYSDATE,NULL,'HCRS');
INSERT INTO hcrs.drug_catg_grp_asgnmnt_t VALUES ('I','CF',SYSDATE,NULL,'HCRS');

-- 3. add component values
DECLARE
   cnt NUMBER:=0;
BEGIN 
   FOR c IN (
      SELECT t.formula_id, t.comp_id, t.pur_catg_cd, t.val
      FROM hcrs.pur_catg_comp_val_t t
      WHERE t.formula_id = 107 -- Federal URA with TCAP 
         AND t.pur_catg_cd = 'FDRL') LOOP

         INSERT INTO hcrs.pur_catg_comp_val_t (
            formula_id, comp_id, drug_catg_grp_cd, pur_catg_cd, 
            eff_dt, end_dt, val, begin_qtr_dt, end_qtr_dt,
            create_dt, mod_by)
         VALUES (
            c.formula_id, c.comp_id, 'CF', c.pur_catg_cd
            ,SYSDATE, to_date('1/1/2100','mm/dd/yyyy')
            ,DECODE (c.comp_id, 100, 0.171, c.val)
            ,to_date('1/1/2018','mm/dd/yyyy'), to_date('1/1/2100','mm/dd/yyyy')
            ,SYSDATE, 'HCRS');
      cnt := cnt + 1;
   END LOOP;

   dbms_output.put_line('PUR_CATG_COMP_VAL_T: Inserted '||cnt||' rows.');
END;
/   

SELECT * 
FROM hcrs.pur_catg_comp_val_t t
WHERE t.formula_id = 107 -- Federal URA with TCAP 
   AND t.pur_catg_cd = 'FDRL'
;

-- Reverse changes
--DELETE FROM hcrs.pur_catg_comp_val_t t WHERE t.drug_catg_grp_cd = 'RP';
--DELETE FROM hcrs.drug_catg_grp_asgnmnt_t t WHERE t.drug_catg_grp_cd = 'RP';
--DELETE FROM hcrs.drug_catg_grp_t WHERE drug_catg_grp_cd = 'RP';
--ALTER TABLE HCRS.PROD_FMLY_T DROP COLUMN medi_reduced_pct;
--@@..\Oracle\prod\pkg_pur_calc.sql
--@@..\Oracle\prod\pkg_ui_dm_pur_catg_comp_val.sql

BEGIN
   dbms_utility.compile_schema('HCRS', FALSE);  -- only compile invalid
END;
/

-- What time did this end running?
SELECT SYSDATE FROM dual;
TIMING SHOW
TIMING STOP
