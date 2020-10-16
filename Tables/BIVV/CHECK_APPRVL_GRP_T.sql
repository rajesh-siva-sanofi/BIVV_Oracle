DROP TABLE BIVV.CHECK_APPRVL_GRP_T CASCADE CONSTRAINTS;

-- Create table
create table BIVV.CHECK_APPRVL_GRP_T
(
  apprvl_grp_id     NUMBER not null,
  co_id             NUMBER(9),
  pgm_id            NUMBER(9),
  apprvl_grp_desc   VARCHAR2(200),
  apprvl_amt        NUMBER,
  apprvl_status_cd  VARCHAR2(3) not null,
  ap_sent_dt        DATE,
  create_dt         DATE not null,
  create_by         VARCHAR2(30) not null,
  mod_dt            DATE,
  mod_by            VARCHAR2(30) not null,
  sap_vendor_num    VARCHAR2(20),
  attachment_ref_id NUMBER
);

-- Create/Recreate primary, unique and foreign key constraints 
alter table BIVV.CHECK_APPRVL_GRP_T
  add constraint PK_CHK_APP_GRP_ID primary key (APPRVL_GRP_ID);

