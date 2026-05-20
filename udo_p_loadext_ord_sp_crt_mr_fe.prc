create or replace procedure UDO_P_LOADEXT_ORD_SP_CRT_MR_FE
(
  nRN                         in number,       -- Рег. номер записи
  nFIRST                      in out number,   -- Признак запуска (1-первый запуск,0-остальные) 
  sNAME                       in out varchar2, -- Наименование номенклатуры
  sDCML_CODE                  in out varchar2, -- Децимальный номер (для изделий)
  sMEAS                       in out varchar2, -- Единица измерения
  nRES_SIGN                   in out number,   -- Признак МР (0 - собственного изготовления, 1 - покупное, 2 - по кооперации, 3 - отходы)   
  sPROD_KIND                  in out varchar2, -- Вид спецификации
  nEXT_ID                     in out number,   -- Идентификатор номенклатуры из внешней системы 
  sGROUP_CODE                 in out varchar2, -- Группа ТМЦ
  sMODIF_NAME                 in out varchar2  -- Наименование модификации 
) is
/*
  Процедура для формы ввода действия "Создать номенклатуру" в спецификации раздела "Загрузки из внешних источников"  

  grant execute on UDO_P_LOADEXT_ORD_SP_CRT_MR_FE to public;    
*/
  REC                       UDO_LOADEXT_ORD_SP%rowtype;             -- Запись спецификации
begin
  
  if nFIRST = 1 then 
    /* считывание записи спецификации */  
    rec := UDO_PKG_LOADEXT_ORD_BASE.SP_GET_ID(NFLAG_SMART => 0, NRN => NRN);
    
    /* устанока атрибутов */    
    nEXT_ID    := rec.ext_id;  -- внешний ID
    UDO_PKG_LOADEXT_ORD_BASE.SP_GET_NOMEN_ATTR(nRN         => nRN,       
                                               sNAME       => sNAME,     
                                               sMODIF_NAME => sMODIF_NAME,
                                               sDCML_CODE  => sDCML_CODE,
                                               sMEAS       => sMEAS,     
                                               nRES_SIGN   => nRES_SIGN, 
                                               sPROD_KIND  => sPROD_KIND,
                                               sGROUP_CODE => sGROUP_CODE);
    nFIRST := 0;
  end if;
end UDO_P_LOADEXT_ORD_SP_CRT_MR_FE;
/

