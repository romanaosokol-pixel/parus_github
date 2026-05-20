create or replace procedure UDO_P_PROD_CULL_SP_SET_CERTIF
(
  nRN                       in number,  -- Рег. номер записи
  nPROCESS                  in number,  -- Идентификатор загрузки 
  sCERT_NUMB                in varchar2,-- Номер сертификата 
  dCERT_FROM                in date,    -- Дата с сертификата   
  dCERT_TO                  in date     -- Дата по сертификата                                                  
) is
  /*
  Клиентская процедура загрузки сертификата.
  Спецификация "Передано на сертификацию/ВК" раздела "Сертификация /входной контроль"
    
  grant execute on UDO_P_PROD_CULL_SP_SET_CERTIF to public;
  */ 
  rec                       udo_prod_cull_sp%rowtype;
begin
  /* запись раздела */
  udo_pkg_prod_cull.CULL_SP_FIND(nRN,rec);
  
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(rec.COMPANY,
                   null,
                   rec.CRN,
                   rec.JURPERS,
                   'UdoProdCullSp',
                   'UDO_PROD_CULL_SP_SET_CERTIF',
                   'UDO_PROD_CULL_SP',
                   nRN);
                   
  /* указать сертификат */
  udo_pkg_prod_cull.CULL_SP_SET_CERTIF(nRN        => nRN,       
                                       nPROCESS   => nPROCESS,  
                                       sCERT_NUMB => sCERT_NUMB,
                                       dCERT_FROM => dCERT_FROM,
                                       dCERT_TO   => dCERT_TO); 
  
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(rec.COMPANY,
                   null,
                   rec.CRN,
                   rec.JURPERS,
                   'UdoProdCullSp',
                   'UDO_PROD_CULL_SP_SET_CERTIF',
                   'UDO_PROD_CULL_SP',
                   nRN);
end ;
/

