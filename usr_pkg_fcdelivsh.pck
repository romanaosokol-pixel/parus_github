create or replace package USR_PKG_FCDELIVSH is
  /*
  Package предназначен для работы с разделом "Комплектовочные ведомости".
  CostDeliverySheets                FCDELIVSH         FDV 
  CostDeliverySheetsSpec            FCDELIVSHSP       FDVS
  CostDeliverySheetsSpecCompletion  FCDELIVSHSPCMPL   FDVSC
  */
  --#########################################################################################################

  function FCDELIVSH_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN       in number
  ) 
  return FCDELIVSH%ROWTYPE;
  --#########################################################################################################

  procedure FCDELIVSH_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSH_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSH_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSH_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSH_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSH_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSH_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  function FCDELIVSHSP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN       in number
  ) 
  return FCDELIVSHSP%ROWTYPE;
  --#########################################################################################################

  procedure FCDELIVSHSP_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSHSP_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSHSP_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSHSP_ACOMPLETE
  /*
  Спецификация. Комплектование строки комплектовочной ведомости. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSHSP_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSHSP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################
  
  function FCDELIVSHSPCMPL_GET
  /*
  Комплектование. Считывание записи
  */
  (
   nRN      in number -- RN записи
  ) 
  return fcdelivshspcmpl%rowtype;
  --#########################################################################################################

  procedure FCDELIVSHSPCMPL_AINSERT
  /*
  Комплектование. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSHSPCMPL_BUPDATE
  /*
  Комплектование. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSHSPCMPL_AUPDATE
  /*
  Комплектование. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSHSPCMPL_BDELETE
  /*
  Комплектование. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCDELIVSHSPCMPL_CHECK_BASE
  /*
  Комплектование. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_FCDELIVSH;
/
create or replace package body USR_PKG_FCDELIVSH is

  --#########################################################################################################

  function FCDELIVSH_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN      in number -- RN записи
  ) 
  return FCDELIVSH%ROWTYPE
  is
    rRow FCDELIVSH%ROWTYPE;
  begin
    begin
      select T.*
        into rRow
        from FCDELIVSH T
        where T.RN = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'FCDELIVSH');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(nRN), 'Не задан')||'> '||
        'в разделе <'||f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCDELIVSH'))||'>.');
    end;
    return(rRow);
  end FCDELIVSH_GET;
  --#########################################################################################################

  procedure FCDELIVSH_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            fcdelivsh%rowtype;
  begin
    null;
    /* Заголовок  */
    /*rRow      := fcdelivsh_get(nRN);*/
  end FCDELIVSH_AINSERT;
  --#########################################################################################################

  procedure FCDELIVSH_BUPDATE
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
    /* Считывание  */
    /*usr_pkg_pub_const.rfcdelivsh := FCDELIVSH_GET(nRN); 
    sAcatalog := GET_ACATALOG_NAME_ID(0, usr_pkg_pub_const.rfcdelivsh.crn);*/
    
    /* ПРОВЕРКИ */

  end FCDELIVSH_BUPDATE;
  --#########################################################################################################

  procedure FCDELIVSH_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
    rRow            fcdelivsh%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow := fcdelivsh_get(nRN);*/

    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    /*fcdelivsh_check_base(nrn => rRow.rn, ncompany => rRow.company);*/
    
  end FCDELIVSH_AUPDATE;
  --#########################################################################################################

  procedure FCDELIVSH_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              fcdelivsh%rowtype;
  begin
    /* Заголовок */
    rRow := FCDELIVSH_GET(nRN);

    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */

  end FCDELIVSH_BDELETE;
  --#########################################################################################################

  procedure FCDELIVSH_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCDELIVSH_BMOVE_IN;
  --#########################################################################################################

  procedure FCDELIVSH_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    null;
  end FCDELIVSH_BMOVE_OUT;
  --#########################################################################################################

  procedure FCDELIVSH_CHECK_BASE
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
  end FCDELIVSH_CHECK_BASE;
  --#########################################################################################################

  function FCDELIVSHSP_GET
  /*
  Спецификация. Считывание записи
  */
  (
   nRN      in number -- RN записи
  ) 
  return FCDELIVSHSP%ROWTYPE
  is
    rRow FCDELIVSHSP%ROWTYPE;
  begin
    begin
      select T.*
        into rRow
        from FCDELIVSHSP T
        where T.RN = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'FCDELIVSHSP');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(nRN), 'Не задан')||'> '||
        'в разделе <'||f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCDELIVSHSP'))||'>.');
    end;
    return(rRow);
  end FCDELIVSHSP_GET;
  --#########################################################################################################

  procedure FCDELIVSHSP_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* Проверка базовая */
    /*fcdelivshsp_check_base(nrn => nRN, ncompany => nCOMPANY);*/
  end FCDELIVSHSP_AINSERT;
  
  --#########################################################################################################

  procedure FCDELIVSHSP_BUPDATE
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
  end FCDELIVSHSP_BUPDATE;
  --#########################################################################################################

  procedure FCDELIVSHSP_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* Проверка базовая */
    /*fcdelivshsp_check_base(nrn => nRN, ncompany => nCOMPANY);*/
  end FCDELIVSHSP_AUPDATE;
  --#########################################################################################################

  procedure FCDELIVSHSP_ACOMPLETE
  /*
  Спецификация. Комплектование строки комплектовочной ведомости. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            fcdelivshsp%rowtype;
    rFcMatResource  fcmatresource%rowtype;
    rDicNomns       dicnomns%rowtype;
    
    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание */
    rRow            := fcdelivshsp_get(nRN);
    rFcMatResource  := usr_pkg_fcmatresource.fcmatresource_get(nrn => rRow.matres, nflagsmart => 0);
    rDicNomns       := usr_pkg_DicNomns.dicnomns_get(nrn => rFcMatResource.nomenclature);
    
    /* Проверки */
    /* Базовая */
    fcdelivshsp_check_base(nrn => nRN, ncompany => nCOMPANY);    

    /* Дробное количество для группы ЭРИ */
    if rDicNomns.group_code = 13884309
    and rRow.quant_plan != trunc(rRow.quant_plan) then
      select group_code into sVarchar from dicgnomn where rn = rDicNomns.group_code;
      p_exception(0, 'Дробное количество в спецификации <%s> у номенклатуры с группой <%s>. %s%s'
                 ,rRow.quant_plan
                 ,sVarchar
                 ,cr||f_docdescrs_get_description(sunitcode => 'CostDeliverySheetsSpec', ndocument => rRow.rn)
                 ,cr||f_docdescrs_get_description(sunitcode => 'CostDeliverySheets', ndocument => rRow.prn)); 
    end if;
    
  end FCDELIVSHSP_ACOMPLETE;
  --#########################################################################################################

  procedure FCDELIVSHSP_BDELETE
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
  end FCDELIVSHSP_BDELETE;
  --#########################################################################################################

  procedure FCDELIVSHSP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              fcdelivshsp%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow            := fcdelivshsp_get(nrn => nRN);
    rIncomeFromDeps := fcdelivsh_get(nrn => rRow.prn);*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКА */

  end FCDELIVSHSP_CHECK_BASE;
  --#########################################################################################################

  function FCDELIVSHSPCMPL_GET
  /*
  Комплектование. Считывание записи
  */
  (
   nRN      in number -- RN записи
  ) 
  return fcdelivshspcmpl%rowtype
  is
    rRow fcdelivshspcmpl%rowtype;
  begin
    begin
      select T.*
        into rRow
        from FCDELIVSHSPCMPL T
        where T.RN = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'FCDELIVSHSPCMPL');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(nRN), 'Не задан')||'> '||
        'в разделе <'||f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCDELIVSHSPCMPL'))||'>.');
    end;
    return(rRow);
  end FCDELIVSHSPCMPL_GET;
  --#########################################################################################################

  procedure FCDELIVSHSPCMPL_AINSERT
  /*
  Комплектование. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    nIdent      pkg_std.tnumber; 
    
    nNumber     pkg_std.tnumber; 
    sVarchar    pkg_std.tstring; 
  begin
    null;
    /* ИСПРАВЛЕНИЯ */
    /* Резервирование */
