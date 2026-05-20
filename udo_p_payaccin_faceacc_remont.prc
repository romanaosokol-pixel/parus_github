create or replace procedure UDO_P_PAYACCIN_FACEACC_REMONT(
  nCOMPANY        in number,   -- Организация.
  sRazdel         in varchar2, -- Раздел Парус
  nRN             in number,   -- RN обрабатываемой накладной
  sNEWFACC        in varchar2  -- Новый лицевой счет
) is
/* KHOK.  27.06.2024 (Finally)
   Замена Лицевого Счета по цепочке от Расходной накладной по ремонтам 
*/
  nNewFAcc    pkg_std.tref; 
  nOldFAcc    FACEACC.RN%TYPE := 0;
  nPRODPLANSP number;
  nDeptRN     number;
  --sTMP        varchar(1024);

begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'UDO_P_PAYACCIN_FACEACC_REMONT');

  if sRazdel not in ('GoodsTransInvoicesToDepts', 'GoodsTransInvoicesToDeptsSpecs') then
    p_exception(0,'Вызов процедуры из данного раздела не предусмотрен!');
  elsif utilizer not in ('KHOK', 'MARANICHENKO_AP', 'SUROV_RS', 'BOGDANOV_AV', 'STEPANOV_MV', 'FEDOREEV_RE') then 
    p_exception(0, 'У вас недостаточно полномочий на выполнение этой процедуры!'); 
  end if;

  if sRazdel = 'GoodsTransInvoicesToDeptsSpecs' then
    p_exception(0,'Вызов процедуры из данного раздела пока(!) не предусмотрен!');
    select t.faceacc, t.rn 
      into nOldFAcc, nDeptRN 
      from TRANSINVDEPT t,
           TRANSINVDEPTSPECS sp
     where t.company = nCOMPANY 
       and t.RN  = sp.prn
       and sp.rn = nRN;
  else
    nDeptRN := nRN;
    select t.faceacc into nOldFAcc from TRANSINVDEPT t where t.company = nCOMPANY and t.RN = nDeptRN;
  end if;
--if utilizer = 'KHOK' then p_exception(0,nDeptRN || '-' || nOldFAcc); end if;   

  /* RN нового лицевого счёта */
  find_faceacc_numb(nflag_smart  => 0
                   ,nflag_option => 0
                   ,ncompany     => nCOMPANY
                   ,snumb        => sNEWFACC
                   ,nrn          => nNewFAcc);

/*  if nNewFAcc = nOldFAcc then
    p_exception(0, 'Ошибка. Старый и новый лицевые счета совпадают.');
  elsif nOldFAcc != 83660497 then
    p_exception(0, 'Ошибка. Изменить можно только ремонтный лицевой счет 02023/1.');
  end if;*/

  --if sRazdel = 'GoodsTransInvoicesToDepts' then
    begin
      update TRANSINVDEPT p -- Расходная накладная на отпуск в подразделение
         set p.faceacc = nNewFAcc
       where p.rn = nDeptRN;
    end;
  --end if;
  
  for rec in (
    select dl.out_unitcode, dl.out_document
      from DOCLINKS dl 
     where dl.in_document = nDeptRN and dl.in_unitcode = 'GoodsTransInvoicesToDepts'
     --and dl.out_document in (142155717, 147465656, 142112421, 142112469) --142112514
     order by dl.out_unitcode, dl.out_document
  ) loop

  if rec.out_unitcode = 'StoragePlacesResJournal' then -- no faceacc
    continue;
  elsif rec.out_unitcode = 'LiabilitiesNotes'  then    -- Журнал отгрузок
    update LIABILITYNOTES li set li.faceacc = nNewFAcc where li.RN = rec.out_document; --and li.faceacc in (nOldFAcc, 83660497);
  elsif rec.out_unitcode = 'StoreOpersJournal' then    -- Журнал складских операций
    update STOREOPERJOURN jo set jo.faceacc = nNewFAcc where jo.RN = rec.out_document; --and jo.faceacc in (nOldFAcc, 83660497);
  elsif rec.out_unitcode = 'ProductionOrders' then     -- Заказ на производство
