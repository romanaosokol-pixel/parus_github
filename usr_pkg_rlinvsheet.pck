create or replace package USR_PKG_RLINVSHEET is
  /*
  Package предназначен для работы с разделом "Ведомости инвентаризации". 
  RealizationInventorySheet           RLINVSHEET       RIS
  RealizationInventorySheetSpec       RLINVSHEETSPEC   RISS
  RealizationInventorySheetSpecCalcs  RLINVSHEETCLC    RISSC
  */
  /* ######################################################################################################### */

  function RLINVSHEET_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return rlinvsheet%rowtype;
  /* ######################################################################################################### */

  procedure RLINVSHEET_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEET_BUPDATE
  /*
  Заголовок. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEET_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEET_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEET_BPROCESS
  /*
  Заголовок. Изменение состояния. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEET_APROCESS
  /*
  Заголовок. Изменение состояния. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEET_BMAKEWABUF_EXCESS
  /*
  Заголовок. Формирование актов оприходования излишков. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEET_AMAKEWABUF_EXCESS
  /*
  Заголовок. Формирование актов оприходования излишков. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEET_BMAKEWABUF_DEFICIT
  /*
  Заголовок. Формирование актов списания недостач. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEET_AMAKEWABUF_DEFICIT
  /*
  Заголовок. Формирование актов списания недостач. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEET_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEET_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in rlinvsheet%rowtype
  );
  /* ######################################################################################################### */

  procedure RLINVSHEET_MAKEWABUF_CORRECT
  /*
  Заголовок. Корректировка буфера формирования актов
  */
  ;
  /* ######################################################################################################### */

  function RLINVSHEETSPEC_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return rlinvsheetspec%rowtype;
  /* ######################################################################################################### */

  procedure RLINVSHEETSPEC_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEETSPEC_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEETSPEC_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEETSPEC_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEETSPEC_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEETSPEC_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in rlinvsheetspec%rowtype
  );
  /* ######################################################################################################### */

  function RLINVSHEETCLC_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return rlinvsheetclc%rowtype;
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_CHECK_BASE
  /*
  Калькуляция. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_BASE_INSERT
  /*
  Калькуляция. Добавление базовое
  */
  (
   rROW     in rlinvsheetclc%rowtype
  ,nRN      out number
  );
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_BASE_UPDATE
  /*
  Калькуляция. Исправление базовое
  */
  (
   rROW             in rlinvsheetclc%rowtype
  );
  /* ######################################################################################################### */

