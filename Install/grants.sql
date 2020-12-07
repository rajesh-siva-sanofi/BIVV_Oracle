DECLARE 
   PROCEDURE grant_select (a_user IN VARCHAR2) IS 
      v_sql    VARCHAR2(4000);
BEGIN   

      FOR cur IN (
         SELECT object_type, object_name 
         FROM all_objects
         WHERE owner = a_user AND object_type IN ('VIEW','TABLE') 
         ORDER BY 1,2
      ) LOOP
   
         BEGIN
            v_sql := 'GRANT SELECT ON '||cur.object_name||' TO BIVV';

            IF cur.object_type = 'VIEW' THEN
               v_sql := v_sql || ' with grant option';
--            dbms_output.put_line (a_user||'-'||cur.object_type||': '||v_sql);   
			END IF;

			EXECUTE IMMEDIATE v_sql;
		 
            v_sql := 'GRANT SELECT ON '||cur.object_name||' TO HCRS_SELECT, HCRS_READ';
			
			EXECUTE IMMEDIATE v_sql;
			
         EXCEPTION 
            WHEN OTHERS THEN
               dbms_output.put_line ('ERROR: '||v_sql||'. SQLERRM: '||SQLERRM);

         END;

      END LOOP;

      IF a_user = 'HCRS' THEN
         -- sequence rights
         EXECUTE IMMEDIATE 'GRANT SELECT ON hcrs.check_s TO BIVV'; 
         EXECUTE IMMEDIATE 'GRANT SELECT ON hcrs.check_apprvl_grp_seq TO BIVV';
         EXECUTE IMMEDIATE 'GRANT EXECUTE ON hcrs.pkg_load_bivv_medi_data TO BIVV';
      END IF;

END;

BEGIN
   dbms_output.put_line ('Granting privs to &1 objects...');
   grant_select ('&1');
END;
/

