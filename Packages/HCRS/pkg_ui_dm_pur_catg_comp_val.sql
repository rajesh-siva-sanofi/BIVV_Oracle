CREATE OR REPLACE PACKAGE HCRS.pkg_ui_dm_pur_catg_comp_val
AS

   /***********************************************************************************
    *      Package Name : PKG_UI_DM_PUR_CATG_COMP_VAL
    *       Returns        :
    *       Date Created   :
    *       Author         :   Quintiles IMS
    *       Description    :
    *
    *-- Modification History
    * Date           Name                Comment
    * ------------   ------------------  --------------------------------------
    *
    **********************************************************************************/
   PROCEDURE p_pur_catg_comp_s
     (i_page_no     IN NUMBER := 1,
      i_page_size   IN NUMBER := 10,
      i_sort_col    IN VARCHAR2,
      i_order_typ   IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR,
      i_debug       IN NUMBER := 0);

   PROCEDURE p_pur_catg_frml_s
     (i_comp_id     IN NUMBER,
      i_page_no     IN NUMBER := 1,
      i_page_size   IN NUMBER := 10,
      i_sort_col    IN VARCHAR2,
      i_order_typ   IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR,
      i_debug       IN NUMBER := 0);

   PROCEDURE p_pur_catg_sbfrml_s
     (i_formula_id  IN NUMBER,
      i_page_no     IN NUMBER := 1,
      i_page_size   IN NUMBER := 10,
      i_sort_col    IN VARCHAR2,
      i_order_typ   IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR,
      i_debug       IN NUMBER := 0);

   PROCEDURE p_pur_catg_comp_val_s
     (i_comp_id     IN NUMBER,
      i_formula_id  IN VARCHAR2,
      i_page_no     IN NUMBER := 1,
      i_page_size   IN NUMBER := 10,
      i_sort_col    IN VARCHAR2,
      i_order_typ   IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR,
      i_debug       IN NUMBER := 0);

   PROCEDURE p_pur_association_dts_actv_s
     (i_as_ndc_lbl    IN VARCHAR2,
      i_as_ndc_prod   IN VARCHAR2,
      i_as_ndc_pckg   IN VARCHAR2,
      i_an_pgm_id     IN NUMBER,
      i_an_frml_id    IN NUMBER,
      i_as_catg_cd    IN VARCHAR2,
      i_ad_bgn_qtr_dt IN DATE,
      i_ad_end_qtr_dt IN DATE,
      i_page_no       IN NUMBER := 1,
      i_page_size     IN NUMBER := 10,
      i_sort_col      IN VARCHAR2,
      i_order_typ     IN VARCHAR2,
      o_return_list   OUT SYS_REFCURSOR,
      i_debug         IN NUMBER := 0);

   PROCEDURE p_pur_catg_comp_val_u
     (i_pur_catg_cd     IN VARCHAR2,
      i_comp_id         IN NUMBER,
      i_drg_catg_grp_cd IN VARCHAR2,
      i_eff_dt          IN DATE,
      i_end_dt          IN DATE,
      i_val             IN NUMBER,
      i_frml_id         IN NUMBER,
      i_bgn_qtr_dt      IN DATE,
      i_end_qtr_dt      IN DATE);

   PROCEDURE p_pur_catg_comp_val_d
     (i_pur_catg_cd     IN VARCHAR2,
      i_comp_id         IN NUMBER,
      i_drg_catg_grp_cd IN VARCHAR2,
      i_eff_dt          IN DATE,
      i_frml_id         IN NUMBER,
      i_bgn_qtr_dt      IN DATE);

   PROCEDURE p_pur_catg_comp_val_i
     (i_pur_catg_cd     IN VARCHAR2,
      i_comp_id         IN NUMBER,
      i_drg_catg_grp_cd IN VARCHAR2,
      i_eff_dt          IN DATE,
      i_end_dt          IN DATE,
      i_val             IN NUMBER,
      i_frml_id         IN NUMBER,
      i_bgn_qtr_dt      IN DATE,
      i_end_qtr_dt      IN DATE);

