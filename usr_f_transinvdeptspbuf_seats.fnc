create or replace function usr_f_transinvdeptspbuf_seats
(
  pin_idn        in number
 ,pin_nommodif   in number
 ,pin_goodsparty in number
) return varchar2 is

  sres varchar2(2000);
begin
  begin
    select udo_f_transinvdeptspecs_seats(sp.rn)
      into sres
      from selectlist sl
      join transinvdeptspecs sp
        on sp.prn = sl.document
     where sl.ident = pin_idn
       and sp.goodsparty = pin_goodsparty
       and sp.nommodif = pin_nommodif
       and rownum = 1;
  exception
    when no_data_found then
      return null;
  end;
  return sres;
end;
/
