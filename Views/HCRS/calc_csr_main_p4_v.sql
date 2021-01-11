CREATE OR REPLACE VIEW hcrs.calc_csr_main_p4_v
AS
   SELECT
          /*+ calc_csr_main_p4_v
              QB_NAME( p4 )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_p4_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part 4
   *
   *                FILTER WHOLESALER
   *
   *                Filter for wholesalers with classes of trade and transaction
   *                type combinations required by the calculation. The matrix GTT
   *                has been pre-filtered for COTs/TTs required by the
   *                calculation components and estimations.
   *
   *                Because effective dates are based on earn date, and all
   *                earn dates have not yet been determined, effective date
   *                filters are not applied at this time.
   *
   *                Swap assc_invc_no and lgcy_trans_line_no for Prasco
   *                rebates/fees linking for easier linking.
   *
   *                Combine related sales and credits IDs for easy linking.
   *
   *                Determine parent transaction class (direct/indiredt) for
   *                Prasco rebate/fee.
   *
   *                Set default wholesaler values for direct sales and
   *                rebates/fees.
   *
   *                Set Bundle Source System Flag.
   *
   *                This view only returns data when the calculation environment
   *                has been initialized with pkg_common_procedures.p_init_calc.
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
   *                            Group columns, GTT column reduction, Adjust hints
   *                            Remove DISTINCT: Too expensive, components will
   *                            prevent duplicates
   *                            Move ICW_KEY invoice changes to later
   *                            Move Swap Prasco invc line/assc invc numbers here
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add Assoc invoice source system code column
   *                            Add SAP4H source system code column
   *                            Add SAP4H source system to Bundle Source Systems
   *  08/01/2020  Joe Kidd      CHG-198490: Bioverativ Integration
   *                            Add Bioverative Source Systems and Trans Adjs
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
          -- Parent Identifiers --------------------------------------------------------------------
          -- Trans Identifiers ---------------------------------------------------------------------
          z.trans_cls_cd,
          z.source_sys_cde,
          -- Trim contract ID in case it only has spaces, thanks IQVIA
          TRIM( z.contr_id) contr_id,
          z.lgcy_trans_no,
          CASE
             -- Swap assc_invc_no and lgcy_trans_line_no for Prasco linking
             WHEN z.source_sys_cde = z.system_prasco
             THEN z.lgcy_trans_line_no
             ELSE z.assc_invc_no
          END assc_invc_no,
          CASE
             -- Swap assc_invc_no and lgcy_trans_line_no for Prasco linking
             WHEN z.source_sys_cde = z.system_prasco
             THEN z.assc_invc_no
             ELSE z.lgcy_trans_line_no
          END lgcy_trans_line_no,
          z.assc_invc_source_sys_cde,
          -- Trans IDs -----------------------------------------------------------------------------
          z.trans_id,
          -- Root Lookup IDs -----------------------------------------------------------------------
          -- Parent Lookup IDs ---------------------------------------------------------------------
          -- Link Markers --------------------------------------------------------------------------
          -- Related Trans -------------------------------------------------------------------------
          NVL2( z.related_sales_id, z.src_tbl_iis, NVL2( z.related_credits_id, z.src_tbl_iic, '')) related_src_tbl_cd,
          NVL( z.related_sales_id, z.related_credits_id) related_unique_id,
          -- Prasco Rebates Link -------------------------------------------------------------------
          DECODE( z.src_tbl_cd,
                  z.src_tbl_ipdr, z.trans_cls_dir,
                  z.src_tbl_ipir, z.trans_cls_idr) prasco_rbt_trans_cls_cd,
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
          -- Set default values for non-chargebacks
          NVL( z.whls_cot_incl_ind, z.whls_cot_incl_ind_noncbk) whls_cot_incl_ind,
          NVL( z.whls_cot_grp_cd, z.whls_cot_grp_cd_noncbk) whls_cot_grp_cd,
          NVL( z.whls_loc_cd, z.whls_loc_cd_noncbk) whls_loc_cd,
          NVL( z.whls_cot_eff_strt_dt, z.begin_time) whls_cot_eff_strt_dt,
          NVL( z.whls_cot_eff_end_dt, z.end_time) whls_cot_eff_end_dt,
          NVL( z.whls_cot_begn_dt, z.begin_time) whls_cot_begn_dt,
          NVL( z.whls_cot_end_dt, z.end_time) whls_cot_end_dt,
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
          CASE
             -- Set the bundle source system flag
             -- 4.1. The transaction must be an RMUS/CARS or SAP/SAP4H
             --      transaction.  This implies that no manual adjustments
             --      will be processed for bundling.
             WHEN z.source_sys_cde IN (z.system_cars,
                                       z.system_sap,
                                       z.system_sap4h)
             THEN z.flag_yes
             ELSE z.flag_no
          END bndl_src_sys_ind,
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
          z.rec_src_icw,
          z.co_gnz,
          z.source_trans_credits,
          z.system_sap,
          z.system_sap4h,
          z.system_cars,
          z.system_x360,
          z.system_prasco,
          z.system_bivvrxc,
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
          z.trans_adj_bivv_adj,
          z.sap_adj_dt_mblty_hrd_lnk,
          z.sap_adj_dt_mblty_sft_lnk,
          z.cot_hhs_grantee,
          z.tt_indirect_sales,
          z.tt_rebates,
          z.tt_fee,
          z.tt_factr_rbt_fee,
          z.tt_govt
          -- Marking data --------------------------------------------------------------------------
          -- Cursor Row Count ----------------------------------------------------------------------
     FROM hcrs.calc_csr_main_p3_v z
       --------------------------------------------------------------------
       -- Z: Eliminate rows with wholesaler but no COT SG was found
    WHERE NOT (    z.whls_id IS NOT NULL
               AND z.whls_cot_grp_cd IS NULL)
       --------------------------------------------------------------------
       -- Z: Eliminate rows with wholesaler but earn/paid date doesn't match
      AND (   (    z.uses_paid_dt = z.flag_yes
               AND NVL( z.whls_uses_paid_dt, z.flag_yes) = z.flag_yes)
           OR (    z.uses_earn_dt = z.flag_yes
               AND NVL( z.whls_uses_earn_dt, z.flag_yes) = z.flag_yes)
          );
