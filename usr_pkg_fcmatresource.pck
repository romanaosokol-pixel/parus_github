create or replace package USR_PKG_FCMATRESOURCE is
  /*
  Package предназначен для работы с разделом "Материальные ресурсы". 
  CostMaterialResources    FCMATRESOURCE     FMR
  */
  /*#########################################################################################################*/

  function FCMATRESOURCE_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return fcmatresource%rowtype;

  /*#########################################################################################################*/

  procedure FCMATRESOURCE_GET_BY_NOM_MODIF
  /*
  Процедура получения мат.ресурса по номенклатуре и модификации
  */
  (
   nFLAGSMART   in number default 0 
  ,nNOMEN       in number
  ,nMODIF       in number
  ,nRN          out number
  ,sCODE        out varchar
  ,sNAME        out varchar
  );
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_GET_NOMEN
  /*
  Процедура получения данных номенклатуры 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0 
  ,nNOMEN       out number
  ,sNOMEN       out varchar2
  ,sNOMEN_NAME  out varchar2
  );
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_GET_MODIF
  /*
  Процедура получения данных модификации  
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0 
  ,nMODIF       out number
  ,sMODIF       out varchar2
  ,sMODIF_NAME  out varchar2
  );
  /* ######################################################################################################### */
  
  function FCMATRESOURCE_GET_BY_DPO
  /*
  Заголовок. Поиск по заказу подразделения
  */
  (
   nFLAGSMART       in number default 0
  ,nTOO_MANY_ROWS   in number default 0
  ,nDEPARTMENTORD   in number
  ) 
  return number;
  /* ######################################################################################################### */
  
  function FCMATRESOURCE_GET_FCUSAGE_LIST
  /*
  Заголовок. Получить список мат.ресурсов применяемости для заданного мат.ресурса
  */
  (
   nRN              in number
  ,nCOMPANY         in number
  ) 
  return udo_tp_numtable;
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_BUPDATE
  /*
  Заголовок. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_AANNUL
  /*
  Заголовок. Аннулирование. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_AANNUL_UNDO
  /*
  Заголовок. Отмена ннулирования. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in fcmatresource%rowtype
  );
  /*#########################################################################################################*/

