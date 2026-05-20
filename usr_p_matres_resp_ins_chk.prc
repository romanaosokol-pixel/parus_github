create or replace procedure usr_p_matres_resp_ins_chk(nrn             in number default null
                                                     ,ncompany        in number
                                                     ,smodif_code     in nommodif.modif_code%type /* Код модификации */
                                                     ,sresponsib_type in extra_dicts_values.str_value%type /*Код Типа ответсвенного */
                                                     ,ddate_beg       in date
                                                     ,ddate_end       in date
                                                     ,err_txt         out varchar2) is
begin

  for cur in (with ty as
                 (select dv.rn
                   from extra_dicts ed
                   join compverlist v
                     on v.version = ed.version
                    and v.company = ncompany
                    and v.unitcode = 'ExtraDictionaries'
                   join extra_dicts_values dv
                     on dv.prn = ed.rn
                    and dv.version = ed.version
                  where ed.code = 'RESPONSIBLE_TYPE'
                    and dv.str_value = sresponsib_type)
                select otv.response_agn
                      ,otv.date_beg
                      ,otv.date_end
                  from nommodif nm
                  join fcmatresource fc
                    on fc.nomen_modif = nm.rn
                   and fc.company = ncompany
                   and fc.nomenclature = nm.prn
                  join usr_tab_matres_response otv
                    on otv.prn = fc.rn
                  join ty
                    on ty.rn = otv.response_type
                 where nm.modif_code = smodif_code
                 and otv.rn != nrn /*Саму с собой не сравниваем */
                 )
  
  loop
  
    ---p_exception(0, ddate_beg||' > '||nvl(cur.date_end, sysdate)||chr(10)||nvl(ddate_end, sysdate)||' < '||cur.date_beg);
  
    if not (ddate_beg > nvl(cur.date_end, sysdate) or nvl(ddate_end, sysdate) < cur.date_beg)
    then
    
      err_txt := 'По типу ' || sresponsib_type || ', на периоде c ' || to_char(ddate_beg, 'DD.MM.YYYY') || ' по ' ||
                 to_char(nvl(ddate_end, sysdate), 'DD.MM.YYYY') || ' уже есть запись' || chr(10) || '(период c ' ||
                 to_char(cur.date_beg, 'DD.MM.YYYY') || ' по ' || to_char(nvl(cur.date_end, sysdate), 'DD.MM.YYYY') || ')';
    
    end if;
  
  end loop;

end;
/
