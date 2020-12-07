CREATE OR REPLACE PACKAGE BIVV.pkg_stg_medi AS

   PROCEDURE p_main (a_trunc_flg VARCHAR2 DEFAULT 'Y', a_valid_flg VARCHAR2 DEFAULT 'Y');
END;
/
CREATE OR REPLACE PACKAGE BODY BIVV.pkg_stg_medi AS

   c_program   CONSTANT conv_log_t.program%TYPE := 'BIVV.PKG_STG_MEDI';
   c_userid_BIVV  CONSTANT hcrs.user_t.user_id%TYPE := 'BIVV';

   E_InvalidData EXCEPTION;

/*
*/
PROCEDURE p_validate IS

   v_module    conv_log_t.module%TYPE := 'p_validate';
   v_msg    VARCHAR2 (4000);
   v_cnt    NUMBER;
   
BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);

   -- validate product program associations
   SELECT COUNT(*) INTO v_cnt
   FROM BIVV_PGM_PROD_VAL_V v
   WHERE nvl(v.val_msg, 'OK') LIKE 'ERR%';
   
   pkg_util.p_saveLog('Non valid count for BIVV_PGM_PROD_VAL_V: '||v_cnt, c_program, v_module);

   IF v_cnt > 0 THEN
      v_msg := CASE WHEN v_msg IS NOT NULL THEN v_msg||', ' END || 'BIVV_PGM_PROD_VAL_V';
   END IF;

   -- validate claim headers
   SELECT COUNT(*) INTO v_cnt
   FROM BIVV_MEDI_CLAIM_VAL_V v
   WHERE nvl(v.val_msg, 'OK') LIKE 'ERR%';
   
   pkg_util.p_saveLog('Non valid count for BIVV_MEDI_CLAIM_V: '||v_cnt, c_program, v_module);

   IF v_cnt > 0 THEN
      v_msg := CASE WHEN v_msg IS NOT NULL THEN v_msg||', ' END || 'BIVV_MEDI_CLAIM_V';
   END IF;

   -- validate all claim lines
   SELECT COUNT(*) INTO v_cnt
   FROM BIVV_MEDI_CLAIM_LINE_VAL_V v
   WHERE nvl(v.val_msg, 'OK') LIKE 'ERR%';
   pkg_util.p_saveLog('Non valid count for BIVV_MEDI_CLAIM_LINE_V: '||v_cnt, c_program, v_module);

   IF v_cnt > 0 THEN
      v_msg := CASE WHEN v_msg IS NOT NULL THEN v_msg||', ' END || 'BIVV_MEDI_CLAIM_LINE_V';
   END IF;

   -- validate all paid lines
   SELECT COUNT(*) INTO v_cnt
   FROM BIVV_MEDI_PAID_LINE_VAL_V v
   WHERE nvl(v.val_msg, 'OK') LIKE 'ERR%';
   pkg_util.p_saveLog('Non valid count for BIVV_MEDI_PAID_LINE_V: '||v_cnt, c_program, v_module);

   IF v_cnt > 0 THEN
      v_msg := CASE WHEN v_msg IS NOT NULL THEN v_msg||', ' END || 'BIVV_MEDI_PAID_LINE_V';
   END IF;

   -- validate disputed lines view
   SELECT COUNT(*) INTO v_cnt
   FROM BIVV_DSPT_VAL_V v
   WHERE nvl(v.val_msg, 'OK') LIKE 'ERR%';   
   pkg_util.p_saveLog('Non valid count for BIVV_DSPT_VAL_V: '||v_cnt, c_program, v_module);

   IF v_cnt > 0 THEN
      v_msg := CASE WHEN v_msg IS NOT NULL THEN v_msg||', ' END || 'BIVV_DSPT_VAL_V';
   END IF;

   -- validate URAs
   SELECT COUNT(*) INTO v_cnt
   FROM BIVV_PUR_FINAL_RESULTS_VAL_V v
   WHERE nvl(v.val_msg, 'OK') LIKE 'ERR%';
   
   pkg_util.p_saveLog('Non valid count for BIVV_PUR_FINAL_RESULTS_VAL_V: '||v_cnt, c_program, v_module);

   IF v_cnt > 0 THEN
      v_msg := CASE WHEN v_msg IS NOT NULL THEN v_msg||', ' END || 'BIVV_PUR_FINAL_RESULTS_VAL_V';
   END IF;

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
--------------------------------------------------- URA CALC-----------------------------------------------------
PROCEDURE p_load_ura_calc IS
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
END p_load_ura_calc;

/*
Truncates all the MEDICLAIM related BIVV Staging table and calls the procedures to load medicalim data
*/
PROCEDURE p_main (a_trunc_flg VARCHAR2 DEFAULT 'Y', a_valid_flg VARCHAR2 DEFAULT 'Y') IS
   v_module    conv_log_t.module%TYPE := 'p_main';
BEGIN

   pkg_util.p_saveLog('START', c_program, v_module);
   pkg_util.p_saveLog('Parameters passed -> a_trunc_flg:'||a_trunc_flg||', a_valid_flg:'||a_valid_flg, c_program, v_module);

   -- validate source data
   IF nvl(a_valid_flg, 'Y') = 'Y' THEN
      p_validate;
   END IF;

   -- truncate all stage tables to prepare for new load if requested
   IF nvl(a_trunc_flg, 'Y') = 'Y' THEN
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
      pkg_util.p_trunc_tbl('PUR_FINAL_RESULTS_T');
      pkg_util.p_trunc_tbl('PROD_MSTR_PGM_T');   
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
      p_load_ura_calc;

--   Commit;

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
