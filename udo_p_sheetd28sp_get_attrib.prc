create or replace procedure UDO_P_SHEETD28SP_GET_ATTRIB
(
  nRN                       in number,    -- Регистрационный номер записи
  nCOMPANY                  in number,    -- Организация
  nMATRES                   in number,    -- Материальный ресурс по спецификации
  nMATRES_DIFF              in number,    -- Материальный ресурс замены
  nMATRES_NOMEN             out number,   -- Номенклатура по спецификации
  sMATRES_NOMEN_CODE        out varchar2, -- 
  nMATRES_MODIF             out number,   -- Модификация по спецификации
  sMATRES_MODIF_CODE        out varchar2, -- 
  nUMEAS                    out number,   -- Основная единица изделия
  sUMEAS                    out varchar2, --
  nMATRES_DIFF_NOMEN        out number,   -- Номенклатура замены
  sMATRES_DIFF_NOMEN_CODE   out varchar2, -- 
  nMATRES_DIFF_MODIF        out number,   -- Модификация замены
  sMATRES_DIFF_MODIF_CODE   out varchar2  -- 
) is
begin

  /* Материальный ресурс по спецификации */
  begin
    select mr.nomenclature,
           n.nomen_code,
           mr.nomen_modif,
           m.modif_code,
           n.umeas_main,
           um.meas_mnemo
      into nMATRES_NOMEN,
           sMATRES_NOMEN_CODE,
           nMATRES_MODIF,
           sMATRES_MODIF_CODE,
           nUMEAS,
           sUMEAS
      from fcmatresource mr,
           dicnomns      n,
           nommodif      m,
           dicmunts      um
      where mr.rn           = nMATRES
        and mr.nomenclature = n.rn
        and mr.nomen_modif  = m.rn (+)
        and n.umeas_main    = um.rn;
  exception
    when NO_DATA_FOUND then null;
  end;

  /* Материальный ресурс замены */
  if nMATRES_DIFF is not null then
    begin
      select mr.nomenclature,
             n.nomen_code,
             mr.nomen_modif,
             m.modif_code
        into nMATRES_DIFF_NOMEN,
             sMATRES_DIFF_NOMEN_CODE,
             nMATRES_DIFF_MODIF,
             sMATRES_DIFF_MODIF_CODE
        from fcmatresource mr,
             dicnomns      n,
             nommodif      m,
             dicmunts      um
        where mr.rn           = nMATRES_DIFF
          and mr.nomenclature = n.rn
          and mr.nomen_modif  = m.rn (+)
          and n.umeas_main    = um.rn;
    exception
      when NO_DATA_FOUND then null;
    end;
  end if;
  
end UDO_P_SHEETD28SP_GET_ATTRIB;
/

