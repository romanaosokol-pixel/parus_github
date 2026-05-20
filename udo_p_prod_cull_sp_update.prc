create or replace procedure UDO_P_PROD_CULL_SP_UPDATE
(
  nPRN                      in number,  -- Рег. номер родителя  
  nQUANT                    in number,  -- Кол-во переданное на сертификацию
  nSIGN_SERT                in number,  -- Признак сертификации (0-выборочная, 1-полная) 
  sNOTE                     in varchar2,-- Примечание
  nRN                       in number   -- Рег. номер записи
) is
  /*
  Клиентская процедура исправления записи.
  Раздел "Сертификация ТМЦ (Спецификация)"
  grant execute on UDO_P_PROD_CULL_SP_UPDATE to public;
  */
  rCULL         udo_prod_cull%rowtype; -- запись заголовка 
begin
  -- заголовок 
  UDO_PKG_PROD_CULL.CULL_FIND(nPRN,
                              rCULL);
  
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(rCULL.COMPANY,
                   null,
                   rCULL.CRN,
                   rCULL.Jurpers,
                   'UdoProdCullSp',
                   'UDO_PROD_CULL_SP_UPDATE',
                   'UDO_PROD_CULL_SP',
                   nRN);
  -- базовое добавление 
  UDO_PKG_PROD_CULL.CULL_SP_UPDATE(nQUANT     => nQUANT,
                                   nSIGN_SERT => nSIGN_SERT,
                                   sNOTE      => sNOTE,
                                   nRN        => nRN);
                                   
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(rCULL.COMPANY,
                   null,
                   rCULL.CRN,
                   rCULL.Jurpers,
                   'UdoProdCullSp',
                   'UDO_PROD_CULL_SP_UPDATE',
                   'UDO_PROD_CULL_SP',
                   nRN);
end UDO_P_PROD_CULL_SP_UPDATE;
/

