create or replace package USR_PKG_USERREPORTS is
  /*
  Степанов М. 01/11/2023
  Для работы с разделом "Контрагенты". 
  UserReports         USERREPORTS         UR
  UserReportParams    USERREPORTS_PARAMS  URP
  UserReportsHistory  USERREPORTSHIST     URH
  */
  --#########################################################################################################

  function USERREPORTS_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN       in number
  ) 
  return USERREPORTS%rowtype;
  /*#########################################################################################################*/

  procedure USERREPORTS_GET_PARAMS_TYPE
  /*
  Процедура считывания коллекции параметров 
  */
  (
   nRN      in number
  ,aARROW   out usr_pkg_pub_const.tuserreports_params
  );
  --#########################################################################################################

  procedure USERREPORTS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTS_BMOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTS_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTS_BMOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTS_AMOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTS_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTS_BPRINT
  /*
  Заголовок. Проверка печать документа. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  );
  --#########################################################################################################

  procedure USERREPORTS_APRINT
  /*
  Заголовок. Проверка печать документа. После
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  );
  --#########################################################################################################

  procedure USERREPORTS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
--#########################################################################################################

  function USERREPORTS_PARAMS_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN       in number
  ) 
  return USERREPORTS_PARAMS %ROWTYPE;
  /*#########################################################################################################*/

  procedure USERREPORTS_PARAMS_GET_VAL_TP
  /*
  Процедура возвращает значение заданного параметра из массива
  */
  (
   sNAME          in  userreports_params.name%type
  ,aARROW         in  usr_pkg_pub_const.tuserreports_params
  ,sVALUE_STR     out userreports_params.default_str%type
  ,nVALUE_NUM     out userreports_params.default_num%type
  ,dVALUE_DATE    out userreports_params.default_date%type
  );
  --#########################################################################################################

  procedure USERREPORTS_PARAMS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTS_PARAMS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTS_PARAMS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTS_PARAMS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTS_PARAMS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  function USERREPORTSHIST_GET
  /*
  История. Считывание
  */
  (
   nRN      in number 
  ) 
  return userreportshist%rowtype;
  --#########################################################################################################

  procedure USERREPORTSHIST_AINSERT
  /*
  История. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTSHIST_BUPDATE
  /*
  История. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTSHIST_AUPDATE
  /*
  История. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTSHIST_BDELETE
  /*
  История. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERREPORTSHIST_CHECK_BASE
  /*
  История. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_USERREPORTS;
/
create or replace package body USR_PKG_USERREPORTS is

  --#########################################################################################################

  function USERREPORTS_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN      in number
  ) 
  return userreports%rowtype
  is
    rRow userreports%rowtype;
  begin
    begin
      select T.*
        into rRow
        from userreports t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERREPORTS'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERREPORTS')));
    end;
    return(rRow);
  end USERREPORTS_GET;
  /*#########################################################################################################*/

  procedure USERREPORTS_GET_PARAMS_TYPE
  /*
  Процедура считывания коллекции параметров 
  */
  (
   nRN      in number
  ,aARROW   out usr_pkg_pub_const.tuserreports_params
  )
  as
    nCount  pkg_std.tnumber := 0; 
  begin
    for c in (select t.rn, t.name, t.prompt, t.data_type
                from userreports_params t
               where t.prn     = nRN
                 and t.linking in (0, 2, 5) )
    loop
      /* добавляем в массив */
      nCount := nCount + 1;
      aARROW(nCount).rn        := c.rn;
      aARROW(nCount).name      := c.name;
      aARROW(nCount).prompt    := c.prompt;
      aARROW(nCount).data_type := c.data_type;
      case c.data_type
        when 0 then 
          pkg_userreports.get_report_param_str(sparam_name  => c.name, sparam_value => aARROW(nCount).value_str);
        when 1 then 
          pkg_userreports.get_report_param_num(sparam_name  => c.name, nparam_value => aARROW(nCount).value_num);
        when 2 then 
          pkg_userreports.get_report_param_num(sparam_name  => c.name, nparam_value => aARROW(nCount).value_num);
        when 3 then 
          pkg_userreports.get_report_param_num(sparam_name  => c.name, nparam_value => aARROW(nCount).value_num);
        when 4 then 
          pkg_userreports.get_report_param_date(sparam_name => c.name, dparam_value => aARROW(nCount).value_date);
      else
        p_exception(0, 'Недопустимое значение <%s> поля DATA_TYPE.', c.data_type); 
      end case;
    end loop;
    
  end USERREPORTS_GET_PARAMS_TYPE;
  --#########################################################################################################

  procedure USERREPORTS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            userreports%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание
     rRow := USERREPORTS_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    userreports_check_base(nrn => nRN, ncompany => nCOMPANY);

  end USERREPORTS_AINSERT;
  --#########################################################################################################

  procedure USERREPORTS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end USERREPORTS_BUPDATE;
  --#########################################################################################################

  procedure USERREPORTS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     userreports%rowtype;
    
  begin
    /* Считывание
     rRow := userreports_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    userreports_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end USERREPORTS_AUPDATE;
  --#########################################################################################################

  procedure USERREPORTS_BMOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end USERREPORTS_BMOVE_IN;
  --#########################################################################################################

  procedure USERREPORTS_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end USERREPORTS_AMOVE_IN;
  --#########################################################################################################

  procedure USERREPORTS_BMOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end USERREPORTS_BMOVE_OUT;
  --#########################################################################################################

  procedure USERREPORTS_AMOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end USERREPORTS_AMOVE_OUT;
  --#########################################################################################################

  procedure USERREPORTS_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end USERREPORTS_BDELETE;
  --#########################################################################################################

  procedure USERREPORTS_BPRINT
  /*
  Заголовок. Проверка печать документа. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  ) 
  is
    rRow              userreports%rowtype;
    aParams           usr_pkg_pub_const.tuserreports_params;
    nDocument         pkg_std.tref; 
    sUnitCode         unitlist.unitcode%type;
    sWriteUpdateList  pkg_std.tstring; 
    sTableName        pkg_std.tstring; 
    sTypeName         pkg_std.tstring; 
    sPrefName         pkg_std.tstring; 
    sNumbName         pkg_std.tstring; 
    sDateName         pkg_std.tstring; 
    sParams           pkg_std.tstring; 
    
    sVarchar          pkg_std.tstring; 
    nNumber           pkg_std.tnumber; 
    dDate             date;
  begin
    /* Если пользователь входит в Группу пользователей Админы, то выходим сразу */
    if usr_pkg_rights.usergrp_user_is_admin( sauthid => utilizer ) = 1 then
      return;
    end if;

    /* Считывание записи отчёта */
    rRow := userreports_get(nrn => NRN);

    /* RN и код раздела отмеченного (текущего) документа */
    usr_pkg_process.get_current_doc_params(ndocument => nDocument, sunitcode => sUnitCode);
    
    /* Если RN и код раздела не заданы */
    if nDocument is null then
      /* используем RN и код раздела отчёта */
      nDocument := rRow.rn; 
      sUnitCode := get_unitlist_code_table(nflag_smart => 0, stable_name => 'USERREPORTS');
    end if;

    /* Считывание параметров отчёта */
    usr_pkg_userreports.userreports_get_params_type(nrn => rRow.rn, aarrow => aParams);


    /* ПРОВЕРКИ */

    /* ЖУРНАЛ РЕГИСТРАЦИИ */
    /* Если НЕ добавлять в журнал регистрации событий, то выходим */
    if cmp_vc2( upper(f_docs_props_get_str_value(nproperty => 115844254, sunitcode => 'UserReports', ndocument => rRow.rn)) /* Доб.Журн.Рег.Соб. */
              ,'ДА' ) = 1 then

      /* Определение таблицы по коду раздела */
      if sUnitCode is not null then
        find_unitlist_table(nflag_smart => 1, sunitcode => sUnitCode, stablename => sTableName);
      end if;

      /* Если массив параметров не пустой */
      if cmp_num(aParams.count, 0) != 1 then
        /* По массиву */
        for i in aParams.first .. aParams.last loop
          /* Формирование текста со значениями параметров отчёта */
          sParams := strcombine( sParams, '- '||aParams(i).prompt||': '||
                                 trim(aParams(i).value_str) || trim(n2si(aParams(i).value_num)) || decode_date(aParams(i).value_date)
                               , cr );
        end loop;
      end if;

      /* Добавление журнала регистрации событий */
      if pkg_iud.prologue(stable_name => sTableName, soper_type => 'U') then
        pkg_iud.reg_rn(scolumn_name => 'RN', nnum_value => nDocument);
        pkg_iud.reg_note(iposition    => 1
                        ,scolumn_name => 'Печать отчёта'
                        ,sstr_value   => rRow.name||' ('||rRow.code||')'||case when sParams is not null 
                                                                            then ' с параметрами:'||cr||sParams||cr
                                                                          end);
        pkg_iud.epilogue;
      end if;

    end if;

  end USERREPORTS_BPRINT;
  --#########################################################################################################

  procedure USERREPORTS_APRINT
  /*
  Заголовок. Проверка печать документа. После
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  ) 
  is
  begin
    null;    
  end USERREPORTS_APRINT;
  --#########################################################################################################

  procedure USERREPORTS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      userreports%rowtype;
  begin
    null;
    
  end USERREPORTS_CHECK_BASE;
  --#########################################################################################################

  function USERREPORTS_PARAMS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number 
  ) 
  return userreports_params%rowtype
  is
    rRow userreports_params%rowtype;
  begin
    begin
      select T.*
        into rRow
        from userreports_params t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERREPORTS_PARAMS'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERREPORTS_PARAMS')));
    end;
    return(rRow);
  end USERREPORTS_PARAMS_GET;
  /*#########################################################################################################*/

  procedure USERREPORTS_PARAMS_GET_VAL_TP
  /*
  Спецификация. Получение значения значение заданного параметра из массива
  */
  (
   sNAME          in  userreports_params.name%type
  ,aARROW         in  usr_pkg_pub_const.tuserreports_params
  ,sVALUE_STR     out userreports_params.default_str%type
  ,nVALUE_NUM     out userreports_params.default_num%type
  ,dVALUE_DATE    out userreports_params.default_date%type
  )
  as
  begin
    /* Если массив не пустой */
    if cmp_num(aARROW.COUNT, 0) != 1 then

      /* По массиву */
      for i in aARROW.FIRST .. aARROW.LAST loop

        /* Если текущий RN в массиве равен параметру */
        if cmp_vc2(aARROW(i).NAME, sNAME) = 1 then
          sVALUE_STR  := aARROW(i).VALUE_STR; 
          nVALUE_NUM  := aARROW(i).VALUE_NUM;
          dVALUE_DATE := aARROW(i).VALUE_DATE;
          exit;
        else
          /* не задан RN в параметре */
          if sNAME is null then
            p_exception(0, 'Не задано наименование параметра.'); 
          end if;
        end if;

      end loop;
    end if;
    
  end USERREPORTS_PARAMS_GET_VAL_TP;
  --#########################################################################################################

  procedure USERREPORTS_PARAMS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    userreports_params_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end USERREPORTS_PARAMS_AINSERT;
  --#########################################################################################################

  procedure USERREPORTS_PARAMS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end USERREPORTS_PARAMS_BUPDATE;
  --#########################################################################################################

  procedure USERREPORTS_PARAMS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    userreports_params_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end USERREPORTS_PARAMS_AUPDATE;
  --#########################################################################################################

  procedure USERREPORTS_PARAMS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end USERREPORTS_PARAMS_BDELETE;
  --#########################################################################################################

  procedure USERREPORTS_PARAMS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     userreports_params%rowtype;
  begin
    null;
   
  end USERREPORTS_PARAMS_CHECK_BASE;
  --#########################################################################################################

  function USERREPORTSHIST_GET
  /*
  История. Считывание
  */
  (
   nRN      in number 
  ) 
  return userreportshist%rowtype
  is
    rRow userreportshist%rowtype;
  begin
    begin
      select T.*
        into rRow
        from userreportshist t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERREPORTSHIST'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERREPORTSHIST')));
    end;
    return(rRow);
  end USERREPORTSHIST_GET;
  --#########################################################################################################

  procedure USERREPORTSHIST_AINSERT
  /*
  История. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    userreportshist_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end USERREPORTSHIST_AINSERT;
  --#########################################################################################################

  procedure USERREPORTSHIST_BUPDATE
  /*
  История. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end USERREPORTSHIST_BUPDATE;
  --#########################################################################################################

  procedure USERREPORTSHIST_AUPDATE
  /*
  История. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    userreportshist_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end USERREPORTSHIST_AUPDATE;
  --#########################################################################################################

  procedure USERREPORTSHIST_BDELETE
  /*
  История. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end USERREPORTSHIST_BDELETE;
  --#########################################################################################################

  procedure USERREPORTSHIST_CHECK_BASE
  /*
  История. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     userreportshist%rowtype;
  begin
    null;
   
  end USERREPORTSHIST_CHECK_BASE;
  --#########################################################################################################


end USR_PKG_USERREPORTS;
/
