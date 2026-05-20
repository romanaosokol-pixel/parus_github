create or replace procedure udo_p_updatelist_fill_table(nrn       in number
                                                       ,sunitcode in varchar
                                                       , -- раздел
                                                        ddatebgn  in date
                                                       , -- дата с
                                                        ddateend  in date
                                                       , -- дата по
                                                        sauthid   in varchar2
                                                       , -- пользователь
                                                        nvidel    in number
                                                       , -- по выделенным
                                                        ndel      in number
                                                       , -- удаление
                                                        nins      in number
                                                       , -- добавление
                                                        nupd      in number
                                                       , -- изменение
                                                        noth      in number
                                                       ,nvdeist   in number
                                                       ,nbphist   in number
                                                       , -- По журналу бизнес процессов
                                                        saction   in varchar2
                                                       ,ntablern  in number) as
  /*
    15/07/2022 Марков МВ.
    Отчет обо всех изменениях документа из UPDATELIST + arc "Журнал событий"
    
    10-02-2026 Городецкий 
    Добавил информацию об удалении строк спецификации документа (Должно быть зарегистрировано изменение поля PRN спецификации
    (Ограничил одним разделом UDO_T_FINPLAN_CONF_ARTS, расширим после тастирвоания)
    
    
  */

  nflag      pkg_std.tref;
  snote      pkg_std.tlstring;
  stablename pkg_std.tstring;
  ddatebgn1  pkg_std.tldate;
  ddateend1  pkg_std.tldate;
  soperation pkg_std.tstring;
  sactcode   pkg_std.tstring;

  procedure get_note(ndocument  in number
                    ,stablename in varchar2
                    ,sgnote     out varchar2) is
  begin
  
    sgnote := '';
  
    for sp in (select udo_f_updatelist_get_oval(stablename
                                               ,ud.scolumn_name
                                               ,ud.sstr_ref_value
                                               ,ud.ndata_type
                                               ,ud.sstr_value
                                               ,ud.nnum_value
                                               ,ud.ddate_value) as spec_value
                 from udo_v_updatelist_detail_nopriv ud
                where ud.nprn = ndocument
                  and ud.nis_null = 0
               union all
               select udo_f_updatelist_get_oval(stablename
                                               ,uda.scolumn_name
                                               ,uda.sstr_ref_value
                                               ,uda.ndata_type
                                               ,uda.sstr_value
                                               ,uda.nnum_value
                                               ,uda.ddate_value) as spec_value
                 from udo_v_updlist_det_arc_nopriv uda
                where uda.nprn = ndocument
                  and uda.nis_null = 0)
    loop
      sgnote := sgnote || '|' || trim(sp.spec_value);
    end loop;
  
  end;

  procedure ins(ndocument in number) is
  begin
   
    
    if nbphist = 0
    then
    
      if nvdeist = 1
      then
      
        for rec in (
                    
                      with tab_prn as
                       (
                        
                        select uld.num_value prn
                               ,ul.tablern
                               ,ul.note
                               ,ul.rn
                               ,ul.tablename
                               ,ul.modifdate
                               ,ul.operation
                               ,ul.authid
                               ,ul.osuser                              
                          from updatelist ul
                          join updatelist_detail uld
                            on uld.prn = ul.rn
                         where ul.tablename = 'UDO_T_FINPLAN_CONF_ARTS'
                           and ul.operation = 'D'
                           and uld.column_name = 'PRN'
                        
                        union all
                        
                        select uld.num_value prn
                               ,ul.tablern
                               ,ul.note
                               ,ul.rn
                               ,ul.tablename
                               ,ul.modifdate
                               ,ul.operation
                               ,ul.authid
                               ,ul.osuser                              
                          from updatelist_arc ul
                          join updatelist_detail_arc uld
                            on uld.prn = ul.rn
                         where ul.tablename = 'UDO_T_FINPLAN_CONF_ARTS'
                           and ul.operation = 'D' 
                           and uld.column_name = 'PRN')
                      
                      select u.rn
                            ,u.tablename
                            ,u.modifdate
                            ,u.operation
                            ,u.authid
                            ,u.osuser
                            ,u.note
                        from updatelist u
                       where u.tablern = ndocument
                      union all
                      select ua.rn
                            ,ua.tablename
                            ,ua.modifdate
                            ,ua.operation
                            ,ua.authid
                            ,ua.osuser
                            ,ua.note
                        from updatelist_arc ua
                       where ua.tablern = ndocument
                      
                      union all
                      /*Выводим данные по удаленным записям спецификации */
                      select tab_prn.rn               
                            ,tab_prn.tablename
                            ,tab_prn.modifdate
                            ,tab_prn.operation
                            ,tab_prn.authid
                            ,tab_prn.osuser
                            ,tab_prn.note                      
                        from tab_prn
                       where tab_prn.prn = ndocument
                      
                    )
        loop
       
          get_note(rec.rn, rec.tablename, snote);
        
          /*sNOTE := nvl(sNOTE, rec.note);*/
          snote := strcombine(snote, rec.note, cr || cr);
        
          insert into udo_t_updatelist_rep
            (dmodifdate
            ,soperation
            ,sauthid
            ,sosuser
            ,sspec_value
            ,sauthid_user)
          values
            (rec.modifdate
            ,rec.operation
            ,rec.authid
            ,rec.osuser
            ,snote
            ,utilizer);
        
        end loop;
      
      else
      
        for rec in (
        with tab_prn as
                       (
                        
                        select uld.num_value prn
                               ,ul.tablern
                               ,ul.note
                               ,ul.rn
                               ,ul.tablename
                               ,ul.modifdate
                               ,ul.operation
                               ,ul.authid
                               ,ul.osuser                              
                          from updatelist ul
                          join updatelist_detail uld
                            on uld.prn = ul.rn
                         where ul.tablename = 'UDO_T_FINPLAN_CONF_ARTS'
                           and ul.operation = 'D'
                           and uld.column_name = 'PRN'
                        
                        union all
                        
                        select uld.num_value prn
                               ,ul.tablern
                               ,ul.note
                               ,ul.rn
                               ,ul.tablename
                               ,ul.modifdate
                               ,ul.operation
                               ,ul.authid
                               ,ul.osuser                              
                          from updatelist_arc ul
                          join updatelist_detail_arc uld
                            on uld.prn = ul.rn
                         where ul.tablename = 'UDO_T_FINPLAN_CONF_ARTS'
                           and ul.operation = 'D'
                           and uld.column_name = 'PRN')
        select u.rn
                          ,u.tablename
                          ,u.modifdate
                          ,u.operation
                          ,u.authid
                          ,u.osuser
                          ,u.note
                          ,u.tablern
                      from updatelist u
                     where u.tablern = ndocument
                       and ((u.operation = 'I' and nins = 1) or (u.operation = 'U' and nupd = 1) or (u.operation = 'D' and ndel = 1))
                    union all
                    select ua.rn
                          ,ua.tablename
                          ,ua.modifdate
                          ,ua.operation
                          ,ua.authid
                          ,ua.osuser
                          ,ua.note
                          ,ua.tablern
                      from updatelist_arc ua
                     where ua.tablern = ndocument
                       and ((ua.operation = 'I' and nins = 1) or (ua.operation = 'U' and nupd = 1) or (ua.operation = 'D' and ndel = 1))
                        union all
                      /*Выводим данные по удаленным записям спецификации */
                      select tab_prn.rn               
                            ,tab_prn.tablename
                            ,tab_prn.modifdate
                            ,tab_prn.operation
                            ,tab_prn.authid
                            ,tab_prn.osuser
                            ,tab_prn.note 
                            ,tab_prn.tablern                     
                        from tab_prn
                       where tab_prn.prn = ndocument
                       
                       
                       )
        loop
        
          get_note(rec.rn, rec.tablename, snote);
        
          snote := trim(nvl(snote, rec.note));
          snote := nvl(snote, rec.tablern);
        
          insert into udo_t_updatelist_rep
            (dmodifdate
            ,soperation
            ,sauthid
            ,sosuser
            ,sspec_value
            ,sauthid_user)
          values
            (rec.modifdate
            ,rec.operation
            ,rec.authid
            ,rec.osuser
            ,snote
            ,utilizer);
        
        end loop;
      
      end if;
    
    else
    
      if nvdeist = 1
      then
      
        for rec in (select u.rn
                          ,u.tablename
                          ,u.reg_date
                          ,u.authid
                          ,u.osuser
                          ,u.action
                      from bphist u
                     where u.document = ndocument
                       and (sactcode is null or u.action = sactcode)
                    union all
                    select ua.rn
                          ,ua.tablename
                          ,ua.reg_date
                          ,ua.authid
                          ,ua.osuser
                          ,ua.action
                      from bphist_arc ua
                     where ua.document = ndocument
                       and (sactcode is null or ua.action = sactcode))
        loop
        
          udo_find_unitfunc_name_by_code(1, rec.action, snote);
        
          snote := nvl(snote, rec.action);
        
          if rec.action like '%INSERT%'
          then
            soperation := 'I';
          elsif rec.action like '%UPDATE%'
          then
            soperation := 'U';
          elsif rec.action like '%DELETE%'
          then
            soperation := 'D';
          else
            soperation := 'O';
          end if;
        
          insert into udo_t_updatelist_rep
            (dmodifdate
            ,soperation
            ,sauthid
            ,sosuser
            ,sspec_value
            ,sauthid_user)
          values
            (rec.reg_date
            ,soperation
            ,rec.authid
            ,rec.osuser
            ,snote
            ,utilizer);
        
        end loop;
      
      else
      
        for rec in (select u.rn
                          ,u.tablename
                          ,u.reg_date
                          ,u.authid
                          ,u.osuser
                          ,u.action
                      from bphist u
                     where u.document = ndocument
                       and (sactcode is null or u.action = sactcode)
                       and ((u.action like '%INSERT%' and nins = 1) or (u.action like '%UPDATE%' and nupd = 1) or
                           (u.action like '%DELETE%' and ndel = 1) or
                           (u.action not like '%INSERT%' and u.action not like '%UPDATE%' and u.action not like '%DELETE%' and noth = 1))
                    union all
                    select ua.rn
                          ,ua.tablename
                          ,ua.reg_date
                          ,ua.authid
                          ,ua.osuser
                          ,ua.action
                      from bphist_arc ua
                     where ua.document = ndocument
                       and (sactcode is null or ua.action = sactcode)
                       and ((ua.action like '%INSERT%' and nins = 1) or (ua.action like '%UPDATE%' and nupd = 1) or
                           (ua.action like '%DELETE%' and ndel = 1) or
                           (ua.action not like '%INSERT%' and ua.action not like '%UPDATE%' and ua.action not like '%DELETE%' and noth = 1)))
        loop
        
          udo_find_unitfunc_name_by_code(1, rec.action, snote);
        
          snote := nvl(snote, rec.action);
        
          if rec.action like '%INSERT%'
          then
            soperation := 'I';
          elsif rec.action like '%UPDATE%'
          then
            soperation := 'U';
          elsif rec.action like '%DELETE%'
          then
            soperation := 'D';
          else
            soperation := 'O';
          end if;
        
          insert into udo_t_updatelist_rep
            (dmodifdate
            ,soperation
            ,sauthid
            ,sosuser
            ,sspec_value
            ,sauthid_user)
          values
            (rec.reg_date
            ,soperation
            ,rec.authid
            ,rec.osuser
            ,snote
            ,utilizer);
        
        end loop;
      
      end if;
    
    end if;
  
  end;