END pkg_ui_dm_pur_catg_comp_val;
/
CREATE OR REPLACE PACKAGE BODY HCRS.pkg_ui_dm_pur_catg_comp_val
AS
   cs_src_pkg CONSTANT hcrs.error_log_t.src_cd%TYPE := 'pkg_ui_dm_pur_catg_comp_val';

   PROCEDURE p_pur_catg_comp_s
     (i_page_no     IN NUMBER := 1,
      i_page_size   IN NUMBER := 10,
      i_sort_col    IN VARCHAR2,
      i_order_typ   IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR,
      i_debug       IN NUMBER := 0)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_pur_catg_comp_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date           Name                Comment
       * ------------   ------------------  --------------------------------------
       **********************************************************************************/
      v_page_no         NUMBER := i_page_no;
      v_page_size       NUMBER := i_page_size;
      v_dyn_sql         pkg_constants.var_formula_sql_txt%TYPE;
      v_order_by        VARCHAR2(500);
      v_min_row         NUMBER;
      v_max_row         NUMBER;
   BEGIN
      -- If either page number or page size is 0, then change to null so all rows are returned
      IF (NVL(v_page_no,0) = 0 OR
          NVL(v_page_size,0) = 0)
      THEN
         v_page_no   := NULL;
         v_page_size := NULL;
      END IF;
      --Calculate Min and Max rows from the page and page size
      v_min_row := ((v_page_no - 1) * v_page_size) + 1;
      v_max_row := (v_page_no * v_page_size);
      --Determine the Order By column and sort direction(ASC / DESC)
      v_order_by := UPPER(LTRIM(RTRIM(i_sort_col)));
      IF v_order_by IS NULL
      THEN
         -- No column passed, set :=  order
         --:=  order by not specified
         v_order_by := 'ORDER BY comp_id ASC';
      ELSIF UPPER(SUBSTR(LTRIM(RTRIM(i_order_typ)),1,1)) = 'D'
      THEN
         v_order_by := ' ORDER BY ' || i_sort_col || ' DESC ';
      ELSE
         v_order_by := ' ORDER BY ' || i_sort_col || ' ';
      END IF;
      -- Build the dynamic sql
      v_dyn_sql := ' WITH z
                      AS(
                      --select statement from data window:
                      SELECT p.comp_id,
                             p.comp_cd
                        FROM hcrs.pur_comp_t p
                       WHERE p.val_typ_cd = ''USER''
                         AND p.Pckg_Lvl_Ind != ''Y''
                      ),
                      y
                      AS(
                      --add row number and count window functions, min / max rows
                      --any additional columns can be added here for use by .net
                      SELECT z.*,
                      ROW_NUMBER() OVER(' || v_order_by ||
                   ') row_num_,
                      COUNT(*) OVER() ttl_row_cnt_,
                      :v_min_row min_row_num_,
                      :v_max_row max_row_num_
                      FROM z
                      )
                      SELECT y.*
                      FROM y
                      --If min/ max are null, return all rows
                      WHERE y.row_num_ BETWEEN NVL(y.min_row_num_, 0) AND NVL(y.max_row_num_, y.ttl_row_cnt_)
                      ORDER BY y.row_num_';

         IF i_debug = 1
         THEN
            dbms_output.put_line(v_dyn_sql);
         END IF;

      --Open the refcursor
      OPEN o_return_list FOR v_dyn_sql
      --pass bind variables, they must be passed for every instance
      --of a variable in the order they appear in the query
         USING v_min_row, v_max_row;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg||'.p_pur_catg_comp_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_pur_catg_comp_s;

   PROCEDURE p_pur_catg_frml_s
     (i_comp_id     IN NUMBER,
      i_page_no     IN NUMBER := 1,
      i_page_size   IN NUMBER := 10,
      i_sort_col    IN VARCHAR2,
      i_order_typ   IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR,
      i_debug       IN NUMBER := 0)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_pur_catg_frml_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date           Name                Comment
       * ------------   ------------------  --------------------------------------
       **********************************************************************************/
      v_page_no         NUMBER := i_page_no;
      v_page_size       NUMBER := i_page_size;
      v_dyn_sql         pkg_constants.var_formula_sql_txt%TYPE;
      v_order_by        VARCHAR2(500);
      v_min_row         NUMBER;
      v_max_row         NUMBER;
   BEGIN
      -- If either page number or page size is 0, then change to null so all rows are returned
      IF (NVL(v_page_no,0) = 0 OR
          NVL(v_page_size,0) = 0)
      THEN
         v_page_no   := NULL;
         v_page_size := NULL;
      END IF;
      --Calculate Min and Max rows from the page and page size
      v_min_row := ((v_page_no - 1) * v_page_size) + 1;
      v_max_row := (v_page_no * v_page_size);
      --Determine the Order By column and sort direction(ASC / DESC)
      v_order_by := UPPER(LTRIM(RTRIM(i_sort_col)));
      IF v_order_by IS NULL
      THEN
         -- No column passed, set :=  order
         --:=  order by not specified
         v_order_by := 'ORDER BY 1 ASC';
      ELSIF UPPER(SUBSTR(LTRIM(RTRIM(i_order_typ)),1,1)) = 'D'
      THEN
         v_order_by := ' ORDER BY ' || i_sort_col || ' DESC ';
      ELSE
         v_order_by := ' ORDER BY ' || i_sort_col || ' ';
      END IF;
      -- Build the dynamic sql
      v_dyn_sql := ' WITH z
                      AS(
                      -- select statement from data window:
                      SELECT DISTINCT pfd.formula_id
                        FROM hcrs.pur_comp_t pc,
                             hcrs.pur_formula_dtl_t pfd
                       WHERE pfd.comp_id = :i_comp_id
                         AND pfd.comp_id = pc.comp_id
                         AND pc.val_typ_cd = ''USER''
                      ),
                      y
                      AS(
                      --add row number and count window functions, min / max rows
                      -- any additional columns can be added here for use by .net
                      SELECT z.*,
                      ROW_NUMBER() OVER(' || v_order_by ||
                   ') row_num_,
                      COUNT(*) OVER() ttl_row_cnt_,
                      :v_min_row min_row_num_,
                      :v_max_row max_row_num_
                      FROM z
                      )
                      SELECT y.*
                      FROM y
                      -- If min/ max are null, return all rows
                      WHERE y.row_num_ BETWEEN NVL(y.min_row_num_, 0) AND NVL(y.max_row_num_, y.ttl_row_cnt_)
                      ORDER BY y.row_num_';

         IF i_debug = 1
         THEN
            dbms_output.put_line(v_dyn_sql);
         END IF;

      --Open the refcursor
      OPEN o_return_list FOR v_dyn_sql
      --pass bind variables, they must be passed for every instance
      --of a variable in the order they appear in the query
         USING i_comp_id, v_min_row, v_max_row;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg||'.p_pur_catg_frml_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_pur_catg_frml_s;

   PROCEDURE p_pur_catg_sbfrml_s
     (i_formula_id  IN NUMBER,
      i_page_no     IN NUMBER := 1,
      i_page_size   IN NUMBER := 10,
      i_sort_col    IN VARCHAR2,
      i_order_typ   IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR,
      i_debug       IN NUMBER := 0)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_pur_catg_sbfrml_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date           Name                Comment
       * ------------   ------------------  --------------------------------------
       **********************************************************************************/
      v_page_no         NUMBER := i_page_no;
      v_page_size       NUMBER := i_page_size;
      v_dyn_sql         pkg_constants.var_formula_sql_txt%TYPE;
      v_order_by        VARCHAR2(500);
      v_min_row         NUMBER;
      v_max_row         NUMBER;
   BEGIN
      -- If either page number or page size is 0, then change to null so all rows are returned
      IF (NVL(v_page_no,0) = 0 OR
          NVL(v_page_size,0) = 0)
      THEN
         v_page_no   := NULL;
         v_page_size := NULL;
      END IF;
      --Calculate Min and Max rows from the page and page size
      v_min_row := ((v_page_no - 1) * v_page_size) + 1;
      v_max_row := (v_page_no * v_page_size);
      --Determine the Order By column and sort direction(ASC / DESC)
      v_order_by := UPPER(LTRIM(RTRIM(i_sort_col)));
      IF v_order_by IS NULL
      THEN
         -- No column passed, set :=  order
         --:=  order by not specified
         v_order_by := 'ORDER BY 1 ASC';
      ELSIF UPPER(SUBSTR(LTRIM(RTRIM(i_order_typ)),1,1)) = 'D'
      THEN
         v_order_by := ' ORDER BY ' || i_sort_col || ' DESC ';
      ELSE
         v_order_by := ' ORDER BY ' || i_sort_col || ' ';
      END IF;
      -- Build the dynamic sql
      v_dyn_sql := ' WITH z
                      AS(
                      -- select statement from data window:
                      SELECT DISTINCT
                             pfd.formula_id
                        FROM hcrs.pur_formula_dtl_t pfd
                       WHERE pfd.sub_formula_id = :i_formula_id
                      ),
                      y
                      AS(
                      --add row number and count window functions, min / max rows
                      -- any additional columns can be added here for use by .net
                      SELECT z.*,
                      ROW_NUMBER() OVER(' || v_order_by ||
                   ') row_num_,
                      COUNT(*) OVER() ttl_row_cnt_,
                      :v_min_row min_row_num_,
                      :v_max_row max_row_num_
                      FROM z
                      )
                      SELECT y.*
                      FROM y
                      -- If min/ max are null, return all rows
                      WHERE y.row_num_ BETWEEN NVL(y.min_row_num_, 0) AND NVL(y.max_row_num_, y.ttl_row_cnt_)
                      ORDER BY y.row_num_';

         IF i_debug = 1
         THEN
            dbms_output.put_line(v_dyn_sql);
         END IF;

      --Open the refcursor
      OPEN o_return_list FOR v_dyn_sql
      --pass bind variables, they must be passed for every instance
      --of a variable in the order they appear in the query
         USING i_formula_id, v_min_row, v_max_row;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg||'.p_pur_catg_sbfrml_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_pur_catg_sbfrml_s;

   PROCEDURE p_pur_catg_comp_val_s
     (i_comp_id     IN NUMBER,
      i_formula_id  IN VARCHAR2,
      i_page_no     IN NUMBER := 1,
      i_page_size   IN NUMBER := 10,
      i_sort_col    IN VARCHAR2,
      i_order_typ   IN VARCHAR2,
      o_return_list OUT SYS_REFCURSOR,
      i_debug       IN NUMBER := 0)
   AS
      /***********************************************************************************
      *       Procedure Name :    p_pur_catg_comp_val_s
      *       Date Created   :
      *       Author         :    Quintiles IMS
      *       Description    :
      *
      *-- Modification History
      *  Date           Name                 Comment
      *  ------------   ------------------   --------------------------------------
      *  9/30/2020      M.Gedzior            fixed up query to allow more than one value of 
      *                                      the same component per formula (for Clotting Factor 
      *                                      enhancement)
      **********************************************************************************/
      v_page_no         NUMBER := i_page_no;
      v_page_size       NUMBER := i_page_size;
      v_dyn_sql         pkg_constants.var_formula_sql_txt%TYPE;
      v_order_by        VARCHAR2(500);
      v_min_row         NUMBER;
      v_max_row         NUMBER;
   BEGIN
      -- If either page number or page size is 0, then change to null so all rows are returned
      IF (NVL(v_page_no,0) = 0 OR
          NVL(v_page_size,0) = 0)
      THEN
         v_page_no   := NULL;
         v_page_size := NULL;
      END IF;
      --Calculate Min and Max rows from the page and page size
      v_min_row := ((v_page_no - 1) * v_page_size) + 1;
      v_max_row := (v_page_no * v_page_size);
      --Determine the Order By column and sort direction(ASC / DESC)
      v_order_by := UPPER(LTRIM(RTRIM(i_sort_col)));
      IF v_order_by IS NULL
      THEN
         -- No column passed, set :=  order
         --:=  order by not specified
         v_order_by := 'ORDER BY PUR_CATG_CD, DRUG_CATG_GRP_CD, BEGIN_QTR_DT DESC, EFF_DT DESC, FORMULA_ID,BEGIN_QTR_DT DESC, EFF_DT DESC';
      ELSIF UPPER(SUBSTR(LTRIM(RTRIM(i_order_typ)),1,1)) = 'D'
      THEN
         v_order_by := ' ORDER BY ' || i_sort_col || ' DESC ';
      ELSE
         v_order_by := ' ORDER BY ' || i_sort_col || ' ';
      END IF;
      -- Build the dynamic sql
      v_dyn_sql := ' WITH z AS(
            SELECT
               pccv.formula_id
               ,pf.formula_descr
               ,pccv.comp_id
               ,pccv.drug_catg_grp_cd
               ,dcg.drug_catg_grp_descr
               ,pccv.pur_catg_cd
               ,pc.pur_catg_descr
               ,pccv.val
               ,pccv.begin_qtr_dt, pccv.end_qtr_dt
               ,pccv.eff_dt, pccv.end_dt
               ,DECODE(pccv.pur_catg_cd, NULL, ''Y'', ''N'') AS new_row_ind
            FROM HCRS.PUR_CATG_COMP_VAL_T PCCV
               ,hcrs.pur_catg_t pc
               ,hcrs.drug_catg_grp_t dcg
               ,hcrs.pur_formula_t pf
            WHERE pccv.pur_catg_cd = pc.pur_catg_cd
               AND pccv.formula_id = pf.formula_id
               AND pccv.comp_id = :al_comp_id
               AND pccv.drug_catg_grp_cd = dcg.drug_catg_grp_cd),
         y AS (
            -- add row number and count window functions, min / max rows
            -- any additional columns can be added here for use by .net
            SELECT z.*,
               ROW_NUMBER() OVER (' || v_order_by ||') row_num_,
               COUNT(*) OVER() ttl_row_cnt_,
               :v_min_row AS min_row_num_,
               :v_max_row AS max_row_num_
            FROM z)
         SELECT y.*
         FROM y
         -- If min/ max are null, return all rows
         WHERE y.row_num_ BETWEEN NVL(y.min_row_num_, 0) AND NVL(y.max_row_num_, y.ttl_row_cnt_)
         ORDER BY y.row_num_';

         IF i_debug = 1
         THEN
            dbms_output.put_line(v_dyn_sql);
            dbms_output.put_line('i_comp_id: '||i_comp_id);
            dbms_output.put_line('v_min_row: '||v_min_row);
            dbms_output.put_line('v_max_row: '||v_max_row);
         END IF;

      --Open the refcursor
      OPEN o_return_list FOR v_dyn_sql
      --pass bind variables, they must be passed for every instance
      --of a variable in the order they appear in the query
         USING i_comp_id, v_min_row, v_max_row;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg||'.p_pur_catg_comp_val_s',
                                  i_src_descr   => v_dyn_sql,
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_pur_catg_comp_val_s;

   PROCEDURE p_pur_association_dts_actv_s
     (i_as_ndc_lbl    IN VARCHAR2,
      i_as_ndc_prod   IN VARCHAR2,
      i_as_ndc_pckg   IN VARCHAR2,
      i_an_pgm_id     IN NUMBER,
      i_an_frml_id    IN NUMBER,
      i_as_catg_cd    IN VARCHAR2,
      i_ad_bgn_qtr_dt IN DATE,
      i_ad_end_qtr_dt IN DATE,
      i_page_no       IN NUMBER := 1,
      i_page_size     IN NUMBER := 10,
      i_sort_col      IN VARCHAR2,
      i_order_typ     IN VARCHAR2,
      o_return_list   OUT SYS_REFCURSOR,
      i_debug         IN NUMBER := 0)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_pur_association_dts_actv_s
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date           Name                Comment
       * ------------   ------------------  --------------------------------------
       **********************************************************************************/
      v_page_no         NUMBER := i_page_no;
      v_page_size       NUMBER := i_page_size;
      v_dyn_sql         pkg_constants.var_formula_sql_txt%TYPE;
      v_order_by        VARCHAR2(500);
      v_min_row         NUMBER;
      v_max_row         NUMBER;
   BEGIN
      -- If either page number or page size is 0, then change to null so all rows are returned
      IF (NVL(v_page_no,0) = 0 OR
          NVL(v_page_size,0) = 0)
      THEN
         v_page_no   := NULL;
         v_page_size := NULL;
      END IF;
      --Calculate Min and Max rows from the page and page size
      v_min_row := ((v_page_no - 1) * v_page_size) + 1;
      v_max_row := (v_page_no * v_page_size);
      --Determine the Order By column and sort direction(ASC / DESC)
      v_order_by := UPPER(LTRIM(RTRIM(i_sort_col)));
      IF v_order_by IS NULL
      THEN
         -- No column passed, set :=  order
         --:=  order by not specified
         v_order_by := 'ORDER BY 1 ASC';
      ELSIF UPPER(SUBSTR(LTRIM(RTRIM(i_order_typ)),1,1)) = 'D'
      THEN
         v_order_by := ' ORDER BY ' || i_sort_col || ' DESC ';
      ELSE
         v_order_by := ' ORDER BY ' || i_sort_col || ' ';
      END IF;
      -- Build the dynamic sql
      v_dyn_sql := ' WITH z
      AS(
         -- select statement from data window:
         SELECT t.begin_qtr_dt,
                t.end_qtr_dt,
                t.eff_dt,
                t.end_dt
           FROM hcrs.pur_formula_pgm_prod_assoc_t t
          WHERE t.ndc_lbl = :i_as_ndc_lbl
            AND t.ndc_prod = :i_as_ndc_prod
            AND t.ndc_pckg = :i_as_ndc_pckg
            AND t.pgm_id = :i_an_pgm_id
            AND t.formula_id = :i_an_frml_id
            AND t.end_dt >= SYSDATE
            AND TRUNC(t.begin_qtr_dt) <= :i_ad_bgn_qtr_dt
            AND TRUNC(t.end_qtr_dt) >= :i_ad_end_qtr_dt
            AND :i_as_ndc_lbl IS NOT NULL
        --ndc_lbl is an indicator as to which part of the union to run
          UNION
         SELECT t.begin_qtr_dt,
                t.end_qtr_dt,
                t.eff_dt,
                t.end_dt
           FROM hcrs.pur_catg_formula_t t
          WHERE t.formula_id = :i_an_frml_id
            AND t.pur_catg_cd = :i_as_catg_cd
            AND t.end_dt >= SYSDATE
            AND TRUNC(t.begin_qtr_dt) <= :i_ad_bgn_qtr_dt
            AND TRUNC(t.end_qtr_dt) >= :i_ad_end_qtr_dt
            AND :i_as_ndc_lbl IS NULL
        ),
        y
        AS(
         --add row number and count window functions, min / max rows
         -- any additional columns can be added here for use by .net
         SELECT z.*,
                ROW_NUMBER() OVER(' || v_order_by ||
                   ') row_num_,
                COUNT(*) OVER() ttl_row_cnt_,
                :v_min_row min_row_num_,
                :v_max_row max_row_num_
           FROM z
        )
               SELECT y.*
                 FROM y
                   -- If min/ max are null, return all rows
                 WHERE y.row_num_ BETWEEN NVL(y.min_row_num_, 0) AND NVL(y.max_row_num_, y.ttl_row_cnt_)
        ORDER BY y.row_num_';

         IF i_debug = 1
         THEN
            dbms_output.put_line(v_dyn_sql);
         END IF;

      --Open the refcursor
      OPEN o_return_list FOR v_dyn_sql
      --pass bind variables, they must be passed for every instance
      --of a variable in the order they appear in the query
         USING i_as_ndc_lbl, i_as_ndc_prod, i_as_ndc_pckg, i_an_pgm_id, i_an_frml_id, i_ad_bgn_qtr_dt, i_ad_end_qtr_dt, i_as_ndc_lbl, i_an_frml_id, i_as_catg_cd, i_ad_bgn_qtr_dt, i_ad_end_qtr_dt, i_as_ndc_lbl, v_min_row, v_max_row;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg||'.p_pur_association_dts_actv_s',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_pur_association_dts_actv_s;

   PROCEDURE p_pur_catg_comp_val_u
     (i_pur_catg_cd     IN VARCHAR2,
      i_comp_id         IN NUMBER,
      i_drg_catg_grp_cd IN VARCHAR2,
      i_eff_dt          IN DATE,
      i_end_dt          IN DATE,
      i_val             IN NUMBER,
      i_frml_id         IN NUMBER,
      i_bgn_qtr_dt      IN DATE,
      i_end_qtr_dt      IN DATE)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_pur_catg_comp_val_u
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date           Name                Comment
       * ------------   ------------------  --------------------------------------
       **********************************************************************************/
   BEGIN
      UPDATE hcrs.pur_catg_comp_val_t pc
         SET pc.end_dt     = i_end_dt,
             pc.val        = i_val,
             pc.end_qtr_dt = i_end_qtr_dt
       WHERE pc.pur_catg_cd      = i_pur_catg_cd
         AND pc.comp_id          = i_comp_id
         AND pc.drug_catg_grp_cd = i_drg_catg_grp_cd
         AND pc.eff_dt           = i_eff_dt
         AND pc.formula_id       = i_frml_id
         AND pc.begin_qtr_dt     = i_bgn_qtr_dt;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg||'.p_pur_catg_comp_val_u',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_pur_catg_comp_val_u;

   PROCEDURE p_pur_catg_comp_val_d
     (i_pur_catg_cd     IN VARCHAR2,
      i_comp_id         IN NUMBER,
      i_drg_catg_grp_cd IN VARCHAR2,
      i_eff_dt          IN DATE,
      i_frml_id         IN NUMBER,
      i_bgn_qtr_dt      IN DATE)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_pur_catg_comp_val_d
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date           Name                Comment
       * ------------   ------------------  --------------------------------------
       **********************************************************************************/
   BEGIN
      DELETE FROM hcrs.pur_catg_comp_val_t pc
       WHERE pc.pur_catg_cd = i_pur_catg_cd
         AND pc.comp_id = i_comp_id
         AND pc.drug_catg_grp_cd = i_drg_catg_grp_cd
         AND pc.eff_dt = i_eff_dt
         AND pc.formula_id = i_frml_id
         AND pc.begin_qtr_dt = i_bgn_qtr_dt;
   EXCEPTION
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg||'.p_pur_catg_comp_val_d',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_pur_catg_comp_val_d;

   PROCEDURE p_pur_catg_comp_val_i
     (i_pur_catg_cd     IN VARCHAR2,
      i_comp_id         IN NUMBER,
      i_drg_catg_grp_cd IN VARCHAR2,
      i_eff_dt          IN DATE,
      i_end_dt          IN DATE,
      i_val             IN NUMBER,
      i_frml_id         IN NUMBER,
      i_bgn_qtr_dt      IN DATE,
      i_end_qtr_dt      IN DATE)
   AS
      /***********************************************************************************
       *       Procedure Name :    p_pur_catg_comp_val_i
       *       Date Created   :
       *       Author         :    Quintiles IMS
       *       Description    :
       *
       *-- Modification History
       * Date           Name                Comment
       * ------------   ------------------  --------------------------------------
       **********************************************************************************/
   BEGIN
      INSERT INTO hcrs.pur_catg_comp_val_t
         (pur_catg_cd,
          comp_id,
          drug_catg_grp_cd,
          eff_dt,
          end_dt,
          val,
          formula_id,
          begin_qtr_dt,
          end_qtr_dt)
      VALUES
         (i_pur_catg_cd,
          i_comp_id,
          i_drg_catg_grp_cd,
          i_eff_dt,
          i_end_dt,
          i_val,
          i_frml_id,
          i_bgn_qtr_dt,
          i_end_qtr_dt);
   EXCEPTION
      WHEN dup_val_on_index
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg||'.p_pur_catg_comp_val_i',
                                  i_src_descr   => 'Duplicate values in the insert',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
      WHEN OTHERS
      THEN
         --Raise errors
         pkg_utils.p_raise_errors(i_src_cd      => cs_src_pkg||'.p_pur_catg_comp_val_i',
                                  i_src_descr   => '',
                                  i_error_cd    => SQLCODE,
                                  i_error_descr => SQLERRM,
                                  i_cmt_txt     => 'Fatal Error');
   END p_pur_catg_comp_val_i;

END pkg_ui_dm_pur_catg_comp_val;
/
