create or replace procedure UDO_P_PROD_CULL_SP_DELETE
(
  nRN                       in number  -- Рег. номер записи                                             
) is
  /*
  Клиентская процедура удаления  записи.
  Раздел "Выбраковка (спецификация)"
  */
  nCOMPANY number; -- Рег. номер организации
  nCRN     number; -- Рег. номер каталога
  nJURPERS number; -- Рег. номер  юр лица 
begin
  begin
    select t.company
          ,t.crn
          ,p.jurpers
      into nCOMPANY
          ,nCRN
          ,nJURPERS 
      from UDO_PROD_CULL_SP t,
           UDO_PROD_CULL p
     where t.rn = nRN
       and t.prn = p.rn 
       
     ;
  exception
    when no_data_found then
      pkg_msg.RECORD_NOT_FOUND(0,
                               nRN,
                               'UDO_PROD_CULL_SP');
  end;
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(nCOMPANY,
                   null,
                   nCRN,
                   nJURPERS,
                   'UdoProdCullSp',
                   'UDO_PROD_CULL_SP_DELETE',
                   'UDO_PROD_CULL_SP',
                   nRN);
  /**/
  UDO_PKG_PROD_CULL.CULL_SP_DELETE(nRN => nRN); 
                   
  
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(nCOMPANY,
                   null,
                   nCRN,
                   nJURPERS,
                   'UdoProdCullSp',
                   'UDO_PROD_CULL_SP_DELETE',
                   'UDO_PROD_CULL_SP',
                   nRN);
end UDO_P_PROD_CULL_SP_DELETE;
/*
  create public synonym UDO_P_PROD_CULL_SP_DELETE for UDO_P_PROD_CULL_SP_DELETE;
  grant execute on UDO_P_PROD_CULL_SP_DELETE to public;
  */
/

