create or replace function usr_f_goodssupply_faceacc(nrn in GOODSSUPPLY.rn%type) return UDO_TP_STRTABLE
    pipelined is
  begin

/*Городецкий 10-04-2026  
Процедура список номеров Лицевых счетов  (заказ) из калькуляции затрат товарного запаса
Количество в калькуляции больше 0  (чаще всего такой запас единственный)  (Плановое или фактическое количество ?)
Используется для формирования окна выбора в форме Переноса между темами usr_p_faceacc_replace_cre1 и т.п.
*/

for cur in (
select fa.numb      
  from goodssupply gy
  join goodssupplyhist h
    on h.prn = gy.rn
  join goodssupplyclc cl
    on cl.prn = gy.rn
  join faceacc fa
    on fa.rn = cl.faceacc
 where gy.rn = nrn
   and h.date_from = (select max(h1.date_from)
                        from goodssupplyhist h1
                       where h1.prn = gy.rn)                       
   and least(h.min_restplan, h.min_restfact) >0
)

loop
        pipe row(cur.numb);


end loop;

end;
/
