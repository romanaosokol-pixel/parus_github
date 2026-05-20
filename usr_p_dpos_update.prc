create or replace procedure USR_P_DPOS_UPDATE
/*
Заказ подразделения. Спецификация. Исправление
Если значение какого-либо параметра не задано, то используется текущее значение
08/04/2022 Степанов М.
*/
(
 nRN          in number
,sNOMEN       in varchar2
,sMODIF       in varchar2
,sCOMMENTS    in varchar2
,nQUANT       in number
)
is
  nrn2              pkg_std.tref := nRN;
  rV_Spec           v_departmentords%rowtype;
  bExistsAllRights  boolean := false;
  
  nNumber           pkg_std.tnumber; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_DPOS_UPDATE');

  /* Считывание текущей записи и заголовка */
  select * into rV_Spec from v_departmentords where nrn = nrn2;

  /* Наличие у пользователя роли 'Все права' */
  for c in (select null from userroles where authid = utilizer and roleid = 90519)
  loop
    bExistsAllRights := true;
    exit;
  end loop;

  /* Изменяется номенклатура */
  if sNOMEN is not null and not bExistsAllRights then
    p_exception(0, 'Запрещено изменять номенклатуру. %s%s'
               ,cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrdersSpecs', ndocument => rV_Spec.nrn)
               ,cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrders', ndocument => rV_Spec.nprn));
  end if;
  /* Изменяется модификация */
  if sMODIF is not null and not bExistsAllRights then
    p_exception(0, 'Запрещено изменять модификацию. %s%s'
               ,cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrdersSpecs', ndocument => rV_Spec.nrn)
               ,cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrders', ndocument => rV_Spec.nprn));
  end if;

  /* Изменяется количество */
  if nQUANT is not null then
    if not bExistsAllRights then
      p_exception(0, 'Запрещено изменять количество. %s%s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrdersSpecs', ndocument => rV_Spec.nrn)
                 ,cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrders', ndocument => rV_Spec.nprn));
    end if;
  end if;

  /* Подстановка значений */
  rV_Spec.snomen      := nvl(sNOMEN, rV_Spec.snomen);
  rV_Spec.snom_modif  := nvl(sMODIF, rV_Spec.snom_modif);
  rV_Spec.snote       := nvl(sCOMMENTS, rV_Spec.snote);
  rV_Spec.nmain_quant := nvl(nQUANT, rV_Spec.nmain_quant);

  /* Исправление текущей записи */
  usr_pkg_departmentord.departmentords_update(rv_row => rV_Spec, nsum_out => nNumber );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end USR_P_DPOS_UPDATE;
/
