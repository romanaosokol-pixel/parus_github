create or replace procedure UDO_P_SHEETD28_GET_ATTRIB
(
  nRN                       in number,    -- Регистрационный номер
  nCOMPANY                  in number,    -- Организация
  nMATRES                   in number,    -- Изделие
  nMATRES_NOMEN             out number,   -- Номенклатура изделия
  sMATRES_NOMEN_CODE        out varchar2, -- 
  nMATRES_MODIF             out number,   -- Модификация изделия
  sMATRES_MODIF_CODE        out varchar2, -- 
  nUMEAS                    out number,   -- Основная единица изделия
  sUMEAS                    out varchar2  --
) is
begin

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
  
end UDO_P_SHEETD28_GET_ATTRIB;
/

