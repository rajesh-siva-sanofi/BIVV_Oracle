CREATE OR REPLACE PACKAGE HCRS.pkg_pur_calc
AS

   /****************************************************************************
   * Package Name : pkg_pur_calc
   * Date Created : 06/01/2002
   * Author           : Tom Zimmerman
   *  Description : PUR Calculations
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  04/17/2003  Joe Kidd      PICCs 1041: Only calculate PUR Categories
   *                            actually in use. (Remove NY-EPIC when
   *                            it is not in use)
   *  04/17/2003  Joe Kidd      PICCs 1042: Disable Program ID not found error
   *  04/28/2003  Joe Kidd      PICC 881: Close Change Log Entries
   *                            created by prod_trnsmsn_t.amp_amt changes
   *  10/15/2003  Joe Kidd      PICC 1120: PCKG override fails when no package
   *                            level components are on the formula
   *  03/09/2004  Alice Gamer   Make function f_get_formula_id public
   *  08/03/2004  Joe Kidd      PICC 1273: Correct main query in p_run_calc that
   *                            was dropping catgory level calculations
   * 07/01/2008   A. Gamer      ACTIV_READY flag is passed to this procedure
   *                            'Y': indicates URA calculation must be
   *                            based on the transmitted AMP/BP
   *                            'N': indicates URA calculation must be
   *                            based on the latest calculated AMP/BP regardless
   *                            of the transmission status.
   * 09/29/2014   T. Zimmerman  Various changes to support D5741 - HCRS - New URA Reports
   * 05/05/2015   T. Zimmerman  CRQ175926  - URA Rounding Issue - Changed rounding to use PKG_CONSTANTS.cs_default_precision
   * 05/10/2019   J. Tronoski   ITS-CHG0113127  - Changed function f_get_pur
   *                            Modified retrieval of pcp.pur_catg_cd
   * 05/23/2019   J. Tronoski   ITS-CHG0113127  - Changed function f_get_pur
   *                            Fixed retrieval of pcp.pur_catg_cd
   ****************************************************************************/
      -- Declare the record
      TYPE t_prod_rec IS RECORD (
           ndc_lbl     hcrs.prod_mstr_t.ndc_lbl%TYPE,
           ndc_prod    hcrs.prod_mstr_t.ndc_prod%TYPE,
           ndc_pckg    hcrs.prod_mstr_t.ndc_pckg%TYPE);

      -- Declare the reference cursor
      TYPE t_prod_cur IS REF CURSOR;

      -- Declare the procedures and functions
      FUNCTION f_get_value(i_formula_id  IN hcrs.pur_formula_dtl_t.formula_id%TYPE,
                     i_comp_id           IN hcrs.pur_comp_t.comp_id%TYPE,
                     i_val_typ_cd        IN hcrs.pur_val_typ_t.val_typ_cd%TYPE DEFAULT NULL,
                     i_comp_typ_cd       IN hcrs.pur_comp_typ_t.comp_typ_cd%TYPE DEFAULT NULL,
                     i_comp_cd           IN hcrs.pur_comp_t.comp_cd%TYPE DEFAULT NULL)
      RETURN NUMBER;

      PROCEDURE p_run_calc(i_prcss_queue_id hcrs.pur_calc_request_t.prcss_queue_id%TYPE,
                     i_ndc_lbl        hcrs.pur_calc_request_t.ndc_lbl%TYPE,
                     i_ndc_prod       hcrs.pur_calc_request_t.ndc_prod%TYPE,
                     i_period_id      hcrs.pur_calc_request_t.period_id%TYPE,
                     i_activ_ready    hcrs.pur_calc_request_t.activ_ready%TYPE);

      FUNCTION f_get_formula_id
      RETURN NUMBER;

      FUNCTION f_get_pur(i_pgm_id          IN  hcrs.pur_formula_pgm_prod_assoc_t.pgm_id%TYPE,
                         i_ndc_lbl         IN  hcrs.prod_mstr_t.ndc_lbl%TYPE,
                         i_ndc_prod        IN  hcrs.prod_mstr_t.ndc_prod%TYPE,
                         i_period_id       IN  hcrs.period_t.period_id%TYPE,
                         i_request_dt      IN  DATE,
                         i_active_flag     IN  CHAR,
                         i_ndc_pckg        IN  hcrs.prod_mstr_t.ndc_pckg%TYPE DEFAULT NULL,
                         o_pur_amt         OUT NUMBER,
                         i_log_flag        IN  BOOLEAN DEFAULT TRUE)
      RETURN NUMBER;

      FUNCTION f_get_calc_detail(
                                --input
                                i_ndc_lbl        IN hcrs.prod_mstr_t.ndc_lbl%TYPE,
                                i_ndc_prod       IN hcrs.prod_mstr_t.ndc_prod%TYPE,
                                i_ndc_pckg       IN hcrs.prod_mstr_t.ndc_pckg%TYPE,
                                i_period_id      IN hcrs.period_t.period_id%TYPE,
                                --derived input
                                i_formula_id     IN hcrs.pur_formula_t.formula_id%TYPE,
                                i_pgm_id         IN hcrs.pgm_t.pgm_id%TYPE,
                                i_pur_catg_cd    IN hcrs.pur_catg_formula_t.pur_catg_cd%TYPE,
                                i_override_level IN VARCHAR2
                                 )
      RETURN VARCHAR2  ;

      FUNCTION f_get_pur_report(i_pgm_id          IN  hcrs.pur_formula_pgm_prod_assoc_t.pgm_id%TYPE,
                         i_ndc_lbl         IN  hcrs.prod_mstr_t.ndc_lbl%TYPE,
                         i_ndc_prod        IN  hcrs.prod_mstr_t.ndc_prod%TYPE,
                         i_period_id       IN  hcrs.period_t.period_id%TYPE,
                         i_request_dt      IN  DATE,
                         i_active_flag     IN  CHAR,
                         i_ndc_pckg        IN  hcrs.prod_mstr_t.ndc_pckg%TYPE DEFAULT NULL--,
                         )
      RETURN NUMBER;

      PROCEDURE p_store_value(i_text           VARCHAR2,
                              i_value          VARCHAR2);

      PROCEDURE p_store_subformula(i_text           VARCHAR2);

      PROCEDURE p_set_g_in_comp_query_func(i_setting BOOLEAN);

      FUNCTION f_get_pur_comp(i_pgm_id     IN  hcrs.pur_formula_pgm_prod_assoc_t.pgm_id%TYPE,
                         i_ndc_lbl         IN  hcrs.prod_mstr_t.ndc_lbl%TYPE,
                         i_ndc_prod        IN  hcrs.prod_mstr_t.ndc_prod%TYPE,
                         i_period_id       IN  hcrs.period_t.period_id%TYPE,
                         i_request_dt      IN  DATE,
                         i_active_flag     IN  CHAR,
                         i_ndc_pckg        IN  hcrs.prod_mstr_t.ndc_pckg%TYPE DEFAULT NULL,
                         o_pur_amt         OUT NUMBER,
                         i_log_flag        IN  BOOLEAN DEFAULT TRUE)
      RETURN NUMBER;

      FUNCTION f_get_pur_report_comp(i_pgm_id          IN  hcrs.pur_formula_pgm_prod_assoc_t.pgm_id%TYPE,
                         i_ndc_lbl         IN  hcrs.prod_mstr_t.ndc_lbl%TYPE,
                         i_ndc_prod        IN  hcrs.prod_mstr_t.ndc_prod%TYPE,
                         i_period_id       IN  hcrs.period_t.period_id%TYPE,
                         i_request_dt      IN  DATE,
                         i_active_flag     IN  CHAR,
                         i_ndc_pckg        IN  hcrs.prod_mstr_t.ndc_pckg%TYPE DEFAULT NULL
                         )
      RETURN NUMBER;

END pkg_pur_calc;
/
CREATE OR REPLACE PACKAGE BODY HCRS.pkg_pur_calc
AS

-- Globals
v_override_result_flag         BOOLEAN := FALSE;
v_perform_final_tests_flag     BOOLEAN := TRUE;
v_parent_formula_at_lowest_lvl BOOLEAN := FALSE;
v_execute_query_flag           BOOLEAN := TRUE;
v_inquiry_only                 BOOLEAN := TRUE;

--Tom Zimmerman - 9/29/2014 - D5741 - HCRS - New URA Reports
g_formula VARCHAR2(32000) := NULL;
g_formula_details VARCHAR2(32000) := NULL;
g_formula_values VARCHAR2(32000) := NULL;
g_formula_details_values VARCHAR2(32000) := NULL;
g_missing_items VARCHAR2(32000) := NULL;

g_in_comp_query_func BOOLEAN := FALSE;
g_comp_query_values VARCHAR2(32000) := NULL;
v_comp_query_missing_items VARCHAR2(32000) := NULL;

/**********************************************
*       Procedure Name : f_calc_value
*       Input params   : i_query - the query to execute
*       Output params  : None
*       Returns       : Number - the value
*       Date Created   : 9/29/2014
*       Author        : Tom Zimmerman
*       Description    : This function will return the value for a sql statement
*                 : Note: the statement MUST look like => BEGIN :var_value := hcrs.pkg_pur_comp_query_functions.f_amp(:var_formula_id); END; with no CRs or tabs
* Modification History
* Date                           Name                                                            Comment
* ------------                  ------------------                      --------------------------------------
**************************************************/
FUNCTION f_calc_value( i_query        hcrs.pur_comp_query_t.query_txt%TYPE )
RETURN NUMBER
AS
  v_cursor       NUMBER;
  v_value        NUMBER := NULL;
  v_query        hcrs.pur_comp_query_t.query_txt%TYPE := NULL;
  v_query_id     hcrs.pur_comp_query_t.query_id%TYPE := NULL;
  v_return       NUMBER;

BEGIN

     -- Begin select statement
     v_query := 'SELECT '||replace(i_query,'|')||' AS x FROM DUAL';

         -- Open cursor
         v_cursor := dbms_sql.open_cursor;

         -- Parse statement
         dbms_sql.parse(c => v_cursor,
                        statement => v_query,
                        language_flag => dbms_sql.v7);

         -- define column
         DBMS_SQL.DEFINE_COLUMN(v_cursor, 1, v_value);

         -- Execute the statement
         v_return := dbms_sql.execute(c => v_cursor);

         IF DBMS_SQL.FETCH_ROWS(v_cursor)>0 THEN
           -- get column values of the row
           DBMS_SQL.COLUMN_VALUE(v_cursor, 1, v_value);
         END IF;

         -- Close the cursor
         dbms_sql.close_cursor(c => v_cursor);


  -- Return
  RETURN v_value;

EXCEPTION
   WHEN OTHERS THEN

       -- Close the cursor
       dbms_sql.close_cursor(c => v_cursor);

       pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_calc_value',
                                                 i_module_descr => 'This function will return the calculated PUR value for the specified request.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant run calculation');
       -- Return null
       RETURN NULL;

END f_calc_value;

/**********************************************
*       Procedure Name : f_clean_value
*       Input params   : i_formula_id - the formula ID
*       Output params  : None
*       Date Created   : 09/29/2014
*       Author        : Tom Zimmerman
*       Description    : This function will clean the value for the specified formula.
*
* Modification History
* Date                 Name                       Comment
* ------------    ------------------         --------------------------------------
* 05/05/2015      T. Zimmerman               CRQ175926  - URA Rounding Issue - Changed rounding to use PKG_CONSTANTS.cs_default_precision
**************************************************/
FUNCTION f_clean_value(i_value          VARCHAR2)
  RETURN VARCHAR2
AS
v_value VARCHAR2(100) := NULL;

BEGIN

    -- init
    v_value := i_value;

    -- round
    BEGIN
       v_value := round(v_value,PKG_CONSTANTS.cs_default_precision);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    -- 0 pad
    IF substr(v_value,1,1) = '.' THEN
      v_value := '0'||v_value;
    END IF;

    RETURN v_value;

EXCEPTION
    WHEN OTHERS THEN
      RETURN i_value;

END f_clean_value;

/**********************************************
*       Procedure Name : p_store_value
*       Input params   : i_formula_id - the formula ID
*       Output params  : None
*       Date Created   : 09/29/2014
*       Author        : Tom Zimmerman
*       Description    : This function will store the value for the specified formula.
*
* Modification History
* Date                 Name                       Comment
* ------------    ------------------         --------------------------------------
**************************************************/
PROCEDURE p_store_value(i_text           VARCHAR2,
                        i_value          VARCHAR2)
AS
v_junk VARCHAR2(10) := NULL;
v_value VARCHAR2(100) := NULL;
BEGIN

    -- init
    v_value := i_value;

    -- clean
    v_value := f_clean_value(v_value);

    -- test if in a component query
    IF NOT g_in_comp_query_func THEN

      g_formula_details := g_formula_details ||' '|| i_text;

      -- test and concat
      IF v_value IS NOT NULL THEN
         g_formula_details_values := g_formula_details_values ||' '|| v_value;
      ELSE
         g_formula_details_values := g_formula_details_values ||' '|| 'NULL';
         g_missing_items := g_missing_items ||' '|| i_text ||' is NULL!';
      END IF;

      IF v_value IS NOT NULL THEN
         g_formula_values := g_formula_values ||' '|| v_value;
      ELSE
         g_formula_values := g_formula_values ||' '||' NULL';
      END IF;

    ELSE -- in component query

      -- test and concat
      IF v_value = 'INIT' THEN
         g_comp_query_values := g_comp_query_values ||' '|| i_text;
      ELSIF v_value IS NOT NULL THEN
         g_comp_query_values := REGEXP_REPLACE(g_comp_query_values,'\?',v_value,1,1);
      ELSE
         g_comp_query_values := REGEXP_REPLACE(g_comp_query_values,'\?','NULL',1,1);
         v_comp_query_missing_items := v_comp_query_missing_items ||' '|| i_text ||' is NULL!';
      END IF;

    END IF;


EXCEPTION

  -- note that if var length is exceeded, this will not fail a calulcaiton.
    WHEN VALUE_ERROR THEN --ORA-06502: PL/SQL: numeric or value error: character string buffer too small
         NULL;
    WHEN OTHERS THEN
     -- Raise errors
     pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.p_store_value'
                                          ,i_module_descr => 'This function will store the value.'
                                          ,i_error_cd => SQLCODE
                                          ,i_error_msg => SQLERRM
                                          ,i_cmt_txt => 'Cant store - value:'||i_value);

END p_store_value;

/**********************************************
*       Procedure Name : p_store_subformula
*       Input params   :
*       Output params  : None
*       Date Created   : 09/29/2014
*       Author        : Tom Zimmerman
*       Description    : This function will store the value for the specified formula.
*
* Modification History
* Date                 Name                       Comment
* ------------    ------------------         --------------------------------------
**************************************************/
PROCEDURE p_store_subformula(i_text           VARCHAR2)
AS
BEGIN

    -- concat
    g_formula_details := g_formula_details ||' '|| i_text;


EXCEPTION
    -- note that if var length is exceeded, this will not fail a calulcaiton.
    WHEN VALUE_ERROR THEN --ORA-06502: PL/SQL: numeric or value error: character string buffer too small
             NULL;
    WHEN OTHERS THEN

     -- Raise errors
     pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.p_store_subformula'
                                          ,i_module_descr => 'This function will store the text.'
                                          ,i_error_cd => SQLCODE
                                          ,i_error_msg => SQLERRM
                                          ,i_cmt_txt => 'Cant store - text:'||i_text);

END p_store_subformula;

/**********************************************
*       Procedure Name : p_set_g_in_comp_query_func
*       Input params   :
*       Output params  : None
*       Date Created   : 09/29/2014
*       Author        : Tom Zimmerman
*       Description    : This procedure will set a variable and or concat values
*
* Modification History
* Date                 Name                       Comment
* ------------    ------------------         --------------------------------------
**************************************************/
PROCEDURE p_set_g_in_comp_query_func(i_setting BOOLEAN)
AS
BEGIN

    -- set
    g_in_comp_query_func := i_setting;

    -- flush subformaula vaules
    IF g_in_comp_query_func = FALSE THEN
         g_formula_details_values := g_formula_details_values || RTRIM(TRIM(g_comp_query_values),',');
         g_missing_items := g_missing_items || v_comp_query_missing_items;

         g_comp_query_values := NULL;
         v_comp_query_missing_items := NULL;
    END IF;

