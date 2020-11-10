CREATE OR REPLACE VIEW V_CONT AS
SELECT c.cont_internal_id,
          c.cont_flg_update,
          c.cont_flg_lock,
          (SELECT b.bunit_name
             FROM bunit b
            WHERE b.bunit_num = c.ctorg_bunit_num AND ROWNUM = 1)
                                                              contract_entity,
          (SELECT b.bunit_city || ', ' || b.bunit_state || ', ' || b.bunit_zip
             FROM bunit b
            WHERE b.bunit_num = c.ctorg_bunit_num AND ROWNUM = 1)
                                                              contract_entity_address,
          (SELECT b.bunit_name
             FROM bunit b, whoami w
            WHERE b.bunit_num = w.bunit_num
              AND c.whoami_num = w.whoami_num
              AND ROWNUM = 1) contract_owner,
          c.cont_title,
          c.cont_dt_start,
          c.cont_dt_end,
         (SELECT x.mkttyp_desc
              FROM mkttyp x
             WHERE x.mkttyp_id = c.mkttyp_id
               AND ROWNUM = 1) mkttyp_id,
          c.userid_admin_cont,
          (SELECT t.txt_opr_nme_lst
             FROM topr t
            WHERE t.num_opr_id = c.userid_admin_cont AND ROWNUM = 1)
                                                               contract_admin,
          c.cont_flg_lpcalc,
          c.cont_flg_lpexempt,
           NVL((SELECT 'Y'
              FROM cpgrp
             WHERE cpgrp.cont_num = c.cont_num AND ROWNUM = 1 AND
                   EXISTS (SELECT NULL FROM cpppo WHERE cpppo.cpgrp_num = cpgrp.cpgrp_num)), 'N') cont_flg_escal,
          c.cont_mod_seq,
          c.cont_flg_hidden_pg,
          c.cont_num,
          c.userid,
          (SELECT t.txt_opr_nme_lst
             FROM topr t
            WHERE t.num_opr_id = c.userid AND ROWNUM = 1) user_name,
          c.lastmod,
          c.flg_note,
          c.userid_admin_rebate,
           decode (c.num_sys_id,
                   102,
                   (SELECT t.BCTAC_NAME_LAST || ', ' || t.BCTAC_NAME_FIRST
                        FROM bctac t
                        WHERE t.BCTAC_NUM = c.CTORG_BCTAC_NUM AND ROWNUM = 1),
          (SELECT t.txt_opr_nme_lst
             FROM topr t
                        WHERE t.num_opr_id = c.userid_admin_rebate AND ROWNUM = 1))
                                                                 rebate_admin,
          c.cttertyp_cd,
          (SELECT x.txt_tbc_val
             FROM v_ttbc x
            WHERE x.num_tbh_id IN (3014, 3017)
              AND x.txt_tbc_cde = c.cttertyp_cd
              AND ROWNUM = 1) CATEGORY,
          c.num_sys_id,
          (SELECT txt_sys_id
             FROM tsys
            WHERE num_sys_id = c.num_sys_id) txt_sys_id,
          c.cont_flg_supplmtl,
          (SELECT s.status_desc
             FROM contstat cs, status s
            WHERE s.status_num = cs.status_num
              AND cs.contstat_num = c.contstat_num
              AND ROWNUM = 1) status_desc,
          CASE
             WHEN (SELECT cs.status_num
                     FROM contstat cs
                    WHERE cs.contstat_num = c.contstat_num) = 3
                THEN 'Not Yet Activated'
             WHEN c.cont_mod_seq = -99
                THEN    'Version '
                     || (SELECT cs2.contstat_mod_seq
                           FROM contstat cs2
                          WHERE cs2.contstat_num =
                                   (SELECT MAX (cs.contstat_num)
                                      FROM contstat cs
                                     WHERE cs.contstat_num != c.contstat_num
                                       AND key_num = c.cont_num
                                       AND cs.contvaltyp_cd = 'CONT'))
             WHEN (SELECT cs.status_num
                     FROM contstat cs
                    WHERE cs.contstat_num = c.contstat_num
                      AND cs.status_num!=35) > 0
                THEN (CASE
                         WHEN c.cont_mod_seq = 0
                            THEN 'Original'
                         WHEN c.cont_mod_seq > 0
                            THEN 'Version ' || c.cont_mod_seq
                      END
                     )
          END last_cont_amendment,
          c.cont_flg_appl_rebate_cap,
          CASE
             WHEN
            -- (c.cont_flg_update = 'Y' OR c.cont_flg_lpcalc = 'Y') AND
              ((SELECT COUNT (1)
                     FROM DUAL
                    WHERE EXISTS (SELECT 1
                                    FROM contval a, contvalh b
                                   WHERE a.contvalh_num = b.contvalh_num
                                     AND b.contstat_num = c.contstat_num
                                     AND a.svrtytyp_cd IN ('CRITICAL', 'CBMBO'))) = 1)
                THEN 'E'
             WHEN c.cont_flg_update = 'Y' OR c.cont_flg_lpcalc = 'Y'
                THEN 'C'
             ELSE 'S'
          END cont_indicator_cd,
          c.ctorg_bunit_num
     FROM cont c
;
