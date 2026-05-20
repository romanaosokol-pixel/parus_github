create or replace procedure USR_P_REP_ACT_DECOUPLING
/*
24/09/2022 Степанов М.
Процедура для отчёта "Акт разукомплектации материала".
*/
(
 nIDENT                   in number
,sAPPROVE_POST            in varchar2   /* Утверждаю. Должность */
,sAPPROVE_FIO             in varchar2   /* Утверждаю. ФИО */
,dAPPROVE_DATE            in date       /* Утверждаю. Дата */
,sCHAIRMAN_COMIS_1_POST   in varchar2   /* Председатель комиссии 1. Должность */
,sCHAIRMAN_COMIS_1_FIO    in varchar2   /* Председатель комиссии 1. ФИО */
,sMEMB_COMIS_2_POST       in varchar2   /* Член комиссии 2. Должность */
,sMEMB_COMIS_2_FIO        in varchar2   /* Член комиссии 2. ФИО */
,sMEMB_COMIS_3_POST       in varchar2   /* Член комиссии 3. Должность */
,sMEMB_COMIS_3_FIO        in varchar2   /* Член комиссии 3. ФИО */
,sMEMB_COMIS_4_POST       in varchar2   /* Член комиссии 4. Должность */
,sMEMB_COMIS_4_FIO        in varchar2   /* Член комиссии 4. ФИО */
)
as
  nRN2              pkg_std.tref; 
  rV_Row            v_transinvdept%rowtype;
  nIncomeFromDeps   pkg_std.tref; 
  sAcatalog         Acatalog.name%type;

  sline01     constant varchar2(40) := '_sline01';
  sline02     constant varchar2(40) := '_sline02';
  sline03     constant varchar2(40) := '_sline03';
  scell       constant varchar2(40) := '_s';
  
  n           pkg_std.tnumber; 
  sVarchar    pkg_std.tstring; 
  bFlag       boolean := false;
