create or replace function usr_f_prjcalcschmart_nmb
(
  nprn      number
 ,nfpdartcl number
) return varchar2 is

  v_res prjcalcschmsp.numb%type;

  /* Доп. колонка отображающая номер статьи в окне "Входящие статьми затрат" */

begin

  begin
    select trim(str1.numb) nmb
      into v_res
      from prjcalcschmsp str
      join prjcalcschmsp str1
        on str1.prn = str.prn     
     where str.rn = nprn
       and str1.fpdartcl = nfpdartcl;
  
  exception
    when no_data_found then
      v_res := null;
    
  end;
  return v_res;
end;
/