/*
    From: Марков Михаил Вячеславович <m.markov@module.ru> 
    Sent: Thursday, January 18, 2024 5:52 PM
    To: 'Степанов Михаил Владимирович' <m.stepanov@module.ru>
    Subject: RE: сделать автоматическое резервирование после действия Комплектовать

    Привет.
    Нет.
    Никакого неименованного блока не нужно.
    Действие Скоплектовать – автоматически делает резервирование.
    Если вручную добавляют, то надо вручную зарезервировать.
    Ручного добавления мало – сделают вручную.
    Неименованного блока не надо ставить.
    Постепенно уйдем от ручного комплектования – исключительные случаи будут.

    From: Степанов Михаил Владимирович <> 
    Sent: Thursday, January 18, 2024 10:41 AM
    To: 'Марков Михаил Вячеславович' <m.markov@module.ru>
    Subject: сделать автоматическое резервирование после действия Комплектовать

    Михаил, привет.

    Правильно ли я понял, что после Комплектовать, обязательно необходимо выполнить резервирование? Может я сделаю неименованный блок, который будет автоматически резервировать?

    p_selectlist_genident(nident => nIdent);
    p_selectlist_insert_ext(nident     => nIdent
                           ,ndocument  => nRN
                           ,sunitcode  => 'CostDeliverySheetsSpecCompletion'
                           ,ndocument1 => null
                           ,sunitcode1 => null
                           ,ncrn       => null
                           ,nrn        => nNumber);
      p_fcdelivshspcmpl_reserv(ncompany     => nCOMPANY
                              ,nident       => nIdent
                              ,nreserv      => 1
                              ,dreserv_date => to_date(current_date, 'DD.MM.YYYY HH24:MI:SS')
                              ,nsign_warn   => 1
                              ,smsg         => sVarchar);*/

    /* ПРОВЕРКИ */
    /* Проверка базовая */
    /*fcdelivshspcmpl_check_base(nrn => nRN, ncompany => nCOMPANY);*/

  end FCDELIVSHSPCMPL_AINSERT;
  --#########################################################################################################

  procedure FCDELIVSHSPCMPL_BUPDATE
  /*
  Комплектование. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCDELIVSHSPCMPL_BUPDATE;
  --#########################################################################################################

  procedure FCDELIVSHSPCMPL_AUPDATE
  /*
  Комплектование. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* Проверка базовая */
    /*fcdelivshspcmpl_check_base(nrn => nRN, ncompany => nCOMPANY);*/
  end FCDELIVSHSPCMPL_AUPDATE;
  --#########################################################################################################

  procedure FCDELIVSHSPCMPL_BDELETE
  /*
  Комплектование. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
/*    nIdent      pkg_std.tnumber;
    sVarchar    pkg_std.tstring; */
    nNumber     pkg_std.tnumber := 0; 
    rRow        fcdelivshspcmpl%rowtype;
  begin
    --null;
    rRow := FCDELIVSHSPCMPL_GET(nRN => nRN);

    /* 25/08/2025 KHOK. Проверка наличия Расходной накладной с данной строкой Комплектования */
    begin
      select count(sp.goodsparty) 
        into nNumber
        from FCDELIVSHSPCMPL   cmpl
           , DOCLINKS          dl
           , TRANSINVDEPTSPECS sp
           , UDO_DEPORDS_PRF   prf
     where cmpl.rn = nRN
       and dl.in_document = cmpl.prn 
       and dl.out_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
       and sp.rn = dl.out_document
       and sp.goodsparty = cmpl.party
       and prf.cmpl  = cmpl.rn
       and prf.quant = cmpl.quant;
    end;
    if nNumber > 0 /*and utilizer not in ('KHOK','ZAYKIN_AD', 'STEPANOV_MV')*/ then
      p_exception(0,'Строка комплектования уже включена в Расходную накладную. Удаление невозможно.');
    end if;   
      
    /* ИСПРАВЛЕНИЯ */
    /* Снять резервирование */
