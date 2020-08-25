CREATE OR REPLACE VIEW hcrs.int_intrfc_1215_v
AS
   SELECT
   /****************************************************************************
   *    View Name : int_intrfc_1215_v
   * Date Created : 09/01/2009
   *       Author : Joe Kidd
   *  Description : Translates icw2_intrpd_sales_v into mstr_trans_stg_t for
   *                Interface 1215.
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  01/27/2010  Joe Kidd      RT 2009-372 - IS-000000000018 - Prasco/Winthrop Initiative
   *                            Added src_tbl_cd field
   *                            Correct Invoice Type and Reason Code values
   *  08/09/2010  Joe Kidd      CRQ-50196: August 2010 GPCS Interface Release
   *                            Limit to US companies
   *  03/01/2011  Joe Kidd      CRQ-2196: Load ICW Related Credit Number
   *                            Add related credits id field
   *  09/14/2011  Joe Kidd      CRQ-10164: Genzyme GP Integration Phase 1 part 1
   *                            Add Line Ref ID and WAC price fields
   *  03/02/2012  Joe Kidd      CRQ-13227: Genzyme GP Integration Phase 1 part 2
   *                            Change Company limit from include to exclude list
   *                            Easier to delete extra trans that add missing trans
   *  07/05/2012  Joe Kidd      CRQ-24537: Genzyme GP Integration Phase 2 part 2
   *                            All chargebacks use IDRCAC transaction type
   *                            Block Genzyme legacy data rebates created for SPM only
   *                            Add keys for Genzyme legacy data
   *                            Add fields to allow searching directly on this view
   *  09/25/2012  Joe Kidd      CRQ-31332: GP Methodology Harmonization
   *                            Reorg fields based on new staging/prod table
   *                            Total Amt and Pkg Qty must have a value
   *  11/01/2012  Joe Kidd      CRQ-31333: Sklice GP Integration
   *                            Rename views with new interface IDs
   *  10/17/2014  Joe Kidd      CRQ-131909: Demand 2849 Bundling of SAP Direct Sales
   *                            Add WAC price and WAC extended amount columns
   *                            Support reloading transactions
   *  03/01/2019  Deepak Gupta  CHG0123872: SHIFT BSI
   *                            Support SAP4H transactions, add term code, add
   *                            original invoice source system, and others for
   *                            support queries
   *  08/01/2020  Joe Kidd      CHG-000000: Bioverativ Integration
   *                            Add Bioverative RxC Direct and Indirect Sales
   *                            Update Company Code filter
   ****************************************************************************/
          -- ICW Fields (needed for interface queries)
          iis.sales_num,
          iis.created_dte,
          iis.sale_dte,
          iis.ndc_cde,
          -- ICW Fields (added for support queries)
          iis.sales_type_cde,
          iis.invce_type_cde,
          iis.reasn_cde,
          iis.po_dte,
          iis.invce_dte,
          iis.invce_num,
          iis.invce_line_num,
          iis.orig_invce_dte,
          iis.orig_invce_num,
          iis.orig_invce_src_sys_cde,
          iis.cust_invce_dte,
          iis.whlslr_invce_dte,
          iis.whlslr_invce_num,
          iis.crdt_issue_dte,
          iis.adj_num,
          iis.adj_line_num,
          iis.adj_num_prior,
          iis.submitm_num,
          iis.submitem_num_prior,
          iis.contr_ownr_id,
          iis.cpgrp_num,
          iis.source_sys_cust_id,
          iis.source_shipto_cust_id,
          iis.source_billto_cust_id,
          iis.co_cde,
          iis.dea_num,
          iis.hin_num,
          iis.id_340b,
          iis.bobtyp_id,
          iis.pkg_units,
          iis.list_price,
          iis.gross_sale_amt intrpd_gross_sale_amt,
          iis.term_disc_pct intrpd_term_disc_pct,
          iis.chrgbk_claim_amt,
          iis.extnd_amt,
          -- GPCS Fields
          NVL( iis.created_dte, SYSDATE) lgcy_mod_dt,
          'Y' rld_new_ind,
          'N' rld_reload_ind,
          'N' rld_archive_ind,
          TO_NUMBER( NULL) rld_snpsht_id,
          'N' archive_ind,
          'N' manual_adj_ind,
          '' man_adj_agency_cd,
          'IIS' src_tbl_cd,
          DECODE( iis.sales_type_cde,
                  'DIRECT', 'D',
                  'INDIRECT', 'I') trans_cls_cd,
          'S' source_trans_typ,
          iis.sales_num unique_id,
          iis.source_sys_cde source_sys_cde,
          SUBSTR( iis.ndc_cde, 1, 5) ndc_lbl,
          SUBSTR( iis.ndc_cde, 6, 4) ndc_prod,
          SUBSTR( iis.ndc_cde, 10, 2) ndc_pckg,
          iis.cust_id cust_id,
          iis.whlslr_cust_id whls_id,
          iis.billto_cust_id,
          iis.shipto_cust_id,
          DECODE( iis.sales_type_cde,
                  'DIRECT', NVL( iis.invce_type_cde || iis.reasn_cde, 'NONE'),
                  'INDIRECT', 'IDRCAC') trans_typ_cd,
          DECODE( iis.sales_type_cde,
                  'DIRECT', iis.reasn_cde,
                  'INDIRECT', '') reasn_cd,
          DECODE( iis.sales_type_cde,
                  'DIRECT', iis.invce_type_cde,
                  'INDIRECT', 'CAC') invc_typ_cd,
          DECODE( iis.sales_type_cde,
                  'DIRECT', iis.invce_dte,
                  'INDIRECT', iis.crdt_issue_dte) paid_dt,
          DECODE( iis.sales_type_cde,
                  'DIRECT', iis.invce_dte,
                  'INDIRECT', iis.whlslr_invce_dte) earn_bgn_dt,
          DECODE( iis.sales_type_cde,
                  'DIRECT', iis.invce_dte,
                  'INDIRECT', iis.whlslr_invce_dte) earn_end_dt,
          DECODE( iis.sales_type_cde,
                  'DIRECT', iis.invce_dte,
                  'INDIRECT', iis.whlslr_invce_dte) trans_dt,
          DECODE( iis.sales_type_cde,
                  'DIRECT', iis.orig_invce_dte,
                  'INDIRECT', TO_DATE( NULL, '')) assc_invc_dt,
          TO_DATE( NULL, '') claim_bgn_dt,
          TO_DATE( NULL, '') claim_end_dt,
          DECODE( iis.sales_type_cde,
                  'DIRECT', TO_NUMBER( iis.invce_num),
                  'INDIRECT', DECODE( iis.source_sys_cde,
                                      'CARS', iis.submitm_num,
                                      'BIVVRXC', iis.submitm_num,
                                      'SNYCARS', iis.submitm_num,
                                      'SNYMANUAL', iis.submitm_num,
                                      'GNZ', iis.submitm_num,
                                      iis.adj_num)) lgcy_trans_no,
          DECODE( iis.sales_type_cde,
                  'DIRECT', iis.invce_line_num,
                  'INDIRECT', DECODE( iis.source_sys_cde,
                                      'CARS', iis.adj_num,
                                      'BIVVRXC', iis.adj_num,
                                      'SNYCARS', iis.adj_num,
                                      'SNYMANUAL', iis.adj_num,
                                      'GNZ', iis.adj_num,
                                      iis.adj_line_num)) lgcy_trans_line_no,
          DECODE( iis.sales_type_cde,
                  'DIRECT', TO_NUMBER( iis.orig_invce_num),
                  'INDIRECT', DECODE( iis.source_sys_cde,
                                      'CARS', iis.submitem_num_prior,
                                      'SNYCARS', iis.submitem_num_prior,
                                      'SNYMANUAL', iis.submitem_num_prior,
                                      TO_NUMBER( NULL))) assc_invc_no,
          TO_NUMBER( NULL) assc_invc_line_no,
          CASE
             -- SAP always uses SAP for original invoice
             WHEN iis.source_sys_cde = 'SAP'
              AND iis.orig_invce_num IS NOT NULL
             THEN iis.source_sys_cde
             -- Original source system is only populated for SAP4H invoices
             -- SAP4H will have SAP4H or SAP for original source system
             ELSE iis.orig_invce_src_sys_cde
          END assc_invc_source_sys_cde,
          iis.contr_id contr_id,
          TO_CHAR( iis.cpgrp_num) price_grp_id,
          TO_NUMBER( NULL) related_sales_id,
          TO_NUMBER( NULL) related_credits_id,
          CASE
             WHEN iis.sales_type_cde = 'DIRECT'
              AND iis.source_sys_cde IN ('SAP', 'SAP4H', 'BIVVRXC')
             THEN iis.list_price
             ELSE TO_NUMBER( NULL)
          END wac_price,
          iis.unit_price pkg_price,
          NVL( iis.pkg_units, 0) pkg_qty,
          TO_NUMBER( NULL) claim_unit_qty,
          NVL( iis.gross_sale_amt, 0) total_amt,
          DECODE( iis.sales_type_cde,
                  'DIRECT', NVL( iis.term_disc_pct, 0),
                  'INDIRECT', TO_NUMBER( NULL)) term_disc_pct,
          DECODE( iis.sales_type_cde,
                  'DIRECT', TO_NUMBER( NULL),
                  'INDIRECT', NVL( iis.chrgbk_claim_amt, 0)) whls_chrgbck_amt,
          TO_NUMBER( NULL) gross_sale_amt,
          CASE
             WHEN iis.sales_type_cde = 'DIRECT'
              AND iis.source_sys_cde IN ('SAP', 'SAP4H', 'BIVVRXC')
             THEN iis.list_price * NVL( iis.pkg_units, 0)
             ELSE TO_NUMBER( NULL)
          END wac_extnd_amt,
          iis.terms term_cd,
          TO_NUMBER( NULL) actual_potency,
          '' line_ref_id,
          '' cmt_txt
     FROM hcrs.icw2_intrpd_sales_v iis
       -- Eliminate non-US companys (easier to delete extra data for new companies)
    WHERE iis.co_cde NOT IN ('------',
                             --'0901', -- Sanofi US Services Inc.
                             --'1209', -- Sanofi US Corporation
                             --'2039', -- sanofi-aventis U.S. LLC
                             --'2100', -- Merrell Pharma Inc.
                             '2106',   -- Aventis Pharma, Inc (PR)
                             --'2123', -- Blue Ridge Laboratories
                             --'5100', -- Genzyme Corporation
                             --'9338', -- Sanofi-Synthelabo Inc
                             'PR02', -- Sanofi PR
                             --'US03', -- Genzyme Corporation US
                             --'US12', -- Bioverativ US
                             '------')
       -- Only direct sales and chargebacks (others are linked in credits)
      AND iis.sales_type_cde IN ('DIRECT', 'INDIRECT')
       -- Block Genzyme manual data for SPM source/sales code
      AND iis.source_sys_cde NOT IN ('GNZMANRBT');
