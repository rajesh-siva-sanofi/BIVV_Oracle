CREATE OR REPLACE VIEW hcrs.calc_csr_main_p0_v
AS
   SELECT
          /*+ calc_csr_main_p0_v
              QB_NAME( p0_0_0 )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_p0_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part 0
   *
   *                TRANS UNION ALL
   *
   *                Concatenate paid date and earn date transaction queries.
   *
   *                This view only returns data when the calculation environment
   *                has been initialized with pkg_common_procedures.p_init_calc.
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
   *                            Group columns, GTT column reduction, Adjust hints
   *                            Add ICW_Key Sales/Credits for SAP adjs
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add Assoc invoice source system code column
   *                            Add SAP4H source system code column
   ****************************************************************************/
          --------------------------------------------------------------------------------
          -- P0-0: Paid date section
          --------------------------------------------------------------------------------
          -- Source --------------------------------------------------------------------------------
          z.rec_src_ind,
          z.co_id,
          -- Customer ------------------------------------------------------------------------------
          z.cust_id,
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
          -- Wholesaler COT ------------------------------------------------------------------------
          z.whls_id,
          -- Transaction Type ----------------------------------------------------------------------
          z.trans_typ_cd,
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
     FROM hcrs.calc_csr_main_p0_0_v z
   UNION ALL
   --------------------------------------------------------------------------------
   -- P0-1: Earn date section (Calculation Period)
   --------------------------------------------------------------------------------
   SELECT /*+ QB_NAME( p0_0_1 )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
          -- Source --------------------------------------------------------------------------------
          z.rec_src_ind,
          z.co_id,
          -- Customer ------------------------------------------------------------------------------
          z.cust_id,
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
          -- Wholesaler COT ------------------------------------------------------------------------
          z.whls_id,
          -- Transaction Type ----------------------------------------------------------------------
          z.trans_typ_cd,
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
     FROM hcrs.calc_csr_main_p0_1_v z
   UNION ALL
   --------------------------------------------------------------------------------
   -- P0-2: Earn date section (After Calc Period, SAP adjs)
   --------------------------------------------------------------------------------
   SELECT /*+ QB_NAME( p0_0_2 )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
          -- Source --------------------------------------------------------------------------------
          z.rec_src_ind,
          z.co_id,
          -- Customer ------------------------------------------------------------------------------
          z.cust_id,
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
          -- Wholesaler COT ------------------------------------------------------------------------
          z.whls_id,
          -- Transaction Type ----------------------------------------------------------------------
          z.trans_typ_cd,
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
     FROM hcrs.calc_csr_main_p0_2_v z
   UNION ALL
   --------------------------------------------------------------------------------
   -- P0-3: Earn date section (After Calc Period, ICW_KEY Sales for SAP adjs)
   --------------------------------------------------------------------------------
   SELECT /*+ QB_NAME( p0_0_3 )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
          -- Source --------------------------------------------------------------------------------
          z.rec_src_ind,
          z.co_id,
          -- Customer ------------------------------------------------------------------------------
          z.cust_id,
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
          -- Wholesaler COT ------------------------------------------------------------------------
          z.whls_id,
          -- Transaction Type ----------------------------------------------------------------------
          z.trans_typ_cd,
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
     FROM hcrs.calc_csr_main_p0_3_v z
   UNION ALL
   --------------------------------------------------------------------------------
   -- P0-4: Earn date section (After Calc Period, ICW_KEY Credits for SAP adjs)
   --------------------------------------------------------------------------------
   SELECT /*+ QB_NAME( p0_0_4 )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
          -- Source --------------------------------------------------------------------------------
          z.rec_src_ind,
          z.co_id,
          -- Customer ------------------------------------------------------------------------------
          z.cust_id,
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
          -- Wholesaler COT ------------------------------------------------------------------------
          z.whls_id,
          -- Transaction Type ----------------------------------------------------------------------
          z.trans_typ_cd,
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
     FROM hcrs.calc_csr_main_p0_4_v z;
