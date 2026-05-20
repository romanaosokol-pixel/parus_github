create or replace procedure UDO_P_LOADEXT_ORD_SP_QUANT
(
  nIDENT   in number, -- отмеченная запись
  nCOMPANY in number, -- организация
  nQUANT   in number -- новое количество
) as
  /*
    15/05/2023 Марков МВ.
    Загрузка спецификаций
    Установить количество.
    Загрузки из Интермеха иногда с нуевым количеством!!!!
    Только для роли ПУДП.ПДО
  */
  nRN number(17);
begin
  --
  if utilizer not in ('MARANICHENKO_AP', 'CITK_MARKOV') then
    p_exception(0,
                'У Вас нет прав на изменение количества в загрузке. Обратитесь к Администратору!');
  end if;
  --
  begin
    select SP.RN
      into nRN
      from UDO_LOADEXT_ORD_SP SP
     where SP.RN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT);
  exception
    when no_data_found then
      p_exception(0, 'Запись спецификации загрузки не найдена.');
    when too_many_rows then
      p_exception(0, 'Изменить количество можно только для одной записи!');
  end;
  --
  update UDO_LOADEXT_ORD_SP SP set SP.EXT_QNT = nQUANT where SP.RN = nRN;
end;
/

