CREATE OR REPLACE PACKAGE HCRS.pkg_load_bivv_medi_data AS

   PROCEDURE p_run_phase1 (a_clean_flg VARCHAR2 DEFAULT 'Y');
   PROCEDURE p_run_phase2 (a_clean_flg VARCHAR2 DEFAULT 'Y');
   PROCEDURE p_run_phase3 (a_clean_flg VARCHAR2 DEFAULT 'Y');

   PROCEDURE p_run_pricing_delta;

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
   v_upd_cnt   NUMBER := 0;
   v_ins_cnt   NUMBER := 0;
--   v_eff_dt    DATE := SYSDATE;
BEGIN
   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   FOR rec IN (
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
         mod_by, 
         src_sys, 
         src_sys_unique_id
      FROM bivv.pur_final_results_t
--      WHERE ndc_prod = '0801' AND pgm_id = 1
   ) LOOP

      -- update end date of any existing record with the same key and different price
      UPDATE hcrs.pur_final_results_t t
      SET t.end_dt = rec.eff_dt - 1/(24*60*60)
      WHERE t.period_id = rec.period_id
         AND t.pgm_id = rec.pgm_id
         AND t.ndc_lbl = rec.ndc_lbl
         AND t.ndc_prod = rec.ndc_prod
         AND t.ndc_pckg = rec.ndc_pckg
         AND t.end_dt = to_date('1/1/2100','mm/dd/yyyy')
         AND t.calc_amt != rec.calc_amt;

      v_upd_cnt := v_upd_cnt + SQL%ROWCOUNT;

      -- insert only if amount is different for the same period/pgm/ndc  
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
         mod_by, 
         src_sys, 
         src_sys_unique_id)
      SELECT 
         rec.period_id, 
         rec.per_begin_dt, 
         rec.per_end_dt, 
         rec.pgm_id, 
         rec.ndc_lbl, 
         rec.ndc_prod, 
         rec.ndc_pckg, 
         rec.calc_amt, 
         rec.eff_dt, 
         rec.end_dt, 
         rec.mod_by, 
         rec.src_sys, 
         rec.src_sys_unique_id
      FROM dual
      WHERE NOT EXISTS (
         SELECT 1 FROM hcrs.pur_final_results_t t
         WHERE t.period_id = rec.period_id
            AND t.pgm_id = rec.pgm_id
            AND t.ndc_lbl = rec.ndc_lbl
            AND t.ndc_prod = rec.ndc_prod
            AND t.ndc_pckg = rec.ndc_pckg
            AND t.calc_amt = rec.calc_amt);

      v_ins_cnt := v_ins_cnt + SQL%ROWCOUNT;

   END LOOP;

   bivv.pkg_util.p_saveLog('Updated PUR_FINAL_RESULTS_T count: '||v_upd_cnt, c_program, v_module);
   bivv.pkg_util.p_saveLog('Inserted PUR_FINAL_RESULTS_T count: '||v_ins_cnt, c_program, v_module);
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
/*
*/
PROCEDURE p_run_pricing_delta IS
  v_module    bivv.conv_log_t.module%TYPE := 'p_run_pricing_delta';

