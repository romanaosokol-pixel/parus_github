create or replace package udo_pkg_umts_02_cntr is

  --create public synonym udo_pkg_umts_02_cntr for udo_pkg_umts_02_cntr;

  --grant execute on udo_pkg_umts_02_cntr to public;

  -- Author  : I.ANNENKO
  -- Created : 06.09.2022 18:50:06
  -- Purpose : Управление снабжением. 2. Контрактация

  -- Public type declarations
  --type <TypeName> is <Datatype>;

  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  /*Процедура выполняет базовое добавление строки заказа поставщику*/
  procedure P_DELIVERYORDS_BASE_INSERT(RSP in DELIVERYORDS%rowtype /*Атрибуты записи строки заказа поставщику*/,
                                       NRN out number /*Регистрационный номер записи*/);

  /*Функция возвращает признак аннулирования документа контрактации*/
  function F_BUYPLANESP_CNTR_DOC_CLC_SGNC(NCOMPANY in number /*Организация*/,
                                          NRN      in number /*Регистрационный номер записи*/)
    return number;

  /*Процедура выполняет расчет закрытого количества по строке плана закупок*/
  procedure P_BUYPLANESP_CNTR_DOC_CLC_QNT(NCOMPANY        in number /*Организация*/,
                                          NRN             in number /*Регистрационный номер записи*/,
                                          NRN_REF         in number /*Анненко И.С. 19.05.2022 Регистрационный номер записи ссылки на заказы*/,
                                          NQUANT_PLAN     out number /*Количество в ОЕИ по плану закупок*/,
                                          NQUANT_PLAN_ALT out number /*Количество в ДЕИ по плану закупок*/);

  /*Функция определяет номенклатуру*/
  function f_buyplanespref_calc_nomen(ncompany in number /*Организация*/,
                                      nrn      in number /*Регистрационный номер записи*/)
    return number;

  /*Процедура выполняет расчет общего количество из плана закупок по документу*/
  procedure P_DOCUMENT_CALC_QUANT_BP(NCOMPANY   in number /*Регистрационный номер организации*/,
                                     SUNITCODE  in varchar2 /*Код раздела*/,
                                     NRN        in number /*Регистрационный номер записи*/,
                                     NQUANT     out number /*Количество ОЕИ*/,
                                     NQUANT_ALT out number /*Количество ОЕИ*/);

  /*Процедура определяет исполненное количество по указанной строке документа контрактации*/
  procedure P_BUYPLANESP_CD_CLC_EXEC_QUANT(NRN              in number /*Регистрационный номер записи*/,
                                           NSIGN_PERIOD     in number /*Признак необходимости фильтрации по периоду*/,
                                           NQUANT           out number /*Количество в ОЕИ*/,
                                           NQUANT_ALT       out number /*Количество в ДЕИ*/,
                                           DDATE_EXEC_BEGIN out date /*Дата начала периода*/,
                                           DDATE_EXEC_END   out date /*Дата окончания периода*/);

  /*Процедура выполняет базовое включение указанной строки плана закупок в заказ поставщику*/
  procedure P_BUYPLANESP_BINCL_DELIVERYORD(NCOMPANY          in number /*Регистрационный номер организации*/,
                                           NRN_ORD           in number /*Регистрационный номер записи заказа поставщику*/,
                                           NTAX_GROUP        in number /*Налоговая группа*/,
                                           NRN               in number /*Регистрационный номер записи*/,
                                           NRN_REF           in number /*Регистрационный номер записи ссылки на заказ*/,
                                           NQUANT            in number /*Количество в ОЕИ*/,
                                           NQUANT_ALT        in number /*Количество в ДЕИ*/,
                                           nsign_upd_del_ord in number /*Признак необходимости исправления заказа поставщику*/);

  /*Процедура определяет атрибуты заказа поставщику по плану закупок*/
  procedure p_buyplanesp_calc_deliveryord(NCOMPANY in number /*Регистрационный номер организации*/,
                                          NIDENT   in number /*Идентификатор помеченных записей*/,
                                          SAGENT   out varchar2 /*Контрагент*/,
                                          sigk     out varchar2 /*ИГК*/,
                                          sobs     out varchar2 /*ОБС*/);

  /*Процедура выполняет формирование заказа поставщику по плану закупок*/
  procedure p_buyplanesp_crt_deliveryord(NCOMPANY  in number /*Регистрационный номер организации*/,
                                         sunitcode in varchar2 /*Код раздела*/,
                                         saction   in varchar2 /*Действие*/,
                                         stable    in varchar2 /*Таблица*/,
                                         NCRN      in number /*Каталог*/,
                                         NIDENT    in number /*Идентификатор помеченных записей*/,
                                         --SCATALOG      in varchar2 /*Каталог*/,
                                         SDOC_TYPE     in varchar2 /*Тип*/,
                                         SAGENT        in varchar2 /*Контрагент*/,
                                         SEXECUTIVE    in varchar2 /*Ответственный*/,
                                         SSUBDIVISION  in varchar2 /*Подразделение*/,
                                         DDATE         in date /*Дата*/,
                                         DRELEASE_DATE in date /*Дата поставки*/,
                                         STAX_GROUP    in varchar2 /*Налоговая группа*/,
                                         nSIGNTAX      in number /*Цены не включают налоги*/,
                                         sigk          in varchar2 /*ИГК*/,
                                         sobs          in varchar2 /*ОБС*/,
                                         saccept       in varchar2 /*Приемка*/,
                                         SNOTE         in varchar2 /*Примечание*/);

  /*Добавить привязку к заказу поставщику*/
  procedure P_BUYPLANESP_INCL_DELIVERYORD(NCOMPANY   in number /*Регистрационный номер организации*/,
                                          sunitcode  in varchar2 /*Код раздела*/,
                                          saction    in varchar2 /*Действие*/,
                                          stable     in varchar2 /*Таблица*/,
                                          NCRN       in number /*Каталог*/,
                                          NRN_ORD    in number /*Регистрационный номер записи заказа поставщику*/,
                                          STAX_GROUP in varchar2 /*Налоговая группа*/,
                                          NRN        in number /*Регистрационный номер записи*/,
                                          NQUANT     in number /*Количество в ОЕИ*/,
                                          NQUANT_ALT in number /*Количество в ДЕИ*/);

  /*Добавить привязку к заказу поставщику на все количество*/
  procedure P_BUYPLANESP_INCLA_DELIVERYORD(NCOMPANY   in number /*Регистрационный номер организации*/,
                                           sunitcode  in varchar2 /*Код раздела*/,
                                           saction    in varchar2 /*Действие*/,
                                           stable     in varchar2 /*Таблица*/,
                                           NCRN       in number /*Каталог*/,
                                           NRN_ORD    in number /*Регистрационный номер записи заказа поставщику*/,
                                           STAX_GROUP in varchar2 /*Налоговая группа*/,
                                           NRN        in number /*Регистрационный номер записи*/);

  /*Процедура определяет перечень заказов поставщику с поправкой на партионность*/
  procedure p_bpspref_calc_del_ord_lst_wou(NCOMPANY     in number /*Регистрационный номер организации*/,
                                           NRN          in number /*Регистрационный номер записи*/,
                                           sdel_ord_lst out varchar2 /*Перечень заказов поставщику*/);

  /*Процедура выполняет расчет количества для привязки к оформленному заказу поставщику*/
  procedure P_BUYPLANESP_calc_DEL_ORD_WO_U(NCOMPANY   in number /*Регистрационный номер организации*/,
                                           NRN_ORD    in number /*Регистрационный номер записи заказа поставщику*/,
                                           NRN        in number /*Регистрационный номер записи*/,
                                           NQUANT     out number /*Количество в ОЕИ*/,
                                           NQUANT_ALT out number /*Количество в ДЕИ*/);

  /*Добавить привязку к оформленному заказу поставщику*/
  procedure P_BUYPLANESP_INCL_DEL_ORD_WO_U(NCOMPANY   in number /*Регистрационный номер организации*/,
                                           NCRN       in number /*Каталог*/,
                                           NRN_ORD    in number /*Регистрационный номер записи заказа поставщику*/,
                                           NRN        in number /*Регистрационный номер записи*/,
                                           NQUANT     in number /*Количество в ОЕИ*/,
                                           NQUANT_ALT in number /*Количество в ДЕИ*/);

  /*Удалить привязку к оформленному заказу поставщику*/
  procedure P_BUYPLANESP_exCL_DEL_ORD_WO_U(NCOMPANY in number /*Регистрационный номер организации*/,
                                           NCRN     in number /*Каталог*/,
                                           NRN_ORD  in number /*Регистрационный номер записи заказа поставщику*/,
                                           NRN      in number /*Регистрационный номер записи*/);

  /*Добавить привязку к оформленному заказу поставщику*/
  procedure p_buyplanespref_INCL_DEL_ORD(NCOMPANY in number /*Регистрационный номер организации*/,
                                         NRN      in number /*Регистрационный номер записи*/);

  /*Процедура выполняет очистку документов закрытия плана закупок*/
  procedure P_BUYPLANESP_CNTR_DOC_CLEAR(SDOC_UNITCODE in varchar2 /*Код раздела документа*/,
                                        NDOC_RN       in number /*Регистрационный номер записи документа*/);

  /*Утверждение заказа поставщику*/
  procedure P_DELIVERYORD_CHECK_BP_QUANT(NCOMPANY in number /*Регистрационный номер организации*/,
                                         NRN      in number /*Регистрационный номер записи*/);

  /*Процедура определяет регистрационный номер записи строки счета на оплату для указанной строки заказа подразделений*/
  procedure p_departmentords_calc_acc_sp(ncompany in number /*Организация*/,
                                         nrn      in number /*Регистрационный номер записи*/,
                                         nrn_acc  out number /*Регистрационный номер записи строки счета на оплату*/);

  /*Процедура определяет перечень заказов поставщику для указанной строки заказа подразделений в плане закупок*/
  procedure p_buyplanespref_clc_delord_lst(ncompany          in number /*Организация*/,
                                           nident            in number /*Идентификатор помеченных записей*/,
                                           nident_delord_lst out number /*Идентификатор помеченных записей заказов поставщикам*/);

  /*Процедура выполняет переброску указанного количества законтрактовано по заказу*/
  procedure P_BUYPLANESPREF_MOVE_CNTR(NCOMPANY        in number /*Регистрационный номер организации*/,
                                      NRN_SRC         in number /*Регистрационный номер записи источника*/,
                                      NRN_DST         in number /*Регистрационный номер записи назначения*/,
                                      NPRN_DST        in number /*Регистрационный номер записи родителя назначения*/,
                                      NCRN_DST        in number /*Регистрационный номер записи каталога назначения*/,
                                      NBP_DST         in number /*Регистрационный номер записи плана закупок назначения*/,
                                      NQUANT_MOVE     in number /*Количество переброски в ОЕИ*/,
                                      NQUANT_ALT_MOVE in number /*Количество переброски в ДЕИ*/);

  /*Функция возвращает дату выпуска для указанного заказа подразделений*/
  function f_departmentord_calc_rel_date(nrn in number /*Регистрационный номер записи*/)
    return date;

  /*Процедура выполняет возврат разницы в план закупок*/
  procedure p_deliveryords_ret_diff_bp(ncompany in number /*Организация*/,
                                       nrn      in number /*Регистрационный номер записи*/);

  /*Процедура выполняет аннулирование позиции заказа поставщику*/
  procedure p_deliveryords_cancel(ncompany in number /*Организация*/,
                                  nrn      in number /*Регистрационный номер записи*/,
                                  ddate    in date /*Дата аннулирования*/);

  /*Процедура выполняет отмену аннулирования позиции заказа поставщику*/
  procedure p_deliveryords_cancel_cancel(ncompany in number /*Организация*/,
                                         nrn      in number /*Регистрационный номер записи*/);

