create or replace procedure UDO_P_PRODCOST_ORD
(
  nCOMPANY      in number,
  nIDENT        in number,
  nSIGN_PROJECT in number, -- признак поиска по закупкам для всего проекта (0 - нет, 1 - да)
  nPRODORD      in number
) as
  /*
    16/02/2023 Марков МВ.
    Себестоимость продукции.
    Формирование данных для заказа на производство.
    --
    Принимаем за условие, что:
      - Потребность соответствует указанному ПС в заказе на производство
      - Производственная программа переформирована
      - КВ переформированы
      
    -- хранение информации
    UDO_PRODCOST_TMP - заголовок
    UDO_PRODCOST_TMP_MTR - матресурсы
    UDO_PRODCOST_TMP_SUB - замены
    UDO_PRODCOST_TMP_INCL - входимость
    UDO_PRODCOST_TMP_SER - приходные серии
       тип записи:
       0 - закупка строго по Парусу (10 - участвует в расчете)
       1 - закупка по 1С (11 - участвует в расчете)
       2 - закупка по другим темам (из комплектования) (12 - участвует в расчете)
  */

  rTMP   UDO_PRODCOST_TMP%rowtype;
  rMTR   UDO_PRODCOST_TMP_MTR%rowtype;
  rINCL  UDO_PRODCOST_TMP_INCL%rowtype;
  nEXP   number(17);

  /* заголовок */
  procedure ins_tmp(rROW in out UDO_PRODCOST_TMP%rowtype) is
  begin
    insert into UDO_PRODCOST_TMP values rROW;
  end ins_tmp;
  /* матресурсы */
  procedure ins_mtr(rROW in out UDO_PRODCOST_TMP_MTR%rowtype) is
  begin
    insert into UDO_PRODCOST_TMP_MTR values rROW;
  end ins_mtr;
  /* входимость */
  procedure ins_incl(rROW in out UDO_PRODCOST_TMP_INCL%rowtype) is
  begin
    insert into UDO_PRODCOST_TMP_INCL values rROW;
  end ins_incl;
  /* приходные серии ТМЦ */
  procedure ins_ser(rROW in out UDO_PRODCOST_TMP_SER%rowtype) is
  begin
    insert into UDO_PRODCOST_TMP_SER values rROW;
  end ins_ser;

  /* формирование закупки */
  procedure set_buy is
    rSER UDO_PRODCOST_TMP_SER%rowtype;
    iCNT integer;
  begin
    -- по связанным заказам
    for rdo in (select D.RN
                  from DEPARTMENTORD D,
                       DOCLINKS      L
                 where L.IN_UNITCODE = 'CostProductExpenseActs'
                   and L.IN_DOCUMENT = nEXP
                   and L.OUT_UNITCODE = 'DepartmentsOrders'
                   and L.OUT_DOCUMENT = D.RN) loop
      -- закупка (связанный ВСО)
      for rpa in (select DS.RN        as ORDS_RN,
                         PE.QUANT,
                         PIS.NOMEN,
                         PIS.NOMMODIF,
                         PIS.PRN      as ACC_RN,
                         PIS.RN       as ACCSP_RN,
                         PIS.QUANT    as PAY_QUANT
                    from DEPARTMENTORDS   DS,
                         PAYACCINSPCLC_EX PE,
                         PAYACCINSPCLC    PC,
                         PAYACCINSPEC     PIS
                   where DS.PRN = rdo.rn
                     and PE.DEPARTMENTORDSP = DS.RN
                     and PE.PRN = PC.RN
                     and PC.PRN = PIS.RN) loop
        -- приходная накладная для ВСО
        for rnv in (select IIS.SERNUMB,
                           IIS.RN,
                           IIS.SUMM,
                           IIS.SUMMTAX,
                           IIS.SUMM_NDS,
                           IIS.QUANT,
                           (select MR.RN
                              from FCMATRESOURCE MR
                             where MR.NOMENCLATURE = IIS.NOMEN
                               and MR.NOMEN_MODIF = IIS.MODIF) as MATRES
                      from ININVOICESSPECS IIS,
                           DOCLINKS        L
                     where L.IN_UNITCODE = 'PaymentAccountsIn'
                       and L.IN_DOCUMENT = rpa.acc_rn
                       and L.OUT_UNITCODE = 'IncomingInvoices'
                       and L.OUT_DOCUMENT = IIS.PRN
                       and IIS.NOMEN = rpa.nomen
                       and IIS.MODIF = rpa.nommodif) loop
          rSER.Ident := nIDENT;
          select count(*)
            into iCNT
            from UDO_PRODCOST_TMP_SER SER
           where SER.IDENT = nIDENT
             and trim(SER.SERNUM) = trim(rnv.sernumb)
             and SER.MATRES = rnv.matres;
          if rnv.matres is not null and
             iCNT <= 0 then
            rSER.Matres    := rnv.matres;
            rSER.Sernum    := rnv.sernumb;
            rSER.Inord_Sp  := null;
            rSER.In_Quant  := rnv.quant;
            rSER.In_Sum    := rnv.summ;
            rSER.In_Nds    := rnv.summ_nds;
            rSER.In_Sumtax := rnv.summtax;
            rSER.Ininv_Sp  := rnv.rn;
            rSER.Rec_Type  := 0;
            ins_ser(rROW => rSER);
          end if;
        end loop;
      
      end loop;
    
      -- связанный приходник (документы 1С)
      for rio in (select IOS.RN,
                         IOS.FACTQUANT as QUANT,
                         IOS.FACTSUM as SUMM,
                         IOS.FACTSUMTAX as SUMMTAX,
                         IOS.FACTSUMNDS as SUMM_NDS,
                         IOS.SERNUMB,
                         (select MR.RN from FCMATRESOURCE MR where MR.NOMEN_MODIF = IOS.NOMMODIF) as MATRES
                    from INORDERSPECS IOS,
                         DOCLINKS     L
                   where L.IN_UNITCODE = 'DepartmentsOrders'
                     and L.IN_DOCUMENT = rdo.rn
                     and L.OUT_UNITCODE = 'IncomingOrders'
                     and L.OUT_DOCUMENT = IOS.PRN) loop
        rSER.Ident := nIDENT;
        select count(*)
          into iCNT
          from UDO_PRODCOST_TMP_SER SER
         where SER.IDENT = nIDENT
           and trim(SER.SERNUM) = trim(rio.sernumb)
           and SER.MATRES = rio.matres;
        if rio.matres is not null and
           iCNT <= 0 then
          rSER.Matres    := rio.matres;
          rSER.Sernum    := rio.sernumb;
          rSER.Inord_Sp  := rio.rn;
          rSER.In_Quant  := rio.quant;
          rSER.In_Sum    := rio.summ;
          rSER.In_Nds    := rio.summ_nds;
          rSER.In_Sumtax := rio.summtax;
          rSER.Ininv_Sp  := null;
          rSER.Rec_Type  := 1;
          ins_ser(rROW => rSER);
        end if;
      end loop;
    
    end loop;
  
    -- укажем количество купленного
    update UDO_PRODCOST_TMP_MTR MTR
       set MTR.BUY_QUANT =
           (select nvl(sum(SER.IN_QUANT), 0)
              from UDO_PRODCOST_TMP_SER SER
             where SER.IDENT = MTR.IDENT
               and SER.MATRES = MTR.MATRES)
     where MTR.IDENT = nIDENT;
  
  end set_buy;

  /* формирование закупки */
  procedure set_buy_project is
    rSER     UDO_PRODCOST_TMP_SER%rowtype;
    iCNT     integer;
    nFACEACC number(17);
    nIDLIST  number(17) := 154;
  begin
    -- ШПЗ заказа на производство
    begin
      select ORD.FACEACC into nFACEACC from PRODUCTORD ORD where ORD.RN = nPRODORD;
    exception
      when no_data_found then
        p_exception(0, 'Не определен ШПЗ заказа на производство.');
    end;
    -- список ШПЗ по проекту/договору
    insert into IDLIST
      (ID,
       HID)
      select nIDLIST,
             PS.FACEACC
        from PROJECTSTAGE PS
       where PS.PRN in (select PPS.PRN from PROJECTSTAGE PPS where PPS.FACEACC = nFACEACC);
    -- по заказам подразделений проекта
    for rdo in (select D.RN
                  from DEPARTMENTORD D,
                       IDLIST        IL
                 where IL.ID = nIDLIST
                   and IL.HID = D.FACEACC) loop
      -- закупка (связанный ВСО)
      for rpa in (select DS.RN        as ORDS_RN,
                         PE.QUANT,
                         PIS.NOMEN,
                         PIS.NOMMODIF,
                         PIS.PRN      as ACC_RN,
                         PIS.RN       as ACCSP_RN,
                         PIS.QUANT    as PAY_QUANT
                    from DEPARTMENTORDS   DS,
                         PAYACCINSPCLC_EX PE,
                         PAYACCINSPCLC    PC,
                         PAYACCINSPEC     PIS
                   where DS.PRN = rdo.rn
                     and PE.DEPARTMENTORDSP = DS.RN
                     and PE.PRN = PC.RN
                     and PC.PRN = PIS.RN) loop
        -- приходная накладная для ВСО
        for rnv in (select IIS.SERNUMB,
                           IIS.RN,
                           IIS.SUMM,
                           IIS.SUMMTAX,
                           IIS.SUMM_NDS,
                           IIS.QUANT,
                           (select MR.RN
                              from FCMATRESOURCE MR
                             where MR.NOMENCLATURE = IIS.NOMEN
                               and MR.NOMEN_MODIF = IIS.MODIF) as MATRES
                      from ININVOICESSPECS IIS,
                           DOCLINKS        L
                     where L.IN_UNITCODE = 'PaymentAccountsIn'
                       and L.IN_DOCUMENT = rpa.acc_rn
                       and L.OUT_UNITCODE = 'IncomingInvoices'
                       and L.OUT_DOCUMENT = IIS.PRN
                       and IIS.NOMEN = rpa.nomen
                       and IIS.MODIF = rpa.nommodif) loop
          rSER.Ident := nIDENT;
          select count(*)
            into iCNT
            from UDO_PRODCOST_TMP_SER SER
           where SER.IDENT = nIDENT
             and trim(SER.SERNUM) = trim(rnv.sernumb)
             and SER.MATRES = rnv.matres;
          if rnv.matres is not null and
             iCNT <= 0 then
            rSER.Matres    := rnv.matres;
            rSER.Sernum    := rnv.sernumb;
            rSER.Inord_Sp  := null;
            rSER.In_Quant  := rnv.quant;
            rSER.In_Sum    := rnv.summ;
            rSER.In_Nds    := rnv.summ_nds;
            rSER.In_Sumtax := rnv.summtax;
            rSER.Ininv_Sp  := rnv.rn;
            rSER.Rec_Type  := 0;
            ins_ser(rROW => rSER);
          end if;
        end loop;
      
      end loop;
    
      -- связанный приходник (документы 1С)
      for rio in (select IOS.RN,
                         IOS.FACTQUANT as QUANT,
                         IOS.FACTSUM as SUMM,
                         IOS.FACTSUMTAX as SUMMTAX,
                         IOS.FACTSUMNDS as SUMM_NDS,
                         IOS.SERNUMB,
                         (select MR.RN from FCMATRESOURCE MR where MR.NOMEN_MODIF = IOS.NOMMODIF) as MATRES
                    from INORDERSPECS IOS,
                         DOCLINKS     L
                   where L.IN_UNITCODE = 'DepartmentsOrders'
                     and L.IN_DOCUMENT = rdo.rn
                     and L.OUT_UNITCODE = 'IncomingOrders'
                     and L.OUT_DOCUMENT = IOS.PRN) loop
        rSER.Ident := nIDENT;
        select count(*)
          into iCNT
          from UDO_PRODCOST_TMP_SER SER
         where SER.IDENT = nIDENT
           and trim(SER.SERNUM) = trim(rio.sernumb)
           and SER.MATRES = rio.matres;
        if rio.matres is not null and
           iCNT <= 0 then
          rSER.Matres    := rio.matres;
          rSER.Sernum    := rio.sernumb;
          rSER.Inord_Sp  := rio.rn;
          rSER.In_Quant  := rio.quant;
          rSER.In_Sum    := rio.summ;
          rSER.In_Nds    := rio.summ_nds;
          rSER.In_Sumtax := rio.summtax;
          rSER.Ininv_Sp  := null;
          rSER.Rec_Type  := 1;
          ins_ser(rROW => rSER);
        end if;
      end loop;
    
    end loop;
  
    -- укажем количество купленного
    update UDO_PRODCOST_TMP_MTR MTR
       set MTR.BUY_QUANT =
           (select nvl(sum(SER.IN_QUANT), 0)
              from UDO_PRODCOST_TMP_SER SER
             where SER.IDENT = MTR.IDENT
               and SER.MATRES = MTR.MATRES)
     where MTR.IDENT = nIDENT;
  
  end set_buy_project;

  /* очистка таблиц */
  procedure clear_tmp is
  begin
    for rec in (select T.IDENT from UDO_PRODCOST_TMP T where T.AUTHID = utilizer) loop
      delete from UDO_PRODCOST_TMP_MTR where IDENT = rec.ident;
      delete from UDO_PRODCOST_TMP_SUB where IDENT = rec.ident;
      delete from UDO_PRODCOST_TMP_INCL where IDENT = rec.ident;
      delete from UDO_PRODCOST_TMP_SER where IDENT = rec.ident;
    end loop;
    delete from UDO_PRODCOST_TMP T where T.AUTHID = utilizer;
  end clear_tmp;

  /* получить параметры приходной серии по строке расходной накладной */
  procedure get_sernumb_by_trdepsp
  (
    nRN     in number,
    rSERNUM in out UDO_PRODCOST_TMP_SER%rowtype
  ) is
    iCNT integer;
  begin
    -- проверим на загрузку из 1С
    begin
      select trim(DV.STR_VALUE)
        into rSERNUM.Sernum
        from DOCS_PROPS_VALS DV
       where DV.UNIT_RN = nRN
         and DV.DOCS_PROP_RN = 13459633;
    exception
      when no_data_found then
        rSERNUM.Sernum := to_char(null);
    end;
    --
    if rtrim(rSERNUM.Sernum) is null then
      -- это не 1С - ищем по товарному запасу
      begin
        select trim(GP.SERNUMB)
          into rSERNUM.Sernum
          from TRANSINVDEPTSPECS TDS,
               GOODSPARTIES      GP
         where TDS.RN = nRN
           and TDS.GOODSPARTY = GP.RN;
      exception
        when no_data_found then
          rSERNUM.Sernum := to_char(null);
      end;
    end if;
    -- нет серийного номера - выход
    if rtrim(rSERNUM.Sernum) is null then
      return;
    end if;
  
    -- иначе ищем приходный документ
    select count(*)
      into iCNT
      from INORDERSPECS IOS
     where IOS.NOMMODIF = rSERNUM.Modif
       and IOS.SERNUMB = rSERNUM.Sernum;
    --
    if iCNT = 0 then
      select count(*)
        into iCNT
        from INORDERSPECS IOS
       where IOS.NOMMODIF = rSERNUM.Modif
         and trim(IOS.SERNUMB) = trim(rSERNUM.Sernum);
    end if;
    --
    if iCNT = 0 then
      -- нет приходника с таким серийным номером
      return;
    
    elsif iCNT = 1 then
      -- один приход - там и цены
      begin
        select IOS.RN,
               IOS.FACTQUANT,
               IOS.FACTSUM,
               IOS.FACTSUMTAX,
               IOS.FACTSUMNDS
          into rSERNUM.Inord_Sp,
               rSERNUM.In_Quant,
               rSERNUM.In_Sum,
               rSERNUM.In_Sumtax,
               rSERNUM.In_Nds
          from INORDERSPECS IOS
         where IOS.NOMMODIF = rSERNUM.Modif
           and IOS.SERNUMB = rSERNUM.Sernum;
      exception
        when no_data_found then
          begin
            select IOS.RN,
                   IOS.FACTQUANT,
                   IOS.FACTSUM,
                   IOS.FACTSUMTAX,
                   IOS.FACTSUMNDS
              into rSERNUM.Inord_Sp,
                   rSERNUM.In_Quant,
                   rSERNUM.In_Sum,
                   rSERNUM.In_Sumtax,
                   rSERNUM.In_Nds
              from INORDERSPECS IOS
             where IOS.NOMMODIF = rSERNUM.Modif
               and trim(IOS.SERNUMB) = trim(rSERNUM.Sernum);
          exception
            when no_data_found then
              return;
          end;
      end;
    
    else
      null;
    end if;
  
  end get_sernumb_by_trdepsp;

  /* формирование списка замен и фактической выдачи других серий (смотрим по КВ) */
  procedure set_sub is
    rSER UDO_PRODCOST_TMP_SER%rowtype;
    iCNT integer;
  begin
    -- план выпуска
    for rpl in (select PSP.RN
                  from FCPRODPLANSP PSP,
                       DOCLINKS     L,
                       PRODUCTORDS  PS
                 where PS.PRN = nPRODORD
                   and L.IN_UNITCODE = 'ProductionOrdersSpecs'
                   and L.IN_DOCUMENT = PS.RN
                   and L.OUT_UNITCODE = 'CostProductPlansSpecs'
                   and L.OUT_DOCUMENT = PSP.RN) loop
      -- производственная программа и сразу МЛ - нет МЛ , значит нет КВ
      for rpp in (select LST.RN
                    from FCPRODPLANSP PSP,
                         DOCLINKS     L,
                         FCROUTLST    LST
                   where PSP.PRN_NODE = rpl.rn
                     and L.IN_UNITCODE = 'CostProductPlansSpecs'
                     and L.IN_DOCUMENT = PSP.RN
                     and L.OUT_UNITCODE = 'CostRouteLists'
                     and L.OUT_DOCUMENT = LST.RN) loop
        -- для МЛ смотрим связанные КВ и расходные накладные
        for rdlv in (select TDS.RN,
                            TDS.NOMMODIF,
                            (select distinct SP.MATRES
                               from FCDELIVSHSP     SP,
                                    FCDELIVSHSPCMPL SC
                              where SP.PRN = SH.RN
                                and SC.PRN = SP.RN
                                and SC.MATRES = MR.RN
                                and rownum < 2) as MATRES
                       from FCDELIVSH         SH,
                            DOCLINKS          LS,
                            TRANSINVDEPTSPECS TDS,
                            DOCLINKS          LT,
                            FCMATRESOURCE     MR
                      where LS.IN_UNITCODE = 'CostRouteLists'
                        and LS.IN_DOCUMENT = rpp.rn
                        and LS.OUT_UNITCODE = 'CostDeliverySheets'
                        and LS.OUT_DOCUMENT = SH.RN
                        and LT.IN_UNITCODE = 'CostDeliverySheets'
                        and LT.IN_DOCUMENT = SH.RN
                        and LT.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
                        and LT.OUT_DOCUMENT = TDS.PRN
                        and TDS.NOMMODIF = MR.NOMEN_MODIF(+)) loop
          rSER          := null;
          rSER.Ident    := nIDENT;
          rSER.Rec_Type := 2;
          rSER.Matres   := rdlv.matres;
          rSER.Modif    := rdlv.nommodif;
          get_sernumb_by_trdepsp(nRN => rdlv.rn, rSERNUM => rSER);
          -- проверка наличия серии
          if rtrim(rSER.Sernum) is not null then
            select count(*)
              into iCNT
              from UDO_PRODCOST_TMP_SER SR
             where SR.IDENT = nIDENT
               and trim(SR.SERNUM) = trim(rSER.Sernum)
               and SR.MATRES = rdlv.matres;
            if iCNT <= 0 then
              ins_ser(rROW => rSER);
            end if;
          else
            -- нет серии - пока ничего не делаем
            null;
          end if;
        
        end loop;
      
      end loop;
    
    end loop;
  
    -- укажем количество купленного
    update UDO_PRODCOST_TMP_MTR MTR
       set MTR.BUY_QUANT =
           (select nvl(sum(SER.IN_QUANT), 0)
              from UDO_PRODCOST_TMP_SER SER
             where SER.IDENT = MTR.IDENT
               and SER.MATRES = MTR.MATRES)
     where MTR.IDENT = nIDENT;
  
  end set_sub;

  /* укажем партии к учету себестоимости */
  procedure set_cost is
    -- указать покупку исходя из количества
    procedure set_cost_quant
    (
      nMATRES in number,
      nQUANT  in number
    ) is
      nQUANT_REST number(17, 3) := nQUANT;
    begin
      -- установим включение в себестоимость - от большего к меньшему
      for rcs in (select SER.*
                    from UDO_PRODCOST_TMP_SER SER
                   where SER.IDENT = nIDENT
                     and SER.MATRES = nMATRES
                     and nvl(SER.IN_QUANT, 0) > 0
                   order by SER.IN_QUANT desc) loop
        if rcs.in_quant >= nQUANT_REST then
          -- закупка больше потребности
          update UDO_PRODCOST_TMP_SER SER
             set SER.REC_TYPE = SER.REC_TYPE + 10
           where SER.IDENT = nIDENT
             and SER.MATRES = nMATRES
             and SER.SERNUM = rcs.sernum
             and (SER.INORD_SP = rcs.inord_sp or (rcs.inord_sp is null and SER.INORD_SP is null))
             and (SER.ININV_SP = rcs.ininv_sp or (rcs.ininv_sp is null and SER.ININV_SP is null))
             and SER.REC_TYPE = rcs.rec_type;
          -- возврат
          return;
        else
          -- закупка меньше потребности
          nQUANT_REST := nQUANT_REST - rcs.in_quant;
          update UDO_PRODCOST_TMP_SER SER
             set SER.REC_TYPE = SER.REC_TYPE + 10
           where SER.IDENT = nIDENT
             and SER.MATRES = nMATRES
             and SER.SERNUM = rcs.sernum
             and (SER.INORD_SP = rcs.inord_sp or (rcs.inord_sp is null and SER.INORD_SP is null))
             and (SER.ININV_SP = rcs.ininv_sp or (rcs.ininv_sp is null and SER.ININV_SP is null))
             and SER.REC_TYPE = rcs.rec_type;
        end if;
      end loop;
    end set_cost_quant;
  
  begin
    for cst in (select MTR.*,
                       (select count(*)
                          from UDO_PRODCOST_TMP_SER SER
                         where SER.IDENT = nIDENT
                           and SER.MATRES = MTR.MATRES) IN_CNT
                  from UDO_PRODCOST_TMP_MTR MTR,
                       FCMATRESOURCE        MR
                 where MTR.IDENT = nIDENT
                   and MTR.PROD_SIGN = 1
                   and MTR.MATRES = MR.RN
                   and MTR.BUY_QUANT > 0) loop
      if cst.in_cnt = 1 then
        update UDO_PRODCOST_TMP_SER SER
           set SER.REC_TYPE = SER.REC_TYPE + 10
         where SER.IDENT = nIDENT
           and SER.MATRES = cst.matres;
      else
        -- выборка по количеству
        set_cost_quant(nMATRES => cst.matres, nQUANT => cst.quant);
      end if;
    end loop;
  end set_cost;

  /* установим параметры партии для себестоимости */
  procedure set_cost_param is
    rSER UDO_PRODCOST_TMP_SER%rowtype;
  begin
    for rcst in (select *
                   from UDO_PRODCOST_TMP_SER SER
                  where SER.IDENT = nIDENT
                    and SER.REC_TYPE > 9) loop
      rSER := rcst;
      if rSER.Ininv_Sp is not null then
        -- по данным приходной накладной
        begin
          select least(II.DOC_DATE, II.EXT_DATE),
                 DT.DOCCODE || ' №' || II.EXT_NUMB,
                 II.AGENT
            into rSER.Trdoc_Date,
                 rSER.Trdoc_Numb,
                 rSER.Agn_Rn
            from ININVOICES      II,
                 ININVOICESSPECS IIS,
                 DOCTYPES        DT
           where IIS.RN = rSER.Ininv_Sp
             and IIS.PRN = II.RN
             and II.DOCTYPE = DT.RN;
        exception
          when no_data_found then
            null;
        end;
        update UDO_PRODCOST_TMP_SER SR
           set SR.AGN_RN     = rSER.Agn_Rn,
               SR.TRDOC_NUMB = rSER.Trdoc_Numb,
               SR.TRDOC_DATE = rSER.Trdoc_Date
         where SR.IDENT = nIDENT
           and SR.Ininv_Sp = rcst.ininv_sp;
      
      elsif rSER.Inord_Sp is not null then
        -- по данным приходного ордера
        begin
          select nvl((select DT.DOCCODE || ' №' || II.EXT_NUMB
                       from ININVOICES II,
                            DOCLINKS   L,
                            DOCTYPES   DT
                      where L.IN_UNITCODE = 'IncomingInvoices'
                        and L.IN_DOCUMENT = II.RN
                        and L.OUT_UNITCODE = 'IncomingOrders'
                        and L.OUT_DOCUMENT = IO.RN
                        and II.DOCTYPE = DT.RN),
                     IO.INVDOCNUMB),
                 IO.INVDOCDATE,
                 IO.CONTRAGENT
            into rSER.Trdoc_Numb,
                 rSER.Trdoc_Date,
                 rSER.Agn_Rn
            from INORDERSPECS IOS,
                 INORDERS     IO
           where IOS.RN = rSER.Inord_Sp
             and IOS.PRN = IO.RN;
        exception
          when no_data_found then
            null;
        end;
        update UDO_PRODCOST_TMP_SER SR
           set SR.AGN_RN     = rSER.Agn_Rn,
               SR.TRDOC_NUMB = rSER.Trdoc_Numb,
               SR.TRDOC_DATE = rSER.Trdoc_Date
         where SR.IDENT = nIDENT
           and SR.Inord_Sp = rcst.inord_sp;
      
      else
        null;
      end if;
    end loop;
  end set_cost_param;

