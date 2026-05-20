create or replace procedure USR_P_TICS_COPY_IFDS
/*
Раздел: Расходные накладные на отпуск в подразделения (спецификация). 
Копировать в приход из подразделений
30/08/2023 Степанов М.
*/
(
 nRN            in number
,nIFD           in number
,sIFDS_DETAILS  in varchar2
,sNOMEN         in varchar2
,sMODIF         in varchar2
)
IS
  rRow            transinvdeptspecs%rowtype;
  rIFD            incomefromdeps%rowtype;
  rIFDS           incomefromdepsspec%rowtype;
  nIFDS           pkg_std.tref;

  sVarchar        pkg_std.tstring; 
  nNumber         pkg_std.tnumber; 
  dDate           date;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TICS_COPY_IFDS');

  /* Текущая запись */
  rRow := usr_pkg_transinvdept.transinvdeptspecs_get(nrn => nRN);
  /* Заголовок документа-приёмника */
  rIFD := usr_pkg_incomefromdeps.incomefromdeps_get(nrn => nIFD);

  /* Проверки */
  /* Если каталог накладной в подразделения "СЗ", а каталог прихода из подразделений НЕ "СЗ на склад" */
  if rRow.crn = 69883751 and rIFD.crn != 112002345 then
    p_exception(0, 'Приход из подразделений для копирования должен находиться в каталоге <%s>.%s'
               ,get_acatalog_name_id(nflag_smart => 1, nrn => 112002345)
               ,get_acatalog_name_id(nflag_smart => 1, nrn => rIFD.crn)
               ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rRow.rn)); 
  end if;

  /* Заполнение значений спецификации */
  rIFDS.prn     := rIFD.rn;
  rIFDS.company := rIFD.company;
  rIFDS.crn     := rIFD.crn;
  find_nommodif_code(nflag_smart  => 0
                    ,nflag_option => 0
                    ,ncompany     => rIFD.company
                    ,nprn         => null
                    ,sprn         => sNOMEN
                    ,smodif_code  => sMODIF
                    ,nrn          => rIFDS.nommodif);
  rIFDS.quant_plan      := rRow.quant;
  rIFDS.quant_fact      := rRow.quant;
  rIFDS.quant_plan_alt  := 0;
  rIFDS.quant_fact_alt  := 0;
  rIFDS.price           := 0;
  rIFDS.pricemeas       := 0;
  rIFDS.summ_plan       := 0;
  rIFDS.summ_fact       := 0;

  /* Добавление спецификации в документ-приёмник */
  usr_pkg_incomefromdeps.incomefromdepsspec_base_insert(rrow => rIFDS, nrn => nIFDS);

  /* Считывание записи добавленной спецификации */
  rIFDS := usr_pkg_incomefromdeps.incomefromdepsspec_get(nrn => nIFDS);

  /* Исправление доп.свойств спецификации */
  /* Дата производства */
  sVarchar := null;
  usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => rRow.goodsparty
                                                     ,nflagsmart  => 0
                                                     ,ndocs_props => 12114824
                                                     ,sresult     => sVarchar
                                                     ,nothers     => nNumber);
  if sVarchar is not null then
    pkg_docs_props_vals.modify(nproperty   => 12114824
                              ,sunitcode   => 'IncomFromDepsSpecs'
                              ,ndocument   => rIFDS.rn
                              ,sstr_value  => sVarchar
                              ,nnum_value  => nNumber
                              ,ddate_value => dDate
                              ,nrn         => nNumber);
  end if;
  /* Партия поставщика */
  sVarchar := null;
  usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => rRow.goodsparty
                                                     ,nflagsmart  => 0
                                                     ,ndocs_props => 69192082
                                                     ,sresult     => sVarchar
                                                     ,nothers     => nNumber);
  if sVarchar is not null then
    pkg_docs_props_vals.modify(nproperty   => 69192082
                              ,sunitcode   => 'IncomFromDepsSpecs'
                              ,ndocument   => rIFDS.rn
                              ,sstr_value  => sVarchar
                              ,nnum_value  => nNumber
                              ,ddate_value => dDate
                              ,nrn         => nNumber);
  end if;
  
  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_TICS_COPY_IFDS;
/
