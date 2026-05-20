create or replace procedure usr_p_stages_upd_nmb
(
  nrn          in stages.rn%type
 ,ncompany     in companies.rn%type
 ,snmb         in stages.numb%type
 ,nmode        in number
 ,snmb_old     in stages.numb%type
 ,pin_sign_sum in stages.sign_sum%type -- Признак включения суммы этапа в сумму догоора
  
) is

  s_old_nmb  stages.numb%type;
  nprn       contracts.rn%type;
  nfl        integer := 1;
  v_sign_sum stages.sign_sum%type;

  ntmp       pkg_std.tlnumber;
  v_sum_type contracts.sum_type%type;

begin
  /*
    Процедура исправляет:
    1. Номер конкртеного этапа если паремтр snmb не совпадает с номером этапа.
    2. Если nmode = 1, то исправляются номера всех этапов, сортируются в порядке возрастания текущих номеров и переименовываются от 1 ....
    3. Признак включения в сумму догоолра
  */

  select st.prn
        ,st.numb
        ,st.sign_sum
        ,dog.sum_type
    into nprn
        ,s_old_nmb
        ,v_sign_sum
        ,v_sum_type
    from stages st
    join contracts dog
      on dog.rn = st.prn
   where st.rn = nrn;

  if nmode = 0
  then
    -- меняем конкретный номер
  
    if s_old_nmb != snmb
    then
      -- есть что менять
    
      --- Проверим, что нет пересечения номеров
    
      begin
        select 0
          into nfl
          from stages st
         where st.prn = nprn
           and st.rn != nrn
           and st.numb = snmb
           and rownum = 1;
      exception
        when no_data_found then
        
          update stages t set t.numb = trim(snmb) where t.rn = nrn;
      end;
    
      p_exception(nfl
                 ,'Нельзя изменить номер этапа на %s, так как этап с таким номером уже существует.');
    
    end if;
  
  else
  
    for cur in (select t.rn
                      ,dense_rank() over(partition by t.prn order by t.numb) nn
                  from stages t
                
                 where t.prn = nprn)
    loop
    
      update stages t set t.numb = cur.nn where t.rn = cur.rn;
    
    end loop;
  end if;

  if v_sign_sum != pin_sign_sum
  then
    if v_sum_type = 0
    then
      p_exception(0
                 ,'Нельзя менять признак включения суммы этапа в сумме договора можно только в договорах у которых установлен признак "Расчетные суммы"');
    end if;
  
    --- Исправим признак
    update stages t set t.sign_sum = pin_sign_sum where t.rn = nrn;
    -- Пересчитаем шапку договора
  
    p_cotracts_setsums(ncompany
                      ,nprn
                      ,1
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp
                      ,ntmp);
  
  end if;

  ---grant execute on usr_p_stages_upd_nmb to public;
end;
/
