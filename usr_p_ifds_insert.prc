create or replace procedure USR_P_IFDS_INSERT
/*
Раздел: Приход из подразделений (спецификация)
Добавлить
*/
(
 nRN              in number
,sNOMEN           in varchar2
,sNOMMODIF        in varchar2
,sSERNUMB         in varchar2
,nQUANT           in number
,sSUPPLIER_PARTY  in varchar2
,sPROVDATE        in varchar2
)
as
  rRow          incomefromdepsspec%rowtype;
  rHead         incomefromdeps%rowtype;
  rV_Spec       v_incomefromdepsspec%rowtype;
  nSpec         pkg_std.tref;
  bUnWork       boolean := false;

  nNumber       pkg_std.tnumber;
  dDate         date;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IFDS_INSERT');

  /* Текущая запись */
  rRow := usr_pkg_incomefromdeps.incomefromdepsspec_get(nrn => nRN);
  /* Заголовок */
  rHead := usr_pkg_incomefromdeps.incomefromdeps_get(nrn => rRow.prn);

  /* Если документ НЕ не отработан */
  if rHead.doc_state != 0 then
    /* Добавление заголовка в selectlist */
    p_selectlist_insert(nident => rHead.rn, ndocument => rHead.rn, sunitcode => 'IncomFromDeps', nrn => nNumber);

    /* Снятие отработки с сохранением партии */
    usr_pkg_incomefromdeps.incomefromdeps_base_set_stat(nrn => rHead.rn, nident => rHead.rn, nstatus => 0);

    /* Флаг, что отработка снималась */
    bUnWork := true;
  end if;

  /* Заполнение значений в запись для добавления */
  rV_Spec.nprn            := rHead.rn;
  rV_Spec.ncompany        := rHead.company;
  rV_Spec.ncrn            := rHead.crn;
  rV_Spec.snomen          := sNOMEN;
  rV_Spec.snommodif       := sNOMMODIF;
  rV_Spec.ssernumb        := sSERNUMB;
  rV_Spec.nquant_plan     := nQUANT;
  rV_Spec.nquant_fact     := nQUANT;
  rV_Spec.nquant_plan_alt := 0;
  rV_Spec.nquant_fact_alt := 0;
  rV_Spec.nprice          := 0;
  rV_Spec.npricemeas      := 0;
  rV_Spec.nsumm_plan      := 0;
  rV_Spec.nsumm_fact      := 0;

  /* Добавление клиентское (!!!) */
  usr_pkg_incomefromdeps.incomefromdepsspec_insert(rv_row => rV_Spec, nrn => nSpec);

  /* Если с документа снималась отработка */
  if bUnWork then
    /* Отработка с сохранением партии */
    usr_pkg_incomefromdeps.incomefromdeps_base_set_stat(nrn => rHead.rn, nident => rHead.rn, nstatus => rHead.doc_state);

    /* Очистка selectlist */
    p_selectlist_clear(nident => rHead.rn);
  end if;

  /* Исправление свойств */
  pkg_docs_props_vals.modify(nproperty   => 69192082
                            ,sunitcode   => 'IncomFromDepsSpecs'
                            ,ndocument   => nSpec
                            ,sstr_value  => sSUPPLIER_PARTY
                            ,nnum_value  => nNumber
                            ,ddate_value => dDate
                            ,nrn         => nNumber);
  pkg_docs_props_vals.modify(nproperty   => 12114824
                            ,sunitcode   => 'IncomFromDepsSpecs'
                            ,ndocument   => nSpec
                            ,sstr_value  => sPROVDATE
                            ,nnum_value  => nNumber
                            ,ddate_value => dDate
                            ,nrn         => nNumber);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_IFDS_INSERT;
/
