create or replace package USR_PKG_FILELINKS is
  /*
  Package предназначен для работы с разделом "Присоединённые документы".
  FileLinks       FILELINKS       FL
  FileLinksUnits  FILELINKSUNITS  FLU
  FileLinksTypes  FLINKTYPES      FLT
  */
  --#########################################################################################################

  function FILELINKS_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return FILELINKS%ROWTYPE;
  --#########################################################################################################

  procedure FILELINKS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################
 
 procedure FILELINKS_BINSERT
  /*
  Заголовок. Проверка До добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################


  procedure FILELINKS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FILELINKS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FILELINKS_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FILELINKS_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FILELINKS_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FILELINKS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /*#########################################################################################################*/

  procedure FILELINKS_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW    in v_filelinks%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure FILELINKS_BASE_UPDATE
  /*
  Заголовок. Исправление базовое 
  */
  (
   rROW      in filelinks%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  function FILELINKSUNITS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return FILELINKSUNITS%ROWTYPE;
  --#########################################################################################################

  procedure FILELINKSUNITS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FILELINKSUNITS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_FILELINKS;
/
create or replace package body USR_PKG_FILELINKS is

  --#########################################################################################################

  function FILELINKS_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return filelinks%rowtype
  is
    rRow filelinks%rowtype;
  begin
    begin
      select * into rRow from filelinks where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FILELINKS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FILELINKS')));
    end;
    return(rRow);
  end FILELINKS_GET;
  --#########################################################################################################

  procedure FILELINKS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow       filelinks%rowtype;
    nUA_RN     pkg_std.tref; 
    sUA_Unit   pkg_std.tstring; 
    
    nNumber    pkg_std.tnumber; 
    sVrachar   pkg_std.tstring; 
  begin
    /* Считывание */
    rRow := filelinks_get(nrn => nRN);

    /* Определение RN документа и код раздела, из которого выполнен переход */
    usr_pkg_process.get_current_doc_params(nDOCUMENT => nUA_RN, SUNITCODE => sUA_Unit); 

    /* ИСПРАВЛЕНИЯ */
    /* Если переход выполнен из разделов: Приходные партии товара */
    if sUA_Unit in ('GoodsParties') then
      /* Ищем дкоумента с разделом */
      nNumber := null;
      find_filelinksunits_link(nflag_smart => 1
                              ,ncompany    => nCOMPANY
                              ,sdoccode    => rRow.code
                              ,sunitcode   => sUA_Unit
                              ,ndocument   => nUA_RN
                              ,nrn         => nNumber);
      /* Если связи нет, добавляем */
      if nNumber is null then                              
        /* базовое добавление связи присоединенного документа с разделом */
        p_filelinksunits_base_insert(nfilelinks_prn => rRow.rn
                                    ,ntable_prn     => nUA_RN
                                    ,sunitcode      => sUA_Unit
                                    ,nrn            => nNumber);
        /* отражение в связанном разделе */
        p_filelinksunits_ref(ncompany       => rRow.company
                            ,nfilelinks_prn => rRow.rn
                            ,ntable_prn     => nUA_RN
                            ,sunitcode      => sUA_Unit
                            ,saction        => 'FILELINKS_UNIT_INSERT'
                            ,sdescription   => 'Присоединен документ'
                            ,snote          => rRow.note);
      end if;
    end if;

    /* ПРОВЕРКИ */
    /* Базовая */
    filelinks_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FILELINKS_AINSERT;
  --#########################################################################################################
  
  procedure FILELINKS_BINSERT
  /*
  Заголовок. Проверка До добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) is

s_connect_ext file_buffer.connect_ext%type:= pkg_session.get_connect_ext;
S_res varchar2(2000):=';';
nidn number(17);

  begin
  
  
  
      select max(T.Ident)
      into nidn
                    from file_buffer t
                   where t.connect_ext = s_connect_ext
                     and t.ident =
                             (select max(tt.ident) from file_buffer tt where tt.connect_ext = s_connect_ext);
  
P_FILE_BUFFER_CLEAR( nidn );                  
  
  
  end;
  
  
  --#########################################################################################################
  
  

  procedure FILELINKS_BUPDATE
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
  end FILELINKS_BUPDATE;
  --#########################################################################################################

  procedure FILELINKS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    filelinks_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FILELINKS_AUPDATE;
  --#########################################################################################################

  procedure FILELINKS_BDELETE
  /*
    Заголовок. Проверка перед исправлением
    */
  (
    nrn      in number
   ,ncompany in number
  ) is
  begin
    --- Привязанные документы к разделу Маршрутные листы, строки, нельзя удалять позднее трех дней после загрузки
    --- Их нужно предварительно отвязать от раздела (Действия -- Удалить связь)
  
    for cur in (select f.load_date
                  from filelinks f
                  join filelinksunits fl
                    on fl.filelinks_prn = f.rn
                 where f.rn = nrn
                   and fl.unitcode = 'CostRouteListsSpecs')
    loop
      if trunc(sysdate) - cur.load_date > 3 then
        p_exception(0
                   ,'Присоединенные из раздела "Маршрутные листы. Строки" присоединенные документы нельзя удалять позднее чем через 3 дня после загрузки.' || cr ||
                    'Дата загрузки: %s' || cr || 'Прошло более %s дней'
                   ,to_char(cur.load_date,'DD.MM.YYYY')
                   ,trunc(sysdate - cur.load_date));
      end if;
    
    end loop;
  
    -- Файловое удаление (если тип документа _ФВД) после данной процедуры проверки не ставить!
    usr_p_fcroutlst_files_delete(nrn => nrn);
  end filelinks_bdelete;
  --#########################################################################################################

  procedure FILELINKS_BMOVE_IN
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
  end FILELINKS_BMOVE_IN;
  --#########################################################################################################

  procedure FILELINKS_BMOVE_OUT
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
  end FILELINKS_BMOVE_OUT;
  --#########################################################################################################

  procedure FILELINKS_CHECK_BASE
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
  end FILELINKS_CHECK_BASE;
  /*#########################################################################################################*/

  procedure FILELINKS_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW    in v_filelinks%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_filelinks_update(nrn        => rV_ROW.NRN
                        ,ncompany   => rV_ROW.NCOMPANY
                        ,scode      => rV_ROW.SCODE
                        ,sfile_type => rV_ROW.SFILE_TYPE
                        ,snote      => rV_ROW.SNOTE );

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Штатное исправление */
      p_filelinks_update(nrn        => rV_ROW.NRN
                        ,ncompany   => rV_ROW.NCOMPANY
                        ,scode      => rV_ROW.SCODE
                        ,sfile_type => rV_ROW.SFILE_TYPE
                        ,snote      => rV_ROW.SNOTE );

      /* Исправление дополнительных полей */
      /* файл документа */
      update filelinks 
         set file_path = rV_ROW.sFILE_PATH
       where rn        = rV_ROW.nRN;
      
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end FILELINKS_UPDATE;
  /*#########################################################################################################*/

  procedure FILELINKS_BASE_UPDATE
  /*
  Заголовок. Исправление базовое 
  */
  (
   rROW      in filelinks%rowtype
  ,nMODE     in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_filelinks_base_update( nrn        => rROW.RN
                              ,ncompany   => rROW.COMPANY
                              ,scode      => rROW.CODE
                              ,nfile_type => rROW.FILE_TYPE
                              ,snote      => rROW.NOTE );

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* Штатное исправление */
      p_filelinks_base_update( nrn        => rROW.RN
                              ,ncompany   => rROW.COMPANY
                              ,scode      => rROW.CODE
                              ,nfile_type => rROW.FILE_TYPE
                              ,snote      => rROW.NOTE );

      /* Исправление дополнительных полей */
      /* файл документа */
      update filelinks 
         set file_path = rROW.FILE_PATH
       where rn        = rROW.RN;
      
    else
      p_exception( 0, 'Неизвестный режим выполнения <%s>', nMODE ); 
    end if;

  end FILELINKS_BASE_UPDATE;
  --#########################################################################################################

  function FILELINKSUNITS_GET
  /*
  Спецификация. Считывание записи
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return filelinksunits%rowtype
  is
    rRow filelinksunits%rowtype;
  begin
    begin
      select * into rRow from filelinksunits where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FILELINKSUNITS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FILELINKSUNITS')));
    end;
    return(rRow);
  end FILELINKSUNITS_GET;
  --#########################################################################################################

  procedure FILELINKSUNITS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow          filelinksunits%rowtype;
    rHead         filelinks%rowtype;
    rFLinkTypes   flinktypes%rowtype;
  begin
    /* Считывание */
    rRow  := filelinksunits_get(nrn => nRN);
    rHead := filelinks_get(nrn => rRow.filelinks_prn);
    rFLinkTypes := udo_pkg_get.row_flinktypes(nrn => rHead.file_type, nsmart => 0);

    /* Раздел привязки */
    case rRow.unitcode 
      /* Входящие счета на оплату */
      when 'PaymentAccountsIn' then
        /* Тип присоединённого документа */
        /* Счета на оплату */
        if rHead.file_type = 7645626 then
          p_exception(0, 'Запрещено использовать тип присоединённого документа <%s> для раздела <%s>.'||CR||
                         'Это раздел Входящие(!) счета на оплату.',
                         rFLinkTypes.code, f_unitlist_getname(sunitcode => rRow.unitcode));
        end if;
        /* Договор */
        if rHead.file_type = 7551929 then
          p_exception(0, 'Запрещено использовать тип присоединённого документа <%s> для раздела <%s>.'||CR||
                         'Скан договора должен быть присоединён в разделе Договоры.',
                         rFLinkTypes.code, f_unitlist_getname(sunitcode => rRow.unitcode));
        end if;
      /* Модификации */
      when 'NomenclatorModification' then
        /* Тип присоединённого документа */
        /* Характеристики, Руков.по экспл. */
        if rHead.file_type in (122299697, 122299756) then 
          p_exception(0, 'Запрещено использовать тип присоединённого документа <%s> для раздела <%s>.'
                     ,rFLinkTypes.code, f_unitlist_getname(sunitcode => rRow.unitcode));
        end if;
    else        
      null;
    end case;
    
  end FILELINKSUNITS_AINSERT;
  --#########################################################################################################

  procedure FILELINKSUNITS_BDELETE
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
  end FILELINKSUNITS_BDELETE;
  --#########################################################################################################

end USR_PKG_FILELINKS;
/
