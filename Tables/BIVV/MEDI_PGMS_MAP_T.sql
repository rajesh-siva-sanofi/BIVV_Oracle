DROP TABLE BIVV.MEDI_PGMS_MAP_T CASCADE CONSTRAINTS;

-- Create table
CREATE TABLE BIVV.MEDI_PGMS_MAP_T
(
  state_cd         VARCHAR2(2),
  bunit_name       VARCHAR2(200),
  cont_num         NUMBER,
  cont_internal_id VARCHAR2(20),
  cont_title       VARCHAR2(200),
  hcrs_pgm_id      NUMBER,
  hcrs_pgm_cd      VARCHAR2(200),
  hcrs_pgm_nm      VARCHAR2(200),
  adjitems_cnt     NUMBER,
  cont_catg_cd     VARCHAR2(20),
  cont_catg_desc   VARCHAR2(200),
  addr             VARCHAR2(1000),
  hcrs_pgm_catg_cd VARCHAR2(200),
  hcrs_addr        VARCHAR2(1000),
  cpgrp_dt_start   DATE,
  cpgrp_dt_end     DATE,
  hcrs_eff_dt      DATE,
  hcrs_end_dt      DATE
);
  
CREATE OR REPLACE VIEW bivv.medi_pgms_map_v AS
SELECT t.state_cd, t.bunit_name, t.cont_num, t.cont_internal_id, t.cont_title
   ,t.hcrs_pgm_id, p.pgm_cd, p.pgm_nm, p.eff_dt, p.end_dt
FROM medi_pgms_map_t t
   ,hcrs.pgm_v p
WHERE 1=1
   AND t.cont_num IS NOT NULL
   AND t.hcrs_pgm_id IS NOT NULL
   AND t.hcrs_pgm_id = p.pgm_id
;

-- Grant/Revoke object privileges 
GRANT SELECT ON BIVV.MEDI_PGMS_MAP_T TO HCRS_SELECT;
GRANT SELECT ON BIVV.MEDI_PGMS_MAP_V TO HCRS_SELECT;

--SELECT * FROM medi_pgms_map_v
--WHERE 1=1
--   AND cont_num = 1004 -- MEDI FDRL
--ORDER BY state_cd, cont_num;


