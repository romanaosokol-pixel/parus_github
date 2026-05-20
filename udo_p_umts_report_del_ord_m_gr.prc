create or replace procedure udo_p_umts_report_del_ord_m_gr(ncompany in number /*Организация*/,
                                                           nident   in number /*Идентификатор отмеченных записей*/) is

  /*Анненко И.С.*/

  /*11.10.2022*/

  --create public synonym udo_p_umts_report_del_ord_m_gr for udo_p_umts_report_del_ord_m_gr;

  --grant execute on udo_p_umts_report_del_ord_m_gr to public;

  /*Процедура выполняет формирование помесячного графика поставки*/

  /*Регистрационный номер записи заказа поставщику*/
  nrn pkg_std.tREF;

  /*Месяц начала*/
  dmonth_begin date;

  /*Месяц окончания*/
  dmonth_end date;

  /*Тип списка столбцов*/
  type tcolumn_list_type is table of date index by binary_integer;

  /*Перечень столбцов*/
  acolumn_list tcolumn_list_type;

  /*Процедура выполняет формирование столбцов отчета*/
  procedure p_create_report_columns is
  
    /*Текущий месяц*/
    dmonth date;
  
    /*Номер столбца*/
    ncolumn_index number;
  
  begin
    /*Первый месяц*/
    dmonth := dmonth_begin;
  
    /*Цикл по месяцам*/
    while (dmonth <= dmonth_end) loop
    
      /*Выполняем добавление столбца*/
      ncolumn_index := prsg_excel.COLUMN_APPEND(sCOLUMN_NAME => 'Столбец');
    
      /*Наименование столбца*/
      prsg_excel.cell_value_write(scell_name    => 'Месяц',
                                  icell_index_x => ncolumn_index,
                                  icell_index_y => 0,
                                  scell_value   => f_smonth_base(nVALUE     => extract(month from
                                                                                       dmonth),
                                                                 nTYPE      => 0,
                                                                 nLOWLETTER => 0) || ' ' ||
                                                   to_char(dmonth, 'yyyy'));
    
      /*Добавляем столбец в список*/
      acolumn_list(ncolumn_index) := dmonth;
    
      /*Переходим к следующему месяцу*/
      dmonth := add_months(dmonth, 1);
    end loop;
  end p_create_report_columns;

  /*Процедура выполняет заполнение ячеек с количеством*/
  procedure p_create_report_cells_quant(nrn_sp      in number /*Регистрационный номер записи строки заказа поставщику*/,
                                        nline_index in number /*Номер строки*/) is
  
    /*Количество*/
    nquant pkg_std.tQUANT;
  
  begin
    /*Цикл по столбцам*/
    for ncolumn_index in acolumn_list.first .. acolumn_list.last loop
    
      select sum(c.quant_plan)
        into nquant
        from udo_uzd_03_buyplanesp_cntr_doc c, buyplanesp bp_sp
       where c.doc_rn = nrn_sp
         and c.company = ncompany
         and bp_sp.rn = c.prn
         and trunc(bp_sp.shipment_plan, 'month') =
             acolumn_list(ncolumn_index);
    
      prsg_excel.cell_value_write(scell_name    => 'Количество',
                                  icell_index_x => ncolumn_index,
                                  icell_index_y => nline_index,
                                  ncell_value   => nvl(nquant, 0));
    end loop;
  end p_create_report_cells_quant;

  /*Процедура выполняет формирование строк отчета*/
  procedure p_create_report_lines is
  
    /*Номер строки*/
    nline_index number;
  
  begin
    /*Цикл по строкам документа*/
    for sp_cursor in (select s.rn           as nrn,
                             n.nomen_name   as sname,
                             dmu.meas_mnemo as sei
                        from deliveryords s, dicnomns n, dicmunts dmu
                       where s.prn = nrn
                         and n.rn = s.nomen
                         and dmu.rn = n.umeas_main
                       order by n.nomen_name) loop
    
      /*Выполняем добавление строки*/
      nline_index := prsg_excel.LINE_APPEND(sLINE_NAME => 'Строка');
    
      /*Наименование*/
      prsg_excel.cell_value_write(scell_name    => 'Номер',
                                  icell_index_x => 0,
                                  icell_index_y => nline_index,
                                  ncell_value   => nline_index);
    
      /*Наименование*/
      prsg_excel.cell_value_write(scell_name    => 'Наименование',
                                  icell_index_x => 0,
                                  icell_index_y => nline_index,
                                  scell_value   => sp_cursor.sname);
    
      /*Выполняем заполнение ячеек с количеством*/
      p_create_report_cells_quant(nrn_sp      => sp_cursor.nrn,
                                  nline_index => nline_index);
    
      /*ЕИ*/
      prsg_excel.cell_value_write(scell_name    => 'ЕИ',
                                  icell_index_x => 0,
                                  icell_index_y => nline_index,
                                  scell_value   => sp_cursor.sei);
    end loop;
  end p_create_report_lines;

begin

  /*Регистрационный номер записи заказа поставщику*/
  begin
    select sl.document
      into nrn
      from selectlist sl
     where sl.ident = nident
       and sl.company = ncompany;
  exception
    when no_data_found then
      p_exception(0,
                  'Необходимо выбрать заказ поставщику');
    when too_many_rows then
      p_exception(0,
                  'Необходимо выбрать единственный заказ поставщику');
  end;

  /*Период*/
  select trunc(min(bp_sp.shipment_plan), 'month'),
         trunc(max(bp_sp.shipment_plan), 'month')
    into dmonth_begin, dmonth_end
    from deliveryords s, udo_uzd_03_buyplanesp_cntr_doc c, buyplanesp bp_sp
   where s.prn = nrn
     and s.company = ncompany
     and c.doc_rn = s.rn
     and bp_sp.rn = c.prn;

  /*Инициализация*/
  prsg_excel.PREPARE;

  /*Выбираем лист*/
  prsg_excel.SHEET_SELECT(sSHEET_NAME => 'График');

  /*Описываем строку*/
  prsg_excel.LINE_DESCRIBE(sLINE_NAME => 'Строка');
  prsg_excel.LINE_CELL_DESCRIBE(sLINE_NAME => 'Строка',
                                sCELL_NAME => 'Номер');
  prsg_excel.LINE_CELL_DESCRIBE(sLINE_NAME => 'Строка',
                                sCELL_NAME => 'Наименование');
  prsg_excel.LINE_CELL_DESCRIBE(sLINE_NAME => 'Строка',
                                sCELL_NAME => 'ЕИ');
  prsg_excel.LINE_CELL_DESCRIBE(sLINE_NAME => 'Строка',
                                sCELL_NAME => 'Количество');

  /*Описываем столбец*/
  prsg_excel.column_DESCRIBE(scolumn_NAME => 'Столбец');
  prsg_excel.column_CELL_DESCRIBE(scolumn_NAME => 'Столбец',
                                  sCELL_NAME   => 'Месяц');
  prsg_excel.column_CELL_DESCRIBE(scolumn_NAME => 'Столбец',
                                  sCELL_NAME   => 'Количество');

  /*Выполняем формирование столбцов отчета*/
  p_create_report_columns;

  /*Выполняем формирование строк отчета*/
  p_create_report_lines;

  /*Удаляем шаблон строки*/
  prsg_excel.LINE_DELETE(sLINE_NAME => 'Строка');

  /*Удаляем шаблон столбца*/
  prsg_excel.column_DELETE(scolumn_NAME => 'Столбец');
end udo_p_umts_report_del_ord_m_gr;
/

