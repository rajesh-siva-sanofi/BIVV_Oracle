CREATE OR REPLACE VIEW V_TTBH AS
SELECT num_tbh_id,
          msg_num,
          (SELECT z.msg_text FROM display_msg z WHERE z.msg_num = a.msg_num) txt_tbh_nam,
          component_cd,
          tmod_num,
          cnt_tbc_rows_max,
          dts_tbh_mod,
          dts_tbh_add,
          txt_tbc_win,
          cnt_tbc_txt_lth,
          cnt_tbc_key_lth,
          txt_tbh_ownr,
          txt_tbh_id
     FROM ttbh a
    WHERE EXISTS (SELECT component_cd
                    FROM industry_comp_assoc x, sysdflt y
                   WHERE y.sysdflt_industry_cd = x.industry_cd
                     AND y.num_sys_id = 101
                     AND x.flg_enabled = 'Y'
                     AND x.component_cd = a.component_cd);
