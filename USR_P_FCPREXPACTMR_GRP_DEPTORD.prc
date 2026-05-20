create or replace procedure USR_P_FCPREXPACTMR_GRP_DEPTORD
(
  nCOMPANY                  in number,   -- Регистрационный номер организации
  nIDENT                    in number,   -- Идентификатор процесса  (Это отмеченные позиции спецификации портебности)
  PIN_PRN                   in number , -- RN родительской записи (потребности)
  dDATE                     in date,     -- Дата формируемых заказов подразделений
  nGRBY_ORDER               in number,   -- Группировать по заказу(ЛС) (0-все в одну, 1-делятся по заказам(ЛС))
  sSPL_SUBDIV               in varchar2, -- Подразделение-поставщик
  nGRBY_SUBDIV              in number,   -- Признак группировки по подразделение-поставщик
  nGRBY_STORE               in number,   -- Признак группировки по складу отгрузки
  nGRBY_SUBDIV_IN           in number,   -- Признак группировки по подразделению-получателю
  nGRBY_STORE_IN            in number,   -- Признак группировки по складу-получателю
  nGRBY_NOM_GROUP           in number,   -- Признак группировки по группе ТМЦ
  nGRBY_PERIOD              in number,   -- Признак группировки по расчетному периоду
  nGRBY_EXEC_DATE           in number,   -- Признак группировки по дате поставки
  nSHOP_REST                in number,   -- Признак "За вычетом остатков на цеховых складах" (0 - нет, 1 - да)
  nSUB_MTR                  in number,   -- Замена материала ( 0 - только используемая замена, 1 - с учетом наличия на складах )
  nSKIP_ACTION              in number,   -- Пропустить проверку права на действие ( 0 или null - нет, 1 - да )
  dDATE_FROM                in date,     -- Период поставки с даты
  dDATE_TO                  in date,     -- Период поставки до даты
  nREFORM_SIGN              in number,   -- Признак "Переформировать ранее созданные заказы"
  nSHOWERR                  out number,
  nIDENTERR                 out number
)
as
  nIDENTZ                   PKG_STD.TLNUMBER := GEN_IDENT;
  nRECTYPEZ                 PKG_STD.TLNUMBER := 0;
  sMSG_TEXT_YES             PKG_STD.TSTRING := 'Сформирован заказ подразделений.';
  sMSG_TEXT_NO              PKG_STD.TSTRING := 'Нет данных для формирования заказа подразделений.';
  nRNZ                      PKG_STD.TLNUMBER;
  nTRUE_REC                 PKG_STD.TLNUMBER;
  
  NDOC_IDENT selectlist.ident%type:= GEN_IDENT; -- Идент Потребности в спецификации которой запускаем процедуру
  
  v_nrn selectlist.rn%type;
  
begin

  /* 
  Формирование заказов подразделений 
  По отмеченным позициям спецификации потребности "Сгруппированная номенклатура"
  09-06-2025 Городецкий О.И.   
  */
  
---  P_exception(0, 'DOC_RN = '||PIN_PRN);
  /*Создаем Ident документа */
  
  p_selectlist_insert(nIDENT => NDOC_IDENT, nDOCUMENT => PIN_PRN, sUNITCODE => 'CostProductExpenseActsGrp', nRN => v_nrn);
  
  
  P_FCPREXPACT_MAKEDEPTORD(nCOMPANY        => nCOMPANY,
                           nIDENT          => NDOC_IDENT, --- Это идент документа
                           dDATE           => dDATE,
                           nGRBY_ORDER     => nGRBY_ORDER,
                           sSPL_SUBDIV     => sSPL_SUBDIV,
                           nGRBY_SUBDIV    => nGRBY_SUBDIV,
                           nGRBY_STORE     => nGRBY_STORE,
                           nGRBY_SUBDIV_IN => nGRBY_SUBDIV_IN,
                           nGRBY_STORE_IN  => nGRBY_STORE_IN,
                           nGRBY_NOM_GROUP => nGRBY_NOM_GROUP,
                           nGRBY_PERIOD    => nGRBY_PERIOD,
                           nGRBY_EXEC_DATE => nGRBY_EXEC_DATE,
                           nSHOP_REST      => nSHOP_REST,
                           nSUB_MTR        => nSUB_MTR,
                           nSKIP_ACTION    => nSKIP_ACTION,
                           dDATE_FROM      => dDATE_FROM,
                           dDATE_TO        => dDATE_TO,
                           nREFORM_SIGN    => nREFORM_SIGN,
                           nTRUE_REC       => nTRUE_REC,
                           NMTRS_IDENT => nIDENT  --- Это идент отмеченных позиций спецификации
                           );
   /*Очищаем Selectlist */                        
   p_selectlist_clear(nIDENT => NDOC_IDENT);
                           
                           
  /* Если на выходе в параметре nTRUE_REC получили null или 0 то выводим сообщение об ошибке */
  if (nTRUE_REC is null) or (nTRUE_REC = 0) then
    nIDENTERR := NIDENTZ;
    nSHOWERR  := 1;
    P_MSGJOURNAL_BASE_INSERT(nIDENTZ, nRECTYPEZ, sMSG_TEXT_NO, nRNZ);
  /* Иначе выводим сообщение об успешном формировании заказа */
  else
    P_MSGJOURNAL_BASE_INSERT(nIDENTZ, nRECTYPEZ, sMSG_TEXT_YES, nRNZ);
    nSHOWERR := 0;
  end if;

end;
/