end udo_pkg_umts_02_cntr;
/
create or replace package body udo_pkg_umts_02_cntr is

  -- Private type declarations
  --type <TypeName> is <Datatype>;

  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  /*Процедура выполняет установку атрибутов инициализации заказа поставщику*/
  procedure P_DELIVERYORD_INIT_ATTRS(RORD out DELIVERYORD%rowtype /*Атрибуты записи заказа поставщику*/) is
  begin
    /*Не утвержден*/
    RORD.ORD_STATE := 0;
    /*Дата смены состояния*/
    RORD.STATE_DATE := TRUNC(sysdate);
    /*Периодический заказ*/
    RORD.ORD_PERIOD := 0;
    /*Учет календаря*/
    RORD.USECALENDAR := 0;
    /*Коррекция для периодов*/
    RORD.PERIOD_CORR := 1;
    /*Количество периодов*/
    RORD.PERIOD_QUANT := 1;
    /*Тип периода*/
    RORD.PERIOD_TYPE := 0;
    /*Длина периода*/
    RORD.PERIOD_LEN := 1;
    /*Одновременное исполнение*/
    RORD.ATSAMETIME := 1;
    RORD.REDUCTION  := 0;
    /*Цены не включают налоги*/
    RORD.INCLUDETAX := 0;
  end P_DELIVERYORD_INIT_ATTRS;

  /*Процедура выполняет базовое добавление заказа поставщику*/
  procedure P_DELIVERYORD_BASE_INSERT(RORD in DELIVERYORD%rowtype /*Атрибуты записи заказа поставщику*/,
                                      NRN  out number /*Регистрационный номер записи*/) is
    NSRN PKG_STD.TREF;
  begin
    PARUS.P_DELIVERYORD_BASE_INSERT(NCOMPANY      => RORD.COMPANY,
                                    NCRN          => RORD.CRN,
                                    SORD_PREF     => RORD.ORD_PREF,
                                    SORD_NUMB     => RORD.ORD_NUMB,
                                    NAGENT        => RORD.AGENT,
                                    NFACEACC      => RORD.FACEACC,
                                    NGRAPHPOINT   => RORD.GRAPHPOINT,
                                    NORD_DOCTYPE  => RORD.ORD_DOCTYPE,
                                    DORD_DATE     => RORD.ORD_DATE,
                                    NORD_STATE    => RORD.ORD_STATE,
                                    DSTATE_DATE   => RORD.STATE_DATE,
                                    NDISP_TYPE    => RORD.DISP_TYPE,
                                    NPAY_TYPE     => RORD.PAY_TYPE,
                                    NDELIV_DIAGR  => RORD.DELIV_DIAGR,
                                    NCURRENCY     => RORD.CURRENCY,
                                    NSTORE        => RORD.STORE,
                                    NACC_AGENT    => RORD.ACC_AGENT,
                                    NSUBDIV       => RORD.SUBDIV,
                                    DPAY_DATE     => RORD.PAY_DATE,
                                    DRELEASE_DATE => RORD.RELEASE_DATE,
                                    NORD_PERIOD   => RORD.ORD_PERIOD,
                                    NUSECALENDAR  => RORD.USECALENDAR,
                                    NPERIOD_CORR  => RORD.PERIOD_CORR,
                                    NPERIOD_QUANT => RORD.PERIOD_QUANT,
                                    NPERIOD_TYPE  => RORD.PERIOD_TYPE,
                                    NPERIOD_LEN   => RORD.PERIOD_LEN,
                                    NATSAMETIME   => RORD.ATSAMETIME,
                                    NINCLUDETAX   => RORD.INCLUDETAX,
                                    NREDUCTION    => RORD.REDUCTION,
                                    SNOTE         => RORD.NOTE,
                                    NJUR_PERS     => RORD.JUR_PERS,
                                    SDELIVDOCNUMB => RORD.DELIVDOCNUMB,
                                    DDELIVDOCDATE => RORD.DELIVDOCDATE,
                                    SBARCODE      => RORD.BARCODE,
                                    NRN           => NRN);
    P_DELIVERYORDP_BASE_INSERT(NCOMPANY       => RORD.COMPANY,
                               NPRN           => NRN,
                               NPERF_NUMB     => 1,
                               DPERF_DATE     => RORD.RELEASE_DATE,
                               NPSUMWTAX      => 0,
                               NPSUMWOTAX     => 0,
                               NPERF_PLAN_SUM => 0,
                               NPERF_FACT_SUM => 0,
                               NPAY_PLAN_SUM  => 0,
                               NPAY_FACT_SUM  => 0,
                               NACC_QUANT     => 0,
                               NACC_SUM       => 0,
                               NRN            => NSRN);
  end P_DELIVERYORD_BASE_INSERT;

  /*Процедура выполняет базовое добавление строки заказа поставщику*/
  procedure P_DELIVERYORDS_BASE_INSERT(RSP in DELIVERYORDS%rowtype /*Атрибуты записи строки заказа поставщику*/,
                                       NRN out number /*Регистрационный номер записи*/) is
    DACTPF_DATE date;
  begin
    begin
      select O.RELEASE_DATE
        into DACTPF_DATE
        from DELIVERYORD O
       where O.RN = RSP.PRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RSP.PRN,
                                 SUNIT_TABLE => 'DeliveryOrders');
    end;
    PARUS.P_DELIVERYORDS_BASE_INSERT(NCOMPANY     => RSP.COMPANY,
                                     NPRN         => RSP.PRN,
                                     NNOMEN       => RSP.NOMEN,
                                     NNOM_PACK    => RSP.NOM_PACK,
                                     NNOM_MODIF   => RSP.NOM_MODIF,
                                     NNOMMOD_PACK => RSP.NOMMOD_PACK,
                                     NPRODUCT     => RSP.PRODUCT,
                                     NTAX_GROUP   => RSP.TAX_GROUP,
                                     NEXP_PRICE   => RSP.EXP_PRICE,
                                     NPR_MEAS     => RSP.PR_MEAS,
                                     NSTORE       => RSP.STORE,
                                     NPOSREDUCT   => RSP.POSREDUCT,
                                     SNOTE        => RSP.NOTE,
                                     NMDMNOMEN    => RSP.MDMNOMEN,
                                     NDUP_RN      => TO_NUMBER(null),
                                     DACTPF_DATE  => DACTPF_DATE,
                                     NACTM_QUANT  => RSP.MAIN_QUANT,
                                     NACTA_QUANT  => RSP.ALT_QUANT,
                                     NACTSWTAX    => RSP.SUMWTAX,
                                     NACTSWOTAX   => RSP.SUMWOTAX,
                                     NIGNOREPERF  => 0,
                                     NRN          => NRN);
  end P_DELIVERYORDS_BASE_INSERT;

  /*Процедура выполняет базовое исправление строки заказа поставщику*/
  procedure P_DELIVERYORDS_BASE_UPDATE(RSP in DELIVERYORDS%rowtype /*Атрибуты записи строки заказа поставщику*/) is
    RPERF DELIVERYORDPS%rowtype;
  begin
    begin
      select P.* into RPERF from DELIVERYORDPS P where P.PRN = RSP.RN;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0,
                    'Не удалось определить исполнение');
      when TOO_MANY_ROWS then
        P_EXCEPTION(0,
                    'Не удалось однозначно определить исполнение');
    end;
    PKG_FLAG.SET_FLAG; -- 09/08/2023 Марков МВ. для исключения контроля в ЗП
    PARUS.P_DELIVERYORDS_BASE_UPDATE(NCOMPANY       => RSP.COMPANY,
                                     NRN            => RSP.RN,
                                     NNOMEN         => RSP.NOMEN,
                                     NNOM_PACK      => RSP.NOM_PACK,
                                     NNOM_MODIF     => RSP.NOM_MODIF,
                                     NNOMMOD_PACK   => RSP.NOMMOD_PACK,
                                     NPRODUCT       => RSP.PRODUCT,
                                     NTAX_GROUP     => RSP.TAX_GROUP,
                                     NEXP_PRICE     => RSP.EXP_PRICE,
                                     NPR_MEAS       => RSP.PR_MEAS,
                                     NSTORE         => RSP.STORE,
                                     NPOSREDUCT     => RSP.POSREDUCT,
                                     SNOTE          => RSP.NOTE,
                                     NMDMNOMEN      => RSP.MDMNOMEN,
                                     NPERFS_STATE   => 0,
                                     DCS_DATE       => RPERF.CS_DATE,
                                     DACTPF_DATE    => RPERF.ACTPF_DATE,
                                     DCUST_DATE     => RPERF.CUST_DATE,
                                     DEXEC_DATE     => RPERF.EXEC_DATE,
                                     NACTM_QUANT    => RSP.MAIN_QUANT,
                                     NACTA_QUANT    => RSP.ALT_QUANT,
                                     NCUSTM_QUANT   => RPERF.CUSTM_QUANT,
                                     NCUSTA_QUANT   => RPERF.CUSTA_QUANT,
                                     NEXECM_QUANT   => RPERF.EXECM_QUANT,
                                     NEXECA_QUANT   => RPERF.EXECA_QUANT,
                                     NACTSWTAX      => RSP.SUMWTAX,
                                     NACTSWOTAX     => RSP.SUMWOTAX,
                                     NCUSTSWTAX     => RPERF.CUSTSWTAX,
                                     NCUSTSWOTAX    => RPERF.CUSTSWOTAX,
                                     NEXECSWTAX     => RPERF.EXECSWTAX,
                                     NEXECSWOTAX    => RPERF.EXECSWOTAX,
                                     NFLAG_DEL_CALC => 0);
    PKG_FLAG.RESET_FLAG;
  end P_DELIVERYORDS_BASE_UPDATE;

  /*Функция определяет номенклатуру*/
  function f_buyplanespref_calc_nomen(ncompany in number /*Организация*/,
                                      nrn      in number /*Регистрационный номер записи*/)
    return number is
  
    nnomen pkg_std.tREF;
  
  begin
    begin
      select s.nomen
        into nnomen
        from buyplanespref r, departmentords s
       where r.rn = nrn
         and r.company = ncompany
         and s.rn = r.deptordsp;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;
  
    return(nnomen);
  end f_buyplanespref_calc_nomen;

  /*Функция возвращает признак аннулирования документа контрактации*/
  function F_BUYPLANESP_CNTR_DOC_CLC_SGNC(NCOMPANY in number /*Организация*/,
                                          NRN      in number /*Регистрационный номер записи*/)
    return number is
    /*Атрибуты записи*/
    RCNTR_DOC UDO_UZD_03_BUYPLANESP_CNTR_DOC%rowtype;
  begin
    /*Атрибуты записи*/
    begin
      select T.*
        into RCNTR_DOC
        from UDO_UZD_03_BUYPLANESP_CNTR_DOC T
       where T.RN = NRN
         and T.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecsCntrDoc');
    end;
    /*Анненко И.С. 29.07.2023*/
    if (prsg_prop.DGET(nCOMPANY  => NCOMPANY,
                       nVERSION  => to_number(null),
                       sUNITCODE => RCNTR_DOC.DOC_UNITCODE,
                       nDOCUMENT => RCNTR_DOC.DOC_RN,
                       sPROPCODE => 'УМТС_ДатаАннулирован') is not null) then
      return(1);
    else
      return(0);
    end if;
    return(0);
  end F_BUYPLANESP_CNTR_DOC_CLC_SGNC;

  /*Процедура выполняет расчет закрытого количества по строке плана закупок*/
  procedure P_BUYPLANESP_CNTR_DOC_CLC_QNT(NCOMPANY        in number /*Организация*/,
                                          NRN             in number /*Регистрационный номер записи*/,
                                          NRN_REF         in number /*Анненко И.С. 19.05.2022 Регистрационный номер записи ссылки на заказы*/,
                                          NQUANT_PLAN     out number /*Количество в ОЕИ по плану закупок*/,
                                          NQUANT_PLAN_ALT out number /*Количество в ДЕИ по плану закупок*/) is
  begin
    select nvl(sum(T.QUANT_PLAN), 0), nvl(sum(T.QUANT_PLAN_ALT), 0)
      into NQUANT_PLAN, NQUANT_PLAN_ALT
      from UDO_UZD_03_BUYPLANESP_CNTR_DOC T
     where T.PRN = NRN
       and T.COMPANY = NCOMPANY
       and (NRN_REF is null or T.RN_REF = NRN_REF) /*Анненко И.С. 19.05.2022*/
          --and T.PART is null
          /*Анненко И.С. 18.07.2022*/
       and F_BUYPLANESP_CNTR_DOC_CLC_SGNC(NCOMPANY => T.COMPANY,
                                          NRN      => T.RN) = 0;
  end P_BUYPLANESP_CNTR_DOC_CLC_QNT;

  /*Процедура выполняет базовое добавление документа закрытия плана закупок*/
  procedure P_BUYPLANESP_CNTR_DOC_BINSERT(NCOMPANY            in number /*Организация*/,
                                          NCRN                in number /*Регистрационный номер каталога*/,
                                          NPRN                in number /*Регистрационный номер родителя*/,
                                          NQUANT_PLAN         in number /*Количество в ОЕИ по плану закупок*/,
                                          NQUANT_PLAN_ALT     in number /*Количество в ДЕИ по плану закупок*/,
                                          SDOC_UNITCODE       in varchar2 /*Код раздела документа*/,
                                          NDOC_RN             in number /*Регистрационный номер записи документа*/,
                                          NDOC_QUANT_PLAN     in number /*Количество в ОЕИ по документу*/,
                                          NDOC_QUANT_PLAN_ALT in number /*Количество в ДЕИ по документу*/,
                                          NRN_REF             in number /*Регистрационный номер записи ссылки на заказ*/,
                                          nsign_check         in number /*Признак необходимости проверки*/, /*Анненко И.С. 18.03.2023*/
                                          NRN                 out number /*Регистрационный номер записи*/) is
    /*Атрибуты записи строки плана закупок*/
    RSP BUYPLANESP%rowtype;
    /*Юридическое лицо*/
    SJUR_PERS PKG_STD.TSTRING;
    NJUR_PERS PKG_STD.TREF;
    /*Количество в ОЕИ по плану закупок*/
    NQUANT_PLAN_OLD number;
    /*Количество в ДЕИ по плану закупок*/
    NQUANT_PLAN_ALT_OLD number;
    --
    sNOMEN DICNOMNS.NOMEN_CODE%type;
    sTMP   varchar2(2000);
    /*Атрибуты записи*/
    rref buyplanespref%rowtype;
  begin
    /*Атрибуты записи строки плана закупок*/
    begin
      select S.*
        into RSP
        from BUYPLANESP S
       where S.RN = NPRN
         and S.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NPRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecs');
    end;
    /*Выполняем расчет закрытого количества по строке плана закупок*/
    P_BUYPLANESP_CNTR_DOC_CLC_QNT(NCOMPANY        => NCOMPANY,
                                  NRN             => NPRN,
                                  NRN_REF         => NRN_REF /*Анненко И.С. 22.12.2022 TO_NUMBER(null)*/,
                                  NQUANT_PLAN     => NQUANT_PLAN_OLD,
                                  NQUANT_PLAN_ALT => NQUANT_PLAN_ALT_OLD);
  
    /*Анненко И.С. 22.12.2022*/
    if (NRN_REF is null) then
      /*Выполняем проверку превышения количества по плану в ОЕИ*/
      if (NQUANT_PLAN_OLD + NQUANT_PLAN > RSP.QUANT_PLAN) --and user <> 'PARUS'
       then
        sNOMEN := get_dicnomns_code_id(nFLAG_SMART => 0, nRN => RSP.NOMEN);
      
        /*Анненко И.С. 18.03.2023*/
        if (nsign_check = 1) then
          P_EXCEPTION(0,
                      'Превышено количество по плану в ОЕИ %s + %s > %s' ||
                      chr(10) || 'Строка плана закупок RN: %s' || chr(10) ||
                      'Номенклатура: %s',
                      NQUANT_PLAN_OLD,
                      NQUANT_PLAN,
                      RSP.QUANT_PLAN,
                      NPRN,
                      sNOMEN);
        end if;
      end if;
      /*Выполняем проверку превышения количества по плану в ДЕИ*/
      if (NQUANT_PLAN_ALT_OLD + NQUANT_PLAN_ALT > RSP.QUANTALT_PLAN) then
        P_EXCEPTION(0,
                    'Превышено количество по плану в ДЕИ');
      end if;
    else
      /*Атрибуты записи*/
      begin
        select r.*
          into rref
          from buyplanespref r
         where r.rn = NRN_REF
           and r.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => NRN_REF,
                                   sUNIT_TABLE => 'BuyPlaneSpecsReferences');
      end;
    
      /*Выполняем проверку превышения количества по плану в ОЕИ*/
      if (NQUANT_PLAN_OLD + NQUANT_PLAN > rref.QUANT_PLAN) --and utilizer not in ('PARUS', 'KHOK')
       then
        sNOMEN := get_dicnomns_code_id(nFLAG_SMART => 0, nRN => RSP.NOMEN);
      
        /*Анненко И.С. 18.03.2023*/
        if (nsign_check = 1) then
          P_EXCEPTION(0,
                      'Превышено количество по плану в ОЕИ %s + %s > %s' ||
                      chr(10) || 'Строка плана закупок RN: %s' || chr(10) ||
                      'Номенклатура: %s',
                      NQUANT_PLAN_OLD,
                      NQUANT_PLAN,
                      rref.QUANT_PLAN,
                      NPRN,
                      sNOMEN);
        end if;
      end if;
      /*Выполняем проверку превышения количества по плану в ДЕИ*/
      if (NQUANT_PLAN_ALT_OLD + NQUANT_PLAN_ALT > rref.QUANTALT_PLAN) then
        P_EXCEPTION(0,
                    'Превышено количество по плану в ДЕИ');
      end if;
    end if;
  
    /*Юридическое лицо*/
    FIND_JURPERSONS_MAIN(NFLAG_SMART => 0,
                         NCOMPANY    => NCOMPANY,
                         SJUR_PERS   => SJUR_PERS,
                         NJUR_PERS   => NJUR_PERS);
    /*Регистрационный номер записи*/
    NRN := GEN_ID;
    /*Выполняем добавление записи в таблицу*/
    insert into UDO_UZD_03_BUYPLANESP_CNTR_DOC
      (RN,
       COMPANY,
       CRN,
       JUR_PERS,
       PRN,
       QUANT_PLAN,
       QUANT_PLAN_ALT,
       DOC_UNITCODE,
       DOC_RN,
       DOC_QUANT_PLAN,
       DOC_QUANT_PLAN_ALT,
       RN_REF)
    values
      (NRN,
       NCOMPANY,
       NCRN,
       NJUR_PERS,
       NPRN,
       NQUANT_PLAN,
       NQUANT_PLAN_ALT,
       SDOC_UNITCODE,
       NDOC_RN,
       NDOC_QUANT_PLAN,
       NDOC_QUANT_PLAN_ALT,
       NRN_REF);
  end P_BUYPLANESP_CNTR_DOC_BINSERT;

  /*Процедура выполняет базовое исправление документа закрытия плана закупок*/
  procedure P_BUYPLANESP_CNTR_DOC_BUPDATE(NCOMPANY            in number /*Организация*/,
                                          NRN                 in number /*Регистрационный номер записи*/,
                                          NQUANT_PLAN         in number /*Количество в ОЕИ по плану закупок*/,
                                          NQUANT_PLAN_ALT     in number /*Количество в ДЕИ по плану закупок*/,
                                          SDOC_UNITCODE       in varchar2 /*Код раздела документа*/,
                                          NDOC_RN             in number /*Регистрационный номер записи документа*/,
                                          NDOC_QUANT_PLAN     in number /*Количество в ОЕИ по документу*/,
                                          NDOC_QUANT_PLAN_ALT in number /*Количество в ДЕИ по документу*/) is
  begin
    /*Анненко И.С. 18.07.2022*/
    if (F_BUYPLANESP_CNTR_DOC_CLC_SGNC(NCOMPANY => NCOMPANY, NRN => NRN) = 1) then
      P_EXCEPTION(0,
                  'Документ контрактации аннулирован');
    end if;
    /*Выполняем исправление записи в таблице*/
    update UDO_UZD_03_BUYPLANESP_CNTR_DOC T
       set T.QUANT_PLAN         = NQUANT_PLAN,
           T.QUANT_PLAN_ALT     = NQUANT_PLAN_ALT,
           T.DOC_UNITCODE       = SDOC_UNITCODE,
           T.DOC_RN             = NDOC_RN,
           T.DOC_QUANT_PLAN     = NDOC_QUANT_PLAN,
           T.DOC_QUANT_PLAN_ALT = NDOC_QUANT_PLAN_ALT
     where T.RN = NRN
       and T.COMPANY = NCOMPANY;
    /*Выполняем проверку исправления записи в таблице*/
    if (sql%notfound) then
      PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                               SUNIT_TABLE => 'BuyPlaneSpecsCntrDoc');
    end if;
  end P_BUYPLANESP_CNTR_DOC_BUPDATE;

  /*Процедура выполняет базовое удаление документа закрытия плана закупок*/
  procedure P_BUYPLANESP_CNTR_DOC_BDELETE(NCOMPANY in number /*Организация*/,
                                          NRN      in number /*Регистрационный номер записи*/) is
  begin
    /*Анненко И.С. 18.07.2022*/
    if (F_BUYPLANESP_CNTR_DOC_CLC_SGNC(NCOMPANY => NCOMPANY, NRN => NRN) = 1) /*and utilizer != 'KHOK'*/ then
      P_EXCEPTION(0, 'Документ контрактации аннулирован');
    end if;
    /*Выполняем удаление записи в таблице*/
    delete UDO_UZD_03_BUYPLANESP_CNTR_DOC T
     where T.RN = NRN
       and T.COMPANY = NCOMPANY;
    /*Выполняем проверку удаления записи в таблице*/
    if (sql%notfound) then
      PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                               SUNIT_TABLE => 'BuyPlaneSpecsCntrDoc');
    end if;
  end P_BUYPLANESP_CNTR_DOC_BDELETE;

  /*Процедура выполняет очистку документов закрытия плана закупок*/
  procedure P_BUYPLANESP_CNTR_DOC_CLEAR(SDOC_UNITCODE in varchar2 /*Код раздела документа*/,
                                        NDOC_RN       in number /*Регистрационный номер записи документа*/) is
  begin
    for DOC_CURSOR in (select D.COMPANY as NCOMPANY, D.RN as NRN
                         from UDO_UZD_03_BUYPLANESP_CNTR_DOC D
                        where D.DOC_RN = NDOC_RN
                          and D.DOC_UNITCODE = SDOC_UNITCODE) loop
      P_BUYPLANESP_CNTR_DOC_BDELETE(NCOMPANY => DOC_CURSOR.NCOMPANY,
                                    NRN      => DOC_CURSOR.NRN);
    end loop;
  end P_BUYPLANESP_CNTR_DOC_CLEAR;

  /*Процедура выполняет расчет общего количество из плана закупок по документу*/
  procedure P_DOCUMENT_CALC_QUANT_BP(NCOMPANY   in number /*Регистрационный номер организации*/,
                                     SUNITCODE  in varchar2 /*Код раздела*/,
                                     NRN        in number /*Регистрационный номер записи*/,
                                     NQUANT     out number /*Количество ОЕИ*/,
                                     NQUANT_ALT out number /*Количество ОЕИ*/) is
  begin
    select NVL(sum(D.DOC_QUANT_PLAN), 0), NVL(sum(D.DOC_QUANT_PLAN_ALT), 0)
      into NQUANT, NQUANT_ALT
      from UDO_UZD_03_BUYPLANESP_CNTR_DOC D
     where D.DOC_RN = NRN
       and D.DOC_UNITCODE = SUNITCODE
       and D.COMPANY = NCOMPANY;
  end P_DOCUMENT_CALC_QUANT_BP;

  /*Процедура определяет период поставки для указанной строки плана закупок*/
  procedure P_BUYPLANESP_CALC_PERIOD(NRN         in number /*Регистрационный номер записи*/,
                                     DDATE_BEGIN out date /*Дата начала периода*/,
                                     DDATE_END   out date /*Дата окончания периода*/) is
    /*Атрибуты записи строки плана закупок*/
    RSP BUYPLANESP%rowtype;
    /*Атрибуты записи плана закупок*/
    Rbp BUYPLANE%rowtype;
    /*Дискретность плана закупок*/
    SPERIOD_TYPE PKG_STD.TSTRING;
  begin
    /*Атрибуты записи строки плана закупок*/
    begin
      select S.* into RSP from BUYPLANESP S where S.RN = NRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecs');
    end;
    /*Атрибуты записи плана закупок*/
    begin
      select bp.* into rbp from BUYPLANE bp where bp.RN = rsp.prn;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => rsp.prn,
                                 SUNIT_TABLE => 'BuyPlanes');
    end;
    /*Дискретность плана закупок*/
    SPERIOD_TYPE := prsg_prop.SGET(nCOMPANY  => rbp.company,
                                   nVERSION  => to_number(null),
                                   sUNITCODE => 'DOCTYPES',
                                   nDOCUMENT => rbp.doctype,
                                   sPROPCODE => 'УМТС_Дискретность');
    if (CMP_VC2(SPERIOD_TYPE, 'Месяц') = 1) then
      DDATE_BEGIN := TRUNC(RSP.SHIPMENT_PLAN, 'month');
      DDATE_END   := ADD_MONTHS(DDATE_BEGIN, 1) - 1;
    elsif (CMP_VC2(SPERIOD_TYPE, 'Квартал') = 1) then
      DDATE_BEGIN := TRUNC(RSP.SHIPMENT_PLAN, 'q');
      DDATE_END   := ADD_MONTHS(DDATE_BEGIN, 3) - 1;
    elsif (CMP_VC2(SPERIOD_TYPE, 'Год') = 1) then
      DDATE_BEGIN := TRUNC(RSP.SHIPMENT_PLAN, 'year');
      DDATE_END   := ADD_MONTHS(DDATE_BEGIN, 12) - 1;
    else
      P_EXCEPTION(0,
                  'Не удалось определить дискретность плана закупок');
    end if;
  end P_BUYPLANESP_CALC_PERIOD;

  /*Процедура определяет исполненное количество по указанной строке документа контрактации*/
  procedure P_BUYPLANESP_CD_CLC_EXEC_QUANT(NRN              in number /*Регистрационный номер записи*/,
                                           NSIGN_PERIOD     in number /*Признак необходимости фильтрации по периоду*/,
                                           NQUANT           out number /*Количество в ОЕИ*/,
                                           NQUANT_ALT       out number /*Количество в ДЕИ*/,
                                           DDATE_EXEC_BEGIN out date /*Дата начала периода*/,
                                           DDATE_EXEC_END   out date /*Дата окончания периода*/) is
    /*Атрибуты записи документа контрактации*/
    RDOC UDO_UZD_03_BUYPLANESP_CNTR_DOC%rowtype;
    /*Атрибуты записи строки плана закупок*/
    RSP BUYPLANESP%rowtype;
    /*Дата начала периода*/
    DDATE_BEGIN date;
    /*Дата окончания периода*/
    DDATE_END date;
  begin
    /*Атрибуты записи документа контрактации*/
    begin
      select D.*
        into RDOC
        from UDO_UZD_03_BUYPLANESP_CNTR_DOC D
       where D.RN = NRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecsCntrDoc');
    end;
    /*Атрибуты записи строки плана закупок*/
    begin
      select S.* into RSP from BUYPLANESP S where S.RN = RDOC.PRN;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RDOC.PRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecs');
    end;
    /*Определяем период поставки для указанной строки плана закупок*/
    P_BUYPLANESP_CALC_PERIOD(NRN         => RSP.RN,
                             DDATE_BEGIN => DDATE_BEGIN,
                             DDATE_END   => DDATE_END);
    /*1. Заказы поставщикам*/
    if (RDOC.DOC_UNITCODE = 'DeliveryOrdersSpec') then
      select NVL(sum(T.NQUANT), 0),
             NVL(sum(T.NQUANT_ALT), 0),
             min(T.WORK_DATE),
             max(T.WORK_DATE)
        into NQUANT, NQUANT_ALT, DDATE_EXEC_BEGIN, DDATE_EXEC_END
        from (
              --
              /*Рамочный договор*/
              select (case
                        when (RDOC.DOC_QUANT_PLAN = 0) then
                         (0)
                        else
                         (S.QUANT / RDOC.DOC_QUANT_PLAN * RDOC.QUANT_PLAN)
                      end) as NQUANT,
                      (case
                        when (RDOC.DOC_QUANT_PLAN_ALT = 0) then
                         (0)
                        else
                         (S.QUANTALT / RDOC.DOC_QUANT_PLAN_ALT *
                         RDOC.QUANT_PLAN_ALT)
                      end) as NQUANT_ALT,
                      I.WORK_DATE
                from DELIVERYORDS    DELOS,
                      DELIVERYORD     DELO,
                      ININVOICES      I,
                      ININVOICESSPECS S
               where DELOS.RN = RDOC.DOC_RN
                 and DELO.RN = DELOS.PRN
                 and I.FACEACC = DELO.FACEACC
                 and ((NSIGN_PERIOD = 0) or
                     (I.WORK_DATE between DDATE_BEGIN and DDATE_END))
                 and I.STATUS = 2
                 and S.PRN = I.RN
                 and S.MODIF = DELOS.NOM_MODIF
                    /*Анненко И.С. 01.11.2021*/
                 and exists (select 1
                        from DOCLINKS L
                       where L.IN_DOCUMENT = DELO.RN
                         and L.IN_UNITCODE = 'DeliveryOrders'
                         and L.OUT_UNITCODE = 'IncomingInvoices'
                         and L.OUT_DOCUMENT = I.RN)
              --
              union all
              --
              /*Генеральное соглашение*/
              select (case
                        when (RDOC.DOC_QUANT_PLAN = 0) then
                         (0)
                        else
                         (S.QUANT / RDOC.DOC_QUANT_PLAN * RDOC.QUANT_PLAN)
                      end) as NQUANT,
                      (case
                        when (RDOC.DOC_QUANT_PLAN_ALT = 0) then
                         (0)
                        else
                         (S.QUANTALT / RDOC.DOC_QUANT_PLAN_ALT *
                         RDOC.QUANT_PLAN_ALT)
                      end) as NQUANTALT,
                      I.WORK_DATE
                from DELIVERYORDS    DELOS,
                      DOCLINKS        L,
                      STAGES          STG,
                      FCACOPERPLANS   P,
                      ININVOICES      I,
                      ININVOICESSPECS S
               where 1 = 0
                 and DELOS.RN = RDOC.DOC_RN
                 and L.IN_DOCUMENT = DELOS.PRN
                 and STG.PRN = L.OUT_DOCUMENT
                 and P.PRN = STG.FACEACC
                 and P.NOMMODIF = DELOS.NOM_MODIF
                 and I.FACEACC = P.PRN
                 and ((NSIGN_PERIOD = 0) or
                     (I.WORK_DATE between DDATE_BEGIN and DDATE_END))
                 and I.STATUS = 2
                 and S.PRN = I.RN
                 and S.MODIF = P.NOMMODIF
              --
              ) T;
      /*Ошибка*/
    else
      P_EXCEPTION(0,
                  'Не удалось определить алгоритм расчета исполненного количества для раздела ' ||
                  RDOC.DOC_UNITCODE);
    end if;
  end P_BUYPLANESP_CD_CLC_EXEC_QUANT;

  /*УЗД03.04.01.01*/
  /*Процедура определяет исполненное количество по указанной строке плана закупок*/
  procedure P_BUYPLANESP_CALC_EXEC_QUANT(NRN        in number /*Регистрационный номер записи*/,
                                         NQUANT     out number /*Количество в ОЕИ*/,
                                         NQUANT_ALT out number /*Количество в ДЕИ*/) is
    /*Дата начала периода*/
    DDATE_EXEC_BEGIN date;
    /*Дата окончания периода*/
    DDATE_EXEC_END date;
  begin
    /*Количество в ОЕИ*/
    NQUANT := 0;
    /*Количество в ДЕИ*/
    NQUANT_ALT := 0;
    /*Цикл по документам контрактации*/
    for CD_CURSOR in (select CD.RN as NRN,
                             TO_NUMBER(null) as NQUANT,
                             TO_NUMBER(null) as NQUANT_ALT
                        from UDO_UZD_03_BUYPLANESP_CNTR_DOC CD
                       where CD.PRN = NRN) loop
      /*Выполняем расчет количества исполнено по документу контрактации*/
      P_BUYPLANESP_CD_CLC_EXEC_QUANT(NRN              => CD_CURSOR.NRN,
                                     NSIGN_PERIOD     => 1,
                                     NQUANT           => CD_CURSOR.NQUANT,
                                     NQUANT_ALT       => CD_CURSOR.NQUANT_ALT,
                                     DDATE_EXEC_BEGIN => DDATE_EXEC_BEGIN,
                                     DDATE_EXEC_END   => DDATE_EXEC_END);
      /*Количество в ОЕИ*/
      NQUANT := NQUANT + CD_CURSOR.NQUANT;
      /*Количество в ДЕИ*/
      NQUANT_ALT := NQUANT_ALT + CD_CURSOR.NQUANT_ALT;
    end loop;
  end P_BUYPLANESP_CALC_EXEC_QUANT;

  /*Процедура определяет период исполнения по указанной строке плана закупок*/
  procedure P_BUYPLANESP_CALC_EXEC_PERIOD(NRN              in number /*Регистрационный номер записи*/,
                                          DDATE_EXEC_BEGIN out date /*Дата начала периода*/,
                                          DDATE_EXEC_END   out date /*Дата окончания периода*/) is
    /*Дата начала периода*/
    DDATE_EXEC_BEGIN_D date;
    /*Дата окончания периода*/
    DDATE_EXEC_END_D date;
  begin
    /*Цикл по документам контрактации*/
    for CD_CURSOR in (select CD.RN as NRN,
                             TO_NUMBER(null) as NQUANT,
                             TO_NUMBER(null) as NQUANT_ALT
                        from UDO_UZD_03_BUYPLANESP_CNTR_DOC CD
                       where CD.PRN = NRN) loop
      /*Выполняем расчет количества исполнено по документу контрактации*/
      P_BUYPLANESP_CD_CLC_EXEC_QUANT(NRN              => CD_CURSOR.NRN,
                                     NSIGN_PERIOD     => 0,
                                     NQUANT           => CD_CURSOR.NQUANT,
                                     NQUANT_ALT       => CD_CURSOR.NQUANT_ALT,
                                     DDATE_EXEC_BEGIN => DDATE_EXEC_BEGIN_D,
                                     DDATE_EXEC_END   => DDATE_EXEC_END_D);
      /*Дата начала периода*/
      if (DDATE_EXEC_BEGIN is null) then
        DDATE_EXEC_BEGIN := DDATE_EXEC_BEGIN_D;
      else
        if (DDATE_EXEC_BEGIN_D < DDATE_EXEC_BEGIN) then
          DDATE_EXEC_BEGIN := DDATE_EXEC_BEGIN_D;
        end if;
      end if;
      /*Дата окончания периода*/
      if (DDATE_EXEC_END is null) then
        DDATE_EXEC_END := DDATE_EXEC_END_D;
      else
        if (DDATE_EXEC_END_D > DDATE_EXEC_END) then
          DDATE_EXEC_END := DDATE_EXEC_END_D;
        end if;
      end if;
    end loop;
  end P_BUYPLANESP_CALC_EXEC_PERIOD;

  /*Процедура выполняет базовое включение указанной строки плана закупок в заказ поставщику*/
  procedure P_BUYPLANESP_BINCL_DELIVERYORD(NCOMPANY          in number /*Регистрационный номер организации*/,
                                           NRN_ORD           in number /*Регистрационный номер записи заказа поставщику*/,
                                           NTAX_GROUP        in number /*Налоговая группа*/,
                                           NRN               in number /*Регистрационный номер записи*/,
                                           NRN_REF           in number /*Регистрационный номер записи ссылки на заказ*/,
                                           NQUANT            in number /*Количество в ОЕИ*/,
                                           NQUANT_ALT        in number /*Количество в ДЕИ*/,
                                           nsign_upd_del_ord in number /*Признак необходимости исправления заказа поставщику*/) is
    /*Атрибуты записи строки плана закупок*/
    RSP BUYPLANESP%rowtype;
    /*Состояние плана закупок*/
    NSTATE number;
    /*Атрибуты записи строки заказа поставщику*/
    RORD_SP DELIVERYORDS%rowtype;
    /*Регистрационный номер записи документа закрытия*/
    NRN_CNTR_DOC PKG_STD.TREF;
    /*Количество связей*/
    NCOUNT_LINKS number;
    /*Цены включают налоги*/
    NPRICEWITHTAX number;
    /*Состояние*/
    NORD_STATE number;
    /*Количество в плане закупок*/
    NQUANT_BP     pkg_std.tQUANT;
    NQUANT_BP_ALT pkg_std.tQUANT;
    rCNTR_DOC     udo_uzd_03_buyplanesp_cntr_doc%rowtype;
  begin
    /*Атрибуты записи строки плана закупок*/
    begin
      select S.*
        into RSP
        from BUYPLANESP S
       where S.RN = NRN
         and S.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecs');
    end;
    /*Состояние плана закупок*/
    begin
      select BP.STATE
        into NSTATE
        from BUYPLANE BP
       where BP.RN = RSP.PRN
         and BP.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RSP.PRN,
                                 SUNIT_TABLE => 'BuyPlanes');
    end;
    /*Если план закупок не утвержден, то выдаем сообщение об ошибке*/
    if (NSTATE = 3) /*and utilizer != 'KHOK'*/ then -- 02/12/2023 Марков МВ. только по закрытым <> 2) then
      P_EXCEPTION(0, 'План закупок Закрыт. Формирование невозможно!!!');
    end if;
    /*Цены включают налоги*/
    begin
      select DO.INCLUDETAX, DO.ORD_STATE
        into NPRICEWITHTAX, NORD_STATE
        from DELIVERYORD DO
       where DO.RN = NRN_ORD
         and DO.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN_ORD,
                                 SUNIT_TABLE => 'DeliveryOrders');
    end;
    /*Выполняем проверку состояния*/
    if  (nsign_upd_del_ord = 1) /*and utilizer != 'KHOK'*/ then
      if (NORD_STATE <> 0) 
        and PKG_FLAG.GET_FLAG = 0 -- 19/01/2024 Марков МВ. Для отработки Ведомости замен
        then
        P_EXCEPTION(0, 'Заказ поставщику находится в состоянии, отличном от "Не утвержден"');
      end if;
    end if;
    /*Выполняем поиск записи строки заказа поставщику*/
    begin
      select S.*
        into RORD_SP
        from DELIVERYORDS S
       where S.PRN = NRN_ORD
         and S.NOM_MODIF = RSP.NOMMODIF;
    exception
      when NO_DATA_FOUND then
        RORD_SP.RN := TO_NUMBER(null);
      when TOO_MANY_ROWS then
