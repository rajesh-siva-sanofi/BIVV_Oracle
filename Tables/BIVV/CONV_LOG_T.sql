DROP SEQUENCE CONV_LOG_SEQ;

CREATE SEQUENCE CONV_LOG_SEQ
  START WITH 1
  MAXVALUE 9999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 10
  NOORDER;
  
DROP TABLE CONV_LOG_T CASCADE CONSTRAINTS;

CREATE TABLE CONV_LOG_T
(
  LOG_ID   NUMBER NOT NULL,
  PROGRAM  VARCHAR2(100) NOT NULL,
  MODULE   VARCHAR2(100),
  LOG_TXT  VARCHAR2(4000) NOT NULL,
  LASTMOD  TIMESTAMP(6) WITH TIME ZONE DEFAULT systimestamp NOT NULL,
  USERID   VARCHAR2(50) DEFAULT user NOT NULL
);

ALTER TABLE CONV_LOG_T ADD (
  CONSTRAINT CONV_LOG_PK
  PRIMARY KEY (LOG_ID) ENABLE VALIDATE);
  
CREATE BITMAP INDEX conv_log_pgm_bidx ON conv_log_t (program);
  
CREATE OR REPLACE TRIGGER CONV_LOG_IU
BEFORE INSERT OR UPDATE ON CONV_LOG_T
REFERENCING NEW AS New OLD AS Old
FOR EACH ROW
BEGIN
  
  if inserting then
   
    select CONV_LOG_SEQ.nextval 
    into :new.log_id
    from dual;
    
    :new.lastmod := systimestamp;
    :new.userid := user;
  
  elsif updating then
  
    :new.lastmod := systimestamp;
    :new.userid := user;
  
  end if;
      
END;
/
