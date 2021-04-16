CREATE OR REPLACE VIEW V_TTBC AS
SELECT num_tbh_id,
          msg_num,
          (SELECT z.msg_text
             FROM display_msg z
            WHERE z.msg_num = a.msg_num) txt_tbc_val,
          component_cd,
          num_tbc_seq,
          tmod_num,
          dts_tbc_mod,
          dts_tbc_add,
          txt_tbc_cde
     FROM ttbc a
    WHERE EXISTS (SELECT component_cd
                    FROM industry_comp_assoc x, sysdflt y
                   WHERE y.sysdflt_industry_cd = x.industry_cd
                     AND y.num_sys_id = 101
                     AND x.flg_enabled = 'Y'
                     AND x.component_cd = a.component_cd);
