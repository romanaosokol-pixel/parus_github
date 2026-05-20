create or replace package UDO_PKG_SHEETD28_BASE is

  -- Author  : ЦИТК ПАРУС (ASTAFIEV_D)
  -- Created : 01.06.2023
  -- Purpose : Базовый функционал раздела "Ведомость Д28"

-----------------------------------------------------------------------------------------
-- ПОИСК ЗАПИСИ ВЕДОМОСТИ Д28 ПО НОМЕРУ
-----------------------------------------------------------------------------------------
procedure FIND_DOC_NUMB(
          nFLAG_SMART          in number,    -- Признак генерации исключения (0 - да, 1 - нет)
          nFLAG_OPTION         in number,    -- Признак генерации исключения для пустого номера (0 - да, 1 - нет)
          nCOMPANY             in number,    -- Организация
          nDOCTYPE             in number,    -- Тип документа
          sDOCPREF             in varchar2,  -- Префикс номера
          sDOCNUMB             in varchar2,  -- Номер
          dDOCDATE             in date,      -- Дата документа
          nRN                  out number
          );

---------------------------------------------------------------------------------------------------
-- СЧИТЫВАНИЕ ЗАПИСИ ВЕДОМОСТИ Д28 (РАСШИРЕННОЕ)
---------------------------------------------------------------------------------------------------
procedure DOC_EXISTS_EX(
          nRN                  in number, -- Регистрационный номер записи
          rREC                 in out nocopy udo_sheetd28%rowtype,
          bFOR_UPDATE          in boolean default false, -- признак блокировки записи
          bRAISE_NOT_FOUND     in boolean default true   -- признак генерации исключения при отсутствии записи
          );

---------------------------------------------------------------------------------------------------
-- СЧИТЫВАНИЕ ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_EXISTS(
          nRN                  in number,  -- Регистрационный номер
          nCOMPANY             in number,  -- Организация
          nCRN                 out number, -- Каталог
          nJUR_PERS            out number  -- Юридическое лицо
          );

---------------------------------------------------------------------------------------------------
-- ГЕНЕРАЦИЯ СЛЕДУЮЩЕГО НОМЕРА ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_GETNEXTNUMB(
          nCOMPANY             in number,   -- Организация
          nJUR_PERS            in number,   -- Юридическое лицо
          dDOCDATE             in date,     -- Дата документа
          nDOCTYPE             in number,   -- Тип документа
          sDOCPREF             in varchar2, -- Префикс
          sDOCNUMB             out varchar2 -- Номер документа
          );

---------------------------------------------------------------------------------------------------
-- ПАРАМЕТРЫ ПО УМОЛЧАНИЮ ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_DEFAULT(
          rREC                 in out udo_sheetd28%rowtype, -- Запись
          bUSE_OPTIONS         in boolean  default false    -- Использовать значения из настроек пользователя
          );

---------------------------------------------------------------------------------------------------
-- ПРОВЕРКА ПРЕФИКСА НОМЕРА ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_CHECK_PREF(
          nCOMPANY             in number,       -- Организация
          sDOCPREF             in out varchar2, -- Префикс
          nSIGN_OPTION         in number default 0 -- Использовать значение из настроек системы
          );

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ДОБАВЛЕНИЕ ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_INSERT(
          nCOMPANY             in number,   -- Организация
          nCRN                 in number,   -- Каталог
          nJUR_PERS            in number,   -- Юридическое лицо
          nDOCTYPE             in number,   -- Тип документа
          sDOCPREF             in varchar2, -- Префикс документа
          sDOCNUMB             in varchar2, -- Номер документа
          dDOCDATE             in date,     -- Дата документа
          sEXT_NUMBER          in varchar2, -- Внешний номер
          nSUBDIV              in number,   -- Подразделение
          nRESPONSIBLE         in number,   -- Ответственный
          nMATRES              in number,   -- Изделие
          sNOTE                in varchar2, -- Примечание
          sBARCODE             in varchar2, -- Штрих-код
          nRN                  out number   -- Регистрационный номер записи
          );

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ИСПРАВЛЕНИЕ ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_UPDATE(
          nRN                  in number,   -- Регистрационный номер записи
          nCOMPANY             in number,   -- Организация
          nJUR_PERS            in number,   -- Юридическое лицо
          nDOCTYPE             in number,   -- Тип документа
          sDOCPREF             in varchar2, -- Префикс документа
          sDOCNUMB             in varchar2, -- Номер документа
          dDOCDATE             in date,     -- Дата документа
          sEXT_NUMBER          in varchar2, -- Внешний номер
          nSUBDIV              in number,   -- Подразделение
          nRESPONSIBLE         in number,   -- Ответственный
          nMATRES              in number,   -- Изделие
          sNOTE                in varchar2, -- Примечание
          sBARCODE             in varchar2  -- Штрих-код
          );

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ УДАЛЕНИЕ ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_DELETE(
          nRN                  in number, -- Регистрационный номер
          nCOMPANY             in number  -- Организация
          );

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ УСТАНОВКА СОСТОЯНИЯ ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_SETSTATE(
          nRN                  in number, -- Регистрационный номер
          nSTATE               in number, -- Состояние: 0-Не утвержден; 1-Утвержден;
          dSTATE_DATE          in date,   -- Дата изменения состояния
          nSIGN_USEDOCDATE     in number default 0
          );

---------------------------------------------------------------------------------------------------
-- СЧИТЫВАНИЕ ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28 (РАСШИРЕННОЕ)
---------------------------------------------------------------------------------------------------
procedure SPEC_EXISTS_EX(
          nRN                  in number, -- Регистрационный номер записи
          rREC                 in out nocopy udo_sheetd28sp%rowtype, -- Запись
          bFOR_UPDATE          in boolean default false, -- Признак блокировки записи
          bRAISE_NOT_FOUND     in boolean default true   -- Признак генерации исключения при отсутствии записи
          );

---------------------------------------------------------------------------------------------------
-- СЧИТЫВАНИЕ ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_EXISTS(
          nRN                  in number,   -- Регистрационный номер записи
          nCOMPANY             in number,   -- Организация
          nPRN                 out number,  -- Регистрационный номер родителя
          nCRN                 out number,  -- Каталог
          nJUR_PERS            out number   -- Юридическое лицо
          );

---------------------------------------------------------------------------------------------------
-- ПРОВЕРКА КОМПЛЕКТУЮЩЕЙ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_CHECK_COMPLETE(
          nFLAG_SMART          in number,   -- Признак генерации исключения (0 - да, 1 - нет)
          nCOMPANY             in number,   -- Организация
          nMATRES              in number,   -- Изделие
          nCOMPLETE            in number,   -- Комплектующая
          nRESULT              out number,  -- Является комплектующей (0 - нет, 1 - да)
          nSUBDIV              in number default null  -- подразделение-исполнитель
          );

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ДОБАВЛЕНИЕ ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_INSERT(
          nCOMPANY             in number,    -- Организация
          nPRN                 in number,    -- Регистрационный номер родителя
          nMATRES              in number,    -- Материальный ресурс
          nMATRES_DIFF         in number,    -- Материальный ресурс замены
          sNOTE                in varchar2,  -- Примечание
          nRN                  out number    -- Регистрационный номер
          );

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ИСПРАВЛЕНИЕ ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_UPDATE(
          nRN                  in number,    -- Регистрационный номер
          nCOMPANY             in number,    -- Организация
          nMATRES              in number,    -- Материальный ресурс
          nMATRES_DIFF         in number,    -- Материальный ресурс замены
          sNOTE                in varchar2   -- Примечание
          );

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ УДАЛЕНИЕ ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_DELETE(
          nRN                  in number, -- Регистрационный номер
          nCOMPANY             in number  -- Организация
          );

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ФОРМИРОВАНИЕ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_MAKE(
          nCOMPANY             in number,
          nPRN                 in number
          );

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ФОРМИРОВАНИЕ ЗАПИСЕЙ ВХОДИМОСТИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure INCL_MAKE(
          nCOMPANY             in number, -- Организация
          nPRN                 in number  -- Регистрационный номер родителя
          );

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ФОРМИРОВАНИЕ ЗАПИСЕЙ ВХОДИМОСТИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28 после создания спецификации
---------------------------------------------------------------------------------------------------
procedure PRODLST_INCL
(
  nCOMPANY in number, -- организация
  nRN      in number -- рег.номер спецификации
);

