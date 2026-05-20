create or replace procedure usr_p_matres_resp_upd_ini(nrn             in number
                                                     ,ncrn            in number
                                                     ,scatalog        out varchar2
                                                     ,snomencode      out varchar2
                                                     ,smodif_code     out varchar2
                                                     ,sresponsib_type out extra_dicts_values.str_value%type /*Код Типа ответсвенного */
                                                     ,vis_scatalog    out number
                                                     ,vis_snomencode  out number
                                                     ,vis_smodif_code out number
                                                     ,ERR_TXT         out varchar2) is

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
          ,(select dv.str_value
             from extra_dicts_values dv
            where dv.rn = t.response_type)
      into snomencode
          ,smodif_code
          ,sresponsib_type
      from usr_tab_matres_response t
      join fcmatresource mr
        on mr.rn = t.prn
      join dicnomns d
        on d.rn = mr.nomenclature
      join nommodif nm
        on nm.rn = mr.nomen_modif
       and d.rn = nm.prn
     where t.rn = nrn;
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

  vis_snomencode  := 1;
  vis_smodif_code := 1;
  
  ERR_TXT:=null;

end;
/
