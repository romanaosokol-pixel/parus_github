create or replace package USR_PKG_FCROUTSHT is
  /*
  Package предназначен для работы с разделом "Маршрутные карты".
  CostRouteSheets       FCROUTSHT     CRS
  CostRouteSheetsSpecs  FCROUTSHTSP   CRSS
  */
  --#########################################################################################################

  function FCROUTSHT_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return FCROUTSHT%ROWTYPE;
  --#########################################################################################################

  procedure FCROUTSHT_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTSHT_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTSHT_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTSHT_BDELETE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTSHT_BMOVE_IN
  /*
  Заголовок. Проверка перед переносом в каталог
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTSHT_BMOVE_OUT
  /*
  Заголовок. Проверка перед переносом из каталога
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTSHT_BCHANGE_STATUS
  /*
  Заголовок. Проверка до Смена состояния маршрутной карты
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) ;
  --#########################################################################################################

  procedure FCROUTSHT_ACHANGE_STATUS
  /*
  Заголовок. Проверка после Смена состояния маршрутной карты
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTSHT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  function FCROUTSHTSP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return FCROUTSHTSP%ROWTYPE;
  --#########################################################################################################

  procedure FCROUTSHTSP_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTSHTSP_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTSHTSP_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTSHTSP_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTSHTSP_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure FCROUTSHTSP_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW             in fcroutshtsp%rowtype
  ,nSIGN_HS         in number default 0 /* Добавление записи в историю(1- да, 0-нет) */
  ,nCHANGE_KIND     in number default 0 /* Вид изменения (0-выпустить, 1-аннулировать, 2- изменить) */
  ,nRN              out number
  );
  --#########################################################################################################

  procedure FCROUTSHTSP_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in fcroutshtsp%rowtype
  ,nCHANGE_KIND     in number default 2 /* Вид изменения (0-выпустить, 1-аннулировать, 2- изменить) */
  ); 
  --#########################################################################################################