/*        if utilizer = 'KHOK' then -- когда есть две одинаковые строки
          RORD_SP := USR_PKG_DELIVERYORD.DELIVERYORDS_GET(nRN => 182347710 \*182347689*\, nFLAGSMART => 0);
        else */
        P_EXCEPTION(0, 'Не удалось однозначно определить строку заказа поставщику');
        --end if;
    end;

    if (nsign_upd_del_ord = 0) then
      /*Выполняем проверку наличия строки в заказе поставщику*/
      if (RORD_SP.RN is null) /*and utilizer != 'KHOK'*/ then
        P_EXCEPTION(0, 'Не удалось определить строку заказа поставщику');
      end if;
      /*Количество в плане закупок*/
      P_DOCUMENT_CALC_QUANT_BP(NCOMPANY   => NCOMPANY,
                               SUNITCODE  => 'DeliveryOrdersSpec',
                               NRN        => RORD_SP.RN,
                               NQUANT     => NQUANT_BP,
                               NQUANT_ALT => NQUANT_BP_ALT);
      /*Выполняем проверку количества*/
      if (NQUANT_BP + nquant > rord_sp.main_quant) 
        --and utilizer not in('CITK_MARKOV', 'KHOK')
        then
        p_exception(0, 'Превышено максимально допустимое количество в ОЕИ (%s + %s) для включения в заказ поставщику. В заказе поставщику (%s)'||cr
        ||'Строка заказа %s.', NQUANT_BP, nquant, rord_sp.main_quant, rord_sp.rn);
      end if;
      if (NQUANT_BP_alt + nquant_alt > rord_sp.alt_quant) then
        p_exception(0, 'Превышено максимально допустимое количество в ДЕИ для включения в заказ поставщику');
      end if;
    end if;
    if (nsign_upd_del_ord = 1) then
      /*Выполняем исправление строки */
      if (RORD_SP.RN is not null) then
        /*Количество ОЕИ*/
        RORD_SP.MAIN_QUANT := RORD_SP.MAIN_QUANT + NQUANT;
        /*Количество ДЕИ*/
        RORD_SP.ALT_QUANT := RORD_SP.ALT_QUANT + NQUANT_ALT;
        /*Расчет суммы*/
        PKG_DICTAXIS_CALC.P_CALCULATE_BASE(NFLAG_SMART => 0,
                                           NCOMPANY    => NCOMPANY,
                                           DDATE       => TRUNC(sysdate),
                                           NSUMM_SIGN  => NPRICEWITHTAX,
                                           NINSUMM     => (case
                                                            when (RORD_SP.PR_MEAS = 0) then
                                                             (RORD_SP.MAIN_QUANT *
                                                             RORD_SP.EXP_PRICE)
                                                            else
                                                             (RORD_SP.ALT_QUANT *
                                                             RORD_SP.EXP_PRICE)
                                                          end),
                                           NTAXGR      => RORD_SP.TAX_GROUP,
                                           NQUANT      => TO_NUMBER(null),
                                           NNCP_SIGN   => 0);
        /*Сумма без НДС*/
        PKG_DICTAXIS_CALC.P_GET_VALUE(NIDENT => 0,
                                      NVALUE => RORD_SP.SUMWOTAX);
        /*Сумма с НДС*/
        PKG_DICTAXIS_CALC.P_GET_VALUE(NIDENT => 2,
                                      NVALUE => RORD_SP.SUMWTAX);
        /*Выполняем базовое исправление строки заказа поставщику*/
        P_DELIVERYORDS_BASE_UPDATE(RSP => RORD_SP);
        /*Выполняем добавление строки*/
      else
        /*Регистрационный номер организации*/
        RORD_SP.COMPANY := NCOMPANY;
        /*Регистрационный номер родителя*/
        RORD_SP.PRN := NRN_ORD;
        /*Номенклатура*/
        RORD_SP.NOMEN := RSP.NOMEN;
        /*Модификация*/
        RORD_SP.NOM_MODIF := RSP.NOMMODIF;
        /*Налоговая группа*/
        RORD_SP.TAX_GROUP := NTAX_GROUP;
        /*Цена*/
        RORD_SP.EXP_PRICE := 0;
        /*ЕИ цены*/
        RORD_SP.PR_MEAS   := 0;
        RORD_SP.POSREDUCT := 0;
        /*Количество ОЕИ*/
        RORD_SP.MAIN_QUANT := NQUANT;
        /*Количество ДЕИ*/
        RORD_SP.ALT_QUANT := NQUANT_ALT;
        /*Расчет суммы*/
        PKG_DICTAXIS_CALC.P_CALCULATE_BASE(NFLAG_SMART => 0,
                                           NCOMPANY    => NCOMPANY,
                                           DDATE       => TRUNC(sysdate),
                                           NSUMM_SIGN  => NPRICEWITHTAX,
                                           NINSUMM     => (case
                                                            when (RORD_SP.PR_MEAS = 0) then
                                                             (RORD_SP.MAIN_QUANT *
                                                             RORD_SP.EXP_PRICE)
                                                            else
                                                             (RORD_SP.ALT_QUANT *
                                                             RORD_SP.EXP_PRICE)
                                                          end),
                                           NTAXGR      => RORD_SP.TAX_GROUP,
                                           NQUANT      => TO_NUMBER(null),
                                           NNCP_SIGN   => 0);
        /*Сумма без НДС*/
        PKG_DICTAXIS_CALC.P_GET_VALUE(NIDENT => 0,
                                      NVALUE => RORD_SP.SUMWOTAX);
        /*Сумма с НДС*/
        PKG_DICTAXIS_CALC.P_GET_VALUE(NIDENT => 2,
                                      NVALUE => RORD_SP.SUMWTAX);
        /*Выполняем базовое добавление строки заказа поставщику*/
        P_DELIVERYORDS_BASE_INSERT(RSP => RORD_SP, NRN => RORD_SP.RN);
      end if;
    end if;
    /*Анненко И.С. 29.12.2022*/
    if (nsign_upd_del_ord = 0) then
      begin
        select c.*
          into rCNTR_DOC
          from udo_uzd_03_buyplanesp_cntr_doc c
         where c.PRN = NRN
           and c.DOC_UNITCODE = 'DeliveryOrdersSpec'
           and c.DOC_RN = RORD_SP.RN
           and c.RN_REF = NRN_REF;
      exception
        when no_data_found then
          rCNTR_DOC.rn := to_number(null);
        when too_many_rows then
          p_exception(0,
                      'Не удалось однозначно определить документ закрытия');
      end;
    
      if (rCNTR_DOC.rn is not null) then
        P_BUYPLANESP_CNTR_DOC_BUPDATE(NCOMPANY            => rCNTR_DOC.COMPANY,
                                      NRN                 => rCNTR_DOC.rn,
                                      NQUANT_PLAN         => rCNTR_DOC.Quant_Plan +
                                                             NQUANT,
                                      NQUANT_PLAN_ALT     => rCNTR_DOC.Quant_Plan_Alt +
                                                             NQUANT_ALT,
                                      SDOC_UNITCODE       => rCNTR_DOC.Doc_Unitcode,
                                      NDOC_RN             => rCNTR_DOC.Doc_Rn,
                                      NDOC_QUANT_PLAN     => rCNTR_DOC.Doc_Quant_Plan +
                                                             NQUANT,
                                      NDOC_QUANT_PLAN_ALT => rCNTR_DOC.Doc_Quant_Plan_Alt +
                                                             NQUANT_ALT);
      
        NRN_CNTR_DOC := rCNTR_DOC.rn;
      end if;
    end if;
    /*Выполняем базовое добавление документа закрытия плана закупок*/
    if (NRN_CNTR_DOC is null) then
      P_BUYPLANESP_CNTR_DOC_BINSERT(NCOMPANY            => NCOMPANY,
                                    NCRN                => RSP.CRN,
                                    NPRN                => NRN,
                                    NQUANT_PLAN         => NQUANT,
                                    NQUANT_PLAN_ALT     => NQUANT_ALT,
                                    SDOC_UNITCODE       => 'DeliveryOrdersSpec',
                                    NDOC_RN             => RORD_SP.RN,
                                    NDOC_QUANT_PLAN     => NQUANT,
                                    NDOC_QUANT_PLAN_ALT => NQUANT_ALT,
                                    NRN_REF             => NRN_REF,
                                    nsign_check         => 1,
                                    NRN                 => NRN_CNTR_DOC);
    end if;
    /*24.12.2021 Коляскина Е.Н. Количество связей + провекра на накидывание связи ниже*/
    select count(1)
      into NCOUNT_LINKS
      from DOCLINKS L
     where L.IN_DOCUMENT = NRN
       and L.IN_UNITCODE = 'BuyPlaneSpecs'
       and L.OUT_DOCUMENT = NRN_ORD
       and L.OUT_UNITCODE = 'DeliveryOrders';
    /*Выполняем установку связи строки плана закупок с заказом поставщику*/
    if (NCOUNT_LINKS = 0) then
      PKG_DOCLINKS.LINK(NFLAG_SMART   => 0,
                        NCOMPANY      => NCOMPANY,
                        SIN_UNITCODE  => 'BuyPlaneSpecs',
                        NIN_DOCUMENT  => NRN,
                        SOUT_UNITCODE => 'DeliveryOrders',
                        NOUT_DOCUMENT => NRN_ORD);
    end if;
    /*Количество связей*/
    select count(1)
      into NCOUNT_LINKS
      from DOCLINKS L
     where L.IN_DOCUMENT = RSP.PRN
       and L.IN_UNITCODE = 'BuyPlanes'
       and L.OUT_DOCUMENT = NRN_ORD
       and L.OUT_UNITCODE = 'DeliveryOrders';
    /*Выполняем установку связи плана закупок с заказом поставщику*/
    if (NCOUNT_LINKS = 0) then
      PKG_DOCLINKS.LINK(NFLAG_SMART   => 0,
                        NCOMPANY      => NCOMPANY,
                        SIN_UNITCODE  => 'BuyPlanes',
                        NIN_DOCUMENT  => RSP.PRN,
                        SOUT_UNITCODE => 'DeliveryOrders',
                        NOUT_DOCUMENT => NRN_ORD);
    end if;
    /* Формирование Строки калькуляции Селиванов*/
    UDO_P_DELIVERYORDCS_GENREC(RORD_SP.COMPANY, RORD_SP.RN);
    
    /* 18/05/2024 Марков МВ. Проверка исполнения строки и самого заказа */
    for rps in(select DPS.RN, DPS.PERFS_STATE from DELIVERYORDPS DPS where DPS.PRN = RORD_SP.RN) loop
      if NORD_STATE = 1 and rps.perfs_state <> 3 then
        update DELIVERYORDPS DPS set DPS.PERFS_STATE = 3 where DPS.RN = rps.rn;
      end if;
    end loop;
  end P_BUYPLANESP_BINCL_DELIVERYORD;

  /*Процедура выполняет базовое исключение указанной строки плана закупок из заказа поставщику*/
  procedure P_BUYPLANESP_Bexcl_DELIVERYORD(NCOMPANY          in number /*Регистрационный номер организации*/,
                                           NRN_ORD           in number /*Регистрационный номер записи заказа поставщику*/,
                                           NRN               in number /*Регистрационный номер записи*/,
                                           NRN_REF           in number /*Регистрационный номер записи ссылки на заказ*/,
                                           nsign_upd_del_ord in number /*Признак необходимости исправления заказа поставщику*/) is
    /*Атрибуты записи строки плана закупок*/
    RSP BUYPLANESP%rowtype;
    /*Состояние плана закупок*/
    NSTATE number;
    /*Атрибуты записи строки заказа поставщику*/
    RORD_SP DELIVERYORDS%rowtype;
    /*Атрибуты записи документа закрытия*/
    rCNTR_DOC udo_uzd_03_buyplanesp_cntr_doc%rowtype;
    /*Количество связей*/
    NCOUNT_LINKS number;
    /*Цены включают налоги*/
    NPRICEWITHTAX number;
    /*Состояние*/
    NORD_STATE number;
  begin
    /*Атрибуты записи строки плана закупок*/
    begin
      select S.*
        into RSP
        from BUYPLANESP S
       where S.RN = NRN
         and S.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecs');
    end;
    /*Состояние плана закупок*/
    begin
      select BP.STATE
        into NSTATE
        from BUYPLANE BP
       where BP.RN = RSP.PRN
         and BP.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RSP.PRN,
                                 SUNIT_TABLE => 'BuyPlanes');
    end;
    /*Если план закупок не утвержден, то выдаем сообщение об ошибке*/
    if (NSTATE <> 2) /*and utilizer != 'KHOK'*/ then
      P_EXCEPTION(0, 'План закупок не утвержден');
    end if;
    /*Цены включают налоги*/
    begin
      select DO.INCLUDETAX, DO.ORD_STATE
        into NPRICEWITHTAX, NORD_STATE
        from DELIVERYORD DO
       where DO.RN = NRN_ORD
         and DO.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN_ORD,
                                 SUNIT_TABLE => 'DeliveryOrders');
    end;
    /*Выполняем проверку состояния*/
    if (nsign_upd_del_ord = 1) then
      if (NORD_STATE <> 0) then
        P_EXCEPTION(0,
                    'Заказ поставщику находится в состоянии, отличном от "Не утвержден"');
      end if;
    end if;
    /*Выполняем поиск записи строки заказа поставщику*/
    begin
      select S.*
        into RORD_SP
        from DELIVERYORDS S
       where S.PRN = NRN_ORD
         and S.NOM_MODIF = RSP.NOMMODIF;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0,
                    'Не удалось определить строку заказа поставщику');
      when TOO_MANY_ROWS then
