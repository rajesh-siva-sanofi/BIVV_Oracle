CREATE OR REPLACE VIEW BIVV.BIVV_PRFL_DELTA_V AS
SELECT DISTINCT p.*
FROM bivv.prfl_t p
   ,bivv.ic_pricing_delta_v pd
WHERE p.tim_per_cd LIKE pd.tim_per_cd||'%';
