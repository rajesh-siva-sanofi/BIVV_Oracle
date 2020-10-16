DROP TABLE HCRS.BIVV_CLAIM_HIST_T;

-- Create table
CREATE TABLE HCRS.BIVV_CLAIM_HIST_T
(
  load_dt                  DATE,
  src                      CHAR(2),
  co_id                    NUMBER(9),
  co_nm                    VARCHAR2(20) NOT NULL,
  period_id                NUMBER(9),
  claim_period             VARCHAR2(81),
  state_cd                 VARCHAR2(2),
  pgm_id                   NUMBER(9),
  pgm_nm                   VARCHAR2(70) NOT NULL,
  ndc_lbl                  VARCHAR2(5),
  ndc_prod                 VARCHAR2(4),
  ndc_pckg                 VARCHAR2(2),
  prod_nm                  VARCHAR2(134) NOT NULL,
  reb_clm_seq_no           NUMBER(4),
  ln_itm_seq_no            NUMBER(4),
  pgm_pur                  NUMBER(11,6),
  ura                      NUMBER,
  claim_units              NUMBER,
  claim_amt                NUMBER,
  paid_units               NUMBER,
  paid_amt                 NUMBER,
  int_amt                  NUMBER,
  dspt_units               NUMBER,
  dspt_amt                 NUMBER,
  wrt_off_units            NUMBER,
  wrt_off_amt              NUMBER,
  dspt_seq_no              NUMBER,
  rpr_dspt_rsn_id          NUMBER,
  rpr_dspt_rsn_descr       VARCHAR2(200),
  dispute_reason           VARCHAR2(200),
  reb_claim_stat_cd        VARCHAR2(2) NOT NULL,
  reb_claim_ln_itm_stat_cd VARCHAR2(2),
  check_id                 NUMBER(9),
  subm_typ_cd              VARCHAR2(2) NOT NULL,
  pstmrk_dt                DATE NOT NULL,
  prcss_day_limit          NUMBER(5) NOT NULL,
  rcv_dt                   DATE NOT NULL,
  input_dt                 DATE NOT NULL,
  invc_num                 VARCHAR2(20),
  script_cnt               NUMBER,
  reimbur_amt              NUMBER,
  nonmed_reimbur_amt       NUMBER,
  total_reimbur_amt        NUMBER,
  valid_dt                 DATE,
  prelim_run_dt            DATE,
  final_run_dt             DATE,
  due_dt                   DATE,
  util_rec_typ             VARCHAR2(20) NOT NULL,
  create_dt                DATE,
  mod_dt                   DATE,
  mod_by                   VARCHAR2(30)
);

CREATE OR REPLACE TRIGGER HCRS.BIVV_CLAIM_HIST_T_rbiu_t
 BEFORE INSERT OR UPDATE ON BIVV_CLAIM_HIST_T
 FOR EACH ROW

BEGIN
   IF INSERTING THEN
      :NEW.create_dt    := SYSDATE;
      :NEW.mod_dt       := SYSDATE;
      :NEW.mod_by       := USER;
   ELSIF UPDATING THEN
      :NEW.mod_dt       := SYSDATE;
      :NEW.mod_by       := USER;
   END IF;
END;
/
