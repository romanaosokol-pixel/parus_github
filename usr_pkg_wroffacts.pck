create or replace package USR_PKG_WROFFACTS is
  /*
  Package предназначен для работы с разделом "Акты списания недостач/оприходования излишков". 
  WriteOffActs          WROFFACTS         WOA
  WriteOffActsSpecs     WROFFACTSPECS     WOAS
  WriteOffActsBuff      WROFFACTSBUF      WOA   Акты списания недостач/оприходования излишков: буфер формирования
  WriteOffActsSpecs     WROFFACTSPECSBUF  WOASB Акты списания недостач/оприходования излишков (спецификаця): буфер формирования
  */
  --#########################################################################################################

  function WROFFACTS_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return wroffacts%rowtype;
  --#########################################################################################################

  procedure WROFFACTS_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure WROFFACTS_BUPDATE
  /*
  Заголовок. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure WROFFACTS_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure WROFFACTS_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure WROFFACTS_BWORK
  /*
  Заголовок. Изменение состояния. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure WROFFACTS_AWORK
  /*
  Заголовок. Изменение состояния. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure WROFFACTS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure WROFFACTS_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in wroffacts%rowtype
  );
  --#########################################################################################################

  function WROFFACTSPECS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return wroffactspecs%rowtype;
  --#########################################################################################################

  procedure WROFFACTSPECS_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure WROFFACTSPECS_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure WROFFACTSPECS_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure WROFFACTSPECS_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  --#########################################################################################################

  procedure WROFFACTSPECS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure WROFFACTSPECS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in wroffactspecs%rowtype
  );
  --#########################################################################################################

  function WROFFACTSPECSBUF_GET
  /*
  Спецификация (буфер). Считывание 
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return wroffactspecsbuf%rowtype;
  --#########################################################################################################

  procedure WROFFACTSPECSBUF_BASE_INSERT
  /*
  Акты списания недостач/оприходования излишков: буфер формирования. Добавление базовое
  */
  (
   rROW         in out wroffactspecsbuf%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

  procedure WROFFACTSPECSBUF_BASE_UPDATE
  /*
  Акты списания недостач/оприходования излишков (спецификаця): буфер формирования. Исправление базовое
  */
  (
   rROW         in wroffactspecsbuf%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  --#########################################################################################################

end USR_PKG_WROFFACTS;
/
create or replace package body USR_PKG_WROFFACTS is

  --#########################################################################################################

  function WROFFACTS_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return wroffacts%rowtype
  is
    rRow wroffacts%rowtype;
  begin
    begin
      select t.* into rRow from wroffacts t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'WROFFACTS');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'WROFFACTS')));
    end;
    return(rRow);
  end WROFFACTS_GET;
  --#########################################################################################################

  procedure WROFFACTS_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow                  wroffacts%rowtype;
    nProjectStageExists   pkg_std.tnumber := 0; 
  begin
    /* Заголовок */
    /*rRow   := WROFFACTS_GET(nRN);*/
    /* Нналичие этапов */
    /*for c in (select 1 from wroffactspecs t where t.prn  = rRow.rn) loop nProjectStageExists := 1; exit; end loop;*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКИ */
    /* Базовая*/
    wroffacts_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rwroffacts := null;*/

  end WROFFACTS_AINSERT;
  --#########################################################################################################

  procedure WROFFACTS_BUPDATE
  /*
  Заголовок. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* Считывание */
    /*usr_pkg_pub_const.rwroffacts := wroffacts_get(nrn => nRN);*/
  end WROFFACTS_BUPDATE;
  --#########################################################################################################

  procedure WROFFACTS_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    wroffacts%rowtype;
  begin
    /* Запись проекта */
    /*rRow := wroffacts_get(nRN => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая */
    wroffacts_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rrowstage := null;*/

  end WROFFACTS_AUPDATE;
  --#########################################################################################################

  procedure WROFFACTS_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Спецификации */
    for c in (select * from wroffactspecs where prn = nRN)
    loop
      wroffactspecs_bdelete(nrn => c.rn, ncompany => c.company);
    end loop;

  end WROFFACTS_BDELETE;
  --#########################################################################################################

  procedure WROFFACTS_BWORK
  /*
  Заголовок. Изменение состояния. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* Считывание */
    /*usr_pkg_pub_const.rwroffacts := wroffacts_get(nrn => nRN);*/
  end WROFFACTS_BWORK;
  --#########################################################################################################

  procedure WROFFACTS_AWORK
  /*
  Заголовок. Изменение состояния. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            wroffacts%rowtype;
  begin
    /* Заголовок */
    rRow := wroffacts_get(nRN => nRN);

    /* ИСПРАВЛЕНИЯ */
    /* Копирование доп.данных из свойств спецификации в приходную партию */
    usr_pkg_document.spec_props_copy_to_gp( nprn => rRow.rn );

    /* ПРОВЕРКИ */
    /* Дата отработки НЕ равна дате документа */
    if cmp_dat(trunc(rRow.work_date), trunc(rRow.docdate)) != 1 then
      p_exception(0, 'Дата отработки %s не равна дате документа %s.%s'
                 ,d2s(trunc(rRow.work_date))
                 ,d2s(trunc(rRow.docdate))
                 ,cr||f_docdescrs_get_description(sunitcode => 'WriteOffActs', ndocument => rRow.rn)); 
    end if;

  end WROFFACTS_AWORK;
  --#########################################################################################################

  procedure WROFFACTS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow              wroffacts%rowtype;
  begin
    null;
    /* Заголовок  */
    /*rRow := wroffacts_get(nRN => nRN);*/
  end WROFFACTS_CHECK_BASE;
  --#########################################################################################################

  procedure WROFFACTS_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in wroffacts%rowtype
  ) 
  is
  begin
    p_wroffacts_base_update(nrn            => rROW.RN
                           ,ncompany       => rROW.COMPANY
                           ,njur_pers      => rROW.JUR_PERS
                           ,ndoctype       => rROW.DOCTYPE
                           ,sdocnumb       => rROW.DOCNUMB
                           ,sdocpref       => rROW.DOCPREF
                           ,ddocdate       => rROW.DOCDATE
                           ,nfaceacc       => rROW.FACEACC
                           ,nstore         => rROW.STORE
                           ,nagent         => rROW.AGENT
                           ,nstoper        => rROW.STOPER
                           ,ncurrency      => rROW.CURRENCY
                           ,ncurcoursum    => rROW.CURCOURSUM
                           ,ncurbasesum    => rROW.CURBASESUM
                           ,nvalid_doctype => rROW.VALID_DOCTYPE
                           ,svalid_numb    => rROW.VALID_NUMB
                           ,dvalid_docdate => rROW.VALID_DOCDATE
                           ,scomments      => rROW.COMMENTS
                           ,sbarcode       => rROW.BARCODE
                           ,nsign_newparty => rROW.SIGN_NEWPARTY
                           /* Обновление 2024/03/28 */
                           ,nORDER_TYPE    => rROW.ORDER_TYPE
                           ,sORDER_NUMB    => rROW.ORDER_NUMB
                           ,dORDER_DATE    => rROW.ORDER_DATE
                           ,nNEED_UTIL     => rROW.NEED_UTIL
                           );
  end WROFFACTS_BASE_UPDATE;
  --#########################################################################################################

  function WROFFACTSPECS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return wroffactspecs%rowtype
  is
    rRow wroffactspecs%rowtype;
  begin
    begin
      select * into rRow from wroffactspecs t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'WROFFACTSPECS');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'WROFFACTSPECS')));
    end;
    return(rRow);
  end WROFFACTSPECS_GET;
  --#########################################################################################################

  procedure WROFFACTSPECS_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         wroffactspecs%rowtype;
  begin
    /* Спецификация */
    /*rRow := wroffactspecs_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    wroffactspecs_check_base(nrn => nRN, ncompany => nCOMPANY);

  end WROFFACTSPECS_AINSERT;
  --#########################################################################################################

  procedure WROFFACTSPECS_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /*usr_pkg_pub_const.rwroffactspecs := wroffactspecs_get(nrn => nRN); */
    
  end WROFFACTSPECS_BUPDATE;
  --#########################################################################################################

  procedure WROFFACTSPECS_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            wroffactspecs%rowtype;
    rGoodsSupply    goodssupply%rowtype;
  begin
    /* Заголовок */
    /*rRow := wroffactspecs_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    wroffactspecs_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rwroffactspecs := null;*/

  end WROFFACTSPECS_AUPDATE;
  --#########################################################################################################

  procedure WROFFACTSPECS_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
    rRow            wroffactspecs%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow := wroffactspecs_get(nrn => nRN);*/
        
  end WROFFACTSPECS_BDELETE;
  --#########################################################################################################

  procedure WROFFACTSPECS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         wroffactspecs%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow    := wroffactspecs_get(nrn => nRN);*/

    /* ПРОВЕРКИ */

  end WROFFACTSPECS_CHECK_BASE;
  --#########################################################################################################

  procedure WROFFACTSPECS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in wroffactspecs%rowtype
  ) 
  is
  begin
    p_wroffactspecs_base_update(nrn           => rROW.RN
                               ,ncompany      => rROW.COMPANY
                               ,nprn          => rROW.PRN
                               ,ngoodssupply  => rROW.GOODSSUPPLY
                               ,nnommodif     => rROW.NOMMODIF
                               ,nnommodifpack => rROW.NOMMODIFPACK
                               ,narticle      => rROW.ARTICLE
                               ,ncell         => rROW.CELL
                               ,nquant        => rROW.QUANT
                               ,nquantalt     => rROW.QUANTALT
                               ,nprice        => rROW.PRICE
                               ,npricemeas    => rROW.PRICEMEAS
                               ,snote         => rROW.NOTE
                               ,nsumm         => rROW.SUMM
                               /* Обновление 2024/03/28 */
                               ,sSTR_CODE     => rROW.STR_CODE
                               ,nNORM         => rROW.NORM
                               ,nUSE_PERIOD   => rROW.USE_PERIOD
                               ,nREASON       => rROW.REASON
                               ,sRESOLUTION   => rROW.RESOLUTION
                               );
  end WROFFACTSPECS_BASE_UPDATE;
  --#########################################################################################################

  function WROFFACTSPECSBUF_GET
  /*
  Спецификация (буфер). Считывание 
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return wroffactspecsbuf%rowtype
  is
    rRow wroffactspecsbuf%rowtype;
  begin
    begin
      select * into rRow from wroffactspecsbuf where RN = NRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => NRN, sunit_table => 'WROFFACTSPECSBUF');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.%s'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'WROFFACTSPECSBUF'))
                   ,cr||cr||sqlerrm );
    end;
    return(rRow);
  end WROFFACTSPECSBUF_GET;
  --#########################################################################################################

  procedure WROFFACTSPECSBUF_BASE_INSERT
  /*
  Спецификация (буфер). Добавление базовое
  */
  (
   rROW         in out wroffactspecsbuf%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_wroffactspecsbuf_base_insert(ncompany      => rROW.COMPANY
                                    ,nprn          => rROW.PRN
                                    ,ngoodssupply  => rROW.GOODSSUPPLY
                                    ,nnommodif     => rROW.NOMMODIF
                                    ,nnommodifpack => rROW.NOMMODIFPACK
                                    ,narticle      => rROW.ARTICLE
                                    ,ncell         => rROW.CELL
                                    ,nquant        => rROW.QUANT
                                    ,nquantalt     => rROW.QUANTALT
                                    ,nprice        => rROW.PRICE
                                    ,npricemeas    => rROW.PRICEMEAS
                                    ,nsumm         => rROW.SUMM
                                    ,snote         => rROW.NOTE
                                    ,sstr_code     => rROW.STR_CODE
                                    ,nnorm         => rROW.NORM
                                    ,nuse_period   => rROW.USE_PERIOD
                                    ,nreason       => rROW.REASON
                                    ,sresolution   => rROW.RESOLUTION
                                    ,nrn           => rROW.RN);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
  end WROFFACTSPECSBUF_BASE_INSERT;
  --#########################################################################################################

  procedure WROFFACTSPECSBUF_BASE_UPDATE
  /*
  Спецификация (буфер). Исправление базовое
  */
  (
   rROW         in wroffactspecsbuf%rowtype
  ,nMODE        in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_wroffactspecsbuf_base_update(nrn           => rROW.RN
                                    ,nident        => rROW.IDENT
                                    ,ncompany      => rROW.COMPANY
                                    ,nprn          => rROW.PRN
                                    ,ngoodssupply  => rROW.GOODSSUPPLY
                                    ,nnommodif     => rROW.NOMMODIF
                                    ,nnommodifpack => rROW.NOMMODIFPACK
                                    ,narticle      => rROW.ARTICLE
                                    ,ncell         => rROW.CELL
                                    ,nquant        => rROW.QUANT
                                    ,nquantalt     => rROW.QUANTALT
                                    ,nprice        => rROW.PRICE
                                    ,npricemeas    => rROW.PRICEMEAS
                                    ,snote         => rROW.NOTE
                                    ,nsumm         => rROW.SUMM
                                    ,sstr_code     => rROW.STR_CODE
                                    ,nnorm         => rROW.NORM
                                    ,nuse_period   => rROW.USE_PERIOD
                                    ,nreason       => rROW.REASON
                                    ,sresolution   => rROW.RESOLUTION);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;
  end WROFFACTSPECSBUF_BASE_UPDATE;
   --#########################################################################################################
  
end USR_PKG_WROFFACTS;
/
