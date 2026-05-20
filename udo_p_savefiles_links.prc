create or replace procedure UDO_P_SAVEFILES_LINKS
(
  nCOMPANY in number,
  sUNIT    in varchar2,
  nPROCESS in number
) as
  /*
    Марков МВ.
    Тестовый пример процедуры сохранения присоединенных документов в каталог по отмеченным записям
  */
begin
  if rtrim(sUNIT) is null or
     nPROCESS is null then
    p_exception(0,
                'Не указан раздел системы выгрузки или не отмечены записи для выгрузки.');
  end if;
  --
  for rec in (select DOCUMENT from SELECTLIST where IDENT = nPROCESS) loop
    -- соберем файлы в буфер
    UDO_P_FILEBUFFER_GET_FLLINKS(sUNIT => sUNIT, nDOCUMENT => rec.document, nIDENT => nPROCESS);
  end loop;
end;
/

