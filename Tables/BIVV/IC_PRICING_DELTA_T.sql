-- drop table
DROP TABLE BIVV.IC_PRICING_DELTA_T;

-- Create table
CREATE TABLE BIVV.IC_PRICING_DELTA_T
(
  ndc11                 VARCHAR2(40),
  ndc9                  VARCHAR2(10),
  year_qtr              VARCHAR2(5),
  market_date_ndc9      DATE,
  first_sale_date_ndc9  DATE,
  first_sale_date_ndc11 DATE,
  amp_qtrly             NUMBER,
  bp_qtrly              NUMBER,
  base_amp              NUMBER,
  base_amp_qtr          VARCHAR2(5),
  asp_qrtly             NUMBER,
  amp_mth_1             NUMBER,
  amp_mth_2             NUMBER,
  amp_mth_3             NUMBER,
  amp_mth_1_strt_dt     DATE,
  amp_mth_1_end_dt      DATE,
  amp_mth_2_strt_dt     DATE,
  amp_mth_2_end_dt      DATE,
  amp_mth_3_strt_dt     DATE,
  amp_mth_3_end_dt      DATE,
  fcp_annual            NUMBER,
  nfamp_qrtly           NUMBER,
  nfamp_annual          NUMBER,
  wac                   NUMBER,
  wac_strt_dt           DATE,
  wac_end_dt            DATE,
  rm_awp_annual         NUMBER(22,6),
  ura                   NUMBER(22,7),
  ddr_amp               NUMBER(12,6),
  ddr_bp                NUMBER(12,6),
  base_amp_used_for_ura NUMBER(12,6),
  ddr_ura               NUMBER(12,6),
  ddr_parent_amp        NUMBER,
  ddr_parent_bp         NUMBER
);
-- Add comments to the table 
COMMENT ON TABLE BIVV.IC_PRICING_DELTA_T
  IS 'IntegriChain Flex pricing as of 2/12/2021';
