create or replace procedure USR_P_TIC_SP_AMAKECORR(nrn in number) is

begin
  for cur in (
select NKB.DOCTYPE, NKB.rn
  from selectlist SL
  join TRANSINVCUSTBUF NKB on SL.Ident = NKB.Ident
 where sl.document = nrn)
 loop
   P_exception(0, cur.rn);--- Корректируем тип документа

 end loop;

end;
/
