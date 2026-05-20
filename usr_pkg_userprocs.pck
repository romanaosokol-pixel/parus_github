create or replace package USR_PKG_USERPROCS is
  /*
  Степанов М. 17/04/2024
  Для работы с разделом "Пользовательские процедуры". 
  UserProcedures          USERPROCS         UP
  UserProceduresParams    USERPROCSPARAMS   UPP
  UserProceduresLinks     USERPROCSLINKS    UPL
  */
  --#########################################################################################################

  function USERPROCS_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN       in number
  ) 
  return USERPROCS%rowtype;
  --#########################################################################################################

  procedure USERPROCS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCS_BMOVE_IN
  /*
  Заголовок. Проверка перед перемещением в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCS_AMOVE_IN
  /*
  Заголовок. Проверка после перемещения в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCS_BMOVE_OUT
  /*
  Заголовок. Проверка перед перемещением из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCS_AMOVE_OUT
  /*
  Заголовок. Проверка после перемещения из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCS_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCS_BEXEC
  /*
  Заголовок. Выполнение. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  );
  --#########################################################################################################

  procedure USERPROCS_AEXEC
  /*
  Заголовок. Выполнение. После
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  );
  --#########################################################################################################

  procedure USERPROCS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
--#########################################################################################################

  function USERPROCSPARAMS_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN       in number
  ) 
  return USERPROCSPARAMS%ROWTYPE;
  --#########################################################################################################

  procedure USERPROCSPARAMS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCSPARAMS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCSPARAMS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCSPARAMS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCSPARAMS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  function USERPROCSLINKS_GET
  /*
  История. Считывание
  */
  (
   nRN      in number 
  ) 
  return userprocslinks%rowtype;
  --#########################################################################################################

  procedure USERPROCSLINKS_AINSERT
  /*
  История. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCSLINKS_BUPDATE
  /*
  История. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCSLINKS_AUPDATE
  /*
  История. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCSLINKS_BDELETE
  /*
  История. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure USERPROCSLINKS_CHECK_BASE
  /*
  История. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_USERPROCS;
/
create or replace package body USR_PKG_USERPROCS is

  --#########################################################################################################

  function USERPROCS_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN      in number
  ) 
  return userprocs%rowtype
  is
    rRow userprocs%rowtype;
  begin
    begin
      select T.*
        into rRow
        from userprocs t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERPROCS'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERPROCS')));
    end;
    return(rRow);
  end USERPROCS_GET;
  --#########################################################################################################

  procedure USERPROCS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            userprocs%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание
     rRow := USERPROCS_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    userprocs_check_base(nrn => nRN, ncompany => nCOMPANY);

  end USERPROCS_AINSERT;
  --#########################################################################################################

  procedure USERPROCS_BUPDATE
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
  end USERPROCS_BUPDATE;
  --#########################################################################################################

  procedure USERPROCS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      userprocs%rowtype;
    
  begin
    /* Считывание
     rRow := userprocs_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    userprocs_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end USERPROCS_AUPDATE;
  --#########################################################################################################

  procedure USERPROCS_BMOVE_IN
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
  end USERPROCS_BMOVE_IN;
  --#########################################################################################################

  procedure USERPROCS_AMOVE_IN
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
  end USERPROCS_AMOVE_IN;
  --#########################################################################################################

  procedure USERPROCS_BMOVE_OUT
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
  end USERPROCS_BMOVE_OUT;
  --#########################################################################################################

  procedure USERPROCS_AMOVE_OUT
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
  end USERPROCS_AMOVE_OUT;
  --#########################################################################################################

  procedure USERPROCS_BDELETE
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
  end USERPROCS_BDELETE;
  --#########################################################################################################

  procedure USERPROCS_BEXEC
  /*
  Заголовок. Выполнение. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  ) 
  is
    rRow              userprocs%rowtype;
    sWriteUpdateList  pkg_std.tstring; 
    nDocument         pkg_std.tref; 
    sNote             updatelist.note%type;
    
    sParams           pkg_std.tstring;
  begin
    /* Считывание */
    rRow := userprocs_get(nrn => NRN);

    /* Значение свойства "Добавлять в журнал регистрации событий" */
    sWriteUpdateList := f_docs_props_get_str_value(nproperty => 115844254 /* Доб.Журн.Рег.Соб. */
                                                  ,sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERPROCS')
                                                  ,ndocument => rRow.rn);

    /* Если добавлять в журнал регистрации событий и пользователь не имеет роли Все права */
    if cmp_vc2(upper(sWriteUpdateList), 'ДА') = 1 then

      /* Формирование текста со значениями параметров процедуры */
      for c in (
                select p.name, t.stringvalue, t.numbervalue, t.datevalue, p.linking
                  from userprocsparamsbuf t, userprocsparams p
                 where t.prn     = p.rn
                   and t.authid  = utilizer() 
                   and p.linking in (0, 2, 4, 5)
               )
      loop
        /* Формирование текста с именами параметров и их значениями */
        sParams := strcombine(sParams, c.name||': '||nvl(c.stringvalue, nvl(n2si(c.numbervalue), decode_date(c.datevalue))), cr);
        /* Если параметр привязан к регистрационному номеру записи */
        if c.linking = 4 then
          /* Сохраняем его значение как RN текущего документа */
          nDocument := c.numbervalue;
        end if;
      end loop;

      /* Формирование текста примечания */
      sNote := 'Выполнение пользовательской процедуры "'||rRow.name||'" ('||rRow.code||') с параметрами:'||cr||sParams;

      /* Регистрация события в разделе Пользовательские процедуры */
      if pkg_iud.prologue(stable_name => 'USERPROCS', soper_type => 'U') then
        pkg_iud.reg_rn(scolumn_name => 'RN', nnum_value => rRow.rn, nupd_num_value => rRow.rn);
        pkg_iud.reg_note(iposition => 2, scolumn_name => null, sstr_value => sNote||cr);
        pkg_iud.epilogue();
      end if;

      /* Если в параметрах процедуры задан RN текущего документа */
      if nDocument is not null then
        /* Добавляем запись в журнал регистрации для текущего документа */
        usr_pkg_updatelist.updatelist_base_insert(stable_name     => 'USERPROCS'
                                                 ,ndocument       => nDocument
                                                 ,ncompany        => nCOMPANY
                                                 ,soperation      => 'U'
                                                 ,dmodifdate      => sysdate
                                                 ,snote           => sNote
                                                 ,nbusprochist    => 1
                                                 ,nbusprocacthist => null);
      end if;
    end if;

  end USERPROCS_BEXEC;
  --#########################################################################################################

  procedure USERPROCS_AEXEC
  /*
  Заголовок. Выполнение. После
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  ) 
  is
  begin
    null;    
  end USERPROCS_AEXEC;
  --#########################################################################################################

  procedure USERPROCS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      userprocs%rowtype;
  begin
    null;
    
  end USERPROCS_CHECK_BASE;
  --#########################################################################################################

  function USERPROCSPARAMS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number 
  ) 
  return userprocsparams%rowtype
  is
    rRow userprocsparams%rowtype;
  begin
    begin
      select T.*
        into rRow
        from userprocsparams t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERPROCSPARAMS'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERPROCSPARAMS')));
    end;
    return(rRow);
  end USERPROCSPARAMS_GET;
  --#########################################################################################################

  procedure USERPROCSPARAMS_AINSERT
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
    userprocsparams_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end USERPROCSPARAMS_AINSERT;
  --#########################################################################################################

  procedure USERPROCSPARAMS_BUPDATE
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
  end USERPROCSPARAMS_BUPDATE;
  --#########################################################################################################

  procedure USERPROCSPARAMS_AUPDATE
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
    userprocsparams_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end USERPROCSPARAMS_AUPDATE;
  --#########################################################################################################

  procedure USERPROCSPARAMS_BDELETE
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
  end USERPROCSPARAMS_BDELETE;
  --#########################################################################################################

  procedure USERPROCSPARAMS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     userprocsparams%rowtype;
  begin
    null;
   
  end USERPROCSPARAMS_CHECK_BASE;
  --#########################################################################################################

  function USERPROCSLINKS_GET
  /*
  История. Считывание
  */
  (
   nRN      in number 
  ) 
  return userprocslinks%rowtype
  is
    rRow userprocslinks%rowtype;
  begin
    begin
      select T.*
        into rRow
        from userprocslinks t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERPROCSLINKS'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'USERPROCSLINKS')));
    end;
    return(rRow);
  end USERPROCSLINKS_GET;
  --#########################################################################################################

  procedure USERPROCSLINKS_AINSERT
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
    userprocslinks_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end USERPROCSLINKS_AINSERT;
  --#########################################################################################################

  procedure USERPROCSLINKS_BUPDATE
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
  end USERPROCSLINKS_BUPDATE;
  --#########################################################################################################

  procedure USERPROCSLINKS_AUPDATE
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
    userprocslinks_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end USERPROCSLINKS_AUPDATE;
  --#########################################################################################################

  procedure USERPROCSLINKS_BDELETE
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
  end USERPROCSLINKS_BDELETE;
  --#########################################################################################################

  procedure USERPROCSLINKS_CHECK_BASE
  /*
  История. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     userprocslinks%rowtype;
  begin
    null;
   
  end USERPROCSLINKS_CHECK_BASE;
  --#########################################################################################################

end USR_PKG_USERPROCS;
/