EXCEPTION
  -- note that if var length is exceeded, this will not fail a calulcaiton.
    WHEN VALUE_ERROR THEN --ORA-06502: PL/SQL: numeric or value error: character string buffer too small
         NULL;
    WHEN OTHERS THEN
     -- Raise errors
     pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.p_set_g_in_comp_query_func'
                                          ,i_module_descr => 'This procedure will set a variable and or concat values.'
                                          ,i_error_cd => SQLCODE
                                          ,i_error_msg => SQLERRM
                                          ,i_cmt_txt => 'See error cd and msg');

END p_set_g_in_comp_query_func;

/**********************************************
*       Procedure Name : p_register_quarter_dates
*       Input params   : None
*       Output params  : None
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will Get and Register the quarter dates
* Modification History
* Date                                          Name                                                            Comment
* ------------                  ------------------                      --------------------------------------
*
**************************************************/
PROCEDURE p_register_quarter_dates
AS
BEGIN

   -- Get and Register the quarter dates
   pkg_pur_common_procedures.p_get_period_dates(i_period_id => pkg_constants.var_period_id
                                               ,o_eff_dt => pkg_constants.var_begin_qtr_dt
                                               ,o_end_dt => pkg_constants.var_end_qtr_dt);
EXCEPTION
    WHEN OTHERS THEN
       pkg_pur_common_procedures.p_raise_errors(i_module_nam => 'pkg_pur_calc.p_register_quarter_dates',
                                                i_module_descr => 'This function will Get and Register the quarter dates ',
                                                i_error_cd => SQLCODE,
                                                i_error_msg => SQLERRM,
                                                i_cmt_txt => 'Cant get and register quarter dates.');

END p_register_quarter_dates;

/**********************************************
*       Procedure Name : f_test_first_calc
*       Input params   : None
*       Output params  : None
*       Returns       : Boolean
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will test if this is not the first calculation of the PUR.
* Modification History
* Date                                          Name                                                            Comment
* ------------                  ------------------                      --------------------------------------
*
**************************************************/
FUNCTION f_test_first_calc
RETURN BOOLEAN
AS
  v_value       BOOLEAN := TRUE;
BEGIN

   -- Loop - may be more than 1 transmitted row
   FOR v_rec IN(SELECT pt.prod_trnsmsn_stat_cd
                FROM   hcrs.prod_trnsmsn_t pt
                WHERE  pt.ndc_lbl = pkg_constants.var_ndc_lbl
                AND    pt.ndc_prod = pkg_constants.var_ndc_prod
                AND    pt.period_id = pkg_constants.var_period_id
                ORDER BY pt.prod_trnsmsn_stat_cd DESC) LOOP

                -- There is AT LEAST 1 Transmitted PUR, so this is not the first calculation
                IF v_rec.prod_trnsmsn_stat_cd = pkg_constants.cs_prod_trnsmsn_trans_cd THEN

                   -- set the value
                   v_value := FALSE;

                   -- exit the loop
                   EXIT;

                END IF;

   END LOOP;

   -- Return
   RETURN v_value;

EXCEPTION
    WHEN OTHERS THEN
       pkg_pur_common_procedures.p_raise_errors(i_module_nam => 'pkg_pur_calc.f_test_first_calc',
                                                i_module_descr => 'This function will test if this is not the first calculation of the PUR.',
                                                i_error_cd => SQLCODE,
                                                i_error_msg => SQLERRM,
                                                i_cmt_txt => 'Cant test product and period.');

       -- Return null
       RETURN NULL;

END f_test_first_calc;

/**********************************************
*       Procedure Name : f_test_formula_lowest_level
*       Input params   : i_formula_id - Subformula ID
*       Output params  : None
*       Returns       : Boolean
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will test if a subformula is at the lowest level of the formula.
* Modification History
* Date                                          Name                                                            Comment
* ------------                  ------------------                      --------------------------------------
*
**************************************************/
FUNCTION f_test_formula_lowest_level(i_formula_id hcrs.pur_formula_t.formula_id%TYPE)
RETURN BOOLEAN
AS
  v_value       BOOLEAN := TRUE;
BEGIN

   -- Loop - there can be MORE THAN 1 subformula in a formula
   FOR v_rec IN(SELECT pkg_constants.cs_flag_no ind
                FROM   hcrs.pur_formula_dtl_t pfd
                WHERE  pfd.formula_id = i_formula_id
                AND    pfd.sub_formula_id IS NOT NULL) LOOP

         -- Set return to False
         v_value := FALSE;

         -- Exit loop
         EXIT;

   END LOOP;

   -- Return
   RETURN v_value;

EXCEPTION
    WHEN OTHERS THEN
       pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_test_formula_lowest_level',
                                                 i_module_descr => 'This function will test if a subformula is at the lowest level of the formula.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant test formula_id:'||i_formula_id);

       -- Return null
       RETURN NULL;

END f_test_formula_lowest_level;

/**********************************************
*       Procedure Name : f_test_formula_pkg_lvl_comp
*       Input params   : i_formula_id - Formula ID
*       Output params  : None
*       Returns       : Boolean
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will recursively test if there is a package level component in a formula.
* Modification History
* Date                                          Name                                                            Comment
* ------------                  ------------------                      --------------------------------------
*
**************************************************/
FUNCTION f_test_formula_pkg_lvl_comp(i_formula_id hcrs.pur_formula_t.formula_id%TYPE)
RETURN BOOLEAN
AS
  v_value       BOOLEAN := FALSE;
BEGIN

  -- Loop thru formula - there can be MORE THAN 1 package level component in a formula
  -- must be a distinct select due to possible recursive call
  FOR v_rec IN (SELECT DISTINCT pfd.sub_formula_id,
                       pc.pckg_lvl_ind
                FROM   hcrs.pur_formula_dtl_t pfd,
                       hcrs.pur_comp_t pc
                WHERE  pfd.formula_id = i_formula_id
                AND    pc.comp_id(+) = pfd.comp_id
                ORDER BY nvl(pc.pckg_lvl_ind,'A') DESC) LOOP

         -- If package level component is found
         IF v_rec.pckg_lvl_ind = pkg_constants.cs_flag_yes THEN

            -- Set flag
            v_value := TRUE;

            -- Stop
            EXIT;

         ELSIF v_rec.sub_formula_id IS NOT NULL THEN

             -- Recursively call passing subformula
             v_value := f_test_formula_pkg_lvl_comp(v_rec.sub_formula_id);

             -- If there is a package level component
             IF v_value THEN

                -- Stop
                EXIT;

             END IF;

         END IF;

   END LOOP;

   -- Return
   RETURN v_value;

EXCEPTION
    WHEN OTHERS THEN
       pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_test_formula_pkg_lvl_comp',
                                                 i_module_descr => 'This function will recursively test if there is a package level component in a formula. ',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant test formula formula_id:'||i_formula_id);

       -- Return null
       RETURN NULL;

END f_test_formula_pkg_lvl_comp;

/**********************************************
*       Procedure Name : f_get_boundary_cd
*       Input params   : i_comp_id
*       Output params  : None
*       Returns       : Number - the code
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will return the boundary code for the specified criteria.
* Modification History
* Date                                          Name                                                            Comment
* ------------                  ------------------                      --------------------------------------
*
**************************************************/
FUNCTION f_get_boundary_cd (i_comp_id hcrs.pur_comp_t.comp_id%TYPE)
RETURN hcrs.pur_comp_t.boundary_cd%TYPE
AS
 v_boundary_cd hcrs.pur_comp_t.boundary_cd%TYPE;

BEGIN

   -- Get the boundary
   SELECT boundary_cd
   INTO   v_boundary_cd
   FROM   hcrs.pur_comp_t
   WHERE  comp_id = i_comp_id;

   -- Return
   RETURN v_boundary_cd;

EXCEPTION
     WHEN OTHERS THEN
     -- Raise errors
     pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_boundary_cd',
                                               i_module_descr => 'This function will return the boundary code for the specified criteria.',
                                               i_error_cd => SQLCODE,
                                               i_error_msg => SQLERRM,
                                               i_cmt_txt => 'Cant return Boundary Code for comp_id:'||i_comp_id);
       -- Return null
       RETURN NULL;

END f_get_boundary_cd;

/**********************************************
*       Procedure Name : f_get_user_val
*       Input params   : i_formula_id - the formula ID
*                 : i_comp_id - the component ID
*                 : i_comp_cd - the component code
*       Output params  : None
*       Returns       : Number - the user value
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will return the user value for the specified criteria.
* Modification History
* Date               Name                       Comment
* ------------       ------------------         --------------------------------------
* 12/26/2002         T. Zimmerman               Added Set override flag to true, set final test flag to false, Return null
*                                               Changed queries from loop to MAX - was a performance issue in Oracle 7
* 01/22/2003         T. Zimmerman               Removed TRUNC of eff and end dates
* 09/29/2014         T. Zimmerman               Changes to support D5741 - HCRS - New URA Reports i.e. call to p_store_values
* 01/07/2015         T. Zimmerman               Changes to support CRQ000000145747 - use quarter date below as opposed to MAX
* 9/24/2020          M. Gedzior                 Added support for reduced percent component values for the same formula.
**************************************************/
FUNCTION f_get_user_val(i_formula_id   IN hcrs.pur_formula_dtl_t.formula_id%TYPE,
                        i_comp_id      IN hcrs.pur_comp_t.comp_id%TYPE,
                        i_comp_cd         IN hcrs.pur_comp_t.comp_cd%TYPE DEFAULT NULL)
RETURN NUMBER
AS
   v_value        NUMBER := NULL;
   v_boundary_cd  hcrs.pur_boundary_typ_t.boundary_cd%TYPE := NULL;
   v_drug_catg_cd hcrs.prod_fmly_drug_catg_t.drug_catg_cd%TYPE := NULL;
   v_cf_ind       hcrs.prod_fmly_t.clotting_factor_ind%TYPE := 'N';

BEGIN

   IF pkg_constants.var_override_level = pkg_constants.cs_ovrrd_lvl_catg THEN

     -- Get the drug category code
     SELECT pfdc.drug_catg_cd
     INTO   v_drug_catg_cd
     FROM   hcrs.prod_fmly_drug_catg_t pfdc
     WHERE  pfdc.ndc_lbl = pkg_constants.var_ndc_lbl
     AND    pfdc.ndc_prod = pkg_constants.var_ndc_prod
     AND    pkg_constants.var_begin_qtr_dt BETWEEN pfdc.eff_dt AND pfdc.end_dt;
/*   AND    pfdc.eff_dt = (SELECT MAX(pfdc2.eff_dt)
                           FROM   hcrs.prod_fmly_drug_catg_t pfdc2
                           WHERE  pfdc2.ndc_lbl = pkg_constants.var_ndc_lbl
                           AND    pfdc2.ndc_prod = pkg_constants.var_ndc_prod
                           AND    pkg_constants.var_request_dt BETWEEN pfdc2.eff_dt AND pfdc2.end_dt);*/


     -- Check for drug category code null
     IF v_drug_catg_cd IS NULL THEN

         -- Raise error
         pkg_pur_common_procedures.p_raise_errors(i_module_nam => 'pkg_pur_calc.f_get_user_value',
                                                  i_module_descr => 'This function will return the user value for the specified criteria.',
                                                  i_error_cd => -1,
                                                  i_error_msg => NULL,
                                                  i_cmt_txt => 'Cant get drug category code when trying to get user value');
         -- Set override flag to true
         v_override_result_flag := TRUE;

         -- Set fianl test flag to false
         v_perform_final_tests_flag := FALSE;

         -- Set the return value to null
         v_value := NULL;

     END IF;

      -- check if reduced % value should be chosen
      SELECT nvl(f.clotting_factor_ind, 'N')
      INTO v_cf_ind
      FROM hcrs.prod_fmly_t f
      WHERE f.ndc_lbl = pkg_constants.var_ndc_lbl
         AND f.ndc_prod = pkg_constants.var_ndc_prod;
      

      -- Get the category component value
      WITH dcga AS (
         SELECT 'Y' AS cf_ind, t.* 
         FROM hcrs.drug_catg_grp_asgnmnt_t t
         WHERE t.drug_catg_grp_cd = 'CF'
         UNION
         SELECT 'N' AS cf_ind, t.* FROM hcrs.drug_catg_grp_asgnmnt_t t
         WHERE t.drug_catg_grp_cd != 'CF')
      SELECT pccv.val
      INTO v_value
      FROM
         hcrs.pur_catg_comp_val_t pccv,
         dcga
      WHERE pccv.formula_id = i_formula_id
         AND pccv.comp_id = i_comp_id
         AND pccv.pur_catg_cd = pkg_constants.var_pur_catg_cd
         AND pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(pccv.begin_qtr_dt) AND TRUNC(pccv.end_qtr_dt)
         AND dcga.drug_catg_grp_cd = pccv.drug_catg_grp_cd
         AND dcga.drug_catg_cd = v_drug_catg_cd
         AND dcga.cf_ind = v_cf_ind
         AND pccv.eff_dt = (SELECT MAX(pccv2.eff_dt)
                           FROM   hcrs.pur_catg_comp_val_t pccv2
                           WHERE  pccv2.formula_id = pccv.formula_id
							AND    pccv2.comp_id = pccv.comp_id
							AND    pccv2.pur_catg_cd = pccv.pur_catg_cd
							AND    pkg_constants.var_request_dt BETWEEN pccv2.eff_dt AND pccv2.end_dt
							AND    pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(pccv2.begin_qtr_dt) AND TRUNC(pccv2.end_qtr_dt)
							AND    pccv2.drug_catg_grp_cd = pccv.drug_catg_grp_cd);


   ELSE

      -- Get the package override value
      SELECT t.val
      INTO   v_value
      FROM   hcrs.pur_form_comp_pgm_prod_val_t t
      WHERE  t.formula_id = i_formula_id
      AND    t.comp_id = i_comp_id
      AND    pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(t.begin_qtr_dt) AND TRUNC(t.end_qtr_dt)
      AND    t.ndc_lbl = pkg_constants.var_ndc_lbl
      AND    t.ndc_prod = pkg_constants.var_ndc_prod
      AND    t.ndc_pckg = pkg_constants.var_ndc_pckg
      AND    t.pgm_id = pkg_constants.var_pgm_id
      AND    t.eff_dt =(SELECT MAX(t2.eff_dt)
                        FROM   hcrs.pur_form_comp_pgm_prod_val_t t2
                        WHERE  t2.formula_id = i_formula_id
                        AND    t2.comp_id = i_comp_id
                        AND    pkg_constants.var_request_dt BETWEEN t2.eff_dt AND t2.end_dt
                        AND    pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(t2.begin_qtr_dt) AND TRUNC(t2.end_qtr_dt)
                        AND    t2.ndc_lbl = pkg_constants.var_ndc_lbl
                        AND    t2.ndc_prod = pkg_constants.var_ndc_prod
                        AND    t2.ndc_pckg = pkg_constants.var_ndc_pckg
                        AND    t2.pgm_id = pkg_constants.var_pgm_id);

   END IF;

   -- store value
   p_store_value(i_text  => i_comp_cd,
                 i_value => v_value);

   -- Check if value is negative
   IF v_value < 0 THEN

      -- Raise calculation exception
      pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.f_get_user_value',
                                                       i_module_descr => 'This function will return the user value for the specified criteria.',
                                                       i_cmt_txt => 'Retrieved comp_id:'||i_comp_id||' comp_cd:'||i_comp_cd||' value:'||v_value||' is less than zero - continuing calculation.');

   -- Otherwise, check if value is NULL
   ELSIF v_value IS NULL THEN

         -- Raise exception
         RAISE NO_DATA_FOUND;

   END IF;

   -- Return
   RETURN v_value;

