create or replace package USR_PKG_GOODSPARTIES_ADD is
  /*
  Степанов М. 18/10/203
  Предназначен для работы с дополнительными данными приходных партий товара, которые хранятся в разделе Сертификаты. 
  grant execute on USR_PKG_GOODSPARTIES_ADD to public;
  */
  --#########################################################################################################

  function GET
  /*
  Считывание записи дополнительных данных (сертификата)
  */
  (
   nGOODSPARTIES  in number
  ,sTYPE          in varchar2  /* Значение свойства "Доп.данные прих.парт" */
  )
  return certification%rowtype;
  --#########################################################################################################

  function GET_VAL_STR
  /*
  Считывание записи дополнительных данных (сертификата)
  */
  (
   nGOODSPARTIES  in number
  ,sTYPE          in varchar2  /* Значение свойства "Доп.данные прих.парт" */
  )
  return varchar2;
  --#########################################################################################################

  function GET_VAL_DATE
  /*
  Считывание записи дополнительных данных (сертификата)
  */
  (
   nGOODSPARTIES  in number
  ,sTYPE          in varchar2  /* Значение свойства "Доп.данные прих.парт" */
  )
  return date;
  --#########################################################################################################

  function GET_VAL_NUM
  /*
  Считывание записи дополнительных данных (сертификата)
  */
  (
   nGOODSPARTIES  in number
  ,sTYPE          in varchar2  /* Значение свойства "Доп.данные прих.парт" */
  )
  return number;
  --#########################################################################################################

  procedure GET_VAL
  /*
  Получение заданного значения дополнительных данных (из сертификата)
  */
  (
   nGOODSPARTIES  in number
  ,sTYPE          in varchar2  /* Значение свойства "Доп.данные прих.парт" */
  ,sVALUE         out varchar2 
  ,dVALUE         out date   
  ,nVALUE         out number
  );
  --#########################################################################################################

  procedure GET_VALS
  /*
  Получение всех значений дополнительных данных товарного запаса
  */
  (
   nGOODSPARTIES          in number    /* Товарный запас. RN (GOODSPARTIES)*/
  ,sPRODUCER              out varchar2 /* Приходные партии товара. Производитель */
  ,dEXPIRY_DATE           out date     /* Приходные партии товара. Срок годности */
  ,nSTORAGE_TIME          out number   /* Приходные партии товара. Срок хранения */
  ,sUMEAS_STORAGE         out varchar2 /* Приходные партии товара. Единица измерения срока хранения*/
  ,sCERTIFICATE           out varchar2 /* Приходные партии товара. Сертификаты */
  ,sBARCODE               out varchar2 /* Приходные партии товара. Штрих-код   */
  ,dPROD_DATE             out date     /* Приходные партии товара. Дата изготовления */
  ,dWARRANTY              out date     /* Сертификаты. Дата окончания гарантии */
  ,sSTORE_CARD            out varchar2 /* Сертификаты. Складская карточка */
  ,sFACTORY_NUMB          out varchar2 /* Сертификаты. Заводской номер*/
  ,sINV_NUMB              out varchar2 /* Сертификаты. Инвентарный номер*/
  ,sEQUIPMENT             out varchar2 /* Сертификаты. Комплектность */
  ,sSTATE_REG_NUMB        out varchar2 /* Сертификаты. Номер в госреестре */
  ,sNOTE                  out varchar2 /* Сертификаты. Примечание */
  ,dFACT_CHECK_DATE       out date     /* Сертификаты. Фактическая поверка. Дата */
  ,dPLAN_CHECK_DATE       out date     /* Сертификаты. Плановая поверка. Дата */
  ,sPLAN_CHECK_AGN        out varchar2 /* Сертификаты. Плановая поверка. Контрагент */
  ,nCHECK_INTERVAL        out number   /* Сертификаты. Интервал поверки */
  ,sACC_RESP              out varchar2 /* Сертификаты. Ответственный в бух.учёте */
  ,sFIXED_ASSETS          out varchar2 /* Сертификаты. Основные средства */
  ,sON_VERIF              out varchar2 /* Сертификаты. На поверке */
  ,sVERIF_CERT            out varchar2 /* Сертификаты. Свидетельство поверки */
  ,sMANUAL                out varchar2 /* Присоединены документы Руководство */
  ,sSPECS                 out varchar2 /* Присоединены документы Характеристики */
  ,sLISTOFDEVICESEXIST    out varchar2 /* Присутствует в перечне приборов */
  ,sLISTOFINDICATORSEXIST out varchar2 /* Присутствует в перечне индикаторов */
  ,sLISTOFDEVICESLSEXIST  out varchar2 /* Присутствует в перечне индикаторов длительного храниния */
  ,nWIDTH                 out number   /* Номенклатор. Ширина. Ширина */
  ,nHEIGHT                out number   /* Номенклатор. Высота. Высота */
  ,nLENGTH                out number   /* Номенклатор. Длина. Длина */
  ,sMU_SIZE               out varchar2 /* Номенклатор. ЕИ размера. */
  ,nWEIGHT                out number   /* Номенклатор. Вес. */
  ,sMU_WEIGHT             out varchar2 /* Номенклатор. ЕИ веса*/
  ,nDICNOMNS              out number
  );
  --#########################################################################################################

  procedure GET_VALS
  /*
  Получение всех значений дополнительных данных товарного запаса
  */
  (
   nGOODSPARTIES      in number    /* Товарный запас. RN (GOODSPARTIES)*/
  ,rMTLGDETREC        out usr_pkg_pub_const.tmtlgdetrec
  );
  --#########################################################################################################

  procedure CHECK_VAL
  /*
  Проверка записи дополнительных данных (сертификата)
  */
  (
   rROW     in certification%rowtype
  ,sTYPE    in varchar2
  );
  --#########################################################################################################

  procedure UPDATE_VAL
  /*
  Исправление заданного значения дополнительных данных
  */
  (
   nGOODSPARTIES  in number
  ,sTYPE          in varchar2  /* Значение свойства "Доп.данные прих.парт" */
  ,sVALUE         in varchar2 
  ,dVALUE         in date   
  ,nVALUE         in number
  );
  --#########################################################################################################

  procedure UPDATE_VALS
  /*
  Исправление всех значений дополнительных данных товарного запаса
  */
  (
   rMTLGDETREC        in usr_pkg_pub_const.tmtlgdetrec
  );
  --#########################################################################################################

  procedure COPY_VALS
  /*
  
  */
  (
   nGOODSPARTIES        in number  
  ,nGOODSPARTIES_FROM   in number  
  ,nDELETE_FROM         in number
  );
  --#########################################################################################################

  procedure DELETE_VALS
  /*
  
  */
  (
   nGOODSPARTIES    in number  
  );
  --#########################################################################################################

