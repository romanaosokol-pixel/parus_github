create or replace procedure UDO_P_LOADEXT_CMP_COMP_LD_FE
(
  nPRN                        in number,       -- Рег. номер записи родителя 
  NPRCNT                      in out number    -- Значение процента
) is
/*
  Процедура для формы ввода действия "Подбор номенклатуры" в спецификации раздела "Загрузки из внешних источников"  

  grant execute on UDO_P_LOADEXT_CMP_COMP_LD_FE to public;    
*/  
begin
  NPRCNT := 55;
end;
/

