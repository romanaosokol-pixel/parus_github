create or replace procedure UDO_P_TRANSINVDEPTSP_FILL_RSRV
(
  nTRANSINVDEPTSP             in number, -- Рег. номер строки РНОПодр
  nRSRV                       in number  -- Рег. номер журнала резервирования
)
/*
  Процедура подбора мест хранения для спецификации расходной накладной в подраздления по данным резерва 
  
  Используется при формировании РНОПодр из комплектовочной ведомости 
*/ 
is
  rec                         TRANSINVDEPTSPECS%rowtype; -- Запись строки РНОПодр
  mrec                        TRANSINVDEPT%rowtype;      -- Запись РНОПодр
  rRSRV                       RESJOURNAL%rowtype;        -- Запись журнала резервирования
  nSTRPLRESJRNL               pkg_std.tREF;              -- Рег. номер журнала резервирования по МХ
  nQNT_REST                   pkg_std.tQUANT;            -- Остаток кол-ва к распределению по МХ
  nQNT_STPL                   pkg_std.tQUANT;            -- Кол-во для распределения по МХ
  nSTPLGOODSSUPPLY_REST       pkg_std.tQUANT;            -- Кол-во доступное для распределения по МХ
begin
  /* Считывание записи строки РНОПодр*/
  rec := udo_pkg_get.ROW_TRANSINVDEPTSPECS(NRN => nTRANSINVDEPTSP, NSMART => 0);
  
  /* Считывание записи РНОПодр*/
  mrec := udo_pkg_get.ROW_TRANSINVDEPT(NRN => rec.prn, NSMART => 0);
  
  /* Считывание записи журнала резервирования*/
  rRSRV := udo_pkg_get.ROW_RESJOURNAL(NRN => nRSRV, NSMART => 0);
  
  /* Инициализация кол-ва к распределению по МХ*/
  nQNT_REST := rRSRV.Quant;
  
  /* Цикл по товарным запасам по МХ*/
  for cur in (select t.* 
                from STPLGOODSSUPPLY t,
                     goodssupply gs
               where t.goodssupply = rRSRV.Supply
                 and t.goodssupply = gs.rn 
                 and gs.store      = mrec.store)
  loop  
    /* кол-во доступное для распределения */
    begin
      select H.MIN_FA_REST
        into nSTPLGOODSSUPPLY_REST
        from STPLGSSUPPLYHIST H   
       where H.PRN = cur.rn
         and h.DATE_FROM <= mrec.docdate
         and (h.DATE_TO >= mrec.docdate or h.DATE_TO is null);
    exception when no_data_found then 
       nSTPLGOODSSUPPLY_REST := 0;
    end;
    
    if nSTPLGOODSSUPPLY_REST > 0 then 
      /* Кол-во для распределения по МХ */
      if nQNT_REST >= nSTPLGOODSSUPPLY_REST then 
        nQNT_STPL :=  nSTPLGOODSSUPPLY_REST; 
      else 
        nQNT_STPL := nQNT_REST;
      end if;
      
      /* Остаток кол-ва к распределению по МХ */  
      nQNT_REST := nQNT_REST - nQNT_STPL;
      
      /* Добавление записи */
      P_STRPLRESJRNL_BASE_INSERT(nCOMPANY       => mrec.COMPANY, -- организация.
                                 sAUTHID         => UTILIZER , -- пользователь
                                 sMASTERUNITCODE => 'GoodsTransInvoicesToDepts', -- код master-раздела
                                 sSLAVEUNITCODE  => 'GoodsTransInvoicesToDeptsSpecs', -- код slave-раздела
                                 nMASTERRN       => mrec.RN, -- регистрационный номер master-записи
                                 nSLAVERN        => rec.RN, -- регистрационный номер slave-записи
                                 nRACK           => null, -- не используется (по возможности убрать)
                                 nCELL           => cur.cell, -- место хранения (резервуар)
                                 nGOODSSUPPLY    => cur.GOODSSUPPLY, -- товарный запас
                                 nRES_TYPE       => 1, -- тип резервирования (0 - приход, 1 - расход)
                                 nNOMMODIF       => rec.Nommodif, -- модификация.
                                 nNOMNMODIFPACK  => rec.nomnmodifpack, -- упаковка модификации
                                 nARTICLE        => rec.article, -- изделие на складе
                                 nGOODSUNIT      => null, -- грузовая единица
                                 nDOCTYPE        => mrec.DOCTYPE, -- тип документа
                                 dDOCDATE        => mrec.DOCDATE, -- дата документа
                                 sDOCNUMB        => mrec.NUMB, -- номер документа
                                 sDOCPREF        => mrec.PREF, -- префикс номера документа
                                 dRESERVING_DATE => mrec.DOCDATE, -- дата и время резервирования.
                                 dFREE_DATE      => null, -- дата и время снятия резервирования.
                                 nQUANT          => nQNT_STPL, -- количество в основной ЕИ
                                 nQUANTALT       => 0, -- количество в дополнительной ЕИ
                                 nQUANTPACK      => 0, -- не используется (рассчитывается из ОЕИ)
                                 nCHECK_PARTY    => 0, -- признак запрета проверки соответствия партий в документе и на МХ (0 - по настройке, 1 - запрещено)
                                 nRN             => nSTRPLRESJRNL);
    end if;
    
    /* Выходим если все распределили */
    exit when nQNT_REST = 0;
  end loop cur;     
end ;
/

