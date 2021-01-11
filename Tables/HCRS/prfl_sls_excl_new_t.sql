--------------------------------------------------------------------------------
-- Create new Profile Sales Exclusion table
--------------------------------------------------------------------------------
TIMING START hcrs.prfl_sls_excl_new_t

--DROP TABLE hcrs.prfl_sls_excl_new_t PURGE;
CREATE TABLE hcrs.prfl_sls_excl_new_t
   (prfl_id         NOT NULL,
    trans_id        NOT NULL,
    sls_excl_cd     DEFAULT 'NOM' NOT NULL, -- New
    over_ind        DEFAULT 'I' NOT NULL,
    co_id           NOT NULL,
    cls_of_trd_cd   NOT NULL,
    apprvd_ind      DEFAULT 'N' NOT NULL,
    apprvd_dt,
    apprvd_by,
    adj_cnt         DEFAULT 0 NOT NULL,
    adj_pkg_qty,
    adj_total_amt,
    nmnl_thres_amt,
    trans_adj_cd,
    root_trans_id,
    parent_trans_id,
    trans_dt,
    dllr_amt,
    pkg_qty,
    chrgbck_amt,
    term_disc_pct,
    nom_dllr_amt,
    nom_pkg_qty,
    splt_pct_typ,
    splt_pct_seq_no,
    bndl_cd,
    bndl_seq_no,
    create_dt       NOT NULL,
    mod_dt,
    mod_by          NOT NULL,
    cmt_txt)
   TABLESPACE hcrsdlg
   AS
      SELECT t.prfl_id,
             t.trans_id,
             CAST( 'NOM' AS VARCHAR2( 10)) sls_excl_cd, -- New
             t.over_ind,
             t.co_id,
             t.cls_of_trd_cd,
             t.apprvd_ind,
             t.apprvd_dt,
             t.apprvd_by,
             t.adj_cnt,
             t.adj_pkg_qty,
             t.adj_total_amt,
             t.nmnl_thres_amt,
             t.trans_adj_cd,
             t.root_trans_id,
             t.parent_trans_id,
             t.trans_dt,
             t.dllr_amt,
             t.pkg_qty,
             t.chrgbck_amt,
             t.term_disc_pct,
             t.nom_dllr_amt,
             t.nom_pkg_qty,
             t.splt_pct_typ,
             t.splt_pct_seq_no,
             t.bndl_cd,
             t.bndl_seq_no,
             t.create_dt,
             t.mod_dt,
             t.mod_by,
             t.cmt_txt
        FROM hcrs.prfl_sls_excl_t t;

-- Analyze table
BEGIN
   dbms_stats.delete_table_stats( ownname => 'HCRS',
                                  tabname => 'PRFL_SLS_EXCL_NEW_T');
   dbms_stats.gather_table_stats( ownname => 'HCRS',
                                  tabname => 'PRFL_SLS_EXCL_NEW_T',
                                  estimate_percent => NULL, -- null means compute
                                  method_opt => 'FOR ALL COLUMNS SIZE 1',
                                  degree => dbms_stats.auto_degree,
                                  cascade => TRUE,
                                  granularity => 'ALL');
END;
/

