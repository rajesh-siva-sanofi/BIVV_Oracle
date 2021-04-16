CREATE OR REPLACE PACKAGE BIVV.pkg_stg_medi AS

   PROCEDURE p_run_phase1 (a_trunc_flg VARCHAR2 DEFAULT 'Y', a_valid_flg VARCHAR2 DEFAULT 'Y');
   PROCEDURE p_run_phase2 (a_trunc_flg VARCHAR2 DEFAULT 'Y', a_valid_flg VARCHAR2 DEFAULT 'Y');
   PROCEDURE p_run_phase3 (a_trunc_flg VARCHAR2 DEFAULT 'Y', a_valid_flg VARCHAR2 DEFAULT 'Y');

   PROCEDURE p_run_pricing_delta;

END;
/
CREATE OR REPLACE PACKAGE BODY BIVV.pkg_stg_medi AS

   c_program         CONSTANT conv_log_t.program%TYPE := 'BIVV.PKG_STG_MEDI';
   c_userid_BIVV     CONSTANT reb_claim_t.mod_by%TYPE := 'BIVV';
   c_prfl_nm_suffix  CONSTANT VARCHAR2(20) := 'Bioverativ LOADED';

   E_InvalidData EXCEPTION;
   E_InvalidPrfl EXCEPTION;
   E_InvalidPrcss EXCEPTION;

/*
   Validates product/program eligibility data
*/
PROCEDURE p_validate (av_object VARCHAR2, av_msg IN OUT VARCHAR2) IS

   v_module    conv_log_t.module%TYPE := 'p_validate';
   v_sql    VARCHAR2(4000);
   v_cnt    NUMBER;
   
BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);

   v_sql := 'SELECT COUNT(*) FROM '||av_object||' WHERE nvl(val_msg, ''OK'') LIKE ''ERR%''';

   EXECUTE IMMEDIATE v_sql  INTO v_cnt; 
   
   pkg_util.p_saveLog('Non valid count for '||av_object||': '||v_cnt, c_program, v_module);

   IF v_cnt > 0 THEN
      av_msg := CASE WHEN av_msg IS NOT NULL THEN av_msg||', ' END || av_object;
   END IF;

   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;
/*
   Validates product/program eligibility data
*/
PROCEDURE p_validate_prodelig IS

   v_module    conv_log_t.module%TYPE := 'p_validate_prodelig';
   v_msg    VARCHAR2 (4000);
--   v_cnt    NUMBER;
   
BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);

   -- validate product program associations
   p_validate ('BIVV_PGM_PROD_VAL_V', v_msg);

   IF length(v_msg) > 0 THEN
      RAISE E_InvalidData;
   END IF;

   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN E_InvalidData THEN
      pkg_util.p_saveLog('Invalid data in: '||v_msg, c_program, v_module);
      pkg_util.p_saveLog('END', c_program, v_module);
      RAISE;

   WHEN OTHERS THEN
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;

/*
   Validates URA data
*/
PROCEDURE p_validate_ura IS

   v_module    conv_log_t.module%TYPE := 'p_validate_ura';
   v_msg    VARCHAR2 (4000);
--   v_cnt    NUMBER;
   
BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);

   -- validate URAs
   p_validate ('BIVV_PUR_FINAL_RESULTS_VAL_V', v_msg);

   IF length(v_msg) > 0 THEN
      RAISE E_InvalidData;
   END IF;

   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN E_InvalidData THEN
      pkg_util.p_saveLog('Invalid data in: '||v_msg, c_program, v_module);
      pkg_util.p_saveLog('END', c_program, v_module);
      RAISE;

   WHEN OTHERS THEN
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;

/* 
   Validates claims data
*/
PROCEDURE p_validate_claims IS

   v_module    conv_log_t.module%TYPE := 'p_validate_claims';
   v_msg    VARCHAR2 (4000);
--   v_cnt    NUMBER;
   
BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);

   -- validate product program associations
   p_validate ('BIVV_PGM_PROD_VAL_V', v_msg);

   -- validate claim headers
   p_validate ('BIVV_MEDI_CLAIM_VAL_V', v_msg);

   -- validate all claim lines
   p_validate ('BIVV_MEDI_CLAIM_LINE_VAL_V', v_msg);

   -- validate all paid lines
   p_validate ('BIVV_MEDI_PAID_LINE_VAL_V', v_msg);

   -- validate disputed lines view
   p_validate ('BIVV_DSPT_VAL_V', v_msg);

   IF length(v_msg) > 0 THEN
      RAISE E_InvalidData;
   END IF;

   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN E_InvalidData THEN
      pkg_util.p_saveLog('Invalid data in: '||v_msg, c_program, v_module);
      pkg_util.p_saveLog('END', c_program, v_module);
      RAISE;

   WHEN OTHERS THEN
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;

/*
Target Table:reb_claim_t
Source object:bivv_medi_claim_v
Filter Condition:All
*/
PROCEDURE p_load_reb_claim IS
   v_module    conv_log_t.module%TYPE := 'p_load_reb_claim';
   
