CREATE OR REPLACE VIEW HCRS.BIVV_CLAIM_HIST_V AS
WITH chk_v
AS
 (--get all checks that have claims Q1/1991-Q4/2016
 SELECT DISTINCT v.check_id
 FROM hcrs.check_v v
 WHERE /*v.period_id BETWEEN 45 AND 148*/ 1=1
 AND v.check_req_stat_cd NOT IN ('NS','SB')
 ORDER BY 1
 )
, uv AS
--valid/disputed/credit claim items for each program/period/NDC
 (SELECT
      /* clm_v selects paid claims*/
         clm_v.src,
         clm_v.co_id,
         c.co_nm,
         clm_v.pgm_id,
         clm_v.period_id,
         pr.yr||'Q'||pr.qtr AS claim_period,
         clm_v.reb_clm_seq_no,
         clm_v.ln_itm_seq_no,
         clm_v.ndc_lbl,
         clm_v.ndc_prod,
         clm_v.ndc_pckg,
         hcrs.f_get_pur (clm_v.pgm_id,clm_v.ndc_lbl,clm_v.ndc_prod,clm_v.period_id,nvl(clm_v.ura_dt,SYSDATE),'Y',clm_v.ndc_pckg) AS ura,
         clm_v.claim_units,
         clm_v.claim_amt,
         clm_v.paid_units,
         clm_v.paid_amt,
         clm_v.int_amt,
         clm_v.dspt_units,
         clm_v.wrt_off_units,
         clm_v.dspt_seq_no,
         clm_v.rpr_dspt_rsn_id,
         clm_v.desc_txt AS dispute_reason,
         h.reb_claim_stat_cd,
         clm_v.reb_claim_ln_itm_stat_cd,
         clm_v.check_id,
         clm_v.script_cnt,
         clm_v.reimbur_amt,
         clm_v.nonmed_reimbur_amt,
         clm_v.total_reimbur_amt,
         clm_v.pgm_pur,
         h.subm_typ_cd,
         h.pstmrk_dt,
         h.rcv_dt,
         h.input_dt,
         h.invc_num,
         h.valid_dt,
         h.prelim_run_dt,
         h.final_run_dt,
         h.mod_dt,
         h.mod_by
        FROM chk_v a, hcrs.co_t c, hcrs.period_t pr,
             (SELECT co_id, pgm_id, period_id, ndc_lbl, reb_clm_seq_no, reb_claim_stat_cd,
             subm_typ_cd, pstmrk_dt, rcv_dt, input_dt, invc_num,
             valid_dt, prelim_run_dt, final_run_dt, mod_dt, mod_by
             FROM hcrs.reb_claim_t
             ) h,
              (
              /* credit line items N/A for BIVV */              
                    /* the following selects valid (non-disputed) lines */
                    SELECT 'VC' AS src
                         ,vc.ndc_lbl
                         ,vc.ndc_prod
                         ,vc.ndc_pckg
                         ,vc.claim_units
                         ,l.claim_amt
                         ,vc.claim_units AS paid_units
                         ,0 AS dspt_units
                         ,0 AS wrt_off_units
                         ,nvl(vcc.paid_amt,0) paid_amt
                         ,nvl(vcc.int_amt,0) int_amt
                         ,CASE WHEN vc.reb_clm_seq_no > 1 THEN 'CORRECTION' ELSE 'ORIGINAL' END desc_txt
                         ,vc.pgm_id
                         ,vc.period_id
                         ,vc.reb_clm_seq_no
                         ,vc.co_id
                         ,vc.ln_itm_seq_no
                         ,vcc.check_id
                         ,vcc.create_dt
                         ,vcc.check_input_dt
                         ,vcc.check_input_dt AS ura_dt
                         ,l.script_cnt
                         ,l.reimbur_amt
                         ,nvl(l.nonmed_reimbur_amt,0) AS nonmed_reimbur_amt
                         ,nvl(l.total_reimbur_amt,l.reimbur_amt) AS total_reimbur_amt
                         ,l.reb_claim_ln_itm_stat_cd
                         ,0 dspt_seq_no
                         ,0 rpr_dspt_rsn_id
                         ,l.pgm_pur
                    FROM
                       hcrs.valid_claim_t vc
                       ,hcrs.reb_clm_ln_itm_t l
                       ,(SELECT vcc.pgm_id,vcc.ndc_lbl,vcc.period_id,vcc.reb_clm_seq_no,vcc.co_id,vcc.ndc_prod,vcc.ndc_pckg
                          ,vcc.paid_amt,vcc.int_amt, vcc.check_id,vcc.create_dt,cr.check_input_dt
                        FROM hcrs.valid_claim_chk_req_t vcc
                             ,hcrs.check_req_t cr
                        WHERE vcc.check_id = cr.check_id
                       ) vcc
                    WHERE
                     vc.pgm_id = vcc.pgm_id
                     AND vc.ndc_lbl = vcc.ndc_lbl
                     AND vc.period_id = vcc.period_id
                     AND vc.reb_clm_seq_no = vcc.reb_clm_seq_no
                     AND vc.co_id = vcc.co_id
                     AND vc.ndc_prod = vcc.ndc_prod
                     AND vc.ndc_pckg = vcc.ndc_pckg
                     AND vc.pgm_id = l.pgm_id
                     AND vc.ndc_lbl = l.ndc_lbl
                     AND vc.period_id = l.period_id
                     AND vc.reb_clm_seq_no = l.reb_clm_seq_no
                     AND vc.co_id = l.co_id
                     AND vc.ndc_prod = l.item_prod_fmly_ndc
                     AND vc.ndc_pckg = l.item_prod_mstr_ndc
                     AND vc.dspt_flg = 'N'

                    /*disputes N/A for BIVV*/
 
                    /*claim exceptions N/A for BIVV*/
  
              ) clm_v
    WHERE a.check_id = clm_v.check_id --join by check_id
    AND c.co_id = clm_v.co_id
     AND pr.period_id = clm_v.period_id
     AND h.co_id = clm_v.co_id
     AND h.pgm_id = clm_v.pgm_id
     AND h.ndc_lbl = clm_v.ndc_lbl
	 AND clm_v.ndc_lbl  IN ('71104') /* Only BIVV */	 
     AND h.period_id = clm_v.period_id
     AND h.reb_clm_seq_no = clm_v.reb_clm_seq_no
)
--main query
SELECT
   uv.src,
   uv.co_id,
   uv.co_nm,
   uv.period_id,
   uv.claim_period,
   p.state_cd,
   uv.pgm_id,
   p.pgm_nm,
   uv.ndc_lbl,
   uv.ndc_prod,
   uv.ndc_pckg,
   pm.prod_nm,
   uv.reb_clm_seq_no,
   uv.ln_itm_seq_no,
   uv.pgm_pur,
   uv.ura,
   uv.claim_units,
   --CASE WHEN uv.ura IS NULL THEN 0 ELSE round(uv.claim_units * uv.ura,2) END AS claim_amt,
   uv.claim_amt,
   uv.paid_units,
   uv.paid_amt,
   uv.int_amt,
   uv.dspt_units,
   CASE WHEN uv.ura IS NULL THEN 0 ELSE round(uv.dspt_units * uv.ura,2) END AS dspt_amt,
   uv.wrt_off_units,
   CASE WHEN uv.ura IS NULL THEN 0 ELSE round(uv.wrt_off_units * uv.ura,2) END AS wrt_off_amt,
   uv.dspt_seq_no,
   uv.rpr_dspt_rsn_id,
   CASE WHEN uv.rpr_dspt_rsn_id > 0 THEN
     (SELECT rr.rpr_dspt_rsn_descr FROM hcrs.rpr_dspt_rsn_t rr WHERE rr.actv_flg = 'Y' AND rr.rpr_dspt_rsn_id = uv.rpr_dspt_rsn_id)
   ELSE NULL
   END rpr_dspt_rsn_descr,
   uv.dispute_reason,
   uv.reb_claim_stat_cd,
   uv.reb_claim_ln_itm_stat_cd,
   uv.check_id,
   uv.subm_typ_cd,
   uv.pstmrk_dt,
   p.prcss_day_limit,
   uv.rcv_dt,
   uv.input_dt,
   uv.invc_num,
   uv.script_cnt,
   uv.reimbur_amt,
   uv.nonmed_reimbur_amt,
   uv.total_reimbur_amt,
   uv.valid_dt,
   uv.prelim_run_dt,
   uv.final_run_dt,
   (uv.pstmrk_dt + p.prcss_day_limit) AS due_dt,
   uv.mod_dt,
   uv.mod_by,
   pg.pgm_group_lvl1_cd AS util_rec_typ,
   'BIVV' AS source_id
FROM hcrs.pgm_t p, hcrs.prod_mstr_t pm, uv,
     (
     SELECT v.pgm_id, v.pgm_group_lvl1_cd
     FROM hcrs.pgm_group_v v
     WHERE v.rpt_typ_cd = 'CMS_RPT'
     ORDER BY v.pgm_id
     ) pg
WHERE pg.pgm_id = uv.pgm_id
   AND p.pgm_id = uv.pgm_id
   AND pm.ndc_lbl = uv.ndc_lbl
   AND pm.ndc_lbl  IN ('71104') /* Only BIVV */
   AND pm.ndc_prod = uv.ndc_prod
   AND pm.ndc_pckg = uv.ndc_pckg
   /*AND uv.period_id BETWEEN 45 AND 148*/
ORDER BY uv.co_id,
      uv.period_id,
      uv.pgm_id,
      uv.ndc_lbl,
      uv.ndc_prod,
      uv.ndc_pckg,
      uv.reb_clm_seq_no,
      uv.check_id;
