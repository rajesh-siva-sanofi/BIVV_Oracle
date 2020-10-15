-- ============================================================================================
-- File		: Insert Biogen/Bioverativ Product Data into HCRS
--
-- Author	: John Tronoski, (IntegriChain)
-- Created	: September, 2020
--
-- Modified 	: 
--		  ...JTronoski 09.27.2020  (IntegriChain)
--
-- Purpose  	: This SQL will be used to load the Biogen and Bioverativ products from the 
--                BIVV Staging Tables to the HCRS Product Tables.
--
--                The following steps will be executed:
--                  1. Display Biogen and Bioverativ products in the HCRS Products tables before the script runs
--                  2. Insert Biogen and Bioverativ products into hcrs.lbl_t
--                  3. Insert Biogen and Bioverativ products into hcrs.prod_fmly_t
--                  4. Insert Biogen and Bioverativ products into hcrs.prod_mstr_t
--                  5. Insert Biogen and Bioverativ products into hcrs.co_prod_mstr_t
--                  6. Insert Biogen and Bioverativ products into hcrs.prod_fmly_drug_catg_t
--                  7. Insert Biogen and Bioverativ products into hcrs.prod_fmly_ppaca_t
--                  8. Display Biogen and Bioverativ products in the HCRS Products tables after the script has run
--
-- Parameters  	: N/A
--
-- Status  	: N/A
--
-- Information 	: This script should be run in the HCRS Instance
--
-- Issues  	: N/A
--
-- SQL  	: N/A
--
-- ============================================================================================

SET PAGESIZE 50000
SET LINESIZE 10000
SET ECHO ON
SET TAB OFF
SET FEEDBACK ON
SET DEFINE OFF
SET TRIMSPOOL ON
SET SERVEROUTPUT ON SIZE 1000000
SET SQLBLANKLINES ON
SET TIMING ON

-- Alter Date and Time Format
ALTER SESSION SET NLS_DATE_FORMAT = 'MM/DD/YYYY HH24:MI:SS';
COMMIT;

-- In what database instance is this run?
SELECT * FROM global_name;

-- What time did this start running?
SELECT SYSDATE FROM dual;

--------------------------------------------------------------------------------
-- Show affected records before change
--------------------------------------------------------------------------------

SELECT *
  FROM hcrs.lbl_t t
 WHERE ndc_lbl IN ('64406','71104')
 ORDER BY 1, 2;

SELECT *
  FROM hcrs.co_prod_mstr_t t
 WHERE t.ndc_lbl IN
       (
         SELECT t0.ndc_lbl
           FROM hcrs.lbl_t t0
          WHERE t0.ndc_lbl IN ('64406','71104')
       )
 ORDER BY 1, 2, 3, 4;

SELECT *
  FROM hcrs.prod_fmly_t t
 WHERE t.ndc_lbl IN
       (
         SELECT t0.ndc_lbl
           FROM hcrs.lbl_t t0
          WHERE t0.ndc_lbl IN ('64406','71104')
       )
 ORDER BY 1, 2;

SELECT *
  FROM hcrs.prod_fmly_drug_catg_t t
 WHERE t.ndc_lbl IN
       (
         SELECT t0.ndc_lbl
           FROM hcrs.lbl_t t0
          WHERE t0.ndc_lbl IN ('64406','71104')
       )
 ORDER BY 1, 2;

SELECT *
  FROM hcrs.prod_fmly_ppaca_t t
 WHERE t.ndc_lbl IN
       (
         SELECT t0.ndc_lbl
           FROM hcrs.lbl_t t0
          WHERE t0.ndc_lbl IN ('64406','71104')
       )
 ORDER BY 1, 2;

SELECT *
  FROM hcrs.prod_mstr_t t
 WHERE t.ndc_lbl IN
       (
         SELECT t0.ndc_lbl
           FROM hcrs.lbl_t t0
          WHERE t0.ndc_lbl IN ('64406','71104')
       )
 ORDER BY 1, 2;


