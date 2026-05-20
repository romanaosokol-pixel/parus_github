create or replace package USR_PKG_BUYPLANDIR is
  /*
  Package предназначен для работы с разделом "Распоряжения об изменении плана закупок". 
  BuyingPlanDirects                 BUYPLANDIR        BPD     Распоряжения об изменении плана закупок
  BuyingPlanDirectsSpecs            BUYPLANDIRSP      BPDS    Распоряжения об изменении плана закупок (изменения строк плана)
  BuyingPlanDirectsSpecsReferences  BUYPLANDIRSPREF   BPDSP   Распоряжения об изменении плана закупок (изменения строк плана, ссылки на заказы)
  */
  /* ######################################################################################################### */

  function BUYPLANDIR_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return BUYPLANDIR%rowtype;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIR_BUPDATE
  /*
  Заголовок. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIR_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIR_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIR_BCRT
  /*
  Заголовок. УМТС. Сформировать. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIR_ACRT
  /*
  Заголовок. УМТС. Сформировать. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIR_BRMV
  /*
  Заголовок. УМТС. Расформировать. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIR_ARMV
  /*
  Заголовок. УМТС. Расформировать. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIR_BCONFIRM
  /*
  Заголовок. УМТС. Утвердить. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIR_ACONFIRM
  /*
  Заголовок. УМТС. Утвердить. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIR_BCANCEL
  /*
  Заголовок. УМТС. Снять утверждение. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIR_ACANCEL
  /*
  Заголовок. УМТС. Снять утверждение. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) ;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  function BUYPLANDIRSP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return BUYPLANDIRSP%rowtype;
  /* ######################################################################################################### */

  procedure BUYPLANDIRSP_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIRSP_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIRSP_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIRSP_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIRSP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  function BUYPLANDIRSPREF_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return BUYPLANDIRSPREF%rowtype;
  /* ######################################################################################################### */

  procedure BUYPLANDIRSPREF_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIRSPREF_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIRSPREF_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIRSPREF_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  /* ######################################################################################################### */

  procedure BUYPLANDIRSPREF_CHECK_BASE
  /*
  Калькуляция. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  /* ######################################################################################################### */

