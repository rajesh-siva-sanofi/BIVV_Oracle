CREATE OR REPLACE TRIGGER hcrs.prfl_sls_excl_rbiu_tr
   BEFORE INSERT OR UPDATE ON hcrs.prfl_sls_excl_t
   FOR EACH ROW
DECLARE
   /****************************************************************************
   * Trigger Name : prfl_sls_excl_rbiu_tr
   * Date Created : unknown
   *       Author : unknown
   *  Description : Create/Mod trigger on prfl_sls_excl_t
   *
   * MOD HISTORY
   *  Date        Modified by   Reason
   *  ----------  ------------  ------------------------------------------------
   *  08/22/2008  Joe Kidd      PICC 1961: Use pkg_constants user constant
   *                            Rename from prfl_sls_excl_t_rbiu_t
   ****************************************************************************/
BEGIN
   IF INSERTING
   THEN
      :NEW.create_dt := SYSDATE;
      :NEW.mod_dt := NULL; -- enforce null mod_dt on insert
      :NEW.mod_by := pkg_constants.cs_user;
   ELSIF UPDATING
   THEN
      :NEW.create_dt := :OLD.create_dt; -- prevent changes on update
      :NEW.mod_dt := SYSDATE;
      :NEW.mod_by := pkg_constants.cs_user;
   END IF;
END prfl_sls_excl_rbiu_tr;
/