begin
  prsg_excel.prepare;
  prsg_excel.sheet_select('Лист1');
  prsg_excel.line_describe(sline01);
  prsg_excel.line_describe(sline02);
  prsg_excel.line_describe(sline03);

  /* РН документа по selectlist */
  begin
    select document into nRN2 from selectlist where ident = nIDENT;
    exception
    when no_data_found then
      p_exception(0, 'Не найден документ с IDENT <%s>.', nIDENT);
    when too_many_rowS THEN
      p_exception(0, 'Отмечено больше одного документа с IDENT <%s>.', nIDENT);
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске документа с IDENT <%s>.', nIDENT);
  end;
  /* Считывание записи документа */
  begin
    select * into rV_Row from v_transinvdept where nrn = nRN2;
    exception
    when no_data_found then
      p_exception(0, 'Не найден документ с RN <%s> в разделе <%s>.'
                 ,nRN2
                 ,f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'TRANSINVDEPT')));
    when too_many_rowS THEN
      p_exception(0, 'Отмечено больше одного документа с RN <%s>.', nRN2);
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске документа с RN <%s>.', nRN2);
  end;
  /* Каталог */
  sAcatalog := get_acatalog_name_id(nflag_smart => 0, nrn => rV_Row.ncrn);

  /* Проверка */
  if sAcatalog not in ('Сборка, разборка') then
    p_exception(0, 'Отчёт предназначен для документов в каталоге <Сборка, разборка>. %s'
               ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rV_Row.nrn)); 
  end if;

  /* Описание ячеек заголовка */
  for Idx in 2 .. 7 loop
    prsg_excel.cell_describe(scell||lpad(to_char(Idx), 3, '0'));
  end loop;
  /* Заполнение ячеек заголовка */
  prsg_excel.cell_value_write(scell||'002', sAPPROVE_POST);                             /* Утверждаю. Должность */
  prsg_excel.cell_value_write(scell||'003', '______________________ / '||sAPPROVE_FIO); /* Утверждаю. ФИО */
  prsg_excel.cell_value_write(scell||'004', usr_f_date_to_str1(dAPPROVE_DATE));         /* Утверждаю. Дата */
  prsg_excel.cell_value_write(scell||'005', 'Акт о разукомплектации материала');        /* Документ. Наименование: "Акт о разукомплектации материала" */
  prsg_excel.cell_value_write(scell||'006', usr_f_date_to_str1(rV_Row.ddocdate));       /* Документ. Дата */
  /* ячейка 007 */
  sVarchar := strcombine(sVarchar, sCHAIRMAN_COMIS_1_POST, ';'||cr );
  sVarchar := strcombine(sVarchar, sCHAIRMAN_COMIS_1_FIO , ' ');
  sVarchar := strcombine(sVarchar, sMEMB_COMIS_2_POST    , ';'||cr );
  sVarchar := strcombine(sVarchar, sMEMB_COMIS_2_FIO     , ' ');
  sVarchar := strcombine(sVarchar, sMEMB_COMIS_3_POST    , ';'||cr );
  sVarchar := strcombine(sVarchar, sMEMB_COMIS_3_FIO     , ' ');
  sVarchar := strcombine(sVarchar, sMEMB_COMIS_4_POST    , ';'||cr );
  sVarchar := strcombine(sVarchar, sMEMB_COMIS_4_FIO     , ' ');
  sVarchar := 'Комиссия, назначенная приказом директора от '||usr_f_date_to_str1(rV_Row.dvalid_docdate)||' N '||rV_Row.svalid_docnumb||', в составе: '||cr||
              sVarchar||cr||
              'произвела разукомплектацию следующего товара:';
  prsg_excel.cell_value_write(scell||'007', sVarchar);

  /* Описание ячеек строки 1 */
  for Idx in 11 .. 16 loop
    prsg_excel.line_cell_describe(sline01, scell||lpad(to_char(Idx), 3, '0'));
  end loop;

  /* Заполнение ячеек строки 1 */
  for c in (select * from v_transinvdeptspecs where nprn = rV_Row.nrn)
  loop
    n := prsg_excel.line_append(sline01);
    prsg_excel.cell_value_write(scell||'011', 0, n, c.ssernumb);      /* Номенкла-турный номер */
    prsg_excel.cell_value_write(scell||'012', 0, n, c.snomenname);    /* Наименование материала */
    prsg_excel.cell_value_write(scell||'013', 0, n, c.smeas_main);    /* Ед. изм. */
    prsg_excel.cell_value_write(scell||'014', 0, n, c.nquant);        /* Коли-чество */
    prsg_excel.cell_value_write(scell||'015', 0, n, c.nprice);        /* Стоимость единицы материала, руб. */
    prsg_excel.cell_value_write(scell||'016', 0, n, c.nsummwithnds);  /* Стоимость всего, руб. */
  end loop;

  /* RN выходного Прихода из подразделений */
  nIncomeFromDeps := f_doclinks_link_out_doc(sin_unitcode  => 'GoodsTransInvoicesToDepts'
                                            ,nin_document  => rV_Row.nrn
                                            ,sout_unitcode => 'IncomFromDeps');

  /* Описание ячеек строки 2 */
  for Idx in 21 .. 26 loop
    prsg_excel.line_cell_describe(sline02, scell||lpad(to_char(Idx), 3, '0'));
  end loop;

  /* Заполнение ячеек строки 2 */
  for c in (select * from v_incomefromdepsspec where nprn = nIncomeFromDeps)
  loop
    n := prsg_excel.line_append(sline02);
    prsg_excel.cell_value_write(scell||'021', 0, n, c.ssernumb);      /* Номенкла-турный номер */
    prsg_excel.cell_value_write(scell||'022', 0, n, c.snomenname);    /* Наименование материала */
    prsg_excel.cell_value_write(scell||'023', 0, n, c.smeas_main);    /* Ед. изм. */
    prsg_excel.cell_value_write(scell||'024', 0, n, c.nquant_fact);   /* Коли-чество */
    prsg_excel.cell_value_write(scell||'025', 0, n, c.nprice);        /* Стоимость единицы материала, руб. */
    prsg_excel.cell_value_write(scell||'026', 0, n, c.nsumm_fact);    /* Стоимость всего, руб. */
    bFlag := true; 
  end loop;

  /* Проверка заполненноссти спецификации Прихода из подразделений */
  if not bFlag then
    p_exception(0, 'Не заполнена спецификация связанного документа в разделе <%s>. %s'
               ,f_unitlist_getname(get_unitlist_code_table(1, 'INCOMEFROMDEPS'))
               ,cr||f_docdescrs_get_description('GoodsTransInvoicesToDepts', rV_Row.nrn)); 
  end if;

  /* Описание ячеек для председателя комиссии */
  for Idx in 31 .. 32 loop
    prsg_excel.cell_describe(scell_name => scell||lpad(to_char(Idx), 3, '0'));
  end loop;

  /* Заполнение ячеек председателя комиссии */
  prsg_excel.cell_value_write(scell||'031', sCHAIRMAN_COMIS_1_POST);  /* Председатель комиссии 1. Должность */
  prsg_excel.cell_value_write(scell||'032', sCHAIRMAN_COMIS_1_FIO);   /* Председатель комиссии 1. ФИО */

  /* Описание ячеек строки 3 */
  for Idx in 33 .. 34 loop
    prsg_excel.line_cell_describe(sline03, scell||lpad(to_char(Idx), 3, '0'));
  end loop;

  /* Заполнение ячеек строки 3 */
  for c in (
            select a.sPost, a.sFIO
              from (
                    select sMEMB_COMIS_2_POST as sPost, sMEMB_COMIS_2_FIO as sFIO
                      from dual 
                     where sMEMB_COMIS_2_POST||sMEMB_COMIS_2_FIO is not null
                    union 
                    select sMEMB_COMIS_3_POST as sPost, sMEMB_COMIS_3_FIO as sFIO
                      from dual 
                     where sMEMB_COMIS_3_POST||sMEMB_COMIS_3_FIO is not null
                    union 
                    select sMEMB_COMIS_4_POST as sPost, sMEMB_COMIS_4_FIO as sFIO
                      from dual 
                     where sMEMB_COMIS_4_POST||sMEMB_COMIS_4_FIO is not null
                   ) a
           )             
  loop
    n := prsg_excel.line_append(sline03);
    prsg_excel.cell_value_write(scell||'033', 0, n, c.sPost);   /* Член комиссии N. Должность */
    prsg_excel.cell_value_write(scell||'034', 0, n, c.sFIO);    /* Член комиссии N. ФИО */
    n := prsg_excel.line_append(sline03);                       /* дополнительная строка */
  end loop;

  /* Очистка */
  prsg_excel.line_delete(sline01);
  prsg_excel.line_delete(sline02);
  prsg_excel.line_delete(sline03);
  
end USR_P_REP_ACT_DECOUPLING;
/
