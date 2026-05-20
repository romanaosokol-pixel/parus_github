create or replace procedure usr_p_fcroutlstsp_begin_ini
(
  pin_doc       in fcroutlstsp.rn%type
 ,pin_nexecutor in clnpspfm.rn%type
 ,out_fm        out agnlist.agnfamilyname%type
 ,out_im        out agnlist.agnfirstname%type
 ,out_ot        out agnlist.agnlastname%type
 ,out_dl        out agnlist.emppost%type
 ,out_txt_res   out varchar2
 ,out_DATE       out date
 ,OUT_OK_ENB    out number
) is

  v_pers_authid clnpersons.pers_authid%type; --- Сотрудник связан с пользователем Парус

begin

  out_txt_res := null;
  OUT_OK_ENB := 1;
  out_date :=sysdate;

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
  
/*    if v_pers_authid is null then
      out_txt_res := 'Сотрудник не идентифицирован. Выполните на сотруднике действие "Идентификация". ' || cr ||
                     '(Словари --> Штатное распиание --> Сотрудники)';
      OUT_OK_ENB :=0;               
    
    end if;*/
  
  end if;

end;
/
