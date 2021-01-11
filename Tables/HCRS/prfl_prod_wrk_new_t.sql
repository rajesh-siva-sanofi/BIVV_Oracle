--------------------------------------------------------------------------------
-- Create new Profile Product Working table
--------------------------------------------------------------------------------
TIMING START hcrs.prfl_prod_wrk_new_t

--DROP TABLE hcrs.prfl_prod_wrk_new_t PURGE;
CREATE GLOBAL TEMPORARY TABLE hcrs.prfl_prod_wrk_new_t
   (prfl_id                     NUMBER NOT NULL,
    co_id                       NUMBER(9) NOT NULL,
    ndc_lbl                     VARCHAR2(5) NOT NULL,
    ndc_prod                    VARCHAR2(4) NOT NULL,
    ndc_pckg                    VARCHAR2(2) NOT NULL,
    calc_typ_cd                 VARCHAR2(20) NOT NULL,
    calc_mthd_cd                VARCHAR2(10) NOT NULL,
    agency_typ_cd               VARCHAR2(12) NOT NULL,
    calc_ndc_pckg_lvl           VARCHAR2(1) NOT NULL,
    rpt_ndc_pckg_lvl            VARCHAR2(1) NOT NULL,
    prcss_typ_cd                VARCHAR2(20) NOT NULL,
    tim_per_cd                  VARCHAR2(12) NOT NULL,
    start_dt                    DATE NOT NULL,
    end_dt                      DATE NOT NULL,
    ann_start_dt                DATE NOT NULL,
    ann_end_dt                  DATE NOT NULL,
    ann_off_start_dt            DATE NOT NULL,
    ann_off_end_dt              DATE NOT NULL,
    min_start_dt                DATE NOT NULL,
    max_end_dt                  DATE NOT NULL,
    min_paid_start_dt           DATE,
    max_paid_end_dt             DATE,
    min_earn_start_dt           DATE,
    max_earn_end_dt             DATE,
    min_bndl_start_dt           DATE,
    max_bndl_end_dt             DATE,
    snpsht_id                   NUMBER NOT NULL,
    snpsht_dt                   DATE NOT NULL,
    sales_offset_days           NUMBER NOT NULL,
    nom_thrs_pct                NUMBER NOT NULL,
    cash_dscnt_pct_raw          NUMBER NOT NULL,
    cash_dscnt_pct              NUMBER NOT NULL,
    prmpt_pay_adj_pct           NUMBER NOT NULL,
    max_dpa_pct_raw             NUMBER NOT NULL,
    max_dpa_pct                 NUMBER NOT NULL,
    dec_pcsn                    NUMBER NOT NULL,
    chk_nom                     VARCHAR2(1) NOT NULL,
    chk_hhs                     VARCHAR2(1) NOT NULL,
    chk_nom_calc                VARCHAR2(1) NOT NULL,
    chk_hhs_calc                VARCHAR2(1) NOT NULL,
    sap_adj_sg_elig_intgrty     VARCHAR2(1) NOT NULL,
    sap_adj_dt_mblty            VARCHAR2(1) NOT NULL,
    lkup_sap_adj                VARCHAR2(1) NOT NULL,
    lkup_rbt_fee                VARCHAR2(1) NOT NULL,
    lkup_rel_crd                VARCHAR2(1) NOT NULL,
    lkup_xenon_adj              VARCHAR2(1) NOT NULL,
    lkup_prasco_rbtfee          VARCHAR2(1) NOT NULL,
    roll_up                     VARCHAR2(1) NOT NULL,
    bndl_only                   VARCHAR2(1) NOT NULL,
    bndl_prod                   VARCHAR2(1) NOT NULL,
    roll_up_ord                 NUMBER NOT NULL,
    non_bndl_cnt                NUMBER NOT NULL,
    calc_min_ndc                VARCHAR2(1) NOT NULL,
    prfl_ndc_lbl                VARCHAR2(5) NOT NULL,
    prfl_ndc_prod               VARCHAR2(4) NOT NULL,
    prfl_ndc_pckg               VARCHAR2(2) NOT NULL,
    trans_ndc_lbl               VARCHAR2(5) NOT NULL,
    trans_ndc_prod              VARCHAR2(4) NOT NULL,
    trans_ndc_pckg              VARCHAR2(2) NOT NULL,
    pri_whls_mthd_cd            VARCHAR2(12) NOT NULL,
    nonrtl_threshold            VARCHAR2(1) NOT NULL,
    nonrtl_drug_ind             VARCHAR2(1) NOT NULL,
    unit_per_pckg               NUMBER NOT NULL,
    comm_unit_per_pckg          NUMBER NOT NULL,
    mrkt_entry_dt               DATE NOT NULL,
    first_dt_sld                DATE NOT NULL,
    term_dt                     DATE NOT NULL,
    liab_end_dt                 DATE NOT NULL,
    drug_catg_cd                VARCHAR2(1) NOT NULL,
    medicare_drug_catg_cd       VARCHAR2(1),
    uses_paid_dt                VARCHAR2(1) DEFAULT 'N' NOT NULL,
    uses_earn_dt                VARCHAR2(1) DEFAULT 'N' NOT NULL,
    prune_days                  NUMBER NOT NULL,
    flag_yes                    VARCHAR2(1) NOT NULL,
    flag_no                     VARCHAR2(1) NOT NULL,
    begin_time                  DATE NOT NULL,
    end_time                    DATE NOT NULL,
    rec_src_icw                 VARCHAR2(1) NOT NULL,
    co_icw                      NUMBER(9) NOT NULL,
    co_gnz                      NUMBER(9) NOT NULL,
    src_tbl_iis                 VARCHAR2(10) NOT NULL,
    src_tbl_iic                 VARCHAR2(10) NOT NULL,
    src_tbl_ipdr                VARCHAR2(10) NOT NULL,
    src_tbl_ipir                VARCHAR2(10) NOT NULL,
    source_trans_sales          VARCHAR2(1) NOT NULL,
    source_trans_credits        VARCHAR2(1) NOT NULL,
    system_sap                  VARCHAR2(10) NOT NULL,
    system_sap4h                VARCHAR2(10) NOT NULL,
    system_cars                 VARCHAR2(10) NOT NULL,
    system_x360                 VARCHAR2(10) NOT NULL,
    system_prasco               VARCHAR2(10) NOT NULL,
    system_bivvrxc              VARCHAR2(10) NOT NULL, -- New column
    trans_cls_dir               VARCHAR2(1) NOT NULL,
    trans_cls_idr               VARCHAR2(1) NOT NULL,
    trans_cls_rbt               VARCHAR2(1) NOT NULL,
    sap_adj_dt_mblty_hrd_lnk    VARCHAR2(1) NOT NULL,
    sap_adj_dt_mblty_sft_lnk    VARCHAR2(1) NOT NULL,
    sap_adj_dt_mblty_no_lnk     VARCHAR2(1) NOT NULL,
    trans_adj_original          VARCHAR2(15) NOT NULL,
    trans_adj_sap_adj           VARCHAR2(15) NOT NULL,
    trans_adj_sap_rollup        VARCHAR2(15) NOT NULL,
    trans_adj_cars_rbt_fee      VARCHAR2(15) NOT NULL,
    trans_adj_cars_adj          VARCHAR2(15) NOT NULL,
    trans_adj_cars_rollup       VARCHAR2(15) NOT NULL,
    trans_adj_icw_key           VARCHAR2(15) NOT NULL,
    trans_adj_x360_adj          VARCHAR2(15) NOT NULL,
    trans_adj_x360_rollup       VARCHAR2(15) NOT NULL,
    trans_adj_prasco_rbtfee     VARCHAR2(15) NOT NULL,
    trans_adj_prasco_rollup     VARCHAR2(15) NOT NULL,
    trans_adj_rollup            VARCHAR2(15) NOT NULL,
    trans_adj_bivv_adj          VARCHAR2(15) NOT NULL, -- New column
    trans_dt_range_ann_off      VARCHAR2(3) NOT NULL,
    whls_cot_grp_cd_noncbk      VARCHAR2(20) NOT NULL,
    whls_cot_incl_ind_noncbk    VARCHAR2(1) NOT NULL,
    whls_domestic_ind_noncbk    VARCHAR2(1) NOT NULL,
    whls_territory_ind_noncbk   VARCHAR2(1) NOT NULL,
    whls_loc_cd_noncbk          VARCHAR2(10) NOT NULL,
    cot_hhs_grantee             VARCHAR2(20) NOT NULL,
    tt_indirect_sales           VARCHAR2(20) NOT NULL,
    tt_rebates                  VARCHAR2(20) NOT NULL,
    tt_fee                      VARCHAR2(20) NOT NULL,
    tt_factr_rbt_fee            VARCHAR2(20) NOT NULL,
    tt_govt                     VARCHAR2(20) NOT NULL)
   ON COMMIT PRESERVE ROWS;

