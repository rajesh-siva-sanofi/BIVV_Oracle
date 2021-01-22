CREATE OR REPLACE PACKAGE HCRS.pkg_load_bivv_medi_data AS

   PROCEDURE p_run_phase1 (a_clean_flg VARCHAR2 DEFAULT 'Y');
   PROCEDURE p_run_phase2 (a_clean_flg VARCHAR2 DEFAULT 'Y');
   PROCEDURE p_run_phase3 (a_clean_flg VARCHAR2 DEFAULT 'Y');

END;
/
CREATE OR REPLACE PACKAGE BODY HCRS.pkg_load_bivv_medi_data AS

   c_program      CONSTANT bivv.conv_log_t.program%TYPE := 'HCRS.PKG_LOAD_BIVV_MEDI_DATA';
   c_bivv_ndc_lbl CONSTANT hcrs.reb_claim_t.ndc_lbl%TYPE :='71104';
   c_source_id    CONSTANT VARCHAR2(4) := 'BIVV';

----------------------p_load_reb_claim---------------------
PROCEDURE p_load_reb_claim IS
   v_module    bivv.conv_log_t.module%TYPE := 'p_load_reb_claim';
BEGIN
   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO hcrs.reb_claim_t (
      pgm_id,
      ndc_lbl,
      period_id,
      reb_clm_seq_no,
      co_id,
      subm_typ_cd,
      reb_claim_stat_cd,
      pstmrk_dt,
      pymnt_pstmrk_dt,
      rcv_dt,
      input_dt,
      extd_due_dt,
      invc_num,
      tot_claim_units,
      valid_dt,
      prelim_run_dt,
      prelim_sent_dt,
      prelim_apprv_dt,
      final_run_dt,
      dspt_prelim_sent_dt,
      dspt_prelim_apprv_dt,
      corr_int_flg,
      create_dt,
      mod_by,
      attachment_ref_id)
   SELECT
      pgm_id,
      ndc_lbl,
      period_id,
      reb_clm_seq_no,
      co_id,
      subm_typ_cd,
      reb_claim_stat_cd,
      pstmrk_dt,
      pymnt_pstmrk_dt,
      rcv_dt,
      input_dt,
      extd_due_dt,
      invc_num,
      tot_claim_units,
      valid_dt,
      prelim_run_dt,
      prelim_sent_dt,
      prelim_apprv_dt,
      final_run_dt,
      dspt_prelim_sent_dt,
      dspt_prelim_apprv_dt,
      corr_int_flg,
      SYSDATE AS create_dt,
      mod_by,
      attachment_ref_id
   FROM bivv.reb_claim_t;

   bivv.pkg_util.p_saveLog('Inserted REB_CLAIM_T count: '||SQL%ROWCOUNT, c_program, v_module);
   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;


----------------------------------p_load_reb_claim_line-------------------------------

PROCEDURE p_load_reb_claim_line IS
   v_module    bivv.conv_log_t.module%TYPE := 'p_load_reb_claim_line';
BEGIN
   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO hcrs.reb_clm_ln_itm_t (
      pgm_id,
      ndc_lbl,
      period_id,
      reb_clm_seq_no,
      co_id,
      ln_itm_seq_no,
      claim_units,
      claim_amt,
      reb_claim_ln_itm_stat_cd,
      script_cnt,
      pgm_pur,
      reimbur_amt,
      corr_flg,
      item_prod_fmly_ndc,
      item_prod_mstr_ndc,
      create_dt,
      mod_by,
      nonmed_reimbur_amt,
      total_reimbur_amt)
   SELECT
      pgm_id,
      ndc_lbl,
      period_id,
      reb_clm_seq_no,
      co_id,
      ln_itm_seq_no,
      claim_units,
      claim_amt,
      reb_claim_ln_itm_stat_cd,
      script_cnt,
      pgm_pur,
      reimbur_amt,
      corr_flg,
      item_prod_fmly_ndc,
      item_prod_mstr_ndc,
      SYSDATE AS create_dt,
      mod_by,
      nonmed_reimbur_amt,
      total_reimbur_amt
   FROM bivv.reb_clm_ln_itm_t;

   bivv.pkg_util.p_saveLog('Inserted REB_CLM_LN_ITM_T count: '||SQL%ROWCOUNT, c_program, v_module);
   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;

-------------------------------------p_load_reb_valid_claim---------------------------


