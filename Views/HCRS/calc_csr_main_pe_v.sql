CREATE OR REPLACE VIEW hcrs.calc_csr_main_pe_v
AS
   SELECT
          /*+ calc_csr_main_pe_v
              QB_NAME( pe )
              NO_MERGE
              LEADING( z psp )
              USE_NL( z psp )
              INDEX( psp prfl_contr_prod_splt_p_wrk_ix1 )
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_pe_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part E (14)
   *
   *                ESTIMATIONS
   *
   *                Apply Estimation Split percentages
   *
   *                This only works when the calculation environment has been
   *                initialized with pkg_common_procedures.p_init_calc.
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
   *                              formula / Winthrop BP Change
   *                            Adjust hints
   *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
   *                            Group columns, GTT column reduction, Adjust hints
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add SAP4H source system code column
   ****************************************************************************/
          -- Source --------------------------------------------------------------------------------
          z.rec_src_ind,
          z.co_id,
          -- Customer ------------------------------------------------------------------------------
          z.cust_id,
          z.orig_cust_id,
          NVL( psp.dst_cls_of_trd_cd, z.cust_cls_of_trd_cd) cust_cls_of_trd_cd,
          -- Root Customer -------------------------------------------------------------------------
          z.root_cust_id,
          -- Parent Customer -----------------------------------------------------------------------
          z.parent_cust_id,
          -- Product -------------------------------------------------------------------------------
          z.ndc_lbl,
          z.ndc_prod,
          z.ndc_pckg,
          -- Component -----------------------------------------------------------------------------
          -- Root Identifiers ----------------------------------------------------------------------
          z.root_trans_cls_cd,
          z.root_source_sys_cde,
          z.root_contr_id,
          z.root_lgcy_trans_no,
          -- Marking Trans Date --------------------------------------------------------------------
          -- Parent Identifiers --------------------------------------------------------------------
          z.parent_trans_cls_cd,
          z.parent_source_sys_cde,
          z.parent_lgcy_trans_ord,
          z.parent_contr_id,
          z.parent_lgcy_trans_no,
          z.parent_lgcy_trans_line_no,
          -- Trans Identifiers ---------------------------------------------------------------------
          z.trans_cls_cd,
          z.source_sys_cde,
          z.lgcy_trans_ord,
          z.contr_id,
          z.lgcy_trans_no,
          z.assc_invc_no,
          z.lgcy_trans_line_no,
          -- Trans IDs -----------------------------------------------------------------------------
          z.root_trans_id,
          z.parent_trans_id,
          z.trans_id,
          NVL( psp.trans_adj_cd, z.trans_adj_cd) trans_adj_cd,
          -- Root Lookup IDs -----------------------------------------------------------------------
          z.root_trans_id_sap_adj,
          z.root_trans_id_cars_adj,
          z.root_trans_id_x360_adj,
          -- Parent Lookup IDs ---------------------------------------------------------------------
          z.parent_trans_id_sap_adj,
          z.parent_trans_id_icw_key,
          z.parent_trans_id_cars_rbt_fee,
          z.parent_trans_id_cars_adj,
          z.parent_trans_id_x360_adj,
          z.parent_trans_id_prasco_rbtfee,
          -- Link Markers --------------------------------------------------------------------------
          z.root_link_ind,
          z.parent_link_ind,
          -- Related Trans -------------------------------------------------------------------------
          -- Prasco Rebates Link -------------------------------------------------------------------
          -- Trans Flags ---------------------------------------------------------------------------
          z.source_trans_typ,
          -- Sales Exclusion -----------------------------------------------------------------------
          z.sls_excl_ind,
          -- Root Keys/Dates -----------------------------------------------------------------------
          -- Parent Keys/Dates ---------------------------------------------------------------------
          -- Transaction Dates ---------------------------------------------------------------------
          z.paid_dt,
          z.alt_paid_dt,
          z.earn_bgn_dt,
          z.earn_end_dt,
          -- Root Values ---------------------------------------------------------------------------
          -- Parent Values -------------------------------------------------------------------------
          -- Transaction Values --------------------------------------------------------------------
          -- Component Values ----------------------------------------------------------------------
          z.dllrs_grs * NVL( psp.splt_pct, 1) dllrs_grs,
          z.dllrs_wac * NVL( psp.splt_pct, 1) dllrs_wac,
          z.dllrs_net * NVL( psp.splt_pct, 1) dllrs_net,
          z.dllrs_dsc * NVL( psp.splt_pct, 1) dllrs_dsc,
          z.dllrs_ppd * NVL( psp.splt_pct, 1) dllrs_ppd,
          z.pkgs * NVL( psp.splt_pct, 1) pkgs,
          z.units * NVL( psp.splt_pct, 1) units,
          -- Customer COT --------------------------------------------------------------------------
          NVL( psp.dst_cot_incl_ind, z.cust_cot_incl_ind) cust_cot_incl_ind,
          NVL( psp.dst_cot_grp_cd, z.cust_cot_grp_cd) cust_cot_grp_cd,
          z.cust_loc_cd,
          -- Wholesaler COT ------------------------------------------------------------------------
          z.whls_cot_incl_ind,
          z.whls_cot_grp_cd,
          z.whls_loc_cd,
          -- Transaction Type ----------------------------------------------------------------------
          NVL( psp.dst_trans_typ_cd, z.trans_typ_cd) trans_typ_cd,
          NVL( psp.dst_tt_incl_ind, z.trans_typ_incl_ind) trans_typ_incl_ind,
          NVL( psp.dst_tt_grp_cd, z.trans_typ_grp_cd) trans_typ_grp_cd,
          -- Profile Calc Data ---------------------------------------------------------------------
          -- Product Units -------------------------------------------------------------------------
          -- Bundling ------------------------------------------------------------------------------
          z.bndl_prod,
          z.bndl_src_sys_ind,
          -- Trans Linking -------------------------------------------------------------------------
          -- Estimations ---------------------------------------------------------------------------
          NVL( psp.splt_pct_ord, 0) splt_pct_ord,
          psp.splt_pct_typ,
          psp.splt_pct_seq_no,
          -- Component Checks ----------------------------------------------------------------------
          z.chk_contr,
          z.chk_phs_pvp_contr,
          z.chk_phs_contr,
          z.chk_fss_contr,
          z.chk_nom,
          z.chk_hhs,
          -- Units Component -----------------------------------------------------------------------
          -- Component Dollars ---------------------------------------------------------------------
          -- Trans Settings ------------------------------------------------------------------------
          -- Nominal Settings ----------------------------------------------------------------------
          -- Sub-PHS Settings ----------------------------------------------------------------------
          -- Trans Groupings -----------------------------------------------------------------------
          -- Constants -----------------------------------------------------------------------------
          z.flag_yes,
          z.flag_no,
          z.system_sap,
          z.system_sap4h,
          z.system_cars,
          z.system_x360,
          z.trans_cls_rbt
          -- Marking data --------------------------------------------------------------------------
          -- Cursor Row Count ----------------------------------------------------------------------
     FROM hcrs.calc_csr_main_pd_v z,
          hcrs.prfl_contr_prod_splt_pct_wrk_t psp
    WHERE z.contr_id = psp.contr_id (+)
      AND z.ndc_lbl = psp.ndc_lbl (+)
      AND z.ndc_prod = psp.ndc_prod (+)
      AND z.ndc_pckg = psp.ndc_pckg (+)
      AND z.cust_cls_of_trd_cd = psp.src_cls_of_trd_cd (+)
      AND z.trans_typ_cd = psp.src_trans_typ_cd (+)
      AND z.earn_bgn_dt >= psp.splt_begn_dt (+)
      AND z.earn_bgn_dt <= psp.splt_end_dt (+)
      AND z.earn_bgn_dt >= psp.splt_pct_strt_dt (+)
      AND z.earn_bgn_dt <= psp.splt_pct_end_dt (+);
