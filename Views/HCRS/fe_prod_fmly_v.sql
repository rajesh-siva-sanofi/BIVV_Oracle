CREATE OR REPLACE VIEW FE_PROD_FMLY_V AS
SELECT 
/****************************************************************************
   * View Name : fe_prod_fmly_v
   * Date Created : 4/18/2016
   * Author : Tom Zimmerman
   * Description :  
   * Called by datawindow  d_product_family  within w_m_product_family  which resides in the dmpr.pbl
   *
   *
   * MOD HISTORY
   *  Date        Modified by    Reason
   *  ----------  ------------   ------------------------------------------------
   *  1/14/2021   mgedzior       added clotting factor indicator column
   ****************************************************************************/
  pf.FDA_DESI_CD,
  pf.DRUG_TYP_CD,   
  pf.FDA_THERA_CD,   
  pf.PROD_FMLY_NM,   
  pf.MKT_ENTRY_DT,   
  pf.HCFA_UNIT_TYP_CD,   
  pf.POTENCY_FLG,   
  pf.BASELN1_DT,   
  pf.BASELN2_DT,   
  pf.STRENGTH,   
  pf.FORM,   
  pf.NDC_LBL,   
  pf.NDC_PROD,
  pf.PURCHASE_PROD_DT,
  bpf.BRAND_ID,   
  bpf.EFF_DT,   
  bpf.END_DT,   
  dc.DRUG_CATG_CD,   
  dc.EFF_DT AS dc_EFF_DT,   
  dc.END_DT AS dc_END_DT,
  pf.nonrtl_drug_ind,
  pf.nonrtl_route_of_admin,
  pf.cod_stat,
  pf.fda_application_num,
  pf.otc_mono_num,
  pf.line_extension_ind,
  pf.clotting_factor_ind
FROM
 HCRS.PROD_FMLY_T pf,   
 (select * from HCRS.BRAND_PROD_FMLY_T where trunc (sysdate) <= trunc (end_dt)) bpf,   
 (select * from HCRS.PROD_FMLY_DRUG_CATG_T where trunc(sysdate) between eff_dt and end_dt) dc
WHERE
 pf.ndc_prod = bpf.ndc_prod (+)
 and pf.ndc_lbl = bpf.ndc_lbl (+)
 and pf.ndc_lbl = dc.ndc_lbl (+)
 and pf.ndc_prod = dc.ndc_prod (+)
;
