create or replace procedure USR_P_GP_GET_PRODMAIN_PCS
/*
Приходные партии товара
Показать головные изделия по входному контролю
Степанов М. 18/09/2023
*/
(
 nRN        in number
,sRES       out varchar2
)
is
begin

  begin
  select substr(udo_f_prod_cull_sp_mainprod(nrn => rn), 0, 3999)
    into sRES
    from udo_prod_cull_sp t
   where t.goodsparty = nRN;
  exception
    when no_data_found then
      null;   
    when too_many_rows then
      null;   
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске головного изделия по входному контролю по приходной партии с RN: <%s>', nRN); 
   end;

end USR_P_GP_GET_PRODMAIN_PCS;
/