PROCEDURE p_load_reb_valid_claim IS
  v_module    bivv.conv_log_t.module%TYPE := 'p_load_reb_valid_claim';
BEGIN
   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO hcrs.valid_claim_t (
     pgm_id,
     ndc_lbl,
     period_id,
     reb_clm_seq_no,
     co_id,
     ln_itm_seq_no,
     ndc_prod,
     ndc_pckg,
     dspt_flg,
     claim_units,
     claim_amt,
     script_cnt,
     pgm_pur,
     reimbur_amt,
     corr_flg,
     create_dt,
     mod_by
     )
   SELECT pgm_id,
     ndc_lbl,
     period_id,
     reb_clm_seq_no,
     co_id,
     ln_itm_seq_no,
     ndc_prod,
     ndc_pckg,
     dspt_flg,
     claim_units,
     claim_amt,
     script_cnt,
     pgm_pur,
     reimbur_amt,
     corr_flg,
     SYSDATE AS create_dt,
     mod_by
   FROM bivv.valid_claim_t;

   bivv.pkg_util.p_saveLog('Inserted VALID_CLAIM_T count: '||SQL%ROWCOUNT, c_program, v_module);
   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END p_load_reb_valid_claim;

------------------------p_load_reb_dspt_claim--------------------------------


PROCEDURE p_load_reb_dspt_claim IS
  v_module    bivv.conv_log_t.module%TYPE := 'p_load_reb_dspt_claim';
BEGIN
   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO hcrs.dspt_t
     (
     pgm_id,
     ndc_lbl,
     period_id,
     reb_clm_seq_no,
     co_id,
     ln_itm_seq_no,
     dspt_seq_no,
     ndc_prod,
     ndc_pckg,
     paid_units,
     dspt_units,
     wrt_off_units,
     dspt_dt,
     create_dt,
     mod_by,
     note_txt
     )
   SELECT
     pgm_id,
     ndc_lbl,
     period_id,
     reb_clm_seq_no,
     co_id,
     ln_itm_seq_no,
     dspt_seq_no,
     ndc_prod,
     ndc_pckg,
     paid_units,
     dspt_units,
     wrt_off_units,
     dspt_dt,
     SYSDATE AS create_dt,
     mod_by,
     note_txt
   FROM bivv.dspt_t;
   bivv.pkg_util.p_saveLog('Inserted DSPT_T count: '||SQL%ROWCOUNT, c_program, v_module);

   INSERT INTO hcrs.dspt_rsn_t (
     rpr_dspt_rsn_id,
     pgm_id,
     ndc_lbl,
     period_id,
     reb_clm_seq_no,
     co_id,
     ln_itm_seq_no,
     dspt_seq_no,
     dspt_priority,
     create_dt,
     mod_by)
   SELECT
     rpr_dspt_rsn_id,
     pgm_id,
     ndc_lbl,
     period_id,
     reb_clm_seq_no,
     co_id,
     ln_itm_seq_no,
     dspt_seq_no,
     dspt_priority,
     SYSDATE AS create_dt,
     mod_by
     FROM bivv.dspt_rsn_t;

   bivv.pkg_util.p_saveLog('Inserted DSPT_RSN_T count: '||SQL%ROWCOUNT, c_program, v_module);
   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END p_load_reb_dspt_claim;

------------------------p_load_check_req_tbl------------------------------
PROCEDURE p_load_check_req_dtl IS
  v_module    bivv.conv_log_t.module%TYPE := 'p_load_check_req_tbl';

