create or replace procedure UDO_P_LOADEXT_ORD_FORM_EDIT_CH
(
  nCOMPANY                  in number,                -- Организация
  nRN                       in out number,            -- Регистрационный номер
  nPRODORD_CH               in out number             -- обязательность для заказа на производство (0 - нет, 1 - да)
) as
  /*
    26/05/2023 Марков МВ.
    Загрузка из внешних источников.
    Открытие формы редактирования заголовка.
  */
  rORD UDO_LOADEXT_ORD%rowtype;
begin
  select *
    into rORD
    from UDO_LOADEXT_ORD ORD
    where ORD.RN = nRN
      and ORD.COMPANY = nCOMPANY;
  -- проверка на тип загрузки
  if rORD.Load = 1 then
    -- Спецификация (ИНТЕРМЕХ)
    nPRODORD_CH := 0; -- заказ на производство не обязателен
  end if;
  
exception
  when no_data_found then
    nPRODORD_CH := 1;
end;
/

