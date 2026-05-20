create or replace procedure UDO_P_SHEETD28_FORM_EDIT(
       nMODE                in number,   -- Режим: 0-добавление/размножение; 1-исправление;
       nRN                  in number,   -- Регистрационный номер
       nCOMPANY             in number,   -- Организация
       sATTRIB              in varchar2, -- Измененный атрибут
       sJUR_PERS            in out varchar2, -- Принадлежность
       nJUR_PERS_EN         in out number,   -- 
       sDOCTYPE             in out varchar2, -- Тип документа
       nDOCTYPE_EN          in out number,   -- 
       sDOCPREF             in out varchar2, -- Префикс документа
       nDOCPREF_EN          in out number,   -- 
       nDOCPREF_RQ          in out number,   -- 
       sDOCNUMB             in out varchar2, -- Номер документа
       nDOCNUMB_EN          in out number,   -- 
       nDOCNUMB_RQ          in out number,   -- 
       dDOCDATE             in out date,     -- Дата документа
       nDOCDATE_EN          in out number,   -- 
       sEXT_NUMBER          in out varchar2, -- Внешний номер
       nEXT_NUMBER_EN       in out number,   -- 
       nEXT_NUMBER_RQ       in out number,   -- 
       nSTATE               in out number,   -- Состояние
       dSTATE_DATE          in out date,     -- Дата смены состояния
       sSUBDIV              in out varchar2, -- Подразделение
       nSUBDIV_EN           in out number,   -- 
       nSUBDIV_RQ           in out number,   -- 
       sRESPONSIBLE         in out varchar2, -- Ответственный
       nRESPONSIBLE_EN      in out number,   -- 
       nRESPONSIBLE_RQ      in out number,   -- 
       nMATRES              in out number,   -- Изделие (матресурс)
       sMATRES_NOMEN        in out varchar2, -- Изделие (номенклатура)
       nMATRES_NOMEN_EN     in out number,   -- 
       sMATRES_MODIF        in out varchar2, -- Изделие (модификация номенклатуры)
       nMATRES_MODIF_EN     in out number,   -- 
       sMATRES_CODE         in out varchar2, -- Обозначение изделия
       sMATRES_NAME         in out varchar2, -- Наименование изделия
       sUMEAS               in out varchar2, -- Основная ЕИ
       sNOTE                in out varchar2, -- Примечание
       sBARCODE             in out varchar2, -- Штрих-код документа
       nBARCODE_EN          in out number    -- 
       ) is
/* Пересчет формы редактирования записи ведомости Д28 */
  -- Контекст формы (контейнер)
  sCONTAINER     constant PKG_STD.tSTRING := $$plsql_unit; -- Имя контейнера для хранения контекста формы
  --
  nCUR_MATRES       PKG_STD.tREF;  -- Изделие (текущее)
  --
  rDOC           udo_sheetd28%rowtype;    -- Запись заголовка
  nUMEAS         PKG_STD.tREF; -- ОЕИ
  nUMEASALT      PKG_STD.tREF; -- ДЕИ
  nCOEFF         PKG_STD.tREF;
  --
  bEDIT          boolean; -- Элемент формы доступен для редактирования
  bEDIT_FORM     boolean; -- Форма доступна для редактирования
  sTMP           PKG_STD.tSTRING;
  nTMP           number;
  nRESULT        number;
