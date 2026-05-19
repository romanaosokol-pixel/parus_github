create or replace function usr_f_vedzam_constr_rn(nrn udo_deporddir.rn%type) return number is

begin
/* 
Городецкий 07-05-2025 Функция поиска конструктора по RN строки ведомости замен.
Конструктор заносится в поле "Разработал" материального ресурса головного изделия 
*/
  for cons in (with zp as
                  (select vz.depord
                    from udo_deporddir vz
                   where vz.rn = nrn
                  union all
                  select udp.depord
                    from udo_deporddir_depord udp
                   where udp.prn = nrn)
                 
                 select distinct siz.developed -- Конструктор
                   from zp
                   join doclinks dl2
                     on dl2.out_document = zp.depord -- RN Заказа подразделений
                    and dl2.out_unitcode = 'DepartmentsOrders'
                    and dl2.in_unitcode = 'CostProductExpenseActs'
                   join doclinks dl1
                     on dl1.out_document = dl2.in_document
                    and dl1.out_unitcode = 'CostProductExpenseActs'
                    and dl1.in_unitcode = 'ProductionOrders'
                   join productords dp
                     on dp.prn = dl1.in_document
                   join fcmatresource mr --- Изделия может и не быть (опережающая закупка), но нет изделия, нет и конструктора
                     on mr.nomen_modif = dp.nom_modif
                   join fcprodlst siz
                     on siz.mtr_res = mr.rn
                  where zp.depord is not null
                 
                 union all
                 
                 select siz.developed
                 
                   from zp
                   join doclinks dl1
                     on dl1.out_document = zp.depord -- RN Заказа подразделений
                  and dl1.out_unitcode = 'DepartmentsOrders'
                  and dl1.in_unitcode = 'ProductionOrders'
                   join productords dp
                     on dp.prn = dl1.in_document
                   join fcmatresource mr --- тут изделие есть всегда, т.к. есть заказ на производство
                     on mr.nomen_modif = dp.nom_modif
                   join fcprodlst siz
                     on siz.mtr_res = mr.rn
                  where zp.depord is not null)
  loop
    return cons.developed;
  end loop;

  return null;

end;
/
