CREATE OR REPLACE VIEW hcrs.calc_csr_main_p0_1_v
AS
   SELECT
          /*+ calc_csr_main_p0_1_v
              QB_NAME( p0_1 )
              NO_MERGE
              LEADING( ppw z )
              USE_NL( ppw z )
              FULL( ppw )
              INDEX( z mstr_trans_ix502 )
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_p0_1_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part 0-1
   *
   *                EARN DATE TRANS
   *
   *                Get product transactions with the earn date within the
   *                calculation period date for calculations that use earn date.
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
   *  08/01/2020  Joe Kidd      CHG-198490: Bioverativ Integration
   *                            Add Bioverative Source Systems and Trans Adjs
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
          ppw.flag_no uses_paid_dt,
          ppw.flag_yes uses_earn_dt,
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
          ppw.system_bivvrxc,
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
          ppw.trans_adj_bivv_adj,
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
     FROM hcrs.prfl_prod_wrk_t ppw,
          hcrs.mstr_trans_t z
       --------------------------------------------------------------------
       -- PPW-MT: Link profile NDCs to transactions
    WHERE ppw.trans_ndc_lbl = z.ndc_lbl
      AND ppw.trans_ndc_prod = z.ndc_prod
      AND ppw.trans_ndc_pckg = z.ndc_pckg
       -- Limit transactions to non-archived manual adjustments and
       -- non-archived transactions up to the selected snapshot
      AND ppw.co_id = z.co_id
      AND ppw.flag_no = z.archive_ind
      AND ppw.agency_typ_cd = COALESCE( z.man_adj_agency_cd, ppw.agency_typ_cd)
      AND ppw.snpsht_id >= z.snpsht_id
       -- Limit earn date by earn date range, include extra room for partition pruning
      AND z.earn_bgn_dt BETWEEN (ppw.min_earn_start_dt - ppw.prune_days) AND (ppw.max_earn_end_dt + ppw.prune_days)
       --------------------------------------------------------------------
       -- PPW: Don't include NDCs that are for bundling only
      AND ppw.bndl_only = ppw.flag_no
       -- PPW: Only when earn date is used
      AND ppw.uses_earn_dt = ppw.flag_yes;
