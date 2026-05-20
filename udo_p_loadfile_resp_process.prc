create or replace procedure UDO_P_LOADFILE_RESP_PROCESS
/* Парсинг и обработка ответов СКУД */
(
  NIDENT                    in number,        -- Идентификатор процесса
  NEXSQUEUE                 in number         -- Регистрационный номер обрабатываемой позиции очереди обмена
)
is
  REXSQUEUE                 EXSQUEUE%rowtype; -- Запись очереди
  SERR                      PKG_STD.TLSTRING; -- Буфер для ошибок
  nIDENT_MOV                PKG_STD.tREF;
  OPTS                      PKG_EXS.TOPTIONS;
  sNEW_DIROK                PKG_STD.TLSTRING;
  sNEW_DIRERR               PKG_STD.TLSTRING;
begin
  /* Считаем запись очереди */
  REXSQUEUE := GET_EXSQUEUE_ID(NFLAG_SMART => 0, NRN => NEXSQUEUE);

  /* !!!! ТУТ КОД КОТОРЫЙ ПАРСИТ ОТВЕТ ИЗ REXSQUEUE.RESP !!!!
    <SDIR>C:\tmp\LOAD</SDIR>
    <SDIR_ERR>C:\tmp\LOAD_ERROR</SDIR_ERR>
    <SDIR_OK>C:\tmp\LOAD_OK</SDIR_OK>
    <SFORMAT>KZ</SFORMAT>
  */
    UDO_P_LOAD_DATAFILE_WEBAPI(SDIR      => PKG_EXS.OPTIONS_READ(SOPTIONS => REXSQUEUE.OPTIONS,
                                                                                 SPATH    => 'qs/SDIR'),
                                             SDIR_OK   => PKG_EXS.OPTIONS_READ(SOPTIONS => REXSQUEUE.OPTIONS,
                                                                                 SPATH    => 'qs/SDIR_OK'),
                                             SDIR_ERR  => PKG_EXS.OPTIONS_READ(SOPTIONS => REXSQUEUE.OPTIONS,
                                                                                    SPATH    => 'qs/SDIR_ERR'),
                                             SFORMAT   => PKG_EXS.OPTIONS_READ(SOPTIONS => REXSQUEUE.OPTIONS,
                                                                                 SPATH    => 'qs/SFORMAT'),
                                             sIDENT    => blob2clob(REXSQUEUE.RESP_ORIGINAL),
                                             nIDENT_MOV  => nIDENT_MOV,
                                             sNEW_DIROK  => sNEW_DIROK,
                                             sNEW_DIRERR  => sNEW_DIRERR,
                                             SERROR => SERR);
  /* Всё прошло успешно */
  PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => 'IDENT_MOV',
                      sVALUE  => nIDENT_MOV);                                                        
  PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => 'NEW_DIROK',
                      sVALUE  => sNEW_DIROK);                                                        
  PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => 'NEW_DIRERR',
                      sVALUE  => sNEW_DIRERR);
                      
  PKG_EXS.PRC_RESP_RESULT_SET(NIDENT => NIDENT,
                              BRESP => REXSQUEUE.RESP_ORIGINAL, 
                              SOPTIONS_RESP => PKG_EXS.OPTIONS_SERIALIZE(OPTIONS => OPTS),
                              SMSG => SERR);
 
                            
exception
  when others then
    /* Запомним ошибку */
    PKG_STATE.DIAGNOSTICS_STACKED();
    SERR := PKG_STATE.SQL_ERRM();
    /* Вернём ошибку */
    PKG_EXS.PRC_RESP_RESULT_SET(NIDENT  => NIDENT,
                                SRESULT => PKG_EXS.SPRC_RESP_RESULT_ERR,
                                SMSG    => SERR);
end;
-- grant execute on UDO_P_LOADFILE_RESP_PROCESS to public;
/

