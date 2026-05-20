create or replace procedure usr_p_inorders_mol_chg
(
  nident selectlist.ident%type
 ,sagent agnlist.agnabbr%type
) is

  v_nmol inorders.agent%type;
begin
/* Меняем контрагнета в ПО */
  begin
    select mol.rn into v_nmol from agnlist mol where mol.agnabbr = sagent;
  exception
    when no_data_found then
      p_exception(0, 'Контрагнет %s не найден!', sagent);
    
  end;

  /*Найдем RN агента*/

  update inorders i
     set i.agent = v_nmol
   where i.rn in (select sl.document
                    from selectlist sl
                   where sl.ident = nident
                     and sl.authid = utilizer
                     and sl.unitcode = 'IncomingOrders');

end;
/
