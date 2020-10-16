CREATE OR REPLACE VIEW BIVV_DSPT_RSN_V AS
SELECT 107 AS rpr_dspt_rsn_id --CALCULATED UNITS TEST
   ,v.pgm_id, v.ndc_lbl, v.period_id, v.reb_clm_seq_no, v.co_id, v.ln_itm_seq_no
   ,v.dspt_seq_no, 1 as dspt_priority
FROM bivv_dspt_v v;

--SELECT *
--FROM hcrs.dspt_rsn_t;

--SELECT *
--FROM bivv.bivv_dspt_rsn_v;