EXCEPTION
   WHEN NO_DATA_FOUND THEN

      -- If inquiry mode
      IF v_inquiry_only THEN

         -- set override flag
         v_override_result_flag := TRUE;

         -- Throw exception
         pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.f_get_user_val',
                                                          i_module_descr => 'This function will return the user value for the specified criteria. ',
                                                          i_cmt_txt => 'Cant find user value for Quarterly comp_id:'||i_comp_id||' comp_cd:'||i_comp_cd||'.  Result will be overridden with NULL');

         -- store value
         p_store_value(i_text  => i_comp_cd,
                       i_value => NULL);

         -- Return 0
         RETURN 0;

      ELSE -- calculation mode

         /*
         When the code cant find a value for a component (no_data_found exception):
         Get the boundary code for the component.
         If the component is 'QTR' and the formula is at the lowest level (no subformula), override the result to NULL.  No exception is generated.  Null result is stored.
         Else if the component is 'QTR'  and the formula has subfoirmaula(s) - throw exception - 'Cant find value, continuing...)'.  Zero is returned. Zero result is stored.
         Otherwise, error - 'Cant find value'.  No results are stored.
         */
         -- Get the boundary code
         v_boundary_cd := f_get_boundary_cd(i_comp_id => i_comp_id);

         -- When no data found AND:

         -- If component has Quarter boundary and parent formula = formula (lowest level?)
         -- then override result with null value
         IF v_boundary_cd = pkg_constants.cs_boundary_qtr
         AND   v_parent_formula_at_lowest_lvl THEN

            -- set override flag
            v_override_result_flag := TRUE;

            -- Set the perform final tests flag
            v_perform_final_tests_flag := FALSE;

            -- Throw exception
            pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.f_get_user_val',
                                                             i_module_descr => 'This function will return the user value for the specified criteria. ',
                                                             i_cmt_txt => 'Cant find user value for Quarterly comp_id:'||i_comp_id||' comp_cd:'||i_comp_cd||'.  Result will be overridden with NULL, continuing calculation...');

            -- store value
            p_store_value(i_text  => i_comp_cd,
                          i_value => NULL);

            -- Return 0
            RETURN 0;

         -- Else if component has Quarter boundary
         -- then throw exception and return 0
         ELSIF v_boundary_cd = pkg_constants.cs_boundary_qtr THEN

            -- Throw exception
            pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.f_get_user_val',
                                                             i_module_descr => 'This function will return the user value for the specified criteria. ',
                                                             i_cmt_txt => 'Cant find user value for Quarterly comp_id:'||i_comp_id||' comp_cd:'||i_comp_cd||'.  Substituting zero and continuing calculation...');

            -- store value
            p_store_value(i_text  => i_comp_cd,
                          i_value => NULL);

            -- Return 0
            RETURN 0;

         ELSE
            -- Raise error
            pkg_pur_common_procedures.p_raise_errors(i_module_nam => 'pkg_pur_calc.f_get_user_val',
                                                     i_module_descr => 'This function will return the user value for the specified criteria.',
                                                     i_error_cd => SQLCODE,
                                                     i_error_msg => SQLERRM,
                                                     i_cmt_txt => 'Cant find user value for formula_id:'||i_formula_id||' comp_id:'||i_comp_id||' comp_cd:'||i_comp_cd);

            -- Set override flag to true
            v_override_result_flag := TRUE;

            -- Set fianl test flag to false
            v_perform_final_tests_flag := FALSE;

            -- store value
            p_store_value(i_text  => i_comp_cd,
                          i_value => NULL);

            -- Return null
            RETURN NULL;

         END IF;

      END IF; -- mode

   WHEN OTHERS THEN
      -- Raise error
      pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_user_val',
                                                 i_module_descr => 'This function will return the user value for the specified criteria.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant get user value for formula_id:'||i_formula_id||' comp_id:'||i_comp_id||' comp_cd:'||i_comp_cd);

      -- Set override flag to true
      v_override_result_flag := TRUE;

      -- Set fianl test flag to false
      v_perform_final_tests_flag := FALSE;

      -- store value
      p_store_value(i_text  => i_comp_cd,
                    i_value => NULL);

      -- Return null
      RETURN NULL;

END f_get_user_val;

/**********************************************
*       Procedure Name : f_get_value
*       Input params   : i_formula_id - the formual ID
*                 : i_comp_id - the component ID
*                 : i_val_typ_cd - the value type code
*                 : i_comp_typ_cd - the component type code
*       Output params  : None
*       Returns       : Number - the value
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will return the value for the specified criteria.
*                 : Note: the statement MUST look like => BEGIN :var_value := hcrs.pkg_pur_comp_query_functions.f_amp(:var_formula_id); END; with no CRs or tabs
* Modification History
* Date                                          Name                                                            Comment
* ------------                  ------------------                      --------------------------------------
* 12/26/2002         T. Zimmerman               Added Set override flag to true, set final test flag to false, Return null
* 01/22/2003         T. Zimmerman              Removed TRUNC of eff and end dates
* 09/29/2014         T. Zimmerman               Changes to support D5741 - HCRS - New URA Reports i.e. call to p_store_values
**************************************************/
FUNCTION f_get_value(i_formula_id       IN hcrs.pur_formula_dtl_t.formula_id%TYPE,
                     i_comp_id          IN hcrs.pur_comp_t.comp_id%TYPE,
                     i_val_typ_cd       IN hcrs.pur_val_typ_t.val_typ_cd%TYPE DEFAULT NULL,
                     i_comp_typ_cd      IN hcrs.pur_comp_typ_t.comp_typ_cd%TYPE DEFAULT NULL,
                     i_comp_cd          IN hcrs.pur_comp_t.comp_cd%TYPE DEFAULT NULL)
RETURN NUMBER
AS
  v_cursor       NUMBER;
  v_value        NUMBER := NULL;
  v_query        hcrs.pur_comp_query_t.query_txt%TYPE := NULL;
  v_bind_count   NUMBER := NULL;
  v_query_id     hcrs.pur_comp_query_t.query_id%TYPE := NULL;
  v_return       NUMBER;

BEGIN

   -- If component type is user then get the value
   IF i_val_typ_cd = pkg_constants.cs_val_typ_user THEN

     -- get user value
     v_value := f_get_user_val(pkg_constants.var_parent_formula_id,
                                                                i_comp_id,
                              i_comp_cd);

   ELSE
   -- Else get the query to return the value

         -- Get query for component - with greatest effective date
         SELECT pcq.query_txt,
                pcq.query_id
         INTO   v_query,
                v_query_id
         FROM   hcrs.pur_comp_t pc,
                hcrs.pur_comp_query_t pcq
         WHERE  pc.comp_id = i_comp_id
         AND    pcq.comp_id = pc.comp_id
         AND    pcq.eff_dt = (SELECT MAX(pcq2.eff_dt)
                              FROM   hcrs.pur_comp_t pc2,
                                     hcrs.pur_comp_query_t pcq2
                              WHERE  pc2.comp_id = pc.comp_id
                              AND    pcq2.comp_id = pc2.comp_id
                              AND    pkg_constants.var_request_dt BETWEEN pcq2.eff_dt AND pcq2.end_dt);

         -- check if null
         IF v_query IS NULL THEN

            -- Raise error
            RAISE NO_DATA_FOUND;

         END IF;

         -- Open cursor
         v_cursor := dbms_sql.open_cursor;

         -- Parse statement
         dbms_sql.parse(c => v_cursor,
                        statement => v_query,
                        language_flag => dbms_sql.v7);

         -- If there is a bind variable for the formula
         IF instr(v_query,':var_formula_id') > 0 THEN

               -- Bind input variable
               dbms_sql.bind_variable(c => v_cursor,
                                      name => ':var_formula_id',
                                      value => i_formula_id);

         END IF;

                        -- Bind the output var
                        dbms_sql.bind_variable( c => v_cursor,
                                                name => ':var_value',
                                                value => v_value);

         -- Execute the statement
         v_return := dbms_sql.execute(c => v_cursor);

                        -- Assign the variable to a value
                        dbms_sql.variable_value(c => v_cursor,
                                                                                                                        name => ':var_value',
                                                                                                                        value => v_value);

         -- Close the cursor
         dbms_sql.close_cursor(c => v_cursor);

        -- store value
        IF NOT g_in_comp_query_func THEN
          p_store_value(i_text  => i_comp_cd,
                        i_value => v_value);
        ELSE
          g_formula_values := g_formula_values||' '|| f_clean_value(v_value);
        END IF;

  END IF;

  -- If the value is null, raise exception
  IF v_value IS NULL THEN

     -- Raise exception
     RAISE NO_DATA_FOUND;

  END IF;

  -- Return
  RETURN v_value;

EXCEPTION
   WHEN NO_DATA_FOUND THEN

       -- Raise error
       pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_value',
                                                 i_module_descr => 'This function will return the value for the specified criteria.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant find value for comp_id:'||i_comp_id||' comp_cd:'||i_comp_cd||' Query:'||v_query);
       -- Set override flag to true
       v_override_result_flag := TRUE;

       -- Set fianl test flag to false
       v_perform_final_tests_flag := FALSE;

       -- Return null
       RETURN NULL;

   WHEN OTHERS THEN

       -- Close the cursor
       dbms_sql.close_cursor(c => v_cursor);

       -- Raise error
       pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_value',
                                                 i_module_descr => 'This function will return the value for the specified criteria.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant execute query for value for comp_id:'||i_comp_id||' comp_cd:'||i_comp_cd||' Query:'||v_query);
       -- Set override flag to true
       v_override_result_flag := TRUE;

       -- Set fianl test flag to false
       v_perform_final_tests_flag := FALSE;

       -- Return null
       RETURN NULL;

END f_get_value;


/**********************************************
*       Procedure Name : p_store_result
*       Input params   : i_formula_id - the formula ID
*       Output params  : None
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will store the value for the specified formula.
*
* Modification History
* Date                 Name                       Comment
* ------------    ------------------         --------------------------------------
* 12/26/2002         T. Zimmerman         Added Set override flag to true, set final test flag to false, Return null
* 06/10/2013         A. Gamer             CRQ51343: added logic for var_ura_adj_firstwac_minus_bp
**************************************************/
PROCEDURE p_store_result(i_formula_id        hcrs.pur_formula_t.formula_id%TYPE,
                         i_value          NUMBER)
AS
  v_value NUMBER := NULL;
BEGIN

   -- Check for override
   IF v_override_result_flag
   AND i_formula_id = pkg_constants.var_parent_formula_id THEN

      -- Nullify value
      v_value := NULL;

      -- Set the override results flag
      v_override_result_flag := FALSE;

   -- Check for negative value
   ELSIF i_value < 0 THEN
         --skip recording exceptions for URA Adjustment
         IF i_formula_id NOT IN (pkg_constants.var_ura_cap_adj_formula_id,
                                pkg_constants.var_ura_adj_lastwac_minus_bp,
                                pkg_constants.var_ura_adj_firstwac_minus_bp) THEN
            -- Raise calculation exception
            pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.p_store_result',
                                                       i_module_descr => 'This function will store the value for the specified formula.',
                                                       i_cmt_txt => 'Storing value:'||i_value||' which is negative - continuing calculation.');
         END IF;

      v_value := i_value;

   ELSE
      v_value := i_value;
   END IF;

   -- Store result
   IF pkg_constants.var_pckg_lvl_ind = pkg_constants.cs_flag_no THEN

        -- insert result
        INSERT INTO hcrs.pur_catg_intrm_results_t(
                        formula_id,
                        period_id,
                        ndc_lbl,
                        ndc_prod,
                        calc_amt,
                        pur_catg_cd,
                        parent_formula_id)
        VALUES (i_formula_id,
                pkg_constants.var_period_id,
                pkg_constants.var_ndc_lbl,
                pkg_constants.var_ndc_prod,
                v_value,
                pkg_constants.var_pur_catg_cd,
                pkg_constants.var_parent_formula_id);

   ELSE

        -- insert result
        INSERT INTO hcrs.pur_intrm_results_t(
                        formula_id,
                        period_id,
                        ndc_lbl,
                        ndc_prod,
                        ndc_pckg,
                        calc_amt,
                        pgm_id,
                        parent_formula_id)
        VALUES (i_formula_id,
                pkg_constants.var_period_id,
                pkg_constants.var_ndc_lbl,
                pkg_constants.var_ndc_prod,
                pkg_constants.var_ndc_pckg,
                v_value,
                pkg_constants.var_pgm_id,
                pkg_constants.var_parent_formula_id);

   END IF;


EXCEPTION
WHEN OTHERS THEN
     -- Raise errors
     pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.p_store_result'
                                          ,i_module_descr => 'This function will store the value for the specified formula.'
                                          ,i_error_cd => SQLCODE
                                          ,i_error_msg => SQLERRM
                                          ,i_cmt_txt => 'Cant store result - value:'||v_value);

END p_store_result;

/**********************************************
*       Procedure Name : f_get_result
*       Input params   : None
*       Output params  : None
*       Returns       : Number - the result
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will get the result for the specified criteria.
*
* Modification History
* Date                                          Name                                                            Comment
* ------------                  ------------------                      --------------------------------------
* 12/26/2002         T. Zimmerman               Added Return null
* 01/20/2003         T. Zimmerman               Added eff_dt to queries and pkg_constants.var_result_eff_dt
* 01/22/2003         T. Zimmerman              Removed TRUNC of eff and end dates
* 06/10/2013         A. Gamer                   CRQ51343: added logic for var_ura_adj_firstwac_minus_bp
**************************************************/
FUNCTION f_get_result(i_formula_id NUMBER)
RETURN NUMBER
AS
 v_value NUMBER := NULL;

BEGIN

  -- NOTE: Do not truncate dates!

   IF pkg_constants.var_active_flag = pkg_constants.cs_flag_yes THEN
      IF pkg_constants.var_override_level = pkg_constants.cs_ovrrd_lvl_pckg THEN

         -- Loop - found this to be more efficient than max query
         FOR v_rec IN ( SELECT t.calc_amt
                              ,t.eff_dt
                        FROM     hcrs.pur_results_t t
                        WHERE    t.ndc_lbl = pkg_constants.var_ndc_lbl
                        AND      t.ndc_prod = pkg_constants.var_ndc_prod
                        AND    t.ndc_pckg = pkg_constants.var_ndc_pckg
                        AND      t.period_id = pkg_constants.var_period_id
                        AND    t.pgm_id = pkg_constants.var_pgm_id
                        AND      t.formula_id = i_formula_id
                        AND    pkg_constants.var_request_dt BETWEEN t.eff_dt AND t.end_dt
                        AND    t.parent_formula_id = pkg_constants.var_parent_formula_id
                        ORDER BY t.trnsmsn_seq_no DESC
                                 ,t.eff_dt DESC) LOOP

            -- override the sql function date
            pkg_constants.var_result_eff_dt := v_rec.eff_dt;

            -- get value
            v_value := v_rec.calc_amt;

            -- Exit
            EXIT;

         END LOOP;

      ELSE -- v_override_level = 'CATG'

         -- Loop - found this to be more efficient than max query
         FOR v_rec IN ( SELECT t.calc_amt
                              ,t.eff_dt
                        FROM     hcrs.pur_catg_results_t t
                        WHERE    t.ndc_lbl = pkg_constants.var_ndc_lbl
                        AND      t.ndc_prod = pkg_constants.var_ndc_prod
                        AND      t.period_id = pkg_constants.var_period_id
                        AND      t.formula_id = i_formula_id
                        AND    t.pur_catg_cd = pkg_constants.var_pur_catg_cd
                        AND    pkg_constants.var_request_dt BETWEEN t.eff_dt AND t.end_dt
                        AND    t.parent_formula_id = pkg_constants.var_parent_formula_id
                        ORDER BY t.trnsmsn_seq_no DESC
                                 ,t.eff_dt DESC) LOOP

            -- override the sql function date
            pkg_constants.var_result_eff_dt := v_rec.eff_dt;

            -- get value
            v_value := v_rec.calc_amt;

            -- Exit
            EXIT;

         END LOOP;

      END IF;

   ELSIF pkg_constants.var_active_flag = pkg_constants.cs_flag_no THEN
      IF pkg_constants.var_override_level = pkg_constants.cs_ovrrd_lvl_pckg THEN

         SELECT t.calc_amt
         INTO           v_value
         FROM           hcrs.pur_intrm_results_t t
         WHERE          t.ndc_lbl = pkg_constants.var_ndc_lbl
         AND            t.ndc_prod = pkg_constants.var_ndc_prod
         AND      t.ndc_pckg = pkg_constants.var_ndc_pckg
         AND            t.period_id = pkg_constants.var_period_id
         AND      t.pgm_id = pkg_constants.var_pgm_id
         AND            t.formula_id = i_formula_id
         AND      t.parent_formula_id = pkg_constants.var_parent_formula_id;

      ELSE -- v_override_level = 'CATG'

         SELECT t.calc_amt
         INTO   v_value
         FROM    hcrs.pur_catg_intrm_results_t t
         WHERE   t.ndc_lbl = pkg_constants.var_ndc_lbl
         AND     t.ndc_prod = pkg_constants.var_ndc_prod
         AND     t.period_id = pkg_constants.var_period_id
         AND    t.pur_catg_cd = pkg_constants.var_pur_catg_cd
         AND     t.formula_id = i_formula_id
         AND    t.parent_formula_id = pkg_constants.var_parent_formula_id;

      END IF;

   END IF;

  -- If valus is null, raise exception
  IF v_value IS NULL THEN

      RAISE NO_DATA_FOUND;

  -- Otherwise, if value is negative
  ELSIF v_value < 0 THEN
      --Do not substitute with 0 URA Adjustment value
      IF i_formula_id NOT IN (pkg_constants.var_ura_cap_adj_formula_id,
                          pkg_constants.var_ura_adj_lastwac_minus_bp,
                          pkg_constants.var_ura_adj_firstwac_minus_bp) THEN
         -- Raise calculation exception
         pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.f_get_result',
                                                       i_module_descr => 'This function will get the value for the specified criteria.',
                                                       i_cmt_txt => 'Retrieved value:'||v_value||' is negative - Substituting with zero and continuing calculation.');
         -- set
         v_value := 0;

      END IF;

  END IF;

  -- Return
  RETURN v_value;


