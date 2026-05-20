create or replace procedure usr_p_matres_resp_ins_clc(ncompany        in number
                                                     ,smodif_code     in varchar2
                                                     ,sresponsib_type in extra_dicts_values.str_value%type /*Код Типа ответсвенного */
                                                     ,ddate_beg       in date
                                                     ,ddate_end       in date
                                                     ,err_txt         out varchar2 
                                                     ,is_ok out number) is

  ---rec usr_tab_matres_response%rowtype; --Куда пишем

begin

  usr_p_matres_resp_ins_chk(ncompany        => ncompany
                           ,smodif_code     => smodif_code
                           ,sresponsib_type => sresponsib_type
                           ,ddate_beg       => ddate_beg
                           ,ddate_end       => ddate_end
                           ,err_txt         => err_txt);

  if err_txt is not null
  then
    is_ok := 0;
  else
    is_ok := 1;
  end if;

end;
/
