DROP TABLE BIVV.DSPT_RSN_T CASCADE CONSTRAINTS;

-- Create table
CREATE TABLE BIVV.DSPT_RSN_T
(
  rpr_dspt_rsn_id NUMBER(9) NOT NULL,
  pgm_id          NUMBER(9) NOT NULL,
  ndc_lbl         VARCHAR2(5) NOT NULL,
  period_id       NUMBER(9) NOT NULL,
  reb_clm_seq_no  NUMBER(4) NOT NULL,
  co_id           NUMBER(9) NOT NULL,
  ln_itm_seq_no   NUMBER(4) NOT NULL,
  dspt_seq_no     NUMBER(4) NOT NULL,
  dspt_priority   NUMBER(4),
  create_dt       DATE,
  mod_dt          DATE,
  mod_by          VARCHAR2(30)
);


-- Create/Recreate primary, unique and foreign key constraints 
ALTER TABLE BIVV.DSPT_RSN_T
  ADD CONSTRAINT PK_DSPT_RSN_T PRIMARY KEY (RPR_DSPT_RSN_ID, PGM_ID, NDC_LBL, PERIOD_ID, REB_CLM_SEQ_NO, CO_ID, LN_ITM_SEQ_NO, DSPT_SEQ_NO)
  USING INDEX;

ALTER TABLE BIVV.DSPT_RSN_T
  ADD CONSTRAINT FK_DSPT_RSN_RELATION__DSPT_T FOREIGN KEY (PGM_ID, NDC_LBL, PERIOD_ID, REB_CLM_SEQ_NO, CO_ID, LN_ITM_SEQ_NO, DSPT_SEQ_NO)
  REFERENCES BIVV.DSPT_T (PGM_ID, NDC_LBL, PERIOD_ID, REB_CLM_SEQ_NO, CO_ID, LN_ITM_SEQ_NO, DSPT_SEQ_NO) ON DELETE CASCADE;

