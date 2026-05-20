create or replace procedure UDO_P_PROD_CULL_SP_SET_STATE
( 
  nPRN                        in number,  -- Рег. номер записи 
  nIDENT                      in number,  -- Идентификатор отмеченных записей
  sSTORE_IN                   in varchar2, -- Склад прихода
  nCERT_LOSS                  in number -- 14/06/2023 Марков МВ.признак получения сертификата позже
) is
 
  /*
  Клиентская процедура отработки записи. Раздел "Сертификация ТМЦ/ ВК"
  07/07/2024 Степанов М. добавление пролога и эпилога
  grant execute on UDO_P_PROD_CULL_SP_SET_STATE to public;
  */
  rCULL                       udo_prod_cull%rowtype; -- запись раздела 
  nSTORE_IN                   pkg_std.tREF;          -- Рег. номер склада прихода 
 begin 
  -- заголовок 
  UDO_PKG_PROD_CULL.CULL_FIND(nPRN,
                              rCULL);  

  /*07/07/2024 Степанов М. добавление пролога и эпилога*/
  for c in (select document from selectlist where ident = nIDENT)
  loop 
    PKG_ENV.PROLOGUE(rCULL.COMPANY,
                     null,
                     rCULL.CRN,
                     rCULL.Jurpers,
                     'UdoProdCullSp',
                     'UDO_PROD_CULL_SP_SET_STATE',
                     'UDO_PROD_CULL_SP'
                     ,c.document);
  end loop;
 
  /* Склад прихода */
  find_dicstore_numb(nFLAG_SMART => 0,
                     nCOMPANY    => rCULL.Company,
                     sNUMB       => sSTORE_IN,
                     nRN         => nSTORE_IN);
                     
  /* Проверка прав на выполнение действия */
  /*07/07/2024 Степанов М. добавление пролога и эпилога*/
  /*PKG_ENV.ACCESS(nCOMPANY  => rCULL.COMPANY,
                 nVERSION  => null,
                 nCATALOG  => rCULL.CRN,
                 nJUR_PERS => rCULL.JURPERS,
                 sUNIT     => 'UdoProdCullSp',
                 sACTION   => 'UDO_PROD_CULL_SP_SET_STATE');*/
       
  /* Базовая отработка */
  UDO_PKG_PROD_CULL.CULL_SP_WORK(nPRN => nPRN, nIDENT => nIDENT, nSTORE_IN => nSTORE_IN, nCERT_LOSS => nCERT_LOSS);

  /*07/07/2024 Степанов М. добавление пролога и эпилога*/
  for c in (select document from selectlist where ident = nIDENT)
  loop 
    /* фиксация окончания выполнения действия */
    PKG_ENV.EPILOGUE(rCULL.COMPANY,
                     null,
                     rCULL.CRN,
                     rCULL.Jurpers,
                     'UdoProdCullSp',
                     'UDO_PROD_CULL_SP_SET_STATE',
                     'UDO_PROD_CULL_SP',
                     c.document);
  end loop;
            
end;
/