end UDO_PKG_SHEETD28_BASE;
/
create or replace package body UDO_PKG_SHEETD28_BASE is

-----------------------------------------------------------------------------------------
-- ПОИСК ЗАПИСИ ВЕДОМОСТИ Д28 ПО НОМЕРУ
-----------------------------------------------------------------------------------------
procedure FIND_DOC_NUMB(
          nFLAG_SMART          in number,    -- Признак генерации исключения (0 - да, 1 - нет)
          nFLAG_OPTION         in number,    -- Признак генерации исключения для пустого номера (0 - да, 1 - нет)
          nCOMPANY             in number,    -- Организация
          nDOCTYPE             in number,    -- Тип документа
          sDOCPREF             in varchar2,  -- Префикс номера
          sDOCNUMB             in varchar2,  -- Номер
          dDOCDATE             in date,      -- Дата документа
          nRN                  out number
          ) as
  nJPERS        number;
  nDOCYEAR      number;
begin

  /* номер не задан */
  if ( rtrim(nDOCTYPE) is null or rtrim(sDOCNUMB) is null ) then

    /* обязательно */
    if ( nFLAG_OPTION = 0 ) then
      P_EXCEPTION( nFLAG_SMART,'Ведомость Д28 '||PKG_DOCUMENT.MAKE_NUMBER( nDOCTYPE, sDOCPREF, sDOCNUMB )||' не определена.' );
    end if;

  /* номер задан */
  else
    /* учет настройки уникальности */
    PKG_DOCUMENT.CORRECT_UNIQ_FIELDS( nCOMPANY, 'UdoSheetD28_UniqMode', null, dDOCDATE, nJPERS, nDOCYEAR );

    /* поиск записи */
    begin
      select t.rn
        into nRN
        from udo_sheetd28 t
       where t.company = nCOMPANY
         and t.docyear = nDOCYEAR
         and t.doctype = nDOCTYPE
         and t.docpref = strright( strtrim( sDOCPREF ),80 )
         and t.docnumb = strright( strtrim( sDOCNUMB ),80 );
    exception
      when NO_DATA_FOUND then
           p_exception( nFLAG_SMART, 'Ведомость Д28 '||PKG_DOCUMENT.MAKE_NUMBER( nDOCTYPE,sDOCPREF,sDOCNUMB )||' не определена.' );
    end;
  end if;
end FIND_DOC_NUMB;

---------------------------------------------------------------------------------------------------
-- СЧИТЫВАНИЕ ЗАПИСИ ВЕДОМОСТИ Д28 (РАСШИРЕННОЕ)
---------------------------------------------------------------------------------------------------
procedure DOC_EXISTS_EX(
          nRN                  in number, -- Регистрационный номер записи
          rREC                 in out nocopy udo_sheetd28%rowtype,
          bFOR_UPDATE          in boolean default false, -- признак блокировки записи
          bRAISE_NOT_FOUND     in boolean default true   -- признак генерации исключения при отсутствии записи
          ) is
begin
  /* поиск записи */
  begin
    if ( bFOR_UPDATE ) then
      select t.*
        into rREC
        from udo_sheetd28 t
        where t.RN = nRN
        for update;
    else
      select t.*
        into rREC
        from udo_sheetd28 t
        where t.RN = nRN;
    end if;
  exception
    when NO_DATA_FOUND then
      if ( bRAISE_NOT_FOUND ) then
        PKG_MSG.RECORD_NOT_FOUND( nRN, 'UdoSheetD28' );
      else
        rREC := null;
      end if;
  end;
  
end DOC_EXISTS_EX;

---------------------------------------------------------------------------------------------------
-- СЧИТЫВАНИЕ ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_EXISTS(
          nRN                  in number,  -- Регистрационный номер
          nCOMPANY             in number,  -- Организация
          nCRN                 out number, -- Каталог
          nJUR_PERS            out number  -- Юридическое лицо
          ) is
begin
  /* поиск записи */
  begin
    select t.CRN, t.JUR_PERS
      into nCRN, nJUR_PERS
      from udo_sheetd28 t
     where t.RN      = nRN
       and t.COMPANY = nCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND( nRN,'UdoSheetD28' );
  end;
end DOC_EXISTS;

---------------------------------------------------------------------------------------------------
-- ГЕНЕРАЦИЯ СЛЕДУЮЩЕГО НОМЕРА ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_GETNEXTNUMB(
          nCOMPANY             in number,   -- Организация
          nJUR_PERS            in number,   -- Юридическое лицо
          dDOCDATE             in date,     -- Дата документа
          nDOCTYPE             in number,   -- Тип документа
          sDOCPREF             in varchar2, -- Префикс
          sDOCNUMB             out varchar2 -- Номер документа
          ) is
begin

  PKG_DOCUMENT.NEXT_NUMBER(
      nCOMPANY        => nCOMPANY,
      nFLD_SIZE       => 80,
      sUK_OPTION      => 'UdoSheetD28_UniqMode',
      sSEC_TBL        => 'UDO_SHEETD28',
      sSEC_JPRS_FLD   => 'JPERS',
      sSEC_YEAR_FLD   => 'DOCYEAR',
      sSEC_TYPE_FLD   => 'DOCTYPE',
      sSEC_PREF_FLD   => 'DOCPREF',
      sSEC_NUMB_FLD   => 'DOCNUMB',
      sBUF_TBL        => null,
      sBUF_IDENT_FLD  => null,
      sBUF_JPRS_FLD   => null,
      sBUF_YEAR_FLD   => null,
      sBUF_TYPE_FLD   => null,
      sBUF_PREF_FLD   => null,
      sBUF_NUMB_FLD   => null,
      nIDENT          => null,
      nJUR_PERS       => nJUR_PERS,
      nYEAR           => D_YEAR(dDOCDATE),
      nTYPE           => nDOCTYPE,
      sPREF           => sDOCPREF,
      sNUMB           => sDOCNUMB
      );

end DOC_GETNEXTNUMB;

---------------------------------------------------------------------------------------------------
-- ПАРАМЕТРЫ ПО УМОЛЧАНИЮ ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_DEFAULT(
          rREC                 in out udo_sheetd28%rowtype, -- Запись
          bUSE_OPTIONS         in boolean  default false    -- Использовать значения из настроек пользователя
          ) is
  bUSE_OPTIONS_   boolean := nvl(bUSE_OPTIONS, false);
  sTMP            PKG_STD.tSTRING;
