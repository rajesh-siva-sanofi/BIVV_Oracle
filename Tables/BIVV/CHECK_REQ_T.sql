DROP TABLE BIVV.CHECK_REQ_T CASCADE CONSTRAINTS;

-- Create table
CREATE TABLE BIVV.CHECK_REQ_T
(
  check_id          NUMBER(9) NOT NULL,
  check_req_stat_cd VARCHAR2(2) NOT NULL,
  pymnt_catg_cd     VARCHAR2(2) NOT NULL,
  credit_num        VARCHAR2(10),
  check_req_amt     NUMBER(10,2) NOT NULL,
  cr_bal            NUMBER(10,2) NOT NULL,
  check_input_dt    DATE DEFAULT SYSDATE NOT NULL,
  check_dt          DATE,
  conf_dt           DATE,
  prcss_dt          DATE,
  mail_dt           DATE,
  check_req_dt      DATE,
  payer_notif_dt    DATE,
  pgm_id            NUMBER(9) NOT NULL,
  co_id             NUMBER(9) NOT NULL,
  int_sel_meth_cd   VARCHAR2(2),
  man_int_amt       NUMBER(10,2),
  rosi_flg          CHAR(1),
  pqas_flg          CHAR(1),
  est_check_mail_dt DATE,
  create_dt         DATE,
  mod_dt            DATE,
  mod_by            VARCHAR2(30),
  amt_changed_flg   VARCHAR2(1),
  cmt_txt           VARCHAR2(2000),
  attachment_ref_id NUMBER
);

-- can't creat primary check_id key since that will only be added in prod copy, but wwe'll ensure uniqness at least
CREATE UNIQUE INDEX BIVV.CHECK_REQ_T_CHK_ID ON BIVV.CHECK_REQ_T (CHECK_ID);

-- Create/Recreate check constraints 
ALTER TABLE BIVV.CHECK_REQ_T
  ADD CONSTRAINT CKC_PQAS_FLG_CHECK_RE
  CHECK (PQAS_FLG IS NULL OR (PQAS_FLG IN ('Y','N')));
ALTER TABLE BIVV.CHECK_REQ_T
  ADD CONSTRAINT CKC_ROSI_FLG_CHECK_RE
  CHECK (ROSI_FLG IS NULL OR (ROSI_FLG IN ('Y','N')));
ALTER TABLE BIVV.CHECK_REQ_T
  ADD CONSTRAINT CK_CMT_TXT
  CHECK ((check_req_stat_cd = 'NS' AND CMT_TXT IS NOT NULL) OR check_req_stat_cd <> 'NS');
