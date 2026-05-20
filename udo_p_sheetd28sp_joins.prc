create or replace procedure UDO_P_SHEETD28SP_JOINS(
       nCOMPANY             in number,   -- Организация
       sMATRES_NOMEN        in varchar2, -- Материальный ресурс (номенклатура)
       sMATRES_MODIF        in varchar2, -- Материальный ресурс (модификация номенклатуры)
       sMATRES_DIFF_NOMEN   in varchar2, -- Материальный ресурс замены (номенклатура)
       sMATRES_DIFF_MODIF   in varchar2, -- Материальный ресурс замены (модификация номенклатуры)
       nMATRES              out number,  -- Материальный ресурс
       nMATRES_DIFF         out number   -- Материальный ресурс замены
       ) is
/* Разрешение ссылок записи спецификации ведомости Д28 */
begin

  -- Материальный ресурс
  FIND_FCMATRES_BY_NOM_AND_MODIF(0, nCOMPANY, sMATRES_NOMEN, sMATRES_MODIF, nMATRES);

  -- Материальный ресурс замены
  if rtrim(sMATRES_DIFF_NOMEN) is not null then
    FIND_FCMATRES_BY_NOM_AND_MODIF(0, nCOMPANY, sMATRES_DIFF_NOMEN, sMATRES_DIFF_MODIF, nMATRES_DIFF);
  end if;

end UDO_P_SHEETD28SP_JOINS;
/

