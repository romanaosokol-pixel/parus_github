create or replace procedure usr_alloc_arts_det_cntrl(nprn          in usr_t_alloc_arts.rn%type
                                                    ,ncompany      in companies.rn%type
                                                    ,sfaceacc_numb in faceacc.numb%type
                                                    ,serr_txt      out varchar2) is

  /*
  Процедура контроля данных в детализации бюджетного распределения
  привязка лицевых счетов документов к статьям бюджетного распределения  (подстатьям бюджета)
  
  Городецкий О.И. 08-05-2026
  
  */
  nfaceacc faceacc.rn%type;

begin

if sfaceacc_numb is null then return; end if;  /*Пока шпз не проверяем выходим*/

  begin
  
    select f.rn
      into nfaceacc
      from faceacc f
     where f.numb = sfaceacc_numb
       and f.company = ncompany;
  exception
    when no_data_found then
      serr_txt := 'Лицевой счет с номером ' || sfaceacc_numb || ' не найден.';
      return;
    
  end;

  /*проверим, что данный лицевой счет не присвоен другой статье бюджетного распределения в данном году */

  with new_date as /* Определяем период добавляемой детализации */
   (select bj.fp_period
      from usr_t_alloc_arts brs
      join usr_t_budget_allocation br
        on br.rn = brs.prn
      join udo_t_finplan bj
        on bj.rn = br.finplan
     where brs.rn = nprn),
  
  old_date as
   (select brs.art_numb
          ,bj.fp_code
          ,fpa.art_numb bj_art
      from usr_t_alloc_arts_det brsd
      join usr_t_alloc_arts brs
        on brs.rn = brsd.prn
      join usr_t_budget_allocation br
        on br.rn = brs.prn
      join udo_t_finplan bj
        on bj.rn = br.finplan
      join new_date
        on brsd.prn != nprn
       and bj.fp_period = new_date.fp_period
       and brsd.faceacc = nfaceacc
      join udo_t_finplan_arts fpa
        on fpa.rn = brs.finplan_arts)
  select 'Данный лицевой счет уже привязан к статье бюджетного распределения ' || old_date.bj_art || ' подстатья ' || old_date.art_numb || ' в бюджете "' || old_date.fp_code || '"'
    into serr_txt
    from old_date;

exception
  when no_data_found then
    return; /*Пока проверка одна, просто выходим из процедуры*/
end;
/
