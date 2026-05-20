create or replace package UDO_PKG_REVEXPEANALYSIS_XLS

is

  /* Формирование отчет */
  procedure XLS_MAKE
  (
    NCOMPANY          in number,   -- Организация
    SFPDARTCL         in Varchar2, -- Статья движения
    SPERIOD           in varchar2  -- Мнемокод расчетного периода
  );
  
end UDO_PKG_REVEXPEANALYSIS_XLS;
/

create or replace package body UDO_PKG_REVEXPEANALYSIS_XLS
is
  /* Константы отчета */
  /* Лист ИТОГИ */
  
  SHEET         PKG_STD.tSTRING := 'Данные';                       -- Титульный лист.
  SZAG                PKG_STD.tSTRING := 'Заголовок';              -- Заголовок 
  SZAG_TABL_P         PKG_STD.tSTRING := 'ТБЛПланПоступления'; -- Заголовок таблицы по месячно
  SZAG_TABL_PITOG     PKG_STD.tSTRING := 'ТБЛПоступленияВсего'; -- Заголовок таблицы по месячно
  SZAG_TABL_P1kv      PKG_STD.tSTRING := 'ТБЛПоступления1кв'; -- Заголовок таблицы по месячно
  SZAG_TABL_P2kv      PKG_STD.tSTRING := 'ТБЛПоступления2кв'; -- Заголовок таблицы по месячно
  SZAG_TABL_P3kv      PKG_STD.tSTRING := 'ТБЛПоступления3кв'; -- Заголовок таблицы по месячно
  SZAG_TABL_P4kv      PKG_STD.tSTRING := 'ТБЛПоступления4кв'; -- Заголовок таблицы по месячно
  SZAG_TABL_FP        PKG_STD.tSTRING := 'ТБЛФактПоступления'; -- Заголовок таблицы по месячно
  SZAG_TABL_FOP       PKG_STD.tSTRING := 'ТБЛОстПолучТек'; -- Заголовок таблицы по месячно
  SZAG_TABL_FPpp      PKG_STD.tSTRING := 'ТБЛФактПоступленияПредПериод'; -- Заголовок таблицы по месячно
  SZAG_TABL_V         PKG_STD.tSTRING := 'ТБЛПланВыплаты'; -- Заголовок таблицы по месячно
  SZAG_TABL_VITOG     PKG_STD.tSTRING := 'ТБЛВыплатыВсего'; -- Заголовок таблицы по месячно
  SZAG_TABL_V1kv      PKG_STD.tSTRING := 'ТБЛВыплаты1кв'; -- Заголовок таблицы по месячно
  SZAG_TABL_V2kv      PKG_STD.tSTRING := 'ТБЛВыплаты2кв'; -- Заголовок таблицы по месячно
  SZAG_TABL_V3kv      PKG_STD.tSTRING := 'ТБЛВыплаты3кв'; -- Заголовок таблицы по месячно
  SZAG_TABL_V4kv      PKG_STD.tSTRING := 'ТБЛВыплаты4кв'; -- Заголовок таблицы по месячно
  SZAG_TABL_FV        PKG_STD.tSTRING := 'ТБЛФактВыплатыТек'; -- Заголовок таблицы по месячно
  SZAG_TABL_FFV       PKG_STD.tSTRING := 'ТБЛБудВыплатыТек'; -- Заголовок таблицы по месячно
  SZAG_TABL_FRpp      PKG_STD.tSTRING := 'ТБЛФактРасхродПред'; -- Заголовок таблицы по месячно

  sLINE_DOG           PKG_STD.tSTRING := 'Договор';                -- Линия отчета с данными
  sLINE_STAGES        PKG_STD.tSTRING := 'Этап';                   -- Линия отчета с данными
  sLINE_ITOGPRJ       PKG_STD.tSTRING := 'ИТОГОПРОЕКТ';            -- Линия отчета с данными
  sLINE_VSEGO         PKG_STD.tSTRING := 'ВСЕГО';                  -- Линия отчета с данными
  sLINE_ITOGPRJ_      PKG_STD.tSTRING := 'ИТОГПРОЕКТ';             -- Линия отчета с данными

  iLINE_BEG_D         integer := 7;                                -- Номер начальной строки
  iLINE_BEG_ITOGO     integer := 4;                               -- Номер начальной строки ИТОГИ по заказчикам
  iLINE_BEG_ZI        integer := 2;                               -- Номер начальной строки ИТОГИ по заказчикам
  

  /* Поиск периода */
  function GET_ENPERIOD_CODE
  (
    nFLAG_SMART       in number,        -- признак генерации исключения (0 - да, 1 - нет)
    nFLAG_OPTION      in number,        -- признак генерации исключения для пустого sCODE (0 - да, 1 - нет)
    NCOMPANY          in number,        -- Организация 
    sCODE             in varchar2       -- Мнемокод расчетного периода
  )return             ENPERIOD%rowtype  -- Запись расчетного периода
  is
    RREC              ENPERIOD%rowtype; -- Запись расчетного периода
  begin
    /* мнемокод не задан */
    if (rtrim(sCODE) is null) then
      /* обязательно */
      P_EXCEPTION(nFLAG_OPTION,
                  'Не задан мнемокод расчетного периода.');
    end if;
    /* Поиск записи */
    begin
      select P.*
        into RREC
        from ENPERIOD P
       where P.COMPANY = nCOMPANY
         and P.CODE = sCODE;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(nFLAG_SMART,
                    'Наименование расчетного периода "' || sCODE ||
                    '" не определено.');
    end;
    return RREC;
  end GET_ENPERIOD_CODE;


  /* Запись значения ячеек строки таблицы */
  procedure TABCELL_WRITE
  (
    nCOLUMN           in varchar2,       -- Имя колонки в отчете
    sROW_NAME         in varchar2,       -- Имя строки в отчете
    sVALUE            in varchar2:=null, -- Значение (строка)
    nVALUE            in number:=null    -- Значение (число)
  ) 
  is
   sXLSNAME PKG_STD.tSTRING; -- Имя ячейки на Excel-листе
  begin
    sXLSNAME := nCOLUMN||sROW_NAME;
    PRSG_EXCEL.CELL_DESCRIBE(sXLSNAME); 
   case
      when sVALUE is not null then
        PRSG_EXCEL.CELL_VALUE_WRITE(sXLSNAME, sVALUE);
      when nVALUE is null then
        PRSG_EXCEL.CELL_VALUE_WRITE(sXLSNAME, nVALUE);
      else
        null;
    end case;
 
  end TABCELL_WRITE;


  /* Первичный отбор данных для отчета */ 
  procedure FIND_DATA
  (
    NCOMPANY          in number,   -- Организация
    NFPDARTCL          in number,    -- Рег. номер статьи движения
    DBEG               in date,      -- Дата С
    DEND               in date,      -- Дата По
    nIDENT_DOG         out number,   -- Идентификатор записей договора
    nIDENT_STAGE       out number    -- Идентификатор записей этапой договора
  )
  is
  begin
    nIDENT_DOG   := gen_ident;
    nIDENT_STAGE := gen_ident;
    /* Отбор данных */
    for DATA_STAGE in (select distinct(S.RN)
                         from CONTRACTS C, STAGES S, FACEACC F, FCACPAYPLANS G, UDO_T_MARK P
                        where S.Prn = C.RN
                          and S.FACEACC = F.RN
                          and F.IEELEMENT = NFPDARTCL
                          and G.PRN = F.RN
                          and G.BEGIN_DATE >= DBEG 
                          and G.END_DATE <= DEND 
                          and S.FACEACC = P.FACEACC
                          --and S.BEGIN_DATE between DBEG and DEND
                          --and S.END_DATE >= DBEG
                          and C.COMPANY = NCOMPANY) loop
      /* Сохраним выбранные этапы договоров */
      insert into idlist (id, hid) values (nIDENT_STAGE, DATA_STAGE.RN);
    end loop;
    for DATA_DOG in (select DISTINCT (S.PRN)
                       from STAGES S, idlist i
                      where i.id = nIDENT_STAGE
                        and s.rn = i.hid) loop
      /* Сохраним выбранные договоры */
      insert into idlist (id, hid) values (nIDENT_DOG, DATA_DOG.PRN);
    end loop;
  end FIND_DATA;

  /* Объявление ячеек листа */
  procedure CELL_DESCRIBE_SHEET
  (
    NYEAR             PKG_STD.tNUMBER    -- Год
  )  
  is
    SZAG_RANGE        PKG_STD.tSTRING;     -- Тема, договор
    SZAG_TABL_RANGE   PKG_STD.tSTRING;     -- Период
  begin
    PRSG_EXCEL.SHEET_SELECT(SHEET);
    /* Параметры отчета */
    PRSG_EXCEL.CELL_DESCRIBE(SZAG); 
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_P);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_PITOG);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_P1kv);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_P2kv);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_P3kv);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_P4kv);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_FP);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_FOP);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_FPpp);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_V);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_VITOG);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_V1kv);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_V2kv);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_V3kv);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_V4kv);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_FV);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_FFV);
    PRSG_EXCEL.CELL_DESCRIBE(SZAG_TABL_FRpp);
    
    SZAG_RANGE      := 'Анализ доходов и расходов по тематической деятельности ЗАО НТЦ "Модуль" в '||NYEAR;
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG, SZAG_RANGE);
    
    SZAG_TABL_RANGE := 'Планируемое поступление в '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_P, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'Всего за год '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_PITOG, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'I кв. '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_P1kv, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'II кв. '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_P2kv, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'III кв. '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_P3kv, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'IV кв. '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_P4kv, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'Фактические поступления в '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_FP, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'Остаток к получению в '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_FOP, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'Фактические поступления в '||to_char(NYEAR-1)||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_FPpp, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'Планируемые выплаты в '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_V, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'за год '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_VITOG, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'I кв. '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_V1kv, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'II кв. '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_V2kv, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'III кв. '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_V3kv, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'IV кв. '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_V4kv, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'Фактические выплаты в '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_FV, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'Будущие выплаты в '||NYEAR||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_FFV, SZAG_TABL_RANGE);

    SZAG_TABL_RANGE := 'Фактические расходы в '||to_char(NYEAR-1)||' г.';
    PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_TABL_FRpp, SZAG_TABL_RANGE);
    /* Описание линий отчета */
    PRSG_EXCEL.LINE_DESCRIBE(sLINE_DOG);
    PRSG_EXCEL.LINE_DESCRIBE(sLINE_STAGES);
    PRSG_EXCEL.LINE_DESCRIBE(sLINE_ITOGPRJ);
    PRSG_EXCEL.LINE_DESCRIBE(sLINE_VSEGO);
    PRSG_EXCEL.LINE_DESCRIBE(sLINE_ITOGPRJ_);

  end CELL_DESCRIBE_SHEET;
  /* Заполняем лист данными */
  procedure SHEET_MAKE
  (
    DBEG              in date,      -- Дата С
    DEND              in date,      -- Дата По 
    nIDENT_DOG         in number,   -- Идентификатор записей договора
    nIDENT_STAGE       in number    -- Идентификатор записей этапой договора 
  )  
  is
    DEND_PP           PKG_STD.tLDATE;
    DDAY_PP           PKG_STD.tNUMBER;
    DMONTH_PP         PKG_STD.tNUMBER;
    DYEAR_PP          PKG_STD.tNUMBER;
    NPP               PKG_STD.tNUMBER:=0;  -- Порядковый номер записи контрактов
    NPP_S             PKG_STD.tNUMBER:=0;  -- Порядковый номер записи этапа контрактов
    NPP_ZIJ           PKG_STD.tNUMBER:=0;
    iXLSNAME_D        PKG_STD.tNUMBER;     -- Номер ячейки для Договора
    iXLSNAME_S        PKG_STD.tNUMBER;     -- Номер ячейки для этапа
    iXLSNAMEITOG_DOG  PKG_STD.tNUMBER;     -- Номер ячейки для Итого по договору
    iXLSNAMEITOG_ZAK  PKG_STD.tNUMBER;     -- Номер ячейки для Итого Заказчик
    iXLSNAMEITOG_ZAKJ PKG_STD.tNUMBER;     -- Номер ячейки для Итого Заказчик
    iXLSNAMEITOG_ITOG PKG_STD.tNUMBER;     -- Номер ячейки для ВСЕГО
    nLINE_CONT_D      PKG_STD.tNUMBER;     -- Порядковый номер линии договоров  
    nLINE_CONT_S      PKG_STD.tNUMBER;     -- Порядковый номер линии договоров  
    nLINE_CONT_ZI     PKG_STD.tNUMBER;     -- Порядковый номер линии Итоги Заказ  
    nLINE_CONT_ZIJ    PKG_STD.tNUMBER;     -- Порядковый номер линии Итоги Заказ  
    nLINE_CONT_ITOG   PKG_STD.tNUMBER;     -- Порядковый номер линии ВСЕГО

    NPkv_SUMM_ZAK     PKG_STD.tSUMM:=0;
    N1Pkv_SUMM_ZAK    PKG_STD.tSUMM:=0;
    N2Pkv_SUMM_ZAK    PKG_STD.tSUMM:=0;
    N3Pkv_SUMM_ZAK    PKG_STD.tSUMM:=0;
    N4Pkv_SUMM_ZAK    PKG_STD.tSUMM:=0; 
    NFP_sum_ZAK       PKG_STD.tSUMM:=0;
    NFop_sum_ZAK      PKG_STD.tSUMM:=0;
    NFppp_sum_ZAK     PKG_STD.tSUMM:=0;
    NVkv_SUMM_ZAK     PKG_STD.tSUMM:=0;
    NV1kv_SUMM_ZAK    PKG_STD.tSUMM:=0;
    NV2kv_SUMM_ZAK    PKG_STD.tSUMM:=0;
    NV3kv_SUMM_ZAK    PKG_STD.tSUMM:=0;
    NV4kv_SUMM_ZAK    PKG_STD.tSUMM:=0;
    NFv_SUMM_ZAK      PKG_STD.tSUMM:=0;
    NFfv_SUMM_ZAK     PKG_STD.tSUMM:=0;
    NFrpp_SUMM_ZAK    PKG_STD.tSUMM:=0;
    nIdent_ZAK         PKG_STD.tref;
    NPkv_SUMM_ITOG     PKG_STD.tSUMM:=0;
    N1Pkv_SUMM_ITOG    PKG_STD.tSUMM:=0;
    N2Pkv_SUMM_ITOG    PKG_STD.tSUMM:=0;
    N3Pkv_SUMM_ITOG    PKG_STD.tSUMM:=0;
    N4Pkv_SUMM_ITOG    PKG_STD.tSUMM:=0; 
    NFP_sum_ITOG       PKG_STD.tSUMM:=0;
    NFop_sum_ITOG      PKG_STD.tSUMM:=0;
    NFppp_sum_ITOG     PKG_STD.tSUMM:=0;
    NVkv_SUMM_ITOG     PKG_STD.tSUMM:=0;
    NV1kv_SUMM_ITOG    PKG_STD.tSUMM:=0;
    NV2kv_SUMM_ITOG    PKG_STD.tSUMM:=0;
    NV3kv_SUMM_ITOG    PKG_STD.tSUMM:=0;
    NV4kv_SUMM_ITOG    PKG_STD.tSUMM:=0;
    NFv_SUMM_ITOG     PKG_STD.tSUMM:=0;
    NFfv_SUMM_ITOG     PKG_STD.tSUMM:=0;
    NFrpp_SUMM_ITOG    PKG_STD.tSUMM:=0;

    SCUSTOMERWORKS    PKG_STD.tSTRING;
  begin
    iXLSNAME_S  := 0;
    nIdent_ZAK  := gen_ident;
    DDAY_PP := to_char(DEND,'DD');
    DMONTH_PP := to_char(DEND,'MM');
    DYEAR_PP  := to_char(DEND,'YYYY') - 1;
    DEND_PP := TO_DATE(DDAY_PP||'.'||DMONTH_PP||'.'||DYEAR_PP,'dd.mm.yyyy');
    
    /* Объявление ячеек листа и заполнение заголовка */
    CELL_DESCRIBE_SHEET(to_CHAR(DEND,'YYYY'));
    /* Договоры */
    for data_D in (select C.RN,

                         udo_f_get_doc_prop_val_str('Заказчик работ',
                                                         'Contracts',
                                                         c.rn) CustomerWorks,
                         NVL(CC.CODE,'<null>') sGOVCNTRID,                                
                          UDO_F_GET_USL_NAME(C.RN) Tproject,
                          A.AGNABBR,
                          trim(C.DOC_PREF) || '-' || TRIM(c.doc_numb) NUMDOG,
                          udo_f_get_doc_prop_val_str('Шифр_поБУ','Contracts',c.rn) NUMBU,
                     CC.CODE IGK,
                                                    UDO_F_PRJCONT_DOCPROP(SPROP => 'Сотрудник',
                                                nRN   => c.rn) ClientPersons                     
                     from CONTRACTS C, IDLIST I, GOVCNTRID CC, AGNLIST A
                    where C.RN = I.HID
                      and I.ID = nIDENT_DOG
                      and C.GOVCNTRID = CC.RN(+)
                      and C.Agent = A.RN
                      --and rownum <= 3
                    order by udo_f_get_doc_prop_val_str('Заказчик работ',
                                                            'Contracts',
                                                            c.rn),
                              NVL(CC.CODE,'<null>') asc) loop
     if SCUSTOMERWORKS is not null and SCustomerWorks != NVL(data_D.Customerworks,data_D.SGovcntrid) then 
       nLINE_CONT_ZI := PRSG_EXCEL.LINE_CONTINUE(sLINE_ITOGPRJ);
       iXLSNAMEITOG_ZAK := iXLSNAME_S + 1;
       TABCELL_WRITE('A', iXLSNAMEITOG_ZAK, 'Итого (по Заказчику - '||SCUSTOMERWORKS||')');
       TABCELL_WRITE('F', iXLSNAMEITOG_ZAK, NPkv_SUMM_ZAK);
       TABCELL_WRITE('G', iXLSNAMEITOG_ZAK, N1Pkv_SUMM_ZAK);
       TABCELL_WRITE('H', iXLSNAMEITOG_ZAK, N2Pkv_SUMM_ZAK);        
       TABCELL_WRITE('I', iXLSNAMEITOG_ZAK, N3Pkv_SUMM_ZAK); 
       TABCELL_WRITE('J', iXLSNAMEITOG_ZAK, N4Pkv_SUMM_ZAK);
       TABCELL_WRITE('L', iXLSNAMEITOG_ZAK, NFP_sum_ZAK);
       TABCELL_WRITE('M', iXLSNAMEITOG_ZAK, NFop_sum_ZAK);
       TABCELL_WRITE('N', iXLSNAMEITOG_ZAK, NFppp_sum_ZAK);
       TABCELL_WRITE('O', iXLSNAMEITOG_ZAK, NVkv_SUMM_ZAK);
       TABCELL_WRITE('P', iXLSNAMEITOG_ZAK, NV1kv_SUMM_ZAK);
       TABCELL_WRITE('Q', iXLSNAMEITOG_ZAK, NV2kv_SUMM_ZAK);
       TABCELL_WRITE('R', iXLSNAMEITOG_ZAK, NV3kv_SUMM_ZAK);
       TABCELL_WRITE('S', iXLSNAMEITOG_ZAK, NV4kv_SUMM_ZAK);
       TABCELL_WRITE('T', iXLSNAMEITOG_ZAK, NFv_SUMM_ZAK);
       TABCELL_WRITE('U', iXLSNAMEITOG_ZAK, NFfv_SUMM_ZAK);
       TABCELL_WRITE('V', iXLSNAMEITOG_ZAK, NFrpp_SUMM_ZAK);

       insert into UDO_T_REVEXPEANALYSIS_XLS_TMP(Ident,         
 NAME,
 Pkv_SUM,
 P1kv_SUM,
 P2kv_SUM,
 P3kv_SUM,
 P4kv_SUM,  
 FP_sum,
 Fop_sum,
 Fppp_sum,
 Vkv_SUM,
 V1kv_SUM,
 V2kv_SUM,
 V3kv_SUM,
 V4kv_SUM,
 Fv_SUM,
 Ffv_SUM,
 Frpp_SUM)
 values
 (   nIdent_ZAK,
     'Итого ( по Заказчику - '||SCUSTOMERWORKS||')',
       NPkv_SUMM_ZAK ,
      N1Pkv_SUMM_ZAK,
      N2Pkv_SUMM_ZAK,
      N3Pkv_SUMM_ZAK,
      N4Pkv_SUMM_ZAK, 
      NFP_sum_ZAK,
      NFop_sum_ZAK,
      NFppp_sum_ZAK,
      NVkv_SUMM_ZAK,
      NV1kv_SUMM_ZAK,
      NV2kv_SUMM_ZAK,
      NV3kv_SUMM_ZAK,
      NV4kv_SUMM_ZAK,
      NFv_SUMM_ZAK,
      NFfv_SUMM_ZAK,
      NFrpp_SUMM_ZAK
 ); 
    NPkv_SUMM_ITOG     :=NPkv_SUMM_ITOG + NPkv_SUMM_ZAK;
    N1Pkv_SUMM_ITOG    :=N1Pkv_SUMM_ITOG + N1Pkv_SUMM_ZAK;
    N2Pkv_SUMM_ITOG    :=N2Pkv_SUMM_ITOG + N2Pkv_SUMM_ZAK;
    N3Pkv_SUMM_ITOG    :=N3Pkv_SUMM_ITOG + N3Pkv_SUMM_ZAK;
    N4Pkv_SUMM_ITOG    :=N4Pkv_SUMM_ITOG + N4Pkv_SUMM_ZAK; 
    NFP_sum_ITOG       :=NFP_sum_ITOG + NFP_sum_ZAK; 
    NFop_sum_ITOG      :=NFop_sum_ITOG + NFop_sum_ZAK;
    NFppp_sum_ITOG     :=NFppp_sum_ITOG + NFppp_sum_ZAK;
    NVkv_SUMM_ITOG     :=NVkv_SUMM_ITOG + NVkv_SUMM_ZAK;
    NV1kv_SUMM_ITOG    :=NV1kv_SUMM_ITOG + NV1kv_SUMM_ZAK;
    NV2kv_SUMM_ITOG    :=NV2kv_SUMM_ITOG + NV2kv_SUMM_ZAK;
    NV3kv_SUMM_ITOG    :=NV3kv_SUMM_ITOG + NV3kv_SUMM_ZAK;
    NV4kv_SUMM_ITOG    :=NV4kv_SUMM_ITOG + NV4kv_SUMM_ZAK;
    NFv_SUMM_ITOG      :=NFv_SUMM_ITOG + NFv_SUMM_ZAK;
    NFfv_SUMM_ITOG     :=NFfv_SUMM_ITOG + NFfv_SUMM_ZAK;
    NFrpp_SUMM_ITOG    :=NFrpp_SUMM_ITOG + NFrpp_SUMM_ZAK;

    NPkv_SUMM_ZAK     :=0;
    N1Pkv_SUMM_ZAK    :=0;
    N2Pkv_SUMM_ZAK    :=0;
    N3Pkv_SUMM_ZAK    :=0;
    N4Pkv_SUMM_ZAK    :=0; 
    NFP_sum_ZAK       :=0;
    NFop_sum_ZAK      :=0;
    NFppp_sum_ZAK     :=0;
    NVkv_SUMM_ZAK     :=0;
    NV1kv_SUMM_ZAK    :=0;
    NV2kv_SUMM_ZAK    :=0;
    NV3kv_SUMM_ZAK    :=0;
    NV4kv_SUMM_ZAK    :=0;
    NFv_SUMM_ZAK     :=0;
    NFfv_SUMM_ZAK     :=0;
    NFrpp_SUMM_ZAK    :=0;
     
 
     /*nLINE_CONT_ZIJ := PRSG_EXCEL.LINE_APPEND(sLINE_ITOGPRJ_);
     iXLSNAMEITOG_ZAKJ := iLINE_BEG_ZI + iXLSNAMEITOG_ZAK + 1;
     TABCELL_WRITE('A', iXLSNAMEITOG_ZAKJ, 'Итого (по Заказчику - '||SCUSTOMERWORKS||')');*/

     end if;
      /* Формирование номера строки */
      case NPP
        when 0 then
          nLINE_CONT_D := PRSG_EXCEL.LINE_APPEND(sLINE_DOG);
          NPP          := NPP + 1;
        else
          nLINE_CONT_D := PRSG_EXCEL.LINE_CONTINUE(sLINE_DOG);
          NPP          := NPP + 1;
      end case;
      iXLSNAME_D := iLINE_BEG_D + nLINE_CONT_D + NVL(nLINE_CONT_S ,0)+ nvl(nLINE_CONT_ZI,0);
      TABCELL_WRITE('A', iXLSNAME_D, NVL(data_D.Customerworks,data_D.SGOVCNTRID));
      TABCELL_WRITE('B', iXLSNAME_D, NPP);
      TABCELL_WRITE('C', iXLSNAME_D, data_D.Tproject || '(' ||data_D.AGNABBR /*NVL(data_D.Customerworks,data_D.SGOVCNTRID)*/ || ')');
      TABCELL_WRITE('D', iXLSNAME_D, data_D.Numdog||', заказ '||data_D.NUMBU);
      TABCELL_WRITE('K', iXLSNAME_D, data_D.IGK);
      TABCELL_WRITE('X', iXLSNAME_D, data_D.Clientpersons);

      NPP_S := 0;
      /* Этапы договора */
      SCUSTOMERWORKS := NVL(data_D.Customerworks,data_D.SGovcntrid);
      for data_S in (select TRIM(S.NUMB) NUMB,
       S.DESCRIPTION, 
       To_char(S.END_DATE, 'dd.mm.yyyy') END_DATE,
       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 1, 'Приход', 'План') P1kv,
       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 2, 'Приход', 'План') P2kv,                     
       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 3, 'Приход', 'План') P3kv,                     
       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 4, 'Приход', 'План') P4kv,                    
       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 0, 'Приход', 'Факт') FP,                    

       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 0, 'Приход', 'План')                     
       -
       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 0, 'Приход', 'Факт') FOP,                    
       
       UDO_F_PAYNOTES_SUMWNDS_OLDPP(S.COMPANY,S.FACEACC, DEND_PP,'Приход',0) FPpp,          

       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 1, 'Расход', 'План') V1kv,
       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 2, 'Расход', 'План') V2kv,                     
       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 3, 'Расход', 'План') V3kv,                     
       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 4, 'Расход', 'План') V4kv,                    
       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 0, 'Расход', 'Факт') FV,                    

       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 0, 'Расход', 'План')                     
       -
       UDO_F_UDO_T_MARK_STAGE(S.COMPANY,S.FACEACC,PS.FACEACC,DBEG,DEND, 0, 'Расход', 'Факт') FFV,  
                         
       UDO_F_PAYNOTES_SUMWNDS_OLDPP(S.COMPANY,S.FACEACC, DEND_PP,'Расход',0) FRpp
                       from STAGES S, IDLIST I, PROJECTSTAGE PS
                      where S.RN = I.HID
                        and I.ID = nIDENT_STAGE
                        and S.PRN = data_D.Rn
                        and PS.FACEACCCUST (+) = S.FACEACC
                     --  and S.STATUS = 1
                    order by TRIM(S.NUMB) asc ) loop
