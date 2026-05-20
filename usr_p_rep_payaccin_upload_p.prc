create or replace procedure usr_p_rep_payaccin_upload_p
/*Пользовательский отчет Выгрузка по входящим счетам на оплату из раздела Входящие счета на оплату*/
(pin_prj_code in project.code%type
 --,sFaceAccnumb in varchar2
 ) is
  -- Имена ячеек из шаблона Excel
  c_numb           constant pkg_std.tstring := 'номер_счета';
  c_doc_date       constant pkg_std.tstring := 'дата_счета';
  c_nomen_name     constant pkg_std.tstring := 'наименование';
  c_group_tmc      constant pkg_std.tstring := 'Группа_ТМЦ';
  c_umts_group     constant pkg_std.tstring := 'УМТС_Группа_Номенклатуры';
  c_quant          constant pkg_std.tstring := 'количество';
  c_summ_with_nds  constant pkg_std.tstring := 'сумма_с_НДС';
  c_nds            constant pkg_std.tstring := 'НДС';
  c_price_unit_nds constant pkg_std.tstring := 'цена_за_единицу_с_НДС';
  c_supplier       constant pkg_std.tstring := 'поставщик';
  c_contract       constant pkg_std.tstring := 'контракт';

  zagolovok constant pkg_std.tstring := 'zagolovok';

  c_line constant pkg_std.tstring := 'LINE1';

  sheet_name varchar2(30) := 'X';
  idx        integer;

begin
  prsg_excel.prepare;
  prsg_excel.sheet_select(sheet_name);
  prsg_excel.line_describe(c_line);
  prsg_excel.cell_describe(zagolovok);

  -- Описываем все именованные ячейки
  prsg_excel.line_cell_describe(c_line
                               ,c_numb);
  prsg_excel.line_cell_describe(c_line
                               ,c_doc_date);
  prsg_excel.line_cell_describe(c_line
                               ,c_nomen_name);
  prsg_excel.line_cell_describe(c_line
                               ,c_group_tmc);
  prsg_excel.line_cell_describe(c_line
                               ,c_umts_group);
  prsg_excel.line_cell_describe(c_line
                               ,c_quant);
  prsg_excel.line_cell_describe(c_line
                               ,c_summ_with_nds);
  prsg_excel.line_cell_describe(c_line
                               ,c_nds);
  prsg_excel.line_cell_describe(c_line
                               ,c_price_unit_nds);
  prsg_excel.line_cell_describe(c_line
                               ,c_supplier);
  prsg_excel.line_cell_describe(c_line
                               ,c_contract);

  for rec in (select p.ext_numb as numb
                    ,p.doc_date
                    ,d.nomen_name
                    ,gr.group_code as group_tmc
                    ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 19579777
                                                        ,sunitcode => 'Nomenclator'
                                                        ,ndocument => d.rn) as umts_group
                    ,sp.quant
                    ,sp.summwithnds
                    ,sp.summ_nds as nds
                    ,case
                       when sp.quant = 0 then
                        0
                       else
                        round(sp.summwithnds / sp.quant
                             ,2)
                     end as price_unit_nds
                    ,ag.agnabbr as supplier
                    ,(select dog.ext_number from stages st join contracts dog on dog.rn = st.prn where st.faceacc = p.faceacc) as contract
                from payaccin p
                join payaccinspec sp
                  on sp.prn = p.rn
                join payaccinspclc clc
                  on clc.prn = sp.rn
                join dicnomns d
                  on d.rn = sp.nomen
                join dicgnomn gr
                  on gr.rn = d.group_code
                join agnlist ag
                  on ag.rn = p.supplier
               where clc.faceaccount in (select ps.faceacc
                                           from project pr
                                           join projectstage ps
                                             on ps.prn = pr.rn
                                          where pr.code = pin_prj_code
                                            and pr.company = p.company)
               order by p.doc_date
                       ,d.nomen_name
                       ,p.ext_numb)
  loop
  
    idx := prsg_excel.line_append(c_line);
  
    prsg_excel.cell_value_write(c_numb
                               ,0
                               ,idx
                               ,rec.numb);
    prsg_excel.cell_value_write(c_doc_date
                               ,0
                               ,idx
                               ,rec.doc_date);
    prsg_excel.cell_value_write(c_nomen_name
                               ,0
                               ,idx
                               ,rec.nomen_name);
    prsg_excel.cell_value_write(c_group_tmc
                               ,0
                               ,idx
                               ,rec.group_tmc);
    prsg_excel.cell_value_write(c_umts_group
                               ,0
                               ,idx
                               ,rec.umts_group);
    prsg_excel.cell_value_write(c_quant
                               ,0
                               ,idx
                               ,rec.quant);
    prsg_excel.cell_value_write(c_summ_with_nds
                               ,0
                               ,idx
                               ,rec.summwithnds);
    prsg_excel.cell_value_write(c_nds
                               ,0
                               ,idx
                               ,rec.nds);
    prsg_excel.cell_value_write(c_price_unit_nds
                               ,0
                               ,idx
                               ,rec.price_unit_nds);
    prsg_excel.cell_value_write(c_supplier
                               ,0
                               ,idx
                               ,rec.supplier);
    prsg_excel.cell_value_write(c_contract
                               ,0
                               ,idx
                               ,rec.contract);
  
  end loop;
  prsg_excel.cell_value_write(zagolovok
                             ,'Выгрузка по входящим счетам на оплату, по лицевому счету затрат из калькуляции ' || pin_prj_code);

  -- Удаляем пустую строку-заготовку (если не было данных)
  prsg_excel.line_delete(c_line);

end;

  --grant execute on USR_P_REP_PAYACCIN_UPLOAD_P to public;
/
