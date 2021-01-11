CREATE OR REPLACE VIEW hcrs.calc_csr_main_p6_v
AS
   SELECT
          /*+ calc_csr_main_p6_v
              QB_NAME( p6 )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_p6_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part 6
   *
   *                PARENT LOOKUP 2
   *
   *                Gets the parent trans_id for CARS_ADJ linkage for RMUS/CARS
   *                chargebacks and for RMUS/CARS rebates not already linked.
   *                This link is done as a scalar subquery because there may be
   *                more than one parent transaction and the index used contains
   *                all columns required to meet the join conditions and return
   *                the parent trans_id.
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
   *                            All lookups no longer join on cust ID/contract ID
   *                            Streamline lookups and customer indexes so there
   *                            is no table access to get trans_id
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add Assoc invoice source system code column
   *                            Add SAP4H source system code column
   *  08/28/2020  Joe Kidd      CHG-187461: Terms Percent Treatment for Direct Adjs
   *                            Remove parent terms percent
   ****************************************************************************/
          -- Source --------------------------------------------------------------------------------
          z.rec_src_ind,
          z.co_id,
          -- Customer ------------------------------------------------------------------------------
          z.cust_id,
          z.orig_cust_id,
          z.cust_cls_of_trd_cd,
          -- Root Customer -------------------------------------------------------------------------
          -- Parent Customer -----------------------------------------------------------------------
          z.parent_cust_id,
          -- Product -------------------------------------------------------------------------------
          z.ndc_lbl,
          z.ndc_prod,
          z.ndc_pckg,
          -- Component -----------------------------------------------------------------------------
          -- Root Identifiers ----------------------------------------------------------------------
          -- Marking Trans Date --------------------------------------------------------------------
          -- Parent Identifiers --------------------------------------------------------------------
          z.parent_trans_cls_cd,
          z.parent_source_sys_cde,
          z.parent_contr_id,
          z.parent_lgcy_trans_no,
          z.parent_lgcy_trans_line_no,
          z.parent_assc_invc_source_sys_cd,
          -- Trans Identifiers ---------------------------------------------------------------------
          z.trans_cls_cd,
          z.source_sys_cde,
          z.contr_id,
          z.lgcy_trans_no,
          z.assc_invc_no,
          z.lgcy_trans_line_no,
          z.assc_invc_source_sys_cde,
          -- Trans IDs -----------------------------------------------------------------------------
          z.parent_trans_id,
          z.trans_id,
          -- Root Lookup IDs -----------------------------------------------------------------------
          -- Parent Lookup IDs ---------------------------------------------------------------------
          z.parent_trans_id_sap_adj,
          z.parent_trans_id_icw_key,
          z.parent_trans_id_cars_rbt_fee,
          -- CARS_ADJ: RMUS/CARS chargeback/rebate parent lookup
          -- Applied here after RMUS/CARS rebates linked to chargebacks
          -- eliminated in previous query block
          CASE
             WHEN z.rec_src_ind = z.rec_src_icw
              AND z.trans_cls_cd IN (z.trans_cls_idr,
                                     z.trans_cls_rbt)
              AND z.source_sys_cde = z.system_cars
              AND z.parent_trans_id_icw_key IS NULL
              AND z.parent_trans_id_cars_rbt_fee IS NULL
              AND z.assc_invc_no IS NOT NULL
             THEN (  -- Use MIN as there may be more than one line
                     SELECT /*+ QB_NAME( p6_cars )
                                NO_MERGE
                                INDEX( rt mstr_trans_ix503 )
                                DYNAMIC_SAMPLING( 0 )
                            */
                            MIN( rt.trans_id) trans_id
                       FROM hcrs.mstr_trans_t rt
                         -- Same data source, not archived, no manual adjustments, limit snapshot
                      WHERE rt.rec_src_ind = z.rec_src_ind
                        AND rt.co_id = z.co_id
                        AND rt.archive_ind = z.archive_ind
                        AND rt.snpsht_id <= z.snpsht_id
                         -- Customer ID must match to link to parent transaction, however
                         -- Customer ID does not need to match to obtain Gross Dollars/Units/Packages
                         --AND rt0.cust_id = z.cust_id
                         -- Must be same NDC
                        AND rt.ndc_lbl = z.ndc_lbl
                        AND rt.ndc_prod = z.ndc_prod
                        AND rt.ndc_pckg = z.ndc_pckg
                         -- Must be a RMUS/CARS chargeback/rebate same as this chargeback/rebate
                        AND rt.source_sys_cde = z.source_sys_cde
                        AND rt.trans_cls_cd = z.trans_cls_cd
                         -- Contract ID must match to link to parent transaction, however
                         -- Contract ID does not need to match to obtain Gross Dollars/Units/Packages
                         -- (RMUS/CARS always has a contract)
                        --AND rt.contr_id = z.contr_id
                         -- Link to original transaction
                        AND rt.lgcy_trans_no = z.assc_invc_no
                        AND rt.earn_bgn_dt = z.earn_bgn_dt
                         -----------------------------------------------------
                         -- Partition pruning - THESE MAKE A HUGE DIFFERENCE!!
                         -----------------------------------------------------
                         -- Parent chargeback/rebate will be paid on or before this chargeback/rebate
                        AND rt.paid_dt <= (z.paid_dt + z.prune_days)
                         -- Parent chargeback will be paid on or after when this chargeback was earned
                        AND rt.paid_dt >= (z.earn_bgn_dt - z.prune_days)
                  )
          END parent_trans_id_cars_adj,
          z.parent_trans_id_x360_adj,
          z.parent_trans_id_prasco_rbtfee,
          -- Link Markers --------------------------------------------------------------------------
          -- Related Trans -------------------------------------------------------------------------
          -- Prasco Rebates Link -------------------------------------------------------------------
          -- Trans Flags ---------------------------------------------------------------------------
          z.source_trans_typ,
          -- Sales Exclusion -----------------------------------------------------------------------
          -- Root Keys/Dates -----------------------------------------------------------------------
          -- Parent Keys/Dates ---------------------------------------------------------------------
          z.parent_paid_dt,
          z.parent_earn_bgn_dt,
          z.parent_earn_end_dt,
          z.parent_assc_invc_dt,
          z.parent_assc_invc_no,
          -- Transaction Dates ---------------------------------------------------------------------
          z.paid_dt,
          z.earn_bgn_dt,
          z.earn_end_dt,
          z.assc_invc_dt,
          -- Root Values ---------------------------------------------------------------------------
          -- Parent Values -------------------------------------------------------------------------
          z.parent_wac_price,
          z.parent_pkg_qty,
          z.parent_total_amt,
          z.parent_whls_chrgbck_amt,
          z.parent_wac_extnd_amt,
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
          z.whls_cot_incl_ind,
          z.whls_cot_grp_cd,
          z.whls_loc_cd,
          z.whls_cot_eff_strt_dt,
          z.whls_cot_eff_end_dt,
          z.whls_cot_begn_dt,
          z.whls_cot_end_dt,
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
          z.bndl_src_sys_ind,
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
          z.cot_hhs_grantee,
          z.tt_indirect_sales,
          z.tt_rebates,
          z.tt_fee,
          z.tt_factr_rbt_fee,
          z.tt_govt
          -- Marking data --------------------------------------------------------------------------
          -- Cursor Row Count ----------------------------------------------------------------------
     FROM hcrs.calc_csr_main_p5_v z;