BEGIN

   bivv.pkg_util.p_saveLog('START', c_program, v_module);

   -- copy WAC/LP prices
   INSERT INTO hcrs.prod_price_t 
      (ndc_lbl, ndc_prod, ndc_pckg, prod_price_typ_cd, eff_dt, end_dt, price_amt, rec_src_ind)
   SELECT ndc_lbl, ndc_prod, ndc_pckg, prod_price_typ_cd, eff_dt, end_dt, price_amt, rec_src_ind   
   FROM bivv.prod_price_t pp
   WHERE NOT EXISTS (
      SELECT 1 FROM hcrs.prod_price_t t
      WHERE t.prod_price_typ_cd = pp.prod_price_typ_cd
         AND t.ndc_lbl = pp.ndc_lbl
         AND t.ndc_prod = pp.ndc_prod
         AND t.ndc_pckg = pp.ndc_pckg
         AND t.eff_dt = pp.eff_dt);
   bivv.pkg_util.p_saveLog('PROD_PRICE_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   -- qtrly AMP/BP into product transmission
   INSERT INTO hcrs.prod_trnsmsn_t
      (ndc_lbl, ndc_prod, period_id, trnsmsn_seq_no, prod_trnsmsn_stat_cd, prod_trnsmsn_rsn_cd, 
      amp_amt, bp_amt, actv_flg, amp_apprvl_flg, bp_apprvl_flg, trnsmsn_dt, dra_baseline_flg)
   SELECT 
      ndc_lbl, ndc_prod, period_id, trnsmsn_seq_no, prod_trnsmsn_stat_cd, prod_trnsmsn_rsn_cd, 
      amp_amt, bp_amt, actv_flg, amp_apprvl_flg, bp_apprvl_flg, trnsmsn_dt, dra_baseline_flg
   FROM bivv.prod_trnsmsn_t pt
   WHERE NOT EXISTS (
      SELECT 1 FROM hcrs.prod_trnsmsn_t t
      WHERE t.period_id = pt.period_id
         AND t.ndc_lbl = pt.ndc_lbl
         AND t.ndc_prod = pt.ndc_prod);
   bivv.pkg_util.p_saveLog('PROD_TRNSMSN_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   -- insert profiles
   INSERT INTO hcrs.prfl_t 
      (prfl_id, snpsht_id, prfl_stat_cd, agency_typ_cd, tim_per_cd, prcss_typ_cd, prfl_nm, 
      begn_dt, end_dt, copy_hist_ind, prelim_ind, mtrx_ind)
   SELECT 
      p.prfl_id, p.snpsht_id, p.prfl_stat_cd, p.agency_typ_cd, p.tim_per_cd, p.prcss_typ_cd, p.prfl_nm, 
      p.begn_dt, p.end_dt, p.copy_hist_ind, p.prelim_ind, p.mtrx_ind
   FROM bivv.prfl_t p
      ,bivv.bivv_prfl_delta_v pd
   WHERE p.prfl_id = pd.prfl_id
      AND NOT EXISTS (
         SELECT 1 FROM hcrs.prfl_t p2
         WHERE p2.prfl_id = p.prfl_id);
   bivv.pkg_util.p_saveLog('PRFL_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   -- profile company
   INSERT INTO hcrs.prfl_co_t (prfl_id, co_id)
   SELECT pc.prfl_id, pc.co_id
   FROM bivv.prfl_co_t pc
      ,bivv.bivv_prfl_delta_v pd
   WHERE pc.prfl_id = pd.prfl_id
      AND NOT EXISTS (
         SELECT 1 FROM hcrs.prfl_co_t pc2
         WHERE pc2.prfl_id = pc.prfl_id
            AND pc2.co_id = pc.co_id);
   bivv.pkg_util.p_saveLog('PRFL_CO_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   -- profile calc type
   INSERT INTO hcrs.prfl_calc_typ_t (calc_typ_cd, prfl_id, calc_mthd_cd)
   SELECT ct.calc_typ_cd, ct.prfl_id, ct.calc_mthd_cd
   FROM bivv.prfl_calc_typ_t ct
      ,bivv.bivv_prfl_delta_v pd
   WHERE ct.prfl_id = pd.prfl_id
      AND NOT EXISTS (
         SELECT 1 FROM hcrs.prfl_calc_typ_t ct2
         WHERE ct2.calc_typ_cd = ct.calc_typ_cd
            AND ct2.prfl_id = ct.prfl_id
            AND ct2.calc_mthd_cd = ct.calc_mthd_cd);
   bivv.pkg_util.p_saveLog('PRFL_CALC_TYP_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   -- profile variables
   INSERT INTO hcrs.prfl_var_t (prfl_id, agency_typ_cd, var_cd, val_txt, prcss_typ_cd)
   SELECT v.prfl_id, v.agency_typ_cd, v.var_cd, v.val_txt, v.prcss_typ_cd
   FROM bivv.prfl_var_t v
      ,bivv.bivv_prfl_delta_v pd
   WHERE v.prfl_id = pd.prfl_id
      AND NOT EXISTS (
         SELECT 1 FROM hcrs.prfl_var_t v2
         WHERE v2.prfl_id = v.prfl_id
            AND v2.agency_typ_cd = v.agency_typ_cd
            AND v2.var_cd = v.var_cd);
   bivv.pkg_util.p_saveLog('PRFL_VAR_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   -- profile prod family
   INSERT INTO hcrs.prfl_prod_fmly_t (prfl_id, ndc_lbl, ndc_prod)
   SELECT pf.prfl_id, pf.ndc_lbl, pf.ndc_prod
   FROM bivv.prfl_prod_fmly_t pf
      ,bivv.bivv_prfl_delta_v pd
   WHERE pf.prfl_id = pd.prfl_id
      AND NOT EXISTS (
         SELECT 1 FROM hcrs.prfl_prod_fmly_t pf2
         WHERE pf2.prfl_id = pf.prfl_id
            AND pf2.ndc_lbl = pf.ndc_lbl
            AND pf2.ndc_prod = pf.ndc_prod);
   bivv.pkg_util.p_saveLog('PRFL_PROD_FMLY_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   INSERT INTO hcrs.prfl_prod_t 
      (prfl_id, ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd, calc_stat_cd, shtdwn_ind)
   SELECT pp.prfl_id, pp.ndc_lbl, pp.ndc_prod, pp.ndc_pckg, pp.pri_whls_mthd_cd, pp.calc_stat_cd, pp.shtdwn_ind
   FROM bivv.prfl_prod_t pp
      ,bivv.bivv_prfl_delta_v pd
   WHERE pp.prfl_id = pd.prfl_id
      AND NOT EXISTS (
         SELECT 1 FROM hcrs.prfl_prod_t pp2
         WHERE pp2.prfl_id = pp.prfl_id
            AND pp2.ndc_lbl = pp.ndc_lbl
            AND pp2.ndc_prod = pp.ndc_prod
            AND pp2.ndc_pckg = pp.ndc_pckg);
   bivv.pkg_util.p_saveLog('PRFL_PROD_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   -- profile calc prod family
   INSERT INTO hcrs.prfl_calc_prod_fmly_t
      (prfl_id, calc_typ_cd, ndc_lbl, ndc_prod, pri_whls_mthd_cd)
   SELECT pc.prfl_id, pc.calc_typ_cd, pc.ndc_lbl, pc.ndc_prod, pc.pri_whls_mthd_cd
   FROM bivv.prfl_calc_prod_fmly_t pc
      ,bivv.bivv_prfl_delta_v pd
   WHERE pc.prfl_id = pd.prfl_id
      AND NOT EXISTS (
         SELECT 1 FROM hcrs.prfl_calc_prod_fmly_t pc2
         WHERE pc2.prfl_id = pc.prfl_id
            AND pc2.calc_typ_cd = pc.calc_typ_cd
            AND pc2.ndc_lbl = pc.ndc_lbl
            AND pc2.ndc_prod = pc.ndc_prod);
   bivv.pkg_util.p_saveLog('PRFL_CALC_PROD_FMLY_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   -- profile calc prod
   INSERT INTO hcrs.prfl_calc_prod_t 
      (prfl_id, calc_typ_cd, ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd)
   SELECT pc.prfl_id, pc.calc_typ_cd, pc.ndc_lbl, pc.ndc_prod, pc.ndc_pckg, pc.pri_whls_mthd_cd
   FROM bivv.prfl_calc_prod_t pc
      ,bivv.bivv_prfl_delta_v pd
   WHERE pc.prfl_id = pd.prfl_id
      AND NOT EXISTS (
         SELECT 1 FROM hcrs.prfl_calc_prod_t pc2
         WHERE pc2.prfl_id = pc.prfl_id
            AND pc2.calc_typ_cd = pc.calc_typ_cd
            AND pc2.ndc_lbl = pc.ndc_lbl
            AND pc2.ndc_prod = pc.ndc_prod
            AND pc2.ndc_pckg = pc.ndc_pckg);
   bivv.pkg_util.p_saveLog('PRFL_CALC_PROD_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   -- profile prod family calc prices
   INSERT INTO hcrs.prfl_prod_fmly_calc_t
      (prfl_id, ndc_lbl, ndc_prod, calc_typ_cd, comp_typ_cd, calc_amt)
   SELECT fc.prfl_id, fc.ndc_lbl, fc.ndc_prod, fc.calc_typ_cd, fc.comp_typ_cd, fc.calc_amt
   FROM bivv.prfl_prod_fmly_calc_t fc
      ,bivv.bivv_prfl_delta_v pd
   WHERE fc.prfl_id = pd.prfl_id
      AND NOT EXISTS (
         SELECT 1 FROM hcrs.prfl_prod_fmly_calc_t fc2
         WHERE fc2.prfl_id = fc.prfl_id
            AND fc2.ndc_lbl = fc.ndc_lbl
            AND fc2.ndc_prod = fc.ndc_prod
            AND fc2.calc_typ_cd = fc.calc_typ_cd
            AND fc2.comp_typ_cd = fc.comp_typ_cd);
   bivv.pkg_util.p_saveLog('PRFL_PROD_FMLY_CALC_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   -- profile prod calc prices
   INSERT INTO hcrs.prfl_prod_calc_t
      (prfl_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, comp_typ_cd, calc_amt)
   SELECT fc.prfl_id, fc.ndc_lbl, fc.ndc_prod, fc.ndc_pckg, fc.calc_typ_cd, fc.comp_typ_cd, fc.calc_amt
   FROM bivv.prfl_prod_calc_t fc
      ,bivv.bivv_prfl_delta_v pd
   WHERE fc.prfl_id = pd.prfl_id
      AND NOT EXISTS (
         SELECT 1 FROM hcrs.prfl_prod_calc_t fc2
         WHERE fc2.prfl_id = fc.prfl_id
            AND fc2.ndc_lbl = fc.ndc_lbl
            AND fc2.ndc_prod = fc.ndc_prod
            AND fc2.ndc_pckg = fc.ndc_pckg
            AND fc2.calc_typ_cd = fc.calc_typ_cd
            AND fc2.comp_typ_cd = fc.comp_typ_cd);
   bivv.pkg_util.p_saveLog('PRFL_PROD_CALC_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   COMMIT;

   bivv.pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      bivv.pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      bivv.pkg_util.p_saveLog('END', c_program, v_module);

END;
/*
*/
END;
/
