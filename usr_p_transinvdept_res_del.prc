create or replace procedure usr_p_transinvdept_res_del
(
  nrn       in transinvdept.rn%type
 ,nskl_type in stkind.rn%type default null
) is

  /* Процедура удаляет резерв с отработанной как факт накладной в подразделения с RN = nrn, если склад назначения имеет вид c rn = nskl_type (или без ограничения, если тип не задан)*/
begin
  for cur in (with skl as
                 (select skl.rn
                       ,skl.azs_number
                   from azsazslistmt skl
                 
                  where (skl.stkind = nskl_type or nskl_type is null))
                
                select t.company
                      ,jrm.rn jrm_rn
                  from transinvdept t
                  join doclinks dl
                    on dl.in_document = t.rn
                   and dl.out_unitcode = 'StoragePlacesResJournal'
                  join strplresjrnl jrm
                    on jrm.rn = dl.out_document
                  join skl
                    on skl.rn = t.in_store
                
                 where t.rn = nrn
                   and t.status = 1
                   and t.in_status = 1
                   and jrm.free_date is null)
  
  loop
    p_strplresjrnl_delete(ncompany => cur.company, nrn => cur.jrm_rn);
  end loop;

end;

  ---
/
