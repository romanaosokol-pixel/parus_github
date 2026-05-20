create or replace procedure UDO_P_TRANSINVDEPT_CERTIF(nRN in number) as
  /*
    26/09/2023 Марков МВ.
    Расходные накладные на отпуск в подразделения
    Неименованный блок (автоматический)
    После отработки
    
    Только для расходных накладных созданных из "Сертификация/Входной контроль", режим проверки "Сертификация"
    Указание номера сертификата в новой партии ТМЦ.
  */
  nPRODCULL      PKG_STD.tREF;
  nIN_PARTY      PKG_STD.tREF;
  sIN_PARTY_CODE INCOMDOC.CODE%type;

begin
  -- проверим связь с Сертификацией
  begin
    select PC.RN,
           TD.IN_PARTY,
           TD.IN_PARTY_CODE
      into nPRODCULL,
           nIN_PARTY,
           sIN_PARTY_CODE
      from TRANSINVDEPT  TD,
           DOCLINKS      L,
           UDO_PROD_CULL PC
     where TD.RN = nRN
       and L.OUT_DOCUMENT = TD.RN
       and L.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
       and L.IN_DOCUMENT = PC.RN
       and L.IN_UNITCODE = 'UdoProdCull'
       and PC.MODE_CHECK = 0;
  exception
    when no_data_found then
      -- накладная не связана с Сертификацией
      return;
  end;

  -- по каждой строке укажем сертификат
  for rec in (select TDS.RN,
                     PCO.CERT_NUMB,
                     TDS.GOODSPARTY as OUT_PARTY,
                     PCO.SIGN_OUT, -- признак сертификации (2 - Сертификация распространяется на партию)
                     (select GP.SERNUMB from GOODSPARTIES GP where GP.RN = TDS.GOODSPARTY) as SERNUMB
                from TRANSINVDEPTSPECS TDS,
                     DOCLINKS          L,
                     UDO_PROD_CULL_OUT PCO
               where TDS.PRN = nRN
                 and L.OUT_DOCUMENT = TDS.RN
                 and L.OUT_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                 and L.IN_DOCUMENT = PCO.RN
                 and L.IN_UNITCODE = 'UdoProdCullSpOut') loop
    -- только при наличии сертификата
    /* KHOK. 06/11/2024 Ждем какие еще слова кроме НЕТ напишут в поле номера сертификации, означающие, что сертификации не было */
    if rtrim(rec.cert_numb) is not null and upper(trim(rec.cert_numb)) != 'НЕТ' then 
      -- укажем сертификат в товарном запасе по приходной операции
      -- должна быть на отдельной партии
      for rsj in (select GP.RN as IN_PARTY
                    from STOREOPERJOURN SOJ,
                         DOCLINKS       LS,
                         GOODSSUPPLY    GS,
                         GOODSPARTIES   GP
                   where LS.IN_DOCUMENT = rec.rn
                     and LS.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                     and LS.OUT_DOCUMENT = SOJ.RN
                     and LS.OUT_UNITCODE = 'StoreOpersJournal'
                     and SOJ.OPER_TYPE = 1
                     and SOJ.GOODSSUPPLY = GS.RN
                     and GS.PRN = GP.RN) loop
        -- обязательная смена партии!!!!
        if rsj.in_party = rec.out_party then
          p_exception(0, 'Для накладной возврата ТМЦ после сертификации должна быть изменена партия ТМЦ.'||chr(10)||
                         'Серия: %s', rec.sernumb);
        end if;
        -- укажем сертификат
        if rec.sign_out = 2 then
          -- 14/01/2025 Марков МВ. Сертификат на всю партию (серию ТМЦ)
          update GOODSPARTIES GP
             set GP.CERTIFICATE = case when rtrim(GP.SERNUMB) is null then rec.cert_numb
                                       else substr(rec.cert_numb||';'||rtrim(GP.SERNUMB), 1, 1000)
                                  end
           where GP.SERNUMB = rec.sernumb;
          
        else
          -- только на партию прихода после сертификации
          update GOODSPARTIES GP set GP.CERTIFICATE = rec.cert_numb where GP.RN = rsj.in_party;
        end if;
        
      end loop;
    end if;
  
  end loop;
  
end;
/
