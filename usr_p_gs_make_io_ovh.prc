create or replace procedure usr_p_gs_make_io_ovh
/*
Товарные запасы (GOODSSUPPLY)
Процедура формирования приходного ордера и распределения его накладного расхода на товарный запас
04/10/2023 Степанов М.
*/
(
 nRN        in number                 /* Товареный запас. RN */
,dDATE      in date                   /* Приходные ордера. Дата */
,sAGENT     in varchar2               /* Приходные ордера. Контрагент */
,sCATALOG   in varchar2 default null  /* Приходные ордера. Каталог */
,sDOC_TYPE  in varchar2 default null  /* Приходные ордера. Тип документа */
,sFACEACC   in varchar2 default null  /* Приходные ордера. Лицевой счёт */
,sSTORE     in varchar2 default null  /* Приходные ордера. Склад */
,sSTOPER    in varchar2 default null  /* Приходные ордера. Складская операция */
,sCURRENCY  in varchar2 default null  /* Приходные ордера. Валюта */
,sTAXGR     in varchar2 default null  /* Приходные ордера. Налоговая группа */
,sNOMEN     in varchar2 default null  /* Приходные ордера (спецификация). Номеннклатура */
,sNOMMODIF  in varchar2 default null  /* Приходные ордера (спецификация). Модификация */
,sNOTE      in varchar2 default null  /* Приходные ордера (спецификация). Примечание */
)
is
  rRow              goodssupply%rowtype;
  rV_InOrders       v_inorders%rowtype;
  rInOrders         inorders%rowtype;
  rV_InOrderSpecs   v_inorderspecs%rowtype;
  rInOrderSpecs     inorderspecs%rowtype;
  sMol              pkg_std.tstring; 
  nOverHeads        pkg_std.tref;
  
  nNumber       pkg_std.tnumber;   
  sVarchar      pkg_std.tstring; 
begin
  /* Считывание товарного запаса */
  rRow := udo_pkg_get.row_goodssupply(nrn => nRN, nsmart => 0); 

  /* Заполнение переменных для заголовка приходного ордера */
  rV_InOrders.ncompany  := rRow.company;
  rV_InOrders.sjur_pers := get_jurpersons_code_id(nflag_smart => 0, njur_pers => rRow.jur_pers);
  /* МОЛ склада */
  find_dicstore_attr(nflag_smart => 0
                    ,nflag_azs   => 0
                    ,ncompany    => rV_InOrders.ncompany
                    ,snumb       => nvl(sSTORE, 'Отдел метрологии')
                    ,nrn         => nNumber
                    ,nmol        => nNumber
                    ,smol        => sMol
                    ,npbe        => nNumber
                    ,spbe        => sVarchar
                    ,ncurrency   => nNumber
                    ,scurrency   => sVarchar);
  rV_InOrders.sindoctype  := nvl(sDOC_TYPE, 'ПланРем');
  rV_InOrders.sseller     := sAGENT;
  rV_InOrders.sfaceacc    := nvl(sFACEACC, 'Технический. Отдел метрологии');
  rV_InOrders.sagent      := sMol;
  rV_InOrders.scurrency   := nvl(sCURRENCY, 'RUB');
  rV_InOrders.sstore      := nvl(sSTORE, 'Отдел метрологии');
  rV_InOrders.sstopertype := nvl(sSTOPER, 'ПриходВнеш');
  /* получение RN по мнемокодам */
  usr_pkg_inorders.inorders_joins(rv_row => rV_InOrders, rrow => rInOrders);
  rInOrders.company   := rV_InOrders.ncompany;
  find_acatalog_name_ex(nflag_smart  => 0
                       ,nflag_option => 0
                       ,ncompany     => rInOrders.company
                       ,nversion     => null
                       ,sunitcode    => 'IncomingOrders'
                       ,sname        => nvl(sCATALOG, 'Услуги. План. Метрология')
                       ,nrn          => rInOrders.crn);
  rInOrders.indocdate := dDATE;
  rInOrders.indocpref := to_char(rInOrders.indocdate,'YYYY');
  p_inorders_base_nextnumb(ncompany   => rInOrders.company
                          ,njur_pers  => rInOrders.jur_pers
                          ,dindocdate => rInOrders.indocdate
                          ,nindoctype => rInOrders.indoctype
                          ,sindocpref => rInOrders.indocpref
                          ,sindocnumb => rInOrders.indocnumb);
  rInOrders.signtax       := 1;
  rInOrders.curcours      := 1;
  rInOrders.curbasecours  := 1;
  rInOrders.fa_cours      := 1;
  rInOrders.fa_basecours  := 1;

  /* Добавление заголовка*/
  usr_pkg_inorders.inorders_base_insert(rrow => rInOrders, nrn => rInOrders.rn);

  /* Заполнение переменных для спецификации приходного ордера */
  rV_InOrderSpecs.ncompany  := rInOrders.company;
  rV_InOrderSpecs.staxgr    := nvl(sTAXGR, 'НДС 20');
  rV_InOrderSpecs.snomen    := nvl(sNOMEN, 'Поверка системы');
  rV_InOrderSpecs.snommodif := nvl(sNOMMODIF, 'Поверка системы');
  /* получение RN по мнемокодам */
  usr_pkg_inorders.inorderspecs_joins(rv_row => rV_InOrderSpecs, rrow => rInOrderSpecs);
  rInOrders.company := rV_InOrderSpecs.ncompany;
  rInOrderSpecs.prn := rInOrders.rn;
  rInOrderSpecs.crn := rInOrders.crn;
  rInOrderSpecs.planquant := 1;
  rInOrderSpecs.factquant := 1;
  rInOrderSpecs.price := 0;
  rInOrderSpecs.pricemeas := 0;
  rInOrderSpecs.price_calc_rule := 1;
  rInOrderSpecs.acc_price := 0;
  rInOrderSpecs.acc_pricemeas := 0;
  rInOrderSpecs.acc_summ := 0;
  rInOrderSpecs.note := sNOTE;
  rInOrderSpecs.plansum := 0;
  rInOrderSpecs.plansumtax := 0;
  rInOrderSpecs.plansumnds := 0;
  rInOrderSpecs.factsum := 0;
  rInOrderSpecs.factsumtax := 0;
  rInOrderSpecs.factsumnds := 0;
  rInOrderSpecs.autocalc_sign := 1;
  rInOrderSpecs.nds_coeff_sign := 0;

  /* Добавление спецификации */
  usr_pkg_inorders.inorderspecs_base_insert(rrow     => rInOrderSpecs
                                           ,ndup_rn  => 0
                                           ,ndup_clc => 0
                                           ,nrn      => rInOrderSpecs.rn);
  /* Отработка */
  p_inorders_bset_status(ncompany    => rInOrders.company
                        ,nrn         => rInOrders.rn
                        ,nstatus     => 2
                        ,dwork_date  => rInOrders.indocdate
                        ,nflag_reset => 0
                        ,nwarning    => nNumber
                        ,smsg        => sVarchar);

  /* Связанный Накладной расход */
  nOverHeads := usr_pkg_doclinks.doclinks_link_out_doc(sin_unitcode => 'IncomingOrders', nin_document => rInOrders.rn, sout_unitcode => 'RealizationOverheads');
  
  /* Распределение накладного расхода на товарный запас */
  usr_pkg_overheads.overheads_spread_on_gs(nrn          => nOverHeads
                                          ,dsupplydate  => rInOrders.indocdate
                                          ,ngoodssupply => rRow.rn);
end USR_P_GS_MAKE_IO_OVH;
/
