CREATE OR REPLACE PACKAGE HCRS.pkg_ui_dm_prod_sel
AS

   /***********************************************************************************
    *       Package Name   : pkg_ui_dm_prod_sel
    *       Returns        :
    *       Date Created   :
    *       Author         :    Quintiles IMS
    *       Description    :
    *
    *-- Modification History
    * Date          Name                Comment
    * ------------  ---------------- ---------------------------------------------------
    * 3/20/2018 	   Mari 	    CHG0032771 --Creaation Association with First sale
	*								of Qurater for instead of Program Effective  Date
	*								p_assoc_pgm_multi_i  --Added DATE Paramater
    *								f_get_cnt_prod_mstr_pgm --Added to get the cnt
    **********************************************************************************/
   PROCEDURE p_chld_elig_stat_s
     (o_result OUT SYS_REFCURSOR);

   PROCEDURE p_tv_chld_s
     (i_as_ndc_lbl  IN VARCHAR2,
      i_as_ndc_prod IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_tv_prnt_wo_stat_s
     (i_ndc_lbl_low   IN VARCHAR2 := '',
      i_ndc_lbl_high  IN VARCHAR2 := '',
      i_ndc_prod_low  IN VARCHAR2 := '',
      i_ndc_prod_high IN VARCHAR2 := '',
      i_page_no       IN NUMBER := 1,
      i_page_size     IN NUMBER := 10,
      i_sort_col      IN VARCHAR2 := '',
      i_order_typ     IN VARCHAR2 := '',
      i_debug         IN NUMBER := 0,
      o_return_list   OUT SYS_REFCURSOR);

   PROCEDURE p_tv_prnt_with_stat_s
     (i_ndc_lbl_low    IN VARCHAR2 := '',
      i_ndc_lbl_high   IN VARCHAR2 := '',
      i_ndc_prod_low   IN VARCHAR2 := '',
      i_ndc_prod_high  IN VARCHAR2 := '',
      i_elig_stat_low  IN VARCHAR2 := '',
      i_elig_stat_high IN VARCHAR2 := '',
      i_page_no        IN NUMBER := 1,
      i_page_size      IN NUMBER := 10,
      i_sort_col       IN VARCHAR2 := '',
      i_order_typ      IN VARCHAR2 := '',
      i_debug          IN NUMBER := 0,
      o_return_list    OUT SYS_REFCURSOR);

   PROCEDURE p_lbl_attch_chkbox_s
     (i_ndc_lbl IN VARCHAR2,
      o_chk     OUT NUMBER);

   PROCEDURE p_chk_clm_ln_itm
     (i_ndc_lbl            IN VARCHAR2,
      i_item_prod_fmly_ndc IN VARCHAR2,
      i_item_prod_mstr_ndc IN VARCHAR2,
      o_cnt_wo_pkg         OUT NUMBER,
      o_cnt_w_pkg          OUT NUMBER);

   PROCEDURE p_chk_prod_trnsmsn
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      o_cnt      OUT NUMBER);

   PROCEDURE p_prod_fmly_d
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      i_ndc_pckg IN VARCHAR2,
      o_cnt      OUT NUMBER);

   PROCEDURE p_prod_fmly_s
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      o_ret_lst  OUT SYS_REFCURSOR);

   PROCEDURE p_prod_fmly_i
     (i_fda_desi_cd           IN VARCHAR2,
      i_drug_typ_cd           IN VARCHAR2,
      i_fda_thera_cd          IN VARCHAR2,
      i_prod_fmly_nm          IN VARCHAR2,
      i_mkt_entry_dt_str      IN VARCHAR2,
      i_hcfa_unit_typ_cd      IN VARCHAR2,
      i_potency_flg           IN VARCHAR2,
      i_baseln1_dt_str        IN VARCHAR2,
      i_baseln2_dt_str        IN VARCHAR2,
      i_strength              IN VARCHAR2,
      i_form                  IN VARCHAR2,
      i_ndc_lbl               IN VARCHAR2,
      i_ndc_prod              IN VARCHAR2,
      i_purchase_prod_dt_str  IN VARCHAR2,
      i_nonrtl_drug_ind       IN VARCHAR2,
      i_nonrtl_route_of_admin IN VARCHAR2,
      i_cod_stat              IN VARCHAR2,
      i_fda_application_num   IN VARCHAR2,
      i_otc_mono_num          IN VARCHAR2,
      i_line_extension_ind    IN VARCHAR2,
      i_clotting_factor_ind   IN VARCHAR2,
      o_cnt                   OUT NUMBER);

   PROCEDURE p_prod_fmly_u
     (i_fda_desi_cd           IN VARCHAR2,
      i_drug_typ_cd           IN VARCHAR2,
      i_fda_thera_cd          IN VARCHAR2,
      i_prod_fmly_nm          IN VARCHAR2,
      i_mkt_entry_dt_str      IN VARCHAR2,
      i_hcfa_unit_typ_cd      IN VARCHAR2,
      i_potency_flg           IN VARCHAR2,
      i_baseln1_dt_str        IN VARCHAR2,
      i_baseln2_dt_str        IN VARCHAR2,
      i_strength              IN VARCHAR2,
      i_form                  IN VARCHAR2,
      i_ndc_lbl               IN VARCHAR2,
      i_ndc_prod              IN VARCHAR2,
      i_purchase_prod_dt_str  IN VARCHAR2,
      i_nonrtl_drug_ind       IN VARCHAR2,
      i_nonrtl_route_of_admin IN VARCHAR2,
      i_cod_stat              IN VARCHAR2,
      i_fda_application_num   IN VARCHAR2,
      i_otc_mono_num          IN VARCHAR2,
      i_line_extension_ind    IN VARCHAR2,
      i_clotting_factor_ind   IN VARCHAR2,
      o_cnt                   OUT NUMBER);

   PROCEDURE p_prod_fmly_cod_stat_s
     (o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_cd_typ_s
     (o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_chld_fmly_drug_catg_s
     (o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_chld_form_s
     (o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_nonrtl_route_admin_s
     (o_return_list OUT SYS_REFCURSOR);

   -- Link part
   PROCEDURE p_auth_gen_xref_d
     (i_auth_gen_ndc1 IN VARCHAR2,
      i_auth_gen_ndc2 IN VARCHAR2,
      i_auth_gen_ndc3 IN VARCHAR2);

   PROCEDURE p_auth_gen_xref_i
     (i_auth_gen_ndc1  IN VARCHAR2,
      i_auth_gen_ndc2  IN VARCHAR2,
      i_auth_gen_ndc3  IN VARCHAR2,
      i_ndc_lbl        IN VARCHAR2,
      i_ndc_prod       IN VARCHAR2,
      i_ndc_pckg       IN VARCHAR2,
      i_auth_gen_desc  IN VARCHAR2,
      i_auth_gen_co_nm IN VARCHAR2,
      i_strength       IN VARCHAR2,
      i_unit_type      IN VARCHAR2,
      i_unit_per_pckg  IN NUMBER,
      o_record         OUT SYS_REFCURSOR);

   PROCEDURE p_auth_gen_xref_u
     (i_auth_gen_ndc1  IN VARCHAR2,
      i_auth_gen_ndc2  IN VARCHAR2,
      i_auth_gen_ndc3  IN VARCHAR2,
      i_ndc_lbl        IN VARCHAR2,
      i_ndc_prod       IN VARCHAR2,
      i_ndc_pckg       IN VARCHAR2,
      i_auth_gen_desc  IN VARCHAR2,
      i_auth_gen_co_nm IN VARCHAR2,
      i_strength       IN VARCHAR2,
      i_unit_type      IN VARCHAR2,
      i_unit_per_pckg  IN NUMBER,
      o_record         OUT SYS_REFCURSOR);

   -- Link End
   PROCEDURE p_prod_fmly_ppaca_s
    ( i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      i_page_no     IN NUMBER := 1,
      i_page_size   IN NUMBER := 10,
      i_sort_col    IN VARCHAR2,
      i_order_typ   IN VARCHAR2,
      i_debug       IN NUMBER := 0,
      o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_prod_fmly_ppaca_u
     (i_ndc_lbl                IN VARCHAR2,
      i_ndc_prod               IN VARCHAR2,
      i_tim_per_bgn_dt_str     IN VARCHAR2,
      i_tim_per_bgn_dt_new_str IN VARCHAR2,
      i_tim_per_end_dt_str     IN VARCHAR2,
      i_eff_bgn_dt_str         IN VARCHAR2,
      i_eff_end_dt_str         IN VARCHAR2,
      i_ppaca_rtl_ind          IN VARCHAR2,
      o_cnt                    OUT NUMBER);

   PROCEDURE p_prod_fmly_ppaca_d
     (i_ndc_lbl            IN VARCHAR2,
      i_ndc_prod           IN VARCHAR2,
      i_tim_per_bgn_dt_str IN VARCHAR2,
      i_eff_bgn_dt_str     IN VARCHAR2,
      o_cnt                OUT NUMBER);

   PROCEDURE p_prod_fmly_ppaca_i
     (i_ndc_lbl            IN VARCHAR2,
      i_ndc_prod           IN VARCHAR2,
      i_tim_per_bgn_dt_str IN VARCHAR2,
      i_tim_per_end_dt_str IN VARCHAR2,
      i_eff_bgn_dt_str     IN VARCHAR2,
      i_eff_end_dt_str     IN VARCHAR2,
      i_ppaca_rtl_ind      IN VARCHAR2,
      o_cnt                OUT NUMBER);

   PROCEDURE p_drg_catg_prod_fmly_hist_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_prod_fmly_drug_catg_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_brnd_prod_fmly_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_brnd_prod_fmly_i
     (i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_brand_id   IN VARCHAR2,
      i_eff_dt_str IN VARCHAR2,
      i_end_dt_str IN VARCHAR2,
      o_cnt        OUT NUMBER);

   PROCEDURE p_brnd_prod_fmly_u
     (i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_brand_id   IN VARCHAR2,
      i_eff_dt_str IN VARCHAR2,
      i_end_dt_str IN VARCHAR2,
      o_cnt        OUT NUMBER);

   PROCEDURE p_brnd_prod_fmly_d
     (i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_eff_dt_str IN VARCHAR2,
      i_brand_id   IN NUMBER,
      o_cnt        OUT NUMBER);

   PROCEDURE p_drg_catg_prod_fmly_by_cd_d
     (i_ndc_lbl      IN VARCHAR2,
      i_ndc_prod     IN VARCHAR2,
      i_eff_dt_str   IN VARCHAR2,
      i_drug_catg_cd IN VARCHAR2,
      o_cnt          OUT NUMBER);

   PROCEDURE p_drg_catg_prod_fmly_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_drg_catg_prod_fmly_i
     (i_ndc_lbl      IN VARCHAR2,
      i_ndc_prod     IN VARCHAR2,
      i_eff_dt_str   IN VARCHAR2,
      i_drug_catg_cd IN VARCHAR2,
      i_end_dt_str   IN VARCHAR2,
      o_cnt          OUT NUMBER);

   PROCEDURE p_get_first_sld_mrkt_entry_dt
     (i_ndc_lbl           IN VARCHAR2,
      i_ndc_prod          IN VARCHAR2,
      o_first_dt_sld_str  OUT VARCHAR2,
      o_mrkt_entry_dt_str OUT VARCHAR2);

   PROCEDURE p_sap_co_s
     (o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_chld_promo_stat_s
     (o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_chld_elig_rsn_s
     (o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_chld_va_drg_catg_cd_s
     (o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_assoc_pgm_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      i_ndc_pckg    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_assoc_pgm_i
     (i_pgm_id     IN NUMBER,
      i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_ndc_pckg   IN VARCHAR2,
      i_eff_dt_str IN VARCHAR2,
      i_end_dt_str IN VARCHAR2,
      o_cnt        OUT NUMBER);

   PROCEDURE p_assoc_pgm_multi_i
     (i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_ndc_pckg   IN VARCHAR2,
      i_start_dt_str IN VARCHAR2,
      i_end_dt_str IN VARCHAR2,
      o_cnt        OUT NUMBER);

   PROCEDURE p_assoc_pgm_d
     (i_pgm_id     IN NUMBER,
      i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_ndc_pckg   IN VARCHAR2,
      i_eff_dt_str IN VARCHAR2,
      o_cnt        OUT NUMBER);

   PROCEDURE p_assoc_pgm_multi_d
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      i_ndc_pckg IN VARCHAR2,
      o_cnt      OUT NUMBER);

   PROCEDURE p_prod_pckg_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      i_ndc_pckg    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_prog_prod_assoc_s
     (o_return_list OUT SYS_REFCURSOR);

   FUNCTION f_get_cnt_prod_mstr
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      i_ndc_pckg IN VARCHAR2)
      RETURN NUMBER;

    FUNCTION f_get_cnt_prod_mstr_pgm
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      i_ndc_pckg IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_last_dy_prd_str
     (i_end_dt_str IN VARCHAR2)
     RETURN VARCHAR2;

   FUNCTION f_get_last_drug_catg_cd
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2)
      RETURN hcrs.prod_fmly_drug_catg_t.drug_catg_cd%TYPE;

   FUNCTION f_get_last_brnd_id
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2)
      RETURN hcrs.brand_prod_fmly_t.brand_id%TYPE;

   FUNCTION f_get_last_co_id
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      i_ndc_pckg IN VARCHAR2)
      RETURN hcrs.co_prod_mstr_t.co_id%TYPE;

   FUNCTION f_get_max_reb_clm_prd_id
     (i_ndc_lbl   IN VARCHAR2,
      i_ndc_prod  IN VARCHAR2,
      i_ndc_pckg  IN VARCHAR2,
      i_period_id IN NUMBER)
      RETURN NUMBER;

   PROCEDURE p_vld_clm_pgm_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      i_ndc_pckg    IN VARCHAR2,
      i_period_id   IN NUMBER,
      o_return_list OUT SYS_REFCURSOR);

   FUNCTION f_get_qtr_name
     (i_period_id IN NUMBER)
     RETURN VARCHAR2;

   FUNCTION f_get_mkt_entry_dt
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_get_liability_dt_prd_id
     (i_liability_dt_str IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_prod_mstr_pgm_t_end_liab
     (i_ndc_lbl         IN VARCHAR2,
      i_ndc_prod        IN VARCHAR2,
      i_ndc_pckg        IN VARCHAR2,
      i_end_liab_dt_str IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE p_tol_fee_d
     (i_ndc_lbl               IN VARCHAR2,
      i_ndc_prod              IN VARCHAR2,
      i_ndc_pckg              IN VARCHAR2,
      i_end_dt_str            IN VARCHAR2,
      o_cnt_prod_mstr_pgm     OUT NUMBER,
      o_cnt_prod_pgm_fee      OUT NUMBER,
      o_cnt_prod_mstr_pgm_tol OUT NUMBER);

   PROCEDURE p_prod_mstr_pgm_id_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      i_ndc_pckg    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_co_prod_mstr_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      i_ndc_pckg    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR);

   PROCEDURE p_co_prod_mstr_i
     (i_co_id      IN NUMBER,
      i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_ndc_pckg   IN VARCHAR2,
      i_eff_dt_str IN VARCHAR2,
      i_end_dt_str IN VARCHAR2,
      o_cnt        OUT NUMBER);

   PROCEDURE p_prod_pckg_i
     (i_ndc_lbl                    IN VARCHAR2,
      i_ndc_prod                   IN VARCHAR2,
      i_ndc_pckg                   IN VARCHAR2,
      i_unit_per_pckg              IN NUMBER,
      i_hcfa_disp_units            IN NUMBER,
      i_first_dt_sld_dir_str       IN VARCHAR2,
      i_shelf_life_mon             IN NUMBER,
      i_elig_stat_cd               IN VARCHAR2,
      i_inelig_rsn_id              IN NUMBER,
      i_prod_nm                    IN VARCHAR2,
      i_fda_approval_dt_str        IN VARCHAR2,
      i_new_prod_flg               IN VARCHAR2,
      i_first_dt_sld_str           IN VARCHAR2,
      i_divestr_dt_str             IN VARCHAR2,
      i_fda_reg_nm                 IN VARCHAR2,
      i_final_lot_dt_str           IN VARCHAR2,
      i_promo_stat_cd              IN VARCHAR2,
      i_cosmis_ndc                 IN VARCHAR2,
      i_cosmis_descr               IN VARCHAR2,
      i_pckg_nm                    IN VARCHAR2,
      i_medicare_elig_stat_cd      IN VARCHAR2,
      i_sap_prod_cd                IN VARCHAR2,
      i_items_per_ndc              IN NUMBER,
      i_volume_per_item            IN NUMBER,
      i_mdcr_exp_trnsmitted_dt_str IN VARCHAR2,
      i_comm_unit_per_pckg         IN NUMBER,
      i_pname_desc                 IN VARCHAR2,
      i_strngtyp_id                IN VARCHAR2,
      i_sizetyp_id                 IN VARCHAR2,
      i_pkgtyp_id                  IN VARCHAR2,
      i_fdb_case_size              IN NUMBER,
      i_fdb_package_size           IN NUMBER,
      o_cnt                        OUT NUMBER);

   PROCEDURE p_prod_pckg_u
     (i_ndc_lbl                    IN VARCHAR2,
      i_ndc_prod                   IN VARCHAR2,
      i_ndc_pckg                   IN VARCHAR2,
      i_unit_per_pckg              IN NUMBER,
      i_hcfa_disp_units            IN NUMBER,
      i_first_dt_sld_dir_str       IN VARCHAR2,
      i_shelf_life_mon             IN NUMBER,
      i_liability_mon              IN NUMBER,
      i_elig_stat_cd               IN VARCHAR2,
      i_inelig_rsn_id              IN NUMBER,
      i_prod_nm                    IN VARCHAR2,
      i_fda_approval_dt_str        IN VARCHAR2,
      i_new_prod_flg               IN VARCHAR2,
      i_first_dt_sld_str           IN VARCHAR2,
      i_divestr_dt_str             IN VARCHAR2,
      i_fda_reg_nm                 IN VARCHAR2,
      i_final_lot_dt_str           IN VARCHAR2,
      i_promo_stat_cd              IN VARCHAR2,
      i_cosmis_ndc                 IN VARCHAR2,
      i_cosmis_descr               IN VARCHAR2,
      i_pckg_nm                    IN VARCHAR2,
      i_medicare_elig_stat_cd      IN VARCHAR2,
      i_sap_prod_cd                IN VARCHAR2,
      i_sap_company_cd             IN VARCHAR2,
      i_items_per_ndc              IN NUMBER,
      i_volume_per_item            IN NUMBER,
      i_mdcr_exp_trnsmitted_dt_str IN VARCHAR2,
      i_comm_unit_per_pckg         IN NUMBER,
      i_pname_desc                 IN VARCHAR2,
      i_strngtyp_id                IN VARCHAR2,
      i_sizetyp_id                 IN VARCHAR2,
      i_pkgtyp_id                  IN VARCHAR2,
      i_va_drug_catg_cd            IN VARCHAR2,
      i_va_elig_stat_cd            IN VARCHAR2,
      i_phs_elig_stat_cd           IN VARCHAR2,
      i_fdb_case_size              IN NUMBER,
      i_fdb_package_size           IN NUMBER,
      o_cnt                        OUT NUMBER);

   PROCEDURE p_attchm_ref_id
     (i_ndc_lbl           IN VARCHAR2,
      o_attachment_ref_id OUT NUMBER);

   PROCEDURE p_attchm_ref_u
     (i_ndc_lbl           IN VARCHAR2,
      i_attachment_ref_id IN NUMBER,
      o_cnt               OUT NUMBER);

END pkg_ui_dm_prod_sel;
/
CREATE OR REPLACE PACKAGE BODY HCRS.pkg_ui_dm_prod_sel
AS

   cs_src_pkg CONSTANT hcrs.error_log_t.src_cd%TYPE := 'pkg_ui_dm_prod_sel';

   PROCEDURE p_chld_elig_stat_s
     (o_result OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_chld_elig_stat_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_result FOR
         SELECT c.cd,
                c.cd_descr
           FROM hcrs.cd_t c
          WHERE c.cd_typ_cd = 'ES';
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_chld_elig_stat_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_chld_elig_stat_s;

   PROCEDURE p_tv_chld_s
     (i_as_ndc_lbl  IN VARCHAR2,
      i_as_ndc_prod IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_tv_chld_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT p.ndc_lbl,
                p.ndc_prod,
                p.ndc_pckg,
                p.prod_nm,
                p.fda_reg_nm,
                p.elig_stat_cd
           FROM hcrs.prod_mstr_t p
          WHERE p.ndc_lbl = i_as_ndc_lbl
            AND p.ndc_prod = i_as_ndc_prod
          ORDER BY p.ndc_pckg ASC;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_tv_chld_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_tv_chld_s;

   PROCEDURE p_tv_prnt_wo_stat_s
     (i_ndc_lbl_low   IN VARCHAR2 := '',
      i_ndc_lbl_high  IN VARCHAR2 := '',
      i_ndc_prod_low  IN VARCHAR2 := '',
      i_ndc_prod_high IN VARCHAR2 := '',
      i_page_no       IN NUMBER := 1,
      i_page_size     IN NUMBER := 10,
      i_sort_col      IN VARCHAR2 := '',
      i_order_typ     IN VARCHAR2 := '',
      i_debug         IN NUMBER := 0,
      o_return_list   OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_tv_prnt_wo_stat_s
       *       Returns        :
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_page_no   NUMBER := i_page_no;
      v_page_size NUMBER := i_page_size;
      v_dyn_sql   pkg_constants.var_formula_sql_txt%TYPE;
      v_order_by  VARCHAR2(500);
      v_min_row   NUMBER;
      v_max_row   NUMBER;
   BEGIN
      -- If either page number or page size is 0, then change to null so all rows are returned
      IF (NVL(v_page_no,0) = 0 OR
          NVL(v_page_size,0) = 0)
      THEN
         v_page_no   := NULL;
         v_page_size := NULL;
      END IF;
      --Calculate Min and Max rows from the page and page size
      v_min_row := ((v_page_no - 1) * v_page_size) + 1;
      v_max_row := (v_page_no * v_page_size);
      --Determine the Order By column and sort direction(ASC / DESC)
      v_order_by := UPPER(LTRIM(RTRIM(i_sort_col)));
      IF v_order_by IS NULL
      THEN
         -- No column passed, set default order
         -- Default order by not specified
         v_order_by := ' ORDER BY ndc_lbl ASC, ndc_prod ASC ';
      ELSIF UPPER(SUBSTR(LTRIM(RTRIM(i_order_typ)),1,1)) = 'D'
      THEN
         v_order_by := ' ORDER BY ' || i_sort_col || ' DESC ';
      ELSE
         v_order_by := ' ORDER BY ' || i_sort_col || ' ';
      END IF;
      -- Build the dynamic sql
      v_dyn_sql := ' WITH z
   AS(
   --select statement from data window:
   SELECT p.ndc_lbl,
   p.ndc_prod,
   p.prod_fmly_nm ,
   DECODE(p.prod_fmly_nm, NULL, ''Unknown Family Name'', p.prod_fmly_nm)  AS family_name
   FROM hcrs.prod_fmly_t p
   WHERE (p.ndc_lbl BETWEEN NVL(:i_ndc_lbl_low, p.ndc_lbl) AND NVL(:i_ndc_lbl_high, p.ndc_lbl) )
   AND (p.ndc_prod BETWEEN NVL(:i_ndc_prod_low, p.ndc_prod) AND NVL(:i_ndc_prod_high, p.ndc_prod) )
   ),
   y
   AS(
    --add row number and count window functions, min / max rows
    --any additional columns can be added here for use by .net
   SELECT z.*,
       ROW_NUMBER() OVER(' || v_order_by ||
                   ') row_num_,
       COUNT(*) OVER() ttl_row_cnt_,
       :v_min_row min_row_num_,
       :v_max_row max_row_num_
   FROM z
   )
      SELECT y.*
      FROM y
      -- If min/ max are null, return all rows
      WHERE y.row_num_ BETWEEN NVL(y.min_row_num_, 0) AND NVL(y.max_row_num_, y.ttl_row_cnt_)
   ORDER BY y.row_num_';

      IF i_debug = 1
      THEN
         dbms_output.put_line(v_dyn_sql);
      END IF;

      --Open the refcursor
      OPEN o_return_list FOR v_dyn_sql
      --pass bind variables, they must be passed for every instance
      --of a variable in the order they appear in the query
         USING i_ndc_lbl_low, i_ndc_lbl_high, i_ndc_prod_low, i_ndc_prod_high, v_min_row, v_max_row;

   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_tv_prnt_wo_stat_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_tv_prnt_wo_stat_s;

   PROCEDURE p_tv_prnt_with_stat_s
     (i_ndc_lbl_low    IN VARCHAR2 := '',
      i_ndc_lbl_high   IN VARCHAR2 := '',
      i_ndc_prod_low   IN VARCHAR2 := '',
      i_ndc_prod_high  IN VARCHAR2 := '',
      i_elig_stat_low  IN VARCHAR2 := '',
      i_elig_stat_high IN VARCHAR2 := '',
      i_page_no        IN NUMBER := 1,
      i_page_size      IN NUMBER := 10,
      i_sort_col       IN VARCHAR2 := '',
      i_order_typ      IN VARCHAR2 := '',
      i_debug          IN NUMBER := 0,
      o_return_list    OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_tv_prnt_with_stat_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_page_no   NUMBER := i_page_no;
      v_page_size NUMBER := i_page_size;
      v_dyn_sql   pkg_constants.var_formula_sql_txt%TYPE;
      v_order_by  VARCHAR2(500);
      v_min_row   NUMBER;
      v_max_row   NUMBER;
   BEGIN
      -- If either page number or page size is 0, then change to null so all rows are returned
      IF (NVL(v_page_no,0) = 0 OR
          NVL(v_page_size,0) = 0)
      THEN
         v_page_no   := NULL;
         v_page_size := NULL;
      END IF;
      --Calculate Min and Max rows from the page and page size
      v_min_row := ((v_page_no - 1) * v_page_size) + 1;
      v_max_row := (v_page_no * v_page_size);
      --Determine the Order By column and sort direction(ASC / DESC)
      v_order_by := UPPER(LTRIM(RTRIM(i_sort_col)));
      IF v_order_by IS NULL
      THEN
         -- No column passed, set default order
         -- Default order by not specified
         v_order_by := ' ORDER BY ndc_lbl ASC, ndc_prod ASC ';
      ELSIF UPPER(SUBSTR(LTRIM(RTRIM(i_order_typ)),1,1)) = 'D'
      THEN
         v_order_by := ' ORDER BY ' || i_sort_col || ' DESC ';
      ELSE
         v_order_by := ' ORDER BY ' || i_sort_col || ' ';
      END IF;
      -- Build the dynamic sql
      v_dyn_sql := ' WITH z
   AS(
   -- select statement from data window:
   SELECT
   DISTINCT
   v.ndc_lbl,
   v.ndc_prod,
   v.prod_fmly_nm,
   v.family_name
   FROM hcrs.fe_tv_parent_with_stat_v v
   WHERE v.ndc_lbl BETWEEN NVL(:i_ndc_lbl_low,  v.ndc_lbl) AND NVL(:i_ndc_lbl_high, v.ndc_lbl)
   AND v.ndc_prod BETWEEN NVL(:i_ndc_prod_low, v.ndc_prod) AND NVL(:i_ndc_prod_high, v.ndc_prod)
   AND v.elig_stat_cd BETWEEN NVL(:i_elig_stat_low, v.elig_stat_cd) AND NVL(:i_elig_stat_high, v.elig_stat_cd)
   ),
   y
   AS(
   --add row number and count window functions, min / max rows
   -- any additional columns can be added here for use by .net
   SELECT z.*,
       ROW_NUMBER() OVER(' || v_order_by ||
                   ') row_num_,
       COUNT(*) OVER() ttl_row_cnt_,
       :v_min_row min_row_num_,
       :v_max_row max_row_num_
   FROM z
   )
      SELECT y.*
      FROM y
      -- If min/ max are null, return all rows
      WHERE y.row_num_ BETWEEN NVL(y.min_row_num_, 0) AND NVL(y.max_row_num_, y.ttl_row_cnt_)
   ORDER BY y.row_num_';

      IF i_debug = 1
      THEN
         dbms_output.put_line(v_dyn_sql);
      END IF;

      --Open the refcursor
      OPEN o_return_list FOR v_dyn_sql
      --pass bind variables, they must be passed for every instance
      --of a variable in the order they appear in the query
         USING i_ndc_lbl_low, i_ndc_lbl_high, i_ndc_prod_low, i_ndc_prod_high, i_elig_stat_low, i_elig_stat_high, v_min_row, v_max_row;

   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_tv_prnt_with_stat_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_tv_prnt_with_stat_s;

   PROCEDURE p_lbl_attch_chkbox_s
     (i_ndc_lbl IN VARCHAR2,
      o_chk     OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_lbl_attch_chkbox_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      SELECT MAX(DISTINCT DECODE(attachment_ref_id,NULL,0,1)) attachment_ref_id
        INTO o_chk
        FROM hcrs.lbl_t l
       WHERE ndc_lbl = i_ndc_lbl;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_lbl_attch_chkbox_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_lbl_attch_chkbox_s;

   PROCEDURE p_chk_clm_ln_itm
     (i_ndc_lbl            IN VARCHAR2,
      i_item_prod_fmly_ndc IN VARCHAR2,
      i_item_prod_mstr_ndc IN VARCHAR2,
      o_cnt_wo_pkg         OUT NUMBER,
      o_cnt_w_pkg          OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_chk_clm_ln_itm
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN

      IF i_item_prod_mstr_ndc IS NULL
      THEN
         SELECT COUNT(*)
           INTO o_cnt_wo_pkg
           FROM hcrs.reb_clm_ln_itm_t r
          WHERE r.ndc_lbl = i_ndc_lbl
            AND r.item_prod_fmly_ndc = i_item_prod_fmly_ndc;
      ELSE
         SELECT COUNT(*)
           INTO o_cnt_w_pkg
           FROM hcrs.reb_clm_ln_itm_t r
          WHERE r.ndc_lbl = i_ndc_lbl
            AND r.item_prod_fmly_ndc = i_item_prod_fmly_ndc
            AND r.item_prod_mstr_ndc = i_item_prod_mstr_ndc;
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_chk_clm_ln_itm',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_chk_clm_ln_itm;

   PROCEDURE p_chk_prod_trnsmsn
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      o_cnt      OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_chk_prod_trnsmsn
       *       Returns        :
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_cnt     NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO o_cnt
        FROM hcrs.prod_trnsmsn_t r
       WHERE r.ndc_lbl  = i_ndc_lbl
         AND r.ndc_prod = i_ndc_prod;

   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_chk_prod_trnsmsn',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_chk_prod_trnsmsn;

   PROCEDURE p_prod_fmly_d
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      i_ndc_pckg IN VARCHAR2,
      o_cnt      OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_fmly_d
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      IF i_ndc_pckg IS NULL
      THEN
         DELETE FROM hcrs.prod_fmly_t p
          WHERE p.ndc_lbl = i_ndc_lbl
            AND p.ndc_prod = i_ndc_prod;
      ELSE
         DELETE FROM hcrs.prod_mstr_t p
          WHERE p.ndc_lbl = i_ndc_lbl
            AND p.ndc_prod = i_ndc_prod
            AND p.ndc_pckg = i_ndc_pckg;
      END IF;
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_fmly_d',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prod_fmly_d;

   PROCEDURE p_prod_fmly_s
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      o_ret_lst  OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_fmly_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date           Name                 Comment
       * ------------   ------------------   --------------------------------------
       * 1/14/2021      mgedzior             added clotting factor ind column
       **********************************************************************************/
   BEGIN
      OPEN o_ret_lst FOR
         SELECT v.fda_desi_cd,
                v.drug_typ_cd,
                v.fda_thera_cd,
                v.prod_fmly_nm,
                v.mkt_entry_dt,
                v.hcfa_unit_typ_cd,
                v.potency_flg,
                v.baseln1_dt,
                v.baseln2_dt,
                v.strength,
                v.form,
                v.ndc_lbl,
                v.ndc_prod,
                v.purchase_prod_dt,
                v.brand_id,
                v.eff_dt,
                v.end_dt,
                v.drug_catg_cd,
                v.dc_eff_dt,
                v.dc_end_dt,
                v.nonrtl_drug_ind,
                v.nonrtl_route_of_admin,
                v.cod_stat,
                v.fda_application_num,
                v.otc_mono_num,
                v.line_extension_ind,
                v.clotting_factor_ind
           FROM hcrs.fe_prod_fmly_v v
          WHERE v.ndc_lbl = i_ndc_lbl
            AND v.ndc_prod = i_ndc_prod;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_fmly_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prod_fmly_s;

   PROCEDURE p_prod_fmly_i
     (i_fda_desi_cd           IN VARCHAR2,
      i_drug_typ_cd           IN VARCHAR2,
      i_fda_thera_cd          IN VARCHAR2,
      i_prod_fmly_nm          IN VARCHAR2,
      i_mkt_entry_dt_str      IN VARCHAR2,
      i_hcfa_unit_typ_cd      IN VARCHAR2,
      i_potency_flg           IN VARCHAR2,
      i_baseln1_dt_str        IN VARCHAR2,
      i_baseln2_dt_str        IN VARCHAR2,
      i_strength              IN VARCHAR2,
      i_form                  IN VARCHAR2,
      i_ndc_lbl               IN VARCHAR2,
      i_ndc_prod              IN VARCHAR2,
      i_purchase_prod_dt_str  IN VARCHAR2,
      i_nonrtl_drug_ind       IN VARCHAR2,
      i_nonrtl_route_of_admin IN VARCHAR2,
      i_cod_stat              IN VARCHAR2,
      i_fda_application_num   IN VARCHAR2,
      i_otc_mono_num          IN VARCHAR2,
      i_line_extension_ind    IN VARCHAR2,
      i_clotting_factor_ind   IN VARCHAR2,
      o_cnt                   OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_fmly_i
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_recordcount INTEGER;
   BEGIN
      INSERT INTO hcrs.prod_fmly_t
         (fda_desi_cd,
          drug_typ_cd,
          fda_thera_cd,
          prod_fmly_nm,
          mkt_entry_dt,
          hcfa_unit_typ_cd,
          potency_flg,
          baseln1_dt,
          baseln2_dt,
          strength,
          form,
          ndc_lbl,
          ndc_prod,
          purchase_prod_dt,
          nonrtl_drug_ind,
          nonrtl_route_of_admin,
          cod_stat,
          fda_application_num,
          otc_mono_num,
          line_extension_ind,
          clotting_factor_ind)
      VALUES
         (i_fda_desi_cd,
          i_drug_typ_cd,
          i_fda_thera_cd,
          i_prod_fmly_nm,
          TO_DATE(i_mkt_entry_dt_str,'MM/DD/YYYY'),
          i_hcfa_unit_typ_cd,
          i_potency_flg,
          TO_DATE(i_baseln1_dt_str,'MM/DD/YYYY'),
          TO_DATE(i_baseln2_dt_str,'MM/DD/YYYY'),
          i_strength,
          i_form,
          i_ndc_lbl,
          i_ndc_prod,
          TO_DATE(i_purchase_prod_dt_str,'MM/DD/YYYY'),
          i_nonrtl_drug_ind,
          i_nonrtl_route_of_admin,
          i_cod_stat,
          i_fda_application_num,
          i_otc_mono_num,
          i_line_extension_ind,
          i_clotting_factor_ind);
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN dup_val_on_index
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_fmly_i',
                                  i_src_descr   => 'Duplicate values in the insert',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_fmly_i',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prod_fmly_i;

   PROCEDURE p_prod_fmly_u
     (i_fda_desi_cd           IN VARCHAR2,
      i_drug_typ_cd           IN VARCHAR2,
      i_fda_thera_cd          IN VARCHAR2,
      i_prod_fmly_nm          IN VARCHAR2,
      i_mkt_entry_dt_str      IN VARCHAR2,
      i_hcfa_unit_typ_cd      IN VARCHAR2,
      i_potency_flg           IN VARCHAR2,
      i_baseln1_dt_str        IN VARCHAR2,
      i_baseln2_dt_str        IN VARCHAR2,
      i_strength              IN VARCHAR2,
      i_form                  IN VARCHAR2,
      i_ndc_lbl               IN VARCHAR2,
      i_ndc_prod              IN VARCHAR2,
      i_purchase_prod_dt_str  IN VARCHAR2,
      i_nonrtl_drug_ind       IN VARCHAR2,
      i_nonrtl_route_of_admin IN VARCHAR2,
      i_cod_stat              IN VARCHAR2,
      i_fda_application_num   IN VARCHAR2,
      i_otc_mono_num          IN VARCHAR2,
      i_line_extension_ind    IN VARCHAR2,
      i_clotting_factor_ind   IN VARCHAR2,
      o_cnt                   OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_fmly_u
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      rec                hcrs.prod_fmly_t%ROWTYPE;
      v_update_statement pkg_constants.var_formula_sql_txt%TYPE;
   BEGIN
      SELECT *
        INTO rec
        FROM hcrs.prod_fmly_t c
       WHERE c.ndc_lbl = i_ndc_lbl
         AND c.ndc_prod = i_ndc_prod;

      IF rec.ndc_lbl IS NOT NULL AND
         (
         LENGTH(i_fda_desi_cd) > 0           OR
         LENGTH(i_drug_typ_cd) > 0           OR
         LENGTH(i_fda_thera_cd) > 0          OR
         LENGTH(i_prod_fmly_nm) > 0          OR
         LENGTH(i_mkt_entry_dt_str) > 0      OR
         LENGTH(i_hcfa_unit_typ_cd) > 0      OR
         LENGTH(i_potency_flg) > 0           OR
         LENGTH(i_baseln1_dt_str) > 0        OR
         LENGTH(i_baseln2_dt_str) > 0        OR
         LENGTH(i_strength) > 0              OR
         LENGTH(i_form) > 0                  OR
         LENGTH(i_purchase_prod_dt_str) > 0  OR
         LENGTH(i_nonrtl_drug_ind) > 0       OR
         LENGTH(i_nonrtl_route_of_admin) > 0 OR
         LENGTH(i_cod_stat) > 0              OR
         LENGTH(i_fda_application_num) > 0   OR
         LENGTH(i_otc_mono_num) > 0          OR
         LENGTH(i_line_extension_ind) > 0)
      THEN
         v_update_statement := 'UPDATE hcrs.prod_fmly_t c
   SET c.ndc_id = c.ndc_id,';
         IF NVL(i_fda_desi_cd,'-ZZZZZZZ') <> NVL(rec.fda_desi_cd,'-ZZZZZZZ')
            AND (LENGTH(i_fda_desi_cd) > 0 OR LENGTH(rec.fda_desi_cd) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.fda_desi_cd = ''' || i_fda_desi_cd ||
                                  ''',';
         END IF;
         IF NVL(i_drug_typ_cd,'-ZZZZZZZ') <> NVL(rec.drug_typ_cd,'-ZZZZZZZ')
            AND (LENGTH(i_drug_typ_cd) > 0 OR LENGTH(rec.drug_typ_cd) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.drug_typ_cd = ''' || i_drug_typ_cd ||
                                  ''',';
         END IF;
         IF NVL(i_fda_thera_cd,'-ZZZZZZZ') <> NVL(rec.fda_thera_cd,'-ZZZZZZZ')
            AND
            (LENGTH(i_fda_thera_cd) > 0 OR LENGTH(rec.fda_thera_cd) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.fda_thera_cd = ''' || i_fda_thera_cd ||
                                  ''',';
         END IF;
         IF NVL(i_prod_fmly_nm,'-ZZZZZZZ') <> NVL(rec.prod_fmly_nm,'-ZZZZZZZ')
            AND
            (LENGTH(i_prod_fmly_nm) > 0 OR LENGTH(rec.prod_fmly_nm) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.prod_fmly_nm = ''' || i_prod_fmly_nm ||
                                  ''',';
         END IF;
         IF TO_CHAR(NVL(TO_DATE(i_mkt_entry_dt_str,'MM/DD/YYYY'),
                        TO_DATE('01/01/0001','MM/DD/YYYY')),'MM/DD/YYYY') <>
            TO_CHAR(NVL(rec.mkt_entry_dt,TO_DATE('01/01/0001','MM/DD/YYYY')),'MM/DD/YYYY')
            AND
            (LENGTH(i_mkt_entry_dt_str) > 0 OR LENGTH(rec.mkt_entry_dt) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.mkt_entry_dt = ''' ||
                                  TO_DATE(i_mkt_entry_dt_str,'MM/DD/YYYY') || ''',';
         END IF;
         IF NVL(i_hcfa_unit_typ_cd,'-ZZZZZZZ') <> NVL(rec.hcfa_unit_typ_cd,'-ZZZZZZZ')
            AND (LENGTH(i_hcfa_unit_typ_cd) > 0 OR
                 LENGTH(rec.hcfa_unit_typ_cd) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.hcfa_unit_typ_cd = ''' ||
                                  i_hcfa_unit_typ_cd || ''',';
         END IF;
         IF NVL(i_potency_flg,'-ZZZZZZZ') <> NVL(rec.potency_flg,'-ZZZZZZZ')
            AND (LENGTH(i_potency_flg) > 0 OR LENGTH(rec.potency_flg) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.potency_flg = ''' || i_potency_flg ||
                                  ''',';
         END IF;
         IF TO_CHAR(NVL(TO_DATE(i_baseln1_dt_str,'MM/DD/YYYY'),
                        TO_DATE('01/01/0001','MM/DD/YYYY')),'MM/DD/YYYY') <>
            TO_CHAR(NVL(rec.baseln1_dt,TO_DATE('01/01/0001','MM/DD/YYYY')),'MM/DD/YYYY')
            AND
            (LENGTH(i_baseln1_dt_str) > 0 OR LENGTH(rec.baseln1_dt) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.baseln1_dt = ''' ||
                                  TO_DATE(i_baseln1_dt_str,'MM/DD/YYYY') || ''',';
         END IF;
         IF TO_CHAR(NVL(TO_DATE(i_baseln2_dt_str,'MM/DD/YYYY'),
                        TO_DATE('01/01/0001','MM/DD/YYYY')),'MM/DD/YYYY') <>
            TO_CHAR(NVL(rec.baseln2_dt,TO_DATE('01/01/0001','MM/DD/YYYY')),'MM/DD/YYYY')
            AND
            (LENGTH(i_baseln2_dt_str) > 0 OR LENGTH(rec.baseln2_dt) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.baseln2_dt = ''' ||
                                  TO_DATE(i_baseln2_dt_str,'MM/DD/YYYY') || ''',';
         END IF;
         IF NVL(i_strength,'-ZZZZZZZ') <> NVL(rec.strength,'-ZZZZZZZ')
            AND (LENGTH(i_strength) > 0 OR LENGTH(rec.strength) > 0)
         THEN
            v_update_statement := v_update_statement || ' c.strength = ''' ||
                                  i_strength || ''',';
         END IF;
         IF NVL(i_form,'-ZZZZZZZ') <> NVL(rec.form,'-ZZZZZZZ')
            AND (LENGTH(i_form) > 0 OR LENGTH(rec.form) > 0)
         THEN
            v_update_statement := v_update_statement || ' c.form = ''' ||
                                  i_form || ''',';
         END IF;
         IF TO_CHAR(NVL(TO_DATE(i_purchase_prod_dt_str,'MM/DD/YYYY'),
                        TO_DATE('01/01/0001','MM/DD/YYYY')),'MM/DD/YYYY') <>
            TO_CHAR(NVL(rec.purchase_prod_dt,TO_DATE('01/01/0001','MM/DD/YYYY')),'MM/DD/YYYY')
            AND (LENGTH(i_purchase_prod_dt_str) > 0 OR
                 LENGTH(rec.purchase_prod_dt) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.purchase_prod_dt = ''' ||
                                  TO_DATE(i_purchase_prod_dt_str,'MM/DD/YYYY') || ''',';
         END IF;
         IF NVL(i_nonrtl_drug_ind,'-ZZZZZZZ') <> NVL(rec.nonrtl_drug_ind,'-ZZZZZZZ')
            AND (LENGTH(i_nonrtl_drug_ind) > 0 OR
                 LENGTH(rec.nonrtl_drug_ind) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.nonrtl_drug_ind = ''' ||
                                  i_nonrtl_drug_ind || ''',';
         END IF;
         IF NVL(i_nonrtl_route_of_admin,'-ZZZZZZZ') <> NVL(rec.nonrtl_route_of_admin,'-ZZZZZZZ')
            AND (LENGTH(i_nonrtl_route_of_admin) > 0 OR
                 LENGTH(rec.nonrtl_route_of_admin) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.nonrtl_route_of_admin = ''' ||
                                  i_nonrtl_route_of_admin || ''',';
         END IF;
         IF NVL(i_cod_stat,'-ZZZZZZZ') <> NVL(rec.cod_stat,'-ZZZZZZZ')
            AND (LENGTH(i_cod_stat) > 0 OR LENGTH(rec.cod_stat) > 0)
         THEN
            v_update_statement := v_update_statement || ' c.cod_stat = ''' ||
                                  i_cod_stat || ''',';
         END IF;
         IF NVL(i_fda_application_num,'-ZZZZZZZ') <> NVL(rec.fda_application_num,'-ZZZZZZZ')
            AND (LENGTH(i_fda_application_num) > 0 OR
                 LENGTH(rec.fda_application_num) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.fda_application_num = ''' ||
                                  i_fda_application_num || ''',';
         END IF;
         IF NVL(i_otc_mono_num,'-ZZZZZZZ') <> NVL(rec.otc_mono_num,'-ZZZZZZZ')
            AND
            (LENGTH(i_otc_mono_num) > 0 OR LENGTH(rec.otc_mono_num) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.otc_mono_num = ''' || i_otc_mono_num ||
                                  ''',';
         END IF;
         IF NVL(i_line_extension_ind,'-ZZZZZZZ') <> NVL(rec.line_extension_ind,'-ZZZZZZZ')
            AND (LENGTH(i_line_extension_ind) > 0 OR
                 LENGTH(rec.line_extension_ind) > 0)
         THEN
            v_update_statement := v_update_statement ||
                                  ' c.line_extension_ind = ''' ||
                                  i_line_extension_ind || ''',';
         END IF;
         v_update_statement := SUBSTR(v_update_statement,1,LENGTH(v_update_statement) - 1) ||
            ', clotting_factor_ind = nvl('''||i_clotting_factor_ind||''', ''N'')' ||
            ' WHERE c.ndc_lbl = :i_ndc_lbl AND c.ndc_prod = :i_ndc_prod ';
         dbms_output.put_line('v_update_statement  : ' ||v_update_statement);

         EXECUTE IMMEDIATE v_update_statement USING i_ndc_lbl, i_ndc_prod;
      ELSE
         hcrs.pkg_ui_dm_prod_sel.p_prod_fmly_i(i_fda_desi_cd,
                                               i_drug_typ_cd,
                                               i_fda_thera_cd,
                                               i_prod_fmly_nm,
                                               i_mkt_entry_dt_str,
                                               i_hcfa_unit_typ_cd,
                                               i_potency_flg,
                                               i_baseln1_dt_str,
                                               i_baseln2_dt_str,
                                               i_strength,
                                               i_form,
                                               i_ndc_lbl,
                                               i_ndc_prod,
                                               i_purchase_prod_dt_str,
                                               i_nonrtl_drug_ind,
                                               i_nonrtl_route_of_admin,
                                               i_cod_stat,
                                               i_fda_application_num,
                                               i_otc_mono_num,
                                               i_line_extension_ind,
                                               i_clotting_factor_ind,
                                               o_cnt);
      END IF;
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN no_data_found
      THEN
         NULL;
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_fmly_u',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prod_fmly_u;

   PROCEDURE p_prod_fmly_cod_stat_s
     (o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_dddw_prod_fmly_cod_stat_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT t.cod_stat,
                t.cod_stat_desc,
                t.cod_stat_desc_long
           FROM hcrs.prod_fmly_cod_stat_t t
          ORDER BY t.cod_stat_desc;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_fmly_cod_stat_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prod_fmly_cod_stat_s;

   PROCEDURE p_cd_typ_s
     (o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_cd_typ_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT c.cd,
                c.cd_typ_cd,
                c.cd_descr
           FROM hcrs.cd_t c
          WHERE c.cd_typ_cd IN ('DE',
                                'DR',
                                'TH',
                                'HC')
          ORDER BY c.cd;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_cd_typ_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_cd_typ_s;

   PROCEDURE p_chld_fmly_drug_catg_s
     (o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_chld_fmly_drg_catg_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT d.drug_catg_cd
           FROM hcrs.drug_catg_t d
          ORDER BY d.drug_catg_cd;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_chld_fmly_drug_catg_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_chld_fmly_drug_catg_s;

   PROCEDURE p_chld_form_s
     (o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_chld_form_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT f.form
           FROM hcrs.drug_form_t f
          ORDER BY f.form ASC;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_chld_form_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_chld_form_s;

   PROCEDURE p_nonrtl_route_admin_s
     (o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_dddw_nonrtl_route_of_admin_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT t.nonrtl_roa_cd,
                t.nonrtl_roa_desc
           FROM hcrs.nonrtl_route_of_admin_t t
          ORDER BY t.nonrtl_roa_desc ASC;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_nonrtl_route_admin_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_nonrtl_route_admin_s;

   -- Link part
   PROCEDURE p_auth_gen_xref_d
     (i_auth_gen_ndc1 IN VARCHAR2,
      i_auth_gen_ndc2 IN VARCHAR2,
      i_auth_gen_ndc3 IN VARCHAR2)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_auth_gen_xref_d
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      DELETE FROM hcrs.auth_gen_ndc_xref_t x
       WHERE x.auth_gen_ndc1 = i_auth_gen_ndc1
         AND x.auth_gen_ndc2 = i_auth_gen_ndc2
         AND x.auth_gen_ndc3 = i_auth_gen_ndc3;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_auth_gen_xref_d',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_auth_gen_xref_d;

   PROCEDURE p_auth_gen_xref_i
     (i_auth_gen_ndc1  IN VARCHAR2,
      i_auth_gen_ndc2  IN VARCHAR2,
      i_auth_gen_ndc3  IN VARCHAR2,
      i_ndc_lbl        IN VARCHAR2,
      i_ndc_prod       IN VARCHAR2,
      i_ndc_pckg       IN VARCHAR2,
      i_auth_gen_desc  IN VARCHAR2,
      i_auth_gen_co_nm IN VARCHAR2,
      i_strength       IN VARCHAR2,
      i_unit_type      IN VARCHAR2,
      i_unit_per_pckg  IN NUMBER,
      o_record         OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_auth_gen_xref_i
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      INSERT INTO hcrs.auth_gen_ndc_xref_t
         (auth_gen_ndc1,
          auth_gen_ndc2,
          auth_gen_ndc3,
          ndc_lbl,
          ndc_prod,
          ndc_pckg,
          auth_gen_desc,
          auth_gen_co_nm,
          strength,
          unit_type,
          unit_per_pckg)
      VALUES
         (i_auth_gen_ndc1,
          i_auth_gen_ndc2,
          i_auth_gen_ndc3,
          i_ndc_lbl,
          i_ndc_prod,
          i_ndc_pckg,
          i_auth_gen_desc,
          i_auth_gen_co_nm,
          i_strength,
          i_unit_type,
          i_unit_per_pckg);

      OPEN o_record FOR
         SELECT x.create_dt,
                x.mod_dt,
                x.mod_by
           FROM hcrs.auth_gen_ndc_xref_t x
          WHERE x.auth_gen_ndc1 = i_auth_gen_ndc1
            AND x.auth_gen_ndc2 = i_auth_gen_ndc2
            AND x.auth_gen_ndc3 = i_auth_gen_ndc3;
   EXCEPTION
      WHEN dup_val_on_index
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_auth_gen_xref_i',
                                  i_src_descr   => 'Duplicate values in the insert',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_auth_gen_xref_i',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_auth_gen_xref_i;

   PROCEDURE p_auth_gen_xref_u
     (i_auth_gen_ndc1  IN VARCHAR2,
      i_auth_gen_ndc2  IN VARCHAR2,
      i_auth_gen_ndc3  IN VARCHAR2,
      i_ndc_lbl        IN VARCHAR2,
      i_ndc_prod       IN VARCHAR2,
      i_ndc_pckg       IN VARCHAR2,
      i_auth_gen_desc  IN VARCHAR2,
      i_auth_gen_co_nm IN VARCHAR2,
      i_strength       IN VARCHAR2,
      i_unit_type      IN VARCHAR2,
      i_unit_per_pckg  IN NUMBER,
      o_record         OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_auth_gen_xref_u
       *       Returns        :
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      UPDATE hcrs.auth_gen_ndc_xref_t x
         SET x.ndc_lbl        = i_ndc_lbl,
             x.ndc_prod       = i_ndc_prod,
             x.ndc_pckg       = i_ndc_pckg,
             x.auth_gen_desc  = i_auth_gen_desc,
             x.auth_gen_co_nm = i_auth_gen_co_nm,
             x.strength       = i_strength,
             x.unit_type      = i_unit_type,
             x.unit_per_pckg  = i_unit_per_pckg
       WHERE x.auth_gen_ndc1 = i_auth_gen_ndc1
         AND x.auth_gen_ndc2 = i_auth_gen_ndc2
         AND x.auth_gen_ndc3 = i_auth_gen_ndc3;

      OPEN o_record FOR
         SELECT x.create_dt,
                x.mod_dt,
                x.mod_by
           FROM hcrs.auth_gen_ndc_xref_t x
          WHERE x.auth_gen_ndc1 = i_auth_gen_ndc1
            AND x.auth_gen_ndc2 = i_auth_gen_ndc2
            AND x.auth_gen_ndc3 = i_auth_gen_ndc3;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_auth_gen_xref_u',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_auth_gen_xref_u;

   -- Link End
   PROCEDURE p_prod_fmly_ppaca_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      i_page_no     IN NUMBER := 1,
      i_page_size   IN NUMBER := 10,
      i_sort_col    IN VARCHAR2,
      i_order_typ   IN VARCHAR2,
      i_debug       IN NUMBER := 0,
      o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_fmly_ppaca_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
     v_page_no   NUMBER := i_page_no;
      v_page_size NUMBER := i_page_size;
      v_dyn_sql   pkg_constants.var_formula_sql_txt%TYPE;
      v_order_by  VARCHAR2(500);
      v_min_row   NUMBER;
      v_max_row   NUMBER;
   BEGIN
      -- If either page number or page size is 0, then change to null so all rows are returned
      IF (NVL(v_page_no,0) = 0 OR
         NVL(v_page_size,0) = 0)
      THEN
         v_page_no   := NULL;
         v_page_size := NULL;
      END IF;
      --Calculate Min and Max rows from the page and page size
      v_min_row := ((v_page_no - 1) * v_page_size) + 1;
      v_max_row := (v_page_no * v_page_size);
      --Determine the Order By column and sort direction(ASC / DESC)
      v_order_by := UPPER(LTRIM(RTRIM(i_sort_col)));
      IF v_order_by IS NULL
      THEN
         -- No column passed, set := order
         -- := order by not specified
         v_order_by := ' ORDER BY ndc_lbl ASC ';
      ELSIF UPPER(SUBSTR(LTRIM(RTRIM(i_order_typ)),1,1)) = 'D'
      THEN
         v_order_by := ' ORDER BY ' || i_sort_col || ' DESC ';
      ELSE
         v_order_by := ' ORDER BY ' || i_sort_col || ' ';
      END IF;
      -- Build the dynamic sql
      v_dyn_sql := ' WITH z
                  AS(
                  -- select statement from data window:
                  SELECT
                  v.ndc_lbl,
                  v.ndc_prod,
                  v.ndc9_prod_fmly_nm,
                  TO_CHAR(v.tim_per_bgn_dt, ''MM/DD/YYYY HH24:MI:SS'') tim_per_bgn_dt,
                  TO_CHAR(v.tim_per_bgn_dt, ''MM/DD/YYYY HH24:MI:SS'') tim_per_bgn_dt_new,
                  TO_CHAR(v.tim_per_end_dt, ''MM/DD/YYYY HH24:MI:SS'') tim_per_end_dt,
                  TO_CHAR(v.eff_bgn_dt, ''MM/DD/YYYY HH24:MI:SS'') eff_bgn_dt,
                  TO_CHAR(v.eff_end_dt, ''MM/DD/YYYY HH24:MI:SS'') eff_end_dt,
                  v.ppaca_rtl_ind,
                  v.create_dt,
                  v.mod_dt,
                  v.mod_by
                  FROM hcrs.fe_prod_fmly_ppaca_v v
                  WHERE v.ndc_lbl = :i_ndc_lbl
                  AND v.ndc_prod = :i_ndc_prod
                  ),
                  y
                  AS(
                  --add row number and count window functions, min / max rows
                  --any additional columns can be added here for use by .net
                  SELECT z.*,
                  ROW_NUMBER() OVER(' || v_order_by ||
                   ') row_num_,
                  COUNT(*) OVER() ttl_row_cnt_,
                  :v_min_row min_row_num_,
                  :v_max_row max_row_num_
                  FROM z
                  )
                  SELECT y.*
                  FROM y
                  --If min/ max are null, return all rows
                  WHERE y.row_num_ BETWEEN NVL(y.min_row_num_, 0) AND NVL(y.max_row_num_, y.ttl_row_cnt_)
                  ORDER BY y.row_num_';

      IF i_debug = 1
      THEN
         dbms_output.put_line(v_dyn_sql);
      END IF;

      --Open the refcursor
      OPEN o_return_list FOR v_dyn_sql
      --pass bind variables, they must be passed for every instance
      --of a variable in the order they appear in the query
         USING i_ndc_lbl, i_ndc_prod, v_min_row, v_max_row;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_fmly_ppaca_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prod_fmly_ppaca_s;

   PROCEDURE p_prod_fmly_ppaca_u
     (i_ndc_lbl                IN VARCHAR2,
      i_ndc_prod               IN VARCHAR2,
      i_tim_per_bgn_dt_str     IN VARCHAR2,
      i_tim_per_bgn_dt_new_str IN VARCHAR2,
      i_tim_per_end_dt_str     IN VARCHAR2,
      i_eff_bgn_dt_str         IN VARCHAR2,
      i_eff_end_dt_str         IN VARCHAR2,
      i_ppaca_rtl_ind          IN VARCHAR2,
      o_cnt                    OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_fmly_ppaca_u
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      UPDATE hcrs.prod_fmly_ppaca_t fp
         SET fp.tim_per_end_dt = TO_DATE(i_tim_per_end_dt_str,'MM/DD/YYYY HH24:MI:SS'),
             fp.tim_per_bgn_dt = TO_DATE(i_tim_per_bgn_dt_new_str,'MM/DD/YYYY HH24:MI:SS'),
             fp.ppaca_rtl_ind  = i_ppaca_rtl_ind
       WHERE fp.ndc_lbl = i_ndc_lbl
         AND fp.ndc_prod = i_ndc_prod
         AND TO_DATE(TO_CHAR(fp.tim_per_bgn_dt,'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS') =
             TO_DATE(i_tim_per_bgn_dt_str,'MM/DD/YYYY HH24:MI:SS')
         AND TO_DATE(TO_CHAR(fp.eff_bgn_dt,'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS') =
             TO_DATE(i_eff_bgn_dt_str,'MM/DD/YYYY HH24:MI:SS');

      o_cnt := SQL%ROWCOUNT;

   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_fmly_ppaca_u',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prod_fmly_ppaca_u;

   PROCEDURE p_prod_fmly_ppaca_d
     (i_ndc_lbl            IN VARCHAR2,
      i_ndc_prod           IN VARCHAR2,
      i_tim_per_bgn_dt_str IN VARCHAR2,
      i_eff_bgn_dt_str     IN VARCHAR2,
      o_cnt                OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_fmly_ppaca_d
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      UPDATE hcrs.prod_fmly_ppaca_t fp
         SET fp.eff_end_dt = SYSDATE
       WHERE fp.ndc_lbl = i_ndc_lbl
         AND fp.ndc_prod = i_ndc_prod
         AND TO_DATE(TO_CHAR(fp.tim_per_bgn_dt,'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS') =
             TO_DATE(i_tim_per_bgn_dt_str,'MM/DD/YYYY HH24:MI:SS')
         AND TO_DATE(TO_CHAR(fp.eff_bgn_dt,'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS') =
             TO_DATE(i_eff_bgn_dt_str,'MM/DD/YYYY HH24:MI:SS');
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_fmly_ppaca_d',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prod_fmly_ppaca_d;

   PROCEDURE p_prod_fmly_ppaca_i
     (i_ndc_lbl            IN VARCHAR2,
      i_ndc_prod           IN VARCHAR2,
      i_tim_per_bgn_dt_str IN VARCHAR2,
      i_tim_per_end_dt_str IN VARCHAR2,
      i_eff_bgn_dt_str     IN VARCHAR2,
      i_eff_end_dt_str     IN VARCHAR2,
      i_ppaca_rtl_ind      IN VARCHAR2,
      o_cnt                OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_fmly_ppaca_i
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      INSERT INTO hcrs.prod_fmly_ppaca_t
         (ndc_lbl,
          ndc_prod,
          tim_per_bgn_dt,
          tim_per_end_dt,
          eff_bgn_dt,
          eff_end_dt,
          ppaca_rtl_ind)
      VALUES
         (i_ndc_lbl,
          i_ndc_prod,
          TO_DATE(i_tim_per_bgn_dt_str,'MM/DD/YYYY HH24:MI:SS'),
          TO_DATE(i_tim_per_end_dt_str,'MM/DD/YYYY HH24:MI:SS'),
          TO_DATE(i_eff_bgn_dt_str,'MM/DD/YYYY HH24:MI:SS'),
          TO_DATE(i_eff_end_dt_str,'MM/DD/YYYY HH24:MI:SS'),
          i_ppaca_rtl_ind);

      o_cnt := SQL%ROWCOUNT;

   EXCEPTION
      WHEN dup_val_on_index
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_fmly_ppaca_i',
                                  i_src_descr   => 'Duplicate values in the insert',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_fmly_ppaca_i',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prod_fmly_ppaca_i;

   PROCEDURE p_drg_catg_prod_fmly_hist_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_drg_catg_prod_fmly_hist_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT t.ndc_lbl,
                t.ndc_prod,
                t.drug_catg_cd,
                t.eff_dt,
                t.end_dt
           FROM hcrs.prod_fmly_drug_catg_t t
          WHERE t.ndc_lbl = i_ndc_lbl
            AND t.ndc_prod = i_ndc_prod
          ORDER BY t.eff_dt;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_drg_catg_prod_fmly_hist_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_drg_catg_prod_fmly_hist_s;

   PROCEDURE p_prod_fmly_drug_catg_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_fmly_drug_catg_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT t.ndc_lbl,
                t.ndc_prod,
                t.drug_catg_cd,
                t.eff_dt,
                t.end_dt
           FROM hcrs.prod_fmly_drug_catg_t t
          WHERE t.ndc_lbl = i_ndc_lbl
            AND t.ndc_prod = i_ndc_prod
            AND SYSDATE BETWEEN eff_dt AND end_dt;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_fmly_drug_catg_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prod_fmly_drug_catg_s;

   PROCEDURE p_brnd_prod_fmly_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_brnd_prod_fmly_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT b.brand_id,
                b.ndc_lbl,
                b.ndc_prod,
                b.eff_dt,
                b.end_dt
           FROM hcrs.brand_prod_fmly_t b
          WHERE (SYSDATE BETWEEN b.eff_dt AND b.end_dt)
            AND (b.ndc_lbl = i_ndc_lbl)
            AND (b.ndc_prod = i_ndc_prod);

   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_brnd_prod_fmly_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_brnd_prod_fmly_s;

   PROCEDURE p_brnd_prod_fmly_i
     (i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_brand_id   IN VARCHAR2,
      i_eff_dt_str IN VARCHAR2,
      i_end_dt_str IN VARCHAR2,
      o_cnt        OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_brnd_prod_fmly_i
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      INSERT INTO hcrs.brand_prod_fmly_t
         (ndc_lbl,
          ndc_prod,
          brand_id,
          eff_dt,
          end_dt)
      VALUES
         (i_ndc_lbl,
          i_ndc_prod,
          i_brand_id,
          TO_DATE(i_eff_dt_str,'MM/DD/YYYY'),
          TO_DATE(i_end_dt_str,'MM/DD/YYYY'));
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN dup_val_on_index
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_brnd_prod_fmly_i',
                                  i_src_descr   => 'Duplicate values in the insert',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_brnd_prod_fmly_i',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_brnd_prod_fmly_i;

   PROCEDURE p_brnd_prod_fmly_u
     (i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_brand_id   IN VARCHAR2,
      i_eff_dt_str IN VARCHAR2,
      i_end_dt_str IN VARCHAR2,
      o_cnt        OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_brnd_prod_fmly_u
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      UPDATE hcrs.brand_prod_fmly_t u
         SET u.brand_id = i_brand_id,
             u.end_dt   = TO_DATE(i_end_dt_str,'MM/DD/YYYY')
       WHERE u.ndc_lbl = i_ndc_lbl
         AND u.ndc_prod = i_ndc_prod
         AND TO_DATE(TO_CHAR(u.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') =
             TO_DATE(i_eff_dt_str,'MM/DD/YYYY');
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_brnd_prod_fmly_u',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_brnd_prod_fmly_u;

   PROCEDURE p_brnd_prod_fmly_d
     (i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_eff_dt_str IN VARCHAR2,
      i_brand_id   IN NUMBER,
      o_cnt        OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_brnd_prod_fmly_d
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      DELETE FROM hcrs.brand_prod_fmly_t u
       WHERE u.ndc_lbl = i_ndc_lbl
         AND u.ndc_prod = i_ndc_prod
         AND TO_DATE(TO_CHAR(u.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') =
             TO_DATE(i_eff_dt_str,'MM/DD/YYYY')
         AND u.brand_id = i_brand_id;
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_brnd_prod_fmly_d',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_brnd_prod_fmly_d;

   PROCEDURE p_drg_catg_prod_fmly_by_cd_d
     (i_ndc_lbl      IN VARCHAR2,
      i_ndc_prod     IN VARCHAR2,
      i_eff_dt_str   IN VARCHAR2,
      i_drug_catg_cd IN VARCHAR2,
      o_cnt          OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_drg_catg_prod_fmly_by_cd_d
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      DELETE FROM hcrs.prod_fmly_drug_catg_t u
       WHERE u.ndc_lbl = i_ndc_lbl
         AND u.ndc_prod = i_ndc_prod
         AND TO_DATE(TO_CHAR(u.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') =
             TO_DATE(i_eff_dt_str,'MM/DD/YYYY')
         AND u.drug_catg_cd = i_drug_catg_cd;
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_drg_catg_prod_fmly_by_cd_d',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_drg_catg_prod_fmly_by_cd_d;

   PROCEDURE p_drg_catg_prod_fmly_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_drg_catg_prod_fmly_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT v.ndc_lbl,
                v.ndc_prod,
                v.drug_catg_cd,
                v.eff_dt,
                v.end_dt
           FROM hcrs.fe_drug_catg_prod_fmly_v v
          WHERE v.ndc_lbl = i_ndc_lbl
            AND v.ndc_prod = i_ndc_prod;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_drg_catg_prod_fmly_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_drg_catg_prod_fmly_s;

   PROCEDURE p_drg_catg_prod_fmly_i
     (i_ndc_lbl      IN VARCHAR2,
      i_ndc_prod     IN VARCHAR2,
      i_eff_dt_str   IN VARCHAR2,
      i_drug_catg_cd IN VARCHAR2,
      i_end_dt_str   IN VARCHAR2,
      o_cnt          OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_drg_catg_prod_fmly_i
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      INSERT INTO hcrs.prod_fmly_drug_catg_t
         (ndc_lbl,
          ndc_prod,
          eff_dt,
          drug_catg_cd,
          end_dt)
      VALUES
         (i_ndc_lbl,
          i_ndc_prod,
          TO_DATE(i_eff_dt_str,'MM/DD/YYYY'),
          i_drug_catg_cd,
          TO_DATE(i_end_dt_str,'MM/DD/YYYY'));
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN dup_val_on_index
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_drg_catg_prod_fmly_i',
                                  i_src_descr   => 'Duplicate values in the insert',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_drg_catg_prod_fmly_i',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_drg_catg_prod_fmly_i;

   PROCEDURE p_get_first_sld_mrkt_entry_dt
     (i_ndc_lbl           IN VARCHAR2,
      i_ndc_prod          IN VARCHAR2,
      o_first_dt_sld_str  OUT VARCHAR2,
      o_mrkt_entry_dt_str OUT VARCHAR2)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_get_first_sld_mrkt_entry_dt
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      SELECT TO_CHAR(MIN(pm.first_dt_sld),'MM/DD/YYYY'),
             TO_CHAR(MIN(pm.mrkt_entry_dt),'MM/DD/YYYY')
        INTO o_first_dt_sld_str,
             o_mrkt_entry_dt_str
        FROM hcrs.prod_mstr_t pm
       WHERE pm.ndc_lbl = i_ndc_lbl
         AND pm.ndc_prod = i_ndc_prod;
   EXCEPTION
      WHEN no_data_found
      THEN
         NULL;
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_get_first_sld_mrkt_entry_dt',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_get_first_sld_mrkt_entry_dt;

   PROCEDURE p_sap_co_s
     (o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_sap_co_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT s.sap_co_cd,
                s.sap_co_descr,
                s.rbt_pymt_ind
           FROM hcrs.sap_co_t s
          WHERE s.rbt_pymt_ind = 'Y';
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_sap_co_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_sap_co_s;

   PROCEDURE p_chld_promo_stat_s
     (o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_chld_promo_stat_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT p.promo_stat_descr,
                p.promo_stat_cd
           FROM hcrs.promo_stat_t p;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_chld_promo_stat_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_chld_promo_stat_s;

   PROCEDURE p_chld_elig_rsn_s
     (o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_chld_elig_rsn_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT i.inelig_rsn_id,
                i.inelig_rsn_shrt_descr,
                i.inelig_rsn_lg_descr
           FROM hcrs.inelig_rsn_t i;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_chld_elig_rsn_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_chld_elig_rsn_s;

   PROCEDURE p_chld_va_drg_catg_cd_s
     (o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_chld_va_drg_catg_cd_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT c.cd,
                c.cd_descr
           FROM hcrs.cd_t c
          WHERE c.cd_typ_cd = 'VC';
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_chld_va_drg_catg_cd_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_chld_va_drg_catg_cd_s;

   PROCEDURE p_assoc_pgm_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      i_ndc_pckg    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_assoc_pgms_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT p.pgm_id,
                p.ndc_lbl,
                p.ndc_prod,
                p.ndc_pckg,
                p.eff_dt,
                p.end_dt
           FROM hcrs.prod_mstr_pgm_t p
          WHERE p.ndc_lbl = i_ndc_lbl
            AND p.ndc_prod = i_ndc_prod
            AND p.ndc_pckg = i_ndc_pckg
            AND SYSDATE BETWEEN p.eff_dt AND p.end_dt;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_assoc_pgm_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_assoc_pgm_s;

   PROCEDURE p_assoc_pgm_i
     (i_pgm_id     IN NUMBER,
      i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_ndc_pckg   IN VARCHAR2,
      i_eff_dt_str IN VARCHAR2,
      i_end_dt_str IN VARCHAR2,
      o_cnt        OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_assoc_pgm_i
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      INSERT INTO hcrs.prod_mstr_pgm_t
         (pgm_id,
          ndc_lbl,
          ndc_prod,
          ndc_pckg,
          eff_dt,
          end_dt)
      VALUES
         (i_pgm_id,
          i_ndc_lbl,
          i_ndc_prod,
          i_ndc_pckg,
          TO_DATE(i_eff_dt_str,'MM/DD/YYYY'),
          TO_DATE(i_end_dt_str,'MM/DD/YYYY'));
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'p_assoc_pgm_i',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_assoc_pgm_i;

   PROCEDURE p_assoc_pgm_multi_i
     (i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_ndc_pckg   IN VARCHAR2,
      i_start_dt_str IN VARCHAR2,
      i_end_dt_str IN VARCHAR2,
      o_cnt        OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_assoc_pgm_multi_i
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       * 3/20/2018     Mari         CHG0032771 --Creaation Association with First sale
       *                  of Qurater for instead of Program Effective  Date
       * 3/15/2019    Saravanan         CHG0099894 -- Change p_assoc_pgm_i parameter to
       *                                eff_dt_str instead of i_start_dt_str
       * 7/15/2019    Saravanan         CHG0122886 -- The effective date for Program-Product Association
       *                                should be the greater of the First Sale Date aligned to quarter
       *                                boundary or Program Effective Date aligned to quarter boundary
       **********************************************************************************/
      v_cnt   NUMBER := 0;
      v_total NUMBER := 0;
   BEGIN
      FOR p IN (SELECT TO_CHAR(TRUNC(p.eff_dt, 'Q'),'MM/DD/YYYY') eff_dt_str,
                       p.pgm_id,
                       p.pgm_cd
                  FROM hcrs.pgm_t p
                 WHERE SYSDATE BETWEEN p.eff_dt AND p.end_dt)
      LOOP
         hcrs.pkg_ui_dm_prod_sel.p_assoc_pgm_i(p.pgm_id,
                                               i_ndc_lbl,
                                               i_ndc_prod,
                                               i_ndc_pckg,
                                               CASE
                                                 WHEN (TO_DATE(i_start_dt_str,'MM/DD/YYYY')
                                                    < TO_DATE(p.eff_dt_str,'MM/DD/YYYY')) THEN
                                                   p.eff_dt_str
                                                 ELSE
                                                   i_start_dt_str
                                                 END,--p.eff_dt_str,
                                               i_end_dt_str,
                                               v_cnt);
         v_total := v_total + v_cnt;
      END LOOP;
      o_cnt := v_total;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_assoc_pgm_multi_i',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error. i_ndc_lbl=[' ||
                                                   i_ndc_lbl ||
                                                   '], i_ndc_prod=[' ||
                                                   i_ndc_prod ||
                                                   '], i_ndc_pckg=[' ||
                                                   i_ndc_pckg ||
                                                   '], i_end_dt_str=[' ||
                                                   i_end_dt_str || '].');
   END p_assoc_pgm_multi_i;

   PROCEDURE p_assoc_pgm_d
     (i_pgm_id     IN NUMBER,
      i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_ndc_pckg   IN VARCHAR2,
      i_eff_dt_str IN VARCHAR2,
      o_cnt        OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_assoc_pgm_d
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      DELETE FROM hcrs.prod_mstr_pgm_t p
       WHERE p.pgm_id = i_pgm_id
         AND p.ndc_lbl = i_ndc_lbl
         AND p.ndc_prod = i_ndc_prod
         AND p.ndc_pckg = i_ndc_pckg
         AND TO_DATE(TO_CHAR(p.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') =
             TO_DATE(i_eff_dt_str,'MM/DD/YYYY');
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_assoc_pgm_d',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error. i_pgm_id=[' ||
                                                   i_pgm_id ||
                                                   '], i_ndc_lbl=[' ||
                                                   i_ndc_lbl ||
                                                   '], i_ndc_prod=[' ||
                                                   i_ndc_prod ||
                                                   '], i_ndc_pckg=[' ||
                                                   i_ndc_pckg ||
                                                   '], i_eff_dt_str=[' ||
                                                   i_eff_dt_str || '].');
   END p_assoc_pgm_d;

   PROCEDURE p_assoc_pgm_multi_d
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      i_ndc_pckg IN VARCHAR2,
      o_cnt      OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_assoc_pgm_multi_d
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      DELETE FROM hcrs.prod_mstr_pgm_t p
       WHERE p.ndc_lbl = i_ndc_lbl
         AND p.ndc_prod = i_ndc_prod
         AND p.ndc_pckg = i_ndc_pckg;
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_assoc_pgm_multi_d',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error. i_ndc_lbl=[' ||
                                                   i_ndc_lbl ||
                                                   '], i_ndc_prod=[' ||
                                                   i_ndc_prod ||
                                                   '], i_ndc_pckg=[' ||
                                                   i_ndc_pckg || '].');
   END p_assoc_pgm_multi_d;

   PROCEDURE p_prod_pckg_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      i_ndc_pckg    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_pckg_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT f.ndc_lbl,
                f.ndc_prod,
                f.ndc_pckg,
                f.prod_nm,
                f.unit_per_pckg,
                f.hcfa_disp_units,
                f.shelf_life_mon,
                f.liablty_mon,
                f.fda_approval_dt,
                f.first_dt_sld,
                f.final_lot_dt,
                f.divestr_dt,
                f.elig_stat_cd,
                f.prod_fmly_nm,
                f.co_id,
                f.inelig_rsn_id,
                f.new_prod_flg,
                f.fda_reg_nm,
                f.promo_stat_cd,
                f.cosmis_ndc,
                f.pckg_nm,
                f.first_dt_sld_dir,
                f.cosmis_descr,
                f.fda_thera_cd,
                f.fda_desi_cd,
                f.drug_typ_cd,
                f.hcfa_unit_typ_cd,
                f.eff_dt,
                f.end_dt,
                f.termination_date,
                f.liability_end_date,
                f.medicare_elig_stat_cd,
                f.comm_unit_per_pckg,
                f.cars_sap_prod_cd,
                f.pname_desc,
                f.strngtyp_id,
                f.sizetyp_id,
                f.pkgtyp_id,
                f.formtyp_id,
                f.medicare_exp_trnsmitted_dt,
                f.volume_per_item,
                f.items_per_ndc,
                f.sap_prod_cd,
                f.sap_company_cd,
                f.va_elig_stat_cd,
                f.va_drug_catg_cd,
                f.phs_elig_stat_cd,
                f.fdb_case_size,
                f.fdb_package_size
           FROM hcrs.fe_prod_pckg_v f
          WHERE f.ndc_lbl = i_ndc_lbl
            AND f.ndc_prod = i_ndc_prod
            AND f.ndc_pckg = i_ndc_pckg;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_pckg_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prod_pckg_s;

   PROCEDURE p_prog_prod_assoc_s
     (o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prog_prod_assoc_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      --Open the refcursor
      OPEN o_return_list FOR
         SELECT d.dummy,
                TO_CHAR(p.eff_dt,'MM/DD/YYYY') eff_dt,
                p.pgm_id,
                p.pgm_cd
           FROM dual       d,
                hcrs.pgm_t p
          WHERE SYSDATE BETWEEN p.eff_dt AND p.end_dt
          ORDER BY p.pgm_cd ASC;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prog_prod_assoc_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prog_prod_assoc_s;

   FUNCTION f_get_cnt_prod_mstr
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      i_ndc_pckg IN VARCHAR2)
      RETURN NUMBER
   AS
      /***********************************************************************************
       *       Function Name  :    f_get_cnt_prod_mstr
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      cnt_prod_mstr NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO cnt_prod_mstr
        FROM hcrs.prod_mstr_t p
       WHERE p.ndc_lbl = i_ndc_lbl
         AND p.ndc_prod = i_ndc_prod
         AND p.ndc_pckg = i_ndc_pckg;
      RETURN cnt_prod_mstr;
   EXCEPTION
      WHEN no_data_found
      THEN
         NULL;
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'f_get_cnt_prod_mstr',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END f_get_cnt_prod_mstr;

   FUNCTION f_get_cnt_prod_mstr_pgm
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      i_ndc_pckg IN VARCHAR2)
      RETURN NUMBER
   AS
      /***********************************************************************************
       *       Function Name  :    f_get_cnt_prod_mstr_pgm
       *       Date Created   :    3/20/2018
       *       Author         :    Mari
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      cnt_prod_mstr_pgm NUMBER;
   BEGIN
      SELECT COUNT(*)
        INTO cnt_prod_mstr_pgm
        FROM hcrs.prod_mstr_pgm_t p
       WHERE p.ndc_lbl = i_ndc_lbl
         AND p.ndc_prod = i_ndc_prod
         AND p.ndc_pckg = i_ndc_pckg;
      RETURN cnt_prod_mstr_pgm;
   EXCEPTION
      WHEN no_data_found
      THEN
         NULL;
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'f_get_cnt_prod_mstr_pgm',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END f_get_cnt_prod_mstr_pgm;

   FUNCTION f_get_last_dy_prd_str
     (i_end_dt_str IN VARCHAR2)
     RETURN VARCHAR2
   AS
      /***********************************************************************************
       *       Function Name  :    f_get_last_dy_prd_str
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_last_dy_prd_str VARCHAR2(50);
   BEGIN
      SELECT TO_CHAR(last_day_period,'MM/DD/YYYY')
        INTO v_last_dy_prd_str
        FROM hcrs.period_t p
       WHERE p.first_day_period <= TO_DATE(i_end_dt_str,'MM/DD/YYYY')
         AND p.last_day_period >= TO_DATE(i_end_dt_str,'MM/DD/YYYY');
      RETURN v_last_dy_prd_str;
   EXCEPTION
      WHEN no_data_found
      THEN
         NULL;
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'f_get_last_dy_prd_str',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END f_get_last_dy_prd_str;

   FUNCTION f_get_last_drug_catg_cd
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2)
      RETURN hcrs.prod_fmly_drug_catg_t.drug_catg_cd%TYPE
   AS
      /***********************************************************************************
       *       Function Name  :    f_get_last_drug_catg_cd
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_last_drug_catg_cd hcrs.prod_fmly_drug_catg_t.drug_catg_cd%TYPE;
   BEGIN
      SELECT dc.drug_catg_cd
        INTO v_last_drug_catg_cd
        FROM hcrs.prod_fmly_drug_catg_t dc
       WHERE dc.ndc_lbl = i_ndc_lbl
         AND dc.ndc_prod = i_ndc_prod
         AND dc.eff_dt = (SELECT MIN(c.eff_dt)
                            FROM hcrs.prod_fmly_drug_catg_t c
                           WHERE c.ndc_lbl = dc.ndc_lbl
                             AND c.ndc_prod = dc.ndc_prod
                             AND TRUNC(SYSDATE) <= c.end_dt);
      RETURN v_last_drug_catg_cd;
   EXCEPTION
      WHEN no_data_found
      THEN
         NULL;
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'f_get_last_drug_catg_cd',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END f_get_last_drug_catg_cd;

   FUNCTION f_get_last_brnd_id
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2)
      RETURN hcrs.brand_prod_fmly_t.brand_id%TYPE
   AS
      /***********************************************************************************
       *       Function Name  :    f_get_last_brnd_id
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_last_brnd_id hcrs.brand_prod_fmly_t.brand_id%TYPE;
   BEGIN
      SELECT bpf.brand_id
        INTO v_last_brnd_id
        FROM hcrs.brand_prod_fmly_t bpf
       WHERE bpf.ndc_lbl = i_ndc_lbl
         AND bpf.ndc_prod = i_ndc_prod
         AND bpf.eff_dt = (SELECT MIN(m.eff_dt)
                             FROM hcrs.brand_prod_fmly_t m
                            WHERE m.ndc_lbl = bpf.ndc_lbl
                              AND m.ndc_prod = bpf.ndc_prod
                              AND TRUNC(SYSDATE) <= m.end_dt);
      RETURN v_last_brnd_id;
   EXCEPTION
      WHEN no_data_found
      THEN
         NULL;
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'f_get_last_brnd_id',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END f_get_last_brnd_id;

   FUNCTION f_get_last_co_id
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2,
      i_ndc_pckg IN VARCHAR2)
      RETURN hcrs.co_prod_mstr_t.co_id%TYPE
   AS
      /***********************************************************************************
       *       Function Name  :    f_get_last_co_id
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_last_co_id hcrs.co_prod_mstr_t.co_id%TYPE;
   BEGIN
      SELECT pm.co_id
        INTO v_last_co_id
        FROM hcrs.co_prod_mstr_t pm
       WHERE pm.ndc_lbl = i_ndc_lbl
         AND pm.ndc_prod = i_ndc_prod
         AND pm.ndc_pckg = i_ndc_pckg
         AND pm.eff_dt = (SELECT MIN(dc.eff_dt)
                            FROM hcrs.prod_fmly_drug_catg_t dc
                           WHERE dc.ndc_lbl = pm.ndc_lbl
                             AND dc.ndc_prod = pm.ndc_prod
                                -- AND dc.ndc_pckg = pm.ndc_pckg
                             AND TRUNC(SYSDATE) <= dc.end_dt);
      RETURN v_last_co_id;
   EXCEPTION
      WHEN no_data_found
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'f_get_last_co_id',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END f_get_last_co_id;

   FUNCTION f_get_max_reb_clm_prd_id
     (i_ndc_lbl   IN VARCHAR2,
      i_ndc_prod  IN VARCHAR2,
      i_ndc_pckg  IN VARCHAR2,
      i_period_id IN NUMBER)
      RETURN NUMBER
   AS
      /***********************************************************************************
       *       Function Name  :    f_get_max_reb_clm_prd_id
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_max_reb_clm_prd_id NUMBER;
   BEGIN
      SELECT MAX(vc.period_id)
        INTO v_max_reb_clm_prd_id
        FROM hcrs.valid_claim_t vc
       WHERE vc.ndc_lbl = i_ndc_lbl
         AND vc.ndc_prod = i_ndc_prod
         AND vc.ndc_pckg = i_ndc_pckg
         AND vc.period_id > i_period_id;
      RETURN v_max_reb_clm_prd_id;
   EXCEPTION
      WHEN no_data_found
      THEN
         NULL;
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'f_get_max_reb_clm_prd_id',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END f_get_max_reb_clm_prd_id;

   PROCEDURE p_vld_clm_pgm_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      i_ndc_pckg    IN VARCHAR2,
      i_period_id   IN NUMBER,
      o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_vld_clm_pgm_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      --Open the refcursor
      OPEN o_return_list FOR
         SELECT p.pgm_nm
           FROM hcrs.valid_claim_t c,
                hcrs.pgm_t         p
          WHERE c.pgm_id = p.pgm_id
            AND c.ndc_lbl = i_ndc_lbl
            AND c.ndc_prod = i_ndc_prod
            AND c.ndc_pckg = i_ndc_pckg
            AND c.period_id = i_period_id
          ORDER BY p.pgm_nm;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_vld_clm_pgm_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_vld_clm_pgm_s;

   FUNCTION f_get_qtr_name
     (i_period_id IN NUMBER)
     RETURN VARCHAR2
   AS
      /***********************************************************************************
       *       Function Name  :    f_get_qtr_name
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_qtr_name VARCHAR2(50);
   BEGIN
      SELECT 'Q' || p.qtr || '/' || p.yr
        INTO v_qtr_name
        FROM hcrs.period_t p
       WHERE p.period_id = i_period_id;
      RETURN v_qtr_name;
   EXCEPTION
      WHEN no_data_found
      THEN
         NULL;
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'f_get_qtr_name',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END f_get_qtr_name;

   FUNCTION f_get_mkt_entry_dt
     (i_ndc_lbl  IN VARCHAR2,
      i_ndc_prod IN VARCHAR2)
      RETURN VARCHAR2
   AS
      /***********************************************************************************
       *       Function Name  :    f_get_mkt_entry_dt
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_mkt_entry_dt_str VARCHAR2(50);
   BEGIN
      SELECT TO_CHAR(f.mkt_entry_dt,'MM/DD/YYYY')
        INTO v_mkt_entry_dt_str
        FROM hcrs.prod_fmly_t f
       WHERE f.ndc_lbl = i_ndc_lbl
         AND f.ndc_prod = i_ndc_prod;
      RETURN v_mkt_entry_dt_str;
   EXCEPTION
      WHEN no_data_found
      THEN
         NULL;
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'f_get_mkt_entry_dt',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END f_get_mkt_entry_dt;

   FUNCTION f_get_liability_dt_prd_id
     (i_liability_dt_str IN VARCHAR2)
      RETURN NUMBER
   AS
      /***********************************************************************************
       *       Function Name  :    f_get_liability_dt_prd_id
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_period_id NUMBER;
   BEGIN
      SELECT p.period_id
        INTO v_period_id
        FROM hcrs.period_t p
       WHERE TRUNC(p.first_day_period) <=
             TO_DATE(i_liability_dt_str,'MM/DD/YYYY')
         AND TRUNC(p.last_day_period) >=
             TO_DATE(i_liability_dt_str,'MM/DD/YYYY');
      RETURN v_period_id;
   EXCEPTION
      WHEN no_data_found
      THEN
         RETURN v_period_id;
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => 'f_get_liability_dt_prd_id',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END f_get_liability_dt_prd_id;

   FUNCTION f_prod_mstr_pgm_t_end_liab
     (i_ndc_lbl         IN VARCHAR2,
      i_ndc_prod        IN VARCHAR2,
      i_ndc_pckg        IN VARCHAR2,
      i_end_liab_dt_str IN VARCHAR2)
      RETURN NUMBER
   AS
      /***********************************************************************************
       *       Function Name  :    f_prod_mstr_pgm_t_end_liab
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
      v_count_indef_liab NUMBER;
      v_count_divest     NUMBER;
   BEGIN
      --Find indefinite liability flag
      SELECT COUNT(*)
        INTO v_count_indef_liab
        FROM hcrs.pgm_t      a,
             hcrs.pgm_catg_t b
       WHERE a.pgm_catg_cd = b.pgm_catg_cd
         AND b.indef_liablty_flg = 'Y'
         AND EXISTS (SELECT 1
                FROM hcrs.prod_mstr_pgm_t pm
               WHERE pm.ndc_lbl = i_ndc_lbl
                 AND pm.ndc_prod = i_ndc_prod
                 AND pm.ndc_pckg = i_ndc_pckg
                 AND pm.pgm_id = a.pgm_id);
      --Find if product is divested
      SELECT COUNT(*)
        INTO v_count_divest
        FROM hcrs.prod_mstr_t p
       WHERE p.ndc_lbl = i_ndc_lbl
         AND p.ndc_prod = i_ndc_prod
         AND p.ndc_pckg = i_ndc_pckg
         AND p.divestr_dt IS NOT NULL
         AND p.liablty_mon > 0;
      IF v_count_indef_liab = 0
      THEN
         UPDATE hcrs.prod_pgm_fee_t p
            SET p.end_dt = TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY')
          WHERE p.ndc_lbl = i_ndc_lbl
            AND p.ndc_prod = i_ndc_prod
            AND p.ndc_pckg = i_ndc_pckg
            AND EXISTS
          (SELECT 1
                   FROM hcrs.prod_mstr_pgm_t pm
                  WHERE pm.ndc_lbl = i_ndc_lbl
                    AND pm.ndc_prod = i_ndc_prod
                    AND pm.ndc_pckg = i_ndc_pckg
                    AND pm.pgm_id = p.pgm_id)
            AND p.eff_dt =
                (SELECT MAX(b.eff_dt)
                   FROM hcrs.prod_pgm_fee_t b
                  WHERE b.ndc_lbl = i_ndc_lbl
                    AND b.ndc_prod = i_ndc_prod
                    AND b.ndc_pckg = i_ndc_pckg
                    AND EXISTS (SELECT 1
                           FROM hcrs.prod_mstr_pgm_t pm
                          WHERE pm.ndc_lbl = i_ndc_lbl
                            AND pm.ndc_prod = i_ndc_prod
                            AND pm.ndc_pckg = i_ndc_pckg
                            AND pm.pgm_id = b.pgm_id)
                    AND TO_DATE(TO_CHAR(b.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') <=
                        TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY')
                    AND TO_DATE(TO_CHAR(b.end_dt,'MM/DD/YYYY'),'MM/DD/YYYY') >=
                        TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY'))
            AND p.end_dt =
                (SELECT MAX(c.end_dt)
                   FROM hcrs.prod_pgm_fee_t c
                  WHERE c.ndc_lbl = i_ndc_lbl
                    AND c.ndc_prod = i_ndc_prod
                    AND c.ndc_pckg = i_ndc_pckg
                    AND EXISTS (SELECT 1
                           FROM hcrs.prod_mstr_pgm_t pm
                          WHERE pm.ndc_lbl = i_ndc_lbl
                            AND pm.ndc_prod = i_ndc_prod
                            AND pm.ndc_pckg = i_ndc_pckg
                            AND pm.pgm_id = c.pgm_id)
                    AND TO_DATE(TO_CHAR(c.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') <=
                        TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY')
                    AND TO_DATE(TO_CHAR(c.end_dt,'MM/DD/YYYY'),'MM/DD/YYYY') >=
                        TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY'));
         --tolerance records
         UPDATE hcrs.prod_mstr_pgm_tol_t t
            SET t.end_dt = TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY')
          WHERE t.ndc_lbl = i_ndc_lbl
            AND t.ndc_prod = i_ndc_prod
            AND t.ndc_pckg = i_ndc_pckg
            AND EXISTS
          (SELECT 1
                   FROM hcrs.prod_mstr_pgm_t pm
                  WHERE pm.ndc_lbl = i_ndc_lbl
                    AND pm.ndc_prod = i_ndc_prod
                    AND pm.ndc_pckg = i_ndc_pckg
                    AND pm.pgm_id = t.pgm_id)
            AND t.eff_dt =
                (SELECT MAX(b.eff_dt)
                   FROM hcrs.prod_mstr_pgm_tol_t b
                  WHERE b.ndc_lbl = i_ndc_lbl
                    AND b.ndc_prod = i_ndc_prod
                    AND b.ndc_pckg = i_ndc_pckg
                    AND EXISTS (SELECT 1
                           FROM hcrs.prod_mstr_pgm_t pm
                          WHERE pm.ndc_lbl = i_ndc_lbl
                            AND pm.ndc_prod = i_ndc_prod
                            AND pm.ndc_pckg = i_ndc_pckg
                            AND pm.pgm_id = b.pgm_id)
                    AND TO_DATE(TO_CHAR(b.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') <=
                        TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY')
                    AND TO_DATE(TO_CHAR(b.end_dt,'MM/DD/YYYY'),'MM/DD/YYYY') >=
                        TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY'))
            AND t.end_dt =
                (SELECT MAX(end_dt)
                   FROM hcrs.prod_mstr_pgm_tol_t c
                  WHERE c.ndc_lbl = i_ndc_lbl
                    AND c.ndc_prod = i_ndc_prod
                    AND c.ndc_pckg = i_ndc_pckg
                    AND EXISTS (SELECT 1
                           FROM hcrs.prod_mstr_pgm_t pm
                          WHERE pm.ndc_lbl = i_ndc_lbl
                            AND pm.ndc_prod = i_ndc_prod
                            AND pm.ndc_pckg = i_ndc_pckg
                            AND pm.pgm_id = c.pgm_id)
                    AND TO_DATE(TO_CHAR(c.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') <=
                        TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY')
                    AND TO_DATE(TO_CHAR(c.end_dt,'MM/DD/YYYY'),'MM/DD/YYYY') >=
                        TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY'));
      ELSE
         IF v_count_divest > 0
         THEN
            UPDATE hcrs.prod_pgm_fee_t f
               SET f.end_dt = i_end_liab_dt_str
             WHERE f.ndc_lbl = i_ndc_lbl
               AND f.ndc_prod = i_ndc_prod
               AND f.ndc_pckg = i_ndc_pckg
               AND EXISTS
             (SELECT 1
                      FROM hcrs.prod_mstr_pgm_t pm
                     WHERE pm.ndc_lbl = i_ndc_lbl
                       AND pm.ndc_prod = i_ndc_prod
                       AND pm.ndc_pckg = i_ndc_pckg
                       AND pm.pgm_id = f.pgm_id)
               AND f.eff_dt =
                   (SELECT MAX(b.eff_dt)
                      FROM hcrs.prod_pgm_fee_t b
                     WHERE b.ndc_lbl = i_ndc_lbl
                       AND b.ndc_prod = i_ndc_prod
                       AND b.ndc_pckg = i_ndc_pckg
                       AND EXISTS (SELECT 1
                              FROM hcrs.prod_mstr_pgm_t pm
                             WHERE pm.ndc_lbl = i_ndc_lbl
                               AND pm.ndc_prod = i_ndc_prod
                               AND pm.ndc_pckg = i_ndc_pckg
                               AND pm.pgm_id = b.pgm_id)
                       AND TO_DATE(TO_CHAR(b.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') <=
                           TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY')
                       AND TO_DATE(TO_CHAR(b.end_dt,'MM/DD/YYYY'),'MM/DD/YYYY') >=
                           TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY'))
               AND f.end_dt =
                   (SELECT MAX(end_dt)
                      FROM hcrs.prod_mstr_pgm_tol_t c
                     WHERE c.ndc_lbl = i_ndc_lbl
                       AND c.ndc_prod = i_ndc_prod
                       AND c.ndc_pckg = i_ndc_pckg
                       AND EXISTS (SELECT 1
                              FROM hcrs.prod_mstr_pgm_t pm
                             WHERE pm.ndc_lbl = i_ndc_lbl
                               AND pm.ndc_prod = i_ndc_prod
                               AND pm.ndc_pckg = i_ndc_pckg
                               AND pm.pgm_id = c.pgm_id)
                       AND TO_DATE(TO_CHAR(c.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') <=
                           TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY')
                       AND TO_DATE(TO_CHAR(c.end_dt,'MM/DD/YYYY'),'MM/DD/YYYY') >=
                           TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY'));
            --tolerance records
            UPDATE hcrs.prod_mstr_pgm_tol_t t
               SET t.end_dt = TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY')
             WHERE t.ndc_lbl = i_ndc_lbl
               AND t.ndc_prod = i_ndc_prod
               AND t.ndc_pckg = i_ndc_pckg
               AND EXISTS
             (SELECT 1
                      FROM hcrs.prod_mstr_pgm_t pm
                     WHERE pm.ndc_lbl = i_ndc_lbl
                       AND pm.ndc_prod = i_ndc_prod
                       AND pm.ndc_pckg = i_ndc_pckg
                       AND pm.pgm_id = t.pgm_id)
               AND t.eff_dt =
                   (SELECT MAX(b.eff_dt)
                      FROM hcrs.prod_mstr_pgm_tol_t b
                     WHERE b.ndc_lbl = i_ndc_lbl
                       AND b.ndc_prod = i_ndc_prod
                       AND b.ndc_pckg = i_ndc_pckg
                       AND EXISTS (SELECT 1
                              FROM hcrs.prod_mstr_pgm_t pm
                             WHERE pm.ndc_lbl = i_ndc_lbl
                               AND pm.ndc_prod = i_ndc_prod
                               AND pm.ndc_pckg = i_ndc_pckg
                               AND pm.pgm_id = b.pgm_id)
                       AND TO_DATE(TO_CHAR(b.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') <=
                           TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY')
                       AND TO_DATE(TO_CHAR(b.end_dt,'MM/DD/YYYY'),'MM/DD/YYYY') >=
                           TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY'))
               AND t.end_dt =
                   (SELECT MAX(end_dt)
                      FROM hcrs.prod_mstr_pgm_tol_t c
                     WHERE c.ndc_lbl = i_ndc_lbl
                       AND c.ndc_prod = i_ndc_prod
                       AND c.ndc_pckg = i_ndc_pckg
                       AND EXISTS (SELECT 1
                              FROM hcrs.prod_mstr_pgm_t pm
                             WHERE pm.ndc_lbl = i_ndc_lbl
                               AND pm.ndc_prod = i_ndc_prod
                               AND pm.ndc_pckg = i_ndc_pckg
                               AND pm.pgm_id = c.pgm_id)
                       AND TO_DATE(TO_CHAR(c.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') <=
                           TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY')
                       AND TO_DATE(TO_CHAR(c.end_dt,'MM/DD/YYYY'),'MM/DD/YYYY') >=
                           TO_DATE(i_end_liab_dt_str,'MM/DD/YYYY'));
         END IF;
      END IF;
      RETURN(1);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN(-1);
         pkg_utils.p_raise_errors(i_src_cd      => 'f_prod_mstr_pgm_t_end_liab',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
         raise_application_error(-20010,
                                 'UPDATE FAILED !');
   END f_prod_mstr_pgm_t_end_liab;

   PROCEDURE p_tol_fee_d
     (i_ndc_lbl               IN VARCHAR2,
      i_ndc_prod              IN VARCHAR2,
      i_ndc_pckg              IN VARCHAR2,
      i_end_dt_str            IN VARCHAR2,
      o_cnt_prod_mstr_pgm     OUT NUMBER,
      o_cnt_prod_pgm_fee      OUT NUMBER,
      o_cnt_prod_mstr_pgm_tol OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_tol_fee_d
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      IF i_end_dt_str IS NOT NULL
      THEN
         --Delete the program product associations that are after the new liability end date
         DELETE FROM hcrs.prod_mstr_pgm_t p
          WHERE p.ndc_lbl = i_ndc_lbl
            AND p.ndc_prod = i_ndc_prod
            AND p.ndc_pckg = i_ndc_pckg
            AND TO_DATE(TO_CHAR(p.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') >
                TO_DATE(i_end_dt_str,'MM/DD/YYYY');
         o_cnt_prod_mstr_pgm := SQL%ROWCOUNT;
         --Delete the supplementary fees that are after the new liability end date
         DELETE FROM hcrs.prod_pgm_fee_t p
          WHERE p.ndc_lbl = i_ndc_lbl
            AND p.ndc_prod = i_ndc_prod
            AND p.ndc_pckg = i_ndc_pckg
            AND TO_DATE(TO_CHAR(p.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') >
                TO_DATE(i_end_dt_str,'MM/DD/YYYY');
         o_cnt_prod_pgm_fee := SQL%ROWCOUNT;
         --Delete the tolerances that are after the new liability end date
         DELETE FROM hcrs.prod_mstr_pgm_tol_t p
          WHERE p.ndc_lbl = i_ndc_lbl
            AND p.ndc_prod = i_ndc_prod
            AND p.ndc_pckg = i_ndc_pckg
            AND TO_DATE(TO_CHAR(p.eff_dt,'MM/DD/YYYY'),'MM/DD/YYYY') >
                TO_DATE(i_end_dt_str,'MM/DD/YYYY');
         o_cnt_prod_mstr_pgm_tol := SQL%ROWCOUNT;
      ELSE
         o_cnt_prod_mstr_pgm     := 0;
         o_cnt_prod_pgm_fee      := 0;
         o_cnt_prod_mstr_pgm_tol := 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg ||
                                                   '.p_tol_fee_d',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error. i_ndc_lbl=[' ||
                                                   i_ndc_lbl ||
                                                   '], i_ndc_prod=[' ||
                                                   i_ndc_prod ||
                                                   '], i_ndc_pckg=[' ||
                                                   i_ndc_pckg ||
                                                   '], i_end_dt_str=[' ||
                                                   i_end_dt_str || '].');
   END p_tol_fee_d;

   PROCEDURE p_prod_mstr_pgm_id_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      i_ndc_pckg    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_mstr_pgm_id_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      --Open the refcursor
      OPEN o_return_list FOR
         SELECT DISTINCT a.pgm_id
           FROM hcrs.prod_mstr_pgm_t a
          WHERE a.ndc_lbl = i_ndc_lbl
            AND a.ndc_prod = i_ndc_prod
            AND a.ndc_pckg = i_ndc_pckg;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_prod_mstr_pgm_id_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_prod_mstr_pgm_id_s;

   PROCEDURE p_co_prod_mstr_s
     (i_ndc_lbl     IN VARCHAR2,
      i_ndc_prod    IN VARCHAR2,
      i_ndc_pckg    IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_co_prod_mstr_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      OPEN o_return_list FOR
         SELECT c.co_id,
                c.ndc_lbl,
                c.ndc_prod,
                c.ndc_pckg,
                c.eff_dt,
                c.end_dt
           FROM hcrs.co_prod_mstr_t c
          WHERE c.ndc_lbl = i_ndc_lbl
            AND c.ndc_prod = i_ndc_prod
            AND c.ndc_pckg = i_ndc_pckg
            AND SYSDATE BETWEEN c.eff_dt AND c.end_dt;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_co_prod_mstr_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error. i_ndc_lbl=[' ||
                                                   i_ndc_lbl ||
                                                   '], i_ndc_prod=[' ||
                                                   i_ndc_prod ||
                                                   '], i_ndc_pckg=[' ||
                                                   i_ndc_pckg || '].');
   END p_co_prod_mstr_s;

   PROCEDURE p_co_prod_mstr_i
     (i_co_id      IN NUMBER,
      i_ndc_lbl    IN VARCHAR2,
      i_ndc_prod   IN VARCHAR2,
      i_ndc_pckg   IN VARCHAR2,
      i_eff_dt_str IN VARCHAR2,
      i_end_dt_str IN VARCHAR2,
      o_cnt        OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_co_prod_mstr_i
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      INSERT INTO hcrs.co_prod_mstr_t
         (co_id,
          ndc_lbl,
          ndc_prod,
          ndc_pckg,
          eff_dt,
          end_dt)
      VALUES
         (i_co_id,
          i_ndc_lbl,
          i_ndc_prod,
          i_ndc_pckg,
          TO_DATE(i_eff_dt_str,'MM/DD/YYYY'),
          TO_DATE(i_end_dt_str,'MM/DD/YYYY'));
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN dup_val_on_index
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg ||
                                                   '.p_co_prod_mstr_i',
                                  i_src_descr   => 'Duplicate values in the insert',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg ||
                                                   '.p_co_prod_mstr_i',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error. i_co_id=[' ||
                                                   i_co_id ||
                                                   '], i_ndc_lbl=[' ||
                                                   i_ndc_lbl ||
                                                   '], i_ndc_prod=[' ||
                                                   i_ndc_prod ||
                                                   '], i_ndc_pckg=[' ||
                                                   i_ndc_pckg ||
                                                   '], i_eff_dt_str=[' ||
                                                   i_eff_dt_str ||
                                                   '], i_end_dt_str=[' ||
                                                   i_end_dt_str || '].');
   END p_co_prod_mstr_i;

   PROCEDURE p_prod_pckg_i
     (i_ndc_lbl                    IN VARCHAR2,
      i_ndc_prod                   IN VARCHAR2,
      i_ndc_pckg                   IN VARCHAR2,
      i_unit_per_pckg              IN NUMBER,
      i_hcfa_disp_units            IN NUMBER,
      i_first_dt_sld_dir_str       IN VARCHAR2,
      i_shelf_life_mon             IN NUMBER,
      i_elig_stat_cd               IN VARCHAR2,
      i_inelig_rsn_id              IN NUMBER,
      i_prod_nm                    IN VARCHAR2,
      i_fda_approval_dt_str        IN VARCHAR2,
      i_new_prod_flg               IN VARCHAR2,
      i_first_dt_sld_str           IN VARCHAR2,
      i_divestr_dt_str             IN VARCHAR2,
      i_fda_reg_nm                 IN VARCHAR2,
      i_final_lot_dt_str           IN VARCHAR2,
      i_promo_stat_cd              IN VARCHAR2,
      i_cosmis_ndc                 IN VARCHAR2,
      i_cosmis_descr               IN VARCHAR2,
      i_pckg_nm                    IN VARCHAR2,
      i_medicare_elig_stat_cd      IN VARCHAR2,
      i_sap_prod_cd                IN VARCHAR2,
      i_items_per_ndc              IN NUMBER,
      i_volume_per_item            IN NUMBER,
      i_mdcr_exp_trnsmitted_dt_str IN VARCHAR2,
      i_comm_unit_per_pckg         IN NUMBER,
      i_pname_desc                 IN VARCHAR2,
      i_strngtyp_id                IN VARCHAR2,
      i_sizetyp_id                 IN VARCHAR2,
      i_pkgtyp_id                  IN VARCHAR2,
      i_fdb_case_size              IN NUMBER,
      i_fdb_package_size           IN NUMBER,
      o_cnt                        OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_pckg_i
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      INSERT INTO hcrs.prod_mstr_t
         (ndc_lbl,
          ndc_prod,
          ndc_pckg,
          unit_per_pckg,
          hcfa_disp_units,
          first_dt_sld_dir,
          shelf_life_mon,
          elig_stat_cd,
          inelig_rsn_id,
          prod_nm,
          fda_approval_dt,
          new_prod_flg,
          first_dt_sld,
          divestr_dt,
          fda_reg_nm,
          final_lot_dt,
          promo_stat_cd,
          cosmis_ndc,
          cosmis_descr,
          pckg_nm,
          medicare_elig_stat_cd,
          sap_prod_cd,
          items_per_ndc,
          volume_per_item,
          medicare_exp_trnsmitted_dt,
          comm_unit_per_pckg,
          pname_desc,
          strngtyp_id,
          sizetyp_id,
          pkgtyp_id,
          fdb_case_size,
          fdb_package_size)
      VALUES
         (i_ndc_lbl,
          i_ndc_prod,
          i_ndc_pckg,
          i_unit_per_pckg,
          i_hcfa_disp_units,
          TO_DATE(i_first_dt_sld_dir_str,'MM/DD/YYYY'),
          i_shelf_life_mon,
          i_elig_stat_cd,
          i_inelig_rsn_id,
          i_prod_nm,
          TO_DATE(i_fda_approval_dt_str,'MM/DD/YYYY'),
          i_new_prod_flg,
          TO_DATE(i_first_dt_sld_str,'MM/DD/YYYY'),
          TO_DATE(i_divestr_dt_str,'MM/DD/YYYY'),
          i_fda_reg_nm,
          TO_DATE(i_final_lot_dt_str,'MM/DD/YYYY'),
          i_promo_stat_cd,
          i_cosmis_ndc,
          i_cosmis_descr,
          i_pckg_nm,
          i_medicare_elig_stat_cd,
          i_sap_prod_cd,
          i_items_per_ndc,
          i_volume_per_item,
          TO_DATE(i_mdcr_exp_trnsmitted_dt_str,'MM/DD/YYYY'),
          i_comm_unit_per_pckg,
          i_pname_desc,
          i_strngtyp_id,
          i_sizetyp_id,
          i_pkgtyp_id,
          i_fdb_case_size,
          i_fdb_package_size);
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN dup_val_on_index
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg ||
                                                   '.p_prod_pckg_i',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error. i_ndc_lbl=[' ||
                                                   i_ndc_lbl ||
                                                   '], i_ndc_prod=[' ||
                                                   i_ndc_prod ||
                                                   '], i_ndc_pckg=[' ||
                                                   i_ndc_pckg ||
                                                   '], i_unit_per_pckg=[' ||
                                                   i_unit_per_pckg ||
                                                   '], i_hcfa_disp_units=[' ||
                                                   i_hcfa_disp_units ||
                                                   '], i_first_dt_sld_dir_str=[' ||
                                                   i_first_dt_sld_dir_str ||
                                                   '], i_shelf_life_mon=[' ||
                                                   i_shelf_life_mon ||
                                                   '],  i_elig_stat_cd=[' ||
                                                   i_elig_stat_cd ||
                                                   '], i_inelig_rsn_id=[' ||
                                                   i_inelig_rsn_id ||
                                                   '], i_prod_nm=[' ||
                                                   i_prod_nm ||
                                                   '], i_fda_approval_dt_str=[' ||
                                                   i_fda_approval_dt_str ||
                                                   '], i_new_prod_flg=[' ||
                                                   i_new_prod_flg ||
                                                   '], i_first_dt_sld_str=[' ||
                                                   i_first_dt_sld_str ||
                                                   '], i_divestr_dt_str=[' ||
                                                   i_divestr_dt_str ||
                                                   '], i_fda_reg_nm=[' ||
                                                   i_fda_reg_nm ||
                                                   '], i_final_lot_dt_str=[' ||
                                                   i_final_lot_dt_str ||
                                                   '], i_promo_stat_cd=[' ||
                                                   i_promo_stat_cd ||
                                                   '],  i_cosmis_ndc=[' ||
                                                   i_cosmis_ndc ||
                                                   '], i_cosmis_descr=[' ||
                                                   i_cosmis_descr ||
                                                   '], i_pckg_nm=[' ||
                                                   i_pckg_nm ||
                                                   '], i_medicare_elig_stat_cd=[' ||
                                                   i_medicare_elig_stat_cd ||
                                                   '], i_sap_prod_cd=[' ||
                                                   i_sap_prod_cd ||
                                                   '], i_items_per_ndc=[' ||
                                                   i_items_per_ndc ||
                                                   '], i_volume_per_item=[' ||
                                                   i_volume_per_item ||
                                                   '], i_mdcr_exp_trnsmitted_dt_str=[' ||
                                                   i_mdcr_exp_trnsmitted_dt_str ||
                                                   '],  i_comm_unit_per_pckg=[' ||
                                                   i_comm_unit_per_pckg ||
                                                   '], i_pname_desc=[' ||
                                                   i_pname_desc ||
                                                   '], i_strngtyp_id=[' ||
                                                   i_strngtyp_id ||
                                                   '], i_sizetyp_id=[' ||
                                                   i_sizetyp_id ||
                                                   '], i_pkgtyp_id=[' ||
                                                   i_pkgtyp_id || '].');
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg ||
                                                   '.p_prod_pckg_i',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error. i_ndc_lbl=[' ||
                                                   i_ndc_lbl ||
                                                   '], i_ndc_prod=[' ||
                                                   i_ndc_prod ||
                                                   '], i_ndc_pckg=[' ||
                                                   i_ndc_pckg ||
                                                   '], i_unit_per_pckg=[' ||
                                                   i_unit_per_pckg ||
                                                   '], i_hcfa_disp_units=[' ||
                                                   i_hcfa_disp_units ||
                                                   '], i_first_dt_sld_dir_str=[' ||
                                                   i_first_dt_sld_dir_str ||
                                                   '], i_shelf_life_mon=[' ||
                                                   i_shelf_life_mon ||
                                                   '],  i_elig_stat_cd=[' ||
                                                   i_elig_stat_cd ||
                                                   '], i_inelig_rsn_id=[' ||
                                                   i_inelig_rsn_id ||
                                                   '], i_prod_nm=[' ||
                                                   i_prod_nm ||
                                                   '], i_fda_approval_dt_str=[' ||
                                                   i_fda_approval_dt_str ||
                                                   '], i_new_prod_flg=[' ||
                                                   i_new_prod_flg ||
                                                   '], i_first_dt_sld_str=[' ||
                                                   i_first_dt_sld_str ||
                                                   '], i_divestr_dt_str=[' ||
                                                   i_divestr_dt_str ||
                                                   '], i_fda_reg_nm=[' ||
                                                   i_fda_reg_nm ||
                                                   '], i_final_lot_dt_str=[' ||
                                                   i_final_lot_dt_str ||
                                                   '], i_promo_stat_cd=[' ||
                                                   i_promo_stat_cd ||
                                                   '],  i_cosmis_ndc=[' ||
                                                   i_cosmis_ndc ||
                                                   '], i_cosmis_descr=[' ||
                                                   i_cosmis_descr ||
                                                   '], i_pckg_nm=[' ||
                                                   i_pckg_nm ||
                                                   '], i_medicare_elig_stat_cd=[' ||
                                                   i_medicare_elig_stat_cd ||
                                                   '], i_sap_prod_cd=[' ||
                                                   i_sap_prod_cd ||
                                                   '], i_items_per_ndc=[' ||
                                                   i_items_per_ndc ||
                                                   '], i_volume_per_item=[' ||
                                                   i_volume_per_item ||
                                                   '], i_mdcr_exp_trnsmitted_dt_str=[' ||
                                                   i_mdcr_exp_trnsmitted_dt_str ||
                                                   '],  i_comm_unit_per_pckg=[' ||
                                                   i_comm_unit_per_pckg ||
                                                   '], i_pname_desc=[' ||
                                                   i_pname_desc ||
                                                   '], i_strngtyp_id=[' ||
                                                   i_strngtyp_id ||
                                                   '], i_sizetyp_id=[' ||
                                                   i_sizetyp_id ||
                                                   '], i_pkgtyp_id=[' ||
                                                   i_pkgtyp_id || '].');
   END p_prod_pckg_i;

   PROCEDURE p_prod_pckg_u
     (i_ndc_lbl                    IN VARCHAR2,
      i_ndc_prod                   IN VARCHAR2,
      i_ndc_pckg                   IN VARCHAR2,
      i_unit_per_pckg              IN NUMBER,
      i_hcfa_disp_units            IN NUMBER,
      i_first_dt_sld_dir_str       IN VARCHAR2,
      i_shelf_life_mon             IN NUMBER,
      i_liability_mon              IN NUMBER,
      i_elig_stat_cd               IN VARCHAR2,
      i_inelig_rsn_id              IN NUMBER,
      i_prod_nm                    IN VARCHAR2,
      i_fda_approval_dt_str        IN VARCHAR2,
      i_new_prod_flg               IN VARCHAR2,
      i_first_dt_sld_str           IN VARCHAR2,
      i_divestr_dt_str             IN VARCHAR2,
      i_fda_reg_nm                 IN VARCHAR2,
      i_final_lot_dt_str           IN VARCHAR2,
      i_promo_stat_cd              IN VARCHAR2,
      i_cosmis_ndc                 IN VARCHAR2,
      i_cosmis_descr               IN VARCHAR2,
      i_pckg_nm                    IN VARCHAR2,
      i_medicare_elig_stat_cd      IN VARCHAR2,
      i_sap_prod_cd                IN VARCHAR2,
      i_sap_company_cd             IN VARCHAR2,
      i_items_per_ndc              IN NUMBER,
      i_volume_per_item            IN NUMBER,
      i_mdcr_exp_trnsmitted_dt_str IN VARCHAR2,
      i_comm_unit_per_pckg         IN NUMBER,
      i_pname_desc                 IN VARCHAR2,
      i_strngtyp_id                IN VARCHAR2,
      i_sizetyp_id                 IN VARCHAR2,
      i_pkgtyp_id                  IN VARCHAR2,
      i_va_drug_catg_cd            IN VARCHAR2,
      i_va_elig_stat_cd            IN VARCHAR2,
      i_phs_elig_stat_cd           IN VARCHAR2,
      i_fdb_case_size              IN NUMBER,
      i_fdb_package_size           IN NUMBER,
      o_cnt                        OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_prod_pckg_u
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      UPDATE hcrs.prod_mstr_t p
         SET p.unit_per_pckg              = i_unit_per_pckg,
             p.hcfa_disp_units            = i_hcfa_disp_units,
             p.first_dt_sld_dir           = TO_DATE(i_first_dt_sld_dir_str,'MM/DD/YYYY'),
             p.shelf_life_mon             = i_shelf_life_mon,
             p.liablty_mon                = i_liability_mon,
             p.elig_stat_cd               = i_elig_stat_cd,
             p.inelig_rsn_id              = i_inelig_rsn_id,
             p.prod_nm                    = i_prod_nm,
             p.fda_approval_dt            = TO_DATE(i_fda_approval_dt_str,'MM/DD/YYYY'),
             p.new_prod_flg               = i_new_prod_flg,
             p.first_dt_sld               = TO_DATE(i_first_dt_sld_str,'MM/DD/YYYY'),
             p.divestr_dt                 = TO_DATE(i_divestr_dt_str,'MM/DD/YYYY'),
             p.fda_reg_nm                 = i_fda_reg_nm,
             p.final_lot_dt               = TO_DATE(i_final_lot_dt_str,'MM/DD/YYYY'),
             p.promo_stat_cd              = i_promo_stat_cd,
             p.cosmis_ndc                 = i_cosmis_ndc,
             p.cosmis_descr               = i_cosmis_descr,
             p.pckg_nm                    = i_pckg_nm,
             p.medicare_elig_stat_cd      = i_medicare_elig_stat_cd,
             p.sap_prod_cd                = i_sap_prod_cd,
             p.sap_company_cd             = i_sap_company_cd,
             p.items_per_ndc              = i_items_per_ndc,
             p.volume_per_item            = i_volume_per_item,
             p.medicare_exp_trnsmitted_dt = TO_DATE(i_mdcr_exp_trnsmitted_dt_str,'MM/DD/YYYY'),
             p.comm_unit_per_pckg         = i_comm_unit_per_pckg,
             p.pname_desc                 = i_pname_desc,
             p.strngtyp_id                = i_strngtyp_id,
             p.sizetyp_id                 = i_sizetyp_id,
             p.pkgtyp_id                  = i_pkgtyp_id,
             p.va_drug_catg_cd            = i_va_drug_catg_cd,
             p.va_elig_stat_cd            = i_va_elig_stat_cd,
             p.phs_elig_stat_cd           = i_phs_elig_stat_cd,
             p.fdb_case_size              = i_fdb_case_size,
             p.fdb_package_size           = i_fdb_package_size
       WHERE p.ndc_lbl = i_ndc_lbl
         AND p.ndc_prod = i_ndc_prod
         AND p.ndc_pckg = i_ndc_pckg;
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg ||
                                                   '.p_prod_pckg_u',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error. i_ndc_lbl=[' ||
                                                   i_ndc_lbl ||
                                                   '], i_ndc_prod=[' ||
                                                   i_ndc_prod ||
                                                   '], i_ndc_pckg=[' ||
                                                   i_ndc_pckg ||
                                                   '], i_unit_per_pckg=[' ||
                                                   i_unit_per_pckg ||
                                                   '], i_hcfa_disp_units=[' ||
                                                   i_hcfa_disp_units ||
                                                   '], i_first_dt_sld_dir_str=[' ||
                                                   i_first_dt_sld_dir_str ||
                                                   '], i_shelf_life_mon=[' ||
                                                   i_shelf_life_mon ||
                                                   '],  i_elig_stat_cd=[' ||
                                                   i_elig_stat_cd ||
                                                   '], i_inelig_rsn_id=[' ||
                                                   i_inelig_rsn_id ||
                                                   '], i_prod_nm=[' ||
                                                   i_prod_nm ||
                                                   '], i_fda_approval_dt_str=[' ||
                                                   i_fda_approval_dt_str ||
                                                   '], i_new_prod_flg=[' ||
                                                   i_new_prod_flg ||
                                                   '], i_first_dt_sld_str=[' ||
                                                   i_first_dt_sld_str ||
                                                   '], i_divestr_dt_str=[' ||
                                                   i_divestr_dt_str ||
                                                   '], i_fda_reg_nm=[' ||
                                                   i_fda_reg_nm ||
                                                   '], i_final_lot_dt_str=[' ||
                                                   i_final_lot_dt_str ||
                                                   '], i_promo_stat_cd=[' ||
                                                   i_promo_stat_cd ||
                                                   '],  i_cosmis_ndc=[' ||
                                                   i_cosmis_ndc ||
                                                   '], i_cosmis_descr=[' ||
                                                   i_cosmis_descr ||
                                                   '], i_pckg_nm=[' ||
                                                   i_pckg_nm ||
                                                   '], i_medicare_elig_stat_cd=[' ||
                                                   i_medicare_elig_stat_cd ||
                                                   '], i_sap_prod_cd=[' ||
                                                   i_sap_prod_cd ||
                                                   '], i_items_per_ndc=[' ||
                                                   i_items_per_ndc ||
                                                   '], i_volume_per_item=[' ||
                                                   i_volume_per_item ||
                                                   '], i_mdcr_exp_trnsmitted_dt_str=[' ||
                                                   i_mdcr_exp_trnsmitted_dt_str ||
                                                   '],  i_comm_unit_per_pckg=[' ||
                                                   i_comm_unit_per_pckg ||
                                                   '], i_pname_desc=[' ||
                                                   i_pname_desc ||
                                                   '], i_strngtyp_id=[' ||
                                                   i_strngtyp_id ||
                                                   '], i_sizetyp_id=[' ||
                                                   i_sizetyp_id ||
                                                   '], i_pkgtyp_id=[' ||
                                                   i_pkgtyp_id || '].');
   END p_prod_pckg_u;

   PROCEDURE p_attchm_ref_id
     (i_ndc_lbl           IN VARCHAR2,
      o_attachment_ref_id OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_attchm_ref_id
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      SELECT DISTINCT NVL(l.attachment_ref_id, 0)
        INTO o_attachment_ref_id
        FROM hcrs.lbl_t l
       WHERE l.ndc_lbl = i_ndc_lbl;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_attchm_ref_id',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_attchm_ref_id;

   PROCEDURE p_attchm_ref_u
     (i_ndc_lbl           IN VARCHAR2,
      i_attachment_ref_id IN NUMBER,
      o_cnt               OUT NUMBER)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_attchm_ref_u
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date          Name                Comment
       * ------------  ------------------  --------------------------------------
       *
       **********************************************************************************/
   BEGIN
      UPDATE hcrs.lbl_t l
         SET l.attachment_ref_id = i_attachment_ref_id
       WHERE l.ndc_lbl = i_ndc_lbl;
      o_cnt := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_utils.p_raise_errors(i_src_cd      => 'p_attchm_ref_u',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_attchm_ref_u;

END pkg_ui_dm_prod_sel;
/
