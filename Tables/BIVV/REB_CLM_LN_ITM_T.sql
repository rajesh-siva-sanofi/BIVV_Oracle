DROP TABLE BIVV.REB_CLM_LN_ITM_T CASCADE CONSTRAINTS;

-- Create table
CREATE TABLE BIVV.REB_CLM_LN_ITM_T
(
  pgm_id                   NUMBER(9) NOT NULL,
  ndc_lbl                  VARCHAR2(5) NOT NULL,
  period_id                NUMBER(9) NOT NULL,
  reb_clm_seq_no           NUMBER(4) NOT NULL,
  co_id                    NUMBER(9) NOT NULL,
  ln_itm_seq_no            NUMBER(4) NOT NULL,
  claim_units              NUMBER(12,3) NOT NULL,
  claim_amt                NUMBER(17,2),
  reb_claim_ln_itm_stat_cd VARCHAR2(2) NOT NULL,
  script_cnt               NUMBER(9),
  pgm_pur                  NUMBER(11,6),
  reimbur_amt              NUMBER(12,2),
  corr_flg                 CHAR(1) NOT NULL,
  item_prod_fmly_ndc       VARCHAR2(4) NOT NULL,
  item_prod_mstr_ndc       VARCHAR2(2) NOT NULL,
  create_dt                DATE,
  mod_dt                   DATE,
  mod_by                   VARCHAR2(30),
  nonmed_reimbur_amt       NUMBER(12,2),
  total_reimbur_amt        NUMBER(13,2)
);

-- Create/Recreate primary, unique and foreign key constraints 
ALTER TABLE BIVV.REB_CLM_LN_ITM_T
  ADD CONSTRAINT PK_REB_CLM_LN_ITM_T PRIMARY KEY (PGM_ID, NDC_LBL, PERIOD_ID, REB_CLM_SEQ_NO, CO_ID, LN_ITM_SEQ_NO)
  USING INDEX;
ALTER TABLE BIVV.REB_CLM_LN_ITM_T
  ADD CONSTRAINT FK_REB_CLM_LN_ITM_2_REB_CLAIM FOREIGN KEY (PGM_ID, NDC_LBL, PERIOD_ID, REB_CLM_SEQ_NO, CO_ID)
  REFERENCES BIVV.REB_CLAIM_T (PGM_ID, NDC_LBL, PERIOD_ID, REB_CLM_SEQ_NO, CO_ID) ON DELETE CASCADE;

