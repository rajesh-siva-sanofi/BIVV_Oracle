CREATE OR REPLACE PACKAGE pkg_constants
AS
   PRAGMA RESTRICT_REFERENCES( pkg_constants, WNDS);
   /****************************************************************************
   * Package Name : pkg_constants
   * Date Created : 10/02/2000
   *       Author : Tom Zimmerman
   *  Description : HCRS/GPCS System-wide constants (except those used by
   *                the GPCS interface)
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  02/10/2002  Joe Kidd      PICC 279: Added SAP Adjustment date constant
   *  08/20/2002  Joe Kidd      PICC 876: Added get_sap_adj_snpsht function get
   *                            SAP Adjustment snapshot id
   *  08/20/2002  Joe Kidd      PICC 856: Added source system constants
   *  08/20/2002  Joe Kidd      PICC 856: Added Transaction Adjustment Codes
   *  10/02/2002  Joe Kidd      PICC 913: Added source transaction types
   *  01/21/2003  T. Zimmerman  Added PUR constants and variables
   *  02/25/2003  Joe Kidd      PICC 1007: Add constant for AWP
   *  04/01/2003  Joe Kidd      PICC 881: Add constants for Changelog
   *  08/08/2003  Joe Kidd      PICC 1097: Add AWP and WAC component constants
   *  10/09/2003  Joe Kidd      PICC 1116: Add Update Profile Status Job const
   *  10/29/2003  Joe Kidd      PICC 1125: Add Check Request Status Constants
   *  10/31/2003  Joe Kidd      PICC 1128: Add FCP constants: FSS Perm/Annl/FFQ
   *  01/06/2004  Joe Kidd      PICC 1159: Add FCP constants: Curr3Q, CurrFFQ,
   *                            Prev3Q, PrevFFQ, PrevNone, FFSOver, and FSSNone
   *  01/28/2004  Joe Kidd      PICC 1167: Add Medicare ASP constants
   *  05/19/2004  Joe Kidd      PICC 1220: Add Medicare Approval Constants
   *  02/01/2005  Joe Kidd      PICC 1372, 1373, 1374:
   *                            Add Preliniary Profile global
   *                            Add Calc Method global and constants
   *                            Add AMP WAC component constant
   *                            Add cs_bulk_row_count constant
   *  05/31/2005  Joe Kidd      PICC 1406: Add Pricing constants
   *  08/04/2005  Joe Kidd      PICC 1446: Add constants for QNEDD/ANEDD
   *  11/15/2005  Joe Kidd      PICC 1487: Add constants for NonFAMP WAC/AEDUP
   *  12/13/2006  Joe Kidd      PICC 1680:
   *                            Add var_co_id global variable
   *                            Changed Rollback constants to constants
   *                            Add Authorized Generics Supergroup constants
   *                            Add Medicaid Monthly processing type constant
   *                            Add DRA calc methods constants
   *                            Moved all Profile Variable contants to one place
   *                            Add new AMP components constants
   *                            Rearranged some calculation constants
   *                            Add HCRS and XENON source system constants
   *                            Add ROLLUP transaction adjustment constant
   *  02/15/2007  Joe Kidd      PICC 1706:
   *                            Add SMTHD-FNL calc method
   *                            Add Transaction Mark/Accum constants
   *                            Add QNEDU, ANEDU, QEWDD, AEWDD, AWDUP components
   *                            Change NFAMP PL102 pricing constants
   *  05/18/2007  Joe Kidd      PICC 1769:
   *                            Fix incorrect year in previous change comments
   *                            Add constant for Component Price Points
   *  10/01/2007  Joe Kidd      PICC 1808:
   *                            Add DRA (final rule) calc methods constants
   *  11/02/2007  Joe Kidd      PICC 1839: Add constant for FCP's previous FCP
   *                            component
   *  11/15/2007  Joe Kidd      PICC 1848: Add constant for FSS Contract 30 Day
   *                            FCP component
   *  11/30/2007  Joe Kidd      PICC 1810: Add constants for Competitive
   *                            Acquisition Program components
   *  11/30/2007  Joe Kidd      PICC 1847: Add constant for Prompt Pay
   *                            Adjustment Percent
   *  12/05/2007  Joe Kidd      PICC 1763: Add constant for Split Percentage
   *                            Estimates transaction adjustments and Delete flag
   *  04/22/2008  Joe Kidd      PICC 1865: Add constant for Bundling transaction
   *                            adjustments and snapshot date
   *  06/16/2008  Joe Kidd      PICC 1927: Add constants for None Condition Code
   *  08/22/2008  Joe Kidd      PICC 1961: Add Bundle Mode and User constants
   *  08/07/2008  Joe Kidd      PICC 1950: Add SAP Adj control constants
   *  04/02/2009  Joe Kidd      PICC 2027: Add Bundle Addl Text Day Offset constants
   *  05/06/2009  Joe Kidd      PICC 2051: Add X360 source system, rollup, and
   *                            adjustment constants
   *                            Remove rollback segment mgmt constants
   *  06/22/2009  Joe Kidd      RT 458 - CRQ 29045 - IS-000000000355
   *                            Add Maximum DPA pct profile variable constant
   *                            Add Transaction Amount Definition Constants
   *                            Add Price Period constants for Min and Max
   *  04/01/2010  Joe Kidd      RT 372 - CRQ 43435 - IS-000000000018
   *                            Added Prasco source system constant
   *                            Added Prasco transaction adjustment constants
   *                            Added Transaction Source Table constants
   *  04/20/2010  Alice Gamer   CRQ44277 - URA changes enacted by HealthCare reform (new constants and variables).
   *  08/05/2010  Alice Gamer   CRQ48778 - added variable var_ura_adj_lastwac_minus_bp
   *  10/01/2010  Joe Kidd      CRQ-53357: October 2010 Govt Calculations Release
   *                            Add new Calc Method constants
   *                            Add new Prod Pricing (matrix) constants
   *                            Cleanup comments, remove unneeded constants
   *  12/01/2010  Joe Kidd      CRQ-931: December 2010 Govt Calculations Release
   *                            Add new Calc Method constant
   *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
   *                            Add Genzyme calc method constants
   *                            Add WAC value of Packages for Dollars trans value
   *                            Add trans mark/accumulation constants
   *                            Add Genzyme component constants
   *                            Add Genzyme record source indicator constant
   *                            Add Genzyme source system constants
   *                            Add Genzyme source table constants
   *                            Add Not Ready Preliminary Approval/Trans constant
   *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
   *                            Add Decimal Precision constant
   *                            Add additional flag constants (all, ignore)
   *                            Add Non-Indirect Wholesaler settings constants
   *                            Add trans mark/accumulation constants
   *                            Add Genzyme component constants
   *  07/05/2012  Joe Kidd      CRQ-24537: Genzyme GP Integration Phase 2 part 2
   *                            Add Genzyme source system constant
   *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
   *                            Add new Calc Method constants
   *                            Update Calculation Query constants
   *                            Add trans mark/accumulation constants
   *                            Add manual record source constant
   *                            Add GPCS manual source system constant
   *                            Add trans class constants
   *                            Add GPCS manual source table constant
   *                            Add/Update FSS OI Perm/Temp Pricing constants
   *                            Add snapshot ID for manual adjustments
   *                            Remove IFF related constants
   *                            Remove SAP Adjustment Date constant
   *  02/20/2013  Alice Gamer   CRQ38024 - URA Calculation Line Extension Drugs PPACA
   *                            Add Base percent component ID, var_pgm_cd
   *  06/10/2013  Alice Gamer   CRQ51343 - added variable var_ura_adj_firstwac_minus_bp
   *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
   *                            Add permanent and temporary FSS pricing constants
   *                            Remove Contract Pricing Types for FCP Calculation
   *                            Remove Govt/OGA/PHS Pricing basis code constants
   *                            Remove FSS Contract Category and Market Type constants
   *                            Move Transaction Amount Definition Constants to
   *                            pkg_common_procedures where they are used.
   *                            Seperated Component and Transaction dollars constants
   *                            Add Transaction Prompt Pay Discount constants
   *                            Add customer source system suffix constants
   *  05/05/2015  T. Zimmerman  CRQ175926  - URA Rounding Issue - Changed rounding to use
   *                            PKG_CONSTANTS.cs_default_precision: Changed from 6 to 7
   *  05/15/2015  Joe Kidd      CRQ-176137: Demand 6727 GP Methodology Changes
   *                            Remove unneeded transaction accumulation constants
   *                            Add new Calc Method constants
   *                            Add new component constants
   *                            Add Bundling Adjustment Discount constants
   *                            Add Bundled Adjustment Transaction dollars constant
   *  10/02/2015  Joe Kidd      CRQ-208647: Demand 6324: NonFamp/FCP Calc Modifications
   *                            Add new constants for NonFAMP and FCP overrides
   *  01/26/2016  Uvarajakumar  CRQ-236712: Demand 8955: Claim Import process enhancement
   *                            Add new constants to delay claim import validation process
   *  03/01/2016  Joe Kidd      CRQ-248323: Demand 8997: ASP Approvals and Pending AMPs
   *                            Remove unneeded Medicaid/Medicare approval status constants
   *  05/25/2016  T. Zimmerman  CRQ-266675: Demand 3336 AMP Final Rule (June Release)
   *                            Added variables for new Calculation Methods, Components and supergroups
   *  08/31/2016  T. Zimmerman  CRQ-302277: Demand 3336 AMP Final Rule (October Release)
   *                            Added variables for new Components and System Flags
   *  01/06/2017  Joe Kidd      CRQ-342698: Demand 8827: GP Audit 2016
   *                            Clean up variables and constants
   *  05/01/2017  Joe Kidd      CRQ-358160: Demand 10645: Bundling Value Based
   *                            Added variables for marking NDC columns
   *  09/20/2017  T. Zimmerman  CRQ-376489: Demand 10536: Revise Calc Methods for SPP Wholesalers
   *                            Added constants for contracted transactions accumulation
   *  3/14/2018   T. Zimmerman  Demand 12284  - Bipartisan Budget Act Revises Alternative Medicaid Rebate Formula for Line Extensions
   *                            Added constant cs_fdrl_disc_formula_id
   *  01/15/2018  Joe Kidd      CHG-055804: Demand 6812 SURF BSI / Cust COT
   *                            Add additional Calculation Defintions constants
   *                            Add Record Source Indicator constants
   *                            Add Data Source Company Identifier constants
   *                            Add additional Bundle Addl Text constants
   *  12/03/2018  Joe Kidd      CHG-0088302: RITM-0603132: Use CMS Qtrly AMP
   *                              formula / Winthrop BP Change
   *                            Add Specialty Wholesaler COT constant
   *  06/05/2019  J. Tronoski   ITS-CHG0117658: RITM-0726677: Bundle Evaluation Date Codes
   *                            Add VSDO and VEDO Bundle Addl Text settings
   *  07/25/2019  J. Tronoski   ITS-CHG0125110
   *                            Add cs_coc_comp_typ_bunit_num
   *  03/01/2019  Joe Kidd      CHG-0137941: RITM-1096050: NonFAMP sub-PHS issue
   *                            Remove unneeded variables and constants
   *                            Add Customer Location Constants
   *                            Correct COSMIS and PST company code constants
   *  11/6/2019   Mario Gedzior RITM1441194 - added mod_prcss for Medicare filing (FIA)
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add SAP4H source system constants
   *  04/05/2020  M. Gedzior    RITM-1714054: Add SubPHS to Sales Exclusion
   *              Joe Kidd      Add sales exclusion code constants
   *                            Add sales exclusion compare code constants
   *  08/01/2020  Joe Kidd      CHG-198490: Bioverativ Integration
   *                            Add Bioverative Source Systems and Trans Adjs
   ****************************************************************************/

 -- Registered variables (these are registered, not constants)
 -- Following variables are session dependent and are being used in different modules
 var_queue_id                     hcrs.prcss_queue_t.prcss_queue_id%TYPE := NULL; -- Registered queue id
 var_prfl_id                      hcrs.prfl_t.prfl_id%TYPE := NULL; -- Registered profile id
 var_atp_cd                       hcrs.agency_typ_t.agency_typ_cd%TYPE := NULL; -- Registered Agency Type
 var_atp_pckg_lvl_ind             hcrs.agency_typ_t.calc_ndc_pckg_lvl%TYPE :=NULL; -- Registered Agency Calc NDC Package Level Indicator
 var_prcss_typ_cd                 hcrs.prfl_t.prcss_typ_cd%TYPE := NULL; -- Registered Process type Cd
 var_ndc_lbl                      hcrs.prod_mstr_t.ndc_lbl%TYPE := NULL; -- Registered NDC label
 var_ndc_prod                     hcrs.prod_mstr_t.ndc_prod%TYPE := NULL; -- Registered NDC product
 var_ndc_pckg                     hcrs.prod_mstr_t.ndc_pckg%TYPE := NULL; -- Registered NDC package
 var_calc_typ_cd                  hcrs.calc_typ_t.calc_typ_cd%TYPE := NULL; -- Calc Type Code
 var_job_exec_nm                  VARCHAR2(50) := NULL ; -- Job to be executed
 var_formula_id                   hcrs.pur_formula_t.formula_id%TYPE := NULL; -- Registered Formula ID
 var_parent_formula_id            hcrs.pur_formula_t.formula_id%TYPE := NULL; -- Registered Parent Fromula ID
 var_period_id                    hcrs.period_t.period_id%TYPE := NULL; -- Register period id
 var_pgm_id                       hcrs.pur_formula_pgm_prod_assoc_t.pgm_id%TYPE := NULL; -- Register Program ID
 var_pgm_cd                       hcrs.pgm_t.pgm_cd%TYPE := NULL; -- Register Program Code
 var_inquiry_mode                 BOOLEAN := FALSE; -- Register inquiry mode
 var_pckg_lvl_ind                 VARCHAR2(1) := NULL; -- Register package level indicator
 var_begin_qtr_dt                 DATE := NULL; -- Register begin quarter date
 var_end_qtr_dt                   DATE := NULL; -- Register end quarter date
 var_request_dt                   DATE := NULL; -- Register request date
 var_active_flag                  CHAR(1) := NULL; -- Register active flag
 var_pur_catg_cd                  hcrs.pur_catg_t.pur_catg_cd%TYPE := NULL; -- Register the PUR category code
 var_override_level               VARCHAR2(10) := NULL; -- Register the PUR coverride level
 var_process_name                 hcrs.error_log_t.calc_typ_cd%TYPE := NULL; -- Register process name
 var_trnsmsn_seq_no               hcrs.pur_results_t.trnsmsn_seq_no%TYPE := NULL; -- Register transmission sequence number
 var_price_adj_id                 hcrs.price_adj_t.price_adj_id%TYPE := NULL; -- Register price adjustment ID
 var_activation_type              VARCHAR2(3) := NULL; -- Register activatio type
 var_log_flag                     BOOLEAN; -- Register log flag
 var_fatal_flag                   BOOLEAN := FALSE; -- Register fatal flag
 var_result_eff_dt                DATE := NULL; -- Register sql function date for rounding and such
 var_formula_sql_txt              VARCHAR2(32767) := NULL; -- Register URA Formula SQL Text
 var_ura_cap_adj_formula_id       hcrs.pur_formula_t.formula_id%TYPE := NULL; -- Register URA Adjustment Formula ID
 var_ura_adj_lastwac_minus_bp     hcrs.pur_formula_t.formula_id%TYPE := NULL; -- Register URA Adjustment @LastWAC-BP Formula ID
 var_ura_adj_firstwac_minus_bp    hcrs.pur_formula_t.formula_id%TYPE := NULL; -- Register URA Adjustment @FirstWAC-BP Formula ID

 -- Capture current user name to prevent hidden Select USER from Dual in triggers
 cs_user                          CONSTANT sys.all_users.username%TYPE := USER;

 -- Commit Check Point for no. of commits to database for Insert and Update
 cs_commit_point                  CONSTANT NUMBER := 10000; -- Commit Pointer
 cs_bulk_row_count                CONSTANT NUMBER := 100; -- Rows for bulk collect

 -- System status
 cs_system_status_base            CONSTANT VARCHAR2(25) := 'SYSTEM STATUS '; -- Base System Status
 cs_system_status_medicaid        CONSTANT VARCHAR2(25) := 'SYSTEM STATUS MEDICAID'; -- Medicaid System Status
 cs_system_status_medicare        CONSTANT VARCHAR2(25) := 'SYSTEM STATUS MEDICARE'; -- Medicare System Status
 cs_system_status_va              CONSTANT VARCHAR2(25) := 'SYSTEM STATUS VA'; -- VA System Status
 cs_system_status_coc             CONSTANT VARCHAR2(25) := 'SYSTEM STATUS COC'; -- COC System Status
 cs_system_status_locked          CONSTANT VARCHAR2(10) := 'LOCKED';  -- System Locked Status
 cs_system_status_unlocked        CONSTANT VARCHAR2(10) := 'UNLOCKED';  -- System Unlocked Status

 -- Job Resubmit constants if any errors
 cs_max_resubmit                  CONSTANT NUMBER := 1; -- Max times to resubmit for delete job
 cs_error_snapshot_too_old        CONSTANT NUMBER := -1555; -- Oracle error code
 cs_error_deadlock                CONSTANT NUMBER := -60; -- Dead lock on tables

 -- Front-end Check Uneval codes
 cs_chk_uneval_product            CONSTANT VARCHAR2(20) := 'PRODUCT'; -- Products
 cs_chk_uneval_cot                CONSTANT VARCHAR2(20) := 'COT'; -- Class of Trade
 cs_chk_uneval_tt                 CONSTANT VARCHAR2(20) := 'TT'; -- Transaction Types
 cs_chk_uneval_cot_tt             CONSTANT VARCHAR2(20) := 'COT/TT'; -- Class of Trade / Transaction Type
 cs_chk_uneval_sls_excl           CONSTANT VARCHAR2(20) := 'SALES EXCLUSIONS'; -- Sales Exclusions
 cs_chk_uneval_var                CONSTANT VARCHAR2(20) := 'VARIABLES'; -- Variables

 -- Drug categories
 cs_drug_cat_innovator            CONSTANT hcrs.drug_catg_t.drug_catg_cd%TYPE := 'I'; -- Innovator
 cs_drug_cat_single_source        CONSTANT hcrs.drug_catg_t.drug_catg_cd%TYPE := 'S'; -- Single Source
 cs_drug_cat_noninnovator         CONSTANT hcrs.drug_catg_t.drug_catg_cd%TYPE := 'N'; -- Non-Innovator

 -- Batch Job status
 cs_job_new                       CONSTANT hcrs.prcss_queue_t.prcss_stat%TYPE := 'NEW'; -- Job new
 cs_job_pending                   CONSTANT hcrs.prcss_queue_t.prcss_stat%TYPE := 'PENDING'; -- Job pending
 cs_job_started                   CONSTANT hcrs.prcss_queue_t.prcss_stat%TYPE := 'STARTED'; -- Job started  Both are used?
 cs_job_starting                  CONSTANT hcrs.prcss_queue_t.prcss_stat%TYPE := 'STARTING'; -- Job starting  Both are used?
 cs_job_running                   CONSTANT hcrs.prcss_queue_t.prcss_stat%TYPE := 'RUNNING'; -- Job running
 cs_job_finished                  CONSTANT hcrs.prcss_queue_t.prcss_stat%TYPE := 'FINISHED'; -- Job finished
 cs_job_error                     CONSTANT hcrs.prcss_queue_t.prcss_stat%TYPE := 'ERROR'; -- Job error
 cs_job_dflt_restart_cnt          CONSTANT hcrs.prcss_queue_t.restart_cnt%TYPE := 0; -- default restart count
 cs_job_dflt_restart_step         CONSTANT hcrs.prcss_queue_t.restart_step%TYPE := 0; -- default restart step
 cs_job_dflt_load_to_db_flg       CONSTANT hcrs.prcss_queue_t.load_to_db_flg%TYPE := 'N'; -- defalut load to db flag

 -- gpcs jobs will be called from Front-end for Calculation
 cs_gpcs_calc_amp_bp              CONSTANT hcrs.prcss_batch_t.exec_nm%TYPE := 'gpcs_calc_amp_bp.sh'; -- AMP BP shell
 cs_gpcs_calc_bp                  CONSTANT hcrs.prcss_batch_t.exec_nm%TYPE := 'gpcs_calc_bp.sh'; -- BP shell
 cs_gpcs_calc_asp                 CONSTANT hcrs.prcss_batch_t.exec_nm%TYPE := 'gpcs_calc_asp.sh'; -- ASP shell
 cs_gpcs_calc_nf_fcp              CONSTANT hcrs.prcss_batch_t.exec_nm%TYPE := 'gpcs_calc_nf_fcp.sh'; -- NonFAMP FCP shell
 cs_gpcs_calc_nf                  CONSTANT hcrs.prcss_batch_t.exec_nm%TYPE := 'gpcs_calc_nf.sh'; -- NonFAMP shell
 cs_gpcs_calc_fcp                 CONSTANT hcrs.prcss_batch_t.exec_nm%TYPE := 'gpcs_calc_fcp.sh'; -- FCP shell

 -- package procedures for gpcs jobs
 cs_p_amp_calc                    CONSTANT VARCHAR2(50) := 'pkg_medicaid.p_amp_calc'; -- AMP calculation procedure
 cs_p_bp_calc                     CONSTANT VARCHAR2(50) := 'pkg_medicaid.p_bp_calc'; -- BP calculation procedure
 cs_p_normal_nfamp_calc           CONSTANT VARCHAR2(50) := 'pkg_va.p_normal_nonfamp'; -- NonFAMP calculation procedure
 cs_p_normal_fcp_calc             CONSTANT VARCHAR2(50) := 'pkg_va.p_fcp';  -- FCP calculation procedure
 cs_p_newprod_nfamp_calc          CONSTANT VARCHAR2(50) := 'pkg_va.p_newprod_nonfamp'; -- NonFAMP calculation procedure
 cs_p_newprod_fcp_calc            CONSTANT VARCHAR2(50) := 'pkg_va.p_newprod_fcp';  -- FCP calculation procedure
 cs_p_asp_calc                    CONSTANT VARCHAR2(50) := 'pkg_medicare.p_asp_calc'; -- ASP calculation procedure
 cs_p_delete_profile              CONSTANT VARCHAR2(50) := 'pkg_fe_profile.p_delete_profile_job' ; -- Delete Profile Job
 cs_p_delete_prices               CONSTANT VARCHAR2(50) := 'pkg_fe_profile.p_delete_prices_job' ; -- Delete Prices Job
 cs_p_upd_prfl_status             CONSTANT VARCHAR2(50) := 'pkg_fe_profile.p_upd_prfl_status_job'; -- Update Profile Status Job
 cs_p_delete_product              CONSTANT VARCHAR2(50) := 'pkg_fe_profile.p_delete_prod_job'; -- Delete product job
 cs_p_override_amp_bp             CONSTANT VARCHAR2(50) := 'pkg_fe_pricing.p_override_amp_bp_job'; -- Override AMP BP job
 cs_p_override_nfamp_fcp          CONSTANT VARCHAR2(50) := 'pkg_fe_pricing.p_override_nfamp_fcp_job'; -- Override NFAMP FCP job
 cs_p_refresh_prfl_cust_cot       CONSTANT VARCHAR2(50) := 'pkg_fe_profile.p_refresh_prfl_cust_cot_job'; -- Refresh Cust COT job
 cs_p_broadcast_changes           CONSTANT VARCHAR2(50) := 'pkg_fe_profile.p_broadcast_changes_job'; -- Broadcast changes job

 -- FSS pricing strategy (Permanent and Temporary)
 cs_fss_strtgy_typ_perm_cd        CONSTANT hcrs.price_grp_strtgy_t.strtgy_typ_cd%TYPE := 'PERM'; -- Permanent Pricing
 cs_fss_strtgy_typ_temp_cd        CONSTANT hcrs.price_grp_strtgy_t.strtgy_typ_cd%TYPE := 'TEMP'; -- Temporary Pricing

 -- Transaction Type supergroups - Make sure the records exist in 'trans_typ_grp_t' table
 cs_tt_direct_sales               CONSTANT hcrs.trans_typ_grp_t.trans_typ_grp_cd%TYPE := 'DIR'; -- Direct Sales
 cs_tt_indirect_sales             CONSTANT hcrs.trans_typ_grp_t.trans_typ_grp_cd%TYPE := 'IDR'; -- Indirect Sales
 cs_tt_rebates                    CONSTANT hcrs.trans_typ_grp_t.trans_typ_grp_cd%TYPE := 'RBT'; -- Rebates
 cs_tt_none                       CONSTANT hcrs.trans_typ_grp_t.trans_typ_grp_cd%TYPE := 'NONE'; -- None
 cs_tt_fee                        CONSTANT hcrs.trans_typ_grp_t.trans_typ_grp_cd%TYPE := 'FEE' ; -- Fee
 cs_tt_uneval                     CONSTANT hcrs.trans_typ_grp_t.trans_typ_grp_cd%TYPE := 'UNEVAL' ; -- Unevaluated
 cs_tt_govt                       CONSTANT hcrs.trans_typ_grp_t.trans_typ_grp_cd%TYPE := 'GOVT' ; -- Government Programs
 cs_tt_auth_gen_mthly             CONSTANT hcrs.trans_typ_grp_t.trans_typ_grp_cd%TYPE := 'AGENM'; -- Authorized Generices Monthly
 cs_tt_auth_gen_qtrly             CONSTANT hcrs.trans_typ_grp_t.trans_typ_grp_cd%TYPE := 'AGENQ'; -- Authorized Generices Monthly
 cs_tt_factr_rbt_fee              CONSTANT hcrs.trans_typ_grp_t.trans_typ_grp_cd%TYPE := 'FCTRF' ; -- Factored Rebates/Fees
 cs_tt_review                     CONSTANT hcrs.trans_typ_grp_t.trans_typ_grp_cd%TYPE := 'RVW'; -- Review

 -- Class of Trade supergroups - Make sure the records exist in 'cls_of_trd_grp_t'
 cs_cot_wholesaler                CONSTANT hcrs.cls_of_trd_grp_t.cot_grp_cd%TYPE := 'WHLSLR'; -- Wholesaler (Default CPP)
 cs_cot_hhs_grantee               CONSTANT hcrs.cls_of_trd_grp_t.cot_grp_cd%TYPE := 'HHS GRANTEE'; -- HHS Grantee
 cs_cot_none                      CONSTANT hcrs.cls_of_trd_grp_t.cot_grp_cd%TYPE := 'NONE'; -- None
 cs_cot_uneval                    CONSTANT hcrs.cls_of_trd_grp_t.cot_grp_cd%TYPE := 'UNEVAL'; -- Unevaluated
 cs_cot_govt                      CONSTANT hcrs.cls_of_trd_grp_t.cot_grp_cd%TYPE := 'GOVT'; -- Government Programs
 cs_cot_cap                       CONSTANT hcrs.cls_of_trd_grp_t.cot_grp_cd%TYPE := 'CAP'; -- Competitive Acquisition Program
 cs_cot_dist_agt                  CONSTANT hcrs.cls_of_trd_grp_t.cot_grp_cd%TYPE := 'DISTAGT'; -- Distributor Agent
 cs_cot_whlslr_no_cpp             CONSTANT hcrs.cls_of_trd_grp_t.cot_grp_cd%TYPE := 'WHLS-NOCPP'; -- Wholesaler (No CPP)
 cs_cot_whlslr_spp                CONSTANT hcrs.cls_of_trd_grp_t.cot_grp_cd%TYPE := 'WHLS-SPP'; -- Specialty Wholesaler (Default CPP)

 -- Agencies - Make sure the records exist in 'agency_typ_t'
 cs_atp_med_cd                    CONSTANT hcrs.agency_typ_t.agency_typ_cd%TYPE := 'MEDICAID'; -- Medicaid Agency Type
 cs_atp_medicare_cd               CONSTANT hcrs.agency_typ_t.agency_typ_cd%TYPE := 'MEDICARE'; -- Medicare Agency Type
 cs_atp_va_cd                     CONSTANT hcrs.agency_typ_t.agency_typ_cd%TYPE := 'VA'; -- VA Agency Type

 -- Return codes
 cs_ret_success                   CONSTANT NUMBER := 0; -- Success
 cs_ret_failure                   CONSTANT NUMBER := -1; -- Failure

 -- Calculation types - Make sure the records exist in 'calc_typ_t' table
 cs_calc_typ_amp_cd               CONSTANT hcrs.calc_typ_t.calc_typ_cd%TYPE := 'AMP'; -- AMP calculation type
 cs_calc_typ_bp_cd                CONSTANT hcrs.calc_typ_t.calc_typ_cd%TYPE := 'BP';  -- BP calculation type
 cs_calc_typ_asp_cd               CONSTANT hcrs.calc_typ_t.calc_typ_cd%TYPE := 'ASP'; -- ASP calculation type
 cs_calc_typ_fcp_cd               CONSTANT hcrs.calc_typ_t.calc_typ_cd%TYPE := 'FCP'; -- FCP calculation type
 cs_calc_typ_nfamp_cd             CONSTANT hcrs.calc_typ_t.calc_typ_cd%TYPE := 'NFAMP'; -- NonFAMP calculation type

 -- Processing types - Make sure the records exist in 'prcss_typ_t' table
 cs_va_prcssng_typ_annl           CONSTANT hcrs.prcss_typ_t.prcss_typ_cd%TYPE := 'VA_ANNL'; -- VA Annual processing
 cs_va_prcssng_typ_qtrly          CONSTANT hcrs.prcss_typ_t.prcss_typ_cd%TYPE := 'VA_QTRLY'; -- VA Quarterly processing
 cs_va_prcssng_typ_30day          CONSTANT hcrs.prcss_typ_t.prcss_typ_cd%TYPE := 'VA_30DAY'; -- VA 30 day processing
 cs_va_prcssng_typ_firstfull      CONSTANT hcrs.prcss_typ_t.prcss_typ_cd%TYPE := 'VA_FIRSTFULL'; -- VA First Full quarter
 cs_med_prcssng_typ_qtrly         CONSTANT hcrs.prcss_typ_t.prcss_typ_cd%TYPE := 'MED_QTRLY'; -- Medicaid Quarterly
 cs_med_prcssng_typ_corrctv       CONSTANT hcrs.prcss_typ_t.prcss_typ_cd%TYPE := 'MED_CORRCTV'; -- Medicaid corrective
 cs_med_prcssng_typ_mthly         CONSTANT hcrs.prcss_typ_t.prcss_typ_cd%TYPE := 'MED_MTHLY'; -- Medicaid corrective
 cs_medicare_prcssng_typ_qtrly    CONSTANT hcrs.prcss_typ_t.prcss_typ_cd%TYPE := 'MEDICARE_QTRLY'; -- Medicare Quarterly

 -- Calculation status -  Make sure the records exist in 'calc_stat_t' table
 cs_calc_ready_status             CONSTANT hcrs.calc_stat_t.calc_stat_cd%TYPE := 'READY'; -- Product Ready Status
 cs_calc_submit_status            CONSTANT hcrs.calc_stat_t.calc_stat_cd%TYPE := 'SUBMITTED'; -- Product Submitted Status
 cs_calc_job_inserted_status      CONSTANT hcrs.calc_stat_t.calc_stat_cd%TYPE := 'JOB INSERTED'; -- Product Job Inserted Status
 cs_calc_run_status               CONSTANT hcrs.calc_stat_t.calc_stat_cd%TYPE := 'RUNNING'; -- Product Running Status
 cs_calc_halt_status              CONSTANT hcrs.calc_stat_t.calc_stat_cd%TYPE := 'HALTED'; -- Product Halt status
 cs_calc_error_status             CONSTANT hcrs.calc_stat_t.calc_stat_cd%TYPE := 'ERROR'; -- Product Error Status
 cs_calc_complete_status          CONSTANT hcrs.calc_stat_t.calc_stat_cd%TYPE := 'COMPLETE'; -- product Complete Status
 cs_calc_delete_status            CONSTANT hcrs.calc_stat_t.calc_stat_cd%TYPE := 'DELETE'; -- product Delete Status
 cs_calc_resubmit_status          CONSTANT hcrs.calc_stat_t.calc_stat_cd%TYPE := 'RESUBMITTED'; -- product Resubmitted Status -- when a job fails, it may be resubmitted again
 cs_calc_overriding_status        CONSTANT hcrs.calc_stat_t.calc_stat_cd%TYPE := 'OVERRIDING'; -- product Overriding status
 cs_calc_override_status          CONSTANT hcrs.calc_stat_t.calc_stat_cd%TYPE := 'OVERRIDE'; -- product Override status
 cs_calc_exception_status         CONSTANT hcrs.calc_stat_t.calc_stat_cd%TYPE := 'EXCEPTION'; -- product Exception status

 -- Profile status - Make sure the records exist in 'prfl_stat_t' table
 cs_prfl_stat_transmitted_cd      CONSTANT hcrs.prfl_stat_t.prfl_stat_cd%TYPE := 'TRANSMITTED' ; -- Profile Status Code - Transmitted
 cs_prfl_stat_submitted_cd        CONSTANT hcrs.prfl_stat_t.prfl_stat_cd%TYPE := 'SUBMITTED' ; -- Profile Status Code - Submitted
 cs_prfl_stat_ready_cd            CONSTANT hcrs.prfl_stat_t.prfl_stat_cd%TYPE := 'READY' ; -- Profile Status Code - Ready
 cs_prfl_stat_new_cd              CONSTANT hcrs.prfl_stat_t.prfl_stat_cd%TYPE := 'NEW' ; -- Profile Status Code - New
 cs_prfl_stat_approved_cd         CONSTANT hcrs.prfl_stat_t.prfl_stat_cd%TYPE := 'APPROVED' ; -- Profile Status Code - Approved
 cs_prfl_stat_locked_cd           CONSTANT hcrs.prfl_stat_t.prfl_stat_cd%TYPE := 'LOCKED' ; -- Profile Status Code - Locked
 cs_prfl_stat_delete_cd           CONSTANT hcrs.prfl_stat_t.prfl_stat_cd%TYPE := 'DELETE' ; -- Profile Status Code - Delete

 -- Calculation method codes - Make sure the records exist in 'calc_mthd_t' table
 cs_calc_mthd_smthd               CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD'; -- Smoothed Calculation Method
 cs_calc_mthd_smthd_dra           CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-DRA'; -- Smoothed DRA (proposed rule) Calculation Method
 cs_calc_mthd_smthd_dra2          CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-DRA2'; -- Smoothed DRA (final rule) Calculation Method
 cs_calc_mthd_smthd_dra3          CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-DRA3'; -- Smoothed DRA (final rule v2) Calculation Method
 cs_calc_mthd_smthd_fnl           CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-FNL'; -- Smoothed (Final Rule v1) Calculation Method
 cs_calc_mthd_smthd_fnl2          CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-FNL2'; -- Smoothed (Final Rule v2) Calculation Method
 cs_calc_mthd_smthd_fnl3          CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-FNL3'; -- Smoothed (Final Rule v3) Calculation Method
 cs_calc_mthd_smthd_fnl4          CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-FNL4'; -- Smoothed (Final Rule v4) Calculation Method
 cs_calc_mthd_smthd_fnl5          CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-FNL5'; -- Smoothing (Final Rule v5) Calculation Method
 cs_calc_mthd_smthd_hcr           CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-HCR'; -- Smoothed (PPACA Prop. Rule v1) Calculation Method
 cs_calc_mthd_smthd_hcr2          CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-HCR2'; -- Smoothed (PPACA Prop. Rule v2) Calculation Method
 cs_calc_mthd_smthd_hcr3          CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-HCR3'; -- Smoothed (PPACA Prop. Rule v3) Calculation Method
 cs_calc_mthd_smthd_hcr4          CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-HCR4'; -- Smoothing (PPACA Final Rule v1) Calculation Method
 cs_calc_mthd_smthd_gnz           CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-GNZ'; -- Smoothed Genzyme (PPACA) Calculation Method
 cs_calc_mthd_smthd_v2            CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-V2'; -- Smoothed (v2) Calculation Method
 cs_calc_mthd_smthd_v3            CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'SMTHD-V3'; -- Smoothing (v3) Calculation Method
 cs_calc_mthd_actl                CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'ACTL'; -- Actual Calculation Method
 cs_calc_mthd_actl_dra            CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'ACTL-DRA'; -- Actual DRA (proposed rule) Calculation Method
 cs_calc_mthd_actl_dra2           CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'ACTL-DRA2'; -- Actual DRA (final rule) Calculation Method
 cs_calc_mthd_actl_dra3           CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'ACTL-DRA3'; -- Actual DRA (final rule v2) Calculation Method
 cs_calc_mthd_actl_hcr            CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'ACTL-HCR'; -- Actual (PPACA Prop. Rule v1) Calculation Method
 cs_calc_mthd_actl_hcr2           CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'ACTL-HCR2'; -- Actual (PPACA Prop. Rule v2) Calculation Method
 cs_calc_mthd_actl_hcr3           CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'ACTL-HCR3'; -- Actual (PPACA Prop. Rule v3) Calculation Method
 cs_calc_mthd_actl_hcr4           CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'ACTL-HCR4'; -- Actual (PPACA Final Rule v1) Calculation Method
 cs_calc_mthd_actl_gnz            CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'ACTL-GNZ'; -- Actual Genzyme (PPACA) Calculation Method
 cs_calc_mthd_actl_v2             CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'ACTL-V2'; -- Actual (v2) Calculation Method
 cs_calc_mthd_actl_v3             CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'ACTL-V3'; -- Actual (v3) Calculation Method
 cs_calc_mthd_div4                CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'DIV4'; -- Divide by 4 Calculation Method
 cs_calc_mthd_refilevals          CONSTANT hcrs.calc_mthd_t.calc_mthd_cd%TYPE := 'REFILEVALS'; -- Refile values Calculation Method

 -- Prod Pricing (matrix) methods - Make sure the records exist in 'pri_whls_mthd_t' table
 cs_prod_pcng_prim_cd             CONSTANT hcrs.pri_whls_mthd_t.pri_whls_mthd_cd%TYPE := 'PRMRY'; -- Primary Product pricing method
 cs_prod_pcng_whls_cd             CONSTANT hcrs.pri_whls_mthd_t.pri_whls_mthd_cd%TYPE := 'WHLSLR'; -- Wholesaler Product pricing Method
 cs_prod_pcng_none_cd             CONSTANT hcrs.pri_whls_mthd_t.pri_whls_mthd_cd%TYPE := 'NONE'; -- None for Medicaid and Medicare
 cs_prod_pcng_rtl_cd              CONSTANT hcrs.pri_whls_mthd_t.pri_whls_mthd_cd%TYPE := 'RTL'; -- Retail for Medicaid
 cs_prod_pcng_nonrtl_cd           CONSTANT hcrs.pri_whls_mthd_t.pri_whls_mthd_cd%TYPE := 'NONRTL'; -- Non-Retail for Medicaid

 -- Variables - Make sure the records exist in 'var_t' table
 cs_dec_pres                      CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'DP'; -- Decimal Precision
 cs_amp_dec_pres                  CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'ADP'; -- AMP Decimal Precision
 cs_asp_dec_pres                  CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'ADP'; -- ASP Decimal Precision
 cs_bp_dec_pres                   CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'BDP'; -- BP Decimal Precision
 cs_cash_dscnt_pct                CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'CDP'; -- Cash Discount Percentage
 cs_prmpt_pay_adj_pct             CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'PPAP'; -- Prompt Pay Adjustment Percentage
 cs_max_dpa_pct                   CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'MAX_DPA_PCT'; -- Maximum DPA Percentage
 cs_cpiu_pct                      CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'CPIU_PCT'; -- CPI-U%
 cs_fcp_dec_pres                  CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'FDP'; -- Annual FCP Decimal Rounding Precision
 cs_gov_dis_pct                   CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'GDP'; -- Government Discount Percentage
 cs_nonfamp_dec_pres              CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'NDP'; -- NonFAMP Decimal Rounding Precision
 cs_nom_thrsh_pct                 CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'NTP'; -- Nominal Threshold Percentage
 cs_sales_offset                  CONSTANT hcrs.prfl_var_t.var_cd%TYPE := 'SO'; -- Sales Offset

 -- Include / Exclude Indicators
 cs_include                       CONSTANT hcrs.misc_cd_dtl_t.dtl_cd%TYPE := 'I'; -- Include
 cs_exclude                       CONSTANT hcrs.misc_cd_dtl_t.dtl_cd%TYPE := 'E'; -- Exclude
 cs_unevaluated                   CONSTANT hcrs.misc_cd_dtl_t.dtl_cd%TYPE := 'U'; -- Unevaluated

 -- Other
 cs_manual_adj_ind                CONSTANT hcrs.mstr_trans_t.manual_adj_ind%TYPE := 'Y'; -- Manual
 cs_snpsht_id_manual              CONSTANT hcrs.mstr_trans_t.snpsht_id%TYPE := 0; -- Manual adjustment snapshot id

 -- Medicaid/Medicare/VA Eligiblity
 cs_prod_med_unevaluated          CONSTANT hcrs.prod_mstr_t.elig_stat_cd%TYPE := 'UN'; -- Product Medicaid/Medicare/VA Unevaluated
 cs_prod_med_eligible             CONSTANT hcrs.prod_mstr_t.elig_stat_cd%TYPE := 'EL'; -- Product Medicaid/Medicare/VA Eligible
 cs_prod_med_ineligible           CONSTANT hcrs.prod_mstr_t.elig_stat_cd%TYPE := 'IN'; -- Product Medicaid/Medicare/VA Ineligible

 -- Prod_trnsmsn_t flags
 cs_prod_trnsmsn_load_cd          CONSTANT hcrs.prod_trnsmsn_t.prod_trnsmsn_stat_cd%TYPE := 'LO'; -- Loaded
 cs_prod_trnsmsn_sub_cd           CONSTANT hcrs.prod_trnsmsn_t.prod_trnsmsn_stat_cd%TYPE := 'SU'; -- Submitted
 cs_prod_trnsmsn_trans_cd         CONSTANT hcrs.prod_trnsmsn_t.prod_trnsmsn_stat_cd%TYPE := 'TR'; -- Transmitted
 cs_prod_trnsmsn_calc_cd          CONSTANT hcrs.prod_trnsmsn_t.prod_trnsmsn_stat_cd%TYPE := 'CA'; -- Calculated

 -- Prod Trnsmssn reason codes
 cs_prod_trnsmsn_rsn_cd_cor       CONSTANT hcrs.prod_trnsmsn_t.prod_trnsmsn_rsn_cd%TYPE := 'COR' ; -- Corrective
 cs_prod_trnsmsn_rsn_cd_qtr       CONSTANT hcrs.prod_trnsmsn_t.prod_trnsmsn_rsn_cd%TYPE := 'QTR' ; -- Quarter

 -- Yes and No
 cs_flag_yes                      CONSTANT CHAR (1) := 'Y';
 cs_flag_no                       CONSTANT CHAR (1) := 'N';
 cs_flag_delete                   CONSTANT CHAR (1) := 'D';
 cs_flag_delay                    CONSTANT CHAR (1) := 'D'; -- Delay scheduled

 -- Calculation Query constants
 cs_prune_days                    CONSTANT NUMBER := 10; -- Partition pruning days of leeway for strange dates

 -- Calc Defintions Accumulation flags
 cs_mark_accum_yes                CONSTANT hcrs.prfl_prod_calc_comp_def2_wrk_t.mark_accum_all_ind%TYPE := 'Y';
 cs_mark_accum_no                 CONSTANT hcrs.prfl_prod_calc_comp_def2_wrk_t.mark_accum_all_ind%TYPE := 'N';
 cs_mark_accum_igr                CONSTANT hcrs.prfl_prod_calc_comp_def2_wrk_t.mark_accum_all_ind%TYPE := '-';

 -- Customer Location Mode Constants
 cs_cust_loc_cd_mode_cust         CONSTANT VARCHAR2( 10) := 'CUST'; -- Customer Mode
 cs_cust_loc_cd_mode_comp_cust    CONSTANT VARCHAR2( 10) := 'COMP_CUST'; -- Component Customer Mode
 cs_cust_loc_cd_mode_comp_whls    CONSTANT VARCHAR2( 10) := 'COMP_WHLS'; -- Component Wholesaler Mode

 -- Calc Defintions Customer Location codes
 cs_cust_dom_terr_ind_incl        CONSTANT hcrs.calc_mthd_comp_trans_def_t.cust_domestic_ind%TYPE := 'Y';
 cs_cust_dom_terr_ind_excl        CONSTANT hcrs.calc_mthd_comp_trans_def_t.cust_domestic_ind%TYPE := 'N';
 cs_cust_dom_terr_ind_ignore      CONSTANT hcrs.calc_mthd_comp_trans_def_t.cust_domestic_ind%TYPE := 'X';
 cs_cust_dom_terr_ind_all         CONSTANT hcrs.calc_mthd_comp_trans_def_t.cust_domestic_ind%TYPE := '%';
 cs_cust_loc_cd_domestic          CONSTANT hcrs.prfl_cust_cls_of_trd_wrk_t.cust_loc_cd%TYPE := 'USDOM';
 cs_cust_loc_cd_territory         CONSTANT hcrs.prfl_cust_cls_of_trd_wrk_t.cust_loc_cd%TYPE := 'USTERR';
 cs_cust_loc_cd_non_us            CONSTANT hcrs.prfl_cust_cls_of_trd_wrk_t.cust_loc_cd%TYPE := 'NONUS';
 cs_cust_loc_cd_none              CONSTANT hcrs.prfl_cust_cls_of_trd_wrk_t.cust_loc_cd%TYPE := 'NONE';
 cs_cust_loc_cd_error             CONSTANT hcrs.prfl_cust_cls_of_trd_wrk_t.cust_loc_cd%TYPE := 'ERROR';
 cs_cust_loc_cd_delim             CONSTANT hcrs.prfl_cust_cls_of_trd_wrk_t.cust_loc_cd%TYPE := ',';

 -- Calc Defintions Constants for Wholesaler on Non-Chargebacks
 cs_whls_cot_grp_cd_noncbk        CONSTANT hcrs.calc_mthd_comp_trans_def_t.whls_cot_grp_cd%TYPE := cs_cot_none;
 cs_whls_cot_incl_ind_noncbk      CONSTANT hcrs.calc_mthd_comp_trans_def_t.whls_cot_incl_ind%TYPE := cs_exclude;
 cs_whls_domestic_ind_noncbk      CONSTANT hcrs.calc_mthd_comp_trans_def_t.whls_domestic_ind%TYPE := cs_cust_dom_terr_ind_ignore;
 cs_whls_territory_ind_noncbk     CONSTANT hcrs.calc_mthd_comp_trans_def_t.whls_territory_ind%TYPE := cs_cust_dom_terr_ind_ignore;
 cs_whls_loc_cd_noncbk            CONSTANT hcrs.prfl_cust_cls_of_trd_wrk_t.cust_loc_cd%TYPE := cs_cust_loc_cd_delim || cs_cust_loc_cd_none || cs_cust_loc_cd_delim;

 -- Transaction Date Constants
 cs_trans_dt_paid                 CONSTANT hcrs.calc_mthd_comp_trans_def_t.trans_dt%TYPE := 'PAID'; -- By paid date
 cs_trans_dt_earn                 CONSTANT hcrs.calc_mthd_comp_trans_def_t.trans_dt%TYPE := 'EARN'; -- By earned date

 -- Transaction Date Range Constants
 cs_trans_dt_range_qtr            CONSTANT hcrs.calc_mthd_comp_trans_def_t.trans_dt%TYPE := 'QTR'; -- Quarter/Month period
 cs_trans_dt_range_ann            CONSTANT hcrs.calc_mthd_comp_trans_def_t.trans_dt%TYPE := 'ANN'; -- Annual period
 cs_trans_dt_range_ann_off        CONSTANT hcrs.calc_mthd_comp_trans_def_t.trans_dt%TYPE := 'OFF'; -- Annual Offset period

 -- Component Dollars constants
 cs_comp_dllrs_sep                CONSTANT hcrs.calc_mthd_comp_trans_def_t.comp_dllrs%TYPE := '-'; -- Components are sometimes seperated with this
 cs_comp_dllrs_price              CONSTANT hcrs.calc_mthd_comp_trans_def_t.comp_dllrs%TYPE := 'PRC'; -- Component is a Price Point
 cs_comp_dllrs_sales              CONSTANT hcrs.calc_mthd_comp_trans_def_t.comp_dllrs%TYPE := 'SLS'; -- Component is Sales Dollars
 cs_comp_dllrs_dsc                CONSTANT hcrs.calc_mthd_comp_trans_def_t.comp_dllrs%TYPE := 'DSC'; -- Component is Discount dollars

 -- Transaction Dollars constants
 cs_trans_dllrs_none              CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_dllrs%TYPE := 'NONE'; -- No dollars
 cs_trans_dllrs_grs               CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_dllrs%TYPE := 'GRS'; -- Gross dollars
 cs_trans_dllrs_net               CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_dllrs%TYPE := 'NET'; -- Net dollars: Gross dollars less discounts
 cs_trans_dllrs_dsc               CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_dllrs%TYPE := 'DSC'; -- Discount dollars
 cs_trans_dllrs_wac               CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_dllrs%TYPE := 'WAC'; -- WAC dollar value of units
 cs_trans_dllrs_ppd               CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_dllrs%TYPE := 'PPD'; -- Prompt Payment dollars
 cs_trans_dllrs_bndl              CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_dllrs%TYPE := 'BNDL'; -- Bundle Adjustment dollars

 -- Transaction Prompt Pay Discount constants
 cs_trans_ppd_none                CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_ppd%TYPE := 'NONE'; -- Prompt Pay IS NOT a discount
 cs_trans_ppd_dsc                 CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_ppd%TYPE := 'DSC'; -- Prompt Pay IS a discount

 -- Transaction Bundling constants
 cs_trans_bndl_def                CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_bndl%TYPE := 'DEF'; -- Only considers if
 cs_trans_bndl_none               CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_bndl%TYPE := 'NONE'; -- Do NOT adjust for bundling
 cs_trans_bndl_adj                CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_bndl%TYPE := 'ADJ'; -- Adjust for bundling

 -- Transaction Packages constants
 cs_trans_pckgs_none              CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_pckgs%TYPE := 'NONE'; -- No packages
 cs_trans_pckgs_pkgs              CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_pckgs%TYPE := 'PKGS'; -- Packages
 cs_trans_pckgs_units             CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_pckgs%TYPE := 'UNITS'; -- Units

 -- Calc Method Component Transactions Definition Constants
 cs_tran_mark_accum_all           CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'ALL'; -- Mark/Accumulate All transactions
 cs_tran_mark_accum_none          CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NONE'; -- Mark/Accumulate No transactions
 cs_tran_mark_accum_nom           CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NOM'; -- Mark/Accumulate Only Nominal transactions
 cs_tran_mark_accum_hhs           CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'HHS'; -- Mark/Accumulate Only HHS violation transactions
 cs_tran_mark_accum_fssphscontr   CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'FSSPHSCONTR'; -- Mark/Accumulate Only transactions when contract is FSS/PHS
 cs_tran_mark_accum_dllrszero     CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'DLLRSZERO'; -- Mark/Accumulate Only transactions with Zero Dollars
 cs_tran_mark_accum_no_nom        CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_NOM'; -- Mark/Accumulate Only Non-Nominal transactions
 cs_tran_mark_accum_no_hhs        CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_HHS'; -- Mark/Accumulate Only Non-HHS Violation transactions
 cs_tran_mark_accum_no_fpcontr    CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_FSSPHSCONTR'; -- Mark/Accumulate Only transactions when contract not is FSS/PHS
 cs_tran_mark_accum_dllrsnonz     CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'DLLRSNONZERO'; -- Mark/Accumulate Only transactions with Non-Zero Dollars
 cs_tran_mark_accum_no_nom_hhs    CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_NOM_HHS'; -- Mark/Accumulate Only Non-Nominal and Non-HHS Violation transactions
 cs_tran_mark_accum_no_nhfpc      CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_NOM_HHS_FSSPHSCONTR'; -- Mark/Accumulate Only Non-Nominal, Non-HHS Violation, and contract is not FSS/PHS
 cs_tran_mark_accum_no_nhdz       CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_NOM_HHS_DLLRSZERO'; -- Mark/Accumulate Only Non-Nominal, Non-HHS Violation, Non-Zero Dollars transactions
 cs_tran_mark_accum_no_nhfpcdz    CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_NOM_HHS_FSSPHSCONTR_DLLRSZERO'; -- Mark/Accumulate Only Non-Nominal, Non-HHS Violation, Non-Zero Dollars transactions, and contract is not FSS/PHS
 cs_tran_mark_accum_no_nom_fpc    CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_NOM_FSSPHSCONTR'; -- Mark/Accumulate Only Non-Nominal, and contract is not FSS/PHS
 cs_tran_mark_accum_no_nom_dz     CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_NOM_DLLRSZERO'; -- Mark/Accumulate Only Non-Nominal, Non-Zero Dollars transactions
 cs_tran_mark_accum_no_nfpcdz     CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_NOM_FSSPHSCONTR_DLLRSZERO'; -- Mark/Accumulate Only Non-Nominal, Non-Zero Dollars transactions, and contract is not FSS/PHS
 cs_tran_mark_accum_no_hhs_fpc    CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_HHS_FSSPHSCONTR';  -- Mark/Accumulate Only Non-HHS Violation transactions and contract is not FSS/PHS
 cs_tran_mark_accum_no_hhs_dz     CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_HHS_DLLRSZERO'; -- Mark/Accumulate Only Non-HHS Violation, Non-Zero Dollars transactions
 cs_tran_mark_accum_no_hfpcdz     CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_HHS_FSSPHSCONTR_DLLRSZERO'; -- Mark/Accumulate Only Non-HHS Violation, Non-Zero Dollars transactions, and contract is not FSS/PHS
 cs_tran_mark_accum_no_fpcdz      CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_FSSPHSCONTR_DLLRSZERO'; -- Mark/Accumulate Only Non-Zero Dollars transactions, and contract is not FSS/PHS
 cs_tran_mark_accum_contr         CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'CONTR'; -- Mark/Accumulate only contracted transactions
 cs_tran_mark_accum_no_contr      CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_CONTR'; -- Mark/Accumulate only non-contracted transactions
 cs_tran_mark_accum_no_nom_cont   CONSTANT hcrs.calc_mthd_comp_trans_def_t.tran_mark_accum%TYPE := 'NO_NOM_CONTR'; -- Mark/Accumulate only non-nominal and non-contracted transactions

 -- Calculation Component Constants - Make sure the values does exists in 'comp_typ_t' table.
 -- Transaction based values
 -- Gross Direct
 cs_qtly_grs_dct_units            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QGDU'; -- Qtly Gross Direct Units
 cs_qtly_grs_dct_dollars          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QGDD'; -- Qtly Gross Direct Dollars
 cs_ann_grs_dct_units             CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AGDU'; -- Annual Gross Direct Units
 cs_ann_grs_dct_dollars           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AGDD'; -- Annual Gross Direct Dollars
 -- Eligible Direct
 cs_qtly_elg_dct_units            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QEDU'; -- Qtly Eligible Direct Units
 cs_qtly_elg_dct_dollars          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QEDD'; -- Qtly Eligible Direct Dollars
 cs_ann_elg_dct_units             CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AEDU'; -- Annual Eligible Direct Units
 cs_ann_elg_dct_dollars           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AEDD'; -- Annual Eligible Direct Dollars
 -- Ineligible Direct
 cs_qtly_inelg_dct_units          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QIDU'; -- Qtly Ineligible Direct Units
 cs_qtly_inelg_dct_dollars        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QIDD'; -- Qtly Ineligible Direct Dollars
 cs_ann_inelg_dct_units           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AIDU'; -- Annual Ineligible Direct Units
 cs_ann_inelg_dct_dollars         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AIDD'; -- Annual Ineligible Direct Dollars
 -- Wholesaler Direct
 cs_qtly_whls_dct_units           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QWDU'; -- Qtly Wholesaler Direct Units
 cs_qtly_whls_dct_dollars         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QWDD'; -- Qtly Wholesaler Direct Dollars
 cs_ann_whls_dct_units            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AWDU'; -- Annual Wholesaler Direct Units
 cs_ann_whls_dct_dollars          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AWDD'; -- Annual Wholesaler Direct Dollars
 -- Offset Wholesaler Direct
 cs_ann_off_whls_dct_units        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AOWDU'; -- Annual Offset Wholesaler Direct Units
 cs_ann_off_whls_dct_dollars      CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AOWDD'; -- Annual Offset Wholesaler Direct Dollars
 -- Eligible Chargebacks
 cs_qtly_chgbck_dollars           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QCD'; -- Qtly Chargeback Dollars
 cs_qtly_chgbck_units             CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QCU'; -- Qtly Chargeback Units
 cs_ann_chgbck_dollars            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ACD'; -- Annual Chargeback Dollars
 cs_ann_chgbck_units              CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ACU'; -- Annual Chargeback Units
 -- Ineligible Indirect
 cs_qtly_inelg_indct_units        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QIIU'; -- Qtly Ineligible Indirect Units
 cs_qtly_inelg_indct_dollars      CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QIID'; -- Qtly Ineligible Indirect Dollars
 cs_ann_inelg_indct_units         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AIIU'; -- Annual Ineligible Indirect Units
 cs_ann_inelg_indct_dollars       CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AIID'; -- Annual Ineligible Indirect Dollars
 -- Eligible Indirect
 cs_qtly_elg_indct_units          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QEIU'; -- Qtly Eligible Indirect Units
 cs_qtly_elg_indct_dollars        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QEID'; -- Qtly Eligible Indirect Dollars
 cs_ann_elg_indct_units           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AEIU'; -- Annual Eligible Indirect Units
 cs_ann_elg_indct_dollars         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AEID'; -- Annual Eligible Indirect Dollars
 -- Special Programs
 cs_qtly_spcprg_dollars           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QSPRD'; -- Quarterly Special Program Dollars
 cs_qtly_spcprg_units             CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QSPRU'; -- Quarterly Special Program Units
 cs_ann_spcprg_dollars            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ASPRD'; -- Annual Special Program Dollars
 cs_ann_spcprg_units              CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ASPRU'; -- Annual Special Program Units
 -- Excluded Sales
 cs_qtly_excl_sls_units           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QESU'; -- Qtly Excluded Sales Units
 cs_qtly_excl_sls_dollars         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QESD'; -- Qtly Excluded Sales Dollars
 cs_ann_excl_sls_units            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AESU'; -- Annual Excluded Sales Units
 cs_ann_excl_sls_dollars          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AESD'; -- Annual Excluded Sales Dollars
 -- Gross AMP Sales
 cs_qtly_grs_amp_units            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QGAU'; -- Qtly Gross AMP Units
 cs_qtly_grs_amp_dollars          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QGAD'; -- Qtly Gross AMP Dollars
 cs_ann_grs_amp_units             CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AGAU'; -- Annual Gross AMP Units
 cs_ann_grs_amp_dollars           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AGAD'; -- Annual Gross AMP Dollars
 -- Gross ASP Sales
 cs_qtly_grs_asp_units            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QGAU'; -- Qtly Gross ASP Units
 cs_qtly_grs_asp_dollars          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QGAD'; -- Qtly Gross ASP Dollars
 cs_ann_grs_asp_units             CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AGAU'; -- Annual Gross ASP Units
 cs_ann_grs_asp_dollars           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AGAD'; -- Annual Gross ASP Dollars
 -- Gross NonFAMP Sales
 cs_qtly_grs_nfamp_units          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QGNU'; -- Qtly Gross NonFAMP Units
 cs_qtly_grs_nfamp_dollars        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QGND'; -- Qtly Gross NonFAMP Dollars
 cs_ann_grs_nfamp_units           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AGNU'; -- Annual Gross NonFAMP Units
 cs_ann_grs_nfamp_dollars         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AGND'; -- Annual Gross NonFAMP Dollars
 -- Rebate/Fee
 cs_qtly_rbtfee_dollars           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QRFD'; -- Quarterly Rebate/Fee Dollars
 cs_ann_rbtfee_dollars            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ARFD'; -- Annual Rebate/Fee Dollars
 -- Rebates
 cs_qtly_rbt_dollars              CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QRD'; -- Quarterly Rebate Dollars
 cs_ann_rbt_dollars               CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ARD'; -- Annual Rebate Dollars
 -- Fees
 cs_qtly_fee_dollars              CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QFD'; -- Quarterly Fee Dollars
 cs_ann_fee_dollars               CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AFD'; -- Annual Fee Dollars
 -- Authorized Generics
 cs_qtly_auth_gen_dollars         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QAGD'; -- Quarterly Authorized Generic Dollars
 cs_qtly_auth_gen_units           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QAGU'; -- Quarterly Authorized Generic Units
 cs_ann_auth_gen_dollars          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AAGD'; -- Annual Authorized Generic Dollars
 cs_ann_auth_gen_units            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AAGU'; -- Annual Authorized Generic Units
 -- Prompt Pay
 cs_qtly_prmpt_pay_dollars        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QPPD'; -- Quarterly Prompt Pay Dollars
 cs_qtly_prmpt_pay_units          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QPPU'; -- Quarterly Prompt Pay Units
 cs_ann_prmpt_pay_dollars         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'APPD'; -- Annual Prompt Pay Dollars
 cs_ann_prmpt_pay_units           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'APPU'; -- Annual Prompt Pay Units
 -- Nominals
 cs_qtly_nom_dollars              CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QND'; -- Quarterly Nominal Dollars
 cs_qtly_nom_units                CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QNU'; -- Quarterly Nominal Units
 cs_ann_nom_dollars               CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AND'; -- Annual Nominal Dollars
 cs_ann_nom_units                 CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ANU'; -- Annual Nominal Units
 -- Competitive Acquisition Program
 cs_qtly_cap_dollars              CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QCAPD'; -- Quarterly Competitive Acquisition Program Dollars
 cs_qtly_cap_units                CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QCAPU'; -- Quarterly Competitive Acquisition Program Units
 cs_ann_cap_dollars               CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ACAPD'; -- Annual Competitive Acquisition Program Dollars
 cs_ann_cap_units                 CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ACAPU'; -- Annual Competitive Acquisition Program Units
 -- Calculated values
 -- Net Eligible Direct
 cs_qtly_net_dct_dollars          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QNEDD'; -- Qtly Net Eligible Direct Dollars
 cs_qtly_net_dct_units            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QNEDU'; -- Qtly Net Eligible Direct Units
 cs_ann_net_dct_dollars           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ANEDD'; -- Annual Net Eligible Direct Dollars
 cs_ann_net_dct_units             CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ANEDU'; -- Annual Net Eligible Direct Units
 -- Net2 Eligible Direct
 cs_qtly_net2_dct_dollars         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QN2EDD'; -- Qtly Net2 Eligible Direct Dollars
 cs_qtly_net2_dct_units           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QN2EDU'; -- Qtly Net2 Eligible Direct Units
 cs_ann_net2_dct_dollars          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AN2EDD'; -- Annual Net2 Eligible Direct Dollars
 cs_ann_net2_dct_units            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AN2EDU'; -- Annual Net2 Eligible Direct Units
 -- Eligible Wholesaler Direct
 cs_qtly_elg_whls_dir_dollars     CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QEWDD'; -- Qtly Eligible Wholesaler Direct Dollars
 cs_qtly_elg_whls_dir_units       CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QEWDU'; -- Qtly Eligible Wholesaler Direct Units
 cs_ann_elg_whls_dir_dollars      CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AEWDD'; -- Annual Eligible Wholesaler Direct Dollars
 cs_ann_elg_whls_dir_units        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AEWDU'; -- Annual Eligible Wholesaler Direct Units
 -- Ineligible Wholesaler Direct
 cs_qtly_inelg_whls_dir_units     CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QIWDU'; -- Qtly Ineligible Wholesaler Direct Units
 cs_ann_inelg_whls_dir_units      CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AIWDU'; -- Annual Ineligible Wholesaler Direct Units
 -- Average Unit Prices
 cs_avg_elg_unit_price            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AEDUP'; -- Average Eligible Direct Unit Price
 cs_avg_whls_unit_price           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AWDUP'; -- Average Wholesaler Direct Unit Price
 cs_avg_chgbck_unit_price         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ACUP'; -- Average Chargeback Unit Price
 cs_avg_inelg_unit_price          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AIIUP'; -- Average Ineligible Indirect Unit Price
 -- Smoothing Ratios
 cs_chgbck_smoothing_ratio        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'CSR'; -- Chargeback Smoothing Ratio
 cs_inelg_smoothing_ratio         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'IISR'; -- Ineligible Indirect Smoothing Ratio
 cs_rbtfee_smoothing_ratio        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'RFSR'; -- Rebate/Fee Smoothing Ratio
 cs_spcprg_smoothing_ratio        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'SPRSR'; -- Special Program Smoothing Ratio
 cs_rbt_smoothing_ratio           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'RSR'; -- Rebate Smoothing Ratio
 -- Smoothed Components
 cs_qtly_smthed_chgbck_dollars    CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'SQCD'; -- Smoothed Qtly Chargeback Dollars
 cs_qtly_smthed_chgbck_units      CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'SQCU'; -- Smoothed Qtly Chargeback Units
 cs_ann_smthed_chgbck_dollars     CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'SACD'; -- Smoothed Ann Chargeback Dollars
 cs_qtly_smthed_inelg_dollars     CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'SQIID'; -- Smoothed Qtly Ineligible Indirect Dollars
 cs_qtly_smthed_inelg_units       CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'SQIIU'; -- Smoothed Qtly Ineligible Indirect Units
 cs_ann_smthed_inelg_dollars      CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'SAIID'; -- Smoothed Ann Ineligible Indirect Dollars
 cs_ann_smthed_inelg_units        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'SAIIU'; -- Smoothed Ann Ineligible Indirect Units
 cs_qtly_smthed_spcprg_dollars    CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'SQSPRD'; -- Smoothed Quarterly Special Program Dollars
 cs_qtly_smthed_spcprg_units      CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'SQSPRU'; -- Smoothed Quarterly Special Program Units
 cs_qtly_smthed_rbtfee_dollars    CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'SQRFD'; -- Smoothed Quarterly Rebate/Fee Dollars
 cs_qtly_smthed_rbt_dollars       CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'SQRD'; -- Smoothed Quarterly Rebate Dollars

 -- Actual (PPACA Final Rule v1) Calculation Method components
 cs_qtly_f_rbt_fee_dollars       CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QFRFD'; -- Quarterly Factored Rebate Fee Dollars
 cs_qtly_f_rbt_fee_units         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QFRFU'; -- Quarterly Factored Rebate Fee Units
 cs_ann_f_rbt_fee_dollars        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AFRFD'; -- Annual Factored Rebate Fee Dollars
 cs_ann_f_rbt_fee_units          CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AFRFU'; -- Annual Factored Rebate Fee Units
 cs_qtly_nf_rbt_fee_dollars      CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QNFRFD'; -- Quarterly Non-Factored Rebate Fee Dollars
 cs_qtly_nf_rbt_fee_units        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QNFRFU'; -- Quarterly Non-Factored Rebate Fee Units
 cs_ann_nf_rbt_fee_dollars       CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ANFRFD'; -- Annual Non-Factored Rebate Fee Dollars
 cs_ann_nf_rbt_fee_units         CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ANFRFU'; -- Annual Non-Factored Rebate Fee Units
 cs_reb_fee_factoring_ratio      CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'RFFR'; -- Rebate Fee Factoring Ratio
 cs_ann_adj_f_reb_fee_dollars    CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AAFRFD'; -- Annual Adjusted Factored Rebate/Fee Dollars
 cs_qtly_adj_f_reb_fee_dollars   CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'QAFRFD'; -- Quarterly Adjusted Factored Rebate/Fee Dollars
 cs_whlslr_dir_unit_ratio        CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'WDUR'; --Wholesaler Direct Unit Ratio

 -- Variables
 cs_nominal_dollars_cd            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ND'; -- Nominal threshold Dollars
 cs_amp_wac                       CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'WAC'; -- Quarterly WAC (weighted average)
 cs_asp_wac                       CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'WAC'; -- Quarterly WAC (weighted average)
 -- AMP Components
 cs_amp_dollars                   CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AMPD'; -- AMP Dollars
 cs_amp_units                     CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AMPU'; -- AMP Units
 cs_amp_units_sub                 CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AMPU-SUB'; -- AMP Units for Submission
 cs_amp                           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AMP'; -- Quarterly AMP
 cs_amp_mcomp_base                CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := '-M'; -- The -M for M Components
 cs_amp_bmcomp_base               CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := '-BM'; -- The -BM for BM Components

 -- BP Components
 cs_bp_realised_mthd_typ_cd       CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'RM'; -- Realised Method
 cs_bp_fcst_mthd_typ_cd           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FM'; -- Forecasted Method
 cs_bp                            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'BP'; -- BP Component
 -- ASP Components
 cs_asp_dollars                   CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ASPD'; -- ASP Dollars
 cs_asp_units                     CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ASPU'; -- ASP Units
 cs_asp                           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'ASP'; -- Quarterly ASP
 -- NFAMP Components
 cs_nonfamp_wac                   CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'WAC';   -- Weighted WAC
 cs_hhs_pl102_violation           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'HHS PL102' ; -- HHS PL102 Price Violation
 cs_nonfamp_dollars               CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'NFD'; -- NonFAMP Dollars
 cs_nonfamp_units                 CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'NFU'; -- NonFAMP Units
 cs_nonfamp                       CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'NFAMP';   -- NonFamp Compuation
 cs_nonfamp_over                  CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'NFAMPOVER';   -- NonFamp Override
 cs_nonfamp_orig                  CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'NFAMPORIG';   -- NonFamp Original
 -- FCP Components
 cs_fcp_addl_discount             CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'AD'; -- Additional Discount
 cs_fcp_ccp                       CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'CCP'; -- Calculated Ceiling Price
 cs_fcp_max_fss                   CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'MAFP'; -- Maximum Allowable FSS Price
 cs_fcp                           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FCP';  -- FCP
 cs_fcp_orig                      CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FCPORIG';  -- FCP Original
 cs_fcp_over                      CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FCPOVER';  -- FCP Override
 cs_fcp_fss_contr_perm            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FSSCPERM'; -- FSS Contract Permanent Pricing
 cs_fcp_fss_contr_annl            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FSSCANNL'; -- FSS Contract Previous Annual
 cs_fcp_fss_contr_ffq             CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FSSCFFQ'; -- FSS Contract First Full Qtr
 cs_fcp_fss_contr_30day           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FSSC30DAY'; -- FSS Contract First Full Qtr
 cs_fcp_fss_contr_over            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FSSCOVER'; -- FSS Contract Override
 cs_fcp_fss_contr_none            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FSSCNONE'; -- FSS Contract Not found
 cs_fcp_curr_nfamp_3q             CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'CURR3Q'; -- Current NFAMP Third Quarter
 cs_fcp_curr_nfamp_ffq            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'CURRFFQ'; -- Current NFAMP First Full Qtr
 cs_fcp_curr_nfamp_over           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'CURROVER'; -- Current NFAMP Override
 cs_fcp_prev_fcp                  CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FCPPREV'; -- Previous Annual FCP
 cs_fcp_prev_fcp_ffq              CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FCPPREVFFQ'; -- Previous FFQ FCP
 cs_fcp_prev_fcp_over             CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'FCPPREVOVER'; -- Previous Annual FCP override
 cs_fcp_prev_nfamp_3q             CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'PREV3Q'; -- Previous NFAMP Third Quarter
 cs_fcp_prev_nfamp_ffq            CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'PREVFFQ'; -- Previous NFAMP First Full Qtr
 cs_fcp_prev_nfamp_none           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'PREVNONE'; -- Previous NFAMP Not Found
 cs_fcp_prev_nfamp_over           CONSTANT hcrs.comp_typ_t.comp_typ_cd%TYPE := 'PREVOVER'; -- Previous NFAMP Override
 cs_fcp_src_fss_ind               CONSTANT hcrs.misc_cd_dtl_t.dtl_cd%TYPE := 'F' ; -- Max FSS
 cs_fcp_src_ccp_ind               CONSTANT hcrs.misc_cd_dtl_t.dtl_cd%TYPE := 'C' ; -- CCP
 cs_fcp_src_ovr_ind               CONSTANT hcrs.misc_cd_dtl_t.dtl_cd%TYPE := 'O' ; -- Override

 -- Other calculations constants
 cs_carryfwd_ind                  CONSTANT hcrs.prfl_prod_calc_t.carry_fwd_ind%TYPE := 'C'; -- Carry/Fwd Indicator

 -- COC Constants
 cs_coc_comp_typ_cntrct           CONSTANT hcrs.coc_comp_typ_t.coc_comp_typ_cd%TYPE := 'CONTR'; -- Contract component type
 cs_coc_comp_typ_cot              CONSTANT hcrs.coc_comp_typ_t.coc_comp_typ_cd%TYPE := 'COT'; -- COT component type
 cs_coc_comp_typ_wac              CONSTANT hcrs.coc_comp_typ_t.coc_comp_typ_cd%TYPE := 'WAC'; -- WAC component type
 cs_coc_comp_typ_bunit_num        CONSTANT hcrs.coc_comp_typ_t.coc_comp_typ_cd%TYPE := 'BUNIT_NUM'; -- Contract Entity component type
 cs_coc_eff_dt_param_seq_no       CONSTANT hcrs.prcss_param_t.prcss_param_seq_no%TYPE:= 1; -- represents the "Effective Date"
 cs_coc_job_name                  CONSTANT hcrs.prcss_queue_t.exec_nm%TYPE := 'gpcs_coc.sh'; -- The job shell script

 -- Transaction Record Source Indicators
 cs_rec_src_manual                CONSTANT hcrs.mstr_trans_t.rec_src_ind%TYPE := 'M';  -- Records from Manual adjustments
 cs_rec_src_icw                   CONSTANT hcrs.mstr_trans_t.rec_src_ind%TYPE := 'I';  -- Records from ICW
 cs_rec_src_cosmis                CONSTANT hcrs.mstr_trans_t.rec_src_ind%TYPE := 'C';  -- Records from COSMIS
 cs_rec_src_gnz                   CONSTANT hcrs.mstr_trans_t.rec_src_ind%TYPE := 'G';  -- Records from GENZYME (via ICW)
 cs_rec_src_pst                   CONSTANT hcrs.mstr_trans_t.rec_src_ind%TYPE := 'P';  -- Records from PASTEUR (via ICW)

 -- Data Source Company Identifiers
 cs_co_icw                        CONSTANT hcrs.mstr_trans_t.co_id%TYPE := 121;  -- Data from ICW
 cs_co_cosmis                     CONSTANT hcrs.mstr_trans_t.co_id%TYPE := 122;  -- Data from COSMIS
 cs_co_gnz                        CONSTANT hcrs.mstr_trans_t.co_id%TYPE := 123;  -- Data from GENZYME (via ICW)
 cs_co_pst                        CONSTANT hcrs.mstr_trans_t.co_id%TYPE := 124;  -- Data from PASTEUR (via ICW)

 -- PUR Constants
 cs_pur                           CONSTANT hcrs.pur_calc_request_t.request_typ_cd%TYPE := 'PUR'; -- PUR calculation request type
 cs_activation                    CONSTANT hcrs.error_log_t.calc_typ_cd%TYPE := 'PUR ACTIVATION'; -- PUR activation type
 cs_awp_typ_cd                    CONSTANT hcrs.prod_price_t.prod_price_typ_cd%TYPE := 'AWP'; -- Average Wholesaler price
 cs_val_typ_user                  CONSTANT hcrs.pur_val_typ_t.val_typ_cd%TYPE := 'USER'; -- User value type
 cs_val_typ_system                CONSTANT hcrs.pur_val_typ_t.val_typ_cd%TYPE := 'SYSTEM'; -- System value type
 cs_val_typ_sysval                CONSTANT hcrs.pur_val_typ_t.val_typ_cd%TYPE := 'SYSVAL'; -- System value type
 cs_val_typ_na                    CONSTANT hcrs.pur_val_typ_t.val_typ_cd%TYPE := 'N/A'; -- NA value type
 cs_comp_typ_operand              CONSTANT hcrs.pur_comp_t.comp_typ_cd%TYPE := 'OPERAND'; -- Operand component type
 cs_comp_typ_operator             CONSTANT hcrs.pur_comp_t.comp_typ_cd%TYPE := 'OPERATOR'; -- Operand component type
 cs_comp_typ_formula              CONSTANT hcrs.pur_comp_t.comp_typ_cd%TYPE := 'FORMULA'; -- Operand component type
 cs_fdrl_min_formula_id           CONSTANT hcrs.pur_formula_t.formula_id%TYPE := 5; -- The Federal Minimum formula ID
 cs_fdrl_disc_comp_id             CONSTANT hcrs.pur_comp_t.comp_id%TYPE := 103; -- The Federal Discount component ID
 cs_fdrl_pen_comp_id              CONSTANT hcrs.pur_comp_t.comp_id%TYPE := 93; -- The Federal Penalty component ID
 cs_pace_paga_pen_comp_id         CONSTANT hcrs.pur_comp_t.comp_id%TYPE := 105; --The PACE PAGA Penalty component ID
 cs_ny_epic_pen_comp_id           CONSTANT hcrs.pur_comp_t.comp_id%TYPE := 104; --The NYEPIC Penalty component ID
 cs_awp_comp_id                   CONSTANT hcrs.pur_comp_t.comp_id%TYPE := 97; --The AWP component ID
 cs_base_pct                      CONSTANT hcrs.pur_comp_t.comp_id%TYPE := 100; --The Base percent component ID
 cs_cap_pct                       CONSTANT hcrs.pur_comp_t.comp_id%TYPE := 101; --The CAP percent component ID
 cs_first_awp_comp_id             CONSTANT hcrs.pur_comp_t.comp_id%TYPE := 118; --The First AWP component ID
 cs_last_awp_comp_id              CONSTANT hcrs.pur_comp_t.comp_id%TYPE := 119; --The Last AWP component ID
 cs_first_wac_comp_id             CONSTANT hcrs.pur_comp_t.comp_id%TYPE := 32; --The First WAC component ID
 cs_last_wac_comp_id              CONSTANT hcrs.pur_comp_t.comp_id%TYPE := 33; --The Last WAC component ID
 cs_prec_round                    CONSTANT hcrs.pur_formula_precision_t.sql_func%TYPE := 'ROUND'; -- Round code
 cs_prec_trunc                    CONSTANT hcrs.pur_formula_precision_t.sql_func%TYPE := 'TRUNC'; -- Trunc code
 cs_stat_approved_cd              CONSTANT hcrs.pur_apprvd_stat_t.apprvd_stat_cd%TYPE := 'APPROVED' ; -- Profile Status Code - Approved
 cs_pur_calc                      CONSTANT hcrs.prcss_batch_t.exec_nm%TYPE := 'pur_calc.sh'; -- PUR shell
 cs_p_run_pur_calc                CONSTANT VARCHAR2(50) := 'pkg_pur_calc.p_run_calc'; -- PUR calculation procedure
 cs_default_sql_func              CONSTANT VARCHAR2(10) := 'ROUND'; -- PUR default SQL function
 cs_default_precision             CONSTANT NUMBER := 7; -- PUR default precision
 cs_boundary_qtr                  CONSTANT hcrs.pur_boundary_typ_t.boundary_cd%TYPE := 'QTR'; -- Quarter boundary
 cs_ovrrd_lvl_pckg                CONSTANT VARCHAR2(10) := 'PCKG'; -- Package Override level
 cs_ovrrd_lvl_catg                CONSTANT VARCHAR2(10) := 'CATG'; -- Category Override level
 cs_calc_step_interim             CONSTANT hcrs.pur_calc_step_t.calc_step%TYPE := 'INTERIM'; -- Interim calculation step
 cs_calc_step_final               CONSTANT hcrs.pur_calc_step_t.calc_step%TYPE := 'FINAL'; -- Final calculation step
 cs_comp_code_input_parm          CONSTANT hcrs.pur_comp_t.comp_cd%TYPE := '@'; -- Input parameter indicator
 cs_tcap_pct                      CONSTANT hcrs.pur_comp_t.comp_id%TYPE := 134; --The Total URA CAP percent component ID
 cs_tcap_comp_cd                  CONSTANT hcrs.pur_comp_t.comp_cd%TYPE := 'TCAP %'; --The Total URA CAP percent component code
 cs_fdrl_pen_formula_id           CONSTANT hcrs.pur_formula_t.formula_id%TYPE := 7; -- The Federal CPI Penalty formula ID
 cs_fdrl_disc_formula_id          CONSTANT hcrs.pur_formula_t.formula_id%TYPE := 4; -- The Federal discount formula ID

 -- PUR Component Category
 cs_pur_comp_catg_cd_min          CONSTANT hcrs.pur_comp_catg_t.comp_catg_cd%TYPE := 'MIN'; -- Minimum
 cs_pur_comp_catg_cd_disc         CONSTANT hcrs.pur_comp_catg_t.comp_catg_cd%TYPE := 'DISC'; -- Discount
 cs_pur_comp_catg_cd_pen          CONSTANT hcrs.pur_comp_catg_t.comp_catg_cd%TYPE := 'PEN'; -- Penalty

 -- Change Log Status Codes
 cs_chg_log_stat_cd_lg            CONSTANT hcrs.chg_log_det_t.chg_log_stat_cd%TYPE := 'LG'; -- Logged type
 cs_chg_log_stat_cd_op            CONSTANT hcrs.chg_log_det_t.chg_log_stat_cd%TYPE := 'OP'; -- Open type
 cs_chg_log_stat_cd_              CONSTANT hcrs.chg_log_det_t.chg_log_stat_cd%TYPE := 'OP'; -- Open type
 cs_chg_log_stat_cd_pc            CONSTANT hcrs.chg_log_det_t.chg_log_stat_cd%TYPE := 'PC'; -- Processed type

 -- Price Mod Effect Type Codes
 cs_price_mod_eff_typ_cd_fi       CONSTANT hcrs.price_mod_eff_typ_t.price_mod_eff_typ_cd%TYPE := 'FI'; -- Filing Code
 cs_price_mod_eff_typ_cd_pr       CONSTANT hcrs.price_mod_eff_typ_t.price_mod_eff_typ_cd%TYPE := 'PR'; -- Pricing Code
 cs_price_mod_eff_typ_cd_pu       CONSTANT hcrs.price_mod_eff_typ_t.price_mod_eff_typ_cd%TYPE := 'PU'; -- PUR Calc code
 cs_price_mod_eff_typ_cd_rc       CONSTANT hcrs.price_mod_eff_typ_t.price_mod_eff_typ_cd%TYPE := 'RC'; -- Rebate Claim Code

 -- Price Mod Process Codes
 cs_price_mod_prcss_cd_fil        CONSTANT hcrs.price_mod_prcss_t.price_mod_prcss_cd%TYPE := 'FIL'; -- Medicaid filing
 cs_price_mod_prcss_cd_fia        CONSTANT hcrs.price_mod_prcss_t.price_mod_prcss_cd%TYPE := 'FIA'; -- Medicare ASP filing

 -- Pricing Type Constants
 cs_price_typ_cd_wac              CONSTANT hcrs.prod_price_typ_t.prod_price_typ_cd%TYPE := 'WAC'; -- WAC price type
 cs_price_typ_cd_awp              CONSTANT hcrs.prod_price_typ_t.prod_price_typ_cd%TYPE := 'AWP'; -- AWP price type
 cs_price_typ_cd_lp               CONSTANT hcrs.prod_price_typ_t.prod_price_typ_cd%TYPE := 'LP'; -- LP price type
 cs_price_typ_cd_pl102            CONSTANT hcrs.prod_price_typ_t.prod_price_typ_cd%TYPE := 'PL 102'; -- PL 102 price type
 cs_price_per_first               CONSTANT VARCHAR2( 10) := 'FIRST'; -- First price in effect for the quarter
 cs_price_per_last                CONSTANT VARCHAR2( 10) := 'LAST'; -- Last price in effect for the quarter
 cs_price_per_avg                 CONSTANT VARCHAR2( 10) := 'AVERAGE'; -- Average of all prices in effect for the quarter
 cs_price_per_wtd                 CONSTANT VARCHAR2( 10) := 'WEIGHTED'; -- Weighted Average of all prices in effect for the quarter
 cs_price_per_min                 CONSTANT VARCHAR2( 10) := 'MINIMUM'; -- Minimum of all prices in effect for the quarter
 cs_price_per_max                 CONSTANT VARCHAR2( 10) := 'MAXIMUM'; -- Maximum of all prices in effect for the quarter

 -- Customer Source System Suffix Codes
 cs_cust_cars                     CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'C';
 cs_cust_sap                      CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'S';
 cs_cust_sap4h                    CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'A';
 cs_cust_hcrs                     CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'H';
 cs_cust_pst                      CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'P';
 cs_cust_pst_hcrs                 CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'Z';
 cs_cust_gnz                      CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'G';
 cs_cust_gnz_hcrs                 CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'Y';
 cs_cust_sny_jde                  CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'J';
 cs_cust_sny_cars                 CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'N';
 cs_cust_gpcs_man                 CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := '-';
 cs_cust_icon                     CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'I';
 cs_cust_cosmis                   CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'X';

 -- Transaction Source System Codes
 cs_system_gpcsmanual             CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'GPCSMANUAL';
 cs_system_cars                   CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'CARS';
 cs_system_cars24                 CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'CARS24';
 cs_system_cosmis                 CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'COSMIS';
 cs_system_icon                   CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'ICON';
 cs_system_manual                 CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'MANUAL';
 cs_system_sap                    CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'SAP';
 cs_system_sap4h                  CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'SAP4H';
 cs_system_hcrs                   CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'HCRS';
 cs_system_xenon                  CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'XENON'; -- Xenon data original format
 cs_system_x360                   CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'X360'; -- Xenon data corrected format
 cs_system_prasco                 CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'PRASCO';
 cs_system_bivvrxc                CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'BIVVRXC'; -- Bioverativ - Direct/Indirect from RxCrossroads
 cs_system_bivvccg                CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'BIVVCCG'; -- Bioverativ - Rebates/Fees from Integrichain (Cumberland Consulting Group) FLEX
 cs_system_bibbmed                CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'BIBBMED'; -- Bioverativ - Biogen Medicaid from Integrichain (Cumberland Consulting Group) FLEX
 cs_system_gnzics                 CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'GNZICS'; -- Genzyme ICS
 cs_system_gnzups                 CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'GNZUPS'; -- Genzyme UPS
 cs_system_gnzabs                 CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'GNZABS'; -- Genzyme ABS
 cs_system_gnzabsg                CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'GNZABSG'; -- Genzyme ABSG
 cs_system_gnzmfg                 CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'GNZMFG'; -- Genzyme MFGPro
 cs_system_gnzmanual              CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'GNZMANUAL'; -- Genzyme Manual
 cs_system_gnzhcrs                CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'GNZHCRS'; -- Genzyme HCRS data (pre-ICW integration)
 cs_system_gnz                    CONSTANT hcrs.mstr_trans_t.source_sys_cde%TYPE := 'GNZ'; -- Genzyme Legacy Data in ICW2 interpreted

 -- Calculation Transaction Adjustment Codes
 cs_trans_adj_original            CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'ORIGINAL';      -- Original trasaction
 cs_trans_adj_sap_rollup          CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'SAP_ROLLUP';    -- SAP/SAP4H Line item rollup
 cs_trans_adj_sap_adj             CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'SAP_ADJ';       -- SAP/SAP4H adjustment
 cs_trans_adj_cars_rollup         CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'CARS_ROLLUP';   -- CARS rollup correction
 cs_trans_adj_cars_rbt_fee        CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'CARS_RBT_FEE';  -- CARS Rebate/Fee applied to Chargeback
 cs_trans_adj_cars_adj            CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'CARS_ADJ';      -- CARS Resubmitted Correction
 cs_trans_adj_icw_key             CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'ICW_KEY';       -- CARS Submission from ICW
 cs_trans_adj_x360_rollup         CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'X360_ROLLUP';   -- X360 Line item rollup
 cs_trans_adj_x360_adj            CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'X360_ADJ';      -- X360 Adjustment
 cs_trans_adj_prasco_rollup       CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'PRASCO_ROLLUP'; -- Prasco Line item rollup
 cs_trans_adj_prasco_rbtfee       CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'PRASCO_RBTFEE'; -- Prasco Rebate/Fee Link
 cs_trans_adj_rollup              CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'ROLLUP';        -- Other Line item rollup
 cs_trans_adj_bivv_rollup         CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'BIVV_ROLLUP';   -- Bioverativ Line item rollup
 cs_trans_adj_bivv_adj            CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'BIVV_ADJ';      -- Bioverativ adjustment
 cs_trans_adj_estimate            CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'ESTIMATE';      -- Line item created by Split Percentage Estimates
 cs_trans_adj_bndl_adj            CONSTANT hcrs.trans_adj_t.trans_adj_cd%TYPE := 'BNDL_ADJ';      -- Line item created by Bundling Adjustments

 -- Source Transaction types (Sales/Credits)
 cs_source_trans_sales            CONSTANT hcrs.mstr_trans_t.source_trans_typ%TYPE := 'S'; -- Sales
 cs_source_trans_credits          CONSTANT hcrs.mstr_trans_t.source_trans_typ%TYPE := 'C'; -- Credits

 -- Transaction Class Codes
 cs_trans_cls_dir                 CONSTANT hcrs.mstr_trans_t.trans_cls_cd%TYPE := 'D'; -- Directs
 cs_trans_cls_idr                 CONSTANT hcrs.mstr_trans_t.trans_cls_cd%TYPE := 'I'; -- Indirects
 cs_trans_cls_rbt                 CONSTANT hcrs.mstr_trans_t.trans_cls_cd%TYPE := 'R'; -- Rebates
 cs_trans_cls_icw_key             CONSTANT hcrs.mstr_trans_t.trans_cls_cd%TYPE := 'K'; -- ICW_KEY
