create or replace procedure usr_p_matres_num_base_delete(nrn in number) is

begin

  delete usr_tab_matres_numeration where rn = nrn;

end;
/
