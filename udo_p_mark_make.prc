create or replace procedure UDO_P_MARK_MAKE
(
  nCOMPANY             in number,    -- Организация
  sVERSHION            in varchar,     -- RN Бюджета
--  sSTATE             in varchar,
  sTYPE                in varchar,
  sFORMPLAN            in varchar,
  nENPERIOD            in number      -- Год бюджета
  )
is
  nTMP_RN PKG_STD.tREF := 0;
  nPeriod PKG_STD.tNUMBER := extract (year from sysdate);
begin
  if nPeriod > nENPERIOD then nPeriod := nENPERIOD; end if; 
  
  for per in(
    select ep.rn
--    into nTMP_RN
    from ENPERIOD ep
    where ep.PERTYPE =  3
      and extract (year from ep.startdate) between nPeriod and nENPERIOD
    --  and exists (select null from UDO_T_FINPLAN fp where fp.fp_period = ep.rn)
  ) loop    
    nTMP_RN := 1;
    
    UDO_PKG_MFINPLAN_MAKE2 .MAKE_MARK(
      nCOMPANY  => nCOMPANY,
      sVERSHION => sVERSHION,
      sSTATE    => 'Факт',
      sTYPE     => sTYPE,
      sFORMPLAN => sFORMPLAN,
      nENPERIOD => per.rn);
    

    UDO_PKG_MFINPLAN_MAKE2.MAKE_MARK(
      nCOMPANY  => nCOMPANY,
      sVERSHION => sVERSHION,
      sSTATE    => 'План',
      sTYPE     => sTYPE,
      sFORMPLAN => sFORMPLAN,
      nENPERIOD => per.rn);
  end loop;
  
   /* Обновление опубликованных данных многомерного отчета */
   PKG_EXS_EXT_OLAPP_RUN.REFRESH(
       NCOMPANY       => nCOMPANY,  /* Рег. номер организации */
       NEXSEXTOLAPP   => 263768813  /* Рег. номер публикации */
   );
      
  if nTMP_RN = 0 then
    P_exception('Период не определён. '||error_text);
  end if;  
end UDO_P_MARK_MAKE;
/