EXCEPTION
WHEN NO_DATA_FOUND THEN

     IF pkg_constants.var_inquiry_mode THEN

        -- Set execute query flag to false
        v_execute_query_flag := FALSE;

        --Return null
        RETURN NULL;

     ELSE
        -- Raise errors
        pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_result'
                                             ,i_module_descr => 'This function will get the value for the specified criteria.'
                                             ,i_error_cd => SQLCODE
                                             ,i_error_msg => SQLERRM
                                             ,i_cmt_txt => 'Cant find result for formula');

       -- Return null
       RETURN NULL;

     END IF;

WHEN OTHERS THEN
     -- Raise errors
     pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_result'
                                          ,i_module_descr => 'This function will get the value for the specified criteria.'
                                          ,i_error_cd => SQLCODE
                                          ,i_error_msg => SQLERRM
                                          ,i_cmt_txt => 'Cant get result for fromula');

       -- Return null
       RETURN NULL;

END f_get_result;

/**********************************************
*       Procedure Name : p_store_formula_hist
*       Input params   : i_formula - the formula text
*       Output params  : none
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will store the formula text.
*
* Modification History
* Date                          Name                                     Comment
* ------------                  ------------------                      --------------------------------------
* 09/29/2014                    T. Zimmerman                            Various changes to support D5741 - HCRS - New URA Reports - i.e. added fields
**************************************************/
PROCEDURE p_store_formula_hist (i_formula VARCHAR)
AS
  v_result NUMBER := NULL;
BEGIN

  -- Calculate
  v_result := f_calc_value(g_formula_values);

   -- Insert formula history
   INSERT INTO hcrs.pur_formula_calc_hist_t(
               formula_id,
               ndc_lbl,
               ndc_prod,
               ndc_pckg,
               eff_dt,
               end_dt,
               formula_txt,
               period_id,
               pgm_id,
               pur_catg_cd
               ,formula
               ,formula_details
               ,formula_details_values
               ,formula_result
               )
   VALUES (pkg_constants.var_parent_formula_id,
           pkg_constants.var_ndc_lbl,
           pkg_constants.var_ndc_prod,
           pkg_constants.var_ndc_pckg,
           pkg_constants.var_begin_qtr_dt,
           pkg_constants.var_end_qtr_dt,
           i_formula,
           pkg_constants.var_period_id,
           pkg_constants.var_pgm_id,
           pkg_constants.var_pur_catg_cd
           ,g_formula
           ,g_formula_details
           ,g_formula_details_values
           ,v_result
           );

EXCEPTION
   WHEN OTHERS THEN
     -- Raise errors
     pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.p_store_formula_hist'
                                          ,i_module_descr => 'This function will store the formula text.'
                                          ,i_error_cd => SQLCODE
                                          ,i_error_msg => SQLERRM
                                          ,i_cmt_txt => 'Cant store formula history - formula:'||i_formula);

END p_store_formula_hist;


/**********************************************
*       Procedure Name : f_build_statement
*       Input params   : i_formula_id - the formula ID
*       Output params  : None
*       Returns       : Varchar - the query string to execute
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will return the query string for the specified formula.
* Modification History
* Date                     Name                        Comment
* ------------        ------------------       --------------------------------------
* 12/26/2002         T. Zimmerman               Added Set override flag to true, set final test flag to false, Return null
* 04/15/2010         A. Gamer                   CRQ44277: Added logic to assign value to pkg_constants.var_formula_sql_txt
*                                               that will be used to get Total URA Amount
* 05/03/2010         A. Gamer                   Get precision for Interim Calc Step
* 08/05/2010         A. Gamer                   CRQ48778 - var_ura_adj_lastwac_minus_bp for Delaware DHCP
* 06/10/2013         A. Gamer                   CRQ51343 - added logic for var_ura_adj_firstwac_minus_bp (DHCP)
* 09/29/2014         T. Zimmerman               Various changes to support D5741 - HCRS - New URA Reports i.e. added calls to p_store_values
**************************************************/
FUNCTION f_build_statement(i_formula_id NUMBER)
RETURN VARCHAR
AS
  v_value    NUMBER := NULL;
  v_sub_formula_value    NUMBER := NULL;
  v_operand_value    NUMBER := NULL;
  v_formula  VARCHAR(32767) := NULL;
  v_sub_formula  VARCHAR(5000) := NULL;
  v_cursor   NUMBER;
  v_return   NUMBER;
  v_skip_operand BOOLEAN := FALSE;
  v_sql_func hcrs.pur_formula_precision_t.sql_func%TYPE := NULL;
  v_prec hcrs.pur_formula_precision_t.val%TYPE := NULL;

BEGIN

     -- Loop and create statement
     FOR v_rec IN (SELECT pc.comp_id,
                          pc.comp_cd,
                          pc.comp_typ_cd,
                          pc.val_typ_cd,
                          pfd.formula_dtl_id,
                          pfd.sub_formula_id,
                          pc.formula_id AS comp_formula_id
                          ,pfd.formula_step
                   FROM   hcrs.pur_formula_dtl_t pfd,
                          hcrs.pur_comp_t pc
                   WHERE  pfd.formula_id = i_formula_id
                   AND    pc.comp_id(+) = pfd.comp_id
                   ORDER BY formula_step ASC) LOOP

g_formula := g_formula ||' '|| v_rec.comp_cd;

         IF NOT pkg_constants.var_inquiry_mode THEN
            --assign value to pkg_constants.var_formula_sql_txt
            IF v_rec.sub_formula_id IN (pkg_constants.var_ura_cap_adj_formula_id,
                                    pkg_constants.var_ura_adj_lastwac_minus_bp,
                                    pkg_constants.var_ura_adj_firstwac_minus_bp) THEN
              pkg_constants.var_formula_sql_txt := 'SELECT ' || v_formula;
              --for debugging
/*              pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.f_build_statement',
                                                       i_module_descr => 'Build pkg_constants.var_formula_sql_txt',
                                                       i_cmt_txt => 'Formula before TCAP:'||pkg_constants.var_formula_sql_txt);*/
            END IF;

         END IF;

         -- Register formula id
         pkg_constants.var_formula_id := i_formula_id;

         -- If SUBFORMULA, recursively call this module whith subformula id
         IF v_rec.sub_formula_id IS NOT NULL THEN

              -- Register formula id
              pkg_constants.var_formula_id := v_rec.sub_formula_id;

              IF pkg_constants.var_inquiry_mode THEN

                  -- test for formula at lowest level
                  IF f_test_formula_lowest_level(v_rec.sub_formula_id) THEN

                       -- Get the result
                       v_sub_formula := to_char(f_get_result(v_rec.sub_formula_id));
                  ELSE

                      -- store value
                      p_store_value(i_text  => '(',
                                    i_value => '(');
                      g_formula := g_formula || '(';

                      -- get sub_formula
                      v_sub_formula := f_build_statement(v_rec.sub_formula_id);

                      --reset
                      p_set_g_in_comp_query_func(FALSE);

                      -- store value
                      p_store_value(i_text  => ')',
                                    i_value => ')');
                      g_formula := g_formula || ')';

                  END IF;

                  -- add subformula to formula
                  v_formula := v_formula || '(' || v_sub_formula || ')';

              ELSE
                  -- store value
                  p_store_value(i_text  => '(',
                                i_value => '(');
                  g_formula := g_formula || '(';

                  -- get sub_formula
                  v_sub_formula := f_build_statement(v_rec.sub_formula_id);

                  p_set_g_in_comp_query_func(FALSE);
                  -- store value
                  p_store_value(i_text  => ')',
                                i_value => ')');
                  g_formula := g_formula || ')';

                 -- execute sub_formula
                 v_sub_formula_value := pkg_pur_common_functions.f_execute_query('SELECT '||v_sub_formula||' FROM DUAL');

                 -- test for formula at lowest level
                 IF f_test_formula_lowest_level(v_rec.sub_formula_id) THEN

                     -- If value is not null
                     IF v_sub_formula_value IS NOT NULL THEN

                        -- Perform SQL function on subformula value
/*                        v_sub_formula_value := pkg_pur_common_functions.f_perform_sql_func(i_formula_id => v_rec.sub_formula_id,
                                                                                           i_calc_step => pkg_constants.cs_calc_step_final,
                                                                                           i_value => v_sub_formula_value);*/

                        v_sub_formula_value := pkg_pur_common_functions.f_perform_sql_func(i_formula_id => v_rec.sub_formula_id,
                                                                   i_calc_step => pkg_constants.cs_calc_step_interim,
                                                                   i_value => v_sub_formula_value);
                     END IF;

                     -- store temporary result for component formula
                     p_store_result(v_rec.sub_formula_id,
                                    v_sub_formula_value);

                     -- add subformula value to formula
                     v_formula := v_formula || '(' || v_sub_formula_value || ')';

                 ELSE

                     -- add subformula to formula
                     v_formula := v_formula || '(' || v_sub_formula || ')';

                 END IF;

              END IF;

         -- if OPERAND, get value
         ELSIF v_rec.comp_typ_cd = pkg_constants.cs_comp_typ_operand THEN

              IF v_skip_operand THEN
                 v_skip_operand := FALSE; -- reset
              ELSE

                  -- get the value for the operand
                  v_operand_value := f_get_value(i_formula_id,--pkg_constants.var_parent_formula_id,
                                                 v_rec.comp_id,
                                                 v_rec.val_typ_cd,
                                                 v_rec.comp_typ_cd,
                                                 v_rec.comp_cd);


                  -- try to perform sql function on value
                  IF v_rec.val_typ_cd = pkg_constants.cs_val_typ_sysval
                  AND v_operand_value IS NOT NULL THEN

                     -- perfrom function
                     v_operand_value := pkg_pur_common_functions.f_perform_sql_func(i_formula_id => i_formula_id,
                                                                                  i_calc_step => 'SYSVAL '||v_rec.comp_cd,
                                                                                  i_value => v_operand_value,
                                                                                  i_raise_exception => pkg_constants.cs_flag_no);

                  END IF;

                  -- put the value into the formula string
                  v_formula := v_formula ||' '|| v_operand_value;

              END IF;

         ELSE -- 'OPERATOR'
               IF v_rec.comp_cd = pkg_constants.cs_comp_code_input_parm THEN -- This is the '@' character
                  v_skip_operand := TRUE; -- set to skip the OPERAND which is next in the cursor
               ELSE
                   v_formula := v_formula ||' '|| v_rec.comp_cd;
               END IF;

              -- store value
              p_store_value(i_text  => v_rec.comp_cd,
                            i_value => v_rec.comp_cd);

         END IF;

     END LOOP;

     -- return formula
     RETURN v_formula;

EXCEPTION
        WHEN OTHERS THEN
       pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_build_statement',
                                                 i_module_descr => 'This function will return the query string for the specified formula.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant build statement for formula_id:'||i_formula_id  ||' formula:'||v_formula);
       -- Set override flag to true
       v_override_result_flag := TRUE;

       -- Set fianl test flag to false
       v_perform_final_tests_flag := FALSE;

       -- Return null
       RETURN NULL;

END f_build_statement;

/**********************************************
*       Procedure Name : f_calculate
*       Input params   : None
*       Output params  : None
*       Returns       : Number - the value of the calculation
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will return the value for the calculation.
* Modification History
* Date                   Name                               Comment
* ------------       ------------------         --------------------------------------
* 12/26/2002         T. Zimmerman               Added Set override flag to true, set final test flag to false, Return null
* 05/03/2010         A. Gamer                   Get precision for Interim Calc Step
**************************************************/
FUNCTION f_calculate
RETURN NUMBER
AS
  v_value    NUMBER := NULL;
  v_formula  VARCHAR(32767) := NULL;
  v_return   NUMBER;
  v_sql_func hcrs.pur_formula_precision_t.sql_func%TYPE := NULL;
  v_prec hcrs.pur_formula_precision_t.val%TYPE := NULL;
BEGIN

     -- Test if parent formula at lowest level
     v_parent_formula_at_lowest_lvl := f_test_formula_lowest_level(pkg_constants.var_parent_formula_id);

     -- Begin select statement
     v_formula := 'SELECT ';

     -- If inquiry and test for formula at lowest level
     IF pkg_constants.var_inquiry_mode
     AND v_parent_formula_at_lowest_lvl THEN

           -- Get the result
           v_formula := v_formula || to_char(f_get_result(pkg_constants.var_parent_formula_id));

     ELSE

           -- Build statement
           v_formula := v_formula || f_build_statement(pkg_constants.var_parent_formula_id);

     END IF;

     -- Complete statement
     v_formula := v_formula ||' FROM DUAL';

     -- If not inquiry mode
     IF NOT pkg_constants.var_inquiry_mode THEN

          -- Store formula hist
          p_store_formula_hist(v_formula);

     END IF;

     -- if query is to be executed
     IF v_execute_query_flag THEN

        -- Execute query
        v_value := pkg_pur_common_functions.f_execute_query(v_formula);

     ELSE

        -- value is null
        v_value := NULL;

     END IF;

     -- If not inquiry mode
     -- and if this is a formula without subformulas, store the result
     IF NOT pkg_constants.var_inquiry_mode
     AND v_parent_formula_at_lowest_lvl THEN

         -- Check the value
         IF v_value IS NOT NULL THEN

              -- Perform SQL function on value
             /* v_value := pkg_pur_common_functions.f_perform_sql_func(i_formula_id => pkg_constants.var_parent_formula_id,
                                                                     i_calc_step => pkg_constants.cs_calc_step_final,
                                                                     i_value => v_value);*/

              v_value := pkg_pur_common_functions.f_perform_sql_func(i_formula_id => pkg_constants.var_parent_formula_id,
                                                                     i_calc_step => pkg_constants.cs_calc_step_interim,
                                                                     i_value => v_value);
         END IF;

         -- store temporary result for component formula
          p_store_result(pkg_constants.var_parent_formula_id,
                         v_value);

     END IF;

     -- Return value
     RETURN v_value;




