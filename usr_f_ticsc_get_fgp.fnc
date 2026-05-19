create or replace function usr_f_ticsc_get_fgp
/*
Расходные накладные на отпуск потребителям (спецификации, строки калькуляции)
Функция для колонки - #Точка графика
grant execute on USR_F_TICSC_GET_FGP to public;
10/07/2025 Степанов М.
*/
(
 nGRAPHPOINT    in number
)
return varchar2
is
begin
  return f_docdescrs_get_description(sunitcode => 'FaceAccountsGraphPoints', ndocument => nGRAPHPOINT );
end;
/
