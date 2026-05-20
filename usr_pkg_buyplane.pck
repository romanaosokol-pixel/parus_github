create or replace package USR_PKG_BUYPLANE is
  /*
  Package предназначен для работы с разделом "Планы закупок". 
  BuyPlanes                 BUYPLANE        BP
  BuyPlaneSpecs             BUYPLANESP      BPS
  BuyPlaneSpecsReferences   BUYPLANESPREF   BPSR
  */
  --#########################################################################################################

  function BUYPLANE_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return buyplane%rowtype;
  --#########################################################################################################

  procedure BUYPLANE_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure BUYPLANE_BUPDATE
  /*
  Заголовок. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure BUYPLANE_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure BUYPLANE_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure BUYPLANE_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  function BUYPLANESP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return buyplanesp%rowtype;
  --#########################################################################################################

  procedure BUYPLANESP_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure BUYPLANESP_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure BUYPLANESP_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure BUYPLANESP_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  --#########################################################################################################

  procedure BUYPLANESP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure BUYPLANESP_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW           in buyplanesp%rowtype
  ,nUSE_BUDGEXP   in number default 1
  );
  --#########################################################################################################

  function BUYPLANESPREF_GET
  /*
  Спецификация (ссылки на заказы). Считывание
  */
  (
   nRN      in number
  ) 
  return buyplanespref%rowtype;
  --#########################################################################################################

  procedure BUYPLANESPREF_AINSERT
  /*
  Спецификация (ссылки на заказы). Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure BUYPLANESPREF_BUPDATE
  /*
  Спецификация (ссылки на заказы). Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure BUYPLANESPREF_AUPDATE
  /*
  Спецификация (ссылки на заказы). Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure BUYPLANESPREF_BDELETE
  /*
  Спецификация (ссылки на заказы). Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  --#########################################################################################################

  procedure BUYPLANESPREF_BCRTDELORDERS
  /*
  Спецификация (ссылки на заказы). УМТС. Сформировать заказ поставщику. До
  */
  ;
  --#########################################################################################################

  procedure BUYPLANESPREF_ACRTDELORDERS
  /*
  Спецификация (ссылки на заказы). УМТС. Сформировать заказ поставщику. После
  */
  ;
  --#########################################################################################################

  procedure BUYPLANESPREF_CHECK_BASE
  /*
  Спецификация (ссылки на заказы). Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure BUYPLANESPREF_BASE_UPDATE
  /*
  Спецификация (ссылки на заказы). Исправление базовое
  */
  (
   rROW            in buyplanespref%rowtype
  ,nSIGN_CLIENT    in number default 0  /* Вызов из клиентского действия (0 - нет, 1 - да) */
  );
  --#########################################################################################################
  
  procedure BUYPLANESPREF_SVOD_SL
  /*
  Переопределяем записи в SELECTLIST c отмеченных позиций "Сводной спецификации" на соответствующие ей записи 
  "Ссылки на заказы" 
  */
  (
   nident            in selectlist.ident%type
   ,nCompany          in  buyplane.company%type
  );
 
   procedure BUYPLANESPREF_SVD_DELORD
  /*
  Процедура формирует заказ поставщику по отмеченным строкам сводной ведомости плана закупок
  */

(
  nident        in number
 ,ncompany      in number
 ,ncrn          in number
 ,sdoc_type     in varchar2
 ,sagent        in varchar2
 ,sexecutive    in varchar2
 ,ssubdivision  in varchar2
 ,ddate         in date
 ,drelease_date in date
 ,stax_group    in varchar2
 ,nsigntax      in number
 ,sigk          in varchar2
 ,sobs          in varchar2
 ,saccept       in varchar2
 ,note          in varchar2
);
  
--#########################################################################################################

