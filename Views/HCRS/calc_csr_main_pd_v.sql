CREATE OR REPLACE VIEW hcrs.calc_csr_main_pd_v
AS
   SELECT
          /*+ calc_csr_main_pd_v
              QB_NAME( pd )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_pd_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part D (13)
   *
   *                DLLRS/UNITS 3
   *
   *                Calculate Gross Dollars, WAC Dollars, Net Dollars, Discount
   *                Dollars, Prompt Payment Dollars, Packages, and Units
   *
   *                Set Nominal and HHS component checks.
   *
   *                This only works when the calculation environment has been
   *                initialized with pkg_common_procedures.p_init_calc.
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
   *                            Group columns, GTT column reduction, Adjust hints
   *                            Adjust Calc WAC dollars
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add SAP4H source system code column
   *  08/01/2020  Joe Kidd      CHG-198490: Bioverativ Integration
   *                            Add Bioverative Source Systems
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
          z.parent_lgcy_trans_ord,
          z.parent_contr_id,
          z.parent_lgcy_trans_no,
          z.parent_lgcy_trans_line_no,
          -- Trans Identifiers ---------------------------------------------------------------------
          z.trans_cls_cd,
          z.source_sys_cde,
          z.lgcy_trans_ord,
          z.contr_id,
          z.lgcy_trans_no,
          z.assc_invc_no,
          z.lgcy_trans_line_no,
          -- Trans IDs -----------------------------------------------------------------------------
          z.root_trans_id,
          z.parent_trans_id,
          z.trans_id,
          z.trans_adj_cd,
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
          z.root_link_ind,
          z.parent_link_ind,
          -- Related Trans -------------------------------------------------------------------------
          -- Prasco Rebates Link -------------------------------------------------------------------
          -- Trans Flags ---------------------------------------------------------------------------
          z.source_trans_typ,
          -- Sales Exclusion -----------------------------------------------------------------------
          z.sls_excl_ind,
          -- Root Keys/Dates -----------------------------------------------------------------------
          -- Parent Keys/Dates ---------------------------------------------------------------------
          -- Transaction Dates ---------------------------------------------------------------------
          z.paid_dt,
          z.alt_paid_dt,
          z.earn_bgn_dt,
          z.earn_end_dt,
          -- Root Values ---------------------------------------------------------------------------
          -- Parent Values -------------------------------------------------------------------------
          -- Transaction Values --------------------------------------------------------------------
          -- Component Values ----------------------------------------------------------------------
          z.dllrs_grs,
          CASE
             -- WAC price missing or invalid, use gross
             WHEN NVL( z.wac_price, 0) <= 0
             THEN z.dllrs_grs
             -- Chargebacks, Direct Sales/Credits (pkgs will be zero for direct credits)
             WHEN z.trans_cls_cd IN (z.trans_cls_idr,
                                     z.trans_cls_dir)
             THEN NVL( z.wac_price * z.pkgs, 0)
             -- Govt/Rebates/Fees based on package qty from trans or related sale
             WHEN z.trans_cls_cd = z.trans_cls_rbt
              AND z.units IS NULL
             THEN NVL( z.wac_price * z.pkgs, 0)
             -- Govt/Rebates/Fees based on claim unit qty from trans
             WHEN z.trans_cls_cd = z.trans_cls_rbt
             THEN NVL( z.wac_price * (NVL( z.units, 0) / z.unit_per_pckg), 0)
          END dllrs_wac,
          z.dllrs_net,
          z.dllrs_dsc,
          CASE
             ---------------------------------------------------------------
             -- Prompt Pay Dollars - Direct Sales/Credits
             ---------------------------------------------------------------
             WHEN z.trans_cls_cd = z.trans_cls_dir
             THEN z.dllrs_net * (NVL( z.term_disc_pct, 0) / 100)
             ELSE 0
          END dllrs_ppd,
          z.pkgs,
          z.units,
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
          -- Product Units -------------------------------------------------------------------------
          -- Bundling ------------------------------------------------------------------------------
          z.bndl_prod,
          z.bndl_src_sys_ind,
          -- Trans Linking -------------------------------------------------------------------------
          -- Estimations ---------------------------------------------------------------------------
          -- Component Checks ----------------------------------------------------------------------
          z.chk_contr,
          z.chk_phs_pvp_contr,
          z.chk_phs_contr,
          z.chk_fss_contr,
          -- Check for Nominal Check eligibility
          -- Only set to N to override Y from component
          CASE
             -- Nominal check does not apply to FSS, PHS, and 340B Prime Vendor contracts
             WHEN z.chk_fss_contr = z.flag_no
              AND z.chk_phs_contr = z.flag_no
              AND z.chk_phs_pvp_contr = z.flag_no
             THEN ''
             ELSE z.flag_no
          END chk_nom,
          -- Check for sub-PHS Check eligibility
          -- Only set to N to override Y from component
          CASE
               -- Must be contracted
             WHEN z.chk_contr = z.flag_yes
               -- HHS check does not apply to 340B Prime Vendor contracts
              AND z.chk_phs_pvp_contr = z.flag_no
               -- Customer class of trade supergroup must be HHS Grantee
              AND z.cust_cot_grp_cd = z.cot_hhs_grantee
               -- Only check Genzyme PHS Chargebacks
              AND (   z.co_id <> z.co_gnz
                   OR (   z.co_id = z.co_gnz
                       AND z.chk_gnz_fss_phs_contr = z.flag_yes
                       AND z.trans_typ_grp_cd = z.tt_indirect_sales
                      )
                  )
             THEN ''
             ELSE z.flag_no
          END chk_hhs,
          -- Units Component -----------------------------------------------------------------------
          -- Component Dollars ---------------------------------------------------------------------
          -- Trans Settings ------------------------------------------------------------------------
          -- Nominal Settings ----------------------------------------------------------------------
          -- Sub-PHS Settings ----------------------------------------------------------------------
          -- Trans Groupings -----------------------------------------------------------------------
          -- Constants -----------------------------------------------------------------------------
          z.flag_yes,
          z.flag_no,
          z.system_sap,
          z.system_sap4h,
          z.system_cars,
          z.system_x360,
          z.system_bivvrxc,
          z.trans_cls_dir,
          z.trans_cls_rbt
          -- Marking data --------------------------------------------------------------------------
          -- Cursor Row Count ----------------------------------------------------------------------
     FROM hcrs.calc_csr_main_pc_v z;
