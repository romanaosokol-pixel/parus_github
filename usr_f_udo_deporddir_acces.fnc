create or replace function usr_f_udo_deporddir_acces(nrn udo_deporddir.rn%type, sauthid userlist.authid%type default utilizer) return number as

/*
  Городецкий О.И.
  29-04-2025

  Передается логин пользователя,
  Если заголовок ведомости замен UDO_DEPORDDIR пользователю доступен , то возвращается Код доступа для права согласования ведомости замен

  0  - Действие недоступно
  1  - Пользователь иаемм роль "Все права"
  10 - Пользователь есть в исполнителях проекта, у которых установлен признак "Ведомость замен" и нет записи Проекты Ответсвенные Изделия
  20 - Пользователь есть в исполнителях проекта и в записи  Проекты Ответсвенные Изделия (Головное) равно Головному изделию Ведомости замен
  30 - У данного матресурса Ведомости замен пользователь является Конструктором (в спецификации изделия контрагент сотрудника задан в поле Разработал

  */

  nfl       number(1) := 0;
  v_sotr_rn clnpersons.rn%type := usr_f_clnpersons_user(sauthid => sauthid ); ---RN сотрудника которым инициализирован текущий пользовтаель

begin
  --- 0. Если пользователь "Все права", то вренем 1

  for a in (select r.rn
              from userroles ur
              join roles r
                on r.rn = ur.roleid
             where ur.authid = sauthid
               and r.rolename = 'Все права') 
  loop

    return 1; -- Разрешено по праву роли

  end loop;

  --- Найдем RN проектов, по которым сделана ведомость замен

  for prj in (select distinct prs.prn
                             ,t.depord zp_rn
                from udo_deporddir t
                join departmentord d
                  on d.rn = t.depord
                join projectstage prs
                  on prs.faceacc = d.faceacc
               where t.rn = nrn

              union all

              select distinct prs.prn
                             ,t.depord zp_rn
                from udo_deporddir_depord t
                join departmentord d
                  on d.rn = t.depord
                join projectstage prs
                  on prs.faceacc = d.faceacc
               where t.prn = nrn)

  loop

    -- 1. проверим, что пользователь есть в исполнителях проекта, у которых установлен признак "Ведомость замен" и нет записи Проекты Ответсвенные Изделия
    begin

      select 1
        into nfl
        from udo_prjexec_list prl
       where prl.prn = prj.prn
         and prl.sign_vzamen = 1 --- Доступны ведомости замен
         and prl.person = v_sotr_rn
         and not exists (select 1 from udo_prjexeclst_article z where z.prn = prl.rn)
         and rownum = 1;

    exception
      when no_data_found then
        nfl := 0;

    end;

    if nfl = 1 then
      return 10;
    end if; --- Показываем ведомость замен (по правилу 1)

    -- 2. Проверим что пользователь есть в исполнителях проекта и в записи  Проекты Ответсвенные Изделия (Головное) равно Головному изделию Ведомости замен
    --- Цикл по изделиям заказов подразделений, которые меняет ведомость замен (их может быть несколько (во всяком случае пока не ввели запрет))
    for izd in (

                select mr.rn as nmr --- Мат ресурс (изделие) по Заказу подразделения, созданному из "Потребности и акты расхода производства изделий"
                       ,dp.rn zps_rn --- RN Заказа на производство (спецификация)
                  from doclinks dl2
                  join doclinks dl1
                    on dl1.out_document = dl2.in_document
                   and dl1.out_unitcode = 'CostProductExpenseActs'
                   and dl1.in_unitcode = 'ProductionOrders'
                  join productords dp
                    on dp.prn = dl1.in_document
                  left join fcmatresource mr --- Изделия может и не быть (опережающая закупка)
                    on mr.nomen_modif = dp.nom_modif
                 where dl2.out_document = prj.zp_rn -- RN Заказа подразделений
                   and dl2.out_unitcode = 'DepartmentsOrders'
                   and dl2.in_unitcode = 'CostProductExpenseActs'

                union all

                select mr.rn as mr_izd --Мат ресурс (изделие) по Заказу подразделения, созданному напрямую из Заказа на производство
                       ,dp.rn zps_rn --- RN Заказа на производство (спецификация)
                  from doclinks dl1
                  join productords dp
                    on dp.prn = dl1.in_document
                  join fcmatresource mr --- тут изделие есть всегда, т.к. есть заказ на производство
                    on mr.nomen_modif = dp.nom_modif
                 where dl1.out_document = prj.zp_rn -- RN Заказа подразделений
                   and dl1.out_unitcode = 'DepartmentsOrders'
                   and dl1.in_unitcode = 'ProductionOrders')

    loop

      begin
        select 1
          into nfl
          from udo_prjexec_list prl
          join udo_prjexeclst_article z
            on z.prn = prl.rn
         where prl.prn = prj.prn
           and prl.sign_vzamen = 1
           and prl.person = v_sotr_rn
           and z.matres = izd.nmr
           and rownum = 1;

      exception
        when no_data_found then
          nfl := 0;

      end;

      if nfl = 1 then
        return 20;
      end if; --- Показываем ведомость замен (по правилу 2)

      --- 3. Если у данного матресурса пользователь является Конструктором (в спецификации изделия контрагент сотрудника задан в поле Разработал, то вернем 1
      begin
        select 1
          into nfl
          from productords zps
          join fcprodcmpsp ps
            on ps.prn = zps.prodcmp
          join fcprodlst mrs
            on mrs.mtr_res = ps.mtr_res
         where zps.rn = izd.zps_rn
           and ps.mtr_res = izd.nmr
           and mrs.developed = (select cp.pers_agent from clnpersons cp where cp.rn = v_sotr_rn);
      exception
        when no_data_found then
          nfl := 0;
      end;

      if nfl = 1 then
        return 30;
      end if; --- Показываем ведомость замен (по правилу 3)

    end loop;

  end loop;

  return 0; -- Не нашли прав подписать Ведомость замен
end;
/