/*
    From: Марков Михаил Вячеславович <m.markov@module.ru> 
    Sent: Thursday, January 18, 2024 5:52 PM
    To: 'Степанов Михаил Владимирович' <m.stepanov@module.ru>
    Subject: RE: сделать автоматическое резервирование после действия Комплектовать

    Привет.
    Нет.
    Никакого неименованного блока не нужно.
    Действие Скоплектовать – автоматически делает резервирование.
    Если вручную добавляют, то надо вручную зарезервировать.
    Ручного добавления мало – сделают вручную.
    Неименованного блока не надо ставить.
    Постепенно уйдем от ручного комплектования – исключительные случаи будут.

    From: Степанов Михаил Владимирович <> 
    Sent: Thursday, January 18, 2024 10:41 AM
    To: 'Марков Михаил Вячеславович' <m.markov@module.ru>
    Subject: сделать автоматическое резервирование после действия Комплектовать

    Михаил, привет.

    Правильно ли я понял, что после Комплектовать, обязательно необходимо выполнить резервирование? Может я сделаю неименованный блок, который будет автоматически резервировать?


    p_selectlist_genident(nident => nIdent);
    p_selectlist_insert_ext(nident     => nIdent
                           ,ndocument  => nRN
                           ,sunitcode  => 'CostDeliverySheetsSpecCompletion'
                           ,ndocument1 => null
                           ,sunitcode1 => null
                           ,ncrn       => null
                           ,nrn        => nNumber);
      p_fcdelivshspcmpl_reserv(ncompany     => nCOMPANY
                              ,nident       => nIdent
                              ,nreserv      => 0
                              ,dreserv_date => to_date(current_date, 'DD.MM.YYYY HH24:MI:SS')
                              ,nsign_warn   => 1
                              ,smsg         => sVarchar);*/
  end FCDELIVSHSPCMPL_BDELETE;
  --#########################################################################################################

  procedure FCDELIVSHSPCMPL_CHECK_BASE
  /*
  Комплектование. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              fcdelivshsp%rowtype;
    rIncomeFromDeps   fcdelivsh%rowtype;

    sVarchar          pkg_std.tstring;
  begin
    null;
    /* Считывание */
    /*rRow            := fcdelivshsp_get(nrn => nRN);
    rIncomeFromDeps := fcdelivsh_get(nrn => rRow.prn);*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКА */

  end FCDELIVSHSPCMPL_CHECK_BASE;
  --#########################################################################################################

end USR_PKG_FCDELIVSH;
/