BEGIN
   pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO reb_claim_t (
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
      v.pgm_id,
      v.ndc_lbl,
      v.period_id,
      v.reb_clm_seq_no,
      v.co_id,
      v.subm_typ_cd,
      v.reb_claim_stat_cd,
      v.pstmrk_dt,
      v.pyment_pstmrk_dt,
      v.rcv_dt,
      v.input_dt,
      v.extd_due_dt,
      v.invc_num,
      v.tot_claim_units,
      v.valid_dt,
      v.prelim_run_dt,
      v.prelim_sent_dt,
      v.prelim_apprv_dt,
      v.final_run_dt,
      v.dspt_prelim_sent_dt,
      v.dspt_prelim_apprv_dt,
      v.corr_int_flg,
      SYSDATE AS create_dt,
      c_userid_BIVV AS mod_by,
      v.attachment_ref_id
   FROM bivv_medi_claim_v v;

   pkg_util.p_saveLog('Inserted REB_CLAIM_T count: '||SQL%ROWCOUNT, c_program, v_module);
   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
   pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;
/*
Target Table:reb_clm_ln_itm_t
Source object:bivv_medi_claim_line_v
Filter Condition:loads the data from "bivv_medi_claim_line_v" for the transaction line item
                  that have entries in reb_claim_t table
*/
PROCEDURE p_load_reb_claim_line IS
   v_module    conv_log_t.module%TYPE := 'p_load_reb_claim_line';
BEGIN
   pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO reb_clm_ln_itm_t
     (
      pgm_id ,
      ndc_lbl ,
      period_id ,
      reb_clm_seq_no ,
      co_id ,
      ln_itm_seq_no ,
      claim_units ,
      claim_amt ,
      reb_claim_ln_itm_stat_cd ,
      script_cnt ,
      pgm_pur ,
      reimbur_amt ,
      corr_flg ,
      item_prod_fmly_ndc ,
      item_prod_mstr_ndc ,
      create_dt ,
      mod_by,
      nonmed_reimbur_amt ,
      total_reimbur_amt
     )
   SELECT cl.pgm_id ,
      cl.ndc_lbl ,
      cl.period_id ,
      cl.reb_clm_seq_no ,
      cl.co_id ,
      cl.ln_itm_seq_no ,
      cl.submitem_units ,
      cl.submitem_asking_dollars ,
      cl.reb_claim_ln_itm_stat_cd ,
      cl.submitem_rx ,
      cl.submitem_rpu ,
      cl.reimbur_amt ,
      cl.corr_flg ,
      cl.item_prod_fmly_ndc ,
      cl.item_prod_mstr_ndc ,
      SYSDATE AS create_dt ,
      c_userid_BIVV AS mod_by ,
      cl.nonmed_reimbur_amt ,
      cl.total_reimbur_amt
   FROM bivv_medi_claim_line_v cl,
      reb_claim_t c
   WHERE c.pgm_id = cl.pgm_id
      AND c.period_id = cl.period_id
      AND c.ndc_lbl = cl.ndc_lbl
      AND cl.reb_claim_ln_itm_stat_cd = c.reb_claim_stat_cd;

   pkg_util.p_saveLog('Inserted REB_CLM_LN_ITM_T count: '||SQL%ROWCOUNT, c_program, v_module);
   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;
/*
*/
PROCEDURE p_load_reb_valid_claim IS
   v_module    conv_log_t.module%TYPE := 'p_load_reb_valid_claim';
BEGIN
   pkg_util.p_saveLog('START', c_program, v_module);
   INSERT INTO valid_claim_t
     (
      pgm_id ,
      ndc_lbl ,
      period_id ,
      reb_clm_seq_no ,
      co_id ,
      ln_itm_seq_no ,
      ndc_prod ,
      ndc_pckg ,
      dspt_flg ,
      claim_units ,
      claim_amt ,
      script_cnt ,
      pgm_pur ,
      reimbur_amt ,
      corr_flg,
      create_dt,
      mod_by
     )
   SELECT c.pgm_id ,
      c.ndc_lbl ,
      c.period_id ,
      c.reb_clm_seq_no ,
      c.co_id ,
      c.ln_itm_seq_no ,
      c.ndc_prod ,
      c.ndc_pckg ,
      c.dspt_flg ,
      c.claim_units ,
      c.claim_amt ,
      c.script_cnt ,
      c.pgm_pur ,
      c.reimbur_amt ,
      c.corr_flg,
      SYSDATE AS create_dt,
      c_userid_bivv AS mod_by
   FROM bivv_valid_claim_v c;


   pkg_util.p_saveLog('Inserted VALID_CLAIM_T count: '||SQL%ROWCOUNT, c_program, v_module);
   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;
/*
Target Table:dspt_t, dspt_rsn_t
Source object:
bivv_dspt_v ---> pulls all transaaction from the view "Bivv_medi_claim_line_v" containing dspt_flag='Y'
BIVV_DSPT_RSN_V--> pulls all transaaction from the view "bivv_dspt_v"
Filter Condition: All
*/
PROCEDURE p_load_reb_dspt_claim IS
   v_module    conv_log_t.module%TYPE := 'p_load_reb_dspt_claim';
BEGIN
   pkg_util.p_saveLog('START', c_program, v_module);
   INSERT INTO dspt_t
     (
     pgm_id ,
     ndc_lbl ,
     period_id ,
     reb_clm_seq_no ,
     co_id ,
     ln_itm_seq_no ,
     dspt_seq_no ,
     ndc_prod ,
     ndc_pckg ,
     paid_units ,
     dspt_units ,
     wrt_off_units ,
     dspt_dt ,
     create_dt,
     mod_by
     )
   SELECT c.pgm_id ,
     c.ndc_lbl ,
     c.period_id ,
     c.reb_clm_seq_no ,
     c.co_id ,
     c.ln_itm_seq_no ,
     c.dspt_seq_no,
     c.ndc_prod ,
     c.ndc_pckg ,
     c.paid_units ,
     c.dspt_units ,
     c.wrt_off_units,
     SYSDATE AS dspt_dt,
     SYSDATE AS create_dt,
     c_userid_bivv AS mod_by
   FROM bivv_dspt_v c;

   pkg_util.p_saveLog('Inserted DSPT_T count: '||SQL%ROWCOUNT, c_program, v_module);

   INSERT INTO dspt_rsn_t
     (
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
     mod_by
     )
   SELECT c.rpr_dspt_rsn_id,
     c.pgm_id,
     c.ndc_lbl,
     c.period_id,
     c.reb_clm_seq_no,
     c.co_id,
     c.ln_itm_seq_no,
     c.dspt_seq_no,
     c.dspt_priority,
     SYSDATE AS create_dt,
     c_userid_BIVV as mod_by
     FROM  bivv_dspt_rsn_v c;

   pkg_util.p_saveLog('Inserted DSPT_RSN_T count: '||SQL%ROWCOUNT, c_program, v_module);
   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END p_load_reb_dspt_claim;
/*
Target Table:valid_claim_chk_req_t, dspt_check_req_t
Source object:
bivv_valid_claim_chk_req_v ---> pulls all transaaction from the view "bivv_valid_claim_v" containing dspt_flag='N'
bivv_dspt_check_req_v-->  pulls all transaaction from the view "bivv_valid_claim_v" containing dspt_flag='N'(Need to verify with MARIO)
Filter Condition: All
*/
PROCEDURE p_load_check_req_tbl IS
/* Cursor to pull the valid and dispute claim item*/
   v_module    conv_log_t.module%TYPE := 'p_load_check_req_tbl';

   CURSOR csr_check_req IS
      WITH v AS (
      SELECT pgm_id, period_id, ndc_lbl, co_id, reb_clm_seq_no FROM valid_claim_t v
      UNION
      SELECT pgm_id, period_id, ndc_lbl, co_id, reb_clm_seq_no FROM dspt_t v
      )
      SELECT pgm_id, period_id, co_id, reb_clm_seq_no, ndc_lbl
      FROM v
      GROUP BY pgm_id, period_id, ndc_lbl, co_id, reb_clm_seq_no
      ORDER BY pgm_id, period_id, ndc_lbl, co_id, reb_clm_seq_no;
  
   v_check_id  hcrs.check_req_t.check_id%TYPE;
   v_valid_claim_rcount  NUMBER(5):=0;
   v_dspt_claim_rcount  NUMBER(5):=0;
   v_check_id_rcount NUMBER(5):=0;
   
BEGIN
   pkg_util.p_saveLog('START', c_program, v_module);


   FOR check_req_rec IN csr_check_req
   LOOP
   
      -- get Check Id Sequence
      SELECT hcrs.check_s.NEXTVAL
      INTO v_check_id
      FROM dual;

      INSERT INTO valid_claim_chk_req_t (
         pgm_id ,
         ndc_lbl ,
         period_id ,
         reb_clm_seq_no ,
         co_id ,
         ln_itm_seq_no ,
         check_id ,
         ndc_prod ,
         ndc_pckg ,
         paid_amt ,
         int_amt ,
         int_owed_amt ,
         int_wrt_off_amt ,
         int_owed_flg ,
         create_dt ,
         mod_by)
      SELECT c.pgm_id ,
         c.ndc_lbl ,
         c.period_id ,
         c.reb_clm_seq_no ,
         c.co_id ,
         c.ln_itm_seq_no ,
         v_check_id  ,
         c.ndc_prod ,
         c.ndc_pckg ,
         c.claim_amt ,
         c.int_amt ,
         c.int_owed_amt ,
         c.int_wrt_off_amt ,
         c.int_owed_flg ,
         SYSDATE AS create_dt,
         c_userid_BIVV as mod_by
      FROM bivv_valid_claim_chk_req_v c
      WHERE 
         c.pgm_id = check_req_rec.pgm_id AND
         c.period_id = check_req_rec.period_id AND
         c.ndc_lbl = check_req_rec.ndc_lbl AND
         c.co_id = check_req_rec.co_id AND
         c.reb_clm_seq_no = check_req_rec.reb_clm_seq_no;

      v_valid_claim_rcount := v_valid_claim_rcount + SQL%ROWCOUNT;
   
      INSERT INTO dspt_check_req_t (
         pgm_id ,
         ndc_lbl ,
         period_id ,
         reb_clm_seq_no ,
         co_id ,
         ln_itm_seq_no ,
         dspt_seq_no ,
         check_id ,
         ndc_prod ,
         ndc_pckg ,
         paid_amt ,
         int_amt ,
         int_owed_amt ,
         int_wrt_off_amt ,
         int_owed_flg ,
         create_dt ,
         mod_by)
      SELECT c.pgm_id ,
         c.ndc_lbl ,
         c.period_id ,
         c.reb_clm_seq_no ,
         c.co_id ,
         c.ln_itm_seq_no ,
         c.dspt_seq_no ,
         v_check_id ,
         c.ndc_prod ,
         c.ndc_pckg ,
         c.claim_amt ,
         c.int_amt ,
         c.int_owed_amt ,
         c.int_wrt_off_amt ,
         c.int_owed_flg ,
         SYSDATE AS create_dt,
         c_userid_BIVV as mod_by
      FROM bivv_dspt_check_req_v c
      WHERE 
         c.pgm_id = check_req_rec.pgm_id AND
         c.period_id = check_req_rec.period_id AND
         c.ndc_lbl = check_req_rec.ndc_lbl AND
         c.co_id = check_req_rec.co_id AND
         c.reb_clm_seq_no = check_req_rec.reb_clm_seq_no;
           
      v_dspt_claim_rcount := v_dspt_claim_rcount + SQL%ROWCOUNT;
   
      INSERT INTO check_req_t (
         check_id ,
         check_req_stat_cd ,
         pymnt_catg_cd ,
         credit_num ,
         check_req_amt ,
         cr_bal ,
         check_input_dt ,
         check_dt ,
         conf_dt ,
         prcss_dt ,
         mail_dt ,
         check_req_dt ,
         pgm_id ,
         co_id ,
         int_sel_meth_cd ,
         man_int_amt ,
         rosi_flg ,
         pqas_flg ,
         est_check_mail_dt ,
         cmt_txt,
         create_dt ,
         mod_by
      )
      SELECT 
         c.check_id,
         c.check_req_stat_cd ,
         c.pymnt_catg_cd ,
         c.credit_num ,
         c.check_req_amt ,
         c.cr_bal ,
         c.check_input_dt ,
         c.check_req_dt ,
         c.conf_dt ,
         c.pcrss_dt ,
         c.mail_dt ,
         c.check_dt ,
         c.pgm_id ,
         c.co_id ,
         c.int_sel_meth_cd ,
         c.man_int_amt ,
         c.rosi_flg ,
         c.pqas_flg ,
         c.est_check_mail_dt ,
         c.cmt_txt,
         SYSDATE AS create_dt,
         c_userid_BIVV AS mod_by
      FROM BIVV_CHECK_REQ_V c
      WHERE c.check_id = v_check_id;

      v_check_id_rcount := v_check_id_rcount + SQL%ROWCOUNT;
   
   END LOOP;
   
   pkg_util.p_saveLog('Inserted count in table valid_claim_chk_req_t: '||v_valid_claim_rcount, c_program, v_module);
   pkg_util.p_saveLog('Inserted count in table  dspt_check_req_t: '||v_dspt_claim_rcount, c_program, v_module);
   pkg_util.p_saveLog('Inserted count in table check_req_t: '||v_check_id_rcount, c_program, v_module);
   pkg_util.p_saveLog('END ', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END p_load_check_req_tbl;


/*
Target Table:check_t
Source object:check_req_t
Filter Condition: All
considering BIVV2020 as check_num
*/
PROCEDURE p_load_check_t_tbl IS
   v_module    conv_log_t.module%TYPE := 'p_load_check_t_tbl';
BEGIN
   pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO check_t (
      check_id,
      check_num,
      check_amt,
      create_dt,
      mod_by)
   SELECT
      check_id,
      'BIVV2020',
      cr.check_req_amt,
      SYSDATE AS create_dt,
      c_userid_BIVV as mod_by
   FROM check_req_t cr;

   pkg_util.p_saveLog('Inserted CHECK_T count: '||SQL%ROWCOUNT, c_program, v_module);
   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END p_load_check_t_tbl;
/*
Target Table:check_apprvl_grp_apprvl_t, check_apprvl_grp_t, check_apprvl_grp_chk_xref_t
Source object:bivv_check_appr_grp_v-->as check_id is required loads data from check_req_t
              and pulls period from valid_claim_chk_req_t(dispute_flag='N')
Filter Condition: All
for check_apprvl_grp_apprvl_t table hard coded values are inserted as per GNZ standard
*/
PROCEDURE p_load_check_appr_grp IS

   v_module    CONSTANT conv_log_t.module%TYPE := 'p_load_check_appr_grp';

--   CURSOR csr_check_appr_grp IS
--   SELECT DISTINCT 
--      c.co_id ,
--      c.pgm_id,
--      c.apprvl_grp_desc ,
--      c.apprvl_amt ,
--      c.apprvl_status_cd ,
--      c.sap_vendor_num,
--      c.attachment_ref_id,
--      c.check_id
--   FROM bivv_check_appr_grp_v c;
   
   v_check_appr_grp_id check_apprvl_grp_t.apprvl_grp_id%TYPE;

   -- Variables for fetching  Rowcount
   v_app_rcount  NUMBER := 0;
   v_app_grp_rcount  NUMBER := 0;
   v_xref_rcount NUMBER := 0; 
   
BEGIN
   pkg_util.p_saveLog('START', c_program, v_module);
   
   FOR check_rec IN (
      SELECT * 
      FROM bivv_check_appr_grp_v
      ORDER BY check_id)
   LOOP

      SELECT hcrs.check_apprvl_grp_seq.NEXTVAL
      INTO  v_check_appr_grp_id
      FROM dual;
 
      INSERT INTO check_apprvl_grp_t (
         apprvl_grp_id,
         co_id,
         pgm_id,
         apprvl_grp_desc,
         apprvl_amt,
         apprvl_status_cd,
         ap_sent_dt,
         create_dt,
         create_by,
         mod_dt,
         mod_by)
      VALUES (
         v_check_appr_grp_id,
         check_rec.co_id,
         check_rec.pgm_id,
         check_rec.appr_grp_desc,
         check_rec.check_req_amt,
         'APS',
         SYSDATE,
         SYSDATE,
         c_userid_BIVV,
         SYSDATE,
         c_userid_BIVV);

      v_app_rcount := v_app_rcount + SQL%ROWCOUNT;

      INSERT INTO check_apprvl_grp_apprvl_t (
         apprvl_grp_id,
         apprvl_limit_id,
         apprvl_reason_cd,
         apprvr_id,
         apprvl_dt,
         comment_txt,
         create_dt,
         mod_by)
      VALUES (
         v_check_appr_grp_id,
         '1',
         'R',
         'HCRS',
         SYSDATE,
         'initial Bioverativ conversion',
         SYSDATE ,
         c_userid_BIVV);

      v_app_grp_rcount := v_app_grp_rcount + SQL%ROWCOUNT;

      INSERT INTO check_apprvl_grp_chk_xref_t (
         apprvl_grp_id,
         check_id,
         create_dt,
         mod_by)
      VALUES (
         v_check_appr_grp_id,
         check_rec.check_id,
         SYSDATE,
         c_userid_BIVV);

      v_xref_rcount:=v_xref_rcount + SQL%ROWCOUNT;
       
   END LOOP;

   pkg_util.p_saveLog('Inserted count check_apprvl_grp_t: '||v_app_rcount, c_program, v_module);
   pkg_util.p_saveLog('Inserted count check_apprvl_grp_apprvl_t: '||v_app_rcount, c_program, v_module);
   pkg_util.p_saveLog('Inserted count check_apprvl_grp_chk_xref_t: '||v_app_rcount, c_program, v_module);
   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END p_load_check_appr_grp;

/*
Target Table:prod_mstr_pgm_t
Source object:bivv_pgm_prod_v
Filter Condition: All
*/
PROCEDURE p_load_prod_pgm IS
   v_module    conv_log_t.module%TYPE := 'p_load_prod_pgm';
BEGIN
   pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO prod_mstr_pgm_t 
     (
       pgm_id,
       ndc_lbl,
       ndc_prod,
       ndc_pckg,
       eff_dt,
       end_dt,
       create_dt,
       mod_dt,
       mod_by
     )
   SELECT 
       pgm_id,
       ndc_lbl,
       ndc_prod,
       ndc_pckg,
       eff_dt,
       end_dt,
       SYSDATE AS create_dt,
       NULL AS mod_dt,
       c_userid_BIVV AS mod_by        
   FROM bivv_pgm_prod_v;

   pkg_util.p_saveLog('Inserted PROD_MSTR_PGM_T count: '||SQL%ROWCOUNT, c_program, v_module);
   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;
--------------------------------------------------- URAs -----------------------------------------------------
PROCEDURE p_load_ura IS
   v_module    conv_log_t.module%TYPE := 'p_load_ura_calc';
BEGIN
   pkg_util.p_saveLog('START', c_program, v_module);

   INSERT INTO bivv.pur_final_results_t (
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
      SYSDATE,
      c_userid_BIVV,
      src_sys,
      src_sys_unique_id
   FROM bivv.bivv_pur_final_results_v;

   pkg_util.p_saveLog('Inserted PUR_FINAL_RESULTS_T count: '||SQL%ROWCOUNT, c_program, v_module);
   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
      RAISE;
END;

/*
   Perform BIVV phase 1 activities:
      1. Product/Program eligibility load
*/
PROCEDURE p_run_phase1 (a_trunc_flg VARCHAR2 DEFAULT 'Y', a_valid_flg VARCHAR2 DEFAULT 'Y') IS
   v_module    conv_log_t.module%TYPE := 'p_run_phase1';
BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);
   pkg_util.p_saveLog('Parameters passed -> a_trunc_flg:'||a_trunc_flg||', a_valid_flg:'||a_valid_flg, c_program, v_module);

   -- validate source data
   IF nvl(a_valid_flg, 'Y') = 'Y' THEN
      p_validate_prodelig;
   END IF;

   -- truncate all stage tables to prepare for new load if requested
   IF nvl(a_trunc_flg, 'Y') = 'Y' THEN
      pkg_util.p_trunc_tbl('PROD_MSTR_PGM_T');   
   END IF;

   -- proceed to loading the data
   p_load_prod_pgm;

   COMMIT;

   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN E_InvalidData THEN
      ROLLBACK;
      pkg_util.p_saveLog('END', c_program, v_module);

   WHEN OTHERS THEN
      ROLLBACK;
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
END;

/*
   Perform BIVV phase 1 activities:
      1. migrates product/program eligibilit
*/
PROCEDURE p_run_phase2 (a_trunc_flg VARCHAR2 DEFAULT 'Y', a_valid_flg VARCHAR2 DEFAULT 'Y') IS
   v_module    conv_log_t.module%TYPE := 'p_run_phase2';
BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);
   pkg_util.p_saveLog('Parameters passed -> a_trunc_flg:'||a_trunc_flg||', a_valid_flg:'||a_valid_flg, c_program, v_module);

   -- validate source data
   IF nvl(a_valid_flg, 'Y') = 'Y' THEN
      p_validate_ura;
   END IF;

   -- truncate all stage tables to prepare for new load if requested
   IF nvl(a_trunc_flg, 'Y') = 'Y' THEN
      pkg_util.p_trunc_tbl('PUR_FINAL_RESULTS_T');
   END IF;

   -- proceed to loading the data
   p_load_ura;

   COMMIT;

   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN E_InvalidData THEN
      ROLLBACK;
      pkg_util.p_saveLog('END', c_program, v_module);

   WHEN OTHERS THEN
      ROLLBACK;
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
END;

/*
   Perform BIVV phase 3 activities:
      1. migrates claims
      2. delta URAs (TBD)
*/
PROCEDURE p_run_phase3 (a_trunc_flg VARCHAR2 DEFAULT 'Y', a_valid_flg VARCHAR2 DEFAULT 'Y') IS
   v_module    conv_log_t.module%TYPE := 'p_run_phase3';
BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);
   pkg_util.p_saveLog('Parameters passed -> a_trunc_flg:'||a_trunc_flg||', a_valid_flg:'||a_valid_flg, c_program, v_module);

   -- validate source data
   IF nvl(a_valid_flg, 'Y') = 'Y' THEN
      p_validate_claims;
   END IF;

   -- truncate all stage tables to prepare for new load if requested
   IF nvl(a_trunc_flg, 'Y') = 'Y' THEN
      pkg_util.p_trunc_tbl('PROD_MSTR_PGM_T');   
      pkg_util.p_trunc_tbl('CHECK_APPRVL_GRP_CHK_XREF_T');
      pkg_util.p_trunc_tbl('CHECK_APPRVL_GRP_APPRVL_T');
      pkg_util.p_trunc_tbl('CHECK_APPRVL_GRP_T');
      pkg_util.p_trunc_tbl('DSPT_CHECK_REQ_T');
      pkg_util.p_trunc_tbl('VALID_CLAIM_CHK_REQ_T');
      pkg_util.p_trunc_tbl('CHECK_T');
      pkg_util.p_trunc_tbl('CHECK_REQ_T');
      pkg_util.p_trunc_tbl('DSPT_RSN_T');
      pkg_util.p_trunc_tbl('DSPT_T');      
      pkg_util.p_trunc_tbl('VALID_CLAIM_T');
      pkg_util.p_trunc_tbl('REB_CLM_LN_ITM_T');
      pkg_util.p_trunc_tbl('REB_CLAIM_T');
   END IF;

   -- proceed to loading the data
   p_load_prod_pgm;
   p_load_reb_claim;
   p_load_reb_claim_line;
   p_load_reb_valid_claim;
   p_load_reb_dspt_claim;
   p_load_check_req_tbl;  
   p_load_check_t_tbl;
   p_load_check_appr_grp;

   COMMIT;

   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN E_InvalidData THEN
      ROLLBACK;
      pkg_util.p_saveLog('END', c_program, v_module);

   WHEN OTHERS THEN
      ROLLBACK;
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
END;

