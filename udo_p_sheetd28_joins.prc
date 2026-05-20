create or replace procedure UDO_P_SHEETD28_JOINS(
       nCOMPANY             in number,   -- Организация
       sJUR_PERS            in varchar2, -- Принадлежность
       sDOCTYPE             in varchar2, -- Тип документа
       sSUBDIV              in varchar2, -- Подразделение
       sRESPONSIBLE         in varchar2, -- Ответственный
       sMATRES_NOMEN        in varchar2, -- Изделие (номенклатура)
       sMATRES_MODIF        in varchar2, -- Изделие (модификация номенклатуры)
       nJUR_PERS            out number,  -- Принадлежность
       nDOCTYPE             out number,  -- Тип документа
       nSUBDIV              out number,  -- Подразделение
       nRESPONSIBLE         out number,  -- Ответственный
       nMATRES              out number   -- Изделие
       ) is
/* Разрешение ссылок записи ведомости Д28 */
begin
  -- Тип документа
  FIND_DOCTYPES_CODE_EX(0,0, nCOMPANY, sDOCTYPE, nDOCTYPE);

  -- Принадлежность
  FIND_JURPERSONS_CODE(0, 0, nCOMPANY, sJUR_PERS, nJUR_PERS);

  -- Подразделение
  if rtrim(sSUBDIV) is not null then
      FIND_SUBDIVS_CODE_EX(0,0, nCOMPANY, sSUBDIV, nSUBDIV);
  end if;

  -- Ответственный
  if rtrim(sRESPONSIBLE) is not null then
      FIND_AGNLIST_CODE(0,0, nCOMPANY, sRESPONSIBLE, nRESPONSIBLE);
  end if;

  -- Изделие
  FIND_FCMATRES_BY_NOM_AND_MODIF(0, nCOMPANY, sMATRES_NOMEN, sMATRES_MODIF, nMATRES);

end UDO_P_SHEETD28_JOINS;
/