begin

  /* Определяем каталог */
  if rREC.Crn is null then
    /* Из настроек */
    if bUSE_OPTIONS_ then
        rREC.Crn := UDO_F_GET_OPTIONS_RN(1, 'UdoSheetD28_Catalog', rREC.Company);
    end if;
    /* Корневой каталог */
    if rREC.Crn is null then
      FIND_ROOT_CATALOG(rREC.Company, 'UdoSheetD28', rREC.Crn);
    end if;
  end if;

  /* Юридическое лицо */
  if rREC.Jur_Pers is null then
    /* Из настроек */
    if bUSE_OPTIONS_ then
        rREC.Jur_Pers := UDO_F_GET_OPTIONS_RN(1, 'JuridicalPerson', rREC.Company);
    end if;
    /* Главная */
    if rREC.Jur_Pers is null then
      FIND_JURPERSONS_MAIN(1, rREC.Company, sTMP, rREC.Jur_Pers);
    end if;
  end if;

  /* Тип документа */
  if rREC.DocType is null then
    /* Из настроек */
    if bUSE_OPTIONS_ then
        rREC.DocType := UDO_F_GET_OPTIONS_RN(1, 'UdoSheetD28_DocType', rREC.Company);
    end if;
  end if;

  /* Дата документа*/
  if rREC.DocDate is null then
    rREC.DocDate := trunc(sysdate);
  end if;

  /* Префикс докцумента */
  if rREC.DocPref is null then
    /* Из настроек */
    if bUSE_OPTIONS_ then
        rREC.DocPref := GET_OPTIONS_STR('UdoSheetD28_DocPref', rREC.Company);
    end if;
  end if;

  /* Номер документа */
  if rREC.DocNumb is null then
    if rREC.DocType is not null and rREC.DocDate is not null then
      DOC_GETNEXTNUMB(
          nCOMPANY  => rREC.Company,
          nJUR_PERS => rREC.Jur_Pers,
          dDOCDATE  => rREC.DocDate,
          nDOCTYPE  => rREC.DocType,
          sDOCPREF  => rREC.DocPref,
          sDOCNUMB  => rREC.DocNumb
          );
    end if;
  end if;

  /* Состояние */
  if rREC.State is null then
    rREC.State := 0;
  end if;

end DOC_DEFAULT;

---------------------------------------------------------------------------------------------------
-- ПРОВЕРКА ПРЕФИКСА НОМЕРА ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_CHECK_PREF(
          nCOMPANY             in number,       -- Организация
          sDOCPREF             in out varchar2, -- Префикс
          nSIGN_OPTION         in number default 0 -- Использовать значение из настроек системы
          ) is
begin
  /* считывание настройки */
  if ( nSIGN_OPTION = 1 ) then
    sDOCPREF := GET_OPTIONS_STR('UdoSheetD28_DocPref', nCOMPANY);
  end if;

  /* проверка */
  if ( rtrim(sDOCPREF) is null ) and ( GET_OPTIONS_NUM('UdoSheetD28_PrefRequired', nCOMPANY) = 1 ) then
    if ( nSIGN_OPTION = 1 ) then
      P_EXCEPTION(0, 'В настройках системы не определен префикс ведомости Д28 по умолчанию.');
    else
      P_EXCEPTION(0, 'Задание префикса номера ведомости Д28 обязательно.');
    end if;
  end if;
end DOC_CHECK_PREF;

---------------------------------------------------------------------------------------------------
-- ПРОВЕРКА ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_CHECK(
          sMODE                in char, -- I-добавление, U-исправление, D-удаление, S-Изменение состояния
          rREC                 in udo_sheetd28%rowtype -- Запись
          ) is
  rCUR_DOC udo_sheetd28%rowtype; -- Текущая запись
  nRESULT  number;
begin

  if sMODE <> 'I' then
      -- Считывание записи
      DOC_EXISTS_EX(rREC.Rn, rCUR_DOC);
  end if;

  if sMODE in ('U','D') and rCUR_DOC.State <> 0 then
      p_exception(0, 'Изменение или удаление ведомости Д28 в состоянии отличном от "Не утвержден" недопустимо.');
  end if;

  /* проверка */
  if sMODE in ('I','U') then
    if ( rtrim(rREC.DocPref) is null ) and ( GET_OPTIONS_NUM('UdoSheetD28_PrefRequired', rREC.Company) = 1 ) then
      p_exception(0, 'Задание префикса номера ведомости Д28 обязательно.');
    end if;
  end if;

  if sMODE = 'U' then
    if cmp_num(rREC.Matres, rCUR_DOC.Matres) = 0 then
      select count(t.rn)
        into nRESULT
        from udo_sheetd28sp t
        where t.prn = rREC.Rn
          and rownum = 1;
      if nRESULT > 0 then
          p_exception(0, 'Смена изделия ведомости Д28 с заполненной спецификацией запрещена.');
      end if;
    end if;
  end if;

  if sMODE in ('I','U') then
    /* наличие спецификации */
    select count(t.rn)
      into nRESULT
      from FCPRODLST t
      where t.company = rREC.Company
        and t.mtr_res = rREC.Matres
        and ROWNUM    = 1;

    if nRESULT = 0 then
      p_exception(0, 'Для изделия "%s" спецификация не определена. Добавление ведомости Д28 невозможно.',
                     F_FCMATRESOURCE_GET_NOMENMODIF(rREC.Company, rREC.Matres) );
    end if;
  end if;

  /* Пользовательские расширения */
  if ( PROCEDURE_EXISTS('UDO_P_SHEETD28_PRECHECK') <> 0 ) then
    execute immediate PKG_SQL_CALL.MAKE_STORED('UDO_P_SHEETD28_PRECHECK')
            using in sMODE, in rREC.Rn, in rREC.Company;
  end if;

end DOC_CHECK;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ДОБАВЛЕНИЕ ЗАПИСИ ВЕДОМОСТИ Д28 (РАСШИРЕННОЕ)
---------------------------------------------------------------------------------------------------
procedure DOC_INSERT_EX(
          rREC                 in out nocopy udo_sheetd28%rowtype -- Запись
          ) is
begin

  /* Заполнение параметров по умолчанию */
  DOC_DEFAULT(rREC, false);

  -- Проверка
  DOC_CHECK('I', rREC);

  --Добавление записи
  rREC.Rn := gen_id;
  insert into udo_sheetd28 values rREC;

end DOC_INSERT_EX;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ДОБАВЛЕНИЕ ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_INSERT(
          nCOMPANY             in number,   -- Организация
          nCRN                 in number,   -- Каталог
          nJUR_PERS            in number,   -- Юридическое лицо
          nDOCTYPE             in number,   -- Тип документа
          sDOCPREF             in varchar2, -- Префикс документа
          sDOCNUMB             in varchar2, -- Номер документа
          dDOCDATE             in date,     -- Дата документа
          sEXT_NUMBER          in varchar2, -- Внешний номер
          nSUBDIV              in number,   -- Подразделение
          nRESPONSIBLE         in number,   -- Ответственный
          nMATRES              in number,   -- Изделие
          sNOTE                in varchar2, -- Примечание
          sBARCODE             in varchar2, -- Штрих-код
          nRN                  out number   -- Регистрационный номер записи
          ) is
  rREC udo_sheetd28%rowtype; -- Запись
