create or replace procedure UDO_P_PRJSTG_PRSTR_CLC_UPDATE
/*
  Клиентская процедура исправления статьи структуры цены этапа проекта

  grant execute on UDO_P_PRJSTG_PRSTR_CLC_UPDATE to public;
 */
(
  nRN             in number,            -- Регистрационный номер
  nCOMPANY        in number,            -- Организация
  sNUMB           in varchar2,          -- Номер строки калькуляции
  sCOST_ARTICLE   in varchar2,          -- Мнемокод статьи затрат
  nEXP_TYPE       in number,            -- Тип затрат
  nCOST_SUM       in number             -- Сумма затрат
 ) is

begin

 UDO_PKG_PRJSTG_PRSTRUCT.CLC_UPDATE
(
  nRN             => nRN,
  nCOMPANY        => nCOMPANY     ,
  sNUMB           => sNUMB        ,
  sCOST_ARTICLE   => sCOST_ARTICLE,
  nEXP_TYPE       => nEXP_TYPE    ,
  nCOST_SUM       => nCOST_SUM

);
end;
/