end USR_PKG_BUYPLANE;
/
create or replace package body USR_PKG_BUYPLANE is

  --#########################################################################################################

  function BUYPLANE_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return buyplane%rowtype
  is
    rRow buyplane%rowtype;
  begin
    begin
      select t.* into rRow from buyplane t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'BUYPLANE');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'BUYPLANE')));
    end;
    return(rRow);
  end BUYPLANE_GET;
  --#########################################################################################################

  procedure BUYPLANE_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow                  buyplane%rowtype;
  begin
    /* Заголовок */
    /*rRow   := BUYPLANE_GET(nRN);*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКИ */
    /* Базовая*/
    buyplane_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rbuyplane := null;*/

  end BUYPLANE_AINSERT;
  --#########################################################################################################

  procedure BUYPLANE_BUPDATE
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
    /*usr_pkg_pub_const.rbuyplane := buyplane_get(nrn => nRN);*/
  end BUYPLANE_BUPDATE;
  --#########################################################################################################

  procedure BUYPLANE_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    buyplane%rowtype;
  begin
    /* Запись */
    /*rRow := buyplane_get(nRN => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая */
    buyplane_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rrowstage := null;*/

  end BUYPLANE_AUPDATE;
  --#########################################################################################################

  procedure BUYPLANE_BDELETE
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
    for c in (select * from buyplanesp where prn = nRN)
    loop
      buyplanesp_bdelete(nrn => c.rn, ncompany => c.company);
    end loop;

  end BUYPLANE_BDELETE;
  --#########################################################################################################

  procedure BUYPLANE_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow              buyplane%rowtype;
  begin
    null;
    /* Заголовок  */
    /*rRow := buyplane_get(nRN => nRN);*/
  
  end BUYPLANE_CHECK_BASE;
  --#########################################################################################################

  function BUYPLANESP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return buyplanesp%rowtype
  is
    rRow buyplanesp%rowtype;
  begin
    begin
      select * into rRow from buyplanesp t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'BUYPLANESP');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'BUYPLANESP')));
    end;
    return(rRow);
  end BUYPLANESP_GET;
  --#########################################################################################################

  procedure BUYPLANESP_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         buyplanesp%rowtype;
  begin
    /* Спецификация */
    /*rRow := buyplanesp_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    buyplanesp_check_base(nrn => nRN, ncompany => nCOMPANY);

  end BUYPLANESP_AINSERT;
  --#########################################################################################################

  procedure BUYPLANESP_BUPDATE
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
    /* usr_pkg_pub_const.rbuyplanesp := buyplanesp_get(nrn => nRN); */
    
  end BUYPLANESP_BUPDATE;
  --#########################################################################################################

  procedure BUYPLANESP_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            buyplanesp%rowtype;
    rGoodsSupply    goodssupply%rowtype;
  begin
    /* Заголовок */
    /* rRow := buyplanesp_get(nrn => nRN); */
    
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    buyplanesp_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rbuyplanesp := null;*/

  end BUYPLANESP_AUPDATE;
  --#########################################################################################################

  procedure BUYPLANESP_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
    rRow            buyplanesp%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow := buyplanesp_get(nrn => nRN);*/
    
  end BUYPLANESP_BDELETE;
  --#########################################################################################################

  procedure BUYPLANESP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            buyplanesp%rowtype;
  begin
    /* Заголовок */
    rRow := buyplanesp_get(nrn => nRN);

    /* ПРОВЕРКИ */

  end BUYPLANESP_CHECK_BASE;
  --#########################################################################################################

  procedure BUYPLANESP_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW           in buyplanesp%rowtype
  ,nUSE_BUDGEXP   in number default 1
  ) 
  is
  begin
    p_buyplanesp_base_update(ncompany       => rROW.COMPANY
                            ,nrn            => rROW.RN
                            ,nnomencls      => rROW.NOMENCLS
                            ,nnomen         => rROW.NOMEN
                            ,nnomnpack      => rROW.NOMNPACK
                            ,nnommodif      => rROW.NOMMODIF
                            ,nnomnmodifpack => rROW.NOMNMODIFPACK
                            ,numeas_main    => rROW.UMEAS_MAIN
                            ,nstore         => rROW.STORE
                            ,nagent         => rROW.AGENT
                            ,dshipment_plan => rROW.SHIPMENT_PLAN
                            ,dshipment_acc  => rROW.SHIPMENT_ACC
                            ,ncost_place    => rROW.COST_PLACE
                            ,nquant_plan    => rROW.QUANT_PLAN
                            ,nquantalt_plan => rROW.QUANTALT_PLAN
                            ,nquant_acc     => rROW.QUANT_ACC
                            ,nquantalt_acc  => rROW.QUANTALT_ACC
                            ,nprice_plan    => rROW.PRICE_PLAN
                            ,nprice_acc     => rROW.PRICE_ACC
                            ,npr_meas       => rROW.PR_MEAS
                            ,nsumm_plan     => rROW.SUMM_PLAN
                            ,nsumm_acc      => rROW.SUMM_ACC
                            ,snote          => rROW.NOTE
                            ,dincl_date     => rROW.INCL_DATE
                            ,nbudgexpend_sp => rROW.BUDGEXPEND_SP
                            ,nuse_budgexp   => nUSE_BUDGEXP);
  end BUYPLANESP_BASE_UPDATE;
  --#########################################################################################################

  function BUYPLANESPREF_GET
  /*
  Спецификация (ссылки на заказы). Считывание
  */
  (
   nRN      in number
  ) 
  return buyplanespref%rowtype
  is
    rRow buyplanespref%rowtype;
  begin
    begin
      select * into rRow from buyplanespref t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'BUYPLANESPREF');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'BUYPLANESPREF')));
    end;
    return(rRow);
  end BUYPLANESPREF_GET;
  --#########################################################################################################

  procedure BUYPLANESPREF_AINSERT
  /*
  Спецификация (ссылки на заказы). Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         buyplanespref%rowtype;
  begin
    /* Спецификация (ссылки на заказы) */
    /*rRow := buyplanespref_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    buyplanespref_check_base(nrn => nRN, ncompany => nCOMPANY);

  end BUYPLANESPREF_AINSERT;
  --#########################################################################################################

  procedure BUYPLANESPREF_BUPDATE
  /*
  Спецификация (ссылки на заказы). Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* usr_pkg_pub_const.rbuyplanespref := buyplanespref_get(nrn => nRN); */
    
  end BUYPLANESPREF_BUPDATE;
  --#########################################################################################################

  procedure BUYPLANESPREF_AUPDATE
  /*
  Спецификация (ссылки на заказы). Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            buyplanespref%rowtype;
  begin
    /* Заголовок */
    /* rRow := buyplanespref_get(nrn => nRN); */
    
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    buyplanespref_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rbuyplanespref := null;*/

  end BUYPLANESPREF_AUPDATE;
  --#########################################################################################################

  procedure BUYPLANESPREF_BDELETE
  /*
  Спецификация (ссылки на заказы). Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
    rRow            buyplanespref%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow := buyplanespref_get(nrn => nRN);*/
    
  end BUYPLANESPREF_BDELETE;
  --#########################################################################################################

  procedure BUYPLANESPREF_BCRTDELORDERS
  /*
  Спецификация (ссылки на заказы). УМТС. Сформировать заказ поставщику. До
  */
  is
    nRN             pkg_std.tnumber; 
    rRow            buyplanespref%rowtype;
    sVarchar        pkg_std.tstring; 
  begin
    /* RN текущего документа */
    usr_pkg_process.get_current_doc_params(ndocument => nRN, sunitcode => sVarchar);
    /* Заголовок */
    /* rRow := buyplanespref_get(nrn => nRN); */

    /* Сохранение идента в константу */
    usr_pkg_pub_const.nIdentBefore := nRN;

  end BUYPLANESPREF_BCRTDELORDERS;
  --#########################################################################################################

  procedure BUYPLANESPREF_ACRTDELORDERS
  /*
  Спецификация (ссылки на заказы). УМТС. Сформировать заказ поставщику. После
  */
  is
    nRN             pkg_std.tref; 
    rRow            buyplanespref%rowtype;
    rDepartmentOrdS departmentords%rowtype;
    rDepartmentOrd  departmentord%rowtype;
    rDeliveryOrd    deliveryord%rowtype;
    sConnect_Ext    pkg_std.tstring := pkg_session.get_connect_ext; 

    sVarchar        pkg_std.tstring; 
  begin
    /* RN текущего документа */
    usr_pkg_process.get_current_doc_params(ndocument => nRN, sunitcode => sVarchar);
    /* Считывание текущего документа */
    rRow := buyplanespref_get(nrn => nRN); 
    /* Заказ подразделения */
    rDepartmentOrdS := usr_pkg_departmentord.departmentords_get(nrn => rRow.deptordsp);
    rDepartmentOrd  := usr_pkg_departmentord.departmentord_get(nrn => rDepartmentOrdS.prn);

    /* ИСПРАВЛЕНИЯ */
    /* По сформированным заказам поставщику */
    for c in (select t.*
                from usr_t_inhierbuff tp, deliveryord t
               where tp.identbefore = usr_pkg_pub_const.nIdentBefore
                 and tp.connect_ext = sConnect_Ext
                 and t.rn           = tp.out_document0) 
    loop
      rDeliveryOrd := c;

      /* Если каталог Метрология, IT  */
      if rDeliveryOrd.crn in (88804043, 20958771) then

        /* Добавление к примечанию примечание заказа подразделения */
        rDeliveryOrd.note := strcombine(rDeliveryOrd.note, rDepartmentOrd.note, cr);
        if rDeliveryOrd.note is not null then
          usr_pkg_deliveryord.deliveryord_base_update(rrow => rDeliveryOrd);
        end if;

      end if;

    end loop;

    /* ПРОВЕРКИ */
    /* Базовая */
    buyplanespref_check_base(nrn => rRow.rn, ncompany => rRow.company);

    /* Очистка констант */
    delete from usr_t_inhierbuff where identbefore = usr_pkg_pub_const.nIdentBefore and connect_ext = sConnect_Ext;
    usr_pkg_pub_const.nIdentBefore := null;

  end BUYPLANESPREF_ACRTDELORDERS;
  --#########################################################################################################

  procedure BUYPLANESPREF_CHECK_BASE
  /*
  Спецификация (ссылки на заказы). Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            buyplanespref%rowtype;
  begin
    /* Заголовок */
    rRow := buyplanespref_get(nrn => nRN);

    /* ПРОВЕРКИ */

  end BUYPLANESPREF_CHECK_BASE;
  --#########################################################################################################

  procedure BUYPLANESPREF_BASE_UPDATE
  /*
  Спецификация (ссылки на заказы). Исправление базовое
  */
  (
   rROW            in buyplanespref%rowtype
  ,nSIGN_CLIENT    in number default 0  /* Вызов из клиентского действия (0 - нет, 1 - да) */
  ) 
  is
  begin
    p_buyplanespref_base_update(nrn            => rROW.RN
                               ,ncompany       => rROW.COMPANY
                               ,nquant_plan    => rROW.QUANT_PLAN
                               ,nquantalt_plan => rROW.QUANTALT_PLAN
                               ,nsign_excl     => rROW.SIGN_EXCL
                               ,nhist          => rROW.HIST
                               ,nsign_client   => nSIGN_CLIENT);
  end BUYPLANESPREF_BASE_UPDATE;
  --#########################################################################################################
  procedure BUYPLANESPREF_SVOD_SL
  /*
    Переопределяем записи в SELECTLIST c отмеченных позиций "Сводной спецификации" на соответствующие ей записи 
    "Ссылки на заказы" 
    */
  (
    nident   in selectlist.ident%type
   ,ncompany in buyplane.company%type
  ) is
  
    v_nrn selectlist.rn%type;
  
  begin
  
    -- 1. Запишем новые значения в Selectlist по строкам раздела "Ссылки на заказы"
  
    for cur in (select spf.rn
                  from selectlist sl
                  join usr_tab_buyplanespref_svod t
                    on sl.document = t.rn
                  join buyplanesp sp
                    on sp.prn = t.prn
                  join buyplanespref spf
                    on spf.prn = sp.rn
                 where sl.ident = nident
                   and sl.authid = utilizer
                   and sl.company = ncompany
                   and sl.unitcode = 'BuyPlanesSpecsSvod'
                   and t.nmodif = sp.nommodif
                   and nvl(udo_f_buyplanespref_shifr(spf.rn), '#') = nvl(t.tema, '#')
                   and nvl(udo_f_buyplanespref_obs(spf.rn), '#') = nvl(t.obs, '#'))
    loop
    
      p_selectlist_insert(nident    => nident
                         ,ndocument => cur.rn
                         ,sunitcode => 'BuyPlaneSpecsReferences'
                         ,nrn       => v_nrn);
    
    end loop;
  
    -- 2. Очищаем Selectlist от записей сводной спецификации плана
  
    delete selectlist sl
     where sl.ident = nident
       and sl.unitcode = 'BuyPlanesSpecsSvod';
  
  end;
  
  --#########################################################################################################
  
  procedure BUYPLANESPREF_SVD_DELORD
  /*
  Процедура формирует заказ поставщику по отмеченным строкам сводной ведомости плана закупок
  */

