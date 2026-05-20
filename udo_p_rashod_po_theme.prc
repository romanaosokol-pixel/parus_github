create or replace procedure UDO_P_RASHOD_PO_THEME(
       nComp   IN NUMBER, 
       nStage  IN integer, /* 0 - без Этапов, 1 - с Этапами */
       nMark   IN integer, /* 0 - по Договорам, 1 - по Показателям */
       dDate   IN DATE) 
  ---- Пакет вызова отчетов "Расходы по тематической деятельности"
is
  begin

  if (1 = nMark) then
    UDO_PKG_RASHOD_PO_THEME.UDO_P_RASHOD_PO_THEME_MARK(nComp => nComp, nStage => nStage, dDate => dDate);
  else
    UDO_PKG_RASHOD_PO_THEME.UDO_P_RASHOD_PO_THEME_DOC(nComp => nComp, nStage => nStage, dDate => dDate);
  end if;
   
end UDO_P_RASHOD_PO_THEME;
/

