create or replace procedure USR_P_IFD_UPDATE
/*
Раздел: Приход из подразделений
Исправить
*/
(
 nRN            in number
,dDOC_DATE      in date
,sSTORE         in varchar2
,sSMOL          in varchar2
)
as
  nRN2          pkg_std.tref := nRN;
  rV_Row        v_incomefromdeps%rowtype;
  bUnWork       boolean := false;

  nNumber       pkg_std.tnumber;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IFD_UPDATE');

  /* Запрет выполнения с пустыми параметрами */
  if dDOC_DATE||sSTORE||sSMOL is null then
    p_exception(0, 'Не заполнен ни один параметр процедуры. %s'
               ,cr||f_docdescrs_get_description(sunitcode => 'IncomFromDeps', ndocument => nRN));
  end if;

  /* Считывание текущей записи */
  select * into rV_Row from v_incomefromdeps where nrn = nRN2;

  /* Если документ НЕ не отработан */
  if rV_Row.ndoc_state != 0 then
    /* Добавление заголовка в selectlist */
    p_selectlist_insert(nident => rV_Row.nrn, ndocument => rV_Row.nrn, sunitcode => 'IncomFromDeps', nrn => nNumber);

    /* Снятие отработки с сохранением партии */
    usr_pkg_incomefromdeps.incomefromdeps_base_set_stat(nrn => rV_Row.nrn, nident => rV_Row.nrn, nstatus => 0);

    /* Флаг, что отработка снималась */
    bUnWork := true;
  end if;

  /* Подмена значений в записи */
  rV_Row.ddoc_date := nvl(dDOC_DATE, rV_Row.ddoc_date);
  rV_Row.sstore    := nvl(sSTORE   , rV_Row.sstore);
  rV_Row.sagent    := nvl(sSMOL    , rV_Row.sagent);

  /* Исправление заголовка клиентское (!!!) */
  usr_pkg_incomefromdeps.incomefromdeps_update(rv_row => rV_Row);

  /* Если с документа снималась отработка */
  if bUnWork then

    /* Отработка с сохранением партии */
    usr_pkg_incomefromdeps.incomefromdeps_base_set_stat(nrn => rV_Row.nrn, nident => rV_Row.nrn, nstatus => rV_Row.ndoc_state);

    /* Очистка selectlist */
    p_selectlist_clear(nident => rV_Row.nrn);

  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_IFD_UPDATE;
/
