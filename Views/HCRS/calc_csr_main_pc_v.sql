CREATE OR REPLACE VIEW hcrs.calc_csr_main_pc_v
AS
   SELECT
          /*+ calc_csr_main_pc_v
              QB_NAME( pc )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_pc_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part C (12)
   *
   *                DLLRS/UNITS 2
   *
   *                Set parent transaction linking columns.  Order parent 
   *                SAP/SAP4H original invoices before parent SAP/SAP4H
   *                adjustment invoices.
   *
   *                Order RMUS/CARS ICW_KEY rebates/fees before other RMUS/CARS
   *                rebates/fees.  Order SAP/SAP4H original invoices before
   *                SAP/SAP4H adjustment invoices.
   *
   *                Calculate Gross Dollars, Net Dollars, Discount Dollars,
   *                Prompt Payment Dollars, Packages, and Units
   *
   *                Set PHS Contract and FSS Contract component checks.
   *
   *                This only works when the calculation environment has been
   *                initialized with pkg_common_procedures.p_init_calc.
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
   *                            Group columns, GTT column reduction, Adjust hints
   *                            Redesign Parent/Root link control, check root here
   *                            Move coalesce root, parent, current to here
   *                            Finish Calc Grs/Net/Dsc/PPD/Pkgs/Units here
   *                            Move SAP_ADJ and ICW_KEY order to here
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add SAP4H source system code column
   *                            Add SAP4H to SAP Original/Adjustment ordering
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
          CASE
             -- SAP/SAP4H must order original first manually because dates
             -- and numbers have no sane order
             WHEN z.parent_source_sys_cde IN (z.system_sap,
                                              z.system_sap4h)
              AND z.parent_assc_invc_no IS NULL
             THEN 1
             ELSE 2
          END parent_lgcy_trans_ord,
          z.parent_contr_id,
          z.parent_lgcy_trans_no,
          z.parent_lgcy_trans_line_no,
          -- Trans Identifiers ---------------------------------------------------------------------
          z.trans_cls_cd,
          z.source_sys_cde,
          CASE
             -- RMUS/CARS must order related sales/credits rebates before other rebates
             WHEN z.source_sys_cde = z.system_cars
              AND z.parent_trans_id_icw_key IS NOT NULL
             THEN 1
             -- SAP/SAP4H must order original first manually because dates
             -- and numbers have no sane order
             WHEN z.source_sys_cde IN (z.system_sap,
                                       z.system_sap4h)
              AND z.assc_invc_no IS NULL
             THEN 1
             ELSE 2
          END lgcy_trans_ord,
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
          z.wac_price,
          z.term_disc_pct,
          -- Component Values ----------------------------------------------------------------------
          NVL( z.dllrs_grs, (z.dllrs_net + z.dllrs_dsc)) dllrs_grs,
          NVL( z.dllrs_net, (z.dllrs_grs - z.dllrs_dsc)) dllrs_net,
          NVL( z.dllrs_dsc, (z.dllrs_grs - z.dllrs_net)) dllrs_dsc,
          NVL( z.pkgs, (z.units / z.unit_per_pckg)) pkgs,
          NVL( z.units, (z.pkgs * z.unit_per_pckg)) units,
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
          z.chk_contr,
          z.chk_phs_pvp_contr,
          z.chk_gnz_fss_phs_contr,
          -- Check for PHS contracts
          CASE
             WHEN z.chk_phs_pvp_contr = z.flag_yes
               OR z.chk_gnz_fss_phs_contr = z.flag_yes
             THEN z.flag_yes
             ELSE z.flag_no
          END chk_phs_contr,
          -- Check for FSS contracts
          CASE
             WHEN z.chk_gnz_fss_phs_contr = z.flag_yes
             THEN z.flag_yes
             ELSE z.flag_no
          END chk_fss_contr,
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
     FROM hcrs.calc_csr_main_pb_v z;
