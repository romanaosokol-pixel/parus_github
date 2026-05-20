create or replace procedure UDO_P_SHEETD28SP_FORM_EDIT
(
  nMODE                     in number,   -- Режим: 0-добавление/размножение; 1-исправление;
  nRN                       in number,   -- Регистрационный номер
  nPRN                      in number,   -- Регистрационный номер родителя
  nCOMPANY                  in number,   -- Организация
  sATTRIB                   in varchar2, -- Измененный атрибут
  nMATRES                   in out number,   -- Комплектующая по спецификации (матресурс)
  sMATRES_NOMEN             in out varchar2, -- Комплектующая по спецификации (номенклатура)
  nMATRES_NOMEN_EN          in out number,   -- 
  sMATRES_MODIF             in out varchar2, -- Комплектующая по спецификации (модификация номенклатуры)
  nMATRES_MODIF_EN          in out number,   -- 
  sMATRES_CODE              in out varchar2, -- Обозначение комплектующей по спецификации
  sMATRES_NAME              in out varchar2, -- Наименование комплектующей по спецификации
  sUMEAS                    in out varchar2, -- Основная ЕИ
  nMATRES_DIFF              in out number,   -- Комплектующая замены (матресурс)
  sMATRES_DIFF_NOMEN        in out varchar2, -- Комплектующая замены  (номенклатура)
  nMATRES_DIFF_NOMEN_EN     in out number,   -- 
  sMATRES_DIFF_MODIF        in out varchar2, -- Комплектующая замены  (модификация номенклатуры)
  nMATRES_DIFF_MODIF_EN     in out number,   -- 
  sMATRES_DIFF_CODE         in out varchar2, -- Обозначение комплектующей замены 
  sMATRES_DIFF_NAME         in out varchar2, -- Наименование комплектующей замены 
  sNOTE                     in out varchar2  -- Примечание
) is
/* Пересчет формы редактирования записи спецификации ведомости Д28 */
  -- Контекст формы (контейнер)
  sCONTAINER        constant PKG_STD.tSTRING := $$plsql_unit; -- Имя контейнера для хранения контекста формы
  --
  nDOC_STATE        number;        -- Состояние
  nCUR_MATRES       PKG_STD.tREF;  -- Комплектующая по спецификации (текущее)
  nCUR_MATRES_DIFF  PKG_STD.tREF;  -- Комплектующая замены (текущее)
  --
  rDOC              udo_sheetd28%rowtype;    -- Запись заголовка
  rREC              udo_sheetd28sp%rowtype;  -- Запись
  nUMEAS            PKG_STD.tREF; -- ОЕИ
  nUMEASALT         PKG_STD.tREF; -- ДЕИ
  nCOEFF            PKG_STD.tREF;
  --
  bEDIT             boolean; -- Элемент формы доступен для редактирования
  bEDIT_FORM        boolean; -- Форма доступна для редактирования
  sTMP              PKG_STD.tSTRING;
  nTMP              number;
