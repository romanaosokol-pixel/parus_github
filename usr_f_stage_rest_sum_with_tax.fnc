create or replace function usr_f_stage_rest_sum_with_tax
/*
  Этапы договоров
  Функция для колонки - #Осталось отгрузить (сумма c налогами)
  
  28/01/2026 Городецкий
  */
(nfaceacc in stages.faceacc%type) return number is
  nres fcacoperplans.summwithnds%type;
  
   nfl number(1);
  
begin

  /*Проверим, есть ли график отгрузки
  Если есть, то берем сумму остатков отгрузки из строк графика
  Если нет, то берем не отгружено из этапа */
  begin
    select 1
      into nfl
      from fcacoperplans ot
     where ot.prn = nfaceacc
       and rownum = 1;
  exception
    when no_data_found then
      nfl := 0;
    
  end;

  if nfl = 1
  then
    /*График есть */
  
    select nvl(sum( usr_f_faoop_rest_sum_with_tax ( nRN => t.rn, nSUMMWITHNDS =>  t.summwithnds)), 0) 
      into nres 
      from fcacoperplans t where t.prn = nfaceacc;
  
  else
    /* Графика нет */
  
    select st.stage_sum - nvl(usr_pkg_faceacc.faceacc_get_fact_summs(nrn => nfaceacc, ssum_type => 'FULL_LOAD_SUM'),0)
      into nres
      from stages st
     where st.faceacc = nfaceacc;
  
  end if;

  return nres;

end;
/