begin

  -- Параметры записи
  rREC.Company       := nCOMPANY;
  rREC.Crn           := nCRN;
  rREC.Jur_Pers      := nJUR_PERS;
  rREC.DocType       := nDOCTYPE;
  rREC.DocDate       := trunc(dDOCDATE);
  rREC.DocPref       := trim(sDOCPREF);
  
  if ( rtrim(sDOCNUMB) is null ) and ( GET_OPTIONS_NUM('UdoSheetD28_AutoNumb', nCOMPANY) = 1 ) then
    /* генерация следующего номера */
    DOC_GETNEXTNUMB(nCOMPANY, nJUR_PERS, dDOCDATE, nDOCTYPE, rREC.DocPref, rREC.DocNumb);
  else
    rREC.DocNumb     := trim(sDOCNUMB);
  end if;

  rREC.Ext_Number    := sEXT_NUMBER;
  rREC.State         := 0;
  rREC.Subdiv        := nSUBDIV;
  rREC.Responsible   := nRESPONSIBLE;
  rREC.Matres        := nMATRES;
  rREC.Note          := sNOTE;
  rREC.Barcode       := sBARCODE;
  rREC.DocYear       := 0;

  -- Базовое добавление записи
  DOC_INSERT_EX(rREC);

  -- Возвращаем результат
  nRN := rREC.Rn;

end DOC_INSERT;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ИСПРАВЛЕНИЕ ЗАПИСИ ВЕДОМОСТИ Д28 (РАСШИРЕННОЕ)
---------------------------------------------------------------------------------------------------
procedure DOC_UPDATE_EX(
          rREC                 in out nocopy udo_sheetd28%rowtype -- Запись
          ) is
begin

  /* Заполнение параметров по умолчанию */
  DOC_DEFAULT(rREC, false);

  -- Проверка возможности исправления
  DOC_CHECK('U', rREC);

  -- Исправление записи
  update udo_sheetd28 t
         set t.company        = rREC.Company,
             t.jur_pers       = rREC.Jur_Pers,
             t.doctype        = rREC.DocType,
             t.docpref        = rREC.DocPref,
             t.docnumb        = rREC.DocNumb,
             t.docdate        = rREC.DocDate,
             t.ext_number     = rREC.Ext_Number,
             t.subdiv         = rREC.Subdiv,
             t.responsible    = rREC.Responsible,
             t.matres         = rREC.Matres,
             t.note           = rREC.Note,
             t.barcode        = rREC.Barcode
         where t.rn = rREC.Rn;
  if SQL%NOTFOUND then
      PKG_MSG.RECORD_NOT_FOUND(rREC.Rn, 'UdoSheetD28');
  end if;

end DOC_UPDATE_EX;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ИСПРАВЛЕНИЕ ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_UPDATE(
          nRN                  in number,   -- Регистрационный номер записи
          nCOMPANY             in number,   -- Организация
          nJUR_PERS            in number,   -- Юридическое лицо
          nDOCTYPE             in number,   -- Тип документа
          sDOCPREF             in varchar2, -- Префикс документа
          sDOCNUMB             in varchar2, -- Номер документа
          dDOCDATE             in date,     -- Дата документа
          sEXT_NUMBER          in varchar2, -- Внешний номер
          nSUBDIV              in number,   -- Подразделение
          nRESPONSIBLE         in number,   -- Ответственный
          nMATRES              in number,   -- Изделие
          sNOTE                in varchar2, -- Примечание
          sBARCODE             in varchar2  -- Штрих-код
          ) is
  rREC udo_sheetd28%rowtype; -- Запись
begin

  -- Считывание записи
  DOC_EXISTS_EX(nRN, rREC);

  -- Параметры записи
  rREC.Jur_Pers      := nJUR_PERS;
  rREC.DocType       := nDOCTYPE;
  rREC.DocPref       := trim(sDOCPREF);
  rREC.DocNumb       := trim(sDOCNUMB);
  rREC.DocDate       := trunc(dDOCDATE);
  rREC.Ext_Number    := sEXT_NUMBER;
  rREC.Subdiv        := nSUBDIV;
  rREC.Responsible   := nRESPONSIBLE;
  rREC.Matres        := nMATRES;
  rREC.Note          := sNOTE;
  rREC.Barcode       := sBARCODE;

  -- Исправление записи
  DOC_UPDATE_EX(rREC);

end DOC_UPDATE;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ УДАЛЕНИЕ ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_DELETE(
          nRN                  in number, -- Регистрационный номер
          nCOMPANY             in number  -- Организация
          ) is
  rREC udo_sheetd28%rowtype; -- Запись
begin

  -- Считывание записи
  DOC_EXISTS_EX(nRN, rREC);

  -- Проверка
  DOC_CHECK('D', rREC);

  -- Удаление записи
  delete from udo_sheetd28 t
         where t.rn      = nRN
           and t.company = nCOMPANY;
  if SQL%NOTFOUND then
      PKG_MSG.RECORD_NOT_FOUND(rREC.Rn, 'UdoSheetD28');
  end if;

end DOC_DELETE;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ УСТАНОВКА СОСТОЯНИЯ ЗАПИСИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure DOC_SETSTATE(
          nRN                  in number, -- Регистрационный номер
          nSTATE               in number, -- Состояние: 0-Не утвержден; 1-Утвержден;
          dSTATE_DATE          in date,   -- Дата изменения состояния
          nSIGN_USEDOCDATE     in number default 0
          ) is
  rREC udo_sheetd28%rowtype; -- Запись
begin

  -- Считывание записи
  DOC_EXISTS_EX(nRN, rREC);

  -- Проверка состояния
  if cmp_num(nSTATE, rREC.State) = 1 then
      return;
  end if;    

  -- Установка параметров
  rREC.State := nSTATE;
  rREC.State_Date := case when nvl(nSIGN_USEDOCDATE,0) = 1 then rREC.DocDate else dSTATE_DATE end;

  -- Проверка
  DOC_CHECK('S', rREC);

  -- Установка нового состояния
  update udo_sheetd28 t
         set t.state      = rREC.State,
             t.state_date = rREC.State_Date
         where t.rn = rREC.Rn;
  if SQL%NOTFOUND then
      PKG_MSG.RECORD_NOT_FOUND(rREC.Rn, 'UdoSheetD28');
  end if;

end DOC_SETSTATE;

---------------------------------------------------------------------------------------------------
-- СЧИТЫВАНИЕ ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28 (РАСШИРЕННОЕ)
---------------------------------------------------------------------------------------------------
procedure SPEC_EXISTS_EX(
          nRN                  in number, -- Регистрационный номер записи
          rREC                 in out nocopy udo_sheetd28sp%rowtype, -- Запись
          bFOR_UPDATE          in boolean default false, -- Признак блокировки записи
          bRAISE_NOT_FOUND     in boolean default true   -- Признак генерации исключения при отсутствии записи
          ) as
begin

  /* поиск записи */
  begin
      if bFOR_UPDATE then
          select t.*
            into rREC
            from udo_sheetd28sp t
            where t.rn = nRN
            for update;
      else
          select t.*
            into rREC
            from udo_sheetd28sp t
            where t.rn = nRN;
      end if;
  exception
    when NO_DATA_FOUND then
      if ( bRAISE_NOT_FOUND ) then
          PKG_MSG.RECORD_NOT_FOUND( nRN, 'UdoSheetD28Specs' );
      else
          rREC := null;
      end if;
  end;
  
end SPEC_EXISTS_EX;

---------------------------------------------------------------------------------------------------
-- СЧИТЫВАНИЕ ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_EXISTS(
          nRN                  in number,   -- Регистрационный номер записи
          nCOMPANY             in number,   -- Организация
          nPRN                 out number,  -- Регистрационный номер родителя
          nCRN                 out number,  -- Каталог
          nJUR_PERS            out number   -- Юридическое лицо
          ) is
