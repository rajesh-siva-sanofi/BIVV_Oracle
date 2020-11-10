CREATE OR REPLACE VIEW bivv.BIVV_VALID_CLAIM_V AS
SELECT v.pgm_id, v.ndc_lbl, v.period_id, v.reb_clm_seq_no, v.co_id, v.ln_itm_seq_no
   ,v.item_prod_fmly_ndc as ndc_prod, v.item_prod_mstr_ndc as ndc_pckg, v.dspt_flg
   ,v.total_units_paid as claim_units, v.total_amt_paid as claim_amt
   ,v.adjitm_auth_rx as script_cnt, v.pgm_pur, v.reimbur_amt, v.corr_flg
   ,v.total_int_amt AS int_amt
FROM bivv_medi_paid_line_v v
WHERE v.dspt_flg = 'N';