end USR_PKG_BUYPLANDIR;
/
create or replace package body USR_PKG_BUYPLANDIR is

  /* ######################################################################################################### */

  function BUYPLANDIR_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return buyplandir%rowtype
  is
    rRow buyplandir%rowtype;
  begin
    begin
      select t.* into rRow from buyplandir t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'BUYPLANDIR');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'BUYPLANDIR')));
    end;
    return(rRow);
  end BUYPLANDIR_GET;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow                  buyplandir%rowtype;
  begin
    /* Заголовок */
    /*rRow   := BUYPLANDIR_GET(nRN);*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКИ */
    /* Базовая*/
    buyplandir_check_base(nrn => nRN, ncompany => nCOMPANY);

  end BUYPLANDIR_AINSERT;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_BUPDATE
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
    /*usr_pkg_pub_const.rBUYPLANDIR := BUYPLANDIR_get(nrn => nRN);*/
  end BUYPLANDIR_BUPDATE;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    BUYPLANDIR%rowtype;
  begin
    /* Запись проекта */
    /*rRow := BUYPLANDIR_get(nRN => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая */
    buyplandir_check_base(nrn => nRN, ncompany => nCOMPANY);

  end BUYPLANDIR_AUPDATE;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_BDELETE
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

  end BUYPLANDIR_BDELETE;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_BCRT
  /*
  Заголовок. УМТС. Сформировать. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* Считывание */
    /*usr_pkg_pub_const.rBUYPLANDIR := BUYPLANDIR_get(nrn => nRN);*/
  end BUYPLANDIR_BCRT;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_ACRT
  /*
  Заголовок. УМТС. Сформировать. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end BUYPLANDIR_ACRT;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_BRMV
  /*
  Заголовок. УМТС. Расформировать. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* Считывание */
    /*usr_pkg_pub_const.rBUYPLANDIR := BUYPLANDIR_get(nrn => nRN);*/
  end BUYPLANDIR_BRMV;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_ARMV
  /*
  Заголовок. УМТС. Расформировать. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end BUYPLANDIR_ARMV;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_BCONFIRM
  /*
  Заголовок. УМТС. Утвердить. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
    /* Считывание */
    /*usr_pkg_pub_const.rBUYPLANDIR := BUYPLANDIR_get(nrn => nRN);*/
  end BUYPLANDIR_BCONFIRM;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_ACONFIRM
  /*
  Заголовок. УМТС. Утвердить. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end BUYPLANDIR_ACONFIRM;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_BCANCEL
  /*
  Заголовок. УМТС. Снять утверждение. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    --rRow    buyplandir%rowtype;
    sTMP       pkg_std.tstring; 
    nORD_QUANT number(17, 3);
    nOLD_QUANT number(17, 3);
  begin
    /* Заголовок */
    --rRow  := buyplandir_get(nrn => nRN);
    /* */
    for dirsp in(select spr.rn as rn_ref,
                        dspr.quantplan_bef, 
                        dspr.quantplan_aft
                   from buyplandirsp    dsp, 
                        buyplandirspref dspr, 
                        buyplanespref   spr
                  where dsp.prn = nRN
                    and dspr.prn = dsp.rn 
                    and spr.prn = dsp.plansp 
                    and spr.deptordsp = dspr.deptordsp) loop
      --
      nORD_QUANT := 0;
      nOLD_QUANT := dirsp.quantplan_bef;
      for dlv in(select doc.quant_plan,
                        f_docdescrs_get_description(sunitcode => 'DeliveryOrders', ndocument => ords.prn) as sdoc
                   from udo_uzd_03_buyplanesp_cntr_doc doc,
                        deliveryords                   ords
                  where doc.rn_ref = dirsp.rn_ref
                    and doc.doc_rn = ords.rn 
                    and doc.doc_quant_plan > 0) loop
        sTMP := substr( strcombine( sTMP, dlv.sdoc, cr), 0, 4000 );
        nORD_QUANT := nORD_QUANT + dlv.quant_plan;
      end loop;
      --
      if nORD_QUANT > dirsp.quantplan_bef then
      p_exception(0, 'В распоряжении присутствуют спецификации, которые уже вошли в заказы поставщикам: %s.%s'||chr(10)||
                     'Количество ДО = %s; Количество в заказах поставщиков = %s'
                 ,cr||sTMP
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'BuyingPlanDirects', ndocument => nRN /*rRow.rn*/),
                 nOLD_QUANT, nORD_QUANT); 
      end if;
    end loop;
    
    /* Проверка вхождения спецификаций в заказы поставщикам */
    /*for c in (select listagg(trim(sdoc), cr) within group (order by sdoc) as sdoc
                from (select distinct f_docdescrs_get_description(sunitcode => 'DeliveryOrders', ndocument => dlos.prn) as sdoc
                        from buyplandirsp                   bpds
                            ,buyplandirspref                bpdsp
                            ,buyplanespref                  bpsp
                            ,udo_uzd_03_buyplanesp_cntr_doc t
                            ,deliveryords                   dlos
                       where bpds.prn        = nRN --rRow.rn
                         and bpds.rn         = bpdsp.prn
                         and bpsp.deptordsp  = bpdsp.deptordsp
                         and t.prn           = bpsp.prn 
                         and dlos.rn         = t.doc_rn
                         and bpsp.quant_plan > 0) 
             )
    loop
      if trim(c.sdoc) is not null \*and utilizer != 'KHOK'*\ then
      p_exception(0, 'В распоряжении присутствуют спецификации, которые уже вошли в заказы поставщикам: %s.%s'
                 ,cr||c.sdoc
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'BuyingPlanDirects', ndocument => nRN \*rRow.rn*\)); 
      end if;
    end loop;*/    

  end BUYPLANDIR_BCANCEL;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_ACANCEL
  /*
  Заголовок. УМТС. Снять утверждение. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end BUYPLANDIR_ACANCEL;
  /* ######################################################################################################### */

  procedure BUYPLANDIR_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow              BUYPLANDIR%rowtype;
    nProjectStageExists     pkg_std.tnumber := 0; 
  begin
    null;
    /* Заголовок  */
    /*rRow := BUYPLANDIR_get(nRN => nRN);*/
  end BUYPLANDIR_CHECK_BASE;
  /* ######################################################################################################### */

  function BUYPLANDIRSP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return buyplandirsp%rowtype
  is
    rRow buyplandirsp%rowtype;
  begin
    begin
      select * into rRow from buyplandirsp where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'BUYPLANDIRSP');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'BUYPLANDIRSP')));
    end;
    return(rRow);
  end BUYPLANDIRSP_GET;
  /* ######################################################################################################### */

  procedure BUYPLANDIRSP_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         BUYPLANDIRSP%rowtype;
  begin
    /* Спецификация */
    /*rRow := BUYPLANDIRSP_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    buyplandirsp_check_base(nrn => nRN, ncompany => nCOMPANY);

  end BUYPLANDIRSP_AINSERT;
  /* ######################################################################################################### */

  procedure BUYPLANDIRSP_BUPDATE
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
  end BUYPLANDIRSP_BUPDATE;
  /* ######################################################################################################### */

  procedure BUYPLANDIRSP_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            BUYPLANDIRSP%rowtype;
  begin
    /* Заголовок */
    rRow := buyplandirsp_get(nrn => nRN);
    
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    buyplandirsp_check_base(nrn => nRN, ncompany => nCOMPANY);

  end BUYPLANDIRSP_AUPDATE;
  /* ######################################################################################################### */

  procedure BUYPLANDIRSP_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
    rRow            BUYPLANDIRSP%rowtype;
  begin
    null;
  end BUYPLANDIRSP_BDELETE;
  /* ######################################################################################################### */

  procedure BUYPLANDIRSP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         BUYPLANDIRSP%rowtype;
  begin
    null;
  end BUYPLANDIRSP_CHECK_BASE;
  /* ######################################################################################################### */

  function BUYPLANDIRSPREF_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return buyplandirspref%rowtype
  is
    rRow buyplandirspref%rowtype;
  begin
    begin
      select * into rRow from buyplandirspref t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'BUYPLANDIRSPREF');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'BUYPLANDIRSPREF')));
    end;
    return(rRow);
  end BUYPLANDIRSPREF_GET;
  /* ######################################################################################################### */

  procedure BUYPLANDIRSPREF_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         buyplandirspref%rowtype;
  begin
    /* Спецификация */
    /*rRow := BUYPLANDIRSPREF_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    buyplandirspref_check_base(nrn => nRN, ncompany => nCOMPANY);

  end BUYPLANDIRSPREF_AINSERT;
  /* ######################################################################################################### */

  procedure BUYPLANDIRSPREF_BUPDATE
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
  end BUYPLANDIRSPREF_BUPDATE;
  /* ######################################################################################################### */

  procedure BUYPLANDIRSPREF_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            buyplandirspref%rowtype;
  begin
    /* Заголовок */
    rRow := buyplandirspref_get(nrn => nRN);
    
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    buyplandirspref_check_base(nrn => nRN, ncompany => nCOMPANY);

  end BUYPLANDIRSPREF_AUPDATE;
  /* ######################################################################################################### */

  procedure BUYPLANDIRSPREF_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
    rRow            BUYPLANDIRSPREF%rowtype;
  begin
    null;
  end BUYPLANDIRSPREF_BDELETE;
  /* ######################################################################################################### */

  procedure BUYPLANDIRSPREF_CHECK_BASE
  /*
  Калькуляция. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         BUYPLANDIRSPREF%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow    := BUYPLANDIRSPREF_get(nrn => nRN);

    /* ПРОВЕРКИ */

  end BUYPLANDIRSPREF_CHECK_BASE;
  /* ######################################################################################################### */
  
end USR_PKG_BUYPLANDIR;
/
