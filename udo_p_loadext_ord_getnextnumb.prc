create or replace procedure UDO_P_LOADEXT_ORD_GETNEXTNUMB
(
  nCOMPANY      in number,       -- Организация
  SDOC_TYPE     in varchar2,     -- Тип документа
  sPREF         in varchar2,     -- Префикс документа
  sNUMB         out varchar2     -- Номер документа
)
as
  /* Генерация номера раздела "Загрузка заявки из внешних источников"*/
  nDOC_TYPE     PKG_STD.tREF;    -- Ссылка на "Тип документа"
begin
  /* Тип документа */
  find_doctypes_code_ex(nFLAG_SMART  => 0,
                        nFLAG_OPTION => 1,
                        nCOMPANY     => nCOMPANY,
                        sCODE        => SDOC_TYPE,
                        nRN          => nDOC_TYPE);

  /* генерация */
  if sPREF is not null and nDOC_TYPE is not null then
    UDO_PKG_LOADEXT_ORD_BASE.ORD_GETNEXTNUMB(nCOMPANY  => nCOMPANY,
                                             nDOC_TYPE => nDOC_TYPE,
                                             sPREF     => sPREF,
                                             sNUMB     => sNUMB);
  end if;
end;
/

