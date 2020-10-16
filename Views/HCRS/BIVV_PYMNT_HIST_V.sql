CREATE OR REPLACE VIEW HCRS.BIVV_PYMNT_HIST_V AS
WITH
chk_v AS
(
SELECT  v.co_id,
        v.pgm_id,
        v.ndc_lbl,
        v.ndc_prod,
        v.ndc_pckg,
        v.ndc_lbl || '-' || v.ndc_prod || '-' || v.ndc_pckg NDC,
        v.period_id,
        v.reb_clm_seq_no,
        c.check_id,
        SUM (v.paid_amt) paid_amt,
        SUM (v.int_amt) int_amt,
        MIN (c.pymnt_catg_cd) pymnt_catg_cd,
        MIN (c.check_req_stat_cd) check_req_stat_cd,
        MIN (d.cd_descr) pymnt_catg_desc,
        MIN (d2.cd_descr) check_status,
        MIN (TRUNC (c.check_input_dt)) check_input_dt,
        MIN (TRUNC (c.check_req_dt)) check_req_dt,
        MIN (TRUNC (c.check_dt)) check_dt
     FROM hcrs.check_v v,
          hcrs.check_req_t c,
          hcrs.cd_t d,
          hcrs.cd_t d2
     WHERE    c.check_id = v.check_id
              AND c.pymnt_catg_cd = d.cd
              AND d.cd_typ_cd = 'PY'
              AND c.check_req_stat_cd = d2.cd
              AND d2.cd_typ_cd = 'CR'
              AND v.ndc_lbl = '71104' -----BiVV NDC label 
              AND v.check_req_stat_cd NOT IN ('NS','SB')
     GROUP BY v.co_id,
              v.pgm_id,
              v.ndc_lbl,
              v.ndc_prod,
              v.ndc_pckg,
              v.ndc_lbl || '-' || v.ndc_prod || '-' || v.ndc_pckg,
              v.period_id,
              v.reb_clm_seq_no,
              c.check_id
     ORDER BY v.co_id,
              v.pgm_id,
              v.ndc_lbl,
              v.ndc_prod,
              v.ndc_pckg,
              v.period_id
)
--Main query
SELECT  chk_v.co_id,
        p.state_cd,
        p.pgm_id,
        p.pgm_nm,
        chk_v.ndc_lbl,
        chk_v.ndc_prod,
        chk_v.ndc_pckg,
        chk_v.NDC,
        pm.prod_nm,
        chk_v.period_id claim_period_id,
        r.yr||'Q'||r.qtr as claim_period,
        chk_v.reb_clm_seq_no,
        chk_v.check_id,
        chk_v.paid_amt,
        chk_v.int_amt,
        chk_v.check_input_dt,
        chk_v.check_req_dt,
        chk_v.check_dt check_cut_dt,
        chk_v.pymnt_catg_cd,
        chk_v.pymnt_catg_desc,
        chk_v.check_req_stat_cd,
        chk_v.check_status,
        ag.check_group_id,
        ag.check_group_desc
FROM chk_v, hcrs.co_t t, hcrs.pgm_t p, hcrs.prod_mstr_t pm, hcrs.period_t r,
                       (SELECT x.check_id,
                               x.apprvl_grp_id check_group_id,
                               g.apprvl_grp_desc check_group_desc
                        FROM hcrs.check_apprvl_grp_chk_xref_t x,
                             hcrs.check_apprvl_grp_t g
                        WHERE g.apprvl_grp_id = x.apprvl_grp_id
                        --need to get max due to duplicate records in check_apprvl_grp_chk_xref_t
                         AND x.apprvl_grp_id IN (SELECT max(x2.apprvl_grp_id)
                                                FROM hcrs.check_apprvl_grp_chk_xref_t x2
                                                WHERE x.check_id = x2.check_id)) ag
WHERE chk_v.co_id = t.co_id
AND chk_v.pgm_id = p.pgm_id
AND chk_v.period_id = r.period_id
AND chk_v.ndc_lbl = pm.ndc_lbl
AND chk_v.ndc_prod = pm.ndc_prod
AND chk_v.ndc_pckg = pm.ndc_pckg
AND chk_v.check_id = ag.check_id (+)
--AND chk_v.period_id BETWEEN 45 AND 148
ORDER BY chk_v.pgm_id,
      chk_v.period_id,
      chk_v.ndc_lbl,
      chk_v.ndc_prod,
      chk_v.ndc_pckg,
      chk_v.reb_clm_seq_no,
      chk_v.check_id
;
