create or replace package USR_PKG_UPDATELIST is
  /*
  Степанов М. 27/09/2024
  Package предназначен для работы с разделом "Инструменты оплаты". 
  ModificationHistory         UPDATELIST          UL
  ModificationHistoryDetail   UPDATELIST_DETAIL   ULD
  */
  --#########################################################################################################

  procedure UPDATELIST_GET_LAST_DETAILS
  /*
  Процедура получения данных последнего заданного действия с документом
  */
  (
   nFLAGSMART       in number default 1
  ,nRN              in number     /* Документ. RN */
  ,sOPERATION       in varchar2   /* I - добавление, U - исправление, D - удаление */
  ,dMODIFDATE       out date
  ,sAUTHID          out varchar2
  );
  --#########################################################################################################

  function UPDATELIST_GET_LAST_DATE
  /*
  Функция получения последней даты заданного действия с документом
  */
  (
   nFLAGSMART       in number default 1
  ,nRN              in number     /* Документ. RN */
  ,sOPERATION       in varchar2   /* I - добавление, U - исправление, D - удаление */
  ) 
  return date;
  --#########################################################################################################

  function UPDATELIST_GET_LAST_AUTHID
  /*
  Функция получения последней даты заданного действия с документом
  */
  (
   nFLAGSMART       in number default 1
  ,nRN              in number     /* Документ. RN */
  ,sOPERATION       in varchar2   /* I - добавление, U - исправление, D - удаление */
  ) 
  return varchar2;
  --#########################################################################################################

  procedure UPDATELIST_BASE_INSERT
  /* 
  Заголовок. Добавление 
  */
  (
   sTABLE_NAME      in varchar2  
  ,nDOCUMENT        in number
  ,nCOMPANY         in number
  ,sOPERATION       in varchar2
  ,dMODIFDATE       in date
  ,sNOTE            in varchar2
  ,nVERSION         in number default null
  ,nCATALOG         in number default null
  ,nJUR_PERS        in number default null
  ,nHIERARCHY       in number default null
  ,nBUSPROCHIST     in number default null
  ,nBUSPROCACTHIST  in number default null
  );
  --#########################################################################################################

end USR_PKG_UPDATELIST;
/
create or replace package body USR_PKG_UPDATELIST is

  --#########################################################################################################

  procedure UPDATELIST_GET_LAST_DETAILS
  /*
  Процедура получения данных последнего заданного действия с документом
  */
  (
   nFLAGSMART       in number default 1
  ,nRN              in number     /* Документ. RN */
  ,sOPERATION       in varchar2   /* I - добавление, U - исправление, D - удаление */
  ,dMODIFDATE       out date
  ,sAUTHID          out varchar2
  ) 
  is
  begin
    begin
      select e.modifdate, e.authid
        into dMODIFDATE , sAUTHID
        from (
--              select /*+ index(up i_updatelist_tablern) */ ul.modifdate, ul.authid
              select ul.modifdate, ul.authid
                from updatelist ul
               where ul.tablern   = nRN
                 and ul.operation = sOPERATION
              union
--              select /*+ index(up i_updatelist_arc_tablern) */ ula.modifdate, ula.authid
              select ula.modifdate, ula.authid
                from updatelist_arc ula
               where ula.tablern   = nRN
                 and ula.operation = sOPERATION
              order by modifdate desc
             ) e
       where rownum = 1
      ;
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Не найдено записей в журнале регистрации событий для документа с RN <%s> с операцией <%s>'
                   ,nRN, sOPERATION);
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске записей в журнале регистрации событий для документа с RN <%s> с операцией <%s>'
                     ,nRN, sOPERATION);
    end;
    
  end UPDATELIST_GET_LAST_DETAILS;
  --#########################################################################################################

  function UPDATELIST_GET_LAST_DATE
  /*
  Функция получения последней даты заданного действия с документом
  */
  (
   nFLAGSMART       in number default 1
  ,nRN              in number     /* Документ. RN */
  ,sOPERATION       in varchar2   /* I - добавление, U - исправление, D - удаление */
  ) 
  return date
  is
    dDate       date; 
    sVarchar    pkg_std.tstring; 
  begin
    usr_pkg_updatelist.updatelist_get_last_details(nflagsmart => nFLAGSMART
                                                  ,nrn        => nRN
                                                  ,soperation => sOPERATION
                                                  ,dmodifdate => dDate
                                                  ,sauthid    => sVarchar);
    return dDate;
    
  end UPDATELIST_GET_LAST_DATE;
  --#########################################################################################################

  function UPDATELIST_GET_LAST_AUTHID
  /*
  Функция получения последней даты заданного действия с документом
  */
  (
   nFLAGSMART       in number default 1
  ,nRN              in number     /* Документ. RN */
  ,sOPERATION       in varchar2   /* I - добавление, U - исправление, D - удаление */
  ) 
  return varchar2
  is
    dDate       date; 
    sVarchar    pkg_std.tstring; 
  begin
    usr_pkg_updatelist.updatelist_get_last_details(nflagsmart => nFLAGSMART
                                                  ,nrn        => nRN
                                                  ,soperation => sOPERATION
                                                  ,dmodifdate => dDate
                                                  ,sauthid    => sVarchar);
    return sVarchar;
    
  end UPDATELIST_GET_LAST_AUTHID;
  --#########################################################################################################

  procedure UPDATELIST_BASE_INSERT
  /* 
  Заголовок. Добавление 
  */
  (
   sTABLE_NAME      in varchar2  
  ,nDOCUMENT        in number
  ,nCOMPANY         in number
  ,sOPERATION       in varchar2
  ,dMODIFDATE       in date
  ,sNOTE            in varchar2
  ,nVERSION         in number default null
  ,nCATALOG         in number default null
  ,nJUR_PERS        in number default null
  ,nHIERARCHY       in number default null
  ,nBUSPROCHIST     in number default null
  ,nBUSPROCACTHIST  in number default null
  ) 
  as
    rRow         updatelist%rowtype;
    rlogdata     pkg_session_logdata.tdata;
  begin
    rlogdata          := pkg_session_logdata.read;
    
    rRow.rn             := seq_updatelist.nextval;
    rRow.modifdate      := dMODIFDATE;
    rRow.operation      := sOPERATION;
    rRow.authid         := rlogdata.authid;
    rRow.program        := rlogdata.application;
    rRow.company$vs     := rlogdata.company;
    rRow.connect_type   := rlogdata.connect_type;
    rRow.connect_ext    := rlogdata.connect_ext;
    rRow.session_id     := rlogdata.session_id;
    rRow.ip_address     := rlogdata.ip_address;
    rRow.osuser         := rlogdata.osuser;
    rRow.machine        := rlogdata.machine;
    rRow.terminal       := rlogdata.terminal;
    rRow.program$vs     := rlogdata.program;
    rRow.browser        := rlogdata.browser;
    rRow.tablename      := sTABLE_NAME;
    rRow.tablern        := nDOCUMENT;
    rRow.company        := case when nCOMPANY is not null then nCOMPANY else pkg_session.get_company end;
    rRow.version        := nVERSION;
    rRow.catalog        := nCATALOG;
    rRow.jur_pers       := nJUR_PERS;
    rRow.hierarchy      := nHIERARCHY;
    rRow.note_format    := 1;
    rRow.note           := sNOTE;
    rRow.busprochist    := nBUSPROCHIST;
    rRow.busprocacthist := nBUSPROCACTHIST;

    insert into updatelist values rrow;

  end UPDATELIST_BASE_INSERT;
  --#########################################################################################################

end USR_PKG_UPDATELIST;
/
