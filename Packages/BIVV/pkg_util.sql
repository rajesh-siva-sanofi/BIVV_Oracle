CREATE OR REPLACE PACKAGE BIVV.pkg_util AS

   PROCEDURE p_saveLog (
      av_logtext in CONV_LOG_T.log_txt%TYPE,
      av_program in CONV_LOG_T.program%TYPE,
      av_module in CONV_LOG_T.module%TYPE DEFAULT NULL);

   PROCEDURE p_trunc_tbl(p_name IN VARCHAR2);

END;
/
CREATE OR REPLACE PACKAGE BODY BIVV.pkg_util AS

   c_program   CONSTANT conv_log_t.program%TYPE := 'BIVV.PKG_UTIL';

PROCEDURE p_saveLog (
  av_logtext in CONV_LOG_T.log_txt%TYPE,
  av_program in CONV_LOG_T.program%TYPE,
  av_module in CONV_LOG_T.module%TYPE DEFAULT NULL) IS

  PRAGMA AUTONOMOUS_TRANSACTION; -- to isolate this procedure from other processing
/*******************************************************************************
  Name:       p_saveLog
  Arguments:
    av_program  - program/package to be associated with log entry
    av_module   - procedure/function to be associated with log entry
    an_runnum   - job run number
    av_logtext  - log text

  Returns:    None
  Notes:      Autonomous procedure to save execution entries into a log table.

  Versions:
  Date         Who         Description
  ----------   ----------  ------------------------------------------------------
  8/18/2020    mg          Initial version
*/

BEGIN

  INSERT INTO conv_log_t (program, module, log_txt)
  VALUES (SUBSTR(av_program,1,100), SUBSTR(av_module,1,100), SUBSTR(av_logtext,1,4000));

  COMMIT;

END;
--
PROCEDURE p_trunc_tbl(p_name IN VARCHAR2) IS
   v_module    conv_log_t.module%TYPE := 'p_trunc_tbl';

   PRAGMA AUTONOMOUS_TRANSACTION; -- to isolate this procedure from other processing
BEGIN
--   p_saveLog('About to delete: '||p_name, c_program, v_module);
--   EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || p_name;
   EXECUTE IMMEDIATE 'DELETE FROM ' || p_name;
   p_saveLog(p_name||' deleted row(s): '||SQL%ROWCOUNT, c_program, v_module);
   COMMIT;
  
EXCEPTION
   WHEN OTHERS THEN
      p_saveLog('Deleting from table '||p_name||'. SQLERRM: '||SQLERRM, 'PKG_UTIL', 'p_trunc_tbl');
      RAISE;
END;

END;
/
