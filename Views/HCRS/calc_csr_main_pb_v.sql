CREATE OR REPLACE VIEW hcrs.calc_csr_main_pb_v
AS
   SELECT
          /*+ calc_csr_main_pb_v
              QB_NAME( pb )
              NO_MERGE
              LEADING( z pse )
              USE_NL( z pse )
              INDEX( pse prfl_sls_excl_ix1 )
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_pb_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part B (11)
   *
   *                SALES EXCL, DLLRS/UNITS 1
   *
   *                Set root transaction linking columns.
   *
   *                Get Sales Exclusion setting from previous executions
   *
   *                Sets the trans adjustment code for SAP_ADJ, ICW_KEY,
   *                CARS_RBT_FEE, CARS_ADJ, X360_ADJ, and PRASCO_RBTFEE linkages.
   *
   *                SAP/SAP4H adj hard link: force use of root invoice date.
   *                SAP/SAP4H adj soft link: allow use of root invoice date.
   *
   *                Calculate Gross Dollars, Net Dollars, Discount Dollars,
   *                Prompt Payment Dollars, Packages, and Units
   *
   *                Set 340B PVP and Legacy Genzyme PHS/FSS component checks.
   *
   *                This only works when the calculation environment has been
   *                initialized with pkg_common_procedures.p_init_calc.
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
   *                              formula / Winthrop BP Change
   *                            Adjust hints
   *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
   *                            Group columns, GTT column reduction, Adjust hints
   *                            Redesign Parent/Root link control, check parent here
   *                            Move coalesce parent, current to here
   *                            Move trans adj code to here
   *                            Start Calc Grs/Net/Dsc/PPD/Pkgs/Units here
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add SAP4H source system code column
   *                            Add SAP4H to SAP Hard/Soft Linking
   *  08/28/2020  Joe Kidd      CHG-187461: Terms Percent Treatment for Direct Adjs
   *                            Only use actual terms percent, not from parent
   ****************************************************************************/
          -- Source --------------------------------------------------------------------------------
          z.rec_src_ind,
          z.co_id,
          -- Customer ------------------------------------------------------------------------------
          z.cust_id,
          z.orig_cust_id,
          z.cust_cls_of_trd_cd,
          -- Root Customer -------------------------------------------------------------------------
          COALESCE( DECODE( z.root_link_ind, z.flag_no, z.parent_cust_id), z.root_cust_id, z.parent_cust_id) root_cust_id,
          -- Parent Customer -----------------------------------------------------------------------
          z.parent_cust_id,
          -- Product -------------------------------------------------------------------------------
          z.ndc_lbl,
          z.ndc_prod,
          z.ndc_pckg,
          -- Component -----------------------------------------------------------------------------
          -- Root Identifiers ----------------------------------------------------------------------
          COALESCE( z.root_trans_cls_cd, z.parent_trans_cls_cd) root_trans_cls_cd,
          COALESCE( z.root_source_sys_cde, z.parent_source_sys_cde) root_source_sys_cde,
          -- Use NVL2 to handle when root and/or parent found but contract id is null
          DECODE( z.root_link_ind, z.flag_no, z.parent_contr_id, NVL2( z.root_trans_id, z.root_contr_id, z.parent_contr_id)) root_contr_id,
          COALESCE( z.root_lgcy_trans_no, z.parent_assc_invc_no, z.parent_lgcy_trans_no) root_lgcy_trans_no,
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
          COALESCE( DECODE( z.root_link_ind, z.flag_no, z.parent_trans_id), z.root_trans_id, z.parent_trans_id) root_trans_id,
          z.parent_trans_id,
          z.trans_id,
          CASE
             -- No parent linkage, mark as original
             WHEN z.parent_trans_id IS NULL
               OR z.parent_link_ind = z.flag_no
             THEN z.trans_adj_original
             -- CARS Rebate/Fee linked to a related sale/credit by ICW Key
             WHEN z.parent_trans_id_icw_key IS NOT NULL
             THEN z.trans_adj_icw_key
             -- CARS Resubmission adjustment
             WHEN z.parent_trans_id_cars_adj IS NOT NULL
             THEN z.trans_adj_cars_adj
             -- CARS Rebate/Fee linked to a chargeback
             WHEN z.parent_trans_id_cars_rbt_fee IS NOT NULL
             THEN z.trans_adj_cars_rbt_fee
             -- SAP Adjustment (separate correction invoice)
             WHEN z.parent_trans_id_sap_adj IS NOT NULL
             THEN z.trans_adj_sap_adj
             -- X360 Adjustment
             WHEN z.parent_trans_id_x360_adj IS NOT NULL
             THEN z.trans_adj_x360_adj
             -- PRASCO Rebate/Fee linked to a direct/indirect sale
             WHEN z.parent_trans_id_prasco_rbtfee IS NOT NULL
             THEN z.trans_adj_prasco_rbtfee
          END trans_adj_cd,
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
          z.root_link_ind,
          z.parent_link_ind,
          -- Related Trans -------------------------------------------------------------------------
          -- Prasco Rebates Link -------------------------------------------------------------------
          -- Trans Flags ---------------------------------------------------------------------------
          z.source_trans_typ,
          -- Sales Exclusion -----------------------------------------------------------------------
          pse.over_ind sls_excl_ind,
          -- Root Keys/Dates -----------------------------------------------------------------------
          -- Parent Keys/Dates ---------------------------------------------------------------------
          z.parent_assc_invc_no,
          -- Transaction Dates ---------------------------------------------------------------------
          CASE
             -- SAP adjustment hard linking (force paid date to original invoice)
             WHEN z.source_sys_cde IN (z.system_sap,
                                       z.system_sap4h)
              AND z.root_link_ind = z.sap_adj_dt_mblty_hrd_lnk
              AND z.parent_link_ind = z.sap_adj_dt_mblty_hrd_lnk
             THEN COALESCE( z.root_paid_dt, z.paid_dt)
             ELSE z.paid_dt
          END paid_dt,
          CASE
             -- SAP adjustment soft linking, allow use of root invoice date
             WHEN z.source_sys_cde IN (z.system_sap,
                                       z.system_sap4h)
              AND z.root_link_ind = z.sap_adj_dt_mblty_sft_lnk
              AND z.parent_link_ind = z.sap_adj_dt_mblty_sft_lnk
             THEN NVL( z.root_paid_dt, z.alt_paid_dt)
          END alt_paid_dt,
          z.earn_bgn_dt,
          z.earn_end_dt,
          -- Root Values ---------------------------------------------------------------------------
          -- Parent Values -------------------------------------------------------------------------
          -- Transaction Values --------------------------------------------------------------------
          z.wac_price,
          z.term_disc_pct,
          -- Component Values ----------------------------------------------------------------------
          CASE
             ---------------------------------------------------------------
             -- Gross Dollars - Rebates
             ---------------------------------------------------------------
             -- ICW_KEY Rebates use gross from parent sale/credit
             -- ICW_KEY On Chargebacks
             WHEN z.trans_cls_cd = z.trans_cls_rbt
              AND z.parent_trans_id_icw_key IS NOT NULL
              AND z.parent_trans_cls_cd = z.trans_cls_idr
             THEN NVL( z.parent_total_amt, 0) + NVL( z.parent_whls_chrgbck_amt, 0)
             -- ICW_KEY On Direct Sales with WAC Price (root, parent, current)
             WHEN z.trans_cls_cd = z.trans_cls_rbt
              AND z.parent_trans_id_icw_key IS NOT NULL
              AND z.parent_trans_cls_cd = z.trans_cls_dir
              AND z.parent_wac_price IS NOT NULL
             THEN z.parent_wac_price * NVL( z.parent_pkg_qty, 0)
             -- ICW_KEY On Direct Sales with WAC Extended Amount
             WHEN z.trans_cls_cd = z.trans_cls_rbt
              AND z.parent_trans_id_icw_key IS NOT NULL
              AND z.parent_trans_cls_cd = z.trans_cls_dir
              AND z.parent_wac_extnd_amt IS NOT NULL
             THEN z.parent_wac_extnd_amt
             -- ICW_KEY On Other Direct Sales
             WHEN z.trans_cls_cd = z.trans_cls_rbt
              AND z.parent_trans_id_icw_key IS NOT NULL
              AND z.parent_trans_cls_cd = z.trans_cls_dir
             THEN z.parent_total_amt
             -- Other Rebates use gross dollars
             WHEN z.trans_cls_cd = z.trans_cls_rbt
             THEN NVL( z.gross_sale_amt, 0)
             ---------------------------------------------------------------
             -- ** Gross Dollars - Indirect Sales = NET + DSC
             ---------------------------------------------------------------
             WHEN z.trans_cls_cd = z.trans_cls_idr
             THEN NULL
             ---------------------------------------------------------------
             -- Gross Dollars - Direct Credits
             ---------------------------------------------------------------
             -- Direct Credits assigned to Rbt/Fee/Fct Rbt Fee/Govt groups
             WHEN z.trans_cls_cd = z.trans_cls_dir
              AND z.source_trans_typ = z.source_trans_credits
              AND z.trans_typ_grp_cd IN (z.tt_rebates,
                                         z.tt_fee,
                                         z.tt_factr_rbt_fee,
                                         z.tt_govt)
             THEN NVL( z.gross_sale_amt, 0)
             ---------------------------------------------------------------
             -- Gross Dollars - Direct Sales
             ---------------------------------------------------------------
             -- Direct Sales with WAC Price (root, parent, current)
             WHEN z.trans_cls_cd = z.trans_cls_dir
              AND z.wac_price IS NOT NULL
             THEN z.wac_price * z.pkg_qty
             -- Direct Sales with WAC Extended Amount
             WHEN z.trans_cls_cd = z.trans_cls_dir
              AND z.wac_extnd_amt IS NOT NULL
             THEN z.wac_extnd_amt
             -- Other Direct Sales
             WHEN z.trans_cls_cd = z.trans_cls_dir
             THEN z.total_amt
          END dllrs_grs,
          -- dllrs_wac in next view
          CASE
             ---------------------------------------------------------------
             -- ** Net Dollars - Rebates = GRS - DSC
             ---------------------------------------------------------------
             WHEN z.trans_cls_cd = z.trans_cls_rbt
             THEN NULL
             ---------------------------------------------------------------
             -- Net Dollars - Indirect Sales
             ---------------------------------------------------------------
             -- Chargebacks
             WHEN z.trans_cls_cd = z.trans_cls_idr
             THEN z.total_amt
             ---------------------------------------------------------------
             -- ** Net Dollars - Direct Credits = GRS - DSC
             ---------------------------------------------------------------
             -- Direct Credits assigned to Rbt/Fee/Fct Rbt Fee/Govt groups
             WHEN z.trans_cls_cd = z.trans_cls_dir
              AND z.source_trans_typ = z.source_trans_credits
              AND z.trans_typ_grp_cd IN (z.tt_rebates,
                                         z.tt_fee,
                                         z.tt_factr_rbt_fee,
                                         z.tt_govt)
             THEN NULL
             ---------------------------------------------------------------
             -- Net Dollars - Direct Sales
             ---------------------------------------------------------------
             WHEN z.trans_cls_cd = z.trans_cls_dir
             THEN z.total_amt
          END dllrs_net,
          CASE
             ---------------------------------------------------------------
             -- Discount Dollars - Rebates
             ---------------------------------------------------------------
             WHEN z.trans_cls_cd = z.trans_cls_rbt
             THEN z.total_amt * -1 -- reverse signs to match chargeback / ppd
             ---------------------------------------------------------------
             -- Discount Dollars - Indirect Sales
             ---------------------------------------------------------------
             -- Chargebacks
             WHEN z.trans_cls_cd = z.trans_cls_idr
             THEN NVL( z.whls_chrgbck_amt, 0)
             ---------------------------------------------------------------
             -- Discount Dollars - Direct Sales
             ---------------------------------------------------------------
             -- Direct Credits assign to Rbt/Fee/Fct Rbt Fee/Govt groups
             WHEN z.trans_cls_cd = z.trans_cls_dir
              AND z.source_trans_typ = z.source_trans_credits
              AND z.trans_typ_grp_cd IN (z.tt_rebates,
                                         z.tt_fee,
                                         z.tt_factr_rbt_fee,
                                         z.tt_govt)
             THEN z.total_amt * -1 -- reverse signs to match chargeback / ppd
             ---------------------------------------------------------------
             -- Discount Dollars - Direct Sales = GRS - NET
             ---------------------------------------------------------------
             WHEN z.trans_cls_cd = z.trans_cls_dir
             THEN NULL
          END dllrs_dsc,
          CASE
             ---------------------------------------------------------------
             -- Packages - Rebates on Pkgs
             ---------------------------------------------------------------
             -- ICW_KEY Rebates use packages from parent sale/credit
             WHEN z.trans_cls_cd = z.trans_cls_rbt
              AND z.parent_trans_id_icw_key IS NOT NULL
             THEN z.parent_pkg_qty
             -- Govt/Rebates/Fees based on package qty from trans
             WHEN z.trans_cls_cd = z.trans_cls_rbt
              AND NVL( z.claim_unit_qty, 0) = 0
             THEN z.pkg_qty
             ---------------------------------------------------------------
             -- ** Packages - Rebates on Units = UNITS / UPP
             ---------------------------------------------------------------
             -- Other rebates
             WHEN z.trans_cls_cd = z.trans_cls_rbt
             THEN NULL
             ---------------------------------------------------------------
             -- Packages - Indirect Sales
             ---------------------------------------------------------------
             WHEN z.trans_cls_cd = z.trans_cls_idr
             THEN z.pkg_qty
             ---------------------------------------------------------------
             -- Packages - Direct Sales
             ---------------------------------------------------------------
             WHEN z.trans_cls_cd = z.trans_cls_dir
             THEN z.pkg_qty
          END pkgs,
          CASE
             ---------------------------------------------------------------
             -- Units - Rebates on Pkgs = PKGS * UPP
             ---------------------------------------------------------------
             -- ICW_KEY Rebates use packages from parent sale/credit
             WHEN z.trans_cls_cd = z.trans_cls_rbt
              AND z.parent_trans_id_icw_key IS NOT NULL
             THEN NULL
             -- Govt/Rebates/Fees based on package qty from trans
             WHEN z.trans_cls_cd = z.trans_cls_rbt
              AND NVL( z.claim_unit_qty, 0) = 0
             THEN NULL
             ---------------------------------------------------------------
             -- Units - Rebates on Units
             ---------------------------------------------------------------
             -- Govt/Rebates/Fees based on claim unit qty from trans from CARS (unit conversion needed)
             WHEN z.trans_cls_cd = z.trans_cls_rbt
              AND z.source_sys_cde = z.system_cars
              AND NOT (z.comm_unit_per_pckg = z.unit_per_pckg)
             THEN NVL( z.claim_unit_qty, 0) / z.comm_unit_per_pckg * z.unit_per_pckg
             -- Govt/Rebates/Fees based on claim unit qty from trans not from CARS
             -- Govt/Rebates/Fees based on claim unit qty from trans from CARS (no unit conversion needed)
             -- Avoids precision issues when units per pckg values are the same
             WHEN z.trans_cls_cd = z.trans_cls_rbt
             THEN NVL( z.claim_unit_qty, 0)
             ---------------------------------------------------------------
             -- Packages - Indirect Sales = PKGS * UPP
             ---------------------------------------------------------------
             WHEN z.trans_cls_cd = z.trans_cls_idr
             THEN NULL
             ---------------------------------------------------------------
             -- Packages - Direct Sales = PKGS * UPP
             ---------------------------------------------------------------
             WHEN z.trans_cls_cd = z.trans_cls_dir
             THEN NULL
          END units,
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
          z.unit_per_pckg,
          -- Bundling ------------------------------------------------------------------------------
          z.bndl_prod,
          z.bndl_src_sys_ind,
          -- Trans Linking -------------------------------------------------------------------------
          -- Estimations ---------------------------------------------------------------------------
          -- Component Checks ----------------------------------------------------------------------
          -- Check for contracted
          z.chk_contr,
          -- Check for 340B Prime Vendor contract
          CASE
             WHEN z.chk_contr = z.flag_no
             THEN z.flag_no
             WHEN EXISTS
                  (
                     SELECT /*+ NO_MERGE
                                INDEX( pcw prfl_contr_wrk_ix1 )
                                DYNAMIC_SAMPLING( 0 )
                            */
                            NULL
                       FROM hcrs.prfl_contr_wrk_t pcw
                      WHERE pcw.contr_id = z.contr_id
                        AND pcw.phs_340b_pvp_ind = z.flag_yes
                  )
             THEN z.flag_yes
             ELSE z.flag_no
          END chk_phs_pvp_contr,
          -- Check for Legacy Genzyme FSS/PHS contracts
          CASE
             WHEN z.chk_contr = z.flag_no
             THEN z.flag_no
             -- CAUTION: UGLY UGLY HARD CODED HACK AHEAD
             -- Genzyme FSS/PHS contracts contain the Genzyme labeler code
             WHEN z.co_id = z.co_gnz
              AND z.contr_id LIKE '%58468%'
             THEN z.flag_yes
             ELSE z.flag_no
          END chk_gnz_fss_phs_contr,
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
          z.system_sap,
          z.system_sap4h,
          z.system_cars,
          z.system_x360,
          z.trans_cls_dir,
          z.trans_cls_idr,
          z.trans_cls_rbt,
          z.cot_hhs_grantee,
          z.tt_indirect_sales
          -- Marking data --------------------------------------------------------------------------
          -- Cursor Row Count ----------------------------------------------------------------------
     FROM hcrs.calc_csr_main_pa_v z,
          hcrs.prfl_sls_excl_t pse
      --------------------------------------------------------------------
      -- TR-PSE: Link the transactions to sales exclusions (nominal)
    WHERE z.prfl_id = pse.prfl_id (+)
      AND z.trans_id = pse.trans_id (+);