--p_exception(0, rec.out_unitcode || ' - ' || rec.out_document);  
      update PRODUCTORD po set po.faceacc = nNewFAcc where po.RN = rec.out_document; --and po.faceacc in (nOldFAcc, 83660497);

      for act in ( -- Планы и отчеты производства изделий (Спецификация)
        select dl.out_unitcode, dl.out_document
          from PRODUCTORDS ords, DOCLINKS dl 
         where ords.prn = rec.out_document
           and dl.in_document = ords.rn and dl.out_unitcode = 'CostProductPlansSpecs'
      ) loop
        update FCPRODPLANSP fcp set fcp.PROD_ORDER = nNewFAcc where fcp.RN = act.out_document; --and fcp.PROD_ORDER in (nOldFAcc, 83660497);
        update FCPRODPLANSP fcp set fcp.PROD_ORDER = nNewFAcc where fcp.PRN_NODE = act.out_document; --and fcp.PROD_ORDER in (nOldFAcc, 83660497);
      end loop;

      for ord in (
        select dl.out_unitcode, dl.out_document
          from DOCLINKS dl 
         where dl.in_document = rec.out_document and dl.in_unitcode = rec.out_unitcode
      ) loop
        if ord.out_unitcode = 'CostProductExpenseActs' then -- Потребности и акты расхода изделий
          begin
          EXECUTE IMMEDIATE 'ALTER TRIGGER T_FCPREXPACT_BUPDATE DISABLE';
          update FCPREXPACT jo set jo.PROD_ORDER = nNewFAcc where jo.RN = ord.out_document; --and jo.PROD_ORDER in (nOldFAcc, 83660497);
          EXECUTE IMMEDIATE 'ALTER TRIGGER T_FCPREXPACT_BUPDATE ENABLE';
          end;

          for dep in ( -- Заказы подразделений
            select dl.out_unitcode, dl.out_document
              from DOCLINKS dl 
             where dl.in_document = ord.out_document and dl.out_unitcode = 'DepartmentsOrders'
          ) loop
            update DEPARTMENTORD jo set jo.faceacc = nNewFAcc where jo.RN = dep.out_document; --and jo.faceacc in (nOldFAcc, 83660497);
          end loop;

        elsif ord.out_unitcode = 'CostProductPlans' then -- Планы и отчеты производства изделий
          continue;
          /*update FCPRODPLAN jo set jo.PROD_ORDER = nNewFAcc where jo.RN = ord.out_document and jo.PROD_ORDER = nOldFAcc;*/ -- это общий план без лицевого счета
        end if;
      end loop;
  elsif rec.out_unitcode = 'CostRouteLists' then    -- Маршрутный лист
    begin
    EXECUTE IMMEDIATE 'ALTER TRIGGER T_FCROUTLST_BUPDATE DISABLE';
    update FCROUTLST fc set fc.faceacc = nNewFAcc where fc.RN = rec.out_document; --and fc.faceacc in (nOldFAcc, 83660497);
    EXECUTE IMMEDIATE 'ALTER TRIGGER T_FCROUTLST_BUPDATE ENABLE';
    end;    

    nPRODPLANSP := f_doclinks_link_in_doc(sOUT_UNITCODE => 'CostRouteLists', 
                                          nOUT_DOCUMENT => rec.out_document, 
                                          sIN_UNITCODE  => 'CostProductPlansSpecs');
    if nPRODPLANSP is not null then -- Планы и отчеты производства изделий (спецификация)
      update FCPRODPLANSP fcp set fcp.PROD_ORDER = nNewFAcc where fcp.RN = nPRODPLANSP; --and fcp.PROD_ORDER in (nOldFAcc, 83660497);
    end if;

    for lst in ( -- Выходные документы из Маршрутного листа
      select dl.out_unitcode, dl.out_document
        from DOCLINKS dl 
       where dl.in_document = rec.out_document and dl.in_unitcode = rec.out_unitcode
    ) loop

    if lst.out_unitcode = 'CostUnfinishedProductionJournal' then -- Незавершенное производство
      begin
      EXECUTE IMMEDIATE 'ALTER TRIGGER T_FCUNFINPRODJNL_BUPDATE DISABLE';
      update FCUNFINPRODJNL fc set fc.prod_order = nNewFAcc where fc.RN = lst.out_document; --and fc.PROD_ORDER in (nOldFAcc, 83660497);
      EXECUTE IMMEDIATE 'ALTER TRIGGER T_FCUNFINPRODJNL_BUPDATE ENABLE';
      end;
    elsif lst.out_unitcode = 'CostUnfinishedProductionMoving' then -- no faceacc
      continue;
    elsif lst.out_unitcode = 'IncomFromDeps' then -- Приход из подразделений
      update INCOMEFROMDEPS ps set ps.out_faceacc = nNewFAcc where ps.RN = lst.out_document; --and ps.out_faceacc in (nOldFAcc, 83660497);

      for inc1 in (
        select dl.out_unitcode, dl.out_document
          from DOCLINKS dl 
         where dl.in_document = lst.out_document and dl.in_unitcode = lst.out_unitcode
      ) loop

      if inc1.out_unitcode = 'LiabilitiesNotes' then     -- Журнал отгрузок
        update LIABILITYNOTES li set li.faceacc = nNewFAcc where li.RN = inc1.out_document; --and li.faceacc in (nOldFAcc, 83660497);
      elsif inc1.out_unitcode = 'StoreOpersJournal' then -- Журнал складских операций
        update STOREOPERJOURN jo set jo.faceacc = nNewFAcc where jo.RN = inc1.out_document; --and jo.faceacc in (nOldFAcc, 83660497);
      elsif inc1.out_unitcode = 'StoragePlacesResJournal' then -- Журнал резервирования по местам хранения STRPLRESJRNL 
        continue;
      elsif inc1.out_unitcode = 'GoodsTransInvoicesToDepts' then -- Расходные накладные на отпуск в подразделение из Расходных накладных
        update TRANSINVDEPT tr set tr.faceacc = nNewFAcc where tr.RN = inc1.out_document;
      else p_exception(0, 'Неучтенный раздел "' || inc1.out_unitcode || '". RN: ' || inc1.out_document);
      end if;

      end loop;

    elsif lst.out_unitcode = 'CostDeliverySheets' then -- Комплектовочные ведомости
      update FCDELIVSH fc set fc.prod_order = nNewFAcc where fc.RN = lst.out_document; --and fc.prod_order in (nOldFAcc, 83660497);
      for dept in (
        select dl.out_unitcode, dl.out_document
          from DOCLINKS dl 
         where dl.in_document = lst.out_document and dl.in_unitcode = lst.out_unitcode
      ) loop

      if dept.out_unitcode = 'GoodsTransInvoicesToDepts' or 
         dept.out_unitcode = 'GoodsTransInvoicesToDeptsSpecs' then 
