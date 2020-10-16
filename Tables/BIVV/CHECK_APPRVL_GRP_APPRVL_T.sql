DROP TABLE BIVV.CHECK_APPRVL_GRP_APPRVL_T CASCADE CONSTRAINTS;

-- Create table
create table BIVV.CHECK_APPRVL_GRP_APPRVL_T
(
  apprvl_grp_id       NUMBER not null,
  apprvl_limit_id     NUMBER not null,
  apprvl_reason_cd    VARCHAR2(1) not null,
  apprvr_id           VARCHAR2(30),
  apprvl_dt           DATE,
  comment_txt         VARCHAR2(2000),
  create_dt           DATE not null,
  mod_by              VARCHAR2(30) not null,
  mod_dt              DATE,
  expected_release_dt DATE
);


-- Create/Recreate primary, unique and foreign key constraints 
alter table BIVV.CHECK_APPRVL_GRP_APPRVL_T
  add constraint FK_CHK_APP_GRP_APPRV_GRP_ID foreign key (APPRVL_GRP_ID)
  references BIVV.CHECK_APPRVL_GRP_T (APPRVL_GRP_ID) on delete cascade;

