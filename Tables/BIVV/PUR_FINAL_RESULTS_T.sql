DROP TABLE BIVV.PUR_FINAL_RESULTS_T CASCADE CONSTRAINTS;

-- Create table
CREATE TABLE BIVV.PUR_FINAL_RESULTS_T
(
  period_id         NUMBER NOT NULL,
  per_begin_dt      DATE NOT NULL,
  per_end_dt        DATE NOT NULL,
  pgm_id            NUMBER NOT NULL,
  ndc_lbl           VARCHAR2(5) NOT NULL,
  ndc_prod          VARCHAR2(4) NOT NULL,
  ndc_pckg          VARCHAR2(2) NOT NULL,
  calc_amt          NUMBER NOT NULL,
  eff_dt            DATE NOT NULL,
  end_dt            DATE DEFAULT to_date('2100-01-01','yyyy-mm-dd') NOT NULL,
  create_dt         DATE DEFAULT SYSDATE NOT NULL,
  mod_dt            DATE,
  mod_by            VARCHAR2(30),
  src_sys           VARCHAR2(5),
  src_sys_unique_id NUMBER
);

-- Create/Recreate primary, unique and foreign key constraints 
ALTER TABLE BIVV.PUR_FINAL_RESULTS_T
  ADD CONSTRAINT PK_PUR_FINAL_RESULTS_T PRIMARY KEY (PERIOD_ID, PGM_ID, NDC_LBL, NDC_PROD, NDC_PCKG, EFF_DT)
  USING INDEX;
