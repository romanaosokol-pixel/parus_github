create or replace package USR_PKG_OVERHEADS is
  /*
  Степанов М. 31/08/2022
  Package предназначен для работы с разделом "Номенклатор". 
  RealizationOverheads      OVH
  RealizationOverheadSpecs  OVHS
  */
  --#########################################################################################################

  function OVERHEADS_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN       in number
  ) 
  return OVERHEADS%rowtype;
  --#########################################################################################################

  procedure OVERHEADS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure OVERHEADS_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure OVERHEADS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure OVERHEADS_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure OVERHEADS_ASPREAD
  /*
  Заголовок. Проверка после распределения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure OVERHEADS_ASPREAD_DELETE
  /*
  Заголовок. Проверка после удаления распределения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure OVERHEADS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure OVERHEADS_BASE_INSERT
  /*
  Заголовок. Базовое добавление
  */
  (
   rROW             in overheads%rowtype
  ,nIS_AUTO_CREATE  in number 
  ,nRN              out number
  );
  --#########################################################################################################

  procedure OVERHEADS_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW                 in overheads%rowtype
  ,sUNITCODE_DETAIL     in varchar2
  ,nCKLINK_TO_FCHRG     in number default 0
  );
  --#########################################################################################################

  procedure OVERHEADS_SPREAD_ON_GS
  /*
  Заголовок. Распределение накладного расхода на заданный товарный запас
  Распределяется нулевая сумма
  */
  (
   nRN          in number
  ,dSUPPLYDATE  in date
  ,nGOODSSUPPLY in number
  );
  --#########################################################################################################

  function OVERHEADSSP_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   nRN       in number
  ) 
  return OVERHEADSSP %ROWTYPE;
  --#########################################################################################################

  procedure OVERHEADSSP_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure OVERHEADSSP_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure OVERHEADSSP_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure OVERHEADSSP_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure OVERHEADSSP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_OVERHEADS;
