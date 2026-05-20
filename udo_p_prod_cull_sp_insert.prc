create or replace procedure UDO_P_PROD_CULL_SP_INSERT
(
  nPRN                      in number,   -- Рег. номер заголовка раздела
  nGOODSPARTY               in number,   -- Рег. номер партии товара
  sNOMEN                    in varchar2, -- номенклатура
  sMODIF                    in varchar2, -- модификация 
  sPACK                     in varchar2, -- упаковка
  sARTICLE                  in varchar2, -- изделие
  nQUANT                    in number,   -- Кол-во переданное на сертификацию
  nSIGN_SERT                in number,   -- Признак сертификации (0-выборочная, 1-полная) 
  sNOTE                     in varchar2, -- Примечание
  nRN                       out number   -- Рег. номер записи  
) is
  /*
  Клиентская процедура добавления записи.
  Раздел "Сертификация ТМЦ (Спецификация)"
  
  grant execute on UDO_P_PROD_CULL_SP_INSERT to public;
  */
  rPROD_CULL_SP udo_prod_cull_sp%rowtype; -- запись раздела
  rCULL         udo_prod_cull%rowtype; -- запись заголовка 
begin

  -- заголовок 
  UDO_PKG_PROD_CULL.CULL_FIND(nPRN,
                              rCULL);
  -- разрешение ссылок
  UDO_PKG_PROD_CULL.CULL_SP_JOIN(nCOMPANY  => rCULL.COMPANY,
                                 sNOMEN    => sNOMEN, -- номенклатура
                                 sMODIF    => sMODIF, -- модификация 
                                 sPACK     => sPACK, -- упаковка
                                 sARTICLE  => sARTICLE, -- изделие
                                 nNOMEN    => rPROD_CULL_SP.Nomen, -- Рег. номер номенклатуры  
                                 nMODIF    => rPROD_CULL_SP.Modif, -- Рег. номер  модификации
                                 nPACK     => rPROD_CULL_SP.Pack, -- Рег. номер упаковки
                                 nARTICLE  => rPROD_CULL_SP.Article -- Рег. номер изделия
                                 );
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(rCULL.COMPANY,
                   null,
                   rCULL.CRN,
                   rCULL.Jurpers,
                   'UdoProdCullSp',
                   'UDO_PROD_CULL_SP_INSERT',
                   'UDO_PROD_CULL_SP');
  -- базовое добавление 
  UDO_PKG_PROD_CULL.CULL_SP_INSERT(nPRN          => nPRN, 
                                   nNOMEN        => rPROD_CULL_SP.Nomen,   
                                   nMODIF        => rPROD_CULL_SP.Modif, 
                                   nPACK         => rPROD_CULL_SP.Pack,
                                   nARTICLE      => rPROD_CULL_SP.Article,
                                   nGOODSPARTY   => nGOODSPARTY,
                                   nQUANT        => nQUANT,
                                   nSIGN_SERT    => nSIGN_SERT,
                                   sNOTE         => sNOTE, 
                                   nRN           => nRN 
                                   );
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(rCULL.COMPANY,
                   null,
                   rCULL.CRN,
                   rCULL.Jurpers,
                   'UdoProdCullSp',
                   'UDO_PROD_CULL_SP_INSERT',
                   'UDO_PROD_CULL_SP',
                   nRN);
end UDO_P_PROD_CULL_SP_INSERT;
/