EXCEPTION
        WHEN OTHERS THEN
       pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_calculate',
                                                 i_module_descr => 'This function will return the value for the calculation.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant calculate PUR - formula:'||v_formula);

       -- Set override flag to true
       v_override_result_flag := TRUE;

       -- Set fianl test flag to false
       v_perform_final_tests_flag := FALSE;

       -- return null
       RETURN NULL;

END f_calculate;

/**********************************************
*       Procedure Name : f_get_pgm_id
*       Input params   : None
*       Output params  : None
*       Returns       : Number - the result
*       Date Created   : 01/17/2003
*       Author        : Tom Zimmerman
*       Description    : This function will get the result for the specified criteria.
*
* Modification History
* Date                                          Name                                                            Comment
* ------------                  ------------------                      --------------------------------------
* 01/22/2003         T. Zimmerman              Removed TRUNC of eff and end dates
* 04/17/2003         Joe Kidd                   PICCs 1042: Disable Program ID not found error
**************************************************/
FUNCTION f_get_pgm_id
RETURN NUMBER
AS
 v_temp_pgm_id NUMBER := NULL;
BEGIN

    -- Get ANY ONE of the pgm_ids for the specified category
    -- LOOP because there could be more than 1 row selected
    FOR v_pgm_rec IN (SELECT t.pgm_id
                      FROM   hcrs.pur_catg_pgm_t t
                      WHERE  t.pur_catg_cd = pkg_constants.var_pur_catg_cd
                      AND    pkg_constants.var_request_dt BETWEEN t.eff_dt AND t.end_dt
                      AND    pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(t.begin_qtr_dt) AND TRUNC(t.end_qtr_dt)
                      ORDER BY t.eff_dt DESC) LOOP

       -- Get the pgm
       v_temp_pgm_id := v_pgm_rec.pgm_id;

       -- Exit loop
       EXIT;

    END LOOP;
    /* -- PICC 1042
    -- check for null
    IF v_temp_pgm_id IS NULL THEN

      -- Exception
      pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.f_get_pgm_id',
                                                       i_module_descr => 'This function will return the PGM ID value for the specified request.',
                                                       i_cmt_txt => 'Cant get the pgm_id for the specified category:'||pkg_constants.var_pur_catg_cd||' request_dt:'||pkg_constants.var_request_dt||' begin_qtr_dt:'||pkg_constants.var_begin_qtr_dt);

    END IF;
    */

   -- Return
   RETURN v_temp_pgm_id;

EXCEPTION
   WHEN OTHERS THEN
       pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_pgm_id',
                                                 i_module_descr => 'This function will return the PGM ID value for the specified request.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant get the pgm_id for the specified category:'||pkg_constants.var_pur_catg_cd||' request_dt:'||pkg_constants.var_request_dt||' begin_qtr_dt:'||pkg_constants.var_begin_qtr_dt);

      -- Return NULL
      RETURN NULL;

END f_get_pgm_id;


/**********************************************
*       Procedure Name : f_run_calc
*       Input params   : i_prcss_queue_id - the batch process request id
*       Output params  : None
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will return the calculated PUR value for the specified request.
*
* Modification History
* Date                                          Name                                                            Comment
* ------------                  ------------------                      --------------------------------------
* 12/27/2002         T. Zimmerman               Added set v_inqiry_only flag
* 01/16/2003         T. Zimmerman               Added registered flag
* 01/17/2003         T. Zimmerman              Changed get_pgm_id logic
* 01/22/2003         T. Zimmerman              Removed TRUNC of eff and end dates
* 04/17/2003         Joe Kidd                   PICCs 1041: Only Calculate PUR Categories
*                                               actually in use. (Remove NY-EPIC when
*                                               it is not in use)
* 04/28/2003         Joe Kidd                   PICC 881: Close Change Log Entries
*                                               created by prod_trnsmsn_t.amp_amt changes
* 10/15/2003         Joe Kidd                   PICC 1120: PCKG override fails when
*                                               no package level components are on
*                                               the formula
* 08/03/2004         Joe Kidd                   PICC 1273: Correct main query that
*                                               was dropping catgory level calculations
* 07/01/2008        A. Gamer                    ACTIV_READY flag is passed to this procedure
*                                               'Y': indicates URA calculation must be
*                                               based on the approved/transmitted AMP/BP
*                                               'N': indicates URA calculation must be
*                                               based on the latest calculated AMP/BP regardless
*                                               of the approval status.
* 04/09/2010        A. Gamer                    Register URA CAP Adjustment Formula ID, URA Formula SQL text
* 08/05/2010        A. Gamer                    CRQ48778 - var_ura_adj_lastwac_minus_bp for Delaware DHCP
* 06/10/2013        A. Gamer                    CRQ51343 - added logic for var_ura_adj_firstwac_minus_bp (DHCP)
* 09/29/2014        T. Zimmerman                Various changes to support D5741 - HCRS - New URA Reports
* 01/07/2015        T. Zimmerman                Changes to support CRQ000000145747 - use quarter date below as opposed to MAX
****************************************************************************************************/
PROCEDURE p_run_calc(i_prcss_queue_id hcrs.pur_calc_request_t.prcss_queue_id%TYPE,
                     i_ndc_lbl        hcrs.pur_calc_request_t.ndc_lbl%TYPE,
                     i_ndc_prod       hcrs.pur_calc_request_t.ndc_prod%TYPE,
                     i_period_id      hcrs.pur_calc_request_t.period_id%TYPE,
                     i_activ_ready    hcrs.pur_calc_request_t.activ_ready%TYPE)
AS
  v_value NUMBER := NULL;
  v_o_pur_amt NUMBER := NULL;
  v_prod_cur t_prod_cur;
  v_prod_rec t_prod_rec;
  v_return NUMBER := NULL;
  v_temp_pgm_id hcrs.pgm_t.pgm_id%TYPE := NULL;
  v_temp_execute_query_flag BOOLEAN := TRUE;
BEGIN

   -- Register process name
   pkg_constants.var_process_name := pkg_constants.cs_pur;

   -- Kill jobs which are failed
   v_return := pkg_pur_job.f_kill_job;

   -- Register queue id
   pkg_constants.var_queue_id := i_prcss_queue_id;

   -- Register labeler
   pkg_constants.var_ndc_lbl := i_ndc_lbl;

   -- Register product
   pkg_constants.var_ndc_prod := i_ndc_prod;

   -- Register Period ID
   pkg_constants.var_period_id := i_period_id;

   -- Register active flag
   --pkg_constants.var_active_flag := pkg_constants.cs_flag_no;
   pkg_constants.var_active_flag := i_activ_ready;

   -- Register result effective date
   pkg_constants.var_result_eff_dt := SYSDATE;

   -- Set flag
   v_inquiry_only := FALSE;

   -- update job status
   pkg_pur_common_procedures.p_update_calc_request_status(i_calc_stat_cd => pkg_constants.cs_calc_run_status);

   -- Delete interim results
   pkg_pur_common_procedures.p_delete_intrm_results;

   -- Commit
   COMMIT;

   -- Register request date
   pkg_constants.var_request_dt := SYSDATE;

   -- Get and Register the quarter dates
   p_register_quarter_dates;

   --Get and Register URA CAP Adjustment Formula ID
    SELECT pf.formula_id
    INTO pkg_constants.var_ura_cap_adj_formula_id
    FROM hcrs.pur_formula_t pf
    WHERE pf.formula_descr like 'URA Adjustment @TCAP%';

   --Get and Register URA Adjustment @LastWAC-BP Formula ID
     SELECT pf.formula_id
     INTO pkg_constants.var_ura_adj_lastwac_minus_bp
     FROM hcrs.pur_formula_t pf
     WHERE pf.formula_descr like 'URA Adjustment @LastWAC-BP%';

   --Get and Register URA Adjustment @FirstWAC-BP Formula ID
     SELECT pf.formula_id
     INTO pkg_constants.var_ura_adj_firstwac_minus_bp
     FROM hcrs.pur_formula_t pf
     WHERE pf.formula_descr like 'URA Adjustment @FirstWAC-BP%';

    -- Loop
    -- get all formulas and programs to process
    -- formula_id may not be populated
    FOR v_rec IN (-- Get the Category level
                  SELECT   distinct pcf.formula_id,
                           pcr.period_id,
                           -1 as pgm_id,-- cant use null due to runtimme error
                           pcf.pur_catg_cd,
                           'CATG' AS override_level
                  FROM     hcrs.pur_calc_request_t pcr,
                           hcrs.period_t p,
                           hcrs.prod_fmly_drug_catg_t pfdc,
                           hcrs.drug_catg_grp_asgnmnt_t dcga,
                           hcrs.pur_catg_formula_t pcf,
                           hcrs.pur_catg_pgm_t pcp, -- PICC 1041
                           hcrs.pur_formula_t pf,
                           hcrs.prod_mstr_pgm_t pmp -- product must exist on a pgm using this category
                  WHERE    pcr.prcss_queue_id = pkg_constants.var_queue_id
                  AND      pcr.request_typ_cd = pkg_constants.cs_pur
                  AND      pcr.ndc_lbl = pkg_constants.var_ndc_lbl
                  AND      pcr.ndc_prod = pkg_constants.var_ndc_prod
                  AND      pcr.period_id = pkg_constants.var_period_id
                  AND      p.period_id = pcr.period_id
                  AND      pfdc.ndc_lbl = pcr.ndc_lbl
                  AND      pfdc.ndc_prod = pcr.ndc_prod
                  AND      pkg_constants.var_begin_qtr_dt BETWEEN pfdc.eff_dt AND pfdc.end_dt
--                AND      pkg_constants.var_request_dt BETWEEN pfdc.eff_dt AND pfdc.end_dt
                  AND      dcga.drug_catg_cd = pfdc.drug_catg_cd
                  AND      pcf.drug_catg_grp_cd = dcga.drug_catg_grp_cd
                  AND      pcf.pur_catg_cd = pcp.pur_catg_cd -- PICC 1041
                  AND      pf.formula_id = pcf.formula_id
                  AND      (pcf.apprvd_stat_cd = pcr.apprvd_stat_cd
                           OR pcr.apprvd_stat_cd IS NULL)
                  AND      pkg_constants.var_request_dt BETWEEN pcf.eff_dt AND pcf.end_dt
                  AND      TRUNC(p.first_day_period) BETWEEN TRUNC(pcf.begin_qtr_dt) AND TRUNC(pcf.end_qtr_dt)
                  AND      pkg_constants.var_request_dt BETWEEN pcp.eff_dt AND pcp.end_dt -- PICC 1041
                  AND      TRUNC( p.first_day_period) BETWEEN TRUNC( pcp.begin_qtr_dt) AND TRUNC( pcp.end_qtr_dt) -- PICC 1041
                  AND      pmp.ndc_lbl = pcr.ndc_lbl
                  AND      pmp.ndc_prod = pcr.ndc_prod
                  AND      pmp.pgm_id = pcp.pgm_id
                  AND      TRUNC( p.first_day_period) BETWEEN pmp.eff_dt AND pmp.end_dt
                  AND NOT EXISTS (SELECT 1
                                    FROM hcrs.pur_formula_pgm_prod_assoc_t pfppa
                                   WHERE pfppa.formula_id = pcf.formula_id
                                     AND pfppa.ndc_lbl = pcr.ndc_lbl
                                     AND pfppa.ndc_prod = pcr.ndc_prod
                                     AND pfppa.pur_catg_cd = pcf.pur_catg_cd
                                     AND pkg_constants.var_request_dt BETWEEN pfppa.eff_dt AND pfppa.end_dt
                                     AND TRUNC( p.first_day_period) BETWEEN TRUNC( pfppa.begin_qtr_dt) AND TRUNC( pfppa.end_qtr_dt))
                  -- Get the Package level
                  UNION
                  SELECT   distinct pf.formula_id,
                           pcr.period_id,
                           pfppa.pgm_id,
                           pfppa.pur_catg_cd,
                           'PCKG' AS override_level--lookup_level
                  FROM          hcrs.pur_calc_request_t pcr,
                           hcrs.pur_formula_pgm_prod_assoc_t pfppa,
                           hcrs.period_t p,
                           hcrs.pur_formula_t pf
                  WHERE         pcr.prcss_queue_id = pkg_constants.var_queue_id
                  AND      pcr.request_typ_cd = pkg_constants.cs_pur
                  AND      pcr.ndc_lbl = pkg_constants.var_ndc_lbl
                  AND      pcr.ndc_prod = pkg_constants.var_ndc_prod
                  AND      pcr.period_id = pkg_constants.var_period_id
                  AND      pfppa.ndc_prod = pcr.ndc_prod
                  AND      pfppa.ndc_lbl = pcr.ndc_lbl
                  AND      p.period_id = pcr.period_id
                  AND      TRUNC(p.first_day_period) BETWEEN TRUNC(pfppa.begin_qtr_dt) AND TRUNC(pfppa.end_qtr_dt)
                  AND      pf.formula_id = pfppa.formula_id
                  AND      (pfppa.apprvd_stat_cd = pcr.apprvd_stat_cd
                           OR pcr.apprvd_stat_cd IS NULL)

                  ORDER BY 2, --period_id,
                           1, --formula_id,
                           4, --pur_catg_cd,
                           3, --pgm_id,
                           5 --lookup_level

                  )LOOP

         -- Initialize
         v_override_result_flag := FALSE;
         v_perform_final_tests_flag := TRUE;
         v_parent_formula_at_lowest_lvl := FALSE;
         v_execute_query_flag := TRUE;
         pkg_constants.var_fatal_flag := FALSE;

         -- Register parent formula
         pkg_constants.var_parent_formula_id := v_rec.formula_id;

         -- Register the lookup level
         pkg_constants.var_override_level := v_rec.override_level;

         -- Register program id -- cant use null due to runtimme error
         IF v_rec.pgm_id = -1 THEN
            pkg_constants.var_pgm_id := NULL;
         ELSE
            pkg_constants.var_pgm_id := v_rec.pgm_id;
         END IF;

         -- Get & Register Program Code
         IF pkg_constants.var_override_level = 'PCKG'
           AND pkg_constants.var_pgm_id IS NOT NULL THEN
             SELECT p.pgm_cd
             INTO pkg_constants.var_pgm_cd
             FROM hcrs.pgm_t p
             WHERE p.pgm_id = pkg_constants.var_pgm_id;
         ELSE
             pkg_constants.var_pgm_cd := NULL;
         END IF;

         -- Register PUR category
         pkg_constants.var_pur_catg_cd := v_rec.pur_catg_cd;

         -- If there is a package level override or
         -- Determine if there is a component in the formula at the Package level -- i.e. AWP
         IF    pkg_constants.var_override_level = pkg_constants.cs_ovrrd_lvl_pckg
            OR f_test_formula_pkg_lvl_comp(pkg_constants.var_parent_formula_id)
         THEN
            -- if so, get all relevant packages at 11 digit
            OPEN v_prod_cur FOR
                  SELECT DISTINCT pfppa.ndc_lbl,
                         pfppa.ndc_prod,
                         pfppa.ndc_pckg
                  FROM   hcrs.pur_formula_pgm_prod_assoc_t pfppa
                  WHERE  pfppa.ndc_lbl = pkg_constants.var_ndc_lbl
                  AND    pfppa.ndc_prod = pkg_constants.var_ndc_prod
                  AND    pfppa.pgm_id = v_rec.pgm_id
                  AND    pfppa.formula_id = v_rec.formula_id
                  AND    pkg_constants.var_request_dt BETWEEN pfppa.eff_dt AND pfppa.end_dt
                  AND    pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(pfppa.begin_qtr_dt) AND TRUNC(pfppa.end_qtr_dt)
                  AND    pfppa.pur_catg_cd = pkg_constants.var_pur_catg_cd;

             -- Register level
             pkg_constants.var_pckg_lvl_ind := pkg_constants.cs_flag_yes;
         ELSE
            -- otherwise, just use the 9 digit ndc
            -- this cursor will only have 1 row, but will fit into logic easier
            OPEN v_prod_cur FOR
                  SELECT pkg_constants.var_ndc_lbl,
                         pkg_constants.var_ndc_prod,
                         NULL
                  FROM   dual;

             -- Register level
             pkg_constants.var_pckg_lvl_ind := pkg_constants.cs_flag_no;

         END IF;

         -- Loop thru product(s)
         LOOP
            FETCH v_prod_cur INTO v_prod_rec;
            EXIT WHEN v_prod_cur%NOTFOUND;

                  -- Register pckg
                  pkg_constants.var_ndc_pckg := v_prod_rec.ndc_pckg;

                  -- Initialize URA Formula SQL text
                  pkg_constants.var_formula_sql_txt := NULL;

                  --Init
                  g_formula := NULL;
                  g_formula_details  := NULL;
                  g_formula_values := NULL;
                  g_formula_details_values := NULL;
                  g_missing_items := NULL;

                  -- Calculate
                  v_value := f_calculate;

                  -- If perform final tests
                  IF v_perform_final_tests_flag THEN

                     -- IF pgm_id is null
                     IF pkg_constants.var_pgm_id IS NULL THEN

                        -- Try to get the pgm_id for the specified category
                        v_temp_pgm_id := f_get_pgm_id;

                     ELSE
                         v_temp_pgm_id := pkg_constants.var_pgm_id;
                     END IF;

                     IF v_temp_pgm_id IS NOT NULL THEN

                        -- Store execute query flag before get pur
                        v_temp_execute_query_flag := v_execute_query_flag;

                        -- test this PUR result to see if it is the same as before
                        -- by calling the f_get_pur.
                        -- If not or the previous PUR is the same ok, otherwise exception
                        v_return := f_get_pur(i_pgm_id => v_temp_pgm_id,
                                              i_ndc_lbl => pkg_constants.var_ndc_lbl,
                                              i_ndc_prod => pkg_constants.var_ndc_prod,
                                              i_period_id => pkg_constants.var_period_id,
                                              i_request_dt => SYSDATE,
                                              i_active_flag => pkg_constants.cs_flag_yes,
                                              i_ndc_pckg => pkg_constants.var_ndc_pckg,
                                              o_pur_amt => v_o_pur_amt);

                        -- UN-Register inquiry mode - due to call to inquiry code and returning to calculation code
                        pkg_constants.var_inquiry_mode := FALSE;

                        -- Re-register active flag
                        --pkg_constants.var_active_flag := pkg_constants.cs_flag_no;
                        pkg_constants.var_active_flag := i_activ_ready;

                        -- Restore execute query flag
                        v_execute_query_flag := v_temp_execute_query_flag;

                        -- Test if calculated PUR is EQUAL to previously calculated PUR
                        -- and not the first calculation of this product and period
                        IF v_o_pur_amt = v_value
                        AND NOT f_test_first_calc THEN

                              -- Raise calculation exception
                              pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.p_run_calc',
                                                                               i_module_descr => 'This function will return the calculated PUR value for the specified request.',
                                                                               i_cmt_txt => 'Calculated PUR: '||v_value||' is EQUAL to previously calcualted PUR: '||v_o_pur_amt);

                        END IF; -- test

                     END IF;

                  END IF;

                  -- commit each program product combinatiom
                  COMMIT;

         END LOOP;

         -- Close product cursor
         CLOSE v_prod_cur;

    -- End Formula loop
    END LOOP;

    -- update job status
    pkg_pur_common_procedures.p_update_calc_request_status(i_calc_stat_cd => pkg_constants.cs_calc_complete_status);

    -- Update the prod_trnsmsn_stat_cd
    pkg_pur_common_procedures.p_update_prod_trnsmsn_status;

    -- Close Change Logs for prod_trnsmsn_t.amp_amt changes
    chglog_util.close_pur_eff
       (pkg_constants.var_ndc_lbl,
        pkg_constants.var_ndc_prod,
        pkg_constants.var_period_id,
        pkg_constants.var_request_dt);

    -- Commit the work
    COMMIT;

