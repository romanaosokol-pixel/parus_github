create or replace procedure udo_p_transinvdept_updcomments
/*
grant execute on udo_p_transinvdept_updcomments to public;
*/
(
 nIDENT   in number
,sSUBJECT in varchar
) 
is
  rV_Row    v_transinvdept%rowtype;
begin
  /* Проверка параметров */
  if sSUBJECT is null then
    p_exception(0, 'Не задан текст примечания.');  
  end if;

  /* По отмеченным документам */
  for с in ( select *
               from v_transinvdept t
              where t.nrn in ( select document from selectlist where ident = nIDENT ) )
  loop
    /* считывание текущего документа */
    rV_Row := с;
    /* добавление нового текста в конец примечания */
    rV_Row.scomments := strcombine( trim(sSUBJECT), rV_Row.scomments, cr );
    /* исправление документа */
    usr_pkg_transinvdept.transinvdept_update( rv_row => rV_Row );
  end loop;

end;
/
