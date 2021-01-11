CREATE OR REPLACE VIEW hcrs.calc_csr_main_p7_v
AS
   SELECT
          /*+ calc_csr_main_p7_v
              QB_NAME( p7 )
              NO_MERGE
              LEADING( z p )
              USE_NL( z p )
              INDEX( p pk_mstr_trans_t )
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_p7_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part 7
   *
   *                PARENT DATA
   *
   *                Gets the parent data for SAP_ADJ, CARS_RBT_FEE, CARS_ADJ,
   *                X360_ADJ, BIVV_ADJ, and PRASCO_RBTFEE linkages.
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
   *                            Move trans adj code to later
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add Assoc invoice source system code column
   *                            Add SAP4H source system code column
   *  08/28/2020  Joe Kidd      CHG-187461: Terms Percent Treatment for Direct Adjs
   *                            Remove parent terms percent
   *  08/01/2020  Joe Kidd      CHG-198490: Bioverativ Integration
   *                            Add Bioverative Source Systems and Trans Adjs
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
          -- Parent Customer -----------------------------------------------------------------------
          NVL( z.parent_cust_id, p.cust_id) parent_cust_id,
          -- Product -------------------------------------------------------------------------------
          z.ndc_lbl,
          z.ndc_prod,
          z.ndc_pckg,
          -- Component -----------------------------------------------------------------------------
          -- Root Identifiers ----------------------------------------------------------------------
          -- Marking Trans Date --------------------------------------------------------------------
          -- Parent Identifiers --------------------------------------------------------------------
          NVL( z.parent_trans_cls_cd, p.trans_cls_cd) parent_trans_cls_cd,
          NVL( z.parent_source_sys_cde, p.source_sys_cde) parent_source_sys_cde,
          -- Use NVL2 to allow for NULL contract ids when parent was found but it does not have a contract ID.
          -- Trim contract ID in case it only has spaces, thanks IQVIA
          TRIM( NVL2( z.parent_trans_id, z.parent_contr_id, p.contr_id)) parent_contr_id,
          NVL( z.parent_lgcy_trans_no, p.lgcy_trans_no) parent_lgcy_trans_no,
          NVL( z.parent_lgcy_trans_line_no, p.lgcy_trans_line_no) parent_lgcy_trans_line_no,
          -- Use NVL2 to allow for NULL when parent was found but it does not have a value
          NVL2( z.parent_trans_id, z.parent_assc_invc_source_sys_cd, p.assc_invc_source_sys_cde) parent_assc_invc_source_sys_cd,
          -- Trans Identifiers ---------------------------------------------------------------------
          z.trans_cls_cd,
          z.source_sys_cde,
          z.contr_id,
          z.lgcy_trans_no,
          z.assc_invc_no,
          z.lgcy_trans_line_no,
          -- Trans IDs -----------------------------------------------------------------------------
          NVL( z.parent_trans_id, p.trans_id) parent_trans_id,
          z.trans_id,
          -- Root Lookup IDs -----------------------------------------------------------------------
          -- Parent Lookup IDs ---------------------------------------------------------------------
          z.parent_trans_id_sap_adj,
          z.parent_trans_id_icw_key,
          z.parent_trans_id_cars_rbt_fee,
          z.parent_trans_id_cars_adj,
          z.parent_trans_id_x360_adj,
          z.parent_trans_id_bivv_adj,
          z.parent_trans_id_prasco_rbtfee,
          -- Link Markers --------------------------------------------------------------------------
          -- Related Trans -------------------------------------------------------------------------
          -- Prasco Rebates Link -------------------------------------------------------------------
          -- Trans Flags ---------------------------------------------------------------------------
          z.source_trans_typ,
          -- Sales Exclusion -----------------------------------------------------------------------
          -- Root Keys/Dates -----------------------------------------------------------------------
          -- Parent Keys/Dates ---------------------------------------------------------------------
          NVL( z.parent_paid_dt, p.paid_dt) parent_paid_dt,
          NVL( z.parent_earn_bgn_dt, p.earn_bgn_dt) parent_earn_bgn_dt,
          NVL( z.parent_earn_end_dt, p.earn_end_dt) parent_earn_end_dt,
          NVL( z.parent_assc_invc_dt, p.assc_invc_dt) parent_assc_invc_dt,
          NVL( z.parent_assc_invc_no, p.assc_invc_no) parent_assc_invc_no,
          -- Transaction Dates ---------------------------------------------------------------------
          z.paid_dt,
          z.earn_bgn_dt,
          z.earn_end_dt,
          z.assc_invc_dt,
          -- Root Values ---------------------------------------------------------------------------
          -- Parent Values -------------------------------------------------------------------------
          NVL( z.parent_wac_price, p.wac_price) parent_wac_price,
          NVL( z.parent_pkg_qty, p.pkg_qty) parent_pkg_qty,
          NVL( z.parent_total_amt, p.total_amt) parent_total_amt,
          NVL( z.parent_whls_chrgbck_amt, p.whls_chrgbck_amt) parent_whls_chrgbck_amt,
          NVL( z.parent_wac_extnd_amt, p.wac_extnd_amt) parent_wac_extnd_amt,
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
     FROM hcrs.calc_csr_main_p6_v z,
          hcrs.mstr_trans_t p
    WHERE COALESCE( z.parent_trans_id_cars_rbt_fee,
                    z.parent_trans_id_cars_adj,
                    z.parent_trans_id_sap_adj,
                    z.parent_trans_id_x360_adj,
                    z.parent_trans_id_bivv_adj,
                    z.parent_trans_id_prasco_rbtfee) = p.trans_id (+);
