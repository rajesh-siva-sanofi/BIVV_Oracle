set define on

DECLARE 
   PROCEDURE grant_select (a_user IN VARCHAR2) IS 
      v_sql    VARCHAR2(4000);
BEGIN   

      FOR cur IN (
         SELECT object_type, object_name 
         FROM all_objects
         WHERE owner = a_user AND object_type IN ('VIEW','TABLE')
		    AND object_name NOT LIKE 'BIVV_RECON%'
         ORDER BY 1,2
      ) LOOP
   
         BEGIN
		 
			IF a_user != 'BIVV' THEN
			
			   v_sql := 'GRANT SELECT ON '||cur.object_name||' TO BIVV with grant option';

               --dbms_output.put_line (a_user||'-'||cur.object_type||': '||v_sql);   

			   EXECUTE IMMEDIATE v_sql;

			END IF;
		 
            v_sql := 'GRANT SELECT ON '||cur.object_name||' TO HCRS_SELECT, HCRS_READ, GPC_SUPP';
			
			EXECUTE IMMEDIATE v_sql;
			
         EXCEPTION 
            WHEN OTHERS THEN
               dbms_output.put_line ('ERROR: '||v_sql||'. SQLERRM: '||SQLERRM);

         END;

      END LOOP;

      IF a_user = 'HCRS' THEN
         -- sequence rights
         EXECUTE IMMEDIATE 'GRANT SELECT ON hcrs.check_s TO BIVV'; 
         EXECUTE IMMEDIATE 'GRANT SELECT ON hcrs.prfl_s TO BIVV'; 
         EXECUTE IMMEDIATE 'GRANT SELECT ON hcrs.check_apprvl_grp_seq TO BIVV';
         EXECUTE IMMEDIATE 'GRANT EXECUTE ON hcrs.pkg_constants TO BIVV';
      END IF;

END;

BEGIN
   dbms_output.put_line ('Granting privs to &1 objects...');
   grant_select ('&1');
END;
/

set define off

