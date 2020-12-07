CREATE OR REPLACE VIEW BIVV.BIVV_CONT_EXCL_V AS 
-- if more exceptions are needed then add them to select from dual as comma seperated values
WITH t AS (SELECT 'MEDISUPPNMPI' AS cont_internal_id FROM dual)
SELECT 
   cont_internal_id AS all_excl_cont_id
   ,trim(COLUMN_VALUE) AS cont_internal_id   
FROM t, 
   xmltable(('"'||REPLACE(cont_internal_id, ',', '","')|| '"'));