begin

  /* Инициализация */
  if sATTRIB is null then
    /* Сбросим состояние контейнера */
    PKG_CONTVARSES.PURGE(sCONTAINER);

    /* Считывание записи */
    UDO_PKG_SHEETD28_BASE.DOC_EXISTS_EX(nPRN, rDOC); 
    if nRN is not null then
      UDO_PKG_SHEETD28_BASE.SPEC_EXISTS_EX(nRN, rREC); 
    end if;

    /* Состояние документа */
    nDOC_STATE   := nvl(rDOC.State,0);

    /* Комплектующая по спецификации */
    nMATRES      := rREC.Matres;
    nMATRES_DIFF := rREC.Matres_Diff;

    /* Сохраним значения */
    PKG_CONTVARGLB.PUTN(sCONTAINER, 'DOC_STATE', nDOC_STATE);
  else
    /* Восстанавливаем значения */
    nDOC_STATE   := PKG_CONTVARGLB.GETN(sCONTAINER, 'DOC_STATE');
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

  /* Атрибуты модификации номенклатуры */
  if sATTRIB is null or sATTRIB in ('SMATRES_DIFF_NOMEN','SMATRES_DIFF_MODIF') then
      /* Считывание текущего знаения */
      nCUR_MATRES_DIFF := PKG_CONTVARGLB.GETN(sCONTAINER, 'MATRES_DIFF');

      /* Прямое изменение атрибутов */
      if cmp_num(nMATRES_DIFF, nCUR_MATRES_DIFF) = 1 then
        if sATTRIB = 'SMATRES_DIFF_NOMEN' then
            if nCUR_MATRES_DIFF is not null then
                nMATRES_DIFF := null;
                sMATRES_DIFF_MODIF  := null;
            end if;
        end if;

        if sATTRIB in ('SMATRES_DIFF_MODIF') then
              nMATRES_DIFF := null;
              sMATRES_DIFF_CODE := null;
              sMATRES_DIFF_NAME := null;
        else
          if rtrim(sMATRES_DIFF_NOMEN) is not null then
            FIND_NOMMODIF_CODE_NAME(
                nFLAG_SMART           => 1,     -- признак генерации исключения (0 - да, 1 - нет)
                nFLAG_OPTION          => 1,     -- признак генерации исключения для пустого sCODE (0 - да, 1 - нет)
                nFLAG_FIRST           => 0,     -- признак поиска первой модификации номенклатуры (0 - да, 1 - нет)
                nCOMPANY              => nCOMPANY,
                nNOMEN                => null,
                sNOMEN                => sMATRES_DIFF_NOMEN,
                sNOMEN_NAME           => null,
                sMODIF                => sMATRES_DIFF_MODIF,
                sMODIF_NAME           => null,
                nRN                   => nTMP,
                sMODIF_OUT            => sMATRES_DIFF_MODIF,
                sMODIF_NAME_OUT       => sTMP
                );
          end if;
        end if;

        if nMATRES_DIFF is null and rtrim(sMATRES_DIFF_NOMEN) is not null then
          /* Поиск материального ресурса */
          FIND_FCMATRES_BY_NOM_AND_MODIF(1, nCOMPANY, sMATRES_DIFF_NOMEN, sMATRES_DIFF_MODIF, nMATRES_DIFF);
        end if;
      end if;

      /* Атрибуты материального ресурса */
      if nMATRES_DIFF is not null then
        begin
        select n.nomen_code,
               m.modif_code,
               t.code, t.name
               into sMATRES_DIFF_NOMEN, sMATRES_DIFF_MODIF,
                    sMATRES_DIFF_CODE, sMATRES_DIFF_NAME
               from FCMATRESOURCE t,
                    DICNOMNS      n,
                    NOMMODIF      m
               where t.rn = nMATRES_DIFF
                 and t.nomenclature = n.rn
                 and t.nomen_modif  = m.rn(+);
        exception when NO_DATA_FOUND then null;
        end;
      else
        sMATRES_DIFF_CODE := null;
        sMATRES_DIFF_NAME := null;
      end if;

    /* Сохраняем в текущее значение */
    PKG_CONTVARGLB.PUTN(sCONTAINER, 'MATRES_DIFF', nMATRES_DIFF);
  end if;


  /* Доступность и обязательность */

  bEDIT_FORM := (nMODE = 0 or (nMODE = 1 and nvl(nDOC_STATE,0) = 0));

  /* Номенклатура и модификация комплектующей по спецификации */
  PKG_EXT.SET_VAL(nMATRES_NOMEN_EN, bEDIT_FORM);
  PKG_EXT.SET_VAL(nMATRES_MODIF_EN, bEDIT_FORM);

  /* Номенклатура и модификация комплектующей замены */
  PKG_EXT.SET_VAL(nMATRES_DIFF_NOMEN_EN, bEDIT_FORM);
  PKG_EXT.SET_VAL(nMATRES_DIFF_MODIF_EN, bEDIT_FORM);

end UDO_P_SHEETD28SP_FORM_EDIT;
/