end USR_PKG_RLINVSHEET;
/
create or replace package body USR_PKG_RLINVSHEET is

  /* ######################################################################################################### */

  function RLINVSHEET_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return rlinvsheet%rowtype
  is
    rRow rlinvsheet%rowtype;
  begin
    begin
      select t.* into rRow from rlinvsheet t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'RLINVSHEET');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'RLINVSHEET')));
    end;
    return(rRow);
  end RLINVSHEET_GET;
  /* ######################################################################################################### */

  procedure RLINVSHEET_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow                  rlinvsheet%rowtype;
    nProjectStageExists   pkg_std.tnumber := 0; 
  begin
    /* Заголовок */
    /*rRow   := RLINVSHEET_GET(nRN);*/
    /* Нналичие этапов */
    /*for c in (select 1 from rlinvsheetspec t where t.prn  = rRow.rn) loop nProjectStageExists := 1; exit; end loop;*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКИ */
    /* Базовая*/
    rlinvsheet_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rrlinvsheet := null;*/

  end RLINVSHEET_AINSERT;
  /* ######################################################################################################### */

  procedure RLINVSHEET_BUPDATE
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
    /*usr_pkg_pub_const.rrlinvsheet := rlinvsheet_get(nrn => nRN);*/
  end RLINVSHEET_BUPDATE;
  /* ######################################################################################################### */

  procedure RLINVSHEET_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    rlinvsheet%rowtype;
  begin
    /* Запись проекта */
    /*rRow := rlinvsheet_get(nRN => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая */
    rlinvsheet_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rrowstage := null;*/

  end RLINVSHEET_AUPDATE;
  /* ######################################################################################################### */

  procedure RLINVSHEET_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    /* Проверка спецификаций */
    for c in (select * from rlinvsheetspec where prn = nRN)
    loop
      rlinvsheetspec_bdelete(nrn => c.rn, ncompany => c.company);
    end loop;

  end RLINVSHEET_BDELETE;
  /* ######################################################################################################### */

  procedure RLINVSHEET_BPROCESS
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
    /*usr_pkg_pub_const.rrlinvsheet := rlinvsheet_get(nrn => nRN);*/
  end RLINVSHEET_BPROCESS;
  /* ######################################################################################################### */

  procedure RLINVSHEET_APROCESS
  /*
  Заголовок. Изменение состояния. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* ПРОВЕРКИ */
    /* Только если до утверждения статус был Не утверждён */
    /*if usr_pkg_pub_const.rrlinvsheet.status = 0 then
      \* По этапам *\
      for c in (select * from rlinvsheetspec where prn = nRN)
      loop
        \* базовая проверка этапа *\
        rlinvsheetspec_check_base(nrn => c.rn, ncompany => c.company);
      end loop;

      \* Базовая *\
      rlinvsheet_check_base(nrn => nRN, ncompany => nCOMPANY);
    end if;*/

  end RLINVSHEET_APROCESS;
  /* ######################################################################################################### */

  procedure RLINVSHEET_BMAKEWABUF_EXCESS
  /*
  Заголовок. Формирование актов оприходования излишков. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow                rlinvsheet%rowtype;
  begin
    /* Считывание */
    /*rRow := rlinvsheet_get( nRN => nRN );
    usr_pkg_pub_const.rrlinvsheet := rRow;*/

    /* Корректировка буфера */
    rlinvsheet_makewabuf_correct;

  end RLINVSHEET_BMAKEWABUF_EXCESS;
  /* ######################################################################################################### */

  procedure RLINVSHEET_AMAKEWABUF_EXCESS
  /*
  Заголовок. Формирование актов оприходования излишков. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    /* Список сформированных документов */
    /* Сохраняем в константу */
    usr_pkg_pub_const.arnlist.delete;
    usr_pkg_pub_const.arnlist := usr_pkg_common.get_amake_document_rn_list;
 
    /* По сформированным документам */
    for c in (select woa.rn, woa.crn
                from table(cast(usr_pkg_pub_const.arnlist as udo_tp_numtable)) t
                    ,wroffacts  woa
               where t.column_value = woa.rn) 
    loop
      /* Проверки не выполняются в клиентской процедуре формирования, запускаем здесь */
      /* проверка прав доступа */
      pkg_env.prologue( ncompany => nCOMPANY
                      , nversion => null
                      , ncatalog => c.crn
                      , sunit    => 'WriteOffActs'
                      , saction  => 'WROFF_INSERT'
                      , stable   => 'WROFFACTS' );
      /* фиксация окончания выполнение действия */
      pkg_env.epilogue( ncompany  => nCOMPANY
                      , nversion  => null
                      , ncatalog  => c.crn
                      , sunit     => 'WriteOffActs'
                      , saction   => 'WROFF_INSERT'
                      , stable    => 'WROFFACTS'
                      , ndocument => c.rn );

      /* По спецификациям сформированных документов */
      for c1 in ( 
                  select t.rn, riss.rn as riss_rn
                    from wroffactspecs        t
                    left join doclinks        dl
                      on dl.out_document      = t.prn 
                    left join rlinvsheetspec  riss
                      on riss.prn             = dl.in_document
                   where t.prn         = c.rn
                     and t.goodssupply = riss.goodssupply
                )         
      loop
        /* копирование свойств из аналогичной спецификации родительского документа */
        pkg_docs_props_vals.copy( sunitcode_from => 'RealizationInventorySheetSpec'
                                 ,ndocument_from => c1.riss_rn
                                 ,sunitcode_to   => 'WriteOffActsSpecs'
                                 ,ndocument_to   => c1.rn );
      end loop;                             
    end loop;

  end RLINVSHEET_AMAKEWABUF_EXCESS;
  /* ######################################################################################################### */

  procedure RLINVSHEET_BMAKEWABUF_DEFICIT
  /*
  Заголовок. Формирование актов списания недостач. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow                rlinvsheet%rowtype;
  begin
    /* Считывание */
    /*rRow := rlinvsheet_get( nRN => nRN );
    usr_pkg_pub_const.rrlinvsheet := rRow;*/

    /* Корректировка буфера */
    rlinvsheet_makewabuf_correct;

  end RLINVSHEET_BMAKEWABUF_DEFICIT;
  /* ######################################################################################################### */

  procedure RLINVSHEET_AMAKEWABUF_DEFICIT
  /*
  Заголовок. Формирование актов списания недостач. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    /* Список сформированных документов */
    /* Сохраняем в константу */
    usr_pkg_pub_const.arnlist.delete;
    usr_pkg_pub_const.arnlist := usr_pkg_common.get_amake_document_rn_list;

    /* По сформированным документам */
    for c in (select woa.rn, woa.crn
                from table(cast(usr_pkg_pub_const.arnlist as udo_tp_numtable)) t
                    ,wroffacts  woa
               where t.column_value = woa.rn) 
    loop
      /* Проверки не выполняются в клиентской процедуре формирования, запускаем здесь */
      /* проверка прав доступа (права не проверяются в клиентской процедуре) */
      pkg_env.prologue( ncompany => nCOMPANY
                      , nversion => null
                      , ncatalog => c.crn
                      , sunit    => 'WriteOffActs'
                      , saction  => 'WROFF_INSERT'
                      , stable   => 'WROFFACTS' );
      /* фиксация окончания выполнение действия */
      pkg_env.epilogue( ncompany  => nCOMPANY
                      , nversion  => null
                      , ncatalog  => c.crn
                      , sunit     => 'WriteOffActs'
                      , saction   => 'WROFF_INSERT'
                      , stable    => 'WROFFACTS'
                      , ndocument => c.rn );
    end loop;

  end RLINVSHEET_AMAKEWABUF_DEFICIT;
  /* ######################################################################################################### */

  procedure RLINVSHEET_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow              rlinvsheet%rowtype;
    nProjectStageExists     pkg_std.tnumber := 0; 
  begin
    null;
    /* Заголовок  */
    /*rRow := rlinvsheet_get(nRN => nRN);*/
  end RLINVSHEET_CHECK_BASE;
  /* ######################################################################################################### */

  procedure RLINVSHEET_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in rlinvsheet%rowtype
  ) 
  is
  begin
    p_rlinvsheet_base_update(nrn       => rROW.RN
                            ,ncompany  => rROW.COMPANY
                            ,ndoctype  => rROW.DOCTYPE
                            ,spref     => rROW.PREF
                            ,snumb     => rROW.NUMB
                            ,ddocdate  => rROW.DOCDATE
                            ,nvdoctype => rROW.VDOCTYPE
                            ,svdocnumb => rROW.VDOCNUMB
                            ,dvdocdate => rROW.VDOCDATE
                            ,nstore    => rROW.STORE
                            ,ncell     => rROW.CELL
                            ,nmol      => rROW.MOL
                            ,ncurrency => rROW.CURRENCY
                            ,ndirector => rROW.DIRECTOR
                            ,naccsum   => rROW.ACCSUM
                            ,nfactsum  => rROW.FACTSUM
                            ,nmoresum  => rROW.MORESUM
                            ,nmisssum  => rROW.MISSSUM
                            ,snote     => rROW.NOTE);
  end RLINVSHEET_BASE_UPDATE;
  /* ######################################################################################################### */

  procedure RLINVSHEET_MAKEWABUF_CORRECT
  /*
  Заголовок. Корректировка буфера формирования актов
  */
  is
    aOut_Document       udo_tp_numtable;
    nCurrentIdent       pkg_std.tref; 
    rWrOffActSpecsBuf   wroffactspecsbuf%rowtype;
    nQuant              pkg_std.tquant := 0; 
    nSumm               pkg_std.tsumm  := 0;
  begin
    null;
    /*  
    \* Текущий Ident *\
    nCurrentIdent := usr_pkg_process.get_env_ident(sunitcode => 'RealizationInventorySheet', nmode => 0);

    \* ИСПРАВЛЕНИЕ *\    
    \* По заголовкам буфера *\
    for c in ( select *
                 from wroffactsbuf
                where ident = nCurrentIdent )
    loop
      usr_pkg_doclinks.doclinks_reset_out(nflagsmart    => 1
                                         ,ncompany      => c.company
                                         ,sin_unitcode  => 'RealizationInventorySheet'
                                         ,nin_document  => c.in_docrn
                                         ,sout_unitcode => 'WriteOffActs'
                                         ,aout_document => aOut_Document
                                         ,nmode         => 0);
      \* По спецификациям буфера, у которых есть другие записи с таким же товарным запасом *\
      for c1 in ( select *
                    from wroffactspecsbuf t
                   where t.prn = c.rn 
                     and exists ( select null 
                                    from wroffactspecsbuf a
                                   where a.prn = c.rn 
                                     and a.goodssupply = t.goodssupply
                                     and a.rn         != t.rn ) )
      loop
        \* Считывание текущей записи *\
        rWrOffActSpecsBuf := usr_pkg_wroffacts.wroffactspecsbuf_get( nrn => c1.rn, nflagsmart => 1);
  
        \* Если она была удалена в предыдущем цикле, переходим к следующей *\
        if rWrOffActSpecsBuf.rn is null then
          continue;
        end if;

        \* По другим спецификациям с таким же товарным запасам *\
        for c2 in ( select *
                      from wroffactspecsbuf t
                     where t.prn        = c.rn 
                       and t.goodssupply = c1.goodssupply
                       and t.rn         != c1.rn )
        loop
          \* проверка равентсва цены текущей и другой записи (на всякий случай) *\
          if cmp_num( c1.price, c2.price ) != 1 then 
            p_exception(0, 'Спецификации с одинаковым товарным запасом имеют разнцю цену. Товарный запас RN: %s', rWrOffActSpecsBuf.goodssupply ); 
          end if;
          \* накопление количества и суммы других записей *\
          nQuant := nQuant + c2.quant ;
          nSumm  := nSumm  + c2.summ ;
          \* удаление другой записи *\
          p_wroffactspecsbuf_base_delete( nconpany => c2.company, nrn => c2.rn, nprn => c2.prn );
        end loop;                                     

        \* прибавляем накопленные количество и сумму других записей к текущей *\
        rWrOffActSpecsBuf.quant := rWrOffActSpecsBuf.quant + nQuant ;
        rWrOffActSpecsBuf.summ  := rWrOffActSpecsBuf.summ  + nSumm  ;
        \* исправляем текущую запись *\
        usr_pkg_wroffacts.wroffactspecsbuf_base_update( rrow => rWrOffActSpecsBuf );

      end loop;       
      usr_pkg_doclinks.doclinks_reset_out(nflagsmart    => 1
                                         ,ncompany      => c.company
                                         ,sin_unitcode  => 'RealizationInventorySheet'
                                         ,nin_document  => c.in_docrn
                                         ,sout_unitcode => 'WriteOffActs'
                                         ,aout_document => aOut_Document
                                         ,nmode         => 1);
    end loop; 
    */
  end RLINVSHEET_MAKEWABUF_CORRECT;
  /* ######################################################################################################### */

  function RLINVSHEETSPEC_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return rlinvsheetspec%rowtype
  is
    rRow rlinvsheetspec%rowtype;
  begin
    begin
      select * into rRow from rlinvsheetspec t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'RLINVSHEETSPEC');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'RLINVSHEETSPEC')));
    end;
    return(rRow);
  end RLINVSHEETSPEC_GET;
  /* ######################################################################################################### */

  procedure RLINVSHEETSPEC_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         rlinvsheetspec%rowtype;
  begin
    /* Спецификация */
    /*rRow := rlinvsheetspec_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    rlinvsheetspec_check_base(nrn => nRN, ncompany => nCOMPANY);

  end RLINVSHEETSPEC_AINSERT;
  /* ######################################################################################################### */

  procedure RLINVSHEETSPEC_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    usr_pkg_pub_const.rrlinvsheetspec := rlinvsheetspec_get(nrn => nRN); 
    
  end RLINVSHEETSPEC_BUPDATE;
  /* ######################################################################################################### */

  procedure RLINVSHEETSPEC_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            rlinvsheetspec%rowtype;
    rGoodsSupply    goodssupply%rowtype;
    nNumber         pkg_std.tnumber; 
  begin
    /* Заголовок */
    rRow := rlinvsheetspec_get(nrn => nRN);
    
    /* ИСПРАВЛЕНИЯ */
    /* Если в спецификации была очищена серия или изделие */
    if  usr_pkg_pub_const.rrlinvsheetspec.goodssupply is not null and rRow.goodssupply is null 
    and rROW.Article is null
      then
      /* считываем товарный запас */
      rGoodsSupply := usr_pkg_goodsparties.goodssupply_get(nrn =>  usr_pkg_pub_const.rrlinvsheetspec.goodssupply);
      /* удаляем приходную партию */
      /*p_goodsparties_base_delete(ncompany => usr_pkg_pub_const.rrlinvsheetspec.company, nrn => rGoodsSupply.prn);*/
      p_selectlist_insert(nident    => rGoodsSupply.prn
                         ,ndocument => rGoodsSupply.prn
                         ,sunitcode => 'GoodsParties'
                         ,nrn       => nNumber);
      udo_p_goodsparties_delete(nident => rGoodsSupply.prn, ncompany => rGoodsSupply.company);
      p_selectlist_clear(nident => rGoodsSupply.prn);
    end if;

    /* ПРОВЕРКИ */
    /* Базовая */
    rlinvsheetspec_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    usr_pkg_pub_const.rrlinvsheetspec := null;

  end RLINVSHEETSPEC_AUPDATE;
  /* ######################################################################################################### */

  procedure RLINVSHEETSPEC_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
    rRow            rlinvsheetspec%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow := rlinvsheetspec_get(nrn => nRN);*/
    
    /* Запрет удаление проверенных записей */
    /*if nvl(rRow.sign_fact, 0) = 1 then
      p_exception(0, 'Запрещено удаление спецификации, т.к. она имеет признак "Проверено". %s%s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'RealizationInventorySheetSpec', ndocument => rRow.rn)
                 ,cr||f_docdescrs_get_description(sunitcode => 'RealizationInventorySheet', ndocument => rRow.prn)); 
    end if;*/
    
  end RLINVSHEETSPEC_BDELETE;
  /* ######################################################################################################### */

  procedure RLINVSHEETSPEC_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         rlinvsheetspec%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow    := rlinvsheetspec_get(nrn => nRN);

    /* ПРОВЕРКИ */

  end RLINVSHEETSPEC_CHECK_BASE;
  /* ######################################################################################################### */

  procedure RLINVSHEETSPEC_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in rlinvsheetspec%rowtype
  ) 
  is
  begin
    p_rlinvsheetspec_base_update(ncompany      => rROW.COMPANY
                                ,nrn           => rROW.RN
                                ,nnomen        => rROW.NOMEN
                                ,nnommodif     => rROW.NOMMODIF
                                ,nnommodifpack => rROW.NOMMODIFPACK
                                ,narticle      => rROW.ARTICLE
                                ,ngoodssupply  => rROW.GOODSSUPPLY
                                ,naccquant     => rROW.ACCQUANT
                                ,naccquantalt  => rROW.ACCQUANTALT
                                ,nfactquant    => rROW.FACTQUANT
                                ,nfactquantalt => rROW.FACTQUANTALT
                                ,nmiscalc      => rROW.MISCALC
                                ,nmiscalcalt   => rROW.MISCALCALT
                                ,nprice        => rROW.PRICE
                                ,npricemeas    => rROW.PRICEMEAS
                                ,snote         => rROW.NOTE);
  end RLINVSHEETSPEC_BASE_UPDATE;
  /* ######################################################################################################### */

  function RLINVSHEETCLC_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return rlinvsheetclc%rowtype
  is
    rRow rlinvsheetclc%rowtype;
  begin
    begin
      select * into rRow from rlinvsheetclc t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'RLINVSHEETCLC');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'RLINVSHEETCLC')));
    end;
    return(rRow);
  end RLINVSHEETCLC_GET;
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         rlinvsheetclc%rowtype;
  begin
    /* Спецификация */
    /*rRow := rlinvsheetclc_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    rlinvsheetclc_check_base(nrn => nRN, ncompany => nCOMPANY);

  end RLINVSHEETCLC_AINSERT;
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_BUPDATE
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
  end RLINVSHEETCLC_BUPDATE;
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            rlinvsheetclc%rowtype;
    rGoodsSupply    goodssupply%rowtype;
  begin
    /* Заголовок */
    rRow := rlinvsheetclc_get(nrn => nRN);
    
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    rlinvsheetclc_check_base(nrn => nRN, ncompany => nCOMPANY);

  end RLINVSHEETCLC_AUPDATE;
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
    rRow            rlinvsheetclc%rowtype;
  begin
    null;
  end RLINVSHEETCLC_BDELETE;
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_CHECK_BASE
  /*
  Калькуляция. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         rlinvsheetclc%rowtype;
    rProject      rlinvsheet%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow    := rlinvsheetclc_get(nrn => nRN);
    rProject := rlinvsheet_get(nrn => rRow.prn);*/

    /* ПРОВЕРКИ */

  end RLINVSHEETCLC_CHECK_BASE;
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_BASE_INSERT
  /*
  Калькуляция. Добавление базовое
  */
  (
   rROW     in rlinvsheetclc%rowtype
  ,nRN      out number
  ) 
  is
  begin
    p_rlinvsheetclc_base_insert(ncompany      => rROW.COMPANY
                               ,nprn          => rROW.PRN
                               ,snumb         => rROW.NUMB
                               ,ncost_article => rROW.COST_ARTICLE
                               ,ncost_place   => rROW.COST_PLACE
                               ,ncost_plan    => rROW.COST_PLAN
                               ,ncost_fact    => rROW.COST_FACT
                               ,npriority     => rROW.PRIORITY
                               ,nfaceaccount  => rROW.FACEACCOUNT
                               ,ngraphpoint   => rROW.GRAPHPOINT
                               ,nfinoper_type => rROW.FINOPER_TYPE
                               ,nquant_plan   => rROW.QUANT_PLAN
                               ,nquant_fact   => rROW.QUANT_FACT
                               ,nsubdiv       => rROW.SUBDIV
                               ,nrn           => nRN);
  end RLINVSHEETCLC_BASE_INSERT;
  /* ######################################################################################################### */

  procedure RLINVSHEETCLC_BASE_UPDATE
  /*
  Калькуляция. Исправление базовое
  */
  (
   rROW             in rlinvsheetclc%rowtype
  ) 
  is
  begin
    p_rlinvsheetclc_base_update(nrn           => rROW.RN
                               ,ncompany      => rROW.COMPANY
                               ,snumb         => rROW.NUMB
                               ,ncost_article => rROW.COST_ARTICLE
                               ,ncost_place   => rROW.COST_PLACE
                               ,ncost_plan    => rROW.COST_PLAN
                               ,ncost_fact    => rROW.COST_FACT
                               ,npriority     => rROW.PRIORITY
                               ,nfaceaccount  => rROW.FACEACCOUNT
                               ,ngraphpoint   => rROW.GRAPHPOINT
                               ,nfinoper_type => rROW.FINOPER_TYPE
                               ,nquant_plan   => rROW.QUANT_PLAN
                               ,nquant_fact   => rROW.QUANT_FACT
                               ,nsubdiv       => rROW.SUBDIV);
  end RLINVSHEETCLC_BASE_UPDATE;
  /* ######################################################################################################### */
  
end USR_PKG_RLINVSHEET;
/