--------------------------------------------------------------------------------
-- P-01: Insert 2 Labelers into hcrs.lbl_t
--------------------------------------------------------------------------------

INSERT INTO hcrs.lbl_t
(ndc_lbl, eff_dt, end_dt, va_active_flg, co_id)
SELECT x.ndc_lbl, x.eff_dt, x.end_dt, x.va_active_flg, x.co_id
  FROM bivv.lbl_t x
 WHERE NOT EXISTS (SELECT 'x'
                     FROM hcrs.lbl_t xx
                    WHERE xx.ndc_lbl = x.ndc_lbl)
;

UPDATE hcrs.lbl_t xx
   SET xx.eff_dt = (SELECT eff_dt
                      FROM bivv.lbl_t x
                     WHERE x.ndc_lbl = xx.ndc_lbl)
      ,xx.end_dt = (SELECT end_dt
                      FROM bivv.lbl_t x
                     WHERE x.ndc_lbl = xx.ndc_lbl)
      ,xx.va_active_flg = (SELECT va_active_flg
                             FROM bivv.lbl_t x
                            WHERE x.ndc_lbl = xx.ndc_lbl)
      ,xx.co_id = (SELECT co_id
                     FROM bivv.lbl_t x
                    WHERE x.ndc_lbl = xx.ndc_lbl)
 WHERE xx.ndc_lbl IN (SELECT ndc_lbl
                        FROM bivv.lbl_t)
;

--------------------------------------------------------------------------------
-- P-02: Insert 32 Products into hcrs.prod_fmly_t
--------------------------------------------------------------------------------

INSERT INTO hcrs.prod_fmly_t
(ndc_lbl, ndc_prod, fda_desi_cd, drug_typ_cd, fda_thera_cd, prod_fmly_nm, mkt_entry_dt
,hcfa_unit_typ_cd, potency_flg, ndc_id, form, strength, purchase_prod_dt, nonrtl_route_of_admin
,nonrtl_drug_ind, cod_stat, otc_mono_num, fda_application_num, line_extension_ind)
SELECT ndc_lbl, ndc_prod, fda_desi_cd, drug_typ_cd, fda_thera_cd, prod_fmly_nm, mkt_entry_dt
      ,hcfa_unit_typ_cd, potency_flg, ndc_id, form, strength, purchase_prod_dt, nonrtl_route_of_admin
      ,nonrtl_drug_ind, cod_stat, otc_mono_num, fda_application_num, line_extension_ind
  FROM bivv.prod_fmly_t x
 WHERE NOT EXISTS (SELECT 'x'
                     FROM hcrs.prod_fmly_t xx
                    WHERE xx.ndc_lbl = x.ndc_lbl
                      AND xx.ndc_prod = x.ndc_prod)
;