begin
  /* поиск записи */
  begin
    select t.prn, t.CRN, t.jur_pers
      into nPRN, nCRN, nJUR_PERS
      from udo_sheetd28sp t
     where t.RN      = nRN
       and t.COMPANY = nCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND( nRN,'UdoSheetD28Specs' );
  end;

end SPEC_EXISTS;

---------------------------------------------------------------------------------------------------
-- ПРОВЕРКА КОМПЛЕКТУЮЩЕЙ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_CHECK_COMPLETE(
          nFLAG_SMART          in number,   -- Признак генерации исключения (0 - да, 1 - нет)
          nCOMPANY             in number,   -- Организация
          nMATRES              in number,   -- Изделие
          nCOMPLETE            in number,   -- Комплектующая
          nRESULT              out number,  -- Является комплектующей (0 - нет, 1 - да)
          nSUBDIV              in number default null  -- подразделение-исполнитель
          ) is
--  nCUR_MATRES       PKG_STD.tREF; -- Текущее изделие
--  nCUR_COMPLETE     PKG_STD.tREF; -- Текущая комплектующая
  PRODLST           PKG_STD.tREF; -- Спецификация изделия
begin

  /* Поиск  */
  FIND_FCPRODLST_MATRES(
    nFLAG_SMART   => 1,      -- признак генерации исключения (0 - да, 1 - нет)
    nFLAG_OPTION  => 1,      -- признак генерации исключения для пустого sCODE (0 - да, 1 - нет)
    nCOMPANY      => nCOMPANY,
    nMATRES       => nMATRES,
    sNOMEN        => null,
    sMODIF        => null,
    nRN           => PRODLST,
    nSUBDIV       => nSUBDIV
    );

    begin
      with tDATA as (
        select ts.rn           as RN,
               t.mtr_res       as MATRES,
               t.rn            as HRN,
               ts.numb         as NUMB,
               ts.position     as POSITION,
               ts.complete     as COMPLETE,
               ts.annul        as ANNUL,     -- Признак "Аннулирована"
               ts.prod_sign    as PROD_SIGN, -- Признак (0-собственного изготовления; 1-покупное; 2-по кооперации; 3-отходы)
               ts.quant        as QUANT
           from FCPRODLST t,
                FCPRODLSTSP ts
           where ts.prn = t.rn
        )
      select count (w.rn)
        into nRESULT
        from tDATA w
        where w.complete = nCOMPLETE
          --and w.quant > 0
          --and ( w.prod_sign = 1 or (w.prod_sign = 0 and CONNECT_BY_ISLEAF = 1))
          and rownum = 1
        connect by prior w.complete = w.matres
        start with w.HRN = PRODLST;
    exception
      when NO_DATA_FOUND then nRESULT := 0;
    end;

  if nvl(nRESULT,0) = 0 and nFLAG_SMART = 0 then
    p_exception(nFLAG_SMART, 'Материальный ресурс "%s" не является комплектующей изделия "%s".',
                             F_FCMATRESOURCE_GET_NOMENMODIF(nCOMPANY, nCOMPLETE),
                             F_FCMATRESOURCE_GET_NOMENMODIF(nCOMPANY, nMATRES)
                             );
  end if;

end SPEC_CHECK_COMPLETE;

---------------------------------------------------------------------------------------------------
-- ПРОВЕРКА ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_CHECK(
          sMODE                in char, -- I-добавление, U-исправление, D-удаление, S-Изменение состояния
          rREC                 in udo_sheetd28sp%rowtype, -- Запись
          bFULLCHECK           in boolean default true      -- 
          ) is
  bFULLCHECK_     boolean := nvl(bFULLCHECK, true);
  rDOC            udo_sheetd28%rowtype;   -- Текущая запись
  rOLD            udo_sheetd28sp%rowtype; -- Текущая запись
  nTMP            number;
begin

  if sMODE <> 'I' then
      -- Считывание записи
      SPEC_EXISTS_EX(rREC.Rn, rOLD);
  end if;

  if bFULLCHECK_ then
    /* Считывание записи родителя */
    DOC_EXISTS_EX(rREC.Prn, rDOC);

    if sMODE in ('I','U','D') and rDOC.State <> 0 then
        p_exception(0, 'Изменение или удаление спецификации ведомости Д28 в состоянии отличном от "Не утвержден" недопустимо.');
    end if;

    /* проверка */
    if sMODE in ('I','U') then
      /* Проверка комплектующей */
      SPEC_CHECK_COMPLETE(0, rREC.Company, rDOC.Matres, rREC.Matres, nTMP);
    end if;

  end if;

  /* проверка */
  if sMODE in ('I','U') then
    null;
  end if;

end SPEC_CHECK;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ДОБАВЛЕНИЕ ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28 (РАСШИРЕННОЕ)
---------------------------------------------------------------------------------------------------
procedure SPEC_INSERT_EX(
          rREC                 in out nocopy udo_sheetd28sp%rowtype, -- Запись
          bFULLCHECK           in boolean default true
          ) is
begin

  -- Проверка
  SPEC_CHECK('I', rREC, bFULLCHECK);

  --Добавление записи
  rREC.Rn := gen_id;
  insert into udo_sheetd28sp values rREC;

end SPEC_INSERT_EX;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ДОБАВЛЕНИЕ ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_INSERT(
          nCOMPANY             in number,    -- Организация
          nPRN                 in number,    -- Регистрационный номер родителя
          nMATRES              in number,    -- Материальный ресурс
          nMATRES_DIFF         in number,    -- Материальный ресурс замены
          sNOTE                in varchar2,  -- Примечание
          nRN                  out number    -- Регистрационный номер
          ) is
  rREC udo_sheetd28sp%rowtype; -- Запись
begin
  /* Считывание записи родителя */
  DOC_EXISTS(nPRN, nCOMPANY, rREC.Crn, rREC.Jur_Pers);
  
  /* Установка параметров */
  rREC.Prn         := nPRN;
  rREC.Company     := nCOMPANY;
  rREC.Matres      := nMATRES;
  rREC.Matres_Diff := nMATRES_DIFF;
  rREC.Note        := sNOTE;
  
  -- Базовое добавление записи
  SPEC_INSERT_EX(rREC);

  -- Возвращаем результат
  nRN := rREC.Rn;

  /* Формирование входимостей */
  INCL_MAKE(nCOMPANY, nRN);

end SPEC_INSERT;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ИСПРАВЛЕНИЕ ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28 (РАСШИРЕННОЕ)
---------------------------------------------------------------------------------------------------
procedure SPEC_UPDATE_EX(
          rREC                 in out nocopy udo_sheetd28sp%rowtype, -- Запись требования платежа
          bFULLCHECK           in boolean default true      -- 
          ) is
begin

  -- Проверка
  SPEC_CHECK('U', rREC, bFULLCHECK);

  -- Исправление записи
  update udo_sheetd28sp t
         set t.matres      = rREC.Matres,
             t.matres_diff = rREC.Matres_Diff,
             t.note        = rREC.Note
         where t.rn = rREC.Rn;
  if SQL%NOTFOUND then
      PKG_MSG.RECORD_NOT_FOUND(rREC.Rn, 'UdoSheetD28Specs');
  end if;

