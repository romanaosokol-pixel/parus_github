create or replace procedure UDO_P_MTRLSHTSUB_GETNEXTNUMB
(
  nCOMPANY      in number,       -- Организация
  SDOCTYPE      in varchar2,     -- Тип документа 
  sPREF         in varchar2,     -- Префикс документа
  sNUMB         out varchar2     -- Номер документа
)
as
  /* Генерация номера раздела "Ведомости замен материалов" 
     grant execute on UDO_P_MTRLSHTSUB_GETNEXTNUMB to public; 
    
  */
  nDOCTYPE      PKG_STD.tREF;    -- Ссылка на "Тип документа"
begin
  /* Тип документа */
  find_doctypes_code_ex(nFLAG_SMART  => 0,
                        nFLAG_OPTION => 1,
                        nCOMPANY     => nCOMPANY,
                        sCODE        => SDOCTYPE,
                        nRN          => nDOCTYPE);

  /* генерация */
  if sPREF is not null and nDOCTYPE is not null then 
    UDO_PKG_MTRLSHTSUB_BASE.SUB_GETNEXTNUMB(nCOMPANY => nCOMPANY,
                                            nDOCTYPE => nDOCTYPE,
                                            sPREF    => sPREF,
                                            sNUMB    => sNUMB); 
  end if;                                            
end;
/

