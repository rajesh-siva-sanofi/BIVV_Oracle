CREATE OR REPLACE VIEW hcrs.calc_csr_main_p0_4_v
AS
   SELECT
          /*+ calc_csr_main_p0_4_v
              QB_NAME( p0_4 )
              NO_MERGE
              LEADING( ppw z )
              USE_NL( ppw z )
              INDEX( z mstr_trans_ix03 )
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_p0_4_v
   * Date Created : 03/01/2019
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part 0-4
   *
   *                EARN DATE TRANS DIR ADJ CREDIT ICW_KEY
   *
   *                Get product transactions with the earn date after the
   *                calculation period date for calculations that use earn date.
   *
   *                Include CARS ICW_KEY related CREDITS transactions linked to
   *                SAP adjustment transactions. This must be done because
   *                RMUS/CARS assigns rebate claims dates based on the invoice
   *                date, not the original invoice dates.  Since the earned date
   *                of both the SAP adjustments and the ICW_KEY related
   *                transactions is based on original invoice date, the earn
   *                range end date must extended to the snapshot date to allow
   *                all adjustments to be found.
   *
   *                This view only returns data when the calculation environment
   *                has been initialized with pkg_common_procedures.p_init_calc.
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add Assoc invoice source system code column
   *                            Add SAP4H source system code column
   ****************************************************************************/
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
          ppw.uses_paid_dt,
          ppw.uses_earn_dt,
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
          ppw.prfl_id,
          ppw.snpsht_id,
          -- Product Units -------------------------------------------------------------------------
          ppw.unit_per_pckg,
          ppw.comm_unit_per_pckg,
          -- Bundling ------------------------------------------------------------------------------
          ppw.bndl_prod,
          ppw.min_bndl_start_dt,
          ppw.max_bndl_end_dt,
          -- Trans Linking -------------------------------------------------------------------------
          ppw.sap_adj_dt_mblty,
          ppw.prune_days,
          -- Estimations ---------------------------------------------------------------------------
          -- Component Checks ----------------------------------------------------------------------
          -- Units Component -----------------------------------------------------------------------
          -- Component Dollars ---------------------------------------------------------------------
          -- Trans Settings ------------------------------------------------------------------------
          -- Nominal Settings ----------------------------------------------------------------------
          -- Sub-PHS Settings ----------------------------------------------------------------------
          -- Trans Groupings -----------------------------------------------------------------------
          -- Constants -----------------------------------------------------------------------------
          ppw.flag_yes,
          ppw.flag_no,
          ppw.begin_time,
          ppw.end_time,
          ppw.rec_src_icw,
          ppw.co_gnz,
          ppw.src_tbl_iis,
          ppw.src_tbl_iic,
          ppw.src_tbl_ipdr,
          ppw.src_tbl_ipir,
          ppw.source_trans_credits,
          ppw.system_sap,
          ppw.system_sap4h,
          ppw.system_cars,
          ppw.system_x360,
          ppw.system_prasco,
          ppw.trans_cls_dir,
          ppw.trans_cls_idr,
          ppw.trans_cls_rbt,
          ppw.trans_adj_original,
          ppw.trans_adj_sap_adj,
          ppw.trans_adj_cars_rbt_fee,
          ppw.trans_adj_cars_adj,
          ppw.trans_adj_icw_key,
          ppw.trans_adj_x360_adj,
          ppw.trans_adj_prasco_rbtfee,
          ppw.sap_adj_dt_mblty_hrd_lnk,
          ppw.sap_adj_dt_mblty_sft_lnk,
          ppw.whls_cot_grp_cd_noncbk,
          ppw.whls_cot_incl_ind_noncbk,
          ppw.whls_loc_cd_noncbk,
          ppw.cot_hhs_grantee,
          ppw.tt_indirect_sales,
          ppw.tt_rebates,
          ppw.tt_fee,
          ppw.tt_factr_rbt_fee,
          ppw.tt_govt
          -- Marking data --------------------------------------------------------------------------
          -- Cursor Row Count ----------------------------------------------------------------------
     FROM hcrs.calc_csr_main_p0_2_v ppw,
          hcrs.mstr_trans_t z
       --------------------------------------------------------------------
       -- PPW-MT: Link Earn date SAP Adjs to transactions
       -- Same data source, not archived, no manual adjustments, limit snapshot
    WHERE ppw.rec_src_ind = z.rec_src_ind
      AND ppw.co_id = z.co_id
      AND ppw.archive_ind = z.archive_ind
      AND ppw.snpsht_id >= z.snpsht_id
       -- Customer does not need to match at all!!
      --AND ppw.cust_id = z.cust_id
       -- Must be same NDC
      AND ppw.ndc_lbl = z.ndc_lbl
      AND ppw.ndc_prod = z.ndc_prod
      AND ppw.ndc_pckg = z.ndc_pckg
       -- Contract ID must match to link to parent transaction (see above)
       -- Contract ID does not need to match to obtain Gross Dollars/Units/Packages
      --AND ppw.contr_id = NVL( z.contr_id (+), ppw.contr_id)
       -- Link to related sales transaction
      AND ppw.unique_id = z.related_credits_id
       -- Limit earn date by earn date end date and snapshot date,
       -- include extra room for partition pruning
       -- prune_days + 1 is ADDED to max_earn_end_dt because query 0-1
       -- already pulls to max_earn_end_dt + prune_days, this prevents overlap
      AND z.earn_bgn_dt BETWEEN (ppw.max_earn_end_dt + ppw.prune_days + 1) AND (ppw.snpsht_dt + ppw.prune_days)
       --------------------------------------------------------------------
       -- PPW: Only Credits rows
      AND ppw.src_tbl_cd = ppw.src_tbl_iic
       -----------------------------------------------------
       -- Partition pruning - THESE MAKE A HUGE DIFFERENCE!!
       -----------------------------------------------------
       -- Related credit will be paid on or after direct sales invoice date
       -- (for SAP, paid_dt = earn_bgn_dt, and earn_bgn_dt is on the index)
      AND (ppw.earn_bgn_dt - ppw.prune_days) <= z.paid_dt;