end SPEC_UPDATE_EX;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ИСПРАВЛЕНИЕ ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_UPDATE(
          nRN                  in number,    -- Регистрационный номер
          nCOMPANY             in number,    -- Организация
          nMATRES              in number,    -- Материальный ресурс
          nMATRES_DIFF         in number,    -- Материальный ресурс замены
          sNOTE                in varchar2   -- Примечание
          ) is
  rREC              udo_sheetd28sp%rowtype; -- Запись
  bSIGN_INCL        boolean; -- Признак обновления входимостей
begin
  /* Считывание записи родителя */
  SPEC_EXISTS_EX(nRN, rREC);

  bSIGN_INCL := ( cmp_num(rREC.Matres, nMATRES) = 0 );

  /* Установка параметров */
  rREC.Matres      := nMATRES;
  rREC.Matres_Diff := nMATRES_DIFF;
  rREC.Note        := sNOTE;

  -- Базовое исправление записи
  SPEC_UPDATE_EX(rREC);

  /* Переформирование входимостей */
  if bSIGN_INCL then
    INCL_MAKE(nCOMPANY, nRN);
  end if;

end SPEC_UPDATE;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ УДАЛЕНИЕ ЗАПИСИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_DELETE(
          nRN                  in number, -- Регистрационный номер
          nCOMPANY             in number  -- Организация
          ) is
  rREC udo_sheetd28sp%rowtype; -- Запись
begin

  -- Считывание записи
  SPEC_EXISTS_EX(nRN, rREC);

  -- Проверка
  SPEC_CHECK('D', rREC);

  -- Удаление записи
  delete from udo_sheetd28sp t
         where t.rn      = nRN
           and t.company = nCOMPANY;
  if SQL%NOTFOUND then
      PKG_MSG.RECORD_NOT_FOUND(rREC.Rn, 'UdoSheetD28Specs');
  end if;

end SPEC_DELETE;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ФОРМИРОВАНИЕ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure SPEC_MAKE(
          nCOMPANY             in number,
          nPRN                 in number
          ) is
  rDOC     udo_sheetd28%rowtype; -- Запись
  rSPEC    udo_sheetd28sp%rowtype; -- Запись
  nPRODLST number;
  nRESULT  number;
begin

  /* Считывание записи */
  DOC_EXISTS_EX(nPRN, rDOC);

  if rDOC.State <> 0 then
      p_exception(0, 'Формирование спецификации ведомости Д28 в состоянии отличном от "Не утвержден" недопустимо.');
  end if;

  /* спецификация */
  FIND_FCPRODLST_MATRES(
      nFLAG_SMART   => 0,
      nFLAG_OPTION  => 0,
      nCOMPANY      => nCOMPANY,
      nMATRES       => rDOC.Matres,
      sNOMEN        => null,
      sMODIF        => null,
      nRN           => nPRODLST,
      nSUBDIV       => null  -- подразделение-исполнитель
      );

  for rec in (
      with tDATA as (
        select ts.rn           as RN,
               t.mtr_res       as MATRES,
               t.rn            as HRN,
               ts.numb         as NUMB,
               ts.position     as POSITION,
               ts.complete     as COMPLETE,
               ts.annul        as ANNUL,     -- Признак "Аннулирована"
               ts.prod_sign    as PROD_SIGN, -- Признак (0-собственного изготовления; 1-покупное; 2-по кооперации; 3-отходы)
               ts.quant        as QUANT
           from FCPRODLST t,
                FCPRODLSTSP ts
           where ts.prn = t.rn
        )
      select w.*
        from tDATA w
        where w.quant > 0
          and ( w.prod_sign = 1 or (w.prod_sign = 0 and CONNECT_BY_ISLEAF = 1))
          and not exists(select null from udo_sheetd28sp s where s.prn = nPRN and s.matres = w.complete)
        connect by prior w.complete = w.matres
        start with w.HRN = nPRODLST
      ) loop

      nRESULT := null;
      begin
        select s.rn
          into nRESULT
          from udo_sheetd28sp s
          where s.prn = nPRN
            and s.matres = rec.complete;
      exception when NO_DATA_FOUND then null;
      end;

      if nRESULT is null then
        rSPEC := null;
        rSPEC.Prn      := nPRN;
        rSPEC.Company  := nCOMPANY;
        rSPEC.Crn      := rDOC.Crn;
        rSPEC.Jur_Pers := rDOC.Jur_Pers;
        rSPEC.Matres   := rec.complete;

        -- Добавление строки спецификации
        SPEC_INSERT_EX(rSPEC, false);

        /* Формирование входимостей */
        INCL_MAKE(nCOMPANY, rSPEC.Rn);
      end if;
  end loop;

end SPEC_MAKE;

---------------------------------------------------------------------------------------------------
-- СЧИТЫВАНИЕ ЗАПИСИ ВХОДИМОСТИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28 (РАСШИРЕННОЕ)
---------------------------------------------------------------------------------------------------
procedure INCL_EXISTS_EX(
          nRN                  in number, -- Регистрационный номер записи
          rREC                 in out nocopy udo_sheetd28spinc%rowtype, -- Запись
          bFOR_UPDATE          in boolean default false, -- Признак блокировки записи
          bRAISE_NOT_FOUND     in boolean default true   -- Признак генерации исключения при отсутствии записи
          ) as
begin

  /* поиск записи */
  begin
      if bFOR_UPDATE then
          select t.*
            into rREC
            from udo_sheetd28spinc t
            where t.rn = nRN
            for update;
      else
          select t.*
            into rREC
            from udo_sheetd28spinc t
            where t.rn = nRN;
      end if;
  exception
    when NO_DATA_FOUND then
      if ( bRAISE_NOT_FOUND ) then
          PKG_MSG.RECORD_NOT_FOUND( nRN, 'UdoSheetD28SpecsInclusion' );
      else
          rREC := null;
      end if;
  end;
  
end INCL_EXISTS_EX;

---------------------------------------------------------------------------------------------------
-- СЧИТЫВАНИЕ ЗАПИСИ ВХОДИМОСТИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure INCL_EXISTS(
          nRN                  in number,   -- Регистрационный номер записи
          nCOMPANY             in number,   -- Организация
          nPRN                 out number,  -- Регистрационный номер родителя
          nCRN                 out number,  -- Каталог
          nJUR_PERS            out number   -- Юридическое лицо
          ) is
begin
  /* поиск записи */
  begin
    select t.prn, t.CRN, t.jur_pers
      into nPRN, nCRN, nJUR_PERS
      from udo_sheetd28spinc t
     where t.RN      = nRN
       and t.COMPANY = nCOMPANY;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND( nRN,'UdoSheetD28SpecsInclusion' );
  end;

end INCL_EXISTS;

---------------------------------------------------------------------------------------------------
-- ПРОВЕРКА ЗАПИСИ ВХОДИМОСТИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure INCL_CHECK(
          sMODE                in char,   -- I-добавление, U-исправление, D-удаление, S-Изменение состояния
          nPRN                 in number  -- Регистрационный номер родителя
          ) is
  rDOC            udo_sheetd28%rowtype;      -- Запись заголовка
  rSPEC           udo_sheetd28sp%rowtype;    -- Запись спецификации
begin

  /* Считывание записи родителя */
  SPEC_EXISTS_EX(nPRN, rSPEC);
  DOC_EXISTS_EX(rSPEC.Prn, rDOC);

  if sMODE in ('I','U','D') and rDOC.State <> 0 then
      p_exception(0, 'Изменение или удаление входимости спецификации ведомости Д28 в состоянии отличном от "Не утвержден" недопустимо.');
  end if;

  /* проверка */
  if sMODE in ('I','U') then
    null;
  end if;

