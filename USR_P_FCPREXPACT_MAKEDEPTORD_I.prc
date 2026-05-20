create or replace procedure USR_P_FCPREXPACT_MAKEDEPTORD_I
(
  NRN                       in number,        -- Регистрационный номер  
  /* Группировать по */
  NGRBY_ORDER               out number,       -- Производственному заказу
  NGRBY_SUBDIV              out number,       -- Подразделению - поставщику
  NGRBY_STORE               out number,       -- Складу отгрузки
  NGRBY_GROUP               out number,       -- Группе ТМЦ
  NGRBY_PERIOD              out number,       -- Расчетному периоду
  NGRBY_DATE                out number,       -- Дате поставки
  NGRBY_SUBDIV_IN           out number,       -- Подразделению - получателю
  NGRBY_STORE_IN            out number,       -- Складу - получателю
  /* Группировать по, доступность */
  NGRBY_ORDER_ENAB          out number,       -- Доступность. Производственному заказу
  NGRBY_SUBDIV_ENAB         out number,       -- Доступность. Подразделению - поставщику
  NGRBY_STORE_ENAB          out number,       -- Доступность. Складу отгрузки
  NGRBY_GROUP_ENAB          out number,       -- Доступность. Группе ТМЦ
  NGRBY_PERIOD_ENAB         out number,       -- Доступность. Расчетному периоду
  NGRBY_DATE_ENAB           out number,       -- Доступность. Дате поставки
  NGRBY_SUBDIV_IN_ENAB      out number,       -- Доступность. Подразделению - получателю
  NGRBY_STORE_IN_ENAB       out number        -- Доступность. Складу - получателю
)
as
begin
  /* Считывание значений */
  begin
    select T.GRBY_ORDER,
           T.GRBY_SUBDIV,
           T.GRBY_STORE,
           T.GRBY_GROUP,
           T.GRBY_PERIOD,
           T.GRBY_DATE,
           T.GRBY_SUBDIV_IN,
           T.GRBY_STORE_IN
      into NGRBY_ORDER,
           NGRBY_SUBDIV,
           NGRBY_STORE,
           NGRBY_GROUP,
           NGRBY_PERIOD,
           NGRBY_DATE,
           NGRBY_SUBDIV_IN,
           NGRBY_STORE_IN
      from FCPREXPACTMR SP
       join  FCPREXPACT T on T.rn = sp.prn
     where SP.RN = NRN
       ;
  exception
    when NO_DATA_FOUND then
      NGRBY_ORDER     := null;
      NGRBY_SUBDIV    := null;
      NGRBY_STORE     := null;
      NGRBY_GROUP     := null;
      NGRBY_PERIOD    := null;
      NGRBY_DATE      := null;
      NGRBY_SUBDIV_IN := null;
      NGRBY_STORE_IN  := null;
  end;

  PKG_EXT.SET_VAL(NGRBY_ORDER_ENAB, NGRBY_ORDER is null);
  PKG_EXT.SET_VAL(NGRBY_SUBDIV_ENAB, NGRBY_SUBDIV is null);
  PKG_EXT.SET_VAL(NGRBY_STORE_ENAB, NGRBY_STORE is null);
  PKG_EXT.SET_VAL(NGRBY_GROUP_ENAB, NGRBY_GROUP is null);
  PKG_EXT.SET_VAL(NGRBY_PERIOD_ENAB, NGRBY_PERIOD is null);
  PKG_EXT.SET_VAL(NGRBY_DATE_ENAB, NGRBY_DATE is null);
  PKG_EXT.SET_VAL(NGRBY_SUBDIV_IN_ENAB, NGRBY_SUBDIV_IN is null);
  PKG_EXT.SET_VAL(NGRBY_STORE_IN_ENAB, NGRBY_STORE_IN is null);
end;
/
