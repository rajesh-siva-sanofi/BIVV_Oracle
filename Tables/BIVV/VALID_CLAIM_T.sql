DROP TABLE BIVV.VALID_CLAIM_T CASCADE CONSTRAINTS;

-- Create table
CREATE TABLE BIVV.VALID_CLAIM_T
(
  pgm_id         NUMBER(9) NOT NULL,
  ndc_lbl        VARCHAR2(5) NOT NULL,
  period_id      NUMBER(9) NOT NULL,
  reb_clm_seq_no NUMBER(4) NOT NULL,
  co_id          NUMBER(9) NOT NULL,
  ln_itm_seq_no  NUMBER(4) NOT NULL,
  ndc_prod       VARCHAR2(4) NOT NULL,
  ndc_pckg       VARCHAR2(2) NOT NULL,
  dspt_flg       CHAR(1) NOT NULL,
  claim_units    NUMBER(12,3) NOT NULL,
  claim_amt      NUMBER(17,2),
  script_cnt     NUMBER(9),
  pgm_pur        NUMBER(11,6),
  reimbur_amt    NUMBER(12,2),
  corr_flg       CHAR(1) NOT NULL,
  create_dt      DATE,
  mod_dt         DATE,
  mod_by         VARCHAR2(30)
);

CREATE UNIQUE INDEX BIVV.VALID_CLAIM_T_UN ON BIVV.VALID_CLAIM_T (PERIOD_ID, NDC_PROD, NDC_LBL, NDC_PCKG, PGM_ID, REB_CLM_SEQ_NO);

-- Create/Recreate primary, unique and foreign key constraints 
ALTER TABLE BIVV.VALID_CLAIM_T
  ADD CONSTRAINT PK_VALID_CLAIM_T PRIMARY KEY (PGM_ID, NDC_LBL, PERIOD_ID, REB_CLM_SEQ_NO, CO_ID, LN_ITM_SEQ_NO)
  USING INDEX;

ALTER TABLE BIVV.VALID_CLAIM_T
  ADD CONSTRAINT FK_VALID_CL_INHR_852_REB_CLM_ FOREIGN KEY (PGM_ID, NDC_LBL, PERIOD_ID, REB_CLM_SEQ_NO, CO_ID, LN_ITM_SEQ_NO)
  REFERENCES BIVV.REB_CLM_LN_ITM_T (PGM_ID, NDC_LBL, PERIOD_ID, REB_CLM_SEQ_NO, CO_ID, LN_ITM_SEQ_NO) ON DELETE CASCADE;

-- Create/Recreate check constraints 
ALTER TABLE BIVV.VALID_CLAIM_T
  ADD CONSTRAINT CKC_DSPT_FLG_VALID_CL
  CHECK (DSPT_FLG IN ('Y','N'));
