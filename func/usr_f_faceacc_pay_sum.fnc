create or replace function usr_f_faceacc_pay_sum(nrn            faceacc.rn%type
                                                ,npay_vid       paynotes.signplan%type default 0 /* Фактические платежи */
                                                ,spay_type      azsgsmpaymentstypes.gsmpayments_mnemo%type default null
                                                ,dpay_date_from paynotes.pay_date%type default null
                                                ,dpay_date_to   paynotes.pay_date%type default null) return number is

  v_res number(17, 2);

/*Сумма оплат по лицевому счету с возможность фильтрации по 
1. Виду плаитежа План/Факт
2. Типу платежа "ОкончатРасчет" , "ПредоплатаБезнал" -- для Авансов
3. Датам платежа с .. по ..

Городецкий 27-04-2026
*/

begin

  select nvl(sum(pn.pay_sum_acc), 0)
    into v_res
    from paynotes pn
    left join azsgsmpaymentstypes pt
      on pt.rn = pn.pay_type
   where pn.faceacc = nrn
     and pn.signplan = npay_vid
     and (dpay_date_from is null or pn.pay_date >= dpay_date_from)
     and (dpay_date_to is null or pn.pay_date <= dpay_date_to)
     and (spay_type is null or pt.gsmpayments_mnemo = spay_type);

  return v_res;

end;
/