-- Comments
COMMENT ON TABLE hcrs.prfl_sls_excl_new_t IS 'Profile Sales Exclusions';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.prfl_id IS 'Profile ID';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.trans_id IS 'Transaction ID, the unique transaction identifer from hcrs.mstr_trans_t';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.sls_excl_cd IS 'Type of sales exclusion: NOM=Nominal, HHS=subPHS, etc.';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.over_ind IS 'Override indicator, default is I for include, otherwise E for exclude';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.co_id IS 'Company ID, data source identifier, source: 121 for ICW data';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.cls_of_trd_cd IS 'Class of Trade assigned to transaction customer ID';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.apprvd_ind IS 'Approval indicator for the sales exclusion, Y is approved';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.apprvd_dt IS 'Approval Date for the sales exclusion';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.apprvd_by IS 'Approval User for the sales exclusion';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.adj_cnt IS 'Adjustment count';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.adj_pkg_qty IS 'Adjusted quantity after all adjustments applied';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.adj_total_amt IS 'Adjusted dollars after all adjustments applied';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.nmnl_thres_amt IS 'Nominal Threshold amount';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.trans_adj_cd IS 'Transaction Adjustment Code, the reason for the transaction adjustment';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.root_trans_id IS 'Root Transaction ID, the trans_id of the root transaction in the group';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.parent_trans_id IS 'Parent Transaction ID, the trans_id of the parent transaction in the group';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.trans_dt IS 'Transaction Date, the date of the transaction as used in the audit trail';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.dllr_amt IS 'Dollar amount of the transaction record that is included in the component value or price';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.pkg_qty IS 'Package Quantity of the transaction record that is included in the component value or price';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.chrgbck_amt IS 'Chargeback Dollar amount of the transaction record that is included in the component value or price';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.term_disc_pct IS 'The discount to wholesalers for prompt payment that is included in the component value or price';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.nom_dllr_amt IS 'Dollar amount of the transaction record that is used as part of nominal price determination';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.nom_pkg_qty IS 'Package amount of the transaction record that is used as part of nominal price determination';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.splt_pct_typ IS 'Split percentage type code';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.splt_pct_seq_no IS 'Unique identifier of the percentage on the profile';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.bndl_cd IS 'Bundle Code, used to link all price groups involved in a single bundle';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.bndl_seq_no IS 'Bundle Sequence Number, deprecated, internal sequence number to link audit trail to a bundle';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.create_dt IS 'Creation Date';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.mod_dt IS 'Last Modification Date';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.mod_by IS 'Last Modification User';
COMMENT ON COLUMN hcrs.prfl_sls_excl_new_t.cmt_txt IS 'Comment Text for approval reason';

-- Indexes
CREATE INDEX hcrs.prfl_sls_excl_new_ix1
   ON hcrs.prfl_sls_excl_new_t (prfl_id, trans_id, over_ind)
   TABLESPACE hcrsilg
   COMPRESS 1;

CREATE INDEX hcrs.prfl_sls_excl_new_ix2
   ON hcrs.prfl_sls_excl_new_t (trans_id)
   TABLESPACE hcrsilg;

CREATE INDEX hcrs.prfl_sls_excl_new_ix3
   ON hcrs.prfl_sls_excl_new_t (prfl_id, sls_excl_cd)
   TABLESPACE hcrsilg;

-- Key Contraints
ALTER TABLE hcrs.prfl_sls_excl_new_t
  ADD CONSTRAINT pk_prfl_sls_excl_new_t
  PRIMARY KEY (prfl_id, trans_id);

ALTER TABLE hcrs.prfl_sls_excl_new_t
  ADD CONSTRAINT fk_prfl_sls_excl_new_prfl_co FOREIGN KEY (prfl_id, co_id)
  REFERENCES prfl_co_t (prfl_id, co_id);

-- Check constraints
ALTER TABLE hcrs.prfl_sls_excl_new_t
  ADD CONSTRAINT prfl_sls_excl_new_chk01
  CHECK (over_ind IN ('I', 'E'));

ALTER TABLE hcrs.prfl_sls_excl_new_t
  ADD CONSTRAINT prfl_sls_excl_new_chk02
  CHECK (apprvd_ind IN ('Y', 'N'));

ALTER TABLE hcrs.prfl_sls_excl_new_t
  ADD CONSTRAINT prfl_sls_excl_new_chk03
  CHECK (sls_excl_cd IN ('NOM', 'HHS'));

-- Privileges
GRANT SELECT ON hcrs.prfl_sls_excl_new_t TO hcrs_connect, hcrs_crm_select, hcrs_rpt, hcrs_select;
GRANT SELECT, INSERT, UPDATE, DELETE ON hcrs.prfl_sls_excl_new_t TO hcrs_data_entry, hcrs_manager, hcrs_supervisor;

TIMING STOP hcrs.prfl_sls_excl_new_t
