create or replace procedure UDO_P_UPLOAD_PAYNOTE_1C_UREP
(
  NCOMPANY         in number,         -- Организация
--  nIDENT           in number,         -- ID помеченных записей
  NPROCESS         in number,         -- ID Процесса
  DBEG             in date default sysdate - 7,           -- начало периода
  DEND             in date default sysdate                -- конец периода

)
is
begin
  /* Точка старта выгрузки отчетов */
  UDO_PKG_UPLOAD_PAYNOTE_1C.START_OUT_MAKE
  (
    NCOMPANY         => NCOMPANY,
 --   nIDENT           => nIDENT,
    NPROCESS         => NPROCESS,
    DBEG             => DBEG,
    DEND             => DEND
  );

end UDO_P_UPLOAD_PAYNOTE_1C_UREP;
-- grant execute on UDO_P_UPLOAD_PAYNOTE_1C_UREP to public;
/

