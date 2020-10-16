DROP TABLE BIVV.MEDI_PGMS_MAP_BIOGEN_T CASCADE CONSTRAINTS;

-- Create table
CREATE TABLE BIVV.MEDI_PGMS_MAP_BIOGEN_T
(
  state           VARCHAR2(2),
  customer_name   VARCHAR2(200),
  program_code    VARCHAR2(100),
  contract_title  VARCHAR2(200),
  contract_number NUMBER,
  hcrs_pgm_id     NUMBER,
  hcrs_pgm_cd     VARCHAR2(100),
  hcrs_pgm_nm     VARCHAR2(200),
  claim_line_cnt  NUMBER,
  contract_category  VARCHAR2(20),
  hcrs_pgm_catg_cd   VARCHAR2(200),
  min_qtr         VARCHAR2(6),
  max_qtr         VARCHAR2(6),
  hcrs_eff_dt     DATE,
  hcrs_end_dt     DATE
);
  
CREATE OR REPLACE VIEW bivv.medi_pgms_map_biogen_v AS
WITH v AS (
   SELECT 
   t.state AS state_cd, t.customer_name, t.program_code
   -- the below is need for 76061 contract since it changed title in its lifetime
   ,MAX(t.contract_title) KEEP (DENSE_RANK LAST ORDER BY t.max_qtr) as contract_title
   ,t.contract_number
   ,t.hcrs_pgm_id
   ,p.pgm_cd AS hcrs_pgm_cd, p.pgm_nm AS hcrs_pgm_nm
   ,t.contract_category, t.hcrs_pgm_catg_cd
FROM medi_pgms_map_biogen_t t
   ,hcrs.pgm_v@hcrs.prod p
WHERE 1=1
   AND t.contract_number IS NOT NULL
   AND t.hcrs_pgm_id IS NOT NULL
   AND t.hcrs_pgm_id = p.pgm_id (+)
GROUP BY t.state, t.customer_name, t.program_code, t.contract_number
   ,t.hcrs_pgm_id
   ,p.pgm_cd, p.pgm_nm
   ,t.contract_category, t.hcrs_pgm_catg_cd)
SELECT *
FROM v
ORDER BY v.hcrs_pgm_id
;

-- Grant/Revoke object privileges 
GRANT SELECT ON BIVV.MEDI_PGMS_MAP_BIOGEN_T TO HCRS_SELECT;
GRANT SELECT ON BIVV.MEDI_PGMS_MAP_V TO HCRS_SELECT;