/*      case NPP_S
        when 0 then
          nLINE_CONT_S := PRSG_EXCEL.LINE_CONTINUE(sLINE_STAGES);
          NPP_S        := NPP_S + 1;
        else*/
          nLINE_CONT_S := PRSG_EXCEL.LINE_CONTINUE(sLINE_STAGES);
          NPP_S          := NPP_S + 1;
     -- end case;
        
        iXLSNAME_S   := iXLSNAME_D + NPP_S;
         
        TABCELL_WRITE('C', iXLSNAME_S, data_S.Numb);
        TABCELL_WRITE('D', iXLSNAME_S, data_S.Description);
        TABCELL_WRITE('E', iXLSNAME_S, data_S.END_DATE);
        TABCELL_WRITE('F', iXLSNAME_S, data_S.P1kv + data_S.P2kv + data_S.P3kv + data_S.P4kv);
        TABCELL_WRITE('G', iXLSNAME_S, data_S.P1kv);
        TABCELL_WRITE('H', iXLSNAME_S, data_S.P2kv);        
        TABCELL_WRITE('I', iXLSNAME_S, data_S.P3kv); 
        TABCELL_WRITE('J', iXLSNAME_S, data_S.P4kv);
        --TABCELL_WRITE('K', iXLSNAME_S, '');
        TABCELL_WRITE('L', iXLSNAME_S, data_S.FP);
        TABCELL_WRITE('M', iXLSNAME_S, data_S.Fop);
        TABCELL_WRITE('N', iXLSNAME_S, data_S.Fppp);
        TABCELL_WRITE('O', iXLSNAME_S, data_S.V1kv + data_S.V2kv + data_S.V3kv + data_S.V4kv);
        TABCELL_WRITE('P', iXLSNAME_S, data_S.V1kv);
        TABCELL_WRITE('Q', iXLSNAME_S, data_S.V2kv);
        TABCELL_WRITE('R', iXLSNAME_S, data_S.V3kv);
        TABCELL_WRITE('S', iXLSNAME_S, data_S.V4kv);
        TABCELL_WRITE('T', iXLSNAME_S, data_S.Fv);
        TABCELL_WRITE('U', iXLSNAME_S, data_S.Ffv);
        TABCELL_WRITE('V', iXLSNAME_S, data_S.Frpp);

      NPkv_SUMM_ZAK  := NPkv_SUMM_ZAK + data_S.P1kv + data_S.P2kv + data_S.P3kv + data_S.P4kv;
      N1Pkv_SUMM_ZAK := N1Pkv_SUMM_ZAK + data_S.P1kv;
      N2Pkv_SUMM_ZAK := N2Pkv_SUMM_ZAK + data_S.P2kv;
      N3Pkv_SUMM_ZAK := N3Pkv_SUMM_ZAK + data_S.P3kv;
      N4Pkv_SUMM_ZAK := N4Pkv_SUMM_ZAK + data_S.P4kv;  
      NFP_sum_ZAK    := NFP_sum_ZAK + data_S.FP;
      NFop_sum_ZAK   := NFop_sum_ZAK + data_S.Fop;
      NFppp_sum_ZAK  := NFppp_sum_ZAK + data_S.Fppp;
      NVkv_SUMM_ZAK  := NVkv_SUMM_ZAK + data_S.V1kv + data_S.V2kv + data_S.V3kv + data_S.V4kv;
      NV1kv_SUMM_ZAK := NV1kv_SUMM_ZAK + data_S.V1kv;
      NV2kv_SUMM_ZAK := NV2kv_SUMM_ZAK + data_S.V2kv;
      NV3kv_SUMM_ZAK := NV3kv_SUMM_ZAK + data_S.V3kv;
      NV4kv_SUMM_ZAK := NV4kv_SUMM_ZAK + data_S.V4kv;
      NFv_SUMM_ZAK   := NFv_SUMM_ZAK + data_S.Fv;
      NFfv_SUMM_ZAK  := NFfv_SUMM_ZAK + data_S.Ffv;
      NFrpp_SUMM_ZAK := NFrpp_SUMM_ZAK + data_S.Frpp;
      
      
      end loop;
    end loop;
    NPkv_SUMM_ITOG     :=NPkv_SUMM_ITOG + NPkv_SUMM_ZAK;
    N1Pkv_SUMM_ITOG    :=N1Pkv_SUMM_ITOG + N1Pkv_SUMM_ZAK;
    N2Pkv_SUMM_ITOG    :=N2Pkv_SUMM_ITOG + N2Pkv_SUMM_ZAK;
    N3Pkv_SUMM_ITOG    :=N3Pkv_SUMM_ITOG + N3Pkv_SUMM_ZAK;
    N4Pkv_SUMM_ITOG    :=N4Pkv_SUMM_ITOG + N4Pkv_SUMM_ZAK; 
    NFP_sum_ITOG       :=NFP_sum_ITOG + NFP_sum_ZAK; 
    NFop_sum_ITOG      :=NFop_sum_ITOG + NFop_sum_ZAK;
    NFppp_sum_ITOG     :=NFppp_sum_ITOG + NFppp_sum_ZAK;
    NVkv_SUMM_ITOG     :=NVkv_SUMM_ITOG + NVkv_SUMM_ZAK;
    NV1kv_SUMM_ITOG    :=NV1kv_SUMM_ITOG + NV1kv_SUMM_ZAK;
    NV2kv_SUMM_ITOG    :=NV2kv_SUMM_ITOG + NV2kv_SUMM_ZAK;
    NV3kv_SUMM_ITOG    :=NV3kv_SUMM_ITOG + NV3kv_SUMM_ZAK;
    NV4kv_SUMM_ITOG    :=NV4kv_SUMM_ITOG + NV4kv_SUMM_ZAK;
    NFv_SUMM_ITOG      :=NFv_SUMM_ITOG + NFv_SUMM_ZAK;
    NFfv_SUMM_ITOG     :=NFfv_SUMM_ITOG + NFfv_SUMM_ZAK;
    NFrpp_SUMM_ITOG    :=NFrpp_SUMM_ITOG + NFrpp_SUMM_ZAK;
         
       nLINE_CONT_D := PRSG_EXCEL.LINE_CONTINUE(sLINE_ITOGPRJ);
       iXLSNAMEITOG_ZAK := iXLSNAME_S + 1;
       TABCELL_WRITE('A', iXLSNAMEITOG_ZAK, 'Итого ( по Заказчику - '||SCUSTOMERWORKS||')');
       TABCELL_WRITE('F', iXLSNAMEITOG_ZAK, NPkv_SUMM_ZAK);
       TABCELL_WRITE('G', iXLSNAMEITOG_ZAK, N1Pkv_SUMM_ZAK);
       TABCELL_WRITE('H', iXLSNAMEITOG_ZAK, N2Pkv_SUMM_ZAK);        
       TABCELL_WRITE('I', iXLSNAMEITOG_ZAK, N3Pkv_SUMM_ZAK); 
       TABCELL_WRITE('J', iXLSNAMEITOG_ZAK, N4Pkv_SUMM_ZAK);
       TABCELL_WRITE('L', iXLSNAMEITOG_ZAK, NFP_sum_ZAK);
       TABCELL_WRITE('M', iXLSNAMEITOG_ZAK, NFop_sum_ZAK);
       TABCELL_WRITE('N', iXLSNAMEITOG_ZAK, NFppp_sum_ZAK);
       TABCELL_WRITE('O', iXLSNAMEITOG_ZAK, NVkv_SUMM_ZAK);
       TABCELL_WRITE('P', iXLSNAMEITOG_ZAK, NV1kv_SUMM_ZAK);
       TABCELL_WRITE('Q', iXLSNAMEITOG_ZAK, NV2kv_SUMM_ZAK);
       TABCELL_WRITE('R', iXLSNAMEITOG_ZAK, NV3kv_SUMM_ZAK);
       TABCELL_WRITE('S', iXLSNAMEITOG_ZAK, NV4kv_SUMM_ZAK);
       TABCELL_WRITE('T', iXLSNAMEITOG_ZAK, NFv_SUMM_ZAK);
       TABCELL_WRITE('U', iXLSNAMEITOG_ZAK, NFfv_SUMM_ZAK);
       TABCELL_WRITE('V', iXLSNAMEITOG_ZAK, NFrpp_SUMM_ZAK);
       
             insert into UDO_T_REVEXPEANALYSIS_XLS_TMP(Ident,         
       NAME,
       Pkv_SUM,
       P1kv_SUM,
      P2kv_SUM,
      P3kv_SUM,
      P4kv_SUM,  
      FP_sum,
      Fop_sum,
      Fppp_sum,
      Vkv_SUM,
      V1kv_SUM,
      V2kv_SUM,
      V3kv_SUM,
      V4kv_SUM,
      Fv_SUM,
      Ffv_SUM,
      Frpp_SUM)
      values
      (   nIdent_ZAK,
     'Итого ( по Заказчику - '||SCUSTOMERWORKS||')',
       NPkv_SUMM_ZAK ,
      N1Pkv_SUMM_ZAK,
      N2Pkv_SUMM_ZAK,
      N3Pkv_SUMM_ZAK,
      N4Pkv_SUMM_ZAK, 
      NFP_sum_ZAK,
      NFop_sum_ZAK,
      NFppp_sum_ZAK,
      NVkv_SUMM_ZAK,
      NV1kv_SUMM_ZAK,
      NV2kv_SUMM_ZAK,
      NV3kv_SUMM_ZAK,
      NV4kv_SUMM_ZAK,
      NFv_SUMM_ZAK,
      NFfv_SUMM_ZAK,
      NFrpp_SUMM_ZAK
 ); 
       
       nLINE_CONT_ITOG := PRSG_EXCEL.LINE_APPEND(sLINE_VSEGO);
       iXLSNAMEITOG_ITOG := iLINE_BEG_ITOGO + iXLSNAMEITOG_ZAK + 1;
       TABCELL_WRITE('F', iXLSNAMEITOG_ITOG, NPkv_SUMM_ITOG);
       TABCELL_WRITE('G', iXLSNAMEITOG_ITOG, N1Pkv_SUMM_ITOG);
       TABCELL_WRITE('H', iXLSNAMEITOG_ITOG, N2Pkv_SUMM_ITOG);        
       TABCELL_WRITE('I', iXLSNAMEITOG_ITOG, N3Pkv_SUMM_ITOG); 
       TABCELL_WRITE('J', iXLSNAMEITOG_ITOG, N4Pkv_SUMM_ITOG);
       TABCELL_WRITE('L', iXLSNAMEITOG_ITOG, NFP_sum_ITOG);
       TABCELL_WRITE('M', iXLSNAMEITOG_ITOG, NFop_sum_ITOG);
       TABCELL_WRITE('N', iXLSNAMEITOG_ITOG, NFppp_sum_ITOG);
       TABCELL_WRITE('O', iXLSNAMEITOG_ITOG, NVkv_SUMM_ITOG);
       TABCELL_WRITE('P', iXLSNAMEITOG_ITOG, NV1kv_SUMM_ITOG);
       TABCELL_WRITE('Q', iXLSNAMEITOG_ITOG, NV2kv_SUMM_ITOG);
       TABCELL_WRITE('R', iXLSNAMEITOG_ITOG, NV3kv_SUMM_ITOG);
       TABCELL_WRITE('S', iXLSNAMEITOG_ITOG, NV4kv_SUMM_ITOG);
       TABCELL_WRITE('T', iXLSNAMEITOG_ITOG, NFv_SUMM_ITOG);
       TABCELL_WRITE('U', iXLSNAMEITOG_ITOG, NFfv_SUMM_ITOG);
       TABCELL_WRITE('V', iXLSNAMEITOG_ITOG, NFrpp_SUMM_ITOG);
  
      NPP_ZIJ := 0;
       for itogi in (select t.* from UDO_T_REVEXPEANALYSIS_XLS_TMP t where t.ident = nIdent_ZAK)loop
       case NPP_ZIJ
         when 0 then 
       nLINE_CONT_ZIJ := PRSG_EXCEL.LINE_APPEND(sLINE_ITOGPRJ_);
          NPP_ZIJ := NPP_ZIJ +1;
        else
       nLINE_CONT_ZIJ := PRSG_EXCEL.LINE_CONTINUE(sLINE_ITOGPRJ_);
          NPP_ZIJ := NPP_ZIJ +1;
       end case;
       iXLSNAMEITOG_ZAKJ := iLINE_BEG_ZI + iXLSNAMEITOG_ITOG + NPP_ZIJ;
       TABCELL_WRITE('D', iXLSNAMEITOG_ZAKJ, itogi.name);
       TABCELL_WRITE('F', iXLSNAMEITOG_ZAKJ, itogi.pkv_sum);
       TABCELL_WRITE('G', iXLSNAMEITOG_ZAKJ, itogi.p1kv_sum);
       TABCELL_WRITE('H', iXLSNAMEITOG_ZAKJ, itogi.p2kv_sum);        
       TABCELL_WRITE('I', iXLSNAMEITOG_ZAKJ, itogi.p3kv_sum); 
       TABCELL_WRITE('J', iXLSNAMEITOG_ZAKJ, itogi.p4kv_sum);
       TABCELL_WRITE('L', iXLSNAMEITOG_ZAKJ, itogi.fp_sum);
       TABCELL_WRITE('M', iXLSNAMEITOG_ZAKJ, itogi.fop_sum);
       TABCELL_WRITE('N', iXLSNAMEITOG_ZAKJ, itogi.fppp_sum);
       TABCELL_WRITE('O', iXLSNAMEITOG_ZAKJ, itogi.vkv_sum);
       TABCELL_WRITE('P', iXLSNAMEITOG_ZAKJ, itogi.v1kv_sum);
       TABCELL_WRITE('Q', iXLSNAMEITOG_ZAKJ, itogi.v2kv_sum);
       TABCELL_WRITE('R', iXLSNAMEITOG_ZAKJ, itogi.v3kv_sum);
       TABCELL_WRITE('S', iXLSNAMEITOG_ZAKJ, itogi.v4kv_sum);
       TABCELL_WRITE('T', iXLSNAMEITOG_ZAKJ, itogi.fv_sum);
       TABCELL_WRITE('U', iXLSNAMEITOG_ZAKJ, itogi.ffv_sum);
       TABCELL_WRITE('V', iXLSNAMEITOG_ZAKJ, itogi.frpp_sum);
       
       
       end loop;
      
       delete UDO_T_REVEXPEANALYSIS_XLS_TMP t where t.ident = nIdent_ZAK;
       PRSG_EXCEL.LINE_DELETE(sLINE_DOG);
       PRSG_EXCEL.LINE_DELETE(sLINE_STAGES);
       PRSG_EXCEL.LINE_DELETE(sLINE_ITOGPRJ);
       PRSG_EXCEL.LINE_DELETE(sLINE_VSEGO);
       PRSG_EXCEL.LINE_DELETE(sLINE_ITOGPRJ_);
       
  end SHEET_MAKE;

  /* Формирование отчет */
  procedure XLS_MAKE
  (
    NCOMPANY          in number,   -- Организация
    SFPDARTCL         in Varchar2, -- Статья движения
    SPERIOD           in varchar2  -- Мнемокод расчетного периода
  )  
  is
    RENPERIOD         ENPERIOD%rowtype; -- Запись расчетного периода
    NFPDARTCL         PKG_STD.tREF;      -- Рег. номер статьи движения
    nIDENT_DOG        PKG_STD.tNUMBER;   -- Идентификатор записей договора
    nIDENT_STAGE      PKG_STD.tNUMBER;   -- Идентификатор записей этапой договора
  begin

  /* Поиск периода */
  RENPERIOD := GET_ENPERIOD_CODE
  (
    nFLAG_SMART       => 0,   
    nFLAG_OPTION      => 0,   
    NCOMPANY          => NCOMPANY,        
    sCODE             => SPERIOD      
  ); 

  /* Проверка периода */
    if RENPERIOD.PERTYPE != 3 then
      P_EXCEPTION(0, 'Тип выбранного периода должен быть "Год"');
    else
 
  /* Поиск записи элемента дохода и расхода, статьи затрат по мнемокоду. */
  FIND_FPDARTCL_CODE
   (
  nFLAG_SMART  => 0,   
  nCOMPANY     => NCOMPANY, 
  sCODE        => SFPDARTCL, 
  nRN          => NFPDARTCL     
   );  
  
  
   /* Первичный отбор данных для отчета */ 
  FIND_DATA
 (
  NCOMPANY          => NCOMPANY,       -- Организация
  NFPDARTCL         => NFPDARTCL,      -- Рег. номер статьи движения
  DBEG              => RENPERIOD.STARTDATE,           -- Дата С
  DEND              => RENPERIOD.ENDDATE,           -- Дата По
  nIDENT_DOG        => nIDENT_DOG,     -- Идентификатор записей договора
  nIDENT_STAGE      => nIDENT_STAGE    -- Идентификатор записей этапой договора
 );
  /* Заполнение листа данными */  
  SHEET_MAKE
  (
  DBEG              => RENPERIOD.STARTDATE,           -- Дата С
  DEND              => RENPERIOD.ENDDATE,           -- Дата По
  nIDENT_DOG        => nIDENT_DOG,     -- Идентификатор записей договора
  nIDENT_STAGE      => nIDENT_STAGE    -- Идентификатор записей этапой договора
  ); 
  
    end if;
  end XLS_MAKE;

end UDO_PKG_REVEXPEANALYSIS_XLS;
/

