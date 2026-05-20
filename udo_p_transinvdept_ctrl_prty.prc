create or replace procedure UDO_P_TRANSINVDEPT_CTRL_PRTY
(
  NCOMPANY                    in number,   -- Рег. номер организации
  NRN                         in number,   -- Рег. номер РН
  sACTION                     in varchar2, -- код действия
  sMODE                       in varchar2  -- код режима (BEFORE - до действия, AFTER - после действия)
)
is
/* Процедура разработана для установки/очистки ноувого кода партии при перемещении ТМЦ через РНОПодр 
  (срабатывает только для вида отгрузки указанног в константе "ВИД_ОТГР_НОВАЯ_ПАРТИЯ")*/
  
  RTID                        TRANSINVDEPT%rowtype; -- Запись РН 
  nSHPVW                      PKG_STD.tREF;         -- Рег. номер вида отгрузки 
  nSUBDIV                     PKG_STD.tREF;         -- Рег. номер подразделения
  sPARTY_NEW                  incomdoc.code%type;   -- Код партии    
begin
  
  /* Считывание РН */
  RTID := udo_pkg_get.ROW_TRANSINVDEPT(NRN => NRN, NSMART => 0);
  
  /* Если не указан склад прхода, то выходим изпроцедуры */
  if RTID.In_Store is null then 
    return;
  end if;
      
  /* Вид отгрузки при использовании которого выполняем процедуру */
  find_dicshpvw_code(nFLAG_SMART => 0,
                     nCOMPANY    => NCOMPANY,
                     sCODE       => udo_f_get_const_val_str(nFLAG_SMART => 0,
                                                            nCOMPANY    => nCOMPANY,
                                                            sCONST_NAME => 'ВИД_ОТГР_НОВАЯ_ПАРТИЯ'),
                     nRN         => nSHPVW);
  
  /* Если не совпадает вид отгрузки, то выходим изпроцедуры */
  if nSHPVW != RTID.SHEEPVIEW then 
    return;
  end if;
  
  /* Отработка */
  if sACTION in ('TRANSINVDEPT_ASPLAN','TRANSINVDEPT_PROCESS') and sMODE = 'BEFORE' then    
    
    if RTID.IN_PARTY_CODE is null then 
      /*Код новой партии */
      p_incomdoc_getnextnumb(nCOMPANY => nCOMPANY, sNUMBER => sPARTY_NEW);
      
      /* подраздедение партии */
      find_subdivs_code(nFLAG_SMART => 0,
                        nCOMPANY    => nCOMPANY,
                        sCODE       => udo_f_get_const_val_str(nFLAG_SMART => 0,nCOMPANY => nCOMPANY,sCONST_NAME => 'ПОДР_УМОЛ_НОВАЯ_ПАРТИЯ'),
                        nRN         => nSUBDIV);
      
      /* Установка нового кода партии */
      update TRANSINVDEPT t
         set t.in_party_code = sPARTY_NEW,
             t.subdiv        = case when t.subdiv is null then nSUBDIV else t.subdiv end,
             t.in_party      = null
       where t.rn = RTID.RN;
       
      if (sql%notfound) then
        PKG_MSG.RECORD_NOT_FOUND(RTID.RN, 'TRANSINVDEPT');
      end if;
    end if;
  
  /* Отработка */
  elsif sACTION in ('TRANSINVDEPT_ASPLAN','TRANSINVDEPT_PROCESS') and sMODE = 'AFTER' then
    -- контроль сертификатов - по приходу
    for rec in(select CO.CERT_NUMB,
                      CO.SIGN_OUT,
                      GS.PRN
                 from UDO_PROD_CULL_OUT CO, 
                      DOCLINKS          L, 
                      TRANSINVDEPTSPECS TDS,
                      STOREOPERJOURN    SOJ,
                      DOCLINKS          LS,
                      GOODSSUPPLY       GS
                where TDS.PRN = RTID.RN
                  and L.OUT_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                  and L.OUT_DOCUMENT = TDS.RN
                  and L.IN_UNITCODE = 'UdoProdCullSpOut'
                  and L.IN_DOCUMENT = CO.RN
                  and LS.IN_DOCUMENT = TDS.RN
                  and LS.IN_UNITCODE = L.OUT_UNITCODE
                  and LS.OUT_DOCUMENT = SOJ.RN
                  and LS.OUT_UNITCODE = 'StoreOpersJournal'
                  and SOJ.OPER_TYPE = 1
                  and SOJ.GOODSSUPPLY = GS.RN
                  and (CO.CERT_NUMB is not null or CO.SIGN_OUT = 3)) loop
        -- спец.проверка 14/12/2023 Марков МВ.
        if rec.sign_out = 3 then
          if rec.cert_numb is null then
            rec.cert_numb := 'Спецпроверка пройдена';
          else
            rec.cert_numb := substr(rec.cert_numb||'. Спецпроверка пройдена', 1, 1000);
          end if;
        end if;
        -- укажем сертификат в товарном запасе
        update GOODSPARTIES GP set GP.CERTIFICATE = rec.cert_numb where GP.RN = rec.prn;
    end loop;

  /* Снятие отработки */
  elsif sACTION = 'TRANSINVDEPT_CANCEL' and sMODE = 'AFTER' then   
    
    /* Очистка партии */
    update TRANSINVDEPT t
       set t.in_party_code = null,
           -- 14/06/2023 Марков МВ. t.subdiv        = null,
           t.in_party      = null
     where t.rn = RTID.RN;
     
    if (sql%notfound) then
      PKG_MSG.RECORD_NOT_FOUND(RTID.RN, 'TRANSINVDEPT');
    end if;
  end if;
  
end;
/
