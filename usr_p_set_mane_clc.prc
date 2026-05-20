create or replace procedure usr_p_set_mane_clc

(
  io_paydate in out payaccin.pay_date%type -- Дата счета
 ,io_nclear   in out number -- Очищать дату платежа
  
) is

begin

  if io_nclear = 1 then
    io_nclear    := 0;
    io_paydate := null;
  end if;

end;
/
