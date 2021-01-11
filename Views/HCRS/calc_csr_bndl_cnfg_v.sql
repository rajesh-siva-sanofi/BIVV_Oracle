CREATE OR REPLACE VIEW hcrs.calc_csr_bndl_cnfg_v
AS
   WITH /*+ calc_csr_bndl_cnfg_v */
        p0
   /****************************************************************************
   *    View Name : calc_csr_bndl_cnfg_v
   * Date Created : 01/15/2018
   *       Author : Joe Kidd
   *  Description : Bundling transaction configuration query
   *
   *                This only works when the calculation environment has been
   *                initialized with pkg_common_procedures.p_init_calc() and the
   *                customer ID has be populated with
   *                pkg_common_procedures.p_set_bndl_cust().
   *
   *                Find bundled transactions for a customer, across all bundled
   *                products, dates, bundled codes, transaction classes (where
   *                transaction type requires net or discount is for
   *                a component), and contracts and prices groups.  No units are
   *                involved, but transactions must have a gross dollar value
   *                and net dollar value.  Only SAP, SAP4H and RMUS/CARS
   *                transactions will be found, no manual adjustments.  Snapshot
   *                logic is applied.  The customer is assumed to have already
   *                passed any eligiblity and domestic/non-domestic restrictions
   *                and that a calculation component will require the unbundled
   *                net or discount dollar amount from their transactions.
   *                However, transaction types will only be included when they
   *                are part of a bundled component that will require the net or
   *                discount value.  All transactions will be included without
   *                regard to sales exclusion status.  The matrix (primary /
   *                wholesaler method code) for the main product will be used,
   *                as eligibility has already been determined with it.
   *
   *                The bundled contract price groups must meet the the
   *                following requirements (numbering continued from
   *                pkg_common_procedures.p_bndl_trans):
   *                4.4. The transaction's contract and price group must be
   *                     assigned to the bundle code.
   *                4.5. The transaction's Earned Date must fall within the
   *                     effective range of the contract price group bundle.
   *                4.6. The transaction's Earned Date must fall within the
   *                     bundle condition effective period.
   *                4.7. The transaction's Earned Date must fall within the
   *                     pricing period of the contract price group bundle.
   *                4.8. The transaction's customer must be in effect on
   *                     the condition based on the transaction's earned date.
   *                4.9. The customer condtion must be effective during the
   *                     bundle condition effective period.
   *
   *                The transactions included in bundling must meet the the
   *                following basic requirements:
   *                5.1. The transaction's customer must be the same as
   *                     the source transactions.  Exception: RMUS/CARS
   *                     rebates/fees with the ICW_KEY link, may have a
   *                     different customer ID from the linked sale, however
   *                     this is handled when adjustments are applied.
   *                5.2. The transaction's NDC must be in effect on the bundle
   *                     code based on the transaction's earned date.
   *                5.3. The transaction must be an SAP, SAP4H, or RMUS/CARS
   *                     transaction.
   *                5.4. The transaction's Sales Cutoff Date must less than or
   *                     equal to the Sales Cutoff Date of the Profile.
   *                5.5. The transaction must not be archived.
   *                5.6. The transaction must not be a manual adjustment.
   *                5.7. The discount or net value of the transaction must
   *                     be needed for a calculation component.
   *
   *                The transactions with which the source transactions are
   *                bundled for the pricing period must meet the the following
   *                additional requirements:
   *                6.1. The transaction's contract and price group must be
   *                     assigned to the bundle code.
   *                6.2. The transaction's earned date must be within the
   *                     pricing period of the bundle code that applies to
   *                     the source transaction.
   *
   *                The transactions with which the source transactions are
   *                bundled for the performance period must meet the the
   *                following additional requirements:
   *                7.1. The transaction's contract and price group may be
   *                     any contract and price group, including those with
   *                     no contract or price group.
   *                7.2. The transaction's earned date must be within the
   *                     performance period for the bundle code that applies
   *                     to the source transaction.
   *
   *                The resulting bundled relationship must then meet these
   *                requirements to be used by the main calculation:
   *                8.1. The pricing period gross dollars must not be
   *                     equal to zero.
   *                8.2. There must be transactions using an NDC of the main
   *                     calculation in the pricing or performance period.
   *                     Those transactions must occur during the range of
   *                     dates used by the main calculation by the
   *                     paid date and/or earned date as used by the main
   *                     calculation.
   *
   *                Required transaction linking:
   *
   *                SAP and SAP4H direct sales that are adjustments must use
   *                the invoice date from the root original invoice as the earn
   *                date and the wac price from the root original invoice to
   *                determine the gross value of the packages. (SAP_ADJ)
   *
   *                RMUS/CARS Rebates with ICW_KEY link to an SAP and SAP4H
   *                direct invoice must use the invoice date as the earn date,
   *                and the package quantity multiplied by the wac price as the
   *                gross dollar value.  If the linked SAP and SAP4H direct
   *                invoice is an adjustment invoice, the invoice date and the
   *                wac price from the root original invoice are substituted.
   *
   *                RMUS/CARS Rebates with ICW_KEY link to RMUS/CARS charegebacks
   *                must use the chargeback wholesaler invoice date as the earn
   *                date, and the contract amount plus the wholesaler chargeback
   *                amount as the gross dollar amount.
   *
   *                RMUS/CARS Rebates with submission link to RMUS/CARS
   *                charegebacks must use the charegeback wholesaler invoice date
   *                as the earn date, and the contract amount plus the wholesaler
   *                chargeback amount as the gross dollar amount. (CARS_RBT_FEE)
   *
   *                RMUS/CARS Utilixation and Customer Submitted SalesRebates
   *                (no link to direct sale or chargeback) use the Claim Period
   *                Start Date as the earn date and the Gross Sale Amount as
   *                gross dollar amount.
   *
   *                Summary:
   *
   *                Trans                     Earn Date         Gross Value
   *                ------------------------  ----------------  -------------------------------------
   *                Direct Orig Invc          Invc Date         (Pkg Qty) * (WAC Price)
   *                Direct Adj Invc           Orig Invc Date    (Adj Pkg Qty) * (Orig WAC Price)
   *                Rbt ICW Key to Dir Orig   Invc Date         (Pkg Qty) * (WAC Price)
   *                Rbt ICW Key to Dir Adj    Orig Invc Date    (Adj Pkg Qty) * (Orig WAC Price)
   *                Rbt ICW Key to Chrgbk     Whls Invc Date    (Ext Contract Amt) + (Ext Chrgbk Amt)
   *                Rbt Submitm to Chrgbk     Whls Invc Date    (Ext Contract Amt) + (Ext Chrgbk Amt)
   *                Rbt Submitm UTIL/CUSTSLS  Claim Begin Date  (Gross Sale Amount)
   *
   *                The ICW_KEY linkage is done as an (outer-) join because there
   *                is only one possible parent transaction and the index used
   *                does not contain all columns required to meet the join
   *                conditions and return the parent trans_id.  So because the
   *                table must be accessed to complete the join, it gets all
   *                the other columns required.
   *
   *                The SAP_ADJ and CARS_RBT_FEE linkages are done as scalar
   *                subqueries because there may be more than one parent/root
   *                transaction, and the index used contains all columns required
   *                to meet the join conditions and return the parent/root trans_id.
   *
   *----------------------------------------------------------------------------
   * Query Map
   *----------------------------------------------------------------------------
   *
   *  P0 --> P1 --> P2 --> P3 --> P4 --> P5 --> P6 --> P7 --> P8 --> P9 --> PA --> PB
   *                                                   |                           |
   *                                                   v                           v
   *  +<-----------------------------------------------+<--------------------------+
   *  |
   *  v
   *  PC --> PD --> PE --> PF --> PG --> PH ------> PI
   *                                     |          |
   *                                     v          v
   *                                   SELECT (UNION ALL)
   *
   * This view is not separated into nested views (similar to calc_csr_main_*_v)
   * because the branching between P6 and PA will cause Oracle to execute the
   * P0 - P6 queries *twice*, once for each branch, and join the results in PB.
   *
   * Subquery descriptions:
   *
   * P0 - Trans: Get the customer and the bundle sequence number
   * P1 - Trans: Add the customer class of trade and the bundle products
   * P2 - Trans: Get transactions, filter for bundled components with the matrix
   * P3 - Trans: Get count of transactions on bundled price groups
   * P4 - Trans: Get ICW_KEY related SAP/SAP4H sales and RMUS/CARS chargebacks
   * P5 - Trans: Get parent RMUS/CARS chargeback for rebates and root SAP/SAP4H sales
   * P6 - Trans: Get values from parent RMUS/CARS chargeback and root SAP/SAP4H sales
   * P7 - Trans: Calculate the gross and discount dollars, filter by true earn date
   * P8 - Bundles: Get all price group bundle dates actually in use by transactions
   * P9 - Bundles: Get the bundle dates in use, filter out inactive conditions
   * PA - Bundles: Find condition overrides
   * PB - Bundles: Add the bundle sequence number, remove unneeded conditions
   * PC - Trans: Get transactions for each linked bundle date range
   * PD - Trans: Check for main calc NDCs
   * PE - Trans: Limit to relationships with main calc NDCs, get trans links
   * PF - Trans: Remove duplicate/unneeded gross dollar amounts
   * PG - Trans: Remove pricing periods with no gross dollars
   * PH - Transaction Detail: Transform to table fields with gross/discount dollars
   *      split into pricing and performance fields
   * PI - Transaction Summary: Get sum of transaction detail
   * SELECT - Output the Summary and Detail for use by multi-table INSERT
   *
   *----------------------------------------------------------------------------
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
   *                            Reorganize for performance: relocate pipeline
   *                            table function, remove second set of detail rows,
   *                            multi-table insert will handle inserting into
   *                            both detail tables
   *  03/01/2019  Joe Kidd      CHG-123872: SHIFT SAP
   *                            Add Assoc invoice source system code column
   *                            Add SAP4H source system code column
   *                            Add SAP4H to SAP transaction filter
   *                            Add SAP4H to SAP adjustment lookups
   *  08/01/2020  Joe Kidd      CHG-198490: Bioverativ Integration
   *                            Short circuit if no trans are on bundled price groups
   ****************************************************************************/
     AS (-- P0 - Trans: Get the customer and the bundle sequence number
         SELECT /*+ QB_NAME( p0 )
                    NO_MERGE
                    LEADING( ppbsw c )
                    DYNAMIC_SAMPLING( 0 )
                */
                c.prfl_id,
                c.co_id,
                c.ndc_lbl,
                c.ndc_prod,
                c.ndc_pckg,
                c.calc_typ_cd,
                c.cust_id,
                c.cond_cd,
                c.cond_strt_dt,
                c.cond_end_dt,
                ppbsw.bndl_seq_no,
                c.calc_running,
                c.flag_yes
           FROM ( -- Get that last bundle sequence number
                  SELECT /*+ QB_NAME( p0_0 )
                             NO_MERGE
                             INDEX( ppbsw prfl_prod_bndl_smry_wrk_ix1 )
                             DYNAMIC_SAMPLING( 0 )
                         */
                         COALESCE( MAX( ppbsw.bndl_seq_no), 0) bndl_seq_no
                    FROM hcrs.prfl_prod_bndl_smry_wrk_t ppbsw
                ) ppbsw,
                TABLE( hcrs.pkg_common_procedures.f_get_bndl_cust()) c
        ),
        p1
     AS (-- P1 - Trans: Add the customer class of trade and the bundle products
         SELECT /*+ QB_NAME( p1 )
                    NO_MERGE
                    LEADING( z pccotw pbpw )
                    USE_NL( z pccotw pbpw )
                    INDEX( pccotw prfl_cust_cls_of_trd_wrk_ix2 )
                    FULL( pbpw )
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                pccotw.strt_dt cust_strt_dt,
                pccotw.end_dt cust_end_dt,
                pccotw.cls_of_trd_cd,
                pbpw.bndl_cd,
                pbpw.bndl_strt_dt,
                pbpw.bndl_end_dt,
                z.cond_cd,
                z.cond_strt_dt,
                z.cond_end_dt,
                z.bndl_seq_no,
                pbpw.min_paid_start_dt,
                pbpw.max_paid_end_dt,
                pbpw.min_earn_start_dt,
                pbpw.max_earn_end_dt,
                pbpw.bndl_ndc_lbl,
                pbpw.bndl_ndc_prod,
                pbpw.bndl_ndc_pckg,
                pbpw.snpsht_id,
                pbpw.prune_days,
                z.calc_running,
                z.flag_yes,
                pbpw.flag_no,
                pbpw.rec_src_icw,
                pbpw.src_tbl_iis,
                pbpw.trans_cls_dir,
                pbpw.trans_cls_idr,
                pbpw.trans_cls_rbt,
                pbpw.trans_adj_original,
                pbpw.trans_adj_cars_rollup,
                pbpw.system_sap,
                pbpw.system_sap4h,
                pbpw.system_cars
           FROM p0 z,
                hcrs.prfl_cust_cls_of_trd_wrk_t pccotw,
                hcrs.prfl_bndl_prod_wrk_t pbpw
          WHERE z.cust_id = pccotw.cust_id
             -- Condition must be in effect during bundle period
            AND z.cond_strt_dt <= pbpw.bndl_end_dt
            AND z.cond_end_dt >= pbpw.bndl_strt_dt
             -- Condition must be in effect during class of trade period
            AND z.cond_strt_dt <= pccotw.end_dt
            AND z.cond_end_dt >= pccotw.strt_dt
             -- Class of Trade must be in effect during bundle period
            AND pccotw.strt_dt <= pbpw.bndl_end_dt
            AND pccotw.end_dt >= pbpw.bndl_strt_dt
        ),
        p2
     AS (-- P2 - Trans: Get transactions, filter for bundled components with the matrix
         SELECT /*+ QB_NAME( p2 )
                    NO_MERGE
                    LEADING( z mt pmw )
                    USE_NL( z mt pmw )
                    INDEX( mt mstr_trans_ix504 )
                    INDEX( pmw prfl_mtrx_wrk_ix3 )
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.cust_strt_dt,
                z.cust_end_dt,
                pmw.cot_begn_dt,
                pmw.cot_end_dt,
                mt.trans_cls_cd,
                z.bndl_cd,
                z.bndl_strt_dt,
                z.bndl_end_dt,
                z.cond_cd,
                z.cond_strt_dt,
                z.cond_end_dt,
                z.bndl_seq_no,
                z.min_paid_start_dt,
                z.max_paid_end_dt,
                z.min_earn_start_dt,
                z.max_earn_end_dt,
                mt.paid_dt,
                mt.earn_bgn_dt,
                mt.earn_end_dt,
                mt.assc_invc_dt,
                z.bndl_ndc_lbl,
                z.bndl_ndc_prod,
                z.bndl_ndc_pckg,
                mt.rec_src_ind,
                mt.archive_ind,
                z.snpsht_id,
                mt.source_sys_cde,
                pmw.tt_begn_dt,
                pmw.tt_end_dt,
                mt.lgcy_trans_no,
                mt.assc_invc_no,
                mt.lgcy_trans_line_no,
                mt.related_sales_id,
                mt.contr_id,
                mt.price_grp_id price_grp_no,
                mt.trans_id,
                mt.wac_price,
                mt.pkg_qty,
                mt.total_amt,
                mt.whls_chrgbck_amt,
                mt.gross_sale_amt,
                CASE
                   WHEN mt.contr_id IS NOT NULL
                    AND mt.price_grp_id IS NOT NULL
                    AND EXISTS
                        (-- Check if transaction on bundle contract price group
                           SELECT /*+ QB_NAME( p2a )
                                      NO_MERGE
                                      INDEX( ppbdw prfl_prod_bndl_dts_wrk_ix1 )
                                      DYNAMIC_SAMPLING( 0 )
                                  */
                                  NULL
                             FROM hcrs.prfl_prod_bndl_dts_wrk_t ppbdw
                               --------------------------------------------------------------------
                               -- Z-PPBDW: All Transactions to Profile Product Bundle Dates
                               -- 4.4. The transaction's contract and price group must be
                               --      assigned to the bundle code.
                               -- 4.5. The transaction's Earned Date must fall within the
                               --      effective range of the contract price group bundle.
                               -- 4.6. The transaction's Earned Date must fall within the
                               --      bundle condition effective period.
                               -- 4.7. The transaction's Earned Date must fall within the
                               --      pricing period of the contract price group bundle.
                            WHERE ppbdw.bndl_cd = z.bndl_cd
                              AND ppbdw.contr_id = mt.contr_id
                              AND ppbdw.price_grp_no = mt.price_grp_id
                              AND ppbdw.cond_cd = z.cond_cd
                        )
                   THEN 1
                   ELSE 0
                END bndl_price_grp,
                z.prune_days,
                z.calc_running,
                z.flag_yes,
                z.src_tbl_iis,
                z.trans_cls_dir,
                z.trans_cls_idr,
                z.trans_cls_rbt,
                z.trans_adj_original,
                z.trans_adj_cars_rollup,
                z.system_sap,
                z.system_sap4h,
                z.system_cars
           FROM p1 z,
                hcrs.mstr_trans_t mt,
                hcrs.prfl_mtrx_wrk_t pmw
             --------------------------------------------------------------------
             -- Z-MT: Only the passed customer
          WHERE z.cust_id = mt.cust_id
             --------------------------------------------------------------------
             -- Z-MT: Profile Bundle Products work to Transactions
            AND z.bndl_ndc_lbl = mt.ndc_lbl
            AND z.bndl_ndc_prod = mt.ndc_prod
            AND z.bndl_ndc_pckg = mt.ndc_pckg
             -- Bundle Start Date is earliest earn date, trans must be paid on or
             -- after it is earned, so this will include trans earned too early
             -- but it can still eliminate a significant number of transactions
             -- and it will use partition pruning
            AND (z.bndl_strt_dt - z.prune_days) <= mt.paid_dt
             -- Bundle End Date is latest earn date, SAP/SAP4H adjustments are
             -- really earned before their earn date
            AND (z.bndl_end_dt + z.prune_days) >= mt.earn_bgn_dt
             --------------------------------------------------------------------
             -- Z-MT: Limit transactions to non-archived non-manual transactions
             -- up to the selected snapshot
            AND z.snpsht_id >= mt.snpsht_id
            AND z.co_id = mt.co_id
            AND z.flag_no = mt.archive_ind
             --------------------------------------------------------------------
             -- Z-MT: Only ICW SAP/SAP4H and RMUS/CARS transactions
            AND z.rec_src_icw = mt.rec_src_ind
            AND mt.source_sys_cde IN (z.system_cars,
                                      z.system_sap,
                                      z.system_sap4h)
             --------------------------------------------------------------------
             -- Z-PMW: Link customer to COT/TT Matrix
             -- Effective dates will be handled later after true
             -- transaction earned date is determined
            AND z.cls_of_trd_cd = pmw.cls_of_trd_cd
             -- Only matrix rows that use net/discount as needed
            AND z.flag_yes = pmw.uses_net_dsc
             --------------------------------------------------------------------
             -- MT-PMW: Link transactions to COT/TT Matrix
            AND mt.trans_typ_cd = pmw.trans_typ_cd
        ),
        p3
     AS (-- P3 - Trans: Get count of transactions on bundled price groups
         SELECT /*+ QB_NAME( p3 )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.cust_strt_dt,
                z.cust_end_dt,
                z.cot_begn_dt,
                z.cot_end_dt,
                z.trans_cls_cd,
                z.bndl_cd,
                z.bndl_strt_dt,
                z.bndl_end_dt,
                z.cond_cd,
                z.cond_strt_dt,
                z.cond_end_dt,
                z.bndl_seq_no,
                z.min_paid_start_dt,
                z.max_paid_end_dt,
                z.min_earn_start_dt,
                z.max_earn_end_dt,
                z.paid_dt,
                z.earn_bgn_dt,
                z.earn_end_dt,
                z.assc_invc_dt,
                z.bndl_ndc_lbl,
                z.bndl_ndc_prod,
                z.bndl_ndc_pckg,
                z.rec_src_ind,
                z.archive_ind,
                z.snpsht_id,
                z.source_sys_cde,
                z.tt_begn_dt,
                z.tt_end_dt,
                z.lgcy_trans_no,
                z.assc_invc_no,
                z.lgcy_trans_line_no,
                z.related_sales_id,
                z.contr_id,
                z.price_grp_no,
                z.trans_id,
                z.wac_price,
                z.pkg_qty,
                z.total_amt,
                z.whls_chrgbck_amt,
                z.gross_sale_amt,
                MAX( z.bndl_price_grp) OVER () bndl_price_grp,
                z.prune_days,
                z.calc_running,
                z.flag_yes,
                z.src_tbl_iis,
                z.trans_cls_dir,
                z.trans_cls_idr,
                z.trans_cls_rbt,
                z.trans_adj_original,
                z.trans_adj_cars_rollup,
                z.system_sap,
                z.system_sap4h,
                z.system_cars
           FROM p2 z
        ),
        p4
     AS (-- P4 - Trans: Get ICW_KEY related SAP/SAP4H sales and RMUS/CARS chargebacks
         SELECT /*+ QB_NAME( p4 )
                    NO_MERGE
                    LEADING( z rt )
                    USE_NL( z rt )
                    INDEX( rt mstr_trans_ix01 )
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.cust_strt_dt,
                z.cust_end_dt,
                z.cot_begn_dt,
                z.cot_end_dt,
                z.trans_cls_cd,
                -- Get the parent trans class (for rebate on DIR/IDR)
                COALESCE( rt.trans_cls_cd, z.trans_cls_cd) rt_trans_cls_cd,
                z.bndl_cd,
                z.bndl_strt_dt,
                z.bndl_end_dt,
                z.cond_cd,
                z.cond_strt_dt,
                z.cond_end_dt,
                z.bndl_seq_no,
                z.min_paid_start_dt,
                z.max_paid_end_dt,
                z.min_earn_start_dt,
                z.max_earn_end_dt,
                z.paid_dt,
                -- Align Earned Dates: All transactions use the assc_invc_dt/earn_bgn_dt of root, then parent, then current
                COALESCE( rt.earn_bgn_dt, z.earn_bgn_dt) earn_bgn_dt,
                COALESCE( rt.earn_end_dt, z.earn_end_dt) earn_end_dt,
                COALESCE( rt.assc_invc_dt, z.assc_invc_dt) assc_invc_dt,
                z.bndl_ndc_lbl,
                z.bndl_ndc_prod,
                z.bndl_ndc_pckg,
                z.rec_src_ind,
                z.archive_ind,
                z.snpsht_id,
                COALESCE( rt.source_sys_cde, z.source_sys_cde) source_sys_cde,
                z.tt_begn_dt,
                z.tt_end_dt,
                -- Align ICW_KEY legacy trans number/orig invoice number with related sale/credit
                COALESCE( rt.lgcy_trans_no, z.lgcy_trans_no) lgcy_trans_no,
                COALESCE( rt.assc_invc_no, z.assc_invc_no) assc_invc_no,
                CASE
                   -- For rebates on SAP/SAP4H directs, replace with invoice line number for proper uniqueness
                   WHEN rt.trans_cls_cd = z.trans_cls_dir
                    AND rt.source_sys_cde IN (z.system_sap,
                                              z.system_sap4h)
                   THEN rt.lgcy_trans_line_no
                   ELSE z.lgcy_trans_line_no
                END lgcy_trans_line_no,
                z.contr_id,
                z.price_grp_no,
                z.trans_id,
                COALESCE( rt.trans_id, z.trans_id) rt_trans_id,
                -- Align WAC Price: All transactions use the wac_price of root, then parent, then current
                COALESCE( rt.wac_price, z.wac_price) wac_price,
                -- Get related dir sale package quantity
                COALESCE( rt.pkg_qty, z.pkg_qty) pkg_qty,
                z.total_amt,
                -- Get related idr/dir sale contracted amount
                COALESCE( rt.total_amt, z.total_amt) rt_total_amt,
                -- Parent chgbk amt will be NULL when this chgbk amt is not null
                COALESCE( rt.whls_chrgbck_amt, z.whls_chrgbck_amt) whls_chrgbck_amt,
                z.gross_sale_amt,
                z.prune_days,
                z.calc_running,
                z.flag_yes,
                z.trans_cls_dir,
                z.trans_cls_idr,
                z.trans_cls_rbt,
                z.trans_adj_original,
                z.trans_adj_cars_rollup,
                z.system_sap,
                z.system_sap4h,
                z.system_cars
           FROM p3 z,
                hcrs.mstr_trans_t rt
            --------------------------------------------------------------------
            -- Z-RT: Limit transactions to non-archived non-manual transactions
            -- up to the selected snapshot
            -- 5.4. The transaction's Sales Cutoff Date must less than or
            --      equal to the Sales Cutoff Date of the Profile.
            -- 5.5. The transaction must not be archived.
            -- 5.6. The transaction must not be a manual adjustment.
            -- (Same data source, not archived, no manual adjustments, limit snapshot)
          WHERE z.rec_src_ind = rt.rec_src_ind (+)
            AND z.co_id = rt.co_id (+)
            AND z.archive_ind = rt.archive_ind (+)
            AND z.snpsht_id >= rt.snpsht_id (+)
            --------------------------------------------------------------------
            -- Z-RT: Only the passed customer
            -- Customer does not need to match at all!!
            --AND z.cust_id = rt.cust_id (+)
            --------------------------------------------------------------------
            -- Z-RT: Profile Bundle Products work to Transactions
            -- 5.2. The transaction's NDC must be in effect on the bundle
            --      code based on the transaction's earned date.
            AND z.bndl_ndc_lbl = rt.ndc_lbl (+)
            AND z.bndl_ndc_prod = rt.ndc_prod (+)
            AND z.bndl_ndc_pckg = rt.ndc_pckg (+)
            -- Contract ID does not need to match to obtain Gross Dollars/Units/Packages
            --AND z.contr_id = COALESCE( rt.contr_id (+), z.contr_id)
             -- Link to related sales/credit transaction
            AND z.src_tbl_iis = rt.src_tbl_cd (+)
            AND z.related_sales_id = rt.unique_id (+)
             -----------------------------------------------------
             -- Partition pruning - THESE MAKE A HUGE DIFFERENCE!!
             -----------------------------------------------------
             -- Related sale/credit will be paid on or before linked credit was paid
            AND (z.paid_dt + z.prune_days) >= rt.paid_dt (+)
             -- Related sale/credit will be paid on or after linked credit was earned
            AND (z.earn_bgn_dt - z.prune_days) <= rt.paid_dt (+)
             -- Only continue if there are transactions on bundled price groups
            AND z.bndl_price_grp > 0
        ),
        p5
     AS (-- P5 - Trans: Get parent RMUS/CARS chargeback for rebates and root SAP/SAP4H sales
         SELECT /*+ QB_NAME( p5 )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.cust_strt_dt,
                z.cust_end_dt,
                z.cot_begn_dt,
                z.cot_end_dt,
                z.trans_cls_cd,
                z.rt_trans_cls_cd,
                z.bndl_cd,
                z.bndl_strt_dt,
                z.bndl_end_dt,
                z.cond_cd,
                z.cond_strt_dt,
                z.cond_end_dt,
                z.bndl_seq_no,
                z.min_paid_start_dt,
                z.max_paid_end_dt,
                z.min_earn_start_dt,
                z.max_earn_end_dt,
                z.paid_dt,
                z.earn_bgn_dt,
                z.assc_invc_dt,
                z.bndl_ndc_lbl,
                z.bndl_ndc_prod,
                z.bndl_ndc_pckg,
                z.source_sys_cde,
                z.tt_begn_dt,
                z.tt_end_dt,
                z.lgcy_trans_no,
                z.assc_invc_no,
                z.lgcy_trans_line_no,
                z.contr_id,
                z.price_grp_no,
                z.trans_id,
                -- SAP_ADJ: Link SAP/SAP4H adjustment to root SAP/SAP4H invoice
                -- Get root original invoice for earn date and WAC values
                CASE
                   WHEN z.rt_trans_cls_cd = z.trans_cls_dir
                    AND z.source_sys_cde IN (z.system_sap,
                                             z.system_sap4h)
                    AND z.assc_invc_no IS NOT NULL
                   THEN (  -- START WITH clause uses index pk_mstr_trans_t
                           -- CONNECT BY clauses uses index mstr_trans_ix503
                           -- use MIN as there may be more than one line
                           SELECT /*+ QB_NAME( p5_sap )
                                      NO_MERGE
                                      INDEX( rt pk_mstr_trans_t )
                                      INDEX( rt mstr_trans_ix503 )
                                      DYNAMIC_SAMPLING( 0 )
                                  */
                                  MIN( rt.trans_id)
                             FROM hcrs.mstr_trans_t rt
                               -- get root row(s)
                            WHERE CONNECT_BY_ISLEAF = 1
                               -- limit snapshot
                              AND rt.snpsht_id <= z.snpsht_id
                               -- Only originals
                              AND rt.assc_invc_no IS NULL
                            START WITH rt.trans_id = z.rt_trans_id
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
                                    -- Sale or credit may not match, do not check
                                    --AND rt.source_trans_typ = PRIOR rt.source_trans_typ
                                    -- Link to original invoice
                                   AND rt.lgcy_trans_no = PRIOR rt.assc_invc_no
                                   AND rt.source_sys_cde = PRIOR rt.assc_invc_source_sys_cde
                                    -- Partition Pruning - Direct partition access
                                   AND rt.paid_dt = PRIOR rt.assc_invc_dt
                        )
                END sap_trans_id,
                -- CARS_RBT_FEE: Link RMUS/CARS rebate/fee to parent RMUS/CARS chargeback
                -- Get parent chargeback for earn date and gross dollars/units
                -- It also determines if rebate is based on chargeback or utilization
                -- Does not apply to ICW_KEY rebates, they are already directly linked
                CASE
                   WHEN z.rt_trans_cls_cd = z.trans_cls_rbt
                    AND z.source_sys_cde = z.system_cars
                    AND z.lgcy_trans_no IS NOT NULL
                    AND z.rt_trans_id = z.trans_id
                   THEN (  -- Use MIN as there may be more than one line
                           SELECT /*+ QB_NAME( p5_cars )
                                      NO_MERGE
                                      INDEX( rt mstr_trans_ix503 )
                                      DYNAMIC_SAMPLING( 0 )
                                  */
                                  MIN( rt.trans_id)
                             FROM hcrs.mstr_trans_t rt
                               -- Same data source, not archived, no manual adjustments, limit snapshot
                            WHERE rt.rec_src_ind = z.rec_src_ind
                              AND rt.co_id = z.co_id
                              AND rt.archive_ind = z.archive_ind
                              AND rt.snpsht_id <= z.snpsht_id
                               -- Customer ID must match to link to parent transaction, however
                               -- Customer ID does not need to match to obtain Gross Dollars/Units/Packages
                               --AND rt.cust_id = z.cust_id
                               -- Must be same NDC
                              AND rt.ndc_lbl = z.bndl_ndc_lbl
                              AND rt.ndc_prod = z.bndl_ndc_prod
                              AND rt.ndc_pckg = z.bndl_ndc_pckg
                               -- Contract ID must match to link to parent transaction, however
                               -- Contract ID does not need to match to obtain Gross Dollars/Units/Packages
                               -- (RMUS/CARS always has a contract)
                              --AND rt.contr_id = z.contr_id
                               -- Must be an RMUS/CARS chargeback
                              AND rt.source_sys_cde = z.source_sys_cde
                              AND rt.trans_cls_cd = z.trans_cls_idr
                               -- Link to original transaction
                              AND rt.lgcy_trans_no = z.lgcy_trans_no
                              AND rt.earn_bgn_dt BETWEEN z.earn_bgn_dt AND z.earn_end_dt
                               -----------------------------------------------------
                               -- Partition pruning - THESE MAKE A HUGE DIFFERENCE!!
                               -----------------------------------------------------
                               -- Parent chargeback will be paid on or before this rebate
                               -- Can't do this - apparently admin fees can be settled long before their chargebacks
                              --AND rt.paid_dt <= (z.paid_dt + z.prune_days)
                               -- Parent chargeback will be paid on or after when this rebate was earned
                              AND rt.paid_dt >= (z.earn_bgn_dt - z.prune_days)
                        )
                END cars_trans_id,
                z.wac_price,
                z.pkg_qty,
                z.total_amt,
                z.rt_total_amt,
                z.whls_chrgbck_amt,
                z.gross_sale_amt,
                z.calc_running,
                z.flag_yes,
                z.trans_cls_dir,
                z.trans_cls_idr,
                z.trans_cls_rbt,
                z.trans_adj_original,
                z.trans_adj_cars_rollup,
                z.system_sap,
                z.system_sap4h,
                z.system_cars
           FROM p4 z
        ),
        p6
     AS (-- P6 - Trans: Get values from parent RMUS/CARS chargeback and root SAP/SAP4H sales
         SELECT /*+ QB_NAME( p6 )
                    NO_MERGE
                    LEADING( z rt )
                    USE_NL( z rt )
                    INDEX( rt pk_mstr_trans_t )
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.cust_strt_dt,
                z.cust_end_dt,
                z.cot_begn_dt,
                z.cot_end_dt,
                z.trans_cls_cd,
                -- Get the parent trans class (for rebate on DIR/IDR)
                COALESCE( rt.trans_cls_cd, z.rt_trans_cls_cd) rt_trans_cls_cd,
                z.bndl_cd,
                z.bndl_strt_dt,
                z.bndl_end_dt,
                z.cond_cd,
                z.cond_strt_dt,
                z.cond_end_dt,
                z.bndl_seq_no,
                z.min_paid_start_dt,
                z.max_paid_end_dt,
                z.min_earn_start_dt,
                z.max_earn_end_dt,
                z.paid_dt,
                -- Align Earned Dates: All transactions use the assc_invc_dt/earn_bgn_dt of root, then parent, then current
                COALESCE( rt.assc_invc_dt, rt.earn_bgn_dt, z.assc_invc_dt, z.earn_bgn_dt) earn_dt,
                z.bndl_ndc_lbl,
                z.bndl_ndc_prod,
                z.bndl_ndc_pckg,
                COALESCE( rt.source_sys_cde, z.source_sys_cde) source_sys_cde,
                z.tt_begn_dt,
                z.tt_end_dt,
                z.lgcy_trans_no,
                z.assc_invc_no,
                z.lgcy_trans_line_no,
                z.contr_id,
                z.price_grp_no,
                z.trans_id,
                -- Align WAC Price: All transactions use the wac_price of root, then parent, then current
                COALESCE( rt.wac_price, z.wac_price) wac_price,
                CASE
                   -- Only change when RMUS/CARS chargeback found
                   WHEN rt.trans_cls_cd = z.trans_cls_idr
                    AND rt.source_sys_cde = z.system_cars
                   THEN COALESCE( rt.pkg_qty, z.pkg_qty)
                   ELSE z.pkg_qty
                END pkg_qty,
                z.total_amt,
                CASE
                   -- Only change when RMUS/CARS chargeback found
                   WHEN rt.trans_cls_cd = z.trans_cls_idr
                    AND rt.source_sys_cde = z.system_cars
                   THEN COALESCE( rt.total_amt, z.rt_total_amt)
                   ELSE z.rt_total_amt
                END rt_total_amt,
                -- Parent chgbk amt will be NULL when this chgbk amt is not null
                COALESCE( rt.whls_chrgbck_amt, z.whls_chrgbck_amt) whls_chrgbck_amt,
                z.gross_sale_amt,
                z.calc_running,
                z.flag_yes,
                z.trans_cls_dir,
                z.trans_cls_idr,
                z.trans_cls_rbt,
                z.trans_adj_original,
                z.trans_adj_cars_rollup,
                z.system_sap,
                z.system_sap4h,
                z.system_cars
           FROM p5 z,
                hcrs.mstr_trans_t rt
          WHERE COALESCE( z.cars_trans_id,
                          z.sap_trans_id) = rt.trans_id (+)
        ),
        p7
     AS (-- P7 - Trans: Calculate the gross and discount dollars, filter by true earn date
         SELECT /*+ QB_NAME( p7 )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.trans_cls_cd,
                z.rt_trans_cls_cd,
                z.bndl_cd,
                z.cond_cd,
                z.cond_strt_dt,
                z.cond_end_dt,
                z.bndl_seq_no,
                z.min_paid_start_dt,
                z.max_paid_end_dt,
                z.min_earn_start_dt,
                z.max_earn_end_dt,
                z.paid_dt,
                z.earn_dt,
                z.bndl_ndc_lbl,
                z.bndl_ndc_prod,
                z.bndl_ndc_pckg,
                z.lgcy_trans_no,
                z.assc_invc_no,
                z.lgcy_trans_line_no,
                z.contr_id,
                z.price_grp_no,
                CASE
                   WHEN z.contr_id IS NOT NULL
                    AND z.price_grp_no IS NOT NULL
                    AND EXISTS
                        (-- Check if transaction on bundle contract price group
                           SELECT /*+ QB_NAME( p7a )
                                      NO_MERGE
                                      INDEX( ppbdw prfl_prod_bndl_dts_wrk_ix1 )
                                      DYNAMIC_SAMPLING( 0 )
                                  */
                                  NULL
                             FROM hcrs.prfl_prod_bndl_dts_wrk_t ppbdw
                               --------------------------------------------------------------------
                               -- Z-PPBDW: All Transactions to Profile Product Bundle Dates
                               -- 4.4. The transaction's contract and price group must be
                               --      assigned to the bundle code.
                               -- 4.5. The transaction's Earned Date must fall within the
                               --      effective range of the contract price group bundle.
                               -- 4.6. The transaction's Earned Date must fall within the
                               --      bundle condition effective period.
                               -- 4.7. The transaction's Earned Date must fall within the
                               --      pricing period of the contract price group bundle.
                            WHERE z.bndl_cd = ppbdw.bndl_cd
                              AND z.contr_id = ppbdw.contr_id
                              AND z.price_grp_no = ppbdw.price_grp_no
                              AND z.cond_cd = ppbdw.cond_cd
                              AND z.earn_dt BETWEEN ppbdw.cond_strt_dt AND ppbdw.cond_end_dt
                              AND z.earn_dt BETWEEN ppbdw.bndl_strt_dt AND ppbdw.bndl_end_dt
                              AND z.earn_dt BETWEEN ppbdw.prcg_strt_dt AND ppbdw.prcg_end_dt
                              AND z.earn_dt BETWEEN z.cond_strt_dt AND z.cond_end_dt
                        )
                   THEN 1
                END bndl_price_grp,
                z.trans_id,
                CASE
                   -- Rebates on Chargebacks (ICW_KEY / CARS_RBT_FEE)
                   WHEN z.trans_cls_cd = z.trans_cls_rbt
                    AND z.rt_trans_cls_cd = z.trans_cls_idr
                    AND z.source_sys_cde = z.system_cars
                   THEN COALESCE( z.rt_total_amt, 0) + COALESCE( z.whls_chrgbck_amt, 0)
                   -- Rebates on Utilization
                   WHEN z.trans_cls_cd = z.trans_cls_rbt
                    AND z.rt_trans_cls_cd = z.trans_cls_rbt
                    AND z.source_sys_cde = z.system_cars
                   THEN COALESCE( z.gross_sale_amt, 0)
                   -- Rebates on Direct Sales (ICW_KEY)
                   WHEN z.trans_cls_cd = z.trans_cls_rbt
                    AND z.rt_trans_cls_cd = z.trans_cls_dir
                    AND z.source_sys_cde IN (z.system_sap,
                                             z.system_sap4h)
                   THEN COALESCE( z.pkg_qty * z.wac_price, 0)
                   -- Chargebacks
                   WHEN z.trans_cls_cd = z.trans_cls_idr
                   THEN COALESCE( z.total_amt, 0) + COALESCE( z.whls_chrgbck_amt, 0)
                   -- Direct Sales
                   WHEN z.trans_cls_cd = z.trans_cls_dir
                    AND z.pkg_qty <> 0
                   THEN COALESCE( z.pkg_qty * z.wac_price, 0)
                   -- Direct Sales (credits)
                   WHEN z.trans_cls_cd = z.trans_cls_dir
                    AND z.pkg_qty = 0
                   THEN 0
                   ELSE 0
                END dllrs_grs,
                CASE
                    -- Rebates (rebate amount stored as sale amount, convert to discount amount)
                   WHEN z.trans_cls_cd = z.trans_cls_rbt
                   THEN COALESCE( z.total_amt, 0) * -1
                    -- Chargebacks
                   WHEN z.trans_cls_cd = z.trans_cls_idr
                   THEN COALESCE( z.whls_chrgbck_amt, 0)
                   -- Direct Sales
                   WHEN z.trans_cls_cd = z.trans_cls_dir
                    AND z.pkg_qty <> 0
                   THEN COALESCE( z.pkg_qty * z.wac_price, 0) - COALESCE( z.total_amt, 0)
                   -- Direct Sales (credits)
                   WHEN z.trans_cls_cd = z.trans_cls_dir
                    AND z.pkg_qty = 0
                   THEN COALESCE( z.total_amt, 0)
                   ELSE 0
                END dllrs_dsc,
                z.calc_running,
                z.flag_yes,
                z.trans_cls_idr,
                z.trans_cls_rbt,
                z.trans_adj_original,
                z.trans_adj_cars_rollup
           FROM p6 z
          WHERE z.earn_dt BETWEEN z.cust_strt_dt AND z.cust_end_dt
            AND z.earn_dt BETWEEN z.bndl_strt_dt AND z.bndl_end_dt
            AND z.earn_dt BETWEEN z.cond_strt_dt AND z.cond_end_dt
            AND z.earn_dt BETWEEN z.cot_begn_dt AND z.cot_end_dt
            AND z.earn_dt BETWEEN z.tt_begn_dt AND z.tt_end_dt
        ),
        p8
     AS (-- P8 - Bundles: Get all price group bundle dates actually in use by transactions
         SELECT /*+ QB_NAME( p8 )
                    NO_MERGE
                    LEADING( z ppbdw )
                    USE_HASH( z ppbdw )
                    FULL( ppbdw )
                    DYNAMIC_SAMPLING( 0 )
                */
                z.trans_cls_cd,
                ppbdw.bndl_cd,
                ppbdw.cond_cd,
                ppbdw.cond_seq_no,
                GREATEST( z.cond_strt_dt, ppbdw.cond_strt_dt) cond_strt_dt,
                LEAST( z.cond_end_dt, ppbdw.cond_end_dt) cond_end_dt,
                ppbdw.prcg_strt_dt,
                ppbdw.prcg_end_dt,
                ppbdw.perf_strt_dt,
                ppbdw.perf_end_dt,
                z.bndl_seq_no
           FROM p7 z,
                hcrs.prfl_prod_bndl_dts_wrk_t ppbdw
            --------------------------------------------------------------------
            -- Z-PPBDW: All Transactions to Profile Product Bundle Dates
            -- 4.4. The transaction's contract and price group must be
            --      assigned to the bundle code.
            -- 4.5. The transaction's Earned Date must fall within the
            --      effective range of the contract price group bundle.
            -- 4.6. The transaction's Earned Date must fall within the
            --      bundle condition effective period.
            -- 4.7. The transaction's Earned Date must fall within the
            --      pricing period of the contract price group bundle.
            -- 4.9. The customer condtion must be effective during the
            --      bundle condition effective period.
          WHERE z.bndl_cd = ppbdw.bndl_cd
            AND z.contr_id = ppbdw.contr_id
            AND z.price_grp_no = ppbdw.price_grp_no
            AND z.cond_cd = ppbdw.cond_cd
            AND z.cond_strt_dt <= ppbdw.cond_end_dt
            AND z.cond_end_dt >= ppbdw.cond_strt_dt
            AND z.earn_dt BETWEEN ppbdw.cond_strt_dt AND ppbdw.cond_end_dt
            AND z.earn_dt BETWEEN ppbdw.bndl_strt_dt AND ppbdw.bndl_end_dt
            AND z.earn_dt BETWEEN ppbdw.prcg_strt_dt AND ppbdw.prcg_end_dt
        ),
        p9
     AS (-- P9 - Bundles: Get the bundle dates in use, filter out inactive conditions
         SELECT /*+ QB_NAME( p9 )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                DISTINCT
                z.trans_cls_cd,
                z.bndl_cd,
                z.cond_cd,
                z.cond_seq_no,
                z.cond_strt_dt,
                z.cond_end_dt,
                z.prcg_strt_dt,
                z.prcg_end_dt,
                z.perf_strt_dt,
                z.perf_end_dt,
                z.bndl_seq_no
           FROM p8 z
             -- filter non-NONE conditions where the condition was not active
             -- NONE conditions always effective beginning of time to end of time
          WHERE z.prcg_strt_dt BETWEEN z.cond_strt_dt AND z.cond_end_dt
            AND z.prcg_end_dt BETWEEN z.cond_strt_dt AND z.cond_end_dt
        ),
        pa
     AS (-- PA - Bundles: Find condition overrides
         SELECT /*+ QB_NAME( pa )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                z.trans_cls_cd,
                z.bndl_cd,
                z.cond_cd,
                z.cond_seq_no,
                -- Get first condition in effect for the pricing period
                FIRST_VALUE( z.cond_cd)
                   OVER (PARTITION BY z.trans_cls_cd,
                                      z.bndl_cd,
                                      z.prcg_strt_dt,
                                      z.prcg_end_dt
                             ORDER BY z.cond_seq_no,
                                      z.perf_strt_dt,
                                      z.perf_end_dt) first_cond_cd,
                z.prcg_strt_dt,
                z.prcg_end_dt,
                z.perf_strt_dt,
                z.perf_end_dt,
                z.bndl_seq_no
           FROM p9 z
        ),
        pb
     AS (-- PB - Bundles: Add the bundle sequence number, remove unneeded conditions
         SELECT /*+ QB_NAME( pb )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                z.trans_cls_cd,
                z.bndl_cd,
                z.cond_cd,
                z.prcg_strt_dt,
                z.prcg_end_dt,
                z.perf_strt_dt,
                z.perf_end_dt,
                z.bndl_seq_no +
                   ROW_NUMBER()
                      OVER (ORDER BY z.trans_cls_cd,
                                     z.bndl_cd,
                                     z.cond_seq_no,
                                     z.prcg_strt_dt,
                                     z.cond_cd,
                                     z.prcg_end_dt,
                                     z.perf_strt_dt,
                                     z.perf_end_dt) bndl_seq_no
           FROM pa z
          WHERE z.cond_cd = z.first_cond_cd
        ),
        pc
     AS (-- PC - Trans: Get transactions for each linked bundle date range
         SELECT /*+ QB_NAME( pc )
                    NO_MERGE
                    LEADING( z y )
                    USE_HASH( z y )
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.trans_cls_cd,
                z.rt_trans_cls_cd,
                z.bndl_cd,
                y.cond_cd,
                y.prcg_strt_dt,
                y.prcg_end_dt,
                y.perf_strt_dt,
                y.perf_end_dt,
                y.bndl_seq_no,
                z.earn_dt,
                z.bndl_ndc_lbl,
                z.bndl_ndc_prod,
                z.bndl_ndc_pckg,
                z.lgcy_trans_no,
                z.assc_invc_no,
                z.lgcy_trans_line_no,
                z.contr_id,
                z.trans_id,
                CASE
                   --------------------------------------------------------------------
                   -- ATR: Additional pricing period requirements:
                   -- 6.1. The transaction's contract and price group must be
                   --      assigned to the bundle code.
                   -- 6.2. The transaction's earned date must be within the
                   --      pricing period of the bundle code that applies to
                   --      the source transaction.
                   WHEN z.earn_dt BETWEEN y.prcg_strt_dt AND y.prcg_end_dt
                    AND z.bndl_price_grp IS NOT NULL
                   THEN 1
                   --------------------------------------------------------------------
                   -- ATR: Additional performance period requirements:
                   -- 7.1. The transaction's contract and price group may be
                   --      any contract and price group.
                   -- 7.2. The transaction's earned date must be within the
                   --      performance period for the bundle code that applies
                   --      to the source transaction.
                   WHEN z.earn_dt BETWEEN y.perf_strt_dt AND y.perf_end_dt
                   THEN 2
                   -- Do not include
                   ELSE 0
                END prcg_perf_ind,
                z.dllrs_grs,
                z.dllrs_dsc,
                --------------------------------------------------------------------
                -- PNC: Additional requirements
                -- 8.2. There must be transactions using an NDC in the main
                --      calculation in the pricing or performance period.
                --      Those transactions must occur during the range of
                --      dates used by the main calculation by the
                --      paid date and/or earned date as used by the main
                --      calculation.
                CASE
                   -- main calculation NDC found
                   WHEN z.paid_dt BETWEEN z.min_paid_start_dt AND z.max_paid_end_dt
                     OR z.earn_dt BETWEEN z.min_earn_start_dt AND z.max_earn_end_dt
                   THEN 1
                   ELSE 0
                END calc_ndc_ind,
                z.calc_running,
                z.flag_yes,
                z.trans_cls_idr,
                z.trans_cls_rbt,
                z.trans_adj_original,
                z.trans_adj_cars_rollup
           FROM p7 z,
                pb y
          WHERE z.trans_cls_cd = y.trans_cls_cd
            AND z.bndl_cd = y.bndl_cd
            AND (   z.earn_dt BETWEEN y.prcg_strt_dt AND y.prcg_end_dt
                 OR z.earn_dt BETWEEN y.perf_strt_dt AND y.perf_end_dt)
        ),
        pd
     AS (-- PD - Trans: Check for main calc NDCs
         SELECT /*+ QB_NAME( pd )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.trans_cls_cd,
                z.rt_trans_cls_cd,
                z.bndl_cd,
                z.cond_cd,
                z.prcg_strt_dt,
                z.prcg_end_dt,
                z.perf_strt_dt,
                z.perf_end_dt,
                z.bndl_seq_no,
                z.earn_dt,
                z.bndl_ndc_lbl,
                z.bndl_ndc_prod,
                z.bndl_ndc_pckg,
                z.lgcy_trans_no,
                z.assc_invc_no,
                z.lgcy_trans_line_no,
                z.contr_id,
                z.trans_id,
                z.prcg_perf_ind,
                z.dllrs_grs,
                z.dllrs_dsc,
                --------------------------------------------------------------------
                -- PNC: Additional requirements
                -- 8.2. There must be transactions using an NDC in the main
                --      calculation in the pricing or performance period.
                --      Those transactions must occur during the range of
                --      dates used by the main calculation by the
                --      paid date and/or earned date as used by the main
                --      calculation.
                SUM( z.calc_ndc_ind) OVER (PARTITION BY z.bndl_seq_no) ndc_cnt,
                z.calc_running,
                z.flag_yes,
                z.trans_cls_idr,
                z.trans_cls_rbt,
                z.trans_adj_original,
                z.trans_adj_cars_rollup
           FROM pc z
          WHERE z.prcg_perf_ind > 0 -- only include transactions in pricing or perf period
        ),
        pe
     AS (-- PE - Trans: Limit to relationships with main calc NDCs, get trans links
         SELECT /*+ QB_NAME( pe )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.trans_cls_cd,
                z.bndl_cd,
                z.cond_cd,
                z.prcg_strt_dt,
                z.prcg_end_dt,
                z.perf_strt_dt,
                z.perf_end_dt,
                z.bndl_seq_no,
                z.earn_dt,
                z.trans_id,
                CASE
                   -- Rebates on chargebacks link on same lgcy_trans_no
                   WHEN z.trans_cls_cd = z.trans_cls_rbt
                    AND z.rt_trans_cls_cd = z.trans_cls_idr
                   THEN FIRST_VALUE( z.trans_id) OVER
                           (PARTITION BY z.bndl_seq_no,
                                         z.bndl_ndc_lbl,
                                         z.bndl_ndc_prod,
                                         z.bndl_ndc_pckg,
                                         z.contr_id,
                                         -- Use trans id should no invoice number be found
                                         COALESCE( z.lgcy_trans_no, z.trans_id)
                                         -- Use absolute value to preserve order due to
                                         -- ICW using negatives for RMUS external data
                                ORDER BY ABS( z.assc_invc_no) NULLS FIRST,
                                         z.lgcy_trans_line_no,
                                         z.trans_id)
                   -- Rebates on directs and utilization link on same
                   -- lgcy_trans_no and lgcy_trans_line_no
                   WHEN z.trans_cls_cd = z.trans_cls_rbt
                    AND z.rt_trans_cls_cd <> z.trans_cls_idr
                   THEN FIRST_VALUE( z.trans_id) OVER
                           (PARTITION BY z.bndl_seq_no,
                                         z.bndl_ndc_lbl,
                                         z.bndl_ndc_prod,
                                         z.bndl_ndc_pckg,
                                         z.contr_id,
                                         -- Use trans id should no invoice number be found
                                         COALESCE( z.lgcy_trans_no, z.trans_id),
                                         z.lgcy_trans_line_no
                                         -- Use absolute value to preserve order due to
                                         -- ICW using negatives for RMUS external data
                                ORDER BY ABS( z.assc_invc_no) NULLS FIRST,
                                         z.trans_id)
                   ELSE z.trans_id
                END p_trans_id,
                z.prcg_perf_ind,
                z.dllrs_grs,
                z.dllrs_dsc,
                z.calc_running,
                z.flag_yes,
                z.trans_cls_rbt,
                z.trans_adj_original,
                z.trans_adj_cars_rollup
           FROM pd z
          WHERE z.ndc_cnt > 0 -- only when calc ndcs found
        ),
        pf
     AS (-- PF - Trans: Remove duplicate/unneeded gross dollar amounts
         SELECT /*+ QB_NAME( pf )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.trans_cls_cd,
                z.bndl_cd,
                z.cond_cd,
                z.prcg_strt_dt,
                z.prcg_end_dt,
                z.perf_strt_dt,
                z.perf_end_dt,
                z.bndl_seq_no,
                z.earn_dt,
                z.trans_id,
                CASE
                   -- Rebates that are adjusting carry root trans id
                   WHEN z.trans_cls_cd = z.trans_cls_rbt
                    AND z.p_trans_id <> z.trans_id
                   THEN z.p_trans_id
                   ELSE TO_NUMBER( NULL)
                END root_trans_id,
                CASE
                   -- Rebates that are adjusting carry parent trans id
                   WHEN z.trans_cls_cd = z.trans_cls_rbt
                    AND z.p_trans_id <> z.trans_id
                   THEN z.p_trans_id
                   ELSE TO_NUMBER( NULL)
                END parent_trans_id,
                CASE
                   -- Rebates that are adjusting marked as rollups
                   WHEN z.trans_cls_cd = z.trans_cls_rbt
                    AND z.p_trans_id <> z.trans_id
                   THEN z.trans_adj_cars_rollup
                   ELSE z.trans_adj_original
                END trans_adj_cd,
                z.prcg_perf_ind,
                CASE
                   -- Rebates that are adjusting should not have gross dollars
                   WHEN z.trans_cls_cd = z.trans_cls_rbt
                    AND z.p_trans_id <> z.trans_id
                   THEN 0
                   -- Rebates that have been reversed (no discount) should not have gross dollars
                   WHEN z.trans_cls_cd = z.trans_cls_rbt
                    AND z.p_trans_id = z.trans_id
                    AND 0 = SUM( z.dllrs_dsc) OVER (PARTITION BY z.bndl_seq_no, z.p_trans_id)
                   THEN 0
                   ELSE z.dllrs_grs
                END dllrs_grs,
                z.dllrs_dsc,
                z.calc_running,
                z.flag_yes
           FROM pe z
        ),
        pg
     AS (-- PG - Trans: Remove pricing periods with no gross dollars
         SELECT /*+ QB_NAME( pg )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.trans_cls_cd,
                z.bndl_cd,
                z.cond_cd,
                z.prcg_strt_dt,
                z.prcg_end_dt,
                z.perf_strt_dt,
                z.perf_end_dt,
                z.bndl_seq_no,
                z.earn_dt,
                z.trans_id,
                z.root_trans_id,
                z.parent_trans_id,
                z.trans_adj_cd,
                z.prcg_perf_ind,
                --------------------------------------------------------------------
                -- PNC: Additional requirements
                -- 8.1. The pricing period gross dollars must not be equal to zero.
                SUM( DECODE( z.prcg_perf_ind, 1, z.dllrs_grs, 0)) OVER (PARTITION BY z.bndl_seq_no) prcg_dllrs_grs,
                z.dllrs_grs,
                z.dllrs_dsc,
                z.calc_running,
                z.flag_yes
           FROM pf z
        ),
        ph
     AS (-- PH - Transaction Detail: Transform to table fields with gross/discount dollars split into pricing and performance fields
         SELECT /*+ QB_NAME( ph )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.trans_cls_cd,
                z.bndl_cd,
                z.cond_cd,
                z.prcg_strt_dt,
                z.prcg_end_dt,
                z.perf_strt_dt,
                z.perf_end_dt,
                z.bndl_seq_no,
                z.earn_dt,
                z.trans_id,
                z.root_trans_id,
                z.parent_trans_id,
                z.trans_adj_cd,
                DECODE( z.prcg_perf_ind, 1, 1, 0) prcg_trns_cnt,
                DECODE( z.prcg_perf_ind, 1, z.dllrs_grs, 0) prcg_dllrs_grs,
                DECODE( z.prcg_perf_ind, 1, z.dllrs_dsc, 0) prcg_dllrs_dsc,
                DECODE( z.prcg_perf_ind, 2, 1, 0) perf_trns_cnt,
                DECODE( z.prcg_perf_ind, 2, z.dllrs_grs, 0) perf_dllrs_grs,
                DECODE( z.prcg_perf_ind, 2, z.dllrs_dsc, 0) perf_dllrs_dsc,
                z.dllrs_grs,
                z.dllrs_dsc,
                z.calc_running,
                z.flag_yes
           FROM pg z
          WHERE z.prcg_dllrs_grs <> 0 -- only when pricing gross dollars is not zero
        ),
        pi
     AS (-- PI - Transaction Summary: Get sum of transaction detail
         SELECT /*+ QB_NAME( pi )
                    NO_MERGE
                    DYNAMIC_SAMPLING( 0 )
                */
                z.prfl_id,
                z.co_id,
                z.ndc_lbl,
                z.ndc_prod,
                z.ndc_pckg,
                z.calc_typ_cd,
                z.cust_id,
                z.trans_cls_cd,
                z.bndl_cd,
                z.cond_cd,
                z.prcg_strt_dt,
                z.prcg_end_dt,
                z.perf_strt_dt,
                z.perf_end_dt,
                z.bndl_seq_no,
                SUM( z.prcg_trns_cnt) prcg_trns_cnt,
                SUM( z.prcg_dllrs_grs) prcg_dllrs_grs,
                SUM( z.prcg_dllrs_dsc) prcg_dllrs_dsc,
                SUM( z.perf_trns_cnt) perf_trns_cnt,
                SUM( z.perf_dllrs_grs) perf_dllrs_grs,
                SUM( z.perf_dllrs_dsc) perf_dllrs_dsc,
                z.calc_running,
                z.flag_yes
           FROM ph z
          GROUP BY z.prfl_id,
                   z.co_id,
                   z.ndc_lbl,
                   z.ndc_prod,
                   z.ndc_pckg,
                   z.calc_typ_cd,
                   z.cust_id,
                   z.trans_cls_cd,
                   z.bndl_cd,
                   z.cond_cd,
                   z.prcg_strt_dt,
                   z.prcg_end_dt,
                   z.perf_strt_dt,
                   z.perf_end_dt,
                   z.bndl_seq_no,
                   z.calc_running,
                   z.flag_yes
        )
   -- SELECT - Output the Summary and Detail for use by multi-table INSERT
   -- Get union of summary and detail with percentages and totals in insert table order
   SELECT /*+ QB_NAME( final_smry )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
          1 tbl,
          z.prfl_id,
          z.co_id,
          z.ndc_lbl,
          z.ndc_prod,
          z.ndc_pckg,
          z.calc_typ_cd,
          z.cust_id,
          z.trans_cls_cd,
          z.trans_cls_cd trans_typ_cd,
          z.bndl_cd,
          z.cond_cd,
          z.prcg_strt_dt,
          z.prcg_end_dt,
          z.perf_strt_dt,
          z.perf_end_dt,
          z.bndl_seq_no,
          TO_DATE( NULL) trans_dt,
          TO_NUMBER( NULL) trans_id,
          TO_NUMBER( NULL) root_trans_id,
          TO_NUMBER( NULL) parent_trans_id,
          '' trans_adj_cd,
          z.prcg_trns_cnt,
          z.prcg_dllrs_grs,
          z.prcg_dllrs_dsc,
          TO_NUMBER( NULL) prcg_dsc_pct,
          z.perf_trns_cnt,
          z.perf_dllrs_grs,
          z.perf_dllrs_dsc,
          TO_NUMBER( NULL) perf_dsc_pct,
          TO_NUMBER( NULL) dllrs_grs,
          TO_NUMBER( NULL) dllrs_dsc,
          z.calc_running,
          z.flag_yes
     FROM pi z
   UNION ALL
   -- Detail table
   SELECT /*+ QB_NAME( final_dtl )
              NO_MERGE
              DYNAMIC_SAMPLING( 0 )
          */
          2 tbl,
          z.prfl_id,
          z.co_id,
          z.ndc_lbl,
          z.ndc_prod,
          z.ndc_pckg,
          z.calc_typ_cd,
          z.cust_id,
          '' trans_cls_cd,
          '' trans_typ_cd,
          z.bndl_cd,
          '' cond_cd,
          TO_DATE( NULL) prcg_strt_dt,
          TO_DATE( NULL) prcg_end_dt,
          TO_DATE( NULL) perf_strt_dt,
          TO_DATE( NULL) perf_end_dt,
          z.bndl_seq_no,
          z.earn_dt trans_dt,
          z.trans_id,
          z.root_trans_id,
          z.parent_trans_id,
          z.trans_adj_cd,
          z.prcg_trns_cnt,
          z.prcg_dllrs_grs,
          z.prcg_dllrs_dsc,
          DECODE( z.prcg_dllrs_grs, 0, 0, z.prcg_dllrs_dsc / z.prcg_dllrs_grs) prcg_dsc_pct,
          z.perf_trns_cnt,
          z.perf_dllrs_grs,
          z.perf_dllrs_dsc,
          DECODE( z.perf_dllrs_grs, 0, 0, z.perf_dllrs_dsc / z.perf_dllrs_grs) perf_dsc_pct,
          z.dllrs_grs,
          z.dllrs_dsc,
          z.calc_running,
          z.flag_yes
     FROM ph z;
