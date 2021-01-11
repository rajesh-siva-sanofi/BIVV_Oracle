CREATE OR REPLACE PACKAGE pkg_common_cursors
IS
   /****************************************************************************
   * Package Name : pkg_common_cursors
   * Date Created : 9/27/2000
   *       Author : Venkata Darabala
   *  Description : Common Cursors and types used for AMP/BP/NonFAMP/ASP Calcs
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  02/10/2002  Joe Kidd      PICC 279: Modified cursors for SAP tie
   *                            adjustment to original invoice
   *  04/17/2002  Joe Kidd      PICC 832: Order cursor to allow rollup of
   *                            transactions and SAP adjs by lgcy_trans_no
   *  05/30/2002  Joe Kidd      Format code, replace literals with constants
   *                            where possible
   *  06/14/2002  Joe Kidd      PICC 833: Group BP Rebate/Fee by lgcy_trans_no
   *                            and lgcy_trans_line_no (submitm_num and adj_num)
   *  07/31/2002  Joe Kidd      PICC 856: Order cursor to allow rollup of
   *                            indirect sales transactions by lgcy_trans_no
   *  08/20/2002  Joe Kidd      PICC 856: Changed cursors and ouput records to
   *                            include source system code and record source
   *                            indicator both needed to properly identify the
   *                            transaction source
   *  08/20/2002  Joe Kidd      PICC 876: Changed SAP Adj logic to use
   *                            Snapshot ID, and only on SAP source records
   *  08/20/2002  Joe Kidd      PICC 876: Added join_reason, parent_trans_id
   *                            to trans_id_rec to identify the reason a trans
   *                            was joined to the price point.
   *  09/11/2002  Joe Kidd      PICC 856: Added Transaction adjustment code,
   *                            root trans_id and parent trans_id to identify
   *                            source transaction
   *  10/02/2002  Joe Kidd      PICC 913: Changed cursors and output records to
   *                            include source_trans_typ and unique_id to allow
   *                            a lookup on related_sales_num for ICW sales
   *  10/17/2002  Joe Kidd      PICC 922: AMP should use claim period dates if
   *                            they exist otherwise use trans date
   *  11/01/2002  Joe Kidd      PICC 857: Apply rebates and fees to indirect sales
   *  11/11/2002  Joe Kidd      PICC 912: Allow CARS 3.8 Resubmissions to be
   *                            rolled up like old style CARS corrections
   *  02/03/2004  Joe Kidd      PICC 1167: Medicare ASP changes
   *  08/09/2004  Joe Kidd      PICC 1253: Use prfl_mtrx_v view instead of
   *                            prfl_mtrx_t table
   *  08/09/2004  Joe Kidd      PICC 1253: Add Matrix begin/end dates
   *  11/01/2004  Joe Kidd      PICC 1327: Calc Cursor Tuning
   *                            BP Forecast pckgs must always return 1
   *                            Remove RULE hint from AMP-QEDD query
   *  02/01/2005  Joe Kidd      PICC 1372: Correct Assc_invc_dt usage
   *                            Add bulk collect structures
   *                            Combine ASP Direct/Rebate/Special Program
   *                            queries
   *                            Renamed all queries and added new queries
   *                            Restructure csr_amp_qedd for performance
   *                            Restructure csr_amp_aowdd for performance
   *                            Change how snpsht_id and man_adj_agency_cd are ref'd
   *                            Added trans_typ_ord field to records and all queries
   *  06/01/2005  Joe Kidd      PICC 1413: Besse/Kinray rebates use pkg_qty
   *                            instead of claim_unit_qty
   *  01/13/2006  Joe Kidd      PICC 1509: BP Rbt/Fee pull ignores transactions
   *                            with NULL contr_id
   *  04/20/2006  Joe Kidd      PICC 1563: Missing prfl_id on matrix causing
   *                            SAP adjustments to be overcounted
   *  06/12/2006  Joe Kidd      PICC 1557:
   *                            csr_amp_aowdd: Don't change rebates/fees to directs
   *                            csr_amp_relcrd: Don't change rebates/fees to directs
   *                            csr_nfamp_qedd: Change nominal amount processing
   *                            csr_nfamp_qiid: Change nominal amount processing
   *                            csr_asp_qedd: Change nominal amount processing
   *  12/13/2006  Joe Kidd      PICC 1680:
   *                            Deleted:
   *                               csr_amp_qedd
   *                               csr_amp_aowdd
   *                               csr_amp_sapadj
   *                               csr_amp_rbtfee
   *                               csr_amp_relcrd
   *                            New:
   *                               csr_non_idr_trans_dt
   *                               csr_non_idr_claim_dt
   *                               csr_idr
   *                               csr_sapadj
   *                               csr_rbtfee
   *                               csr_relcrd
   *                            Add dllrs_grs, dllrs_dsc, dllrs_net, pkgs, units,
   *                              pri_whls_mthd_cd, cust_cot_incl_ind, cust_cot_grp_cd,
   *                              whls_cot_incl_ind, whls_cot_grd_cd, and
   *                              trans_typ_incl_ind to calc_rec, calc_rec2, and all cursors
   *                            Remove prfl_co_t from all cursors, use pkg_constants.var_co_id instead
   *                            Reorganized all queries, added ordered hint
   *  02/15/2007  Joe Kidd      PICC 1706:
   *                            Deleted:
   *                               csr_asp_qedd
   *                               csr_asp_aiid
   *                               csr_asp_sapadj
   *                               csr_asp_rbtfee
   *                               csr_asp_relcrd
   *                               csr_nfamp_qedd
   *                               csr_nfamp_aiid
   *                               csr_nfamp_sapadj
   *                               csr_nfamp_rbtfee
   *                               csr_nfamp_relcrd
   *                            csr_non_idr_trans_dt:
   *                              Remove related_sales_id limit
   *                              Add link to Sales Exclusions
   *                            csr_non_idr_claim_dt:
   *                              Remove related_sales_id limit
   *                              Add link to Sales Exclusions
   *                            csr_idr:
   *                              Remove related_sales_id limit
   *                              Add link to Sales Exclusions
   *                            csr_sapadj:
   *                              Add link to Sales Exclusions
   *                            csr_rbtfee:
   *                              Add link to Sales Exclusions
   *                            csr_relcrd:
   *                              Add link to Sales Exclusions
   *  05/18/2007  Joe Kidd      PICC 1769:
   *                            Fix incorrect year in previous change comments
   *                            Types:
   *                              Removed unneeded types and fields
   *                              Add claim_bgn_dt, claim_end_dt,
   *                              lgcy_trans_line_no to types and fields
   *                            Deleted:
   *                              csr_bp_fm
   *                              csr_bp_rm_dir
   *                              csr_bp_rm_idr
   *                              csr_bp_rm_rbt
   *                              csr_bp_sapadj
   *                              csr_bp_rbtfee
   *                              csr_bp_relcrd
   *                            csr_non_idr_trans_dt, csr_non_idr_claim_dt, csr_idr:
   *                              Restructure entire query for tuning
   *                              Removed unneeded fields
   *                              Add claim_bgn_dt, claim_end_dt,
   *                              lgcy_trans_line_no to types and fields
   *                              Fix product rollup issue
   *                              Use matrix work table
   *                            csr_relcrd, csr_sapadj, csr_rbtfee:
   *                              Restructure entire query for tuning
   *                              Removed unneeded fields
   *                              Add claim_bgn_dt, claim_end_dt,
   *                              lgcy_trans_line_no to types and fields
   *                              Fix product rollup issue
   *                              Use matrix work table
   *                              Add i_trans_typ_grp_cd and i_cust_cot_grp_cd
   *                              parameters to enforce lookup logic
   *  10/01/2007  Joe Kidd      PICC 1808:
   *                            csr_non_idr_trans_dt, csr_non_idr_claim_dt,
   *                            csr_idr, csr_sapadj, csr_rbtfee, csr_relcrd:
   *                              Remove trans_typ_grp_t from query as Trans Type
   *                              Group Processing Order is on prfl_mtrx_wrk_t
   *  12/05/2007  Joe Kidd      PICC 1763:
   *                            New: t_trans_typ_cd, t_splt_pct_typ, t_splt_pct_seq_no
   *                            Renamed calc_rec to t_calc_rec, calc_ref_csr to
   *                            t_calc_ref_csr, calc_tbl to t_calc_tbl, calc_rec2
   *                            to t_calc_rec2,
   *                            t_calc_rec, t_calc_rec2:
   *                              Added transaction type, split percentage type,
   *                              split percentage sequence number
   *                            csr_sapadj, csr_relcrd:
   *                              Converted to cursor
   *                              Use product work table instead of inline query
   *                              Limit by NDC
   *                              Added transaction type, split percentage type,
   *                              split percentage sequence number
   *                            csr_rbtfee:
   *                              Converted to cursor
   *                              Use product work table instead of inline query
   *                              Added transaction type, split percentage type,
   *                              split percentage type sequence number
   *                            csr_non_idr_trans_dt, csr_non_idr_claim_dt, csr_idr:
   *                              Remove NDC parameters
   *                              Use product work table instead of inline query
   *                              Added transaction type, split percentage type,
   *                              split percentage sequence number
   *  04/22/2008  Joe Kidd      PICC 1865:
   *                            New: t_num, t_price_grp_id, t_bndl_cd, t_bndl_seq_no,
   *                              t_bndl_id, t_prcg_trns_cnt, t_prcg_dllrs_grs,
   *                              t_prcg_dllrs_dsc, t_prcg_dsc_pct, t_perf_trns_cnt,
   *                              t_perf_dllrs_grs, t_perf_dllrs_dsc, t_perf_dsc_pct,
   *                              t_bndl_trns_rec,
   *                              f_ins_bndl_cp_smry, f_ins_bndl_cp_trans
   *                            Deleted: t_calc_typ_cd, t_dllrs_grs, t_dllrs_dsc,
   *                              t_dllrs_net, t_pkgs, t_units, t_disc_pct,
   *                              t_whls_cot_incl_ind, t_whls_cot_grp_cd,
   *                              t_root_trans_id, t_parent_trans_id
   *                            t_calc_rec:
   *                              Added org_dllrs_grs, org_dllrs_dsc, org_dllrs_net,
   *                              org_pkgs, org_units, price_grp_id, earnd_dt,
   *                              bndl_cd, bndl_seq_no
   *                            t_calc_rec2:
   *                              Added org_dllrs_grs, org_dllrs_dsc, org_dllrs_net,
   *                              org_pkgs, org_units, price_grp_id, earnd_dt,
   *                              bndl_cd, bndl_seq_no
   *                              Use common types for the following: dllrs_grs,
   *                              dllrs_dsc, dllrs_net, pkgs, units, disc_pct,
   *                              whls_cot_incl_ind, whls_cot_grp_cd,
   *                              root_trans_id, parent_trans_id
   *                            csr_sapadj, csr_rbtfee, csr_relcrd, csr_idr,
   *                            csr_non_idr_trans_dt, csr_non_idr_claim_dt:
   *                              Retrieve related sales gross dollars, packages, and units
   *                              Added org_dllrs_grs, org_dllrs_dsc, org_dllrs_net,
   *                              org_pkgs, org_units, price_grp_id, earnd_dt,
   *                              bndl_cd, bndl_seq_no
   *  06/16/2008  Joe Kidd      PICC 1927:
   *                            Removed: t_bndl_id, f_ins_bndl_cp_smry
   *                            csr_sapadj, csr_rbtfee, csr_relcrd, csr_idr,
   *                            csr_non_idr_trans_dt, csr_non_idr_claim_dt:
   *                              Correct retrieval of related sales gross dollars
   *                            f_ins_bndl_cp_trans:
   *                              Use Loop to process transactions
   *                              Use passed dates to determine eligible transactions
   *                              Add Condition parameter
   *  08/22/2008  Joe Kidd      PICC 1961:
   *                            csr_sapadj, csr_rbtfee, csr_relcrd:
   *                              Move cursor queries to package body
   *                            f_ins_bndl_cp_trns:
   *                              Remove contract and price group limitation from
   *                              performance period
   *                              Remove FOR loop and replace with single queries
   *  08/07/2008  Joe Kidd      PICC 1950:
   *                            New: t_assc_invc_dt, csr_saporg
   *                            t_calc_rec: Add assc_invc_dt
   *                            t_calc_rec2: Add assc_invc_dt
   *                            csr_sapadj:
   *                              Add assc_invc_dt
   *                              Remove null related_sales_id condition
   *                            csr_rbtfee, csr_idr: Add assc_invc_dt
   *                            csr_relcrd:
   *                              Add assc_invc_dt
   *                              Limit to CARS credits
   *                            csr_non_idr_trans_dt, csr_non_idr_claim_dt:
   *                              Add assc_invc_dt
   *                              Remove SAP adjustment filters
   *  05/06/2009  Joe Kidd      PICC 2051:
   *                            New: csr_x360adj
   *                            csr_non_idr_claim_dt: Add X360 Adjustment filter
   *  07/22/2009  Joe Kidd      RT 267 - CRQ 43432: Bundling Tuning
   *                            csr_non_idr_trans_dt, csr_non_idr_claim_dt, csr_idr:
   *                              Add Source System Code parameter to limit by
   *                              source system
   *                            f_ins_bndl_cp_trns:
   *                              Remove out parameter no longer required
   *                              Add cursor names
   *                              Add index hint to query csr_bndl_cp_trns
   *                              Remove view reference for first_value no
   *                              longer required in Oracle 10g
   *                              Check that one or more NDCs from the current
   *                              calculation were used
   *                              Use Bundle Summary work table
   *  04/01/2010  Joe Kidd      RT 372 - CRQ 43435 - IS-000000000018
   *                            New: csr_prasco_rbtfee
   *                            csr_x360adj:
   *                              Add hint to force index use
   *  04/26/2010  Joe Kidd      RT 2009-724 - CRQ 46973: Revise Bundling Methodology
   *                            f_ins_bndl_cp_trns:
   *                              Combine all queries into a single multi-table
   *                              insert to reduce context switches and improve
   *                              data access paths and build all bundles at once
   *                              Discontinue use of global temp table
   *                              Correct linking of credits with a related sale
   *                              Check for pricing period gross dollars
   *                              Check for calc NDCs during the min-max date range
   *  12/01/2010  Joe Kidd      CRQ-931: December 2010 Govt Calculations Release
   *                            t_calc_rec:
   *                              Add csr_cnt count of rows in cursor
   *                            t_calc_rec2:
   *                              Add csr_cnt count of rows in cursor
   *                            csr_saporg, csr_sapadj, csr_x360adj,
   *                            csr_prasco_rbtfee, csr_rbtfee, csr_relcrd:
   *                              Convert dllrs/pkgs/units DECODEs to CASEs
   *                              Add Commercial Units/Pckg conversion
   *                              Add count of rows to each cursor
   *                            csr_non_idr_trans_dt, csr_non_idr_claim_dt,
   *                            csr_idr:
   *                              Convert dllrs/pkgs/units DECODEs to CASEs
   *                              Add Commercial Units/Pckg conversion
   *                              Add count of rows to each cursor
   *                              Remove Source System Code parameter to limit by
   *                              source system
   *                            f_ins_bndl_cp_trns:
   *                              Adjust hint on prfl_prod_bndl_smry_wrk_t due
   *                              to index name change
   *  01/28/2010  Joe Kidd      CRQ-1222: Bundling BP Linking issue
   *                            t_calc_rec, t_calc_rec2, csr_saporg, csr_sapadj,
   *                            csr_x360adj, csr_non_idr_trans_dt,
   *                            csr_non_idr_claim_dt, csr_idr:
   *                              Removed earnd_dt from cursor output
   *                            csr_prasco_rbtfee, csr_rbtfee, csr_relcrd:
   *                              Change trans_dt value to earned date for rebate lookups
   *                              Removed earnd_dt from cursor output
   *  01/28/2010  Joe Kidd      CRQ-1412: Winthrop Chargeback-Rebate linking
   *                            csr_relcrd:
   *                              Add contr_id parameter
   *                              Rebate must be on same contract as sale
   *  04/01/2011  Joe Kidd      CRQ-3921: Linking of CARS chargebacks
   *                            t_calc_rec, t_calc_rec2
   *                              Add root lgcy trans no
   *                              Reorder cursor fields
   *                            csr_saporg csr_sapadj, csr_x360adj,
   *                            csr_prasco_rbtfee,
   *                              Add root lgcy trans no
   *                              Reorder cursor fields
   *                              Add new order by clause
   *                            csr_rbtfee
   *                              Add root lgcy trans no
   *                              Reorder cursor fields
   *                              Add new order by clause
   *                              Add heirarchical subquery for CARS root trans
   *                              Don't use assc_invc_no to find matches
   *                            csr_relcrd, csr_non_idr_trans_dt,
   *                            csr_non_idr_claim_dt, csr_idr
   *                              Add root lgcy trans no
   *                              Reorder cursor fields
   *                              Add new order by clause
   *                              Add heirarchical subquery for CARS root trans
   *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
   *                            NEW: t_prcss_seq_no, t_cust_domestic_ind,
   *                            t_cust_territory_ind,
   *                            t_calc_rec, t_calc_rec2
   *                              Add Process sequence number
   *                              Add WAC value of packages and reorder dollars fields
   *                              Add Customer and Wholesaler Domestic and
   *                              Territory indicators
   *                            csr_saporg, csr_sapadj, csr_x360adj,
   *                            csr_prasco_rbtfee, csr_rbtfee, csr_relcrd,
   *                            csr_non_idr_trans_dt, csr_non_idr_claim_dt,
   *                            csr_idr
   *                              Restrict transactions by data source (company ID)
   *                              Add Process sequence number
   *                              Add WAC value of packages and reorder dollars fields
   *                              Add Customer and Wholesaler Domestic and
   *                              Territory indicators
   *                              No duplicate transactions
   *                            f_ins_bndl_cp_trns
   *                              Restrict transactions by data source (company ID)
   *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
   *                            csr_saporg, csr_sapadj, csr_x360adj,
   *                            csr_prasco_rbtfee, csr_rbtfee, csr_relcrd,
   *                            csr_non_idr_trans_dt, csr_non_idr_claim_dt,
   *                            csr_idr
   *                              Remove Domestic and Territory filtering that
   *                              is now performed after retreival
   *                              Change non-indirect wholesaler values
   *                              Change refernces to NDC in product work table
   *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
   *                            New: csr_main
   *                            Removed: csr_non_idr_trans_dt,
   *                              csr_non_idr_claim_dt, csr_idr
   *                            t_calc_rec, t_calc_rec2
   *                              Update for new trans table
   *                            csr_saporg, csr_sapadj
   *                              Update for new trans table
   *                              Change source of lkup settings
   *                              Add customer ID due to SAP changing customer ID
   *                            csr_x360adj, csr_prasco_rbtfee, csr_rbtfee, csr_relcrd
   *                              Update for new trans table
   *                              Change source of lkup settings
   *                            f_ins_bndl_cp_trns
   *                              Update for new trans table
   *  02/11/2013  Joe Kidd      CRQ-93846: Add hint to correct performance issue
   *                            csr_main
   *                              Add hint to correct performance issue
   *  09/22/2014  Joe Kidd      CRQ-126918: Correct SAP adjustment duplication
   *                            csr_main
   *                              Correct SAP Original to Adjustment linking
   *                              Change transaction output order
   *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
   *                            New: f_calc_amt
   *                            Removed: t_calc_rec2 and other bulk collect types
   *                              Simplify bulk collections
   *                            t_calc_rec
   *                              Add prompt pay dollars
   *                            csr_saporg, csr_sapadj, csr_x360adj, csr_prasco_rbtfee,
   *                            csr_rbtfee, csr_relcrd
   *                              Use new Profile Cust COT working table
   *                              Change behavior of WAC/GRS/NET/DSC for Direct Sales/Credits
   *                              Updated WAC/GRS/NET/DSC to use f_calc_amt
   *                              Add prompt pay dollars, wac extended amount,
   *                              transaction class, related sale trans id
   *                            csr_main
   *                              Use new Profile Cust COT working table
   *                              Change behavior of WAC/GRS/NET/DSC for Direct Sales/Credits
   *                              Updated WAC/GRS/NET/DSC to use f_calc_amt
   *                              Add prompt pay dollars, wac extended amount,
   *                              transaction class, related sale trans id
   *                              Correct CARS/SAP trans linking in root/lgcy_trans lookup and order
   *                            f_ins_bndl_cp_trns
   *                               Remove trans type and add cust COT parameter
   *                               Refactor to process all transactions for a customer
   *                               Include SAP transactions
   *                               Correct CARS rebate linking
   *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
   *                            t_calc_rec
   *                              Remove uneeded org* columns
   *                            csr_saporg,
   *                              Remove uneeded org* columns
   *                              Use Profile Prod Calc Comp Def working table
   *                              Relax SAP adjustment lookup by Tran Type Group
   *                            csr_x360adj, csr_prasco_rbtfee,
   *                            csr_rbtfee, csr_relcrd
   *                              Remove uneeded org* columns
   *                              Use Profile Prod Calc Comp Def working table
   *                            csr_sapadj
   *                              Correct WAC for SAP Adjustments
   *                              Remove uneeded org* columns
   *                              Use Profile Prod Calc Comp Def working table
   *                              Relax SAP adjustment lookup by Tran Type Group
   *                              Allow to find RBT/FEE SAP adjustments when
   *                              rebate/fee lookup is on
   *                            csr_main
   *                              Correct WAC for SAP Adjustments
   *                              Remove uneeded org* columns
   *                              Use Profile Prod Calc Comp Def working table
   *                              Use Profile Class of Trade working table
   *                            f_ins_bndl_cp_trns
   *                              Correct WAC for SAP Adjustments
   *                              Correct Gross Dollars on Reversed Rebates
   *  05/25/2016  Joe Kidd      CRQ-266675: Demand 3336 AMP Final Rule (June Release)
   *              T. Zimmerman  csr_saporg
   *                              SAP adjustments can be by invoice date, paid date, or earned date
   *                            csr_sapadj, f_calc_amt
   *                              Add Factored Rebates/Fees to rules
   *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
   *                            csr_main
   *                              Adjust sort order, customer first
   *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
   *                            New: t_trans_cls_bndl_rec, t_trans_cls_bndl_tbl,
   *                                 csr_bndl_adj_trns
   *                            csr_saporg, csr_sapadj, csr_x360adj, csr_main
   *                              Add hints to all parts of the query
   *                            csr_rbtfee, csr_relcrd
   *                              Add hints to heirarchical queries
   *                            csr_main
   *                              Add hints to all parts of the query
   *                              Refactor cnd subqueries to be more efficient
   *                            f_ins_bndl_cp_trns
   *                              Use global variables for marking NDC columns
   *                              Prioritize Pricing period over Performance Period
   *                              Expand hints on all subqueries
   *                              Don't insert dummy bundle summary rows
   *                              Adjust matrix subquery, add index and hint
   *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
   *                            Removed: t_calc_rec, t_calc_ref_csr, t_calc_tbl,
   *                              csr_saporg, csr_sapadj, csr_x360adj, csr_rbtfee,
   *                              csr_prasco_rbtfee, csr_relcrd, csr_bndl_adj_trns,
   *                              csr_main, f_calc_amt
   *                            New: t_calc_trans_rec, t_calc_trans_ref_csr,
   *                                 t_calc_trans_tbl, f_csr_main
   *                            f_ins_bndl_cp_trns
   *                              Move query to view, add GTT for transaction
   *                              detail, delete the GTT contents before insert
   *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
   *                              formula / Winthrop BP Change
   *                            t_calc_trans_rec
   *                              Add Wholesaler COT Supergroup
   *                              Correct %TYPE anchors
   *                            f_csr_main
   *                              Add Wholesaler COT Supergroup
   *                            f_ins_bndl_cp_trns
   *                              Correct hints
   *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
   *                            t_calc_trans_rec
   *                              GTT column reduction
   *                            f_csr_main
   *                              GTT column reduction
   *                              Add normal exception handling (Calc Debug Mode)
   *                            f_ins_bndl_cp_trns
   *                              Multi-table insert handles both trans tables
   *                              Remove order by from multitable insert select
   *                              Remove GTT delete by customer
   *                              Correct hints
   *                              Add normal exception handling (Calc Debug Mode)
   ****************************************************************************/

   -----------------------------------------------------------------------------
   -- Calculation transaction record
   -----------------------------------------------------------------------------
   TYPE t_calc_trans_rec IS RECORD
       -- Source -------------------------------------------------------------------------------------------------------------------------------------
       -- Customer -----------------------------------------------------------------------------------------------------------------------------------
       (cust_id                   hcrs.mstr_trans_t.cust_id%TYPE,                                       -- 01: Customer ID
        orig_cust_id              hcrs.mstr_trans_t.cust_id%TYPE,                                       -- 02: Customer ID
        cust_cls_of_trd_cd        hcrs.prfl_cust_cls_of_trd_wrk_t.cls_of_trd_cd%TYPE,                   -- 03: Customer Class of Trade
       -- Root Customer ------------------------------------------------------------------------------------------------------------------------------
       -- Parent Customer ----------------------------------------------------------------------------------------------------------------------------
       -- Product ------------------------------------------------------------------------------------------------------------------------------------
        ndc_lbl                   hcrs.mstr_trans_t.ndc_lbl%TYPE,                                       -- 04: Trans NDC Labeler
        ndc_prod                  hcrs.mstr_trans_t.ndc_prod%TYPE,                                      -- 05: Trans NDC Product Family
        ndc_pckg                  hcrs.mstr_trans_t.ndc_pckg%TYPE,                                      -- 06: Trans NDC Package
       -- Component ----------------------------------------------------------------------------------------------------------------------------------
        comp_typ_cd               hcrs.prfl_prod_calc_comp_def2_wrk_t.comp_typ_cd%TYPE,                 -- 07: Component for accumulation
        mark_accum_all_ind        hcrs.prfl_prod_calc_comp_def2_wrk_t.mark_accum_all_ind%TYPE,          -- 08: Accumulate All (Y/N/-)
        mark_accum_nom_ind        hcrs.prfl_prod_calc_comp_def2_wrk_t.mark_accum_nom_ind%TYPE,          -- 09: Accumulate Nominal (Y/N/-)
        mark_accum_hhs_ind        hcrs.prfl_prod_calc_comp_def2_wrk_t.mark_accum_hhs_ind%TYPE,          -- 10: Accumulate SubPHS (Y/N/-)
        mark_accum_contr_ind      hcrs.prfl_prod_calc_comp_def2_wrk_t.mark_accum_contr_ind%TYPE,        -- 11: Accumulate Contracted (Y/N/-)
        mark_accum_fsscontr_ind   hcrs.prfl_prod_calc_comp_def2_wrk_t.mark_accum_fsscontr_ind%TYPE,     -- 12: Accumulate FSS Contracts (Y/N/-)
        mark_accum_phscontr_ind   hcrs.prfl_prod_calc_comp_def2_wrk_t.mark_accum_phscontr_ind%TYPE,     -- 13: Accumulate PHS Contracts (Y/N/-)
        mark_accum_zerodllrs_ind  hcrs.prfl_prod_calc_comp_def2_wrk_t.mark_accum_zerodllrs_ind%TYPE,    -- 14: Accumulate Zero Dollars (Y/N/-)
       -- Root Identifiers ---------------------------------------------------------------------------------------------------------------------------
       -- Marking Trans Date -------------------------------------------------------------------------------------------------------------------------
        trans_dt                  hcrs.mstr_trans_t.paid_dt%TYPE,                                       -- 15: Marked Trans Date
       -- Parent Identifiers -------------------------------------------------------------------------------------------------------------------------
       -- Trans Identifiers --------------------------------------------------------------------------------------------------------------------------
        trans_cls_cd              hcrs.mstr_trans_t.trans_cls_cd%TYPE,                                  -- 16: Trans class
        source_sys_cde            hcrs.mstr_trans_t.source_sys_cde%TYPE,                                -- 17: Source System
        assc_invc_no              hcrs.mstr_trans_t.assc_invc_no%TYPE,                                  -- 18: Original Legacy Trans/Invoice number
       -- Trans IDs ----------------------------------------------------------------------------------------------------------------------------------
        root_trans_id             hcrs.mstr_trans_t.trans_id%TYPE,                                      -- 19: Root Trans ID for Trans group
        parent_trans_id           hcrs.mstr_trans_t.trans_id%TYPE,                                      -- 20: Parent Trans ID for Trans group
        trans_id                  hcrs.mstr_trans_t.trans_id%TYPE,                                      -- 21: Trans ID
        trans_adj_cd              hcrs.prfl_prod_wrk_t.trans_adj_original%TYPE,                         -- 22: Trans adjustment code
       -- Root Lookup IDs ----------------------------------------------------------------------------------------------------------------------------
       -- Parent Lookup IDs --------------------------------------------------------------------------------------------------------------------------
        parent_trans_id_icw_key   hcrs.mstr_trans_t.trans_id%TYPE,                                      -- 23: Parent ICW Key Trans ID
       -- Link Markers -------------------------------------------------------------------------------------------------------------------------------
       -- Related Trans ------------------------------------------------------------------------------------------------------------------------------
       -- Prasco Rebates Link ------------------------------------------------------------------------------------------------------------------------
       -- Trans Flags --------------------------------------------------------------------------------------------------------------------------------
       -- Sales Exclusion ----------------------------------------------------------------------------------------------------------------------------
        sls_excl_ind              hcrs.prfl_sls_excl_t.over_ind%TYPE,                                   -- 24: Sales Exclusion Indicator
       -- Root Keys/Dates ----------------------------------------------------------------------------------------------------------------------------
       -- Parent Keys/Dates --------------------------------------------------------------------------------------------------------------------------
       -- Transaction Dates --------------------------------------------------------------------------------------------------------------------------
        earn_bgn_dt               hcrs.mstr_trans_t.earn_bgn_dt%TYPE,                                   -- 25: Trans Earned Begin Date
        earn_end_dt               hcrs.mstr_trans_t.earn_end_dt%TYPE,                                   -- 26: Trans Earned End Date
       -- Root Values --------------------------------------------------------------------------------------------------------------------------------
       -- Parent Values ------------------------------------------------------------------------------------------------------------------------------
       -- Transaction Values -------------------------------------------------------------------------------------------------------------------------
       -- Component Values ---------------------------------------------------------------------------------------------------------------------------
        dllrs_grs                 NUMBER,                                                               -- 27: Gross dollar amount (net + disc)
        dllrs_wac                 NUMBER,                                                               -- 28: WAC dollar value for units (wac * pkgs)
        dllrs_net                 NUMBER,                                                               -- 29: Net dollar amount (gross - disc)
        dllrs_dsc                 NUMBER,                                                               -- 30: Discount dollar amount (gross - net)
        dllrs_ppd                 NUMBER,                                                               -- 31: Prompt Pay dollar amount
        pkgs                      NUMBER,                                                               -- 32: Package Qty
        units                     NUMBER,                                                               -- 33: Unit Qty
       -- Customer COT -------------------------------------------------------------------------------------------------------------------------------
        cust_cot_grp_cd           hcrs.prfl_mtrx_wrk_t.cot_grp_cd%TYPE,                                 -- 34: Customer Class of Trade Super Group
       -- Wholesaler COT -----------------------------------------------------------------------------------------------------------------------------
        whls_cot_grp_cd           hcrs.prfl_mtrx_wrk_t.cot_grp_cd%TYPE,                                 -- 35: Wholesaler Class of Trade Super Group
       -- Transaction Type ---------------------------------------------------------------------------------------------------------------------------
       -- Profile Calc Data --------------------------------------------------------------------------------------------------------------------------
       -- Profile Calc Data --------------------------------------------------------------------------------------------------------------------------
       -- Profile Calc Data --------------------------------------------------------------------------------------------------------------------------
       -- Product Units ------------------------------------------------------------------------------------------------------------------------------
       -- Bundling -----------------------------------------------------------------------------------------------------------------------------------
        bndl_prod                 hcrs.prfl_prod_wrk_t.bndl_prod%TYPE,                                  -- 36: Bundle product flag
        bndl_src_sys_ind          hcrs.prfl_prod_calc_comp_def2_wrk_t.bndl_comp_tran_ind%TYPE,          -- 37: Bundle Source System flag
        bndl_comp_tran_ind        hcrs.prfl_prod_calc_comp_def2_wrk_t.bndl_comp_tran_ind%TYPE,          -- 38: Bundle Component Transaction flag
        bndl_comp_nom_ind         hcrs.prfl_prod_calc_comp_def2_wrk_t.bndl_comp_nom_ind%TYPE,           -- 39: Bundle Component Nominal Check flag
        bndl_comp_hhs_ind         hcrs.prfl_prod_calc_comp_def2_wrk_t.bndl_comp_hhs_ind%TYPE,           -- 40: Bundle Component subPHS Check flag
       -- Trans Linking ------------------------------------------------------------------------------------------------------------------------------
       -- Estimations --------------------------------------------------------------------------------------------------------------------------------
        splt_pct_typ              hcrs.prfl_contr_prod_splt_pct_wrk_t.splt_pct_typ%TYPE,                -- 41: Split Percentage Type
        splt_pct_seq_no           hcrs.prfl_contr_prod_splt_pct_wrk_t.splt_pct_seq_no%TYPE,             -- 42: Split Percentage Type Sequence Number
       -- Component Checks ---------------------------------------------------------------------------------------------------------------------------
        chk_contr                 hcrs.prfl_prod_calc_comp_def2_wrk_t.chk_nom%TYPE,                     -- 43: Check for contracted
        chk_phs_pvp_contr         hcrs.prfl_prod_calc_comp_def2_wrk_t.chk_nom%TYPE,                     -- 44: Check for 340B Prime Vendor
        chk_phs_contr             hcrs.prfl_prod_calc_comp_def2_wrk_t.chk_nom%TYPE,                     -- 45: Check for PHS Contract
        chk_fss_contr             hcrs.prfl_prod_calc_comp_def2_wrk_t.chk_nom%TYPE,                     -- 46: Check for FSS Contract
        chk_nom                   hcrs.prfl_prod_calc_comp_def2_wrk_t.chk_nom%TYPE,                     -- 47: Check for Nominal Pricing
        chk_hhs                   hcrs.prfl_prod_calc_comp_def2_wrk_t.chk_hhs%TYPE,                     -- 48: Check for sub-PHS pricing
       -- Units Component ----------------------------------------------------------------------------------------------------------------------------
        units_comp_typ_cd         hcrs.prfl_prod_calc_comp_def2_wrk_t.units_comp_typ_cd%TYPE,           -- 49: Units Component for accumulation
       -- Component Dollars --------------------------------------------------------------------------------------------------------------------------
        comp_dllrs                hcrs.prfl_prod_calc_comp_def2_wrk_t.comp_dllrs%TYPE,                  -- 50: Component Dollars SLS/DSC/PRC
       -- Trans Settings -----------------------------------------------------------------------------------------------------------------------------
        tran_dllrs                hcrs.prfl_prod_calc_comp_def2_wrk_t.tran_dllrs%TYPE,                  -- 51: Accumulate trans dollars (Gross, net..)
        tran_pckgs                hcrs.prfl_prod_calc_comp_def2_wrk_t.tran_pckgs%TYPE,                  -- 52: Accumulate trans packages or units
        tran_ppd                  hcrs.prfl_prod_calc_comp_def2_wrk_t.tran_ppd%TYPE,                    -- 53: Accumulate trans prompt pay
        tran_bndl                 hcrs.prfl_prod_calc_comp_def2_wrk_t.tran_bndl%TYPE,                   -- 54: Accumulate trans bundling adj
       -- Nominal Settings ---------------------------------------------------------------------------------------------------------------------------
        nom_chk_dllrs             hcrs.prfl_prod_calc_comp_def2_wrk_t.nom_chk_dllrs%TYPE,               -- 55: Nominal check dollars (Gross, net..)
        nom_chk_pckgs             hcrs.prfl_prod_calc_comp_def2_wrk_t.nom_chk_pckgs%TYPE,               -- 56: Nominal check packages or units
        nom_chk_ppd               hcrs.prfl_prod_calc_comp_def2_wrk_t.nom_chk_ppd%TYPE,                 -- 57: Nominal check prompt pay as discount
        nom_chk_bndl              hcrs.prfl_prod_calc_comp_def2_wrk_t.nom_chk_bndl%TYPE,                -- 58: Nominal check bundling adj
       -- Sub-PHS Settings ---------------------------------------------------------------------------------------------------------------------------
        hhs_chk_dllrs             hcrs.prfl_prod_calc_comp_def2_wrk_t.hhs_chk_dllrs%TYPE,               -- 59: SubPHS check dollars (Gross, net..)
        hhs_chk_pckgs             hcrs.prfl_prod_calc_comp_def2_wrk_t.hhs_chk_pckgs%TYPE,               -- 60: SubPHS check packages or units
        hhs_chk_ppd               hcrs.prfl_prod_calc_comp_def2_wrk_t.hhs_chk_ppd%TYPE,                 -- 61: SubPHS check prompt pay
        hhs_chk_bndl              hcrs.prfl_prod_calc_comp_def2_wrk_t.hhs_chk_bndl%TYPE,                -- 62: SubPHS check bundling adj
       -- Trans Groupings ----------------------------------------------------------------------------------------------------------------------------
        root_trans_grp            NUMBER,                                                               -- 63: Root Trans Group
        parent_trans_grp          NUMBER,                                                               -- 64: Parent Trans Group
        trans_grp                 NUMBER,                                                               -- 65: Trans Group
        trans_ord                 NUMBER,                                                               -- 66: Trans Order within groups
       -- Constants ----------------------------------------------------------------------------------------------------------------------------------
       -- Marking data -------------------------------------------------------------------------------------------------------------------------------
        mk_dllr_amt               NUMBER,                                                               -- 67: Marked Dollar Amount
        mk_pkg_qty                NUMBER,                                                               -- 68: Marked Package/Unit Quantity
        prc_pnt                   NUMBER,                                                               -- 69: Marked Price Point
        nom_dllr_amt              NUMBER,                                                               -- 70: Nominal Check Dollar Amount
        nom_pkg_qty               NUMBER,                                                               -- 71: Nominal Check Package/Unit Quantity
        hhs_dllr_amt              NUMBER,                                                               -- 72: HHS Check Dollar Amount
        hhs_pkg_qty               NUMBER,                                                               -- 73: HHS Check Package/Unit Quantity
        bndl_cd                   hcrs.prfl_prod_bndl_smry_wrk_t.bndl_cd%TYPE,                          -- 74: Marked Bundle Code (null from csr_main)
        cmt_txt                   hcrs.prfl_prod_bp_pnt_t.cmt_txt%TYPE,                                 -- 75: Marked BP Comments (null from csr_main)
       -- Cursor Row Count ---------------------------------------------------------------------------------------------------------------------------
        csr_cnt                   NUMBER);                                                              -- 76: Cursor Output Record Count

   -- Calculation transaction query refcursor
   TYPE t_calc_trans_ref_csr IS REF CURSOR RETURN t_calc_trans_rec;

   -- Calculation transaction associative array
   TYPE t_calc_trans_tbl IS TABLE OF t_calc_trans_rec INDEX BY BINARY_INTEGER;

   -----------------------------------------------------------------------------
   -- Calculation Ref Cursors
   -----------------------------------------------------------------------------
   FUNCTION f_csr_main
      RETURN t_calc_trans_ref_csr;

   -----------------------------------------------------------------------------
   -- Bundle Insert Statement
   -----------------------------------------------------------------------------
   FUNCTION f_ins_bndl_cp_trns
      (i_load_gtt IN BOOLEAN := FALSE)
      RETURN NUMBER;

