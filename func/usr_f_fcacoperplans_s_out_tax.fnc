create or replace function USR_F_FCACOPERPLANS_S_OUT_TAX(NRN in number, nSUMM in number) return number is

  nRes TRANSINVCUSTSPECS.Summ%type;

begin
  /* Функция для колонки - #Осталось отгрузить Сумма без НДС  */
  /* Городецкий О.И. 10/12/2024 */

  select sum(trs.SUMM)
  into nRes
  from UDO_T_TRANSINVCUSTSPECS_EX ex
   join  TRANSINVCUSTSPECS trs on trs.rn = ex.prn
  where  ex.fcacoperplans = NRN;
    
    
  return(nSumm - nvl(nRes,0));
end;
--grant execute on USR_F_FCACOPERPLANS_S_OUT_TAX to public;
/
