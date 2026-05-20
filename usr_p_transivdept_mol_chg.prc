create or replace procedure usr_p_transivdept_mol_chg
(
  nident selectlist.ident%type
 ,s_mol agnlist.agnabbr%type
 ,s_in_mol agnlist.agnabbr%type
) is

  v_nmol transinvdept.mol%type;
  v_innmol transinvdept.in_mol%type;
begin
/* Меняем контрагнета в расходной накданой в подразделения */
  
  /*Найдем RN МОЛ*/
  begin
    select mol.rn into v_nmol from agnlist mol where mol.agnabbr = s_mol;
  exception
    when no_data_found then
      p_exception(0, 'МОЛ "от кого" %s не найден!', s_mol);
    
  end;
  
   begin
    select mol.rn into v_nmol from agnlist mol where mol.agnabbr = s_in_mol;
  exception
    when no_data_found then
      p_exception(0, 'МОЛ "кому" %s не найден!', s_in_mol);
    
  end;

  

  update transinvdept i
     set i.mol = v_nmol,
         i.in_mol = v_innmol
   where i.rn in (select sl.document
                    from selectlist sl
                   where sl.ident = nident
                     and sl.authid = utilizer
                     ---and sl.unitcode = 'IncomingOrders'
                     );

end;
/
