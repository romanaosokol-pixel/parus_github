create or replace package USR_PKG_PROJECT is
  /*
  Package предназначен для работы с разделом "Проекты". 
  Projects                    PROJECT                 PJ      Проекты
  ProjectsStages              PROJECTSTAGE            PJS     Проекты (этапы)
  UDOProjectsStagesSheet      UDO_PROJECTSTAGE_SHT    PJSSH   Проекты (этапы, ведомость производства)
  UdoProjectExecutiveList     UDO_PRJEXEC_LIST        PJEL    Проекты (ответственные)
  UdoProjectExecListArticles  UDO_PRJEXECLST_ARTICLE  PJELA   Проекты (ответственные, изделия)
  */
  /* ######################################################################################################### */

  function PROJECT_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return project%rowtype;
  /* ######################################################################################################### */

  function PROJECT_GET_RN_BY_FACEACC
  /*
  Заголовок. Поиск RN проекта по RN лицевого счёта затрат
  */
  (
   nFLAGSMART   in number 
  ,nFACEACC     in number  
  ) 
  return number;
  /* ######################################################################################################### */

  function PROJECT_GET_CODE_ID
  /*
  Заголовок. Поиск кода проекта по RN
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number  
  ) 
  return varchar2;
  /*#########################################################################################################*/

  function PROJECT_GET_STATUS_NAME
  /*
  Заголовок. Показать наименование состояния
  */
  (
   nSTATE    in number /* номер статуса */
  ) 
  return varchar2;
  /* ######################################################################################################### */

  procedure PROJECT_BINSERT
  /*
  Заголовок. Добавление. До
  */
  (
   nRN      in number
  ,NCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECT_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECT_BUPDATE
  /*
  Заголовок. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECT_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECT_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECT_BSTATE
  /*
  Заголовок. Изменение состояния. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECT_ASTATE
  /*
  Заголовок. Изменение состояния. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECT_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in project%rowtype
  ,nSTATUS_IGNORE   in number default 0 /* Исправлять в утверждёный договор 0-нет, 1-да */
  );
  /* ######################################################################################################### */

  function PROJECTSTAGE_GET
  /*
  Этап. Считывание
  */
  (
   nRN      in number
  ) 
  return projectstage%rowtype;
  /* ######################################################################################################### */

  function PROJECTSTAGE_GET_RN_BY_FACEACC
  /*
  Проекты (этапы). Поиск RN по RN лицевого счёта затрат
  */
  (
   nFLAGSMART   in number 
  ,nFACEACC     in number  
  ) 
  return number;
  /*#########################################################################################################*/

  function PROJECTSTAGE_GET_STATUS_NAME
  /*
  Проекты (этапы). Показать наименование состояния
  */
  (
   nSTATE    in number /* номер статуса */
  ) 
  return varchar2;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_BINSERT
  /*
  Этап. Добавление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_AINSERT
  /*
  Этап. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_BUPDATE
  /*
  Этап. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_AUPDATE
  /*
  Этап. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_BDELETE
  /*
  Этап. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_BSTATE
  /*
  Этап. Изменение состояния. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_ASTATE
  /*
  Этап. Изменение состояния. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_CHECK_BASE
  /*
  Этап. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  function PROJECTSTAGE_SHT_GET
  /*
  Проекты (этапы, ведомость производства). Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return udo_projectstage_sht%rowtype;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_BINSERT
  /*
  Проекты (этапы, ведомость производства). Добавление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_AINSERT
  /*
  Проекты (этапы, ведомость производства). Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_BUPDATE
  /*
  Проекты (этапы, ведомость производства). Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_AUPDATE
  /*
  Проекты (этапы, ведомость производства). Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_BDELETE
  /*
  Проекты (этапы, ведомость производства). Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_BPRODORD_CRT
  /*
  Проекты (этапы, ведомость производства). Сформировать заказ на производство. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_APRODORD_CRT
  /*
  Проекты (этапы, ведомость производства). Сформировать заказ на производство. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_BPRODORD_RMV
  /*
  Проекты (этапы, ведомость производства). Расформировать заказ на производство. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_APRODORD_RMV
  /*
  Проекты (этапы, ведомость производства). Расформировать заказ на производство. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_CHECK_BASE
  /*
  Проекты (этапы, ведомость производства). Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  function PRJEXEC_LIST_GET
  /*
  Проекты (ответственные). Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return udo_prjexec_list%rowtype;
  /* ######################################################################################################### */
  
  function PRJEXEC_LIST_GET_BY_PARAMS
  /*
  Проекты (ответственные). Поиск по проекту и мат.ресурсу
  */
  (
   nFLAGSMART     in number default 0
  ,nPROJECT       in number
  ,nEXEC_ROLE     in number default null
  ,nMATRESOURCE   in number
  ) 
  return number;
  /* ######################################################################################################### */
  
  function PRJEXEC_LIST_GET_EXC_ROLE_NAME
  /*
  Проекты (ответственные). Получить наименование роли по номеру
  */
  (
   nEXEC_ROLE     in number
  ) 
  return varchar2;
  /* ######################################################################################################### */

  procedure PRJEXEC_LIST_AINSERT
  /*
  Проекты (ответственные). Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PRJEXEC_LIST_BUPDATE
  /*
  Проекты (ответственные). Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PRJEXEC_LIST_AUPDATE
  /*
  Проекты (ответственные). Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PRJEXEC_LIST_BDELETE
  /*
  Проекты (ответственные). Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /* ######################################################################################################### */

  procedure PRJEXEC_LIST_CHECK_BASE
  /*
  Проекты (ответственные). Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */
  
  function PRJEXECLST_ARTICLE_GET
  /*
  Проекты (ответственные, изделия). Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return udo_prjexeclst_article%rowtype;
  /* ######################################################################################################### */

  procedure PRJEXECLST_ARTICLE_AINSERT
  /*
  Проекты (ответственные, изделия). Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PRJEXECLST_ARTICLE_BUPDATE
  /*
  Проекты (ответственные, изделия). Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PRJEXECLST_ARTICLE_AUPDATE
  /*
  Проекты (ответственные, изделия). Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure PRJEXECLST_ARTICLE_BDELETE
  /*
  Проекты (ответственные, изделия). Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /* ######################################################################################################### */

  procedure PRJEXECLST_ARTICLE_CHECK_BASE
  /*
  Проекты (ответственные, изделия). Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

end USR_PKG_PROJECT;
/
create or replace package body USR_PKG_PROJECT is

  /* ######################################################################################################### */

  function PROJECT_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return project%rowtype
  is
    rRow project%rowtype;
  begin
    begin
      select t.* into rRow from project t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'PROJECT');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PROJECT')));
    end;
    return(rRow);
  end PROJECT_GET;
  /* ######################################################################################################### */

  function PROJECT_GET_RN_BY_FACEACC
  /*
  Заголовок. Поиск RN проекта по RN лицевого счёта затрат
  */
  (
   nFLAGSMART   in number 
  ,nFACEACC     in number  
  ) 
  return number
  is
    nRef  pkg_std.tref; 
  begin
    begin
      select nptoject 
        into nRef
        from (select prn as nptoject from projectstage where faceacc = nFACEACC
              union 
              select rn  as nptoject from project      where faceacc = nFACEACC);

    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Не найден проект по лицевому счёту затрат <%s>.'
                   ,get_faceacc_numb_id(nflag_smart => 1, nrn => nFACEACC));
      when too_many_rows then
        p_exception(nFLAGSMART, 'Найдено больше одного проекта по лицевому счёту затрат <%s>.'
                   ,get_faceacc_numb_id(nflag_smart => 1, nrn => nFACEACC));
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске проекта по лицевому счёту затрат <%s>.'
                   ,get_faceacc_numb_id(nflag_smart => 1, nrn => nFACEACC));
    end;

    return(nRef);

  end PROJECT_GET_RN_BY_FACEACC;
  /* ######################################################################################################### */

  function PROJECT_GET_CODE_ID
  /*
  Заголовок. Поиск кода проекта по RN
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number  
  ) 
  return varchar2
  is
    sRes  pkg_std.tstring; 
  begin
    begin
      select code into sRes from project where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found( nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'PROJECT' );
      when too_many_rows then
        p_exception( nFLAGSMART, 'Найдено больше одного проекта c RN <%s>.', nRN );
      when others then
        p_exception( 0, 'Неопределённая ситуация при поиске проекта c RN <%s>.', nRN );
    end;

    return( sRes );

  end PROJECT_GET_CODE_ID;
  /*#########################################################################################################*/

  function PROJECT_GET_STATUS_NAME
  /*
  Заголовок. Показать наименование состояния
  */
  (
   nSTATE    in number /* номер статуса */
  ) 
  return varchar2
  is
  begin
    return( case nSTATE 
              when 0 then 'Зарегистрирован'
              when 1 then 'Открыт'
              when 2 then 'Остановлен'
              when 3 then 'Закрыт'
              when 4 then 'Согласован'
              when 5 then 'Исполнение прекращено'
            else 'Не определено'  
            end );
  END PROJECT_GET_STATUS_NAME;
  /* ######################################################################################################### */

  procedure PROJECT_BINSERT
  /*
  Заголовок. Добавление. До
  */
  (
   nRN      in number
  ,NCOMPANY in number 
  ) 
  is
  begin
    null;
    /* Очистка констант */
    /*usr_pkg_pub_const.rproject := null;*/
  end PROJECT_BINSERT;
  /* ######################################################################################################### */

  procedure PROJECT_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow                  project%rowtype;
    nProjectStageExists   pkg_std.tnumber := 0; 
  begin
    /* Заголовок */
    /*rRow   := PROJECT_GET(nRN);*/
    /* Нналичие этапов */
    /*for c in (select 1 from projectstage t where t.prn  = rRow.rn) loop nProjectStageExists := 1; exit; end loop;*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКИ */
    /* Базовая*/
    project_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rproject := null;*/

  end PROJECT_AINSERT;
  /* ######################################################################################################### */

  procedure PROJECT_BUPDATE
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
    /*usr_pkg_pub_const.rproject := project_get(nrn => nRN);*/
  end PROJECT_BUPDATE;
  /* ######################################################################################################### */

  procedure PROJECT_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    project%rowtype;
  begin
    /* Запись проекта */
    /*rRow := project_get(nRN => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая */
    project_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rrowstage := null;*/

  end PROJECT_AUPDATE;
  /* ######################################################################################################### */

  procedure PROJECT_BDELETE
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
  end PROJECT_BDELETE;
  /* ######################################################################################################### */

  procedure PROJECT_BSTATE
  /*
  Заголовок. Изменение состояния. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    project%rowtype;
  begin
    null;
    /* Запись проекта */
    /*rRow := project_get(nRN => nRN);
    usr_pkg_pub_const.rproject := rRow;*/

  end PROJECT_BSTATE;
  /* ######################################################################################################### */

  procedure PROJECT_ASTATE
  /*
  Заголовок. Изменение состояния. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    project%rowtype;
    
    nNumber pkg_std.tnumber; 
  begin
    /* Запись проекта */
    rRow := project_get(nRN => nRN);

    /* ПРОВЕРКИ */
    /* Состояние проекта Открыт или Согласован */ 
    if rRow.state in ( 1, 4  ) then
      /* Количество в проекте сотрудников "Ответственный (главный конструктор)" */
      select count(*)
        into nNumber
        from udo_prjexec_list
       where prn       = rRow.rn
         and exec_role = 0;
      /* Нет в проекте сотрудников "Ответственный (главный конструктор)" */
      if nNumber = 0 then         
        p_exception(0, 'В разделе "Проекты (ответственные) не задан сотрудник с ролью "Ответственный (главный конструктор)" .%s'
                   ,cr||cr|| f_docdescrs_get_description( sunitcode => 'Projects', ndocument => rrow.rn ));
      end if;
    end if;

  end PROJECT_ASTATE;
  /* ######################################################################################################### */

  procedure PROJECT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
    nRN      in number
   ,nCOMPANY in number
  ) 
  is
    rRow                project%rowtype;
    nProjectStageExists pkg_std.tnumber := 0;
  begin

    /* Заголовок  */
    rrow := project_get(nrn => nrn);

    /* ПРОВЕРКИ */

    /* Обязательность заполгнения поля "Внешний заказчик" для всех проектов с типами кроме (20,21,22) */

    for cur in (select pt.code
                      ,pr.ext_cust
                  from project pr
                  join prjtype pt
                    on pt.rn = pr.prjtype
                 where pr.rn = nrn)
    loop
      if cur.code not in (20
                         ,21
                         ,22)
         and cur.ext_cust is null
      then
        p_exception(0
                   ,'Для проектов с типом %s обязательно заполнение поля "Внешний заказчик"'
                   ,cur.code);
      end if;
    end loop;

    /* Дублирование условного наименования */
    for c in (select *
                from project
               where name_usl = rrow.name_usl
                 and rn != rrow.rn)
    loop
      p_exception(0
                 ,'В системе уже существует проект с условным наименованием <%s> с мнемокодом <%s>. %s'
                 ,c.name_usl
                 ,c.name
                 ,cr || f_docdescrs_get_description(sunitcode => 'Projects'
                                                   ,ndocument => rrow.rn));
    end loop;

  end project_check_base;
  /* ######################################################################################################### */

  procedure PROJECT_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW             in project%rowtype
  ,nSTATUS_IGNORE   in number default 0 /* Исправлять в утверждёный договор 0-нет, 1-да */
  ) 
  is
  begin
    /* Если договор утверждён, то снимаем утверждение */
    /*if nSTATUS_IGNORE = 1 and rPROJECT.STATE = 1 then
      update project set state = 0 where rn = rPROJECT.RN;
    end if;*/
    /* Исправление */
    p_project_base_update(nrn                => rROW.RN
                         ,ncompany           => rROW.COMPANY
                         ,njur_pers          => rROW.JUR_PERS
                         ,scode              => rROW.CODE
                         ,sname              => rROW.NAME
                         ,sname_usl          => rROW.NAME_USL
                         ,sdoc_osn           => rROW.DOC_OSN
                         ,nprjtype           => rROW.PRJTYPE
                         ,nfaceacc           => rROW.FACEACC
                         ,ngr_pnt_cost       => rROW.GR_PNT_COST
                         ,sexpected_res      => rROW.EXPECTED_RES
                         ,nsubdiv_cust       => rROW.SUBDIV_CUST
                         ,next_cust          => rROW.EXT_CUST
                         ,nsubdiv_resp       => rROW.SUBDIV_RESP
                         ,nresponsible       => rROW.RESPONSIBLE
                         ,nstate             => rROW.STATE
                         ,dbegplan           => rROW.BEGPLAN
                         ,dbegfact           => rROW.BEGFACT
                         ,dendplan           => rROW.ENDPLAN
                         ,dendfact           => rROW.ENDFACT
                         ,ncurnames          => rROW.CURNAMES
                         ,ncost_sum          => rROW.COST_SUM
                         ,snote              => rROW.NOTE
                         ,ddo_act_from       => rROW.DO_ACT_FROM
                         ,nrflct_hs          => rROW.RFLCT_HS
                         ,nlab_proj          => rROW.LAB_PROJ
                         ,nlab_plan          => rROW.LAB_PLAN
                         ,nlab_fact          => rROW.LAB_FACT
                         ,nlab_part          => rROW.LAB_PART
                         ,nlab_meas          => rROW.LAB_MEAS
                         ,schng_base         => rROW.CHNG_BASE
                         ,nfaceacccust       => rROW.FACEACCCUST
                         ,ngr_pnt_cust       => rROW.GR_PNT_CUST
                         ,ngovcntrid         => rROW.GOVCNTRID
                         ,ncost_sum_basecurr => rROW.COST_SUM_BASECURR
                         ,nplane_rate        => rROW.PLANE_RATE
                         ,ncalcschm          => rROW.CALCSCHM);

    /* Если договор утверждён, то восстанавливаем утверждение */
    /*if nSTATUS_IGNORE = 1 and rPROJECT.STATE = 1 then
      update project set state = rPROJECT.STATUS where rn = rPROJECT.RN;
    end if;*/
  end PROJECT_BASE_UPDATE;
  /* ######################################################################################################### */

  function PROJECTSTAGE_GET
  /*
  Проекты (этапы). Считывание
  */
  (
   nRN      in number
  ) 
  return projectstage%rowtype
  is
    rRow projectstage%rowtype;
  begin
    begin
      select * into rRow from projectstage t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'PROJECTSTAGE');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'PROJECTSTAGE')));
    end;
    return(rRow);
  end PROJECTSTAGE_GET;
  /* ######################################################################################################### */

  function PROJECTSTAGE_GET_RN_BY_FACEACC
  /*
  Проекты (этапы). Поиск RN по RN лицевого счёта затрат
  */
  (
   nFLAGSMART   in number 
  ,nFACEACC     in number  
  ) 
  return number
  is
    nRef  pkg_std.tref; 
  begin
    begin
      select rn into nRef from projectstage where faceacc = nFACEACC;
    exception
      when no_data_found then
        p_exception(nFLAGSMART, 'Не найден этап проекта по лицевому счёту затрат "%s".'
                   ,get_faceacc_numb_id( nflag_smart => 1, nrn => nFACEACC ) );
      when too_many_rows then
        p_exception(nFLAGSMART, 'Найдено больше одного этапа проекта по лицевому счёту затрат "%s".'
                   ,get_faceacc_numb_id( nflag_smart => 1, nrn => nFACEACC ) );
      when others then
        p_exception(0, 'Неопределённая ситуация при поиске этапа проекта по лицевому счёту затрат "%s".'
                   ,get_faceacc_numb_id(nflag_smart => 1, nrn => nFACEACC ) );
    end;

    return( nRef );

  end PROJECTSTAGE_GET_RN_BY_FACEACC;
  /*#########################################################################################################*/

  function PROJECTSTAGE_GET_STATUS_NAME
  /*
  Проекты (этапы). Показать наименование состояния
  */
  (
   nSTATE    in number /* номер статуса */
  ) 
  return varchar2
  is
  begin
    return( case nSTATE 
              when 0 then 'Зарегистрирован'
              when 1 then 'Открыт'
              when 2 then 'Закрыт'
              when 3 then 'Согласован'
              when 4 then 'Исполнение прекращено'
              when 5 then 'Остановлен'
            else 'Не определено'  
            end );
  END PROJECTSTAGE_GET_STATUS_NAME;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_BINSERT
  /*
  Проекты (этапы). Добавление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* Очистка констант */
    /*usr_pkg_pub_const.rRow := null;*/
  end PROJECTSTAGE_BINSERT;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_AINSERT
  /*
  Проекты (этапы). Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         projectstage%rowtype;
  begin
    /* Проекты (этапы) */
    /*rRow := projectstage_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    projectstage_check_base(nrn => nRN, ncompany => nCOMPANY);

  end PROJECTSTAGE_AINSERT;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_BUPDATE
  /*
  Проекты (этапы). Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /*usr_pkg_pub_const.rprojectstage := projectstage_get(nrn => nRN); */
  end PROJECTSTAGE_BUPDATE;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_AUPDATE
  /*
  Проекты (этапы). Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            projectstage%rowtype;
  begin
    /* Заголовок */
    /*rRow := projectstage_get(nrn => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая*/
    projectstage_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант* /
    /*usr_pkg_pub_const.rprojectstage := null;*/

  end PROJECTSTAGE_AUPDATE;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_BDELETE
  /*
  Проекты (этапы). Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
  begin
    null;
  end PROJECTSTAGE_BDELETE;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_BSTATE
  /*
  Проекты (этапы). Изменение состояния. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
  begin
    null;
    /*usr_pkg_pub_const.rprojectstage := projectstage_get(nrn => nRN); */
  end PROJECTSTAGE_BSTATE;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_ASTATE
  /*
  Проекты (этапы). Изменение состояния. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end PROJECTSTAGE_ASTATE;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_CHECK_BASE
  /*
  Проекты (этапы). Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         projectstage%rowtype;
    rProject      project%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow    := projectstage_get(nrn => nRN);
    rProject := project_get(nrn => rRow.prn);*/

    /* ПРОВЕРКИ */

  end PROJECTSTAGE_CHECK_BASE;
  /* ######################################################################################################### */

  function PROJECTSTAGE_SHT_GET
  /*
  Проекты (этапы, ведомость производства). Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return udo_projectstage_sht%rowtype
  is
    rRow udo_projectstage_sht%rowtype;
  begin
    begin
      select * into rRow from udo_projectstage_sht where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'UDO_PROJECTSTAGE_SHT');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'UDO_PROJECTSTAGE_SHT')));
    end;
    return(rRow);
  end PROJECTSTAGE_SHT_GET;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_BINSERT
  /*
  Проекты (этапы, ведомость производства). Добавление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* Очистка констант */
    /*usr_pkg_pub_const.rRow := null;*/
  end PROJECTSTAGE_SHT_BINSERT;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_AINSERT
  /*
  Проекты (этапы, ведомость производства). Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         udo_projectstage_sht%rowtype;
  begin
    /* Проекты (этапы, ведомость производства) */
    /*rRow := udo_projectstage_sht_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    projectstage_sht_check_base(nrn => nRN, ncompany => nCOMPANY);

  end PROJECTSTAGE_SHT_AINSERT;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_BUPDATE
  /*
  Проекты (этапы, ведомость производства). Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /*usr_pkg_pub_const.rudo_projectstage_sht := udo_projectstage_sht_get(nrn => nRN); */
  end PROJECTSTAGE_SHT_BUPDATE;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_AUPDATE
  /*
  Проекты (этапы, ведомость производства). Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            udo_projectstage_sht%rowtype;
  begin
    /* Заголовок */
    /*rRow := udo_projectstage_sht_get(nrn => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая*/
    projectstage_sht_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант* /
    /*usr_pkg_pub_const.rudo_projectstage_sht := null;*/

  end PROJECTSTAGE_SHT_AUPDATE;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_BDELETE
  /*
  Проекты (этапы, ведомость производства). Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
  begin
    null;
  end PROJECTSTAGE_SHT_BDELETE;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_BPRODORD_CRT
  /*
  Проекты (этапы, ведомость производства). Сформировать заказ на производство. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
  begin
    /* Сохранение RN в константу для инициализации в триггере сохранения данных о сформированных документах */
    usr_pkg_pub_const.nIdentBefore := nRN;
  end PROJECTSTAGE_SHT_BPRODORD_CRT;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_APRODORD_CRT
  /*
  Проекты (этапы, ведомость производства). Сформировать заказ на производство. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    sFVD_PropVal    docs_props_vals.str_value%type;
    
    nNumber     pkg_std.tnumber; 
    dDate       date;
  begin
    /* По сформированным документам */
    for c in ( select out_document0 from usr_t_inhierbuff where identbefore = usr_pkg_pub_const.nIdentBefore )
    loop
      /* копирование свойств */
      /* фото-видео документирование */
      sFVD_PropVal := usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 160686482, ndocument => nRN);
      pkg_docs_props_vals.modify(nproperty   => 160686482
                                ,sunitcode   => 'ProductionOrders'
                                ,ndocument   => c.out_document0
                                ,sstr_value  => sFVD_PropVal
                                ,nnum_value  => nNumber 
                                ,ddate_value => dDate   
                                ,nrn         => nNumber);
      
      /* проверка заголовка */
      usr_pkg_productord.productord_ainsert(nrn => c.out_document0, ncompany => nCOMPANY);
    end loop;

    /* Очистка записей временной таблицы взаимосвязей */
    delete from usr_t_inhierbuff where identbefore = usr_pkg_pub_const.nIdentBefore;
    usr_pkg_pub_const.nIdentBefore := null;

  end PROJECTSTAGE_SHT_APRODORD_CRT;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_BPRODORD_RMV
  /*
  Проекты (этапы, ведомость производства). Расформировать заказ на производство. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
  begin
    null;
    /*usr_pkg_pub_const.rudo_projectstage_sht := udo_projectstage_sht_get(nrn => nRN); */
  end PROJECTSTAGE_SHT_BPRODORD_RMV;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_APRODORD_RMV
  /*
  Проекты (этапы, ведомость производства). Расформировать заказ на производство. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end PROJECTSTAGE_SHT_APRODORD_RMV;
  /* ######################################################################################################### */

  procedure PROJECTSTAGE_SHT_CHECK_BASE
  /*
  Проекты (этапы, ведомость производства). Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         udo_projectstage_sht%rowtype;
    rProject      project%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow    := udo_projectstage_sht_get(nrn => nRN);
    rProject := project_get(nrn => rRow.prn);*/

    /* ПРОВЕРКИ */

  end PROJECTSTAGE_SHT_CHECK_BASE;
  /* ######################################################################################################### */

  function PRJEXEC_LIST_GET
  /*
  Проекты (ответственные). Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return udo_prjexec_list%rowtype
  is
    rRow udo_prjexec_list%rowtype;
  begin
    begin
      select * into rRow from udo_prjexec_list where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'UDO_PRJEXEC_LIST');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'UDO_PRJEXEC_LIST')));
    end;
    return(rRow);
  end PRJEXEC_LIST_GET;
  /* ######################################################################################################### */
  
  function PRJEXEC_LIST_GET_BY_PARAMS
  /*
  Проекты (ответственные). Поиск по проекту и мат.ресурсу
  */
  (
   nFLAGSMART     in number default 0
  ,nPROJECT       in number
  ,nEXEC_ROLE     in number default null
  ,nMATRESOURCE   in number
  ) 
  return number
  is
    nRef    pkg_std.tref; 
  begin
    begin
      select pjel.rn
        into nRef 
        from udo_prjexec_list       pjel
            ,udo_prjexeclst_article pjela
       where  pjela.prn      = pjel.rn
         and  pjel.prn       = nPROJECT
         and (pjel.exec_role = nEXEC_ROLE or nEXEC_ROLE is null)
         and  pjela.matres   = nMATRESOURCE;
    exception
      when no_data_found then
        p_exception( nFLAGSMART, 'Не найден ответственный сотрудник для изделия <%s>.%s'
                   ,nMATRESOURCE 
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'Projects', ndocument => nPROJECT) );
      when too_many_rows then
        p_exception( nFLAGSMART, 'Найдено больше одного ответственных сотрудников для изделия <%s>.%s'
                   ,nMATRESOURCE
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'Projects', ndocument => nPROJECT) );
      when others then
        p_exception( 0, 'Неопределённая ситуация при поиске ответственного сотрудника для изделия <%s>.%s'
                   ,nMATRESOURCE
                   ,cr||cr||f_docdescrs_get_description(sunitcode => 'Projects', ndocument => nPROJECT) );
    end;

    return( nRef );

  end PRJEXEC_LIST_GET_BY_PARAMS;
  /* ######################################################################################################### */
  
  function PRJEXEC_LIST_GET_EXC_ROLE_NAME
  /*
  Проекты (ответственные). Получить наименование роли по номеру
  */
  (
   nEXEC_ROLE     in number
  ) 
  return varchar2
  is
  begin
    return( case  nEXEC_ROLE 
              when 0 then 'Ответственный(Главный конструктор)'
              when 1 then 'Руководитель работ'
              when 2 then 'ТКПА'
              when 3 then 'Зам.Ответственного'
              when 4 then 'Конструктор'
            else 'Неверный номер роли'
            end );

  end PRJEXEC_LIST_GET_EXC_ROLE_NAME;
  /* ######################################################################################################### */

  procedure PRJEXEC_LIST_AINSERT
  /*
  Проекты (ответственные). Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         udo_prjexec_list%rowtype;
  begin
    /* Проекты (ответственные) */
    /*rRow := udo_prjexec_list_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    prjexec_list_check_base(nrn => nRN, ncompany => nCOMPANY);

  end PRJEXEC_LIST_AINSERT;
  /* ######################################################################################################### */

  procedure PRJEXEC_LIST_BUPDATE
  /*
  Проекты (ответственные). Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /*usr_pkg_pub_const.rudo_prjexec_list := udo_prjexec_list_get(nrn => nRN); */
  end PRJEXEC_LIST_BUPDATE;
  /* ######################################################################################################### */

  procedure PRJEXEC_LIST_AUPDATE
  /*
  Проекты (ответственные). Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            udo_prjexec_list%rowtype;
  begin
    /* Заголовок */
    /*rRow := udo_prjexec_list_get(nrn => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая*/
    prjexec_list_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант* /
    /*usr_pkg_pub_const.rudo_prjexec_list := null;*/

  end PRJEXEC_LIST_AUPDATE;
  /* ######################################################################################################### */

  procedure PRJEXEC_LIST_BDELETE
  /*
  Проекты (ответственные). Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
  begin
    null;
  end PRJEXEC_LIST_BDELETE;
  /* ######################################################################################################### */

  procedure PRJEXEC_LIST_CHECK_BASE
  /*
  Проекты (ответственные). Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         udo_prjexec_list%rowtype;
    rProject      project%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow    := udo_prjexec_list_get(nrn => nRN);
    rProject := project_get(nrn => rRow.prn);*/

    /* ПРОВЕРКИ */

  end PRJEXEC_LIST_CHECK_BASE;
  /* ######################################################################################################### */
  
  function PRJEXECLST_ARTICLE_GET
  /*
  Проекты (ответственные, изделия). Считывание
  */
  (
   nRN          in number
  ,nFLAGSMART   in number default 0
  ) 
  return udo_prjexeclst_article%rowtype
  is
    rRow udo_prjexeclst_article%rowtype;
  begin
    begin
      select * into rRow from udo_prjexeclst_article where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => nFLAGSMART, ndocument => nRN, sunit_table => 'UDO_PRJEXECLST_ARTICLE');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'UDO_PRJEXECLST_ARTICLE')));
    end;
    return(rRow);
  end PRJEXECLST_ARTICLE_GET;
  /* ######################################################################################################### */

  procedure PRJEXECLST_ARTICLE_AINSERT
  /*
  Проекты (ответственные, изделия). Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         udo_prjexeclst_article%rowtype;
  begin
    /* Проекты (ответственные, изделия) */
    /*rRow := udo_prjexeclst_article_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    prjexeclst_article_check_base(nrn => nRN, ncompany => nCOMPANY);

  end PRJEXECLST_ARTICLE_AINSERT;
  /* ######################################################################################################### */

  procedure PRJEXECLST_ARTICLE_BUPDATE
  /*
  Проекты (ответственные, изделия). Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /*usr_pkg_pub_const.rudo_prjexeclst_article := udo_prjexeclst_article_get(nrn => nRN); */
  end PRJEXECLST_ARTICLE_BUPDATE;
  /* ######################################################################################################### */

  procedure PRJEXECLST_ARTICLE_AUPDATE
  /*
  Проекты (ответственные, изделия). Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            udo_prjexeclst_article%rowtype;
  begin
    /* Заголовок */
    /*rRow := udo_prjexeclst_article_get(nrn => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая*/
    prjexeclst_article_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант* /
    /*usr_pkg_pub_const.rudo_prjexeclst_article := null;*/

  end PRJEXECLST_ARTICLE_AUPDATE;
  /* ######################################################################################################### */

  procedure PRJEXECLST_ARTICLE_BDELETE
  /*
  Проекты (ответственные, изделия). Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
  begin
    null;
  end PRJEXECLST_ARTICLE_BDELETE;
  /* ######################################################################################################### */

  procedure PRJEXECLST_ARTICLE_CHECK_BASE
  /*
  Проекты (ответственные, изделия). Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            udo_prjexeclst_article%rowtype;
    rPrjExec_List   udo_prjexec_list%rowtype;
  begin
    /* Заголовок */
    rRow          := prjexeclst_article_get(nrn => nRN);
    rPrjExec_List := prjexec_list_get(nrn => rRow.prn);

    /* ПРОВЕРКИ */
    /* Проверка наличия назначения изделия нескольким сотрудникам внутри одного проекта и у одной роли */
    for c in ( select pjela.company
                     ,pjel.prn      as pjel_prn
                     ,pjel.person   as pjel_person
                     ,pjela.matres  as pjela_matres
                 from udo_prjexeclst_article pjela
                     ,udo_prjexec_list       pjel
                where pjel.rn        = pjela.prn 
                  and pjela.rn      != rRow.rn
                  and pjela.matres   = rRow.matres
                  and pjel.prn       = rPrjExec_List.prn 
                  and pjel.exec_role = rPrjExec_List.exec_role )
    loop
      p_exception( 0, 'В этом проекте изделие <%s> уже назначено сотруднику <%s> с ролью <%s>.%s'
                 ,c.pjela_matres
                 ,prjexec_list_get_exc_role_name(nexec_role => rPrjExec_List.exec_role)
                 ,get_clnpersons_code_id(nflag_smart => 1, nrn => c.pjel_person) 
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'Projects', ndocument => rPrjExec_List.prn) );
    end loop;                 

  end PRJEXECLST_ARTICLE_CHECK_BASE;
  /* ######################################################################################################### */

end USR_PKG_PROJECT;
/
