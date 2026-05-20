create or replace procedure usr_p_matres_resp_ins_ini(ncrn  in number
                                                     ,nmrrn in number
                                                     ,scatalog        out varchar2
                                                     ,snomencode      out varchar2
                                                     ,smodif_code     out varchar2
                                                     ,vis_scatalog    out number
                                                     ,vis_snomencode  out number
                                                     ,vis_smodif_code out number) is

  ---rec usr_tab_matres_response%rowtype; --Куда пишем

begin

  /* Поиск каталога */
  begin
    select ac.name
      into scatalog
      from acatalog ac
     where ac.rn = ncrn;
  exception
    when no_data_found then
      scatalog := null;
  end;

  /* Поиск Номенклатуры и модификации Материального ресурса */
  begin
    select d.nomen_code
          ,nm.modif_code
      into snomencode
          ,smodif_code
      from fcmatresource mr
      join dicnomns d
        on d.rn = mr.nomenclature
      join nommodif nm
        on nm.rn = mr.nomen_modif
       and d.rn = nm.prn
     where mr.rn = nmrrn;
  exception
    when no_data_found then
      snomencode := null;
    
  end;

  if scatalog is null
  then
    vis_scatalog := 1;
  else
    vis_scatalog := 0;
  end if;
  if snomencode is null
  then
    vis_snomencode  := 1;
    vis_smodif_code := 1;
  else
    vis_snomencode  := 0;
    vis_smodif_code := 0;
  end if;

end;
/
