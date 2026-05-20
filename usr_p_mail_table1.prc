create or replace procedure usr_p_mail_table1(pin_list_mail in varchar2,
                                              PIN_MOL in varchar2 default null,
                                              PIN_TEMA in varchar2  default null)

 is

  /*
  Рассылка таблицы в HTML формате таблицы с перечнем договоров у которых
  
  Сумма этапа c налогами stages.stage_sumtax
  не равна сумме запланированных платежей (
  
  
  */
  v_mail_html clob := '<head>';
  v_style     varchar2(2000);

  v_table_head varchar2(2000); --- описание характеристик столбцов

  v_table_caption varchar2(225) := ' '; --- Заголовок таблицы

  v_table_th varchar2(2000); --- Наименование заголовков столбцов таблицы

  v_idn number(17);

  nfl integer := 0;

  ---V_LIST_MAIL varchar2(255):='o.gorodetskiy@module.ru;k.bykova@module.ru;a.kuroedova@module.ru';

begin

  v_mail_html := '<head>' || cr;

  v_style := '<Style>
body {

    justify-content: center;
    padding: 5px;
    background-color: #ffffff;
    color: #18191C;
    font-family: "Roboto", sans-serif;
  }

table {

  border-top: 1px solid black;
  border-collapse: collapse;
  margin-bottom: 2px;
  border: 1px solid #dddddd;
}

td {

  padding: 1px;
  border: 1px solid black;
}

    td:nth-child(1) {
        width: 130px;
    text-align: left;
    }

    td:nth-child(2) {
        width: 160px;
        text-align: left;
    }

  td:nth-child(3) {
        width: 60px;
        text-align: right;
    }

  td:nth-child(4) {
        width: 50px;
        text-align: center;
    }

  td:nth-child(5) {
        width: 100px;
        text-align: center;
    }

  td:nth-child(6) {
        width: 100px;
        text-align: center;
    }
  td:nth-child(7) {
        width: 100px;
        text-align: center;
    }      

  td:nth-child(8) {
        width: 140px;
        text-align: right;
    }

  td:nth-child(9) {
        width: 140px;
        text-align: right;
    }

  td:nth-child(10) {
        width: 140px;
        text-align: right;
    }

 th {
  text-align: center;
  padding: 10px;
  border: 1px solid black;
 }

 caption{
 text-align: center;
 font-weight: bold;
 }
