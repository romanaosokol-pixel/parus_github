create or replace package UDO_PKG_UNITSTMOD
as
  /* процедура предварительной регистрации документа для активации статусной модели */
  procedure REG_FOR_ACTIVATION
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2,
    nDOCUMENT               in number
  );

  /* процедурREG_FOR_ACTIVATIONа предварительной регистрации документа для деактивации статусной модели */
  procedure REG_FOR_DEACTIVATION
  (
    sUNITCODE               in varchar2,
    nDOCUMENT               in number
  );

  /* процедура выполнения обработки документов в статусной модели */
  procedure EXEC_PROCESSING
  (
    nCOMPANY                in number,      -- Организация
    sUNITCODE               in varchar2,    -- Мнемокод раздела
    nDOCUMENT               in number,      -- Документ
    sACTION                 in varchar2,    -- Выполняемое действие
    sMODE                   in varchar2,    -- Режим выполнения 'BEFORE' - пролог, 'AFTER' - эпилог
    nSTANDARD               in number,      -- Тип действия
    nBUSPROC                in number       -- Идентификатор бизнес-процесса
  );

  /* процедура начала обработки действия раздела документа в статусной модели */
  procedure ACTION_PROLOGUE
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2,
    nDOCUMENT               in number,
    sACTION                 in varchar2
  );

  /* процедура окончания обработки действия раздела документа в статусной модели */
  procedure ACTION_EPILOGUE
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2,
    nDOCUMENT               in number,
    sACTION                 in varchar2
  );
end UDO_PKG_UNITSTMOD;
/

