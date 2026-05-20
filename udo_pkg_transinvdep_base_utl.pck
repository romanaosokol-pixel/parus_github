create or replace package UDO_PKG_TRANSINVDEP_BASE_UTL as
  /*
    24/10/2022 Марков МВ.
    Расходные накладные на отпуск в подразделения
    Пакет процедур и функций для расширения функциональных возможностей
    Базовый пакет.
  */

  /* Функция возвращает строку комплектования для строки спецификации накладной */
  function F_GET_CMPL_BY_SPEC
  (
    nSPEC  in number,
    nSHEET in number
  ) return number;

  /* Запись строки спецификации накладной */
  procedure P_TRANSINVDEPT_SPEC(rROW in out TRANSINVDEPTSPECS%rowtype);

  /* Запись заголовка расходной накладной */
  procedure P_TRANSINVDEPT_ROW(rROW in out TRANSINVDEPT%rowtype);

  /* Процедура формирования сквозного номера */
  procedure P_TRANSINVDEP_NEXTNUMB
  (
    nCOMPANY in number,
    dDOCDATE in date,
    sPREF    out varchar2,
    sNUMB    out varchar2
  );

  /* При исправлении накладной */
  procedure P_TRANSINVDEP_NEXT_UPDATE
  (
    nCOMPANY in number,
    nRN      in number,
    dDOCDATE in date,
    sPREF    in out varchar2,
    sNUMB    in out varchar2
  );

  /* Создание приходной партии товарного запаса */
  procedure P_GOODSPARTY_MAKE
  (
    nCOMPANY        in number,                              -- Рег номер организации
    sJUR_PERS       in varchar2,            -- Принадлежность
    sAGENT          in varchar2,         -- Контрагент партии
    dENTRY_DATE     in date,                                -- Дата прихода
    nNOMMODIF       in number,                              -- Рег номер модификации
    sCERTIFICATE    in varchar2,                            -- Сертификат
    sSERNUMB        in varchar2,                            -- Серия
    nGOODSPARTIES     out number                            -- Рег номер товарного запаса
  );

  /* Исправление количества в спецификации РН, связанной с КВ */
  procedure SP_UPDATE_QNT
  (
    nDOCUMENT                 in number, -- Рег. номер спецификации РН
    nQUANT                    in number, -- Количество
    nSIGN_DLVR                in number, -- Удалить из комплектования КВ
    nSIGN_DROP                in number  -- Признак удаления резерва
  );
  
  /* 12/09/2023 Марков МВ. Неизменность полей для возвратной накладной */
  procedure P_TRANSINVDEP_RET_CHECK
  (
    rROW        in TRANSINVDEPT%rowtype,
    nIN_STORE   in number,
    nIN_MOL     in number,
    nIN_STOPER  in number,
    nIN_STORE_  out number,
    nIN_MOL_    out number,
    nIN_STOPER_ out number
  );