BEGIN
   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO hcrs.valid_claim_chk_req_t (
      pgm_id,
      ndc_lbl,
      period_id,
      reb_clm_seq_no,
      co_id,
      ln_itm_seq_no,
      check_id,
      ndc_prod,
      ndc_pckg,
      paid_amt,
      int_amt,
      int_owed_amt,
      int_wrt_off_amt,
      int_owed_flg,
      create_dt,
      mod_by)
   SELECT
      pgm_id,
      ndc_lbl,
      period_id,
      reb_clm_seq_no,
      co_id,
      ln_itm_seq_no,
      check_id,
      ndc_prod,
      ndc_pckg,
      paid_amt,
      int_amt,
      int_owed_amt,
      int_wrt_off_amt,
      int_owed_flg,
      SYSDATE AS create_dt,
      mod_by
   FROM bivv.valid_claim_chk_req_t;
   bivv.pkg_util.p_saveLog('Inserted VALID_CLAIM_CHK_REQ_T count: '||SQL%ROWCOUNT, c_program, v_module);

   INSERT INTO hcrs.dspt_check_req_t (
      pgm_id,
      ndc_lbl,
      period_id,
      reb_clm_seq_no,
      co_id,
      ln_itm_seq_no,
      dspt_seq_no,
      check_id,
      ndc_prod,
      ndc_pckg,
      paid_amt,
      int_amt,
      int_owed_amt,
      int_wrt_off_amt,
      int_owed_flg,
      create_dt,
      mod_by)
   SELECT
      pgm_id,
      ndc_lbl,
      period_id,
      reb_clm_seq_no,
      co_id,
      ln_itm_seq_no,
      dspt_seq_no,
      check_id,
      ndc_prod,
      ndc_pckg,
      paid_amt,
      int_amt,
      int_owed_amt,
      int_wrt_off_amt,
      int_owed_flg,
      SYSDATE AS create_dt,
      mod_by
   FROM bivv.dspt_check_req_t;
   bivv.pkg_util.p_saveLog('Inserted DSPT_CHECK_REQ_T count: '||SQL%ROWCOUNT, c_program, v_module);

   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END p_load_check_req_dtl;

--------------------p_load_check_agg_tbl------------------
PROCEDURE p_load_check_req IS
  v_module    bivv.conv_log_t.module%TYPE := 'p_load_check_agg_tbl';
BEGIN
  bivv.pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO hcrs.check_req_t (
      check_id,
      check_req_stat_cd,
      pymnt_catg_cd,
      credit_num,
      check_req_amt,
      cr_bal,
      check_input_dt,
      check_dt,
      conf_dt,
      prcss_dt,
      mail_dt,
      check_req_dt,
      payer_notif_dt,
      pgm_id,
      co_id,
      int_sel_meth_cd,
      man_int_amt,
      rosi_flg,
      pqas_flg,
      est_check_mail_dt,
      create_dt,
      amt_changed_flg,
      cmt_txt,
      attachment_ref_id)
   SELECT 
      check_id,
      check_req_stat_cd,
      pymnt_catg_cd,
      credit_num,
      check_req_amt,
      cr_bal,
      check_input_dt,
      check_dt,
      conf_dt,
      prcss_dt,
      mail_dt,
      check_req_dt,
      payer_notif_dt,
      pgm_id,
      co_id,
      int_sel_meth_cd,
      man_int_amt,
      rosi_flg,
      pqas_flg,
      est_check_mail_dt,
      SYSDATE AS create_dt,
      amt_changed_flg,
      cmt_txt,
      attachment_ref_id
   FROM bivv.check_req_t;

   bivv.pkg_util.p_saveLog('Inserted CHECK_REQ_T count: '||SQL%ROWCOUNT, c_program, v_module);
   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END p_load_check_req;

--------------------------------p_load_check_t_tbl-------------------------------
PROCEDURE p_load_check_t_tbl IS
   v_module    bivv.conv_log_t.module%TYPE := 'p_load_check_t_tbl';
BEGIN
   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO hcrs.check_t (
      check_id,
      check_num,
      check_amt,
      create_dt,
      mod_by)
   SELECT
      check_id,
      check_num,
      check_amt,
      SYSDATE AS create_dt,
      mod_by
   FROM bivv.check_t;

   bivv.pkg_util.p_saveLog('Inserted CHECK_T count: '||SQL%ROWCOUNT, c_program, v_module);
   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END p_load_check_t_tbl;

------------------------------------p_load_check_appr_grp-----------------------
PROCEDURE p_load_check_appr_grp IS

   v_module    bivv.conv_log_t.module%TYPE := 'p_load_check_appr_grp';

