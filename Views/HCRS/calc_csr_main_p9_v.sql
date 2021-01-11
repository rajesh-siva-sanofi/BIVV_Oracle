CREATE OR REPLACE VIEW hcrs.calc_csr_main_p9_v
AS
   SELECT
          /*+ calc_csr_main_p9_v
              QB_NAME( p9 )
              NO_MERGE
              LEADING( z r )
              USE_NL( z r )
              INDEX( r pk_mstr_trans_t )
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_p9_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part 9
   *
   *                ROOT DATA
   *
   *                Set parent transaction linking columns.
   *
   *                Gets the root data for SAP_ADJ, CARS_ADJ, and X360_ADJ
   *                linkages.
   *
   *                SAP/SAP4H adj hard link: force use of parent invoice date.
   *                SAP/SAP4H adj soft link: allow use of parent invoice date.
   *
   *                Align Earned Dates with Root: All transactions use the
   *                assc_invc_dt/earn_bgn_dt of root, then parent, then current.
   *
   *                Align Parent WAC Price with Root: All transactions use the
   *                wac_price of root, then parent.
   *
   *                Align WAC Price with Root: All transactions use the wac_price
   *                of root, then parent, then current.
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
   *                            Move coalesce root, parent, current later
   *                            Simplify WAC/Term%/Earn/Paid root/parent, coalesce
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add SAP4H source system code column
   *                            Add SAP4H to SAP Hard/Soft Linking
   *  08/28/2020  Joe Kidd      CHG-187461: Terms Percent Treatment for Direct Adjs
   *                            Remove root and parent terms percent
   ****************************************************************************/
          -- Source --------------------------------------------------------------------------------
          z.rec_src_ind,
          z.co_id,
          -- Customer ------------------------------------------------------------------------------
          z.cust_id,
          z.orig_cust_id,
          z.cust_cls_of_trd_cd,
          -- Root Customer -------------------------------------------------------------------------
          r.cust_id root_cust_id,
          -- Parent Customer -----------------------------------------------------------------------
          COALESCE( DECODE( z.parent_link_ind, z.flag_no, z.cust_id), z.parent_cust_id, z.cust_id) parent_cust_id,
          -- Product -------------------------------------------------------------------------------
          z.ndc_lbl,
          z.ndc_prod,
          z.ndc_pckg,
          -- Component -----------------------------------------------------------------------------
          -- Root Identifiers ----------------------------------------------------------------------
          r.trans_cls_cd root_trans_cls_cd,
          r.source_sys_cde root_source_sys_cde,
          -- Trim contract ID in case it only has spaces, thanks IQVIA
          TRIM( r.contr_id) root_contr_id,
          r.lgcy_trans_no root_lgcy_trans_no,
          -- Marking Trans Date --------------------------------------------------------------------
          -- Parent Identifiers --------------------------------------------------------------------
          COALESCE( z.parent_trans_cls_cd, z.trans_cls_cd) parent_trans_cls_cd,
          COALESCE( z.parent_source_sys_cde, z.source_sys_cde) parent_source_sys_cde,
          -- Use NVL2 to handle when root and/or parent found but contract id is null
          DECODE( z.parent_link_ind, z.flag_no, z.contr_id, NVL2( z.parent_trans_id, z.parent_contr_id, z.contr_id)) parent_contr_id,
          COALESCE( z.parent_lgcy_trans_no, z.assc_invc_no, z.lgcy_trans_no) parent_lgcy_trans_no,
          COALESCE( z.parent_lgcy_trans_line_no, z.lgcy_trans_line_no) parent_lgcy_trans_line_no,
          -- Trans Identifiers ---------------------------------------------------------------------
          z.trans_cls_cd,
          z.source_sys_cde,
          z.contr_id,
          z.lgcy_trans_no,
          z.assc_invc_no,
          z.lgcy_trans_line_no,
          -- Trans IDs -----------------------------------------------------------------------------
          r.trans_id root_trans_id,
          COALESCE( DECODE( z.parent_link_ind, z.flag_no, z.trans_id), z.parent_trans_id, z.trans_id) parent_trans_id,
          z.trans_id,
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
          z.parent_link_ind,
          -- Related Trans -------------------------------------------------------------------------
          -- Prasco Rebates Link -------------------------------------------------------------------
          -- Trans Flags ---------------------------------------------------------------------------
          z.source_trans_typ,
          -- Sales Exclusion -----------------------------------------------------------------------
          -- Root Keys/Dates -----------------------------------------------------------------------
          r.paid_dt root_paid_dt,
          -- Parent Keys/Dates ---------------------------------------------------------------------
          z.parent_assc_invc_no,
          -- Transaction Dates ---------------------------------------------------------------------
          CASE
             -- SAP/SAP4H adjustment hard linking (force paid date to original invoice)
             WHEN z.source_sys_cde IN (z.system_sap,
                                       z.system_sap4h)
              AND z.parent_link_ind = z.sap_adj_dt_mblty_hrd_lnk
             THEN NVL( z.parent_paid_dt, z.paid_dt)
             ELSE z.paid_dt
          END paid_dt,
          CASE
             -- SAP adjustment soft linking, allow use of parent invoice date
             WHEN z.source_sys_cde IN (z.system_sap,
                                       z.system_sap4h)
              AND z.parent_link_ind = z.sap_adj_dt_mblty_sft_lnk
             THEN z.parent_paid_dt
          END alt_paid_dt,
          -- Align Earned Dates with Root: All transactions use the assc_invc_dt/earn_bgn_dt of root, then parent, then current
          COALESCE( r.assc_invc_dt, r.earn_bgn_dt, z.parent_assc_invc_dt, z.parent_earn_bgn_dt, z.assc_invc_dt, z.earn_bgn_dt) earn_bgn_dt,
          COALESCE( r.assc_invc_dt, r.earn_end_dt, z.parent_assc_invc_dt, z.parent_earn_end_dt, z.assc_invc_dt, z.earn_end_dt) earn_end_dt,
          -- Root Values ---------------------------------------------------------------------------
          -- Parent Values -------------------------------------------------------------------------
          -- Align Parent WAC Price with Root: All transactions use the wac_price of root, then parent
          COALESCE( r.wac_price, z.parent_wac_price) parent_wac_price,
          z.parent_pkg_qty,
          z.parent_total_amt,
          z.parent_whls_chrgbck_amt,
          z.parent_wac_extnd_amt,
          -- Transaction Values --------------------------------------------------------------------
          -- Align WAC Price with Root: All transactions use the wac_price of root, then parent, then current
          COALESCE( r.wac_price, z.parent_wac_price, z.wac_price) wac_price,
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
     FROM hcrs.calc_csr_main_p8_v z,
          hcrs.mstr_trans_t r
    WHERE COALESCE( z.root_trans_id_sap_adj,
                    z.root_trans_id_cars_adj,
                    z.root_trans_id_x360_adj) = r.trans_id (+);
