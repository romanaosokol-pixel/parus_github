create or replace procedure UDO_PKG_EXS_EXT_INTERMEX
  (
    NIDENT           in number,         -- Идентификатор процесса
    NEXSQUEUE        in number          -- Регистрационный номер обрабатываемой позиции очереди обмена
  )
  is
    --REXSQUEUE        EXSQUEUE%ROWTYPE;    -- заить очереди обмена
    --NRN              PKG_STD.tREF;
  begin
    
  /* Обработка */
  UDO_PKG_CADMECH_EXS.PROCESS(nIDENT, nEXSQUEUE);
  
/*    begin
      REXSQUEUE := GET_EXSQUEUE_ID(NFLAG_SMART => 0, NRN => NEXSQUEUE);

      \* Сохраним параметры запроса для последующей обработки -- Времнно *\
      NRN := gen_id;
      insert into UDO_REG_NOTICES_INTERMEX(RN,STATUS,TYPE,CXML)
      values(NRN,0,'IZV',BLOB2CLOB(REXSQUEUE.MSG_ORIGINAL));

      \* Возвращаем ответ *\
      PKG_EXS.PRC_RESP_RESULT_SET(NIDENT => NIDENT, SRESULT => PKG_EXS.SPRC_RESP_RESULT_OK);
    exception
      when others then
        \* Вернём ошибку - это фатальная *\
        PKG_STATE.DIAGNOSTICS_STACKED();
        PKG_EXS.PRC_RESP_RESULT_SET(NIDENT        => NIDENT,
                                    SRESULT       => PKG_EXS.SPRC_RESP_RESULT_ERR,
                                    SMSG          => PKG_STATE.SQL_ERRM());
    end;
*/
end UDO_PKG_EXS_EXT_INTERMEX;
-- grant execute on UDO_PKG_EXS_EXT_INTERMEX to public;
/

