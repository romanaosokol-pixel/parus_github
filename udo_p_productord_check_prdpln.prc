create or replace procedure UDO_P_PRODUCTORD_CHECK_PRDPLN
(
  nRN                         in number -- рег. номер заказа на производство 
) 
is
  /*
    Процедура для неименованного блока, контролирующего тип плана производства. Включать заказ можно только в план выпуска.
  */
  nCATEGORY                   fcprodplan.category%type; -- категория (0 – Первичный документ, 1 – Производственная программа, 2 – Цеховой план, 3 – План подразделения, 4 – План поузловой сборки)          
begin
  /* поиск связанного с ЗП плана выпуска */
  begin 
    select pp.CATEGORY
      into nCATEGORY 
      from doclinks dl,
           fcprodplan pp
     where dl.in_unitcode  = 'ProductionOrders'
       and dl.in_document  = nRN
       and dl.out_unitcode = 'CostProductPlans'
       and dl.out_document = pp.rn;
  exception 
    when no_data_found then 
      nCATEGORY := null;
    when too_many_rows then 
      p_exception(0, 'Заказ уже включен в план выпуска.');
  end; 
  
  if nCATEGORY is not null and nCATEGORY != 0 then 
    p_exception(0, 'Заказ на призводство может быть включен только в план выпуска (документ должен иметь признак "Первичный документ").');
  end if; 

end UDO_P_PRODUCTORD_CHECK_PRDPLN;
/