PROCEDURE p_process_WAC_price (a_prc ic_pricing_delta_v%ROWTYPE) IS 

   v_module    conv_log_t.module%TYPE := 'p_process_WAC_price';
   v_cnt       NUMBER;
BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);

   SELECT COUNT(*)
   INTO v_cnt
   FROM hcrs.prod_price_t t
   WHERE t.prod_price_typ_cd = 'LP'
      AND t.ndc_lbl = a_prc.ndc_lbl
      AND t.ndc_prod = a_prc.ndc_prod
      AND t.ndc_pckg = a_prc.ndc_pckg
      AND t.eff_dt = a_prc.wac_strt_dt;

--   pkg_util.p_saveLog('LP count: '||v_cnt, c_program, v_module);
   IF v_cnt = 0 THEN 
      pkg_util.p_saveLog('LP not found', c_program, v_module);

      INSERT INTO bivv.prod_price_t
         (ndc_lbl, ndc_prod, ndc_pckg, prod_price_typ_cd, eff_dt, end_dt, price_amt, rec_src_ind) 
      VALUES
         (a_prc.ndc_lbl, a_prc.ndc_prod, a_prc.ndc_pckg, 'LP', a_prc.wac_strt_dt, a_prc.wac_end_dt, a_prc.wac, 'M');

      pkg_util.p_saveLog('Inserted: '||SQL%ROWCOUNT, c_program, v_module);

   END IF;

   SELECT COUNT(*)
   INTO v_cnt
   FROM hcrs.prod_price_t t
   WHERE t.prod_price_typ_cd = 'WAC'
      AND t.ndc_lbl = a_prc.ndc_lbl
      AND t.ndc_prod = a_prc.ndc_prod
      AND t.ndc_pckg = a_prc.ndc_pckg
      AND t.eff_dt = a_prc.wac_strt_dt;