end INCL_CHECK;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ДОБАВЛЕНИЕ ЗАПИСИ ВХОДИМОСТИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28 (РАСШИРЕННОЕ)
---------------------------------------------------------------------------------------------------
procedure INCL_INSERT_EX(
          rREC                 in out nocopy udo_sheetd28spinc%rowtype -- Запись
          ) is
begin

  -- Проверка
  INCL_CHECK('I', rREC.Prn);

  --Добавление записи
  rREC.Rn := gen_id;
  insert into udo_sheetd28spinc values rREC;

end INCL_INSERT_EX;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ДОБАВЛЕНИЕ ЗАПИСИ ВХОДИМОСТИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure INCL_INSERT(
          nCOMPANY             in number,    -- Организация
          nPRN                 in number,    -- Регистрационный номер родителя
          nPRODLSTSP           in number,    -- Строка спецификации изделия
          nRN                  out number    -- Регистрационный номер
          ) is
  rREC  udo_sheetd28spinc%rowtype; -- Запись
  nDOC  number;
begin
  /* Считывание записи родителя */
  SPEC_EXISTS(nPRN, nCOMPANY, nDOC, rREC.Crn, rREC.Jur_Pers);
  
  /* Установка параметров */
  rREC.Prn         := nPRN;
  rREC.Company     := nCOMPANY;
  rREC.Prodlstsp   := nPRODLSTSP;

  -- Базовое добавление записи
  INCL_INSERT_EX(rREC);

  -- Возвращаем результат
  nRN := rREC.Rn;

end INCL_INSERT;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ УДАЛЕНИЕ ЗАПИСИ ВХОДИМОСТИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure INCL_DELETE(
          nRN                  in number, -- Регистрационный номер
          nCOMPANY             in number  -- Организация
          ) is
  rREC udo_sheetd28spinc%rowtype; -- Запись
begin

  -- Считывание записи
  INCL_EXISTS_EX(nRN, rREC);

  -- Проверка
  INCL_CHECK('D', rREC.Prn);

  -- Удаление записи
  delete from udo_sheetd28spinc t
         where t.rn      = nRN
           and t.company = nCOMPANY;
  if SQL%NOTFOUND then
      PKG_MSG.RECORD_NOT_FOUND(rREC.Rn, 'UdoSheetD28SpecsInclusion');
  end if;

end INCL_DELETE;

---------------------------------------------------------------------------------------------------
-- БАЗОВАЯ ОЧИСТКА ЗАПИСЕЙ ВХОДИМОСТИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure INCL_CLEAR(
          nCOMPANY             in number, -- Организация
          nPRN                 in number  -- Регистрационный номер родителя
          ) is
begin

  -- Проверка
  INCL_CHECK('D', nPRN);

  -- Удаление записи
  delete from udo_sheetd28spinc t
         where t.prn     = nPRN
           and t.company = nCOMPANY;

end INCL_CLEAR;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ФОРМИРОВАНИЕ ЗАПИСЕЙ ВХОДИМОСТИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28
---------------------------------------------------------------------------------------------------
procedure INCL_MAKE(
          nCOMPANY             in number, -- Организация
          nPRN                 in number  -- Регистрационный номер родителя
          ) is
  rREC            udo_sheetd28spinc%rowtype;  -- Запись
  rSPEC           udo_sheetd28sp%rowtype;     -- Запись спецификации
  rDOC            udo_sheetd28%rowtype;       -- Запись заголовка
  nPRODLST        PKG_STD.tREF;               -- Спецификация изделия
begin

  /* Считывание записи родителя */
  SPEC_EXISTS_EX(nPRN, rSPEC);
  DOC_EXISTS_EX(rSPEC.Prn, rDOC);

  -- Проверка
  INCL_CHECK('I', nPRN);

  -- Очистка вхождения
  INCL_CLEAR(nCOMPANY, nPRN);
  
  /* Поиск спецификации изделия */
  FIND_FCPRODLST_MATRES(
    nFLAG_SMART   => 1,      -- признак генерации исключения (0 - да, 1 - нет)
    nFLAG_OPTION  => 1,      -- признак генерации исключения для пустого sCODE (0 - да, 1 - нет)
    nCOMPANY      => nCOMPANY,
    nMATRES       => rDOC.Matres,
    sNOMEN        => null,
    sMODIF        => null,
    nRN           => nPRODLST,
    nSUBDIV       => null
    );

  for rec in (
      with tDATA as (
        select ts.rn           as RN,
               t.mtr_res       as MATRES,
               t.rn            as HRN,
               ts.numb         as NUMB,
               ts.position     as POSITION,
               ts.complete     as COMPLETE,
               ts.annul        as ANNUL,     -- Признак "Аннулирована"
               ts.prod_sign    as PROD_SIGN, -- Признак (0-собственного изготовления; 1-покупное; 2-по кооперации; 3-отходы)
               ts.quant        as QUANT
           from FCPRODLST t,
                FCPRODLSTSP ts
           where ts.prn = t.rn
        )
      select w.*
        from tDATA w
        where w.complete = rSPEC.Matres
          and w.quant > 0
          and ( w.prod_sign = 1 or (w.prod_sign = 0 and CONNECT_BY_ISLEAF = 1))
        connect by prior w.complete = w.matres
        start with w.HRN = nPRODLST
      ) loop 

      /* Установка параметров */
      rREC := null;
      rREC.Prn         := nPRN;
      rREC.Company     := nCOMPANY;
      rREC.Crn         := rSPEC.Crn;
      rREC.Jur_Pers    := rSPEC.Jur_Pers;
      rREC.Prodlstsp   := rec.rn;

      -- Базовое добавление записи
      INCL_INSERT_EX(rREC);

  end loop;

end INCL_MAKE;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ДОБАВЛЕНИЕ ЗАПИСИ связи СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28 и строки спецификации изделия
---------------------------------------------------------------------------------------------------
  procedure SPEC_LNK_INSERT
  (
    nLST_SP in number, -- рег.номер записи строки спецификации изделия
    nD28_SP in number, -- рег.номер записи спецификации Ведомости Д28
    nRN     out number -- рег.номер записи
  ) is
  begin
    -- проверки
    if nLST_SP is null then
      p_exception(0,
                  'Не указан рег.номер записи строки спецификации изделия.');
    end if;
    if nD28_SP is null then
      p_exception(0,
                  'Не указан рег.номер записи спецификации Ведомости Д28.');
    end if;
    -- добавление
    nRN := gen_id;
    insert into UDO_SHEETD28_SPEC_LNK(RN, PRODLSTSP_RN, SHEETD28SP_RN)
    values(nRN, nLST_SP, nD28_SP);
  end SPEC_LNK_INSERT;

