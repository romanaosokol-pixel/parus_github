create or replace procedure usr_p_calc_detail_modif(nprn        in payaccinspclc.rn%type
                                                   ,sunitcode   in unitlist.unitcode%type
                                                   ,nalloc_arts in usr_t_alloc_arts.rn%type
                                                   ,nrn         out usr_tab_calc_detail.rn%type) is

  /*
  Обновление ссылки на бюджетное распределение из калькуляции к разделу
  для ускорения формирования выборок данных
  Городецкий 01-04-2026
  */

begin

  begin
  
    select t.rn
      into nrn
      from usr_tab_calc_detail t
     where t.prn = nprn;
  
  exception
    when no_data_found then
    
      nrn := gen_id_fix;
    
      insert into usr_tab_calc_detail
        (rn
        ,unitcode
        ,alloc_arts
        ,prn)
      values
        (nrn
        ,sunitcode
        ,nalloc_arts
        ,nprn);
    
      return;
    
  end;

  update usr_tab_calc_detail t
     set t.alloc_arts = nalloc_arts
   where t.rn = nrn;

end;
/
