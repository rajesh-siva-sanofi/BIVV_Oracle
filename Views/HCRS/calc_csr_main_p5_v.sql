CREATE OR REPLACE VIEW hcrs.calc_csr_main_p5_v
AS
   SELECT
          /*+ calc_csr_main_p5_v
              QB_NAME( p5 )
              NO_MERGE
              LEADING( z rt )
              USE_NL( z rt )
              INDEX( rt mstr_trans_ix01 )
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_p5_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part 5
   *
   *                PARENT LOOKUP 1
   *
   *                Gets the parent data for ICW_KEY linkage.  This link is
   *                done as an (outer-) join because there is only one possible
   *                parent transaction and the index used does not contain all
   *                columns required to meet the join conditions and return the
   *                parent trans_id.  So because the table must be accessed to
   *                complete the join, it gets all the other columns required.
   *
   *                Clear lgcy_trans_no and assc_invc_no for ICW_KEY rows.
   *
   *                Gets the parent trans_id for SAP_ADJ, CARS_RBT_FEE,
   *                X360_ADJ, and PRASCO_RBTFEE linkages.  These links are done
   *                as scalar subqueries because there may be more than one
   *                parent transaction, the volumne of SAP, SAP4H, X360, and
   *                PRASCO links are low, and the index used contains all columns
   *                required to meet the join conditions and return the parent
   *                trans_id.
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
   *                            Redesign Parent/Root link control, move to later
   *                            Move ICW_KEY invoice changes to here
   *                            Move Swap Prasco invc line/assc invc numbers earlier
   *                            Move SAP_ADJ and ICW_KEY order to later
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add Assoc invoice source system code column
   *                            Add SAP4H source system code column
   *                            Add SAP4H to SAP adjustment lookup
   *  08/28/2020  Joe Kidd      CHG-187461: Terms Percent Treatment for Direct Adjs
   *                            Remove parent terms percent
   ****************************************************************************/
          -- Source --------------------------------------------------------------------------------
          z.rec_src_ind,
          z.co_id,
          -- Customer ------------------------------------------------------------------------------
          CASE
             -- ICW_KEY uses parent customer ID for linking,
             -- because customer IDs never need to match
             WHEN rt.trans_id IS NOT NULL
             THEN rt.cust_id
             ELSE z.cust_id
          END cust_id,
          z.cust_id orig_cust_id,
          z.cust_cls_of_trd_cd,
          -- Root Customer -------------------------------------------------------------------------
          -- Parent Customer -----------------------------------------------------------------------
          rt.cust_id parent_cust_id,
          -- Product -------------------------------------------------------------------------------
          z.ndc_lbl,
          z.ndc_prod,
          z.ndc_pckg,
          -- Component -----------------------------------------------------------------------------
          -- Root Identifiers ----------------------------------------------------------------------
          -- Marking Trans Date --------------------------------------------------------------------
          -- Parent Identifiers --------------------------------------------------------------------
          rt.trans_cls_cd parent_trans_cls_cd,
          rt.source_sys_cde parent_source_sys_cde,
          -- Trim contract ID in case it only has spaces, thanks IQVIA
          TRIM( rt.contr_id) parent_contr_id,
          rt.lgcy_trans_no parent_lgcy_trans_no,
          rt.lgcy_trans_line_no parent_lgcy_trans_line_no,
          rt.assc_invc_source_sys_cde parent_assc_invc_source_sys_cd,
          -- Trans Identifiers ---------------------------------------------------------------------
          z.trans_cls_cd,
          z.source_sys_cde,
          z.contr_id,
          CASE
             -- Align ICW_KEY legacy trans number with related sale/credit
             -- This allows siblings that do not link to parent to roll up
             WHEN rt.trans_id IS NOT NULL
             THEN rt.lgcy_trans_no
             -- If ICW_KEY link is not found, ignore the lgcy_trans_no
             -- With CARS it was always NULL but with RMUS it now has a
             -- negative number (submextitem_num)
             WHEN z.related_unique_id IS NOT NULL
               OR z.lgcy_trans_no IS NULL
             THEN z.trans_id
             ELSE z.lgcy_trans_no
          END lgcy_trans_no,
          CASE
             -- ICW_KEY credits should always ignore the assc_invc_no
             -- With CARS it was always NULL but with RMUS it now may have
             -- negative number (submextitem_num_prior)
             WHEN z.related_unique_id IS NOT NULL
             THEN TO_NUMBER( NULL)
             ELSE z.assc_invc_no
          END assc_invc_no,
          z.lgcy_trans_line_no,
          z.assc_invc_source_sys_cde,
          -- Trans IDs -----------------------------------------------------------------------------
          rt.trans_id parent_trans_id,
          z.trans_id,
          -- Root Lookup IDs -----------------------------------------------------------------------
          -- Parent Lookup IDs ---------------------------------------------------------------------
          -- SAP_ADJ: Link SAP/SAP4H adjustment to parent SAP/SAP4H invoice
          CASE
             WHEN z.rec_src_ind = z.rec_src_icw
              AND z.trans_cls_cd = z.trans_cls_dir
              AND z.source_sys_cde IN (z.system_sap,
                                       z.system_sap4h)
              AND z.assc_invc_no IS NOT NULL
              AND z.assc_invc_dt IS NOT NULL
              AND z.assc_invc_source_sys_cde IS NOT NULL
             THEN (  -- use MIN as there may be more than one line
                     SELECT /*+ QB_NAME( p5_sap )
                                NO_MERGE
                                INDEX( rt0 mstr_trans_ix503 )
                                DYNAMIC_SAMPLING( 0 )
                            */
                            MIN( rt0.trans_id) trans_id
                       FROM hcrs.mstr_trans_t rt0
                         -- Same data source, not archived, no manual adjustments, limit snapshot
                      WHERE rt0.rec_src_ind = z.rec_src_ind
                        AND rt0.co_id = z.co_id
                        AND rt0.archive_ind = z.archive_ind
                        AND rt0.snpsht_id <= z.snpsht_id
                         -- Customer ID must match to link to parent transaction, however
                         -- Customer ID does not need to match to obtain Gross Dollars/Units/Packages
                         --AND rt0.cust_id = z.cust_id
                         -- Must be same NDC
                        AND rt0.ndc_lbl = z.ndc_lbl
                        AND rt0.ndc_prod = z.ndc_prod
                        AND rt0.ndc_pckg = z.ndc_pckg
                         -- Contract ID must match to link to parent transaction, however
                         -- Contract ID does not need to match to obtain Gross Dollars/Units/Packages
                         --AND rt0.contr_id = z.contr_id
                         -- Must be a direct sale
                        AND rt0.trans_cls_cd = z.trans_cls_cd
                         -- Link to original invoice
                        AND rt0.lgcy_trans_no = z.assc_invc_no
                        AND rt0.source_sys_cde = z.assc_invc_source_sys_cde
                         -----------------------------------------------------
                         -- Partition pruning - Direct partition access
                         -----------------------------------------------------
                        AND rt0.paid_dt = z.assc_invc_dt
                  )
          END parent_trans_id_sap_adj,
          -- ICW_KEY: Link RMUS/CARS rebate/fee to parent Interpretes Sale/Credit
          rt.trans_id parent_trans_id_icw_key,
          -- CARS_RBT_FEE: Link RMUS/CARS rebate/fee to parent RMUS/CARS chargeback
          CASE
             WHEN z.rec_src_ind = z.rec_src_icw
              AND z.trans_cls_cd = z.trans_cls_rbt
              AND z.source_sys_cde = z.system_cars
              AND z.related_unique_id IS NULL
              AND z.lgcy_trans_no IS NOT NULL
             THEN (  -- Use MIN as there may be more than one line
                     SELECT /*+ QB_NAME( p5_cars )
                                NO_MERGE
                                INDEX( rt0 mstr_trans_ix503 )
                                DYNAMIC_SAMPLING( 0 )
                            */
                            MIN( rt0.trans_id) trans_id
                       FROM hcrs.mstr_trans_t rt0
                         -- Same data source, not archived, no manual adjustments, limit snapshot
                      WHERE rt0.rec_src_ind = z.rec_src_ind
                        AND rt0.co_id = z.co_id
                        AND rt0.archive_ind = z.archive_ind
                        AND rt0.snpsht_id <= z.snpsht_id
                         -- Customer ID must match to link to parent transaction, however
                         -- Customer ID does not need to match to obtain Gross Dollars/Units/Packages
                         --AND rt0.cust_id = z.cust_id
                         -- Must be same NDC
                        AND rt0.ndc_lbl = z.ndc_lbl
                        AND rt0.ndc_prod = z.ndc_prod
                        AND rt0.ndc_pckg = z.ndc_pckg
                         -- Contract ID must match to link to parent transaction, however
                         -- Contract ID does not need to match to obtain Gross Dollars/Units/Packages
                         -- (RMUS/CARS always has a contract)
                        --AND rt0.contr_id = z.contr_id
                         -- Must be an RMUS/CARS chargeback
                        AND rt0.source_sys_cde = z.source_sys_cde
                        AND rt0.trans_cls_cd = z.trans_cls_idr
                         -- Link to original transaction
                        AND rt0.lgcy_trans_no = z.lgcy_trans_no
                        AND rt0.earn_bgn_dt BETWEEN z.earn_bgn_dt AND z.earn_end_dt
                         -----------------------------------------------------
                         -- Partition pruning - THESE MAKE A HUGE DIFFERENCE!!
                         -----------------------------------------------------
                         -- Parent chargeback will be paid on or before this rebate
                         -- Can't do this - apparently admin fees can be settled long before their chargebacks
                        --AND rt0.paid_dt <= (z.paid_dt + z.prune_days)
                         -- Parent chargeback will be paid on or after when this rebate was earned
                        AND rt0.paid_dt >= (z.earn_bgn_dt - z.prune_days)
                  )
          END parent_trans_id_cars_rbt_fee,
          -- X360_ADJ: Link X360 rebate/fee to parent X360 rebate/fee
          CASE
             WHEN z.rec_src_ind = z.rec_src_icw
              AND z.trans_cls_cd = z.trans_cls_rbt
              AND z.source_sys_cde = z.system_x360
              AND z.assc_invc_no IS NOT NULL
             THEN (  -- Use MIN as there may be more than one line
                     SELECT /*+ QB_NAME( p5_x360 )
                                NO_MERGE
                                INDEX( rt0 mstr_trans_ix503 )
                                DYNAMIC_SAMPLING( 0 )
                            */
                            MIN( rt0.trans_id) trans_id
                       FROM hcrs.mstr_trans_t rt0
                         -- Same data source, not archived, no manual adjustments, limit snapshot
                      WHERE rt0.rec_src_ind = z.rec_src_ind
                        AND rt0.co_id = z.co_id
                        AND rt0.archive_ind = z.archive_ind
                        AND rt0.snpsht_id <= z.snpsht_id
                         -- Customer ID must match to link to parent transaction, however
                         -- Customer ID does not need to match to obtain Gross Dollars/Units/Packages
                         --AND rt0.cust_id = z.cust_id
                         -- Must be same NDC
                        AND rt0.ndc_lbl = z.ndc_lbl
                        AND rt0.ndc_prod = z.ndc_prod
                        AND rt0.ndc_pckg = z.ndc_pckg
                         -- Must be an X360 rebate
                        AND rt0.source_sys_cde = z.source_sys_cde
                        AND rt0.trans_cls_cd = z.trans_cls_cd
                         -- X360 rebates do not have a contract ID
                        --AND rt0.contr_id = z.contr_id
                         -- Link to original transaction
                        AND rt0.lgcy_trans_no = z.assc_invc_no
                        AND rt0.lgcy_trans_line_no = z.lgcy_trans_line_no
                        AND rt0.earn_bgn_dt = z.earn_bgn_dt
                         -----------------------------------------------------
                         -- Partition pruning - THESE MAKE A HUGE DIFFERENCE!!
                         -----------------------------------------------------
                         -- Parent rebate will be paid on or before this rebate
                        AND rt0.paid_dt <= (z.paid_dt + z.prune_days)
                         -- Parent rebate will be paid on or after when this rebate was earned
                        AND rt0.paid_dt >= (z.earn_bgn_dt - z.prune_days)
                  )
          END parent_trans_id_x360_adj,
          -- PRASCO_RBTFEE: Link Prasco rebate/fee to parent direct/indirect sale
          CASE
             WHEN z.rec_src_ind = z.rec_src_icw
              AND z.trans_cls_cd = z.trans_cls_rbt
              AND z.source_sys_cde = z.system_prasco
              AND z.lgcy_trans_no IS NOT NULL
              AND z.lgcy_trans_line_no IS NOT NULL
             THEN (  -- Use MIN as there may be more than one line
                     SELECT /*+ QB_NAME( p5_prasco )
                                NO_MERGE
                                INDEX( rt0 mstr_trans_ix503 )
                                DYNAMIC_SAMPLING( 0 )
                            */
                            MIN( rt0.trans_id) trans_id
                       FROM hcrs.mstr_trans_t rt0
                         -- Same data source, not archived, no manual adjustments, limit snapshot
                      WHERE rt0.rec_src_ind = z.rec_src_ind
                        AND rt0.co_id = z.co_id
                        AND rt0.archive_ind = z.archive_ind
                        AND rt0.snpsht_id <= z.snpsht_id
                         -- Customer ID must match to link to parent transaction, however
                         -- Customer ID does not need to match to obtain Gross Dollars/Units/Packages
                         --AND rt0.cust_id = z.cust_id
                         -- Must be same NDC
                        AND rt0.ndc_lbl = z.ndc_lbl
                        AND rt0.ndc_prod = z.ndc_prod
                        AND rt0.ndc_pckg = z.ndc_pckg
                         -- Must be an Prasco Sale
                        AND rt0.source_sys_cde = z.source_sys_cde
                         -- Match direct rebate to direct sale and
                         -- Match indirect rebate to indirect sale
                        AND rt0.trans_cls_cd = z.prasco_rbt_trans_cls_cd
                         -- PRASCO rebates do not have a contract ID
                        --AND rt0.contr_id = z.contr_id
                         -- Link to original transaction
                        AND rt0.lgcy_trans_no = z.lgcy_trans_no
                        AND rt0.lgcy_trans_line_no = z.lgcy_trans_line_no
                         -----------------------------------------------------
                         -- Partition pruning - THESE MAKE A HUGE DIFFERENCE!!
                         -----------------------------------------------------
                         -- Parent sale will be paid on or before this rebate
                        AND rt0.paid_dt <= (z.paid_dt + z.prune_days)
                         -- Parent sale will be paid on or after when the rebate was earned
                        AND rt0.paid_dt >= (z.earn_bgn_dt - z.prune_days)
                  )
          END parent_trans_id_prasco_rbtfee,
          -- Link Markers --------------------------------------------------------------------------
          -- Related Trans -------------------------------------------------------------------------
          -- Prasco Rebates Link -------------------------------------------------------------------
          -- Trans Flags ---------------------------------------------------------------------------
          z.archive_ind,
          z.source_trans_typ,
          -- Sales Exclusion -----------------------------------------------------------------------
          -- Root Keys/Dates -----------------------------------------------------------------------
          -- Parent Keys/Dates ---------------------------------------------------------------------
          rt.paid_dt parent_paid_dt,
          rt.earn_bgn_dt parent_earn_bgn_dt,
          rt.earn_end_dt parent_earn_end_dt,
          rt.assc_invc_dt parent_assc_invc_dt,
          rt.assc_invc_no parent_assc_invc_no,
          -- Transaction Dates ---------------------------------------------------------------------
          z.paid_dt,
          z.earn_bgn_dt,
          z.earn_end_dt,
          z.assc_invc_dt,
          -- Root Values ---------------------------------------------------------------------------
          -- Parent Values -------------------------------------------------------------------------
          rt.wac_price parent_wac_price,
          rt.pkg_qty parent_pkg_qty,
          rt.total_amt parent_total_amt,
          rt.whls_chrgbck_amt parent_whls_chrgbck_amt,
          rt.wac_extnd_amt parent_wac_extnd_amt,
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
     FROM hcrs.calc_csr_main_p4_v z,
          hcrs.mstr_trans_t rt
       -- Same data source, not archived, no manual adjustments, limit snapshot
    WHERE z.rec_src_ind = rt.rec_src_ind (+)
      AND z.co_id = rt.co_id (+)
      AND z.archive_ind = rt.archive_ind (+)
      AND z.snpsht_id >= rt.snpsht_id  (+)
       -- Customer ID never needs to match!!
      --AND z.cust_id = rt.cust_id (+)
       -- Must be same NDC
      AND z.ndc_lbl = rt.ndc_lbl (+)
      AND z.ndc_prod = rt.ndc_prod (+)
      AND z.ndc_pckg = rt.ndc_pckg (+)
       -- Contract ID must match to link to parent transaction (see above)
       -- Contract ID does not need to match to obtain Gross Dollars/Units/Packages
      --AND z.contr_id = NVL( rt.contr_id (+), z.contr_id)
       -- Link to related sales/credit parent transaction
      AND z.related_src_tbl_cd = rt.src_tbl_cd (+)
      AND z.related_unique_id = rt.unique_id (+)
       -----------------------------------------------------
       -- Partition pruning - THESE MAKE A HUGE DIFFERENCE!!
       -----------------------------------------------------
       -- Related sale/credit will be paid on or before linked credit was paid
      AND (z.paid_dt + z.prune_days) >= rt.paid_dt (+)
       -- Related sale/credit will be paid on or after linked credit was earned
      AND (z.earn_bgn_dt - z.prune_days) <= rt.paid_dt (+);