---------------------------------------------------------------------------------------------------
-- БАЗОВОЕ ФОРМИРОВАНИЕ ЗАПИСЕЙ ВХОДИМОСТИ СПЕЦИФИКАЦИИ ВЕДОМОСТИ Д28 после создания спецификации
---------------------------------------------------------------------------------------------------
  procedure PRODLST_INCL
  (
    nCOMPANY in number, -- организация
    nRN      in number -- рег.номер спецификации
  ) as
    nCRN       PKG_STD.tREF;
    rFCPRODLST FCPRODLST%rowtype;
    nUSAGE     PKG_STD.tREF;
    rSHEETD28  UDO_SHEETD28%rowtype;
    nJUR_PERS  PKG_STD.tREF;
    sJUR_PERS  JURPERSONS.CODE%type;
    nTMP       PKG_STD.tREF;
    nD28SP     PKG_STD.tREF;
  begin
    -- спецификация
    rFCPRODLST := UDO_PKG_FCPRODLST_BASE.GET_PRODLST_ROW(nRN => nRN);

    -- сначала переформируем последнюю Применяемость для СЕ
    nUSAGE := to_number(null);
    for rsdg in (select USG.*
                   from FCUSAGE USG
                  where USG.MATRES = rFCPRODLST.Mtr_Res
                    and USG.COMPANY = nCOMPANY
                  order by USG.FORM_DATE desc) loop
      /* исправление применяемости */
      P_FCUSAGE_BASE_UPDATE(nRN        => rsdg.rn,
                            nCOMPANY   => rsdg.company,
                            nMATRES    => rsdg.matres,
                            dFORM_DATE => trunc(sysdate),
                            nPR_COND   => rsdg.pr_cond);
    
      /* удаление спецификации */
      for rSP in (select RN
                    from FCUSAGESP
                   where PRN = rsdg.RN
                     and HRN is null) loop
        /* базовое удаление спецификации */
        P_FCUSAGESP_BASE_DELETE(rSP.RN, nCOMPANY);
      end loop;
    
      /* базовая процедура формирования */
      P_FCUSAGE_BASE_MAKE(nCOMPANY   => rsdg.company,
                          nRN        => rsdg.rn,
                          nMATRES    => rsdg.matres,
                          dFORM_DATE => trunc(sysdate),
                          nPR_COND   => rsdg.pr_cond);
      nUSAGE := rsdg.rn;
      exit; -- достаточно последней
    end loop;
    -- Нет применяемости - сформируем
    if nUSAGE is null then
      -- корневой каталог
      FIND_ROOT_CATALOG(nCOMPANY => nCOMPANY, sCODE => 'CostUsage', nCRN => nCRN);
      /* базовая процедура добавления */
      P_FCUSAGE_BASE_INSERT(nCOMPANY   => nCOMPANY,
                            nCRN       => nCRN,
                            nMATRES    => rFCPRODLST.Mtr_Res,
                            dFORM_DATE => trunc(sysdate),
                            nPR_COND   => null,
                            nRN        => nUSAGE);
      /* базовая процедура формирования */
      P_FCUSAGE_BASE_MAKE(nCOMPANY   => nCOMPANY,
                          nRN        => nUSAGE,
                          nMATRES    => rFCPRODLST.Mtr_Res,
                          dFORM_DATE => trunc(sysdate),
                          nPR_COND   => null);
    end if;
    -- для каждого верхнего изделия добавим замену Д28
    FIND_JURPERSONS_MAIN(nFLAG_SMART => 0, nCOMPANY => nCOMPANY, sJUR_PERS => sJUR_PERS, nJUR_PERS => nJUR_PERS);
    for rSP in (select *
                  from FCUSAGESP
                 where PRN = nUSAGE
                   and HRN is null) loop
      -- ведомость Д28 для СЕ
      begin
        select D28.*
          into rSHEETD28
          from UDO_SHEETD28 D28
         where D28.MATRES = rSP.MATRES
           and D28.COMPANY = nCOMPANY
           and D28.JUR_PERS = nJUR_PERS;
      exception
        when no_data_found then
          -- добавим ведомость Д28
          rSHEETD28.Company := nCOMPANY;
          FIND_ROOT_CATALOG(nCOMPANY => nCOMPANY, sCODE => 'UdoSheetD28', nCRN => rSHEETD28.Crn);
          rSHEETD28.Jur_Pers := nJUR_PERS;
          rSHEETD28.Jpers    := 0;
          rSHEETD28.Doctype  := 77787542; -- Д28
          rSHEETD28.Docpref  := to_char(sysdate, 'yyyy');
          rSHEETD28.Docdate  := trunc(sysdate);
          rSHEETD28.Docyear  := 0;
          DOC_GETNEXTNUMB(nCOMPANY  => nCOMPANY,
                          nJUR_PERS => rSHEETD28.Jur_Pers,
                          dDOCDATE  => rSHEETD28.Docdate,
                          nDOCTYPE  => rSHEETD28.Doctype,
                          sDOCPREF  => rSHEETD28.Docpref,
                          sDOCNUMB  => rSHEETD28.Docnumb);
          --rSHEETD28.Ext_Number
          rSHEETD28.State      := 0;
          rSHEETD28.State_Date := rSHEETD28.Docdate;
          --rSHEETD28.Subdiv
          --rSHEETD28.Responsible
          rSHEETD28.Matres := rSP.MATRES;
          rSHEETD28.Note   := 'Создано автоматически при загрузке спецификации из Интермех';
          --rSHEETD28.Barcode
          DOC_INSERT_EX(rREC => rSHEETD28);
      end;
    
      -- по всем заменам спецификации
      for rlsp in (select LSP.RN,
                          LSP.COMPLETE
                     from FCPRODLSTSP LSP
                    where LSP.PRN = rFCPRODLST.Rn
                      and exists (select null from FCPRODLSTSUB SUB where SUB.PRN = LSP.RN)) loop
      
        -- по каждой замене
        for rlsb in (select SUB.RN,
                            SUB.MATRES
                       from FCPRODLSTSUB SUB
                      where SUB.PRN = rlsp.rn) loop
          -- проверим наличие записи в ведомости
          begin
            select SP28.RN
              into nD28SP
              from UDO_SHEETD28SP SP28
             where SP28.PRN = rSHEETD28.Rn
               and SP28.MATRES = rlsp.complete
               and SP28.MATRES_DIFF= rlsb.matres;
          exception
            when no_data_found then
              -- нет замены - проверим без замены
              begin
                select SP28.RN
                  into nD28SP
                  from UDO_SHEETD28SP SP28
                 where SP28.PRN = rSHEETD28.Rn
                   and SP28.MATRES = rlsp.complete
                   and SP28.MATRES_DIFF is null;
                -- есть пустая запись
                update UDO_SHEETD28SP SP28
                   set SP28.MATRES_DIFF = rlsb.matres
                 where SP28.MATRES = rlsp.complete
                   and SP28.PRN = rSHEETD28.Rn;
              exception
                when no_data_found then
                  -- нет записи в Д28 - добавим
                  SPEC_INSERT(nCOMPANY     => nCOMPANY,
                              nPRN         => rSHEETD28.Rn,
                              nMATRES      => rlsp.complete,
                              nMATRES_DIFF => rlsb.matres,
                              sNOTE        => 'Автоматически при отработке спецификации из Интермех',
                              nRN          => nD28SP);
              end;
          end;
          -- проверим связь
          begin
            select LNK.RN
              into nTMP
              from UDO_SHEETD28_SPEC_LNK LNK
             where LNK.SHEETD28SP_RN = nD28SP
               and LNK.PRODLSTSP_RN = rlsp.rn;
          exception
            when no_data_found then
              -- добавим
              SPEC_LNK_INSERT(nLST_SP => rlsp.rn, -- рег.номер записи строки спецификации изделия
                              nD28_SP => nD28SP, -- рег.номер записи спецификации Ведомости Д28
                              nRN     => nTMP);
          end;
        
        end loop;
        
      end loop;
    
    end loop;

  end PRODLST_INCL;

end UDO_PKG_SHEETD28_BASE;
/
