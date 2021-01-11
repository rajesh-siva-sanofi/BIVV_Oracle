CREATE OR REPLACE VIEW hcrs.calc_csr_main_final_v
AS
   SELECT
          /*+ calc_csr_main_final_v
              QB_NAME( final )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_final_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, final part
   *
   *                COUNT ROWS
   *
   *                Count rows.  Order moved to pkg_common_cursors.f_csr_main().
   *
   *                This only works when the calculation environment has been
   *                initialized with pkg_common_procedures.p_init_calc.
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
   *                            Group columns, GTT column reduction, Adjust hints
   *  08/01/2020  Joe Kidd      CHG-198490: Bioverativ Integration
   *                            Add Bioverative direct adjustment lookups
   ****************************************************************************/
          -- Source --------------------------------------------------------------------------------
          z.rec_src_ind,
          z.co_id,
          -- Customer ------------------------------------------------------------------------------
          z.cust_id,
          z.orig_cust_id,
          z.cust_cls_of_trd_cd,
          -- Root Customer -------------------------------------------------------------------------
          z.root_cust_id,
          -- Parent Customer -----------------------------------------------------------------------
          z.parent_cust_id,
          -- Product -------------------------------------------------------------------------------
          z.ndc_lbl,
          z.ndc_prod,
          z.ndc_pckg,
          -- Component -----------------------------------------------------------------------------
          z.comp_typ_cd,
          z.mark_accum_all_ind,
          z.mark_accum_nom_ind,
          z.mark_accum_hhs_ind,
          z.mark_accum_contr_ind,
          z.mark_accum_fsscontr_ind,
          z.mark_accum_phscontr_ind,
          z.mark_accum_zerodllrs_ind,
          -- Root Identifiers ----------------------------------------------------------------------
          z.root_trans_cls_cd,
          z.root_source_sys_cde,
          z.root_contr_id,
          z.root_lgcy_trans_no,
          -- Marking Trans Date --------------------------------------------------------------------
          z.trans_dt,
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
          z.trans_adj_cd,
          -- Root Lookup IDs -----------------------------------------------------------------------
          z.root_trans_id_sap_adj,
          z.root_trans_id_cars_adj,
          z.root_trans_id_x360_adj,
          z.root_trans_id_bivv_adj,
          -- Parent Lookup IDs ---------------------------------------------------------------------
          z.parent_trans_id_sap_adj,
          z.parent_trans_id_icw_key,
          z.parent_trans_id_cars_rbt_fee,
          z.parent_trans_id_cars_adj,
          z.parent_trans_id_x360_adj,
          z.parent_trans_id_bivv_adj,
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
          z.earn_bgn_dt,
          z.earn_end_dt,
          -- Root Values ---------------------------------------------------------------------------
          -- Parent Values -------------------------------------------------------------------------
          -- Transaction Values --------------------------------------------------------------------
          -- Component Values ----------------------------------------------------------------------
          z.dllrs_grs,
          z.dllrs_wac,
          z.dllrs_net,
          z.dllrs_dsc,
          z.dllrs_ppd,
          z.pkgs,
          z.units,
          -- Customer COT --------------------------------------------------------------------------
          z.cust_cot_incl_ind,
          z.cust_cot_grp_cd,
          z.cust_loc_cd,
          -- Wholesaler COT ------------------------------------------------------------------------
          z.whls_cot_incl_ind,
          z.whls_cot_grp_cd,
          z.whls_loc_cd,
          -- Transaction Type ----------------------------------------------------------------------
          z.trans_typ_cd,
          z.trans_typ_incl_ind,
          z.trans_typ_grp_cd,
          -- Profile Calc Data ---------------------------------------------------------------------
          -- Product Units -------------------------------------------------------------------------
          -- Bundling ------------------------------------------------------------------------------
          z.bndl_prod,
          z.bndl_src_sys_ind,
          z.bndl_comp_tran_ind,
          z.bndl_comp_nom_ind,
          z.bndl_comp_hhs_ind,
          -- Trans Linking -------------------------------------------------------------------------
          -- Estimations ---------------------------------------------------------------------------
          z.splt_pct_typ,
          z.splt_pct_seq_no,
          -- Component Checks ----------------------------------------------------------------------
          z.chk_contr,
          z.chk_phs_pvp_contr,
          z.chk_phs_contr,
          z.chk_fss_contr,
          z.chk_nom,
          z.chk_hhs,
          -- Units Component -----------------------------------------------------------------------
          z.units_comp_typ_cd,
          -- Component Dollars ---------------------------------------------------------------------
          z.comp_dllrs,
          -- Trans Settings ------------------------------------------------------------------------
          z.tran_dllrs,
          z.tran_pckgs,
          z.tran_ppd,
          z.tran_bndl,
          -- Nominal Settings ----------------------------------------------------------------------
          z.nom_chk_dllrs,
          z.nom_chk_pckgs,
          z.nom_chk_ppd,
          z.nom_chk_bndl,
          -- Sub-PHS Settings ----------------------------------------------------------------------
          z.hhs_chk_dllrs,
          z.hhs_chk_pckgs,
          z.hhs_chk_ppd,
          z.hhs_chk_bndl,
          -- Trans Groupings -----------------------------------------------------------------------
          z.root_trans_grp,
          z.parent_trans_grp,
          z.trans_grp,
          z.trans_ord,
          -- Constants -----------------------------------------------------------------------------
          -- Marking data --------------------------------------------------------------------------
          -- Cursor Row Count ----------------------------------------------------------------------
          COUNT(*) OVER () csr_cnt
     FROM hcrs.calc_csr_main_pl_v z;
