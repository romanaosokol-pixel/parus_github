create or replace procedure usr_p_filelinks_update
/*
Присоединённые документы. Процедура "Исправить"
07/04/2026 Степанов М.
create public synonym usr_p_filelinks_update for usr_p_filelinks_update;
grant execute on usr_p_filelinks_update to public;

*/
(
 nIDENT           in number
,sFILE_PATH       in varchar2   /* Имя файла */
,nSAVE_EXTENSION  in number     /* Исправлять только имя файла, расширение оставить прежним */
,s7356488         in varchar2   /* Свойство РазделСистемы */
,s183211398       in varchar2   /* Свойство Удалить */
)
is
  rV_Row    v_filelinks%rowtype;
  
  nNumber   pkg_std.tnumber; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_FILELINKS_UPDATE');
  
  /* Считывание */
  begin
    select t.* 
      into rV_Row 
      from selectlist   sl
      join v_filelinks  t  on t.nrn = sl.document
     where sl.ident = nIDENT;
  exception
    when no_data_found then
      p_exception(0, 'Не найден документ в разделе <%s>.'
                 ,f_unitlist_getname( sunitcode => get_unitlist_code_table( nflag_smart => 1, stable_name => 'FILELINKS' ) ) );
    when too_many_rows then
      p_exception(0, 'Отмечено больше одного документа в разделе <%s>.'
                 ,f_unitlist_getname( sunitcode => get_unitlist_code_table( nflag_smart => 1, stable_name => 'FILELINKS' ) ) );
    when others then
      p_exception(0, 'Неопределённая ситуация при считывании документа в разделе <%s>.'
                 ,f_unitlist_getname( sunitcode => get_unitlist_code_table( nflag_smart => 1, stable_name => 'FILELINKS' ) ) );
  end;
  
  /* Если задано имя файла и признак сохранять расширение */
  if  sFILE_PATH is not null 
  and cmp_num( nSAVE_EXTENSION, 1 ) = 1 then
    rV_Row.sfile_path := sFILE_PATH ||substr ( rV_Row.sfile_path, instr( rV_Row.sfile_path, '.', -1) );
  /* Иначе */
  else
    rV_Row.sfile_path := nvl( sFILE_PATH, rV_Row.sfile_path );
  end if;

  /* Исправление присоединённого документа */
  usr_pkg_filelinks.filelinks_update( rv_row => rv_row, nmode => 1 );

  /* Исправление свойств */
  if s7356488 is not null then
    pkg_docs_props_vals.modify( nproperty   => 7356488
                               ,sunitcode   => 'FileLinks'
                               ,ndocument   => rV_Row.nrn
                               ,sstr_value  => s7356488
                               ,nnum_value  => null
                               ,ddate_value => null
                               ,nrn         => nNumber );
  end if;                             
  if s183211398 is not null then
    pkg_docs_props_vals.modify( nproperty   => 183211398
                               ,sunitcode   => 'FileLinks'
                               ,ndocument   => rV_Row.nrn
                               ,sstr_value  => s183211398
                               ,nnum_value  => null
                               ,ddate_value => null
                               ,nrn         => nNumber );
  end if;                             

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
    usr_pkg_process.process_close;
    raise;
end;
/
