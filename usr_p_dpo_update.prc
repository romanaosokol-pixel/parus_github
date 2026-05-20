create or replace procedure USR_P_DPO_UPDATE
/*
Заказы подразделений. Исправление
12/03/2024 Степанов М.
*/
(
 nRN          in number
,sFACEACC     in varchar2
,sREQUEST_1C  in varchar2
,sCOMMENTS    in varchar2
,nMODE        in number default 1 /* Режим исправления значений: 0-заменять, 1-заменять, если задано, 2-добавлять через ';' */
)
is
  nRN2              pkg_std.tref := nRN;
  rRow              departmentord%rowtype;
  aProps            usr_pkg_pub_const.tdocs_props_vals;
  bExistsAllRights  boolean := false;
  nFaceAcc          pkg_std.tref; 

  nNumber           pkg_std.tnumber; 
  dDate             date;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_DPO_UPDATE');

  /* Проверка параметров */
  if nMODE not in (0, 1, 2) then
    p_exception(0, 'Неверный режим работы <%s>. %s'
               ,nMODE
               ,cr||f_docdescrs_get_description(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'DEPARTMENTORD'), ndocument => nRN)); 
  end if;

  /* Наличие у пользователя роли 'Все права' */
  for c in (select null from userroles where authid = utilizer and roleid = 90519)
  loop
    bExistsAllRights := true;
    exit;
  end loop;

  /* Считывание */
  /* Заголовок */
  rRow := usr_pkg_departmentord.departmentord_get(nrn => nRN);
  /* Свойства заголовка */
  usr_pkg_docs_props_vals.get_vals_document_type(ndocument => rRow.rn, apropvals => aProps);

  /* Лицевой счёт */
  if sFACEACC is not null then
    /* Если нет роли Все права */  --- Нужно ограничение, что ЛС можно править если не включено в заказ поставщикам!
  /*  if not bExistsAllRights then
      p_exception(0, 'Запрещено исправлять лицевой счёт. %s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrders', ndocument => rRow.rn)); 
   end if;*/
    /* RN лицевого счёта */
    find_faceacc_numb(nflag_smart  => 0
                     ,nflag_option => 0
                     ,ncompany     => rRow.company
                     ,snumb        => sFACEACC
                     ,nrn          => nFaceAcc);

    /* Иссправление заголовка */
    rRow.faceacc := nFaceAcc;
    usr_pkg_departmentord.departmentord_base_update(rRow => rRow, nsum_out => nNumber, nmode => 1);
  end if;
  
  /* Изменение значений переменных */
  /* Свойство НОМ_ЗЯВКИ */
  usr_pkg_docs_props_vals.modify_val_from_type
  (
   sproperty   => 'НОМ_ЗЯВКИ'
  ,sstr_value  => case nMODE 
                    when 0 then
                      sREQUEST_1C
                    when 1 then
                      nvl(sREQUEST_1C, usr_pkg_docs_props_vals.get_val_from_type_str(sproperty => 'НОМ_ЗЯВКИ', apropvals => aProps))
                    when 2 then
                      strcombine(usr_pkg_docs_props_vals.get_val_from_type_str(sproperty => 'НОМ_ЗЯВКИ', apropvals => aProps), sREQUEST_1C, '; ')
                  end
  ,nnum_value  => nNumber
  ,ddate_value => dDate
  ,apropvals   => aProps
  );

  /* Свойство КОММ_ЗАЯВКИ */
  usr_pkg_docs_props_vals.modify_val_from_type
  (
   sproperty   => 'КОММ_ЗАЯВКИ'
  ,sstr_value  => case nMODE 
                    when 0 then
                      sCOMMENTS
                    when 1 then
                      nvl(sCOMMENTS, usr_pkg_docs_props_vals.get_val_from_type_str(sproperty => 'КОММ_ЗАЯВКИ', apropvals => aProps))
                    when 2 then
                      strcombine(usr_pkg_docs_props_vals.get_val_from_type_str(sproperty => 'КОММ_ЗАЯВКИ', apropvals => aProps), sCOMMENTS, '; ')
                  end
  ,nnum_value  => nNumber
  ,ddate_value => dDate
  ,apropvals   => aProps
  );

  /* Исправление свойств */
  usr_pkg_docs_props_vals.modify_vals_document_type(ndocument => rRow.rn, sunitcode => 'DepartmentsOrders', apropvals => aProps);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_DPO_UPDATE;
/
