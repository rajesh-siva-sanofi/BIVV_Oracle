CREATE OR REPLACE VIEW hcrs.nom_excl_v
AS
   SELECT
   /****************************************************************************
   *    View Name : nom_excl_v
   * Date Created : 04/23/2007
   *       Author : Joe Kidd
   *  Description : Used by cognos impromptu reports in Main Query:
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  04/24/2007  A. Gamer      Added logic to include in select agency_typ_cd,
   *                            calc_typ_cd, comp_typ_cd
   *  04/13/2009  Joe Kidd      PICC 2053: Profile screen Exclusion tab error
   *                            Limit Contract Title lookup to non-deleted records
   *  02/28/2014  Joe Kidd      CRQ-94942: Correct Performance Issue
   *                            Remove NDC from trans_dt lookups
   *  01/15/2018  Joe Kidd      CHG-0055804: Demand 6812 SURF BSI / Cust COT
   *                            Remove contract low price, use lookup function,
   *                            Use new sales exclusion table format and remove
   *                            profile customer class of trade table
   ****************************************************************************/
          -- Parameters
          pse.prfl_id,
          mt.ndc_lbl,
          mt.ndc_prod,
          mt.ndc_pckg,
          -- Profile Level
          p.agency_typ_cd,
          p.prfl_nm,
          p.begn_dt AS prfl_begn_dt,
          p.end_dt AS prfl_end_dt,
          p.prfl_stat_cd,
          p.tim_per_cd,
          p.snpsht_id,
          p.prcss_typ_cd,
          -- Product Level
          mt.ndc_lbl || '-' || mt.ndc_prod || '-' || mt.ndc_pckg ndc,
          pm.prod_nm,
          -- Customer Level
          mt.cust_id,
          c.cust_nm,
          pse.cls_of_trd_cd,
          cot.cls_of_trd_descr,
          -- Contract Level
          mt.contr_id,
          (SELECT hcrs.pkg_common_functions.f_get_contr_title( mt.contr_id) FROM dual) cont_title,
          -- Transaction Level
          DECODE( pse.adj_cnt, 0, 'N', 'Y') adjusted,
          pse.over_ind,
          pse.cmt_txt,
          pse.apprvd_by,
          pse.apprvd_dt,
          mt.trans_typ_cd,
          tt.trans_typ_descr,
          NVL(
             (SELECT ppc.calc_typ_cd
                FROM hcrs.prfl_prod_calc_t ppc
               WHERE ppc.prfl_id = pse.prfl_id
                 AND ppc.ndc_lbl = mt.ndc_lbl
                 AND ppc.ndc_prod = mt.ndc_prod
                 AND ppc.ndc_pckg = mt.ndc_pckg
                 AND ppc.comp_typ_cd = 'ND'),
             (SELECT ppfc.calc_typ_cd
                FROM hcrs.prfl_prod_fmly_calc_t ppfc
               WHERE ppfc.prfl_id = pse.prfl_id
                 AND ppfc.ndc_lbl = mt.ndc_lbl
                 AND ppfc.ndc_prod = mt.ndc_prod
                 AND ppfc.calc_typ_cd = 'AMP'
                 AND ppfc.comp_typ_cd = 'ND')) calc_typ_cd,
          NVL(
             (SELECT ppc.comp_typ_cd
                FROM hcrs.prfl_prod_calc_t ppc
               WHERE ppc.prfl_id = pse.prfl_id
                 AND ppc.ndc_lbl = mt.ndc_lbl
                 AND ppc.ndc_prod = mt.ndc_prod
                 AND ppc.ndc_pckg = mt.ndc_pckg
                 AND ppc.comp_typ_cd = 'ND'),
             (SELECT ppfc.comp_typ_cd
                FROM hcrs.prfl_prod_fmly_calc_t ppfc
               WHERE ppfc.prfl_id = pse.prfl_id
                 AND ppfc.ndc_lbl = mt.ndc_lbl
                 AND ppfc.ndc_prod = mt.ndc_prod
                 AND ppfc.calc_typ_cd = 'AMP'
                 AND ppfc.comp_typ_cd = 'ND')) comp_typ_cd,
          DECODE( NVL( pse.trans_adj_cd, 'ORIGINAL'), 'ORIGINAL', NVL( pse.nmnl_thres_amt, NVL(
             (SELECT ppc.calc_amt
                FROM hcrs.prfl_prod_calc_t ppc
               WHERE ppc.prfl_id = pse.prfl_id
                 AND ppc.ndc_lbl = mt.ndc_lbl
                 AND ppc.ndc_prod = mt.ndc_prod
                 AND ppc.ndc_pckg = mt.ndc_pckg
                 AND ppc.comp_typ_cd = 'ND'),
             (SELECT ppfc.calc_amt
                FROM hcrs.prfl_prod_fmly_calc_t ppfc
               WHERE ppfc.prfl_id = pse.prfl_id
                 AND ppfc.ndc_lbl = mt.ndc_lbl
                 AND ppfc.ndc_prod = mt.ndc_prod
                 AND ppfc.calc_typ_cd = 'AMP'
                 AND ppfc.comp_typ_cd = 'ND')))) nominal_threshold_amt,
          pse.adj_total_amt / DECODE( pse.adj_pkg_qty, 0, 1, pse.adj_pkg_qty) adj_price,
          pse.adj_pkg_qty,
          pse.adj_total_amt,
          CASE
             -- original amount logic before 04/01/2007
             WHEN pse.dllr_amt IS NOT NULL
              AND pse.create_dt < TO_DATE( '04/01/2007', 'MM/DD/YYYY')
              AND pse.pkg_qty + NVL( pse.nom_pkg_qty, 0) <> 0
             THEN ((pse.dllr_amt * (1 - (pse.term_disc_pct / 100))) + NVL( pse.nom_pkg_qty, 0)) / (pse.pkg_qty + NVL( pse.nom_pkg_qty, 0))
             -- new amount logic after 04/01/2007
             WHEN pse.dllr_amt IS NOT NULL
              AND pse.nom_pkg_qty IS NOT NULL
              AND pse.nom_pkg_qty <> 0
             THEN pse.nom_dllr_amt / pse.nom_pkg_qty
             -- values not recorded, use transaction values
             WHEN pse.dllr_amt IS NULL
              AND DECODE( NVL( mt.claim_unit_qty, 0), 0, NVL( mt.pkg_qty, 0), mt.claim_unit_qty / pm.unit_per_pckg) <> 0
             THEN (NVL( mt.gross_sale_amt, 0) + (NVL( mt.total_amt, 0) * (1 - ( NVL( mt.term_disc_pct, 0) / 100)))) / DECODE( NVL( mt.claim_unit_qty, 0), 0, NVL( mt.pkg_qty, 0), mt.claim_unit_qty / pm.unit_per_pckg)
             ELSE 0
          END dllrs_pkgs,
          CASE
             -- original amount logic before 04/01/2007
             WHEN pse.dllr_amt IS NOT NULL
              AND pse.create_dt < TO_DATE( '04/01/2007', 'MM/DD/YYYY')
             THEN pse.pkg_qty + NVL( pse.nom_pkg_qty, 0)
             -- new amount logic after 04/01/2007
             WHEN pse.dllr_amt IS NOT NULL
             THEN pse.nom_pkg_qty
             ELSE DECODE( NVL( mt.claim_unit_qty, 0), 0, NVL( mt.pkg_qty, 0), mt.claim_unit_qty / pm.unit_per_pckg)
          END pkgs,
          CASE
             -- original amount logic before 04/01/2007
             WHEN pse.dllr_amt IS NOT NULL
              AND pse.create_dt < TO_DATE( '04/01/2007', 'MM/DD/YYYY')
             THEN (pse.dllr_amt * (1 - (pse.term_disc_pct / 100))) + NVL( pse.nom_pkg_qty, 0)
             -- new amount logic after 04/01/2007
             WHEN pse.dllr_amt IS NOT NULL
             THEN pse.nom_dllr_amt
             -- values not recorded, use transaction values
             ELSE NVL( mt.gross_sale_amt, 0) + (NVL( mt.total_amt, 0) * (1 - ( NVL( mt.term_disc_pct, 0) / 100)))
          END dllrs,
          NVL( (SELECT MIN( ppct.trans_dt)
                  FROM hcrs.prfl_prod_comp_trans_t ppct
                 WHERE ppct.prfl_id = pse.prfl_id
                   AND ppct.trans_id = pse.trans_id),
               NVL( (SELECT MIN( ppfct.trans_dt)
                       FROM hcrs.prfl_prod_fmly_comp_trans_t ppfct
                      WHERE ppfct.prfl_id = pse.prfl_id
                        AND ppfct.trans_id = pse.trans_id), NVL( mt.assc_invc_dt, mt.trans_dt))) trans_dt,
          mt.lgcy_trans_no,
          mt.lgcy_trans_line_no,
          mt.lgcy_trans_no || DECODE( mt.lgcy_trans_line_no, NULL, NULL, '-' || mt.lgcy_trans_line_no) invc_line_no,
          mt.price_grp_id,
          mt.whls_id,
          CASE
             -- use marked values
             WHEN pse.dllr_amt IS NOT NULL
             THEN pse.chrgbck_amt
             -- use transaction values
             ELSE mt.whls_chrgbck_amt
          END chrgbcks,
          mt.assc_invc_dt,
          mt.assc_invc_no,
          mt.assc_invc_line_no,
          mt.manual_adj_ind,
          mt.claim_bgn_dt,
          mt.claim_end_dt,
          NVL( pse.root_trans_id, pse.trans_id) root_trans_id,
          NVL( pse.parent_trans_id, pse.trans_id) parent_trans_id,
          pse.trans_id,
          pse.trans_adj_cd,
          ta.trans_adj_descr,
          mt.co_id
     FROM hcrs.prfl_sls_excl_t pse,
          hcrs.prfl_t p,
          hcrs.trans_adj_t ta,
          hcrs.mstr_trans_t mt,
          hcrs.prod_mstr_t pm,
          hcrs.cust_t c,
          hcrs.trans_typ_t tt,
          hcrs.cls_of_trd_t cot
    WHERE pse.prfl_id = p.prfl_id
      AND pse.trans_adj_cd = ta.trans_adj_cd (+)
      AND pse.trans_id = mt.trans_id
      AND mt.ndc_lbl = pm.ndc_lbl
      AND mt.ndc_prod = pm.ndc_prod
      AND mt.ndc_pckg = pm.ndc_pckg
      AND mt.cust_id = c.cust_id
      AND mt.co_id = tt.co_id
      AND mt.trans_typ_cd = tt.trans_typ_cd
      AND pse.co_id = cot.co_id
      AND pse.cls_of_trd_cd = cot.cls_of_trd_cd;
