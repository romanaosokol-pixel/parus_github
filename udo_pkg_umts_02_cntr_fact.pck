create or replace package udo_pkg_umts_02_cntr_fact is

  --create public synonym udo_pkg_umts_02_cntr_fact for udo_pkg_umts_02_cntr_fact;

  --grant execute on udo_pkg_umts_02_cntr_fact to public;

  -- Author  : I.ANNENKO
  -- Created : 26.10.2022 7:38:48
  -- Purpose : УМТС. 2. Контрактация (по факту заключения сделки)

  -- Public type declarations
  --type <TypeName> is <Datatype>;

  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  /*Процедура выполняет установку атрибутов инициализации строки счета на оплату*/
  procedure P_PAYACCINSPEC_INIT_ATTRS(RSP out PAYACCINSPEC%rowtype /*Атрибуты записи строки счета на оплату*/);

  /*Процедура выполняет базовое добавление строки счета на оплату*/
  procedure P_PAYACCINSPEC_BASE_INSERT(RSP in PAYACCINSPEC%rowtype /*Атрибуты записи строки счета на оплату*/,
                                       NRN out number /*Регистрационный номер записи*/);

  /*Процедура выполняет формирование счета-договора*/
  procedure P_deliveryord_CRT_PAYACCIN(NCOMPANY      in number /*Регистрационный номер организации*/,
                                       nrn           in number /*Регистрационный номер записи*/,
                                       SCATALOG      in varchar2 /*Каталог*/,
                                       SDOC_TYPE     in varchar2 /*Тип*/,
                                       SEXT_NUMB     in varchar2 /*Номер*/,
                                       DDATE         in date /*Дата*/,
                                       SAGENT        in varchar2 /*Контрагент*/,
                                       SAGNACC       in varchar2 /*Реквизиты*/,
                                       sjur_acc      in varchar2 /*Реквизиты плательщика*/,
                                       SEXECUTIVE    in varchar2 /*Ответственный*/,
                                       SSUBDIVISION  in varchar2 /*Подразделение*/,
                                       STARIF        in varchar2 /*Тариф*/,
                                       NPRICEWITHTAX in number /*Цены включают налоги*/,
                                       SNOTE         in varchar2 /*Примечание*/,
                                       SIEELEMENT    in varchar2 /* Статья затрат */,
                                       nrn_acc       out number /*Регистрационный номер записи счета-договора*/);

  /*Процедура выполняет расформирование счета-договора*/
  procedure P_deliveryord_rmv_PAYACCIN(NCOMPANY in number /*Регистрационный номер организации*/,
                                       nrn      in number /*Регистрационный номер записи*/);

  /*Функция возвращает вид договора*/
  function f_contracts_calc_kind(NCOMPANY in number /*Регистрационный номер организации*/,
                                 nrn      in number /*Регистрационный номер записи*/)
    return varchar2;

  /*Процедура выполняет указание действующего рамочного договора*/
  procedure P_deliveryord_set_cntr(NCOMPANY       in number /*Регистрационный номер организации*/,
                                   nrn            in number /*Регистрационный номер записи*/,
                                   ncntr          in number /*Регистрационный номер записи договора*/,
                                   SAGENT         in varchar2 /*Контрагент*/,
                                   SAGNACC        in varchar2 /*Реквизиты*/,
                                   sjur_acc       in varchar2 /*Реквизиты плательщика*/,
                                   SEXECUTIVE     in varchar2 /*Ответственный*/,
                                   SSUBDIVISION   in varchar2 /*Подразделение*/,
                                   NPRICEWITHTAX  in number /*Цены включают налоги*/,
                                   STAX_GROUP     in varchar2 /*Налоговая группа*/,
                                   nSTAGE_SUM     in number /*Сумма без НДС*/,
                                   nSTAGE_SUMTAX  in number /*Сумма с НДС*/,
                                   nSTAGE_SUM_NDS in number /*Сумма НДС*/,
                                   SDESCRIPTION   in varchar2 /*Описание*/,
                                   SNOTE          in varchar2 /*Примечание*/);

  /*Процедура выполняет очистку действующего рамочного договора*/
  procedure P_deliveryord_clr_cntr(NCOMPANY in number /*Регистрационный номер организации*/,
                                   nrn      in number /*Регистрационный номер записи*/);

  /*Процедура выполняет формирование нового договора*/
  procedure P_deliveryord_crt_cntr(NCOMPANY       in number /*Регистрационный номер организации*/,
                                   nrn            in number /*Регистрационный номер записи*/,
                                   SCATALOG       in varchar2 /*Каталог*/,
                                   SDOC_TYPE      in varchar2 /*Тип*/,
                                   scntr_kind     in varchar2 /*Вид договора*/,
                                   sdoc_pref      in varchar2 /*Префикс договора*/,
                                   sdoc_numb      in varchar2 /*Номер договора по журналу бухгалтерии*/,
                                   SEXT_NUMB      in varchar2 /*Номер*/,
                                   DDATE          in date /*Дата*/,
                                   SAGENT         in varchar2 /*Контрагент*/,
                                   SAGNACC        in varchar2 /*Реквизиты*/,
                                   sjur_acc       in varchar2 /*Реквизиты плательщика*/,
                                   sigk           in varchar2 /*ИГК*/,
                                   SEXECUTIVE     in varchar2 /*Ответственный*/,
                                   SSUBDIVISION   in varchar2 /*Подразделение*/,
                                   DDATE_BEGIN    in date /*Дата начала периода*/,
                                   DDATE_END      in date /*Дата окончания периода*/,
                                   sSUBJECT       in varchar2 /*Предмет договора*/,
                                   NPRICEWITHTAX  in number /*Цены включают налоги*/,
                                   STAX_GROUP     in varchar2 /*Налоговая группа*/,
                                   nSTAGE_SUM     in number /*Сумма без НДС*/,
                                   nSTAGE_SUMTAX  in number /*Сумма с НДС*/,
                                   nSTAGE_SUM_NDS in number /*Сумма НДС*/,
                                   SDESCRIPTION   in varchar2 /*Описание*/,
                                   SNOTE          in varchar2 /*Примечание*/,
                                   ncntr          out number /*Регистрационный номер записи договора*/);

  /*Процедура выполняет расформирование нового договора*/
  procedure P_deliveryord_rmv_cntr(NCOMPANY in number /*Регистрационный номер организации*/,
                                   nrn      in number /*Регистрационный номер записи*/);

  /*Процедура выполняет исправление внутреннего номера договора*/
  procedure p_contracts_upd_pref_numb(NCOMPANY  in number /*Регистрационный номер организации*/,
                                      nrn       in number /*Регистрационный номер записи*/,
                                      sdoc_pref in varchar2 /*Префикс договора*/,
                                      sdoc_numb in varchar2 /*Номер договора*/);