/
create or replace package body USR_PKG_OVERHEADS is

  --#########################################################################################################

  function OVERHEADS_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN      in number
  ) 
  return overheads%rowtype
  is
    rRow overheads%rowtype;
  begin
    begin
      select T.*
        into rRow
        from overheads t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(nflag_smart => 1, stable_name => 'OVERHEADS'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'OVERHEADS')));
    end;
    return(rRow);
  end OVERHEADS_GET;
  --#########################################################################################################

  procedure OVERHEADS_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            overheads%rowtype;
  begin
    /* Считывание
     rRow := OVERHEADS_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    overheads_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end OVERHEADS_AINSERT;
  --#########################################################################################################

  procedure OVERHEADS_BUPDATE
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
  end OVERHEADS_BUPDATE;
  --#########################################################################################################

  procedure OVERHEADS_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     overheads%rowtype;
    
  begin
    /* Считывание
     rRow := overheads_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    overheads_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end OVERHEADS_AUPDATE;
  --#########################################################################################################

  procedure OVERHEADS_BDELETE
  /*
  Заголовок. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end OVERHEADS_BDELETE;
  --#########################################################################################################

  procedure OVERHEADS_ASPREAD
  /*
  Заголовок. Проверка после распределения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end OVERHEADS_ASPREAD;
  --#########################################################################################################

  procedure OVERHEADS_ASPREAD_DELETE
  /*
  Заголовок. Проверка после удаления распределения
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end OVERHEADS_ASPREAD_DELETE;
  --#########################################################################################################

  procedure OVERHEADS_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     overheads%rowtype;
  begin
    null;
    /* Заголовок */  
    /* rRow := overheads_get(nrn => nRN); */
    
  end OVERHEADS_CHECK_BASE;
  --#########################################################################################################

  procedure OVERHEADS_BASE_INSERT
  /*
  Заголовок. Базовое добавление
  */
  (
   rROW             in overheads%rowtype
  ,nIS_AUTO_CREATE  in number 
  ,nRN              out number
  ) 
  is 
  begin
    p_overheads_base_insert(ncompany         => rROW.COMPANY
                           ,njur_pers        => rROW.JUR_PERS
                           ,sunitcode        => rROW.UNITCODE
                           ,sunitcode_detail => null --rROW.UNITCODE_DETAIL
                           ,nbase_overhead   => rROW.BASE_OVERHEAD
                           ,ndoc_type        => rROW.DOC_TYPE
                           ,sdoc_numb        => rROW.DOC_NUMB
                           ,ddoc_date        => rROW.DOC_DATE
                           ,nnomen           => rROW.NOMEN
                           ,nnommodif        => rROW.NOMMODIF
                           ,ncurrency        => rROW.CURRENCY
                           ,nsumm            => rROW.SUMM
                           ,nsumm_nds        => rROW.SUMM_NDS
                           ,ncurcourse       => rROW.CURCOURSE
                           ,ncurbasecours    => rROW.CURBASECOURS
                           ,nsignspread      => rROW.SIGNSPREAD
                           ,dwork_date       => rROW.WORK_DATE
                           ,snote            => rROW.NOTE
                           ,nstoper          => rROW.STOPER
                           ,nsigngoodsrep    => rROW.SIGNGOODSREP
                           ,ngroup_code_cond => rROW.GROUP_CODE_COND
                           ,nnomen_cond      => rROW.NOMEN_COND
                           ,ntax_group_cond  => rROW.TAX_GROUP_COND
                           ,nsumm_calc_proc  => rROW.SUMM_CALC_PROC
                           ,nis_auto_create  => nIS_AUTO_CREATE
                           ,nrn              => nRN);
  end OVERHEADS_BASE_INSERT;
  --#########################################################################################################

  procedure OVERHEADS_BASE_UPDATE
  /*
  Заголовок. Базовое исправление
  */
  (
   rROW                 in overheads%rowtype
  ,sUNITCODE_DETAIL     in varchar2
  ,nCKLINK_TO_FCHRG     in number default 0
  ) 
  is 
  begin
    p_overheads_base_update(nrn              => rROW.RN
                           ,ncompany         => rROW.COMPANY
                           ,njur_pers        => rROW.JUR_PERS
                           ,nbase_overhead   => rROW.BASE_OVERHEAD
                           ,nnomen           => rROW.NOMEN
                           ,nnommodif        => rROW.NOMMODIF
                           ,ndoc_type        => rROW.DOC_TYPE
                           ,sdoc_numb        => rROW.DOC_NUMB
                           ,ddoc_date        => rROW.DOC_DATE
                           ,nsumm            => rROW.SUMM
                           ,nsumm_nds        => rROW.SUMM_NDS
                           ,nspread_sum      => rROW.SPREAD_SUM
                           ,nspread_sum_nds  => rROW.SPREAD_SUM_NDS
                           ,ncurrency        => rROW.CURRENCY
                           ,ncurcourse       => rROW.CURCOURSE
                           ,ncurbasecours    => rROW.CURBASECOURS
                           ,nsignspread      => rROW.SIGNSPREAD
                           ,dwork_date       => rROW.WORK_DATE
                           ,ngroup_code_cond => rROW.GROUP_CODE_COND
                           ,nnomen_cond      => rROW.NOMEN_COND
                           ,ntax_group_cond  => rROW.TAX_GROUP_COND
                           ,nsumm_calc_proc  => rROW.SUMM_CALC_PROC
                           ,nstoper          => rROW.STOPER
                           ,nsigngoodsrep    => rROW.SIGNGOODSREP
                           ,snote            => rROW.NOTE
                           ,sunitcode_detail => sUNITCODE_DETAIL
                           ,ncklink_to_fchrg => nCKLINK_TO_FCHRG
                           );
  end OVERHEADS_BASE_UPDATE;
  --#########################################################################################################

  procedure OVERHEADS_SPREAD_ON_GS
  /*
  Заголовок. Распределение накладного расхода на заданный товарный запас
  Распределяется нулевая сумма
  */
  (
   nRN          in number
  ,dSUPPLYDATE  in date
  ,nGOODSSUPPLY in number
  ) 
  is
    nIdent        pkg_std.tref; 
    rRow          overheads%rowtype;
    
    nNumber       pkg_std.tnumber;
    sVarchar      pkg_std.tstring; 
    bBoolean      boolean := false;
  begin
    /* Считывание */
    rRow := overheads_get(nrn => nRN);

    /* Генерация Ident */
    p_selectlist_genident(nident => nIdent);

    /* Формирование */
    p_goodssupplyondate_insert(ncompany    => rRow.company
                              ,nident      => nIDENT
                              ,dsupplydate => dSUPPLYDATE
                              ,nrn         => nNumber);
    p_selectlist_insert(nident    => nIdent
                       ,ndocument => nGOODSSUPPLY
                       ,sunitcode => 'GoodsParties'
                       ,nrn       => nNumber);
    p_goodssupplyondate_pack(nident => nIdent);
    p_overheads_isquantaltnull(ncompany     => rRow.company
                              ,nident       => nIdent
                              ,nspread_kind => 0
                              ,nspread_type => 3
                              ,nerr_code    => nNumber
                              ,smsg         => sVarchar);
    p_overheads_spread(ncompany        => rRow.company
                      ,nident          => nIdent
                      ,nrn             => rRow.rn
                      ,nspread_kind    => 1
                      ,nspread_type    => 3
                      ,ddate           => dSUPPLYDATE
                      ,nspread_sum     => 0 /* rRow.spread_sum */
                      ,nspread_sum_nds => 0 /* rRow.spread_sum_nds */
                      ,nhd_course      => 1
                      ,nhd_coursebase  => 1
                      ,scurrency       => 'RUB'
                      ,ncourse         => 1
                      ,ncourse_base    => 1
                      ,nis_doc_course  => 0
                      ,nsign_rest      => 0
                      ,smsg            => sVarchar);
    /* Проверка, что распределилось */
    for c in (select 1 from overheadssp where prn = rRow.rn)
    loop
      bBoolean := true;
    end loop;
    if not bBoolean then
      p_exception(0, 'Распределение накладного расхода не выполнено. Возможно, дата распределения меньше даты поступления товарного запаса. %s%s'
                 ,cr||rRow.rn, cr||f_unitlist_getname(sunitcode => get_unitlist_code_table(1, 'OVERHEADS')));
    end if;
    
    /* Очистка */
    p_selectlist_clear(nident => nIdent);
    
  end OVERHEADS_SPREAD_ON_GS;
  --#########################################################################################################

  function OVERHEADSSP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number 
  ) 
  return overheadssp%rowtype
  is
    rRow overheadssp%rowtype;
  begin
    begin
      select T.*
        into rRow
        from overheadssp t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(nflag_smart => 1, stable_name => 'OVERHEADSSP'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'OVERHEADSSP')));
    end;
    return(rRow);
  end OVERHEADSSP_GET;
  --#########################################################################################################

  procedure OVERHEADSSP_AINSERT
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
    overheadssp_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end OVERHEADSSP_AINSERT;
  
  --#########################################################################################################

  procedure OVERHEADSSP_BUPDATE
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
  end OVERHEADSSP_BUPDATE;
  --#########################################################################################################

  procedure OVERHEADSSP_AUPDATE
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
    overheadssp_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end OVERHEADSSP_AUPDATE;
  --#########################################################################################################

  procedure OVERHEADSSP_BDELETE
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
  end OVERHEADSSP_BDELETE;
  --#########################################################################################################

  procedure OVERHEADSSP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     overheadssp%rowtype;
  begin
    null;
    /* Считывание */
    /*  rRow := overheadssp_get(nrn => nRN); */

    /* ПРОВЕРКИ */
    
  end OVERHEADSSP_CHECK_BASE;
--#########################################################################################################

end USR_PKG_OVERHEADS;
/
