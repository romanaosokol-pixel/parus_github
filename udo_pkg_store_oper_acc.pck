create or replace package UDO_PKG_STORE_OPER_ACC is

  --create public synonym udo_pkg_store_oper_acc for udo_pkg_store_oper_acc;
  --grant execute on udo_pkg_store_oper_acc to public;
  -- Author  : Анненко И.С.
  -- Created : 01.02.2016 15:11:55
  -- Purpose : Складской учет
  -- Public type declarations
  --type <TypeName> is <Datatype>;
  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;
  -- Public variable declarations
  --<VariableName> <Datatype>;
  -- Public function and procedure declarations
  /*Функция возвращает дату поступления указанной партии на указанный склад*/
  function F_CALC_PARTY_IN_DATE(NCOMPANY in number /*Организация*/,
                                NPARTY   in GOODSPARTIES.RN%type /*Регистрационный номер партии*/,
                                NSTORE   in AZSAZSLISTMT.RN%type /*Склад*/)
    return date;

  /*Функция возвращает учетную цену указанной номенклатуры*/
  function F_DICNOMNS_CALC_PRICE(NCOMPANY    in number /*Организация*/,
                                 SNOMEN      in DICNOMNS.NOMEN_CODE%type /*Код номенклатуры*/,
                                 DPRICE_DATE in date /*На дату*/)
    return number;

  /*Выполняем базовое добавление приходного ордера*/
  procedure p_inorders_base_insert(rinorders in inorders%rowtype /*Атрибуты записи*/,
                                   nrn       out inorders.rn%type /*Регистрационный номер записи*/);

  /*Процедура выолняет базовое добавление строки приходного ордера*/
  procedure p_inorderspecs_base_insert(rinorderspecs in inorderspecs%rowtype /*Атрибуты записи*/,
                                       nrn           out inorderspecs.rn%type /*Регистрационный номер записи*/);

  /*Процедура выполняет добавление прихода из подразделения*/
  procedure P_INSERT_INCOMEFROMDEPS(RINCOMEFROMDEPS   in INCOMEFROMDEPS%rowtype /*Атрибуты прихода из подразделения*/,
                                    NRNINCOMEFROMDEPS out INCOMEFROMDEPS.RN%type /*Регистрационный номер прихода из подразделения*/);

  /*Процедура выполняет добавление спецификации прихода из подразделения*/
  procedure P_INSERT_INCOMEFROMDEPSSPEC(RINCOMEFROMDEPSSPEC   in INCOMEFROMDEPSSPEC%rowtype /*Атрибуты спецификации прихода из подразделения*/,
                                        NRNINCOMEFROMDEPSSPEC out INCOMEFROMDEPSSPEC.RN%type /*Регистрационный номер спецификации прихода из подразделения*/);

  /*Процедура выполняет добавление РНОвП*/
  procedure P_INSERT_TRANSINVDEPT(RTRANSINVDEPT   in TRANSINVDEPT%rowtype /*Атрибуты РНОвП*/,
                                  NRNTRANSINVDEPT out TRANSINVDEPT.RN%type /*Регистрационный номер РНОвП*/);

  /*Процедура выполняет добавление спецификации РНОвП*/
  procedure P_INSERT_TRANSINVDEPTSPECS(RTRANSINVDEPTSPECS   in TRANSINVDEPTSPECS%rowtype /*Атрибуты спецификации РНОвП*/,
                                       NRNTRANSINVDEPTSPECS out TRANSINVDEPTSPECS.RN%type /*Регистрационный номер спецификации РНОвП*/);

  /*Процедура выполняет добавление акта списания*/
  procedure P_INSERT_WROFFACTS(RWROFFACTS   in WROFFACTS%rowtype /*Атрибуты акта списания*/,
                               NRNWROFFACTS out WROFFACTS.RN%type /*Регистрационный номер акта списания*/);

  /*Процедура выполняет добавление спецификации акта списания*/
  procedure P_INSERT_WROFFACTSPECS(RWROFFACTSPECS   in WROFFACTSPECS%rowtype /*Атрибуты спецификации акта списания*/,
                                   NRNWROFFACTSPECS out WROFFACTSPECS.RN%type /*Регистрационный номер спецификации акта списания*/);

  /*Процедура устанавливает атрибуты инициализации прихода из подразделения*/
  procedure P_INCOMEFROMDEPS_INIT_PARAMS(RINCOMEFROMDEPSINIT out INCOMEFROMDEPS%rowtype /*Атрибуты прихода из подразделений*/);

  /*Процедура устанавливает атрибуты инициализации спецификации прихода из подразделения*/
  procedure P_INCOMEFROMDEPSSP_INIT_PARAMS(RINCOMEFROMDEPSSPECINIT out INCOMEFROMDEPSSPEC%rowtype /*Атрибуты строки прихода из подразделений*/);

  /*Процедура устанавливает атрибуты инициализации РНОвП*/
  procedure P_TRANSINVDEPT_INIT_PARAMS(RTRANSINVDEPTINIT out TRANSINVDEPT%rowtype /*Атрибуты РНОвП*/);

  /*Процедура устанавливает атрибуты инициализации спецификации РНОвП*/
  procedure P_TRANSINVDEPTSPECS_INIT_PARS(RTRANSINVDEPTSPECSINIT out TRANSINVDEPTSPECS%rowtype /*Атрибуты строки РНОвП*/);

  /*Процедура устанавливает атрибуты инициализации акта списания*/
  procedure P_WROFFACTS_INIT_PARAMS(RWROFFACTSINIT out WROFFACTS%rowtype /*Атрибуты акта списания*/);

  /*Процедура устанавливает атрибуты инициализации спецификации акта списания*/
  procedure P_WROFFACTSPECS_INIT_PARAMS(RWROFFACTSPECSINIT out WROFFACTSPECS%rowtype /*Атрибуты строки акта списания*/);

  /*Функция возвращает наименование номенклатуры*/
  function F_DICNOMNS_GET_NAME(SCODE in varchar2 /*Код номенклатуры*/)
    return DICNOMNS.NOMEN_NAME%type;

  /*Процедура определяет МОЛ склада*/
  procedure P_STORE_GET_AGENT(NRNSTORE in AZSAZSLISTMT.RN%type /*Склад*/,
                              NRNAGENT out AZSAZSLISTMT.AZS_AGENT%type /*МОЛ*/);

  /*Процедура определяет подразделение склада*/
  procedure P_STORE_GET_DEP(NRNSTORE in AZSAZSLISTMT.RN%type /*Склад*/,
                            NRNDEP   out INS_DEPARTMENT.RN%type /*Подразделение*/);

  /*Процедура определяет код основной единицы измерения указанной номенклатуры*/
  procedure P_DICNOMNS_CALC_UMEAS_MAIN(SNOMEN in DICNOMNS.NOMEN_CODE%type /*Номенклатура*/,
                                       SMUNIT out DICMUNTS.MEAS_MNEMO%type /*Единица измерения*/);

  /*Процедура определяет модификацию указанной номенклатуры*/
  procedure P_DICNOMNS_CALC_MODIF(SNOMEN     in DICNOMNS.NOMEN_CODE%type /*Номенклатура*/,
                                  SMODIF     out NOMMODIF.MODIF_CODE%type /*Модификация*/,
                                  SMODIFNAME out NOMMODIF.MODIF_NAME%type /*Наименование модификации*/);

  /*Процедура определяет склад с указанным видом для указанного подразделения*/
  procedure P_INS_DEP_SEARCH_STORE_TYPE(NRNDEP   in INS_DEPARTMENT.RN%type /*Подразделение*/,
                                        NTYPE    in STKIND.RN%type /*Вид склада*/,
                                        NRNSTORE out AZSAZSLISTMT.RN%type /*Склад*/);

  /*Функция определяет статью затрат для указанной модификации номенклатуры*/
  function F_NOMMODIF_CALC_ARTICLE(NCOMPANY in number /*Организация*/,
                                   NRN      in NOMMODIF.RN%type /*Регистрационный номер записи*/)
    return FPDARTCL.CODE%type;

  /*Процедура выполняет установку заказа в приход из подразделений*/
  procedure P_INCOMEFROMDEPS_SET_PR_ORDER(NCOMPANY    in number,
                                          NRN         in number,
                                          SPROD_ORDER in varchar2);

  /*Процедура выполняет резервирование указанной строки расходной накладной*/
  procedure P_TRANSINVDEPTSP_BASE_RES(NCOMPANY     in number, -- организация    
                                      NRN          in number, -- RN спецификации расходной накладной
                                      NSIGN_WARN   in number, -- признак генерации предупреждений (0-нет, 1-да)
                                      NSIGNSTORE   in number /*Признак склада: -1 - отправитель, 1 - получатель*/,
                                      DRES_DATE    in out date, -- дата и время резервирования
                                      DRES_DATE_TO in date -- дата резервирования до
                                      );

  /*Процедура выполняет отмену резервирования указанной строки расходной накладной*/
  procedure P_TRANSINVDEPTSP_BASE_RES_CAN(NCOMPANY     in number, -- организация
                                          NRN          in number, -- RN спецификации расходной накладной
                                          NSIGN_WARN   in number, -- признак генерации предупреждений (0-нет, 1-да)
                                          NSIGNSTORE   in number /*Признак склада: -1 - отправитель, 1 - получатель*/,
                                          DRES_DATE    in out date, -- дата и время резервирования
                                          DRES_DATE_TO in date -- дата резервирования до   
                                          );

  /*Процедура выполняет резервирование для указанной расходной накладной*/
  procedure P_TRANSINVDEPT_BASE_RESERV(NCOMPANY     in number, -- организация.
                                       NRN          in number, -- RN накладной
                                       NSIGN_WARN   in number, -- признак генерации предупреждений
                                       NSIGNSTORE   in number /*Признак склада: -1 - отправитель, 1 - получатель*/,
                                       DRES_DATE    in out date, -- дата и время резервирования
                                       DRES_DATE_TO in date -- дата резервирования до
                                       );

  /*Процедура выполняет отмену резервирования для указанной расходной накладной*/
  procedure P_TRANSINVDEPT_BASE_RESERV_CAN(NCOMPANY     in number, -- организация.
                                           NRN          in number, -- RN накладной    
                                           NSIGN_WARN   in number, -- признак генерации предупреждений
                                           NSIGNSTORE   in number /*Признак склада: -1 - отправитель, 1 - получатель*/,
                                           DRES_DATE    in out date, -- дата и время резервирования
                                           DRES_DATE_TO in out date -- дата резервирования до
                                           );

  /*Процедура выполняет резервирование указанного акта списания*/
  procedure P_WROFFACTS_BASE_RESERV(NCOMPANY     in number /*Регистрационный номер организации*/,
                                    NRN          in WROFFACTS.RN%type /*Регистрационный номер записи*/,
                                    NSIGN_WARN   in number /*признак генерации предупреждений*/,
                                    DRES_DATE    in out date /*дата и время резервирования*/,
                                    DRES_DATE_TO in date /*дата резервирования до*/);

  /*Процедура выполняет отмену резервирования указанного акта списания*/
  procedure P_WROFFACTS_BASE_RESERV_CANCEL(NCOMPANY     in number /*Регистрационный номер организации*/,
                                           NRN          in WROFFACTS.RN%type /*Регистрационный номер записи*/,
                                           NSIGN_WARN   in number /*признак генерации предупреждений*/,
                                           DRES_DATE    in out date /*дата и время резервирования*/,
                                           DRES_DATE_TO in date /*дата резервирования до*/);

  /*Функция определяет минимальный остаток в истории изменений товарного запаса в указанном интервале времени*/
  function F_GOODSSUPPLYHIST_CALC_ReST(NPRN      in GOODSSUPPLYHIST.PRN%type /*Регистрационный номер товарного запаса*/,
                                       DDATE     in date /*Дата*/,
                                       NMUNIT    in number /*Признак ЕИ*/,
                                       nsign_res in number /*Признак резерва*/)
    return PKG_STD.TQUANT;

  /*Функция определяет минимальный остаток в истории изменений товарного запаса в указанном интервале времени*/
  function F_GOODSSUPPLYHIST_CALC_MIN_RST(NPRN       in GOODSSUPPLYHIST.PRN%type /*Регистрационный номер товарного запаса*/,
                                          DDATEBEGIN in date /*Дата начала периода*/,
                                          DDATEEND   in date /*Дата окончания периода*/,
                                          NMUNIT     in number /*Признак ЕИ*/,
                                          nsign_res  in number /*Признак резерва*/)
    return PKG_STD.TQUANT;

  /*Функция определяет признак изменения заказа для указанной расходной накладной*/
  /*function F_TRANSINVDEPT_CLC_SGN_NEW_ORD
  (
    NCOMPANY    in number \*Организация*\
   ,NRN         in TRANSINVDEPT.RN%type \*Регистрационный номер записи*\
   ,NCHECKSTATE in number \*Признак необходимости проверки ГОЗ*\
  ) return number;*/

  /*Процедура выполняет установку приходной партии для указанной расходной накладной на отпуск в подразделения*/
  procedure P_TRANSINVDEPT_SET_IN_PATY(NCOMPANY in number /*Организация*/,
                                       NRN      in TRANSINVDEPT.RN%type /*Регистрационный номер записи*/,
                                       SPARTY   in TRANSINVDEPT.IN_PARTY_CODE%type /*Партия*/);

  /*Процедура выполняет установку партии источника для партий указанной расходной накладной*/
  /*procedure P_TRANSINVDEPT_SET_P_ORD_MOVE
  (
    NCOMPANY in number \*Организация*\
   ,NRN      in TRANSINVDEPT.RN%type \*Регистрационный номер записи*\
  );*/

  /*Процедура выполняет базовое формирование требования на выдачу материала*/
  /*procedure P_TRANSINVDEPT_BCREATE_INV_MAT
  (
    NCOMPANY      in number \*Организация*\
   ,NCRN          in TRANSINVDEPT.CRN%type \*Каталог*\
   ,NJUR_PERS     in TRANSINVDEPT.JUR_PERS%type \*Регистрационный номер юридического лица*\
   ,NTYPE         in TRANSINVDEPT.DOCTYPE%type \*Тип*\
   ,SNUMBER       in TRANSINVDEPT.NUMB%type \*Номер*\
   ,DDATE         in TRANSINVDEPT.DOCDATE%type \*Дата*\
   ,NSTOREOUT     in TRANSINVDEPT.STORE%type \*Склад расхода*\
   ,NSTOREOPEROUT in TRANSINVDEPT.STOPER%type \*Складская операция расхода*\
   ,NSTOREIN      in TRANSINVDEPT.IN_STORE%type \*Склад прихода*\
   ,NDEP          in TRANSINVDEPT.SUBDIV%type \*Подразделение*\
   ,NORDER        in TRANSINVDEPT.FACEACC%type \*Заказ*\
   ,SPARTY        in TRANSINVDEPT.IN_PARTY_CODE%type \*Партия*\
   ,
    \*Документ-основание*\NVALID_DOCTYPE in TRANSINVDEPT.VALID_DOCTYPE%type
   ,SVALID_DOCNUMB in TRANSINVDEPT.VALID_DOCNUMB%type
   ,DVALID_DOCDATE in TRANSINVDEPT.VALID_DOCDATE%type
   ,NMODIF         in TRANSINVDEPTSPECS.NOMMODIF%type \*Модификация*\
   ,NQUANT         in TRANSINVDEPTSPECS.QUANT%type \*Количество*\
   ,NRNINV         out TRANSINVDEPT.RN%type \*Регистрационный номер записи*\
  );*/

  /*Процедура выполняет формирование требования на выдачу материала*/
  procedure P_TRANSINVDEPT_CREATE_INV_MAT(NCOMPANY      in number /*Организация*/,
                                          STYPE         in DOCTYPES.DOCCODE%type /*Тип*/,
                                          SNUMBER       in TRANSINVDEPT.NUMB%type /*Номер*/,
                                          DDATE         in TRANSINVDEPT.DOCDATE%type /*Дата*/,
                                          SSTOREOUT     in AZSAZSLISTMT.AZS_NUMBER%type /*Склад расхода*/,
                                          SSTOREOPEROUT in AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type /*Складская операция расхода*/,
                                          SSTOREIN      in AZSAZSLISTMT.AZS_NUMBER%type /*Склад прихода*/,
                                          SDEP          in INS_DEPARTMENT.CODE%type /*Подразделение*/,
                                          SORDER        in FACEACC.NUMB%type /*Заказ*/,
                                          SNOMEN        in DICNOMNS.NOMEN_CODE%type /*Номенклатура*/,
                                          SNOMENNAME    in DICNOMNS.NOMEN_NAME%type /*Наименование номенклатуры*/,
                                          SMODIF        in NOMMODIF.MODIF_CODE%type /*Модификация*/,
                                          SMODIFNAME    in NOMMODIF.MODIF_NAME%type /*Наименование модификации*/,
                                          NQUANT        in TRANSINVDEPTSPECS.QUANT%type /*Количество*/,
                                          SMUNIT        in DICMUNTS.MEAS_MNEMO%type /*Единица измерения*/,
                                          NRNINV        out TRANSINVDEPT.RN%type /*Регистрационный номер записи*/);

  /*Функция определяет учетную цену*/
  function F_REGPRICE_CALCULATE(NCOMPANY in number /*Организация*/,
                                NRN      in GOODSSUPPLY.RN%type /*Регистрационный номер записи*/,
                                DDATE    in date /*Дата*/)
    return REGPRICE.PRICE%type;

  /*Функция определяет учетную цену*/
  function F_REGPRICE_CALCULATE(NCOMPANY in number /*Организация*/,
                                NRN      in GOODSPARTIES.RN%type /*Регистрационный номер записи*/,
                                NRNSTORE in AZSAZSLISTMT.RN%type /*Склад*/,
                                DDATE    in date /*Дата*/)
    return REGPRICE.PRICE%type;

  function f_overheads_calc_price(NCOMPANY in number /*Организация*/,
                                  NRN      in GOODSSUPPLY.RN%type /*Регистрационный номер записи*/,
                                  DDATE    in date /*Дата*/) return number;

  /*Функция определяет признак нулевого склада для указанного остатка*/
  function F_GOODSSUPPLY_CALC_ZERO_SIGN(NCOMPANY in number /*Организация*/,
                                        NRN      in GOODSSUPPLY.RN%type /*Регистрационный номер записи*/,
                                        NREC     in number /*Уровень рекурсии*/)
    return number;

  /*Процедура выполняет удаление партии перед отработкой расходной накладной*/
  procedure P_TRANSINVDEPT_REMOVE_IN_PARTY(NCOMPANY in number /*Организация*/,
                                           NRN      in TRANSINVDEPT.RN%type /*Регистрационный номер записи*/);

  /*Функция возвращает признак необходимости формирования документа списания партии на СГП*/
  function F_INCOMEFROMDEPS_CLC_SGN_CRT_I(NCOMPANY in number /*Организация*/,
                                          NRN      in number /*Регистрационный номер записи*/)
    return number;

  /*Процедура выполняет формирование расходной накладной для указанного прихода из подразделений*/
  /*procedure P_INCOMEFROMDEPS_SGP_CRT_INV
  (
    NCOMPANY in number \*Организация*\
   ,NRN      in INCOMEFROMDEPS.RN%type \*Регистрационный номер записи*\
  );*/

  /*Процедура выполняет расформирование расходной накладной для указанного прихода из подразделений*/
  /*procedure P_INCOMEFROMDEPS_SGP_RMV_INV
  (
    NCOMPANY in number \*Организация*\
   ,NRN      in INCOMEFROMDEPS.RN%type \*Регистрационный номер записи*\
  );*/

  /*Процедура выполняет формирование приходного документа для указанной расходной накладной*/
  /*procedure P_TRANSINVDEPT_CREATE_INDOC
  (
    NCOMPANY  in number \*Регистрационный номер организации*\
   ,NRN       in number \*Регистрационный номер записи*\
   ,SCATALOG  in ACATALOG.NAME%type \*Каталог*\
   ,SNOMEN    in DICNOMNS.NOMEN_CODE%type \*Номенклатура*\
   ,NPRICE    in number \*Цена*\
   ,NRN_INDOC out number \*Регистрационный номер записи приходного документа*\
  );*/

  /*Процедура выполняет формирование приходного документа для указанной расходной накладной*/
  procedure P_TRANSINVCUST_CREATE_INDOC(NCOMPANY    in number /*Организация*/,
                                        NRN         in TRANSINVCUST.RN%type /*Регистрационный номер записи*/,
                                        SCATALOG    in ACATALOG.NAME%type /*Каталог*/,
                                        NRN_INC_SGP out INCOMEFROMDEPS.RN%type /*Регистрационный номер прихода*/);

  /*Процедура выполняет расформирование приходного документа для указанной расходной накладной*/
  procedure P_TRANSINVCUST_REMOVE_INDOC(NCOMPANY in number /*Организация*/,
                                        NRN      in TRANSINVCUST.RN%type /*Регистрационный номер записи*/);

  /*Функция возвращает признак давальческой схемы для указанной партии*/
  function f_goodsparties_calc_sign_proc(ncompany in number /*Организация*/,
                                         nrn      in number /*Регистрационный номер записи*/)
    return number;

  /*Функция возвращает МВЗ по давальческой схеме для указанной партии*/
  function f_goodsparties_calc_cpl_proc(ncompany in number /*Организация*/,
                                        nrn      in number /*Регистрационный номер записи*/)
    return number;

  /*Функция возвращает цену по давальческой схеме для указанной партии*/
  function f_goodsparties_calc_price_proc(ncompany in number /*Организация*/,
                                          nrn      in number /*Регистрационный номер записи*/)
    return number;

  /*Функция возвращает цену по давальческой схеме для указанной партии*/
  function f_goodsparties_calc_price_pr_a(ncompany in number /*Организация*/,
                                          nrn      in number /*Регистрационный номер записи*/,
                                          nARTICLE in number /*Регистрационный номер записи статьи затрат*/)
    return number;

  /*Процедура очищает таблицу выбора партий*/
  --procedure P_GOODSSUPPLY_SELECT_CLEAR;

  /*Процедура заполняет таблицу выбора партий*/
  /*procedure P_GOODSSUPPLY_SELECT_FILL
  (
    NCOMPANY in number \*Организация*\
   ,NRNMODIF in NOMMODIF.RN%type \*Модификация*\
   ,NRNSTORE in AZSAZSLISTMT.RN%type \*Склад расхода*\
   ,DDATE    in date \*Дата*\
   ,nREPLACE in number default 0 \* с учетом возможных замен по матресурсу: 0 - нет; 1 - да *\
  );*/

  /*Функция определяет признак ГОЗ для указанной темы*/
  function f_theme_calc_sign_goz(nflag_smart in number /*Признак генерации исключения*/,
                                 NCOMPANY    in number /*Организация*/,
                                 NRN         in number /* RN проекта/договора */)
    return number;

  /*Функция определяет признак ГОЗ для указанного лицевого счета*/
  function f_faceacc_calc_sign_goz(nflag_smart in number /*Признак генерации исключения*/,
                                   NCOMPANY    in number /*Организация*/,
                                   nrn         in number /*Регистрационный номер записи*/)
    return number;

  /*Процедура выполняет базовое формирование документа перевода в свободный остаток*/
  procedure P_TRANSINVDEPT_bCRT_free_rest(NCOMPANY  in number /*Организация*/,
                                          DDATE     in TRANSINVDEPT.DOCDATE%type /*Дата*/,
                                          nident    in number /*Идентификатор отмеченных записей*/,
                                          nrn       in number /*Регистрационный номер записи товарного запаса*/,
                                          NQUANT    in TRANSINVDEPTSPECS.QUANT%type /*Количество*/,
                                          NQUANTalt in TRANSINVDEPTSPECS.QUANTalt%type /*Количество ДЕИ*/,
                                          NRNINV    out TRANSINVDEPT.RN%type /*Регистрационный номер записи*/);

  /*Процедура выполняет базовое формирование документа перевода в свободный остаток*/
  procedure P_TRANSINVDEPT_CRT_free_rest(NCOMPANY in number /*Организация*/,
                                         ncrn     in number /*Каталог*/,
                                         DDATE    in TRANSINVDEPT.DOCDATE%type /*Дата*/,
                                         stheme   in varchar2 /*Тема*/,
                                         NRNINV   out TRANSINVDEPT.RN%type /*Регистрационный номер записи*/);

