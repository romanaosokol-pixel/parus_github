create or replace procedure UDO_P_START_WEBAPI_OUT_MAKE
(
    NCOMPANY         in number,                             -- Организация
    DBEG             in date default sysdate - 7,           -- начало периода
    DEND             in date default sysdate,               -- конец периода
    SPATTERN_DIR     in varchar2                            -- Каталог размещения файлов для выгрузки
)
is
begin
  /* Точка старта выгрузки отчетов */
  UDO_PKG_UPLOAD_PAYNOTE_1C.START_WEBAPI_OUT_MAKE
  (
    NCOMPANY         => NCOMPANY,
    DBEG             => DBEG,
    DEND             => DEND,
    SPATTERN_DIR     => SPATTERN_DIR
  );

end UDO_P_START_WEBAPI_OUT_MAKE;
-- grant execute on UDO_P_START_WEBAPI_OUT_MAKE to public;
/