end USR_PKG_FCMATRESOURCE;
/
create or replace package body USR_PKG_FCMATRESOURCE is

  /*#########################################################################################################*/

  function FCMATRESOURCE_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN          in number 
  ,nFLAGSMART   in number default 0 
  ) 
  return fcmatresource%rowtype
  is
    rRow fcmatresource%rowtype;
  begin
    begin
      select t.* into rRow from fcmatresource t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'FCMATRESOURCE');
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCMATRESOURCE')));
    end;
    return(rRow);
  end FCMATRESOURCE_GET;
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_GET_BY_NOM_MODIF
  /*
  Процедура получения мат.ресурса по номенклатуре и модификации
  */
  (
   nFLAGSMART   in number default 0 
  ,nNOMEN       in number
  ,nMODIF       in number
  ,nRN          out number
  ,sCODE        out varchar
  ,sNAME        out varchar
  ) 
  is
  begin
    begin
      select t.rn, t.code, t.name
        into  nRN,  sCODE, sNAME
        from fcmatresource t
       where t.nomenclature        = nNOMEN
         and nvl(t.nomen_modif, 0) = nvl(nMODIF, 0);
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nrn, sunit_table => 'FCMATRESOURCE');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCMATRESOURCE')) );
    end;
  end FCMATRESOURCE_GET_BY_NOM_MODIF;
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_GET_NOMEN
  /*
  Процедура получения данных номенклатуры 
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0 
  ,nNOMEN       out number
  ,sNOMEN       out varchar2
  ,sNOMEN_NAME  out varchar2
  ) 
  is
  begin
    begin
      select dnm.rn, dnm.nomen_code, dnm.nomen_name
        into nNOMEN, sNOMEN        , sNOMEN_NAME   
        from fcmatresource t, dicnomns dnm
       where t.rn     = nRN
         and dnm.rn   = t.nomenclature;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nrn, sunit_table => 'FCMATRESOURCE');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCMATRESOURCE')) );
    end;
  end FCMATRESOURCE_GET_NOMEN;
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_GET_MODIF
  /*
  Процедура получения данных модификации  
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0 
  ,nMODIF       out number
  ,sMODIF       out varchar2
  ,sMODIF_NAME  out varchar2
  ) 
  is
  begin
    begin
      select nm.rn , nm.modif_code, nm.modif_name
        into nMODIF, sMODIF       , sMODIF_NAME  
        from fcmatresource t, nommodif nm
       where t.rn     = nRN
         and nm.rn(+) = t.nomen_modif;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nrn, sunit_table => 'FCMATRESOURCE');
      when others then
        p_exception(0 ,'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FCMATRESOURCE')) );
    end;
  end FCMATRESOURCE_GET_MODIF;
  /* ######################################################################################################### */
  
  function FCMATRESOURCE_GET_BY_DPO
  /*
  Заголовок. Поиск по заказу подразделения
  */
  (
   nFLAGSMART       in number default 0
  ,nTOO_MANY_ROWS   in number default 0
  ,nDEPARTMENTORD   in number
  ) 
  return number
  is
    nRef          pkg_std.tref; 
    nProductOrd   pkg_std.tref; 
  begin
    /* Заказ на производство */
    nProductOrd := usr_pkg_productord.productord_get_by_dpo(nflagsmart     => nFLAGSMART
                                                           ,ntoo_many_rows => nTOO_MANY_ROWS
                                                           ,ndepartmentord => nDEPARTMENTORD);
    /* Поиск мат.ресурса */
    begin
      select fmr.rn
        into nRef
        from productords   po
            ,fcmatresource fmr
       where po.prn           = nProductOrd
         and fmr.nomenclature = po.nomen
         and fmr.nomen_modif  = po.nom_modif;
    exception
      when no_data_found then
        p_exception( nFLAGSMART, 'Не найден материальный ресурс для заказа подразделения <%s>.', nDEPARTMENTORD );
      when too_many_rows then
        if nFLAGSMART = 0 then
          p_exception( nTOO_MANY_ROWS, 'Найдено больше одного материального ресурса для заказа подразделения <%s>.', nDEPARTMENTORD );
        end if;
      when others then
        p_exception( 0, 'Неопределённая ситуация при поиске материального ресурса для заказа подразделения <%s>.', nDEPARTMENTORD );
    end;

    return nRef;

  end FCMATRESOURCE_GET_BY_DPO;
  /* ######################################################################################################### */
  
  function FCMATRESOURCE_GET_FCUSAGE_LIST
  /*
  Заголовок. Получить список мат.ресурсов применяемости для заданного мат.ресурса
  */
  (
   nRN              in number
  ,nCOMPANY         in number
  ) 
  return udo_tp_numtable
  is
    nFcUsage  pkg_std.tref; 
    aRNList   udo_tp_numtable;
  begin
    /* Формирование применяемости на будущую дату */
    p_fcusage_make(ncompany   => nCOMPANY
                  ,ncrn       => 7861062
                  ,scatalog   => null /* 'Применяемость '*/
                  ,nmatres    => nRN
                  ,snomen     => null
                  ,smodif     => null
                  ,dform_date => to_date('31.12.2099', 'dd.mm.yyyy')  
                  ,npr_cond   => null
                  ,spr_cond   => null
                  ,nrn        => nFcUsage);

    /* Считывание мат.ресурсов из спецификации применяемости */
    select matres bulk collect
      into aRNList
      from fcusagesp
     where nvl(hrn, 0)  in (0)
       and prn          = nFcUsage;

    /* Удаление применяемости */
    p_fcusage_delete(nrn => nFcUsage, ncompany => nCOMPANY);
    
    /* Результат */
    return aRNList;

  end FCMATRESOURCE_GET_FCUSAGE_LIST;
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    fcmatresource%rowtype;
  begin
    /* Заголовок */
    /*rRow   := FCMATRESOURCE_GET(nRN);*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКИ */
    /* Базовая*/
    fcmatresource_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rfcmatresource := null;*/

  end FCMATRESOURCE_AINSERT;
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_BUPDATE
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
    /*usr_pkg_pub_const.rfcmatresource := fcmatresource_get(nrn => nRN);*/
  end FCMATRESOURCE_BUPDATE;
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    fcmatresource%rowtype;
  begin
    /* Запись */
    /*rRow := fcmatresource_get(nRN => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая */
    fcmatresource_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rrowstage := null;*/

  end FCMATRESOURCE_AUPDATE;
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end FCMATRESOURCE_BDELETE;
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_AANNUL
  /*
  Заголовок. Аннулирование. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end FCMATRESOURCE_AANNUL;
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_AANNUL_UNDO
  /*
  Заголовок. Отмена ннулирования. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end FCMATRESOURCE_AANNUL_UNDO;
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow              fcmatresource%rowtype;
  begin
    null;
    /* Заголовок  */
    /*rRow := fcmatresource_get(nRN => nRN);*/

    /* ПРОВЕРКИ */
    /* Проверка мнемокода без пробелов */
    for c in (
              select t.code
                from fcmatresource t 
               where t.rn != rRow.rn
                 and cmp_vc2(translate(upper(usr_f_trim(sval => t.code   , nspaces => 0)), 'ETYOPAHKXCBM', 'ЕТУОРАНКХСВМ') 
                            ,translate(upper(usr_f_trim(sval => rRow.code, nspaces => 0)), 'ETYOPAHKXCBM', 'ЕТУОРАНКХСВМ') ) = 1
             )
    loop
      p_exception(0, 'Существует материальный ресурс с аналогичным обозначением.'
                  ||cr||'Добавляемое обозначение: <%s>'
                  ||cr||'Существующее обозначение: <%s>'
                 ,rRow.code
                 ,c.code
                 ); 
    end loop;
    /* Проверка наименования без пробелов  */
    /*for c in (
              select t.name
                from fcmatresource t 
               where t.rn != rRow.rn
                 and cmp_vc2(translate(upper(usr_f_trim(sval => t.name   , nspaces => 0)), 'ETYOPAHKXCBM', 'ЕТУОРАНКХСВМ') 
                            ,translate(upper(usr_f_trim(sval => rRow.name, nspaces => 0)), 'ETYOPAHKXCBM', 'ЕТУОРАНКХСВМ') ) = 1
             )
    loop
      p_exception(0, 'Существует материальный ресурс с аналогичным наименованием.'
                  ||cr||'Добавляемое наименование: <%s>'
                  ||cr||'Существующее наименование: <%s>'
                 ,rRow.name
                 ,c.name
                 ); 
    end loop;*/

  end FCMATRESOURCE_CHECK_BASE;
  /*#########################################################################################################*/

  procedure FCMATRESOURCE_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in fcmatresource%rowtype
  ) 
  is
  begin
    p_fcmatresource_base_update(ncompany       => rROW.COMPANY
                               ,nrn            => rROW.RN
                               ,scode          => rROW.CODE
                               ,sname          => rROW.NAME
                               ,nnomenclature  => rROW.NOMENCLATURE
                               ,nnomen_modif   => rROW.NOMEN_MODIF
                               ,nequiv_munit   => rROW.EQUIV_MUNIT
                               ,ndef_artcl     => rROW.DEF_ARTCL
                               ,nbrak_artcl    => rROW.BRAK_ARTCL
                               ,nart_number    => rROW.ART_NUMBER
                               ,ncalc_type     => rROW.CALC_TYPE
                               ,scalc_formula  => rROW.CALC_FORMULA
                               ,npr_subdiv     => rROW.PR_SUBDIV
                               ,nprod_kind     => rROW.PROD_KIND
                               ,nres_sign      => rROW.RES_SIGN
                               ,nwrk_acc_sign  => rROW.WRK_ACC_SIGN
                               ,nstor_oper_in  => rROW.STOR_OPER_IN
                               ,nstor_oper_out => rROW.STOR_OPER_OUT
                               ,nstorage       => rROW.STORAGE
                               ,nmol           => rROW.MOL
                               ,nmtr_res       => rROW.MTR_RES
                               ,nmin_party     => rROW.MIN_PARTY
                               ,nquanin_party  => rROW.QUANIN_PARTY
                               ,nprod_cycle    => rROW.PROD_CYCLE
                               ,nnorm_munit    => rROW.NORM_MUNIT
                               ,nplan_mode     => rROW.PLAN_MODE
                               ,nmin_rest      => rROW.MIN_REST
                               ,ncalcschm      => rROW.CALCSCHM
                               ,sformat        => rROW.FORMAT
                               ,nsep_sign      => rROW.SEP_SIGN
                               ,nvirtual_sign  => rROW.VIRTUAL_SIGN
                               ,nwght_munit    => rROW.WGHT_MUNIT
                               ,nweight        => rROW.WEIGHT
                               ,nsize_munit    => rROW.SIZE_MUNIT
                               ,nlength        => rROW.LENGTH
                               ,nwidth         => rROW.WIDTH
                               ,nheight        => rROW.HEIGHT
                               ,nhalf_sign     => rROW.HALF_SIGN
                               ,nmtr_grade     => rROW.MTR_GRADE
                               ,nmtr_grade_std => rROW.MTR_GRADE_STD
                               ,nmtr_asrt      => rROW.MTR_ASRT
                               ,nmtr_asrt_std  => rROW.MTR_ASRT_STD
                               ,npr_agent      => rROW.PR_AGENT
                               ,snote          => rROW.NOTE
                               ,ntool_sign     => rROW.TOOL_SIGN
                               ,nlife          => rROW.LIFE
                               ,nlife_unit     => rROW.LIFE_UNIT
                               ,nround_calc    => rROW.ROUND_CALC
                               ,nplan_munit    => rROW.PLAN_MUNIT
                               ,nplan_coeff    => rROW.PLAN_COEFF);
  end FCMATRESOURCE_BASE_UPDATE;
  /*#########################################################################################################*/
  
end USR_PKG_FCMATRESOURCE;
/
