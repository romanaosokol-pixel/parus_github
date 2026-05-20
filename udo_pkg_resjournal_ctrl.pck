create or replace package UDO_PKG_RESJOURNAL_CTRL is

  -- Author  : ЦИТК "Парус"
  -- Created : 22.11.2016
  -- Purpose : Пакет для управления резервированием ТЗ
  -- grant execute on UDO_PKG_RESJOURNAL_CTRL  to public;
  
  --NDEPARTMENTORDS number;

  -- зарезервированное количество по номенклатуре заказа подразделения
  /*function GET_QUANT_BY_ORDER
  (
    NORDER     in number -- рег. номер заказа подразделений
   ,NMODIF     in number -- рег. номер модификации номенклатуры
   ,NMODIFPACK in number -- рег. номер упаковки модификации номенклатуры
   ,DRESDATE   in date default null -- дата резервирования
  ) return number;*/

  -- количество доступное для резервироания по спецификации заказа подразделения
  function GET_QUANTERST_BY_ORDER
  (
    nDEPORDS   in number -- рег. номер спецификации заказа подразделений
  ) return number;

  --Процедура резервирования ТЗ из заказа подразделения
  procedure MAKE_BY_DORD
  (    
    NDOCUMENT                 in number, -- Рег. номер заказа
    sSTORE                    in varchar2  -- Склад для резервироания 
  );

  --Процедура резервирования ТЗ из спецификации заказа подразделения
  procedure MAKE_BY_DORDS
  (
    NDOCUMENT                 in number, -- Рег. номер спецификации заказа
    sSTORE                    in varchar2  -- Склад для резервироания 
  );

  --Процедура резервирования ТЗ из спецификации заказа подразделения
  procedure MAKE_BY_DORDS_EX
  (
    NSUPPLY                   in number -- рег. номер товарного запаса
   ,NQUANT                    in number -- кол-во
   ,nDEPORDS                  in number default null -- рег. номер спецификации заказа подразделения  
   ,nRSRV                     out number -- рег. номер журнала резервирования
   ,nSIGN_FREE                in number default 0 -- Признак резервирования из свободного остатка (1 - да)
  );
   
  --Процедура резервирования ТЗ из приходного ордера по заказам подразделений
  /*procedure MAKE_BY_INORDER
  (
    NCOMPANY  in number
   ,NDOCUMENT in number
  );*/

  -- Процедура закрытия резерва
  procedure TAKE
  (
    NDOCUMENT  in number -- рег. номер записи резерва
   ,SNOTE      in varchar default null -- примечание
   ,NLINK_DROP in number default 0 -- признак удаления связей резерва (0-не удалять, 1 удалять)
   ,NDORDS_SETNULL in number default 0 -- признак обнуления исполнения (0-не обнулять, 1 - обнулять )
  );

  --Процедура снятия резервирования ТЗ из приходного ордера по заказам подразделений
  --procedure TAKE_BY_INORDERS(NDOCUMENT in number);

  --Процедура снятия резервирования ТЗ из заказа подразделений
  procedure TAKE_BY_DORD
  (
    NDOCUMENT        in number
   ,NDOCUMENT_PARENT in number
  );

  --Процедура снятия резервирования ТЗ из спецификации заказа подразделений
  procedure TAKE_BY_DORDS
  (
    NDOCUMENT        in number
   ,NDOCUMENT_PARENT in number
  );

  -- разбиение резерва на 2 части
  procedure DIVISION
  (
    NRESJOURNAL_SRC           in number -- рег. номер записи резерва источника
   ,NQUANT_IN                 in number -- кол-во для выделения
   ,NRESJOURNAL_IN            out number -- рег. номер записи резерва с выделенным количеством
   ,NRESJOURNAL_REST          out number -- рег. номер записи резерва с остатком количества
  );
  
  /*Процедура выполняет закрытие резервов перед отработкой расходной накладной в подразделения */
  procedure RSRV_CLOSE_TRNSINVDPT
  (
    NRN                       in number --Регистрационный номер записи расходной накладной
  );
  
  /*Процедура выполняет восстановление резервов перед снятием отработки с расходной накладной в подразделения */
  procedure RSRV_OPEN_TRNSINVDPT
  (
    NRN                       in number --Регистрационный номер записи расходной накладной
  );

  /* Процедура контроля снятия резерва из Журнала */
  procedure RSRV_CLOSE_CHECK(nRN in number);

