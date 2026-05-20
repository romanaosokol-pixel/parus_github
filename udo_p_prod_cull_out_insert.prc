create or replace procedure udo_p_prod_cull_out_insert
(
  nPRN                      in number,  -- Рег. номер заголовка раздела
  nSIGN_OUT                 in number,  -- Признак записи (0-количество сертифицированных ТМЦ, 1-количество разрушенных/негодных ТМЦ, 2-количество ТМЦ на которых распространяется сертификация)
  nSUPPLY                   in number,  -- Рег. номер товарного запаса
  sSERNUMB_NEW              in varchar2,-- Серия (новая)
  sCERT_NUMB                in varchar2,-- Номер сертификата
  dCERT_FROM                in date,    -- Дата с сертификата
  dCERT_TO                  in date,    -- Дата по сертификата
  nQUANT                    in number,  -- Кол-во
  nPRICE                    in number,  -- Цена
  nSUMM                     in number,  -- Сумма
  sCURRENCY                 in varchar2,-- валюта
  sNOTE                     in varchar2,-- Примечание
  pin_PROD_DATE_D           in date,     /* Дата производства дата */
  pin_PROD_DATE_S           in varchar2, /* Дата производства текстом */
  PIN_SUPPLIER_PARTY        in varchar2, /* Партия поставщика */
  PIN_sACCEPT               in varchar2, /* Приемки */
  PIN_RECHECK_DATE          IN varchar2  /* Дата перепроверки */
 ,sCHECK_TYPES              in varchar2  /* Виды испытаний */
 ,sCHECK_DEFECTIVE          in varchar2  /* Испытания, при которых выявлен брак */
 ,sMEAS_PARAMS              in varchar2  /* Измеренные параметры */
 ,nRN                       out number   /* Рег. номер записи */
) is
  /*
  Клиентская процедура добавления записи.
  Раздел "Сертификация ТМЦ (Результаты сертификации)"

  grant execute on UDO_P_PROD_CULL_OUT_INSERT to public;
  */
  rCULL_SP                  udo_prod_cull_sp%rowtype; -- запись заголовка
  nCURRENCY                 number; --  рег. номер валюты
  nAccept extra_dicts_values.rn%type; -- RN вида приемки
begin
  -- заголовок
  UDO_PKG_PROD_CULL.CULL_SP_FIND(nPRN,
                                 rCULL_SP);

  -- разрешение ссылок
  UDO_PKG_PROD_CULL .CULL_OUT_JOIN(nCOMPANY  => rCULL_SP.COMPANY,sCURRENCY => sCURRENCY, sACCEPT => PIN_sACCEPT, nCURRENCY => nCURRENCY, nACCEPT => nACCEPT);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(rCULL_SP.COMPANY,
                   null,
                   rCULL_SP.CRN,
                   rCULL_SP.Jurpers,
                   'UdoProdCullSpOut',
                   'UDO_PROD_CULL_OUT_INSERT',
                   'UDO_PROD_CULL_OUT');

  -- базовое добавление
  UDO_PKG_PROD_CULL.CULL_OUT_INSERT(nPRN         => nPRN,
                                    nSIGN_OUT    => nSIGN_OUT,
                                    nSUPPLY      => nSUPPLY,
                                    sSERNUMB_NEW => sSERNUMB_NEW,
                                    sCERT_NUMB   => sCERT_NUMB,
                                    dCERT_FROM   => dCERT_FROM,
                                    dCERT_TO     => dCERT_TO,
                                    nQUANT       => nQUANT,
                                    nPRICE       => nPRICE,
                                    nSUMM        => nSUMM,
                                    nCURRENCY    => nCURRENCY,
                                    sNOTE        => sNOTE,
                                    dPROD_DATE_D  => pin_PROD_DATE_D,
                                    sPROD_DATE_S  => pin_PROD_DATE_S,
                                    sSUPPLIER_PARTY => PIN_SUPPLIER_PARTY,
                                    nACCEPT => nAccept,
                                    sRECHECK_DATE => PIN_RECHECK_DATE
                                   ,sCHECK_TYPES      => sCHECK_TYPES    
                                   ,sCHECK_DEFECTIVE  => sCHECK_DEFECTIVE
                                   ,sMEAS_PARAMS      => sMEAS_PARAMS    
                                   ,nRN               => nRN);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(rCULL_SP.COMPANY,
                   null,
                   rCULL_SP.CRN,
                   rCULL_SP.Jurpers,
                   'UdoProdCullSpOut',
                   'UDO_PROD_CULL_OUT_INSERT',
                   'UDO_PROD_CULL_OUT',
                   nRN);
end UDO_P_PROD_CULL_OUT_INSERT;
/
