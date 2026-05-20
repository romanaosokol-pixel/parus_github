create or replace procedure usr_p_finplan_arts_imp_ext2_s1
(
  finplan_rn in number
 ,dept_code  in varchar2
 ,syyyy      in varchar
 ,out_err_txt    out varchar2
) is
  v_parus_yyyy     varchar2(4);
  v_parus_dep_code ins_department.code%type;
  sgroupbudg       dicsmrks.smark_mnemo%type;
begin
  /* Проверка корректности заголовка файла загрузки */
  begin
    select dep.code
          ,extract(year from rp.startdate)
          ,gb.smark_mnemo
      into v_parus_dep_code
          ,v_parus_yyyy
          ,sgroupbudg
      from USR_T_BUDGET_ALLOCATION BR
      join udo_t_finplan t on T.rn = br.finplan
      left join ins_department dep
        on dep.rn = t.depord
      join enperiod rp
        on rp.rn = t.fp_period
      join dicsmrks gb
        on gb.rn = t.groupbudg
     where br.rn = finplan_rn;
  exception
    when no_data_found then
      out_err_txt := 'Распределение бюджета с RN = ' || finplan_rn || ', в который хотим загрузить данные, не найдены.';
  end;

  if sgroupbudg != 'test'
  then
    p_exception(0, 'Загружать данные можно только в бюджет с группой = "test", а вы загружаете в бюджет группы '||sgroupbudg);
  end if;
 
 if v_parus_dep_code is null
  then
    out_err_txt := 'В Бюджете с RN = ' || finplan_rn || ', в который хотим загрузить данные, не задан "Код отдела". Задайте его через словарь.';
  end if;

  if v_parus_dep_code != dept_code
  then
    out_err_txt := 'В Бюджете с RN = ' || finplan_rn || ', в который хотим загрузить данные, задан "Код отдела" = ||v_parus_dep_code||. ' ||
               ' А в файле загрузки задан код отдела ' || dept_code || ' они не совпадают. Возможны вы загружаете не в тот бюджет.';
  end if;

  if v_parus_yyyy != syyyy
  then
    out_err_txt := 'В Бюджете с RN = ' || finplan_rn || ', в который хотим загрузить данные, задан "Год бюджета" = ' || v_parus_yyyy ||
               '. А в файле загрузки задан год бюджета ' || syyyy || '.' || ' Они не совпадают. Возможны вы загружаете не в тот бюджет.';
  end if;
end;
/