end USR_PKG_FCROUTSHT;
/
create or replace package body USR_PKG_FCROUTSHT is

  --#########################################################################################################

  function FCROUTSHT_GET
  /*
  Заголовок. Считывание записи
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return fcroutsht%rowtype
  is
    rRow fcroutsht%rowtype;
  begin
    begin
      select * into rRow from fcroutsht where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FCROUTSHT');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCROUTSHT')));
    end;
    return(rRow);
  end FCROUTSHT_GET;
  --#########################################################################################################

  procedure FCROUTSHT_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rFCRoutShtSp    fcroutshtsp%rowtype;
  begin
    /* ИСПРАВЛЕНИЯ */
    /* По спецификациям */
    for c in (select * from fcroutshtsp where prn = nRN)
    loop
      /* Копирование в переменную */
      rFCRoutShtSp := c;
      /* Очистка значений в поле с нормачасами "adem_t_o" */
      rFCRoutShtSp.adem_t_o := 0;
      fcroutshtsp_base_update(rrow => rFCRoutShtSp);
    end loop;

    /* ПРОВЕРКИ */
    /* Базовая */
    fcroutsht_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FCROUTSHT_AINSERT;
  --#########################################################################################################

  procedure FCROUTSHT_BUPDATE
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
  end FCROUTSHT_BUPDATE;
  --#########################################################################################################

  procedure FCROUTSHT_AUPDATE
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
    fcroutsht_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FCROUTSHT_AUPDATE;
  --#########################################################################################################

  procedure FCROUTSHT_BDELETE
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
  end FCROUTSHT_BDELETE;
  --#########################################################################################################

  procedure FCROUTSHT_BMOVE_IN
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
  end FCROUTSHT_BMOVE_IN;
  --#########################################################################################################

  procedure FCROUTSHT_BMOVE_OUT
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
  end FCROUTSHT_BMOVE_OUT;
  --#########################################################################################################

  procedure FCROUTSHT_BCHANGE_STATUS
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
  end FCROUTSHT_BCHANGE_STATUS;
  --#########################################################################################################

  procedure FCROUTSHT_ACHANGE_STATUS
  /*
  Заголовок. Проверка после Смена состояния маршрутной карты
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    fcroutsht_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FCROUTSHT_ACHANGE_STATUS;
  --#########################################################################################################

  procedure FCROUTSHT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            fcroutsht%rowtype;
    rFcMatResource  fcmatresource%rowtype;
  begin
    /* Считывание */
    rRow           := fcroutsht_get( nrn => nRN );
    rFcMatResource := usr_pkg_fcmatresource.fcmatresource_get( nrn => rRow.mtr_res );
    
    /* ПРОВЕРКИ */
    /* Обозначение маршрутной карты не равно обозначению мат.ресурса */
    /*if cmp_vc2( rRow.code, rFcMatResource.code ) != 1 then
      p_exception(0, 'Обозначение маршрутной карты <%s> не равно обозначению материального ресурса <%s>. %s'
                 ,rRow.code
                 ,rFcMatResource.code
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'CostRouteSheets', ndocument => rRow.rn ) );
    end if;*/

  end FCROUTSHT_CHECK_BASE;
  --#########################################################################################################

  function FCROUTSHTSP_GET
  /*
  Спецификация. Считывание записи
  */
  (
   nRN        in number
  ,nFLAGSMART in number default 0 
  ) 
  return fcroutshtsp%rowtype
  is
    rRow fcroutshtsp%rowtype;
  begin
    begin
      select * into rRow from fcroutshtsp where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FCROUTSHTSP');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCROUTSHTSP')));
    end;
    return(rRow);
  end FCROUTSHTSP_GET;

  --#########################################################################################################

  procedure FCROUTSHTSP_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rFCRoutShtSp    fcroutshtsp%rowtype;
  begin
    /* Проверка базовая */
    fcroutshtsp_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end FCROUTSHTSP_AINSERT;
  --#########################################################################################################

  procedure FCROUTSHTSP_BUPDATE
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
  end FCROUTSHTSP_BUPDATE;
  --#########################################################################################################

  procedure FCROUTSHTSP_AUPDATE
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
    fcroutshtsp_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FCROUTSHTSP_AUPDATE;
  --#########################################################################################################

  procedure FCROUTSHTSP_BDELETE
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
  end FCROUTSHTSP_BDELETE;
  --#########################################################################################################

  procedure FCROUTSHTSP_CHECK_BASE
  /*
  Спецификация. Проверка базовая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow    fcroutshtsp%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow := fcroutshtsp_get(nrn => nRN);*/
    
  end FCROUTSHTSP_CHECK_BASE;
  --#########################################################################################################

  procedure FCROUTSHTSP_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW             in fcroutshtsp%rowtype
  ,nSIGN_HS         in number default 0 /* Добавление записи в историю(1- да, 0-нет) */
  ,nCHANGE_KIND     in number default 0 /* Вид изменения (0-выпустить, 1-аннулировать, 2- изменить) */
  ,nRN              out number
  ) 
  is
  begin
    p_fcroutshtsp_base_insert(ncompany         => rROW.COMPANY
                             ,nprn             => rROW.PRN
                             ,snumb            => rROW.NUMB
                             ,soper_numb       => rROW.OPER_NUMB
                             ,noper_tps        => rROW.OPER_TPS
                             ,soper_uk         => rROW.OPER_UK
                             ,nfpdaccnt        => rROW.FPDACCNT
                             ,npr_cond         => rROW.PR_COND
                             ,nequipment       => rROW.EQUIPMENT
                             ,nmanpower        => rROW.MANPOWER
                             ,ncategory        => rROW.CATEGORY
                             ,nstaffgrp        => rROW.STAFFGRP
                             ,ncoeffic         => rROW.COEFFIC
                             ,nnorm            => rROW.NORM
                             ,nnorm_type       => rROW.NORM_TYPE
                             ,nnorm_unit       => rROW.NORM_UNIT
                             ,nsign_part_rels  => rROW.SIGN_PART_RELS
                             ,nquotat_spec     => rROW.QUOTAT_SPEC
                             ,ntariff          => rROW.TARIFF
                             ,ddate_from       => rROW.DATE_FROM
                             ,snote            => rROW.NOTE
                             ,ncurnames        => rROW.CURNAMES
                             ,sbasis           => rROW.BASIS
                             ,nprev_cycle      => rROW.PREV_CYCLE
                             ,ncontrl_oper     => rROW.CONTRL_OPER
                             ,nsign_hs         => nSIGN_HS
                             ,nannul           => rROW.ANNUL
                             ,nchange_kind     => nCHANGE_KIND
                             ,nstore           => rROW.STORE
                             ,nsubdiv          => rROW.SUBDIV
                             ,ncoeffic_numb    => rROW.COEFFIC_NUMB
                             ,nnorm_value      => rROW.NORM_VALUE
                             ,nproduct_time    => rROW.PRODUCT_TIME
                             ,nwork_cond       => rROW.WORK_COND
                             ,nmechdgr         => rROW.MECHDGR
                             ,nprocess_type    => rROW.PROCESS_TYPE
                             ,sdocument        => rROW.DOCUMENT
                             ,nagent           => rROW.AGENT
                             ,ncost_article    => rROW.COST_ARTICLE
                             ,ncutting_sign    => rROW.CUTTING_SIGN
                             ,nmunit           => rROW.MUNIT
                             ,nrn              => nRN/*
                             ,nadem_id_calc    => rROW.ADEM_ID_CALC
                             ,nadem_id_subcalc => rROW.ADEM_ID_SUBCALC
                             ,nadem_t_pz       => rROW.ADEM_T_PZ
                             ,nadem_t_vsp      => rROW.ADEM_T_VSP
                             ,nadem_t_o        => rROW.ADEM_T_O*/);
  end FCROUTSHTSP_BASE_INSERT;
  --#########################################################################################################

  procedure FCROUTSHTSP_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW             in fcroutshtsp%rowtype
  ,nCHANGE_KIND     in number default 2 /* Вид изменения (0-выпустить, 1-аннулировать, 2- изменить) */
  ) 
  is
  begin
    p_fcroutshtsp_base_update(nrn              => rROW.RN
                             ,ncompany         => rROW.COMPANY
                             ,snumb            => rROW.NUMB
                             ,soper_numb       => rROW.OPER_NUMB
                             ,noper_tps        => rROW.OPER_TPS
                             ,soper_uk         => rROW.OPER_UK
                             ,npr_cond         => rROW.PR_COND
                             ,nequipment       => rROW.EQUIPMENT
                             ,nmanpower        => rROW.MANPOWER
                             ,ncategory        => rROW.CATEGORY
                             ,nstaffgrp        => rROW.STAFFGRP
                             ,ncoeffic         => rROW.COEFFIC
                             ,nnorm            => rROW.NORM
                             ,nnorm_type       => rROW.NORM_TYPE
                             ,nnorm_unit       => rROW.NORM_UNIT
                             ,nsign_part_rels  => rROW.SIGN_PART_RELS
                             ,nquotat_spec     => rROW.QUOTAT_SPEC
                             ,ntariff          => rROW.TARIFF
                             ,ddate_from       => rROW.DATE_FROM
                             ,snote            => rROW.NOTE
                             ,ncurnames        => rROW.CURNAMES
                             ,sbasis           => rROW.BASIS
                             ,nprev_cycle      => rROW.PREV_CYCLE
                             ,ncontrl_oper     => rROW.CONTRL_OPER
                             ,nannul           => rROW.ANNUL
                             ,nchange_kind     => nCHANGE_KIND
                             ,nstore           => rROW.STORE
                             ,nsubdiv          => rROW.SUBDIV
                             ,ncoeffic_numb    => rROW.COEFFIC_NUMB
                             ,nnorm_value      => rROW.NORM_VALUE
                             ,nproduct_time    => rROW.PRODUCT_TIME
                             ,nwork_cond       => rROW.WORK_COND
                             ,nmechdgr         => rROW.MECHDGR
                             ,nprocess_type    => rROW.PROCESS_TYPE
                             ,sdocument        => rROW.DOCUMENT
                             ,nagent           => rROW.AGENT
                             ,ncost_article    => rROW.COST_ARTICLE
                             ,ncutting_sign    => rROW.CUTTING_SIGN
                             ,nmunit           => rROW.MUNIT/*
                             ,nadem_id_calc    => rROW.ADEM_ID_CALC
                             ,nadem_id_subcalc => rROW.ADEM_ID_SUBCALC
                             ,nadem_t_pz       => rROW.ADEM_T_PZ
                             ,nadem_t_vsp      => rROW.ADEM_T_VSP
                             ,nadem_t_o        => rROW.ADEM_T_O*/);
  end FCROUTSHTSP_BASE_UPDATE;
  --#########################################################################################################

end USR_PKG_FCROUTSHT;
/
