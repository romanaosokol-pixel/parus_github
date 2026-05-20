create or replace package UDO_PKG_RLINVSHEET as
  /*
    11/01/2024 Марков МВ.
    Пакет процедур и функций для раздела "Ведомости инвентаризации"
    grant execute on  UDO_PKG_RLINVSHEET to public;
  */
  
  /* Места хранения. */
  function F_STPLCELLS_CODE(nRN in number) return varchar2;

  /* Инициализация параметров формы "Указать факт" */
  procedure FRM_RLINVSHEETSP_SET_FACT
  (
    nRN      in number, -- рег.номер записи спецификации
    nCOMPANY in number, -- организация
    nFACT    out number, -- количество "Фактически"
    nDLVR    out number -- количество "В том числе в КВ"
  );
  
  /* Процедура "Указать факт" */
  procedure RLINVSHEETSP_SET_FACT
  (
    nRN      in number, -- рег.номер записи спецификации
    nCOMPANY in number, -- организация
    nFACT    in number, -- количество "Фактически"
    nDLVR    in number -- количество "В том числе в КВ"
  );

end UDO_PKG_RLINVSHEET;
/
create or replace package body UDO_PKG_RLINVSHEET as
  /*
    11/01/2024 Марков МВ.
    Пакет процедур и функций для раздела "Ведомости инвентаризации"
    grant execute on  UDO_PKG_RLINVSHEET to public;
  */

  /* Места хранения. */
  function F_STPLCELLS_CODE(nRN in number) return varchar2 is
    sRES varchar2(240);
  begin
    select TRIM(CEL.PREF) || '.' || to_char(CEL.TIER) || '.' || TRIM(CEL.NUMB)
      into sRES
      from STPLCELLS CEL
     where CEL.RN = nRN;
    return sRES;
  exception
    when no_data_found then
      return '';
  end F_STPLCELLS_CODE;

  /* Базовая Процедура "Указать факт" */
  procedure RLINVSHEETSP_BSET_FACT
  (
    nRN   in number, -- рег.номер записи спецификации
    nFACT in number, -- количество "Фактически"
    nDLVR in number -- количество "В том числе в КВ"
  ) is
    nFACT_QUANT    RLINVSHEETSPEC.FACTQUANT%type;
    nSTATUS        RLINVSHEET.STATUS%type;
    nTMP           PKG_STD.tREF;
  begin
    -- статус ведомости
    begin
      select SH.STATUS
        into nSTATUS
        from RLINVSHEETSPEC SP,
             RLINVSHEET     SH
       where SP.RN = nRN
         and SP.PRN = SH.RN;
    exception
      when no_data_found then
        p_exception(0, 'Ведомость не найдена.'||chr(10)||
                       'SPEC_RN: %s',
                       nRN);
    end;
    -- Только для состояния Бланк
    if nSTATUS > 0 then
      p_exception(0, 'Ведомость в состоянии отличном от "Бланк".'||chr(10)||
                     'Сначала переведите ведомость в состояние "Бланк".');
    end if;
    -- фактически на складе
    nFACT_QUANT := nFACT + nDLVR;
    update RLINVSHEETSPEC SP set SP.FACTQUANT = nFACT_QUANT where SP.RN = nRN;
    -- в том числе скомплектовано
    PKG_DOCS_PROPS_VALS.MODIFY(nPROPERTY   => 109134620, -- КВ_КОЛ
                               sUNITCODE   => 'RealizationInventorySheetSpec',
                               nDOCUMENT   => nRN,
                               sSTR_VALUE  => null,
                               nNUM_VALUE  => nDLVR,
                               dDATE_VALUE => null,
                               nRN         => nTMP);
  end RLINVSHEETSP_BSET_FACT;

  /* Инициализация параметров формы "Указать факт" */
  procedure FRM_RLINVSHEETSP_SET_FACT
  (
    nRN      in number, -- рег.номер записи спецификации
    nCOMPANY in number, -- организация
    nFACT    out number, -- количество "Фактически"
    nDLVR    out number -- количество "В том числе в КВ"
  ) is
    nPARTY PKG_STD.tREF;
    nSTORE PKG_STD.tREF;
    nMODIF PKG_STD.tREF;
    sCELL_NUMB varchar2(240);
  begin
    -- количество по строке
    begin
      select SP.FACTQUANT,
             GS.PRN,
             SP.NOMMODIF,
             SP.CELL_NUMB,
             SH.STORE
        into nFACT,
             nPARTY,
             nMODIF,
             sCELL_NUMB,
             nSTORE
        from RLINVSHEETSPEC SP,
             RLINVSHEET     SH,
             GOODSSUPPLY    GS
       where SP.RN = nRN
         and SP.PRN = SH.RN
         and SP.GOODSSUPPLY = GS.RN;
    exception
      when no_data_found then
        return;
    end;
    -- количество в неотработанных накладных в Статусе кроме "Регистрация накладной"
    begin
      select nvl(sum(TDS.QUANT), 0)
        into nDLVR
        from TRANSINVDEPTSPECS TDS,
             TRANSINVDEPT      TD
       where TDS.PRN = TD.RN
         and TD.COMPANY = nCOMPANY
         and TDS.GOODSPARTY = nPARTY
         and TDS.NOMMODIF = nMODIF
         and TD.STATUS = 0
         and TD.STORE = nSTORE
         and exists (select null
                from CLNEVENTS    CE,
                     CLNEVNTYPSTS CT,
                     CLNEVNSTATS  CS
               where CE.LINKED_RN = TD.RN
                 and CE.EVENT_STAT = CT.RN
                 and CT.EVENT_STATUS = CS.RN
                 and CS.EVNSTAT_CODE not in ('РегистрацияРНвПдр', 'ВыданоПроизводство'))
         and exists(select null
                from STRPLRESJRNL JRN,
                     DOCLINKS     L,
                     STPLCELLS    CELL
               where L.IN_DOCUMENT = TDS.RN
                 and L.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                 and L.OUT_DOCUMENT = JRN.RN
                 and JRN.RES_TYPE = 1
                 and UDO_PKG_RLINVSHEET.F_STPLCELLS_CODE(nRN => JRN.CELL) = sCELL_NUMB);
    exception
      when no_data_found then
        nDLVR := 0;
    end;
    -- инициализация
    nFACT := nFACT - nDLVR;
  end FRM_RLINVSHEETSP_SET_FACT;
  
  /* Процедура "Указать факт" */
  procedure RLINVSHEETSP_SET_FACT
  (
    nRN   in number, -- рег.номер записи спецификации
    nCOMPANY in number, -- организация
    nFACT in number, -- количество "Фактически"
    nDLVR in number -- количество "В том числе в КВ"
  ) is
    nFACT_QUANT    RLINVSHEETSPEC.FACTQUANT%type := nvl(nFACT, 0);
    nDELIVSH_QUANT number(17, 3) := nvl(nDLVR, 0);
    nCRN           PKG_STD.tREF;
  begin
    -- запись строки спецификации
    P_RLINVSHEETSPEC_EXISTS(nCOMPANY => nCOMPANY, nRN => nRN, nCRN => nCRN);
    -- пролог
    PKG_ENV.PROLOGUE(nCOMPANY  => nCOMPANY,
                     nVERSION  => null,
                     nCATALOG  => nCRN,
                     sUNIT     => 'RealizationInventorySheetSpec',
                     sACTION   => 'UDO_RLINVSHEETSP_SET_FACT',
                     sTABLE    => 'RLINVSHEETSPEC',
                     nDOCUMENT => nRN);
    -- базовое исправление
    RLINVSHEETSP_BSET_FACT(nRN => nRN, nFACT => nFACT_QUANT, nDLVR => nDELIVSH_QUANT);
    -- эпилог
    PKG_ENV.EPILOGUE(nCOMPANY  => nCOMPANY,
                     nVERSION  => null,
                     nCATALOG  => nCRN,
                     sUNIT     => 'RealizationInventorySheetSpec',
                     sACTION   => 'UDO_RLINVSHEETSP_SET_FACT',
                     sTABLE    => 'RLINVSHEETSPEC',
                     nDOCUMENT => nRN);
  end RLINVSHEETSP_SET_FACT;
  
end UDO_PKG_RLINVSHEET;
/