end USR_PKG_GOODSPARTIES_ADD;
/
create or replace package body USR_PKG_GOODSPARTIES_ADD is

  --#########################################################################################################

  function GET
  /*
  Считывание записи дополнительных данных (сертификата)
  */
  (
   nGOODSPARTIES  in number
  ,sTYPE          in varchar2  /* Значение свойства "Доп.данные прих.парт" */
  )
  return certification%rowtype
  is
    rRow certification%rowtype;
  begin
    /* Сертификат в каталоге Метрология, у которого партия равна заданной партии и свойство "Доп.данные метрологии" равно заданному */
    begin
      select /*+ ORDERED */ h.*
        into rRow
        from certificationsp s, certification h, docs_props_vals dpv
       where h.rn             = s.prn
         and h.crn            = 97525163
         and s.party          = nGOODSPARTIES
         and dpv.docs_prop_rn = 97644642
         and dpv.unit_rn      = h.rn
         and dpv.str_value    = sTYPE;
    exception
      when no_data_found then
        null;
      when too_many_rows then
        p_exception(0, 'Найдено больше одной записи дополнительных данных приходной партии <%s>. %s'
                   ,sTYPE
                   ,cr||f_docdescrs_get_description('GoodsParties', nGOODSPARTIES));
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске дополнительных данных приходнойпартии <%s>. %s'
                   ,sTYPE
                   ,cr||f_docdescrs_get_description('GoodsParties', nGOODSPARTIES));
    end;

    return(rRow);

  end GET;
  --#########################################################################################################

  function GET_VAL_STR
  /*
  Считывание записи дополнительных данных (сертификата)
  */
  (
   nGOODSPARTIES  in number
  ,sTYPE          in varchar2  /* Значение свойства "Доп.данные прих.парт" */
  )
  return varchar2
  is
    sRes    pkg_std.tstring;
    dRes    date;
    nRes    pkg_std.tnumber;
  begin
    get_val(ngoodsparties => nGOODSPARTIES
           ,stype         => sTYPE
           ,svalue        => sRes
           ,dvalue        => dRes
           ,nvalue        => nRes);
    return sRes;
  end GET_VAL_STR;
  --#########################################################################################################

  function GET_VAL_DATE
  /*
  Считывание записи дополнительных данных (сертификата)
  */
  (
   nGOODSPARTIES  in number
  ,sTYPE          in varchar2  /* Значение свойства "Доп.данные прих.парт" */
  )
  return date
  is
    sRes    pkg_std.tstring;
    dRes    date;
    nRes    pkg_std.tnumber;
  begin
    get_val(ngoodsparties => nGOODSPARTIES
           ,stype         => sTYPE
           ,svalue        => sRes
           ,dvalue        => dRes
           ,nvalue        => nRes);
    return dRes;
  end GET_VAL_DATE;
  --#########################################################################################################

  function GET_VAL_NUM
  /*
  Считывание записи дополнительных данных (сертификата)
  */
  (
   nGOODSPARTIES  in number
  ,sTYPE          in varchar2  /* Значение свойства "Доп.данные прих.парт" */
  )
  return number
  is
    sRes    pkg_std.tstring;
    dRes    date;
    nRes    pkg_std.tnumber;
  begin
    get_val(ngoodsparties => nGOODSPARTIES
           ,stype         => sTYPE
           ,svalue        => sRes
           ,dvalue        => dRes
           ,nvalue        => nRes);
    return nRes;
  end GET_VAL_NUM;
  --#########################################################################################################

  procedure GET_VAL
  /*
  Получение заданного значения дополнительных данных (из сертификата)
  */
  (
   nGOODSPARTIES  in number
  ,sTYPE          in varchar2  /* Значение свойства "Доп.данные прих.парт" */
  ,sVALUE         out varchar2 
  ,dVALUE         out date   
  ,nVALUE         out number
  ) 
  is 
    rRow      certification%rowtype;
  begin
    /* Считывани сертификата */    
    rRow := get(ngoodsparties => nGOODSPARTIES, stype => sTYPE);

    /* Если сертификат найден */    
    if rRow.rn is not null then
      /* в зависимости от параметра */    
      if sTYPE in ('Складская карточка', 'Заводской номер', 'Инвентарный номер', 'Комплектность'
                  ,'Номер в госреестре', 'Примечание', 'Ответственный в бух.учёте', 'Основные средства'
                  ,'На поверке', 'Свидетельство поверки'
                  ) then
        sVALUE := rRow.note;
      elsif sTYPE in ('Плановая поверка. Контрагент') then
        sVALUE := get_agnlist_agnabbr_id(1, rRow.company_cert_expert);
      elsif sTYPE in ('Дата окончания гарантии', 'Плановая поверка. Дата', 'Фактическая поверка. Дата') then
        dVALUE := rRow.date_to;
      elsif sTYPE in ('Интервал поверки') then
        nVALUE := to_number(rRow.note);
      else
        null;
      end if;
    end if;

  end GET_VAL;
  --#########################################################################################################
  
  procedure GET_VALS
  /*
   Получение всех значений дополнительных данных товарного запаса
   */
  (
   nGOODSPARTIES          in number    /* Товарный запас. RN (GOODSPARTIES)*/
  ,sPRODUCER              out varchar2 /* Приходные партии товара. Производитель */
  ,dEXPIRY_DATE           out date     /* Приходные партии товара. Срок годности */
  ,nSTORAGE_TIME          out number   /* Приходные партии товара. Срок хранения */
  ,sUMEAS_STORAGE         out varchar2 /* Приходные партии товара. Единица измерения срока хранения*/
  ,sCERTIFICATE           out varchar2 /* Приходные партии товара. Сертификаты */
  ,sBARCODE               out varchar2 /* Приходные партии товара. Штрих-код   */
  ,dPROD_DATE             out date     /* Приходные партии товара. Дата изготовления */
  ,dWARRANTY              out date     /* Сертификаты. Дата окончания гарантии */
  ,sSTORE_CARD            out varchar2 /* Сертификаты. Складская карточка */
  ,sFACTORY_NUMB          out varchar2 /* Сертификаты. Заводской номер*/
  ,sINV_NUMB              out varchar2 /* Сертификаты. Инвентарный номер*/
  ,sEQUIPMENT             out varchar2 /* Сертификаты. Комплектность */
  ,sSTATE_REG_NUMB        out varchar2 /* Сертификаты. Номер в госреестре */
  ,sNOTE                  out varchar2 /* Сертификаты. Примечание */
  ,dFACT_CHECK_DATE       out date     /* Сертификаты. Фактическая поверка. Дата */
  ,dPLAN_CHECK_DATE       out date     /* Сертификаты. Плановая поверка. Дата */
  ,sPLAN_CHECK_AGN        out varchar2 /* Сертификаты. Плановая поверка. Контрагент */
  ,nCHECK_INTERVAL        out number   /* Сертификаты. Интервал поверки */
  ,sACC_RESP              out varchar2 /* Сертификаты. Ответственный в бух.учёте */
  ,sFIXED_ASSETS          out varchar2 /* Сертификаты. Основные средства */
  ,sON_VERIF              out varchar2 /* Сертификаты. На поверке */
  ,sVERIF_CERT            out varchar2 /* Сертификаты. Свидетельство поверки */
  ,sMANUAL                out varchar2 /* Присоединены документы Руководство */
  ,sSPECS                 out varchar2 /* Присоединены документы Характеристики */
  ,sLISTOFDEVICESEXIST    out varchar2 /* Присутствует в перечне приборов */
  ,sLISTOFINDICATORSEXIST out varchar2 /* Присутствует в перечне индикаторов */
  ,sLISTOFDEVICESLSEXIST  out varchar2 /* Присутствует в перечне индикаторов длительного храниния */
  ,nWIDTH                 out number   /* Номенклатор. Ширина. Ширина */
  ,nHEIGHT                out number   /* Номенклатор. Высота. Высота */
  ,nLENGTH                out number   /* Номенклатор. Длина. Длина */
  ,sMU_SIZE               out varchar2 /* Номенклатор. ЕИ размера. */
  ,nWEIGHT                out number   /* Номенклатор. Вес. */
  ,sMU_WEIGHT             out varchar2 /* Номенклатор. ЕИ веса*/
  ,nDICNOMNS              out number
  ) 
  is
    rMtlgDetRec     usr_pkg_pub_const.tmtlgdetrec;
  begin
    /* считывание */
    get_vals(ngoodsparties => nGOODSPARTIES, rmtlgdetrec => rMtlgDetRec);

    /* ПРИХОДНАЯ ПАРТИЯ */
    /* запись значений */
    sPRODUCER      := rMtlgDetRec.sproducer;
    dEXPIRY_DATE   := rMtlgDetRec.dexpiry_date;
    nSTORAGE_TIME  := rMtlgDetRec.nstorage_time;
    sUMEAS_STORAGE := rMtlgDetRec.sumeas_storage;
    sCERTIFICATE   := rMtlgDetRec.scertificate;
    sBARCODE       := rMtlgDetRec.sbarcode;
    dPROD_DATE     := rMtlgDetRec.dprod_date;
  
    /* СЕРТИФИКАТЫ */
    dWARRANTY        := rMtlgDetRec.dwarranty;
    sFACTORY_NUMB    := rMtlgDetRec.sfactory_numb;
    sSTORE_CARD      := rMtlgDetRec.sstore_card;
    sINV_NUMB        := rMtlgDetRec.sinv_numb;
    sEQUIPMENT       := rMtlgDetRec.sequipment;
    sSTATE_REG_NUMB  := rMtlgDetRec.sstate_reg_numb;
    sNOTE            := rMtlgDetRec.snote;
    dFACT_CHECK_DATE := rMtlgDetRec.dfact_check_date;
    dPLAN_CHECK_DATE := rMtlgDetRec.dplan_check_date;
    sPLAN_CHECK_AGN  := rMtlgDetRec.splan_check_agn;
    nCHECK_INTERVAL  := rMtlgDetRec.ncheck_interval;
    sACC_RESP        := rMtlgDetRec.sacc_resp;
    sFIXED_ASSETS    := rMtlgDetRec.sfixed_assets;
    sON_VERIF        := rMtlgDetRec.son_verif;
    sVERIF_CERT      := rMtlgDetRec.sverif_cert;
  
    /* НОМЕНКЛАТУРА */
    nDICNOMNS  := rMtlgDetRec.ndicnomns;
    nWIDTH     := rMtlgDetRec.nwidth;
    nHEIGHT    := rMtlgDetRec.nheight;
    nLENGTH    := rMtlgDetRec.nlength;
    sMU_SIZE   := rMtlgDetRec.smu_size;
    nWEIGHT    := rMtlgDetRec.nweight;
    sMU_WEIGHT := rMtlgDetRec.smu_weight;

    /* ПРОЧЕЕ */
    sMANUAL                := rMtlgDetRec.smanual;
    sSPECS                 := rMtlgDetRec.sspecs;
    sLISTOFDEVICESEXIST    := rMtlgDetRec.slistofdevicesexist;
    sLISTOFINDICATORSEXIST := rMtlgDetRec.slistofindicatorsexist;
    sLISTOFDEVICESLSEXIST  := rMtlgDetRec.slistofdeviceslsexist; 
                           
  end GET_VALS;            
  --#########################################################################################################

  procedure GET_VALS
  /*
  Получение всех значений дополнительных данных товарного запаса
  */
  (
   nGOODSPARTIES      in number    /* Товарный запас. RN (GOODSPARTIES)*/
  ,rMTLGDETREC        out usr_pkg_pub_const.tmtlgdetrec
  )
  is
    rRow              goodsparties%rowtype;
    rDicNomns         dicnomns%rowtype;
  begin
    /* считывание */
    rRow := udo_pkg_get.row_goodsparties(nrn => nGOODSPARTIES, nsmart => 0);

    /* ПРИХОДНАЯ ПАРТИЯ */
    /* запись значений */
    rMTLGDETREC.sPRODUCER      := get_agnlist_agnabbr_id(nflag_smart => 1, nrn => rRow.producer);
    rMTLGDETREC.dEXPIRY_DATE   := rRow.expiry_date;
    rMTLGDETREC.nSTORAGE_TIME  := rRow.storage_time;
    rMTLGDETREC.sUMEAS_STORAGE := case when rRow.umeas_storage is not null then f_dicmunts_get_code(nmeasure_unit => rRow.umeas_storage) end;
    rMTLGDETREC.sCERTIFICATE   := rRow.certificate;
    rMTLGDETREC.sBARCODE       := rRow.barcode;
    rMTLGDETREC.dPROD_DATE     := rRow.prod_date;

    /* СЕРТИФИКАТЫ */
    rMTLGDETREC.dWARRANTY         := get_val_date(ngoodsparties => rRow.rn, stype => 'Дата окончания гарантии');
    rMTLGDETREC.sFACTORY_NUMB     := get_val_str(ngoodsparties  => rRow.rn, stype => 'Заводской номер');
    rMTLGDETREC.sSTORE_CARD       := get_val_str(ngoodsparties  => rRow.rn, stype => 'Складская карточка');
    rMTLGDETREC.sINV_NUMB         := get_val_str(ngoodsparties  => rRow.rn, stype => 'Инвентарный номер');
    rMTLGDETREC.sEQUIPMENT        := get_val_str(ngoodsparties  => rRow.rn, stype => 'Комплектность');
    rMTLGDETREC.sSTATE_REG_NUMB   := get_val_str(ngoodsparties  => rRow.rn, stype => 'Номер в госреестре');
    rMTLGDETREC.sNOTE             := get_val_str(ngoodsparties  => rRow.rn, stype => 'Примечание');
    rMTLGDETREC.dFACT_CHECK_DATE  := get_val_date(ngoodsparties => rRow.rn, stype => 'Фактическая поверка. Дата');
    rMTLGDETREC.dPLAN_CHECK_DATE  := get_val_date(ngoodsparties => rRow.rn, stype => 'Плановая поверка. Дата');
    rMTLGDETREC.sPLAN_CHECK_AGN   := get_val_str(ngoodsparties  => rRow.rn, stype => 'Плановая поверка. Контрагент');
    rMTLGDETREC.nCHECK_INTERVAL   := get_val_num(ngoodsparties  => rRow.rn, stype => 'Интервал поверки');
    rMTLGDETREC.sACC_RESP         := get_val_str(ngoodsparties  => rRow.rn, stype => 'Ответственный в бух.учёте');
    rMTLGDETREC.sFIXED_ASSETS     := get_val_str(ngoodsparties  => rRow.rn, stype => 'Основные средства');
    rMTLGDETREC.sON_VERIF         := get_val_str(ngoodsparties  => rRow.rn, stype => 'На поверке');
    rMTLGDETREC.sVERIF_CERT       := get_val_str(ngoodsparties  => rRow.rn, stype => 'Свидетельство поверки');

    /* НОМЕНКЛАТУРА */
    /* считывание */
    rDicNomns := usr_pkg_dicnomns.dicnomns_get(nrn => usr_pkg_dicnomns.nommodif_get_prn_by_rn(nflagsmart => 0, nrn => rRow.nommodif));
    /* запись значений */
    rMTLGDETREC.nDICNOMNS  := rDicNomns.rn;
    rMTLGDETREC.nWIDTH     := f_dicnomns_get_size(nsize => rDicNomns.width, nmeasure => rDicNomns.mu_size);
    rMTLGDETREC.nHEIGHT    := f_dicnomns_get_size(nsize => rDicNomns.height, nmeasure => rDicNomns.mu_size);
    rMTLGDETREC.nLENGTH    := f_dicnomns_get_size(nsize => rDicNomns.length, nmeasure => rDicNomns.mu_size);
    rMTLGDETREC.sMU_SIZE   := usr_pkg_dicnomns.get_mu_size_by_val(nvalue => rDicNomns.mu_size);
    rMTLGDETREC.nWEIGHT    := f_dicnomns_get_weight(nweight => rDicNomns.weight, nmeasure => rDicNomns.mu_weight);
    rMTLGDETREC.sMU_WEIGHT := usr_pkg_dicnomns.get_mu_weight_by_val(nvalue => rDicNomns.mu_weight);

    /* ПРОЧЕЕ */
    rMTLGDETREC.sManual                 := 'Нет';
    rMTLGDETREC.sSpecs                  := 'Нет';
    rMTLGDETREC.sListOfDevicesExist     := 'Нет';
    rMTLGDETREC.sListOfIndicatorsExist  := 'Нет';
    rMTLGDETREC.sListOfDevicesLSExist   := 'Нет';

    begin
      select 'Да'
        into rMTLGDETREC.sManual
        from filelinks      fl
            ,filelinksunits flu
            ,goodsparties   gp
            ,nommodif       nm
       where flu.filelinks_prn = fl.rn
         and fl.file_type      = 122299697 /* !!!!!! Руков.по экспл. */
         and gp.nommodif       = nm.rn
         and nm.prn            = flu.table_prn
         and gp.rn             = rRow.rn;
    exception
      when no_data_found then
        null;     
      when too_many_rows then
        null;     
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске присоединённого документа с типом "Руков.по экспл." для приходной партии с RN: %s', rRow.rn); 
    end;

    begin
      select 'Да'
        into rMTLGDETREC.sSpecs
        from filelinks fl
            ,filelinksunits flu
            ,goodsparties gp
            ,nommodif       nm
       where flu.filelinks_prn = fl.rn
         and fl.file_type      = 122299756 /* !!!!!! Характеристики */
         and gp.nommodif       = nm.rn
         and nm.prn            = flu.table_prn
         and gp.rn             = rRow.rn;
    exception
      when no_data_found then
        null;     
      when too_many_rows then
        null;     
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске присоединённого документа с типом "Характеристики" для приходной партии с RN: %s', rRow.rn); 
    end;

    begin
      select 'Да'
        into rMTLGDETREC.sListOfDevicesExist
        from payaccspecs  pas
            ,payacc       pa
       where pas.goodsparty = rRow.rn
         and pa.rn          = pas.prn
         and pa.doctype     = 122611152 ;
    exception
      when no_data_found then
        null;     
      when too_many_rows then
        p_exception(0, 'Найдено больше одного документа "Перечень приборов" %s года, в который включена приходная партия с RN: %s'
                   ,to_char(current_date, 'YYYY'), rRow.rn); 
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске документа "Перечень приборов" %s года, в который включена приходная партия с RN: %s'
                   ,to_char(current_date, 'YYYY'), rRow.rn); 
    end;

    begin
      select 'Да'
        into rMTLGDETREC.sListOfIndicatorsExist
        from payaccspecs  pas
            ,payacc       pa
       where pas.goodsparty = rRow.rn
         and pa.rn          = pas.prn
         and pa.doctype     = 122611093;
    exception
      when no_data_found then
        null;     
      when too_many_rows then
        p_exception(0, 'Найдено больше одного документа "Перечень индикаторов" %s года, в который включена приходная партия с RN: %s'
                   ,to_char(current_date, 'YYYY'), rRow.rn); 
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске документа "Перечень индикаторов" %s года, в который включена приходная партия с RN: %s'
                   ,to_char(current_date, 'YYYY'), rRow.rn); 
    end;

    begin
      select 'Да'
        into rMTLGDETREC.sListOfDevicesLSExist
        from payaccspecs  pas
            ,payacc       pa
       where pas.goodsparty = rRow.rn
         and pa.rn          = pas.prn
         and pa.doctype     = 122611171;
    exception
      when no_data_found then
        null;     
      when too_many_rows then
        p_exception(0, 'Найдено больше одного документа "Перечень приборов длительного хранения" %s года, в который включена приходная партия с RN: %s'
                   ,to_char(current_date, 'YYYY'), rRow.rn); 
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске документа "Перечень приборов длительного хранения" %s года, в который включена приходная партия с RN: %s'
                   ,to_char(current_date, 'YYYY'), rRow.rn); 
    end;

  end GET_VALS;
  --#########################################################################################################

  procedure CHECK_VAL
  /*
  Проверка записи дополнительных данных (сертификата)
  */
  (
   rROW     in certification%rowtype
  ,sTYPE    in varchar2
  ) 
  is
    rCertificationSp  certificationsp%rowtype;
  begin
    /* Спецификация */
    begin
      select *
        into rCertificationSp
        from certificationsp
       where prn = rROW.RN;
    exception
      when no_data_found then
        p_exception(0, 'Отсутствует сертифицируемый товар у сертификата. %s'
                   ,cr||f_docdescrs_get_description('Certificates', rROW.RN)); 
      when too_many_rows then
        p_exception(0, 'Больше одного сертифицируемого товара у сертификата. %s'
                   ,cr||f_docdescrs_get_description('Certificates', rROW.RN)); 
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске сертифицируемого товара длясертификата. %s'
                   ,cr||f_docdescrs_get_description('Certificates', rROW.RN)); 
    end;
    /* Поиск аналогичной записи в каталоге Дополнительные данные приходных партий, у которой такие же свойство Тип данных метрологии и RN приходной партии */
    for c in (
              select s.*
                from certificationsp s, certification h
               where h.rn     = s.prn
                 and 1        = usr_pkg_common.is_crn_in_hiercrn(ncrn            => h.crn
                                                                ,shier_crn_list2 => 97525163)
                 and s.rn    != rCertificationSp.rn
                 and s.party  = rCertificationSp.party
                 and 1        = cmp_vc2(f_docs_props_get_str_value(nproperty => 97644642, sunitcode => 'Certificates', ndocument => h.rn)
                                       ,sTYPE) 
             )
    loop
      p_exception(0, 'Дублирование типа данных. %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
    end loop;
    
    /* Орган по сертификации всегда Модуль */
    if rROW.company_cert != 92146 then
      p_exception(0, 'Поле "Орган по сертификации" должно иметь значение <%s>.%s'
                 ,get_agnlist_agnabbr_id(nflag_smart => 0, nrn => 92146)
                 ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
    end if;

    /* Проверка доп данных */
    case sTYPE
      when 'Дата окончания гарантии' then
        if rROW.DATE_TO is null then
          p_exception(0, 'Не заполнено поле "Срок действия по...".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Складская карточка' then
        if rROW.NOTE is null then
          p_exception(0, 'Не заполнено поле "Складская карточка".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Заводской номер' then
        if rROW.NOTE is null then
          p_exception(0, 'Не заполнено поле "Примечание".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Инвентарный номер' then
        if rROW.NOTE is null then
          p_exception(0, 'Не заполнено поле "Примечание".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Комплектность' then
        if rROW.NOTE is null then
          p_exception(0, 'Не заполнено поле "Примечание".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Номер в госреестре' then
        if rROW.NOTE is null then
          p_exception(0, 'Не заполнено поле "Примечание".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Фактическая поверка. Дата' then
        if rROW.date_to is null then
          p_exception(0, 'Не заполнено поле "Срок действия по...".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Плановая поверка. Дата' then
        if rROW.date_to is null then
          p_exception(0, 'Не заполнено поле "Срок действия по...".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Плановая поверка. Контрагент' then
        if rROW.company_cert_expert is null then
          p_exception(0, 'Не заполнено поле "Эксперт по сертификации".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Интервал поверки' then
        if rROW.NOTE is null then
          p_exception(0, 'Не заполнено поле "Интервал поверки".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Примечание' then
        if rROW.NOTE is null then
          p_exception(0, 'Не заполнено поле "Примечание".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Ответственный в бух.учёте' then
        if rROW.NOTE is null then
          p_exception(0, 'Не заполнено поле "Ответственный в бух.учёте".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Основные средства' then
        if rROW.NOTE is null then
          p_exception(0, 'Не заполнено поле "Основные средства".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'На поверке' then
        if rROW.NOTE is null then
          p_exception(0, 'Не заполнено поле "На поверке".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
      when 'Свидетельство поверки' then
        if rROW.NOTE is null then
          p_exception(0, 'Не заполнено поле "Свидетельство поверки".%s'
                     ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
        end if;
    else
      p_exception(0, 'Неверное значение типа дополнительных данных приходной партии <%s>.%s'
                 ,sTYPE
                 ,cr||f_docdescrs_get_description(sunitcode => 'Certificates', ndocument => rROW.RN)); 
    end case;
    
  end CHECK_VAL;
  --#########################################################################################################

  procedure UPDATE_VAL
  /*
  Исправление заданного значения дополнительных данных
  */
  (
   nGOODSPARTIES  in number
  ,sTYPE          in varchar2  /* Значение свойства "Доп.данные прих.парт" */
  ,sVALUE         in varchar2 
  ,dVALUE         in date   
  ,nVALUE         in number
  ) 
  is 
    rCertification    certification%rowtype;
    rCertificationSp  certificationsp%rowtype;
    nCertification    pkg_std.tref; 
    rGoodsParties     goodsparties%rowtype;
    nCertificationSp  pkg_std.tref; 
    
    nNumber           pkg_std.tnumber; 
    dDate             date;
  begin
    /* Считывание приходной партии и сертификата */
    rGoodsParties := usr_pkg_goodsparties.goodsparties_get(nrn => nGOODSPARTIES);
    rCertification := get(ngoodsparties => rGoodsParties.rn, stype => sTYPE);

    /* Если входные значения пустые */
    if sVALUE is null and dVALUE is null and nVALUE is null then
      /* если сертификат со значением есть */
      if rCertification.rn is not null then
        /* удаляем свойство "Доп.данные прих.парт" сертификату */
        pkg_docs_props_vals.modify(nproperty   => 97644642
                                  ,sunitcode   => 'Certificates'
                                  ,ndocument   => rCertification.rn
                                  ,sstr_value  => sTYPE
                                  ,nnum_value  => nNumber
                                  ,ddate_value => dDate
                                  ,nrn         => nNumber);
        /* удаляем */
        p_certification_base_delete(ncompany => rGoodsParties.company, nrn => rCertification.rn);
      end if;
    /* Если входные значения НЕ пустые */
    else
      /* Записываем значения входных переменных в переменную сертификата */
      if sTYPE = 'Плановая поверка. Контрагент' then 
        find_agnlist_by_mnemo(nflag_smart => 1
                             ,ncompany    => rGoodsParties.company
                             ,sagnabbr    => sVALUE
                             ,nrn         => rCertification.company_cert_expert);
      elsif sTYPE in ('Плановая поверка. Дата', 'Дата окончания гарантии', 'Фактическая поверка. Дата') then
        rCertification.date_to := dVALUE;
      elsif sTYPE in ('Складская карточка', 'Заводской номер', 'Инвентарный номер', 'Комплектность', 'Номер в госреестре'
                     ,'Примечание', 'Ответственный в бух.учёте', 'Основные средства', 'На поверке', 'Свидетельство поверки') then
        rCertification.note:= sVALUE;
      elsif sTYPE in ('Интервал поверки') then
        rCertification.note:= trim(nVALUE);
      else
        p_exception(0, 'Неверное значение параметра <sTYPE>: <%s>', sTYPE); 
      end if;
      /* Если сертификат с заданным значением НЕ НАЙДЕН */
      if rCertification.rn is null then
        /* записываем значения в переменную сертификата */
        rCertification.version      := 91322;
        rCertification.company_cert := 92146;
        rCertification.crn          := 97525163;
        rCertification.numb_cert    := 999999999;
        rCertification.date_from    := to_date('01.01.1970', 'dd.mm.yyyy') ;
        /* добавляем сертификат */
        usr_pkg_certification.certification_base_insert(rrow => rCertification, nrn => nCertification);
        /* исправляем в сертификате номер на значение RN */
        rCertification.rn         := nCertification;
        rCertification.numb_cert  := rCertification.rn;
        usr_pkg_certification.certification_base_update(rrow => rCertification);
        /* записываем значения в переменную спецификации сертификата */
        rCertificationSp.prn        := rCertification.rn;
        rCertificationSp.version    := rCertification.version;
        rCertificationSp.crn        := rCertification.crn;
        rCertificationSp.nommodif   := rGoodsParties.nommodif;
        rCertificationSp.goodsparty := rGoodsParties.indoc;
        rCertificationSp.sernumb    := rGoodsParties.sernumb;
        rCertificationSp.party      := rGoodsParties.rn;
        /* добавляем спецификацию сертификата */
        usr_pkg_certification.certificationsp_base_insert(rrow => rCertificationSp, nrn => nCertificationSp);
        /* добавляем свойство "Доп.данные прих.парт" сертификату */
        pkg_docs_props_vals.modify(nproperty   => 97644642
                                  ,sunitcode   => 'Certificates'
                                  ,ndocument   => rCertification.rn
                                  ,sstr_value  => sTYPE
                                  ,nnum_value  => nNumber
                                  ,ddate_value => dDate
                                  ,nrn         => nNumber);
        /* проверяем сертификат */
        check_val(rRow => rCertification, stype => sTYPE);
      /* Если сертификат с заданным значением НАЙДЕН */
      else
        /* исправляем сертификат */
        usr_pkg_certification.certification_base_update(rrow => rCertification);
        /* проверяем сертификат */
        check_val(rRow => rCertification, stype => sTYPE);
      end if;
    end if;

  end UPDATE_VAL;
  --#########################################################################################################

  procedure UPDATE_VALS
  /*
  Исправление всех значений дополнительных данных товарного запаса
  */
  (
   rMTLGDETREC        in usr_pkg_pub_const.tmtlgdetrec
  ) 
  is
    rMtlgDetRecOld      usr_pkg_pub_const.tmtlgdetrec;
  
    rGoodsParties       goodsparties%rowtype;
    rDicNomns           dicnomns%rowtype;
  begin
    /* Старые значения */
    get_vals(ngoodsparties => rMTLGDETREC.NGOODSPARTIES, rmtlgdetrec => rMtlgDetRecOld);

    /* Считывание записей */
    /* приходная партия */
    rGoodsParties := udo_pkg_get.row_goodsparties(nrn => rMTLGDETREC.NGOODSPARTIES, nsmart => 0);
    /* номенклатор */
    rDicNomns := udo_pkg_get.row_dicnomns(nrn => rMtlgDetRecOld.ndicnomns, nsmart => 0);
    
    /* ПРИХОДНАЯ ПАРТИЯ */
    /* Параметры изменились */
    if cmp_vc2(rMtlgDetRecOld.sPRODUCER || rMtlgDetRecOld.dEXPIRY_DATE || rMtlgDetRecOld.nSTORAGE_TIME || rMtlgDetRecOld.sUMEAS_STORAGE 
              || rMtlgDetRecOld.sCERTIFICATE || rMtlgDetRecOld.sBARCODE || rMtlgDetRecOld.dPROD_DATE || rMtlgDetRecOld.sACC_RESP || rMtlgDetRecOld.sFIXED_ASSETS
              ,rMTLGDETREC.sPRODUCER || rMTLGDETREC.dEXPIRY_DATE || rMTLGDETREC.nSTORAGE_TIME || rMTLGDETREC.sUMEAS_STORAGE 
              || rMTLGDETREC.sCERTIFICATE || rMTLGDETREC.sBARCODE || rMTLGDETREC.dPROD_DATE || rMTLGDETREC.sACC_RESP || rMTLGDETREC.sFIXED_ASSETS
              ) != 1 then
      /* подставновка новых значений в запись */
      p_goodsparties_joins(ncompany       => rGoodsParties.company
                          ,sproducer      => rMTLGDETREC.sPRODUCER
                          ,nproducer      => rGoodsParties.producer
                          ,sumeas_storage => rMTLGDETREC.sUMEAS_STORAGE
                          ,numeas_storage => rGoodsParties.umeas_storage);
      rGoodsParties.expiry_date   := rMTLGDETREC.dEXPIRY_DATE;
      rGoodsParties.storage_time  := rMTLGDETREC.nSTORAGE_TIME;
      rGoodsParties.certificate   := rMTLGDETREC.sCERTIFICATE;
      rGoodsParties.barcode       := rMTLGDETREC.sBARCODE;
      rGoodsParties.prod_date     := rMTLGDETREC.dPROD_DATE;
      /* исправление */
      usr_pkg_goodsparties.goodsparties_base_update(rrow => rGoodsParties);
    end if;

    /* СЕРТИФИКАТЫ */
    /* Параметры изменились */
    if cmp_dat(rMtlgDetRecOld.dWarranty, rMTLGDETREC.dWARRANTY) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Дата окончания гарантии'
                ,svalue        => null
                ,dvalue        => rMTLGDETREC.dWARRANTY
                ,nvalue        => null);
    end if;
    if cmp_vc2(rMtlgDetRecOld.sStore_card, rMTLGDETREC.sSTORE_CARD) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Складская карточка'
                ,svalue        => rMTLGDETREC.sSTORE_CARD
                ,dvalue        => null
                ,nvalue        => null);
    end if;
    if cmp_vc2(rMtlgDetRecOld.sFactory_numb, rMTLGDETREC.sFACTORY_NUMB) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Заводской номер'
                ,svalue        => rMTLGDETREC.sFACTORY_NUMB
                ,dvalue        => null
                ,nvalue        => null);
    end if;
    if cmp_vc2(rMtlgDetRecOld.sInv_numb, rMTLGDETREC.sINV_NUMB) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Инвентарный номер'
                ,svalue        => rMTLGDETREC.sINV_NUMB
                ,dvalue        => null
                ,nvalue        => null);
    end if;
    if cmp_vc2(rMtlgDetRecOld.sEquipment, rMTLGDETREC.sEQUIPMENT) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Комплектность'
                ,svalue        => rMTLGDETREC.sEQUIPMENT
                ,dvalue        => null
                ,nvalue        => null);
    end if;
    if cmp_vc2(rMtlgDetRecOld.sState_reg_numb, rMTLGDETREC.sSTATE_REG_NUMB) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Номер в госреестре'
                ,svalue        => rMTLGDETREC.sSTATE_REG_NUMB
                ,dvalue        => null
                ,nvalue        => null);
    end if;
    if cmp_vc2(rMtlgDetRecOld.sNote, rMTLGDETREC.sNOTE) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Примечание'
                ,svalue        => rMTLGDETREC.sNOTE
                ,dvalue        => null
                ,nvalue        => null);
    end if;
    if cmp_dat(rMtlgDetRecOld.dFact_check_date, rMTLGDETREC.dFACT_CHECK_DATE) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Фактическая поверка. Дата'
                ,svalue        => null
                ,dvalue        => rMTLGDETREC.dFACT_CHECK_DATE
                ,nvalue        => null);
    end if;
    if cmp_dat(rMtlgDetRecOld.dPlan_check_date, rMTLGDETREC.dPLAN_CHECK_DATE) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Плановая поверка. Дата'
                ,svalue        => null
                ,dvalue        => rMTLGDETREC.dPLAN_CHECK_DATE
                ,nvalue        => null);
    end if;
    if cmp_vc2(rMtlgDetRecOld.sPlan_check_agn, rMTLGDETREC.sPLAN_CHECK_AGN) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Плановая поверка. Контрагент'
                ,svalue        => rMTLGDETREC.sPLAN_CHECK_AGN
                ,dvalue        => null
                ,nvalue        => null);
    end if;
    if cmp_num(rMtlgDetRecOld.nCheck_interval, rMTLGDETREC.nCHECK_INTERVAL) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Интервал поверки'
                ,svalue        => null
                ,dvalue        => null
                ,nvalue        => rMTLGDETREC.nCHECK_INTERVAL);
    end if;
    if cmp_vc2(rMtlgDetRecOld.sAcc_Resp, rMTLGDETREC.sACC_RESP) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Ответственный в бух.учёте'
                ,svalue        => rMTLGDETREC.sACC_RESP
                ,dvalue        => null
                ,nvalue        => null);
    end if;
    if cmp_vc2(rMtlgDetRecOld.sFixed_Assets, rMTLGDETREC.sFIXED_ASSETS) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Основные средства'
                ,svalue        => rMTLGDETREC.sFIXED_ASSETS
                ,dvalue        => null
                ,nvalue        => null);
    end if;
    if cmp_vc2(rMtlgDetRecOld.sOn_Verif, rMTLGDETREC.sON_VERIF) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'На поверке'
                ,svalue        => rMTLGDETREC.sON_VERIF
                ,dvalue        => null
                ,nvalue        => null);
    end if;
    if cmp_vc2(rMtlgDetRecOld.sVerif_Cert, rMTLGDETREC.sVERIF_CERT) != 1 then
      update_val(ngoodsparties => rGoodsParties.rn
                ,stype         => 'Свидетельство поверки'
                ,svalue        => rMTLGDETREC.sVERIF_CERT
                ,dvalue        => null
                ,nvalue        => null);
    end if;
    
    /* НОМЕНКЛАТОР */
    /* Параметры изменились */
    if cmp_vc2(rMtlgDetRecOld.nWidth || rMtlgDetRecOld.nHeight || rMtlgDetRecOld.nLength || rMtlgDetRecOld.nWeight 
              ,rMTLGDETREC.nWIDTH || rMTLGDETREC.nHEIGHT || rMTLGDETREC.nLENGTH || rMTLGDETREC.nWEIGHT ) != 1 then
      /* подставновка новых значений в запись */
      rDicNomns.width     := rMTLGDETREC.nWIDTH;
      rDicNomns.height    := rMTLGDETREC.nHEIGHT;
      rDicNomns.length    := rMTLGDETREC.nLENGTH;
      rDicNomns.mu_size   := nvl(usr_pkg_dicnomns.get_mu_size_by_code(scode => rMTLGDETREC.sMU_SIZE), rDicNomns.mu_size);
      rDicNomns.weight    := rMTLGDETREC.nWEIGHT;
      rDicNomns.mu_weight := nvl(usr_pkg_dicnomns.get_mu_weight_by_code(scode => rMTLGDETREC.sMU_WEIGHT), rDicNomns.mu_weight);
      /* исправление */
      usr_pkg_dicnomns.dicnomns_base_update(rrow => rDicNomns, ncompany => rGoodsParties.company);
    end if;

  end UPDATE_VALS;
  --#########################################################################################################

  procedure COPY_VALS
  /*
  Скопировать доп.данные Приходной партии из другой 
  */
  (
   nGOODSPARTIES        in number  /* Приходная партия "куда". RN */
  ,nGOODSPARTIES_FROM   in number  /* Приходная партия "откуда". RN */
  ,nDELETE_FROM         in number  /* Удалить данные Приходной партии "откуда": 0 - нет, 1 - да */
  )
  is
    rRow              goodsparties%rowtype;
    rMtlgDetRec       usr_pkg_pub_const.tmtlgdetrec;
    rMtlgDetRecFrom   usr_pkg_pub_const.tmtlgdetrec;
  begin
    /* Считывание записи текущей Приходной партии */
    rRow := usr_pkg_goodsparties.goodsparties_get(nrn => nGOODSPARTIES);

    /* Получение доп.данных Приходной партии "откуда" */
    get_vals(ngoodsparties => nGOODSPARTIES_FROM, rmtlgdetrec => rMtlgDetRecFrom);

    /* Копирование доп.данных "откуда" в массив для текущей партии */
    rMtlgDetRec := rMtlgDetRecFrom;

    /* Подмена в массиве текущей партии RN Приходной партии и номенклатуры */
    rMtlgDetRec.ngoodsparties := rRow.rn;
    rMtlgDetRec.ndicnomns     := usr_pkg_dicnomns.nommodif_get_prn_by_rn(nflagsmart => 0, nrn => rRow.nommodif) ;

    /* Добавление доп.данных в текущую партию */
    update_vals(rmtlgdetrec => rMtlgDetRec);

    /* Если Удалить данные Приходной партии "откуда" */
    if cmp_num(nDELETE_FROM, 1) = 1 then
      /* Удаление */
      delete_vals(ngoodsparties => nGOODSPARTIES_FROM);
    end if;
    
  end COPY_VALS;
  --#########################################################################################################

  procedure DELETE_VALS
  /*
  Удалить доп.данные Приходной партии
  */
  (
   nGOODSPARTIES    in number  
  )
  is
    rMtlgDetRec       usr_pkg_pub_const.tmtlgdetrec;
  begin
    /* Подстановка RN Приходной партии в пустую переменную */
    rMtlgDetRec.ngoodsparties := nGOODSPARTIES;

    /* Исправление с пустыми значениями (удаление) */
    update_vals(rmtlgdetrec => rMtlgDetRec);

  end DELETE_VALS;
  --#########################################################################################################

end USR_PKG_GOODSPARTIES_ADD;
/
