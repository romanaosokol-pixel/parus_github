create or replace procedure usr_p_matres_resp_join(ncompany        in number
                                                  ,smodif_code     in nommodif.modif_code%type
                                                  ,scatalog        in acatalog.name%type
                                                  ,sresponsib_type in extra_dicts_values.str_value%type /*Код Типа ответсвенного */
                                                  ,sresponsib_agn  in agnlist.agnabbr%type /*Код ответсвенного кон*/
                                                  ,nmr_rn          out number
                                                  ,ncrn            out number
                                                  ,nresponsib_type out extra_dicts_values.rn%type /*rn Кода Типа ответсвенного */
                                                  ,nresponsib_agn  out agnlist.rn%type) is

begin

  begin
    select mr.rn
      into nmr_rn
      from fcmatresource mr
      join dicnomns d
        on d.rn = mr.nomenclature
      join nommodif nm
        on nm.prn = mr.nomenclature
       and d.rn = nm.prn
     where nm.modif_code = smodif_code
       and mr.company = ncompany
       and mr.nomenclature = nm.prn
       and mr.nomen_modif = nm.rn;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Для модификации номенклатуры с кодом %s не найден материальный ресурс'
                 ,smodif_code);
    
  end;

  begin
    select a.rn
      into ncrn
      from acatalog a
     where a.docname = 'USR_MATRES_RESPONSIBLE'
       and a.company = ncompany
       and a.name = scatalog;
  exception
    when no_data_found then
      p_exception(0
                 ,'Каталог с наименованием %s не найден в разделе "Материальные ресурсы. Ответсвенные"'
                 ,scatalog);
    
  end;

  begin
    select dv.rn
      into nresponsib_type
      from extra_dicts_values dv
     where dv.prn = 270555091 /*rn дополнительного словаря "RESPONSIBLE_TYPE" (Вид ответственного)*/
       and dv.str_value = sresponsib_type;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Значение дополнительного словаря "RESPONSIBLE_TYPE" (Вид ответственного) - %s , не найдено.'
                 ,sresponsib_type);
    when too_many_rows then
      p_exception(0
                 ,'Не удалось определить уникальное значение дополнительного словаря "RESPONSIBLE_TYPE" (Вид ответственного) - %s , найдено несколько одинаковых значений.'
                 ,sresponsib_type);
    
  end;

  begin
  
    select ag.rn
      into nresponsib_agn
      from agnlist ag
      join compverlist v
        on v.company = ncompany
       and v.version = ag.version
       and v.unitcode = 'AGNLIST'
     where ag.agnabbr = sresponsib_agn;
     
     exception when no_data_found then P_EXCEPTION(0, 'Контрагент с мнемокодом %s не найден', sresponsib_agn);
  
  end;

end;
/
