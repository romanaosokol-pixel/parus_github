create or replace procedure usr_p_dicnomns_update_params2
/*
Номенклатор. Исправление параметров 2
27/04/2026 Степанов М.
create public synonym usr_p_dicnomns_update_params2 for usr_p_dicnomns_update_params2;
grant execute on usr_p_dicnomns_update_params2 to public;
*/
(
 nRN                in number
,nCOMPANY           in number
,sGROUP             in varchar2 /* Группа */
,nGROUP_CLEAR       in number   /* Очистить ( Группа номенклатуры ) */
,sPURCH_RESP        in varchar2 /* Ответственный за закупку */
,nPURCH_RESP_CLEAR  in number   /* Очистить (Ответственный за закупку) */
)
is
  nNumber             pkg_std.tnumber;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open( sname => 'USR_P_DICNOMNS_UPDATE_PARAMS2' );

  /* Проверка до исправления */
  usr_pkg_dicnomns.dicnomns_bupdate( nrn => nRN, ncompany => nCOMPANY );

  /* Исправление */
  /* 'УМТС_ГруппаНомен' */
  pkg_docs_props_vals.modify( nproperty   => 19579777
                             ,sunitcode   => 'Nomenclator'
                             ,ndocument   => nRN
                             ,sstr_value  => case when nGROUP_CLEAR = 1 then
                                               null
                                             else
                                               nvl( sGROUP, usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 19579777, ndocument => nRN ) )
                                             end
                             ,nnum_value  => null
                             ,ddate_value => null
                             ,nrn         => nNumber );
  /* УМТС_Ответственный */
  pkg_docs_props_vals.modify( nproperty   => 180597323
                             ,sunitcode   => 'Nomenclator'
                             ,ndocument   => nRN
                             ,sstr_value  => case when nPURCH_RESP_CLEAR = 1 then
                                               null
                                             else
                                               nvl( sPURCH_RESP, usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 180597323, ndocument => nRN ) )
                                             end
                             ,nnum_value  => null
                             ,ddate_value => null
                             ,nrn         => nNumber );

  /* Проверка после исправления */
  usr_pkg_dicnomns.dicnomns_aupdate( nrn => nRN, ncompany => nCOMPANY );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end usr_p_dicnomns_update_params2;
/