UPDATE hcrs.prod_fmly_t xx
   SET xx.fda_desi_cd = (SELECT fda_desi_cd
                           FROM bivv.prod_fmly_t x
                          WHERE x.ndc_lbl = xx.ndc_lbl
                            AND x.ndc_prod = xx.ndc_prod)
      ,xx.drug_typ_cd = (SELECT drug_typ_cd
                           FROM bivv.prod_fmly_t x
                          WHERE x.ndc_lbl = xx.ndc_lbl
                            AND x.ndc_prod = xx.ndc_prod)
      ,xx.fda_thera_cd = (SELECT fda_thera_cd
                           FROM bivv.prod_fmly_t x
                          WHERE x.ndc_lbl = xx.ndc_lbl
                            AND x.ndc_prod = xx.ndc_prod)
      ,xx.prod_fmly_nm = (SELECT prod_fmly_nm
                            FROM bivv.prod_fmly_t x
                           WHERE x.ndc_lbl = xx.ndc_lbl
                            AND x.ndc_prod = xx.ndc_prod)
      ,xx.mkt_entry_dt = (SELECT mkt_entry_dt
                            FROM bivv.prod_fmly_t x
                           WHERE x.ndc_lbl = xx.ndc_lbl
                             AND x.ndc_prod = xx.ndc_prod)
      ,xx.hcfa_unit_typ_cd = (SELECT hcfa_unit_typ_cd
                                FROM bivv.prod_fmly_t x
                               WHERE x.ndc_lbl = xx.ndc_lbl
                                 AND x.ndc_prod = xx.ndc_prod)
      ,xx.potency_flg = (SELECT potency_flg
                           FROM bivv.prod_fmly_t x
                          WHERE x.ndc_lbl = xx.ndc_lbl
                            AND x.ndc_prod = xx.ndc_prod)
      ,xx.ndc_id = (SELECT ndc_id
                      FROM bivv.prod_fmly_t x
                     WHERE x.ndc_lbl = xx.ndc_lbl
                       AND x.ndc_prod = xx.ndc_prod)
      ,xx.form = (SELECT form
                    FROM bivv.prod_fmly_t x
                   WHERE x.ndc_lbl = xx.ndc_lbl
                     AND x.ndc_prod = xx.ndc_prod)
      ,xx.strength = (SELECT strength
                        FROM bivv.prod_fmly_t x
                       WHERE x.ndc_lbl = xx.ndc_lbl
                         AND x.ndc_prod = xx.ndc_prod)
      ,xx.purchase_prod_dt = (SELECT purchase_prod_dt
                                FROM bivv.prod_fmly_t x
                               WHERE x.ndc_lbl = xx.ndc_lbl
                                 AND x.ndc_prod = xx.ndc_prod)
      ,xx.nonrtl_route_of_admin = (SELECT nonrtl_route_of_admin
                                     FROM bivv.prod_fmly_t x
                                    WHERE x.ndc_lbl = xx.ndc_lbl
                                      AND x.ndc_prod = xx.ndc_prod)
      ,xx.nonrtl_drug_ind = (SELECT nonrtl_drug_ind
                               FROM bivv.prod_fmly_t x
                              WHERE x.ndc_lbl = xx.ndc_lbl
                                AND x.ndc_prod = xx.ndc_prod)
      ,xx.cod_stat = (SELECT cod_stat
                        FROM bivv.prod_fmly_t x
                       WHERE x.ndc_lbl = xx.ndc_lbl
                         AND x.ndc_prod = xx.ndc_prod)
      ,xx.otc_mono_num = (SELECT otc_mono_num
                            FROM bivv.prod_fmly_t x
                           WHERE x.ndc_lbl = xx.ndc_lbl
                             AND x.ndc_prod = xx.ndc_prod)
      ,xx.fda_application_num = (SELECT fda_application_num
                                   FROM bivv.prod_fmly_t x
                                  WHERE x.ndc_lbl = xx.ndc_lbl
                                    AND x.ndc_prod = xx.ndc_prod)
      ,xx.line_extension_ind = (SELECT line_extension_ind
                                  FROM bivv.prod_fmly_t x
                                 WHERE x.ndc_lbl = xx.ndc_lbl
                                   AND x.ndc_prod = xx.ndc_prod)
 WHERE EXISTS (SELECT 'x'
                 FROM bivv.prod_fmly_t x
                WHERE x.ndc_lbl = xx.ndc_lbl
                  AND x.ndc_prod = xx.ndc_prod)
;

--------------------------------------------------------------------------------
-- P-03: Insert 32 Products into hcrs.prod_mstr_t
--------------------------------------------------------------------------------

