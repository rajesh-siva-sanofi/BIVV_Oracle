CREATE OR REPLACE VIEW hcrs.calc_csr_main_p3_v
AS
   SELECT
          /*+ calc_csr_main_p3_v
              QB_NAME( p3 )
              NO_MERGE
              LEADING( z pmw )
              USE_NL( z pmw )
              INDEX( pmw prfl_mtrx_wrk_ix2 )
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_p3_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part 3
   *
   *                WHOLESALER MATRIX
   *
   *                Filter for wholesalers required by the calculation. The
   *                customer class of trade GTT has been pre-filtered for COTs
   *                required by the calculation components and estimations.
   *
   *                Add wholesaler class of trade and transaction type
   *                combination information. An outer-join is required because
   *                only indirect sales have a wholesaler. No rows are filtered
   *                at this time.
   *
   *                Because effective dates are based on earn date, and all
   *                earn dates have not yet been determined, effective date
   *                filters are not applied at this time.
   *
   *                This view only returns data when the calculation environment
   *                has been initialized with pkg_common_procedures.p_init_calc.
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
   *                            Add Assoc invoice source system code column
   *                            Add SAP4H source system code column
   ****************************************************************************/
          -- Source --------------------------------------------------------------------------------
          z.rec_src_ind,
          z.co_id,
          -- Customer ------------------------------------------------------------------------------
          z.cust_id,
          z.cust_cls_of_trd_cd,
          -- Root Customer -------------------------------------------------------------------------
          -- Parent Customer -----------------------------------------------------------------------
          -- Product -------------------------------------------------------------------------------
          z.ndc_lbl,
          z.ndc_prod,
          z.ndc_pckg,
          -- Component -----------------------------------------------------------------------------
          -- Root Identifiers ----------------------------------------------------------------------
          -- Marking Trans Date --------------------------------------------------------------------
          z.uses_paid_dt,
          z.uses_earn_dt,
          -- Parent Identifiers --------------------------------------------------------------------
          -- Trans Identifiers ---------------------------------------------------------------------
          z.trans_cls_cd,
          z.source_sys_cde,
          z.contr_id,
          z.lgcy_trans_no,
          z.assc_invc_no,
          z.lgcy_trans_line_no,
          z.assc_invc_source_sys_cde,
          -- Trans IDs -----------------------------------------------------------------------------
          z.trans_id,
          -- Root Lookup IDs -----------------------------------------------------------------------
          -- Parent Lookup IDs ---------------------------------------------------------------------
          -- Link Markers --------------------------------------------------------------------------
          -- Related Trans -------------------------------------------------------------------------
          z.related_sales_id,
          z.related_credits_id,
          -- Prasco Rebates Link -------------------------------------------------------------------
          z.src_tbl_cd,
          -- Trans Flags ---------------------------------------------------------------------------
          z.archive_ind,
          z.source_trans_typ,
          -- Sales Exclusion -----------------------------------------------------------------------
          -- Root Keys/Dates -----------------------------------------------------------------------
          -- Parent Keys/Dates ---------------------------------------------------------------------
          -- Transaction Dates ---------------------------------------------------------------------
          z.paid_dt,
          z.earn_bgn_dt,
          z.earn_end_dt,
          z.assc_invc_dt,
          -- Root Values ---------------------------------------------------------------------------
          -- Parent Values -------------------------------------------------------------------------
          -- Transaction Values --------------------------------------------------------------------
          z.wac_price,
          z.pkg_qty,
          z.claim_unit_qty,
          z.total_amt,
          z.term_disc_pct,
          z.whls_chrgbck_amt,
          z.gross_sale_amt,
          z.wac_extnd_amt,
          -- Component Values ----------------------------------------------------------------------
          -- Customer COT --------------------------------------------------------------------------
          z.cust_cot_incl_ind,
          z.cust_cot_grp_cd,
          z.cust_loc_cd,
          z.cust_cot_eff_strt_dt,
          z.cust_cot_eff_end_dt,
          z.cust_cot_begn_dt,
          z.cust_cot_end_dt,
          -- Wholesaler COT ------------------------------------------------------------------------
          z.whls_id,
          pmw.cot_incl_ind whls_cot_incl_ind,
          pmw.cot_grp_cd whls_cot_grp_cd,
          z.whls_loc_cd,
          z.whls_cot_eff_strt_dt,
          z.whls_cot_eff_end_dt,
          pmw.cot_begn_dt whls_cot_begn_dt,
          pmw.cot_end_dt whls_cot_end_dt,
          pmw.uses_paid_dt whls_uses_paid_dt,
          pmw.uses_earn_dt whls_uses_earn_dt,
          -- Transaction Type ----------------------------------------------------------------------
          z.trans_typ_cd,
          z.trans_typ_incl_ind,
          z.trans_typ_grp_cd,
          z.tt_begn_dt,
          z.tt_end_dt,
          -- Profile Calc Data ---------------------------------------------------------------------
          z.prfl_id,
          z.snpsht_id,
          -- Product Units -------------------------------------------------------------------------
          z.unit_per_pckg,
          z.comm_unit_per_pckg,
          -- Bundling ------------------------------------------------------------------------------
          z.bndl_prod,
          z.min_bndl_start_dt,
          z.max_bndl_end_dt,
          -- Trans Linking -------------------------------------------------------------------------
          z.sap_adj_dt_mblty,
          z.prune_days,
          -- Estimations ---------------------------------------------------------------------------
          -- Component Checks ----------------------------------------------------------------------
          -- Units Component -----------------------------------------------------------------------
          -- Component Dollars ---------------------------------------------------------------------
          -- Trans Settings ------------------------------------------------------------------------
          -- Nominal Settings ----------------------------------------------------------------------
          -- Sub-PHS Settings ----------------------------------------------------------------------
          -- Trans Groupings -----------------------------------------------------------------------
          -- Constants -----------------------------------------------------------------------------
          z.flag_yes,
          z.flag_no,
          z.begin_time,
          z.end_time,
          z.rec_src_icw,
          z.co_gnz,
          z.src_tbl_iis,
          z.src_tbl_iic,
          z.src_tbl_ipdr,
          z.src_tbl_ipir,
          z.source_trans_credits,
          z.system_sap,
          z.system_sap4h,
          z.system_cars,
          z.system_x360,
          z.system_prasco,
          z.trans_cls_dir,
          z.trans_cls_idr,
          z.trans_cls_rbt,
          z.trans_adj_original,
          z.trans_adj_sap_adj,
          z.trans_adj_cars_rbt_fee,
          z.trans_adj_cars_adj,
          z.trans_adj_icw_key,
          z.trans_adj_x360_adj,
          z.trans_adj_prasco_rbtfee,
          z.sap_adj_dt_mblty_hrd_lnk,
          z.sap_adj_dt_mblty_sft_lnk,
          z.whls_cot_grp_cd_noncbk,
          z.whls_cot_incl_ind_noncbk,
          z.whls_loc_cd_noncbk,
          z.cot_hhs_grantee,
          z.tt_indirect_sales,
          z.tt_rebates,
          z.tt_fee,
          z.tt_factr_rbt_fee,
          z.tt_govt
          -- Marking data --------------------------------------------------------------------------
          -- Cursor Row Count ----------------------------------------------------------------------
     FROM hcrs.calc_csr_main_p2_v z,
          hcrs.prfl_mtrx_wrk_t pmw
       --------------------------------------------------------------------
       -- Z-PMW: Link transactions to Wholesaler COT/TT
       -- Outer join because only chargebacks have a wholesaler
       -- Effective dates will be handled later after true
       -- transaction earned date is determined
    WHERE z.whls_cls_of_trd_cd = pmw.cls_of_trd_cd (+)
      AND z.trans_typ_cd = pmw.trans_typ_cd (+)
      AND z.trans_typ_incl_ind = pmw.incl_ind (+)
      AND z.trans_typ_grp_cd = pmw.trans_typ_grp_cd (+)
      AND z.tt_begn_dt = pmw.tt_begn_dt (+)
      AND z.tt_end_dt = pmw.tt_end_dt (+)
       --------------------------------------------------------------------
       -- Z: Eliminate rows with wholesaler but no COT was found
      AND NOT (    z.whls_id IS NOT NULL
               AND z.whls_cls_of_trd_cd IS NULL);
