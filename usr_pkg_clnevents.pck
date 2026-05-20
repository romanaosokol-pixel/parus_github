create or replace package USR_PKG_CLNEVENTS is
  /*
  Package предназначен для работы с разделом "События".
  ClientEvents              CLNEVENTS         CE
  ClientEventsHistory       CLNEVNHIST        CEH
  ClientEventsNotes         CLNEVNOTES        CEN   "События (примечания)"
  ClientEventTypesNotes     CLNEVNTYPENOTES   CETN  "Примечания типов клиентских событий" (Примечание типового события)
  ClientEventsNotesHistory  CLNEVNOTESHIST    CENH  "События (история примечаний)"
  ClientEventNoteTypes      CLNEVNTNOTETYPES  CENT  "Типы заголовков примечаний"  (Типовое примечание)
  */
  --#########################################################################################################

  function CLNEVENTS_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN       in number
  ) 
  return CLNEVENTS%ROWTYPE;
  --#########################################################################################################

  procedure CLNEVENTS_GET_ADDITIONAL_DATA
  /*
  Заголовок. Считывание дополнительных данных
  */
  (
   rROW              in  clnevents%rowtype
  ,rCLNEVNHIST       out clnevnhist%rowtype   /* Текущая запись истории */
  ,rCLNEVNHIST_PREV  out clnevnhist%rowtype   /* Последняя запись истории предыдущего статуса */
  ,rEVROUTES         out evroutes%rowtype     /* Маршрут */
  ,rEVRTPOINTS       out evrtpoints%rowtype   /* Точка маршрута текущей записи истории */
  ,rEVRTPOINTS_PREV  out evrtpoints%rowtype   /* Точка маршрута последней записи истории предыдущего статуса */
  );
  --#########################################################################################################

  function CLNEVENTS_GET_CURRENT_CEH
  /*
  Заголовок. Текущая (последняя) запись истории события. Если задан Код действия, то ищется только запись с указанным кодом
  */
  (
   nRN            in number
  ,sACTION_CODE   in varchar2 default null /* Код действия */
  ) 
  return number;
  --#########################################################################################################

  procedure CLNEVENTS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BCHANGE_STATE
  /*
  Заголовок. Изменение статуса события. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_ACHANGE_STATE
  /*
  Заголовок. Изменение статуса события. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BRETURN
  /*
  Заголовок. Выполнение возврата в предыдущую точку маршрута. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_ARETURN
  /*
  Заголовок. Выполнение возврата в предыдущую точку маршрута. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BDO_SEND
  /*
  Заголовок. Переадресация события. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_ADO_SEND
  /*
  Заголовок. Переадресация события. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BCO_WORKING
  /*
  Заголовок. Совместное исполнение. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_ACO_WORKING
  /*
  Заголовок. Совместное исполнение. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BPERF_MARK_SET
  /*
  Заголовок. Установка отметки об исполнении. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_APERF_MARK_SET
  /*
  Заголовок. Установка отметки об исполнении. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BPERF_MARK_REMOVE
  /*
  Заголовок. Снятие отметки об исполнении. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_APERF_MARK_REMOVE
  /*
  Заголовок. Снятие отметки об исполнении. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BDO_ACTION
  /*
  Заголовок. Выполнение действия для события. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_ADO_ACTION
  /*
  Заголовок. Выполнение действия для события. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BUNDO_ACTION
  /*
  Заголовок. Выполнение отката действия для события. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_AUNDO_ACTION
  /*
  Заголовок. Выполнение отката действия для события. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BLINKED_UNIT_ACTION
  /*
  Заголовок. Выполнение действия в связанном разделе. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_ALINKED_UNIT_ACTION
  /*
  Заголовок. Выполнение действия в связанном разделе. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BCLOSE
  /*
  Заголовок. Аннулирование события. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_ACLOSE
  /*
  Заголовок. Аннулирование события. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BOPEN
  /*
  Заголовок. Отмена аннулирования события. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_AOPEN
  /*
  Заголовок. Отмена аннулирования события. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVENTS_CHECK_ON_ERP
  /*
  Процедура проверки переходов между точками маршрута. 
  Инициируется до    перехода через указание в разделе "Маршруты события\ Точки перехода", вкладка "Условия перехода"
  Инициируется после перехода через указание номеров действий в свойстве точки перехода
  Обратите внимание, при запуске До и После будут разные rEVRTPOINTS и rEVRTPOINTSPREV
  */
  (
   nRN               in number
  ,sPARAM_LIST       in varchar2 /* список проверок через ";" */
  );
  --#########################################################################################################

  procedure CLNEVENTS_CHECK_ON_ERP
  /*
  Процедура проверки переходов между точками маршрута. 
  Инициируется до    перехода через указание в разделе "Маршруты события\ Точки перехода", вкладка "Условия перехода"
  Инициируется после перехода через указание номеров действий в свойстве точки перехода
  Обратите внимание, при запуске До и После будут разные rEVRTPOINTS и rEVRTPOINTSPREV
  */
  (
   rROW              in clnevents%rowtype
  ,rCLNEVNHIST       in clnevnhist%rowtype
  ,rCLNEVNHISTPREV   in clnevnhist%rowtype
  ,rEVROUTES         in evroutes%rowtype
  ,rEVRTPOINTS       in evrtpoints%rowtype
  ,rEVRTPOINTSPREV   in evrtpoints%rowtype
  ,sPARAM_LIST       in varchar2 /* список проверок через ";" */
  );
  --#########################################################################################################

  procedure CLNEVENTS_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW           in clnevents%rowtype
  ,sLINKED_ACTION in varchar2
  ,nRN            out number
  );
  --#########################################################################################################

  procedure CLNEVENTS_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in clnevents%rowtype
  ,sLINKED_ACTION   in varchar2
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure CLNEVENTS_PERF_MARK_SET
  (
   nCOMPANY     in number             /* Организация */
  ,nRN          in number             /* Регистрационный номер события */
  ,sPERF_MARK   in varchar2           /* Отметка об исполнении */
  ,nMODE        in number default 0   /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure CLNEVENTS_CLOSE
  (
   nCOMPANY         in number             /* Организация */
  ,nRN              in number             /* Регистрационный номер события */
  ,nREMOTE_ACCESS   in number default null      
  ,nMODE            in number default 0   /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  function CLNEVNHIST_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN       in number
  ) 
  return CLNEVNHIST%ROWTYPE;
  --#########################################################################################################

  function CLNEVNHIST_GET_PREV
  /*
  Спецификация. Поиск предыдущей записи истории относительно заданной. Если задан Код действия, то ищется только запись с указанным кодом
  */
  (
   nFLAGSMART           in number   default 0
  ,nINCLUD_CURRENT      in number   default 0     /* Включать текущую запись */
  ,nRN                  in number                 /* Текущая запись истории */
  ,sACTION_CODE         in varchar2 default null  /* Код действия */
  ,nOTHER_EVENT_STAT    in number   default 0     /* Статус отличный от статуса в текущей истории: 0-любой, 1-отличный */
  ) 
  return number;
  --#########################################################################################################

  function CLNEVNHIST_GET_PREV
  /*
  Спецификация. Поиск предыдущей записи истории относительно заданной. Если задан Код действия, то ищется только запись с указанным кодом
  */
  (
   nFLAGSMART           in number   default 0
  ,nINCLUD_CURRENT      in number   default 0     /* Включать текущую запись */
  ,rROW                 in clnevnhist%rowtype     /* Текущая запись истории */
  ,sACTION_CODE         in varchar2 default null  /* Код действия */
  ,nOTHER_EVENT_STAT    in number   default 0     /* Статус отличный от статуса в текущей истории: 0-нет, 1-да */
  ) 
  return number;
  --#########################################################################################################

  function CLNEVNHIST_GET_PREV_BY_CENT
  /*
  Спецификация. Поиск предыдущей записи истории относительно заданной. Если задан Код действия, то ищется только запись с указанным кодом
  */
  (
   nFLAGSMART           in number default 0
  ,nINCLUD_CURRENT      in number default 0       /* Включать текущую запись */
  ,rROW                 in clnevnhist%rowtype     /* Текущая запись истории */
  ,nCENT                in number default null    /* Типовое примечание */
  ) 
  return number;
  --#########################################################################################################

  procedure CLNEVNHIST_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNHIST_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNHIST_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNHIST_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNHIST_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNHIST_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW           in clnevnhist%rowtype
  ,nRN            out number
  );
  --#########################################################################################################

  function CLNEVNOTES_GET
  /*
  Примечание. Считывание
  */
  (
   nRN       in number
  ) 
  return CLNEVNOTES%ROWTYPE;
  --#########################################################################################################

  procedure CLNEVNOTES_BINSERT
  /*
  Примечание. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNOTES_AINSERT
  /*
  Примечание. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNOTES_BUPDATE
  /*
  Примечание. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNOTES_AUPDATE
  /*
  Примечание. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNOTES_BDELETE
  /*
  Примечание. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure CLNEVNOTES_CHECK_BASE
  /*
  Примечание. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################
  
  procedure CLNEVNOTES_INSERT
  /* Клиентское добавление примечания */
  (
   nCOMPANY     in number
  ,nPRN         in number
  ,sNOTE_HEADER in varchar2
  ,sNOTE        in varchar2
  ,nRN          out number
  ,nMODE        in number default 0   /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  function CLNEVNOTESHIST_GET
  /*
  История примечания. Считывание записи
  */
  (
   nRN      in number 
  ) 
  return clnevnoteshist%rowtype;
  --#########################################################################################################

end USR_PKG_CLNEVENTS;
/
create or replace package body USR_PKG_CLNEVENTS is

  --#########################################################################################################

  function CLNEVENTS_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN      in number 
  ) 
  return clnevents%rowtype
  is
    rRow clnevents%rowtype;
  begin
    begin
      select * into rRow from clnevents where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'CLNEVENTS');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVENTS')));
    end;
    return(rRow);
  end CLNEVENTS_GET;
  --#########################################################################################################

  procedure CLNEVENTS_GET_ADDITIONAL_DATA
  /*
  Заголовок. Считывание дополнительных данных
  */
  (
   rROW              in  clnevents%rowtype
  ,rCLNEVNHIST       out clnevnhist%rowtype   /* Текущая запись истории */
  ,rCLNEVNHIST_PREV  out clnevnhist%rowtype   /* Последняя запись истории предыдущего статуса */
  ,rEVROUTES         out evroutes%rowtype     /* Маршрут */
  ,rEVRTPOINTS       out evrtpoints%rowtype   /* Точка маршрута текущей записи истории */
  ,rEVRTPOINTS_PREV  out evrtpoints%rowtype   /* Точка маршрута последней записи истории предыдущего статуса */
  ) 
  is
    nRef             pkg_std.tref;            
  begin
    /* Текущая (последняя) история события */
    nRef        := clnevents_get_current_ceh(nrn => rROW.RN);
    rCLNEVNHIST := clnevnhist_get(nrn => nRef);
    /* Маршрут события */
    nRef        := usr_pkg_evroutes.evroutes_get_by_cet(nrn => rROW.EVENT_TYPE);
    rEVROUTES   := usr_pkg_evroutes.evroutes_get(nrn => nRef);
    /* Точка маршрута события */
    nRef        := usr_pkg_evroutes.evrtpoints_get_by_cets(nrn => rCLNEVNHIST.EVENT_STAT);
    rEVRTPOINTS := usr_pkg_evroutes.evrtpoints_get(nrn => nRef);
    /* Предыдущая история события со статусом отличным от статуса текущей истории */
    nRef        := clnevnhist_get_prev(nflagsmart        => 1
                                      ,ninclud_current   => 0
                                      ,rrow              => rCLNEVNHIST
                                      ,nother_event_stat => 1);
    /* если найдена, то считываем её запись и её точку маршрута */
    if nRef is not null then
      rCLNEVNHIST_PREV := clnevnhist_get(nrn => nRef);
      nRef             := usr_pkg_evroutes.evrtpoints_get_by_cets(nrn => rCLNEVNHIST_PREV.EVENT_STAT);
      rEVRTPOINTS_PREV := usr_pkg_evroutes.evrtpoints_get(nrn => nRef);
    end if;

  end CLNEVENTS_GET_ADDITIONAL_DATA;
  --#########################################################################################################

  function CLNEVENTS_GET_CURRENT_CEH
  /*
  Заголовок. Текущая (последняя) запись истории события. Если задан Код действия, то ищется только запись с указанным кодом
  */
  (
   nRN            in number
  ,sACTION_CODE   in varchar2 default null /* Код действия */
  ) 
  return number
  is
    nRef    number;  
  begin
    begin
