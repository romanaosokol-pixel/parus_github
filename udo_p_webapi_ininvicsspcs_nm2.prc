create or replace procedure UDO_P_WEBAPI_ININVICSSPCS_NM2
(
    NCOMPANY         in number,                             -- Организация
    SPATTERN_DIR     in varchar2                            -- Каталог размещения файлов для выгрузки
)
is
begin
  /* Точка старта выгрузки отчетов */
  UDO_PKG_UPLD_ININVICSSPCS_NM2.START_WEBAPI_OUT_MAKE
  (
    NCOMPANY         => NCOMPANY,
    SPATTERN_DIR     => SPATTERN_DIR
  );

end UDO_P_WEBAPI_ININVICSSPCS_NM2;
-- grant execute on UDO_P_WEBAPI_ININVICSSPCS_NM2 to public;
/

