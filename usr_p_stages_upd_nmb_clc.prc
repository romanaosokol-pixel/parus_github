create or replace procedure usr_p_stages_upd_nmb_clc
(
  nrn          in stages.rn%type
 ,nmode        in number
 ,snmb         in out stages.numb%type
 ,snmb_old     out stages.numb%type
 ,snmb_vis     out number
 ,snmb_old_vis out number
 ,smsg         out varchar2
 ,nmsg_color   out number
 ,nok          out number
) is

  nprn contracts.rn%type;

begin

  nok := 1;

  begin
    select st.numb
          ,st.prn
      into snmb_old
          ,nprn
      from stages st
     where st.rn = nrn;
  
    snmb := nvl(snmb, snmb_old);
    -- P_exception(0, '39 '||snmb);
  exception
    when no_data_found then
      p_exception(0
                 ,'Процедура запускается только на этапе договора.');
    
  end;

  if nmode = 1 then
  
    snmb         := snmb_old;
    snmb_vis     := 0;
    snmb_old_vis := 0;
  
  else
  
    snmb_vis     := 1;
    snmb_old_vis := 1;
  
    -- Проверим, что такого номера еще нет
  
    if snmb != snmb_old then
    
      for cur in (select 1
                    from stages st
                   where st.prn = nprn
                     and st.rn != nrn
                     and trim(st.numb) = snmb
                     and rownum = 1)
      
      loop
        smsg       := 'Нельзя изменить номер этапа на ' || snmb ||
                      ', так как этап с таким номером уже существует.';
        nmsg_color := 15; -- Как красный цвет вывести?
        nok        := 0;
      
      end loop;
    
    end if;
  
  end if;

  ---grant execute on usr_p_stages_upd_nmb_clc to public;

end;
/
