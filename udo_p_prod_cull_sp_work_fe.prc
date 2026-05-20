create or replace procedure UDO_P_PROD_CULL_SP_WORK_FE
(
  nPRN                        in number,         -- Рег. номер родительской записи
  nFIRST                      in out number,     -- признак первого запуска (1-первый запуск, 0- последующие)
  SSTORE_IN                   in out varchar2,    -- Склад прихода 
  nCERT                       in out number       -- признак Сертификации
) is
  /*
  Процедура для валидатора формы ввода для действия "Отработать" спецификаци раздела "Сертификация ТМЦ"  
  grant execute on UDO_P_PROD_CULL_SP_WORK_FE to public;
  */
  rec                         udo_prod_cull%rowtype;     -- запись заголовка
  rSTORE                      azsazslistmt%rowtype;      -- запись склада
begin
  /* запись заголовка */
  UDO_PKG_PROD_CULL.CULL_FIND(nRN => nPRN,rCULL => rec);
  
  -- Сертификация
  if rec.Mode_Check = 0 then
    nCERT := 1;
  else
    nCERT := 0;
  end if;
  
  if nFIRST = 1 then
    
    /* Склад прихда */
    rSTORE    := udo_pkg_get.ROW_STORE(NRN => rec.store_in, NSMART => 1);
    SSTORE_IN := rSTORE.Azs_Number;
    
    nFIRST := 0;
  end if; 
end;
/