end UDO_PKG_RESJOURNAL_CTRL;
/
create or replace package body UDO_PKG_RESJOURNAL_CTRL is

  /* зарезервированное количество по строке заказа подразделения */
  function GET_QUANT_BY_ORDERS
  (
    NORDERS    in number -- рег. номер строки заказа подразделений
  ) return number is
    ntmp       pkg_std.tREF; -- временная переменная  
    NRES       number;       -- результат работы
  begin  
    udo_pkg_depords_prf.p_departmentords_calc_res_qnt(ncompany        => null,
                                                      nrn             => NORDERS,
                                                      nquant_perf     => nres,
                                                      nquant_perf_alt => ntmp);
    
    return NVL(NRES, 0);
  end;
  
  
  -- зарезервированное количество по номенклатуре заказа подразделения
  function GET_QUANT_BY_ORDER
  (
    NORDER     in number -- рег. номер заказа подразделений
   ,NMODIF     in number -- рег. номер модификации номенклатуры
   ,NMODIFPACK in number -- рег. номер упаковки модификации номенклатуры
  ) return number is
    RORDS      DEPARTMENTORDS%rowtype; -- запись заказа подразделений  
    ntmp       pkg_std.tREF; -- временная переменная  
    NRES       number;       -- результат работы
  begin
    -- запись заказа подразделений
    begin
      select T.*
        into RORDS
        from DEPARTMENTORDS T
       where T.PRN = NORDER
         and t.Nom_Modif = NMODIF
         and CMP_NUM(t.Nommod_Pack,NMODIFPACK) = 1;
    exception
      when NO_DATA_FOUND then
        p_exception(0,'Не найдена строка заказа подразделения. Рег. номер заголовка "%s" и рег. номер модификации "%s".',NORDER, NMODIF);
    end;
    
    udo_pkg_depords_prf.p_departmentords_calc_res_qnt(ncompany => null,
                                                     nrn => RORDS.rn,
                                                     nquant_perf => nres,
                                                     nquant_perf_alt => ntmp);
    
    return NVL(NRES,0);
  end;
  
  -- зарезервированное количество по номенклатуре заказа потребителей
  function GET_QUANT_BY_СORDER
  (
    NORDER     in number -- рег. номер заказа подразделений
   ,NMODIF     in number -- рег. номер модификации номенклатуры
   ,NMODIFPACK in number -- рег. номер упаковки модификации номенклатуры
   ,DRESDATE   in date default null -- дата резервирования
  ) return number is
    RСORD CONSUMERORD%rowtype; -- запись заказа подразделений
    NRES number; -- результат работы
  begin
    -- запись заказа подразделений
    begin
      select T.*
        into RСORD
        from CONSUMERORD T
       where T.RN = NORDER;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0
                                ,NORDER
                                ,'CONSUMERORD');
    end;
    -- кол-во резерва для заказа по номенклатуре
    select sum(R.QUANT)
      into NRES
      from RESJOURNAL   R
          ,GOODSPARTIES GP
          ,GOODSSUPPLY  GS
     where R.SUPPLY = GS.RN
       and GS.PRN = GP.RN
       and GP.NOMMODIF = NMODIF
       and CMP_NUM(GP.NOMNMODIFPACK
                  ,NMODIFPACK) = 1
       and R.DOCTYPE = RСORD.ORD_DOCTYPE
       and trim(R.DOCPREF) = trim(RСORD.ORD_PREF)
       and trim(R.DOCNUMB) = trim(RСORD.ORD_NUMB)
       and R.DOCDATE = RСORD.ORD_DATE
       and R.RES_END_DATE is null
       and (R.RES_START_DATE <= DRESDATE or DRESDATE is null);
    return NVL(NRES
              ,0);
  end;
  
  -- количество доступное для резервироания по спецификации заказа подразделения
  function GET_QUANTERST_BY_ORDER
  (
    nDEPORDS   in number -- рег. номер спецификации заказа подразделений
  ) return number is
    RDORDS     DEPARTMENTORDS%rowtype; -- запись спецификации заказа подразделений
    NRES       number; -- результат работы
  begin
   -- запись заказа подразделений
    begin
      select T.*
        into RDORDS
        from DEPARTMENTORDS T
       where T.RN = nDEPORDS;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0
                                ,nDEPORDS
                                ,'DEPARTMENTORDS');
    end;
    
    -- кол-во доступное по заказу 
    NRES := RDORDS.Main_Quant 
            -- - nvl(F_DEPARTMENTORDPS_GET_NPARAM(1,RDORDS.RN,0,'P_FACTM_QUANT' ),0)
            - nvl(UDO_F_PRODORDSP_TRANSINV(NRN => nDEPORDS,nCOMPANY => RDORDS.COMPANY),0)
            - GET_QUANT_BY_ORDERS(NORDERS => nDEPORDS);
  
   return (nRES);
  end;
  
  /*
  
  --  Процедура снятия резервирования ТЗ по заявкам на закупку инструмента по помеченным записям спецификации ПО
  procedure P_RESJOURNAL_ORDPUR_DEL
  (
    NCOMPANY in number
   ,NCRN     in number
   ,NIDENT   in number
  ) is
    \*
      Передадов А.Ю.
      09.07.2015
    *\
    NCNT number;
  begin
    -- проверка прав доступа
    PKG_ENV.ACCESS(NCOMPANY => NCOMPANY
                  ,NVERSION => null
                  ,NCATALOG => NCRN
                  ,SUNIT    => 'ORDER_PURCHASE_TOOLS_IOR'
                  ,SACTION  => 'UDO_RESJOURNAL_ORDPUR_DEL');
    for CUR in (select RJ.*
                      ,PKG_DOCUMENT.MAKE_NUMBER(NDOC_TYPE => D.ORD_DOCTYPE
                                               ,SDOC_PREF => D.ORD_PREF
                                               ,SDOC_NUMB => D.ORD_NUMB
                                               ,DDOC_DATE => D.ORD_DATE) SDOC_NUMB
                  from UDO_V_ORDER_PURCHASE_TOOLS_IOR T
                      ,UDO_V_ORDER_PURCHASE_TOOLS_PAY P
                      ,SELECTLIST                     SL
                      ,RESJOURNAL                     RJ
                      ,DEPARTMENTORD                  D
                 where T.NRN = SL.DOCUMENT
                   and SL.IDENT = NIDENT
                   and RJ.RES_END_DATE is null
                   and RJ.SUPPLY = T.NGOODSSUPPLY
                   and P.RN = T.NPRN
                   and P.NDEPARTMENTORD = D.RN)
    loop
      -- проверка привязки резерва к расходным документам
      select count(DL.RN)
        into NCNT
        from DOCLINKS DL
       where DL.IN_DOCUMENT = CUR.RN
         and DL.IN_UNITCODE = 'ReservationJournal'
         and DL.OUT_UNITCODE = 'DepartmentsOrders';
      if NVL(NCNT
            ,0) != 0
      then
        P_EXCEPTION(0
                   ,'Невозможно закрыть запись журнала резервирования. По текущему резерву существует связь с расходными документами.');
      end if;
      -- снятие резерва
      P_RESJOURNAL_STORN(NCOMPANY => CUR.COMPANY
                        ,NRN      => CUR.RN
                        ,SNOTES   => 'Резерв снят пользователем "' ||
                                     GET_USERLIST_NAME_ID(NFLAG_SMART => 0
                                                         ,SAUTHID     => UTILIZER) ||
                                     '" из заявки на закупку инструмента "' ||
                                     CUR.SDOC_NUMB || '".');
    end loop CUR;
  end;
  
  --Процедура восстановления резерва по заявкам на закупку инструмента при снятии отработке расходной накладной
  procedure P_RESJOURNAL_TRINVDEPT_OPEN(NRN in number) is
  begin
    for CUR in (select RJ.*
                      ,PKG_DOCUMENT.MAKE_NUMBER(NDOC_TYPE => TR.DOCTYPE
                                               ,SDOC_PREF => TR.PREF
                                               ,SDOC_NUMB => TR.NUMB
                                               ,DDOC_DATE => TR.DOCDATE) SDOC_NUMB
                  from TRANSINVDEPT      TR
                      ,TRANSINVDEPTSPECS TRS
                      ,DOCLINKS          DL
                      ,RESJOURNAL        RJ
                 where TR.RN = NRN
                   and TR.RN = TRS.PRN
                   and DL.OUT_DOCUMENT = TRS.RN
                   and DL.IN_DOCUMENT = RJ.RN)
    loop
      -- восстановление резерва
      update RESJOURNAL
         set RES_END_DATE = null
            ,NOTES        = SUBSTR('Резервирование восстановлено из расходной накладной на отпуск в подразделение "' ||
                                   CUR.SDOC_NUMB || '".' || NOTES
                                  ,1
                                  ,240)
       where RN = CUR.RN
         and COMPANY = CUR.COMPANY;
      \* отражение снятия резервирования на ТЗ и истории ТЗ *\
      P_GOODSSUPPLY_RECALC2(CUR.COMPANY
                           ,CUR.SUPPLY
                           ,CUR.RES_START_DATE
                           ,0 \*nRES_TYPE*\
                           ,CUR.QUANT
                           ,CUR.QUANT_ALT);
    end loop CUR;
  end;
  
  --Процедура снятия резервирования ТЗ по заявкам на закупку инструмента при отработке расходной накладной
  procedure P_RESJOURNAL_TRINVDEPT_CLOSE(NRN in number) is
    \*
      Передадов А.Ю.
      10.07.2015
    *\
  begin
    for CUR in (select RJ.*
                      ,TR.RN      NTRDPT_RN
                      ,TR.DOCTYPE NTRDPT_DOCTYPE
                      ,TR.PREF    STRDPT_PREF
                      ,TR.NUMB    STRDPT_NUMB
                      ,TR.DOCDATE DTRDPT_DOCDATE
                  from TRANSINVDEPT      TR
                      ,TRANSINVDEPTSPECS TRS
                      ,DOCLINKS          DL
                      ,RESJOURNAL        RJ
                 where RJ.RES_END_DATE is null
                   and TR.RN = NRN
                   and TR.RN = TRS.PRN
                   and DL.OUT_DOCUMENT = TRS.RN
                   and DL.IN_DOCUMENT = RJ.RN)
    loop
      -- снятие резерва
      update RESJOURNAL
         set RES_END_DATE = CUR.RES_START_DATE
            ,NOTES        = SUBSTR('Резервирование снято из расходной накладной на отпуск в подразделение "' ||
                                   PKG_DOCUMENT.MAKE_NUMBER(NDOC_TYPE => CUR.NTRDPT_DOCTYPE
                                                           ,SDOC_PREF => CUR.STRDPT_PREF
                                                           ,SDOC_NUMB => CUR.STRDPT_NUMB
                                                           ,DDOC_DATE => CUR.DTRDPT_DOCDATE) || '".' ||
                                   NOTES
                                  ,1
                                  ,240)
       where RN = CUR.RN;
      \* отражение снятия резервирования на ТЗ и истории ТЗ *\
      P_GOODSSUPPLY_RECALC2(CUR.COMPANY
                           ,CUR.SUPPLY
                           ,CUR.RES_START_DATE
                           ,1 \*nRES_TYPE*\
                           ,CUR.QUANT
                           ,CUR.QUANT_ALT);
    end loop CUR;
  end P_RESJOURNAL_TRINVDEPT_CLOSE;
  
  -- Процедура удаления связей спецификации расходной накладной и заказа подразделения с запсиью журнала резервирования и закрытие резерва при удалении расходной накладной
  procedure P_RESJOURNAL_TID_DROP_LINK(NRN in number) is
    \*
      Передадов А.Ю.
      23.10.2015
    *\
  begin
    for CUR in (select RJ.COMPANY as NCOMPANY
                      ,RJ.RN as NRESJOURNAL
                      ,RJ.RES_END_DATE as DRES_END_DATE
                      ,TR.RN as NTID
                      ,TRS.RN as NTID_SP
                      ,NVL((select count(DL.RN)
                             from DOCLINKS DL
                            where DL.IN_UNITCODE = 'IncomingOrdersSpecs'
                              and DL.OUT_DOCUMENT = RJ.RN
                              and DL.OUT_UNITCODE = 'ReservationJournal')
                          ,0) NLINK_IOS
                  from TRANSINVDEPT      TR
                      ,TRANSINVDEPTSPECS TRS
                      ,DOCLINKS          DL
                      ,RESJOURNAL        RJ
                 where (TR.RN = NRN or TRS.RN = NRN)
                   and TR.RN = TRS.PRN
                   and DL.OUT_DOCUMENT = TRS.RN
                   and DL.IN_DOCUMENT = RJ.RN)
    loop
      -- удаление связи ЖР-ЗП, ЖР-спец РН
      P_LINKSALL_REMOVE(NCOMPANY      => CUR.NCOMPANY
                       ,SIN_UNITCODE  => 'ReservationJournal'
                       ,NIN_DOCUMENT  => CUR.NRESJOURNAL
                       ,SOUT_UNITCODE => null
                       ,NOUT_DOCUMENT => null);
      -- если резерв не связан с ПО то закрываем его
      if CUR.NLINK_IOS = 0 and CUR.DRES_END_DATE is null
      then
        P_RESJOURNAL_TAKE(NCOMPANY => CUR.NCOMPANY
                         ,NRN      => CUR.NRESJOURNAL);
      end if;
      -- обновление записей истории
      update UDO_T_ORDER_PURCHASE_TOOLS_ST T
         set T.NOTE = 'Расходная накладная удалена.'
       where T.DOC_RN = NRN;
    end loop CUR;
  end P_RESJOURNAL_TID_DROP_LINK;
  */
  -- инициализация рег. номера спецификации заказа подразделений
  /*procedure INIT_DORDS(NDOCUMENT in number) is
  begin

    NDEPARTMENTORDS := NDOCUMENT;
    --UDO_PKG_DEPARNMENT_STATE.STATE_UPD(NDOCUMENT);  --- 14.02.2017 Е.З.Ст. - пересчет статусов строки

  end;*/

  -- Процедура создания резерва
  procedure MAKE
  (
    RRESJRN    in out RESJOURNAL%rowtype -- запись журнала резервирования
   ,SUNIT_LINK in varchar default null -- код раздела для связи с резервом
   ,NDOC_LINK  in number default null -- рег. номер документа раздела для связи с резервом
   ,NLINK      in number default 0 -- 0-связь по выходу (документ - резерв), 1-связь по входу (резерв-документ)
  ) is
    NQUANT_SALE PKG_STD.TQUANT; -- доступное кол-вл ТЗ  
    sNOMEN      DICNOMNS.NOMEN_NAME%type;--
  begin
    begin
      select LEAST(T.RESTPLAN, T.RESTFACT) - T.RESERV,
             NM.NOMEN_NAME
        into NQUANT_SALE,
             sNOMEN
        from GOODSSUPPLY T,
             GOODSPARTIES GP,
             NOMMODIF     MD,
             DICNOMNS     NM
       where T.RN = RRESJRN.SUPPLY
         and T.PRN = GP.RN
         and GP.NOMMODIF = MD.RN
         and MD.PRN = NM.RN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0, RRESJRN.SUPPLY, 'GOODSSUPPLY');
    end;
    if RRESJRN.QUANT > NQUANT_SALE --and utilizer != 'KHOK'
    then
      P_EXCEPTION(0
                 ,'Доступное кол-во ТЗ "%s" меньше требуемого "%s".'||chr(10)||
                 'Номенклатура: %s'||chr(10)||
                 'Документ: '||trim(RRESJRN.DOCPREF)||'-'||trim(RRESJRN.DOCNUMB)
                 ,NQUANT_SALE
                 ,RRESJRN.QUANT
                 ,sNOMEN);
    end if;
    RRESJRN.RN := null;
    --   базовое добавление
    P_RESJOURNAL_BASE_INSERT(NCOMPANY        => RRESJRN.COMPANY
                            ,SAUTHID         => RRESJRN.AUTHID
                            ,NSUPPLY         => RRESJRN.SUPPLY
                            ,DRES_START_DATE => RRESJRN.RES_START_DATE
                            ,DRES_END_DATE   => RRESJRN.RES_END_DATE
                            ,NQUANT          => RRESJRN.QUANT
                            ,NQUANT_ALT      => NVL(RRESJRN.QUANT_ALT
                                                   ,0)
                            ,NDOCTYPE        => RRESJRN.DOCTYPE
                            ,DDOCDATE        => RRESJRN.DOCDATE
                            ,SDOCPREF        => RRESJRN.DOCPREF
                            ,SDOCNUMB        => RRESJRN.DOCNUMB
                            ,NAGENT          => RRESJRN.AGENT
                            ,NSUBDIV         => RRESJRN.SUBDIV
                            ,NSELL_TUBE      => RRESJRN.SELL_TUBE
                            ,NACC_AGENT      => RRESJRN.ACC_AGENT
                            ,SNOTES          => RRESJRN.NOTES
                            ,NRN             => RRESJRN.RN);
    -- формирование связи
    if RRESJRN.RN is not null and
       (SUNIT_LINK is not null and NDOC_LINK is not null)
    then
      P_LINKSALL_LINK_DIRECT(NCOMPANY          => RRESJRN.COMPANY
                            ,SIN_UNITCODE      => case
                                                    when NLINK = 0 then
                                                     SUNIT_LINK
                                                    else
                                                     'ReservationJournal'
                                                  end
                            ,NIN_DOCUMENT      => case
                                                    when NLINK = 0 then
                                                     NDOC_LINK
                                                    else
                                                     RRESJRN.RN
                                                  end
                            ,NIN_PRN_DOCUMENT  => null
                            ,DIN_IN_DATE       => sysdate
                            ,NIN_STATUS        => 1
                            ,SOUT_UNITCODE     => case
                                                    when NLINK = 0 then
                                                     'ReservationJournal'
                                                    else
                                                     SUNIT_LINK
                                                  end
                            ,NOUT_DOCUMENT     => case
                                                    when NLINK = 0 then
                                                     RRESJRN.RN
                                                    else
                                                     NDOC_LINK
                                                  end
                            ,NOUT_PRN_DOCUMENT => null
                            ,DOUT_IN_DATE      => sysdate
                            ,NOUT_STATUS       => 1);
    end if;
  end;

  --Процедура резервирования ТЗ из приходного ордера по заказам подразделений
  /*procedure MAKE_BY_INORDER
  (
    NCOMPANY  in number
   ,NDOCUMENT in number
  ) is
    RRESJRN         RESJOURNAL%rowtype;
    NPROP_ORD       number; -- рег. номер дополнительного св-ва "Заказ подразделений"
    NQUANT_ORD_RSRV number; -- кол-во зарезервированное по заказу
    \*
    
    *\
  begin
    -- рег. номер дополнительного св-ва "Заказ подразделений"
    FIND_DOCS_PROPS_CODE(NFLAG_SMART => 0
                        ,NCOMPANY    => NCOMPANY
                        ,SCODE       => 'EE_ORD'
                        ,NRN         => NPROP_ORD); -- 10996417
    -- атрибуты записи резервирования
    RRESJRN.COMPANY        := NCOMPANY;
    RRESJRN.AUTHID         := UTILIZER();
    RRESJRN.RES_START_DATE := sysdate();
    -- цикл по специфиации приходного ордера
    for CUR in (select PS.RN NACCSP
                      ,O.INDOCPREF
                      ,O.INDOCNUMB
                      ,O.INDOCDATE
                      ,OS.*
                  from INORDERS     O
                      ,INORDERSPECS OS
                      ,DOCLINKS     DL
                      ,DOCLINKS     DV
                      ,PAYACCIN     P
                      ,PAYACCINSPEC PS
                 where O.RN = NDOCUMENT
                   and OS.PRN = O.RN
                   and DL.IN_UNITCODE = 'IncomingInvoices'
                   and DL.OUT_DOCUMENT = OS.PRN
                   and DL.OUT_UNITCODE = 'IncomingOrders'
                   and DV.IN_DOCUMENT = P.RN
                   and DV.IN_UNITCODE = 'PaymentAccountsIn'
                   and DV.OUT_DOCUMENT = DL.IN_DOCUMENT
                   and DV.OUT_UNITCODE = 'IncomingInvoices'
                   and P.RN = PS.PRN
                   and PS.NOMMODIF = OS.NOMMODIF
                   and CMP_NUM(PS.NOMMODIFPACK
                              ,OS.NOMNMODIFPACK) = 1
                      --
                   and NVL(REGEXP_COUNT(OS.SERNUMB
                                       ,'\D')
                          ,0) = 0 -- 22.07.2014 Добавлен фильтр, исключающий из автобронирования позиции ПО, у которых в серии присуствуют буквы
                
                --*--
                )
    loop
      -- атрибуты записи резервирования
      RRESJRN.NOTES  := 'Зарезервировано автоматически из приходного ордера  №' ||
                        trim(CUR.INDOCPREF) || '-' || trim(CUR.INDOCNUMB) ||
                        ' от ' || TO_CHAR(CUR.INDOCDATE
                                         ,'dd.mm.yyyy') || '.';
      RRESJRN.SUPPLY := CUR.GOODSSUPPLY;
      -- цикл по калькуляции спецификации ВСО
      for REC in (select PC.*
                        ,DS.rn as nDEPORDS 
                        ,DV.SOURCE
                        ,DV.STR_VALUE
                        ,DP.ORD_DOCTYPE
                        ,DP.ORD_PREF
                        ,DP.ORD_NUMB
                        ,DP.ORD_DATE
                        ,DP.SUBDIV as ORD_SUBDIV
                        ,DP.RN NORDER
                        ,(DS.MAIN_QUANT -
                          nvl(UDO_F_PRODORDSP_TRANSINV(ds.rn),0)
                         \*F_DEPARTMENTORDPS_GET_NPARAM(1
                                                      ,DS.RN
                                                      ,0
                                                      ,'P_FACTM_QUANT')*\) NQUANT_ORDER
                    from PAYACCINSPCLC   PC
                        ,DOCS_PROPS_VALS DV
                        ,DEPARTMENTORD   DP
                        ,DEPARTMENTORDS  DS
                   where PC.PRN = CUR.NACCSP
                     and PC.RN = DV.UNIT_RN
                     and 'PaymentAccountsInSpecsCalcs' = DV.UNITCODE
                     and NPROP_ORD = DV.DOCS_PROP_RN
                     and DV.SOURCE = DP.RN
                     and DP.RN = DS.PRN
                     and DS.NOM_MODIF = CUR.NOMMODIF
                     and CMP_NUM(DS.NOMMOD_PACK
                                ,CUR.NOMNMODIFPACK) = 1
                         order by pc.priority)
      loop
        -- кол-во зарезервированное по заказу
        NQUANT_ORD_RSRV := GET_QUANT_BY_ORDER(NORDER     => REC.NORDER
                                             ,NMODIF     => CUR.NOMMODIF
                                             ,NMODIFPACK => CUR.NOMNMODIFPACK);
        ---  p_exception (0 , REC.NORDER);
        -- кол-во требуемое для резерва (не исполненное кол-во из заказа подразделения минус ранее зарезервированное кол-во )
        REC.NQUANT_ORDER := REC.NQUANT_ORDER - NQUANT_ORD_RSRV;
        -- проверка корректности кол-ва резерва
        if REC.NQUANT_ORDER <= 0 or REC.QUANT_FACT = 0
        then
          CONTINUE;
        end if;
        -- кол-во для резервирования
        if REC.QUANT_FACT > REC.NQUANT_ORDER
        then
          RRESJRN.QUANT := REC.NQUANT_ORDER;
        else
            RRESJRN.QUANT := REC.QUANT_FACT;
        end if;
        if CUR.FACTQUANT  < RRESJRN.QUANT then
          RRESJRN.QUANT := CUR.FACTQUANT;
        end if;  
        CUR.FACTQUANT := CUR.FACTQUANT - RRESJRN.QUANT;
        -- атрибуты записи резервирования
        RRESJRN.SUBDIV  := REC.ORD_SUBDIV;
        RRESJRN.DOCTYPE := REC.ORD_DOCTYPE;
        RRESJRN.DOCPREF := REC.ORD_PREF;
        RRESJRN.DOCNUMB := REC.ORD_NUMB;
        RRESJRN.DOCDATE := REC.ORD_DATE;
        --DBMS_OUTPUT.PUT_LINE(CUR.NOMMODIF || ' - ' || RRESJRN.QUANT);
        -- создание записи резерва
        if RRESJRN.QUANT >0 then
          MAKE(RRESJRN    => RRESJRN -- запись журнала резервирования
              ,SUNIT_LINK => 'IncomingOrdersSpecs' -- код раздела для связи с резервом
              ,NDOC_LINK  => CUR.RN -- рег. номер документа раздела для связи с резервом
               );
        
            \* Добавление исполнения строки заказа подразделения *\
            udo_pkg_depords_prf.BINSERT(nDORDSP    => rec.Ndepords,
                                        nRSRV      => RRESJRN.RN,
                                        nQUANT     => RRESJRN.QUANT,
                                        nQUANT_ALT => RRESJRN.QUANT_ALT);
        
        end if;
      --  UDO_P_DEPARNMENT_STATE.STATE_UPD(REC.NORDER);---EZSt--Обновление статусов после резервирования
      end loop;
    end loop;
  end;
*/
  --Процедура резервирования ТЗ из заказа подразделения
  procedure MAKE_BY_DORD
  (
    NDOCUMENT                 in number, -- Рег. номер заказа
    sSTORE                    in varchar2  -- Склад для резервироания 
  ) 
  is
  begin
    /* цикл по спецификациям */
    for REC in (select S.RN
                  from DEPARTMENTORDS S
                      ,DICNOMNS       D
                 where S.PRN = NDOCUMENT
                   and S.NOMEN = D.RN
                   and S.NOM_MODIF is not null
                   and D.NOMEN_TYPE <> 2)
    loop
      MAKE_BY_DORDS(NDOCUMENT => REC.RN, sSTORE => sSTORE);
    end loop;
  end;

  --Процедура резервирования ТЗ из спецификации заказа подразделения
  procedure MAKE_BY_DORDS
  (
    NDOCUMENT                 in number, -- Рег. номер спецификации заказа
    sSTORE                    in varchar2  -- Склад для резервироания 
  ) 
  is
    RDORD     DEPARTMENTORD%rowtype; -- запись ЗП
    RDORDS    DEPARTMENTORDS%rowtype; -- запись спецификации ЗП
    DRES_DATE date := sysdate(); -- дата и время резервирования
    RDOC      UDO_PKG_PARTIES_CHOICE.TDOC; -- коллекция документов для резервирования
    TBPARTIES UDO_PKG_PARTIES_CHOICE.TPARTIES; -- коллекция партии ТЗ подобранных для резервирования
    NQUANT    PKG_STD.TQUANT; -- кол-во
    NQUANTALT PKG_STD.TQUANT := 0; -- кол-во в ДЕИ
    NTMP      PKG_STD.TNUMBER; -- временная переменная
    NRES_RN   PKG_STD.TNUMBER; -- рег. номр записи резерва
    nQUANT_CHOICE  number;
    nRES           number;
    narticle_check number;
    rSTORE         azsazslistmt%rowtype;
    nSTKIND_VK     PKG_STD.tREF;
  begin
    -- запись спецификации ЗП
    begin
      select *
        into RDORDS
        from DEPARTMENTORDS
       where RN = NDOCUMENT;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0
                                ,NDOCUMENT
                                ,'DEPARTMENTORDS');
    end;
    -- запись ЗП
    begin
      select *
        into RDORD
        from DEPARTMENTORD
       where RN = RDORDS.PRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0
                                ,RDORDS.PRN
                                ,'DEPARTMENTORD');
    end;
    
     if RDORD.ORD_STATE != 1 then 
      p_exception (0 , 'Не возможно зарезервировать по неутвержденному заказу.');
    end if ; 
     if RDORD.Consolidated in (2,3) then 
      p_exception (0 , 'Действие не доступно для консолидированного заказа.');
    end if ;
    
    -- если нет модификации - выходим
    if RDORDS.NOM_MODIF is null
    then
      return;
    end if;
    -- проверка прав доступа
    PKG_ENV.ACCESS(NCOMPANY => RDORDS.COMPANY
                  ,NVERSION => null
                  ,NCATALOG => RDORDS.CRN
                  ,SUNIT    => 'DepartmentsOrdersSpecs'
                  ,SACTION  => 'UDO_DEPARTMENTORDS_RESERV');
    -- сравниваем кол-ва в ОЕИ
    /*if (F_DEPARTMENTORDPS_GET_NPARAM(1
                                    ,RDORDS.RN
                                    ,0
                                    ,'P_FACTM_QUANT') >
       F_DEPARTMENTORDPS_GET_NPARAM(1
                                    ,RDORDS.RN
                                    ,0
                                    ,'P_PLANM_QUANT'))
    then
      NQUANT := F_DEPARTMENTORDPS_GET_NPARAM(1
                                            ,RDORDS.RN
                                            ,0
                                            ,'ACTM_QUANT') -
                F_DEPARTMENTORDPS_GET_NPARAM(1
                                            ,RDORDS.RN
                                            ,0
                                            ,'P_FACTM_QUANT');
    else
      NQUANT := F_DEPARTMENTORDPS_GET_NPARAM(1
                                            ,RDORDS.RN
                                            ,0
                                            ,'ACTM_QUANT') -
                F_DEPARTMENTORDPS_GET_NPARAM(1
                                            ,RDORDS.RN
                                            ,0
                                            ,'P_PLANM_QUANT');
    end if;*/
    
    NQUANT := RDORDS.Main_Quant  - nvl(UDO_F_PRODORDSP_TRANSINV(NRN => RDORDS.rn,nCOMPANY => RDORDS.COMPANY),0) - nvl(GET_QUANT_BY_ORDERS(NORDERS =>RDORDS.rn),0);
    
    -- если кол-во в ОЕИ не ноль - подбираем партию и резервируем
    begin
      select mn.rn
       into narticle_check
      from dicnomns mn
      where mn.rn = RDORDS.NOMEN
            and mn.sign_serial = 1;
       exception when no_data_found then narticle_check := null;     
     end; 
    if narticle_check is not null
      then p_exception (0,'Запрещено резервировать номенклатуры с признаком "Учет по серийным номерам"!');
     end if; 
    if NQUANT > 0
    then
      /* инициализация документа */
      RDOC.UNITCODE    := 'DepartmentsOrders';
      RDOC.RN          := RDORD.RN;
      RDOC.DOCTYPE     := RDORD.ORD_DOCTYPE;
      RDOC.PREF        := RDORD.ORD_PREF;
      RDOC.NUMB        := RDORD.ORD_NUMB;
      RDOC.DOCDATE     := RDORD.ORD_DATE;
      RDOC.WORK_DATE   := TRUNC(DRES_DATE);
      RDOC.JUR_PERS    := RDORD.JUR_PERS;
      RDOC.SUBDIV      := RDORD.SUBDIV;
      RDOC.RESPONSIBLE := RDORD.ACC_AGENT;
      RDOC.RESPONSIBLE := RDORD.ACC_AGENT;
      RDOC.FACEACC     := RDORD.Faceacc;
      RDOC.STOPER      := null;
      /* инициализация спецификации */
      RDOC.SPEC.UNITCODE   := 'DepartmentsOrdersSpecs';
      RDOC.SPEC.RN         := RDORDS.RN;
      RDOC.SPEC.MODIF      := RDORDS.NOM_MODIF;
      RDOC.SPEC.PACK       := RDORDS.NOMMOD_PACK;
      RDOC.SPEC.ARTICLE    := null;
      RDOC.SPEC.GOODSPARTY := null;
      RDOC.SPEC.QUANT      := NQUANT;
      RDOC.SPEC.QUANT_ALT  := NQUANTALT;
      
      /* инициализация склада */
      -- 2022.09.08 Добавлено указание склада при резервировании для того чтобы исключить резервирование с склада  ВК 
      find_dicstore_numb(nFLAG_SMART => 0,
                         nCOMPANY    => RDORD.COMPANY,
                         sNUMB       => sSTORE,
                         nRN         => RDOC.STORE.RN);
      rSTORE := udo_pkg_get.ROW_STORE(NRN => RDOC.STORE.RN,NSMART => 0);
      
      find_stkind_code(nFLAG_SMART  => 0,
                       nFLAG_OPTION => 0,
                       nCOMPANY     => RDORD.COMPANY,
                       sCODE        => udo_f_constlst_str(NCOMPANY => RDORD.COMPANY,SNAME => 'ВИД_СКЛАДА_ВК'),
                       nRN          => nSTKIND_VK);
      
      if rSTORE.Stkind is not null and nSTKIND_VK = rSTORE.Stkind then 
        p_exception(0 , 'Запрещено резервировать с складов входного контроля.');
      end if;
      --RDOC.STORE.RN := RDORD.STORE;
      
      /* считываем дополнительные параметры документа */
      UDO_PKG_PARTIES_CHOICE.GET_DOCUMENT_PARAMS(1 /*FLAG_SMART*/
                                            ,0 /*подбор по товарным запасам*/
                                            ,RDOC);
      -- если не услуга, подбираем
      if RDOC.SPEC.NOMEN_TYPE != 2
      then
        -- подбор партий и резервирование товара
        UDO_PKG_PARTIES_CHOICE.CHOICE_EX(nFLAG_SMART => 1 /*FLAG_SMART*/
                                    ,nCOMPANY => RDORD.COMPANY
                                    ,nOPER_SPACE => 0 /*подбор по товарным запасам*/
                                    ,nOPER_TYPE => 0 /*подбор для резервирования*/
                                    ,nOPER_ACTION => 0 /*подбор*/
                                    ,rDOC => RDOC
                                    ,tbPARTIES => TBPARTIES
                                    ,nQUANT => nQUANT_CHOICE
                                    ,nQUANT_ALT => NTMP
                                    ,nWEIGHT => NTMP
                                    ,nVOLUME => NTMP
                                    ,nRES => NRES);
        -- резервирование
        if TBPARTIES.COUNT > 0 and nQUANT_CHOICE <= NQUANT
        then
          -- цикл по записям подобранных партий
          for I in TBPARTIES.FIRST .. TBPARTIES.LAST
          loop
            if TBPARTIES(I).QUANT > 0 then 
              -- добавляем запись резервирования
              P_RESJOURNAL_BASE_INSERT(RDORD.COMPANY
                                      ,UTILIZER
                                      ,TBPARTIES(I).SUPPLY
                                      ,NVL(DRES_DATE
                                          ,RDOC.WORK_DATE) /*dRES_START_DATE*/
                                      ,null /*RES_END_DATE*/
                                      ,TBPARTIES(I).QUANT
                                      ,TBPARTIES(I).QUANT_ALT
                                      ,RDOC.DOCTYPE
                                      ,RDOC.DOCDATE
                                      ,RDOC.PREF
                                      ,RDOC.NUMB
                                      ,RDOC.AGENT
                                      ,RDOC.SUBDIV
                                      ,null /*SELL_TUBE*/
                                      ,RDOC.RESPONSIBLE
                                      ,'Зарезервировано из раздела "' ||
                                       GET_UNITLIST_NAME_CODE(0
                                                             ,RDOC.UNITCODE) || '"'
                                      ,NRES_RN); 
              
              /* Добавление исполнения строки заказа подразделения */
              udo_pkg_depords_prf.BINSERT(nDORDSP    => RDORDS.RN,
                                          nRSRV      => NRES_RN,
                                          nQUANT     => TBPARTIES(I).QUANT,
                                          nQUANT_ALT => TBPARTIES(I).QUANT_ALT);
            end if;
          end loop;
          TBPARTIES.DELETE;
        end if;
      end if;
    end if;
    
    /*if NRES_RN is null then 
      p_exception(0, 'Данных для резервирования не найдено.');
    end if;*/
    --UDO_PKG_DEPARNMENT_STATE.STATE_UPD(NDOCUMENT);  --- 14.02.2017 Е.З.Ст. - пересчет статусов строки

  end;

