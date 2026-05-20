create or replace procedure UDO_P_MODUL_INVENT_FIN
(
    NCOMPANY         in number,         -- Организация
    NPROCESS         in number,         -- ID Процесса
    SCRN             in varchar2,       -- каталог
    sJUR_PERS        in varchar2,       -- Юр.лицо
    sDOCTYPE         in varchar2,       --  тип документа
    dDOC_DATE        in date,       -- лата
    sPREF            in varchar2,       -- префикс
    sPARTY           in varchar2,       -- Партия
    sSTORE_OPER      in varchar2        -- Складская операция
)
is
begin
  UDO_PKG_MODUL_INV_FIN.START_IN_MAKE(NCOMPANY    =>NCOMPANY,
                                     NPROCESS    =>NPROCESS,
                                     SCRN        =>SCRN,
                                     sJUR_PERS   =>sJUR_PERS,
                                     sDOCTYPE    =>sDOCTYPE,
                                     dDOC_DATE   =>dDOC_DATE,
                                     sPREF       =>sPREF,
                                     sPARTY      =>sPARTY,
                                     sSTORE_OPER =>sSTORE_OPER);

end UDO_P_MODUL_INVENT_FIN;
--grant execute on UDO_P_MODUL_INVENT_FIN to public;
/

