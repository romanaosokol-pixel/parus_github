create or replace procedure USR_P_IFDS_DELETE
/*
Раздел: Приход из подразделений (спецификация)
Удалить
*/
(
 nRN              in number
)
as
  rRow          incomefromdepsspec%rowtype;
  rHead         incomefromdeps%rowtype;
  rGoodsSupply  goodssupply%rowtype;
  rGoodsParties goodsparties%rowtype;
  bUnWork       boolean := false;

  nNumber       pkg_std.tnumber;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IFDS_DELETE');

  /* Текущая запись */
  rRow := usr_pkg_incomefromdeps.incomefromdepsspec_get(nrn => nRN);
  /* Товарный запас */
  rGoodsSupply := usr_pkg_goodsparties.goodssupply_get(nrn => rRow.supply);
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

  /* Удаление спецификации клиентское (!!!) */
  p_incomefromdepsspec_delete(ncompany => rRow.company, nrn => rRow.rn);

  /* Если с документа снималась отработка */
  if bUnWork then
    /* Отработки с сохранением партии */
    usr_pkg_incomefromdeps.incomefromdeps_base_set_stat(nrn => rHead.rn, nident => rHead.rn, nstatus => rHead.doc_state);

    /* Очистка selectlist */
    p_selectlist_clear(nident => rHead.rn);
  end if;

  /* Удаление дополнительных данных приходной партии из раздела Сертификаты */
  for c in (select distinct crts.prn
              from certificationsp crts
             where crts.party = rGoodsSupply.prn)
  loop
    p_certification_base_delete(ncompany => rGoodsSupply.company, nrn => c.prn);
  end loop;

  /* Приходная партия по товарному запасу удалённой спецификации */
  rGoodsParties := usr_pkg_goodsparties.goodsparties_get(nrn => rGoodsSupply.prn, nflagsmart => 1);

  /* Если приходная партия не была удалёна при удалении доп.данных из Сертификатов */
  if rGoodsParties.rn is not null then
    /* Добавление приходной партии в selectlist */
    p_selectlist_insert(nident => rGoodsParties.rn, ndocument => rGoodsParties.rn, sunitcode => 'GoodsParties', nrn => nNumber);

    /* Попытка удалить приходную партию */
    udo_p_goodsparties_delete(nident => rGoodsParties.rn, ncompany => rGoodsParties.company);

    /* Очистка selectlist */
    p_selectlist_clear(nident => rGoodsParties.rn);
  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_IFDS_DELETE;
/
