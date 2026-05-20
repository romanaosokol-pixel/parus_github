create or replace procedure usr_p_fcusage_view_ini
(
  nmatres  in fcmatresource.rn%type default null
 ,nmodifrn in nommodif.rn%type
 ,ncompany in fcmatresource.company%type

 /*,nfcusage out fcusage.rn%type*/
) is

  --  nmatres  fcmatresource.rn%type := 9392811;
  ---  ncompany fcmatresource.company%type := 90521;

  ncrn      fcusagesp.crn%type;
  v_nmatres fcmatresource.rn%type;

  nfl   integer := 0;
  nfcusage fcusage.rn%type;
  ddate fcusage.form_date%type;

  v_nrn number(17);
  v_idn number(17);

  sCONTAINER constant PKG_STD.tSTRING := 'FCUSAGE_VIEW_INI'; -- Имя контейнера


begin

  /* Очистка контейнера*/
  PKG_CONTCACHE.PURGE(sCONTAINER);
  
  ----P_exception(0, ncompany||' '|| nmodifrn);
  -- Находим корневой каталог Применяемости

  select ac.rn
    into ncrn
    from acatalog ac
   where ac.docname = 'CostUsage'
     and ac.is_root = 1
     and ac.company = ncompany;

  if nmatres is null then

    begin
      select mr.rn
        into v_nmatres
        from fcmatresource mr
       where mr.nomen_modif = nmodifrn
         and mr.company = ncompany;
    exception
      when no_data_found then
       
        -- Если нет мат ресурса, то и применимости не будет
        return;
    end;
  else
    v_nmatres := nmatres;

  end if;

  ---Находим последний состав применяемости
  begin
    select t.rn
          ,t.form_date
      into nfcusage
          ,ddate
      from fcusage t
     where t.matres = v_nmatres
       and t.form_date = (select max(tt.form_date) from fcusage tt where tt.matres = v_nmatres);

  exception
    when no_data_found then
      p_fcusage_make(ncompany   => ncompany
                    ,ncrn       => ncrn
                    ,scatalog   => null
                    ,nmatres    => v_nmatres
                    ,snomen     => null
                    ,smodif     => null
                    ,dform_date => trunc(sysdate)
                    ,npr_cond   => null
                    ,spr_cond   => null
                    ,nrn        => nfcusage);
      nfl := 1; -- Сформировали новую применяемость
    ---

  end;

  if nfl = 0 then
    --- Переформировываем Применяемость
    v_idn := gen_ident;

    p_selectlist_base_insert(nident       => v_idn
                            ,ncompany     => null
                            ,ndocument    => nfcusage
                            ,sunitcode    => 'CostUsage'
                            ,sactioncode  => null
                            ,ncrn         => null
                            ,ndocument1   => null
                            ,sunitcode1   => null
                            ,sactioncode1 => null
                            ,nrn          => v_nrn);

    p_fcusage_remake(ncompany   => ncompany
                    ,nident     => v_idn
                    ,snomen     => null
                    ,smodif     => null
                    ,dform_date => trunc(sysdate)
                    ,spr_cond   => null);

  end if;

  PKG_CONTCACHE.PUTN(sCONTAINER, 'FCUSAGE_RN', nfcusage, false);

end;
/
