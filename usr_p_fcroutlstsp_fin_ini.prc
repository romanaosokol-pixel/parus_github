create or replace procedure usr_p_fcroutlstsp_fin_ini
-- usr_p_fcroutlstsp_is_start
(
  pin_doc       in fcroutlstsp.rn%type
 ,out_nexecutor out clnpspfm.rn%type
 ,out_date      out date
 ,out_fm        out agnlist.agnfamilyname%type
 ,out_im        out agnlist.agnfirstname%type
 ,out_ot        out agnlist.agnlastname%type
 ,out_dl        out agnlist.emppost%type
 ,out_txt_res   out varchar2
 ,out_ok_enb    out number
) is

begin

  out_ok_enb := 1;
  out_date   := sysdate;

/* Найдем кто начал работу, предполагаем, что он и закончит ее */

  begin
  
    with pers as
     (select h.clnperson rn
        from udo_fcroutlst_hist h
       where h.spec = pin_doc
         and h.begdate = (select max(hh.begdate) from udo_fcroutlst_hist hh where hh.spec = h.spec)
         and rownum = 1 --- Без учета заводских номров 
      )
    
    select (select pm.rn
              from clnpspfm pm
             where pm.persrn = cp.rn
               and pm.begeng = (select max(ppm.begeng) from clnpspfm ppm where ppm.persrn = cp.rn))
          ,ag.agnfamilyname
          ,ag.agnfirstname
          ,ag.agnlastname
          ,ag.emppost
      into out_nexecutor
          ,out_fm
          ,out_im
          ,out_ot
          ,out_dl
      from pers
      join clnpersons cp
        on cp.rn = pers.rn
      join agnlist ag
        on ag.rn = cp.pers_agent;
  exception
    when no_data_found then
      out_ok_enb := 0;
    
      out_txt_res := 'Перед выполнением данного действия необходимо задать Дату начала операции. Выполнить действие: "Начать работы"';
    
  end;

end;
/