-- Table statistics
BEGIN
   dbms_stats.delete_table_stats( ownname => 'HCRS',
                                  tabname => 'PRFL_PROD_WRK_NEW_T');
   dbms_stats.gather_table_stats( ownname => 'HCRS',
                                  tabname => 'PRFL_PROD_WRK_NEW_T',
                                  estimate_percent => NULL, -- null means compute
                                  method_opt => 'FOR ALL COLUMNS SIZE 1',
                                  degree => NULL,
                                  granularity => 'ALL',
                                  cascade => TRUE);
END;
/

-- Comments
COMMENT ON TABLE hcrs.prfl_prod_wrk_new_t IS 'Profile Product Work table for calculations';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.prfl_id IS 'Profile ID of running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.co_id IS 'Company ID of NDCs included in the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.ndc_lbl IS 'NDC Labeler of running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.ndc_prod IS 'NDC Product Family of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.ndc_pckg IS 'NDC Package of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.calc_typ_cd IS 'Calculation code of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.calc_mthd_cd IS 'Calculation Method code of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.agency_typ_cd IS 'Agency of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.calc_ndc_pckg_lvl IS 'Calculated at the Package (NDC11) level';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.rpt_ndc_pckg_lvl IS 'Reported at the Package (NDC11) level';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.prcss_typ_cd IS 'Processing Type code of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.tim_per_cd IS 'Profile time period';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.start_dt IS 'Period Start Date of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.end_dt IS 'Period End Date of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.ann_start_dt IS 'Annual Start Date of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.ann_end_dt IS 'Annual End Date of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.ann_off_start_dt IS 'Annual Offset Start Date of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.ann_off_end_dt IS 'Annual Offset End Date of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.min_start_dt IS 'Minimum Start Date of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.max_end_dt IS 'Maximum End Date of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.min_paid_start_dt IS 'Minimum Paid Start Date of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.max_paid_end_dt IS 'Maximum Paid End Date of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.min_earn_start_dt IS 'Minimum Earn Start Date of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.max_earn_end_dt IS 'Maximum Earn End Date of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.min_bndl_start_dt IS 'Minimum Bundle Start Date for the product';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.max_bndl_end_dt IS 'Maximum Bundle End Date for the product';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.snpsht_id IS 'Snapshot ID of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.snpsht_dt IS 'Snapshot Date of the Snapshot ID of the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.sales_offset_days IS 'Sales Offeet Days';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.nom_thrs_pct IS 'Nominal Threshold percentage';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.cash_dscnt_pct_raw IS 'Cash Discount (prompt payment) percentage';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.cash_dscnt_pct IS 'Cash Discount (prompt payment) percentage from 100%';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.prmpt_pay_adj_pct IS 'Prompt Payment adjustment percentage';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.max_dpa_pct_raw IS 'Maximum DPA percentage';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.max_dpa_pct IS 'Maximum DPA percentage from 100%';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.dec_pcsn IS 'Calculation decimal precision';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.chk_nom IS 'Runtime Nominal Check setting (changes based on calc state)';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.chk_hhs IS 'Runtime HHS Violation Check setting (changes based on calc state)';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.chk_nom_calc IS 'Calculation Nominal Check setting (set at calc start, never changes)';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.chk_hhs_calc IS 'Calculation HHS Violation Check setting (set at calc start, never changes)';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.sap_adj_sg_elig_intgrty IS 'Controls Super Group and Eligibility Integrity for SAP/SAP4H Adjustments (Y/N)';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.sap_adj_dt_mblty IS 'Controls Date Mobility for SAP/SAP4H Adjustments (Y=Hard Link, S=Soft Link, N=No Link)';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.lkup_sap_adj IS 'When set to Y, perform SAP/SAP4H Adjustment lookups';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.lkup_rbt_fee IS 'When set to Y, perform Rebate/Fee lookups';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.lkup_rel_crd IS 'When set to Y, perform Related Credits lookups';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.lkup_xenon_adj IS 'When set to Y, perform XENON/X360 Adjustment lookups';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.lkup_prasco_rbtfee IS 'When set to Y, perform Prasco Rebate/Fee lookups';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.roll_up IS 'If set to Y, this NDC is a rollup NDC.';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.bndl_only IS 'If set to Y, this NDC is only used for bundling, not in the main calculation.';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.bndl_prod IS 'If set to Y, this NDC is used for bundling, it may or may not be used in the main calculation, see bndl_only column';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.roll_up_ord IS 'Orders rollup NDCs after main NDCs';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.non_bndl_cnt IS 'Count of non-bundle only NDCs';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.calc_min_ndc IS 'Lowest non-rollup NDC of the calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.prfl_ndc_lbl IS 'NDC Labeler 5 digit code for the base product';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.prfl_ndc_prod IS 'NDC Product Family 4 digit code for the base product';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.prfl_ndc_pckg IS 'NDC Package Size 2 digit code for the base product';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_ndc_lbl IS 'NDC Labeler of NDCs included in the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_ndc_prod IS 'NDC Product Family of NDCs included in the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_ndc_pckg IS 'NDC Package of NDCs included in the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.pri_whls_mthd_cd IS 'Matrix of NDCs included in the running calculation';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.nonrtl_threshold IS 'Non-Retail Threshold';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.nonrtl_drug_ind IS 'Identifies whether a product is a 5i Drug';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.unit_per_pckg IS 'Number of Medicaid Claim units per package.  Used to translate between Medicaid claim units and packages.';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.comm_unit_per_pckg IS 'number of commercially submitted units per package.  Used to translate between CARS commercial claim units and packages.';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.mrkt_entry_dt IS 'Market Entry Date of the NDC.  This can be backdated prior to NDC launch date for authorized generics.';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.first_dt_sld IS 'first Date sold of the NDC.  This generally represents the actual NDC launch date.';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.term_dt IS 'Product Termination Date.';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.liab_end_dt IS 'Product Liability End Date.';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.drug_catg_cd IS 'Product Drug Category Code.';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.medicare_drug_catg_cd IS 'Medicare Product Drug Category Code.';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.uses_paid_dt IS 'Components include transactions by paid date';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.uses_earn_dt IS 'Components include transactions by earned date';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.prune_days IS 'Partition pruning days of leeway for strange dates';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.flag_yes IS 'System Constant for Yes';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.flag_no IS 'System Constant for No';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.begin_time IS 'System Constant for the beginning of time';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.end_time IS 'System Constant for the end of time';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.rec_src_icw IS 'System Constant for Record Source for ICW';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.co_icw IS 'System Constant for Company ID for ICW';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.co_gnz IS 'System Constant for Company ID for Legacy Genzyme';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.src_tbl_iis IS 'System Constant for ICW Interpreted Sales';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.src_tbl_iic IS 'System Constant for ICW Interpreted Credits';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.src_tbl_ipdr IS 'System Constant for ICW2 Prasco Direct Rebates';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.src_tbl_ipir IS 'System Constant for ICW2 Prasco Indirect Rebates';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.source_trans_sales IS 'System Constant for Source Transaction type Sales';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.source_trans_credits IS 'System Constant for Source Transaction type Credits';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.system_sap IS 'System Constant for SAP source system';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.system_sap4h IS 'System Constant for SAP4H source system';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.system_cars IS 'System Constant for CARS / RMUS source system';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.system_x360 IS 'System Constant for X360 (Xenon) source system';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.system_prasco IS 'System Constant for Prasco source system';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.system_bivvrxc IS 'System Constant for Bioverativ RxCrossroads source system';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_cls_dir IS 'System Constant for Direct Sales Transaction Class Code';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_cls_idr IS 'System Constant for Indirect Sales Transaction Class Code';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_cls_rbt IS 'System Constant for Rebates Transaction Class Code';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.sap_adj_dt_mblty_hrd_lnk IS 'System Constant for SAP/SAP4H Adjustment Hard date linking';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.sap_adj_dt_mblty_sft_lnk IS 'System Constant for SAP/SAP4H Adjustment Soft date linking';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.sap_adj_dt_mblty_no_lnk IS 'System Constant for SAP/SAP4H Adjustment no date linking';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_original IS 'System Constant for Original trasaction';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_sap_adj IS 'System Constant for SAP/SAP4H adjustment';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_sap_rollup IS 'System Constant for SAP/SAP4H rollup';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_cars_rbt_fee IS 'System Constant for CARS Rebate/Fee applied to Chargeback';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_cars_adj IS 'System Constant for CARS Resubmitted Correction';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_cars_rollup IS 'System Constant for CARS rollup';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_icw_key IS 'System Constant for ICW Key transaction adjustment';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_x360_adj IS 'System Constant for X360 Adjustment';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_x360_rollup IS 'System Constant for X360 rollup';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_prasco_rbtfee IS 'System Constant for Prasco Rebate/Fee Link';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_prasco_rollup IS 'System Constant for Prasco rollup';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_rollup IS 'System Constant for rollup';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_adj_bivv_adj IS 'System Constant for Bioverativ adjustment';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.trans_dt_range_ann_off IS 'System Constant for Trans Date Range Annual Offset';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.whls_cot_grp_cd_noncbk IS 'System Constant for the Wholesaler COT Supergroup on Non-Chargebacks';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.whls_cot_incl_ind_noncbk IS 'System Constant for the Wholesaler COT Eligibility on Non-Chargebacks';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.whls_domestic_ind_noncbk IS 'System Constant for the Wholesaler Domestic Indicator on Non-Chargebacks';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.whls_territory_ind_noncbk IS 'System Constant for the Wholesaler Territory Indicator on Non-Chargebacks';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.whls_loc_cd_noncbk IS 'System Constant for the Wholesaler Customer Location Code on Non-Chargebacks';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.cot_hhs_grantee IS 'System Constant for the HHS Grantee class of trade supergroup';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.tt_indirect_sales IS 'System Constant for the Indirect Sales transaction type supergroup';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.tt_rebates IS 'System Constant for the Rebate transaction type supergroup';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.tt_fee IS 'System Constant for the Fee Rebate transaction type supergroup';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.tt_factr_rbt_fee IS 'System Constant for the Factored Rebate/Fee transaction type supergroup';
COMMENT ON COLUMN hcrs.prfl_prod_wrk_new_t.tt_govt IS 'System Constant for the Govt Program transaction type supergroup';

-- Indexes
CREATE INDEX hcrs.prfl_prod_wrk_new_ix1
   ON prfl_prod_wrk_new_t (prfl_id, co_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, trans_ndc_lbl, trans_ndc_prod, trans_ndc_pckg);

-- Key Contraints
ALTER TABLE hcrs.prfl_prod_wrk_new_t
  ADD CONSTRAINT pk_prfl_prod_wrk_new_t
  PRIMARY KEY (prfl_id, co_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, trans_ndc_lbl, trans_ndc_prod, trans_ndc_pckg);

-- Privileges
GRANT SELECT ON hcrs.prfl_prod_wrk_new_t TO hcrs_connect, hcrs_crm_select, hcrs_rpt, hcrs_select;
GRANT SELECT, INSERT, UPDATE, DELETE ON hcrs.prfl_prod_wrk_new_t TO hcrs_data_entry, hcrs_manager, hcrs_supervisor;

TIMING STOP hcrs.prfl_prod_wrk_new_t
