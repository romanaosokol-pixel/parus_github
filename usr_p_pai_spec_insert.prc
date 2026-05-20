create or replace procedure USR_P_PAI_SPEC_INSERT
/*
Входящие счета на оплату. Добавить спецификацию в утверждённый документ
08/04/2022 Степанов М.
*/
(
 nRN          in number
,sNOMEN       in varchar2
,sMODIF       in varchar2
,sTAXGR       in varchar2
,sSERNUMB     in varchar2
,sCOMMENTS    in varchar2
,nQUANT       in number
,nSUMMWITHNDS in number
)
is
  rHead             payaccin%rowtype;
  rV_Spec           v_payaccinspec%rowtype;
  bExistsAllRights  boolean := false;
  
  nNumber           pkg_std.tnumber; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_PAI_SPEC_INSERT');

  /* Считывание текущей записи заголовка */
  rHead := usr_pkg_payaccin.payaccin_get(nrn => nRN);

  /* Наличие у пользователя роли 'Все права' */
  for c in (select null from userroles where authid = utilizer and roleid = 90519)
  loop
    bExistsAllRights := true;
    exit;
  end loop;

  /* Подстановка значений */
  rV_Spec.nprn          := rHead.rn;
  rV_Spec.ncompany      := rHead.company;
  rV_Spec.ncrn          := rHead.crn;
  rV_Spec.snomen        := sNOMEN;
  rV_Spec.snommodif     := sMODIF;
  rV_Spec.staxgr        := sTAXGR;
  rV_Spec.sseria        := sSERNUMB;
  rV_Spec.scomments     := sCOMMENTS;
  rV_Spec.nquant        := nQUANT;
  rV_Spec.nsummwithnds  := nSUMMWITHNDS;
  
  /* Пересчёт сумм */
  pkg_dictaxis_calc.p_calculate(
                                nflag_smart => 0
                               ,ncompany    => rHead.company
                               ,ddate       => rHead.doc_date
                               ,nsumm_sign  => 1 /* всегда с налогами */
                               ,ninsumm     => rV_Spec.nsummwithnds
                               ,staxgr      => rV_Spec.staxgr
                               ,nquant      => 1
                               ,nncp_sign   => 1);
  rV_Spec.nsumm        := pkg_dictaxis_calc.f_get_value(nident => 0); -- Сумма без налогов       (0)
  rV_Spec.nsummwithnds := pkg_dictaxis_calc.f_get_value(nident => 2); -- Сумма со всеми налогами (2)
  rV_Spec.nsumm_nds    := pkg_dictaxis_calc.f_get_value(nident => 8); -- НДС                     (8)
  rV_Spec.nprice       := case rHead.pricewithtax when 0 then rV_Spec.nsumm else rV_Spec.nsummwithnds end / rV_Spec.nquant;
  rV_Spec.npricemeas   := 0;
  rV_Spec.nautocalc_sign   := 1;

  /* Изменение статуса на Не утверждён */
  update payaccin set doc_state = 0 where rn = rHead.rn;

  /* Добавление спецификации */
  usr_pkg_payaccin.payaccinspec_insert(rv_row => rV_Spec, nrn => nNumber);

  /* Возврат искходного статуса  */
  update payaccin set doc_state = rHead.doc_state where rn = rHead.rn;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_PAI_SPEC_INSERT;
/