END pkg_common_cursors;
/
CREATE OR REPLACE PACKAGE BODY pkg_common_cursors
IS
   cs_src_pkg    CONSTANT hcrs.error_log_t.src_cd%TYPE := 'pkg_common_cursors';

   FUNCTION f_csr_main
      RETURN t_calc_trans_ref_csr
   IS
      /*************************************************************************
      *  Function Name : f_csr_main
      *   Input params : none
      *  Output params : none
      *        Returns : REF CURSOR, calculation transactions
      *   Date Created : 01/15/2018
      *         Author : Joe Kidd
      *    Description : Main calculation transaction query
      *
      *                  NOTE: This procedure should only write to temporary
      *                  tables, so that it can be used during testing/debugging
      *                  in production.  No changes should be made to permanent
      *                  objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Add Wholesaler COT Supergroup
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            GTT column reduction
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_csr_main';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Main calculation transaction query';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error in main calculation transaction query';
      v_csr_main            t_calc_trans_ref_csr;
   BEGIN
      OPEN v_csr_main FOR
         SELECT /*+ f_csr_main
                    QB_NAME( fcm )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                -- Source --------------------------------------------------------------------------------
                -- Customer ------------------------------------------------------------------------------
                z.cust_id,
                z.orig_cust_id,
                z.cust_cls_of_trd_cd,
                -- Root Customer -------------------------------------------------------------------------
                -- Parent Customer -----------------------------------------------------------------------
                -- Product -------------------------------------------------------------------------------
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                -- Component -----------------------------------------------------------------------------
                z.comp_typ_cd,
                z.mark_accum_all_ind,
                z.mark_accum_nom_ind,
                z.mark_accum_hhs_ind,
                z.mark_accum_contr_ind,
                z.mark_accum_fsscontr_ind,
                z.mark_accum_phscontr_ind,
                z.mark_accum_zerodllrs_ind,
                -- Root Identifiers ----------------------------------------------------------------------
                -- Marking Trans Date --------------------------------------------------------------------
                z.trans_dt,
                -- Parent Identifiers --------------------------------------------------------------------
                -- Trans Identifiers ---------------------------------------------------------------------
                z.trans_cls_cd,
                z.source_sys_cde,
                z.assc_invc_no,
                -- Trans IDs -----------------------------------------------------------------------------
                z.root_trans_id,
                z.parent_trans_id,
                z.trans_id,
                z.trans_adj_cd,
                -- Root Lookup IDs -----------------------------------------------------------------------
                -- Parent Lookup IDs ---------------------------------------------------------------------
                z.parent_trans_id_icw_key,
                -- Link Markers --------------------------------------------------------------------------
                -- Related Trans -------------------------------------------------------------------------
                -- Prasco Rebates Link -------------------------------------------------------------------
                -- Trans Flags ---------------------------------------------------------------------------
                -- Sales Exclusion -----------------------------------------------------------------------
                z.sls_excl_ind,
                -- Root Keys/Dates -----------------------------------------------------------------------
                -- Parent Keys/Dates ---------------------------------------------------------------------
                -- Transaction Dates ---------------------------------------------------------------------
                z.earn_bgn_dt,
                z.earn_end_dt,
                -- Root Values ---------------------------------------------------------------------------
                -- Parent Values -------------------------------------------------------------------------
                -- Transaction Values --------------------------------------------------------------------
                -- Component Values ----------------------------------------------------------------------
                z.dllrs_grs,
                z.dllrs_wac,
                z.dllrs_net,
                z.dllrs_dsc,
                z.dllrs_ppd,
                z.pkgs,
                z.units,
                -- Customer COT --------------------------------------------------------------------------
                z.cust_cot_grp_cd,
                -- Wholesaler COT ------------------------------------------------------------------------
                z.whls_cot_grp_cd,
                -- Transaction Type ----------------------------------------------------------------------
                -- Profile Calc Data ---------------------------------------------------------------------
                -- Product Units -------------------------------------------------------------------------
                -- Bundling ------------------------------------------------------------------------------
                z.bndl_prod,
                z.bndl_src_sys_ind,
                z.bndl_comp_tran_ind,
                z.bndl_comp_nom_ind,
                z.bndl_comp_hhs_ind,
                -- Trans Linking -------------------------------------------------------------------------
                -- Estimations ---------------------------------------------------------------------------
                z.splt_pct_typ,
                z.splt_pct_seq_no,
                -- Component Checks ----------------------------------------------------------------------
                z.chk_contr,
                z.chk_phs_pvp_contr,
                z.chk_phs_contr,
                z.chk_fss_contr,
                z.chk_nom,
                z.chk_hhs,
                -- Units Component -----------------------------------------------------------------------
                z.units_comp_typ_cd,
                -- Component Dollars ---------------------------------------------------------------------
                z.comp_dllrs,
                -- Trans Settings ------------------------------------------------------------------------
                z.tran_dllrs,
                z.tran_pckgs,
                z.tran_ppd,
                z.tran_bndl,
                -- Nominal Settings ----------------------------------------------------------------------
                z.nom_chk_dllrs,
                z.nom_chk_pckgs,
                z.nom_chk_ppd,
                z.nom_chk_bndl,
                -- Sub-PHS Settings ----------------------------------------------------------------------
                z.hhs_chk_dllrs,
                z.hhs_chk_pckgs,
                z.hhs_chk_ppd,
                z.hhs_chk_bndl,
                -- Trans Groupings -----------------------------------------------------------------------
                z.root_trans_grp,
                z.parent_trans_grp,
                z.trans_grp,
                z.trans_ord,
                -- Constants -----------------------------------------------------------------------------
                -- Marking data --------------------------------------------------------------------------
                TO_NUMBER( NULL) mk_dllr_amt,
                TO_NUMBER( NULL) mk_pkg_qty,
                TO_NUMBER( NULL) prc_pnt,
                TO_NUMBER( NULL) nom_dllr_amt,
                TO_NUMBER( NULL) nom_pkg_qty,
                TO_NUMBER( NULL) hhs_dllr_amt,
                TO_NUMBER( NULL) hhs_pkg_qty,
                '' bndl_cd,
                '' cmt_txt,
                -- Cursor Row Count ----------------------------------------------------------------------
                z.csr_cnt
           FROM hcrs.calc_csr_main_final_v z
          ORDER BY z.root_trans_grp,
                   z.parent_trans_grp,
                   z.trans_grp,
                   z.trans_ord;
      RETURN v_csr_main;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_common_procedures.p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
      RETURN NULL;
   END f_csr_main;


   FUNCTION f_ins_bndl_cp_trns
      (i_load_gtt IN BOOLEAN := FALSE)
      RETURN NUMBER
   IS
      /*************************************************************************
      *  Function Name : f_ins_bndl_cp_trns
      *   Input params : i_load_gtt - If TRUE, load the GTT from existing
      *                :              permanent audit log. ONLY FOR SUPPORT!!
      *  Output params : None
      *        Returns : SQL%ROWCOUNT, number of rows inserted
      *   Date Created : 04/22/2008
      *         Author : Joe Kidd
      *    Description : Retrieves bundle transaction rows for a customer,
      *                  transaction class, bundle code, and date
      *
      *                  NOTE: Exposed for support testing and research. Support
      *                  should always call without parameters in production.
      *
      *                  Find bundled transactions for a customer, across all
      *                  products, dates, bundled codes, transaction class,
      *                  (where transaction type requires net or discount is for
      *                  a component), and contracts and prices groups.  No units
      *                  are involved, but transactions must have a gross and net
      *                  value.  Only SAP and CARS transactions will be found,
      *                  no manual adjustments.  Snapshot logic is applied.  We
      *                  assume that because we are processing this customer,
      *                  they have already passed any eligiblity and domestic/
      *                  non-domestic restrictions and that their transactions
      *                  will require the net or discount value for a bundled
      *                  component.  However, transaction types will only be
      *                  included when  they are part of a bundled component
      *                  that will require the net or discount value.  All
      *                  transactions will be included without regard to sales
      *                  exclusion status.  The matrix (primary/wholesaler
      *                  method code) for the main product will be used, as
      *                  eligibility has already been determined there.
      *
      *                  The bundled contract price groups must meet the the
      *                  following requirements (numbering continued from
      *                  pkg_common_procedures.p_bndl_trans):
      *                  4.4. The transaction's contract and price group must be
      *                       assigned to the bundle code.
      *                  4.5. The transaction's Earned Date must fall within the
      *                       effective range of the contract price group bundle.
      *                  4.6. The transaction's Earned Date must fall within the
      *                       bundle condition effective period.
      *                  4.7. The transaction's Earned Date must fall within the
      *                       pricing period of the contract price group bundle.
      *                  4.8. The transaction's customer must be in effect on
      *                       the condition based on the transaction's earned date.
      *                  4.9. The customer condtion must be effective during the
      *                       bundle condition effective period.
      *
      *                  The transactions included in bundling must meet the the
      *                  following basic requirements:
      *                  5.1. The transaction's customer must be the same as
      *                       the source transactions.
      *                       (changed)
      *                  5.2. The transaction's NDC must be in effect on the bundle
      *                       code based on the transaction's earned date.
      *                  5.3. The transaction must be a CARS or SAP transaction.
      *                       This implies that no manual adjustments will be
      *                       processed for bundling.
      *                       (changed)
      *                  5.4. The transaction's Sales Cutoff Date must less than or
      *                       equal to the Sales Cutoff Date of the Profile.
      *                  5.5. The transaction must not be archived.
      *                  5.6. The transaction must not be a manual adjustment.
      *                  5.7. The discount or net value of the transaction must
      *                       be needed for a calculation component.
      *                       (new)
      *
      *                  The transactions with which the source transactions are
      *                  bundled for the pricing period must meet the the following
      *                  additional requirements:
      *                  6.1. The transaction's contract and price group must be
      *                       assigned to the bundle code.
      *                  6.2. The transaction's earned date must be within the
      *                       pricing period of the bundle code that applies to
      *                       the source transaction.
      *
      *                  The transactions with which the source transactions are
      *                  bundled for the performance period must meet the the
      *                  following additional requirements:
      *                  7.1. The transaction's contract and price group may be
      *                       any contract and price group.
      *                  7.2. The transaction's earned date must be within the
      *                       performance period for the bundle code that applies
      *                       to the source transaction.
      *
      *                  The resulting bundled relationship must then meet these
      *                  requirements to be used by the main calculation:
      *                  8.1. The pricing period gross dollars must not be
      *                       equal to zero.
      *                  8.2. There must be transactions using an NDC in the main
      *                       calculation in the pricing or performance period.
      *                       Those transactions must occure during the range of
      *                       dates used by the main calculation by the
      *                       paid date and/or earned date as used by the main
      *                       calculation.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  06/16/2008  Joe Kidd      PICC 1927: Use Loop to process transactions
      *                            Use passed dates to determine eligible transactions
      *                            Add Condition parameter
      *  08/22/2008  Joe Kidd      PICC 1961: Remove contract and price group
      *                            limitation from performance period
      *                            Remove FOR loop and replace with single queries
      *  07/22/2009  Joe Kidd      RT 267 - CRQ 43432: Bundling Tuning
      *                            Remove out parameter no longer required
      *                            Add cursor names
      *                            Add index hint to query csr_bndl_cp_trns
      *                            Remove view reference for first_value no
      *                            longer required in Oracle 10g
      *                            Check that one or more NDCs from the current
      *                            calculation were used
      *                            Use Bundle Summary work table
      *  04/26/2010  Joe Kidd      RT 2009-724 - CRQ 46973: Revise Bundling Methodology
      *                            Combine all queries into a single multi-table
      *                            insert to reduce context switches and improve
      *                            data access paths and build all bundles at once
      *                            Discontinue use of global temp table
      *                            Correct linking of credits with a related sale
      *                            Check for pricing period gross dollars
      *                            Check for calc NDCs during the min-max date range
      *  12/01/2010  Joe Kidd      CRQ-931: December 2010 Govt Calculations Release
      *                            Adjust hint on prfl_prod_bndl_smry_wrk_t due
      *                            to index name change
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Restrict transactions by data source (company ID)
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Change refernces to NDC in product work table
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Update for new trans table
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Remove trans type and add cust COT parameter
      *                            Refactor to process all transactions for a customer
      *                            Include SAP transactions
      *                            Correct CARS rebate linking
      *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
      *                            Correct WAC for SAP Adjustments
      *                            Correct Gross Dollars on Reversed Rebates
      *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
      *                            Use global variables for marking NDC columns
      *                            Prioritize Pricing period over Performance Period
      *                            Expand hints on all subqueries
      *                            Don't insert dummy bundle summary rows
      *                            Adjust matrix subquery, add index and hint
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Move query to view, add GTT for transaction
      *                            detail, delete the GTT contents before insert
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Correct hints
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Multi-table insert handles both trans tables
      *                            Remove order by from multitable insert select
      *                            Remove GTT delete by customer
      *                            Correct hints
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_ins_bndl_cp_trns';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Creates Bundle Summary and Detail rows';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error creating Bundle Summary and Detail rows';
      v_cnt                 NUMBER := 0;
   BEGIN
      --------------------------------------------------------------------------
      -- Clear the global temp tables
      --------------------------------------------------------------------------
      IF     NVL( i_load_gtt, TRUE)
         AND NOT pkg_common_procedures.f_is_calc_running()
      THEN
         -- ONLY FOR SUPPORT!!
         --------------------------------------------------------------------------
         -- Insert Bundling Summary working rows from permanent table
         --------------------------------------------------------------------------
         DELETE FROM hcrs.prfl_prod_bndl_smry_wrk_t;
         INSERT INTO hcrs.prfl_prod_bndl_smry_wrk_t
            (bndl_seq_no,
             cust_id,
             trans_cls_cd,
             trans_typ_cd,
             bndl_cd,
             cond_cd,
             prcg_strt_dt,
             prcg_end_dt,
             perf_strt_dt,
             perf_end_dt,
             prcg_trns_cnt,
             prcg_dllrs_grs,
             prcg_dllrs_dsc,
             perf_trns_cnt,
             perf_dllrs_grs,
             perf_dllrs_dsc)
            SELECT /*+ NO_MERGE
                       LEADING( c ppbs )
                       USE_NL( c ppbs )
                       INDEX( ppbs prfl_prod_bndl_smry_ix1 )
                       DYNAMIC_SAMPLING( 0 )
                   */
                   ppbs.bndl_seq_no,
                   ppbs.cust_id,
                   ppbs.trans_cls_cd,
                   ppbs.trans_typ_cd,
                   ppbs.bndl_cd,
                   ppbs.cond_cd,
                   ppbs.prcg_strt_dt,
                   ppbs.prcg_end_dt,
                   ppbs.perf_strt_dt,
                   ppbs.perf_end_dt,
                   ppbs.prcg_trns_cnt,
                   ppbs.prcg_dllrs_grs,
                   ppbs.prcg_dllrs_dsc,
                   ppbs.perf_trns_cnt,
                   ppbs.perf_dllrs_grs,
                   ppbs.perf_dllrs_dsc
              FROM TABLE( hcrs.pkg_common_procedures.f_get_bndl_cust( pkg_constants.cs_cond_none_cd)) c,
                   hcrs.prfl_prod_bndl_smry_t ppbs
             WHERE c.prfl_id = ppbs.prfl_id
               AND c.co_id = ppbs.co_id
               AND c.ndc_lbl = ppbs.ndc_lbl
               AND c.ndc_prod = ppbs.ndc_prod
               AND c.ndc_pckg = ppbs.ndc_pckg
               AND c.calc_typ_cd = ppbs.calc_typ_cd;
         v_cnt := v_cnt + SQL%ROWCOUNT;
         --------------------------------------------------------------------------
         -- Insert Bundling Detail working rows from permanent table
         --------------------------------------------------------------------------
         DELETE FROM hcrs.prfl_prod_bndl_cp_trns_wrk_t;
         INSERT INTO hcrs.prfl_prod_bndl_cp_trns_wrk_t
            (trans_id,
             bndl_seq_no,
             bndl_cd,
             dllrs_grs,
             dllrs_dsc)
            SELECT /*+ NO_MERGE
                       LEADING( c ppbsw ppbct )
                       USE_NL( c ppbsw ppbct )
                       FULL( ppbsw )
                       INDEX( ppbct prfl_prod_bndl_cp_trns_ix1 )
                       DYNAMIC_SAMPLING( 0 )
                   */
                   ppbct.trans_id,
                   ppbsw.bndl_seq_no,
                   ppbsw.bndl_cd,
                   DECODE( ppbct.prcg_trns_cnt, 1, ppbct.prcg_dllrs_grs, ppbct.perf_dllrs_grs) dllrs_grs,
                   DECODE( ppbct.prcg_trns_cnt, 1, ppbct.prcg_dllrs_dsc, ppbct.perf_dllrs_dsc) dllrs_dsc
              FROM TABLE( hcrs.pkg_common_procedures.f_get_bndl_cust( pkg_constants.cs_cond_none_cd)) c,
                   hcrs.prfl_prod_bndl_smry_wrk_t ppbsw,
                   hcrs.prfl_prod_bndl_cp_trns_t ppbct
             WHERE c.prfl_id = ppbct.prfl_id
               AND c.co_id = ppbct.co_id
               AND c.ndc_lbl = ppbct.ndc_lbl
               AND c.ndc_prod = ppbct.ndc_prod
               AND c.ndc_pckg = ppbct.ndc_pckg
               AND c.calc_typ_cd = ppbct.calc_typ_cd
               AND ppbsw.bndl_seq_no = ppbct.bndl_seq_no;
         v_cnt := v_cnt + SQL%ROWCOUNT;
      ELSE
         --------------------------------------------------------------------------
         -- Insert Bundling Summary and Detail working rows, permanent Detail Rows
         --------------------------------------------------------------------------
         INSERT /*+ f_ins_bndl_cp_trns */
                ALL
             -- Only write to the permanent detail table if the calculation is running.
             -- This allows debugging of data in production without writes to the permanent tables.
           WHEN tbl = 2
            AND calc_running = flag_yes
           THEN INTO hcrs.prfl_prod_bndl_cp_trns_t
                (prfl_id,
                 co_id,
                 ndc_lbl,
                 ndc_prod,
                 ndc_pckg,
                 calc_typ_cd,
                 bndl_seq_no,
                 trans_id,
                 trans_dt,
                 prcg_trns_cnt,
                 prcg_dllrs_grs,
                 prcg_dllrs_dsc,
                 prcg_dsc_pct,
                 perf_trns_cnt,
                 perf_dllrs_grs,
                 perf_dllrs_dsc,
                 perf_dsc_pct,
                 trans_adj_cd,
                 root_trans_id,
                 parent_trans_id)
                VALUES
                (prfl_id,
                 co_id,
                 ndc_lbl,
                 ndc_prod,
                 ndc_pckg,
                 calc_typ_cd,
                 bndl_seq_no,
                 trans_id,
                 trans_dt,
                 prcg_trns_cnt,
                 prcg_dllrs_grs,
                 prcg_dllrs_dsc,
                 prcg_dsc_pct,
                 perf_trns_cnt,
                 perf_dllrs_grs,
                 perf_dllrs_dsc,
                 perf_dsc_pct,
                 trans_adj_cd,
                 root_trans_id,
                 parent_trans_id)
             -- Always write to the detail GTT table
           WHEN tbl = 2
           THEN INTO hcrs.prfl_prod_bndl_cp_trns_wrk_t
                (trans_id,
                 bndl_seq_no,
                 bndl_cd,
                 dllrs_grs,
                 dllrs_dsc)
                VALUES
                (trans_id,
                 bndl_seq_no,
                 bndl_cd,
                 dllrs_grs,
                 dllrs_dsc)
             -- Always write to the summary GTT table
           WHEN tbl = 1
           THEN INTO hcrs.prfl_prod_bndl_smry_wrk_t
                (cust_id,
                 trans_cls_cd,
                 trans_typ_cd,
                 bndl_cd,
                 cond_cd,
                 prcg_strt_dt,
                 prcg_end_dt,
                 perf_strt_dt,
                 perf_end_dt,
                 bndl_seq_no,
                 prcg_trns_cnt,
                 prcg_dllrs_grs,
                 prcg_dllrs_dsc,
                 perf_trns_cnt,
                 perf_dllrs_grs,
                 perf_dllrs_dsc)
                VALUES
                (cust_id,
                 trans_cls_cd,
                 trans_typ_cd,
                 bndl_cd,
                 cond_cd,
                 prcg_strt_dt,
                 prcg_end_dt,
                 perf_strt_dt,
                 perf_end_dt,
                 bndl_seq_no,
                 prcg_trns_cnt,
                 prcg_dllrs_grs,
                 prcg_dllrs_dsc,
                 perf_trns_cnt,
                 perf_dllrs_grs,
                 perf_dllrs_dsc)
            SELECT /*+ NO_MERGE
                       DYNAMIC_SAMPLING( 0 )
                   */
                   z.tbl,
                   z.prfl_id,
                   z.co_id,
                   z.ndc_lbl,
                   z.ndc_prod,
                   z.ndc_pckg,
                   z.calc_typ_cd,
                   z.cust_id,
                   z.trans_cls_cd,
                   z.trans_typ_cd,
                   z.bndl_cd,
                   z.cond_cd,
                   z.prcg_strt_dt,
                   z.prcg_end_dt,
                   z.perf_strt_dt,
                   z.perf_end_dt,
                   z.bndl_seq_no,
                   z.trans_dt,
                   z.trans_id,
                   z.root_trans_id,
                   z.parent_trans_id,
                   z.trans_adj_cd,
                   z.prcg_trns_cnt,
                   z.prcg_dllrs_grs,
                   z.prcg_dllrs_dsc,
                   z.prcg_dsc_pct,
                   z.perf_trns_cnt,
                   z.perf_dllrs_grs,
                   z.perf_dllrs_dsc,
                   z.perf_dsc_pct,
                   z.dllrs_grs,
                   z.dllrs_dsc,
                   z.calc_running,
                   z.flag_yes
              FROM hcrs.calc_csr_bndl_cnfg_v z;
         v_cnt := v_cnt + SQL%ROWCOUNT;
      END IF;
      RETURN v_cnt;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_common_procedures.p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
      RETURN 0;
   END f_ins_bndl_cp_trns;

END pkg_common_cursors;
/