EXCEPTION

        WHEN OTHERS THEN
       pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_run_calc',
                                                 i_module_descr => 'This function will return the calculated PUR value for the specified request.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant run calculation');

END p_run_calc;

/**********************************************
*       Procedure Name : f_get_formula_id
*       Input params   : None
*       Output params  : None
*       Returns       : Number - the formula
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will return the formula ID for the specified criteria.
* Modification History
* Date                 Name                         Comment
* ------------       ------------------    --------------------------------------
* 12/20/2002         T. Zimmerman          Total Rewrite
* 01/22/2003         T. Zimmerman          Removed TRUNC of eff and end dates
* 10/19/2012         A. Gamer              CRQ31181: Added criteria for request date between eff and end dates
* 01/07/2015         T. Zimmerman          Changes to support CRQ000000145747 - use quarter date below as opposed to MAX
**************************************************/
FUNCTION f_get_formula_id
RETURN NUMBER
AS
  v_value       NUMBER := NULL;
BEGIN

      -- Try to get the formula at the 'PCKG' level
      BEGIN

         SELECT t.formula_id
         INTO   v_value
         FROM   hcrs.pur_formula_pgm_prod_assoc_t t
         WHERE  t.pgm_id = pkg_constants.var_pgm_id
         AND    t.ndc_lbl = pkg_constants.var_ndc_lbl
         AND    t.ndc_prod = pkg_constants.var_ndc_prod
         AND    t.ndc_pckg = pkg_constants.var_ndc_pckg
         AND    pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(t.begin_qtr_dt) AND TRUNC(t.end_qtr_dt)
         --10/19/12 A.G. added criteria below
         AND    pkg_constants.var_request_dt BETWEEN t.eff_dt AND t.end_dt
         AND    t.eff_dt = (SELECT MAX( t2.eff_dt)
                           FROM   hcrs.pur_formula_pgm_prod_assoc_t t2
                           WHERE  t2.pgm_id = t.pgm_id
                           AND    t2.ndc_lbl = t.ndc_lbl
                           AND    t2.ndc_prod = t.ndc_prod
                           AND    t2.ndc_pckg = t.ndc_pckg
                           AND    pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(t2.begin_qtr_dt) AND TRUNC(t2.end_qtr_dt)
                           AND    pkg_constants.var_request_dt BETWEEN t2.eff_dt AND t2.end_dt);

         -- Set the lookup level
         pkg_constants.var_override_level := pkg_constants.cs_ovrrd_lvl_pckg;


      EXCEPTION
         WHEN NO_DATA_FOUND THEN

            BEGIN

               -- Get the 'CATG' level formula ID
               SELECT   pcf.formula_id
               INTO     v_value
               FROM     hcrs.prod_fmly_drug_catg_t pfdc,
                        hcrs.drug_catg_grp_asgnmnt_t dcga,
                        hcrs.pur_catg_formula_t pcf
               WHERE    pfdc.ndc_lbl = pkg_constants.var_ndc_lbl
               AND      pfdc.ndc_prod = pkg_constants.var_ndc_prod
               AND      pkg_constants.var_begin_qtr_dt BETWEEN pfdc.eff_dt AND pfdc.end_dt
--             AND      pkg_constants.var_request_dt BETWEEN pfdc.eff_dt AND pfdc.end_dt
               AND      dcga.drug_catg_cd = pfdc.drug_catg_cd
               AND      pcf.drug_catg_grp_cd = dcga.drug_catg_grp_cd
               AND      pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(pcf.begin_qtr_dt) AND TRUNC(pcf.end_qtr_dt)
               AND      pcf.pur_catg_cd = pkg_constants.var_pur_catg_cd
               AND      pcf.eff_dt = (SELECT MAX(pcf2.eff_dt)
                                       FROM     hcrs.pur_catg_formula_t pcf2
                                       WHERE    pcf2.drug_catg_grp_cd = dcga.drug_catg_grp_cd
                                       AND      pkg_constants.var_request_dt BETWEEN pcf2.eff_dt AND pcf2.end_dt
                                       AND      pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(pcf2.begin_qtr_dt) AND TRUNC(pcf2.end_qtr_dt)
                                       AND      pcf2.pur_catg_cd = pkg_constants.var_pur_catg_cd);

               -- Set the override level
               pkg_constants.var_override_level := pkg_constants.cs_ovrrd_lvl_catg;

            EXCEPTION
               WHEN NO_DATA_FOUND THEN

                   -- Raise error
                   pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_formula_id',
                                                             i_module_descr => 'This function will return the formula ID for the specified criteria.',
                                                             i_error_cd => SQLCODE,
                                                             i_error_msg => SQLERRM,
                                                             i_cmt_txt => 'Cant get formula ID');

            END;

      END; -- End block

      -- Return
      RETURN v_value;


EXCEPTION
    WHEN OTHERS THEN
       pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_formula_id',
                                                 i_module_descr => 'This function will return the formula ID for the specified criteria.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'l');
       -- Return null
       RETURN NULL;

END f_get_formula_id;

/**********************************************
*       Procedure Name : f_get_pur
*       Input params   : i_pgm_id - the program ID
*                 : i_ndc_lbl - the product labeler
*                 : i_ndc_prod - the product
*                 : i_period_id - the period ID
*                 : i_request_dt - the request date
*                 : i_active_flag - the price active flag
*                 : i_ndc_pckg - the product package
*       Output params  : none
*  Returns        : Number - the PUR result
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will return the PUR value for the specified criteria.
*
* Modification History
*    Date                 Name                                Comment
* ------------       ------------------    --------------------------------------
* 12/23/2002         T. Zimmerman          Changed EXCEPTION to ERROR module call
*                                          Added v_inquiry_onlf flag check and moved variable registration
* 01/08/2003         T. Zimmerman          Moved raise error message for pur catg cd
*                                          Added IF pkg_constants.var_parent_formula_id IS NULL THEN
* 01/20/2003         T. Zimmerman          Added registered flag
* 01/21/2003         T. Zimmerman          Added Initialize override flag
* 01/22/2003         T. Zimmerman          Removed TRUNC of eff and end dates
* 04/09/2010         A. Gamer              Register URA CAP Adjustment Formula ID, URA Formula SQL text
* 08/05/2010         A. Gamer              CRQ48778 - var_ura_adj_lastwac_minus_bp for Delaware DHCP
* 03/19/2013         A. Gamer              CRQ38024 - URA Calc Line Extension PPACA (added var_pgm_cd)
* 06/10/2013         A. Gamer              CRQ51343 - added var_ura_adj_firstwac_minus_bp (DHCP)
* 07/11/2017         T. Zimmerman          Added logic to pull from pur_final_results when active is requested
* 08/09/2017         T. Zimmerman          Added logic: If being called by Activation 'A' then force to 'Y' to get active data
* 05/10/2019         J. Tronoski           ITS-CHG0113127 - Modified retrieval of pcp.pur_catg_cd
* 				           The new logic will check the inquiry mode and quarter begin date
****************************************************************************************************/
FUNCTION f_get_pur(i_pgm_id          IN  hcrs.pur_formula_pgm_prod_assoc_t.pgm_id%TYPE,
                   i_ndc_lbl         IN  hcrs.prod_mstr_t.ndc_lbl%TYPE,
                   i_ndc_prod        IN  hcrs.prod_mstr_t.ndc_prod%TYPE,
                   i_period_id       IN  hcrs.period_t.period_id%TYPE,
                   i_request_dt      IN  DATE,
                   i_active_flag     IN  CHAR,
                   i_ndc_pckg        IN  hcrs.prod_mstr_t.ndc_pckg%TYPE DEFAULT NULL,
                   o_pur_amt         OUT NUMBER,
                   i_log_flag        IN  BOOLEAN DEFAULT TRUE)
RETURN NUMBER
AS
  v_value NUMBER := NULL;
  v_sql_func hcrs.pur_formula_precision_t.sql_func%TYPE := NULL;
  v_prec hcrs.pur_formula_precision_t.val%TYPE := NULL;
  e_cant_find_pur_catg EXCEPTION;
BEGIN

  -- If active is requested
  IF i_active_flag = pkg_constants.cs_flag_yes THEN

    -- Get and Register the quarter dates
    pkg_pur_common_procedures.p_get_period_dates(i_period_id => i_period_id,
                                                 o_eff_dt => pkg_constants.var_begin_qtr_dt,
                                                 o_end_dt => pkg_constants.var_end_qtr_dt);

    -- =========================================================================
    -- Changes to retrieval of the PUR category code
    --
    -- The URA calculation for Non-Federal programs was transitioned to IQVIA
    -- at the end of the 1st Quarter of 2018. Therefore, a program that no
    -- longer calculates URA will have an end quarter date of 3/31/2018.
    --
    -- This function must now check the inquiry mode and the begin
    -- quarter date before performing the lookup:
    --
    --     v_inquiry_only	pkg_constants.var_begin_qtr_dt	   Result
    --     --------------	------------------------------	--------------
    --		TRUE			>= 03/31/2018		New Code
    --		TRUE			< 03/31/2018		Old Code
    --		FALSE						Old Code
    --
    -- =========================================================================

    IF v_inquiry_only AND pkg_constants.var_begin_qtr_dt >= TO_DATE('03/31/2018','MM/DD/YYYY') THEN
        -- Get and register the PUR category code
        SELECT MAX(pcp.pur_catg_cd)
          KEEP (DENSE_RANK LAST
                ORDER BY pcp.end_qtr_dt)
          INTO pkg_constants.var_pur_catg_cd
          FROM hcrs.pur_catg_pgm_t pcp
         WHERE pcp.pgm_id = i_pgm_id
           AND i_request_dt BETWEEN pcp.eff_dt AND pcp.end_dt
           AND pcp.eff_dt = (SELECT MAX(pcp2.eff_dt)
                               FROM hcrs.pur_catg_pgm_t pcp2
                              WHERE pcp2.pgm_id = i_pgm_id
                                AND i_request_dt BETWEEN pcp2.eff_dt AND pcp2.end_dt);
    -- This is the original code to retrieve the PUR category code
    ELSE
        -- Get and register the PUR category code
        SELECT pcp.pur_catg_cd
          INTO pkg_constants.var_pur_catg_cd
          FROM hcrs.pur_catg_pgm_t pcp
         WHERE pcp.pgm_id = i_pgm_id
           AND pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(pcp.begin_qtr_dt) AND TRUNC(pcp.end_qtr_dt)
           AND pcp.eff_dt = (SELECT MAX(pcp2.eff_dt)
                               FROM hcrs.pur_catg_pgm_t pcp2
                              WHERE pcp2.pgm_id 	= pcp.pgm_id
                                AND pcp2.pur_catg_cd 	= pcp.pur_catg_cd
                                AND i_request_dt BETWEEN pcp2.eff_dt AND pcp2.end_dt
                                AND pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(pcp2.begin_qtr_dt) AND TRUNC(pcp2.end_qtr_dt));
    END IF;

    -- If FDRL, set to hardcoded value - otherwise, use PGM passed in
    IF pkg_constants.var_pur_catg_cd = 'FDRL' THEN
       pkg_constants.var_pgm_id := 1;
    ELSE
       pkg_constants.var_pgm_id := i_pgm_id;
    END IF;

    -- Get active URA
    --
    -- If no package passed, meaning FDRL, get max
    IF i_ndc_pckg IS NULL THEN

      SELECT max(t.calc_amt)
      INTO o_pur_amt
      FROM hcrs.pur_final_results_t t
      WHERE t.pgm_id = pkg_constants.var_pgm_id
      AND t.ndc_lbl = i_ndc_lbl
      and t.ndc_prod = i_ndc_prod
      --and t.ndc_pckg =
      and t.period_id = i_period_id
      AND i_request_dt BETWEEN t.eff_dt AND t.end_dt;

    ELSE

      SELECT t.calc_amt
      INTO o_pur_amt
      FROM hcrs.pur_final_results_t t
      WHERE t.pgm_id = pkg_constants.var_pgm_id
      AND t.ndc_lbl = i_ndc_lbl
      and t.ndc_prod = i_ndc_prod
      and t.ndc_pckg = i_ndc_pckg
      and t.period_id = i_period_id
      AND i_request_dt BETWEEN t.eff_dt AND t.end_dt;

    END IF;

  ELSE -- not activated...

   -- Initialize
   v_parent_formula_at_lowest_lvl := FALSE;
   v_execute_query_flag := TRUE;
   pkg_constants.var_fatal_flag := FALSE;
   pkg_constants.var_result_eff_dt := SYSDATE;
  g_formula := NULL;
  g_formula_details  := NULL;
  g_formula_values := NULL;
  g_formula_details_values := NULL;
  g_missing_items := NULL;

   -- Register log flag
   pkg_constants.var_log_flag := i_log_flag;

   -- Register inquiry mode
   pkg_constants.var_inquiry_mode := TRUE;

   -- Register active flag
   IF i_active_flag = 'A' THEN -- If being called by Activation 'A' then force to 'Y' to get active data
    pkg_constants.var_active_flag := 'Y';
   ELSE
    pkg_constants.var_active_flag := 'N';
   END IF;

   -- If v_inquiry_only is FALSE, f_get_pur is being called from p_run_calc and the
   -- following values have already been set
   IF  v_inquiry_only THEN

      -- Initialize override flag
      v_override_result_flag := FALSE;

      -- Register process name
      pkg_constants.var_process_name := pkg_constants.cs_pur;

      -- Register labeler
      pkg_constants.var_ndc_lbl := i_ndc_lbl;

      -- Register prod
      pkg_constants.var_ndc_prod := i_ndc_prod;

      -- register package
      IF i_ndc_pckg IS NOT NULL THEN
        -- Register pckg
        pkg_constants.var_ndc_pckg := i_ndc_pckg;

        -- Register level
        pkg_constants.var_pckg_lvl_ind := pkg_constants.cs_flag_yes;

      END IF;

      -- Register Program ID
      pkg_constants.var_pgm_id := i_pgm_id;

      -- Get & Register Program Code
      SELECT p.pgm_cd
      INTO pkg_constants.var_pgm_cd
      FROM hcrs.pgm_t p
      WHERE p.pgm_id = i_pgm_id;

      -- Register period
      pkg_constants.var_period_id := i_period_id;

      -- Register request date
      -- No truncate due to time stamp requirements
      pkg_constants.var_request_dt := i_request_dt;

      -- Get and Register the period dates
      p_register_quarter_dates;

      -- Initialize URA Formula SQL text
      pkg_constants.var_formula_sql_txt := NULL;

      --Get and Register URA CAP Adjustment Formula ID
      SELECT pf.formula_id
      INTO pkg_constants.var_ura_cap_adj_formula_id
      FROM hcrs.pur_formula_t pf
      WHERE pf.formula_descr like 'URA Adjustment @TCAP%';

      --Get and Register URA Adjustment @LastWAC-BP Formula ID
      SELECT pf.formula_id
      INTO pkg_constants.var_ura_adj_lastwac_minus_bp
      FROM hcrs.pur_formula_t pf
      WHERE pf.formula_descr like 'URA Adjustment @LastWAC-BP%';

      --Get and Register URA Adjustment @FirstWAC-BP Formula ID
      SELECT pf.formula_id
      INTO pkg_constants.var_ura_adj_firstwac_minus_bp
      FROM hcrs.pur_formula_t pf
      WHERE pf.formula_descr like 'URA Adjustment @FirstWAC-BP%';

      -- Get and register the PUR category code
      SELECT   pcp.pur_catg_cd
      INTO     pkg_constants.var_pur_catg_cd
      FROM              hcrs.pur_catg_pgm_t pcp
      WHERE             pcp.pgm_id = pkg_constants.var_pgm_id
      AND      pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(pcp.begin_qtr_dt) AND TRUNC(pcp.end_qtr_dt)
      AND      pcp.eff_dt = (SELECT MAX(pcp2.eff_dt)
                             FROM    hcrs.pur_catg_pgm_t pcp2
                             WHERE      pcp2.pgm_id = pkg_constants.var_pgm_id
                             AND     pcp2.pur_catg_cd = pcp.pur_catg_cd
                             AND     pkg_constants.var_request_dt BETWEEN  pcp2.eff_dt AND pcp2.end_dt
                             AND     pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(pcp2.begin_qtr_dt) AND TRUNC(pcp2.end_qtr_dt));

      -- check for null
      IF pkg_constants.var_pur_catg_cd IS NULL THEN

         -- raise error
         pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_pur',
                                                 i_module_descr => 'This function will return the PUR value for the specified criteria.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant get the PUR category code for pgm_id:'||pkg_constants.var_pgm_id||' begin_qtr_dt:'||pkg_constants.var_begin_qtr_dt||' request_dt:'||pkg_constants.var_request_dt);

         -- Raise error
         RAISE NO_DATA_FOUND;

      END IF;

