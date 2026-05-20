create or replace procedure UDO_P_LOADFILE_RESP_IMXPRODSP
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
  nIDENT_            PKG_STD.tNUMBER;
  sMSG_OUT           PKG_STD.tSTRING; 
  sMOV_FILE          PKG_STD.tSTRING;
  SDIR_OK            PKG_STD.tSTRING;
  SDIR_ERR           PKG_STD.tSTRING;
  --nIDENT_MOV         PKG_STD.tREF;
  sNEW_DIROK         PKG_STD.tSTRING;
  --sNEW_DIRERR        PKG_STD.tSTRING;
  SERROR             PKG_STD.tSTRING := 'Нет ошибок';
  nIDENT_BUF         PKG_STD.tREF;
  SDIR               PKG_STD.tSTRING; 
  SDIRDEL            PKG_STD.tSTRING;
  SNAME_ENCODING_ZIP      constant PKG_STD.TSTRING := 'Windows-1251'/*'CP866'*/; -- Кодировка архива
  sLNK_COMPANY       PKG_STD.tSTRING;
begin
  /* Считаем запись очереди */
  REXSQUEUE := GET_EXSQUEUE_ID(NFLAG_SMART => 0, NRN => NEXSQUEUE);

  /* !!!! ТУТ КОД КОТОРЫЙ ПАРСИТ ОТВЕТ ИЗ REXSQUEUE.RESP !!!!
    <SDIR>C:\tmp\LOAD</SDIR>
    <SDIR_ERR>C:\tmp\LOAD_ERROR</SDIR_ERR>
    <SDIR_OK>C:\tmp\LOAD_OK</SDIR_OK>
    <SFORMAT>KZ</SFORMAT>
  */
     if blob2clob(REXSQUEUE.RESP_ORIGINAL) is not null then
    nIDENT_ := to_char(blob2clob(REXSQUEUE.RESP_ORIGINAL));
    nIDENT_MOV := gen_ident;




    for DATA_ in (/*select t.* from file_buffer t where t.ident = nIDENT*/
      select t.* from UDO_TMP_LOADMOVE_FILES T where t.ident = nIDENT_) loop

       begin
  /* Цикл по загруженным документам */  
  /*for cur in (select * from file_buffer t where t.ident = nPROCESS)    
  loop*/
    /* проверка файла */
    if upper(DATA_.SDIR_IN) not like '%.ZIP' then  
     p_exception(0 , 'Массовая загрузка изделий поддерживается только при использовании zip-архивов.');
    end if;
    
    if dbms_lob.getlength(DATA_.BDATA) = 0 then 
      p_exception(0 , 'Не удалось распознать файл zip-архива. Возможно при загрузке не указан признак "Загружать как двоичные данные".');
    end if;
    
    /* идентификатор буфера для распаковки архива */
    nIDENT_BUF := GEN_IDENT();
    
    /* Распаковка архива (данные сохраняются в FILE_BUFFER)*/
    begin
      PKG_LOB_ZIP.ZIP_ARRAY_DECOMPRESS(ZIP_FILE            => DATA_.BDATA,
                                       ENTRY_NAME_ENCODING => SNAME_ENCODING_ZIP,
                                       IDENT               => nIDENT_BUF); 
    exception when others then 
      p_exception(0,'Ошибка при обработке загружаемого архива "'||DATA_.SDIR_IN||'":'||error_text);
    end;  
    
    /* Загрузка спецификации из ИНТЕРМЕХ*/
    begin 
      sLNK_COMPANY := PKG_EXS.OPTIONS_READ(SOPTIONS => REXSQUEUE.OPTIONS, SPATH    => 'qs/NLNK_COMPANY');
      UDO_P_INTEMEH_FILE_LOAD(nCOMPANY => sLNK_COMPANY,
                              nPROCESS => nIDENT_BUF,
                              sCTLG    => 'Автоматическая загрузка');  
    exception when others then  
     p_exception(0,'Ошибка при разборе данных загружаемого архива "'||DATA_.SDIR_IN||'":'||error_text);
    end; 
    /* удаляем данные из буфера */                           
     
    sMSG_OUT := 'Нет ошибок';
    SERROR := null;                                     
  
  /* удаляем данные из буфера */                           
  --p_file_buffer_clear(nIDENT =>nPROCESS);  
  exception when OTHERS then
    sMSG_OUT := 'Ошибка загрузки!';
    SERROR := 'Ошибка: '|| ERROR_TEXT;
  end;
    /*if instr(upper(DATA_.SDIR_IN), upper('ЮФКВ.469555.915 [5] ЮФКВ.198-2023.zip')) !=0 then
      sMSG_OUT := 'Ошибка загрузки!';
      else 
        sMSG_OUT := null;
    end if;*/
    if sMSG_OUT = 'Ошибка загрузки!' then 
    SDIR_ERR := PKG_EXS.OPTIONS_READ(SOPTIONS => REXSQUEUE.OPTIONS, SPATH    => 'qs/SDIR_ERR');
    SDIR := PKG_EXS.OPTIONS_READ(SOPTIONS => REXSQUEUE.OPTIONS, SPATH    => 'qs/SDIR');
     -- win sMOV_FILE := replace(DATA_.SDIR_IN/*FILENAME*/,SDIR,SDIR_ERR||'\'||to_char(sysdate,'yyyy_mm_dd'));
     /*linux*/ sMOV_FILE := replace(DATA_.SDIR_IN/*FILENAME*/,SDIR,SDIR_ERR||'/'||to_char(sysdate,'yyyy_mm_dd'));
     
     -- win sNEW_DIRERR  := SDIR_ERR||'\'||to_char(sysdate,'yyyy_mm_dd');
    /*linux*/ sNEW_DIRERR  := SDIR_ERR||'/'||to_char(sysdate,'yyyy_mm_dd');

     insert into UDO_TMP_LOADMOVE_FILES(IDENT,SDIR_IN,SDIR_OUT,ERR)
      values(nIDENT_MOV,DATA_.SDIR_IN/*FILENAME*/,sMOV_FILE,SERROR); 

     else
       SDIR_OK := PKG_EXS.OPTIONS_READ(SOPTIONS => REXSQUEUE.OPTIONS, SPATH    => 'qs/SDIR_OK');
     -- win  sMOV_FILE := replace(DATA_.SDIR_IN/*FILENAME*/,SDIR,SDIR_OK||'\'||to_char(sysdate,'yyyy_mm_dd'));
     /* linux */  sMOV_FILE := replace(DATA_.SDIR_IN/*FILENAME*/,SDIR,SDIR_OK||'/'||to_char(sysdate,'yyyy_mm_dd'));
 
     -- win sNEW_DIROK  := SDIR_OK||'\'||to_char(sysdate,'yyyy_mm_dd'); 
     /* linux */ --sNEW_DIROK  := SDIR_OK||'/'||to_char(sysdate,'yyyy_mm_dd');
     SDIRDEL := 'IPS/OK_DEL';
    insert into UDO_TMP_LOADMOVE_FILES(IDENT,SDIR_IN,SDIR_OUT)
      values(nIDENT_MOV,DATA_.SDIR_IN/*FILENAME*/,SDIRDEL);     
     SDIRDEL := 'IPS/OK_DEL';
    end if;
  /* Всё прошло успешно */
  /*PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => 'IDENT_MOV',
                      sVALUE  => nIDENT_MOV);
  PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => 'SDIRDEL',
                      sVALUE  => SDIRDEL);
  PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => 'NEW_DIROK',
                      sVALUE  => null);
  PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => 'NEW_DIRERR',
                      sVALUE  => sNEW_DIRERR);

  PKG_EXS.PRC_RESP_RESULT_SET(NIDENT => NIDENT,
                              BRESP => REXSQUEUE.RESP_ORIGINAL,
                              SOPTIONS_RESP => PKG_EXS.OPTIONS_SERIALIZE(OPTIONS => OPTS),
                              SMSG => SERR);*/
   
   end loop;
      delete from UDO_TMP_LOADMOVE_FILES t where t.ident = nIDENT_;
    end if;



    /*UDO_P_LOAD_DATAFILE_WEBAPI(SDIR      => PKG_EXS.OPTIONS_READ(SOPTIONS => REXSQUEUE.OPTIONS,
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
                                             SERROR => SERR);*/
  /* Всё прошло успешно */
  PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => 'IDENT_MOV',
                      sVALUE  => nIDENT_MOV);
  PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => 'SDIRDEL',
                      sVALUE  => SDIRDEL);
  PKG_EXS.OPTIONS_SET(OPTIONS => OPTS,
                      SCODE   => 'NEW_DIROK',
                      sVALUE  => null);
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
-- grant execute on UDO_P_LOADFILE_RESP_IMXPRODSP to public;
/

