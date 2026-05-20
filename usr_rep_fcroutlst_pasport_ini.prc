create or replace procedure usr_rep_fcroutlst_pasport_ini
/*
Процедура инициализации входных значений параметров для отчёта "Маршрутный лист (Технологический паспорт)" на процедуре UDO_REP_FCROUTLST_PASPORT
create public synonym usr_rep_fcroutlst_pasport_ini for usr_rep_fcroutlst_pasport_ini;
*/
(
 nRN           in number
,nPIN_VIS_11SH out number /* Печать ФВД */
) 
is
begin
  for c in (
            select 1 as nres
              from fcroutlstsernumb t
              join fcroutlstsp      s  on s.prn = t.prn
                                      and usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 160686482 /* ФВД */, ndocument => s.rn ) = 'Да' 
             where t.rn = nRN
           )
  loop
    nPIN_VIS_11SH := c.nres;
    exit;
  end loop;

end;
/
