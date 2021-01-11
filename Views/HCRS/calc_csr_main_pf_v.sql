CREATE OR REPLACE VIEW hcrs.calc_csr_main_pf_v
AS
   SELECT
          /*+ calc_csr_main_pf_v
              QB_NAME( pf )
              NO_MERGE
              LEADING( z pcd )
              USE_NL( z pcd )
              INDEX( pcd prfl_prod_calc_comp_def2_w_ix1 )
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_pf_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part F (15)
   *
   *                COMPONENT DEFINTIONS
   *
   *                Apply component classifications, define marking, linking
   *                date, and linking earn date
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
   *                            Add SAP4H to SAP Link date
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
          pcd.comp_typ_cd,
          pcd.mark_accum_all_ind,
          pcd.mark_accum_nom_ind,
          pcd.mark_accum_hhs_ind,
          pcd.mark_accum_contr_ind,
          pcd.mark_accum_fsscontr_ind,
          pcd.mark_accum_phscontr_ind,
          pcd.mark_accum_zerodllrs_ind,
          -- Root Identifiers ----------------------------------------------------------------------
          z.root_trans_cls_cd,
          z.root_source_sys_cde,
          z.root_contr_id,
          z.root_lgcy_trans_no,
          -- Marking Trans Date --------------------------------------------------------------------
          -- Only one of the component dates (paid or earn) will be populated
          CASE
             WHEN z.alt_paid_dt BETWEEN pcd.comp_paid_bgn_dt AND pcd.comp_paid_end_dt
             THEN z.alt_paid_dt
             WHEN z.paid_dt BETWEEN pcd.comp_paid_bgn_dt AND pcd.comp_paid_end_dt
             THEN z.paid_dt
             WHEN z.earn_bgn_dt BETWEEN pcd.comp_earn_bgn_dt AND pcd.comp_earn_end_dt
             THEN z.earn_bgn_dt
          END trans_dt,
          CASE
             -- Earn date always links when earn date used
             WHEN z.earn_bgn_dt BETWEEN pcd.comp_earn_bgn_dt AND pcd.comp_earn_end_dt
             THEN z.earn_bgn_dt
             -- SAP/SAP4H always links if paid date or earn date used
             WHEN z.source_sys_cde IN (z.system_sap,
                                       z.system_sap4h)
             THEN TO_DATE( NULL)
             -- CARS Rebates link by paid date when paid date used
             WHEN z.source_sys_cde = z.system_cars
              AND z.trans_cls_cd = z.trans_cls_rbt
             THEN z.paid_dt
             -- X360 Rebates link by paid date when paid date used
             WHEN z.source_sys_cde = z.system_x360
              AND z.trans_cls_cd = z.trans_cls_rbt
             THEN z.paid_dt
             -- Others do not link when paid date used
             -- Adding (trans_id / 86400) increases the paid_dt a different amount for every trans
             WHEN z.paid_dt BETWEEN pcd.comp_paid_bgn_dt AND pcd.comp_paid_end_dt
             THEN z.paid_dt + (z.trans_id / 86400)
          END link_trans_dt,
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
          pcd.bndl_comp_tran_ind,
          pcd.bndl_comp_nom_ind,
          pcd.bndl_comp_hhs_ind,
          -- Trans Linking -------------------------------------------------------------------------
          -- Estimations ---------------------------------------------------------------------------
          z.splt_pct_ord,
          z.splt_pct_typ,
          z.splt_pct_seq_no,
          -- Component Checks ----------------------------------------------------------------------
          z.chk_contr,
          z.chk_phs_pvp_contr,
          z.chk_phs_contr,
          z.chk_fss_contr,
          -- Allow calculated Nominal/sub-PHS to override component setting
          NVL( z.chk_nom, pcd.chk_nom) chk_nom,
          NVL( z.chk_hhs, pcd.chk_hhs) chk_hhs,
          -- Units Component -----------------------------------------------------------------------
          pcd.units_comp_typ_cd,
          -- Component Dollars ---------------------------------------------------------------------
          pcd.comp_dllrs,
          -- Trans Settings ------------------------------------------------------------------------
          pcd.tran_dllrs,
          pcd.tran_pckgs,
          pcd.tran_ppd,
          pcd.tran_bndl,
          -- Nominal Settings ----------------------------------------------------------------------
          pcd.nom_chk_dllrs,
          pcd.nom_chk_pckgs,
          pcd.nom_chk_ppd,
          pcd.nom_chk_bndl,
          -- Sub-PHS Settings ----------------------------------------------------------------------
          pcd.hhs_chk_dllrs,
          pcd.hhs_chk_pckgs,
          pcd.hhs_chk_ppd,
          pcd.hhs_chk_bndl,
          -- Trans Groupings -----------------------------------------------------------------------
          -- Constants -----------------------------------------------------------------------------
          z.flag_yes,
          z.flag_no
          -- Marking data --------------------------------------------------------------------------
          -- Cursor Row Count ----------------------------------------------------------------------
     FROM hcrs.calc_csr_main_pe_v z,
          hcrs.prfl_prod_calc_comp_def2_wrk_t pcd
       -- Qualify the transaction type supergroup and eligibility
    WHERE z.trans_typ_grp_cd = pcd.trans_typ_grp_cd
      AND z.trans_typ_incl_ind = pcd.trans_typ_incl_ind
       -- Qualify the customer COT supergroup, eligibility, and location
      AND z.cust_cot_grp_cd = pcd.cust_cot_grp_cd
      AND z.cust_cot_incl_ind = pcd.cust_cot_incl_ind
      AND pcd.cust_loc_cd_list LIKE '%' || z.cust_loc_cd  || '%'
       -- Qualify the wholesaler COT supergroup, eligibility, and location
      AND z.whls_cot_grp_cd = pcd.whls_cot_grp_cd
      AND z.whls_cot_incl_ind = pcd.whls_cot_incl_ind
      AND pcd.whls_loc_cd_list LIKE '%' || z.whls_loc_cd  || '%'
       -- Only use active component definition rows
      AND pcd.active_ind = z.flag_yes
       -- Quailify the transaction date
       -- Only one set of component dates will be populated
      AND (   z.alt_paid_dt BETWEEN pcd.comp_paid_bgn_dt AND pcd.comp_paid_end_dt
           OR z.paid_dt BETWEEN pcd.comp_paid_bgn_dt AND pcd.comp_paid_end_dt
           OR z.earn_bgn_dt BETWEEN pcd.comp_earn_bgn_dt AND pcd.comp_earn_end_dt
          );