/*        if utilizer = 'KHOK' then -- когда есть две одинаковые строки
          RORD_SP := USR_PKG_DELIVERYORD.DELIVERYORDS_GET(nRN => 129813656 \*182347689*\, nFLAGSMART => 0);
        else */
        P_EXCEPTION(0, 'Не удалось однозначно определить строку заказа поставщику');
        --end if;
    end;
    /*Атрибуты записи документа закрытия*/
    begin
      select c.*
        into rCNTR_DOC
        from udo_uzd_03_buyplanesp_cntr_doc c
       where c.PRN = nrn
         and c.DOC_UNITCODE = 'DeliveryOrdersSpec'
         and c.DOC_RN = rord_sp.rn
         and c.RN_REF = NRN_REF;
    exception
      when no_data_found then
        P_EXCEPTION(0,
                    'Не удалось определить документ закрытия');
      when too_many_rows then
        P_EXCEPTION(0,
                    'Не удалось однозначно определить документ закрытия' || NRN_REF);
    end;
    /*Выполняем базовое удаление документа закрытия плана закупок*/
    P_BUYPLANESP_CNTR_DOC_Bdelete(nCOMPANY => ncompany,
                                  nRN      => rCNTR_DOC.rn);
    /* Формирование Строки калькуляции Селиванов*/
    UDO_P_DELIVERYORDCS_GENREC(RORD_SP.COMPANY, RORD_SP.RN);
    /*24.12.2021 Коляскина Е.Н. Количество связей + провекра на накидывание связи ниже*/
    select count(1)
      into NCOUNT_LINKS
      from udo_uzd_03_buyplanesp_cntr_doc c, deliveryords s
     where c.prn = nrn
       and c.doc_unitcode = 'DeliveryOrdersSpec'
       and c.doc_rn = s.rn
       and s.prn = NRN_ORD;
    /*Выполняем удаление связи строки плана закупок с заказом поставщику*/
    if (NCOUNT_LINKS = 0) then
      PKG_DOCLINKS.remove(SIN_UNITCODE  => 'BuyPlaneSpecs',
                          NIN_DOCUMENT  => NRN,
                          SOUT_UNITCODE => 'DeliveryOrders',
                          NOUT_DOCUMENT => NRN_ORD);
    end if;
    /*Количество связей*/
    select count(1)
      into NCOUNT_LINKS
      from buyplanesp                     bp_sp,
           udo_uzd_03_buyplanesp_cntr_doc c,
           deliveryords                   s
     where bp_sp.prn = rsp.prn
       and c.prn = bp_sp.rn
       and c.doc_unitcode = 'DeliveryOrdersSpec'
       and c.doc_rn = s.rn
       and s.prn = NRN_ORD;
    /*Выполняем удаление связи плана закупок с заказом поставщику*/
    if (NCOUNT_LINKS = 0) then
      PKG_DOCLINKS.remove(SIN_UNITCODE  => 'BuyPlanes',
                          NIN_DOCUMENT  => RSP.PRN,
                          SOUT_UNITCODE => 'DeliveryOrders',
                          NOUT_DOCUMENT => NRN_ORD);
    end if;
    if (nsign_upd_del_ord = 1) then
      /*Выполняем исправление строки */
      if (rCNTR_DOC.Doc_Quant_Plan < RORD_SP.Main_Quant) then
        /*Количество ОЕИ*/
        RORD_SP.MAIN_QUANT := RORD_SP.MAIN_QUANT - rCNTR_DOC.Doc_Quant_Plan;
        /*Количество ДЕИ*/
        RORD_SP.ALT_QUANT := RORD_SP.ALT_QUANT -
                             rCNTR_DOC.Doc_Quant_Plan_Alt;
        /*Расчет суммы*/
        PKG_DICTAXIS_CALC.P_CALCULATE_BASE(NFLAG_SMART => 0,
                                           NCOMPANY    => NCOMPANY,
                                           DDATE       => TRUNC(sysdate),
                                           NSUMM_SIGN  => NPRICEWITHTAX,
                                           NINSUMM     => (case
                                                            when (RORD_SP.PR_MEAS = 0) then
                                                             (RORD_SP.MAIN_QUANT *
                                                             RORD_SP.EXP_PRICE)
                                                            else
                                                             (RORD_SP.ALT_QUANT *
                                                             RORD_SP.EXP_PRICE)
                                                          end),
                                           NTAXGR      => RORD_SP.TAX_GROUP,
                                           NQUANT      => TO_NUMBER(null),
                                           NNCP_SIGN   => 0);
        /*Сумма без НДС*/
        PKG_DICTAXIS_CALC.P_GET_VALUE(NIDENT => 0,
                                      NVALUE => RORD_SP.SUMWOTAX);
        /*Сумма с НДС*/
        PKG_DICTAXIS_CALC.P_GET_VALUE(NIDENT => 2,
                                      NVALUE => RORD_SP.SUMWTAX);
        /*Выполняем базовое исправление строки заказа поставщику*/
        P_DELIVERYORDS_BASE_UPDATE(RSP => RORD_SP);
        /*Выполняем удаление строки*/
      else
        p_deliveryords_base_delete(nCOMPANY => ncompany, nRN => rord_sp.rn);
      end if;
    end if;
  end P_BUYPLANESP_Bexcl_DELIVERYORD;

  /*УЗД03.02.01.01*/
  /*Процедура выполняет базовое формирование заказа поставщику*/
  procedure P_BUYPLANESP_BCRT_DELIVERYORD(NCOMPANY      in number /*Регистрационный номер организации*/,
                                          NIDENT        in number /*Идентификатор помеченных записей*/,
                                          NCRN          in number /*Каталог*/,
                                          NDOC_TYPE     in number /*Тип*/,
                                          NAGENT        in number /*Контрагент*/,
                                          NEXECUTIVE    in number /*Ответственный*/,
                                          NSUBDIVISION  in number /*Подразделение*/,
                                          DDATE         in date /*Дата*/,
                                          DRELEASE_DATE in date /*Дата поставки*/,
                                          NTAX_GROUP    in number /*Налоговая группа*/,
                                          nSIGNTAX      in number /*Цены включают налоги*/,
                                          sigk          in varchar2 /*ИГК*/,
                                          sobs          in varchar2 /*ОБС*/,
                                          saccept       in varchar2 /*Приемка*/,
                                          SNOTE         in varchar2 /*Примечание*/) is
    /*Атрибуты записи заголовка плана закупок*/
    RBP BUYPLANE%rowtype;
    /*Атрибуты записи заказа поставщику*/
    RORD DELIVERYORD%rowtype;
    /*Юрилическое лицо*/
    SJUR_PERS PKG_STD.TSTRING;
    
    nTMP PKG_STD.tREF;
  begin
    /*Регистрационный номер записи заголовка плана закупок*/
    begin
      select distinct S.PRN
        into RBP.RN
        from (
              --
              select S.PRN
                from SELECTLIST SL, BUYPLANESP S
               where SL.IDENT = NIDENT
                 and SL.COMPANY = NCOMPANY
                 and S.RN = SL.DOCUMENT
              --
              union all
              --
              select S.PRN
                from SELECTLIST SL, BUYPLANESPREF R, BUYPLANESP S
               where SL.IDENT = NIDENT
                 and SL.COMPANY = NCOMPANY
                 and R.RN = SL.DOCUMENT
                 and S.RN = R.PRN
              --
              ) S;
    exception
      when NO_DATA_FOUND then
        P_EXCEPTION(0,
                    'Не удалось определить план закупок');
      when TOO_MANY_ROWS then
        P_EXCEPTION(0,
                    'Не удалось однозначно определить план закупок');
    end;
    /*Атрибуты записи заголовка плана закупок*/
    begin
      select BP.*
        into RBP
        from BUYPLANE BP
       where BP.RN = RBP.RN
         and BP.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => RBP.RN,
                                 SUNIT_TABLE => 'BuyPlanes');
    end;
    /*Выполняем установку атрибутов инициализации заказа поставщику*/
    P_DELIVERYORD_INIT_ATTRS(RORD => RORD);
    /*Организация*/
    RORD.COMPANY := NCOMPANY;
    /*Каталог*/
    RORD.CRN := ncrn;
    /*Тип*/
    RORD.ORD_DOCTYPE := ndoc_type;
    /*Префикс*/
    RORD.ORD_PREF := TO_CHAR(DDATE, 'yyyy');
    /*Номер*/
    P_DELIVERYORD_NEXT_NUMB(NCOMPANY     => NCOMPANY,
                            SORD_DOCTYPE => GET_DOCTYPES_CODE_ID(NFLAG_SMART => 0,
                                                                 NRN         => RORD.ORD_DOCTYPE),
                            SORD_PREF    => RORD.ORD_PREF,
                            SORD_NUMB    => RORD.ORD_NUMB);
    /*Контрагент*/
    RORD.AGENT := NAGENT;
    /*Лицеовй счет*/
    RORD.FACEACC := to_number(null);
    /*Дата*/
    RORD.ORD_DATE := DDATE;
    /*Вид отгрузки*/
    RORD.DISP_TYPE := to_number(null);
    /*Вид оплаты*/
    RORD.PAY_TYPE := to_number(null);
    /*Валюта*/
    RORD.CURRENCY := f_curbase_get_rn(nFLAG_SMART => 0,
                                      nCOMPANY    => ncompany);
    /*Ответственный*/
    RORD.ACC_AGENT := NEXECUTIVE /*Анненко И.С. 02.08.2021 RFACEACC.EXECUTIVE*/
     ;
    /*Подразделение*/
    RORD.SUBDIV := NSUBDIVISION /*Анненко И.С. 02.08.2021 RFACEACC.SUBDIV*/
     ;
    /*Дата поставки*/
    RORD.RELEASE_DATE := DRELEASE_DATE;
    /*Примечание*/
    RORD.NOTE := SNOTE;
    /*Юрилическое лицо*/
    FIND_JURPERSONS_MAIN(NFLAG_SMART => 0,
                         NCOMPANY    => NCOMPANY,
                         SJUR_PERS   => SJUR_PERS,
                         NJUR_PERS   => RORD.JUR_PERS);
    /*Цены включают налоги*/
    RORD.INCLUDETAX := nSIGNTAX;
    /*Выполняем базовое добавление заказа поставщику*/
    P_DELIVERYORD_BASE_INSERT(RORD => RORD, NRN => RORD.RN);
    /*ИГК*/
    prsg_prop.VSET(sUNITCODE  => 'DeliveryOrders',
                   nDOCUMENT  => rord.rn,
                   sPROPCODE  => 'ИГК',
                   sSTRVALUE  => sigk,
                   nNUMVALUE  => to_number(null),
                   dDATEVALUE => to_date(null));
    /*ОБС*/
    prsg_prop.VSET(sUNITCODE  => 'DeliveryOrders',
                   nDOCUMENT  => rord.rn,
                   sPROPCODE  => 'ИнстрОпл',
                   sSTRVALUE  => sobs,
                   nNUMVALUE  => to_number(null),
                   dDATEVALUE => to_date(null));
  
    /*Приемка*/
    prsg_prop.VSET(sUNITCODE  => 'DeliveryOrders',
                   nDOCUMENT  => rord.rn,
                   sPROPCODE  => 'ПРИЕМКА',
                   sSTRVALUE  => saccept,
                   nNUMVALUE  => to_number(null),
                   dDATEVALUE => to_date(null));
  
    /*Цикл по выбранным строкам плана закупок*/
    for SP_CURSOR in (
                      --
                      select S.RN as NRN,
                              TO_NUMBER(null) as NRN_REF,
                              S.QUANT_PLAN as NQUANT_PLAN,
                              S.QUANTALT_PLAN as NQUANTALT_PLAN,
                              TO_NUMBER(null) as NQUANT_CNTR,
                              TO_NUMBER(null) as NQUANT_ALT_CNTR
                        from SELECTLIST SL, BUYPLANESP S
                       where SL.IDENT = NIDENT
                         and SL.COMPANY = NCOMPANY
                         and S.RN = SL.DOCUMENT
                      --
                      union all
                      --
                      select S.RN as NRN,
                              R.RN as NRN_REF,
                              R.QUANT_PLAN as NQUANT_PLAN,
                              R.QUANTALT_PLAN as NQUANTALT_PLAN,
                              TO_NUMBER(null) as NQUANT_CNTR,
                              TO_NUMBER(null) as NQUANT_ALT_CNTR
                        from SELECTLIST SL, BUYPLANESPREF R, BUYPLANESP S
                       where SL.IDENT = NIDENT
                         and SL.COMPANY = NCOMPANY
                         and R.RN = SL.DOCUMENT
                         and S.RN = R.PRN
                      --
                      ) loop
      /*Выполняем расчет законтрактованного количества по строке плана закупок*/
      P_BUYPLANESP_CNTR_DOC_CLC_QNT(NCOMPANY        => NCOMPANY,
                                    NRN             => SP_CURSOR.NRN,
                                    NRN_REF         => SP_CURSOR.NRN_REF,
                                    NQUANT_PLAN     => SP_CURSOR.NQUANT_CNTR,
                                    NQUANT_PLAN_ALT => SP_CURSOR.NQUANT_ALT_CNTR);
      /*Выполняем включение указанной строки плана закупок в заказ поставщику*/
      if ((SP_CURSOR.NQUANT_PLAN - SP_CURSOR.NQUANT_CNTR > 0) or
         (SP_CURSOR.NQUANTALT_PLAN - SP_CURSOR.NQUANT_ALT_CNTR > 0)) then
        P_BUYPLANESP_BINCL_DELIVERYORD(NCOMPANY          => NCOMPANY,
                                       NRN_ORD           => RORD.RN,
                                       NTAX_GROUP        => NTAX_GROUP,
                                       NRN               => SP_CURSOR.NRN,
                                       NRN_REF           => SP_CURSOR.NRN_REF,
                                       NQUANT            => SP_CURSOR.NQUANT_PLAN -
                                                            SP_CURSOR.NQUANT_CNTR,
                                       NQUANT_ALT        => SP_CURSOR.NQUANTALT_PLAN -
                                                            SP_CURSOR.NQUANT_ALT_CNTR,
                                       nsign_upd_del_ord => 1);
      end if;
    end loop;
    
    /* 25/02/2026 Марков МВ. Добавим количество на ЛПМ */
    for rsp in(select DS.RN,
                      0 as TECH_QUANT,
                      (select DV.NUM_VALUE
                         from FCMATRESOURCE   MR,
                              DOCS_PROPS_VALS DV
                        where MR.NOMEN_MODIF = DS.NOM_MODIF
                          and DV.UNIT_RN = MR.RN
                          and DV.DOCS_PROP_RN = 157488441) as TECH_LPM
                 from DELIVERYORDS DS
                where DS.PRN = RORD.RN
                  -- 19/03/2026 Марков МВ. Только по списку заказов в доп.словаре ЗАКАЗ_ЛПМ
                  and exists(select null from EXTRA_DICTS ED, EXTRA_DICTS_VALUES EDV
                                    where ED.CODE = 'ЗАКАЗ_ЛПМ'
                                      and EDV.PRN = ED.RN
                                      and EDV.STR_VALUE in(select FA.NUMB from DELIVERYORDCS DCL, FACEACC FA
                                                                  where DCL.PRN = DS.RN and DCL.FACEACCOUNT = FA.RN))) loop
      -- проверим наличие
      if nvl(rsp.tech_lpm, 0) > 0 then
        -- добавим технужды по каждому заказу на производство
        /* пока 1 раз
        for rcnt in(select distinct ACT.RN
            from UDO_UZD_03_BUYPLANESP_CNTR_DOC DOC,
                 BUYPLANESPREF                  SPRF,
                 DEPARTMENTORDS                 ORDS,
                 DOCLINKS                       L,
                 FCPREXPACT                     ACT
           where DOC.DOC_RN = rsp.rn
             and DOC.RN_REF = SPRF.RN
             and SPRF.DEPTORDSP = ORDS.RN
             and L.OUT_DOCUMENT = ORDS.PRN
             and L.OUT_UNITCODE = 'DepartmentsOrders'
             and L.IN_DOCUMENT = ACT.RN
             and L.IN_UNITCODE = 'CostProductExpenseActs') loop
          rsp.tech_quant := rsp.tech_quant + 1;
        end loop;*/
        -- если нет потребности, то 1
        if rsp.tech_quant <= 0 then
          rsp.tech_quant := 1;
        end if;
        -- ЛПМ по каждой потребности (заказу на производство)
        rsp.tech_quant := rsp.tech_quant * rsp.tech_lpm;
        --добавим ЛПМ
        update DELIVERYORDS DS
           set DS.MAIN_QUANT = DS.MAIN_QUANT + rsp.tech_quant
         where DS.RN = rsp.rn;
        -- обновим исполнение
        update DELIVERYORDPS DPS
           set DPS.MAIN_QUANT = DPS.MAIN_QUANT + rsp.tech_quant,
               DPS.ACTM_QUANT = DPS.ACTM_QUANT + rsp.tech_quant,
               DPS.EXECM_QUANT = DPS.EXECM_QUANT + rsp.tech_quant,
               DPS.CUSTM_QUANT = DPS.CUSTM_QUANT + rsp.tech_quant
         where DPS.PRN = rsp.rn;
        -- добавим в калькуляцию по первому заказу
        for rclc in(select CS.RN from DELIVERYORDCS CS where CS.PRN = rsp.rn) loop
          update DELIVERYORDCS CLC
             set CLC.QUANT_PLAN = CLC.QUANT_PLAN + rsp.tech_quant,
                 CLC.QUANT_FACT = CLC.QUANT_FACT + rsp.tech_quant
           where CLC.RN = rclc.rn;
          exit;
        end loop;
        -- Добавим свойство
        PKG_DOCS_PROPS_VALS.MODIFY(sPROPERTY   => 'ТехН_ЛПМ',        -- мнемокод свойства
                                   sUNITCODE   => 'DeliveryOrdersSpec',        -- код раздела
                                   nDOCUMENT   => rsp.rn,          -- документ
                                   sSTR_VALUE  => null,        -- значение (строка)
                                   nNUM_VALUE  => rsp.tech_quant,          -- значение (число)
                                   dDATE_VALUE => null,            -- значение (дата)
                                   nRN         => nTMP          -- регистрационный номер записи значения свойства
                                   );
      end if;
      
    end loop;
    
  end P_BUYPLANESP_BCRT_DELIVERYORD;

  /*Процедура определяет атрибуты заказа поставщику по плану закупок*/
  procedure p_buyplanesp_calc_deliveryord(NCOMPANY in number /*Регистрационный номер организации*/,
                                          NIDENT   in number /*Идентификатор помеченных записей*/,
                                          SAGENT   out varchar2 /*Контрагент*/,
                                          sigk     out varchar2 /*ИГК*/,
                                          sobs     out varchar2 /*ОБС*/) is
  begin
    select distinct t.sagent,
                    t.sigk,
                    (select fpt.code
                       from agnacc acc, finpaytool fpt
                      where acc.agnacc = t.sobs
                        and fpt.payer_acc = acc.rn)
      into sagent, sigk, sobs
      from (
            --
            select a.agnabbr as sagent,
                    udo_f_buyplanespref_igk(nrn => r.rn) as sigk,
                    udo_f_buyplanespref_obs(nrn => r.rn) as sobs
              from SELECTLIST SL, BUYPLANESP S, BUYPLANESPREF R, agnlist a
             where SL.IDENT = NIDENT
               and SL.COMPANY = NCOMPANY
               and S.RN = SL.DOCUMENT
               and r.prn = s.rn
               and a.rn(+) = s.agent
            --
            union all
            --
            select a.agnabbr as sagent,
                    udo_f_buyplanespref_igk(nrn => r.rn) as sigk,
                    udo_f_buyplanespref_obs(nrn => r.rn) as sobs
              from SELECTLIST SL, BUYPLANESPREF R, BUYPLANESP S, agnlist a
             where SL.IDENT = NIDENT
               and SL.COMPANY = NCOMPANY
               and R.RN = SL.DOCUMENT
               and S.RN = R.PRN
               and a.rn(+) = s.agent
            --
            ) t;
  exception
    when others then
      sagent := to_char(null);
      sigk   := to_char(null);
      sobs   := to_char(null);
  end p_buyplanesp_calc_deliveryord;

  /*Процедура выполняет формирование заказа поставщику по плану закупок*/
  procedure p_buyplanesp_crt_deliveryord(NCOMPANY  in number /*Регистрационный номер организации*/,
                                         sunitcode in varchar2 /*Код раздела*/,
                                         saction   in varchar2 /*Действие*/,
                                         stable    in varchar2 /*Таблица*/,
                                         NCRN      in number /*Каталог*/,
                                         NIDENT    in number /*Идентификатор помеченных записей*/,
                                         --SCATALOG      in varchar2 /*Каталог*/,
                                         SDOC_TYPE     in varchar2 /*Тип*/,
                                         SAGENT        in varchar2 /*Контрагент*/,
                                         SEXECUTIVE    in varchar2 /*Ответственный*/,
                                         SSUBDIVISION  in varchar2 /*Подразделение*/,
                                         DDATE         in date /*Дата*/,
                                         DRELEASE_DATE in date /*Дата поставки*/,
                                         STAX_GROUP    in varchar2 /*Налоговая группа*/,
                                         nSIGNTAX      in number /*Цены включают налоги*/,
                                         sigk          in varchar2 /*ИГК*/,
                                         sobs          in varchar2 /*ОБС*/,
                                         saccept       in varchar2 /*Приемка*/,
                                         SNOTE         in varchar2 /*Примечание*/) is
    /*Каталог*/
    SCATALOG pkg_std.tSTRING;
    /*Каталог*/
    NCATALOG PKG_STD.TREF;
    /*Тип*/
    NDOC_TYPE PKG_STD.TREF;
    /*Контрагент*/
    NAGENT PKG_STD.TREF;
    /*Налоговая группа*/
    NTAX_GROUP PKG_STD.TREF;
    /*Ответственный*/
    NEXECUTIVE PKG_STD.TREF;
    /*Подразделение*/
    NSUBDIVISION PKG_STD.TREF;
  begin
    /*Каталог*/
    sCATALOG := GET_OPTIONS_STR('Realiz_DeliveryOrd_Catalog', nCOMPANY);
    if (rtrim(sCATALOG) is null) then
      P_EXCEPTION(0,
                  'В настройках системы не определен каталог заказов поставщикам по умолчанию.');
    end if;
    /*Анненко и.С. 04.04.2023*/
    if (sunitcode = 'BuyPlaneSpecs') then
      p_exception(0, 'Действие запрещено. Формирование осуществляется из вкладки "Ссылки на заказы".');
    end if;
    /*Каталог*/
    FIND_ACATALOG_NAME(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       NVERSION    => TO_NUMBER(null),
                       SUNITCODE   => 'DeliveryOrders',
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
    /*Налоговая группа*/
    FIND_DICTAXGR_CODE(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       SCODE       => STAX_GROUP,
                       NRN         => NTAX_GROUP);
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
    -- Фиксация начала выполнения действия
    PKG_ENV.PROLOGUE(NCOMPANY, null, NCRN, sunitcode, saction, stable, 0);
    /*Выполняем базовое формирование заказа поставщику*/
    P_BUYPLANESP_BCRT_DELIVERYORD(NCOMPANY      => NCOMPANY,
                                  NIDENT        => NIDENT,
                                  NCRN          => NCATALOG,
                                  NDOC_TYPE     => NDOC_TYPE,
                                  NAGENT        => NAGENT,
                                  NEXECUTIVE    => NEXECUTIVE,
                                  NSUBDIVISION  => NSUBDIVISION,
                                  DDATE         => DDATE,
                                  DRELEASE_DATE => DRELEASE_DATE,
                                  NTAX_GROUP    => NTAX_GROUP,
                                  nSIGNTAX      => nSIGNTAX,
                                  sigk          => sigk,
                                  sobs          => sobs,
                                  saccept       => saccept,
                                  SNOTE         => SNOTE);
    -- Фиксация окончания выполнения действия
    PKG_ENV.EPILOGUE(NCOMPANY, null, NCRN, sunitcode, saction, stable, 0);
  end p_buyplanesp_crt_deliveryord;

  /*Добавить привязку к заказу поставщику*/
  procedure P_BUYPLANESP_INCL_DELIVERYORD(NCOMPANY   in number /*Регистрационный номер организации*/,
                                          sunitcode  in varchar2 /*Код раздела*/,
                                          saction    in varchar2 /*Действие*/,
                                          stable     in varchar2 /*Таблица*/,
                                          NCRN       in number /*Каталог*/,
                                          NRN_ORD    in number /*Регистрационный номер записи заказа поставщику*/,
                                          STAX_GROUP in varchar2 /*Налоговая группа*/,
                                          NRN        in number /*Регистрационный номер записи*/,
                                          NQUANT     in number /*Количество в ОЕИ*/,
                                          NQUANT_ALT in number /*Количество в ДЕИ*/) is
  
    /*Налоговая группа*/
    NTAX_GROUP PKG_STD.TREF;
    /*Регистрационный номер записи строки плана закупок*/
    nrn_bp_sp pkg_std.tREF;
    /*Регистрационный номер записи строки заказа в плане закупок*/
    nrn_ref pkg_std.tREF;
  begin
    /*Регистрационный номер записи строки плана закупок*/
    /*Регистрационный номер записи строки заказа в плане закупок*/
    if (sunitcode = 'BuyPlaneSpecs') then
      /*Анненко и.С. 04.04.2023*/
      p_exception(0, 'Действие запрещено');
      nrn_bp_sp := nrn;
      nrn_ref   := to_number(null);
    elsif (sunitcode = 'BuyPlaneSpecsReferences') then
      begin
        select r.prn
          into nrn_bp_sp
          from buyplanespref r
         where r.rn = nrn
           and r.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                   sUNIT_TABLE => sunitcode);
      end;
      nrn_ref := nrn;
    else
      p_exception(0,
                  'Не удалось определить код раздела');
    end if;
    /*Налоговая группа*/
    FIND_DICTAXGR_CODE(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       SCODE       => STAX_GROUP,
                       NRN         => NTAX_GROUP);
    -- Фиксация начала выполнения действия
    PKG_ENV.PROLOGUE(NCOMPANY, null, NCRN, sunitcode, saction, stable, NRN);
    /*Выполняем базовое включение указанной строки плана закупок в заказ поставщику*/
    P_BUYPLANESP_BINCL_DELIVERYORD(NCOMPANY          => NCOMPANY,
                                   NRN_ORD           => NRN_ORD,
                                   NTAX_GROUP        => NTAX_GROUP,
                                   NRN               => NRN_bp_sp,
                                   NRN_REF           => nrn_ref,
                                   NQUANT            => NQUANT,
                                   NQUANT_ALT        => NQUANT_ALT,
                                   nsign_upd_del_ord => 1);
    -- Фиксация окончания выполнения действия
    PKG_ENV.EPILOGUE(NCOMPANY, null, NCRN, sunitcode, saction, stable, NRN);
  end P_BUYPLANESP_INCL_DELIVERYORD;

  /*Добавить привязку к заказу поставщику на все количество*/
  procedure P_BUYPLANESP_INCLA_DELIVERYORD(NCOMPANY   in number /*Регистрационный номер организации*/,
                                           sunitcode  in varchar2 /*Код раздела*/,
                                           saction    in varchar2 /*Действие*/,
                                           stable     in varchar2 /*Таблица*/,
                                           NCRN       in number /*Каталог*/,
                                           NRN_ORD    in number /*Регистрационный номер записи заказа поставщику*/,
                                           STAX_GROUP in varchar2 /*Налоговая группа*/,
                                           NRN        in number /*Регистрационный номер записи*/) is
    /*Налоговая группа*/
    NTAX_GROUP PKG_STD.TREF;
    /*Регистрационный номер записи строки плана закупок*/
    nrn_bp_sp pkg_std.tREF;
    /*Регистрационный номер записи строки заказа в плане закупок*/
    nrn_ref pkg_std.tREF;
    /*План в ОЕИ*/
    NQUANT_PLAN pkg_std.tQUANT;
    /*План в ДЕИ*/
    NQUANTALT_PLAN pkg_std.tQUANT;
    /*Законтрактовано в ОЕИ*/
    NQUANT_CNTR pkg_std.tQUANT;
    /*Законтрактовано в ДЕИ*/
    NQUANT_ALT_CNTR pkg_std.tQUANT;
    --
    sNOMEN DICNOMNS.NOMEN_NAME%type;
  begin
    /*Налоговая группа*/
    FIND_DICTAXGR_CODE(NFLAG_SMART => 0,
                       NCOMPANY    => NCOMPANY,
                       SCODE       => STAX_GROUP,
                       NRN         => NTAX_GROUP);
    /*Регистрационный номер записи строки заказа в плане закупок*/
    if (sunitcode = 'BuyPlaneSpecs') then
      /*Анненко и.С. 04.04.2023*/
      p_exception(0, 'Действие запрещено');
      begin
        select s.quant_plan, s.quantalt_plan
          into NQUANT_PLAN, NQUANTALT_PLAN
          from buyplanesp s
         where s.rn = nrn
           and s.company = ncompany;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                   sUNIT_TABLE => sunitcode);
      end;
    
      nrn_bp_sp := nrn;
      nrn_ref   := to_number(null);
    elsif (sunitcode = 'BuyPlaneSpecsReferences') then
      begin
        select r.prn, r.quant_plan, r.quantalt_plan, NM.NOMEN_NAME
          into nrn_bp_sp, NQUANT_PLAN, NQUANTALT_PLAN, sNOMEN
          from buyplanespref r, BUYPLANESP PS, DICNOMNS NM
         where r.rn = nrn
           and r.company = ncompany
           and r.prn = PS.RN
           and PS.NOMEN = NM.RN;
      exception
        when no_data_found then
          pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                   sUNIT_TABLE => sunitcode);
      end;
      nrn_ref := nrn;
    else
      p_exception(0,
                  'Не удалось определить код раздела.');
    end if;
    /*Выполняем расчет законтрактованного количества по строке плана закупок*/
    P_BUYPLANESP_CNTR_DOC_CLC_QNT(NCOMPANY        => NCOMPANY,
                                  NRN             => NRN_bp_sp,
                                  nrn_ref         => nrn_ref,
                                  NQUANT_PLAN     => NQUANT_CNTR,
                                  NQUANT_PLAN_ALT => NQUANT_ALT_CNTR);
