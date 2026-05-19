create or replace function usr_f_norm
/*
Функция нормализации строки. Выполняет действия со строкой, указанные в параметрах
31/01/2024 Степанов М.
grant execute on USR_F_TRIM to public;
*/
(
 sVAL             in varchar2
,nSB_TRIM         in number default 1 /* удаление/замена пробелов и переносов */
,nSB_TRIM_NUM     in number default 0 /* для параметра nSB_TRIM - удаление/замена пробелов и переносов: количество пробелов, которыми заменить множественные пробелы и переносы */
,nRMV_DOT_LAST    in number default 1 /* удалить последний символ, если это точка */
,nRMV_COMMA_TWS   in number default 1 /* удалить сдвоенную запятую */
,nTRNSL_LW        in number default 1 /* translate */
,nTRNSL_UP        in number default 1 /* TRANSLATE */
,nLOWER           in number default 1 /* UPPER */
,nUPPER           in number default 0 /* lower */
)
return varchar2
as
  s   pkg_std.tstring := trim( sVAL );
begin
  if nvl(nSB_TRIM, 0) = 1 then
    s := regexp_replace( s, '[[:space:]]+', rpad(' ', nSB_TRIM_NUM) );
  end if;
  if nvl(nRMV_DOT_LAST, 0) = 1 then
    s := case 
           when substr( s, -1, 1 ) = '.' 
           then substr( s, 0, length( s ) -1 ) 
           else s 
         end;
  end if;
  if nvl(nRMV_COMMA_TWS, 0) = 1 then
    s := replace( s, ',,', ',' );
    s := replace( s, ',,', ',' );
    s := replace( s, ',,', ',' );
  end if;
  if nvl(nTRNSL_LW, 0) = 1 then
    s := translate( s, 'etyopahkxcbm', 'етуоранкхсвм' );
  end if;
  if nvl(nTRNSL_UP, 0) = 1 then
    s := translate( s, 'ETYOPAHKXCBM', 'ЕТУОРАНКХСВМ' );
  end if;
  if nvl(nLOWER, 0) = 1 then
    s := upper( s );
  end if;
  if nvl(nUPPER, 0) = 1 then
    s := lower( s );
  end if;

  return s ;
end;
/
