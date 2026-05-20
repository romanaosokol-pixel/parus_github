create or replace procedure UDO_P_PROD_CULL_DELETE(nRN in number -- Рег. номер записи
                                                   ) is
  /*
  Клиентская процедура удаления  записи.
  Раздел "Выбраковка"
  */
  nCOMPANY number; -- Рег. номер организации
  nCRN     number; -- Рег. номер каталога
  nJURPERS number; -- Рег. номер юр. лица 
begin
  begin
    select t.company
          ,t.crn
          ,t.jurpers
      into nCOMPANY
          ,nCRN
          ,nJURPERS
      from UDO_PROD_CULL t
     where t.rn = nRN;
  exception
    when no_data_found then
      pkg_msg.RECORD_NOT_FOUND(0,
                               nRN,
                               'UDO_PROD_CULL');
  end;
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(nCOMPANY,
                   null,
                   nCRN,
                   nJURPERS,
                   'UdoProdCull',
                   'UDO_PROD_CULL_DELETE',
                   'UDO_PROD_CULL',
                   nRN);
  -- базовое добавление 
  UDO_PKG_PROD_CULL.CULL_DELETE(nRN => nRN -- Рег. номер записи
                                );
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(nCOMPANY,
                   null,
                   nCRN,
                   nJURPERS,
                   'UdoProdCull',
                   'UDO_PROD_CULL_DELETE',
                   'UDO_PROD_CULL',
                   nRN);
end UDO_P_PROD_CULL_DELETE;
/*
  create public synonym UDO_P_PROD_CULL_DELETE for UDO_P_PROD_CULL_DELETE;
  grant execute on UDO_P_PROD_CULL_DELETE to public;
  */
/

