create or replace function usr_f_stages_avans(nfaceacc in number) return number is
  v_res paynotes.pay_sum%type;
begin
  /* Функция считает сумму фактических Авансовых платеже по лицевому счету (Признак Вид оплаты "ПредоплатаБезнал"
  С учетом:
      напраления финансовой операции (typoper_direct -  Направление средств операции  0 - приход, 1-расход )
      Вида лицевого счета acc_kind (0 - потребление/закупка, 1 - поставка/продажа) 
      
      Соответственно сумма прямого аванса положительна, возврат аванса отрицательное значение
      
     Городецкий 2026-04-20 
      
  */
  select nvl(sum(pn.pay_sum * (1 - 2 * op.typoper_direct)) * (2 * f.acc_kind - 1), 0)
    into v_res
    from faceacc f
    join paynotes pn
      on pn.faceacc = f.rn
    join azsgsmpaymentstypes vp
      on vp.rn = pn.pay_type
    join dictoper op
      on op.rn = pn.finoper
   where f.rn = nfaceacc
     and pn.signplan = 0
     and vp.gsmpayments_mnemo = 'ПредоплатаБезнал'
   group by f.acc_kind;
  return v_res;
end;
/
