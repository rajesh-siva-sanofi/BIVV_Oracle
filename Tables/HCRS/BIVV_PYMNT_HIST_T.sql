DROP TABLE hcrs.BIVV_PYMNT_HIST_T;

-- Create table
CREATE TABLE HCRS.BIVV_PYMNT_HIST_T
(
  load_dt           DATE,
  co_id             NUMBER(9),
  state_cd          VARCHAR2(2),
  pgm_id            NUMBER(9) NOT NULL,
  pgm_nm            VARCHAR2(70) NOT NULL,
  ndc_lbl           VARCHAR2(5),
  ndc_prod          VARCHAR2(4),
  ndc_pckg          VARCHAR2(2),
  ndc               VARCHAR2(13),
  prod_nm           VARCHAR2(134) NOT NULL,
  claim_period_id   NUMBER(9),
  claim_period      VARCHAR2(81),
  reb_clm_seq_no    NUMBER(4),
  check_id          NUMBER(9) NOT NULL,
  paid_amt          NUMBER,
  int_amt           NUMBER,
  check_input_dt    DATE,
  check_req_dt      DATE,
  check_cut_dt      DATE,
  pymnt_catg_cd     VARCHAR2(2),
  pymnt_catg_desc   VARCHAR2(50),
  check_req_stat_cd VARCHAR2(2),
  check_status      VARCHAR2(50),
  check_group_id    NUMBER,
  check_group_desc  VARCHAR2(200),
  create_dt         DATE,
  mod_dt            DATE,
  mod_by            VARCHAR2(30)
);

CREATE OR REPLACE TRIGGER HCRS.BIVV_PYMNT_HIST_T_rbiu_t
 BEFORE INSERT OR UPDATE ON BIVV_PYMNT_HIST_T
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
