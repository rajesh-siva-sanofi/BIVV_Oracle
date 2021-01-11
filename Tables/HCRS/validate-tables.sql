--
-- Validate tables
--
WITH p
  AS (-- Parameters
      -- p_scr_num:     Script number parameter: 01, 02, etc.
      -- p_scr_exec:    Script execution parameter: BEFORE / AFTER
      -- tbl_owner:     Table Owner
      -- priv_cnt:      Expected expected table privilege count
      -- priv2_cnt:     Expected unexpected table privilege count
      -- scr_exec_*:    Script Execution, BEFORE / AFTER
      -- tbl_ver:       Table version: TEMP / CNEW / SWPB / SWPA / MODB / MODA
      --                TEMP - Create Temp table in 01 that will be dropped after install
      --                NEW  - Create brand new table in 01
      --                SWP* - Create new version of the table in 01 and swap with original table in 02
      --                SWPB - Before / original version
      --                SWPA - After / new version
      --                MOD* - Modify table in place in 01 (add/drop column, change indexes, etc.)
      --                MODB - Before / original version
      --                MODA - After / new version
      -- tbl_name_*:    Table name, MAIN / ALT
      -- obj_typ_*:     Object types with order
      -- nn:            Null Number
      --
      SELECT '&1' p_scr_num,
             '&2' p_scr_exec,
             'HCRS' tbl_owner,
             16 priv_cnt,
             0 priv2_cnt,
             'BEFORE' scr_exec_b,
             'AFTER' scr_exec_a,
             'TEMP' tbl_ver_temp,
             'NEW' tbl_ver_new,
             'SWPB' tbl_ver_swpb,
             'SWPA' tbl_ver_swpa,
             'MODB' tbl_ver_modb,
             'MODA' tbl_ver_moda,
             'MAIN' tbl_name_m,
             'ALT' tbl_name_a,
             '1-TABLE' obj_typ_tbl,
             '2-INDEX' obj_typ_idx,
             '3-CONSTRAINT' obj_typ_cns,
             '4-TRIGGER' obj_typ_trg,
             TO_NUMBER( NULL) nn
        FROM dual
--) SELECT COUNT(*) OVER () cnt, a.* FROM p a WHERE 1=1 ORDER BY 2
     ),
     t
  AS (-- Tables Validation defintions
      -- tbl_ord:       Table Order: table_number.version, N.0: New table, N.1: Original version, N.2: New version
      -- tbl_ver:       Table version: TEMP / CNEW / SWPB / SWPA / MODB / MODA
      -- tbl_owner:     Table Owner
      -- tbl_name:      Table Name
      -- tbl_name_alt:  Table Alternate Name for SWAP table (before = ORG, after = NEW)
      -- tbl_cnt:       Expected table count
      -- col_cnt:       Expected table column count
      -- idx_cnt:       Expected table index
      -- cns_cnt:       Expected table named constraint count
      -- trg_cnt:       Expected table trigger count
      -- anlz_chk:      Check if table/index analyzed: 1=Yes, 0=No
      -- cmt_chk:       Check if table/column comments exist: 1=Yes, 0=No
      -- priv_chk:      Check if table privileges are correct: 1=Yes, 0=No
      --
      SELECT '' tbl_ord, '' tbl_ver, '' tbl_owner, '' tbl_name, '' tbl_name_alt, 0 tbl_cnt, 0 col_cnt, 0 idx_cnt, 0 cns_cnt, 0 trg_cnt, 0 anlz_chk, 0 cmt_chk, 0 priv_chk FROM dual WHERE 1=2 UNION ALL
      SELECT '1.1', p.tbl_ver_swpb, p.tbl_owner, 'PRFL_PROD_WRK_T',                'PRFL_PROD_WRK_ORG_T',            1, 121,  1,  1, 0, 0, 0, 0 FROM p UNION ALL
      SELECT '1.2', p.tbl_ver_swpa, p.tbl_owner, 'PRFL_PROD_WRK_T',                'PRFL_PROD_WRK_NEW_T',            1, 123,  1,  1, 0, 0, 1, 1 FROM p UNION ALL
      SELECT '2.1', p.tbl_ver_swpb, p.tbl_owner, 'PRFL_SLS_EXCL_T',                'PRFL_SLS_EXCL_ORG_T',            1,  30,  2,  4, 1, 0, 0, 0 FROM p UNION ALL
      SELECT '2.2', p.tbl_ver_swpa, p.tbl_owner, 'PRFL_SLS_EXCL_T',                'PRFL_SLS_EXCL_NEW_T',            1,  31,  3,  5, 1, 1, 1, 1 FROM p UNION ALL
      SELECT '' tbl_ord, '' tbl_ver, '' tbl_owner, '' tbl_name, '' tbl_name_alt, 0 tbl_cnt, 0 col_cnt, 0 idx_cnt, 0 cns_cnt, 0 trg_cnt, 0 anlz_chk, 0 cmt_chk, 0 priv_chk FROM dual WHERE 1=2
--) SELECT COUNT(*) OVER () cnt, a.* FROM t a WHERE 1=1 ORDER BY 2
     ),
     s
  AS (-- Script execution defintions
      -- scr_num:       Script number: 01, 02, etc.
      -- scr_exec:      Script execution: BEFORE / AFTER
      -- tbl_ver:       Table version: TEMP / CNEW / SWPB / SWPA / MODB / MODA
      -- tbl_name:      Table Name
      -- tbl_mult:      Table multiplier, for tables that don't exist
      -- trg_mult:      Trigger multiplier, for triggers that don't exist
      --
      SELECT '' scr_num, '' scr_exec, '' tbl_ver, '' tbl_name, 0 tbl_mult, 0 trg_mult FROM p WHERE 1=2 UNION ALL
      -- Install script 01 - BEFORE
      SELECT '01', p.scr_exec_b, p.tbl_ver_temp, p.tbl_name_m, 0, 0 FROM p UNION ALL -- Temp doesn't exist
      SELECT '01', p.scr_exec_b, p.tbl_ver_new,  p.tbl_name_m, 0, 0 FROM p UNION ALL -- New doesn't exist
      SELECT '01', p.scr_exec_b, p.tbl_ver_swpb, p.tbl_name_m, 1, 1 FROM p UNION ALL -- Swap original exists under main name
      SELECT '01', p.scr_exec_b, p.tbl_ver_swpa, p.tbl_name_a, 0, 0 FROM p UNION ALL -- Swap new doesn't exist under alt name
      SELECT '01', p.scr_exec_b, p.tbl_ver_modb, p.tbl_name_m, 1, 1 FROM p UNION ALL -- Mod hasn't been modified yet
      -- Install script 01 - AFTER
      SELECT '01', p.scr_exec_a, p.tbl_ver_temp, p.tbl_name_m, 1, 1 FROM p UNION ALL -- Temp exists
      SELECT '01', p.scr_exec_a, p.tbl_ver_new,  p.tbl_name_m, 1, 1 FROM p UNION ALL -- New exists
      SELECT '01', p.scr_exec_a, p.tbl_ver_swpb, p.tbl_name_m, 1, 1 FROM p UNION ALL -- Swap original exists under main name
      SELECT '01', p.scr_exec_a, p.tbl_ver_swpa, p.tbl_name_a, 1, 0 FROM p UNION ALL -- Swap new exists under alt name, no triggers
      SELECT '01', p.scr_exec_a, p.tbl_ver_moda, p.tbl_name_m, 1, 1 FROM p UNION ALL -- Mod has been modified
      -- Install script 02 - BEFORE
      SELECT '02', p.scr_exec_b, p.tbl_ver_temp, p.tbl_name_m, 1, 1 FROM p UNION ALL -- Temp exists
      SELECT '02', p.scr_exec_b, p.tbl_ver_new,  p.tbl_name_m, 1, 1 FROM p UNION ALL -- New exists
      SELECT '02', p.scr_exec_b, p.tbl_ver_swpb, p.tbl_name_m, 1, 1 FROM p UNION ALL -- Swap original exists under main name
      SELECT '02', p.scr_exec_b, p.tbl_ver_swpa, p.tbl_name_a, 1, 0 FROM p UNION ALL -- Swap new exists under alt name, no triggers
      SELECT '02', p.scr_exec_b, p.tbl_ver_moda, p.tbl_name_m, 1, 1 FROM p UNION ALL -- Mod has been modified
      -- Install script 02 - AFTER
      SELECT '02', p.scr_exec_a, p.tbl_ver_temp, p.tbl_name_m, 1, 1 FROM p UNION ALL -- Temp exists
      SELECT '02', p.scr_exec_a, p.tbl_ver_new,  p.tbl_name_m, 1, 1 FROM p UNION ALL -- New exists
      SELECT '02', p.scr_exec_a, p.tbl_ver_swpb, p.tbl_name_a, 1, 0 FROM p UNION ALL -- Swap original exists under alt name, no triggers
      SELECT '02', p.scr_exec_a, p.tbl_ver_swpa, p.tbl_name_m, 1, 1 FROM p UNION ALL -- Swap new exists under main name
      SELECT '02', p.scr_exec_a, p.tbl_ver_moda, p.tbl_name_m, 1, 1 FROM p UNION ALL -- Mod has been modified
      SELECT '' scr_num, '' scr_exec, '' tbl_ver, '' tbl_name, 0 tbl_mult, 0 trg_mult FROM p WHERE 1=2
--) SELECT COUNT(*) OVER () cnt, a.* FROM s a WHERE 1=1 ORDER BY 2, 3 DESC
     ),
     z
  AS (-- Full validation steps with adjusted values
      -- scr_num:       Script number: 01, 02, etc.
      -- scr_exec:      Script execution: BEFORE / AFTER
      -- tbl_ord:       Table Order: table_number.version, N.0: New table, N.1: Original version, N.2: New version
      -- tbl_owner:     Table Owner
      -- tbl_name:      Table Name
      -- tbl_cnt:       Expected table count
      -- col_cnt:       Expected table column count
      -- cmt_cnt:       Expected table/column comment count
      -- idx_cnt:       Expected table index
      -- cns_cnt:       Expected table named constraint count
      -- trg_cnt:       Expected table trigger count
      -- anlz_cnt:      Expected table/index analyzed count
      -- priv_cnt:      Expected expected table privilege count
      -- priv2_cnt:     Expected unexpected table privilege count
      -- anlz_chk:      Check if table/index analyzed: 1=Yes, 0=No
      -- cmt_chk:       Check if table/column comments exist: 1=Yes, 0=No
      -- priv_chk:      Check if table privileges are correct: 1=Yes, 0=No
      -- p_scr_exec:    Script execution parameter: BEFORE / AFTER
      -- p_scr_num:     Script number parameter: 01, 02, etc.
      -- obj_typ_*:     Object types with order
      --
      SELECT s.scr_num,
             s.scr_exec,
             t.tbl_ord,
             p.tbl_owner,
             CASE
                -- Using MAIN table name
                WHEN s.tbl_name = p.tbl_name_m
                THEN t.tbl_name
                -- Using ALT table name
                WHEN s.tbl_name = p.tbl_name_a
                THEN NVL( t.tbl_name_alt, t.tbl_name)
             END tbl_name,
             t.tbl_cnt * s.tbl_mult tbl_cnt,
             t.col_cnt * s.tbl_mult col_cnt,
             (t.tbl_cnt + t.col_cnt) * s.tbl_mult cmt_cnt,
             t.idx_cnt * s.tbl_mult idx_cnt,
             t.cns_cnt * s.tbl_mult cns_cnt,
             t.trg_cnt * s.tbl_mult * s.trg_mult trg_cnt,
             (t.tbl_cnt + t.idx_cnt) * s.tbl_mult anlz_cnt,
             p.priv_cnt * s.tbl_mult priv_cnt,
             p.priv2_cnt * s.tbl_mult priv2_cnt,
             t.anlz_chk * s.tbl_mult anlz_chk,
             t.cmt_chk * s.tbl_mult cmt_chk,
             t.priv_chk * s.tbl_mult priv_chk,
             p.p_scr_exec,
             p.p_scr_num,
             p.obj_typ_tbl
        FROM p,
             s,
             t
       WHERE p.tbl_owner = t.tbl_owner
         AND s.tbl_ver = t.tbl_ver
         AND p.p_scr_exec LIKE s.scr_exec || '%'
         AND p.p_scr_num LIKE s.scr_num || '%'
--) SELECT COUNT(*) OVER () cnt, a.* FROM z a WHERE 1=1 ORDER BY 2, 3 DESC, 4, 5, 6
     ),
     d
  AS (-- All Tables, Indexes, Contraints, and Triggers
      -- tbl_owner:     Table Owner
      -- tbl_name:      Table Name
      -- obj_typ:       Object type with order (table, index, constraint, trigger)
      -- sub_obj_name:  Sub object name for index, constraint, trigger
      -- tbl_cnt2:      Actual table count
      -- col_cnt2:      Actual table column count
      -- cmt_cnt2:      Actual table/column comment count
      -- idx_cnt2:      Actual index count
      -- cns_cnt2:      Actual constraint count
      -- trg_cnt2:      Actual trigger count
      -- anlz_cnt2:     Actual table/index analyzed count
      -- priv_cnt2:     Actual expected table privilege count
      -- priv2_cnt2:    Actual unexpected table privilege count
      --
      -- Tables
      SELECT dt.owner tbl_owner,
             dt.table_name tbl_name,
             z.obj_typ_tbl obj_typ,
             '' sub_obj_name,
             1 tbl_cnt2,
             (-- Get count of columns
               SELECT COUNT(*)
                 FROM dba_tab_columns dtc
                WHERE dtc.owner = dt.owner
                  AND dtc.table_name = dt.table_name
             ) col_cnt2,
             (-- Get table comment count
               SELECT COUNT(*)
                 FROM dba_tab_comments dtc
                WHERE dtc.owner = dt.owner
                  AND dtc.table_name = dt.table_name
                  AND dtc.comments IS NOT NULL
             ) +
             (-- Get column comment count
               SELECT COUNT(*)
                 FROM dba_col_comments dcc
                WHERE dcc.owner = dt.owner
                  AND dcc.table_name = dt.table_name
                  AND dcc.comments IS NOT NULL
             ) cmt_cnt2,
             z.nn idx_cnt2,
             z.nn cns_cnt2,
             z.nn trg_cnt2,
             NVL2( dt.last_analyzed, 1, 0) anlz_cnt2,
             (
               SELECT COUNT(*)
                 FROM dba_tab_privs dtp
                WHERE dtp.owner = dt.owner
                  AND dtp.table_name = dt.table_name
                  AND (   (    dtp.privilege = 'SELECT'
                           AND dtp.grantee IN ('HCRS_CONNECT', 'HCRS_CRM_SELECT', 'HCRS_RPT', 'HCRS_SELECT')
                          )
                       OR (    dtp.privilege IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE')
                           AND dtp.grantee IN ('HCRS_DATA_ENTRY', 'HCRS_MANAGER', 'HCRS_SUPERVISOR')
                          )
                      )
             ) priv_cnt2,
             (
               SELECT COUNT(*)
                 FROM dba_tab_privs dtp
                WHERE dtp.owner = dt.owner
                  AND dtp.table_name = dt.table_name
                  AND NOT (   (    dtp.privilege = 'SELECT'
                               AND dtp.grantee IN ('HCRS_CONNECT', 'HCRS_CRM_SELECT', 'HCRS_RPT', 'HCRS_SELECT')
                              )
                           OR (    dtp.privilege IN ('SELECT', 'INSERT', 'UPDATE', 'DELETE')
                               AND dtp.grantee IN ('HCRS_DATA_ENTRY', 'HCRS_MANAGER', 'HCRS_SUPERVISOR')
                              )
                          )
             ) priv2_cnt2
        FROM p z,
             dba_tables dt
       WHERE z.tbl_owner = dt.owner
      UNION ALL
      -- Indexes
      SELECT di.table_owner tbl_owner,
             di.table_name tbl_name,
             z.obj_typ_idx obj_typ,
             di.index_name sub_obj_name,
             z.nn tbl_cnt2,
             z.nn col_cnt2,
             z.nn cmt_cnt2,
             1 idx_cnt2,
             z.nn cns_cnt2,
             z.nn trg_cnt2,
             NVL2( di.last_analyzed, 1, 0) anlz_cnt2,
             z.nn priv_cnt2,
             z.nn priv2_cnt2
        FROM p z,
             dba_indexes di
       WHERE z.tbl_owner = di.table_owner
      UNION ALL
      -- Constraints
      SELECT dc.owner tbl_owner,
             dc.table_name tbl_name,
             z.obj_typ_cns obj_typ,
             dc.constraint_name sub_obj_name,
             z.nn tbl_cnt2,
             z.nn col_cnt2,
             z.nn cmt_cnt2,
             z.nn idx_cnt2,
             1 cns_cnt2,
             z.nn trg_cnt2,
             z.nn anlz_cnt2,
             z.nn priv_cnt2,
             z.nn priv2_cnt2
        FROM p z,
             dba_constraints dc
       WHERE z.tbl_owner = dc.owner
         AND dc.constraint_name NOT LIKE 'SYS\_C%' ESCAPE '\'
      UNION ALL
      -- Triggers
      SELECT dr.table_owner tbl_owner,
             dr.table_name tbl_name,
             z.obj_typ_trg obj_typ,
             dr.trigger_name sub_obj_name,
             z.nn tbl_cnt2,
             z.nn col_cnt2,
             z.nn cmt_cnt2,
             z.nn idx_cnt2,
             z.nn cns_cnt2,
             1 trg_cnt2,
             z.nn anlz_cnt2,
             z.nn priv_cnt2,
             z.nn priv2_cnt2
        FROM p z,
             dba_triggers dr
       WHERE z.tbl_owner = dr.table_owner
--) SELECT COUNT(*) OVER () cnt, a.* FROM d a WHERE 1=1 ORDER BY 2, 3, 4, 5, 6, 7
     ),
     y
  AS (-- Combine table/script/step definitions with actual object information
      -- scr_num:       Script number: 01, 02, etc.
      -- scr_exec:      Script execution: BEFORE / AFTER
      -- tbl_ord:       Table Order: table_number.version, N.0: New table, N.1: Original version, N.2: New version
      -- tbl_owner:     Table Owner
      -- tbl_name:      Table Name
      -- obj_typ:       Object type with order (table, index, constraint, trigger)
      -- obj_typ2:      Object type only for table row
      -- sub_obj_name:  Sub object name for index, constraint, trigger
      -- tbl_cnt:       Expected table count
      -- tbl_cnt2:      Actual table count
      -- col_cnt:       Expected table column count
      -- col_cnt2:      Actual table column count
      -- cmt_cnt:       Expected table/column comment count
      -- cmt_cnt2:      Actual table/column comment count
      -- idx_cnt:       Expected table index
      -- idx_cnt2:      Actual index count
      -- cns_cnt:       Expected table named constraint count
      -- cns_cnt2:      Actual constraint count
      -- trg_cnt:       Expected table trigger count
      -- trg_cnt2:      Actual trigger count
      -- anlz_cnt:      Expected table/index analyzed count
      -- anlz_cnt2:     Actual table/index analyzed count
      -- priv_cnt:      Expected expected table privilege count
      -- priv_cnt2:     Actual expected table privilege count
      -- priv2_cnt :    Expected unexpected table privilege count
      -- priv2_cnt2:    Actual unexpected table privilege count
      -- anlz_chk:      Check if table/index analyzed: 1=Yes, 0=No
      -- cmt_chk:       Check if table/column comments exist: 1=Yes, 0=No
      -- priv_chk:      Check if table privileges are correct: 1=Yes, 0=No
      -- p_scr_exec:    Script execution parameter: BEFORE / AFTER
      -- p_scr_num:     Script number parameter: 01, 02, etc.
      --
      SELECT z.scr_num,
             z.scr_exec,
             z.tbl_ord,
             z.tbl_owner,
             z.tbl_name,
             d.obj_typ,
             DECODE( NVL( d.obj_typ, z.obj_typ_tbl), z.obj_typ_tbl, z.obj_typ_tbl) obj_typ2,
             d.sub_obj_name,
             z.tbl_cnt,
             d.tbl_cnt2,
             z.col_cnt,
             d.col_cnt2,
             (z.tbl_cnt + z.col_cnt) * z.cmt_chk cmt_cnt,
             d.cmt_cnt2 * z.cmt_chk cmt_cnt2,
             z.idx_cnt,
             d.idx_cnt2,
             z.cns_cnt,
             d.cns_cnt2,
             z.trg_cnt,
             d.trg_cnt2,
             (z.tbl_cnt + z.idx_cnt) * z.anlz_chk anlz_cnt,
             d.anlz_cnt2 * z.anlz_chk anlz_cnt2,
             z.priv_cnt * z.priv_chk priv_cnt,
             d.priv_cnt2 * z.priv_chk priv_cnt2,
             z.priv2_cnt * z.priv_chk priv2_cnt,
             d.priv2_cnt2 * z.priv_chk priv2_cnt2,
             z.anlz_chk,
             z.cmt_chk,
             z.priv_chk,
             z.p_scr_exec,
             z.p_scr_num
        FROM z,
             d
       WHERE z.tbl_owner = d.tbl_owner (+)
         AND z.tbl_name = d.tbl_name (+)
--) SELECT COUNT(*) OVER () cnt, a.* FROM y a WHERE 1=1 ORDER BY 2, 3 DESC, 4, 5, 6, 7, 8, 9
     ),
     x
  AS (-- Summarize counts on table row
      -- scr_num:       Script number: 01, 02, etc.
      -- scr_exec:      Script execution: BEFORE / AFTER
      -- tbl_ord:       Table Order: table_number.version, N.0: New table, N.1: Original version, N.2: New version
      -- tbl_owner:     Table Owner
      -- tbl_name:      Table Name
      -- obj_typ:       Object type with order (table, index, constraint, trigger)
      -- sub_obj_name:  Sub object name for index, constraint, trigger
      -- tbl_cnt:       Expected table count
      -- tbl_cnt2:      Actual table count
      -- col_cnt:       Expected table column count
      -- col_cnt2:      Actual table column count
      -- cmt_cnt:       Expected table/column comment count
      -- cmt_cnt2:      Actual table/column comment count
      -- idx_cnt:       Expected table index
      -- idx_cnt2:      Actual index count
      -- cns_cnt:       Expected table named constraint count
      -- cns_cnt2:      Actual constraint count
      -- trg_cnt:       Expected table trigger count
      -- trg_cnt2:      Actual trigger count
      -- anlz_cnt:      Expected table/index analyzed count
      -- anlz_cnt2:     Actual table/index analyzed count
      -- priv_cnt:      Expected expected table privilege count
      -- priv_cnt2:     Actual expected table privilege count
      -- priv2_cnt :    Expected unexpected table privilege count
      -- priv2_cnt2:    Actual unexpected table privilege count
      -- anlz_chk:      Check if table/index analyzed: 1=Yes, 0=No
      -- cmt_chk:       Check if table/column comments exist: 1=Yes, 0=No
      -- priv_chk:      Check if table privileges are correct: 1=Yes, 0=No
      -- p_scr_exec:    Script execution parameter: BEFORE / AFTER
      -- p_scr_num:     Script number parameter: 01, 02, etc.
      --
      SELECT z.scr_num,
             z.scr_exec,
             z.tbl_ord,
             z.tbl_owner,
             z.tbl_name,
             z.obj_typ,
             z.sub_obj_name,
             NVL2( z.obj_typ2, z.tbl_cnt, '') tbl_cnt,
             NVL2( z.obj_typ2, NVL( z.tbl_cnt2, 0), '') tbl_cnt2,
             NVL2( z.obj_typ2, z.col_cnt, '') col_cnt,
             NVL2( z.obj_typ2, NVL( z.col_cnt2, 0), '') col_cnt2,
             NVL2( z.obj_typ2, z.cmt_cnt, '') cmt_cnt,
             NVL2( z.obj_typ2, NVL( z.cmt_cnt2, 0), '') cmt_cnt2,
             NVL2( z.obj_typ2, z.idx_cnt, '') idx_cnt,
             NVL2( z.obj_typ2, NVL( SUM( z.idx_cnt2) OVER (PARTITION BY z.scr_num, z.scr_exec, z.tbl_owner, z.tbl_name), 0), '') idx_cnt2,
             NVL2( z.obj_typ2, z.cns_cnt, '') cns_cnt,
             NVL2( z.obj_typ2, NVL( SUM( z.cns_cnt2) OVER (PARTITION BY z.scr_num, z.scr_exec, z.tbl_owner, z.tbl_name), 0), '') cns_cnt2,
             NVL2( z.obj_typ2, z.trg_cnt, '') trg_cnt,
             NVL2( z.obj_typ2, NVL( SUM( z.trg_cnt2) OVER (PARTITION BY z.scr_num, z.scr_exec, z.tbl_owner, z.tbl_name), 0), '') trg_cnt2,
             NVL2( z.obj_typ2, z.anlz_cnt, '') anlz_cnt,
             NVL2( z.obj_typ2, NVL( SUM( z.anlz_cnt2) OVER (PARTITION BY z.scr_num, z.scr_exec, z.tbl_owner, z.tbl_name), 0), '') anlz_cnt2,
             NVL2( z.obj_typ2, z.priv_cnt, '') priv_cnt,
             NVL2( z.obj_typ2, NVL( SUM( z.priv_cnt2) OVER (PARTITION BY z.scr_num, z.scr_exec, z.tbl_owner, z.tbl_name), 0), '') priv_cnt2,
             NVL2( z.obj_typ2, z.priv2_cnt, '') priv2_cnt,
             NVL2( z.obj_typ2, NVL( SUM( z.priv2_cnt2) OVER (PARTITION BY z.scr_num, z.scr_exec, z.tbl_owner, z.tbl_name), 0), '') priv2_cnt2,
             z.anlz_chk,
             z.cmt_chk,
             z.priv_chk,
             z.p_scr_exec,
             z.p_scr_num
        FROM y z
--) SELECT COUNT(*) OVER () cnt, a.* FROM x a WHERE 1=1 ORDER BY 2, 3 DESC, 4, 5, 6, 7, 8
     ),
     w
  AS (
      -- chk_tbl:       Check if all table objects exist
      -- scr_num:       Script number: 01, 02, etc.
      -- scr_exec:      Script execution: BEFORE / AFTER
      -- tbl_ord:       Table Order: table_number.version, N.0: New table, N.1: Original version, N.2: New version
      -- tbl_owner:     Table Owner
      -- tbl_name:      Table Name
      -- obj_typ:       Object type with order (table, index, constraint, trigger)
      -- sub_obj_name:  Sub object name for index, constraint, trigger
      -- tbl_cnt:       Expected table count
      -- tbl_cnt2:      Actual table count
      -- col_cnt:       Expected table column count
      -- col_cnt2:      Actual table column count
      -- cmt_cnt:       Expected table/column comment count
      -- cmt_cnt2:      Actual table/column comment count
      -- idx_cnt:       Expected table index
      -- idx_cnt2:      Actual index count
      -- cns_cnt:       Expected table named constraint count
      -- cns_cnt2:      Actual constraint count
      -- trg_cnt:       Expected table trigger count
      -- trg_cnt2:      Actual trigger count
      -- anlz_cnt:      Expected table/index analyzed count
      -- anlz_cnt2:     Actual table/index analyzed count
      -- priv_cnt:      Expected expected table privilege count
      -- priv_cnt2:     Actual expected table privilege count
      -- priv2_cnt :    Expected unexpected table privilege count
      -- priv2_cnt2:    Actual unexpected table privilege count
      -- anlz_chk:      Check if table/index analyzed: 1=Yes, 0=No
      -- cmt_chk:       Check if table/column comments exist: 1=Yes, 0=No
      -- priv_chk:      Check if table privileges are correct: 1=Yes, 0=No
      -- p_scr_exec:    Script execution parameter: BEFORE / AFTER
      -- p_scr_num:     Script number parameter: 01, 02, etc.
      --
      SELECT CASE
                WHEN z.tbl_cnt IS NULL
                THEN ''
                WHEN z.tbl_cnt <> z.tbl_cnt2
                THEN 'TABLE'
                ELSE NVL( RTRIM( DECODE( z.col_cnt, z.col_cnt2, '', 'COLUMN,') ||
                                 DECODE( z.cmt_cnt, z.cmt_cnt2, '', 'COMMENT,') ||
                                 DECODE( z.idx_cnt, z.idx_cnt2, '', 'INDEX,') ||
                                 DECODE( z.cns_cnt, z.cns_cnt2, '', 'CONSTRAINT,') ||
                                 DECODE( z.trg_cnt, z.trg_cnt2, '', 'TRIGGER,') ||
                                 DECODE( z.anlz_cnt, z.anlz_cnt2, '', 'ANALYZE,') ||
                                 DECODE( z.priv_cnt, z.priv_cnt2, '', 'PRIV-,') ||
                                 DECODE( z.priv2_cnt, z.priv2_cnt2, '', 'PRIV+,'), ','),
                          'OK')
             END chk_tbl,
             z.scr_num,
             z.scr_exec,
             z.tbl_ord,
             z.tbl_owner,
             z.tbl_name,
             z.obj_typ,
             z.sub_obj_name,
             z.tbl_cnt,
             z.tbl_cnt2,
             z.col_cnt,
             z.col_cnt2,
             z.cmt_cnt,
             z.cmt_cnt2,
             z.idx_cnt,
             z.idx_cnt2,
             z.cns_cnt,
             z.cns_cnt2,
             z.trg_cnt,
             z.trg_cnt2,
             z.anlz_cnt,
             z.anlz_cnt2,
             z.priv_cnt,
             z.priv_cnt2,
             z.priv2_cnt,
             z.priv2_cnt2,
             z.anlz_chk,
             z.cmt_chk,
             z.priv_chk,
             z.p_scr_exec,
             z.p_scr_num
        FROM x z
--) SELECT COUNT(*) OVER () cnt, a.* FROM w a WHERE 1=1 ORDER BY 3, 4 DESC, 5, 6, 7, 8, 9
     )