begin

  /* Инициализация */
  if sATTRIB is null then
    /* Сбросим состояние контейнера */
    PKG_CONTVARSES.PURGE(sCONTAINER);

    /* Считывание записи */
    if nRN is not null then
      UDO_PKG_SHEETD28_BASE.DOC_EXISTS_EX(nRN, rDOC); 
    end if;

    /* Состояние документа */
    nSTATE      := nvl(rDOC.State,0);
    dSTATE_DATE := rDOC.State_Date;

    if nMODE = 0 then

      /* Принадлежность */
      if sJUR_PERS is null then
        /* Из настроек */
        sJUR_PERS := GET_OPTIONS_STR('JuridicalPerson', nCOMPANY);
        /* По умолчанию */
        if sJUR_PERS is null then
          FIND_JURPERSONS_MAIN(1, nCOMPANY, sJUR_PERS, nTMP);
        end if;
      end if;

      /* Тип документа */
      if sDOCTYPE is null then
        sDOCTYPE := GET_OPTIONS_STR('UdoSheetD28_DocType', nCOMPANY);
      end if;

      /* Префикс документа */
      if sDOCPREF is null then
        sDOCPREF := GET_OPTIONS_STR('UdoSheetD28_DocPref', nCOMPANY);
      end if;

      /* Дата документа */
      if dDOCDATE is null then
        dDOCDATE := P_TOOLS_NOW;
      end if;

      /* Номер документа */
      if rtrim(sDOCTYPE) is not null and rtrim(sJUR_PERS) is not null then
        if GET_OPTIONS_NUM('UdoSheetD28_AutoNumb', nCOMPANY) = 0 then
          UDO_P_SHEETD28_GETNEXTNUMB(nCOMPANY, sJUR_PERS, dDOCDATE, sDOCTYPE, sDOCPREF, sDOCNUMB);
        else
          sDOCNUMB := null;
        end if;
      end if;
        
      /* Штрих-код */
      if (GET_OPTIONS_NUM( 'DocsBarCode_AutoGeneration', nCOMPANY ) = 1) then
        P_DOCBARCODES_GET_NEXT( NCOMPANY, 'UdoSheetD28', null, sBARCODE );
      end if;

    end if;

    bEDIT := ( GET_OPTIONS_NUM('UdoSheetD28_PrefRequired', nCOMPANY) = 1 and nvl(nSTATE,0) = 0 );
    PKG_EXT.SET_VAL(nDOCPREF_RQ, bEDIT);

    bEDIT := (nMODE = 0 and GET_OPTIONS_NUM('UdoSheetD28_AutoNumb', nCOMPANY) = 0) or (nMODE = 1 and nvl(nSTATE,0) = 0 );
    PKG_EXT.SET_VAL(nDOCNUMB_EN, bEDIT);
    PKG_EXT.SET_VAL(nDOCNUMB_RQ, bEDIT);

    /* Изделие */
    nMATRES := rDOC.Matres;

  end if;

  /* Атрибуты модификации номенклатуры */
  if sATTRIB is null or sATTRIB in ('SMATRES_NOMEN','SMATRES_MODIF') then
      /* Считывание текущего знаения */
      nCUR_MATRES := PKG_CONTVARGLB.GETN(sCONTAINER, 'MATRES');

      /* Прямое изменение атрибутов */
      if cmp_num(nMATRES, nCUR_MATRES) = 1 then
        if sATTRIB = 'SMATRES_NOMEN' then
            if nCUR_MATRES is not null then
                nMATRES := null;
                sMATRES_MODIF  := null;
            end if;
        end if;

        if sATTRIB in ('SMATRES_MODIF') then
              nMATRES := null;
              sMATRES_CODE := null;
              sMATRES_NAME := null;
        else
          if rtrim(sMATRES_NOMEN) is not null then
            FIND_NOMMODIF_CODE_NAME(
                nFLAG_SMART           => 1,     -- признак генерации исключения (0 - да, 1 - нет)
                nFLAG_OPTION          => 1,     -- признак генерации исключения для пустого sCODE (0 - да, 1 - нет)
                nFLAG_FIRST           => 0,     -- признак поиска первой модификации номенклатуры (0 - да, 1 - нет)
                nCOMPANY              => nCOMPANY,
                nNOMEN                => null,
                sNOMEN                => sMATRES_NOMEN,
                sNOMEN_NAME           => null,
                sMODIF                => sMATRES_MODIF,
                sMODIF_NAME           => null,
                nRN                   => nTMP,
                sMODIF_OUT            => sMATRES_MODIF,
                sMODIF_NAME_OUT       => sTMP
                );
          end if;
        end if;

        if nMATRES is null and rtrim(sMATRES_NOMEN) is not null then
          /* Поиск материального ресурса */
          FIND_FCMATRES_BY_NOM_AND_MODIF(1, nCOMPANY, sMATRES_NOMEN, sMATRES_MODIF, nMATRES);
        end if;
      end if;

      /* Атрибуты материального ресурса */
      if nMATRES is not null then
        begin
        select n.nomen_code,
               m.modif_code,
               t.code, t.name,
               n.umeas_main, n.umeas_alt, n.equal
               into sMATRES_NOMEN, sMATRES_MODIF,
                    sMATRES_CODE, sMATRES_NAME,
                    nUMEAS, nUMEASALT, nCOEFF
               from FCMATRESOURCE t,
                    DICNOMNS      n,
                    NOMMODIF      m
               where t.rn = nMATRES
                 and t.nomenclature = n.rn
                 and t.nomen_modif  = m.rn(+);
        exception when NO_DATA_FOUND then null;
        end;
      else
        sMATRES_CODE := null;
        sMATRES_NAME := null;
        nUMEAS := null; nUMEASALT := null; nCOEFF := null;
      end if;

    /* Сохраняем в текущее значение */
    PKG_CONTVARGLB.PUTN(sCONTAINER, 'MATRES', nMATRES);
  end if;

  /* Доступность и обязательность */

  bEDIT_FORM := (nMODE = 0 or (nMODE = 1 and nvl(nSTATE,0) = 0));

  /* Принадлежность */
  PKG_EXT.SET_VAL(nJUR_PERS_EN, bEDIT_FORM);
  
  /* Тип, префикс, дата */
  PKG_EXT.SET_VAL(nDOCTYPE_EN, bEDIT_FORM);
  PKG_EXT.SET_VAL(nDOCPREF_EN, bEDIT_FORM);
  PKG_EXT.SET_VAL(nDOCDATE_EN, bEDIT_FORM);

  /* Внешний номер */
  PKG_EXT.SET_VAL(nEXT_NUMBER_EN, bEDIT_FORM);

  /* Штрих-код */
  PKG_EXT.SET_VAL(nBARCODE_EN, bEDIT_FORM);

  /* Подразделение */
  PKG_EXT.SET_VAL(nSUBDIV_EN, bEDIT_FORM);

  /* Ответственный */
  PKG_EXT.SET_VAL(nRESPONSIBLE_EN, bEDIT_FORM);

  /* Номенклатура и модификация изделия */
  PKG_EXT.SET_VAL(nMATRES_NOMEN_EN, bEDIT_FORM);
  PKG_EXT.SET_VAL(nMATRES_MODIF_EN, bEDIT_FORM);

end UDO_P_SHEETD28_FORM_EDIT;
/