--if dept.out_unitcode = 'GoodsTransInvoicesToDepts' then p_exception(0,lst.out_unitcode||lst.out_document||dept.out_unitcode||dept.out_document); end if;   

        if dept.out_unitcode = 'GoodsTransInvoicesToDepts' then -- Расходные накладные на отпуск в подразделения
          update TRANSINVDEPT p set p.faceacc = nNewFAcc where p.rn = dept.out_document; --and p.faceacc in (nOldFAcc, 83660497);
        end if;

        for inc2 in (
          select dl.out_unitcode, dl.out_document
            from DOCLINKS dl 
           where dl.in_document = dept.out_document and dl.in_unitcode = dept.out_unitcode
        ) loop

        if inc2.out_unitcode = 'LiabilitiesNotes' then     -- Журнал отгрузок
          update LIABILITYNOTES li set li.faceacc = nNewFAcc where li.RN = inc2.out_document; --and li.faceacc in (nOldFAcc, 83660497);
        elsif inc2.out_unitcode = 'StoreOpersJournal' then -- Журнал складских операций
          update STOREOPERJOURN jo set jo.faceacc = nNewFAcc where jo.RN = inc2.out_document; --and jo.faceacc in (nOldFAcc, 83660497);
        elsif inc2.out_unitcode = 'StoragePlacesResJournal' then -- no faceacc
          continue;
        elsif inc2.out_unitcode = 'GoodsTransInvoicesToDepts' then -- Расходные накладные на отпуск в подразделение из Расходных накладных
          update TRANSINVDEPT tr set tr.faceacc = nNewFAcc where tr.RN = inc2.out_document;
        else p_exception(0, 'Неучтенный раздел "' || inc2.out_unitcode || '". RN: ' || inc2.out_document);
        end if;

        end loop;

      end if;

      end loop;
    elsif lst.out_unitcode = 'CostDeliveryLists' then -- Комплектации
      update FCDELIVERYLIST dl set dl.prod_order = nNewFAcc where dl.RN = lst.out_document; --and dl.prod_order in (nOldFAcc, 83660497);
    else p_exception(0, 'Неучтенный раздел "' || lst.out_unitcode || '". RN: ' || lst.out_document);
    end if;

    end loop;

  elsif rec.out_unitcode = 'GoodsTransInvoicesToDepts' then -- Расходные накладные на отпуск в подразделение из Расходных накладных
    update TRANSINVDEPT tr set tr.faceacc = nNewFAcc where tr.RN = rec.out_document;

/*    for gtd in ( -- Сертификация/Входной контроль
        select dl.out_unitcode, dl.out_document
          from DOCLINKS dl 
         where dl.in_document = rec.out_document
    ) loop
    null;
\*      'StoreOpersJournal'
      'LiabilitiesNotes'
      gtd.out_unitcode = 'GoodsTransInvoicesToDepts'*\
    end loop;*/

  elsif rec.out_unitcode = 'UdoProdCull' then -- Сертификация/Входной контроль
    update UDO_PROD_CULL pc set pc.faceacc_div = nNewFAcc where pc.RN = rec.out_document;

  else p_exception(0, 'Неучтенный раздел "' || rec.out_unitcode || '". RN: ' || rec.out_document);
  end if;
  
  end loop;
--p_exception(0, 'Stop: ' || nOldFAcc || '->' || nNewFAcc);  

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end UDO_P_PAYACCIN_FACEACC_REMONT;
/
