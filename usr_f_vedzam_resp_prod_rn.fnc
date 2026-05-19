create or replace function usr_f_vedzam_resp_prod_rn(nrn udo_deporddir.rn%type)
  return udo_tp_numtable
  pipelined is

begin

  /*
  ‘ункци€ вернЄт набор Rn строк записей таблицы "ќтветственные по проекту", дл€ которого создана данна€ ведомость замен  
  дл€ последующего отбора по нужным критери€м  
  */

  for rec in (with vz as
                 (select t.rn
                       ,t.depord --- «аказ подразделени€ непосредственно из ведомости замен       
                   from udo_deporddir t
                  where t.rn = nrn),
                zp as
                 (select distinct nvl(vzp.depord, vz.depord) depord --- «аказ подразделени€ из спецификации "заказы подразделени€" ведомости замен
                   from vz
                   left join udo_deporddir_depord vzp
                     on vzp.prn = vz.rn),
                pf as
                 (select distinct dp.faceacc --- Ћицевой счет заказов подразделени€        
                   from zp
                   join departmentord dp
                     on dp.rn = zp.depord)
                
                select pL.rn --RN проект
                  from pf
                  join projectstage ps
                    on ps.faceacc = pf.faceacc
                  join UDO_PRJEXEC_LIST  PL on PL.prn = ps.prn  
                    )
  
  loop
    pipe row(rec.rn);
  end loop;

  return;
end;
/
