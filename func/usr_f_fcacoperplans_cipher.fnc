create or replace function usr_f_fcacoperplans_cipher
(
  nprn      fcacoperplans.prn%type
 ,ncompany  fcacoperplans.company%type
 ,nnomprice fcacoperplans.nomprice%type
) return varchar2 is

  sres faceacc.numb%type;
  /*
  Доп колонка графика отпуска товаров и услуг этапа договора, выводящая
  ШПЗ шифр производственных затрат
  1. Лицевой счет ЗАТРАТ этапа связанного с договором проекта у которого лицевой счет совпадает с лицевым счетом этапа договора
  2. Значения свойства "ШПЗ" учетной цены по котрой сформирована калькуляция графика отпуска
  
  grant execute on usr_f_fcacoperplans_cipher to public;
  */
begin
  begin /* 1 */
    select fp.numb
      into sres
      from projectstage pst
      join faceacc fp
        on fp.rn = pst.faceacc
     where pst.faceacccust = nprn;
  exception
    when no_data_found then
      /* 2 */
      begin
        select zsv.str_value
          into sres
          from docs_props_vals zsv
         where zsv.unit_rn = nnomprice
           and zsv.unitcode = 'NomenclatorPrice'
           and zsv.company = ncompany
           and zsv.docs_prop_rn = 12047550; -- Rn свойства с кодом "ШПЗ"
      exception
        when no_data_found then
          sres := null; /* не нашли совсем */
      end;
    
  end;

  return sres;

end;
/
