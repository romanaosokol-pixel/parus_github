create or replace function usr_f_stages_price_SZ(nrn in stages.rn%type, sz_code in FPDARTCL.CODE%type ) return number is

V_RES CONTRPRCLC.Cost_Sum%type;

begin
/*
Сумма из калькуляции структуры цены этапа договора
Городецкий 27-04-2026
*/

begin
select sum(cl.cost_sum)
  into v_res
  from contrprstruct str
  join contrprclc cl
    on cl.prn = str.rn
  join fpdartcl sz
    on sz.rn = cl.cost_article
 where str.prn = nrn
   and str.SIGN_ACT = 1 /* Действующая */
   and sz.code = sz_code
   and sz.version = 91451 /*Версия у нас одна */;

exception when no_data_found then return 0;

end;

return v_res;

end;
/