/*
  procedure MAKE_BY_DORDS_IZD
  (
    nIDent                    in number, -- кол-во
    nDEPORDS                  in number default null -- рег. номер спецификации заказа подразделения  
  ) is
    RDORD       DEPARTMENTORD%rowtype; -- запись ЗП
    RDORDS      DEPARTMENTORDS%rowtype; -- запись спецификации ЗП
    DRES_DATE   date := sysdate(); -- дата и время резервирования
    NQUANT_ALT  PKG_STD.TQUANT := 0; -- кол-во в ДЕИ
    NQUANT_SALE PKG_STD.TQUANT; -- доступное кол-вл ТЗ  
    NRES_RN     PKG_STD.TNUMBER; -- рег. номр записи резерва
    nQUANT_ORD  PKG_STD.TQUANT; -- доступное кол-во по заказу
    RCORD       CONSUMERORD%rowtype; -- запись ЗП
    RСORDS      CONSUMERORDS%rowtype; 
    NQUANT      number;
    sunitcode   varchar(100);
  begin

 begin
   select 'DEPARTMENTORDS'
   into sunitcode
   from DEPARTMENTORDS s
   where s.rn=nDEPORDS;
   
 exception when others then sunitcode:='CONSUMERORDS' ;
 end; 
 
p_exception(0,'Действие в разработке!!!');
 if sunitcode='DEPARTMENTORDS' then
    -- запись спецификации ЗП
    begin
      select *
        into RDORDS
        from DEPARTMENTORDS
       where RN = nDEPORDS;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0
                                ,nDEPORDS
                                ,'DEPARTMENTORDS');
    end;
 

    -- запись ЗП
    begin
      select *
        into RDORD
        from DEPARTMENTORD
       where RN = RDORDS.PRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0
                                ,RDORDS.PRN
                                ,'DEPARTMENTORD');
    end;
    if RDORD.ORD_STATE != 1 then 
      p_exception (0 , 'Не возможно зарезервировать по неутвержденному заказу.');
    end if ;
    
    \*             for i in (
                    select M.*
                    from SELECTLIST S, 
                    MCST_V_RLARTICLESSLAVE M
                         
                    where s.ident=nIdent and s.document=m.RN) loop   
    -- добавляем запись резервирования
P_RESJOURNAL_BASE_INSERT(NCOMPANY        => RDORD.COMPANY
                            ,SAUTHID         => UTILIZER()
                            ,NSUPPLY         => i.ngoodssupply
                            ,DRES_START_DATE => DRES_DATE
                            ,DRES_END_DATE   => null
                            ,NQUANT          => 1
                            ,NQUANT_ALT      => 1
                            ,NDOCTYPE        => RDORD.ORD_DOCTYPE
                            ,DDOCDATE        => RDORD.ORD_DATE
                            ,SDOCPREF        => RDORD.ORD_PREF
                            ,SDOCNUMB        => RDORD.ORD_NUMB
                            ,NAGENT          => null
                            ,NSUBDIV         => RDORD.SUBDIV
                            ,NSELL_TUBE      => null
                            ,NACC_AGENT      => null
                            ,SNOTES          => 'Зарезервировано из раздела "' ||
                                                GET_UNITLIST_NAME_CODE(0
                                                                      ,'DepartmentsOrders') || '"'
                            ,NRN             => NRES_RN);
                           update  RESJOURNAL R SET
                           r.ser_num=i.code
                           WHERE R.RN=NRES_RN;
                              update ARTICLESSUPPLY a set
                           a.ship_plan=1
                           where a.rn=i.rn; 
                           end loop;*\
    end if;
  if sunitcode='CONSUMERORDS' then
  
     begin
      select *
        into RСORDS
        from CONSUMERORDS
       where RN = nDEPORDS;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0
                                ,nDEPORDS
                                ,'CONSUMERORDS');
    end;


    -- запись ЗП
    begin
      select *
        into RCORD
        from CONSUMERORD
       where RN = RСORDS.PRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0
                                ,RСORDS.PRN
                                ,'CONSUMERORD');
    end;
    if RCORD.ORD_STATE != 1 then 
      p_exception (0 , 'Не возможно зарезервировать по неутвержденному заказу.');
    end if ;
    
    
    
    begin
      select count(s.rn)
         into NQUANT
      from selectlist s
      where s.ident=nIdent;
            exception
      when NO_DATA_FOUND then  p_exception (0,'Не выбранно ниодно изделие');
    end;
    
    
    
     \*
    begin
      select sum(LEAST(T.RESTPLAN
                  ,T.RESTFACT) - T.RESERV)
        into NQUANT_SALE
        from GOODSSUPPLY T
       where T.RN in (select m.NGOODSSUPPLY from SELECTLIST S, 
                    MCST_V_RLARTICLESSLAVE M
                         
                    where s.ident=nIdent and s.document=m.RN );
    exception
      when NO_DATA_FOUND then
      null;
    end;

    if NQUANT > NQUANT_SALE
    then
      P_EXCEPTION(0
                 ,'Доступное кол-во ТЗ "%s" меньше требуемого "%s".'
                 ,NQUANT_SALE
                 ,NQUANT);end if;
                 
                 for i in (
                    select M.*
                    from SELECTLIST S, 
                    MCST_V_RLARTICLESSLAVE M
                         
                    where s.ident=nIdent and s.document=m.RN) loop  
    -- добавляем запись резервирования
P_RESJOURNAL_BASE_INSERT(NCOMPANY        => RCORD.COMPANY
                            ,SAUTHID         => UTILIZER()
                            ,NSUPPLY         => i.ngoodssupply
                            ,DRES_START_DATE => DRES_DATE
                            ,DRES_END_DATE   => null
                            ,NQUANT          => 1
                            ,NQUANT_ALT      => 1
                            ,NDOCTYPE        => RCORD.ORD_DOCTYPE
                            ,DDOCDATE        => RCORD.ORD_DATE
                            ,SDOCPREF        => RCORD.ORD_PREF
                            ,SDOCNUMB        => RCORD.ORD_NUMB
                            ,NAGENT          => null
                            ,NSUBDIV         =>RCORD.SUBDIV
                            ,NSELL_TUBE      => null
                            ,NACC_AGENT      => null
                            ,SNOTES          => 'Зарезервировано из раздела "' ||
                                                GET_UNITLIST_NAME_CODE(0
                                                                      ,'DepartmentsOrders') || '"'
                            ,NRN             => NRES_RN);
                           update  RESJOURNAL R SET
                           r.ser_num=i.code
                           WHERE R.RN=NRES_RN;
                          update ARTICLESSUPPLY a set
                           a.ship_plan=1
                           where a.rn=i.rn;  
                             end loop;
                           
                        *\
   end if;
    -- кол-во доступное по заказу
  \*  nQUANT_ORD := RDORDS.Main_Quant - UDO_F_GET_DEPTORD_ISP_QNT(RDORDS.RN)--nvl(F_DEPARTMENTORDPS_GET_NPARAM(1,RDORDS.RN,0,'P_FACTM_QUANT' ),0)
                      - udo_pkg_resjournal_ctrl.GET_QUANT_BY_ORDER(NORDER => RDORD.rn,NMODIF => RDORDS.nom_modif,NMODIFPACK => RDORDS.nommod_pack);
                    
    if  NQUANT >  nQUANT_ORD then 
      null;
    \*  P_EXCEPTION(0
                 ,'Доступное кол-во по заказу "%s" меньше требуемого "%s".'
                 ,nQUANT_ORD
                 ,NQUANT);*\
    end if ;*\
    -- проверка прав доступа
  \*  PKG_ENV.ACCESS(NCOMPANY => RDORDS.COMPANY
                  ,NVERSION => null
                  ,NCATALOG => RDORDS.CRN
                  ,SUNIT    => 'DepartmentsOrdersSpecs'
                  ,SACTION  => 'UDO_DEPARTMENTORDS_RSRV_IZD');*\
           
  end;*/
  
  --Процедура резервирования ТЗ по конкретной партии из спецификации заказа подразделения
  procedure MAKE_BY_DORDS_EX
  (
    NSUPPLY                   in number -- рег. номер товарного запаса
   ,NQUANT                    in number -- кол-во
   ,nDEPORDS                  in number default null -- рег. номер спецификации заказа подразделения  
   ,nRSRV                     out number -- рег. номер журнала резервирования
   ,nSIGN_FREE                in number default 0 -- Признак резервирования из свободного остатка (1 - да)
  ) is
    RDORD                     DEPARTMENTORD%rowtype; -- запись ЗП
    RDORDS                    DEPARTMENTORDS%rowtype; -- запись спецификации ЗП
    DRES_DATE                 date := sysdate(); -- дата и время резервирования
    NQUANT_ALT                PKG_STD.TQUANT := 0; -- кол-во в ДЕИ
    NQUANT_SALE               PKG_STD.TQUANT; -- доступное кол-вл ТЗ  
    --nQUANT_ORD                PKG_STD.TQUANT; -- доступное кол-во по заказу
    sNOMEN                    DICNOMNS.NOMEN_CODE%type;
    sPARTY                    INCOMDOC.CODE%type;
    --NRES_RN                   PKG_STD.TNUMBER; -- рег. номр записи резерва
  begin
    -- проверка корректности количества для резервирования
    if NVL(NQUANT,0) = 0
    then
      return;
    end if;
    
    -- запись спецификации ЗП
    begin
      select *
        into RDORDS
        from DEPARTMENTORDS
       where RN = nDEPORDS;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0, nDEPORDS, 'DEPARTMENTORDS');
    end;


    -- запись ЗП
    begin
      select *
        into RDORD
        from DEPARTMENTORD
       where RN = RDORDS.PRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0, RDORDS.PRN, 'DEPARTMENTORD');
    end;
    if RDORD.ORD_STATE = 0 then 
      p_exception (0 , 'Невозможно зарезервировать по неутвержденному заказу.');
    end if ;
    /*begin
      select LEAST(T.RESTPLAN
                  ,T.RESTFACT) - T.RESERV
        into NQUANT_SALE
        from GOODSSUPPLY T
       where T.RN = NSUPPLY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0, NSUPPLY, 'GOODSSUPPLY');
    end;*/
    
    /*Анненко И.С. 26.04.2023*/
    begin /* 29.11.2024 KHOK. Кажется есть проблема с отработкой перемещения с Входного контроля в Изолятор брака */
      select T.nsale_total
        into NQUANT_SALE
        from UDO_V_DEPORDSBUF_SUPPLY_RSRV T
       where T.RN = NSUPPLY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0, NSUPPLY, 'GOODSSUPPLY');
    end;

    if NQUANT > NQUANT_SALE --and utilizer != 'KHOK'
    then
      begin
        select NM.NOMEN_CODE
          into sNOMEN
          from DICNOMNS NM
         where NM.RN = RDORDS.NOMEN;
      exception
        when no_data_found then
          sNOMEN := '';
      end;
      begin
        select IC.CODE
          into sPARTY
          from INCOMDOC IC,
               GOODSPARTIES GP,
               GOODSSUPPLY GS
         where GS.RN = NSUPPLY
           and GS.PRN = GP.RN
           and GP.INDOC = IC.RN;
      exception
        when no_data_found then
          sPARTY := '';
      end;
      
      --if utilizer in ('CITK_MARKOV') then return; end if;
      /*Анненко И.С. 26.04.2023 раскомментил*/
      P_EXCEPTION(0
                 ,'Доступное кол-во ТЗ "%s" меньше требуемого "%s".'||chr(10)||
                  'Номенклатура: %s'||chr(10)||
                  'Партия: %s'
                 ,NQUANT_SALE
                 ,NQUANT
                 ,sNOMEN
                 ,sPARTY);
    end if;
    -- кол-во доступное по заказу
    --nQUANT_ORD := GET_QUANTERST_BY_ORDER(nDEPORDS => RDORDS.RN);
                    
    /*if  NQUANT >  nQUANT_ORD --and utilizer not in('CITK_MARKOV')
       then 
      P_EXCEPTION(0
                 ,'Доступное кол-во по заказу "%s" меньше требуемого "%s".'
                 ,nQUANT_ORD
                 ,NQUANT);
    end if ;*/
    
    -- проверка прав доступа
    if nDEPORDS is null then 
      PKG_ENV.ACCESS(NCOMPANY => RDORDS.COMPANY
                    ,NVERSION => null
                    ,NCATALOG => RDORDS.CRN
                    ,SUNIT    => 'DepartmentsOrdersSpecs'
                    ,SACTION  => 'UDO_DEPARTMENTORDS_RSRV_PARTY');
    end if;              
                  
    -- добавляем запись резервирования
    P_RESJOURNAL_BASE_INSERT(NCOMPANY        => RDORD.COMPANY
                            ,SAUTHID         => UTILIZER()
                            ,NSUPPLY         => NSUPPLY
                            ,DRES_START_DATE => DRES_DATE
                            ,DRES_END_DATE   => null
                            ,NQUANT          => NQUANT
                            ,NQUANT_ALT      => NQUANT_ALT
                            ,NDOCTYPE        => RDORD.ORD_DOCTYPE
                            ,DDOCDATE        => RDORD.ORD_DATE
                            ,SDOCPREF        => RDORD.ORD_PREF
                            ,SDOCNUMB        => RDORD.ORD_NUMB
                            ,NAGENT          => null
                            ,NSUBDIV         => RDORD.SUBDIV
                            ,NSELL_TUBE      => null
                            ,NACC_AGENT      => null
                            ,SNOTES          => 'Зарезервировано из раздела "' ||
                                                GET_UNITLIST_NAME_CODE(0, 'DepartmentsOrders') || '"'
                            ,NRN             => nRSRV);
  
    /* Добавление исполнения строки заказа подразделения */
    udo_pkg_depords_prf.BINSERT(nDORDSP    => RDORDS.RN,
                                nRSRV      => nRSRV,
                                nQUANT     => NQUANT,
                                nQUANT_ALT => NQUANT_ALT,
                                nSIGN_FREE => nSIGN_FREE);
  end;
  
  --Процедура резервирования ТЗ по конкретной партии из спецификации заказа потребителей
  /*procedure MAKE_BY_СORDS_EX
  (
    NSUPPLY in number -- рег. номер товарного запаса
   ,NQUANT  in number -- кол-во
  ) is
    RCORD       CONSUMERORD%rowtype; -- запись ЗП
    RСORDS      CONSUMERORDS%rowtype; -- запись спецификации ЗП
    DRES_DATE   date := sysdate(); -- дата и время резервирования
    NQUANT_ALT  PKG_STD.TQUANT := 0; -- кол-во в ДЕИ
    NQUANT_SALE PKG_STD.TQUANT; -- доступное кол-вл ТЗ  
    NRES_RN     PKG_STD.TNUMBER; -- рег. номр записи резерва
    nQUANT_ORD  PKG_STD.TQUANT; -- доступное кол-во по заказу
  begin
    if NVL(NQUANT
          ,0) = 0
    then
      return;
    end if;
    -- проверка корректности количества для резервирования
    -- запись спецификации ЗП
    begin
      select *
        into RСORDS
        from CONSUMERORDS
       where RN = UDO_PKG_RESJOURNAL_CTRL.NDEPARTMENTORDS;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0, UDO_PKG_RESJOURNAL_CTRL.NDEPARTMENTORDS, 'CONSUMERORDS');
    end;


    -- запись ЗП
    begin
      select *
        into RCORD
        from CONSUMERORD
       where RN = RСORDS.PRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0, RСORDS.PRN, 'CONSUMERORD');
    end;
    if RCORD.ORD_STATE != 1 then 
      p_exception (0, 'Невозможно зарезервировать по неутвержденному заказу.');
    end if ;
    begin
      select LEAST(T.RESTPLAN
                  ,T.RESTFACT) - T.RESERV
        into NQUANT_SALE
        from GOODSSUPPLY T
       where T.RN = NSUPPLY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0, NSUPPLY, 'GOODSSUPPLY');
    end;

    if NQUANT > NQUANT_SALE
    then
      P_EXCEPTION(0, 'Доступное кол-во ТЗ "%s" меньше требуемого "%s".'
                 ,NQUANT_SALE
                 ,NQUANT);
    end if;
    
    -- кол-во доступное по заказу
    nQUANT_ORD := RСORDS.Main_Quant - udo_pkg_resjournal_ctrl.GET_QUANT_BY_СORDER(NORDER => RCORD.rn,NMODIF => RСORDS.nom_modif,NMODIFPACK => RСORDS.nommod_pack);
                    
    if  NQUANT >  nQUANT_ORD then 
      null;
      P_EXCEPTION(0, 'Доступное кол-во по заказу "%s" меньше требуемого "%s".'
                 ,nQUANT_ORD
                 ,NQUANT); 
    
    end if ;
    -- проверка прав доступа
    PKG_ENV.ACCESS(NCOMPANY => RCORDS.COMPANY
                  ,NVERSION => null
                  ,NCATALOG => RDORDS.CRN
                  ,SUNIT    => 'DepartmentsOrdersSpecs'
                  ,SACTION  => 'UDO_DEPARTMENTORDS_RSRV_PARTY');
    -- добавляем запись резервирования
    P_RESJOURNAL_BASE_INSERT(NCOMPANY        => RCORD.COMPANY
                            ,SAUTHID         => UTILIZER()
                            ,NSUPPLY         => NSUPPLY
                            ,DRES_START_DATE => DRES_DATE
                            ,DRES_END_DATE   => null
                            ,NQUANT          => NQUANT
                            ,NQUANT_ALT      => NQUANT_ALT
                            ,NDOCTYPE        => RCORD.ORD_DOCTYPE
                            ,DDOCDATE        => RCORD.ORD_DATE
                            ,SDOCPREF        => RCORD.ORD_PREF
                            ,SDOCNUMB        => RCORD.ORD_NUMB
                            ,NAGENT          => null
                            ,NSUBDIV         => RCORD.SUBDIV
                            ,NSELL_TUBE      => null
                            ,NACC_AGENT      => null
                            ,SNOTES          => 'Зарезервировано из раздела "' ||
                                                GET_UNITLIST_NAME_CODE(0
                                                                      ,'ConsumersOrders') || '"'
                            ,NRN             => NRES_RN);
  end;*/
  
  
  -- Процедура закрытия резерва
  procedure TAKE
  (
    NDOCUMENT  in number -- рег. номер записи резерва
   ,SNOTE      in varchar default null -- примечание
   ,NLINK_DROP in number default 0 -- признак удаления связей резерва (0-не удалять, 1 удалять)
   ,NDORDS_SETNULL in number default 0 -- признак обнуления исполнения (0-не обнулять, 1 - обнулять )
  ) is
    RRESJOURNAL RESJOURNAL%rowtype; -- запись резерва источника
    nDORDSP     pkg_std.tref; -- Рег. номер строки заказа подразделения
  begin
    
    -- запись
    RRESJOURNAL := udo_pkg_get.ROW_RESJOURNAL(NRN => NDOCUMENT,NSMART => 0);
    
    if RRESJOURNAL.RES_END_DATE is not null then 
      p_exception(0 , 'Резерв снят. Повторное действие недопустимо.');
    end if; 
    
    /* считывание привязки к строке заказа подразделения */
    nDORDSP := udo_pkg_depords_prf.GET_BY_RSRV(nRSRV => RRESJOURNAL.rn,NSMART => 1);
        
    -- закрываем резерв
    update RESJOURNAL
       set RES_END_DATE = RRESJOURNAL.RES_START_DATE
          ,NOTES        = SUBSTR(SNOTE || NOTES
                                ,1
                                ,240)
     where RN = NDOCUMENT;
    -- отражение снятия резервирования на ТЗ и истории ТЗ
    P_GOODSSUPPLY_RECALC2(RRESJOURNAL.COMPANY
                         ,RRESJOURNAL.SUPPLY
                         ,RRESJOURNAL.RES_START_DATE
                         ,1 --nRES_TYPE
                         ,RRESJOURNAL.QUANT
                         ,RRESJOURNAL.QUANT_ALT);
    
    /* Добавление исполнения строки заказа подразделения */
    if nvl(NDORDS_SETNULL,0) = 1 then 
      if nDORDSP is null then 
        null;
        /*udo_pkg_depords_prf.BINSERT(nDORDSP    => nDORDSP,
                                    nRSRV      => RRESJOURNAL.RN,
                                    nQUANT     => 0,
                                    nQUANT_ALT => 0);*/
      
      else  
        udo_pkg_depords_prf.SET_QUANT(nDORDSP    => nDORDSP,
                                      nRSRV      => RRESJOURNAL.RN,
                                      nQUANT     => 0,
                                      nQUANT_ALT => 0);                            
      end if;   
    end if;
    
    --удаление связей
    if NLINK_DROP = 1
    then
      P_LINKSALL_DELETE_FULL_OUT(RRESJOURNAL.COMPANY
                                ,'ReservationJournal'
                                ,RRESJOURNAL.RN);
       /*begin
       update articlessupply a set
       a.ship_plan=0
       where a.article=(select r.rn from rlarticles r where  r.code=RRESJOURNAL.SER_NUM);    
       exception when others then null; end;   */        
   
   end if;
  end;

  --Процедура снятия резервирования ТЗ из приходного ордера по заказам подразделений
  /*procedure TAKE_BY_INORDERS(NDOCUMENT in number) is
    NCNT number;
  begin
    for CUR in (select RJ.*
                      ,IO.INDOCPREF
                      ,IO.INDOCNUMB
                  from INORDERS     IO
                      ,INORDERSPECS IOS
                      ,RESJOURNAL   RJ
                 where IO.RN = NDOCUMENT
                   and IO.RN = IOS.PRN
                   and RJ.RES_END_DATE is null
                   and RJ.SUPPLY = IOS.GOODSSUPPLY)
    loop
      select count(DL.RN)
        into NCNT
        from DOCLINKS DL
       where DL.IN_DOCUMENT = CUR.RN
         and DL.IN_UNITCODE = 'ReservationJournal'
         and DL.OUT_UNITCODE = 'SheepDirectToDepts';
      if NVL(NCNT
            ,0) != 0
      then
        P_EXCEPTION(0
                   ,'Невозможно закрыть запись журнала резервирования. По текущему резерву существует связь с расходными документами.');
      end if;
      -- снятие резерва
      P_RESJOURNAL_STORN(NCOMPANY => CUR.COMPANY
                        ,NRN      => CUR.RN
                        ,SNOTES   => 'Резерв снят при снятии отработки с приходного ордера №' ||
                                     trim(CUR.INDOCPREF) || '-' ||
                                     trim(CUR.INDOCNUMB) || '.');
    end loop CUR;
  end;*/

  --Процедура снятия резервирования ТЗ из заказа подразделений
  procedure TAKE_BY_DORD
  (
    NDOCUMENT        in number
   ,NDOCUMENT_PARENT in number
  ) is
    RDORD DEPARTMENTORD%rowtype; -- запись ЗП
  begin
    -- запись ЗП
    begin
      select *
        into RDORD
        from DEPARTMENTORD
       where RN = NDOCUMENT_PARENT;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0, NDOCUMENT_PARENT, 'DEPARTMENTORD');
    end;
  
    
    -- проверка прав доступа
    PKG_ENV.ACCESS(NCOMPANY => RDORD.COMPANY
                  ,NVERSION => null
                  ,NCATALOG => RDORD.CRN
                  ,SUNIT    => 'UdoDepartmentsOrdersRsrv'
                  ,SACTION  => 'UDO_DEPARTMENTORD_RSRV_TAKE');
    TAKE(NDOCUMENT  => NDOCUMENT
        ,SNOTE      => 'Резервирование снято из раздела "' ||
                       GET_UNITLIST_NAME_CODE(0, 'DepartmentsOrders') || '"'
        ,NLINK_DROP => 1
        ,NDORDS_SETNULL  => 1 -- признак обнуления исполнения (0-не обнулять, 1 - обнулять )
        );
     

  end;

  --Процедура снятия резервирования ТЗ из спецификации заказа подразделений
  procedure TAKE_BY_DORDS
  (
    NDOCUMENT        in number -- запись резерва по строке ЗП
   ,NDOCUMENT_PARENT in number -- запись спецификации ЗП
  ) is
    RDORD DEPARTMENTORD%rowtype; -- запись ЗП
    nCMPL pkg_std.tref;
  begin
   -- запись ЗП
    begin
      select D.*
        into RDORD
        from DEPARTMENTORD  D
            ,DEPARTMENTORDS DS
       where DS.PRN = D.RN
         and DS.RN = NDOCUMENT_PARENT;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0, NDOCUMENT_PARENT, 'DEPARTMENTORDS');
    end;
    -- проверка прав доступа
    PKG_ENV.ACCESS(NCOMPANY => RDORD.COMPANY
                  ,NVERSION => null
                  ,NCATALOG => RDORD.CRN
                  ,SUNIT    => 'UdoDepartmentsOrdersSpRsrv'
                  ,SACTION  => 'UDO_DEPARTMENTORDS_RSRV_TAKE');
    
    
    /* считывание привязки к строке заказа подразделения */
    nCMPL := udo_pkg_depords_prf.GET_CMPL_BY_RSRV(nRSRV => NDOCUMENT,NSMART => 1);
    
    if /*utilizer != 'KHOK' and*/ nCMPL is not null then 
      p_exception(0 , 'Резерв включен в КВ "%s", закрытие невозможно. Необходимо исключить резерв из КВ перед закрытием.', UDO_F_RESJOURNAL_DELIVSH(NDOCUMENT));
    end if;
    
    TAKE(NDOCUMENT  => NDOCUMENT
        ,SNOTE      => 'Резервирование снято из раздела "' ||
                       GET_UNITLIST_NAME_CODE(0
                                             ,'DepartmentsOrders') || '"'
        ,NLINK_DROP => 1 
        ,NDORDS_SETNULL  => 1 -- признак обнуления исполнения (0-не обнулять, 1 - обнулять )
        );
 

  end;


  -- разбиение резерва на 2 части
  procedure DIVISION
  (
    NRESJOURNAL_SRC  in number -- рег. номер записи резерва источника
   ,NQUANT_IN        in number -- кол-во для выделения
   ,NRESJOURNAL_IN   out number -- рег. номер записи резерва с выделенным количеством
   ,NRESJOURNAL_REST out number -- рег. номер записи резерва с остатком количества
  ) is
    RRESJOURNAL   RESJOURNAL%rowtype; -- запись резерва источника
    NQUANT_SRC    number; -- количество в записи источнике
    NIN_DOCUMENT  number; -- рег. номер документа порождающего связь
    NOUT_DOCUMENT number; -- рег. номер документа принимающего связь
    type TTLINK is table of DOCLINKS%rowtype; -- тип коллекции для связей документа резерва
    TLINK TTLINK := TTLINK(); -- коллекция для связей документа резерва
    rDORDSP_PRF               udo_depords_prf%rowtype;
  begin
    -- запись резерва
    RRESJOURNAL := udo_pkg_get.ROW_RESJOURNAL(NRN => NRESJOURNAL_SRC,NSMART => 0);
    
    NQUANT_SRC  := RRESJOURNAL.QUANT;

    /* считывание привязки к строке заказа подразделения */
    rDORDSP_PRF := udo_pkg_depords_prf.GET(nRSRV => NRESJOURNAL_SRC,NSMART => 1);
    
    -- проверка корректности выделяемого количества
    if NQUANT_IN >= RRESJOURNAL.QUANT
    then
      P_EXCEPTION(0
                 ,'Количество для выделения "%S" должно быть меньше зарезервированого количества  "%S". разделение невозможно'
                 ,NQUANT_IN
                 ,RRESJOURNAL.QUANT);
    end if;
    -- проверка даты закрытия резерва
    if RRESJOURNAL.RES_END_DATE is not null
    then
      P_EXCEPTION(0, 'Разделение доступно только для не закрытых резервов.');
    end if;
    -- считываем связи резерва
    select DL.* bulk collect
      into TLINK
      from DOCLINKS DL
     where (DL.IN_UNITCODE = 'ReservationJournal' and
           DL.IN_DOCUMENT = RRESJOURNAL.RN)
        or (DL.OUT_UNITCODE = 'ReservationJournal' and
           DL.OUT_DOCUMENT = RRESJOURNAL.RN);
    -- удаляем текущий резерв
    P_RESJOURNAL_STORN(NCOMPANY => RRESJOURNAL.COMPANY
                      ,NRN      => RRESJOURNAL.RN
                      ,SNOTES   => SUBSTR('Снято резервирование при разделении резерва.' ||
                                          RRESJOURNAL.NOTES
                                         ,1
                                         ,240));
    
    /* Обнуление кол-ва строки исполнения заказа подразделения */
    if rDORDSP_PRF.dordsp is not null then 
      udo_pkg_depords_prf.SET_QUANT(nDORDSP    => rDORDSP_PRF.dordsp,
                                    nRSRV      => RRESJOURNAL.RN,
                                    nQUANT     => 0,
                                    nQUANT_ALT => 0);
      udo_pkg_depords_prf.SET_CMPL(nDORDSP => rDORDSP_PRF.dordsp,
                                    nRSRV  => RRESJOURNAL.RN,
                                    nCMPL  => null);
      udo_pkg_depords_prf.SET_INVDPTSP(nDORDSP   => rDORDSP_PRF.dordsp,
                                       nRSRV     => RRESJOURNAL.RN,
                                       nINVDPTSP => null);                                
    end if;                            
    
    -- запись резерва (количество которое требовалось выделить)
    RRESJOURNAL.QUANT := NQUANT_IN;
    
    MAKE(RRESJRN => RRESJOURNAL);
    NRESJOURNAL_IN := RRESJOURNAL.RN; 
    /* Добавление исполнения строки заказа подразделения */
    if rDORDSP_PRF.dordsp is not null then 
      udo_pkg_depords_prf.BINSERT(nDORDSP    => rDORDSP_PRF.dordsp,
                                  nRSRV      => NRESJOURNAL_IN,
                                  nQUANT     => RRESJOURNAL.QUANT,
                                  nQUANT_ALT => RRESJOURNAL.QUANT_ALT,
                                  nINVDPTSP  => rDORDSP_PRF.Invdptsp,
                                  nCMPL      => rDORDSP_PRF.Cmpl);
    end if;   
    
    -- запись резерва (оставшееся количество)
    RRESJOURNAL.QUANT     := NQUANT_SRC - NQUANT_IN;
    RRESJOURNAL.QUANT_ALT := 0; 
    
    MAKE(RRESJRN => RRESJOURNAL);
    NRESJOURNAL_REST := RRESJOURNAL.RN;
    /* Добавление исполнения строки заказа подразделения */
    if rDORDSP_PRF.dordsp is not null then 
      udo_pkg_depords_prf.BINSERT(nDORDSP    => rDORDSP_PRF.dordsp,
                                  nRSRV      => NRESJOURNAL_REST,
                                  nQUANT     => RRESJOURNAL.QUANT,
                                  nQUANT_ALT => RRESJOURNAL.QUANT_ALT,
                                  nINVDPTSP  => rDORDSP_PRF.Invdptsp,
                                  nCMPL      => rDORDSP_PRF.Cmpl);
    end if;    
                                       
    -- формирование связей для записей резерва
    if TLINK.COUNT > 0
    then
      -- цикл по связям
      for INDX in TLINK.FIRST .. TLINK.LAST
      loop
        -- цикл по записям резерва
        for CUR in (select NRESJOURNAL_IN as NDOCUMENT
                      from DUAL
                    union all
                    select NRESJOURNAL_REST as NDOCUMENT
                      from DUAL)
        loop
          -- подмена исходого резерва на вновь созданные резервы
          if TLINK(INDX).IN_DOCUMENT = NRESJOURNAL_SRC
          then
            NIN_DOCUMENT  := CUR.NDOCUMENT;
            NOUT_DOCUMENT := TLINK(INDX).OUT_DOCUMENT;
          else
            NIN_DOCUMENT  := TLINK(INDX).IN_DOCUMENT;
            NOUT_DOCUMENT := CUR.NDOCUMENT;
          end if;
          -- добавление записи
          begin 
          P_LINKSALL_LINK_DIRECT(NCOMPANY          => TLINK(INDX).IN_COMPANY
                                ,SIN_UNITCODE      => TLINK(INDX).IN_UNITCODE
                                ,NIN_DOCUMENT      => NIN_DOCUMENT
                                ,NIN_PRN_DOCUMENT  => null
                                ,DIN_IN_DATE       => TLINK(INDX).IN_DATE
                                ,NIN_STATUS        => 0
                                ,SOUT_UNITCODE     => TLINK(INDX).OUT_UNITCODE
                                ,NOUT_DOCUMENT     => NOUT_DOCUMENT
                                ,NOUT_PRN_DOCUMENT => null
                                ,DOUT_IN_DATE      => TLINK(INDX).OUT_DATE
                                ,NOUT_STATUS       => 0);
        exception when others then 
         p_exception(0, 'NRESJOURNAL_SRC:'||NRESJOURNAL_SRC||' - '||error_text);
        end;
        end loop;
      end loop CUR;
    end if;
  end;

  /*Процедура выполняет закрытие резервов перед отработкой РН*/
  procedure RSRV_CLOSE_TRNSINVDPT(NRN in number -- Регистрационный номер записи расходной накладной
                                  ) is
    sNOTE   resjournal.notes%type;
    ndordsp pkg_std.tref;
    nQUANT  number(17, 3);
  begin
    /* Проверка связи с КВ */
    /* 05/12/2023 Марков МВ.
       Добавились прямые выдачи из заказов подразделений - снимаем резервы по линкам
    begin
      if f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDepts',
                                nOUT_DOCUMENT => NRN,
                                sIN_UNITCODE  => 'CostDeliverySheets') is null then
        return;
      end if;
    exception
      when others then
        return;
    end;*/
  
    sNOTE := 'Резервирование снято из раздела "' || GET_UNITLIST_NAME_CODE(0, 'GoodsTransInvoicesToDepts') || '".';
  
    if f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDepts',
                              nOUT_DOCUMENT => NRN,
                              sIN_UNITCODE  => 'CostDeliverySheets') is not null then
      -- Накладная связана с КВ - снять резервирование по КВ
      /*Цикл по резервам*/
      for cur in (select s.RN      as NLRN,
                         s.crn,
                         s.company,
                         rj.rn     as nRSRV,
                         rj.quant
                    from TRANSINVDEPTSPECS S,
                         doclinks          dl,
                         resjournal        rj
                   where S.PRN = NRN
                     and s.rn = dl.out_document
                     and dl.out_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
                     and dl.in_unitcode = 'ReservationJournal'
                     and rj.rn = dl.in_document
                     and rj.res_end_date is null
                  ) loop
      
        /* считывание привязки к строке заказа подразделения */
        ndordsp := udo_pkg_depords_prf.GET_BY_RSRV(nRSRV => cur.nrsrv, NSMART => 1);
        /*Выполняем очистку регистрационного номера записи строки требования-накладной*/
      
        if ndordsp is not null then
          udo_pkg_depords_prf.SET_INVDPTSP(nDORDSP => ndordsp, nRSRV => cur.nrsrv, nINVDPTSP => cur.nlrn);
        end if;
        /* очиска буфера сообщений */
        PKG_GOODS_CHECK.P_CLEAR_ERRORS;
      
        /* Закрытие резерва */
        P_RESJOURNAL_STORN(nCOMPANY => cur.company, nRN => cur.nrsrv, sNOTES => sNOTE);
      
        if (PKG_GOODS_CHECK.P_GET_ERRORS_COUNT <> 0) then
          PKG_GOODS_CHECK.P_CHECK_RIGHTS(0, cur.COMPANY, cur.CRN);
        end if;
      end loop;
    
    elsif f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDepts',
                                 nOUT_DOCUMENT => NRN,
                                 sIN_UNITCODE  => 'DepartmentsOrders') is not null then
      -- накладная создана из Заказа подразделения - прямая выдача комплектующих в производство

      -- 05/12/2023 Марков МВ. Снимем резервы при недостаточности свободного остатка
      for crsp in(select TDS.RN,
                         TDS.PRN,
                         TDS.NOMMODIF,
                         MD.PRN as NOMEN,
                         TDS.GOODSPARTY,
                         TD.STORE,
                         TD.COMPANY,
                         TDS.QUANT,
                         (select GS.RN from GOODSSUPPLY GS
                           where GS.PRN = TDS.GOODSPARTY and GS.STORE = TD.STORE) as SUPPLY,
                         (select (GS.RESTFACT - GS.RESERV) from GOODSSUPPLY GS
                           where GS.PRN = TDS.GOODSPARTY and GS.STORE = TD.STORE) as RESTFACT
                    from TRANSINVDEPT      TD, 
                         TRANSINVDEPTSPECS TDS,
                         NOMMODIF          MD
                   where TDS.PRN = TD.RN
                     and TD.RN = nRN
                     and TDS.NOMMODIF = MD.RN
                     and TD.DOCDATE > s2d('01.12.2023') -- только после 1 декабря. Более ранние докумнты могут быть из 1С
                     ) loop
        if crsp.quant > crsp.restfact then
