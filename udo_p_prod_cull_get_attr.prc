create or replace procedure UDO_P_PROD_CULL_GET_ATTR
(
  nCOMPANY  in number, -- Рег. номер организации
  nMODE     in out number,
  nFIRST    in out number,
  sJURPERS  in out varchar2, --       юр. лица
  sDOC_TYPE in out varchar2, --      типа документа
  sDOC_PREF in out varchar2, --     Префикс документа
  sDOC_NUMB in out varchar2, --      Номер документа
  dDOC_DATE in out date,     --Дата документа
  sATTRIB   in varchar2
  --sSIGN     in varchar2 default 'I' -- 'I'-добавление, 'U'-исправление
) is
  /*
  Процедура подбора атрибутов 
  */
  nJUR_PERS pkg_std.tREF;
begin
  if nMODE in (0,1) then  
    -- дата документа 
    if dDOC_DATE is null then
      dDOC_DATE := trunc(sysdate);
    end if;
    
    -- тип локумента 
    if sDOC_TYPE is null then 
      sDOC_TYPE :=  null;/*GET_OPTIONS_STR('UdoProdCull_DocType',nCOMPANY);*/
    end if ; 
    
    -- префикс 
    if sDOC_PREF is null then 
      sDOC_PREF :=  to_char(d_year(dDOC_DATE));/*GET_OPTIONS_STR('UdoProdCull_DocPref',nCOMPANY);*/
    end if ;
    
    -- юр. лицо 
    if sJURPERS is null then
      find_jurpersons_main(0,
                           nCOMPANY,
                           sJURPERS,
                           nJUR_PERS);
    end if;
    
    
   end if;
   
   if sATTRIB in ('SDOC_TYPE', 'SDOC_PREF') or (nMODE in (0,1)  and nFIRST = 1)  then 
     -- номер документа 
     if sDOC_TYPE is not null and sDOC_PREF is not null then
       udo_pkg_prod_cull.CULL_NEXT_NUMB(nCOMPANY  => nCOMPANY,
                                        sDOC_TYPE => sDOC_TYPE,
                                        sPREF     => sDOC_PREF,
                                        sNUMB     => sDOC_NUMB);
     end if;
   end if;  
   
   nFIRST := 0;
end UDO_P_PROD_CULL_GET_ATTR;
/*
  create public synonym UDO_P_PROD_CULL_GET_ATTR for UDO_P_PROD_CULL_GET_ATTR;
  grant execute on UDO_P_PROD_CULL_GET_ATTR to public;
  */
/

