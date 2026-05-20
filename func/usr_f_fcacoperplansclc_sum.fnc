create or replace function usr_f_fcacoperplansclc_sum
(
  nprn        fcacoperplans.rn%type
 ,ncompany    fcacoperplans.company%type
 ,sconst_name udo_tp_strtable
 ,nquant      fcacoperplans.quant%type default 1
) return number is

  v_res fcacoperplansclc.cost_plan%type;
begin
  /* ‘ункци€ находит в заданных в списке констант (sconst_name) значени€, 
     €вл€ющиес€ стать€ми затрат строки калькул€ции заданного графика отпуска (nprn), 
  и возвращает сумму данных строк * на количество (nquant)  */

  
    with zn as
     (select column_value cv from table(sconst_name))
    
    select nvl(sum(clc.cost_plan), 0) * nquant
      into v_res
      from zn
      join constlst cn
        on cn.name = zn.cv
       and cn.company = ncompany
      join fpdartcl sz
        on sz.code = cn.strvalue
      join compverlist v
        on v.version = sz.version
       and v.company = cn.company
       and v.unitcode = 'FinPlanArticles'
      join fcacoperplansclc clc
        on clc.prn = nprn
       and clc.cost_article = sz.rn;
  
    return v_res;
  
  end;
/