/*      --debugging
      pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.f_get_pur',
                                                       i_module_descr => 'f_get_pur',
                                                       i_cmt_txt => 'pkg_constants.var_pur_catg_cd: '||pkg_constants.var_pur_catg_cd);
*/

      -- Get and register parent formuala id
      -- NOTE: this will also set v_override_level
      pkg_constants.var_parent_formula_id := f_get_formula_id;

      IF pkg_constants.var_parent_formula_id IS NULL THEN

         -- Raise error
         RAISE NO_DATA_FOUND;

      END IF;

   END IF; -- If v_inquiry_only

   -- Calculate
   v_value := f_calculate;

   -- If the value is null OR override
   IF v_value IS NULL
   OR v_override_result_flag THEN

      -- Set output value to null
      o_pur_amt := NULL;

      -- Could have raised no_data_found or returned 1403 to ensure 1403 for COBOL programs
      -- But this was not defined at requirements definition.

   ELSE

      -- Perform SQL function on value
      v_value := pkg_pur_common_functions.f_perform_sql_func(i_formula_id => pkg_constants.var_parent_formula_id,
                                                             i_calc_step => pkg_constants.cs_calc_step_final,
                                                             i_value => v_value);
      -- If value is negative
      IF v_value < 0 THEN

            -- Raise calculation exception
            pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.f_get_pur',
                                                             i_module_descr => 'This function will return the PUR value for the specified criteria.',
                                                             i_cmt_txt => 'Returned PUR: '||v_value||' is negative - Substituting with zero.');

            -- Set output value to zero
            o_pur_amt := 0;

      ELSE
         -- Set output value to value calculated
         o_pur_amt := v_value; -- this is done to preserve (11,6) precision

      END IF;


   END IF;

  END IF;

   -- Return zero
   RETURN 0;

EXCEPTION
WHEN NO_DATA_FOUND THEN

       -- nullfiy amount
       o_pur_amt := NULL;

       -- return code
       RETURN 1403;

WHEN OTHERS THEN

       -- nullfiy amount
       o_pur_amt := NULL;

       -- return code
       RETURN SQLCODE;

END f_get_pur;

/****************************************************************************************************
*       Procedure Name : f_get_pur_report
*       Input params   : i_pgm_id - the program ID
*                 : i_ndc_lbl - the product labeler
*                 : i_ndc_prod - the product
*                 : i_period_id - the period ID
*                 : i_request_dt - the request date
*                 : i_active_flag - the price active flag
*                 : i_ndc_pckg - the product package
*       Output params  : none
*  Returns        : Number - the PUR result
*       Date Created   : 09/29/2014
*       Author        : Tom Zimmerman
*       Description    : This function will return the PUR value for the specified criteria.
*
* Modification History
* Date                          Name                                    Comment
* ------------                  ------------------                      --------------------------------------
****************************************************************************************************/
FUNCTION f_get_pur_report(i_pgm_id          IN  hcrs.pur_formula_pgm_prod_assoc_t.pgm_id%TYPE,
                   i_ndc_lbl         IN  hcrs.prod_mstr_t.ndc_lbl%TYPE,
                   i_ndc_prod        IN  hcrs.prod_mstr_t.ndc_prod%TYPE,
                   i_period_id       IN  hcrs.period_t.period_id%TYPE,
                   i_request_dt      IN  DATE,
                   i_active_flag     IN  CHAR,
                   i_ndc_pckg        IN  hcrs.prod_mstr_t.ndc_pckg%TYPE DEFAULT NULL
                   )
RETURN NUMBER
AS
  v_return VARCHAR2(100) := NULL;
  v_pur_amt NUMBER := NULL;
BEGIN

  v_inquiry_only := TRUE;

  v_return := f_get_pur(i_pgm_id      => i_pgm_id,
                   i_ndc_lbl         => i_ndc_lbl,
                   i_ndc_prod        => i_ndc_prod,
                   i_period_id       => i_period_id,
                   i_request_dt      => i_request_dt,
                   i_active_flag     => i_active_flag,
                   i_ndc_pckg        => i_ndc_pckg,
                   o_pur_amt         => v_pur_amt,
                   i_log_flag        => FALSE);

  RETURN v_pur_amt;

EXCEPTION
WHEN OTHERS THEN

       -- return
       RETURN NULL;

END f_get_pur_report;

/**********************************************
*       Procedure Name : f_get_formula_detail
*       Input params   : i_formula_id - the formula ID
*       Output params  : None
*       Returns       : Varchar - the query string to execute
*       Date Created   : 09/26/2014
*       Author        : Tom Zimmerman
*       Description    : This function will return the query string for the specified formula.
* Modification History
* Date                     Name                        Comment
* ------------        ------------------       --------------------------------------
**************************************************/
FUNCTION f_get_formula_detail(i_formula_id NUMBER)
RETURN VARCHAR
AS
  v_value    NUMBER := NULL;
  v_operand_value    NUMBER := NULL;
  v_formula  VARCHAR(32767) := NULL;
  v_sub_formula  VARCHAR(5000) := NULL;
  v_cursor   NUMBER;
  v_return   NUMBER;
  v_skip_operand BOOLEAN := FALSE;
  v_sql_func hcrs.pur_formula_precision_t.sql_func%TYPE := NULL;
  v_prec hcrs.pur_formula_precision_t.val%TYPE := NULL;

BEGIN

     -- Loop and create statement
     FOR v_rec IN (SELECT pc.comp_id,
                          pc.comp_cd,
                          pc.comp_typ_cd,
                          pc.val_typ_cd,
                          pfd.formula_dtl_id,
                          pfd.sub_formula_id,
                          pc.formula_id AS comp_formula_id
                   FROM   hcrs.pur_formula_dtl_t pfd,
                          hcrs.pur_comp_t pc
                   WHERE  pfd.formula_id = i_formula_id
                   AND    pc.comp_id(+) = pfd.comp_id
                   ORDER BY formula_step ASC) LOOP

g_formula := g_formula ||' '|| v_rec.comp_cd;

            --assign value to pkg_constants.var_formula_sql_txt
            IF v_rec.sub_formula_id IN (pkg_constants.var_ura_cap_adj_formula_id,
                                    pkg_constants.var_ura_adj_lastwac_minus_bp,
                                    pkg_constants.var_ura_adj_firstwac_minus_bp) THEN
              pkg_constants.var_formula_sql_txt := 'SELECT ' || v_formula;
              --for debugging
/*              pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.f_build_statement',
                                                       i_module_descr => 'Build pkg_constants.var_formula_sql_txt',
                                                       i_cmt_txt => 'Formula before TCAP:'||pkg_constants.var_formula_sql_txt);*/
            END IF;

         -- Register formula id
         pkg_constants.var_formula_id := i_formula_id;

         -- If SUBFORMULA, recursively call this module whith subformula id
         IF v_rec.sub_formula_id IS NOT NULL THEN

              -- Register formula id
              pkg_constants.var_formula_id := v_rec.sub_formula_id;

              --init
              g_formula := g_formula || '(';

              -- store value
              p_store_value(i_text  => '(',
                            i_value => '(');

               -- get sub_formula
               v_sub_formula := f_get_formula_detail(v_rec.sub_formula_id);

               -- reset
               p_set_g_in_comp_query_func(FALSE);

               -- store value
               p_store_value(i_text  => ')',
                             i_value => ')');

               g_formula := g_formula || ')';

               v_formula := v_formula || '(' || v_sub_formula || ')';


         -- if OPERAND, get value
         ELSIF v_rec.comp_typ_cd = pkg_constants.cs_comp_typ_operand THEN

              IF v_skip_operand THEN
                 v_skip_operand := FALSE; -- reset
              ELSE

                  -- get the value for the operand
                  v_operand_value := f_get_value(i_formula_id,--pkg_constants.var_parent_formula_id,
                                                 v_rec.comp_id,
                                                 v_rec.val_typ_cd,
                                                 v_rec.comp_typ_cd,
                                                 v_rec.comp_cd);

    -- clean
    v_operand_value := f_clean_value(v_operand_value);

                  -- try to perform sql function on value
                  IF v_rec.val_typ_cd = pkg_constants.cs_val_typ_sysval
                  AND v_operand_value IS NOT NULL THEN

                     -- perfrom function
                     v_operand_value := pkg_pur_common_functions.f_perform_sql_func(i_formula_id => i_formula_id,
                                                                                  i_calc_step => 'SYSVAL '||v_rec.comp_cd,
                                                                                  i_value => v_operand_value,
                                                                                  i_raise_exception => pkg_constants.cs_flag_no);


                  END IF;

                  -- put the value into the formula string
                  IF v_operand_value IS NOT NULL THEN
                    v_formula := v_formula ||' '|| v_operand_value;
                  ELSE
                    v_formula := v_formula ||' '|| 'NULL';
                  END IF;

              END IF;

         ELSE -- 'OPERATOR'
               IF v_rec.comp_cd = pkg_constants.cs_comp_code_input_parm THEN -- This is the '@' character
                  v_skip_operand := TRUE; -- set to skip the OPERAND which is next in the cursor
               ELSE
                   v_formula := v_formula ||' '|| v_rec.comp_cd;

                   -- store value
                   p_store_value(i_text  => v_rec.comp_cd,
                                 i_value => v_rec.comp_cd);

               END IF;

         END IF;

     END LOOP;

     -- return formula
     RETURN v_formula;

EXCEPTION
        WHEN OTHERS THEN
       pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_formula_detail',
                                                 i_module_descr => 'This function will return the query string for the specified formula.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant build statement for formula_id:'||i_formula_id  ||' formula:'||v_formula);
       -- Set override flag to true
       --v_override_result_flag := TRUE;

       -- Set fianl test flag to false
       --v_perform_final_tests_flag := FALSE;

       -- Return null
       RETURN NULL;

END f_get_formula_detail;

/**********************************************
*       Procedure Name : f_get_calc_detail
*       Input params   :--input
                        i_ndc_lbl        - The labeler
                        i_ndc_prod       - The product
                        i_ndc_pckg       - The package
                        i_period_id      - The period
                        --derived input
                        i_formula_id     - The formula id
                        i_pgm_id         - The program
                        i_pur_catg_cd    - The PUR category
                        i_override_level - The override level
*       Output params  : None
*       Date Created   : 09/26/2014
*       Author        : Tom Zimmerman
*       Description    : This function will return the calculated PUR details for the specified request.
*
* Modification History
* Date                                          Name                                                            Comment
* ------------                  ------------------                      --------------------------------------
****************************************************************************************************/
FUNCTION f_get_calc_detail( --input
                            i_ndc_lbl        IN hcrs.prod_mstr_t.ndc_lbl%TYPE,
                            i_ndc_prod       IN hcrs.prod_mstr_t.ndc_prod%TYPE,
                            i_ndc_pckg       IN hcrs.prod_mstr_t.ndc_pckg%TYPE,
                            i_period_id      IN hcrs.period_t.period_id%TYPE,
                            --derived input
                            i_formula_id     IN hcrs.pur_formula_t.formula_id%TYPE,
                            i_pgm_id         IN hcrs.pgm_t.pgm_id%TYPE,
                            i_pur_catg_cd    IN hcrs.pur_catg_formula_t.pur_catg_cd%TYPE,
                            i_override_level IN VARCHAR2
                           )
RETURN VARCHAR2
AS
  v_value NUMBER := NULL;
  v_o_pur_amt NUMBER := NULL;
  v_prod_rec t_prod_rec;
  v_return NUMBER := NULL;
  v_temp_pgm_id hcrs.pgm_t.pgm_id%TYPE := NULL;
  v_temp_execute_query_flag BOOLEAN := TRUE;
  v_formula  VARCHAR(32767) := NULL;
  v_result NUMBER := NULL;

