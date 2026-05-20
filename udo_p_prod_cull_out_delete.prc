create or replace procedure UDO_P_PROD_CULL_OUT_DELETE(nRN in number -- Рег. номер записи
                                                       ) is
  /*
   Клиентская процедура удаления  записи.
  Раздел "Выбраковка"  (спецификация-номенклатура)
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
      from UDO_PROD_CULL_OUT t
          ,UDO_PROD_CULL_SP  sp
          ,UDO_PROD_CULL     p
     where t.rn = nRN
       and t.prn = sp.rn
       and sp.prn = p.rn;
  exception
    when no_data_found then
      pkg_msg.RECORD_NOT_FOUND(0,
                               nRN,
                               'UDO_PROD_CULL_OUT');
  end;
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE(nCOMPANY,
                   null,
                   nCRN,
                   nJURPERS,
                   'UdoProdCullSpOut',
                   'UDO_PROD_CULL_OUT_DELETE',
                   'UDO_PROD_CULL_OUT',
                   nRN);
  -- базовое добавление 
  UDO_PKG_PROD_CULL.CULL_OUT_DELETE(nRN => nRN -- Рег. номер записи
                                    );
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE(nCOMPANY,
                   null,
                   nCRN,
                   nJURPERS,
                   'UdoProdCullSpOut',
                   'UDO_PROD_CULL_OUT_DELETE',
                   'UDO_PROD_CULL_OUT',
                   nRN);
end UDO_P_PROD_CULL_OUT_DELETE;
/*
  create public synonym UDO_P_PROD_CULL_OUT_DELETE for UDO_P_PROD_CULL_OUT_DELETE;
  grant execute on UDO_P_PROD_CULL_OUT_DELETE to public;
  */
/

