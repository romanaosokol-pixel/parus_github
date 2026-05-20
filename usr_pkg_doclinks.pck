create or replace package USR_PKG_DOCLINKS is
  /*
  Степанов М. 12/09/2023
  Package предназначен для работы с разделом "Связи документов". 
  */
  /*#########################################################################################################*/

  function DOCLINKS_LINK_IN_DOC
  /*
  Получение регистрационного номера входного документа
  */
  (
   nTOO_MANY_ROWS   in number default 0 /* если найдено больше одной 0 - прерывать */
  ,sOUT_UNITCODE    in varchar2
  ,nOUT_DOCUMENT    in number
  ,sIN_UNITCODE     in varchar2 default null
  ,nLINK_TYPE       in number default null
  ) 
  return number;
  /*#########################################################################################################*/

  function DOCLINKS_LINK_OUT_DOC
  /*
  Получение регистрационного номера выходного документа
  */
  (
   nTOO_MANY_ROWS   in number default 0 /* если найдено больше одной 0 - прерывать */
  ,sIN_UNITCODE     in varchar2
  ,nIN_DOCUMENT     in number
  ,sOUT_UNITCODE    in varchar2 default null
  ,nLINK_TYPE       in number default null
  ) 
  return number;
  /*#########################################################################################################*/

  procedure DOCLINKS_LINK_IN_PARAMS
  /*
  Получение данных входной связи 
  */
  (
   nFLAGSMART       in number default 0 
  ,nTOO_MANY_ROWS   in number default 0 /* если найдено больше одной 0 - прерывать */
  ,nOUT_DOCUMENT    in number
  ,nLINK_TYPE       in number default null
  ,sIN_UNITCODE     in out varchar2 
  ,nIN_DOCUMENT     out number
  ,sOUT_UNITCODE    out varchar2
  );
  /*#########################################################################################################*/

  procedure DOCLINKS_LINK_OUT_PARAMS
  /*
  Получение данных выходной связи 
  */
  (
   nFLAGSMART       in number default 0 
  ,nTOO_MANY_ROWS   in number default 0 /* если найдено больше одной 0 - прерывать */
  ,nIN_DOCUMENT     in number
  ,nLINK_TYPE       in number default null
  ,sOUT_UNITCODE    in out varchar2 
  ,nOUT_DOCUMENT    out number
  ,sIN_UNITCODE     out varchar2
  );
  --########################################################################################################

  procedure DOCLINKS_RESET
  /*
  Процедура разрыва и восстановления связей документа
  В режиме Разорвать переносит связи на несуществующий документ с RN 11111, в режиме Восстановить - возвращает связи с несуществующего документа.
  Если не выполнить запуск в режиме Восстановить, то связи останутся на несуществующем документе
  */
  (
   nFLAGSMART     in number
  ,nCOMPANY       in number
  ,nRN            in number
  ,sUNITCODE      in varchar2
  ,nMODE          in number   /* 0 - разорвать, 1 - восстановить */
  );
  --########################################################################################################

  procedure DOCLINKS_RESET_IN
  /*
  Процедура удаления и восстановления входных связей документа
  В режиме удаления возвращает список документов, связи с которыми были удалены. В режиме восстановления использует этот же список.
  */
  (
   nFLAGSMART     in number default 1
  ,nRN            in number
  ,nCOMPANY       in number
  ,sUNITCODE      in varchar2 default null  /* Список разделов через ";". Если пусто, то все */
  ,aRN_UNIT_LIST  in out usr_pkg_pub_const.trn_unit_list
  ,nMODE          in number                 /* 0 - разорвать, 1 - восстановить */
  );
  --########################################################################################################

  procedure DOCLINKS_RESET_OUT
  /*
  Процедура удаления и восстановления выходных связей документа
  В режиме удаления возвращает список документов, связи с которыми были удалены. В режиме восстановления использует этот же список.
  */
  (
   nFLAGSMART     in number
  ,nRN            in number
  ,nCOMPANY       in number
  ,sUNITCODE      in varchar2 default null  /* Список разделов через ";". Если пусто, то все */
  ,aRN_UNIT_LIST  in out usr_pkg_pub_const.trn_unit_list
  ,nMODE          in number                 /* 0 - разорвать, 1 - восстановить */
  );
  --########################################################################################################

  procedure DOCLINKS_RESET_IN
  /*
  НЕ ИСПОЛЬЗОВАТЬ!!! ВМЕСТО НЕЁ ПРОЦЕДУРА ВЫШЕ. ЭТА ОСТАЛАСЬ ДЛЯ СОВМЕСТИМОСТИ. ПОСТЕПЕННО БУДЕТ ВЫВОДИТЬСЯ ИЗ ТЕКСТА
  Процедура удаления и восстановления входных связей документа
  В режиме удаления возвращает список документов, связи с которыми были удалены. В режиме восстановления использует этот же список.
  */
  (
   nFLAGSMART     in number
  ,nCOMPANY       in number
  ,sIN_UNITCODE   in varchar2
  ,aIN_DOCUMENT   in out udo_tp_numtable
  ,sOUT_UNITCODE  in varchar2
  ,nOUT_DOCUMENT  in number
  ,nMODE          in number   /* 0 - разорвать, 1 - восстановить */
  );
  --########################################################################################################

  procedure DOCLINKS_RESET_OUT
  /*
  НЕ ИСПОЛЬЗОВАТЬ!!! ВМЕСТО НЕЁ ПРОЦЕДУРА ВЫШЕ. ЭТА ОСТАЛАСЬ ДЛЯ СОВМЕСТИМОСТИ. ПОСТЕПЕННО БУДЕТ ВЫВОДИТЬСЯ ИЗ ТЕКСТА
  Процедура удаления и восстановления выходных связей документа
  В режиме удаления возвращает список документов, связи с которыми были удалены. В режиме восстановления использует этот же список.
  */
  (
   nFLAGSMART     in number
  ,nCOMPANY       in number
  ,sIN_UNITCODE   in varchar2
  ,nIN_DOCUMENT   in number
  ,sOUT_UNITCODE  in varchar2
  ,aOUT_DOCUMENT  in out udo_tp_numtable
  ,nMODE          in number   /* 0 - разорвать, 1 - восстановить */
  );
  /*#########################################################################################################*/

