create or replace package UDO_PKG_TI_IF_DL_CREATE
is

  /* Точка старта */
  procedure DLMAKE_START
 (
  nCOMPANY         in number,
  NRN              in number,
  SUNITCODE        in varchar2,
  nDOC_RN_TI       in number,
  nDOC_RN_IF       in number,
  NTYPE_DL         in number           -- тип Связи (0 - по выходу; 1 - по входу)  
 );

  /* Обработка формы */
  procedure DLMAKE_FE
 (
    nCOMPANY         in number,
    SATRIB           in varchar2,        -- Изменённый атрибут
    nDOC_RN_TI       in out number,
    nDOC_RN_TI_ND    in out number,          -- доступность
    nDOC_RN_IF       in out number,
    nDOC_RN_IF_ND    in out number          -- доступность  
  );

end UDO_PKG_TI_IF_DL_CREATE;
/

create or replace package body UDO_PKG_TI_IF_DL_CREATE
is

 /* Создание связи */
 procedure LINKS_MAKE
 (
    nCOMPANY         in number,
    sIN_UNITCODE     in varchar2,
    nIN_DOCUMENT     in number,
    sOUT_UNITCODE    in varchar2,
    nOUT_DOCUMENT    in number  
 )
 is
 begin

   PKG_DOCLINKS.LINK(nFLAG_SMART   => 0,
                     nCOMPANY      => nCOMPANY,
                     sIN_UNITCODE  => sIN_UNITCODE,
                     nIN_DOCUMENT  => nIN_DOCUMENT,
                     sOUT_UNITCODE => sOUT_UNITCODE,
                     nOUT_DOCUMENT => nOUT_DOCUMENT);
 end LINKS_MAKE;
 /* Обработка данных */
 procedure DATA_PREPARE
 (
  nCOMPANY         in number,
  NRN              in number,
  SUNITCODE        in varchar2,
  nDOC_RN_TI       in number,
  nDOC_RN_IF       in number,
  NTYPE_DL         in number           -- тип Связи (0 - по выходу; 1 - по входу)  
 )
 is
    sIN_UNITCODE     PKG_STD.tSTRING;
    nIN_DOCUMENT     PKG_STD.tREF;
    sOUT_UNITCODE    PKG_STD.tSTRING;
    nOUT_DOCUMENT    PKG_STD.tREF;  
    sOUT_UNITCODE_REC    PKG_STD.tSTRING;
    nOUT_DOCUMENT_REC    PKG_STD.tREF;     
 begin
  -- p_exception(0,'nDOC_RN_TI - "%s" nDOC_RN_IF - "%s"', nDOC_RN_TI, nDOC_RN_IF); 
   if nDOC_RN_TI is not null then
     nOUT_DOCUMENT_REC := nDOC_RN_TI;
     sOUT_UNITCODE_REC := 'GoodsTransInvoicesToDepts';
   elsif nDOC_RN_IF is not null then
     nOUT_DOCUMENT_REC := nDOC_RN_IF;
     sOUT_UNITCODE_REC := 'IncomFromDeps';
   elsif nDOC_RN_TI is null and nDOC_RN_IF is null then
     p_exception(0,
                 'Документ для построения связи не выбран.');
   end if;
 
   case NTYPE_DL
     when 0 then
       sIN_UNITCODE  := SUNITCODE;
       nIN_DOCUMENT  := NRN;
       sOUT_UNITCODE := sOUT_UNITCODE_REC;
       nOUT_DOCUMENT := nOUT_DOCUMENT_REC;
     else
       sIN_UNITCODE  := sOUT_UNITCODE_REC;
       nIN_DOCUMENT  := nOUT_DOCUMENT_REC;
       sOUT_UNITCODE := SUNITCODE;
       nOUT_DOCUMENT := NRN;
   end case;
   /* Создание связи */
   LINKS_MAKE(nCOMPANY      => nCOMPANY,
              sIN_UNITCODE  => sIN_UNITCODE,
              nIN_DOCUMENT  => nIN_DOCUMENT,
              sOUT_UNITCODE => sOUT_UNITCODE,
              nOUT_DOCUMENT => nOUT_DOCUMENT);
 
 end DATA_PREPARE;
  /* Точка старта */
  procedure DLMAKE_START
 (
  nCOMPANY         in number,
  NRN              in number,
  SUNITCODE        in varchar2,
  nDOC_RN_TI       in number,
  nDOC_RN_IF       in number,
  NTYPE_DL         in number           -- тип Связи (0 - по выходу; 1 - по входу)  
 )
 is
 begin
   DATA_PREPARE(nCOMPANY   => nCOMPANY,
                NRN        => NRN,
                SUNITCODE  => SUNITCODE,
                nDOC_RN_TI => nDOC_RN_TI,
                nDOC_RN_IF => nDOC_RN_IF,
                NTYPE_DL   => NTYPE_DL);
 
 end DLMAKE_START;

  /* Обработка формы */
  procedure DLMAKE_FE
 (
    nCOMPANY         in number,
    SATRIB           in varchar2,        -- Изменённый атрибут
    nDOC_RN_TI       in out number,
    nDOC_RN_TI_ND    in out number,          -- доступность
    nDOC_RN_IF       in out number,
    nDOC_RN_IF_ND    in out number          -- доступность  
  )
  is
  begin
    if SATRIB is null then
      nDOC_RN_TI_ND := 1;
      nDOC_RN_IF_ND := 1;
      nDOC_RN_TI := null;
      nDOC_RN_IF := null;
    end if;
    if SATRIB = 'sDOC_RN_TI' then
      nDOC_RN_IF    := null;
      nDOC_RN_IF_ND := 0;
    end if;
    if SATRIB = 'sDOC_RN_IF' then
      nDOC_RN_TI    := null;
      nDOC_RN_TI_ND := 0;
    end if;
  
  end DLMAKE_FE;
  
  
end UDO_PKG_TI_IF_DL_CREATE;
/

