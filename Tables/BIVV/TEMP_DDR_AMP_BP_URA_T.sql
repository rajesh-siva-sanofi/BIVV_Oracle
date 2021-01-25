DROP TABLE BIVV.TEMP_DDR_AMP_BP_URA_T;
CREATE TABLE BIVV.TEMP_DDR_AMP_BP_URA_T
(
  period                     VARCHAR2(30),
  ndc                        VARCHAR2(11),
  amp                        NUMBER(12,6),
  best_price                 NUMBER(12,6),
  init_drug_available_for_le VARCHAR2(30),
  init_drug                  VARCHAR2(30),
  base_amp_used_for_ura      NUMBER(12,6),
  ura                        NUMBER(12,6),
  ura_indicatior             VARCHAR2(30),
  cf_ep_cal_indicator        VARCHAR2(30),
  marked_for_deletion        VARCHAR2(30)
);
