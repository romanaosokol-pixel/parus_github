create or replace procedure UDO_REP_FCROUTLST_CONDITION (
  nCOMPANY           in number,  -- Организация
  nIDENT             in number,  -- Отмеченные записи (Изделие, ТехПаспорт, ...?)
  sRazd              in varchar2,-- Раздел в котором запускается отчет
  sTheme             in varchar2,-- Тема 
  sIzd               in varchar2,-- Изделие ради которого запускается отчет
  sZakaz             in varchar2,-- Заказ
  sOper              in varchar2,-- Операция
  bTree              in integer  -- Смотреть всё дерево изделия
) is

begin

  UDO_PKG_RP_FCROUTLST_CONDITION.XLS_MAKE(NCOMPANY => nCOMPANY, NIDENT => nIDENT, sRazd => sRazd, 
                                          sTheme => sTheme, sIzd => sIzd, sZakaz=>sZakaz, sOper => sOper,
                                          bTree => bTree); 

end UDO_REP_FCROUTLST_CONDITION;
/

