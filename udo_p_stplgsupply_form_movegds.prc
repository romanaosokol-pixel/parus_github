create or replace procedure UDO_P_STPLGSUPPLY_FORM_MOVEGDS
(
  nCOMPANY                  in number,        -- Организация
  nIDENT                    in number,        -- Идентификатор процесса
  sATTRIB                   in varchar2,      -- Измененный атрибут
  sCATALOG                  in out varchar2,  -- Каталог документа
  nCATALOG_EN               in out number,    -- 
  nCATALOG_RQ               in out number,    -- 
  sDOCTYPE                  in out varchar2,  -- Тип документа
  nDOCTYPE_EN               in out number,    -- 
  nDOCTYPE_RQ               in out number,    -- 
  sDOCPREF                  in out varchar2,  -- Префикс номера документа
  nDOCPREF_EN               in out number,    -- 
  nDOCPREF_RQ               in out number,    -- 
  sSTORE                    in out varchar2,  -- Мнемокод склада
  nSTORE_EN                 in out number,    -- 
  nSTORE_RQ                 in out number,    -- 
  nRACK                     in out number,    -- Стеллаж места хранения куда перемещается товар
  sRACKFULLNUMB             in out varchar2,  -- Полный номер стеллажа
  nRACKFULLNUMB_EN          in out number,    -- 
  nRACKFULLNUMB_RQ          in out number,    -- 
  sRACKNUMB                 in out varchar2,  -- Номер стеллажа места хранения куда перемещается товар
  sRACKPREF                 in out varchar2,  -- Префикс стеллажа места хранения куда перемещается товар
  nCELL                     in out number,    -- Ячейка места хранения куда перемещается товар
  sCELLFULLNUMB             in out varchar2,  -- Полный номер ячейки
  nCELLFULLNUMB_EN          in out number,    -- 
  nCELLFULLNUMB_RQ          in out number,    -- 
  sCELLNUMB                 in out varchar2,  -- Номер ячейки места хранения - ячейки, куда перемещается товар
  sCELLPREF                 in out varchar2,  -- Префикс ячейки места хранения куда перемещается товар
  sSHEEPVIEW                in out varchar2,  -- Вид отгрузки
  nSHEEPVIEW_EN             in out number,    -- 
  nSHEEPVIEW_RQ             in out number,    -- 
  sSTOPER                   in out varchar2,  -- Складская операция (расход)
  nSTOPER_EN                in out number,    -- 
  nSTOPER_RQ                in out number,    -- 
  sIN_STOPER                in out varchar2,  -- Складская операция (приход)
  nIN_STOPER_EN             in out number,    -- 
  nIN_STOPER_RQ             in out number,    -- 
  sNOTE                     in out varchar2,  -- Примечание
  nCONSOLIDATE              in out number,    -- Консолидировать позиции (0-нет; 1-да)
  nSIGN_WORK                in out number,    -- Отработка сформированных документов (0-нет; 1-да)
  nSAVE_DOCS                in out number     -- Сохранять регистрационный номера документов (0-нет; 1-да)
) as
  nSTORE      PKG_STD.tREF;
  bEDIT       boolean;
begin
  /* начальная инициализация */
  if sATTRIB is null then
    /* Каталог документа */
    sCATALOG := GET_OPTIONS_STR('Realiz_InvDept_Catalog', nCOMPANY);
    
    /* Тип документа */
    sDOCTYPE := GET_OPTIONS_STR('Realiz_InvDept_DocType', nCOMPANY);

    /* Префикс документа */
    sDOCPREF := to_char(P_TOOLS_NOW, 'YYYY');

    /* Склад */
    begin
      select distinct S.STORE
             into nSTORE
        from SELECTLIST        SL,
             STPLGSSUPPLYHIST  SH,
             STPLGOODSSUPPLY   GS,
             GOODSSUPPLY       S
       where SL.IDENT        = nIDENT
         and SL.AUTHID       = UTILIZER
         and SL.DOCUMENT     = SH.RN
         and SH.PRN          = GS.RN
         and GS.GOODSSUPPLY  = S.RN;
    exception when NO_DATA_FOUND or TOO_MANY_ROWS then nSTORE := null;
    end;

    if nSTORE is not null then
      sSTORE := F_DICSTORE_GET_NUMB(nSTORE);
    end if;

    /* Вид отгрузки */
    sSHEEPVIEW := GET_OPTIONS_STR('Realiz_InvDept_ShipType', nCOMPANY);
    /* Складская операция (расход) */
    sSTOPER    := GET_OPTIONS_STR('Realiz_InvDept_StoreOper', nCOMPANY);
    /* Складская операция (приход) */
    sIN_STOPER := GET_OPTIONS_STR('Realiz_InvDept_InStoreOper', nCOMPANY);
  end if;

  /* Склад */
  if sATTRIB in ('SSTORE') then
      sRACKFULLNUMB := null;
      sRACKNUMB     := null;
      sRACKPREF     := null;
      sCELLFULLNUMB := null;
      sCELLNUMB     := null;
      sCELLPREF     := null;
  end if;

  /* Стеллаж места хранения куда перемещается товар */
  if sATTRIB in ('SRACKFULLNUMB') then
    if sRACKFULLNUMB is null then
      sRACKNUMB := null;
      sRACKPREF := null;
      sCELLNUMB := null;
      sCELLPREF := null;
    end if;
  end if;

  /* Ячейка места хранения куда перемещается товар */
  if sATTRIB in ('SCELLFULLNUMB') then
    if sCELLFULLNUMB is null then
      sCELLNUMB := null;
      sCELLPREF := null;
    end if;
  end if;

  /* Доступность и обязательность */

  /* Стеллаж места хранения куда перемещается товар */
  bEDIT := ( sSTORE is not null );
  PKG_EXT.SET_VALS(sRACKFULLNUMB, nRACKFULLNUMB_EN, bEDIT, is_NULL => true);
  PKG_EXT.SET_VAL(nRACKFULLNUMB_RQ, bEDIT);

  /* Ячейка места хранения куда перемещается товар */
  bEDIT := not (sRACKNUMB is null or sRACKPREF is null);
  PKG_EXT.SET_VALS(sCELLFULLNUMB, nCELLFULLNUMB_EN, bEDIT, is_NULL => true);
  PKG_EXT.SET_VAL(nCELLFULLNUMB_RQ, bEDIT);

end UDO_P_STPLGSUPPLY_FORM_MOVEGDS;
/

