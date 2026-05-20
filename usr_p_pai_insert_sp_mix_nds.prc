create or replace procedure USR_P_PAI_INSERT_SP_MIX_NDS
/*
Входящий счёт на оплату. Заголовок. Добавление спецификаций с НДС и без НДС
По сумме НДС расчитывает исходную сумму, добавляет спецификацию. После добавляет вторую спецификацию на оставшуюся сумму с налоговой группой без НДС
20/10/2023 Степанов М.
*/
(
 nRN            in number     /* Заголовок */
,sNOMEN         in varchar2
,sMODIF         in varchar2
,sTAXGR         in varchar2   /* Налоговая группа с НДС */
,sNO_TAXGR      in varchar2   /* Налоговая группа без НДС */
,nSUMMNDS       in number
,nSUMMWITHNDS   in number
)
is
  rHead             payaccin%rowtype;
  rV_Spec           v_payaccinspec%rowtype;
  nNDS_Percent      pkg_std.tnumber;
  rSpec             payaccinspec%rowtype;
  nNomenType        pkg_std.tref; 

  nNumber           pkg_std.tnumber;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_PAI_INSERT_SP_MIX_NDS');

  /* Заголовок */
  rHead := usr_pkg_payaccin.payaccin_get(nrn => nRN);

  /* Подстановка значений */
  rV_Spec.nprn          := rHead.rn;
  rV_Spec.ncompany      := rHead.company;
  rV_Spec.ncrn          := rHead.crn;
  rV_Spec.snomen        := sNOMEN;
  rV_Spec.snommodif     := sMODIF;
  rV_Spec.staxgr        := sTAXGR;
  rV_Spec.nquant        := 1;
  rV_Spec.nsummwithnds  := nSUMMWITHNDS;
  rV_Spec.npricemeas      := 1;
  rV_Spec.nautocalc_sign  := 1;
  rV_Spec.ndiscount       := 0;

  /* если номенклатура - услуга, то подставляем дату начала услуг */
  find_dicnomns_code(nflag_smart  => 0
                    ,nflag_option => 0
                    ,ncompany     => rHead.company
                    ,scode        => sNOMEN
                    ,nrn          => rV_Spec.nnomen);
  find_nomenclature_type(ncompany => rHead.company, nrn => rV_Spec.nnomen, ntype => nNomenType);
  if nNomenType = 2 then
    rV_Spec.dbegindate := rHead.doc_date;
  end if;

  /* Ставка НДС */
  find_dictaxis_kind_new(nflag_smart  => 0
                        ,nflag_gre    => 0
                        ,ncompany     => rHead.company
                        ,stax_group   => sTAXGR
                        ,nkind        => 1
                        ,dbeg_date    => rHead.doc_date
                        ,nrn          => nNumber
                        ,ntype        => nNumber
                        ,np_value     => nNDS_Percent
                        ,np_value_ret => nNumber
                        ,na_summer    => nNumber
                        ,np_round     => nNumber
                        ,nret_calc    => nNumber);
  /* Сумма спецификации с НДС рассчитанная по заданной сумме НДС и ставке налога */
  rV_Spec.nsummwithnds := nSUMMNDS / nNDS_Percent * (100 + nNDS_Percent);

  /* Добавление спецификации с НДС */
  /* расчёт всех сумм для спецификации */
  pkg_dictaxis_calc.p_calculate(nflag_smart => 0
                               ,ncompany    => rHead.company
                               ,ddate       => rHead.doc_date
                               ,nsumm_sign  => 1
                               ,ninsumm     => rV_Spec.nsummwithnds
                               ,staxgr      => rV_Spec.staxgr
                               ,nquant      => 1
                               ,nncp_sign   => 1);
  rV_Spec.nsumm        := pkg_dictaxis_calc.f_get_value(nident => 0); -- Сумма без налогов       (0)
  rV_Spec.nsummwithnds := pkg_dictaxis_calc.f_get_value(nident => 2); -- Сумма со всеми налогами (2)
  rV_Spec.nsumm_nds    := pkg_dictaxis_calc.f_get_value(nident => 8); -- НДС                     (8)
  rV_Spec.nprice       := case rHead.pricewithtax when 0 then rV_Spec.nsumm else rV_Spec.nsummwithnds end / rV_Spec.nquant;
  rV_Spec.sseria       := 1;
  /* добавление */
  usr_pkg_payaccin.payaccinspec_insert(rv_row => rV_Spec, nrn => nNumber);
  /* считывание добавленной записи */
  rSpec := usr_pkg_payaccin.payaccinspec_get(nrn => nNumber);
  /* подставляем в Серию RN */
  rSpec.sernumb := rSpec.rn;
  /* исправление */
  usr_pkg_payaccin.payaccinspec_base_update(rrow => rSpec);


  /* Добавление спецификации без НДС */
  /* подстановка налоговой группы без НДС и техническая запись в поле Серия */
  rV_Spec.staxgr := sNO_TAXGR;
  rV_Spec.sseria := 2;
  /* остаток суммы  */
  rV_Spec.nsummwithnds := nSUMMWITHNDS - rV_Spec.nsummwithnds;
  /* расчёт всех сумм для спецификации */
  pkg_dictaxis_calc.p_calculate(nflag_smart => 0
                               ,ncompany    => rHead.company
                               ,ddate       => rHead.doc_date
                               ,nsumm_sign  => 1
                               ,ninsumm     => rV_Spec.nsummwithnds
                               ,staxgr      => rV_Spec.staxgr
                               ,nquant      => 1
                               ,nncp_sign   => 1);
  rV_Spec.nsumm        := pkg_dictaxis_calc.f_get_value(nident => 0); -- Сумма без налогов       (0)
  rV_Spec.nsummwithnds := pkg_dictaxis_calc.f_get_value(nident => 2); -- Сумма со всеми налогами (2)
  rV_Spec.nsumm_nds    := pkg_dictaxis_calc.f_get_value(nident => 8); -- НДС                     (8)
  rV_Spec.nprice       := case rHead.pricewithtax when 0 then rV_Spec.nsumm else rV_Spec.nsummwithnds end / rV_Spec.nquant;
  /* добавление */
  usr_pkg_payaccin.payaccinspec_insert(rv_row => rV_Spec, nrn => nNumber);

  /* считывание добавленной записи */
  rSpec := usr_pkg_payaccin.payaccinspec_get(nrn => nNumber);
  /* подставляем в Серию RN */
  rSpec.sernumb := rSpec.rn;
  /* исправление */
  usr_pkg_payaccin.payaccinspec_base_update(rrow => rSpec);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  

end USR_P_PAI_INSERT_SP_MIX_NDS;
/
