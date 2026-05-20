create or replace procedure usr_p_stages_upd_nmb_ini
(
  nrn          in stages.rn%type
 ,nmode        in number
 ,out_sign_sum out number
 ,snmb         out stages.numb%type
 ,snmb_old     out stages.numb%type
 ,snmb_vis     out number
 ,snmb_old_vis out number
 ,smsg         out varchar2
 ,nok          out number
) is
begin

  smsg := null;
  if nmode = 1
  then
  
    snmb_old     := null;
    snmb_vis     := 0;
    snmb_old_vis := 0;
    nok          := 1;
  
  else
  
    snmb_vis     := 1;
    snmb_old_vis := 1;
  
    begin
      select st.numb
            ,st.sign_sum
        into snmb_old
            ,out_sign_sum
        from stages st
       where st.rn = nrn;
    
      snmb := snmb_old;
    
    exception
      when no_data_found then
        p_exception(0, 'Процедура запускается только на этапе договора.');
      
    end;
  
    nok := 1;
  end if;

end;
/
