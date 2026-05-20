create or replace procedure UDO_P_PROD_CULL_INSERT
(
  nCOMPANY                  in number, -- Рег. номер организации
  nCRN                      in number, -- Рег. номер каталога
  nMODE_CHECK               in number, --Режим проверки (0-сертификация ТМЦ, 1-входной контроль) 
  sJURPERS                  in varchar2, -- юр. лицо
  sDOC_TYPE                 in varchar2, -- тип документа    
  sDOC_PREF                 in varchar2, -- Префикс документа
  sDOC_NUMB                 in varchar2, -- Номер документа 
  dDOC_DATE                 in date, -- Дата документа
  sSTORE_CULL               in varchar2, -- склад списания
  sSTOPER_CULL              in varchar2, -- складская операция списания 
  sSTORE_IN                 in varchar2, -- склада поступления
  sSTOPER_IN                in varchar2, -- складская операция поступления
  sSTORE_SPOIL              in varchar2, --  склад брака
  sSTOPER_SPOIL             in varchar2, --   складская операция брака
  sFACEACC_DIV              in varchar2, -- лицевой счет подразделения
  sFACEACC_AGN              in varchar2, -- лицевой счет контрагента
  sEXECUTOR                 in varchar2, -- исполнитель 
  sNOTE                     in varchar2, -- Примечание 
  nRN                       in out number -- Рег. номер записи
) is
  /*
  Клиентская процедура добавления записи.
  Раздел "Выбраковка"
  */
  rPROD_cull udo_prod_cull%rowtype; -- запись раздела 
begin
  -- разрешение ссылок
  UDO_PKG_PROD_CULL.CULL_JOIN(nCOMPANY      => nCOMPANY,
                              sJURPERS      => sJURPERS, -- юр. лицо
                              sDOC_TYPE     => sDOC_TYPE, -- тип документа  
                              sSTORE_CULL   => sSTORE_CULL, -- склад списания
                              sSTOPER_CULL  => sSTOPER_CULL, -- складская операция списания 
                              sSTORE_IN     => sSTORE_IN, -- склада поступления
                              sSTOPER_IN    => sSTOPER_IN, -- складская операция поступления
                              sSTORE_SPOIL  => sSTORE_SPOIL, --  склад брака
                              sSTOPER_SPOIL => sSTOPER_SPOIL, --   складская операция брака
                              sFACEACC_DIV  => sFACEACC_DIV, -- лицевой счет подразделения
                              sFACEACC_AGN  => sFACEACC_AGN,
                              sEXECUTOR     => sEXECUTOR, -- исполнитель 
                              nJURPERS      => rPROD_cull.Jurpers, -- Рег. номер юр. лица
                              nDOC_TYPE     => rPROD_cull.Doc_Type, -- Рег. номер типа документа  
                              nSTORE_CULL   => rPROD_cull.Store_Cull, -- Рег. номер склада списания
                              nSTOPER_CULL  => rPROD_cull.Stoper_Cull, -- Рег. номер складской операции списания 
                              nSTORE_IN     => rPROD_cull.Store_In, -- Рег. номер склада поступления
                              nSTOPER_IN    => rPROD_cull.Stoper_In, -- Рег. номер  складской операции поступления
                              nSTORE_SPOIL  => rPROD_cull.Store_Spoil, -- Рег. номер склада брака
                              nSTOPER_SPOIL => rPROD_cull.Stoper_Spoil, -- Рег. номер  складской операции брака
                              nFACEACC_DIV  => rPROD_cull.Faceacc_Div, -- Рег. номер лицевого счета подразделения
                              nFACEACC_AGN  => rPROD_cull.Faceacc_Agn, -- Рег. номер лицевого счета контаргента
                              nEXECUTOR     => rPROD_cull.Executor -- Рег. номер контрагента исполнителя 
                              );
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(nCOMPANY,
                   null,
                   nCRN,
                   sJURPERS,
                   'UdoProdCull',
                   'UDO_PROD_CULL_INSERT',
                   'UDO_PROD_CULL');
  -- базовое добавление 
  UDO_PKG_PROD_CULL.CULL_INSERT(nCOMPANY      => nCOMPANY, -- Рег. номер организации
                                nCRN          => nCRN, -- Рег. номер каталога
                                nJURPERS      => rPROD_cull.Jurpers, -- Рег. номер юр. лица
                                nDOC_TYPE     => rPROD_cull.Doc_Type, -- Рег. номер типа документа  
                                sDOC_PREF     => sDOC_PREF, -- Префикс документа
                                sDOC_NUMB     => sDOC_NUMB, -- Номер документа 
                                dDOC_DATE     => dDOC_DATE, -- Дата документа 
                                nSTORE_CULL   => rPROD_cull.Store_Cull, -- Рег. номер склада списания
                                nSTOPER_CULL  => rPROD_cull.Stoper_Cull, -- Рег. номер складской операции списания 
                                nSTORE_IN     => rPROD_cull.Store_In, -- Рег. номер склада поступления
                                nSTOPER_IN    => rPROD_cull.Stoper_In, -- Рег. номер  складской операции поступления
                                nSTORE_SPOIL  => rPROD_cull.Store_Spoil, -- Рег. номер склада брака
                                nSTOPER_SPOIL => rPROD_cull.Stoper_Spoil, -- Рег. номер  складской операции брака
                                nFACEACC_DIV  => rPROD_cull.Faceacc_Div, -- Рег. номер лицевого счета подразделения
                                nEXECUTOR     => rPROD_cull.Executor, -- Рег. номер контрагента исполнителя \
                                nFACEACC_AGN  => rPROD_cull.Faceacc_Agn,
                                sNOTE         => sNOTE, -- примечание
                                nMODE_CHECK   => nMODE_CHECK, 
                                nRN           => nRN -- Рег. номер записи
                                );
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(nCOMPANY,
                   null,
                   nCRN,
                   sJURPERS,
                   'UdoProdCull',
                   'UDO_PROD_CULL_INSERT',
                   'UDO_PROD_CULL',
                   nRN);
end UDO_P_PROD_CULL_INSERT;
/*
  create public synonym UDO_P_PROD_CULL_INSERT for UDO_P_PROD_CULL_INSERT;
  grant execute on UDO_P_PROD_CULL_INSERT to public;
  */
/