begin

  if saction is not null
     and nbphist = 1
  then
    udo_find_unitfunc_code_by_name(0, sunitcode, saction, sactcode);
  end if;

  ddatebgn1 := nvl(ddatebgn, sysdate);
  ddateend1 := nvl(ddateend, sysdate);

  -- p_exception(0,NRN || ' - ' || sUNITCODE);
  delete from udo_t_updatelist_rep where sauthid_user = utilizer;

  if nvidel = 1
  then
    for cur in (select s.document
                  from selectlist s
                 where s.ident = nrn
                   and s.unitcode = sunitcode)
    loop
      ins(cur.document);
    end loop;
  elsif ntablern is not null
  then
    ins(ntablern);
  else
  
    begin
      select ul.table_name
        into stablename
        from unitlist ul
       where ul.unitcode = sunitcode
         and rownum = 1;
    exception
      when others then
        p_exception(0, 'Не удалось определить таблицу');
    end;
  
    if stablename = 'UDO_V_DEPARTMENT_SHEET'
    then
      stablename := 'UDO_DEPARTMENT_SHEET';
    end if;
  
    if nbphist = 0
    then
    
      for cur in (select distinct ttt.tablern
                    from (select u.tablern
                            from updatelist u
                           where u.tablename = stablename
                             and (sauthid is null or u.authid = sauthid)
                             and u.modifdate >= ddatebgn1
                             and u.modifdate <= ddateend1
                             and ((u.operation = 'I' and nins = 1) or (u.operation = 'U' and nupd = 1) or (u.operation = 'D' and ndel = 1))
                          union all
                          select ua.tablern
                            from updatelist_arc ua
                           where ua.tablename = stablename
                             and (sauthid is null or ua.authid = sauthid)
                             and ua.modifdate >= ddatebgn1
                             and ua.modifdate <= ddateend1
                             and ((ua.operation = 'I' and nins = 1) or (ua.operation = 'U' and nupd = 1) or (ua.operation = 'D' and ndel = 1))) ttt)
      loop
        ins(cur.tablern);
      end loop;
    
    else
      for cur in (select distinct ttt.tablern
                    from (select u.document as tablern
                            from bphist u
                           where u.tablename = stablename
                             and (sauthid is null or u.authid = sauthid)
                             and u.reg_date >= ddatebgn1
                             and u.reg_date <= ddateend1
                             and (sactcode is null or u.action = sactcode)
                             and ((u.action like '%INSERT%' and nins = 1) or (u.action like '%UPDATE%' and nupd = 1) or
                                 (u.action like '%DELETE%' and ndel = 1) or (u.action not like '%INSERT%' and u.action not like '%UPDATE%' and
                                 u.action not like '%DELETE%' and noth = 1))
                          union all
                          select ua.document as tablern
                            from bphist_arc ua
                           where ua.tablename = stablename
                             and (sauthid is null or ua.authid = sauthid)
                             and ua.reg_date >= ddatebgn1
                             and ua.reg_date <= ddateend1
                             and (sactcode is null or ua.action = sactcode)
                             and ((ua.action like '%INSERT%' and nins = 1) or (ua.action like '%UPDATE%' and nupd = 1) or
                                 (ua.action like '%DELETE%' and ndel = 1) or
                                 (ua.action not like '%INSERT%' and ua.action not like '%UPDATE%' and ua.action not like '%DELETE%' and
                                 noth = 1))) ttt)
      loop
        ins(cur.tablern);
      end loop;
    end if;
  end if;

end udo_p_updatelist_fill_table;
/