(
  nident        in number
 ,ncompany      in number
 ,ncrn          in number
 ,sdoc_type     in varchar2
 ,sagent        in varchar2
 ,sexecutive    in varchar2
 ,ssubdivision  in varchar2
 ,ddate         in date
 ,drelease_date in date
 ,stax_group    in varchar2
 ,nsigntax      in number
 ,sigk          in varchar2
 ,sobs          in varchar2
 ,saccept       in varchar2
 ,note          in varchar2
) is

begin
  /* Переопределим Selectlist */
  BUYPLANESPREF_SVOD_SL(nident, nCompany);

  /*Процедура выполняет формирование заказа поставщику по отмеченным строкам раздела "Ссылки на заказы" */
  udo_pkg_umts_02_cntr.p_buyplanesp_crt_deliveryord(ncompany      => ncompany /*Регистрационный номер организации*/
                                                   ,sunitcode     => 'BuyPlaneSpecsReferences' /*Код раздела*/
                                                   ,saction       => 'BuyPlaneSpecsReferencesCrtDelOrders' /*Действие*/
                                                   ,stable        => 'BUYPLANESPREF' /*Таблица*/
                                                   ,ncrn          => 20814178/*ncrn*/ /*Каталог*/
                                                   ,nident        => nident /*Идентификатор помеченных записей*/
                                                   ,sdoc_type     => sdoc_type /*Тип*/
                                                   ,sagent        => sagent /*Контрагент*/
                                                   ,sexecutive    => sexecutive /*Ответственный*/
                                                   ,ssubdivision  => ssubdivision /*Подразделение*/
                                                   ,ddate         => ddate /*Дата*/
                                                   ,drelease_date => drelease_date /*Дата поставки*/
                                                   ,stax_group    => stax_group /*Налоговая группа*/
                                                   ,nsigntax      => nsigntax /*Цены включают налоги*/
                                                   ,sigk          => sigk /*ИГК*/
                                                   ,sobs          => sobs /*ОБС*/
                                                   ,saccept       => saccept /*Приемка*/
                                                   ,snote         => note /*Примечание*/);
  


end;
  
--#########################################################################################################
end USR_PKG_BUYPLANE;
/