end UDO_PKG_TRANSINVDEP_BASE_UTL;
/
create or replace package body UDO_PKG_TRANSINVDEP_BASE_UTL as
  /*
    23/01/2026 Степанов М. отключение восстановления значений склада-получателя при выполнении определённых процедур
    20/11/2025 Степанов М. заменил процедуру удаления спецификации на нашу, убрал удаление связей, т.к. в нашей есть
    29/05/2025 Степанов М. удаление входных связей спецификации
    24/10/2022 Марков МВ.
    Расходные накладные на отпуск в подразделения
    Пакет процедур и функций для расширения функциональных возможностей
    Базовый пакет. Гранты не выдавать!!!!
  */

  /* Функция возвращает строку комплектования для строки спецификации накладной */
  function F_GET_CMPL_BY_SPEC
  (
    nSPEC  in number,
    nSHEET in number
  ) return number is
    nRES    number(17);
    nSTATUS TRANSINVDEPT.STATUS%type;
  begin
    -- парметры накладной
    begin
      select TD.STATUS
        into nSTATUS
        from TRANSINVDEPTSPECS TDS,
             TRANSINVDEPT      TD
       where TDS.RN = nSPEC
         and TDS.PRN = TD.RN;
    exception
      when no_data_found then
        return null;
    end;
    --
    if nSTATUS <= 0 then
      -- не отработано
      nRES := 0;
      -- связанный резерв
      for rsrv in (select L.*
                     from DOCLINKS L
                    where L.OUT_DOCUMENT = nSPEC
                      and L.OUT_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                      and L.IN_UNITCODE = 'ReservationJournal') loop
        -- проверим заказ
        for rprf in (select CMPL.QUANT
                       from UDO_DEPORDS_PRF PRF,
                            FCDELIVSHSPCMPL CMPL
                      where PRF.RSRV = rsrv.in_document
                        and PRF.CMPL = CMPL.RN) loop
          --return rprf.quant;
          nRES := nRES + rprf.quant;
        end loop;
        -- нет заказов - прямое резервирование в КВ
        for rkv in (select CMPL.QUANT
                      from DOCLINKS        L,
                           FCDELIVSHSPCMPL CMPL
                     where L.OUT_UNITCODE = rsrv.in_unitcode
                       and L.OUT_DOCUMENT = rsrv.in_document
                       and L.IN_UNITCODE = 'CostDeliverySheetsSpecCompletion'
                       and L.IN_DOCUMENT = CMPL.RN) loop
          --return rkv.quant;
          nRES := nRES + rkv.quant;
        end loop;
      end loop;
    
    else
      -- отработано
      -- сначала по схеме резервов из заказа
      begin
        select nvl(sum(CMPL.QUANT), 0)
          into nRES
          from UDO_DEPORDS_PRF PRF,
               FCDELIVSHSPCMPL CMPL
         where PRF.INVDPTSP = nSPEC
           and PRF.CMPL = CMPL.RN;
           --and rownum < 2;
      exception
        when no_data_found then
          nRES := 0;
      end;
      --
      if nvl(nRES, 0) > 0 then
        return nRES;
      end if;
      -- Передача в цех
      begin
        select TRN.QUANT
          into nRES
          from FCDELIVSHSPTRN TRN
         where TRN.PRN = nSHEET
           and TRN.TRNSDPTSP = nSPEC;
      exception
        when no_data_found then
          return null;
      end;
    end if;
  
    return nRES;
  end F_GET_CMPL_BY_SPEC;
  
  /* Запись строки спецификации накладной */
  procedure P_TRANSINVDEPT_SPEC(rROW in out TRANSINVDEPTSPECS%rowtype) is
  begin
    select TDS.*
      into rROW
      from TRANSINVDEPTSPECS TDS
     where TDS.RN = rROW.Rn;
  exception
    when no_data_found then
      null;
  end P_TRANSINVDEPT_SPEC;
  
  /* Запись заголовка расходной накладной */
  procedure P_TRANSINVDEPT_ROW(rROW in out TRANSINVDEPT%rowtype) is
  begin
    select TD.*
      into rROW
      from TRANSINVDEPT TD
     where TD.RN = rROW.Rn;
  exception
    when no_data_found then
      rROW := null;
  end P_TRANSINVDEPT_ROW;
  
  /* Контроль истории статусов расходной накладной */
  procedure P_TRINVDEPT_QNT_CHECK_EVNSTATE(nRN in number) is
    dSTATE date;
  begin
    select CE.REG_DATE
      into dSTATE
      from CLNEVENTS    CE,
           CLNEVNTYPSTS CTS,
           CLNEVNSTATS  CS
     where CE.LINKED_RN = nRN
       and CE.LINKED_UNIT = 'GoodsTransInvoicesToDepts'
       and CE.EVENT_STAT = CTS.RN
       and CTS.EVENT_STATUS = CS.RN
       and CS.EVNSTAT_CODE in ('ПринятоНаКомплект.', 'Передано в ОТК', 'РегистрацияРНвПдр');
  exception
    when no_data_found then
      for rul in (select UR.ROLEID
                    from USERROLES UR,
                         ROLES     R
                   where UR.AUTHID = UTILIZER
                     and UR.ROLEID = R.RN
                     and R.ROLENAME = 'ПУДП Количество') loop
        p_exception(0,
                    'Изменение количества возможно только для состояний "РегистрацияРНвПдр", "ПринятоНаКомплект.", "Передано в ОТК".' ||
                    chr(10) || 'Обратитесь к Администратору.');
      end loop;
      null;
  end P_TRINVDEPT_QNT_CHECK_EVNSTATE;
  
  /* Процедура формирования сквозного номера */
  procedure P_TRANSINVDEP_NEXTNUMB
  (
    nCOMPANY in number,
    dDOCDATE in date,
    sPREF    out varchar2,
    sNUMB    out varchar2
  ) is
    sMAX   TRANSINVDEPT.NUMB%type;
    sBMAX  TRANSINVDEPT.NUMB%type;
    dYEAR date;
  begin
    --
    if nCOMPANY is null then
      p_exception(0, 'Не указан рег.номер организации. COMPANY: %s', nCOMPANY);
    end if;
    --
    if dDOCDATE is null then
      sPREF := to_char(sysdate, 'yyyy');
      dYEAR := trunc(sysdate, 'yyyy');
    else
      sPREF := to_char(dDOCDATE, 'yyyy');
      dYEAR := trunc(dDOCDATE, 'yyyy');
    end if;
    -- максимальный номер по году
    begin
      select max(TD.NUMB)
        into sMAX
        from TRANSINVDEPT TD
       where TD.COMPANY = nCOMPANY
         and trim(TD.PREF)             = to_char(D_YEAR(dYEAR))
         and trunc(TD.DOCDATE, 'yyyy') = dYEAR
         and instr(TD.NUMB, '00000')  <= 0
         and instr(TD.NUMB, '-') <= 0;
    exception
      when no_data_found then
        sMAX := to_char(null);
    end;
    
    -- максимальный номер по году в буфере
    /* Столярский ЕЗ. 06/05/2024 Можем генерить несколько документов сразу по разным складам */
    /*begin
      select max(TD.NUMB)
        into sBMAX
        from TRANSINVDEPTBUF TD
       where TD.COMPANY = nCOMPANY
         and trim(TD.PREF)             = to_char(D_YEAR(dYEAR))
         and trunc(TD.DOCDATE, 'yyyy') = dYEAR
         and instr(TD.NUMB, '00000')  <= 0;
    exception
      when no_data_found then
        sBMAX := to_char(null);
    end;
    
    if sBMAX is not null then 
      sMAX := GREATEST(sMAX, sBMAX);
    --  sMAX :=  sBMAX;
    end if;*/
    /* инкрементация номера */
    sNUMB := PKG_INCREMENT.DOCUMENT_(sDOCUMENT => sMAX, iLENGTH => 80, iSTEP => 1, iZERO => 1);
  
  end P_TRANSINVDEP_NEXTNUMB;

  /* При исправлении накладной */
  procedure P_TRANSINVDEP_NEXT_UPDATE
  (
    nCOMPANY in number,
    nRN      in number,
    dDOCDATE in date,
    sPREF    in out varchar2,
    sNUMB    in out varchar2
  ) is
    dDOCDATE_OLD date;
  begin
    -- считывание записи
    begin
      select TD.DOCDATE
        into dDOCDATE_OLD
        from TRANSINVDEPT TD
       where TD.RN = nRN
         and TD.COMPANY = nCOMPANY;
    exception
      when no_data_found then
        p_exception(0,
                    'Расходная накладная на отпуск в подразделения не найдена.' || chr(10) || 'RN: %s' || chr(10) ||
                    'COMPANY: %s',
                    nRN,
                    nCOMPANY);
    end;
    --
    if trunc(dDOCDATE, 'yyyy') != trunc(dDOCDATE_OLD, 'yyyy') then
      P_TRANSINVDEP_NEXTNUMB(nCOMPANY => nCOMPANY, dDOCDATE => dDOCDATE, sPREF => sPREF, sNUMB => sNUMB);
    end if;
  end P_TRANSINVDEP_NEXT_UPDATE;

  /* Создание приходной партии товарного запаса */
  procedure P_GOODSPARTY_MAKE
  (
    nCOMPANY        in number,                              -- Рег номер организации
    sJUR_PERS       in varchar2,            -- Принадлежность
    sAGENT          in varchar2,         -- Контрагент партии
    dENTRY_DATE     in date,                                -- Дата прихода
    nNOMMODIF       in number,                              -- Рег номер модификации
    sCERTIFICATE    in varchar2,                            -- Сертификат
    sSERNUMB        in varchar2,                            -- Серия
    nGOODSPARTIES     out number                            -- Рег номер товарного запаса
  )
  is
    nAGENT          PKG_STD.tREF;
    nSUBDIV         PKG_STD.tREF;
    nJUR_PERS       PKG_STD.tREF;
    sCODE           PKG_STD.tSTRING;
    nINCOMDOC       PKG_STD.tREF; 
  begin
    /* Генерация номера */
    P_INCOMDOC_GETNEXTNUMB(nCOMPANY => nCOMPANY, sNUMBER => sCODE);
    /* разрешение ссылок */
    P_INCOMDOC_JOINS(nCOMPANY,
                     sAGENT,
                     nAGENT,
                     null,
                     nSUBDIV,
                     sJUR_PERS,
                     nJUR_PERS);
    /* базовое добавление */
    P_INCOMDOC_BASE_INSERT(nCOMPANY     => nCOMPANY,
                           nJUR_PERS    => nJUR_PERS,
                           sCODE        => sCODE,
                           nAGENT       => nAGENT,
                           nSUBDIV      => null,
                           dENTRY_DATE  => dENTRY_DATE,
                           nOUT_PARTY   => 0,
                           nSTOR_SIGN   => 0,
                           nCOMMIS_SIGN => 0,
                           nRN          => nINCOMDOC);
  
    /* Базовое добавление партии товара */
    P_GOODSPARTIES_BASE_INSERT(nCOMPANY       => nCOMPANY,
                               nINDOC         => nINCOMDOC,
                               nNOMMODIF      => nNOMMODIF,
                               nNOMNMODIFPACK => null,
                               nSIGNBREAK     => 0,
                               dEXPIRY_DATE   => null,
                               sCERTIFICATE   => sCERTIFICATE,
                               sSERNUMB       => sSERNUMB,
                               sBARCODE       => null,
                               nCOUNTRY       => null,
                               sGTD           => null,
                               nPRODUCER      => null,
                               nSTORAGE_TIME  => null,
                               nUMEAS_STORAGE => null,
                               sORIGINAL_NAME => null, -- Оригинальное наименование
                               dPROD_DATE     => null, -- Дата изготовления
                               nRN            => nGOODSPARTIES);
  
  end P_GOODSPARTY_MAKE;
  
  /* Исправление количества в спецификации РН, связанной с КВ */
  procedure SP_UPDATE_QNT
  (
    nDOCUMENT                 in number, -- Рег. номер спецификации РН
    nQUANT                    in number, -- Количество
    nSIGN_DLVR                in number, -- Удалить из комплектования КВ
    nSIGN_DROP                in number  -- Признак удаления резерва
  )
  is
    rSP                       transinvdeptspecs%rowtype; -- Запись спецификации РН
    rDOC                      TRANSINVDEPT%rowtype;      -- Запись накладной
    rCMPL                     fcdelivshspcmpl%rowtype;   -- Запись комплектования КВ
    nDELIVSHSP                pkg_std.tREF;              -- Рег. номер строки КВ
    nRSRV_CLOSE               pkg_std.tREF;              -- Рег. номер резерва (закрываемого)
    nRSRV_REST                pkg_std.tREF;              -- Рег. номер резерва (остаток)
    nCMPL                     pkg_std.tREF;              -- Рег. номер комплектования КВ
    nQUANT_DIFF               pkg_std.tQUANT;            -- Разница с текущим значением
    nQUANT_CLOSE              pkg_std.tQUANT;            -- Кол-во закрываемого резерва
    nQUANT_TMP2               pkg_std.tQUANT;            -- Временная переменная
    rDORDSP_PRF               udo_depords_prf%rowtype;   -- Запись исполнения  
    
    /* Обновление резерва по строке комплектования */
    procedure CMPL_UPDATE_RSRV
    (
      nCMPL in number -- Рег.номер строки 
    )
    is
      dres_start_date date;
    begin 
      /* Резервровать до */
      select min (tt.dres_start_date)
        into dres_start_date
        from (select rj.res_start_date as dres_start_date
                from doclinks   dl,
                     resjournal rj
               where dl.in_document = rj.rn 
                 and dl.in_unitcode = 'ReservationJournal'      
                 and dl.out_unitcode = 'CostDeliverySheetsSpecCompletion'
                 and dl.out_document = nCMPL
                 and rj.res_end_date is null
               union all  
              select rj.res_start_date as dres_start_date
                from doclinks   dl,
                     resjournal rj
               where dl.out_document = rj.rn 
                 and dl.out_unitcode = 'ReservationJournal'      
                 and dl.in_unitcode = 'CostDeliverySheetsSpecCompletion'
                 and dl.in_document = nCMPL
                 and rj.res_end_date is null) tt;
                                
      
      update FCDELIVSHSPCMPL r
       set r.RESERV_QUANT = nvl((select sum(rj.quant)
                               from doclinks   dl,
                                    resjournal rj
                              where dl.in_document = rj.rn 
                                and dl.in_unitcode = 'ReservationJournal'      
                                and dl.out_unitcode = 'CostDeliverySheetsSpecCompletion'
                                and dl.out_document = r.rn
                                and rj.res_end_date is null),0) +  
                             nvl((select sum(rj.quant)
                               from doclinks   dl,
                                    resjournal rj
                              where dl.out_document = rj.rn 
                                and dl.out_unitcode = 'ReservationJournal'      
                                and dl.in_unitcode = 'CostDeliverySheetsSpecCompletion'
                                and dl.in_document = r.rn
                                and rj.res_end_date is null),0),    
            r.reserv_date = dres_start_date
      where r.RN = nCMPL;
    end;  
    
    /* Разделение строки комплектования */
    procedure CMPL_DIVISION 
    (
      rCMPL_SRC       in fcdelivshspcmpl%rowtype, -- Запись комплектования для разделения  
      NQUANT_IN       in number,                  -- Количество для выделения
      nRSRV           in number                   -- Рег. номер резерва для выделения количества
    )
    is
      NCMPL_OUT                 pkg_std.tREF;              -- Строка компелктования, созданная для выделенного резерва
      nDOCIN_CMPL               pkg_std.tREF;              -- Признак комплектования по КВ      	 
      nDOCOUT_CMPL              pkg_std.tREF;              -- Признак комплектования по заказу подразделения
      rDORDSP_PRF               udo_depords_prf%rowtype;   -- Запись исполнения строки заказа подразделения
    begin
      /* считывание привязки к строке заказа подразделения */
      rDORDSP_PRF := udo_pkg_depords_prf.GET(nRSRV => nRSRV,NSMART => 1);
                           
      /* 1. Корректируем запись комплектования для остатка */ 
      /*   1.1 Исправление записи количества в строке комплектования */
      p_fcdelivshspcmpl_base_update(nRN            => rCMPL_SRC.RN,
                                    nCOMPANY       => rCMPL_SRC.COMPANY,
                                    dACT_DATE      => rCMPL_SRC.ACT_DATE,
                                    nMATRES        => rCMPL_SRC.MATRES,
                                    nQUANT         => rCMPL_SRC.Quant - NQUANT_IN,
                                    nCOEFF         => rCMPL_SRC.COEFF,
                                    nROUTLST       => rCMPL_SRC.ROUTLST,
                                    nPARTY         => rCMPL_SRC.PARTY,
                                    nARTICLE       => rCMPL_SRC.ARTICLE,
                                    nVALID_DOCTYPE => rCMPL_SRC.VALID_DOCTYPE,
                                    sVALID_DOCNUMB => rCMPL_SRC.VALID_DOCNUMB,
                                    dVALID_DOCDATE => rCMPL_SRC.VALID_DOCDATE,
                                    sNOTE          => rCMPL_SRC.NOTE);
      /*   1.2 Удаление связи с новым резервом (резерв на выделяемое кол-во) */
      begin 
        /* Резерв из КВ */
        select dl.in_document
          into nDOCIN_CMPL
          from doclinks dl 
         where dl.in_unitcode  = 'CostDeliverySheetsSpecCompletion'
           and dl.in_document  = rCMPL_SRC.RN 
           and dl.out_unitcode = 'ReservationJournal'
           and dl.out_document = nRSRV; 
      exception when no_data_found then 
        nDOCIN_CMPL := null;
      end;
      if nDOCIN_CMPL is not null then
        p_linksall_remove(nCOMPANY      => rCMPL_SRC.Company,
                          sIN_UNITCODE  => 'CostDeliverySheetsSpecCompletion',
                          nIN_DOCUMENT  => rCMPL_SRC.RN,
                          sOUT_UNITCODE => 'ReservationJournal',
                          nOUT_DOCUMENT => nRSRV); 
      end if;              
      begin 
        /* Резерв из заказа подразделения */                
        select dl.in_document
          into nDOCOUT_CMPL
          from doclinks dl 
         where dl.in_unitcode  = 'ReservationJournal'
           and dl.in_document  = nRSRV 
           and dl.out_unitcode = 'CostDeliverySheetsSpecCompletion'
           and dl.out_document = rCMPL_SRC.RN; 
      exception when no_data_found then 
        nDOCOUT_CMPL := null;
      end;
      if nDOCOUT_CMPL is not null then
        p_linksall_remove(nCOMPANY      => rCMPL_SRC.Company,
                          sIN_UNITCODE  => 'ReservationJournal',
                          nIN_DOCUMENT  => nRSRV,
                          sOUT_UNITCODE => 'CostDeliverySheetsSpecCompletion',
                          nOUT_DOCUMENT => rCMPL_SRC.RN);                           
      end if;           
                
      /*   1.3 Обновление кол-ва резерва по строке комплектования*/            
      CMPL_UPDATE_RSRV(nCMPL => rCMPL_SRC.RN);
                
      
      
      
      
      /* 2. Добавляем запись комплектования для нового резерва */
      /*   2.1 Добавление записи строки компектования */
      p_fcdelivshspcmpl_base_insert(nCOMPANY       => rCMPL_SRC.COMPANY,
                                    nPRN           => rCMPL_SRC.PRN,
                                    nACT           => rCMPL_SRC.ACT,
                                    dACT_DATE      => rCMPL_SRC.ACT_DATE,
                                    nDELIVSHSP     => rCMPL_SRC.DELIVSHSP,
                                    nCMPL          => rCMPL_SRC.CMPL,
                                    nMATRES        => rCMPL_SRC.MATRES,
                                    nQUANT         => NQUANT_IN,
                                    nCOEFF         => rCMPL_SRC.COEFF,
                                    nROUTLST       => rCMPL_SRC.ROUTLST,
                                    nPARTY         => rCMPL_SRC.PARTY,
                                    nARTICLE       => rCMPL_SRC.ARTICLE,
                                    nVALID_DOCTYPE => rCMPL_SRC.VALID_DOCTYPE,
                                    sVALID_DOCNUMB => rCMPL_SRC.VALID_DOCNUMB,
                                    dVALID_DOCDATE => rCMPL_SRC.VALID_DOCDATE,
                                    sNOTE          => rCMPL_SRC.NOTE,
                                    nRN            => NCMPL_OUT);
      PKG_FLAG.SET_FLAG; -- повторно выставляем,т.к. в процедуре p_fcdelivshspcmpl_base_insert есть с ним работа
                
      /*   2.2 Восставновление связей со строкой комплектования */
      if nDOCIN_CMPL is not null then 
        /* При комплектовании из КВ */
        p_linksall_link_direct(nCOMPANY          => rCMPL_SRC.COMPANY,
                               sIN_UNITCODE      => 'CostDeliverySheetsSpecCompletion',
                               nIN_DOCUMENT      => NCMPL_OUT,
                               nIN_PRN_DOCUMENT  => null,
                               dIN_IN_DATE       => trunc(sysdate),
                               nIN_STATUS        => 0,
                               sOUT_UNITCODE     => 'ReservationJournal',
                               nOUT_DOCUMENT     => nRSRV,
                               nOUT_PRN_DOCUMENT => null,
                               dOUT_IN_DATE      => trunc(sysdate),
                               nOUT_STATUS       => 0);
      elsif nDOCOUT_CMPL is not null then 
         /* При комплектовании из заказа подразделения */
         p_linksall_link_direct(nCOMPANY          => rCMPL_SRC.COMPANY,
                               sIN_UNITCODE      => 'ReservationJournal',
                               nIN_DOCUMENT      => nRSRV,           
                               nIN_PRN_DOCUMENT  => null,
                               dIN_IN_DATE       => trunc(sysdate),
                               nIN_STATUS        => 0,
                               sOUT_UNITCODE     => 'CostDeliverySheetsSpecCompletion',
                               nOUT_DOCUMENT     => NCMPL_OUT,
                               nOUT_PRN_DOCUMENT => null,
                               dOUT_IN_DATE      => trunc(sysdate),
                               nOUT_STATUS       => 0);                      
      else 
        p_exception(0 , 'Не удалось определить строку комплектования для воставновления резерва на уменьшаемое количество.');
      end if;
                
      /*   2.3 Обновление кол-ва резерва по строке комплектования*/            
      CMPL_UPDATE_RSRV(nCMPL => NCMPL_OUT);
      
      /* 2.4 Обновление ссылки на строку комплектования в таблице исполнения ЗП */     
      if rDORDSP_PRF.dordsp is not null then  
        udo_pkg_depords_prf.SET_CMPL(nDORDSP => rDORDSP_PRF.dordsp,
                                      nRSRV  => nRSRV,
                                      nCMPL  => NCMPL_OUT);
      end if;                                
    end;
    
    
  begin
    if nvl(nQUANT,0) < 0 then   
      p_exception(0, 'Новое значение количества должно быть больше, либо равно 0.');
    end if;
    /* Считывание записи спецификации */
    rSP := udo_pkg_get.ROW_TRANSINVDEPTSPECS(NRN => nDOCUMENT,NSMART => 0);
    
    /* Считывание записи накладной */
    rDOC := UDO_PKG_GET.ROW_TRANSINVDEPT(NRN => rSP.Prn, NSMART => 0);
    
    if rDOC.Status > 0 then
      p_exception(0, 'Накладная в состоянии Отработано. Изменение невозможно.');
    end if;
    
    /* Проверям связана ли РН с КВ*/
    nDELIVSHSP := f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',nOUT_DOCUMENT => nDOCUMENT, sIN_UNITCODE  => 'CostDeliverySheetsSpec');
    if nDELIVSHSP is null then 
      p_exception(0, 'Действие доступно только для строк РН связанных с КВ.');
    end if;
    
    /* 12/06/2023 Марков МВ. Контроль истории статусов расходной накладной */
    P_TRINVDEPT_QNT_CHECK_EVNSTATE(nRN => rDOC.Rn);
    if rtrim(rSP.Note) is null then
      null; -- 13/06/2023 Марков МВ. Убрал контроль о просьбе Стрижовой
      --p_exception(0, 'При изменении количества необходимо указать в примечании спецификации причину исправления.');
    end if;
    
    PKG_FLAG.SET_FLAG; 
    
    /* Обрабатываем только уменьшение, т.к. увеличение выдачи проводим только через КВ */
    if nQUANT < rSP.Quant then
      
      /* Разница между исходным и новым кол-вами */
      nQUANT_DIFF := rSP.Quant - nQUANT; 
      
      /*Отражаем изменения в журнале резервирования */
      for cur in (select rj.rn as nRSRV,
                         rj.quant
                    from doclinks          dl,
                         resjournal        rj
                   where dl.out_document = rSP.Rn
                     and dl.out_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
                     and dl.in_unitcode  = 'ReservationJournal'
                     and dl.in_document  = rj.rn
                     and rj.res_end_date is null
                   order by rj.quant)
      loop
        /* считывание привязки резерва к стрке комплектования КВ (через таблицу исполнения для резерва из заказов подразделений) */
        nCMPL := udo_pkg_depords_prf.GET_CMPL_BY_RSRV(nRSRV => cur.nrsrv,NSMART => 1);  
        /* Запись комплектования КВ */
        rCMPL := udo_pkg_get.ROW_FCDELIVSHSPCMPL(NRN => nCMPL, NSMART => 1);
        
        /* определим нужно ли разбивать резерв */ 
        if nQUANT_DIFF >= cur.quant then 
          nRSRV_CLOSE  := cur.nRSRV;
          nQUANT_CLOSE := cur.quant;
        else 
          /* разбиваем резерв  */
          udo_pkg_resjournal_ctrl.DIVISION(NRESJOURNAL_SRC  => cur.nRSRV,
                                           NQUANT_IN        => nQUANT_DIFF,
                                           NRESJOURNAL_IN   => nRSRV_CLOSE, -- выделяемое кол-во (резерв для закрытия)
                                           NRESJOURNAL_REST => nRSRV_REST);  -- остаток (резерв который должен остаться )
          nQUANT_CLOSE := nQUANT_DIFF;
        end if;    
      
        /* удаляем связь строки РН с резервом для восстановления возможности выдать повторно по строке комплектования */ 
        p_linksall_remove(nCOMPANY      => rSP.Company,
                          sIN_UNITCODE  => 'ReservationJournal',
                          nIN_DOCUMENT  => nRSRV_CLOSE,
                          sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
                          nOUT_DOCUMENT => rSP.Rn);                
        
        /* Указан признак "Удалить из комплектования" (уменьшения кол-ва в комплектовании КВ) */
        if nvl(nSIGN_DLVR,0) = 1 then
          
          /* •	Уменьшить значение «Количество» и «Количество зарезервированное» на уменьшенное количество по строке спецификации накладной.
             •	Закрыть старый резерв, удалить линки со старым резервом с сохранением линков для восстановления с новым резервом.
             •	Создать новый резерв на новое количество. Добавить линки, которые были у старого резерва.
             •	Если старый резерв был связан с записью в разделе «Заказы подразделений», 
                то создать новый резерв, связанный с этой же записью заказа подразделения на уменьшенное количество.*/                
                              
          /* Закрываем резерв, если указан признак удаления резерва */
          if nvl(nSIGN_DROP,0) = 1 then
            udo_pkg_resjournal_ctrl.TAKE(NDOCUMENT => nRSRV_CLOSE,
                                         SNOTE     => 'Резервирование закрыто при изменении количества в расходной накладной.');
            
            /* Удаляем связи с закрытым резервом (для восстановления возможности выдать повторно по строке комплектования) */
            p_linksall_remove(nCOMPANY      => rSP.Company,
                              sIN_UNITCODE  => null,
                              nIN_DOCUMENT  => null,
                              sOUT_UNITCODE => 'ReservationJournal',
                              nOUT_DOCUMENT => nRSRV_CLOSE);
            
            p_linksall_remove(nCOMPANY      => rSP.Company,
                              sIN_UNITCODE  => 'ReservationJournal',
                              nIN_DOCUMENT  => nRSRV_CLOSE,
                              sOUT_UNITCODE => null,
                              nOUT_DOCUMENT => null);
          end if;
          
          /* Отражаем изменения в КВ (резервирование из заказа подразделения)*/
          if nCMPL is not null then 
            
            /* Удаление связи строки комплектации с новым резервом (резерв на выделяемое кол-во) */
            p_linksall_remove(nCOMPANY      => rDOC.Company,
                              sIN_UNITCODE  => 'ReservationJournal',
                              nIN_DOCUMENT  => nRSRV_CLOSE,
                              sOUT_UNITCODE => 'CostDeliverySheetsSpecCompletion',
                              nOUT_DOCUMENT => rCMPL.RN);
            p_linksall_remove(nCOMPANY      => rDOC.Company,
                              sIN_UNITCODE  => 'ReservationJournal',
                              nIN_DOCUMENT  => nRSRV_CLOSE,
                              sOUT_UNITCODE => 'CostDeliverySheets',
                              nOUT_DOCUMENT => null);
                              
            /* считывание привязки к строке заказа подразделения */
            rDORDSP_PRF := udo_pkg_depords_prf.GET(nRSRV => nRSRV_CLOSE,NSMART => 1);   
            /* Обнуление кол-ва скомплектовано по строке исполнения заказа подразделения */
            if rDORDSP_PRF.dordsp is not null then 
              udo_pkg_depords_prf.SET_CMPL(nDORDSP => rDORDSP_PRF.dordsp,
                                            nRSRV  => nRSRV_CLOSE,
                                            nCMPL  => null);                       
            end if;  
                    
            /* Если кол-во в комплектовании,меньше разницы, то удаляем запись */
            if nQUANT_CLOSE >= rCMPL.Quant then
              -- обнулим дату резервирования
              update FCDELIVSHSPCMPL DCM set DCM.RESERV_DATE = to_date(null) where DCM.RN = rCMPL.Rn;
              -- удалим строку комплектования
              p_fcdelivshspcmpl_base_delete(nRN => rCMPL.RN, nCOMPANY => rCMPL.COMPANY);
            
            /* Иначе корректирум запись комплектования */
            else 
              p_fcdelivshspcmpl_base_update(nRN            => rCMPL.RN,
                                            nCOMPANY       => rCMPL.COMPANY,
                                            dACT_DATE      => rCMPL.ACT_DATE,
                                            nMATRES        => rCMPL.MATRES,
                                            nQUANT         => rCMPL.Quant - nQUANT_CLOSE,
                                            nCOEFF         => rCMPL.COEFF,
                                            nROUTLST       => rCMPL.ROUTLST,
                                            nPARTY         => rCMPL.PARTY,
                                            nARTICLE       => rCMPL.ARTICLE,
                                            nVALID_DOCTYPE => rCMPL.VALID_DOCTYPE,
                                            sVALID_DOCNUMB => rCMPL.VALID_DOCNUMB,
                                            dVALID_DOCDATE => rCMPL.VALID_DOCDATE,
                                            sNOTE          => rCMPL.NOTE);
            
              /* Обновление кол-ва резерва по строке */
              CMPL_UPDATE_RSRV(nCMPL => rCMPL.RN);                             
            end if;
            
          /* Резервирование из КВ */  
          else   
            nQUANT_TMP2 := nQUANT_CLOSE;
            /* цикл по связанным со строкой РН комплектациям КВ*/
            for rec in (select t.*
                          from fcdelivshspcmpl t,
                               doclinks        dl
                         where t.prn           = nDELIVSHSP
                           and t.party         = rSP.goodsparty
                           and dl.in_unitcode  = 'CostDeliverySheetsSpecCompletion'
                           and dl.in_document  = t.rn
                           and dl.out_unitcode = 'ReservationJournal'
                           and dl.out_document = nRSRV_CLOSE) 
            loop
              /* Если кол-во в комплектовании,меньше разницы, то удаляем запись */
              if nQUANT_TMP2 >= rec.Quant then
                  -- обнуляем резервирование
                  update FCDELIVSHSPCMPL r
                     set r.RESERV_QUANT = 0, r.reserv_date = to_date(null)  
                   where r.RN = rec.RN;
                p_fcdelivshspcmpl_base_delete(nRN => rec.RN, nCOMPANY => rec.COMPANY);
              
              /* Иначе корректирум запись комплектования */
              else 
                p_fcdelivshspcmpl_base_update(nRN            => rec.RN,
                                              nCOMPANY       => rec.COMPANY,
                                              dACT_DATE      => rec.ACT_DATE,
                                              nMATRES        => rec.MATRES,
                                              nQUANT         => rec.Quant - nQUANT_TMP2,
                                              nCOEFF         => rec.COEFF,
                                              nROUTLST       => rec.ROUTLST,
                                              nPARTY         => rec.PARTY,
                                              nARTICLE       => rec.ARTICLE,
                                              nVALID_DOCTYPE => rec.VALID_DOCTYPE,
                                              sVALID_DOCNUMB => rec.VALID_DOCNUMB,
                                              dVALID_DOCDATE => rec.VALID_DOCDATE,
                                              sNOTE          => rec.NOTE);
              
                  /* Обновление кол-ва резерва по строке */
                  CMPL_UPDATE_RSRV(nCMPL => rec.RN);
              end if;   
              
              /* Если резервирование было выполнено в разделе «Комплектовочные ведомости», то новый резерв не создается. 
                 Уменьшенное количество остается свободным остатком */
              if nvl(nSIGN_DROP,0) = 0 then
                udo_pkg_resjournal_ctrl.TAKE(NDOCUMENT => nRSRV_CLOSE,
                                         SNOTE     => 'Резервирование закрыто при изменении количества в расходной накладной.');
                p_linksall_remove(nCOMPANY      => rSP.Company,
                                  sIN_UNITCODE  => null,
                                  nIN_DOCUMENT  => null,
                                  sOUT_UNITCODE => 'ReservationJournal',
                                  nOUT_DOCUMENT => nRSRV_CLOSE);
                
                p_linksall_remove(nCOMPANY      => rSP.Company,
                                  sIN_UNITCODE  => 'ReservationJournal',
                                  nIN_DOCUMENT  => nRSRV_CLOSE,
                                  sOUT_UNITCODE => null,
                                  nOUT_DOCUMENT => null);
              end if;            
              
              nQUANT_TMP2 := nQUANT_TMP2 - rec.Quant;
              exit when nQUANT_TMP2 <= 0; 
            end loop rec;
          end if;
        
        /* не указан признак "Удалить из комплектования"*/
        else          
        /*•	Уменьшить значение «Количество» и «Количество зарезервированное» на уменьшенное количество по строке спецификации накладной.
          •	Закрыть старый резерв, удалить линки со старым резервом с сохранением линков для восстановления с новым резервом.
          •	Создать новый резерв на новое количество. Добавить линки, которые были у старого резерва.          
          •	Добавить новую строку в «Комплектование» на уменьшенное количество. 
            Добавить новый резерв на уменьшенное количество. Добавить линки, аналогичные старого резерва. 
            Новая строка должна быть доступна для формирования новой расходной накладной*/
                    
          /* Отражаем изменения в КВ (резервирование из заказа подразделения)*/
          if nCMPL is not null then 
             
            /* Если кол-во в комплектовании,меньше разницы, то не трогаем запись, т.к. она уже доступна для последующей выдачи */
            if nQUANT_CLOSE >= rCMPL.Quant then
              null;
            /* Иначе разбиваем запись комплектования на величину выделяемого резерва */
            else
              CMPL_DIVISION(rCMPL_SRC => rCMPL,
                            NQUANT_IN => nQUANT_CLOSE,
                            nRSRV     => nRSRV_CLOSE);            
            end if; 
            
          /* Резервирование из КВ */
          else             
            nQUANT_TMP2 := nQUANT_CLOSE;
            /* цикл по связанным со строкой РН комплектациям КВ*/
            for rec in (select t.*
                          from fcdelivshspcmpl t,
                               doclinks        dl
                         where t.prn           = nDELIVSHSP
                           and t.party         = rSP.goodsparty
                           and dl.in_unitcode  = 'CostDeliverySheetsSpecCompletion'
                           and dl.in_document  = t.rn
                           and dl.out_unitcode = 'ReservationJournal'
                           and dl.out_document = nRSRV_CLOSE) 
            loop
              /* Если кол-во в комплектовании,меньше разницы, то не трогаем запись, т.к. она уже доступна для последующей выдачи */
              if nQUANT_TMP2 >= rec.Quant then
                null;                
              /* Иначе разбиваем запись комплектования на величину выделяемого резерва */
              else 
                CMPL_DIVISION(rCMPL_SRC => rec,
                              NQUANT_IN => nQUANT_TMP2,
                              nRSRV     => nRSRV_CLOSE);
              end if;   
              
              nQUANT_TMP2 := nQUANT_TMP2 - rec.Quant;
              exit when nQUANT_TMP2 <= 0; 
            end loop rec;
            
          end if;
        end if;
        
        nQUANT_DIFF := nQUANT_DIFF - nQUANT_CLOSE;
        exit when nQUANT_DIFF <= 0;        
      end loop cur; 
      
      /* Отражаем изменения в распределении по местам хранения (МХ для списания) */
      nQUANT_DIFF := rSP.Quant - nQUANT; 
      for cur in (select t.*
                    from STRPLRESJRNL t
                   where t.RES_TYPE = 1
                     and exists (select *
                            from V_DOCLINKS_INOUT_IN_EXT DLIN
                           where (DLIN.NIN_DOCUMENT = rSP.Rn)
                             and (DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')
                             and (DLIN.NDOCUMENT = t.RN)))
      loop 
        /* определим нужно ли разбивать резерв по МХ */ 
        if nQUANT_DIFF >= cur.quant then  
          nQUANT_CLOSE := cur.quant;
        else 
          nQUANT_CLOSE := nQUANT_DIFF;
        end if;  
        
        /* удаляем если уменьшается все кол-во с МХ */
        if nQUANT_CLOSE = cur.quant then 
          p_strplresjrnl_base_delete(nCOMPANY => cur.company,nRN =>  cur.rn);
        
        /* обновляем если уменьшаем не все количество с МХ*/
        else 
          p_strplresjrnl_base_update(nCOMPANY        => cur.company,
                                     nRN             => cur.rn,
                                     sAUTHID         => cur.authid,
                                     nCELL           => cur.cell,
                                     nGOODSSUPPLY    => cur.goodssupply,
                                     nNOMMODIF       => cur.nommodif,
                                     nNOMNMODIFPACK  => cur.nomnmodifpack,
                                     nARTICLE        => cur.article,
                                     nGOODSUNIT      => cur.goodsunit,
                                     dRESERVING_DATE => cur.reserving_date,
                                     nQUANT          => cur.quant - nQUANT_CLOSE,
                                     nQUANTALT       => cur.QUANTALT,
                                     nCHECK_PARTY    => 0);
        end if;
        
        nQUANT_DIFF := nQUANT_DIFF - nQUANT_CLOSE;
        exit when nQUANT_DIFF <= 0;   
      end loop cur;
      
       /* Отражаем изменения в распределении по местам хранения (МХ для распределения) */
      nQUANT_DIFF := rSP.Quant - nQUANT; 
      for cur in (select t.*
                    from STRPLRESJRNL t
                   where t.RES_TYPE = 0
                     and exists (select *
                            from V_DOCLINKS_INOUT_IN_EXT DLIN
                           where (DLIN.NIN_DOCUMENT = rSP.Rn)
                             and (DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')
                             and (DLIN.NDOCUMENT = t.RN)))
      loop 
        /* определим нужно ли разбивать резерв по МХ */ 
        if nQUANT_DIFF >= cur.quant then  
          nQUANT_CLOSE := cur.quant;
        else 
          nQUANT_CLOSE := nQUANT_DIFF;
        end if;  
        
        /* удаляем если уменьшается все кол-во с МХ */
        if nQUANT_CLOSE = cur.quant then 
          p_strplresjrnl_base_delete(nCOMPANY => cur.company,nRN =>  cur.rn);
        
        /* обновляем если уменьшаем не все количество с МХ*/
        else 
          p_strplresjrnl_base_update(nCOMPANY        => cur.company,
                                     nRN             => cur.rn,
                                     sAUTHID         => cur.authid,
                                     nCELL           => cur.cell,
                                     nGOODSSUPPLY    => cur.goodssupply,
                                     nNOMMODIF       => cur.nommodif,
                                     nNOMNMODIFPACK  => cur.nomnmodifpack,
                                     nARTICLE        => cur.article,
                                     nGOODSUNIT      => cur.goodsunit,
                                     dRESERVING_DATE => cur.reserving_date,
                                     nQUANT          => cur.quant - nQUANT_CLOSE,
                                     nQUANTALT       => cur.QUANTALT,
                                     nCHECK_PARTY    => 0);
        end if;
        
        nQUANT_DIFF := nQUANT_DIFF - nQUANT_CLOSE;
        exit when nQUANT_DIFF <= 0;  
      end loop cur;
      
      /* Удаляем спецификацию РН при 0 */
      if nvl(nQUANT,0) = 0 then
        /* удаление спецификации */
        /* 20/11/2025 Степанов М. заменил процедуру удаления спецификации на нашу, убрал удаление связей, т.к. в нашей есть */
        -- p_transinvdeptsp_base_delete(nCOMPANY => rSP.Company, nRN => rSP.Rn);
        usr_pkg_transinvdept.transinvdeptspecs_base_delete(ncompany => rSP.Company, nrn => rSP.Rn, nmode => 1);
      else 
        /* Обновляем кол-во в спецификации РН*/
        update TRANSINVDEPTSPECS t 
           set t.quant = nQUANT
         where t.rn = nDOCUMENT;
      end if;  
      
    elsif nQUANT < rSP.Quant then 
      PKG_FLAG.RESET_FLAG; 
      p_exception(0, 'Увеличение количества выдаваемых ТМЦ возможно только через проведение изменений в КВ. Скомплектуйте доп. кол-во в КВ и сформируйте РН.');
    end if; 
    
    PKG_FLAG.RESET_FLAG; 
  end;
  
  /* 12/09/2023 Марков МВ. Неизменность полей для возвратной накладной */
  procedure P_TRANSINVDEP_RET_CHECK
  (
    rROW       in TRANSINVDEPT%rowtype,
    nIN_STORE   in number,
    nIN_MOL     in number,
    nIN_STOPER  in number,
    nIN_STORE_  out number,
    nIN_MOL_    out number,
    nIN_STOPER_ out number
  ) is
    nFACTRET_SIGN number(17);
  begin
    nIN_STORE_  := nIN_STORE;
    nIN_MOL_    := nIN_MOL;
    nIN_STOPER_ := nIN_STOPER;
    /* 23/01/2026 Степанов М. отключение восстановления значений склада-получателя при выполнении определённых процедур */
    if nvl( upper( usr_pkg_process.process_get ), 'null' ) in ( 'USR_P_TID_IN_STORE_CLEAR' ) then
      return;
    end if;
    
    if rROW.In_Store is null or rROW.In_Stoper is null then -- 22/09/2023 Марков МВ. почему-то указана операция прихода без наличия склада
      return;
    end if;
    /* считывание текущих параметров */
    select STO.FACTRET_SIGN
      into nFACTRET_SIGN
      from AZSGSMWAYSTYPES STO
     where STO.RN = rROW.In_Stoper;
    -- для возвратной операции сохраняем старые значения
    if nFACTRET_SIGN = 1 then
      nIN_STORE_  := rROW.In_Store;
      nIN_MOL_    := rROW.In_Mol;
      nIN_STOPER_ := rROW.In_Stoper;
    end if;
  end P_TRANSINVDEP_RET_CHECK;
  
end UDO_PKG_TRANSINVDEP_BASE_UTL;
/
