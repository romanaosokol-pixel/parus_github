create or replace procedure usr_p_prjcalcschmsp_insz
/*grant execute on USR_P_PRJCALCSCHMSP_INSZ to public;*/
/* Процедура выводит список статей затрат в которые входит статья с RN = nRN Для схемы калькуляции*/

(
  nRN  in number
 ,sRES out varchar2
) is

begin
  sRES := '!';
  for cur in (with sz as
                 (select t.prn
                       ,t.fpdartcl
                   from prjcalcschmsp t
                  where t.rn = nrn)
                
                select trim(isz.numb) || ' ' || fp.code res
                  from sz
                  join prjcalcschmsp isz
                    on isz.prn = sz.prn --- Все статьи входящие в структуру расходов искомой
                  join prjcalcschmart vsz -- отбираю Статьи в которые входит искомая
                    on vsz.prn = isz.rn
                   and vsz.fpdartcl = sz.fpdartcl
                  join fpdartcl fp
                    on fp.rn = isz.fpdartcl
                
                 order by 1)
  loop
    if length(sRES) < 1700 then
      sRES := sRES || chr(10) || cur.res;
    end if;
  
  end loop;
  sRES := substr(SRES, 3);
end;
/
