create or replace procedure usr_p_fcroutlstsp_fin_upd
-- usr_p_fcroutlstsp_is_start
(
  pin_doc       in fcroutlstsp.rn%type
 ,pin_nexecutor in clnpspfm.rn%type
 ,nsnmb         in varchar2 -- Заводской номер для активации процедуры на форме 

 ,out_fm        out agnlist.agnfamilyname%type
 ,out_im        out agnlist.agnfirstname%type
 ,out_ot        out agnlist.agnlastname%type
 ,out_dl        out agnlist.emppost%type
 ,out_txt_res   out varchar2
 ,out_ok_enb    out number
) is
 v_pers_authid clnpersons.pers_authid%type; --- Сотрудник связан с пользователем Парус

begin

  out_ok_enb := 1;

  begin
  
    select null
      into out_txt_res
      from fcroutlstsp sp
     where sp.rn = pin_doc
       and sp.rlfact_date is not null;
  exception
    when no_data_found then
      out_ok_enb := 0;
     
      out_txt_res   := 'Перед выполнением данного действия необходимо задать Дату начала операции. Выполнить действие: "Начать работы"';
    
  end;

  if out_txt_res is null then
    --- Ранее ошибка не выявлена
  
    if pin_nexecutor is null then
    
      out_fm := null;
      out_im := null;
      out_ot := null;
      out_dl := null;
    
    else
    
      select ag.agnfamilyname
            ,ag.agnfirstname
            ,ag.agnlastname
            ,ag.emppost
            ,cp.pers_authid
        into out_fm
            ,out_im
            ,out_ot
            ,out_dl
            ,v_pers_authid
      
        from clnpspfm pm
        join clnpersons cp
          on cp.rn = pm.persrn
        join agnlist ag
          on ag.rn = cp.pers_agent
       where pm.rn = pin_nexecutor;
    
      if v_pers_authid is null then
        out_txt_res := 'Сотрудник не идентифицирован. Выполните на сотруднике действие "Идентификация". ' || cr ||
                       '(Словари --> Штатное распиание --> Сотрудники)';
        out_ok_enb  := 0;
      
      end if;
    
    end if;
  
  end if;
  
   if out_ok_enb = 1
     ---and user = 'GOR'
     and nsnmb is not null
  then
    out_txt_res := ' ';
  
    for cur in (with zn as
                   (select regexp_substr(nsnmb, '[^;]+', 1, level) as zn
                     from (select nsnmb from dual)
                   connect by regexp_substr(nsnmb, '[^;]+', 1, level) is not null)
                  
                  select zn.zn
                    from zn
                   where not exists (select 1
                            from fcroutlstsp str
                            join fcroutlstsernumb sn
                              on sn.prn = str.prn
                            join rlarticles ra
                              on ra.rn = sn.article
                           where str.rn = pin_doc
                             and ra.version = 92063
                             and ra.code = zn.zn))
    loop
    
      out_ok_enb  := 0;
      out_txt_res := out_txt_res || ' ' || cur.zn;
    
    end loop;
  
    if out_ok_enb = 0
    then
    
      out_txt_res := 'Выбраны заводские номера, отсутствующие в данном маршрутном листе. Выберите корректное значение через словарь.' || cr ||
                     'Некорректные номера: ' || out_txt_res;
    
    end if;
  
  end if;
  

end;
/
