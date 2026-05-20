create or replace procedure usr_p_transinvcust_from_graf_n
(
  pio_tek_nmb  in out number --- Параметр для автогенерацииномера на форме
 ,pin_com      in transinvcust.company%type /*:= 90521;*/
 ,pin_jur      in jurpersons.code%type /*:= 'Модуль';*/
 ,pin_doc_date in transinvcust.docdate%type /*:= trunc(sysdate);*/
 ,pin_doc_type in doctypes.doccode%type /*:= 'АктВыпРаб';*/
 ,pin_doc_pref in transinvcust.pref%type /*:= 'TEST';*/
 ,out_doc_nmb  in out transinvcust.numb%type /*:= '78';*/
  
) is

begin
/*Пересчет номера для формы процедуры формирования акта из этапа договора */
  if pio_tek_nmb = 1 or out_doc_nmb is null
  then
  
    pio_tek_nmb := 0;

    p_transinvcust_getnextnumb(ncompany  => pin_com
                              ,sjur_pers => pin_jur
                              ,ddocdate  => nvl(pin_doc_date, sysdate)
                              ,stype     => pin_doc_type
                              ,spref     => pin_doc_pref
                              ,snumb     => out_doc_nmb);
  
  end if;

end;
/
