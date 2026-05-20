create or replace procedure USR_P_DPO_INS_TO_BP
/*
Заказы подразделений. Включить в план закупок
24/06/2024 Степанов М.
*/
(
 nIDENT         in number
,sUNITCODE      in varchar2
,sBP_TYPE       in varchar2   /* Мнемокод типа документа плана закупок */
,sBP_PREF       in varchar2   /* Префикс плана закупок */
,sBP_NUMB       in varchar2   /* Номер плана закупок */
,nDLO_CREATE    in number
,sFACEACC       in varchar
,sTAX_GR        in varchar
,nPAI_CREATE    in number
,sPAI_EXT_NUMB  in varchar
)
is
  nDocument         pkg_std.tref; 
  aRNList           udo_tp_numtable;
  rV_Row            v_departmentord%rowtype;
  rV_BuyPlanDir     v_buyplandir%rowtype;
  rV_BuyPlane       v_buyplane%rowtype;
  rV_DeliveryOrd    v_deliveryord%rowtype;
  rDeliveryOrd      deliveryord%rowtype;
  rV_FaceAcc        v_faceacc%rowtype;
  sConnect_Ext      pkg_std.tstring := pkg_session.get_connect_ext;

  nNumber           pkg_std.tnumber;
  sVarchar          pkg_std.tstring;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_DPO_INS_TO_BP');

  /* Раздел вызова */
  case sUNITCODE

    /* Заказы подразделений */
    when 'DepartmentsOrders' then

      /* Считывание отмеченной записи заголовка */
      select t.* 
        into rV_Row 
        from selectlist      sl
            ,v_departmentord t
       where sl.ident = nIdent
         and t.nrn    = sl.document ;

      /* Считывание спецификаций заголовка */
      begin
        select rn bulk collect
          into aRNList
          from departmentords
         where prn = rV_Row.nrn;
      end;

    /* Заказы подразделений (спецификации) */
    when 'DepartmentsOrdersSpecs' then

      /* Считывание RN отмеченных спецификаций */
      begin
        select sl.document bulk collect
          into aRNList
          from selectlist sl
         where sl.ident = nIDENT;
      end;

      /* Считывание записи заголовка */
      select h.* 
        into rV_Row 
        from departmentords   s
            ,v_departmentord  h
       where s.rn   in (select column_value from table(cast(aRNList as udo_tp_numtable))) 
         and h.nrn  = s.prn
         and rownum < 2 ;
  else
    p_exception(0, 'Неверный код разделя <%s>', sUNITCODE); 
  end case;

  /* Сохранение идента в константу */
  usr_pkg_pub_const.nident := rV_Row.nrn;

  /* Утверждение заказа подразделения */
  if rV_Row.nord_state = 0 then
    p_departmentord_set_state(nflag_smart  => 0
                             ,nflag_mode   => 0
                             ,ncompany     => rV_Row.ncompany
                             ,nrn          => rV_Row.nrn
                             ,nnew_state   => 1
                             ,dstate_date  => current_date
                             ,nreserv_sign => 0
                             ,nsign_warn   => 0
                             ,nresult      => nNumber
                             ,smsg         => sVarchar);
  end if;

  /* Заполнение переменных для заголовка распоряжения плана закупок */
  sVarchar := get_options_str(scode => 'BuyingPlanDirects_Catalog', ncomp_vers => rV_Row.ncompany);
  find_acatalog_name(nflag_smart => 0
                    ,ncompany    => rV_Row.ncompany
                    ,nversion    => null
                    ,sunitcode   => 'BuyingPlanDirects'
                    ,sname       => sVarchar
                    ,nrn         => rV_BuyPlanDir.ncrn);
  rV_BuyPlanDir.sdoc_type := get_options_str(scode => 'BuyingPlanDirects_DocType', ncomp_vers => rV_Row.ncompany);
  rV_BuyPlanDir.sdoc_pref := get_options_str(scode => 'BuyingPlanDirects_DocPref', ncomp_vers => rV_Row.ncompany);
  p_buyplandir_getnextnumb(ncompany  => rV_Row.ncompany
                          ,sdoc_type => rV_BuyPlanDir.sdoc_type
                          ,sdoc_pref => rV_BuyPlanDir.sdoc_pref
                          ,sdoc_numb => rV_BuyPlanDir.sdoc_numb);

  /* Добавление заголовка распоряжения плана закупок */
  p_buyplandir_insert(ncompany   => rV_Row.ncompany
                     ,ncrn       => rV_BuyPlanDir.ncrn
                     ,sjur_pers  => rV_Row.sjur_pers
                     ,sdoc_type  => rV_BuyPlanDir.sdoc_type
                     ,sdoc_pref  => rV_BuyPlanDir.sdoc_pref
                     ,sdoc_numb  => rV_BuyPlanDir.sdoc_numb
                     ,ddoc_date  => current_date
                     ,splan_type => sBP_TYPE
                     ,splan_pref => sBP_PREF
                     ,splan_numb => sBP_NUMB
                     ,sbase      => null
                     ,nrn        => rV_BuyPlanDir.nrn);

  /* Считывание заголовка распоряжения плана закупок */
  if rV_BuyPlanDir.nrn is not null then
    select * into rV_BuyPlanDir from v_buyplandir where nrn = to_number(rV_BuyPlanDir.nrn);
  else
    p_exception(0, 'Не сформировано распоряжение об изменении плана закупок для заказа подразделения.%s'
               ,cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrdersSpecs', ndocument => rV_Row.nrn));
  end if;

  /* Формирование спецификаций распоряжения плана закупок */
  udo_pkg_umts_05_replan.p_buyplandir_crt(ncompany => rV_Row.ncompany, nrn => rV_BuyPlanDir.nrn, ndepartmentord => rV_Row.nrn);

  /* Удаление из распоряжения плана закупок чужих спецификаций */
  for c in ( select distinct s.rn, s.company
               from buyplandirsp     s
                   ,buyplandirspref  t
              where s.prn        = rV_BuyPlanDir.nrn
                and t.prn        = s.rn
                and t.deptordsp  not in (select column_value from table(cast(aRNList as udo_tp_numtable))) )
  loop
    p_buyplandirsp_base_delete(nrn => c.rn, ncompany => c.company);
  end loop;

  /* Отработка распоряжения плана закупок */
  udo_pkg_umts_05_replan.p_buyplandir_confirm(ncompany => rV_Row.ncompany, nrn => rV_BuyPlanDir.nrn);

  /* Создавать заказ поставщику */
  if nvl(nDLO_CREATE, 0) = 1 then

    /* Считывание плана закупок */
    select * into rV_BuyPlane from v_buyplane where nrn = rV_BuyPlanDir.nplan;

    /* Добавление исполнений спецификаций плана закупок в selectlist */
    for c in ( select bpsp.rn as bpsp_rn, bps.rn as bps_rn
                 from buyplanespref    bpsp
                     ,buyplanesp       bps
                     ,departmentords   dpos
                where bps.prn        = rV_BuyPlane.nrn
                  and bpsp.prn       = bps.rn
                  and bpsp.deptordsp = dpos.rn
                  and dpos.rn        in (select column_value from table(cast(aRNList as udo_tp_numtable)))
                  )
    loop
      p_selectlist_insert(nident    => usr_pkg_pub_const.nident
                         ,ndocument => c.bpsp_rn
                         ,sunitcode => 'BuyPlaneSpecsReferences'
                         ,nrn       => nNumber);
    end loop;

    /* Заполнение переменных для заказа поставщику */
    sVarchar := get_options_str(scode => 'Realiz_DeliveryOrd_Catalog', ncomp_vers => rV_Row.ncompany);
    find_acatalog_name(nflag_smart => 0
                      ,ncompany    => rV_Row.ncompany
                      ,nversion    => null
                      ,sunitcode   => 'DeliveryOrders'
                      ,sname       => sVarchar
                      ,nrn         => rV_DeliveryOrd.ncrn);
    rV_DeliveryOrd.sord_doctype := get_options_str(scode => 'Realiz_DeliveryOrd_DocType', ncomp_vers => rV_Row.ncompany);
    rV_DeliveryOrd.sacc_agent   := get_options_str(scode => 'Realiz_DeliveryOrd_MOL', ncomp_vers => rV_Row.ncompany);
    rV_DeliveryOrd.ssubdiv      := get_options_str(scode => 'Realiz_DeliveryOrd_SubDiv', ncomp_vers => rV_Row.ncompany);
    /* лицевой счёт */
    find_faceacc_by_numb(ncompany => rV_Row.ncompany, snumber => sFACEACC, nrn => rV_FaceAcc.nrn);
    select * into rV_FaceAcc from v_faceacc where nrn = to_number(rV_FaceAcc.nrn);

    /* Формирование заказа поставщику */
    udo_pkg_umts_02_cntr.p_buyplanesp_crt_deliveryord(ncompany      => rV_BuyPlane.ncompany
                                                     ,sunitcode     => 'BuyPlaneSpecsReferences'
                                                     ,saction       => 'BuyPlaneSpecsReferencesCrtDelOrders'
                                                     ,stable        => 'BUYPLANESPREF'
                                                     ,ncrn          => rV_BuyPlane.ncrn
                                                     ,nident        => usr_pkg_pub_const.nident
                                                     ,sdoc_type     => rV_DeliveryOrd.sord_doctype
                                                     ,sagent        => rV_FaceAcc.sagent
                                                     ,sexecutive    => rV_DeliveryOrd.sacc_agent
                                                     ,ssubdivision  => rV_DeliveryOrd.ssubdiv
                                                     ,ddate         => trunc(sysdate)
                                                     ,drelease_date => trunc(sysdate)
                                                     ,stax_group    => sTAX_GR
                                                     ,nsigntax      => 1
                                                     ,sigk          => null
                                                     ,sobs          => null
                                                     ,saccept       => null
                                                     ,snote         => null);

    /* Очистка selectlist */
    p_selectlist_clear(nident => usr_pkg_pub_const.nident);

    /* По сформированным заказам поставщику */
    for c in ( select dlo.*
                 from usr_t_inhierbuff t, deliveryord dlo
                where t.ident2      = usr_pkg_pub_const.nident
                  and t.connect_ext = sConnect_Ext
                  and dlo.rn        = t.out_document0 )
    loop
      rDeliveryOrd := c;

      /* Подмена лицевого счёта */
      rDeliveryOrd.faceacc := rV_FaceAcc.nrn;
      usr_pkg_deliveryord.deliveryord_base_update(rrow => rDeliveryOrd);

      /* Утверждение */
      p_deliveryord_set_state(nflag_smart => 0
                             ,ncompany    => rDeliveryOrd.company
                             ,nrn         => rDeliveryOrd.rn
                             ,nflag_mode  => 0
                             ,nnew_state  => 1
                             ,dstate_date => current_date
                             ,nresult     => nNumber);

      /* Создавать входящий счёт */
      if nvl(nPAI_CREATE, 0) = 1 then

        /* Добавление заказа поставщику в selectlist */
        p_selectlist_insert(nident    => rDeliveryOrd.rn
                           ,ndocument => rDeliveryOrd.rn
                           ,sunitcode => 'DeliveryOrders'
                           ,nrn       => nNumber);

        /* Формирование входящего счёта */
        usr_pkg_deliveryord.deliveryord_make_pai(nident    => rDeliveryOrd.rn
                                                ,ncompany  => rV_Row.ncompany
                                                ,scatalog  => get_options_str(scode => 'Realiz_PaymentAccountsIn_Catalog', ncomp_vers => rV_Row.ncompany)
                                                ,ddate     => current_date
                                                ,sstore    => null
                                                ,sext_numb => sPAI_EXT_NUMB);
      end if;
      
    end loop;
    
    /* Сформируем калькуляцию входящих счетов */
     for cur in (
              select T.In_Document1 nrn
                into nDOCUMENT
                from usr_t_inhierbuff T)
              loop
               usr_p_payaccinspclc_cre(nrn => cur.nrn);

              end loop;
    
    

    /* Проверка, что заказ поставщику обработан */
    if rDeliveryOrd.rn is null then
      p_exception(0, 'Не выполнена обработка сформированных заказов поставщикам.%s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'DepartmentsOrdersSpecs', ndocument => rV_Row.nrn));
    end if;







    /* Очистка selectlist */
    p_selectlist_clear(nident => usr_pkg_pub_const.nident);

  end if;

  /* Очистка временных переменных */
  delete from usr_t_inhierbuff where ident2 = usr_pkg_pub_const.nident and connect_ext = sConnect_Ext;
  usr_pkg_pub_const.nident := null;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
