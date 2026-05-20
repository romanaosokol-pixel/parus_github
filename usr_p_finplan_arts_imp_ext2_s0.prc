create or replace procedure usr_p_finplan_arts_imp_ext2_s0 is

begin
  delete USR_T_FINPLAN_ARTS_IMP_EXT2 t
   where  t.sauthid = utilizer;
end;
/
