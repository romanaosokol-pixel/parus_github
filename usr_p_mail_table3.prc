create or replace procedure usr_p_mail_table3
(
  pin_list_mail in varchar2
 ,pin_mol       in varchar2 default null
 ,pin_tema      in varchar2 default null
)

 is

  /*
  Рассылка таблицы в HTML формате таблицы с перечнем договоров у которых
  
  Сумма этапа c налогами stages.stage_sumtax
  не равна сумме запланированных платежей (
  
  
  */
  v_mail_html clob := '<head>';
  v_style     varchar2(2000);

  v_table_head varchar2(2000); --- описание характеристик столбцов

  v_table_caption varchar2(225) := pin_tema ||
                                   'Сумма этапа не равна сумме запланированных платежей, что приводит к ошибкам планирования денежных потоков!'; --- Заголовок таблицы

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

  v_mail_html := v_mail_html || '<h1>' || pin_tema || 'Отчет "Ошибки в Договорах" составлен ' ||
                 to_char(sysdate
                        ,'DD.MM.YYYY HH24:Mi:ss') || '</h1>';

  v_table_head := '<table> <tbody>';

  v_mail_html := v_mail_html || v_table_head || cr;

  v_mail_html := v_mail_html || '<caption>' || v_table_caption || '</caption>' || cr;

  v_table_th := '<tr>
        <th>Экономист</th>
        <th>Условное наименование</th>
        <th>RN Договора</th>
        <th>Префикс</th>
        <th>Номер</th>
        <th>Дата</th>
        <th>Номер этапа</th>
        <th>Сумма <br>запланированных <br>платежей <br>(из графиков <br>платежей)</th>
        <th>Сумма этапа</th>
        <th>Расхождение</th>
    </tr>';

  v_mail_html := v_mail_html || v_table_th || cr;

  --- Заполняем таблицу

  for cur in (with cnt3 as
                 (select (select nvl(sum(gr.pay_sum * (1 - 2 * gr.inexp_sign))
                                   ,0)
                           from fcacpayplans gr
                          where gr.prn = st.faceacc) calc_sum
                       ,st.stage_sumtax stage_sum --- т.к. в графике сумма с НДС
                       ,trim(st.numb) stage_nmb
                       ,dog.rn dog_rn
                       ,trim(dog.doc_pref) dog_prf
                       ,trim(dog.doc_numb) dog_nmb
                       ,to_char(dog.doc_date
                               ,'DD.MM.YYYY') dog_date
                       ,cat.name catalog
                       ,(select nvl(sum(gr.pay_sum * (1 - 2 * gr.inexp_sign))
                                   ,0)
                           from fcacpayplans gr
                           join stages stf
                             on stf.faceacc = gr.prn
                          where stf.prn = dog.rn) sum_gr_dog
                       ,(select sum(stage_sumtax) from stages sts where sts.prn = dog.rn) sum_st_dog
                   from contracts dog
                   join stages st
                     on st.prn = dog.rn
                   join faceacc f
                     on f.rn = st.faceacc
                   join fpdartcl fo
                     on fo.rn = f.ieelement
                   join diciearts cl
                     on cl.rn = fo.iearticle
                   join acatalog cat
                     on cat.rn = dog.crn
                   join fpdartcl sz
                     on sz.rn = f.ieelement
                 
                  where dog.status = 1 --- Утвержденные
                    and cl.code = 'Доход' -- Договора поставки
                    and usr_F_get_stage_status(st.rn) != 'Закрыт' --- Статус этапа нашей функцией
                    and st.sign_sum = 1 -- Отражается на сумме Договора
                    and sz.code in ('Темат. доходы_Б'
                                   ,'Продажа товаров вСНГ'
                                   ,'Расходы на КА_Б'
                                   ,'Прочие тем.расходы_Б'
                                   ,'Расходы на иниц._Б'
                                   ,'Субсидии на разработки_Б')
                       /*По всем или одному МОЛ*/
                    and (pin_mol is null or pin_mol = usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 1082887
                                                                                         ,sunitcode => 'Contracts'
                                                                                         ,ndocument => dog.rn)))
                
                select nvl(usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Сотрудник'
                                                              ,sunitcode  => 'Contracts'
                                                              ,ndocument  => cnt3.dog_rn)
                          ,cnt3.catalog) otv
                      ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Условное наименовани'
                                                          ,sunitcode  => 'Contracts'
                                                          ,ndocument  => cnt3.dog_rn) usl_name
                       
                      ,cnt3.dog_rn
                      ,cnt3.dog_prf
                      ,cnt3.dog_nmb
                      ,cnt3.dog_date
                      ,cnt3.stage_nmb
                      ,trim(to_char(cnt3.calc_sum
                                   ,'999G999G999G999G990D00'
                                   ,'NLS_NUMERIC_CHARACTERS='', ''')) calc_sum
                      ,trim(to_char(cnt3.stage_sum
                                   ,'999G999G999G999G990D00'
                                   ,'NLS_NUMERIC_CHARACTERS='', ''')) stage_sum
                      ,trim(to_char(cnt3.stage_sum - cnt3.calc_sum
                                   ,'999G999G999G999G990D00'
                                   ,'NLS_NUMERIC_CHARACTERS='', ''')) delta
                  from cnt3
                 where abs(cnt3.calc_sum - cnt3.stage_sum) > 99
                   and abs(cnt3.sum_gr_dog - cnt3.sum_st_dog) > 99
                 order by abs(cnt3.stage_sum - cnt3.calc_sum) desc)
  
  loop
    v_mail_html := v_mail_html || '<tr>' || '<td>' || cur.otv || '</td>' || '<td>' || cur.usl_name || '</td>' || '<td>' || cur.dog_rn ||
                   '</td>' || '<td>' || cur.dog_prf || '</td>' || '<td>' || cur.dog_nmb || '</td>' || '<td>' || cur.dog_date || '</td>' ||
                   '<td>' || cur.stage_nmb || '</td>' || '<td>' || cur.calc_sum || '</td>' ||
                  --'<td style = ''''text-align:right''''>' || cur.stage_sum || '</td>' ||
                  --'<td style = ''''text-align:right''''>' || cur.delta || '</td>' || '</tr>';
                   '<td>' || cur.stage_sum || '</td>' || '<td>' || cur.delta || '</td>' || '</tr>';
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
      ,to_char(sysdate
              ,'DD.MM.YYYY') || '.html'
      ,v_mail_html);
  
    pkg_exs_ext_mail.send_by_list(sto_list           => pin_list_mail --;a.kuroedova@module.ru;k.bykova@module.ru
                                 , -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                  stitle             => 'Ошибки в Договорах. Сумма этапа не равна сумме графика отгрузки'
                                 , -- Тема
                                  ctext              => v_mail_html
                                 ,nfile_buffer_ident => v_idn
                                 , -- Прикладываемые документы (идентификатор файлового буфера)
                                  nformat            => pkg_exs_ext_mail.nformat_html);
  else
    if pin_mol is null
    then
      -- Сообщение об отсутствие ошибки посылаем только если конкретный МОЛ не задан 
      pkg_exs_ext_mail.send_by_list(sto_list           => pin_list_mail --;a.kuroedova@module.ru;k.bykova@module.ru
                                   , -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                    stitle             => 'Не обнаружены ошибки в Договорах. Сумма этапа не равна сумме графика отгрузки'
                                   , -- Тема
                                    ctext              => 'На ' || to_char(sysdate
                                                                          ,'DD.MM.YYYY') || ' ошибки не обнаружены.'
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