BEGIN

  --init
  v_override_result_flag          := FALSE;
  v_perform_final_tests_flag      := TRUE;
  v_parent_formula_at_lowest_lvl  := FALSE;
  v_execute_query_flag            := TRUE;
  g_formula  := '|';
  g_formula_details  := '|';
  g_formula_values  := '|';
  g_formula_details_values  := '|';
  g_missing_items  := '|';


  pkg_constants.var_process_name := pkg_constants.cs_pur;
  pkg_constants.var_inquiry_mode := TRUE;


  -- Register process name
  pkg_constants.var_process_name := pkg_constants.cs_pur;

  -- Register labeler
  pkg_constants.var_ndc_lbl := i_ndc_lbl;

  -- Register product
  pkg_constants.var_ndc_prod := i_ndc_prod;

  -- Register Period ID
  pkg_constants.var_period_id := i_period_id;

  -- Register active flag
  pkg_constants.var_active_flag := pkg_constants.cs_flag_no;
  --pkg_constants.var_active_flag := i_activ_ready;

  -- Register result effective date
  pkg_constants.var_result_eff_dt := SYSDATE;

  -- Set flag
  v_inquiry_only := TRUE;

  -- Register request date
  pkg_constants.var_request_dt := SYSDATE;

  -- Get and Register the quarter dates
  p_register_quarter_dates;

  --Get and Register URA CAP Adjustment Formula ID
  SELECT pf.formula_id
  INTO pkg_constants.var_ura_cap_adj_formula_id
  FROM hcrs.pur_formula_t pf
  WHERE pf.formula_descr like 'URA Adjustment @TCAP%';

  --Get and Register URA Adjustment @LastWAC-BP Formula ID
   SELECT pf.formula_id
   INTO pkg_constants.var_ura_adj_lastwac_minus_bp
   FROM hcrs.pur_formula_t pf
   WHERE pf.formula_descr like 'URA Adjustment @LastWAC-BP%';

  --Get and Register URA Adjustment @FirstWAC-BP Formula ID
   SELECT pf.formula_id
   INTO pkg_constants.var_ura_adj_firstwac_minus_bp
   FROM hcrs.pur_formula_t pf
   WHERE pf.formula_descr like 'URA Adjustment @FirstWAC-BP%';

  -- Initialize
  v_override_result_flag := FALSE;
  v_perform_final_tests_flag := TRUE;
  v_parent_formula_at_lowest_lvl := FALSE;
  v_execute_query_flag := TRUE;
  pkg_constants.var_fatal_flag := FALSE;

  -- Register parent formula
  pkg_constants.var_parent_formula_id := i_formula_id;

  -- Register the lookup level
  pkg_constants.var_override_level := i_override_level;

  -- Register program id -- cant use null due to runtimme error
  IF i_pgm_id = -1 THEN
    pkg_constants.var_pgm_id := NULL;
  ELSE
    pkg_constants.var_pgm_id := i_pgm_id;
  END IF;

  -- Get & Register Program Code
  IF pkg_constants.var_override_level = 'PCKG'
   AND pkg_constants.var_pgm_id IS NOT NULL THEN
     SELECT p.pgm_cd
     INTO pkg_constants.var_pgm_cd
     FROM hcrs.pgm_t p
     WHERE p.pgm_id = pkg_constants.var_pgm_id;
  ELSE
     pkg_constants.var_pgm_cd := NULL;
  END IF;

  -- Register PUR category
  pkg_constants.var_pur_catg_cd := i_pur_catg_cd;

  -- Register pckg
  pkg_constants.var_ndc_pckg := i_ndc_pckg;--v_prod_rec.ndc_pckg;

  -- Initialize URA Formula SQL text
  pkg_constants.var_formula_sql_txt := NULL;

  -- Build statement
  v_formula := v_formula || f_get_formula_detail(pkg_constants.var_parent_formula_id);

  -- Calculate
  v_result := f_clean_value(f_calc_value(g_formula_values));

  --concat VALUES into v_formula
  RETURN g_formula_details||g_formula_values||g_formula_details_values||g_missing_items||'|'||v_result||g_formula;


EXCEPTION

        WHEN OTHERS THEN
       pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_calc_detail',
                                                 i_module_descr => 'This function will return the calculated PUR value for the specified request.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant run calculation');
    --RETURN v_formula;
    RETURN g_formula_details||g_formula_values||g_formula_details_values||g_missing_items;

END f_get_calc_detail;

/**********************************************
*       Procedure Name : f_get_pur_comp
*       Input params   : i_pgm_id - the program ID
*                 : i_ndc_lbl - the product labeler
*                 : i_ndc_prod - the product
*                 : i_period_id - the period ID
*                 : i_request_dt - the request date
*                 : i_active_flag - the price active flag
*                 : i_ndc_pckg - the product package
*       Output params  : none
*  Returns        : Number - the PUR result
*       Date Created   : 06/01/2002
*       Author        : Tom Zimmerman
*       Description    : This function will return the PUR value for the specified criteria.
*
* Modification History
* Date                                          Name                                                            Comment
* ------------                  ------------------                      --------------------------------------
* 12/23/2002         T. Zimmerman               Changed EXCEPTION to ERROR module call
*                                               Added v_inquiry_onlf flag check and moved variable registration
* 01/08/2003         T. Zimmerman               Moved raise error message for pur catg cd
*                                               Added IF pkg_constants.var_parent_formula_id IS NULL THEN
* 01/20/2003         T. Zimmerman               Added registered flag
* 01/21/2003         T. Zimmerman              Added Initialize override flag
* 01/22/2003         T. Zimmerman              Removed TRUNC of eff and end dates
* 04/09/2010         A. Gamer                   Register URA CAP Adjustment Formula ID, URA Formula SQL text
* 08/05/2010         A. Gamer                   CRQ48778 - var_ura_adj_lastwac_minus_bp for Delaware DHCP
* 03/19/2013         A. Gamer                   CRQ38024 - URA Calc Line Extension PPACA (added var_pgm_cd)
* 06/10/2013         A. Gamer                   CRQ51343 - added var_ura_adj_firstwac_minus_bp (DHCP)
****************************************************************************************************/
FUNCTION f_get_pur_comp(i_pgm_id          IN  hcrs.pur_formula_pgm_prod_assoc_t.pgm_id%TYPE,
                   i_ndc_lbl         IN  hcrs.prod_mstr_t.ndc_lbl%TYPE,
                   i_ndc_prod        IN  hcrs.prod_mstr_t.ndc_prod%TYPE,
                   i_period_id       IN  hcrs.period_t.period_id%TYPE,
                   i_request_dt      IN  DATE,
                   i_active_flag     IN  CHAR,
                   i_ndc_pckg        IN  hcrs.prod_mstr_t.ndc_pckg%TYPE DEFAULT NULL,
                   o_pur_amt         OUT NUMBER,
                   i_log_flag        IN  BOOLEAN DEFAULT TRUE)
RETURN NUMBER
AS
  v_value NUMBER := NULL;
  v_sql_func hcrs.pur_formula_precision_t.sql_func%TYPE := NULL;
  v_prec hcrs.pur_formula_precision_t.val%TYPE := NULL;
  e_cant_find_pur_catg EXCEPTION;
BEGIN

   -- Initialize
   v_parent_formula_at_lowest_lvl := FALSE;
   v_execute_query_flag := TRUE;
   pkg_constants.var_fatal_flag := FALSE;
   pkg_constants.var_result_eff_dt := SYSDATE;
  g_formula := NULL;
  g_formula_details  := NULL;
  g_formula_values := NULL;
  g_formula_details_values := NULL;
  g_missing_items := NULL;

   -- Register log flag
   pkg_constants.var_log_flag := i_log_flag;

   -- Register inquiry mode
   pkg_constants.var_inquiry_mode := TRUE;

   -- Register active flag
   pkg_constants.var_active_flag := i_active_flag;
   -- If v_inquiry_only is FALSE, f_get_pur is being called from p_run_calc and the
   -- following values have already been set
   IF  v_inquiry_only THEN

      -- Initialize override flag
      v_override_result_flag := FALSE;

      -- Register process name
      pkg_constants.var_process_name := pkg_constants.cs_pur;

      -- Register labeler
      pkg_constants.var_ndc_lbl := i_ndc_lbl;

      -- Register prod
      pkg_constants.var_ndc_prod := i_ndc_prod;

      -- register package
      IF i_ndc_pckg IS NOT NULL THEN
        -- Register pckg
        pkg_constants.var_ndc_pckg := i_ndc_pckg;

        -- Register level
        pkg_constants.var_pckg_lvl_ind := pkg_constants.cs_flag_yes;

      END IF;

      -- Register Program ID
      pkg_constants.var_pgm_id := i_pgm_id;

      -- Get & Register Program Code
      SELECT p.pgm_cd
      INTO pkg_constants.var_pgm_cd
      FROM hcrs.pgm_t p
      WHERE p.pgm_id = i_pgm_id;

      -- Register period
      pkg_constants.var_period_id := i_period_id;

      -- Register request date
      -- No truncate due to time stamp requirements
      pkg_constants.var_request_dt := i_request_dt;

      -- Get and Register the period dates
      p_register_quarter_dates;

      -- Initialize URA Formula SQL text
      pkg_constants.var_formula_sql_txt := NULL;

      --Get and Register URA CAP Adjustment Formula ID
      SELECT pf.formula_id
      INTO pkg_constants.var_ura_cap_adj_formula_id
      FROM hcrs.pur_formula_t pf
      WHERE pf.formula_descr like 'URA Adjustment @TCAP%';

      --Get and Register URA Adjustment @LastWAC-BP Formula ID
      SELECT pf.formula_id
      INTO pkg_constants.var_ura_adj_lastwac_minus_bp
      FROM hcrs.pur_formula_t pf
      WHERE pf.formula_descr like 'URA Adjustment @LastWAC-BP%';

      --Get and Register URA Adjustment @FirstWAC-BP Formula ID
      SELECT pf.formula_id
      INTO pkg_constants.var_ura_adj_firstwac_minus_bp
      FROM hcrs.pur_formula_t pf
      WHERE pf.formula_descr like 'URA Adjustment @FirstWAC-BP%';

      -- Get and register the PUR category code
      SELECT   pcp.pur_catg_cd
      INTO     pkg_constants.var_pur_catg_cd
      FROM              hcrs.pur_catg_pgm_t pcp
      WHERE             pcp.pgm_id = pkg_constants.var_pgm_id
      AND      pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(pcp.begin_qtr_dt) AND TRUNC(pcp.end_qtr_dt)
      AND      pcp.eff_dt = (SELECT MAX(pcp2.eff_dt)
                             FROM    hcrs.pur_catg_pgm_t pcp2
                             WHERE      pcp2.pgm_id = pkg_constants.var_pgm_id
                             AND     pcp2.pur_catg_cd = pcp.pur_catg_cd
                             AND     pkg_constants.var_request_dt BETWEEN  pcp2.eff_dt AND pcp2.end_dt
                             AND     pkg_constants.var_begin_qtr_dt BETWEEN TRUNC(pcp2.begin_qtr_dt) AND TRUNC(pcp2.end_qtr_dt));

      -- check for null
      IF pkg_constants.var_pur_catg_cd IS NULL THEN

         -- raise error
         pkg_pur_common_procedures.p_raise_errors( i_module_nam => 'pkg_pur_calc.f_get_pur',
                                                 i_module_descr => 'This function will return the PUR value for the specified criteria.',
                                                 i_error_cd => SQLCODE,
                                                 i_error_msg => SQLERRM,
                                                 i_cmt_txt => 'Cant get the PUR category code for pgm_id:'||pkg_constants.var_pgm_id||' begin_qtr_dt:'||pkg_constants.var_begin_qtr_dt||' request_dt:'||pkg_constants.var_request_dt);

         -- Raise error
         RAISE NO_DATA_FOUND;

      END IF;

/*      --debugging
      pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.f_get_pur',
                                                       i_module_descr => 'f_get_pur',
                                                       i_cmt_txt => 'pkg_constants.var_pur_catg_cd: '||pkg_constants.var_pur_catg_cd);
*/

      -- Get and register parent formuala id
      -- NOTE: this will also set v_override_level
      pkg_constants.var_parent_formula_id := f_get_formula_id;

      IF pkg_constants.var_parent_formula_id IS NULL THEN

         -- Raise error
         RAISE NO_DATA_FOUND;

      END IF;

   END IF; -- If v_inquiry_only

   -- Calculate
   v_value := f_calculate;

   -- If the value is null OR override
   IF v_value IS NULL
   OR v_override_result_flag THEN

      -- Set output value to null
      o_pur_amt := NULL;

      -- Could have raised no_data_found or returned 1403 to ensure 1403 for COBOL programs
      -- But this was not defined at requirements definition.

   ELSE

      -- Perform SQL function on value
      v_value := pkg_pur_common_functions.f_perform_sql_func(i_formula_id => pkg_constants.var_parent_formula_id,
                                                             i_calc_step => pkg_constants.cs_calc_step_final,
                                                             i_value => v_value);

      -- If value is negative
      IF v_value < 0 THEN

            -- Raise calculation exception
            pkg_pur_common_procedures.p_raise_calc_exception(i_module_nam => 'pkg_pur_calc.f_get_pur',
                                                             i_module_descr => 'This function will return the PUR value for the specified criteria.',
                                                             i_cmt_txt => 'Returned PUR: '||v_value||' is negative - Substituting with zero.');

            -- Set output value to zero
            o_pur_amt := 0;

      ELSE
         -- Set output value to value calculated
         o_pur_amt := v_value; -- this is done to preserve (11,6) precision

      END IF;


   END IF;

   -- Return zero
   RETURN 0;

EXCEPTION
WHEN NO_DATA_FOUND THEN

       -- nullfiy amount
       o_pur_amt := NULL;

       -- return code
       RETURN 1403;

WHEN OTHERS THEN

       -- nullfiy amount
       o_pur_amt := NULL;

       -- return code
       RETURN SQLCODE;

END f_get_pur_comp;


/****************************************************************************************************
*       Procedure Name : f_get_pur_report_comp
*       Input params   : i_pgm_id - the program ID
*                 : i_ndc_lbl - the product labeler
*                 : i_ndc_prod - the product
*                 : i_period_id - the period ID
*                 : i_request_dt - the request date
*                 : i_active_flag - the price active flag
*                 : i_ndc_pckg - the product package
*       Output params  : none
*  Returns        : Number - the PUR result
*       Date Created   : 09/29/2014
*       Author        : Tom Zimmerman
*       Description    : This function will return the PUR value for the specified criteria.
*
* Modification History
* Date                          Name                                    Comment
* ------------                  ------------------                      --------------------------------------
****************************************************************************************************/
FUNCTION f_get_pur_report_comp(i_pgm_id          IN  hcrs.pur_formula_pgm_prod_assoc_t.pgm_id%TYPE,
                   i_ndc_lbl         IN  hcrs.prod_mstr_t.ndc_lbl%TYPE,
                   i_ndc_prod        IN  hcrs.prod_mstr_t.ndc_prod%TYPE,
                   i_period_id       IN  hcrs.period_t.period_id%TYPE,
                   i_request_dt      IN  DATE,
                   i_active_flag     IN  CHAR,
                   i_ndc_pckg        IN  hcrs.prod_mstr_t.ndc_pckg%TYPE DEFAULT NULL
                   )
RETURN NUMBER
AS
  v_return VARCHAR2(100) := NULL;
  v_pur_amt NUMBER := NULL;
BEGIN

  v_inquiry_only := TRUE;

  v_return := f_get_pur_comp(i_pgm_id      => i_pgm_id,
                   i_ndc_lbl         => i_ndc_lbl,
                   i_ndc_prod        => i_ndc_prod,
                   i_period_id       => i_period_id,
                   i_request_dt      => i_request_dt,
                   i_active_flag     => i_active_flag,
                   i_ndc_pckg        => i_ndc_pckg,
                   o_pur_amt         => v_pur_amt,
                   i_log_flag        => FALSE);

  RETURN v_pur_amt;

EXCEPTION
WHEN OTHERS THEN

       -- return
       RETURN NULL;

END f_get_pur_report_comp;

END pkg_pur_calc;
/