create or replace package body UDO_PKG_UNITSTMOD
as
  /* функция проверки, выступает ли маршрут в качестве статусной модели */
  function ROUTE_IS_STMOD
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2,
    nROUTE                  in number
  )
  return boolean
  is
    nCOUNT                  integer;
  begin
    select count(*)
      into nCOUNT
      from DUAL
     where exists ( select null
                      from UNITSTMOD
                     where COMPANY = nCOMPANY
                       and UNITCODE = sUNITCODE
                       and EVROUTES = nROUTE );

    return nCOUNT != 0;
  end ROUTE_IS_STMOD;

  /* функция поиска активной статусной модели */
  function FIND_UNITSTMOD
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2
  )
  return UNITSTMOD%rowtype
  is
    rUNITSTMOD              UNITSTMOD%rowtype;
  begin
    select *
      into rUNITSTMOD
      from UNITSTMOD
     where COMPANY = nCOMPANY
       and UNITCODE = sUNITCODE
       and SIGN_ACTIVE = 1
       and rownum = 1;

    return rUNITSTMOD;
  exception
    when NO_DATA_FOUND then
      return null;
  end;

  /* функция поиска связанного с документом события */
  function FIND_EVENT
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2,
    nDOCUMENT               in number
  )
  return number
  is
    nEVENT                  PKG_STD.tREF;
  begin
    select RN
      into nEVENT
      from CLNEVENTS
     where COMPANY = nCOMPANY
       and LINKED_UNIT = sUNITCODE
       and LINKED_RN = nDOCUMENT;

    return nEVENT;
  exception
    when NO_DATA_FOUND then
      return null;
  end FIND_EVENT;

  /* процедура создания события по статусной модели */
  procedure CREATE_EVENT
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2,
    nDOCUMENT               in number,
    rUNITSTMOD              in UNITSTMOD%rowtype,
    sACTION                 in varchar2,
    nCLNEVENTS              out number
  )
  is
    sUNITCODE_              PKG_STD.tSTRING := sUNITCODE;
    sACTION_                PKG_STD.tSTRING := sACTION;
    rCLNEVNTYPES            CLNEVNTYPES%rowtype;
    nEVENT_STAT             PKG_STD.tREF;
    nINIT_PERSON            PKG_STD.tREF;
    nCLIENT_CLIENT          PKG_STD.tREF;
    nSEND_CLIENT            PKG_STD.tREF;
    nSEND_DIVISION          PKG_STD.tREF;
    nSEND_POST              PKG_STD.tREF;
    nSEND_PERFORM           PKG_STD.tREF;
    nSEND_PERSON            PKG_STD.tREF;
    nSEND_STAFFGRP          PKG_STD.tREF;
    nSEND_USER_GROUP        PKG_STD.tREF;
    sSEND_USER_AUTHID       PKG_STD.tSTRING;
    sEVENT_DESCR            PKG_STD.tSTRING;

  begin
    /* если не задано действие */
    if sACTION is null then
      /* определение выполняемого действия и раздела, откуда оно выполняется */
      begin
        select UNITCODE,
               ACTIONCODE
          into sUNITCODE_,
               sACTION_
          from ( select L.UNITCODE,
                        LD.ACTIONCODE
                   from ENV_LOCK     L,
                        ENV_LOCK_DET LD
                  where L.AUTHID = UTILIZER
                    and L.COMPANY = nCOMPANY
                    and L.BUSPROC = PKG_ENV_BASE.GET_BUSPROC
                    and L.RN = LD.PRN
                    and LD.ACTIONCODE is not null
                  order by LD.LOCK_DATE desc )
         where rownum = 1;
      exception
        when NO_DATA_FOUND then
          sUNITCODE_ := null;
          sACTION_ := null;
      end;
    end if;

    /* если в статусной модели задан маршрут */
    if rUNITSTMOD.EVROUTES is not null then

      /* считывание записи типа события */
      begin
        select ET.*
          into rCLNEVNTYPES
          from EVROUTES     R,
               CLNEVNTYPES  ET
         where R.RN = rUNITSTMOD.EVROUTES
           and R.EVENT_TYPE = ET.RN;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND(rUNITSTMOD.EVROUTES, 'EventRoutes');
      end;

    /* если в статусной модели задана процедура подбора */
    elsif rUNITSTMOD.SEL_PROC is not null then

      /* вызов процедуры подбора */
      P_DUP_UNITSTMOD_EVENTTYPE
      (
        rUNITSTMOD.SEL_PROC,
        nCOMPANY,
        sUNITCODE,
        nDOCUMENT,
        rCLNEVNTYPES.RN
      );

      if rCLNEVNTYPES.RN is not null then
        /* считывание записи типа события */
        begin
          select *
            into rCLNEVNTYPES
            from CLNEVNTYPES
            where RN = rCLNEVNTYPES.RN;
        exception
          when NO_DATA_FOUND then
            PKG_MSG.RECORD_NOT_FOUND(rCLNEVNTYPES.RN, 'ClientEventTypes');
        end;
      end if;
    end if;

    /* если тип события определен */
    if rCLNEVNTYPES.RN is not null then

      if CMP_NUM(rCLNEVNTYPES.COMPANY, nCOMPANY) = 0 then
        if rUNITSTMOD.EVROUTES is not null then
          P_EXCEPTION(0, 'Недопустимая организация у типового события "%s" статусной модели "%s".',
                          rCLNEVNTYPES.EVNTYPE_CODE, GET_EVROUTES_CODE_ID(0,rUNITSTMOD.EVROUTES));
        else
          P_EXCEPTION(0, 'Недопустимая организация у типового события "%s".', rCLNEVNTYPES.EVNTYPE_CODE);
        end if;
      end if;

      if CMP_VC2(rCLNEVNTYPES.LINKED_UNIT, sUNITCODE) = 0 then
        if rUNITSTMOD.EVROUTES is not null then
          P_EXCEPTION(0, 'Недопустимый раздел у типового события "%s" статусной модели "%s".',
                         rCLNEVNTYPES.EVNTYPE_CODE, GET_EVROUTES_CODE_ID(0,rUNITSTMOD.EVROUTES));
        else
          P_EXCEPTION(0, 'Недопустимый раздел у типового события "%s".', rCLNEVNTYPES.EVNTYPE_CODE);
        end if;
      end if;

      if rCLNEVNTYPES.EVENT_PREF is null then
        if rUNITSTMOD.EVROUTES is not null then
          P_EXCEPTION(0, 'Не определен префикс номера события у типового события "%s" статусной модели "%s".',
                         rCLNEVNTYPES.EVNTYPE_CODE, GET_EVROUTES_CODE_ID(0,rUNITSTMOD.EVROUTES));
        else
          P_EXCEPTION(0, 'Не определен префикс номера события у типового события "%s".', rCLNEVNTYPES.EVNTYPE_CODE);
        end if;
      end if;

      /* cчитывание статуса события "по умолчанию" */
      nEVENT_STAT := GET_CLNEVNTYPSTS_BASE_DEFAULT(1, rCLNEVNTYPES.RN);
      if nEVENT_STAT is null then
        if rUNITSTMOD.EVROUTES is not null then
          P_EXCEPTION(0, 'Не определен статус события по умолчанию у типового события "%s" статусной модели "%s".',
                         rCLNEVNTYPES.EVNTYPE_CODE, GET_EVROUTES_CODE_ID(0,rUNITSTMOD.EVROUTES));
        else
          P_EXCEPTION(0, 'Не определен статус события по умолчанию у типового события "%s".', rCLNEVNTYPES.EVNTYPE_CODE);
        end if;
      end if;

      /* поиск сотрудника-инициатора (для случая использования инициатора в качестве предопределенного исполнителя) */
      begin
        select RN
          into nINIT_PERSON
          from CLNPERSONS
         where PERS_AUTHID = UTILIZER
           and COMPANY = nCOMPANY;
      exception
        when NO_DATA_FOUND then
          nINIT_PERSON := null;
      end;

      /* поиск клиента–организации (по соответствию контрагентов клиента и текущей организации) */
      begin
        select CC.RN
          into nCLIENT_CLIENT
          from COMPANIES   C,
               CLNCLIENTS  CC
         where C.RN = nCOMPANY
           and C.AGENT = CC.CLIENT_AGENT
           and C.RN = CC.COMPANY;
      exception
        when NO_DATA_FOUND then
          nCLIENT_CLIENT := null;
      end;
      if sACTION_ is not null then
        if sUNITCODE = sUNITCODE_ then
          sEVENT_DESCR := 'Создано автоматически по статусной модели раздела "' || GET_UNITLIST_NAME_CODE(0, sUNITCODE) ||
                          '" при выполнении действия "' || GET_UNITFUNC_NAME_CODE(0, sACTION_) || '".' || sEVENT_DESCR;
        else
          sEVENT_DESCR := 'Создано автоматически по статусной модели раздела "' || GET_UNITLIST_NAME_CODE(0, sUNITCODE) ||
                          '" при выполнении действия "' || GET_UNITFUNC_NAME_CODE(0, sACTION_) ||
                          '" в разделе "' || GET_UNITLIST_NAME_CODE(0, sUNITCODE_) || '".' || sEVENT_DESCR;
        end if;
      else
        sEVENT_DESCR := 'Создано автоматически по статусной модели раздела "' || GET_UNITLIST_NAME_CODE(0, sUNITCODE) ||
                        '".' || sEVENT_DESCR;
      end if;

      /* если выполняется действие из другого раздела */
      if (CMP_VC2(sUNITCODE, sUNITCODE_) = 0) then
        sACTION_ := null;
      end if;

      /* поиск исполнителя по умолчанию */
      FIND_EVRTPOINTS_DEF_EXECUTER
      (
        nCOMPANY,
        null, /*-- Событие -- Обновление от 03_2022 --*/
        nINIT_PERSON,
        UTILIZER/*nINIT_AUTHID*/,
        null/*nCLIENT_CLIENT**/,
        null/*nCLIENT_PERSON*/,
        rCLNEVNTYPES.RN/*nEVENT_TYPE*/,
        nEVENT_STAT,
        nSEND_CLIENT,
        nSEND_DIVISION,
        nSEND_POST,
        nSEND_PERFORM,
        nSEND_PERSON,
        nSEND_STAFFGRP,
        nSEND_USER_GROUP,
        sSEND_USER_AUTHID
      );

      /* внутреннее добавление события */
      P_CLNEVENTS_INSERT_INT
      (
        nCOMPANY,                                                   -- nCOMPANY
        rCLNEVNTYPES.REMOTE_CRN,                                    -- nCRN
        rCLNEVNTYPES.EVENT_PREF,                                    -- sEVENT_PREF
        GET_CLNEVENTS_NEXTNUMB(nCOMPANY, rCLNEVNTYPES.EVENT_PREF),  -- sEVENT_NUMB
        rCLNEVNTYPES.RN,                                            -- nEVENT_TYPE
        nEVENT_STAT,                                                -- nEVENT_STAT
        null,                                                       -- dPLAN_DATE
        nINIT_PERSON,                                               -- nINIT_PERSON
        null,                                                       -- nCLIENT_CLIENT
        null,                                                       -- nCLIENT_PERSON
        nSEND_CLIENT,                                               -- nSEND_CLIENT
        nSEND_DIVISION,                                             -- nSEND_DIVISION
        nSEND_POST,                                                 -- nSEND_POST
        nSEND_PERFORM,                                              -- nSEND_PERFORM
        nSEND_PERSON,                                               -- nSEND_PERSON
        nSEND_STAFFGRP,                                             -- nSEND_STAFFGRP
        nSEND_USER_GROUP,                                           -- nSEND_USER_GROUP
        sSEND_USER_AUTHID,                                          -- sSEND_USER_AUTHID
        sEVENT_DESCR,                                               -- sEVENT_DESCR
        null,                                                       -- sREASON
        sUNITCODE,                                                  -- sLINKED_UNIT
        nDOCUMENT,                                                  -- nLINKED_RN
        sACTION_,                                                   -- sLINKED_ACTION
        nCLNEVENTS                                                  -- nRN
      );

      /* рассылка уведомления о создании события */
      P_EVRTPTNOT_NOTIFY( nCOMPANY, nCLNEVENTS, 3 ); -- тип активизации (после после перехода в данную точку) - 3
    end if;
  end CREATE_EVENT;

  /* процедура создания события по статусной модели */
  procedure CREATE_EVENT
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2,
    nDOCUMENT               in number,
    nUNITSTMOD              in number,
    sACTION                 in varchar2,
    nCLNEVENTS              out number
  )
  is
    rUNITSTMOD              UNITSTMOD%rowtype;
  begin
    /* если нет связанного с документом события */
    if FIND_EVENT( nCOMPANY, sUNITCODE, nDOCUMENT ) is null then
      /* считывание записи статусной модели */
      begin
        select *
          into rUNITSTMOD
          from UNITSTMOD
         where RN = nUNITSTMOD;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND( nUNITSTMOD,'UnitsStatusModels' );
      end;

      CREATE_EVENT
      (
        nCOMPANY,
        sUNITCODE,
        nDOCUMENT,
        rUNITSTMOD,
        sACTION,
        nCLNEVENTS
      );
    end if;
  end CREATE_EVENT;

  /* процедура удаления события по статусной модели */
  procedure REMOVE_EVENT
  (
    nEVENT                  in number
  )
  is
  begin
    if nEVENT is not null then
      /* удаление события */
      P_CLNEVENTS_BASE_DELETE( nEVENT );
    end if;
  exception
    when OTHERS then
      null;
  end REMOVE_EVENT;

  /* процедура дополнения описания события описателем документа */
  procedure ADD_DOC_DESCRIBE
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2,
    nDOCUMENT               in number,
    nEVENT                  in number
  )
  is
    sDESCRIBE               PKG_STD.tSTRING;
  begin
    if nEVENT is not null then
      /* определение описания документа */
      if FUNCTION_EXISTS('F_DOCDESCRS_DESCRIBE') = 1 then
        execute immediate
          PKG_SQL_CALL.MAKE_STORED('F_DOCDESCRS_DESCRIBE')
          using out sDESCRIBE,
                 in nCOMPANY,
                 in sUNITCODE,
                 in nDOCUMENT,
                 in 1;  -- nRETURN_NULL

        /* исправление описания события */
        if sDESCRIBE is not null then
          update CLNEVENTS
             set EVENT_DESCR = sDESCRIBE || CR || CR || EVENT_DESCR
           where RN = nEVENT;
        end if;
      end if;
    end if;
  end ADD_DOC_DESCRIBE;

  /* процедура предварительной регистрации документа */
  procedure REG_DOCUMENT
  (
    sUNITCODE               in varchar2,
    nDOCUMENT               in number,
    nUNITSTMOD              in number,
    nEVENT                  in number,
    nOPERATION              in number
  )
  is
    nBUSPROC                PKG_STD.tREF;
  begin
    nBUSPROC := PKG_ENV_BASE.GET_BUSPROC;

    if nBUSPROC is not null then
      insert into UNITSTMOD_TEMP
      (
        BUSPROC,
        UNITCODE,
        DOCUMENT,
        UNITSTMOD,
        EVENT,
        OPERATION
      )
      values
      (
        nBUSPROC,
        sUNITCODE,
        nDOCUMENT,
        nUNITSTMOD,
        nEVENT,
        nOPERATION
      );
    end if;
  end REG_DOCUMENT;

  /* процедура предварительной регистрации документа для активации статусной модели */
  procedure REG_FOR_ACTIVATION
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2,
    nDOCUMENT               in number
  )
  is
  --  nCOMPANY                PKG_STD.tREF;
    rUNITSTMOD              UNITSTMOD%rowtype;
    nEVENT                  PKG_STD.tREF;
  begin
    /* инициализация */
 --   nCOMPANY := PKG_SESSION.GET_COMPANY;

    /* поиск активной статусной модели для раздела */
    rUNITSTMOD := FIND_UNITSTMOD(nCOMPANY, sUNITCODE);
