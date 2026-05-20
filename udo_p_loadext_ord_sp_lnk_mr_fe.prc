create or replace procedure UDO_P_LOADEXT_ORD_SP_LNK_MR_FE
(
  nRN                         in number,       -- Рег. номер записи
  nCOMPANY                    in number,       -- Рег. номер организации 
  sATTRIB                     in varchar2,     -- Изменяемый атрибут
  nFIRST                      in out number,   -- Признак запуска (1-первый запуск,0-остальные) 
  sNOMEN_CODE                 in out varchar2, -- Код номенклатуры
  sNOMEN_CODE_EN              in out number,   -- Доступность атрибута "Код номенклатуры"
  sNOMEN_NAME                 in out varchar2, -- Наименование номенклатуры
  SNOMMODIF_CODE              in out varchar2, -- Код модификации  
  SNOMMODIF_CODE_EN           in out number,   -- Доступность атрибута "Код модификации"
  SNOMMODIF_NAME              in out varchar2  -- Наименование модификации
) is
/*
  Процедура для формы ввода действия "Связать с номенклатурой" в спецификации раздела "Загрузки из внешних источников"  

  grant execute on UDO_P_LOADEXT_ORD_SP_LNK_MR_FE to public;    
*/
  REC                       UDO_LOADEXT_ORD_SP%rowtype; -- Запись спецификации
  rMODIF                    nommodif%rowtype;           -- Запись модификации             
  rNOMEN                    dicnomns%rowtype;           -- Запись номенклатуры
  nMODIF                    pkg_std.tREF;               -- Рег. номер модияикации
  nFIRST_                   pkg_std.tREF := 1;          -- Признак запуска процедуры
begin
  
  if nFIRST = 1 then 
    /* считывание записи спецификации */  
    rec := UDO_PKG_LOADEXT_ORD_BASE.SP_GET_ID(NFLAG_SMART => 0, NRN => NRN);
   
    /* поиск утвержденных соответствий для номенклатуры */
    if rec.ext_id is not null then 
      nMODIF :=  UDO_F_MODIF_MATCHES_GET(nEXT_ID => rec.ext_id);
    
      /* поиск не утвержденных соответствий для номенклатуры */
      if nMODIF is null then 
        nMODIF := UDO_PKG_LOADEXT_ORD_BASE.SP_GET_MODIF_NOTCONF(sext_id => rec.ext_id);
      else 
        /* Запрещаем изменять номенклатуру, если есть утвержденные соответствия*/
        sNOMEN_CODE_EN    := 0;
        SNOMMODIF_CODE_EN := 0;
      end if;
      
      /* Инициализация полей для найденной номенклатуре */
      if nMODIF is not null then 
        
        rMODIF := udo_pkg_get.ROW_NOMMODIF(NRN => nMODIF, NSMART => 0);
        rNOMEN := udo_pkg_get.ROW_DICNOMNS(NRN => rMODIF.pRn, NSMART => 0);
        
        sNOMEN_CODE    := rNOMEN.Nomen_Code;       
        sNOMEN_NAME    := rNOMEN.Nomen_Name;   
        SNOMMODIF_CODE := rMODIF.Modif_Code;   
        SNOMMODIF_NAME := rMODIF.Modif_Name;   
      end if;
    end if;
     
    nFIRST := 0;
  end if;
  
  if sATTRIB = 'SNOMEN_CODE' then 
    /* установка модификации для номенклатуры */
    if sNOMEN_CODE is not null then 
      UDO_FIND_NOMMODIF_BY_NOMEN(nCOMPANY     => nCOMPANY,
                               nNOMEN         => null,
                               sNOMEN_CODE    => sNOMEN_CODE,
                               SNOMMODIF_CODE => SNOMMODIF_CODE,
                               SNOMMODIF_NAME => SNOMMODIF_NAME,
                               nFIRST         => nFIRST_);
    else 
      sNOMEN_NAME    := null;
      SNOMMODIF_CODE := null;
      SNOMMODIF_NAME := null;
    end if;
  end if;
  
end UDO_P_LOADEXT_ORD_SP_LNK_MR_FE;
/