BEGIN
   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO hcrs.check_apprvl_grp_t (
      apprvl_grp_id,
      co_id,
      pgm_id,
      apprvl_grp_desc,
      apprvl_amt,
      apprvl_status_cd,
      ap_sent_dt,
      create_dt,
      create_by,
      mod_by,
      sap_vendor_num,
      attachment_ref_id)
   SELECT
      apprvl_grp_id,
      co_id,
      pgm_id,
      apprvl_grp_desc,
      apprvl_amt,
      apprvl_status_cd,
      ap_sent_dt,
      SYSDATE AS create_dt,
      create_by,
      mod_by,
      sap_vendor_num,
      attachment_ref_id
   FROM bivv.check_apprvl_grp_t;
   bivv.pkg_util.p_saveLog('Inserted CHECK_APPRVL_GRP_T count: '||SQL%ROWCOUNT, c_program, v_module);

   INSERT INTO hcrs.check_apprvl_grp_apprvl_t (
     apprvl_grp_id,
     apprvl_limit_id,
     apprvl_reason_cd,
     apprvr_id,
     apprvl_dt,
     comment_txt,
     create_dt,
     mod_by,
     expected_release_dt)
   SELECT
      apprvl_grp_id,
      apprvl_limit_id,
      apprvl_reason_cd,
      apprvr_id,
      apprvl_dt,
      comment_txt,
      SYSDATE AS create_dt,
      mod_by,
      expected_release_dt
   FROM bivv.check_apprvl_grp_apprvl_t;
   bivv.pkg_util.p_saveLog('Inserted CHECK_APPRVL_GRP_APPRVL_T count: '||SQL%ROWCOUNT, c_program, v_module);

   INSERT INTO hcrs.check_apprvl_grp_chk_xref_t (
      apprvl_grp_id,
      check_id,
      create_dt,
      mod_by)
   SELECT
      apprvl_grp_id,
      check_id,
      SYSDATE AS create_dt,
      mod_by
   FROM bivv.check_apprvl_grp_chk_xref_t;
   bivv.pkg_util.p_saveLog('Inserted CHECK_APPRVL_GRP_CHK_XREF_T count: '||SQL%ROWCOUNT, c_program, v_module);

   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END p_load_check_appr_grp;

---------------------p_load_prod_pgm-----------------------------
PROCEDURE p_load_prod_pgm IS
   v_module    bivv.conv_log_t.module%TYPE := 'p_load_prod_pgm';
BEGIN
   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO hcrs.prod_mstr_pgm_t (
      pgm_id,
      ndc_lbl,
      ndc_prod,
      ndc_pckg,
      eff_dt,
      end_dt,
      create_dt,
      mod_by)
   SELECT
      pgm_id,
      ndc_lbl,
      ndc_prod,
      ndc_pckg,
      eff_dt,
      end_dt,
      SYSDATE AS create_dt,
      mod_by
   FROM bivv.prod_mstr_pgm_t;
   bivv.pkg_util.p_saveLog('Inserted PROD_MSTR_PGM_T count: '||SQL%ROWCOUNT, c_program, v_module);

   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;

---------------------p_load_claim_hist-----------------------------

PROCEDURE p_load_pur_results IS
   v_module    bivv.conv_log_t.module%TYPE := 'p_load_claim_hist';
BEGIN
   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO hcrs.pur_final_results_t (
      period_id, 
      per_begin_dt, 
      per_end_dt, 
      pgm_id, 
      ndc_lbl, 
      ndc_prod, 
      ndc_pckg, 
      calc_amt, 
      eff_dt, 
      end_dt, 
      create_dt, 
      mod_by, 
      src_sys, 
      src_sys_unique_id)
   SELECT
      period_id, 
      per_begin_dt, 
      per_end_dt, 
      pgm_id, 
      ndc_lbl, 
      ndc_prod, 
      ndc_pckg, 
      calc_amt, 
      eff_dt, 
      end_dt, 
      SYSDATE AS create_dt, 
      mod_by, 
      src_sys, 
      src_sys_unique_id
   FROM bivv.pur_final_results_t;

   bivv.pkg_util.p_saveLog('Inserted PUR_FINAL_RESULTS_T count: '||SQL%ROWCOUNT, c_program, v_module);
   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;

---------------------p_load_iqvia_data-----------------------------
/* Payment and details that are needed to loaded in IQVIA  */
PROCEDURE p_load_iqvia_data IS

   v_module    bivv.conv_log_t.module%TYPE := 'p_load_iqvia_data';