--   pkg_util.p_saveLog('WAC count: '||v_cnt, c_program, v_module);
   IF v_cnt = 0 THEN 
      pkg_util.p_saveLog('WAC not found', c_program, v_module);

      INSERT INTO bivv.prod_price_t
         (ndc_lbl, ndc_prod, ndc_pckg, prod_price_typ_cd, eff_dt, end_dt, price_amt, rec_src_ind) 
      VALUES
         (a_prc.ndc_lbl, a_prc.ndc_prod, a_prc.ndc_pckg, 'WAC', a_prc.wac_strt_dt, a_prc.wac_end_dt, a_prc.wac, 'M');

      pkg_util.p_saveLog('Inserted: '||SQL%ROWCOUNT, c_program, v_module);
   END IF;

   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
END;
/*
*/
FUNCTION f_create_prfl (
   a_prcss_typ    hcrs.prfl_t.prcss_typ_cd%TYPE,
   a_agency       hcrs.prfl_t.agency_typ_cd%TYPE,
   a_prfl_nm      hcrs.prfl_t.prfl_nm%TYPE,
   a_tim_per_cd   hcrs.prfl_t.tim_per_cd%TYPE,
   a_begn_dt      hcrs.prfl_t.begn_dt%TYPE,
   a_end_dt       hcrs.prfl_t.end_dt%TYPE) RETURN hcrs.prfl_t.prfl_id%TYPE IS

   v_module       conv_log_t.module%TYPE := 'f_create_prfl';
   v_prfl_id      hcrs.prfl_t.prfl_id%TYPE;

BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);

   -- header record
   INSERT INTO prfl_t 
      (prfl_id, snpsht_id, prfl_stat_cd, agency_typ_cd, tim_per_cd
      ,prcss_typ_cd, prfl_nm, begn_dt, end_dt, copy_hist_ind, prelim_ind, mtrx_ind)
   VALUES
      (hcrs.prfl_s.nextval,0, hcrs.pkg_constants.cs_prfl_stat_transmitted_cd, a_agency, a_tim_per_cd
      ,a_prcss_typ, a_prfl_nm, a_begn_dt, a_end_dt, 'N', 'N', 'N')
   RETURNING prfl_id INTO v_prfl_id;

   pkg_util.p_saveLog('PRFL_T inserted: '||a_prfl_nm||' ('||v_prfl_id||'): '||SQL%ROWCOUNT, c_program, v_module);

   -- company
   INSERT INTO prfl_co_t (prfl_id, co_id)
   VALUES (v_prfl_id, 121);
   pkg_util.p_saveLog('PRFL_CO_T inserted: '||SQL%ROWCOUNT, c_program, v_module);


   -- determine and insert calc type
   INSERT INTO prfl_calc_typ_t (prfl_id, calc_typ_cd, calc_mthd_cd)
   WITH v AS (
      SELECT 'MED_MTHLY' AS prcss_typ, 'AMP' AS calc_typ, 'ACTL' AS calc_mthd FROM dual
      UNION
      SELECT 'MED_QTRLY' AS prcss_typ, 'AMP' AS calc_typ, 'ACTL' AS calc_mthd FROM dual
      UNION
      SELECT 'MED_QTRLY' AS prcss_typ, 'BP' AS calc_typ, 'ACTL' AS calc_mthd FROM dual
      UNION
      SELECT 'MEDICARE_QTRLY' AS prcss_typ, 'ASP' AS calc_typ, 'ACTL-BIOV' AS calc_mthd FROM dual
      UNION
      SELECT 'VA_QTRLY' AS prcss_typ, 'NFAMP' AS calc_typ, 'ACTL-BIOV' AS calc_mthd FROM dual
      UNION
      SELECT 'VA_ANNL' AS prcss_typ, 'NFAMP' AS calc_typ, 'ACTL' AS calc_mthd FROM dual
      UNION
      SELECT 'VA_ANNL' AS prcss_typ, 'FCP' AS calc_typ, 'ACTL' AS calc_mthd FROM dual)
   SELECT p.prfl_id, v.calc_typ, v.calc_mthd
   FROM prfl_t p, v
   WHERE p.prcss_typ_cd = v.prcss_typ
      AND p.prfl_id = v_prfl_id;

   pkg_util.p_saveLog('PRFL_CALC_TYP_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   -- copy variable from the latest profile bivv profile for the same processing type
   INSERT INTO prfl_var_t (prfl_id, agency_typ_cd, var_cd, val_txt, prcss_typ_cd)
   SELECT v_prfl_id, v.agency_typ_cd, v.var_cd, v.val_txt, v.prcss_typ_cd
   FROM hcrs.prfl_var_t v
   WHERE v.prfl_id = (
      SELECT MAX(prfl_id)
      FROM hcrs.prfl_t p
      WHERE p.prcss_typ_cd = a_prcss_typ);
   pkg_util.p_saveLog('PRFL_VAR_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   pkg_util.p_saveLog('END', c_program, v_module);

   RETURN v_prfl_id;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);

END;

/*
*/
FUNCTION f_get_profile (
   a_prcss_typ hcrs.prfl_t.prcss_typ_cd%TYPE,
   a_start_dt  hcrs.prfl_t.begn_dt%TYPE,
   a_end_dt    hcrs.prfl_t.end_dt%TYPE) RETURN hcrs.prfl_t.prfl_id%TYPE IS

   v_module       conv_log_t.module%TYPE := 'f_get_profile';
   v_prfl_id      hcrs.prfl_t.prfl_id%TYPE;
   v_tim_per_cd   hcrs.prfl_t.tim_per_cd%TYPE;
   v_agency       hcrs.prfl_t.agency_typ_cd%TYPE;
   v_prfl_nm      hcrs.prfl_t.prfl_nm%TYPE;

BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);

   CASE 
      -- monthly
      WHEN a_prcss_typ = hcrs.pkg_constants.cs_med_prcssng_typ_mthly THEN 
         v_tim_per_cd := to_char(a_start_dt, 'yyyy"Q"q"M"mm');
         v_agency := hcrs.pkg_constants.cs_atp_med_cd;
         v_prfl_nm := TO_CHAR(a_start_dt,'FMYYYY Month') || ' AMP '||c_prfl_nm_suffix;

      -- quarterly
      WHEN a_prcss_typ = hcrs.pkg_constants.cs_med_prcssng_typ_qtrly THEN
         v_tim_per_cd := to_char(a_start_dt, 'yyyy"Q"q');
         v_agency := hcrs.pkg_constants.cs_atp_med_cd;
         v_prfl_nm := TO_CHAR(a_start_dt,'yyyy"Q"q') || ' AMP/BP '||c_prfl_nm_suffix;

      WHEN a_prcss_typ = hcrs.pkg_constants.cs_medicare_prcssng_typ_qtrly THEN
         v_tim_per_cd := to_char(a_start_dt, 'yyyy"Q"q');
         v_agency := hcrs.pkg_constants.cs_atp_medicare_cd;
         v_prfl_nm := TO_CHAR(a_start_dt,'yyyy"Q"q') || ' ASP '||c_prfl_nm_suffix;

      WHEN a_prcss_typ = hcrs.pkg_constants.cs_va_prcssng_typ_qtrly THEN
         v_tim_per_cd := to_char(a_start_dt, 'yyyy"Q"q');
         v_agency := hcrs.pkg_constants.cs_atp_va_cd;
         v_prfl_nm := TO_CHAR(a_start_dt,'yyyy"Q"q') || ' NFAMP '||c_prfl_nm_suffix;

      --annual
      WHEN a_prcss_typ = hcrs.pkg_constants.cs_va_prcssng_typ_annl THEN 
         v_tim_per_cd := to_char(a_start_dt, 'yyyy');
         v_agency := hcrs.pkg_constants.cs_atp_va_cd;
         v_prfl_nm := TO_CHAR(a_start_dt,'yyyy') || ' NFAMP/FCP '||c_prfl_nm_suffix;

   END CASE;

   pkg_util.p_saveLog('Looking for a_prcss_typ: '||a_prcss_typ||', v_tim_per_cd: '||v_tim_per_cd, c_program, v_module);

   BEGIN
      -- see if HCRS already has matching profile for this time period
      SELECT prfl_id
      INTO v_prfl_id
      FROM hcrs.prfl_t p
      WHERE p.prfl_stat_cd = hcrs.pkg_constants.cs_prfl_stat_transmitted_cd
         AND p.tim_per_cd = v_tim_per_cd
         AND p.prcss_typ_cd = a_prcss_typ
         AND p.prfl_nm LIKE '%'||c_prfl_nm_suffix||'%';

   EXCEPTION
      WHEN no_data_found THEN
         -- see if BIVV already has one
         SELECT prfl_id
         INTO v_prfl_id
         FROM prfl_t p
         WHERE p.prfl_stat_cd = hcrs.pkg_constants.cs_prfl_stat_transmitted_cd
            AND p.tim_per_cd = v_tim_per_cd
            AND p.prcss_typ_cd = a_prcss_typ
            AND p.prfl_nm LIKE '%'||c_prfl_nm_suffix||'%';
   END;
   
   pkg_util.p_saveLog('END', c_program, v_module);

   RETURN v_prfl_id;

