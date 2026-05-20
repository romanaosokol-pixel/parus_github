create or replace procedure udo_p_prod_cull_out_update
(
  nSIGN_OUT                 in number,  -- Признак записи (0-количество сертифицированных ТМЦ, 1-количество разрушенных/негодных ТМЦ, 2-количество ТМЦ на которых распространяется сертификация)
  sSERNUMB_NEW              in varchar2,-- Серия (новая)
  sCERT_NUMB                in varchar2,-- Номер сертификата
  dCERT_FROM                in date,    -- Дата с сертификата
  dCERT_TO                  in date,    -- Дата по сертификата
  nQUANT                    in number,  -- Кол-во
  nPRICE                    in number,  -- Цена
  nSUMM                     in number,  -- Сумма
  sCURRENCY                 in varchar2,-- валюта
  sNOTE                     in varchar2,-- Примечание
  pin_PROD_DATE_D           in date,  --- Дата изготовления в формате Дата
  pin_PROD_DATE_S           in varchar2, --- Дата изготовления в формате "как на этикете"
  PIN_SUPPLIER_PARTY        in varchar2, --- Партия поставщика
  PIN_sACCEPT               in varchar2, -- Вид приемки (код)
  PIN_RECHECK_DATE          IN varchar2  /* Дата перепроверки */
 ,sCHECK_TYPES              in varchar2  /* Виды испытаний */
 ,sCHECK_DEFECTIVE          in varchar2  /* Испытания, при которых выявлен брак */
 ,sMEAS_PARAMS              in varchar2  /* Измеренные параметры */
 ,nRN                       in number  -- Рег. номер записи
) is
  /*
  Клиентская процедура исправления записи.
  Раздел "Сертификация ТМЦ (Результаты сертификации)"

  grant execute on UDO_P_PROD_CULL_OUT_UPDATE to public;
  */
  rCULL_OUT                 udo_prod_cull_out%rowtype; -- запись заголовка
  nCURRENCY                 number; --  рег. номер валюты
  nAccept extra_dicts_values.rn%type; -- RN вида приемки

begin
  -- заголовок
  UDO_PKG_PROD_CULL.CULL_OUT_FIND(nRN,
                                  rCULL_OUT);

  -- разрешение ссылок
  UDO_PKG_PROD_CULL.CULL_OUT_JOIN(nCOMPANY  => rCULL_OUT.COMPANY,sCURRENCY => sCURRENCY,sACCEPT =>PIN_sACCEPT,  nCURRENCY => nCURRENCY, nACCEPT => nAccept);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(rCULL_OUT.COMPANY,
                   null,
                   rCULL_OUT.CRN,
                   rCULL_OUT.Jurpers,
                   'UdoProdCullSpOut',
                   'UDO_PROD_CULL_OUT_UPDATE',
                   'UDO_PROD_CULL_OUT',
                   nRN);

  -- базовое добавление
  UDO_PKG_PROD_CULL.CULL_OUT_UPDATE(nSIGN_OUT    => nSIGN_OUT,
                                    sSERNUMB_NEW => sSERNUMB_NEW,
                                    sCERT_NUMB   => sCERT_NUMB,
                                    dCERT_FROM   => dCERT_FROM,
                                    dCERT_TO     => dCERT_TO,
                                    nQUANT       => nQUANT,
                                    nPRICE       => nPRICE,
                                    nSUMM        => nSUMM,
                                    nCURRENCY    => nCURRENCY ,
                                    sNOTE        => sNOTE,
                                    pin_PROD_DATE_D     =>      pin_PROD_DATE_D ,
                                    pin_PROD_DATE_S     =>      pin_PROD_DATE_S  ,
                                    PIN_SUPPLIER_PARTY  =>      PIN_SUPPLIER_PARTY,
                                    PIN_nACCEPT         =>      nACCEPT     ,
                                    PIN_RECHECK_DATE    =>      PIN_RECHECK_DATE 
                                   ,sCHECK_TYPES        => sCHECK_TYPES    
                                   ,sCHECK_DEFECTIVE    => sCHECK_DEFECTIVE
                                   ,sMEAS_PARAMS        => sMEAS_PARAMS    
                                   ,nRN                 => nRN);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(rCULL_OUT.COMPANY,
                   null,
                   rCULL_OUT.CRN,
                   rCULL_OUT.Jurpers,
                   'UdoProdCullSpOut',
                   'UDO_PROD_CULL_OUT_UPDATE',
                   'UDO_PROD_CULL_OUT',
                   nRN);
end UDO_P_PROD_CULL_OUT_UPDATE;
/