end udo_pkg_umts_02_cntr_fact;
/
create or replace package body udo_pkg_umts_02_cntr_fact is

  /*
  23/11/2023 Степанов М. В параметрах формирования счёта-договора добавил статью затрат, которая переносится в ЛС
  13/09/2023 Степанов М. Добавил новый признак Рамочный договор; Добавил определение типа суммы для договора и этапа
  */
  -- Private type declarations
  --type <TypeName> is <Datatype>;

  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  /*Процедура выполняет установку атрибутов инициализации счета на оплату*/
  procedure P_PAYACCIN_INIT_ATTRS(RACC out PAYACCIN%rowtype /*Атрибуты записи счета на оплату*/) is
  begin
    RACC.DOC_STATE    := 0;
    RACC.STATE_DATE   := TRUNC(sysdate);
    RACC.CURCOURS     := 1;
    RACC.CURBASE      := 1;
    RACC.PRICEWITHTAX := 0;
    RACC.FA_BASECOURS := 1;
    RACC.FA_COURS     := 1;
    RACC.PLANPAYSUMM  := 0;
    RACC.FACTPAYSUMM  := 0;
    RACC.ININVSUMM    := 0;
    RACC.INORDSUMM    := 0;
    RACC.DISCOUNT     := 0;
  end P_PAYACCIN_INIT_ATTRS;

  /*Процедура выполняет базовое добавление заголовка счета на оплату*/
  procedure P_PAYACCIN_BASE_INSERT(RACC in PAYACCIN%rowtype /*Атрибуты записи счета на оплату*/,
                                   NRN  out number /*Регистрационный номер записи*/) is
  begin
    PARUS.P_PAYACCIN_BASE_INSERT(NCOMPANY       => RACC.COMPANY,
                                 NCRN           => RACC.CRN,
                                 NDOC_TYPE      => RACC.DOC_TYPE,
                                 SDOC_PREF      => RACC.DOC_PREF,
                                 SDOC_NUMB      => RACC.DOC_NUMB,
                                 SEXT_NUMB      => RACC.EXT_NUMB,
                                 DREG_DATE      => RACC.REG_DATE,
                                 DDOC_DATE      => RACC.DOC_DATE,
                                 NDOC_STATE     => RACC.DOC_STATE,
                                 DSTATE_DATE    => RACC.STATE_DATE,
                                 DPAY_DATE      => RACC.PAY_DATE,
                                 NPAYER         => RACC.JUR_PERS,
                                 NPAYERACC      => RACC.PAYERACC,
                                 NSUPPLIER      => RACC.SUPPLIER,
                                 NSUPPLACC      => RACC.SUPPLACC,
                                 NFACEACC       => RACC.FACEACC,
                                 NGRAPHPOINT    => RACC.GRAPHPOINT,
                                 NCURRENCY      => RACC.CURRENCY,
                                 NCURCOURS      => RACC.CURCOURS,
                                 NCURBASE       => RACC.CURBASE,
                                 NAGNFI         => RACC.AGNFI,
                                 NAGNFO         => RACC.AGNFO,
                                 NSTORE         => RACC.STORE,
                                 NVDOC_TYPE     => RACC.VDOC_TYPE,
                                 SVDOC_NUM      => RACC.VDOC_NUM,
                                 DVDOC_DATE     => RACC.VDOC_DATE,
                                 NPRICEWITHTAX  => RACC.PRICEWITHTAX,
                                 NFA_BASECOURSE => RACC.FA_BASECOURS,
                                 NFA_COURSE     => RACC.FA_COURS,
                                 NPLANPAYSUMM   => RACC.PLANPAYSUMM,
                                 NFACTPAYSUMM   => RACC.FACTPAYSUMM,
                                 NININVSUMM     => RACC.ININVSUMM,
                                 NINORDSUMM     => RACC.INORDSUMM,
                                 SCOMMENTS      => RACC.COMMENTS,
                                 NPAYTYPE       => RACC.PAYTYPE,
                                 NDISCOUNT      => RACC.DISCOUNT,
                                 NRN            => NRN);
  end P_PAYACCIN_BASE_INSERT;

  /*Процедура выполняет установку атрибутов инициализации строки счета на оплату*/
  procedure P_PAYACCINSPEC_INIT_ATTRS(RSP out PAYACCINSPEC%rowtype /*Атрибуты записи строки счета на оплату*/) is
  begin
    RSP.PRICE         := 0;
    RSP.PRICEMEAS     := 0;
    RSP.SUMMWITHNDS   := 0;
    RSP.SUMM          := 0;
    RSP.SUMM_NDS      := 0;
    RSP.AUTOCALC_SIGN := 1;
    RSP.PLANQUANT     := 0;
    RSP.FACTQUANT     := 0;
    RSP.PLANSUMM      := 0;
    RSP.FACTSUMM      := 0;
    RSP.DISCOUNT      := 0;
  end P_PAYACCINSPEC_INIT_ATTRS;

  /*Процедура выполняет базовое добавление строки счета на оплату*/
  procedure P_PAYACCINSPEC_BASE_INSERT(RSP in PAYACCINSPEC%rowtype /*Атрибуты записи строки счета на оплату*/,
                                       NRN out number /*Регистрационный номер записи*/) is
  begin
    PARUS.P_PAYACCINSPEC_BASE_INSERT(NPRN           => RSP.PRN,
                                     NCOMPANY       => RSP.COMPANY,
                                     NCRN           => RSP.CRN,
                                     NNOMEN         => RSP.NOMEN,
                                     NNOMMODIF      => RSP.NOMMODIF,
                                     NNOMPACK       => RSP.NOMPACK,
                                     NNOMMODIFPACK  => RSP.NOMMODIFPACK,
                                     SSERNUMB       => RSP.SERNUMB,
                                     NCOUNTRY       => RSP.COUNTRY,
                                     SGTD           => RSP.GTD,
                                     NTAXGR         => RSP.TAXGR,
                                     NQUANT         => RSP.QUANT,
                                     NQUANTALT      => RSP.QUANTALT,
                                     DBEGINDATE     => RSP.BEGINDATE,
                                     DENDDATE       => RSP.ENDDATE,
                                     NPRICE         => RSP.PRICE,
                                     NPRICEMEAS     => RSP.PRICEMEAS,
                                     NSUMMWITHNDS   => RSP.SUMMWITHNDS,
                                     NSUMM          => RSP.SUMM,
                                     NSUMM_NDS      => RSP.SUMM_NDS,
                                     NAUTOCALC_SIGN => RSP.AUTOCALC_SIGN,
                                     NPLANQUANT     => RSP.PLANQUANT,
                                     NFACTQUANT     => RSP.FACTQUANT,
                                     NPLANSUMM      => RSP.PLANSUMM,
                                     NFACTSUMM      => RSP.FACTSUMM,
                                     NSTORE         => RSP.STORE,
                                     SCOMMENTS      => RSP.COMMENTS,
                                     NDISCOUNT      => RSP.DISCOUNT,
                                     SORIGINAL_NAME => RSP.ORIGINAL_NAME,
                                     NMDMNOMEN      => RSP.MDMNOMEN,
                                     NRN            => NRN);
  end P_PAYACCINSPEC_BASE_INSERT;

  /*Процедура выполняет базовое исправление строки счета на оплату*/
  procedure P_PAYACCINSPEC_BASE_UPDATE(RSP in PAYACCINSPEC%rowtype /*Атрибуты записи строки счета на оплату*/) is
  begin
    PARUS.P_PAYACCINSPEC_BASE_UPDATE(NRN            => RSP.RN,
                                     NCOMPANY       => RSP.COMPANY,
                                     NNOMEN         => RSP.NOMEN,
                                     NNOMMODIF      => RSP.NOMMODIF,
                                     NNOMPACK       => RSP.NOMPACK,
                                     NNOMMODIFPACK  => RSP.NOMMODIFPACK,
                                     SSERNUMB       => RSP.SERNUMB,
                                     NCOUNTRY       => RSP.COUNTRY,
                                     SGTD           => RSP.GTD,
                                     NTAXGR         => RSP.TAXGR,
                                     NQUANT         => RSP.QUANT,
                                     NQUANTALT      => RSP.QUANTALT,
                                     DBEGINDATE     => RSP.BEGINDATE,
                                     DENDDATE       => RSP.ENDDATE,
                                     NPRICE         => RSP.PRICE,
                                     NPRICEMEAS     => RSP.PRICEMEAS,
                                     NSUMMWITHNDS   => RSP.SUMMWITHNDS,
                                     NSUMM          => RSP.SUMM,
                                     NSUMM_NDS      => RSP.SUMM_NDS,
                                     NAUTOCALC_SIGN => RSP.AUTOCALC_SIGN,
                                     NPLANQUANT     => RSP.PLANQUANT,
                                     NFACTQUANT     => RSP.FACTQUANT,
                                     NPLANSUMM      => RSP.PLANSUMM,
                                     NFACTSUMM      => RSP.FACTSUMM,
                                     NSTORE         => RSP.STORE,
                                     SCOMMENTS      => RSP.COMMENTS,
                                     NDISCOUNT      => RSP.DISCOUNT,
                                     SORIGINAL_NAME => RSP.ORIGINAL_NAME,
                                     NMDMNOMEN      => RSP.MDMNOMEN,
                                     NFLAG_DEL_CALC => 0);
  end P_PAYACCINSPEC_BASE_UPDATE;

  /*Процедура выполняет установку атрибутов инициализации договора*/
  procedure P_CONTRACTS_INIT_ATTRS(RCONTRACT out CONTRACTS%rowtype /*Атрибуты записи договора*/) is
  begin
    RCONTRACT.APPFLAG := 0;
    --RCONTRACT.INOUT_SIGN := 1;
    --RCONTRACT.FALSE_DOC      := 1;
    RCONTRACT.EXT_AGREEMENT  := 0;
    RCONTRACT.SUM_TYPE       := 1;
    RCONTRACT.DOC_SUM        := 0;
    RCONTRACT.DOC_SUMTAX     := 0;
    RCONTRACT.DOC_SUM_NDS    := 0;
    RCONTRACT.AUTOCALC_SIGN  := 1;
    RCONTRACT.CURCOURS       := 1;
    RCONTRACT.CURBASE        := 1;
    RCONTRACT.SECRET_SIGN    := 0;
    RCONTRACT.SOLUT_SIGN     := 0;
    RCONTRACT.STATUS_SIGN    := 0;
    RCONTRACT.GOVDEFORD_EXEC := 0;
  end P_CONTRACTS_INIT_ATTRS;

  /*Процедура выполняет базовое добавление договора*/
  procedure P_CONTRACTS_BASE_INSERT(RCONTRACT in CONTRACTS%rowtype /*Атрибуты записи договора*/,
                                    NRN       out number /*Регистрационный номер записи договора*/) is
  begin
    PARUS.P_CONTRACTS_BASE_INSERT(NCOMPANY        => RCONTRACT.COMPANY,
                                  NCRN            => RCONTRACT.CRN,
                                  NPRN            => RCONTRACT.PRN,
                                  NAPPFLAG        => RCONTRACT.APPFLAG,
                                  NJUR_PERS       => RCONTRACT.JUR_PERS,
                                  NJUR_ACC        => RCONTRACT.JUR_ACC,
                                  NDOC_TYPE       => RCONTRACT.DOC_TYPE,
                                  SDOC_PREF       => RCONTRACT.DOC_PREF,
                                  SDOC_NUMB       => RCONTRACT.DOC_NUMB,
                                  DDOC_DATE       => RCONTRACT.DOC_DATE,
                                  SEXT_NUMBER     => RCONTRACT.EXT_NUMBER,
                                  DREG_DATE       => RCONTRACT.REG_DATE,
                                  NINOUT_SIGN     => RCONTRACT.INOUT_SIGN,
                                  NFALSE_DOC      => RCONTRACT.FALSE_DOC,
                                  NEXT_AGREEMENT  => RCONTRACT.EXT_AGREEMENT,
                                  NAGENT          => RCONTRACT.AGENT,
                                  NAGNACC         => RCONTRACT.AGNACC,
                                  NEXECUTIVE      => RCONTRACT.EXECUTIVE,
                                  NSUBDIVISION    => RCONTRACT.SUBDIVISION,
                                  DBEGIN_DATE     => RCONTRACT.BEGIN_DATE,
                                  DEND_DATE       => RCONTRACT.END_DATE,
                                  NTAXGR          => RCONTRACT.TAXGR,
                                  NSUM_TYPE       => RCONTRACT.SUM_TYPE,
                                  NDOC_SUM        => RCONTRACT.DOC_SUM,
                                  NDOC_SUMTAX     => RCONTRACT.DOC_SUMTAX,
                                  NDOC_SUM_NDS    => RCONTRACT.DOC_SUM_NDS,
                                  NAUTOCALC_SIGN  => RCONTRACT.AUTOCALC_SIGN,
                                  NCURRENCY       => RCONTRACT.CURRENCY,
                                  NCURCOURS       => RCONTRACT.CURCOURS,
                                  NCURBASE        => RCONTRACT.CURBASE,
                                  NBUDGEXPEND_SP  => RCONTRACT.BUDGEXPEND_SP,
                                  SSUBJECT        => RCONTRACT.SUBJECT,
                                  SNOTE           => RCONTRACT.NOTE,
                                  SBARCODE        => RCONTRACT.BARCODE,
                                  SREG_NO         => RCONTRACT.REG_NO,
                                  DREG_DATE_R     => RCONTRACT.REG_DATE_R,
                                  NSECRET_SIGN    => RCONTRACT.SECRET_SIGN,
                                  NORDLOCMOD      => RCONTRACT.ORDLOCMOD,
                                  DAUCT_DATE      => RCONTRACT.AUCT_DATE,
                                  NVAL_DOCTYPE    => RCONTRACT.VAL_DOCTYPE,
                                  SVAL_NUMBER     => RCONTRACT.VAL_NUMBER,
                                  DVAL_DATE       => RCONTRACT.VAL_DATE,
                                  SLAW_SOLUT      => RCONTRACT.LAW_SOLUT,
                                  SDOC_ID         => RCONTRACT.DOC_ID,
                                  DPUB_DATE       => RCONTRACT.PUB_DATE,
                                  SPUB_INFO       => RCONTRACT.PUB_INFO,
                                  NSOLUT_SIGN     => RCONTRACT.SOLUT_SIGN,
                                  NLOT_NUMB       => RCONTRACT.LOT_NUMB,
                                  NEXCOREASONS    => RCONTRACT.EXCOREASONS,
                                  NCOPRCHJUSTIF   => RCONTRACT.COPRCHJUSTIF,
                                  NSTATUS_SIGN    => RCONTRACT.STATUS_SIGN,
                                  SPRINT_FORM     => RCONTRACT.PRINT_FORM,
                                  SDESCRIPTION    => RCONTRACT.DESCRIPTION,
                                  SVAL_REQ        => RCONTRACT.VAL_REQ,
                                  NGOVCNTRID      => RCONTRACT.GOVCNTRID,
                                  NGOVDEFORD_EXEC => RCONTRACT.GOVDEFORD_EXEC,
                                  nSIGN_FRAME     => RCONTRACT.SIGN_FRAME,    ---Обновление 2023/07
                                  NDUP_RN         => TO_NUMBER(null),
                                  NRN             => NRN);
  end P_CONTRACTS_BASE_INSERT;

  /*Процедура выполняет базовое добавление лицевого счета*/
  procedure P_FACEACC_BASE_INSERT(RFACEACC in FACEACC%rowtype /*Атрибуты записи лицевого счета*/,
                                  NRN      out number /*Регистрационный номер записи*/) is
  begin
    PARUS.P_FACEACC_BASE_INSERT(NCOMPANY         => RFACEACC.COMPANY,
                                NCRN             => RFACEACC.CRN,
                                NJUR_PERS        => RFACEACC.JUR_PERS,
                                NPRN             => RFACEACC.PRN,
                                NAGENT           => RFACEACC.AGENT,
                                NFINERULE        => RFACEACC.FINERULE,
                                SNUMBER          => RFACEACC.NUMB,
                                NACC_KIND        => RFACEACC.ACC_KIND,
                                NACC_CLASS       => RFACEACC.ACC_CLASS,
                                NOPER_FLAG       => RFACEACC.OPER_FLAG,
                                NSIGN_CONTRACT   => RFACEACC.SIGN_CONTRACT,
                                NSIGN_STAGE      => RFACEACC.SIGN_STAGE,
                                NORDER_SIGN      => RFACEACC.ORDER_SIGN,
                                NVALID_DOCTYPE   => RFACEACC.VALID_DOCTYPE,
                                SVALID_DOCNUMB   => RFACEACC.VALID_DOCNUMB,
                                DVALID_DOCDATE   => RFACEACC.VALID_DOCDATE,
                                DPLAN_OPEN_DATE  => RFACEACC.PLAN_OPEN_DATE,
                                DFACT_OPEN_DATE  => RFACEACC.FACT_OPEN_DATE,
                                DPLAN_CLOSE_DATE => RFACEACC.PLAN_CLOSE_DATE,
                                DFACT_CLOSE_DATE => RFACEACC.FACT_CLOSE_DATE,
                                NEXECUTIVE       => RFACEACC.EXECUTIVE,
                                NCURRENCY        => RFACEACC.CURRENCY,
                                NCREDIT_SUM      => RFACEACC.CREDIT_SUM,
                                NBEGIN_SUM       => RFACEACC.BEGIN_SUM,
                                NCURRENT_SUM     => RFACEACC.CURRENT_SUM,
                                NPLAN_SUM        => RFACEACC.PLAN_SUM,
                                NFCACGR          => RFACEACC.FCACGR,
                                NAGNACC          => RFACEACC.AGNACC,
                                NAGNFI           => RFACEACC.AGNFI,
                                NAGNFO           => RFACEACC.AGNFO,
                                NAGN_TRANS       => RFACEACC.AGN_TRANS,
                                NSUBDIV          => RFACEACC.SUBDIV,
                                NTARIF           => RFACEACC.TARIF,
                                NDISCOUNT        => RFACEACC.DISCOUNT,
                                NPAY_TYPE        => RFACEACC.PAY_TYPE,
                                NSHIP_TYPE       => RFACEACC.SHIP_TYPE,
                                NPRICE_TYPE      => RFACEACC.PRICE_TYPE,
                                DPRICE_DATE      => RFACEACC.PRICE_DATE,
                                NSIGNTAX         => RFACEACC.SIGNTAX,
                                NSAME_NOMN       => RFACEACC.SAME_NOMN,
                                NDOC_SERV        => RFACEACC.DOC_SERV,
                                NPLAN_SERV       => RFACEACC.PLAN_SERV,
                                NFACT_SERV       => RFACEACC.FACT_SERV,
                                NDOC_SHIP        => RFACEACC.DOC_SHIP,
                                NPLAN_SHIP       => RFACEACC.PLAN_SHIP,
                                NFACT_SHIP       => RFACEACC.FACT_SHIP,
                                NDOC_INCOME      => RFACEACC.DOC_INCOME,
                                NPLAN_INCOME     => RFACEACC.PLAN_INCOME,
                                NFACT_INCOME     => RFACEACC.FACT_INCOME,
                                NFACT_DEFICIT    => RFACEACC.FACT_DEFICIT,
                                NDOC_POSTED      => RFACEACC.DOC_POSTED,
                                NPLAN_POSTED     => RFACEACC.PLAN_POSTED,
                                NFACT_POSTED     => RFACEACC.FACT_POSTED,
                                NDOC_PAYED       => RFACEACC.DOC_PAYED,
                                NPLAN_PAYED      => RFACEACC.PLAN_PAYED,
                                NFACT_PAYED      => RFACEACC.FACT_PAYED,
                                NFINACCNT        => RFACEACC.FINACCNT,
                                NRESPMANAGER     => RFACEACC.RESPMANAGER,
                                NIEELEMENT       => RFACEACC.IEELEMENT,
                                NFINSOURCE       => RFACEACC.FINSOURCE,
                                NPAYTOOL         => RFACEACC.PAYTOOL,
                                NPAYPRIOR        => RFACEACC.PAYPRIOR,
                                NPAYRULE         => RFACEACC.PAYRULE,
                                NCHECK_BAL_SIGN  => RFACEACC.CHECK_BAL_SIGN,
                                NSPEC_MARK       => RFACEACC.SPEC_MARK,
                                NBUDGEXPEND_SP   => RFACEACC.BUDGEXPEND_SP,
                                NSERV_SUM        => RFACEACC.SERV_SUM,
                                NSERV_PERCENT    => RFACEACC.SERV_PERCENT,
                                NFINPLANREST     => RFACEACC.FINPLANREST,
                                SNOTE            => RFACEACC.NOTE,
                                NEXPSTRUCT       => RFACEACC.EXPSTRUCT,
                                NINCOMECLASS     => RFACEACC.INCOMECLASS,
                                NECONCLASS       => RFACEACC.ECONCLASS,
                                NDICBUNTS        => RFACEACC.DICBUNTS,
                                NACCFNDSRC       => RFACEACC.ACCFNDSRC,
                                NGOVCNTRID       => RFACEACC.GOVCNTRID,
                                NADDR_AGENT      => RFACEACC.ADDR_AGENT,
                                NADDR_AGNACC     => RFACEACC.ADDR_AGNACC,
                                NRN              => NRN);
  end P_FACEACC_BASE_INSERT;

  /*Процедура выполняет установку атрибутов инициализации этапа договора*/
  procedure P_STAGES_INIT_ATTRS(RSTG out STAGES%rowtype /*Атрибуты записи этапа договора*/) is
  begin
    RSTG.SIGN_SUM      := 1;
    RSTG.STAGE_SUM     := 0;
    RSTG.STAGE_SUMTAX  := 0;
    RSTG.STAGE_SUM_NDS := 0;
    RSTG.AUTOCALC_SIGN := 1;
  end P_STAGES_INIT_ATTRS;

  /*Процедура выполняет базовое добавление этапа договора*/
  procedure P_STAGES_BASE_INSERT(RSTG in STAGES%rowtype /*Атрибуты записи этапа договора*/,
                                 NRN  out number /*Регистрационный номер записи*/) is
    /*Атрибуты записи лицевого счета*/
    RFACEACC FACEACC%rowtype;
  begin
    /*Атрибуты записи лицевого счета*/
    begin
      select FA.*
        into RFACEACC
        from FACEACC FA
       where FA.RN = RSTG.FACEACC
         and FA.COMPANY = RSTG.COMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RSTG.FACEACC,
                                 SUNIT_TABLE => 'FaceAccounts');
    end;
    PARUS.P_STAGES_BASE_INSERT(NCOMPANY       => RSTG.COMPANY,
                               NPRN           => RSTG.PRN,
                               SNUMB          => RSTG.NUMB,
                               NEXT_AGREEMENT => RSTG.EXT_AGREEMENT,
                               NSIGN_SUM      => RSTG.SIGN_SUM,
                               DBEGIN_DATE    => RSTG.BEGIN_DATE,
                               DEND_DATE      => RSTG.END_DATE,
                               NDIRECTOR      => RSTG.DIRECTOR,
                               NJUR_ACC       => RSTG.JUR_ACC,
                               NTAXGR         => RSTG.TAXGR,
                               NSUM_TYPE      => RSTG.SUM_TYPE,
                               NSTAGE_SUM     => RSTG.STAGE_SUM,
                               NSTAGE_SUMTAX  => RSTG.STAGE_SUMTAX,
                               NSTAGE_SUM_NDS => RSTG.STAGE_SUM_NDS,
                               NAUTOCALC_SIGN => RSTG.AUTOCALC_SIGN,
                               SDESCRIPTION   => RSTG.DESCRIPTION,
                               SCOMMENTS      => RSTG.COMMENTS,
                               NEXPSTRUCT     => RSTG.EXPSTRUCT,
                               NINCOMECLASS   => RSTG.INCOMECLASS,
                               NECONCLASS     => RSTG.ECONCLASS,
                               NDICBUNTS      => RSTG.DICBUNTS,
                               NACCFNDSRC     => RSTG.ACCFNDSRC,
                               NBFPURPCODES   => RSTG.BFPURPCODES,
                               NFA_EDIT_SIGN  => 0,
                               NFACEACC       => RSTG.FACEACC,
                               NFACEACC_CRN   => RFACEACC.CRN,
                               NAGENT         => RFACEACC.AGENT,
                               NFINERULE      => RFACEACC.FINERULE,
                               SFACEACC       => RFACEACC.NUMB,
                               NACC_KIND      => RFACEACC.ACC_KIND,
                               NEXECUTIVE     => RFACEACC.EXECUTIVE,
                               NCURRENCY      => RFACEACC.CURRENCY,
                               NCREDIT_SUM    => RFACEACC.CREDIT_SUM,
                               NFCACGR        => RFACEACC.FCACGR,
                               NAGNACC        => RFACEACC.AGNACC,
                               NAGNFI         => RFACEACC.AGNFI,
                               NAGNFO         => RFACEACC.AGNFO,
                               NAGN_TRANS     => RFACEACC.AGN_TRANS,
                               NSUBDIV        => RFACEACC.SUBDIV,
                               NTARIF         => RFACEACC.TARIF,
                               NDISCOUNT      => RFACEACC.DISCOUNT,
                               NPAY_TYPE      => RFACEACC.PAY_TYPE,
                               NSHIP_TYPE     => RFACEACC.SHIP_TYPE,
                               NPRICE_TYPE    => RFACEACC.PRICE_TYPE,
                               DPRICE_DATE    => RFACEACC.PRICE_DATE,
                               NSIGNTAX       => RFACEACC.SIGNTAX,
                               NSAME_NOMN     => RFACEACC.SAME_NOMN,
                               NFINACCNT      => RFACEACC.FINACCNT,
                               NRESPMANAGER   => RFACEACC.RESPMANAGER,
                               NIEELEMENT     => RFACEACC.IEELEMENT,
                               NFINSOURCE     => RFACEACC.FINSOURCE,
                               NPAYTOOL       => RFACEACC.PAYTOOL,
                               NPAYPRIOR      => RFACEACC.PAYPRIOR,
                               NPAYRULE       => RFACEACC.PAYRULE,
                               NSPEC_MARK     => RFACEACC.SPEC_MARK,
                               NBUDGEXPEND_SP => RFACEACC.BUDGEXPEND_SP,
                               NADDR_AGENT    => RFACEACC.ADDR_AGENT,
                               NADDR_AGNACC   => RFACEACC.ADDR_AGNACC,
                               NDUP_RN        => TO_NUMBER(null),
                               NRN            => NRN,
                               NSIGN_DIR      => 0);
  end P_STAGES_BASE_INSERT;

  /*Процедура выполняет установку атрибутов инициализации строки графика поступления*/
  procedure P_FCACOPERPLANS_INIT_ATTRS(RGR out FCACOPERPLANS%rowtype /*Атрибуты записи строки графика поступления*/) is
  begin
    RGR.INEXP_SIGN    := 0;
    RGR.PRICE         := 0;
    RGR.PRICEMEAS     := 0;
    RGR.DISCOUNT      := 0;
    RGR.SUMM          := 0;
    RGR.SUMMWITHNDS   := 0;
    RGR.SUMM_NDS      := 0;
    RGR.AUTOCALC_SIGN := 1;
    RGR.QUANT         := 0;
    RGR.QUANT_MEAS    := 0;
  end P_FCACOPERPLANS_INIT_ATTRS;

  /*Процедура выполняет базовое добавление строки графика поступления*/
  procedure P_FCACOPERPLANS_BASE_INSERT(RGR in FCACOPERPLANS%rowtype /*Атрибуты записи строки графика поступления*/,
                                        NRN out number /*Регистрационный номер записи*/) is
  begin
    PARUS.P_FCACOPERPLANS_BASE_INSERT(NCOMPANY       => RGR.COMPANY,
                                      NPRN           => RGR.PRN,
                                      NGRAPHPOINT    => RGR.GRAPHPOINT,
                                      NINEXP_SIGN    => RGR.INEXP_SIGN,
                                      NNOMEN         => RGR.NOMEN,
                                      NNOMMODIF      => RGR.NOMMODIF,
                                      NNOMENPACK     => RGR.NOMENPACK,
                                      NNOMMODIFPACK  => RGR.NOMMODIFPACK,
                                      NARTICLE       => RGR.ARTICLE,
                                      NTAXGR         => RGR.TAXGR,
                                      DBEGIN_DATE    => RGR.BEGIN_DATE,
                                      DEND_DATE      => RGR.END_DATE,
                                      NPRICE         => RGR.PRICE,
                                      NPRICEMEAS     => RGR.PRICEMEAS,
                                      NDISCOUNT      => RGR.DISCOUNT,
                                      NQUANT         => RGR.QUANT,
                                      NQUANT_MEAS    => RGR.QUANT_MEAS,
                                      NSUMM          => RGR.SUMM,
                                      NSUMMWITHNDS   => RGR.SUMMWITHNDS,
                                      NSUMM_NDS      => RGR.SUMM_NDS,
                                      NAUTOCALC_SIGN => RGR.AUTOCALC_SIGN,
                                      NQUANT_MAIN    => RGR.QUANT_MAIN,
                                      NQUANT_ALT     => RGR.QUANT_ALT,
                                      SSERNUMB       => RGR.SERNUMB,
                                      NCOUNTRY       => RGR.COUNTRY,
                                      SGTD           => RGR.GTD,
                                      SORIGINAL_NAME => RGR.ORIGINAL_NAME,
                                      SNUMB          => RGR.NUMB,
                                      nNOMPRICE      => RGR.NOMPRICE, -- Учетная цена  -- Обновление 2024/08/30
                                      NRN            => NRN,
                                      NSIGN_DIR      => 0);
  end P_FCACOPERPLANS_BASE_INSERT;

  /*Процедура выполняет базовое исправление строки графика поступления*/
  procedure P_FCACOPERPLANS_BASE_UPDATE(RGR in FCACOPERPLANS%rowtype /*Атрибуты записи строки графика поступления*/) is
  begin
    PARUS.P_FCACOPERPLANS_BASE_UPDATE(NCOMPANY       => RGR.COMPANY,
                                      NRN            => RGR.RN,
                                      NPRN           => RGR.PRN,
                                      NGRAPHPOINT    => RGR.GRAPHPOINT,
                                      NINEXP_SIGN    => RGR.INEXP_SIGN,
                                      NNOMEN         => RGR.NOMEN,
                                      NNOMMODIF      => RGR.NOMMODIF,
                                      NNOMENPACK     => RGR.NOMENPACK,
                                      NNOMMODIFPACK  => RGR.NOMMODIFPACK,
                                      NARTICLE       => RGR.ARTICLE,
                                      NTAXGR         => RGR.TAXGR,
                                      DBEGIN_DATE    => RGR.BEGIN_DATE,
                                      DEND_DATE      => RGR.END_DATE,
                                      NPRICE         => RGR.PRICE,
                                      NPRICEMEAS     => RGR.PRICEMEAS,
                                      NDISCOUNT      => RGR.DISCOUNT,
                                      NQUANT         => RGR.QUANT,
                                      NQUANT_MEAS    => RGR.QUANT_MEAS,
                                      NSUMM          => RGR.SUMM,
                                      NSUMMWITHNDS   => RGR.SUMMWITHNDS,
                                      NSUMM_NDS      => RGR.SUMM_NDS,
                                      NAUTOCALC_SIGN => RGR.AUTOCALC_SIGN,
                                      NQUANT_MAIN    => RGR.QUANT_MAIN,     -- Количество в ОЕИ
                                      NQUANT_ALT     => RGR.QUANT_ALT,      -- Количество в ДЕИ
                                      SSERNUMB       => RGR.SERNUMB,        -- Серия
                                      NCOUNTRY       => RGR.COUNTRY,        -- Страна производителя
                                      SGTD           => RGR.GTD,            -- Реквизиты ГТД
                                      SORIGINAL_NAME => RGR.ORIGINAL_NAME,  -- Оригинальное наименование
                                      SNUMB          => RGR.NUMB,           -- Номер
                                      nNOMPRICE      => RGR.NOMPRICE,       -- Учетная цена  ---обновление 2024/08/30
                                      NSIGN_DIR      => 0);
  end P_FCACOPERPLANS_BASE_UPDATE;

  /*Процедура выполняет базовое формирование счета-договора*/
  procedure P_deliveryord_bCRT_PAYACCIN(NCOMPANY      in number /*Регистрационный номер организации*/,
                                        nrn           in number /*Регистрационный номер записи*/,
                                        ncrn          in number /*Каталог*/,
                                        NDOC_TYPE     in number /*Тип*/,
                                        SEXT_NUMB     in varchar2 /*Номер*/,
                                        DDATE         in date /*Дата*/,
                                        NAGENT        in number /*Контрагент*/,
                                        NAGNACC       in number /*Реквизиты*/,
                                        njur_acc      in number /*Реквизиты плательщика*/,
                                        NEXECUTIVE    in number /*Ответственный*/,
                                        NSUBDIVISION  in number /*Подразделение*/,
                                        NTARIF        in number /*Тариф*/,
                                        NPRICEWITHTAX in number /*Цены включают налоги*/,
                                        SNOTE         in varchar2 /*Примечание*/,
                                        NIEELEMENT    in number   /* Статья затрат 23/11/2023 Степанов М. */,
                                        nrn_acc       out number  /*Регистрационный номер записи счета-договора*/) is
    /*Атрибуты записи заказа поставщику*/
    rord deliveryord%rowtype;
    /*Регистрационный номер записи исполнения*/
    nrn_perf pkg_std.tREF;
    /*Результат установки состояния*/
    nresult number;
    /*Атрибуты записи лицевого счета*/
    RFACEACC FACEACC%rowtype;
    /*Атрибуты записи счета на оплату*/
    RACC PAYACCIN%rowtype;
    /*Атрибуты записи строки счета на оплату*/
    RACC_SP Payaccinspec%rowtype;
    /* Рег номер строки калькуляции - добавил селиванов 14022023 */
    CLC_RN PKG_STD.tREF;
  begin
    /*Атрибуты записи заказа поставщику*/
    begin
      select o.*
        into rord
        from deliveryord o
       where o.rn = nrn
         and o.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DeliveryOrders');
    end;

    /*Выполняем проверку состояния*/
    if not (rord.ord_state in (0, 2)) then
      P_EXCEPTION(0,
                  'Формирование счета-договора для заказа поставщику в состоянии отличном от "Не подтвержден" или "Согласование" недопустимо.');
    end if;
    /*Выполняем проверку указания лицевого счета*/
    if (rord.faceacc is not null) then
      p_exception(0, 'Лицевой счет уже указан');
    end if;

    /*Выполняем проверку наличия счета*/
    if (f_doclinks_link_out_doc(sIN_UNITCODE  => 'DeliveryOrders',
                                nIN_DOCUMENT  => nrn,
                                sOUT_UNITCODE => 'PaymentAccountsIn') is not null) then
      p_exception(0,
                  'Счет-договор уже сформирован');
    end if;
    /*Регистрационный номер записи исполнения*/
    begin
      select p.RN
        into nrn_perf
        from DELIVERYORDP p
       where p.PRN = nrn
         and p.company = ncompany;
    exception
      when no_data_found then
        p_exception(0,
                    'Не удалось определить исполнение');
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить исполнение');
    end;
    /*Выполняем проверку корректности указания контрагента*/
    if (get_agnlist_agnabbr_id(nFLAG_SMART => 0, nRN => nagent) = 'Выбор') then
      p_exception(0,
                  'Необходимо указать поставщика');
    end if;
    /*Выполняем установку атрибутов инициализации лицевого счета*/
    P_FACEACC_BASE_DEFVALUES(RREC => RFACEACC);
    /*Организация*/
    RFACEACC.COMPANY := NCOMPANY;
    /*Каталог*/
    FIND_ACATALOG_NAME_EX(NFLAG_SMART  => 0,
                          NFLAG_OPTION => 0,
                          NCOMPANY     => NCOMPANY,
                          NVERSION     => null,
                          SUNITCODE    => 'FaceAccounts',
                          SNAME        => 'Фиктивные',
                          NRN          => RFACEACC.CRN);
    /*Юрилическое лицо*/
    RFACEACC.JUR_PERS := rord.jur_pers;
    /*Контрагент*/
    RFACEACC.AGENT := NAGENT;
    /*Номер*/
    p_faceacc_make_new(ncompany   => ncompany,
                       smnemo     => get_agnlist_agnabbr_id(nFLAG_SMART => 0,
                                                            nRN         => nagent),
                       sdelimiter => '\',
                       snumb      => RFACEACC.NUMB);
    /*Документ-основание*/
    RFACEACC.VALID_DOCTYPE := nDOC_TYPE;
    RFACEACC.VALID_DOCNUMB := sext_numb;
    RFACEACC.VALID_DOCDATE := dDATE;
    /*Ответственный*/
    RFACEACC.EXECUTIVE := NEXECUTIVE;
    /*Валюта*/
    RFACEACC.CURRENCY := F_CURBASE_GET_RN(NFLAG_SMART => 0,
                                          NCOMPANY    => NCOMPANY);
    /*Реквизиты*/
    RFACEACC.AGNACC := NAGNACC;
    /*Подразделение*/
    RFACEACC.SUBDIV := NSUBDIVISION;
    /*Тариф*/
    RFACEACC.TARIF := NTARIF;
    /*Вид оплаты*/
    RFACEACC.PAYRULE := to_number(null);
    /*Цены включают налоги*/
    RFACEACC.SIGNTAX := NPRICEWITHTAX;
    /*Статья*/
    /* 23/11/2023 Степанов М. */
    RFACEACC.IEELEMENT := NIEELEMENT;
    /*find_fpdartcl_code(nFLAG_SMART => 0,
                       nCOMPANY    => nCOMPANY,
                       sCODE       => 'Расходы на ПКИ_Б',
                       nRN         => RFACEACC.IEELEMENT);*/
    /*Выполняем базовое добавление лицевого счета*/
    P_FACEACC_BASE_INSERT(RFACEACC => RFACEACC, NRN => RFACEACC.RN);

    /* Проверка после добавления лицевого счёта */
    usr_pkg_faceacc.faceacc_ainsert(nrn => RFACEACC.RN, ncompany => RFACEACC.COMPANY);

    /*Выполняем открытие лицевого счета*/
    p_faceacc_open(nCOMPANY   => ncompany,
                   sNUMBER    => rfaceacc.numb,
                   dOPEN_DATE => trunc(sysdate));
    /*Выполняем установку лицевого счета*/
    update deliveryord o
       set o.agent = nagent, o.faceacc = RFACEACC.Rn
     where o.rn = nrn
       and o.company = ncompany;
    /*Выполняем проверку установки лицевого счета*/
    if (sql%notfound) then
      pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                               sUNIT_TABLE => 'DeliveryOrders');
    end if;
    /*Выполняем утверждение заказа поставщику*/
    p_deliveryord_set_state(nflag_smart => 0,
                            ncompany    => ncompany,
                            nrn         => nrn,
                            nflag_mode  => 0,
                            nnew_state  => 1,
                            dstate_date => trunc(sysdate),
                            nresult     => nresult);
    /*Выполняем проверку утверждения заказа поставщику*/
    if (nresult <> 0) then
      p_exception(0,
                  'При утверждении заказа поставщику возникла ошибка. Обратитесь к администратору');
    end if;
    /*Выполняем установку атрибутов инициализации счета на оплату*/
    P_PAYACCIN_INIT_ATTRS(RACC => RACC);
    /*Организация*/
    RACC.COMPANY := NCOMPANY;
    /*Юридическое лицо*/
    RACC.JUR_PERS := rord.jur_pers;
    /*Каталог*/
    RACC.CRN := NCRN;
    /*Тип*/
    RACC.DOC_TYPE := NDOC_TYPE;
    /*Префикс*/
    RACC.DOC_PREF := TO_CHAR(sysdate, 'yyyy');
    /*Номер*/

    P_PAYACCIN_GETNEXTNUMB(NCOMPANY  => NCOMPANY,
                           SJUR_PERS => get_jurpersons_code_id(nFLAG_SMART => 0,
                                                               nJUR_PERS   => rord.jur_pers),
                           DDOC_DATE => sysdate,
                           SDOC_TYPE => GET_DOCTYPES_CODE_ID(NFLAG_SMART => 0,
                                                             NRN         => NDOC_TYPE),
                           SDOC_PREF => RACC.DOC_PREF,
                           SDOC_NUMB => RACC.DOC_NUMB);
    /*Внешний номер*/
    RACC.EXT_NUMB := SEXT_NUMB;
    /*Дата*/
    RACC.REG_DATE := DDATE;
    RACC.DOC_DATE := sysdate;
    /*Валюта*/
    RACC.CURRENCY := F_CURBASE_GET_RN(NFLAG_SMART => 0,
                                      NCOMPANY    => NCOMPANY);
    /*Реквизиты организации*/
    RACC.PAYERACC := nJUR_ACC;
    /*Поставщик*/
    RACC.SUPPLIER := NAGENT;
    /*Реквизиты поставщика*/
    RACC.SUPPLACC := NAGNACC;
    /*Лицевой счет*/
    RACC.FACEACC := RFACEACC.RN;
    /*Примечание*/
    RACC.COMMENTS := SNOTE;
    /*Документ-основание*/
    RACC.VDOC_TYPE := RFACEACC.VALID_DOCTYPE;
    RACC.VDOC_NUM  := RFACEACC.VALID_DOCNUMB;
    RACC.VDOC_DATE := RFACEACC.VALID_DOCDATE;
    /*Цены включают налоги*/
    RACC.PRICEWITHTAX := NPRICEWITHTAX;
    /*Выполняем базовое добавление заголовка счета на оплату*/
    P_PAYACCIN_BASE_INSERT(RACC => RACC, NRN => RACC.RN);
  
    /*Выполняем установку атрибутов инициализации строки счета на оплату*/
    P_PAYACCINSPEC_INIT_ATTRS(RSP => RACC_SP);
    /*Регистрационный номер родителя*/
    RACC_SP.PRN := racc.rn;
    /*Регистрационный номер организации*/
    RACC_SP.COMPANY := NCOMPANY;
    /*Каталог*/
    RACC_SP.CRN := racc.crn;
    /*Цикл по строкам заказа поставщику*/
    for sp_cursor in (select *
                        from deliveryords s
                       where s.prn = nrn
                         and s.company = ncompany) loop
      /*Номенклатура*/
      RACC_SP.NOMEN := sp_cursor.NOMEN;
      /*Модификация*/
      RACC_SP.NOMMODIF := sp_cursor.nom_modif;
      /*Налоговая группа*/
      RACC_SP.TAXGR := sp_cursor.tax_group;
      /*Количество в ОЕИ*/
      RACC_SP.QUANT := sp_cursor.main_quant;
      /*Количество в ДЕИ*/
      RACC_SP.QUANTALT := sp_cursor.alt_quant;
      /*Цена*/
      RACC_SP.Price := sp_cursor.exp_price;
      /*Сумма*/
      RACC_SP.SUMMWITHNDS := sp_cursor.sumwtax;
      RACC_SP.SUMM        := sp_cursor.sumwotax;
      RACC_SP.SUMM_NDS    := sp_cursor.sumwtax - sp_cursor.sumwotax;
      /*Выполняем базовое добавление строки счета на оплату*/
      P_PAYACCINSPEC_BASE_INSERT(RSP => RACC_SP, NRN => RACC_SP.RN);
      /* формирование калькуляции строки входящего счета на оплату  - Добавил Селиванов 14022023*/
      if (PROCEDURE_EXISTS('P_PAYACCINSPCLC_BASE_INSERT') <> 0) then
        for rCLC in (select COST_ARTICLE,
                            COST_PLACE,
                            FACEACCOUNT,
                            GRAPHPOINT,
                            FINOPER_TYPE,
                            SUBDIV,
                            sum(QUANT_PLAN) as QUANT_PLAN,
                            sum(QUANT_FACT) as QUANT_FACT,
                            max(COST_PLAN) as COST_PLAN,
                            max(COST_FACT) as COST_FACT,
                            min(RN) as RN
                       from DELIVERYORDCS
                      where PRN = sp_cursor.RN
                      group by COST_ARTICLE,
                               COST_PLACE,
                               FACEACCOUNT,
                               GRAPHPOINT,
                               FINOPER_TYPE,
                               SUBDIV) loop
          P_PAYACCINSPCLC_BASE_INSERT(nCOMPANY,
                                      RACC_SP.RN,
                                      null,
                                      rCLC.COST_ARTICLE,
                                      rCLC.COST_PLACE,
                                      rCLC.COST_PLAN,
                                      rCLC.COST_FACT,
                                      null,
                                      rCLC.FACEACCOUNT,
                                      rCLC.GRAPHPOINT,
                                      rCLC.FINOPER_TYPE,
                                      rCLC.QUANT_PLAN,
                                      rCLC.QUANT_FACT,
                                      rCLC.SUBDIV,
                                      CLC_RN);
        end loop;
      end if;
    end loop;
    /*Пересчитывем калькуляцию, для привязки ее к Бюджетам 
    Городецкий 29-01-2026 
    */
    usr_p_payaccinspclc_cre( RACC.RN);
    
    /*Выполняем установку связи*/
    pkg_doclinks.LINK(nFLAG_SMART   => 0,
                      nCOMPANY      => ncompany,
                      sIN_UNITCODE  => 'DeliveryOrders',
                      nIN_DOCUMENT  => nrn,
                      sOUT_UNITCODE => 'PaymentAccountsIn',
                      nOUT_DOCUMENT => RACC.RN);
    pkg_doclinks.LINK(nFLAG_SMART   => 0,
                      nCOMPANY      => ncompany,
                      sIN_UNITCODE  => 'DeliveryOrdersPerform',
                      nIN_DOCUMENT  => nrn_perf,
                      sOUT_UNITCODE => 'PaymentAccountsIn',
                      nOUT_DOCUMENT => RACC.RN);
    /*Регистрационный номер записи счета-договора*/
    nrn_acc := RACC.RN;
    /* добавление записи расширения */
    for CLC_EX in (Select CLC.PRN, CLC.RN
                     from PAYACCINSPCLC CLC, PAYACCINSPEC SP
                    where CLC.PRN = SP.RN
                      and SP.PRN = nrn_acc) loop
      UDO_PKG_PAYACCINSPCLC_EX.PAYACCINSPCLC_EX_START(nCOMPANY => nCOMPANY,
                                                      NRN      => CLC_EX.RN,
                                                      NPRN     => CLC_EX.PRN);
    end loop;
  end P_deliveryord_bCRT_PAYACCIN;

  /*Процедура выполняет базовое расформирование счета-договора*/
  procedure P_deliveryord_brmv_PAYACCIN(NCOMPANY in number /*Регистрационный номер организации*/,
                                        nrn      in number /*Регистрационный номер записи*/) is
    /*Атрибуты записи заказа поставщику*/
    rord deliveryord%rowtype;
    /*Регистрационный номер записи исполнения*/
    nrn_perf pkg_std.tREF;
    /*Результат установки состояния*/
    nresult number;
    /*Регистрационный номер записи счета-договора*/
    nrn_acc pkg_std.tREF;
  begin
    /*Атрибуты записи заказа поставщику*/
    begin
      select o.*
        into rord
        from deliveryord o
       where o.rn = nrn
         and o.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DeliveryOrders');
    end;
    /*Выполняем проверку состояния*/
    if not (rord.ord_state in (1)) then
      P_EXCEPTION(0,
                  'Расформирование счета-договора для заказа поставщику в состоянии отличном от "Утвержден" недопустимо.');
    end if;
    /*Выполняем проверку указания лицевого счета*/
    if (rord.faceacc is null) then
      p_exception(0, 'Лицевой счет не указан');
    end if;
    /*Регистрационный номер записи счета-договора*/
    nrn_acc := f_doclinks_link_out_doc(sIN_UNITCODE  => 'DeliveryOrders',
                                       nIN_DOCUMENT  => nrn,
                                       sOUT_UNITCODE => 'PaymentAccountsIn');
    /*Выполняем проверку наличия счета*/
    if (nrn_acc is null) then
      p_exception(0, 'Счет-договор не сформирован');
    end if;
    /*Регистрационный номер записи исполнения*/
    begin
      select p.RN
        into nrn_perf
        from DELIVERYORDP p
       where p.PRN = nrn
         and p.company = ncompany;
    exception
      when no_data_found then
        p_exception(0,
                    'Не удалось определить исполнение');
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить исполнение');
    end;
    /*Выполняем разрыв связи*/
    pkg_doclinks.remove(sIN_UNITCODE  => 'DeliveryOrders',
                        nIN_DOCUMENT  => nrn,
                        sOUT_UNITCODE => 'PaymentAccountsIn',
                        nOUT_DOCUMENT => nrn_acc);
    pkg_doclinks.remove(sIN_UNITCODE  => 'DeliveryOrdersPerform',
                        nIN_DOCUMENT  => nrn_perf,
                        sOUT_UNITCODE => 'PaymentAccountsIn',
                        nOUT_DOCUMENT => nrn_acc);
    /*Выполняем базовое удаление заголовка счета на оплату*/
    p_payaccin_base_delete(ncompany => ncompany, NRN => nrn_acc);
  
    /*Выполняем снятие утверждения заказа поставщику*/
    p_deliveryord_set_state(nflag_smart => 0,
                            ncompany    => ncompany,
                            nrn         => nrn,
                            nflag_mode  => 0,
                            nnew_state  => 2,
                            dstate_date => trunc(sysdate),
                            nresult     => nresult);
    /*Выполняем проверку снятие утверждения заказа поставщику*/
    if (nresult <> 0) then
      p_exception(0,
                  'При снятии утверждения с заказа поставщику возникла ошибка. Обратитесь к администратору');
    end if;
  
    /*Выполняем очистку лицевого счета*/
    update deliveryord o
       set o.faceacc = to_number(null)
     where o.rn = nrn
       and o.company = ncompany;
    /*Выполняем проверку установки лицевого счета*/
    if (sql%notfound) then
      pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                               sUNIT_TABLE => 'DeliveryOrders');
    end if;
  
    /*Выполняем базовое удаление лицевого счета*/
    p_faceacc_base_delete(ncompany => ncompany, NRN => rord.faceacc);
  end P_deliveryord_brmv_PAYACCIN;

  /*Процедура выполняет формирование счета-договора*/
  procedure P_deliveryord_CRT_PAYACCIN(NCOMPANY      in number /*Регистрационный номер организации*/,
                                       nrn           in number /*Регистрационный номер записи*/,
                                       SCATALOG      in varchar2 /*Каталог*/,
                                       SDOC_TYPE     in varchar2 /*Тип*/,
                                       SEXT_NUMB     in varchar2 /*Номер*/,
                                       DDATE         in date /*Дата*/,
                                       SAGENT        in varchar2 /*Контрагент*/,
                                       SAGNACC       in varchar2 /*Реквизиты*/,
                                       sjur_acc      in varchar2 /*Реквизиты плательщика*/,
                                       SEXECUTIVE    in varchar2 /*Ответственный*/,
                                       SSUBDIVISION  in varchar2 /*Подразделение*/,
                                       STARIF        in varchar2 /*Тариф*/,
                                       NPRICEWITHTAX in number /*Цены включают налоги*/,
                                       SNOTE         in varchar2 /*Примечание*/,
                                       SIEELEMENT    in varchar2 /* Статья затрат */,
                                       nrn_acc       out number /*Регистрационный номер записи счета-договора*/) is
    /*Каталог*/
    nCRN pkg_std.tREF;
    /*Каталог*/
    NCATALOG PKG_STD.TREF;
    /*Тип*/
    NDOC_TYPE PKG_STD.TREF;
    /*Контрагент*/
    NAGENT PKG_STD.TREF;
    /*Реквизиты*/
    NAGNACC PKG_STD.TREF;
    /*Контрагент организации*/
    Sjur_AGENT pkg_std.tSTRING;
    /*Реквизиты плательщика*/
    njur_acc PKG_STD.TREF;
    /*Тариф*/
    NTARIF PKG_STD.TREF;
    /*Ответственный*/
    NEXECUTIVE PKG_STD.TREF;
    /*Подразделение*/
    NSUBDIVISION PKG_STD.TREF;
    /* Статья затрат */
    NIEELEMENT PKG_STD.TREF;
  begin
    /*Выполняем проверку существования заказа поставщику*/
    P_DELIVERYORD_EXISTS(nCOMPANY, nRN, nCRN);
    /*Каталог*/
    FIND_ACATALOG_NAME(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       NVERSION    => TO_NUMBER(null),
                       SUNITCODE   => 'PaymentAccountsIn',
                       SNAME       => SCATALOG,
                       NRN         => NCATALOG);
    /*Тип*/
    FIND_DOCTYPES_CODE(NCOMPANY  => NCOMPANY,
                       SDOCCODE  => SDOC_TYPE,
                       SUNITCODE => TO_CHAR(null),
                       NSTYPE    => 0,
                       NRN       => NDOC_TYPE);
    /*Контрагент*/
    FIND_AGNLIST_CODE(NFLAG_SMART  => 0,
                      NFLAG_OPTION => 0,
                      NCOMPANY     => NCOMPANY,
                      SCODE        => SAGENT,
                      NRN          => NAGENT);
    /*Реквизиты*/
    FIND_AGNACC_CODE(NFLAG_SMART => 0,
                     COMPANY     => NCOMPANY,
                     MNEMO       => SAGENT,
                     CODE        => SAGNACC,
                     RN          => NAGNACC);
    /*Контрагент организации*/
    get_company_agent(nFLAG_SMART => 0,
                      nCOMPANY    => NCOMPANY,
                      sAGENT      => Sjur_AGENT);
    /*Реквизиты плательщика*/
    FIND_AGNACC_CODE(NFLAG_SMART => 0,
                     COMPANY     => NCOMPANY,
                     MNEMO       => Sjur_AGENT,
                     CODE        => sjur_acc,
                     RN          => njur_acc);
    /*Тариф*/
    FIND_DICTARIF_CODE(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       SCODE       => STARIF,
                       NFRN        => NTARIF);
    /*Подразделение*/
    FIND_SUBDIVS_CODE(NFLAG_SMART => 0,
                      NCOMPANY    => NCOMPANY,
                      SCODE       => SSUBDIVISION,
                      NRN         => NSUBDIVISION);
    /*Ответственный*/
    FIND_AGNLIST_CODE(NFLAG_SMART  => 0,
                      NFLAG_OPTION => 0,
                      NCOMPANY     => NCOMPANY,
                      SCODE        => SEXECUTIVE,
                      NRN          => NEXECUTIVE);
    /* Статья затрат */
    FIND_FPDARTCL_CODE(NFLAG_SMART => 0
                      ,NCOMPANY    => NCOMPANY
                      ,SCODE       => SIEELEMENT
                      ,NRN         => NIEELEMENT);

    -- Фиксация начала выполнения действия
    PKG_ENV.PROLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'DeliveryOrders',
                     'DeliveryOrdersCntrFactCrtPayAcc',
                     'DELIVERYORD',
                     nrn);
    /*Выполняем базовое формирование счета на оплату*/
    P_deliveryord_bCRT_PAYACCIN(NCOMPANY      => NCOMPANY,
                                nrn           => nrn,
                                NCRN          => NCATALOG,
                                NDOC_TYPE     => NDOC_TYPE,
                                SEXT_NUMB     => SEXT_NUMB,
                                DDATE         => DDATE,
                                NAGENT        => NAGENT,
                                NAGNACC       => NAGNACC,
                                njur_acc      => njur_acc,
                                NEXECUTIVE    => NEXECUTIVE,
                                NSUBDIVISION  => NSUBDIVISION,
                                NTARIF        => NTARIF,
                                NPRICEWITHTAX => NPRICEWITHTAX,
                                SNOTE         => SNOTE,
                                NIEELEMENT    => NIEELEMENT,
                                nrn_acc       => nrn_acc);
    -- Фиксация окончания выполнения действия
    PKG_ENV.epiLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'DeliveryOrders',
                     'DeliveryOrdersCntrFactCrtPayAcc',
                     'DELIVERYORD',
                     nrn);
  end P_deliveryord_CRT_PAYACCIN;

  /*Процедура выполняет расформирование счета-договора*/
  procedure P_deliveryord_rmv_PAYACCIN(NCOMPANY in number /*Регистрационный номер организации*/,
                                       nrn      in number /*Регистрационный номер записи*/) is
    /*Каталог*/
    nCRN pkg_std.tREF;
  begin
    /*Выполняем проверку существования заказа поставщику*/
    P_DELIVERYORD_EXISTS(nCOMPANY, nRN, nCRN);
    -- Фиксация начала выполнения действия
    PKG_ENV.PROLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'DeliveryOrders',
                     'DeliveryOrdersCntrFactRmvPayAcc',
                     'DELIVERYORD',
                     nrn);
    /*Выполняем базовое расформирование счета на оплату*/
    P_deliveryord_brmv_PAYACCIN(NCOMPANY => NCOMPANY, nrn => nrn);
    -- Фиксация окончания выполнения действия
    PKG_ENV.epiLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'DeliveryOrders',
                     'DeliveryOrdersCntrFactRmvPayAcc',
                     'DELIVERYORD',
                     nrn);
  end P_deliveryord_rmv_PAYACCIN;

  /*Функция возвращает вид договора*/
  function f_contracts_calc_kind(NCOMPANY in number /*Регистрационный номер организации*/,
                                 nrn      in number /*Регистрационный номер записи*/)
    return varchar2 is
  begin
    return(prsg_prop.SGET(nCOMPANY  => nCOMPANY,
                          nVERSION  => to_number(null),
                          sUNITCODE => 'Contracts',
                          nDOCUMENT => nrn,
                          sPROPCODE => 'УМТС_ВидДоговора'));
  end f_contracts_calc_kind;

  /*Процедура выполняет формирование этапа договора*/
  procedure p_stages_crt(NCOMPANY       in number /*Регистрационный номер организации*/,
                         njur_pers      in number /*Регистрационный номер записи юридического лица*/,
                         ncntr          in number /*Регистрационный номер записи договора*/,
                         nEXT_AGREEMENT in number /*Признак дополнительного соглашения*/,
                         nAGENT         in number /*Контрагент*/,
                         nAGNACC        in number /*Реквизиты*/,
                         njur_acc       in number /*Реквизиты плательщика*/,
                         nEXECUTIVE     in number /*Ответственный*/,
                         nSUBDIVISION   in number /*Подразделение*/,
                         NPRICEWITHTAX  in number /*Цены включают налоги*/,
                         nTAX_GROUP     in number /*Налоговая группа*/,
                         nSTAGE_SUM     in number /*Сумма без НДС*/,
                         nSTAGE_SUMTAX  in number /*Сумма с НДС*/,
                         nSTAGE_SUM_NDS in number /*Сумма НДС*/,
                         SDESCRIPTION   in varchar2 /*Описание*/,
                         SNOTE          in varchar2 /*Примечание*/,
                         nfaceacc       out number /*Регистрационный номер записи лицевого счета*/) is
  
    /*Атрибуты записи лицевого счета*/
    RFACEACC FACEACC%rowtype;
  
    /*Атрибуты записи договора*/
    RCONTRACT CONTRACTs%rowtype;
  
    /*Атрибуты записи этапа договора*/
    RSTG stages%rowtype;
  
  begin
    /*Атрибуты записи договора*/
    begin
      select C.*
        into RCONTRACT
        from CONTRACTS C
       where C.RN = NCNTR
         and C.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NCNTR,
                                 SUNIT_TABLE => 'Contracts');
    end;
    /*Выполняем установку атрибутов инициализации лицевого счета*/
    P_FACEACC_BASE_DEFVALUES(RREC => RFACEACC);
    /*Организация*/
    RFACEACC.COMPANY := NCOMPANY;
    /*Каталог*/
    FIND_ACATALOG_NAME_EX(NFLAG_SMART  => 0,
                          NFLAG_OPTION => 0,
                          NCOMPANY     => NCOMPANY,
                          NVERSION     => null,
                          SUNITCODE    => 'FaceAccounts',
                          SNAME        => 'ОМТС',
                          NRN          => RFACEACC.CRN);
    /*Юрилическое лицо*/
    RFACEACC.JUR_PERS := njur_pers;
    /*Контрагент*/
    RFACEACC.AGENT := NAGENT;
    /*Номер*/
    p_faceacc_make_new(ncompany   => ncompany,
                       smnemo     => get_agnlist_agnabbr_id(nFLAG_SMART => 0,
                                                            nRN         => nagent),
                       sdelimiter => '\',
                       snumb      => RFACEACC.NUMB);
    /*Документ-основание*/
    RFACEACC.VALID_DOCTYPE := RCONTRACT.DOC_TYPE;
    RFACEACC.VALID_DOCNUMB := PKG_DOCUMENT.MAKE_NUMBER_EX(NCOMPANY  => RCONTRACT.COMPANY,
                                                          SDOC_PREF => RCONTRACT.DOC_PREF,
                                                          SDOC_NUMB => RCONTRACT.DOC_NUMB);
    RFACEACC.VALID_DOCDATE := RCONTRACT.DOC_DATE;
    /*Ответственный*/
    RFACEACC.EXECUTIVE := NEXECUTIVE;
    /*Валюта*/
    RFACEACC.CURRENCY := F_CURBASE_GET_RN(NFLAG_SMART => 0,
                                          NCOMPANY    => NCOMPANY);
    /*Реквизиты*/
    RFACEACC.AGNACC := NAGNACC;
    /*Подразделение*/
    RFACEACC.SUBDIV := NSUBDIVISION;
    /*Тариф*/
    --RFACEACC.TARIF := NTARIF;
    /*Вид оплаты*/
    --RFACEACC.PAYRULE := NPAY_RULE;
    /*Цены включают налоги*/
    RFACEACC.SIGNTAX := NPRICEWITHTAX;
    /*Статья*/
    find_fpdartcl_code(nFLAG_SMART => 0,
                       nCOMPANY    => nCOMPANY,
                       sCODE       => 'Расходы на ПКИ_Б',
                       nRN         => RFACEACC.IEELEMENT);
    /*Выполняем базовое добавление лицевого счета*/
    P_FACEACC_BASE_INSERT(RFACEACC => RFACEACC, NRN => RFACEACC.RN);
    /*Выполняем установку атрибутов инициализации этапа договора*/
    P_STAGES_INIT_ATTRS(RSTG => RSTG);
    /*Дополнительное соглашение*/
    RSTG.EXT_AGREEMENT := nEXT_AGREEMENT;
    /*Организация*/
    RSTG.COMPANY := NCOMPANY;
    /*Регистрационный номер родителя*/
    RSTG.PRN := RCONTRACT.RN;
    /*\*Сумма задается вручную*\
     RSTG.SUM_TYPE := 0;*/ 
    /* 13/09/2023 Степанов М. Тип суммы. Если сумма не задана в параметрах, то "Расчётная по спецификации" иначе - "Вручную" */
    RSTG.SUM_TYPE := case nvl(nSTAGE_SUM, 0) when 0 then 1 else 0 end;
    /*Регистрационный номер записи лицевого счета*/
    RSTG.FACEACC := RFACEACC.RN;
    /*Номер*/
    P_STAGES_GETNEXTNUMB(NCOMPANY  => NCOMPANY,
                         NPRN      => RSTG.PRN,
                         SNUMB_MAX => RSTG.NUMB);
    /*Дата начала*/
    RSTG.BEGIN_DATE := rcontract.begin_date;
    /*Дата окончания*/
    RSTG.END_DATE := nvl(rcontract.end_date,
                         add_months(trunc(rcontract.begin_date, 'year'), 12) - 1);
    /*Реквизиты принадлежности*/
    RSTG.JUR_ACC := NJUR_ACC;
    /*Описание этапа*/
    RSTG.DESCRIPTION := SDESCRIPTION;
    /*Примечание*/
    RSTG.COMMENTS := SNOTE;
    /*Налоговая группа*/
    RSTG.Taxgr := nTAX_GROUP;
    /*Сумма*/
    RSTG.STAGE_SUM     := nSTAGE_SUM;
    RSTG.STAGE_SUMTAX  := nSTAGE_SUMTAX;
    RSTG.STAGE_SUM_NDS := nSTAGE_SUM_NDS;
    /*Выполняем базовое добавление этапа договора*/
    P_STAGES_BASE_INSERT(RSTG => RSTG, NRN => RSTG.RN);
    /*Регистрационный номер записи лицевого счета*/
    nfaceacc := rfaceacc.rn;
  end p_stages_crt;

  /*Процедура выполняет базовое указание действующего рамочного договора*/
  procedure P_deliveryord_bset_cntr(NCOMPANY       in number /*Регистрационный номер организации*/,
                                    nrn            in number /*Регистрационный номер записи*/,
                                    ncntr          in number /*Регистрационный номер записи договора*/,
                                    nAGENT         in number /*Контрагент*/,
                                    nAGNACC        in number /*Реквизиты*/,
                                    njur_acc       in number /*Реквизиты плательщика*/,
                                    nEXECUTIVE     in number /*Ответственный*/,
                                    nSUBDIVISION   in number /*Подразделение*/,
                                    NPRICEWITHTAX  in number /*Цены включают налоги*/,
                                    nTAX_GROUP     in number /*Налоговая группа*/,
                                    nSTAGE_SUM     in number /*Сумма без НДС*/,
                                    nSTAGE_SUMTAX  in number /*Сумма с НДС*/,
                                    nSTAGE_SUM_NDS in number /*Сумма НДС*/,
                                    SDESCRIPTION   in varchar2 /*Описание*/,
                                    SNOTE          in varchar2 /*Примечание*/) is
  
    /*Атрибуты записи заказа поставщику*/
    rord deliveryord%rowtype;
  
    /*Результат установки состояния*/
    nresult number;
  
    /*Вид договора*/
    scntr_kind pkg_std.tSTRING;
  
    /*Регистрационный номер записи этапа договора*/
    nstg pkg_std.tREF;
  
  begin
    /*Атрибуты записи заказа поставщику*/
    begin
      select o.*
        into rord
        from deliveryord o
       where o.rn = nrn
         and o.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DeliveryOrders');
    end;
    /*Выполняем проверку состояния*/
    if not (rord.ord_state in (0, 2)) then
      P_EXCEPTION(0,
                  'Указание действующего рамочного договора для заказа поставщику в состоянии отличном от "Не подтвержден" или "Согласование" недопустимо.');
    end if;
    /*Выполняем проверку указания лицевого счета*/
    if (rord.faceacc is not null) then
      p_exception(0, 'Лицевой счет уже указан');
    end if;
    /*Выполняем проверку корректности указания контрагента*/
    if (get_agnlist_agnabbr_id(nFLAG_SMART => 0, nRN => nagent) = 'Выбор') then
      p_exception(0,
                  'Необходимо указать поставщика');
    end if;
    /*Вид договора*/
    scntr_kind := prsg_prop.SGET(nCOMPANY  => nCOMPANY,
                                 nVERSION  => to_number(null),
                                 sUNITCODE => 'Contracts',
                                 nDOCUMENT => ncntr,
                                 sPROPCODE => 'УМТС_ВидДоговора');
    if (scntr_kind = 'Разовая поставка') then
      p_exception(0,
                  'Выбранный договор является разовой поставкой');
    elsif (scntr_kind in ('Рамочный', 'РамочныйТема')) then
      begin
        select s.faceacc
          into rord.faceacc
          from stages s
         where s.prn = ncntr
           and s.company = ncompany;
      exception
        when no_data_found then
          p_exception(0,
                      'Не удалось определить этап договора');
        when too_many_rows then
          /*Анненко И.С. 01.12.2022*/
          begin
          
            select s.faceacc
              into rord.faceacc
              from stages s
             where s.prn = ncntr
               and s.company = ncompany
               and trim(s.numb) = '0';
          
          exception
            when no_data_found then
              p_exception(0,
                          'Не удалось определить этап договора');
            when too_many_rows then
              p_exception(0,
                          'Не удалось однозначно определить этап договора');
          end;
      end;
    elsif (scntr_kind in ('РамочныйГОЗ')) then
      /*Выполняем формирование этапа договора*/
      p_stages_crt(NCOMPANY       => NCOMPANY,
                   njur_pers      => rord.jur_pers,
                   ncntr          => ncntr,
                   nEXT_AGREEMENT => 1,
                   nAGENT         => nAGENT,
                   nAGNACC        => nAGNACC,
                   njur_acc       => njur_acc,
                   nEXECUTIVE     => nEXECUTIVE,
                   nSUBDIVISION   => nSUBDIVISION,
                   NPRICEWITHTAX  => NPRICEWITHTAX,
                   nTAX_GROUP     => nTAX_GROUP,
                   nSTAGE_SUM     => nSTAGE_SUM,
                   nSTAGE_SUMTAX  => nSTAGE_SUMTAX,
                   nSTAGE_SUM_NDS => nSTAGE_SUM_NDS,
                   SDESCRIPTION   => SDESCRIPTION,
                   SNOTE          => SNOTE,
                   nfaceacc       => rord.faceacc);
    
      /*Регистрационный номер записи этапа договора*/
      begin
        select s.rn
          into nstg
          from stages s
         where s.faceacc = rord.faceacc
           and s.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rord.faceacc,
                                   sUNIT_TABLE => 'ContractsStages');
      end;
    
      /*Выполняем открытие этапа договора*/
      p_stages_setstatus(nCOMPANY    => nCOMPANY,
                         nRN         => nSTG,
                         nSTATUS     => 1,
                         dWORKDATE   => trunc(sysdate),
                         nSSFOD_SIGN => 0);
    else
      p_exception(0,
                  'Не удалось определить вид договора');
    end if;
    /*Выполняем установку лицевого счета*/
    update deliveryord o
       set o.agent = nagent, o.faceacc = rord.faceacc
     where o.rn = nrn
       and o.company = ncompany;
    /*Выполняем проверку установки лицевого счета*/
    if (sql%notfound) then
      pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                               sUNIT_TABLE => 'DeliveryOrders');
    end if;
    /*Выполняем утверждение заказа поставщику*/
    p_deliveryord_set_state(nflag_smart => 0,
                            ncompany    => ncompany,
                            nrn         => nrn,
                            nflag_mode  => 0,
                            nnew_state  => 1,
                            dstate_date => trunc(sysdate),
                            nresult     => nresult);
    /*Выполняем проверку утверждения заказа поставщику*/
    if (nresult <> 0) then
      p_exception(0,
                  'При утверждении заказа поставщику возникла ошибка. Обратитесь к администратору');
    end if;
  end P_deliveryord_bset_cntr;

  /*Процедура выполняет базовую очистку действующего рамочного договора*/
  procedure P_deliveryord_bclr_cntr(NCOMPANY in number /*Регистрационный номер организации*/,
                                    nrn      in number /*Регистрационный номер записи*/) is
  
    /*Атрибуты записи заказа поставщику*/
    rord deliveryord%rowtype;
  
    /*Результат установки состояния*/
    nresult number;
  
    /*Вид договора*/
    scntr_kind pkg_std.tSTRING;
  
    /*Регистрационный номер записи этапа договора*/
    nstg pkg_std.tREF;
  
    /*Регистрационный номер записи договора*/
    ncntr pkg_std.tREF;
  
  begin
    /*Атрибуты записи заказа поставщику*/
    begin
      select o.*
        into rord
        from deliveryord o
       where o.rn = nrn
         and o.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DeliveryOrders');
    end;
    /*Выполняем проверку состояния*/
    if not (rord.ord_state in (1)) then
      P_EXCEPTION(0,
                  'Очистка действующего рамочного договора для заказа поставщику в состоянии отличном от "Утвержден" недопустимо.');
    end if;
    /*Выполняем проверку указания лицевого счета*/
    if (rord.faceacc is null) then
      p_exception(0, 'Лицевой счет не указан');
    end if;
  
    /*Выполняем снятие утверждения заказа поставщику*/
    p_deliveryord_set_state(nflag_smart => 0,
                            ncompany    => ncompany,
                            nrn         => nrn,
                            nflag_mode  => 0,
                            nnew_state  => 2,
                            dstate_date => trunc(sysdate),
                            nresult     => nresult);
    /*Выполняем проверку снятие утверждения заказа поставщику*/
    if (nresult <> 0) then
      p_exception(0,
                  'При снятии утверждения с заказа поставщику возникла ошибка. Обратитесь к администратору');
    end if;
  
    /*Выполняем очистку лицевого счета*/
    update deliveryord o
       set o.faceacc = to_number(null)
     where o.rn = nrn
       and o.company = ncompany;
    /*Выполняем проверку установки лицевого счета*/
    if (sql%notfound) then
      pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                               sUNIT_TABLE => 'DeliveryOrders');
    end if;
  
    /*Регистрационный номер записи этапа договора*/
  
    /*Регистрационный номер записи договора*/
    begin
      select s.rn, s.prn
        into nstg, ncntr
        from stages s
       where s.faceacc = rord.faceacc
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rord.faceacc,
                                 sUNIT_TABLE => 'ContractsStages');
    end;
    /*Вид договора*/
    scntr_kind := prsg_prop.SGET(nCOMPANY  => nCOMPANY,
                                 nVERSION  => to_number(null),
                                 sUNITCODE => 'Contracts',
                                 nDOCUMENT => ncntr,
                                 sPROPCODE => 'УМТС_ВидДоговора');
  
    if (scntr_kind = 'Разовая поставка') then
      p_exception(0,
                  'Выбранный договор является разовой поставкой');
    elsif (scntr_kind in ('Рамочный', 'РамочныйТема')) then
      null;
    elsif (scntr_kind in ('РамочныйГОЗ')) then
    
      /*Выполняем закрытие этапа договора*/
      p_stages_setstatus(nCOMPANY    => nCOMPANY,
                         nRN         => nSTG,
                         nSTATUS     => 0,
                         dWORKDATE   => trunc(sysdate),
                         nSSFOD_SIGN => 0);
    
      /*Выполняем базовое удаление этапа договора*/
      p_stages_base_delete(nrn => nSTG, nSIGN_DIR => 0);
    
      /*Выполняем базовое удаление лицевого счета*/
      p_faceacc_base_delete(ncompany => ncompany, NRN => rord.faceacc);
    
    else
      p_exception(0,
                  'Не удалось определить вид договора');
    end if;
  end P_deliveryord_bclr_cntr;

  /*Процедура выполняет указание действующего рамочного договора*/
  procedure P_deliveryord_set_cntr(NCOMPANY       in number /*Регистрационный номер организации*/,
                                   nrn            in number /*Регистрационный номер записи*/,
                                   ncntr          in number /*Регистрационный номер записи договора*/,
                                   SAGENT         in varchar2 /*Контрагент*/,
                                   SAGNACC        in varchar2 /*Реквизиты*/,
                                   sjur_acc       in varchar2 /*Реквизиты плательщика*/,
                                   SEXECUTIVE     in varchar2 /*Ответственный*/,
                                   SSUBDIVISION   in varchar2 /*Подразделение*/,
                                   NPRICEWITHTAX  in number /*Цены включают налоги*/,
                                   STAX_GROUP     in varchar2 /*Налоговая группа*/,
                                   nSTAGE_SUM     in number /*Сумма без НДС*/,
                                   nSTAGE_SUMTAX  in number /*Сумма с НДС*/,
                                   nSTAGE_SUM_NDS in number /*Сумма НДС*/,
                                   SDESCRIPTION   in varchar2 /*Описание*/,
                                   SNOTE          in varchar2 /*Примечание*/) is
    /*Каталог*/
    nCRN pkg_std.tREF;
    /*Контрагент*/
    NAGENT PKG_STD.TREF;
    /*Реквизиты*/
    NAGNACC PKG_STD.TREF;
    /*Контрагент организации*/
    Sjur_AGENT pkg_std.tSTRING;
    /*Реквизиты плательщика*/
    njur_acc PKG_STD.TREF;
    /*Ответственный*/
    NEXECUTIVE PKG_STD.TREF;
    /*Подразделение*/
    NSUBDIVISION PKG_STD.TREF;
    /*Налоговая группа*/
    NTAX_GROUP PKG_STD.TREF;
  begin
    /*Выполняем проверку существования заказа поставщику*/
    P_DELIVERYORD_EXISTS(nCOMPANY, nRN, nCRN);
    /*Контрагент*/
    FIND_AGNLIST_CODE(NFLAG_SMART  => 0,
                      NFLAG_OPTION => 0,
                      NCOMPANY     => NCOMPANY,
                      SCODE        => SAGENT,
                      NRN          => NAGENT);
    /*Реквизиты*/
    if (trim(SAGNACC) is not null) then
      FIND_AGNACC_CODE(NFLAG_SMART => 0,
                       COMPANY     => NCOMPANY,
                       MNEMO       => SAGENT,
                       CODE        => SAGNACC,
                       RN          => NAGNACC);
    end if;
    /*Контрагент организации*/
    get_company_agent(nFLAG_SMART => 0,
                      nCOMPANY    => NCOMPANY,
                      sAGENT      => Sjur_AGENT);
    /*Реквизиты плательщика*/
    if (trim(sjur_acc) is not null) then
      FIND_AGNACC_CODE(NFLAG_SMART => 0,
                       COMPANY     => NCOMPANY,
                       MNEMO       => Sjur_AGENT,
                       CODE        => sjur_acc,
                       RN          => njur_acc);
    end if;
    /*Подразделение*/
    FIND_SUBDIVS_CODE(NFLAG_SMART => 0,
                      NCOMPANY    => NCOMPANY,
                      SCODE       => SSUBDIVISION,
                      NRN         => NSUBDIVISION);
    /*Ответственный*/
    FIND_AGNLIST_CODE(NFLAG_SMART  => 0,
                      NFLAG_OPTION => 0,
                      NCOMPANY     => NCOMPANY,
                      SCODE        => SEXECUTIVE,
                      NRN          => NEXECUTIVE);
    /*Налоговая группа*/
    FIND_DICTAXGR_CODE(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       SCODE       => STAX_GROUP,
                       NRN         => NTAX_GROUP);
    -- Фиксация начала выполнения действия
    PKG_ENV.PROLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'DeliveryOrders',
                     'DeliveryOrdersCntrFactSetCntr',
                     'DELIVERYORD',
                     nrn);
    /*Выполняем базовое указание действующего рамочного договора*/
    P_deliveryord_bset_cntr(NCOMPANY       => NCOMPANY,
                            nrn            => nrn,
                            ncntr          => ncntr,
                            NAGENT         => NAGENT,
                            NAGNACC        => NAGNACC,
                            njur_acc       => njur_acc,
                            NEXECUTIVE     => NEXECUTIVE,
                            NSUBDIVISION   => NSUBDIVISION,
                            NPRICEWITHTAX  => NPRICEWITHTAX,
                            nTAX_GROUP     => nTAX_GROUP,
                            nSTAGE_SUM     => nSTAGE_SUM,
                            nSTAGE_SUMTAX  => nSTAGE_SUMTAX,
                            nSTAGE_SUM_NDS => nSTAGE_SUM_NDS,
                            SDESCRIPTION   => SDESCRIPTION,
                            SNOTE          => SNOTE);
    -- Фиксация окончания выполнения действия
    PKG_ENV.epiLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'DeliveryOrders',
                     'DeliveryOrdersCntrFactSetCntr',
                     'DELIVERYORD',
                     nrn);
  end P_deliveryord_set_cntr;

  /*Процедура выполняет очистку действующего рамочного договора*/
  procedure P_deliveryord_clr_cntr(NCOMPANY in number /*Регистрационный номер организации*/,
                                   nrn      in number /*Регистрационный номер записи*/) is
    /*Каталог*/
    nCRN pkg_std.tREF;
  begin
    /*Выполняем проверку существования заказа поставщику*/
    P_DELIVERYORD_EXISTS(nCOMPANY, nRN, nCRN);
    -- Фиксация начала выполнения действия
    PKG_ENV.PROLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'DeliveryOrders',
                     'DeliveryOrdersCntrFactClrCntr',
                     'DELIVERYORD',
                     nrn);
    /*Выполняем базовое очистку действующего рамочного договора*/
    P_deliveryord_bclr_cntr(NCOMPANY => NCOMPANY, nrn => nrn);
    -- Фиксация окончания выполнения действия
    PKG_ENV.epiLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'DeliveryOrders',
                     'DeliveryOrdersCntrFactClrCntr',
                     'DELIVERYORD',
                     nrn);
  end P_deliveryord_clr_cntr;

  /*Процедура выполняет базовое формирование нового договора*/
  procedure P_deliveryord_bcrt_cntr(NCOMPANY       in number /*Регистрационный номер организации*/,
                                    nrn            in number /*Регистрационный номер записи*/,
                                    ncrn           in number /*Каталог*/,
                                    nDOC_TYPE      in number /*Тип*/,
                                    scntr_kind     in varchar2 /*Вид договора*/,
                                    sdoc_pref      in varchar2 /*Префикс договора*/,
                                    sdoc_numb      in varchar2 /*Номер договора по журналу бухгалтерии*/,
                                    SEXT_NUMB      in varchar2 /*Номер*/,
                                    DDATE          in date /*Дата*/,
                                    nAGENT         in number /*Контрагент*/,
                                    nAGNACC        in number /*Реквизиты*/,
                                    njur_acc       in number /*Реквизиты плательщика*/,
                                    nigk           in number /*ИГК*/,
                                    nEXECUTIVE     in number /*Ответственный*/,
                                    nSUBDIVISION   in number /*Подразделение*/,
                                    DDATE_BEGIN    in date /*Дата начала периода*/,
                                    DDATE_END      in date /*Дата окончания периода*/,
                                    sSUBJECT       in varchar2 /*Предмет договора*/,
                                    NPRICEWITHTAX  in number /*Цены включают налоги*/,
                                    nTAX_GROUP     in number /*Налоговая группа*/,
                                    nSTAGE_SUM     in number /*Сумма без НДС*/,
                                    nSTAGE_SUMTAX  in number /*Сумма с НДС*/,
                                    nSTAGE_SUM_NDS in number /*Сумма НДС*/,
                                    SDESCRIPTION   in varchar2 /*Описание*/,
                                    SNOTE          in varchar2 /*Примечание*/,
                                    ncntr          out number /*Регистрационный номер записи договора*/) is
  
    /*Атрибуты записи заказа поставщику*/
    rord deliveryord%rowtype;
  
    /*Результат установки состояния*/
    nresult number;
  
    /*Атрибуты записи договора*/
    RCONTRACT CONTRACTs%rowtype;
  
    /*Регистрационный номер записи этапа договора*/
    nstg pkg_std.tREF;
  
  begin
    /*Атрибуты записи заказа поставщику*/
    begin
      select o.*
        into rord
        from deliveryord o
       where o.rn = nrn
         and o.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DeliveryOrders');
    end;
    /*Выполняем проверку состояния*/
    if not (rord.ord_state in (0, 2)) then
      P_EXCEPTION(0,
                  'Формирование договора для заказа поставщику в состоянии отличном от "Не подтвержден" или "Согласование" недопустимо.
                  Текущее состояние %s', rord.ord_state);
    end if;
    /*Выполняем проверку указания лицевого счета*/
    if (rord.faceacc is not null) then
      p_exception(0, 'Лицевой счет уже указан');
    end if;
    /*Выполняем проверку наличия договора*/
    if (f_doclinks_link_out_doc(sIN_UNITCODE  => 'DeliveryOrders',
                                nIN_DOCUMENT  => nrn,
                                sOUT_UNITCODE => 'Contracts') is not null) then
      p_exception(0, 'Договор уже сформирован');
    end if;
    /*Выполняем проверку корректности указания контрагента*/
    if (get_agnlist_agnabbr_id(nFLAG_SMART => 0, nRN => nagent) = 'Выбор') then
      p_exception(0,
                  'Необходимо указать поставщика');
    end if;
    /*Выполняем установку атрибутов инициализации договора*/
    P_CONTRACTS_INIT_ATTRS(RCONTRACT => RCONTRACT);
    RCONTRACT.INOUT_SIGN := 0;
    /*Условный*/
    RCONTRACT.FALSE_DOC := 0;
    /*Организация*/
    RCONTRACT.COMPANY := NCOMPANY;
    /*Каталог*/
    RCONTRACT.CRN := NCRN;
    /*Юрилическое лицо*/
    RCONTRACT.JUR_PERS := rord.jur_pers;
    /*Реквизиты принадлежности*/
    if (scntr_kind in ('РамочныйГОЗ')) then
      RCONTRACT.JUR_ACC := to_number(null);
    else
      RCONTRACT.JUR_ACC := NJUR_ACC;
    end if;
    /*Тип*/
    RCONTRACT.DOC_TYPE := NDOC_TYPE;
    /*Префикс*/
    --RCONTRACT.DOC_PREF := TO_CHAR(DDATE, 'yyyy');
    RCONTRACT.DOC_PREF := sDOC_PREF || '/' || TO_CHAR(DDATE, 'yy');
    /*Номер*/
    /*P_CONTRACTS_BASE_GETNEXTNUMB(NCOMPANY  => NCOMPANY,
    NJUR_PERS => RCONTRACT.JUR_PERS,
    DDOC_DATE => DDATE,
    NDOC_TYPE => RCONTRACT.DOC_TYPE,
    SDOC_PREF => RCONTRACT.DOC_PREF,
    SDOC_NUMB => RCONTRACT.DOC_NUMB);*/
    RCONTRACT.DOC_NUMB := sDOC_NUMB;
    /*Дата*/
    RCONTRACT.DOC_DATE := DDATE;
    /*Внешний номер*/
    RCONTRACT.EXT_NUMBER := SEXT_NUMB;
    /* Дата регистрации */
    RCONTRACT.REG_DATE   := DDATE;
    /*Контрагент*/
    RCONTRACT.AGENT := NAGENT;
    /*Рекивзиты*/
    RCONTRACT.AGNACC := NAGNACC;
    /*Ответственный*/
    RCONTRACT.EXECUTIVE := NEXECUTIVE;
    /*Подразделение*/
    RCONTRACT.SUBDIVISION := NSUBDIVISION;
    /*Дата начала периода*/
    RCONTRACT.BEGIN_DATE := DDATE_BEGIN;
    /*Дата окончания периода*/
    RCONTRACT.END_DATE := DDATE_END;
    /*Валюта*/
    RCONTRACT.CURRENCY := F_CURBASE_GET_RN(NFLAG_SMART => 0,
                                           NCOMPANY    => NCOMPANY);
    /*Предмет*/
    RCONTRACT.SUBJECT := sSUBJECT;
    /*ИГК*/
    RCONTRACT.Govcntrid := nigk;
    /*Примечание*/
    --RCONTRACT.NOTE := SNOTE;
    /* 13/09/2023 Степанов М.  Рамочный */
    RCONTRACT.sign_frame := 0;
    /* 13/09/2023 Степанов М.  Тип суммы - расчётная */
    RCONTRACT.sum_type := 1;
    /*Выполняем базовое добавление договора*/
    P_CONTRACTS_BASE_INSERT(RCONTRACT => RCONTRACT, NRN => RCONTRACT.RN);
    /*Вид договора*/
    prsg_prop.VSET(sUNITCODE  => 'Contracts',
                   nDOCUMENT  => RCONTRACT.RN,
                   sPROPCODE  => 'УМТС_ВидДоговора',
                   sSTRVALUE  => scntr_kind,
                   nNUMVALUE  => to_number(null),
                   dDATEVALUE => to_date(null));
    /*Выполняем формирование этапа договора*/
    p_stages_crt(NCOMPANY       => NCOMPANY,
                 njur_pers      => rord.jur_pers,
                 ncntr          => RCONTRACT.RN,
                 nEXT_AGREEMENT => 0,
                 nAGENT         => nAGENT,
                 nAGNACC        => nAGNACC,
                 njur_acc       => njur_acc,
                 nEXECUTIVE     => nEXECUTIVE,
                 nSUBDIVISION   => nSUBDIVISION,
                 NPRICEWITHTAX  => NPRICEWITHTAX,
                 nTAX_GROUP     => nTAX_GROUP,
                 nSTAGE_SUM     => (case
                                     when (scntr_kind in
                                          ('Рамочный',
                                            'РамочныйТема')) then
                                      (0)
                                     else
                                      (nSTAGE_SUM)
                                   end),
                 nSTAGE_SUMTAX  => (case
                                     when (scntr_kind in
                                          ('Рамочный',
                                            'РамочныйТема')) then
                                      (0)
                                     else
                                      (nSTAGE_SUMTAX)
                                   end),
                 nSTAGE_SUM_NDS => (case
                                     when (scntr_kind in
                                          ('Рамочный',
                                            'РамочныйТема')) then
                                      (0)
                                     else
                                      (nSTAGE_SUM_NDS)
                                   end),
                 SDESCRIPTION   => sDESCRIPTION,
                 SNOTE          => sNOTE,
                 nfaceacc       => rord.faceacc);
  
    /*Регистрационный номер записи этапа договора*/
    begin
      select s.rn
        into nstg
        from stages s
       where s.faceacc = rord.faceacc
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => rord.faceacc,
                                 sUNIT_TABLE => 'ContractsStages');
    end;
  
    /*Утверждаем договор*/
    p_contracts_setstatus(nCOMPANY  => nCOMPANY,
                          nRN       => RCONTRACT.RN,
                          nSTATUS   => 1,
                          dWORKDATE => trunc(sysdate));
  
    /*Выполняем открытие этапа договора*/
    p_stages_setstatus(nCOMPANY    => nCOMPANY,
                       nRN         => nstg,
                       nSTATUS     => 1,
                       dWORKDATE   => trunc(sysdate),
                       nSSFOD_SIGN => 0);
  
    /*Выполняем установку лицевого счета*/
    update deliveryord o
       set o.agent = nagent, o.faceacc = rord.faceacc
     where o.rn = nrn
       and o.company = ncompany;
    /*Выполняем проверку установки лицевого счета*/
    if (sql%notfound) then
      pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                               sUNIT_TABLE => 'DeliveryOrders');
    end if;
    /*Выполняем утверждение заказа поставщику*/
    p_deliveryord_set_state(nflag_smart => 0,
                            ncompany    => ncompany,
                            nrn         => nrn,
                            nflag_mode  => 0,
                            nnew_state  => 1,
                            dstate_date => trunc(sysdate),
                            nresult     => nresult);
    /*Выполняем проверку утверждения заказа поставщику*/
    if (nresult <> 0) then
      p_exception(0,
                  'При утверждении заказа поставщику возникла ошибка. Обратитесь к администратору');
    end if;
  
    /*Выполняем установку связи*/
    pkg_doclinks.LINK(nFLAG_SMART   => 0,
                      nCOMPANY      => ncompany,
                      sIN_UNITCODE  => 'DeliveryOrders',
                      nIN_DOCUMENT  => nrn,
                      sOUT_UNITCODE => 'Contracts',
                      nOUT_DOCUMENT => RCONTRACT.RN);
  
    /*Регистрационный номер записи договора*/
    ncntr := RCONTRACT.RN;
  end P_deliveryord_bcrt_cntr;

  /*Процедура выполняет базовое расформирование нового договора*/
  procedure P_deliveryord_brmv_cntr(NCOMPANY in number /*Регистрационный номер организации*/,
                                    nrn      in number /*Регистрационный номер записи*/) is
  
    /*Атрибуты записи заказа поставщику*/
    rord deliveryord%rowtype;
  
    /*Результат установки состояния*/
    nresult number;
  
    /*Регистрационный номер записи договора*/
    ncntr pkg_std.tREF;
  
  begin
    /*Атрибуты записи заказа поставщику*/
    begin
      select o.*
        into rord
        from deliveryord o
       where o.rn = nrn
         and o.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DeliveryOrders');
    end;
    /*Выполняем проверку состояния*/
    if not (rord.ord_state in (1)) then
      P_EXCEPTION(0,
                  'Расформирование договора для заказа поставщику в состоянии отличном от "Утвержден" недопустимо.');
    end if;
    /*Выполняем проверку указания лицевого счета*/
    if (rord.faceacc is null) then
      p_exception(0, 'Лицевой счет не указан');
    end if;
    /*Регистрационный номер записи договора*/
    ncntr := f_doclinks_link_out_doc(sIN_UNITCODE  => 'DeliveryOrders',
                                     nIN_DOCUMENT  => nrn,
                                     sOUT_UNITCODE => 'Contracts');
    /*Выполняем проверку наличия договора*/
    if (ncntr is null) then
      p_exception(0, 'Договор не сформирован');
    end if;
  
    /*Выполняем разрыв связи*/
    pkg_doclinks.remove(sIN_UNITCODE  => 'DeliveryOrders',
                        nIN_DOCUMENT  => nrn,
                        sOUT_UNITCODE => 'Contracts',
                        nOUT_DOCUMENT => ncntr);
  
    /*Выполняем снятие утверждения заказа поставщику*/
    p_deliveryord_set_state(nflag_smart => 0,
                            ncompany    => ncompany,
                            nrn         => nrn,
                            nflag_mode  => 0,
                            nnew_state  => 2,
                            dstate_date => trunc(sysdate),
                            nresult     => nresult);
    /*Выполняем проверку снятие утверждения заказа поставщику*/
    if (nresult <> 0) then
      p_exception(0,
                  'При снятии утверждения с заказа поставщику возникла ошибка. Обратитесь к администратору');
    end if;
  
    /*Выполняем очистку лицевого счета*/
    update deliveryord o
       set o.faceacc = to_number(null)
     where o.rn = nrn
       and o.company = ncompany;
    /*Выполняем проверку установки лицевого счета*/
    if (sql%notfound) then
      pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                               sUNIT_TABLE => 'DeliveryOrders');
    end if;
  
    /*Снимаем утверждение с договора*/
    p_contracts_setstatus(nCOMPANY  => nCOMPANY,
                          nRN       => ncntr,
                          nSTATUS   => 0,
                          dWORKDATE => trunc(sysdate));
  
    /*Выполняем базовое удаление договора*/
    p_contracts_base_delete(ncompany => ncompany, nrn => ncntr);
  
    /*Выполняем базовое удаление лицевого счета*/
    p_faceacc_base_delete(ncompany => ncompany, NRN => rord.faceacc);
  end P_deliveryord_brmv_cntr;

  /*Процедура выполняет формирование нового договора*/
  procedure P_deliveryord_crt_cntr(NCOMPANY       in number /*Регистрационный номер организации*/,
                                   nrn            in number /*Регистрационный номер записи*/,
                                   SCATALOG       in varchar2 /*Каталог*/,
                                   SDOC_TYPE      in varchar2 /*Тип*/,
                                   scntr_kind     in varchar2 /*Вид договора*/,
                                   sdoc_pref      in varchar2 /*Префикс договора*/,
                                   sdoc_numb      in varchar2 /*Номер договора по журналу бухгалтерии*/,
                                   SEXT_NUMB      in varchar2 /*Номер*/,
                                   DDATE          in date /*Дата*/,
                                   SAGENT         in varchar2 /*Контрагент*/,
                                   SAGNACC        in varchar2 /*Реквизиты*/,
                                   sjur_acc       in varchar2 /*Реквизиты плательщика*/,
                                   sigk           in varchar2 /*ИГК*/,
                                   SEXECUTIVE     in varchar2 /*Ответственный*/,
                                   SSUBDIVISION   in varchar2 /*Подразделение*/,
                                   DDATE_BEGIN    in date /*Дата начала периода*/,
                                   DDATE_END      in date /*Дата окончания периода*/,
                                   sSUBJECT       in varchar2 /*Предмет договора*/,
                                   NPRICEWITHTAX  in number /*Цены включают налоги*/,
                                   STAX_GROUP     in varchar2 /*Налоговая группа*/,
                                   nSTAGE_SUM     in number /*Сумма без НДС*/,
                                   nSTAGE_SUMTAX  in number /*Сумма с НДС*/,
                                   nSTAGE_SUM_NDS in number /*Сумма НДС*/,
                                   SDESCRIPTION   in varchar2 /*Описание*/,
                                   SNOTE          in varchar2 /*Примечание*/,
                                   ncntr          out number /*Регистрационный номер записи договора*/) is
    /*Каталог*/
    nCRN pkg_std.tREF;
    /*Каталог*/
    NCATALOG PKG_STD.TREF;
    /*Тип*/
    NDOC_TYPE PKG_STD.TREF;
    /*Контрагент*/
    NAGENT PKG_STD.TREF;
    /*Реквизиты*/
    NAGNACC PKG_STD.TREF;
    /*Контрагент организации*/
    Sjur_AGENT pkg_std.tSTRING;
    /*Реквизиты плательщика*/
    njur_acc PKG_STD.TREF;
    /*Ответственный*/
    NEXECUTIVE PKG_STD.TREF;
    /*Подразделение*/
    NSUBDIVISION PKG_STD.TREF;
    /*Налоговая группа*/
    NTAX_GROUP PKG_STD.TREF;
    /*ИГК*/
    nigk PKG_STD.TREF;
  begin
    /*Выполняем проверку существования заказа поставщику*/
    P_DELIVERYORD_EXISTS(nCOMPANY, nRN, nCRN);
    /*Каталог*/
    FIND_ACATALOG_NAME(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       NVERSION    => TO_NUMBER(null),
                       SUNITCODE   => 'Contracts',
                       SNAME       => SCATALOG,
                       NRN         => NCATALOG);
    /*Тип*/
    FIND_DOCTYPES_CODE(NCOMPANY  => NCOMPANY,
                       SDOCCODE  => SDOC_TYPE,
                       SUNITCODE => TO_CHAR(null),
                       NSTYPE    => 0,
                       NRN       => NDOC_TYPE);
    /*Контрагент*/
    FIND_AGNLIST_CODE(NFLAG_SMART  => 0,
                      NFLAG_OPTION => 0,
                      NCOMPANY     => NCOMPANY,
                      SCODE        => SAGENT,
                      NRN          => NAGENT);
    /*Реквизиты*/
    if (trim(SAGNACC) is not null) then
      FIND_AGNACC_CODE(NFLAG_SMART => 0,
                       COMPANY     => NCOMPANY,
                       MNEMO       => SAGENT,
                       CODE        => SAGNACC,
                       RN          => NAGNACC);
    end if;
    /*Контрагент организации*/
    get_company_agent(nFLAG_SMART => 0,
                      nCOMPANY    => NCOMPANY,
                      sAGENT      => Sjur_AGENT);
    /*Реквизиты плательщика*/
    if (trim(sjur_acc) is not null) then
      FIND_AGNACC_CODE(NFLAG_SMART => 0,
                       COMPANY     => NCOMPANY,
                       MNEMO       => Sjur_AGENT,
                       CODE        => sjur_acc,
                       RN          => njur_acc);
    end if;
    /*Подразделение*/
    FIND_SUBDIVS_CODE(NFLAG_SMART => 0,
                      NCOMPANY    => NCOMPANY,
                      SCODE       => SSUBDIVISION,
                      NRN         => NSUBDIVISION);
    /*Ответственный*/
    FIND_AGNLIST_CODE(NFLAG_SMART  => 0,
                      NFLAG_OPTION => 0,
                      NCOMPANY     => NCOMPANY,
                      SCODE        => SEXECUTIVE,
                      NRN          => NEXECUTIVE);
    /*Налоговая группа*/
    FIND_DICTAXGR_CODE(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       SCODE       => STAX_GROUP,
                       NRN         => NTAX_GROUP);
    /*ИГК*/
    find_govcntrid_code(nFLAG_SMART  => 0,
                        nFLAG_OPTION => 1,
                        nCOMPANY     => ncompany,
                        sCODE        => sigk,
                        nRN          => nigk);
    -- Фиксация начала выполнения действия
    PKG_ENV.PROLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'DeliveryOrders',
                     'DeliveryOrdersCntrFactCrtCntr',
                     'DELIVERYORD',
                     nrn);
    /*Выполняем базовое формирование нового договора*/
    P_deliveryord_bcrt_cntr(NCOMPANY       => NCOMPANY,
                            nrn            => nrn,
                            ncrn           => ncatalog,
                            nDOC_TYPE      => nDOC_TYPE,
                            scntr_kind     => scntr_kind,
                            sdoc_pref      => sdoc_pref,
                            sdoc_numb      => sdoc_numb,
                            SEXT_NUMB      => SEXT_NUMB,
                            DDATE          => DDATE,
                            NAGENT         => NAGENT,
                            NAGNACC        => NAGNACC,
                            njur_acc       => njur_acc,
                            nigk           => nigk,
                            NEXECUTIVE     => NEXECUTIVE,
                            NSUBDIVISION   => NSUBDIVISION,
                            DDATE_BEGIN    => DDATE_BEGIN,
                            DDATE_END      => DDATE_END,
                            sSUBJECT       => sSUBJECT,
                            NPRICEWITHTAX  => NPRICEWITHTAX,
                            nTAX_GROUP     => nTAX_GROUP,
                            nSTAGE_SUM     => nSTAGE_SUM,
                            nSTAGE_SUMTAX  => nSTAGE_SUMTAX,
                            nSTAGE_SUM_NDS => nSTAGE_SUM_NDS,
                            SDESCRIPTION   => SDESCRIPTION,
                            SNOTE          => SNOTE,
                            ncntr          => ncntr);
    -- Фиксация окончания выполнения действия
    PKG_ENV.epiLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'DeliveryOrders',
                     'DeliveryOrdersCntrFactCrtCntr',
                     'DELIVERYORD',
                     nrn);
  end P_deliveryord_crt_cntr;

  /*Процедура выполняет расформирование нового договора*/
  procedure P_deliveryord_rmv_cntr(NCOMPANY in number /*Регистрационный номер организации*/,
                                   nrn      in number /*Регистрационный номер записи*/) is
    /*Каталог*/
    nCRN pkg_std.tREF;
  begin
    /*Выполняем проверку существования заказа поставщику*/
    P_DELIVERYORD_EXISTS(nCOMPANY, nRN, nCRN);
    -- Фиксация начала выполнения действия
    PKG_ENV.PROLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'DeliveryOrders',
                     'DeliveryOrdersCntrFactRmvCntr',
                     'DELIVERYORD',
                     nrn);
    /*Выполняем базовое расформирование нового договора*/
    P_deliveryord_brmv_cntr(NCOMPANY => NCOMPANY, nrn => nrn);
    -- Фиксация окончания выполнения действия
    PKG_ENV.epiLOGUE(nCOMPANY,
                     null,
                     nCRN,
                     'DeliveryOrders',
                     'DeliveryOrdersCntrFactRmvCntr',
                     'DELIVERYORD',
                     nrn);
  end P_deliveryord_rmv_cntr;

  /*Процедура выполняет исправление номера документа-основания для указанного лицевого счета*/
  procedure p_faceacc_upd_valid_docnumb(NCOMPANY       in number /*Регистрационный номер организации*/,
                                        nrn            in number /*Регистрационный номер записи*/,
                                        sVALID_DOCNUMB in varchar2 /*Номер документа-основания*/) is
  begin
    /* исправление записи в таблице */
    update FACEACC fa
       set fa.vALID_DOCNUMB = sVALID_DOCNUMB
     where fa.RN = nrn
       and fa.COMPANY = nCOMPANY;
  
    if (SQL%NOTFOUND) then
      PKG_MSG.RECORD_NOT_FOUND(nrn, 'FaceAccounts');
    end if;
  
    /*Цикл по приходным накладным*/
    for inv_cursor in (select i.rn as nrn
                         from ininvoices i
                        where i.faceacc = nrn
                          and i.company = ncompany) loop
      /* исправление записи в таблице */
      update ININVOICES i
         set i.VALID_DOCNUMB = sVALID_DOCNUMB
       where i.RN = inv_cursor.nRN
         and i.company = ncompany;
      --
      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(inv_cursor.nRN, 'IncomingInvoices');
      end if;
    end loop;
  
    /*Цикл по приходным ордерам*/
    for ord_cursor in (select o.rn as nrn
                         from inorders o
                        where o.faceacc = nrn
                          and o.company = ncompany) loop
      /* исправление записи в таблице */
      update INORDERS o
         set o.CONFDOCNUMB = sVALID_DOCNUMB
       where o.RN = ord_cursor.nRN
         and o.COMPANY = nCOMPANY;
      --
      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(ord_cursor.nRN, 'IncomingOrders');
      end if;
    end loop;
  
    /*Цикл по счетам на оплату*/
    for acc_cursor in (select a.rn as nrn
                         from payaccin a
                        where a.faceacc = nrn
                          and a.company = ncompany) loop
      /* исправление записи в таблице */
      update PAYACCIN p
         set p.VDOC_NUM = sVALID_DOCNUMB
       where p.RN = acc_cursor.nRN
         and p.COMPANY = nCOMPANY;
    
      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(acc_cursor.nRN, 'PaymentAccountsIn');
      end if;
    end loop;
  
    /*Цикл по журналу платежей*/
    for pay_cursor in (select p.rn as nrn
                         from paynotes p
                        where p.faceacc = nrn
                          and p.company = ncompany) loop
      update PAYNOTES p
         set p.VDOC_NUMB = sVALID_DOCNUMB
       where p.RN = pay_cursor.nRN
         and p.COMPANY = nCOMPANY;
    
      if (SQL%NOTFOUND) then
        PKG_MSG.RECORD_NOT_FOUND(pay_cursor.nRN, 'PayNotes');
      end if;
    end loop;
  end p_faceacc_upd_valid_docnumb;

  /*Процедура выполняет исправление внутреннего номера договора*/
  procedure p_contracts_upd_pref_numb(NCOMPANY  in number /*Регистрационный номер организации*/,
                                      nrn       in number /*Регистрационный номер записи*/,
                                      sdoc_pref in varchar2 /*Префикс договора*/,
                                      sdoc_numb in varchar2 /*Номер договора*/) is
  
    /*Номер документа-основания*/
    sVALID_DOCNUMB pkg_std.tSTRING;
  
    /*Дата договора*/
    ddoc_date date;
  
  begin
    /* исправление записи в таблице */
    update CONTRACTS c
       set c.doc_pref = sdoc_pref || '/' || to_char(c.doc_date, 'yy'),
           c.doc_numb = sdoc_numb
     where c.RN = nRN
       and c.company = nCOMPANY
    returning c.doc_date into ddoc_date;
  
    if (SQL%NOTFOUND) then
      PKG_MSG.RECORD_NOT_FOUND(nRN, 'Contracts');
    end if;
  
    /*Номер документа-основания*/
    sVALID_DOCNUMB := pkg_document.MAKE_NUMBER(sDOC_PREF => sdoc_pref || '/' ||
                                                            to_char(ddoc_date,
                                                                    'yy'),
                                               sDOC_NUMB => sdoc_numb);
  
    /*Цикл по этапам договора*/
    for stg_cursor in (select s.faceacc as nfaceacc
                         from stages s
                        where s.prn = nrn
                          and s.company = ncompany) loop
      p_faceacc_upd_valid_docnumb(NCOMPANY       => NCOMPANY,
                                  nrn            => stg_cursor.nfaceacc,
                                  sVALID_DOCNUMB => sVALID_DOCNUMB);
    end loop;
  end p_contracts_upd_pref_numb;
  
begin
  -- Initialization
  null;
end udo_pkg_umts_02_cntr_fact;
/
