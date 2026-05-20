create or replace procedure USR_P_RL_UPDATE_SELECTED
/*
Маршрутные листы. Заголовок. Исправление
Если значение какого-либо параметра не задано, то используется текущее значение
12/07/2024 Степанов М.
*/
(
 nRN          in number
,sNOTE        in varchar2
,s13459644    in varchar2 /* СП */
,s13459637    in varchar2 /* СБ */
,s13459654    in varchar2 /* ИДЕНТ_ДОК (Номер идентификатора) */
,s8027724     in varchar2 /* ПРИЕМКА */
)
is
  nrn2              pkg_std.tref := nRN;
  rV_Row            v_fcroutlst%rowtype;
  bNeedUpdate       boolean := false;   /* были изменения, требуется исправить запись */
  aPropVals         usr_pkg_pub_const.tdocs_props_vals;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_RL_UPDATE_SELECTED');

  /* Считывание текущей записи */
  select * into rV_Row from v_fcroutlst where nrn = nrn2;

  /* Примечание */
  if sNOTE is not null then
    rV_Row.snote := sNOTE;
    bNeedUpdate := true;
  end if;
  
  /* Если были изменения полей документа */
  if bNeedUpdate then
  /* Исправление */
    usr_pkg_fcroutlst.fcroutlst_update(rv_row => rv_row);
  end if;

  /* Обнуление переменной */
  bNeedUpdate := false;

  /* Считывание массива свойств */
  usr_pkg_docs_props_vals.get_vals_document_type(ndocument => nRN, apropvals => aPropVals);

   /* СП */
  if s13459644 is not null then
    usr_pkg_docs_props_vals.modify_val_from_type(nproperty => 13459644, sstr_value => s13459644, apropvals => aPropVals);
    bNeedUpdate := true;
  end if;
  /* СБ */
  if s13459637 is not null then
    usr_pkg_docs_props_vals.modify_val_from_type(nproperty => 13459637, sstr_value => s13459637, apropvals => aPropVals);
    bNeedUpdate := true;
  end if;
   /* ИДЕНТ_ДОК (Номер идентификатора) */
  if s13459654 is not null then
    usr_pkg_docs_props_vals.modify_val_from_type(nproperty => 13459654, sstr_value => s13459654, apropvals => aPropVals);
    bNeedUpdate := true;
  end if;
   /* ПРИЕМКА */
  if s8027724 is not null then
    usr_pkg_docs_props_vals.modify_val_from_type(nproperty => 8027724, sstr_value => s8027724, apropvals => aPropVals);
    bNeedUpdate := true;
  end if;

  /* Если были изменения свойств */
  if bNeedUpdate then
  /* Исправление */
    usr_pkg_docs_props_vals.modify_vals_document_type(ndocument => nRN, sunitcode => 'CostRouteLists', apropvals => aPropVals);
  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  /* Закрываем процесс */
  usr_pkg_process.process_close;
  raise;
end USR_P_RL_UPDATE_SELECTED;
/
