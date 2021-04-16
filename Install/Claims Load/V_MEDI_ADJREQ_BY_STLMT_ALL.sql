CREATE OR REPLACE VIEW V_MEDI_ADJREQ_BY_STLMT_ALL AS
SELECT
    --Settlement key
   a.stlmnt_num,
   a.userid,
   a.lastmod,
   a.flg_note,
   -- AdjReq Status Desc
   (SELECT status_desc        FROM status b  WHERE b.status_num = x.adj_stat)                             status_desc,
   -- Settlement Status Desc
   (SELECT status_desc        FROM status b  WHERE b.status_num = s.STLMNT_STAT)                             stlmnt_status_desc,
   (SELECT b.cont_internal_id FROM cont b WHERE b.cont_num = a.cont_num)                        cont_internal_id,
   -- Supplemental Contract
   (SELECT bb.cont_flg_supplmtl FROM cont bb    WHERE bb.cont_num   = a.cont_num)                cont_flg_supplmtl,
   -- Claim Date Creation
   x.DT_CREATED claim_date,
   -- Submission Number
   (SELECT submgrp_num FROM submdat WHERE submdat_num=x.SUBM_NUM) subm_num,
   -- Invoice Number
   (SELECT submdat_docno      FROM submdat b WHERE b.submdat_num = x.subm_num)                            invoice_num,
   TO_CHAR(adjreq_dt_start,'Q"Q"YYYY')                                                          quarter,
   adjreq_dt_start quarter_date,
   x.labeler_cd                                                                                 labeler_cd,
   (SELECT b.txt_tbc_val FROM v_ttbc b WHERE b.num_tbh_id = 3004 AND b.txt_tbc_cde = x.subtyp_cd) claim_type,
   CASE
      WHEN (SELECT COUNT(1) FROM adjitem WHERE adj_num = a.adj_num AND status_num = 1700) = (SELECT COUNT(1) FROM adjitem WHERE adj_num = a.adj_num AND status_num<>1700 ) THEN 'Y'
      ELSE 'N'
   END error_only,
   CASE
     WHEN ADJREQ_FLG_INTEREST='Y' THEN
       0
     ELSE
       CASE
       --there are no partial applies on the claim
       WHEN NOT EXISTS
       (
         SELECT 1 FROM adjreqitem ari1
         WHERE ari1.adjitm_num IN (SELECT ai.adjitm_num FROM adjitem ai WHERE ai.adj_num=x.adj_num)
       ) THEN
         x.adj_stlmnt_amt --show original amount
       --there are partial applies on the claim, but on different settlements
       WHEN NVL((SELECT SUM(NVL(adjreqitem_amt_override,0)) FROM adjreqitem ari2 WHERE ari2.adjreq_num=a.adjreq_num),0)=0 THEN
         0 --show zero
       --there are partial applies on the claim for current settlement
       ELSE
         (SELECT SUM(ROUND(NVL(adjreqitem_amt_override,0),2)) FROM adjreqitem ari3 WHERE ari3.adjreq_num=a.adjreq_num) --show sum of partial applies on current settlement
       END
   END adj_stlmnt_amt,
   (SELECT SUM (  ROUND (e.adjitm_amt_final, 2)
             + ROUND (e.adjitm_resolve_amt,2))
  FROM adjitemint d, adjitem e
 WHERE e.adj_num = x.adj_num and e.adjitm_num = d.adjitm_num and e.adj_num = d.adj_num and a.stlmnt_num=d.stlmnt_num and d.adjitemint_num_prior is null) adj_total_itemized,
   a.adjreq_interest_amt,
   a.adjreq_flg_interest,
   x.adj_dt_pmtdue,
   -- DT_PAYED
   sm.STLMNTMTHD_DT_SENT dt_payed,
   -- SETTLEMENT METHOD
   sm.STLTYP_CD stlmnt_method,
   -- METHOD ID
   sm.STLMNTMTHD_DOCNO stlmnt_meth_id,
   a.adj_num,
   a.adjreq_num,
   a.bunit_num,
   (select b.bunit_id_pri from bunit b where b.bunit_num = a.bunit_num)                             bunit_name,
   (select m.mds_name from mds m where m.mds_num = x.mds_num) division_name,
   x.adj_dt_start,
    --extra rebate amount
    DECODE(ADJREQ_FLG_INTEREST,'Y',0,(SELECT SUM (ROUND(NVL (clmadjitm_extra_rebate, 0),2))
             FROM adjitem c
            WHERE c.adj_num = a.adj_num )) extra_amt,
    x.adj_stat,
    (CASE WHEN EXISTS (SELECT 1 FROM adjreqitem ar, adjitem ai WHERE ar.adjitm_num = ai.adjitm_num and ai.adj_num = a.adj_num)
      THEN 'Y'
      ELSE 'N'
    END) AS adj_flg_partapply
FROM
   adjreq a, adj x, stlmnt s, stlmntmthd sm
WHERE
   a.adj_type  = 'MEDI'    AND
   x.adjtyp_cd = 'MEDI'    AND
   x.adj_num   = a.adj_num AND
   a.stlmnt_num = s.stlmnt_num AND
   a.stlmnt_num = sm.STLMNT_NUM AND
   s.STLMNT_STAT in(183, 184, 1703, 186) AND
   sm.stlmntmthd_status_num != 191 -- Ignore VOID
;