EXCEPTION
   WHEN no_data_found THEN
      -- create a new profile
      RETURN f_create_prfl (a_prcss_typ, v_agency, v_prfl_nm, v_tim_per_cd, a_start_dt, a_end_dt);

   WHEN OTHERS THEN
      ROLLBACK;
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);

END;

/*
*/
PROCEDURE p_process_GP_price (a_prc ic_pricing_delta_v%ROWTYPE) IS 

   v_module    conv_log_t.module%TYPE := 'p_process_GP_price';
--   v_cnt       NUMBER;
--   v_period_id hcrs.period_t.period_id%TYPE;
   v_prfl_id   hcrs.prfl_t.prfl_id%TYPE;
   v_start_dt  DATE;
   v_end_dt    DATE;
   v_skip      BOOLEAN;

BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);

   -- process prod transmission table (only AMP/BP quarterly)
   INSERT INTO bivv.prod_trnsmsn_t 
      (ndc_lbl, ndc_prod, period_id, trnsmsn_seq_no
      ,prod_trnsmsn_stat_cd, prod_trnsmsn_rsn_cd
      ,amp_amt, bp_amt, actv_flg, amp_apprvl_flg, bp_apprvl_flg, trnsmsn_dt, dra_baseline_flg)
   SELECT 
      a_prc.ndc_lbl, a_prc.ndc_prod, p.period_id, 1
      ,hcrs.pkg_constants.cs_prod_trnsmsn_trans_cd, hcrs.pkg_constants.cs_prod_trnsmsn_rsn_cd_qtr
      ,a_prc.amp_qtrly, a_prc.bp_qtrly, 'Y', 'Y', 'Y', SYSDATE, 'N'
   FROM hcrs.period_t p
   WHERE p.first_day_period = a_prc.qtr_start
      -- only AMP or BP is not zero
      AND (NVL(a_prc.amp_qtrly,0) != 0 OR NVL(a_prc.bp_qtrly,0) != 0)
      AND NOT EXISTS (
         SELECT 1 FROM hcrs.prod_trnsmsn_t t
         WHERE t.period_id = p.period_id
            AND t.ndc_lbl = a_prc.ndc_lbl
            AND t.ndc_prod = a_prc.ndc_prod);

   pkg_util.p_saveLog('PROD_TRNSMSN_T Inserted: '||SQL%ROWCOUNT, c_program, v_module);

   -- process pricing data that needs to be stored on profiles
   FOR prcss_cur IN (
      WITH v AS (
         SELECT hcrs.pkg_constants.cs_med_prcssng_typ_mthly AS prcss_typ, 1 AS period_ind FROM dual UNION
         SELECT hcrs.pkg_constants.cs_med_prcssng_typ_mthly AS prcss_typ, 2 AS period_ind FROM dual UNION
         SELECT hcrs.pkg_constants.cs_med_prcssng_typ_mthly AS prcss_typ, 3 AS period_ind FROM dual UNION
         SELECT hcrs.pkg_constants.cs_med_prcssng_typ_qtrly AS prcss_typ, 1 AS period_ind FROM dual UNION
         SELECT hcrs.pkg_constants.cs_medicare_prcssng_typ_qtrly AS prcss_typ, 1 AS period_ind FROM dual UNION
         SELECT hcrs.pkg_constants.cs_va_prcssng_typ_qtrly AS prcss_typ, 1 AS period_ind FROM dual UNION
         SELECT hcrs.pkg_constants.cs_va_prcssng_typ_annl AS prcss_typ, 1 AS period_ind FROM dual)
      SELECT prcss_typ, period_ind FROM v
      ORDER BY 1,2) LOOP

      -- reset skip flag
      v_skip := FALSE;

      -- get profile start and end dates
      CASE 
         WHEN prcss_cur.prcss_typ = hcrs.pkg_constants.cs_med_prcssng_typ_mthly AND prcss_cur.period_ind = 1 THEN
            v_start_dt := a_prc.amp_mth_1_strt_dt;
            v_end_dt := a_prc.amp_mth_1_end_dt;
            IF a_prc.amp_mth_1 IS NULL THEN v_skip := TRUE; END IF;

         WHEN prcss_cur.prcss_typ = hcrs.pkg_constants.cs_med_prcssng_typ_mthly AND prcss_cur.period_ind = 2 THEN
            v_start_dt := a_prc.amp_mth_2_strt_dt;
            v_end_dt := a_prc.amp_mth_2_end_dt;
            IF a_prc.amp_mth_2 IS NULL THEN v_skip := TRUE; END IF;
   
         WHEN prcss_cur.prcss_typ = hcrs.pkg_constants.cs_med_prcssng_typ_mthly AND prcss_cur.period_ind = 3 THEN
            v_start_dt := a_prc.amp_mth_3_strt_dt;
            v_end_dt := a_prc.amp_mth_3_end_dt;
            IF a_prc.amp_mth_3 IS NULL THEN v_skip := TRUE; END IF;

         WHEN prcss_cur.prcss_typ = hcrs.pkg_constants.cs_med_prcssng_typ_qtrly THEN
            v_start_dt := a_prc.qtr_start;
            v_end_dt := a_prc.qtr_end;
            IF a_prc.amp_qtrly IS NULL THEN v_skip := TRUE; END IF;
         
         WHEN prcss_cur.prcss_typ = hcrs.pkg_constants.cs_medicare_prcssng_typ_qtrly THEN
            v_start_dt := a_prc.qtr_start;
            v_end_dt := a_prc.qtr_end;
            IF a_prc.asp_qrtly IS NULL THEN v_skip := TRUE; END IF;

         WHEN prcss_cur.prcss_typ = hcrs.pkg_constants.cs_va_prcssng_typ_qtrly THEN
            v_start_dt := a_prc.qtr_start;
            v_end_dt := a_prc.qtr_end;
            IF a_prc.nfamp_qrtly IS NULL THEN v_skip := TRUE; END IF;

         WHEN prcss_cur.prcss_typ = hcrs.pkg_constants.cs_va_prcssng_typ_annl THEN
            v_start_dt := a_prc.anfamp_start;
            v_end_dt := a_prc.anfamp_end;
            IF a_prc.nfamp_annual IS NULL THEN v_skip := TRUE; END IF;

         ELSE
            RAISE E_InvalidPrcss;
      END CASE;

      -- if price is present then just continue to the next one
      IF v_skip THEN CONTINUE; END IF;

      v_prfl_id := f_get_profile (prcss_cur.prcss_typ, v_start_dt, v_end_dt);
      IF v_prfl_id IS NULL THEN
         RAISE E_InvalidPrfl;
      END IF;

      pkg_util.p_saveLog('prfl_id: '||v_prfl_id, c_program, v_module);

      -- prfl prod family (only for Medi profiles)
      INSERT INTO prfl_prod_fmly_t (prfl_id, ndc_lbl, ndc_prod)
      SELECT v_prfl_id, a_prc.ndc_lbl, a_prc.ndc_prod 
      FROM prfl_t p
      WHERE p.prfl_id = v_prfl_id
         AND p.prcss_typ_cd = prcss_cur.prcss_typ
         AND prcss_cur.prcss_typ IN (hcrs.pkg_constants.cs_med_prcssng_typ_mthly, hcrs.pkg_constants.cs_med_prcssng_typ_qtrly)
         AND NOT EXISTS (
            SELECT 1 
            FROM hcrs.prfl_prod_fmly_t t
            WHERE t.prfl_id = v_prfl_id AND t.ndc_lbl = a_prc.ndc_lbl AND t.ndc_prod = a_prc.ndc_prod);
      pkg_util.p_saveLog('PRFL_PROD_FMLY_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

      -- prfl prod
      INSERT INTO prfl_prod_t 
         (prfl_id, ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd, calc_stat_cd, shtdwn_ind)
      SELECT v_prfl_id, a_prc.ndc_lbl, a_prc.ndc_prod, a_prc.ndc_pckg, 'NONE' ,'COMPLETE', 'N' 
      FROM prfl_t p
      WHERE p.prfl_id = v_prfl_id
         AND p.prcss_typ_cd = prcss_cur.prcss_typ
         AND NOT EXISTS (
            SELECT 1 
            FROM hcrs.prfl_prod_t t
            WHERE t.prfl_id = v_prfl_id AND t.ndc_lbl = a_prc.ndc_lbl AND t.ndc_prod = a_prc.ndc_prod AND t.ndc_pckg = a_prc.ndc_pckg);
      pkg_util.p_saveLog('PRFL_PROD_T inserted: '||SQL%ROWCOUNT, c_program, v_module);
   
      -- prfl calc prod fmly (only for Medi profiles)
      INSERT INTO prfl_calc_prod_fmly_t
         (prfl_id, calc_typ_cd, ndc_lbl, ndc_prod, pri_whls_mthd_cd)
      SELECT t.prfl_id, t.calc_typ_cd, a_prc.ndc_lbl, a_prc.ndc_prod, 'NONE'
      FROM prfl_calc_typ_t t
         ,prfl_t p
      WHERE t.prfl_id = p.prfl_id
         AND t.prfl_id = v_prfl_id
         AND p.prcss_typ_cd = prcss_cur.prcss_typ
         AND prcss_cur.prcss_typ IN (hcrs.pkg_constants.cs_med_prcssng_typ_mthly, hcrs.pkg_constants.cs_med_prcssng_typ_qtrly)
         AND NOT EXISTS (
            SELECT 1 
            FROM hcrs.prfl_calc_prod_fmly_t cp
            WHERE cp.prfl_id = t.prfl_id
               AND cp.calc_typ_cd = t.calc_typ_cd
               AND cp.ndc_lbl = a_prc.ndc_lbl
               AND cp.ndc_prod = a_prc.ndc_prod);
      pkg_util.p_saveLog('PRFL_CALC_PROD_FMLY_T inserted: '||SQL%ROWCOUNT, c_program, v_module);
         
      -- prfl calc prod
      INSERT INTO prfl_calc_prod_t 
         (prfl_id, calc_typ_cd, ndc_lbl, ndc_prod, ndc_pckg, pri_whls_mthd_cd)
      SELECT t.prfl_id, t.calc_typ_cd, a_prc.ndc_lbl, a_prc.ndc_prod, a_prc.ndc_pckg, 'NONE'
      FROM prfl_calc_typ_t t
         ,prfl_t p
      WHERE t.prfl_id = p.prfl_id
         AND t.prfl_id = v_prfl_id
         AND p.prcss_typ_cd = prcss_cur.prcss_typ
         AND NOT EXISTS (
            SELECT 1 
            FROM hcrs.prfl_calc_prod_t cp
            WHERE cp.prfl_id = t.prfl_id
               AND cp.calc_typ_cd = t.calc_typ_cd
               AND cp.ndc_lbl = a_prc.ndc_lbl
               AND cp.ndc_prod = a_prc.ndc_prod
               AND cp.ndc_pckg = a_prc.ndc_pckg);
      pkg_util.p_saveLog('PRFL_CALC_PROD_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

      -- prfl prod fmly calc (only for Medi profiles) 
      -- this is where the pricing is
      INSERT INTO prfl_prod_fmly_calc_t
         (prfl_id, ndc_lbl, ndc_prod, calc_typ_cd, comp_typ_cd, calc_amt)
      SELECT t.prfl_id, a_prc.ndc_lbl, a_prc.ndc_prod, t.calc_typ_cd, t.calc_typ_cd
         ,CASE 
            WHEN t.calc_typ_cd = 'AMP' AND prcss_cur.prcss_typ = hcrs.pkg_constants.cs_med_prcssng_typ_mthly THEN 
               CASE 
                  WHEN prcss_cur.period_ind = 1 THEN a_prc.AMP_MTH_1
                  WHEN prcss_cur.period_ind = 2 THEN a_prc.AMP_MTH_2
                  WHEN prcss_cur.period_ind = 3 THEN a_prc.AMP_MTH_3
               END
            WHEN t.calc_typ_cd = 'AMP' AND prcss_cur.prcss_typ = hcrs.pkg_constants.cs_med_prcssng_typ_qtrly THEN a_prc.amp_qtrly
            WHEN t.calc_typ_cd = 'BP' THEN a_prc.bp_qtrly
         END AS price
      FROM prfl_calc_typ_t t
         ,prfl_t p
      WHERE t.prfl_id = p.prfl_id
         AND t.prfl_id = v_prfl_id
         AND p.prcss_typ_cd = prcss_cur.prcss_typ
         AND prcss_cur.prcss_typ IN (hcrs.pkg_constants.cs_med_prcssng_typ_mthly, hcrs.pkg_constants.cs_med_prcssng_typ_qtrly)
         AND NOT EXISTS (
            SELECT 1 
            FROM hcrs.prfl_prod_fmly_calc_t pc
            WHERE pc.prfl_id = t.prfl_id
               AND pc.calc_typ_cd = t.calc_typ_cd
               AND pc.comp_typ_cd = t.calc_typ_cd
               AND pc.ndc_lbl = a_prc.ndc_lbl
               AND pc.ndc_prod = a_prc.ndc_prod);
      pkg_util.p_saveLog('PRFL_PROD_FMLY_CALC_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

      -- prfl prod fmly calc (only for Medi profiles) 
      -- this is where the pricing is
      INSERT INTO prfl_prod_calc_t
         (prfl_id, ndc_lbl, ndc_prod, ndc_pckg, calc_typ_cd, comp_typ_cd, calc_amt)
      SELECT t.prfl_id, a_prc.ndc_lbl, a_prc.ndc_prod, a_prc.ndc_pckg, t.calc_typ_cd, t.calc_typ_cd
         ,CASE 
            WHEN t.calc_typ_cd = 'AMP' AND prcss_cur.prcss_typ = hcrs.pkg_constants.cs_med_prcssng_typ_mthly THEN 
               CASE 
                  WHEN prcss_cur.period_ind = 1 THEN a_prc.AMP_MTH_1
                  WHEN prcss_cur.period_ind = 2 THEN a_prc.AMP_MTH_2
                  WHEN prcss_cur.period_ind = 3 THEN a_prc.AMP_MTH_3
               END
            WHEN t.calc_typ_cd = 'AMP' AND prcss_cur.prcss_typ = hcrs.pkg_constants.cs_med_prcssng_typ_qtrly THEN a_prc.amp_qtrly
            WHEN t.calc_typ_cd = 'BP' THEN a_prc.bp_qtrly
            WHEN t.calc_typ_cd = 'ASP' THEN a_prc.asp_qrtly
            WHEN t.calc_typ_cd = 'NFAMP' AND prcss_cur.prcss_typ = hcrs.pkg_constants.cs_va_prcssng_typ_qtrly THEN a_prc.nfamp_qrtly
            WHEN t.calc_typ_cd = 'NFAMP' AND prcss_cur.prcss_typ = hcrs.pkg_constants.cs_va_prcssng_typ_annl THEN a_prc.nfamp_annual
            WHEN t.calc_typ_cd = 'FCP' THEN a_prc.fcp_annual
         END AS price
      FROM prfl_calc_typ_t t
         ,prfl_t p
      WHERE t.prfl_id = p.prfl_id
         AND t.prfl_id = v_prfl_id
         AND p.prcss_typ_cd = prcss_cur.prcss_typ
         AND NOT EXISTS (
            SELECT 1 
            FROM hcrs.prfl_prod_calc_t pc
            WHERE pc.prfl_id = t.prfl_id
               AND pc.calc_typ_cd = t.calc_typ_cd
               AND pc.comp_typ_cd = t.calc_typ_cd
               AND pc.ndc_lbl = a_prc.ndc_lbl
               AND pc.ndc_prod = a_prc.ndc_prod
               AND pc.ndc_pckg = a_prc.ndc_pckg);
      pkg_util.p_saveLog('PRFL_PROD_CALC_T inserted: '||SQL%ROWCOUNT, c_program, v_module);

   END LOOP; -- all price types processed

   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN no_data_found THEN
      ROLLBACK;
      pkg_util.p_saveLog('NO_DATA_FOUND Exception. Unable to find period for '||to_char(a_prc.qtr_start,'mm/dd/yyyy hh24:mi:ss')||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
   
   WHEN E_InvalidPrfl THEN
      ROLLBACK;
      pkg_util.p_saveLog('E_InvalidPrfl Exception. Unable to find profile. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);

   WHEN E_InvalidPrcss THEN
      ROLLBACK;
      pkg_util.p_saveLog('E_InvalidPrcss Exception. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
   
   WHEN OTHERS THEN
      ROLLBACK;
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
END;
/*
*/
PROCEDURE p_run_pricing_delta IS
   v_module    conv_log_t.module%TYPE := 'p_run_pricing_delta';
BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);

   -- loop through all pricing available and insert if new
   FOR prc_cur IN (
      SELECT * FROM ic_pricing_delta_v v
      ORDER BY v.ndc11, v.year_qtr) LOOP

      pkg_util.p_saveLog('NDC11: '||prc_cur.ndc11||', QTR: '||prc_cur.year_qtr, c_program, v_module);

      -- process WAC
      IF prc_cur.wac IS NOT NULL THEN
         -- non GP prices are treated differently
         p_process_WAC_price (prc_cur);
      ELSE
         -- all other GP prices
         p_process_GP_price (prc_cur);
         NULL;
      END IF;
   
   END LOOP;

   COMMIT;

   pkg_util.p_saveLog('END', c_program, v_module);

EXCEPTION
   WHEN E_InvalidData THEN
      ROLLBACK;
      pkg_util.p_saveLog('END', c_program, v_module);

   WHEN OTHERS THEN
      ROLLBACK;
      pkg_util.p_saveLog('Other exception. SQLERRM: '||SQLERRM||'. BACKTRACE: '||dbms_utility.format_error_backtrace, c_program, v_module);
END;

END;
/
