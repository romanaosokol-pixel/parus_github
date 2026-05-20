create or replace package USR_PKG_FCROUTLST is
  /*
  Package предназначен для работы с разделом "Маршрутные листы".
  CostRouteLists                FCROUTLST         RL
  CostRouteListsSpecs           FCROUTLSTSP       RLS
  CostRouteListsSerialNumbers   FCROUTLSTSERNUMB  RLSN
  CostRouteListsOrders          FCROUTLSTORD      RLO
  
  */
  --#########################################################################################################

  function FCROUTLST_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN       in number
  ) 
  return FCROUTLST%ROWTYPE;
  /*#########################################################################################################*/

  function FCROUTLST_GET_PO_RN
  /*
  Заголовок. Поиск RN Заказа на производство
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return number;
  --#########################################################################################################

  procedure FCROUTLST_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_BCHANGE_STATE
  /*
  Заголовок. Проверка до отработки как факт
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) ;
  --#########################################################################################################

  procedure FCROUTLST_ACHANGE_STATE
  /*
  Заголовок. Проверка после отработки как факт
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_BINCFDEP_CREATE
  /*
  Заголовок. Формирование прихода из подразделений. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_AINCFDEP_CREATE
  /*
  Заголовок. Формирование прихода из подразделений. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_BDLVRLST_CREATE
  /*
  Заголовок. Формирование комплектовочной ведомости. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_ADLVRLST_CREATE
  /*
  Заголовок. Формирование комплектовочной ведомости. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_BTRDPT_CREATE
  /*
  Заголовок. Формирование расходных накладных (списание материалов и комплектующих). До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_ATRDPT_CREATE
  /*
  Заголовок. Формирование расходных накладных (списание материалов и комплектующих). После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_BCRT_FCDELIVSH
  /*
  Заголовок. Сформировать комплектовочную ведомость. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_ACRT_FCDELIVSH
  /*
  Заголовок. Сформировать комплектовочную ведомость. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_BREPLACE
  /*
  Заголовок. Проверка до "Заменить маршрут"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) ;
  --#########################################################################################################

  procedure FCROUTLST_AREPLACE
  /*
  Заголовок. Проверка после "Заменить маршрут"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_BCANCEL
  /*
  Заголовок. Проверка до снятия отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_ACANCEL
  /*
  Заголовок. Проверка после снятия отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLST_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  PROCEDURE FCROUTLST_INSERT
  /*
  Заголовок. Добаление
  */
  (
   rV_ROW       in v_fcroutlst%rowtype
  ,nDUP_RN      in number
  ,nRN          out number
  );
  --#########################################################################################################

  PROCEDURE FCROUTLST_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW       in v_fcroutlst%rowtype  -- RN сформированного документа
  );
  --#########################################################################################################

  PROCEDURE FCROUTLST_BASE_INSERT
  /*
  Заголовок. Добаление базовое
  */
  (
   rROW       in fcroutlst%rowtype
  ,nRN        out number
  );
  --#########################################################################################################

  PROCEDURE FCROUTLST_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW       in fcroutlst%rowtype
  );
  --#########################################################################################################

  function FCROUTLSTSP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN       in number
  ) 
  return FCROUTLSTSP%ROWTYPE;
  --#########################################################################################################

  procedure FCROUTLSTSP_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLSTSP_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLSTSP_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLSTSP_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLSTSP_ASET_STATE
  /* 
  Смена состояния строки спецификации маршрутного листа 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) ;
  --#########################################################################################################

  procedure FCROUTLSTSP_BBEGIN
  /*
  Спецификация. Начать работы. До 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLSTSP_ABEGIN
  /*
  Спецификация. Начать работы. После 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLSTSP_BFINISH
  /*
  Спецификация. Закончить работы. До 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLSTSP_AFINISH
  /*
  Спецификация. Закончить работы. После 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLSTSP_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
   --#########################################################################################################
   
  function FCROUTLSTSERNUMB_GET
  /*
  Серийные номера. Считывание записи
  */
  (
   nRN      in number -- RN записи
  ) 
  return FCROUTLSTSERNUMB%rowtype;
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_GET_BY_ART
  /*
  Серийные номера. Поиск по изделию
  */
  (
   nFLAGSMART       in number
  ,nTOO_MANY_ROWS   in number
  ,nARTICLE         in number
  ,nRL_DOCTYPE      in number  /* ТехПаспорт - 12140413, ТП Ремонт - 12141719 */
  ,nRN              out number
  ,nPRN             out number
  );
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_GET_IFD
  /*
  Серийные номера. Поиск прихода из подразделений по серийному номеру. 
  Если найдено больше одного, то возвращать тот, у которого поздняя дата прихода из подразделения
  */
  (
   nFLAGSMART       in number
  ,nTOO_MANY_ROWS   in number   /* Если найдено больше одной записи: 0 - выдавать ошибку, 1 - возвращать запись по условию */
  ,nRN              in number
  ,nIFD             out number
  ,nIFDS            out number
  );
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_AINSERT
  /*
  Серийные номера. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_BDELETE
  /*
  Серийные номера. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_BDLVRLST_CRT
  /*
  Серийные номера. Формирование комплектовочной ведомости. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_ADLVRLST_CRT
  /*
  Серийные номера. Формирование комплектовочной ведомости. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_CHECK_BASE
  /*
  Серийные номера. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  
end USR_PKG_FCROUTLST;
/
create or replace package body USR_PKG_FCROUTLST is

  --#########################################################################################################

  function FCROUTLST_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN      in number -- RN записи
  ) 
  return fcroutlst%rowtype
  is
    rRow fcroutlst%rowtype;
  begin
    begin
      select * into rRow from fcroutlst where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'FCROUTLST');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCROUTLST')));
    end;
    return(rRow);
  end FCROUTLST_GET;
  /*#########################################################################################################*/

  function FCROUTLST_GET_PO_RN
  /*
  Заголовок. Поиск RN Заказа на производство
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0
  ) 
  return number
  is
    rFCProdPlanSp   fcprodplansp%rowtype;
    nProductOrd     pkg_std.tref; 
  begin
    /* Поиск спецификации Планов и отчётов производства */ 
    rFCProdPlanSp.rn := f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                                      ,sout_unitcode => 'CostRouteLists'
                                                      ,nout_document => nRN
                                                      ,sin_unitcode  => 'CostProductPlansSpecs' );
    /* Если найдена спецификация Планов и отчётов производства */ 
    if rFCProdPlanSp.rn is not null then                                                          
      /* Считывание спецификация Планов и отчётов производства */ 
      rFCProdPlanSp := udo_pkg_get.row_fcprodplansp( nrn => rFCProdPlanSp.rn );
      /* Поиск заказа на производство хитрой процедурой */ 
      nProductOrd   := udo_pkg_fcprodplan_utl.sp_get_prodord( nflagsmart  => nFLAGSMART, nprodplansp => rFCProdPlanSp.prn_node );
    end if;

    return( nProductOrd );
    
  end FCROUTLST_GET_PO_RN;
  --#########################################################################################################

  procedure FCROUTLST_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    fcroutlst_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FCROUTLST_AINSERT;
  --#########################################################################################################

  procedure FCROUTLST_BUPDATE
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
  end FCROUTLST_BUPDATE;
  --#########################################################################################################

  procedure FCROUTLST_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    fcroutlst_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FCROUTLST_AUPDATE;
  --#########################################################################################################

  procedure FCROUTLST_BDELETE
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
  end FCROUTLST_BDELETE;
  --#########################################################################################################

  procedure FCROUTLST_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCROUTLST_BMOVE_IN;
  --#########################################################################################################

  procedure FCROUTLST_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
  begin
    null;
  end FCROUTLST_BMOVE_OUT;
  --#########################################################################################################

  procedure FCROUTLST_BCHANGE_STATE
  /*
  Заголовок. Проверка до отработки как факт
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCROUTLST_BCHANGE_STATE;
  --#########################################################################################################

  procedure FCROUTLST_ACHANGE_STATE
  /*
  Заголовок. Проверка после отработки как факт
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    fcroutlst_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FCROUTLST_ACHANGE_STATE;
  --#########################################################################################################

  procedure FCROUTLST_BINCFDEP_CREATE
  /*
  Заголовок. Формирование прихода из подразделений. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            fcroutlst%rowtype;
  begin
    /* Считывание записи */
    rRow := fcroutlst_get(nrn => NRN);

    /* ПРОВЕРКИ */
    /* Лицевой счёт "02023/1" */
    if nvl(rRow.faceacc, 0) = 83660497 then
      p_exception(0, 'Запрещено использовать лицевой счёт %s.%s'
                  ,get_faceacc_numb_id(nflag_smart => 1, nrn => rRow.faceacc)
                  ,cr||f_docdescrs_get_description(sunitcode => 'CostRouteLists', ndocument => rRow.rn)); 
    end if;

  end FCROUTLST_BINCFDEP_CREATE;
  --#########################################################################################################

  procedure FCROUTLST_AINCFDEP_CREATE
  /*
  Заголовок. Формирование прихода из подразделений. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Список сформированных документов */
    /* Сохраняем в константу */
    usr_pkg_pub_const.arnlist.delete;
    usr_pkg_pub_const.arnlist := usr_pkg_common.get_amake_document_rn_list;

    /* По сформированным документам */
    for c in (select column_value from table(cast(usr_pkg_pub_const.arnlist as udo_tp_numtable))) 
    loop
      /* проверка заголовка */
      usr_pkg_incomefromdeps.incomefromdeps_ainsert(nrn => c.column_value, ncompany => nCOMPANY);
    end loop;

  end FCROUTLST_AINCFDEP_CREATE;
  --#########################################################################################################

  procedure FCROUTLST_BDLVRLST_CREATE
  /*
  Заголовок. Формирование комплектовочной ведомости. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow    fcroutlst%rowtype;
  begin
    /* Запись значения в константу идентификатора */  
    usr_pkg_pub_const.nidentbefore := nRN;

  end FCROUTLST_BDLVRLST_CREATE;
  --#########################################################################################################

  procedure FCROUTLST_ADLVRLST_CREATE
  /*
  Заголовок. Формирование комплектовочной ведомости. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            fcroutlst%rowtype;
    sConnect_Ext    pkg_std.tstring := pkg_session.get_connect_ext; 
  begin
    /* Считывание записи */
    rRow := fcroutlst_get(nrn => NRN);

    /* ПРОВЕРКИ */
    /* По сформированным документам */
    for c in (select out_document0 from usr_t_inhierbuff where identbefore = usr_pkg_pub_const.nidentbefore and connect_ext = sConnect_Ext) 
    loop
      /* проверка заголовка */
      usr_pkg_fcdeliverylist.fcdeliverylist_ainsert(nrn => c.out_document0, ncompany => nCOMPANY);
    end loop;

    /* Очистка записей временной таблицы взаимосвязей */  
    delete from usr_t_inhierbuff where identbefore = usr_pkg_pub_const.nidentbefore and connect_ext = sConnect_Ext;
    usr_pkg_pub_const.nidentbefore := null;

    /* Лицевой счёт "02023/1" */
    if nvl(rRow.faceacc, 0) = 83660497 then
      p_exception(0, 'Запрещено использовать лицевой счёт %s.%s'
                  ,get_faceacc_numb_id(nflag_smart => 1, nrn => rRow.faceacc)
                  ,cr||f_docdescrs_get_description(sunitcode => 'CostRouteLists', ndocument => rRow.rn)); 
    end if;
    
  end FCROUTLST_ADLVRLST_CREATE;
  --#########################################################################################################

  procedure FCROUTLST_BTRDPT_CREATE
  /*
  Заголовок. Формирование расходных накладных (списание материалов и комплектующих). До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCROUTLST_BTRDPT_CREATE;
  --#########################################################################################################

  procedure FCROUTLST_ATRDPT_CREATE
  /*
  Заголовок. Формирование расходных накладных (списание материалов и комплектующих). После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* ПРОВЕРКИ */
    /* Базовая */
    /*fcroutlst_check_base(nrn => nRN, ncompany => nCOMPANY);*/

  end FCROUTLST_ATRDPT_CREATE;
  --#########################################################################################################

  procedure FCROUTLST_BCRT_FCDELIVSH
  /*
  Заголовок. Сформировать комплектовочную ведомость. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCROUTLST_BCRT_FCDELIVSH;
  --#########################################################################################################

  procedure FCROUTLST_ACRT_FCDELIVSH
  /*
  Заголовок. Сформировать комплектовочную ведомость. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
    /* ПРОВЕРКИ */
    /* Базовая */
    /*fcroutlst_check_base(nrn => nRN, ncompany => nCOMPANY);*/

  end FCROUTLST_ACRT_FCDELIVSH;
  --#########################################################################################################

  procedure FCROUTLST_BREPLACE
  /*
  Заголовок. Проверка до "Заменить маршрут"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCROUTLST_BREPLACE;
  --#########################################################################################################

  procedure FCROUTLST_AREPLACE
  /*
  Заголовок. Проверка после "Заменить маршрут"
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Копирование ссылок на присоединённые документы из маршрутной карты.
       Карту ищем в любой спецификации маршрутного листа, т.к. в заголовке ссылка на карту не меняется. */
    for c in (select * from fcroutlstsp where prn = nRN)
    loop
      /* Поиск присоединённых документов, привязанных к маршрутному листу, которые также имеют связь с маршрутной картой */
      for c1 in (
                 select t.rn
                   from filelinksunits t 
                  where t.table_prn = nRN
                    and exists (select null
                                  from filelinksunits a
                                 where a.table_prn = c.fcroutsht
                                   and a.filelinks_prn = t.filelinks_prn
                                )
                 )
        loop
          /* удаление */
          p_filelinksunits_base_delete(nrn => c1.rn);
        end loop;

      /* Копирование присоединённых документов из маршрутной карты в маршрутный лист */
      p_filelinksunits_copy(ncompany   => c.company
                           ,nsrc_rn    => c.fcroutsht
                           ,ssrc_unit  => 'CostRouteSheets'
                           ,ndest_rn   => nRN
                           ,sdest_unit => 'CostRouteLists');
      exit;
    end loop;

    /* ПРОВЕРКИ */
    /* Базовая */
    fcroutlst_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FCROUTLST_AREPLACE;
  --#########################################################################################################

  procedure FCROUTLST_BCANCEL
  /*
  Заголовок. Проверка до снятия отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCROUTLST_BCANCEL;
  --#########################################################################################################

  procedure FCROUTLST_ACANCEL
  /*
  Заголовок. Проверка после снятия отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCROUTLST_ACANCEL;
  --#########################################################################################################

  procedure FCROUTLST_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    for rec in(select LST.* from FCROUTLST LST where LST.RN = nRN) loop
      -- контроль указания серийного изделия в шапке
      if rec.article is not null then
        p_exception(0, 'Заводские номера необходимо указывать в отдельном списке.'||chr(10)||
                       'Указывать заводской номер в заголовке МЛ запрещено!');
      end if;
    end loop;
  end FCROUTLST_CHECK_BASE;
  --#########################################################################################################

  PROCEDURE FCROUTLST_INSERT
  /*
  Заголовок. Добаление
  */
  (
   rV_ROW       in v_fcroutlst%rowtype
  ,nDUP_RN      in number
  ,nRN          out number
  ) 
  is
  begin
    p_fcroutlst_insert(ncompany           => rV_ROW.NCOMPANY
                      ,ncrn               => rV_ROW.NCRN
                      ,sdoctype           => rV_ROW.SDOCTYPE
                      ,sdocpref           => rV_ROW.SDOCPREF
                      ,sdocnumb           => rV_ROW.SDOCNUMB
                      ,ddocdate           => rV_ROW.DDOCDATE
                      ,sbarcode           => rV_ROW.SBARCODE
                      ,sjur_pers          => rV_ROW.SJUR_PERS
                      ,nstate             => rV_ROW.NSTATE
                      ,dchange_date       => rV_ROW.DCHANGE_DATE
                      ,sfaceacc_numb      => rV_ROW.SFACEACC_NUMB
                      ,spr_cond           => rV_ROW.SPR_COND
                      ,smatres_nomen      => rV_ROW.SMATRES_NOMEN
                      ,smatres_modif      => rV_ROW.SMATRES_MODIF
                      ,snomclassif        => rV_ROW.SNOMCLASSIF
                      ,sarticle           => rV_ROW.SARTICLE
                      ,nquant             => rV_ROW.NQUANT
                      ,smatres_plan_nomen => rV_ROW.SMATRES_PLAN_NOMEN
                      ,smatres_plan_modif => rV_ROW.SMATRES_PLAN_MODIF
                      ,nmeasure_type      => rV_ROW.NMEASURE_TYPE
                      ,nquant_plan        => rV_ROW.NQUANT_PLAN
                      ,smatres_fact_nomen => rV_ROW.SMATRES_FACT_NOMEN
                      ,smatres_fact_modif => rV_ROW.SMATRES_FACT_MODIF
                      ,nquant_fact        => rV_ROW.NQUANT_FACT
                      ,dout_date          => rV_ROW.DOUT_DATE
                      ,sblank_nomen       => rV_ROW.SBLANK_NOMEN
                      ,sblank_modif       => rV_ROW.SBLANK_MODIF
                      ,ndetails_count     => rV_ROW.NDETAILS_COUNT
                      ,nsupply            => rV_ROW.NSUPPLY
                      ,sstorage           => rV_ROW.SSTORAGE
                      ,sstorage_in        => rV_ROW.SSTORAGE_IN
                      ,sprodcmp           => rV_ROW.SPRODCMP
                      ,sprodcmp_type      => rV_ROW.SPRODCMP_TYPE
                      ,nprodcmpsp         => rV_ROW.NPRODCMPSP
                      ,drel_date          => rV_ROW.DREL_DATE
                      ,nrel_quant         => rV_ROW.NREL_QUANT
                      ,ndup_rn            => nDUP_RN
                      ,nprior_order       => rV_ROW.NPRIOR_ORDER
                      ,nprior_party       => rV_ROW.NPRIOR_PARTY
                      ,sroutsht           => rV_ROW.SROUTSHT
                      ,sroute             => rV_ROW.SROUTE
                      ,scalc_scheme       => rV_ROW.SCALC_SCHEME
                      ,sper_matres_nomen  => rV_ROW.SPER_MATRES_NOMEN
                      ,sper_matres_modif  => rV_ROW.SPER_MATRES_MODIF
                      ,scost_article      => rV_ROW.SCOST_ARTICLE
                      ,svalid_doctype     => rV_ROW.SVALID_DOCTYPE
                      ,svalid_docnumb     => rV_ROW.SVALID_DOCNUMB
                      ,dvalid_docdate     => rV_ROW.DVALID_DOCDATE
                      ,snote              => rV_ROW.SNOTE
                      ,sparty             => rV_ROW.SPARTY
                      ,dexec_date         => rV_ROW.DEXEC_DATE
                      ,sint_numb          => rV_ROW.SINT_NUMB
                      ,nrn                => NRN);
  END FCROUTLST_INSERT;
  --#########################################################################################################

  PROCEDURE FCROUTLST_UPDATE
  /*
  Заголовок. Исправление
  */
  (
   rV_ROW       in v_fcroutlst%rowtype  -- RN сформированного документа
  ) 
  is
  begin
    p_fcroutlst_update(nrn                => rV_ROW.NRN
                      ,ncompany           => rV_ROW.NCOMPANY
                      ,sdoctype           => rV_ROW.SDOCTYPE
                      ,sdocpref           => rV_ROW.SDOCPREF
                      ,sdocnumb           => rV_ROW.SDOCNUMB
                      ,ddocdate           => rV_ROW.DDOCDATE
                      ,sbarcode           => rV_ROW.SBARCODE
                      ,sjur_pers          => rV_ROW.SJUR_PERS
                      ,nstate             => rV_ROW.NSTATE
                      ,dchange_date       => rV_ROW.DCHANGE_DATE
                      ,sfaceacc_numb      => rV_ROW.SFACEACC_NUMB
                      ,spr_cond           => rV_ROW.SPR_COND
                      ,smatres_nomen      => rV_ROW.SMATRES_NOMEN
                      ,smatres_modif      => rV_ROW.SMATRES_MODIF
                      ,snomclassif        => rV_ROW.SNOMCLASSIF
                      ,sarticle           => rV_ROW.SARTICLE
                      ,nquant             => rV_ROW.NQUANT
                      ,smatres_plan_nomen => rV_ROW.SMATRES_PLAN_NOMEN
                      ,smatres_plan_modif => rV_ROW.SMATRES_PLAN_MODIF
                      ,nmeasure_type      => rV_ROW.NMEASURE_TYPE
                      ,nquant_plan        => rV_ROW.NQUANT_PLAN
                      ,smatres_fact_nomen => rV_ROW.SMATRES_FACT_NOMEN
                      ,smatres_fact_modif => rV_ROW.SMATRES_FACT_MODIF
                      ,nquant_fact        => rV_ROW.NQUANT_FACT
                      ,dout_date          => rV_ROW.DOUT_DATE
                      ,sblank_nomen       => rV_ROW.SBLANK_NOMEN
                      ,sblank_modif       => rV_ROW.SBLANK_MODIF
                      ,ndetails_count     => rV_ROW.NDETAILS_COUNT
                      ,nsupply            => rV_ROW.NSUPPLY
                      ,sstorage           => rV_ROW.SSTORAGE
                      ,sstorage_in        => rV_ROW.SSTORAGE_IN
                      ,sprodcmp           => rV_ROW.SPRODCMP
                      ,sprodcmp_type      => rV_ROW.SPRODCMP_TYPE
                      ,nprodcmpsp         => rV_ROW.NPRODCMPSP
                      ,drel_date          => rV_ROW.DREL_DATE
                      ,nrel_quant         => rV_ROW.NREL_QUANT
                      ,nprior_order       => rV_ROW.NPRIOR_ORDER
                      ,nprior_party       => rV_ROW.NPRIOR_PARTY
                      ,sroutsht           => rV_ROW.SROUTSHT
                      ,sroute             => rV_ROW.SROUTE
                      ,scalc_scheme       => rV_ROW.SCALC_SCHEME
                      ,sper_matres_nomen  => rV_ROW.SPER_MATRES_NOMEN
                      ,sper_matres_modif  => rV_ROW.SPER_MATRES_MODIF
                      ,scost_article      => rV_ROW.SCOST_ARTICLE
                      ,svalid_doctype     => rV_ROW.SVALID_DOCTYPE
                      ,svalid_docnumb     => rV_ROW.SVALID_DOCNUMB
                      ,dvalid_docdate     => rV_ROW.DVALID_DOCDATE
                      ,snote              => rV_ROW.SNOTE
                      ,sparty             => rV_ROW.SPARTY
                      ,dexec_date         => rV_ROW.DEXEC_DATE
                      ,ssep_numb          => rV_ROW.SSEP_NUMB
                      ,sint_numb          => rV_ROW.SINT_NUMB);
  END FCROUTLST_UPDATE;
  --#########################################################################################################

  PROCEDURE FCROUTLST_BASE_INSERT
  /*
  Заголовок. Добаление базовое
  */
  (
   rROW       in fcroutlst%rowtype
  ,nRN        out number
  ) 
  is
  begin
    p_fcroutlst_base_insert(ncompany       => rROW.COMPANY
                           ,ncrn           => rROW.CRN
                           ,ndoctype       => rROW.DOCTYPE
                           ,sdocpref       => rROW.DOCPREF
                           ,sdocnumb       => rROW.DOCNUMB
                           ,ddocdate       => rROW.DOCDATE
                           ,sbarcode       => rROW.BARCODE
                           ,njur_pers      => rROW.JUR_PERS
                           ,nstate         => rROW.STATE
                           ,dchange_date   => rROW.CHANGE_DATE
                           ,nfaceacc       => rROW.FACEACC
                           ,npr_cond       => rROW.PR_COND
                           ,nmatres        => rROW.MATRES
                           ,nnomclassif    => rROW.NOMCLASSIF
                           ,narticle       => rROW.ARTICLE
                           ,nquant         => rROW.QUANT
                           ,nmatres_plan   => rROW.MATRES_PLAN
                           ,nmeasure_type  => rROW.MEASURE_TYPE
                           ,nquant_plan    => rROW.QUANT_PLAN
                           ,nmatres_fact   => rROW.MATRES_FACT
                           ,nquant_fact    => rROW.QUANT_FACT
                           ,dout_date      => rROW.OUT_DATE
                           ,nblank         => rROW.BLANK
                           ,ndetails_count => rROW.DETAILS_COUNT
                           ,nsupply        => rROW.SUPPLY
                           ,nstorage       => rROW.STORAGE
                           ,nstorage_in    => rROW.STORAGE_IN
                           ,nprodcmp       => rROW.PRODCMP
                           ,nprodcmpsp     => rROW.PRODCMPSP
                           ,drel_date      => rROW.REL_DATE
                           ,nrel_quant     => rROW.REL_QUANT
                           ,nprior_order   => rROW.PRIOR_ORDER
                           ,nprior_party   => rROW.PRIOR_PARTY
                           ,nroutsht       => rROW.ROUTSHT
                           ,nroute         => rROW.ROUTE
                           ,ncalc_scheme   => rROW.CALC_SCHEME
                           ,nper_matres    => rROW.PER_MATRES
                           ,ncost_article  => rROW.COST_ARTICLE
                           ,nvalid_doctype => rROW.VALID_DOCTYPE
                           ,svalid_docnumb => rROW.VALID_DOCNUMB
                           ,dvalid_docdate => rROW.VALID_DOCDATE
                           ,snote          => rROW.NOTE
                           ,nparty         => rROW.PARTY
                           ,dexec_date     => rROW.EXEC_DATE
                           ,ncategory      => rROW.CATEGORY
                           ,nsep_lstsp     => rROW.SEP_LSTSP
                           ,ssep_numb      => rROW.SEP_NUMB
                           ,sint_numb      => rROW.INT_NUMB
                           ,nrn            => nRN);
  END FCROUTLST_BASE_INSERT;
  --#########################################################################################################

  PROCEDURE FCROUTLST_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW       in fcroutlst%rowtype
  ) 
  is
  begin
    p_fcroutlst_base_update(nrn            => rROW.RN
                           ,ncompany       => rROW.COMPANY
                           ,ndoctype       => rROW.DOCTYPE
                           ,sdocpref       => rROW.DOCPREF
                           ,sdocnumb       => rROW.DOCNUMB
                           ,ddocdate       => rROW.DOCDATE
                           ,sbarcode       => rROW.BARCODE
                           ,njur_pers      => rROW.JUR_PERS
                           ,nstate         => rROW.STATE
                           ,dchange_date   => rROW.CHANGE_DATE
                           ,nfaceacc       => rROW.FACEACC
                           ,npr_cond       => rROW.PR_COND
                           ,nmatres        => rROW.MATRES
                           ,nnomclassif    => rROW.NOMCLASSIF
                           ,narticle       => rROW.ARTICLE
                           ,nquant         => rROW.QUANT
                           ,nmatres_plan   => rROW.MATRES_PLAN
                           ,nmeasure_type  => rROW.MEASURE_TYPE
                           ,nquant_plan    => rROW.QUANT_PLAN
                           ,nmatres_fact   => rROW.MATRES_FACT
                           ,nquant_fact    => rROW.QUANT_FACT
                           ,dout_date      => rROW.OUT_DATE
                           ,nblank         => rROW.BLANK
                           ,ndetails_count => rROW.DETAILS_COUNT
                           ,nsupply        => rROW.SUPPLY
                           ,nstorage       => rROW.STORAGE
                           ,nstorage_in    => rROW.STORAGE_IN
                           ,nprodcmp       => rROW.PRODCMP
                           ,nprodcmpsp     => rROW.PRODCMPSP
                           ,drel_date      => rROW.REL_DATE
                           ,nrel_quant     => rROW.REL_QUANT
                           ,nprior_order   => rROW.PRIOR_ORDER
                           ,nprior_party   => rROW.PRIOR_PARTY
                           ,nroutsht       => rROW.ROUTSHT
                           ,nroute         => rROW.ROUTE
                           ,ncalc_scheme   => rROW.CALC_SCHEME
                           ,nper_matres    => rROW.PER_MATRES
                           ,ncost_article  => rROW.COST_ARTICLE
                           ,nvalid_doctype => rROW.VALID_DOCTYPE
                           ,svalid_docnumb => rROW.VALID_DOCNUMB
                           ,dvalid_docdate => rROW.VALID_DOCDATE
                           ,snote          => rROW.NOTE
                           ,nparty         => rROW.PARTY
                           ,dexec_date     => rROW.EXEC_DATE
                           ,ssep_numb      => rROW.SEP_NUMB
                           ,sint_numb      => rROW.INT_NUMB);
  END FCROUTLST_BASE_UPDATE;
  --#########################################################################################################

  function FCROUTLSTSP_GET
  /*
  Спецификация. Считывание записи
  */
  (
   nRN      in number -- RN записи
  ) 
  return fcroutlstsp%rowtype
  is
    rRow fcroutlstsp%rowtype;
  begin
    begin
      select * into rRow from fcroutlstsp where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'FCROUTLSTSP');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCROUTLSTSP')));
    end;
    return(rRow);
  end FCROUTLSTSP_GET;
  --#########################################################################################################

  procedure FCROUTLSTSP_AINSERT
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
    fcroutlstsp_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FCROUTLSTSP_AINSERT;
  --#########################################################################################################

  procedure FCROUTLSTSP_BUPDATE
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
  end FCROUTLSTSP_BUPDATE;
  --#########################################################################################################

  procedure FCROUTLSTSP_AUPDATE
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
    fcroutlstsp_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FCROUTLSTSP_AUPDATE;
  --#########################################################################################################

  procedure FCROUTLSTSP_BDELETE
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
  end FCROUTLSTSP_BDELETE;
  --#########################################################################################################
  
  procedure FCROUTLSTSP_ASET_STATE
  /* 
  Смена состояния строки спецификации маршрутного листа 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin 
    /* 15-01-2025 контроль обязательности заполнения даты начала процесса в спецификации маршрутного листа при завершении процесса (перевод в состояние Выполнен) */
    for cur in (select t.rlfact_date
                      ,t.state
                  from fcroutlstsp t
                 where t.rn = nrn)
    loop
      
      if cur.state = 1
         and cur.rlfact_date is null then
         
        p_exception(0
                   ,'Не заполнено поле "Фактическая дата начала". Перед переводом в состояниие "Выполнена" выполните действие "Начать работы" ');
      end if;
    end loop;
  
  end;
  --#########################################################################################################

  procedure FCROUTLSTSP_BBEGIN
  /*
  Спецификация. Начать работы. До 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCROUTLSTSP_BBEGIN;
  --#########################################################################################################

  procedure FCROUTLSTSP_ABEGIN
  /*
  Спецификация. Начать работы. После 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      fcroutlstsp%rowtype;
  begin
    /* Считывание */
    /* rRow := fcroutlstsp_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    fcroutlstsp_check_base( nrn => nRN, ncompany => nCOMPANY );

  end FCROUTLSTSP_ABEGIN;
  --#########################################################################################################

  procedure FCROUTLSTSP_BFINISH
  /*
  Спецификация. Закончить работы. До 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCROUTLSTSP_BFINISH;
  --#########################################################################################################

  procedure FCROUTLSTSP_AFINISH
  /*
  Спецификация. Закончить работы. После 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      fcroutlstsp%rowtype;
  begin
    /* Считывание */
    /* rRow := fcroutlstsp_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    fcroutlstsp_check_base( nrn => nRN, ncompany => nCOMPANY );

  end FCROUTLSTSP_AFINISH;
  --#########################################################################################################

  procedure FCROUTLSTSP_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            fcroutlstsp%rowtype;
    rFCRoutLst      fcroutlst%rowtype;
    rFaceAcc        faceacc%rowtype;
    rProductOrd     productord%rowtype;
    rProjectStage   projectstage%rowtype;

    nNumber         pkg_std.tnumber; 
  begin
    /* Считывание */
    rRow           := fcroutlstsp_get( nrn => nRN );
    rFCRoutLst     := fcroutlst_get( nrn => rRow.prn );
    rFaceAcc       := usr_pkg_faceacc.faceacc_get( nrn => rFCRoutLst.faceacc );
    /* Входной заказ на производство */ 
    rProductOrd.rn := fcroutlst_get_po_rn( nrn => rRow.prn, nflagsmart => 1 );
    if rProductOrd.rn is not null then
      rProductOrd := usr_pkg_productord.productord_get( nrn => rProductOrd.rn );
    end if;
    /* Этап проекта */ 
    rProjectStage.rn := usr_pkg_project.projectstage_get_rn_by_faceacc(nflagsmart => 1, nfaceacc => rFaceAcc.rn );
    if rProjectStage.rn is not null then
      rProjectStage := usr_pkg_project.projectstage_get( nrn => rProjectStage.rn );
    end if;

    /* ПРОВЕРКИ */
    /* Если лицевой счёт закрыт */ 
    if rFaceAcc.fact_close_date is not null then
      p_exception(0, 'Невозвожно выполнить действие, т.к. лицевой счёт "%s" имеет статус "%s". %s'
                 ,rFaceAcc.numb
                 ,usr_pkg_faceacc.faceacc_get_status_name( dfact_open_date => rFaceAcc.fact_open_date, dfact_close_date => rFaceAcc.fact_close_date )
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'CostRouteLists', ndocument => rRow.prn ) ); 
    end if;

    /* Если входной заказ на производство имеет статусы Закрыт, Аннулирован */ 
    if nvl( rProductOrd.ord_state, -1 ) in ( 3, 4 ) then
      p_exception(0, 'Невозвожно выполнить действие, т.к. заказ на производство "%s" имеет статус "%s". %s'
                 ,f_docdescrs_get_description( sunitcode => 'ProductionOrders', ndocument => rProductOrd.rn )
                 ,usr_pkg_productord.productord_get_status_name( nord_state => rProductOrd.ord_state )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'CostRouteLists', ndocument => rRow.prn ) ); 
    end if;

    /* Если этап проекта имеет статусы 2-закрыт, 4-исполнение прекращено, 5-остановлен */ 
    if nvl( rProjectStage.state, -1 ) in ( 2, 4, 5 ) then
      p_exception(0, 'Невозвожно выполнить действие, т.к. этап проекта "%s" имеет статус "%s". %s'
                 ,f_docdescrs_get_description( sunitcode => 'ProjectsStages', ndocument => rProjectStage.rn )
                 ,usr_pkg_project.projectstage_get_status_name( nstate => rProjectStage.state )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'CostRouteLists', ndocument => rRow.prn ) ); 
    end if;
    
  end FCROUTLSTSP_CHECK_BASE;
  --#########################################################################################################

  function FCROUTLSTSERNUMB_GET
  /*
  Серийные номера. Считывание записи
  */
  (
   nRN      in number -- RN записи
  ) 
  return fcroutlstsernumb%rowtype
  is
    rrow fcroutlstsernumb%rowtype;
  begin
    begin
      select * into rRow from fcroutlstsernumb where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'FCROUTLSTSERNUMB');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCROUTLSTSERNUMB')));
    end;
    return(rRow);
  end FCROUTLSTSERNUMB_GET;
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_GET_BY_ART
  /*
  Серийные номера. Поиск серийного номера по изделию. Если найдено больше одного, то возвращать тот, у которого поздняя дата маршрутного листа
  */
  (
   nFLAGSMART       in number
  ,nTOO_MANY_ROWS   in number  /* Если найдено больше одной записи: 0 - выдавать ошибку, 1 - возвращать запись по условию */
  ,nARTICLE         in number
  ,nRL_DOCTYPE      in number  /* ТехПаспорт - 12140413, ТП Ремонт - 12141719 */
  ,nRN              out number
  ,nPRN             out number
  ) 
  is
  begin
    begin
      select rlsn.rn, rlsn.prn
        into nRN, nPRN
        from fcroutlstsernumb rlsn 
            ,fcroutlst        rl
       where rlsn.prn     = rl.rn
         and rlsn.article = nARTICLE
         and rl.doctype   = nRL_DOCTYPE
       order by rl.docdate desc, rl.rn desc;
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Не найдено серийного номера для изделия с RN %s в разделе %s.'
                   ,nARTICLE, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCROUTLSTSERNUMB')));
      when too_many_rows then
        p_exception(case nTOO_MANY_ROWS when 0 then 0 else nFLAGSMART end
                   ,'Найдено больше одного серийного номера для изделия с RN %s в разделе %s.'
                   ,nARTICLE, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCROUTLSTSERNUMB')));
      when others then
        p_exception(0, 'Неопределённая ситуация поиске серийного номера для изделия с RN %s в разделе %s.'
                   ,nARTICLE, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCROUTLSTSERNUMB')));
    end;

  end FCROUTLSTSERNUMB_GET_BY_ART;
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_GET_IFD
  /*
  Серийные номера. Поиск прихода из подразделений по серийному номеру. 
  Если найдено больше одного, то возвращать тот, у которого поздняя дата прихода из подразделения
  */
  (
   nFLAGSMART       in number
  ,nTOO_MANY_ROWS   in number   /* Если найдено больше одной записи: 0 - выдавать ошибку, 1 - возвращать запись по условию */
  ,nRN              in number
  ,nIFD             out number
  ,nIFDS            out number
  ) 
  is
    rRow      fcroutlstsernumb%rowtype;
  begin
    /* Считывание */
    rRow := fcroutlstsernumb_get(nrn => nRN);

    /* Запрос */
    begin
      select ifd.rn, ifds.Rn
        into nIFD, nIFDS
        from doclinks           dl
            ,incomefromdeps     ifd
            ,incomefromdepsspec ifds
       where dl.in_document   = rRow.prn
         and dl.out_document  = ifd.rn
         and ifd.rn           = ifds.prn
         and ifds.article     = rRow.article
         and ifd.doc_state    = 2  /* отработан как факт */
      order by ifd.doc_date desc, ifd.rn desc;
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Не найдено прихода из подразделений для серийного номера с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCROUTLSTSERNUMB')));
      when too_many_rows then
        p_exception(case nTOO_MANY_ROWS when 0 then 0 else nFLAGSMART end
                   ,'Найдено больше одного прихода из подразделений для серийного номера с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCROUTLSTSERNUMB')));
      when others then
        p_exception(0, 'Неопределённая ситуация поиске прихода из подразделений для серийного номера с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCROUTLSTSERNUMB')));
    end;

  end FCROUTLSTSERNUMB_GET_IFD;
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_AINSERT
  /*
  Серийные номера. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Проверка базовая */
    fcroutlstsernumb_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FCROUTLSTSERNUMB_AINSERT;
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_BDELETE
  /*
  Серийные номера. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end FCROUTLSTSERNUMB_BDELETE;
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_BDLVRLST_CRT
  /*
  Заголовок. Формирование комплектовочной ведомости. До
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* Запись значения в константу идентификатора */  
    usr_pkg_pub_const.nidentbefore := nRN;

  end FCROUTLSTSERNUMB_BDLVRLST_CRT;
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_ADLVRLST_CRT
  /*
  Заголовок. Формирование комплектовочной ведомости. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* По сформированным документам */
    for c in (select out_document0 from usr_t_inhierbuff where identbefore = usr_pkg_pub_const.nidentbefore) 
    loop
      /* проверка заголовка */
      usr_pkg_fcdeliverylist.fcdeliverylist_ainsert(nrn => c.out_document0, ncompany => nCOMPANY);
    end loop;

    /* Очистка записей временной таблицы взаимосвязей */  
    delete from usr_t_inhierbuff where identbefore = usr_pkg_pub_const.nidentbefore;
    usr_pkg_pub_const.nidentbefore := null;
    
  end FCROUTLSTSERNUMB_ADLVRLST_CRT;
  --#########################################################################################################

  procedure FCROUTLSTSERNUMB_CHECK_BASE
  /*
  Серийные номера. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow    fcroutlstsernumb%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow := FCROUTLSTSERNUMB_get(nrn => nRN);*/
    
  end FCROUTLSTSERNUMB_CHECK_BASE;
 


end USR_PKG_FCROUTLST;
/
