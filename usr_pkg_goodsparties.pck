create or replace package USR_PKG_GOODSPARTIES is
  /*
  Степанов М. 31/08/2022
  Package предназначен для работы с разделом "Приходные партии товара". 
  GoodsParties                GOODSPARTIES      GP
  GoodsSupply                 GOODSSUPPLY       GS
  GoodsSupplyStoredArticles   ARTICLESSUPPLY    GSSA
  IncomingDocuments           INCOMDOC          IDC
  */
  --#########################################################################################################

  function GOODSPARTIES_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return goodsparties%rowtype;
  --#########################################################################################################

  function GOODSPARTIES_GET_CODE
  /*
  Заголовок. Получить код партии
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return varchar2;
  --#########################################################################################################

  procedure GOODSPARTIES_GET_FULL
  /*
  Заголовок. Поиск полный (возвращает запись)
  */
  (
   nFLAGSMART         in number   default 0
  ,nCOMPANY           in number
  ,sINDOC             in varchar2
  ,sSERNUMB           in varchar2 default null
  ,nSERCH_FLAG        in number   default 1 /* 0 - по коду 1 - по серийному номеру*/
  ,sNOMEN             in varchar2
  ,sNOMMODIF          in varchar2
  ,rV_GOODSPARTIES    out v_goodsparties%rowtype
  );
  --#########################################################################################################

  procedure GOODSPARTIES_GET_FULL
  /*
  Заголовок. Поиск полный (возвращает RN)
  */
  (
   nFLAGSMART         in number   default 0
  ,nCOMPANY           in number
  ,sINDOC             in varchar2
  ,sSERNUMB           in varchar2 default null
  ,nSERCH_FLAG        in number   default 1 /* 0 - по коду 1 - по серийному номеру*/
  ,sNOMEN             in varchar2
  ,sNOMMODIF          in varchar2
  ,nRN                out number
  );
  --#########################################################################################################

  procedure GOODSPARTIES_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSPARTIES_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSPARTIES_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSPARTIES_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSPARTIES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSPARTIES_BASE_INSERT
  /*
  Заголовок. Базовое добавление
  */
  (
   rROW             in goodsparties%rowtype
  ,nRN              out number
  );
  --#########################################################################################################

  procedure GOODSPARTIES_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW             in goodsparties%rowtype
  ,nMODE            in number default 1  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure GOODSPARTIES_GET_IIVS_IFDS_PRP
  /*
  Получение значений свойств спецификаций приходных накладных и приходных ордеров
  */
  (
   nRN          in number
  ,nFLAGSMART   in number 
  ,nDOCS_PROPS  in number  /* RN доп.свойства */
  ,sRESULT     out varchar2
  ,nOTHERS     out number   
  );
  --#########################################################################################################

  function GOODSPARTIES_GET_IIVS_IFDS_PRP
  /*
  Получение значений свойств спецификаций приходных накладных и приходных ордеров
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 1
  ,nDOCS_PROPS  in number  /* RN доп.свойства */
  ) 
  return varchar2;
  --#########################################################################################################

  procedure GOODSPARTIES_GET_INDOCS_DATA
  /*
  Получение данных приходных документов
  */
  (
   sSERNUMB       in varchar2
  ,nFLAGSMART     in number default 0
  ,nTOO_MANY_ROWS in number default 0
  ,sPARAMS        in varchar2 default null /* Список возвращаемых параметров через ";" */
  ,nGP            out number  /* Приходная партия */ 
  ,nIO            out number  /* Приходный ордер */ 
  ,nIOS           out number  /* Приходный ордер. Спецификация */  
  ,nIIV           out number  /* Приходная накданая */   
  ,nIIVS          out number  /* Приходная накданая. Спецификация */    
  ,nPAI           out number  /* Входящий счёт */    
  ,nPAIS          out number  /* Входящий счёт. Спецификация */    
  ,nCE            out number  /* Входящий счёт. Событие */    
  ,nAL            out number  /* Входящий счёт. Контрагент-инициатор */    
  );
  --#########################################################################################################

  function GOODSPARTIES_GET_INDOCS_DATA
  /*
  Получение данных приходных документов
  */
  (
   sSERNUMB         in varchar2
  ,nFLAGSMART       in number default 1
  ,nTOO_MANY_ROWS   in number default 1
  ,sPARAM           in varchar2   /* Возвращаемый  параметр процедуры. Только один */
  ) 
  return number;
  --#########################################################################################################

  function GOODSSUPPLY_GET
  /*
  Спецификация. Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return goodssupply%rowtype;
  --#########################################################################################################

  procedure GOODSSUPPLY_GET_BY_GSSA
  /*
  Спецификация. Поиск по товарному запасу изделия на складе
  */
  (
   nFLAGSMART in number
  ,nGSSA      in number /* Товарный запас изделия на складе. RN */
  ,nCOMPANY   in number
  ,nRN        out number
  );
  --#########################################################################################################

  function GOODSSUPPLY_GET_REST_BY_RN
  /*
  Спецификация. Поиск остатков по RN 
  */
  (
   nFLAGSMART   in number
  ,nRN          in number
  ,nCOMPANY     in number
  ,dDATE        in date
  ,sRES_TYPE    in varchar2 /*'RESTFACT', 'RESTFACTALT', 'RESERV', 'RESERVALT', 'SALE', 'SALEALT' */
  ) 
  return pkg_std.tlquant;
  --#########################################################################################################

  procedure GOODSSUPPLY_GET_FULL
  /*
  Спецификация. Поиск по RN или мнемокодам Приходной партии и Товарного запаса. 
  Возвращает их записи, заполненные считанными значениями
  */
  (
   nFLAGSMART       in number   default 0
  ,nCOMPANY         in number   default null
  ,nGOODSSUPPLY     in number   default null  /* Если искать только по RN товарного запаса */
  ,sINDOC           in varchar2 default null
  ,sNOMEN_CODE      in varchar2 default null
  ,sNOMMODIF_CODE   in varchar2 default null
  ,sSERNUMB         in varchar2 default null
  ,sCOUNTRY         in varchar2 default null
  ,sGTD             in varchar2 default null
  ,sSTORE           in varchar2 default null
  ,dDATE            in date     default null
  ,rV_GOODSPARTIES  out v_goodsparties%rowtype
  ,rV_GOODSSUPPLY   out v_goodssupply%rowtype
  );
  --#########################################################################################################

  procedure GOODSSUPPLY_GET_FULL
  /*
  Спецификация. Поиск по мнемокодам Приходной партии и Товарного запаса. 
  Возвращает только их RN
  */
  (
   nFLAGSMART       in number   default 0
  ,nCOMPANY         in number   default null
  ,sINDOC           in varchar2 default null
  ,sNOMEN_CODE      in varchar2 default null
  ,sNOMMODIF_CODE   in varchar2 default null
  ,sSERNUMB         in varchar2 default null
  ,sCOUNTRY         in varchar2 default null
  ,sGTD             in varchar2 default null
  ,sSTORE           in varchar2 default null
  ,dDATE            in date     default null
  ,nRN              out number
  ,nPRN             out number
  );
  --#########################################################################################################

  procedure GOODSSUPPLY_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSSUPPLY_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSSUPPLY_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSSUPPLY_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSSUPPLY_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSSUPPLY_BASE_UPDATE
  /*
  Спецификация. Базовое исправление
  */
  (
   rROW                 in goodssupply%rowtype
  );
  --#########################################################################################################

  procedure GOODSSUPPLY_RECALC
  /*
  Спецификация. Пересчёт данных. По мотивам P_GOODSSUPPLYHIST_BASE_FORMING
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  );
  --#########################################################################################################

  function GOODSSUPPLYCLC_GET
  /*
  Спецификация (калькуляция затрат) Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return goodssupplyclc%rowtype;
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_AINSERT
  /*
  Спецификация (калькуляция затрат) Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_BUPDATE
  /*
  Спецификация (калькуляция затрат) Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_AUPDATE
  /*
  Спецификация (калькуляция затрат) Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_BDELETE
  /*
  Спецификация (калькуляция затрат) Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_CHECK_BASE
  /*
  Спецификация (калькуляция затрат) Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_BASE_INSERT
  /*
  Спецификация (калькуляция затрат) Базовое исправление
  */
  (
   rROW                 in goodssupplyclc%rowtype
  ,nRN                  out number
  );
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_BASE_UPDATE
  /*
  Спецификация (калькуляция затрат) Базовое исправление
  */
  (
   rROW                 in goodssupplyclc%rowtype
  );
  --#########################################################################################################

  function ARTICLESSUPPLY_GET
  /*
  Изделия на складе. Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return articlessupply%rowtype;
  --#########################################################################################################

  function INCOMDOC_GET
  /*
  Партии товара. Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return incomdoc%rowtype;
  --#########################################################################################################

  procedure INCOMDOC_GET_FULL
  /*
  Партии товара. Поиск полный (возвращает запись)
  */
  (
   nFLAGSMART         in number   default 0
  ,nFLAG_OPTION       in number   default 0  /* признак генерации исключения для пустого sCODE и RN (0 - да, 1 - нет) */
  ,nCOMPANY           in number
  ,sCODE              in varchar2 default null
  ,nRN                in number default null
  ,rV_INCOMDOC        out v_incomdoc%rowtype
  );
  --#########################################################################################################

  procedure INCOMDOC_GET_FULL
  /*
  Партии товара. Поиск полный (возвращает запись)
  */
  (
   nFLAGSMART         in number   default 0
  ,nFLAG_OPTION       in number   default 0  /* признак генерации исключения для пустого sCODE и RN (0 - да, 1 - нет) */
  ,nCOMPANY           in number
  ,sCODE              in varchar2 default null
  ,nRN                out number
  );
  --#########################################################################################################
  
