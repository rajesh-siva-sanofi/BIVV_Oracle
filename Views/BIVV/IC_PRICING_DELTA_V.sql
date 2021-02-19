CREATE OR REPLACE VIEW BIVV.IC_PRICING_DELTA_V AS
WITH 
p AS (
   SELECT t.ndc11, year_qtr, SUBSTR(t.year_qtr,1,4)||'Q'||SUBSTR(t.year_qtr,5,1) AS tim_per_cd
      ,amp_qtrly, bp_qtrly, asp_qrtly, amp_mth_1, amp_mth_2, amp_mth_3
      ,amp_mth_1_strt_dt, amp_mth_1_end_dt, amp_mth_2_strt_dt, amp_mth_2_end_dt, amp_mth_3_strt_dt, amp_mth_3_end_dt
      ,fcp_annual, nfamp_qrtly, nfamp_annual, wac, wac_strt_dt
      -- if WAC has "end of time" in Flex then set it to end of time in HCRS
      ,DECODE(wac_end_dt, to_date('12/31/2099','mm/dd/yyyy'), to_date('1/1/2100','mm/dd/yyyy'), wac_end_dt) AS wac_end_dt
      ,SUBSTR(t.ndc11,1,5) AS ndc_lbl, SUBSTR(t.ndc11,6,4) AS ndc_prod, SUBSTR(t.ndc11,10,2) AS ndc_pckg
      ,add_months(to_date('1/1/'||SUBSTR(t.year_qtr,1,4),'mm/dd/yyyy'),-3) AS anfamp_start
      ,add_months(to_date('1/1/'||SUBSTR(t.year_qtr,1,4),'mm/dd/yyyy'), 9) - 1 AS anfamp_end
      ,to_date(to_char(3 * SUBSTR(t.year_qtr,5,1) - 2)||'/1/'||SUBSTR(t.year_qtr,1,4),'mm/dd/yyyy') AS qtr_start
      ,add_months(to_date(to_char(3 * SUBSTR(t.year_qtr,5,1) - 2)||'/1/'||SUBSTR(t.year_qtr,1,4),'mm/dd/yyyy'), 3) - 1 AS qtr_end
   FROM IC_PRICING_DELTA_T t)
SELECT * 
FROM p
WHERE 1=1
   AND ndc_lbl = '71104'
   AND year_qtr = '20204';
