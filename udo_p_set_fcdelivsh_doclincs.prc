create or replace procedure UDO_P_SET_FCDELIVSH_DOCLINCS(nOld_KV in number, nNew_KV in number, nRash_RN in number) is

  --  nRash_RN number := 18857791;
  --  nOld_KV  number := 22605698;
  --  nNew_KV  number := 22362478;
  nTMP NUMBER;
begin
-- nRash_RN := NRN;
  


begin
    /* создание связи документов (без даты и статуса) */
 PKG_DOCLINKS.LINK
  (
    nFLAG_SMART       => 0,        -- признак генерации исключения при дублировании связи (0 - да, 1 - нет)
    nCOMPANY          => 90521,        -- регистрационный номер записи организации
    sIN_UNITCODE      => 'CostDeliverySheets',      -- код раздела входного документа
    nIN_DOCUMENT      => nNew_KV,        -- регистрационный номер записи входного документа

    sOUT_UNITCODE     => 'GoodsTransInvoicesToDepts',      -- код раздела выходного документа
    nOUT_DOCUMENT     => nRash_RN        -- регистрационный номер записи выходного документа

  );
  exception when others then
    null;
  end;
  
    for rr in (
      select dl.*
      from DOCLINKS dl, FCDELIVSHSP pp
      where dl.in_document = pp.rn
       and pp.prn = nOld_KV
     ) loop
     
         /* удаление связи документов */
        PKG_DOCLINKS.REMOVE
        (
          sIN_UNITCODE      => rr.in_unitcode,      -- код раздела входного документа
          nIN_DOCUMENT      => rr.in_document,        -- регистрационный номер записи входного документа
          sOUT_UNITCODE     => rr.out_unitcode,      -- код раздела выходного документа
          nOUT_DOCUMENT     => rr.out_document         -- регистрационный номер записи выходного документа
        );
    
     end loop;   
     
     
  for cc in (
    select ts.rn as ts_rn
          ,kv.rn as kv_rn
          ,kv.matres
          ,ts.quant
    from TRANSINVDEPTSPECS ts
        ,FCDELIVSHSP       kv
        ,FCMATRESOURCE     mr 
    where ts.prn = nRash_RN
      and kv.prn = nNew_KV
      and ts.nommodif = mr.nomen_modif
      and mr.rn = kv.matres 
  union
    select ts.rn as ts_rn
          ,kv.rn as kv_rn
          ,kv.matres
          ,ts.quant
    from TRANSINVDEPTSPECS ts
        ,FCDELIVSHSP       kv
        ,FCMATRESOURCE     mr
        ,UDO_FCDELIVSHSUB  fc
    where ts.prn = nRash_RN
      and kv.prn = nNew_KV
      and fc.prn = kv.rn
      and ts.nommodif = mr.nomen_modif
      and mr.rn = fc.matres
  ) loop
    begin
       PKG_DOCLINKS.LINK
        (
          nFLAG_SMART       => 0,        -- признак генерации исключения при дублировании связи (0 - да, 1 - нет)
          nCOMPANY          => 90521,        -- регистрационный номер записи организации
          sIN_UNITCODE      => 'CostDeliverySheetsSpec',      -- код раздела входного документа
          nIN_DOCUMENT      => cc.kv_rn,        -- регистрационный номер записи входного документа

          sOUT_UNITCODE     => 'GoodsTransInvoicesToDepts',      -- код раздела выходного документа
          nOUT_DOCUMENT     => nRash_RN        -- регистрационный номер записи выходного документа

        );
     exception when others then
       null;
     end;   
    begin
       PKG_DOCLINKS.LINK
        (
          nFLAG_SMART       => 0,        -- признак генерации исключения при дублировании связи (0 - да, 1 - нет)
          nCOMPANY          => 90521,        -- регистрационный номер записи организации
          sIN_UNITCODE      => 'CostDeliverySheetsSpec',      -- код раздела входного документа
          nIN_DOCUMENT      => cc.kv_rn,        -- регистрационный номер записи входного документа

          sOUT_UNITCODE     => 'GoodsTransInvoicesToDeptsSpecs',      -- код раздела выходного документа
          nOUT_DOCUMENT     => cc.ts_rn        -- регистрационный номер записи выходного документа

        );
     exception when others then
       null;
     end;   
  end loop;
  /*
    for sp in (
      select FCOLD.*
            ,fsp.rn as nPRN
      from FCDELIVSHSP     fsp
          ,FCDELIVSHSP     fsold
          ,FCDELIVSHSPCMPL fcold
     where fsp.prn = nNew_KV
       and fsp.matres = fsold.matres
       and fcold.prn = fsold.rn
       and fsold.prn = nOld_KV
       and fsp.RN = 22334795

    union

      select FCOLD.*
            ,fsp.rn as nPRN
      from FCDELIVSHSP     fsp
          ,FCDELIVSHSP     fsold
          ,FCDELIVSHSPCMPL fcold
          ,UDO_FCDELIVSHSUB  fz
     where fsp.prn = nNew_KV
       and fz.prn = fsp.rn
       and fz.matres = fsold.matres
       and fcold.prn = fsold.rn
       and fsold.prn = nOld_KV
       and fsp.RN = 22334795
    
    ) loop
    
    P_FCDELIVSHSPCMPL_BASE_INSERT
        (
          nCOMPANY        => sp.company,            -- Организация
          nPRN            => sp.nPRN,                 -- Родитель
          nACT            => sp.act,                -- Операция
          dACT_DATE       => sp.act_date,           -- Дата операции
          nDELIVSHSP      => sp.delivshsp,          -- Строка комплектовочной ведомости
          nCMPL           => sp.cmpl,               -- Строка комплектования
          nMATRES         => sp.matres,             -- Комплектующая факт
          nQUANT          => sp.quant,              -- Количество
          nCOEFF          => sp.coeff,              -- Коэффициент замены
          nROUTLST        => sp.routlst,            -- Маршрутный лист
          nPARTY          => sp.party,              -- Партия комплектующей
          nARTICLE        => sp.article,            -- Изделие (серийный №)
          nVALID_DOCTYPE  => sp.valid_doctype,      -- Тип документа-основания замены
          sVALID_DOCNUMB  => sp.valid_docnumb,      -- Номер документа-основания замены
          dVALID_DOCDATE  => sp.valid_docdate,      -- Дата документа-основания замены
          sNOTE           => sp.note,               -- Примечание
          nRN             => nTMP                   -- Регистрационный номер
        );
      
    end loop;
  */
  begin
   /* удаление связи документов */
   if nOld_KV is not null then
  PKG_DOCLINKS.REMOVE
  (
    sIN_UNITCODE      => 'CostDeliverySheets',      -- код раздела входного документа
    nIN_DOCUMENT      => nOld_KV,        -- регистрационный номер записи входного документа
    sOUT_UNITCODE     => 'GoodsTransInvoicesToDepts',      -- код раздела выходного документа
    nOUT_DOCUMENT     => nRash_RN         -- регистрационный номер записи выходного документа

  );
  end if;
end;

end UDO_P_SET_FCDELIVSH_DOCLINCS;
/

