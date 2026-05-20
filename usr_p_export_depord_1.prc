create or replace procedure usr_p_export_depord_1(ncompany in number
                                                 ,nprocess in number
                                                 ,nident   in number
                                                 ,bcontent out blob) is
  nfl integer := 0;
/*    <Внешний номер договора> + ' '+ <Дата договора> + ' '+ <Номер этапа (для накладной)> + ' '+<Название файла присоединенного документ> + <RN присоединенного документа>*/
  procedure export_file(in_content_type in number
                       ,in_file_path    in varchar2
                       ,in_bdata        in blob
                       ,in_cdata        in clob
                       ,in_mime_type    in varchar2) is
  begin
    if in_content_type = 0
    then
      insert into file_buffer
        (ident
        ,authid
        ,filename
        ,bdata
        ,mime_type)
      values
        (nprocess
        ,utilizer
        ,in_file_path
        ,in_bdata
        ,in_mime_type);
    else
      insert into file_buffer
        (ident
        ,authid
        ,filename
        ,data
        ,mime_type)
      values
        (nprocess
        ,utilizer
        ,in_file_path
        ,in_cdata
        ,in_mime_type);
    end if;
  end;

begin

  for rrec in (select dep.rn
                     ,nvl(dep.ord_numb, ' ' || dep.rn) || ' ' || to_char(dep.ord_date, 'DD.MM.YYYY') || ' ' as base_name
                 from selectlist sl
                 join departmentord dep
                   on dep.rn = sl.document
                where sl.ident = nident
                  and sl.authid = utilizer
                  and sl.unitcode = 'DepartmentsOrders')
  loop
  
    begin
    
      with rr as
       (select ur.authid
          from roles r
          join userroles ur
            on ur.roleid = r.rn        
         where r.rolename in ('УЗСР ОМТС', 'Все права'))      
      select 1
        into nfl
        from rr
       where rr.authid = utilizer
         and rownum = 1;
    exception
      when no_data_found then
        nfl := 0;
    end;
  
    p_exception(nfl, 'Права на выгрузку есть только у роли "УЗСР ОМТС".');
  
    -- 1. Файлы самого заказа подразделения
    for fl_dep in (select fl.file_path
                         ,fl.bdata
                         ,fl.cdata
                         ,flt.content_type
                         ,flt.mime_type
                         ,fl.rn as fl_rn
                     from filelinksunits flu
                     join filelinks fl
                       on fl.rn = flu.filelinks_prn
                     join flinktypes flt
                       on flt.rn = fl.file_type
                    where flu.table_prn = rrec.rn
                      and flu.unitcode = 'DepartmentsOrders'
                      and flt.allocation_type = 0)
    loop
      export_file(trim(fl_dep.content_type)
                 ,trim(rrec.base_name) || ' ЗАЯВКА ' || substr(fl_dep.file_path, 1, instr(fl_dep.file_path, '.', -1) - 1) || ' ' ||
                  fl_dep.fl_rn || substr(fl_dep.file_path, instr(fl_dep.file_path, '.', -1))
                 ,fl_dep.bdata
                 ,fl_dep.cdata
                 ,fl_dep.mime_type);
    end loop;
  
    -- 2. Входящие счета, связанные через PAYACCINSPCLC_EX
    for inv in (select distinct pai.rn
                               ,pai.faceacc
                               ,nvl(pai.doc_numb, ' ' || pai.rn) as doc_number
                               ,pai.doc_date
                  from payaccinspclc_ex ex
                  join payaccinspclc pclc
                    on pclc.rn = ex.prn
                  join payaccinspec spec
                    on spec.rn = pclc.prn
                  join payaccin pai
                    on pai.rn = spec.prn
                 where ex.departmentord = rrec.rn)
    loop
    
      -- Файлы заголовка входящего счёта (PAYACCIN)
      for fl_inv in (select fl.file_path
                           ,fl.bdata
                           ,fl.cdata
                           ,flt.content_type
                           ,flt.mime_type
                           ,fl.rn as fl_rn
                       from filelinksunits flu
                       join filelinks fl
                         on fl.rn = flu.filelinks_prn
                       join flinktypes flt
                         on flt.rn = fl.file_type
                      where flu.table_prn = inv.rn
                        and flu.unitcode = 'PaymentAccountsIn'
                        and flt.allocation_type = 0)
      loop
        export_file(trim(fl_inv.content_type)
                   ,trim(rrec.base_name) || ' СЧЕТ ' || trim(inv.doc_number) || ' ' || to_char(inv.doc_date, 'DD.MM.YYYY') || ' ' ||
                    substr(fl_inv.file_path, 1, instr(fl_inv.file_path, '.', -1) - 1) || ' ' || fl_inv.fl_rn ||
                    substr(fl_inv.file_path, instr(fl_inv.file_path, '.', -1))
                   ,fl_inv.bdata
                   ,fl_inv.cdata
                   ,fl_inv.mime_type);
      end loop;
      -- 3. Приходные накладные, связанные по сыязям со счетами
      for rcpt in (select ininv.rn
                         ,nvl(ininv.numb, 'RCPT_' || ininv.rn) as doc_numb
                         ,ininv.doc_date
                     from doclinks dl
                     join ininvoices ininv  on ininv.rn = dl.out_document
                    where dl.in_document = inv.rn  and dl.out_unitcode = 'IncomingInvoices' and dl.in_unitcode = 'PaymentAccountsIn'
                    /*ininv.faceacc = inv.faceacc*/)
      loop
      
        -- Файлы приходной накладной
        for fl_rcpt in (select fl.file_path
                              ,fl.bdata
                              ,fl.cdata
                              ,flt.content_type
                              ,flt.mime_type
                              ,fl.rn as fl_rn
                          from filelinksunits flu
                          join filelinks fl
                            on fl.rn = flu.filelinks_prn
                          join flinktypes flt
                            on flt.rn = fl.file_type
                         where flu.table_prn = rcpt.rn
                           and flu.unitcode = 'IncomingInvoices'
                           and flt.allocation_type = 0)
        loop
          export_file(fl_rcpt.content_type
                     ,trim(rrec.base_name) || ' НАКЛАДНАЯ ' || rcpt.rn||' '||trim(rcpt.doc_numb) || ' ' || to_char(rcpt.doc_date, 'DD.MM.YYYY') || ' ' ||
                      substr(fl_rcpt.file_path, 1, instr(fl_rcpt.file_path, '.', -1) - 1) || ' ' || fl_rcpt.fl_rn ||
                      substr(fl_rcpt.file_path, instr(fl_rcpt.file_path, '.', -1))
                     ,fl_rcpt.bdata
                     ,fl_rcpt.cdata
                     ,fl_rcpt.mime_type);
        end loop; -- fl_rcpt
      
      end loop; -- rcpt
    end loop; -- inv
  
  end loop; -- rrec

end;
/
