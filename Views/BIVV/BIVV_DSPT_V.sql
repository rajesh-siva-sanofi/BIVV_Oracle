-- validation view
CREATE OR REPLACE VIEW bivv.BIVV_DSPT_VAL_V AS
SELECT 
   CASE WHEN (
      SELECT COUNT(*) FROM bivv_valid_claim_v t 
      WHERE t.pgm_id = v.pgm_id AND t.ndc_lbl = v.ndc_lbl AND t.period_id = v.period_id AND t.reb_clm_seq_no = v.reb_clm_seq_no
         AND t.co_id = v.co_id AND t.ln_itm_seq_no = v.ln_itm_seq_no) = 0 THEN 'ERR: Matching valid_claim not found' 
   ELSE 'OK' END AS val_msg
   ,v.pgm_id, v.ndc_lbl, v.period_id, v.reb_clm_seq_no, v.co_id, v.ln_itm_seq_no
   ,1 AS dspt_seq_no, v.item_prod_fmly_ndc as ndc_prod, v.item_prod_mstr_ndc as ndc_pckg
   ,v.total_units_paid as paid_units, v.adjitm_dispute_units as dspt_units, 0 AS wrt_off_units   
FROM bivv_medi_claim_line_v v
WHERE v.dspt_flg = 'Y';

-- main view
CREATE OR REPLACE VIEW bivv.BIVV_DSPT_V AS
SELECT *
FROM BIVV_DSPT_VAL_V
WHERE NVL(val_msg,'OK') = 'OK';

