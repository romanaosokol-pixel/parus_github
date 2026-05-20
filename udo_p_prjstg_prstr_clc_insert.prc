create or replace procedure UDO_P_PRJSTG_PRSTR_CLC_INSERT
/*
  Клиентская процедура добавления статьи структуры цены этапа проекта

  grant execute on UDO_P_PRJSTG_PRSTR_CLC_INSERT to public;
 */
(
  nCOMPANY        in number,            -- Организация
  nPRN            in number,            -- Родитель
  sNUMB           in varchar2,          -- Номер строки калькуляции
  sCOST_ARTICLE   in varchar2,          -- Мнемокод статьи затрат
  nEXP_TYPE       in number,            -- Тип затрат
  --nSIGN_MAIN      in number,            -- Признак "Основная"
  nCOST_SUM       in number,            -- Сумма затрат
  nRN             out number            -- Регистрационный номер
 ) is

begin

 UDO_PKG_PRJSTG_PRSTRUCT.CLC_INSERT
(
  nCOMPANY        => nCOMPANY     ,            -- Организация
  nPRN            => nPRN         ,            -- Родитель
  sNUMB           => sNUMB        ,          -- Номер строки калькуляции
  sCOST_ARTICLE   => sCOST_ARTICLE,          -- Мнемокод статьи затрат
  nEXP_TYPE       => nEXP_TYPE    ,            -- Тип затрат
  nSIGN_MAIN      => 0,--nSIGN_MAIN   ,            -- Признак "Основная"
  nCOST_SUM       => nCOST_SUM    ,            -- Сумма затрат
  nRN             => nRN
);
end;
/

