create or replace package USR_PKG_EQCONFIG is
  /*
  Степанов М. 06/09/2023
  Состав оборудования
  EquipConfiguration           EC
  EquipConfigurationStateHist  ECSH
  */
  --#########################################################################################################

  function EQCONFIG_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN       in number
  ) 
  return eqconfig%rowtype;
  --#########################################################################################################

  procedure EQCONFIG_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIG_BUPDATE
  /*
  Заголовок. Исправление. Перед 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIG_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIG_ASET_STATE
  /*
  Заголовок. Изменение состояния объекта. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIG_AUNDO_STATE
  /*
  Заголовок. Возвращение предыдущего состояния объекта. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIG_ASET_EXTRA
  /*
  Заголовок. Перемещение объекта из структуры. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIG_AREFRESH_INFO
  /*
  Заголовок. Обновление дополнительной информации. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIG_AOBJ_LEVEL_CHANGE
  /*
  Заголовок. Изменение уровня структуры объекта. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIG_AOBJ_MOVE
  /*
  Заголовок. Перемещение объекта состава оборудования. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIG_BDELETE
  /*
  Заголовок. Удаление. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIG_BDELETE_WITH_STRUCT
  /*
  Заголовок. Удаление объекта со структурой. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIG_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIG_BASE_INSERT
  /*
  Заголовок. Добавление базовое 
  */
  (
   rROW         in eqconfig%rowtype
  ,nRN          out number
  );
  --#########################################################################################################

  procedure EQCONFIG_BASE_UPDATE
  /*
  Заголовок. Исправление базовое 
  */
  (
   rROW         in eqconfig%rowtype
  );
  --#########################################################################################################

  function EQCONFIGSH_GET
  /*
  История смены состояний. Считывание
  */
  (
   nRN       in number
  ) 
  return eqconfigsh%rowtype;
  --#########################################################################################################

  procedure EQCONFIGSH_BUPDATE
  /*
  История смены состояний. Исправление. Перед 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

  procedure EQCONFIGSH_AUPDATE
  /*
  История смены состояний. Исправление. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_EQCONFIG;
/
create or replace package body USR_PKG_EQCONFIG is

  --#########################################################################################################

  function EQCONFIG_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN      in number
  ) 
  return eqconfig%rowtype
  is
    rRow eqconfig%rowtype;
  begin
    begin
      select T.*
        into rRow
        from eqconfig t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(nflag_smart => 1, stable_name => 'EQCONFIG'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EQCONFIG')));
    end;
    return(rRow);
  end EQCONFIG_GET;
  --#########################################################################################################

  procedure EQCONFIG_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            eqconfig%rowtype;

    sVarchar        pkg_std.tstring; 
  begin
    /* Считывание
     rRow := EQCONFIG_GET(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    eqconfig_check_base(nrn => nRN, ncompany => nCOMPANY);

  end EQCONFIG_AINSERT;
  --#########################################################################################################

  procedure EQCONFIG_BUPDATE
  /*
  Заголовок. Исправление. Перед 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end EQCONFIG_BUPDATE;
  --#########################################################################################################

  procedure EQCONFIG_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow                     eqconfig%rowtype;
    
  begin
    /* Считывание
     rRow := eqconfig_get(nRN); */

    /* ПРОВЕРКИ */
    /* Базовая */
    eqconfig_check_base(nrn => nRN, ncompany => nCOMPANY);
    
  end EQCONFIG_AUPDATE;
  --#########################################################################################################

  procedure EQCONFIG_ASET_STATE
  /*
  Заголовок. Изменение состояния объекта. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        eqconfig%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow     := eqconfig_get(nrn => nRN);*/

  end EQCONFIG_ASET_STATE;
  --#########################################################################################################

  procedure EQCONFIG_AUNDO_STATE
  /*
  Заголовок. Возвращение предыдущего состояния объекта. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EQCONFIG_AUNDO_STATE;
  --#########################################################################################################

  procedure EQCONFIG_ASET_EXTRA
  /*
  Заголовок. Перемещение объекта из структуры. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EQCONFIG_ASET_EXTRA;
  --#########################################################################################################

  procedure EQCONFIG_AREFRESH_INFO
  /*
  Заголовок. Обновление дополнительной информации. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EQCONFIG_AREFRESH_INFO;
  --#########################################################################################################

  procedure EQCONFIG_AOBJ_LEVEL_CHANGE
  /*
  Заголовок. Изменение уровня структуры объекта. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EQCONFIG_AOBJ_LEVEL_CHANGE;
  --#########################################################################################################

  procedure EQCONFIG_AOBJ_MOVE
  /*
  Заголовок. Перемещение объекта состава оборудования. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EQCONFIG_AOBJ_MOVE;
  --#########################################################################################################

  procedure EQCONFIG_BDELETE
  /*
  Заголовок. Удаление. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Наличие связей */
    if f_doclinks_link_exists(sUNITCODE => 'EquipConfiguration', nDOCUMENT => nRN) != 0 then
      p_exception(0, 'Документ имеет связи. Удаление запрещено. %s'
                 ,cr||f_docdescrs_get_description('EquipConfiguration', nRN)); 
      
    end if;
  end EQCONFIG_BDELETE;
  --#########################################################################################################

  procedure EQCONFIG_BDELETE_WITH_STRUCT
  /*
  Заголовок. Удаление объекта со структурой. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;    
  end EQCONFIG_BDELETE_WITH_STRUCT;
  --#########################################################################################################

  procedure EQCONFIG_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow     eqconfig%rowtype;
  begin
    null;
    /* Заголовок */  
    /* rRow := eqconfig_get(nrn => nRN); */
    
  end EQCONFIG_CHECK_BASE;
  --#########################################################################################################

  procedure EQCONFIG_BASE_INSERT
  /*
  Заголовок. Добавление базовое 
  */
  (
   rROW         in eqconfig%rowtype
  ,nRN          out number
  ) 
  is 
  begin
    p_eqconfig_base_insert(ncompany          => RROW.COMPANY
                          ,nprn              => RROW.PRN
                          ,njur_pers         => RROW.JUR_PERS
                          ,scode             => RROW.CODE
                          ,sname             => RROW.NAME
                          ,sstruct_code      => RROW.STRUCT_CODE
                          ,npr_obj_level     => RROW.PR_OBJ_LEVEL
                          ,nobj_type         => RROW.OBJ_TYPE
                          ,nth_obj_level     => RROW.TH_OBJ_LEVEL
                          ,nobj_kind         => RROW.OBJ_KIND
                          ,swork_numb        => RROW.WORK_NUMB
                          ,sclasscode        => RROW.CLASSCODE
                          ,sinv_numb         => RROW.INV_NUMB
                          ,spos_numb         => RROW.POS_NUMB
                          ,doper_date        => RROW.OPER_DATE
                          ,sdraft            => RROW.DRAFT
                          ,sstandard         => RROW.STANDARD
                          ,naccept_res       => RROW.ACCEPT_RES
                          ,nstat_res         => RROW.STAT_RES
                          ,numeas_res        => RROW.UMEAS_RES
                          ,nquant            => RROW.QUANT
                          ,nfict_rec         => RROW.FICT_REC
                          ,nextra_obj        => RROW.EXTRA_OBJ
                          ,nuse_kind         => null /*RROW.USE_KIND*/
                          ,duse_kind_date    => RROW.USE_KIND_DATE
                          ,nresp_div         => RROW.RESP_DIV
                          ,ntech_srv_div     => RROW.TECH_SRV_DIV
                          ,nnomen            => RROW.NOMEN
                          ,nnom_modif        => RROW.NOM_MODIF
                          ,nowner_agent      => RROW.OWNER_AGENT
                          ,nfix_state        => RROW.FIX_STATE
                          ,nfix_moves        => RROW.FIX_MOVES
                          ,nproduce_agnlist  => RROW.PRODUCE_AGNLIST
                          ,dproduce_date     => RROW.PRODUCE_DATE
                          ,sfactory_number   => RROW.FACTORY_NUMBER
                          ,neqsetplace       => RROW.EQSETPLACE
                          ,neqsetmode        => RROW.EQSETMODE
                          ,neqjoinpipeline   => RROW.EQJOINPIPELINE
                          ,npipelinefrom     => RROW.PIPELINEFROM
                          ,npipelineto       => RROW.PIPELINETO
                          ,spicketagefrom    => RROW.PICKETAGEFROM
                          ,spicketageto      => RROW.PICKETAGETO
                          ,npicketagefrom_m  => RROW.PICKETAGEFROM_M
                          ,npicketageto_m    => RROW.PICKETAGETO_M
                          ,npipesectionfrom  => RROW.PIPESECTIONFROM
                          ,npipesectionto    => RROW.PIPESECTIONTO
                          ,ndisplacementfrom => RROW.DISPLACEMENTFROM
                          ,ndisplacementto   => RROW.DISPLACEMENTTO
                          ,neqlocation       => RROW.EQLOCATION
                          ,nconsectionfrom   => RROW.CONSECTIONFROM
                          ,nconsectionto     => RROW.CONSECTIONTO
                          ,ncoord_x_deg      => RROW.COORD_X_DEG
                          ,ncoord_x_min      => RROW.COORD_X_MIN
                          ,ncoord_x_sec      => RROW.COORD_X_SEC
                          ,ncoord_y_deg      => RROW.COORD_Y_DEG
                          ,ncoord_y_min      => RROW.COORD_Y_MIN
                          ,ncoord_y_sec      => RROW.COORD_Y_SEC
                          ,ccomplex_coord    => RROW.COMPLEX_COORD
                          ,nfcequipment      => RROW.FCEQUIPMENT
                          ,nobj_inst         => RROW.OBJ_INST
                          ,sbarcode          => RROW.BARCODE
                          ,ddate_from        => RROW.DATE_FROM
                          ,ddate_to          => RROW.DATE_TO
                          ,sregnumb          => RROW.REGNUMB
                          ,nfaceacc          => RROW.FACEACC
                          ,ncost_place       => RROW.COST_PLACE
                          ,nrn               => nRN);
  end EQCONFIG_BASE_INSERT;
  --#########################################################################################################

  procedure EQCONFIG_BASE_UPDATE
  /*
  Заголовок. Исправление базовое 
  */
  (
   rROW         in eqconfig%rowtype
  ) 
  is 
  begin
    p_eqconfig_base_update(ncompany          => rROW.COMPANY
                          ,nrn               => rROW.RN
                          ,nprn              => rROW.PRN
                          ,njur_pers         => rROW.JUR_PERS
                          ,scode             => rROW.CODE
                          ,sname             => rROW.NAME
                          ,sstruct_code      => rROW.STRUCT_CODE
                          ,npr_obj_level     => rROW.PR_OBJ_LEVEL
                          ,nobj_type         => rROW.OBJ_TYPE
                          ,nth_obj_level     => rROW.TH_OBJ_LEVEL
                          ,nobj_kind         => rROW.OBJ_KIND
                          ,swork_numb        => rROW.WORK_NUMB
                          ,sclasscode        => rROW.CLASSCODE
                          ,sinv_numb         => rROW.INV_NUMB
                          ,spos_numb         => rROW.POS_NUMB
                          ,doper_date        => rROW.OPER_DATE
                          ,sdraft            => rROW.DRAFT
                          ,sstandard         => rROW.STANDARD
                          ,naccept_res       => rROW.ACCEPT_RES
                          ,nstat_res         => rROW.STAT_RES
                          ,numeas_res        => rROW.UMEAS_RES
                          ,nquant            => rROW.QUANT
                          ,nfict_rec         => rROW.FICT_REC
                          ,nextra_obj        => rROW.EXTRA_OBJ
                          ,nresp_div         => rROW.RESP_DIV
                          ,ntech_srv_div     => rROW.TECH_SRV_DIV
                          ,nnomen            => rROW.NOMEN
                          ,nnom_modif        => rROW.NOM_MODIF
                          ,nowner_agent      => rROW.OWNER_AGENT
                          ,nfix_state        => rROW.FIX_STATE
                          ,nfix_moves        => rROW.FIX_MOVES
                          ,nproduce_agnlist  => rROW.PRODUCE_AGNLIST
                          ,dproduce_date     => rROW.PRODUCE_DATE
                          ,sfactory_number   => rROW.FACTORY_NUMBER
                          ,neqsetplace       => rROW.EQSETPLACE
                          ,neqsetmode        => rROW.EQSETMODE
                          ,neqjoinpipeline   => rROW.EQJOINPIPELINE
                          ,npipelinefrom     => rROW.PIPELINEFROM
                          ,npipelineto       => rROW.PIPELINETO
                          ,spicketagefrom    => rROW.PICKETAGEFROM
                          ,spicketageto      => rROW.PICKETAGETO
                          ,npicketagefrom_m  => rROW.PICKETAGEFROM_M
                          ,npicketageto_m    => rROW.PICKETAGETO_M
                          ,npipesectionfrom  => rROW.PIPESECTIONFROM
                          ,npipesectionto    => rROW.PIPESECTIONTO
                          ,ndisplacementfrom => rROW.DISPLACEMENTFROM
                          ,ndisplacementto   => rROW.DISPLACEMENTTO
                          ,neqlocation       => rROW.EQLOCATION
                          ,nconsectionfrom   => rROW.CONSECTIONFROM
                          ,nconsectionto     => rROW.CONSECTIONTO
                          ,ncoord_x_deg      => rROW.COORD_X_DEG
                          ,ncoord_x_min      => rROW.COORD_X_MIN
                          ,ncoord_x_sec      => rROW.COORD_X_SEC
                          ,ncoord_y_deg      => rROW.COORD_Y_DEG
                          ,ncoord_y_min      => rROW.COORD_Y_MIN
                          ,ncoord_y_sec      => rROW.COORD_Y_SEC
                          ,ccomplex_coord    => rROW.COMPLEX_COORD
                          ,nfcequipment      => rROW.FCEQUIPMENT
                          ,nobj_inst         => rROW.OBJ_INST
                          ,sbarcode          => rROW.BARCODE
                          ,ddate_from        => rROW.DATE_FROM
                          ,ddate_to          => rROW.DATE_TO
                          ,sregnumb          => rROW.REGNUMB
                          ,nfaceacc          => rROW.FACEACC
                          ,ncost_place       => rROW.COST_PLACE);

  end EQCONFIG_BASE_UPDATE;
  --#########################################################################################################

  function EQCONFIGSH_GET
  /*
  История смены состояний. Считывание
  */
  (
   nRN      in number 
  ) 
  return eqconfigsh%rowtype
  is
    rRow eqconfigsh%rowtype;
  begin
    begin
      select T.*
        into rRow
        from eqconfigsh t
       where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(nflag_smart => 1, stable_name => 'EQCONFIGSH'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'EQCONFIGSH')));
    end;
    return(rRow);
  end EQCONFIGSH_GET;
  --#########################################################################################################

  procedure EQCONFIGSH_BUPDATE
  /*
  История смены состояний. Исправление. Перед 
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EQCONFIGSH_BUPDATE;
  --#########################################################################################################

  procedure EQCONFIGSH_AUPDATE
  /*
  История смены состояний. Исправление. После
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end EQCONFIGSH_AUPDATE;
--#########################################################################################################

end USR_PKG_EQCONFIG;
/
