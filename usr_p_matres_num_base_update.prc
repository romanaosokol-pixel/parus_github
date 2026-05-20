create or replace procedure usr_p_matres_num_base_update
(
  nrn   in number
 ,ncrn  in number
 ,snote in varchar2
) is

begin

  update usr_tab_matres_numeration t
     set t.note = snote
        ,t.crn  = ncrn
   where t.rn = nrn;

end;
/