BEGIN
   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO hcrs.claim_hist_t (
      load_dt,
      src,
      co_id,
      co_nm,
      period_id,
      claim_period,
      state_cd,
      pgm_id,
      pgm_nm,
      ndc_lbl,
      ndc_prod,
      ndc_pckg,
      prod_nm,
      reb_clm_seq_no,
      ln_itm_seq_no,
      pgm_pur,
      ura,
      claim_units,
      claim_amt,
      paid_units,
      paid_amt,
      int_amt,
      dspt_units,
      dspt_amt,
      wrt_off_units,
      wrt_off_amt,
      dspt_seq_no,
      rpr_dspt_rsn_id,
      rpr_dspt_rsn_descr,
      dispute_reason,
      reb_claim_stat_cd,
      reb_claim_ln_itm_stat_cd,
      check_id,
      subm_typ_cd,
      pstmrk_dt,
      prcss_day_limit,
      rcv_dt,
      input_dt,
      invc_num,
      script_cnt,
      reimbur_amt,
      nonmed_reimbur_amt,
      total_reimbur_amt,
      valid_dt,
      prelim_run_dt,
      final_run_dt,
      due_dt,
      mod_by,
      util_rec_typ,
      source_id)
   SELECT
      sysdate load_dt,
      src,
      co_id,
      co_nm,
      period_id,
      claim_period,
      state_cd,
      pgm_id,
      pgm_nm,
      ndc_lbl,
      ndc_prod,
      ndc_pckg,
      prod_nm,
      reb_clm_seq_no,
      ln_itm_seq_no,
      pgm_pur,
      ura,
      claim_units,
      claim_amt,
      paid_units,
      paid_amt,
      int_amt,
      dspt_units,
      dspt_amt,
      wrt_off_units,
      wrt_off_amt,
      dspt_seq_no,
      rpr_dspt_rsn_id,
      rpr_dspt_rsn_descr,
      dispute_reason,
      reb_claim_stat_cd,
      reb_claim_ln_itm_stat_cd,
      check_id,
      subm_typ_cd,
      pstmrk_dt,
      prcss_day_limit,
      rcv_dt,
      input_dt,
      invc_num,
      script_cnt,
      reimbur_amt,
      nonmed_reimbur_amt,
      total_reimbur_amt,
      valid_dt,
      prelim_run_dt,
      final_run_dt,
      due_dt,
      mod_by,
      util_rec_typ,
      source_id
   FROM hcrs.bivv_claim_hist_v;
   bivv.pkg_util.p_saveLog('Inserted BIVV_CLAIM_HIST_T count: '||SQL%ROWCOUNT, c_program, v_module);

   INSERT INTO hcrs.pymnt_hist_t (
      load_dt,
      co_id,
      state_cd,
      pgm_id,
      pgm_nm,
      ndc_lbl,
      ndc_prod,
      ndc_pckg,
      ndc,
      prod_nm,
      claim_period_id,
      claim_period,
      reb_clm_seq_no,
      check_id,
      paid_amt,
      int_amt,
      check_input_dt,
      check_req_dt,
      check_cut_dt,
      pymnt_catg_cd,
      pymnt_catg_desc,
      check_req_stat_cd,
      check_status,
      check_group_id,
      check_group_desc,
      source_id)
   SELECT
     sysdate as load_dt,
     co_id,
     state_cd,
     pgm_id,
     pgm_nm,
     ndc_lbl,
     ndc_prod,
     ndc_pckg,
     ndc,
     prod_nm,
     claim_period_id,
     claim_period,
     reb_clm_seq_no,
     check_id,
     paid_amt,
     int_amt,
     check_input_dt,
     check_req_dt,
     check_cut_dt,
     pymnt_catg_cd,
     pymnt_catg_desc,
     check_req_stat_cd,
     check_status,
     check_group_id,
     check_group_desc,
     source_id
   FROM hcrs.bivv_pymnt_hist_v;
   bivv.pkg_util.p_saveLog('Inserted BIVV_PYMNT_HIST_T count: '||SQL%ROWCOUNT, c_program, v_module);

   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END p_load_iqvia_data;
/*
-------------------------p_cleanup_data----------------------
*/
PROCEDURE p_cleanup_claims_data IS
   v_module    bivv.conv_log_t.module%TYPE := 'p_cleanup_data';

   v_appgrp_cnt      NUMBER := 0;
   v_appgrp_xref_cnt NUMBER := 0;
   v_appgrp_app_cnt  NUMBER := 0;

   v_check_dsp_cnt   NUMBER := 0;
   v_check_val_cnt   NUMBER := 0;
   v_check_cnt       NUMBER := 0;
   v_check_req_cnt   NUMBER := 0;