/*      select s.rn
        into nRef
        from (select * from clnevnhist order by rn desc) s
       where  s.prn  = nRN
         and (s.action_code = sACTION_CODE or sACTION_CODE is null)
         and  rownum = 1;*/
      select max(s.rn)
        into nRef
        from clnevnhist s
       where  s.prn  = nRN
         and (s.action_code = sACTION_CODE or sACTION_CODE is null);
    exception
      when no_data_found then
        null;
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s. %s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVENTS')), sqlerrm);
    end;
    return(nRef);
  end CLNEVENTS_GET_CURRENT_CEH;
  --#########################################################################################################

  procedure CLNEVENTS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    clnevents_check_base(nrn => nRN, ncompany => nCOMPANY);

  end CLNEVENTS_AINSERT;
  --#########################################################################################################

  procedure CLNEVENTS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BUPDATE;
  --#########################################################################################################

  procedure CLNEVENTS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    clnevents_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end CLNEVENTS_AUPDATE;
  --#########################################################################################################

  procedure CLNEVENTS_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BDELETE;
  --#########################################################################################################

  procedure CLNEVENTS_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BMOVE_IN;
  --#########################################################################################################

  procedure CLNEVENTS_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    null;
  end CLNEVENTS_BMOVE_OUT;
  --#########################################################################################################

  procedure CLNEVENTS_BCHANGE_STATE
  /*
  Заголовок. Изменение статуса события. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BCHANGE_STATE;
  --#########################################################################################################

  procedure CLNEVENTS_ACHANGE_STATE
  /*
  Заголовок. Изменение статуса события. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              clnevents%rowtype;
    rClnevnHist       clnevnhist%rowtype;
    rClnevnHistPrev   clnevnhist%rowtype;
    rEvRoutes         evroutes%rowtype;
    rEvRtPoints       evrtpoints%rowtype;
    rEvRtPointsPrev   evrtpoints%rowtype;
    nEvRtPtPass       pkg_std.tref; 
    rEvrTptNot        evrtptnot%rowtype;
    
    sVarchar  pkg_std.tstring; 
    nNumber   pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow := clnevents_get(nrn => nRN);
    clnevents_get_additional_data(rrow             => rRow
                                 ,rclnevnhist      => rClnevnHist
                                 ,rclnevnhist_prev => rClnevnHistPrev
                                 ,revroutes        => rEvRoutes
                                 ,revrtpoints      => rEvRtPoints
                                 ,revrtpoints_prev => rEvRtPointsPrev);

    /* Точка перехода RN */
    nEvRtPtPass := usr_pkg_evroutes.evrtptpass_get_by_erp(nprn => rEvRtPointsPrev.rn, nnext_point => rEvRtPoints.rn, nflagsmart => 1);

    /* Список проверок на точке перехода */
    if nEvRtPtPass is not null then 
      sVarchar := usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 113678368, ndocument => nEvRtPtPass);
    end if;

    /* ПРОВЕРКИ */
    /* Если список проверок не пустой */
    if sVarchar is not null then
      /* проверки на точке перехода */
      clnevents_check_on_erp(rrow            => rRow
                            ,rclnevnhist     => rClnevnHist
                            ,rclnevnhistprev => rClnevnHistPrev
                            ,revroutes       => rEvRoutes
                            ,revrtpoints     => rEvRtPoints
                            ,revrtpointsprev => rEvRtPointsPrev
                            ,sparam_list     => sVarchar);
    end if;

    /* В точке маршрута есть запись в Исполнители в точке маршрута, к которой относится пользователь, у которой нет никаких прав. */
    nNumber := usr_pkg_evroutes.evrtpoints_get_no_rights( nflagsmart => 0, nrn => rEvRtPoints.rn, sauthid => utilizer );


    /* Рассылка уведомлений только при переходе между заданными точками маршрута.
     Концепция.
     Проблема в том, что уведомления рассылаются при переходе в точку маршрута без учёта того, из какой точки выполнен переход. А требуется это учитывать.
     Решение такое: 
     - Добавляем уведомление с Типом активации, который мы не будем использовать - "После истечения времени исполнения у исполнителя" (номер 6).
     - В переходе между точками в добавляем "Процедуру проверки условий перехода" ( "usr_pkg_clnevents.clnevents_check_on_erp" с параметром "7" ), 
     - Эта процедура в момент выполнения перехода ищет все возможные точки перехода из текущей точки, ищет в них уведомления № 6, если находит,
       то меняет им Тип активации на "После выполнения перехода в этот статус" (№ 3). Также сохраняет RN исправленных уведомлений в точке маршрута
     - Дальше процедура перехода делает рассылку
     - В неименованном блоке после выполнения (который ниже), выполняется исправление Типа активации на № 6 в уведомлениях точки перехода по сохранённому списку RN */

    /* отключение регистрации */
    if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

    /* По списку RN уведомлений в следующих статусах с типом активации 6 */
    for c in (select erpn.*
                from table(cast(usr_pkg_pub_const.aEvrTptNot as udo_tp_numtable)) t
                    ,evrtptnot  erpn
               where erpn.rn = t.column_value ) 
    loop
      /* Исправляем тип активации на "После истечения времени исполнения у исполнителя" в этот статус (6) */
      rEvrTptNot := c;
      rEvrTptNot.act_type := 6;
      usr_pkg_evroutes.evrtptnot_update(rrow => rEvrTptNot);
    end loop;

    /* включение регистрации */
    if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;


    /* Очистка констант */
    usr_pkg_pub_const.aEvrTptNot.delete;

  end CLNEVENTS_ACHANGE_STATE;
  --#########################################################################################################

  procedure CLNEVENTS_BRETURN
  /*
  Заголовок. Выполнение возврата в предыдущую точку маршрута. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BRETURN;
  --#########################################################################################################

  procedure CLNEVENTS_ARETURN
  /*
  Заголовок. Выполнение возврата в предыдущую точку маршрута. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_ARETURN;
  --#########################################################################################################

  procedure CLNEVENTS_BDO_SEND
  /*
  Заголовок. Переадресация события. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BDO_SEND;
  --#########################################################################################################

  procedure CLNEVENTS_ADO_SEND
  /*
  Заголовок. Переадресация события. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_ADO_SEND;
  --#########################################################################################################

  procedure CLNEVENTS_BCO_WORKING
  /*
  Заголовок. Совместное исполнение. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BCO_WORKING;
  --#########################################################################################################

  procedure CLNEVENTS_ACO_WORKING
  /*
  Заголовок. Совместное исполнение. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_ACO_WORKING;
  --#########################################################################################################

  procedure CLNEVENTS_BPERF_MARK_SET
  /*
  Заголовок. Установка отметки об исполнении. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BPERF_MARK_SET;
  --#########################################################################################################

  procedure CLNEVENTS_APERF_MARK_SET
  /*
  Заголовок. Установка отметки об исполнении. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_APERF_MARK_SET;
  --#########################################################################################################

  procedure CLNEVENTS_BPERF_MARK_REMOVE
  /*
  Заголовок. Снятие отметки об исполнении. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BPERF_MARK_REMOVE;
  --#########################################################################################################

  procedure CLNEVENTS_APERF_MARK_REMOVE
  /*
  Заголовок. Снятие отметки об исполнении. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_APERF_MARK_REMOVE;
  --#########################################################################################################

  procedure CLNEVENTS_BDO_ACTION
  /*
  Заголовок. Выполнение действия для события. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BDO_ACTION;
  --#########################################################################################################

  procedure CLNEVENTS_ADO_ACTION
  /*
  Заголовок. Выполнение действия для события. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_ADO_ACTION;
  --#########################################################################################################

  procedure CLNEVENTS_BUNDO_ACTION
  /*
  Заголовок. Выполнение отката действия для события. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BUNDO_ACTION;
  --#########################################################################################################

  procedure CLNEVENTS_AUNDO_ACTION
  /*
  Заголовок. Выполнение отката действия для события. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_AUNDO_ACTION;
  --#########################################################################################################

  procedure CLNEVENTS_BLINKED_UNIT_ACTION
  /*
  Заголовок. Выполнение действия в связанном разделе. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BLINKED_UNIT_ACTION;
  --#########################################################################################################

  procedure CLNEVENTS_ALINKED_UNIT_ACTION
  /*
  Заголовок. Выполнение действия в связанном разделе. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_ALINKED_UNIT_ACTION;
  --#########################################################################################################

  procedure CLNEVENTS_BCLOSE
  /*
  Заголовок. Аннулирование события. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BCLOSE;
  --#########################################################################################################

  procedure CLNEVENTS_ACLOSE
  /*
  Заголовок. Аннулирование события. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_ACLOSE;
  --#########################################################################################################

  procedure CLNEVENTS_BOPEN
  /*
  Заголовок. Отмена аннулирования события. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_BOPEN;
  --#########################################################################################################

  procedure CLNEVENTS_AOPEN
  /*
  Заголовок. Отмена аннулирования события. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_AOPEN;
  --#########################################################################################################

  procedure CLNEVENTS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVENTS_CHECK_BASE;
  --#########################################################################################################

  procedure CLNEVENTS_CHECK_ON_ERP
  /*
  Процедура проверки переходов между точками маршрута. 
  Инициируется до    перехода через указание в разделе "Маршруты события\ Точки перехода", вкладка "Условия перехода"
  Инициируется после перехода через указание номеров действий в свойстве точки перехода
  Обратите внимание, при запуске До и После будут разные rEVRTPOINTS и rEVRTPOINTSPREV
  */
  (
   nRN               in number
  ,sPARAM_LIST       in varchar2 /* список проверок через ";" */
  ) 
  is
    rRow              clnevents%rowtype;
    rClnevnHist       clnevnhist%rowtype;
    rClnevnHistPrev   clnevnhist%rowtype;
    rEvRoutes         evroutes%rowtype;
    rEvRtPoints       evrtpoints%rowtype;
    rEvRtPointsPrev   evrtpoints%rowtype;
    nEvRtPtPass       pkg_std.tref; 
  begin
    /* Считывание */
    rRow := clnevents_get(nrn => nRN);
    clnevents_get_additional_data(rrow             => rRow
                                 ,rclnevnhist      => rClnevnHist
                                 ,rclnevnhist_prev => rClnevnHistPrev
                                 ,revroutes        => rEvRoutes
                                 ,revrtpoints      => rEvRtPoints
                                 ,revrtpoints_prev => rEvRtPointsPrev);
    /* проверки на точке перехода */
    clnevents_check_on_erp(rrow            => rRow
                          ,rclnevnhist     => rClnevnHist
                          ,rclnevnhistprev => rClnevnHistPrev
                          ,revroutes       => rEvRoutes
                          ,revrtpoints     => rEvRtPoints
                          ,revrtpointsprev => rEvRtPointsPrev
                          ,sparam_list     => sPARAM_LIST);
  end;
  --#########################################################################################################

  procedure CLNEVENTS_CHECK_ON_ERP
  /*
  Процедура проверки переходов между точками маршрута. 
  Инициируется до    перехода через указание в разделе "Маршруты события\ Точки перехода", вкладка "Условия перехода"
  Инициируется после перехода через указание номеров действий в свойстве точки перехода
  Обратите внимание, при запуске До и После будут разные rEVRTPOINTS и rEVRTPOINTSPREV
  */
  (
   rROW              in clnevents%rowtype
  ,rCLNEVNHIST       in clnevnhist%rowtype
  ,rCLNEVNHISTPREV   in clnevnhist%rowtype
  ,rEVROUTES         in evroutes%rowtype
  ,rEVRTPOINTS       in evrtpoints%rowtype
  ,rEVRTPOINTSPREV   in evrtpoints%rowtype
  ,sPARAM_LIST       in varchar2 /* список проверок через ";" */
  ) 
  is
    rDocument         usr_pkg_pub_const.tdoc_base_values_rec;
    nContracts        pkg_std.tref; 
    rContracts        contracts%rowtype;
    nCntrSaleType     pkg_std.tnumber; 
    nSummPrev         pkg_std.tsumm;
    nCEHPrev          pkg_std.tref; 
    rCEHPrev          clnevnhist%rowtype;
    nEvRtPointsNext   pkg_std.tref; 
    rEvRtPointsNext   evrtpoints%rowtype;
    rEvrTptNot        evrtptnot%rowtype;
    
    nNumber   pkg_std.tnumber; 
    sVarchar  pkg_std.tstring; 
  begin
    /* Документ статусной модели */
    rDocument := usr_pkg_document.get_base_values(nflagsmart => 1
                                                 ,nrn        => rRow.linked_rn
                                                 ,ncompany   => rRow.company
                                                 ,sunitcode  => rRow.linked_unit);
    /* Если документ не найден, выходим */
    if rDocument.nrn is null then 
      return;
    end if;
    
    /* Договор */
    find_contracts_faceacc(nflag_smart  => 1
                          ,ncompany     => rRow.company
                          ,nfaceacc     => rDocument.nfaceacc
                          ,sfaceacc     => null
                          ,ncontract    => null
                          ,ncontractout => nContracts
                          ,sdoc_type    => sVarchar
                          ,sdoc_pref    => sVarchar
                          ,sdoc_numb    => sVarchar
                          ,ddoc_date    => sVarchar
                          ,nstage       => nNumber
                          ,sstagenumb   => sVarchar
                          ,sfaceaccout  => sVarchar);
    /* Если договор найден */
    if nContracts is not null then
      /* Считывание записи договора */
      rContracts := usr_pkg_contracts.contracts_get(nrn => nContracts);
      /* Определение типа продажи договора */
      nCntrSaleType := usr_pkg_contracts.contracts_get_sale_type(nrn => rContracts.rn, ncompany => rContracts.company, nflagsmart => 1);
    end if;

    /* ПРОВЕРКИ */

    /* 1. Тип продажи должен быть Коммерческий */
    /*if strin(1, sPARAM_LIST) = 1 then 
      if nCntrSaleType != 2 then 
        p_exception(0, 'Тип продажи договора <%s>. %s'
                   ,usr_pkg_contracts.contracts_get_sale_type_name(ntype => nCntrSaleType)
                   ,cr||f_docdescrs_get_description(sunitcode => 'Contracts', ndocument => rContracts.rn)); 
      end if;   
    end if;*/   

    /* 2. Тип продажи должен быть Производство */
    /*if strin(2, sPARAM_LIST) = 1 then 
      if nCntrSaleType != 0 then 
        p_exception(0, 'Тип продажи договора <%s>. %s'
                   ,usr_pkg_contracts.contracts_get_sale_type_name(ntype => nCntrSaleType)
                   ,cr||f_docdescrs_get_description(sunitcode => 'Contracts', ndocument => rContracts.rn)); 
      end if;   
    end if;   */

    /* 3. Проверка отработки распоряжения на отгрузку */
    /*if strin(3, sPARAM_LIST) = 1 then 
      if rsheepdirscust.status != 1 then
        p_exception(0, 'Документ не отработан. %s'
                   ,cr||f_docdescrs_get_description(sunitcode => rROW.linked_unit, ndocument => rROW.LINKED_RN)); 
      end if;
    end if;   */

    /* 1. Документ имеет статус "Не утвержден" */
    if strin(1, sPARAM_LIST) = 1 then 
      if rDocument.nstatus = 0 then
        p_exception(0, 'Документ имеет статус "Не утвержден / Новый". %s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => rRow.linked_unit, ndocument => rDocument.nrn) ); 
      end if;
    end if;   

    /* 2. Документ имеет присоединённые документы */
    if strin(2, sPARAM_LIST) = 1 then 
      sVarchar := udo_f_filelinks_have_docs(rDocument.nrn);
      
      if cmp_vc2(upper(sVarchar), 'ДА') != 1 then
        p_exception(0, 'Отсутствует присоединенный документ. %s'
                   ,cr||cr||f_docdescrs_get_description(sunitcode => rRow.linked_unit, ndocument => rDocument.nrn)); 
      end if;
    end if;   

    /* 3. Добавить примечание с суммой документа */
    if strin(3, sPARAM_LIST) = 1 then 

      /* Если сумма документа НЕ задана */
      if rDocument.nsummtax is null then
        /* выходим */
        return;
      end if;   

      /* Предыдущая история события с примечанием "ВхСчет_ИзмСумм" */
      nCEHPrev := clnevnhist_get_prev_by_cent(nflagsmart      => 1
                                             ,ninclud_current => 1
                                             ,rrow            => rClnevnHist
                                             ,ncent           => 11844915);
      if nCEHPrev is not null then 
        rCEHPrev := usr_pkg_clnevents.clnevnhist_get(nrn => nCEHPrev);
      end if;

      /* Если найдена предыдущая история события с примечанием "ВхСчет_ИзмСумм" */
      if nCEHPrev is not null then
        /* Считываем из неё значение свойства "Сумма" */
        nSummPrev := usr_pkg_docs_props_vals.get_val_num(ndoc_prop => 148554177, ndocument => rCEHPrev.note);
      end if;

      /* Текст примечания */
      sVarchar := 'Сумма документа: '||usr_f_n2ss(rDocument.nsummtax);
      /* Если найдена предыдущая сумма, то добавляем её в текст примечания */
      if nSummPrev is not null and cmp_num(rDocument.nsummtax, nSummPrev) != 1 then
        sVarchar := sVarchar||'. Предыдущая сумма: '||usr_f_n2ss(nSummPrev);
        sVarchar := sVarchar||'. Разница: '||usr_f_n2ss(rDocument.nsummtax - nSummPrev);
      end if;

      /* Добавление примечания к событию */
      clnevnotes_insert(ncompany     => rRow.company
                       ,nprn         => rRow.rn
                       ,snote_header => 'ВхСчет_ИзмСумм'
                       ,snote        => sVarchar
                       ,nrn          => nNumber);
      /* Сохранение в его свойство новой суммы */
      pkg_docs_props_vals.modify(nproperty   => 148554177
                                ,sunitcode   => 'ClientEventsNotes'
                                ,ndocument   => nNumber
                                ,sstr_value  => null
                                ,nnum_value  => rDocument.nsummtax
                                ,ddate_value => null
                                ,nrn         => nNumber);
    end if;   

    /* 4. Перейти в следующий статус */
    if strin(4, sPARAM_LIST) = 1 then 
      /* следующий статус */
      nEvRtPointsNext := usr_pkg_evroutes.evrtpoints_get_next_point(nrn => rEvRtPoints.rn, nflagsmart => 0);
      rEvRtPointsNext := usr_pkg_evroutes.evrtpoints_get(nrn => nEvRtPointsNext);
      /* переход */
      p_clnevents_update_int(ncompany         => rRow.company
                            ,nrn              => rRow.rn
                            ,ncrn             => rRow.crn
                            ,nremote_access   => null
                            ,dchange_date     => rRow.change_date
                            ,nevent_type      => rRow.event_type
                            ,nevent_status    => rEvRtPointsNext.event_status
                            ,nclient_client   => rRow.client_client
                            ,nclient_person   => rRow.client_person
                            ,nsnd_client      => rRow.send_client
                            ,nsnd_division    => rRow.send_division
                            ,nsnd_post        => rRow.send_post
                            ,nsnd_perform     => rRow.send_perform
                            ,nsnd_person      => rRow.send_person
                            ,nsnd_staffgrp    => rRow.send_staffgrp
                            ,nsnd_user_group  => rRow.send_user_group
                            ,ssnd_user_authid => rRow.send_user_authid
                            ,sevent_descr     => rRow.event_descr);
    end if;   

    /* 5. Выполнить массовое списание с мест хранения РН в подразделения */
    if strin(5, sPARAM_LIST) = 1 then 
      /* Если документ не отработан */
      if rDocument.nstatus = 0 then
        usr_pkg_transinvdept.transinvdept_sprj_mins(ncompany => rROW.COMPANY, nrn => rROW.LINKED_RN, noutnote => nNumber);
      end if;
    end if;   

    /* 6. Выполнить массовую отменну списание с мест хранения РН в подразделения */
    if strin(6, sPARAM_LIST) = 1 then 
      /* Если документ не отработан */
      if rDocument.nstatus = 0 then
        udo_p_gtid_strplresjrnl_del(ncompany => rROW.COMPANY, nrn => rROW.LINKED_RN, nrestypep => 0, nrestyper => 1);
      end if;
    end if;   

    /* 7. Активировать (исправить) уведомления в следующих точках маршрута для их выполнения */
    if strin(7, sPARAM_LIST) = 1 then 

      /* Очистка константы списка RN уведомлений в статусе */
      usr_pkg_pub_const.aEvrTptNot.delete;

      /* Считывание списка RN уведомлений в следующих статусах, у которых тип активизации "После истечения времени исполнения у исполнителя" (6) */
      select erpn.rn bulk collect
        into usr_pkg_pub_const.aEvrTptNot
        from evrtptpass erpp
            ,evrtpoints erp
            ,evrtptnot  erpn
       where erpp.prn        = rEVRTPOINTS.RN
         and erpp.next_point = erp.rn
         and erp.rn          = erpn.prn
         and erpn.act_type   = 6;

      /* отключение регистрации */
      if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;

      /* По списку RN уведомлений в следующих статусах с типом активации 6 */
      for c in (select erpn.*
                  from table(cast(usr_pkg_pub_const.aEvrTptNot as udo_tp_numtable)) t
                      ,evrtptnot  erpn
                 where erpn.rn = t.column_value )
      loop
        /* Исправляем тип активации на После выполнения перехода в этот статус (3) */
        rEvrTptNot := c;
        rEvrTptNot.act_type := 3;
        usr_pkg_evroutes.evrtptnot_update(rrow => rEvrTptNot);
      end loop;

      /* включение регистрации */
      if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

    end if;   

    /* 99. Аннулировать */
    if strin(99, sPARAM_LIST) = 1 then 
      clnevents_close(ncompany => rRow.company, nrn => rRow.rn, nmode => 1);
    end if;   

  end CLNEVENTS_CHECK_ON_ERP;
  --#########################################################################################################

  procedure CLNEVENTS_BASE_INSERT
  /*
  Заголовок. Добавление базовое
  */
  (
   rROW           in clnevents%rowtype
  ,sLINKED_ACTION in varchar2
  ,nRN            out number
  ) 
  is
  begin
    p_clnevents_base_insert(ncompany          => rROW.COMPANY
                           ,ncrn              => rROW.CRN
                           ,sevent_pref       => rROW.EVENT_PREF
                           ,sevent_numb       => rROW.EVENT_NUMB
                           ,nevent_type       => rROW.EVENT_TYPE
                           ,nevent_stat       => rROW.EVENT_STAT
                           ,dplan_date        => rROW.PLAN_DATE
                           ,ninit_person      => rROW.INIT_PERSON
                           ,nclient_client    => rROW.CLIENT_CLIENT
                           ,nclient_person    => rROW.CLIENT_PERSON
                           ,nsend_client      => rROW.SEND_CLIENT
                           ,nsend_division    => rROW.SEND_DIVISION
                           ,nsend_post        => rROW.SEND_POST
                           ,nsend_perform     => rROW.SEND_PERFORM
                           ,nsend_person      => rROW.SEND_PERSON
                           ,nsend_staffgrp    => rROW.SEND_STAFFGRP
                           ,nsend_user_group  => rROW.SEND_USER_GROUP
                           ,ssend_user_authid => rROW.SEND_USER_AUTHID
                           ,sevent_descr      => rROW.EVENT_DESCR
                           ,sreason           => rROW.REASON
                           ,slinked_unit      => rROW.LINKED_UNIT
                           ,nlinked_rn        => rROW.LINKED_RN
                           ,slinked_action    => sLINKED_ACTION
                           ,nrn               => nRN);

  end CLNEVENTS_BASE_INSERT;
  --#########################################################################################################

  procedure CLNEVENTS_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in clnevents%rowtype
  ,sLINKED_ACTION   in varchar2
  ,nMODE            in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    nRN1    pkg_std.tnumber; 
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_clnevents_base_update(ncompany          => rROW.COMPANY
                             ,nrn               => rROW.RN
                             ,saction_code      => rROW.ACTION_CODE
                             ,nevent_stat       => rROW.EVENT_STAT
                             ,nclient_client    => rROW.CLIENT_CLIENT
                             ,nclient_person    => rROW.CLIENT_PERSON
                             ,nsend_client      => rROW.SEND_CLIENT
                             ,nsend_division    => rROW.SEND_DIVISION
                             ,nsend_post        => rROW.SEND_POST
                             ,nsend_perform     => rROW.SEND_PERFORM
                             ,nsend_person      => rROW.SEND_PERSON
                             ,nsend_staffgrp    => rROW.SEND_STAFFGRP
                             ,nsend_user_group  => rROW.SEND_USER_GROUP
                             ,ssend_user_authid => rROW.SEND_USER_AUTHID
                             ,sevent_descr      => rROW.EVENT_DESCR
                             ,slinked_action    => sLINKED_ACTION);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      /* исправление записи в таблице */
      update CLNEVENTS
         set EVENT_STAT       = rRow.EVENT_STAT,
             ACTION_CODE      = rRow.ACTION_CODE,
             CLIENT_CLIENT    = rRow.CLIENT_CLIENT,
             CLIENT_PERSON    = rRow.CLIENT_PERSON,
             SEND_CLIENT      = rRow.SEND_CLIENT,
             SEND_DIVISION    = rRow.SEND_DIVISION,
             SEND_POST        = rRow.SEND_POST,
             SEND_PERFORM     = rRow.SEND_PERFORM,
             SEND_PERSON      = rRow.SEND_PERSON,
             SEND_STAFFGRP    = rRow.SEND_STAFFGRP,
             SEND_USER_GROUP  = rRow.SEND_USER_GROUP,
             SEND_USER_AUTHID = rRow.SEND_USER_AUTHID,
             EVENT_DESCR      = rRow.EVENT_DESCR
            ,INIT_PERSON      = rRow.init_person
            ,INIT_AUTHID      = rRow.init_authid
       where RN      = rRow.RN
         and COMPANY = rRow.COMPANY;

      if ( SQL%NOTFOUND ) then
        P_EXCEPTION( 0,'Запись события (RN: '||nvl(to_char(rRow.RN),'<null>')||') не найдена.' );
      end if;

      /* добавление записи в историю */
      P_CLNEVNHIST_BASE_INSERT
      (
        rRow.RN,
        rRow.ACTION_CODE,
        rRow.EVENT_STAT,
        null/*nPERF_MARK*/,
        null/*nUSER_PROC*/,
        null/*nACTION_UNDO*/,
        rRow.CLIENT_CLIENT,
        rRow.CLIENT_PERSON,
        rRow.SEND_CLIENT,
        rRow.SEND_DIVISION,
        rRow.SEND_POST,
        rRow.SEND_PERFORM,
        rRow.SEND_PERSON,
        rRow.SEND_STAFFGRP,
        rRow.SEND_USER_GROUP,
        rRow.SEND_USER_AUTHID,
        rRow.EVENT_DESCR,
        null/*nNOTE*/,
        null/*nACTION_REC*/,
        sLINKED_ACTION,
        null/*sREASON*/,
        nRN1
      );
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end CLNEVENTS_BASE_UPDATE;
  --#########################################################################################################

  procedure CLNEVENTS_PERF_MARK_SET
  (
   nCOMPANY     in number             /* Организация */
  ,nRN          in number             /* Регистрационный номер события */
  ,sPERF_MARK   in varchar2           /* Отметка об исполнении */
  ,nMODE        in number default 0   /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  )
  as
    rCLNEVENTS            CLNEVENTS%rowtype;
    rPOINT                EVRTPOINTS%rowtype;
    nROUTE                PKG_STD.tREF;
    nPERF_MARK            PKG_STD.tREF;
    nPERSON               PKG_STD.tREF;
    nCHECK_RESULT         integer;
    nTMP                  PKG_STD.tREF;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_clnevents_perf_mark_set(ncompany => nCOMPANY, nrn => nRN, sperf_mark => sPERF_MARK);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* считывание записи события */
      begin
        select *
          into rCLNEVENTS
          from CLNEVENTS
         where RN = nRN;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND( nRN,'ClientEvents' );
      end;

      /* фиксация начала выполнения действия */
      /*PKG_ENV.PROLOGUE( nCOMPANY,null,rCLNEVENTS.CRN,'ClientEvents','CLNEVENTS_PERF_MARK_SET','CLNEVENTS',nRN );*/

      /* определение маршрута, соответствующего событию */
      begin
        select RN
          into nROUTE
          from EVROUTES
         where EVENT_TYPE = rCLNEVENTS.EVENT_TYPE
           and COMPANY = nCOMPANY;
      exception
        when NO_DATA_FOUND then
          P_EXCEPTION( 0, 'Невозможно определить маршрут события. Возможно, маршрутная карта события была модифицирована. '||
                          'Обратитесь к Администратору системы.' );
      end;

      /* определение точки маршрута, соответствующей статусу события */
      begin
        select *
          into rPOINT
          from EVRTPOINTS
         where PRN = nROUTE
           and EVENT_STATUS = rCLNEVENTS.EVENT_STAT
           and COMPANY = nCOMPANY;
      exception
        when NO_DATA_FOUND then
          P_EXCEPTION( 0, 'Точка маршрута, соответствующая статусу события, не определена. '||
                          'Обратитесь к Администратору системы.' );
      end;

      /* если точка является точкой совместного исполнения */
      if rPOINT.TOGETHER_SIGN = 1 then

        /* проверка наличия отражения совместного исполнения в истории события */
        select count(*)
          into nTMP
          from DUAL
         where exists ( select null
                          from CLNEVNHIST
                         where PRN = nRN
                           and ACTION_CODE = 'CLNEVENTS_CO-WORKING'
                           and EVENT_STAT  = rCLNEVENTS.EVENT_STAT
                           and CHANGE_DATE = rCLNEVENTS.COWORKING_DATE );
        if nTMP = 0 then
          P_EXCEPTION( 0, 'У события отсутствуют записи в истории, отражающие совместное исполнение в статусе. '||
                          'Возможно, маршрутная карта события была модифицирована. Обратитесь к Администратору системы.' );
        end if;

        /* поиск типа отметки об исполнении */
        FIND_CLNEVNPFMRK_CODE( 0, 0, nCOMPANY, sPERF_MARK, nPERF_MARK );

        /* установка отметки об исполнении */
        PKG_CLNEVENTS_COWRKING.PERF_MARK_SET
        (
          nCOMPANY,
          rCLNEVENTS,
          rPOINT.RN,
          nPERF_MARK
        );

        /* проверка возможности и выполнение перехода/возврата по условиям совместного исполнения */
        PKG_CLNEVENTS_COWRKING.CHECK_CONDS_PERF_MARK
        (
          nCOMPANY,
          nRN,
          rPOINT.RN,
          nPERF_MARK,
          nCHECK_RESULT
        );

      else
        P_EXCEPTION(0, 'Точка маршрута, соответствующая статусу события, не является точкой совместного исполнения.');
      end if;

      /* фиксация окончания выполнения действия */
      /*PKG_ENV.EPILOGUE( nCOMPANY,null,rCLNEVENTS.CRN,'ClientEvents','CLNEVENTS_PERF_MARK_SET','CLNEVENTS',nRN );*/

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end CLNEVENTS_PERF_MARK_SET;
  --#########################################################################################################

  procedure CLNEVENTS_CLOSE
  (
   nCOMPANY         in number             /* Организация */
  ,nRN              in number             /* Регистрационный номер события */
  ,nREMOTE_ACCESS   in number default null          
  ,nMODE            in number default 0   /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  )
  as
    rCLNEVENTS            CLNEVENTS%rowtype;
    nROUTE                PKG_STD.tREF;
    rPOINT                EVRTPOINTS%rowtype;
    nTMP                  PKG_STD.tREF;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
        p_clnevents_close(ncompany => nCOMPANY, nrn => nRN, nremote_access => nREMOTE_ACCESS);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* считывание записи */
      begin
        select *
          into rCLNEVENTS
          from CLNEVENTS
         where RN = nRN;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND( nRN,'ClientEvents' );
      end;

      /* фиксация начала выполнения действия */
      /*PKG_ENV.PROLOGUE( nCOMPANY,null,rCLNEVENTS.CRN,'ClientEvents','CLNEVENTS_CLOSE','CLNEVENTS',nRN );*/

      /* событие может быть аннулировано только один раз */
      if rCLNEVENTS.CLOSED <> 0 then
         P_EXCEPTION( 0,'Cобытие уже аннулировано.' );
      end if;

      -- Определим маршрут, соответствующий событию.
      begin
        select RN
          into nROUTE
          from EVROUTES
         where EVENT_TYPE = rCLNEVENTS.EVENT_TYPE
           and COMPANY = nCOMPANY;
      exception
        when NO_DATA_FOUND then
          nROUTE := null;
      end;

      if nROUTE is not null then
        -- 5 - Проверка полномочий на выполнение аннулирования в точке маршрута;
        /*P_EVRTPTEXEC_CHECK_RIGHTS( nCOMPANY,nRN,nREMOTE_ACCESS,5 );*/

        /* определение точки маршрута, соответствующей статусу события */
        begin
          select *
            into rPOINT
            from EVRTPOINTS
           where PRN = nROUTE
             and EVENT_STATUS = rCLNEVENTS.EVENT_STAT
             and COMPANY = nCOMPANY;
        exception
          when NO_DATA_FOUND then
            P_EXCEPTION( 0,'Точка маршрута, соответствующая статусу события, не определена. '||
                           'Обратитесь к Администратору системы.' );
          when OTHERS then
            raise;
        end;
      else
        rPOINT.TOGETHER_SIGN := 0;
      end if;

      update CLNEVENTS
         set CLOSED = 1
       where RN = nRN;

      /* добавить запись в историю события */
      P_CLNEVNHIST_BASE_INSERT
      (
        nRN,
        'CLNEVENTS_CLOSE',
        rCLNEVENTS.EVENT_STAT,
        null/*nPERF_MARK*/,
        null/*nUSER_PROC*/,
        null/*nACTION_UNDO*/,
        rCLNEVENTS.CLIENT_CLIENT,
        rCLNEVENTS.CLIENT_PERSON,
        rCLNEVENTS.SEND_CLIENT,
        rCLNEVENTS.SEND_DIVISION,
        rCLNEVENTS.SEND_POST,
        rCLNEVENTS.SEND_PERFORM,
        rCLNEVENTS.SEND_PERSON,
        rCLNEVENTS.SEND_STAFFGRP,
        rCLNEVENTS.SEND_USER_GROUP,
        rCLNEVENTS.SEND_USER_AUTHID,
        null/*sEVENT_DESCR*/,
        null/*nNOTE*/,
        null/*nACTION_REC*/,
        null/*sLINKED_ACTION*/,
        null/*sREASON*/,
        nTMP
      );

      /* фиксация окончания выполнения действия */
      /*PKG_ENV.EPILOGUE( nCOMPANY,null,rCLNEVENTS.CRN,'ClientEvents','CLNEVENTS_CLOSE','CLNEVENTS',nRN );*/

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end CLNEVENTS_CLOSE;
  --#########################################################################################################

  function CLNEVNHIST_GET
  /*
  Спецификация. Считывание записи
  */
  (
   nRN      in number 
  ) 
  return clnevnhist%rowtype
  is
    rRow clnevnhist%rowtype;
  begin
    begin
      select * into rRow from clnevnhist where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'CLNEVNHIST');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVNHIST')));
    end;
    return(rRow);
  end CLNEVNHIST_GET;
  --#########################################################################################################

  function CLNEVNHIST_GET_PREV
  /*
  Спецификация. Поиск предыдущей записи истории относительно заданной. Если задан Код действия, то ищется только запись с указанным кодом
  */
  (
   nFLAGSMART           in number   default 0
  ,nINCLUD_CURRENT      in number   default 0     /* Включать текущую запись */
  ,nRN                  in number                 /* Текущая запись истории */
  ,sACTION_CODE         in varchar2 default null  /* Код действия */
  ,nOTHER_EVENT_STAT    in number   default 0     /* Статус отличный от статуса в текущей истории: 0-любой, 1-отличный */
  ) 
  return number
  is
    rRow    clnevnhist%rowtype;
    nRef    pkg_std.tref; 
  begin
    rRow := clnevnhist_get(nrn => nRN);
    nRef := clnevnhist_get_prev(nflagsmart        => nFLAGSMART
                               ,ninclud_current   => nINCLUD_CURRENT
                               ,rrow              => rRow
                               ,saction_code      => sACTION_CODE
                               ,nother_event_stat => nOTHER_EVENT_STAT);
    return(nRef);
  end CLNEVNHIST_GET_PREV;
  --#########################################################################################################

  function CLNEVNHIST_GET_PREV
  /*
  Спецификация. Поиск предыдущей записи истории относительно заданной. Если задан Код действия, то ищется только запись с указанным кодом
  */
  (
   nFLAGSMART           in number   default 0
  ,nINCLUD_CURRENT      in number   default 0     /* Включать текущую запись */
  ,rROW                 in clnevnhist%rowtype     /* Текущая запись истории */
  ,sACTION_CODE         in varchar2 default null  /* Код действия */
  ,nOTHER_EVENT_STAT    in number   default 0     /* Статус отличный от статуса в текущей истории: 0-нет, 1-да */
  ) 
  return number
  is
    nRef  number;
  begin
    begin
      select a.rn
        into nRef
        from (
              select t.rn
                from clnevnhist t
               where   t.prn          = rROW.PRN
                 and (  (t.rn         < rROW.RN and nINCLUD_CURRENT = 0)
                     or (t.rn        <= rROW.RN and nINCLUD_CURRENT = 1) )
                 and ( t.action_code  = sACTION_CODE or sACTION_CODE is null )
                 and ( t.event_stat  != rROW.EVENT_STAT or nvl(nOTHER_EVENT_STAT, 0) = 0 )
               order by t.rn desc
             ) a
       where rownum = 1;
    exception
      when no_data_found then
        if nFLAGSMART = 0 then 
          pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => rROW.RN, sunit_table => 'CLNEVNHIST');
        end if;
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,rROW.RN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => nFLAGSMART, stable_name => 'CLNEVNHIST')));
    end;
    return(nRef);
  end CLNEVNHIST_GET_PREV;
  --#########################################################################################################

  function CLNEVNHIST_GET_PREV_BY_CENT
  /*
  Спецификация. Поиск предыдущей записи истории относительно заданной. Если задан Код действия, то ищется только запись с указанным кодом
  */
  (
   nFLAGSMART           in number default 0
  ,nINCLUD_CURRENT      in number default 0       /* Включать текущую запись */
  ,rROW                 in clnevnhist%rowtype     /* Текущая запись истории */
  ,nCENT                in number default null    /* Типовое примечание */
  ) 
  return number
  is
    nRef  number;
  begin
    begin
      select b.rn
        into nRef
        from ( select t.rn 
                 from clnevnhist  t
                     ,( select cen.rn, cetn.note_type 
                          from clnevnotes       cen 
                              ,clnevntypenotes  cetn
                         where cetn.rn = cen.header ) a 
                where t.prn       = rROW.PRN
                  and ((t.rn      < rROW.RN and nINCLUD_CURRENT = 0) 
                      or (t.rn   <= rROW.RN and nINCLUD_CURRENT = 1))
                  and t.note      = a.rn 
                  and a.note_type = nCENT
               order by t.rn desc ) b
       where rownum = 1;
    exception
      when no_data_found then
        if nFLAGSMART = 0 then 
          pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => rROW.RN, sunit_table => 'CLNEVNHIST');
        end if;
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,rROW.RN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => nFLAGSMART, stable_name => 'CLNEVNHIST')));
    end;
    return(nRef);
  end CLNEVNHIST_GET_PREV_BY_CENT;
  --#########################################################################################################

  procedure CLNEVNHIST_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */    
    /* Проверка базовая */
    clnevnhist_check_base(nrn => nRN, ncompany => nCOMPANY);

  end CLNEVNHIST_AINSERT;
  --#########################################################################################################

  procedure CLNEVNHIST_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVNHIST_BUPDATE;
  --#########################################################################################################

  procedure CLNEVNHIST_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    clnevnhist_check_base(nrn => nRN, ncompany => nCOMPANY);

  end CLNEVNHIST_AUPDATE;
  --#########################################################################################################

  procedure CLNEVNHIST_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVNHIST_BDELETE;
  --#########################################################################################################

  procedure CLNEVNHIST_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVNHIST_CHECK_BASE;
  --#########################################################################################################

  procedure CLNEVNHIST_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW           in clnevnhist%rowtype
  ,nRN            out number
  ) 
  is
  begin
    p_clnevnhist_base_insert(nprn              => rROW.PRN
                            ,saction_code      => rROW.ACTION_CODE
                            ,nevent_stat       => rROW.EVENT_STAT
                            ,nperf_mark        => rROW.PERF_MARK
                            ,nuser_proc        => rROW.USER_PROC
                            ,naction_undo      => rROW.ACTION_UNDO
                            ,nclient_client    => rROW.CLIENT_CLIENT
                            ,nclient_person    => rROW.CLIENT_PERSON
                            ,nsend_client      => rROW.SEND_CLIENT
                            ,nsend_division    => rROW.SEND_DIVISION
                            ,nsend_post        => rROW.SEND_POST
                            ,nsend_perform     => rROW.SEND_PERFORM
                            ,nsend_person      => rROW.SEND_PERSON
                            ,nsend_staffgrp    => rROW.SEND_STAFFGRP
                            ,nsend_user_group  => rROW.SEND_USER_GROUP
                            ,ssend_user_authid => rROW.SEND_USER_AUTHID
                            ,sevent_descr      => rROW.EVENT_DESCR
                            ,nnote             => rROW.NOTE
                            ,naction_rec       => rROW.ACTION_REC
                            ,slinked_action    => rROW.LINKED_ACTION
                            ,sreason           => rROW.REASON
                            ,nrn               => nRN);
  end CLNEVNHIST_BASE_INSERT;
  --#########################################################################################################

  function CLNEVNOTES_GET
  /*
  Примечание. Считывание записи
  */
  (
   nRN      in number 
  ) 
  return clnevnotes%rowtype
  is
    rRow clnevnotes%rowtype;
  begin
    begin
      select * into rRow from clnevnotes where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'CLNEVNOTES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVNOTES')));
    end;
    return(rRow);
  end CLNEVNOTES_GET;
  --#########################################################################################################

  procedure CLNEVNOTES_BINSERT
  /*
  Примечание. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVNOTES_BINSERT;
  --#########################################################################################################

  procedure CLNEVNOTES_AINSERT
  /*
  Примечание. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    clnevnotes_check_base(nrn => nRN, ncompany => nCOMPANY);

  end CLNEVNOTES_AINSERT;
  --#########################################################################################################

  procedure CLNEVNOTES_BUPDATE
  /*
  Примечание. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVNOTES_BUPDATE;
  --#########################################################################################################

  procedure CLNEVNOTES_AUPDATE
  /*
  Примечание. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    clnevnotes_check_base(nrn => nRN, ncompany => nCOMPANY);

  end CLNEVNOTES_AUPDATE;
  --#########################################################################################################

  procedure CLNEVNOTES_BDELETE
  /*
  Примечание. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVNOTES_BDELETE;
  --#########################################################################################################

  procedure CLNEVNOTES_CHECK_BASE
  /*
  Примечание. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end CLNEVNOTES_CHECK_BASE;
  --#########################################################################################################
  
  procedure CLNEVNOTES_INSERT
  /* Клиентское добавление примечания */
  (
   nCOMPANY     in number
  ,nPRN         in number
  ,sNOTE_HEADER in varchar2
  ,sNOTE        in varchar2
  ,nRN          out number
  ,nMODE        in number default 0   /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  )
  as
    rCLNEVENTS      CLNEVENTS%rowtype;
    nNOTE_HEADER    PKG_STD.tREF;
    nHEADER         PKG_STD.tREF;
    nTMP            PKG_STD.tREF;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_clnevnotes_insert(ncompany     => nCOMPANY
                         ,nprn         => nPRN
                         ,snote_header => sNOTE_HEADER
                         ,snote        => sNOTE
                         ,nrn          => nRN);

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then

      /* считывание master-записи */
      begin
        select *
          into rCLNEVENTS
          from CLNEVENTS
         where RN = nPRN;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND( nPRN,'ClientEvents' );
      end;

      /* фиксация начала выполнения действия */
      /* PKG_ENV.PROLOGUE( nCOMPANY, null, rCLNEVENTS.CRN, 'ClientEventsNotes', 'CLNEVNOTES_INSERT', 'CLNEVNOTES' ); */

      if rCLNEVENTS.CLOSED = 1 then
        P_EXCEPTION( 0,'Невозможно добавить примечание к аннулированному событию.' );
      end if;

      FIND_CLNEVNTNOTETYPES_CODE( 0, nCOMPANY, sNOTE_HEADER, nNOTE_HEADER );

      begin
        select RN
          into nHEADER
          from CLNEVNTYPENOTES
         where PRN = rCLNEVENTS.EVENT_TYPE
           and NOTE_TYPE = nNOTE_HEADER;
      exception
        when NO_DATA_FOUND then
          P_EXCEPTION( 0,'Заголовок примечания "'||sNOTE_HEADER||'" для данного типа события не определен.' );
      end;

      /* базовое добавление */
      P_CLNEVNOTES_BASE_INSERT
      (
        nCOMPANY,
        nPRN,
        nHEADER,
        sNOTE,
        nRN
      );

      /* добавить запись в историю события */
      P_CLNEVNHIST_BASE_INSERT
      (
        nPRN,
        'CLNEVNOTES_INSERT',
        rCLNEVENTS.EVENT_STAT,
        null/*nPERF_MARK*/,
        null,
        null,
        rCLNEVENTS.CLIENT_CLIENT,
        rCLNEVENTS.CLIENT_PERSON,
        rCLNEVENTS.SEND_CLIENT,
        rCLNEVENTS.SEND_DIVISION,
        rCLNEVENTS.SEND_POST,
        rCLNEVENTS.SEND_PERFORM,
        rCLNEVENTS.SEND_PERSON,
        rCLNEVENTS.SEND_STAFFGRP,
        rCLNEVENTS.SEND_USER_GROUP,
        rCLNEVENTS.SEND_USER_AUTHID,
        null,
        nRN/*nNOTE*/,
        null,
        null,
        null,
        nTMP
      );

      /* фиксация окончания выполнения действия */
      /* PKG_ENV.EPILOGUE( nCOMPANY, null, rCLNEVENTS.CRN, 'ClientEventsNotes', 'CLNEVNOTES_INSERT', 'CLNEVNOTES', nRN ); */
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end CLNEVNOTES_INSERT;
  --#########################################################################################################

  function CLNEVNOTESHIST_GET
  /*
  История примечания. Считывание записи
  */
  (
   nRN      in number 
  ) 
  return clnevnoteshist%rowtype
  is
    rRow clnevnoteshist%rowtype;
  begin
    begin
      select * into rRow from clnevnoteshist where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'CLNEVNOTESHIST');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVNOTESHIST')));
    end;
    return(rRow);
  end CLNEVNOTESHIST_GET;
  --#########################################################################################################
end USR_PKG_CLNEVENTS;
/