--if utilizer = 'CITK_MARKOV' then p_exception(0, 'crsp.quant = %s; crsp.restfact = %s', crsp.quant, crsp.restfact); end if;
          nQUANT := crsp.quant - crsp.restfact;
          -- находим строку в заказе и снимаем нужное количество резерва
          for rsrv in(select DS.RN
                        from DEPARTMENTORDS DS, 
                             DOCLINKS       L
                       where L.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
                         and L.OUT_DOCUMENT = nRN
                         and L.IN_UNITCODE = 'DepartmentsOrders' 
                         and L.IN_DOCUMENT = DS.PRN 
                         and DS.NOMEN = crsp.nomen 
                         and DS.NOM_MODIF = crsp.nommodif) loop
            -- снимем резерв по нужному товарному запасу
            for rprf in(select PRF.RN,
                               PRF.QUANT,
                               PRF.RSRV
                          from UDO_DEPORDS_PRF PRF,
                               RESJOURNAL      RES
                         where PRF.DORDSP = rsrv.rn
                           and PRF.RSRV = RES.RN
                           and RES.RES_END_DATE is null
                           and RES.SUPPLY = crsp.supply) loop
              if nQUANT < rprf.quant then
                -- снимем только часть резерва
                /*UDO_P_DEPARTMENTORDS_RSRV_FREE*/UDO_P_DPO_RSRV_FREE_BASE(nRN => rprf.rsrv, nCOMPANY => crsp.company, nQUANT => nQUANT);
                nQUANT := 0;
                exit;
              else
                -- снимем полностью резерв
                TAKE_BY_DORDS(NDOCUMENT => rprf.rsrv, NDOCUMENT_PARENT => rsrv.rn);
                nQUANT := nQUANT - rprf.quant;
              end if;
            end loop;
            
            if nQUANT <= 0 then
              exit;
            end if;
          end loop;
          
        end if;
      end loop;
      
    else
      null;
    end if;
  
  end RSRV_CLOSE_TRNSINVDPT;
  
  
  /*Процедура выполняет восстановление резервов после снятием отработки с расходной накладной в подразделения */
  procedure RSRV_OPEN_TRNSINVDPT
  (
    NRN                       in number -- Регистрационный номер записи расходной накладной
  )
  is
    nRSRV                     pkg_std.tREF;
    nCMPL                     pkg_std.tREF;
    rRSRV                     resjournal%rowtype;
    --
    nCMPL_QUANT               FCDELIVSHSPCMPL.QUANT%type;
    --
    sPARTY_CODE               INCOMDOC.CODE%type;
    sSERNUMB                  GOODSPARTIES.SERNUMB%type;
  begin
    /* Проверка связи с КВ */
    if f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDepts',nOUT_DOCUMENT => NRN,sIN_UNITCODE  => 'CostDeliverySheets') is null then  
      return;
    end if;
    
    /*Цикл по резервам*/
    for cur in (/*1. Резервы связанные со заказом подразделения */
                select s.company    as ncompany,
                       R.RN         as NRN,
                       R.DORDSP     as NDORDSP,
                       R.RSRV       as NRSRV,
                       R.QUANT      as NQUANT_PERF,
                       R.QUANT_ALT  as NQUANT_PERF_ALT,
                       R.INVDPTSP   as NINVDPTSP,
                       R.CMPL       as NCMPL,
                       J.SUPPLY     as NSUPPLY,
                       J.QUANT      as NQUANT,
                       J.QUANT_ALT  as NQUANT_ALT,
                       c.prn        as nCMPL_HEAD, 
                       s.goodsparty as nPARTY
                   from TRANSINVDEPTSPECS         S,
                        UDO_DEPORDS_PRF           R,
                        RESJOURNAL                J,
                        fcdelivshspcmpl           cm,
                        fcdelivshsp               c
                  where S.PRN = NRN 
                    and R.INVDPTSP = S.RN
                    and J.RN = R.RSRV
                    and r.cmpl = cm.rn -- 16/03/2023 Марков МВ (иначе пустое значнеие nCMPL_HEAD (+)
                    and cm.prn  = c.rn --(+) 
                  union all  
                  /*2. Резервы связанные со строкой КВ напрямую */
                 select s.company   as ncompany,
                        null        as NRN,
                        null        as NDORDSP,
                        j.rn        as NRSRV,
                        j.Quant     as NQUANT_PERF,
                        j.Quant_Alt as NQUANT_PERF_ALT,
                        s.rn        as NINVDPTSP,
                        null        as NCMPL,
                        j.SUPPLY    as NSUPPLY,
                        J.QUANT     as NQUANT,
                        J.QUANT_ALT as NQUANT_ALT,
                        f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
                                               nOUT_DOCUMENT => s.rn,
                                               sIN_UNITCODE  => 'CostDeliverySheets') as nCMPL_HEAD,
                        gs.prn 	    as nPARTY 
                   from TRANSINVDEPTSPECS         S,
                        doclinks                  dl,
                        RESJOURNAL                J,
                        goodssupply               gs 
                  where S.PRN = NRN 
                    and dl.in_unitcode = 'ReservationJournal'
                    and dl.in_document = j.rn
                    and dl.out_unitcode ='GoodsTransInvoicesToDeptsSpecs'
                    and dl.out_document = s.rn
                    and j.supply = gs.rn
                    and not exists (select null from udo_depords_prf pr where pr.rsrv = j.rn)
                  )
    loop
      /* восстанавливаем резерв по строке заказа подразделения*/
      if cur.nrn is not null then 
        /*Выполняем очистку регистрационного номера записи строки требования-накладной*/
        udo_pkg_depords_prf.SET_INVDPTSP(nDORDSP   => cur.ndordsp,
                                         nRSRV     => cur.nrsrv,
                                         nINVDPTSP => null);
        udo_pkg_depords_prf.SET_CMPL(nDORDSP   => cur.ndordsp,
                                     nRSRV     => cur.nrsrv,
                                     nCMPL     =>  null); 
        
        udo_pkg_depords_prf.SET_QUANT(nDORDSP   => cur.ndordsp,
                                     nRSRV      => cur.nrsrv,
                                     nQUANT     =>  0,
                                     nQUANT_ALT =>  0);
                                                                   
        /*Выполняем проверку очистки регистрационного номера записи строки требования-накладной*/
        if (sql%notfound)
        then
          PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => CUR.NRN,
                                   SUNIT_TABLE => 'UDO_DEPORDS_PRF');
        end if;
        
        
        /* Создаем резерв и связываем его с документами */
        MAKE_BY_DORDS_EX(NSUPPLY  => cur.nsupply,
                         NQUANT   => cur.NQUANT,
                         nDEPORDS => cur.ndordsp,
                         nRSRV    => nRSRV );
                         
        /*Выполняем установку регистрационного номера записи строки КВ*/ 
        udo_pkg_depords_prf.SET_CMPL(nDORDSP   => cur.ndordsp,
                                     nRSRV     => nRSRV,
                                     nCMPL     =>  cur.ncmpl); 
                                     
        /* связь со строкой расходной накладной на отпуск подраздления */
        for link in (select 'GoodsTransInvoicesToDeptsSpecs' as sUNITCODE, cur.ninvdptsp as nDOCUMENT from dual 
                      union all 
                     select 'CostDeliverySheets' as sUNITCODE, cur.nCMPL_HEAD as nDOCUMENT from dual 
                      union all 
                     select 'CostDeliverySheetsSpecCompletion' as sUNITCODE, cur.ncmpl as nDOCUMENT from dual)
        loop  
          if link.ndocument is null then
            p_exception(0, 'unit = %s', link.sunitcode);
          end if;
          p_linksall_link_direct(nCOMPANY          => cur.nCOMPANY,
                                 sIN_UNITCODE      => 'ReservationJournal',
                                 nIN_DOCUMENT      => nRSRV,
                                 nIN_PRN_DOCUMENT  => null,
                                 dIN_IN_DATE       => sysdate,
                                 nIN_STATUS        => 0,
                                 sOUT_UNITCODE     => link.sUNITCODE ,
                                 nOUT_DOCUMENT     => link.nDOCUMENT,
                                 nOUT_PRN_DOCUMENT => null,
                                 dOUT_IN_DATE      => sysdate,
                                 nOUT_STATUS       => 0,
                                 nBREAKUP_KIND     => 1);
        end loop;
    /* восстанавливаем резерв из строки КВ */
    else 
      /* считывание записи ЖР */
      rRSRV := udo_pkg_get.ROW_RESJOURNAL(NRN => cur.NRSRV, NSMART => 1);
      
      /* создание резерва */
      if rRSRV.rn is not null --and utilizer not in ('CITK_MARKOV')
         then 
        
        rRSRV.Res_End_Date := null; 
        rRSRV.Notes := 'Зарезервировано из раздела "' ||
                       GET_UNITLIST_NAME_CODE(0, 'CostDeliverySheets') || '"';
      
        /* Поиск строки комплектования КВ */
        /* 22/01/2023 Марков МВ. При замене нескольких позиций на одну и ту же получается общее количество
                                 на несколько строк коплектования.
                                 Надо обходить все строки и смотреть по количеству в накладной!!!
        begin 
          select cm.rn
            into nCMPL
            from fcdelivshspcmpl cm
           where cm.prn = f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
                                                 nOUT_DOCUMENT => cur.ninvdptsp,
                                                 sIN_UNITCODE  => 'CostDeliverySheetsSpec') 
             and cm.party = cur.nPARTY
             and cm.quant = rRSRV.quant;
        exception 
          when no_data_found then 
            p_exception(0 , 'Для строки РН рег. номер "%s" не удалось определить строку комплектования КВ', cur.ninvdptsp);
          when too_many_rows then 
            p_exception(0 , 'Для строки РН рег. номер "%s" не удалось однозначно определить строку комплектования КВ', cur.ninvdptsp);
        end;*/
        -- количество связанных строк комплектования
        select count(*)
          into nCMPL
          from doclinks        l,
               fcdelivshspcmpl cm
         where l.out_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
           and L.OUT_DOCUMENT = cur.ninvdptsp
           and L.IN_UNITCODE = 'CostDeliverySheetsSpec'
           and L.IN_DOCUMENT = CM.PRN
           and cm.party = cur.nPARTY;
        
        if nCMPL = 1 then
          MAKE(RRESJRN => rRSRV);
          -- одна строка - должно совпадать
          begin 
            select cm.rn
              into nCMPL
              from fcdelivshspcmpl cm
             where cm.prn = f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
                                                   nOUT_DOCUMENT => cur.ninvdptsp,
                                                   sIN_UNITCODE  => 'CostDeliverySheetsSpec') 
               and cm.party = cur.nPARTY
               and (cm.quant = rRSRV.quant /*or utilizer = 'KHOK'*/); -- Нужна ли тут проверка по количеству? KHOK, 25/10/2023
          exception 
            when no_data_found then 
              begin
                select GP.SERNUMB,
                       IC.CODE
                  into sSERNUMB,
                       sPARTY_CODE
                  from GOODSPARTIES GP,
                       INCOMDOC     IC
                 where GP.RN = cur.nparty
                   and Gp.Indoc = IC.RN;
              exception
                when no_data_found then
                  sSERNUMB    := '';
                  sPARTY_CODE := '';
              end;