</Style>';

  v_mail_html := v_mail_html || v_style || cr;

  v_mail_html := v_mail_html || '<h1>' || PIN_TEMA||'Отчет "Ошибки в Договорах. Стоимость по калькуляции не равна стоимости отгрузки". составлен ' ||
                 to_char(sysdate, 'DD.MM.YYYY HH24:Mi:ss') || ' <br>Неисправленные ошибки могут привести к ошибкам планирования валовой прибыли бюджетов расходов и доходов.'||'</h1>';

  v_table_head := '<table> <tbody>';

  v_mail_html := v_mail_html || v_table_head || cr;

  v_mail_html := v_mail_html || '<caption>' || v_table_caption || '</caption>' || cr;

  v_table_th := '<tr>
        <th>Экономист</th>
        <th>Условное наименование проекта</th>
        <th>RN Договора</th>
        <th>Префикс договора</th>
        <th>Номер договора</th>       
        <th>Номер этапа</th>
        <th>Номер строки графика отпуска товаров и услуг</th>
        <th>Стоимость по калькуляции (Цена с НДС * Кол-во графика отпуска товаров и услуг)</th>
        <th>Сумма строки графика отпуска товаров и услуг</th>
        <th>Расхождение</th>
    </tr>';

  v_mail_html := v_mail_html || v_table_th || cr;

  --- Заполняем таблицу

  for cur in (with cnt as
                 (select Gr.Summwithnds GR_sum
                       ,(select sum(cl.cost_plan * gr.quant * (1 - gr.discount / 100) )
                           from  FCACOPERPLANSCLC cl                             
                           join fpdartcl fp
                             on fp.rn = cl.cost_article
                          where cl.prn = gr.rn                             
                            and fp.code = 'Цена с НДС'
                            and fp.version = 91451)  calc_sum
                       ,trim(GR.numb) GR_nmb
                       ,trim(st.numb) stage_nmb
                       ,dog.rn dog_rn
                       ,trim(dog.doc_pref) dog_prf
                       ,trim(dog.doc_numb) dog_nmb                     
                       ,st.faceacc
                   from contracts dog
                   join stages st
                     on st.prn = dog.rn
                   join faceacc f
                     on f.rn = st.faceacc
                   join acatalog cat
                     on cat.rn = dog.crn
                   join fpdartcl sz
                     on sz.rn = f.ieelement
                   left join fcacoperplans gr on gr.prn = F.rn  and gr.inexp_sign = 1
                 
                  where dog.status = 1 --- Утвержденные
                    and dog.crn != 58774176 --- Исключили каталог "Исполненные"
                    and st.sign_sum = 1 -- Отражается на сумме Договора
                    /*По всем или одному МОЛ*/
                    and (PIN_MOL is null or 
                    PIN_MOL = usr_pkg_docs_props_vals.get_val_str(nDOC_PROP => 1082887, sunitcode => 'Contracts', ndocument => dog.rn))
                    
                    and  gr.discount = 0 --- Временно исключили договора со скидкой (от такой 1 => Договор, 1/23-32, 27.12.2023)
                    and usr_F_get_stage_status(st.rn) != 'Закрыт' --- Статус по нашей колонке
                    and sz.code in ('Темат. доходы_Б'
                                   ,'Продажа товаров вСНГ'
                                   ,'Расходы на КА_Б'
                                   ,'Прочие тем.расходы_Б'
                                   ,'Расходы на иниц._Б'
                                   ,'Субсидии на разработки_Б'))
                select
                
                 usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Сотрудник', sunitcode => 'Contracts', ndocument => cnt.dog_rn) otv
                ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Условное наименовани'
                                                    ,sunitcode  => 'Contracts'
                                                    ,ndocument  => cnt.dog_rn) usl_name
                ,cnt.dog_rn
                ,cnt.dog_prf
                ,cnt.dog_nmb                
                ,cnt.stage_nmb
                ,cnt.gr_nmb
                ,trim(to_char(cnt.calc_sum, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''')) calc_sum
                ,trim(to_char(cnt.GR_sum, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''')) GR_sum
                ,trim(to_char(cnt.GR_sum - cnt.calc_sum, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS='', ''')) delta
                  from cnt
                 where nvl(cnt.calc_sum, 0) != 0
                   and cnt.calc_sum is not null
                   and abs(cnt.GR_sum - cnt.calc_sum) > 99
                 order by abs(cnt.GR_sum - cnt.calc_sum) desc)
  
  loop
    v_mail_html := v_mail_html || '<tr>' || '<td>' || cur.otv || '</td>' || '<td>' || cur.usl_name || '</td>' || '<td>' || cur.dog_rn ||
                   '</td>' || '<td>' || cur.dog_prf || '</td>' || '<td>' || cur.dog_nmb || '</td>' ||  '<td>' || cur.stage_nmb || '</td>' ||
                    '<td>' || cur.gr_nmb || '</td>' ||'<td>' || cur.calc_sum || '</td>' ||
                  --'<td style = ''''text-align:right''''>' || cur.GR_sum || '</td>' ||
                  --'<td style = ''''text-align:right''''>' || cur.delta || '</td>' || '</tr>';
                   '<td>' || cur.GR_sum || '</td>' || '<td>' || cur.delta || '</td>' || '</tr>';
    nfl         := 1;
  
  end loop;

  if nfl = 1
  then
    ---Завершаем таблицу
    v_mail_html := v_mail_html || '</tbody> </table>';
  
    v_idn := gen_ident;
  
    delete from file_buffer b where b.filename like '%html';
  
    insert into file_buffer
      (ident
      ,filename
      ,data)
    values
      (v_idn
      ,to_char(sysdate, 'DD.MM.YYYY') || '.html'
      ,v_mail_html);
  
    pkg_exs_ext_mail.send_by_list(sto_list           => pin_list_mail --;a.kuroedova@module.ru;k.bykova@module.ru
                                 , -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                  stitle             => 'Ошибки в Договорах. Сумма калькуляции графика отгрузки не равна сумме этапа'
                                 , -- Тема
                                  ctext              => v_mail_html
                                 ,nfile_buffer_ident => v_idn
                                 , -- Прикладываемые документы (идентификатор файлового буфера)
                                  nformat            => pkg_exs_ext_mail.nformat_html);
  else
  if PIN_MOL is null then -- Сообщение об отсутствие ошибки посылаем только если конкретный МОЛ не задан 
    pkg_exs_ext_mail.send_by_list(sto_list           => pin_list_mail --;a.kuroedova@module.ru;k.bykova@module.ru
                                 , -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                  stitle             => 'Не обнаружены ошибки в Договорах. Сумма калькуляции графика отгрузки не равна сумме этапа'
                                 , -- Тема
                                  ctext              => 'На ' || to_char(sysdate, 'DD.MM.YYYY') || ' ошибки не обнаружены.'
                                 ,nfile_buffer_ident => null
                                 , -- Прикладываемые документы (идентификатор файлового буфера)
                                  nformat            => pkg_exs_ext_mail.nformat_text);
   else 
     return;
   end if;                               
  
  end if;

  dbms_lob.freetemporary(v_mail_html);

  ----
  --- Файл письма
  /*insert into usr_tab_tmp_lob
  (RN, CLOB_VAL)
  values
  (gen_id, v_mail_html);*/

end;
/