--p_exception(0,'!! 222 - '||nCOMPANY||'-'||sUNITCODE);
    /* выход, если статусная модель не найдена */
    if rUNITSTMOD.RN is null then
      return;
    end if;

    /* если в статусной модели задан маршрут */
    if rUNITSTMOD.EVROUTES is not null then

      /* если нет связанного с документом события */
      if FIND_EVENT( nCOMPANY, sUNITCODE, nDOCUMENT ) is null then
        /* создание события по статусной модели */
        CREATE_EVENT
        (
          nCOMPANY,
          sUNITCODE,
          nDOCUMENT,
          rUNITSTMOD,
          null/*sACTION*/,
          nEVENT
        );
      end if;

    /* если в статусной модели задана процедура подбора */
    elsif rUNITSTMOD.SEL_PROC is not null then
      /* создание события будет производиться позднее при обработке зарегистрированных документов */
      nEVENT := null;
    end if;

    /* регистрация документа */
    REG_DOCUMENT
    (
      sUNITCODE,
      nDOCUMENT,
      rUNITSTMOD.RN,
      nEVENT,
      1/*nOPERATION*/
    );
  end REG_FOR_ACTIVATION;

  /* процедура предварительной регистрации документа для деактивации статусной модели */
  procedure REG_FOR_DEACTIVATION
  (
    sUNITCODE               in varchar2,
    nDOCUMENT               in number
  )
  is
    nCOMPANY                PKG_STD.tREF;
    nEXISTS                 PKG_STD.tNUMBER;
  begin
    /* инициализация */
    nCOMPANY := PKG_SESSION.GET_COMPANY;

    /* если удаляется запись статусной модели */
    if sUNITCODE = 'UnitsStatusModels' then
      /* выход, иначе будет мутация при выполнении следующего запроса */
      return;
    end if;

    /* проверка наличия статусной модели у раздела */
    select count(*)
      into nEXISTS
      from DUAL
     where exists ( select null
                      from UNITSTMOD
                     where COMPANY = nCOMPANY
                       and UNITCODE = sUNITCODE );

    if nEXISTS = 0 then
      /* выход, если статусная модель не найдена */
      return;
    end if;

    /* если регистрируется документ раздела "События" и разделов, ссылающихся на него по цепочкам "on delete cascade",
       у которых существует trigger "T_..._ADELETE" */
    if sUNITCODE in ('ClientEvents', 'ClientEventsNotes')  then

      /* регистрация документа */
      REG_DOCUMENT
      (
        sUNITCODE,
        nDOCUMENT,
        null/*nUNITSTMOD*/,
        null/*nEVENT*/,     -- поиск события будет производиться позднее при обработке зарегистрированных документов
        0/*nOPERATION*/
      );

    /* если регистрируется документ любого другого раздела */
    else

      /* поиск и удаление события по статусной модели */
      REMOVE_EVENT( FIND_EVENT(nCOMPANY, sUNITCODE, nDOCUMENT) );
    end if;
  end REG_FOR_DEACTIVATION;

  /* процедура обработки действия раздела документа в статусной модели */
  procedure ACTION_PROCESSING
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2,
    nDOCUMENT               in number,
    sACTION                 in varchar2,
    sMODE                   in varchar2,
    nSTANDARD               in number
  )
  is
    nCRN                    PKG_STD.tREF;
    rUNITSTMOD              UNITSTMOD%rowtype;
    sEVENT_DESCR            PKG_STD.tSTRING;
    nEVENT                  PKG_STD.tREF;
    nEVENT_TYPE             PKG_STD.tREF;
    nEVENT_STAT             PKG_STD.tREF;
    nROUTE                  PKG_STD.tREF;
    nPOINT                  PKG_STD.tREF;
    nPOINT_ACTION           PKG_STD.tREF;
    nNEXT_POINT             PKG_STD.tREF;
    nINIT_PERSON            PKG_STD.tREF;
    sINIT_AUTHID            PKG_STD.tSTRING;
    nCLIENT_CLIENT          PKG_STD.tREF;
    nCLIENT_PERSON          PKG_STD.tREF;
    nPASS_COND_PROC         PKG_STD.tREF;
    sPASS_ERROR_MSG         PKG_STD.tLSTRING;
    nCHECK_PROC             PKG_STD.tREF;
    nSEND_CLIENT            PKG_STD.tREF;
    nSEND_DIVISION          PKG_STD.tREF;
    nSEND_POST              PKG_STD.tREF;
    nSEND_PERFORM           PKG_STD.tREF;
    nSEND_PERSON            PKG_STD.tREF;
    nSEND_STAFFGRP          PKG_STD.tREF;
    nSEND_USER_GROUP        PKG_STD.tREF;
    sSEND_USER_AUTHID       PKG_STD.tSTRING;
    nPERSON                 PKG_STD.tREF;
    nCHECK_RESULT           number( 1 );
  begin
    /* поиск активной статусной модели раздела */
    rUNITSTMOD := FIND_UNITSTMOD(nCOMPANY, sUNITCODE);

    /* выход, если статусная модель не найдена */
    if rUNITSTMOD.RN is null then
      return;
    end if;

    /* если режим выполнения "эпилог" и не стандартное добавление/размножение//удаление */
    if (sMODE = 'AFTER') and not nSTANDARD in (1,3) then

      /* если задано действие */
      if sACTION is not null then

        /* поиск точки автоматического перехода */
        begin
          select T.RN,
                 T.CRN,
                 T.EVENT_TYPE,
                 T.INIT_PERSON,
                 T.INIT_AUTHID,
                 T.CLIENT_CLIENT,
                 T.CLIENT_PERSON,
                 P.RN,
                 P.PRN,
                 A.EVRTPOINTS,
                 N.EVENT_STATUS
            into nEVENT,
                 nCRN,
                 nEVENT_TYPE,
                 nINIT_PERSON,
                 sINIT_AUTHID,
                 nCLIENT_CLIENT,
                 nCLIENT_PERSON,
                 nPOINT,
                 nROUTE,
                 nNEXT_POINT,
                 nEVENT_STAT
            from CLNEVENTS  T,
                 EVRTPOINTS P,
                 EVRTPNTACT A,
                 EVRTPOINTS N
            where T.LINKED_UNIT = sUNITCODE
              and T.LINKED_RN = nDOCUMENT
              and T.EVENT_STAT = P.EVENT_STATUS
              and P.COMPANY = nCOMPANY
              and P.RN = A.PRN
              and A.UNITFUNC = sACTION
              and A.EVRTPOINTS = N.RN;
        exception
          when NO_DATA_FOUND then
            nPOINT := null;
            nNEXT_POINT := null;
        end;

        if nNEXT_POINT is not null then
          /* проверка полномочий на выполнение переходов в следующие точки маршрута */
          P_EVRTPTEXEC_CHECK_RIGHTS( nCOMPANY, nEVENT, null /* nREMOTE_ACCESS */, 2 );

          /* проверка, является ли переход условным или нет */
          begin
            select PASS_COND_PROC,
                   PASS_ERROR_MSG
              into nPASS_COND_PROC,
                   sPASS_ERROR_MSG
              from EVRTPTPASS
             where PRN = nPOINT
               and NEXT_POINT = nNEXT_POINT;
          exception
            when NO_DATA_FOUND then
              if rUNITSTMOD.EVROUTES is not null then
                P_EXCEPTION(0, 'Статусная модель "%s". Переход в новый статус не определен. Возможно, статусная модель была модифицирована. ' ||
                               'Обратитесь к Администратору системы.', GET_EVROUTES_CODE_ID(0,rUNITSTMOD.EVROUTES));
              elsif ROUTE_IS_STMOD(nCOMPANY, sUNITCODE, nROUTE) then
                P_EXCEPTION(0, 'Статусная модель "%s". Переход в новый статус не определен. Возможно, статусная модель была модифицирована. ' ||
                               'Обратитесь к Администратору системы.', GET_EVROUTES_CODE_ID(0, nROUTE));
              else
                P_EXCEPTION(0, 'Маршрут событий "%s". Переход в точку маршрута, соответствующую новому статусу события, не определен. ' ||
                               'Возможно, маршрутная карта события была модифицирована. Обратитесь к Администратору системы.', GET_EVROUTES_CODE_ID(0, nROUTE));
              end if;
          end;

          if nPASS_COND_PROC is not null then
            /* предопределённая пользовательская процедура (проверки условий выполнения переходов, действий и т.п. в событиях) */
            P_PDUP_CLNEVENTS_CHECK_PASS /* -- Обновление от 03_2022*/
            (
              nPASS_COND_PROC,
              nCOMPANY,
              nCRN,
              nEVENT,
              nCHECK_RESULT
            );

            if nCHECK_RESULT = 0 then
              if sPASS_ERROR_MSG is null then
                if rUNITSTMOD.EVROUTES is not null then
                  P_EXCEPTION(0, 'Статусная модель "%s". Невозможно выполнить переход из текущего статуса, так как не выполняется условие перехода.',
                    GET_EVROUTES_CODE_ID(0,rUNITSTMOD.EVROUTES));
                elsif ROUTE_IS_STMOD(nCOMPANY, sUNITCODE, nROUTE) then
                  P_EXCEPTION(0, 'Статусная модель "%s". Невозможно выполнить переход из текущего статуса, так как не выполняется условие перехода.',
                    GET_EVROUTES_CODE_ID(0, nROUTE));
                else
                  P_EXCEPTION(0, 'Маршрут событий "%s". Невозможно выполнить переход из текущей точки маршрута, так как не выполняется условие перехода.',
                    GET_EVROUTES_CODE_ID(0, nROUTE));
                end if;
              else
                P_EXCEPTION(0, sPASS_ERROR_MSG);
              end if;
            end if;
          end if;

          /* поиск исполнителя по умолчанию */
          FIND_EVRTPOINTS_DEF_EXECUTER
          (
            nCOMPANY,
            nEVENT,  /*-- Событие */
            nINIT_PERSON,
            sINIT_AUTHID,
            null/*nCLIENT_CLIENT**/,
            null/*nCLIENT_PERSON*/,
            nEVENT_TYPE,
            nEVENT_STAT,
            nSEND_CLIENT,
            nSEND_DIVISION,
            nSEND_POST,
            nSEND_PERFORM,
            nSEND_PERSON,
            nSEND_STAFFGRP,
            nSEND_USER_GROUP,
            sSEND_USER_AUTHID
          );

          /* исправление события */
          P_CLNEVENTS_BASE_UPDATE
          (
            nCOMPANY,
            nEVENT,
            'CLNEVENTS_CHANGE_STATE',
            nEVENT_STAT,
            null,
            null,
            nSEND_CLIENT,
            nSEND_DIVISION,
            nSEND_POST,
            nSEND_PERFORM,
            nSEND_PERSON,
            nSEND_STAFFGRP,
            nSEND_USER_GROUP,
            sSEND_USER_AUTHID,
            null/*sEVENT_DESCR*/,
            sACTION
          );

          /* уведомление о выполнении перехода в данную точку */
          P_EVRTPTNOT_NOTIFY( nCOMPANY, nEVENT, 3 ); -- тип активизации (после после перехода в данную точку) - 3

          /* изменение статуса мероприятия */
          P_CLNEVENTS_EX_MEASSTATE( nCOMPANY, nEVENT );

        /* если стандартное Формирование/удаление ЭП в разделе */
        elsif nSTANDARD in (12,14) then

          /* отражение действий с ЭП в связанном с документом событии */
          P_CLNEVENTS_SIGN_PROCESSING
          (
            nCOMPANY,
            sUNITCODE,
            nDOCUMENT,
            sACTION
          );
        end if;
      end if;

    /* если режим выполнения "пролог" */
    elsif sMODE = 'BEFORE' then

      /* поиск действия в точке маршрута */
      begin
        select T.RN,
               T.INIT_PERSON,
               T.INIT_AUTHID,
               T.CLIENT_CLIENT,
               T.CLIENT_PERSON,
               P.RN,
               P.PRN,
               A.CHECK_PROC,
               A.RN
          into nEVENT,
               nINIT_PERSON,
               sINIT_AUTHID,
               nCLIENT_CLIENT,
               nCLIENT_PERSON,
               nPOINT,
               nROUTE,
               nCHECK_PROC,
               nPOINT_ACTION
          from CLNEVENTS  T,
               EVRTPOINTS P,
               EVRTPNTACT A
         where T.LINKED_UNIT = sUNITCODE
           and T.LINKED_RN = nDOCUMENT
           and T.EVENT_STAT = P.EVENT_STATUS
           and P.COMPANY = nCOMPANY
           and P.RN = A.PRN
           and A.UNITFUNC = sACTION;
      exception
        when NO_DATA_FOUND then
          nPOINT_ACTION := null;
      end;

      if nPOINT_ACTION is not null then

        /* определение сотрудника для текущего пользователя */
        begin
          select RN
            into nPERSON
            from CLNPERSONS
           where PERS_AUTHID = UTILIZER
             and COMPANY = nCOMPANY;
        exception
          when NO_DATA_FOUND then
            nPERSON := null;
        end;

        /* проверка исполнителя действия в точке маршрута */
        select count(*)
          into nCHECK_RESULT
          from EVRTPNTACTEX
         where PRN = nPOINT_ACTION
           and F_EVRTPNTACTEX_CHECK_AUTHID
               (
                 nCOMPANY,
                 UTILIZER,
                 nPERSON,
                 nEVENT,
                 nINIT_PERSON,
                 sINIT_AUTHID,
                 nCLIENT_CLIENT,
                 nCLIENT_PERSON,
                 nPOINT,
                 PREDEFINED_EXEC,
                 PREDEFINED_PROC,
                 CLIENT,
                 DIVISION,
                 POST,
                 POST_IN_DIV,
                 PERSON,
                 STAFFGRP,
                 USER_GROUP,
                 USER_AUTHID
               ) > 0;

        if nCHECK_RESULT = 0 then
          if rUNITSTMOD.EVROUTES is not null then
            P_EXCEPTION(0, 'Статусная модель "%s". Недостаточно полномочий для выполнения действия "%s".',
              GET_EVROUTES_CODE_ID(0,rUNITSTMOD.EVROUTES), GET_UNITFUNC_NAME_CODE(0, sACTION));
          elsif ROUTE_IS_STMOD(nCOMPANY, sUNITCODE, nROUTE) then
            P_EXCEPTION(0, 'Статусная модель "%s". Недостаточно полномочий для выполнения действия "%s".',
              GET_EVROUTES_CODE_ID(0, nROUTE), GET_UNITFUNC_NAME_CODE(0, sACTION));
          else
            P_EXCEPTION(0, 'Маршрут событий "%s". Недостаточно полномочий для выполнения действия "%s".',
              GET_EVROUTES_CODE_ID(0, nROUTE), GET_UNITFUNC_NAME_CODE(0, sACTION));
          end if;
        end if;

        /* вызов пользовательской процедуры проверки условий выполнения действия */
        if nCHECK_PROC is not null then
          P_DUP_UNITSTMOD_CHECK_ACTION
          (
            nCHECK_PROC,
            nCOMPANY,
            sUNITCODE,
            nDOCUMENT,
            sACTION
          );
        end if;
      end if;
    end if;
  end ACTION_PROCESSING;

  /* процедура выполнения обработки документов в статусной модели */
  procedure EXEC_PROCESSING
  (
    nCOMPANY                in number,      -- Организация
    sUNITCODE               in varchar2,    -- Мнемокод раздела
    nDOCUMENT               in number,      -- Документ
    sACTION                 in varchar2,    -- Выполняемое действие
    sMODE                   in varchar2,    -- Режим выполнения 'BEFORE' - пролог, 'AFTER' - эпилог
    nSTANDARD               in number,      -- Тип действия
    nBUSPROC                in number       -- Идентификатор бизнес-процесса
  )
  is
    rUNITSTMOD              UNITSTMOD%rowtype;
    nEVENT                  PKG_STD.tREF;
    bDOC_PROCESSED          boolean := false;   -- документ уже обработан (флаг)
  begin
    /* если режим выполнения "эпилог" */
    if sMODE = 'AFTER' then

      /* цикл обработки предварительно зарегистрированных документов */
      for Rec in
      (
        select *
          from UNITSTMOD_TEMP
         where BUSPROC = nBUSPROC
      )
      loop
        /* если активация */
        if Rec.OPERATION = 1 then

          if Rec.EVENT is null then
            /* создание события по статусной модели (для предварительно зарегистрированного документа) */
            CREATE_EVENT
            (
              nCOMPANY,
              Rec.UNITCODE,
              Rec.DOCUMENT,
              Rec.UNITSTMOD,
              null/*sACTION*/,
              nEVENT
            );
          end if;

          /* дополнение описания события описателем документа */
          ADD_DOC_DESCRIBE
          (
            nCOMPANY,
            Rec.UNITCODE,
            Rec.DOCUMENT,
            coalesce(Rec.EVENT,nEVENT)
          );

        /* если деактивация */
        elsif Rec.OPERATION = 0 then

          if Rec.EVENT is null then
            /* поиск и удаление события по статусной модели */
            REMOVE_EVENT( FIND_EVENT(nCOMPANY, Rec.UNITCODE, Rec.DOCUMENT) );
          else
            /* удаление события по статусной модели */
            REMOVE_EVENT( Rec.EVENT );
          end if;
        end if;

        /* если выполняется эпилог стандартного добавления/удаления и документ был зарегистрирован, а значит уже обработан */
        if nSTANDARD in (1,3) and (Rec.UNITCODE = sUNITCODE) and (Rec.DOCUMENT = nDOCUMENT) then
          /* установка флага */
          bDOC_PROCESSED := true;
        end if;

        /* очистка обработанного документа */
        delete
          from UNITSTMOD_TEMP
         where BUSPROC  = nBUSPROC
           and UNITCODE = Rec.UNITCODE
           and DOCUMENT = Rec.DOCUMENT;
      end loop;

      /* если документ не был обработан */
      if not bDOC_PROCESSED then
        /* если выполняется эпилог стандартного добавления/размножения */
        if nSTANDARD = 1 then

          /* поиск активной статусной модели раздела */
          rUNITSTMOD := FIND_UNITSTMOD(nCOMPANY, sUNITCODE);

          /* если существует активная статусная модель */
          if rUNITSTMOD.RN is not null then
            /* если нет связанного с документом события */
            if FIND_EVENT( nCOMPANY, sUNITCODE, nDOCUMENT ) is null then

              /* создание события по статусной модели */
              CREATE_EVENT
              (
                nCOMPANY,
                sUNITCODE,
                nDOCUMENT,
                rUNITSTMOD,
                sACTION,
                nEVENT
              );

              /* дополнение описания события описателем документа */
              ADD_DOC_DESCRIBE
              (
                nCOMPANY,
                sUNITCODE,
                nDOCUMENT,
                nEVENT
              );
            end if;
          end if;

        /* если выполняется эпилог стандартного удаления */
        elsif nSTANDARD = 3 then

          /* поиск и удаление события по статусной модели */
          REMOVE_EVENT( FIND_EVENT(nCOMPANY, sUNITCODE, nDOCUMENT) );
        end if;
      end if;
    end if;

    /* обработка действия раздела документа */
    ACTION_PROCESSING
    (
      nCOMPANY,
      sUNITCODE,
      nDOCUMENT,
      sACTION,
      sMODE,
      nSTANDARD
    );
  end EXEC_PROCESSING;

  /* процедура начала обработки действия раздела документа в статусной модели */
  procedure ACTION_PROLOGUE
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2,
    nDOCUMENT               in number,
    sACTION                 in varchar2
  )
  is
  begin
    /* обработка действия */
    ACTION_PROCESSING
    (
      nCOMPANY,
      sUNITCODE,
      nDOCUMENT,
      sACTION,
      'BEFORE',
      GET_UNITFUNC_TYPE_CODE(0, sACTION)
    );
  end ACTION_PROLOGUE;

  /* процедура окончания обработки действия раздела документа в статусной модели */
  procedure ACTION_EPILOGUE
  (
    nCOMPANY                in number,
    sUNITCODE               in varchar2,
    nDOCUMENT               in number,
    sACTION                 in varchar2
  )
  is
  begin
    /* обработка действия */
    ACTION_PROCESSING
    (
      nCOMPANY,
      sUNITCODE,
      nDOCUMENT,
      sACTION,
      'AFTER',
      GET_UNITFUNC_TYPE_CODE(0, sACTION)
    );
  end ACTION_EPILOGUE;

end UDO_PKG_UNITSTMOD;
/