INSERT INTO hcrs.prod_mstr_t
(ndc_lbl, ndc_prod, ndc_pckg, unit_per_pckg, hcfa_disp_units, first_dt_sld_dir, shelf_life_mon
,elig_stat_cd, inelig_rsn_id, fda_approval_dt, liablty_mon, new_prod_flg, first_dt_sld, divestr_dt
,final_lot_dt, promo_stat_cd, ndc_id, cosmis_ndc , cosmis_descr, pckg_nm, coc_schm_id, rec_src_ind
,mrkt_entry_dt, gnrc_nm, medicare_elig_stat_cd, sap_prod_cd, items_per_ndc, volume_per_item
,medicare_exp_trnsmitted_dt, comm_unit_per_pckg, pname_desc, strngtyp_id, sizetyp_id, pkgtyp_id
,formtyp_id, sap_company_cd, cars_sap_prod_cd, va_drug_catg_cd, va_elig_stat_cd, phs_elig_stat_cd
,fdb_case_size, fdb_package_size)
SELECT ndc_lbl, ndc_prod, ndc_pckg, unit_per_pckg, hcfa_disp_units, first_dt_sld_dir, shelf_life_mon
      ,elig_stat_cd, inelig_rsn_id, fda_approval_dt, liablty_mon, new_prod_flg, first_dt_sld, divestr_dt
      ,final_lot_dt, promo_stat_cd, ndc_id, cosmis_ndc , cosmis_descr, pckg_nm, coc_schm_id, rec_src_ind
      ,mrkt_entry_dt, gnrc_nm, medicare_elig_stat_cd, sap_prod_cd, items_per_ndc, volume_per_item
      ,medicare_exp_trnsmitted_dt, comm_unit_per_pckg, pname_desc, strngtyp_id, sizetyp_id, pkgtyp_id
      ,formtyp_id, sap_company_cd, cars_sap_prod_cd, va_drug_catg_cd, va_elig_stat_cd, phs_elig_stat_cd
      ,fdb_case_size, fdb_package_size 
  FROM bivv.prod_mstr_t x
 WHERE NOT EXISTS (SELECT 'x'
                     FROM hcrs.prod_mstr_t xx
                    WHERE xx.ndc_lbl = x.ndc_lbl
                      AND xx.ndc_prod = x.ndc_prod
                      AND xx.ndc_pckg = x.ndc_pckg)
;

