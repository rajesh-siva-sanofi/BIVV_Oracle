CREATE OR REPLACE VIEW hcrs.calc_csr_main_pa_v
AS
   SELECT
          /*+ calc_csr_main_pa_v
              QB_NAME( pa )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_pa_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part A (10)
   *
   *                APPLY EARN DATES
   *
   *                Limit matrix effective dates by earned date
   *
   *                Limit class of trade effective dates by earned date
   *
   *                Determine if the parent transaction should be linked.
   *
   *                Revise bundle flag if tranaction earn date is not within the
   *                range covered by bundle date definitions.
   *
   *                Set contracted component check.
   *
   *                This only works when the calculation environment has been
   *                initialized with pkg_common_procedures.p_init_calc.
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
   *                            Group columns, GTT column reduction, Adjust hints
   *                            Redesign Parent/Root link control, add root here
   *                            Move SAP_ADJ and ICW_KEY order later
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add SAP4H source system code column
   *  08/28/2020  Joe Kidd      CHG-187461: Terms Percent Treatment for Direct Adjs
   *                            Remove root terms percent
   *                            Only use actual terms percent, not from root
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
          z.root_cust_id,
          -- Parent Customer -----------------------------------------------------------------------
          z.parent_cust_id,
          -- Product -------------------------------------------------------------------------------
          z.ndc_lbl,
          z.ndc_prod,
          z.ndc_pckg,
          -- Component -----------------------------------------------------------------------------
          -- Root Identifiers ----------------------------------------------------------------------
          z.root_trans_cls_cd,
          z.root_source_sys_cde,
          z.root_contr_id,
          z.root_lgcy_trans_no,
          -- Marking Trans Date --------------------------------------------------------------------
          -- Parent Identifiers --------------------------------------------------------------------
          z.parent_trans_cls_cd,
          z.parent_source_sys_cde,
          z.parent_contr_id,
          z.parent_lgcy_trans_no,
          z.parent_lgcy_trans_line_no,
          -- Trans Identifiers ---------------------------------------------------------------------
          z.trans_cls_cd,
          z.source_sys_cde,
          z.contr_id,
          z.lgcy_trans_no,
          z.assc_invc_no,
          z.lgcy_trans_line_no,
          -- Trans IDs -----------------------------------------------------------------------------
          z.root_trans_id,
          z.parent_trans_id,
          z.trans_id,
          -- Root Lookup IDs -----------------------------------------------------------------------
          z.root_trans_id_sap_adj,
          z.root_trans_id_cars_adj,
          z.root_trans_id_x360_adj,
          z.root_trans_id_bivv_adj,
          -- Parent Lookup IDs ---------------------------------------------------------------------
          z.parent_trans_id_sap_adj,
          z.parent_trans_id_icw_key,
          z.parent_trans_id_cars_rbt_fee,
          z.parent_trans_id_cars_adj,
          z.parent_trans_id_x360_adj,
          z.parent_trans_id_bivv_adj,
          z.parent_trans_id_prasco_rbtfee,
          -- Link Markers --------------------------------------------------------------------------
          CASE -- Ordered by frequency of occurance in data
             --------------------------------------------------------------------------------------
             -- Parent is not linked
             WHEN z.parent_link_ind = z.flag_no
             THEN z.flag_no
             --------------------------------------------------------------------------------------
             -- Root not found, set to parent link
             WHEN z.root_trans_id IS NULL
             THEN z.parent_link_ind
             --------------------------------------------------------------------------------------
             -- CARS_ADJ Linking: The customer IDs and contact IDs must match, but
             -- they does not need to match to obtain Gross Dollars/Units/Packages.
             WHEN z.root_trans_id_cars_adj IS NOT NULL
              AND z.root_cust_id = z.parent_cust_id
              AND z.root_contr_id = z.parent_contr_id
             THEN z.flag_yes
             WHEN z.root_trans_id_cars_adj IS NOT NULL
             THEN z.flag_no
             --------------------------------------------------------------------------------------
             -- SAP_ADJ Linking: The customer IDs must match, and the contact IDs must match (same
             -- value or both are NULL), but they does not need to match to obtain Gross Dollars/
             -- Units/Packages.  Linking must be on, but use date mobility:
             -- N = No link, orig+adjs always included separately by their invoice dates
             -- S = Soft Link, orig+adjs linked if their invoices dates are in the same component
             -- Y = Hard Link, orig+adjs always linked and included on original invoice date
             WHEN z.root_trans_id_sap_adj IS NOT NULL
              AND z.root_cust_id = z.parent_cust_id
              AND (   z.root_contr_id = z.parent_contr_id
                   OR (    z.root_contr_id IS NULL
                       AND z.parent_contr_id IS NULL
                      )
                  )
             THEN z.sap_adj_dt_mblty
             WHEN z.root_trans_id_sap_adj IS NOT NULL
             THEN z.flag_no
             --------------------------------------------------------------------------------------
             -- X360_ADJ Linking: The customer IDs must match (Xenon doesn't have and contact IDs),
             --  but they does not need to match to obtain Gross Dollars/Units/Packages.
             WHEN z.root_trans_id_x360_adj IS NOT NULL
              AND z.root_cust_id = z.parent_cust_id
             THEN z.flag_yes
             WHEN z.root_trans_id_x360_adj IS NOT NULL
             THEN z.flag_no
             ---------------------------------------------------------------------------------------
             -- BIVV_ADJ Linking: The customer IDs must match, but the contact IDs do not need to
             -- match.  SAP link settings are used as they are really direct adjustment settings.
             -- Linking must be on, but use date mobility:
             -- N = No link, orig+adjs always included separately by their invoice dates
             -- S = Soft Link, orig+adjs linked if their invoices dates are in the same component
             -- Y = Hard Link, orig+adjs always linked and included on original invoice date
             WHEN z.root_trans_id_bivv_adj IS NOT NULL
              AND z.root_cust_id = z.parent_cust_id
             THEN z.sap_adj_dt_mblty
             WHEN z.root_trans_id_sap_adj IS NOT NULL
             THEN z.flag_no
          END root_link_ind,
          z.parent_link_ind,
          -- Related Trans -------------------------------------------------------------------------
          -- Prasco Rebates Link -------------------------------------------------------------------
          -- Trans Flags ---------------------------------------------------------------------------
          z.source_trans_typ,
          -- Sales Exclusion -----------------------------------------------------------------------
          -- Root Keys/Dates -----------------------------------------------------------------------
          z.root_paid_dt,
          -- Parent Keys/Dates ---------------------------------------------------------------------
          z.parent_assc_invc_no,
          -- Transaction Dates ---------------------------------------------------------------------
          z.paid_dt,
          z.alt_paid_dt,
          z.earn_bgn_dt,
          z.earn_end_dt,
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
          -- Wholesaler COT ------------------------------------------------------------------------
          z.whls_cot_incl_ind,
          z.whls_cot_grp_cd,
          z.whls_loc_cd,
          -- Transaction Type ----------------------------------------------------------------------
          z.trans_typ_cd,
          z.trans_typ_incl_ind,
          z.trans_typ_grp_cd,
          -- Profile Calc Data ---------------------------------------------------------------------
          z.prfl_id,
          -- Product Units -------------------------------------------------------------------------
          z.unit_per_pckg,
          z.comm_unit_per_pckg,
          -- Bundling ------------------------------------------------------------------------------
          -- Revise bundle flag if tranaction earn date is not within the
          -- range covered by bundle date definitions
          CASE
             WHEN z.earn_bgn_dt BETWEEN z.min_bndl_start_dt AND z.max_bndl_end_dt
             THEN z.flag_yes
             ELSE z.flag_no
          END bndl_prod,
          z.bndl_src_sys_ind,
          -- Trans Linking -------------------------------------------------------------------------
          -- Estimations ---------------------------------------------------------------------------
          -- Component Checks ----------------------------------------------------------------------
          -- Check for contracted
          DECODE( z.contr_id, NULL, z.flag_no, z.flag_yes) chk_contr,
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
     FROM hcrs.calc_csr_main_p9_v z
    WHERE z.earn_bgn_dt BETWEEN z.cust_cot_eff_strt_dt AND z.cust_cot_eff_end_dt
      AND z.earn_bgn_dt BETWEEN z.cust_cot_begn_dt AND z.cust_cot_end_dt
      AND z.earn_bgn_dt BETWEEN z.whls_cot_eff_strt_dt AND z.whls_cot_eff_end_dt
      AND z.earn_bgn_dt BETWEEN z.whls_cot_begn_dt AND z.whls_cot_end_dt
      AND z.earn_bgn_dt BETWEEN z.tt_begn_dt AND z.tt_end_dt;
