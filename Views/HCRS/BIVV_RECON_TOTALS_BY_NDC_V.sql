CREATE OR REPLACE VIEW HCRS.BIVV_RECON_TOTALS_BY_NDC_V AS
WITH v AS (
   SELECT ndc11, SUM(flex_auth_units) AS flex_auth_units, SUM(hcrs_paid_units) AS hcrs_paid_units
      ,SUM(flex_paid_amt) AS flex_paid_amt, SUM(hcrs_paid_amt) AS hcrs_paid_amt
      ,SUM(flex_int_amt) AS flex_int_amt, SUM(hcrs_int_amt) AS hcrs_int_amt
   FROM hcrs.bivv_recon_totals_by_ndc_qtr_v
   GROUP BY ndc11)
SELECT
CASE
   WHEN flex_auth_units != hcrs_paid_units THEN 'Paid units different'
   WHEN flex_paid_amt != hcrs_paid_amt THEN 'Paid amounts different'
   WHEN flex_int_amt != hcrs_int_amt THEN 'Interest amounts different'
   ELSE 'OK' END AS valid_msg
   ,v."NDC11",v."FLEX_AUTH_UNITS",v."HCRS_PAID_UNITS",v."FLEX_PAID_AMT",v."HCRS_PAID_AMT",v."FLEX_INT_AMT",v."HCRS_INT_AMT"
FROM v
ORDER BY ndc11;
