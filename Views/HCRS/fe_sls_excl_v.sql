CREATE OR REPLACE VIEW HCRS.FE_SLS_EXCL_V AS
SELECT
/****************************************************************************
   * View Name : fe_sls_excl_v
   * Date Created : 4/18/2016
   * Author : Tom Zimmerman
   * Description :
   * Called by datawindow  d_sales_exclusions  within u_tabpg_exclusions   which resides in the gpc_profile.pbl
   *
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  4/5/2020    M. Gedzior    RITM-1714054 - added sls_excl_cd to support
   *                            subPHS transaction handling
   ****************************************************************************/
  e.prfl_id
  , e.over_ind
  , e.cmt_txt
  , e.apprvd_by
  , e.apprvd_dt
  , e.apprvd_ind
  , e.trans_id
  , v.prfl_id AS v_prfl_id
  , v.ndc_lbl
  , v.ndc_prod
  , v.ndc_pckg
  , v.agency_typ_cd
  , v.prfl_nm
  , v.prfl_begn_dt
  , v.prfl_end_dt
  , v.prfl_stat_cd
  , v.tim_per_cd
  , v.snpsht_id
  , v.prcss_typ_cd
  , v.ndc
  , v.prod_nm
  , v.cust_id
  , v.cust_nm
  , v.cls_of_trd_cd
  , v.cls_of_trd_descr
  , v.contr_id
  , v.cont_title
  , v.adjusted
  , v.trans_typ_cd
  , v.trans_typ_descr
  , v.calc_typ_cd
  , v.comp_typ_cd
  , v.nominal_threshold_amt
  , v.adj_price
  , v.adj_pkg_qty
  , v.adj_total_amt
  , v.dllrs_pkgs
  , v.pkgs
  , v.dllrs
  , v.trans_dt
  , v.lgcy_trans_no
  , v.lgcy_trans_line_no
  , v.invc_line_no
  , v.price_grp_id
  , v.whls_id
  , v.chrgbcks
  , v.assc_invc_dt
  , v.assc_invc_no
  , v.assc_invc_line_no
  , v.manual_adj_ind
  , v.claim_bgn_dt
  , v.claim_end_dt
  , v.root_trans_id
  , v.parent_trans_id
  , v.trans_id AS v_trans_id
  , v.trans_adj_cd
  , v.trans_adj_descr
  , v.co_id
  , v.sls_excl_cd
  , v.sls_excl_descr
FROM hcrs.prfl_sls_excl_t e,
     hcrs.nom_excl_v v
WHERE e.prfl_id = v.prfl_id
AND e.trans_id = v.trans_id
--AND e.prfl_id = :in_prfl_id
ORDER BY v.ndc, v.cust_nm,v.root_trans_id,v.parent_trans_id, v.trans_id
;
