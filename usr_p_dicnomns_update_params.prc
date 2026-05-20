create or replace procedure usr_p_dicnomns_update_params
/*
Номенклатор. Исправление параметров
Заменяет значения на зананные в параметрах, если в параметре задано пустое значение, то обнуляет его в таблице
Для исправления используется базовая процедура, которая обходит проверки неименованных блоков
26/09/2025 Степанов М.
create public synonym usr_p_dicnomns_update_params for usr_p_dicnomns_update_params;
grant execute on usr_p_dicnomns_update_params to public;
*/
(
 nIDENT           in number
,nCOMPANY         in number
,nSTORAGE_TIME    in number   /* Срок хранения */
,sUMEAS_STORAGE   in varchar2 /* Единица измерения срока хранения */
)
is
  rRow            dicnomns%rowtype;
  nUmeas_Storage  pkg_std.tref; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open( sname => 'USR_P_DICNOMNS_UPDATE_PARAMS' );

  /* RN единицы измерения */
  if sUMEAS_STORAGE is not null then
    find_dicmunts_code(nflag_smart  => 0
                      ,nflag_option => 0
                      ,ncompany     => nCOMPANY
                      ,smeas_mnemo  => sUMEAS_STORAGE
                      ,nrn          => nUmeas_Storage);
  end if;                    

  /* По отмеченным записям */
  for c in ( select dnm.*
               from selectlist    sl
               left join dicnomns dnm 
                 on dnm.rn   = sl.document
              where sl.ident = nIDENT )
  loop           
    /* Считывание в переменную */
    rRow := c;
    /* Подстановка значений */
    rRow.storage_time  := nSTORAGE_TIME;
    rRow.umeas_storage := nUmeas_Storage;
    /* Исправление  */
    usr_pkg_dicnomns.dicnomns_base_update( rRow => rRow, ncompany => nCOMPANY );
  end loop;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end usr_p_dicnomns_update_params;
/