end USR_PKG_GOODSPARTIES;
/
create or replace package body USR_PKG_GOODSPARTIES is

  --#########################################################################################################

  function GOODSPARTIES_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return goodsparties%rowtype
  is
    rRow goodsparties%rowtype;
  begin
    begin
      select * into rRow from goodsparties where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'GOODSPARTIES');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'GOODSPARTIES')));
    end;
    return(rRow);
  end GOODSPARTIES_GET;
  --#########################################################################################################

  function GOODSPARTIES_GET_CODE
  /*
  Заголовок. Получить код партии
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return varchar2
  is
    sCode   incomdoc.code%type;
  begin
    begin
      select icd.code
        into sCode 
        from goodsparties gp
            ,incomdoc     icd
       where gp.rn  = nRN
         and icd.rn = gp.indoc ;
    exception
      when no_data_found then
        pkg_msg.record_not_found( nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'GOODSPARTIES' );
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname( sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'GOODSPARTIES' ) ) );
    end;
    
    return( sCode );
    
  end GOODSPARTIES_GET_CODE;
  --#########################################################################################################

  procedure GOODSPARTIES_GET_FULL
  /*
  Заголовок. Поиск полный (возвращает запись)
  */
  (
   nFLAGSMART         in number   default 0
  ,nCOMPANY           in number
  ,sINDOC             in varchar2
  ,sSERNUMB           in varchar2 default null
  ,nSERCH_FLAG        in number   default 1 /* 0 - по коду 1 - по серийному номеру*/
  ,sNOMEN             in varchar2
  ,sNOMMODIF          in varchar2
  ,rV_GOODSPARTIES    out v_goodsparties%rowtype
  ) 
  is
  begin
    find_goodsparties_full(nflag_smart        => nFLAGSMART
                          ,ncompany           => nCOMPANY
                          ,sindoc             => sINDOC
                          ,ssernumb           => sSERNUMB
                          ,nserch_flag        => nSERCH_FLAG
                          ,snomen             => sNOMEN
                          ,snommodif          => sNOMMODIF
                          ,snommodifpack      => null
                          ,sout_indoc         => rV_GOODSPARTIES.SCODE
                          ,dout_expiry_date   => rV_GOODSPARTIES.DEXPIRY_DATE
                          ,sout_certificate   => rV_GOODSPARTIES.SCERTIFICATE
                          ,nout_signbreak     => rV_GOODSPARTIES.NSIGNBREAK
                          ,sout_sernumb       => rV_GOODSPARTIES.SSERNUMB
                          ,sout_barcode       => rV_GOODSPARTIES.SBARCODE
                          ,sout_country       => rV_GOODSPARTIES.SCOUNTRY
                          ,sout_gtd           => rV_GOODSPARTIES.SGTD
                          ,sout_producer      => rV_GOODSPARTIES.SPRODUCER
                          ,nout_storage_time  => rV_GOODSPARTIES.NSTORAGE_TIME
                          ,sout_umeas_storage => rV_GOODSPARTIES.SUMEAS_STORAGE
                          ,sout_original_name => rV_GOODSPARTIES.SORIGINAL_NAME
                          ,dout_prod_date     => rV_GOODSPARTIES.DPROD_DATE
                          ,nrn                => rV_GOODSPARTIES.NRN);
  end GOODSPARTIES_GET_FULL;
  --#########################################################################################################

  procedure GOODSPARTIES_GET_FULL
  /*
  Заголовок. Поиск полный (возвращает RN)
  */
  (
   nFLAGSMART         in number   default 0
  ,nCOMPANY           in number
  ,sINDOC             in varchar2
  ,sSERNUMB           in varchar2 default null
  ,nSERCH_FLAG        in number   default 1 /* 0 - по коду 1 - по серийному номеру*/
  ,sNOMEN             in varchar2
  ,sNOMMODIF          in varchar2
  ,nRN                out number
  ) 
  is
    rV_GoodsParties    v_goodsparties%rowtype;
  begin
    /* Поиск */
    goodsparties_get_full(nflagsmart      => nFLAGSMART
                         ,ncompany        => nCOMPANY
                         ,sindoc          => sINDOC
                         ,ssernumb        => sSERNUMB
                         ,nserch_flag     => nSERCH_FLAG
                         ,snomen          => sNOMEN
                         ,snommodif       => sNOMMODIF
                         ,rv_goodsparties => rV_GoodsParties);
    /* Результат */
    nRN := rV_GoodsParties.nrn;                        

  end GOODSPARTIES_GET_FULL;
  --#########################################################################################################

  procedure GOODSPARTIES_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            goodsparties%rowtype;
  begin
    /* Считывание
     rRow := GOODSPARTIES_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    goodsparties_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end GOODSPARTIES_AINSERT;
  --#########################################################################################################

  procedure GOODSPARTIES_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end GOODSPARTIES_BUPDATE;
  --#########################################################################################################

  procedure GOODSPARTIES_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     goodsparties%rowtype;
  begin
    /* Считывание
     rRow := goodsparties_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    goodsparties_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end GOODSPARTIES_AUPDATE;
  --#########################################################################################################

  procedure GOODSPARTIES_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end GOODSPARTIES_BDELETE;
  --#########################################################################################################

  procedure GOODSPARTIES_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     goodsparties%rowtype;
  begin
    null;
    /* Заголовок */  
    /* rRow := goodsparties_get(nrn => nRN); */
    
  end GOODSPARTIES_CHECK_BASE;
  --#########################################################################################################

  procedure GOODSPARTIES_BASE_INSERT
  /*
  Заголовок. Базовое добавление
  */
  (
   rROW             in goodsparties%rowtype
  ,nRN              out number
  ) 
  is 
  begin
    p_goodsparties_base_insert(ncompany       => rROW.COMPANY
                              ,nindoc         => rROW.INDOC
                              ,nnommodif      => rROW.NOMMODIF
                              ,nnomnmodifpack => rROW.NOMNMODIFPACK
                              ,nsignbreak     => rROW.SIGNBREAK
                              ,dexpiry_date   => rROW.EXPIRY_DATE
                              ,scertificate   => rROW.CERTIFICATE
                              ,ssernumb       => rROW.SERNUMB
                              ,sbarcode       => rROW.BARCODE
                              ,ncountry       => rROW.COUNTRY
                              ,sgtd           => rROW.GTD
                              ,nproducer      => rROW.PRODUCER
                              ,nstorage_time  => rROW.STORAGE_TIME
                              ,numeas_storage => rROW.UMEAS_STORAGE
                              ,soriginal_name => rROW.ORIGINAL_NAME
                              ,dprod_date     => rROW.PROD_DATE
                              ,nrn            => nRN);

  end GOODSPARTIES_BASE_INSERT;
  --#########################################################################################################

  procedure GOODSPARTIES_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW             in goodsparties%rowtype
  ,nMODE            in number default 1  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is 
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_goodsparties_base_update(ncompany       => rROW.COMPANY
                                ,nrn            => rROW.RN
                                ,nsignbreak     => rROW.SIGNBREAK
                                ,dexpiry_date   => rROW.EXPIRY_DATE
                                ,scertificate   => rROW.CERTIFICATE
                                ,sbarcode       => rROW.BARCODE
                                ,nproducer      => rROW.PRODUCER
                                ,nstorage_time  => rROW.STORAGE_TIME
                                ,numeas_storage => rROW.UMEAS_STORAGE);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_goodsparties_base_update(ncompany       => rROW.COMPANY
                                ,nrn            => rROW.RN
                                ,nsignbreak     => rROW.SIGNBREAK
                                ,dexpiry_date   => rROW.EXPIRY_DATE
                                ,scertificate   => rROW.CERTIFICATE
                                ,sbarcode       => rROW.BARCODE
                                ,nproducer      => rROW.PRODUCER
                                ,nstorage_time  => rROW.STORAGE_TIME
                                ,numeas_storage => rROW.UMEAS_STORAGE);
      update goodsparties 
         set original_name  = rROW.ORIGINAL_NAME
            ,prod_date      = rROW.PROD_DATE
       where rn       = rROW.RN
         and company  = rROW.COMPANY;
      if SQL%NOTFOUND then
        pkg_msg.record_not_found( rROW.RN,'GoodsParties' );
      end if;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
    
  end GOODSPARTIES_BASE_UPDATE;
  --#########################################################################################################

  procedure GOODSPARTIES_GET_IIVS_IFDS_PRP
  /*
  Получение значений свойств спецификаций приходных накладных и приходных ордеров
  */
  (
   nRN          in number
  ,nFLAGSMART   in number 
  ,nDOCS_PROPS  in number  /* RN доп.свойства */
  ,sRESULT     out varchar2
  ,nOTHERS     out number   
  ) 
  is
  begin
    /* Инициализация */
    nOTHERS := 0;

    /* Проверка  */
    /* Не задан RN */
    if NRN is null then 
      p_exception(nFLAGSMART, 'Не задан RN.'); 
      nOTHERS := 1;
      return;
    end if;

    /* Дата производства, Партия поставщика, Дата перепроверки, ПРИЕМКА */
    if nDOCS_PROPS not in (12114824, 69192082, 134301298, 8027724) then 
      p_exception(nFLAGSMART, 'Недопустимое значение RN доп.свойства <%s>.', nDOCS_PROPS); 
      nOTHERS := 1;
      return;
    end if;
    
    /* Значение свойства из Приходной партии */
    sRESULT := usr_pkg_docs_props_vals.get_val_str( ndoc_prop => nDOCS_PROPS, ndocument => NRN );

    /* Приходные ордера */
    if sRESULT is null then
      begin
        select gpv.str_value
          into sRESULT
          from inorderspecs     isp
              ,goodsparties     gp
              ,docs_props_vals  gpv
         where gp.rn             = nRN
           and trim(isp.sernumb) = nvl(gp.sernumb, '9999999999')
           and isp.nommodif      = gp.nommodif
           and gpv.docs_prop_rn  = nDOCS_PROPS
           and gpv.unit_rn       = isp.rn
           and rownum            < 2;
      exception
        when no_data_found then
          sRESULT := to_char(null);
        when others then
          sRESULT := to_char(null);
          nOTHERS := 1;
          p_exception(nFLAGSMART, 'Неопределённая ситуация при поиске значения RN доп.свойства <%s>.', nDOCS_PROPS); 
      end;
    end if;

    /* Приход из подразделений */
    if sRESULT is null then
      begin
        select gpv.str_value
          into sRESULT
          from goodsparties       gp
              ,goodssupply        gs
              ,incomefromdepsspec isp
              ,incomefromdeps     i
              ,azsgsmwaystypes    ds
              ,docs_props_vals    gpv
         where gp.rn             = NRN
           and gs.prn            = gp.rn
           and isp.supply        = gs.rn
           and i.rn              = isp.prn
           and ds.rn             = i.store_oper
           and ds.gsmways_type   = 1
           and gpv.docs_prop_rn  = nDOCS_PROPS
           and gpv.unit_rn       = isp.rn;
      exception
        when no_data_found then
          sRESULT := to_char(null);
        when others then
          sRESULT := to_char(null);
          nOTHERS := 1;
          p_exception(nFLAGSMART, 'Неопределённая ситуация при поиске значения RN доп.свойства <%s>.', nDOCS_PROPS); 
      end;
    end if;

    /* Для старых поставок - из таблицы по 1С (только для свойства Дата производства) */
    if sRESULT is null 
    and nDOCS_PROPS = 12114824 then
      begin
        select substr(ms.prod_date, 1, 200)
          into sRESULT
          from udo_nomodif_series ms
         where ms.series = (select nvl(gp.sernumb, '9999999999') from goodsparties gp where gp.rn = nRN)
           and rownum    < 2;
      exception
        when no_data_found then
          sRESULT := to_char(null);
        when others then
          sRESULT := to_char(null);
          nOTHERS := 1;
          p_exception(nFLAGSMART, 'Неопределённая ситуация при поиске значения RN доп.свойства <%s>.', nDOCS_PROPS); 
      end;
    end if;
    
  end GOODSPARTIES_GET_IIVS_IFDS_PRP;  
  --#########################################################################################################

  function GOODSPARTIES_GET_IIVS_IFDS_PRP
  /*
  Получение значений свойств спецификаций приходных накладных и приходных ордеров
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 1
  ,nDOCS_PROPS  in number  /* RN доп.свойства */
  ) 
  return varchar2
  is
    sRes      docs_props_vals.str_value%type;
    nNumber   pkg_std.tnumber; 
  begin
    goodsparties_get_iivs_ifds_prp(nrn         => nRN
                                  ,nflagsmart  => nFLAGSMART
                                  ,ndocs_props => nDOCS_PROPS
                                  ,sresult     => sRes
                                  ,nothers     => nNumber);
    return(sRes);

  end GOODSPARTIES_GET_IIVS_IFDS_PRP;
  --#########################################################################################################

  procedure GOODSPARTIES_GET_INDOCS_DATA
  /*
  Получение данных приходных документов
  */
  (
   sSERNUMB       in varchar2
  ,nFLAGSMART     in number   default 0
  ,nTOO_MANY_ROWS in number   default 0
  ,sPARAMS        in varchar2 default null /* Список возвращаемых параметров через ";" */
  ,nGP            out number  /* Приходная партия */ 
  ,nIO            out number  /* Приходный ордер */ 
  ,nIOS           out number  /* Приходный ордер. Спецификация */  
  ,nIIV           out number  /* Приходная накданая */   
  ,nIIVS          out number  /* Приходная накданая. Спецификация */    
  ,nPAI           out number  /* Входящий счёт */    
  ,nPAIS          out number  /* Входящий счёт. Спецификация */    
  ,nCE            out number  /* Входящий счёт. Событие */    
  ,nAL            out number  /* Входящий счёт. Контрагент-инициатор */    
  ) 
  is
    rInInvoicesSpecs    ininvoicesspecs%rowtype;
  begin
    /* Приходная накладная. Спецификация */
    begin
      select t.*
        into rInInvoicesSpecs
        from udo_sernumb_list   snl
            ,ininvoicesspecs    t
       where snl.sernumb  = sSERNUMB
         and t.rn         = snl.document;
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Не найден документ для серии <%s> в разделе <%s>.'
                   ,sSERNUMB, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'ININVOICESSPECS')));
      when too_many_rows then
        if nFLAGSMART = 0 then
          p_exception(nTOO_MANY_ROWS, 'Найдено больше одного документ для серии <%s> в разделе <%s>.'
                     ,sSERNUMB, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'ININVOICESSPECS')));
        end if;
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске документа для серии <%s> в разделе <%s>.'
                   ,sSERNUMB, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'ININVOICESSPECS')));
    end;
    /* Если возвращать данные приходных накладных */
    if usr_pkg_common.is_lists_intersect(upper('nIIV;nIIVS'), upper(sPARAMS)) 
    or sPARAMS is null then 
      nIIV  := rInInvoicesSpecs.prn;
      nIIVS := rInInvoicesSpecs.rn;
    end if;

    /* Если возвращать данные приходных ордеров */
    if usr_pkg_common.is_lists_intersect(upper('nGP;nIO;nIOS'), upper(sPARAMS)) 
    or sPARAMS is null then 
      /* Приходный ордер и спецификация */
      begin
        select ios.prn, ios.rn, ios.gp_rn
          into nIO    , nIOS  , nGP
          from doclinks dl
              ,( select s.rn, s.prn, gp.sernumb, gp.rn as gp_rn
                   from inorderspecs s
                       ,goodssupply  gs
                       ,goodsparties gp
                  where s.goodssupply = gs.rn
                    and gs.prn        = gp.rn ) ios
         where dl.in_document   = rInInvoicesSpecs.prn
           and dl.out_document  = ios.prn
           and ios.sernumb      = sSERNUMB;
      exception
        when no_data_found then
          p_exception(nFLAGSMART, 'Не найден документ для серии <%s> в разделе <%s>.'
                     ,sSERNUMB, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'INORDERSPECS')));
        when too_many_rows then
          if nFLAGSMART = 0 then
            p_exception(nTOO_MANY_ROWS, 'Найдено больше одного документ для серии <%s> в разделе <%s>.'
                       ,sSERNUMB, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'INORDERSPECS')));
          end if;
        when others then
          p_exception(0, 'Неопределённая ситуация при поиске документа для серии <%s> в разделе <%s>.'
                     ,sSERNUMB, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'INORDERSPECS')));
      end;
    end if;

    /* Если возвращать данные входящих счетов */
    if usr_pkg_common.is_lists_intersect(upper('nPAI;nPAIS;nCE;nAL'), upper(sPARAMS)) 
    or sPARAMS is null then 
      /* Входящий счёт и спецификация */
      begin
        select t.prn, t.rn
          into nPAI , nPAIS
          from payaccinspec t
              ,doclinks        dl
         where dl.in_document  = t.prn
           and dl.out_document = rInInvoicesSpecs.prn
           and t.nommodif      = rInInvoicesSpecs.modif;
      exception
        when no_data_found then
          p_exception(nFLAGSMART, 'Не найден документ для серии <%s> в разделе <%s>.'
                     ,sSERNUMB, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACCINSPEC')));
        when too_many_rows then
          if nFLAGSMART = 0 then
            p_exception(nTOO_MANY_ROWS, 'Найдено больше одного документ для серии <%s> в разделе <%s>.'
                       ,sSERNUMB, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACCINSPEC')));
          end if;
        when others then
          p_exception(0, 'Неопределённая ситуация при поиске документа для серии <%s> в разделе <%s>.'
                     ,sSERNUMB, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PAYACCINSPEC')));
      end;
    end if;
  
    /* Если возвращать данные события входящего счёта */
    if usr_pkg_common.is_lists_intersect(upper('nCE;nAL'), upper(sPARAMS)) 
    or sPARAMS is null then 
      /* Событие входящего счёта и контрагент-инициатор */
      begin
        select ce.rn, al.rn
          into nCE, nAL
          from clnevents  ce
              ,clnpersons cp
              ,agnlist    al
         where ce.linked_rn   = nPAI
           and ce.init_person = cp.rn
           and cp.pers_agent  = al.rn;
      exception
        when no_data_found then
          p_exception(nFLAGSMART, 'Не найден документ для серии <%s> в разделе <%s>.'
                     ,sSERNUMB, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVENTS')));
        when too_many_rows then
          if nFLAGSMART = 0 then
            p_exception(nTOO_MANY_ROWS, 'Найдено больше одного документ для серии <%s> в разделе <%s>.'
                       ,sSERNUMB, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVENTS')));
          end if;
        when others then
          p_exception(0, 'Неопределённая ситуация при поиске документа для серии <%s> в разделе <%s>.'
                     ,sSERNUMB, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'CLNEVENTS')));
      end;
    end if;

  end GOODSPARTIES_GET_INDOCS_DATA;  
  --#########################################################################################################

  function GOODSPARTIES_GET_INDOCS_DATA
  /*
  Получение приходного ордера по серии
  */
  (
   sSERNUMB         in varchar2
  ,nFLAGSMART       in number default 1
  ,nTOO_MANY_ROWS   in number default 1
  ,sPARAM           in varchar2   /* Возвращаемый  параметр процедуры. Только один */
  ) 
  return number
  is
    nRef      pkg_std.tref; 
    nCount    pkg_std.tnumber := 0; 
    nGP       pkg_std.tref; 
    nIO       pkg_std.tref; 
    nIOS      pkg_std.tref; 
    nIIV      pkg_std.tref; 
    nIIVS     pkg_std.tref; 
    nPAI      pkg_std.tref; 
    nPAIS     pkg_std.tref; 
    nCE       pkg_std.tref; 
    nAL       pkg_std.tref; 

    nNumber   pkg_std.tnumber; 
  begin
    /* Проверка параметров */    
    select count(*) 
      into nCount
      from table(cast(udo_f_get_str_table(nflag_smart => 1, sparam_list => sPARAM) as udo_tp_strtable));

    if nCount != 1 then
      p_exception(0, 'Неверное количество <%s> значений в параметре <sPARAM>'); 
    end if;
        
    /* Процедура */
    goodsparties_get_indocs_data(ssernumb       => sSERNUMB
                                ,nflagsmart     => nFLAGSMART
                                ,ntoo_many_rows => nTOO_MANY_ROWS
                                ,sparams        => sPARAM
                                ,ngp            => nGP
                                ,nio            => nIO     
                                ,nios           => nIOS    
                                ,niiv           => nIIV    
                                ,niivs          => nIIVS   
                                ,npai           => nPAI    
                                ,npais          => nPAIS   
                                ,nce            => nCE     
                                ,nal            => nAL);
    return( case upper(sPARAM)
              when 'NGP'   then nGP  
              when 'NIO'   then nIO  
              when 'NIOS'  then nIOS 
              when 'NIIV'  then nIIV 
              when 'NIIVS' then nIIVS
              when 'NPAI'  then nPAI 
              when 'NPAIS' then nPAIS
              when 'NCE'   then nCE  
              when 'NAL'   then nAL  
            end );

  end GOODSPARTIES_GET_INDOCS_DATA;
  --#########################################################################################################

  function GOODSSUPPLY_GET
  /*
  Спецификация. Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return goodssupply%rowtype
  is
    rRow goodssupply%rowtype;
  begin
    begin
      select * into rRow from goodssupply where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'GOODSSUPPLY');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'GOODSSUPPLY')));
    end;
    return(rRow);
  end GOODSSUPPLY_GET;
  --#########################################################################################################

  procedure GOODSSUPPLY_GET_BY_GSSA
  /*
  Спецификация. Поиск по товарному запасу изделия на складе
  */
  (
   nFLAGSMART in number
  ,nGSSA      in number /* Товарный запас изделия на складе. RN */
  ,nCOMPANY   in number
  ,nRN        out number
  ) 
  is
  begin
    begin
      select gs.rn
        into nRN
        from articlessupply ats
            ,goodssupply    gs
       where ats.rn = nGSSA
         and gs.rn  = ats.prn;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nGSSA, sunit_table =>  'GOODSSUPPLY');
      when too_many_rows then
        p_exception(nFLAGSMART, 'Найдено больше одного товарного запаса для изделия с RN <%s> в разделе <%s>.'
                   ,nGSSA, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'GOODSSUPPLY')));
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске товарного запаса для изделия с RN <%s> в разделе <%s>.'
                   ,nGSSA, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'GOODSSUPPLY')));
    end;
  end GOODSSUPPLY_GET_BY_GSSA;
  --#########################################################################################################

  function GOODSSUPPLY_GET_REST_BY_RN
  /*
  Спецификация. Поиск остатков по RN 
  */
  (
   nFLAGSMART   in number
  ,nRN          in number
  ,nCOMPANY     in number
  ,dDATE        in date
  ,sRES_TYPE    in varchar2 /*'RESTFACT', 'RESTFACTALT', 'RESERV', 'RESERVALT', 'SALE', 'SALEALT' */
  ) 
  return pkg_std.tlquant
  is
    rRow    goodssupply%rowtype;
    nRes    pkg_std.tlquant; 
    /* Штатная починенная */
    procedure FIND_GOODSSUPPLY_FULL_BY_RN
    (
      nCOMPANY          in  number,         -- организация
      nFLAG_SMART       in  number,         -- признак генерации исключения (0 - да, 1 - нет)
      nRN               in  number,         -- регистрационный номер
      dDATE             in  date,           -- дата отбора ТЗ
      nRESTPLAN         out number,         -- плановый остаток в основной ЕИ
      nRESTPLANALT      out number,         -- плановый остаток в дополнительной ЕИ
      nRESTFACT         out number,         -- фактический остаток в основной ЕИ
      nRESTFACTALT      out number,         -- фактический остаток в дополнительной ЕИ
      nRESERV           out number,         -- резерв в основной ЕИ
      nRESERVALT        out number          -- резерв в дополнительной ЕИ
    )
    as
    begin
      select GSH.RESTPLAN, GSH.RESTPLANALT, GSH.RESTFACT, GSH.RESTFACTALT, GSH.RESERV, GSH.RESERVALT
        into nRESTPLAN, nRESTPLANALT, nRESTFACT, nRESTFACTALT, nRESERV, nRESERVALT
        from GOODSSUPPLY     GS,
             GOODSSUPPLYHIST GSH
       where GS.RN = nRN
         and GS.COMPANY = nCOMPANY
         and GS.RN = GSH.PRN
         and GSH.DATE_FROM <= trunc(nvl(dDATE,sysdate))
         and (GSH.DATE_TO is null or GSH.DATE_TO >= trunc(nvl(dDATE,sysdate)));
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND( nFLAG_SMART/* этого не было */, nRN, 'GoodsSupply' );
    end;

  begin
    /* Поиск */
    find_goodssupply_full_by_rn(ncompany     => nCOMPANY
                               ,nflag_smart  => nFLAGSMART
                               ,nrn          => nRN
                               ,ddate        => dDATE
                               ,nrestplan    => rRow.restplan
                               ,nrestplanalt => rRow.restplanalt
                               ,nrestfact    => rRow.restfact
                               ,nrestfactalt => rRow.restfactalt
                               ,nreserv      => rRow.reserv
                               ,nreservalt   => rRow.reservalt
                               );
    /* Присвоение значения выходной переменной */
    nRes := case upper( sRES_TYPE )
              when 'RESTFACT'    then rRow.restfact
              when 'RESTFACTALT' then rRow.restfactalt
              when 'RESERV'      then rRow.reserv
              when 'RESERVALT'   then rRow.reservalt
              when 'SALE'        then nvl( rRow.restfact   , 0 ) - nvl( rRow.reserv   , 0 )
              when 'SALEALT'     then nvl( rRow.restfactalt, 0 ) - nvl( rRow.reservalt, 0 )
            else -9
            end;
    /* Проверка входной переменной */
    if cmp_num( nRes, -9 ) = 1 then
      p_exception( nFLAGSMART, 'Неверное значение "%s" параметра "sRES_TYPE".', sRES_TYPE );
    end if;
    /* Результат */
    return( nRes );

  end GOODSSUPPLY_GET_REST_BY_RN;
  --#########################################################################################################

  procedure GOODSSUPPLY_GET_FULL
  /*
  Спецификация. Поиск по RN или мнемокодам Приходной партии и Товарного запаса. 
  Возвращает их записи, заполненные считанными значениями
  */
  (
   nFLAGSMART       in number   default 0
  ,nCOMPANY         in number   default null
  ,nGOODSSUPPLY     in number   default null  /* Если искать только по RN товарного запаса */
  ,sINDOC           in varchar2 default null
  ,sNOMEN_CODE      in varchar2 default null
  ,sNOMMODIF_CODE   in varchar2 default null
  ,sSERNUMB         in varchar2 default null
  ,sCOUNTRY         in varchar2 default null
  ,sGTD             in varchar2 default null
  ,sSTORE           in varchar2 default null
  ,dDATE            in date     default null
  ,rV_GOODSPARTIES  out v_goodsparties%rowtype
  ,rV_GOODSSUPPLY   out v_goodssupply%rowtype
  ) 
  is
    nNumber       pkg_std.tnumber; 
    sVarchar      pkg_std.tstring; 
  begin
    find_goodssupply_full(nflag_smart        => nFLAGSMART
                         ,ncompany           => nCOMPANY
                         ,sindoc             => sINDOC
                         ,snomen_code        => sNOMEN_CODE
                         ,snommodif_code     => sNOMMODIF_CODE
                         ,snommodifpack_code => null
                         ,sgp_sernumb        => sSERNUMB
                         ,sgp_country        => sCOUNTRY
                         ,sgp_gtd            => sGTD
                         ,sgs_store          => sSTORE
                         ,ngs_rn             => nGOODSSUPPLY
                         ,ddate              => dDATE
                         ,nrn                => rV_GOODSSUPPLY.NRN
                         ,nrestplan          => rV_GOODSSUPPLY.NRESTPLAN
                         ,nrestplanalt       => rV_GOODSSUPPLY.NRESTPLANALT
                         ,nrestfact          => rV_GOODSSUPPLY.NRESTFACT
                         ,nrestfactalt       => rV_GOODSSUPPLY.NRESTFACTALT
                         ,nreserv            => rV_GOODSSUPPLY.NRESERV
                         ,nreservalt         => rV_GOODSSUPPLY.NRESERVALT
                         ,nstore             => rV_GOODSSUPPLY.NSTORE
                         ,sstore             => rV_GOODSSUPPLY.SSTORE
                         ,nnomgroup          => nNumber
                         ,snomgroup          => sVarchar
                         ,snomgroupname      => sVarchar
                         ,nnomen             => rV_GOODSPARTIES.NNOMEN
                         ,snomen             => rV_GOODSPARTIES.SNOMEN
                         ,snomenname         => rV_GOODSPARTIES.SNOMENNAME
                         ,nnommodif          => rV_GOODSPARTIES.NNOMMODIF
                         ,snommodif          => rV_GOODSPARTIES.SNOMMODIF
                         ,snommodifname      => rV_GOODSPARTIES.SNOMMODIFNAME
                         ,nnommodifpack      => nNumber
                         ,snommodifpack      => sVarchar
                         ,snommodifpackname  => sVarchar
                         ,dexpiry_date       => rV_GOODSPARTIES.DEXPIRY_DATE
                         ,scertificate       => rV_GOODSPARTIES.SCERTIFICATE
                         ,ssernumb           => rV_GOODSPARTIES.SSERNUMB
                         ,sbarcode           => rV_GOODSPARTIES.SBARCODE
                         ,ncountry           => rV_GOODSPARTIES.NCOUNTRY
                         ,scountry           => rV_GOODSPARTIES.SCOUNTRY
                         ,sgtd               => rV_GOODSPARTIES.SGTD
                         ,nproducer          => rV_GOODSPARTIES.NPRODUCER
                         ,sproducer          => rV_GOODSPARTIES.SPRODUCER
                         ,sproducername      => sVarchar
                         ,nstorage_time      => rV_GOODSPARTIES.NSTORAGE_TIME
                         ,numeas_storage     => rV_GOODSPARTIES.NUMEAS_STORAGE
                         ,sumeas_storage     => rV_GOODSPARTIES.SUMEAS_STORAGE
                         ,nstorage_time_rest => rV_GOODSPARTIES.NSTORAGE_TIME_REST
                         ,nparty             => rV_GOODSPARTIES.NINDOC
                         ,sparty             => rV_GOODSPARTIES.SCODE
                         ,njur_pers          => rV_GOODSPARTIES.NJUR_PERS
                         ,sjur_pers          => rV_GOODSPARTIES.SJUR_PERS
                         ,nsupplier          => rV_GOODSPARTIES.NAGENT
                         ,ssupplier          => rV_GOODSPARTIES.SAGENT
                         ,ssuppliername      => rV_GOODSPARTIES.SAGENTNAME
                         ,dentry_date        => rV_GOODSPARTIES.DENTRY_DATE);

    /* Остатки к продаже */
    rV_GOODSSUPPLY.NSALE    := nvl( rV_GOODSSUPPLY.NRESTFACT   , 0 ) - nvl( rV_GOODSSUPPLY.NRESERV   , 0 );
    rV_GOODSSUPPLY.NSALEALT := nvl( rV_GOODSSUPPLY.NRESTFACTALT, 0 ) - nvl( rV_GOODSSUPPLY.NRESERVALT, 0 );

  end GOODSSUPPLY_GET_FULL;
  --#########################################################################################################

  procedure GOODSSUPPLY_GET_FULL
  /*
  Спецификация. Поиск по мнемокодам Приходной партии и Товарного запаса. 
  Возвращает только их RN
  */
  (
   nFLAGSMART       in number   default 0
  ,nCOMPANY         in number   default null
  ,sINDOC           in varchar2 default null
  ,sNOMEN_CODE      in varchar2 default null
  ,sNOMMODIF_CODE   in varchar2 default null
  ,sSERNUMB         in varchar2 default null
  ,sCOUNTRY         in varchar2 default null
  ,sGTD             in varchar2 default null
  ,sSTORE           in varchar2 default null
  ,dDATE            in date     default null
  ,nRN              out number
  ,nPRN             out number
  ) 
  is
    rV_GoodsParties  v_goodsparties%rowtype;
    rV_GoodsSupply   v_goodssupply%rowtype;
  begin
    /* Поиск */
    goodssupply_get_full(nflagsmart      => nFLAGSMART
                        ,ncompany        => nCOMPANY
                        ,sindoc          => sINDOC
                        ,snomen_code     => sNOMEN_CODE
                        ,snommodif_code  => sNOMMODIF_CODE
                        ,ssernumb        => sSERNUMB
                        ,scountry        => sCOUNTRY
                        ,sgtd            => sGTD
                        ,sstore          => sSTORE
                        ,ngoodssupply    => null
                        ,ddate           => dDATE
                        ,rv_goodsparties => rV_GoodsParties
                        ,rv_goodssupply  => rV_GoodsSupply);
    /* Результат */
    nRN  := rV_GoodsSupply.nrn;  
    nPRN := rV_GoodsParties.nrn;  
                          
  end GOODSSUPPLY_GET_FULL;
  --#########################################################################################################

  procedure GOODSSUPPLY_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    goodssupply_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end GOODSSUPPLY_AINSERT;
  
  --#########################################################################################################

  procedure GOODSSUPPLY_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end GOODSSUPPLY_BUPDATE;
  --#########################################################################################################

  procedure GOODSSUPPLY_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    goodssupply_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end GOODSSUPPLY_AUPDATE;
  --#########################################################################################################

  procedure GOODSSUPPLY_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end GOODSSUPPLY_BDELETE;
  --#########################################################################################################

  procedure GOODSSUPPLY_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     goodssupply%rowtype;
  begin
    null;
    /* Считывание */
    /*  rRow := goodssupply_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    
  end GOODSSUPPLY_CHECK_BASE;
  --#########################################################################################################

  procedure GOODSSUPPLY_BASE_UPDATE
  /*
  Спецификация. Базовое исправление
  */
  (
   rROW                 in goodssupply%rowtype
  ) 
  is 
  begin
    p_goodssupply_base_update(ncompany  => rROW.COMPANY
                             ,nrn       => rROW.RN
                             ,nprn      => rROW.PRN
                             ,nstore    => rROW.STORE
                             ,scardnumb => rROW.CARDNUMB);

  end GOODSSUPPLY_BASE_UPDATE;
  --#########################################################################################################

  procedure GOODSSUPPLY_RECALC
  /*
  Спецификация. Пересчёт данных. По мотивам P_GOODSSUPPLYHIST_BASE_FORMING
  */
  (
   nRN        in number
  ,nCOMPANY   in number
  )
  as
    rGOODSSUPPLYHIST  GOODSSUPPLYHIST%rowtype;
    bUPDATE_DATE_TO   boolean;
    bUPDATE_MINS      boolean;
  begin
    /* очистка записей истории ТЗ */
      delete from GOODSSUPPLYHIST
       where prn = nRN;

    /* цикл по записям журнала складских операций в порядке возрастания дат */
    for Rec in
    (
      select J.GOODSSUPPLY,
             trunc(J.OPERDATE) OPERDATE,
             J.OPER_TYPE,
             J.SIGNPLAN,
             J.QUANT           * (2*J.OPER_TYPE - 1) QUANT,
             nvl(J.QUANTALT,0) * (2*J.OPER_TYPE - 1) QUANTALT,
             J.REGSUMM         * (2*J.OPER_TYPE - 1) REGSUMM,
             GS.JUR_PERS,
             GS.STORE
        from STOREOPERJOURN J,
             GOODSSUPPLY    GS
       where J.GOODSSUPPLY = GS.RN
         and gs.rn         = nRN
       order by J.GOODSSUPPLY, J.OPERDATE, J.FACTOPERDATE, J.OPER_TYPE desc
    )
    loop
      if Rec.SIGNPLAN = 0 then     -- факт
        /* коррекция истории товарных запасов */
        P_GOODSSUPPLYHIST_CORRECT
        (
          nCOMPANY,
          Rec.GOODSSUPPLY,
          Rec.JUR_PERS,
          Rec.STORE,
          Rec.OPERDATE,
          0,            -- nRESTPLAN
          0,            -- nRESTPLANALT
          Rec.QUANT,    -- nRESTFACT
          Rec.QUANTALT, -- nRESTFACTALT
          0,            -- nRESERV
          0,            -- nRESERVALT
          0,            -- nSUMMPLAN
          Rec.REGSUMM,  -- nSUMMFACT
          0             -- nEXTRA_CORRECT
        );
      elsif Rec.SIGNPLAN = 1 then  -- план
        /* коррекция истории товарных запасов */
        P_GOODSSUPPLYHIST_CORRECT
        (
          nCOMPANY,
          Rec.GOODSSUPPLY,
          Rec.JUR_PERS,
          Rec.STORE,
          Rec.OPERDATE,
          Rec.QUANT,    -- nRESTPLAN
          Rec.QUANTALT, -- nRESTPLANALT
          0,            -- nRESTFACT
          0,            -- nRESTFACTALT
          0,            -- nRESERV
          0,            -- nRESERVALT
          Rec.REGSUMM,  -- nSUMMPLAN
          0,            -- nSUMMFACT
          0             -- nEXTRA_CORRECT
        );
      elsif Rec.SIGNPLAN = 2 then  -- план/факт
        /* коррекция истории товарных запасов */
        P_GOODSSUPPLYHIST_CORRECT
        (
          nCOMPANY,
          Rec.GOODSSUPPLY,
          Rec.JUR_PERS,
          Rec.STORE,
          Rec.OPERDATE,
          Rec.QUANT,    -- nRESTPLAN
          Rec.QUANTALT, -- nRESTPLANALT
          Rec.QUANT,    -- nRESTFACT
          Rec.QUANTALT, -- nRESTFACTALT
          0,            -- nRESERV
          0,            -- nRESERVALT
          Rec.REGSUMM,  -- nSUMMPLAN
          Rec.REGSUMM,  -- nSUMMFACT
          0             -- nEXTRA_CORRECT
        );
      end if;
    end loop;

    /* цикл по записям журнала резервирования в порядке возрастания дат */
    for Rec in
    (
      select J.SUPPLY,
             0 RES_TYPE,
             J.RES_START_DATE,
             trunc(J.RES_START_DATE) OPERDATE,
             J.QUANT,
             J.QUANT_ALT,
             GS.JUR_PERS,
             GS.STORE
        from RESJOURNAL  J,
             GOODSSUPPLY GS
       where J.SUPPLY = GS.RN
         and (trunc(J.RES_START_DATE) <> trunc(J.RES_END_DATE) or J.RES_END_DATE is null)
         and gs.rn    = nRN 
       union all
      select J.SUPPLY,
             1 RES_TYPE,
             J.RES_START_DATE,
             trunc(J.RES_END_DATE) OPERDATE,
             - J.QUANT,
             - J.QUANT_ALT,
             GS.JUR_PERS,
             GS.STORE
        from RESJOURNAL  J,
             GOODSSUPPLY GS
       where J.SUPPLY = GS.RN
         and trunc(J.RES_START_DATE) <> trunc(J.RES_END_DATE)
         and gs.rn    = nRN
       order by SUPPLY, RES_START_DATE, RES_TYPE
    )
    loop
      /* коррекция истории товарных запасов */
      P_GOODSSUPPLYHIST_CORRECT
      (
        nCOMPANY,
        Rec.SUPPLY,
        Rec.JUR_PERS,
        Rec.STORE,
        Rec.OPERDATE,
        0,              -- nRESTPLAN
        0,              -- nRESTPLANALT
        0,              -- nRESTFACT
        0,              -- nRESTFACTALT
        Rec.QUANT,      -- nRESERV
        Rec.QUANT_ALT,  -- nRESERVALT
        0,              -- nSUMMPLAN
        0,              -- nSUMMFACT
        0               -- nEXTRA_CORRECT
      );
    end loop;

    /* если выставлен параметр "Учитывать распределение накладных расходов в стоимости ТЗ" */
    if GET_OPTIONS_NUM('Realiz_GoodsSupply_UseOverheads', nCOMPANY) = 1 then
      /* цикл по записям журнала накладных расходов в порядке возрастания дат */
      for Rec in
      (
        select O.WORK_DATE,
               OS.GOODSSUPPLY,
               OS.SUMM_NDS,
               GS.JUR_PERS,
               GS.STORE
          from OVERHEADS   O,
               OVERHEADSSP OS,
               GOODSSUPPLY GS
         where O.COMPANY      = nCOMPANY
           and O.WORK_DATE    is not null
           and O.RN           = OS.PRN
           and OS.GOODSSUPPLY = GS.RN
           and GS.RN          = nRN
         order by O.WORK_DATE
      )
      loop
        /* коррекция истории товарных запасов */
        P_GOODSSUPPLYHIST_CORRECT
        (
          nCOMPANY,
          Rec.GOODSSUPPLY,
          Rec.JUR_PERS,
          Rec.STORE,
          Rec.WORK_DATE,
          0,            -- nRESTPLAN
          0,            -- nRESTPLANALT
          0,            -- nRESTFACT
          0,            -- nRESTFACTALT
          0,            -- nRESERV
          0,            -- nRESERVALT
          Rec.SUMM_NDS, -- nSUMMPLAN
          Rec.SUMM_NDS, -- nSUMMFACT
          0             -- nEXTRA_CORRECT
        );
      end loop;
    end if;

    /* объединение повторов в истории ТЗ */
    /* инициализация */
    rGOODSSUPPLYHIST := null;

    /* цикл по истории ТЗ */
    for Rec in
    (
      select *
        from GOODSSUPPLYHIST
       where prn = nRN
       order by PRN, DATE_FROM desc
    )
    loop
      /* инициализация */
      bUPDATE_DATE_TO := false;
      bUPDATE_MINS    := false;

      /* начиная со второго шага */
      if rGOODSSUPPLYHIST.RN is not null and (Rec.PRN = rGOODSSUPPLYHIST.PRN) then

        /* сравнение записей истории ТЗ */
        /* если количества совпадают */
        if (Rec.RESTPLAN    = rGOODSSUPPLYHIST.RESTPLAN) and
           (Rec.RESTPLANALT = rGOODSSUPPLYHIST.RESTPLANALT) and
           (Rec.RESTFACT    = rGOODSSUPPLYHIST.RESTFACT) and
           (Rec.RESTFACTALT = rGOODSSUPPLYHIST.RESTFACTALT) and
           (Rec.RESERV      = rGOODSSUPPLYHIST.RESERV) and
           (Rec.RESERVALT   = rGOODSSUPPLYHIST.RESERVALT) and
           (Rec.SUMMPLAN    = rGOODSSUPPLYHIST.SUMMPLAN) and
           (Rec.SUMMFACT    = rGOODSSUPPLYHIST.SUMMFACT) then

          /* удаление запись истории ТЗ предшествующего шага */
          P_GOODSSUPPLYHIST_BASE_DELETE( nCOMPANY, rGOODSSUPPLYHIST.RN );

          /* переинициализация даты окончания */
          Rec.DATE_TO := rGOODSSUPPLYHIST.DATE_TO;

          /* необходимо исправление */
          bUPDATE_DATE_TO := true;
        end if;

        /* сравнение записей истории ТЗ по минимумам */
        if (Rec.MIN_RESTPLAN    <> least(rGOODSSUPPLYHIST.MIN_RESTPLAN,    Rec.RESTPLAN - Rec.RESERV)) or
           (Rec.MIN_RESTPLANALT <> least(rGOODSSUPPLYHIST.MIN_RESTPLANALT, Rec.RESTPLANALT - Rec.RESERVALT)) or
           (Rec.MIN_RESTFACT    <> least(rGOODSSUPPLYHIST.MIN_RESTFACT,    Rec.RESTFACT - Rec.RESERV)) or
           (Rec.MIN_RESTFACTALT <> least(rGOODSSUPPLYHIST.MIN_RESTFACTALT, Rec.RESTFACTALT - Rec.RESERVALT)) then

          /* расчет минимальных остатков */
          Rec.MIN_RESTPLAN    := least(rGOODSSUPPLYHIST.MIN_RESTPLAN,    Rec.RESTPLAN - Rec.RESERV);
          Rec.MIN_RESTPLANALT := least(rGOODSSUPPLYHIST.MIN_RESTPLANALT, Rec.RESTPLANALT - Rec.RESERVALT);
          Rec.MIN_RESTFACT    := least(rGOODSSUPPLYHIST.MIN_RESTFACT,    Rec.RESTFACT - Rec.RESERV);
          Rec.MIN_RESTFACTALT := least(rGOODSSUPPLYHIST.MIN_RESTFACTALT, Rec.RESTFACTALT - Rec.RESERVALT);

          /* необходимо исправление */
          bUPDATE_MINS := true;
        end if;

      /* первый шаг цикла */
      else

        /* сравнение записей истории ТЗ по минимумам */
        if (Rec.MIN_RESTPLAN    <> (Rec.RESTPLAN - Rec.RESERV)) or
           (Rec.MIN_RESTPLANALT <> (Rec.RESTPLANALT - Rec.RESERVALT)) or
           (Rec.MIN_RESTFACT    <> (Rec.RESTFACT - Rec.RESERV)) or
           (Rec.MIN_RESTFACTALT <> (Rec.RESTFACTALT - Rec.RESERVALT)) then

          /* расчет минимальных остатков */
          Rec.MIN_RESTPLAN    := Rec.RESTPLAN - Rec.RESERV;
          Rec.MIN_RESTPLANALT := Rec.RESTPLANALT - Rec.RESERVALT;
          Rec.MIN_RESTFACT    := Rec.RESTFACT - Rec.RESERV;
          Rec.MIN_RESTFACTALT := Rec.RESTFACTALT - Rec.RESERVALT;

          /* необходимо исправление */
          bUPDATE_MINS := true;
        end if;
      end if;

      /* если необходимо исправление атрибутов записи истории ТЗ */
      if bUPDATE_DATE_TO and bUPDATE_MINS then
        /* исправление */
        update GOODSSUPPLYHIST
           set DATE_TO         = Rec.DATE_TO,
               MIN_RESTPLAN    = Rec.MIN_RESTPLAN,
               MIN_RESTPLANALT = Rec.MIN_RESTPLANALT,
               MIN_RESTFACT    = Rec.MIN_RESTFACT,
               MIN_RESTFACTALT = Rec.MIN_RESTFACTALT
         where RN = Rec.RN;
      /**/
      elsif bUPDATE_DATE_TO then
        /* исправление */
        update GOODSSUPPLYHIST
           set DATE_TO         = Rec.DATE_TO
         where RN = Rec.RN;
      /**/
      elsif bUPDATE_MINS then
        /* исправление */
        update GOODSSUPPLYHIST
           set MIN_RESTPLAN    = Rec.MIN_RESTPLAN,
               MIN_RESTPLANALT = Rec.MIN_RESTPLANALT,
               MIN_RESTFACT    = Rec.MIN_RESTFACT,
               MIN_RESTFACTALT = Rec.MIN_RESTFACTALT
         where RN = Rec.RN;
      end if;

      /* инициализация */
      rGOODSSUPPLYHIST := Rec;
    end loop;

  end GOODSSUPPLY_RECALC;
  --#########################################################################################################

  function GOODSSUPPLYCLC_GET
  /*
  Спецификация (калькуляция затрат) Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return goodssupplyclc%rowtype
  is
    rRow goodssupplyclc%rowtype;
  begin
    begin
      select * into rRow from goodssupplyclc where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'GOODSSUPPLYCLC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'GOODSSUPPLYCLC')));
    end;
    return(rRow);
  end GOODSSUPPLYCLC_GET;
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_AINSERT
  /*
  Спецификация (калькуляция затрат) Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    goodssupplyclc_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end GOODSSUPPLYCLC_AINSERT;
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_BUPDATE
  /*
  Спецификация (калькуляция затрат) Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end GOODSSUPPLYCLC_BUPDATE;
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_AUPDATE
  /*
  Спецификация (калькуляция затрат) Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    goodssupplyclc_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end GOODSSUPPLYCLC_AUPDATE;
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_BDELETE
  /*
  Спецификация (калькуляция затрат) Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end GOODSSUPPLYCLC_BDELETE;
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_CHECK_BASE
  /*
  Спецификация (калькуляция затрат) Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     goodssupplyclc%rowtype;
  begin
    null;
    /* Считывание */
    /*  rRow := goodssupplyclc_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    
  end GOODSSUPPLYCLC_CHECK_BASE;
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_BASE_INSERT
  /*
  Спецификация (калькуляция затрат) Базовое исправление
  */
  (
   rROW                 in goodssupplyclc%rowtype
  ,nRN                  out number
  ) 
  is 
  begin
    p_goodssupplyclc_base_insert(ncompany      => rROW.COMPANY
                                ,nprn          => rROW.PRN
                                ,snumb         => rROW.NUMB
                                ,ncost_article => rROW.COST_ARTICLE
                                ,ncost_place   => rROW.COST_PLACE
                                ,ncost_plan    => rROW.COST_PLAN
                                ,ncost_fact    => rROW.COST_FACT
                                ,npriority     => rROW.PRIORITY
                                ,nfaceacc      => rROW.FACEACC
                                ,ngraphpoint   => rROW.GRAPHPOINT
                                ,nfinoper_type => rROW.FINOPER_TYPE
                                ,nquant_plan   => rROW.QUANT_PLAN
                                ,nquant_fact   => rROW.QUANT_FACT
                                ,nsubdiv       => rROW.SUBDIV
                                ,nrn           => nRN);

  end GOODSSUPPLYCLC_BASE_INSERT;
  --#########################################################################################################

  procedure GOODSSUPPLYCLC_BASE_UPDATE
  /*
  Спецификация (калькуляция затрат) Базовое исправление
  */
  (
   rROW                 in goodssupplyclc%rowtype
  ) 
  is 
  begin
    p_goodssupplyclc_base_update(nrn           => rROW.RN
                                ,ncompany      => rROW.COMPANY
                                ,snumb         => rROW.NUMB
                                ,ncost_article => rROW.COST_ARTICLE
                                ,ncost_place   => rROW.COST_PLACE
                                ,ncost_plan    => rROW.COST_PLAN
                                ,ncost_fact    => rROW.COST_FACT
                                ,npriority     => rROW.PRIORITY
                                ,nfaceacc      => rROW.FACEACC
                                ,ngraphpoint   => rROW.GRAPHPOINT
                                ,nfinoper_type => rROW.FINOPER_TYPE
                                ,nquant_plan   => rROW.QUANT_PLAN
                                ,nquant_fact   => rROW.QUANT_FACT
                                ,nsubdiv       => rROW.SUBDIV);

  end GOODSSUPPLYCLC_BASE_UPDATE;
  --#########################################################################################################

  function ARTICLESSUPPLY_GET
  /*
  Изделия на складе. Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return articlessupply%rowtype
  is
    rRow articlessupply%rowtype;
  begin
    begin
      select * into rrow from articlessupply where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'ARTICLESSUPPLY');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'ARTICLESSUPPLY')));
    end;
    return(rRow);
  end ARTICLESSUPPLY_GET;
  --#########################################################################################################

  function INCOMDOC_GET
  /*
  Партии товара. Считывание 
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return incomdoc%rowtype
  is
    rRow incomdoc%rowtype;
  begin
    begin
      select * into rRow from incomdoc where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'INCOMDOC');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'INCOMDOC')));
    end;
    return(rRow);
  end INCOMDOC_GET;
  --#########################################################################################################

  procedure INCOMDOC_GET_FULL
  /*
  Партии товара. Поиск полный (возвращает запись)
  */
  (
   nFLAGSMART         in number   default 0
  ,nFLAG_OPTION       in number   default 0  /* признак генерации исключения для пустого sCODE и RN (0 - да, 1 - нет) */
  ,nCOMPANY           in number
  ,sCODE              in varchar2 default null
  ,nRN                in number   default null
  ,rV_INCOMDOC        out v_incomdoc%rowtype
  ) 
  is
  begin
    find_incomdoc_all(nflag_smart  => nFLAGSMART
                     ,nflag_option => nFLAG_OPTION
                     ,ncompany     => nCOMPANY
                     ,scode        => sCODE
                     ,nrn          => nRN
                     ,nirn         => rV_INCOMDOC.NRN
                     ,sicode       => rV_INCOMDOC.SCODE
                     ,njur_pers    => rV_INCOMDOC.NJUR_PERS
                     ,sjur_pers    => rV_INCOMDOC.SJUR_PERS
                     ,nagent       => rV_INCOMDOC.NAGENT
                     ,sagent       => rV_INCOMDOC.SAGENT
                     ,nsubdiv      => rV_INCOMDOC.NSUBDIV
                     ,ssubdiv      => rV_INCOMDOC.SSUBDIV
                     ,dentry_date  => rV_INCOMDOC.DENTRY_DATE
                     ,nout_party   => rV_INCOMDOC.NOUT_PARTY
                     ,nstor_sign   => rV_INCOMDOC.NSTOR_SIGN
                     ,ncommis_sign => rV_INCOMDOC.NCOMMIS_SIGN);
  end INCOMDOC_GET_FULL;
  --#########################################################################################################

  procedure INCOMDOC_GET_FULL
  /*
  Партии товара. Поиск полный (возвращает запись)
  */
  (
   nFLAGSMART         in number default 0
  ,nFLAG_OPTION       in number default 0  /* признак генерации исключения для пустого sCODE и RN (0 - да, 1 - нет) */
  ,nCOMPANY           in number
  ,sCODE              in varchar2
  ,nRN                out number
  ) 
  is
    rV_IncomDoc            v_incomdoc%rowtype;
  begin
    /* Поиск */
    incomdoc_get_full(nflagsmart   => nFLAGSMART
                     ,nflag_option => nFLAG_OPTION
                     ,ncompany     => nCOMPANY
                     ,scode        => sCODE
                     ,nrn          => null
                     ,rv_incomdoc  => rV_IncomDoc);
    /* Результат */
    nRN := rV_IncomDoc.nrn;  
    
  end INCOMDOC_GET_FULL;
  --#########################################################################################################

end USR_PKG_GOODSPARTIES;
/
