DROP TABLE BIVV.CHECK_T CASCADE CONSTRAINTS;

-- Create table
CREATE TABLE BIVV.CHECK_T
(
  check_id  NUMBER(9) NOT NULL,
  check_num VARCHAR2(13) NOT NULL,
  check_amt NUMBER(10,2) NOT NULL,
  create_dt DATE,
  mod_dt    DATE,
  mod_by    VARCHAR2(30)
);
-- Create/Recreate primary, unique and foreign key constraints 
ALTER TABLE BIVV.CHECK_T
  ADD CONSTRAINT PK_CHECK_T PRIMARY KEY (CHECK_ID, CHECK_NUM);

