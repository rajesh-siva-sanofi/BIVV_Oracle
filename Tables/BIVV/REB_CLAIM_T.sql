DROP TABLE BIVV.REB_CLAIM_T CASCADE CONSTRAINTS;

-- Create table
CREATE TABLE BIVV.REB_CLAIM_T
(
  pgm_id               NUMBER(9) NOT NULL,
  ndc_lbl              VARCHAR2(5) NOT NULL,
  period_id            NUMBER(9) NOT NULL,
  reb_clm_seq_no       NUMBER(4) NOT NULL,
  co_id                NUMBER(9) NOT NULL,
  subm_typ_cd          VARCHAR2(2) NOT NULL,
  reb_claim_stat_cd    VARCHAR2(2) NOT NULL,
  pstmrk_dt            DATE NOT NULL,
  pymnt_pstmrk_dt      DATE,
  rcv_dt               DATE NOT NULL,
  input_dt             DATE DEFAULT SYSDATE NOT NULL,
  extd_due_dt          DATE,
  invc_num             VARCHAR2(20),
  tot_claim_units      NUMBER(13,3),
  valid_dt             DATE,
  prelim_run_dt        DATE,
  prelim_sent_dt       DATE,
  prelim_apprv_dt      DATE,
  final_run_dt         DATE,
  dspt_prelim_sent_dt  DATE,
  dspt_prelim_apprv_dt DATE,
  corr_int_flg         VARCHAR2(1),
  create_dt            DATE,
  mod_dt               DATE,
  mod_by               VARCHAR2(30),
  attachment_ref_id    NUMBER
);
-- Create/Recreate primary, unique and foreign key constraints 
ALTER TABLE BIVV.REB_CLAIM_T
  ADD CONSTRAINT REB_CLAIM_PK PRIMARY KEY (PGM_ID, NDC_LBL, PERIOD_ID, REB_CLM_SEQ_NO, CO_ID)
  USING INDEX;
--ALTER TABLE BIVV.REB_CLAIM_T
--  ADD CONSTRAINT FK_REB_CLAIM_2_CO_T FOREIGN KEY (CO_ID)
--  REFERENCES HCRS.CO_T (CO_ID);
--ALTER TABLE BIVV.REB_CLAIM_T
--  ADD CONSTRAINT FK_REB_CLAIM_2_LBL_T FOREIGN KEY (NDC_LBL, CO_ID)
--  REFERENCES HCRS.LBL_T (NDC_LBL, CO_ID);
--ALTER TABLE BIVV.REB_CLAIM_T
--  ADD CONSTRAINT FK_REB_CLAIM_2_PERIOD_T FOREIGN KEY (PERIOD_ID)
--  REFERENCES HCRS.PERIOD_T (PERIOD_ID);
--ALTER TABLE BIVV.REB_CLAIM_T
--  ADD CONSTRAINT FK_REB_CLAIM_2_PGM_T FOREIGN KEY (PGM_ID)
--  REFERENCES HCRS.PGM_T (PGM_ID);

