BEGIN
  -- Call the procedure
   hcrs.PKG_LOAD_BIVV_MEDI_DATA.p_run_phase2 (a_clean_flg => 'N');
   COMMIT;
END;
/
