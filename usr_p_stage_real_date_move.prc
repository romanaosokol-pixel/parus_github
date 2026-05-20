create or replace procedure usr_p_stage_real_date_move(rec_date date) is

  /*declare
  
  rec_date date := to_date('01-01-2026', 'DD.MM.YYYY');*/

  v_sv_rn      docs_props_vals.rn%type;
  rec_date_max date;

begin

---P_exception(0,'Процедура в разработке!');

  /*Задаем параметр "ДАТА" */

  /* ПЕРВЫЙ ЭТАП */

  /*Обираем этары договоров у которых:
  1. Этап открыт
  2. Тип этапа "Продажа"
  3. Есть графики отпуска
  4. У графика отпуска колонка "#Осталось отгрузить" не равна 0
  5. В свойстве графика отпуска "БЮДЖЕТ дата накладной(ожидаемая)"  стоит дата > 01-01-2025 или пустая дата
  
  
  /* Действия с отобранными записями */

  /*
  
   1.  Если дата в свойстве "БЮДЖЕТ дата накладной(ожидаемая)" не пустая, то она заполняется значением парметра "ДАТА"
   2.  Если дата в свойстве "БЮДЖЕТ дата накладной(ожидаемая)" пустая, то она заполняется наибольшей датой из (даты окончания графика и датой, заданной в параметре «ДАТА»
  
  */

  /* ВТОРОЙ ЭТАП */

  /*Обираем этары договоров у которых:
   1. Этап открыт
   2. Тип этапа "Продажа"
   3. НЕТ графика отпуска
   4. В свойстве этапа "БЮДЖЕТ дата акта (ожидаемая)"  стоит дата > 01-01-2025 или пустая дата
  
  /* Действия с отобранными записями */

  /*
  
  
 	1.	Если НЕ заполнено свойство этапа "БЮДЖЕТ дата акта (ожидаемая)", то в него записывается дата окончания этапа.
  2.	Если Заполнено свойство этапа "БЮДЖЕТ дата акта (ожидаемая)", то в него записывается дата окончания этапа.
            a.	Если по этапу договора были акты (В поле "Оказано услуг фактически" стоит не 0), то в свойство этапа "БЮДЖЕТ дата акта (ожидаемая)" записываем дату последнего акта по данному этапу
b.	Если по этапу договора НЕ БЫЛО актов (В поле "Оказано услуг фактически" стоит 0), то в свойство этапа "БЮДЖЕТ дата акта (ожидаемая)" заполняется значением параметра «ДАТА»


  
  */

  for cur1 in (
               
               select gr.rn
                      ,st.end_date
                      ,usr_pkg_docs_props_vals.get_val_date(ndoc_prop => 7526416, sunitcode => 'FaceAccountsOperOutPlans', ndocument => gr.rn) data_sv /*'Реальная дата' (БЮДЖЕТ дата накладной (ожидаемая))*/
                      ,f.numb
               
                 from fcacoperplans gr
                 join stages st
                   on st.faceacc = gr.prn
                 join faceacc f
                   on f.rn = st.faceacc
                where gr.inexp_sign = 1
                  and st.status = 1
                  and f.acc_kind = 1
                  and udo_f_fcacoperplans_transremn(nrn => gr.rn, nquant => gr.quant) != 0
                  and nvl(usr_pkg_docs_props_vals.get_val_date(ndoc_prop => 7526416
                                                              ,sunitcode => 'FaceAccountsOperOutPlans'
                                                              ,ndocument => gr.rn)
                         ,to_date('01-01-2025', 'DD.MM.YYYY')) >= to_date('01-01-2025', 'DD.MM.YYYY')
               
               )
  loop
    /*Сохраним старое значение*/
    insert into usr_tab_date_remove_log
      (rn
      ,data_sv
      ,numb_fc)
    values
      (cur1.rn
      ,cur1.data_sv
      ,cur1.numb);
  
    if cur1.data_sv is not null
    then
      pkg_docs_props_vals.modify(sproperty   => 'Реальная дата'
                                ,sunitcode   => 'FaceAccountsOperOutPlans'
                                ,ndocument   => cur1.rn
                                ,sstr_value  => null
                                ,nnum_value  => null
                                ,ddate_value => rec_date
                                ,nrn         => v_sv_rn);
    else
      pkg_docs_props_vals.modify(sproperty   => 'Реальная дата'
                                ,sunitcode   => 'FaceAccountsOperOutPlans'
                                ,ndocument   => cur1.rn
                                ,sstr_value  => null
                                ,nnum_value  => null
                                ,ddate_value => greatest(cur1.end_date, rec_date)
                                ,nrn         => v_sv_rn);
    
    end if;
  
  end loop;

  for cur2 in (
               
               select st.rn
                      ,st.numb st_numb
                      ,f.rn frn
                      ,f.numb
                      ,usr_pkg_docs_props_vals.get_val_date(ndoc_prop => 7526416, sunitcode => 'ContractsStages', ndocument => st.rn) data_sv
                      ,f.fact_serv
                      ,st.end_date
                 from stages st
                 join faceacc f
                   on f.rn = st.faceacc
                where st.status = 1
                  and f.acc_kind = 1
                  and not exists
                (select null from fcacoperplans gr where gr.prn = st.faceacc)
                  and nvl(usr_pkg_docs_props_vals.get_val_date(ndoc_prop => 7526416, sunitcode => 'ContractsStages', ndocument => st.rn)
                         ,to_date('01-01-2025', 'DD.MM.YYYY')) >= to_date('01-01-2025', 'DD.MM.YYYY'))
  loop
  
    /*Сохраним старое значение*/
    insert into usr_tab_date_remove_log
      (stage_rn
      ,data_sv
      ,numb_fc)
    values
      (cur2.rn
      ,cur2.data_sv
      ,cur2.numb);
  
   case when  cur2.data_sv is null then 
   
    pkg_docs_props_vals.modify(sproperty   => 'Реальная дата'
                                ,sunitcode   => 'ContractsStages'
                                ,ndocument   => cur2.rn
                                ,sstr_value  => null
                                ,nnum_value  => null
                                ,ddate_value => cur2.end_date
                                ,nrn         => v_sv_rn);
    
    
     when  cur2.fact_serv = 0    then
    
      pkg_docs_props_vals.modify(sproperty   => 'Реальная дата'
                                ,sunitcode   => 'ContractsStages'
                                ,ndocument   => cur2.rn
                                ,sstr_value  => null
                                ,nnum_value  => null
                                ,ddate_value => rec_date
                                ,nrn         => v_sv_rn);
    
    else 
    
      /*найдем дату последнего акта*/
    
      select nvl(max(n.docdate), rec_date) into rec_date_max from transinvcust n where n.faceacc = cur2.frn;
    
      pkg_docs_props_vals.modify(sproperty   => 'Реальная дата'
                                ,sunitcode   => 'ContractsStages'
                                ,ndocument   => cur2.rn
                                ,sstr_value  => null
                                ,nnum_value  => null
                                ,ddate_value => rec_date_max
                                ,nrn         => v_sv_rn);
    
    end case;
  
  end loop;

end;
/
