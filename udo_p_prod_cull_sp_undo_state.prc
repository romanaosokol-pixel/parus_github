create or replace procedure UDO_P_PROD_CULL_SP_UNDO_STATE
(
  nPRN                        in number -- Рег. номер записи
                                                      
) is
  /*
  Клиентская процедура снятия отработки. Раздел "Сертификацияя ТМЦ/ВК"
  
  grant execute on UDO_P_PROD_CULL_SP_UNDO_STATE to public;
  */
  rCULL                       udo_prod_cull%rowtype; -- запись раздела                
begin
  -- заголовок 
  UDO_PKG_PROD_CULL.CULL_FIND(nPRN,
                              rCULL);
                              
  /* Проверка прав на выполнение действия */
  PKG_ENV.ACCESS(nCOMPANY  => rCULL.COMPANY,
                 nVERSION  => null,
                 nCATALOG  => rCULL.CRN,
                 nJUR_PERS => rCULL.JURPERS,
                 sUNIT     => 'UdoProdCullSp',
                 sACTION   => 'UDO_PROD_CULL_SP_UNDO_STATE');
                 
  /* Базовое снятие отработки */ 
  UDO_PKG_PROD_CULL.CULL_SP_WORK_UNDO(nPRN => nPRN);
                  
end;
/

