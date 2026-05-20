create or replace procedure udo_p_mcst_csv
(
  nCOMPANY in number,
  nIDENT   in number
) as
  /*
    30/11/2025 Степанов М. Проверка мнемокода и наименования  
    Марков МВ. 30/11/2022
  */

  bDATA               blob; -- Excel-файл    
  cDATA               clob; -- Загруженный файл
  SFILE_NAME          FILE_BUFFER.FILENAME%type; -- наименование файла
  nID_PRS             number(17);
  rTMP                UDO_MCST_CSV%rowtype;
  nSUMM_ININVOICES    ININVOICES.SUMM%type;
  nSUMMTAX_ININVOICES ININVOICES.SUMMTAX%type;

  /* Конвертация из clob в blob */
  FUNCTION clob_to_blob
  (
    p_clob        CLOB,
    p_charsetname VARCHAR2
  ) RETURN BLOB AS
    l_lang_ctx    INTEGER := DBMS_LOB.default_lang_ctx;
    l_warning     INTEGER;
    l_dest_offset NUMBER := 1;
    l_src_offset  NUMBER := 1;
    l_return      BLOB;
  BEGIN
    DBMS_LOB.createtemporary(l_return, FALSE);
    DBMS_LOB.converttoblob(l_return,
                           p_clob,
                           DBMS_LOB.lobmaxsize,
                           l_dest_offset,
                           l_src_offset,
                           CASE WHEN p_charsetname IS NOT NULL THEN NLS_CHARSET_ID(p_charsetname) ELSE
                           DBMS_LOB.default_csid END,
                           l_lang_ctx,
                           l_warning);
  
    RETURN l_return;
  END;

  procedure get_nomen_like
  (
    sNAME  in varchar2,
    nNOMEN out number,
    nMODIF out number
  ) is
  begin
    for rec in (select NM.RN,
                       (select count(*) from NOMMODIF MD where MD.PRN = NM.RN) MD_CNT
                  from DICNOMNS NM
                 where NM.NOMEN_NAME like '%' || sNAME || '%'
                   and NM.VERSION = 91744) loop
      nNOMEN := rec.rn;
      if rec.md_cnt = 1 then
        select RN into nMODIF from NOMMODIF where PRN = rec.rn;
      end if;
    end loop;
  end get_nomen_like;

  procedure insert_new
  (
    sNAME  in varchar2,
    sMODIF in varchar2,
    nNOMEN out number,
    nMODIF out number
  ) is
    sCODE       DICNOMNS.NOMEN_CODE%type;
    sMODIF_NAME NOMMODIF.MODIF_NAME%type;
  begin
    P_DICNOMNS_GETNEXTCODE(nCOMPANY => nCOMPANY, sCODE => sCODE);
    P_DICNOMNS_BASE_INSERT(nCOMPANY         => nCOMPANY,
                           nCRN             => 51476137,
                           sNOMEN_CODE      => sCODE,
                           sNOMEN_NAME      => sNAME,
                           sMN_NAME         => null,
                           sORIGINAL_NAME   => null,
                           nMEAS_MAIN       => 175629,
                           nMEAS_ALT        => null,
                           nEQUAL           => 0,
                           nSIGN_ACNT       => 1,
                           nSIGN_DOCS       => 1,
                           nGROUP_CODE      => 13884309,
                           nTAX_GROUP       => 502994,
                           nNALTAX_GROUP    => null,
                           nSIGN_UMEAS      => 0,
                           nNOMEN_TYPE      => 1,
                           nSIGN_SERIAL     => 0,
                           nSIGN_MODIF      => 0,
                           nSIGN_PARTY      => 0,
                           nSIGN_SER_RANGES => 0,
                           nSIGN_LIQUID     => 0,
                           nCNTRNDM         => 0,
                           nMTDRNDM         => 0,
                           nCNTRNDS         => 0,
                           nMTDRNDS         => 0,
                           nOKPD            => null,
                           nOKDP_RN         => null,
                           nOKOF            => null,
                           nSIGN_SET        => 0,
                           nSIGN_SET_DIVIDE => 0,
                           nRN_DUP          => null,
                           nWIDTH           => null,
                           nHEIGHT          => null,
                           nLENGTH          => null,
                           nWEIGHT          => null,
                           nMU_SIZE         => 1,
                           nMU_WEIGHT       => 1,
                           nTEMP_FROM       => null,
                           nTEMP_TO         => null,
                           nHUMID_FROM      => null,
                           nHUMID_TO        => null,
                           nCOMMON_PR_SIGN  => 0,
                           nSTORAGE_TIME    => null,
                           nUMEAS_STORAGE   => null,
                           nAUTOADDMODIF    => 0,
                           nOKP             => null,
                           nAMORT_GROUP     => null,
                           nFNSNOMCLASS     => null,
                           nOKVED           => null,
                           nRN              => nNOMEN);
    /* 30/11/2025 Степанов М. Проверка мнемокода и наименования */
    usr_pkg_dicnomns.dicnomns_check_name(nrn => nNOMEN, ncompany => nCOMPANY);

    sMODIF_NAME := case
                     when instr(sMODIF, 'АЛЯР') > 0 then
                      substr(sMODIF, instr(sMODIF, 'АЛЯР'))
                     when instr(sMODIF, 'ШКАБ') > 0 then
                      substr(sMODIF, instr(sMODIF, 'ШКАБ'))
                     when instr(sMODIF, 'ТВГИ') > 0 then
                      substr(sMODIF, instr(sMODIF, 'ТВГИ'))
                     when instr(sMODIF, 'РЮМК') > 0 then
                      substr(sMODIF, instr(sMODIF, 'РЮМК'))
                     else
                      sCODE
                   end;
  
    p_nommodif_base_insert(nCOMPANY        => nCOMPANY,
                           nPRN            => nNOMEN,
                           sMODIF_CODE     => sCODE,
                           sMODIF_NAME     => sMODIF_NAME,
                           sBAR_CODE       => null,
                           sCOMMENTS       => 'МЦСТ',
                           nPRN_DUP        => null,
                           nRN_DUP         => null,
                           nWIDTH          => null,
                           nHEIGHT         => null,
                           nLENGTH         => null,
                           nWEIGHT         => null,
                           nMU_SIZE        => 1,
                           nMU_WEIGHT      => 1,
                           nTEMP_FROM      => null,
                           nTEMP_TO        => null,
                           nHUMID_FROM     => null,
                           nHUMID_TO       => null,
                           nCOMMON_PR_SIGN => 0,
                           nPRODUCER       => null,
                           nSTORAGE_TIME   => null,
                           nUMEAS_STORAGE  => null,
                           nGOODNOMENFT    => null,
                           nRN             => nMODIF);
  end insert_new;