end USR_PKG_DOCLINKS;
/
create or replace package body USR_PKG_DOCLINKS is

  /*#########################################################################################################*/

  function DOCLINKS_LINK_IN_DOC
  /*
  Получение регистрационного номера входного документа
  */
  (
   nTOO_MANY_ROWS   in number default 0 /* если найдено больше одной 0 - прерывать */
  ,sOUT_UNITCODE    in varchar2
  ,nOUT_DOCUMENT    in number
  ,sIN_UNITCODE     in varchar2 default null
  ,nLINK_TYPE       in number default null
  ) 
  return number 
  as
    nIN_DOCUMENT PKG_STD.tREF;
  begin
    /* инициализация */
    nIN_DOCUMENT := null;
    
    /* выбор типа */
    case
      when ( sIN_UNITCODE is not null and nLINK_TYPE is not null ) then
        begin 
          select /*+ INDEX(L I_DOCLINKS_OUT_DOCUMENT) */ L.IN_DOCUMENT
            into nIN_DOCUMENT
            from DOCLINKS L
            where     L.OUT_DOCUMENT = nOUT_DOCUMENT
                  and L.OUT_UNITCODE = sOUT_UNITCODE
                  and L.IN_UNITCODE  = sIN_UNITCODE
                  and L.LINK_TYPE    = nLINK_TYPE;
        exception
          when no_data_found then
            null;
          when too_many_rows then
            if nTOO_MANY_ROWS = 0 then
              p_exception(0, 'Для документа <%s> из раздела <%s> найдено больше одной входной связи в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
            end if;
          when others then
            p_exception(0, 'Неопределённая ситуация при поиске входной связи для документа <%s> из раздела <%s> в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
        end;              
      when ( sIN_UNITCODE is not null and nLINK_TYPE is null ) then
        begin 
          select /*+ INDEX(L I_DOCLINKS_OUT_DOCUMENT) */ L.IN_DOCUMENT
            into nIN_DOCUMENT
            from DOCLINKS L
            where     L.OUT_DOCUMENT = nOUT_DOCUMENT
                  and L.OUT_UNITCODE = sOUT_UNITCODE
                  and L.IN_UNITCODE  = sIN_UNITCODE;
        exception
          when no_data_found then
            null;
          when too_many_rows then
            if nTOO_MANY_ROWS = 0 then
              p_exception(0, 'Для документа <%s> из раздела <%s> найдено больше одной входной связи в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
            end if;
          when others then
            p_exception(0, 'Неопределённая ситуация при поиске входной связи для документа <%s> из раздела <%s> в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
        end;              
      when ( sIN_UNITCODE is null and nLINK_TYPE is not null ) then
        begin 
          select /*+ INDEX(L I_DOCLINKS_OUT_DOCUMENT) */ L.IN_DOCUMENT
            into nIN_DOCUMENT
            from DOCLINKS L
            where     L.OUT_DOCUMENT = nOUT_DOCUMENT
                  and L.OUT_UNITCODE = sOUT_UNITCODE
                  and L.LINK_TYPE    = nLINK_TYPE;
        exception
          when no_data_found then
            null;
          when too_many_rows then
            if nTOO_MANY_ROWS = 0 then
              p_exception(0, 'Для документа <%s> из раздела <%s> найдено больше одной входной связи в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
            end if;
          when others then
            p_exception(0, 'Неопределённая ситуация при поиске входной связи для документа <%s> из раздела <%s> в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
        end;              
      else
        begin 
          select /*+ INDEX(L I_DOCLINKS_OUT_DOCUMENT) */ L.IN_DOCUMENT
            into nIN_DOCUMENT
            from DOCLINKS L
            where     L.OUT_DOCUMENT = nOUT_DOCUMENT
                  and L.OUT_UNITCODE = sOUT_UNITCODE;
        exception
          when no_data_found then
            null;
          when too_many_rows then
            if nTOO_MANY_ROWS = 0 then
              p_exception(0, 'Для документа <%s> из раздела <%s> найдено больше одной входной связи в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
            end if;
          when others then
            p_exception(0, 'Неопределённая ситуация при поиске входной связи для документа <%s> из раздела <%s> в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
        end;              
    end case;

    /* возврат результата */
    return nIN_DOCUMENT;
    
  end DOCLINKS_LINK_IN_DOC;
  /*#########################################################################################################*/

  function DOCLINKS_LINK_OUT_DOC
  /*
  Получение регистрационного номера выходного документа
  */
  (
   nTOO_MANY_ROWS   in number default 0 /* если найдено больше одной 0 - прерывать */
  ,sIN_UNITCODE     in varchar2
  ,nIN_DOCUMENT     in number
  ,sOUT_UNITCODE    in varchar2 default null
  ,nLINK_TYPE       in number default null
  ) 
  return number 
  as
    nOUT_DOCUMENT PKG_STD.tREF;
  begin
    /* инициализация */
    nOUT_DOCUMENT := null;

    /* выбор типа */
    case
      when ( sOUT_UNITCODE is not null and nLINK_TYPE is not null ) then
        begin
          select /*+ INDEX(L I_DOCLINKS_IN_DOCUMENT) */ L.OUT_DOCUMENT
            into nOUT_DOCUMENT
            from DOCLINKS L
           where L.IN_DOCUMENT  = nIN_DOCUMENT
             and L.IN_UNITCODE  = sIN_UNITCODE
             and L.OUT_UNITCODE = sOUT_UNITCODE
              and L.LINK_TYPE    = nLINK_TYPE;
        exception
          when no_data_found then
            null;
          when too_many_rows then
            if nTOO_MANY_ROWS = 0 then
              p_exception(0, 'Для документа <%s> из раздела <%s> найдено больше одной выходной связи в разделе <%s>.', nIN_DOCUMENT, sIN_UNITCODE, sOUT_UNITCODE); 
            end if;
          when others then
            p_exception(0, 'Неопределённая ситуация при поиске выходной связи для документа <%s> из раздела <%s> в разделе <%s>.', nIN_DOCUMENT, sIN_UNITCODE, sOUT_UNITCODE); 
        end;              
      when ( sOUT_UNITCODE is not null and nLINK_TYPE is null ) then
        begin
          select /*+ INDEX(L I_DOCLINKS_IN_DOCUMENT) */ L.OUT_DOCUMENT
            into nOUT_DOCUMENT
            from DOCLINKS L
           where L.IN_DOCUMENT  = nIN_DOCUMENT
             and L.IN_UNITCODE  = sIN_UNITCODE
             and L.OUT_UNITCODE = sOUT_UNITCODE;
        exception
          when no_data_found then
            null;
          when too_many_rows then
            if nTOO_MANY_ROWS = 0 then
              p_exception(0, 'Для документа <%s> из раздела <%s> найдено больше одной выходной связи в разделе <%s>.', nIN_DOCUMENT, sIN_UNITCODE, sOUT_UNITCODE); 
            end if;
          when others then
            p_exception(0, 'Неопределённая ситуация при поиске выходной связи для документа <%s> из раздела <%s> в разделе <%s>.', nIN_DOCUMENT, sIN_UNITCODE, sOUT_UNITCODE); 
        end;              
      when ( sOUT_UNITCODE is null and nLINK_TYPE is not null ) then
        begin
          select /*+ INDEX(L I_DOCLINKS_IN_DOCUMENT) */ L.OUT_DOCUMENT
            into nOUT_DOCUMENT
            from DOCLINKS L
           where L.IN_DOCUMENT = nIN_DOCUMENT
             and L.IN_UNITCODE = sIN_UNITCODE
             and L.LINK_TYPE   = nLINK_TYPE;
        exception
          when no_data_found then
            null;
          when too_many_rows then
            if nTOO_MANY_ROWS = 0 then
              p_exception(0, 'Для документа <%s> из раздела <%s> найдено больше одной выходной связи в разделе <%s>.', nIN_DOCUMENT, sIN_UNITCODE, sOUT_UNITCODE); 
            end if;
          when others then
            p_exception(0, 'Неопределённая ситуация при поиске выходной связи для документа <%s> из раздела <%s> в разделе <%s>.', nIN_DOCUMENT, sIN_UNITCODE, sOUT_UNITCODE); 
        end;              
      else
        begin
          select /*+ INDEX(L I_DOCLINKS_IN_DOCUMENT) */ L.OUT_DOCUMENT
            into nOUT_DOCUMENT
            from DOCLINKS L
           where L.IN_DOCUMENT = nIN_DOCUMENT
             and L.IN_UNITCODE = sIN_UNITCODE;
        exception
          when no_data_found then
            null;
          when too_many_rows then
            if nTOO_MANY_ROWS = 0 then
              p_exception(0, 'Для документа <%s> из раздела <%s> найдено больше одной выходной связи в разделе <%s>.', nIN_DOCUMENT, sIN_UNITCODE, sOUT_UNITCODE); 
            end if;
          when others then
            p_exception(0, 'Неопределённая ситуация при поиске выходной связи для документа <%s> из раздела <%s> в разделе <%s>.', nIN_DOCUMENT, sIN_UNITCODE, sOUT_UNITCODE); 
        end;              
    end case;

    /* возврат результата */
    return nOUT_DOCUMENT;
    
  end DOCLINKS_LINK_OUT_DOC;
  /*#########################################################################################################*/

  procedure DOCLINKS_LINK_IN_PARAMS
  /*
  Получение данных входной связи 
  */
  (
   nFLAGSMART       in number default 0 
  ,nTOO_MANY_ROWS   in number default 0 /* если найдено больше одной 0 - прерывать */
  ,nOUT_DOCUMENT    in number
  ,nLINK_TYPE       in number default null
  ,sIN_UNITCODE     in out varchar2 
  ,nIN_DOCUMENT     out number
  ,sOUT_UNITCODE    out varchar2
  ) 
  as
  begin
    begin 
      select l.in_document, l.in_unitcode, l.out_unitcode 
        into nIN_DOCUMENT , sIN_UNITCODE , sOUT_UNITCODE
        from doclinks l
       where l.out_document = nOUT_DOCUMENT
         and (L.in_unitcode = sIN_UNITCODE or sIN_UNITCODE is null)
         and (l.link_type   = nLINK_TYPE   or nLINK_TYPE is null);
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Для документа <%s> из раздела <%s> найдено больше одной входной связи в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
      when too_many_rows then
        if nTOO_MANY_ROWS = 0 then
          p_exception(nFLAGSMART, 'Для документа <%s> из раздела <%s> найдено больше одной входной связи в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
        end if;
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске входной связи для документа <%s> из раздела <%s> в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
    end;              

  end DOCLINKS_LINK_IN_PARAMS;
  /*#########################################################################################################*/

  procedure DOCLINKS_LINK_OUT_PARAMS
  /*
  Получение данных выходной связи 
  */
  (
   nFLAGSMART       in number default 0 
  ,nTOO_MANY_ROWS   in number default 0 /* если найдено больше одной 0 - прерывать */
  ,nIN_DOCUMENT     in number
  ,nLINK_TYPE       in number default null
  ,sOUT_UNITCODE    in out varchar2 
  ,nOUT_DOCUMENT    out number
  ,sIN_UNITCODE     out varchar2
  ) 
  as
  begin
    begin 
      select l.out_document, l.out_unitcode, l.in_unitcode 
        into nOUT_DOCUMENT , sOUT_UNITCODE , sIN_UNITCODE
        from doclinks l
       where l.in_document   = nIN_DOCUMENT
         and (L.out_unitcode = sOUT_UNITCODE or sOUT_UNITCODE is null)
         and (l.link_type    = nLINK_TYPE    or nLINK_TYPE is null);
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Для документа <%s> из раздела <%s> найдено больше одной входной связи в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
      when too_many_rows then
        if nTOO_MANY_ROWS = 0 then
          p_exception(nFLAGSMART, 'Для документа <%s> из раздела <%s> найдено больше одной входной связи в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
        end if;
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске входной связи для документа <%s> из раздела <%s> в разделе <%s>.', nOUT_DOCUMENT, sOUT_UNITCODE, sIN_UNITCODE); 
    end;              

  end DOCLINKS_LINK_OUT_PARAMS;
  --########################################################################################################

  procedure DOCLINKS_RESET
  /*
  Процедура разрыва и восстановления связей документа
  В режиме Разорвать переносит связи на несуществующий документ с RN 11111, в режиме Восстановить - возвращает связи с несуществующего документа.
  Если не выполнить запуск в режиме Восстановить, то связи останутся на несуществующем документе
  */
  (
   nFLAGSMART     in number
  ,nCOMPANY       in number
  ,nRN            in number
  ,sUNITCODE      in varchar2
  ,nMODE          in number   /* 0 - разорвать, 1 - восстановить */
  ) 
  as
    nDocLinksExists     pkg_std.tnumber;  /* 0 - связи отсутствуют, 1 - связь по входу, 2 - связь по выходу, 3 - связи и по входу и по выходу */
  begin

    /* Режим выполнения */
    case nMODE

      /* Разорвать */
      when 0 then
        /* Опрределение наличия связей для документа */
        nDocLinksExists := f_doclinks_link_exists(sunitcode => sUNITCODE, ndocument => nRN);
        /* Если связи есть, то перенос */
        if nDocLinksExists = 2 then
          pkg_doclinks.reset_in (ncompany => nCOMPANY, sold_unitcode => sUNITCODE, nold_document => nRN, snew_unitcode => sUNITCODE, nnew_document => 11111);
        elsif nDocLinksExists = 1 then
          pkg_doclinks.reset_out(ncompany => nCOMPANY, sold_unitcode => sUNITCODE, nold_document => nRN, snew_unitcode => sUNITCODE, nnew_document => 11111);
        elsif nDocLinksExists = 3 then
          pkg_doclinks.reset_in (ncompany => nCOMPANY, sold_unitcode => sUNITCODE, nold_document => nRN, snew_unitcode => sUNITCODE, nnew_document => 11111);
          pkg_doclinks.reset_out(ncompany => nCOMPANY, sold_unitcode => sUNITCODE, nold_document => nRN, snew_unitcode => sUNITCODE, nnew_document => 11111);
        elsif nDocLinksExists = 0 and nFLAGSMART = 0 then
          p_exception(0, 'Документ не имеет связей. RN: %s, раздел %s', nRN, sUNITCODE); 
        end if;

      /* Восстановить */
      when 1 then 
        /* Опрределение наличия связей для течнической записи */
        nDocLinksExists := f_doclinks_link_exists(sunitcode => sUNITCODE, ndocument => 11111);
        /* Если связи есть, то перенос */
        if nDocLinksExists = 2 then
          pkg_doclinks.reset_in (ncompany => nCOMPANY, sold_unitcode => sUNITCODE, nold_document => 11111, snew_unitcode => sUNITCODE, nnew_document => nRN);
        elsif nDocLinksExists = 1 then
          pkg_doclinks.reset_out(ncompany => nCOMPANY, sold_unitcode => sUNITCODE, nold_document => 11111, snew_unitcode => sUNITCODE, nnew_document => nRN);
        elsif nDocLinksExists = 3 then
          pkg_doclinks.reset_in (ncompany => nCOMPANY, sold_unitcode => sUNITCODE, nold_document => 11111, snew_unitcode => sUNITCODE, nnew_document => nRN);
          pkg_doclinks.reset_out(ncompany => nCOMPANY, sold_unitcode => sUNITCODE, nold_document => 11111, snew_unitcode => sUNITCODE, nnew_document => nRN);
        elsif nDocLinksExists = 0 and nFLAGSMART = 0 then
          p_exception(0, 'Документ не имеет связей. RN: %s, раздел %s', nRN, sUNITCODE); 
        end if;
    else
      p_exception(0, 'Неверный режим работы %s.', nMODE); 
    end case;        

  end DOCLINKS_RESET;
  --########################################################################################################

  procedure DOCLINKS_RESET_IN
  /*
  Процедура удаления и восстановления входных связей документа
  В режиме удаления возвращает список документов, связи с которыми были удалены. В режиме восстановления использует этот же список.
  */
  (
   nFLAGSMART     in number default 1
  ,nRN            in number
  ,nCOMPANY       in number
  ,sUNITCODE      in varchar2 default null  /* Список разделов через ";". Если пусто, то все */
  ,aRN_UNIT_LIST  in out usr_pkg_pub_const.trn_unit_list
  ,nMODE          in number                 /* 0 - разорвать, 1 - восстановить */
  ) 
  as
  begin
    /* Режим выполнения */
    case nMODE

      /* Разорвать */
      when 0 then

        /* Считывание списка документов по связям */
        begin
          select t.in_document, t.in_unitcode, t.out_unitcode bulk collect
            into aRN_UNIT_LIST
            from doclinks t
           where t.out_document = nRN 
             and ( strin( t.in_unitcode , sUNITCODE , ';' ) = 1 
                 or sUNITCODE is null );
        end;
        
        /* Если массив пустой, выходим */
        if aRN_UNIT_LIST.COUNT = 0 then
          p_exception( nFLAGSMART, 'Не найдены связи для удаления у документа с RN: %s', nRN ); 
          return;
        end if;

        /* Удаление связей по списку */
        for i in aRN_UNIT_LIST.FIRST .. aRN_UNIT_LIST.LAST loop
          pkg_doclinks.remove( sin_unitcode  => aRN_UNIT_LIST(i).UNITCODE
                              ,nin_document  => aRN_UNIT_LIST(i).DOCUMENT
                              ,sout_unitcode => aRN_UNIT_LIST(i).UNITCODE_OWN
                              ,nout_document => nRN );
        end loop;

      /* Восстановить */
      when 1 then 

        /* Если массив пустой, выходим */
        if aRN_UNIT_LIST.COUNT = 0 then
          p_exception(nFLAGSMART, 'Не найдены связи для восстановления у документа с RN: %s', nRN); 
          return;
        end if;

        /* Создание связей по списку */
        for i in aRN_UNIT_LIST.FIRST .. aRN_UNIT_LIST.LAST loop
          pkg_doclinks.link( nflag_smart       => 0
                            ,ncompany          => nCOMPANY
                            ,sin_unitcode      => aRN_UNIT_LIST(i).UNITCODE
                            ,nin_document      => aRN_UNIT_LIST(i).DOCUMENT
                            ,sout_unitcode     => aRN_UNIT_LIST(i).UNITCODE_OWN
                            ,nout_document     => nRN );
        end loop;

    else
      p_exception(0, 'Неверный режим работы %s.', nMODE); 
    end case;        

  END DOCLINKS_RESET_IN;
  --########################################################################################################

  procedure DOCLINKS_RESET_OUT
  /*
  Процедура удаления и восстановления выходных связей документа
  В режиме удаления возвращает список документов, связи с которыми были удалены. В режиме восстановления использует этот же список.
  */
  (
   nFLAGSMART     in number
  ,nRN            in number
  ,nCOMPANY       in number
  ,sUNITCODE      in varchar2 default null  /* Список разделов через ";". Если пусто, то все */
  ,aRN_UNIT_LIST  in out usr_pkg_pub_const.trn_unit_list
  ,nMODE          in number                 /* 0 - разорвать, 1 - восстановить */
  ) 
  as
  begin
    /* Режим выполнения */
    case nMODE

      /* Разорвать */
      when 0 then

        /* Считывание списка документов по связям */
        begin
          select t.out_document, t.out_unitcode, t.in_unitcode bulk collect
            into aRN_UNIT_LIST
            from doclinks t
           where t.in_document = nRN 
             and ( strin( t.out_unitcode , sUNITCODE , ';' ) = 1 
                 or sUNITCODE is null );
        end;
        
        /* Если массив пустой, выходим */
        if aRN_UNIT_LIST.COUNT = 0 then
          p_exception( nFLAGSMART, 'Не найдены связи для удаления у документа с RN: %s', nRN ); 
          return;
        end if;

        /* Удаление связей по списку */
        for i in aRN_UNIT_LIST.FIRST .. aRN_UNIT_LIST.LAST loop
          pkg_doclinks.remove( sin_unitcode  => aRN_UNIT_LIST(i).UNITCODE_OWN
                              ,nin_document  => nRN                        
                              ,sout_unitcode => aRN_UNIT_LIST(i).UNITCODE
                              ,nout_document => aRN_UNIT_LIST(i).DOCUMENT );
        end loop;

      /* Восстановить */
      when 1 then 
        /* Если массив пустой, выходим */
        if aRN_UNIT_LIST.COUNT = 0 then
          p_exception(nFLAGSMART, 'Не найдены связи для восстановления у документа с RN: %s', nRN); 
          return;
        end if;

        /* Создание связей по списку */
        for i in aRN_UNIT_LIST.FIRST .. aRN_UNIT_LIST.LAST loop
          pkg_doclinks.link( nflag_smart       => 0
                            ,ncompany          => nCOMPANY
                            ,sin_unitcode      => aRN_UNIT_LIST(i).UNITCODE_OWN
                            ,nin_document      => nRN
                            ,sout_unitcode     => aRN_UNIT_LIST(i).UNITCODE
                            ,nout_document     => aRN_UNIT_LIST(i).DOCUMENT );
        end loop;

    else
      p_exception(0, 'Неверный режим работы %s.', nMODE); 
    end case;        

  END DOCLINKS_RESET_OUT;
  --########################################################################################################

  procedure DOCLINKS_RESET_IN
  /*
  НЕ ИСПОЛЬЗОВАТЬ!!! ВМЕСТО НЕЁ ПРОЦЕДУРА ВЫШЕ. ЭТА ОСТАЛАСЬ ДЛЯ СОВМЕСТИМОСТИ. ПОСТЕПЕННО БУДЕТ ВЫВОДИТЬСЯ ИЗ ТЕКСТА
  Процедура удаления и восстановления входных связей документа
  В режиме удаления возвращает список документов, связи с которыми были удалены. В режиме восстановления использует этот же список.
  */
  (
   nFLAGSMART     in number
  ,nCOMPANY       in number
  ,sIN_UNITCODE   in varchar2
  ,aIN_DOCUMENT   in out udo_tp_numtable
  ,sOUT_UNITCODE  in varchar2
  ,nOUT_DOCUMENT  in number
  ,nMODE          in number   /* 0 - разорвать, 1 - восстановить */
  ) 
  as
    aRN_Unit_List   usr_pkg_pub_const.trn_unit_list;
  begin
    for c in ( select column_value as document, rownum from table( cast( aIN_DOCUMENT as udo_tp_numtable ) ) ) 
    loop
      aRN_Unit_List(c.rownum).document     := c.document;
      aRN_Unit_List(c.rownum).unitcode     := sIN_UNITCODE;
      aRN_Unit_List(c.rownum).unitcode_own := sOUT_UNITCODE;
    end loop;

    usr_pkg_doclinks.doclinks_reset_in(nflagsmart    => nFLAGSMART
                                      ,nrn           => nOUT_DOCUMENT
                                      ,ncompany      => nCOMPANY
                                      ,sunitcode     => sIN_UNITCODE
                                      ,arn_unit_list => arn_unit_list
                                      ,nmode         => nMODE);

    if aRN_Unit_List.count != 0 then
      for i in aRN_Unit_List.first .. aRN_Unit_List.last  loop
        aIN_DOCUMENT.extend;
        aIN_DOCUMENT(i) := aRN_Unit_List(i).document;
      end loop;
    end if;

  END DOCLINKS_RESET_IN;
  --########################################################################################################

  procedure DOCLINKS_RESET_OUT
  /*
  НЕ ИСПОЛЬЗОВАТЬ!!! ВМЕСТО НЕЁ ПРОЦЕДУРА ВЫШЕ. ЭТА ОСТАЛАСЬ ДЛЯ СОВМЕСТИМОСТИ. ПОСТЕПЕННО БУДЕТ ВЫВОДИТЬСЯ ИЗ ТЕКСТА
  Процедура удаления и восстановления выходных связей документа
  В режиме удаления возвращает список документов, связи с которыми были удалены. В режиме восстановления использует этот же список.
  */
  (
   nFLAGSMART     in number
  ,nCOMPANY       in number
  ,sIN_UNITCODE   in varchar2
  ,nIN_DOCUMENT   in number
  ,sOUT_UNITCODE  in varchar2
  ,aOUT_DOCUMENT  in out udo_tp_numtable
  ,nMODE          in number   /* 0 - разорвать, 1 - восстановить */
  ) 
  as
    aRN_Unit_List   usr_pkg_pub_const.trn_unit_list;
  begin
    for c in ( select column_value as document, rownum from table( cast( aOUT_DOCUMENT as udo_tp_numtable ) ) ) 
    loop
      aRN_Unit_List(c.rownum).document     := c.document;
      aRN_Unit_List(c.rownum).unitcode     := sOUT_UNITCODE;
      aRN_Unit_List(c.rownum).unitcode_own := sIN_UNITCODE;
    end loop;

    usr_pkg_doclinks.doclinks_reset_out( nflagsmart    => nFLAGSMART
                                        ,nrn           => nIN_DOCUMENT
                                        ,ncompany      => nCOMPANY
                                        ,sunitcode     => sOUT_UNITCODE
                                        ,arn_unit_list => aRN_Unit_List
                                        ,nmode         => nMODE );

    if aRN_Unit_List.count != 0 then
      for i in aRN_Unit_List.first .. aRN_Unit_List.last  loop
        aOUT_DOCUMENT.extend;
        aOUT_DOCUMENT(i) := aRN_Unit_List(i).document;
      end loop;
    end if;

  END DOCLINKS_RESET_OUT;
  /*#########################################################################################################*/

end USR_PKG_DOCLINKS;
/
