CREATE OR REPLACE VIEW hcrs.calc_csr_main_p8_v
AS
   SELECT
          /*+ calc_csr_main_p8_v
              QB_NAME( p8 )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
   /****************************************************************************
   *    View Name : calc_csr_main_p8_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Main calculation transaction query, part 8
   *
   *                ROOT LOOKUP
   *
   *                Gets the root trans_id for SAP_ADJ, CARS_ADJ, X360_ADJ, and
   *                BIVV_ADJ linkages.  These links are done as scalar subqueries
   *                because there may be a heirarchy of transactions between the
   *                parent and the root transaction, there may be more than one
   *                root transaction, the volume of SAP, SAP4H, and X360 links
   *                are low, and the index used contains all columns required to
   *                meet the join conditions and return the root trans_id.
   *
   *                Determine if the parent transaction should be linked.
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
   *                            Redesign Parent/Root link control, add parent here
   *                            Move SAP_ADJ and ICW_KEY order later
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add Assoc invoice source system code column
   *                            Add SAP4H source system code column
   *                            Add SAP4H to SAP adjustment lookup
   *  08/28/2020  Joe Kidd      CHG-187461: Terms Percent Treatment for Direct Adjs
   *                            Remove parent terms percent
   *  08/01/2020  Joe Kidd      CHG-198490: Bioverativ Integration
   *                            Add Bioverative Source Systems and Trans Adjs
   *                            Add Bioverative direct adjustment lookups
   *                            Adjust ICW_KEY contract ID match rules
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
          z.parent_cust_id,
          -- Product -------------------------------------------------------------------------------
          z.ndc_lbl,
          z.ndc_prod,
          z.ndc_pckg,
          -- Component -----------------------------------------------------------------------------
          -- Root Identifiers ----------------------------------------------------------------------
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
          z.parent_trans_id,
          z.trans_id,
          -- Root Lookup IDs -----------------------------------------------------------------------
          -- SAP_ADJ: Link SAP/SAP4H adjustment to root SAP/SAP4H invoice
          CASE
             WHEN z.parent_trans_id IS NOT NULL
              AND z.rec_src_ind = z.rec_src_icw
              AND z.parent_trans_cls_cd = z.trans_cls_dir
              AND z.parent_source_sys_cde IN (z.system_sap,
                                              z.system_sap4h)
              AND z.parent_assc_invc_no IS NOT NULL
              AND z.parent_assc_invc_dt IS NOT NULL
              AND z.parent_assc_invc_source_sys_cd IS NOT NULL
             THEN (  -- START WITH clause uses index pk_mstr_trans_t
                     -- CONNECT BY clauses uses index mstr_trans_ix503
                     -- use MIN as there may be more than one line
                     SELECT /*+ QB_NAME( p8_sap )
                                NO_MERGE
                                INDEX( rt pk_mstr_trans_t )
                                INDEX( rt mstr_trans_ix503 )
                                DYNAMIC_SAMPLING( 0 )
                            */
                            MIN( rt.trans_id) trans_id
                       FROM hcrs.mstr_trans_t rt
                         -- get root row(s)
                      WHERE CONNECT_BY_ISLEAF = 1
                         -- limit snapshot
                        AND rt.snpsht_id <= z.snpsht_id
                         -- Only originals
                        AND rt.assc_invc_no IS NULL
                      START WITH rt.trans_id = z.parent_trans_id
                         -- Same data source, not archived, no manual adjustments
                         -- PRIOR is the current row used to get the next row in hierarchy
                      CONNECT BY rt.rec_src_ind = PRIOR rt.rec_src_ind
                             AND rt.co_id = PRIOR rt.co_id
                             AND rt.archive_ind = PRIOR rt.archive_ind
                              -- Customer ID must match to link to root transaction, however
                              -- Customer ID does not need to match to obtain Gross Dollars/Units/Packages
                             --AND rt.cust_id = PRIOR rt.cust_id
                              -- Must be same NDC
                             AND rt.ndc_lbl = PRIOR rt.ndc_lbl
                             AND rt.ndc_prod = PRIOR rt.ndc_prod
                             AND rt.ndc_pckg = PRIOR rt.ndc_pckg
                              -- Contract ID must match to link to root transaction, however
                              -- Contract ID does not need to match to obtain Gross Dollars/Units/Packages
                              --AND rt.contr_id = PRIOR rt.contr_id
                              -- Must be a direct sale
                             AND rt.trans_cls_cd = PRIOR rt.trans_cls_cd
                              -- Link to original invoice
                             AND rt.lgcy_trans_no = PRIOR rt.assc_invc_no
                             AND rt.source_sys_cde = PRIOR rt.assc_invc_source_sys_cde
                              -- Partition Pruning - Direct partition access
                             AND rt.paid_dt = PRIOR rt.assc_invc_dt
                  )
          END root_trans_id_sap_adj,
          -- ICW_KEY: Parent related sale/credit is used for root lookup
          -- CARS_ADJ: CARS chargeback/rebate root lookup
          CASE
             WHEN z.parent_trans_id IS NOT NULL
              AND z.rec_src_ind = z.rec_src_icw
              AND z.parent_trans_cls_cd IN (z.trans_cls_idr,
                                            z.trans_cls_rbt)
              AND z.parent_source_sys_cde = z.system_cars
              AND z.parent_assc_invc_no IS NOT NULL
             THEN (  -- START WITH clause uses index pk_mstr_trans_t
                     -- CONNECT BY clauses uses index mstr_trans_ix503
                     -- Use MIN as there may be more than one line
                     SELECT /*+ QB_NAME( p8_cars )
                                NO_MERGE
                                INDEX( rt pk_mstr_trans_t )
                                INDEX( rt mstr_trans_ix503 )
                                DYNAMIC_SAMPLING( 0 )
                            */
                            MIN( rt.trans_id) trans_id
                       FROM hcrs.mstr_trans_t rt
                         -- get root row(s)
                      WHERE CONNECT_BY_ISLEAF = 1
                         -- limit snapshot
                        AND rt.snpsht_id <= z.snpsht_id
                         -- Only originals
                        AND rt.assc_invc_no IS NULL
                      START WITH rt.trans_id = z.parent_trans_id
                         -- Same data source, not archived, no manual adjustments
                         -- PRIOR is the current row used to get the next row
                      CONNECT BY rt.rec_src_ind = PRIOR rt.rec_src_ind
                             AND rt.co_id = PRIOR rt.co_id
                             AND rt.archive_ind = PRIOR rt.archive_ind
                              -- Customer ID must match to link to parent transaction, however
                              -- Customer ID does not need to match to obtain Gross Dollars/Units/Packages
                              --AND rt.cust_id = PRIOR rt.cust_id
                              -- Must be same NDC
                             AND rt.ndc_lbl = PRIOR rt.ndc_lbl
                             AND rt.ndc_prod = PRIOR rt.ndc_prod
                             AND rt.ndc_pckg = PRIOR rt.ndc_pckg
                              -- Must be a CARS chargeback/rebate same as this chargeback/rebate
                             AND rt.source_sys_cde = PRIOR rt.source_sys_cde
                             AND rt.trans_cls_cd = PRIOR rt.trans_cls_cd
                             -- Contract ID must match to link to parent transaction, however
                             -- Contract ID does not need to match to obtain Gross Dollars/Units/Packages
                             -- (RMUS/CARS always has a contract)
                             --AND rt.contr_id = PRIOR rt.contr_id
                              -- Link to original invoice
                             AND rt.lgcy_trans_no = PRIOR rt.assc_invc_no
                             AND rt.earn_bgn_dt = PRIOR rt.earn_bgn_dt
                              -----------------------------------------------------
                              -- Partition pruning - THESE MAKE A HUGE DIFFERENCE!!
                              -----------------------------------------------------
                              -- Parent rebate/chargeback will be paid on or before this rebate
                             AND rt.paid_dt <= PRIOR (rt.paid_dt + z.prune_days)
                              -- Parent rebate/chargeback will be paid on or after when this rebate was earned
                             AND rt.paid_dt >= PRIOR (rt.earn_bgn_dt - z.prune_days)
                  )
          END root_trans_id_cars_adj,
          -- X360_ADJ: Link parent X360 rebate/fee to root X360 rebate/fee
          CASE
             WHEN z.parent_trans_id IS NOT NULL
              AND z.rec_src_ind = z.rec_src_icw
              AND z.parent_trans_cls_cd = z.trans_cls_rbt
              AND z.parent_source_sys_cde = z.system_x360
              AND z.parent_assc_invc_no IS NOT NULL
             THEN (  -- START WITH clause uses index pk_mstr_trans_t
                     -- CONNECT BY clauses uses index mstr_trans_ix503
                     -- Use MIN as there may be more than one line
                     SELECT /*+ QB_NAME( p8_x360 )
                                NO_MERGE
                                INDEX( rt pk_mstr_trans_t )
                                INDEX( rt mstr_trans_ix503 )
                                DYNAMIC_SAMPLING( 0 )
                            */
                            MIN( rt.trans_id) trans_id
                       FROM hcrs.mstr_trans_t rt
                         -- get root row(s)
                      WHERE CONNECT_BY_ISLEAF = 1
                         -- limit snapshot
                        AND rt.snpsht_id <= z.snpsht_id
                         -- Only originals
                        AND rt.assc_invc_no IS NULL
                      START WITH rt.trans_id = z.parent_trans_id
                         -- Same data source, not archived, no manual adjustments
                      CONNECT BY rt.rec_src_ind = PRIOR rt.rec_src_ind
                             AND rt.co_id = PRIOR rt.co_id
                             AND rt.archive_ind = PRIOR rt.archive_ind
                              -- Customer ID must match to link to parent transaction, however
                              -- Customer ID does not need to match to obtain Gross Dollars/Units/Packages
                              --AND rt.cust_id = PRIOR rt.cust_id
                              -- Must be same NDC
                             AND rt.ndc_lbl = PRIOR rt.ndc_lbl
                             AND rt.ndc_prod = PRIOR rt.ndc_prod
                             AND rt.ndc_pckg = PRIOR rt.ndc_pckg
                              -- Must be an X360 rebate
                             AND rt.source_sys_cde = PRIOR rt.source_sys_cde
                             AND rt.trans_cls_cd = PRIOR rt.trans_cls_cd
                              -- X360 rebates do not have a contract ID
                              --AND rt.contr_id = PRIOR rt.contr_id
                              -- Link to original transaction
                             AND rt.lgcy_trans_no = PRIOR rt.assc_invc_no
                             AND rt.lgcy_trans_line_no = PRIOR rt.lgcy_trans_line_no
                             AND rt.earn_bgn_dt = PRIOR rt.earn_bgn_dt
                              -----------------------------------------------------
                              -- Partition pruning - THESE MAKE A HUGE DIFFERENCE!!
                              -----------------------------------------------------
                              -- Parent rebate will be paid on or before this rebate
                             AND rt.paid_dt <= PRIOR (rt.paid_dt + z.prune_days)
                              -- Parent rebate will be paid on or after when this rebate was earned
                             AND rt.paid_dt >= PRIOR (rt.earn_bgn_dt - z.prune_days)
                  )
          END root_trans_id_x360_adj,
          -- BIVV_ADJ: Link BIVVRXC direct adjustment to root BIVVRXC invoice
          CASE
             WHEN z.parent_trans_id IS NOT NULL
              AND z.rec_src_ind = z.rec_src_icw
              AND z.parent_trans_cls_cd = z.trans_cls_dir
              AND z.parent_source_sys_cde = z.system_bivvrxc
              AND z.parent_assc_invc_no IS NOT NULL
              AND z.parent_assc_invc_dt IS NOT NULL
             THEN (  -- START WITH clause uses index pk_mstr_trans_t
                     -- CONNECT BY clauses uses index mstr_trans_ix503
                     -- use MIN as there may be more than one line
                     SELECT /*+ QB_NAME( p8_bivv )
                                NO_MERGE
                                INDEX( rt pk_mstr_trans_t )
                                INDEX( rt mstr_trans_ix503 )
                                DYNAMIC_SAMPLING( 0 )
                            */
                            MIN( rt.trans_id) trans_id
                       FROM hcrs.mstr_trans_t rt
                         -- get root row(s)
                      WHERE CONNECT_BY_ISLEAF = 1
                         -- limit snapshot
                        AND rt.snpsht_id <= z.snpsht_id
                         -- Only originals
                        AND rt.assc_invc_no IS NULL
                      START WITH rt.trans_id = z.parent_trans_id
                         -- Same data source, not archived, no manual adjustments
                         -- PRIOR is the current row used to get the next row in hierarchy
                      CONNECT BY rt.rec_src_ind = PRIOR rt.rec_src_ind
                             AND rt.co_id = PRIOR rt.co_id
                             AND rt.archive_ind = PRIOR rt.archive_ind
                              -- Customer ID must match to link to root transaction, however
                              -- Customer ID does not need to match to obtain Gross Dollars/Units/Packages
                             --AND rt.cust_id = PRIOR rt.cust_id
                              -- Must be same NDC
                             AND rt.ndc_lbl = PRIOR rt.ndc_lbl
                             AND rt.ndc_prod = PRIOR rt.ndc_prod
                             AND rt.ndc_pckg = PRIOR rt.ndc_pckg
                              -- Contract ID does not need to match link or obtain Gross Dollars/Units/Packages
                              --AND rt.contr_id = PRIOR rt.contr_id
                              -- Must be a direct sale
                             AND rt.trans_cls_cd = PRIOR rt.trans_cls_cd
                              -- Link to original invoice
                             AND rt.lgcy_trans_no = PRIOR rt.assc_invc_no
                              -- Partition Pruning - Direct partition access
                             AND rt.paid_dt = PRIOR rt.assc_invc_dt
                  )
          END root_trans_id_bivv_adj,
          -- PRASCO_RBTFEE: Prasco rebate/fee only has one level of relationship to the parent direct/indirect sale
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
             ---------------------------------------------------------------------------------------
             -- No Parent found
             WHEN z.parent_trans_id IS NULL
             THEN z.flag_no
             ---------------------------------------------------------------------------------------
             -- ICW_KEY Linking
             -- The contract ID of an RMUS/CARS ICW_KEY rebate must match the contract ID of an
             -- SAP/SAP4H/RMUS/CARS related sale/credit or the related sale/credit contract ID can
             -- be NULL, but they does not need to match to obtain Gross Dollars/Units/Packages.
             -- If the ICW_KEY rebate is not from RMUS/CARS or the related sale/credit is not from
             -- SAP/SAP4H/RMUS/CARS, the contract IDs do NOT need to match. The customer IDs never
             -- need to match.
             WHEN z.parent_trans_id_icw_key IS NOT NULL
              AND z.source_sys_cde = z.system_cars
              AND z.parent_source_sys_cde IN (z.system_cars,
                                              z.system_sap,
                                              z.system_sap4h)
              AND NVL( z.parent_contr_id, z.contr_id) <> z.contr_id
             THEN z.flag_no
             WHEN z.parent_trans_id_icw_key IS NOT NULL
             THEN z.flag_yes
             ---------------------------------------------------------------------------------------
             -- CARS_ADJ Linking: The customer IDs and contact IDs must match, but
             -- they does not need to match to obtain Gross Dollars/Units/Packages.
             WHEN z.parent_trans_id_cars_adj IS NOT NULL
              AND z.parent_cust_id = z.cust_id
              AND z.parent_contr_id = z.contr_id
             THEN z.flag_yes
             WHEN z.parent_trans_id_cars_adj IS NOT NULL
             THEN z.flag_no
             ---------------------------------------------------------------------------------------
             -- CARS_RBT_FEE Linking: The customer IDs and contact IDs must match, but
             -- they does not need to match to obtain Gross Dollars/Units/Packages.
             WHEN z.parent_trans_id_cars_rbt_fee IS NOT NULL
              AND z.parent_cust_id = z.cust_id
              AND z.parent_contr_id = z.contr_id
             THEN z.flag_yes
             WHEN z.parent_trans_id_cars_rbt_fee IS NOT NULL
             THEN z.flag_no
             ---------------------------------------------------------------------------------------
             -- SAP_ADJ Linking: The customer IDs must match, and the contact IDs must match (same
             -- value or both are NULL), but they does not need to match to obtain Gross Dollars/
             -- Units/Packages.  Linking must be on, but use date mobility:
             -- N = No link, orig+adjs always included separately by their invoice dates
             -- S = Soft Link, orig+adjs linked if their invoices dates are in the same component
             -- Y = Hard Link, orig+adjs always linked and included on original invoice date
             WHEN z.parent_trans_id_sap_adj IS NOT NULL
              AND z.parent_cust_id = z.cust_id
              AND NVL( z.parent_contr_id, '-NULL-') = NVL( z.contr_id, '-NULL-')
             THEN z.sap_adj_dt_mblty
             WHEN z.parent_trans_id_sap_adj IS NOT NULL
             THEN z.flag_no
             ---------------------------------------------------------------------------------------
             -- X360_ADJ Linking: The customer IDs must match (Xenon doesn't have and contact IDs),
             --  but they does not need to match to obtain Gross Dollars/Units/Packages.
             WHEN z.parent_trans_id_x360_adj IS NOT NULL
              AND z.parent_cust_id = z.cust_id
             THEN z.flag_yes
             WHEN z.parent_trans_id_x360_adj IS NOT NULL
             THEN z.flag_no
             ---------------------------------------------------------------------------------------
             -- BIVV_ADJ Linking: The customer IDs must match, but the contact IDs do not need to
             -- match.  SAP link settings are used as they are really direct adjustment settings.
             -- Linking must be on, but use date mobility:
             -- N = No link, orig+adjs always included separately by their invoice dates
             -- S = Soft Link, orig+adjs linked if their invoices dates are in the same component
             -- Y = Hard Link, orig+adjs always linked and included on original invoice date
             WHEN z.parent_trans_id_bivv_adj IS NOT NULL
              AND z.parent_cust_id = z.cust_id
             THEN z.sap_adj_dt_mblty
             WHEN z.parent_trans_id_bivv_adj IS NOT NULL
             THEN z.flag_no
             ---------------------------------------------------------------------------------------
             -- PRASCO_RBTFEE Linking: The customer IDs must match (Prasco doesn't have and contact IDs),
             --  but they does not need to match to obtain Gross Dollars/Units/Packages.
             WHEN z.parent_trans_id_prasco_rbtfee IS NOT NULL
              AND z.parent_cust_id = z.cust_id
             THEN z.flag_yes
             WHEN z.parent_trans_id_prasco_rbtfee IS NOT NULL
             THEN z.flag_no
          END parent_link_ind,
          -- Related Trans -------------------------------------------------------------------------
          -- Prasco Rebates Link -------------------------------------------------------------------
          -- Trans Flags ---------------------------------------------------------------------------
          z.source_trans_typ,
          -- Sales Exclusion -----------------------------------------------------------------------
          -- Root Keys/Dates -----------------------------------------------------------------------
          -- Parent Keys/Dates ---------------------------------------------------------------------
          z.parent_paid_dt,
          z.parent_earn_bgn_dt,
          z.parent_earn_end_dt,
          z.parent_assc_invc_dt,
          z.parent_assc_invc_no,
          -- Transaction Dates ---------------------------------------------------------------------
          z.paid_dt,
          z.earn_bgn_dt,
          z.earn_end_dt,
          z.assc_invc_dt,
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
     FROM hcrs.calc_csr_main_p7_v z;
