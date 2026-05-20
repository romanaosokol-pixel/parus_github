create or replace procedure usr_p_dpos_reserve_delete
/*
Раздел: "Заказы подразделений (спецификация)"
Процедура: Снять резервирование
28/10/2025 Степанов М.
create public synonym usr_p_dpos_reserve_delete for usr_p_dpos_reserve_delete;
grant execute on usr_p_dpos_reserve_delete to public;
*/
(
 nRN          in number
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'usr_p_dpos_reserve_delete');

  /* По активным записям журнала резервирования */
  for c in (
            select a.*
              from departmentords   t
              join udo_depords_prf  a  on a.dordsp  = t.rn
              join resjournal       rj on a.rsrv    = rj.rn
               and rj.res_end_date  is null
             where t.rn = nRN
           )
  loop
    /* Попытка снятия резерва */
    begin
      udo_pkg_resjournal_ctrl.take_by_dords( ndocument => c.rsrv, ndocument_parent => c.dordsp );
    exception when others then
      /* Если ошибка "Резерв включен в КВ...", то переходим к следующей записи */
      if sqlerrm like '%Резерв включен в КВ%' then
        continue;
      else
        /* Иначе ошибка */
        raise;
      end if;
    end;
  end loop;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end;
/
