create or replace procedure UDO_P_STPLGSUPPLY_MOVEGOODS
(
  nCOMPANY        in number,      -- Организация
  nIDENT          in number,      -- Идентификатор процесса
  sCATALOG        in varchar2,    -- Каталог документа
  sDOCTYPE        in varchar2,    -- Тип документа
  sDOCPREF        in varchar2,    -- Префикс номера документа
  sSTORE          in varchar2,    -- Мнемокод склада
  sRACKNUMB       in varchar2,    -- Номер места хранения - стеллажа, куда перемещается товар
  sRACKPREF       in varchar2,    -- Префикс места хранения - стеллажа, куда перемещается товар
  sCELLNUMB       in varchar2,    -- Номер места хранения - ячейки, куда перемещается товар
  sCELLPREF       in varchar2,    -- Префикс места хранения - ячейки, куда перемещается товар
  sSHEEPVIEW      in varchar2,    -- Вид отгрузки
  sSTOPER         in varchar2,    -- Складская операция (расход)
  sIN_STOPER      in varchar2,    -- Складская операция (приход)
  sNOTE           in varchar2,    -- Примечание
  nCOUNT          out number,     -- Количество отработанных записей
  nIDENT_MSG      out number,     -- Идентификатор записей журнала сообщений (null, 0 - нет сообщений)
  nIDENT_DOC      out number,     -- Идентификатор записей расходных накладных (null, 0 - нет сформированных документов)
  nCONSOLIDATE    in number  default 1,    -- Консолидировать позиции (0-нет; 1-да)
  nSIGN_WORK      in number  default 1,    -- Отработка сформированных документов (0-нет; 1-да)
  nSAVE_DOCS      in number  default 0     -- Сохранять регистрационный номера документов (0-нет; 1-да)

)
as
  nDOCTYPE         PKG_STD.tREF;     -- тип документа
  nSTORE           PKG_STD.tREF;     -- склад
  nRACK            PKG_STD.tREF;     -- стеллаж МХ
  nCELL            PKG_STD.tREF;     -- ячейка МХ
  nSHEEPVIEW       PKG_STD.tREF;     -- Вид отгрузки
  nSTOPER          PKG_STD.tREF;     -- Складская операция (расход)
  nIN_STOPER       PKG_STD.tREF;     -- Складская операция (приход)
  nCRN             PKG_STD.tREF;     -- Каталог
  --
  nTMP             number;
begin
  /* начальная инициализация */
  nCOUNT      := 0;

  /*проверка прав доступа */
  for rec in (
      select SL.UNITCODE, GS.RN, GS.JUR_PERS
        from SELECTLIST        SL,
             STPLGSSUPPLYHIST  SH,
             STPLGOODSSUPPLY   GS
       where SL.IDENT        = nIDENT
         and SL.AUTHID       = UTILIZER
         and SL.DOCUMENT     = SH.RN
         and SH.PRN          = GS.RN
      ) loop 
      /* фиксация начала выполнения действия */
      PKG_ENV.ACCESS( nCOMPANY, null, null, Rec.JUR_PERS, 'StoragePlacesGoodsSupply', 'UDO_STPLGSUPPLY_MOVEGOODS' );

      if rec.unitcode <> 'StoragePlacesGoodsSupply' then
        P_SELECTLIST_INSERT(nIDENT, rec.rn, 'StoragePlacesGoodsSupply', nTMP);
      end if;
  end loop;

  /* поиск каталога документа */
  FIND_ACATALOG_NAME_EX(0, 1, nCOMPANY, null, 'GoodsTransInvoicesToDepts', sCATALOG, nCRN);
  /* поиск типа документа */
  FIND_DOCTYPES_CODE_EX( 0, 1, nCOMPANY, sDOCTYPE, nDOCTYPE );
  /* поиск склада */
  FIND_DICSTORE_NUMB( 0, nCOMPANY, sSTORE, nSTORE );
  /* поиск стеллажа, куда перемещается товар */
  P_STPLRACKS_FIND( 0, nCOMPANY, sSTORE, sRACKPREF, sRACKNUMB, nRACK );
  /* поиск места хранения (ячейки), куда перемещается товар */
  P_STPLCELLS_FIND( 0, nCOMPANY, nRACK, sCELLPREF, sCELLNUMB, nCELL );
  /* Вид отгрузки */
  FIND_DICSHPVW_CODE ( 0, nCOMPANY, sSHEEPVIEW, nSHEEPVIEW );
  /* Складская операция (расход) */
  FIND_DICSTOPR_CODE ( 0, nCOMPANY, sSTOPER, nSTOPER );
  /* Складская операция (приход) */
  FIND_DICSTOPR_CODE ( 1, nCOMPANY, sIN_STOPER, nIN_STOPER );

  /* Перемещение между местами хранения через документ "Расходная накладная на отпуск в подразделения" */
  UDO_P_STPLGSUPPLY_MOVEINVDEPT(
      nCOMPANY        => nCOMPANY,
      nIDENT          => nIDENT,
      nCRN            => nCRN,
      nDOCTYPE        => nDOCTYPE,
      sDOCPREF        => sDOCPREF,
      nSTORE          => nSTORE,
      nCELL           => nCELL,
      nSHEEPVIEW      => nSHEEPVIEW,
      nSTOPER         => nSTOPER,
      nIN_STOPER      => nIN_STOPER,
      nQUANT          => null,
      nQUANTALT       => null,
      sNOTE           => sNOTE,
      nCOUNT          => nCOUNT,
      nIDENT_MSG      => nIDENT_MSG,
      nIDENT_DOC      => nIDENT_DOC,
      nCONSOLIDATE    => nCONSOLIDATE,  -- Консолидировать позиции (0-нет; 1-да)
      nSIGN_WORK      => nSIGN_WORK,    -- Отработка сформированных документов (0-нет; 1-да)
      nSAVE_DOCS      => nSAVE_DOCS     -- Сохранять регистрационный номера документов (0-нет; 1-да)
      );

  if nCOUNT = 0 and nvl(nIDENT_MSG,0) = 0 then
    p_exception(0, 'Нет данных для обработки.');
  end if;

end UDO_P_STPLGSUPPLY_MOVEGOODS;
/

