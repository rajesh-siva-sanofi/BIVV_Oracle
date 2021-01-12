BEGIN
  -- Call the procedure
   bivv.PKG_STG_MEDI.p_run_phase3 (a_trunc_flg => 'Y', a_valid_flg => 'Y');
   COMMIT;
END;
/
