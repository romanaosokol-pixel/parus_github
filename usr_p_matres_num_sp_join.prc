create or replace procedure usr_p_matres_num_sp_join
(
  ncompany in number
 ,smatres  in varchar2
 ,smodif   in varchar2
 ,nmatres  out number
 ,nmodif   out number
) is

begin
  begin
    select mr.rn
      into nmatres
      from fcmatresource mr
     where mr.code = smatres
       and mr.company = ncompany;
  exception
    when no_data_found then
      p_exception(0
                 ,'Материальный ресурс с кодом %s  не найден. Выберите корректное значение через словарь.'
                 ,smatres);
  end;

  begin
    select nm.rn into nmodif from nommodif nm where nm.modif_code = smodif;
  exception
    when no_data_found then
      p_exception(0
                 ,'Модификация номенклатуры с кодом %s  не найдена. Выберите корректное значение через словарь.'
                 ,smodif);
  end;

end;
/
