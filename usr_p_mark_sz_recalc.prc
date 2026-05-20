create or replace procedure usr_p_mark_sz_recalc(pin_com   in number
                                                ,pin_syear in varchar2) is

  --  pin_com   number(17):= 90521;
  ---  pin_syear varchar2(4):= '2026';

  v_f_sz faceacc.rn%type;

begin

  /*
  
  Добавляем в показатели ПОДСТАТЬЮ (лицевой счет из рапределения бюджета) по платежам, которые созданы не по счетам
  
  При этом статья затрат, заданная в лицевом счете платежа, определеяет подстатью однозначно.
  */

  /* Отберем показатели, созданные по журналу платежей, в которых не задан лицевой счет, определяющих Подстатью бюджета Alloc_Arts_Faceacc */

  for cur in (select f.ieelement sz
                    ,pk.rn
                    ,pn.company
                from paynotes pn
                join udo_t_mark pk
                  on pk.document = pn.rn
                join faceacc f
                  on f.rn = pn.faceacc
               where extract(year from pn.pay_date) = pin_syear
                 and pk.alloc_arts_faceacc is null
              
              )
  
  loop
  
    /*Определим, что у статьи единственное распределение по всем  бюджетам заданного года */
    begin
      select distinct brs.faceacc_cost
        into v_f_sz
        from udo_t_finplan_arts bjs
        join usr_t_alloc_arts brs
          on brs.finplan_arts = bjs.rn
        join udo_t_finplan bj
          on bj.rn = bjs.prn
        join enperiod per
          on per.rn = bj.fp_period
       where bjs.fpdartcl = cur.sz /* Состав затрат */
         and extract(year from per.startdate) = pin_syear /*Год показателя */
         and bj.company = pin_com /* Организация */
         and bj.fp_type = 6336511 /* БДДСП_подр */
         and bj.groupbudg = 6419333; /* План */
    exception
      when too_many_rows
           or no_data_found then
        v_f_sz := null;
    end;
  
    if v_f_sz is not null
    then
    
      update udo_t_mark pk set pk.alloc_arts_faceacc = v_f_sz where pk.rn = cur.rn;
    
    end if;
  
  end loop;

end;
/
