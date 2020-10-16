CREATE OR REPLACE VIEW BIVV.BIVV_CHECK_APPR_GRP_V AS
WITH v AS (
   SELECT check_id, period_id FROM valid_claim_chk_req_t
   UNION
   SELECT check_id, period_id FROM dspt_check_req_t)
SELECT 
   c.*
   ,'BIVV import for '||pgm.pgm_cd||' '||p.qtr||'q'||p.yr AS appr_grp_desc
FROM 
   check_req_t c
   ,v
   ,hcrs.pgm_t pgm
   ,hcrs.period_t p
WHERE c.check_id = v.check_id
   AND c.pgm_id = pgm.pgm_id 
   AND v.period_id = p.period_id;