--if utilizer != 'KHOK' then  
              p_exception(0 , 'Для строки РН рег. номер "%s" не удалось определить строку комплектования КВ.'||chr(10)||
                              'PARTY: %s'||chr(10)||
                              'Серия: %s'||chr(10)||
                              'Партия: %s'||chr(10)||
                              'Резерв: %s',
                              cur.ninvdptsp, cur.nPARTY, sSERNUMB, sPARTY_CODE, rRSRV.Rn);
--end if; 
            when too_many_rows then 
              p_exception(0 , 'Для строки РН рег. номер "%s" не удалось однозначно определить строку комплектования КВ', cur.ninvdptsp);
          end;
          
          /* удаляем связь с закрытым резервом */
          p_linksall_remove(nCOMPANY      => cur.nCOMPANY,
                            sIN_UNITCODE  => 'ReservationJournal',
                            nIN_DOCUMENT  => cur.NRSRV,
                            sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
                            nOUT_DOCUMENT => cur.ninvdptsp);
                            
          /* Привязка к документам */
          for link in (select 'ReservationJournal' as sIN_UNITCODE, 
                              rRSRV.rn             as nIN_DOCUMENT, 
                              'GoodsTransInvoicesToDeptsSpecs' as sOUT_UNITCODE, 
                              cur.ninvdptsp                    as nOUT_DOCUMENT
                         from dual 
                        union all 
                       select 'CostDeliverySheets' as sIN_UNITCODE, 
                              cur.nCMPL_HEAD       as nIN_DOCUMENT,
                              'ReservationJournal' as sIN_UNITCODE, 
                              rRSRV.rn             as nIN_DOCUMENT 
                         from dual 
                          union all 
                       select 'CostDeliverySheetsSpecCompletion' as sIN_UNITCODE, 
                              nCMPL                              as nIN_DOCUMENT,
                              'ReservationJournal'               as sIN_UNITCODE, 
                              rRSRV.rn                           as nIN_DOCUMENT 
                         from dual)
          loop  
            p_linksall_link_direct(nCOMPANY          => cur.nCOMPANY,
                                   sIN_UNITCODE      => link.sIN_UNITCODE,
                                   nIN_DOCUMENT      => link.nIN_DOCUMENT,
                                   nIN_PRN_DOCUMENT  => null,
                                   dIN_IN_DATE       => sysdate,
                                   nIN_STATUS        => 0,
                                   sOUT_UNITCODE     => link.sOUT_UNITCODE ,
                                   nOUT_DOCUMENT     => link.nOUT_DOCUMENT,
                                   nOUT_PRN_DOCUMENT => null,
                                   dOUT_IN_DATE      => sysdate,
                                   nOUT_STATUS       => 0,
                                   nBREAKUP_KIND     => 1);
          end loop;

        elsif nCMPL > 1 then
          -- количество связанного со строкой накладной строк комплетования
          select sum(cm.quant)
            into nCMPL_QUANT
            from fcdelivshspcmpl cm
           where cm.prn = f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
                                                 nOUT_DOCUMENT => cur.ninvdptsp,
                                                 sIN_UNITCODE  => 'CostDeliverySheetsSpec') 
             and cm.party = cur.nPARTY;
          --
          if nCMPL_QUANT = rRSRV.quant then
            -- общее количество
            for rrsv in(select cm.rn,
                               cm.quant
                          from doclinks        l,
                               fcdelivshspcmpl cm
                         where l.out_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
                           and L.OUT_DOCUMENT = cur.ninvdptsp
                           and L.IN_UNITCODE = 'CostDeliverySheetsSpec'
                           and L.IN_DOCUMENT = CM.PRN
                           and cm.party = cur.nPARTY) loop
              -- создаем резерв на колическтво комплектования
              rRSRV.Quant := rrsv.quant;
              MAKE(RRESJRN => rRSRV);
              /* удаляем связь с закрытым резервом */
              p_linksall_remove(nCOMPANY      => cur.nCOMPANY,
                                sIN_UNITCODE  => 'ReservationJournal',
                                nIN_DOCUMENT  => cur.NRSRV,
                                sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
                                nOUT_DOCUMENT => cur.ninvdptsp);
                                
              /* Привязка к документам */
              for link in (select 'ReservationJournal' as sIN_UNITCODE, 
                                  rRSRV.rn             as nIN_DOCUMENT, 
                                  'GoodsTransInvoicesToDeptsSpecs' as sOUT_UNITCODE, 
                                  cur.ninvdptsp                    as nOUT_DOCUMENT
                             from dual 
                            union all 
                           select 'CostDeliverySheets' as sIN_UNITCODE, 
                                  cur.nCMPL_HEAD       as nIN_DOCUMENT,
                                  'ReservationJournal' as sIN_UNITCODE, 
                                  rRSRV.rn             as nIN_DOCUMENT 
                             from dual 
                              union all 
                           select 'CostDeliverySheetsSpecCompletion' as sIN_UNITCODE, 
                                  rrsv.rn                            as nIN_DOCUMENT,
                                  'ReservationJournal'               as sIN_UNITCODE, 
                                  rRSRV.rn                           as nIN_DOCUMENT 
                             from dual)
              loop  
                p_linksall_link_direct(nCOMPANY          => cur.nCOMPANY,
                                       sIN_UNITCODE      => link.sIN_UNITCODE,
                                       nIN_DOCUMENT      => link.nIN_DOCUMENT,
                                       nIN_PRN_DOCUMENT  => null,
                                       dIN_IN_DATE       => sysdate,
                                       nIN_STATUS        => 0,
                                       sOUT_UNITCODE     => link.sOUT_UNITCODE ,
                                       nOUT_DOCUMENT     => link.nOUT_DOCUMENT,
                                       nOUT_PRN_DOCUMENT => null,
                                       dOUT_IN_DATE      => sysdate,
                                       nOUT_STATUS       => 0,
                                       nBREAKUP_KIND     => 1);
              end loop;
            
            end loop;
          
          end if;
        
        else
          -- нет связанных строк
          null;
        end if;
      
      end if;  
    end if;  
    /*                    
    \*Атрибуты товарного запаса*\
    begin
      select GS.*
        into RSUPPLY
        from GOODSSUPPLY GS
       where GS.RN = NSUPPLY_RES
         and GS.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NSUPPLY_RES,
                                 SUNIT_TABLE => 'GoodsSupply');
    end;
    \* проверим текущее состояние заказа *\
    if RORD.ORD_STATE <> 1
    then
      P_EXCEPTION(0,
                  'Резервирование товара по заказу подразделения допустимо только в состоянии "Утвержден".');
    end if;
    if (RORD_SP.NOM_MODIF is null)
    then
      P_EXCEPTION(0,
                  'Для заказа не указана модификация');
    end if;
    \*Выполняем проверку количество резерва в ОЕИ*\
    if (NQUANT >
       UDO_PKG_STORE_OPER_ACC.F_GOODSSUPPLYHIST_CALC_REST(NPRN   => NSUPPLY_RES,
                                                           DDATE  => TRUNC(sysdate),
                                                           NMUNIT => 0))
    then
      P_EXCEPTION(0,
                  'Превышено допустимое количество резерва в ОЕИ ' ||
                  TO_CHAR(UDO_PKG_STORE_OPER_ACC.F_GOODSSUPPLYHIST_CALC_REST(NPRN   => NSUPPLY_RES,
                                                                             DDATE  => TRUNC(sysdate),
                                                                             NMUNIT => 0)));
    end if;
    \*Выполняем проверку количество резерва в ДЕИ*\
    if (NQUANT_ALT >
       UDO_PKG_STORE_OPER_ACC.F_GOODSSUPPLYHIST_CALC_REST(NPRN   => NSUPPLY_RES,
                                                           DDATE  => TRUNC(sysdate),
                                                           NMUNIT => 1))
    then
      P_EXCEPTION(0,
                  'Превышено допустимое количество резерва в ДЕИ ' ||
                  TO_CHAR(UDO_PKG_STORE_OPER_ACC.F_GOODSSUPPLYHIST_CALC_REST(NPRN   => NSUPPLY_RES,
                                                                             DDATE  => TRUNC(sysdate),
                                                                             NMUNIT => 1)));
    end if;
    \*Определяем количество, зарезервированное по указанной строке заказа*\
    P_DEPARTMENTORDS_CALC_RES_QNT(NCOMPANY        => NCOMPANY,
                                  NRN             => NPRN,
                                  NQUANT_PERF     => NQUANT_PERF_OLD,
                                  NQUANT_PERF_ALT => NQUANT_PERF_ALT_OLD);
    \*Выполняем проверку количество резерва в ОЕИ по заказу*\
    if (NQUANT_PERF > RORD_SP.MAIN_QUANT - NQUANT_PERF_OLD)
    then
      if (NSIGN_CANCEL_CHECK_ORD_QUANT = 0)
      then
        P_EXCEPTION(0,
                    'Превышено допустимое количество резерва по заказу в ОЕИ (' ||
                    TO_CHAR(NQUANT_PERF) || ' > ' ||
                    TO_CHAR(RORD_SP.MAIN_QUANT - NQUANT_PERF_OLD) || ')');
      end if;
    end if;
    \*Выполняем проверку количество резерва в ДЕИ по заказу*\
    if (NQUANT_PERF_ALT > RORD_SP.ALT_QUANT - NQUANT_PERF_ALT_OLD)
    then
      if (NSIGN_CANCEL_CHECK_ORD_QUANT = 0)
      then
        P_EXCEPTION(0,
                    'Превышено допустимое количество резерва по заказу в ДЕИ (' ||
                    TO_CHAR(NQUANT_PERF_ALT) || ' > ' ||
                    TO_CHAR(RORD_SP.ALT_QUANT - NQUANT_PERF_ALT_OLD) || ')');
      end if;
    end if;*/
    
     /*UDO_PKG_UZD_01.P_DEPARTMENTORDS_RESERV_BCRT(NCOMPANY                     => NCOMPANY,
                                                  NPRN                         => RES_CURSOR.NPRN,
                                                  NSUPPLY_RES                  => RES_CURSOR.NSUPPLY,
                                                  NQUANT                       => RES_CURSOR.NQUANT,
                                                  NQUANT_ALT                   => RES_CURSOR.NQUANT_ALT,
                                                  NQUANT_PERF                  => RES_CURSOR.NQUANT_PERF,
                                                  NQUANT_PERF_ALT              => RES_CURSOR.NQUANT_PERF_ALT,
                                                  NSIGN_HIST                   => 1,
                                                  NACTIVE                      => 1,
                                                  NSIGN_CANCEL_CHECK_ORD_QUANT => 1,
                                                  NRN                          => NRN_RES);*/ 
      
    end loop;
  
  end;
  
  -- установка кол-ва спецификации заказа подразделения, не участвующего в исполнении
  /*procedure SET_DORDS_EXCEPT
  (
    NCOMPANY  in number
   ,NCRN      in number
   ,NDOCUMENT in number
   ,NQUANT    in number
  ) is
    NTMP number;
  begin
    -- проверка прав доступа
    PKG_ENV.ACCESS(NCOMPANY => NCOMPANY
                  ,NVERSION => null
                  ,NCATALOG => NCRN
                  ,SUNIT    => 'DepartmentsOrdersSpecs'
                  ,SACTION  => 'UDO_DEPARTMENTORDS_SET_QNT_EXCEPT');
    PKG_DOCS_PROPS_VALS.MODIFY(SPROPERTY   => 'КолвоИскл'
                              ,SUNITCODE   => 'DepartmentsOrdersSpecs'
                              ,NDOCUMENT   => NDOCUMENT
                              ,SSTR_VALUE  => null
                              ,NNUM_VALUE  => NQUANT
                              ,DDATE_VALUE => null
                              ,NRN         => NTMP);
  end;*/

  -- Формирование резерва по неисполненныс заказам подразделений 
  /*procedure CREATE_RSRV
  (
    NCOMPANY  in number
   ,NDOCUMENT in number
  ) is
    NSTORE_TEMA  number := 7122526; -- Тематичечский
    NSTORE_BRON  number := 7122509; -- Склад бронирования
    NRES_RN      number;
    NCHECK_QUANT boolean;
    NCHECK_OUT   boolean;
    NQUANT_OUT   number;
    SMSG         PKG_STD.TSTRING;
    NMSG         PKG_STD.tNUMBER;
    SCONFIRM     PKG_STD.TSTRING;
    RDORD        DEPARTMENTORD%rowtype;
    type RRRSRV is record(
       NSUPPLY number
      ,NQUANT  number);
    RRSRV RRRSRV;
    type TTRSRV is table of RRRSRV;
    TRSRV       TTRSRV := TTRSRV();
    NQUANT_RSRV number;
    SNOMEN      PKG_STD.TSTRING;
    NQUANT_SALE number;
    -- формирование возвратной накладной 
    procedure CREATE_TID(NTID_BRON in number) is
      RTID      TRANSINVDEPT%rowtype;
      NTIDSP_RN number;
      NPARTY    number;
      NNOMMODIF number;
      NPRICE    number;
    begin
      -- атрибуты 
      RTID.COMPANY := NCOMPANY;
      RTID.CRN     := 12108281; -- Возврат
      FIND_JURPERSONS_MAIN(NFLAG_SMART => 0
                          ,NCOMPANY    => NCOMPANY
                          ,SJUR_PERS   => SMSG
                          ,NJUR_PERS   => RTID.JUR_PERS);
      RTID.DOCTYPE     := 9913905; -- НАКЛ_ВОЗВР      
      RTID.PREF        := TO_CHAR(D_YEAR(TRUNC(sysdate)));
      RTID.DOCDATE     := TRUNC(sysdate);
      RTID.STOPER      := 7810638; -- Расход/Внутри 
      RTID.STORE       := NSTORE_BRON; -- Склад бронирования
      RTID.MOL         := 7286465;
      RTID.SHEEPVIEW   := 87138;
      RTID.CURRENCY    := PKG_CURBASE.FIND(NCOMPANY => NCOMPANY);
      RTID.SUMMWITHNDS := 0;
      RTID.IN_STORE    := NSTORE_TEMA; -- Тематичечский
      RTID.IN_MOL      := 7286465;
      RTID.IN_STOPER   := 7810290; -- Приход/Внутри
      RTID.COMMENTS    := 'Сформировано при создании резерва для заказа подразделений.';
      if TRSRV.COUNT > 0
      then
        for INDX in TRSRV.FIRST .. TRSRV.LAST
        loop
          select GP.RN
                ,GP.NOMMODIF
                ,(select max(RP.PRICE)
                    from REGPRICE RP
                   where RP.PRN = GS.RN
                     and RP.ADATE = (select max(ADATE)
                                       from REGPRICE
                                      where PRN = GS.RN)) as REGPRICE
            into NPARTY
                ,NNOMMODIF
                ,NPRICE
            from GOODSSUPPLY  GS
                ,GOODSPARTIES GP
           where GS.PRN = GP.RN
             and GS.RN = TRSRV(INDX).NSUPPLY;
          P_TRANSINVDEPT_GETNEXTNUMB(NCOMPANY => RTID.COMPANY
                                    ,sJUR_PERS => SMSG
                                    ,dDOCDATE => RTID.DOCDATE
                                    ,STYPE    => GET_DOCTYPES_CODE_ID(0
                                                                     ,RTID.DOCTYPE)
                                    ,SPREF    => RTID.PREF
                                    ,SNUMB    => RTID.NUMB);
          -- заголовок 
          P_TRANSINVDEPT_BASE_INSERT(NCOMPANY       => RTID.COMPANY
                                    ,NCRN           => RTID.CRN
                                    ,NJUR_PERS      => RTID.JUR_PERS
                                    ,NDOCTYPE       => RTID.DOCTYPE
                                    ,SPREF          => RTID.PREF
                                    ,SNUMB          => RTID.NUMB
                                    ,DDOCDATE       => RTID.DOCDATE
                                    ,NDIRDOC        => RTID.DIRDOC
                                    ,SDIRNUMB       => RTID.DIRNUMB
                                    ,DDIRDATE       => RTID.DIRDATE
                                    ,NSTOPER        => RTID.STOPER
                                    ,NFACEACC       => RTID.FACEACC
                                    ,NGRAPHPOINT    => RTID.GRAPHPOINT
                                    ,NSTORE         => RTID.STORE
                                    ,NMOL           => RTID.MOL
                                    ,NSHEEPVIEW     => RTID.SHEEPVIEW
                                    ,NAGENT         => RTID.AGENT
                                    ,NSUBDIV        => RTID.SUBDIV
                                    ,NCURRENCY      => RTID.CURRENCY
                                    ,NCURCOURS      => NVL(RTID.CURCOURS
                                                          ,1)
                                    ,NCURBASE       => NVL(RTID.CURBASE
                                                          ,1)
                                    ,NSUMMWITHNDS   => RTID.SUMMWITHNDS
                                    ,NRECIPDOC      => RTID.RECIPDOC
                                    ,SRECIPNUMB     => RTID.RECIPNUMB
                                    ,DRECIPDATE     => RTID.RECIPDATE
                                    ,NFERRYMAN      => RTID.FERRYMAN
                                    ,SGETCONFIRM    => RTID.GETCONFIRM
                                    ,SWAYBLADENUMB  => RTID.WAYBLADENUMB
                                    ,NDRIVER        => RTID.DRIVER
                                    ,NCAR           => RTID.CAR
                                    ,NROUTE         => RTID.ROUTE
                                    ,NTRAILER1      => RTID.TRAILER1
                                    ,NTRAILER2      => RTID.TRAILER2
                                    ,NFA_CURCOURS   => RTID.FA_CURCOURS
                                    ,NFA_CURBASE    => RTID.FA_CURBASE
                                    ,NIN_STORE      => RTID.IN_STORE
                                    ,NIN_MOL        => RTID.IN_MOL
                                    ,NIN_STOPER     => RTID.IN_STOPER
                                    ,NIN_PARTY      => RTID.IN_PARTY
                                    ,SIN_PARTY      => null
                                    ,NIN_CURCOURS   => RTID.IN_CURCOURS
                                    ,NIN_CURBASE    => RTID.IN_CURBASE
                                    ,NVALID_DOCTYPE => RTID.VALID_DOCTYPE
                                    ,SVALID_DOCNUMB => RTID.VALID_DOCNUMB
                                    ,DVALID_DOCDATE => RTID.VALID_DOCDATE
                                    ,SCOMMENTS      => RTID.COMMENTS
                                    ,SBARCODE       => RTID.BARCODE
                                    ,NRESERV_SIGN   => 0
                                    ,NRN            => RTID.RN);
          P_TRANSINVDEPTSP_BASE_INSERT(NCOMPANY         => RTID.COMPANY
                                      ,NPRN             => RTID.RN
                                      ,NAGENT           => null
                                      ,NGOODSPARTY      => NPARTY
                                      ,NNOMMODIF        => NNOMMODIF
                                      ,NNOMNMODIFPACK   => null
                                      ,NARTICLE         => null
                                      ,NCELL            => null
                                      ,NTEMPERATURE     => null
                                      ,NPRICE           => NPRICE
                                      ,NQUANT           => TRSRV(INDX).NQUANT
                                      ,NQUANTALT        => 0
                                      ,NCOEFF           => 0
                                      ,NCOEFF_VAL_SIGN  => 0
                                      ,NCOEFF_CALC_SIGN => 1
                                      ,NPRICEMEAS       => 0
                                      ,NSUMMWITHNDS     => TRSRV(INDX)
                                                           .NQUANT * NPRICE
                                      ,DBEGINDATE       => null
                                      ,DENDDATE         => null
                                      ,SNOTE            => null
                                      ,SBCODE           => null
                                      ,SCARDNUMB        => null    --обновление 28\09\18
                                      ,NRN              => NTIDSP_RN);
          P_TRANSINVDEPT_SET_STATUS(NCOMPANY      => NCOMPANY
                                   ,NRN           => RTID.RN
                                   ,NSTATUS       => 2
                                   ,NIN_STATUS    => 1
                                   ,DIN_WORK_DATE => TRUNC(sysdate)
                                   ,DWORK_DATE    => TRUNC(sysdate)
                                   ,SMSG          => SMSG
                                   ,SCONFIRM      => SCONFIRM
                                   ,nIDENT_MSG    => NMSG);
          if SMSG is not null
          then
            P_EXCEPTION(0
                       ,'Создание РН рег. номер ' || RTID.RN || '. Сообщение:' || SMSG);
          end if;
          P_LINKSALL_LINK_DIRECT(NCOMPANY          => NCOMPANY
                                ,SIN_UNITCODE      => 'GoodsTransInvoicesToDepts'
                                ,NIN_DOCUMENT      => NTID_BRON
                                ,NIN_PRN_DOCUMENT  => null
                                ,DIN_IN_DATE       => TRUNC(sysdate)
                                ,NIN_STATUS        => 0
                                ,SOUT_UNITCODE     => 'GoodsTransInvoicesToDepts'
                                ,NOUT_DOCUMENT     => RTID.RN
                                ,NOUT_PRN_DOCUMENT => null
                                ,DOUT_IN_DATE      => TRUNC(sysdate)
                                ,NOUT_STATUS       => 0);
        end loop;
      end if;
    end;
  
  begin
    begin
      select T.*
        into RDORD
        from DEPARTMENTORD T
       where T.RN = NDOCUMENT;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(0
                                ,NDOCUMENT
                                ,'DEPARTMENTORD');
    end;
    -- цикл по бронированиям
    for REC in (select T.*
                  from DOCLINKS     DL
                      ,TRANSINVDEPT T
                 where T.RN = DL.OUT_DOCUMENT
                   and t.status = 1
                   and DL.IN_DOCUMENT = RDORD.RN)
    loop
      TRSRV.DELETE;
      NCHECK_QUANT := false;
      NCHECK_OUT   := false;
      -- цикл по спец борони 
      for SPC in (select GP.RN NGOODSPARTIES
                        ,GS.RN NGOODSSUPPLY
                        ,GP.NOMMODIF
                        ,sum(S.QUANT) NQUANT_BRON
                    from DOCLINKS       DS
                        ,STOREOPERJOURN S
                        ,GOODSSUPPLY    GS
                        ,GOODSPARTIES   GP
                   where DS.IN_DOCUMENT = REC.RN
                     and DS.IN_UNITCODE = 'GoodsTransInvoicesToDepts'
                     and DS.OUT_DOCUMENT = S.RN
                     and DS.OUT_UNITCODE = 'StoreOpersJournal'
                     and S.OPER_TYPE = 0
                     and S.GOODSSUPPLY = GS.RN
                     and GS.STORE = NSTORE_TEMA -- Тематичечский
                     and exists
                   (select null
                            from DOCLINKS       DS1
                                ,STOREOPERJOURN S1
                                ,GOODSSUPPLY    GS1
                           where DS1.IN_DOCUMENT = DS.IN_DOCUMENT
                             and DS1.IN_UNITCODE = 'GoodsTransInvoicesToDepts'
                             and DS1.OUT_DOCUMENT = S1.RN
                             and DS1.OUT_UNITCODE = 'StoreOpersJournal'
                             and S1.GOODSSUPPLY = GS1.RN
                             and GS1.STORE = NSTORE_BRON -- бронирование
                             and S1.OPER_TYPE = 1)
                     and GS.PRN = GP.RN
                   group by GP.RN
                           ,GS.RN
                           ,GP.NOMMODIF)
      loop
         
        -- выданное кол-во по партии 
        select sum(SS.QUANT)
          into NQUANT_OUT
          from DOCLINKS           DL
              ,SHEEPDIRSDEPT      S
              ,SHEEPDIRSDEPTSPECS SS
         where S.RN = DL.OUT_DOCUMENT
           and DL.IN_DOCUMENT = RDORD.RN
           and S.STORE = NSTORE_BRON
           and S.RN = SS.PRN
           and SS.GOODSPARTY = SPC.NGOODSPARTIES;
        -- если была хотя бы одна выдача из распоряжения, то снимать отработку нельзя будем делать возвратный документ 
        if NVL(NQUANT_OUT
              ,0) != 0 and not (NCHECK_OUT)
        then
          NCHECK_OUT := true;
        end if;
        -- кол-во для резервирвоания 
        NQUANT_RSRV := SPC.NQUANT_BRON - NVL(NQUANT_OUT
                                            ,0);
        if NQUANT_RSRV <= 0
        then
          CONTINUE;
        end if;
        --  формируем коллекцию для резервирования (если была выдача то этаколлекция также ля РН)
        TRSRV.EXTEND;
        RRSRV.NSUPPLY := SPC.NGOODSSUPPLY;
        RRSRV.NQUANT := NQUANT_RSRV;
        TRSRV(TRSRV.LAST) := RRSRV;
      end loop SPC;
      -- РЕЗЕРВИРОВАНИЕ 
      if TRSRV.COUNT > 0
      then
        DBMS_OUTPUT.PUT_LINE('Заказ ' || trim(RDORD.ORD_PREF) || '-' ||
                             trim(RDORD.ORD_NUMB) || '        ' ||
                             'Бронирование ' || trim(REC.PREF) || '-' ||
                             trim(REC.NUMB) || '    ' || REC.RN);
        -- если по брони не было выдачи, то снимаем отработку 
        if not (NCHECK_OUT)
        then
          null;
          -- снять отработку 
          for L_CUR in (select SM.*
                          from DOCLINKS        L
                              ,SALESREPORTMAIN SM
                         where L.IN_DOCUMENT = REC.RN
                           and L.OUT_DOCUMENT = SM.RN)
          loop
            P_SALESRPTMAIN_DELETE(NRN      => L_CUR.RN
                                 ,NCOMPANY => L_CUR.COMPANY);
          end loop;
          P_TRANSINVDEPT_SET_STATUS(NCOMPANY      => NCOMPANY
                                   ,NRN           => REC.RN
                                   ,NSTATUS       => 0
                                   ,NIN_STATUS    => 0
                                   ,DIN_WORK_DATE => null
                                   ,DWORK_DATE    => TRUNC(sysdate)
                                   ,SMSG          => SMSG
                                   ,SCONFIRM      => SCONFIRM
                                   ,nIDENT_MSG    => NMSG);
          if SMSG is not null
          then
            P_EXCEPTION(0
                       ,'РН рег. номер ' || REC.RN || '. Сообщение:' || SMSG);
          end if;
          -- номер заказа подразделения записываем в св-ва 
          PKG_DOCS_PROPS_VALS.MODIFY(SPROPERTY   => 'ДОК_ОСН'
                                    ,SUNITCODE   => 'GoodsTransInvoicesToDepts'
                                    ,NDOCUMENT   => REC.RN
                                    ,SSTR_VALUE  => (GET_DOCTYPES_CODE_ID(0
                                                                         ,RDORD.ORD_DOCTYPE) || ' №' ||
                                                    trim(RDORD.ORD_PREF) || '-' ||
                                                    trim(RDORD.ORD_NUMB) ||
                                                    ' от ' ||
                                                    TO_CHAR(RDORD.ORD_DATE
                                                            ,'dd.mm.yyyy'))
                                    ,NNUM_VALUE  => null
                                    ,DDATE_VALUE => null
                                    ,NRN         => SMSG);
          --  удаляем связь с заказом
          \*(NCOMPANY      => NCOMPANY
                           ,SIN_UNITCODE  => 'DepartmentsOrders'
                           ,NIN_DOCUMENT  => CUR.rn
                           ,SOUT_UNITCODE => 'GoodsTransInvoicesToDepts'
                           ,NOUT_DOCUMENT => rec.RN);
          P_LINKSALL_REMOVE(NCOMPANY      => NCOMPANY
                           ,SIN_UNITCODE  => 'DepartmentsOrdersPerform'
                           ,NIN_DOCUMENT  => null
                           ,SOUT_UNITCODE => 'GoodsTransInvoicesToDepts'
                           ,NOUT_DOCUMENT => rec.RN);
            *\
          -- если выдача была то формируем накладную возврата на не выданное количество
        else
          -- формируем возврат на тематику  
          null;
          CREATE_TID(NTID_BRON => REC.RN);
        end if;
        -- формирвоание резерва 
        for INDX in TRSRV.FIRST .. TRSRV.LAST
        loop
          select LEAST(GS.RESTPLAN
                      ,GS.RESTFACT) - GS.RESERV
            into NQUANT_SALE
            from GOODSSUPPLY GS
           where GS.RN = TRSRV(INDX).NSUPPLY;
          if TRSRV(INDX).NQUANT > NVL(NQUANT_SALE
                          ,0)
          then
            \*DBMS_OUTPUT.PUT_LINE('Не найдено достаточное кол-во ТЗ "' ||
            NQUANT_SALE || '" для резервирования "' || TRSRV(INDX)
            .NQUANT || '", рег. номер  ТЗ "' || TRSRV(INDX)
            .NSUPPLY || '".');*\
            P_EXCEPTION(0
                       ,'Не найдено достаточное кол-во ТЗ "%S" для резервирования "%S", рег. номер  ТЗ "%S".'
                       ,NQUANT_SALE
                       ,TRSRV                                                                                                                                     (INDX)
                        .NQUANT
                       ,TRSRV                                                                                                                                     (INDX)
                        .NSUPPLY);
          end if;
          -- добавляем запись резервирования 
          P_RESJOURNAL_BASE_INSERT(NCOMPANY
                                  ,UTILIZER
                                  ,TRSRV(INDX).NSUPPLY
                                  ,TRUNC(sysdate())
                                  ,null
                                  ,TRSRV(INDX).NQUANT
                                  ,0
                                  ,RDORD.ORD_DOCTYPE
                                  ,RDORD.ORD_DATE
                                  ,RDORD.ORD_PREF
                                  ,RDORD.ORD_NUMB
                                  ,null
                                  ,RDORD.SUBDIV
                                  ,null
                                  ,null
                                  ,'Зарезервировано из раздела "' ||
                                   GET_UNITLIST_NAME_CODE(0
                                                         ,'DepartmentsOrders') || '"'
                                  ,NRES_RN);
          select N.NOMEN_CODE || '/' || M.MODIF_CODE
            into SNOMEN
            from DICNOMNS     N
                ,NOMMODIF     M
                ,GOODSSUPPLY  GS
                ,GOODSPARTIES GP
           where N.RN = M.PRN
             and M.RN = GP.NOMMODIF
             and GP.RN = GS.PRN
             and GS.RN = TRSRV(INDX).NSUPPLY;
          DBMS_OUTPUT.PUT_LINE('                       ' || SNOMEN ||
                               '  Кол-во для резервирования -' || TRSRV(INDX)
                               .NQUANT);
        end loop;
        -- формирвоание резерва 
      end if;
    end loop REC;
  end;*/

  /* Процедура контроля снятия резерва из Журнала */
  procedure RSRV_CLOSE_CHECK(nRN in number) is
    sDELIV varchar2(240);
  begin
    -- проверка резерва на наличие накладной
    for rsv in (select L.OUT_UNITCODE
                  from DOCLINKS L
                 where L.IN_DOCUMENT = nRN
                   and L.IN_UNITCODE = 'ReservationJournal'
                   and L.OUT_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs') loop
      --if utilizer not in('CITK_MARKOV', 'KHOK') then
      p_exception(0,
                  'Для данной строки резерва создана расходная накладная.' || chr(10) ||
                  'Для снятия резервирования необходимо сначала удалить накладную.');
      --end if;
    end loop;
    -- проверка переноса резерва по заказу подразделения
    sDELIV := udo_f_resjournal_delivsh(nRN => nRN);
    if rtrim(sDELIV) is not null 
      --and utilizer not in ('CITK_MARKOV', 'KHOK')
      then
      p_exception(0,
                  'Резерв связан со строкой комплектовочной ведомости.' || chr(10) ||
                  'Необходимо сначала исключить комплектование из КВ.');
    end if;
    -- прямое резервирование из КВ
    --if utilizer not in ('KHOK') then       
    for rsv in (select L.OUT_DOCUMENT --.OUT_UNITCODE
                  from DOCLINKS L
                 where L.IN_DOCUMENT = nRN
                   and L.IN_UNITCODE = 'ReservationJournal'
                   and L.OUT_UNITCODE = 'CostDeliverySheetsSpecCompletion') loop
      --if utilizer not in('CITK_MARKOV') then
      p_exception(0,
                  'Резервирование выполнено из Комплектовочной ведомости.' || chr(10) ||
                  'Снятие резервирование необходимо выполнить из КВ.' || chr(10) || rsv.out_document);
      --end if;
    end loop;
    --end if; 
    -- 28/06/2023 Марков МВ. резервирование в заказах подразделения
    --if utilizer in ('CITK_MARKOV'/*, 'KHOK'*/, 'STEPANOV_MV') then return; end if;
    for rec in (select trim(D.ORD_PREF) || '-' || trim(D.ORD_NUMB) ORD_NUMB
                  from UDO_DEPORDS_PRF PRF,
                       DEPARTMENTORDS  DS,
                       DEPARTMENTORD   D
                 where PRF.RSRV = nRN
                   and PRF.DORDSP = DS.RN
                   and DS.PRN = D.RN) loop
      p_exception(0,
                  'Резервирование выполнено для заказа подразделения %s.' || chr(10) ||
                  'Снятие резервирование необходимо выполнить из заказа подразделения.',
                  rec.ord_numb);
    end loop;
  end RSRV_CLOSE_CHECK;
  
begin
  null;
end UDO_PKG_RESJOURNAL_CTRL;
/
