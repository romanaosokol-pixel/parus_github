create or replace procedure UDO_P_PAYACCIN_CHECK_DAYS
(
  nCOMPANY in number,
  nRN      in number
) as
  /*
    23/03/2023 Марков МВ.
    Входящие счета на оплату
    Неименованный блок
    Контроль наличия дней поставки по всем позициям, связанным с заказами подразделений по производству
    При утверждении счета на оплату
  */
begin
  -- по каждой спецификации
  for rsp in (select SP.RN,
                     SPC.RN CLC_RN,
                     (select DV.NUM_VALUE
                        from DOCS_PROPS_VALS DV
                       where DV.UNIT_RN = SP.RN
                         and DV.DOCS_PROP_RN = 7551156) N_DAYS
                from PAYACCINSPEC  SP,
                     PAYACCINSPCLC SPC
               where SP.PRN = nRN
                 and SP.COMPANY = nCOMPANY
                 and SPC.PRN = SP.RN) loop
  
    -- при наличии связи с заказом подразделения
    for rce in (select CEX.DEPARTMENTORD
                  from PAYACCINSPCLC_EX CEX
                 where CEX.PRN = rsp.clc_rn
                   and exists(select null from DOCLINKS L where L.OUT_DOCUMENT = CEX.DEPARTMENTORD and L.OUT_UNITCODE = 'DepartmentsOrders'
                       and L.IN_UNITCODE in ('CostProductExpenseActs', 'ProductionOrders'))) loop
      if rsp.n_days is null or rsp.n_days < 0 then
        p_exception(0, 'По спецификации счета на оплату,' ||
                       ' связанного с производственным заказом подразделения' ||
                       ' необходимо указать количество дней поставки.');
      end if;
    end loop;
  end loop;
end UDO_P_PAYACCIN_CHECK_DAYS;
/