begin
  /* Забираем загруженные данные из файлового буфера */
  begin
    select T.DATA,
           T.FILENAME
      into cDATA,
           SFILE_NAME
      from FILE_BUFFER T
     where T.IDENT = nIDENT;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Данные файла Excel не найдены в буфере (IDENT: %s).', TO_CHAR(nIDENT));
    when TOO_MANY_ROWS then
      P_EXCEPTION(0,
                  'Данные файла Excel определены неоднозначно (IDENT: %s).',
                  TO_CHAR(nIDENT));
  end;
  
  /* Проверка наличия данных */
  if dbms_lob.getlength(cDATA) = 0 then
    p_exception(0, 'Загружаемый файл Excel пуст.');
  end if;
  
  bDATA := clob_to_blob(cDATA, null);
  
  /* Разбор данных Excel файла */
  UDO_PKG_XLSX_PARSER.PARSE_XLS(bDATA => bDATA, nIDENT => nID_PRS);
  
  for cur in (SELECT *
                FROM TABLE(udo_pkg_xlsx_parser.get_data(nident => nID_PRS)) t
              )
   loop
    rTMP.Rn       := gen_ident;
    rTMP.Doc_Numb := cur.col01;
    rTMP.Doc_Date := cur.col02;
    rTMP.Ord      := cur.col03;
    rTMP.Sernumb  := cur.col04;
    rTMP.Code     := cur.col05;
    rTMP.Name     := cur.col06;
    rTMP.Modif    := cur.col07;
    rTMP.Quant    := cur.col08;
    rTMP.Firm     := cur.col09;
    rTMP.Price    := cur.col10;
    rTMP.Summa    := cur.col11;
    insert into UDO_MCST_CSV values rTMP;
  end loop;

  -- попробуем найти
  for r1 in (select * from UDO_MCST_CSV /*where NOMEN is not null*/) loop
  /*  --
    if instr(r1.modif, 'Микросхема') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Микросхема')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Конденсатор керамический') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Конденсатор керамический')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Транзистор') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Транзистор')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Индуктивность') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Индуктивность')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Источник питания') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Источник питания')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Конденсатор электролитический') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Конденсатор электролитический')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Кварцевый резонатор') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Кварцевый резонатор')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'ферритовая') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'ферритовая')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Кварцевый генератор') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Кварцевый генератор')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Резисторная сборка') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Резисторная сборка')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Резистор') > 0  and instr(r1.modif, 'Резисторная сборка') <= 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Резистор')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Переключатель') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Переключатель')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Диод Шоттки') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Диод Шоттки')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Светодиод') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Светодиод')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Предохранитель') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Предохранитель')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Переключатель кнопочный') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Переключатель кнопочный')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    elsif instr(r1.modif, 'Диод') > 0 then
      get_nomen_like(sNAME => trim(replace(r1.modif, 'Диод')), nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
    --
    else*/
      get_nomen_like(sNAME => r1.name, nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
/*-    end if;*/

    -- добавим
      get_nomen_like(sNAME => r1.name, nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
      if r1.nomen is null then
    insert_new(sNAME => r1.name, sMODIF => r1.modif, nNOMEN => r1.nomen, nMODIF => r1.modif_rn);
    end if;
    update UDO_MCST_CSV set NOMEN = r1.nomen, MODIF_RN = r1.modif_rn where RN = r1.rn;
  
    -- спецификация
    p_ininvoicesspecs_base_insert(nCOMPANY            => nCOMPANY,
                                  nPRN                => 101803945,
                                  nNOMEN              => r1.nomen,
                                  nMODIF              => r1.modif_rn,
                                  nPACK               => null,
                                  nARTICLE            => null,
                                  nTAXGR              => 1026751,
                                  nSTORE              => null,
                                  nQUANT              => to_number(r1.quant),
                                  nQUANTALT           => null,
                                  nPRICE              => /*to_number(r1.price)*/0,
                                  nPRICEMEAS          => 0,
                                  nSUMM               => /*to_number(r1.summa)*/0,
                                  nSUMMTAX            => /*to_number(r1.summa)*/0,
                                  nSUMM_NDS           => 0,
                                  nAUTOCALC_SIGN      => 0,
                                  dSROK               => null,
                                  sSERTIFICATE        => null,
                                  sNOTE               => 'Давальческое МЦСТ',
                                  dBEGINDATE          => null,
                                  dENDDATE            => null,
                                  sSERNUMB            => null,
                                  sBARCODE            => null,
                                  nCOUNTRY            => null,
                                  sGTD                => null,
                                  nPRODUCER           => null,
                                  nSTORAGE_TIME       => null,
                                  nUMEAS_STORAGE      => null,
                                  nDISCOUNT           => 0,
                                  sORIGINAL_NAME      => null,
                                  dPROD_DATE          => null,
                                  nMDMNOMEN           => null,
                                  nRN                 => r1.spec,
                                  nSUMM_ININVOICES    => nSUMM_ININVOICES,
                                  nSUMMTAX_ININVOICES => nSUMMTAX_ININVOICES);
    update UDO_MCST_CSV set SPEC = r1.spec where RN = r1.rn;
  end loop;
end;
/