UPDATE hcrs.prod_mstr_t xx
   SET xx.hcfa_disp_units = (SELECT hcfa_disp_units
                               FROM bivv.prod_mstr_t x
                              WHERE x.ndc_lbl = xx.ndc_lbl
                                AND x.ndc_prod = xx.ndc_prod)
      ,xx.first_dt_sld_dir = (SELECT first_dt_sld_dir
                                FROM bivv.prod_mstr_t x
                               WHERE x.ndc_lbl = xx.ndc_lbl
                                 AND x.ndc_prod = xx.ndc_prod)
      ,xx.shelf_life_mon = (SELECT shelf_life_mon
                              FROM bivv.prod_mstr_t x
                             WHERE x.ndc_lbl = xx.ndc_lbl
                               AND x.ndc_prod = xx.ndc_prod)
      ,xx.elig_stat_cd = (SELECT elig_stat_cd
                            FROM bivv.prod_mstr_t x
                           WHERE x.ndc_lbl = xx.ndc_lbl
                             AND x.ndc_prod = xx.ndc_prod)
      ,xx.inelig_rsn_id = (SELECT inelig_rsn_id
                             FROM bivv.prod_mstr_t x
                            WHERE x.ndc_lbl = xx.ndc_lbl
                              AND x.ndc_prod = xx.ndc_prod)
      ,xx.fda_approval_dt = (SELECT fda_approval_dt
                               FROM bivv.prod_mstr_t x
                              WHERE x.ndc_lbl = xx.ndc_lbl
                                AND x.ndc_prod = xx.ndc_prod)
      ,xx.liablty_mon = (SELECT liablty_mon
                           FROM bivv.prod_mstr_t x
                          WHERE x.ndc_lbl = xx.ndc_lbl
                            AND x.ndc_prod = xx.ndc_prod)
      ,xx.new_prod_flg = (SELECT new_prod_flg
                            FROM bivv.prod_mstr_t x
                           WHERE x.ndc_lbl = xx.ndc_lbl
                             AND x.ndc_prod = xx.ndc_prod)
      ,xx.first_dt_sld = (SELECT first_dt_sld
                            FROM bivv.prod_mstr_t x
                           WHERE x.ndc_lbl = xx.ndc_lbl
                             AND x.ndc_prod = xx.ndc_prod)
      ,xx.divestr_dt = (SELECT divestr_dt
                          FROM bivv.prod_mstr_t x
                         WHERE x.ndc_lbl = xx.ndc_lbl
                           AND x.ndc_prod = xx.ndc_prod)
      ,xx.final_lot_dt = (SELECT final_lot_dt
                            FROM bivv.prod_mstr_t x
                           WHERE x.ndc_lbl = xx.ndc_lbl
                             AND x.ndc_prod = xx.ndc_prod)
      ,xx.promo_stat_cd = (SELECT promo_stat_cd
                             FROM bivv.prod_mstr_t x
                            WHERE x.ndc_lbl = xx.ndc_lbl
                              AND x.ndc_prod = xx.ndc_prod)
      ,xx.ndc_id = (SELECT ndc_id
                      FROM bivv.prod_mstr_t x
                     WHERE x.ndc_lbl = xx.ndc_lbl
                       AND x.ndc_prod = xx.ndc_prod)
      ,xx.cosmis_ndc = (SELECT cosmis_ndc
                          FROM bivv.prod_mstr_t x
                         WHERE x.ndc_lbl = xx.ndc_lbl
                           AND x.ndc_prod = xx.ndc_prod)
      ,xx.cosmis_descr = (SELECT cosmis_descr
                            FROM bivv.prod_mstr_t x
                           WHERE x.ndc_lbl = xx.ndc_lbl
                             AND x.ndc_prod = xx.ndc_prod)
      ,xx.pckg_nm = (SELECT pckg_nm
                       FROM bivv.prod_mstr_t x
                      WHERE x.ndc_lbl = xx.ndc_lbl
                        AND x.ndc_prod = xx.ndc_prod)
      ,xx.coc_schm_id = (SELECT coc_schm_id
                           FROM bivv.prod_mstr_t x
                          WHERE x.ndc_lbl = xx.ndc_lbl
                            AND x.ndc_prod = xx.ndc_prod)
      ,xx.rec_src_ind = (SELECT rec_src_ind
                           FROM bivv.prod_mstr_t x
                          WHERE x.ndc_lbl = xx.ndc_lbl
                            AND x.ndc_prod = xx.ndc_prod)
      ,xx.mrkt_entry_dt = (SELECT mrkt_entry_dt
                             FROM bivv.prod_mstr_t x
                            WHERE x.ndc_lbl = xx.ndc_lbl
                              AND x.ndc_prod = xx.ndc_prod)
      ,xx.gnrc_nm = (SELECT gnrc_nm
                       FROM bivv.prod_mstr_t x
                      WHERE x.ndc_lbl = xx.ndc_lbl
                        AND x.ndc_prod = xx.ndc_prod)
      ,xx.medicare_elig_stat_cd = (SELECT medicare_elig_stat_cd
                                     FROM bivv.prod_mstr_t x
                                    WHERE x.ndc_lbl = xx.ndc_lbl
                                      AND x.ndc_prod = xx.ndc_prod)
      ,xx.sap_prod_cd = (SELECT sap_prod_cd
                           FROM bivv.prod_mstr_t x
                          WHERE x.ndc_lbl = xx.ndc_lbl
                            AND x.ndc_prod = xx.ndc_prod)
      ,xx.items_per_ndc = (SELECT items_per_ndc
                             FROM bivv.prod_mstr_t x
                            WHERE x.ndc_lbl = xx.ndc_lbl
                              AND x.ndc_prod = xx.ndc_prod)
      ,xx.volume_per_item = (SELECT volume_per_item
                               FROM bivv.prod_mstr_t x
                              WHERE x.ndc_lbl = xx.ndc_lbl
                                AND x.ndc_prod = xx.ndc_prod)
      ,xx.medicare_exp_trnsmitted_dt = (SELECT medicare_exp_trnsmitted_dt
                                          FROM bivv.prod_mstr_t x
                                         WHERE x.ndc_lbl = xx.ndc_lbl
                                           AND x.ndc_prod = xx.ndc_prod)
      ,xx.comm_unit_per_pckg = (SELECT comm_unit_per_pckg
                                  FROM bivv.prod_mstr_t x
                                 WHERE x.ndc_lbl = xx.ndc_lbl
                                   AND x.ndc_prod = xx.ndc_prod)
      ,xx.pname_desc = (SELECT pname_desc
                          FROM bivv.prod_mstr_t x
                         WHERE x.ndc_lbl = xx.ndc_lbl
                           AND x.ndc_prod = xx.ndc_prod)
      ,xx.strngtyp_id = (SELECT strngtyp_id
                           FROM bivv.prod_mstr_t x
                          WHERE x.ndc_lbl = xx.ndc_lbl
                            AND x.ndc_prod = xx.ndc_prod)
      ,xx.sizetyp_id = (SELECT sizetyp_id
                          FROM bivv.prod_mstr_t x
                         WHERE x.ndc_lbl = xx.ndc_lbl
                           AND x.ndc_prod = xx.ndc_prod)
      ,xx.pkgtyp_id = (SELECT pkgtyp_id
                         FROM bivv.prod_mstr_t x
                        WHERE x.ndc_lbl = xx.ndc_lbl
                          AND x.ndc_prod = xx.ndc_prod)
      ,xx.formtyp_id = (SELECT formtyp_id
                          FROM bivv.prod_mstr_t x
                         WHERE x.ndc_lbl = xx.ndc_lbl
                           AND x.ndc_prod = xx.ndc_prod)
      ,xx.sap_company_cd = (SELECT sap_company_cd
                              FROM bivv.prod_mstr_t x
                             WHERE x.ndc_lbl = xx.ndc_lbl
                               AND x.ndc_prod = xx.ndc_prod)
      ,xx.cars_sap_prod_cd = (SELECT cars_sap_prod_cd
                                FROM bivv.prod_mstr_t x
                               WHERE x.ndc_lbl = xx.ndc_lbl
                                 AND x.ndc_prod = xx.ndc_prod)
      ,xx.va_drug_catg_cd = (SELECT va_drug_catg_cd
                               FROM bivv.prod_mstr_t x
                              WHERE x.ndc_lbl = xx.ndc_lbl
                                AND x.ndc_prod = xx.ndc_prod)
      ,xx.va_elig_stat_cd = (SELECT va_elig_stat_cd
                               FROM bivv.prod_mstr_t x
                              WHERE x.ndc_lbl = xx.ndc_lbl
                                AND x.ndc_prod = xx.ndc_prod)
      ,xx.phs_elig_stat_cd = (SELECT phs_elig_stat_cd
                                FROM bivv.prod_mstr_t x
                               WHERE x.ndc_lbl = xx.ndc_lbl
                                 AND x.ndc_prod = xx.ndc_prod)
      ,xx.fdb_case_size = (SELECT fdb_case_size
                             FROM bivv.prod_mstr_t x
                            WHERE x.ndc_lbl = xx.ndc_lbl
                              AND x.ndc_prod = xx.ndc_prod)
      ,xx.fdb_package_size = (SELECT fdb_package_size
                                FROM bivv.prod_mstr_t x
                               WHERE x.ndc_lbl = xx.ndc_lbl
                                 AND x.ndc_prod = xx.ndc_prod)
 WHERE EXISTS (SELECT 'x'
                 FROM bivv.prod_mstr_t x
                WHERE x.ndc_lbl = xx.ndc_lbl
                  AND x.ndc_prod = xx.ndc_prod)