-- cs_trans_cls_rbt_dir_icw_key     CONSTANT hcrs.mstr_trans_t.trans_cls_cd%TYPE := cs_trans_cls_rbt || cs_trans_cls_dir || cs_trans_cls_icw_key;  -- Rebates on Direct Sales (ICW_KEY)
-- cs_trans_cls_rbt_idr             CONSTANT hcrs.mstr_trans_t.trans_cls_cd%TYPE := cs_trans_cls_rbt || cs_trans_cls_idr; -- Rebates on Indirect Sales
-- cs_trans_cls_rbt_idr_icw_key     CONSTANT hcrs.mstr_trans_t.trans_cls_cd%TYPE := cs_trans_cls_rbt || cs_trans_cls_idr || cs_trans_cls_icw_key; -- Rebates on Indirect Sales
-- cs_trans_cls_rbt_rbt             CONSTANT hcrs.mstr_trans_t.trans_cls_cd%TYPE := cs_trans_cls_rbt || cs_trans_cls_rbt; -- Rebates on Rebate (UTIL, CUSTSLS, etc.)

 -- Transaction Source Tables
 cs_src_tbl_manual                CONSTANT hcrs.mstr_trans_t.src_tbl_cd%TYPE := 'GPCSMANUAL'; -- GPCS Manual Adjs
 cs_src_tbl_iis                   CONSTANT hcrs.mstr_trans_t.src_tbl_cd%TYPE := 'IIS'; -- ICW2 Interpreted Sales
 cs_src_tbl_iic                   CONSTANT hcrs.mstr_trans_t.src_tbl_cd%TYPE := 'IIC'; -- ICW2 Interpreted Credits
 cs_src_tbl_ipds                  CONSTANT hcrs.mstr_trans_t.src_tbl_cd%TYPE := 'IPDS'; -- ICW2 Prasco Direct Sales
 cs_src_tbl_ipdc                  CONSTANT hcrs.mstr_trans_t.src_tbl_cd%TYPE := 'IPDC'; -- ICW2 Prasco Direct Credits
 cs_src_tbl_ipch                  CONSTANT hcrs.mstr_trans_t.src_tbl_cd%TYPE := 'IPCH'; -- ICW2 Prasco Chargebacks (Indirect Sales)
 cs_src_tbl_ipdr                  CONSTANT hcrs.mstr_trans_t.src_tbl_cd%TYPE := 'IPDR'; -- ICW2 Prasco Direct Rebates
 cs_src_tbl_ipir                  CONSTANT hcrs.mstr_trans_t.src_tbl_cd%TYPE := 'IPIR'; -- ICW2 Prasco Indirect Rebates
 cs_src_tbl_igs                   CONSTANT hcrs.mstr_trans_t.src_tbl_cd%TYPE := 'IGS'; -- ICW2 Genzyme Direct Sales
 cs_src_tbl_igc                   CONSTANT hcrs.mstr_trans_t.src_tbl_cd%TYPE := 'IGC'; -- ICW2 Genzyme Chargebacks
 cs_src_tbl_igr                   CONSTANT hcrs.mstr_trans_t.src_tbl_cd%TYPE := 'IGR'; -- ICW2 Genzyme Rebates
 cs_src_tbl_igic                  CONSTANT hcrs.mstr_trans_t.src_tbl_cd%TYPE := 'IGIC'; -- ICW2 Genzyme Interpreted Credits

 -- Beginning of Time and End of Time
 -- Should always match setting in hcrs.ini
 cs_begin_time                    CONSTANT DATE := TO_DATE( '01/01/1900', 'MM/DD/YYYY');
 cs_end_time                      CONSTANT DATE := TO_DATE( '01/01/2100', 'MM/DD/YYYY');

 -- Check Request Status Codes
 cs_check_req_stat_re             CONSTANT hcrs.check_req_t.check_req_stat_cd%TYPE := 'RE'; -- Requested
 cs_check_req_stat_cf             CONSTANT hcrs.check_req_t.check_req_stat_cd%TYPE := 'CF'; -- Confirmed
 cs_check_req_stat_ma             CONSTANT hcrs.check_req_t.check_req_stat_cd%TYPE := 'MA'; -- Mailed/Check Paid

 -- None Condtion constants
 cs_cond_none_cd                  CONSTANT hcrs.bndl_cond_t.cond_cd%TYPE := 'NONE'; -- None condtion code
 cs_cond_none_seq_no              CONSTANT hcrs.bndl_cond_t.cond_seq_no%TYPE := 9999; -- None condtion sequence

 -- SAP Adjustment Settings
 cs_sap_adj_sg_elig_intgrty_y     CONSTANT hcrs.calc_mthd_prcss_typ_t.sap_adj_sg_elig_intgrty%TYPE := cs_flag_yes; -- Enforce integrity
 cs_sap_adj_sg_elig_intgrty_n     CONSTANT hcrs.calc_mthd_prcss_typ_t.sap_adj_sg_elig_intgrty%TYPE := cs_flag_no; -- Dont Enforce integrity
 cs_sap_adj_dt_mblty_hrd_lnk      CONSTANT hcrs.calc_mthd_prcss_typ_t.sap_adj_dt_mblty%TYPE := cs_flag_yes; -- Hard date linking
 cs_sap_adj_dt_mblty_sft_lnk      CONSTANT hcrs.calc_mthd_prcss_typ_t.sap_adj_dt_mblty%TYPE := 'S'; -- Soft date linking
 cs_sap_adj_dt_mblty_no_lnk       CONSTANT hcrs.calc_mthd_prcss_typ_t.sap_adj_dt_mblty%TYPE := cs_flag_no; -- no date linking

 -- Bundle Addl Text
 cs_addl_txt_fdo                  CONSTANT VARCHAR2( 10) := 'FDO'; -- Effective/Pricing Period Day Offset
 cs_addl_txt_vdo                  CONSTANT VARCHAR2( 10) := 'VDO'; -- Evaluation/Performance Period Day Offset
 cs_addl_txt_neglag               CONSTANT VARCHAR2( 10) := 'NEGLAG'; -- Treats Period Lag as negative
 cs_addl_txt_vsdo                 CONSTANT VARCHAR2( 10) := 'VSDO'; -- Evaluation/Performance Start Date Offset
 cs_addl_txt_vedo                 CONSTANT VARCHAR2( 10) := 'VEDO'; -- Evaluation/Performance End Date Offset

 -- System flags
 cs_skip_validate_matrix          CONSTANT hcrs.sys_param_t.param_val%TYPE := 'SKIP VALIDATE MATRIX'; -- Used to control validate matrix step in pkg_common_procedures.p_common_initialize

 -- Sales exclusion codes
 cs_sls_excl_cd_nom              CONSTANT hcrs.cd_t.cd%TYPE := 'NOM'; -- Nominal sales
 cs_sls_excl_cd_hhs              CONSTANT hcrs.cd_t.cd%TYPE := 'HHS'; -- Sub-PHS sales

 -- Sales exclusion compare codes
 cs_sls_excl_comp_cd_lss         CONSTANT VARCHAR2( 10) := 'LSS'; -- Less than
 cs_sls_excl_comp_cd_leq         CONSTANT VARCHAR2( 10) := 'LEQ'; -- Less than or equal
 cs_sls_excl_comp_cd_equ         CONSTANT VARCHAR2( 10) := 'EQU'; -- Equal
 cs_sls_excl_comp_cd_neq         CONSTANT VARCHAR2( 10) := 'NEQ'; -- Not Equal
 cs_sls_excl_comp_cd_gtr         CONSTANT VARCHAR2( 10) := 'GTR'; -- Greater than
 cs_sls_excl_comp_cd_geq         CONSTANT VARCHAR2( 10) := 'GEQ'; -- Greater than or equal

END pkg_constants;
/
