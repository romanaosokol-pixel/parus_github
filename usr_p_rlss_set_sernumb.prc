create or replace procedure USR_P_RLSS_SET_SERNUMB
/*
Раздел "Ведомости инвентаризации (спецификация)"
Процедура добавления товарного запаса и запись его в спецификацию
*/
(
 nRN              in number
,sSERNUMB         in varchar2
)
as
  rRow              rlinvsheetspec%rowtype;
  rHead             rlinvsheet%rowtype;
  rGoodsParties     goodsparties%rowtype;
  nGoodsParties     pkg_std.tref;
  nGoodsSupply      pkg_std.tref;
  sIncomDoc         incomdoc.code%type;
  nIncomDoc         pkg_std.tref;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_RLSS_SET_SERNUMB');

  /* Считывание */
  rRow  := usr_pkg_rlinvsheet.rlinvsheetspec_get(nrn => nRN);
  rHead := usr_pkg_rlinvsheet.rlinvsheet_get(nrn => rRow.prn);

  /* Проверки */
  if sSERNUMB is null then
    p_exception(0, 'Не задана серия в параметрах. RN: %s. %s.'
               ,nRN, cr||f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'RLINVSHEETSPEC')));
  end if;
  if rRow.goodssupply is not null then
    p_exception(0, 'Серия и партия не должны быть заполнены. RN: %s. %s.'
               ,nRN, cr||f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'RLINVSHEETSPEC')));
  end if;
  if rRow.accquant - rRow.factquant > 0 then
    p_exception(0, 'Процедура предназначена для спецификаций с видом "Излишек". RN: %s. %s.'
               ,nRN, cr||f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'RLINVSHEETSPEC')));
  end if;

  /* Заполнение переменных для приходной партии */
  rGoodsParties.company     := rRow.company;
  rGoodsParties.jur_pers    := rHead.jpers;
  rGoodsParties.nommodif    := rRow.nommodif;
  rGoodsParties.expiry_date := rHead.docdate;
  rGoodsParties.signbreak   := 0;
  rGoodsParties.sernumb     := sSERNUMB;
  p_incomdoc_getnextnumb(ncompany => rGoodsParties.company, snumber => sIncomDoc);
  p_incomdoc_base_insert(ncompany     => rGoodsParties.company
                        ,njur_pers    => rGoodsParties.jur_pers
                        ,scode        => sIncomDoc
                        ,nagent       => null
                        ,nsubdiv      => 1026748
                        ,dentry_date  => rHead.docdate
                        ,nout_party   => 1
                        ,nstor_sign   => 0
                        ,ncommis_sign => 0
                        ,nrn          => nIncomDoc);
  rGoodsParties.indoc := nIncomDoc;

  /* Добавление приходной партии */
  usr_pkg_goodsparties.goodsparties_base_insert(rrow => rGoodsParties, nrn =>  nGoodsParties);

  /* Добавление товарного запаса */
  p_goodssupply_base_insert(ncompany  => rGoodsParties.company
                           ,nprn      => nGoodsParties
                           ,nstore    => rHead.store
                           ,scardnumb => null
                           ,nrn       => nGoodsSupply);

  /* Подстановка товарного запаса в текущую запись */
  rRow.goodssupply := nGoodsSupply;

  /* Исправление текущей записи */
  usr_pkg_rlinvsheet.rlinvsheetspec_base_update(rrow => rrow);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_RLSS_SET_SERNUMB;
/