--if utilizer != 'KHOK' then
    /*Если остаток для контрактации отсутствует, то выдаем сообщение об ошибке*/
    if not ((NQUANT_PLAN - NQUANT_CNTR > 0) or
        (NQUANTALT_PLAN - NQUANT_ALT_CNTR > 0)) then
      p_exception(0,
                  'Остаток для контрактации отсутствует.' || chr(10) ||
                  'Номенклатура: %s' || chr(10) ||
                  'Количество к включению: %s' || chr(10) ||
                  'Законтрактовано: %s',
                  sNOMEN,
                  NQUANT_PLAN,
                  NQUANT_CNTR);
    end if;
--end if;  
    -- Фиксация начала выполнения действия
    PKG_ENV.PROLOGUE(NCOMPANY, null, NCRN, sunitcode, saction, stable, nrn);
  
    /*Выполняем включение указанной строки плана закупок в заказ поставщику*/
    P_BUYPLANESP_BINCL_DELIVERYORD(NCOMPANY          => NCOMPANY,
                                   NRN_ORD           => NRN_ORD,
                                   NTAX_GROUP        => NTAX_GROUP,
                                   NRN               => NRN_bp_sp,
                                   NRN_REF           => Nrn_Ref,
                                   NQUANT            => NQUANT_PLAN -
                                                        NQUANT_CNTR,
                                   NQUANT_ALT        => NQUANTALT_PLAN -
                                                        NQUANT_ALT_CNTR,
                                   nsign_upd_del_ord => 1);
    -- Фиксация окончания выполнения действия
    PKG_ENV.EPILOGUE(NCOMPANY, null, NCRN, sunitcode, saction, stable, 0);
  end P_BUYPLANESP_INCLA_DELIVERYORD;

  /*Процедура определяет перечень заказов поставщику с поправкой на партионность*/
  procedure p_bpspref_calc_del_ord_lst_wou(NCOMPANY     in number /*Регистрационный номер организации*/,
                                           NRN          in number /*Регистрационный номер записи*/,
                                           sdel_ord_lst out varchar2 /*Перечень заказов поставщику*/) is
  
    /*Атрибуты записи строки заказа подразделений в плане закупок*/
    rref buyplanespref%rowtype;
  
    /*Атрибуты записи строки плана закупок*/
    RSP buyplanesp%rowtype;
  
  begin
  
    /*Атрибуты записи строки заказа подразделений в плане закупок*/
    begin
      select r.*
        into rref
        from buyplanespref r
       where r.RN = NRN
         and r.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;
  
    /*Атрибуты записи строки плана закупок*/
    begin
      select S.*
        into rsp
        from BUYPLANESP S
       where S.RN = rref.prn
         and S.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => rref.prn,
                                 SUNIT_TABLE => 'BuyPlaneSpecs');
    end;
  
    /*Цикл по заказам поставщикам*/
    for del_ord_cursor in (select o.ord_doctype,
                                  o.ord_pref,
                                  o.ord_numb,
                                  o.ord_date,
                                  s.rn,
                                  s.main_quant,
                                  s.alt_quant,
                                  to_number(null) as NQUANT_BP,
                                  to_number(null) as NQUANT_BP_alt
                             from deliveryords s, deliveryord o
                            where s.nom_modif = rsp.nommodif
                              and s.company = ncompany
                              and o.rn = s.prn
                              and exists
                            (select 1
                                     from doclinks l
                                    where l.out_document = o.rn
                                      and l.out_unitcode = 'DeliveryOrders'
                                      and l.in_unitcode = 'BuyPlanes')
                              and not exists (select 1
                                     from udo_uzd_03_buyplanesp_cntr_doc c
                                    where c.rn_ref = nrn
                                      and c.doc_rn = s.rn)
                              and not exists
                            (select 1
                                     from doclinks l
                                    where l.in_document = o.rn
                                      and l.in_unitcode = 'DeliveryOrders'
                                      and l.out_unitcode = 'IncomingInvoices')
                              and not exists
                            (select 1
                                     from doclinks l1, doclinks l2
                                    where l1.in_document = o.rn
                                      and l1.in_unitcode = 'DeliveryOrders'
                                      and l1.out_unitcode =
                                          'PaymentAccountsIn'
                                      and l2.in_document = l1.out_document
                                      and l2.in_unitcode = l1.out_unitcode
                                      and l2.out_unitcode =
                                          'IncomingInvoices')) loop
      /*Количество в плане закупок*/
      P_DOCUMENT_CALC_QUANT_BP(NCOMPANY   => NCOMPANY,
                               SUNITCODE  => 'DeliveryOrdersSpec',
                               NRN        => del_ord_cursor.RN,
                               NQUANT     => del_ord_cursor.NQUANT_BP,
                               NQUANT_ALT => del_ord_cursor.NQUANT_BP_ALT);
    
      if (del_ord_cursor.main_quant - del_ord_cursor.nquant_bp > 0) then
        if (sdel_ord_lst is not null) then
          sdel_ord_lst := sdel_ord_lst || chr(13) || chr(10);
        end if;
      
        sdel_ord_lst := sdel_ord_lst ||
                        pkg_document.make_number(ndoc_type => del_ord_cursor.ord_doctype,
                                                 sdoc_pref => del_ord_cursor.ord_pref,
                                                 sdoc_numb => del_ord_cursor.ord_numb,
                                                 ddoc_date => del_ord_cursor.ord_date) ||
                        ' = ' || to_char(del_ord_cursor.main_quant -
                                         del_ord_cursor.nquant_bp);
      end if;
    end loop;
  end p_bpspref_calc_del_ord_lst_wou;

  /*Процедура выполняет расчет количества для привязки к оформленному заказу поставщику*/
  procedure P_BUYPLANESP_calc_DEL_ORD_WO_U(NCOMPANY   in number /*Регистрационный номер организации*/,
                                           NRN_ORD    in number /*Регистрационный номер записи заказа поставщику*/,
                                           NRN        in number /*Регистрационный номер записи*/,
                                           NQUANT     out number /*Количество в ОЕИ*/,
                                           NQUANT_ALT out number /*Количество в ДЕИ*/) is
  
    /*Атрибуты записи строки заказа подразделений в плане закупок*/
    rref buyplanespref%rowtype;
  
    /*Атрибуты записи строки плана закупок*/
    RSP buyplanesp%rowtype;
  
    /*Атрибуты записи строки заказа поставщику*/
    RORD_SP DELIVERYORDS%rowtype;
  
    /*Законтрактовано*/
    nquant_cntr     pkg_std.tQUANT;
    nquant_cntr_alt pkg_std.tQUANT;
  
    /*Количество в плане закупок*/
    NQUANT_BP     pkg_std.tQUANT;
    NQUANT_BP_ALT pkg_std.tQUANT;
  
  begin
    /*Атрибуты записи строки заказа подразделений в плане закупок*/
    begin
      select r.*
        into rref
        from buyplanespref r
       where r.RN = NRN
         and r.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN,
                                 SUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;
  
    /*Атрибуты записи строки плана закупок*/
    begin
      select S.*
        into rsp
        from BUYPLANESP S
       where S.RN = rref.prn
         and S.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => rref.prn,
                                 SUNIT_TABLE => 'BuyPlaneSpecs');
    end;
  
    /*Выполняем поиск записи строки заказа поставщику*/
    begin
      select S.*
        into RORD_SP
        from DELIVERYORDS S
       where S.PRN = NRN_ORD
         and S.NOM_MODIF = RSP.NOMMODIF;
    exception
      when NO_DATA_FOUND then
        RORD_SP.rn := to_number(null);
      when TOO_MANY_ROWS then
