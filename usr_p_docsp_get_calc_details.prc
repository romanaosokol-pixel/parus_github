create or replace procedure USR_P_DOCSP_GET_CALC_DETAILS
/*
Все документы. Спецификация. Показать данные калькуляции
08/04/2022 Степанов М.
*/
(
 nRN          in number
,sUNITCODE    in varchar2
,sOUT        out varchar2
)
is
  nPAISC_QuantPlan pkg_std.tquant; 

  sVarchar        pkg_std.tstring; 
  nNumber         pkg_std.tnumber; 
begin
  case sUNITCODE
    when 'DeliveryOrdersSpec' then
      for c in (
                select t.rn, fa.numb, fpa.code, t.quant_plan, t.quant_fact
                  from deliveryordcs  t
                      ,faceacc        fa
                      ,fpdartcl       fpa
                 where t.prn          = nRN
                   and t.faceaccount  = fa.rn (+)
                   and t.cost_article = fpa.rn(+)
               )
      loop
        sVarchar := sVarchar||'Лицевой счёт: <'||nvl(c.numb, null)||'>';
        sVarchar := sVarchar||', Статья затрат: <'||nvl(c.code, null)||'>';
        sVarchar := sVarchar||', Количество план: '||nvl(trim(n2sq(c.quant_plan)), '<>');
        /*sVarchar := sVarchar||', Количество факт: <'||nvl(trim(n2sq(c.quant_fact)), null)||'>';*/
        usr_pkg_deliveryord.deliveryordcs_get_paisc_quant(nrn         => c.rn
                                                         ,nquant_plan => nPAISC_QuantPlan
                                                         ,nquant_fact => nNumber);
        sVarchar := sVarchar||', Количество по вх.счетам: <'||nvl(trim(n2sq(nPAISC_QuantPlan)), null)||'>'; 
        sVarchar := sVarchar||', Остаток: <'||nvl(trim(n2sq(c.quant_plan - nPAISC_QuantPlan)), null)||'>'; 
        sOUT     := strcombine(sVarchar, sOUT, cr);
        sVarchar := null;
      end loop;
    when 'PaymentAccountsInSpecs' then
      for c in (
                select t.rn, fa.numb, fpa.code, t.quant_plan, t.quant_fact
                  from payaccinspclc  t
                      ,faceacc        fa
                      ,fpdartcl       fpa
                 where t.prn          = nRN
                   and t.faceaccount  = fa.rn (+)
                   and t.cost_article = fpa.rn(+)
               )
      loop
        sVarchar := sVarchar||'Лицевой счёт: <'||c.numb||'>';
        sVarchar := sVarchar||', Статья затрат: <'||c.code||'>';
        sVarchar := sVarchar||', Количество план: <'||trim(n2sq(c.quant_plan))||'>'; 
        /*sVarchar := sVarchar||', Количество факт: <'||trim(n2sq(c.quant_fact))||'>';*/
        usr_pkg_payaccin.payaccinspclc_get_iivsc_quant(nrn         => c.rn
                                                      ,nquant_plan => nPAISC_QuantPlan
                                                      ,nquant_fact => nNumber);
        sVarchar := sVarchar||', Количество по накладным: <'||trim(n2sq(nPAISC_QuantPlan))||'>';
        sVarchar := sVarchar||', Остаток: <'||trim(n2sq(c.quant_plan - nPAISC_QuantPlan))||'>';
        sOUT     := strcombine(sVarchar, sOUT, cr);
        sVarchar := null;
      end loop;
  else
    p_exception(0, 'Неверный раздел для вызова <%s>', sUNITCODE); 
  end case;
end USR_P_DOCSP_GET_CALC_DETAILS;
/
