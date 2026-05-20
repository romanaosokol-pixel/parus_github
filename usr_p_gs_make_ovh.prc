create or replace procedure USR_P_GS_MAKE_OVH
/*
Товарные запасы (GOODSSUPPLY)
Процедура формирования и распределения накладного расхода для товарного запаса
04/10/2023 Степанов М.
*/
(
 nRN        in number
,sDOC_TYPE  in varchar2
,dDATE      in date
,sNOMEN     in varchar2
,sNOMMODIF  in varchar2
,sSTOPER    in varchar2
,sCURRENCY  in varchar2
,sNOTE      in varchar2
) 
is
  rRow          goodssupply%rowtype;
  rOverHeads    overheads%rowtype;
  nOverHeads    pkg_std.tref;
begin
  /* Считывание товарного запаса */
  begin
    select * into rRow from goodssupply where rn = nRN;
  exception
    when no_data_found then
      pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'GOODSSUPPLY');
    when others then
      p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                 ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(1, 'GOODSSUPPLY')));
  end;

  /* Заполнение переменных для добавления накладного расхода */
  rOverHeads.company  := rRow.company;
  rOverHeads.jur_pers := rRow.jur_pers;
  find_dicnomns_by_code(nflag_smart => 0
                       ,ncompany    => rRow.company
                       ,snomen_code => sNOMEN
                       ,nrn         => rOverHeads.nomen);
  find_nommodif_code(nflag_smart  => 0
                    ,nflag_option => 0
                    ,ncompany     => rRow.company
                    ,nprn         => rOverHeads.nomen
                    ,sprn         => null
                    ,smodif_code  => sNOMMODIF
                    ,nrn          => rOverHeads.nommodif);
  find_doctypes_code(ncompany  => rRow.company
                    ,sdoccode  => sDOC_TYPE
                    ,sunitcode => null
                    ,nstype    => null
                    ,nrn       => rOverHeads.doc_type);
  p_overheads_base_get_next_numb(ncompany  => rRow.company
                                ,njur_pers => rRow.jur_pers
                                ,nnomen    => rOverHeads.nomen
                                ,nnommodif => rOverHeads.nommodif
                                ,ndoc_type => rOverHeads.doc_type
                                ,nyear     => null
                                ,sunitcode => null
                                ,sdoc_numb => rOverHeads.doc_numb);
  rOverHeads.doc_date         := dDATE;
  rOverHeads.summ             := 0;
  rOverHeads.summ_nds         := 0;
  find_currency_iso(nflag_smart => 0, ncompany => rRow.company, siso => sCURRENCY, nrn => rOverHeads.currency);
  rOverHeads.curcourse        := 1;
  rOverHeads.curbasecours     := 1;
  rOverHeads.signspread       := 1; /* Тип распределения 0 - по сумме товара, 1 - по количеству в основной ЕИ, 2 - по количеству в дополнительной ЕИ, 3 - вручную, 4 - по весу, 5 - по объему */
  rOverHeads.work_date        := dDATE;
  find_dicstopr_code(nsmart_flag => 0
                    ,ncompany    => rRow.company
                    ,scode       => sSTOPER
                    ,nrn         => rOverHeads.stoper);
  rOverHeads.signgoodsrep     := 0;
  rOverHeads.group_code_cond  := null;
  rOverHeads.nomen_cond       := rOverHeads.nomen;
  rOverHeads.note             := sNOTE;
  /* Добавление накладного расхода */
  usr_pkg_overheads.overheads_base_insert(rrow            => rOverHeads
                                         ,nis_auto_create => 0
                                         ,nrn             => nOverHeads);
  /* Распределение накладного расхода на товарный запас */
  usr_pkg_overheads.overheads_spread_on_gs(nrn          => nOverHeads
                                          ,dsupplydate  => dDATE
                                          ,ngoodssupply => rRow.rn);

end USR_P_GS_MAKE_OVH;
/
