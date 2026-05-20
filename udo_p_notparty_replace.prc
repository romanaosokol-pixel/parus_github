create or replace procedure UDO_P_NOTPARTY_REPLACE
(
  nCOMPANY  in number,
  nTRINVDEP in number
) as
  /*
    30/05/2023 Марков МВ.
    Перевод 4-значных серий в отдельную партию
    Признак партии - не использовать.
    Запрет резервирования этой партии в заказах подразделений.
  */
  nSTORE number(17) := 43093662;
begin
  -- заголовок уже созден!!!!
  null;
  -- спецификация
  for rec in (select gp.sernumb,
                     gs.restfact,
                     gs.store
                from goodsparties gp,
                     goodssupply  gs
               where gp.sernumb like '____'
                 and gs.prn = gp.rn
                 and gs.restfact > 0
                 and gs.store = nSTORE) loop
    null; --p_transinvdeptsp_base_insert
  end loop;
  
end;
/

