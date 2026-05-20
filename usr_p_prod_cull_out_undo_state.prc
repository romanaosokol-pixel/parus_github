create or replace procedure usr_p_prod_cull_out_undo_state
/*
Клиентская процедура снятия отработки. Раздел "Резкультаты сертификации/ВК"
Таблица раздела: UDO_PROD_CULL_OUT Результаты Сертификации/ВК   USR_PROD_CULL_OUT_UNDO_STATE
grant execute on UDO_P_PROD_CULL_OUT_UNDO_STATE to public;
*/
(
 nIDENT in selectlist.ident%type -- Идент. отмеченной записи
) 
is
  nProd_Cull_Out    pkg_std.tref; 
  rProd_Cull_Out    udo_prod_cull_out%rowtype;
begin
  /* Определение RN документа */
  select document
    into nProd_Cull_Out
    from selectlist 
   where ident = nIDENT;

  /* Считывание записи */
  rProd_Cull_Out := udo_pkg_prod_cull.cull_out_get_id( nflag_smart => 0, nRN => nProd_Cull_Out );

  /* Проверка прав на выполнение действия */
  /*pkg_env.access( ncompany  => rProd_Cull_Out.company
                 ,nversion  => null
                 ,ncatalog  => rProd_Cull_Out.crn
                 ,njur_pers => rProd_Cull_Out.jurpers
                 ,sunit     => 'UdoProdCullSpOut'
                 ,saction   => 'USR_P_PROD_CULL_OUT_UNDO_STATE');*/
                 
  /* Базовое снятие отработки */ 
  udo_pkg_prod_cull.cull_out_work_undo( nrn => rProd_Cull_Out.rn, ncompany => rProd_Cull_Out.company );

/*
  \* Отберем строки раздела "Результаты сертификации", которые будут удалены при сняти отработки *\
  for rec in (select t.rn doc_rn
                    ,t.prn doc_prn
                    ,t.company
                    ,nsp.rn nsp_rn
                    ,n.rn n_rn
                    ,sp.prn ser_rn -- RN Документа "Сертификация"
                    ,max(n.status) over(partition by t.rn) max_status
                from selectlist sl
                join udo_prod_cull_out t
                  on t.rn = sl.document
                left join doclinks dl
                  on dl.in_document = t.rn
                 and dl.out_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
                 and dl.in_unitcode = 'UdoProdCullSpOut'
                left join transinvdeptspecs nsp
                  on nsp.rn = dl.out_document
                left join transinvdept n
                  on n.rn = nsp.prn
                join udo_prod_cull_sp sp
                  on sp.rn = t.prn
               where sl.ident = nident
                 and sl.authid = utilizer
                 and sl.unitcode = 'UdoProdCullSpOut')
  loop
  
    if rec.max_status = 0
    then
      ---
      \*Удаляем связь между строкой Результата сертификации и строкой спецификации накладной *\
    
      pkg_doclinks.remove(sin_unitcode => 'UdoProdCullSpOut', nin_document => rec.doc_rn, sout_unitcode => 'GoodsTransInvoicesToDeptsSpecs', nout_document => rec.nsp_rn);
    
      \* Удаляем строку из накладной *\
    
      p_transinvdeptsp_base_delete(rec.company, rec.nsp_rn);
    
      \* 
      
         Если это последняя строка в накладной, то
      1. Удаляем связь между накладной и Документом "Сертификация/входной контроль"     
      2. Если по строке "Передано на сертификацию/ВК" больше накладных нет, то Снимаем с неё отработку
      
      *\
    
      for nak in (select n.rn
                    from transinvdept n
                    left join transinvdeptspecs nsp
                      on nsp.prn = n.rn
                   where n.rn = rec.n_rn
                     and nsp.rn is null)
      
      loop
      
        udo_p_prod_cull_sp_undo_state(nprn => rec.ser_rn);
      
      end loop;
    
    else
    
      \* Находим реквизиты накладной которая в состоянии "Отработан" и выдаем предупреждение , что снять отработку невозможно *\
      begin
        select n.rn
              ,trim(n.pref) || '-' || trim(n.numb) || ' от ' || to_char(n.docdate, 'DD.MM.YYYY')
          into v_nak_rn
              ,v_s_nak
          from selectlist sl
          join udo_prod_cull_out t
            on t.rn = sl.document
          left join doclinks dl
            on dl.in_document = t.rn
           and dl.out_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
           and dl.in_unitcode = 'UdoProdCullSpOut'
          left join transinvdeptspecs nsp
            on nsp.rn = dl.out_document
          left join transinvdept n
            on n.rn = nsp.prn
         where sl.ident = nident
           and sl.authid = utilizer
           and sl.unitcode = 'UdoProdCullSpOut'
           and n.status != 0
           and rownum = 1;
      exception
        when no_data_found then
          p_exception(0, 'Ошибка снятия отработки c документа, обратитесь в тех. поддержку.'); \*Такого никогда не должно быть!*\
      end;
    
      p_exception(0, 'Нельзя снять отработку со строки результатов сертификации(Rn = %s), т.к. созданная по данной строке накладная %s уже отработана в учете.', v_nak_rn, v_s_nak);
    
    end if;
  
  end loop;
*/

end;
/