end UDO_PKG_STORE_OPER_ACC;
/
create or replace package body UDO_PKG_STORE_OPER_ACC is

  -- Private type declarations
  --type <TypeName> is <Datatype>;
  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;
  -- Private variable declarations
  --<VariableName> <Datatype>;
  -- Function and procedure implementations
  /*Функция возвращает дату поступления указанной партии на указанный склад*/
  function F_CALC_PARTY_IN_DATE(NCOMPANY in number /*Организация*/,
                                NPARTY   in GOODSPARTIES.RN%type /*Регистрационный номер партии*/,
                                NSTORE   in AZSAZSLISTMT.RN%type /*Склад*/)
    return date is
    /*Регистрационный номер записи товарного запаса*/
    NSUPPLY GOODSSUPPLY.RN%type;
    /*Дата поступления*/
    DIN_DATE date;
  begin
    /*Регистрационный номер записи товарного запаса*/
    FIND_GOODSSUPPLY_BY_STORE(NCOMPANY    => NCOMPANY,
                              NFLAG_SMART => 0,
                              NPRN        => NPARTY,
                              SSTORE      => F_DICSTORE_GET_NUMB(NSTORE => NSTORE),
                              NRN         => NSUPPLY);
    /*Дата поступления*/
    select max(J.OPERDATE)
      into DIN_DATE
      from STOREOPERJOURN J
     where J.GOODSSUPPLY = NSUPPLY
       and J.OPER_TYPE = 1;
    /*Возвращаем результат*/
    return(DIN_DATE);
  end F_CALC_PARTY_IN_DATE;

  /*Функция возвращает учетную цену указанной номенклатуры*/
  function F_DICNOMNS_CALC_PRICE(NCOMPANY    in number /*Организация*/,
                                 SNOMEN      in DICNOMNS.NOMEN_CODE%type /*Код номенклатуры*/,
                                 DPRICE_DATE in date /*На дату*/)
    return number is
    NNOMEN       DICNOMNS.RN%type;
    NTMP         number;
    NACNT_BPRICE number;
  begin
    FIND_DICNOMNS_CODE(NFLAG_SMART  => 1,
                       NFLAG_OPTION => 1,
                       NCOMPANY     => NCOMPANY,
                       SCODE        => SNOMEN,
                       NRN          => NNOMEN);
    FIND_NOMENCLATURE_PRICE(NFLAG_MODE    => 0,
                            NCOMPANY      => NCOMPANY,
                            NNOMEN        => NNOMEN,
                            DPRICE_DATE   => DPRICE_DATE,
                            NBALUNIT      => TO_NUMBER(null),
                            NIN_CURRENCY  => F_CURBASE_GET_RN(NFLAG_SMART => 0,
                                                              NCOMPANY    => NCOMPANY),
                            NPF_TYPE      => 1,
                            NIN_MS_TYPE   => 0,
                            NRN           => NTMP,
                            NOUT_CURRENCY => NTMP,
                            NACNT_PRICE   => NTMP,
                            NACNT_BPRICE  => NACNT_BPRICE,
                            NCTRL_PRICE   => NTMP,
                            NCTRL_BPRICE  => NTMP,
                            NOUT_MS_TYPE  => NTMP,
                            NREG_STATE    => TO_NUMBER(null),
                            NNOMMODIF     => TO_NUMBER(null));
    return(NVL(NACNT_BPRICE, 0));
  end F_DICNOMNS_CALC_PRICE;

  /*Выполняем базовое добавление приходного ордера*/
  procedure p_inorders_base_insert(rinorders in inorders%rowtype /*Атрибуты записи*/,
                                   nrn       out inorders.rn%type /*Регистрационный номер записи*/) is
  begin
    parus.p_inorders_base_insert(ncompany       => rinorders.company,
                                 ncrn           => rinorders.crn,
                                 njur_pers      => rinorders.jur_pers,
                                 ncontragent    => rinorders.contragent,
                                 nfaceacc       => rinorders.faceacc,
                                 ngraphpoint    => rinorders.graphpoint,
                                 sparty_code    => rinorders.party_code,
                                 nparty         => rinorders.party,
                                 nstore         => rinorders.store,
                                 nstopertype    => rinorders.stopertype,
                                 nindoctype     => rinorders.indoctype,
                                 sindocpref     => rinorders.indocpref,
                                 sindocnumb     => rinorders.indocnumb,
                                 dindocdate     => rinorders.indocdate,
                                 ndirectdoctype => rinorders.directdoctype,
                                 sdirectdocnumb => rinorders.directdocnumb,
                                 ddirectdocdate => rinorders.directdocdate,
                                 ninvdoctype    => rinorders.invdoctype,
                                 sinvdocnumb    => rinorders.invdocnumb,
                                 dinvdocdate    => rinorders.invdocdate,
                                 nconfdoctype   => rinorders.confdoctype,
                                 sconfdocnumb   => rinorders.confdocnumb,
                                 dconfdocdate   => rinorders.confdocdate,
                                 nsigntax       => rinorders.signtax,
                                 ncurrency      => rinorders.currency,
                                 ncurcours      => rinorders.curcours,
                                 ncurbasecours  => rinorders.curbasecours,
                                 nacc_cours     => rinorders.acc_cours,
                                 nacc_basecours => rinorders.acc_basecours,
                                 nfa_cours      => rinorders.fa_cours,
                                 nfa_basecours  => rinorders.fa_basecours,
                                 nagent         => rinorders.agent,
                                 scomments      => rinorders.comments,
                                 nagnfifo       => rinorders.agnfifo,
                                 sbarcode       => rinorders.barcode,
                                 npayconf_type  => rinorders.payconf_type,
                                 spayconf_numb  => rinorders.payconf_numb,
                                 dpayconf_date  => rinorders.payconf_date,
                                 nreg_agent     => rinorders.reg_agent,
                                 nrn            => nrn);
  end p_inorders_base_insert;

  /*Процедура выолняет базовое добавление строки приходного ордера*/
  procedure p_inorderspecs_base_insert(rinorderspecs in inorderspecs%rowtype /*Атрибуты записи*/,
                                       nrn           out inorderspecs.rn%type /*Регистрационный номер записи*/) is
  begin
    parus.p_inorderspecs_base_insert(ncompany         => rinorderspecs.company,
                                     nprn             => rinorderspecs.prn,
                                     nnommodif        => rinorderspecs.nommodif,
                                     nnomnmodifpack   => rinorderspecs.nomnmodifpack,
                                     narticle         => rinorderspecs.article,
                                     ncell            => rinorderspecs.cell,
                                     ntaxgr           => rinorderspecs.taxgr,
                                     nplanquant       => rinorderspecs.planquant,
                                     nfactquant       => rinorderspecs.factquant,
                                     nplanquantalt    => rinorderspecs.planquantalt,
                                     nfactquantalt    => rinorderspecs.factquantalt,
                                     nprice           => rinorderspecs.price,
                                     npricemeas       => rinorderspecs.pricemeas,
                                     nprice_calc_rule => rinorderspecs.price_calc_rule,
                                     nNDS_COEFF_SIGN  => rinorderspecs.nds_coeff_sign, -- 01/02/2019 markov reliz 25/12/2018
                                     nNDS_COEFF       => rinorderspecs.nds_coeff, -- 01/02/2019 markov reliz 25/12/2018
                                     nacc_price       => rinorderspecs.acc_price,
                                     nacc_pricemeas   => rinorderspecs.acc_pricemeas,
                                     nacc_summ        => rinorderspecs.acc_summ,
                                     dexpiry_date     => rinorderspecs.expiry_date,
                                     scertificate     => rinorderspecs.certificate,
                                     nplansum         => rinorderspecs.plansum,
                                     nplansumtax      => rinorderspecs.plansumtax,
                                     nplansumnds      => rinorderspecs.plansumnds,
                                     nfactsum         => rinorderspecs.factsum,
                                     nfactsumtax      => rinorderspecs.factsumtax,
                                     nfactsumnds      => rinorderspecs.factsumnds,
                                     nautocalc_sign   => rinorderspecs.autocalc_sign,
                                     snote            => rinorderspecs.note,
                                     ssernumb         => rinorderspecs.sernumb,
                                     sbarcode         => rinorderspecs.barcode,
                                     ncountry         => rinorderspecs.country,
                                     sgtd             => rinorderspecs.gtd,
                                     nproducer        => rinorderspecs.producer,
                                     nstorage_time    => rinorderspecs.storage_time,
                                     numeas_storage   => rinorderspecs.umeas_storage,
                                     soriginal_name   => rinorderspecs.original_name,
                                     dprod_date       => rinorderspecs.prod_date,
                                     scardnumb        => rinorderspecs.cardnumb,
                                     nmdmnomen        => rinorderspecs.mdmnomen -- релиз 2019/12
                                    ,
                                     ndup_rn          => null -- релиз 2019/12
                                    ,
                                     ndup_clc         => 0 -- релиз 2019/12
                                    ,
                                     nrn              => nrn);
  end p_inorderspecs_base_insert;

  /*Процедура выполняет добавление прихода из подразделения*/
  procedure P_INSERT_INCOMEFROMDEPS(RINCOMEFROMDEPS   in INCOMEFROMDEPS%rowtype /*Атрибуты прихода из подразделения*/,
                                    NRNINCOMEFROMDEPS out INCOMEFROMDEPS.RN%type /*Регистрационный номер прихода из подразделения*/) is
  begin
    P_INCOMEFROMDEPS_BASE_INSERT(NCOMPANY          => RINCOMEFROMDEPS.COMPANY,
                                 NCRN              => RINCOMEFROMDEPS.CRN,
                                 NJUR_PERS         => RINCOMEFROMDEPS.JUR_PERS,
                                 NDOC_TYPE         => RINCOMEFROMDEPS.DOC_TYPE,
                                 SDOC_PREF         => RINCOMEFROMDEPS.DOC_PREF,
                                 SDOC_NUMB         => RINCOMEFROMDEPS.DOC_NUMB,
                                 DDOC_DATE         => RINCOMEFROMDEPS.DOC_DATE,
                                 NVALID_DOCTYPE    => RINCOMEFROMDEPS.VALID_DOCTYPE,
                                 SVALID_DOCNUMB    => RINCOMEFROMDEPS.VALID_DOCNUMB,
                                 DVALID_DOCDATE    => RINCOMEFROMDEPS.VALID_DOCDATE,
                                 NOUT_DEPARTMENT   => RINCOMEFROMDEPS.OUT_DEPARTMENT,
                                 NOUT_FACEACC      => RINCOMEFROMDEPS.OUT_FACEACC,
                                 NOUT_GRAPHPOINT   => RINCOMEFROMDEPS.OUT_GRAPHPOINT,
                                 NOUT_STORE        => RINCOMEFROMDEPS.OUT_STORE,
                                 NPARTY_AGENT      => RINCOMEFROMDEPS.PARTY_AGENT,
                                 NSTORE            => RINCOMEFROMDEPS.STORE,
                                 NAGENT            => RINCOMEFROMDEPS.AGENT,
                                 NCURRENCY         => RINCOMEFROMDEPS.CURRENCY,
                                 NSTORE_OPER       => RINCOMEFROMDEPS.STORE_OPER,
                                 SPARTY            => RINCOMEFROMDEPS.PARTY,
                                 SNOTE             => RINCOMEFROMDEPS.NOTE,
                                 NCURCOURS         => RINCOMEFROMDEPS.CURCOURS,
                                 NCURBASECOURS     => RINCOMEFROMDEPS.CURBASECOURS,
                                 NCURCOURS_DOC     => RINCOMEFROMDEPS.CURCOURS_DOC,
                                 NCURBASECOURS_DOC => RINCOMEFROMDEPS.CURBASECOURS_DOC,
                                 SBARCODE          => RINCOMEFROMDEPS.BARCODE,
                                 NRN               => NRNINCOMEFROMDEPS);
  end P_INSERT_INCOMEFROMDEPS;

  /*Процедура выполняет добавление спецификации прихода из подразделения*/
  procedure P_INSERT_INCOMEFROMDEPSSPEC(RINCOMEFROMDEPSSPEC   in INCOMEFROMDEPSSPEC%rowtype /*Атрибуты спецификации прихода из подразделения*/,
                                        NRNINCOMEFROMDEPSSPEC out INCOMEFROMDEPSSPEC.RN%type /*Регистрационный номер спецификации прихода из подразделения*/) is
  begin
    PARUS.P_INCOMEFROMDPSPEC_BASE_INSERT(NCOMPANY        => RINCOMEFROMDEPSSPEC.COMPANY,
                                         NPRN            => RINCOMEFROMDEPSSPEC.PRN,
                                         NNOMMODIF       => RINCOMEFROMDEPSSPEC.NOMMODIF,
                                         NPACK           => RINCOMEFROMDEPSSPEC.PACK,
                                         NARTICLE        => RINCOMEFROMDEPSSPEC.ARTICLE,
                                         NCELL           => RINCOMEFROMDEPSSPEC.CELL,
                                         NPARTY_AGENT    => RINCOMEFROMDEPSSPEC.PARTY_AGENT,
                                         NSUPPLY         => RINCOMEFROMDEPSSPEC.SUPPLY,
                                         NQUANT_PLAN     => RINCOMEFROMDEPSSPEC.QUANT_PLAN,
                                         NQUANT_FACT     => RINCOMEFROMDEPSSPEC.QUANT_FACT,
                                         NQUANT_PLAN_ALT => RINCOMEFROMDEPSSPEC.QUANT_PLAN_ALT,
                                         NQUANT_FACT_ALT => RINCOMEFROMDEPSSPEC.QUANT_FACT_ALT,
                                         DSROK           => RINCOMEFROMDEPSSPEC.SROK,
                                         SSERTIFICATE    => RINCOMEFROMDEPSSPEC.SERTIFICATE,
                                         NPRICE          => RINCOMEFROMDEPSSPEC.PRICE,
                                         NPRICEMEAS      => RINCOMEFROMDEPSSPEC.PRICEMEAS,
                                         NSUMM_PLAN      => RINCOMEFROMDEPSSPEC.SUMM_PLAN,
                                         NSUMM_FACT      => RINCOMEFROMDEPSSPEC.SUMM_FACT,
                                         SNOTE           => RINCOMEFROMDEPSSPEC.NOTE,
                                         SSERNUMB        => RINCOMEFROMDEPSSPEC.SERNUMB,
                                         SBARCODE        => RINCOMEFROMDEPSSPEC.BARCODE,
                                         NCOUNTRY        => RINCOMEFROMDEPSSPEC.COUNTRY,
                                         SGTD            => RINCOMEFROMDEPSSPEC.GTD,
                                         NPRODUCER       => RINCOMEFROMDEPSSPEC.PRODUCER,
                                         NSTORAGE_TIME   => RINCOMEFROMDEPSSPEC.STORAGE_TIME,
                                         NUMEAS_STORAGE  => RINCOMEFROMDEPSSPEC.UMEAS_STORAGE,
                                         DPROD_DATE      => RINCOMEFROMDEPSSPEC.PROD_DATE,
                                         SCARDNUMB       => RINCOMEFROMDEPSSPEC.CARDNUMB,
                                         NRN             => NRNINCOMEFROMDEPSSPEC);
  end P_INSERT_INCOMEFROMDEPSSPEC;

  /*Процедура выполняет добавление РНОвП*/
  procedure P_INSERT_TRANSINVDEPT(RTRANSINVDEPT   in TRANSINVDEPT%rowtype /*Атрибуты РНОвП*/,
                                  NRNTRANSINVDEPT out TRANSINVDEPT.RN%type /*Регистрационный номер РНОвП*/) is
  begin
    P_TRANSINVDEPT_BASE_INSERT(NCOMPANY       => RTRANSINVDEPT.COMPANY,
                               NCRN           => RTRANSINVDEPT.CRN,
                               NJUR_PERS      => RTRANSINVDEPT.JUR_PERS,
                               NDOCTYPE       => RTRANSINVDEPT.DOCTYPE,
                               SPREF          => RTRANSINVDEPT.PREF,
                               SNUMB          => RTRANSINVDEPT.NUMB,
                               DDOCDATE       => RTRANSINVDEPT.DOCDATE,
                               NDIRDOC        => RTRANSINVDEPT.DIRDOC,
                               SDIRNUMB       => RTRANSINVDEPT.DIRNUMB,
                               DDIRDATE       => RTRANSINVDEPT.DIRDATE,
                               NSTOPER        => RTRANSINVDEPT.STOPER,
                               NFACEACC       => RTRANSINVDEPT.FACEACC,
                               NGRAPHPOINT    => RTRANSINVDEPT.GRAPHPOINT,
                               NSTORE         => RTRANSINVDEPT.STORE,
                               NMOL           => RTRANSINVDEPT.MOL,
                               NSHEEPVIEW     => RTRANSINVDEPT.SHEEPVIEW,
                               NAGENT         => RTRANSINVDEPT.AGENT,
                               NSUBDIV        => RTRANSINVDEPT.SUBDIV,
                               NCURRENCY      => RTRANSINVDEPT.CURRENCY,
                               NCURCOURS      => RTRANSINVDEPT.CURCOURS,
                               NCURBASE       => RTRANSINVDEPT.CURBASE,
                               NSUMMWITHNDS   => RTRANSINVDEPT.SUMMWITHNDS,
                               NRECIPDOC      => RTRANSINVDEPT.RECIPDOC,
                               SRECIPNUMB     => RTRANSINVDEPT.RECIPNUMB,
                               DRECIPDATE     => RTRANSINVDEPT.RECIPDATE,
                               NFERRYMAN      => RTRANSINVDEPT.FERRYMAN,
                               SGETCONFIRM    => RTRANSINVDEPT.GETCONFIRM,
                               SWAYBLADENUMB  => RTRANSINVDEPT.WAYBLADENUMB,
                               NDRIVER        => RTRANSINVDEPT.DRIVER,
                               NCAR           => RTRANSINVDEPT.CAR,
                               NROUTE         => RTRANSINVDEPT.ROUTE,
                               NTRAILER1      => RTRANSINVDEPT.TRAILER1,
                               NTRAILER2      => RTRANSINVDEPT.TRAILER2,
                               NFA_CURCOURS   => RTRANSINVDEPT.FA_CURCOURS,
                               NFA_CURBASE    => RTRANSINVDEPT.FA_CURBASE,
                               NIN_STORE      => RTRANSINVDEPT.IN_STORE,
                               NIN_MOL        => RTRANSINVDEPT.IN_MOL,
                               NIN_STOPER     => RTRANSINVDEPT.IN_STOPER,
                               NIN_PARTY      => RTRANSINVDEPT.IN_PARTY,
                               SIN_PARTY      => RTRANSINVDEPT.IN_PARTY_CODE,
                               NIN_CURCOURS   => RTRANSINVDEPT.IN_CURCOURS,
                               NIN_CURBASE    => RTRANSINVDEPT.IN_CURBASE,
                               NVALID_DOCTYPE => RTRANSINVDEPT.VALID_DOCTYPE,
                               SVALID_DOCNUMB => RTRANSINVDEPT.VALID_DOCNUMB,
                               DVALID_DOCDATE => RTRANSINVDEPT.VALID_DOCDATE,
                               SCOMMENTS      => RTRANSINVDEPT.COMMENTS,
                               SBARCODE       => RTRANSINVDEPT.BARCODE,
                               NRESERV_SIGN   => 0,
                               NRN            => NRNTRANSINVDEPT);
  end P_INSERT_TRANSINVDEPT;

  /*Процедура выполняет добавление спецификации РНОвП*/
  procedure P_INSERT_TRANSINVDEPTSPECS(RTRANSINVDEPTSPECS   in TRANSINVDEPTSPECS%rowtype /*Атрибуты спецификации РНОвП*/,
                                       NRNTRANSINVDEPTSPECS out TRANSINVDEPTSPECS.RN%type /*Регистрационный номер спецификации РНОвП*/) is
  begin
    P_TRANSINVDEPTSP_BASE_INSERT(NCOMPANY         => RTRANSINVDEPTSPECS.COMPANY,
                                 NPRN             => RTRANSINVDEPTSPECS.PRN,
                                 NAGENT           => RTRANSINVDEPTSPECS.AGENT,
                                 NGOODSPARTY      => RTRANSINVDEPTSPECS.GOODSPARTY,
                                 NNOMMODIF        => RTRANSINVDEPTSPECS.NOMMODIF,
                                 NNOMNMODIFPACK   => RTRANSINVDEPTSPECS.NOMNMODIFPACK,
                                 NARTICLE         => RTRANSINVDEPTSPECS.ARTICLE,
                                 NCELL            => RTRANSINVDEPTSPECS.CELL,
                                 NTEMPERATURE     => RTRANSINVDEPTSPECS.TEMPERATURE,
                                 NPRICE           => RTRANSINVDEPTSPECS.PRICE,
                                 NQUANT           => RTRANSINVDEPTSPECS.QUANT,
                                 NQUANTALT        => RTRANSINVDEPTSPECS.QUANTALT,
                                 NCOEFF           => RTRANSINVDEPTSPECS.COEFF,
                                 NCOEFF_VAL_SIGN  => RTRANSINVDEPTSPECS.COEFF_VAL_SIGN,
                                 NCOEFF_CALC_SIGN => RTRANSINVDEPTSPECS.COEFF_CALC_SIGN,
                                 NPRICEMEAS       => RTRANSINVDEPTSPECS.PRICEMEAS,
                                 NSUMMWITHNDS     => RTRANSINVDEPTSPECS.SUMMWITHNDS,
                                 DBEGINDATE       => RTRANSINVDEPTSPECS.BEGINDATE,
                                 DENDDATE         => RTRANSINVDEPTSPECS.ENDDATE,
                                 SNOTE            => RTRANSINVDEPTSPECS.NOTE,
                                 SBCODE           => RTRANSINVDEPTSPECS.BCODE,
                                 SCARDNUMB        => null --28/06/2018 Кузнецов А.С релиз 20/06/2018
                                ,
                                 NRN              => NRNTRANSINVDEPTSPECS
                                 /*,nAUTO_BCODE => 0*/);
  end P_INSERT_TRANSINVDEPTSPECS;

  /*Процедура выполняет добавление акта списания*/
  procedure P_INSERT_WROFFACTS(RWROFFACTS   in WROFFACTS%rowtype /*Атрибуты акта списания*/,
                               NRNWROFFACTS out WROFFACTS.RN%type /*Регистрационный номер акта списания*/) is
    ICNT     integer := 0;
    SDOCPREF WROFFACTS.DOCPREF%type := trim(RWROFFACTS.DOCPREF);
  begin
    loop
      -- 05/04/2018 Марков МВ.
      /* цикл обеспечения уникальности номера */
      ICNT := ICNT + 1;
      begin
        P_WROFFACTS_BASE_INSERT(NCOMPANY       => RWROFFACTS.COMPANY,
                                NCRN           => RWROFFACTS.CRN,
                                NJUR_PERS      => RWROFFACTS.JUR_PERS,
                                NDOCTYPE       => RWROFFACTS.DOCTYPE,
                                SDOCNUMB       => RWROFFACTS.DOCNUMB,
                                SDOCPREF       => SDOCPREF, -- 05/04/2018 Марков МВ. RWROFFACTS.DOCPREF,
                                DDOCDATE       => RWROFFACTS.DOCDATE,
                                NFACEACC       => RWROFFACTS.FACEACC,
                                NACTTYPE       => RWROFFACTS.ACTTYPE,
                                NSTORE         => RWROFFACTS.STORE,
                                NAGENT         => RWROFFACTS.AGENT,
                                NSTOPER        => RWROFFACTS.STOPER,
                                NCURRENCY      => RWROFFACTS.CURRENCY,
                                NCURCOURSUM    => RWROFFACTS.CURCOURSUM,
                                NCURBASESUM    => RWROFFACTS.CURBASESUM,
                                NVALID_DOCTYPE => RWROFFACTS.VALID_DOCTYPE,
                                SVALID_NUMB    => RWROFFACTS.VALID_NUMB,
                                DVALID_DOCDATE => RWROFFACTS.VALID_DOCDATE,
                                SCOMMENTS      => RWROFFACTS.COMMENTS,
                                SBARCODE       => RWROFFACTS.BARCODE,
                                NSIGN_NEWPARTY => RWROFFACTS.SIGN_NEWPARTY,
                                NRN            => NRNWROFFACTS);
        -- успешный выход из цикла
        exit;
      exception
        when PKG_STD.UNIQUE_RECORD_FOUND then
          /* нарушена уникальность номера */
          begin
            SDOCPREF := trim(SDOCPREF) || '/' || TO_CHAR(ICNT);
          exception
            when OTHERS then
              SDOCPREF := '999/' || TO_CHAR(ICNT);
          end;
      end;
    end loop;
  end P_INSERT_WROFFACTS;

  /*Процедура выполняет добавление спецификации акта списания*/
  procedure P_INSERT_WROFFACTSPECS(RWROFFACTSPECS   in WROFFACTSPECS%rowtype /*Атрибуты спецификации акта списания*/,
                                   NRNWROFFACTSPECS out WROFFACTSPECS.RN%type /*Регистрационный номер спецификации акта списания*/) is
  begin
    P_WROFFACTSPECS_BASE_INSERT(NCOMPANY      => RWROFFACTSPECS.COMPANY,
                                NPRN          => RWROFFACTSPECS.PRN,
                                NGOODSSUPPLY  => RWROFFACTSPECS.GOODSSUPPLY,
                                NNOMMODIF     => RWROFFACTSPECS.NOMMODIF,
                                NNOMMODIFPACK => RWROFFACTSPECS.NOMMODIFPACK,
                                NARTICLE      => RWROFFACTSPECS.ARTICLE,
                                NCELL         => RWROFFACTSPECS.CELL,
                                NQUANT        => RWROFFACTSPECS.QUANT,
                                NQUANTALT     => RWROFFACTSPECS.QUANTALT,
                                NPRICE        => RWROFFACTSPECS.PRICE,
                                NPRICEMEAS    => RWROFFACTSPECS.PRICEMEAS,
                                NSUMM         => RWROFFACTSPECS.SUMM,
                                SNOTE         => RWROFFACTSPECS.NOTE,
                                NRN           => NRNWROFFACTSPECS);
  end P_INSERT_WROFFACTSPECS;

  /*Процедура устанавливает атрибуты инициализации прихода из подразделения*/
  procedure P_INCOMEFROMDEPS_INIT_PARAMS(RINCOMEFROMDEPSINIT out INCOMEFROMDEPS%rowtype /*Атрибуты прихода из подразделений*/) is
  begin
    /*Тип документа-основания*/
    RINCOMEFROMDEPSINIT.VALID_DOCTYPE := null;
    /*Номер документа-основания*/
    RINCOMEFROMDEPSINIT.VALID_DOCNUMB := null;
    /*Дата документа-основания*/
    RINCOMEFROMDEPSINIT.VALID_DOCDATE := null;
    /*Склад отправки*/
    RINCOMEFROMDEPSINIT.OUT_STORE := null;
    /*Точка графика лицевого счета*/
    RINCOMEFROMDEPSINIT.OUT_GRAPHPOINT := null;
    /*Контрагент партии*/
    RINCOMEFROMDEPSINIT.PARTY_AGENT := null;
    /*Партия*/
    RINCOMEFROMDEPSINIT.PARTY := null;
    /*Примечание*/
    RINCOMEFROMDEPSINIT.NOTE := null;
    /*Кросс-курс валюты лицевого счета*/
    RINCOMEFROMDEPSINIT.CURCOURS := null;
    /*Отношение кросс-курса л/с*/
    RINCOMEFROMDEPSINIT.CURBASECOURS := null;
    /*Кросс-курс документа*/
    RINCOMEFROMDEPSINIT.CURCOURS_DOC := 1;
    /*Отношение кросс-курса документа*/
    RINCOMEFROMDEPSINIT.CURBASECOURS_DOC := 1;
    /*Штрих-код*/
    --rIncomefromdepsInit.BARCODE := null;
  end P_INCOMEFROMDEPS_INIT_PARAMS;

  /*Процедура устанавливает атрибуты инициализации спецификации прихода из подразделения*/
  procedure P_INCOMEFROMDEPSSP_INIT_PARAMS(RINCOMEFROMDEPSSPECINIT out INCOMEFROMDEPSSPEC%rowtype /*Атрибуты строки прихода из подразделений*/) is
  begin
    /*Упаковка модификации*/
    RINCOMEFROMDEPSSPECINIT.PACK := null;
    /*Изделие*/
    RINCOMEFROMDEPSSPECINIT.ARTICLE := null;
    /*Место хранения*/
    RINCOMEFROMDEPSSPECINIT.CELL := null;
    /*Контрагент партии*/
    RINCOMEFROMDEPSSPECINIT.PARTY_AGENT := null;
    /*Партия товара*/
    RINCOMEFROMDEPSSPECINIT.SUPPLY := null;
    /*Количество в основной ЕИ фактически*/
    RINCOMEFROMDEPSSPECINIT.QUANT_FACT := 0;
    /*Количество в дополнительной ЕИ фактически*/
    RINCOMEFROMDEPSSPECINIT.QUANT_PLAN := 0;
    /*Количество в дополнительной ЕИ по плану*/
    RINCOMEFROMDEPSSPECINIT.QUANT_PLAN_ALT := 0;
    /*Количество в дополнительной ЕИ фактически*/
    RINCOMEFROMDEPSSPECINIT.QUANT_FACT_ALT := 0;
    /*Срок годности*/
    RINCOMEFROMDEPSSPECINIT.SROK := null;
    /*Сертификаты*/
    RINCOMEFROMDEPSSPECINIT.SERTIFICATE := null;
    /*Учетная цена*/
    RINCOMEFROMDEPSSPECINIT.PRICE := 0;
    /*ЕИ учетной цены*/
    RINCOMEFROMDEPSSPECINIT.PRICEMEAS := 0;
    /*Сумма план*/
    RINCOMEFROMDEPSSPECINIT.SUMM_PLAN := 0;
    /*Сумма факт*/
    RINCOMEFROMDEPSSPECINIT.SUMM_FACT := 0;
    /*Серия товара*/
    RINCOMEFROMDEPSSPECINIT.SERNUMB := null;
    /*Штрих-код*/
    RINCOMEFROMDEPSSPECINIT.BARCODE := null;
    /*Страна производителя*/
    RINCOMEFROMDEPSSPECINIT.COUNTRY := null;
    /*Реквизиты ГТД*/
    RINCOMEFROMDEPSSPECINIT.GTD := null;
    /*Производитель*/
    RINCOMEFROMDEPSSPECINIT.PRODUCER := null;
    /*Срок хранения*/
    RINCOMEFROMDEPSSPECINIT.STORAGE_TIME := null;
    /*Единица измерения срока хранения*/
    RINCOMEFROMDEPSSPECINIT.UMEAS_STORAGE := null;
  end P_INCOMEFROMDEPSSP_INIT_PARAMS;

  /*Процедура устанавливает атрибуты инициализации РНОвП*/
  procedure P_TRANSINVDEPT_INIT_PARAMS(RTRANSINVDEPTINIT out TRANSINVDEPT%rowtype /*Атрибуты РНОвП*/) is
  begin
    --Документ-распоряжение
    /*Ид типа документа распоряжения*/
    RTRANSINVDEPTINIT.DIRDOC := null;
    /*Номер распоряжения*/
    RTRANSINVDEPTINIT.DIRNUMB := null;
    /*Дата распоряжения*/
    RTRANSINVDEPTINIT.DIRDATE := null;
    /*Точка графика лицевого счета*/
    RTRANSINVDEPTINIT.GRAPHPOINT := null;
    /*Контрагент партии*/
    RTRANSINVDEPTINIT.AGENT := null;
    /*Курс валюты*/
    RTRANSINVDEPTINIT.CURCOURS := 1;
    /*Отношение курса*/
    RTRANSINVDEPTINIT.CURBASE := 1;
    /*Сумма с НДС и ГСМ*/
    RTRANSINVDEPTINIT.SUMMWITHNDS := 0;
    --Документ получателя
    /*Ид типа документа получателя*/
    RTRANSINVDEPTINIT.RECIPDOC := null;
    /*Номер получателя*/
    RTRANSINVDEPTINIT.RECIPNUMB := null;
    /*Дата получателя*/
    RTRANSINVDEPTINIT.RECIPDATE := null;
    /*Грузоперевозчик*/
    RTRANSINVDEPTINIT.FERRYMAN := null;
    /*Груз получил*/
    RTRANSINVDEPTINIT.GETCONFIRM := null;
    /*Номер путевого листа*/
    RTRANSINVDEPTINIT.WAYBLADENUMB := null;
    /*Ид водителя*/
    RTRANSINVDEPTINIT.DRIVER := null;
    /*Ид автомобиля*/
    RTRANSINVDEPTINIT.CAR := null;
    /*Ид маршрута*/
    RTRANSINVDEPTINIT.ROUTE := null;
    /*Прицеп 1*/
    RTRANSINVDEPTINIT.TRAILER1 := null;
    /*Прицеп 2*/
    RTRANSINVDEPTINIT.TRAILER2 := null;
    /*Курс валюты л/с*/
    RTRANSINVDEPTINIT.FA_CURCOURS := null;
    /*Отношение курса л/с*/
    RTRANSINVDEPTINIT.FA_CURBASE := null;
    /*Партия получателя (регистрационный номер)*/
    RTRANSINVDEPTINIT.IN_PARTY := null;
    /*Курс валюты склада-получателя*/
    RTRANSINVDEPTINIT.IN_CURCOURS := 1;
    /*Отношение курса склада-получателя*/
    RTRANSINVDEPTINIT.IN_CURBASE := 1;
    /*примечание*/
    RTRANSINVDEPTINIT.COMMENTS := null;
    /*Штрих-код*/
    RTRANSINVDEPTINIT.BARCODE := null;
  end P_TRANSINVDEPT_INIT_PARAMS;

  /*Процедура устанавливает атрибуты инициализации спецификации РНОвП*/
  procedure P_TRANSINVDEPTSPECS_INIT_PARS(RTRANSINVDEPTSPECSINIT out TRANSINVDEPTSPECS%rowtype /*Атрибуты строки РНОвП*/) is
  begin
    /*контрагент партии*/
    RTRANSINVDEPTSPECSINIT.AGENT := null;
    /*упаковка модификации*/
    RTRANSINVDEPTSPECSINIT.NOMNMODIFPACK := null;
    /*изделие*/
    RTRANSINVDEPTSPECSINIT.ARTICLE := null;
    /*место хранения (резервуар)*/
    RTRANSINVDEPTSPECSINIT.CELL := null;
    /*температура*/
    RTRANSINVDEPTSPECSINIT.TEMPERATURE := null;
    /*цена*/
    RTRANSINVDEPTSPECSINIT.PRICE := 0;
    /*количество в дополнительной ЕИ*/
    RTRANSINVDEPTSPECSINIT.QUANTALT := 0;
    /*коэффициент*/
    RTRANSINVDEPTSPECSINIT.COEFF := 0;
    /*признак указывающий что хранится в поле COEFF*/
    RTRANSINVDEPTSPECSINIT.COEFF_VAL_SIGN := 0;
    /*признак автоматического пересчета поля COEFF по количествам в ОЕИ и ДЕИ*/
    RTRANSINVDEPTSPECSINIT.COEFF_CALC_SIGN := 1;
    /*ЕИ цены*/
    RTRANSINVDEPTSPECSINIT.PRICEMEAS := 0 /*за основную ЕИ*/
     ;
    /*сумма с НДС и ГСМ*/
    RTRANSINVDEPTSPECSINIT.SUMMWITHNDS := 0;
    /*начало периода предоставления услуг*/
    RTRANSINVDEPTSPECSINIT.BEGINDATE := null;
    /*конец периода предоставления услуг*/
    RTRANSINVDEPTSPECSINIT.ENDDATE := null;
    /*примечание*/
    RTRANSINVDEPTSPECSINIT.NOTE := null;
  end P_TRANSINVDEPTSPECS_INIT_PARS;

  /*Процедура устанавливает атрибуты инициализации акта списания*/
  procedure P_WROFFACTS_INIT_PARAMS(RWROFFACTSINIT out WROFFACTS%rowtype /*Атрибуты акта списания*/) is
  begin
    /*Курс валюты*/
    RWROFFACTSINIT.CURCOURSUM := 1;
    /*Отношение курса*/
    RWROFFACTSINIT.CURBASESUM := 1;
    /*Примечание*/
    RWROFFACTSINIT.COMMENTS := null;
    /*Штрих-код*/
    RWROFFACTSINIT.BARCODE := null;
    /*Признак формирования новой партии*/
    RWROFFACTSINIT.SIGN_NEWPARTY := 0;
  end P_WROFFACTS_INIT_PARAMS;

  /*Процедура устанавливает атрибуты инициализации спецификации акта списания*/
  procedure P_WROFFACTSPECS_INIT_PARAMS(RWROFFACTSPECSINIT out WROFFACTSPECS%rowtype /*Атрибуты строки акта списания*/) is
  begin
    /*Изделие*/
    RWROFFACTSPECSINIT.ARTICLE := null;
    /*Место хранения (резервуар)*/
    RWROFFACTSPECSINIT.CELL := null;
    /*Количество в ДЕИ*/
    RWROFFACTSPECSINIT.QUANTALT := 0;
    /*Цена*/
    RWROFFACTSPECSINIT.PRICE := 0;
    /*ЕИ цены*/
    RWROFFACTSPECSINIT.PRICEMEAS := 0 /*за основную ЕИ*/
     ;
    /*Сумма*/
    RWROFFACTSPECSINIT.SUMM := 0;
    /*Примечание*/
    RWROFFACTSPECSINIT.NOTE := null;
  end P_WROFFACTSPECS_INIT_PARAMS;

  /*Функция возвращает наименование номенклатуры*/
  function F_DICNOMNS_GET_NAME(SCODE in varchar2 /*Код номенклатуры*/)
    return DICNOMNS.NOMEN_NAME%type is
    SNAME DICNOMNS.NOMEN_NAME%type;
  begin
    begin
      select N.NOMEN_NAME
        into SNAME
        from DICNOMNS N
       where N.NOMEN_CODE = SCODE;
    exception
      when NO_DATA_FOUND then
        SNAME := TO_CHAR(null);
    end;
    return(SNAME);
  end F_DICNOMNS_GET_NAME;

  /*Функция возвращает код вида склада*/
  function F_STKIND_CALC_CODE(NRN in STKIND.RN%type /*Регистрационный номер записи*/)
    return STKIND.CODE%type is
    /*Вид склада*/
    SCODE STKIND.CODE%type;
  begin
    begin
      select T.CODE into SCODE from STKIND T where T.RN = NRN;
    exception
      when NO_DATA_FOUND then
        SCODE := TO_CHAR(null);
    end;
    return(SCODE);
  end F_STKIND_CALC_CODE;

  /*Процедура определяет МОЛ склада*/
  procedure P_STORE_GET_AGENT(NRNSTORE in AZSAZSLISTMT.RN%type /*Склад*/,
                              NRNAGENT out AZSAZSLISTMT.AZS_AGENT%type /*МОЛ*/) is
  begin
    begin
      select STORE.AZS_AGENT
        into NRNAGENT
        from AZSAZSLISTMT STORE
       where STORE.RN = NRNSTORE;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRNSTORE,
                                 SUNIT_TABLE => 'AZSListView');
    end;
  end P_STORE_GET_AGENT;

  /*Процедура определяет подразделение склада*/
  procedure P_STORE_GET_DEP(NRNSTORE in AZSAZSLISTMT.RN%type /*Склад*/,
                            NRNDEP   out INS_DEPARTMENT.RN%type /*Подразделение*/) is
  begin
    begin
      select STORE.DEPARTMENT
        into NRNDEP
        from AZSAZSLISTMT STORE
       where STORE.RN = NRNSTORE;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRNSTORE,
                                 SUNIT_TABLE => 'AZSListView');
    end;
  end P_STORE_GET_DEP;

  /*Процедура определяет код основной единицы измерения указанной номенклатуры*/
  procedure P_DICNOMNS_CALC_UMEAS_MAIN(SNOMEN in DICNOMNS.NOMEN_CODE%type /*Номенклатура*/,
                                       SMUNIT out DICMUNTS.MEAS_MNEMO%type /*Единица измерения*/) is
  begin
    select DMU.MEAS_MNEMO
      into SMUNIT
      from DICNOMNS DN, DICMUNTS DMU
     where DN.NOMEN_CODE = SNOMEN
       and DMU.RN = DN.UMEAS_MAIN;
  exception
    when NO_DATA_FOUND then
      SMUNIT := TO_CHAR(null);
  end P_DICNOMNS_CALC_UMEAS_MAIN;

  /*Процедура определяет модификацию указанной номенклатуры*/
  procedure P_DICNOMNS_CALC_MODIF(SNOMEN     in DICNOMNS.NOMEN_CODE%type /*Номенклатура*/,
                                  SMODIF     out NOMMODIF.MODIF_CODE%type /*Модификация*/,
                                  SMODIFNAME out NOMMODIF.MODIF_NAME%type /*Наименование модификации*/) is
  begin
    select NM.MODIF_CODE, NM.MODIF_NAME
      into SMODIF, SMODIFNAME
      from DICNOMNS DN, NOMMODIF NM
     where DN.NOMEN_CODE = SNOMEN
       and NM.PRN = DN.RN
       and ROWNUM = 1;
  exception
    when NO_DATA_FOUND then
      SMODIF     := TO_CHAR(null);
      SMODIFNAME := TO_CHAR(null);
  end P_DICNOMNS_CALC_MODIF;

  /*Процедура определяет склад с указанным видом для указанного подразделения*/
  procedure P_INS_DEP_SEARCH_STORE_TYPE(NRNDEP   in INS_DEPARTMENT.RN%type /*Подразделение*/,
                                        NTYPE    in STKIND.RN%type /*Вид склада*/,
                                        NRNSTORE out AZSAZSLISTMT.RN%type /*Склад*/) is
  begin
    select STORE.RN
      into NRNSTORE
      from AZSAZSLISTMT STORE
     where STORE.DEPARTMENT = NRNDEP
       and STORE.STKIND = NTYPE;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0,
                  'Не удалось определить склад с типом ' ||
                  F_STKIND_CALC_CODE(NRN => NTYPE) || ' для подразделения ' ||
                  udo_get_subdiv_code_id(nFLAG_SMART => 0, NRN => NRNDEP));
    when TOO_MANY_ROWS then
      P_EXCEPTION(0,
                  'Не удалось однозначно определить склад с типом ' ||
                  F_STKIND_CALC_CODE(NRN => NTYPE) || ' для подразделения ' ||
                  udo_get_subdiv_code_id(nFLAG_SMART => 0, NRN => NRNDEP));
  end P_INS_DEP_SEARCH_STORE_TYPE;

  /*Функция определяет статью затрат для указанной модификации номенклатуры*/
  function F_NOMMODIF_CALC_ARTICLE(NCOMPANY in number /*Организация*/,
                                   NRN      in NOMMODIF.RN%type /*Регистрационный номер записи*/)
    return FPDARTCL.CODE%type is
    /*Статья затрат*/
    SARTICLE FPDARTCL.CODE%type;
  begin
    begin
      select ART.CODE
        into SARTICLE
        from FCMATRESOURCE MR, FPDARTCL ART
       where MR.NOMEN_MODIF = NRN
         and ART.RN = MR.DEF_ARTCL;
    exception
      when NO_DATA_FOUND then
        SARTICLE := TO_CHAR(null);
    end;
    return(SARTICLE);
  end F_NOMMODIF_CALC_ARTICLE;

  /*Процедура выполняет установку заказа в приход из подразделений*/
  procedure P_INCOMEFROMDEPS_SET_PR_ORDER(NCOMPANY    in number,
                                          NRN         in number,
                                          SPROD_ORDER in varchar2) is
    /*Заказ*/
    NPROD_ORDER FACEACC.RN%type;
  begin
    /*Выполняем поиск заказа*/
    FIND_FACEACC_NUMB(NFLAG_SMART  => 0,
                      NFLAG_OPTION => 0,
                      NCOMPANY     => NCOMPANY,
                      SNUMB        => SPROD_ORDER,
                      NRN          => NPROD_ORDER);
    /*Выполняем исправление заказа*/
    update INCOMEFROMDEPS I
       set I.OUT_FACEACC = NPROD_ORDER
     where I.RN = NRN
       and I.COMPANY = NCOMPANY;
    /*Выполняем проверку исправления заказа*/
    if (sql%notfound) then
      PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                               SUNIT_TABLE => 'IncomFromDeps');
    end if;
  end P_INCOMEFROMDEPS_SET_PR_ORDER;

  /*Процедура выполняет резервирование указанной строки расходной накладной*/
  procedure P_TRANSINVDEPTSP_BASE_RES(NCOMPANY     in number, -- организация    
                                      NRN          in number, -- RN спецификации расходной накладной
                                      NSIGN_WARN   in number, -- признак генерации предупреждений (0-нет, 1-да)
                                      NSIGNSTORE   in number /*Признак склада: -1 - отправитель, 1 - получатель*/,
                                      DRES_DATE    in out date, -- дата и время резервирования
                                      DRES_DATE_TO in date -- дата резервирования до
                                      ) as
    /*Атрибуты документа*/
    RINV TRANSINVDEPT%rowtype;
    /*Атрибуты спецификации документа*/
    RSP       TRANSINVDEPTSPECS%rowtype;
    RDOC      PKG_PARTIES_CHOICE.TDOC;
    TBPARTIES PKG_PARTIES_CHOICE.TPARTIES;
    NRESULT   PKG_STD.TNUMBER;
    SMSG      PKG_STD.TLSTRING;
    NTMP      PKG_STD.TNUMBER;
  begin
    /*Атрибуты спецификации документа*/
    begin
      select S.* into RSP from TRANSINVDEPTSPECS S where S.RN = NRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'GoodsTransInvoicesToDeptsSpecs');
    end;
    /*Атрибуты документа*/
    begin
      select N.* into RINV from TRANSINVDEPT N where N.RN = RSP.PRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RSP.PRN,
                                 SUNIT_TABLE => 'GoodsTransInvoicesToDepts');
    end;
    /* инициализация документа */
    RDOC.UNITCODE    := 'GoodsTransInvoicesToDepts';
    RDOC.RN          := RINV.RN;
    RDOC.DOCTYPE     := RINV.DOCTYPE;
    RDOC.PREF        := RINV.PREF;
    RDOC.NUMB        := RINV.NUMB;
    RDOC.DOCDATE     := RINV.DOCDATE;
    RDOC.WORK_DATE   := TRUNC(DRES_DATE);
    RDOC.JUR_PERS    := RINV.JUR_PERS;
    RDOC.AGENT       := NVL(RINV.AGENT, RSP.AGENT);
    RDOC.SUBDIV      := RINV.SUBDIV;
    RDOC.RESPONSIBLE := TO_NUMBER(null);
    RDOC.RESERVDATE  := DRES_DATE_TO;
    if (NSIGNSTORE = -1) then
      RDOC.STOPER := RINV.STOPER;
    else
      RDOC.STOPER := RINV.IN_STOPER;
    end if;
    /* инициализация спецификации */
    RDOC.SPEC.UNITCODE := 'GoodsTransInvoicesToDeptsSpecs';
    RDOC.SPEC.RN       := RSP.RN;
    RDOC.SPEC.MODIF    := RSP.NOMMODIF;
    RDOC.SPEC.PACK     := RSP.NOMNMODIFPACK;
    RDOC.SPEC.ARTICLE  := RSP.ARTICLE;
    if (NSIGNSTORE = -1) then
      RDOC.SPEC.GOODSPARTY := RSP.GOODSPARTY;
    else
      begin
        select GS.PRN
          into RDOC.SPEC.GOODSPARTY
          from DOCLINKS L, STOREOPERJOURN J, GOODSSUPPLY GS
         where L.IN_DOCUMENT = RSP.RN
           and L.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
           and L.OUT_UNITCODE = 'StoreOpersJournal'
           and J.RN = L.OUT_DOCUMENT
           and J.OPER_TYPE = 1
           and GS.RN = J.GOODSSUPPLY;
      exception
        when NO_DATA_FOUND then
          P_EXCEPTION(0,
                      'Не удалось определить партию %s',
                      rsp.rn);
        when TOO_MANY_ROWS then
          P_EXCEPTION(0,
                      'Не удалось однозначно определить партию');
      end;
    end if;
    RDOC.SPEC.QUANT     := RSP.QUANT;
    RDOC.SPEC.QUANT_ALT := RSP.QUANTALT;
    /* инициализация склада */
    if (NSIGNSTORE = -1) then
      RDOC.STORE.RN := RINV.STORE;
    else
      RDOC.STORE.RN := RINV.IN_STORE;
    end if;
    /* считываем дополнительные параметры документа */
    PKG_PARTIES_CHOICE.GET_DOCUMENT_PARAMS(1 /*FLAG_SMART*/,
                                           0 /*подбор по товарным запасам*/,
                                           RDOC);
    /* если не услуга, подбираем */
    if RDOC.SPEC.NOMEN_TYPE != 2 then
      /* подбор партий и резервирование товара */
      PKG_PARTIES_CHOICE.CHOICE_EX(1 /*FLAG_SMART*/,
                                   NCOMPANY,
                                   0 /*подбор по товарным запасам*/,
                                   0 /*подбор для резервирования*/,
                                   0 /*подбор*/,
                                   RDOC,
                                   TBPARTIES,
                                   NTMP,
                                   NTMP,
                                   NTMP,
                                   NTMP,
                                   NRESULT);
      if TBPARTIES.COUNT > 0 then
        /* резервирование */
        PKG_PARTIES_CHOICE.ADD_TO_RESJOURNAL(NCOMPANY,
                                             DRES_DATE,
                                             RDOC,
                                             TBPARTIES);
      end if;
      /* если нет требуемого количества - формируем предупреждение */
      if (NSIGN_WARN = 1) and (NRESULT = 0) then
        if RDOC.STORE.RN is not null then
          SMSG := 'На складе "' || RDOC.STORE.AZS_NUMBER || '" товара ';
        else
          SMSG := 'Товара ';
        end if;
        SMSG := SMSG || '"' || RDOC.SPEC.NOMEN_CODE || '" ';
        if RDOC.SPEC.MODIF_CODE is not null then
          SMSG := SMSG || 'модификации "' || RDOC.SPEC.MODIF_CODE || '" ';
        end if;
        SMSG := SMSG || 'не достаточно.';
        /* проверка входной связи c расходами сопутствующих товаров сменных отчетов АЗС */
        if F_DOCLINKS_LINK_IN('GoodsTransInvoicesToDepts',
                              RINV.RN,
                              'AZSRepOutAttendGoods') is not null then
          /* при резервировании из расходов сопутствующих товаров генерируем исключение */
          SMSG := SMSG || CR || 'Резервирование невозможно.';
          P_EXCEPTION(0, SMSG);
        else
          SMSG := SMSG || CR || 'Зарезервировать частично?';
          PKG_GOODS_CHECK.P_ADD_ERROR_MESSAGE(110,
                                              SMSG,
                                              null,
                                              RDOC.STORE.JUR_PERS);
        end if;
      end if;
    end if;
    TBPARTIES.DELETE;
  end P_TRANSINVDEPTSP_BASE_RES;

  /*Процедура выполняет отмену резервирования указанной строки расходной накладной*/
  procedure P_TRANSINVDEPTSP_BASE_RES_CAN(NCOMPANY     in number, -- организация
                                          NRN          in number, -- RN спецификации расходной накладной
                                          NSIGN_WARN   in number, -- признак генерации предупреждений (0-нет, 1-да)
                                          NSIGNSTORE   in number /*Признак склада: -1 - отправитель, 1 - получатель*/,
                                          DRES_DATE    in out date, -- дата и время резервирования
                                          DRES_DATE_TO in date -- дата резервирования до   
                                          ) as
  begin
    for REC in (select J.RN, J.RES_START_DATE
                  from DOCLINKS L, RESJOURNAL J
                 where L.IN_DOCUMENT = NRN
                   and L.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                   and L.OUT_UNITCODE = 'ReservationJournal'
                   and L.OUT_DOCUMENT = J.RN
                   and J.RES_END_DATE is null
                 order by J.RES_START_DATE) loop
      P_RESJOURNAL_STORN(NCOMPANY,
                         REC.RN,
                         'Резервирование снято из раздела "' ||
                         GET_UNITLIST_NAME_CODE(0,
                                                'GoodsTransInvoicesToDepts') || '"');
      /* возвращение даты начала последнего резервирования */
      DRES_DATE := REC.RES_START_DATE;
    end loop;
  end P_TRANSINVDEPTSP_BASE_RES_CAN;

  /*Процедура выполняет резервирование для указанной расходной накладной*/
  procedure P_TRANSINVDEPT_BASE_RESERV(NCOMPANY     in number, -- организация.
                                       NRN          in number, -- RN накладной
                                       NSIGN_WARN   in number, -- признак генерации предупреждений
                                       NSIGNSTORE   in number /*Признак склада: -1 - отправитель, 1 - получатель*/,
                                       DRES_DATE    in out date, -- дата и время резервирования
                                       DRES_DATE_TO in date -- дата резервирования до
                                       ) as
    NCRN          TRANSINVDEPT.CRN%type;
    NSTATUS       TRANSINVDEPT.STATUS%type;
    NOPER_TYPE    AZSGSMWAYSTYPES.GSMWAYS_TYPE%type;
    NFACTRET_SIGN AZSGSMWAYSTYPES.FACTRET_SIGN%type;
    -- временные переменные
    NTMP PKG_STD.TNUMBER;
    DTMP PKG_STD.TLDATE;
  begin
    /*Выполняем проверку существования расходной накладной*/
    P_TRANSINVDEPT_EXISTS(NCOMPANY => NCOMPANY, NRN => NRN, NCRN => NCRN);
    if (NSIGNSTORE = -1) then
      begin
        select T.STATUS, T.RESERVDATE, SO.GSMWAYS_TYPE, SO.FACTRET_SIGN
          into NSTATUS, DTMP, NOPER_TYPE, NFACTRET_SIGN
          from TRANSINVDEPT T, AZSGSMWAYSTYPES SO
         where T.COMPANY = NCOMPANY
           and T.RN = NRN
           and T.STOPER = SO.RN;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND(NRN, 'GoodsTransInvoicesToDepts');
      end;
      /* проверим дату резервирования */
      if DTMP is not null then
        return;
      end if;
      /* проверим текущее состояние ТТН */
      if (NSTATUS <> 0) then
        P_EXCEPTION(0,
                    'Резервирование товара по расходной накладной на отпуск в подразделения допустимо только в состоянии "Не отработан".');
      end if;
      /* проверим складскую операцию */
      if (NOPER_TYPE <> 0) or (NFACTRET_SIGN <> 0) then
        P_EXCEPTION(0,
                    'Резервирование товара по расходной накладной на отпуск в подразделения допустимо только с типом складской операции' ||
                    ' "Расход"/"Прямая".');
      end if;
      /* проверка связи с распоряжением */
      NTMP := F_DOCLINKS_LINK_IN_DOC('GoodsTransInvoicesToDepts',
                                     NRN,
                                     'SheepDirectToDepts');
      if NTMP is not null then
        P_EXCEPTION(0,
                    'Резервирование товара по расходной накладной на отпуск в подразделения, созданной из распоряжения на отгрузку в подразделения, недопустимо.');
      end if;
      /* проверка связи с заказом подразделения */
      NTMP := F_DOCLINKS_LINK_IN_DOC('GoodsTransInvoicesToDepts',
                                     NRN,
                                     'DepartmentsOrders');
      if NTMP is not null then
        begin
          -- считываем дату резервирования заказа
          select RESERVDATE into DTMP from DEPARTMENTORD where RN = NTMP;
        exception
          when NO_DATA_FOUND then
            P_EXCEPTION(0,
                        'Запись заказа подразделения (RN: ' ||
                        NVL(TO_CHAR(NTMP), '<null>') || ') не найдена.');
        end;
        if DTMP is not null then
          -- если заказ зарезервирован, то резервировать нельзя.
          P_EXCEPTION(0,
                      'Резервирование товара по расходной накладной на отпуск в подразделения, созданной из заказа подразделения,' ||
                      ' недопустимо, т.к. товар был зарезервирован из заказа.');
        end if;
      end if;
      /* установка даты резервирования */
      update TRANSINVDEPT
         set RESERVDATE = DRES_DATE_TO
       where COMPANY = NCOMPANY
         and RN = NRN;
      if sql%notfound then
        PKG_MSG.RECORD_NOT_FOUND(NRN, 'GoodsTransInvoicesToDepts');
      end if;
    end if;
    /* очиска буфера сообщений */
    PKG_GOODS_CHECK.P_CLEAR_ERRORS;
    /* цикл по спецификациям */
    for REC in (select S.RN as NRN
                  from TRANSINVDEPTSPECS S, NOMMODIF M, DICNOMNS D
                 where S.COMPANY = NCOMPANY
                   and S.PRN = NRN
                   and S.NOMMODIF = M.RN
                   and M.PRN = D.RN
                   and D.NOMEN_TYPE <> 2) loop
      P_TRANSINVDEPTSP_BASE_RES(NCOMPANY     => NCOMPANY,
                                NRN          => REC.NRN,
                                NSIGN_WARN   => NSIGN_WARN,
                                NSIGNSTORE   => NSIGNSTORE,
                                DRES_DATE    => DRES_DATE,
                                DRES_DATE_TO => DRES_DATE_TO);
    end loop;
    /*Ошибки*/
    if (PKG_GOODS_CHECK.P_GET_ERRORS_COUNT <> 0) then
      PKG_GOODS_CHECK.P_CHECK_RIGHTS(0, NCOMPANY, NCRN);
    end if;
  end P_TRANSINVDEPT_BASE_RESERV;

  /*Процедура выполняет отмену резервирования для указанной расходной накладной*/
  procedure P_TRANSINVDEPT_BASE_RESERV_CAN(NCOMPANY     in number, -- организация.
                                           NRN          in number, -- RN накладной    
                                           NSIGN_WARN   in number, -- признак генерации предупреждений
                                           NSIGNSTORE   in number /*Признак склада: -1 - отправитель, 1 - получатель*/,
                                           DRES_DATE    in out date, -- дата и время резервирования
                                           DRES_DATE_TO in out date -- дата резервирования до
                                           ) as
    NCRN TRANSINVDEPT.CRN%type;
  begin
    /*Выполняем проверку существования расходной накладной*/
    P_TRANSINVDEPT_EXISTS(NCOMPANY => NCOMPANY, NRN => NRN, NCRN => NCRN);
    if (NSIGNSTORE = -1) then
      begin
        /* получение даты резервирования до */
        select RESERVDATE
          into DRES_DATE_TO
          from TRANSINVDEPT
         where COMPANY = NCOMPANY
           and RN = NRN;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND(NRN, 'GoodsTransInvoicesToDepts');
      end;
      /* снятие даты резервирования */
      update TRANSINVDEPT
         set RESERVDATE = null
       where COMPANY = NCOMPANY
         and RN = NRN;
    end if;
    /* очиска буфера сообщений */
    PKG_GOODS_CHECK.P_CLEAR_ERRORS;
    /* цикл по спецификациям */
    for REC in (select S.RN as NRN
                  from TRANSINVDEPTSPECS S, NOMMODIF M, DICNOMNS D
                 where S.PRN = NRN
                   and S.COMPANY = NCOMPANY
                   and S.NOMMODIF = M.RN
                   and M.PRN = D.RN
                   and D.NOMEN_TYPE <> 2) loop
      /* снятие резервирования */
      P_TRANSINVDEPTSP_BASE_RES_CAN(NCOMPANY     => NCOMPANY,
                                    NRN          => REC.NRN,
                                    NSIGN_WARN   => NSIGN_WARN,
                                    NSIGNSTORE   => NSIGNSTORE,
                                    DRES_DATE    => DRES_DATE,
                                    DRES_DATE_TO => DRES_DATE_TO);
    end loop;
    /*Ошибки*/
    if (PKG_GOODS_CHECK.P_GET_ERRORS_COUNT <> 0) then
      PKG_GOODS_CHECK.P_CHECK_RIGHTS(0, NCOMPANY, NCRN);
    end if;
  end P_TRANSINVDEPT_BASE_RESERV_CAN;

  /*Процедура выполняет резервирование указанной строки акта списания*/
  procedure P_WROFFACTSPECS_BASE_RES(NCOMPANY     in number /*Регистрационный номер организации*/,
                                     NRN          in WROFFACTSPECS.RN%type /*Регистрационный номер записи*/,
                                     NSIGN_WARN   in number /*признак генерации предупреждений*/,
                                     DRES_DATE    in out date /*дата и время резервирования*/,
                                     DRES_DATE_TO in date /*дата резервирования до*/) is
    /*Атрибуты записи*/
    RSP WROFFACTSPECS%rowtype;
    /*Атрибуты документа*/
    RACT      WROFFACTS%rowtype;
    RDOC      PKG_PARTIES_CHOICE.TDOC;
    TBPARTIES PKG_PARTIES_CHOICE.TPARTIES;
    NRESULT   PKG_STD.TNUMBER;
    SMSG      PKG_STD.TLSTRING;
    NTMP      PKG_STD.TNUMBER;
  begin
    /*Атрибуты записи*/
    begin
      select S.* into RSP from WROFFACTSPECS S where S.RN = NRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'WriteOffActsSpecs');
    end;
    /*Атрибуты документа*/
    begin
      select ACT.* into RACT from WROFFACTS ACT where ACT.RN = RSP.PRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RSP.PRN,
                                 SUNIT_TABLE => 'WriteOffActs');
    end;
    /* инициализация документа */
    RDOC.UNITCODE    := 'WriteOffActs';
    RDOC.RN          := RACT.RN;
    RDOC.DOCTYPE     := RACT.DOCTYPE;
    RDOC.PREF        := RACT.DOCPREF;
    RDOC.NUMB        := RACT.DOCNUMB;
    RDOC.DOCDATE     := RACT.DOCDATE;
    RDOC.WORK_DATE   := TRUNC(DRES_DATE);
    RDOC.JUR_PERS    := RACT.JUR_PERS;
    RDOC.AGENT       := TO_NUMBER(null);
    RDOC.SUBDIV      := TO_NUMBER(null);
    RDOC.RESPONSIBLE := TO_NUMBER(null);
    RDOC.RESERVDATE  := trunc(DRES_DATE_TO);
    RDOC.STOPER      := RACT.STOPER;
    /* инициализация спецификации */
    RDOC.SPEC.UNITCODE := 'WriteOffActsSpecs';
    RDOC.SPEC.RN       := RSP.RN;
    RDOC.SPEC.MODIF    := RSP.NOMMODIF;
    RDOC.SPEC.PACK     := RSP.NOMMODIFPACK;
    RDOC.SPEC.ARTICLE  := RSP.ARTICLE;
    begin
      select GS.PRN
        into RDOC.SPEC.GOODSPARTY
        from GOODSSUPPLY GS
       where GS.RN = RSP.GOODSSUPPLY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RSP.GOODSSUPPLY,
                                 SUNIT_TABLE => 'GoodsSupply');
    end;
    RDOC.SPEC.QUANT     := RSP.QUANT;
    RDOC.SPEC.QUANT_ALT := RSP.QUANTALT;
    /* инициализация склада */
    RDOC.STORE.RN := RACT.STORE;
    /* считываем дополнительные параметры документа */
    PKG_PARTIES_CHOICE.GET_DOCUMENT_PARAMS(1 /*FLAG_SMART*/,
                                           0 /*подбор по товарным запасам*/,
                                           RDOC);
    /* если не услуга, подбираем */
    if RDOC.SPEC.NOMEN_TYPE != 2 then
      /* подбор партий и резервирование товара */
      PKG_PARTIES_CHOICE.CHOICE_EX(1 /*FLAG_SMART*/,
                                   NCOMPANY,
                                   0 /*подбор по товарным запасам*/,
                                   0 /*подбор для резервирования*/,
                                   0 /*подбор*/,
                                   RDOC,
                                   TBPARTIES,
                                   NTMP,
                                   NTMP,
                                   NTMP,
                                   NTMP,
                                   NRESULT);
      if TBPARTIES.COUNT > 0 then
        /* резервирование */
        PKG_PARTIES_CHOICE.ADD_TO_RESJOURNAL(NCOMPANY,
                                             trunc(DRES_DATE),
                                             RDOC,
                                             TBPARTIES);
      end if;
      /* если нет требуемого количества - формируем предупреждение */
      if (NSIGN_WARN = 1) and (NRESULT = 0) then
        if RDOC.STORE.RN is not null then
          SMSG := 'На складе "' || RDOC.STORE.AZS_NUMBER || '" товара ';
        else
          SMSG := 'Товара ';
        end if;
        SMSG := SMSG || '"' || RDOC.SPEC.NOMEN_CODE || '" ';
        if RDOC.SPEC.MODIF_CODE is not null then
          SMSG := SMSG || 'модификации "' || RDOC.SPEC.MODIF_CODE || '" ';
        end if;
        SMSG := SMSG || 'не достаточно.';
        /* проверка входной связи c расходами сопутствующих товаров сменных отчетов АЗС */
        /*if F_DOCLINKS_LINK_IN('GoodsTransInvoicesToDepts', nPRN, 'AZSRepOutAttendGoods') is not null then
          \* при резервировании из расходов сопутствующих товаров генерируем исключение *\
          sMSG := sMSG||CR||'Резервирование невозможно.';
          P_EXCEPTION(0, sMSG);
        else*/
        SMSG := SMSG || CR || 'Зарезервировать частично?';
        PKG_GOODS_CHECK.P_ADD_ERROR_MESSAGE(110,
                                            SMSG,
                                            null,
                                            RDOC.STORE.JUR_PERS);
        --end if;
      end if;
    end if;
    TBPARTIES.DELETE;
  end P_WROFFACTSPECS_BASE_RES;

  /*Процедура выполняет отмену резервирования указанной строки акта списания*/
  procedure P_WROFFACTSPECS_BASE_CAN_RES(NCOMPANY     in number /*Регистрационный номер организации*/,
                                         NRN          in WROFFACTSPECS.RN%type /*Регистрационный номер записи*/,
                                         NSIGN_WARN   in number /*признак генерации предупреждений*/,
                                         DRES_DATE    in out date /*дата и время резервирования*/,
                                         DRES_DATE_TO in date /*дата резервирования до*/) is
  begin
    for REC in (select J.RN, J.RES_START_DATE
                  from DOCLINKS L, RESJOURNAL J
                 where L.IN_DOCUMENT = NRN
                   and L.IN_UNITCODE = 'WriteOffActsSpecs'
                   and L.OUT_UNITCODE = 'ReservationJournal'
                   and L.OUT_DOCUMENT = J.RN
                   and J.RES_END_DATE is null
                 order by J.RES_START_DATE) loop
      P_RESJOURNAL_STORN(NCOMPANY,
                         REC.RN,
                         'Резервирование снято из раздела "' ||
                         GET_UNITLIST_NAME_CODE(0, 'WriteOffActs') || '"');
      /* возвращение даты начала последнего резервирования */
      DRES_DATE := REC.RES_START_DATE;
    end loop;
  end P_WROFFACTSPECS_BASE_CAN_RES;

  /*Процедура выполняет резервирование указанного акта списания*/
  procedure P_WROFFACTS_BASE_RESERV(NCOMPANY     in number /*Регистрационный номер организации*/,
                                    NRN          in WROFFACTS.RN%type /*Регистрационный номер записи*/,
                                    NSIGN_WARN   in number /*признак генерации предупреждений*/,
                                    DRES_DATE    in out date /*дата и время резервирования*/,
                                    DRES_DATE_TO in date /*дата резервирования до*/) is
    /*Атрибуты документа*/
    RACT          WROFFACTS%rowtype;
    NOPER_TYPE    AZSGSMWAYSTYPES.GSMWAYS_TYPE%type;
    NFACTRET_SIGN AZSGSMWAYSTYPES.FACTRET_SIGN%type;
  begin
    /*Атрибуты документа*/
    begin
      select ACT.* into RACT from WROFFACTS ACT where ACT.RN = NRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'WriteOffActs');
    end;
    begin
      select SO.GSMWAYS_TYPE, SO.FACTRET_SIGN
        into NOPER_TYPE, NFACTRET_SIGN
        from AZSGSMWAYSTYPES SO
       where SO.RN = RACT.STOPER
         and SO.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(RACT.STOPER, 'AZSGSMWAYSTYPES');
    end;
    /* проверим дату резервирования */
    /*if dTMP is not null then
      return;
    end if;*/
    if (F_DOCLINKS_LINK_OUT_DOC(SIN_UNITCODE  => 'WriteOffActs',
                                NIN_DOCUMENT  => NRN,
                                SOUT_UNITCODE => 'ReservationJournal') is not null) then
      P_EXCEPTION(0,
                  'По документу уже было выполнено резервирование');
    end if;
    /* проверим текущее состояние ТТН */
    if (RACT.STATUS <> 0) then
      P_EXCEPTION(0,
                  'Резервирование товара по расходной накладной на отпуск в подразделения допустимо только в состоянии "Не отработан".');
    end if;
    /* проверим складскую операцию */
    if (NOPER_TYPE <> 0) or (NFACTRET_SIGN <> 0) then
      P_EXCEPTION(0,
                  'Резервирование товара по расходной накладной на отпуск в подразделения допустимо только с типом складской операции' ||
                  ' "Расход"/"Прямая".');
    end if;
    /* проверка связи с распоряжением */
    /*nTMP := F_DOCLINKS_LINK_IN_DOC( 'GoodsTransInvoicesToDepts', nRN, 'SheepDirectToDepts' );
    if nTMP is not null then
      P_EXCEPTION( 0,'Резервирование товара по расходной накладной на отпуск в подразделения, созданной из распоряжения на отгрузку в подразделения, недопустимо.' );
    end if;*/
    /* проверка связи с заказом подразделения */
    --nTMP := F_DOCLINKS_LINK_IN_DOC( 'GoodsTransInvoicesToDepts', nRN, 'DepartmentsOrders' );
    /*if nTMP is not null then
      begin -- считываем дату резервирования заказа
        select RESERVDATE
          into dTMP
          from DEPARTMENTORD
         where RN = nTMP;
      exception
        when NO_DATA_FOUND then
          P_EXCEPTION( 0,'Запись заказа подразделения (RN: '||nvl(to_char(nTMP),'<null>')||') не найдена.' );
      end;
      if dTMP is not null then -- если заказ зарезервирован, то резервировать нельзя.
        P_EXCEPTION( 0,'Резервирование товара по расходной накладной на отпуск в подразделения, созданной из заказа подразделения,'||
                       ' недопустимо, т.к. товар был зарезервирован из заказа.' );
      end if;
    end if;*/
    /* установка даты резервирования */
    /*update TRANSINVDEPT
       set RESERVDATE = dRES_DATE_TO
     where COMPANY = nCOMPANY
       and RN = nRN;
    
    if SQL%NOTFOUND then
      PKG_MSG.RECORD_NOT_FOUND(nRN, 'GoodsTransInvoicesToDepts');
    end if;*/
    /* цикл по спецификациям */
    for REC in (select S.RN as NRN, D.NOMEN_CODE as nomen_code
                  from --TRANSINVDEPTSPECS S,
                       WROFFACTSPECS S,
                       NOMMODIF      M,
                       DICNOMNS      D
                 where S.COMPANY = NCOMPANY
                   and S.PRN = NRN
                   and S.NOMMODIF = M.RN
                   and M.PRN = D.RN
                   and D.NOMEN_TYPE <> 2) loop
      /* резервирование */
      /*P_TRANSINVDEPTSP_BASE_RESERV
      (
        nCOMPANY,
        1\*nRESERV*\,
        dRES_DATE_,
        Rec.RN,
        nRN,
        dRES_DATE_TO,
        nDOCTYPE,
        sDOCPREF,
        sDOCNUMB,
        dDOCDATE,
        nJUR_PERS,
        nvl(nAGENT, Rec.AGENT),
        nSTORE,
        nSTOPER,
        nSUBDIV,
        null\*nACC_AGENT*\,
        Rec.NOMMODIF,
        Rec.NOMNMODIFPACK,
        Rec.ARTICLE,
        Rec.GOODSPARTY,
        Rec.QUANT,
        Rec.QUANTALT,
        nSIGN_WARN
      );*/
      P_WROFFACTSPECS_BASE_RES(NCOMPANY     => NCOMPANY,
                               NRN          => REC.NRN,
                               NSIGN_WARN   => NSIGN_WARN,
                               DRES_DATE    => DRES_DATE,
                               DRES_DATE_TO => DRES_DATE_TO);
      if (PKG_GOODS_CHECK.P_GET_ERRORS_COUNT <> 0) then
        PKG_GOODS_CHECK.P_CHECK_RIGHTS(0, NCOMPANY, RACT.CRN);
        --p_exception(0, 'Ошибка резервирования для номенклатуры %s', rec.nomen_code);
      end if;
    end loop;
    /* считывание сообщений об ошибках */
    if (PKG_GOODS_CHECK.P_GET_ERRORS_COUNT <> 0) then
      PKG_GOODS_CHECK.P_CHECK_RIGHTS(0, NCOMPANY, RACT.CRN);
    end if;
  end P_WROFFACTS_BASE_RESERV;

  /*Процедура выполняет отмену резервирования указанного акта списания*/
  procedure P_WROFFACTS_BASE_RESERV_CANCEL(NCOMPANY     in number /*Регистрационный номер организации*/,
                                           NRN          in WROFFACTS.RN%type /*Регистрационный номер записи*/,
                                           NSIGN_WARN   in number /*признак генерации предупреждений*/,
                                           DRES_DATE    in out date /*дата и время резервирования*/,
                                           DRES_DATE_TO in date /*дата резервирования до*/) is
    DRES_DATE_ PKG_STD.TLDATE := DRES_DATE;
    NCRN       WROFFACTS.CRN%type;
  begin
    /*begin
      \* получение даты резервирования до *\
      select RESERVDATE
        into dRES_DATE_TO
        from TRANSINVDEPT
       where COMPANY = nCOMPANY
         and RN = nRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(nRN, 'GoodsTransInvoicesToDepts');
    end;*/
    /* снятие даты резервирования */
    /*update TRANSINVDEPT
      set RESERVDATE = null
    where COMPANY = nCOMPANY
      and RN = nRN;*/
    /*Выполняем проверку существования акта списания*/
    P_WROFFACTS_EXISTS(NCOMPANY => NCOMPANY, NRN => NRN, NCRN => NCRN);
    /* очиска буфера сообщений */
    PKG_GOODS_CHECK.P_CLEAR_ERRORS;
    /* цикл по спецификациям */
    for REC in (select S.RN as NRN
                  from --TRANSINVDEPTSPECS S,
                       WROFFACTSPECS S,
                       NOMMODIF      M,
                       DICNOMNS      D
                 where S.PRN = NRN
                   and S.COMPANY = NCOMPANY
                   and S.NOMMODIF = M.RN
                   and M.PRN = D.RN
                   and D.NOMEN_TYPE <> 2) loop
      /* снятие резервирования */
      --P_TRANSINVDEPTSP_BASE_RESERV(nCOMPANY, 0 /*nRESERV*/, dRES_DATE_, Rec.RN);
      P_WROFFACTSPECS_BASE_CAN_RES(NCOMPANY     => NCOMPANY,
                                   NRN          => REC.NRN,
                                   NSIGN_WARN   => NSIGN_WARN,
                                   DRES_DATE    => DRES_DATE_,
                                   DRES_DATE_TO => DRES_DATE_TO);
    end loop;
    /* считывание сообщений об ошибках */
    if (PKG_GOODS_CHECK.P_GET_ERRORS_COUNT <> 0) then
      PKG_GOODS_CHECK.P_CHECK_RIGHTS(0, NCOMPANY, NCRN);
    end if;
  end P_WROFFACTS_BASE_RESERV_CANCEL;

  /*Функция определяет минимальный остаток в истории изменений товарного запаса в указанном интервале времени*/
  function F_GOODSSUPPLYHIST_CALC_ReST(NPRN      in GOODSSUPPLYHIST.PRN%type /*Регистрационный номер товарного запаса*/,
                                       DDATE     in date /*Дата*/,
                                       NMUNIT    in number /*Признак ЕИ*/,
                                       nsign_res in number /*Признак резерва*/)
    return PKG_STD.TQUANT is
    /*Остаток*/
    NREST PKG_STD.TQUANT;
  begin
    select (case
             when (NMUNIT = 0) then
              (H.RESTFACT - (case
                when (nsign_res = 0) then
                 (0)
                else
                 (GREATEST(0, H.RESERV))
              end))
             when (NMUNIT = 1) then
              (H.RESTFACTALT - (case
                when (nsign_res = 0) then
                 (0)
                else
                 (GREATEST(0, H.RESERValt))
              end))
             else
              (0)
           end)
      into NREST
      from GOODSSUPPLYHIST H
     where H.PRN = NPRN
       and H.DATE_FROM <= DDATE
       and NVL(H.DATE_TO, dDATE) >= dDATE;
    return(NVL(NREST, 0));
  end F_GOODSSUPPLYHIST_CALC_ReST;

  /*Функция определяет минимальный остаток в истории изменений товарного запаса в указанном интервале времени*/
  function F_GOODSSUPPLYHIST_CALC_MIN_RST(NPRN       in GOODSSUPPLYHIST.PRN%type /*Регистрационный номер товарного запаса*/,
                                          DDATEBEGIN in date /*Дата начала периода*/,
                                          DDATEEND   in date /*Дата окончания периода*/,
                                          NMUNIT     in number /*Признак ЕИ*/,
                                          nsign_res  in number /*Признак резерва*/)
    return PKG_STD.TQUANT is
    /*Остаток*/
    NREST PKG_STD.TQUANT;
  begin
    select min((case
                 when (NMUNIT = 0) then
                  (H.RESTFACT - (case
                    when (nsign_res = 0) then
                     (0)
                    else
                     (GREATEST(0, H.RESERV))
                  end))
                 when (NMUNIT = 1) then
                  (H.RESTFACTALT - (case
                    when (nsign_res = 0) then
                     (0)
                    else
                     (GREATEST(0, H.RESERValt))
                  end))
                 else
                  (0)
               end))
      into NREST
      from GOODSSUPPLYHIST H
     where H.PRN = NPRN
       and H.DATE_FROM <= NVL(DDATEEND, H.DATE_FROM)
       and ((DDATEBEGIN is null) or
           ((DDATEBEGIN is not null) and
           (NVL(H.DATE_TO, DDATEBEGIN) >= DDATEBEGIN)));
    return(NVL(NREST, 0));
  end F_GOODSSUPPLYHIST_CALC_MIN_RST;

  /*Функция определяет учетную цену*/
  function F_REGPRICE_CALCULATE(NCOMPANY in number /*Организация*/,
                                NRN      in GOODSSUPPLY.RN%type /*Регистрационный номер записи*/,
                                DDATE    in date /*Дата*/)
    return REGPRICE.PRICE%type is
    NRNCURRENCY CURNAMES.RN%type;
    NPRICE      REGPRICE.PRICE%type;
    NTMP        number;
  begin
    FIND_CURRENCY_BASE(COMPANY => NCOMPANY, RN => NRNCURRENCY);
    P_GET_REGPRICE_BASE_EX(NCOMPANY     => NCOMPANY,
                           NGOODSSUPPLY => NRN,
                           NSOJ_QUANT   => TO_NUMBER(null),
                           NNOMEN       => TO_NUMBER(null),
                           NNOMMODIF    => TO_NUMBER(null),
                           NARTICLE     => TO_NUMBER(null),
                           NCURRENCY    => NRNCURRENCY,
                           NCURSUM      => 1,
                           NEQUALSUM    => 1,
                           DDATE        => DDATE,
                           NPRICE       => NPRICE,
                           NMEASTYPE    => NTMP,
                           NRN          => NTMP);
    return(NPRICE);
  end F_REGPRICE_CALCULATE;

  /*Функция определяет учетную цену*/
  function F_REGPRICE_CALCULATE(NCOMPANY in number /*Организация*/,
                                NRN      in GOODSPARTIES.RN%type /*Регистрационный номер записи*/,
                                NRNSTORE in AZSAZSLISTMT.RN%type /*Склад*/,
                                DDATE    in date /*Дата*/)
    return REGPRICE.PRICE%type is
    /*Товарный запас*/
    NRNSUPPLY GOODSSUPPLY.RN%type;
  begin
    FIND_GOODSSUPPLY_BY_STORE(NCOMPANY    => NCOMPANY,
                              NFLAG_SMART => 1,
                              NPRN        => NRN,
                              SSTORE      => F_DICSTORE_GET_NUMB(NSTORE => NRNSTORE),
                              NRN         => NRNSUPPLY);
    return(F_REGPRICE_CALCULATE(NCOMPANY => NCOMPANY,
                                NRN      => NRNSUPPLY,
                                DDATE    => DDATE));
  end F_REGPRICE_CALCULATE;

  function f_overheads_calc_price(NCOMPANY in number /*Организация*/,
                                  NRN      in GOODSSUPPLY.RN%type /*Регистрационный номер записи*/,
                                  DDATE    in date /*Дата*/) return number is
    /*Регистрационный номер записи партии*/
    nprn pkg_std.tref;
    /*Регистрационный номер записи товарного запаса*/
    nsupply pkg_std.tref;
  begin
    /*Регистрационный номер записи партии*/
    begin
      select s.prn
        into nprn
        from GOODSSUPPLY s
       where s.rn = nrn
         and s.COMPANY = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'GoodsSupply');
    end;
    /*Регистрационный номер записи товарного запаса*/
    select min(s.rn) into nsupply from GOODSSUPPLY s where s.prn = nprn;
    /*Возвращаем результат*/
    return(nvl(parus.f_overheads_calc_price(nflag_smart   => 1,
                                            ncompany      => ncompany,
                                            nsupply       => nsupply,
                                            nsoj_quant    => to_number(null),
                                            nmeastype     => 0,
                                            ddate         => ddate,
                                            ncurrency     => to_number(null),
                                            ncurcourse    => to_number(null),
                                            ncurbasecours => to_number(null)),
               0));
  end f_overheads_calc_price;

  /*Процедура очищает таблицу выбора партий*/
  /*procedure P_GOODSSUPPLY_SELECT_CLEAR is
  begin
    delete UDO_T_GOODSSUPPLY_SELECT;
  end P_GOODSSUPPLY_SELECT_CLEAR;*/

  /*Процедура заполняет таблицу выбора партий*/
  /*procedure P_GOODSSUPPLY_SELECT_FILL
    (
      NCOMPANY in number \*Организация*\
     ,NRNMODIF in NOMMODIF.RN%type \*Модификация*\
     ,NRNSTORE in AZSAZSLISTMT.RN%type \*Склад расхода*\
     ,DDATE    in date \*Дата*\
     ,nREPLACE in number default 0 \* с учетом возможных замен по матресурсу: 0 - нет; 1 - да 27/05/2020 Марков МВ*\
    ) is
      nNOMEN number(17);
    begin
      -- строка модификации 27/05/2020 Марков МВ.
      begin
        select MD.PRN
          into nNOMEN
          from NOMMODIF MD
         where MD.RN = NRNMODIF;
      exception
        when no_data_found then
          return; -- нет модификации, нечего строить
      end;
      
      -- строго по модификации из товарных запасов
      insert into UDO_T_GOODSSUPPLY_SELECT
        select \*+ index(h I_GOODSSUPPLYHIST_NMST)*\
         H.COMPANY
        ,H.PRN
        ,H.NOMMODIF
          from GOODSSUPPLYHIST H
         where H.NOMMODIF = NRNMODIF
           and H.STORE = NRNSTORE
           and H.COMPANY = NCOMPANY
           and H.DATE_FROM <= DDATE
           and NVL(H.DATE_TO, DDATE) >= DDATE
           and UDO_PKG_STORE_OPER_ACC.F_GOODSSUPPLYHIST_CALC_MIN_RST(NPRN       => H.PRN
                                                                    ,DDATEBEGIN => DDATE
                                                                    ,DDATEEND   => TO_DATE(null)
                                                                    ,NMUNIT     => 0) > 0;
      -- добавим возможные замены 27/05/2020 Марков МВ.
      if nREPLACE = 1 then
  --if utilizer = 'CITK_MARKOV' then p_exception(0, 'DDATE=%s; NRNSTORE=%s', DDATE, NRNSTORE); end if;
        for rec in(
          select MRS.NOMEN_MODIF
                     from FCMATRESOURCE  MR,
                          FCMATRESOURSUB SUB,
                          FCMATRESOURCE  MRS
                    where MR.NOMENCLATURE = nNOMEN
                      and MR.NOMEN_MODIF = NRNMODIF
                      and SUB.PRN = MR.RN
                      and SUB.ACTION_DATE <= DDATE
                      and nvl(SUB.END_DATE, DDATE) >= DDATE
                      and SUB.MATRES = MRS.RN
                      order by SUB.ACTION_DATE) loop
      -- добавим замены
      insert into UDO_T_GOODSSUPPLY_SELECT
        select \*+ index(h I_GOODSSUPPLYHIST_NMST)*\
         H.COMPANY
        ,H.PRN
        ,H.NOMMODIF
          from GOODSSUPPLYHIST H
         where H.NOMMODIF = rec.nomen_modif --NRNMODIF
           and H.STORE = NRNSTORE
           and H.COMPANY = NCOMPANY
           and H.DATE_FROM <= DDATE
           and NVL(H.DATE_TO, DDATE) >= DDATE
           and UDO_PKG_STORE_OPER_ACC.F_GOODSSUPPLYHIST_CALC_MIN_RST(NPRN       => H.PRN
                                                                    ,DDATEBEGIN => DDATE
                                                                    ,DDATEEND   => TO_DATE(null)
                                                                    ,NMUNIT     => 0) > 0;
        end loop;
      end if;
    end P_GOODSSUPPLY_SELECT_FILL;*/

  /*Функция определяет признак изменения заказа для указанной расходной накладной*/
  /*function F_TRANSINVDEPT_CLC_SGN_NEW_ORD
  (
    NCOMPANY    in number \*Организация*\
   ,NRN         in TRANSINVDEPT.RN%type \*Регистрационный номер записи*\
   ,NCHECKSTATE in number \*Признак необходимости проверки ГОЗ*\
  ) return number is
    NCOUNT number;
  begin
    select count(1)
      into NCOUNT
      from TRANSINVDEPT           N
          ,TRANSINVDEPTSPECS      S
          ,UDO_T_GOODSPARTIES_EXT GP_EXT
     where N.RN = NRN
       and N.COMPANY = NCOMPANY
       and S.PRN = N.RN
       and GP_EXT.PRN(+) = S.GOODSPARTY
       and CMP_NUM(GP_EXT.FACEACC, N.FACEACC) = 0
       and ((NCHECKSTATE = 0) or ((NCHECKSTATE = 1) and (GP_EXT.FACEACC is null)));
    if (NCOUNT = 0) then
      return(0);
    else
      return(1);
    end if;
  end F_TRANSINVDEPT_CLC_SGN_NEW_ORD;*/

  /*Процедура выполняет установку приходной партии для указанной расходной накладной на отпуск в подразделения*/
  procedure P_TRANSINVDEPT_SET_IN_PATY(NCOMPANY in number /*Организация*/,
                                       NRN      in TRANSINVDEPT.RN%type /*Регистрационный номер записи*/,
                                       SPARTY   in TRANSINVDEPT.IN_PARTY_CODE%type /*Партия*/) is
    /*Атрибуты требования*/
    RINV TRANSINVDEPT%rowtype;
  begin
    /*Атрибуты документа*/
    begin
      select N.* into RINV from TRANSINVDEPT N where N.RN = NRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'GoodsTransInvoicesToDepts');
    end;
    /* 26.01.2018 Добавлено исключение складов инструментов, для них партия не должна указываться*/
    if RINV.IN_STORE is not null then
      declare
        NDOCS_PROPS number;
        NSOURCE_EXT number;
      begin
        /*св-во "Статус склада"*/
        FIND_DOCS_PROPS_CODE(NFLAG_SMART => 0,
                             NCOMPANY    => NCOMPANY,
                             SCODE       => 'Тип итога',
                             NRN         => NDOCS_PROPS);
        begin
          select V.SOURCE_EXT
            into NSOURCE_EXT
            from DOCS_PROPS_VALS V
           where V.DOCS_PROP_RN = NDOCS_PROPS
             and V.UNIT_RN = RINV.IN_STORE
             and V.UNITCODE = 'AZSListView';
        exception
          when NO_DATA_FOUND then
            NSOURCE_EXT := null;
        end;
        /*если свойство заполнено, то выходим из процедуры*/
        if NSOURCE_EXT is not null then
          return;
        end if;
      end;
      -- если склад-получатель не склад комплектования, выходим. Бухвин 13/02/2018
      declare
        NIS_DELIV number;
      begin
        select count(*)
          into NIS_DELIV
          from AZSAZSLISTMT A
         where A.RN = RINV.IN_STORE
           and A.STKIND = 118505873;
        if NIS_DELIV = 0 then
          return;
        end if;
      end;
    end if;
    /*Код партии*/
    if (trim(SPARTY) is not null) then
      RINV.IN_PARTY_CODE := SPARTY;
    else
      RINV.IN_PARTY_CODE := GET_DOCTYPES_CODE_ID(NFLAG_SMART => 0,
                                                 NRN         => RINV.DOCTYPE) || '_' ||
                            trim(RINV.PREF) || '_' || trim(RINV.NUMB);
    end if;
    /*Выполняем поиск партии*/
    FIND_INCOMDOC_BY_CODE_EX(NFLAG_SMART => 1,
                             NCOMPANY    => NCOMPANY,
                             SCODE       => RINV.IN_PARTY_CODE,
                             NRN         => RINV.IN_PARTY);
    /*Выдаем сообщение об ошибке*/
    if (RINV.IN_PARTY is not null) then
      RINV.IN_PARTY_CODE := TO_CHAR(null);
    end if;
    /*Выполняем установку кода партии*/
    update TRANSINVDEPT N
       set N.IN_PARTY_CODE = RINV.IN_PARTY_CODE, N.IN_PARTY = RINV.IN_PARTY
     where N.RN = RINV.RN;
    /*Выполняем проверку исправления записи*/
    if (sql%notfound) then
      PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RINV.RN,
                               SUNIT_TABLE => 'GoodsTransInvoicesToDepts');
    end if;
  end P_TRANSINVDEPT_SET_IN_PATY;

  /*Процедура выполняет поиск партии источника для указанной приходной складской операции*/
  procedure P_STOREOPERJOURN_CLC_PARTY_SRC(NCOMPANY   in number /*Организация*/,
                                           NRN        in STOREOPERJOURN.RN%type /*Регистрационный номер записи*/,
                                           NPARTY_IN  in GOODSPARTIES.RN%type /*Регистрационный номер партии прихода*/,
                                           NPARTY_OUT out GOODSPARTIES.RN%type /*Регистрационный номер партии расхода*/) is
  begin
    select distinct GS.PRN
      into NPARTY_OUT
      from DOCLINKS L1, DOCLINKS L2, STOREOPERJOURN J, GOODSSUPPLY GS
     where L1.OUT_DOCUMENT = NRN
       and L1.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
       and L2.IN_DOCUMENT = L1.IN_DOCUMENT
       and L2.IN_UNITCODE = L1.IN_UNITCODE
       and L2.OUT_UNITCODE = 'StoreOpersJournal'
       and J.RN = L2.OUT_DOCUMENT
       and J.COMPANY = NCOMPANY
       and J.OPER_TYPE = 0 /*Расход*/
       and J.SIGNPLAN = 2 /*Факт*/
       and GS.RN = J.GOODSSUPPLY
       and GS.PRN <> NPARTY_IN;
  exception
    when NO_DATA_FOUND then
      NPARTY_OUT := TO_NUMBER(null);
    when TOO_MANY_ROWS then
      P_EXCEPTION(0,
                  'Не удалось однозначно определить партию-источник для партии');
  end P_STOREOPERJOURN_CLC_PARTY_SRC;

  /*Процедура выполняет установку партии источника для партий указанной расходной накладной*/
  /*procedure P_TRANSINVDEPT_SET_P_ORD_MOVE
  (
    NCOMPANY in number \*Организация*\
   ,NRN      in TRANSINVDEPT.RN%type \*Регистрационный номер записи*\
  ) is
    \*Регистрационный номер партии расхода*\
    NPARTY_OUT GOODSPARTIES.RN%type;
    \*Регистрационный номер записи партии-источника*\
    nparty_src GOODSPARTIES.RN%type;
  begin
    \*Если документ проводится по местам хранения, то завершаем работу процедуры*\
    if (F_DOCLINKS_LINK_OUT_DOC(SIN_UNITCODE  => 'GoodsTransInvoicesToDepts'
                               ,NIN_DOCUMENT  => NRN
                               ,SOUT_UNITCODE => 'StoragePlacesResJournal') is not null) then
      return;
    end if;
    \*Цикл по приходным партиям*\
    for INPARTYCURSOR in (select J.RN   as NOPER
                                ,GS.PRN as NPARTY
                            from DOCLINKS       L
                                ,STOREOPERJOURN J
                                ,GOODSSUPPLY    GS
                           where L.IN_DOCUMENT = NRN
                             and L.OUT_UNITCODE = 'StoreOpersJournal'
                             and J.RN = L.OUT_DOCUMENT
                             and J.OPER_TYPE = 1 \*Приход*\
                             and J.SIGNPLAN = 2 \*Факт*\
                             and GS.RN = J.GOODSSUPPLY)
    loop
      \*Выполняем поиск партии источника для текущей приходной складской операции*\
      P_STOREOPERJOURN_CLC_PARTY_SRC(NCOMPANY   => NCOMPANY
                                    ,NRN        => INPARTYCURSOR.NOPER
                                    ,NPARTY_IN  => INPARTYCURSOR.NPARTY
                                    ,NPARTY_OUT => NPARTY_OUT);
      \*Устанавливаем партию-источник*\
      if (NPARTY_OUT is not null) then
        \*Регистрационный номер записи партии-источника*\
        begin
          select t.src_party
            into nparty_src
            from UDO_T_GOODSPARTIES_EXT t
           where t.prn = NPARTY_OUT;
        exception
          when OTHERS then
            nparty_src := to_number(null);
        end;
        update UDO_T_GOODSPARTIES_EXT T
           set T.RN_PARTY_ORDER_MOVE = NPARTY_OUT
              ,t.src_party           = nparty_src
         where T.PRN = INPARTYCURSOR.NPARTY;
        if (sql%notfound) then
          insert into UDO_T_GOODSPARTIES_EXT
            (RN
            ,PRN
            ,FACEACC
            ,RN_PARTY_ORDER_MOVE
            ,src_party)
          values
            (GEN_ID
            ,INPARTYCURSOR.NPARTY
            ,TO_NUMBER(null)
            ,NPARTY_OUT
            ,nparty_src);
        end if;
      end if;
    end loop;
  end P_TRANSINVDEPT_SET_P_ORD_MOVE;*/

  /*Процедура выполняет базовое формирование требования на выдачу материала*/
  /*  procedure P_TRANSINVDEPT_BCREATE_INV_MAT
  (
    NCOMPANY       in number \*Организация*\
   ,NCRN           in TRANSINVDEPT.CRN%type \*Каталог*\
   ,NJUR_PERS      in TRANSINVDEPT.JUR_PERS%type \*Регистрационный номер юридического лица*\
   ,NTYPE          in TRANSINVDEPT.DOCTYPE%type \*Тип*\
   ,SNUMBER        in TRANSINVDEPT.NUMB%type \*Номер*\
   ,DDATE          in TRANSINVDEPT.DOCDATE%type \*Дата*\
   ,NSTOREOUT      in TRANSINVDEPT.STORE%type \*Склад расхода*\
   ,NSTOREOPEROUT  in TRANSINVDEPT.STOPER%type \*Складская операция расхода*\
   ,NSTOREIN       in TRANSINVDEPT.IN_STORE%type \*Склад прихода*\
   ,NDEP           in TRANSINVDEPT.SUBDIV%type \*Подразделение*\
   ,NORDER         in TRANSINVDEPT.FACEACC%type \*Заказ*\
   ,SPARTY         in TRANSINVDEPT.IN_PARTY_CODE%type \*Партия*\
   ,NVALID_DOCTYPE in TRANSINVDEPT.VALID_DOCTYPE%type\*Документ-основание*\
   ,SVALID_DOCNUMB in TRANSINVDEPT.VALID_DOCNUMB%type
   ,DVALID_DOCDATE in TRANSINVDEPT.VALID_DOCDATE%type
   ,NMODIF         in TRANSINVDEPTSPECS.NOMMODIF%type \*Модификация*\
   ,NQUANT         in TRANSINVDEPTSPECS.QUANT%type \*Количество*\
   ,NRNINV         out TRANSINVDEPT.RN%type \*Регистрационный номер записи*\
  ) is
    \*Вид отгрузки*\
    SSHEEPVIEW DICSHPVW.CODE%type;
    \*Складская операция прихода*\
    SOPERIN AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type;
    \*Подобранное количество*\
    NQUANTSELECT TRANSINVDEPTSPECS.QUANT%type;
    \*Атрибуты требования*\
    RINV TRANSINVDEPT%rowtype;
    \*Атрибуты строки требования*\
    RSP TRANSINVDEPTSPECS%rowtype;
    \*Тип требования*\
    STYPE varchar2(240);
  begin
    \*Устанавливаем атрибуты инициализации требования*\
    UDO_PKG_STORE_OPER_ACC.P_TRANSINVDEPT_INIT_PARAMS(RTRANSINVDEPTINIT => RINV);
    \*Организация*\
    RINV.COMPANY := NCOMPANY;
    \*Каталог*\
    RINV.CRN := NCRN;
    \*Юридическое лицо*\
    RINV.JUR_PERS := NJUR_PERS;
    \*Тип*\
    RINV.DOCTYPE := NTYPE;
    \*Префикс*\
    RINV.PREF := TO_CHAR(DDATE, 'yy-mm-') || F_DICSTORE_GET_NUMB(NSTORE => NSTOREOUT);
    \*Номер*\
    if rtrim(SNUMBER) is null then
      -- 13/03/2019 Марков МВ. проверка на отсутствие номера
      \*Тип*\
      P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY
                           ,SNAME    => 'ТребНаВыдачуМат_Тип'
                           ,DDATE    => TO_DATE(null)
                           ,SVALUE   => STYPE);
      -- номер по порядку для префикса
      p_transinvdept_getnextnumb(nCOMPANY => NCOMPANY
      ,sJUR_PERS => get_jurpersons_code_id(nFLAG_SMART => 0,nJUR_PERS => NJUR_PERS)
      ,dDOCDATE => ddate
                                ,sTYPE    => STYPE
                                ,sPREF    => RINV.PREF
                                ,sNUMB    => RINV.NUMB);
    else
      RINV.NUMB := trim(SNUMBER);
    end if;
    \*Дата*\
    RINV.DOCDATE := DDATE;
    \*Складская операция расхода*\
    RINV.STOPER := NSTOREOPEROUT;
    \*Лицевой счет*\
    RINV.FACEACC := NORDER;
    \*Склад расхода*\
    RINV.STORE := NSTOREOUT;
    \*МОЛ склада расхода*\
    UDO_PKG_STORE_OPER_ACC.P_STORE_GET_AGENT(NRNSTORE => RINV.STORE, NRNAGENT => RINV.MOL);
    \*Вид отгрузки*\
    P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY
                         ,SNAME    => 'ТребНаВыдачуМат_ВидОтгрузки'
                         ,DDATE    => TO_DATE(null)
                         ,SVALUE   => SSHEEPVIEW);
    FIND_DICSHPVW_CODE(NFLAG_SMART => 0
                      ,NCOMPANY    => NCOMPANY
                      ,SCODE       => SSHEEPVIEW
                      ,NRN         => RINV.SHEEPVIEW);
    \*Валюта*\
    RINV.CURRENCY := F_CURBASE_GET_RN(NFLAG_SMART => 0, NCOMPANY => NCOMPANY);
    \*Складская операция прихода*\
    P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY
                         ,SNAME    => 'ТребНаВыдачуМат_ОперПрих'
                         ,DDATE    => TO_DATE(null)
                         ,SVALUE   => SOPERIN);
    FIND_DICSTOPR_CODE(NSMART_FLAG => 0
                      ,NCOMPANY    => NCOMPANY
                      ,SCODE       => SOPERIN
                      ,NRN         => RINV.IN_STOPER);
    \*Склад прихода*\
    RINV.IN_STORE := NSTOREIN;
    \*МОЛ склада прихода*\
    if (RINV.IN_STORE is not null) then
      UDO_PKG_STORE_OPER_ACC.P_STORE_GET_AGENT(NRNSTORE => RINV.IN_STORE, NRNAGENT => RINV.IN_MOL);
    end if;
    \*Подразделение получатель*\
    RINV.SUBDIV := NDEP;
    \*Документ-основание*\
    RINV.VALID_DOCTYPE := NVALID_DOCTYPE;
    RINV.VALID_DOCNUMB := SVALID_DOCNUMB;
    RINV.VALID_DOCDATE := DVALID_DOCDATE;
    \*Выполняем добавление требования*\
    UDO_PKG_STORE_OPER_ACC.P_INSERT_TRANSINVDEPT(RTRANSINVDEPT => RINV, NRNTRANSINVDEPT => RINV.RN);
    \*Устанавливаем атрибуты инициализации строки требования*\
    UDO_PKG_STORE_OPER_ACC.P_TRANSINVDEPTSPECS_INIT_PARS(RTRANSINVDEPTSPECSINIT => RSP);
    \*Организация*\
    RSP.COMPANY := NCOMPANY;
    \*Регистрационный номер родителя*\
    RSP.PRN := RINV.RN;
    \*Модификация*\
    RSP.NOMMODIF := NMODIF;
    \*Очищаем таблицу выбора партий*\
    UDO_PKG_STORE_OPER_ACC.P_GOODSSUPPLY_SELECT_CLEAR;
    \*Заполняем таблицу выбора партий*\
    UDO_PKG_STORE_OPER_ACC.P_GOODSSUPPLY_SELECT_FILL(NCOMPANY => NCOMPANY
                                                    ,NRNMODIF => NMODIF
                                                    ,NRNSTORE => NSTOREOUT
                                                    ,DDATE    => DDATE);
    \*Подобранное количество*\
    NQUANTSELECT := 0;
    \*Цикл по партиям*\
    for PARTY_CURSOR in (select GS.PRN as NRN
                               ,UDO_PKG_STORE_OPER_ACC.F_GOODSSUPPLYHIST_CALC_MIN_RST(NPRN       => GS.RN
                                                                                     ,DDATEBEGIN => DDATE
                                                                                     ,DDATEEND   => TO_DATE(null)
                                                                                     ,NMUNIT     => 0) \* - gs.RESERV*\ as NQUANT
                           from UDO_T_GOODSSUPPLY_SELECT GSS
                               ,GOODSSUPPLY              GS
                               ,GOODSPARTIES             P
                               ,INCOMDOC                 I
                          where GS.RN = GSS.RN
                            and P.RN = GS.PRN
                            and I.RN = P.INDOC
                          order by I.ENTRY_DATE
                                  ,I.RN)
    loop
      if (NQUANTSELECT < NQUANT) then
        \*Партия*\
        RSP.GOODSPARTY := PARTY_CURSOR.NRN;
        \*Количество*\
        if (NQUANTSELECT + PARTY_CURSOR.NQUANT <= NQUANT) then
          RSP.QUANT := PARTY_CURSOR.NQUANT;
        else
          RSP.QUANT := NQUANT - NQUANTSELECT;
        end if;
        \*Подобранное количество*\
        NQUANTSELECT := NQUANTSELECT + RSP.QUANT;
        \*Выполняем добавление строки требования*\
        UDO_PKG_STORE_OPER_ACC.P_INSERT_TRANSINVDEPTSPECS(RTRANSINVDEPTSPECS   => RSP
                                                         ,NRNTRANSINVDEPTSPECS => RSP.RN);
      end if;
    end loop;
    \*Если не удалось выполнить подбор партий, то выдаем сообщение об ошибке*\
    if (NQUANTSELECT < NQUANT) then
      P_EXCEPTION(0
                 ,'Не удалось выполнить подбор партий. Требуется ' || TO_CHAR(NQUANT) ||
                  ', а на складе доступно ' || TO_CHAR(NQUANTSELECT));
    end if;
    \*Приходная партия*\
    if (F_TRANSINVDEPT_CLC_SGN_NEW_ORD(NCOMPANY => NCOMPANY, NRN => RINV.RN, NCHECKSTATE => 1) = 1) then
      P_TRANSINVDEPT_SET_IN_PATY(NCOMPANY => NCOMPANY, NRN => RINV.RN, SPARTY => SPARTY);
    end if;
    \*Регистрационный номер записи*\
    NRNINV := RINV.RN;
  end P_TRANSINVDEPT_BCREATE_INV_MAT;*/

  /*Процедура выполняет формирование требования на выдачу материала*/
  procedure P_TRANSINVDEPT_CREATE_INV_MAT(NCOMPANY      in number /*Организация*/,
                                          STYPE         in DOCTYPES.DOCCODE%type /*Тип*/,
                                          SNUMBER       in TRANSINVDEPT.NUMB%type /*Номер*/,
                                          DDATE         in TRANSINVDEPT.DOCDATE%type /*Дата*/,
                                          SSTOREOUT     in AZSAZSLISTMT.AZS_NUMBER%type /*Склад расхода*/,
                                          SSTOREOPEROUT in AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type /*Складская операция расхода*/,
                                          SSTOREIN      in AZSAZSLISTMT.AZS_NUMBER%type /*Склад прихода*/,
                                          SDEP          in INS_DEPARTMENT.CODE%type /*Подразделение*/,
                                          SORDER        in FACEACC.NUMB%type /*Заказ*/,
                                          SNOMEN        in DICNOMNS.NOMEN_CODE%type /*Номенклатура*/,
                                          SNOMENNAME    in DICNOMNS.NOMEN_NAME%type /*Наименование номенклатуры*/,
                                          SMODIF        in NOMMODIF.MODIF_CODE%type /*Модификация*/,
                                          SMODIFNAME    in NOMMODIF.MODIF_NAME%type /*Наименование модификации*/,
                                          NQUANT        in TRANSINVDEPTSPECS.QUANT%type /*Количество*/,
                                          SMUNIT        in DICMUNTS.MEAS_MNEMO%type /*Единица измерения*/,
                                          NRNINV        out TRANSINVDEPT.RN%type /*Регистрационный номер записи*/) is
    /*Каталог*/
    NCATALOG ACATALOG.NAME%type;
    /*Юридическое лицо*/
    SJUR_PERS JURPERSONS.CODE%type;
    /*Регистрационный номер юридического лица*/
    NJUR_PERS JURPERSONS.RN%type;
    /*Тип*/
    NTYPE TRANSINVDEPT.DOCTYPE%type;
    /*Склад расхода*/
    NSTOREOUT TRANSINVDEPT.STORE%type;
    /*Склад прихода*/
    NSTOREIN TRANSINVDEPT.IN_STORE%type;
    /*Подразделение*/
    NDEP TRANSINVDEPT.SUBDIV%type;
    /*Складская операция расхода*/
    NSTOREOPEROUT TRANSINVDEPT.STOPER%type;
    /*Заказ*/
    NORDER TRANSINVDEPT.FACEACC%type;
    /*Номенклатура*/
    NNOMEN DICNOMNS.RN%type;
    /*Модификация*/
    NMODIF TRANSINVDEPTSPECS.NOMMODIF%type;
  begin
    /*Каталог*/
    FIND_ACATALOG_NAME(NFLAG_SMART => 1,
                       NCOMPANY    => NCOMPANY,
                       NVERSION    => TO_NUMBER(null),
                       SUNITCODE   => 'GoodsTransInvoicesToDepts',
                       SNAME       => TO_CHAR(DDATE, 'yyyy mm ') || SDEP,
                       NRN         => NCATALOG);
    if (NCATALOG is null) then
      /*Анненко И.С. 30.09.2019 Для подразделения 310 особый алгоритм определения каталога*/
      if (SDEP = '310') then
        FIND_ACATALOG_NAME(NFLAG_SMART => 0,
                           NCOMPANY    => NCOMPANY,
                           NVERSION    => TO_NUMBER(null),
                           SUNITCODE   => 'GoodsTransInvoicesToDepts',
                           SNAME       => SDEP,
                           NRN         => NCATALOG);
      else
        FIND_ACATALOG_NAME(NFLAG_SMART => 0,
                           NCOMPANY    => NCOMPANY,
                           NVERSION    => TO_NUMBER(null),
                           SUNITCODE   => 'GoodsTransInvoicesToDepts',
                           SNAME       => TO_CHAR(DDATE, 'yyyy mm'),
                           NRN         => NCATALOG);
      end if;
    end if;
    /*Юридическое лицо*/
    FIND_JURPERSONS_MAIN(NFLAG_SMART => 0,
                         NCOMPANY    => NCOMPANY,
                         SJUR_PERS   => SJUR_PERS,
                         NJUR_PERS   => NJUR_PERS);
    /*Тип*/
    FIND_DOCTYPES_CODE(NCOMPANY  => NCOMPANY,
                       SDOCCODE  => STYPE,
                       SUNITCODE => 'GoodsTransInvoicesToDepts',
                       NSTYPE    => 0,
                       NRN       => NTYPE);
    /*Склад расхода*/
    FIND_DICSTORE_NUMB(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       SNUMB       => SSTOREOUT,
                       NRN         => NSTOREOUT);
    /*Склад прихода*/
    if (trim(SSTOREIN) is not null) then
      FIND_DICSTORE_NUMB(NFLAG_SMART => 0,
                         NCOMPANY    => NCOMPANY,
                         SNUMB       => trim(SSTOREIN),
                         NRN         => NSTOREIN);
    end if;
    /*Подразделение*/
    FIND_SUBDIVS_CODE(NFLAG_SMART => 0,
                      NCOMPANY    => NCOMPANY,
                      SCODE       => SDEP,
                      NRN         => NDEP);
    /*Складская операция расхода*/
    FIND_DICSTOPR_CODE(NSMART_FLAG => 0,
                       NCOMPANY    => NCOMPANY,
                       SCODE       => SSTOREOPEROUT,
                       NRN         => NSTOREOPEROUT);
    /*Заказ*/
    FIND_FACEACC_NUMB(NFLAG_SMART  => 0,
                      NFLAG_OPTION => 0,
                      NCOMPANY     => NCOMPANY,
                      SNUMB        => SORDER,
                      NRN          => NORDER);
    /*Номенклатура*/
    FIND_DICNOMNS_CODE(NFLAG_SMART  => 0,
                       NFLAG_OPTION => 0,
                       NCOMPANY     => NCOMPANY,
                       SCODE        => SNOMEN,
                       NRN          => NNOMEN);
    /*Модификация*/
    FIND_NOMMODIF_BY_CODE(NPRN => NNOMEN, SCODE => SMODIF, NFRN => NMODIF);
    /*Выполняем базовое формирование требования на выдачу материала для указанного маршрутного листа*/
    /*P_TRANSINVDEPT_BCREATE_INV_MAT(NCOMPANY       => NCOMPANY
    ,NCRN           => NCATALOG
    ,NJUR_PERS      => NJUR_PERS
    ,NTYPE          => NTYPE
    ,SNUMBER        => SNUMBER
    ,DDATE          => DDATE
    ,NSTOREOUT      => NSTOREOUT
    ,NSTOREOPEROUT  => NSTOREOPEROUT
    ,NSTOREIN       => NSTOREIN
    ,NDEP           => NDEP
    ,NORDER         => NORDER
    ,SPARTY         => TO_CHAR(null)
    ,NVALID_DOCTYPE => TO_NUMBER(null)
    ,SVALID_DOCNUMB => TO_CHAR(null)
    ,DVALID_DOCDATE => TO_DATE(null)
    ,NMODIF         => NMODIF
    ,NQUANT         => NQUANT
    ,NRNINV         => NRNINV);*/
    /* фиксация начала выполнения действия */
    PKG_ENV.PROLOGUE(NCOMPANY  => NCOMPANY,
                     NVERSION  => TO_NUMBER(null),
                     NCATALOG  => NCATALOG,
                     SUNIT     => 'GoodsTransInvoicesToDepts',
                     SACTION   => 'GoodsTransInvoicesToDeptsCreateInvMat',
                     STABLE    => 'TRANSINVDEPT',
                     NDOCUMENT => NRNINV);
    /* фиксация окончания выполнения действия */
    PKG_ENV.EPILOGUE(NCOMPANY  => NCOMPANY,
                     NVERSION  => TO_NUMBER(null),
                     NCATALOG  => NCATALOG,
                     SUNIT     => 'GoodsTransInvoicesToDepts',
                     SACTION   => 'GoodsTransInvoicesToDeptsCreateInvMat',
                     STABLE    => 'TRANSINVDEPT',
                     NDOCUMENT => NRNINV);
  end P_TRANSINVDEPT_CREATE_INV_MAT;

  /*Функция определяет признак нулевого склада*/
  function F_DICSTORE_CALC_ZERO_SIGN(NCOMPANY in number /*Организация*/,
                                     NRN      in AZSAZSLISTMT.RN%type /*Регистрационный номер записи*/)
    return number is
    /*Код вида нулевого склада*/
    SZERO_STORE_KIND STKIND.CODE%type;
    /*Регистрационный номер записи вида нулевого склада*/
    NZERO_STORE_KIND STKIND.RN%type;
    /*Количество записей*/
    NCOUNT number;
  begin
    /*Код вида нулевого склада*/
    P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY,
                          SNAME    => 'ВидНулевогоСклада',
                          DDATE    => TO_DATE(null),
                          SVALUE   => SZERO_STORE_KIND);
    /*Регистрационный номер записи вида нулевого склада*/
    FIND_STKIND_CODE(NFLAG_SMART  => 0,
                     NFLAG_OPTION => 0,
                     NCOMPANY     => NCOMPANY,
                     SCODE        => SZERO_STORE_KIND,
                     NRN          => NZERO_STORE_KIND);
    /*Количество записей*/
    select count(1)
      into NCOUNT
      from AZSAZSLISTMT S
     where S.RN = NRN
       and S.COMPANY = NCOMPANY
       and S.STKIND = NZERO_STORE_KIND;
    /*Возвращаем результат*/
    if (NCOUNT = 0) then
      return(0);
    else
      return(1);
    end if;
  end F_DICSTORE_CALC_ZERO_SIGN;

  /*Функция определяет признак нулевого склада для указанного остатка*/
  function F_GOODSSUPPLY_CALC_ZERO_SIGN(NCOMPANY in number /*Организация*/,
                                        NRN      in GOODSSUPPLY.RN%type /*Регистрационный номер записи*/,
                                        NREC     in number /*Уровень рекурсии*/)
    return number is
    /*Склад*/
    NSTORE AZSAZSLISTMT.RN%type;
    /*Регистрационный номер записи приходной партии*/
    NIN_PARTY GOODSSUPPLY.RN%type;
  begin
    /*Обход бесконечной рекурсии*/
    if (NREC > 10) then
      return(0);
    end if;
    /*Обход пустого значения*/
    if (NRN is null) then
      return(0);
    end if;
    /*Склад*/
    begin
      select S.STORE
        into NSTORE
        from GOODSSUPPLY S
       where S.RN = NRN
         and S.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'GoodsSupply');
    end;
    /*Если склад является нулевым, то завершаем работу функции*/
    if (F_DICSTORE_CALC_ZERO_SIGN(NCOMPANY => NCOMPANY, NRN => NSTORE) = 1) then
      return(1);
    end if;
    /*Регистрационный номер записи приходной партии*/
    select /*Анненко И.С. 26.03.2020*/
     max(J2.GOODSSUPPLY)
      into NIN_PARTY
      from STOREOPERJOURN J1, DOCLINKS L1, DOCLINKS L2, STOREOPERJOURN J2
     where J1.GOODSSUPPLY = NRN
       and J1.COMPANY = NCOMPANY
       and J1.OPER_TYPE = 1 /*Приход*/
       and J1.SIGNPLAN = 2 /*Факт*/
       and L1.OUT_UNITCODE = 'StoreOpersJournal'
       and L1.OUT_DOCUMENT = J1.RN
       and L1.IN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
       and L2.IN_DOCUMENT = L1.IN_DOCUMENT
       and L2.IN_UNITCODE = L1.IN_UNITCODE
       and L2.OUT_UNITCODE = L1.OUT_UNITCODE
       and J2.RN = L2.OUT_DOCUMENT
       and J2.OPER_TYPE = 0 /*Расход*/
       and J2.SIGNPLAN = 2 /*Факт*/
       and J2.GOODSSUPPLY <> NRN;
    /*Вычисляем результат*/
    if (NIN_PARTY is null) then
      return(0);
    else
      return(F_GOODSSUPPLY_CALC_ZERO_SIGN(NCOMPANY => NCOMPANY,
                                          NRN      => NIN_PARTY,
                                          NREC     => NREC + 1));
    end if;
  end F_GOODSSUPPLY_CALC_ZERO_SIGN;

  /*Процедура выполняет удаление партии перед отработкой расходной накладной*/
  procedure P_TRANSINVDEPT_REMOVE_IN_PARTY(NCOMPANY in number /*Организация*/,
                                           NRN      in TRANSINVDEPT.RN%type /*Регистрационный номер записи*/) is
    /*Атрибуты партии*/
    RPARTY INCOMDOC%rowtype;
    /*Количество записей*/
    NCOUNT number;
  begin
    /*Код партии*/
    begin
      select N.IN_PARTY_CODE, N.IN_PARTY
        into RPARTY.CODE, RPARTY.RN
        from TRANSINVDEPT N
       where N.RN = NRN
         and N.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'GoodsTransInvoicesToDepts');
    end;
    if (RPARTY.RN is null) then
      /*Если приходная партия не указана, то завершаем работу процедуры*/
      if (RPARTY.CODE is null) then
        return;
      end if;
      /*Выполняем поиск партии*/
      FIND_INCOMDOC_BY_CODE_EX(NFLAG_SMART => 1,
                               NCOMPANY    => NCOMPANY,
                               SCODE       => RPARTY.CODE,
                               NRN         => RPARTY.RN);
    end if;
    /*Если приходная партия не найдена, то завершаем работу процедуры*/
    if (RPARTY.RN is null) then
      return;
    end if;
    /*Количество записей*/
    select count(1)
      into NCOUNT
      from GOODSPARTIES P, GOODSSUPPLY S, STOREOPERJOURN J
     where P.INDOC = RPARTY.RN
       and S.PRN = P.RN
       and J.GOODSSUPPLY = S.RN;
    /*Если по партии уже зарегистрированы складские операции, то завершаем работу процедуры*/
    if (NCOUNT > 0) then
      return;
    end if;
    /*Количество записей*/
    select count(1)
      into NCOUNT
      from GOODSPARTIES P, GOODSSUPPLY S, RESJOURNAL J
     where P.INDOC = RPARTY.RN
       and S.PRN = P.RN
       and J.SUPPLY = S.RN
       and J.RES_END_DATE is null;
    /*Если по партии уже зарегистрированы открытые резервы, то завершаем работу процедуры*/
    if (NCOUNT > 0) then
      return;
    end if;
    /*Цикл по журналу резервирования*/
    for RES_CURSOR in (select J.RN as NRN
                         from GOODSPARTIES P, GOODSSUPPLY S, RESJOURNAL J
                        where P.INDOC = RPARTY.RN
                          and S.PRN = P.RN
                          and J.SUPPLY = S.RN
                          and J.RES_END_DATE is not null) loop
      P_RESJOURNAL_BASE_DELETE(NCOMPANY => NCOMPANY, NRN => RES_CURSOR.NRN);
    end loop;
    /*Цикл по товарным запасам*/
    for SUPPLY_CURSOR in (select S.RN as NRN
                            from GOODSPARTIES P, GOODSSUPPLY S
                           where P.INDOC = RPARTY.RN
                             and S.PRN = P.RN) loop
      /* удаление товарного запаса */
      P_GOODSSUPPLY_BASE_DELETE(NCOMPANY, SUPPLY_CURSOR.NRN);
    end loop;
    /*Цикл по партиям*/
    for PARTY_CURSOR in (select P.RN as NRN
                           from GOODSPARTIES P
                          where P.INDOC = RPARTY.RN) loop
      /* удаление партии товара, если у нее нет товарных запасов */
      P_GOODSPARTIES_BASE_DELETE(NCOMPANY, PARTY_CURSOR.NRN);
    end loop;
    /*Код партии*/
    if (RPARTY.CODE is null) then
      begin
        select I.CODE
          into RPARTY.CODE
          from INCOMDOC I
         where I.RN = RPARTY.RN
           and I.COMPANY = NCOMPANY;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RPARTY.RN,
                                   SUNIT_TABLE => 'IncomingDocuments');
      end;
    end if;
    /*Выполняем очистку ссылки на партию*/
    update TRANSINVDEPT N
       set N.IN_PARTY = TO_NUMBER(null), N.IN_PARTY_CODE = RPARTY.CODE
     where N.RN = NRN
       and N.COMPANY = NCOMPANY;
    /*Выполняем проверку очистки ссылки на партию*/
    if (sql%notfound) then
      PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                               SUNIT_TABLE => 'GoodsTransInvoicesToDepts');
    end if;
    /* удаление партии, если у нее нет партий товара */
    --p_exception(0,RPARTY.RN);
    P_INCOMDOC_BASE_DELETE(NCOMPANY, RPARTY.RN);
  end P_TRANSINVDEPT_REMOVE_IN_PARTY;

  /*Функция возвращает признак необходимости формирования документа списания партии на СГП*/
  function F_INCOMEFROMDEPS_CLC_SGN_CRT_I(NCOMPANY in number /*Организация*/,
                                          NRN      in number /*Регистрационный номер записи*/)
    return number is
    /*Количество записей*/
    NCOUNT number;
  begin
    if (F_DOCLINKS_LINK_IN_DOC(SOUT_UNITCODE => 'IncomFromDeps',
                               NOUT_DOCUMENT => NRN,
                               SIN_UNITCODE  => 'CostRouteLists') is not null) then
      return(0);
    end if;
    select count(1)
      into NCOUNT
      from INCOMEFROMDEPS I, INS_DEPARTMENT D
     where I.RN = NRN
       and I.COMPANY = NCOMPANY
       and D.RN = I.OUT_DEPARTMENT
       and exists (select 1
              from EXTRA_DICTS ED, EXTRA_DICTS_VALUES EDV
             where ED.CODE = 'ПодрСдЭКСП_РасхВыпМЛ'
               and EDV.PRN = ED.RN
               and EDV.STR_VALUE = D.CODE);
    if (NCOUNT = 0) then
      return(0);
    else
      return(1);
    end if;
  end F_INCOMEFROMDEPS_CLC_SGN_CRT_I;

  /*Процедура выполняет формирование расходной накладной для указанного прихода из подразделений*/
  /*procedure P_INCOMEFROMDEPSSP_SGP_CRT_INV
  (
    NCOMPANY in number \*Организация*\
   ,NRN      in INCOMEFROMDEPSSPEC.RN%type \*Регистрационный номер записи*\
  ) is
    \*Атрибуты строки прихода*\
    RINC_SP INCOMEFROMDEPSSPEC%rowtype;
    \*Атрибуты прихода*\
    RINC INCOMEFROMDEPS%rowtype;
    \*Регистрационный номер записи маршрутного листа*\
    NRNLST FCROUTLST.RN%type;
    \*Каталог*\
    SCATALOG ACATALOG.NAME%type;
    \*Тип*\
    SDOCTYPE DOCTYPES.DOCCODE%type;
    \*Складская операция*\
    SSTOPER AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type;
    \*Вид отгрузки*\
    SSHEEPVIEW DICSHPVW.CODE%type;
    \*Атрибуты записи заголовка документа*\
    RINV TRANSINVDEPT%rowtype;
    \*Атрибуты записи строки документа*\
    RINV_SP TRANSINVDEPTSPECS%rowtype;
    \*Сообщение*\
    SMSG PKG_STD.TSTRING;
    \*Подтверждение*\
    SCONFIRM PKG_STD.TSTRING;
    \* маршрутный лист в ПиП *\
    SLST_NUM DOCS_PROPS_VALS.STR_VALUE%type;
  begin
    \*Атрибуты строки прихода*\
    begin
      select S.*
        into RINC_SP
        from INCOMEFROMDEPSSPEC S
       where S.RN = NRN
         and S.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT => NRN, SUNIT_TABLE => 'IncomFromDepsSpecs');
    end;
    \*Атрибуты прихода*\
    begin
      select I.*
        into RINC
        from INCOMEFROMDEPS I
       where I.RN = RINC_SP.PRN
         and I.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT => RINC_SP.PRN, SUNIT_TABLE => 'IncomFromDeps');
    end;
    \*Регистрационный номер маршрутного листа для спецификации прихода из подразделений*\
    SLST_NUM := NVL(UDO_PKG_DOCS_PROPS_VALS.F_DOCS_PROPS_VALS_CALC_STR(SPROPERTY => 'Маршрутный лист'
                                                                      ,SUNITCODE => 'IncomFromDepsSpecs'
                                                                      ,NDOCUMENT => RINC_SP.RN)
                   ,UDO_PKG_DOCS_PROPS_VALS.F_DOCS_PROPS_VALS_CALC_STR(SPROPERTY => 'Маршрутный лист'
                                                                      ,SUNITCODE => 'IncomFromDeps'
                                                                      ,NDOCUMENT => RINC_SP.PRN));
    -- 12/07/2018 Марков МВ. контроль наличия МЛ в свойстве
    if RTRIM(SLST_NUM) is not null then
      UDO_PKG_ASSEMBLY_DETAIL.P_FCROUTLST_SEARCH_NUM(NCOMPANY => NCOMPANY
                                                    ,SNUMBER  => SLST_NUM \*nvl(udo_pkg_docs_props_vals.f_docs_props_vals_calc_str(sproperty => 'Маршрутный лист'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ,sunitcode => 'IncomFromDepsSpecs'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ,ndocument => rinc_sp.rn)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      ,udo_pkg_docs_props_vals.f_docs_props_vals_calc_str(sproperty => 'Маршрутный лист'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ,sunitcode => 'IncomFromDeps'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         ,ndocument => rinc_sp.prn))*\
                                                    ,NRNLST   => NRNLST);
    else
      -- -- 12/07/2018 Марков МВ. нет МЛ и не надо создавать РНОП
      return;
    end if;
    if (1 = 0) then
      \*Устанавливаем атрибуты инициализации РНОвП*\
      P_TRANSINVDEPT_INIT_PARAMS(RTRANSINVDEPTINIT => RINV);
      \*Организация*\
      RINV.COMPANY := NCOMPANY;
      \*Каталог*\
      P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY
                           ,SNAME    => 'ДокСписСГПКаталог'
                           ,DDATE    => TO_DATE(null)
                           ,SVALUE   => SCATALOG);
      FIND_ACATALOG_NAME(NFLAG_SMART => 0
                        ,NCOMPANY    => NCOMPANY
                        ,NVERSION    => TO_NUMBER(null)
                        ,SUNITCODE   => 'GoodsTransInvoicesToDepts'
                        ,SNAME       => SCATALOG
                        ,NRN         => RINV.CRN);
      \*Юридическое лицо*\
      RINV.JUR_PERS := RINC.JUR_PERS;
      \*Тип*\
      P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY
                           ,SNAME    => 'ДокСписСГПТип'
                           ,DDATE    => TO_DATE(null)
                           ,SVALUE   => SDOCTYPE);
      FIND_DOCTYPES_CODE(NCOMPANY  => NCOMPANY
                        ,SDOCCODE  => SDOCTYPE
                        ,SUNITCODE => 'GoodsTransInvoicesToDepts'
                        ,NSTYPE    => 0
                        ,NRN       => RINV.DOCTYPE);
      \*Префикс*\
      RINV.PREF := TO_CHAR(RINC.DOC_DATE, 'yyyy.mm');
      \*Номер*\
      P_TRANSINVDEPT_GETNEXTNUMB(NCOMPANY => NCOMPANY
                                ,STYPE    => SDOCTYPE
                                ,SPREF    => RINV.PREF
                                ,SNUMB    => RINV.NUMB);
      \*Дата*\
      RINV.DOCDATE := TRUNC(sysdate);
      \*Складская операция*\
      P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY
                           ,SNAME    => 'ДокСписСГПСклОпер'
                           ,DDATE    => TO_DATE(null)
                           ,SVALUE   => SSTOPER);
      FIND_DICSTOPR_CODE(NSMART_FLAG => 0
                        ,NCOMPANY    => NCOMPANY
                        ,SCODE       => SSTOPER
                        ,NRN         => RINV.STOPER);
      \*Заказ*\
      RINV.FACEACC := RINC.OUT_FACEACC;
      \*Склад*\
      begin
        select I.STORE
          into RINV.STORE
          from DOCLINKS       L
              ,INCOMEFROMDEPS I
         where L.IN_DOCUMENT = NRNLST
           and L.IN_UNITCODE = 'CostRouteLists'
           and L.OUT_UNITCODE = 'IncomFromDeps'
           and I.RN = L.OUT_DOCUMENT;
      exception
        when NO_DATA_FOUND then
          P_EXCEPTION(0, 'Не удалось определить склад');
        when TOO_MANY_ROWS then
          P_EXCEPTION(0
                     ,'Не удалось однозначно определить склад');
      end;
      \*МОЛ*\
      P_STORE_GET_AGENT(NRNSTORE => RINV.STORE, NRNAGENT => RINV.MOL);
      \*Вид отгрузки*\
      P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY
                           ,SNAME    => 'ДокСписСГПВидОтгр'
                           ,DDATE    => TO_DATE(null)
                           ,SVALUE   => SSHEEPVIEW);
      FIND_DICSHPVW_CODE(NFLAG_SMART => 0
                        ,NCOMPANY    => NCOMPANY
                        ,SCODE       => SSHEEPVIEW
                        ,NRN         => RINV.SHEEPVIEW);
      \*Подразделение*\
      P_STORE_GET_DEP(NRNSTORE => RINV.STORE, NRNDEP => RINV.SUBDIV);
      \*Валюта*\
      RINV.CURRENCY := F_CURBASE_GET_RN(NFLAG_SMART => 0, NCOMPANY => NCOMPANY);
      \*Склад получатель*\
      RINV.IN_STORE := TO_NUMBER(null);
      \*МОЛ склада получателя*\
      RINV.IN_MOL := TO_NUMBER(null);
      \*Складская операция прихода*\
      RINV.IN_STOPER := TO_NUMBER(null);
      \*Партия приходная*\
      RINV.IN_PARTY_CODE := TO_CHAR(null);
      \*Документ-основание*\
      begin
        select FA.VALID_DOCTYPE
              ,FA.VALID_DOCNUMB
              ,FA.VALID_DOCDATE
          into RINV.VALID_DOCTYPE
              ,RINV.VALID_DOCNUMB
              ,RINV.VALID_DOCDATE
          from FACEACC FA
         where FA.RN = RINV.FACEACC
           and FA.COMPANY = NCOMPANY;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT => RINV.FACEACC, SUNIT_TABLE => 'FaceAccounts');
      end;
      \*Процедура устанавливает атрибуты инициализации спецификации РНОвП*\
      P_TRANSINVDEPTSPECS_INIT_PARS(RTRANSINVDEPTSPECSINIT => RINV_SP);
      \*Выполняем добавление РНОвП*\
      P_INSERT_TRANSINVDEPT(RTRANSINVDEPT => RINV, NRNTRANSINVDEPT => RINV.RN);
      \*Организация*\
      RINV_SP.COMPANY := NCOMPANY;
      \*Регистрационный номер родителя*\
      RINV_SP.PRN := RINV.RN;
      \*Партия*\
      \*Модификация*\
      begin
        select GS.PRN
              ,S.NOMMODIF
          into RINV_SP.GOODSPARTY
              ,RINV_SP.NOMMODIF
          from DOCLINKS           L
              ,INCOMEFROMDEPSSPEC S
              ,GOODSSUPPLY        GS
         where L.IN_DOCUMENT = NRNLST
           and L.IN_UNITCODE = 'CostRouteLists'
           and L.OUT_UNITCODE = 'IncomFromDeps'
           and S.PRN = L.OUT_DOCUMENT
           and GS.RN = S.SUPPLY;
      exception
        when NO_DATA_FOUND then
          P_EXCEPTION(0, 'Не удалось определить партию');
        when TOO_MANY_ROWS then
          P_EXCEPTION(0
                     ,'Не удалось однозначно  определить партию');
      end;
      \*Количество*\
      RINV_SP.QUANT := RINC_SP.QUANT_FACT;
      \*Выполняем добавление спецификации РНОвП*\
      P_INSERT_TRANSINVDEPTSPECS(RTRANSINVDEPTSPECS => RINV_SP, NRNTRANSINVDEPTSPECS => RINV_SP.RN);
      \*Создаем связь с заголовком документа*\
      PKG_DOCLINKS.LINK(NFLAG_SMART   => 0
                       ,NCOMPANY      => NCOMPANY
                       ,SIN_UNITCODE  => 'GoodsTransInvoicesToDepts'
                       ,NIN_DOCUMENT  => RINV.RN
                       ,SOUT_UNITCODE => 'IncomFromDeps'
                       ,NOUT_DOCUMENT => RINC_SP.PRN
                       ,NBREAKUP_KIND => 0);
      \*Создаем связь со строкой документа*\
      PKG_DOCLINKS.LINK(NFLAG_SMART   => 0
                       ,NCOMPANY      => NCOMPANY
                       ,SIN_UNITCODE  => 'GoodsTransInvoicesToDepts'
                       ,NIN_DOCUMENT  => RINV.RN
                       ,SOUT_UNITCODE => 'IncomFromDepsSpecs'
                       ,NOUT_DOCUMENT => RINC_SP.RN
                       ,NBREAKUP_KIND => 0);
      \*Выполняем отработку документа*\
      P_TRANSINVDEPT_SET_STATUS(NCOMPANY      => NCOMPANY
                               ,NRN           => RINV.RN
                               ,NSTATUS       => 2
                               ,NIN_STATUS    => 0
                               ,DIN_WORK_DATE => TO_DATE(null)
                               ,DWORK_DATE    => RINC.DOC_DATE
                               ,SMSG          => SMSG
                               ,SCONFIRM      => SCONFIRM);
    end if;
    begin
      select GS.PRN
        into RINV_SP.GOODSPARTY
        from DOCLINKS           L
            ,INCOMEFROMDEPSSPEC S
            ,GOODSSUPPLY        GS
       where L.IN_DOCUMENT = NRNLST
         and L.IN_UNITCODE = 'CostRouteLists'
         and L.OUT_UNITCODE = 'IncomFromDeps'
         and S.PRN = L.OUT_DOCUMENT
         and GS.RN = S.SUPPLY;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0, 'Не удалось определить партию');
      when TOO_MANY_ROWS then
        P_EXCEPTION(0
                   ,'Не удалось однозначно  определить партию');
    end;
    \*Выполняем поиск товарного запаса*\
    FIND_GOODSSUPPLY_BY_STORE(NCOMPANY    => NCOMPANY
                             ,NFLAG_SMART => 1
                             ,NPRN        => RINV_SP.GOODSPARTY
                             ,SSTORE      => F_DICSTORE_GET_NUMB(NSTORE => RINC.STORE)
                             ,NRN         => RINC_SP.SUPPLY);
    \*Выполняем добавление товарного запаса*\
    if (RINC_SP.SUPPLY is null) then
      P_GOODSSUPPLY_BASE_INSERT(NCOMPANY  => NCOMPANY
                               ,NPRN      => RINV_SP.GOODSPARTY
                               ,NSTORE    => RINC.STORE
                               ,SCARDNUMB => null -- релиз от 20/06/2018 Марков МВ.
                               ,NRN       => RINC_SP.SUPPLY);
    end if;
    \*Выполняем исправление записи*\
    update INCOMEFROMDEPSSPEC S
       set S.SUPPLY  = RINC_SP.SUPPLY
          ,S.SERNUMB = TO_CHAR(null)
     where S.RN = RINC_SP.RN
       and S.COMPANY = NCOMPANY;
    \*Выполняем проверку исправления записи*\
    if (sql%notfound) then
      PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT => RINC_SP.RN, SUNIT_TABLE => 'IncomFromDepsSpecs');
    end if;
  end P_INCOMEFROMDEPSSP_SGP_CRT_INV;*/

  /*Процедура выполняет расформирование расходной накладной для указанного прихода из подразделений*/
  /*procedure P_INCOMEFROMDEPSSP_SGP_RMV_INV
  (
    NCOMPANY in number \*Организация*\
   ,NRN      in INCOMEFROMDEPSSPEC.RN%type \*Регистрационный номер записи*\
  ) is
    \*Атрибуты строки прихода*\
    RINC_SP INCOMEFROMDEPSSPEC%rowtype;
    \*Регистрационный номер записи накладной*\
    NRN_INV PKG_STD.TREF;
    \*Сообщение*\
    SMSG PKG_STD.TSTRING;
    \*Подтверждение*\
    SCONFIRM PKG_STD.TSTRING;
  begin
    \*Атрибуты строки прихода*\
    begin
      select S.*
        into RINC_SP
        from INCOMEFROMDEPSSPEC S
       where S.RN = NRN
         and S.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT => NRN, SUNIT_TABLE => 'IncomFromDepsSpecs');
    end;
    \*Регистрационный номер записи накладной*\
    NRN_INV := F_DOCLINKS_LINK_IN_DOC(SOUT_UNITCODE => 'IncomFromDepsSpecs'
                                     ,NOUT_DOCUMENT => NRN
                                     ,SIN_UNITCODE  => 'GoodsTransInvoicesToDepts');
    \*Если не удалось определить документ списания партии готовых изделий, то выдаем сообщение об ошибке*\
    if (NRN_INV is null) then
      return;
      \*   если связи нет, то выходим 12/07/2018 Бухвин
      p_exception(0
                 ,'Не удалось определить документ списания партии готовых изделий');*\
    end if;
    \*Разрываем связь с заголовком*\
    PKG_DOCLINKS.REMOVE(SIN_UNITCODE  => 'GoodsTransInvoicesToDepts'
                       ,NIN_DOCUMENT  => NRN_INV
                       ,SOUT_UNITCODE => 'IncomFromDeps'
                       ,NOUT_DOCUMENT => RINC_SP.PRN);
    \*Создаем связь со спецификацией*\
    PKG_DOCLINKS.REMOVE(SIN_UNITCODE  => 'GoodsTransInvoicesToDepts'
                       ,NIN_DOCUMENT  => NRN_INV
                       ,SOUT_UNITCODE => 'IncomFromDepsSpecs'
                       ,NOUT_DOCUMENT => RINC_SP.RN);
    \*Снимаем отработку с документа*\
    P_TRANSINVDEPT_SET_STATUS(NCOMPANY      => NCOMPANY
                             ,NRN           => NRN_INV
                             ,NSTATUS       => 0
                             ,NIN_STATUS    => 0
                             ,DIN_WORK_DATE => TO_DATE(null)
                             ,DWORK_DATE    => TRUNC(sysdate)
                             ,SMSG          => SMSG
                             ,SCONFIRM      => SCONFIRM);
    \*Выполняем базовое удаление документа*\
    P_TRANSINVDEPT_BASE_DELETE(NCOMPANY => NCOMPANY, NRN => NRN_INV);
  end P_INCOMEFROMDEPSSP_SGP_RMV_INV;*/

  /*Процедура выполняет формирование расходной накладной для указанного прихода из подразделений*/
  /*procedure P_INCOMEFROMDEPS_SGP_CRT_INV
  (
    NCOMPANY in number \*Организация*\
   ,NRN      in INCOMEFROMDEPS.RN%type \*Регистрационный номер записи*\
  ) is
  begin
    \*Очищаем партии в заголовке*\
    update INCOMEFROMDEPS I
       set I.PARTY    = TO_CHAR(null)
          ,I.PARTY_RN = TO_NUMBER(null)
     where I.RN = NRN
       and I.COMPANY = NCOMPANY;
    \*Выполняем проверку очистки партий в заголовке*\
    if (sql%notfound) then
      PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT => NRN, SUNIT_TABLE => 'IncomFromDeps');
    end if;
    \*Цикл по строкам прихода*\
    for SP_CURSOR in (select S.RN as NRN
                        from INCOMEFROMDEPSSPEC S
                       where S.PRN = NRN
                         and S.COMPANY = NCOMPANY)
    loop
      P_INCOMEFROMDEPSSP_SGP_CRT_INV(NCOMPANY => NCOMPANY, NRN => SP_CURSOR.NRN);
    end loop;
  end P_INCOMEFROMDEPS_SGP_CRT_INV;*/

  /*Процедура выполняет расформирование расходной накладной для указанного прихода из подразделений*/
  /*procedure P_INCOMEFROMDEPS_SGP_RMV_INV
  (
    NCOMPANY in number \*Организация*\
   ,NRN      in INCOMEFROMDEPS.RN%type \*Регистрационный номер записи*\
  ) is
  begin
    return;
    \*Цикл по строкам прихода*\
    for SP_CURSOR in (select S.RN as NRN
                        from INCOMEFROMDEPSSPEC S
                       where S.PRN = NRN
                         and S.COMPANY = NCOMPANY)
    loop
      P_INCOMEFROMDEPSSP_SGP_RMV_INV(NCOMPANY => NCOMPANY, NRN => SP_CURSOR.NRN);
    end loop;
  end P_INCOMEFROMDEPS_SGP_RMV_INV;*/

  /*Процедура выполняет базовое формирование приходного документа для указанной расходной накладной*/
  /*procedure P_TRANSINVDEPT_BCREATE_INDOC
  (
    NCOMPANY  in number \*Регистрационный номер организации*\
   ,NRN       in number \*Регистрационный номер записи*\
   ,NCATALOG  in ACATALOG.RN%type \*Каталог*\
   ,NNOMEN    in DICNOMNS.RN%type \*Номенклатура*\
   ,NPRICE    in number \*Цена*\
   ,NRN_INDOC out number \*Регистрационный номер записи приходного документа*\
  ) is
    \*Атрибуты записи расходной накладной*\
    RINV TRANSINVDEPT%rowtype;
    \*Атрибуты записи спецификации расходной накладаной*\
    --RINV_SP TRANSINVDEPTSPECS%rowtype;
    \*Атрибуты прихода из подразделения*\
    RINCOMEFROMDEPS INCOMEFROMDEPS%rowtype;
    \*Атрибуты спецификации прихода из подразделений*\
    RINCOMEFROMDEPSSPEC INCOMEFROMDEPSSPEC%rowtype;
    \*Предупреждение*\
    NWARNING number;
    \*Сообщение об ошибке*\
    SMESSAGE PKG_STD.TSTRING;
  begin
    \*Если приходный документ уже сформирован, то выдаем сообщение об ошибке*\
    if (F_DOCLINKS_LINK_OUT_DOC(SIN_UNITCODE  => 'GoodsTransInvoicesToDepts'
                               ,NIN_DOCUMENT  => NRN
                               ,SOUT_UNITCODE => 'IncomFromDeps') is not null) then
      P_EXCEPTION(0, 'Приходный документ уже сформирован');
    end if;
    \*Атрибуты записи расходной накладной*\
    begin
      select N.*
        into RINV
        from TRANSINVDEPT N
       where N.RN = NRN
         and N.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT => NRN, SUNIT_TABLE => 'GoodsTransInvoicesToDepts');
    end;
    \*Если документ не отработан, то выдаем сообщение об оишбке*\
    if (RINV.STATUS <> 1) then
      P_EXCEPTION(0, 'Документ не отработан');
    end if;
    \*Если документ отработан с приходом, то выдаем сообщение об оишбке*\
    if (RINV.IN_STATUS = 1) then
      P_EXCEPTION(0, 'Документ отработан с приходом');
    end if;
    \*Если не указан склад-получатель, то выдаем сообщение об оишбке*\
    if (RINV.IN_STORE is null) then
      P_EXCEPTION(0, 'Не указан склад-получатель');
    end if;
    \*Если не указана складская операция прихода, то выдаем сообщение об оишбке*\
    if (RINV.IN_STOPER is null) then
      P_EXCEPTION(0, 'Не указана складская операция прихода');
    end if;
    \*Устанавливаем атрибуты инициализации прихода из подразделений*\
    P_INCOMEFROMDEPS_INIT_PARAMS(RINCOMEFROMDEPSINIT => RINCOMEFROMDEPS);
    \*Регистрационный номер организации*\
    RINCOMEFROMDEPS.COMPANY := NCOMPANY;
    \*Каталог*\
    RINCOMEFROMDEPS.CRN := NCATALOG;
    \*Юридическое лицо*\
    RINCOMEFROMDEPS.JUR_PERS := RINV.JUR_PERS;
    \*Тип*\
    RINCOMEFROMDEPS.DOC_TYPE := RINV.DOCTYPE;
    \*Префикс*\
    RINCOMEFROMDEPS.DOC_PREF := RINV.PREF;
    \*Номер*\
    RINCOMEFROMDEPS.DOC_NUMB := RINV.NUMB;
    \*Дата*\
    RINCOMEFROMDEPS.DOC_DATE := RINV.DOCDATE;
    \*Склад*\
    RINCOMEFROMDEPS.OUT_STORE := RINV.STORE;
    \*Подразделение*\
    P_STORE_GET_DEP(NRNSTORE => RINCOMEFROMDEPS.OUT_STORE
                   ,NRNDEP   => RINCOMEFROMDEPS.OUT_DEPARTMENT);
    \*Выполняем установку партии*\
    for sp_cursor in (select s.GOODSPARTY
                        from transinvdeptspecs s
                       where S.PRN = NRN
                         and S.COMPANY = NCOMPANY
                         --and udo_f_goodsparties_faceacc(nrn => s.GOODSPARTY) is null
                         )
    loop
      udo_pkg_goodsparties_ext.p_goodsparties_set_prod_order(ncompany   => ncompany
                                                            ,nrn        => sp_cursor.GOODSPARTY
                                                            ,sprodorder => '90-0-0000');
    end loop;
    \*Заказ*\
    begin
      select distinct P.FACEACC
        into RINCOMEFROMDEPS.OUT_FACEACC
        from TRANSINVDEPTSPECS      S
            ,UDO_T_GOODSPARTIES_EXT P
       where S.PRN = NRN
         and S.COMPANY = NCOMPANY
         and P.PRN(+) = S.GOODSPARTY;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0, 'Не удалось определить ШПЗ. TRANSINVDEPT.RN:%s', nRN);
      when TOO_MANY_ROWS then
        P_EXCEPTION(0, 'Не удалось однозначно определить ШПЗ');
    end;
    \*Склад*\
    RINCOMEFROMDEPS.STORE := RINV.IN_STORE;
    \*МОЛ*\
    P_STORE_GET_AGENT(NRNSTORE => RINCOMEFROMDEPS.STORE, NRNAGENT => RINCOMEFROMDEPS.AGENT);
    \*Валюта*\
    RINCOMEFROMDEPS.CURRENCY := F_CURBASE_GET_RN(NFLAG_SMART => 0, NCOMPANY => NCOMPANY);
    \*Складская операция*\
    RINCOMEFROMDEPS.STORE_OPER := RINV.IN_STOPER;
    \*Подразделение*\
    begin
      select distinct D.SUBDIV
        into RINCOMEFROMDEPS.OUT_DEPARTMENT
        from TRANSINVDEPTSPECS S
            ,GOODSPARTIES      P
            ,INCOMDOC          D
       where S.PRN = NRN
         and S.COMPANY = NCOMPANY
         and P.RN = S.GOODSPARTY
         and D.RN = P.INDOC
         and D.SUBDIV is not null -- 18/01/2019 Марков МВ. только для указанных подразделений
      ;
    exception
      when NO_DATA_FOUND then
        RINCOMEFROMDEPS.OUT_DEPARTMENT := to_number(null);
        --P_EXCEPTION(0,
      --          'Не удалось определить подразделение');
      when TOO_MANY_ROWS then
        P_EXCEPTION(0
                   ,'Не удалось однозначно определить подразделение');
    end;
    \*Выполняем базовое добавление прихода из подразделений*\
    P_INSERT_INCOMEFROMDEPS(RINCOMEFROMDEPS   => RINCOMEFROMDEPS
                           ,NRNINCOMEFROMDEPS => RINCOMEFROMDEPS.RN);
    \*Устанавливаем атрибуты инициализации строки прихода из подразделений*\
    P_INCOMEFROMDEPSSP_INIT_PARAMS(RINCOMEFROMDEPSSPECINIT => RINCOMEFROMDEPSSPEC);
    \*Регистрационный номер организации*\
    RINCOMEFROMDEPSSPEC.COMPANY := NCOMPANY;
    \*Регистрационный номер родителя*\
    RINCOMEFROMDEPSSPEC.PRN := RINCOMEFROMDEPS.RN;
    \*Номенклатура*\
    begin
      select NM.RN
        into RINCOMEFROMDEPSSPEC.NOMMODIF
        from NOMMODIF NM
       where NM.PRN = NNOMEN;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0
                   ,'Не удалось определить модификацию номенклатуры');
      when TOO_MANY_ROWS then
        P_EXCEPTION(0
                   ,'Не удалось однозначно определить модификацию номенклатуры');
    end;
    \*Цикл по строкам документа*\
    for INV_SP_CURSOR in (select P.INDOC
                                ,S.*
                            from TRANSINVDEPTSPECS S
                                ,GOODSPARTIES      P
                           where S.PRN = NRN
                             and S.COMPANY = NCOMPANY
                             and P.RN = S.GOODSPARTY)
    loop
      \*Поиск партии*\
      begin
        select P.RN
          into INV_SP_CURSOR.GOODSPARTY
          from GOODSPARTIES P
         where P.INDOC = INV_SP_CURSOR.INDOC
           and P.NOMMODIF = RINCOMEFROMDEPSSPEC.NOMMODIF
           and P.COMPANY = INV_SP_CURSOR.COMPANY;
      exception
        when NO_DATA_FOUND then
          INV_SP_CURSOR.GOODSPARTY := TO_NUMBER(null);
        when TOO_MANY_ROWS then
          P_EXCEPTION(0
                     ,'Не удалось однозначно определить партию');
      end;
      \*Добавление партии*\
      if (INV_SP_CURSOR.GOODSPARTY is null) then
        P_GOODSPARTIES_BASE_INSERT(NCOMPANY       => INV_SP_CURSOR.COMPANY
                                  ,NINDOC         => INV_SP_CURSOR.INDOC
                                  ,NNOMMODIF      => RINCOMEFROMDEPSSPEC.NOMMODIF
                                  ,NNOMNMODIFPACK => TO_NUMBER(null)
                                  ,NSIGNBREAK     => 0
                                  ,DEXPIRY_DATE   => TO_DATE(null)
                                  ,SCERTIFICATE   => TO_CHAR(null)
                                  ,SSERNUMB       => TO_CHAR(null)
                                  ,SBARCODE       => TO_CHAR(null)
                                  ,NCOUNTRY       => TO_NUMBER(null)
                                  ,SGTD           => TO_CHAR(null)
                                  ,NPRODUCER      => TO_NUMBER(null)
                                  ,NSTORAGE_TIME  => TO_NUMBER(null)
                                  ,NUMEAS_STORAGE => TO_NUMBER(null)
                                  ,SORIGINAL_NAME => TO_CHAR(null)
                                  ,DPROD_DATE     => TO_DATE(null)
                                  ,NRN            => INV_SP_CURSOR.GOODSPARTY);
      end if;
      \*Партия*\
      FIND_GOODSSUPPLY_BY_STORE(NCOMPANY    => NCOMPANY
                               ,NFLAG_SMART => 1
                               ,NPRN        => INV_SP_CURSOR.GOODSPARTY
                               ,SSTORE      => F_DICSTORE_GET_NUMB(NSTORE => RINCOMEFROMDEPS.STORE)
                               ,NRN         => RINCOMEFROMDEPSSPEC.SUPPLY);
      if (RINCOMEFROMDEPSSPEC.SUPPLY is null) then
        P_GOODSSUPPLY_BASE_INSERT(NCOMPANY  => NCOMPANY
                                 ,NPRN      => INV_SP_CURSOR.GOODSPARTY
                                 ,NSTORE    => RINCOMEFROMDEPS.STORE
                                 ,SCARDNUMB => TO_CHAR(null)
                                 ,NRN       => RINCOMEFROMDEPSSPEC.SUPPLY);
      end if;
      \*Плановое количество*\
      RINCOMEFROMDEPSSPEC.QUANT_PLAN := INV_SP_CURSOR.QUANT;
      \*Фактическое количество*\
      RINCOMEFROMDEPSSPEC.QUANT_FACT := INV_SP_CURSOR.QUANT;
      \*Плановое количество*\
      RINCOMEFROMDEPSSPEC.QUANT_PLAN_ALT := INV_SP_CURSOR.QUANTALT;
      \*Фактическое количество*\
      RINCOMEFROMDEPSSPEC.QUANT_FACT_ALT := INV_SP_CURSOR.QUANTALT;
      \*Цена*\
      RINCOMEFROMDEPSSPEC.PRICE := NVL(NPRICE, 0);
      \*Сумма план*\
      RINCOMEFROMDEPSSPEC.SUMM_PLAN := NVL(RINCOMEFROMDEPSSPEC.PRICE, 0) *
                                       RINCOMEFROMDEPSSPEC.QUANT_PLAN;
      \*Сумма факт*\
      RINCOMEFROMDEPSSPEC.SUMM_FACT := NVL(RINCOMEFROMDEPSSPEC.PRICE, 0) *
                                       RINCOMEFROMDEPSSPEC.QUANT_FACT;
      \*Выполняем базовое добавление строки прихода из подразделений*\
      P_INSERT_INCOMEFROMDEPSSPEC(RINCOMEFROMDEPSSPEC   => RINCOMEFROMDEPSSPEC
                                 ,NRNINCOMEFROMDEPSSPEC => RINCOMEFROMDEPSSPEC.RN);
    end loop;
    \*Создаем связь*\
    PKG_DOCLINKS.LINK(NFLAG_SMART   => 0
                     ,NCOMPANY      => NCOMPANY
                     ,SIN_UNITCODE  => 'GoodsTransInvoicesToDepts'
                     ,NIN_DOCUMENT  => NRN
                     ,SOUT_UNITCODE => 'IncomFromDeps'
                     ,NOUT_DOCUMENT => RINCOMEFROMDEPS.RN
                     ,NBREAKUP_KIND => 0);
    \*Выполняем отработку прихода из подразделений*\
    P_INCOMEFROMDEPS_SET_STATUS(NCOMPANY  => NCOMPANY
                               ,NRN       => RINCOMEFROMDEPS.RN
                               ,NSTATUS   => 2 \*Отработан как факт*\
                               ,DWORKDATE => RINV.WORK_DATE
                               ,NWARNING  => NWARNING
                               ,SMSG      => SMESSAGE);
    \*Устанавливаем регистрационный номер записи*\
    NRN_INDOC := RINCOMEFROMDEPS.RN;
  end P_TRANSINVDEPT_BCREATE_INDOC;*/

  /*Процедура выполняет формирование приходного документа для указанной расходной накладной*/
  /*procedure P_TRANSINVDEPT_CREATE_INDOC
  (
    NCOMPANY  in number \*Регистрационный номер организации*\
   ,NRN       in number \*Регистрационный номер записи*\
   ,SCATALOG  in ACATALOG.NAME%type \*Каталог*\
   ,SNOMEN    in DICNOMNS.NOMEN_CODE%type \*Номенклатура*\
   ,NPRICE    in number \*Цена*\
   ,NRN_INDOC out number \*Регистрационный номер записи приходного документа*\
  ) is
    \*Каталог*\
    NCRN PKG_STD.TREF;
    \*Каталог*\
    NCATALOG PKG_STD.TREF;
    \*Номенклатура*\
    NNOMEN PKG_STD.TREF;
  begin
    \*Выполняем проверку существования накладной*\
    P_TRANSINVDEPT_EXISTS(NCOMPANY => NCOMPANY, NRN => NRN, NCRN => NCRN);
    \*Каталог*\
    FIND_ACATALOG_NAME(NFLAG_SMART => 0
                      ,NCOMPANY    => NCOMPANY
                      ,NVERSION    => TO_NUMBER(null)
                      ,SUNITCODE   => 'IncomFromDeps'
                      ,SNAME       => SCATALOG
                      ,NRN         => NCATALOG);
    \*Номенклатура*\
    FIND_DICNOMNS_BY_CODE(NFLAG_SMART => 0
                         ,NCOMPANY    => NCOMPANY
                         ,SNOMEN_CODE => SNOMEN
                         ,NRN         => NNOMEN);
    \*Пролог*\
    PKG_ENV.PROLOGUE(NCOMPANY  => NCOMPANY
                    ,NVERSION  => TO_NUMBER(null)
                    ,NCATALOG  => NCRN
                    ,SUNIT     => 'GoodsTransInvoicesToDepts'
                    ,SACTION   => 'GoodsTransInvoicesToDeptsCreateInDoc'
                    ,STABLE    => 'TRANSINVDEPT'
                    ,NDOCUMENT => NRN);
    \*Выполняем базовое формирование приходного документа для указанной расходной накладной*\
    P_TRANSINVDEPT_BCREATE_INDOC(NCOMPANY  => NCOMPANY
                                ,NRN       => NRN
                                ,NCATALOG  => NCATALOG
                                ,NNOMEN    => NNOMEN
                                ,NPRICE    => NPRICE
                                ,NRN_INDOC => NRN_INDOC);
    \*Эпилог*\
    PKG_ENV.EPILOGUE(NCOMPANY  => NCOMPANY
                    ,NVERSION  => TO_NUMBER(null)
                    ,NCATALOG  => NCRN
                    ,SUNIT     => 'GoodsTransInvoicesToDepts'
                    ,SACTION   => 'GoodsTransInvoicesToDeptsCreateInDoc'
                    ,STABLE    => 'TRANSINVDEPT'
                    ,NDOCUMENT => NRN);
  end P_TRANSINVDEPT_CREATE_INDOC;*/

  /*Процедура выполняет формирование приходного документа для указанной расходной накладной*/
  procedure P_TRANSINVCUST_CREATE_INDOC(NCOMPANY    in number /*Организация*/,
                                        NRN         in TRANSINVCUST.RN%type /*Регистрационный номер записи*/,
                                        SCATALOG    in ACATALOG.NAME%type /*Каталог*/,
                                        NRN_INC_SGP out INCOMEFROMDEPS.RN%type /*Регистрационный номер прихода*/) is
    /*Каталог*/
    NCATALOG ACATALOG.RN%type;
    /*Тип документа*/
    SDOC_TYPE DOCTYPES.DOCCODE%type;
    /*Вид складской операции*/
    SSTORE_OPER AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type;
    /*Атрибуты записи накладной*/
    RINV TRANSINVCUST%rowtype;
    /*Атрибуты записи заголовка документа*/
    RINC INCOMEFROMDEPS%rowtype;
    /*Атрибуты записи строки документа*/
    RINC_SP INCOMEFROMDEPSSPEC%rowtype;
    /*Предупреждение*/
    NWARNING number;
    /*Сообщение об ошибке*/
    SMESSAGE PKG_STD.TSTRING;
    NMESSAGE PKG_STD.TNUMBER;
    /*Количество записей*/
    NCOUNT number;
    /*идентификатор процесса*/
    nID PKG_STD.tREF;
  begin
    /*Каталог*/
    FIND_ACATALOG_NAME(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       NVERSION    => null,
                       SUNITCODE   => 'IncomFromDeps',
                       SNAME       => SCATALOG,
                       NRN         => NCATALOG);
    /*Атрибуты записи накладной*/
    begin
      select N.*
        into RINV
        from TRANSINVCUST N
       where N.RN = NRN
         and N.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'GoodsTransInvoicesToConsumers');
    end;
    /*Количество записей*/
    select count(1)
      into NCOUNT
      from TRANSINVCUSTSPECS S
     where S.PRN = NRN
       and S.COMPANY = NCOMPANY
       and S.QUANT <> 0;
    /*Если в товарной спецификации нет позиций, то завершаем работу процедуры*/
    if (NCOUNT = 0) then
      return;
    end if;
    /*Выполняем установку атрибутов инициализации заголовка документа*/
    UDO_PKG_STORE_OPER_ACC.P_INCOMEFROMDEPS_INIT_PARAMS(RINCOMEFROMDEPSINIT => RINC);
    /*Организация*/
    RINC.COMPANY := NCOMPANY;
    /*Каталог*/
    RINC.CRN := NCATALOG;
    /*Юридическое лицо*/
    RINC.JUR_PERS := RINV.JUR_PERS;
    /*Тип документа*/
    P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY,
                          SNAME    => 'ПриходПодРеализациюТип',
                          DDATE    => TO_DATE(null),
                          SVALUE   => SDOC_TYPE);
    FIND_DOCTYPES_CODE(NCOMPANY  => NCOMPANY,
                       SDOCCODE  => SDOC_TYPE,
                       SUNITCODE => 'IncomFromDeps',
                       NSTYPE    => 0,
                       NRN       => RINC.DOC_TYPE);
    /*Префикс*/
    RINC.DOC_PREF := RINV.PREF;
    /*Номер*/
    RINC.DOC_NUMB := RINV.NUMB;
    /*Дата*/
    RINC.DOC_DATE := RINV.DOCDATE;
    /*Заказ*/
    RINC.OUT_FACEACC := TO_NUMBER(null);
    /*Документ-основание*/
    if (RINC.OUT_FACEACC is not null) then
      begin
        select distinct FA.VALID_DOCTYPE,
                        FA.VALID_DOCNUMB,
                        FA.VALID_DOCDATE
          into RINC.VALID_DOCTYPE, RINC.VALID_DOCNUMB, RINC.VALID_DOCDATE
          from FACEACC FA
         where FA.RN = RINC.OUT_FACEACC;
      exception
        when NO_DATA_FOUND then
          PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RINC.OUT_FACEACC,
                                   SUNIT_TABLE => 'FaceAccounts');
      end;
    end if;
    /*Подразделение*/
    RINC.OUT_DEPARTMENT := RINV.SUBDIV;
    /*Префикс*/
    if (RINC.DOC_PREF is null) then
      RINC.DOC_PREF := udo_get_subdiv_code_id(nFLAG_SMART => 0,
                                              NRN         => RINC.OUT_DEPARTMENT) ||
                       TO_CHAR(RINC.DOC_DATE, 'yymm');
    end if;
    /*Склад*/
    RINC.STORE := RINV.STORE;
    /*МОЛ*/
    P_STORE_GET_AGENT(NRNSTORE => RINC.STORE, NRNAGENT => RINC.AGENT);
    /*Валюта*/
    RINC.CURRENCY := F_CURBASE_GET_RN(NFLAG_SMART => 0,
                                      NCOMPANY    => NCOMPANY);
    /*Вид складской операции*/
    P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY,
                          SNAME    => 'ПриходПодРеализациюСклОпер',
                          DDATE    => TO_DATE(null),
                          SVALUE   => SSTORE_OPER);
    FIND_DICSTOPR_CODE(NSMART_FLAG => 0,
                       NCOMPANY    => NCOMPANY,
                       SCODE       => SSTORE_OPER,
                       NRN         => RINC.STORE_OPER);
    /*Партия*/
    RINC.PARTY := udo_get_subdiv_code_id(nFLAG_SMART => 0,
                                         NRN         => RINC.OUT_DEPARTMENT) ||
                  TO_CHAR(RINC.DOC_DATE, 'yymm') || '_' ||
                  trim(RINC.DOC_NUMB);
    /*Выполняем добавление заголовка документа*/
    UDO_PKG_STORE_OPER_ACC.P_INSERT_INCOMEFROMDEPS(RINCOMEFROMDEPS   => RINC,
                                                   NRNINCOMEFROMDEPS => RINC.RN);
    /*Выполняем установку атрибутов инициализации строки документа*/
    UDO_PKG_STORE_OPER_ACC.P_INCOMEFROMDEPSSP_INIT_PARAMS(RINCOMEFROMDEPSSPECINIT => RINC_SP);
    /*Организация*/
    RINC_SP.COMPANY := NCOMPANY;
    /*Регистрационный номер родителя*/
    RINC_SP.PRN := RINC.RN;
    /*Цикл по номенклатуре*/
    for MODIF_CURSOR in (select S.NOMMODIF as NMODIF,
                                S.PRICE as NPRICE,
                                S.PRICEMEAS as NPRICEMEAS,
                                sum(S.QUANT) as NQUANT_MAIN,
                                sum(S.QUANTALT) as NQUANT_ALT
                           from TRANSINVCUSTSPECS S
                          where S.PRN = NRN
                            and S.COMPANY = NCOMPANY
                          group by S.NOMMODIF, S.PRICE, S.PRICEMEAS) loop
      /*Модификация*/
      RINC_SP.NOMMODIF := MODIF_CURSOR.NMODIF;
      /*Количество по документу в ОЕИ*/
      RINC_SP.QUANT_PLAN := MODIF_CURSOR.NQUANT_MAIN;
      /*Количество фактически в ОЕИ*/
      RINC_SP.QUANT_FACT := MODIF_CURSOR.NQUANT_MAIN;
      /*Количество по документу в ДЕИ*/
      RINC_SP.QUANT_PLAN_ALT := MODIF_CURSOR.NQUANT_ALT;
      /*Количество фактически в ДЕИ*/
      RINC_SP.QUANT_FACT_ALT := MODIF_CURSOR.NQUANT_ALT;
      /*Цена*/
      RINC_SP.PRICE := MODIF_CURSOR.NPRICE;
      /*Еи Цены*/
      RINC_SP.PRICEMEAS := MODIF_CURSOR.NPRICEMEAS;
      /*Цена по документу*/
      RINC_SP.SUMM_PLAN := RINC_SP.PRICE * RINC_SP.QUANT_FACT;
      /*Цена фактически*/
      RINC_SP.SUMM_FACT := RINC_SP.PRICE * RINC_SP.QUANT_FACT;
      /*Выполняем базовое добавление строки документа*/
      UDO_PKG_STORE_OPER_ACC.P_INSERT_INCOMEFROMDEPSSPEC(RINCOMEFROMDEPSSPEC   => RINC_SP,
                                                         NRNINCOMEFROMDEPSSPEC => RINC_SP.RN);
    end loop;
    /*Создаем связь*/
    PKG_DOCLINKS.LINK(NFLAG_SMART   => 0,
                      NCOMPANY      => NCOMPANY,
                      SIN_UNITCODE  => 'IncomFromDeps',
                      NIN_DOCUMENT  => RINC.RN,
                      SOUT_UNITCODE => 'GoodsTransInvoicesToConsumers',
                      NOUT_DOCUMENT => NRN,
                      NBREAKUP_KIND => 0);
    /*Выполняем отработки прихода как факт*/
    nID := gen_ident;
    P_INCOMEFROMDEPS_SET_STATUS(NCOMPANY  => NCOMPANY,
                                nIDENT    => nID -- идентификатор процесса --обновление 03/2023
                               ,
                                NRN       => RINC.RN,
                                NSTATUS   => 2 /*Отработан как факт*/,
                                DWORKDATE => RINC.DOC_DATE,
                                NWARNING  => NWARNING,
                                SMSG      => SMESSAGE,
                                nSHOW_MSG => NMESSAGE); -- показывать журнал сообщений --обновление 03/2023
    /*Регистрационный номер прихода*/
    NRN_INC_SGP := RINC.RN;
  end P_TRANSINVCUST_CREATE_INDOC;

  /*Процедура выполняет расформирование приходного документа для указанной расходной накладной*/
  procedure P_TRANSINVCUST_REMOVE_INDOC(NCOMPANY in number /*Организация*/,
                                        NRN      in TRANSINVCUST.RN%type /*Регистрационный номер записи*/) is
    /*Регистрационный номер прихода*/
    NRN_INC_SGP INCOMEFROMDEPS.RN%type;
    /*Предупреждение*/
    NWARNING number;
    /*Сообщение об ошибке*/
    SMESSAGE PKG_STD.TSTRING;
    NMESSAGE PKG_STD.tNUMBER;
    /**/
    nID PKG_STD.tREF;
  begin
    /*Регистрационный номер прихода*/
    NRN_INC_SGP := F_DOCLINKS_LINK_IN_DOC(SOUT_UNITCODE => 'GoodsTransInvoicesToConsumers',
                                          NOUT_DOCUMENT => NRN,
                                          SIN_UNITCODE  => 'IncomFromDeps');
    /*Если не удалось определить приходный документ, то выдаем сообщение об ошибке*/
    if (NRN_INC_SGP is null) then
      P_EXCEPTION(0,
                  'Не удалось определить приходный документ');
    end if;
    /*Выполняем снятие отработки прихода как факт*/
    nID := gen_ident;
    P_INCOMEFROMDEPS_SET_STATUS(NCOMPANY  => NCOMPANY,
                                NRN       => NRN_INC_SGP,
                                nIDENT    => nID -- идентификатор процесса -- обновление 03/2023 ??
                               ,
                                NSTATUS   => 0,
                                DWORKDATE => TRUNC(sysdate),
                                NWARNING  => NWARNING,
                                SMSG      => SMESSAGE,
                                nSHOW_MSG => NMESSAGE); -- показывать журнал сообщений -- обновление 03/2023
    /*Выполняем разрыв связей*/
    PKG_DOCLINKS.REMOVE(SIN_UNITCODE  => 'IncomFromDeps',
                        NIN_DOCUMENT  => NRN_INC_SGP,
                        SOUT_UNITCODE => 'GoodsTransInvoicesToConsumers',
                        NOUT_DOCUMENT => NRN);
    /*Выполняем удаление документа*/
    P_INCOMEFROMDEPS_BASE_DELETE(NCOMPANY => NCOMPANY, NRN => NRN_INC_SGP);
  end P_TRANSINVCUST_REMOVE_INDOC;

  /*Функция возвращает признак давальческой схемы для указанной партии*/
  function f_goodsparties_calc_sign_proc(ncompany in number /*Организация*/,
                                         nrn      in number /*Регистрационный номер записи*/)
    return number is
    NPARTY_SRC pkg_std.tREF;
    NCOUNT_CLC number;
  begin
    if (nrn is null) then
      return(0);
    end if;
    /*Выполняем поиск партии поставщика*/
    /*UDO_PKG_GOODSPARTIES_EXT.P_GOODSPARTIES_CALC_SRC(nflag_smart => 1
    ,NCOMPANY    => NCOMPANY
    ,NRN         => nrn
    ,NSIGN_HIER  => 1
    ,NRN_SRC     => NPARTY_SRC);*/
    /*Количество записей в калькуляции партии*/
    select count(1)
      into NCOUNT_CLC
      from GOODSSUPPLY GS, INORDERSPECS S, INORDERSPECSCLC C
     where GS.PRN = NPARTY_SRC
       and S.GOODSSUPPLY = GS.RN
       and C.PRN = S.RN;
    /*Возвращаем результат*/
    if (NCOUNT_CLC = 0) then
      return(0);
    else
      return(1);
    end if;
  end f_goodsparties_calc_sign_proc;

  /*Функция возвращает МВЗ по давальческой схеме для указанной партии*/
  function f_goodsparties_calc_cpl_proc(ncompany in number /*Организация*/,
                                        nrn      in number /*Регистрационный номер записи*/)
    return number is
    NPARTY_SRC  pkg_std.tREF;
    ncost_place number;
  begin
    /*Выполняем поиск партии поставщика*/
    /*UDO_PKG_GOODSPARTIES_EXT.P_GOODSPARTIES_CALC_SRC(nflag_smart => 1
    ,NCOMPANY    => NCOMPANY
    ,NRN         => nrn
    ,NSIGN_HIER  => 1
    ,NRN_SRC     => NPARTY_SRC);*/
    /*МВЗ*/
    begin
      select distinct C.COST_PLACE
        into ncost_place
        from GOODSSUPPLY GS, INORDERSPECS S, INORDERSPECSCLC C
       where GS.PRN = NPARTY_SRC
         and S.GOODSSUPPLY = GS.RN
         and C.PRN = S.RN;
    exception
      when no_data_found then
        p_exception(0, 'Не удалось определить МВЗ');
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить МВЗ');
    end;
    /*Возвращаем результат*/
    return(ncost_place);
  end f_goodsparties_calc_cpl_proc;

  /*Функция возвращает цену по давальческой схеме для указанной партии*/
  function f_goodsparties_calc_price_proc(ncompany in number /*Организация*/,
                                          nrn      in number /*Регистрационный номер записи*/)
    return number is
    NPARTY_SRC pkg_std.tREF;
    nprice     number;
  begin
    /*Выполняем поиск партии поставщика*/
    /*UDO_PKG_GOODSPARTIES_EXT.P_GOODSPARTIES_CALC_SRC(nflag_smart => 1
    ,NCOMPANY    => NCOMPANY
    ,NRN         => nrn
    ,NSIGN_HIER  => 1
    ,NRN_SRC     => NPARTY_SRC);*/
    /*Цена*/
    select sum(C.COST_FACT)
      into nprice
      from GOODSSUPPLY GS, INORDERSPECS S, INORDERSPECSCLC C
     where GS.PRN = NPARTY_SRC
       and S.GOODSSUPPLY = GS.RN
       and C.PRN = S.RN;
    /*Возвращаем результат*/
    return(nvl(nprice, 0));
  end f_goodsparties_calc_price_proc;

  /*Функция возвращает цену по давальческой схеме для указанной партии*/
  function f_goodsparties_calc_price_pr_a(ncompany in number /*Организация*/,
                                          nrn      in number /*Регистрационный номер записи*/,
                                          nARTICLE in number /*Регистрационный номер записи статьи затрат*/)
    return number is
    NPARTY_SRC pkg_std.tREF;
    nprice     number;
  begin
    /*Выполняем поиск партии поставщика*/
    /*UDO_PKG_GOODSPARTIES_EXT.P_GOODSPARTIES_CALC_SRC(nflag_smart => 1
    ,NCOMPANY    => NCOMPANY
    ,NRN         => nrn
    ,NSIGN_HIER  => 1
    ,NRN_SRC     => NPARTY_SRC);*/
    /*Цена*/
    select sum(C.COST_FACT)
      into nprice
      from GOODSSUPPLY GS, INORDERSPECS S, INORDERSPECSCLC C
     where GS.PRN = NPARTY_SRC
       and S.GOODSSUPPLY = GS.RN
       and C.PRN = S.RN
       and c.COST_ARTICLE = nARTICLE;
    /*Возвращаем результат*/
    return(nvl(nprice, 0));
  end f_goodsparties_calc_price_pr_a;

  /*Функция определяет признак ГОЗ для указанной темы*/
  function f_theme_calc_sign_goz(nflag_smart in number /*Признак генерации исключения*/,
                                 NCOMPANY    in number /*Организация*/,
                                 NRN         in number /* RN ЛС проекта/договора */)
    return number is
    nigk pkg_std.tREF;
  begin
    begin
      select distinct t.govcntrid
        into nigk
        from (
              --
              /* От проекта */
              select p.govcntrid
                from project p
               where p.company = ncompany                
                 and p.rn = NRN 
              --
              union all
              --
              /* от договора */
              select c.govcntrid
                from contracts c 
               where c.company = ncompany               
                 and c.rn = NRN
              --
              ) t;
    exception
      when no_data_found then
        if (nflag_smart = 1) then
          return(to_number(null));
        end if;
      
        p_exception(nflag_smart,
                    'Не удалось определить проект/договор для темы ' ||
                    NRN);
      when too_many_rows then
        if (nflag_smart = 1) then
          return(to_number(null));
        end if;
      
        p_exception(nflag_smart,
                    'Не удалось однозначно определить проект/договор для темы ' ||
                    NRN);
    end;
  
    if (nigk is not null) then
      return(1);
    else
      return(0);
    end if;
  end f_theme_calc_sign_goz;
  
  /*Функция определяет признак ГОЗ для указанного лицевого счета*/
  function f_faceacc_calc_sign_goz(nflag_smart in number /*Признак генерации исключения*/,
                                   NCOMPANY    in number /*Организация*/,
                                   NRN         in number /*Регистрационный номер записи*/)
    return number is
  
    stheme pkg_std.tSTRING;
    nigk   pkg_std.tREF;
  begin
  
    begin
      select distinct t.govcntrid
        into nigk
        from (
              select p.govcntrid
                from project p, PROJECTSTAGE prs
               where p.company = ncompany                
                 and (prs.FACEACC = NRN or prs.faceacccust = NRN)
                 and p.rn = prs.prn
              ) t;
    exception
      when no_data_found then
        if (nflag_smart = 1) then
          return(to_number(null));
        end if;
    end;
    
    if (nigk is not null) then
      return(1);
    else
      return(0);
    end if;    
    
  end f_faceacc_calc_sign_goz;

  /*Процедура выполняет базовое формирование документа перевода в свободный остаток*/
  procedure P_TRANSINVDEPT_bCRT_free_rest(NCOMPANY  in number /*Организация*/,
                                          DDATE     in TRANSINVDEPT.DOCDATE%type /*Дата*/,
                                          nident    in number /*Идентификатор отмеченных записей*/,
                                          nrn       in number /*Регистрационный номер записи товарного запаса*/,
                                          NQUANT    in TRANSINVDEPTSPECS.QUANT%type /*Количество*/,
                                          NQUANTalt in TRANSINVDEPTSPECS.QUANTalt%type /*Количество ДЕИ*/,
                                          NRNINV    out TRANSINVDEPT.RN%type /*Регистрационный номер записи*/) is
    /*Каталог*/
    scatalog acatalog.name%type;
    /*Юридическое лицо*/
    sJUR_PERS jurpersons.code%type;
    /*Тип*/
    sDOCTYPE doctypes.doccode%type;
    /*Вид отгрузки*/
    SSHEEPVIEW DICSHPVW.CODE%type;
    /*Складская операция расхода*/
    SOPERout AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type;
    /*Складская операция прихода*/
    SOPERIN AZSGSMWAYSTYPES.GSMWAYS_MNEMO%type;
    /*Атрибуты требования*/
    RINV TRANSINVDEPT%rowtype;
    /*Атрибуты строки требования*/
    RSP TRANSINVDEPTSPECS%rowtype;
  
    /*Призак ГОЗ*/
    nsign_goz number;
  
    /*Лицевой счет*/
    sFACEACC faceacc.numb%type;
  
    /*Регистрационный номер записи калькуляции*/
    nrn_clc pkg_std.tREF;
  
  begin
    /*Устанавливаем атрибуты инициализации требования*/
    UDO_PKG_STORE_OPER_ACC.P_TRANSINVDEPT_INIT_PARAMS(RTRANSINVDEPTINIT => RINV);
    /*Организация*/
    RINV.COMPANY := NCOMPANY;
    /*Каталог*/
    p_get_string_constant(nCOMPANY => NCOMPANY,
                          sNAME    => 'ДокПерСвобОстКаталог',
                          dDATE    => TO_DATE(null),
                          sVALUE   => scatalog);
    FIND_ACATALOG_NAME(NFLAG_SMART => 1,
                       NCOMPANY    => NCOMPANY,
                       NVERSION    => TO_NUMBER(null),
                       SUNITCODE   => 'GoodsTransInvoicesToDepts',
                       SNAME       => scatalog,
                       NRN         => RINV.CRN);
    /*Юридическое лицо*/
    find_jurpersons_main(nFLAG_SMART => 0,
                         nCOMPANY    => NCOMPANY,
                         sJUR_PERS   => sJUR_PERS,
                         nJUR_PERS   => RINV.JUR_PERS);
    /*Тип*/
    p_get_string_constant(nCOMPANY => NCOMPANY,
                          sNAME    => 'ДокПерСвобОстТип',
                          dDATE    => TO_DATE(null),
                          sVALUE   => sDOCTYPE);
    FIND_DOCTYPES_CODE(NCOMPANY  => NCOMPANY,
                       SDOCCODE  => sDOCTYPE,
                       SUNITCODE => 'GoodsTransInvoicesToDepts',
                       NSTYPE    => 0,
                       NRN       => RINV.DOCTYPE);
    /*Префикс*/
    RINV.PREF := TO_CHAR(DDATE, 'yyyy');
    /*Номер*/
    p_transinvdept_getnextnumb(nCOMPANY  => NCOMPANY,
                               sJUR_PERS => get_jurpersons_code_id(nFLAG_SMART => 0,
                                                                   nJUR_PERS   => RINV.JUR_PERS),
                               dDOCDATE  => ddate,
                               sTYPE     => sDOCTYPE,
                               sPREF     => RINV.PREF,
                               sNUMB     => RINV.NUMB);
    /*Дата*/
    RINV.DOCDATE := DDATE;
    /*Складская операция расхода*/
    P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY,
                          SNAME    => 'ДокПерСвобОстСОРасх',
                          DDATE    => TO_DATE(null),
                          SVALUE   => SOPERout);
    FIND_DICSTOPR_CODE(NSMART_FLAG => 0,
                       NCOMPANY    => NCOMPANY,
                       SCODE       => SOPERout,
                       NRN         => RINV.STOPER);
    /*Призак ГОЗ*/
    begin
      select distinct t.nsign_goz
        into nsign_goz
        from (
              --
              select f_faceacc_calc_sign_goz(nflag_smart => 0,
                                              NCOMPANY    => NCOMPANY,
                                              nrn         => c.faceacc) as nsign_goz
                from goodssupply gs, goodssupplyclc c
               where gs.rn = nrn
                 and gs.company = ncompany
                 and c.prn = gs.rn
                 and c.quant_fact > 0
              --
              union all
              --
              select f_faceacc_calc_sign_goz(nflag_smart => 0,
                                              NCOMPANY    => NCOMPANY,
                                              nrn         => c.faceacc) as nsign_goz
                from selectlist sl, goodssupply gs, goodssupplyclc c
               where sl.ident = nident
                 and sl.company = ncompany
                 and gs.rn = sl.document
                 and c.prn = gs.rn
                 and c.quant_fact > 0
              --
              ) t;
    exception
      when no_data_found then
        p_exception(0,
                    'Не удалось определить признак ГОЗ');
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить признак ГОЗ');
    end;
    /*Лицевой счет*/
    if (nsign_goz = 0) then
      P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY,
                            SNAME    => 'ШифрСвобОст',
                            DDATE    => TO_DATE(null),
                            SVALUE   => sFACEACC);
    else
      P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY,
                            SNAME    => 'ШифрСвобОстГОЗ',
                            DDATE    => TO_DATE(null),
                            SVALUE   => sFACEACC);
    end if;
    find_faceacc_numb(nFLAG_SMART  => 0,
                      nFLAG_OPTION => 0,
                      nCOMPANY     => nCOMPANY,
                      sNUMB        => sFACEACC,
                      nRN          => RINV.FACEACC);
    /*Склад расхода*/
    begin
      select distinct t.store
        into RINV.STORE
        from (
              --
              select gs.store
                from goodssupply gs
               where gs.rn = nrn
                 and gs.company = ncompany
              --
              union all
              --
              select gs.store
                from selectlist sl, goodssupply gs
               where sl.ident = nident
                 and sl.company = ncompany
                 and gs.rn = sl.document
              --
              ) t;
    exception
      when no_data_found then
        p_exception(0,
                    'Не удалось определить склад расхода');
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить склад расхода');
    end;
    /*МОЛ склада расхода*/
    UDO_PKG_STORE_OPER_ACC.P_STORE_GET_AGENT(NRNSTORE => RINV.STORE,
                                             NRNAGENT => RINV.MOL);
    /*Вид отгрузки*/
    P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY,
                          SNAME    => 'ДокПерСвобОстВидОтгр',
                          DDATE    => TO_DATE(null),
                          SVALUE   => SSHEEPVIEW);
    FIND_DICSHPVW_CODE(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       SCODE       => SSHEEPVIEW,
                       NRN         => RINV.SHEEPVIEW);
    /*Валюта*/
    RINV.CURRENCY := F_CURBASE_GET_RN(NFLAG_SMART => 0,
                                      NCOMPANY    => NCOMPANY);
    /*Складская операция прихода*/
    P_GET_STRING_CONSTANT(NCOMPANY => NCOMPANY,
                          SNAME    => 'ДокПерСвобОстСОПрих',
                          DDATE    => TO_DATE(null),
                          SVALUE   => SOPERIN);
    FIND_DICSTOPR_CODE(NSMART_FLAG => 0,
                       NCOMPANY    => NCOMPANY,
                       SCODE       => SOPERIN,
                       NRN         => RINV.IN_STOPER);
    /*Склад прихода*/
    RINV.IN_STORE := RINV.Store;
    /*МОЛ склада прихода*/
    RINV.In_Mol := rinv.mol;
    /*Подразделение получатель*/
    RINV.SUBDIV := to_number(null);
    /*Документ-основание*/
    RINV.VALID_DOCTYPE := to_number(null);
    RINV.VALID_DOCNUMB := to_char(null);
    RINV.VALID_DOCDATE := to_date(null);
    /*Партия*/
    p_incomdoc_getnextnumb(nCOMPANY => nCOMPANY,
                           sNUMBER  => RINV.In_Party_Code);
    /*Выполняем добавление требования*/
    UDO_PKG_STORE_OPER_ACC.P_INSERT_TRANSINVDEPT(RTRANSINVDEPT   => RINV,
                                                 NRNTRANSINVDEPT => RINV.RN);
    /*Устанавливаем атрибуты инициализации строки требования*/
    UDO_PKG_STORE_OPER_ACC.P_TRANSINVDEPTSPECS_INIT_PARS(RTRANSINVDEPTSPECSINIT => RSP);
    /*Организация*/
    RSP.COMPANY := NCOMPANY;
    /*Регистрационный номер родителя*/
    RSP.PRN := RINV.RN;
    /*Цикл по партиям*/
    for PARTY_CURSOR in (
                         --
                         select gs.prn as nrn,
                                 gp.nommodif as nnommodif,
                                 nquant as nquant,
                                 NQUANTalt as NQUANTalt,
                                 gp.sernumb as ssernumb,
                                 gs.rn as nrn_gs,
                                 to_number(null) as nprod_order
                           from goodssupply gs, goodsparties gp
                          where gs.rn = nrn
                            and gs.company = ncompany
                            and gp.rn = gs.prn
                         --
                         union all
                         --
                         select gs.prn as nrn,
                                 gp.nommodif as nnommodif,
                                 F_GOODSSUPPLYHIST_CALC_ReST(NPRN      => gs.rn,
                                                             DDATE     => DDATE,
                                                             NMUNIT    => 0,
                                                             nsign_res => 1) as nquant,
                                 F_GOODSSUPPLYHIST_CALC_ReST(NPRN      => gs.rn,
                                                             DDATE     => DDATE,
                                                             NMUNIT    => 1,
                                                             nsign_res => 1) as NQUANTalt,
                                 gp.sernumb as ssernumb,
                                 gs.rn as nrn_gs,
                                 to_number(null) as nprod_order
                           from selectlist   sl,
                                 goodssupply  gs,
                                 goodsparties gp
                          where sl.ident = nident
                            and sl.company = ncompany
                            and gs.rn = sl.document
                            and gp.rn = gs.prn
                         --
                         ) loop
      if (PARTY_CURSOR.NQUANT > 0) then
        /*Партия*/
        RSP.GOODSPARTY := PARTY_CURSOR.NRN;
        /*Модификация*/
        RSP.NOMMODIF := PARTY_CURSOR.nnommodif;
        /*Количество*/
        RSP.QUANT    := PARTY_CURSOR.NQUANT;
        RSP.Quantalt := PARTY_CURSOR.nQuantalt;
        rsp.coeff    := PARTY_CURSOR.nQuantalt / PARTY_CURSOR.NQUANT;
        /*Выполняем добавление строки требования*/
        UDO_PKG_STORE_OPER_ACC.P_INSERT_TRANSINVDEPTSPECS(RTRANSINVDEPTSPECS   => RSP,
                                                          NRNTRANSINVDEPTSPECS => RSP.RN);
      
        /*Определяем заказ*/
        begin
          select c.faceacc
            into PARTY_CURSOR.nprod_order
            from goodssupplyclc c
           where c.prn = PARTY_CURSOR.nrn_gs
             and c.quant_fact > 0;
        exception
          when no_data_found then
            p_exception(0,
                        'Не удалось определить шифр партии с серийным номером ' ||
                        PARTY_CURSOR.ssernumb);
          when too_many_rows then
            p_exception(0,
                        'Не удалось определить шифр партии с серийным номером ' ||
                        PARTY_CURSOR.ssernumb);
        end;
        /*Выыполняем добавление калькуляции*/
        p_transinvdeptclc_base_insert(ncompany      => ncompany,
                                      nprn          => RSP.RN,
                                      snumb         => to_char(null),
                                      ncost_article => to_number(null),
                                      ncost_place   => to_number(null),
                                      ncost_plan    => to_number(null),
                                      ncost_fact    => to_number(null),
                                      npriority     => to_number(null),
                                      nfaceaccount  => PARTY_CURSOR.nprod_order,
                                      ngraphpoint   => to_number(null),
                                      nfinoper_type => to_number(null),
                                      nquant_plan   => to_number(null),
                                      nquant_fact   => to_number(null),
                                      nsubdiv       => to_number(null),
                                      nrn           => nrn_clc);
      end if;
    end loop;
    /*Регистрационный номер записи*/
    NRNINV := RINV.RN;
  end P_TRANSINVDEPT_bCRT_free_rest;

  /*Процедура выполняет базовое формирование документа перевода в свободный остаток*/
  procedure P_TRANSINVDEPT_CRT_free_rest(NCOMPANY in number /*Организация*/,
                                         ncrn     in number /*Каталог*/,
                                         DDATE    in TRANSINVDEPT.DOCDATE%type /*Дата*/,
                                         stheme   in varchar2 /*Тема*/,
                                         NRNINV   out TRANSINVDEPT.RN%type /*Регистрационный номер записи*/) is
  
    nident number;
  
  begin
    /*Выполняем заполнение таблицы остатков*/
    udo_pkg_monitor_rest.p_recreate(ncompany  => ncompany,
                                    ddate     => ddate,
                                    stheme    => stheme,
                                    nsign_azs => 1
                                    ,nsign_free => 0/*Анненко И.С. 06.07.2023 Признак включения свободного остатка*/
                                    ,nsign_wout => 0/*Анненко И.С. 06.07.2023 Признак включения без темы*/);
  
    /* проверка прав доступа */
    PKG_ENV.PROLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'GoodsTransInvoicesToDepts',
                     'GoodsTransInvoicesToDeptsCrtFreeRest',
                     'TRANSINVDEPT',
                     0);
    /*Цикл по складам*/
    for store_cursor in (select distinct gs.store as nstore,
                                         to_number(null) as nrn_inv
                           from udo_monitor_rest r, goodssupply gs
                          where gs.rn = r.rn) loop
    
      p_selectlist_genident(nIDENT => nident);
    
      /*Цикл по партиям*/
      for party_cursor in (select gs.rn as nrn, to_number(null) as nrn_sl
                             from udo_monitor_rest r, goodssupply gs
                            where gs.rn = r.rn
                              and gs.store = store_cursor.nstore) loop
        p_selectlist_insert(nIDENT    => nident,
                            nDOCUMENT => party_cursor.nrn,
                            sUNITCODE => 'GoodsSupply',
                            nRN       => party_cursor.nrn_sl);
      end loop;
    
      P_TRANSINVDEPT_bCRT_free_rest(NCOMPANY  => NCOMPANY,
                                    DDATE     => DDATE,
                                    nident    => nident,
                                    nrn       => to_number(null),
                                    NQUANT    => to_number(null),
                                    NQUANTalt => to_number(null),
                                    NRNINV    => store_cursor.NRN_INV);
    
      p_selectlist_clear(nIDENT => nident);
    
    end loop;
  
    /* фиксация окончания выполнение действия */
    PKG_ENV.EPILOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'GoodsTransInvoicesToDepts',
                     'GoodsTransInvoicesToDeptsCrtFreeRest',
                     'TRANSINVDEPT',
                     0);
  end P_TRANSINVDEPT_CRT_free_rest;

begin
  -- Initialization
  null;
end UDO_PKG_STORE_OPER_ACC;
/