/*        if utilizer = 'KHOK' then -- когда есть две одинаковые строки
          RORD_SP := USR_PKG_DELIVERYORD.DELIVERYORDS_GET(nRN => 182347710 \*182347689*\, nFLAGSMART => 0);
        else */
        P_EXCEPTION(0, 'Не удалось однозначно определить строку заказа поставщику');
        --end if;
    end;
  
    if (RORD_SP.rn is null) then
      NQUANT     := 0;
      NQUANT_ALT := 0;
    end if;
  
    /*Законтрактовано*/
    p_buyplanesp_cntr_doc_clc_qnt(ncompany        => ncompany,
                                  nrn             => rref.prn,
                                  nrn_ref         => rref.rn,
                                  nquant_plan     => nquant_cntr,
                                  nquant_plan_alt => nquant_cntr_alt);
  
    /*Количество в плане закупок*/
    P_DOCUMENT_CALC_QUANT_BP(NCOMPANY   => NCOMPANY,
                             SUNITCODE  => 'DeliveryOrdersSpec',
                             NRN        => RORD_SP.RN,
                             NQUANT     => NQUANT_BP,
                             NQUANT_ALT => NQUANT_BP_ALT);
  
    /*Количество в ОЕИ*/
    NQUANT := least(rref.quant_plan - nquant_cntr,
                    RORD_SP.Main_Quant - NQUANT_BP);
  
    /*Количество в ДЕИ*/
    NQUANT_ALT := least(rref.quantalt_plan - nquant_cntr_alt,
                        rord_sp.alt_quant - NQUANT_BP_ALT);
  end P_BUYPLANESP_calc_DEL_ORD_WO_U;

  /*Добавить привязку к оформленному заказу поставщику*/
  procedure P_BUYPLANESP_INCL_DEL_ORD_WO_U(NCOMPANY   in number /*Регистрационный номер организации*/,
                                           NCRN       in number /*Каталог*/,
                                           NRN_ORD    in number /*Регистрационный номер записи заказа поставщику*/,
                                           NRN        in number /*Регистрационный номер записи*/,
                                           NQUANT     in number /*Количество в ОЕИ*/,
                                           NQUANT_ALT in number /*Количество в ДЕИ*/) is
    /*Регистрационный номер записи строки плана закупок*/
    nrn_bp_sp pkg_std.tREF;
  begin
    /*Регистрационный номер записи строки плана закупок*/
    begin
      select r.prn
        into nrn_bp_sp
        from buyplanespref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;
    -- Фиксация начала выполнения действия
    PKG_ENV.PROLOGUE(NCOMPANY,
                     null,
                     NCRN,
                     'BuyPlaneSpecsReferences',
                     'BuyPlaneSpecsReferencesInclDelOrdersDone',
                     'BUYPLANESPREF',
                     NRN);
    /*Выполняем базовое включение указанной строки плана закупок в заказ поставщику*/
    P_BUYPLANESP_BINCL_DELIVERYORD(NCOMPANY          => NCOMPANY,
                                   NRN_ORD           => NRN_ORD,
                                   NTAX_GROUP        => to_number(null),
                                   NRN               => NRN_bp_sp,
                                   NRN_REF           => nrn,
                                   NQUANT            => NQUANT,
                                   NQUANT_ALT        => NQUANT_ALT,
                                   nsign_upd_del_ord => 0);
    -- Фиксация окончания выполнения действия
    PKG_ENV.EPILOGUE(NCOMPANY,
                     null,
                     NCRN,
                     'BuyPlaneSpecsReferences',
                     'BuyPlaneSpecsReferencesInclDelOrdersDone',
                     'BUYPLANESPREF',
                     NRN);
  end P_BUYPLANESP_INCL_DEL_ORD_WO_U;

  /*Удалить привязку к оформленному заказу поставщику*/
  procedure P_BUYPLANESP_exCL_DEL_ORD_WO_U(NCOMPANY in number /*Регистрационный номер организации*/,
                                           NCRN     in number /*Каталог*/,
                                           NRN_ORD  in number /*Регистрационный номер записи заказа поставщику*/,
                                           NRN      in number /*Регистрационный номер записи*/) is
  
    /*Регистрационный номер записи строки плана закупок*/
    nrn_bp_sp pkg_std.tREF;
  
  begin
    /*Регистрационный номер записи строки плана закупок*/
    begin
      select r.prn
        into nrn_bp_sp
        from buyplanespref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;
    -- Фиксация начала выполнения действия
    PKG_ENV.PROLOGUE(NCOMPANY,
                     null,
                     NCRN,
                     'BuyPlaneSpecsReferences',
                     'BuyPlaneSpecsReferencesExclDelOrdersDone',
                     'BUYPLANESPREF',
                     NRN);
    /*Выполняем базовое включение указанной строки плана закупок в заказ поставщику*/
    P_BUYPLANESP_BexCL_DELIVERYORD(NCOMPANY          => NCOMPANY,
                                   NRN_ORD           => NRN_ORD,
                                   NRN               => NRN_bp_sp,
                                   NRN_REF           => nrn,
                                   nsign_upd_del_ord => 0);
    -- Фиксация окончания выполнения действия
    PKG_ENV.EPILOGUE(NCOMPANY,
                     null,
                     NCRN,
                     'BuyPlaneSpecsReferences',
                     'BuyPlaneSpecsReferencesExclDelOrdersDone',
                     'BUYPLANESPREF',
                     NRN);
  end P_BUYPLANESP_exCL_DEL_ORD_WO_U;

  /*Добавить привязку к оформленному заказу поставщику*/
  procedure p_buyplanespref_INCL_DEL_ORD(NCOMPANY in number /*Регистрационный номер организации*/,
                                         NRN      in number /*Регистрационный номер записи*/) is
  
    /*Атрибуты записи*/
    rref buyplanespref%rowtype;
  
    /*Законтрактовано*/
    nquant_cntr pkg_std.tQUANT;
  
    nquant_cntr_alt pkg_std.tQUANT;
  
    /*Регистрационный номер записи заказа поставщику*/
    NRN_ORD pkg_std.tREF;
  
  begin
    /*Атрибуты записи*/
    begin
      select r.*
        into rref
        from buyplanespref r
       where r.rn = nrn
         and r.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'BuyPlaneSpecsReferences');
    end;
  
    /*Регистрационный номер записи заказа поставщику*/
    begin
      select l.out_document
        into NRN_ORD
        from departmentords s, doclinks l, deliveryords dos
       where s.rn = rref.deptordsp
         and s.company = ncompany
         and l.in_document = s.prn
         and l.in_unitcode = 'DepartmentsOrders'
         and l.out_unitcode = 'DeliveryOrders'
         and dos.prn = l.out_document
         and dos.nom_modif = s.nom_modif;
    exception
      when no_data_found then
        NRN_ORD := to_number(null);
      when too_many_rows then
        p_exception(0,
                    'Не удалось однозначно определить заказ поставщику');
    end;
  
    if (nrn_ord is null) then
      return;
    end if;
  
    /*Законтрактовано*/
    p_buyplanesp_cntr_doc_clc_qnt(ncompany        => get_session_company,
                                  nrn             => rref.prn,
                                  nrn_ref         => rref.rn,
                                  nquant_plan     => nquant_cntr,
                                  nquant_plan_alt => nquant_cntr_alt);
  
    if (rref.quant_plan - nquant_cntr <= 0) then
      return;
    end if;
  
    /*Выполняем базовое включение указанной строки плана закупок в заказ поставщику*/
    P_BUYPLANESP_BINCL_DELIVERYORD(NCOMPANY          => NCOMPANY,
                                   NRN_ORD           => NRN_ORD,
                                   NTAX_GROUP        => to_number(null),
                                   NRN               => rref.prn,
                                   NRN_REF           => rref.rn,
                                   NQUANT            => rref.quant_plan -
                                                        nquant_cntr,
                                   NQUANT_ALT        => rref.quantalt_plan -
                                                        nquant_cntr_alt,
                                   nsign_upd_del_ord => 0);
  end p_buyplanespref_INCL_DEL_ORD;

  /*Утверждение заказа поставщику*/
  procedure P_DELIVERYORD_CHECK_BP_QUANT(NCOMPANY in number /*Регистрационный номер организации*/,
                                         NRN      in number /*Регистрационный номер записи*/) is
  begin
    /*Цикл по строкам заказа поставщику*/
    for SP_CURSOR in (select S.RN as NRN,
                             S.NOMEN as NNOMEN,
                             S.MAIN_QUANT as NMAIN_QUANT,
                             S.ALT_QUANT as NALT_QUANT,
                             TO_NUMBER(null) as NQUANT_BP,
                             TO_NUMBER(null) as NQUANT_BP_ALT,
                             TO_NUMBER(null) as NRN_CNTR_DOC
                        from DELIVERYORDS S
                       where S.PRN = NRN
                         and S.COMPANY = NCOMPANY) loop
      P_DOCUMENT_CALC_QUANT_BP(NCOMPANY   => NCOMPANY,
                               SUNITCODE  => 'DeliveryOrdersSpec',
                               NRN        => SP_CURSOR.NRN,
                               NQUANT     => SP_CURSOR.NQUANT_BP,
                               NQUANT_ALT => SP_CURSOR.NQUANT_BP_ALT);
      if ((SP_CURSOR.NMAIN_QUANT - SP_CURSOR.NQUANT_BP < 0) or
         (SP_CURSOR.NALT_QUANT - SP_CURSOR.NQUANT_BP_ALT < 0)) then
        begin
          select D.RN
            into SP_CURSOR.NRN_CNTR_DOC
            from UDO_UZD_03_BUYPLANESP_CNTR_DOC D
           where D.DOC_RN = SP_CURSOR.NRN
             and D.DOC_UNITCODE = 'DeliveryOrdersSpec'
             and D.COMPANY = NCOMPANY;
        exception
          when others then
            SP_CURSOR.NRN_CNTR_DOC := TO_NUMBER(null);
        end;
        if (SP_CURSOR.NRN_CNTR_DOC is null) then
          /*21/11/2022 Марков МВ.
          Заказ поставщику сформирован из нескольких строк ПЗ.
          Уменьшили количество по Заказу.
          Закрываем по порядку от большего значения.*/
          P_EXCEPTION(0,
                      'По номенклатуре ' ||
                      F_DICNOMNS_GET_CODE(NNOMEN => SP_CURSOR.NNOMEN) ||
                      ' количество в плане закупок больше количества по заказу поставщику.' ||
                      chr(10) ||
                      'Заказ поставщику сформирован из более чем одной строки плана закупок.' ||
                      chr(10) || 'SP_CURSOR.NRN = %s',
                      SP_CURSOR.NRN);
          /*Анненко И.С. 15.02.2023 По просьбе Марины вернул ошибку*/
          -- несколько позиций внесено в заказ поставщику
          /*for rdo in (select D.RN, D.QUANT_PLAN, D.DOC_QUANT_PLAN
                        from UDO_UZD_03_BUYPLANESP_CNTR_DOC D
                       where D.DOC_RN = SP_CURSOR.NRN
                         and D.DOC_UNITCODE = 'DeliveryOrdersSpec'
                         and D.COMPANY = NCOMPANY
                       order by D.QUANT_PLAN desc) loop
            if SP_CURSOR.NMAIN_QUANT = 0 then
              -- все количество по заказу поставщиков распределено по строкам плана - остальное удалить
              delete from UDO_UZD_03_BUYPLANESP_CNTR_DOC T
               where T.RN = rdo.rn;
            else
              -- распределим количество по строкам плана
              if rdo.quant_plan >= SP_CURSOR.NMAIN_QUANT then
                update UDO_UZD_03_BUYPLANESP_CNTR_DOC T
                   set T.QUANT_PLAN         = SP_CURSOR.NMAIN_QUANT,
                       T.QUANT_PLAN_ALT     = SP_CURSOR.NALT_QUANT,
                       T.DOC_QUANT_PLAN     = SP_CURSOR.NMAIN_QUANT,
                       T.DOC_QUANT_PLAN_ALT = SP_CURSOR.NALT_QUANT
                 where T.RN = rdo.rn;
                SP_CURSOR.NMAIN_QUANT := 0;
              else
                update UDO_UZD_03_BUYPLANESP_CNTR_DOC T
                   set T.DOC_QUANT_PLAN     = T.QUANT_PLAN,
                       T.DOC_QUANT_PLAN_ALT = T.QUANT_PLAN_ALT
                 where T.RN = rdo.rn;
                SP_CURSOR.NMAIN_QUANT := SP_CURSOR.NMAIN_QUANT -
                                         rdo.quant_plan;
              end if;
            end if;
          end loop;*/
        else
          /*Выполняем исправление записи в таблице*/
          update UDO_UZD_03_BUYPLANESP_CNTR_DOC T
             set T.QUANT_PLAN         = SP_CURSOR.NMAIN_QUANT,
                 T.QUANT_PLAN_ALT     = SP_CURSOR.NALT_QUANT,
                 T.DOC_QUANT_PLAN     = SP_CURSOR.NMAIN_QUANT,
                 T.DOC_QUANT_PLAN_ALT = SP_CURSOR.NALT_QUANT
           where T.RN = SP_CURSOR.NRN_CNTR_DOC
             and T.COMPANY = NCOMPANY;
          /*Выполняем проверку исправления записи в таблице*/
          if (sql%notfound) then
            PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => SP_CURSOR.NRN_CNTR_DOC,
                                     SUNIT_TABLE => 'BuyPlaneSpecsCntrDoc');
          end if;
        end if;
      end if;
    end loop;
  end P_DELIVERYORD_CHECK_BP_QUANT;

  /*Процедура определяет перечень заказов поставщику для указанной строки заказа подразделений в плане закупок*/
  procedure p_buyplanespref_clc_delord_lst(ncompany          in number /*Организация*/,
                                           nident            in number /*Идентификатор помеченных записей*/,
                                           nident_delord_lst out number /*Идентификатор помеченных записей заказов поставщикам*/) is
  
    /*Регистрационный номер записи*/
    nrn_sl pkg_std.tREF;
  
  begin
    /*Идентификатор помеченных записей заказов поставщикам*/
    p_selectlist_genident(nIDENT => nident_delord_lst);
  
    for delord_cursor in (select distinct ds.prn as nrn
                            from selectlist                     sl,
                                 udo_uzd_03_buyplanesp_cntr_doc c,
                                 deliveryords                   ds
                           where sl.ident = nident
                             and sl.company = ncompany
                             and c.rn_ref = sl.document
                             and ds.rn = c.doc_rn
                             and c.doc_unitcode = 'DeliveryOrdersSpec') loop
      p_selectlist_insert(nident    => nident_delord_lst,
                          ndocument => delord_cursor.nrn,
                          sunitcode => 'DeliveryOrders',
                          nrn       => nrn_sl);
    end loop;
  end p_buyplanespref_clc_delord_lst;

  /*Процедура определяет регистрационный номер записи строки счета на оплату для указанной строки заказа подразделений*/
  procedure p_departmentords_calc_acc_sp(ncompany in number /*Организация*/,
                                         nrn      in number /*Регистрационный номер записи*/,
                                         nrn_acc  out number /*Регистрационный номер записи строки счета на оплату*/) is
  begin
    select max(ps.rn) --min(ps.rn)
      into nrn_acc
      from buyplanespref                  r,
           udo_uzd_03_buyplanesp_cntr_doc c,
           deliveryords                   ds,
           doclinks                       l,
           payaccinspec                   ps
     where r.deptordsp = nrn
       and r.company = ncompany
       and c.prn = r.prn
       and c.rn_ref = r.rn
       and ds.rn = c.doc_rn
       and c.doc_unitcode = 'DeliveryOrdersSpec'
       and l.in_document = ds.prn
       and l.out_document = ps.prn
       and ps.nommodif = ds.nom_modif;
  end p_departmentords_calc_acc_sp;

  /*Процедура выполняет переброску указанного количества законтрактовано по заказу*/
  procedure P_BUYPLANESPREF_MOVE_CNTR(NCOMPANY        in number /*Регистрационный номер организации*/,
                                      NRN_SRC         in number /*Регистрационный номер записи источника*/,
                                      NRN_DST         in number /*Регистрационный номер записи назначения*/,
                                      NPRN_DST        in number /*Регистрационный номер записи родителя назначения*/,
                                      NCRN_DST        in number /*Регистрационный номер записи каталога назначения*/,
                                      NBP_DST         in number /*Регистрационный номер записи плана закупок назначения*/,
                                      NQUANT_MOVE     in number /*Количество переброски в ОЕИ*/,
                                      NQUANT_ALT_MOVE in number /*Количество переброски в ДЕИ*/) is
    /*Переброшенное количество в ОЕИ*/
    NQUANT_MOVE_EXEC PKG_STD.TQUANT;
    /*Переброшенное количество в ДЕИ*/
    NQUANT_ALT_MOVE_EXEC PKG_STD.TQUANT;
    /*Регистрационный номер записи документа контрактации*/
    NRN_CNTR_DOC PKG_STD.TREF;
    /*Регистрационный номер записи документа*/
    NRN_DOC PKG_STD.TREF;
    /*Количество связей*/
    NCOUNT_LINKS number;
    /*Дата начала периода*/
    DDATE_EXEC_BEGIN date;
    /*Дата окончания периода*/
    DDATE_EXEC_END date;
  begin
    /*Переброшенное количество в ОЕИ*/
    NQUANT_MOVE_EXEC := 0;
    /*Переброшенное количество в ДЕИ*/
    NQUANT_ALT_MOVE_EXEC := 0;
    for CNTR_DOC in (select T.*,
                            TO_NUMBER(null) as NQUANT_EXEC,
                            TO_NUMBER(null) as NQUANT_EXEC_ALT,
                            TO_NUMBER(null) as NQUANT_MOVE_EXEC_CUR,
                            TO_NUMBER(null) as NQUANT_ALT_MOVE_EXEC_CUR,
                            TO_NUMBER(null) as NQUANT_MOVE_EXEC_CUR_DOC,
                            TO_NUMBER(null) as NQUANT_ALT_MOVE_EXEC_CUR_DOC
                       from UDO_UZD_03_BPSP_CNTR_DOC_TMP T
                      where CMP_NUM(T.RN_REF, NRN_SRC) = 1) loop
      if (NQUANT_MOVE > NQUANT_MOVE_EXEC) or
         (NQUANT_ALT_MOVE > NQUANT_ALT_MOVE_EXEC) then
        /*Исполнено*/
        P_BUYPLANESP_CD_CLC_EXEC_QUANT(NRN              => CNTR_DOC.RN,
                                       NSIGN_PERIOD     => 1,
                                       NQUANT           => CNTR_DOC.NQUANT_EXEC,
                                       NQUANT_ALT       => CNTR_DOC.NQUANT_EXEC_ALT,
                                       DDATE_EXEC_BEGIN => DDATE_EXEC_BEGIN,
                                       DDATE_EXEC_END   => DDATE_EXEC_END);
        if (CNTR_DOC.QUANT_PLAN > CNTR_DOC.NQUANT_EXEC) or
           (CNTR_DOC.QUANT_PLAN_ALT > CNTR_DOC.NQUANT_EXEC_ALT) then
          /*Количество к переброске в ОЕИ*/
          CNTR_DOC.NQUANT_MOVE_EXEC_CUR := LEAST(CNTR_DOC.QUANT_PLAN -
                                                 CNTR_DOC.NQUANT_EXEC,
                                                 NQUANT_MOVE -
                                                 NQUANT_MOVE_EXEC);
          /*Количество к переброске в ДЕИ*/
          CNTR_DOC.NQUANT_ALT_MOVE_EXEC_CUR := LEAST(CNTR_DOC.QUANT_PLAN_ALT -
                                                     CNTR_DOC.NQUANT_EXEC_ALT,
                                                     NQUANT_ALT_MOVE -
                                                     NQUANT_ALT_MOVE_EXEC);
          /*Количество к переброске по документу в ОЕИ*/
          CNTR_DOC.NQUANT_MOVE_EXEC_CUR_DOC := CNTR_DOC.NQUANT_MOVE_EXEC_CUR *
                                               CNTR_DOC.DOC_QUANT_PLAN /
                                               CNTR_DOC.QUANT_PLAN;
          /*Количество к переброске по документу в ДЕИ*/
          if (CNTR_DOC.QUANT_PLAN_ALT = 0) then
            CNTR_DOC.NQUANT_ALT_MOVE_EXEC_CUR_DOC := 0;
          else
            CNTR_DOC.NQUANT_ALT_MOVE_EXEC_CUR_DOC := CNTR_DOC.NQUANT_ALT_MOVE_EXEC_CUR *
                                                     CNTR_DOC.DOC_QUANT_PLAN_ALT /
                                                     CNTR_DOC.QUANT_PLAN_ALT;
          end if;
          /*Выполняем уменьшение количества*/
          P_BUYPLANESP_CNTR_DOC_BUPDATE(NCOMPANY            => NCOMPANY,
                                        NRN                 => CNTR_DOC.RN,
                                        NQUANT_PLAN         => CNTR_DOC.QUANT_PLAN -
                                                               CNTR_DOC.NQUANT_MOVE_EXEC_CUR,
                                        NQUANT_PLAN_ALT     => CNTR_DOC.QUANT_PLAN_ALT -
                                                               CNTR_DOC.NQUANT_ALT_MOVE_EXEC_CUR,
                                        SDOC_UNITCODE       => CNTR_DOC.DOC_UNITCODE,
                                        NDOC_RN             => CNTR_DOC.DOC_RN,
                                        NDOC_QUANT_PLAN     => CNTR_DOC.DOC_QUANT_PLAN -
                                                               CNTR_DOC.NQUANT_MOVE_EXEC_CUR_DOC,
                                        NDOC_QUANT_PLAN_ALT => CNTR_DOC.DOC_QUANT_PLAN_ALT -
                                                               CNTR_DOC.NQUANT_ALT_MOVE_EXEC_CUR_DOC);
          /*Выполняем добавление новой записи*/
          begin
            select CD.RN
              into NRN_CNTR_DOC
              from UDO_UZD_03_BUYPLANESP_CNTR_DOC CD
             where CD.PRN = NPRN_DST
               and CD.DOC_UNITCODE = CNTR_DOC.DOC_UNITCODE
               and CD.DOC_RN = CNTR_DOC.DOC_RN
               and CMP_NUM(CD.RN_REF, NRN_DST) = 1;
          exception
            when NO_DATA_FOUND then
              NRN_CNTR_DOC := TO_NUMBER(null);
            when TOO_MANY_ROWS then
              P_EXCEPTION(0,
                          'Не удалось однозначно определить документ контрактации');
          end;
          if (NRN_CNTR_DOC is not null) then
            /*Анненко И.С. 18.07.2022*/
            if (F_BUYPLANESP_CNTR_DOC_CLC_SGNC(NCOMPANY => NCOMPANY,
                                               NRN      => NRN_CNTR_DOC) = 1) then
              P_EXCEPTION(0,
                          'Документ контрактации аннулирован');
            end if;
            update UDO_UZD_03_BUYPLANESP_CNTR_DOC CD
               set CD.QUANT_PLAN         = CD.QUANT_PLAN +
                                           CNTR_DOC.NQUANT_MOVE_EXEC_CUR,
                   CD.QUANT_PLAN_ALT     = CD.QUANT_PLAN_ALT +
                                           CNTR_DOC.NQUANT_ALT_MOVE_EXEC_CUR,
                   CD.DOC_QUANT_PLAN     = CD.DOC_QUANT_PLAN +
                                           CNTR_DOC.NQUANT_MOVE_EXEC_CUR_DOC,
                   CD.DOC_QUANT_PLAN_ALT = CD.DOC_QUANT_PLAN_ALT +
                                           CNTR_DOC.NQUANT_ALT_MOVE_EXEC_CUR_DOC
             where CD.RN = NRN_CNTR_DOC;
            if (sql%notfound) then
              PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => NRN_CNTR_DOC,
                                       SUNIT_TABLE => 'BuyPlaneSpecsReferences');
            end if;
          else
            P_BUYPLANESP_CNTR_DOC_BINSERT(NCOMPANY            => NCOMPANY,
                                          NCRN                => NCRN_DST,
                                          NPRN                => NPRN_DST,
                                          NQUANT_PLAN         => CNTR_DOC.NQUANT_MOVE_EXEC_CUR,
                                          NQUANT_PLAN_ALT     => CNTR_DOC.NQUANT_ALT_MOVE_EXEC_CUR,
                                          SDOC_UNITCODE       => CNTR_DOC.DOC_UNITCODE,
                                          NDOC_RN             => CNTR_DOC.DOC_RN,
                                          NDOC_QUANT_PLAN     => CNTR_DOC.NQUANT_MOVE_EXEC_CUR_DOC,
                                          NDOC_QUANT_PLAN_ALT => CNTR_DOC.NQUANT_ALT_MOVE_EXEC_CUR_DOC,
                                          NRN_REF             => NRN_DST,
                                          nsign_check         => 0,
                                          NRN                 => NRN_CNTR_DOC);
          end if;
          /*1. Заказы поставщикам*/
          if (CNTR_DOC.DOC_UNITCODE = 'DeliveryOrdersSpec') then
            /*Регистрационный номер записи документа*/
            begin
              select S.PRN
                into NRN_DOC
                from DELIVERYORDS S
               where S.RN = CNTR_DOC.DOC_RN
                 and S.COMPANY = NCOMPANY;
            exception
              when NO_DATA_FOUND then
                PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => CNTR_DOC.DOC_RN,
                                         SUNIT_TABLE => 'DeliveryOrdersSpec');
            end;
            /*Количество связей*/
            select count(1)
              into NCOUNT_LINKS
              from DOCLINKS L
             where L.IN_DOCUMENT = NPRN_DST
               and L.IN_UNITCODE = 'BuyPlaneSpecs'
               and L.OUT_DOCUMENT = NRN_DOC
               and L.OUT_UNITCODE = 'DeliveryOrders';
            /*Выполняем установку связи строки плана закупок с заказом поставщику*/
            if (NCOUNT_LINKS = 0) then
              PKG_DOCLINKS.LINK(NFLAG_SMART   => 0,
                                NCOMPANY      => NCOMPANY,
                                SIN_UNITCODE  => 'BuyPlaneSpecs',
                                NIN_DOCUMENT  => NPRN_DST,
                                SOUT_UNITCODE => 'DeliveryOrders',
                                NOUT_DOCUMENT => NRN_DOC);
            end if;
            /*Количество связей*/
            select count(1)
              into NCOUNT_LINKS
              from DOCLINKS L
             where L.IN_DOCUMENT = NBP_DST
               and L.IN_UNITCODE = 'BuyPlanes'
               and L.OUT_DOCUMENT = NRN_DOC
               and L.OUT_UNITCODE = 'DeliveryOrders';
            /*Выполняем установку связи плана закупок с заказом поставщику*/
            if (NCOUNT_LINKS = 0) then
              PKG_DOCLINKS.LINK(NFLAG_SMART   => 0,
                                NCOMPANY      => NCOMPANY,
                                SIN_UNITCODE  => 'BuyPlanes',
                                NIN_DOCUMENT  => NBP_DST,
                                SOUT_UNITCODE => 'DeliveryOrders',
                                NOUT_DOCUMENT => NRN_DOC);
            end if;
          else
            P_EXCEPTION(0,
                        'Не удалось определить алгоритм расчета переброски для раздела ' ||
                        CNTR_DOC.DOC_UNITCODE);
          end if;
          /*Переброшенное количество в ОЕИ*/
          NQUANT_MOVE_EXEC := NQUANT_MOVE_EXEC +
                              CNTR_DOC.NQUANT_MOVE_EXEC_CUR;
          /*Переброшенное количество в ДЕИ*/
          NQUANT_ALT_MOVE_EXEC := NQUANT_ALT_MOVE_EXEC +
                                  CNTR_DOC.NQUANT_ALT_MOVE_EXEC_CUR;
        end if;
      end if;
    end loop;
    if (CMP_NUM(NQUANT_MOVE_EXEC, NQUANT_MOVE) = 0) then
      P_EXCEPTION(0,
                  'Не удалось выполнить перенос информации о контрактации. Обратитесь к администратору в службу ИТ');
    end if;
    if (CMP_NUM(NQUANT_ALT_MOVE_EXEC, NQUANT_ALT_MOVE) = 0) then
      P_EXCEPTION(0,
                  'Не удалось выполнить перенос информации о контрактации. Обратитесь к администратору в службу ИТ');
    end if;
  end P_BUYPLANESPREF_MOVE_CNTR;

  /*Функция возвращает дату выпуска для указанного заказа подразделений*/
  function f_departmentord_calc_rel_date(nrn in number /*Регистрационный номер записи*/)
    return date is
  
    ddate date;
  
  begin
    select min(P.RELEASE_DATE)
      into ddate
      from DOCLINKS L, FCPREXPACT ACT, DOCLINKS LA, PRODUCTORD P
     where L.OUT_DOCUMENT = nrn
       and L.OUT_UNITCODE = 'DepartmentsOrders'
       and L.IN_UNITCODE = 'CostProductExpenseActs'
       and L.IN_DOCUMENT = ACT.RN
       and LA.OUT_UNITCODE = 'CostProductExpenseActs'
       and LA.OUT_DOCUMENT = ACT.RN
       and LA.IN_UNITCODE = 'ProductionOrders'
       and LA.IN_DOCUMENT = P.RN;
  
    return(ddate);
  end f_departmentord_calc_rel_date;

  /*Процедура выполняет возврат разницы в план закупок*/
  procedure p_deliveryords_bret_diff_bp(ncompany in number /*Организация*/,
                                        nrn      in number /*Регистрационный номер записи*/) is
  
    /*Атрибуты записи спецификации заказа поставщику*/
    rsp deliveryords%rowtype;
  
    /*Количество в плане закупок*/
    NQUANT_BP     pkg_std.tQUANT;
    NQUANT_BP_ALT pkg_std.tQUANT;
  
    /*Возвращенное количество*/
    nquant_ret pkg_std.tQUANT;
  
    NCOUNT_LINKS number;
  
  begin
    /*Атрибуты записи спецификации заказа поставщику*/
    begin
      select s.*
        into rsp
        from deliveryords s
       where s.rn = nrn
         and s.company = ncompany;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DeliveryOrdersSpec');
    end;
  
    /*Количество в плане закупок*/
    P_DOCUMENT_CALC_QUANT_BP(NCOMPANY   => NCOMPANY,
                             SUNITCODE  => 'DeliveryOrdersSpec',
                             NRN        => NRN,
                             NQUANT     => NQUANT_BP,
                             NQUANT_ALT => NQUANT_BP_ALT);
  
    /*Выполняем проверку количества*/
    if (NQUANT_BP <= rsp.main_quant) then
      p_exception(0,
                  'Для номенклатуры ' ||
                  get_dicnomns_code_id(nFLAG_SMART => 0, nRN => rsp.nomen) ||
                  ' количество к возврату в план закупок отсутствует');
    end if;
  
    /*Возвращенное количество*/
    nquant_ret := 0;
  
    /*Цикл по строкам привязки к плану закупок*/
    for cntr_cursor in (select c.rn as nrn,
                               c.quant_plan as nquant_plan,
                               to_number(null) as nquant_ret,
                               s.rn as nrn_bp_sp,
                               s.prn as nrn_bp,
                               o.ord_pref,
                               o.ord_numb
                          from udo_uzd_03_buyplanesp_cntr_doc c,
                               buyplanespref                  r,
                               buyplanesp                     s,
                               departmentords                 dos,
                               departmentord                  o
                         where c.doc_rn = nrn
                           and c.doc_unitcode = 'DeliveryOrdersSpec'
                           and c.company = ncompany
                           and r.rn = c.rn_ref
                           and s.rn = c.prn
                           and dos.rn = r.deptordsp
                           and o.rn = dos.prn
                         order by prsg_prop.dget(nCOMPANY  => ncompany,
                                                 nVERSION  => to_number(null),
                                                 sUNITCODE => 'BuyPlaneSpecsReferences',
                                                 nDOCUMENT => c.rn_ref,
                                                 sPROPCODE => 'УМТС_ПланДатаПост'),
                                  nvl(f_departmentord_calc_rel_date(nrn => o.rn),
                                      o.ord_date),
                                  o.ord_pref,
                                  o.ord_numb,
                                  c.rn_ref) loop
      if (nquant_ret >= NQUANT_BP - rsp.main_quant) then
        cntr_cursor.nquant_ret := 0;
      else
        cntr_cursor.nquant_ret := least(cntr_cursor.nquant_plan,
                                        NQUANT_BP - rsp.main_quant -
                                        nquant_ret);
      end if;
    
      if (cntr_cursor.nquant_ret > 0) then
      
        if (cmp_num(cntr_cursor.nquant_ret, cntr_cursor.nquant_plan) = 1) then
        
          /*Выполняем удаление привязки*/
          P_BUYPLANESP_CNTR_DOC_Bdelete(nCOMPANY => ncompany,
                                        nRN      => cntr_cursor.nrn);
          select count(1)
            into NCOUNT_LINKS
            from udo_uzd_03_buyplanesp_cntr_doc c, deliveryords s
           where c.prn = cntr_cursor.nrn_bp_sp
             and c.doc_unitcode = 'DeliveryOrdersSpec'
             and c.doc_rn = s.rn
             and s.prn = rsp.prn;
          /*Выполняем удаление связи строки плана закупок с заказом поставщику*/
          if (NCOUNT_LINKS = 0) then
            PKG_DOCLINKS.remove(SIN_UNITCODE  => 'BuyPlaneSpecs',
                                NIN_DOCUMENT  => cntr_cursor.nrn_bp_sp,
                                SOUT_UNITCODE => 'DeliveryOrders',
                                NOUT_DOCUMENT => rsp.prn);
          end if;
          /*Количество связей*/
          select count(1)
            into NCOUNT_LINKS
            from buyplanesp                     bp_sp,
                 udo_uzd_03_buyplanesp_cntr_doc c,
                 deliveryords                   s
           where bp_sp.prn = cntr_cursor.nrn_bp
             and c.prn = bp_sp.rn
             and c.doc_unitcode = 'DeliveryOrdersSpec'
             and c.doc_rn = s.rn
             and s.prn = rsp.prn;
          /*Выполняем удаление связи плана закупок с заказом поставщику*/
          if (NCOUNT_LINKS = 0) then
            PKG_DOCLINKS.remove(SIN_UNITCODE  => 'BuyPlanes',
                                NIN_DOCUMENT  => cntr_cursor.nrn_bp,
                                SOUT_UNITCODE => 'DeliveryOrders',
                                NOUT_DOCUMENT => rsp.prn);
          end if;
        
        else
          /*Выполняем исправление количества привязки*/
          update UDO_UZD_03_BUYPLANESP_CNTR_DOC c
             set c.QUANT_PLAN     = c.QUANT_PLAN - cntr_cursor.nquant_ret,
                 c.DOC_QUANT_PLAN = c.DOC_QUANT_PLAN -
                                    cntr_cursor.nquant_ret
           where c.RN = cntr_cursor.nrn
             and c.COMPANY = NCOMPANY;
          if (sql%notfound) then
            PKG_MSG.RECORD_NOT_FOUND(NDOCUMENT   => cntr_cursor.nrn,
                                     SUNIT_TABLE => 'BuyPlaneSpecsCntrDoc');
          end if;
        
        end if;
      
        /*Возвращенное количество*/
        nquant_ret := nquant_ret + cntr_cursor.nquant_ret;
      
      end if;
    end loop;
  
    /*Выполняем проверку возвращенного количества*/
    if (cmp_num(nquant_ret, NQUANT_BP - rsp.main_quant) = 0) then
      p_exception(0,
                  'При расчете количества к возврату возникла ошибка. Обратитесь к администратору' ||
                  to_char(nquant_ret));
    end if;
  
    /* Формирование Строки калькуляции*/
    udo_p_deliveryordcs_genrec(ncompany => ncompany, nrn => nrn);
  end p_deliveryords_bret_diff_bp;

  /*Процедура выполняет возврат разницы в план закупок*/
  procedure p_deliveryords_ret_diff_bp(ncompany in number /*Организация*/,
                                       nrn      in number /*Регистрационный номер записи*/) is
  
    /*Каталог*/
    ncrn pkg_std.tREF;
  
  begin
  
    /*Выполняем проверку существования строки заказа поставщику*/
    p_deliveryords_exists(nCOMPANY => ncompany, nRN => nrn, nCRN => ncrn);
  
    /* пролог */
    PKG_ENV.PROLOGUE(nCOMPANY,
                     null,
                     ncrn,
                     'DeliveryOrdersSpec',
                     'DeliveryOrdersSpecReturnDiffBP',
                     'DELIVERYORDS',
                     nRN);
  
    /*Выполняем базовый возврат разницы в план закупок*/
    p_deliveryords_bret_diff_bp(ncompany => ncompany, nrn => nrn);
  
    /* эпилог */
    PKG_ENV.EPILOGUE(nCOMPANY,
                     null,
                     ncrn,
                     'DeliveryOrdersSpec',
                     'DeliveryOrdersSpecReturnDiffBP',
                     'DELIVERYORDS',
                     nRN);
  
  end p_deliveryords_ret_diff_bp;

  /*Процедура выполняет базовое аннулирование позиции заказа поставщику*/
  procedure p_deliveryords_bcancel(ncompany in number /*Организация*/,
                                   nrn      in number /*Регистрационный номер записи*/,
                                   ddate    in date /*Дата аннулирования*/) is
  
    nord_state number;
  
  begin
    if (prsg_prop.DGET(nCOMPANY  => NCOMPANY,
                       nVERSION  => to_number(null),
                       sUNITCODE => 'DeliveryOrdersSpec',
                       nDOCUMENT => nrn,
                       sPROPCODE => 'УМТС_ДатаАннулирован') is not null) then
      p_exception(0,
                  'Позиция заказа поставщику уже аннулирована');
    end if;
  
    begin
      select o.ord_state
        into nord_state
        from deliveryords s, deliveryord o
       where s.rn = nrn
         and s.company = ncompany
         and o.rn = s.prn;
    exception
      when no_data_found then
        pkg_msg.RECORD_NOT_FOUND(nDOCUMENT   => nrn,
                                 sUNIT_TABLE => 'DeliveryOrdersSpec');
    end;
  
    if (nord_state <> 1) then
      p_exception(0,
                  'Состояние документа отлично от "Утвержден"');
    end if;
    prsg_prop.VSET(sUNITCODE  => 'DeliveryOrdersSpec',
                   nDOCUMENT  => nrn,
                   sPROPCODE  => 'УМТС_ДатаАннулирован',
                   sstrvalue  => to_char(null),
                   nnumvalue  => to_number(null),
                   dDATEVALUE => ddate);
  end p_deliveryords_bcancel;

  /*Процедура выполняет базовую отмену аннулирования позиции заказа поставщику*/
  procedure p_deliveryords_bcancel_cancel(ncompany in number /*Организация*/,
                                          nrn      in number /*Регистрационный номер записи*/) is
  begin
    if (prsg_prop.DGET(nCOMPANY  => NCOMPANY,
                       nVERSION  => to_number(null),
                       sUNITCODE => 'DeliveryOrdersSpec',
                       nDOCUMENT => nrn,
                       sPROPCODE => 'УМТС_ДатаАннулирован') is null) then
      p_exception(0,
                  'Позиция заказа поставщику еще не аннулирована');
    end if;
  
    prsg_prop.VSET(sUNITCODE  => 'DeliveryOrdersSpec',
                   nDOCUMENT  => nrn,
                   sPROPCODE  => 'УМТС_ДатаАннулирован',
                   sstrvalue  => to_char(null),
                   nnumvalue  => to_number(null),
                   dDATEVALUE => to_date(null));
  end p_deliveryords_bcancel_cancel;

  /*Процедура выполняет аннулирование позиции заказа поставщику*/
  procedure p_deliveryords_cancel(ncompany in number /*Организация*/,
                                  nrn      in number /*Регистрационный номер записи*/,
                                  ddate    in date /*Дата аннулирования*/) is
  
    /*Каталог*/
    ncrn pkg_std.tREF;
  
  begin
  
    /*Выполняем проверку существования строки заказа поставщику*/
    p_deliveryords_exists(nCOMPANY => ncompany, nRN => nrn, nCRN => ncrn);
  
    /* пролог */
    PKG_ENV.PROLOGUE(nCOMPANY,
                     null,
                     ncrn,
                     'DeliveryOrdersSpec',
                     'DeliveryOrdersSpecCancel',
                     'DELIVERYORDS',
                     nRN);
  
    /*Выполняем базовое аннулирование позиции заказа поставщику*/
    p_deliveryords_bcancel(ncompany => ncompany,
                           nrn      => nrn,
                           ddate    => ddate);
  
    /* эпилог */
    PKG_ENV.EPILOGUE(nCOMPANY,
                     null,
                     ncrn,
                     'DeliveryOrdersSpec',
                     'DeliveryOrdersSpecCancel',
                     'DELIVERYORDS',
                     nRN);
  
  end p_deliveryords_cancel;

  /*Процедура выполняет отмену аннулирования позиции заказа поставщику*/
  procedure p_deliveryords_cancel_cancel(ncompany in number /*Организация*/,
                                         nrn      in number /*Регистрационный номер записи*/) is
  
    /*Каталог*/
    ncrn pkg_std.tREF;
  
  begin
  
    /*Выполняем проверку существования строки заказа поставщику*/
    p_deliveryords_exists(nCOMPANY => ncompany, nRN => nrn, nCRN => ncrn);
  
    /* пролог */
    PKG_ENV.PROLOGUE(nCOMPANY,
                     null,
                     ncrn,
                     'DeliveryOrdersSpec',
                     'DeliveryOrdersSpecCancelCancel',
                     'DELIVERYORDS',
                     nRN);
  
    /*Выполняем базовую отмену аннулирования позиции заказа поставщику*/
    p_deliveryords_bcancel_cancel(ncompany => ncompany, nrn => nrn);
  
    /* эпилог */
    PKG_ENV.EPILOGUE(nCOMPANY,
                     null,
                     ncrn,
                     'DeliveryOrdersSpec',
                     'DeliveryOrdersSpecCancelCancel',
                     'DELIVERYORDS',
                     nRN);
  
  end p_deliveryords_cancel_cancel;

begin
  -- Initialization
  null;
end udo_pkg_umts_02_cntr;
/
