DROP TABLE BIVV.DSPT_T CASCADE CONSTRAINTS;

-- Create table
CREATE TABLE BIVV.DSPT_T
(
  pgm_id         NUMBER(9) NOT NULL,
  ndc_lbl        VARCHAR2(5) NOT NULL,
  period_id      NUMBER(9) NOT NULL,
  reb_clm_seq_no NUMBER(4) NOT NULL,
  co_id          NUMBER(9) NOT NULL,
  ln_itm_seq_no  NUMBER(4) NOT NULL,
  dspt_seq_no    NUMBER(4) NOT NULL,
  ndc_prod       VARCHAR2(4) NOT NULL,
  ndc_pckg       VARCHAR2(2) NOT NULL,
  paid_units     NUMBER(12,3) NOT NULL,
  dspt_units     NUMBER(12,3) NOT NULL,
  wrt_off_units  NUMBER(12,3) DEFAULT 0 NOT NULL,
  dspt_dt        DATE DEFAULT SYSDATE NOT NULL,
  create_dt      DATE,
  mod_dt         DATE,
  mod_by         VARCHAR2(30),
  note_txt       VARCHAR2(4000)
);
-- Create/Recreate indexes 
CREATE UNIQUE INDEX BIVV.DSPT_T_UN ON BIVV.DSPT_T (NDC_PROD, NDC_PCKG, NDC_LBL, PGM_ID, PERIOD_ID, REB_CLM_SEQ_NO, DSPT_SEQ_NO);
-- Create/Recreate primary, unique and foreign key constraints 
ALTER TABLE BIVV.DSPT_T
  ADD CONSTRAINT PK_DSPT_T PRIMARY KEY (PGM_ID, NDC_LBL, PERIOD_ID, REB_CLM_SEQ_NO, CO_ID, LN_ITM_SEQ_NO, DSPT_SEQ_NO)
  USING INDEX ;

