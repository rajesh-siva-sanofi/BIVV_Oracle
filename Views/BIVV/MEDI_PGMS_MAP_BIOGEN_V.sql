CREATE OR REPLACE VIEW BIVV.MEDI_PGMS_MAP_BIOGEN_V AS
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
   ,hcrs.pgm_v p
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
GRANT SELECT ON BIVV.MEDI_PGMS_MAP_V TO HCRS_SELECT, HCRS_READ, GPC_SUPP;
