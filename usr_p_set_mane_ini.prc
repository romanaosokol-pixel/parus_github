create or replace procedure usr_p_set_mane_ini

( -- Внешний номер
 nrn            in payaccin.rn%type -- Дата счета
,out_snumber    out payaccin.ext_numb%type -- Внешний номер 
,out_dregdate   out payaccin.reg_date%type -- Дата счета
,out_nclear     out number -- Очищать дату платежа
,out_nclear_vis out number -- видеть парметр очищать дату платежа
,sCurenc  out varchar2 --- Код ISO валюты
 ) is

begin
  begin
    select p.reg_date
          ,p.ext_numb
          ,0
          ,case
             when p.pay_date is null then
              0
             else
              1
           end,
           cr.intcode
      into out_dregdate
          ,out_snumber
          ,out_nclear
          ,out_nclear_vis
          ,sCurenc
      from payaccin p
      join curnames cr on cr.rn = P.CURRENCY
     where p.rn = nrn;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Процедуру можно запускать только по одному входящему счету на оплату');
  end;
end;
/
