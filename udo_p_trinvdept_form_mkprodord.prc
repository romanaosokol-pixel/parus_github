create or replace procedure UDO_P_TRINVDEPT_FORM_MKPRODORD
(
  nCOMPANY                  in number,        -- Организация
  nRN                       in number,        -- Регистрационный номер записи
  sATTRIB                   in varchar2,      -- Измененный атрибут
  sCATALOG                  in out varchar2,  -- Каталог
  nCATALOG_EN               in out number,    -- 
  nCATALOG_RQ               in out number,    -- 
  sDOCTYPE                  in out varchar2,  -- Тип документа
  nDOCTYPE_EN               in out number,    -- 
  sDOCPREF                  in out varchar2,  -- Префикс документа
  nDOCPREF_EN               in out number,    -- 
  nDOCPREF_RQ               in out number,    -- 
  dDOCDATE                  in out date,      -- Дата документа
  nDOCDATE_EN               in out number,    -- 
  nDOCDATE_RQ               in out number,    -- 
  sAGENT                    in out varchar2,  -- Ответственный исполнитель
  nAGENT_EN                 in out number,    -- 
  nAGENT_RQ                 in out number,    -- 
  sSUBDIV                   in out varchar2,  -- Ответственное подразделение исполнитель
  nSUBDIV_EN                in out number,    -- 
  nSUBDIV_RQ                in out number,    -- 
  dRELEASE_DATE             in out date,      -- Дата исполнения
  nRELEASE_DATE_EN          in out number,    -- 
  nRELEASE_DATE_RQ          in out number,    -- 
  sFACEACC                  in out varchar2,  -- Лицевой счет
  nFACEACC_EN               in out number,    --
  nFACEACC_RQ               in out number,    --
  nCONSOLIDATE              in out number,    -- Консолидировать позиции в единый заказ (0-нет; 1-да)
  nCONSOLIDATE_EN           in out number,    -- 
  nSIGN_CONFIRM             in out number,    -- Признак формирования с подтверждением (0-нет, 1-да)
  nSIGN_CONFIRM_EN          in out number     -- 
) is
  nCRN    PKG_STD.tREF;
begin

  if sATTRIB is null then
    
    /* Каталог */
    FIND_ROOT_CATALOG(nCOMPANY, 'ProductionOrders', nCRN);
    sCATALOG := GET_ACATALOG_NAME_ID(1, nCRN);

    /* Тип документа */
    sDOCTYPE := 'ТП Ремонт';
    
    /* Дата документа */
    dDOCDATE := P_TOOLS_NOW;

    /* Префикс документа */
    sDOCPREF := to_char(dDOCDATE, 'YYYY');

    /* Ответственный исполнитель */

    /* Лицевой счет */
    begin
    select UDO_GET_SUBDIV_CODE_ID(1, t.rn),
           GET_FACEACC_NUMB_ID(1, t.faceacc)
      into sSUBDIV,
           sFACEACC
      from TRANSINVDEPT t
      where t.rn      = nRN
        and t.company = nCOMPANY;
    exception when NO_DATA_FOUND then null;
    end;

    /* Дата исполнения */
    dRELEASE_DATE := dDOCDATE;

  end if;

  /* Доступность и обязательность */
  PKG_EXT.SET_VAL( nCATALOG_EN, true);
  PKG_EXT.SET_VAL( nCATALOG_RQ, true);

  PKG_EXT.SET_VAL( nDOCTYPE_EN, false);

  PKG_EXT.SET_VAL( nFACEACC_EN, false);
  PKG_EXT.SET_VAL( nFACEACC_RQ, true);

  PKG_EXT.SET_VAL( nCONSOLIDATE_EN, true);
  PKG_EXT.SET_VAL( nSIGN_CONFIRM_EN, false);

end UDO_P_TRINVDEPT_FORM_MKPRODORD;
/

