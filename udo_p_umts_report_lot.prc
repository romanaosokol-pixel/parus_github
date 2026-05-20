create or replace procedure udo_p_umts_report_lot(ncompany in number /*Организация*/,
                                                  nident   in number /*Идентификатор отмеченных записей*/) is

  /*Анненко И.С.*/

  /*10.09.2022*/

  --create public synonym udo_p_umts_report_lot for udo_p_umts_report_lot;

  --grant execute on udo_p_umts_report_lot to public;

  /*Процедура выполняет формирование печатной формы лота*/

  /*Регистрационный номер записи заказа поставщику*/
  nrn pkg_std.tREF;

  /*Номер строки*/
  nline_index number;

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

  /*Инициализация*/
  prsg_excel.PREPARE;

  /*Выбираем лист*/
  prsg_excel.SHEET_SELECT(sSHEET_NAME => 'Лот');

  /*Описываем строку*/
  prsg_excel.LINE_DESCRIBE(sLINE_NAME => 'Строка');
  prsg_excel.LINE_CELL_DESCRIBE(sLINE_NAME => 'Строка',
                                sCELL_NAME => 'Номер');
  prsg_excel.LINE_CELL_DESCRIBE(sLINE_NAME => 'Строка',
                                sCELL_NAME => 'Наименование');
  prsg_excel.LINE_CELL_DESCRIBE(sLINE_NAME => 'Строка',
                                sCELL_NAME => 'Количество');
  prsg_excel.LINE_CELL_DESCRIBE(sLINE_NAME => 'Строка',
                                sCELL_NAME => 'ЕИ');
  prsg_excel.LINE_CELL_DESCRIBE(sLINE_NAME => 'Строка',
                                sCELL_NAME => 'Цена');
  prsg_excel.LINE_CELL_DESCRIBE(sLINE_NAME => 'Строка',
                                sCELL_NAME => 'Сумма');

  /*Цикл по строкам документа*/
  for sp_cursor in (select n.nomen_name   as sname,
                           s.main_quant   as nquant,
                           dmu.meas_mnemo as sei
                      from deliveryords s, dicnomns n, dicmunts dmu
                     where s.prn = nrn
                       and n.rn = s.nomen
                       and dmu.rn = n.umeas_main
                     order by n.nomen_name) loop
    /*Выполняем добавление строки*/
    nline_index := prsg_excel.LINE_APPEND(sLINE_NAME => 'Строка');
  
    /*Наименование*/
    prsg_excel.cell_value_write(scell_name    => 'Наименование',
                                icell_index_x => 0,
                                icell_index_y => nline_index,
                                scell_value   => sp_cursor.sname);
  
    /*Количество*/
    prsg_excel.cell_value_write(scell_name    => 'Количество',
                                icell_index_x => 0,
                                icell_index_y => nline_index,
                                ncell_value   => sp_cursor.nquant);
  
    /*ЕИ*/
    prsg_excel.cell_value_write(scell_name    => 'ЕИ',
                                icell_index_x => 0,
                                icell_index_y => nline_index,
                                scell_value   => sp_cursor.sei);
  end loop;

  /*Удаляем шаблон строки*/
  prsg_excel.LINE_DELETE(sLINE_NAME => 'Строка');
end udo_p_umts_report_lot;
/