;

--------------------------------------------------------------------------------
-- P-04: Insert 32 Products into hcrs.co_prod_mstr_t
--------------------------------------------------------------------------------

INSERT INTO hcrs.co_prod_mstr_t
(ndc_lbl, ndc_prod, ndc_pckg, eff_dt, end_dt, co_id)
SELECT ndc_lbl, ndc_prod, ndc_pckg, eff_dt, end_dt, co_id
  FROM bivv.co_prod_mstr_t x
 WHERE NOT EXISTS (SELECT 'x'
                     FROM hcrs.co_prod_mstr_t xx
                    WHERE xx.ndc_lbl = x.ndc_lbl
                      AND xx.ndc_prod = x.ndc_prod)
;

UPDATE hcrs.co_prod_mstr_t xx
   SET xx.eff_dt = (SELECT eff_dt
                      FROM bivv.co_prod_mstr_t x
                     WHERE x.ndc_lbl = xx.ndc_lbl
                       AND x.ndc_prod = xx.ndc_prod)
      ,xx.end_dt = (SELECT end_dt
                      FROM bivv.co_prod_mstr_t x
                     WHERE x.ndc_lbl = xx.ndc_lbl
                       AND x.ndc_prod = xx.ndc_prod)
      ,xx.co_id = (SELECT co_id
                     FROM bivv.co_prod_mstr_t x
                    WHERE x.ndc_lbl = xx.ndc_lbl
                      AND x.ndc_prod = xx.ndc_prod)
 WHERE EXISTS (SELECT 'x'
                 FROM bivv.co_prod_mstr_t x
                WHERE x.ndc_lbl = xx.ndc_lbl
                  AND x.ndc_prod = xx.ndc_prod)
