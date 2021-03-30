CREATE OR REPLACE VIEW BIVV.MEDI_PGMS_MAP_V AS
SELECT DISTINCT t.state_cd, t.bunit_name, t.cont_num, t.cont_internal_id, t.cont_title
   ,t.hcrs_pgm_id, p.pgm_cd, p.pgm_nm, p.eff_dt, p.end_dt
FROM medi_pgms_map_t t
   ,hcrs.pgm_t p
WHERE 1=1
   AND t.cont_num IS NOT NULL
   AND t.hcrs_pgm_id IS NOT NULL
   AND t.hcrs_pgm_id = p.pgm_id;
