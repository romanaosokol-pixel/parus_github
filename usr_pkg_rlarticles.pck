create or replace package USR_PKG_RLARTICLES is
  /*
  Степанов М. 07/12/2023
  Package предназначен для работы с разделом "Изделия". 
  RealizationArticles RA
  */
  --#########################################################################################################

  function RLARTICLES_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN       in number
  ) 
  return RLARTICLES%rowtype;
  --#########################################################################################################

  procedure RLARTICLES_GET_BY_NOMMODIF
  /*
  Заголовок. Поиск RN изделия по коду и RN модификации
  */
  (
   nFLAGSMART   in number
  ,sCODE        in varchar2
  ,nNOMMODIF    in number
  ,nRN          out number
  );
  --#########################################################################################################

  function RLARTICLES_GET_SHORT_NUMB
  /*
  Заголовок. Получение порядкового номера изделия (исключая мнемокод номенклатуры)
  */
  (
   sNUMB      in varchar2
  ) 
  return varchar2;
  --#########################################################################################################

  procedure RLARTICLES_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure RLARTICLES_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure RLARTICLES_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure RLARTICLES_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure RLARTICLES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_RLARTICLES;
/
create or replace package body USR_PKG_RLARTICLES is

  --#########################################################################################################

  function RLARTICLES_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN      in number
  ) 
  return rlarticles%rowtype
  is
    rRow rlarticles%rowtype;
  begin
    begin
      select T.*
        into rRow
        from rlarticles t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'RLARTICLES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'RLARTICLES')));
    end;
    return(rRow);
  end RLARTICLES_GET;
  --#########################################################################################################

  procedure RLARTICLES_GET_BY_NOMMODIF
  /*
  Заголовок. Поиск RN изделия по коду и RN модификации
  */
  (
   nFLAGSMART   in number
  ,sCODE        in varchar2
  ,nNOMMODIF    in number
  ,nRN          out number
  ) 
  is
  begin
    begin
      select rn
        into nRN
        from rlarticles
       where code      = sCODE
         and nommodif  = nNOMMODIF;
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Не найдено изделие с кодом <%s> и RN модификацией <%s>.', sCODE, nNOMMODIF);
      when too_many_rows then
        p_exception(nFLAGSMART, 'Найдено больше одного изделия с кодом <%s> и RN модификации <%s> в разделе <%s>.', sCODE, nNOMMODIF);
      when others then
        p_exception(0, 'Неопределённая ситуация при изделия с кодом <%s> и RN модификации <%s> в разделе <%s>. %s', sCODE, nNOMMODIF, cr||sqlerrm);
    end;
    
  end RLARTICLES_GET_BY_NOMMODIF;
  --#########################################################################################################

  function RLARTICLES_GET_SHORT_NUMB
  /*
  Заголовок. Получение порядкового номера изделия (исключая мнемокод номенклатуры)
  */
  (
   sNUMB      in varchar2
  ) 
  return varchar2
  is
  begin
    return(trim(lpad(substr(sNUMB, instr(sNUMB, '_')+1), 20, ' ')));
  end RLARTICLES_GET_SHORT_NUMB;
  --#########################################################################################################

  procedure RLARTICLES_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Считывание*/
    /*rRow := RLARTICLES_GET(nrn => nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    rlarticles_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end RLARTICLES_AINSERT;
  --#########################################################################################################

  procedure RLARTICLES_BUPDATE
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
  end RLARTICLES_BUPDATE;
  --#########################################################################################################

  procedure RLARTICLES_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Считывание*/
    /*rRow := rlarticles_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    rlarticles_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end RLARTICLES_AUPDATE;
  --#########################################################################################################

  procedure RLARTICLES_BDELETE
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
  end RLARTICLES_BDELETE;
  --#########################################################################################################

  procedure RLARTICLES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* Заголовок */  
    /*rRow := rlarticles_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    /* Проверка наименования без пробелов */
    
  end RLARTICLES_CHECK_BASE;
  --#########################################################################################################

end USR_PKG_RLARTICLES;
/