BEGIN
   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   FOR chk_cur IN (
      SELECT check_id FROM valid_claim_chk_req_t
      WHERE ndc_lbl = c_bivv_ndc_lbl
         AND reb_clm_seq_no = 1 -- remove only originally imported checks
      UNION
      SELECT check_id FROM dspt_check_req_t
      WHERE ndc_lbl = c_bivv_ndc_lbl
         AND reb_clm_seq_no = 1)
   LOOP

--      bivv.pkg_util.p_saveLog('Working on check id: '||chk_cur.check_id, c_program, v_module);

      FOR grp_cur IN (
         SELECT apprvl_grp_id FROM check_apprvl_grp_chk_xref_t
         WHERE check_id = chk_cur.check_id)
      LOOP

--         bivv.pkg_util.p_saveLog('Working on appr group id: '||grp_cur.apprvl_grp_id, c_program, v_module);

         DELETE FROM hcrs.check_apprvl_grp_apprvl_t
         WHERE apprvl_grp_id = grp_cur.apprvl_grp_id;
         v_appgrp_app_cnt := v_appgrp_app_cnt + SQL%ROWCOUNT;

         DELETE FROM hcrs.check_apprvl_grp_chk_xref_t
         WHERE apprvl_grp_id = grp_cur.apprvl_grp_id;
         v_appgrp_xref_cnt := v_appgrp_xref_cnt + SQL%ROWCOUNT;

         DELETE FROM hcrs.check_apprvl_grp_t
         WHERE apprvl_grp_id = grp_cur.apprvl_grp_id;
         v_appgrp_cnt := v_appgrp_cnt + SQL%ROWCOUNT;

      END LOOP; -- approval group loop

      DELETE FROM hcrs.dspt_check_req_t
      WHERE  ndc_lbl = chk_cur.check_id;
      v_check_dsp_cnt := v_check_dsp_cnt + SQL%ROWCOUNT;

      DELETE FROM hcrs.valid_claim_chk_req_t
      WHERE ndc_lbl = chk_cur.check_id;
      v_check_val_cnt := v_check_val_cnt + SQL%ROWCOUNT;

      DELETE FROM hcrs.check_t
      WHERE check_id = chk_cur.check_id;
      v_check_cnt := v_check_cnt + SQL%ROWCOUNT;

      DELETE FROM hcrs.check_req_t
      WHERE check_id = chk_cur.check_id;
      v_check_req_cnt := v_check_req_cnt + SQL%ROWCOUNT;

   END LOOP; -- check loop

   bivv.pkg_util.p_saveLog('Deleted from CHECK_APPRVL_GRP_APPRVL_T: '||v_appgrp_app_cnt||' rows', c_program, v_module);
   bivv.pkg_util.p_saveLog('Deleted from CHECK_APPRVL_GRP_CHK_XREF_T: '||v_appgrp_xref_cnt||' rows', c_program, v_module);
   bivv.pkg_util.p_saveLog('Deleted from CHECK_APPRVL_GRP_T: '||v_appgrp_cnt||' rows', c_program, v_module);
   bivv.pkg_util.p_saveLog('Deleted from DSPT_CHECK_REQ_T: '||v_check_dsp_cnt||' rows', c_program, v_module);
   bivv.pkg_util.p_saveLog('Deleted from VALID_CLAIM_CHK_REQ_T: '||v_check_val_cnt||' rows', c_program, v_module);
   bivv.pkg_util.p_saveLog('Deleted from CHECK_T: '||v_check_cnt||' rows', c_program, v_module);
   bivv.pkg_util.p_saveLog('Deleted from CHECK_REQ_T: '||v_check_req_cnt||' rows', c_program, v_module);

   DELETE FROM hcrs.dspt_rsn_t
   WHERE ndc_lbl = c_bivv_ndc_lbl
      AND reb_clm_seq_no = 1;
   bivv.pkg_util.p_saveLog('Deleted from DSPT_RSN_T: '||SQL%ROWCOUNT||' rows', c_program, v_module);

   DELETE FROM hcrs.dspt_t
   WHERE ndc_lbl = c_bivv_ndc_lbl
      AND reb_clm_seq_no = 1;
   bivv.pkg_util.p_saveLog('Deleted from DSPT_T: '||SQL%ROWCOUNT||' rows', c_program, v_module);

   DELETE FROM hcrs.valid_claim_t
   WHERE ndc_lbl = c_bivv_ndc_lbl
      AND reb_clm_seq_no = 1;
   bivv.pkg_util.p_saveLog('Deleted from VALID_CLAIM_T: '||SQL%ROWCOUNT||' rows', c_program, v_module);

   DELETE FROM hcrs.reb_clm_ln_itm_t
   WHERE ndc_lbl = c_bivv_ndc_lbl
      AND reb_clm_seq_no = 1;
   bivv.pkg_util.p_saveLog('Deleted from REB_CLM_LN_ITM_T: '||SQL%ROWCOUNT||' rows', c_program, v_module);

   DELETE FROM hcrs.reb_claim_t
   WHERE ndc_lbl = c_bivv_ndc_lbl
      AND reb_clm_seq_no = 1;
   bivv.pkg_util.p_saveLog('Deleted from REB_CLAIM_T: '||SQL%ROWCOUNT||' rows', c_program, v_module);