-- chk_all:       Check if table objects exist for all tables
-- chk_tbl:       Check if table objects exist
-- scr_num:       Script number: 01, 02, etc.
-- scr_exec:      Script execution: BEFORE / AFTER
-- tbl_ord:       Table Order: table_number.version, N.0: New table, N.1: Original version, N.2: New version
-- tbl_owner:     Table Owner
-- tbl_name:      Table Name
-- obj_typ:       Object type with order (table, index, constraint, trigger)
-- sub_obj_name:  Sub object name for index, constraint, trigger
-- tbl_cnt:       Expected table count
-- tbl_cnt2:      Actual table count
-- col_cnt:       Expected table column count
-- col_cnt2:      Actual table column count
-- cmt_cnt:       Expected table/column comment count
-- cmt_cnt2:      Actual table/column comment count
-- idx_cnt:       Expected table index
-- idx_cnt2:      Actual index count
-- cns_cnt:       Expected table named constraint count
-- cns_cnt2:      Actual constraint count
-- trg_cnt:       Expected table trigger count
-- trg_cnt2:      Actual trigger count
-- anlz_cnt:      Expected table/index analyzed count
-- anlz_cnt2:     Actual table/index analyzed count
-- priv_cnt:      Expected expected table privilege count
-- priv_cnt2:     Actual expected table privilege count
-- priv2_cnt :    Expected unexpected table privilege count
-- priv2_cnt2:    Actual unexpected table privilege count
-- anlz_chk:      Check if table/index analyzed: 1=Yes, 0=No
-- cmt_chk:       Check if table/column comments exist: 1=Yes, 0=No
-- priv_chk:      Check if table privileges are correct: 1=Yes, 0=No
-- p_scr_exec:    Script execution parameter: BEFORE / AFTER
-- p_scr_num:     Script number parameter: 01, 02, etc.
--
SELECT CASE
          WHEN z.chk_tbl IS NULL
          THEN ''
          WHEN SUM( DECODE( z.chk_tbl, '', 0, 1)) OVER () <>
               SUM( DECODE( z.chk_tbl, 'OK', 1, 0)) OVER ()
          THEN 'ERROR'
          ELSE 'OK'
       END chk_all,
       z.chk_tbl,
       z.scr_num,
       z.scr_exec,
       z.tbl_ord,
       z.tbl_owner,
       z.tbl_name,
       z.obj_typ,
       z.sub_obj_name,
       z.tbl_cnt,
       z.tbl_cnt2,
       z.col_cnt,
       z.col_cnt2,
       z.cmt_cnt,
       z.cmt_cnt2,
       z.idx_cnt,
       z.idx_cnt2,
       z.cns_cnt,
       z.cns_cnt2,
       z.trg_cnt,
       z.trg_cnt2,
       z.anlz_cnt,
       z.anlz_cnt2,
       z.priv_cnt,
       z.priv_cnt2,
       z.priv2_cnt,
       z.priv2_cnt2,
       z.anlz_chk,
       z.cmt_chk,
       z.priv_chk,
       z.p_scr_exec,
       z.p_scr_num
  FROM w z
 ORDER BY 3, 4, 5, 6, 7, 8, 9, 10;