;

--------------------------------------------------------------------------------
-- P-05: Insert 32 Products into hcrs.prod_fmly_drug_catg_t
--------------------------------------------------------------------------------

INSERT INTO hcrs.prod_fmly_drug_catg_t
(ndc_lbl, ndc_prod, eff_dt, drug_catg_cd, end_dt, medicare_drug_catg_cd)
SELECT ndc_lbl, ndc_prod, eff_dt, drug_catg_cd, end_dt, medicare_drug_catg_cd
  FROM bivv.prod_fmly_drug_catg_t x
 WHERE NOT EXISTS (SELECT 'x'
                     FROM hcrs.prod_fmly_drug_catg_t xx
                    WHERE xx.ndc_lbl = x.ndc_lbl
                      AND xx.ndc_prod = x.ndc_prod)
;

UPDATE hcrs.prod_fmly_drug_catg_t xx
   SET xx.eff_dt = (SELECT eff_dt
                      FROM bivv.prod_fmly_drug_catg_t x
                     WHERE x.ndc_lbl = xx.ndc_lbl
                       AND x.ndc_prod = xx.ndc_prod)
      ,xx.drug_catg_cd = (SELECT drug_catg_cd
                            FROM bivv.prod_fmly_drug_catg_t x
                           WHERE x.ndc_lbl = xx.ndc_lbl
                             AND x.ndc_prod = xx.ndc_prod)
      ,xx.end_dt = (SELECT end_dt
                      FROM bivv.prod_fmly_drug_catg_t x
                     WHERE x.ndc_lbl = xx.ndc_lbl
                       AND x.ndc_prod = xx.ndc_prod)
      ,xx.medicare_drug_catg_cd = (SELECT medicare_drug_catg_cd
                                     FROM bivv.prod_fmly_drug_catg_t x
                                    WHERE x.ndc_lbl = xx.ndc_lbl
                                      AND x.ndc_prod = xx.ndc_prod)
 WHERE EXISTS (SELECT 'x'
                 FROM bivv.prod_fmly_drug_catg_t x
                WHERE x.ndc_lbl = xx.ndc_lbl
                  AND x.ndc_prod = xx.ndc_prod)
;

--------------------------------------------------------------------------------
-- P-06: Insert 32 Products into hcrs.prod_fmly_ppaca_t
--------------------------------------------------------------------------------

