create or replace procedure usr_p_placestorage_copy
(
  ncompany    in number
 ,nstore_to    in number --- КУда
 ,pin_store_from in varchar2 -- Откуда
) is

  --- Копируем места хранения со Склада 2 на Склад 1
  ---grant execute on usr_p_placestorage_copy to public;
  /* Городецкий 04-02-2025 Копирование мест хранения указанног склада в текущий */

  nstore_from azsazslistmt.rn%type;

  nrac_to  stplracks.rn%type;
  nhrn_to stplracks.hrn%type;
  ncell_to  stplcells.rn%type;

begin
  begin  --- RN склада Откуда копируем места хранения
    select skl.rn
      into nstore_from
      from azsazslistmt skl
     where skl.azs_number = pin_store_from
       and skl.company = ncompany;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Склад с которого копируем места хранения (%s) не найден. Выберите корректное значение через словарь.');
    
  end;

  -- По складу откуда
  for stl in (select sth.pref hpref
                    ,sth.numb hnumb
                    ,st.*
                from stplracks st
                left join stplracks sth
                  on sth.rn = st.hrn
               where st.store = nstore_from
               order by st.hier_level -- Стеллажи верхнего уровня заносятся первыми
              )
  
  --- Проверим, есть ли стеллаж с таким префиксом и номером в складе КУДА копируем
  --  Если нет, то заводим на складе КУДА  такой стеллаж
  loop
  
    begin
      select t.rn
        into nrac_to
        from stplracks t
       where t.store = nstore_to
         and t.company = ncompany
         and t.pref = stl.pref
         and t.numb = stl.numb;
    exception
      when no_data_found then
        -- Заводим стеллаж, если он отсутствует
      
        --- Найдем RN Вышестоящего стеллажа HRN на складе назначения, если STL.HRN не Null
        begin
        
          if stl.hrn is not null then
          
            begin
              select t.rn
                into nhrn_to
                from stplracks t
               where t.store = nstore_to
                 and t.company = ncompany
                 and t.pref = stl.hpref
                 and t.numb = stl.hnumb;
            exception
              when no_data_found then
                p_exception(0
                           ,'Для стеллажа %s %s не найден вышестоящий стеллаж %s %s'
                           ,trim(stl.pref)
                           ,trim(stl.numb)
                           ,trim(stl.hpref)
                           ,trim(stl.hnumb));
            end;
          
          else
          
            nhrn_to := null;
          
          end if;
        
          p_stplracks_base_insert(ncompany     => ncompany
                                 ,nhrn         => nhrn_to
                                 ,nstore       => nstore_to
                                 ,nrack        => stl.rack -- Тип стеллажа
                                 ,nzone        => stl.zone -- Зона хранения
                                 ,spref        => stl.pref
                                 ,snumb        => stl.numb
                                 ,nwidth       => stl.width
                                 ,nheight      => stl.height
                                 ,nlength      => stl.length
                                 ,nmaxweight   => stl.maxweight
                                 ,nmu_size     => stl.mu_size
                                 ,nmu_weight   => stl.mu_weight
                                 ,nhorz_offset => stl.horz_offset
                                 ,nvert_offset => stl.vert_offset
                                 ,ntemp_from   => stl.temp_from
                                 ,ntemp_to     => stl.temp_to
                                 ,nhumid_from  => stl.humid_from
                                 ,nhumid_to    => stl.humid_to
                                 ,npart_rmv    => stl.part_rmv
                                 ,nfull_fill   => stl.full_fill
                                 ,ndiff_knd    => stl.diff_knd
                                 ,nmol         => stl.mol
                                 ,sbarcode     => stl.barcode
                                 ,nrn          => nrac_to);
        end;
      
    end;
    --- Проходим по ячейкам стеллажа скдада Откуда
  
    for cel in (select t.* from stplcells t where t.prn = stl.rn)
    
    loop
      -- Если ячейки нет на стеллаже склада Куда, создадим ее
    
      begin
      
        select t.rn
          into ncell_to
          from STPLCELLS t
         where t.prn = nrac_to
           and t.pref = cel.pref
           and t.numb = cel.numb;
      
      exception
        when no_data_found then
        
          begin
          
            p_stplcells_base_insert(ncompany      => ncompany
                                   ,nzone         => cel.zone
                                   ,nplace        => cel.place
                                   ,nprn          => nrac_to
                                   ,spref         => cel.pref
                                   ,snumb         => cel.numb
                                   ,ntier         => cel.tier
                                   ,nwidth        => cel.width
                                   ,ndepth        => cel.depth
                                   ,nheight       => cel.height
                                   ,nmaxweight    => cel.maxweight
                                   ,nis_avail     => cel.is_avail
                                   ,nmu_size      => cel.mu_size
                                   ,nmu_weight    => cel.mu_weight
                                   ,nhorz_offset  => cel.horz_offset
                                   ,nvert_offset  => cel.vert_offset
                                   ,npart_rmv     => cel.part_rmv
                                   ,nfull_fill    => cel.full_fill
                                   ,ndiff_knd     => cel.diff_knd
                                   ,ntemp_from    => cel.temp_from
                                   ,ntemp_to      => cel.temp_to
                                   ,nhumid_from   => cel.humid_from
                                   ,nhumid_to     => cel.humid_to
                                   ,sbarcode      => cel.barcode
                                   ,nunload_place => cel.unload_place
                                   ,nship_place   => cel.ship_place
                                   ,nrn           => ncell_to);
          
          end;
        
      end;
    
    end loop;
  
  end loop;

end;
/