--   DELETE FROM hcrs.bivv_claim_hist_t;
   DELETE FROM hcrs.claim_hist_t
   WHERE source_id = c_source_id;
   bivv.pkg_util.p_saveLog('Deleted from CLAIM_HIST_T: '||SQL%ROWCOUNT||' rows', c_program, v_module);

--   DELETE FROM hcrs.bivv_pymnt_hist_t;
   DELETE FROM hcrs.pymnt_hist_t
   WHERE source_id = c_source_id;
   bivv.pkg_util.p_saveLog('Deleted from PYMNT_HIST_T: '||SQL%ROWCOUNT||' rows', c_program, v_module);

   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
END;

/*
   Phase 2: 
   1. Product/Program eligibility load
*/
PROCEDURE p_run_phase1 (a_clean_flg VARCHAR2 DEFAULT 'Y') IS
  v_module    bivv.conv_log_t.module%TYPE := 'p_run_phase1';

BEGIN

   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   IF nvl(a_clean_flg, 'Y') = 'Y' THEN

      DELETE FROM hcrs.prod_mstr_pgm_t t
      WHERE t.ndc_lbl = c_bivv_ndc_lbl;

      bivv.pkg_util.p_saveLog('Deleted from PROD_MSTR_PGM_T: '||SQL%ROWCOUNT||' rows', c_program, v_module);
      
   END IF;

   -- proceed to load the data
   p_load_prod_pgm;

   COMMIT;

   bivv.pkg_util.p_saveLog('END', c_program, v_module);
   
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      bivv.pkg_util.p_saveLog('END', c_program, v_module);

END;

/*
   Phase 2: 
   1. URA load
*/
PROCEDURE p_run_phase2 (a_clean_flg VARCHAR2 DEFAULT 'Y') IS
  v_module    bivv.conv_log_t.module%TYPE := 'p_run_phase2';

BEGIN

   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   IF nvl(a_clean_flg, 'Y') = 'Y' THEN

      DELETE FROM hcrs.pur_final_results_t t
      WHERE t.ndc_lbl = c_bivv_ndc_lbl;

      bivv.pkg_util.p_saveLog('Deleted from PUR_FINAL_RESULTS_T: '||SQL%ROWCOUNT||' rows', c_program, v_module);
      
   END IF;

   -- proceed to load the data
   p_load_pur_results;

   COMMIT;

   bivv.pkg_util.p_saveLog('END', c_program, v_module);
   
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      bivv.pkg_util.p_saveLog('END', c_program, v_module);

END;

/*
   Phase 3: 
   1. Claims load
   2. URA delta (TBD)
*/
PROCEDURE p_run_phase3 (a_clean_flg VARCHAR2 DEFAULT 'Y') IS
  v_module    bivv.conv_log_t.module%TYPE := 'p_run_phase3';

BEGIN

   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   IF nvl(a_clean_flg, 'Y') = 'Y' THEN
      p_cleanup_claims_data;
   END IF;

   -- proceed to load the data
   p_load_reb_claim;
   p_load_reb_claim_line;
   p_load_reb_valid_claim;
   p_load_reb_dspt_claim;
   p_load_check_req;
   p_load_check_req_dtl;
   p_load_check_t_tbl;
   p_load_check_appr_grp;
   p_load_iqvia_data;

   COMMIT;

   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      bivv.pkg_util.p_saveLog('END', c_program, v_module);

END;

END;
/
