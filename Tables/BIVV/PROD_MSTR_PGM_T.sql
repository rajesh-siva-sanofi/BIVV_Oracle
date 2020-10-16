DROP TABLE BIVV.PROD_MSTR_PGM_T CASCADE CONSTRAINTS;

-- Create table
CREATE TABLE BIVV.PROD_MSTR_PGM_T
(
  pgm_id    NUMBER(9) NOT NULL,
  ndc_lbl   VARCHAR2(5) NOT NULL,
  ndc_prod  VARCHAR2(4) NOT NULL,
  ndc_pckg  VARCHAR2(2) NOT NULL,
  eff_dt    DATE NOT NULL,
  end_dt    DATE DEFAULT to_date('2100-01-01','yyyy-mm-dd') NOT NULL,
  create_dt DATE,
  mod_dt    DATE,
  mod_by    VARCHAR2(30)
);

-- Create/Recreate primary, unique and foreign key constraints 
ALTER TABLE BIVV.PROD_MSTR_PGM_T
  ADD CONSTRAINT PK_PROD_MSTR_PGM_T PRIMARY KEY (PGM_ID, NDC_LBL, NDC_PROD, NDC_PCKG, EFF_DT)
  USING INDEX;

--alter table BIVV.PROD_MSTR_PGM_T
--alter table BIVV.PROD_MSTR_PGM_T
--  add constraint FK_PROD_MST_RELATION__PGM_T foreign key (PGM_ID)
--  references BIVV.PGM_T (PGM_ID) on delete cascade;

-- Create/Recreate check constraints 
ALTER TABLE BIVV.PROD_MSTR_PGM_T
  ADD CONSTRAINT CKT_PROD_MSTR_PGM_T
  CHECK (END_DT >= EFF_DT);
