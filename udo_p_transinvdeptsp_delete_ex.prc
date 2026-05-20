create or replace procedure UDO_P_TRANSINVDEPTSP_DELETE_EX
(
  nIDENT                      in number -- Идентификатор отмеченных записей 
) is
/*
  Процедура удаления строки РН, связанной с КВ (с удалением распределния по местам хранения)
  
  grant execute on UDO_P_TRANSINVDEPTSP_DELETE_EX to public;
*/
  nCHECK                      pkg_std.tREF := 0;             -- Признак удаления записи
  nCMPL                       pkg_std.tREF;                  -- Рег. номер КВ
  nCMPL_SP                    pkg_std.tREF;                  -- Рег. номер сроки КВ
  rec                         transinvdept%rowtype;          -- Запись РН
  sEVNSTAT_CODE               CLNEVNSTATS.EVNSTAT_CODE%type; -- Статус РН
  sEVNSTAT_CODE_CHECK         CLNEVNSTATS.EVNSTAT_CODE%type; -- Значение константы для проверки                     
begin
  -- процедура закрыта
  -- 07/04/2023 Марков МВ.
  p_exception(0, 'Воспользуйтесь процедурой "Корректировка количества..."');
  
  /* Цикл по отмеченным записям */
  for cur in (select t.* 
                from transinvdeptspecs t,
                     selectlist        sl 
               where t.rn = sl.document
                 and sl.ident = nIDENT)
  loop  
    if nvl(nCHECK,0) = 0 then
      nCHECK := 1;
      
      /* КВ */
      nCMPL := f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDepts',
                                      nOUT_DOCUMENT => cur.prn,
                                      sIN_UNITCODE  => 'CostDeliverySheets');
      if nCMPL is null then 
        return;
      end if;
      
      /* Считывааем заголовок */
      rec := udo_pkg_get.ROW_TRANSINVDEPT(NRN => cur.prn, NSMART => 0);
      
      /* Проверка прав доступа */
      pkg_env.ACCESS(nCOMPANY  => rec.company,
                     nVERSION  => null,
                     nCATALOG  => rec.crn,
                     nJUR_PERS => null,
                     sUNIT     => 'GoodsTransInvoicesToDeptsSpecs',
                     sACTION   => 'TRANSINVDEPTSPECS_DELETE');
                     
      /* удаление связи  КВ-РН для возможности удаления строк спецификации */
      p_linksall_remove(nCOMPANY      => rec.company,
                        sIN_UNITCODE  => 'CostDeliverySheets',
                        nIN_DOCUMENT  => nCMPL,
                        sOUT_UNITCODE => 'GoodsTransInvoicesToDepts',
                        nOUT_DOCUMENT => rec.rn);
      
      /* Проверка стаусной модели (удаление возможно только в статусе "РегистрацияРНвПдр") */
      sEVNSTAT_CODE_CHECK := udo_f_get_const_val_str(nFLAG_SMART => 0,nCOMPANY => rec.company, sCONST_NAME => 'СТАТ_РНОПОДР_УДАЛ_СП');
      begin
        select TS.EVNSTAT_CODE
          into sEVNSTAT_CODE
          from CLNEVENTS      T,
               CLNEVNTYPSTS   ES,
               CLNEVNSTATS    TS
         where T.EVENT_STAT    = ES.RN
           and ES.EVENT_STATUS = TS.RN
           and T.LINKED_UNIT = 'GoodsTransInvoicesToDepts'
           and T.LINKED_RN = rec.rn;
      exception when no_data_found then 
        sEVNSTAT_CODE := null;
      end;  
      if sEVNSTAT_CODE is not null and sEVNSTAT_CODE != sEVNSTAT_CODE_CHECK
        and utilizer not in ('CITK_MARKOV','EVGEN', 'KHOK')
         then 
        p_exception(0,'Удаление строки РН возможно только если заголовок находится в статусе "%s".', sEVNSTAT_CODE_CHECK);
      end if;
      
    end if;
     
    /* Удаление распределения по местам хранения */
    for lnk in (select *
                  from STRPLRESJRNL t
                 where exists (select *
                                 from V_DOCLINKS_INOUT_IN_EXT DLIN
                                where (DLIN.NIN_DOCUMENT = cur.rn)
                                  and (DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')
                                  and (DLIN.NDOCUMENT = t.RN)))
    loop                       
      P_STRPLRESJRNL_BASE_DELETE(nCOMPANY => lnk.company, nRN => lnk.rn);
    end loop;
    
   /* Удаление связей с строкой КВ для заголовка РН 26/10/2022 Марков МВ. */
    nCMPL_SP := f_doclinks_link_in_doc(sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
                                       nOUT_DOCUMENT => cur.rn,
                                       sIN_UNITCODE  => 'CostDeliverySheetsSpec');
    p_linksall_remove(nCOMPANY      => rec.company,
                      sIN_UNITCODE  => 'CostDeliverySheetsSpec',
                      nIN_DOCUMENT  => nCMPL_SP,
                      sOUT_UNITCODE => 'GoodsTransInvoicesToDepts',
                      nOUT_DOCUMENT => rec.rn);  
                                        
    /* Удаление связей по входу для строки спецификации */
    p_linksall_remove(nCOMPANY      => rec.company,
                        sIN_UNITCODE  => null,
                        nIN_DOCUMENT  => null,
                        sOUT_UNITCODE => 'GoodsTransInvoicesToDeptsSpecs',
                        nOUT_DOCUMENT => cur.rn);
                        
    /* Удаление записи */
    P_TRANSINVDEPTSP_BASE_DELETE(nCOMPANY => cur.company, nRN => cur.rn);
    
  end loop;
  
  if nvl(nCHECK,0) = 1 then 
    /* восстанавливаем связь КВ-РН */
    p_linksall_link_direct(nCOMPANY          => rec.company,
                           sIN_UNITCODE      => 'CostDeliverySheets',
                           nIN_DOCUMENT      => nCMPL,
                           nIN_PRN_DOCUMENT  => null,
                           dIN_IN_DATE       => sysdate,
                           nIN_STATUS        => 0,
                           sOUT_UNITCODE     => 'GoodsTransInvoicesToDepts',
                           nOUT_DOCUMENT     => rec.rn,
                           nOUT_PRN_DOCUMENT => null,
                           dOUT_IN_DATE      => sysdate,
                           nOUT_STATUS       => 0,
                           nBREAKUP_KIND     => 1);
  end if; 
end ;
/

