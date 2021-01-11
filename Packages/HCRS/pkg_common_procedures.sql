CREATE OR REPLACE PACKAGE pkg_common_procedures
AS
   /****************************************************************************
   * Package Name : pkg_common_procedures
   * Date Created : 09/20/2000
   *       Author : Venkata Darabala
   *  Description : Calculation Common Procedures
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  02/04/2004  Joe Kidd      PICC 1167: Medicare ASP changes
   *  05/19/2004  Joe Kidd      PICC 1220: Medicare ASP changes 2004Q2
   *  06/01/2004  Joe Kidd      PICC 1235: Validate the Matrix for the
   *                            running profile and calc
   *  07/14/2004  M. Gedzior    PICC 1264: In the ICW Key related credits logic
   *                            added AMP calls similar to NFAMP section
   *  08/09/2004  Joe Kidd      PICC 1253: Add Matrix begin/end dates
   *  08/09/2004  Joe Kidd      PICC 1253: Add trans_dt to marking tables
   *  09/10/2004  Joe Kidd      PICC 1253: Delete marking table records in
   *                            groups by the commit point
   *  10/26/2004  Joe Kidd      PICC 1311: Only resubmit calculations
   *  10/28/2004  Joe Kidd      PICC 1316: Force Commit after calculation
   *                            has been deleted
   *  11/01/2004  Joe Kidd      PICC 1327: Calc Cursor Tuning
   *                            Add p_calc_log to log calc event timings
   *                            Add calc start and delete event timings
   *  02/01/2005  Joe Kidd      PICC 1372, 1373, 1374:
   *                            Add calc_mthd_cd to rec_param
   *                            Get and register calc_mthd_cd
   *                            Add parameter to p_calc_log to skip log writing and
   *                            Register actions with DBMS_APPLICATION_INFO
   *                            Set Annual date ranges using table
   *                            Added more common init actions to p_common_initialize
   *                            Add p_mark_record for BP tables
   *                            Restructure p_trans_rollup to simplify logic
   *                            Restructure p_trans_rollup to use bulk collect
   *                            p_mark_record uses bulk binds
   *                            Add p_mark_record_flush to flush mark binds
   *                            Added trans_typ_ord field to bulk collect
   *                            Use new calc cursor names
   *  05/05/2005  Joe Kidd      PICC 1406:
   *                            Code Cleanup and Naming Conventions
   *                            p_create_pl102_tbl: Treat Annual range and current
   *                            period range seperately
   *  08/04/2005  Joe Kidd      PICC 1446: Add variables for QNEDD/ANEDD
   *  11/15/2005  Joe Kidd      PICC 1487: Add variable for AEDUP
   *  03/20/2006  Joe Kidd      PICC 1536:
   *                            p_assign_rbs: Fix bug in cleanup of abandoned
   *                            rollback segments
   *  06/12/2006  Joe Kidd      PICC 1557:
   *                            Add new types for Transaction Amounts
   *                            Add new fields for Transaction Amounts to marking records
   *                            p_get_product_rollup: Apply naming conventions
   *                            p_create_pl102_tbl: Apply naming conventions
   *                            p_mark_record: (all three)
   *                            Add new fields for Transaction Amounts
   *                            p_trans_rollup_loop:
   *                            Change nominal amount processing
   *                            Don't accumulate nominal amount adjustments
   *                            for Rebate/Fee and Related Credit lookups
   *                            p_mark_record_flush:
   *                            Add new fields for Transaction Amounts
   *  12/13/2006  Joe Kidd      PICC 1680:
   *                            New:
   *                              rec_comp
   *                              tbl_comp
   *                              t_comp_trans_def_rec
   *                              t_comp_trans_def_tbl
   *                              p_comp_tbl_to_rec
   *                              p_save_trans_comps
   *                              p_mark_record
   *                              p_accum_trans
   *                              p_prcss_trans
   *                              p_trans_rollup_loop2
   *                              p_get_calc_trans
   *                            rec_calc: Add new components, remove unused components, reorganized
   *                            rec_param: Add values now retrieved in p_common_initialize
   *                            p_raise_errors
   *                              Trim Error Msg and Comments
   *                            p_calc_delete:
   *                              Add status messages
   *                            p_common_initialize:
   *                              Add parameters: io_comp_rec, io_comp_def_tbl, i_dec_pscn_var_cd
   *                              Remove io_cur_product_tbl parameter
   *                              Clear passed records
   *                              Add co_id registration
   *                              Set Annual date ranges using calc method
   *                              Set Annual Offset dates
   *                              Set Cash Discount Percent
   *                              Set Decimal Rounding Prescision
   *                              Set Nominal Threshold Percentage
   *                              Build component transaction definition table
   *                            p_create_pl102_tbl
   *                              Changed PL 102 constant due to constants cleanup
   *                            p_trans_rollup_loop:
   *                              Pass Prompt Pay Discount to calc
   *                              Add fields to v_calc_rec
   *                              Perform SAP adjustment lookup recursively
   *                              Correct trans_adj_cd in lookups
   *                              Remove AMP specific calls
   *                              Prompt Pay cleanup only applies to directs
   *  02/15/2007  Joe Kidd      PICC 1706:
   *                            Removed all references to pkg_common_procedures
   *                            for objects in pkg_common_procedures
   *                            New:
   *                              t_price_rec, t_price_tbl
   *                              p_create_amp_nd_tbl
   *                              p_get_dllr_pkgs
   *                            Removed:
   *                              tp_cot_rec, t_tp_cot_tbl
   *                              cot_hhs, t_cot_hhs_tbl
   *                              rec_pl102, tbl_pl102
   *                              t_rec_amp_nd, t_tbl_amp_nd
   *                              p_reg_prim_whls_mthd_cd
   *                              p_get_sales_offset_period
   *                              p_create_tp_cot_table
   *                              p_create_cot_hhs_table
   *                              p_mark_record (for AMP/NFAMP/ASP)
   *                            rec_calc: Add new components
   *                            rec_param: Add values now retrieved in p_common_initialize
   *                            t_comp_trans_def_rec: Add and rename fields
   *                            p_raise_errors:
   *                              Replace literals with constants
   *                            p_create_product_table:
   *                              Replace literals with constants
   *                              Remove from package specification
   *                              Get earliest market entry date
   *                            p_get_product_rollup:
   *                              Remove from package specification
   *                              Get earliest market entry date
   *                              Added io_param_rec parameter
   *                            p_calc_delete:
   *                              Replace literals with constants
   *                            p_update_interim_table:
   *                              Replace literals with constants
   *                              Only save components when marking is enabled
   *                              Add debugging information to error message
   *                            p_common_initialize:
   *                              Move Matrix validation before calc delete
   *                              Set Profile Months
   *                              Extend component transaction definition table
   *                              Build PL 102 price table if needed
   *                            p_create_pl102_tbl:
   *                              Use pkg_common_functions.f_get_price instead
   *                              Add Annual Offset checking
   *                              New parameter names, naming conventions
   *                              Fix logic error that omitted quarters
   *                            p_trans_rollup_loop:
   *                              Remove ASP specific calls
   *                              Remove NFAMP specific calls
   *                            p_mark_record:
   *                              Allow override of Component and Dollar/Unit values
   *                              Don't set nominal values if no nominal threshold value
   *                            p_accum_trans:
   *                              Add Nominal checking logic
   *                              Add HHS violation checking logic
   *                              Add Accumulation and Marking logic
   *                            p_prcss_trans:
   *                              Remove extraneous code
   *                            p_get_calc_trans:
   *                              Some variable names have changed
   *                              Add i_nd_tbl parameter for Nominal processing
   *                              Add i_pl102_tbl parameter for PL 102 processing
   *                              Add i_step parameter to log calc step
   *  04/17/2007  Joe Kidd      PICC 1743:
   *                            p_update_interim_table:
   *                              Overloaded
   *                            p_insert_trnsmsn_price:
   *                              Moved from pkg_fe_pricing
   *                              Update first, insert if update fails
   *                              No preliminary profiles
   *                              Only calculations that use prod_trnsmsn_t
   *                            p_ins_bp_row:
   *                              Moved from pkg_fe_pricing
   *                              No global variables
   *                              Use p_update_interim_table
   *  05/18/2007  Joe Kidd      PICC 1769:
   *                            Fix incorrect year in previous change comments
   *                            Removed:
   *                              p_mark_record (for BP)
   *                              p_trans_rollup_loop (old version)
   *                            rec_comp: add comp_dllrs
   *                            rec_param: add drug category code
   *                            p_get_product_rollup:
   *                              Set default drug category code
   *                            p_ins_bp_rows
   *                              Call p_insert_trnsmsn_price above
   *                            p_common_initialize:
   *                              Set session_cached_cursors to 50 to reduce library cache latches
   *                              Don't allow calc to run if no products found
   *                              Move Calc Delete to end after configuration
   *                              Change Invalid Matrix error code and message
   *                              Change Error Numbers and Messages for thrown errors
   *                            p_create_amp_nd_tbl:
   *                              Allow preliminary profiles to retrieve preliminary AMPs
   *                            p_calc_log:
   *                              Removed Select from dual
   *                            p_comp_tbl_to_rec:
   *                              Only process non-price point components
   *                              Save Annual/Quarterly Nominal Dollars/Units
   *                              Throw error if component isn't handled
   *                            p_save_trans_comps:
   *                              Only process non-price point components
   *                              Save Annual/Quarterly Nominal Dollars/Units
   *                              Throw error if component isn't handled
   *                            p_ins_price_pnt:
   *                              Moved from pkg_medicaid.p_bp_insert
   *                              Add i_bp_ind to set price as BP
   *                            p_mark_record:
   *                              Add i_dllrs and i_units for entire transaction amounts
   *                              Add price point logic for BP processing
   *                            p_accum_trans:
   *                              Only accum component values for Sales/Discount components
   *                              Adjust Nominal check logic to always retrieve nominal threshold
   *                            p_trans_rollup_loop:
   *                              Renamed from p_trans_rollup_loop2
   *                              Removed unneeded fields
   *                              Add lgcy_trans_line_no types and fields
   *                              Rebate/Fee Rollup Accumulation
   *                            p_get_calc_trans:
   *                              Add comp_dllrs to component table
   *                              Truncate and populate matrix work table
   *  10/01/2007  Joe Kidd      PICC 1808:
   *                            t_calc_comp_rec: Renamed from rec_calc
   *                            t_calc_param_rec:
   *                               Renamed from rec_param
   *                               remove unused fields
   *                               add new fields
   *                            t_product_rec: renamed from product_table
   *                            t_product_ref: renamed from rec_type
   *                            Removed: p_create_product_table
   *                            p_get_product_rollup:
   *                              Get first unit per package value
   *                              Get first pricing method value
   *                              Get NDC count
   *                              Removed io_cur_prod_tbl, io_related_prod_tbl parameters
   *                              Moved p_create_product_table ref cursors here
   *                              Moved explicit cursor to FOR loop
   *                            p_update_interim_table:
   *                              Component is now required parameter
   *                            p_common_initialize:
   *                              Removed io_rollup_product_tbl parameter
   *                              Call altered p_get_product_rollup
   *                              Removed uneeded variables
   *                              Populate 30 Day and First Full Qtr End Dates
   *                            p_create_amp_nd_tbl
   *                              Pass units per package to convert to packages
   *                              Use new pkg_common_functions.f_get_prod_comp
   *                              Allow Monthly AMP to fallback to Quarterly AMP
   *                            p_get_calc_trans:
   *                              Remove i_pl102_tbl parameter
   *                              Only process transactions if components are defined
   *                              Include Trans Type Group Processing Order in temp matrix
   *  11/30/2007  Joe Kidd      PICC 1810:
   *                            t_calc_comp_rec: Add Competitive Acquisition Program components
   *                            t_rec_comp: renamed from rec_comp, add unit component cd
   *                            t_tbl_comp: renamed from tbl_comp
   *                            t_comp_trans_def_rec: add unit component cd
   *                            Removed: p_save_trans_comps
   *                            p_common_initialize:
   *                              Add unit component cd to component list
   *                            p_comp_tbl_to_rec:
   *                              Save Component Values here instead
   *                              Add processing for CAP components
   *                            p_get_calc_trans:
   *                              Add unit component cd to component list
   *                              Remove call to p_save_trans_comps
   *                              Restore marking records settings
   *  11/30/2007  Joe Kidd      PICC 1847:
   *                            t_calc_comp_rec: Add Prompt Pay Adjustment Pct
   *                            t_calc_param_rec:
   *                              Add Termination Date and Liability End Date
   *                            t_related_prod_rec, t_product_rec:
   *                              Add Termination Date
   *                            p_get_product_rollup:
   *                              Get latest Termination Date and Liability End Date
   *                            p_common_initialize:
   *                              Retrieve Prompt Pay Adjustment Pct
   *  01/18/2007  Joe Kidd      PICC 1867:
   *                            p_get_product_rollup:
   *                              Highest Termination Date does not respect
   *                              non-terminated packages
   *  01/15/2008  Joe Kidd      PICC 1864:
   *                            p_ins_price_pnt: Allow comment to be passed
   *  02/12/2008  Joe Kidd      PICC 1807:
   *                            p_insert_trnsmsn_price:
   *                              Set DRA Baseline Flag
   *                              DRA Baseline does not require PUR calc
   *  12/05/2007  Joe Kidd      PICC 1763:
   *                            New: t_contr_prod_splt_pct_rec,
   *                              t_contr_prod_splt_pct_tbl, t_splt_pct_typ,
   *                              t_splt_pct_seq_no
   *                            p_mk_prod_wrk_t, p_mk_mtrx_wrk_t, p_splt_trns
   *                            Renamed t_rec_comp to t_comp_rec, t_tbl_comp to t_comp_tbl
   *                            Removed:
   *                              t_related_prod_rec, t_related_prod_tbl, t_product_rec,
   *                              t_product_ref
   *                            t_calc_param_rec: Added Lookup cursor flags
   *                            t_mark_rec: Added split percentage type,
   *                              split percentage sequence number
   *                            p_get_product_rollup:
   *                              Removed date parameters
   *                              Get product data from the product work table
   *                            p_common_initialize:
   *                              Set Lookup cursor flags
   *                              Change exception IF..END IFs to only raise exception
   *                              Call p_mk_prod_wrk_t to build the product work table
   *                              Call p_mk_mtrx_wrk_t to build the matrix work table
   *                              Call p_mk_splt_pct_wrk_t to build the Split Percents list
   *                            p_mark_record_flush:
   *                              Move v_null_mark_rec from body to this function
   *                              Added split percentage type, split percentage
   *                              sequence number
   *                            p_mark_record: Added split percentage type
   *                            p_trans_rollup_loop:
   *                              Added transaction type, split percentage type,
   *                              split percentage sequence number
   *                              Obey Lookup cursor flags
   *                              Change Lookup queries into static cursors
   *                              Call p_splt_trns instead of p_prcss_trans to
   *                              apply split percentages
   *                            p_get_calc_trans:
   *                              Remove the build of the matrix work table
   *                              Remove the ndc from the calc cursor calls
   *  04/22/2008  Joe Kidd      PICC 1865:
   *                            New: t_bndl_cd, t_bndl_seq_no,
   *                              f_mk_bndl_dts, f_sv_bndl_dts, p_bndl_trans
   *                            t_calc_param_rec:
   *                              Add Bundle Use flags, Bundle Sequence Number,
   *                              Add marking NDC fields
   *                            t_mark_rec:
   *                              Added bundle code and bundle sequence number
   *                            p_get_product_rollup:
   *                              Populate marking NDC fields
   *                            p_calc_delete:
   *                              Clear Bundle tables
   *                              If family level, don't loop for each NDC
   *                              If package level, don't clear family tables
   *                              Clear BP trans by price point, NDC fails for rollups
   *                            p_common_initialize:
   *                              Set Bundle Use flags
   *                              Call f_mk_bndl_dts to build the bundle dates work table
   *                              Call f_sv_bndl_dts to save the bundle dates work table
   *                            p_get_calc_trans:
   *                               Add call to bundling cp summary function
   *  06/16/2008  Joe Kidd      PICC 1927:
   *                            f_mk_bndl_dts:
   *                              Revise loading of the following working tables:
   *                              Bundled Products, Price Group Bundle Dates
   *                              Load new working tables: Price Group Bundles,
   *                              Customer Conditions, Bundle Price Groups
   *                            f_sv_bndl_dts:
   *                              Add Condition fields
   *                            p_calc_delete:
   *                              Remove Bundle CPG Summary table
   *                              Increase commit point 10 times for deletes
   *                            p_common_initialize:
   *                              Commit after bundle work tables
   *                            p_bndl_trans:
   *                              Main transaction must have a non-zero gross
   *                              dollar amount
   *                              Check if component will use net or discount
   *                              dollars before check for bundle
   *                              Revise for Bundle Conditions
   *                            p_get_calc_trans:
   *                              Remove call to bundling cp summary function
   *  08/22/2008  Joe Kidd      PICC 1961:
   *                            t_calc_param_rec:
   *                              Add Product Eligibility dates
   *                              Add Max Bundle Pricing End Date
   *                            p_mk_prod_wrk_t:
   *                              Add Bundle flag and Primary/Wholesaler method
   *                              parameters
   *                              Add bundled products to the list of products
   *                              Delete instead of Truncate
   *                            p_mk_mtrx_wrk_t:
   *                              Delete instead of Truncate
   *                            f_mk_bndl_dts:
   *                              Delete instead of Truncate
   *                              Add Profile Bundle Conditions working table
   *                              Delete Customer Conditions and Bundle Price
   *                              Groups working tables before loading
   *                              Only run queries if previous queries returned results
   *                            p_get_product_rollup:
   *                              Only non-bundled product records
   *                            p_calc_delete:
   *                              Correct Profile Product Bundle Contract Price
   *                              Group Transactions abbreviation
   *                            p_common_initialize:
   *                              Simplify First Full Qtr End Date
   *                              Get Max Bundle Pricing Period End Date
   *                              Product Eligibility dates now on param record
   *                              Add bundled products to the list of products
   *                            p_accum_trans, p_prcss_trans, p_splt_trns:
   *                              Add switch to skip this procedure
   *                            p_bndl_trans:
   *                              Add parameter for bundling mode
   *                              Create two bundling modes:
   *                              Mode CFG ids by bundle config, calculates
   *                              bundle percentage, creates bundle audit trail
   *                              Mode TRN ids by the audit trail retrieves and
   *                              applies bundle percentage
   *                            p_trans_rollup_loop:
   *                              Add parameter for bundling mode
   *                            p_get_calc_trans:
   *                              Add multiple query passes for the two
   *                              bundling modes
   *  08/07/2008  Joe Kidd      PICC 1950:
   *                            t_calc_param_rec: Add SAP Adj control fields
   *                            p_common_initialize: Retreive SAP Adj control fields
   *                            p_accum_trans:
   *                              Check CARS credits that may already be linked
   *                              to a sale
   *                              Check SAP adjustments that may have already
   *                              been linked to an original
   *                            p_trans_rollup_loop:
   *                              Add assc_invc_dt
   *                              Add new SAP adjustment logic
   *  12/01/2008  Joe Kidd      PICC 2009: GPCS Server Migration
   *                            p_assign_rbs, p_release_rbs, p_commit
   *                              Disable rollback mgmt for 10g
   *                            p_common_initialize
   *                              Remove session commands
   *  04/02/2009  Joe Kidd      PICC 2027:
   *                            f_mk_bndl_dts:
   *                               Adjust Pricing/Perfomance Start/End
   *                               Dates for Bundle Addl Text Day Offsets
   *  05/06/2009  Joe Kidd      PICC 2051:
   *                            New: p_init_calc
   *                            Hide: p_mk_prod_wrk_t, p_mk_mtrx_wrk_t,
   *                              p_mk_splt_pct_wrk_t, f_mk_bndl_dtsm
   *                            Deleted: p_get_processing_period, p_assign_rbs,
   *                              p_release_rbs
   *                            t_calc_param_rec: Add Check HHS flag
   *                            p_update_prfl_status, p_raise_errors,
   *                            p_reg_job_name:
   *                              Remove rollback segment mgmt
   *                            p_common_initialize:
   *                              Split out initialization to p_init_calc
   *                              Use param record Check HHS flag
   *                            p_trans_rollup_loop:
   *                              Add linking of X360 lines and adjs
   *  06/22/2009  Joe Kidd      RT 458 - CRQ 29045 - IS-000000000355
   *                            New:
   *                              t_trns_amt_rec, t_trns_amt_tbl, t_cmt_txt,
   *                              p_get_trans_vals, p_mark_nominal
   *                            t_calc_comp_rec: Added Maximum DPA Percent
   *                            t_mark_rec: added cmt_txt field
   *                            p_init_calc:
   *                              Retrieve new Max DPA profile variable
   *                            p_mark_record:
   *                              Added Price Point, comment, component amounts,
   *                              and nominal amounts parameters
   *                              Removed nominal threshold, and component
   *                              configuration parameters
   *                              Use passed price point over dollars and units
   *                              Allow generated comments to be added to price point
   *                              Remove f_get_trans_dllrs and f_get_trans_pkgs calls
   *                            p_accum_trans:
   *                              Replace f_get_trans_dllrs and f_get_trans_pkgs
   *                              call pairs with a single p_get_trans_vals call
   *                              Get component values first
   *                              Restructure Nominal/HHS and transaction evaluation
   *                              Incorporated f_det_hhs_component and f_chk_pkg_price
   *                            p_trans_rollup_loop:
   *                              Rename internal proc p_accum_trans to p_add_trans
   *                              Add calc log entry for first record fetch
   *  07/22/2009  Joe Kidd      RT 267 - CRQ 43432: Bundling Tuning
   *                            t_tt_bndl_tbl: Use VARCHAR2 index
   *                            p_mk_prod_wrk_t:
   *                              Get count of additional bundled products
   *                            f_mk_bndl_dts:
   *                              Only load CARS customers for NONE condition
   *                            p_calc_delete:
   *                              Add Company ID to Bundling deletes
   *                            p_bndl_trans:
   *                              Remove seperate Main Transaction in Bundle
   *                              check in both passes
   *                              Remove retrieval of bundle pct in first pass
   *                              Tune csr_bndl_trns_loop query
   *                              Use new VARCHAR2 index for trans type list
   *                              Use count of additional bundled products
   *                              Use Bundle Summary work table
   *                            p_get_calc_trans:
   *                              Limit cursor calls by CARS Source System Code
   *                              during bundling first pass
   *                              Save Bundle Summary rows
   *  04/01/2010  Joe Kidd      RT 372 - CRQ 43435 - IS-000000000018
   *                            t_calc_param_rec, t_comp_trans_def_rec:
   *                              Add Lookup Prasco Rebate/Fee flag
   *                            p_init_calc:
   *                              Add Lookup Prasco Rebate/Fee flag
   *                            p_accum_trans:
   *                              Check Prasco Rebates/Fees that may have already
   *                              been linked to an original
   *                            p_trans_rollup_loop:
   *                              Add Prasco rollup and Rebate/Fee processing
   *  04/26/2010  Joe Kidd      RT 2009-724 - CRQ 46973: Revise Bundling Methodology
   *                            f_mk_bndl_dts:
   *                              Collapse contiguous customer condition rows
   *                              Determine if customer conditions are used
   *                            p_init_calc:
   *                              Get minimum and maximum dates used by calc
   *                            p_bndl_trans:
   *                              Correct customer condition logic
   *                              Revise bundle application logic
   *                            p_trans_rollup_loop:
   *                              Lookup Prasco Rebate/Fee only once
   *                              Rollup Prasco Chargebacks/Rebate/Fee by line number
   *  07/19/2010  Joe Kidd      CRQ-48638: Correct Bundling Sign Issue
   *                            p_bndl_trans:
   *                              Correct Bundling Application Sign Issue
   *  10/01/2010  Joe Kidd      CRQ-53357: October 2010 Govt Calculations Release
   *                            New: p_update_prod_calc
   *                            p_mk_prod_wrk_t:
   *                              Use new profile calculation product tables
   *                            p_calc_delete:
   *                              Use new views
   *                            p_init_calc:
   *                              Update new profile calculation product tables
   *                              Use new views
   *                              Remove commented 8.1.7.4 queries
   *  12/01/2010  Joe Kidd      CRQ-931: December 2010 Govt Calculations Release
   *                            t_calc_param_rec,
   *                              Add Commercial Units/Pckg
   *                            p_mk_prod_wrk_t, p_get_product_rollup:
   *                              Add Commercial Units/Pckg
   *                            p_init_calc:
   *                              Validate Medicaid Units per package and
   *                              Commercial Units per package
   *                            p_calc_log:
   *                              Add longops for calc monitoring
   *                            p_bndl_trans:
   *                              Run config and apply on each call
   *                              Remove Bundle mode parameter no longer needed
   *                              csr_bndl_trns_loop should use prfl_prod_bndl_smry_wrk_t
   *                              Add hints to csr_bndl_trns_loop for performance
   *                            p_trans_rollup_loop:
   *                              Add longops for to calc log calls
   *                              Remove Bundle mode parameter no longer needed
   *                            p_get_calc_trans:
   *                              Remove bundling passes no longer needed
   *                              Remove source system code filtering
   *  01/28/2011  Joe Kidd      CRQ-1222: Bundling BP Linking issue
   *                            p_bndl_trans:
   *                              Check all transactions for CARS Source System
   *                              Check earned/paid date for all transactions
   *                            p_trans_rollup_loop:
   *                              Removed earnd_dt from cursor output
   *  01/28/2011  Joe Kidd      CRQ-1412: Winthrop Chargeback-Rebate linking
   *                            p_trans_rollup_loop:
   *                              ICW_KEY Rebate must be on same contract as sale
   *  02/10/2011  Joe Kidd      CRQ-1471: Fix Company Product Association Calc Error
   *                            p_calc_delete, p_init_calc:
   *                              Add profile to f_get_prod_company_id call
   *  04/01/2011  Joe Kidd      CRQ-3921: Linking of CARS chargebacks
   *                            New: p_get_profile_variable, p_push_src, p_pop_src
   *                            p_raise_errors
   *                              Process error call stack if populated
   *                            p_mk_prod_wrk_t
   *                              Remove error logging and use error call stack
   *                              to allow init_calc use for debugging in prod
   *                              Remove additional bundle products count
   *                            p_mk_mtrx_wrk_t, p_mk_splt_pct_wrk_t,
   *                            f_mk_bndl_dts, p_get_product_rollup,
   *                              Remove error logging and use error call stack
   *                              to allow init_calc use for debugging in prod
   *                            p_init_calc
   *                              Added company id and debug mode parameters
   *                              Remove update of Profile Calc Product Tables
   *                              Remove matrix validation and other error checks
   *                              Use new profile variable procedure above
   *                              Remove all commits and permanent writes
   *                              Remove error logging and use error call stack
   *                              to allow init_calc use for debugging in prod
   *                            p_common_initialize
   *                              Add company id retrival
   *                              Add update of Profile Calc Product Tables
   *                              Add matrix validation and other error checks
   *                              Update init calc procedure call
   *                            p_trans_rollup_loop
   *                              Add and use root lgcy trans no during linking
   *                              Reorder cursor fields
   *  12/13/2011  Joe Kidd      CRQ-10134: Lovenox Omnicare Calcs runnning slow
   *                            p_bndl_trans:
   *                              Add hints to csr_bndl_trns_loop query
   *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
   *                            NEW: p_set_calc_shutdown, f_chk_trans_comp
   *                            t_calc_comp_rec
   *                              Add Genzyme Calculation components
   *                              Add Raw Cash Discount and Raw Max DPA percentages
   *                            t_comp_trans_def_rec
   *                              Add domestic/territory fields and remove
   *                              lookup fields.
   *                            p_update_prod_calc
   *                              Use calc setting to enforce PPACA indicator
   *                            f_mk_bndl_dts
   *                              Remove unneeded bundling condition checks
   *                            p_calc_delete
   *                              Use pkg_utils App Info
   *                            p_commit
   *                              Allow Calc shutdown when flagged
   *                            p_init_calc
   *                              Add Raw Cash Discount and Max DPA percentages
   *                              Add domestic/territory fields to component list
   *                            p_common_initialize
   *                              Enforce PPACA Retail/Non-Retail settings
   *                              Set a flag that a calc is running
   *                            p_calc_log
   *                              Use pkg_utils App Info
   *                              Rename package global variables
   *                            p_comp_tbl_to_rec
   *                              Add Genzyme Calculation components
   *                            p_get_trans_vals
   *                              Add WAC value of packages
   *                              Use Raw Cash Discount and Max DPA percentages
   *                            p_accum_trans
   *                              Add WAC value of packages
   *                              Add Zero Dollars mark/accumulation method
   *                              Add FFS-PHS Contract mark/accumulation method
   *                              Add Non-Zero Dollars/FFS-PHS Contract mark/accumulation method
   *                              Add No Nominal/HHS/Zero Dollars mark/accumulation method
   *                              Add No Nominal/HHS/Zero Dollars/FFS-PHS Contract mark/accumulation method
   *                            p_prcss_trans
   *                              Add WAC value of packages
   *                              Add domestic/territory fields to component check
   *                            p_splt_trns
   *                              Add WAC value of packages
   *                            p_bndl_trans
   *                              Add WAC value of packages
   *                              Add global flags to disable bundling steps
   *                            p_trans_rollup_loop
   *                              Add WAC value of packages
   *                              Add domestic/territory fields
   *                            p_get_calc_trans
   *                              Disable Bundle Config step unless calc step is 1
   *  03/01/2012  Joe Kidd      CRQ-14127: Fix Contract ID filter not working
   *                            for blank contract IDs
   *                            p_accum_trans
   *                               Make NULL FSS/PHS contract check FALSE
   *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
   *                            Deleted: p_get_product_rollup, p_get_profile_variable
   *                            New: p_unlock_profile, p_chk_calc_shutdown
   *                            t_calc_comp_rec
   *                              Add Genzyme Calculation components
   *                              Remove Cash Discount and Max DPA percentages
   *                            t_calc_param_rec: Restructured and expanded
   *                            p_set_calc_shutdown
   *                              Allow to set shutdown on entire profile for
   *                              running or submitted products
   *                            p_update_prod_calc
   *                              Use new view to populate tables
   *                              Commit at end counting all changes
   *                            p_mk_prod_wrk_t
   *                              Pass only calc parameter record
   *                              Use new view to populate products
   *                              Remove Bundle products section
   *                            p_mk_mtrx_wrk_t
   *                              Pass only calc parameter record
   *                            p_mk_splt_pct_wrk_t, f_mk_bndl_dts
   *                              Pass only calc parameter record
   *                              Change refernces to NDC in product work table
   *                            p_commit
   *                              Call new Calc shutdown proc every time
   *                            p_init_calc
   *                              Use new view to populate settings
   *                              Remove scalar parameters and make overloaded version
   *                              Enforce Wholesaler values for Non-Indirects
   *                              Remove debug settings no longer needed
   *                              Remove addition of bundled products to work table
   *                            p_common_initialize
   *                              Remove decimal precision parameter
   *                              Call init calc, then check variables
   *                              Reduce use of pkg_constants globals
   *                            p_ins_price_pnt
   *                              Commit at end counting all changes
   *                            p_get_trans_vals
   *                              Variables moved to param record
   *                            p_accum_trans
   *                              Check FSS/PHS contract first
   *                              Don't check nominal for FSS/PHS contracts
   *                              Add HHS/Non-Zero Dollars mark/accumulation method
   *                              Add HHS/Zero Dollars mark/accumulation method
   *                              Add No HHS mark/accumulation method
   *                              Add No HHS/Zero Dollars mark/accumulation method
   *                              Add No Nominal mark/accumulation method
   *                              Add No Nominal/Zero Dollars mark/accumulation method
   *                              Add No Nominal/Zero Dollars/FFS-PHS Contract mark/accumulation method
   *                              Don't mark HHS violations mor ethan once
   *                            f_chk_trans_comp
   *                              Fully describe customer dom/terr check
   *                              Expand to allow Non-US only
   *                            p_trans_rollup_loop
   *                              Prevent duplicate adjustments
   *                            p_get_calc_trans
   *                              Remove deletion of bundle products (no longer needed)
   *  11/06/2012  Joe Kidd      CRQ-32007: Correct Product-only Bundle Null Measurement Date Error
   *                            p_bndl_trans
   *                              Change index name in csr_bndl_cust_tt hint
   *                              due to index name change
   *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
   *                            Code formatting
   *                            New: t_prod_price_rec, t_prod_price_tbl
   *                              p_comp_val_set, p_comp_val_add, p_comp_val_save,
   *                            Removed: t_calc_comp_rec, t_comp_rec, t_comp_tbl,
   *                              p_comp_tbl_to_rec
   *                            t_calc_param_rec
   *                              Add FCP source indicator
   *                            t_comp_trans_def_rec
   *                              Remove unneeded index columns
   *                              Add nominal and HHS units components
   *                            p_chk_calc_shutdown
   *                              Fix timer bug
   *                            p_mk_prod_wrk_t
   *                              Populate Addtional fields
   *                            p_mk_splt_pct_wrk_t
   *                              Remove transaction date range overlap restriction
   *                            f_mk_bndl_dts
   *                              Fix pop src after return
   *                            p_update_interim_table
   *                              Remove FCP source indicator parameter
   *                            p_init_calc
   *                              Change component value parameter
   *                              Populate profile work table
   *                              Update Component Definition Query to Remove
   *                              unneeded index columns, Get Nom/HHS units components
   *                            p_common_initialize
   *                              Change component value parameter
   *                              Save initial component values
   *                            p_create_prod_price_tbl
   *                              Get prices for all NDCs in calculation
   *                              Get prices with actual dates not just last
   *                              price of the quarter
   *                            p_create_amp_nd_tbl
   *                              Remove call to pkg_common_functions.f_calc_nominal_dollars
   *                            p_get_trans_vals
   *                              Update for calc cursor changes
   *                            f_ins_price_pnt, p_ins_price_pnt
   *                              Convert to function returning price point seq no
   *                              Procedure to call function
   *                            p_mark_record
   *                              Call new f_ins_price_pnt function and remove global
   *                            p_accum_trans
   *                              Use new component value table
   *                              Add new trans mark/accumulation settings
   *                              Use earned date Sub-PHS checks
   *                              Add nominal values to nom/hhs mark components
   *                              Use chk values for HHS violation component
   *                            p_splt_trns
   *                              Use earned date to determine split percentage
   *                            f_chk_trans_comp
   *                              Reorder date check to annual, qtr, offset
   *                            p_bndl_trans
   *                              Change Min/Max dates to match new paid/earned scheme
   *                            p_trans_rollup_loop
   *                              Update for calc cursor changes
   *                              Only link transactions when earned dates are used
   *                              Add customer ID to SAP cursors
   *                            p_get_calc_trans
   *                              Change component value parameter
   *                              Call new main cursor
   *  04/11/2013  Joe Kidd      CRQ-45044: Adjust GP Smoothing
   *                            p_init_calc, p_trans_rollup_loop, p_get_calc_trans
   *                              Disable bundling on second pass if no bundling
   *                              summaries are found
   *  11/20/2013  Joe Kidd      CRQ-79943: Correct rollup product logic
   *                            p_update_prod_calc
   *                              Correct how prfl_calc_prod_roll_t is populated
   *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
   *                            New: p_mk_calc_comp_def_wrk_t, f_sv_calc_comp_def_wrk_t,
   *                                 f_fe_bndl_init, f_fe_bndl_cleanup, f_sv_bndl_stats
   *                            Move Transaction Amount Definition Constants from
   *                            pkg_common_constants because they are only used here.
   *                            t_calc_param_rec
   *                              Add component description field
   *                            t_comp_trans_def_rec
   *                              Add Prompt Pay Discount fields
   *                            p_chk_calc_shutdown
   *                              Add user message for calc shutdown
   *                            p_update_prod_calc
   *                              Refactor to populate additional columns
   *                            p_mk_mtrx_wrk_t
   *                              Populate Profile Cust COT working table
   *                              Populate new uses net/discount column
   *                            f_mk_bndl_dts
   *                              Extracted bundling dates query from f_mk_bndl_info
   *                            f_mk_bndl_info
   *                              Renamed from f_mk_bndl_dts
   *                              Moved bundling dates query to f_mk_bndl_dts
   *                              Load customer COTs from new GTT
   *                            p_calc_delete
   *                              Add tablename to error messages
   *                              Clear Calc Component Definition table
   *                            p_init_calc
   *                              Moved Calc Component Defintions to procedure
   *                              Collect bundling statistics
   *                              Set system globals
   *                            p_common_initialize
   *                              Add user message for progress points and errors
   *                              Save Calc Component Definitions
   *                            p_calc_log
   *                              Add user message parameter and populate it
   *                              Add addititonal longops for calc delete
   *                            p_get_trans_vals, p_mark_record
   *                              Seperated Component and Transaction dollars constants
   *                              Carry and process prompt pay dollars seperately
   *                            f_is_trans_marked
   *                              Moved from pkg_common_functions
   *                            p_accum_trans
   *                              Seperated Component and Transaction dollars constants
   *                              Carry prompt pay dollars seperately
   *                              Reorder and complete Accumulate processing
   *                            p_bndl_trans
   *                              Include SAP transactions in bundling processing
   *                              Seperated Component and Transaction dollars constants
   *                              Collect bundling statistics
   *                            p_splt_trns, p_prcss_trans
   *                              Carry prompt pay dollars seperately
   *                            p_trans_rollup_loop
   *                              Add component description for user message
   *                              Carry and process prompt pay dollars seperately
   *                              Simplify bulk collections
   *                            p_get_calc_trans
   *                              Add component description for user message
   *                              Collect bundling statistics
   *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
   *                            t_comp_trans_def_rec
   *                              Add new bundling control columns
   *                            p_mk_calc_comp_def_wrk_t
   *                              Add new bundling control columns
   *                              Add bundle adjustment count parameter
   *                            f_sv_calc_comp_def_wrk_t
   *                              Add new bundling control columns
   *                              Remove unneeded transaction accumulation checks
   *                            p_mk_mtrx_wrk_t
   *                              Add new bundling control columns
   *                              Populate Profile COT working table
   *                            p_init_calc
   *                              Revise bundling control logic
   *                            p_get_trans_vals
   *                              Add new bundling control columns
   *                              Remove main transaction and total variables
   *                            p_accum_trans
   *                              Remove total variables
   *                              Remove unneeded transaction accumulations
   *                            p_prcss_trans, p_splt_trns
   *                              Remove total variables
   *                            p_trans_rollup_loop
   *                              Remove total variables
   *                              Relax SAP adjustment lookup by Tran Type Group
   *                              Allow to find RBT/FEE SAP adjustments when
   *                              rebate/fee lookup is on
   *                            p_bndl_trans
   *                              Remove total variables
   *                              Add new bundling control variables
   *                              Correct rebate link double counting issue
   *  10/02/2015  Joe Kidd      CRQ-208647: Demand 6324: NonFamp/FCP Calc Modifications
   *                            Removed: p_update_interim_table (t_calc_param_rec version)
   *                            t_comp_val_rec, p_comp_val_set
   *                              Add FCP source and carry forward indicators
   *                            t_calc_param_rec
   *                              Remove FCP source and carry forward indicators
   *                            p_comp_val_save
   *                              Allow each component to set FCP source and carry
   *                                forward indicators
   *                            p_update_interim_table
   *                              Remove validation on FCP Source and Carry Forward
   *                            p_common_initialize
   *                              Add parameter to control clearing of product comments
   *  10/26/2015  Joe Kidd      CRQ-228988: Demand 8134: BP Upload
   *                            f_ins_price_pnt, p_ins_price_pnt
   *                              Add parameters to set manually added indicator,
   *                              control null comments, and control commits
   *  05/25/2016  Joe Kidd      CRQ-266675: Demand 3336 AMP Final Rule (June Release)
   *                            p_trans_rollup_loop
   *                              Limit trans linking to same supergroup
   *  08/31/2016  T. Zimmerman  CRQ-302277: Demand 3336 AMP Final Rule (October Release)
   *                            p_common_initialize
   *                              Added test of sys param to control Validate Matrix
   *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
   *                            New: t_mark2_tbl
   *                            p_mk_mtrx_wrk_t
   *                              Remove wholesaler COT SG limit
   *                            p_calc_delete
   *                              Remove all references to bp_pnt_contr_dtl_t
   *                              Adjust for new bp_pnt_trans_dtl_t layout
   *                              Calc Log adds formatted counts to user message
   *                            p_init_calc
   *                              Clear all working (GTT) tables
   *                            p_common_initialize
   *                              Add commit before init calc to detect shutdown
   *                            p_calc_log
   *                              Add formatted counts to user message
   *                            p_mark_record_flush
   *                              Remove from package specification
   *                              Add customer id parameter
   *                              Remove all references to bp_pnt_contr_dtl_t
   *                              Adjust for new bp_pnt_trans_dtl_t layout
   *                              Only save rows when marking records
   *                              Flush rows when customer changes
   *                            p_mark_record
   *                              Adjust for new bp_pnt_trans_dtl_t layout
   *                              Always build marking cache and lookup tables
   *                              Flush rows when customer changes
   *                            f_is_trans_marked
   *                              Remove trans ndc parameters
   *                              Use marking lookup table instead of cache table
   *                            p_accum_trans
   *                              Remove trans ndc parameters from f_is_trans_marked
   *                            p_trans_rollup_loop
   *                              Calc Log adds formatted counts to user message
   *                            p_get_calc_trans
   *                              Add steps parameter for user message
   *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
   *                            New: p_add_bndl_trans_id, p_del_bndl_trans_id,
   *                                 f_get_bndl_trans_ids
   *                            t_calc_param_rec
   *                              Add ndc_dupe_count
   *                            f_mk_bndl_dts
   *                              Refactor query and allow future measurement periods
   *                            f_mk_bndl_info, p_init_calc
   *                              Remove reference to prfl_bndl_price_grp_wrk_t
   *                            f_fe_bndl_init
   *                              Add Company ID parameter defaults to Sanofi
   *                            p_init_calc
   *                              Remove reference to prfl_bndl_price_grp_wrk_t
   *                              Populate global variables for marking NDC columns
   *                              Check for duplicate NDCs
   *                            p_common_initialize
   *                              Check for duplicate NDCs
   *                              Cleanup error handling
   *                            p_mark_record_flush
   *                              When customer changes, only flush the customer
   *                              marekd transaction ID table.  The full marked
   *                              transaction table flush on bulk row count
   *                            p_bndl_trans
   *                              Replace summary count cursor and bundling
   *                              control variables with cust ID associative array
   *                              Moved bundle adjustment query to
   *                              pkg_common_cursors.csr_bndl_adj_trns
   *                              Only create one adjustment for each of a
   *                              transaction group's transaction classes for
   *                              all related bundle codes
   *                              Check if bundling is enabled here
   *                            p_trans_rollup_loop
   *                              Control log updates by time intervals
   *                              Remove bundle statistics update
   *                              Move check if bundling enabled to bundling proc
   *                            p_get_calc_trans
   *                              Remove unneeded bundle statistics update
   *  08/01/2017  Joe Kidd      CRQ-376321: Demand 10535: NFAMP HHS Comp Summary
   *                            f_mk_bndl_dts
   *                              Fix day based periods bug, performance improvements
   *                            p_common_initialize
   *                              Create HHS Violation component
   *                            p_accum_trans
   *                              Accumulate a component for the HHS violations
   *  09/01/2017  T. Zimmerman  CRQ-376430: Demand 10537: NFAMP 340B Prime Vendor
   *                            New: t_340b_pvp_contr_tbl, p_create_340b_pvp_contr_tbl
   *                            p_common_initialize
   *                              Load 340B Prime Vendor Contracts
   *                            p_accum_trans
   *                              Skip sub-PHS price checking for 340B Prime Vendor contracts
   *  09/20/2017  T. Zimmerman  CRQ-376489: Demand 10536: Revise Calc Methods for SPP Wholesalers
   *              Joe Kidd      p_mk_calc_comp_def_wrk_t, p_accum_trans
   *                              Add limit for contracted or non-contracted transactions
   */
   -- This gap brought to you by PL/SQL Developer which cannot handle a 1000+ line comment.
   /*
   *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
   *                            Removed: t_340b_pvp_contr_tbl, t_comp_trans_def_rec,
   *                              t_comp_trans_def_tbl, t_trns_amt_rec,
   *                              t_trns_amt_tbl, t_splt_pct_rec, t_splt_pct_tbl,
   *                              t_bndl_cust_id_tbl, p_update_prfl_status,
   *                              p_create_340b_pvp_contr_tbl, f_chk_trans_comp,
   *                              p_prcss_trans, p_splt_trns
   *                            New: t_calc_total_rec, t_mark_nom_rec, t_mark_nom_tbl,
   *                              t_mark_nom_id_tbl, t_bndl_cust_tbl,
   *                              t_trans_cls_bndl_rec, t_trans_cls_bndl_tbl,
   *                              t_longops_rec, p_comp_val_clear, p_comp_val_init,
   *                              p_comp_val_round_all, f_comp_val_get,
   *                              f_is_calc_running, p_clear_wrk_t, p_commit_force,
   *                              p_set_bndl_cust, f_get_bndl_cust, p_init_longops_rec,
   *                              p_init_longops_tbl, p_set_longops_rec, f_sv_bndl_smry,
   *                              p_mk_contr_wrk_t, p_mk_mtrx_splt_bndl_wrk_t
   *                            General: Renamed all package globals to gv_*
   *                            t_calc_param_rec
   *                              Remove Component and Description
   *                              Add Min/Max Paid/Earn dates, Component Count
   *                            t_comp_trans_def_rec
   *                              Remove secondary nom/hhs accumulation columns
   *                            p_comp_val_save
   *                              Do not save price point components
   *                            p_chk_calc_shutdown
   *                              Remove parameters, use package global
   *                            p_update_prod_calc
   *                              Use working tables instead of views
   *                            p_mk_prod_wrk_t
   *                              Change parameters, populate addtional fields
   *                            p_mk_calc_comp_def_wrk_t
   *                              Change parameters, Populate second working table
   *                              No longer populate associative array or throw errors
   *                              Get Units components from main table
   *                            p_mk_mtrx_wrk_t
   *                              Remove parameters
   *                              Remove Trans Type Group process seq number
   *                              Add flags for paid date and earn date use
   *                              Remove class of trade working table
   *                              Populate cust cot working table with dates
   *                            p_mk_splt_pct_wrk_t
   *                              Change parameters to allow two passes
   *                              Populate working table instead of associative array
   *                            f_mk_bndl_dts
   *                              Add support for NEGLAG additional text value
   *                              Check if bundles are used by earned date
   *                            f_mk_bndl_info
   *                              Populate addtional fields
   *                              Additional Value changed from NUMBER to VARCHAR2
   *                              Limit customer conditions by the matrix
   *                              Clear working tables if bundling not needed
   *                              Set bundle dates and bundle product flags
   *                            f_fe_bndl_init
   *                              Adapt to changes in Bundle Dates routine
   *                            p_calc_delete
   *                              Clean up logging and longops handling
   *                              Use package globals if possible
   *                            p_init_calc
   *                              Change parameters, initialize all package globals
   *                              Revise working tables population
   *                              Use global variable for debugging environment
   *                              Add parameters to disable nominal/sub-PHS
   *                            p_common_initialize
   *                              Change parameters, Fix NDC on PPACA and UOM errors,
   *                              Check Component Defs for errors, use package globals
   *                              Populate the component value table
   *                              Remove 340B Prime Vendor Contract load
   *                            p_calc_log
   *                              Change parameters, add more logging and longops items
   *                            p_mark_record_flush
   *                              Flush write cache for nominal
   *                            p_get_trans_vals
   *                              Change parameters, handle rebates w/o discount
   *                              Change parameters, perform component checks
   *                            p_mark_record
   *                              Changed parameters, Add marked row count logging
   *                            f_mark_nominal
   *                              Change to function, cache writes, add new columns,
   *                              control default inclusion here, simplify comment
   *                              lookup, add marked row count logging
   *                            f_is_trans_marked
   *                              Change parameters, reduce key length
   *                              Added version to check entire transaction group
   *                            p_accum_trans
   *                              Change parameters, adapt to new component settings
   *                              and functions, remove secondary nom/hhs components
   *                            p_add_bndl_trans_id
   *                              Add additional columns, remove error handler
   *                            p_del_bndl_trans_id, f_get_bndl_trans_ids
   *                              Remove error handler
   *                            p_bndl_trans
   *                              Change parameters, simplify audit trail process
   *                              Simplify transaction analysis to apply bundle
   *                            p_trans_rollup_loop
   *                              Completely rewritten for new main cursor output
   *                            p_get_calc_trans
   *                              Change parameters, Use new main cursor output
   *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
   *                              formula / Winthrop BP Change
   *                            New: p_update_longops_tbl, f_get_longops_val,
   *                                 p_update_user_msg, f_format_calc_log_step_descr,
   *                                 f_format_calc_log_user_msg, f_calc_log,
   *                                 p_calc_log, p_calc_log_write, p_calc_log_new_calc,
   *                                 p_calc_log_end_calc
   *                            p_calc_log....
   *                              Split p_calc_log into many functions and procedures
   *                            p_chk_calc_shutdown
   *                              Use updated calc log procedures
   *                            f_fe_bndl_init
   *                              Remove unneeded parameters, use cleanup proc
   *                            p_calc_delete
   *                              Add parameter for calc log user message
   *                              Use updated calc log procedures
   *                            p_init_calc
   *                              Don't initialize calc log longops
   *                            p_common_initialize, p_get_calc_trans
   *                              Use updated calc log procedures
   *                              Expand calc log entries
   *                            p_get_trans_vals
   *                              Apply Cash Discount % to Wholesaler Source
   *                              Program Chargebacks
   *                            p_set_bndl_cust, p_add_bndl_trans_id:
   *                              Correct %TYPE anchors
   *                            p_trans_rollup_loop
   *                              Add calc log parameters
   *                              Use updated calc log procedures
   *  06/05/2019  J. Tronoski   CHG-117658: RITM-0726677: Bundle Evaluation Date Codes
   *                            f_mk_bndl_dts
   *                              Add VSDO and VEDO Addl Text settings
   *  08/01/2019  JTronoski     CHG-125643: Prompt Pay Disc Change for New Bundle Adjustment
   *                            p_create_adjustments
   *                              Set Bundle Adjustment Prompt Pay Dollars to zero
   *  09/11/2019  JTronoski     CHG-132657: Issue with AMP Calculation
   *                            p_calc_log_write
   *                              Calc log write failure, set last update to NULL
   *                              instead of zero to force an update
   *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
   *                            Removed: p_init_longops_rec, p_update_longops_tbl,
   *                              f_get_longops_val, p_push_src, p_pop_src,
   *                              f_get_bndl_cust_cond
   *                            New: f_log_errors, p_log_errors, f_is_calc_running_vc,
   *                              f_get_cust_loc_cd_list, p_cnt_act_calc_comp_def_wrk_t
   *                            General (many proc/func affected)
   *                              Move longops rountines and timers to pkg_utils
   *                              Add Calc Debug mode and Front End mode to control error handling
   *                              Remove unneeded pkg_constants global variables
   *                              Centralize GTT deletes
   *                              GTT column reductions
   *                            t_calc_param_rec, p_mk_mtrx_splt_bndl_wrk_t
   *                              Correct Nominal/sub-PHS enable/disable
   *                            p_raise_errors
   *                              Move error logging to separate procedures
   *                            p_chk_calc_shutdown
   *                              Use calc running function
   *                            p_commit
   *                              Move commit counter into this package
   *                            p_commit_force
   *                              Call p_commit passing commit point
   *                            p_init_cntrs
   *                              Renamed from p_init_longops_tbl
   *                            p_set_cntr
   *                              Renamed from p_set_longops_rec
   *                            f_calc_log
   *                              Add force update parameter
   *                            p_mk_prod_wrk_t, p_mk_mtrx_splt_bndl_wrk_t,
   *                            p_init_calc, p_accum_trans, p_bndl_trans,
   *                            p_get_calc_trans
   *                              Correct Nominal/sub-PHS enable/disable
   *                            p_mk_calc_comp_def_wrk_t
   *                              Use new customer location code function
   *                            p_mk_mtrx_wrk_t
   *                              Tune CCOT insert, correct hints
   *                            f_mk_bndl_dts, f_mk_bndl_info
   *                              New bundle period columns added
   *                              Check for invalid pricing/performance period date ranges
   *                            f_sv_bndl_dts, f_sv_bndl_smry
   *                              Calculate values removed from GTT
   *                            f_fe_bndl_init, f_fe_bndl_cleanup
   *                              New bundle period columns added
   *                              Add exception handler
   *                            p_calc_delete
   *                              Delete all tables in commit loop, reduce code
   *                              Clean up logging and longops handling
   *                            p_init_calc_debug
   *                              Rename from p_init_calc
   *                              Correct Nominal/sub-PHS enable/disable
   *                            p_common_initialize
   *                              Reorganize validations and logging
   *                            p_set_bndl_cust
   *                              Include Customer Conditions
   *                            p_bndl_trans
   *                              Remove GTT delete by customer
   *                            p_trans_rollup_loop
   *                              Correct handling of ICW_KEY and other links
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            t_calc_param_rec - Reorder similiar to view
   *                            p_mk_prod_wrk_t, f_mk_bndl_info
   *                              Add SAP4H source system constants
   *                            p_init_calc
   *                              Add SAP4H source system constants
   *                              Reorder t_calc_param_rec columns
   *                            p_bndl_trans, p_trans_rollup_loop
   *                              Add SAP4H to SAP trans rules
   ****************************************************************************/

   -- Initialization parameters
   TYPE t_calc_param_rec IS RECORD
      (prfl_id                      hcrs.prfl_wrk_v.prfl_id%TYPE,
       co_id                        hcrs.prfl_wrk_v.co_id%TYPE,
       ndc_lbl                      hcrs.prfl_wrk_v.ndc_lbl%TYPE,
       ndc_prod                     hcrs.prfl_wrk_v.ndc_prod%TYPE,
       ndc_pckg                     hcrs.prfl_wrk_v.ndc_pckg%TYPE, -- NULL for NDC9 calculations
       mk_ndc_lbl                   hcrs.prfl_wrk_v.ndc_lbl%TYPE, -- For marking tables
       mk_ndc_prod                  hcrs.prfl_wrk_v.ndc_prod%TYPE, -- For marking tables
       mk_ndc_pckg                  hcrs.prfl_wrk_v.ndc_pckg%TYPE, -- For marking tables, min NDC11 for NDC9 calcs
       calc_typ_cd                  hcrs.prfl_wrk_v.calc_typ_cd%TYPE,
       calc_mthd_cd                 hcrs.prfl_wrk_v.calc_mthd_cd%TYPE,
       agency_typ_cd                hcrs.prfl_wrk_v.agency_typ_cd%TYPE,
       calc_ndc_pckg_lvl            hcrs.prfl_wrk_v.calc_ndc_pckg_lvl%TYPE,
       rpt_ndc_pckg_lvl             hcrs.prfl_wrk_v.rpt_ndc_pckg_lvl%TYPE,
       prcss_typ_cd                 hcrs.prfl_wrk_v.prcss_typ_cd%TYPE,
       tim_per_cd                   hcrs.prfl_wrk_v.tim_per_cd%TYPE,
       start_dt                     hcrs.prfl_wrk_v.start_dt%TYPE,
       end_dt                       hcrs.prfl_wrk_v.end_dt%TYPE,
       ann_start_dt                 hcrs.prfl_wrk_v.ann_start_dt%TYPE,
       ann_end_dt                   hcrs.prfl_wrk_v.ann_end_dt%TYPE,
       ann_off_start_dt             hcrs.prfl_wrk_v.ann_off_start_dt%TYPE,
       ann_off_end_dt               hcrs.prfl_wrk_v.ann_off_end_dt%TYPE,
       min_start_dt                 hcrs.prfl_wrk_v.min_start_dt%TYPE,
       max_end_dt                   hcrs.prfl_wrk_v.max_end_dt%TYPE,
       min_paid_start_dt            hcrs.prfl_wrk_v.min_paid_start_dt%TYPE,
       max_paid_end_dt              hcrs.prfl_wrk_v.max_paid_end_dt%TYPE,
       min_earn_start_dt            hcrs.prfl_wrk_v.min_earn_start_dt%TYPE,
       max_earn_end_dt              hcrs.prfl_wrk_v.max_earn_end_dt%TYPE,
       -----------------------------
       min_bndl_start_dt            hcrs.prfl_prod_wrk_t.min_bndl_start_dt%TYPE,
       max_bndl_end_dt              hcrs.prfl_prod_wrk_t.max_bndl_end_dt%TYPE,
       -----------------------------
       prod_elig_start_dt           hcrs.prfl_wrk_v.prod_elig_start_dt%TYPE,
       prod_elig_end_dt             hcrs.prfl_wrk_v.prod_elig_end_dt%TYPE,
       end_dt_30_day                hcrs.prfl_wrk_v.end_dt_30_day%TYPE,
       end_dt_first_full            hcrs.prfl_wrk_v.end_dt_first_full%TYPE,
       snpsht_id                    hcrs.prfl_wrk_v.snpsht_id%TYPE,
       snpsht_dt                    hcrs.prfl_wrk_v.snpsht_dt%TYPE,
       max_fss_comp_ind             hcrs.prfl_wrk_v.max_fss_comp_ind%TYPE,
       prelim_ind                   hcrs.prfl_wrk_v.prelim_ind%TYPE,
       sales_offset_days            hcrs.prfl_wrk_v.sales_offset_days%TYPE,
       nom_thrs_pct                 hcrs.prfl_wrk_v.nom_thrs_pct%TYPE,
       cash_dscnt_pct_raw           hcrs.prfl_wrk_v.cash_dscnt_pct_raw%TYPE, -- CDP as entered
       cash_dscnt_pct               hcrs.prfl_wrk_v.cash_dscnt_pct%TYPE, -- (1 - CDP)
       prmpt_pay_adj_pct            hcrs.prfl_wrk_v.prmpt_pay_adj_pct%TYPE, -- PPAP as entered
       max_dpa_pct_raw              hcrs.prfl_wrk_v.max_dpa_pct_raw%TYPE, -- MAX_DPA_PCT as entered
       max_dpa_pct                  hcrs.prfl_wrk_v.max_dpa_pct%TYPE, -- (1- MAX_DPA_PCT)
       dec_pcsn                     hcrs.prfl_wrk_v.dec_pcsn%TYPE,
       nxt_calc_typ_cd              hcrs.prfl_wrk_v.nxt_calc_typ_cd%TYPE,
       init_filing                  hcrs.prfl_wrk_v.init_filing%TYPE,
       addl_filing                  hcrs.prfl_wrk_v.addl_filing%TYPE,
       set_baseline                 hcrs.prfl_wrk_v.set_baseline%TYPE,
       carry_fwd                    hcrs.prfl_wrk_v.carry_fwd%TYPE,
       prod_trnsmsn_rsn_cd          hcrs.prfl_wrk_v.prod_trnsmsn_rsn_cd%TYPE,
       prfl_mths                    hcrs.prfl_wrk_v.prfl_mths%TYPE,
       annl_strt_dt_mth_offset      hcrs.prfl_wrk_v.annl_strt_dt_mth_offset%TYPE,
       annl_end_dt_mth_offset       hcrs.prfl_wrk_v.annl_end_dt_mth_offset%TYPE,
       prod_elig_strt_dt_mth_offset hcrs.prfl_wrk_v.prod_elig_strt_dt_mth_offset%TYPE,
       prod_elig_end_dt_mth_offset  hcrs.prfl_wrk_v.prod_elig_end_dt_mth_offset%TYPE,
       dra_baseln_restat_strt_dt    hcrs.prfl_wrk_v.dra_baseln_restat_strt_dt%TYPE,
       dra_baseln_restat_end_dt     hcrs.prfl_wrk_v.dra_baseln_restat_end_dt%TYPE,
       use_dra_prod_bndl            hcrs.prfl_wrk_v.use_dra_prod_bndl%TYPE,
       use_dra_time_bndl            hcrs.prfl_wrk_v.use_dra_time_bndl%TYPE,
       sap_adj_sg_elig_intgrty      hcrs.prfl_wrk_v.sap_adj_sg_elig_intgrty%TYPE,
       sap_adj_dt_mblty             hcrs.prfl_wrk_v.sap_adj_dt_mblty%TYPE,
       use_ppaca_ind                hcrs.prfl_wrk_v.use_ppaca_ind%TYPE,
       lkup_sap_adj                 hcrs.prfl_wrk_v.lkup_sap_adj%TYPE,
       lkup_rbt_fee                 hcrs.prfl_wrk_v.lkup_rbt_fee%TYPE,
       lkup_rel_crd                 hcrs.prfl_wrk_v.lkup_rel_crd%TYPE,
       lkup_xenon_adj               hcrs.prfl_wrk_v.lkup_xenon_adj%TYPE,
       lkup_prasco_rbtfee           hcrs.prfl_wrk_v.lkup_prasco_rbtfee%TYPE,
       chk_nom                      hcrs.prfl_wrk_v.chk_nom%TYPE, -- Runtime Nominal Check setting (changes based on calc state)
       chk_hhs                      hcrs.prfl_wrk_v.chk_hhs%TYPE, -- Runtime HHS Violation Check setting (changes based on calc state)
       -----------------------------
       chk_nom_calc                 hcrs.prfl_prod_wrk_t.chk_nom_calc%TYPE, -- Calculation Nominal Check setting (set at calc start, never changes)
       chk_hhs_calc                 hcrs.prfl_prod_wrk_t.chk_hhs_calc%TYPE, -- Calculation HHS Violation Check setting (set at calc start, never changes)
       -----------------------------
       uses_paid_dt                 hcrs.prfl_wrk_v.uses_paid_dt%TYPE,
       uses_earn_dt                 hcrs.prfl_wrk_v.uses_earn_dt%TYPE,
       pri_whls_mthd_cd             hcrs.prfl_wrk_v.pri_whls_mthd_cd%TYPE,
       ndc_count                    hcrs.prfl_wrk_v.ndc_count%TYPE,
       ndc_dupe_count               hcrs.prfl_wrk_v.ndc_dupe_count%TYPE,
       unit_per_pckg                hcrs.prfl_wrk_v.unit_per_pckg%TYPE,
       comm_unit_per_pckg           hcrs.prfl_wrk_v.comm_unit_per_pckg%TYPE,
       mrkt_entry_dt                hcrs.prfl_wrk_v.mrkt_entry_dt%TYPE,
       first_dt_sld                 hcrs.prfl_wrk_v.first_dt_sld%TYPE,
       term_dt                      hcrs.prfl_wrk_v.term_dt%TYPE,
       liab_end_dt                  hcrs.prfl_wrk_v.liab_end_dt%TYPE,
       drug_catg_cd                 hcrs.prfl_wrk_v.drug_catg_cd%TYPE,
       medicare_drug_catg_cd        hcrs.prfl_wrk_v.medicare_drug_catg_cd%TYPE,
       comp_def_cnt                 NUMBER,
       bndl_adj_cnt                 NUMBER,
       bad_accum_cnt                NUMBER,
       deprecated_cnt               NUMBER,
       bad_trans_cnt                NUMBER,
       bad_nom_cnt                  NUMBER,
       bad_hhs_cnt                  NUMBER);

   -- For Nominal price checks
   TYPE t_price_rec IS RECORD
      (start_dt  DATE,
       end_dt    DATE,
       chk_price NUMBER, -- price to check against
       src_price NUMBER); -- original price
   TYPE t_price_tbl IS TABLE OF t_price_rec INDEX BY BINARY_INTEGER;

   -- Sub-PHS price checks (PL 102 violations)
   TYPE t_prod_price_rec IS RECORD
      (ndc_lbl   hcrs.prfl_wrk_v.ndc_lbl%TYPE,
       ndc_prod  hcrs.prfl_wrk_v.ndc_prod%TYPE,
       ndc_pckg  hcrs.prfl_wrk_v.ndc_pckg%TYPE, -- NULL for NDC9 calculations
       start_dt  DATE,
       end_dt    DATE,
       chk_price NUMBER, -- price to check against
       src_price NUMBER); -- original price
   TYPE t_prod_price_tbl IS TABLE OF t_prod_price_rec INDEX BY BINARY_INTEGER;

   PROCEDURE p_raise_errors
      (i_module_nam   IN hcrs.error_log_t.src_cd%TYPE,
       i_module_descr IN hcrs.error_log_t.src_descr%TYPE,
       i_error_cd     IN hcrs.error_log_t.error_cd%TYPE,
       i_error_msg    IN hcrs.error_log_t.error_descr%TYPE,
       i_cmt_txt      IN hcrs.error_log_t.cmt_txt%TYPE);

   PROCEDURE p_reg_job_name
      (i_job_name IN VARCHAR2);

   PROCEDURE p_unlock_profile
      (i_prfl_id IN hcrs.prfl_prod_calc_t.prfl_id%TYPE);

   FUNCTION f_is_calc_running
      RETURN BOOLEAN;

   FUNCTION f_is_calc_running_vc
      RETURN VARCHAR2;

   PROCEDURE p_set_calc_shutdown
      (i_prfl_id  IN hcrs.prfl_prod_calc_t.prfl_id%TYPE,
       i_ndc_lbl  IN hcrs.prfl_prod_calc_t.ndc_lbl%TYPE := NULL,
       i_ndc_prod IN hcrs.prfl_prod_calc_t.ndc_prod%TYPE := NULL,
       i_ndc_pckg IN hcrs.prfl_prod_calc_t.ndc_pckg%TYPE := NULL);

   PROCEDURE p_commit
      (i_ctr IN NUMBER := 1);

   PROCEDURE p_commit_force;

   PROCEDURE p_calc_log
      (i_step_descr  IN hcrs.prfl_prod_calc_log_t.descr%TYPE,
       i_user_msg    IN hcrs.prfl_prod_t.user_msg_txt%TYPE := NULL,
       i_comp_typ_cd IN hcrs.prfl_prod_calc_log_t.comp_typ_cd%TYPE := NULL);

   PROCEDURE p_calc_log_end_calc;

   PROCEDURE p_update_interim_table
      (i_prfl_id       IN hcrs.prfl_prod_calc_t.prfl_id%TYPE,
       i_ndc_lbl       IN hcrs.prfl_prod_calc_t.ndc_lbl%TYPE,
       i_ndc_prod      IN hcrs.prfl_prod_calc_t.ndc_prod%TYPE,
       i_ndc_pckg      IN hcrs.prfl_prod_calc_t.ndc_pckg%TYPE,
       i_calc_typ_cd   IN hcrs.prfl_prod_calc_t.calc_typ_cd%TYPE,
       i_comp_typ_cd   IN hcrs.prfl_prod_calc_t.comp_typ_cd%TYPE,
       i_calc_amt      IN hcrs.prfl_prod_calc_t.calc_amt%TYPE,
       i_fcp_src_ind   IN hcrs.prfl_prod_calc_t.fcp_src_ind%TYPE := NULL,
       i_carry_fwd_ind IN hcrs.prfl_prod_calc_t.carry_fwd_ind%TYPE := NULL);

   PROCEDURE p_comp_val_round_all
      (i_dec_pcsn   IN NUMBER,
       i_trans_comp IN BOOLEAN := NULL);

   PROCEDURE p_comp_val_set
      (i_comp_typ_cd   IN hcrs.comp_typ_t.comp_typ_cd%TYPE,
       i_amt           IN NUMBER,
       i_fcp_src_ind   IN hcrs.prfl_prod_calc_t.fcp_src_ind%TYPE := NULL,
       i_carry_fwd_ind IN hcrs.prfl_prod_calc_t.carry_fwd_ind%TYPE := NULL);

   PROCEDURE p_comp_val_add
      (i_comp_typ_cd IN hcrs.comp_typ_t.comp_typ_cd%TYPE,
       i_amt         IN NUMBER);

   FUNCTION f_comp_val_get
      (i_comp_typ_cd IN hcrs.comp_typ_t.comp_typ_cd%TYPE)
      RETURN NUMBER;

   PROCEDURE p_comp_val_save;

   FUNCTION f_get_cust_loc_cd_list
      (i_mode             IN VARCHAR2,
       i_domestic_ind     IN hcrs.prfl_prod_calc_comp_def_wrk_t.cust_domestic_ind%TYPE,
       i_territory_ind    IN hcrs.prfl_prod_calc_comp_def_wrk_t.cust_territory_ind%TYPE,
       i_trans_typ_grp_cd IN hcrs.prfl_prod_calc_comp_def_wrk_t.trans_typ_grp_cd%TYPE := NULL)
      RETURN VARCHAR2;

   FUNCTION f_fe_bndl_init
      (i_bndl_strt_dt      IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_strt_dt%TYPE,
       i_bndl_end_dt       IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_end_dt%TYPE,
       i_bndl_prcg_prd_off IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_prcg_prd_off%TYPE,
       i_bndl_prcg_prd_len IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_prcg_prd_len%TYPE,
       i_bndl_perf_prd_off IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_perf_prd_off%TYPE,
       i_bndl_perf_prd_len IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_perf_prd_len%TYPE,
       i_bndl_prd_unit     IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_prd_unit%TYPE,
       i_bndl_addl_txt     IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_addl_txt%TYPE,
       i_bndl_addl_val     IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_addl_val%TYPE)
      RETURN NUMBER;

   FUNCTION f_fe_bndl_cleanup
      RETURN NUMBER;

   PROCEDURE p_create_prod_price_tbl
      (i_param_rec         IN     t_calc_param_rec,
       i_prod_price_typ_cd IN     hcrs.prod_price_typ_t.prod_price_typ_cd%TYPE,
       io_price_tbl        IN OUT t_prod_price_tbl,
       i_unit_per_pckg     IN     hcrs.prod_mstr_t.unit_per_pckg%TYPE := NULL);

   PROCEDURE p_create_amp_nd_tbl
      (i_param_rec     IN     t_calc_param_rec,
       io_nd_tbl       IN OUT t_price_tbl,
       i_unit_per_pckg IN     hcrs.prod_mstr_t.unit_per_pckg%TYPE := NULL);

   PROCEDURE p_calc_delete
      (i_calc_log_user_msg IN hcrs.prfl_prod_t.user_msg_txt%TYPE := NULL);

   PROCEDURE p_init_calc_debug
      (i_prfl_id         IN hcrs.prfl_prod_wrk_t.prfl_id%TYPE,
       i_ndc_lbl         IN hcrs.prfl_prod_wrk_t.ndc_lbl%TYPE,
       i_ndc_prod        IN hcrs.prfl_prod_wrk_t.ndc_prod%TYPE,
       i_ndc_pckg        IN hcrs.prfl_prod_wrk_t.ndc_pckg%TYPE,
       i_calc_typ_cd     IN hcrs.prfl_prod_wrk_t.calc_typ_cd%TYPE,
       i_disable_nom_chk IN hcrs.prfl_prod_wrk_t.chk_nom%TYPE := pkg_constants.cs_flag_no,
       i_disable_hhs_chk IN hcrs.prfl_prod_wrk_t.chk_hhs%TYPE := pkg_constants.cs_flag_no);

   PROCEDURE p_common_initialize
      (i_job_name    IN  VARCHAR2,
       i_calc_typ_cd IN  hcrs.calc_typ_t.calc_typ_cd%TYPE,
       i_ndc_lbl     IN  hcrs.prod_mstr_t.ndc_lbl%TYPE,
       i_ndc_prod    IN  hcrs.prod_mstr_t.ndc_prod%TYPE,
       i_ndc_pckg    IN  hcrs.prod_mstr_t.ndc_pckg%TYPE,
       o_param_rec   OUT t_calc_param_rec,
       i_queue_id    IN  VARCHAR2,
       i_clr_cmt_txt IN  VARCHAR2 := pkg_constants.cs_flag_yes);

   PROCEDURE p_insert_trnsmsn_price
      (i_prfl_id     IN hcrs.prfl_prod_calc_t.prfl_id%TYPE,
       i_ndc_lbl     IN hcrs.prfl_prod_calc_t.ndc_lbl%TYPE,
       i_ndc_prod    IN hcrs.prfl_prod_calc_t.ndc_prod%TYPE,
       i_calc_typ_cd IN hcrs.prfl_prod_calc_t.calc_typ_cd%TYPE,
       i_calc_amt    IN hcrs.prfl_prod_calc_t.calc_amt%TYPE);

   PROCEDURE p_ins_bp_rows
      (i_prfl_id       IN hcrs.prfl_t.prfl_id%TYPE,
       i_ndc_lbl       IN hcrs.prod_mstr_t.ndc_lbl%TYPE,
       i_ndc_prod      IN hcrs.prod_mstr_t.ndc_prod%TYPE,
       i_carry_fwd_ind IN hcrs.prfl_prod_calc_t.carry_fwd_ind%TYPE := NULL);

   PROCEDURE p_ins_price_pnt
      (i_prfl_id        IN hcrs.prfl_t.prfl_id%TYPE,
       i_ndc_lbl        IN hcrs.prod_mstr_t.ndc_lbl%TYPE,
       i_ndc_prod       IN hcrs.prod_mstr_t.ndc_prod%TYPE,
       i_comp_typ_cd    IN hcrs.comp_typ_t.comp_typ_cd%TYPE,
       i_price          IN NUMBER,
       i_bp_ind         IN hcrs.prfl_prod_bp_pnt_t.bp_ind%TYPE := NULL,
       i_cmt_txt        IN hcrs.prfl_prod_bp_pnt_t.cmt_txt%TYPE := NULL,
       i_manual_add_ind IN hcrs.prfl_prod_bp_pnt_t.manual_add_ind%TYPE := NULL,
       i_allow_null_cmt IN VARCHAR2 := NULL,
       i_commit         IN VARCHAR2 := pkg_constants.cs_flag_yes);

   PROCEDURE p_set_bndl_cust
      (i_cust_id IN hcrs.prfl_prod_bndl_smry_wrk_t.cust_id%TYPE);

   FUNCTION f_get_bndl_cust
      (i_cond_cd IN hcrs.prfl_prod_bndl_dts_wrk_t.cond_cd%TYPE := NULL)
      RETURN hcrs.bndl_cust_tbl_typ
      PIPELINED;

   PROCEDURE p_add_bndl_trans_id
      (i_trans_id     IN hcrs.prfl_prod_bndl_cp_trns_wrk_t.trans_id%TYPE,
       i_trans_cls_cd IN hcrs.prfl_prod_bndl_smry_wrk_t.trans_cls_cd%TYPE,
       i_dllrs_dsc    IN hcrs.prfl_prod_bndl_cp_trns_wrk_t.dllrs_dsc%TYPE,
       i_trans_idx    IN NUMBER := NULL);

   PROCEDURE p_del_bndl_trans_id;

   FUNCTION f_get_bndl_trans_ids
      RETURN hcrs.bndl_trans_id_tbl_typ
      PIPELINED;

   PROCEDURE p_get_calc_trans
      (i_nd_tbl      IN t_price_tbl,
       i_no_mark_rec IN BOOLEAN := FALSE,
       i_step        IN NUMBER := NULL,
       i_steps       IN NUMBER := NULL);

END pkg_common_procedures;
/
CREATE OR REPLACE PACKAGE BODY pkg_common_procedures
AS
   cs_src_pkg    CONSTANT hcrs.error_log_t.src_cd%TYPE := 'pkg_common_procedures';

   -- %TYPE Anchor variables
   gv_calc_log_txt                  VARCHAR2( 30);

   -- Transaction Amount Definition Constants
   cs_trns_amt_comp                 CONSTANT VARCHAR2( 20) := 'COMP'; -- Main Component values
   cs_trns_amt_nom_chk              CONSTANT VARCHAR2( 20) := 'NOM_CHK'; -- Nominal check values
   cs_trns_amt_hhs_chk              CONSTANT VARCHAR2( 20) := 'HHS_CHK'; -- HHS check values

   -- Calculation constants
   cs_calc_shutdown_interval        CONSTANT NUMBER := 6000; -- In 100ths of seconds
   cs_calc_shutdown_timer           CONSTANT VARCHAR2( 20) := 'CALC_SHUTDOWN';
   cs_qry_main                      CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'MAIN'; -- Main query

   -- Calc Log Constants
   cs_calc_log_timer_last_update    CONSTANT hcrs.pkg_utils.gv_timer_id%TYPE := 'CALC_LOG_LAST_UPDATE';
   cs_calc_log_show_time_remain     CONSTANT BOOLEAN := FALSE; -- Show remaining time in user message

   -- Calc Log Format Constants
   cs_calc_log_txt_comp_cd          CONSTANT gv_calc_log_txt%TYPE := '##COMP##';
   cs_calc_log_txt_done             CONSTANT gv_calc_log_txt%TYPE := '##DONE##';
   cs_calc_log_txt_total            CONSTANT gv_calc_log_txt%TYPE := '##TOTAL##';
   cs_calc_log_txt_done_total       CONSTANT gv_calc_log_txt%TYPE := '##DONE_TOTAL##';
   cs_calc_log_txt_remain           CONSTANT gv_calc_log_txt%TYPE := '##REMAIN##';
   cs_calc_log_fmt_num              CONSTANT gv_calc_log_txt%TYPE := 'FM999,999,999,999,999';
   cs_calc_log_fmt_time             CONSTANT gv_calc_log_txt%TYPE := 'HH24:MI:SS';

   -- Calc Log Counter Constants
   cs_calc_log_cntr_rows            CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'ROWS';          -- Main cursor rows loop counter
   cs_calc_log_cntr_rows_marked     CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'MARK';          -- Main cursor marked row count counter
   cs_calc_log_cntr_links           CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'LINKS';         -- Main cursor linked trans count counter
   cs_calc_log_cntr_tbls            CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'TBLS';          -- Calc Delete table loop counter (not in calc log)
   cs_calc_log_cntr_tbl_rows        CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'TBL_ROWS';      -- Calc Delete table row loop counter (not in calc log)
   cs_calc_log_cntr_custs           CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'CUSTS';         -- Main cursor customer count counter
   cs_calc_log_cntr_cust_rows       CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'CUST_ROWS';     -- Main cursor customer row count counter
   cs_calc_log_cntr_cust_rows_max   CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'CUST_ROWS_MAX'; -- Main cursor maximum customer row count counter
   cs_calc_log_cntr_bndl_cust_cnt   CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'BNDL_CUST_CNT'; -- Bundled customer count counter
   cs_calc_log_cntr_bndl_trn_rows   CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'BNDL_TRN_ROWS'; -- Bundled trans count counter
   cs_calc_log_cntr_bndl_cfg_exec   CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'BNDL_CFG_EXEC'; -- Bundled config query execution count counter
   cs_calc_log_cntr_bndl_cfg_rows   CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'BNDL_CFG_ROWS'; -- Bundled config query row count counter
   cs_calc_log_cntr_bndl_cfg_time   CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'BNDL_CFG_TIME'; -- Bundled config query timer counter
   cs_calc_log_cntr_bndl_adj_exec   CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'BNDL_ADJ_EXEC'; -- Bundled adjustment query execution count counter
   cs_calc_log_cntr_bndl_adj_rows   CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'BNDL_ADJ_ROWS'; -- Bundled adjustment query row count counter
   cs_calc_log_cntr_bndl_adj_time   CONSTANT hcrs.pkg_utils.gv_counter_id%TYPE := 'BNDL_ADJ_TIME'; -- Bundled adjustment query timer counter

   -- Component value record and table
   TYPE t_comp_val_rec IS RECORD
      (comp_typ_cd    hcrs.comp_typ_t.comp_typ_cd%TYPE,
       amt            NUMBER := 0,
       comp_dllrs     hcrs.prfl_prod_calc_comp_def_t.comp_dllrs%TYPE,
       trans_dt_range hcrs.prfl_prod_calc_comp_def_t.trans_dt_range%TYPE,
       trans_comp     BOOLEAN,
       fcp_src_ind    hcrs.prfl_prod_calc_t.fcp_src_ind%TYPE,
       carry_fwd_ind  hcrs.prfl_prod_calc_t.carry_fwd_ind%TYPE);
   TYPE t_comp_val_tbl IS TABLE OF t_comp_val_rec INDEX BY hcrs.comp_typ_t.comp_typ_cd%TYPE;

   -- Record to carry the total dollars and units for a transaction group
   TYPE t_calc_total_rec IS RECORD
      (trans_cls_cd   hcrs.mstr_trans_t.trans_cls_cd%TYPE,
       source_sys_cde hcrs.mstr_trans_t.source_sys_cde%TYPE,
       dllrs_grs      NUMBER,
       dllrs_wac      NUMBER,
       dllrs_net      NUMBER,
       dllrs_dsc      NUMBER,
       dllrs_ppd      NUMBER,
       pkgs           NUMBER,
       units          NUMBER);

   -- Marked transaction cache table (full data to write to db)
   TYPE t_mark_rec IS RECORD
      (prfl_id          hcrs.prfl_prod_comp_trans_t.prfl_id%TYPE,
       ndc_lbl          hcrs.prfl_prod_comp_trans_t.ndc_lbl%TYPE,
       ndc_prod         hcrs.prfl_prod_comp_trans_t.ndc_prod%TYPE,
       ndc_pckg         hcrs.prfl_prod_comp_trans_t.ndc_pckg%TYPE,
       calc_typ_cd      hcrs.prfl_prod_comp_trans_t.calc_typ_cd%TYPE,
       comp_typ_cd      hcrs.prfl_prod_comp_trans_t.comp_typ_cd%TYPE,
       trans_id         hcrs.prfl_prod_comp_trans_t.trans_id%TYPE,
       price_pnt_seq_no hcrs.bp_pnt_trans_dtl_t.price_pnt_seq_no%TYPE,
       co_id            hcrs.prfl_prod_comp_trans_t.co_id%TYPE,
       cls_of_trd_cd    hcrs.prfl_prod_comp_trans_t.cls_of_trd_cd%TYPE,
       trans_adj_cd     hcrs.prfl_prod_comp_trans_t.trans_adj_cd%TYPE,
       root_trans_id    hcrs.prfl_prod_comp_trans_t.root_trans_id%TYPE,
       parent_trans_id  hcrs.prfl_prod_comp_trans_t.parent_trans_id%TYPE,
       trans_dt         hcrs.prfl_prod_comp_trans_t.trans_dt%TYPE,
       dllr_amt         hcrs.prfl_prod_comp_trans_t.dllr_amt%TYPE,
       pkg_qty          hcrs.prfl_prod_comp_trans_t.pkg_qty%TYPE,
       chrgbck_amt      hcrs.prfl_prod_comp_trans_t.chrgbck_amt%TYPE,
       term_disc_pct    hcrs.prfl_prod_comp_trans_t.term_disc_pct%TYPE,
       nom_dllr_amt     hcrs.prfl_prod_comp_trans_t.nom_dllr_amt%TYPE,
       nom_pkg_qty      hcrs.prfl_prod_comp_trans_t.nom_pkg_qty%TYPE,
       splt_pct_typ     hcrs.prfl_prod_comp_trans_t.splt_pct_typ%TYPE,
       splt_pct_seq_no  hcrs.prfl_prod_comp_trans_t.splt_pct_seq_no%TYPE,
       bndl_cd          hcrs.prfl_prod_comp_trans_t.bndl_cd%TYPE,
       bndl_seq_no      hcrs.prfl_prod_comp_trans_t.bndl_seq_no%TYPE);
   TYPE t_mark_tbl IS TABLE OF t_mark_rec INDEX BY BINARY_INTEGER;

   -- Marked transaction cache table (all transactions marked by components)
   TYPE t_mark_id_tbl IS TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(100);

   -- Marked nominal transaction cache table (full data to write to db)
   TYPE t_mark_nom_rec IS RECORD
      (prfl_id         hcrs.prfl_sls_excl_t.prfl_id%TYPE,
       trans_id        hcrs.prfl_sls_excl_t.trans_id%TYPE,
       co_id           hcrs.prfl_sls_excl_t.co_id%TYPE,
       cls_of_trd_cd   hcrs.prfl_sls_excl_t.cls_of_trd_cd%TYPE,
       over_ind        hcrs.prfl_sls_excl_t.over_ind%TYPE,
       apprvd_ind      hcrs.prfl_sls_excl_t.apprvd_ind%TYPE,
       apprvd_dt       hcrs.prfl_sls_excl_t.apprvd_dt%TYPE,
       apprvd_by       hcrs.prfl_sls_excl_t.apprvd_by%TYPE,
       adj_cnt         hcrs.prfl_sls_excl_t.adj_cnt%TYPE,
       adj_pkg_qty     hcrs.prfl_sls_excl_t.adj_pkg_qty%TYPE,
       adj_total_amt   hcrs.prfl_sls_excl_t.adj_total_amt%TYPE,
       nmnl_thres_amt  hcrs.prfl_sls_excl_t.nmnl_thres_amt%TYPE,
       trans_adj_cd    hcrs.prfl_sls_excl_t.trans_adj_cd%TYPE,
       root_trans_id   hcrs.prfl_sls_excl_t.root_trans_id%TYPE,
       parent_trans_id hcrs.prfl_sls_excl_t.parent_trans_id%TYPE,
       trans_dt        hcrs.prfl_sls_excl_t.trans_dt%TYPE,
       dllr_amt        hcrs.prfl_sls_excl_t.dllr_amt%TYPE,
       pkg_qty         hcrs.prfl_sls_excl_t.pkg_qty%TYPE,
       chrgbck_amt     hcrs.prfl_sls_excl_t.chrgbck_amt%TYPE,
       term_disc_pct   hcrs.prfl_sls_excl_t.term_disc_pct%TYPE,
       nom_dllr_amt    hcrs.prfl_sls_excl_t.nom_dllr_amt%TYPE,
       nom_pkg_qty     hcrs.prfl_sls_excl_t.nom_pkg_qty%TYPE,
       splt_pct_typ    hcrs.prfl_sls_excl_t.splt_pct_typ%TYPE,
       splt_pct_seq_no hcrs.prfl_sls_excl_t.splt_pct_seq_no%TYPE,
       bndl_cd         hcrs.prfl_sls_excl_t.bndl_cd%TYPE,
       bndl_seq_no     hcrs.prfl_sls_excl_t.bndl_seq_no%TYPE,
       cmt_txt         hcrs.prfl_sls_excl_t.cmt_txt%TYPE);
   TYPE t_mark_nom_tbl IS TABLE OF t_mark_nom_rec INDEX BY BINARY_INTEGER;

   -- Marked nominal transaction cache table (all transactions marked as nominal)
   TYPE t_mark_nom_id_tbl IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

   -- Processed Customer table
   TYPE t_cust_id_tbl IS TABLE OF NUMBER INDEX BY hcrs.cust_t.cust_id%TYPE;

   -- Transaction class bundles table (to apply to a transaction)
   TYPE t_trans_cls_bndl_rec IS RECORD
      (bndl_cd         hcrs.prfl_prod_bndl_smry_wrk_t.bndl_cd%TYPE,
       trans_idx       BINARY_INTEGER,
       trans_dllrs_dsc hcrs.prfl_prod_bndl_smry_wrk_t.prcg_dllrs_dsc%TYPE,
       dsc_pct         hcrs.prfl_prod_bndl_smry_wrk_t.prcg_dllrs_dsc%TYPE);
   TYPE t_trans_cls_bndl_tbl IS TABLE OF t_trans_cls_bndl_rec INDEX BY VARCHAR2( 100);

   -- CALC DEBUG MODE settings - prevent error handler from writing to the database in Debug Mode
   gv_calc_debug_mode              BOOLEAN := FALSE; -- Set to TRUE when in debug mode
   gv_calc_debug_disable_nom_chk   BOOLEAN := FALSE; -- Debug mode Override for Calculation Nominal Check setting
   gv_calc_debug_disable_hhs_chk   BOOLEAN := FALSE; -- Debug mode Override for Calculation HHS Violation Check setting

   -- Indicates if the calc is running from p_common_initialize
   gv_calc_running                 BOOLEAN := FALSE;

   -- Indicates if the calc delete is running from p_calc_delete
   gv_calc_delete_running          BOOLEAN := FALSE;

   -- Calculation caches for parameters, component values,
   -- Nominal pricing, PL 102 pricing, Customer IDs
   gv_param_rec                    t_calc_param_rec;
   gv_comp_val_tbl                 t_comp_val_tbl;
   gv_nd_tbl                       t_price_tbl;
   gv_pl102_tbl                    t_prod_price_tbl;
   gv_cust_id_tbl                  t_cust_id_tbl;

   -- Marked records cache, ID lookup, customer ID
   gv_mark_tbl                     t_mark_tbl;
   gv_mark_id_tbl                  t_mark_id_tbl;
   gv_mark_cust_id                 hcrs.prfl_cust_cls_of_trd_t.cust_id%TYPE;
   gv_mark_cust_row_cnt_max        NUMBER;

   -- Marked nominal records cache, ID lookup
   gv_mark_nom_tbl                 t_mark_nom_tbl;
   gv_mark_nom_id_tbl              t_mark_nom_id_tbl;

   -- These variables are used to short circuit the calculation processes as needed
   gv_bndl_use_dra_prod            BOOLEAN := TRUE; -- Enable product bundles
   gv_bndl_use_dra_time            BOOLEAN := TRUE; -- Enable temporal bundles
   gv_bndl_config                  BOOLEAN := TRUE; -- Run p_bndl_trans step to configure the bundling data
   gv_bndl_apply                   BOOLEAN := TRUE; -- Run p_bndl_trans step to apply the bundling adjustment
   gv_bndl_trans                   BOOLEAN := TRUE; -- Run p_bndl_trans step to determine the component for a trans
   gv_accum_trans                  BOOLEAN := TRUE; -- Run p_accum_trans step to accumulate the trans in the component
   gv_mark_records                 BOOLEAN := TRUE; -- Run p_mark_record to create the calculation audit trail

   -- These variables track the bundling customer to short circuit the bundling process where possible
   -- This variable tracks bundling customers to short circuit the bundling process where possible
   -- Key is customer ID, existance = evaluated for bundling, TRUE = has bundles, FALSE = no bundles
   gv_bndl_cust_id_tbl             t_cust_id_tbl;                                              -- Bundled Processed main customers
   gv_bndl_cust_tbl                hcrs.bndl_cust_tbl_typ := hcrs.bndl_cust_tbl_typ();         -- Customer for config query
   gv_bndl_cust_cond_cnt           NUMBER;                                                     -- >0 If bundle condition overrides found
   gv_bndl_trans_ids               hcrs.bndl_trans_id_tbl_typ := hcrs.bndl_trans_id_tbl_typ(); -- Transactions for adj query

   -- These variables track bundling statistics for storage
   gv_bndl_ind                     hcrs.prfl_calc_prod_t.bndl_ind%TYPE := pkg_constants.cs_flag_yes;
   gv_bndl_dts_cnt                 hcrs.prfl_calc_prod_t.bndl_dts_cnt%TYPE := 0;
   gv_bndl_smry_cnt                hcrs.prfl_calc_prod_t.bndl_smry_cnt%TYPE := 0;
   gv_bndl_trans_cnt               hcrs.prfl_calc_prod_t.bndl_trans_cnt%TYPE := 0;
   gv_bndl_adj_cnt                 hcrs.prfl_calc_prod_t.bndl_adj_cnt%TYPE := 0;

   -- Commit Counter
   gv_commit_ctr                   NUMBER := 0;

   -- Error Level for Resubmit Status
   gv_error_level                  NUMBER := NULL;

   -- These variables are used by the calc log for calculation monitoring
   gv_step_descr_txt_len           NUMBER;
   gv_user_msg_txt_len             NUMBER;
   gv_calc_log_run_seq             hcrs.prfl_prod_calc_log_t.run_seq%TYPE;
   gv_calc_log_step                hcrs.prfl_prod_calc_log_t.step%TYPE;
   gv_calc_log_module_name         hcrs.pkg_utils.gv_module_name%TYPE;

   -- These variables are used by the calc to control calc log call timings
   gv_calc_log_update_interval     NUMBER; -- Update interval in seconds, null or <= 0 means every call

   -- Dummy variable for functions that return number that are not needed
   gv_dummy                        NUMBER;


   FUNCTION f_log_errors
      (i_src_cd      IN hcrs.error_log_t.src_cd%TYPE,
       i_src_descr   IN hcrs.error_log_t.src_descr%TYPE,
       i_error_cd    IN hcrs.error_log_t.error_cd%TYPE,
       i_error_descr IN hcrs.error_log_t.error_descr%TYPE,
       i_cmt_txt     IN hcrs.error_log_t.cmt_txt%TYPE)
      RETURN NUMBER
   IS
      /*************************************************************************
      * Function Name : f_log_errors
      *  Input params : i_src_cd - Name of the calling module
      *               : i_src_descr - Description of the calling module
      *               : i_error_cd - SQL Error Code
      *               : i_error_descr - SQL Error Message
      *               : i_cmt_txt - Comments on the error
      * Output params : none
      *       Returns : NUMBER - error id
      *  Date Created : 03/01/2019
      *        Author : Joe Kidd
      *   Description : Logs errors into an error_log_t table but DOES NOT
      *                 ROLLBACK, re-raise errors, or make any other changes.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      --cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_log_errors';
      --cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Logs Errors';
      --cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while logging errors';
      v_error_id            hcrs.error_log_t.error_seq_id%TYPE := NULL;
   BEGIN
      v_error_id := pkg_utils.f_log_errors
                       (i_src_cd,
                        i_src_descr,
                        i_error_cd,
                        i_error_descr,
                        i_cmt_txt,
                        pkg_constants.var_prfl_id,
                        pkg_constants.var_queue_id,
                        pkg_constants.var_ndc_lbl,
                        pkg_constants.var_ndc_prod,
                        pkg_constants.var_ndc_pckg,
                        pkg_constants.var_calc_typ_cd);
      RETURN v_error_id;
   -- No exception handling in error logger
   --EXCEPTION
   --   WHEN OTHERS
   --   THEN
   --      p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
   --         'Fatal ' || cs_cmt_txt);
   END f_log_errors;


   PROCEDURE p_log_errors
      (i_src_cd      IN hcrs.error_log_t.src_cd%TYPE,
       i_src_descr   IN hcrs.error_log_t.src_descr%TYPE,
       i_error_cd    IN hcrs.error_log_t.error_cd%TYPE,
       i_error_descr IN hcrs.error_log_t.error_descr%TYPE,
       i_cmt_txt     IN hcrs.error_log_t.cmt_txt%TYPE)
   IS
      /*************************************************************************
      * Procedure Name : p_log_errors
      *   Input params : i_src_cd - Name of the calling module
      *                : i_src_descr - Description of the calling module
      *                : i_error_cd - SQL Error Code
      *                : i_error_descr - SQL Error Message
      *                : i_cmt_txt - Comments on the error
      *  Output params : None
      *   Date Created : 03/01/2019
      *         Author : Joe Kidd
      *    Description : Logs errors into an error_log_t table but DOES NOT
      *                  ROLLBACK, re-raise errors, or make any other changes.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      --cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_log_errors';
      --cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Logs errors into an error_log_t';
      --cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while logging errors into an error_log_t';
   BEGIN
      -- Insert into Log table
      gv_dummy := f_log_errors( i_src_cd, i_src_descr, i_error_cd, i_error_descr, i_cmt_txt);
   -- No exception handling in error logger
   --EXCEPTION
   --   WHEN OTHERS
   --   THEN
   --      p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
   --         'Fatal ' || cs_cmt_txt);
   END p_log_errors;


   PROCEDURE p_raise_errors
      (i_module_nam   IN hcrs.error_log_t.src_cd%TYPE,
       i_module_descr IN hcrs.error_log_t.src_descr%TYPE,
       i_error_cd     IN hcrs.error_log_t.error_cd%TYPE,
       i_error_msg    IN hcrs.error_log_t.error_descr%TYPE,
       i_cmt_txt      IN hcrs.error_log_t.cmt_txt%TYPE)
   IS
      /*************************************************************************
      * Procedure Name : p_raise_errors
      *   Input params : i_module_nam - Name of the Calling module
      *                : i_module_descr - Description of the module
      *                : i_error_cd - SQL Error Code
      *                : i_error_msg - SQL Error Message
      *                : i_cmt_txt - Any specific comments for the Error
      *  Output params : None
      *   Date Created : 10/02/2000
      *         Author : Venkata Darabala
      *    Description : Logs errors into an error_log_t table and will raise
      *                  an application error.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  01/30/2001  Bhaskar       Commented the call to P_update_all_product_status
      *                            Add call to p_update_product STatus for the running product
      *  02/14/2001  T. Zimmerman  Added ELSIF pkg_constants.var_atp_cd = pkg_constants.cs_atp_med_cd THEN
      *  02/04/2004  Joe Kidd      PICC 1167: Remove agency references
      *  10/26/2004  Joe Kidd      PICC 1311: Only resubmit calculations
      *  12/13/2006  Joe Kidd      PICC 1680: Trim Error Msg and Comments
      *  02/15/2007  Joe Kidd      PICC 1706: Replace literals with constants
      *  05/06/2009  Joe Kidd      PICC 2051: Remove rollback segment mgmt
      *  04/01/2011  Joe Kidd      CRQ-3921: Linking of CARS chargebacks
      *                            Process error call stack if populated
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Move error logging to separate procedures
      *                            Prevent error logging in Calc Debug mode
      *                            Remove unneeded global variables
      *************************************************************************/
      --cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_raise_errors';
      --cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Logs errors into an error_log_t';
      --cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while logging errors into an error_log_t';
      v_error_id            hcrs.error_log_t.error_seq_id%TYPE := 0;
      v_resubmit_cnt        NUMBER := 0;
      v_count               NUMBER := 0;
   BEGIN
      -- Rollback any database changes
      ROLLBACK;
      IF NOT gv_calc_debug_mode
      THEN
         -- Only log errors when NOT in Calculation debug mode
         -- Insert into Log table, Get Error ID
         v_error_id := f_log_errors( i_module_nam, i_module_descr, i_error_cd, i_error_msg, i_cmt_txt);
         IF pkg_constants.var_prfl_id IS NOT NULL
         THEN
            -- update profile status
            p_unlock_profile( pkg_constants.var_prfl_id);
            -- Check if this job can be resubmitted
            SELECT COUNT(*) cnt
              INTO v_count
              FROM hcrs.calc_prcss_typ_t cpt
             WHERE cpt.plsql_proc_nm = pkg_constants.var_job_exec_nm;
            IF  (    i_error_cd NOT IN (pkg_constants.cs_error_snapshot_too_old, -- IF Not ORA-1555
                                        pkg_constants.cs_error_deadlock) -- ORA-00060 Dead Lock
                 AND gv_error_level IS NULL)
              OR v_count = 0
            THEN
               -- Not a snapshot too old or deadlock error and error level has not been set
               -- or not an process that can be resubmitted.
               -- Call update product Status only if error level is NULL
               -- Call p_update_product_status to Error for a running product
               gv_dummy := pkg_common_functions.f_update_product_status
                              (pkg_constants.var_prfl_id,
                               pkg_constants.var_ndc_lbl,
                               pkg_constants.var_ndc_prod,
                               pkg_constants.var_ndc_pckg,
                               pkg_constants.cs_calc_error_status);
            ELSIF i_error_cd IN (pkg_constants.cs_error_snapshot_too_old, -- If ORA-1555 Error
                                 pkg_constants.cs_error_deadlock)
            THEN
               -- IF ora-0060 Error Dead Lock
               -- Get resubmit Count for the product
               IF pkg_constants.var_atp_pckg_lvl_ind = pkg_constants.cs_flag_no --var_atp_cd = pkg_constants.cs_atp_med_cd
               THEN
                  SELECT ppf.resub_cnt
                    INTO v_resubmit_cnt
                    FROM hcrs.prfl_prod_fmly_t ppf
                   WHERE ppf.prfl_id = pkg_constants.var_prfl_id
                     AND ppf.ndc_lbl = pkg_constants.var_ndc_lbl
                     AND ppf.ndc_prod = pkg_constants.var_ndc_prod;
               ELSE
                  SELECT pp.resub_cnt
                    INTO v_resubmit_cnt
                    FROM hcrs.prfl_prod_t pp
                   WHERE pp.prfl_id = pkg_constants.var_prfl_id
                     AND pp.ndc_lbl = pkg_constants.var_ndc_lbl
                     AND pp.ndc_prod = pkg_constants.var_ndc_prod
                     AND pp.ndc_pckg = pkg_constants.var_ndc_pckg;
               END IF;
               IF NVL( v_resubmit_cnt, 0) < pkg_constants.cs_max_resubmit
               THEN
                  -- Increment Error Level
                  gv_error_level := 1;
                  -- Increment the resubmit Counter
                  IF pkg_constants.var_atp_pckg_lvl_ind = pkg_constants.cs_flag_no --var_atp_cd = pkg_constants.cs_atp_med_cd
                  THEN
                     UPDATE hcrs.prfl_prod_fmly_t ppf
                        SET ppf.resub_cnt = NVL( ppf.resub_cnt, 0) + 1
                      WHERE ppf.prfl_id = pkg_constants.var_prfl_id
                        AND ppf.ndc_lbl = pkg_constants.var_ndc_lbl
                        AND ppf.ndc_prod = pkg_constants.var_ndc_prod;
                  ELSE
                     UPDATE hcrs.prfl_prod_t pp
                        SET pp.resub_cnt = NVL( pp.resub_cnt, 0) + 1
                      WHERE pp.prfl_id = pkg_constants.var_prfl_id
                        AND pp.ndc_lbl = pkg_constants.var_ndc_lbl
                        AND pp.ndc_prod = pkg_constants.var_ndc_prod
                        AND pp.ndc_pckg = pkg_constants.var_ndc_pckg;
                  END IF;
                  -- Ensure update of Prfl status to Locked
                  UPDATE prfl_t p
                     SET p.prfl_stat_cd = pkg_constants.cs_prfl_stat_locked_cd
                   WHERE prfl_id = pkg_constants.var_prfl_id
                     AND prfl_stat_cd NOT IN (pkg_constants.cs_prfl_stat_transmitted_cd,
                                              pkg_constants.cs_prfl_stat_locked_cd);
                  -- Call p_update_product_status to RESUBMITTED for a running product
                  gv_dummy := pkg_common_functions.f_update_product_status
                                 (pkg_constants.var_prfl_id,
                                  pkg_constants.var_ndc_lbl,
                                  pkg_constants.var_ndc_prod,
                                  pkg_constants.var_ndc_pckg,
                                  pkg_constants.cs_calc_resubmit_status);
                  -- Insert into Log table
                  p_log_errors
                     (i_module_nam,
                      i_module_descr,
                      0,
                      pkg_constants.cs_calc_resubmit_status,
                      pkg_constants.var_job_exec_nm || ' Product Resubmitted for Calculation by ' ||
                         pkg_constants.var_calc_typ_cd || ' - Calculation Module');
                  COMMIT;
                  -- Resubmit this job again
                  gv_dummy := pkg_gpcs_job.f_create_prod_job( pkg_constants.var_job_exec_nm);
               END IF; -- Resubmission
            END IF;
         END IF;
         -- Kill the Running job
         gv_dummy := pkg_gpcs_job.f_kill_job;
      END IF;
      -- Raise error again
      raise_application_error
         ('-20000',
          'Error ID : ' || v_error_id ||
          ', Module : ' || i_module_nam ||
          ', Message :' || i_error_msg);
   -- No exception handling in error logger
   --EXCEPTION
   --   WHEN OTHERS
   --   THEN
   --      p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
   --         'Fatal ' || cs_cmt_txt);
   END p_raise_errors;


   PROCEDURE p_reg_job_name
      (i_job_name IN VARCHAR2)
   IS
      /*************************************************************************
      * Procedure Name : p_reg_job_name
      *   Input params : i_job_name - Job Name
      *  Output params : None
      *   Date Created : 02/04/2005
      *         Author : Joe Kidd
      *    Description : Registers and begins a new job
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  05/06/2009  Joe Kidd      PICC 2051: Remove rollback segment mgmt
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_reg_job_name';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Registers and begins a new job';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while registering and beginning a new job';
   BEGIN
      -- initialize commit counter
      gv_commit_ctr := 0;
      -- Register the Job Name
      pkg_constants.var_job_exec_nm := i_job_name;
      -- Kill jobs which are failed or resubmitted
      gv_dummy := pkg_gpcs_job.f_kill_job;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_reg_job_name;


   PROCEDURE p_unlock_profile
      (i_prfl_id IN hcrs.prfl_prod_calc_t.prfl_id%TYPE)
   IS
      /*************************************************************************
      * Procedure Name : p_unlock_profile
      *   Input params : None
      *  Output params : None
      *   Date Created : 11/13/2000
      *         Author : Venkata Darabala
      *    Description : Update the profile status to READY from LOCKED
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  05/06/2009  Joe Kidd      PICC 2051: Remove rollback segment mgmt
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Rename from p_update_prfl_status
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_unlock_profile';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Update the profile status to READY from LOCKED';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while updating the profile status to READY from LOCKED';
   BEGIN
      UPDATE hcrs.prfl_t p
         SET p.prfl_stat_cd = pkg_constants.cs_prfl_stat_ready_cd,
             p.mod_by = USER,
             p.mod_dt = SYSDATE
       WHERE p.prfl_id = i_prfl_id
         AND p.prfl_stat_cd = pkg_constants.cs_prfl_stat_locked_cd
         AND NOT EXISTS
             (
               SELECT 1
                 FROM hcrs.prfl_prod_t pp
                WHERE pp.prfl_id = p.prfl_id
                  AND pp.calc_stat_cd IN (pkg_constants.cs_calc_submit_status,
                                          pkg_constants.cs_calc_run_status,
                                          pkg_constants.cs_calc_job_inserted_status,
                                          pkg_constants.cs_calc_delete_status,
                                          pkg_constants.cs_calc_resubmit_status)
             );
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_unlock_profile;


   FUNCTION f_is_calc_delete_running
      RETURN BOOLEAN
   IS
      /*************************************************************************
      * Function Name : f_is_calc_delete_running
      *  Input params : none
      * Output params : none
      *       Returns : BOOLEAN, TRUE if calc delete is running
      *  Date Created : 01/15/2018
      *        Author : Joe Kidd
      *   Description : Returns calc delete running state, without permitting
      *                 it to be changed by support debugging.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Add error handling
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_is_calc_delete_running';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Returns calc delete running state';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while returning calc delete running state';
   BEGIN
      RETURN NVL( gv_calc_delete_running, FALSE);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_is_calc_delete_running;


   FUNCTION f_is_calc_running
      RETURN BOOLEAN
   IS
      /*************************************************************************
      * Function Name : f_is_calc_running
      *  Input params : none
      * Output params : none
      *       Returns : BOOLEAN, TRUE if calculation is running
      *  Date Created : 01/15/2018
      *        Author : Joe Kidd
      *   Description : Returns calculation running state, without permitting
      *                 it to be changed by support debugging.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Add error handling
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_is_calc_running';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Returns calculation running state';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while returning calculation running state';
   BEGIN
      RETURN NVL( gv_calc_running, FALSE);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_is_calc_running;


   FUNCTION f_is_calc_running_vc
      RETURN VARCHAR2
   IS
      /*************************************************************************
      * Function Name : f_is_calc_running_vc
      *  Input params : none
      * Output params : none
      *       Returns : VARCHAR2, returns Y if calculation is running, else N
      *  Date Created : 03/18/2018
      *        Author : Joe Kidd
      *   Description : Returns calculation running state, without permitting
      *                 it to be changed by support debugging.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_is_calc_running_vc';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Returns calculation running state';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while returning calculation running state';
      v_calc_running        VARCHAR2( 1);
   BEGIN
      IF f_is_calc_running()
      THEN
         v_calc_running := pkg_constants.cs_flag_yes;
      ELSE
         v_calc_running := pkg_constants.cs_flag_no;
      END IF;
      RETURN v_calc_running;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_is_calc_running_vc;


   PROCEDURE p_update_user_msg
      (i_user_msg IN hcrs.prfl_prod_t.user_msg_txt%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_update_user_msg
      *   Input params : i_user_msg - user message for the UI
      *  Output params : None
      *   Date Created : 12/03/2018
      *         Author : Joe Kidd
      *    Description : Updates the user message for the UI
      *
      *                  This routine is an autonomous transaction.  It will
      *                  commit to the calc log regardless of the state of
      *                  the transaction in process when this routine was
      *                  called.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      ------------------------------
      PRAGMA AUTONOMOUS_TRANSACTION;
      ------------------------------
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_update_user_msg';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Updates the user message for the UI';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while updating the user message for the UI';
   BEGIN
      IF    f_is_calc_running()
         OR f_is_calc_delete_running()
      THEN
         -- Update User Message
         UPDATE hcrs.prfl_prod_t pp
            SET pp.user_msg_txt = i_user_msg
          WHERE pp.prfl_id = gv_param_rec.prfl_id
            AND pp.ndc_lbl = gv_param_rec.ndc_lbl
            AND pp.ndc_prod = gv_param_rec.ndc_prod
            AND pp.ndc_pckg = NVL( gv_param_rec.ndc_pckg, pp.ndc_pckg);
      END IF;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_update_user_msg;


   PROCEDURE p_chk_calc_shutdown
   IS
      /*************************************************************************
      * Procedure Name : p_chk_calc_shutdown
      *   Input params : None
      *  Output params : None
      *   Date Created : 03/02/2012
      *         Author : Joe Kidd
      *    Description : Checks if the running calculation should be shutdown
      *                  Checks every minute when called by commit procedure
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Fix timer bug
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Add user message for calc shutdown
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Remove parameters, use package global
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Use updated calc log procedures
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Move timer to pkg_utils, use calc running function
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_chk_calc_shutdown';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Checks if the running calculation should be shutdown';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while checking if the running calculation should be shutdown';
      v_cnt                 NUMBER;
   BEGIN
      -- If the calculation if running and
      -- this is the first check or the check interval has passed
      IF   f_is_calc_running()
       AND NVL( pkg_utils.f_timer_elapsed( cs_calc_shutdown_timer), cs_calc_shutdown_interval) >= cs_calc_shutdown_interval
      THEN
         -- Has the shutdown indicator been set on this product?
         SELECT COUNT(*)
           INTO v_cnt
           FROM hcrs.prfl_prod_t pp
          WHERE pp.prfl_id = gv_param_rec.prfl_id
            AND pp.ndc_lbl = gv_param_rec.ndc_lbl
            AND pp.ndc_prod = gv_param_rec.ndc_prod
            AND pp.ndc_pckg = NVL( gv_param_rec.ndc_pckg, pp.ndc_pckg)
            AND pp.shtdwn_ind = pkg_constants.cs_flag_yes;
         IF v_cnt > 0
         THEN
            -- It has been set, shutdown the calc
            -- Clear the shutdown indicator and commit to capture the change
            UPDATE hcrs.prfl_prod_t pp
               SET pp.shtdwn_ind = pkg_constants.cs_flag_no
             WHERE pp.prfl_id = gv_param_rec.prfl_id
               AND pp.ndc_lbl = gv_param_rec.ndc_lbl
               AND pp.ndc_prod = gv_param_rec.ndc_prod
               AND pp.ndc_pckg = NVL( gv_param_rec.ndc_pckg, pp.ndc_pckg)
               AND pp.shtdwn_ind = pkg_constants.cs_flag_yes;
            COMMIT;
            -- Raise an error to shutdown the calc
            p_update_user_msg( 'Calculation was ordered to shutdown');
            p_raise_errors( cs_src_cd, cs_src_descr, -20000,
               'Calculation was ordered to shutdown',
               'Calculation was ordered to shutdown');
         ELSE
            -- It has NOT been set, start the check timer
            pkg_utils.p_timer_start( cs_calc_shutdown_timer);
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_chk_calc_shutdown;


   PROCEDURE p_set_calc_shutdown
      (i_prfl_id  IN hcrs.prfl_prod_calc_t.prfl_id%TYPE,
       i_ndc_lbl  IN hcrs.prfl_prod_calc_t.ndc_lbl%TYPE := NULL,
       i_ndc_prod IN hcrs.prfl_prod_calc_t.ndc_prod%TYPE := NULL,
       i_ndc_pckg IN hcrs.prfl_prod_calc_t.ndc_pckg%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_set_calc_shutdown
      *   Input params : i_prfl_id - Profile ID
      *                : i_ndc_lbl - NDC Labeler, optional, means all if blank
      *                : i_ndc_prod - NDC Product, optional, means all if blank
      *                : i_ndc_pckg - NDC Package, optional, means all if blank
      *  Output params : None
      *   Date Created : 09/14/2011
      *         Author : Joe Kidd
      *    Description : Set calculation shutdown indicator on calculations that
      *                  are running or waiting to run.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Allow to set shutdown on entire profile for
      *                            running or submitted products
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_set_calc_shutdown';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Set calculation shutdown indicator';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while setting calculation shutdown indicator';
   BEGIN
      UPDATE hcrs.prfl_prod_t pp
         SET pp.shtdwn_ind = pkg_constants.cs_flag_yes
       WHERE pp.prfl_id = i_prfl_id
         AND pp.calc_stat_cd IN (pkg_constants.cs_calc_run_status,
                                 pkg_constants.cs_calc_job_inserted_status,
                                 pkg_constants.cs_calc_submit_status)
         AND pp.ndc_lbl LIKE NVL( i_ndc_lbl, '%')
         AND pp.ndc_prod LIKE DECODE( i_ndc_lbl, NULL, '%', NVL( i_ndc_prod, '%'))
         AND pp.ndc_pckg LIKE DECODE( i_ndc_lbl, NULL, '%',
                              DECODE( i_ndc_prod, NULL, '%', NVL( i_ndc_pckg, '%')));
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_set_calc_shutdown;


   PROCEDURE p_commit
      (i_ctr IN NUMBER := 1)
   IS
      /*************************************************************************
      * Procedure Name : p_commit
      *   Input params : i_ctr - record count
      *  Output params : None
      *   Date Created : 08/02/2001
      *         Author : Venkata Darabala
      *    Description : Commits records and Pins transaction to a RollBack Segment
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  07/19/2001  T. Zimmerman  Added Error handling
      *  12/01/2008  Joe Kidd      PICC 2009: GPCS Server Migration
      *                            Disable rollback mgmt for 10g
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Allow Calc shutdown when flagged
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Call new Calc shutdown proc every time
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Move commit counter into this package
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_commit';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Commits records and Pins transaction to a RollBack Segment';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while commiting records and pinning transaction to a RollBack Segment';
   BEGIN
      gv_commit_ctr := NVL( gv_commit_ctr, 0) + NVL( i_ctr, 1);
      IF gv_commit_ctr >= pkg_constants.cs_commit_point
      THEN
         -- Commit the transaction
         COMMIT;
         -- Reset the commit counter
         gv_commit_ctr := 0;
      END IF;
      -- Check if the calc should be shutdown
      p_chk_calc_shutdown;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_commit;


   PROCEDURE p_commit_force
   IS
      /*************************************************************************
      * Procedure Name : p_commit_force
      *   Input params : None
      *  Output params : None
      *   Date Created : 01/15/2018
      *         Author : Joe Kidd
      *    Description : Commits records and resets commit counter
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Call p_commit passing commit point
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_commit_force';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Forces a commits and resets commit counter';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while forcing a commits and resets commit counter';
   BEGIN
      -- Send commit point to force commit
      p_commit( pkg_constants.cs_commit_point);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_commit_force;


   PROCEDURE p_clear_cntrs
      (i_cntr_id IN hcrs.pkg_utils.gv_counter_id%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_clear_cntrs
      *   Input params : i_cntr_id - If passed, only clear this counter
      *  Output params : None
      *   Date Created : 03/01/2019
      *         Author : Joe Kidd
      *    Description : Clears the calc log counters
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_clear_cntrs';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Clears the calc log counters';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while clearing the calc log counters';
   BEGIN
      pkg_utils.p_counter_clear( cs_calc_log_cntr_rows, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_rows_marked, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_links, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_tbls, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_tbl_rows, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_custs, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_cust_rows, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_cust_rows_max, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_bndl_cust_cnt, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_bndl_trn_rows, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_bndl_cfg_exec, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_bndl_cfg_rows, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_bndl_cfg_time, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_bndl_adj_exec, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_bndl_adj_rows, i_cntr_id);
      pkg_utils.p_counter_clear( cs_calc_log_cntr_bndl_adj_time, i_cntr_id);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_clear_cntrs;


   PROCEDURE p_init_cntrs
      (i_cntr_id IN hcrs.pkg_utils.gv_counter_id%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_init_cntrs
      *   Input params : i_cntr_id - If passed, only modify this counter
      *  Output params : None
      *   Date Created : 01/15/2018
      *         Author : Joe Kidd
      *    Description : Initialize the calc log counters
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Renamed from p_init_longops_tbl
      *                            Move longops rountines to pkg_utils
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_init_cntrs';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Initialize the calc log counters';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while initializing the calc log counters';
   BEGIN
      pkg_utils.p_counter_init( cs_calc_log_cntr_rows, i_cntr_id, NULL, 'Rows', pkg_utils.cs_counter_type_loop, NULL, NULL, cs_calc_log_show_time_remain);
      pkg_utils.p_counter_init( cs_calc_log_cntr_rows_marked, i_cntr_id, NULL, 'Rows', pkg_utils.cs_counter_type_count);
      pkg_utils.p_counter_init( cs_calc_log_cntr_links, i_cntr_id, NULL, 'Rows', pkg_utils.cs_counter_type_count);
      pkg_utils.p_counter_init( cs_calc_log_cntr_tbls, i_cntr_id, NULL, 'Tables', pkg_utils.cs_counter_type_loop);
      pkg_utils.p_counter_init( cs_calc_log_cntr_tbl_rows, i_cntr_id, NULL, 'Table Rows', pkg_utils.cs_counter_type_loop);
      pkg_utils.p_counter_init( cs_calc_log_cntr_custs, i_cntr_id, NULL, 'Custs', pkg_utils.cs_counter_type_count);
      pkg_utils.p_counter_init( cs_calc_log_cntr_cust_rows, i_cntr_id, NULL, 'Rows', pkg_utils.cs_counter_type_count);
      pkg_utils.p_counter_init( cs_calc_log_cntr_cust_rows_max, i_cntr_id, NULL, 'Rows', pkg_utils.cs_counter_type_count);
      pkg_utils.p_counter_init( cs_calc_log_cntr_bndl_cust_cnt, i_cntr_id, NULL, 'Custs', pkg_utils.cs_counter_type_count);
      pkg_utils.p_counter_init( cs_calc_log_cntr_bndl_trn_rows, i_cntr_id, NULL, 'Rows', pkg_utils.cs_counter_type_count);
      pkg_utils.p_counter_init( cs_calc_log_cntr_bndl_cfg_exec, i_cntr_id, NULL, 'Execs', pkg_utils.cs_counter_type_count);
      pkg_utils.p_counter_init( cs_calc_log_cntr_bndl_cfg_rows, i_cntr_id, NULL, 'Rows', pkg_utils.cs_counter_type_count);
      pkg_utils.p_counter_init( cs_calc_log_cntr_bndl_cfg_time, i_cntr_id, NULL, 'CentSecs', pkg_utils.cs_counter_type_timer);
      pkg_utils.p_counter_init( cs_calc_log_cntr_bndl_adj_exec, i_cntr_id, NULL, 'Execs', pkg_utils.cs_counter_type_count);
      pkg_utils.p_counter_init( cs_calc_log_cntr_bndl_adj_rows, i_cntr_id, NULL, 'Rows', pkg_utils.cs_counter_type_count);
      pkg_utils.p_counter_init( cs_calc_log_cntr_bndl_adj_time, i_cntr_id, NULL, 'CentSecs', pkg_utils.cs_counter_type_timer);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_init_cntrs;


   PROCEDURE p_set_cntr
      (i_cntr_id IN hcrs.pkg_utils.gv_counter_id%TYPE,
       i_done    IN NUMBER := NULL,
       i_total   IN NUMBER := NULL,
       i_msg     IN hcrs.pkg_utils.gv_counter_msg%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_set_cntr
      *   Input params : i_cntr_id - counter identifier
      *                : i_done - value of counter, if i_total is null, this value
      *                :          will be added to the existing done value
      *                : i_total - top range of counter
      *                : i_msg - set the message if not already set
      *  Output params : None
      *   Date Created : 03/01/2019
      *         Author : Joe Kidd
      *    Description : Set the calc log counter values
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Renamed from p_set_longops_rec
      *                            Move longops rountines to pkg_utils
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_set_cntr';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Set the calc log counter values';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while setting the calc log counter values';
   BEGIN
       IF NOT pkg_utils.f_counter_exists( i_cntr_id)
       THEN
          -- Initialize counter if it doesn't exist
          p_init_cntrs( i_cntr_id);
       END IF;
       pkg_utils.p_counter_set( i_cntr_id, i_done, i_total, RTRIM( gv_calc_log_module_name || ', ' || NVL( i_msg, i_cntr_id), ', '));
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_set_cntr;


   FUNCTION f_get_calc_module
      (i_prfl_id     IN hcrs.prfl_calc_prod_t.prfl_id%TYPE,
       i_ndc_lbl     IN hcrs.prfl_calc_prod_t.ndc_lbl%TYPE,
       i_ndc_prod    IN hcrs.prfl_calc_prod_t.ndc_prod%TYPE,
       i_ndc_pckg    IN hcrs.prfl_calc_prod_t.ndc_prod%TYPE,
       i_calc_typ_cd IN hcrs.prfl_calc_prod_t.calc_typ_cd%TYPE)
      RETURN VARCHAR2
   IS
      /*************************************************************************
      * Function Name : f_get_calc_module
      *  Input params : i_prfl_id - profile
      *               : i_ndc_lbl - labeler
      *               : i_ndc_prod - product
      *               : i_ndc_pckg - package
      *               : i_calc_typ_cd - calc type code
      * Output params : none
      *       Returns : VARCHAR2 - The calc module
      *  Date Created : 03/01/2019
      *        Author : Joe Kidd
      *   Description : Gets the calc module
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_get_calc_module';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Gets the calc module';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while getting the calc module';
      v_module              pkg_utils.gv_module_name%TYPE;
   BEGIN
      v_module := RTRIM( i_calc_typ_cd || ', ' ||
                         i_prfl_id || ', ' ||
                         i_ndc_lbl || '-' ||
                         i_ndc_prod || '-' ||
                         i_ndc_pckg, ', -');
      RETURN v_module;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
         RETURN NULL;
   END f_get_calc_module;


   FUNCTION f_format_calc_log_step_descr
      (i_step_descr  IN hcrs.prfl_prod_calc_log_t.descr%TYPE,
       i_comp_typ_cd IN hcrs.prfl_prod_calc_log_t.comp_typ_cd%TYPE := NULL,
       i_rows_done   IN NUMBER := NULL,
       i_rows_total  IN NUMBER := NULL)
      RETURN VARCHAR2
   IS
      /*************************************************************************
      * Function Name : f_format_calc_log_step_descr
      *  Input params : i_step_descr - Step Description
      *               : i_comp_typ_cd - Component Type
      *               : i_rows_done - Rows Done
      *               : i_rows_total - Rows Total
      * Output params : None
      *       Returns : VARCHAR2, the formatted step description
      *  Date Created : 12/03/2018
      *        Author : Joe Kidd
      *   Description : Formats the Calc Log Step Description
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Split p_calc_log into many functions and procedures
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_format_calc_log_step_descr';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Formats the Calc Log Step Description';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while formatting the Calc Log Step Description';
      v_step_descr          hcrs.prfl_prod_calc_log_t.descr%TYPE;
   BEGIN
      IF i_step_descr IS NOT NULL
      THEN
         -----------------------------------------------------------------------
         -- Get length of step description column
         -----------------------------------------------------------------------
         IF gv_step_descr_txt_len IS NULL
         THEN
            SELECT c.data_length
              INTO gv_step_descr_txt_len
              FROM user_tab_columns c
             WHERE c.table_name = 'PRFL_PROD_CALC_LOG_T'
               AND c.column_name = 'DESCR';
         END IF;
         v_step_descr := SUBSTR( LTRIM( RTRIM( i_step_descr)), 1, gv_step_descr_txt_len);
         -----------------------------------------------------------------------
         -- Format the step description
         -----------------------------------------------------------------------
         -- Component type code
         v_step_descr := SUBSTR( REPLACE( v_step_descr, cs_calc_log_txt_comp_cd, i_comp_typ_cd), 1, gv_step_descr_txt_len);
         -- Rows done and rows total
         IF    i_rows_done >= 0
            OR i_rows_total >= 0
         THEN
            IF     i_rows_done >= 0
               AND i_rows_total >= 0
               AND v_step_descr LIKE '%' || cs_calc_log_txt_done_total || '%'
            THEN
               -- Replace rows done and rows total
               v_step_descr := SUBSTR( REPLACE( v_step_descr, cs_calc_log_txt_done_total, i_rows_done || ' / ' || i_rows_total), 1, gv_step_descr_txt_len);
            END IF;
            IF     i_rows_done >= 0
               AND v_step_descr LIKE '%' || cs_calc_log_txt_done || '%'
            THEN
               -- Replace rows done
               v_step_descr := SUBSTR( REPLACE( v_step_descr, cs_calc_log_txt_done, i_rows_done), 1, gv_step_descr_txt_len);
            END IF;
            IF     i_rows_total >= 0
               AND v_step_descr LIKE '%' || cs_calc_log_txt_total || '%'
            THEN
               -- Replace rows total
               v_step_descr := SUBSTR( REPLACE( v_step_descr, cs_calc_log_txt_total, i_rows_total), 1, gv_step_descr_txt_len);
            END IF;
            IF    ' ' || v_step_descr || ' ' LIKE '% ' || i_rows_done || ' %'
               OR ' ' || v_step_descr || ' ' LIKE '% ' || i_rows_total || ' %'
            THEN
               -- Skip, already formatted
               NULL;
            ELSIF  i_rows_done = 0
               AND i_rows_total >= 0
            THEN
               -- Add rows done if necessary
               v_step_descr := SUBSTR( v_step_descr || ' - ' || i_rows_done, 1, gv_step_descr_txt_len);
            ELSIF  i_rows_done > 0
               AND i_rows_total > 0
               AND i_rows_done < i_rows_total
            THEN
               -- Add rows done and rows total if necessary
               v_step_descr := SUBSTR( v_step_descr || ' - ' || i_rows_done || ' / ' || i_rows_total, 1, gv_step_descr_txt_len);
            ELSIF  i_rows_done > 0
               AND i_rows_done = i_rows_total
            THEN
               -- Add rows total if necessary
               v_step_descr := SUBSTR( v_step_descr || ' - ' || i_rows_total, 1, gv_step_descr_txt_len);
            END IF;
         END IF;
      END IF;
      RETURN v_step_descr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_format_calc_log_step_descr;


   FUNCTION f_format_calc_log_user_msg
      (i_user_msg    IN hcrs.prfl_prod_t.user_msg_txt%TYPE,
       i_comp_typ_cd IN hcrs.prfl_prod_calc_log_t.comp_typ_cd%TYPE := NULL,
       i_rows_done   IN NUMBER := NULL,
       i_rows_total  IN NUMBER := NULL,
       i_time_remain IN NUMBER := NULL)
      RETURN VARCHAR2
   IS
      /*************************************************************************
      * Function Name : f_format_calc_log_user_msg
      *  Input params : i_user_msg - User message
      *               : i_comp_typ_cd - Component Type
      *               : i_rows_done - Rows Done
      *               : i_rows_total - Rows Total
      * Output params : None
      *       Returns : VARCHAR2, the formatted user message
      *  Date Created : 12/03/2018
      *        Author : Joe Kidd
      *   Description : Formats the Calc Log User Message
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Split p_calc_log into many functions and procedures
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_format_calc_log_user_msg';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Formats the Calc Log User Message';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while formatting the Calc Log User Message';
      v_user_msg            hcrs.prfl_prod_t.user_msg_txt%TYPE;
      v_rows_done           hcrs.prfl_prod_t.user_msg_txt%TYPE;
      v_rows_total          hcrs.prfl_prod_t.user_msg_txt%TYPE;
      v_time_remain         NUMBER;
      v_time_remain_txt     hcrs.prfl_prod_t.user_msg_txt%TYPE;
   BEGIN
      IF i_user_msg IS NOT NULL
      THEN
         -----------------------------------------------------------------------
         -- Get length of user message column
         -----------------------------------------------------------------------
         IF gv_user_msg_txt_len IS NULL
         THEN
            SELECT c.data_length
              INTO gv_user_msg_txt_len
              FROM user_tab_columns c
             WHERE c.table_name = 'PRFL_PROD_T'
               AND c.column_name = 'USER_MSG_TXT';
         END IF;
         -----------------------------------------------------------------------
         -- Format the values
         -----------------------------------------------------------------------
         IF i_rows_done >= 0
         THEN
            v_rows_done := TO_CHAR( i_rows_done, cs_calc_log_fmt_num);
         END IF;
         IF i_rows_total >= 0
         THEN
            v_rows_total := TO_CHAR( i_rows_total, cs_calc_log_fmt_num);
         END IF;
         IF i_time_remain > 0
         THEN
            v_time_remain := i_time_remain / 86400;
            IF v_time_remain > 1
            THEN
               -- Add days
               v_time_remain_txt := SUBSTR( TRUNC( v_time_remain) || ':', 1, gv_user_msg_txt_len);
               v_time_remain := MOD( v_time_remain, 1);
            END IF;
            IF v_time_remain > 0
            THEN
               -- Add H:M:S, trim hours if zero
               v_time_remain_txt :=
                  SUBSTR( v_time_remain_txt ||
                          LTRIM( LTRIM( TO_CHAR( TRUNC( SYSDATE) + v_time_remain, cs_calc_log_fmt_time), '0'), ':'),
                          1, gv_user_msg_txt_len);
            END IF;
         END IF;
         -----------------------------------------------------------------------
         -- Format the user message
         -----------------------------------------------------------------------
         v_user_msg := SUBSTR( LTRIM( RTRIM( i_user_msg)), 1, gv_user_msg_txt_len);
         -- Component type code
         v_user_msg := SUBSTR( REPLACE( v_user_msg, cs_calc_log_txt_comp_cd, i_comp_typ_cd), 1, gv_user_msg_txt_len);
         -- Rows done, rows total
         IF    v_rows_done IS NOT NULL
            OR v_rows_total IS NOT NULL
         THEN
            IF     v_rows_done IS NOT NULL
               AND v_rows_total IS NOT NULL
               AND v_user_msg LIKE '%' || cs_calc_log_txt_done_total || '%'
            THEN
               -- Replace rows done and rows total
               v_user_msg := SUBSTR( REPLACE( v_user_msg, cs_calc_log_txt_done_total, v_rows_done || ' of ' || v_rows_total), 1, gv_user_msg_txt_len);
            END IF;
            IF     v_rows_done IS NOT NULL
               AND v_user_msg LIKE '%' || cs_calc_log_txt_done || '%'
            THEN
               -- Replace rows done
               v_user_msg := SUBSTR( REPLACE( v_user_msg, cs_calc_log_txt_done, v_rows_done), 1, gv_user_msg_txt_len);
            END IF;
            IF     v_rows_total IS NOT NULL
               AND v_user_msg LIKE '%' || cs_calc_log_txt_total || '%'
            THEN
               -- Replace rows total
               v_user_msg := SUBSTR( REPLACE( v_user_msg, cs_calc_log_txt_total, v_rows_total), 1, gv_user_msg_txt_len);
            END IF;
            IF    ' ' || v_user_msg || ' ' LIKE '% ' || i_rows_done || ' %'
               OR ' ' || v_user_msg || ' ' LIKE '% ' || i_rows_total || ' %'
               OR ' ' || v_user_msg || ' ' LIKE '% ' || v_rows_done || ' %'
               OR ' ' || v_user_msg || ' ' LIKE '% ' || v_rows_total || ' %'
            THEN
               -- Skip, already formatted
               NULL;
            ELSIF  v_rows_done IS NOT NULL
               AND v_rows_total IS NOT NULL
            THEN
               -- Add rows done and rows total
               v_user_msg := SUBSTR( v_user_msg || ', ' || v_rows_done || ' of ' || v_rows_total || ' rows', 1, gv_user_msg_txt_len);
            END IF;
         END IF;
         -- Time remaining
         IF v_time_remain_txt IS NOT NULL
         THEN
            IF v_user_msg LIKE '%' || cs_calc_log_txt_remain || '%'
            THEN
               -- Replace time remaining
               v_user_msg := SUBSTR( REPLACE( v_user_msg, cs_calc_log_txt_remain, v_time_remain_txt), 1, gv_user_msg_txt_len);
            END IF;
            IF ' ' || v_user_msg || ' ' LIKE '% ' || v_time_remain_txt || ' %'
            THEN
               -- Skip, already formatted
               NULL;
            ELSE
               -- Add time remaining
               v_user_msg := SUBSTR( v_user_msg || ', ' || v_time_remain_txt || ' remaining', 1, gv_user_msg_txt_len);
            END IF;
         END IF;
      END IF;
      RETURN v_user_msg;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_format_calc_log_user_msg;


   FUNCTION f_calc_log
      (i_step_descr   IN hcrs.prfl_prod_calc_log_t.descr%TYPE,
       i_user_msg     IN hcrs.prfl_prod_t.user_msg_txt%TYPE := NULL,
       i_comp_typ_cd  IN hcrs.prfl_prod_calc_log_t.comp_typ_cd%TYPE := NULL,
       i_rows_done    IN NUMBER := NULL,
       i_rows_total   IN NUMBER := NULL,
       i_force_update IN BOOLEAN := FALSE)
      RETURN VARCHAR2
   IS
      /*************************************************************************
      * Function Name : p_calc_log
      *  Input params : i_step_descr - Step Description
      *               : i_user_msg - User message for front end.
      *               : i_comp_typ_cd - Component Type
      *               : i_rows_done - Rows Done counter
      *               : i_rows_total - Rows Total counter
      *               : i_force_update - If TRUE, force an update
      * Output params : None
      *       Returns : VARCHAR2, the formatted step description
      *  Date Created : 12/03/2018
      *        Author : Joe Kidd
      *   Description : Sets calc log messages without writing to log.
      *                 Cannot start a new calculation
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  02/01/2005  Joe Kidd      PICC 1372, 1373, 1374:
      *                            Register actions with DBMS_APPLICATION_INFO
      *                            Add parameter to skip log writing
      *  05/18/2007  Joe Kidd      PICC 1769: Removed Select from dual
      *  12/01/2010  Joe Kidd      CRQ-931: December 2010 Govt Calculations Release
      *                            Add longops for calc monitoring
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Use pkg_utils App Info
      *                            Rename package global variables
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Add user message parameter and populate it
      *                            Add addititonal longops for calc delete
      *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
      *                            Add formatted counts to user message
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters, add more logging and longops items
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Split p_calc_log into many functions and procedures
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Add force update parameter, move timer to pkg_utils
      *                            Move longops rountines to pkg_utils
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_calc_log';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Sets calc log messages without writing to log';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while setting calc log messages without writing to log';
      v_step_descr          hcrs.prfl_prod_calc_log_t.descr%TYPE;
      v_user_msg            hcrs.prfl_prod_t.user_msg_txt%TYPE;
      v_rows_done           hcrs.prfl_prod_calc_log_t.rows_done%TYPE;
      v_rows_total          hcrs.prfl_prod_calc_log_t.rows_total%TYPE;
      v_time_remain         NUMBER;
   BEGIN
      IF    f_is_calc_running()
         OR f_is_calc_delete_running()
      THEN
         -----------------------------------------------------------------------
         -- Get the longops row count values
         -----------------------------------------------------------------------
         v_rows_done := NVL( i_rows_done, pkg_utils.f_counter_get_done( cs_calc_log_cntr_rows));
         v_rows_total := NVL( i_rows_total, pkg_utils.f_counter_get_total(cs_calc_log_cntr_rows));
         -----------------------------------------------------------------------
         -- If forcing an update, or the update interval is not positve,
         -- or it has passed, or the main counter is not running (v_rows_done)
         -----------------------------------------------------------------------
         IF    NVL( i_force_update, FALSE)
            OR NVL( gv_calc_log_update_interval, 0) <= 0
            OR COALESCE( pkg_utils.f_timer_elapsed( cs_calc_log_timer_last_update), gv_calc_log_update_interval * 100, 0) >=
                  NVL( gv_calc_log_update_interval * 100, 0)
            OR v_rows_done IS NULL
         THEN
            IF NVL( gv_calc_log_update_interval, 0) > 0
            THEN
               -- Update interval set, set last update time
               pkg_utils.p_timer_start( cs_calc_log_timer_last_update);
            END IF;
            -----------------------------------------------------------------------
            -- Update the longops
            -----------------------------------------------------------------------
            IF i_rows_done IS NULL
            THEN
               pkg_utils.p_counter_update();
               IF cs_calc_log_show_time_remain
               THEN
                  v_time_remain := pkg_utils.f_counter_get_remain( cs_calc_log_cntr_rows);
               END IF;
            END IF;
            -----------------------------------------------------------------------
            -- Format the description and user message
            -----------------------------------------------------------------------
            v_step_descr := f_format_calc_log_step_descr( i_step_descr, i_comp_typ_cd, v_rows_done, v_rows_total);
            v_user_msg := f_format_calc_log_user_msg( i_user_msg, i_comp_typ_cd, v_rows_done, v_rows_total, v_time_remain);
            -----------------------------------------------------------------------
            -- Register Calc in App Info
            -----------------------------------------------------------------------
            pkg_utils.p_appinfo_set( gv_calc_log_module_name, v_step_descr, '');
            -----------------------------------------------------------------------
            -- Update User Message
            -----------------------------------------------------------------------
            p_update_user_msg( v_user_msg);
         END IF;
      END IF;
      RETURN v_step_descr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_calc_log;


   PROCEDURE p_calc_log
      (i_step_descr  IN hcrs.prfl_prod_calc_log_t.descr%TYPE,
       i_user_msg    IN hcrs.prfl_prod_t.user_msg_txt%TYPE := NULL,
       i_comp_typ_cd IN hcrs.prfl_prod_calc_log_t.comp_typ_cd%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_calc_log
      *   Input params : i_step_descr - Step Description
      *                : i_user_msg - User message for front end.
      *                : i_comp_typ_cd - Component Type
      *  Output params : None
      *   Date Created : 12/03/2018
      *         Author : Joe Kidd
      *    Description : Sets calc log messages without writing to log.
      *                  Cannot start a new calculation
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Split p_calc_log into many functions and procedures
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_calc_log';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Sets calc log messages without writing to log';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while setting calc log messages without writing to log';
      v_dummy               hcrs.prfl_prod_calc_log_t.descr%TYPE;
   BEGIN
      v_dummy := f_calc_log( i_step_descr, i_user_msg, i_comp_typ_cd);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_calc_log;


   PROCEDURE p_calc_log_write
      (i_step_descr  IN hcrs.prfl_prod_calc_log_t.descr%TYPE,
       i_user_msg    IN hcrs.prfl_prod_t.user_msg_txt%TYPE := NULL,
       i_comp_typ_cd IN hcrs.prfl_prod_calc_log_t.comp_typ_cd%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_calc_log_write
      *   Input params : i_step_descr - Step Description
      *                : i_user_msg - User message for front end.
      *                : i_comp_typ_cd - Component Type
      *                : i_format_txt - Flag for other
      *  Output params : None
      *   Date Created : 12/03/2018
      *         Author : Joe Kidd
      *    Description : Writes messages to the calc log
      *                  Cannot start a new calculation
      *
      *                 This routine is an autonomous transaction.  It will
      *                 commit to the calc log regardless of the state of
      *                 the transaction in process when this routine was
      *                 called.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Split p_calc_log into many functions and procedures
      *  09/11/2019  JTronoski     CHG-132657: Issue with AMP Calculation
      *                            Calc log write failure, set last update to NULL
      *                            instead of zero to force an update
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Move timer to pkg_utils
      *                            Move longops rountines to pkg_utils
      *************************************************************************/
      ------------------------------
      PRAGMA AUTONOMOUS_TRANSACTION;
      ------------------------------
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_calc_log_write';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Writes messages to the calc log';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while writing messages to the calc log';
      v_rows_done           hcrs.prfl_prod_calc_log_t.rows_done%TYPE;
      v_rows_total          hcrs.prfl_prod_calc_log_t.rows_total%TYPE;
      v_rows_mark           hcrs.prfl_prod_calc_log_t.rows_mark%TYPE;
      v_rows_link           hcrs.prfl_prod_calc_log_t.rows_link%TYPE;
      v_cust_cnt            hcrs.prfl_prod_calc_log_t.cust_cnt%TYPE;
      v_bndl_cust_cnt       hcrs.prfl_prod_calc_log_t.bndl_cust_cnt%TYPE;
      v_bndl_trn_rows       hcrs.prfl_prod_calc_log_t.bndl_trn_rows%TYPE;
      v_bndl_cfg_exec       hcrs.prfl_prod_calc_log_t.bndl_cfg_exec%TYPE;
      v_bndl_cfg_rows       hcrs.prfl_prod_calc_log_t.bndl_cfg_rows%TYPE;
      v_bndl_cfg_time       hcrs.prfl_prod_calc_log_t.bndl_cfg_time%TYPE;
      v_bndl_adj_exec       hcrs.prfl_prod_calc_log_t.bndl_adj_exec%TYPE;
      v_bndl_adj_rows       hcrs.prfl_prod_calc_log_t.bndl_adj_rows%TYPE;
      v_bndl_adj_time       hcrs.prfl_prod_calc_log_t.bndl_adj_time%TYPE;
      v_step_descr          hcrs.prfl_prod_calc_log_t.descr%TYPE;
   BEGIN
      IF     f_is_calc_running()
         AND gv_calc_log_run_seq IS NOT NULL
         AND gv_calc_log_step IS NOT NULL
      THEN
         -----------------------------------------------------------------------
         -- Increment the step
         -----------------------------------------------------------------------
         gv_calc_log_step := gv_calc_log_step + 1;
         -----------------------------------------------------------------------
         -- Get the final longops values
         -----------------------------------------------------------------------
         v_rows_done := pkg_utils.f_counter_get_done( cs_calc_log_cntr_rows);
         v_rows_total := pkg_utils.f_counter_get_total(cs_calc_log_cntr_rows);
         IF     v_rows_done IS NOT NULL
            AND v_rows_total IS NOT NULL
         THEN
            -----------------------------------------------------------------------
            -- Add other attributes if rows are set
            -----------------------------------------------------------------------
            v_rows_mark := pkg_utils.f_counter_get_done( cs_calc_log_cntr_rows_marked);
            v_rows_link := pkg_utils.f_counter_get_done( cs_calc_log_cntr_links);
            v_cust_cnt := pkg_utils.f_counter_get_done( cs_calc_log_cntr_custs);
            v_bndl_cust_cnt := pkg_utils.f_counter_get_done( cs_calc_log_cntr_bndl_cust_cnt);
            v_bndl_trn_rows := pkg_utils.f_counter_get_done( cs_calc_log_cntr_bndl_trn_rows);
            v_bndl_cfg_exec := pkg_utils.f_counter_get_done( cs_calc_log_cntr_bndl_cfg_exec);
            v_bndl_cfg_rows := pkg_utils.f_counter_get_done( cs_calc_log_cntr_bndl_cfg_rows);
            v_bndl_cfg_time := pkg_utils.f_counter_get_done( cs_calc_log_cntr_bndl_cfg_time);
            v_bndl_adj_exec := pkg_utils.f_counter_get_done( cs_calc_log_cntr_bndl_adj_exec);
            v_bndl_adj_rows := pkg_utils.f_counter_get_done( cs_calc_log_cntr_bndl_adj_rows);
            v_bndl_adj_time := pkg_utils.f_counter_get_done( cs_calc_log_cntr_bndl_adj_time);
            IF v_rows_done = v_rows_total
            THEN
               -----------------------------------------------------------------------
               -- End the longops counters
               -----------------------------------------------------------------------
               pkg_utils.p_counter_update( NULL, TRUE);
            END IF;
         END IF;
         -----------------------------------------------------------------------
         -- Display the calc log messages (updates global step description)
         -----------------------------------------------------------------------
         v_step_descr := f_calc_log( i_step_descr, i_user_msg, i_comp_typ_cd, v_rows_done, v_rows_total, TRUE);
         -----------------------------------------------------------------------
         -- Write the log row
         -----------------------------------------------------------------------
         INSERT INTO hcrs.prfl_prod_calc_log_t
            (prfl_id,
             ndc_lbl,
             ndc_prod,
             ndc_pckg,
             calc_typ_cd,
             comp_typ_cd,
             run_seq,
             step,
             descr,
             rows_done,
             rows_total,
             rows_mark,
             rows_link,
             cust_cnt,
             bndl_cust_cnt,
             bndl_trn_rows,
             bndl_cfg_exec,
             bndl_cfg_rows,
             bndl_cfg_time,
             bndl_adj_exec,
             bndl_adj_rows,
             bndl_adj_time)
            VALUES
            (gv_param_rec.prfl_id,
             gv_param_rec.ndc_lbl,
             gv_param_rec.ndc_prod,
             gv_param_rec.ndc_pckg,
             gv_param_rec.calc_typ_cd,
             i_comp_typ_cd,
             gv_calc_log_run_seq,
             gv_calc_log_step,
             v_step_descr,
             v_rows_done,
             v_rows_total,
             v_rows_mark,
             v_rows_link,
             v_cust_cnt,
             v_bndl_cust_cnt,
             v_bndl_trn_rows,
             v_bndl_cfg_exec,
             v_bndl_cfg_rows,
             v_bndl_cfg_time,
             v_bndl_adj_exec,
             v_bndl_adj_rows,
             v_bndl_adj_time);
      END IF;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_calc_log_write;


   PROCEDURE p_calc_log_new_calc
   IS
      /*************************************************************************
      * Procedure Name : p_calc_log_new_calc
      *   Input params : None
      *  Output params : None
      *   Date Created : 12/03/2018
      *         Author : Joe Kidd
      *    Description : Starts a new calc, writes messages to calc log
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Split p_calc_log into many functions and procedures
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Move longops rountines to pkg_utils
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_calc_log_new_calc';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Starts a new calc, writes messages to calc log';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while starting a new calc, writing messages to calc log';
   BEGIN
      IF f_is_calc_running()
      THEN
         -----------------------------------------------------------------------
         -- Register New Calc in App Info
         -----------------------------------------------------------------------
         pkg_utils.p_appinfo_stk_push;
         gv_calc_log_module_name := f_get_calc_module( gv_param_rec.prfl_id,
                                                       gv_param_rec.ndc_lbl,
                                                       gv_param_rec.ndc_prod,
                                                       gv_param_rec.ndc_pckg,
                                                       gv_param_rec.calc_typ_cd);
         -----------------------------------------------------------------------
         -- Get new the run sequence
         -----------------------------------------------------------------------
         BEGIN
            SELECT MAX( ppcl.run_seq)
              INTO gv_calc_log_run_seq
              FROM hcrs.prfl_prod_calc_log_t ppcl
             WHERE ppcl.prfl_id = gv_param_rec.prfl_id
               AND ppcl.ndc_lbl = gv_param_rec.ndc_lbl
               AND ppcl.ndc_prod = gv_param_rec.ndc_prod
               AND (   (    gv_param_rec.ndc_pckg IS NULL
                        AND ppcl.ndc_pckg IS NULL)
                    OR (    gv_param_rec.ndc_pckg IS NOT NULL
                        AND ppcl.ndc_pckg = gv_param_rec.ndc_pckg))
               AND ppcl.calc_typ_cd = gv_param_rec.calc_typ_cd;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               gv_calc_log_run_seq := 0;
            WHEN OTHERS
            THEN
               p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
                  'Max run_seq query ' || cs_cmt_txt);
         END;
         -----------------------------------------------------------------------
         -- Increment the run sequence
         -----------------------------------------------------------------------
         gv_calc_log_run_seq := NVL( gv_calc_log_run_seq, 0) + 1;
         -----------------------------------------------------------------------
         -- Initialize the step
         -----------------------------------------------------------------------
         gv_calc_log_step := 0;
         -----------------------------------------------------------------------
         -- Clear and initialize longops counters
         -----------------------------------------------------------------------
         p_init_cntrs();
         -----------------------------------------------------------------------
         -- Write the calc start message to the log
         -----------------------------------------------------------------------
         p_calc_log_write( 'Calc Start', '', 'CALC');
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_calc_log_new_calc;


   PROCEDURE p_calc_log_end_calc
   IS
      /*************************************************************************
      * Procedure Name : p_calc_log_end_calc
      *   Input params : None
      *  Output params : None
      *   Date Created : 12/03/2018
      *         Author : Joe Kidd
      *    Description : Ends the calc, writes messages to calc log
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Split p_calc_log into many functions and procedures
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_calc_log_end_calc';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Ends the calc, writes messages to calc log';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while ending the calc, writes messages to calc log';
   BEGIN
      IF f_is_calc_running()
      THEN
         p_calc_log_write( 'Calc End', '', 'CALC');
         -----------------------------------------------------------------------
         -- Unregister Calc in App Info
         -----------------------------------------------------------------------
         pkg_utils.p_appinfo_stk_pop;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_calc_log_end_calc;


   PROCEDURE p_update_interim_table
      (i_prfl_id       IN hcrs.prfl_prod_calc_t.prfl_id%TYPE,
       i_ndc_lbl       IN hcrs.prfl_prod_calc_t.ndc_lbl%TYPE,
       i_ndc_prod      IN hcrs.prfl_prod_calc_t.ndc_prod%TYPE,
       i_ndc_pckg      IN hcrs.prfl_prod_calc_t.ndc_pckg%TYPE,
       i_calc_typ_cd   IN hcrs.prfl_prod_calc_t.calc_typ_cd%TYPE,
       i_comp_typ_cd   IN hcrs.prfl_prod_calc_t.comp_typ_cd%TYPE,
       i_calc_amt      IN hcrs.prfl_prod_calc_t.calc_amt%TYPE,
       i_fcp_src_ind   IN hcrs.prfl_prod_calc_t.fcp_src_ind%TYPE := NULL,
       i_carry_fwd_ind IN hcrs.prfl_prod_calc_t.carry_fwd_ind%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_update_interim_table
      *   Input params : i_prfl_id - Profile ID
      *                : i_ndc_lbl - NDC Labeler
      *                : i_ndc_prod - NDC Product
      *                : i_ndc_pckg - NDC Package
      *                : i_calc_typ_cd - Calculation code
      *                : i_comp_typ_cd - Component Code
      *                : i_calc_amt - Component Amount
      *                : i_fcp_src_ind - FCP source
      *                : i_carry_fwd_ind - Carry Forward Indicator
      *  Output params : None
      *   Date Created : 04/17/2007
      *         Author : Joe Kidd
      *    Description : Checks and inserts the data into interim table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  10/02/2015  Joe Kidd      CRQ-208647: Demand 6324: NonFamp/FCP Calc Modifications
      *                            Remove validation on FCP Source and Carry Forward
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_update_interim_table';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Checks and inserts the data into interim table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while checking and inserting the data into interim table';
   BEGIN
      IF gv_mark_records
      THEN
         IF i_ndc_pckg IS NOT NULL
         THEN
            -- This agency calcs at the pckg level
            -- Save component into pckg level table
            UPDATE hcrs.prfl_prod_calc_t ppc
               SET ppc.calc_amt = i_calc_amt,
                   ppc.carry_fwd_ind = i_carry_fwd_ind,
                   ppc.fcp_src_ind = i_fcp_src_ind
             WHERE ppc.prfl_id = i_prfl_id
               AND ppc.ndc_lbl = i_ndc_lbl
               AND ppc.ndc_prod = i_ndc_prod
               AND ppc.ndc_pckg = i_ndc_pckg
               AND ppc.calc_typ_cd = i_calc_typ_cd
               AND ppc.comp_typ_cd = i_comp_typ_cd;
            IF SQL%NOTFOUND
            THEN
               -- Insert the values if record is not found
               INSERT INTO hcrs.prfl_prod_calc_t
                  (prfl_id,
                   ndc_lbl,
                   ndc_prod,
                   ndc_pckg,
                   calc_typ_cd,
                   comp_typ_cd,
                   calc_amt,
                   carry_fwd_ind,
                   fcp_src_ind,
                   apprvd_ind)
                  VALUES
                  (i_prfl_id,
                   i_ndc_lbl,
                   i_ndc_prod,
                   i_ndc_pckg,
                   i_calc_typ_cd,
                   i_comp_typ_cd,
                   i_calc_amt,
                   i_carry_fwd_ind,
                   i_fcp_src_ind,
                   pkg_constants.cs_flag_no);
            END IF;
         ELSE
            -- This agency calcs at the product level
            -- Save component into prod level table
            UPDATE hcrs.prfl_prod_fmly_calc_t ppfc
               SET ppfc.calc_amt = i_calc_amt,
                   ppfc.carry_fwd_ind = i_carry_fwd_ind
             WHERE ppfc.prfl_id = i_prfl_id
               AND ppfc.ndc_lbl = i_ndc_lbl
               AND ppfc.ndc_prod = i_ndc_prod
               AND ppfc.calc_typ_cd = i_calc_typ_cd
               AND ppfc.comp_typ_cd = i_comp_typ_cd;
            -- Insert if the record not found
            IF SQL%NOTFOUND
            THEN
               INSERT INTO hcrs.prfl_prod_fmly_calc_t
                  (prfl_id,
                   ndc_lbl,
                   ndc_prod,
                   calc_typ_cd,
                   comp_typ_cd,
                   calc_amt,
                   carry_fwd_ind,
                   apprvd_ind)
                  VALUES
                  (i_prfl_id,
                   i_ndc_lbl,
                   i_ndc_prod,
                   i_calc_typ_cd,
                   i_comp_typ_cd,
                   i_calc_amt,
                   i_carry_fwd_ind,
                   pkg_constants.cs_flag_no);
            END IF;
            IF i_calc_typ_cd = i_comp_typ_cd
            THEN
               -- The calc type and component type are the same which means
               -- this component is the final result of the calc
               -- Save component into pckg level table
               UPDATE hcrs.prfl_prod_calc_t ppc
                  SET ppc.calc_amt = i_calc_amt,
                      ppc.carry_fwd_ind = i_carry_fwd_ind
                WHERE ppc.prfl_id = i_prfl_id
                  AND ppc.ndc_lbl = i_ndc_lbl
                  AND ppc.ndc_prod = i_ndc_prod
                  AND ppc.calc_typ_cd = i_calc_typ_cd
                  AND ppc.comp_typ_cd = i_comp_typ_cd;
               -- Insert if the record not found
               IF SQL%NOTFOUND
               THEN
                  INSERT INTO hcrs.prfl_prod_calc_t
                     (prfl_id,
                      ndc_lbl,
                      ndc_prod,
                      ndc_pckg,
                      calc_typ_cd,
                      comp_typ_cd,
                      calc_amt,
                      carry_fwd_ind,
                      apprvd_ind)
                     SELECT i_prfl_id,
                            i_ndc_lbl,
                            i_ndc_prod,
                            pp.ndc_pckg,
                            i_calc_typ_cd,
                            i_comp_typ_cd,
                            i_calc_amt,
                            i_carry_fwd_ind,
                            pkg_constants.cs_flag_no
                       FROM hcrs.prfl_prod_t pp
                      WHERE pp.prfl_id = i_prfl_id
                        AND pp.ndc_lbl = i_ndc_lbl
                        AND pp.ndc_prod = i_ndc_prod;
               END IF;
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt ||
            ' i_prfl_id=[' || i_prfl_id || ']' ||
            ' i_ndc_lbl=[' || i_ndc_lbl || ']' ||
            ' i_ndc_prod=[' || i_ndc_prod || ']' ||
            ' i_ndc_pckg=[' || i_ndc_pckg || ']' ||
            ' i_calc_typ_cd=[' || i_calc_typ_cd || ']' ||
            ' i_comp_typ_cd=[' || i_comp_typ_cd || ']' ||
            ' i_calc_amt=[' || i_calc_amt || ']' ||
            ' i_fcp_src_ind=[' || i_fcp_src_ind || ']' ||
            ' i_carry_fwd_ind=[' || i_carry_fwd_ind || ']');
   END p_update_interim_table;


   PROCEDURE p_comp_val_clear
      (i_zero_only IN BOOLEAN := FALSE)
   IS
      /*************************************************************************
      * Procedure Name : p_comp_val_clear
      *   Input params : i_zero_only - If TRUE, only zeros all components
      *  Output params : None
      *   Date Created : 01/15/2018
      *         Author : Joe Kidd
      *    Description : Delete all entries in the component value table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_comp_val_clear';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Delete all entries in the component value table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while deleting all entries in the component value table';
      v_comp_typ_cd         hcrs.comp_typ_t.comp_typ_cd%TYPE;
   BEGIN
      IF NVL( i_zero_only, FALSE)
      THEN
        -- Zero all values
         v_comp_typ_cd := gv_comp_val_tbl.FIRST();
         WHILE v_comp_typ_cd IS NOT NULL
         LOOP
            gv_comp_val_tbl( v_comp_typ_cd).amt := 0;
            v_comp_typ_cd := gv_comp_val_tbl.NEXT( v_comp_typ_cd);
         END LOOP;
      ELSE
        -- Delete all values
        gv_comp_val_tbl.DELETE();
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_comp_val_clear;


   PROCEDURE p_comp_val_init
      (i_comp_typ_cd    IN hcrs.comp_typ_t.comp_typ_cd%TYPE,
       i_trans_comp     IN BOOLEAN := FALSE,
       i_comp_dllrs     IN hcrs.prfl_prod_calc_comp_def_t.comp_dllrs%TYPE := '',
       i_trans_dt_range IN hcrs.prfl_prod_calc_comp_def_t.trans_dt_range%TYPE := '')
   IS
      /*************************************************************************
      * Procedure Name : p_comp_val_init
      *   Input params : i_comp_typ_cd - Component Type Code
      *                : i_trans_comp - If TRUE, component is built from transactions
      *                : i_comp_dllrs - Component Dollars (SLS/DSC)
      *                : i_trans_dt_range - Trans Date range (QTR/ANN/OFF)
      *  Output params : None
      *   Date Created : 01/15/2018
      *         Author : Joe Kidd
      *    Description : Initialize a component in the component value table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_comp_val_init';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Initialize a component in the component value table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while initializing of a component in the component value table';
   BEGIN
      IF i_comp_typ_cd IS NOT NULL
      THEN
         gv_comp_val_tbl( i_comp_typ_cd).comp_typ_cd := i_comp_typ_cd;
         gv_comp_val_tbl( i_comp_typ_cd).amt := 0;
         gv_comp_val_tbl( i_comp_typ_cd).trans_comp := NVL( i_trans_comp, FALSE);
         IF i_comp_dllrs IS NOT NULL
         THEN
            gv_comp_val_tbl( i_comp_typ_cd).comp_dllrs := i_comp_dllrs;
         END IF;
         IF i_trans_dt_range IS NOT NULL
         THEN
            gv_comp_val_tbl( i_comp_typ_cd).trans_dt_range := i_trans_dt_range;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_comp_val_init;


   PROCEDURE p_comp_val_round_all
      (i_dec_pcsn   IN NUMBER,
       i_trans_comp IN BOOLEAN := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_comp_val_round_all
      *   Input params : i_dec_pcsn - Number of decimal places to round
      *                : i_trans_comp - If NULL, round all components
      *                :                If TRUE, round transaction components
      *                :                If FALSE, round non-transaction components
      *  Output params : None
      *   Date Created : 01/15/2018
      *         Author : Joe Kidd
      *    Description : Rounds all entries in the component value table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_comp_val_round_all';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Rounds all entries in the component value table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while rounding all entries in the component value table';
      v_comp_typ_cd         hcrs.comp_typ_t.comp_typ_cd%TYPE;
   BEGIN
      IF i_dec_pcsn IS NOT NULL
      THEN
        -- Round all values
         v_comp_typ_cd := gv_comp_val_tbl.FIRST();
         WHILE v_comp_typ_cd IS NOT NULL
         LOOP
            IF i_trans_comp IS NULL -- all components
               -- only transaction components
               OR (    i_trans_comp
                   AND NVL( gv_comp_val_tbl( v_comp_typ_cd).trans_comp, FALSE)
                  )
               -- only non-transaction components
               OR (    NOT i_trans_comp
                   AND NOT NVL( gv_comp_val_tbl( v_comp_typ_cd).trans_comp, FALSE)
                  )
            THEN
               gv_comp_val_tbl( v_comp_typ_cd).amt := ROUND( gv_comp_val_tbl( v_comp_typ_cd).amt, i_dec_pcsn);
            END IF;
            v_comp_typ_cd := gv_comp_val_tbl.NEXT( v_comp_typ_cd);
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_comp_val_round_all;


   PROCEDURE p_comp_val_set
      (i_comp_typ_cd   IN hcrs.comp_typ_t.comp_typ_cd%TYPE,
       i_amt           IN NUMBER,
       i_fcp_src_ind   IN hcrs.prfl_prod_calc_t.fcp_src_ind%TYPE := NULL,
       i_carry_fwd_ind IN hcrs.prfl_prod_calc_t.carry_fwd_ind%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_comp_val_set
      *   Input params : i_comp_typ_cd - Component Type Code
      *                : i_amt - Amount
      *                : i_fcp_src_ind - FCP Source indicator (F/C/O)
      *                : i_carry_fwd_ind -  Carry Forward Indicator (C)
      *  Output params : None
      *   Date Created : 09/25/2012
      *         Author : Joe Kidd
      *    Description : Set the amount of a component in the component value table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  10/02/2015  Joe Kidd      CRQ-208647: Demand 6324: NonFamp/FCP Calc Modifications
      *                            Add FCP source and carry forward indicators
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Remove component table parameter and other
      *                            parameters only used for initialization
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_comp_val_set';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Set the amount of a component in the component value table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while setting the amount of a component in the component value table';
   BEGIN
      IF i_comp_typ_cd IS NOT NULL
      THEN
         gv_comp_val_tbl( i_comp_typ_cd).comp_typ_cd := i_comp_typ_cd;
         gv_comp_val_tbl( i_comp_typ_cd).amt := i_amt;
         gv_comp_val_tbl( i_comp_typ_cd).fcp_src_ind := i_fcp_src_ind;
         gv_comp_val_tbl( i_comp_typ_cd).carry_fwd_ind := i_carry_fwd_ind;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_comp_val_set;


   PROCEDURE p_comp_val_add
      (i_comp_typ_cd IN hcrs.comp_typ_t.comp_typ_cd%TYPE,
       i_amt         IN NUMBER)
   IS
      /*************************************************************************
      * Procedure Name : p_comp_val_add
      *   Input params : i_comp_typ_cd - Component Type Code
      *                : i_amt - Amount to add
      *  Output params : None
      *   Date Created : 09/25/2012
      *         Author : Joe Kidd
      *    Description : Add an amount to a component in the component value table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Remove component table parameter
      *                            Check for existance of component
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_comp_val_add';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Add an amount to a component in the component value table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while adding an amount to a component in the component value table';
   BEGIN
      IF i_comp_typ_cd IS NOT NULL
      THEN
         IF NOT gv_comp_val_tbl.EXISTS( i_comp_typ_cd)
         THEN
            p_comp_val_init( i_comp_typ_cd);
         END IF;
         gv_comp_val_tbl( i_comp_typ_cd).amt := NVL( gv_comp_val_tbl( i_comp_typ_cd).amt, 0) + i_amt;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_comp_val_add;


   FUNCTION f_comp_val_get
      (i_comp_typ_cd IN hcrs.comp_typ_t.comp_typ_cd%TYPE)
      RETURN NUMBER
   IS
      /*************************************************************************
      * Function Name : f_comp_val_get
      *  Input params : i_comp_typ_cd - Component Type Code
      *               : i_amt - Amount
      *               : i_fcp_src_ind - FCP Source indicator (F/C/O)
      *               : i_carry_fwd_ind -  Carry Forward Indicator (C)
      * Output params : None
      *       Returns : NUMBER, the component value
      *  Date Created : 01/15/2018
      *        Author : Joe Kidd
      *   Description : Gets the component amount from the component value table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_comp_val_get';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Get the component amount from the component value table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while getting the component amount from the component value table';
      v_return              NUMBER;
   BEGIN
      IF gv_comp_val_tbl.EXISTS( i_comp_typ_cd)
      THEN
         v_return := gv_comp_val_tbl( i_comp_typ_cd).amt;
      END IF;
      RETURN v_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_comp_val_get;


   PROCEDURE p_comp_val_save
   IS
      /*************************************************************************
      * Procedure Name : p_comp_val_save
      *   Input params : None
      *  Output params : None
      *   Date Created : 09/25/2012
      *         Author : Joe Kidd
      *    Description : Save the component value table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  10/02/2015  Joe Kidd      CRQ-208647: Demand 6324: NonFamp/FCP Calc Modifications
      *                            Allow each component to set FCP source and carry
      *                              forward indicators
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Remove component table parameter
      *                            Do not save price point components
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_comp_val_save';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Save the component value table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while saving the component value table';
      v_comp_typ_cd         hcrs.comp_typ_t.comp_typ_cd%TYPE;
   BEGIN
      v_comp_typ_cd := gv_comp_val_tbl.FIRST();
      WHILE v_comp_typ_cd IS NOT NULL
      LOOP
         IF gv_comp_val_tbl( v_comp_typ_cd).comp_dllrs IN (pkg_constants.cs_comp_dllrs_price)
         THEN
            -- Price point components don't accumulate a value
            NULL;
         ELSE
            p_update_interim_table
               (gv_param_rec.prfl_id,
                gv_param_rec.ndc_lbl,
                gv_param_rec.ndc_prod,
                gv_param_rec.ndc_pckg,
                gv_param_rec.calc_typ_cd,
                gv_comp_val_tbl( v_comp_typ_cd).comp_typ_cd,
                gv_comp_val_tbl( v_comp_typ_cd).amt,
                gv_comp_val_tbl( v_comp_typ_cd).fcp_src_ind,
                gv_comp_val_tbl( v_comp_typ_cd).carry_fwd_ind);
         END IF;
         v_comp_typ_cd := gv_comp_val_tbl.NEXT( v_comp_typ_cd);
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_comp_val_save;


   PROCEDURE p_update_prod_calc
      (i_prfl_id     IN hcrs.prfl_calc_prod_t.prfl_id%TYPE,
       i_calc_typ_cd IN hcrs.prfl_calc_prod_t.calc_typ_cd%TYPE,
       i_ndc_lbl     IN hcrs.prfl_calc_prod_t.ndc_lbl%TYPE,
       i_ndc_prod    IN hcrs.prfl_calc_prod_t.ndc_prod%TYPE,
       i_ndc_pckg    IN hcrs.prfl_calc_prod_t.ndc_pckg%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_update_prod_calc
      *   Input params : i_prfl_id - profile
      *                : i_calc_typ_cd - calculation code
      *                : i_ndc_lbl - NDC labeler
      *                : i_ndc_prod - NDC Product Family
      *                : i_ndc_pckg - NDC Package Size
      *  Output params : None
      *   Date Created : 10/01/2010
      *         Author : Joe Kidd
      *    Description : Update product calc tables
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Use calc setting to enforce PPACA indicator
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Use new view to populate tables
      *                            Commit at end counting all changes
      *  11/20/2013  Joe Kidd      CRQ-79943: Correct rollup product logic
      *                            Correct how prfl_calc_prod_roll_t is populated
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Refactor to populate additional columns
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Use working tables instead of views
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_update_prod_calc';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Update product calc tables after any change to products';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while updating product calc tables after any change to products';
      v_cnt                 NUMBER := 0;
   BEGIN
      --------------------------------------------------------------------------
      -- Insert/Update Product Calc Family level (only applies to NDC9 level calcs)
      --------------------------------------------------------------------------
      MERGE
       INTO hcrs.prfl_calc_prod_fmly_t pcpf
      USING (
               SELECT DISTINCT
                      ppw.prfl_id,
                      ppw.calc_typ_cd,
                      ppw.trans_ndc_lbl,
                      ppw.trans_ndc_prod,
                      ppw.pri_whls_mthd_cd,
                      ppw.nonrtl_threshold,
                      ppw.start_dt,
                      ppw.end_dt,
                      ppw.ann_start_dt,
                      ppw.ann_end_dt,
                      ppw.ann_off_start_dt,
                      ppw.ann_off_end_dt,
                      ppw.min_start_dt,
                      ppw.max_end_dt
                 FROM hcrs.prfl_prod_wrk_t ppw
                   -- For the passed parameters
                WHERE ppw.prfl_id = i_prfl_id
                  AND ppw.calc_typ_cd = i_calc_typ_cd
                  AND ppw.ndc_lbl = i_ndc_lbl
                  AND ppw.ndc_prod = i_ndc_prod
                   -- only applies to NDC9 level calcs
                  AND ppw.calc_ndc_pckg_lvl = pkg_constants.cs_flag_no
                   -- only applies to main products
                  AND ppw.roll_up = pkg_constants.cs_flag_no
                  AND ppw.bndl_only = pkg_constants.cs_flag_no
            ) z
         ON (    pcpf.prfl_id = z.prfl_id
             AND pcpf.calc_typ_cd = z.calc_typ_cd
             AND pcpf.ndc_lbl = z.trans_ndc_lbl
             AND pcpf.ndc_prod = z.trans_ndc_prod
            )
       WHEN MATCHED
       THEN UPDATE
               SET pcpf.pri_whls_mthd_cd = z.pri_whls_mthd_cd,
                   pcpf.nonrtl_threshold = z.nonrtl_threshold,
                   pcpf.start_dt = z.start_dt,
                   pcpf.end_dt = z.end_dt,
                   pcpf.ann_start_dt = z.ann_start_dt,
                   pcpf.ann_end_dt = z.ann_end_dt,
                   pcpf.ann_off_start_dt = z.ann_off_start_dt,
                   pcpf.ann_off_end_dt = z.ann_off_end_dt,
                   pcpf.min_start_dt = z.min_start_dt,
                   pcpf.max_end_dt = z.max_end_dt
       WHEN NOT MATCHED
       THEN INSERT
               (pcpf.prfl_id,
                pcpf.calc_typ_cd,
                pcpf.ndc_lbl,
                pcpf.ndc_prod,
                pcpf.pri_whls_mthd_cd,
                pcpf.nonrtl_threshold,
                pcpf.start_dt,
                pcpf.end_dt,
                pcpf.ann_start_dt,
                pcpf.ann_end_dt,
                pcpf.ann_off_start_dt,
                pcpf.ann_off_end_dt,
                pcpf.min_start_dt,
                pcpf.max_end_dt)
               VALUES
               (z.prfl_id,
                z.calc_typ_cd,
                z.trans_ndc_lbl,
                z.trans_ndc_prod,
                z.pri_whls_mthd_cd,
                z.nonrtl_threshold,
                z.start_dt,
                z.end_dt,
                z.ann_start_dt,
                z.ann_end_dt,
                z.ann_off_start_dt,
                z.ann_off_end_dt,
                z.min_start_dt,
                z.max_end_dt);
      v_cnt := v_cnt + SQL%ROWCOUNT;
      --------------------------------------------------------------------------
      -- Insert/Update Product Calc Package level
      --------------------------------------------------------------------------
      MERGE
       INTO hcrs.prfl_calc_prod_t pcp
      USING (
               SELECT ppw.prfl_id,
                      ppw.calc_typ_cd,
                      ppw.trans_ndc_lbl,
                      ppw.trans_ndc_prod,
                      ppw.trans_ndc_pckg,
                      ppw.pri_whls_mthd_cd,
                      ppw.nonrtl_threshold,
                      ppw.start_dt,
                      ppw.end_dt,
                      ppw.ann_start_dt,
                      ppw.ann_end_dt,
                      ppw.ann_off_start_dt,
                      ppw.ann_off_end_dt,
                      ppw.min_start_dt,
                      ppw.max_end_dt
                 FROM hcrs.prfl_prod_wrk_t ppw
                   -- For the passed parameters
                WHERE ppw.prfl_id = i_prfl_id
                  AND ppw.calc_typ_cd = i_calc_typ_cd
                  AND ppw.ndc_lbl = i_ndc_lbl
                  AND ppw.ndc_prod = i_ndc_prod
                  AND ppw.ndc_pckg = NVL( i_ndc_pckg, ppw.ndc_pckg)
                   -- only applies to main products
                  AND ppw.roll_up = pkg_constants.cs_flag_no
                  AND ppw.bndl_only = pkg_constants.cs_flag_no
            ) z
         ON (    pcp.prfl_id = z.prfl_id
             AND pcp.calc_typ_cd = z.calc_typ_cd
             AND pcp.ndc_lbl = z.trans_ndc_lbl
             AND pcp.ndc_prod = z.trans_ndc_prod
             AND pcp.ndc_pckg = z.trans_ndc_pckg
            )
       WHEN MATCHED
       THEN UPDATE
               SET pcp.pri_whls_mthd_cd = z.pri_whls_mthd_cd,
                   pcp.nonrtl_threshold = z.nonrtl_threshold,
                   pcp.start_dt = z.start_dt,
                   pcp.end_dt = z.end_dt,
                   pcp.ann_start_dt = z.ann_start_dt,
                   pcp.ann_end_dt = z.ann_end_dt,
                   pcp.ann_off_start_dt = z.ann_off_start_dt,
                   pcp.ann_off_end_dt = z.ann_off_end_dt,
                   pcp.min_start_dt = z.min_start_dt,
                   pcp.max_end_dt = z.max_end_dt
       WHEN NOT MATCHED
       THEN INSERT
               (pcp.prfl_id,
                pcp.calc_typ_cd,
                pcp.ndc_lbl,
                pcp.ndc_prod,
                pcp.ndc_pckg,
                pcp.pri_whls_mthd_cd,
                pcp.nonrtl_threshold,
                pcp.start_dt,
                pcp.end_dt,
                pcp.ann_start_dt,
                pcp.ann_end_dt,
                pcp.ann_off_start_dt,
                pcp.ann_off_end_dt,
                pcp.min_start_dt,
                pcp.max_end_dt)
               VALUES
               (z.prfl_id,
                z.calc_typ_cd,
                z.trans_ndc_lbl,
                z.trans_ndc_prod,
                z.trans_ndc_pckg,
                z.pri_whls_mthd_cd,
                z.nonrtl_threshold,
                z.start_dt,
                z.end_dt,
                z.ann_start_dt,
                z.ann_end_dt,
                z.ann_off_start_dt,
                z.ann_off_end_dt,
                z.min_start_dt,
                z.max_end_dt);
      v_cnt := v_cnt + SQL%ROWCOUNT;
      --------------------------------------------------------------------------
      -- Insert/Update Product Calc Rollups
      --------------------------------------------------------------------------
      MERGE
       INTO hcrs.prfl_calc_prod_roll_t pcpr
      USING (
               SELECT ppw.prfl_id,
                      ppw.calc_typ_cd,
                      ppw.prfl_ndc_lbl,
                      ppw.prfl_ndc_prod,
                      ppw.prfl_ndc_pckg,
                      ppw.trans_ndc_lbl ndc_lbl,
                      ppw.trans_ndc_prod ndc_prod,
                      ppw.trans_ndc_pckg ndc_pckg,
                      ppw.pri_whls_mthd_cd,
                      ppw.nonrtl_threshold
                 FROM hcrs.prfl_prod_wrk_t ppw
                   -- For the passed parameters
                WHERE ppw.prfl_id = i_prfl_id
                  AND ppw.calc_typ_cd = NVL( i_calc_typ_cd, ppw.calc_typ_cd)
                  AND ppw.ndc_lbl = NVL( i_ndc_lbl, ppw.ndc_lbl)
                  AND ppw.ndc_prod = NVL( i_ndc_prod, ppw.ndc_prod)
                  AND ppw.ndc_pckg = NVL( i_ndc_pckg, ppw.ndc_pckg)
                   -- only applies to rollup products
                  AND ppw.roll_up = pkg_constants.cs_flag_yes
                  AND ppw.bndl_only = pkg_constants.cs_flag_no
            ) z
         ON (    pcpr.prfl_id = z.prfl_id
             AND pcpr.calc_typ_cd = z.calc_typ_cd
             AND pcpr.prfl_ndc_lbl = z.prfl_ndc_lbl
             AND pcpr.prfl_ndc_prod = z.prfl_ndc_prod
             AND pcpr.prfl_ndc_pckg = z.prfl_ndc_pckg
             AND pcpr.ndc_lbl = z.ndc_lbl
             AND pcpr.ndc_prod = z.ndc_prod
             AND pcpr.ndc_pckg = z.ndc_pckg
            )
       WHEN MATCHED
       THEN UPDATE
               SET pcpr.pri_whls_mthd_cd = z.pri_whls_mthd_cd,
                   pcpr.nonrtl_threshold = z.nonrtl_threshold
       WHEN NOT MATCHED
       THEN INSERT
               (pcpr.prfl_id,
                pcpr.calc_typ_cd,
                pcpr.prfl_ndc_lbl,
                pcpr.prfl_ndc_prod,
                pcpr.prfl_ndc_pckg,
                pcpr.ndc_lbl,
                pcpr.ndc_prod,
                pcpr.ndc_pckg,
                pcpr.pri_whls_mthd_cd,
                pcpr.nonrtl_threshold)
               VALUES
               (z.prfl_id,
                z.calc_typ_cd,
                z.prfl_ndc_lbl,
                z.prfl_ndc_prod,
                z.prfl_ndc_pckg,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.pri_whls_mthd_cd,
                z.nonrtl_threshold);
      v_cnt := v_cnt + SQL%ROWCOUNT;
      p_commit( v_cnt);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_update_prod_calc;


   FUNCTION f_get_cust_loc_cd_list
      (i_mode             IN VARCHAR2,
       i_domestic_ind     IN hcrs.prfl_prod_calc_comp_def_wrk_t.cust_domestic_ind%TYPE,
       i_territory_ind    IN hcrs.prfl_prod_calc_comp_def_wrk_t.cust_territory_ind%TYPE,
       i_trans_typ_grp_cd IN hcrs.prfl_prod_calc_comp_def_wrk_t.trans_typ_grp_cd%TYPE := NULL)
      RETURN VARCHAR2
   IS
      /*************************************************************************
      * Function Name : f_get_cust_loc_cd_list
      *  Input params : i_mode: Translation mode
      *               : i_domestic_ind: Domestic Indicator
      *               : i_territory_ind: Territory Indicator
      *               : i_trans_typ_grp_cd: Transaction Type Group
      * Output params : None
      *       Returns : VARCHAR2, the customer location codes
      *  Date Created : 03/01/2019
      *        Author : Joe Kidd
      *   Description : Get the specified longops value
      *
      *                 Translation modes
      *                 CUST      : Customer location
      *                 COMP_CUST : Component Customer location
      *                 COMP_WHLS : Component Wholesaler location
      *
      *                 Transaction Type Group (TTG) code
      *                 The Component Wholesaler mode requires the component's
      *                 Transaction Type Group code to be passed because only
      *                 Indirect TTG use Wholesaler location.  All others TTGs
      *                 are ignored.
      *
      *                 Legacy Customer/wholesaler location conditions
      *                 Values: Y (include), N (exclude), X (ignore), % (all)
      *
      *                 Customer settings - Translate a customer's location settings
      *                 Y and N : USDOM  : US Domestic only: set domestic_ind = 'Y' and territory_ind = 'N'
      *                 N and Y : USTERR : US Territory only: set domestic_ind = 'N' and territory_ind = 'Y'
      *                 N and N : NONUS  : Non-US Only: set both to 'N'
      *
      *                 Component settings - Match a group of customers by location
      *                 Y and X: USDOM              : US Domestic only: set domestic_ind = 'Y' and territory_ind = 'X'
      *                 X and Y: USTERR             : US Territory only: set domestic_ind = 'X' and territory_ind = 'Y'
      *                 N and N: NONUS              : Non-US Only: set both to 'N'
      *                 Y and Y: USDOM,USTERR       : US Domestic and Territories: set both to 'Y'
      *                 X and N: USDOM,NONUS        : US Domestic and Non-US: set domestic_ind = 'X' and territory_ind = 'N'
      *                 N and X: USTERR,NONUS       : Territory and Non-US: set domestic_ind = 'N' and territory_ind = 'X'
      *                 % and %: USDOM,USTERR,NONUS : All: set both to '%'
      *                 X and X: NONE               : None: set both to 'X'
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_get_cust_loc_cd_list';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Get the customer location code list from legacy settings';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while getting the customer location code list from legacy settings';
      v_cust_loc_cd_list    hcrs.prfl_prod_calc_comp_def2_wrk_t.cust_loc_cd_list%TYPE;
      v_error_descr         hcrs.error_log_t.error_descr%TYPE;
   BEGIN
      -- Default to error status
      v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_error;
      CASE
         -----------------------------------------------------------------------
         -- Validate parameters
         -----------------------------------------------------------------------
         WHEN i_mode NOT IN (pkg_constants.cs_cust_loc_cd_mode_cust,
                             pkg_constants.cs_cust_loc_cd_mode_comp_cust,
                             pkg_constants.cs_cust_loc_cd_mode_comp_whls)
         THEN
            v_error_descr := 'Invalid mode';
         WHEN i_domestic_ind NOT IN (pkg_constants.cs_cust_dom_terr_ind_incl,
                                     pkg_constants.cs_cust_dom_terr_ind_excl,
                                     pkg_constants.cs_cust_dom_terr_ind_ignore,
                                     pkg_constants.cs_cust_dom_terr_ind_all)
         THEN
            v_error_descr := 'Invalid Domestic Indicator';
         WHEN i_territory_ind NOT IN (pkg_constants.cs_cust_dom_terr_ind_incl,
                                      pkg_constants.cs_cust_dom_terr_ind_excl,
                                      pkg_constants.cs_cust_dom_terr_ind_ignore,
                                      pkg_constants.cs_cust_dom_terr_ind_all)
         THEN
            v_error_descr := 'Invalid Territory Indicator';
         WHEN i_mode = pkg_constants.cs_cust_loc_cd_mode_comp_whls
          AND i_trans_typ_grp_cd IS NULL
         THEN
            v_error_descr := 'Wholesaler Mode requires Trans Type Group code';
         -----------------------------------------------------------------------
         -- Customer Mode
         -----------------------------------------------------------------------
         -- US Domestic
         WHEN i_mode = pkg_constants.cs_cust_loc_cd_mode_cust
          AND i_domestic_ind = pkg_constants.cs_cust_dom_terr_ind_incl
          AND i_territory_ind = pkg_constants.cs_cust_dom_terr_ind_excl
         THEN
            v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_domestic;
         -- US Territories
         WHEN i_mode = pkg_constants.cs_cust_loc_cd_mode_cust
          AND i_domestic_ind = pkg_constants.cs_cust_dom_terr_ind_excl
          AND i_territory_ind = pkg_constants.cs_cust_dom_terr_ind_incl
         THEN
            v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_territory;
         -- Non-US
         WHEN i_mode = pkg_constants.cs_cust_loc_cd_mode_cust
          AND i_domestic_ind = pkg_constants.cs_cust_dom_terr_ind_excl
          AND i_territory_ind = pkg_constants.cs_cust_dom_terr_ind_excl
         THEN
            v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_non_us;
         -- Not reconized
         WHEN i_mode = pkg_constants.cs_cust_loc_cd_mode_cust
         THEN
            v_error_descr := 'Invalid Customer Mode settings';
         -----------------------------------------------------------------------
         -- Component Customer/Wholesaler Mode
         -----------------------------------------------------------------------
         -- Wholesaler mode Ignores non-Indirect Sales Trans Type Groups
         WHEN i_mode = pkg_constants.cs_cust_loc_cd_mode_comp_whls
          AND i_trans_typ_grp_cd <> pkg_constants.cs_tt_indirect_sales
         THEN
            v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_none;
         -- US Domestic
         WHEN i_mode IN (pkg_constants.cs_cust_loc_cd_mode_comp_cust,
                         pkg_constants.cs_cust_loc_cd_mode_comp_whls)
          AND i_domestic_ind = pkg_constants.cs_cust_dom_terr_ind_incl
          AND i_territory_ind = pkg_constants.cs_cust_dom_terr_ind_ignore
         THEN
            v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_domestic;
         -- US Territories
         WHEN i_mode IN (pkg_constants.cs_cust_loc_cd_mode_comp_cust,
                         pkg_constants.cs_cust_loc_cd_mode_comp_whls)
          AND i_domestic_ind = pkg_constants.cs_cust_dom_terr_ind_ignore
          AND i_territory_ind = pkg_constants.cs_cust_dom_terr_ind_incl
         THEN
            v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_territory;
         -- Non-US
         WHEN i_mode IN (pkg_constants.cs_cust_loc_cd_mode_comp_cust,
                         pkg_constants.cs_cust_loc_cd_mode_comp_whls)
          AND i_domestic_ind = pkg_constants.cs_cust_dom_terr_ind_excl
          AND i_territory_ind = pkg_constants.cs_cust_dom_terr_ind_excl
         THEN
            v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_non_us;
         -- US Domestic and Territories
         WHEN i_mode IN (pkg_constants.cs_cust_loc_cd_mode_comp_cust,
                         pkg_constants.cs_cust_loc_cd_mode_comp_whls)
          AND i_domestic_ind = pkg_constants.cs_cust_dom_terr_ind_incl
          AND i_territory_ind = pkg_constants.cs_cust_dom_terr_ind_incl
         THEN
            v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_domestic ||
                                  pkg_constants.cs_cust_loc_cd_delim ||
                                  pkg_constants.cs_cust_loc_cd_territory;
         -- US Domestic and Non-US
         WHEN i_mode IN (pkg_constants.cs_cust_loc_cd_mode_comp_cust,
                         pkg_constants.cs_cust_loc_cd_mode_comp_whls)
          AND i_domestic_ind = pkg_constants.cs_cust_dom_terr_ind_ignore
          AND i_territory_ind = pkg_constants.cs_cust_dom_terr_ind_excl
         THEN
            v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_domestic ||
                                  pkg_constants.cs_cust_loc_cd_delim ||
                                  pkg_constants.cs_cust_loc_cd_non_us;
         -- US Territory and Non-US
         WHEN i_mode IN (pkg_constants.cs_cust_loc_cd_mode_comp_cust,
                         pkg_constants.cs_cust_loc_cd_mode_comp_whls)
          AND i_domestic_ind = pkg_constants.cs_cust_dom_terr_ind_excl
          AND i_territory_ind = pkg_constants.cs_cust_dom_terr_ind_ignore
         THEN
            v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_territory ||
                                  pkg_constants.cs_cust_loc_cd_delim ||
                                  pkg_constants.cs_cust_loc_cd_non_us;
         -- All
         WHEN i_mode IN (pkg_constants.cs_cust_loc_cd_mode_comp_cust,
                         pkg_constants.cs_cust_loc_cd_mode_comp_whls)
          AND i_domestic_ind = pkg_constants.cs_cust_dom_terr_ind_all
          AND i_territory_ind = pkg_constants.cs_cust_dom_terr_ind_all
         THEN
            v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_domestic ||
                                  pkg_constants.cs_cust_loc_cd_delim ||
                                  pkg_constants.cs_cust_loc_cd_territory ||
                                  pkg_constants.cs_cust_loc_cd_delim ||
                                  pkg_constants.cs_cust_loc_cd_non_us;
         -- None
         WHEN i_mode IN (pkg_constants.cs_cust_loc_cd_mode_comp_cust,
                         pkg_constants.cs_cust_loc_cd_mode_comp_whls)
          AND i_domestic_ind = pkg_constants.cs_cust_dom_terr_ind_ignore
          AND i_territory_ind = pkg_constants.cs_cust_dom_terr_ind_ignore
         THEN
            v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_none;
         WHEN i_mode = pkg_constants.cs_cust_loc_cd_mode_comp_cust
         THEN
            v_error_descr := 'Invalid Component Customer Mode settings';
         WHEN i_mode = pkg_constants.cs_cust_loc_cd_mode_comp_whls
         THEN
            v_error_descr := 'Invalid Component Wholesaler Mode settings';
      END CASE;
      IF v_cust_loc_cd_list = pkg_constants.cs_cust_loc_cd_error
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_error_descr, 'Fatal ' || cs_cmt_txt);
      ELSE
         -- Add delimiters
         v_cust_loc_cd_list := pkg_constants.cs_cust_loc_cd_delim ||
                               v_cust_loc_cd_list ||
                               pkg_constants.cs_cust_loc_cd_delim;
      END IF;
      RETURN v_cust_loc_cd_list;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_get_cust_loc_cd_list;


   PROCEDURE p_clear_wrk_t
      (i_mode IN NUMBER)
   IS
      /*************************************************************************
      * Procedure Name : p_clear_wrk_t
      *   Input params : i_mode - Controls which working tables are cleared
      *                         0: Clear all working tables
      *                         1: Clear all, except products, components,
      *                            bundle summary and detail trans
      *                         2: Clear only bundling setup working tables
      *  Output params : None
      *   Date Created : 01/15/2018
      *         Author : Joe Kidd
      *    Description : Clear working tables, TRUNCATEs when calc is running,
      *                  DELETEs when calc is not running.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Centralize GTT deletes
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_clear_wrk_t';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Clear working tables';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while clearing working tables';
      v_mode                NUMBER := NVL( i_mode, -1);
   BEGIN
      IF v_mode = 0
      THEN
         IF f_is_calc_running()
         THEN
            pkg_utils.p_truncate_table( 'hcrs.prfl_prod_wrk_t');
            pkg_utils.p_truncate_table( 'hcrs.prfl_prod_calc_comp_def_wrk_t');
            pkg_utils.p_truncate_table( 'hcrs.prfl_prod_calc_comp_def2_wrk_t');
            pkg_utils.p_truncate_table( 'hcrs.prfl_prod_bndl_smry_wrk_t');
            pkg_utils.p_truncate_table( 'hcrs.prfl_prod_bndl_cp_trns_wrk_t');
         ELSE
            DELETE FROM hcrs.prfl_prod_wrk_t;
            DELETE FROM hcrs.prfl_prod_calc_comp_def_wrk_t;
            DELETE FROM hcrs.prfl_prod_calc_comp_def2_wrk_t;
            DELETE FROM hcrs.prfl_prod_bndl_smry_wrk_t;
            DELETE FROM hcrs.prfl_prod_bndl_cp_trns_wrk_t;
         END IF;
      END IF;
      IF v_mode IN (0, 1)
      THEN
         IF f_is_calc_running()
         THEN
            pkg_utils.p_truncate_table( 'hcrs.prfl_contr_prod_splt_pct_wrk_t');
            pkg_utils.p_truncate_table( 'hcrs.prfl_mtrx_wrk_t');
            pkg_utils.p_truncate_table( 'hcrs.prfl_cust_cls_of_trd_wrk_t');
            pkg_utils.p_truncate_table( 'hcrs.prfl_contr_wrk_t');
         ELSE
            DELETE FROM hcrs.prfl_contr_prod_splt_pct_wrk_t;
            DELETE FROM hcrs.prfl_mtrx_wrk_t;
            DELETE FROM hcrs.prfl_cust_cls_of_trd_wrk_t;
            DELETE FROM hcrs.prfl_contr_wrk_t;
         END IF;
      END IF;
      IF v_mode IN (0, 1, 2)
      THEN
         IF f_is_calc_running()
         THEN
            pkg_utils.p_truncate_table( 'hcrs.prfl_bndl_prod_wrk_t');
            pkg_utils.p_truncate_table( 'hcrs.prfl_bndl_cond_wrk_t');
            pkg_utils.p_truncate_table( 'hcrs.prfl_price_grp_bndl_wrk_t');
            pkg_utils.p_truncate_table( 'hcrs.prfl_prod_bndl_dts_wrk_t');
            pkg_utils.p_truncate_table( 'hcrs.prfl_cust_cond_wrk_t');
         ELSE
            DELETE FROM hcrs.prfl_bndl_prod_wrk_t;
            DELETE FROM hcrs.prfl_bndl_cond_wrk_t;
            DELETE FROM hcrs.prfl_price_grp_bndl_wrk_t;
            DELETE FROM hcrs.prfl_prod_bndl_dts_wrk_t;
            DELETE FROM hcrs.prfl_cust_cond_wrk_t;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_clear_wrk_t;


   PROCEDURE p_mk_prod_wrk_t
      (i_prfl_id     IN hcrs.prfl_prod_calc_t.prfl_id%TYPE,
       i_ndc_lbl     IN hcrs.prfl_prod_calc_t.ndc_lbl%TYPE,
       i_ndc_prod    IN hcrs.prfl_prod_calc_t.ndc_prod%TYPE,
       i_ndc_pckg    IN hcrs.prfl_prod_calc_t.ndc_pckg%TYPE,
       i_calc_typ_cd IN hcrs.prfl_prod_calc_t.calc_typ_cd%TYPE)
   IS
      /*************************************************************************
      * Procedure Name : p_mk_prod_wrk_t
      *   Input params : i_prfl_id - Profile ID
      *                : i_ndc_lbl - NDC Labeler
      *                : i_ndc_prod - NDC Product
      *                : i_ndc_pckg - NDC Package
      *                : i_calc_typ_cd - Calculation code
      *  Output params : None
      *        Returns : None
      *   Date Created : 12/05/2007
      *         Author : Joe Kidd
      *    Description : Populates the product working table (a global temp table)
      *
      *                  NOTE: This procedure should only write to temporary
      *                  tables, so that it can be used during testing/debugging
      *                  in production.  No changes should be made to permanent
      *                  objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  08/22/2008  Joe Kidd      PICC 1961: Add Bundle flag and
      *                            Primary/Wholesaler method parameters
      *                            Add bundled products to the list of products
      *                            Delete instead of Truncate
      *  07/22/2009  Joe Kidd      RT 267 - CRQ 43432: Bundling Tuning
      *                            Get count of additional bundled products
      *  10/01/2010  Joe Kidd      CRQ-53357: October 2010 Govt Calculations Release
      *                            Use new profile calculation product tables
      *  12/01/2010  Joe Kidd      CRQ-931: December 2010 Govt Calculations Release
      *                            Add Commercial Units/Pckg
      *  04/01/2011  Joe Kidd      CRQ-3921: Linking of CARS chargebacks
      *                            Remove error logging and use error call stack
      *                            to allow init_calc use for debugging in prod
      *                            Remove additional bundle products count
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Pass only calc parameter record
      *                            Use new view to populate products
      *                            Remove Bundle products section
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Populate Addtional fields
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters, populate addtional fields
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Centralize GTT deletes
      *                            Correct Nominal/sub-PHS enable/disable
      *                            Add normal exception handling (Calc Debug Mode)
      *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
      *                            Add SAP4H source system constants
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_mk_prod_wrk_t';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Populates the product working table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while populating the product working table';
   BEGIN
      INSERT INTO hcrs.prfl_prod_wrk_t
         (prfl_id,
          co_id,
          ndc_lbl,
          ndc_prod,
          ndc_pckg,
          calc_typ_cd,
          calc_mthd_cd,
          agency_typ_cd,
          calc_ndc_pckg_lvl,
          rpt_ndc_pckg_lvl,
          prcss_typ_cd,
          tim_per_cd,
          start_dt,
          end_dt,
          ann_start_dt,
          ann_end_dt,
          ann_off_start_dt,
          ann_off_end_dt,
          min_start_dt,
          max_end_dt,
          min_paid_start_dt,
          max_paid_end_dt,
          min_earn_start_dt,
          max_earn_end_dt,
          snpsht_id,
          snpsht_dt,
          sales_offset_days,
          nom_thrs_pct,
          cash_dscnt_pct_raw,
          cash_dscnt_pct,
          prmpt_pay_adj_pct,
          max_dpa_pct_raw,
          max_dpa_pct,
          dec_pcsn,
          chk_nom,
          chk_hhs,
          chk_nom_calc,
          chk_hhs_calc,
          sap_adj_sg_elig_intgrty,
          sap_adj_dt_mblty,
          lkup_sap_adj,
          lkup_rbt_fee,
          lkup_rel_crd,
          lkup_xenon_adj,
          lkup_prasco_rbtfee,
          roll_up,
          bndl_only,
          bndl_prod,
          roll_up_ord,
          non_bndl_cnt,
          calc_min_ndc,
          prfl_ndc_lbl,
          prfl_ndc_prod,
          prfl_ndc_pckg,
          trans_ndc_lbl,
          trans_ndc_prod,
          trans_ndc_pckg,
          pri_whls_mthd_cd,
          nonrtl_threshold,
          nonrtl_drug_ind,
          unit_per_pckg,
          comm_unit_per_pckg,
          mrkt_entry_dt,
          first_dt_sld,
          term_dt,
          liab_end_dt,
          drug_catg_cd,
          medicare_drug_catg_cd,
          uses_paid_dt,
          uses_earn_dt,
          prune_days,
          flag_yes,
          flag_no,
          begin_time,
          end_time,
          rec_src_icw,
          co_icw,
          co_gnz,
          src_tbl_iis,
          src_tbl_iic,
          src_tbl_ipdr,
          src_tbl_ipir,
          source_trans_sales,
          source_trans_credits,
          system_sap,
          system_sap4h,
          system_cars,
          system_x360,
          system_prasco,
          trans_cls_dir,
          trans_cls_idr,
          trans_cls_rbt,
          sap_adj_dt_mblty_hrd_lnk,
          sap_adj_dt_mblty_sft_lnk,
          sap_adj_dt_mblty_no_lnk,
          trans_adj_original,
          trans_adj_sap_adj,
          trans_adj_sap_rollup,
          trans_adj_cars_rbt_fee,
          trans_adj_cars_adj,
          trans_adj_cars_rollup,
          trans_adj_icw_key,
          trans_adj_x360_adj,
          trans_adj_x360_rollup,
          trans_adj_prasco_rbtfee,
          trans_adj_prasco_rollup,
          trans_adj_rollup,
          trans_dt_range_ann_off,
          whls_cot_grp_cd_noncbk,
          whls_cot_incl_ind_noncbk,
          whls_domestic_ind_noncbk,
          whls_territory_ind_noncbk,
          whls_loc_cd_noncbk,
          cot_hhs_grantee,
          tt_indirect_sales,
          tt_rebates,
          tt_fee,
          tt_factr_rbt_fee,
          tt_govt)
         SELECT ppw.prfl_id,
                ppw.co_id,
                ppw.ndc_lbl,
                ppw.ndc_prod,
                ppw.ndc_pckg,
                ppw.calc_typ_cd,
                ppw.calc_mthd_cd,
                ppw.agency_typ_cd,
                ppw.calc_ndc_pckg_lvl,
                ppw.rpt_ndc_pckg_lvl,
                ppw.prcss_typ_cd,
                ppw.tim_per_cd,
                ppw.start_dt,
                ppw.end_dt,
                ppw.ann_start_dt,
                ppw.ann_end_dt,
                ppw.ann_off_start_dt,
                ppw.ann_off_end_dt,
                ppw.min_start_dt,
                ppw.max_end_dt,
                ppw.min_paid_start_dt,
                ppw.max_paid_end_dt,
                ppw.min_earn_start_dt,
                ppw.max_earn_end_dt,
                ppw.snpsht_id,
                ppw.snpsht_dt,
                ppw.sales_offset_days,
                ppw.nom_thrs_pct,
                ppw.cash_dscnt_pct_raw,
                ppw.cash_dscnt_pct,
                ppw.prmpt_pay_adj_pct,
                ppw.max_dpa_pct_raw,
                ppw.max_dpa_pct,
                ppw.dec_pcsn,
                ppw.chk_nom,
                ppw.chk_hhs,
                ppw.chk_nom chk_nom_calc,
                ppw.chk_hhs chk_hhs_calc,
                ppw.sap_adj_sg_elig_intgrty,
                ppw.sap_adj_dt_mblty,
                ppw.lkup_sap_adj,
                ppw.lkup_rbt_fee,
                ppw.lkup_rel_crd,
                ppw.lkup_xenon_adj,
                ppw.lkup_prasco_rbtfee,
                ppw.roll_up,
                ppw.bndl_only,
                -- set to no here, will be updated after bundling data determined
                pkg_constants.cs_flag_no bndl_prod,
                ppw.roll_up_ord,
                ppw.non_bndl_cnt,
                ppw.calc_min_ndc,
                ppw.prfl_ndc_lbl,
                ppw.prfl_ndc_prod,
                ppw.prfl_ndc_pckg,
                ppw.trans_ndc_lbl,
                ppw.trans_ndc_prod,
                ppw.trans_ndc_pckg,
                ppw.pri_whls_mthd_cd,
                ppw.nonrtl_threshold,
                ppw.nonrtl_drug_ind,
                ppw.unit_per_pckg,
                ppw.comm_unit_per_pckg,
                ppw.mrkt_entry_dt,
                ppw.first_dt_sld,
                ppw.term_dt,
                ppw.liab_end_dt,
                ppw.drug_catg_cd,
                ppw.medicare_drug_catg_cd,
                ppw.uses_paid_dt,
                ppw.uses_earn_dt,
                pkg_constants.cs_prune_days prune_days,
                pkg_constants.cs_flag_yes flag_yes,
                pkg_constants.cs_flag_no flag_no,
                pkg_constants.cs_begin_time begin_time,
                pkg_constants.cs_end_time end_time,
                pkg_constants.cs_rec_src_icw rec_src_icw,
                pkg_constants.cs_co_icw co_icw,
                pkg_constants.cs_co_gnz co_gnz,
                pkg_constants.cs_src_tbl_iis src_tbl_iis,
                pkg_constants.cs_src_tbl_iic src_tbl_iic,
                pkg_constants.cs_src_tbl_ipdr src_tbl_ipdr,
                pkg_constants.cs_src_tbl_ipir src_tbl_ipir,
                pkg_constants.cs_source_trans_sales source_trans_sales,
                pkg_constants.cs_source_trans_credits source_trans_credits,
                pkg_constants.cs_system_sap system_sap,
                pkg_constants.cs_system_sap4h system_sap4h,
                pkg_constants.cs_system_cars system_cars,
                pkg_constants.cs_system_x360 system_x360,
                pkg_constants.cs_system_prasco system_prasco,
                pkg_constants.cs_trans_cls_dir trans_cls_dir,
                pkg_constants.cs_trans_cls_idr trans_cls_idr,
                pkg_constants.cs_trans_cls_rbt trans_cls_rbt,
                pkg_constants.cs_sap_adj_dt_mblty_hrd_lnk sap_adj_dt_mblty_hrd_lnk,
                pkg_constants.cs_sap_adj_dt_mblty_sft_lnk sap_adj_dt_mblty_sft_lnk,
                pkg_constants.cs_sap_adj_dt_mblty_no_lnk sap_adj_dt_mblty_no_lnk,
                pkg_constants.cs_trans_adj_original trans_adj_original,
                pkg_constants.cs_trans_adj_sap_adj trans_adj_sap_adj,
                pkg_constants.cs_trans_adj_sap_rollup trans_adj_sap_rollup,
                pkg_constants.cs_trans_adj_cars_rbt_fee trans_adj_cars_rbt_fee,
                pkg_constants.cs_trans_adj_cars_adj trans_adj_cars_adj,
                pkg_constants.cs_trans_adj_cars_rollup trans_adj_cars_rollup,
                pkg_constants.cs_trans_adj_icw_key trans_adj_icw_key,
                pkg_constants.cs_trans_adj_x360_adj trans_adj_x360_adj,
                pkg_constants.cs_trans_adj_x360_rollup trans_adj_x360_rollup,
                pkg_constants.cs_trans_adj_prasco_rbtfee trans_adj_prasco_rbtfee,
                pkg_constants.cs_trans_adj_prasco_rollup trans_adj_prasco_rollup,
                pkg_constants.cs_trans_adj_rollup trans_adj_rollup,
                pkg_constants.cs_trans_dt_range_ann_off trans_dt_range_ann_off,
                pkg_constants.cs_whls_cot_grp_cd_noncbk whls_cot_grp_cd_noncbk,
                pkg_constants.cs_whls_cot_incl_ind_noncbk whls_cot_incl_ind_noncbk,
                pkg_constants.cs_whls_domestic_ind_noncbk whls_domestic_ind_noncbk,
                pkg_constants.cs_whls_territory_ind_noncbk whls_territory_ind_noncbk,
                pkg_constants.cs_whls_loc_cd_noncbk whls_loc_cd_noncbk,
                pkg_constants.cs_cot_hhs_grantee cot_hhs_grantee,
                pkg_constants.cs_tt_indirect_sales tt_indirect_sales,
                pkg_constants.cs_tt_rebates tt_rebates,
                pkg_constants.cs_tt_fee tt_fee,
                pkg_constants.cs_tt_factr_rbt_fee tt_factr_rbt_fee,
                pkg_constants.cs_tt_govt tt_govt
           FROM hcrs.prfl_prod_wrk_v ppw
          WHERE ppw.prfl_id = i_prfl_id
            AND ppw.calc_typ_cd = i_calc_typ_cd
            AND ppw.ndc_lbl = i_ndc_lbl
            AND ppw.ndc_prod = i_ndc_prod
            AND ppw.ndc_pckg = i_ndc_pckg;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_mk_prod_wrk_t;


   PROCEDURE p_cnt_act_calc_comp_def_wrk_t
      (o_bndl_adj_cnt OUT NUMBER,
       o_chk_nom      OUT hcrs.prfl_prod_wrk_t.chk_nom%TYPE,
       o_chk_hhs      OUT hcrs.prfl_prod_wrk_t.chk_hhs%TYPE)
   IS
      /*************************************************************************
      * Procedure Name : p_cnt_act_calc_comp_def_wrk_t
      *   Input params : None
      *  Output params : o_bndl_adj_cnt - Count of active bundling adjusted lines
      *                : o_chk_nom - Y if active nominal check lines exist, else N
      *                : o_chk_hhs - Y if active HHS check lines exist, else N
      *        Returns : None
      *   Date Created : 03/01/2019
      *         Author : Joe Kidd
      *    Description : Counts active bundling, nominal, and HHS lines in the
      *                  calc component defintion working table
      *
      *                  NOTE: This procedure should only write to temporary
      *                  tables, so that it can be used during testing/debugging
      *                  in production.  No changes should be made to permanent
      *                  objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_cnt_act_calc_comp_def_wrk_t';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Counts active calc component defintion lines';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while counting active calc component defintion lines';
   BEGIN
      ----------------------------------------------------------
      -- Count use of bundling, nominal, HHS
      ----------------------------------------------------------
      SELECT SUM(
                CASE
                   WHEN t.bndl_comp_tran_ind = pkg_constants.cs_flag_yes
                     OR t.bndl_comp_nom_ind = pkg_constants.cs_flag_yes
                     OR t.bndl_comp_hhs_ind = pkg_constants.cs_flag_yes
                   THEN 1
                   ELSE 0
                END) bndl_adj_cnt,
             NVL( MAX( t.chk_nom), pkg_constants.cs_flag_no) chk_nom,
             NVL( MAX( t.chk_hhs), pkg_constants.cs_flag_no) chk_hhs
        INTO o_bndl_adj_cnt,
             o_chk_nom,
             o_chk_hhs
        FROM hcrs.prfl_prod_calc_comp_def2_wrk_t t
       WHERE t.active_ind = pkg_constants.cs_flag_yes;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_cnt_act_calc_comp_def_wrk_t;


   PROCEDURE p_mk_calc_comp_def_wrk_t
      (o_comp_def_cnt   OUT NUMBER,
       o_bndl_adj_cnt   OUT NUMBER,
       o_chk_nom        OUT hcrs.prfl_prod_wrk_t.chk_nom%TYPE,
       o_chk_hhs        OUT hcrs.prfl_prod_wrk_t.chk_hhs%TYPE,
       o_bad_accum_cnt  OUT NUMBER,
       o_deprecated_cnt OUT NUMBER,
       o_bad_trans_cnt  OUT NUMBER,
       o_bad_nom_cnt    OUT NUMBER,
       o_bad_hhs_cnt    OUT NUMBER)
   IS
      /*************************************************************************
      * Procedure Name : p_mk_calc_comp_def_wrk_t
      *   Input params : None
      *  Output params : o_comp_def_cnt - Count of component definitions
      *                : o_bndl_adj_cnt - Count of active bundling adjusted lines
      *                : o_chk_nom - Y if active nominal check lines exist, else N
      *                : o_chk_hhs - Y if active HHS check lines exist, else N
      *                : o_bad_accum_cnt - Count of lines with bad mark accum values
      *                : o_deprecated_cnt - Count of lines using deprecated columns
      *                : o_trans_cnt - Count of lines with bad trans amounts
      *                : o_nom_cnt - Count of lines with bad nom amounts
      *                : o_hhs_cnt - Count of lines with bad hhs amounts
      *        Returns : None
      *   Date Created : 10/17/2014
      *         Author : Joe Kidd
      *    Description : Populates the calc component defintion working table
      *
      *                  NOTE: This procedure should only write to temporary
      *                  tables, so that it can be used during testing/debugging
      *                  in production.  No changes should be made to permanent
      *                  objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
      *                            Add new bundling control columns
      *                            Add bundle adjustment count parameter
      *                            Remove unneeded transaction accumulation checks
      *  09/20/2017  Joe Kidd      CRQ-376489: Demand 10536: Revise Calc Methods for SPP Wholesalers
      *                            Add limit for contracted or non-contracted transactions
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters, Populate second working table
      *                            No longer populate associative array or throw errors
      *                            Get Units components from main table
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Use new customer location code function
      *                            Centralize GTT deletes
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_mk_calc_comp_def_wrk_t';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Populates the calc component defintion working table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while populating the calc component defintion working table';
   BEGIN
      -------------------------------------------------------
      -- Populate the calc component definition working table
      -------------------------------------------------------
      INSERT INTO hcrs.prfl_prod_calc_comp_def_wrk_t
         (prfl_id,
          co_id,
          ndc_lbl,
          ndc_prod,
          ndc_pckg,
          agency_typ_cd,
          prcss_typ_cd,
          calc_typ_cd,
          calc_mthd_cd,
          pri_whls_mthd_cd,
          comp_typ_cd,
          units_comp_typ_cd,
          trans_typ_grp_cd,
          cust_cot_grp_cd,
          whls_cot_grp_cd,
          eff_bgn_dt,
          eff_end_dt,
          tim_per_bgn_dt,
          tim_per_end_dt,
          trans_dt,
          trans_dt_range,
          trans_typ_incl_ind,
          cust_cot_incl_ind,
          cust_domestic_ind,
          cust_territory_ind,
          whls_cot_incl_ind,
          whls_domestic_ind,
          whls_territory_ind,
          comp_dllrs,
          tran_dllrs,
          tran_pckgs,
          tran_ppd,
          tran_bndl,
          tran_mark_accum,
          nom_chk_dllrs,
          nom_chk_pckgs,
          nom_chk_ppd,
          nom_chk_bndl,
          nom_mark_accum_comp,
          --nom_mark_accum_comp_units, -- No longer calculated
          nom_mark_accum_dllrs,
          nom_mark_accum_pckgs,
          nom_mark_accum_ppd,
          nom_mark_accum_bndl,
          --nom_comp_dllrs, -- No longer calculated
          hhs_chk_dllrs,
          hhs_chk_pckgs,
          hhs_chk_ppd,
          hhs_chk_bndl,
          hhs_mark_accum_comp,
          --hhs_mark_accum_comp_units, -- No longer calculated
          hhs_mark_accum_dllrs,
          hhs_mark_accum_pckgs,
          hhs_mark_accum_ppd,
          hhs_mark_accum_bndl,
          --hhs_comp_dllrs, -- No longer calculated
          cmt_txt)
         SELECT ppw.prfl_id,
                ppw.co_id,
                ppw.ndc_lbl,
                ppw.ndc_prod,
                ppw.ndc_pckg,
                ppw.agency_typ_cd,
                ppw.prcss_typ_cd,
                ppw.calc_typ_cd,
                ppw.calc_mthd_cd,
                ppw.pri_whls_mthd_cd,
                t.comp_typ_cd,
                t.units_comp_typ_cd,
                t.trans_typ_grp_cd,
                t.cust_cot_grp_cd,
                DECODE( t.trans_typ_grp_cd,
                        ppw.tt_indirect_sales, t.whls_cot_grp_cd,
                        ppw.whls_cot_grp_cd_noncbk) whls_cot_grp_cd,
                t.eff_bgn_dt,
                t.eff_end_dt,
                t.tim_per_bgn_dt,
                t.tim_per_end_dt,
                t.trans_dt,
                t.trans_dt_range,
                t.trans_typ_incl_ind,
                t.cust_cot_incl_ind,
                t.cust_domestic_ind,
                t.cust_territory_ind,
                DECODE( t.trans_typ_grp_cd,
                        ppw.tt_indirect_sales, t.whls_cot_incl_ind,
                        ppw.whls_cot_incl_ind_noncbk) whls_cot_incl_ind,
                DECODE( t.trans_typ_grp_cd,
                        ppw.tt_indirect_sales, t.whls_domestic_ind,
                        ppw.whls_domestic_ind_noncbk) whls_domestic_ind,
                DECODE( t.trans_typ_grp_cd,
                        ppw.tt_indirect_sales, t.whls_territory_ind,
                        ppw.whls_territory_ind_noncbk) whls_territory_ind,
                t.comp_dllrs,
                t.tran_dllrs,
                t.tran_pckgs,
                t.tran_ppd,
                t.tran_bndl,
                t.tran_mark_accum,
                t.nom_chk_dllrs,
                t.nom_chk_pckgs,
                t.nom_chk_ppd,
                t.nom_chk_bndl,
                t.nom_mark_accum_comp,
                --nom_mark_accum_comp_units, -- No longer calculated
                t.nom_mark_accum_dllrs,
                t.nom_mark_accum_pckgs,
                t.nom_mark_accum_ppd,
                t.nom_mark_accum_bndl,
                --nom_comp_dllrs, -- No longer calculated
                t.hhs_chk_dllrs,
                t.hhs_chk_pckgs,
                t.hhs_chk_ppd,
                t.hhs_chk_bndl,
                t.hhs_mark_accum_comp,
                --hhs_mark_accum_comp_units, -- No longer calculated
                t.hhs_mark_accum_dllrs,
                t.hhs_mark_accum_pckgs,
                t.hhs_mark_accum_ppd,
                t.hhs_mark_accum_bndl,
                --hhs_comp_dllrs, -- No longer calculated
                t.cmt_txt
           FROM hcrs.prfl_prod_wrk_t ppw,
                hcrs.calc_mthd_comp_trans_def_t t
          WHERE ppw.agency_typ_cd = t.agency_typ_cd
            AND ppw.prcss_typ_cd = t.prcss_typ_cd
            AND ppw.calc_typ_cd = t.calc_typ_cd
            AND ppw.calc_mthd_cd = t.calc_mthd_cd
            AND ppw.pri_whls_mthd_cd = t.pri_whls_mthd_cd
            AND SYSDATE BETWEEN t.eff_bgn_dt AND t.eff_end_dt
            AND ppw.end_dt BETWEEN t.tim_per_bgn_dt AND t.tim_per_end_dt
             -- Only use Annual Offset period when Offset exists
            AND (   (    ppw.sales_offset_days = 0
                     AND t.trans_dt_range <> ppw.trans_dt_range_ann_off)
                 OR ppw.sales_offset_days > 0)
            AND ppw.calc_min_ndc = ppw.flag_yes;
      ----------------------------------------------------------
      -- Populate the calc component definition working table #2
      ----------------------------------------------------------
      INSERT INTO hcrs.prfl_prod_calc_comp_def2_wrk_t
         (trans_typ_grp_cd,
          trans_typ_incl_ind,
          cust_cot_grp_cd,
          cust_cot_incl_ind,
          cust_loc_cd_list,
          whls_cot_grp_cd,
          whls_cot_incl_ind,
          whls_loc_cd_list,
          active_ind,
          comp_paid_bgn_dt,
          comp_paid_end_dt,
          comp_earn_bgn_dt,
          comp_earn_end_dt,
          mark_accum_all_ind,
          mark_accum_nom_ind,
          mark_accum_hhs_ind,
          mark_accum_contr_ind,
          mark_accum_fsscontr_ind,
          mark_accum_phscontr_ind,
          mark_accum_zerodllrs_ind,
          comp_typ_cd,
          units_comp_typ_cd,
          comp_dllrs,
          tran_dllrs,
          tran_pckgs,
          tran_ppd,
          tran_bndl,
          chk_nom,
          nom_chk_dllrs,
          nom_chk_pckgs,
          nom_chk_ppd,
          nom_chk_bndl,
          chk_hhs,
          hhs_chk_dllrs,
          hhs_chk_pckgs,
          hhs_chk_ppd,
          hhs_chk_bndl,
          bndl_comp_tran_ind,
          bndl_comp_nom_ind,
          bndl_comp_hhs_ind)
         WITH z
           AS (-- Get the constants
               SELECT ppw.prfl_id,
                      ppw.co_id,
                      ppw.ndc_lbl,
                      ppw.ndc_prod,
                      ppw.ndc_pckg,
                      ppw.agency_typ_cd,
                      ppw.prcss_typ_cd,
                      ppw.calc_typ_cd,
                      ppw.calc_mthd_cd,
                      ppw.pri_whls_mthd_cd,
                      ppw.start_dt,
                      ppw.end_dt,
                      ppw.ann_start_dt,
                      ppw.ann_end_dt,
                      ppw.ann_off_start_dt,
                      ppw.ann_off_end_dt,
                      ppw.whls_loc_cd_noncbk,
                      ppw.tt_indirect_sales,
                      ppw.flag_yes,
                      ppw.flag_no,
                      pkg_constants.cs_trans_dt_earn trans_dt_earn,
                      pkg_constants.cs_trans_dt_paid trans_dt_paid,
                      pkg_constants.cs_trans_dt_range_ann trans_dt_range_ann,
                      ppw.trans_dt_range_ann_off,
                      pkg_constants.cs_trans_dt_range_qtr trans_dt_range_qtr,
                      pkg_constants.cs_mark_accum_yes tma_yes,
                      pkg_constants.cs_mark_accum_no tma_no,
                      pkg_constants.cs_mark_accum_igr tma_igr,
                      pkg_constants.cs_tran_mark_accum_all tma_all,
                      pkg_constants.cs_tran_mark_accum_none tma_none,
                      pkg_constants.cs_tran_mark_accum_nom tma_nom,
                      pkg_constants.cs_tran_mark_accum_hhs tma_hhs,
                      pkg_constants.cs_tran_mark_accum_fssphscontr tma_fssphscontr,
                      pkg_constants.cs_tran_mark_accum_dllrszero tma_dllrszero,
                      pkg_constants.cs_tran_mark_accum_no_nom tma_no_nom,
                      pkg_constants.cs_tran_mark_accum_no_hhs tma_no_hhs,
                      pkg_constants.cs_tran_mark_accum_no_fpcontr tma_no_fpcontr,
                      pkg_constants.cs_tran_mark_accum_dllrsnonz tma_dllrsnonz,
                      pkg_constants.cs_tran_mark_accum_no_nom_hhs tma_no_nom_hhs,
                      pkg_constants.cs_tran_mark_accum_no_nhfpc tma_no_nhfpc,
                      pkg_constants.cs_tran_mark_accum_no_nhdz tma_no_nhdz,
                      pkg_constants.cs_tran_mark_accum_no_nhfpcdz tma_no_nhfpcdz,
                      pkg_constants.cs_tran_mark_accum_no_nom_fpc tma_no_nom_fpc,
                      pkg_constants.cs_tran_mark_accum_no_nom_dz tma_no_nom_dz,
                      pkg_constants.cs_tran_mark_accum_no_nfpcdz tma_no_nfpcdz,
                      pkg_constants.cs_tran_mark_accum_no_hhs_fpc tma_no_hhs_fpc,
                      pkg_constants.cs_tran_mark_accum_no_hhs_dz tma_no_hhs_dz,
                      pkg_constants.cs_tran_mark_accum_no_hfpcdz tma_no_hfpcdz,
                      pkg_constants.cs_tran_mark_accum_no_fpcdz tma_no_fpcdz,
                      pkg_constants.cs_tran_mark_accum_contr tma_contr,
                      pkg_constants.cs_tran_mark_accum_no_contr tma_no_contr,
                      pkg_constants.cs_tran_mark_accum_no_nom_cont tma_no_nom_cont
                 FROM hcrs.prfl_prod_wrk_t ppw
                WHERE ppw.calc_min_ndc = ppw.flag_yes
                  AND ROWNUM > 0
              ),
              y
           AS (-- Translate mark accum to indicators
               SELECT '' tran_mark_accum, '' mark_accum_all_ind, '' mark_accum_nom_ind, '' mark_accum_hhs_ind, '' mark_accum_contr_ind, '' mark_accum_fsscontr_ind, '' mark_accum_phscontr_ind, '' mark_accum_zerodllrs_ind FROM dual WHERE 1=2 UNION ALL
               SELECT z.tma_all,         z.tma_yes, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr FROM z UNION ALL -- ALL
               --SELECT z.tma_none,        z.tma_no,  z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr FROM z UNION ALL -- NONE - Ignore these lines as nothing would be accumulated
               SELECT z.tma_nom,         z.tma_igr, z.tma_yes, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr FROM z UNION ALL -- NOM
               SELECT z.tma_hhs,         z.tma_igr, z.tma_igr, z.tma_yes, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr FROM z UNION ALL -- HHS
               SELECT z.tma_contr,       z.tma_igr, z.tma_igr, z.tma_igr, z.tma_yes, z.tma_igr, z.tma_igr, z.tma_igr FROM z UNION ALL -- CONTR
               SELECT z.tma_fssphscontr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_yes, z.tma_igr, z.tma_igr FROM z UNION ALL -- FSSPHSCONTR, Needs two rows because FSS/PHS are now split
               SELECT z.tma_fssphscontr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_yes, z.tma_igr FROM z UNION ALL -- FSSPHSCONTR, Needs two rows because FSS/PHS are now split
               SELECT z.tma_dllrszero,   z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_yes FROM z UNION ALL -- DLLRSZERO
               SELECT z.tma_no_nom,      z.tma_igr, z.tma_no,  z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr FROM z UNION ALL -- NO_NOM
               SELECT z.tma_no_hhs,      z.tma_igr, z.tma_igr, z.tma_no,  z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr FROM z UNION ALL -- NO_HHS
               SELECT z.tma_no_contr,    z.tma_igr, z.tma_igr, z.tma_igr, z.tma_no,  z.tma_igr, z.tma_igr, z.tma_igr FROM z UNION ALL -- NO_CONTR
               SELECT z.tma_no_fpcontr,  z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_no,  z.tma_no,  z.tma_igr FROM z UNION ALL -- NO_FSSPHSCONTR
               SELECT z.tma_dllrsnonz,   z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_no  FROM z UNION ALL -- DLLRSNONZERO
               SELECT z.tma_no_nom_hhs,  z.tma_igr, z.tma_no,  z.tma_no,  z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr FROM z UNION ALL -- NO_NOM_HHS
               SELECT z.tma_no_nom_cont, z.tma_igr, z.tma_no,  z.tma_igr, z.tma_no,  z.tma_igr, z.tma_igr, z.tma_igr FROM z UNION ALL -- NO_NOM_CONTR
               SELECT z.tma_no_nom_fpc,  z.tma_igr, z.tma_no,  z.tma_igr, z.tma_igr, z.tma_no,  z.tma_no,  z.tma_igr FROM z UNION ALL -- NO_NOM_FSSPHSCONTR
               SELECT z.tma_no_nom_dz,   z.tma_igr, z.tma_no,  z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_no  FROM z UNION ALL -- NO_NOM_DLLRSZERO
               SELECT z.tma_no_nhfpc,    z.tma_igr, z.tma_no,  z.tma_no,  z.tma_igr, z.tma_no,  z.tma_no,  z.tma_igr FROM z UNION ALL -- NO_NOM_HHS_FSSPHSCONTR
               SELECT z.tma_no_nhdz,     z.tma_igr, z.tma_no,  z.tma_no,  z.tma_igr, z.tma_igr, z.tma_igr, z.tma_no  FROM z UNION ALL -- NO_NOM_HHS_DLLRSZERO
               SELECT z.tma_no_nhfpcdz,  z.tma_igr, z.tma_no,  z.tma_no,  z.tma_igr, z.tma_no,  z.tma_no,  z.tma_no  FROM z UNION ALL -- NO_NOM_HHS_FSSPHSCONTR_DLLRSZERO
               SELECT z.tma_no_nfpcdz,   z.tma_igr, z.tma_no,  z.tma_igr, z.tma_igr, z.tma_no,  z.tma_no,  z.tma_no  FROM z UNION ALL -- NO_NOM_FSSPHSCONTR_DLLRSZERO
               SELECT z.tma_no_hhs_fpc,  z.tma_igr, z.tma_igr, z.tma_no,  z.tma_igr, z.tma_no,  z.tma_no,  z.tma_igr FROM z UNION ALL -- NO_HHS_FSSPHSCONTR
               SELECT z.tma_no_hhs_dz,   z.tma_igr, z.tma_igr, z.tma_no,  z.tma_igr, z.tma_igr, z.tma_igr, z.tma_no  FROM z UNION ALL -- NO_HHS_DLLRSZERO
               SELECT z.tma_no_hfpcdz,   z.tma_igr, z.tma_igr, z.tma_no,  z.tma_igr, z.tma_no,  z.tma_no,  z.tma_no  FROM z UNION ALL -- NO_HHS_FSSPHSCONTR_DLLRSZERO
               SELECT z.tma_no_fpcdz,    z.tma_igr, z.tma_igr, z.tma_igr, z.tma_igr, z.tma_no,  z.tma_no,  z.tma_no  FROM z UNION ALL -- NO_FSSPHSCONTR_DLLRSZERO
               SELECT '' tran_mark_accum, '' mark_accum_all_ind, '' mark_accum_nom_ind, '' mark_accum_hhs_ind, '' mark_accum_contr_ind, '' mark_accum_fsscontr_ind, '' mark_accum_phscontr_ind, '' mark_accum_zerodllrs_ind FROM dual WHERE 1=2
              )
         SELECT ppccdw.trans_typ_grp_cd,
                ppccdw.trans_typ_incl_ind,
                ppccdw.cust_cot_grp_cd,
                ppccdw.cust_cot_incl_ind,
                -- Get customer location codes
                (SELECT hcrs.pkg_common_procedures.f_get_cust_loc_cd_list
                           (pkg_constants.cs_cust_loc_cd_mode_comp_cust,
                            ppccdw.cust_domestic_ind,
                            ppccdw.cust_territory_ind) cust_loc_cd_list
                   FROM dual) cust_loc_cd_list,
                ppccdw.whls_cot_grp_cd,
                ppccdw.whls_cot_incl_ind,
                -- Get wholesaler location codes
                (SELECT hcrs.pkg_common_procedures.f_get_cust_loc_cd_list
                           (pkg_constants.cs_cust_loc_cd_mode_comp_whls,
                            ppccdw.whls_domestic_ind,
                            ppccdw.whls_territory_ind,
                            ppccdw.trans_typ_grp_cd) whls_loc_cd_list
                   FROM dual) whls_loc_cd_list,
                z.flag_yes active_ind,
                CASE
                   WHEN ppccdw.trans_dt = z.trans_dt_paid
                    AND ppccdw.trans_dt_range = z.trans_dt_range_qtr
                   THEN z.start_dt
                   WHEN ppccdw.trans_dt = z.trans_dt_paid
                    AND ppccdw.trans_dt_range = z.trans_dt_range_ann
                   THEN z.ann_start_dt
                   WHEN ppccdw.trans_dt = z.trans_dt_paid
                    AND ppccdw.trans_dt_range = z.trans_dt_range_ann_off
                   THEN z.ann_off_start_dt
                END comp_paid_bgn_dt,
                CASE
                   WHEN ppccdw.trans_dt = z.trans_dt_paid
                    AND ppccdw.trans_dt_range = z.trans_dt_range_qtr
                   THEN z.end_dt
                   WHEN ppccdw.trans_dt = z.trans_dt_paid
                    AND ppccdw.trans_dt_range = z.trans_dt_range_ann
                   THEN z.ann_end_dt
                   WHEN ppccdw.trans_dt = z.trans_dt_paid
                    AND ppccdw.trans_dt_range = z.trans_dt_range_ann_off
                   THEN z.ann_off_end_dt
                END comp_paid_end_dt,
                CASE
                   WHEN ppccdw.trans_dt = z.trans_dt_earn
                    AND ppccdw.trans_dt_range = z.trans_dt_range_qtr
                   THEN z.start_dt
                   WHEN ppccdw.trans_dt = z.trans_dt_earn
                    AND ppccdw.trans_dt_range = z.trans_dt_range_ann
                   THEN z.ann_start_dt
                   WHEN ppccdw.trans_dt = z.trans_dt_earn
                    AND ppccdw.trans_dt_range = z.trans_dt_range_ann_off
                   THEN z.ann_off_start_dt
                END comp_earn_bgn_dt,
                CASE
                   WHEN ppccdw.trans_dt = z.trans_dt_earn
                    AND ppccdw.trans_dt_range = z.trans_dt_range_qtr
                   THEN z.end_dt
                   WHEN ppccdw.trans_dt = z.trans_dt_earn
                    AND ppccdw.trans_dt_range = z.trans_dt_range_ann
                   THEN z.ann_end_dt
                   WHEN ppccdw.trans_dt = z.trans_dt_earn
                    AND ppccdw.trans_dt_range = z.trans_dt_range_ann_off
                   THEN z.ann_off_end_dt
                END comp_earn_end_dt,
                y.mark_accum_all_ind,
                y.mark_accum_nom_ind,
                y.mark_accum_hhs_ind,
                y.mark_accum_contr_ind,
                y.mark_accum_fsscontr_ind,
                y.mark_accum_phscontr_ind,
                y.mark_accum_zerodllrs_ind,
                ppccdw.comp_typ_cd,
                ppccdw.units_comp_typ_cd,
                ppccdw.comp_dllrs,
                ppccdw.tran_dllrs,
                ppccdw.tran_pckgs,
                ppccdw.tran_ppd,
                ppccdw.tran_bndl,
                CASE
                   WHEN ppccdw.nom_chk_dllrs <> pkg_constants.cs_trans_dllrs_none
                    AND ppccdw.nom_chk_pckgs <> pkg_constants.cs_trans_dllrs_none
                   THEN pkg_constants.cs_flag_yes
                   ELSE pkg_constants.cs_flag_no
                END chk_nom,
                ppccdw.nom_chk_dllrs,
                ppccdw.nom_chk_pckgs,
                ppccdw.nom_chk_ppd,
                ppccdw.nom_chk_bndl,
                CASE
                   WHEN ppccdw.hhs_chk_dllrs <> pkg_constants.cs_trans_dllrs_none
                    AND ppccdw.hhs_chk_pckgs <> pkg_constants.cs_trans_dllrs_none
                   THEN pkg_constants.cs_flag_yes
                   ELSE pkg_constants.cs_flag_no
                END chk_hhs,
                ppccdw.hhs_chk_dllrs,
                ppccdw.hhs_chk_pckgs,
                ppccdw.hhs_chk_ppd,
                ppccdw.hhs_chk_bndl,
                -- Set bundled component flag
                -- 4.3. The transaction must be used by a component which
                --      requires either the Net or Discount dollars of the
                --      transaction for one or more of the following:
                --      component accumulation, nominal checking, HHS violation
                --      checking.
                CASE
                   WHEN -- Trans accum uses default bundling and needs one of /nec/dsc/bundle adj amount
                        (   (    ppccdw.tran_bndl = pkg_constants.cs_trans_bndl_def
                             AND ppccdw.tran_dllrs IN (pkg_constants.cs_trans_dllrs_net,
                                                       pkg_constants.cs_trans_dllrs_dsc,
                                                       pkg_constants.cs_trans_dllrs_bndl)
                        -- Trans accum uses bundling and uses any dollar component
                         OR (    ppccdw.tran_bndl = pkg_constants.cs_trans_bndl_adj
                             AND ppccdw.tran_dllrs <> pkg_constants.cs_trans_dllrs_none)
                            )
                        )
                   THEN pkg_constants.cs_flag_yes
                   ELSE pkg_constants.cs_flag_no
                END bndl_tran_comp_ind,
                CASE
                   WHEN -- Nominal Check uses default bundling and needs one of /nec/dsc/bundle adj amount
                        (   (    ppccdw.nom_chk_bndl = pkg_constants.cs_trans_bndl_def
                             AND ppccdw.nom_chk_dllrs IN (pkg_constants.cs_trans_dllrs_net,
                                                          pkg_constants.cs_trans_dllrs_dsc,
                                                          pkg_constants.cs_trans_dllrs_bndl)
                        -- Nominal Check uses bundling and uses any dollar component
                         OR (    ppccdw.nom_chk_bndl = pkg_constants.cs_trans_bndl_adj
                             AND ppccdw.nom_chk_dllrs <> pkg_constants.cs_trans_dllrs_none)
                            )
                        )
                   THEN pkg_constants.cs_flag_yes
                   ELSE pkg_constants.cs_flag_no
                END bndl_nom_comp_ind,
                CASE
                   WHEN -- Sub-PHS Check uses default bundling and needs one of /nec/dsc/bundle adj amount
                        (   (    ppccdw.hhs_chk_bndl = pkg_constants.cs_trans_bndl_def
                             AND ppccdw.hhs_chk_dllrs IN (pkg_constants.cs_trans_dllrs_net,
                                                          pkg_constants.cs_trans_dllrs_dsc,
                                                          pkg_constants.cs_trans_dllrs_bndl)
                        -- Sub-PHS Check uses bundling and uses any dollar component
                         OR (    ppccdw.hhs_chk_bndl = pkg_constants.cs_trans_bndl_adj
                             AND ppccdw.hhs_chk_dllrs <> pkg_constants.cs_trans_dllrs_none)
                            )
                        )
                   THEN pkg_constants.cs_flag_yes
                   ELSE pkg_constants.cs_flag_no
                END bndl_hhs_comp_ind
           FROM z,
                hcrs.prfl_prod_calc_comp_def_wrk_t ppccdw,
                y
          WHERE z.prfl_id = ppccdw.prfl_id
            AND z.co_id = ppccdw.co_id
            AND z.ndc_lbl = ppccdw.ndc_lbl
            AND z.ndc_prod = ppccdw.ndc_prod
            AND z.ndc_pckg = ppccdw.ndc_pckg
            AND z.agency_typ_cd = ppccdw.agency_typ_cd
            AND z.prcss_typ_cd = ppccdw.prcss_typ_cd
            AND z.calc_typ_cd = ppccdw.calc_typ_cd
            AND z.calc_mthd_cd = ppccdw.calc_mthd_cd
            AND z.pri_whls_mthd_cd = ppccdw.pri_whls_mthd_cd
            AND ppccdw.tran_mark_accum = y.tran_mark_accum (+)
          ORDER BY ppccdw.comp_typ_cd,
                   ppccdw.trans_typ_grp_cd,
                   ppccdw.trans_typ_incl_ind,
                   ppccdw.cust_cot_grp_cd,
                   ppccdw.cust_cot_incl_ind,
                   cust_loc_cd_list,
                   ppccdw.whls_cot_grp_cd,
                   ppccdw.whls_cot_incl_ind,
                   whls_loc_cd_list;
      o_comp_def_cnt := SQL%ROWCOUNT;
      ----------------------------------------------------------
      -- Count use of bundling, nominal, HHS
      ----------------------------------------------------------
      p_cnt_act_calc_comp_def_wrk_t
         (o_bndl_adj_cnt,
          o_chk_nom,
          o_chk_hhs);
      ----------------------------------------------------------
      -- Validate the accumulation settings
      -- Validate no deprecated fields used
      ----------------------------------------------------------
      SELECT SUM(
                CASE
                   WHEN t.tran_mark_accum NOT IN
                        (pkg_constants.cs_tran_mark_accum_all,
                         pkg_constants.cs_tran_mark_accum_none,
                         pkg_constants.cs_tran_mark_accum_nom,
                         pkg_constants.cs_tran_mark_accum_hhs,
                         pkg_constants.cs_tran_mark_accum_fssphscontr,
                         pkg_constants.cs_tran_mark_accum_contr,
                         pkg_constants.cs_tran_mark_accum_dllrszero,
                         pkg_constants.cs_tran_mark_accum_no_nom,
                         pkg_constants.cs_tran_mark_accum_no_hhs,
                         pkg_constants.cs_tran_mark_accum_no_fpcontr,
                         pkg_constants.cs_tran_mark_accum_no_contr,
                         pkg_constants.cs_tran_mark_accum_dllrsnonz,
                         pkg_constants.cs_tran_mark_accum_no_nom_hhs,
                         pkg_constants.cs_tran_mark_accum_no_nhfpc,
                         pkg_constants.cs_tran_mark_accum_no_nhdz,
                         pkg_constants.cs_tran_mark_accum_no_nhfpcdz,
                         pkg_constants.cs_tran_mark_accum_no_nom_fpc,
                         pkg_constants.cs_tran_mark_accum_no_nom_cont,
                         pkg_constants.cs_tran_mark_accum_no_nom_dz,
                         pkg_constants.cs_tran_mark_accum_no_nfpcdz,
                         pkg_constants.cs_tran_mark_accum_no_hhs_fpc,
                         pkg_constants.cs_tran_mark_accum_no_hhs_dz,
                         pkg_constants.cs_tran_mark_accum_no_hfpcdz,
                         pkg_constants.cs_tran_mark_accum_no_fpcdz)
                   THEN 1
                   ELSE 0
                END) bad_accum_cnt,
             SUM(
                CASE
                   WHEN t.nom_mark_accum_comp IS NOT NULL
                     OR t.hhs_mark_accum_comp IS NOT NULL
                   THEN 1
                   ELSE 0
                END) deprecated_cnt
        INTO o_bad_accum_cnt,
             o_deprecated_cnt
        FROM hcrs.prfl_prod_calc_comp_def_wrk_t t;
      ----------------------------------------------------------
      -- Validate the trans amount settings
      -- Validate nominal and hhs check settings
      ----------------------------------------------------------
      SELECT SUM(
                CASE
                   WHEN t.tran_dllrs = pkg_constants.cs_trans_dllrs_none
                    AND t.tran_pckgs = pkg_constants.cs_trans_pckgs_none
                    AND t.tran_ppd = pkg_constants.cs_trans_ppd_none
                    AND t.tran_bndl = pkg_constants.cs_trans_bndl_none
                   THEN 1
                   ELSE 0
                END) bad_trans_cnt,
             SUM(
                CASE
                   WHEN t.mark_accum_nom_ind <> pkg_constants.cs_mark_accum_igr
                    AND t.nom_chk_dllrs = pkg_constants.cs_trans_dllrs_none
                    AND t.nom_chk_pckgs = pkg_constants.cs_trans_pckgs_none
                   THEN 1
                   ELSE 0
                END) bad_nom_cnt,
             SUM(
                CASE
                   WHEN t.mark_accum_hhs_ind <> pkg_constants.cs_mark_accum_igr
                    AND t.hhs_chk_dllrs = pkg_constants.cs_trans_dllrs_none
                    AND t.hhs_chk_pckgs = pkg_constants.cs_trans_pckgs_none
                   THEN 1
                   ELSE 0
                END) bad_hhs_cnt
        INTO o_bad_trans_cnt,
             o_bad_nom_cnt,
             o_bad_hhs_cnt
        FROM hcrs.prfl_prod_calc_comp_def2_wrk_t t;
      -- Temporarily disable these checks:
      o_bad_trans_cnt := 0;
      o_bad_nom_cnt := 0;
      o_bad_hhs_cnt := 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_mk_calc_comp_def_wrk_t;


   PROCEDURE p_mk_mtrx_wrk_t
   IS
      /*************************************************************************
      * Procedure Name : p_mk_mtrx_wrk_t
      *   Input params : None
      *  Output params : None
      *        Returns : None
      *   Date Created : 12/05/2007
      *         Author : Joe Kidd
      *    Description : Populates the matrix working table (GTT)
      *                  Populate customer COT working table (GTT)
      *
      *                  1. Load Matrix GTT with COTs/TTs used by Components or
      *                     by Split Percentage mappings.
      *                  2. Load Customer COT table with customers where the COT
      *                     is in the matrix and the customer location is used by
      *                     components.
      *                  3. Delete COTs from the Matrix GTT that are not assigned
      *                     to customers or split percentages.
      *
      *                  NOTE: This procedure should only write to temporary
      *                  tables, so that it can be used during testing/debugging
      *                  in production.  No changes should be made to permanent
      *                  objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  08/22/2008  Joe Kidd      PICC 1961: Delete instead of Truncate
      *  04/01/2011  Joe Kidd      CRQ-3921: Linking of CARS chargebacks
      *                            Remove error logging and use error call stack
      *                            to allow init_calc use for debugging in prod
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Pass only calc parameter record
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Populate Profile Cust COT working table
      *                            Populate new uses net/discount column
      *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
      *                            Add new bundling control columns
      *                            Populate Profile COT working table
      *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
      *                            Remove wholesaler COT SG limit
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Remove parameters
      *                            Remove Trans Type Group process seq number
      *                            Add flags for paid date and earn date use
      *                            Remove class of trade working table
      *                            Populate cust cot working table with dates
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Tune CCOT insert, correct hints
      *                            Centralize GTT deletes
      *                            Add normal exception handling (Calc Debug Mode)
      *                            GTT column reductions
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_mk_mtrx_wrk_t';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Populates the matrix working table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while populating the matrix working table';
   BEGIN
      ---------------------------------------------------------------------------------------------------
      -- Limit matrix entries to only entries that will be used by the calculation (part 1)
      ---------------------------------------------------------------------------------------------------
      -- COT or TT must be used by the Component Definitions or Split Percentages
      INSERT INTO hcrs.prfl_mtrx_wrk_t
         (cls_of_trd_cd,
          trans_typ_cd,
          cot_incl_ind,
          incl_ind,
          cot_grp_cd,
          trans_typ_grp_cd,
          cot_begn_dt,
          cot_end_dt,
          tt_begn_dt,
          tt_end_dt,
          uses_paid_dt,
          uses_earn_dt,
          uses_net_dsc)
         WITH pw
           AS (-- Get the calc parameters and constants
               SELECT ppw.prfl_id,
                      ppw.co_id,
                      ppw.ndc_lbl,
                      ppw.ndc_prod,
                      ppw.ndc_pckg,
                      ppw.agency_typ_cd,
                      ppw.prcss_typ_cd,
                      ppw.calc_typ_cd,
                      ppw.calc_mthd_cd,
                      ppw.pri_whls_mthd_cd,
                      pkg_constants.cs_trans_dllrs_net dllrs_net,
                      pkg_constants.cs_trans_dllrs_dsc dllrs_dsc,
                      pkg_constants.cs_trans_dllrs_bndl dllrs_bndl,
                      pkg_constants.cs_trans_bndl_adj bndl_adj,
                      pkg_constants.cs_trans_bndl_none bndl_none,
                      pkg_constants.cs_trans_dt_paid trans_dt_paid,
                      pkg_constants.cs_trans_dt_earn trans_dt_earn,
                      ppw.flag_yes,
                      ppw.flag_no
                 FROM hcrs.prfl_prod_wrk_t ppw
                WHERE ppw.calc_min_ndc = ppw.flag_yes
              ),
              pm
           AS (-- Materialize the matrix for performance
               SELECT pm.cls_of_trd_cd,
                      pm.trans_typ_cd,
                      pm.cot_incl_ind,
                      pm.incl_ind,
                      pm.cot_grp_cd,
                      pm.trans_typ_grp_cd,
                      pm.cot_begn_dt,
                      pm.cot_end_dt,
                      pm.tt_begn_dt,
                      pm.tt_end_dt,
                      pw.flag_yes,
                      pw.flag_no
                 FROM pw,
                      hcrs.prfl_mtrx_v pm
                WHERE pw.prfl_id = pm.prfl_id
                  AND pw.calc_typ_cd = pm.calc_typ_cd
                  AND pw.co_id = pm.co_id
                  AND pw.pri_whls_mthd_cd = pm.pri_whls_mthd_cd
                  AND ROWNUM > 0 -- materialize
              ),
              cmp
           AS (-- Get COT-TT SG and Elig combinations from component definitions
               -- Customer COT-TT SG and Elig combinations
               -- Wholesaler COT-TT SG and Elig combinations
               SELECT DISTINCT
                      ppccdw.trans_typ_grp_cd,
                      DECODE( n.n, 1, ppccdw.cust_cot_grp_cd, ppccdw.whls_cot_grp_cd) cot_grp_cd,
                      ppccdw.trans_typ_incl_ind incl_ind,
                      DECODE( n.n, 1, ppccdw.cust_cot_incl_ind, ppccdw.whls_cot_incl_ind) cot_incl_ind,
                      DECODE( ppccdw.comp_paid_bgn_dt, NULL, pw.flag_no, pw.flag_yes) uses_paid_dt,
                      DECODE( ppccdw.comp_earn_bgn_dt, NULL, pw.flag_no, pw.flag_yes) uses_earn_dt,
                      CASE
                         WHEN pw.flag_yes IN (ppccdw.bndl_comp_tran_ind,
                                              ppccdw.bndl_comp_nom_ind,
                                              ppccdw.bndl_comp_hhs_ind)
                         THEN pw.flag_yes
                      END uses_net_dsc
                 FROM pw,
                      ( -- Allows a single scan to give both cust and whls above
                        SELECT 1 n FROM dual UNION ALL
                        SELECT 2 n FROM dual
                      ) n,
                      hcrs.prfl_prod_calc_comp_def2_wrk_t ppccdw
                WHERE ROWNUM > 0 -- materialize
                  AND ppccdw.active_ind = pw.flag_yes
              ),
              sp
           AS (-- Get the split percentage COT/TTs
               SELECT pcpspw.src_cls_of_trd_cd cls_of_trd_cd,
                      pcpspw.src_trans_typ_cd trans_typ_cd
                 FROM hcrs.prfl_contr_prod_splt_pct_wrk_t pcpspw
               UNION -- needed to distinct
               SELECT pcpspw.dst_cls_of_trd_cd cls_of_trd_cd,
                      pcpspw.dst_trans_typ_cd trans_typ_cd
                 FROM hcrs.prfl_contr_prod_splt_pct_wrk_t pcpspw
              ),
              cb
           AS (-- Combine the matrix with the component definitions and split percentages
               SELECT pm.cls_of_trd_cd,
                      pm.trans_typ_cd,
                      pm.cot_incl_ind,
                      pm.incl_ind,
                      pm.cot_grp_cd,
                      pm.trans_typ_grp_cd,
                      pm.cot_begn_dt,
                      pm.cot_end_dt,
                      pm.tt_begn_dt,
                      pm.tt_end_dt,
                      cmp.uses_paid_dt,
                      cmp.uses_earn_dt,
                      cmp.uses_net_dsc,
                      pm.flag_no
                 FROM pm,
                      cmp
                WHERE pm.trans_typ_grp_cd = cmp.trans_typ_grp_cd
                  AND pm.cot_grp_cd = cmp.cot_grp_cd
                  AND pm.cot_incl_ind = cmp.cot_incl_ind
                  AND pm.incl_ind = cmp.incl_ind
               UNION ALL
               SELECT pm.cls_of_trd_cd,
                      pm.trans_typ_cd,
                      pm.cot_incl_ind,
                      pm.incl_ind,
                      pm.cot_grp_cd,
                      pm.trans_typ_grp_cd,
                      pm.cot_begn_dt,
                      pm.cot_end_dt,
                      pm.tt_begn_dt,
                      pm.tt_end_dt,
                      '' uses_paid_dt,
                      '' uses_earn_dt,
                      '' uses_net_dsc,
                      pm.flag_no
                 FROM pm,
                      sp
                WHERE pm.cls_of_trd_cd = sp.cls_of_trd_cd
                  AND pm.trans_typ_cd = sp.trans_typ_cd
              )
         -- Combine the component definition values with the matrix
         SELECT cb.cls_of_trd_cd,
                cb.trans_typ_cd,
                cb.cot_incl_ind,
                cb.incl_ind,
                cb.cot_grp_cd,
                cb.trans_typ_grp_cd,
                cb.cot_begn_dt,
                cb.cot_end_dt,
                cb.tt_begn_dt,
                cb.tt_end_dt,
                -- If any line uses paid date, set to Y
                NVL( MAX( cb.uses_paid_dt), cb.flag_no) uses_paid_dt,
                -- If any line uses earn date, set to Y
                NVL( MAX( cb.uses_earn_dt), cb.flag_no) uses_earn_dt,
                -- If any line uses net discount, set to Y
                NVL( MAX( cb.uses_net_dsc), cb.flag_no) uses_net_dsc
           FROM cb
          GROUP BY cb.cls_of_trd_cd,
                   cb.trans_typ_cd,
                   cb.cot_incl_ind,
                   cb.incl_ind,
                   cb.cot_grp_cd,
                   cb.trans_typ_grp_cd,
                   cb.cot_begn_dt,
                   cb.cot_end_dt,
                   cb.tt_begn_dt,
                   cb.tt_end_dt,
                   cb.flag_no
          ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;
      ---------------------------------------------------------------------------------------------------
      -- Limit customer classes of trade to only what will be used by the calculation
      ---------------------------------------------------------------------------------------------------
      INSERT INTO hcrs.prfl_cust_cls_of_trd_wrk_t
         (cust_id,
          strt_dt,
          end_dt,
          cls_of_trd_cd,
          cust_loc_cd)
         WITH cmp
           AS (-- Get the COT supergroups and locations for active Components
               SELECT ppw.prfl_id,
                      ppw.co_id,
                      ppccdw.cust_cot_grp_cd,
                      ppccdw.cust_loc_cd_list
                 FROM hcrs.prfl_prod_wrk_t ppw,
                      hcrs.prfl_prod_calc_comp_def2_wrk_t ppccdw
                WHERE ppw.calc_min_ndc = ppw.flag_yes
                  AND ppccdw.active_ind = ppw.flag_yes
               UNION -- Does DISTINCT
               SELECT ppw.prfl_id,
                      ppw.co_id,
                      ppccdw.whls_cot_grp_cd cust_cot_grp_cd,
                      ppccdw.whls_loc_cd_list cust_loc_cd_list
                 FROM hcrs.prfl_prod_wrk_t ppw,
                      hcrs.prfl_prod_calc_comp_def2_wrk_t ppccdw
                WHERE ppw.calc_min_ndc = ppw.flag_yes
                  AND ppccdw.active_ind = ppw.flag_yes
                  AND ppw.tt_indirect_sales = ppccdw.trans_typ_grp_cd
              ),
              cot
           AS (-- Convert COT supergroups to COTs, with locations for active Components
               SELECT DISTINCT
                      z.prfl_id,
                      z.co_id,
                      pmw.cls_of_trd_cd,
                      z.cust_loc_cd_list
                 FROM cmp z,
                      hcrs.prfl_mtrx_wrk_t pmw
                WHERE z.cust_cot_grp_cd = pmw.cot_grp_cd
              ),
              ccot0
           AS (-- Get the Customers for the COTs for active Components with locations
               SELECT pccot.cust_id,
                      pccot.strt_dt,
                      pccot.end_dt,
                      pccot.cls_of_trd_cd,
                      -- Get customer location code
                      (SELECT hcrs.pkg_common_procedures.f_get_cust_loc_cd_list
                                 (pkg_constants.cs_cust_loc_cd_mode_cust,
                                  pccot.domestic_ind,
                                  pccot.territory_ind) cust_loc_cd
                         FROM dual) cust_loc_cd,
                      z.cust_loc_cd_list
                 FROM cot z,
                      hcrs.prfl_cust_cls_of_trd_t pccot
                WHERE z.prfl_id = pccot.prfl_id
                  AND z.co_id = pccot.co_id
                  AND z.cls_of_trd_cd = pccot.cls_of_trd_cd
              ),
              ccot
           AS (-- Remove customers with wrong locations for COT
               SELECT z.cust_id,
                      z.strt_dt,
                      z.end_dt,
                      z.cls_of_trd_cd,
                      z.cust_loc_cd
                 FROM ccot0 z
                WHERE z.cust_loc_cd_list LIKE '%' || z.cust_loc_cd || '%'
              ),
              dt0
           AS (-- Collapse contigous/overlapping date ranges: Analyze the dates on the key
               SELECT /*+ NO_MERGE */
                      z.cust_id,
                      z.strt_dt,
                      z.end_dt,
                      z.cls_of_trd_cd,
                      -- Get the end date of the previous row partitioned by the key, ordered by the start date, end date
                      LAG( z.end_dt)
                         OVER (PARTITION BY z.cust_id,
                                            z.cls_of_trd_cd
                                   ORDER BY z.strt_dt,
                                            z.end_dt) + 1 prev_end_dt,
                      -- Get the row number partitioned by the key, ordered by the start date, end date
                      ROW_NUMBER()
                         OVER (PARTITION BY z.cust_id,
                                            z.cls_of_trd_cd
                                   ORDER BY z.strt_dt,
                                            z.end_dt) row_num,
                      z.cust_loc_cd
                 FROM ccot z
              ),
              dt1
           AS (-- Collapse contigous/overlapping date ranges: Mark non-contiguous rows
               SELECT /*+ NO_MERGE */
                      z.cust_id,
                      z.strt_dt,
                      z.end_dt,
                      z.cls_of_trd_cd,
                      z.prev_end_dt,
                      z.row_num,
                      CASE
                         -- Row is non-contiguous/non-overlapping
                         WHEN z.prev_end_dt IS NULL
                           OR z.strt_dt > z.prev_end_dt
                         THEN z.row_num
                         -- Row is contiguous/overlapping
                         ELSE 0
                      END mk_num,
                      z.cust_loc_cd
                 FROM dt0 z
              ),
              dt
           AS (-- Collapse contigous/overlapping date ranges: Mark contiguous rows with the same group number
               SELECT /*+ NO_MERGE */
                      z.cust_id,
                      z.strt_dt,
                      z.end_dt,
                      z.cls_of_trd_cd,
                      z.prev_end_dt,
                      z.row_num,
                      z.mk_num,
                      MAX( z.mk_num)
                         OVER (PARTITION BY z.cust_id,
                                            z.cls_of_trd_cd
                                   ORDER BY z.strt_dt,
                                            z.end_dt) mk_grp,
                      z.cust_loc_cd
                 FROM dt1 z
              )
         -- Collapse contigous date ranges
         SELECT /*+ NO_MERGE */
                z.cust_id,
                MIN( z.strt_dt) strt_dt,
                MAX( z.end_dt) end_dt,
                z.cls_of_trd_cd,
                z.cust_loc_cd
           FROM dt z
          GROUP BY z.cust_id,
                   z.cls_of_trd_cd,
                   z.cust_loc_cd,
                   z.mk_grp
          ORDER BY 1, 2, 3;
      ---------------------------------------------------------------------------------------------------
      -- Limit matrix entries to only entries that will be used by the calculation (part 2)
      ---------------------------------------------------------------------------------------------------
      -- Remove COTs from the matrix that are not used by customers and not used by split percentages
      DELETE
        FROM hcrs.prfl_mtrx_wrk_t pmw
       WHERE NOT EXISTS
             (-- Check the customer COTs
               SELECT NULL
                 FROM hcrs.prfl_cust_cls_of_trd_wrk_t pccotw
                WHERE pccotw.cls_of_trd_cd = pmw.cls_of_trd_cd
             )
         AND NOT EXISTS
             (-- Check the split percentage COTs
               SELECT NULL
                 FROM hcrs.prfl_contr_prod_splt_pct_wrk_t pcpspw
                WHERE pcpspw.src_cls_of_trd_cd = pmw.cls_of_trd_cd
               UNION ALL
               SELECT NULL
                 FROM hcrs.prfl_contr_prod_splt_pct_wrk_t pcpspw
                WHERE pcpspw.dst_cls_of_trd_cd = pmw.cls_of_trd_cd
              );
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_mk_mtrx_wrk_t;


   PROCEDURE p_mk_splt_pct_wrk_t
      (i_pass IN NUMBER)
   IS
      /*************************************************************************
      * Procedure Name : p_mk_splt_pct_wrk_t
      *   Input params : i_pass - the pass number
      *  Output params : None
      *        Returns : None
      *   Date Created : 12/05/2007
      *         Author : Joe Kidd
      *    Description : Populates the split percentages working table
      *                  Pass 1 - load all split percents
      *                  Pass 2 - reload, limit by matrix, create original,
      *                           reversal, reallocation rows for each percentage
      *
      *                  NOTE: This procedure should only write to temporary
      *                  tables, so that it can be used during testing/debugging
      *                  in production.  No changes should be made to permanent
      *                  objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  04/01/2011  Joe Kidd      CRQ-3921: Linking of CARS chargebacks
      *                            Remove error logging and use error call stack
      *                            to allow init_calc use for debugging in prod
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Pass only calc parameter record
      *                            Change refernces to NDC in product work table
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Remove transaction date range overlap restriction
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters to allow two passes
      *                            Populate working table instead of associative array
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_mk_splt_pct_wrk_t';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Populates the split percent working table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while populating the split percent working table';
   BEGIN
      -- Always delete because this is called twice, before and after the matrix
      DELETE FROM hcrs.prfl_contr_prod_splt_pct_wrk_t;
      INSERT INTO hcrs.prfl_contr_prod_splt_pct_wrk_t
         (contr_id,
          ndc_lbl,
          ndc_prod,
          ndc_pckg,
          src_cls_of_trd_cd,
          src_trans_typ_cd,
          splt_begn_dt,
          splt_end_dt,
          splt_pct_strt_dt,
          splt_pct_end_dt,
          splt_pct_ord,
          splt_pct_typ,
          splt_pct,
          splt_pct_seq_no,
          dst_cls_of_trd_cd,
          dst_trans_typ_cd,
          dst_cot_incl_ind,
          dst_cot_grp_cd,
          dst_cot_begn_dt,
          dst_cot_end_dt,
          dst_tt_incl_ind,
          dst_tt_grp_cd,
          dst_tt_begn_dt,
          dst_tt_end_dt,
          trans_adj_cd)
         WITH z
           AS (-- Get the split percentages
               SELECT pcpsp.contr_id,
                      pcpsp.ndc_lbl,
                      pcpsp.ndc_prod,
                      pcpsp.ndc_pckg,
                      psp.src_cls_of_trd_cd,
                      psp.src_trans_typ_cd,
                      psp.begn_dt splt_begn_dt,
                      psp.end_dt splt_end_dt,
                      pcpsp.strt_dt splt_pct_strt_dt,
                      pcpsp.end_dt splt_pct_end_dt,
                      pcpsp.splt_pct_typ,
                      pcpsp.splt_pct,
                      pcpsp.splt_pct_seq_no,
                      psp.dst_cls_of_trd_cd,
                      psp.dst_trans_typ_cd,
                      ppw.flag_no dst_cot_incl_ind,
                      ppw.flag_no dst_cot_grp_cd,
                      ppw.begin_time dst_cot_begn_dt,
                      ppw.end_time dst_cot_end_dt,
                      ppw.flag_no dst_tt_incl_ind,
                      ppw.flag_no dst_tt_grp_cd,
                      ppw.begin_time dst_tt_begn_dt,
                      ppw.end_time dst_tt_end_dt
                 FROM hcrs.prfl_prod_wrk_t ppw,
                      hcrs.prfl_splt_pct_t psp,
                      hcrs.prfl_contr_prod_splt_pct_t pcpsp
                   -- PPW-PSP: Products to Split Percentage Mapping
                WHERE ppw.prfl_id = psp.prfl_id
                  AND ppw.co_id = psp.co_id
                  AND ppw.calc_typ_cd = psp.calc_typ_cd
                  AND ppw.pri_whls_mthd_cd = psp.pri_whls_mthd_cd
                   -- PPW-PCPSP: Products to Contract Product Split Percentages
                  AND ppw.prfl_id = pcpsp.prfl_id
                  AND ppw.co_id = pcpsp.co_id
                  AND ppw.trans_ndc_lbl = pcpsp.ndc_lbl
                  AND ppw.trans_ndc_prod = pcpsp.ndc_prod
                  AND ppw.trans_ndc_pckg = pcpsp.ndc_pckg
                   -- PSP-PCPSP: Split Percentage Mapping to Contract Product Split Percentages
                  AND psp.prfl_id = pcpsp.prfl_id
                  AND psp.co_id = pcpsp.co_id
                  AND psp.splt_pct_typ = pcpsp.splt_pct_typ
                  -- Split percentage must be greater than zero
                  -- and less than or equal to 1
                  AND pcpsp.splt_pct > 0
                  AND pcpsp.splt_pct <= 1
              ),
              y
           AS (-- Limit by the matrix (skip if src and dst not in the matrix)
               SELECT z.contr_id,
                      z.ndc_lbl,
                      z.ndc_prod,
                      z.ndc_pckg,
                      z.src_cls_of_trd_cd,
                      z.src_trans_typ_cd,
                      z.splt_begn_dt,
                      z.splt_end_dt,
                      z.splt_pct_strt_dt,
                      z.splt_pct_end_dt,
                      z.splt_pct_typ,
                      z.splt_pct,
                      z.splt_pct_seq_no,
                      z.dst_cls_of_trd_cd,
                      z.dst_trans_typ_cd,
                      pmw.cot_incl_ind dst_cot_incl_ind,
                      pmw.cot_grp_cd dst_cot_grp_cd,
                      pmw.cot_begn_dt dst_cot_begn_dt,
                      pmw.cot_end_dt dst_cot_end_dt,
                      pmw.incl_ind dst_tt_incl_ind,
                      pmw.trans_typ_grp_cd dst_tt_grp_cd,
                      pmw.tt_begn_dt dst_tt_begn_dt,
                      pmw.tt_end_dt dst_tt_end_dt
                 FROM z,
                      hcrs.prfl_mtrx_wrk_t pmw
                WHERE z.dst_cls_of_trd_cd = pmw.cls_of_trd_cd
                  AND z.dst_trans_typ_cd = pmw.trans_typ_cd
                  AND z.splt_begn_dt <= pmw.cot_end_dt
                  AND pmw.cot_begn_dt <= z.splt_end_dt
                  AND z.splt_begn_dt <= pmw.tt_end_dt
                  AND pmw.tt_begn_dt <= z.splt_end_dt
              ),
              x
           AS (-- Map source to source as 100% to keep original trans
               SELECT z.contr_id,
                      z.ndc_lbl,
                      z.ndc_prod,
                      z.ndc_pckg,
                      z.src_cls_of_trd_cd,
                      z.src_trans_typ_cd,
                      z.splt_begn_dt,
                      z.splt_end_dt,
                      z.splt_pct_strt_dt,
                      z.splt_pct_end_dt,
                      1 splt_pct_ord,
                      '' splt_pct_typ,
                      1 splt_pct,
                      TO_NUMBER( NULL) splt_pct_seq_no,
                      '' dst_cls_of_trd_cd,
                      '' dst_trans_typ_cd,
                      '' dst_cot_incl_ind,
                      '' dst_cot_grp_cd,
                      TO_DATE( NULL) dst_cot_begn_dt,
                      TO_DATE( NULL) dst_cot_end_dt,
                      '' dst_tt_incl_ind,
                      '' dst_tt_grp_cd,
                      TO_DATE( NULL) dst_tt_begn_dt,
                      TO_DATE( NULL) dst_tt_end_dt,
                      '' trans_adj_cd
                 FROM y z
               UNION ALL
               -- Map source to source as negative % to reverse out
               SELECT z.contr_id,
                      z.ndc_lbl,
                      z.ndc_prod,
                      z.ndc_pckg,
                      z.src_cls_of_trd_cd,
                      z.src_trans_typ_cd,
                      z.splt_begn_dt,
                      z.splt_end_dt,
                      z.splt_pct_strt_dt,
                      z.splt_pct_end_dt,
                      2 splt_pct_ord,
                      z.splt_pct_typ,
                      z.splt_pct * -1 splt_pct,
                      z.splt_pct_seq_no,
                      '' dst_cls_of_trd_cd,
                      '' dst_trans_typ_cd,
                      '' dst_cot_incl_ind,
                      '' dst_cot_grp_cd,
                      TO_DATE( NULL) dst_cot_begn_dt,
                      TO_DATE( NULL) dst_cot_end_dt,
                      '' dst_tt_incl_ind,
                      '' dst_tt_grp_cd,
                      TO_DATE( NULL) dst_tt_begn_dt,
                      TO_DATE( NULL) dst_tt_end_dt,
                      pkg_constants.cs_trans_adj_estimate trans_adj_cd
                 FROM y z
               UNION ALL
               -- Map source to destination as positive % to reallocate
               SELECT z.contr_id,
                      z.ndc_lbl,
                      z.ndc_prod,
                      z.ndc_pckg,
                      z.src_cls_of_trd_cd,
                      z.src_trans_typ_cd,
                      z.splt_begn_dt,
                      z.splt_end_dt,
                      z.splt_pct_strt_dt,
                      z.splt_pct_end_dt,
                      3 splt_pct_ord,
                      z.splt_pct_typ,
                      z.splt_pct,
                      z.splt_pct_seq_no,
                      z.dst_cls_of_trd_cd,
                      z.dst_trans_typ_cd,
                      z.dst_cot_incl_ind,
                      z.dst_cot_grp_cd,
                      z.dst_cot_begn_dt,
                      z.dst_cot_end_dt,
                      z.dst_tt_incl_ind,
                      z.dst_tt_grp_cd,
                      z.dst_tt_begn_dt,
                      z.dst_tt_end_dt,
                      '' trans_adj_cd
                 FROM y z
              )
         -- Pass 1 - load all split percents
         SELECT z.contr_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.src_cls_of_trd_cd,
                z.src_trans_typ_cd,
                z.splt_begn_dt,
                z.splt_end_dt,
                z.splt_pct_strt_dt,
                z.splt_pct_end_dt,
                0 splt_pct_ord,
                z.splt_pct_typ,
                z.splt_pct,
                z.splt_pct_seq_no,
                z.dst_cls_of_trd_cd,
                z.dst_trans_typ_cd,
                z.dst_cot_incl_ind,
                z.dst_cot_grp_cd,
                z.dst_cot_begn_dt,
                z.dst_cot_end_dt,
                z.dst_tt_incl_ind,
                z.dst_tt_grp_cd,
                z.dst_tt_begn_dt,
                z.dst_tt_end_dt,
                '' trans_adj_cd
           FROM z
          WHERE i_pass = 1
         UNION ALL
         -- Pass 2 - reload, limit by matrix, create original, reversal,
         --          reallocation rows for each percentage
         SELECT z.contr_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.src_cls_of_trd_cd,
                z.src_trans_typ_cd,
                z.splt_begn_dt,
                z.splt_end_dt,
                z.splt_pct_strt_dt,
                z.splt_pct_end_dt,
                z.splt_pct_ord,
                z.splt_pct_typ,
                z.splt_pct,
                z.splt_pct_seq_no,
                z.dst_cls_of_trd_cd,
                z.dst_trans_typ_cd,
                z.dst_cot_incl_ind,
                z.dst_cot_grp_cd,
                z.dst_cot_begn_dt,
                z.dst_cot_end_dt,
                z.dst_tt_incl_ind,
                z.dst_tt_grp_cd,
                z.dst_tt_begn_dt,
                z.dst_tt_end_dt,
                z.trans_adj_cd
           FROM x z
          WHERE i_pass = 2
          ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_mk_splt_pct_wrk_t;


   FUNCTION f_mk_bndl_dts
      (io_param_rec IN OUT t_calc_param_rec)
      RETURN NUMBER
   IS
      /*************************************************************************
      * Function Name : f_mk_bndl_dts
      *  Input params : io_param_rec - Calculation parameters
      * Output params : io_param_rec - Calculation parameters
      *       Returns : NUMBER, the number of rows inserted
      *  Date Created : 10/17/2014
      *        Author : Joe Kidd
      *   Description : Populates the Profile Product Bundle Dates working table
      *                 from the price group bundle defintions.  See
      *                 f_mk_bndl_info below for full details
      *
      *                 NOTE: This procedure should only write to temporary
      *                 tables, so that it can be used during testing/debugging
      *                 in production.  No changes should be made to permanent
      *                 objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Extracted bundling dates query from f_mk_bndl_info
      *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
      *                            Refactor query and allow future measurement periods
      *  08/01/2017  Joe Kidd      CRQ-376321: Demand 10535: NFAMP HHS Comp Summary
      *                            Fix day based periods bug, performance improvements
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Add support for NEGLAG additional text value
      *                            Check if bundles are used by earned date
      *  06/05/2019  J. Tronoski   CHG-117658: RITM-0726677: Bundle Evaluation Date Codes
      *                            Add VSDO and VEDO Addl Text settings
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            New bundle period columns added
      *                            Check for invalid pricing/performance period date ranges
      *                            Centralize GTT deletes
      *                            Add normal exception handling (Calc Debug Mode)
      *                            GTT column reductions
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_mk_bndl_dts';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Populates the bundling dates working tables';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while populating the bundling dates working tables';
      v_dts                 NUMBER;
   BEGIN
      -- Load Price Group Bundle Dates working table
      INSERT INTO hcrs.prfl_prod_bndl_dts_wrk_t
         (contr_id,
          price_grp_no,
          cond_cd,
          cond_strt_dt,
          cond_end_dt,
          cond_seq_no,
          bndl_strt_dt,
          bndl_end_dt,
          bndl_cd,
          prcg_strt_dt,
          prcg_end_dt,
          perf_strt_dt,
          perf_end_dt)
         WITH c
           AS (-- Get constants and variables
               SELECT pkg_constants.cs_flag_yes flag_yes,
                      pkg_constants.cs_flag_no flag_no,
                      TO_DATE( NULL, '') null_dt, -- format mask added to remove PL/SQL developer hint
                      pkg_constants.cs_addl_txt_fdo addl_txt_fdo,
                      pkg_constants.cs_addl_txt_vdo addl_txt_vdo,
                      pkg_constants.cs_addl_txt_neglag addl_txt_neglag,
                      pkg_constants.cs_addl_txt_vsdo addl_txt_vsdo,
                      pkg_constants.cs_addl_txt_vedo addl_txt_vedo,
                      pkg_constants.cs_begin_time begin_time,
                      io_param_rec.snpsht_dt snpsht_dt
                 FROM dual
              ),
              z
           AS (-- Get the first day of the periods that the bundle start and end dates occur in
               SELECT ppgbw.contr_id,
                      ppgbw.price_grp_no,
                      ppgbw.cond_cd,
                      ppgbw.cond_strt_dt,
                      ppgbw.cond_end_dt,
                      ppgbw.cond_seq_no,
                      ppgbw.bndl_strt_dt,
                      ppgbw.bndl_end_dt,
                      ppgbw.bndl_cd,
                      -- 2.1. The Bundle Start Date is translated to the Period
                      --      Start Date, which is the start date of the period
                      --      (based on the bundle period unit) in which it occurs.
                      CASE
                         -- Periods that use months always begins on the first of the month:
                         -- First day of the year of the bundle start date has added to it a
                         -- number of months equal to the month of the bundle start date
                         -- divided by the number of months in the period type (mltplr),
                         -- rounded up, less one, multiplied by the number of months in the
                         -- period type (mltplr). This reliably produces a start date for
                         -- each period type (Month, Quarter, Trimester, Half-Year, Year)
                         WHEN ppgbw.uses_mths = c.flag_yes
                         THEN ADD_MONTHS( TRUNC( ppgbw.bndl_strt_dt, 'YYYY'), (CEIL( TO_NUMBER( TO_CHAR( ppgbw.bndl_strt_dt, 'MM')) / ppgbw.mltplr) - 1) * ppgbw.mltplr)
                         -- Daily is always the same day: the Bundle Start Date.
                         WHEN ppgbw.uses_mths = c.flag_no
                          AND ppgbw.mltplr = 1
                         THEN ppgbw.bndl_strt_dt
                         -- Weekly is the first day of the week beginning on Sunday:
                         -- The Bundle Start Date has subtracted from it a number of days
                         -- equal to one less than the numeric day of the week (Sun = 1, Mon = 2,..Sat = 7).
                         WHEN ppgbw.uses_mths = c.flag_no
                          AND ppgbw.mltplr = 7
                         THEN ppgbw.bndl_strt_dt - (TO_CHAR( ppgbw.bndl_strt_dt, 'D') - 1)
                         ELSE c.null_dt
                      END prd_strt_dt,
                      -- 2.2. The Bundle End Date is translated to the Period
                      --      End Date, which is the start date of the period
                      --      (based on the bundle period unit) in which it occurs.
                      CASE
                         -- Periods that use months always begins on the first of a month
                         -- First Day of the Year has added to it a number of months equal to
                         -- the month of the bundle end date divided by the number of months in the period type (mltplr),
                         -- rounded up, less one, multiplied by the number of months in the period type (mltplr)
                         WHEN ppgbw.uses_mths = c.flag_yes
                         THEN ADD_MONTHS( TRUNC( ppgbw.bndl_end_dt, 'YYYY'), (CEIL( TO_NUMBER( TO_CHAR( ppgbw.bndl_end_dt, 'MM')) / ppgbw.mltplr) - 1) * ppgbw.mltplr)
                         -- Daily is always the same day: returns the Bundle End Date
                         WHEN ppgbw.uses_mths = c.flag_no
                          AND ppgbw.mltplr = 1
                         THEN ppgbw.bndl_end_dt
                         -- Weekly is the first day of the week beginning on Sunday:
                         -- The Bundle End Date has subtracted from it a number of days
                         -- equal to one less than the numeric day of the week (Sun = 1, Mon = 2,..Sat = 7).
                         WHEN ppgbw.uses_mths = c.flag_no
                          AND ppgbw.mltplr = 7
                         THEN ppgbw.bndl_end_dt - (TO_CHAR( ppgbw.bndl_end_dt, 'D') - 1)
                         ELSE c.null_dt
                      END prd_end_dt,
                      -- 2.3. The period lengths and offsets are converted from bundle
                      --      periods to months or days as appropriate.
                      ppgbw.bndl_prcg_prd_off * ppgbw.mltplr bndl_prcg_prd_off,
                      ppgbw.bndl_prcg_prd_len * ppgbw.mltplr bndl_prcg_prd_len,
                      ppgbw.bndl_perf_prd_off * ppgbw.mltplr bndl_perf_prd_off,
                      ppgbw.bndl_perf_prd_len * ppgbw.mltplr bndl_perf_prd_len,
                      ppgbw.uses_mths,
                      ppgbw.mltplr,
                      -- 2.11. If specified by FDOnnn in the additional text, adjust
                      --       the pricing period start and end date by nnn days.
                      -- 2.12. If specified by VDOnnn in the additional text, adjust
                      --       the performance period start and end date by nnn days.
                      -- 2.12a.If specified by VSDOnnn in the additional text, adjust
                      --       the performance period start date by nnn days.
                      --       The value for VSDO would override the value in VDO
                      -- 2.12b.If specified by VEDOnnn in the additional text, adjust
                      --       the performance period end date by nnn days.
                      --       The value for VEDO would override the value in VDO
                      -- Format the Additional Text field
                      --   wrap with commas, replace repeating spaces and commas with one comma,
                      --   if only a single comma remain delete it, uppercase
                      UPPER( REGEXP_REPLACE( REGEXP_REPLACE( ',' || ppgbw.bndl_addl_txt || ',', '[[:space:],]+', ','), '^,$', '')) bndl_addl_txt,
                      c.flag_yes,
                      c.flag_no,
                      c.null_dt,
                      c.addl_txt_fdo,
                      c.addl_txt_vdo,
                      c.addl_txt_neglag,
                      c.addl_txt_vsdo,
                      c.addl_txt_vedo,
                      c.begin_time,
                      c.snpsht_dt
                 FROM c,
                      hcrs.prfl_price_grp_bndl_wrk_t ppgbw
                   -- 1.6. Pricing Period length must be greater than zero
                WHERE ppgbw.bndl_prcg_prd_len > 0
                   -- 1.7. Pricing Period offset must be greater than or equal to zero
                  AND ppgbw.bndl_prcg_prd_off >= 0
                   -- 1.8. REMOVED: Performance Period offset must be greater than or equal to zero
                   -- a negative offset pushes the Performance Period into the future
                   -- AND ppgbw.bndl_perf_prd_off >= 0
                   -- 1.9. Performance Period length must be greater than or equal to zero
                  AND ppgbw.bndl_perf_prd_len >= 0
              ),
              y
           AS (-- Get row for each period each bundle is in effect
               -- by joining to 1024 records, this prevents long running times
               -- Get the Adjusted Bundle Start and End date for determining which
               -- pricing periods are needed
               SELECT z.contr_id,
                      z.price_grp_no,
                      z.cond_cd,
                      z.cond_strt_dt,
                      z.cond_end_dt,
                      z.cond_seq_no,
                      z.bndl_strt_dt,
                      z.bndl_end_dt,
                      -- 2.4. The Bundle Start Date is translated to the Adjusted
                      --      Bundle Start Date by adding a number of bundle periods
                      --      equal to the Pricing Period Offset.  This is done to
                      --      allow all valid pricing periods to occur within the
                      --      Adjusted Bundle Date Range.
                      CASE
                         -- Use ADD_MONTHS if the period uses months, otherwise add days
                         WHEN z.uses_mths = z.flag_yes
                         THEN ADD_MONTHS( z.bndl_strt_dt, z.bndl_prcg_prd_off)
                         -- Add days if the period uses days
                         WHEN z.uses_mths = z.flag_no
                         THEN z.bndl_strt_dt + z.bndl_prcg_prd_off
                         ELSE z.null_dt
                      END adj_bndl_strt_dt,
                      -- 2.5. The Bundle End Date is translated to the Adjusted
                      --      Bundle Start Date by adding a number of bundle periods
                      --      equal to the Pricing Period Offset.
                      CASE
                         -- Use ADD_MONTHS if the period uses months, otherwise add days
                         WHEN z.uses_mths = z.flag_yes
                         THEN ADD_MONTHS( z.bndl_end_dt, z.bndl_prcg_prd_off)
                         -- Add days if the period uses days
                         WHEN z.uses_mths = z.flag_no
                         THEN z.bndl_end_dt + z.bndl_prcg_prd_off
                         ELSE z.null_dt
                      END adj_bndl_end_dt,
                      z.bndl_cd,
                      z.prd_strt_dt,
                      -- 2.6. Determine the number of bundle pricing periods that
                      --      must be built for each bundle.
                      CASE
                         WHEN z.uses_mths = z.flag_yes
                         THEN CEIL( (MONTHS_BETWEEN( z.prd_end_dt, z.prd_strt_dt) + 1) / z.mltplr)
                         WHEN z.uses_mths = z.flag_no
                         THEN CEIL( ((z.prd_end_dt - z.prd_strt_dt) + 1) / z.mltplr)
                         ELSE 0
                      END num_prds,
                      z.bndl_prcg_prd_off,
                      z.bndl_prcg_prd_len,
                      -- If the performance period offset (period lag) is positive
                      --    and NEGLAG is in additional text
                      -- Make the performance period offset (period lag) negative
                      CASE
                         WHEN z.bndl_perf_prd_off > 0
                          AND INSTR( z.bndl_addl_txt, ',' || z.addl_txt_neglag || ',') > 0
                         THEN z.bndl_perf_prd_off * -1
                         ELSE z.bndl_perf_prd_off
                      END bndl_perf_prd_off,
                      z.bndl_perf_prd_len,
                      z.uses_mths,
                      z.mltplr,
                      -- 2.11. If specified by FDOnnn in the additional text, adjust
                      --       the pricing period start and end date by nnn days.
                      -- 2.12. If specified by VDOnnn in the additional text, adjust
                      --       the performance period start and end date by nnn days.
                      -- 2.12a.If specified by VSDOnnn in the additional text, adjust
                      --       the performance period start date by nnn days.
                      --       The value for VSDO would override the value in VDO
                      -- 2.12b.If specified by VEDOnnn in the additional text, adjust
                      --       the performance period end date by nnn days.
                      --       The value for VEDO would override the value in VDO
                      -- Get Pricing and Performance Period Day Offsets
                      -- Use regexp to find abbreivation plus an optional sign plus one to three digits between commas,
                      -- Extract just the sign and numbers, Convert to number, replace null with zero
                      NVL( TO_NUMBER( REGEXP_SUBSTR( z.bndl_addl_txt, ',' || z.addl_txt_fdo || '([\+\-]{0,1}[[:digit:]]{1,3}),', 1, 1, 'i', 1)), 0) prcg_per_day_off,
                      NVL( TO_NUMBER( REGEXP_SUBSTR( z.bndl_addl_txt, ',' || z.addl_txt_vdo || '([\+\-]{0,1}[[:digit:]]{1,3}),', 1, 1, 'i', 1)), 0) perf_per_day_off,
                      NVL( TO_NUMBER( REGEXP_SUBSTR( z.bndl_addl_txt, ',' || z.addl_txt_vsdo || '([\+\-]{0,1}[[:digit:]]{1,3}),', 1, 1, 'i', 1)), 0) perf_strt_day_off,
                      NVL( TO_NUMBER( REGEXP_SUBSTR( z.bndl_addl_txt, ',' || z.addl_txt_vedo || '([\+\-]{0,1}[[:digit:]]{1,3}),', 1, 1, 'i', 1)), 0) perf_end_day_off,
                      z.flag_yes,
                      z.flag_no,
                      z.null_dt,
                      z.begin_time,
                      z.snpsht_dt
                 FROM z
              ),
              x
           AS (-- Get rows to calculate all pricing periods
               SELECT LEVEL - 1 n
                 FROM dual
               CONNECT BY LEVEL <= (
                                    SELECT MAX( y.num_prds) + 1
                                      FROM y
                                   )
              ),
              w
           AS (-- Calculate the pricing period start date for each period the bundle is in effect
               SELECT y.contr_id,
                      y.price_grp_no,
                      y.cond_cd,
                      y.cond_strt_dt,
                      y.cond_end_dt,
                      y.cond_seq_no,
                      y.bndl_strt_dt,
                      y.bndl_end_dt,
                      y.adj_bndl_strt_dt,
                      y.adj_bndl_end_dt,
                      y.bndl_cd,
                      -- 2.7. Calculate the pricing period start date using the
                      --      pricing period offset.
                      CASE
                         -- Use ADD_MONTHS if the period uses months, otherwise add days
                         WHEN y.uses_mths = y.flag_yes
                         THEN ADD_MONTHS( y.prd_strt_dt, y.bndl_prcg_prd_off + (y.bndl_prcg_prd_len * x.n))
                         -- Add days if the period uses days
                         WHEN y.uses_mths = y.flag_no
                         THEN y.prd_strt_dt + y.bndl_prcg_prd_off + (y.bndl_prcg_prd_len * x.n)
                         ELSE y.null_dt
                      END prcg_strt_dt,
                      y.bndl_prcg_prd_len,
                      y.bndl_perf_prd_off,
                      y.bndl_perf_prd_len,
                      y.uses_mths,
                      y.prcg_per_day_off,
                      y.perf_per_day_off,
                      y.perf_strt_day_off,
                      y.perf_end_day_off,
                      y.flag_yes,
                      y.flag_no,
                      y.null_dt,
                      y.begin_time,
                      y.snpsht_dt
                 FROM y,
                      x
                -- Limit join to dummy table to just enough periods
                WHERE y.num_prds >= x.n
              ),
              v
           AS (-- Calculate the pricing period end date
               SELECT w.contr_id,
                      w.price_grp_no,
                      w.cond_cd,
                      w.cond_strt_dt,
                      w.cond_end_dt,
                      w.cond_seq_no,
                      w.bndl_strt_dt,
                      w.bndl_end_dt,
                      w.adj_bndl_strt_dt,
                      w.adj_bndl_end_dt,
                      w.bndl_cd,
                      w.prcg_strt_dt,
                      -- 2.8. Calculate the pricing period end date using the
                      --      pricing period start date and pricing period length.
                      CASE
                         -- Use ADD_MONTHS if the period uses months, otherwise add days
                         WHEN w.uses_mths = w.flag_yes
                         THEN ADD_MONTHS( w.prcg_strt_dt, w.bndl_prcg_prd_len) - 1
                         -- Add days if the period uses days
                         WHEN w.uses_mths = w.flag_no
                         THEN w.prcg_strt_dt + w.bndl_prcg_prd_len - 1
                         ELSE w.null_dt
                      END prcg_end_dt,
                      w.bndl_perf_prd_off,
                      w.bndl_perf_prd_len,
                      w.uses_mths,
                      w.prcg_per_day_off,
                      w.perf_per_day_off,
                      w.perf_strt_day_off,
                      w.perf_end_day_off,
                      w.flag_yes,
                      w.flag_no,
                      w.null_dt,
                      w.begin_time,
                      w.snpsht_dt
                 FROM w
              ),
              u
           AS (-- Calculate the performance period start date
               SELECT v.contr_id,
                      v.price_grp_no,
                      v.cond_cd,
                      v.cond_strt_dt,
                      v.cond_end_dt,
                      v.cond_seq_no,
                      v.bndl_strt_dt,
                      v.bndl_end_dt,
                      v.adj_bndl_strt_dt,
                      v.adj_bndl_end_dt,
                      v.bndl_cd,
                      v.prcg_strt_dt,
                      v.prcg_end_dt,
                      -- 2.9. Calculate the performance period start date using the
                      --      pricing period start date, performance period offset,
                      --      and performance period length.  The performance period
                      --      length must be greater than zero to have a performance
                      --      period.
                      CASE
                         -- Use ADD_MONTHS if the period uses months, otherwise add days
                         WHEN v.bndl_perf_prd_len > 0
                          AND v.uses_mths = v.flag_yes
                         THEN ADD_MONTHS( v.prcg_strt_dt, (v.bndl_perf_prd_off + v.bndl_perf_prd_len) * -1)
                         -- Add days if the period uses days
                         WHEN v.bndl_perf_prd_len > 0
                          AND v.uses_mths = v.flag_no
                         THEN v.prcg_strt_dt + ((v.bndl_perf_prd_off + v.bndl_perf_prd_len) * -1)
                         ELSE v.null_dt
                      END perf_strt_dt,
                      v.bndl_perf_prd_len,
                      v.uses_mths,
                      v.prcg_per_day_off,
                      v.perf_per_day_off,
                      v.perf_strt_day_off,
                      v.perf_end_day_off,
                      v.flag_yes,
                      v.flag_no,
                      v.null_dt,
                      v.begin_time,
                      v.snpsht_dt
                 FROM v
              ),
              t
           AS (-- Calculate the performance period end date
               SELECT u.contr_id,
                      u.price_grp_no,
                      u.cond_cd,
                      u.cond_strt_dt,
                      u.cond_end_dt,
                      u.cond_seq_no,
                      u.bndl_strt_dt,
                      u.bndl_end_dt,
                      u.adj_bndl_strt_dt,
                      u.adj_bndl_end_dt,
                      u.bndl_cd,
                      u.prcg_strt_dt,
                      u.prcg_end_dt,
                      u.perf_strt_dt,
                      -- 2.10. Calculate the performance period end date using the
                      --       performance period start date and performance period
                      --       length.
                      CASE
                         -- Use ADD_MONTHS if the period uses months, otherwise add days
                         WHEN u.uses_mths = u.flag_yes
                         THEN ADD_MONTHS( u.perf_strt_dt, u.bndl_perf_prd_len) - 1
                         -- Add days if the period uses days
                         WHEN u.uses_mths = u.flag_no
                         THEN u.perf_strt_dt + u.bndl_perf_prd_len - 1
                         ELSE u.null_dt
                      END perf_end_dt,
                      u.prcg_per_day_off,
                      u.perf_per_day_off,
                      u.perf_strt_day_off,
                      u.perf_end_day_off,
                      u.begin_time,
                      u.snpsht_dt
                 FROM u
              ),
              s
           AS (-- Calculate the adjust pricing/performance period start/end dates
               SELECT t.contr_id,
                      t.price_grp_no,
                      t.cond_cd,
                      t.cond_strt_dt,
                      t.cond_end_dt,
                      t.cond_seq_no,
                      t.bndl_strt_dt,
                      t.bndl_end_dt,
                      t.adj_bndl_strt_dt,
                      t.adj_bndl_end_dt,
                      t.bndl_cd,
                      -- 2.11. If specified by FDOnnn in the additional text, adjust
                      --       the pricing period start and end date by nnn days.
                      t.prcg_strt_dt + t.prcg_per_day_off prcg_strt_dt,
                      t.prcg_end_dt + t.prcg_per_day_off prcg_end_dt,
                      -- 2.12. If specified by VDOnnn in the additional text, adjust
                      --       the performance period start and end date by nnn days.
                      -- 2.12a.If specified by VSDOnnn in the additional text, adjust
                      --       the performance period start date by nnn days.
                      --       The value for VSDO would override the value in VDO
                      -- 2.12b.If specified by VEDOnnn in the additional text, adjust
                      --       the performance period end date by nnn days.
                      --       The value for VEDO would override the value in VDO
                      CASE
                         -- Use VSDO value if set
                         WHEN t.perf_strt_day_off <> 0
                         THEN t.perf_strt_dt + t.perf_strt_day_off
                         -- Otherwise use VDO value
                         ELSE t.perf_strt_dt + t.perf_per_day_off
                      END perf_strt_dt,
                      CASE
                         -- Use VEDO value if set
                         WHEN t.perf_end_day_off <> 0
                         THEN t.perf_end_dt + t.perf_end_day_off
                         -- Otherwise use VDO value
                         ELSE t.perf_end_dt + t.perf_per_day_off
                      END perf_end_dt,
                      t.begin_time,
                      t.snpsht_dt
                 FROM t
              )
         -- Get the rows that are in effect during the bundle dates and profile dates
         SELECT s.contr_id,
                s.price_grp_no,
                s.cond_cd,
                s.cond_strt_dt,
                s.cond_end_dt,
                s.cond_seq_no,
                s.bndl_strt_dt,
                s.bndl_end_dt,
                s.bndl_cd,
                s.prcg_strt_dt,
                s.prcg_end_dt,
                s.perf_strt_dt,
                s.perf_end_dt
           FROM s
             -- The pricing period date range must be valid
          WHERE s.prcg_strt_dt <= s.prcg_end_dt
             -- The performance period date range must be valid
            AND (   (    s.perf_strt_dt IS NULL
                     AND s.perf_end_dt IS NULL
                    )
                 OR s.perf_strt_dt <= s.perf_end_dt
                )
             -- 3.1. The pricing period overlaps with the Adjusted Bundle
             -- Date Range.
            AND s.prcg_strt_dt <= s.adj_bndl_end_dt
            AND s.prcg_end_dt >= s.adj_bndl_strt_dt
             -- 3.2. The pricing period or performance period overlaps
             --      with the Condition Date Range.
            AND (   (    s.prcg_strt_dt <= s.cond_end_dt
                     AND s.prcg_end_dt >= s.cond_strt_dt
                    )
                 OR (    s.perf_strt_dt <= s.cond_end_dt
                     AND s.perf_end_dt >= s.cond_strt_dt
                    )
                )
             -- 3.3. The pricing period starts on or before the snapshot date.
            AND s.prcg_strt_dt <= TRUNC( s.snpsht_dt)
             -- 3.4. The performance period starts on or before the snapshot date.
            AND NVL( s.perf_strt_dt, s.begin_time) <= TRUNC( s.snpsht_dt);
      v_dts := SQL%ROWCOUNT;
      IF     v_dts > 0
         AND io_param_rec.min_earn_start_dt IS NOT NULL
         AND io_param_rec.max_earn_end_dt IS NOT NULL
         AND io_param_rec.min_paid_start_dt IS NULL
         AND io_param_rec.max_paid_end_dt IS NULL
      THEN
         -- Bundles dates were found, only earn dates used, and paid dates not used
         -- Remove all rows where the pricing or performance period dates
         -- do not overlap with the calculation earned period
         DELETE
           FROM hcrs.prfl_prod_bndl_dts_wrk_t ppbdw
          WHERE NOT (   (    io_param_rec.min_earn_start_dt <= ppbdw.prcg_end_dt
                         AND io_param_rec.max_earn_end_dt >= ppbdw.prcg_strt_dt
                        )
                     OR (    ppbdw.perf_strt_dt IS NOT NULL
                         AND ppbdw.perf_end_dt IS NOT NULL
                         AND io_param_rec.min_earn_start_dt <= ppbdw.perf_end_dt
                         AND io_param_rec.max_earn_end_dt >= ppbdw.perf_strt_dt
                        )
                    );
         -- Get count of bundle dates that overlap with the earn date range
         SELECT COUNT(*)
           INTO v_dts
           FROM ( -- Check each row in case there is a gap period where there are no bundles
                  SELECT LEAST( ppbdw.bndl_strt_dt, NVL( ppbdw.perf_strt_dt, ppbdw.bndl_strt_dt)) bndl_strt_dt,
                         GREATEST( ppbdw.bndl_end_dt, NVL( ppbdw.perf_end_dt, ppbdw.bndl_end_dt)) bndl_end_dt
                    FROM hcrs.prfl_prod_bndl_dts_wrk_t ppbdw
                ) b
          WHERE b.bndl_strt_dt <= io_param_rec.max_earn_end_dt
            AND b.bndl_end_dt >= io_param_rec.min_earn_start_dt;
      END IF;
      RETURN v_dts;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
         RETURN 0;
   END f_mk_bndl_dts;


   FUNCTION f_mk_bndl_info
      (io_param_rec IN OUT t_calc_param_rec)
      RETURN NUMBER
   IS
      /*************************************************************************
      * Function Name : f_mk_bndl_info
      *  Input params : io_param_rec - Calculation parameters
      * Output params : io_param_rec - Calculation parameters
      *       Returns : NUMBER, the number of rows inserted
      *  Date Created : 12/05/2007
      *        Author : Joe Kidd
      *   Description : Populates the Profile Product Bundle Dates working table
      *                 from the price group bundle defintions
      *
      *                 NOTE: This procedure should only write to temporary
      *                 tables, so that it can be used during testing/debugging
      *                 in production.  No changes should be made to permanent
      *                 objects.  Make those changes in p_common_initialize.
      *
      *                 The following requirement must be met for a bundled price
      *                 groups configuration to be included in the translation:
      *
      *                 1.1. One or more NDCs of the running calculation must be
      *                      effective on the bundle before the Sales Cutoff Date.
      *                 1.2. The Bundle Start Date must be before the Sales Cutoff
      *                      Date.
      *                 1.3. The Condition must be effective during the Bundle
      *                      effective period.
      *                 1.4. The Condition Start Date must be before the Sales Cutoff
      *                      Date.
      *                 1.5. The Condtion must have customers effective before the
      *                      Sales Cutoff Date
      *                 1.6. The Pricing Period length must be greater than zero.
      *                 1.7. The Pricing Period offset must be greater than or
      *                      equal to zero.
      *                 1.8. The Performance Period offset must be greater than or
      *                      equal to zero.
      *                 1.9. The Performance Period length must be greater than or
      *                      equal to zero.
      *
      *                 The following step occur in the translation process:
      *
      *                 2.1. The Bundle Start Date is translated to the Period
      *                      Start Date, which is the start date of the period
      *                      (based on the bundle period unit) in which it occurs:
      *                      G_ANNUAL  - Year periods begining on Jan 1st.
      *                      F_SEMI    - Six month periods begining on Jan 1st and July 1st.
      *                      F_TRI     - Four month periods begining on Jan 1st, May 1st, and Sept 1st.
      *                      E_QTR     - Three month periods begining on Jan 1st, Apr 1st, Jult 1st, and Oct 1st.
      *                      D_MONTHLY - Single month periods beginning on the first of each calendar month.
      *                      C_WEEKLY  - Seven day long periods beginning on Sunday.
      *                      I_DAILY   - Single day periods.
      *                 2.2. The Bundle End Date is translated to the Period
      *                      End Date, which is the start date of the period
      *                      (based on the bundle period unit) in which it occurs.
      *                 2.3. The period lengths and offsets are converted from bundle
      *                      periods to months or days as appropriate.
      *                 2.4. The Bundle Start Date is translated to the Adjusted
      *                      Bundle Start Date by adding a number of bundle periods
      *                      equal to the Pricing Period Offset.  This is done to
      *                      allow all valid pricing periods to occur within the
      *                      Adjusted Bundle Date Range.
      *                 2.5. The Bundle End Date is translated to the Adjusted
      *                      Bundle Start Date by adding a number of bundle periods
      *                      equal to the Pricing Period Offset.
      *                 2.6. Determine the number of bundle pricing periods that
      *                      must be built for each bundle.
      *                 For each pricing period that must be built:
      *                 2.7. Calculate the pricing period start date using the
      *                      pricing period offset.
      *                 2.8. Calculate the pricing period end date using the
      *                      pricing period start date and pricing period length.
      *                 2.9. Calculate the performance period start date using the
      *                      pricing period start date, performance period offset,
      *                      and performance period length.  The performance period
      *                      length must be greater than zero to have a performance
      *                      period.
      *                 2.10. Calculate the performance period end date using the
      *                       performance period start date and performance period
      *                       length.
      *                 2.11. If specified by FDOnnn in the additional text, adjust
      *                       the pricing period start and end date by nnn days.
      *                 2.12. If specified by VDOnnn in the additional text, adjust
      *                       the performance period start and end date by nnn days.
      *
      *                 Each pricing periods built must meet the following
      *                 requirements:
      *
      *                 3.1. The pricing period overlaps with the Adjusted Bundle
      *                      Date Range.
      *                 3.2. The pricing period or performance period overlaps
      *                      with the Condition Date Range.
      *                 3.3. The pricing period starts on or before the snapshot date.
      *                 3.4. The performance period starts on or before the snapshot date.
      *
      *                 Don't relate Bundle effective, pricing, and performance
      *                 dates (earned dates only) to the calculation transaction
      *                 pull start and end dates (possibly a mix of earned and
      *                 paid dates)
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  06/16/2008  Joe Kidd      PICC 1927: Revise loading of the following
      *                            working tables: Bundled Products, Price Group
      *                            Bundle Dates
      *                            Load new working tables: Price Group Bundles,
      *                            Customer Conditions, Bundle Price Groups
      *  08/22/2008  Joe Kidd      PICC 1961: Delete instead of Truncate
      *                            Add Profile Bundle Conditions working table
      *                            Delete Customer Conditions and Bundle Price
      *                            Groups working tables before loading
      *                            Only run queries if previous queries returned results
      *  04/02/2009  Joe Kidd      PICC 2027: Adjust Pricing/Perfomance Start/End
      *                            Dates for Bundle Addl Text Day Offsets
      *  07/22/2009  Joe Kidd      RT 267 - CRQ 43432: Bundling Tuning
      *                            Only load CARS customers for NONE condition
      *  04/26/2010  Joe Kidd      RT 2009-724 - CRQ 46973: Revise Bundling Methodology
      *                            Collapse contiguous customer condition rows
      *                            Determine if customer conditions are used
      *  04/01/2011  Joe Kidd      CRQ-3921: Linking of CARS chargebacks
      *                            Remove error logging and use error call stack
      *                            to allow init_calc use for debugging in prod
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Remove unneeded bundling condition checks
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Pass only calc parameter record
      *                            Change refernces to NDC in product work table
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Fix pop src after return
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Renamed from f_mk_bndl_dts
      *                            Moved bundling dates query to f_mk_bndl_dts
      *                            Load customer COTs from new GTT
      *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
      *                            Remove reference to prfl_bndl_price_grp_wrk_t
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Populate addtional fields
      *                            Additional Value changed from NUMBER to VARCHAR2
      *                            Limit customer conditions by the matrix
      *                            Clear working tables if bundling not needed
      *                            Set bundle dates and bundle product flags
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            New bundle period columns added
      *                            Centralize GTT deletes
      *                            Add normal exception handling (Calc Debug Mode)
      *                            GTT column reductions
      *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
      *                            Add SAP4H source system constants
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_mk_bndl_info';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Populates the bundling working tables';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while populating the bundling working tables';
      v_cnt                 NUMBER := 0;
      v_dts                 NUMBER := 0;
   BEGIN
      --------------------------------------------------------------------------
      -- Load Bundled Products working table
      INSERT INTO hcrs.prfl_bndl_prod_wrk_t
         (bndl_cd,
          bndl_ndc_lbl,
          bndl_ndc_prod,
          bndl_ndc_pckg,
          prod_strt_dt,
          prod_end_dt,
          bndl_strt_dt,
          bndl_end_dt,
          min_paid_start_dt,
          max_paid_end_dt,
          min_earn_start_dt,
          max_earn_end_dt,
          snpsht_id,
          prune_days,
          flag_yes,
          flag_no,
          rec_src_icw,
          src_tbl_iis,
          system_sap,
          system_sap4h,
          system_cars,
          trans_cls_dir,
          trans_cls_idr,
          trans_cls_rbt,
          trans_adj_original,
          trans_adj_cars_rollup)
         WITH z
           AS (-- 1.1. One or more NDCs of the running calculation
               --      effective on the bundle before the Sales Cutoff Date.
               SELECT DISTINCT
                      ppw.prfl_id,
                      ppw.co_id,
                      ppw.ndc_lbl,
                      ppw.ndc_prod,
                      ppw.ndc_pckg,
                      ppw.calc_typ_cd,
                      ppw.pri_whls_mthd_cd,
                      pbp0.bndl_cd,
                      pbp0.ndc_lbl bndl_ndc_lbl,
                      pbp0.ndc_prod bndl_ndc_prod,
                      pbp0.ndc_pckg bndl_ndc_pckg,
                      pbp0.prod_strt_dt,
                      pbp0.prod_end_dt,
                      -- These dates populated later after dates table populated
                      ppw.begin_time bndl_strt_dt,
                      ppw.end_time bndl_end_dt,
                      ppw.snpsht_id,
                      ppw.prune_days,
                      ppw.flag_yes,
                      ppw.flag_no,
                      ppw.rec_src_icw,
                      ppw.src_tbl_iis,
                      ppw.system_sap,
                      ppw.system_sap4h,
                      ppw.system_cars,
                      ppw.trans_cls_dir,
                      ppw.trans_cls_idr,
                      ppw.trans_cls_rbt,
                      ppw.trans_adj_original,
                      ppw.trans_adj_cars_rollup
                 FROM hcrs.prfl_prod_wrk_t ppw,
                      hcrs.prfl_bndl_prod_t pbp,
                      hcrs.prfl_bndl_prod_t pbp0
                WHERE ppw.prfl_id = pbp.prfl_id
                  AND ppw.co_id = pbp.co_id
                  AND ppw.trans_ndc_lbl = pbp.ndc_lbl
                  AND ppw.trans_ndc_prod = pbp.ndc_prod
                  AND ppw.trans_ndc_pckg = pbp.ndc_pckg
                  AND TRUNC( ppw.snpsht_dt) >= pbp.prod_strt_dt
                  AND pbp.prfl_id = pbp0.prfl_id
                  AND pbp.co_id = pbp0.co_id
                  AND pbp.bndl_cd = pbp0.bndl_cd
              ),
              y
           AS (-- Flag the calc products with the dates, check that the dates
               -- overlap with the bundle product dates
               SELECT z.bndl_cd,
                      z.bndl_ndc_lbl,
                      z.bndl_ndc_prod,
                      z.bndl_ndc_pckg,
                      z.prod_strt_dt,
                      z.prod_end_dt,
                      z.bndl_strt_dt,
                      z.bndl_end_dt,
                      -- Only adds these dates for the calculation products
                      ppw.min_paid_start_dt,
                      ppw.max_paid_end_dt,
                      ppw.min_earn_start_dt,
                      ppw.max_earn_end_dt,
                      -- Check if bundle products effective during calc period
                      CASE
                         -- Paid date calcs bundle product must start before calc period end
                         WHEN ppw.min_paid_start_dt IS NOT NULL
                          AND ppw.max_paid_end_dt IS NOT NULL
                          AND ppw.max_paid_end_dt >= z.prod_strt_dt
                         THEN ppw.flag_yes
                         -- Earn date calcs bundle product overlap with the calc period
                         WHEN ppw.min_earn_start_dt IS NOT NULL
                          AND ppw.max_earn_end_dt IS NOT NULL
                          AND ppw.min_earn_start_dt <= z.prod_end_dt
                          AND ppw.max_earn_end_dt >= z.prod_strt_dt
                         THEN ppw.flag_yes
                      END prod_dt_chk,
                      z.snpsht_id,
                      z.prune_days,
                      z.flag_yes,
                      z.flag_no,
                      z.rec_src_icw,
                      z.src_tbl_iis,
                      z.system_sap,
                      z.system_sap4h,
                      z.system_cars,
                      z.trans_cls_dir,
                      z.trans_cls_idr,
                      z.trans_cls_rbt,
                      z.trans_adj_original,
                      z.trans_adj_cars_rollup
                 FROM z,
                      hcrs.prfl_prod_wrk_t ppw
                WHERE z.prfl_id = ppw.prfl_id (+)
                  AND z.co_id = ppw.co_id (+)
                  AND z.ndc_lbl = ppw.ndc_lbl (+)
                  AND z.ndc_prod = ppw.ndc_prod (+)
                  AND z.ndc_pckg = ppw.ndc_pckg (+)
                  AND z.calc_typ_cd = ppw.calc_typ_cd (+)
                  AND z.bndl_ndc_lbl = ppw.trans_ndc_lbl (+)
                  AND z.bndl_ndc_prod = ppw.trans_ndc_prod (+)
                  AND z.bndl_ndc_pckg = ppw.trans_ndc_pckg (+)
              ),
              x
           AS (-- Count the number of calc products that overlap
               SELECT z.bndl_cd,
                      z.bndl_ndc_lbl,
                      z.bndl_ndc_prod,
                      z.bndl_ndc_pckg,
                      z.prod_strt_dt,
                      z.prod_end_dt,
                      z.bndl_strt_dt,
                      z.bndl_end_dt,
                      z.min_paid_start_dt,
                      z.max_paid_end_dt,
                      z.min_earn_start_dt,
                      z.max_earn_end_dt,
                      COUNT( z.prod_dt_chk) OVER () prod_dt_chk_cnt,
                      z.snpsht_id,
                      z.prune_days,
                      z.flag_yes,
                      z.flag_no,
                      z.rec_src_icw,
                      z.src_tbl_iis,
                      z.system_sap,
                      z.system_sap4h,
                      z.system_cars,
                      z.trans_cls_dir,
                      z.trans_cls_idr,
                      z.trans_cls_rbt,
                      z.trans_adj_original,
                      z.trans_adj_cars_rollup
                 FROM y z
              )
         -- Insert the bundle products when they overlap with the calc products
         SELECT z.bndl_cd,
                z.bndl_ndc_lbl,
                z.bndl_ndc_prod,
                z.bndl_ndc_pckg,
                z.prod_strt_dt,
                z.prod_end_dt,
                z.bndl_strt_dt,
                z.bndl_end_dt,
                z.min_paid_start_dt,
                z.max_paid_end_dt,
                z.min_earn_start_dt,
                z.max_earn_end_dt,
                z.snpsht_id,
                z.prune_days,
                z.flag_yes,
                z.flag_no,
                z.rec_src_icw,
                z.src_tbl_iis,
                z.system_sap,
                z.system_sap4h,
                z.system_cars,
                z.trans_cls_dir,
                z.trans_cls_idr,
                z.trans_cls_rbt,
                z.trans_adj_original,
                z.trans_adj_cars_rollup
           FROM x z
          WHERE z.prod_dt_chk_cnt > 0
          ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14;
      v_cnt := v_cnt + SQL%ROWCOUNT;
      IF SQL%ROWCOUNT > 0
      THEN
         --------------------------------------------------------------------------
         -- Load Bundle Conditions definitions working table
         INSERT INTO hcrs.prfl_bndl_cond_wrk_t
            (bndl_cd,
             cond_cd,
             cond_strt_dt,
             cond_end_dt,
             cond_seq_no,
             bndl_prcg_prd_off,
             bndl_prcg_prd_len,
             bndl_perf_prd_off,
             bndl_perf_prd_len,
             bndl_prd_unit,
             bndl_addl_txt,
             bndl_addl_val)
            SELECT pbc.bndl_cd,
                   pbc.cond_cd,
                   pbc.cond_strt_dt,
                   pbc.cond_end_dt,
                   pbc.cond_seq_no,
                   pbc.bndl_prcg_prd_off,
                   pbc.bndl_prcg_prd_len,
                   pbc.bndl_perf_prd_off,
                   pbc.bndl_perf_prd_len,
                   pbc.bndl_prd_unit,
                   pbc.bndl_addl_txt,
                   pbc.bndl_addl_val
              FROM hcrs.prfl_bndl_cond_t pbc
             WHERE (pbc.prfl_id,
                    pbc.co_id,
                    pbc.bndl_cd) IN
                   ( -- 1.1. One or more NDCs of the running calculation
                     --      effective on the bundle before the Sales Cutoff Date.
                     SELECT DISTINCT
                            ppw.prfl_id,
                            ppw.co_id,
                            pbpw.bndl_cd
                       FROM hcrs.prfl_prod_wrk_t ppw,
                            hcrs.prfl_bndl_prod_wrk_t pbpw
                   )
               -- 1.4. The Condition Start Date must be before the Sales Cutoff Date
               AND pbc.cond_strt_dt <= TRUNC( io_param_rec.snpsht_dt)
               AND (pbc.prfl_id,
                    pbc.co_id,
                    pbc.cond_cd) IN
                   (
                     SELECT DISTINCT
                            pcc.prfl_id,
                            pcc.co_id,
                            pcc.cond_cd
                       FROM hcrs.prfl_cust_cond_t pcc
                      WHERE (pcc.prfl_id,
                             pcc.co_id) IN
                            (
                              SELECT DISTINCT
                                     ppw.prfl_id,
                                     ppw.co_id
                                FROM hcrs.prfl_prod_wrk_t ppw
                            )
                         -- 1.5. The Condtion must have customers effective before the
                         --      Sales Cutoff Date
                        AND pcc.cond_strt_dt <= TRUNC( io_param_rec.snpsht_dt)
                   );
         v_cnt := v_cnt + SQL%ROWCOUNT;
         INSERT INTO hcrs.prfl_bndl_cond_wrk_t
            (bndl_cd,
             cond_cd,
             cond_strt_dt,
             cond_end_dt,
             cond_seq_no,
             bndl_prcg_prd_off,
             bndl_prcg_prd_len,
             bndl_perf_prd_off,
             bndl_perf_prd_len,
             bndl_prd_unit,
             bndl_addl_txt,
             bndl_addl_val)
            SELECT DISTINCT
                   pbpw.bndl_cd,
                   pkg_constants.cs_cond_none_cd cond_cd,
                   pkg_constants.cs_begin_time cond_strt_dt,
                   pkg_constants.cs_end_time cond_end_dt,
                   pkg_constants.cs_cond_none_seq_no cond_seq_no,
                   TO_NUMBER( NULL) bndl_prcg_prd_off,
                   TO_NUMBER( NULL) bndl_prcg_prd_len,
                   TO_NUMBER( NULL) bndl_perf_prd_off,
                   TO_NUMBER( NULL) bndl_perf_prd_len,
                   '' bndl_prd_unit,
                   '' bndl_addl_txt,
                   '' bndl_addl_val
              FROM hcrs.prfl_bndl_prod_wrk_t pbpw;
         v_cnt := v_cnt + SQL%ROWCOUNT;
         --------------------------------------------------------------------------
         -- Load Price Group Bundle definitions working table
         INSERT INTO hcrs.prfl_price_grp_bndl_wrk_t
            (bndl_cd,
             contr_id,
             price_grp_no,
             cond_cd,
             cond_strt_dt,
             cond_end_dt,
             cond_seq_no,
             bndl_strt_dt,
             bndl_end_dt,
             bndl_prcg_prd_off,
             bndl_prcg_prd_len,
             bndl_perf_prd_off,
             bndl_perf_prd_len,
             bndl_prd_unit,
             uses_mths,
             mltplr,
             bndl_addl_txt,
             bndl_addl_val)
            WITH z
              AS (
                  SELECT ppgb.co_id,
                         ppgb.bndl_cd,
                         ppgb.contr_id,
                         ppgb.price_grp_no,
                         pbcw.cond_cd,
                         pbcw.cond_strt_dt,
                         pbcw.cond_end_dt,
                         pbcw.cond_seq_no,
                         ppgb.bndl_strt_dt,
                         ppgb.bndl_end_dt,
                         NVL( pbcw.bndl_prcg_prd_off, ppgb.bndl_prcg_prd_off) bndl_prcg_prd_off,
                         NVL( pbcw.bndl_prcg_prd_len, ppgb.bndl_prcg_prd_len) bndl_prcg_prd_len,
                         NVL( pbcw.bndl_perf_prd_off, ppgb.bndl_perf_prd_off) bndl_perf_prd_off,
                         NVL( pbcw.bndl_perf_prd_len, ppgb.bndl_perf_prd_len) bndl_perf_prd_len,
                         NVL( pbcw.bndl_prd_unit, ppgb.bndl_prd_unit) bndl_prd_unit,
                         NVL( pbcw.bndl_addl_txt, ppgb.bndl_addl_txt) bndl_addl_txt,
                         NVL( pbcw.bndl_addl_val, ppgb.bndl_addl_val) bndl_addl_val
                    FROM hcrs.prfl_price_grp_bndl_t ppgb,
                         hcrs.prfl_bndl_cond_wrk_t pbcw
                   WHERE ppgb.bndl_cd = pbcw.bndl_cd
                     AND (ppgb.prfl_id,
                          ppgb.co_id,
                          ppgb.bndl_cd) IN
                         ( -- 1.1. One or more NDCs of the running calculation
                           --      effective on the bundle before the Sales Cutoff Date.
                           SELECT DISTINCT
                                  ppw.prfl_id,
                                  ppw.co_id,
                                  pbpw.bndl_cd
                             FROM hcrs.prfl_prod_wrk_t ppw,
                                  hcrs.prfl_bndl_prod_wrk_t pbpw
                         )
                     -- 1.2. The Bundle Start Date must be before the Sales Cutoff Date
                     AND ppgb.bndl_strt_dt <= TRUNC( io_param_rec.snpsht_dt)
                     -- 1.3. The Condition must be effective during the Bundle
                     --      effective period.
                     AND (   ppgb.bndl_strt_dt BETWEEN pbcw.cond_strt_dt AND pbcw.cond_end_dt
                          OR ppgb.bndl_end_dt BETWEEN pbcw.cond_strt_dt AND pbcw.cond_end_dt
                          OR pbcw.cond_strt_dt BETWEEN ppgb.bndl_strt_dt AND ppgb.bndl_end_dt
                          OR pbcw.cond_end_dt BETWEEN ppgb.bndl_strt_dt AND ppgb.bndl_end_dt)
                 )
            SELECT z.bndl_cd,
                   z.contr_id,
                   z.price_grp_no,
                   z.cond_cd,
                   z.cond_strt_dt,
                   z.cond_end_dt,
                   z.cond_seq_no,
                   z.bndl_strt_dt,
                   z.bndl_end_dt,
                   z.bndl_prcg_prd_off,
                   z.bndl_prcg_prd_len,
                   z.bndl_perf_prd_off,
                   z.bndl_perf_prd_len,
                   z.bndl_prd_unit,
                   bp.uses_mths,
                   bp.mltplr,
                   z.bndl_addl_txt,
                   z.bndl_addl_val
              FROM z,
                   hcrs.bndl_prd_t bp
             WHERE z.co_id = bp.co_id
               AND z.bndl_prd_unit = bp.bndl_prd_unit;
         v_cnt := v_cnt + SQL%ROWCOUNT;
         IF SQL%ROWCOUNT > 0
         THEN
            -- Price Group Bundle definitions found, continue on
            --------------------------------------------------------------------------
            -- Query moved to function for front-end use
            v_dts := f_mk_bndl_dts( io_param_rec);
            v_cnt := v_cnt + v_dts;
            --------------------------------------------------------------------------
            IF v_dts > 0
            THEN
               -- Price Group Bundle Dates found, continue on
               --------------------------------------------------------------------------
               -- Load Customer Conditions working table
               -- It absolutely required to collapse the contiguous/overlapping ranges
               -- in order for the condition matching to work correctly
               INSERT INTO hcrs.prfl_cust_cond_wrk_t
                  (cust_id,
                   cond_cd,
                   cond_strt_dt,
                   cond_end_dt)
                  WITH z
                    AS (-- Get Bundle Conditions in use
                        SELECT DISTINCT
                               ppw.prfl_id,
                               ppw.co_id,
                               ppbdw.cond_cd
                          FROM hcrs.prfl_prod_wrk_t ppw,
                               hcrs.prfl_prod_bndl_dts_wrk_t ppbdw
                         WHERE ppbdw.cond_cd <> pkg_constants.cs_cond_none_cd
                           AND ROWNUM > 0 --materialize
                       ),
                       y
                    AS (-- Get Customer Conditions, limit to CARS customers
                        SELECT /*+ LEADING( z pcc )
                                   USE_NL( z pcc )
                               */
                               pcc.cust_id,
                               pcc.cond_cd,
                               pcc.cond_strt_dt,
                               pcc.cond_end_dt
                          FROM z,
                               hcrs.prfl_cust_cond_t pcc
                         WHERE z.prfl_id = pcc.prfl_id
                           AND z.co_id = pcc.co_id
                           AND z.cond_cd = pcc.cond_cd
                            -- 1.5. The Condtion must have customers effective before the
                            --      Sales Cutoff Date
                           AND pcc.cond_strt_dt <= TRUNC( io_param_rec.snpsht_dt)
                            -- Only CARS customers
                           AND pcc.cust_id LIKE '%' || pkg_constants.cs_cust_cars
                           AND EXISTS
                               (
                                 SELECT NULL
                                   FROM hcrs.prfl_cust_cls_of_trd_wrk_t pccotw
                                  WHERE pccotw.cust_id = pcc.cust_id
                               )
                       ),
                       x
                    AS (-- Tag rows that are non-contiguous with the prior row by key and date
                        SELECT z.cust_id,
                               z.cond_cd,
                               z.cond_strt_dt,
                               z.cond_end_dt,
                               -- Get the end date of the previous row partitioned by the key,
                               -- ordered by the start date and end date, add one day
                               LAG( z.cond_end_dt)
                                  OVER (PARTITION BY z.cust_id,
                                                     z.cond_cd
                                            ORDER BY z.cond_strt_dt,
                                                     z.cond_end_dt) + 1 p_cond_end_dt,
                               -- Get the row number partitioned by the key, ordered by the start date and end date
                               ROW_NUMBER()
                                  OVER (PARTITION BY z.cust_id,
                                                     z.cond_cd
                                            ORDER BY z.cond_strt_dt,
                                                     z.cond_end_dt) rn
                          FROM y z
                       ),
                       w
                    AS (-- Tag rows that are non-contiguous with the prior row by key and date
                        SELECT z.cust_id,
                               z.cond_cd,
                               z.cond_strt_dt,
                               z.cond_end_dt,
                               z.p_cond_end_dt,
                               z.rn,
                               CASE
                                  -- Row is non-contiguous/non-overlapping
                                  WHEN z.p_cond_end_dt IS NULL
                                    OR z.cond_strt_dt > z.p_cond_end_dt
                                  THEN z.rn
                                  -- Row is contiguous/overlapping
                                  ELSE 0
                               END tag
                          FROM x z
                       ),
                       v
                    AS (-- Convert the tag into a grouping of rows that are contiguous
                        SELECT z.cust_id,
                               z.cond_cd,
                               z.cond_strt_dt,
                               z.cond_end_dt,
                               z.p_cond_end_dt,
                               z.rn,
                               z.tag,
                               -- Get the maximum tag number partitioned by the key, ordered by the start date and end date
                               MAX( z.tag)
                                  OVER (PARTITION BY z.cust_id,
                                                     z.cond_cd
                                            ORDER BY z.cond_strt_dt,
                                                     z.cond_end_dt) grp
                          FROM w z
                       )
                  -- Collapse the contiguous/overlapping rows by the row groupings
                  SELECT z.cust_id,
                         z.cond_cd,
                         MIN( z.cond_strt_dt) cond_strt_dt,
                         MAX( z.cond_end_dt) cond_end_dt
                    FROM v z
                   GROUP BY z.cust_id,
                            z.cond_cd,
                            z.grp;
               v_cnt := v_cnt + SQL%ROWCOUNT;
               gv_bndl_cust_cond_cnt := SQL%ROWCOUNT;
            ELSE
               -- No Price Group Bundle Dates found, nothing to do
               v_cnt := 0;
            END IF;
         ELSE
            -- No Price Group Bundle definitions found, nothing to do
            v_cnt := 0;
         END IF;
      ELSE
         -- No bundled products found, nothing to do
         v_cnt := 0;
      END IF;
      IF v_cnt = 0
      THEN
         -- No bundling to do, clear all bundling tables that may have been loaded
         p_clear_wrk_t( 2);
         -- Update bundle flag and dates on main product table
         UPDATE hcrs.prfl_prod_wrk_t ppw
            SET ppw.bndl_prod = ppw.flag_no,
                ppw.min_bndl_start_dt = NULL,
                ppw.max_bndl_end_dt = NULL;
      ELSE
         -- Update bundle start and end dates on the bundle products table
         -- A. All dates are always limited by the product start/end dates
         -- B. Pricing period dates are always limited by the bundle start/end dates
         -- C. Performance period dates may be outside the bundle start/end dates
         -- Start Date = (later of Product Start Date and (Earlier of Bundle Start Date or Performance Period Start Date))
         -- End Date = (Earlier of Product End Date and (Later of Bundle End Date or Performance End Start Date))
         UPDATE hcrs.prfl_bndl_prod_wrk_t pbpw
            SET pbpw.bndl_strt_dt =
                   GREATEST( pbpw.prod_strt_dt,
                             (
                              SELECT MIN( LEAST( ppbdw.bndl_strt_dt, NVL( ppbdw.perf_strt_dt, ppbdw.bndl_strt_dt))) bndl_strt_dt
                                FROM hcrs.prfl_prod_bndl_dts_wrk_t ppbdw
                               WHERE ppbdw.bndl_cd = pbpw.bndl_cd
                             )),
                pbpw.bndl_end_dt =
                   LEAST( pbpw.prod_end_dt,
                          (
                           SELECT MAX( GREATEST( ppbdw.bndl_end_dt, NVL( ppbdw.perf_end_dt, ppbdw.bndl_end_dt))) bndl_end_dt
                             FROM hcrs.prfl_prod_bndl_dts_wrk_t ppbdw
                            WHERE ppbdw.bndl_cd = pbpw.bndl_cd
                          ));
         -- Update bundle flag and dates on main product table
         -- 5.2. The transaction's NDC must be in effect on the bundle
         --      code based on the transaction's earned date.
         UPDATE hcrs.prfl_prod_wrk_t ppw
            SET ppw.bndl_prod = ppw.flag_yes,
                ppw.min_bndl_start_dt =
                (
                  SELECT MIN( pbpw.bndl_strt_dt) min_bndl_strt_dt
                    FROM hcrs.prfl_bndl_prod_wrk_t pbpw
                   WHERE pbpw.bndl_ndc_lbl = ppw.trans_ndc_lbl
                     AND pbpw.bndl_ndc_prod = ppw.trans_ndc_prod
                     AND pbpw.bndl_ndc_pckg = ppw.trans_ndc_pckg
                ),
                ppw.max_bndl_end_dt =
                (
                  SELECT MAX( pbpw.bndl_end_dt) max_bndl_end_dt
                    FROM hcrs.prfl_bndl_prod_wrk_t pbpw
                   WHERE pbpw.bndl_ndc_lbl = ppw.trans_ndc_lbl
                     AND pbpw.bndl_ndc_prod = ppw.trans_ndc_prod
                     AND pbpw.bndl_ndc_pckg = ppw.trans_ndc_pckg
                )
          WHERE (ppw.trans_ndc_lbl,
                 ppw.trans_ndc_prod,
                 ppw.trans_ndc_pckg) IN
                (
                  SELECT pbpw.bndl_ndc_lbl,
                         pbpw.bndl_ndc_prod,
                         pbpw.bndl_ndc_pckg
                    FROM hcrs.prfl_bndl_prod_wrk_t pbpw
                );
      END IF;
      RETURN v_cnt;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
      RETURN NULL;
   END f_mk_bndl_info;


   PROCEDURE p_mk_contr_wrk_t
      (i_param_rec IN t_calc_param_rec)
   IS
      /*************************************************************************
      * Procedure Name : p_mk_contr_wrk_t
      *   Input params : i_param_rec - Calculation parameter record
      *  Output params : None
      *   Date Created : 01/15/2018
      *         Author : Joe Kidd
      *    Description : Populates the contract working table (a global temp table)
      *
      *                  NOTE: This procedure should only write to temporary
      *                  tables, so that it can be used during testing/debugging
      *                  in production.  No changes should be made to permanent
      *                  objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Centralize GTT deletes
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_mk_contr_wrk_t';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Populates the contract working table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while populating the contract working table';
   BEGIN
      INSERT INTO hcrs.prfl_contr_wrk_t
         (contr_id,
          phs_340b_pvp_ind)
         SELECT t.contr_id,
                t.phs_340b_pvp_ind
           FROM hcrs.prfl_contr_t t
          WHERE t.prfl_id = i_param_rec.prfl_id
            AND t.phs_340b_pvp_ind = pkg_constants.cs_flag_yes
            AND i_param_rec.chk_hhs_calc = pkg_constants.cs_flag_yes
          ORDER BY 1, 2;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_mk_contr_wrk_t;


   PROCEDURE p_mk_mtrx_splt_bndl_wrk_t
      (io_param_rec IN OUT t_calc_param_rec)
   IS
      /*************************************************************************
      * Procedure Name : p_mk_mtrx_splt_bndl_wrk_t
      *   Input params : io_param_rec - Calculation parameters
      *  Output params : io_param_rec - Calculation parameters
      *        Returns : None
      *   Date Created : 01/15/2018
      *         Author : Joe Kidd
      *    Description : Populates the matrix, split, and bundle working tables
      *
      *                  NOTE: This procedure should only write to temporary
      *                  tables, so that it can be used during testing/debugging
      *                  in production.  No changes should be made to permanent
      *                  objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Correct Nominal/sub-PHS enable/disable
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_mk_mtrx_splt_bndl_wrk_t';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Populates matrix, split, and bundle working tables';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while populating matrix, split, and bundle working tables';
      v_bndl_cnt            NUMBER := 0;
   BEGIN
      IF io_param_rec.comp_def_cnt > 0
      THEN
         --------------------------------------------------------------------
         -- Set nominal/HHS violation check on product working table
         --------------------------------------------------------------------
         UPDATE hcrs.prfl_prod_wrk_t ppw
            SET ppw.chk_nom = io_param_rec.chk_nom,
                ppw.chk_hhs = io_param_rec.chk_hhs;
         --------------------------------------------------------------------
         -- Mark active component defintions rows
         --------------------------------------------------------------------
         -- Activate all component definition rows
         UPDATE hcrs.prfl_prod_calc_comp_def2_wrk_t t
            SET t.active_ind = pkg_constants.cs_flag_yes;
         -- Deactivate Nominal accumulation rows
         IF    io_param_rec.chk_nom_calc = pkg_constants.cs_flag_no
            OR io_param_rec.chk_nom = pkg_constants.cs_flag_no
         THEN
            UPDATE hcrs.prfl_prod_calc_comp_def2_wrk_t t
               SET t.active_ind = pkg_constants.cs_flag_no
             WHERE t.mark_accum_nom_ind = pkg_constants.cs_mark_accum_yes;
         END IF;
         -- Deactivate HHS violation accumulation rows
         IF    io_param_rec.chk_hhs_calc = pkg_constants.cs_flag_no
            OR io_param_rec.chk_hhs = pkg_constants.cs_flag_no
         THEN
            UPDATE hcrs.prfl_prod_calc_comp_def2_wrk_t t
               SET t.active_ind = pkg_constants.cs_flag_no
             WHERE t.mark_accum_hhs_ind = pkg_constants.cs_mark_accum_yes;
         END IF;
         --------------------------------------------------------------------
         -- Clear working tables, except Products, Components, and Bundle
         -- Summary and Detail transactions
         --------------------------------------------------------------------
         p_clear_wrk_t( 1);
         --------------------------------------------------------------------
         -- Populate Split Percentages working table (pass 1)
         --------------------------------------------------------------------
         p_mk_splt_pct_wrk_t( 1);
         --------------------------------------------------------------------
         -- Populate Matrix work table
         --------------------------------------------------------------------
         p_mk_mtrx_wrk_t;
         --------------------------------------------------------------------
         -- Populate Split Percentages working table (pass 2)
         --------------------------------------------------------------------
         p_mk_splt_pct_wrk_t( 2);
         --------------------------------------------------------------------
         -- Populate Contracts working table
         --------------------------------------------------------------------
         p_mk_contr_wrk_t( io_param_rec);
      END IF;
      --------------------------------------------------------------------
      -- Populate profile product bundle dates work table
      --------------------------------------------------------------------
      IF     (   io_param_rec.use_dra_prod_bndl = pkg_constants.cs_flag_yes
              OR io_param_rec.use_dra_time_bndl = pkg_constants.cs_flag_yes
             )
          -- These will be TRUE on first pass, then modified below
          -- Later passes will set them to FALSE if no bundling is required
         AND (   gv_bndl_use_dra_prod
              OR gv_bndl_use_dra_time
             )
          -- Components use bundling
         AND io_param_rec.bndl_adj_cnt > 0
      THEN
         -- Bundling at calc level and component bundling in use
         v_bndl_cnt := f_mk_bndl_info( io_param_rec);
      END IF;
      IF     (   io_param_rec.use_dra_prod_bndl = pkg_constants.cs_flag_yes
              OR io_param_rec.use_dra_time_bndl = pkg_constants.cs_flag_yes
             )
         AND (   gv_bndl_use_dra_prod
              OR gv_bndl_use_dra_time
             )
          -- Components use bundling
         AND io_param_rec.bndl_adj_cnt > 0
         AND v_bndl_cnt > 0
         -- Bundling at calc level and component bundling in use and bundles defined
      THEN
         gv_bndl_ind := pkg_constants.cs_flag_yes;
         gv_bndl_use_dra_prod := TRUE;
         gv_bndl_use_dra_time := TRUE;
      ELSE
         -- No bundles defined - turn off bundling
         io_param_rec.use_dra_prod_bndl := pkg_constants.cs_flag_no;
         io_param_rec.use_dra_time_bndl := pkg_constants.cs_flag_no;
         gv_bndl_ind := pkg_constants.cs_flag_no;
         gv_bndl_use_dra_prod := FALSE;
         gv_bndl_use_dra_time := FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_mk_mtrx_splt_bndl_wrk_t;


   FUNCTION f_fe_bndl_init
      (i_bndl_strt_dt      IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_strt_dt%TYPE,
       i_bndl_end_dt       IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_end_dt%TYPE,
       i_bndl_prcg_prd_off IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_prcg_prd_off%TYPE,
       i_bndl_prcg_prd_len IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_prcg_prd_len%TYPE,
       i_bndl_perf_prd_off IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_perf_prd_off%TYPE,
       i_bndl_perf_prd_len IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_perf_prd_len%TYPE,
       i_bndl_prd_unit     IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_prd_unit%TYPE,
       i_bndl_addl_txt     IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_addl_txt%TYPE,
       i_bndl_addl_val     IN hcrs.prfl_price_grp_bndl_wrk_t.bndl_addl_val%TYPE)
      RETURN NUMBER
   IS
      /*************************************************************************
      * Function Name : f_fe_bndl_init
      *  Input params : i_bndl_strt_dt
      *               : i_bndl_end_dt
      *               : i_bndl_prcg_prd_off
      *               : i_bndl_prcg_prd_len
      *               : i_bndl_perf_prd_off
      *               : i_bndl_perf_prd_len
      *               : i_bndl_prd_unit
      *               : i_bndl_addl_txt
      *               : i_bndl_addl_val
      * Output params : None
      *       Returns : NUMBER, the number of rows inserted
      *  Date Created : 10/17/2014
      *        Author : Joe Kidd
      *   Description : Populates the Profile Product Bundle Dates working table
      *                 for the front-end to demonstrate the bundle date
      *                 extrapolation process.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
      *                            Add Company ID parameter defaults to Sanofi
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Adapt to changes in Bundle Dates routine
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Remove unneeded parameters, use cleanup proc
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            New bundle period columns added
      *                            Remove unneeded pkg_constants global variables
      *                            Add normal exception handling
      *                            GTT column reductions
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_fe_bndl_init';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Populates the bundling working tables for frontend';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while populating the bundling working tables for frontend';
      v_param_rec            t_calc_param_rec;
      v_cnt                  NUMBER := 0;
   BEGIN
      -- Populate v_param_rec
      v_param_rec.snpsht_dt := pkg_constants.cs_end_time;
      v_param_rec.min_paid_start_dt := pkg_constants.cs_begin_time;
      v_param_rec.max_paid_end_dt := pkg_constants.cs_end_time;
      v_param_rec.min_earn_start_dt := pkg_constants.cs_begin_time;
      v_param_rec.max_earn_end_dt := pkg_constants.cs_end_time;
      -- Clean the working tables
      gv_dummy := f_fe_bndl_cleanup();
      -- Add the dummy price group bundle settings
      INSERT INTO hcrs.prfl_price_grp_bndl_wrk_t
         (bndl_cd,
          contr_id,
          price_grp_no,
          cond_cd,
          cond_strt_dt,
          cond_end_dt,
          cond_seq_no,
          bndl_strt_dt,
          bndl_end_dt,
          bndl_prcg_prd_off,
          bndl_prcg_prd_len,
          bndl_perf_prd_off,
          bndl_perf_prd_len,
          bndl_prd_unit,
          uses_mths,
          mltplr,
          bndl_addl_txt,
          bndl_addl_val)
         SELECT '0' bndl_cd,
                '0' contr_id,
                '0' price_grp_no,
                pkg_constants.cs_cond_none_cd cond_cd,
                pkg_constants.cs_begin_time cond_strt_dt,
                pkg_constants.cs_end_time cond_end_dt,
                pkg_constants.cs_cond_none_seq_no cond_seq_no,
                i_bndl_strt_dt bndl_strt_dt,
                i_bndl_end_dt bndl_end_dt,
                i_bndl_prcg_prd_off bndl_prcg_prd_off,
                i_bndl_prcg_prd_len bndl_prcg_prd_len,
                i_bndl_perf_prd_off bndl_perf_prd_off,
                i_bndl_perf_prd_len bndl_perf_prd_len,
                bp.bndl_prd_unit,
                bp.uses_mths,
                bp.mltplr,
                i_bndl_addl_txt bndl_addl_txt,
                i_bndl_addl_val bndl_addl_val
           FROM hcrs.bndl_prd_t bp
          WHERE bp.co_id = pkg_constants.cs_co_icw
            AND bp.bndl_prd_unit = i_bndl_prd_unit;
      -- Populate bundling dates table using same code as the calculation
      v_cnt := f_mk_bndl_dts( v_param_rec);
      COMMIT;
      RETURN v_cnt;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Only LOG error and RAISE because this function is only for the frontend
         pkg_utils.p_log_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM, 'Fatal ' || cs_cmt_txt);
         RAISE;
         RETURN NULL;
   END f_fe_bndl_init;


   FUNCTION f_fe_bndl_cleanup
      RETURN NUMBER
   IS
      /*************************************************************************
      * Function Name : f_fe_bndl_cleanup
      *  Input params : None
      * Output params : None
      *       Returns : NUMBER, 1 if succeeded
      *  Date Created : 10/17/2014
      *        Author : Joe Kidd
      *   Description : Cleans up the tables for the front-end demonstration
      *                 of the bundle date extrapolation process.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Centralize GTT deletes
      *                            Add normal exception handling
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_fe_bndl_cleanup';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Clears the bundling working tables for frontend';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while clearing the bundling working tables for frontend';
   BEGIN
      -- Cleanup tables
      p_clear_wrk_t( 2);
      COMMIT;
      RETURN 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Only LOG error and RAISE because this function is only for the frontend
         pkg_utils.p_log_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM, 'Fatal ' || cs_cmt_txt);
         RAISE;
         RETURN NULL;
   END f_fe_bndl_cleanup;


   FUNCTION f_sv_calc_comp_def_wrk_t
      RETURN NUMBER
   IS
      /*************************************************************************
      * Function Name : f_sv_calc_comp_def_wrk_t
      *  Input params : none
      * Output params : none
      *       Returns : NUMBER, the number of rows inserted
      *  Date Created : 10/17/2014
      *        Author : Joe Kidd
      *   Description : Saves Profile Product Calc Component Definition working
      *                 table to the permanent audit table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Collect bundling statistics for dates
      *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
      *                            Add new bundling control columns
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_sv_calc_comp_def_wrk_t';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Saves Profile Product Calc Component Definitions';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while saving Profile Calc Component Definitions';
   BEGIN
      INSERT INTO hcrs.prfl_prod_calc_comp_def_t
         (prfl_id,
          co_id,
          ndc_lbl,
          ndc_prod,
          ndc_pckg,
          agency_typ_cd,
          prcss_typ_cd,
          calc_typ_cd,
          calc_mthd_cd,
          pri_whls_mthd_cd,
          comp_typ_cd,
          units_comp_typ_cd,
          trans_typ_grp_cd,
          cust_cot_grp_cd,
          whls_cot_grp_cd,
          eff_bgn_dt,
          eff_end_dt,
          tim_per_bgn_dt,
          tim_per_end_dt,
          trans_dt,
          trans_dt_range,
          trans_typ_incl_ind,
          cust_cot_incl_ind,
          cust_domestic_ind,
          cust_territory_ind,
          whls_cot_incl_ind,
          whls_domestic_ind,
          whls_territory_ind,
          comp_dllrs,
          tran_dllrs,
          tran_pckgs,
          tran_ppd,
          tran_bndl,
          tran_mark_accum,
          nom_chk_dllrs,
          nom_chk_pckgs,
          nom_chk_ppd,
          nom_chk_bndl,
          nom_mark_accum_comp,
          nom_mark_accum_comp_units,
          nom_mark_accum_dllrs,
          nom_mark_accum_pckgs,
          nom_mark_accum_ppd,
          nom_mark_accum_bndl,
          nom_comp_dllrs,
          hhs_chk_dllrs,
          hhs_chk_pckgs,
          hhs_chk_ppd,
          hhs_chk_bndl,
          hhs_mark_accum_comp,
          hhs_mark_accum_comp_units,
          hhs_mark_accum_dllrs,
          hhs_mark_accum_pckgs,
          hhs_mark_accum_ppd,
          hhs_mark_accum_bndl,
          hhs_comp_dllrs,
          cmt_txt)
         SELECT t.prfl_id,
                t.co_id,
                t.ndc_lbl,
                t.ndc_prod,
                t.ndc_pckg,
                t.agency_typ_cd,
                t.prcss_typ_cd,
                t.calc_typ_cd,
                t.calc_mthd_cd,
                t.pri_whls_mthd_cd,
                t.comp_typ_cd,
                t.units_comp_typ_cd,
                t.trans_typ_grp_cd,
                t.cust_cot_grp_cd,
                t.whls_cot_grp_cd,
                t.eff_bgn_dt,
                t.eff_end_dt,
                t.tim_per_bgn_dt,
                t.tim_per_end_dt,
                t.trans_dt,
                t.trans_dt_range,
                t.trans_typ_incl_ind,
                t.cust_cot_incl_ind,
                t.cust_domestic_ind,
                t.cust_territory_ind,
                t.whls_cot_incl_ind,
                t.whls_domestic_ind,
                t.whls_territory_ind,
                t.comp_dllrs,
                t.tran_dllrs,
                t.tran_pckgs,
                t.tran_ppd,
                t.tran_bndl,
                t.tran_mark_accum,
                t.nom_chk_dllrs,
                t.nom_chk_pckgs,
                t.nom_chk_ppd,
                t.nom_chk_bndl,
                t.nom_mark_accum_comp,
                t.nom_mark_accum_comp_units,
                t.nom_mark_accum_dllrs,
                t.nom_mark_accum_pckgs,
                t.nom_mark_accum_ppd,
                t.nom_mark_accum_bndl,
                t.nom_comp_dllrs,
                t.hhs_chk_dllrs,
                t.hhs_chk_pckgs,
                t.hhs_chk_ppd,
                t.hhs_chk_bndl,
                t.hhs_mark_accum_comp,
                t.hhs_mark_accum_comp_units,
                t.hhs_mark_accum_dllrs,
                t.hhs_mark_accum_pckgs,
                t.hhs_mark_accum_ppd,
                t.hhs_mark_accum_bndl,
                t.hhs_comp_dllrs,
                t.cmt_txt
           FROM hcrs.prfl_prod_calc_comp_def_wrk_t t;
      RETURN SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_sv_calc_comp_def_wrk_t;


   FUNCTION f_sv_bndl_dts
      RETURN NUMBER
   IS
      /*************************************************************************
      * Function Name : f_sv_bndl_dts
      *  Input params : none
      * Output params : none
      *       Returns : NUMBER, the number of rows inserted
      *  Date Created : 12/05/2007
      *        Author : Joe Kidd
      *   Description : Saves Profile Product Bundle Dates working table to
      *                 the permanent audit table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  06/16/2008  Joe Kidd      PICC 1927: Add Condition fields
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            GTT column reductions
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_sv_bndl_dts';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Saves Profile Product Bundle Dates';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while saving Profile Product Bundle Dates';
   BEGIN
      INSERT INTO hcrs.prfl_prod_bndl_dts_t
         (prfl_id,
          co_id,
          ndc_lbl,
          ndc_prod,
          ndc_pckg,
          calc_typ_cd,
          bndl_id,
          bndl_cd,
          contr_id,
          price_grp_no,
          cond_cd,
          cond_strt_dt,
          cond_end_dt,
          cond_seq_no,
          bndl_strt_dt,
          bndl_end_dt,
          prcg_strt_dt,
          prcg_end_dt,
          perf_strt_dt,
          perf_end_dt)
         SELECT ppw.prfl_id,
                ppw.co_id,
                ppw.ndc_lbl,
                ppw.ndc_prod,
                ppw.ndc_pckg,
                ppw.calc_typ_cd,
                0,
                ppbdw.bndl_cd,
                ppbdw.contr_id,
                ppbdw.price_grp_no,
                ppbdw.cond_cd,
                ppbdw.cond_strt_dt,
                ppbdw.cond_end_dt,
                ppbdw.cond_seq_no,
                ppbdw.bndl_strt_dt,
                ppbdw.bndl_end_dt,
                ppbdw.prcg_strt_dt,
                ppbdw.prcg_end_dt,
                ppbdw.perf_strt_dt,
                ppbdw.perf_end_dt
           FROM hcrs.prfl_prod_wrk_t ppw,
                hcrs.prfl_prod_bndl_dts_wrk_t ppbdw
          WHERE ppw.calc_min_ndc = ppw.flag_yes;
      RETURN SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_sv_bndl_dts;


   FUNCTION f_sv_bndl_smry
      RETURN NUMBER
   IS
      /*************************************************************************
      * Function Name : f_sv_bndl_smry
      *  Input params : none
      * Output params : none
      *       Returns : NUMBER, the number of rows inserted
      *  Date Created : 01/15/2018
      *        Author : Joe Kidd
      *   Description : Saves Profile Product Bundle Summary working table to
      *                 the permanent audit table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            GTT column reductions
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_sv_bndl_smry';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Saves Profile Product Bundle Summary';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while saving Profile Product Bundle Summary';
   BEGIN
      -- Get count of bundle summary rows with transacton count greater than zero
      SELECT /*+ FULL( ppbsw ) */
             COUNT(*) bndl_smry_cnt,
             SUM( (ppbsw.prcg_trns_cnt + ppbsw.perf_trns_cnt)) bndl_trans_cnt
        INTO gv_bndl_smry_cnt,
             gv_bndl_trans_cnt
        FROM hcrs.prfl_prod_bndl_smry_wrk_t ppbsw
       WHERE (ppbsw.prcg_trns_cnt + ppbsw.perf_trns_cnt) > 0;
      IF gv_bndl_smry_cnt = 0
      THEN
         -- No bundling summary rows means bundling not active, disable it
         gv_bndl_use_dra_prod := FALSE;
         gv_bndl_use_dra_time := FALSE;
         gv_bndl_ind := pkg_constants.cs_flag_no;
         gv_bndl_trans_cnt := 0;
         gv_bndl_adj_cnt := 0;
      ELSE
         -- Move needed bundle summary rows (transactons count is greater than zero)
         INSERT INTO hcrs.prfl_prod_bndl_smry_t
            (prfl_id,
             co_id,
             ndc_lbl,
             ndc_prod,
             ndc_pckg,
             calc_typ_cd,
             cust_id,
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
             prcg_dsc_pct,
             perf_trns_cnt,
             perf_dllrs_grs,
             perf_dllrs_dsc,
             perf_dsc_pct,
             tot_trns_cnt,
             tot_dllrs_grs,
             tot_dllrs_dsc,
             tot_dsc_pct)
            SELECT /*+ FULL( ppbsw ) */
                   gv_param_rec.prfl_id,
                   gv_param_rec.co_id,
                   gv_param_rec.mk_ndc_lbl,
                   gv_param_rec.mk_ndc_prod,
                   gv_param_rec.mk_ndc_pckg,
                   gv_param_rec.calc_typ_cd,
                   ppbsw.cust_id,
                   ppbsw.trans_cls_cd,
                   ppbsw.trans_typ_cd,
                   ppbsw.bndl_cd,
                   ppbsw.cond_cd,
                   ppbsw.prcg_strt_dt,
                   ppbsw.prcg_end_dt,
                   ppbsw.perf_strt_dt,
                   ppbsw.perf_end_dt,
                   ppbsw.bndl_seq_no,
                   ppbsw.prcg_trns_cnt,
                   ppbsw.prcg_dllrs_grs,
                   ppbsw.prcg_dllrs_dsc,
                   DECODE( ppbsw.prcg_dllrs_grs, 0, 0, ppbsw.prcg_dllrs_dsc / ppbsw.prcg_dllrs_grs) prcg_dsc_pct,
                   ppbsw.perf_trns_cnt,
                   ppbsw.perf_dllrs_grs,
                   ppbsw.perf_dllrs_dsc,
                   DECODE( ppbsw.perf_dllrs_grs, 0, 0, ppbsw.perf_dllrs_dsc / ppbsw.perf_dllrs_grs) perf_dsc_pct,
                   (ppbsw.prcg_trns_cnt + ppbsw.perf_trns_cnt) tot_trns_cnt,
                   (ppbsw.prcg_dllrs_grs + ppbsw.perf_dllrs_grs) tot_dllrs_grs,
                   (ppbsw.prcg_dllrs_dsc + ppbsw.perf_dllrs_dsc) tot_dllrs_dsc,
                   DECODE( (ppbsw.prcg_dllrs_grs + ppbsw.perf_dllrs_grs), 0, 0,
                           (ppbsw.prcg_dllrs_dsc + ppbsw.perf_dllrs_dsc) /
                           (ppbsw.prcg_dllrs_grs + ppbsw.perf_dllrs_grs)) tot_dsc_pct
              FROM hcrs.prfl_prod_bndl_smry_wrk_t ppbsw
             WHERE (ppbsw.prcg_trns_cnt + ppbsw.perf_trns_cnt) > 0;
      END IF;
      RETURN gv_bndl_smry_cnt;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_sv_bndl_smry;


   FUNCTION f_sv_bndl_stats
      (io_param_rec IN OUT t_calc_param_rec)
      RETURN NUMBER
   IS
      /*************************************************************************
      * Function Name : f_sv_bndl_stats
      *  Input params : io_param_rec - Calculation parameters
      * Output params : io_param_rec - Calculation parameters
      *       Returns : NUMBER, the number of rows updated
      *  Date Created : 10/17/2014
      *        Author : Joe Kidd
      *   Description : Saves Bundle statistics to the profile product
      *                 NDC11/9 tables
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_sv_bndl_stats';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Saves Bundle Statistics';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while saving Bundle Statistics';
      v_cnt                 NUMBER := 0;
   BEGIN
      IF io_param_rec.calc_ndc_pckg_lvl = pkg_constants.cs_flag_no
      THEN
         -- These rows will only exist for Medicaid Calcs
         UPDATE hcrs.prfl_calc_prod_fmly_t pcpf
            SET pcpf.bndl_ind = gv_bndl_ind,
                pcpf.bndl_dts_cnt = gv_bndl_dts_cnt,
                pcpf.bndl_smry_cnt = gv_bndl_smry_cnt,
                pcpf.bndl_trans_cnt = gv_bndl_trans_cnt,
                pcpf.bndl_adj_cnt = gv_bndl_adj_cnt
          WHERE pcpf.prfl_id = io_param_rec.prfl_id
            AND pcpf.calc_typ_cd = io_param_rec.calc_typ_cd
            AND pcpf.ndc_lbl = io_param_rec.ndc_lbl
            AND pcpf.ndc_prod = io_param_rec.ndc_prod;
         v_cnt := v_cnt + SQL%ROWCOUNT;
      END IF;
      -- These rows will exist for All Calcs
      UPDATE hcrs.prfl_calc_prod_t pcp
         SET pcp.bndl_ind = gv_bndl_ind,
             pcp.bndl_dts_cnt = gv_bndl_dts_cnt,
             pcp.bndl_smry_cnt = gv_bndl_smry_cnt,
             pcp.bndl_trans_cnt = gv_bndl_trans_cnt,
             pcp.bndl_adj_cnt = gv_bndl_adj_cnt
       WHERE pcp.prfl_id = io_param_rec.prfl_id
         AND pcp.calc_typ_cd = io_param_rec.calc_typ_cd
         AND pcp.ndc_lbl = io_param_rec.ndc_lbl
         AND pcp.ndc_prod = io_param_rec.ndc_prod
         AND pcp.ndc_pckg = NVL( io_param_rec.ndc_pckg, pcp.ndc_pckg);
      v_cnt := v_cnt + SQL%ROWCOUNT;
      RETURN v_cnt;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_sv_bndl_stats;


   PROCEDURE p_create_prod_price_tbl
      (i_param_rec         IN     t_calc_param_rec,
       i_prod_price_typ_cd IN     hcrs.prod_price_typ_t.prod_price_typ_cd%TYPE,
       io_price_tbl        IN OUT t_prod_price_tbl,
       i_unit_per_pckg     IN     hcrs.prod_mstr_t.unit_per_pckg%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_create_prod_price_tbl
      *   Input params : i_param_rec - Calculation Parameters
      *                : i_prod_price_typ_cd - Price Type to use
      *                : io_price_tbl - Table of pricing
      *                : i_unit_per_pckg - used to convert package prices to unit prices
      *  Output params : io_price_tbl - Table of pricing
      *   Date Created : 04/26/2001
      *         Author : Venkata Darabala
      *    Description : Creates product price PL/SQL table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  07/19/2001  T. Zimmerman  Added error handler
      *  07/19/2001  T. Zimmerman  Changed to get quarter via: TO_CHAR(ADD_MONTHS(v_end_dt,v_period * -3),'q') AS qtr
      *  02/04/2004  Joe Kidd      PICC 1167: Added i_param_rec parameter and
      *                            use p_update_interim_table
      *  05/05/2005  Joe Kidd      PICC 1406: Treat Annual range and current
      *                            period range seperately
      *  06/12/2006  Joe Kidd      PICC 1557: Apply naming conventions
      *  12/13/2006  Joe Kidd      PICC 1680: Changed PL 102 constant due to constants cleanup
      *  02/15/2007  Joe Kidd      PICC 1706: Use pkg_common_functions.f_get_price instead
      *                            Add Annual Offset checking
      *                            New parameter names, naming conventions
      *                            Fix logic error that omitted quarters
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Get any passed price type, not just PL 102
      *                            Get prices for all NDCs in calculation
      *                            Get prices with actual dates not just last
      *                            price of the quarter
      *                            Save prices to permanent profile table
      *                            Pass units per package to convert package price to unit price
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_create_prod_price_tbl';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Creates product price PL/SQL table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while creating product price PL/SQL table';
      v_cnt                 NUMBER;
   BEGIN
      -- Delete prices from the pl/sql table
      io_price_tbl.DELETE();
      -- Delete prices from the saved table
      DELETE
        FROM hcrs.prfl_prod_price_t ppp
       WHERE ppp.prfl_id = i_param_rec.prfl_id
         AND ppp.ndc_lbl = i_param_rec.mk_ndc_lbl
         AND ppp.ndc_prod = i_param_rec.mk_ndc_prod
         AND ppp.ndc_pckg = i_param_rec.mk_ndc_pckg
         AND ppp.calc_typ_cd = i_param_rec.calc_typ_cd
         AND ppp.prod_price_typ_cd = i_prod_price_typ_cd;
      -- Commit Records
      p_commit( SQL%ROWCOUNT);
      -- Load prices into the saved table
      INSERT INTO hcrs.prfl_prod_price_t
         (prfl_id,
          ndc_lbl,
          ndc_prod,
          ndc_pckg,
          calc_typ_cd,
          prod_price_ndc_lbl,
          prod_price_ndc_prod,
          prod_price_ndc_pckg,
          prod_price_typ_cd,
          prod_price_eff_dt,
          prod_price_end_dt,
          prod_price_amt,
          rec_src_ind)
         SELECT ppw.prfl_id,
                ppw.ndc_lbl,
                ppw.ndc_prod,
                ppw.ndc_pckg,
                ppw.calc_typ_cd,
                ppw.trans_ndc_lbl prod_price_ndc_lbl,
                ppw.trans_ndc_prod prod_price_ndc_prod,
                ppw.trans_ndc_pckg prod_price_ndc_pckg,
                pp.prod_price_typ_cd,
                pp.eff_dt prod_price_eff_dt,
                pp.end_dt prod_price_end_dt,
                pp.price_amt prod_price_amt,
                pp.rec_src_ind
           FROM hcrs.prfl_prod_wrk_t ppw,
                hcrs.prod_price_t pp
          WHERE ppw.trans_ndc_lbl = pp.ndc_lbl
            AND ppw.trans_ndc_prod = pp.ndc_prod
            AND ppw.trans_ndc_pckg = pp.ndc_pckg
            AND ppw.end_dt >= pp.eff_dt
            AND ppw.prfl_id = i_param_rec.prfl_id
            AND ppw.ndc_lbl = i_param_rec.mk_ndc_lbl
            AND ppw.ndc_prod = i_param_rec.mk_ndc_prod
            AND ppw.ndc_pckg = i_param_rec.mk_ndc_pckg
            AND ppw.calc_typ_cd = i_param_rec.calc_typ_cd
            AND pp.prod_price_typ_cd = i_prod_price_typ_cd
          ORDER BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11;
      -- Commit Records
      p_commit( SQL%ROWCOUNT);
      -- Load prices from the saved table into the PL/SQL table
      FOR v_price IN
         (  -- Get prices in descending date order to speed lookups
            SELECT ppp.prod_price_ndc_lbl,
                   ppp.prod_price_ndc_prod,
                   ppp.prod_price_ndc_pckg,
                   ppp.prod_price_eff_dt,
                   ppp.prod_price_end_dt,
                   ppp.prod_price_amt
              FROM hcrs.prfl_prod_price_t ppp
             WHERE ppp.prfl_id = i_param_rec.prfl_id
               AND ppp.ndc_lbl = i_param_rec.mk_ndc_lbl
               AND ppp.ndc_prod = i_param_rec.mk_ndc_prod
               AND ppp.ndc_pckg = i_param_rec.mk_ndc_pckg
               AND ppp.calc_typ_cd = i_param_rec.calc_typ_cd
               AND ppp.prod_price_typ_cd = i_prod_price_typ_cd
             ORDER BY 5 DESC, 1, 2, 3
         )
      LOOP
         v_cnt := io_price_tbl.COUNT() + 1;
         io_price_tbl( v_cnt).ndc_lbl := v_price.prod_price_ndc_lbl;
         io_price_tbl( v_cnt).ndc_prod := v_price.prod_price_ndc_prod;
         io_price_tbl( v_cnt).ndc_pckg := v_price.prod_price_ndc_pckg;
         io_price_tbl( v_cnt).start_dt := v_price.prod_price_eff_dt;
         io_price_tbl( v_cnt).end_dt := v_price.prod_price_end_dt;
         io_price_tbl( v_cnt).src_price := v_price.prod_price_amt;
         io_price_tbl( v_cnt).chk_price := v_price.prod_price_amt * NVL( i_unit_per_pckg, 1);
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_create_prod_price_tbl;


   PROCEDURE p_create_amp_nd_tbl
      (i_param_rec     IN     t_calc_param_rec,
       io_nd_tbl       IN OUT t_price_tbl,
       i_unit_per_pckg IN     hcrs.prod_mstr_t.unit_per_pckg%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_create_amp_nd_tbl
      *   Input params : i_param_rec - Calculation Parameters
      *                : io_nd_tbl - Nominal Pricing Table
      *                : i_unit_per_pckg - used to convert unit AMP to pkg AMP
      *  Output params : io_nd_tbl - Nominal Pricing Table
      *   Date Created : 02/15/2007
      *         Author : Joe Kidd
      *    Description : Creates AMP Nominal price PL/SQL table
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  05/18/2007  Joe Kidd      PICC 1769: Allow preliminary profiles to retrieve preliminary AMPs
      *  10/01/2007  Joe Kidd      PICC 1808: Pass units per package to convert to packages
      *                            Use new pkg_common_functions.f_get_prod_comp
      *                            Allow Monthly AMP to fallback to Quarterly AMP
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Add First Date Sold
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Remove call to pkg_common_functions.f_calc_nominal_dollars
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_create_amp_nd_tbl';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Creates AMP Nominal price PL/SQL table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while creating AMP Nominal price PL/SQL table';
      v_cnt                 NUMBER;
      v_period              NUMBER;
      v_start_dt            DATE;
      v_end_dt              DATE;
      v_price_amt           NUMBER;
   BEGIN
      -- Delete the pl/sql table
      io_nd_tbl.DELETE();
      --
      -- Start with the current period's end date and go backwards by quarter
      -- check each end date to see if it is used by the annual range or the current period
      -- stop when the end date we are checking is before the annual start date.
      --
      -- Possible annual/current period relationships:
      --   Annual and current period are the same (Annual/FFQ/30Day NFAMP) (4 qtrs or 1 qtr)
      --   Annual period overlaps current period (old Quarterly NFAMP) (4 qtrs)
      --     Annual  = 01/01/2004 to 12/31/2004
      --     Current = 10/01/2004 to 12/31/2004
      --   Annual period precedes current period (Quarterly NFAMP) (5 qtrs)
      --     Annual  = 01/01/2004 to 12/31/2004
      --     Current = 01/01/2005 to 03/31/2005
      --
      -- Loop for number of periods between the earliest start date and the end date
      v_cnt := 0; -- number of the period we are getting
      v_period := 0; -- number of periods back we are
      v_end_dt := i_param_rec.end_dt;
      v_start_dt := ADD_MONTHS( v_end_dt, i_param_rec.prfl_mths * -1) + 1;
      LOOP
         -- exit loop if the current end date before the earliest start date
         EXIT WHEN v_end_dt < LEAST( i_param_rec.start_dt, i_param_rec.ann_start_dt, i_param_rec.ann_off_start_dt);
         IF   v_end_dt >= i_param_rec.mrkt_entry_dt
          AND v_end_dt >= i_param_rec.first_dt_sld
          AND (    v_end_dt BETWEEN i_param_rec.start_dt AND i_param_rec.end_dt
               OR v_end_dt BETWEEN i_param_rec.ann_start_dt AND i_param_rec.ann_end_dt
               OR v_end_dt BETWEEN i_param_rec.ann_off_start_dt AND i_param_rec.ann_off_end_dt)
         THEN
            -- current end date is in either the current period or an annual range
            -- Retrieve AMP
            v_price_amt := pkg_common_functions.f_get_prod_comp
                              (v_start_dt,
                               v_end_dt,
                               i_param_rec.ndc_lbl,
                               i_param_rec.ndc_prod,
                               i_param_rec.ndc_pckg,
                               pkg_constants.cs_calc_typ_amp_cd,
                               pkg_constants.cs_amp,
                               i_param_rec.prelim_ind);
            IF   v_price_amt IS NULL
             AND i_param_rec.prcss_typ_cd = pkg_constants.cs_med_prcssng_typ_mthly
            THEN
               -- Monthly AMPs should fall back to Quarterly AMPs
               -- Determine the products' price for the given period from the calculation type table
               v_price_amt := pkg_common_functions.f_get_prod_comp
                                 (v_start_dt,
                                  v_end_dt,
                                  i_param_rec.ndc_lbl,
                                  i_param_rec.ndc_prod,
                                  i_param_rec.ndc_pckg,
                                  pkg_constants.cs_calc_typ_amp_cd,
                                  pkg_constants.cs_amp,
                                  i_param_rec.prelim_ind,
                                  NULL,
                                  pkg_constants.cs_flag_yes); -- First AMP in effect
            END IF;
            v_cnt := v_cnt + 1;
            io_nd_tbl( v_cnt).start_dt := v_start_dt;
            io_nd_tbl( v_cnt).end_dt := v_end_dt;
            io_nd_tbl( v_cnt).src_price := v_price_amt;
            IF i_unit_per_pckg IS NOT NULL
            THEN
               v_price_amt := v_price_amt * i_unit_per_pckg;
            END IF;
            io_nd_tbl( v_cnt).chk_price := v_price_amt * i_param_rec.nom_thrs_pct;
         END IF;
         -- Move the end date backwards another period
         v_period := v_period + 1;
         v_end_dt := ADD_MONTHS( v_end_dt, i_param_rec.prfl_mths * -1);
         v_start_dt := ADD_MONTHS( v_end_dt, i_param_rec.prfl_mths * -1) + 1;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_create_amp_nd_tbl;


   PROCEDURE p_calc_delete
      (i_calc_log_user_msg IN hcrs.prfl_prod_t.user_msg_txt%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_calc_delete
      *   Input params : i_calc_log_user_msg - Calc Log User Message
      *  Output params : None
      *   Date Created : 11/29/2000
      *         Author : Venkata Darabala
      *    Description : Delete calculations for the profile
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  01/25/2001  T. Zimmerman  Removed UPDATE hcrs.prod_trnsmsn_t
      *  01/30/2001  Bhaskar       Constrained the query to Family level
      *  02/13/2001  T. Zimmerman  Removed AND pp.calc_stat_cd = pkg_constants.cs_calc_run_status
      *  02/14/2001  T. Zimmerman  Added AND DECODE(pkg_constants.var_ndc_pckg,NULL,0,pp.ndc_pckg) = nvl(pkg_constants.var_ndc_pckg,0))
      *  12/11/2001  T. Zimmerman  PICC 746 - Clean up PUR_SUMM_T
      *  06/01/2002  T. Zimmerman  Modified PUR delete logic for new PUR changes
      *  02/04/2004  Joe Kidd      PICC 1167: Remove agency references
      *  09/10/2004  Joe Kidd      PICC 1253: Delete marking table records in
      *                            groups by the commit point
      *  10/28/2004  Joe Kidd      PICC 1316: Force Commit after calculation
      *                            has been deleted
      *  12/13/2006  Joe Kidd      PICC 1680: Add status messages
      *  02/15/2007  Joe Kidd      PICC 1706: Replace literals with constants
      *  04/22/2008  Joe Kidd      PICC 1865: Clear Bundle tables
      *  06/16/2008  Joe Kidd      PICC 1927: Remove Bundle CPG Summary table
      *                            Increase commit point 10 times for deletes
      *  08/22/2008  Joe Kidd      PICC 1961: Correct Profile Product Bundle
      *                            Contract Price Group Transactions abbreviation
      *  07/22/2009  Joe Kidd      RT 267 - CRQ 43432: Bundling Tuning
      *                            Add Company ID to Bundling deletes
      *  10/01/2010  Joe Kidd      CRQ-53357: October 2010 Govt Calculations Release
      *                            Use new views
      *  02/10/2011  Joe Kidd      CRQ-1471: Fix Company Product Association Calc Error
      *                            Add profile to f_get_prod_company_id call
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Use pkg_utils App Info
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Add tablename to error messages
      *                            Clear Calc Component Definition table
      *                            Add user status msgs and longops
      *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
      *                            Clear user status msg on completion
      *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
      *                            Remove all references to bp_pnt_contr_dtl_t
      *                            Adjust for new bp_pnt_trans_dtl_t layout
      *                            Calc Log adds formatted counts to user message
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Clean up logging and longops handling
      *                            Use package globals if possible
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Add parameter for calc log user message
      *                            Use updated calc log procedures
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Delete all tables in commit loop, reduce code
      *                            Clean up logging and longops handling
      *                            Remove unneeded pkg_constants global variables
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_calc_delete';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Deletes calculations for the profile';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while deleting calculations for the profile';
      v_prfl_id             hcrs.prfl_prod_comp_trans_t.prfl_id%TYPE;
      v_co_id               hcrs.prfl_prod_comp_trans_t.co_id%TYPE;
      v_ndc_lbl             hcrs.prfl_prod_comp_trans_t.ndc_lbl%TYPE;
      v_ndc_prod            hcrs.prfl_prod_comp_trans_t.ndc_prod%TYPE;
      v_ndc_pckg            hcrs.prfl_prod_comp_trans_t.ndc_pckg%TYPE;
      v_calc_typ_cd         hcrs.prfl_prod_comp_trans_t.calc_typ_cd%TYPE;
      v_tbls_per_ndc        NUMBER;
      v_cntr                NUMBER;
      v_tbl_name            VARCHAR2( 30);
      v_tbl_abbr            VARCHAR2( 30);
      v_tbl_done            NUMBER;
      v_tbl_total           NUMBER;
      v_row_done            NUMBER;
      v_row_total           NUMBER;
      v_row_count           NUMBER;
      v_commit              NUMBER;
      v_module_name         hcrs.pkg_utils.gv_module_name%TYPE;
      v_action_name         hcrs.pkg_utils.gv_action_name%TYPE;
      v_user_msg            hcrs.prfl_prod_t.user_msg_txt%TYPE;
      v_user_msg_tbl        hcrs.prfl_prod_t.user_msg_txt%TYPE;
      v_user_msg_row        hcrs.prfl_prod_t.user_msg_txt%TYPE;
      v_comp_typ_cd         hcrs.prfl_prod_calc_log_t.comp_typ_cd%TYPE;

      PROCEDURE p_row
         (i_action_name  IN  hcrs.pkg_utils.gv_action_name%TYPE,
          i_user_msg     IN  hcrs.prfl_prod_t.user_msg_txt%TYPE,
          i_user_msg_tbl IN  hcrs.prfl_prod_t.user_msg_txt%TYPE,
          i_tbl_abbr     IN  VARCHAR2,
          i_row_done     IN  NUMBER,
          i_row_total    IN  NUMBER,
          i_row_count    IN  NUMBER,
          o_row_done     OUT NUMBER,
          o_row_total    OUT NUMBER,
          o_row_count    OUT NUMBER)
      IS
         v_user_msg_row   hcrs.prfl_prod_t.user_msg_txt%TYPE;
      BEGIN
         -- DELETE LOOP
         -- Get COUNT(*) in to row total
         -- p_row BEFORE LOOP:
         --    Row Done Input  : Pass NULL
         --    Row Total Input : Pass row total variable
         --    Rows Count Input: Pass commit point
         --    DURING LOOP: pass rows done variable
         -- WHILE row total > 0 and count = commit point
         --    DELETE WHERE ROWNUM <= commit point
         --    p_row DURING LOOP:
         --       Row Done Input  : pass rows done variable
         --       Row Total Input : Pass row total variable
         --       Rows Count Input: Pass SQL%ROWCOUNT
         -- END LOOP
         o_row_total := NVL( i_row_total, 0);
         o_row_count := NVL( i_row_count, 0);
         IF i_row_done IS NULL
         THEN
            -- NULL rows done means new table delete loop, ignore row count
            o_row_done := 0;
         ELSE
            o_row_done := i_row_done + o_row_count;
            -- Only commit when work was done
            p_commit( o_row_count);
         END IF;
         v_user_msg_row := ', ' || TO_CHAR( o_row_done, cs_calc_log_fmt_num) || ' of ' || TO_CHAR( o_row_total, cs_calc_log_fmt_num) || ' rows';
         p_set_cntr( cs_calc_log_cntr_tbl_rows, o_row_done, o_row_total, i_tbl_abbr);
         p_calc_log( i_action_name || i_tbl_abbr || ' ' || o_row_done, i_user_msg || i_user_msg_tbl || v_user_msg_row, i_tbl_abbr);
      END p_row;

      PROCEDURE p_tbl
         (i_tbl_name     IN VARCHAR2,
          i_tbl_abbr     IN VARCHAR2,
          i_tbl_done     IN NUMBER,
          i_tbl_total    IN NUMBER,
          i_tbls_per_ndc IN NUMBER,
          i_cntr         IN NUMBER,
          i_comp_typ_cd  IN VARCHAR2,
          i_user_msg     IN VARCHAR2,
          o_tbl_name     OUT VARCHAR2,
          o_tbl_abbr     OUT VARCHAR2,
          o_tbl_done     OUT NUMBER,
          o_user_msg_tbl OUT VARCHAR2)
      IS
      BEGIN
         -- Show the tables
         o_tbl_name := i_tbl_name;
         o_tbl_abbr := i_tbl_abbr;
         o_tbl_done := i_tbl_done + (i_tbls_per_ndc * (i_cntr - 1));
         o_user_msg_tbl := ' table ' || TO_CHAR( o_tbl_done, cs_calc_log_fmt_num) || ' of ' || TO_CHAR( i_tbl_total, cs_calc_log_fmt_num);
         -- Update the table counter
         p_set_cntr( cs_calc_log_cntr_tbls, o_tbl_done, i_tbl_total, i_comp_typ_cd);
         p_calc_log( v_action_name || o_tbl_abbr, i_user_msg || o_user_msg_tbl, i_comp_typ_cd);
      END p_tbl;

   BEGIN
      -- Set calc delete runnning status to ON
      gv_calc_delete_running := TRUE;
      pkg_utils.p_appinfo_stk_push;
      -- Get the product calculation from the parameter record, otherwise from globals
      v_prfl_id := NVL( gv_param_rec.prfl_id, pkg_constants.var_prfl_id);
      v_co_id := gv_param_rec.co_id;
      v_ndc_lbl := NVL( gv_param_rec.ndc_lbl, pkg_constants.var_ndc_lbl);
      v_ndc_prod := NVL( gv_param_rec.ndc_prod, pkg_constants.var_ndc_prod);
      v_ndc_pckg := NVL( gv_param_rec.ndc_pckg, pkg_constants.var_ndc_pckg);
      v_calc_typ_cd := NVL( gv_param_rec.calc_typ_cd, pkg_constants.var_calc_typ_cd);
      -- Set the module name
      v_module_name := gv_calc_log_module_name;
      gv_calc_log_module_name := f_get_calc_module( v_prfl_id, v_ndc_lbl, v_ndc_prod, v_ndc_pckg, v_calc_typ_cd);
      -- Set number of tables that will be deleted
      v_tbls_per_ndc := 15;
      -- Increase commit point
      v_commit := pkg_constants.cs_commit_point * 10;
      p_init_cntrs( cs_calc_log_cntr_tbls);
      -- Delete existing profile product calculation if any
      FOR v_prod IN
         (
            SELECT z.*,
                   COUNT(*) OVER () cnt
              FROM (
                     SELECT DISTINCT
                            p.prfl_id,
                            p.co_id,
                            pp.ndc_lbl,
                            pp.ndc_prod,
                            DECODE( p.calc_ndc_pckg_lvl,
                                    p.flag_yes, pp.ndc_pckg) ndc_pckg,
                            p.calc_typ_cd,
                            pt.trnsmsn_seq_no,
                            pt.period_id
                       FROM hcrs.prfl_co_calc_v p,
                            hcrs.prfl_prod_t pp,
                            hcrs.prfl_trnsmsn_t pt
                      WHERE p.prfl_id = pp.prfl_id
                        AND pp.prfl_id = pt.prfl_id (+)
                        AND pp.ndc_lbl = pt.ndc_lbl (+)
                        AND pp.ndc_prod = pt.ndc_prod (+)
                        AND p.prfl_id = v_prfl_id
                        AND p.co_id = NVL( v_co_id, p.co_id)
                        AND p.calc_typ_cd = v_calc_typ_cd
                        AND pp.ndc_lbl = v_ndc_lbl
                        AND pp.ndc_prod = v_ndc_prod
                        AND pp.ndc_pckg = DECODE( p.calc_ndc_pckg_lvl,
                                                  p.flag_yes, v_ndc_pckg,
                                                  pp.ndc_pckg)
                   ) z
             ORDER BY 1, 2, 3, 4, 5, 6
         )
      LOOP
         v_cntr := NVL( v_cntr, 0) + 1;
         v_tbl_total := v_tbls_per_ndc * v_prod.cnt;
         IF i_calc_log_user_msg IS NULL
         THEN
            v_user_msg := 'Deleting';
         ELSE
            v_user_msg := i_calc_log_user_msg || ', deleting';
         END IF;
         v_action_name := 'DEL ' || v_prod.ndc_lbl || '-' || v_prod.ndc_prod;
         v_comp_typ_cd := 'DELETE';
         IF v_prod.ndc_pckg IS NOT NULL
         THEN
            v_action_name := v_action_name || '-' || v_prod.ndc_pckg;
         END IF;
         v_action_name := v_action_name || ': ';
         IF NVL( v_tbl_done, 0) = 0
         THEN
            -- Initialize table counter
            p_calc_log( v_action_name || 'Start', v_user_msg || ' start', v_comp_typ_cd);
         END IF;
         IF v_prod.ndc_pckg IS NOT NULL
         THEN
            -----------------------------------------------------------------------
            -- NDC11 aggregate marking table
            p_tbl( 'PRFL_PROD_COMP_TRANS_T', 'PPCT', 1, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
            SELECT COUNT(*)
              INTO v_row_total
              FROM hcrs.prfl_prod_comp_trans_t ppct
             WHERE ppct.prfl_id = v_prod.prfl_id
               AND ppct.ndc_lbl = v_prod.ndc_lbl
               AND ppct.ndc_prod = v_prod.ndc_prod
               AND ppct.ndc_pckg = v_prod.ndc_pckg
               AND ppct.calc_typ_cd = v_prod.calc_typ_cd;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
            WHILE  v_row_total > 0
               AND v_row_count = v_commit
            LOOP
               DELETE
                 FROM hcrs.prfl_prod_comp_trans_t ppct
                WHERE ppct.prfl_id = v_prod.prfl_id
                  AND ppct.ndc_lbl = v_prod.ndc_lbl
                  AND ppct.ndc_prod = v_prod.ndc_prod
                  AND ppct.ndc_pckg = v_prod.ndc_pckg
                  AND ppct.calc_typ_cd = v_prod.calc_typ_cd
                  AND ROWNUM <= v_commit;
               p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
            END LOOP;
         ELSE
            -----------------------------------------------------------------------
            -- NDC9 aggregate marking table
            p_tbl( 'PRFL_PROD_FMLY_COMP_TRANS_T', 'PPFCT', 2, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
            SELECT COUNT(*)
              INTO v_row_total
              FROM hcrs.prfl_prod_fmly_comp_trans_t ppfct
             WHERE ppfct.prfl_id = v_prod.prfl_id
               AND ppfct.ndc_lbl = v_prod.ndc_lbl
               AND ppfct.ndc_prod = v_prod.ndc_prod
               AND ppfct.calc_typ_cd = v_prod.calc_typ_cd;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
            WHILE  v_row_total > 0
               AND v_row_count = v_commit
            LOOP
               DELETE
                 FROM hcrs.prfl_prod_fmly_comp_trans_t ppfct
                WHERE ppfct.prfl_id = v_prod.prfl_id
                  AND ppfct.ndc_lbl = v_prod.ndc_lbl
                  AND ppfct.ndc_prod = v_prod.ndc_prod
                  AND ppfct.calc_typ_cd = v_prod.calc_typ_cd
                  AND ROWNUM <= v_commit;
               p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
            END LOOP;
         END IF;
         IF v_prod.calc_typ_cd = pkg_constants.cs_calc_typ_bp_cd
         THEN
            -----------------------------------------------------------------------
            -- BP marking table
            p_tbl( 'BP_PNT_TRANS_DTL_T', 'BPTD', 3, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
            SELECT COUNT(*)
              INTO v_row_total
              FROM hcrs.bp_pnt_trans_dtl_t bptd
             WHERE bptd.prfl_id = v_prod.prfl_id
               AND bptd.ndc_lbl = v_prod.ndc_lbl
               AND bptd.ndc_prod = v_prod.ndc_prod
               AND bptd.calc_typ_cd = v_prod.calc_typ_cd;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
            WHILE  v_row_total > 0
               AND v_row_count = v_commit
            LOOP
               DELETE
                 FROM hcrs.bp_pnt_trans_dtl_t bptd
                WHERE bptd.prfl_id = v_prod.prfl_id
                  AND bptd.ndc_lbl = v_prod.ndc_lbl
                  AND bptd.ndc_prod = v_prod.ndc_prod
                  AND bptd.calc_typ_cd = v_prod.calc_typ_cd
                  AND ROWNUM <= v_commit;
               p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
            END LOOP;
            -----------------------------------------------------------------------
            -- BP price point table
            p_tbl( 'PRFL_PROD_BP_PNT_T', 'PPBP', 4, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
            SELECT COUNT(*)
              INTO v_row_total
              FROM hcrs.prfl_prod_bp_pnt_t ppbp
             WHERE ppbp.prfl_id = v_prod.prfl_id
               AND ppbp.ndc_lbl = v_prod.ndc_lbl
               AND ppbp.ndc_prod = v_prod.ndc_prod;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
            WHILE  v_row_total > 0
               AND v_row_count = v_commit
            LOOP
               DELETE
                 FROM hcrs.prfl_prod_bp_pnt_t ppbp
                WHERE ppbp.prfl_id = v_prod.prfl_id
                  AND ppbp.ndc_lbl = v_prod.ndc_lbl
                  AND ppbp.ndc_prod = v_prod.ndc_prod
                  AND ROWNUM <= v_commit;
               p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
            END LOOP;
         END IF;
         -----------------------------------------------------------------------
         -- Bundle Contract Price Group Transaction table
         p_tbl( 'PRFL_PROD_BNDL_CP_TRNS_T', 'PPBCT', 5, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
         SELECT COUNT(*)
           INTO v_row_total
           FROM hcrs.prfl_prod_bndl_cp_trns_t ppbct
          WHERE ppbct.prfl_id = v_prod.prfl_id
            AND ppbct.co_id = v_prod.co_id
            AND ppbct.ndc_lbl = v_prod.ndc_lbl
            AND ppbct.ndc_prod = v_prod.ndc_prod
            AND ppbct.ndc_pckg = NVL( v_prod.ndc_pckg, ppbct.ndc_pckg)
            AND ppbct.calc_typ_cd = v_prod.calc_typ_cd;
         p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
         WHILE  v_row_total > 0
            AND v_row_count = v_commit
         LOOP
            DELETE
              FROM hcrs.prfl_prod_bndl_cp_trns_t ppbct
             WHERE ppbct.prfl_id = v_prod.prfl_id
               AND ppbct.co_id = v_prod.co_id
               AND ppbct.ndc_lbl = v_prod.ndc_lbl
               AND ppbct.ndc_prod = v_prod.ndc_prod
               AND ppbct.ndc_pckg = NVL( v_prod.ndc_pckg, ppbct.ndc_pckg)
               AND ppbct.calc_typ_cd = v_prod.calc_typ_cd
               AND ROWNUM <= v_commit;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
         END LOOP;
         -----------------------------------------------------------------------
         -- Bundle Summary table
         p_tbl( 'PRFL_PROD_BNDL_SMRY_T', 'PPBS', 6, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
         SELECT COUNT(*)
           INTO v_row_total
           FROM hcrs.prfl_prod_bndl_smry_t ppbs
          WHERE ppbs.prfl_id = v_prod.prfl_id
            AND ppbs.co_id = v_prod.co_id
            AND ppbs.ndc_lbl = v_prod.ndc_lbl
            AND ppbs.ndc_prod = v_prod.ndc_prod
            AND ppbs.ndc_pckg = NVL( v_prod.ndc_pckg, ppbs.ndc_pckg)
            AND ppbs.calc_typ_cd = v_prod.calc_typ_cd;
         p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
         WHILE  v_row_total > 0
            AND v_row_count = v_commit
         LOOP
            DELETE
              FROM hcrs.prfl_prod_bndl_smry_t ppbs
             WHERE ppbs.prfl_id = v_prod.prfl_id
               AND ppbs.co_id = v_prod.co_id
               AND ppbs.ndc_lbl = v_prod.ndc_lbl
               AND ppbs.ndc_prod = v_prod.ndc_prod
               AND ppbs.ndc_pckg = NVL( v_prod.ndc_pckg, ppbs.ndc_pckg)
               AND ppbs.calc_typ_cd = v_prod.calc_typ_cd
               AND ROWNUM <= v_commit;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
         END LOOP;
         -----------------------------------------------------------------------
         -- Bundle Dates table
         p_tbl( 'PRFL_PROD_BNDL_DTS_T', 'PPBD', 7, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
         SELECT COUNT(*)
           INTO v_row_total
           FROM hcrs.prfl_prod_bndl_dts_t ppbd
          WHERE ppbd.prfl_id = v_prod.prfl_id
            AND ppbd.co_id = v_prod.co_id
            AND ppbd.ndc_lbl = v_prod.ndc_lbl
            AND ppbd.ndc_prod = v_prod.ndc_prod
            AND ppbd.ndc_pckg = NVL( v_prod.ndc_pckg, ppbd.ndc_pckg)
            AND ppbd.calc_typ_cd = v_prod.calc_typ_cd;
         p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
         WHILE  v_row_total > 0
            AND v_row_count = v_commit
         LOOP
            DELETE
              FROM hcrs.prfl_prod_bndl_dts_t ppbd
             WHERE ppbd.prfl_id = v_prod.prfl_id
               AND ppbd.co_id = v_prod.co_id
               AND ppbd.ndc_lbl = v_prod.ndc_lbl
               AND ppbd.ndc_prod = v_prod.ndc_prod
               AND ppbd.ndc_pckg = NVL( v_prod.ndc_pckg, ppbd.ndc_pckg)
               AND ppbd.calc_typ_cd = v_prod.calc_typ_cd
               AND ROWNUM <= v_commit;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
         END LOOP;
         -----------------------------------------------------------------------
         -- Calc Component Defintion table
         p_tbl( 'PRFL_PROD_CALC_COMP_DEF_T', 'PPCCD', 8, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
         SELECT COUNT(*)
           INTO v_row_total
           FROM hcrs.prfl_prod_calc_comp_def_t ppccd
          WHERE ppccd.prfl_id = v_prod.prfl_id
            AND ppccd.co_id = v_prod.co_id
            AND ppccd.ndc_lbl = v_prod.ndc_lbl
            AND ppccd.ndc_prod = v_prod.ndc_prod
            AND ppccd.ndc_pckg = NVL( v_prod.ndc_pckg, ppccd.ndc_pckg)
            AND ppccd.calc_typ_cd = v_prod.calc_typ_cd;
         p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
         WHILE  v_row_total > 0
            AND v_row_count = v_commit
         LOOP
            DELETE
              FROM hcrs.prfl_prod_calc_comp_def_t ppccd
             WHERE ppccd.prfl_id = v_prod.prfl_id
               AND ppccd.co_id = v_prod.co_id
               AND ppccd.ndc_lbl = v_prod.ndc_lbl
               AND ppccd.ndc_prod = v_prod.ndc_prod
               AND ppccd.ndc_pckg = NVL( v_prod.ndc_pckg, ppccd.ndc_pckg)
               AND ppccd.calc_typ_cd = v_prod.calc_typ_cd
               AND ROWNUM <= v_commit;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
         END LOOP;
         -----------------------------------------------------------------------
         -- Product Price table
         p_tbl( 'PRFL_PROD_PRICE_T', 'PPP', 9, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
         SELECT COUNT(*)
           INTO v_row_total
           FROM hcrs.prfl_prod_price_t ppp
          WHERE ppp.prfl_id = v_prod.prfl_id
            AND ppp.calc_typ_cd = v_prod.calc_typ_cd
            AND ppp.ndc_lbl = v_prod.ndc_lbl
            AND ppp.ndc_prod = v_prod.ndc_prod
            AND ppp.ndc_pckg = NVL( v_prod.ndc_pckg, ppp.ndc_pckg);
         p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
         WHILE  v_row_total > 0
            AND v_row_count = v_commit
         LOOP
            DELETE
              FROM hcrs.prfl_prod_price_t ppp
             WHERE ppp.prfl_id = v_prod.prfl_id
               AND ppp.calc_typ_cd = v_prod.calc_typ_cd
               AND ppp.ndc_lbl = v_prod.ndc_lbl
               AND ppp.ndc_prod = v_prod.ndc_prod
               AND ppp.ndc_pckg = NVL( v_prod.ndc_pckg, ppp.ndc_pckg)
               AND ROWNUM <= v_commit;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
         END LOOP;
         -----------------------------------------------------------------------
         -- NDC11 component table
         p_tbl( 'PRFL_PROD_CALC_T', 'PPC', 10, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
         SELECT COUNT(*)
           INTO v_row_total
           FROM hcrs.prfl_prod_calc_t ppc
          WHERE ppc.prfl_id = v_prod.prfl_id
            AND ppc.calc_typ_cd = v_prod.calc_typ_cd
            AND ppc.ndc_lbl = v_prod.ndc_lbl
            AND ppc.ndc_prod = v_prod.ndc_prod
            AND ppc.ndc_pckg = NVL( v_prod.ndc_pckg, ppc.ndc_pckg);
         p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
         WHILE  v_row_total > 0
            AND v_row_count = v_commit
         LOOP
            DELETE
              FROM hcrs.prfl_prod_calc_t ppc
             WHERE ppc.prfl_id = v_prod.prfl_id
               AND ppc.calc_typ_cd = v_prod.calc_typ_cd
               AND ppc.ndc_lbl = v_prod.ndc_lbl
               AND ppc.ndc_prod = v_prod.ndc_prod
               AND ppc.ndc_pckg = NVL( v_prod.ndc_pckg, ppc.ndc_pckg)
               AND ROWNUM <= v_commit;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
         END LOOP;
         IF v_prod.ndc_pckg IS NULL
         THEN
            -----------------------------------------------------------------------
            -- NDC9 component table
            p_tbl( 'PRFL_PROD_FMLY_CALC_T', 'PPFC', 11, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
            SELECT COUNT(*)
              INTO v_row_total
              FROM hcrs.prfl_prod_fmly_calc_t ppfc
             WHERE ppfc.prfl_id = v_prod.prfl_id
               AND ppfc.calc_typ_cd = v_prod.calc_typ_cd
               AND ppfc.ndc_lbl = v_prod.ndc_lbl
               AND ppfc.ndc_prod = v_prod.ndc_prod;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
            WHILE  v_row_total > 0
               AND v_row_count = v_commit
            LOOP
               DELETE
                 FROM hcrs.prfl_prod_fmly_calc_t ppfc
                WHERE ppfc.prfl_id = v_prod.prfl_id
                  AND ppfc.calc_typ_cd = v_prod.calc_typ_cd
                  AND ppfc.ndc_lbl = v_prod.ndc_lbl
                  AND ppfc.ndc_prod = v_prod.ndc_prod
                  AND ROWNUM <= v_commit;
               p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
            END LOOP;
         END IF;
         -----------------------------------------------------------------------
         -- Quarterly AMP Specific tables
         IF     v_prod.calc_typ_cd = pkg_constants.cs_calc_typ_amp_cd
            AND v_prod.period_id IS NOT NULL
         THEN
            -----------------------------------------------------------------------
            -- Profile Transmissions
            p_tbl( 'PRFL_TRNSMSN_T', 'PT', 12, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
            SELECT COUNT(*)
              INTO v_row_total
              FROM hcrs.prfl_trnsmsn_t pt
             WHERE pt.prfl_id = v_prod.prfl_id
               AND pt.ndc_lbl = v_prod.ndc_lbl
               AND pt.ndc_prod = v_prod.ndc_prod;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
            WHILE  v_row_total > 0
               AND v_row_count = v_commit
            LOOP
               DELETE
                 FROM hcrs.prfl_trnsmsn_t pt
                WHERE pt.prfl_id = v_prod.prfl_id
                  AND pt.ndc_lbl = v_prod.ndc_lbl
                  AND pt.ndc_prod = v_prod.ndc_prod
                  AND ROWNUM <= v_commit;
               p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
            END LOOP;
            -----------------------------------------------------------------------
            -- Product Transmissions
            p_tbl( 'PROD_TRNSMSN_T', 'PDT', 13, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
            SELECT COUNT(*)
              INTO v_row_total
              FROM hcrs.prod_trnsmsn_t pt
             WHERE pt.period_id = v_prod.period_id
               AND pt.ndc_lbl = v_prod.ndc_lbl
               AND pt.ndc_prod = v_prod.ndc_prod
               AND pt.trnsmsn_seq_no = v_prod.trnsmsn_seq_no;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
            WHILE  v_row_total > 0
               AND v_row_count = v_commit
            LOOP
               DELETE
                 FROM hcrs.prod_trnsmsn_t pt
                WHERE pt.period_id = v_prod.period_id
                  AND pt.ndc_lbl = v_prod.ndc_lbl
                  AND pt.ndc_prod = v_prod.ndc_prod
                  AND pt.trnsmsn_seq_no = v_prod.trnsmsn_seq_no
                  AND ROWNUM <= v_commit;
               p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
            END LOOP;
            -----------------------------------------------------------------------
            -- PUR Category Interim results
            p_tbl( 'PUR_CATG_INTRM_RESULTS_T', 'PCIR', 14, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
            SELECT COUNT(*)
              INTO v_row_total
              FROM hcrs.pur_catg_intrm_results_t pcir
             WHERE pcir.ndc_lbl = v_prod.ndc_lbl
               AND pcir.ndc_prod = v_prod.ndc_prod
               AND pcir.period_id = v_prod.period_id;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
            WHILE  v_row_total > 0
               AND v_row_count = v_commit
            LOOP
               DELETE
                 FROM hcrs.pur_catg_intrm_results_t pcir
                WHERE pcir.ndc_lbl = v_prod.ndc_lbl
                  AND pcir.ndc_prod = v_prod.ndc_prod
                  AND pcir.period_id = v_prod.period_id
                  AND ROWNUM <= v_commit;
               p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
            END LOOP;
            -----------------------------------------------------------------------
            -- PUR Interim results
            p_tbl( 'PUR_INTRM_RESULTS_T', 'PIR', 15, v_tbl_total, v_tbls_per_ndc, v_cntr, v_comp_typ_cd, v_user_msg, v_tbl_name, v_tbl_abbr, v_tbl_done, v_user_msg_tbl);
            SELECT COUNT(*)
              INTO v_row_total
              FROM hcrs.pur_intrm_results_t pir
             WHERE pir.ndc_lbl = v_prod.ndc_lbl
               AND pir.ndc_prod = v_prod.ndc_prod
               AND pir.period_id = v_prod.period_id;
            p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, NULL, v_row_total, v_commit, v_row_done, v_row_total, v_row_count);
            WHILE  v_row_total > 0
               AND v_row_count = v_commit
            LOOP
               DELETE
                 FROM hcrs.pur_intrm_results_t pir
                WHERE pir.ndc_lbl = v_prod.ndc_lbl
                  AND pir.ndc_prod = v_prod.ndc_prod
                  AND pir.period_id = v_prod.period_id
                  AND ROWNUM <= v_commit;
               p_row( v_action_name, v_user_msg, v_user_msg_tbl, v_tbl_abbr, v_row_done, v_row_total, SQL%ROWCOUNT, v_row_done, v_row_total, v_row_count);
            END LOOP;
         END IF;
      END LOOP;
      -- Force Commit
      p_commit_force();
      p_set_cntr( cs_calc_log_cntr_tbls, v_tbl_total, v_tbl_total);
      IF f_is_calc_running()
      THEN
         -- If the calc is running, set done message
         v_user_msg := v_user_msg || ' done';
      ELSE
         -- If the calc is not running, clear the user message
         v_user_msg := NULL;
      END IF;
      p_calc_log( v_action_name || 'End', v_user_msg, v_comp_typ_cd);
      pkg_utils.p_appinfo_stk_pop;
      -- Restore the module name
      gv_calc_log_module_name := v_module_name;
      -- Set calc delete runnning status to OFF
      gv_calc_delete_running := FALSE;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt || ' Table: ' || v_tbl_name);
   END p_calc_delete;


   PROCEDURE p_init_calc
      (io_param_rec IN OUT t_calc_param_rec)
   IS
      /*************************************************************************
      * Procedure Name : p_init_calc
      *   Input params : io_param_rec - Calculation parameters
      *  Output params : io_param_rec - Calculation parameters
      *   Date Created : 05/09/2006
      *         Author : Joe Kidd
      *    Description : Initialize environment for Calculations
      *
      *                  NOTE: This procedure should only write to temporary
      *                  tables, so that it can be used during testing/debugging
      *                  in production.  No changes should be made to permanent
      *                  objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  06/22/2009  Joe Kidd      RT 458 - CRQ 29045 - IS-000000000355
      *                            Retrieve new Max DPA profile variable
      *  04/01/2010  Joe Kidd      RT 372 - CRQ 43435 - IS-000000000018
      *                            Add Lookup Prasco Rebate/Fee flag
      *  04/26/2010  Joe Kidd      RT 2009-724 - CRQ 46973: Revise Bundling Methodology
      *                            Get minimum and maximum dates used by calc
      *  10/01/2010  Joe Kidd      CRQ-53357: October 2010 Govt Calculations Release
      *                            Update new profile calculation product tables
      *                            Use new views
      *                            Remove commented 8.1.7.4 queries
      *  12/01/2010  Joe Kidd      CRQ-931: December 2010 Govt Calculations Release
      *                            Validate Medicaid Units per package and
      *                            Commercial Units per package
      *  02/10/2011  Joe Kidd      CRQ-1471: Fix Company Product Association Calc Error
      *                            Add profile to f_get_prod_company_id call
      *  04/01/2011  Joe Kidd      CRQ-3921: Linking of CARS chargebacks
      *                            Added company id and debug mode parameters
      *                            Remove update of Profile Calc Product Tables
      *                            Remove matrix validation and other error checks
      *                            Use new profile variable procedure above
      *                            Remove all commits and permanent writes
      *                            Remove error logging and use error call stack
      *                            to allow init_calc use for debugging in prod
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Add Raw Cash Discount and Max DPA percentages
      *                            Add domestic/territory fields to component list
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Use new view to populate settings
      *                            Remove scalar parameters and make overloaded version
      *                            Enforce Wholesaler values for Non-Indirects
      *                            Remove debug settings no longer needed
      *                            Remove addition of bundled products to work table
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Change component value parameter
      *                            Populate profile work table
      *                            Update Component Definition Query to Remove
      *                            unneeded index columns, Get Nom/HHS units components
      *  04/11/2013  Joe Kidd      CRQ-45044: Adjust GP Smoothing
      *                            Disable bundling on second pass if no bundling
      *                            summaries are found
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Moved Calc Component Defintions to procedure
      *                            Collect bundling statistics
      *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
      *                            Revise bundling control logic
      *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
      *                            Clear all working (GTT) tables
      *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
      *                            Remove reference to prfl_bndl_price_grp_wrk_t
      *                            Populate global variables for marking NDC columns
      *                            Check for duplicate NDCs
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters, initialize all package globals
      *                            Revise working tables population
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Don't initialize calc log longops
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Correct Nominal/sub-PHS enable/disable
      *                            Remove pkg_constants global variables
      *                            Add normal exception handling (Calc Debug Mode)
      *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
      *                            Add SAP4H source system constants
      *                            Reorder t_calc_param_rec columns
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_init_calc';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Initialize environment for Calculations';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error during Initialization of environment for Calculations';
      v_upd_ppw             BOOLEAN := FALSE;
   BEGIN
      --------------------------------------------------------------------
      -- Clear all working tables
      --------------------------------------------------------------------
      p_clear_wrk_t( 0);
      --------------------------------------------------------------------
      -- Register Profile Calculation settings
      --------------------------------------------------------------------
      SELECT pw.co_id,
             pw.ndc_lbl mk_ndc_lbl,
             pw.ndc_prod mk_ndc_prod,
             pw.ndc_pckg mk_ndc_pckg,
             pw.calc_mthd_cd,
             pw.agency_typ_cd,
             pw.calc_ndc_pckg_lvl,
             pw.rpt_ndc_pckg_lvl,
             pw.prcss_typ_cd,
             pw.tim_per_cd,
             pw.start_dt,
             pw.end_dt,
             pw.ann_start_dt,
             pw.ann_end_dt,
             pw.ann_off_start_dt,
             pw.ann_off_end_dt,
             pw.min_start_dt,
             pw.max_end_dt,
             pw.min_paid_start_dt,
             pw.max_paid_end_dt,
             pw.min_earn_start_dt,
             pw.max_earn_end_dt,
             TO_DATE( NULL) min_bndl_start_dt,
             TO_DATE( NULL) max_bndl_end_dt,
             pw.prod_elig_start_dt,
             pw.prod_elig_end_dt,
             pw.end_dt_30_day,
             pw.end_dt_first_full,
             pw.snpsht_id,
             pw.snpsht_dt,
             pw.max_fss_comp_ind,
             pw.prelim_ind,
             pw.sales_offset_days,
             pw.nom_thrs_pct,
             pw.cash_dscnt_pct_raw,
             pw.cash_dscnt_pct,
             pw.prmpt_pay_adj_pct,
             pw.max_dpa_pct_raw,
             pw.max_dpa_pct,
             pw.dec_pcsn,
             pw.nxt_calc_typ_cd,
             pw.init_filing,
             pw.addl_filing,
             pw.set_baseline,
             pw.carry_fwd,
             pw.prod_trnsmsn_rsn_cd,
             pw.prfl_mths,
             pw.annl_strt_dt_mth_offset,
             pw.annl_end_dt_mth_offset,
             pw.prod_elig_strt_dt_mth_offset,
             pw.prod_elig_end_dt_mth_offset,
             pw.dra_baseln_restat_strt_dt,
             pw.dra_baseln_restat_end_dt,
             pw.use_dra_prod_bndl,
             pw.use_dra_time_bndl,
             pw.sap_adj_sg_elig_intgrty,
             pw.sap_adj_dt_mblty,
             pw.use_ppaca_ind,
             pw.lkup_sap_adj,
             pw.lkup_rbt_fee,
             pw.lkup_rel_crd,
             pw.lkup_xenon_adj,
             pw.lkup_prasco_rbtfee,
             pw.chk_nom,
             pw.chk_hhs,
             pw.chk_nom chk_nom_calc,
             pw.chk_hhs chk_hhs_calc,
             pw.uses_paid_dt,
             pw.uses_earn_dt,
             pw.pri_whls_mthd_cd,
             pw.ndc_count,
             pw.ndc_dupe_count,
             pw.unit_per_pckg,
             pw.comm_unit_per_pckg,
             pw.mrkt_entry_dt,
             pw.first_dt_sld,
             pw.term_dt,
             pw.liab_end_dt,
             pw.drug_catg_cd,
             pw.medicare_drug_catg_cd,
             TO_NUMBER( NULL) comp_def_cnt,
             TO_NUMBER( NULL) bndl_adj_cnt,
             TO_NUMBER( NULL) bad_accum_cnt,
             TO_NUMBER( NULL) deprecated_cnt,
             TO_NUMBER( NULL) bad_trans_cnt,
             TO_NUMBER( NULL) bad_nom_cnt,
             TO_NUMBER( NULL) bad_hhs_cnt
        INTO io_param_rec.co_id,
             io_param_rec.mk_ndc_lbl,
             io_param_rec.mk_ndc_prod,
             io_param_rec.mk_ndc_pckg,
             io_param_rec.calc_mthd_cd,
             io_param_rec.agency_typ_cd,
             io_param_rec.calc_ndc_pckg_lvl,
             io_param_rec.rpt_ndc_pckg_lvl,
             io_param_rec.prcss_typ_cd,
             io_param_rec.tim_per_cd,
             io_param_rec.start_dt,
             io_param_rec.end_dt,
             io_param_rec.ann_start_dt,
             io_param_rec.ann_end_dt,
             io_param_rec.ann_off_start_dt,
             io_param_rec.ann_off_end_dt,
             io_param_rec.min_start_dt,
             io_param_rec.max_end_dt,
             io_param_rec.min_paid_start_dt,
             io_param_rec.max_paid_end_dt,
             io_param_rec.min_earn_start_dt,
             io_param_rec.max_earn_end_dt,
             io_param_rec.min_bndl_start_dt,
             io_param_rec.max_bndl_end_dt,
             io_param_rec.prod_elig_start_dt,
             io_param_rec.prod_elig_end_dt,
             io_param_rec.end_dt_30_day,
             io_param_rec.end_dt_first_full,
             io_param_rec.snpsht_id,
             io_param_rec.snpsht_dt,
             io_param_rec.max_fss_comp_ind,
             io_param_rec.prelim_ind,
             io_param_rec.sales_offset_days,
             io_param_rec.nom_thrs_pct,
             io_param_rec.cash_dscnt_pct_raw,
             io_param_rec.cash_dscnt_pct,
             io_param_rec.prmpt_pay_adj_pct,
             io_param_rec.max_dpa_pct_raw,
             io_param_rec.max_dpa_pct,
             io_param_rec.dec_pcsn,
             io_param_rec.nxt_calc_typ_cd,
             io_param_rec.init_filing,
             io_param_rec.addl_filing,
             io_param_rec.set_baseline,
             io_param_rec.carry_fwd,
             io_param_rec.prod_trnsmsn_rsn_cd,
             io_param_rec.prfl_mths,
             io_param_rec.annl_strt_dt_mth_offset,
             io_param_rec.annl_end_dt_mth_offset,
             io_param_rec.prod_elig_strt_dt_mth_offset,
             io_param_rec.prod_elig_end_dt_mth_offset,
             io_param_rec.dra_baseln_restat_strt_dt,
             io_param_rec.dra_baseln_restat_end_dt,
             io_param_rec.use_dra_prod_bndl,
             io_param_rec.use_dra_time_bndl,
             io_param_rec.sap_adj_sg_elig_intgrty,
             io_param_rec.sap_adj_dt_mblty,
             io_param_rec.use_ppaca_ind,
             io_param_rec.lkup_sap_adj,
             io_param_rec.lkup_rbt_fee,
             io_param_rec.lkup_rel_crd,
             io_param_rec.lkup_xenon_adj,
             io_param_rec.lkup_prasco_rbtfee,
             io_param_rec.chk_nom,
             io_param_rec.chk_hhs,
             io_param_rec.chk_nom_calc,
             io_param_rec.chk_hhs_calc,
             io_param_rec.uses_paid_dt,
             io_param_rec.uses_earn_dt,
             io_param_rec.pri_whls_mthd_cd,
             io_param_rec.ndc_count,
             io_param_rec.ndc_dupe_count,
             io_param_rec.unit_per_pckg,
             io_param_rec.comm_unit_per_pckg,
             io_param_rec.mrkt_entry_dt,
             io_param_rec.first_dt_sld,
             io_param_rec.term_dt,
             io_param_rec.liab_end_dt,
             io_param_rec.drug_catg_cd,
             io_param_rec.medicare_drug_catg_cd,
             io_param_rec.comp_def_cnt,
             io_param_rec.bndl_adj_cnt,
             io_param_rec.bad_accum_cnt,
             io_param_rec.deprecated_cnt,
             io_param_rec.bad_trans_cnt,
             io_param_rec.bad_nom_cnt,
             io_param_rec.bad_hhs_cnt
        FROM hcrs.prfl_wrk_v pw
       WHERE pw.prfl_id = io_param_rec.prfl_id
         AND pw.ndc_lbl = io_param_rec.ndc_lbl
         AND pw.ndc_prod = io_param_rec.ndc_prod
         AND pw.ndc_pckg = NVL( io_param_rec.ndc_pckg, pw.ndc_pckg)
         AND pw.calc_typ_cd = io_param_rec.calc_typ_cd;
      --------------------------------------------------------------------
      -- Initialize package globals
      --------------------------------------------------------------------
      gv_comp_val_tbl.DELETE();
      gv_nd_tbl.DELETE();
      gv_pl102_tbl.DELETE();
      gv_mark_tbl.DELETE();
      gv_mark_id_tbl.DELETE();
      gv_mark_cust_id := NULL;
      gv_mark_cust_row_cnt_max := NULL;
      gv_mark_nom_tbl.DELETE();
      gv_mark_nom_id_tbl.DELETE();
      gv_bndl_use_dra_prod := TRUE;
      gv_bndl_use_dra_time := TRUE;
      gv_bndl_config := TRUE;
      gv_bndl_apply := TRUE;
      gv_bndl_trans := TRUE;
      gv_accum_trans := TRUE;
      gv_cust_id_tbl.DELETE();
      gv_mark_records := TRUE;
      gv_bndl_cust_id_tbl.DELETE();
      gv_bndl_cust_tbl.DELETE();
      gv_bndl_cust_cond_cnt := 0;
      gv_bndl_trans_ids.DELETE();
      gv_bndl_ind := pkg_constants.cs_flag_yes;
      gv_bndl_dts_cnt := 0;
      gv_bndl_smry_cnt := 0;
      gv_bndl_trans_cnt := 0;
      gv_bndl_adj_cnt := 0;
      --------------------------------------------------------------------
      -- Clear shutdown timer
      --------------------------------------------------------------------
      pkg_utils.p_timer_clear( cs_calc_shutdown_timer);
      --------------------------------------------------------------------
      -- Get products
      --------------------------------------------------------------------
      p_mk_prod_wrk_t
         (io_param_rec.prfl_id,
          io_param_rec.mk_ndc_lbl,
          io_param_rec.mk_ndc_prod,
          io_param_rec.mk_ndc_pckg,
          io_param_rec.calc_typ_cd);
      --------------------------------------------------------------------
      -- Set Debugging overrides for Nominal/HHS violation checking
      --------------------------------------------------------------------
      IF NOT f_is_calc_running()
      THEN
         -- Set nominal check override
         IF     gv_calc_debug_disable_nom_chk
            AND io_param_rec.chk_nom_calc = pkg_constants.cs_flag_yes
         THEN
            v_upd_ppw := TRUE;
            io_param_rec.chk_nom_calc := pkg_constants.cs_flag_no;
         END IF;
         -- Set HHS violation check override
         IF     gv_calc_debug_disable_hhs_chk
            AND io_param_rec.chk_hhs_calc = pkg_constants.cs_flag_yes
         THEN
            v_upd_ppw := TRUE;
            io_param_rec.chk_hhs_calc := pkg_constants.cs_flag_no;
         END IF;
         -- Set nominal/HHS violation check on product working table
         IF v_upd_ppw
         THEN
            UPDATE hcrs.prfl_prod_wrk_t ppw
               SET ppw.chk_nom_calc = io_param_rec.chk_nom_calc,
                   ppw.chk_hhs_calc = io_param_rec.chk_hhs_calc;
         END IF;
      END IF;
      --------------------------------------------------------------------
      -- Get component transaction definitions
      --------------------------------------------------------------------
      p_mk_calc_comp_def_wrk_t
         (io_param_rec.comp_def_cnt,
          io_param_rec.bndl_adj_cnt,
          io_param_rec.chk_nom,
          io_param_rec.chk_hhs,
          io_param_rec.bad_accum_cnt,
          io_param_rec.deprecated_cnt,
          io_param_rec.bad_trans_cnt,
          io_param_rec.bad_nom_cnt,
          io_param_rec.bad_hhs_cnt);
      --------------------------------------------------------------------
      -- Get Matrix, Split Percent, and Bundle settings
      --------------------------------------------------------------------
      p_mk_mtrx_splt_bndl_wrk_t( io_param_rec);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_init_calc;


   PROCEDURE p_init_calc_debug
      (i_prfl_id         IN hcrs.prfl_prod_wrk_t.prfl_id%TYPE,
       i_ndc_lbl         IN hcrs.prfl_prod_wrk_t.ndc_lbl%TYPE,
       i_ndc_prod        IN hcrs.prfl_prod_wrk_t.ndc_prod%TYPE,
       i_ndc_pckg        IN hcrs.prfl_prod_wrk_t.ndc_pckg%TYPE,
       i_calc_typ_cd     IN hcrs.prfl_prod_wrk_t.calc_typ_cd%TYPE,
       i_disable_nom_chk IN hcrs.prfl_prod_wrk_t.chk_nom%TYPE := pkg_constants.cs_flag_no,
       i_disable_hhs_chk IN hcrs.prfl_prod_wrk_t.chk_hhs%TYPE := pkg_constants.cs_flag_no)
   IS
      /*************************************************************************
      * Procedure Name : p_init_calc_debug
      *   Input params : i_prfl_id - Profile ID
      *                : i_ndc_lbl - Product Labeler Code
      *                : i_ndc_prod - Product Family Code
      *                : i_ndc_pckg - Product Package Code
      *                : i_calc_typ_cd - Calc Type Code of the calculation
      *                : i_disable_nom_chk - Control Nominal check setting
      *                : i_disable_hhs_chk - Control HHS violation setting
      *   Date Created : 03/02/2012
      *         Author : Joe Kidd
      *    Description : Initialize environment for debugging calculations.
      *
      *                  NOTE: This procedure should only write to temporary
      *                  tables, so that it can be used during testing/debugging
      *                  in production.  No changes should be made to permanent
      *                  objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Change component value parameter
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Set system globals
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Use global variable for debugging environment
      *                            Add parameters to disable nominal/sub-PHS
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Rename from p_init_calc
      *                            Correct Nominal/sub-PHS enable/disable
      *                            Remove pkg_constants global variables
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_init_calc_debug';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Initialize environment for debugging calculations';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error during Initialization of environment for debugging calculations';
      v_clear_param_rec     t_calc_param_rec;
   BEGIN
      -- Set Calc Debug mode ON
      gv_calc_debug_mode := TRUE;
      -- Clear and populate param record
      gv_param_rec := v_clear_param_rec;
      gv_param_rec.prfl_id := i_prfl_id;
      gv_param_rec.ndc_lbl := i_ndc_lbl;
      gv_param_rec.ndc_prod := i_ndc_prod;
      gv_param_rec.ndc_pckg := i_ndc_pckg;
      gv_param_rec.calc_typ_cd := i_calc_typ_cd;
      -- Set Calc Debug Nomimal/sub-PHS settings
      gv_calc_debug_disable_nom_chk := (NVL( i_disable_nom_chk, pkg_constants.cs_flag_no) = pkg_constants.cs_flag_yes);
      gv_calc_debug_disable_hhs_chk := (NVL( i_disable_hhs_chk, pkg_constants.cs_flag_no) = pkg_constants.cs_flag_yes);
      -- Initialize the calculation environment
      p_init_calc( gv_param_rec);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_init_calc_debug;


   PROCEDURE p_common_initialize
      (i_job_name    IN  VARCHAR2,
       i_calc_typ_cd IN  hcrs.calc_typ_t.calc_typ_cd%TYPE,
       i_ndc_lbl     IN  hcrs.prod_mstr_t.ndc_lbl%TYPE,
       i_ndc_prod    IN  hcrs.prod_mstr_t.ndc_prod%TYPE,
       i_ndc_pckg    IN  hcrs.prod_mstr_t.ndc_pckg%TYPE,
       o_param_rec   OUT t_calc_param_rec,
       i_queue_id    IN  VARCHAR2,
       i_clr_cmt_txt IN  VARCHAR2 := pkg_constants.cs_flag_yes)
   IS
      /*************************************************************************
      * Procedure Name : p_common_initialize
      *   Input params : i_job_name - Procedure name of the calculation
      *                : i_calc_typ_cd - Calc Type Code of the calculation
      *                : i_ndc_lbl - Product Labeler Code
      *                : i_ndc_prod - Product Family Code
      *                : i_ndc_pckg - Product Package Code
      *                : i_queue_id - Process Queue ID
      *                : i_clr_cmt_txt - Clear the comment text if 'Y'
      *  Output params : o_param_rec - Calculation parameters
      *   Date Created : 10/16/2000
      *         Author : Venkata Darabala
      *    Description : Common Initialization routines for Calculations
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  01/14/2003  Joe Kidd      PICC 1159: Erase Product comment
      *  02/12/2004  Joe Kidd      PICC 1167: Medicare ASP changes
      *  06/01/2004  Joe Kidd      PICC 1235: Validate the Matrix for the
      *                            running profile and calc
      *  11/01/2004  Joe Kidd      PICC 1327: Calc Cursor Tuning
      *                            Add calc start and delete event timings
      *  02/01/2005  Joe Kidd      PICC 1372: Get and register calc_mthd_cd
      *  02/01/2005  Joe Kidd      PICC 1374: Set Annual date ranges using table
      *                            Added more common init actions
      *  12/13/2006  Joe Kidd      PICC 1680:
      *                            Add parameters: io_comp_rec, io_comp_def_tbl, i_dec_pscn_var_cd
      *                            Remove io_cur_product_tbl parameter
      *                            Clear passed records
      *                            Add co_id registration
      *                            Set Annual date ranges using calc method
      *                            Set Annual Offset dates
      *                            Set Cash Discount Percent
      *                            Set Decimal Rounding Prescision
      *                            Set Nominal Threshold Percentage
      *                            Build component transaction definition table
      *  02/15/2007  Joe Kidd      PICC 1706:
      *                            Move Matrix validation before calc delete
      *                            Set Profile Months
      *                            Extend component transaction definition table
      *                            Build PL 102 price table if needed
      *  05/18/2007  Joe Kidd      PICC 1769:
      *                            Set session_cached_cursors to 50 to reduce library cache latches
      *                            Don't allow calc to run if no products found
      *                            Move Calc Delete to end after configuration
      *                            Change Invalid Matrix error code and message
      *                            Change Error Numbers and Messages for thrown errors
      *  10/01/2007  Joe Kidd      PICC 1808: Removed io_rollup_product_tbl parameter
      *                            Call altered p_get_product_rollup
      *                            Removed uneeded variables
      *                            Populate 30 Day and First Full Qtr End Dates
      *  11/30/2007  Joe Kidd      PICC 1810: Add unit component cd to component list
      *  11/30/2007  Joe Kidd      PICC 1847: Retrieve Prompt Pay Adjustment Pct
      *  12/05/2007  Joe Kidd      PICC 1763: Set Lookup cursor flags
      *                            Change exception IF..END IFs to only raise exception
      *                            Call p_mk_prod_wrk_t to build the product work table
      *                            Call p_mk_mtrx_wrk_t to build the matrix work table
      *                            Call p_mk_splt_pct_wrk_t to build the Split Percents list
      *  04/22/2008  Joe Kidd      PICC 1865: Set Bundle Use flags
      *                            Call f_mk_bndl_dts to build the bundle dates work table
      *                            Call f_sv_bndl_dts to save the bundle dates work table
      *  06/16/2008  Joe Kidd      PICC 1927: Commit after bundle work tables
      *  08/22/2008  Joe Kidd      PICC 1961: Simplify First Full Qtr End Date
      *                            Get Max Bundle Pricing Period End Date
      *                            Product Eligibility dates now on param record
      *                            Add bundled products to the list of products
      *  08/07/2008  Joe Kidd      PICC 1950: Retreive SAP Adj control fields
      *  12/01/2008  Joe Kidd      PICC 2009: GPCS Server Migration
      *                            Remove session commands
      *  05/06/2009  Joe Kidd      PICC 2051: Split out initialization to p_init_calc
      *                            Use param record Check HHS flag
      *  04/01/2011  Joe Kidd      CRQ-3921: Linking of CARS chargebacks
      *                            Add company id retrival
      *                            Add update of Profile Calc Product Tables
      *                            Add matrix validation and other error checks
      *                            Update init calc procedure call
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Enforce PPACA Retail/Non-Retail settings
      *                            Set a flag that a calc is running
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Remove decimal precision parameter
      *                            Call init calc, then check variables
      *                            Reduce use of pkg_constants globals
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Change component value parameter
      *                            Save initial component values
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Add user message for progress points and errors
      *                            Save Calc Component Definitions
      *  10/02/2015  Joe Kidd      CRQ-208647: Demand 6324: NonFamp/FCP Calc Modifications
      *                            Add parameter to control clearing of product comments
      *  08/31/2016  T. Zimmerman  CRQ-302277: Demand 3336 AMP Final Rule (October Release)
      *                            Added test of sys param to control Validate Matrix
      *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
      *                            Add commit before init calc to detect shutdown
      *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
      *                            Check for duplicate NDCs
      *                            Cleanup error handling
      *  08/01/2017  Joe Kidd      CRQ-376321: Demand 10535: NFAMP HHS Comp Summary
      *                            Create HHS Violation component
      *  09/01/2017  T. Zimmerman  CRQ-376430: Demand 10537: NFAMP 340B Prime Vendor
      *                            Load 340B Prime Vendor Contracts
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters, Fix NDC on PPACA and UOM errors,
      *                            Check Component Defs for errors, use package globals
      *                            Populate the component value table
      *                            Remove 340B Prime Vendor Contract load
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Use updated calc log procedures
      *                            Expand calc log entries
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Reorganize validations and logging
      *                            Remove pkg_constants global variables
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_common_initialize';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Common Initialization routines for Calculations';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error during Common Initialization routines for Calculations';
      v_clear_param_rec     t_calc_param_rec;
      v_err_msg             VARCHAR2( 4000);
      v_bad_cnt             NUMBER;
      v_ndc_err             VARCHAR2( 4000);
      v_calc_log_comp_cd    hcrs.prfl_prod_calc_log_t.comp_typ_cd%TYPE;
      v_calc_log_comp_cd2   hcrs.prfl_prod_calc_log_t.comp_typ_cd%TYPE;
      v_calc_log_user_msg   hcrs.prfl_prod_t.user_msg_txt%TYPE;
      v_calc_log_user_msg2  hcrs.prfl_prod_t.user_msg_txt%TYPE;
   BEGIN
      --==================================================================
      -- Calc is now running in the session
      --==================================================================
      gv_calc_running := TRUE;
      --------------------------------------------------------------------
      -- Register calc job
      --------------------------------------------------------------------
      p_reg_job_name( i_job_name);
      --------------------------------------------------------------------
      -- Check for the queue_id and if not found then raise error
      --------------------------------------------------------------------
      IF i_queue_id IS NULL
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Process Queue ID is missing.  ' || cs_cmt_txt);
      END IF;
      --------------------------------------------------------------------
      -- Clear param record
      --------------------------------------------------------------------
      gv_param_rec := v_clear_param_rec;
      --------------------------------------------------------------------
      -- Register globals, Get profile id from process queue
      --------------------------------------------------------------------
      pkg_constants.var_prfl_id := pkg_common_functions.f_get_profile_id( i_queue_id);
      pkg_constants.var_ndc_lbl := i_ndc_lbl;
      pkg_constants.var_ndc_prod := i_ndc_prod;
      pkg_constants.var_ndc_pckg := i_ndc_pckg;
      pkg_constants.var_calc_typ_cd := i_calc_typ_cd;
      --------------------------------------------------------------------
      -- Populate param record
      --------------------------------------------------------------------
      gv_param_rec.prfl_id := pkg_constants.var_prfl_id;
      gv_param_rec.ndc_lbl := pkg_constants.var_ndc_lbl;
      gv_param_rec.ndc_prod := pkg_constants.var_ndc_prod;
      gv_param_rec.ndc_pckg := pkg_constants.var_ndc_pckg;
      gv_param_rec.calc_typ_cd := pkg_constants.var_calc_typ_cd;
      --------------------------------------------------------------------
      -- Set the product status to Running and clear comment
      --------------------------------------------------------------------
      IF pkg_common_functions.f_update_product_status
            (gv_param_rec.prfl_id,
             gv_param_rec.ndc_lbl,
             gv_param_rec.ndc_prod,
             gv_param_rec.ndc_pckg,
             pkg_constants.cs_calc_run_status,
             NVL( i_clr_cmt_txt, pkg_constants.cs_flag_yes)) = 0
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, 'Unable to update product',
            'Unable to update product ' || cs_cmt_txt);
      END IF;
      --==================================================================
      -- Log start of calculation
      --==================================================================
      p_calc_log_new_calc();
      --==================================================================
      -- Log start of initialization
      --==================================================================
      v_calc_log_comp_cd := 'INIT';
      v_calc_log_user_msg := 'Initializing';
      p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' Start', v_calc_log_user_msg, v_calc_log_comp_cd);
      --==================================================================
      -- Log start of first initialization section
      --==================================================================
      v_calc_log_user_msg2 := v_calc_log_user_msg || '..';
      v_calc_log_comp_cd2 := v_calc_log_comp_cd || '_PART1';
      p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' Start', v_calc_log_user_msg2, v_calc_log_comp_cd2);
      --------------------------------------------------------------------
      -- Initialize the calculation
      --------------------------------------------------------------------
      p_commit_force();
      p_init_calc( gv_param_rec);
      p_commit_force();
      --------------------------------------------------------------------
      -- Log end of first initialization section
      --------------------------------------------------------------------
      p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' End', v_calc_log_user_msg2, v_calc_log_comp_cd2);
      --==================================================================
      -- Log start of second initialization section
      --==================================================================
      v_calc_log_comp_cd2 := v_calc_log_comp_cd || '_PART2';
      v_calc_log_user_msg2 := v_calc_log_user_msg || '....';
      p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' Start', v_calc_log_user_msg2, v_calc_log_comp_cd2);
      --------------------------------------------------------------------
      -- Validate the component definition accumulation settings
      --------------------------------------------------------------------
      IF gv_param_rec.bad_accum_cnt > 0
      THEN
         v_err_msg := 'Calculation Configuration Internal Error';
         p_update_user_msg( v_err_msg);
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg,
            'Bad tran_mark_accum value(s) ' || cs_cmt_txt ||
            ' count=' || gv_param_rec.bad_accum_cnt);
      END IF;
      --------------------------------------------------------------------
      -- Validate no deprecated component definitions columns used
      --------------------------------------------------------------------
      IF gv_param_rec.deprecated_cnt > 0
      THEN
         v_err_msg := 'Calculation Configuration Internal Error';
         p_update_user_msg( v_err_msg);
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg,
            'Unsupported alternate nom/hhs component used ' || cs_cmt_txt ||
            ' count=' || gv_param_rec.deprecated_cnt);
      END IF;
      --------------------------------------------------------------------
      -- Validate component definitions trans amount settings
      --------------------------------------------------------------------
      IF gv_param_rec.bad_trans_cnt > 0
      THEN
         v_err_msg := 'Calculation Configuration Internal Error';
         p_update_user_msg( v_err_msg);
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg,
            'Bad trans value(s) ' || cs_cmt_txt ||
            ' count=' || gv_param_rec.bad_trans_cnt);
      END IF;
      --------------------------------------------------------------------
      -- Validate component definitions nom check amount settings
      --------------------------------------------------------------------
      IF gv_param_rec.bad_nom_cnt > 0
      THEN
         v_err_msg := 'Calculation Configuration Internal Error';
         p_update_user_msg( v_err_msg);
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg,
            'Bad nominal check value(s) ' || cs_cmt_txt ||
            ' count=' || gv_param_rec.bad_nom_cnt);
      END IF;
      --------------------------------------------------------------------
      -- Validate component definitions sub-PHS check amount settings
      --------------------------------------------------------------------
      IF gv_param_rec.bad_hhs_cnt > 0
      THEN
         v_err_msg := 'Calculation Configuration Internal Error';
         p_update_user_msg( v_err_msg);
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg,
            'Bad hhs check value(s) ' || cs_cmt_txt ||
            ' count=' || gv_param_rec.bad_hhs_cnt);
      END IF;
      --------------------------------------------------------------------
      -- Check the processing period for the profile
      --------------------------------------------------------------------
      IF   (gv_param_rec.start_dt >= gv_param_rec.end_dt)
        OR (   gv_param_rec.start_dt IS NULL
            OR gv_param_rec.end_dt IS NULL)
      THEN
         v_err_msg := 'Check Profile Dates';
         p_update_user_msg( v_err_msg);
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg, v_err_msg || ' ' || cs_cmt_txt);
      END IF;
      --------------------------------------------------------------------
      -- Check for and add missing profile variables
      --------------------------------------------------------------------
      v_bad_cnt := pkg_common_functions.f_chk_prfl_var( gv_param_rec.prfl_id);
      IF v_bad_cnt > 0
      THEN
         v_err_msg := v_bad_cnt || ' missing profile variables added';
         p_update_user_msg( v_err_msg);
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg, v_err_msg || ' ' || cs_cmt_txt);
      ELSIF v_bad_cnt < 0
      THEN
         v_err_msg := ABS( v_bad_cnt) || ' profile variables are not set';
         p_update_user_msg( v_err_msg);
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg, v_err_msg || ' ' || cs_cmt_txt);
      END IF;
      --------------------------------------------------------------------
      -- Check if products exist
      --------------------------------------------------------------------
      IF gv_param_rec.ndc_count = 0
      THEN
         v_err_msg := 'No Product NDCs Found';
         p_update_user_msg( v_err_msg);
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg, v_err_msg || ' ' || cs_cmt_txt);
      END IF;
      --------------------------------------------------------------------
      -- Check if duplicate products exist
      --------------------------------------------------------------------
      IF gv_param_rec.ndc_dupe_count > 0
      THEN
         v_err_msg := 'Found ' || gv_param_rec.ndc_dupe_count || ' product NDCs duplicated';
         p_update_user_msg( v_err_msg);
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg, v_err_msg || ' ' || cs_cmt_txt);
      END IF;
      --------------------------------------------------------------------
      -- Check units per package values
      --------------------------------------------------------------------
      SELECT COUNT(*) cnt,
             pkg_utils.f_coll_to_str( CAST( COLLECT( ppw.trans_ndc_lbl || '-' || ppw.trans_ndc_prod || '-' || ppw.trans_ndc_pckg) AS hcrs.ntt_varchar2_typ), ', ') ndc_err
        INTO v_bad_cnt,
             v_ndc_err
        FROM hcrs.prfl_prod_wrk_t ppw
       WHERE ppw.unit_per_pckg IS NULL
          OR ppw.unit_per_pckg <= 0
          OR ppw.comm_unit_per_pckg IS NULL
          OR ppw.comm_unit_per_pckg <= 0;
      IF v_bad_cnt > 0
      THEN
         v_err_msg := 'Found ' || v_bad_cnt || ' NDC(s) with Bad Medicaid and/or Commercial Units/Pckg';
         p_update_user_msg( v_err_msg);
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg, v_err_msg || ' ' || v_ndc_err);
      END IF;
      --------------------------------------------------------------------
      -- Check PPACA Retail/Non-Retail values
      --------------------------------------------------------------------
      SELECT COUNT(*) cnt,
             pkg_utils.f_coll_to_str( CAST( COLLECT( ppw.trans_ndc_lbl || '-' || ppw.trans_ndc_prod || '-' || ppw.trans_ndc_pckg) AS hcrs.ntt_varchar2_typ), ', ') ndc_err
        INTO v_bad_cnt,
             v_ndc_err
        FROM hcrs.calc_mthd_prcss_typ_t cmpt,
             hcrs.prfl_prod_wrk_t ppw
       WHERE cmpt.agency_typ_cd = gv_param_rec.agency_typ_cd
         AND cmpt.prcss_typ_cd = gv_param_rec.prcss_typ_cd
         AND cmpt.calc_typ_cd = gv_param_rec.calc_typ_cd
         AND cmpt.calc_mthd_cd = gv_param_rec.calc_mthd_cd
         AND cmpt.use_ppaca_ind = pkg_constants.cs_flag_yes
         AND ppw.calc_typ_cd = gv_param_rec.calc_typ_cd
         AND ppw.pri_whls_mthd_cd NOT IN (pkg_constants.cs_prod_pcng_rtl_cd,
                                          pkg_constants.cs_prod_pcng_nonrtl_cd);
      IF v_bad_cnt > 0
      THEN
         v_err_msg := 'Found ' || v_bad_cnt || ' NDC(s) with missing Medicaid PPACA Retail/Non-Retail setting';
         p_update_user_msg( v_err_msg);
         p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg, v_err_msg || ' ' || v_ndc_err);
      END IF;
      --------------------------------------------------------------------
      -- Validate Matrix, support can disable for testing
      --------------------------------------------------------------------
      IF NVL( pkg_utils.f_get_sys_param( pkg_constants.cs_skip_validate_matrix), pkg_constants.cs_flag_no) != pkg_constants.cs_flag_yes
      THEN
         IF NOT pkg_common_functions.f_validate_matrix( gv_param_rec.prfl_id, gv_param_rec.calc_typ_cd)
         THEN
            v_err_msg := 'Invalid Matrix';
            p_update_user_msg( v_err_msg);
            p_raise_errors( cs_src_cd, cs_src_descr, -20001, v_err_msg, v_err_msg || ' ' || cs_cmt_txt);
         END IF;
      END IF;
      --------------------------------------------------------------------
      -- Update Profile Calc Product Tables
      --------------------------------------------------------------------
      p_update_prod_calc
         (gv_param_rec.prfl_id,
          gv_param_rec.calc_typ_cd,
          gv_param_rec.ndc_lbl,
          gv_param_rec.ndc_prod,
          gv_param_rec.ndc_pckg);
      p_commit_force();
      --------------------------------------------------------------------
      -- Log end of Second initialization section
      --------------------------------------------------------------------
      p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' End', v_calc_log_user_msg2, v_calc_log_comp_cd2);
      --==================================================================
      -- Delete existing calculation data
      --==================================================================
      v_calc_log_comp_cd2 := v_calc_log_comp_cd || '_DELETE';
      p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' Start', v_calc_log_user_msg || ', deleting calculation', v_calc_log_comp_cd2);
      p_calc_delete( v_calc_log_user_msg);
      p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' End', v_calc_log_user_msg || ', calculation deleted', v_calc_log_comp_cd2);
      --==================================================================
      -- Log Start of Third initialization section
      --==================================================================
      v_calc_log_comp_cd2 := v_calc_log_comp_cd || '_PART3';
      v_calc_log_user_msg2 := v_calc_log_user_msg || '......';
      p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' Start', v_calc_log_user_msg2, v_calc_log_comp_cd2);
      --------------------------------------------------------------------
      -- Save the calc component defintion work table
      --------------------------------------------------------------------
      IF gv_param_rec.comp_def_cnt > 0
      THEN
         p_commit( f_sv_calc_comp_def_wrk_t());
      END IF;
      --------------------------------------------------------------------
      -- Save the profile product bundle dates work table
      --------------------------------------------------------------------
      IF   gv_param_rec.use_dra_prod_bndl = pkg_constants.cs_flag_yes
        OR gv_param_rec.use_dra_time_bndl = pkg_constants.cs_flag_yes
      THEN
         gv_bndl_dts_cnt := f_sv_bndl_dts();
         p_commit( gv_bndl_dts_cnt);
      END IF;
      p_commit( f_sv_bndl_stats( gv_param_rec));
      --------------------------------------------------------------------
      -- Populate component value table for Sales/Discount components
      --------------------------------------------------------------------
      p_comp_val_clear;
      IF gv_param_rec.comp_def_cnt > 0
      THEN
         FOR v_rec IN
            (
               SELECT DISTINCT
                      t.comp_typ_cd,
                      t.units_comp_typ_cd,
                      t.comp_dllrs,
                      t.trans_dt_range
                 FROM hcrs.prfl_prod_calc_comp_def_wrk_t t
                WHERE t.comp_dllrs IN (pkg_constants.cs_comp_dllrs_sales,
                                       pkg_constants.cs_comp_dllrs_dsc)
                ORDER BY t.comp_typ_cd
            )
         LOOP
            -- (price point components don't accumulate a value)
            p_comp_val_init( v_rec.comp_typ_cd, TRUE, v_rec.comp_dllrs, v_rec.trans_dt_range);
            p_comp_val_init( v_rec.units_comp_typ_cd, TRUE, v_rec.comp_dllrs, v_rec.trans_dt_range);
         END LOOP;
      END IF;
      --------------------------------------------------------------------
      -- Build PL 102 price list for HHS Violation checking
      --------------------------------------------------------------------
      IF gv_param_rec.chk_hhs_calc = pkg_constants.cs_flag_yes
      THEN
         p_create_prod_price_tbl
            (gv_param_rec,
             pkg_constants.cs_price_typ_cd_pl102,
             gv_pl102_tbl);
         -- Create HHS Violation component
         p_comp_val_init( pkg_constants.cs_hhs_pl102_violation, TRUE);
      ELSE
         gv_pl102_tbl.DELETE();
      END IF;
      -----------------------------------------------------------------------
      -- Save component values
      -----------------------------------------------------------------------
      p_comp_val_save;
      --------------------------------------------------------------------
      -- Log end of third initialization section
      --------------------------------------------------------------------
      p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' End', v_calc_log_user_msg2, v_calc_log_comp_cd2);
      --==================================================================
      -- Initilization Complete
      --==================================================================
      -- Return param record and force commit
      o_param_rec := gv_param_rec;
      p_commit_force();
      --==================================================================
      -- Log end of initialization
      --==================================================================
      p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' End', 'Initialization complete', v_calc_log_comp_cd);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_common_initialize;


   PROCEDURE p_insert_trnsmsn_price
      (i_prfl_id     IN hcrs.prfl_prod_calc_t.prfl_id%TYPE,
       i_ndc_lbl     IN hcrs.prfl_prod_calc_t.ndc_lbl%TYPE,
       i_ndc_prod    IN hcrs.prfl_prod_calc_t.ndc_prod%TYPE,
       i_calc_typ_cd IN hcrs.prfl_prod_calc_t.calc_typ_cd%TYPE,
       i_calc_amt    IN hcrs.prfl_prod_calc_t.calc_amt%TYPE)
   IS
      /*************************************************************************
      * Procedure Name : p_insert_trnsmsn_price
      *   Input params : i_prfl_id - Profile ID
      *                : i_ndc_lbl - NDC Labeler
      *                : i_ndc_prod - NDC Product
      *                : i_calc_typ_cd - Calculation code
      *                : i_calc_amt - Component Amount
      *  Output params : None
      *   Date Created : 05/31/2001
      *         Author : Tom Zimmerman
      *    Description : Insert transmission prices for a product
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  12/13/2006  Joe Kidd      PICC 1680: Apply naming conventions
      *  04/17/2007  Joe Kidd      PICC 1743: Moved from pkg_fe_pricing
      *                            Update first, insert if update fails
      *                            No preliminary profiles
      *                            Only calculations that use prod_trnsmsn_t
      *  02/12/2008  Joe Kidd      PICC 1807: Set DRA Baseline Flag
      *                            DRA Baseline does not require PUR calc
      *************************************************************************/
      cs_src_cd     CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_insert_trnsmsn_price';
      cs_src_descr  CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Inserts transmission prices for a product';
      cs_cmt_txt    CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while inserting transmission prices for a product';
      v_trnsmsn_seq_no       hcrs.prod_trnsmsn_t.trnsmsn_seq_no%TYPE;
      v_dra_baseline_flg     hcrs.prod_trnsmsn_t.dra_baseline_flg%TYPE;
      v_prod_trnsmsn_stat_cd hcrs.prod_trnsmsn_t.prod_trnsmsn_stat_cd%TYPE;
   BEGIN
      -- Update prod_trnsmsn_t for non-preliminary profiles
      -- and calculations that use prod_trnsmsn_t
      FOR v_rec IN
         (
            SELECT cpt.prod_trnsmsn_rsn_cd,
                   pr.period_id
              FROM hcrs.prfl_t p,
                   hcrs.calc_prcss_typ_t cpt,
                   hcrs.period_t pr
             WHERE p.agency_typ_cd = cpt.agency_typ_cd
               AND p.prcss_typ_cd = cpt.prcss_typ_cd
               AND TO_CHAR( p.begn_dt, 'Q') = pr.qtr
               AND TO_CHAR( p.begn_dt, 'YYYY') = pr.yr
               AND p.prfl_id = i_prfl_id
               AND p.prelim_ind = pkg_constants.cs_flag_no
               AND cpt.calc_typ_cd = i_calc_typ_cd
               AND cpt.prod_trnsmsn_rsn_cd IS NOT NULL -- uses prod_trnsmsn_t
         )
      LOOP
         -- Is this a DRA baseline restatement?
         v_dra_baseline_flg := pkg_common_functions.f_get_dra_baseln_restat_flg
                                 (i_prfl_id,
                                  i_ndc_lbl,
                                  i_ndc_prod);
         -- Set prod transmission status
         IF v_dra_baseline_flg = pkg_constants.cs_flag_yes
         THEN
            -- DRA baseline restatement does not require URA calculation
            v_prod_trnsmsn_stat_cd := pkg_constants.cs_prod_trnsmsn_calc_cd;
         ELSE
            -- all others require URA calculation
            v_prod_trnsmsn_stat_cd := pkg_constants.cs_prod_trnsmsn_load_cd;
         END IF;
         -- Update existing transmission record
         UPDATE hcrs.prod_trnsmsn_t pdt
            SET pdt.amp_amt = DECODE( i_calc_typ_cd,
                                      pkg_constants.cs_calc_typ_amp_cd, i_calc_amt,
                                      pdt.amp_amt),
                pdt.bp_amt = DECODE( i_calc_typ_cd,
                                     pkg_constants.cs_calc_typ_bp_cd, i_calc_amt,
                                     pdt.bp_amt),
                pdt.amp_apprvl_flg = DECODE( i_calc_typ_cd,
                                             pkg_constants.cs_calc_typ_amp_cd, pkg_constants.cs_flag_no,
                                             pdt.amp_apprvl_flg),
                pdt.bp_apprvl_flg = DECODE( i_calc_typ_cd,
                                            pkg_constants.cs_calc_typ_bp_cd, pkg_constants.cs_flag_no,
                                            pdt.bp_apprvl_flg),
                pdt.prod_trnsmsn_stat_cd = v_prod_trnsmsn_stat_cd,
                pdt.dra_baseline_flg = v_dra_baseline_flg
          WHERE pdt.ndc_lbl = i_ndc_lbl
            AND pdt.ndc_prod = i_ndc_prod
            AND EXISTS
                (
                  SELECT NULL
                    FROM hcrs.prfl_trnsmsn_t pft
                   WHERE pft.prfl_id = i_prfl_id
                     AND pft.ndc_lbl = pdt.ndc_lbl
                     AND pft.ndc_prod = pdt.ndc_prod
                     AND pft.trnsmsn_seq_no = pdt.trnsmsn_seq_no
                     AND pft.period_id = pdt.period_id
                );
         IF SQL%ROWCOUNT = 0
         THEN
            -- Insert record
            -- Get the next transmission sequence number from product transmission
            SELECT NVL( MAX( pt.trnsmsn_seq_no), 0) + 1
              INTO v_trnsmsn_seq_no
              FROM hcrs.prod_trnsmsn_t pt
             WHERE pt.period_id = v_rec.period_id
               AND pt.ndc_lbl = i_ndc_lbl
               AND pt.ndc_prod = i_ndc_prod;
            -- Save the next transmission sequence number from product transmission
            INSERT INTO hcrs.prfl_trnsmsn_t
               (prfl_id,
                ndc_lbl,
                ndc_prod,
                period_id,
                trnsmsn_seq_no)
               VALUES
               (i_prfl_id,
                i_ndc_lbl,
                i_ndc_prod,
                v_rec.period_id,
                v_trnsmsn_seq_no);
            -- Save the transmission to product transmission
            INSERT INTO hcrs.prod_trnsmsn_t
               (ndc_lbl,
                ndc_prod,
                period_id,
                trnsmsn_seq_no,
                prod_trnsmsn_stat_cd,
                prod_trnsmsn_rsn_cd,
                amp_amt,
                bp_amt,
                actv_flg,
                amp_apprvl_flg,
                bp_apprvl_flg,
                dra_baseline_flg)
               VALUES
               (i_ndc_lbl,
                i_ndc_prod,
                v_rec.period_id,
                v_trnsmsn_seq_no,
                v_prod_trnsmsn_stat_cd,
                v_rec.prod_trnsmsn_rsn_cd,
                DECODE( i_calc_typ_cd,
                        pkg_constants.cs_calc_typ_amp_cd, i_calc_amt,
                        0),
                DECODE( i_calc_typ_cd,
                        pkg_constants.cs_calc_typ_bp_cd, i_calc_amt,
                        0),
                pkg_constants.cs_flag_no,
                pkg_constants.cs_flag_no,
                pkg_constants.cs_flag_no,
                v_dra_baseline_flg);
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_insert_trnsmsn_price;


   PROCEDURE p_ins_bp_rows
      (i_prfl_id       IN hcrs.prfl_t.prfl_id%TYPE,
       i_ndc_lbl       IN hcrs.prod_mstr_t.ndc_lbl%TYPE,
       i_ndc_prod      IN hcrs.prod_mstr_t.ndc_prod%TYPE,
       i_carry_fwd_ind IN hcrs.prfl_prod_calc_t.carry_fwd_ind%TYPE := NULL)
   IS
      /*************************************************************************
      * Procedure Name : f_ins_bp_rows
      *   Input params : i_prfl_id - profile
      *                : i_ndc_lbl - product labeler
      *                : i_ndc_prod - product
      *                : i_carry_fwd_ind - carry forward indicator
      *  Output params : None
      *   Date Created : 12/04/2000
      *         Author : Tom Zimmerman
      *    Description : Inserts the selected bp into prfl_prod_calc
      *                  and prfl_famly_prod_calc from prfl_prod_bp_pnt.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  04/19/2002  T. Zimmerman  Removed count variable -- not needed
      *  04/17/2007  Joe Kidd      PICC 1743: Moved from pkg_fe_pricing
      *                            No global variables
      *                            Use p_update_interim_table
      *  05/18/2007  Joe Kidd      PICC 1769: Call p_insert_trnsmsn_price above
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_ins_bp_rows';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Insert BP results';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while inserting BP results';
   BEGIN
      -- get price
      FOR v_rec IN
         (
            SELECT ppbp.price_amt calc_amt
              FROM hcrs.prfl_prod_bp_pnt_t ppbp
             WHERE ppbp.prfl_id = i_prfl_id
               AND ppbp.ndc_lbl = i_ndc_lbl
               AND ppbp.ndc_prod = i_ndc_prod
               AND ppbp.bp_ind = pkg_constants.cs_flag_yes
         )
      LOOP
         p_update_interim_table
            (i_prfl_id,
             i_ndc_lbl,
             i_ndc_prod,
             NULL,
             pkg_constants.cs_calc_typ_bp_cd,
             pkg_constants.cs_calc_typ_bp_cd,
             v_rec.calc_amt,
             NULL,
             i_carry_fwd_ind);
         -- update the hcrs.prod_trnsmsn_t table
         p_insert_trnsmsn_price
            (i_prfl_id,
             i_ndc_lbl,
             i_ndc_prod,
             pkg_constants.cs_calc_typ_bp_cd,
             v_rec.calc_amt);
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_ins_bp_rows;


   PROCEDURE p_mark_record_flush
      (i_cust_id IN hcrs.prfl_cust_cls_of_trd_t.cust_id%TYPE,
       i_force   IN BOOLEAN := FALSE)
   IS
      /*************************************************************************
      * Procedure Name : p_mark_record_flush
      *   Input params : i_cust_id - customer id, save rows if different from
      *                :             last customer id
      *                : i_force - Forces write and commit if TRUE
      *  Output params : None
      *   Date Created : 03/01/2005
      *         Author : Joe Kidd
      *    Description : Flushs Marked records into the marking tables:
      *                  bp_pnt_trans_dtl_t
      *                  prfl_prod_comp_trans_t
      *                  prfl_prod_fmly_comp_trans_t
      *
      *                  Records are flushed when:
      *                  - Forced by parameter
      *                  - Bulk row count limit reached
      *                  - Customer changes
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  06/12/2006  Joe Kidd      PICC 1557: Add new fields for Transaction Amounts
      *  12/05/2007  Joe Kidd      PICC 1763: Move v_null_mark_rec from body to here
      *                            Add split percentage type, split percentage
      *                            sequence number
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Commit at end counting all changes
      *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
      *                            Remove from package specification
      *                            Add customer id parameter
      *                            Remove all references to bp_pnt_contr_dtl_t
      *                            Adjust for new bp_pnt_trans_dtl_t layout
      *                            Only save rows when marking records
      *                            Flush rows when customer changes
      *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
      *                            When customer changes, only flush the customer
      *                            marekd transaction ID table.  The full marked
      *                            transaction table flush on bulk row count
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Flush write cache for nominal
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_mark_record_flush';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Flushes marked records marking tables';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while flushing marked records in marking tables';
      v_cnt                 NUMBER := 0;
      v_save                BOOLEAN := FALSE;
   BEGIN
      IF    NVL( i_force, FALSE)
         OR (    i_cust_id IS NOT NULL
             AND (   gv_mark_cust_id IS NULL
                  OR i_cust_id <> gv_mark_cust_id
                 )
            )
      THEN
         -- Save customer ID, and delete lookup caches when
         -- Forced,
         -- or Customer is passed
         --    and No previous customer
         --        or Passed customer is different from previous customer
         gv_mark_cust_id := i_cust_id;
         gv_mark_id_tbl.DELETE();
         gv_mark_nom_id_tbl.DELETE();
      END IF;
      IF    NVL( i_force, FALSE)
         OR (gv_mark_tbl.COUNT() + gv_mark_nom_tbl.COUNT()) >= pkg_constants.cs_bulk_row_count
      THEN
         -- flush the rows when forced or bulk row limit reached
         v_save := TRUE;
      END IF;
      IF v_save
      THEN
         -- Flush the rows
         IF gv_mark_records
         THEN
            -- Writing to the marking tables enabled
            IF gv_mark_tbl.COUNT() > 0
            THEN
               -- the main audit log has something to save
               IF gv_mark_tbl( gv_mark_tbl.FIRST()).calc_typ_cd IN (pkg_constants.cs_calc_typ_nfamp_cd,
                                                                    pkg_constants.cs_calc_typ_asp_cd)
               THEN
                  -- NDC11 table (Nonfamp/ASP)
                  -- Use bulk bind to write records
                  FORALL v_i IN INDICES OF gv_mark_tbl
                     INSERT INTO hcrs.prfl_prod_comp_trans_t
                        (prfl_id,
                         ndc_lbl,
                         ndc_prod,
                         ndc_pckg,
                         calc_typ_cd,
                         comp_typ_cd,
                         trans_id,
                         co_id,
                         cls_of_trd_cd,
                         trans_adj_cd,
                         root_trans_id,
                         parent_trans_id,
                         trans_dt,
                         dllr_amt,
                         pkg_qty,
                         chrgbck_amt,
                         term_disc_pct,
                         nom_dllr_amt,
                         nom_pkg_qty,
                         splt_pct_typ,
                         splt_pct_seq_no,
                         bndl_cd,
                         bndl_seq_no)
                        VALUES
                        (gv_mark_tbl( v_i).prfl_id,
                         gv_mark_tbl( v_i).ndc_lbl,
                         gv_mark_tbl( v_i).ndc_prod,
                         gv_mark_tbl( v_i).ndc_pckg,
                         gv_mark_tbl( v_i).calc_typ_cd,
                         gv_mark_tbl( v_i).comp_typ_cd,
                         gv_mark_tbl( v_i).trans_id,
                         gv_mark_tbl( v_i).co_id,
                         gv_mark_tbl( v_i).cls_of_trd_cd,
                         gv_mark_tbl( v_i).trans_adj_cd,
                         gv_mark_tbl( v_i).root_trans_id,
                         gv_mark_tbl( v_i).parent_trans_id,
                         gv_mark_tbl( v_i).trans_dt,
                         gv_mark_tbl( v_i).dllr_amt,
                         gv_mark_tbl( v_i).pkg_qty,
                         gv_mark_tbl( v_i).chrgbck_amt,
                         gv_mark_tbl( v_i).term_disc_pct,
                         gv_mark_tbl( v_i).nom_dllr_amt,
                         gv_mark_tbl( v_i).nom_pkg_qty,
                         gv_mark_tbl( v_i).splt_pct_typ,
                         gv_mark_tbl( v_i).splt_pct_seq_no,
                         gv_mark_tbl( v_i).bndl_cd,
                         gv_mark_tbl( v_i).bndl_seq_no);
                  v_cnt := v_cnt + SQL%ROWCOUNT;
               ELSIF gv_mark_tbl( gv_mark_tbl.FIRST()).calc_typ_cd = pkg_constants.cs_calc_typ_amp_cd
               THEN
                  -- AMP
                  -- Use bulk bind to write records
                  FORALL v_i IN INDICES OF gv_mark_tbl
                     INSERT INTO hcrs.prfl_prod_fmly_comp_trans_t
                        (prfl_id,
                         ndc_lbl,
                         ndc_prod,
                         calc_typ_cd,
                         comp_typ_cd,
                         trans_id,
                         co_id,
                         cls_of_trd_cd,
                         trans_adj_cd,
                         root_trans_id,
                         parent_trans_id,
                         trans_dt,
                         dllr_amt,
                         pkg_qty,
                         chrgbck_amt,
                         term_disc_pct,
                         nom_dllr_amt,
                         nom_pkg_qty,
                         splt_pct_typ,
                         splt_pct_seq_no,
                         bndl_cd,
                         bndl_seq_no)
                        VALUES
                        (gv_mark_tbl( v_i).prfl_id,
                         gv_mark_tbl( v_i).ndc_lbl,
                         gv_mark_tbl( v_i).ndc_prod,
                         gv_mark_tbl( v_i).calc_typ_cd,
                         gv_mark_tbl( v_i).comp_typ_cd,
                         gv_mark_tbl( v_i).trans_id,
                         gv_mark_tbl( v_i).co_id,
                         gv_mark_tbl( v_i).cls_of_trd_cd,
                         gv_mark_tbl( v_i).trans_adj_cd,
                         gv_mark_tbl( v_i).root_trans_id,
                         gv_mark_tbl( v_i).parent_trans_id,
                         gv_mark_tbl( v_i).trans_dt,
                         gv_mark_tbl( v_i).dllr_amt,
                         gv_mark_tbl( v_i).pkg_qty,
                         gv_mark_tbl( v_i).chrgbck_amt,
                         gv_mark_tbl( v_i).term_disc_pct,
                         gv_mark_tbl( v_i).nom_dllr_amt,
                         gv_mark_tbl( v_i).nom_pkg_qty,
                         gv_mark_tbl( v_i).splt_pct_typ,
                         gv_mark_tbl( v_i).splt_pct_seq_no,
                         gv_mark_tbl( v_i).bndl_cd,
                         gv_mark_tbl( v_i).bndl_seq_no);
                  v_cnt := v_cnt + SQL%ROWCOUNT;
               ELSIF gv_mark_tbl( gv_mark_tbl.FIRST()).calc_typ_cd = pkg_constants.cs_calc_typ_bp_cd
                 AND gv_mark_tbl( gv_mark_tbl.FIRST()).comp_typ_cd = pkg_constants.cs_bp_realised_mthd_typ_cd
               THEN
                  -- BP Realized Method
                  -- Use bulk bind to write records
                  FORALL v_i IN INDICES OF gv_mark_tbl
                     INSERT INTO hcrs.bp_pnt_trans_dtl_t
                        (prfl_id,
                         ndc_lbl,
                         ndc_prod,
                         calc_typ_cd,
                         comp_typ_cd,
                         trans_id,
                         price_pnt_seq_no,
                         co_id,
                         cls_of_trd_cd,
                         trans_adj_cd,
                         root_trans_id,
                         parent_trans_id,
                         trans_dt,
                         dllr_amt,
                         pkg_qty,
                         chrgbck_amt,
                         term_disc_pct,
                         nom_dllr_amt,
                         nom_pkg_qty,
                         splt_pct_typ,
                         splt_pct_seq_no,
                         bndl_cd,
                         bndl_seq_no)
                        VALUES
                        (gv_mark_tbl( v_i).prfl_id,
                         gv_mark_tbl( v_i).ndc_lbl,
                         gv_mark_tbl( v_i).ndc_prod,
                         gv_mark_tbl( v_i).calc_typ_cd,
                         gv_mark_tbl( v_i).comp_typ_cd,
                         gv_mark_tbl( v_i).trans_id,
                         gv_mark_tbl( v_i).price_pnt_seq_no,
                         gv_mark_tbl( v_i).co_id,
                         gv_mark_tbl( v_i).cls_of_trd_cd,
                         gv_mark_tbl( v_i).trans_adj_cd,
                         gv_mark_tbl( v_i).root_trans_id,
                         gv_mark_tbl( v_i).parent_trans_id,
                         gv_mark_tbl( v_i).trans_dt,
                         gv_mark_tbl( v_i).dllr_amt,
                         gv_mark_tbl( v_i).pkg_qty,
                         gv_mark_tbl( v_i).chrgbck_amt,
                         gv_mark_tbl( v_i).term_disc_pct,
                         gv_mark_tbl( v_i).nom_dllr_amt,
                         gv_mark_tbl( v_i).nom_pkg_qty,
                         gv_mark_tbl( v_i).splt_pct_typ,
                         gv_mark_tbl( v_i).splt_pct_seq_no,
                         gv_mark_tbl( v_i).bndl_cd,
                         gv_mark_tbl( v_i).bndl_seq_no);
                  v_cnt := v_cnt + SQL%ROWCOUNT;
               END IF;
            END IF;
            IF gv_mark_nom_tbl.COUNT() > 0
            THEN
               -- the nominal log has something to save
               -- Use bulk bind to write records
               FORALL v_i IN INDICES OF gv_mark_nom_tbl
                  INSERT INTO hcrs.prfl_sls_excl_t
                     (prfl_id,
                      trans_id,
                      co_id,
                      cls_of_trd_cd,
                      over_ind,
                      apprvd_ind,
                      apprvd_dt,
                      apprvd_by,
                      adj_cnt,
                      adj_pkg_qty,
                      adj_total_amt,
                      nmnl_thres_amt,
                      trans_adj_cd,
                      root_trans_id,
                      parent_trans_id,
                      trans_dt,
                      dllr_amt,
                      pkg_qty,
                      chrgbck_amt,
                      term_disc_pct,
                      nom_dllr_amt,
                      nom_pkg_qty,
                      splt_pct_typ,
                      splt_pct_seq_no,
                      bndl_cd,
                      bndl_seq_no,
                      cmt_txt)
                     SELECT gv_mark_nom_tbl( v_i).prfl_id,
                            gv_mark_nom_tbl( v_i).trans_id,
                            gv_mark_nom_tbl( v_i).co_id,
                            gv_mark_nom_tbl( v_i).cls_of_trd_cd,
                            gv_mark_nom_tbl( v_i).over_ind,
                            gv_mark_nom_tbl( v_i).apprvd_ind,
                            gv_mark_nom_tbl( v_i).apprvd_dt,
                            gv_mark_nom_tbl( v_i).apprvd_by,
                            gv_mark_nom_tbl( v_i).adj_cnt,
                            gv_mark_nom_tbl( v_i).adj_pkg_qty,
                            gv_mark_nom_tbl( v_i).adj_total_amt,
                            gv_mark_nom_tbl( v_i).nmnl_thres_amt,
                            gv_mark_nom_tbl( v_i).trans_adj_cd,
                            gv_mark_nom_tbl( v_i).root_trans_id,
                            gv_mark_nom_tbl( v_i).parent_trans_id,
                            gv_mark_nom_tbl( v_i).trans_dt,
                            gv_mark_nom_tbl( v_i).dllr_amt,
                            gv_mark_nom_tbl( v_i).pkg_qty,
                            gv_mark_nom_tbl( v_i).chrgbck_amt,
                            gv_mark_nom_tbl( v_i).term_disc_pct,
                            gv_mark_nom_tbl( v_i).nom_dllr_amt,
                            gv_mark_nom_tbl( v_i).nom_pkg_qty,
                            gv_mark_nom_tbl( v_i).splt_pct_typ,
                            gv_mark_nom_tbl( v_i).splt_pct_seq_no,
                            gv_mark_nom_tbl( v_i).bndl_cd,
                            gv_mark_nom_tbl( v_i).bndl_seq_no,
                            gv_mark_nom_tbl( v_i).cmt_txt
                       FROM dual
                      WHERE NOT EXISTS
                            ( -- Skip rows already in the table from previous runs
                              SELECT NULL
                                FROM hcrs.prfl_sls_excl_t pse
                               WHERE pse.prfl_id = gv_mark_nom_tbl( v_i).prfl_id
                                 AND pse.trans_id = gv_mark_nom_tbl( v_i).trans_id
                            );
               v_cnt := v_cnt + SQL%ROWCOUNT;
            END IF;
         END IF;
         -- Delete marking record caches
         gv_mark_tbl.DELETE();
         gv_mark_nom_tbl.DELETE();
      END IF;
      p_commit( v_cnt);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_mark_record_flush;


   PROCEDURE p_get_trans_vals
      (i_comp_dllrs    IN  VARCHAR2,
       i_dllrs_stg     IN  VARCHAR2,
       i_pkgs_stg      IN  VARCHAR2,
       i_ppd_stg       IN  VARCHAR2,
       i_bndl_stg      IN  VARCHAR2,
       i_trans_adj_cd  IN  VARCHAR2,
       i_dllrs_grs     IN  NUMBER,
       i_dllrs_wac     IN  NUMBER,
       i_dllrs_net     IN  NUMBER,
       i_dllrs_dsc     IN  NUMBER,
       i_dllrs_ppd     IN  NUMBER,
       i_pkgs          IN  NUMBER,
       i_units         IN  NUMBER,
       i_nvl           IN  NUMBER,
       o_dllrs         OUT NUMBER,
       o_units         OUT NUMBER,
       i_rebate_no_dsc IN  BOOLEAN := FALSE)
   IS
      /*************************************************************************
      * Procedure Name : p_get_trans_vals
      *   Input params : i_comp_dllrs - Component Dollar type (SLS/DSC/PRC)
      *                : i_dllrs_stg - Dollar Setting to use (NONE/GRS/NET/DSC/PPD)
      *                : i_pkgs_stg - Packages Setting to use (NONE/PKGS/UNITS)
      *                : i_ppd_stg - Prompt Pay Dollars Setting to use (NONE/DSC)
      *                : i_bndl_stg - Bundling setting to use (DEF/NONE/ADJ)
      *                : i_trans_adj_cd - Identifies Bundling adjustments
      *                : i_dllrs_grs - Gross dollar value
      *                : i_dllrs_wac - WAC value of packages dollar value
      *                : i_dllrs_net - Net dollar value
      *                : i_dllrs_dsc - Discount dollar value
      *                : i_dllrs_ppd - Prompt Pay Dollars
      *                : i_pkgs - Packages as packages
      *                : i_units - Packages as Units
      *                : i_nvl - if null use this value
      *                : i_rebate_no_dsc - Rebate with no discount get special treatment
      *  Output params : o_dllrs - Dollar value
      *                : o_units - Unit value
      *   Date Created : 06/22/2009
      *         Author : Joe Kidd
      *    Description : Determines the values for a transaction: dollars
      *                  and units.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Add WAC value of packages
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Seperated Component and Transaction dollars constants
      *                            Carry and process prompt pay dollars seperately
      *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
      *                            Add new bundling control columns
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters, handle rebates w/o discount
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_get_trans_vals';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Determines the values for a transaction';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while determining the values for a transaction';
      v_dllrs               NUMBER;
      v_units               NUMBER;
   BEGIN
      --------------------------
      -- Calculate Dollars value
      --------------------------
      IF    i_bndl_stg = pkg_constants.cs_trans_bndl_none
        AND i_trans_adj_cd = pkg_constants.cs_trans_adj_bndl_adj
      THEN
         -- No bundle adjustments amounts
         v_dllrs := 0;
      ELSIF i_dllrs_stg = pkg_constants.cs_trans_dllrs_bndl
        AND i_trans_adj_cd = pkg_constants.cs_trans_adj_bndl_adj
      THEN
         -- Only Bundle adjustment dollar value
         v_dllrs := i_dllrs_dsc;
      ELSIF i_dllrs_stg = pkg_constants.cs_trans_dllrs_bndl
        AND i_trans_adj_cd <> pkg_constants.cs_trans_adj_bndl_adj
      THEN
         -- Not a Bundle adjustment dollar value
         v_dllrs := 0;
      ELSIF i_dllrs_stg = pkg_constants.cs_trans_dllrs_grs
        AND NOT i_rebate_no_dsc
      THEN
         -- Gross Dollar value
         v_dllrs := i_dllrs_grs;
      ELSIF i_dllrs_stg = pkg_constants.cs_trans_dllrs_wac
        AND NOT i_rebate_no_dsc
      THEN
         -- WAC Dollar value
         v_dllrs := i_dllrs_wac;
      ELSIF i_dllrs_stg = pkg_constants.cs_trans_dllrs_net
        AND i_ppd_stg = pkg_constants.cs_trans_ppd_none
        AND NOT i_rebate_no_dsc
      THEN
         -- Net Dollar value (prompt pay is not a discount)
         v_dllrs := i_dllrs_net;
      ELSIF i_dllrs_stg = pkg_constants.cs_trans_dllrs_net
        AND i_ppd_stg = pkg_constants.cs_trans_ppd_dsc
        AND NOT i_rebate_no_dsc
      THEN
         -- Net Dollar value (prompt pay is a discount)
         v_dllrs := i_dllrs_net - NVL( i_dllrs_ppd, 0);
      ELSIF i_dllrs_stg = pkg_constants.cs_trans_dllrs_dsc
        AND i_ppd_stg = pkg_constants.cs_trans_ppd_none
      THEN
         -- Discount Dollar value (prompt pay is not a discount)
         v_dllrs := i_dllrs_dsc;
      ELSIF i_dllrs_stg = pkg_constants.cs_trans_dllrs_dsc
        AND i_ppd_stg = pkg_constants.cs_trans_ppd_dsc
      THEN
         -- Discount Dollar value (prompt pay is a discount)
         v_dllrs := i_dllrs_dsc + NVL( i_dllrs_ppd, 0);
      ELSIF i_dllrs_stg = pkg_constants.cs_trans_dllrs_ppd
      THEN
         -- Prompt Pay Dollar value (does not matter if it is a discount)
         v_dllrs := i_dllrs_ppd;
      END IF;
      IF    i_comp_dllrs = pkg_constants.cs_comp_dllrs_sales
        AND i_dllrs_stg IN (pkg_constants.cs_trans_dllrs_dsc,
                            pkg_constants.cs_trans_dllrs_ppd)
      THEN
         -- Discount is applied to a sales component
         -- Discount must be subtracted, so reverse the sign
         v_dllrs := v_dllrs * -1;
      END IF;
      o_dllrs := NVL( v_dllrs, i_nvl);
      ---------------------------
      -- Calculate Packages value
      ---------------------------
      IF    i_pkgs_stg = pkg_constants.cs_trans_pckgs_pkgs
        AND NOT i_rebate_no_dsc
      THEN
         -- Use packages
         v_units := i_pkgs;
      ELSIF i_pkgs_stg = pkg_constants.cs_trans_pckgs_units
        AND NOT i_rebate_no_dsc
      THEN
         -- Use units
         v_units := i_units;
      END IF;
      o_units := NVL( v_units, i_nvl);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_get_trans_vals;


   PROCEDURE p_get_trans_vals
      (io_trans_group_rec IN OUT pkg_common_cursors.t_calc_trans_rec,
       i_trns_amt_cd      IN     VARCHAR2,
       i_nvl              IN     NUMBER,
       o_dllrs            OUT    NUMBER,
       o_units            OUT    NUMBER,
       o_contr            OUT    BOOLEAN,
       o_fss_contr        OUT    BOOLEAN,
       o_phs_contr        OUT    BOOLEAN,
       o_phs_pvp_contr    OUT    BOOLEAN,
       o_chk_nom          OUT    BOOLEAN,
       o_chk_hhs          OUT    BOOLEAN,
       i_rebate_no_dsc    IN     BOOLEAN)
   IS
      /*************************************************************************
      * Procedure Name : p_get_trans_vals
      *   Input params : io_trans_group_rec - current lines of a transaction group (orig + adj)
      *                : i_trns_amt_cd - Trans Amount field code
      *                : i_nvl - if null use this value
      *                : i_rebate_no_dsc - Rebate with no discount get special treatment
      *  Output params : io_trans_group_rec - current lines of a transaction group (orig + adj)
      *                : o_dllrs - Dollar value
      *                : o_units - Unit value
      *                : o_contr - True if contracted
      *                : o_fss_contr - True if FSS contract
      *                : o_phs_contr - True if PHS contract
      *                : o_phs_pvp_contr - True if PHS Prime Vendor contract
      *                : o_chk_nom - True if Nominal should be checked
      *                : o_chk_hhs - True if HHS Violation should be checked
      *   Date Created : 06/22/2009
      *         Author : Joe Kidd
      *    Description : Determines the values for a transaction: dollars,
      *                  units, price point, and comment.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Add WAC value of packages
      *                            Use Raw Cash Discount and Max DPA percentages
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Variables moved to param record
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Update for calc cursor changes
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Seperated Component and Transaction dollars constants
      *                            Carry and process prompt pay dollars seperately
      *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
      *                            Add new bundling control columns
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters, perform component checks
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Apply Cash Discount % to Wholesaler Source
      *                            Program Chargebacks
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_get_trans_vals';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Determines the values for a transaction';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while determining the values for a transaction';
      v_prc_pnt             NUMBER;
      v_disc_adj_amt        NUMBER := 0;
      v_cmt_txt             hcrs.prfl_prod_bp_pnt_t.cmt_txt%TYPE;
   BEGIN
      IF     io_trans_group_rec.source_sys_cde = pkg_constants.cs_system_x360
         AND (   i_trns_amt_cd IN (cs_trns_amt_nom_chk,
                                   cs_trns_amt_hhs_chk)
              OR io_trans_group_rec.comp_dllrs = pkg_constants.cs_comp_dllrs_price
             )
      THEN
         -----------------------------------------------------------------------
         -- X360 uses WAC less Cash Discount % less Max DPA %
         -----------------------------------------------------------------------
         -- X360 price point for the Nominal Check, HHS check, and any
         -- Component when the main component is a price point is the lowest
         -- WAC in effect less prompt pay percentage less dpa percentage
         -- Get the lowest WAC in effect during the claim period
         v_prc_pnt := pkg_common_functions.f_get_price( io_trans_group_rec.ndc_lbl,
                                                        io_trans_group_rec.ndc_prod,
                                                        io_trans_group_rec.ndc_pckg,
                                                        io_trans_group_rec.earn_bgn_dt,
                                                        io_trans_group_rec.earn_end_dt,
                                                        pkg_constants.cs_price_typ_cd_wac,
                                                        pkg_constants.cs_price_per_min,
                                                        -- if not package level use unit wac
                                                        gv_param_rec.calc_ndc_pckg_lvl = pkg_constants.cs_flag_no);
         -- Build comment
         -- Estimated price point for wholesalers, which is equal to WAC less prompt pay (2%) less DPA (1%)
         v_cmt_txt := 'Estimated Price to Wholesaler based on ';
         IF gv_param_rec.calc_ndc_pckg_lvl = pkg_constants.cs_flag_no
         THEN
            v_cmt_txt := v_cmt_txt || 'unit ';
         END IF;
         v_cmt_txt := v_cmt_txt || 'WAC ($' ||
                      pkg_common_functions.f_get_amt_padded_c( v_prc_pnt,
                                                               gv_param_rec.prfl_id,
                                                               NULL,
                                                               gv_param_rec.dec_pcsn) ||
                      ') less Prompt Pay (' ||
                      pkg_common_functions.f_get_amt_padded( gv_param_rec.cash_dscnt_pct_raw * 100,
                                                             gv_param_rec.prfl_id,
                                                             NULL,
                                                             gv_param_rec.dec_pcsn) ||
                      '%) and Max DPA (' ||
                      pkg_common_functions.f_get_amt_padded( gv_param_rec.max_dpa_pct_raw * 100,
                                                             gv_param_rec.prfl_id,
                                                             NULL,
                                                             gv_param_rec.dec_pcsn) ||
                      '%)';
         -- Reduce by Prompt Pay Amount and DPA percent
         v_prc_pnt := v_prc_pnt * (1 - gv_param_rec.cash_dscnt_pct_raw - gv_param_rec.max_dpa_pct_raw);
         -- Save to record
         o_dllrs := v_prc_pnt;
         o_units := 1;
         IF i_trns_amt_cd = cs_trns_amt_comp
         THEN
            io_trans_group_rec.mk_dllr_amt := v_prc_pnt;
            io_trans_group_rec.mk_pkg_qty := 1;
         ELSIF i_trns_amt_cd = cs_trns_amt_nom_chk
         THEN
            io_trans_group_rec.nom_dllr_amt := v_prc_pnt;
            io_trans_group_rec.nom_pkg_qty := 1;
         ELSIF i_trns_amt_cd = cs_trns_amt_hhs_chk
         THEN
            io_trans_group_rec.hhs_dllr_amt := v_prc_pnt;
            io_trans_group_rec.hhs_pkg_qty := 1;
         END IF;
         io_trans_group_rec.prc_pnt := v_prc_pnt;
         io_trans_group_rec.cmt_txt := v_cmt_txt;
      ELSE
         IF     io_trans_group_rec.source_sys_cde = pkg_constants.cs_system_cars
            AND io_trans_group_rec.trans_cls_cd = pkg_constants.cs_trans_cls_idr
            AND io_trans_group_rec.cust_cot_grp_cd IN
                (pkg_constants.cs_cot_wholesaler,
                 pkg_constants.cs_cot_whlslr_no_cpp)
            AND io_trans_group_rec.whls_cot_grp_cd IN
                (pkg_constants.cs_cot_wholesaler,
                 pkg_constants.cs_cot_whlslr_no_cpp)
            AND (   i_trns_amt_cd IN (cs_trns_amt_nom_chk,
                                      cs_trns_amt_hhs_chk)
                 OR io_trans_group_rec.comp_dllrs = pkg_constants.cs_comp_dllrs_price
                )
         THEN
            -----------------------------------------------------------------------
            -- Wholesaler Source Program Chargebacks from CARS/RMUS
            -----------------------------------------------------------------------
            -- Wholesaler source program chargebacks must add the cash discount
            -- (prompt pay) percentage of the gross dollars to the discount amount
            -- when calculating a price point to stack that discount from the direct
            -- sale with the chargeback.
            --
            -- Transaction must be:
            --  - CARS/RMUS Chargeback
            --  - Customer COT must be "Wholesaler (Default CPP)" or "Wholesaler (No CPP)"
            --  - Wholesaler COT must be "Wholesaler (Default CPP)" or "Wholesaler (No CPP)"
            --
            v_disc_adj_amt := io_trans_group_rec.dllrs_grs * gv_param_rec.cash_dscnt_pct_raw;
            io_trans_group_rec.dllrs_net := io_trans_group_rec.dllrs_net - v_disc_adj_amt;
            io_trans_group_rec.dllrs_dsc := io_trans_group_rec.dllrs_dsc + v_disc_adj_amt;
            io_trans_group_rec.cmt_txt :=
               'Wholesaler Source Program chargeback discount includes Prompt Pay (' ||
               pkg_common_functions.f_get_amt_padded
                  (gv_param_rec.cash_dscnt_pct_raw * 100,
                   gv_param_rec.prfl_id,
                   NULL,
                   gv_param_rec.dec_pcsn) ||
               '% off WAC)';
         END IF;
         IF i_trns_amt_cd = cs_trns_amt_comp
         THEN
            -----------------------------------------------------------------------
            -- Transaction values
            -----------------------------------------------------------------------
            p_get_trans_vals( io_trans_group_rec.comp_dllrs,
                              io_trans_group_rec.tran_dllrs,
                              io_trans_group_rec.tran_pckgs,
                              io_trans_group_rec.tran_ppd,
                              io_trans_group_rec.tran_bndl,
                              io_trans_group_rec.trans_adj_cd,
                              io_trans_group_rec.dllrs_grs,
                              io_trans_group_rec.dllrs_wac,
                              io_trans_group_rec.dllrs_net,
                              io_trans_group_rec.dllrs_dsc,
                              io_trans_group_rec.dllrs_ppd,
                              io_trans_group_rec.pkgs,
                              io_trans_group_rec.units,
                              i_nvl,
                              io_trans_group_rec.mk_dllr_amt,
                              io_trans_group_rec.mk_pkg_qty,
                              i_rebate_no_dsc);
            o_dllrs := io_trans_group_rec.mk_dllr_amt;
            o_units := io_trans_group_rec.mk_pkg_qty;
         ELSIF i_trns_amt_cd = cs_trns_amt_nom_chk
         THEN
            -----------------------------------------------------------------------
            -- Nominal check values
            -----------------------------------------------------------------------
            p_get_trans_vals( io_trans_group_rec.comp_dllrs,
                              io_trans_group_rec.nom_chk_dllrs,
                              io_trans_group_rec.nom_chk_pckgs,
                              io_trans_group_rec.nom_chk_ppd,
                              io_trans_group_rec.nom_chk_bndl,
                              io_trans_group_rec.trans_adj_cd,
                              io_trans_group_rec.dllrs_grs,
                              io_trans_group_rec.dllrs_wac,
                              io_trans_group_rec.dllrs_net,
                              io_trans_group_rec.dllrs_dsc,
                              io_trans_group_rec.dllrs_ppd,
                              io_trans_group_rec.pkgs,
                              io_trans_group_rec.units,
                              i_nvl,
                              io_trans_group_rec.nom_dllr_amt,
                              io_trans_group_rec.nom_pkg_qty);
            IF i_rebate_no_dsc
            THEN
               io_trans_group_rec.nom_dllr_amt := 0;
               io_trans_group_rec.nom_pkg_qty := 0;
            END IF;
            o_dllrs := io_trans_group_rec.nom_dllr_amt;
            o_units := io_trans_group_rec.nom_pkg_qty;
         ELSIF i_trns_amt_cd = cs_trns_amt_hhs_chk
         THEN
            -----------------------------------------------------------------------
            -- HHS check values
            -----------------------------------------------------------------------
            p_get_trans_vals( io_trans_group_rec.comp_dllrs,
                              io_trans_group_rec.hhs_chk_dllrs,
                              io_trans_group_rec.hhs_chk_pckgs,
                              io_trans_group_rec.hhs_chk_ppd,
                              io_trans_group_rec.hhs_chk_bndl,
                              io_trans_group_rec.trans_adj_cd,
                              io_trans_group_rec.dllrs_grs,
                              io_trans_group_rec.dllrs_wac,
                              io_trans_group_rec.dllrs_net,
                              io_trans_group_rec.dllrs_dsc,
                              io_trans_group_rec.dllrs_ppd,
                              io_trans_group_rec.pkgs,
                              io_trans_group_rec.units,
                              i_nvl,
                              io_trans_group_rec.hhs_dllr_amt,
                              io_trans_group_rec.hhs_pkg_qty);
            IF i_rebate_no_dsc
            THEN
               io_trans_group_rec.nom_dllr_amt := 0;
               io_trans_group_rec.nom_pkg_qty := 0;
            END IF;
            o_dllrs := io_trans_group_rec.hhs_dllr_amt;
            o_units := io_trans_group_rec.hhs_pkg_qty;
         END IF;
      END IF;
      -----------------------------------------------------------------------
      -- Contract check
      -----------------------------------------------------------------------
      -- Contract ID is populated
      o_contr := (io_trans_group_rec.chk_contr = pkg_constants.cs_flag_yes);
      -----------------------------------------------------------------------
      -- PHS Prime Vendor Contract check
      -----------------------------------------------------------------------
      -- Contract is a PHS prime vendor contact
      o_phs_pvp_contr := (io_trans_group_rec.chk_phs_pvp_contr = pkg_constants.cs_flag_yes);
      -----------------------------------------------------------------------
      -- PHS Contract check
      -----------------------------------------------------------------------
      -- PHS contracts
      o_phs_contr := (io_trans_group_rec.chk_phs_contr = pkg_constants.cs_flag_yes);
      -----------------------------------------------------------------------
      -- FSS Contract check
      -----------------------------------------------------------------------
      -- Genzyme FSS/PHS contracts
      o_fss_contr := (io_trans_group_rec.chk_fss_contr = pkg_constants.cs_flag_yes);
      -----------------------------------------------------------------------
      -- Nominal Check
      -----------------------------------------------------------------------
      -- Test for nominal only if nominal dollars and units have been selected
      o_chk_nom := (io_trans_group_rec.chk_nom = pkg_constants.cs_flag_yes);
      -----------------------------------------------------------------------
      -- HHS Violation Check
      -----------------------------------------------------------------------
      o_chk_hhs := (io_trans_group_rec.chk_hhs = pkg_constants.cs_flag_yes);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_get_trans_vals;


   PROCEDURE p_get_trans_vals
      (io_trans_group_tbl IN OUT pkg_common_cursors.t_calc_trans_tbl,
       i_trns_amt_cd      IN     VARCHAR2,
       i_nvl              IN     NUMBER,
       o_dllrs            OUT    NUMBER,
       o_units            OUT    NUMBER,
       o_prc_pnt          OUT    NUMBER,
       io_contr           IN OUT BOOLEAN,
       io_phs_pvp_contr   IN OUT BOOLEAN,
       io_phs_contr       IN OUT BOOLEAN,
       io_fss_contr       IN OUT BOOLEAN,
       io_zero_dllrs      IN OUT BOOLEAN,
       io_chk_nom         IN OUT BOOLEAN,
       io_chk_hhs         IN OUT BOOLEAN,
       i_rebate_no_dsc    IN     BOOLEAN)
   IS
      /*************************************************************************
      * Procedure Name : p_get_trans_vals
      *   Input params : io_trans_group_tbl - all lines of a transaction group (orig + adj)
      *                : i_trns_amt_cd - Trans Amount field code
      *                : i_nvl - if null use this value
      *                : io_contr - Input value ignored when calculated
      *                : io_phs_pvp_contr - Input value ignored when calculated
      *                : io_phs_contr - Input value ignored when calculated
      *                : io_fss_contr - Input value ignored when calculated
      *                : io_zero_dllrs - Input value ignored when calculated
      *                : io_chk_nom - If TRUE, determine if Nominal should be checked
      *                : io_chk_hhs - If TRUE, determine if HHS Violations should be checked
      *                : i_rebate_no_dsc - Rebate with no discount get special treatment
      *  Output params : io_trans_group_tbl - all lines of a transaction group (orig + adj)
      *                : o_dllrs - Dollar value
      *                : o_units - Unit value
      *                : o_prc_pnt - Price Point value
      *                : io_contr - True if contracted
      *                : io_phs_pvp_contr - True if PHS Prime Vendor contract
      *                : io_phs_contr - True if PHS contract
      *                : io_fss_contr - True if FSS contract
      *                : io_zero_dllrs - True if group is zero dollars
      *                : io_chk_nom - True if Nominal should be checked
      *                : io_chk_hhs - True if HHS Violation should be checked
      *   Date Created : 06/22/2009
      *         Author : Joe Kidd
      *    Description : Determines the values for all lines of a transaction:
      *                  dollars, units, price point, and comments
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Add WAC value of packages
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Carry and process prompt pay dollars seperately
      *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
      *                            Add new bundling control columns
      *                            Remove main transaction and total variables
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters, perform component checks
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_get_trans_vals';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Determines the values for a transaction';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while determining the values for a transaction';
      v_i                   BINARY_INTEGER;
      v_dllrs               NUMBER := 0;
      v_dllrs_o             NUMBER := 0;
      v_units               NUMBER := 0;
      v_units_o             NUMBER := 0;
      v_prc_pnt             NUMBER;
      v_cmt_txt             hcrs.prfl_prod_bp_pnt_t.cmt_txt%TYPE;
      v_contr               BOOLEAN := TRUE;
      v_contr_o             BOOLEAN;
      v_phs_pvp_contr       BOOLEAN := TRUE;
      v_phs_pvp_contr_o     BOOLEAN;
      v_phs_contr           BOOLEAN := TRUE;
      v_phs_contr_o         BOOLEAN;
      v_fss_contr           BOOLEAN := TRUE;
      v_fss_contr_o         BOOLEAN;
      v_chk_nom             BOOLEAN := io_chk_nom;
      v_chk_nom_o           BOOLEAN;
      v_chk_hhs             BOOLEAN := io_chk_hhs;
      v_chk_hhs_o           BOOLEAN;
   BEGIN
      -- Process all transactions
      v_i := io_trans_group_tbl.FIRST();
      WHILE v_i IS NOT NULL
      LOOP
         p_get_trans_vals( io_trans_group_tbl( v_i),
                           i_trns_amt_cd,
                           i_nvl,
                           v_dllrs_o,
                           v_units_o,
                           v_contr_o,
                           v_fss_contr_o,
                           v_phs_contr_o,
                           v_phs_pvp_contr_o,
                           v_chk_nom_o,
                           v_chk_hhs_o,
                           i_rebate_no_dsc);
         v_dllrs := v_dllrs + v_dllrs_o;
         v_units := v_units + v_units_o;
         v_prc_pnt := NVL( v_prc_pnt, io_trans_group_tbl( v_i).prc_pnt);
         v_cmt_txt := NVL( v_cmt_txt, io_trans_group_tbl( v_i).cmt_txt);
         v_contr := (v_contr AND v_contr_o);
         v_fss_contr := (v_fss_contr AND v_fss_contr_o);
         v_phs_contr := (v_phs_contr AND v_phs_contr_o);
         v_phs_pvp_contr := (v_phs_pvp_contr AND v_phs_pvp_contr_o);
         v_chk_nom := (v_chk_nom AND v_chk_nom_o);
         v_chk_hhs := (v_chk_hhs AND v_chk_hhs_o);
         -- get next row
         v_i := io_trans_group_tbl.NEXT( v_i);
      END LOOP;
      -- Assign values to output variables that always change
      o_dllrs := v_dllrs;
      o_units := v_units;
      o_prc_pnt := v_prc_pnt;
      IF i_trns_amt_cd = cs_trns_amt_comp
      THEN
         -- Assign values to output variables only set for component level
         -- including zero dollar check
         io_contr := v_contr;
         io_phs_pvp_contr := v_phs_pvp_contr;
         io_phs_contr := v_phs_contr;
         io_fss_contr := v_fss_contr;
         io_zero_dllrs := (NVL( v_dllrs, 0) = 0);
         io_chk_nom := v_chk_nom;
         io_chk_hhs := v_chk_hhs;
         -- Distribute price point and/or comment over all rows
         IF    v_prc_pnt IS NOT NULL
            OR v_cmt_txt IS NOT NULL
         THEN
            v_i := io_trans_group_tbl.FIRST();
            WHILE v_i IS NOT NULL
            LOOP
               io_trans_group_tbl( v_i).prc_pnt := v_prc_pnt;
               io_trans_group_tbl( v_i).cmt_txt := v_cmt_txt;
               -- get next row
               v_i := io_trans_group_tbl.NEXT( v_i);
            END LOOP;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_get_trans_vals;


   FUNCTION f_ins_price_pnt
      (i_prfl_id        IN hcrs.prfl_t.prfl_id%TYPE,
       i_ndc_lbl        IN hcrs.prod_mstr_t.ndc_lbl%TYPE,
       i_ndc_prod       IN hcrs.prod_mstr_t.ndc_prod%TYPE,
       i_comp_typ_cd    IN hcrs.comp_typ_t.comp_typ_cd%TYPE,
       i_price          IN NUMBER,
       i_occurrences    IN NUMBER,
       i_bp_ind         IN hcrs.prfl_prod_bp_pnt_t.bp_ind%TYPE := NULL,
       i_cmt_txt        IN hcrs.prfl_prod_bp_pnt_t.cmt_txt%TYPE := NULL,
       i_manual_add_ind IN hcrs.prfl_prod_bp_pnt_t.manual_add_ind%TYPE := NULL,
       i_allow_null_cmt IN VARCHAR2 := NULL,
       i_commit         IN VARCHAR2 := pkg_constants.cs_flag_yes)
      RETURN hcrs.prfl_prod_bp_pnt_t.price_pnt_seq_no%TYPE
   IS
      /*************************************************************************
      * Function Name : p_ins_price_pnt
      *  Input params : i_prfl_id - profile
      *               : i_ndc_lbl - labeler
      *               : i_ndc_prod - product
      *               : i_comp_typ_cd - component type code
      *               : i_price - bp price point
      *               : i_occurences - number of trans at this price
      *               : i_bp_ind - When set to Y, set the BP
      *               : i_cmt_txt - Sets comment on price point
      *               : i_manual_add_ind - When set to Y, price was manually added
      *               : i_allow_null_cmt - When set to Y, a passed null comment will
      *               :                    delete the price point comment
      *               : i_commit - When set to Y, perform periodic commit
      * Output params : none
      *       Returns : NUMBER - Price Point Sequence of price point
      *  Date Created : 12/04/2000
      *        Author : Venkata Darabala
      *   Description : Inserts Price Points
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  05/18/2007  Joe Kidd      PICC 1769: Moved from pkg_medicaid.p_bp_insert
      *                            Add i_bp_ind to set price as BP
      *  01/15/2008  Joe Kidd      PICC 1864: Allow comment to be passed
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Commit at end counting all changes
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Convert to function returning price point seq no
      *                            Procedure to call function
      *  10/26/2015  Joe Kidd      CRQ-228988: Demand 8134: BP Upload
      *                            Add parameters to set manually added indicator,
      *                            control null comments, and control commits
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_ins_price_pnt';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Inserts BP price point';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while inserting BP price point';
      v_bp_ind              hcrs.prfl_prod_bp_pnt_t.bp_ind%TYPE;
      v_manual_add_ind      hcrs.prfl_prod_bp_pnt_t.manual_add_ind%TYPE;
      v_cnt                 NUMBER := 0;
      v_price_pnt_seq_no    hcrs.prfl_prod_bp_pnt_t.price_pnt_seq_no%TYPE;
   BEGIN
      IF i_manual_add_ind = pkg_constants.cs_flag_yes
      THEN
         v_manual_add_ind := pkg_constants.cs_flag_yes;
      END IF;
      IF i_bp_ind = pkg_constants.cs_flag_yes
      THEN
         v_bp_ind := pkg_constants.cs_flag_yes;
         -- Clear the BP flag on all existing records
         UPDATE hcrs.prfl_prod_bp_pnt_t t
            SET t.bp_ind = NULL
          WHERE t.prfl_id = i_prfl_id
            AND t.ndc_lbl = i_ndc_lbl
            AND t.ndc_prod = i_ndc_prod
            AND t.bp_mthd_typ_cd = i_comp_typ_cd
            AND t.bp_ind IS NOT NULL;
         v_cnt := v_cnt + SQL%ROWCOUNT;
      END IF;
      -- Increment the occurences in the table if the record already exists
      UPDATE hcrs.prfl_prod_bp_pnt_t t
         SET t.occurs_cnt = t.occurs_cnt + i_occurrences,
             t.bp_ind = v_bp_ind,
             t.cmt_txt = CASE
                            -- Allow comments to be deleted if null passed
                            WHEN i_allow_null_cmt = pkg_constants.cs_flag_yes
                            THEN i_cmt_txt
                            ELSE NVL( i_cmt_txt, t.cmt_txt)
                         END
             -- never change manually added indicator here
       WHERE t.prfl_id = i_prfl_id
         AND t.ndc_lbl = i_ndc_lbl
         AND t.ndc_prod = i_ndc_prod
         AND t.bp_mthd_typ_cd = i_comp_typ_cd
         AND t.price_amt = i_price
      RETURNING t.price_pnt_seq_no
           INTO v_price_pnt_seq_no;
      v_cnt := v_cnt + SQL%ROWCOUNT;
      -- If no record found then create the point
      IF SQL%NOTFOUND
      THEN
         INSERT INTO hcrs.prfl_prod_bp_pnt_t
            (prfl_id,
             ndc_lbl,
             ndc_prod,
             bp_mthd_typ_cd,
             price_amt,
             occurs_cnt,
             bp_ind,
             cmt_txt,
             manual_add_ind)
            VALUES
            (i_prfl_id,
             i_ndc_lbl,
             i_ndc_prod,
             i_comp_typ_cd,
             i_price,
             i_occurrences,
             v_bp_ind,
             i_cmt_txt,
             v_manual_add_ind)
            RETURNING price_pnt_seq_no
            INTO v_price_pnt_seq_no;
         v_cnt := v_cnt + SQL%ROWCOUNT;
      END IF;
      IF i_commit = pkg_constants.cs_flag_yes
      THEN
         p_commit( v_cnt);
      END IF;
      RETURN v_price_pnt_seq_no;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt ||
            ' i_prfl_id=[' || i_prfl_id ||
            '] i_ndc_lbl=[' || i_ndc_lbl ||
            '] i_ndc_prod=[' || i_ndc_prod ||
            '] i_comp_typ_cd=[' || i_comp_typ_cd ||
            '] i_price=[' || i_price ||
            '] i_occurrences=[' || i_occurrences ||
            '] i_bp_ind=[' || i_bp_ind ||
            '] i_cmt_txt=[' || i_cmt_txt ||
            '] i_manual_add_ind=[' || i_manual_add_ind ||
            '] i_allow_null_cmt=[' || i_allow_null_cmt ||
            '] i_commit=[' || i_commit || ']');
   END f_ins_price_pnt;


   PROCEDURE p_ins_price_pnt
      (i_prfl_id        IN hcrs.prfl_t.prfl_id%TYPE,
       i_ndc_lbl        IN hcrs.prod_mstr_t.ndc_lbl%TYPE,
       i_ndc_prod       IN hcrs.prod_mstr_t.ndc_prod%TYPE,
       i_comp_typ_cd    IN hcrs.comp_typ_t.comp_typ_cd%TYPE,
       i_price          IN NUMBER,
       i_bp_ind         IN hcrs.prfl_prod_bp_pnt_t.bp_ind%TYPE := NULL,
       i_cmt_txt        IN hcrs.prfl_prod_bp_pnt_t.cmt_txt%TYPE := NULL,
       i_manual_add_ind IN hcrs.prfl_prod_bp_pnt_t.manual_add_ind%TYPE := NULL,
       i_allow_null_cmt IN VARCHAR2 := NULL,
       i_commit         IN VARCHAR2 := pkg_constants.cs_flag_yes)
   IS
      /*************************************************************************
      * Procedure Name : p_ins_price_pnt
      *   Input params : i_prfl_id - profile
      *                : i_ndc_lbl - labeler
      *                : i_ndc_prod - product
      *                : i_comp_typ_cd - component type code
      *                : i_price - bp price point
      *                : i_bp_ind - When set to Y, set the BP
      *                : i_cmt_txt - Sets comment on price point
      *                : i_manual_add_ind - When set to Y, price was manually added
      *                : i_allow_null_cmt - When set to Y, a passed null comment will
      *                :                    delete the price point comment
      *                : i_commit - When set to Y, perform periodic commit
      *  Output params : None
      *        Returns : None
      *   Date Created : 09/25/2012
      *         Author : Joe Kidd
      *    Description : Inserts Price Points
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Convert to function returning price point seq no
      *                            Procedure to call function
      *  10/26/2015  Joe Kidd      CRQ-228988: Demand 8134: BP Upload
      *                            Add parameters to set manually added indicator,
      *                            control null comments, and control commits
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_ins_price_pnt';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Inserts BP price point';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while inserting BP price point';
   BEGIN
      gv_dummy := f_ins_price_pnt
                     (i_prfl_id,
                      i_ndc_lbl,
                      i_ndc_prod,
                      i_comp_typ_cd,
                      i_price,
                      0,
                      i_bp_ind,
                      i_cmt_txt,
                      i_manual_add_ind,
                      i_allow_null_cmt,
                      i_commit);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_ins_price_pnt;


   PROCEDURE p_mark_record
      (i_trans_group_tbl IN pkg_common_cursors.t_calc_trans_tbl,
       i_dllrs           IN NUMBER,
       i_units           IN NUMBER,
       i_prc_pnt         IN NUMBER,
       i_comp_typ_cd     IN hcrs.prfl_prod_calc_comp_def_t.comp_typ_cd%TYPE := NULL,
       i_use_hhs_chk     IN BOOLEAN := FALSE)
   IS
      /*************************************************************************
      * Procedure Name : p_mark_record
      *   Input params : i_trans_group_tbl - all lines of a transaction group (orig + adj)
      *                : i_dllrs - total dollars for the entire transaction
      *                : i_units - total units for the entire transaction
      *                : i_prc_pnt - Price Point value
      *                : i_comp_typ_cd - Component Type Code, if passed overrides table
      *                : i_use_hhs_chk - If TRUE, hhs check values will be used
      *                :                 instead of transaction and nominal values
      *  Output params : None
      *   Date Created : 12/13/2006
      *         Author : Joe Kidd
      *    Description : Adds records to marking cache
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  02/15/2007  Joe Kidd      PICC 1706: Allow override of Component and
      *                            Dollar/Unit values
      *                            Don't set nominal values if no nominal threshold value
      *  05/18/2007  Joe Kidd      PICC 1769: Add i_dllrs and i_units for entire transaction amounts
      *                            Add price point logic for BP processing
      *  12/05/2007  Joe Kidd      PICC 1763: Add split percentage type
      *  06/22/2009  Joe Kidd      RT 458 - CRQ 29045 - IS-000000000355
      *                            Added Price Point, comment, component amounts,
      *                            and nominal amounts parameters
      *                            Removed nominal threshold, and component
      *                            configuration parameters
      *                            Use passed price point over dollars and units
      *                            Allow generated comments to be added to price point
      *                            Remove f_get_trans_dllrs and f_get_trans_pkgs calls
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Call new f_ins_price_pnt function and remove global
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Seperated Component and Transaction dollars constants
      *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
      *                            Adjust for new bp_pnt_trans_dtl_t layout
      *                            Always build marking cache and lookup tables
      *                            Flush rows when customer changes
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Changed parameters, Add marked row count logging
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            GTT column reduction
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_mark_record';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Marks records in the prfl_prod_fmly_comp_trans_t table';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while marking records in the prfl_prod_fmly_comp_trans_t table';
      v_comp_typ_cd         hcrs.prfl_prod_calc_comp_def_t.comp_typ_cd%TYPE;
      v_prc_pnt             NUMBER;
      v_price_pnt_seq_no    hcrs.prfl_prod_bp_pnt_t.price_pnt_seq_no%TYPE;
      v_i                   BINARY_INTEGER;
      v_j                   BINARY_INTEGER;
      v_key                 VARCHAR2( 100);
   BEGIN
      v_i := i_trans_group_tbl.FIRST();
      -- Flush rows if this is a new customer
      p_mark_record_flush( i_trans_group_tbl( v_i).cust_id);
      -- Mark the passed rows
      v_comp_typ_cd := NVL( i_comp_typ_cd, i_trans_group_tbl( v_i).comp_typ_cd);
      IF i_trans_group_tbl( v_i).comp_dllrs = pkg_constants.cs_comp_dllrs_price
      THEN
         -- price points must create parent price point record
         IF i_prc_pnt IS NOT NULL
         THEN
            -- used passed price
            v_prc_pnt := i_prc_pnt;
         ELSE
            -- calculate the price
            IF i_units = 0
            THEN
               -- If no units, use the dollar amount as the price point
               v_prc_pnt := i_dllrs;
            ELSE
               v_prc_pnt := i_dllrs / i_units;
            END IF;
         END IF;
         -- round amount to decimal precision
         v_prc_pnt := ROUND( v_prc_pnt, gv_param_rec.dec_pcsn);
         IF gv_mark_records
         THEN
            -- insert BP point
            v_price_pnt_seq_no := f_ins_price_pnt
                                     (gv_param_rec.prfl_id,
                                      gv_param_rec.ndc_lbl,
                                      gv_param_rec.ndc_prod,
                                      v_comp_typ_cd,
                                      v_prc_pnt,
                                      i_trans_group_tbl.COUNT(), -- count of transactions
                                      pkg_constants.cs_flag_no,
                                      i_trans_group_tbl( v_i).cmt_txt);
         END IF;
      END IF;
      v_i := i_trans_group_tbl.FIRST();
      WHILE v_i IS NOT NULL
      LOOP
         -- Populate marking cache
         v_j := NVL( gv_mark_tbl.COUNT(), 0) + 1;
         gv_mark_tbl( v_j).prfl_id := gv_param_rec.prfl_id;
         gv_mark_tbl( v_j).ndc_lbl := gv_param_rec.ndc_lbl;
         gv_mark_tbl( v_j).ndc_prod := gv_param_rec.ndc_prod;
         gv_mark_tbl( v_j).ndc_pckg := gv_param_rec.ndc_pckg;
         gv_mark_tbl( v_j).calc_typ_cd := gv_param_rec.calc_typ_cd;
         gv_mark_tbl( v_j).comp_typ_cd := v_comp_typ_cd;
         gv_mark_tbl( v_j).trans_id := i_trans_group_tbl( v_i).trans_id;
         gv_mark_tbl( v_j).price_pnt_seq_no := v_price_pnt_seq_no;
         gv_mark_tbl( v_j).cls_of_trd_cd := i_trans_group_tbl( v_i).cust_cls_of_trd_cd;
         gv_mark_tbl( v_j).co_id := gv_param_rec.co_id;
         gv_mark_tbl( v_j).trans_adj_cd := i_trans_group_tbl( v_i).trans_adj_cd;
         IF i_trans_group_tbl( v_i).trans_adj_cd = pkg_constants.cs_trans_adj_original
         THEN
            gv_mark_tbl( v_j).root_trans_id := NULL;
            gv_mark_tbl( v_j).parent_trans_id := NULL;
         ELSE
            gv_mark_tbl( v_j).root_trans_id := i_trans_group_tbl( v_i).root_trans_id;
            gv_mark_tbl( v_j).parent_trans_id := i_trans_group_tbl( v_i).parent_trans_id;
         END IF;
         gv_mark_tbl( v_j).splt_pct_typ := i_trans_group_tbl( v_i).splt_pct_typ;
         gv_mark_tbl( v_j).splt_pct_seq_no := i_trans_group_tbl( v_i).splt_pct_seq_no;
         gv_mark_tbl( v_j).bndl_cd := i_trans_group_tbl( v_i).bndl_cd;
         gv_mark_tbl( v_j).bndl_seq_no := NULL;
         gv_mark_tbl( v_j).trans_dt := i_trans_group_tbl( v_i).trans_dt;
         IF NVL( i_use_hhs_chk, FALSE)
         THEN
            -- Transaction Dollars and Units
            gv_mark_tbl( v_j).dllr_amt := i_trans_group_tbl( v_i).hhs_dllr_amt;
            gv_mark_tbl( v_j).pkg_qty := i_trans_group_tbl( v_i).hhs_pkg_qty;
            -- HHS Dollars and Units
            gv_mark_tbl( v_j).nom_dllr_amt := i_trans_group_tbl( v_i).hhs_dllr_amt;
            gv_mark_tbl( v_j).nom_pkg_qty := i_trans_group_tbl( v_i).hhs_pkg_qty;
         ELSE
            -- Transaction Dollars and Units
            gv_mark_tbl( v_j).dllr_amt := i_trans_group_tbl( v_i).mk_dllr_amt;
            gv_mark_tbl( v_j).pkg_qty := i_trans_group_tbl( v_i).mk_pkg_qty;
            -- Nominal Dollars and Units
            gv_mark_tbl( v_j).nom_dllr_amt := i_trans_group_tbl( v_i).nom_dllr_amt;
            gv_mark_tbl( v_j).nom_pkg_qty := i_trans_group_tbl( v_i).nom_pkg_qty;
         END IF;
         -- Chargeback amount / Term Disc Pct no longer used
         gv_mark_tbl( v_j).chrgbck_amt := NULL;
         gv_mark_tbl( v_j).term_disc_pct := NULL;
         -- Populate marking cache lookup table
         v_key := '|' || gv_mark_tbl( v_j).comp_typ_cd || '|' || gv_mark_tbl( v_j).trans_id || '|';
         gv_mark_id_tbl( v_key) := pkg_constants.cs_flag_yes;
         -- Add to the mark row count
         p_set_cntr( cs_calc_log_cntr_rows_marked);
         v_i := i_trans_group_tbl.NEXT( v_i);
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_mark_record;


   FUNCTION f_mark_nominal
      (i_trans_group_tbl IN pkg_common_cursors.t_calc_trans_tbl,
       i_dllrs           IN NUMBER,
       i_units           IN NUMBER,
       i_nom_thresh      IN NUMBER)
      RETURN BOOLEAN
   IS
      /*************************************************************************
      * Function Name : f_mark_nominal
      *  Input params : i_trans_group_tbl - all lines of a transaction group (orig + adj)
      *               : i_dllrs - Transaction Dollar amount
      *               : i_units - Transaction Unit amount
      *               : i_nom_thresh - nominal threshold amount
      * Output params : None
      *       Returns : BOOLEAN, Inclusion setting set by user
      *  Date Created : 06/22/2009
      *        Author : Joe Kidd
      *   Description : Inserts nominal transactions into the exclusions table
      *                 setting the override to the passed value or to the
      *                 last value set by the user.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change to function, cache writes, add new columns,
      *                            control default inclusion here, simplify comment
      *                            lookup, add marked row count logging
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_mark_nominal';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Inserts nominal transactions into the exclusions table.';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while inserting nominal transactions into the exclusions table.';
      v_over_ind            hcrs.prfl_sls_excl_t.over_ind%TYPE;
      v_sls_excl_ind        hcrs.prfl_sls_excl_t.over_ind%TYPE;
      v_cmt_txt             hcrs.prfl_sls_excl_t.cmt_txt%TYPE;
      v_i                   BINARY_INTEGER;
      v_j                   BINARY_INTEGER;
   BEGIN
      v_i := i_trans_group_tbl.FIRST();
      -- Flush rows if this is a new customer
      p_mark_record_flush( i_trans_group_tbl( v_i).cust_id);
      ------------------------------------------------
      -- DEFAULT: Non-nominal/false/included
      ------------------------------------------------
      v_over_ind := pkg_constants.cs_include;
      --v_over_ind := pkg_constants.cs_exclude;
      IF gv_mark_nom_id_tbl.EXISTS( i_trans_group_tbl( v_i).trans_id)
      THEN
         -- Already processed as nominal, use last result
         v_over_ind := gv_mark_nom_id_tbl( i_trans_group_tbl( v_i).trans_id);
      ELSE
         -- Insert record as Included to reverse exclusion logic
         -- This reversal was put into place before SAP adjustments were tied
         -- together to allow adjustments to be included in the calc without
         -- user intervention.  A true nominal sale must be manually excluded
         -- by the end user from the front end in order to be removed from the
         -- calculation.
         v_sls_excl_ind := i_trans_group_tbl( v_i).sls_excl_ind;
         IF v_sls_excl_ind IS NULL
         THEN
            -- Get the most recently approved inclusion setting and comment for
            -- this transaction in this agency from transmitted profiles but not
            -- the current profile, otherwise use the default inclusion setting
            -- MAX used to prevent no data exception
            SELECT MAX( z.over_ind) over_ind,
                   MAX( z.cmt_txt) cmt_txt
              INTO v_sls_excl_ind,
                   v_cmt_txt
              FROM (
                     SELECT ROW_NUMBER() OVER (ORDER BY pse.apprvd_dt DESC, pse.prfl_id DESC) rn,
                            pse.over_ind,
                            pse.cmt_txt
                       FROM hcrs.prfl_t p,
                            hcrs.prfl_sls_excl_t pse
                      WHERE p.prfl_id = pse.prfl_id
                        AND p.prfl_stat_cd = pkg_constants.cs_prfl_stat_transmitted_cd
                        AND p.agency_typ_cd = gv_param_rec.agency_typ_cd
                        AND pse.trans_id = i_trans_group_tbl( v_i).trans_id
                        AND pse.prfl_id <> gv_param_rec.prfl_id
                   ) z
             WHERE z.rn = 1;
            -- Use default is nothing found
            v_sls_excl_ind := NVL( v_sls_excl_ind, v_over_ind);
         END IF;
         v_i := i_trans_group_tbl.FIRST();
         WHILE v_i IS NOT NULL
         LOOP
            -- Populate marking cache
            v_j := NVL( gv_mark_nom_tbl.COUNT(), 0) + 1;
            gv_mark_nom_tbl( v_j).prfl_id := gv_param_rec.prfl_id;
            gv_mark_nom_tbl( v_j).trans_id := i_trans_group_tbl( v_i).trans_id;
            gv_mark_nom_tbl( v_j).co_id := gv_param_rec.co_id;
            gv_mark_nom_tbl( v_j).cls_of_trd_cd := i_trans_group_tbl( v_i).cust_cls_of_trd_cd;
            gv_mark_nom_tbl( v_j).over_ind := v_sls_excl_ind;
            gv_mark_nom_tbl( v_j).cmt_txt := v_cmt_txt;
            -- Row will exist if already approved, so just set defaults
            gv_mark_nom_tbl( v_j).apprvd_ind := pkg_constants.cs_flag_no;
            gv_mark_nom_tbl( v_j).apprvd_dt := NULL;
            gv_mark_nom_tbl( v_j).apprvd_by := NULL;
            -- Only Include the adjustment count, quantity, amount, and nominal threshold for original transactions
            IF v_i = i_trans_group_tbl.FIRST()
            THEN
               -- First record is the original invoice transaction, the rest of the records are adjustments
               gv_mark_nom_tbl( v_j).adj_cnt := i_trans_group_tbl.COUNT() - 1;
               gv_mark_nom_tbl( v_j).adj_pkg_qty := i_units;
               gv_mark_nom_tbl( v_j).adj_total_amt := i_dllrs;
               gv_mark_nom_tbl( v_j).nmnl_thres_amt := i_nom_thresh;
            ELSE
               gv_mark_nom_tbl( v_j).adj_cnt := 0;
               gv_mark_nom_tbl( v_j).adj_pkg_qty := NULL;
               gv_mark_nom_tbl( v_j).adj_total_amt := NULL;
               gv_mark_nom_tbl( v_j).nmnl_thres_amt := NULL;
            END IF;
            gv_mark_nom_tbl( v_j).trans_adj_cd := i_trans_group_tbl( v_i).trans_adj_cd;
            IF i_trans_group_tbl( v_i).trans_adj_cd = pkg_constants.cs_trans_adj_original
            THEN
               gv_mark_nom_tbl( v_j).root_trans_id := NULL;
               gv_mark_nom_tbl( v_j).parent_trans_id := NULL;
            ELSE
               gv_mark_nom_tbl( v_j).root_trans_id := i_trans_group_tbl( v_i).root_trans_id;
               gv_mark_nom_tbl( v_j).parent_trans_id := i_trans_group_tbl( v_i).parent_trans_id;
            END IF;
            gv_mark_nom_tbl( v_j).trans_dt := i_trans_group_tbl( v_i).trans_dt;
            gv_mark_nom_tbl( v_j).splt_pct_typ := i_trans_group_tbl( v_i).splt_pct_typ;
            gv_mark_nom_tbl( v_j).splt_pct_seq_no := i_trans_group_tbl( v_i).splt_pct_seq_no;
            gv_mark_nom_tbl( v_j).bndl_cd := i_trans_group_tbl( v_i).bndl_cd;
            gv_mark_nom_tbl( v_j).bndl_seq_no := NULL;
            -- Get Transaction Dollars and Units
            gv_mark_nom_tbl( v_j).dllr_amt := i_trans_group_tbl( v_i).mk_dllr_amt;
            gv_mark_nom_tbl( v_j).pkg_qty := i_trans_group_tbl( v_i).mk_pkg_qty;
            -- Chargeback amount/Term Disc Pct deprecated
            gv_mark_nom_tbl( v_j).chrgbck_amt := NULL;
            gv_mark_nom_tbl( v_j).term_disc_pct := NULL;
            -- Get Nominal Dollars and Units
            gv_mark_nom_tbl( v_j).nom_dllr_amt := i_trans_group_tbl( v_i).nom_dllr_amt;
            gv_mark_nom_tbl( v_j).nom_pkg_qty := i_trans_group_tbl( v_i).nom_pkg_qty;
            -- Populate marking cache lookup table
            gv_mark_nom_id_tbl( gv_mark_nom_tbl( v_j).trans_id) := v_sls_excl_ind;
            -- Add to the mark row count
            p_set_cntr( cs_calc_log_cntr_rows_marked);
            v_i := i_trans_group_tbl.NEXT( v_i);
         END LOOP;
      END IF;
      -- Set actual inclusion values
      RETURN (v_over_ind = pkg_constants.cs_exclude);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_mark_nominal;


   FUNCTION f_is_trans_marked
      (i_comp_typ_cd IN hcrs.prfl_prod_comp_trans_t.comp_typ_cd%TYPE,
       i_trans_id    IN hcrs.prfl_prod_comp_trans_t.trans_id%TYPE)
      RETURN BOOLEAN
   IS
      /*************************************************************************
      * Function Name : f_is_trans_marked
      *  Input params : i_comp_typ_cd - Component Type Code
      *               : i_trans_id - Trans ID
      * Output params : None
      *       Returns : BOOLEAN - TRUE if marked
      *  Date Created : 01/21/2004
      *        Author : Joe Kidd
      *   Description : Determines if a transaction has been marked by a
      *                 calculation in a specific component
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  02/04/2004  Joe Kidd      PICC 1167: Add Medicare ASP
      *  11/01/2004  Joe Kidd      PICC 1327: Calc Cursor Tuning
      *                            f_is_trans_marked is more specific for BP
      *  02/01/2005  Joe Kidd      PICC 1372: Check bulk bind marking record caches
      *  12/13/2006  Joe Kidd      PICC 1680: Look in cache first
      *  05/18/2007  Joe Kidd      PICC 1769: Add parameters to differentiate
      *                            calculation NDC and transaction NDC
      *  08/07/2008  Joe Kidd      PICC 1950: Don't check table if found in
      *                            bulk bind record cache
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Moved from pkg_common_functions
      *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
      *                            Remove trans ndc parameters
      *                            Use marking lookup table instead of cache table
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters, reduce key length
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_is_trans_marked';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Checks if a transaction has been marked';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while checking if a transaction has been marked';
   BEGIN
      RETURN gv_mark_id_tbl.EXISTS( '|' || i_comp_typ_cd || '|' || i_trans_id || '|');
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_is_trans_marked;


   FUNCTION f_is_trans_marked
      (i_trans_group_tbl IN pkg_common_cursors.t_calc_trans_tbl,
       i_comp_typ_cd     IN hcrs.prfl_prod_comp_trans_t.comp_typ_cd%TYPE := NULL)
      RETURN BOOLEAN
   IS
      /*************************************************************************
      * Function Name : f_is_trans_marked
      *  Input params : i_trans_group_tbl - all lines of a transaction group (orig + adj)
      *               : i_comp_typ_cd - Component Type Code, if passed overrides table
      * Output params : None
      *       Returns : BOOLEAN - TRUE if marked
      *  Date Created : 01/15/2018
      *        Author : Joe Kidd
      *   Description : Determines if any transaction in the trans group has been
      *                 marked in a specific calculation component
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_is_trans_marked';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Checks if any transaction in group has been marked';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while checking if any transaction in group has been marked';
      v_marked              BOOLEAN := FALSE;
      v_i                   BINARY_INTEGER;
   BEGIN
      v_i := i_trans_group_tbl.FIRST();
      WHILE v_i IS NOT NULL
        AND NOT v_marked
      LOOP
         v_marked := f_is_trans_marked
                        (NVL( TRIM( i_comp_typ_cd), i_trans_group_tbl( v_i).comp_typ_cd),
                         i_trans_group_tbl( v_i).trans_id);
         v_i := i_trans_group_tbl.NEXT( v_i);
      END LOOP;
      RETURN v_marked;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END f_is_trans_marked;


   PROCEDURE p_accum_trans
      (io_trans_group_tbl IN OUT pkg_common_cursors.t_calc_trans_tbl,
       i_trans_group_ttls IN     t_calc_total_rec)
   IS
      /*************************************************************************
      * Procedure Name : p_accum_trans
      *   Input params : io_trans_group_tbl - the transaction group (orig + adj)
      *                : i_trans_group_ttls - Dollar/Unit totals for the group
      *  Output params : io_trans_group_tbl - the transaction group (orig + adj)
      *   Date Created : 12/13/2006
      *         Author : Joe Kidd
      *    Description : Accumulates a transaction into a component.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  02/15/2007  Joe Kidd      PICC 1706: Add Nominal checking logic
      *                            Add HHS violation checking logic
      *                            Add Accumulation and Marking logic
      *  05/18/2007  Joe Kidd      PICC 1769:
      *                            Only accum component values for Sales/Discount components
      *                            Adjust Nominal check logic to always retrieve nominal threshold
      *  08/22/2008  Joe Kidd      PICC 1961: Add switch to skip this procedure
      *  08/07/2008  Joe Kidd      PICC 1950: Check CARS credits that may already
      *                            be linked to a sale
      *                            Check SAP adjustments that may have already
      *                            been linked to an original
      *  06/22/2009  Joe Kidd      RT 458 - CRQ 29045 - IS-000000000355
      *                            Replace f_get_trans_dllrs and f_get_trans_pkgs
      *                            call pairs with a single p_get_trans_vals call
      *                            Get component values first
      *                            Restructure Nominal/HHS and transaction evaluation
      *                            Incorporated f_det_hhs_component and f_chk_pkg_price
      *  04/01/2010  Joe Kidd      RT 372 - CRQ 43435 - IS-000000000018
      *                            Check Prasco Rebates/Fees that may have already
      *                            been linked to an original
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Add WAC value of packages
      *                            Add Zero Dollars mark/accumulation method
      *                            Add FFS-PHS Contract mark/accumulation method
      *                            Add Non-Zero Dollars/FFS-PHS Contract mark/accumulation method
      *                            Add No Nominal/HHS/Zero Dollars mark/accumulation method
      *                            Add No Nominal/HHS/Zero Dollars/FFS-PHS Contract mark/accumulation method
      *  03/01/2012  Joe Kidd      CRQ-14127: Fix Contract ID filter not working
      *                            for blank contract IDs
      *                            Make NULL FSS/PHS contract check FALSE
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Check FSS/PHS contract first
      *                            Don't check nominal for FSS/PHS contracts
      *                            Add HHS/Non-Zero Dollars mark/accumulation method
      *                            Add HHS/Zero Dollars mark/accumulation method
      *                            Add No HHS mark/accumulation method
      *                            Add No HHS/Zero Dollars mark/accumulation method
      *                            Add No Nominal mark/accumulation method
      *                            Add No Nominal/Zero Dollars mark/accumulation method
      *                            Add No Nominal/Zero Dollars/FFS-PHS Contract mark/accumulation method
      *                            Don't mark HHS violations more than once
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Use new component value table
      *                            Add new trans mark/accumulation settings
      *                            Use earned date Sub-PHS checks
      *                            Add nominal values to nom/hhs mark components
      *                            Use chk values for HHS violation component
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Seperated Component and Transaction dollars constants
      *                            Carry and process prompt pay dollars seperately
      *                            Reorder and complete Accumulate processing
      *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
      *                            Remove total variables
      *                            Remove unneeded transaction accumulations
      *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
      *                            Remove trans ndc parameters from f_is_trans_marked
      *  08/01/2017  Joe Kidd      CRQ-376321: Demand 10535: NFAMP HHS Comp Summary
      *                            Accumulate a component for the HHS violations
      *  09/01/2017  T. Zimmerman  CRQ-376430: Demand 10537: NFAMP 340B Prime Vendor
      *                            Skip sub-PHS price checking for 340B PVP contracts
      *  09/20/2017  T. Zimmerman  CRQ-376489: Demand 10536: Revise Calc Methods for SPP Wholesalers
      *                            Add limit for contracted or non-contracted transactions
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters, adapt to new component settings
      *                            and functions, remove secondary nom/hhs components
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Correct Nominal/sub-PHS enable/disable
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_accum_trans';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Accumulates a transaction into a component.';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while accumulating a transaction into a component.';
      v_i                   BINARY_INTEGER;
      v_trans_group_tbl     pkg_common_cursors.t_calc_trans_tbl;
      v_trn_dllrs           NUMBER := 0;
      v_trn_units           NUMBER := 0;
      v_trn_prc_pnt         NUMBER;
      v_accum               BOOLEAN := FALSE; -- Transactions are not accumulated by default
      v_rebate_no_dsc       BOOLEAN := FALSE; -- Does rebate have no discount?
      v_contr               BOOLEAN;
      v_fss_contr           BOOLEAN;
      v_phs_contr           BOOLEAN;
      v_phs_pvp_contr       BOOLEAN;
      v_zero_dllrs          BOOLEAN;
      v_nom                 BOOLEAN := FALSE; -- Transactions are non-nominal by default
      v_hhs                 BOOLEAN := FALSE; -- Transactions are not sub-PHS by default
      v_chk_nom             BOOLEAN := FALSE; -- Nominal not checked by default
      v_nom_thresh          NUMBER;
      v_get_nom_values      BOOLEAN := FALSE; -- Nominal values not retrieved by default
      v_nom_dllrs           NUMBER := 0;
      v_nom_units           NUMBER := 0;
      v_nom_prc_pnt         NUMBER;
      v_chk_hhs             BOOLEAN := FALSE; -- HHS violations not checked by default
      v_hhs_thresh          NUMBER;
      v_hhs_dllrs           NUMBER := 0;
      v_hhs_units           NUMBER := 0;
      v_hhs_prc_pnt         NUMBER;
   BEGIN
      IF gv_accum_trans
      THEN
         --------------------------------------------------------------------
         -- Check if the transaction has already been processed
         --------------------------------------------------------------------
         IF NOT f_is_trans_marked( io_trans_group_tbl)
         THEN
            -----------------------------------------------------------------------
            -- Make local copy of transaction group
            -----------------------------------------------------------------------
            v_trans_group_tbl := io_trans_group_tbl;
            v_i := v_trans_group_tbl.FIRST();
            -----------------------------------------------------------------------
            -- Set Nominal and HHS Violation checks
            -----------------------------------------------------------------------
            v_chk_nom := (gv_param_rec.chk_nom = pkg_constants.cs_flag_yes);
            v_chk_hhs := (gv_param_rec.chk_hhs = pkg_constants.cs_flag_yes);
            -----------------------------------------------------------------------
            -- Is trans a rebate with no net discount?  Only use the discount amount
            -----------------------------------------------------------------------
            v_rebate_no_dsc := (    i_trans_group_ttls.trans_cls_cd = pkg_constants.cs_trans_cls_rbt
                                AND i_trans_group_ttls.source_sys_cde = pkg_constants.cs_system_cars
                                AND i_trans_group_ttls.dllrs_grs <> 0
                                AND i_trans_group_ttls.dllrs_dsc = 0);
            -----------------------------------------------------------------------
            -- Calculate Main Comp values
            -----------------------------------------------------------------------
            p_get_trans_vals( v_trans_group_tbl,
                              cs_trns_amt_comp,
                              0,
                              v_trn_dllrs,
                              v_trn_units,
                              v_trn_prc_pnt,
                              v_contr,
                              v_phs_pvp_contr,
                              v_phs_contr,
                              v_fss_contr,
                              v_zero_dllrs,
                              v_chk_nom,
                              v_chk_hhs,
                              v_rebate_no_dsc);
            -----------------------------------------------------------------------
            -- Nominal check
            -----------------------------------------------------------------------
            -- Nominal rules moved to p_get_trans_vals call above to check all rows
            IF v_chk_nom
            THEN
               -- If a nominal check is required always retrieve the nominal threshold
               -- it is needed for the nominal check and to enforce population of
               -- the nominal dollars and units on the marked record
               -- Note: sls_excl_ind will be null unless the transactions has already
               -- been marked as nominal and the user has set the include/exclude flag
               v_nom_thresh := pkg_common_functions.f_get_chk_price( v_trans_group_tbl( v_i).trans_dt, gv_nd_tbl);
               IF   v_trans_group_tbl( v_i).sls_excl_ind IS NULL
                AND NVL( v_nom_thresh, 0) > 0
               THEN
                  -- Never identified as nominal and threshold exists
                  -- Non-Nominal by default, get nominal values, check for nominal
                  v_nom := FALSE;
                  v_get_nom_values := TRUE;
                  v_chk_nom := TRUE;
               ELSIF v_trans_group_tbl( v_i).sls_excl_ind IS NULL
                 AND NVL( v_nom_thresh, 0) <= 0
               THEN
                  -- Never identified as nominal and threshold does not exist
                  -- Set to non-nominal, don't get nominal values, don't check for nominal
                  v_nom := FALSE;
                  v_get_nom_values := FALSE;
                  v_chk_nom := FALSE;
               ELSIF v_trans_group_tbl( v_i).sls_excl_ind = pkg_constants.cs_include
               THEN
                  -- Already identified as Nominal and user set as non-nominal
                  -- Set to non-nominal, get nominal values, don't check for nominal
                  v_nom := FALSE;
                  v_get_nom_values := TRUE;
                  v_chk_nom := FALSE;
               ELSIF v_trans_group_tbl( v_i).sls_excl_ind = pkg_constants.cs_exclude
               THEN
                  -- Already identified as Nominal and user set as nominal
                  -- Set to non-nominal, get nominal values, don't check for nominal
                  v_nom := TRUE;
                  v_get_nom_values := TRUE;
                  v_chk_nom := FALSE;
               END IF;
               IF v_get_nom_values
               THEN
                  -- Calculate Nominal dollars and units
                  p_get_trans_vals( v_trans_group_tbl,
                                    cs_trns_amt_nom_chk,
                                    NULL,
                                    v_nom_dllrs,
                                    v_nom_units,
                                    v_nom_prc_pnt,
                                    -- These values will not be changed
                                    v_contr,
                                    v_phs_pvp_contr,
                                    v_phs_contr,
                                    v_fss_contr,
                                    v_zero_dllrs,
                                    v_chk_nom,
                                    v_chk_hhs,
                                    v_rebate_no_dsc);
               END IF;
               IF v_chk_nom
               THEN
                  -- Check for nominal sales
                  IF   v_nom_prc_pnt IS NULL
                   AND v_nom_dllrs <> 0
                   AND v_nom_units <> 0
                   AND v_nom_thresh > 0
                   AND ABS( v_nom_dllrs) / ABS( v_nom_units) <= v_nom_thresh
                  THEN
                     --------------------------------------------------------------------
                     -- This is a nominal sale
                     --------------------------------------------------------------------
                     -- no price point was passed (null)
                     -- and the dollar value is not zero (and not null)
                     -- and the unit value is not zero (and not null)
                     -- and the nominal threshold is greater than zero (and not null)
                     -- and the passed price point is less than or equal to the nominal threshold
                     -- Return TRUE to exclude the rows
                     v_nom := TRUE;
                  ELSIF v_nom_prc_pnt IS NOT NULL
                    AND v_nom_prc_pnt > 0
                    AND v_nom_thresh > 0
                    AND v_nom_prc_pnt <= v_nom_thresh
                  THEN
                     --------------------------------------------------------------------
                     -- This is a nominal sale
                     --------------------------------------------------------------------
                     -- Price point was passed  (not null)
                     -- and the passed price point was greater than zero
                     -- and the nominal threshold is greater than zero (and not null)
                     -- and the passed price point is less than or equal to the nominal threshold
                     -- Return TRUE to exclude the rows
                     v_nom := TRUE;
                  END IF;
                  IF v_nom
                  THEN
                     -- Price is a nominal, Add to sales exclusions. Default inclusion
                     -- rule is controlled in the function. The user can override with
                     -- UI and run calc again. A user override on this or previous
                     -- profiles can change the nominal flag from this function
                     v_nom := f_mark_nominal( v_trans_group_tbl,
                                              v_nom_dllrs,
                                              v_nom_units,
                                              v_nom_thresh);
                  END IF;
               END IF;
            END IF; -- Nom
            -----------------------------------------------------------------------
            -- HHS violation check
            -----------------------------------------------------------------------
            -- HHS violation rules moved to p_get_trans_vals call above to check all rows
            IF v_chk_hhs
            THEN
               -- If a HHS check is required always retrieve the nominal threshold
               -- it is needed for the HHS check and to enforce population of
               -- the nominal dollars and units on the marked record
               -- Earned date must be used to retrieve the correct PHS price
               v_hhs_thresh := pkg_common_functions.f_get_chk_price
                                  (v_trans_group_tbl( v_i).ndc_lbl,
                                   v_trans_group_tbl( v_i).ndc_prod,
                                   v_trans_group_tbl( v_i).ndc_pckg,
                                   v_trans_group_tbl( v_i).earn_bgn_dt,
                                   gv_pl102_tbl);
               IF NVL( v_hhs_thresh, 0) > 0
               THEN
                  -- Calculate HHS violation dollars and units
                  p_get_trans_vals( v_trans_group_tbl,
                                    cs_trns_amt_hhs_chk,
                                    NULL,
                                    v_hhs_dllrs,
                                    v_hhs_units,
                                    v_hhs_prc_pnt,
                                    -- These values will not be changed
                                    v_contr,
                                    v_phs_pvp_contr,
                                    v_phs_contr,
                                    v_fss_contr,
                                    v_zero_dllrs,
                                    v_chk_nom,
                                    v_chk_hhs,
                                    v_rebate_no_dsc);
                  -- Check for HHS violation
                  IF   v_hhs_prc_pnt IS NULL
                   AND v_hhs_dllrs <> 0
                   AND v_hhs_units <> 0
                   AND v_hhs_thresh > 0
                   AND ABS( v_hhs_dllrs) / ABS( v_hhs_units) < v_hhs_thresh
                  THEN
                     --------------------------------------------------------------------
                     -- This is a Sub-PHS sale
                     --------------------------------------------------------------------
                     -- no price point was passed (null)
                     -- and the dollar value is not zero (and not null)
                     -- and the unit value is not zero (and not null)
                     -- and the PL102 price is greater than zero (and not null)
                     -- and the dollars divided by units is less than the PL 102 price
                     v_hhs := TRUE;
                  ELSIF v_hhs_prc_pnt IS NOT NULL
                    AND v_hhs_prc_pnt > 0
                    AND v_hhs_thresh > 0
                    AND v_hhs_prc_pnt < v_hhs_thresh
                  THEN
                     --------------------------------------------------------------------
                     -- This is a Sub-PHS sale
                     --------------------------------------------------------------------
                     -- Price point was passed  (not null)
                     -- and the passed price point was greater than zero
                     -- and the PL102 price is greater than zero (and not null)
                     -- and the passed price point is less than the PL 102 price
                     v_hhs := TRUE;
                  END IF;
               END IF;
               IF v_hhs
               THEN
                  IF NOT f_is_trans_marked( v_trans_group_tbl, pkg_constants.cs_hhs_pl102_violation)
                  THEN
                     -- Mark as an HHS violation if is hasn't already been marked
                     p_mark_record
                        (v_trans_group_tbl,
                         v_hhs_dllrs,
                         v_hhs_units,
                         v_hhs_prc_pnt,
                         pkg_constants.cs_hhs_pl102_violation,
                         TRUE); -- use hhs instead of nom
                     -- Add units to HHS violation component
                     p_comp_val_add( pkg_constants.cs_hhs_pl102_violation, v_hhs_units);
                  END IF;
               END IF;
            END IF; -- HHS
            -----------------------------------------------------------------------
            -- Component marking
            -----------------------------------------------------------------------
            v_accum := FALSE;
            -- ALL setting overrides everything else
            IF (v_trans_group_tbl( v_i).mark_accum_all_ind = pkg_constants.cs_flag_yes)
            THEN
               -- Accumulate All transactions
               v_accum := TRUE;
            ELSIF (v_trans_group_tbl( v_i).mark_accum_all_ind = pkg_constants.cs_flag_no)
            THEN
               -- Accumulate no transactions (this is not loaded into the working table, but this is here for completeness)
               v_accum := FALSE;
            ELSIF  (   -- Interpret nominal setting
                       (v_trans_group_tbl( v_i).mark_accum_nom_ind = pkg_constants.cs_mark_accum_yes AND v_nom)
                    OR (v_trans_group_tbl( v_i).mark_accum_nom_ind = pkg_constants.cs_mark_accum_no AND NOT v_nom)
                    OR (v_trans_group_tbl( v_i).mark_accum_nom_ind = pkg_constants.cs_mark_accum_igr)
                   )
               AND (   -- Interpret sub-PHS setting
                       (v_trans_group_tbl( v_i).mark_accum_hhs_ind = pkg_constants.cs_mark_accum_yes AND v_hhs)
                    OR (v_trans_group_tbl( v_i).mark_accum_hhs_ind = pkg_constants.cs_mark_accum_no AND NOT v_hhs)
                    OR (v_trans_group_tbl( v_i).mark_accum_hhs_ind = pkg_constants.cs_mark_accum_igr)
                   )
               AND (   -- Interpret contracted setting
                       (v_trans_group_tbl( v_i).mark_accum_contr_ind = pkg_constants.cs_mark_accum_yes AND v_contr)
                    OR (v_trans_group_tbl( v_i).mark_accum_contr_ind = pkg_constants.cs_mark_accum_no AND NOT v_contr)
                    OR (v_trans_group_tbl( v_i).mark_accum_contr_ind = pkg_constants.cs_mark_accum_igr)
                   )
               AND (   -- Interpret FSS contract setting
                       (v_trans_group_tbl( v_i).mark_accum_fsscontr_ind = pkg_constants.cs_mark_accum_yes AND v_fss_contr)
                    OR (v_trans_group_tbl( v_i).mark_accum_fsscontr_ind = pkg_constants.cs_mark_accum_no AND NOT v_fss_contr)
                    OR (v_trans_group_tbl( v_i).mark_accum_fsscontr_ind = pkg_constants.cs_mark_accum_igr)
                   )
               AND (   -- Interpret PHS contract setting
                       (v_trans_group_tbl( v_i).mark_accum_phscontr_ind = pkg_constants.cs_mark_accum_yes AND v_phs_contr)
                    OR (v_trans_group_tbl( v_i).mark_accum_phscontr_ind = pkg_constants.cs_mark_accum_no AND NOT v_phs_contr)
                    OR (v_trans_group_tbl( v_i).mark_accum_phscontr_ind = pkg_constants.cs_mark_accum_igr)
                   )
               AND (   -- Interpret Zero Dollars setting
                       (v_trans_group_tbl( v_i).mark_accum_zerodllrs_ind = pkg_constants.cs_mark_accum_yes AND v_zero_dllrs)
                    OR (v_trans_group_tbl( v_i).mark_accum_zerodllrs_ind = pkg_constants.cs_mark_accum_no AND NOT v_zero_dllrs)
                    OR (v_trans_group_tbl( v_i).mark_accum_zerodllrs_ind = pkg_constants.cs_mark_accum_igr)
                   )
            THEN
               v_accum := TRUE;
            END IF;
            IF v_accum
            THEN
               IF v_trans_group_tbl( v_i).comp_dllrs IN (pkg_constants.cs_comp_dllrs_sales,
                                                         pkg_constants.cs_comp_dllrs_dsc)
               THEN
                  -- Accumulate the transaction values
                  p_comp_val_add( v_trans_group_tbl( v_i).comp_typ_cd, v_trn_dllrs);
                  p_comp_val_add( v_trans_group_tbl( v_i).units_comp_typ_cd, v_trn_units);
               END IF;
               -- Mark the transactions
               p_mark_record
                  (v_trans_group_tbl,
                   v_trn_dllrs,
                   v_trn_units,
                   v_trn_prc_pnt);
            END IF;
         END IF; -- not marked
      END IF; -- Accumulation ON
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt ||
            ' TRANS_ID=' || io_trans_group_tbl( io_trans_group_tbl.FIRST()).trans_id);
   END p_accum_trans;


   PROCEDURE p_set_bndl_cust
      (i_cust_id IN hcrs.prfl_prod_bndl_smry_wrk_t.cust_id%TYPE)
   IS
      /*************************************************************************
      * Procedure Name : p_set_bndl_cust
      *   Input params : i_cust_id - customer ID
      *  Output params : None
      *        Returns : None
      *   Date Created : 01/15/2018
      *         Author : Joe Kidd
      *    Description : Set the current bundling customer for the audit trail
      *                  Exposed for support when testing hcrs.calc_csr_bndl_cnfg_v
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
      *                            Correct %TYPE anchors
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Include Customer Conditions
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_set_bndl_cust';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Set the current bundling customer for the audit trail';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while setting the current bundling customer for the audit trail';
      v_calc_running        VARCHAR2( 1);
   BEGIN
      v_calc_running := f_is_calc_running_vc();
      -- Clear the array
      gv_bndl_cust_tbl.DELETE();
      -- Add customer with NONE condition
      gv_bndl_cust_tbl.EXTEND();
      gv_bndl_cust_tbl( gv_bndl_cust_tbl.LAST()) :=
         hcrs.bndl_cust_rec_typ( gv_param_rec.prfl_id,
                                 gv_param_rec.co_id,
                                 gv_param_rec.mk_ndc_lbl,
                                 gv_param_rec.mk_ndc_prod,
                                 gv_param_rec.mk_ndc_pckg,
                                 gv_param_rec.calc_typ_cd,
                                 i_cust_id,
                                 pkg_constants.cs_cond_none_cd,
                                 pkg_constants.cs_begin_time,
                                 pkg_constants.cs_end_time,
                                 v_calc_running,
                                 pkg_constants.cs_flag_yes);
      -- Add other customer conditions
      IF gv_bndl_cust_cond_cnt > 0
      THEN
         FOR v_rec IN
            (
               SELECT /*+ INDEX( pccw prfl_cust_cond_wrk_ix1 )
                          DYNAMIC_SAMPLING( 0 )
                      */
                      pccw.cond_cd,
                      pccw.cond_strt_dt,
                      pccw.cond_end_dt
                 FROM hcrs.prfl_cust_cond_wrk_t pccw
                WHERE pccw.cust_id = i_cust_id
            )
         LOOP
            gv_bndl_cust_tbl.EXTEND();
            gv_bndl_cust_tbl( gv_bndl_cust_tbl.LAST()) :=
               hcrs.bndl_cust_rec_typ( gv_param_rec.prfl_id,
                                       gv_param_rec.co_id,
                                       gv_param_rec.mk_ndc_lbl,
                                       gv_param_rec.mk_ndc_prod,
                                       gv_param_rec.mk_ndc_pckg,
                                       gv_param_rec.calc_typ_cd,
                                       i_cust_id,
                                       v_rec.cond_cd,
                                       v_rec.cond_strt_dt,
                                       v_rec.cond_end_dt,
                                       v_calc_running,
                                       pkg_constants.cs_flag_yes);
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_set_bndl_cust;


   FUNCTION f_get_bndl_cust
      (i_cond_cd IN hcrs.prfl_prod_bndl_dts_wrk_t.cond_cd%TYPE := NULL)
      RETURN hcrs.bndl_cust_tbl_typ
      PIPELINED
   IS
      /*************************************************************************
      * Function Name : f_get_bndl_cust
      *  Input params : i_cond_cd - If passed, limit to passed condition code
      * Output params : None
      *       Returns : Current bundling customer for audit trail
      *  Date Created : 01/15/2018
      *        Author : Joe Kidd
      *   Description : Get the current bundling customer for the audit trail
      *
      *                 Pipelined Table function for use in SQL
      *                 Exposed for support when testing hcrs.calc_csr_bndl_cnfg_v
      *
      *                 NOTE: This procedure should only write to temporary
      *                 tables, so that it can be used during testing/debugging
      *                 in production.  No changes should be made to permanent
      *                 objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_get_bndl_cust';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Get the current bundling customer for the audit trail';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while getting the current bundling customer for the audit trail';
      v_i                   NUMBER;
   BEGIN
      v_i := gv_bndl_cust_tbl.FIRST();
      WHILE v_i IS NOT NULL
      LOOP
         IF gv_bndl_cust_tbl( v_i).cond_cd = NVL( i_cond_cd, gv_bndl_cust_tbl( v_i).cond_cd)
         THEN
            -- NONE row found
            PIPE ROW( gv_bndl_cust_tbl( v_i));
            -- Only one NONE row will ever exist, exit loop
            v_i := NULL;
         END IF;
         v_i := gv_bndl_cust_tbl.NEXT( v_i);
      END LOOP;
      RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
         RETURN;
   END f_get_bndl_cust;


   PROCEDURE p_add_bndl_trans_id
      (i_trans_id     IN hcrs.prfl_prod_bndl_cp_trns_wrk_t.trans_id%TYPE,
       i_trans_cls_cd IN hcrs.prfl_prod_bndl_smry_wrk_t.trans_cls_cd%TYPE,
       i_dllrs_dsc    IN hcrs.prfl_prod_bndl_cp_trns_wrk_t.dllrs_dsc%TYPE,
       i_trans_idx    IN NUMBER := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_add_bndl_trans_id
      *   Input params : i_trans_id - transaction ID
      *                : i_trans_cls_cd - transaction class code
      *                : i_dllrs_dsc - transaction discount dollars
      *                : i_trans_idx - transaction index
      *  Output params : None
      *        Returns : None
      *   Date Created : 05/01/2017
      *         Author : Joe Kidd
      *    Description : Add a trans ID to the current bundled trans list
      *                  Exposed for support when testing hcrs.calc_csr_bndl_adj_v
      *
      *                  NOTE: This procedure should only write to temporary
      *                  tables, so that it can be used during testing/debugging
      *                  in production.  No changes should be made to permanent
      *                  objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Add additional columns, remove error handler
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Correct %TYPE anchors
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            GTT column reduction
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_add_bndl_trans_id';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Add a trans ID to the current bundled trans list';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while adding a trans ID to the current bundled trans list';
   BEGIN
      gv_bndl_trans_ids.EXTEND();
      gv_bndl_trans_ids( gv_bndl_trans_ids.LAST()) :=
         hcrs.bndl_trans_id_rec_typ( i_trans_id,
                                     i_trans_idx,
                                     i_trans_cls_cd,
                                     i_dllrs_dsc);
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_add_bndl_trans_id;


   PROCEDURE p_del_bndl_trans_id
   IS
      /*************************************************************************
      * Procedure Name : p_del_bndl_trans_id
      *   Input params : None
      *  Output params : None
      *        Returns : None
      *   Date Created : 05/01/2017
      *         Author : Joe Kidd
      *    Description : Deletes all current bundled trans IDs
      *                  Exposed for support when testing hcrs.calc_csr_bndl_adj_v
      *
      *                  NOTE: This procedure should only write to temporary
      *                  tables, so that it can be used during testing/debugging
      *                  in production.  No changes should be made to permanent
      *                  objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Remove error handler
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_del_bndl_trans_id';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Deletes all current bundled trans IDs';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while deleting all current bundled trans IDs';
   BEGIN
      gv_bndl_trans_ids.DELETE();
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_del_bndl_trans_id;


   FUNCTION f_get_bndl_trans_ids
      RETURN hcrs.bndl_trans_id_tbl_typ
      PIPELINED
   IS
      /*************************************************************************
      * Function Name : f_get_bndl_trans_ids
      *  Input params : None
      * Output params : None
      *       Returns : Table of the trans IDs for the current transaction
      *  Date Created : 05/01/2017
      *        Author : Joe Kidd
      *   Description : Get the current bundled transaction trans IDs
      *
      *                 Pipelined Table function for use in SQL
      *                 Exposed for support when testing hcrs.calc_csr_bndl_adj_v
      *
      *                 NOTE: This procedure should only write to temporary
      *                 tables, so that it can be used during testing/debugging
      *                 in production.  No changes should be made to permanent
      *                 objects.  Make those changes in p_common_initialize.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Remove error handler
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Add normal exception handling (Calc Debug Mode)
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.f_get_bndl_trans_ids';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Get the current bundled transaction trans IDs';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while getting the current bundled transaction trans IDs';
      v_i                   NUMBER;
   BEGIN
      v_i := gv_bndl_trans_ids.FIRST();
      WHILE v_i IS NOT NULL
      LOOP
         PIPE ROW( gv_bndl_trans_ids( v_i));
         v_i := gv_bndl_trans_ids.NEXT( v_i);
      END LOOP;
      RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
         RETURN;
   END f_get_bndl_trans_ids;


   PROCEDURE p_bndl_trans
      (io_trans_group_tbl IN OUT pkg_common_cursors.t_calc_trans_tbl,
       i_trans_group_ttls IN     t_calc_total_rec)
   IS
      /*************************************************************************
      * Procedure Name : p_bndl_trans
      *   Input params : io_trans_group_tbl - the transaction group (orig + adj)
      *                : i_trans_group_ttls - Dollar/Unit totals for the group
      *  Output params : io_trans_group_tbl - the transaction group (orig + adj)
      *        Returns : None
      *   Date Created : 12/05/2007
      *         Author : Joe Kidd
      *    Description : Applies bundling logic to the passed transaction
      *
      *                  Bundling uses two steps to perform the unbundling.
      *
      *                  Step one generates the bundling summary and audit trail
      *                  for the transactions's customer if the customer has not
      *                  yet been evaluated for bundling impact.
      *
      *                  Step two uses the audit trail built by step one to find
      *                  bundled transactions and apply the unbundled discount.
      *
      *                  Before a source transation can have the bundle calculation
      *                  applied to it, it must meet the following requirements,
      *                  (in this order for performance):
      *
      *                  4.1. The transaction must be a CARS or SAP transaction.
      *                       This implies that no manual adjustments will be
      *                       processed for bundling.
      *                  4.2. The transaction must have a non-zero gross dollar
      *                       value, or the bundle adjustment cannot be applied.
      *                  4.3. The transaction must be used by a component which
      *                       requires either the Net or Discount dollars of the
      *                       transaction for one or more of the following:
      *                       component accumulation, nominal checking, HHS violation
      *                       checking.
      *
      *                  5.2. The transaction's NDC must be in effect on the bundle
      *                       code based on the transaction's earned date.
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  06/16/2008  Joe Kidd      PICC 1927: Main transaction must have a
      *                            non-zero gross dollar amount
      *                            Check if component will use net or discount
      *                            dollars before check for bundle
      *                            Revise for Bundle Conditions
      *  08/22/2008  Joe Kidd      PICC 1961: Add parameter for bundling mode
      *                            Create two bundling modes:
      *                            Mode CFG ids by bundle config, calculates
      *                            bundle percentage, creates bundle audit trail
      *                            Mode TRN ids by the audit trail retrieves and
      *                            applies bundle percentage
      *  07/22/2009  Joe Kidd      RT 267 - CRQ 43432: Bundling Tuning
      *                            Remove seperate Main Transaction in Bundle
      *                            check in both passes
      *                            Remove retrieval of bundle pct in first pass
      *                            Tune csr_bndl_trns_loop query
      *                            Use new VARCHAR2 index for trans type list
      *                            Use count of additional bundled products
      *                            Use Bundle Summary work table
      *  04/26/2010  Joe Kidd      RT 2009-724 - CRQ 46973: Revise Bundling Methodology
      *                            Correct customer condition logic
      *                            Revise bundle application logic
      *  07/19/2010  Joe Kidd      CRQ-48638: Correct Bundling Sign Issue
      *                            Correct Bundling Application Sign Issue
      *  12/01/2010  Joe Kidd      CRQ-931: December 2010 Govt Calculations Release
      *                            Run config and apply on each call
      *                            Remove Bundle mode parameter no longer needed
      *                            csr_bndl_trns_loop should use prfl_prod_bndl_smry_wrk_t
      *                            Add hints to csr_bndl_trns_loop for performance
      *  01/28/2011  Joe Kidd      CRQ-1222: Bundling BP Linking issue
      *                            Check all transactions for CARS Source System
      *                            Check earned/paid date for all transactions
      *  12/13/2011  Joe Kidd      CRQ-10134: Lovenox Omnicare Calcs runnning slow
      *                            Add hints to csr_bndl_trns_loop query
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Add WAC value of packages
      *                            Add global flags to disable bundling steps
      *                            Add domestic/territory fields to component check
      *  11/06/2012  Joe Kidd      CRQ-32007: Correct Product-only Bundle Null Measurement Date Error
      *                            Change index name in csr_bndl_cust_tt hint
      *                            due to index name change
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Change Min/Max dates to match new paid/earned scheme
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Include SAP transactions in bundling processing
      *                            Seperated Component and Transaction dollars constants
      *                            Collect bundling statistics
      *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
      *                            Remove total variables
      *                            Add new bundling control variables
      *                            Correct rebate link double counting issue
      *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
      *                            Replace summary count cursor and bundling
      *                            control variables with cust ID associative array
      *                            Moved bundle adjustment query to
      *                            pkg_common_cursors.csr_bndl_adj_trns
      *                            Only create one adjustment for each of a
      *                            transaction group's transaction classes for
      *                            all related bundle codes
      *                            Check if bundling is enabled here
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters, simplify audit trail process
      *                            Simplify transaction analysis to apply bundle
      *  08/01/2019  JTronoski     CHG-125643: Prompt Pay Disc Change for New Bundle Adjustment
      *                            Set Bundle Adjustment Prompt Pay Dollars to zero
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Correct Nominal/sub-PHS enable/disable
      *                            Move longops rountines and timers to pkg_utils
      *                            Remove GTT delete by customer
      *                            GTT column reduction
      *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
      *                            Add SAP4H to SAP trans rules
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_bndl_trans';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Applies bundling logic to the passed transaction';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while applying bundling logic to the passed transaction';
      v_i                   BINARY_INTEGER;
      v_cust_id             hcrs.prfl_cust_cls_of_trd_t.cust_id%TYPE;

      PROCEDURE p_run_config
         (i_cust_id IN hcrs.prfl_cust_cls_of_trd_t.cust_id%TYPE)
      IS
         v_timer  NUMBER := 0;
      BEGIN
         IF NOT gv_bndl_cust_id_tbl.EXISTS( i_cust_id)
         THEN
            -- Start timer
            pkg_utils.p_timer_start( cs_calc_log_cntr_bndl_cfg_time);
            -- Create the bundle summary and detail records
            p_set_bndl_cust( i_cust_id);
            -- Run config query, load GTT, save customer row count
            gv_bndl_cust_id_tbl( i_cust_id) := pkg_common_cursors.f_ins_bndl_cp_trns();
            -- End timer
            v_timer := pkg_utils.f_timer_stop( cs_calc_log_cntr_bndl_cfg_time);
            -- Commit as needed
            p_commit( gv_bndl_cust_id_tbl( i_cust_id));
            -- Add to counters/timers
            p_set_cntr( cs_calc_log_cntr_bndl_cfg_exec);
            p_set_cntr( cs_calc_log_cntr_bndl_cfg_rows, gv_bndl_cust_id_tbl( i_cust_id));
            p_set_cntr( cs_calc_log_cntr_bndl_cfg_time, v_timer);
            p_set_cntr( cs_calc_log_cntr_bndl_cust_cnt);
         END IF;
      END p_run_config;

      PROCEDURE p_create_audit_trail
      IS
         v_i                   BINARY_INTEGER;
         v_orig_cust_id        hcrs.prfl_cust_cls_of_trd_t.cust_id%TYPE;
      BEGIN
         -----------------------------------------------------------------------
         -- first step, create the bundle audit trail
         -----------------------------------------------------------------------
         -- Run config query
         p_run_config( v_cust_id);
         -----------------------------------------------------------------------
         -- ORIG customers
         -- Loop through every row in the transaction
         -- Load bundling for orig customer IDs for ICW_KEY rebates
         v_i := io_trans_group_tbl.FIRST();
         WHILE v_i IS NOT NULL
         LOOP
            v_orig_cust_id := io_trans_group_tbl( v_i).orig_cust_id;
            -- If the original customer is different from the main customer
            -- and it is a RMUS/CARS customer
            -- and it has not already been loaded into the GTT
            -- and the transaction is an SAP or RMUS/CARS transaction
            IF     v_orig_cust_id <> v_cust_id
               AND v_orig_cust_id LIKE '%' || pkg_constants.cs_cust_cars
               AND io_trans_group_tbl( v_i).source_sys_cde IN (pkg_constants.cs_system_cars,
                                                               pkg_constants.cs_system_sap,
                                                               pkg_constants.cs_system_sap4h)
            THEN
               -- Run config query
               p_run_config( v_orig_cust_id);
            END IF;
            -- Get next row
            v_i := io_trans_group_tbl.NEXT( v_i);
         END LOOP;
      END p_create_audit_trail;

      PROCEDURE p_create_adjustments
      IS
         v_i                   BINARY_INTEGER;                                     -- loop index
         v_j                   BINARY_INTEGER;                                     -- transaction table key
         v_trans_cls_bndl_tbl  t_trans_cls_bndl_tbl;                               -- Totals by Trans Classes and Bundle Codes
         v_trans_cls_bndl_key  VARCHAR2( 100);                                     -- Trans Class/Bundle Code Grouping Key
         v_tc_dsc_pct          hcrs.prfl_prod_bndl_smry_wrk_t.prcg_dllrs_dsc%TYPE; -- Transaction Class Discount percentage
         v_tc_dsc_pct_abs      hcrs.prfl_prod_bndl_smry_wrk_t.prcg_dllrs_dsc%TYPE; -- Absolute Value of Transaction Class Discount percentage
         v_diff_dsc_pct        hcrs.prfl_prod_bndl_smry_wrk_t.prcg_dllrs_dsc%TYPE; -- Difference between bundle disc pct and trans disc pct
         v_diff_dsc_amt        hcrs.prfl_prod_bndl_smry_wrk_t.prcg_dllrs_dsc%TYPE; -- Dollars diff amount to apply
         v_cnt                 NUMBER;
      BEGIN
         -----------------------------------------------------------------------
         -- second step, create adjustments from bundle audit trail
         -----------------------------------------------------------------------
         IF     gv_bndl_cust_id_tbl.EXISTS( v_cust_id)
            AND gv_bndl_cust_id_tbl( v_cust_id) > 0
         THEN
            -- Customer has bundles
            -- Clear bundled transactions list and last trans class
            p_del_bndl_trans_id();
            -----------------------------------------------------------------------
            -- Loop through every row in the transaction
            -- Process the lines for the bundle
            v_i := io_trans_group_tbl.FIRST();
            WHILE v_i IS NOT NULL
            LOOP
               IF io_trans_group_tbl( v_i).source_sys_cde IN (pkg_constants.cs_system_cars,
                                                              pkg_constants.cs_system_sap,
                                                              pkg_constants.cs_system_sap4h)
               THEN
                  -- 4.1. The transaction must be a CARS or SAP transaction.
                  --      This implies that no manual adjustments will be
                  --      processed for bundling.
                  -- 4.4. The customer ID must be a CARS customer ID.
                  -- Load the transaction with its discount dollars
                  p_add_bndl_trans_id
                     (io_trans_group_tbl( v_i).trans_id,
                      io_trans_group_tbl( v_i).trans_cls_cd,
                      io_trans_group_tbl( v_i).dllrs_dsc,
                      v_i);
               END IF;
               -- Get next row
               v_i := io_trans_group_tbl.NEXT( v_i);
            END LOOP;
            -----------------------------------------------------------------------
            -- Retrieve the transaction class bundle discount percentages
            IF gv_bndl_trans_ids.COUNT() > 0
            THEN
               -----------------------------------------------------------------
               -- Find the total gross dollars and total discount dollars of
               -- all the unique transactions that have been identified as
               -- bundled with this transaction.
               v_cnt := 0;
               pkg_utils.p_timer_start( cs_calc_log_cntr_bndl_adj_time);
               FOR v_ttl IN
                 (
                  SELECT /*+ p_bndl_trans_bndl_adj
                             DYNAMIC_SAMPLING( 0 )
                         */
                         ccba.trans_cls_cd,
                         ccba.bndl_cd,
                         ccba.min_trans_idx,
                         ccba.trans_dllrs_dsc,
                         ccba.dllrs_grs,
                         ccba.dllrs_dsc,
                         ccba.dsc_pct
                    FROM hcrs.calc_csr_bndl_adj_v ccba
                 )
               LOOP
                  -- Add to list of transaction class bundles for
                  -- which an adjustment must be made
                  v_trans_cls_bndl_key := v_ttl.trans_cls_cd || '-' || v_ttl.bndl_cd;
                  v_trans_cls_bndl_tbl( v_trans_cls_bndl_key).bndl_cd := v_ttl.bndl_cd;
                  v_trans_cls_bndl_tbl( v_trans_cls_bndl_key).trans_idx := v_ttl.min_trans_idx;
                  v_trans_cls_bndl_tbl( v_trans_cls_bndl_key).trans_dllrs_dsc := v_ttl.trans_dllrs_dsc;
                  v_trans_cls_bndl_tbl( v_trans_cls_bndl_key).dsc_pct := v_ttl.dsc_pct;
                  v_cnt := v_cnt + 1;
               END LOOP;
               p_set_cntr( cs_calc_log_cntr_bndl_adj_time, pkg_utils.f_timer_stop( cs_calc_log_cntr_bndl_adj_time));
               p_set_cntr( cs_calc_log_cntr_bndl_adj_rows, v_cnt);
               p_set_cntr( cs_calc_log_cntr_bndl_adj_exec);
            END IF;
            -----------------------------------------------------------------------
            -- Apply the bundle percentages and create the adjustments
            v_trans_cls_bndl_key := v_trans_cls_bndl_tbl.FIRST();
            WHILE v_trans_cls_bndl_key IS NOT NULL
            LOOP
               IF v_trans_cls_bndl_tbl( v_trans_cls_bndl_key).trans_dllrs_dsc = 0
               THEN
                  -- This can be zero for multiple bundle codes for a transaction class
                  -- First bundle code actually performs the adjustment
                  -- Second and later add a zero adjustment just to capture the
                  -- bundle code in the audit trail
                  v_diff_dsc_amt := 0;
               ELSE
                  -- only adjust when the discount dollars are not equal to zero
                  --------------------------------------------------------------
                  -- Calculate the difference between the transaction discount
                  -- percentage and the bundle percentage
                  -- NOTE: When gross dollars is zero the transaction's percentage
                  -- cannot be calculated.  This usually means the transaction was
                  -- backed out.  Main procedure prevents this by ignoring the trans.
                  --------------------------------------------------------------
                  -- Get the Transaction's Average Discount
                  v_tc_dsc_pct := v_trans_cls_bndl_tbl( v_trans_cls_bndl_key).trans_dllrs_dsc / i_trans_group_ttls.dllrs_grs;
                  -- Get the Absolute Value of the Transaction Type's Average Discount
                  v_tc_dsc_pct_abs := ABS( v_tc_dsc_pct);
                  --------------------------------------------------------------
                  -- Get Discount Percent Difference as the difference between
                  -- the Unbundled Average Discount and the Absolute Value of the
                  -- Transaction Type's Average Discount
                  v_diff_dsc_pct := v_trans_cls_bndl_tbl( v_trans_cls_bndl_key).dsc_pct - v_tc_dsc_pct_abs;
                  --------------------------------------------------------------
                  -- Get Discount Amount Difference by applying Discount Percent
                  -- Difference to the Gross Dollars and adjusting for the sign
                  -- of the Transaction Type's Average Discount
                  v_diff_dsc_amt := i_trans_group_ttls.dllrs_grs * v_diff_dsc_pct * SIGN( v_tc_dsc_pct);
               END IF;
               --------------------------------------------------------------
               -- Add a bundle adjustment row to the transaction list
               v_j := io_trans_group_tbl.COUNT() + 1;
               io_trans_group_tbl( v_j) := io_trans_group_tbl( v_trans_cls_bndl_tbl( v_trans_cls_bndl_key).trans_idx);
               -- Set dollars and units
               io_trans_group_tbl( v_j).dllrs_grs := 0;
               io_trans_group_tbl( v_j).dllrs_wac := 0;
               io_trans_group_tbl( v_j).dllrs_net := v_diff_dsc_amt * -1;
               io_trans_group_tbl( v_j).dllrs_dsc := v_diff_dsc_amt;
               io_trans_group_tbl( v_j).dllrs_ppd := 0;
               io_trans_group_tbl( v_j).pkgs := 0;
               io_trans_group_tbl( v_j).units := 0;
               -- Mark as a bundle adjustment
               io_trans_group_tbl( v_j).root_trans_id := io_trans_group_tbl( io_trans_group_tbl.FIRST()).trans_id;
               io_trans_group_tbl( v_j).parent_trans_id := io_trans_group_tbl( v_trans_cls_bndl_tbl( v_trans_cls_bndl_key).trans_idx).trans_id;
               io_trans_group_tbl( v_j).trans_adj_cd := pkg_constants.cs_trans_adj_bndl_adj;
               -- Add the Bundle code
               io_trans_group_tbl( v_j).bndl_cd := v_trans_cls_bndl_tbl( v_trans_cls_bndl_key).bndl_cd;
               -- Track number of bundling adjustments made
               gv_bndl_adj_cnt := gv_bndl_adj_cnt + 1;
               v_trans_cls_bndl_key := v_trans_cls_bndl_tbl.NEXT( v_trans_cls_bndl_key);
            END LOOP;
         END IF;
      END p_create_adjustments;

   BEGIN
      -- If bundling is on, apply it (only affects dollars)
      IF     gv_bndl_trans
         AND (   gv_bndl_use_dra_prod
              OR gv_bndl_use_dra_time)
      THEN
         v_i := io_trans_group_tbl.FIRST();
         v_cust_id := io_trans_group_tbl( v_i).cust_id;
         -- 4.2. The transaction must have a non-zero gross dollar
         --      value and non-zero discount dollar value, or the
         --      bundle adjustment cannot be applied.
         IF     i_trans_group_ttls.dllrs_grs <> 0
            AND i_trans_group_ttls.dllrs_dsc <> 0
            -- 4.1. The transaction must be a CARS or SAP transaction.
            --      This implies that no manual adjustments will be
            --      processed for bundling.
            AND io_trans_group_tbl( v_i).bndl_src_sys_ind = pkg_constants.cs_flag_yes
            -- 4.3. The transaction must be used by a component which
            --      requires either the Net or Discount dollars of the
            --      transaction for one or more of the following:
            --      component accumulation, nominal checking, HHS violation
            --      checking.
            AND (   io_trans_group_tbl( v_i).bndl_comp_tran_ind = pkg_constants.cs_flag_yes
                 OR (    io_trans_group_tbl( v_i).bndl_comp_nom_ind = pkg_constants.cs_flag_yes
                     AND gv_param_rec.chk_nom = pkg_constants.cs_flag_yes)
                 OR (    io_trans_group_tbl( v_i).bndl_comp_hhs_ind = pkg_constants.cs_flag_yes
                     AND gv_param_rec.chk_hhs = pkg_constants.cs_flag_yes)
                )
            -- 4.4. The customer ID must be a CARS customer ID.
            AND v_cust_id LIKE '%' || pkg_constants.cs_cust_cars
            -- 5.2. The transaction's NDC must be in effect on the bundle
            --      code based on the transaction's earned date.
            AND io_trans_group_tbl( v_i).bndl_prod = pkg_constants.cs_flag_yes
         THEN
            p_set_cntr( cs_calc_log_cntr_bndl_trn_rows, io_trans_group_tbl.COUNT());
            IF gv_bndl_config
            THEN
               -- Calculate the bundle, create the audit trail
               p_create_audit_trail;
            END IF;
            IF gv_bndl_apply
            THEN
               -- Create the bundle adjustments
               p_create_adjustments;
            END IF;
         END IF; -- product is a bundled product
      END IF; -- bundling is on
      -- Done
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_bndl_trans;


   PROCEDURE p_trans_rollup_loop
      (i_calc_log_user_msg IN     hcrs.prfl_prod_t.user_msg_txt%TYPE,
       i_calc_log_comp_cd  IN     hcrs.prfl_prod_calc_log_t.comp_typ_cd%TYPE,
       io_calc_trans_csr   IN OUT pkg_common_cursors.t_calc_trans_ref_csr)
   IS
      /*************************************************************************
      * Procedure Name : p_trans_rollup_loop
      *   Input params : i_calc_log_user_msg - Calc Log User Message
      *                : i_calc_log_comp_cd - Calc Log Component code
      *                : io_calc_trans_csr - ref cursor to process
      *  Output params : io_calc_trans_csr - ref cursor to process
      *        Returns : None
      *   Date Created : 02/13/2004
      *         Author : Joe Kidd
      *    Description : Performs the transaction rollup loop for calculations
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  07/14/2004  M. Gedzior    PICC 1264: In the ICW Key related credits logic
      *                            added AMP calls similar to NFAMP section
      *  11/01/2004  Joe Kidd      PICC 1327: Calc Cursor Tuning
      *                            Add calc processing start and end event timings
      *  02/01/2005  Joe Kidd      PICC 1372, 1373, 1374:
      *                            Restructure p_trans_rollup to simplify logic
      *                            Restructure p_trans_rollup to use bulk collect
      *                            Added trans_typ_ord field to bulk collect
      *                            Use new calc cursor names
      *  06/12/2006  Joe Kidd      PICC 1557: Change nominal amount processing
      *                            Don't accumulate nominal amount adjustments
      *                            for Rebate/Fee and Related Credit lookups
      *  12/13/2006  Joe Kidd      PICC 1680: Pass Prompt Pay Discount to calc
      *                            Add fields to v_calc_rec
      *                            Perform SAP adjustment lookup recursively
      *                            Remove calls to calc specific cursors
      *  05/18/2007  Joe Kidd      PICC 1769: Renamed from p_trans_rollup_loop2
      *                            Removed unneeded fields
      *                            Add lgcy_trans_line_no types and fields
      *                            Rebate/Fee Rollup Accumulation
      *  12/05/2007  Joe Kidd      PICC 1763: Obey Lookup cursor flags
      *                            Added transaction type, split percentage type
      *                            Change Lookup queries into static cursors
      *                            Call p_splt_trns instead of p_prcss_trans to
      *                            apply split percentages
      *  04/22/2008  Joe Kidd      PICC 1865: Add new fields for bundling
      *                            Add call to bundling procedure
      *  08/22/2008  Joe Kidd      PICC 1961: Add parameter for bundling mode
      *  08/07/2008  Joe Kidd      PICC 1950: Add assc_invc_dt
      *                            Add new SAP adjustment logic
      *  05/06/2009  Joe Kidd      PICC 2051: Add linking of X360 lines and adjs
      *  06/22/2009  Joe Kidd      RT 458 - CRQ 29045 - IS-000000000355
      *                            Rename internal proc p_accum_trans to p_add_trans
      *                            Add calc log entry for first record fetch
      *  04/01/2010  Joe Kidd      RT 372 - CRQ 43435 - IS-000000000018
      *                            Add Prasco rollup and Rebate/Fee processing
      *  04/26/2010  Joe Kidd      RT 2009-724 - CRQ 46973: Revise Bundling Methodology
      *                            Lookup Prasco Rebate/Fee only once
      *                            Rollup Prasco Chargebacks/Rebate/Fee by line number
      *  12/01/2010  Joe Kidd      CRQ-931: December 2010 Govt Calculations Release
      *                            Add longops for to calc log calls
      *                            Remove Bundle mode parameter no longer needed
      *  01/28/2011  Joe Kidd      CRQ-1222: Bundling BP Linking issue
      *                            Removed earnd_dt from cursor output
      *  01/28/2011  Joe Kidd      CRQ-1412: Winthrop Chargeback-Rebate linking
      *                            ICW_KEY Rebate must be on same contract as sale
      *  04/01/2011  Joe Kidd      CRQ-3921: Linking of CARS chargebacks
      *                            Add and use root lgcy trans no during linking
      *                            Reorder cursor fields
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Add WAC value of packages
      *                            Add domestic/territory fields
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Prevent duplicate adjustments
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Update for calc cursor changes
      *                            Only link transactions when earned dates are used
      *                            Add customer ID to SAP cursors
      *  04/11/2013  Joe Kidd      CRQ-45044: Adjust GP Smoothing
      *                            Disable bundling on second pass if no bundling
      *                            summaries are found
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Add component description for user message
      *                            Carry and process prompt pay dollars seperately
      *                            Simplify bulk collections
      *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
      *                            Remove total variables
      *                            Relax SAP adjustment lookup by Tran Type Group
      *                            Allow to find RBT/FEE SAP adjustments when
      *                            rebate/fee lookup is on
      *  05/25/2016  Joe Kidd      CRQ-266675: Demand 3336 AMP Final Rule (June Release)
      *                            Limit trans linking to same supergroup
      *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
      *                            Calc Log adds formatted counts to user message
      *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
      *                            Control log updates by time intervals
      *                            Remove bundle statistics update
      *                            Move check if bundling enabled to bundling proc
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Completely rewritten for new main cursor output
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Add calc log parameters
      *                            Use updated calc log procedures
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Move longops rountines and timers to pkg_utils
      *                            Correct handling of ICW_KEY and other links
      *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
      *                            Add SAP4H to SAP trans rules
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_trans_rollup_loop';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Performs the transaction rollup loop for calculations';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while performing the transaction rollup loop for calculations';
      v_trans_fetch_tbl             pkg_common_cursors.t_calc_trans_tbl; -- All transactions from last fetch
      v_trans_curr_rec              pkg_common_cursors.t_calc_trans_rec; -- Current transaction being examined
      v_trans_last_rec              pkg_common_cursors.t_calc_trans_rec; -- Last transaction that was examined
      v_trans_group_all_tbl         pkg_common_cursors.t_calc_trans_tbl; -- All transactions for transaction group
      v_trans_group_ttls            t_calc_total_rec;
      v_root_trans_id               hcrs.mstr_trans_t.trans_id%TYPE;
      v_parent_trans_id             hcrs.mstr_trans_t.trans_id%TYPE;
      v_root_trans_grp              NUMBER;
      v_parent_trans_grp            NUMBER;
      v_trans_grp                   NUMBER;
      v_sale_exists_flg             BOOLEAN := FALSE;
      v_icw_key_exists_flg          BOOLEAN := FALSE;
      v_first_sap_is_adj_flg        BOOLEAN := FALSE;
      v_c                           BINARY_INTEGER;
      v_total_rows                  NUMBER;

      PROCEDURE p_start_new_trans_group
      IS
      BEGIN
         IF NOT gv_cust_id_tbl.EXISTS( v_trans_curr_rec.cust_id)
         THEN
            -- Register new customer
            gv_cust_id_tbl( v_trans_curr_rec.cust_id) := 0;
            p_set_cntr( cs_calc_log_cntr_custs);
            p_set_cntr( cs_calc_log_cntr_cust_rows, 0, -1); -- reset to zero, use same counter
         END IF;
         -- Increment customer transaction count
         gv_cust_id_tbl( v_trans_curr_rec.cust_id) := gv_cust_id_tbl( v_trans_curr_rec.cust_id) + 1;
         p_set_cntr( cs_calc_log_cntr_cust_rows);
         -- if group starts with direct sale or indirect sale,
         -- subsequent rebates only accumulate discount
         v_sale_exists_flg := (v_trans_curr_rec.trans_cls_cd IN (pkg_constants.cs_trans_cls_dir,
                                                                 pkg_constants.cs_trans_cls_idr));
         -- if group starts with an ICW_KEY rebate subsequent rebates only accumulate discount
         v_icw_key_exists_flg := (v_trans_curr_rec.parent_trans_id_icw_key IS NOT NULL);
         -- if group starts with an adjustment transaction, first trans group are rollups
         v_first_sap_is_adj_flg := (     v_trans_curr_rec.source_sys_cde IN (pkg_constants.cs_system_sap,
                                                                             pkg_constants.cs_system_sap4h)
                                     AND (   v_trans_curr_rec.trans_id <> v_trans_curr_rec.parent_trans_id
                                          OR v_trans_curr_rec.trans_id <> v_trans_curr_rec.root_trans_id
                                         )
                                   );
         -- First trans is original and sets root/parent trans id
         v_trans_curr_rec.root_trans_id := v_trans_curr_rec.trans_id;
         v_trans_curr_rec.parent_trans_id := v_trans_curr_rec.trans_id;
         v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_original;
         -- Get root/parent trans id, parent group number
         v_root_trans_id := v_trans_curr_rec.root_trans_id;
         v_parent_trans_id := v_trans_curr_rec.parent_trans_id;
         -- Get parent trans group numbers
         --   Root group - transaction linking
         --   Parent group - manages parent trans id and rebate units/gross dollars
         --   Trans group - manages rebate units/gross dollars
         v_root_trans_grp := v_trans_curr_rec.root_trans_grp;
         v_parent_trans_grp := v_trans_curr_rec.parent_trans_grp;
         v_trans_grp := v_trans_curr_rec.trans_grp;
         -- Store the current transaction info
         -- All dollars/units remain intact
         v_trans_last_rec := v_trans_curr_rec;
         v_trans_group_all_tbl.DELETE();
         v_trans_group_all_tbl( 1) := v_trans_curr_rec;
         -- Capture total dollars/units
         v_trans_group_ttls.trans_cls_cd := v_trans_curr_rec.trans_cls_cd;
         v_trans_group_ttls.source_sys_cde := v_trans_curr_rec.source_sys_cde;
         v_trans_group_ttls.dllrs_grs := NVL( v_trans_curr_rec.dllrs_grs, 0);
         v_trans_group_ttls.dllrs_wac := NVL( v_trans_curr_rec.dllrs_wac, 0);
         v_trans_group_ttls.dllrs_net := NVL( v_trans_curr_rec.dllrs_net, 0);
         v_trans_group_ttls.dllrs_dsc := NVL( v_trans_curr_rec.dllrs_dsc, 0);
         v_trans_group_ttls.dllrs_ppd := NVL( v_trans_curr_rec.dllrs_ppd, 0);
         v_trans_group_ttls.pkgs := NVL( v_trans_curr_rec.pkgs, 0);
         v_trans_group_ttls.units := NVL( v_trans_curr_rec.units, 0);
      END p_start_new_trans_group;

      PROCEDURE p_add_to_trans_group
      IS
      BEGIN
         -- Increment customer transaction count
         gv_cust_id_tbl( v_trans_curr_rec.cust_id) := gv_cust_id_tbl( v_trans_curr_rec.cust_id) + 1;
         p_set_cntr( cs_calc_log_cntr_cust_rows);
         -- Increment linked transaction count
         p_set_cntr( cs_calc_log_cntr_links);
         -- Rebates only accumulate discount when a sale exists, or when
         -- the parent trans group is same and the trans grp > 1 or if
         -- the first trans was an ICW key, the trans grp > 1
         -- Reset dollar/unit values for rebates added to previous sales
         IF     v_trans_curr_rec.trans_cls_cd = pkg_constants.cs_trans_cls_rbt
            AND (   v_sale_exists_flg
                 OR (    v_trans_curr_rec.parent_trans_grp = v_parent_trans_grp
                     AND (   v_trans_curr_rec.trans_ord > 1
                          OR (    v_icw_key_exists_flg
                              AND v_trans_curr_rec.trans_grp > 1
                             )
                          --OR NVL( v_trans_curr_rec.lgcy_trans_line_no, -1) <> NVL( v_trans_last_rec.lgcy_trans_line_no, -1) -- nulls equal
                         )
                    )
                )
         THEN
            -- Rebates only add discount when the line numbers on the group matches
            -- (rebate or fee paid on the same units as previous row)
            -- Only apply the discount - no gross or pkgs/units
            v_trans_curr_rec.dllrs_grs := 0;
            v_trans_curr_rec.dllrs_wac := 0;
            v_trans_curr_rec.dllrs_net := v_trans_curr_rec.dllrs_dsc * -1;
            v_trans_curr_rec.dllrs_ppd := 0;
            v_trans_curr_rec.pkgs := 0;
            v_trans_curr_rec.units := 0;
         END IF;
         -- Reset root trans_id
         v_trans_curr_rec.root_trans_id := v_root_trans_id;
         -- Set Parent trans_id based on parent trans group
         IF v_parent_trans_grp <> v_trans_curr_rec.parent_trans_grp
         THEN
            v_parent_trans_grp := v_trans_curr_rec.parent_trans_grp;
            v_parent_trans_id := v_trans_curr_rec.parent_trans_id;
         ELSE
            v_trans_curr_rec.parent_trans_id := v_parent_trans_id;
         END IF;
         -- Set trans group
         IF v_trans_grp <> v_trans_curr_rec.trans_grp
         THEN
            v_trans_grp := v_trans_curr_rec.trans_grp;
         END IF;
         -- Capture the transaction linking info for this transaction
         CASE
            WHEN v_trans_curr_rec.trans_adj_cd = pkg_constants.cs_trans_adj_estimate
            THEN
               -- Estimate rows do not change
               NULL;
            --------------------------------------------------------------------
            -- CARS Rebate Linking
            --------------------------------------------------------------------
            -- CARS ICW_KEY Rebate linked to sale (any level) is an ICW_KEY
            WHEN v_trans_curr_rec.source_sys_cde = pkg_constants.cs_system_cars
             AND v_trans_curr_rec.trans_cls_cd = pkg_constants.cs_trans_cls_rbt
             AND v_trans_curr_rec.parent_trans_id_icw_key IS NOT NULL
             AND v_sale_exists_flg
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_icw_key;
            -- CARS ICW_KEY Rebate not linked to sale is a rollup
            WHEN v_trans_curr_rec.source_sys_cde = pkg_constants.cs_system_cars
             AND v_trans_curr_rec.trans_cls_cd = pkg_constants.cs_trans_cls_rbt
             AND v_trans_curr_rec.parent_trans_id_icw_key IS NOT NULL
             AND NOT v_sale_exists_flg
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_cars_rollup;
               v_trans_curr_rec.parent_trans_id := v_root_trans_id;
            -- CARS Rebate linked to sale (any level) is a RBT/FEE
            WHEN v_trans_curr_rec.source_sys_cde = pkg_constants.cs_system_cars
             AND v_trans_curr_rec.trans_cls_cd = pkg_constants.cs_trans_cls_rbt
             AND v_sale_exists_flg
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_cars_rbt_fee;
            -- CARS Rebates marked as originals are rollups
            -- CARS Rebate without assoc invc are rollups
            WHEN v_trans_curr_rec.source_sys_cde = pkg_constants.cs_system_cars
             AND v_trans_curr_rec.trans_cls_cd = pkg_constants.cs_trans_cls_rbt
             AND v_trans_curr_rec.assc_invc_no IS NULL
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_cars_rollup;
               v_trans_curr_rec.parent_trans_id := v_root_trans_id;
            -- Otherwise CARS Rebates are adjustments
            WHEN v_trans_curr_rec.source_sys_cde = pkg_constants.cs_system_cars
             AND v_trans_curr_rec.trans_cls_cd = pkg_constants.cs_trans_cls_rbt
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_cars_adj;
               v_trans_curr_rec.parent_trans_id := v_root_trans_id;
            --------------------------------------------------------------------
            -- CARS Indirect Linking
            --------------------------------------------------------------------
            -- CARS Indirects marked Original are rollups
            WHEN v_trans_curr_rec.source_sys_cde = pkg_constants.cs_system_cars
             AND v_trans_curr_rec.trans_cls_cd = pkg_constants.cs_trans_cls_idr
             AND v_trans_curr_rec.trans_adj_cd = pkg_constants.cs_trans_adj_original
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_cars_rollup;
               v_trans_curr_rec.parent_trans_id := v_root_trans_id;
            -- CARS Indirect without assoc invc are rollups
            WHEN v_trans_curr_rec.source_sys_cde = pkg_constants.cs_system_cars
             AND v_trans_curr_rec.trans_cls_cd = pkg_constants.cs_trans_cls_idr
             AND v_trans_curr_rec.assc_invc_no IS NULL
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_cars_rollup;
            -- Otherwise CARS Indirects are adjustments
            WHEN v_trans_curr_rec.source_sys_cde = pkg_constants.cs_system_cars
             AND v_trans_curr_rec.trans_cls_cd = pkg_constants.cs_trans_cls_idr
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_cars_adj;
            --------------------------------------------------------------------
            -- SAP/SAP4H Linking
            --------------------------------------------------------------------
            -- SAP/SAP4H marked as original, or first in parent group, or first parent
            -- group when first invoice is an adjustment
            WHEN v_trans_curr_rec.source_sys_cde IN (pkg_constants.cs_system_sap,
                                                     pkg_constants.cs_system_sap4h)
             AND (   v_trans_curr_rec.trans_adj_cd = pkg_constants.cs_trans_adj_original
                  OR v_trans_curr_rec.trans_grp = 1
                  OR (    v_first_sap_is_adj_flg
                      AND v_trans_curr_rec.parent_trans_grp = 1
                     )
                 )
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_sap_rollup;
               v_trans_curr_rec.parent_trans_id := v_root_trans_id;
            -- Otherwise SAP is an adjustment
            WHEN v_trans_curr_rec.source_sys_cde IN (pkg_constants.cs_system_sap,
                                                     pkg_constants.cs_system_sap4h)
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_sap_adj;
            --------------------------------------------------------------------
            -- X360 Rebate Linking
            --------------------------------------------------------------------
            -- X360 Rebate Originals are rollups
            -- X360 Rebate marked as Original is a rollup
            WHEN v_trans_curr_rec.source_sys_cde = pkg_constants.cs_system_x360
             AND v_trans_curr_rec.trans_cls_cd = pkg_constants.cs_trans_cls_rbt
             AND (   v_trans_curr_rec.trans_adj_cd = pkg_constants.cs_trans_adj_original
                  OR v_trans_curr_rec.assc_invc_no IS NULL
                  OR v_trans_curr_rec.trans_grp = 1
                 )
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_x360_rollup;
               v_trans_curr_rec.parent_trans_id := v_root_trans_id;
            -- Otherwise X360 Rebates are adjustments
            WHEN v_trans_curr_rec.source_sys_cde = pkg_constants.cs_system_x360
             AND v_trans_curr_rec.trans_cls_cd = pkg_constants.cs_trans_cls_rbt
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_x360_adj;
            --------------------------------------------------------------------
            -- Prasco Linking
            --------------------------------------------------------------------
            -- Prasco Rebate linked to sale (any level) is a RBT/FEE
            WHEN v_trans_curr_rec.source_sys_cde = pkg_constants.cs_system_prasco
             AND v_trans_curr_rec.trans_cls_cd = pkg_constants.cs_trans_cls_rbt
             AND v_sale_exists_flg
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_prasco_rbtfee;
            -- otherwise Prasco uses rollup
            WHEN v_trans_curr_rec.source_sys_cde = pkg_constants.cs_system_prasco
            THEN
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_prasco_rollup;
            --------------------------------------------------------------------
            -- Other Linking
            --------------------------------------------------------------------
            -- All others only use rollup
            ELSE
               v_trans_curr_rec.trans_adj_cd := pkg_constants.cs_trans_adj_rollup;
         END CASE;
         -- Add the transaction to the transaction group
         v_trans_group_all_tbl( v_trans_group_all_tbl.COUNT() + 1) := v_trans_curr_rec;
         v_trans_last_rec := v_trans_curr_rec;
         -- Capture total dollars/units
         v_trans_group_ttls.dllrs_grs := v_trans_group_ttls.dllrs_grs + NVL( v_trans_curr_rec.dllrs_grs, 0);
         v_trans_group_ttls.dllrs_wac := v_trans_group_ttls.dllrs_wac + NVL( v_trans_curr_rec.dllrs_wac, 0);
         v_trans_group_ttls.dllrs_net := v_trans_group_ttls.dllrs_net + NVL( v_trans_curr_rec.dllrs_net, 0);
         v_trans_group_ttls.dllrs_dsc := v_trans_group_ttls.dllrs_dsc + NVL( v_trans_curr_rec.dllrs_dsc, 0);
         v_trans_group_ttls.dllrs_ppd := v_trans_group_ttls.dllrs_ppd + NVL( v_trans_curr_rec.dllrs_ppd, 0);
         v_trans_group_ttls.pkgs := v_trans_group_ttls.pkgs + NVL( v_trans_curr_rec.pkgs, 0);
         v_trans_group_ttls.units := v_trans_group_ttls.units + NVL( v_trans_curr_rec.units, 0);
      END p_add_to_trans_group;

      PROCEDURE p_process_trans_group
      IS
      BEGIN
         -- Only process when there is something to process
         IF v_trans_group_all_tbl.COUNT() > 0
         THEN
            --------------------------------------------------------------
            -- If CARS rebate has no discount, ignore all values
            --------------------------------------------------------------
            IF     v_trans_group_ttls.trans_cls_cd = pkg_constants.cs_trans_cls_rbt
               AND v_trans_group_ttls.source_sys_cde = pkg_constants.cs_system_cars
               AND v_trans_group_ttls.dllrs_grs <> 0
               AND v_trans_group_ttls.dllrs_dsc = 0
            THEN
               -- A CARS rebate with no discount implies that no sale occurred.
               -- This can be a no-pay price group or a correction that nets to zero.
               v_trans_group_ttls.dllrs_grs := 0;
               v_trans_group_ttls.dllrs_wac := 0;
               v_trans_group_ttls.dllrs_net := 0;
               v_trans_group_ttls.dllrs_ppd := 0;
               v_trans_group_ttls.pkgs := 0;
               v_trans_group_ttls.units := 0;
            END IF;
            ----------------------------------------------------------
            -- process the transaction as needed and process all parts
            ----------------------------------------------------------
            -- Adjust for Bundling
            p_bndl_trans( v_trans_group_all_tbl, v_trans_group_ttls);
            -- Accumulate the transaction
            p_accum_trans( v_trans_group_all_tbl, v_trans_group_ttls);
         END IF;
      END p_process_trans_group;

   BEGIN
      --------------------------------------------------------------------------
      -- Set Log interval seconds for performance
      --------------------------------------------------------------------------
      gv_calc_log_update_interval := 5;
      -- Initialize longops counters
      p_init_cntrs();
      LOOP
         --------------------------------------------------------------------------
         -- Begin Bulk Collect Fetch Loop
         --------------------------------------------------------------------------
         -- Bulk collect n records into a record of tables
         FETCH io_calc_trans_csr BULK COLLECT
          INTO v_trans_fetch_tbl
         LIMIT pkg_constants.cs_bulk_row_count;
         --------------------------------------------------------------------------
         -- Get starting record index
         --------------------------------------------------------------------------
         v_c := v_trans_fetch_tbl.FIRST();
         --------------------------------------------------------------------------
         -- Get total rows from first row of first fetch, init logging
         --------------------------------------------------------------------------
         IF v_total_rows IS NULL
         THEN
            IF v_c IS NOT NULL
            THEN
               v_total_rows := v_trans_fetch_tbl( v_c).csr_cnt;
            ELSE
               v_total_rows := 0;
            END IF;
            -- Initialize main counters
            p_set_cntr( cs_calc_log_cntr_rows, 0, v_total_rows, i_calc_log_comp_cd);
            p_set_cntr( cs_calc_log_cntr_rows_marked, 0, 0);
            p_set_cntr( cs_calc_log_cntr_custs, 0, 0);
            p_set_cntr( cs_calc_log_cntr_links, 0, 0);
            p_set_cntr( cs_calc_log_cntr_cust_rows, 0, 0);
            p_set_cntr( cs_calc_log_cntr_cust_rows_max, 0, 0);
            -- Inititialize customer and customer row counts
            gv_cust_id_tbl.DELETE();
            gv_mark_cust_row_cnt_max := 0;
            -- Log first batch as zero
            p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd, i_calc_log_user_msg, i_calc_log_comp_cd);
         END IF;
         WHILE v_c IS NOT NULL
         LOOP
            --------------------------------------------------------------------------
            -- Begin Trans Processing Loop
            --------------------------------------------------------------------------
            -- Get the current record
            v_trans_curr_rec := v_trans_fetch_tbl( v_c);
            -- Assemble the transaction group
            IF v_trans_curr_rec.root_trans_grp = v_root_trans_grp
            THEN
               -- The current transaction matches the current transaction group
               p_add_to_trans_group;
            ELSE
               -- The current transaction does not match the current transaction group
               -- or there is no current transaction group (first row fetched)
               p_process_trans_group;
               p_start_new_trans_group;
            END IF;
            -- Set Max customer row count
            IF gv_cust_id_tbl( v_trans_curr_rec.cust_id) > gv_mark_cust_row_cnt_max
            THEN
               p_set_cntr( cs_calc_log_cntr_cust_rows_max, (gv_cust_id_tbl( v_trans_curr_rec.cust_id) - gv_mark_cust_row_cnt_max));
               gv_mark_cust_row_cnt_max := gv_cust_id_tbl( v_trans_curr_rec.cust_id);
            END IF;
            -----------------------------------------------------------------------
            -- Log calc events, but only display in session view
            -----------------------------------------------------------------------
            p_set_cntr( cs_calc_log_cntr_rows, 1, NULL, i_calc_log_comp_cd);
            p_calc_log( 'Calc ' || cs_calc_log_txt_comp_cd, i_calc_log_user_msg, i_calc_log_comp_cd);
            -----------------------------------------------------------------------
            -- Get next record index
            -----------------------------------------------------------------------
            v_c := v_trans_fetch_tbl.NEXT( v_c);
            --------------------------------------------------------------------------
            -- End Trans Processing Loop if records fetched
            --------------------------------------------------------------------------
         END LOOP;
         EXIT WHEN io_calc_trans_csr%NOTFOUND;
         --------------------------------------------------------------------------
         -- End Bulk Collect Fetch Loop
         --------------------------------------------------------------------------
      END LOOP;
      CLOSE io_calc_trans_csr;
      --------------------------------------------------------------------------
      -- Process any remaining transaction group
      --------------------------------------------------------------------------
      p_process_trans_group;
      --------------------------------------------------------------------------
      -- Flush all marked records
      --------------------------------------------------------------------------
      p_mark_record_flush( '', TRUE);
      --------------------------------------------------------------------------
      -- Log Calc Processing End
      --------------------------------------------------------------------------
      p_set_cntr( cs_calc_log_cntr_rows, v_total_rows, v_total_rows, i_calc_log_comp_cd);
      p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd, i_calc_log_user_msg, i_calc_log_comp_cd);
      -- Clear Log interval seconds
      gv_calc_log_update_interval := NULL;
      -- clear longops counters
      p_clear_cntrs();
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_trans_rollup_loop;


   PROCEDURE p_get_calc_trans
      (i_nd_tbl      IN t_price_tbl,
       i_no_mark_rec IN BOOLEAN := FALSE,
       i_step        IN NUMBER := NULL,
       i_steps       IN NUMBER := NULL)
   IS
      /*************************************************************************
      * Procedure Name : p_get_calc_trans
      *   Input params : i_nd_tbl - Nominal Pricing Table
      *                : i_no_mark_rec - run calculation without marking records
      *                : i_step - step number of this procedure call
      *                : i_steps - number of steps that will call this procedure
      *  Output params : None
      *        Returns : None
      *   Date Created : 12/13/2006
      *         Author : Joe Kidd
      *    Description : Opens all necessary transaction cursors for a
      *                  calculation and processes the results
      *
      * MOD HISTORY
      *  Date        Modified by   Reason
      *  ----------  ------------  ---------------------------------------------
      *  02/15/2007  Joe Kidd      PICC 1706: Some variable names have changed
      *                            Add i_nd_tbl parameter for Nominal processing
      *                            Add i_pl102_tbl parameter for PL 102 processing
      *                            Add i_step parameter to log calc step
      *  05/18/2007  Joe Kidd      PICC 1769: Add comp_dllrs to component table
      *                            Truncate and populate matrix work table
      *  10/01/2007  Joe Kidd      PICC 1808: Remove i_pl102_tbl parameter
      *                            Only process transactions if components are defined
      *                            Include Trans Type Group Processing Order in temp matrix
      *  11/30/2007  Joe Kidd      PICC 1810: Add unit component cd to component list
      *                            Remove call to p_save_trans_comps
      *                            Restore marking records settings
      *  12/05/2007  Joe Kidd      PICC 1763: Remove build of matrix work table
      *                            Remove the ndc from the calc cursor calls
      *  04/22/2008  Joe Kidd      PICC 1865: Add call to bundling cp summary function
      *  06/16/2008  Joe Kidd      PICC 1927: Remove call to bundling cp summary function
      *  08/22/2008  Joe Kidd      PICC 1961: Add multiple query passes for
      *                            the two bundling modes
      *                            Intial Bundle Pass processes all Bundled Products
      *  07/22/2009  Joe Kidd      RT 267 - CRQ 43432: Bundling Tuning
      *                            Limit cursor calls by CARS Source System Code
      *                            during bundling first pass
      *                            Save Bundle Summary rows
      *  12/01/2010  Joe Kidd      CRQ-931: December 2010 Govt Calculations Release
      *                            Remove bundling passes no longer needed
      *                            Remove source system code filtering
      *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
      *                            Disable Bundle Config step unless calc step is 1
      *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
      *                            Remove deletion of bundle products (no longer needed)
      *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
      *                            Change component value parameter
      *                            Call new main cursor
      *  04/11/2013  Joe Kidd      CRQ-45044: Adjust GP Smoothing
      *                            Disable bundling on second pass if no bundling
      *                            summaries are found
      *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
      *                            Add component description for user message
      *                            Collect bundling statistics
      *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
      *                            Add steps parameter for user message
      *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
      *                            Remove unneeded bundle statistics update
      *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
      *                            Change parameters, Use new main cursor output
      *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
      *                              formula / Winthrop BP Change
      *                            Use updated calc log procedures
      *                            Expand calc log entries
      *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
      *                            Correct Nominal/sub-PHS enable/disable
      *************************************************************************/
      cs_src_cd    CONSTANT hcrs.error_log_t.src_cd%TYPE := cs_src_pkg || '.p_get_calc_trans';
      cs_src_descr CONSTANT hcrs.error_log_t.src_descr%TYPE := 'Gets all transactions for a calculation';
      cs_cmt_txt   CONSTANT hcrs.error_log_t.cmt_txt%TYPE := 'Error while getting all transactions for a calculation';
      v_step                NUMBER;
      v_steps               NUMBER;
      v_calc_log_steps_msg  hcrs.prfl_prod_t.user_msg_txt%TYPE;
      v_calc_log_comp_cd    hcrs.prfl_prod_calc_log_t.comp_typ_cd%TYPE;
      v_calc_log_comp_cd2   hcrs.prfl_prod_calc_log_t.comp_typ_cd%TYPE;
      v_calc_log_user_msg   hcrs.prfl_prod_t.user_msg_txt%TYPE;
      v_calc_log_user_msg2  hcrs.prfl_prod_t.user_msg_txt%TYPE;
      v_i                   BINARY_INTEGER;
      v_calc_trans_csr      pkg_common_cursors.t_calc_trans_ref_csr; -- Ref Cursor Variable
      v_save_bndl_config    BOOLEAN;
      v_save_bndl_apply     BOOLEAN;
      v_save_accum_trans    BOOLEAN;
      v_save_mark_records   BOOLEAN;
      v_save_pl102_tbl      t_prod_price_tbl;
   BEGIN
      -- Save global settings
      v_save_bndl_config := gv_bndl_config;
      v_save_bndl_apply := gv_bndl_apply;
      v_save_accum_trans := gv_accum_trans;
      v_save_mark_records := gv_mark_records;
      v_save_pl102_tbl := gv_pl102_tbl;
      -- Set global nominal dollars
      gv_nd_tbl := i_nd_tbl;
      -- Turn marking on/off
      gv_mark_records := NOT NVL( i_no_mark_rec, FALSE);
      -- Set step/steps
      v_step := NVL( i_step, 1);
      v_steps := NVL( i_steps, v_step);
      IF v_steps > 1
      THEN
         -- Only show passes when there is more than one pass
         v_calc_log_steps_msg := ', pass ' || v_step || ' of ' || v_steps;
      END IF;
      -- Only do trans work if components have been defined
      IF gv_param_rec.comp_def_cnt > 0
      THEN
         --=====================================================================
         -- Log step start
         --=====================================================================
         v_calc_log_comp_cd := cs_qry_main || v_step;
         v_calc_log_user_msg := 'Running' || v_calc_log_steps_msg;
         p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' Start', v_calc_log_user_msg, v_calc_log_comp_cd);
         --=====================================================================
         -- Log step preparation start
         --=====================================================================
         v_calc_log_comp_cd2 := v_calc_log_comp_cd || '_INIT';
         v_calc_log_user_msg2 := v_calc_log_user_msg || '..';
         p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' Start', v_calc_log_user_msg2, v_calc_log_comp_cd2);
         -----------------------------------------------------------------------
         -- Configure Nominal checking
         -----------------------------------------------------------------------
         IF     gv_param_rec.chk_nom_calc = pkg_constants.cs_flag_yes
            AND gv_param_rec.chk_nom = pkg_constants.cs_flag_yes
            AND NVL( gv_param_rec.nom_thrs_pct, 0) > 0
         THEN
            -- Calculation actually uses nominal and nominal threshold set
            -- Remove Nominal prices that are null or not greater than zero to speed nominal checking
            v_i := gv_nd_tbl.FIRST();
            WHILE v_i IS NOT NULL
            LOOP
               IF NVL( gv_nd_tbl( v_i).chk_price, 0) <= 0
               THEN
                  gv_nd_tbl.DELETE( v_i);
               END IF;
               v_i := gv_nd_tbl.NEXT( v_i);
            END LOOP;
         ELSE
            -- Nominal disabled, clear price list
            gv_nd_tbl.DELETE();
         END IF;
         IF gv_nd_tbl.COUNT() > 0
         THEN
            gv_param_rec.chk_nom := pkg_constants.cs_flag_yes;
         ELSE
            gv_param_rec.chk_nom := pkg_constants.cs_flag_no;
         END IF;
         -----------------------------------------------------------------------
         -- Configure sub-PHS checking
         -----------------------------------------------------------------------
         IF     gv_param_rec.chk_hhs_calc = pkg_constants.cs_flag_yes
            AND gv_param_rec.chk_hhs = pkg_constants.cs_flag_yes
         THEN
            -- Remove PL102 prices that are null or not greater than zero to speed sub-PHS checking
            -- This table is built as part of p_common_initialize
            v_i := gv_pl102_tbl.FIRST();
            WHILE v_i IS NOT NULL
            LOOP
               IF NVL( gv_pl102_tbl( v_i).chk_price, 0) <= 0
               THEN
                  gv_pl102_tbl.DELETE( v_i);
               END IF;
               v_i := gv_pl102_tbl.NEXT( v_i);
            END LOOP;
         ELSE
            -- sub-PHS check disabled, clear price list
            gv_pl102_tbl.DELETE();
         END IF;
         IF gv_pl102_tbl.COUNT() > 0
         THEN
            gv_param_rec.chk_hhs := pkg_constants.cs_flag_yes;
         ELSE
            gv_param_rec.chk_hhs := pkg_constants.cs_flag_no;
         END IF;
         -----------------------------------------------------------------------
         -- Rebuild matrix, split percent, and bndling work tables
         -----------------------------------------------------------------------
         p_mk_mtrx_splt_bndl_wrk_t( gv_param_rec);
         -----------------------------------------------------------------------
         -- Clear and Populate component value table
         -----------------------------------------------------------------------
         p_comp_val_clear( TRUE); -- only zero the components
         -----------------------------------------------------------------------
         -- Configure Bundling settings
         -----------------------------------------------------------------------
         IF v_step = 1
         THEN
            -- Enable all bundling steps
            gv_bndl_config := TRUE;
            gv_bndl_apply := TRUE;
         ELSE
            -- Enable only bundling application step
            gv_bndl_config := FALSE;
            gv_bndl_apply := TRUE;
         END IF;
         -- Reset adjustment count
         gv_bndl_adj_cnt := 0;
         -- Force Commit
         p_commit_force();
         --=====================================================================
         -- Log step preparation end
         --=====================================================================
         p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' End', v_calc_log_user_msg2, v_calc_log_comp_cd2);
         --=====================================================================
         -- Log cursor open start
         --=====================================================================
         v_calc_log_comp_cd2 := v_calc_log_comp_cd || '_OPEN';
         v_calc_log_user_msg2 := v_calc_log_user_msg || '...';
         p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' Start', v_calc_log_user_msg2, v_calc_log_comp_cd2);
         -----------------------------------------------------------------------
         -- Open the main cursor
         -----------------------------------------------------------------------
         v_calc_trans_csr := pkg_common_cursors.f_csr_main;
         --=====================================================================
         -- Log cursor open end
         --=====================================================================
         p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' End', v_calc_log_user_msg2, v_calc_log_comp_cd2);
         --=====================================================================
         -- Log cursor loop start
         --=====================================================================
         v_calc_log_comp_cd2 := v_calc_log_comp_cd || '_LOOP';
         v_calc_log_user_msg2 := v_calc_log_user_msg || '....';
         p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' Start', v_calc_log_user_msg2, v_calc_log_comp_cd2);
         -----------------------------------------------------------------------
         -- Process transactions in a loop
         -----------------------------------------------------------------------
         IF v_calc_trans_csr%ISOPEN
         THEN
            p_trans_rollup_loop
               (v_calc_log_user_msg,
                v_calc_log_comp_cd2,
                v_calc_trans_csr);
         END IF;
         --=====================================================================
         -- Log cursor loop end
         --=====================================================================
         v_calc_log_user_msg := v_calc_log_user_msg || ', completed';
         p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' End', v_calc_log_user_msg, v_calc_log_comp_cd2);
         -----------------------------------------------------------------------
         -- Save components
         -----------------------------------------------------------------------
         p_comp_val_save;
         -----------------------------------------------------------------------
         -- Save Bundling summary and statistics
         -----------------------------------------------------------------------
         IF     v_step = 1
            AND (   gv_bndl_use_dra_prod
                 OR gv_bndl_use_dra_time)
         THEN
            p_commit( f_sv_bndl_smry());
         END IF;
         p_commit( f_sv_bndl_stats( gv_param_rec));
         --=====================================================================
         -- Log step end
         --=====================================================================
         p_calc_log_write( 'Calc ' || cs_calc_log_txt_comp_cd || ' End', v_calc_log_user_msg, v_calc_log_comp_cd);
      END IF;
      -- Force Commit
      p_commit_force();
      -- Restore global settings
      gv_bndl_config := v_save_bndl_config;
      gv_bndl_apply := v_save_bndl_apply;
      gv_accum_trans := v_save_accum_trans;
      gv_mark_records := v_save_mark_records;
      gv_pl102_tbl := v_save_pl102_tbl;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_raise_errors( cs_src_cd, cs_src_descr, SQLCODE, SQLERRM,
            'Fatal ' || cs_cmt_txt);
   END p_get_calc_trans;

END pkg_common_procedures;
/