begin
  if nPRODORD is null then
    return;
  end if;
  --
  clear_tmp;
  --
  rTMP.Ident    := nIDENT;
  rTMP.Document := nPRODORD;
  rTMP.Unitcode := 'ProductionOrdersSpecs';
  rTMP.Authid   := utilizer;
  rTMP.Op_Date  := sysdate;
  ins_tmp(rROW => rTMP);
  -- потребность
  nEXP := f_doclinks_link_out_doc(sIN_UNITCODE  => 'ProductionOrders',
                                  nIN_DOCUMENT  => nPRODORD,
                                  sOUT_UNITCODE => 'CostProductExpenseActs');
  if nEXP is null then
    -- нет потребности
    p_exception(0,
                'Для заказа на производство не сформирована потребность в комплектующих.');
  end if;
  -- формируем таблицу потребности
  for rct in (select ACM.MATRES,
                     MR.NOMENCLATURE,
                     MR.NOMEN_MODIF,
                     ACM.PROD_SIGN,
                     sum(ACM.QUANT) as QUANT
                from FCPREXPACTMR  ACM,
                     FCMATRESOURCE MR
               where ACM.PRN = nEXP
                 and ACM.MATRES = MR.RN
               group by ACM.MATRES,
                        MR.NOMENCLATURE,
                        MR.NOMEN_MODIF,
                        ACM.PROD_SIGN) loop
    -- сохранение только для больше нуля
    if rct.quant > 0 then
      rMTR.Ident     := nIDENT;
      rMTR.Prn       := rTMP.Document;
      rMTR.Matres    := rct.matres;
      rMTR.Nomen     := rct.nomenclature;
      rMTR.Modif     := rct.nomen_modif;
      rMTR.Quant     := rct.quant;
      rMTR.Prod_Sign := rct.prod_sign;
      ins_mtr(rROW => rMTR);
      -- входимость
      for rncl in (select ACM.QUANT,
                          ACM.PROD_MATRES,
                          MR.NOMENCLATURE,
                          MR.NOMEN_MODIF
                     from FCPREXPACTMR  ACM,
                          FCMATRESOURCE MR
                    where ACM.PRN = nEXP
                      and ACM.MATRES = rct.matres
                      and ACM.PROD_MATRES = MR.RN) loop
        rINCL.Ident      := nIDENT;
        rINCL.Matres     := rMTR.Matres;
        rINCL.Matres_Art := rncl.prod_matres;
        rINCL.Nomen_Art  := rncl.nomenclature;
        rINCL.Modif_Art  := rncl.nomen_modif;
        rINCL.Quant      := rncl.quant;
        ins_incl(rROW => rINCL);
      end loop;
    end if;
  
  end loop;

  -- теперь по закупкам согласно потребности (покупная)
  set_buy;
  -- при необходимости проверим закупку по всему проекту
  if nvl(nSIGN_PROJECT, 0) = 1 then
    set_buy_project;
  end if;
  -- закупка по выдаче
  set_sub;
  -- укажем партию к себестоимости
  set_cost;
  -- параметры партии в себестоимости
  set_cost_param;

end;
/