INSERT INTO hcrs.prod_fmly_ppaca_t
(ndc_lbl, ndc_prod, eff_bgn_dt, eff_end_dt, tim_per_bgn_dt, tim_per_end_dt, ppaca_rtl_ind)
SELECT ndc_lbl, ndc_prod, eff_bgn_dt, eff_end_dt, tim_per_bgn_dt, tim_per_end_dt, ppaca_rtl_ind
  FROM bivv.prod_fmly_ppaca_t x
 WHERE NOT EXISTS (SELECT 'x'
                     FROM hcrs.prod_fmly_ppaca_t xx
                    WHERE xx.ndc_lbl = x.ndc_lbl
                      AND xx.ndc_prod = x.ndc_prod)
;

UPDATE hcrs.prod_fmly_ppaca_t xx
   SET xx.eff_bgn_dt = (SELECT eff_bgn_dt
                          FROM bivv.prod_fmly_ppaca_t x
                         WHERE x.ndc_lbl = xx.ndc_lbl
                           AND x.ndc_prod = xx.ndc_prod)
      ,xx.eff_end_dt = (SELECT eff_end_dt
                          FROM bivv.prod_fmly_ppaca_t x
                         WHERE x.ndc_lbl = xx.ndc_lbl
                           AND x.ndc_prod = xx.ndc_prod)
      ,xx.tim_per_bgn_dt = (SELECT tim_per_bgn_dt
                              FROM bivv.prod_fmly_ppaca_t x
                             WHERE x.ndc_lbl = xx.ndc_lbl
                               AND x.ndc_prod = xx.ndc_prod)
      ,xx.tim_per_end_dt = (SELECT tim_per_end_dt
                              FROM bivv.prod_fmly_ppaca_t x
                             WHERE x.ndc_lbl = xx.ndc_lbl
                               AND x.ndc_prod = xx.ndc_prod)
      ,xx.ppaca_rtl_ind = (SELECT ppaca_rtl_ind
                             FROM bivv.prod_fmly_ppaca_t x
                            WHERE x.ndc_lbl = xx.ndc_lbl
                              AND x.ndc_prod = xx.ndc_prod)
 WHERE EXISTS (SELECT 'x'
                 FROM bivv.prod_fmly_ppaca_t x
                WHERE x.ndc_lbl = xx.ndc_lbl
                  AND x.ndc_prod = xx.ndc_prod)
;


--------------------------------------------------------------------------------
-- Show affected records after change
--------------------------------------------------------------------------------

SELECT *
  FROM hcrs.lbl_t t
 WHERE ndc_lbl IN ('64406','71104')
 ORDER BY 1, 2;

SELECT *
  FROM hcrs.co_prod_mstr_t t
 WHERE t.ndc_lbl IN
       (
         SELECT t0.ndc_lbl
           FROM hcrs.lbl_t t0
          WHERE t0.ndc_lbl IN ('64406','71104')
       )
 ORDER BY 1, 2, 3, 4;

SELECT *
  FROM hcrs.prod_fmly_t t
 WHERE t.ndc_lbl IN
       (
         SELECT t0.ndc_lbl
           FROM hcrs.lbl_t t0
          WHERE t0.ndc_lbl IN ('64406','71104')
       )
 ORDER BY 1, 2;

SELECT *
  FROM hcrs.prod_fmly_drug_catg_t t
 WHERE t.ndc_lbl IN
       (
         SELECT t0.ndc_lbl
           FROM hcrs.lbl_t t0
          WHERE t0.ndc_lbl IN ('64406','71104')
       )
 ORDER BY 1, 2;

SELECT *
  FROM hcrs.prod_fmly_ppaca_t t
 WHERE t.ndc_lbl IN
       (
         SELECT t0.ndc_lbl
           FROM hcrs.lbl_t t0
          WHERE t0.ndc_lbl IN ('64406','71104')
       )
 ORDER BY 1, 2;

SELECT *
  FROM hcrs.prod_mstr_t t
 WHERE t.ndc_lbl IN
       (
         SELECT t0.ndc_lbl
           FROM hcrs.lbl_t t0
          WHERE t0.ndc_lbl IN ('64406','71104')
       )
 ORDER BY 1, 2;


-- Commit changes
COMMIT;

-- What time did this end running?
SELECT SYSDATE FROM dual;
