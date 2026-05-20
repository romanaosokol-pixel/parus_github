create or replace package USR_PKG_RINVTOSUP IS
  /*
  Package предназначен для работы с разделом "Расходные накладные на возврат поставщикам". Степанов М. 12/02/2022
  ReturnInvoicesToSuppliers       RINVTOSUP         RITS    
  ReturnInvoicesToSuppliersSpecs  RINVTOSUPSPECS    RITSS
  ReturnInvoicesToSuppliersCalcs  RINVTOSUPCLC      RITSSC
  */
  /* ######################################################################################################### */

  function RINVTOSUP_GET
  /*
  Заголовок. Считывание
  */
  (
   NRN       in number
  ) 
  return RINVTOSUP%ROWTYPE;
  /* ######################################################################################################### */

  procedure RINVTOSUP_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUP_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUP_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUP_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUP_BPROCESS
  /*
  Заголовок. Проверка перед отработкой
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUP_APROCESS
  /*
  Заголовок. Проверка после отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUP_BCANCEL
  /*
  Заголовок. Проверка перед отменой отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUP_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUP_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rV_ROW         in v_rinvtosup%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /*#########################################################################################################*/

  procedure RINVTOSUP_MAKE_IIV
  /*
  Заголовок. Сформировать приходную накладную
  */
  (
   nRN              in number
  ,sCATALOG         in varchar2
  ,sDOC_TYPE        in varchar2
  ,sDOC_PREF        in varchar2
  ,sSTORE_OPER      in varchar2
  ,aRNLIST          out udo_tp_numtable
  );
  /* ######################################################################################################### */

  procedure RINVTOSUP_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW           in rinvtosup%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /* ######################################################################################################### */

  procedure RINVTOSUP_UPDATE_SIGNTAX
  /*
  Заголовок. Исправление признака "Цены включают налоги"
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number
  ,nSIGNTAX     in number /*0 - не включают, 1 - включают */
  );
  /*#########################################################################################################*/

  procedure RINVTOSUP_RECREATE_IIVSC
  /*
  Заголовок. Пересоздать калькуляции
  */
  (
   nRN      in number
  );
  /* ######################################################################################################### */

  /*** процедура пересчета исполнения у родительских документов **
  по мотивам P_RINVTOSUP_BSET_STATUS  */
  procedure RINVTOSUP_RECALC_PERFORMANCE
  (
    nCOMPANY    in number,
    dWORK_DATE  in date,
    nR_RN       in number, -- RN возвратной накладной
    nR_OSTATUS  in number, -- старое состояние (0 - не отработан; 1 - план; 2 - факт)
    nR_NSTATUS  in number  -- новое состояние (0 - не отработан; 1 - план; 2 - факт)
  );
  /* ######################################################################################################### */

  function RINVTOSUPSPECS_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   NRN       in number
  ) 
  return RINVTOSUPSPECS %ROWTYPE;
  /*#########################################################################################################*/
  
  PROCEDURE RINVTOSUPSPECS_GET_BY_PARAMS
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   NFLAGSMART         IN NUMBER DEFAULT 0
  ,NFLAG_OPTION       IN NUMBER DEFAULT 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,NTOO_MANY_ROWS     IN NUMBER DEFAULT 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,NPRN               IN NUMBER
  ,NNOMMODIF          IN NUMBER DEFAULT NULL
  ,NNOMMODIFPACK      IN NUMBER DEFAULT NULL
  ,NTAXGR             IN NUMBER DEFAULT NULL
  ,NQUANT             IN NUMBER DEFAULT NULL
  ,NQUANTALT          IN NUMBER DEFAULT NULL
  ,NPRICE             IN NUMBER DEFAULT NULL
  ,NARTICLE           IN NUMBER DEFAULT NULL
  ,SSERNUMB           IN VARCHAR2 DEFAULT NULL
  ,DBEGINDATE         IN DATE     DEFAULT NULL
  ,DENDDATE           IN DATE     DEFAULT NULL
  ,RROW               OUT RINVTOSUPSPECS%ROWTYPE 
  );
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_INSERT
  /*
  Спецификация. Добавление
  */
  (
   rV_ROW         in v_rinvtosupspecs%rowtype
  ,rV_RINVTOSUP   in v_rinvtosup%rowtype
  ,nDUP_RN        in number          /* Размножение калькуляции */
  ,nRN            in out number      /* если не null, то это размножение */
  ,sMSG           out varchar2
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_UPDATE
  /*
  Спецификация. Исправление
  */
  (
   rV_ROW         in v_rinvtosupspecs%rowtype
  ,rV_RINVTOSUP   in v_rinvtosup%rowtype
  ,sMSG           out varchar2
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW     in rinvtosupspecs%rowtype
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ,nRN      out number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW     in rinvtosupspecs%rowtype
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /* ######################################################################################################### */

  procedure RINVTOSUPCLC_BASE_INSERT
  /*
  Калькуляция. Добавление базовое
  */
  (
   rROW     in rinvtosupclc%rowtype
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ,nRN      out number
  );
  /* ######################################################################################################### */

  procedure RINVTOSUPCLC_BASE_UPDATE
  /*
  Калькуляция. Исправление базовое
  */
  (
   rROW     in rinvtosupclc%rowtype
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  );
  /* ######################################################################################################### */

end USR_PKG_RINVTOSUP;
/
create or replace package body USR_PKG_RINVTOSUP is

  /* ######################################################################################################### */

  function RINVTOSUP_GET
  /*
  Заголовок. Считывание 
  */
  (
   nRN      in number 
  ) 
  return rinvtosup%rowtype
  is
    rRow rinvtosup%rowtype;
  begin
    begin
      select * into rRow from rinvtosup where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(1, 'RINVTOSUP'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>', nRN, f_unitlist_getname(get_unitlist_code_table(1, 'RINVTOSUP')));
    end;
    return(rRow);
  end RINVTOSUP_GET;
  /* ######################################################################################################### */

  procedure RINVTOSUP_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    /*rRow     rinvtosup%rowtype;*/
  begin
    /* Заголовок */
    /*rRow := rinvtosup_get(nRN);*/

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    rinvtosup_check_base(nrn => nRN, ncompany => nCOMPANY);

  end RINVTOSUP_AINSERT;
  /* ######################################################################################################### */

  procedure RINVTOSUP_BUPDATE
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
    /* Считывание */
    /*usr_pkg_pub_const.rrinvtosup := rinvtosup_get(nrn => nRN); */
  end RINVTOSUP_BUPDATE;
  /* ######################################################################################################### */

  procedure RINVTOSUP_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    /* ПРОВЕРКИ */
    /* Базовая */
    rinvtosup_check_base(nrn => nRN, ncompany => nCOMPANY);

  end RINVTOSUP_AUPDATE;
  /* ######################################################################################################### */

  procedure RINVTOSUP_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end RINVTOSUP_BDELETE;
  /* ######################################################################################################### */

  procedure RINVTOSUP_BPROCESS
  /*
  Заголовок. Проверка перед отработкой
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow        rinvtosup%rowtype;
    nQuantRes   pkg_std.tquant; 
    bExists     boolean := false;
  begin
    /* Заголовок */
    rRow := rinvtosup_get(nrn => nRN);

    /* По спецификациям */
    for c in (select * from rinvtosupspecs where prn = rRow.rn)
    loop
      /* Спецификации есть */
      bExists := true;
      /* Исполнение заказа подраздлений (резервы под заказ и выдача в производство) */
      nQuantRes := 0;
      for c1 in ( select t.*
                    from resjournal       rj
                        ,udo_depords_prf  t
                   where rj.supply        = c.goodssupply
                     and rj.res_end_date  is null
                     and t.rsrv           = rj.rn )
      loop   
        /* Вычисление количества для снятия с резерва */
        nQuantRes := c.quant - nQuantRes;
        nQuantRes := least(nQuantRes, c1.quant);
        /* Снятие с резерва */
        udo_p_departmentords_rsrv_free(nrn => c1.rsrv, ncompany => c.company, nquant => nQuantRes);
      end loop;
    end loop;

    /* Спецификаций нет */
    if not bExists then
      p_exception(0, 'В документе отсутствуют спецификации. %s'
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'ReturnInvoicesToSuppliers', ndocument => rRow.rn ) ); 
    end if;                 

  end RINVTOSUP_BPROCESS;
  /* ######################################################################################################### */

  procedure RINVTOSUP_APROCESS
  /*
  Заголовок. Проверка после отработки
 */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow            rinvtosup%rowtype;
    rSupplier       agnlist%rowtype;
    rStore          azsazslistmt%rowtype; 
    nGP_PayAccIn    pkg_std.tref; 
    nGP_AgnList     pkg_std.tref; 
    rGP_PayAccIn    payaccin%rowtype; 
    rPAI_AgnList    agnlist%rowtype; 
    rGP_AgnList     agnlist%rowtype; 
    
    nNumber         pkg_std.tnumber; 
    sVarchar        pkg_std.tstring; 
    cClob           clob;
  begin
    /* Заголовок */
    rRow := rinvtosup_get(nrn => nRN);
    /* Склад */
    rStore := udo_pkg_get.row_store(nrn => rRow.store, nsmart => 0);
    /* Поставщик */
    rSupplier := usr_pkg_agnlist.agnlist_get(nrn => rRow.supplier);

    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    rinvtosup_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Дата отработки равна дате документа */
    if cmp_dat(rRow.work_date, rRow.docdate) != 1 then
      p_exception(0, 'Дата отработки <%s> не равна дате документа <%s>. %s'
                 ,d2s(rRow.work_date)
                 ,d2s(rRow.docdate)
                 ,cr||f_docdescrs_get_description(sunitcode => 'ReturnInvoicesToSuppliers', ndocument => rRow.rn)); 
    end if;

    /* Уведомление в ОМТС */
    /* По спецификациям */
    for c in (select dnm.nomen_code
                    ,dnm.nomen_name
                    ,nm.modif_code
                    ,nm.modif_name
                    ,icd.code
                    ,gp.sernumb
                    ,t.quant
                    ,t.summtax
                    ,icd.entry_date
                    ,gp.rn as gp_rn
                    ,rownum
                from rinvtosupspecs t
                    ,dicnomns       dnm
                    ,nommodif       nm
                    ,goodssupply    gs
                    ,goodsparties   gp
                    ,incomdoc       icd
               where t.prn   = rRow.rn
                 and nm.rn   = t.nommodif
                 and dnm.rn  = nm.prn
                 and gs.rn   = t.goodssupply
                 and gp.rn   = gs.prn
                 and icd.rn  = gp.indoc)
    loop
      /* Если первая запись */
      if c.rownum = 1 then
        /* Считывание данных приходных документов приходной партии товара */
        usr_pkg_goodsparties.goodsparties_get_indocs_data(ssernumb        => c.sernumb
                                                         ,nflagsmart      => 1
                                                         ,ntoo_many_rows  => 1
                                                         ,ngp             => nNumber
                                                         ,nio             => nNumber
                                                         ,nios            => nNumber
                                                         ,niiv            => nNumber
                                                         ,niivs           => nNumber
                                                         ,npai            => nGP_PayAccIn
                                                         ,npais           => nNumber
                                                         ,nce             => nNumber
                                                         ,nal             => nGP_AgnList);
      end if;
      /* Формирование текста спецификации */
      cClob := strcombine(cClob, cr|| c.nomen_name ||', '|| c.modif_name );
      cClob := strcombine(cClob, c.sernumb, ', Серия: ');
      cClob := strcombine(cClob, to_char(c.entry_date, 'dd.mm.yyyy'), ', Поступление: ');
    end loop;
    /* Считывание входящего счёта и контрагента его поставщика */
    if nGP_PayAccIn is not null then
      rGP_PayAccIn := usr_pkg_payaccin.payaccin_get(nrn => nGP_PayAccIn);
      rPAI_AgnList := usr_pkg_agnlist.agnlist_get(nrn => rGP_PayAccIn.supplier);
    end if;
    /* Считывание контрагента инициатора вх.счёта */
    if nGP_AgnList is not null then
      rGP_AgnList  := usr_pkg_agnlist.agnlist_get(nrn => nGP_AgnList);
    end if;
    /* Отправка уведомления в ОМТС */
    usr_pkg_maillst.maillst_insert_exs_ext_send(ncompany     => rRow.company
                                               ,sdescription => 'Отработан документ на склад "Поставщики_Брак". ' ||pkg_document.make_number(ndoc_type => null, sdoc_pref => rRow.pref, sdoc_numb => rRow.numb, ddoc_date => rRow.docdate)
                                               ,sto_list     => 'snab@module.ru'
                                               ,stitle       => 'Отработан документ на склад "Поставщики_Брак" в разделе: "'||f_unitlist_getname(sunitcode => 'ReturnInvoicesToSuppliers')||'"'
                                               ,ctext        => pkg_document.make_number(ndoc_type => null, sdoc_pref => rRow.pref, sdoc_numb => rRow.numb, ddoc_date => rRow.docdate)
                                                                ||cr||'Поставщик: '|| rPAI_AgnList.agnabbr
                                                                ||cr||'Инициатор вх.счёта: ' || rGP_AgnList.agnabbr
                                                                ||cr||cClob /* спецификации */
                                               ,nrn          => nNumber);

    /* По спецификациям */
    for c in (select * from rinvtosupspecs where prn = rRow.rn)
    loop
      /* проверка */
      rinvtosupspecs_check_base(nrn => c.rn, ncompany => c.company);
    end loop;

  end RINVTOSUP_APROCESS;
  /* ######################################################################################################### */

  procedure RINVTOSUP_BCANCEL
  /*
  Заголовок. Проверка перед отменой отработки
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
  begin
    null;
  end RINVTOSUP_BCANCEL;
  /* ######################################################################################################### */

  procedure RINVTOSUP_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow      rinvtosup%rowtype;
  begin
    /* Заголовок */
    rRow := rinvtosup_get(nrn => nRN);
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Параметр "Цены включают налоги" */  
    if rRow.signtax = 0 then
      p_exception(0, 'Параметр "Цены включают налоги" должен быть заполнен. %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'ReturnInvoicesToSuppliers', ndocument => rRow.rn)); 
    end if;

  end RINVTOSUP_CHECK_BASE;
  /* ######################################################################################################### */

  procedure RINVTOSUP_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rV_ROW         in v_rinvtosup%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
    rV_RInvToSup   v_rinvtosup%rowtype;
    aRN_Unit_List    usr_pkg_pub_const.tRN_Unit_List;
    rRInvToSupSpecs   rinvtosupspecs%rowtype;
    nParty            pkg_std.tref; 

    nNumber         pkg_std.tnumber;
    sVarchar        pkg_std.tstring;
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_rinvtosup_update(nrn                => rV_ROW.NRN
                        ,ncompany           => rV_ROW.NCOMPANY
                        ,sjur_pers          => rV_ROW.SJUR_PERS
                        ,sdoctype           => rV_ROW.SDOCTYPE
                        ,spref              => rV_ROW.SPREF
                        ,snumb              => rV_ROW.SNUMB
                        ,ddocdate           => rV_ROW.DDOCDATE
                        ,nstatus            => rV_ROW.NSTATUS
                        ,nservact_sign      => rV_ROW.NSERVACT_SIGN
                        ,dwork_date         => rV_ROW.DWORK_DATE
                        ,svalid_doctype     => rV_ROW.SVALID_DOCTYPE
                        ,svalid_numb        => rV_ROW.SVALID_NUMB
                        ,dvalid_docdate     => rV_ROW.DVALID_DOCDATE
                        ,ssupplier          => rV_ROW.SSUPPLIER
                        ,sfaceacc           => rV_ROW.SFACEACC
                        ,sgraphpoint        => rV_ROW.SGRAPHPOINT
                        ,sstore             => rV_ROW.SSTORE
                        ,sstoreoper         => rV_ROW.SSTOREOPER
                        ,smol               => rV_ROW.SMOL
                        ,sagnfifo           => rV_ROW.SAGNFIFO
                        ,sparty             => rV_ROW.SPARTY
                        ,scurrency          => rV_ROW.SCURRENCY
                        ,srecip_doctype     => rV_ROW.SRECIP_DOCTYPE
                        ,srecip_numb        => rV_ROW.SRECIP_NUMB
                        ,drecip_docdate     => rV_ROW.DRECIP_DOCDATE
                        ,sreceiver          => rV_ROW.SRECEIVER
                        ,ncurr_rate         => rV_ROW.NCURR_RATE
                        ,ncurr_rate_base    => rV_ROW.NCURR_RATE_BASE
                        ,ncurr_rate_acc     => rV_ROW.NCURR_RATE_ACC
                        ,ncurr_rate_inv_acc => rV_ROW.NCURR_RATE_INV_ACC
                        ,nsigntax           => rV_ROW.NSIGNTAX
                        ,nsumm              => rV_ROW.NSUMM
                        ,nsummtax           => rV_ROW.NSUMMTAX
                        ,sroute             => rV_ROW.SROUTE
                        ,swaybillnumb       => rV_ROW.SWAYBILLNUMB
                        ,sferryman          => rV_ROW.SFERRYMAN
                        ,sdriver            => rV_ROW.SDRIVER
                        ,scar               => rV_ROW.SCAR
                        ,strailer1          => rV_ROW.STRAILER1
                        ,strailer2          => rV_ROW.STRAILER2
                        ,snote              => rV_ROW.SNOTE
                        ,sbarcode           => rV_ROW.SBARCODE);

      /* По спецификациям */
      for c in ( select * from v_rinvtosupspecs where nprn = rV_ROW.NRN )
      loop
        /* сохранение записи в переменную */
        rRInvToSupSpecs := rinvtosupspecs_get( nrn => c.nrn );
        
        /* считывание записи текущего товарного запаса и приходной партии */
        usr_pkg_goodsparties.goodsparties_get_full( nflagsmart  => 0
                                                   ,ncompany    => c.ncompany
                                                   ,sindoc      => rV_ROW.SPARTY
                                                   ,ssernumb    => c.ssernumb
                                                   ,snomen      => c.snomen
                                                   ,snommodif   => c.snommodif
                                                   ,nrn         => nParty );
        
        /* поиск товарного запаса для текущей приходной партии и нового склада */
        find_goodssupply_by_store( ncompany    => c.ncompany
                                  ,nflag_smart => 0
                                  ,nprn        => nParty
                                  ,sstore      => rV_ROW.SSTORE
                                  ,nrn         => rRInvToSupSpecs.goodssupply );
        /* исправление спецификации */
        rinvtosupspecs_base_update( rrow => rRInvToSupSpecs );
      end loop;

    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      /* Считывание значений в переменную */
      rV_RInvToSup := rV_ROW;

      /* Если документ НЕ не отработан */
      if rV_RInvToSup.nstatus != 0 then

        /* Отключение регистрации */
        if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;
        /* Удаление входных связей */
        usr_pkg_doclinks.doclinks_reset_in( nrn           => rV_RInvToSup.nrn
                                           ,ncompany      => rV_RInvToSup.ncompany
                                           ,arn_unit_list => aRN_Unit_List
                                           ,nmode         => 0 );
        /* Снятие отработки */
        p_rinvtosup_setstatus( ncompany   => rV_RInvToSup.ncompany
                              ,nrn        => rV_RInvToSup.nrn
                              ,nstatus    => 0
                              ,dwork_date => rV_RInvToSup.dwork_date
                              ,nwarning   => nNumber
                              ,smsg       => sVarchar
                              ,nident_msg => nNumber );
        /* Подмена статуса на Не отработан */
        rV_RInvToSup.nstatus := 0;
        /* Включение регистрации */
        if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

        /* Исправление */
        rinvtosup_update(rv_row => rV_RInvToSup, nmode => 0);

        /* Отключение регистрации */
        if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;
        /* Восстановление входных связей */
        usr_pkg_doclinks.doclinks_reset_in( nrn           => rV_RInvToSup.nrn
                                           ,ncompany      => rV_RInvToSup.ncompany
                                           ,arn_unit_list => aRN_Unit_List
                                           ,nmode         => 1 );
        /* Отработка */
        p_rinvtosup_setstatus( ncompany   => rV_RInvToSup.ncompany
                              ,nrn        => rV_RInvToSup.nrn
                              ,nstatus    => 1
                              ,dwork_date => rV_RInvToSup.ddocdate
                              ,nwarning   => nNumber
                              ,smsg       => sVarchar
                              ,nident_msg => nNumber );
        /* Включение регистрации */
        if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;

      /* Если документ не отработан */
      else                               
        /* Исправление */
        rinvtosup_update(rv_row => rV_RInvToSup, nmode => 0);
      end if;

    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end RINVTOSUP_UPDATE;
  /* ######################################################################################################### */

  procedure RINVTOSUP_BASE_UPDATE
  /*
  Заголовок. Исправление базовое
  */
  (
   rROW           in rinvtosup%rowtype
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_rinvtosup_base_update(nrn                => rROW.RN
                             ,ncompany           => rROW.COMPANY
                             ,njur_pers          => rROW.JUR_PERS
                             ,ndoctype           => rROW.DOCTYPE
                             ,spref              => rROW.PREF
                             ,snumb              => rROW.NUMB
                             ,ddocdate           => rROW.DOCDATE
                             ,nstatus            => rROW.STATUS
                             ,nservact_sign      => rROW.SERVACT_SIGN
                             ,dwork_date         => rROW.WORK_DATE
                             ,nvalid_doctype     => rROW.VALID_DOCTYPE
                             ,svalid_numb        => rROW.VALID_NUMB
                             ,dvalid_docdate     => rROW.VALID_DOCDATE
                             ,nsupplier          => rROW.SUPPLIER
                             ,nfaceacc           => rROW.FACEACC
                             ,ngraphpoint        => rROW.GRAPHPOINT
                             ,nstore             => rROW.STORE
                             ,nstoreoper         => rROW.STOREOPER
                             ,nmol               => rROW.MOL
                             ,nagnfifo           => rROW.AGNFIFO
                             ,nparty             => rROW.PARTY
                             ,ncurrency          => rROW.CURRENCY
                             ,nrecip_doctype     => rROW.RECIP_DOCTYPE
                             ,srecip_numb        => rROW.RECIP_NUMB
                             ,drecip_docdate     => rROW.RECIP_DOCDATE
                             ,sreceiver          => rROW.RECEIVER
                             ,ncurr_rate         => rROW.CURR_RATE
                             ,ncurr_rate_base    => rROW.CURR_RATE_BASE
                             ,ncurr_rate_acc     => rROW.CURR_RATE_ACC
                             ,ncurr_rate_inv_acc => rROW.CURR_RATE_INV_ACC
                             ,nsigntax           => rROW.SIGNTAX
                             ,nsumm              => rROW.SUMM
                             ,nsummtax           => rROW.SUMMTAX
                             ,nroute             => rROW.ROUTE
                             ,swaybillnumb       => rROW.WAYBILLNUMB
                             ,nferryman          => rROW.FERRYMAN
                             ,ndriver            => rROW.DRIVER
                             ,ncar               => rROW.CAR
                             ,ntrailer1          => rROW.TRAILER1
                             ,ntrailer2          => rROW.TRAILER2
                             ,snote              => rROW.NOTE
                             ,sbarcode           => rROW.BARCODE);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_exception(0, 'Неиспользуемый режим выполнения <%s>', nMODE); 
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end RINVTOSUP_BASE_UPDATE;
  /*#########################################################################################################*/

  procedure RINVTOSUP_MAKE_IIV
  /*
  Заголовок. Сформировать приходную накладную
  */
  (
   nRN              in number
  ,sCATALOG         in varchar2
  ,sDOC_TYPE        in varchar2
  ,sDOC_PREF        in varchar2
  ,sSTORE_OPER      in varchar2
  ,aRNLIST          out udo_tp_numtable
  )
  is
    rRow              rinvtosup%rowtype;
    nInInvoices       pkg_std.tref; 
    rInInvoices       ininvoices%rowtype;
    rInInvoicesSpecs  ininvoicesspecs%rowtype;
    rInInvoicesSpC    ininvoicesspc%rowtype;
    rGoodsParties     goodsparties%rowtype;
    nPayAccIn         pkg_std.tref; 

    nNumber       pkg_std.tnumber;
  begin
    /* Считывание текущего документа */
    rRow := rinvtosup_get(nrn => nRN);

    /* Проверка отработки текущего документа */
    if rRow.status != 1 then
      p_exception(0, 'Документ не отработан в учёте.%s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'ReturnInvoicesToSuppliers', ndocument => rRow.rn));
    end if;

    /* Поиск Rn входящего счёта по цепочке связей */
    nPayAccIn := f_doclinks_link_in_recurs_doc(nflag_mode    => 1
                                              ,sout_unitcode => 'ReturnInvoicesToSuppliers'
                                              ,nout_document => rRow.rn
                                              ,sin_unitcode  => 'PaymentAccountsIn' );

    /* Формирование приходной накладной из входящего счёта */
    usr_pkg_payaccin.payaccin_make_ininvoices(nrn        => nPayAccIn
                                             ,scatalog   => sCATALOG
                                             ,sdoctype   => sDOC_TYPE
                                             ,ddate      => trunc(sysdate)
                                             ,sext_numb  => null
                                             ,dext_date  => null
                                             ,scurrency  => 'RUB'
                                             ,sstoreoper => sSTORE_OPER
                                             ,arnlist    => aRNlist);

    /* Удаление спецификаций из приходной накладной */
    /* отключение регистрации */
    if pkg_iud_int.is_register_active then pkg_iud.disable_register; end if;
    for c in (select s.*
                from table(cast(aRNList as udo_tp_numtable)) t
                    ,ininvoicesspecs s
               where s.prn = t.column_value)
    loop
      /* удаление */
      p_ininvoicesspecs_base_delete(nrn => c.rn, nsumm_ininvoices => nNumber, nsummtax_ininvoices => nNumber);
      /* сохранение RN заголовка */
      nInInvoices := c.prn;
    end loop;
    /* включение регистрации */
    if not pkg_iud_int.is_register_active then pkg_iud.enable_register; end if;
    
    /* Копирование свойств заголовков */
    pkg_docs_props_vals.copy(sunitcode_from => 'ReturnInvoicesToSuppliers'
                            ,ndocument_from => rRow.rn
                            ,sunitcode_to   => 'IncomingInvoices'
                            ,ndocument_to   => nInInvoices);

    /* Считывание заголовка приходной накладной */
    rInInvoices := usr_pkg_ininvoices.ininvoices_get(nrn =>  nInInvoices, nflagsmart => 0);

    /* По спецификациям текущего документа */
    for c in (select t.*
                    ,gs.prn   as goodsparties
                    ,nm.prn   as nomen 
                from rinvtosupspecs t
                    ,goodssupply    gs
                    ,nommodif       nm
               where t.prn      = rRow.rn
                 and gs.rn      = t.goodssupply
                 and t.nommodif = nm.rn)

    loop
      /* Считывание приходной партии */
      rGoodsParties := usr_pkg_goodsparties.goodsparties_get(nrn => c.goodsparties, nflagsmart => 0);
      /* Заполнение переменных */
      rInInvoicesSpecs.prn             := rInInvoices.rn;
      rInInvoicesSpecs.company         := rInInvoices.company;
      rInInvoicesSpecs.crn             := rInInvoices.crn;
      rInInvoicesSpecs.nomen           := c.nomen;
      rInInvoicesSpecs.modif           := c.nommodif;
      rInInvoicesSpecs.pack            := c.nomnmodifpack;
      rInInvoicesSpecs.article         := c.article;
      rInInvoicesSpecs.taxgr           := c.taxgr;
      rInInvoicesSpecs.store           := null;
      rInInvoicesSpecs.quant           := c.quant;
      rInInvoicesSpecs.quantalt        := c.quantalt;
      rInInvoicesSpecs.price           := c.price;
      rInInvoicesSpecs.pricemeas       := c.pricemeas;
      rInInvoicesSpecs.summ            := c.summ;
      rInInvoicesSpecs.summtax         := c.summtax;
      rInInvoicesSpecs.summ_nds        := c.summ_nds;
      rInInvoicesSpecs.autocalc_sign   := c.autocalc_sign;
      rInInvoicesSpecs.srok            := null;
      rInInvoicesSpecs.sertificate     := null;
      rInInvoicesSpecs.note            := null;
      rInInvoicesSpecs.begindate       := c.begindate;
      rInInvoicesSpecs.enddate         := c.enddate;
      rInInvoicesSpecs.sernumb         := null;
      rInInvoicesSpecs.barcode         := null;
      rInInvoicesSpecs.country         := null;
      rInInvoicesSpecs.gtd             := null;
      rInInvoicesSpecs.producer        := null;
      rInInvoicesSpecs.storage_time    := null;
      rInInvoicesSpecs.umeas_storage   := null;
      rInInvoicesSpecs.discount        := 0;
      rInInvoicesSpecs.original_name   := c.original_name;
      rInInvoicesSpecs.prod_date       := null;
      rInInvoicesSpecs.mdmnomen        := null;

      /* Добавление спецификации */
      usr_pkg_ininvoices.ininvoicesspecs_base_insert(rrow => rInInvoicesSpecs, nrn => rInInvoicesSpecs.rn, nsumm_ininvoices => nNumber, nsummtax_ininvoices => nNumber);

      /* По калькуляциям спецификации текущего документа  */
      for c1 in (select * from rinvtosupclc where prn = c.rn)
      loop
        /* Заполнение переменных */
        rInInvoicesSpC.prn          := rInInvoicesSpecs.rn;
        rInInvoicesSpC.company      := c1.company;
        rInInvoicesSpC.numb         := c1.numb;
        rInInvoicesSpC.cost_article := c1.cost_article;
        rInInvoicesSpC.cost_place   := c1.cost_place;
        rInInvoicesSpC.cost_plan    := c1.cost_plan;
        rInInvoicesSpC.cost_fact    := c1.cost_fact;
        rInInvoicesSpC.priority     := c1.priority;
        rInInvoicesSpC.faceaccount  := c1.faceacc;
        rInInvoicesSpC.graphpoint   := c1.graphpoint;
        rInInvoicesSpC.finoper_type := c1.finoper_type;
        rInInvoicesSpC.quant_plan   := c1.quant_plan;
        rInInvoicesSpC.quant_fact   := c1.quant_fact;
        rInInvoicesSpC.subdiv       := c1.subdiv;
        /* Добавление калькуляции */
        usr_pkg_ininvoices.ininvoicesspc_base_insert(rrow => rInInvoicesSpC, nrn => nNumber);
      end loop;
    end loop;

    /* Установление связи */
    pkg_doclinks.link(nflag_smart   => 0
                     ,ncompany      => rRow.company
                     ,sin_unitcode  => 'ReturnInvoicesToSuppliers'
                     ,nin_document  => rRow.rn
                     ,sout_unitcode => 'IncomingInvoices'
                     ,nout_document => rInInvoices.rn);

  end RINVTOSUP_MAKE_IIV;
  /* ######################################################################################################### */

  procedure RINVTOSUP_UPDATE_SIGNTAX
  /*
  Заголовок. Исправление признака "Цены включают налоги"
  */
  (
   nFLAGSMART   in number default 0
  ,nRN          in number
  ,nSIGNTAX     in number /*0 - не включают, 1 - включают */
  ) 
  is
    rRow        rinvtosup%rowtype;
    rSpec       rinvtosupspecs%rowtype;
  begin
    /* Заголовок  */
    rRow := rinvtosup_get(nrn => nRN);
    
    /* Проверка параметров*/    
    /* Не задан */
    if nSIGNTAX is null then
      p_exception(0, 'Не задан параметр процедуры "Цены включают налоги". %s'
                 ,cr||f_docdescrs_get_description(sunitcode => 'ReturnInvoicesToSuppliers', ndocument => rRow.rn)); 
    elsif nSIGNTAX not in (0, 1) then
      p_exception(0, 'Неверное значение: "%s" параметра процедуры "Цены включают налоги". %s'
                 ,nSIGNTAX
                 ,cr||f_docdescrs_get_description(sunitcode => 'ReturnInvoicesToSuppliers', ndocument => rRow.rn)); 
    end if;
    /* Имеет такое же значение, как в документе */
    if  cmp_num(rRow.signtax, nSIGNTAX) = 1 
    and nFLAGSMART = 0 then
      p_exception(0, 'Параметр "Цены включают налоги" имеет такое же значение, как в документе: "%s". %s'
                 ,case rRow.signtax when 0 then 'Нет' else 'Да' end
                 ,cr||f_docdescrs_get_description(sunitcode => 'ReturnInvoicesToSuppliers', ndocument => rRow.rn)); 
    end if;
      
    /* Исправление заголовка */
    update rinvtosup
       set signtax = nSIGNTAX
     where rn = rRow.rn;

    /* По спецификациям */
   for c in (select * from rinvtosupspecs where prn = rRow.rn)
    loop
      /* Сохранение записи в переменную */
      rSpec := c;
      /* Расчёт сумм от суммы с налогами */
      pkg_dictaxis_calc.p_calculate_base
      (
       nflag_smart => 0
      ,ncompany    => rRow.company
      ,ddate       => rRow.docdate
      ,nsumm_sign  => 1
      ,ninsumm     => rSpec.summtax
      ,ntaxgr      => rSpec.taxgr
      ,nquant      => rSpec.quant
      ,nncp_sign   => 1
      );
      /* Расчёт и сохранение цены в переменную */
      rSpec.price := case nSIGNTAX 
                       when 0 then pkg_dictaxis_calc.f_get_value(0) /* Сумма без налогов (0) */
                       else pkg_dictaxis_calc.f_get_value(2)        /* Сумма со всеми налогами (2) */
                     end  / rSpec.quant; 
      /* Исправление спецификации */
      rinvtosupspecs_base_update(rrow => rSpec);
    end loop;

  end RINVTOSUP_UPDATE_SIGNTAX;
  /*#########################################################################################################*/

  procedure RINVTOSUP_RECREATE_IIVSC
  /*
  Заголовок. Пересоздать калькуляции
  */
  (
   nRN      in number
  ) 
  is
    rRow                  rinvtosup%rowtype;
    nINDH                 pkg_std.tref;           /* входной документ. Заголовок. RN */
    rINDS                 inorderspecs%rowtype;   /* входной документ. Спецификация. Запись */
    nINDC_CURC_Quant      pkg_std.tnumber;        /* распределённое количество калькуляции входного документа */
    nINDC_CURC_QuantRest  pkg_std.tnumber;        /* нераспределённое количество калькуляции входного документа */
    nCURS_QuantRest       pkg_std.tnumber;        /* нераспределённое количество калькуляции текущего документа */
    nQuant                pkg_std.tnumber;        /* количество для распределения */
    rCURC                 rinvtosupclc%rowtype;   /* калькуляция текущего документа. Запись */
    
    nNumber           pkg_std.tnumber; 
  begin
    /* Заголовок  */
    rRow := rinvtosup_get(nrn => nRN);

    /* Удаление калькуляций во всех спецификациях текущего документа */
    for c in (select rn, company from rinvtosupclc where prn in (select rn from rinvtosupspecs where prn =  nRN))
    loop
      p_rinvtosupclc_base_delete(nrn => c.rn, ncompany => c.company);
    end loop;
    
    /* По спецификациям текущего документа */
    for sp in (select gp.sernumb as gp_sernumb, t.*
                 from rinvtosupspecs t
                     ,goodssupply    gs
                     ,goodsparties   gp
                where t.prn = nRN
                  and gs.rn = t.goodssupply
                  and gp.rn = gs.prn)
    loop
      /* Поиск заголовка входного документа */
      nINDH := usr_pkg_doclinks.doclinks_link_in_doc(ntoo_many_rows => 0
                                                    ,sout_unitcode  => 'ReturnInvoicesToSuppliers'
                                                    ,nout_document  => sp.prn
                                                    ,sin_unitcode   => 'IncomingOrders');
      /* поиск аналогичной спецификации входного документа */
      usr_pkg_inorders.inorderspecs_get_by_params(nprn          => nINDH
                                                 ,nnommodif     => sp.nommodif
                                                 ,nnommodifpack => sp.nomnmodifpack
                                                 ,narticle      => sp.article
                                                 ,ssernumb      => sp.gp_sernumb
                                                 ,rrow          => rINDS);

      /* Нераспределённое количество калькуляции текущего документа = количество по спецификации текущего документа */
      nCURS_QuantRest := sp.quant;

      /* По калькуляциям спецификации входного документа с сортировкой по номеру ЛС */
      for c in (select t.*
                  from inorderspecsclc t, faceacc fa
                 where t.prn         = rINDS.rn
                   and t.faceaccount = fa.rn
                order by fa.numb)
      loop
        /* распределённое количество калькуляции входного документа */
        usr_pkg_inorders.inorderspecsclc_get_iivsc_qnt(nrn         => c.rn
                                                      ,nquant_plan => nINDC_CURC_Quant
                                                      ,nquant_fact => nNumber);
        /* нераспределённое количество калькуляции входного документа */
        nINDC_CURC_QuantRest := c.quant_plan - nINDC_CURC_Quant;
        /* если Нераспределённое количество калькуляции текущего документа больше или равно Нераспределённому количеству калькуляции входного документа */
        if nCURS_QuantRest >= nINDC_CURC_QuantRest then
          /* используем Нераспределённое количество калькуляции входного документа */
          nQuant := nINDC_CURC_QuantRest;
          /* пересчитываем Нераспределённое количество калькуляции текущего документа */
          nCURS_QuantRest := nCURS_QuantRest - nQuant;
        /* если Нераспределённое количество калькуляции текущего документа меньше Нераспределённого количества калькуляции входного документа */
        else
          /* используем Нераспределённое количество калькуляции текущего документа */
          nQuant          := nCURS_QuantRest;
          /* пересчитываем Нераспределённое количество калькуляции текущего документа */
          nCURS_QuantRest := nCURS_QuantRest - nQuant;
        end if;
         /* если есть количество для распределения */
        if nQuant != 0 then 
          /* Сохранение значений в переменную калькуляции текущего документа */
          rCURC.prn          := sp.rn;
          rCURC.company      := sp.company;
          rCURC.crn          := sp.crn;
          rCURC.numb         := null;
          rCURC.cost_article := c.cost_article;
          rCURC.cost_place   := c.cost_place;
          rCURC.cost_plan    := null;
          rCURC.cost_fact    := null;
          rCURC.priority     := c.priority;
          rCURC.faceacc      := c.faceaccount;
          rCURC.graphpoint   := c.graphpoint;
          rCURC.finoper_type := c.finoper_type;
          rCURC.quant_plan   := nQuant;
          /*rCURC.quant_fact   := nQuant;*/
          rCURC.subdiv       := c.subdiv;
          /* добавление калькуляции текущего документа*/
          rinvtosupclc_base_insert(rrow => rCURC, nrn => nNumber);
        end if;
      end loop;
    end loop;

  end RINVTOSUP_RECREATE_IIVSC;

  /* ######################################################################################################### */

  /*** процедура пересчета исполнения у родительских документов **
  по мотивам P_RINVTOSUP_BSET_STATUS  */
  procedure RINVTOSUP_RECALC_PERFORMANCE
  (
    nCOMPANY    in number,
    dWORK_DATE  in date,
    nR_RN       in number, -- RN возвратной накладной
    nR_OSTATUS  in number, -- старое состояние (0 - не отработан; 1 - план; 2 - факт)
    nR_NSTATUS  in number  -- новое состояние (0 - не отработан; 1 - план; 2 - факт)
  )
  is
    nR_IDENT    PKG_STD.tNUMBER;  -- идентификатор процесса отражения.
    nR_ORDER    PKG_STD.tREF;     -- RN периода исполнения заказа поставщику
    nR_PACCIN   PKG_STD.tREF;     -- RN входящего счета на оплату
    nPLAN_SIGN  PKG_STD.tNUMBER;  -- знак суммирования плана (-1,0,1)
    nFACT_SIGN  PKG_STD.tNUMBER;  -- знак суммирования факта (-1,0,1)
    nSO_SIGN    PKG_STD.tNUMBER;  -- знак зависит от складской операции (1 - приход, -1 - расход)
  begin
    /* инициализация пакета расчета исполнения товарных позиций */
    PKG_GOODSDOCS_PERF_CRM.INIT( nCOMPANY, nR_IDENT );
    /* поиск родительского заказа поставщикам (работа идет с конкретным периодом) */
    nR_ORDER := PKG_GOODSDOCS_PERF_CRM.FIND_SET_PARENT( nR_IDENT, 'ReturnInvoicesToSuppliers', nR_RN, 'DeliveryOrdersPerform' );
    /* поиск родительского входящего счета на оплату */
    nR_PACCIN := PKG_GOODSDOCS_PERF_CRM.FIND_SET_PARENT( nR_IDENT, 'ReturnInvoicesToSuppliers', nR_RN, 'PaymentAccountsIn' );

    /* если нет ни одного родительского документа - выходим */
    if ( nR_ORDER is null ) and ( nR_PACCIN is null ) then
      return;
    end if;

    /* знак в зависимости от складской операции */
    select decode(S.GSMWAYS_TYPE, 0, -1, 1)
      into nSO_SIGN
      from RINVTOSUP       T,
           AZSGSMWAYSTYPES S
     where T.RN        = nR_RN
       and T.STOREOPER = S.RN;

    /* выставим знаки суммирования плана и факта */
    nPLAN_SIGN := 0;
    nFACT_SIGN := 0;
    if    ( nR_OSTATUS = 0 ) then -- был не отработан
      if    ( nR_NSTATUS = 1 ) then -- будет планом
        nPLAN_SIGN := 1;
        nFACT_SIGN := 0;
      elsif ( nR_NSTATUS = 2 ) then -- будет фактом
        nPLAN_SIGN := 1;
        nFACT_SIGN := 1;
      else
        return;
      end if; -- на всякий случай
    elsif ( nR_OSTATUS = 1 ) then -- был планом
      if    ( nR_NSTATUS = 0 ) then -- будет не отработан
        nPLAN_SIGN := -1;
        nFACT_SIGN := 0;
      elsif ( nR_NSTATUS = 2 ) then -- будет фактом
        nPLAN_SIGN := 0;
        nFACT_SIGN := 1;
      else
        return;
      end if; -- на всякий случай
    elsif ( nR_OSTATUS = 2 ) then -- был фактом
      if    ( nR_NSTATUS = 0 ) then -- будет не отработан
        nPLAN_SIGN := -1;
        nFACT_SIGN := -1;
      elsif ( nR_NSTATUS = 1 ) then -- будет планом
        nPLAN_SIGN := 0;
        nFACT_SIGN := -1;
      else
        return;
      end if; -- на всякий случай
    end if;
    nPLAN_SIGN := nPLAN_SIGN * nSO_SIGN;
    nFACT_SIGN := nFACT_SIGN * nSO_SIGN;

    /* отражение исполнения по спецификациям возвратной накладной */
    for RISS in ( select R.CURRENCY, R.CURR_RATE, R.CURR_RATE_BASE,
                         F.CURRENCY FA_CURRENCY, R.CURR_RATE_ACC, R.CURR_RATE_INV_ACC,
                         M.PRN NOMEN, RS.NOMMODIF, RS.NOMNMODIFPACK, RS.ARTICLE,
                         nvl(GS.STORE, R.STORE) STORE, GP.SERNUMB, GP.COUNTRY, GP.GTD,
                         RS.QUANT, RS.QUANTALT, RS.SUMMTAX
                    from RINVTOSUP      R,
                         RINVTOSUPSPECS RS,
                         NOMMODIF       M,
                         FACEACC        F,
                         GOODSSUPPLY    GS,
                         GOODSPARTIES   GP
                   where R.RN           = nR_RN
                     and R.RN           = RS.PRN
                     and RS.NOMMODIF    = M.RN
                     and R.FACEACC      = F.RN
                     and RS.GOODSSUPPLY = GS.RN (+)
                     and GS.PRN         = GP.RN (+) )
    loop
      /* суммирование исполнения (партию не указываем, т.к. возврат может быть в другую партию) */
      PKG_GOODSDOCS_PERF_CRM.SET_PERF( nR_IDENT, 1/*SIGN_PACK*/,
                                       null/*NOMENCLS*/, null/*UMEAS_MAIN*/,
                                       RISS.NOMEN, null/*NOMNPACK*/, RISS.NOMMODIF, RISS.NOMNMODIFPACK, RISS.ARTICLE,
                                       RISS.STORE, null/*GOODSPARTY*/, RISS.SERNUMB, RISS.COUNTRY, RISS.GTD,
                                       RISS.QUANT, RISS.QUANTALT,
                                       RISS.QUANT, RISS.QUANTALT,
                                       0/*nRTN_PLANM_QUANT*/, 0/*nRTN_PLANA_QUANT*/,
                                       0/*nRTN_FACTM_QUANT*/, 0/*nRTN_FACTA_QUANT*/,
                                       RISS.SUMMTAX, RISS.SUMMTAX,
                                       nPLAN_SIGN, nFACT_SIGN,
                                       0/*nRTN_PLAN_SIGN*/, 0/*nRTN_FACT_SIGN*/,
                                       RISS.CURRENCY, RISS.CURR_RATE, RISS.CURR_RATE_BASE,
                                       RISS.FA_CURRENCY, RISS.CURR_RATE_ACC, RISS.CURR_RATE_INV_ACC, dWORK_DATE );
    end loop;
    /* сохранение рассчитаного исполнения в родительских документах */
    PKG_GOODSDOCS_PERF_CRM.SAVE_PARENT( nR_IDENT );
  end RINVTOSUP_RECALC_PERFORMANCE;
  /* ######################################################################################################### */

  function RINVTOSUPSPECS_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return rinvtosupspecs%rowtype
  is
    rRow rinvtosupspecs%rowtype;
  begin
    begin
      select * into rRow from rinvtosupspecs where rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nRN, get_unitlist_code_table(1, 'RINVTOSUPSPECS'));
      when others then
        p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>', nRN, f_unitlist_getname(get_unitlist_code_table(1, 'RINVTOSUPSPECS')));
    end;
    return(rRow);
  end RINVTOSUPSPECS_GET;
  /*#########################################################################################################*/
  
  PROCEDURE RINVTOSUPSPECS_GET_BY_PARAMS
  /*
  Спецификация. Получение записи по параметрам
  */
  (
   NFLAGSMART         IN NUMBER DEFAULT 0
  ,NFLAG_OPTION       IN NUMBER DEFAULT 1 -- использовать в условии поиска значения переменных: 0 - всех, 1 - только заданных
  ,NTOO_MANY_ROWS     IN NUMBER DEFAULT 0 -- 0 - только единственную запись, 1 - первую попавшуюся из нескольких
  ,NPRN               IN NUMBER
  ,NNOMMODIF          IN NUMBER DEFAULT NULL
  ,NNOMMODIFPACK      IN NUMBER DEFAULT NULL
  ,NTAXGR             IN NUMBER DEFAULT NULL
  ,NQUANT             IN NUMBER DEFAULT NULL
  ,NQUANTALT          IN NUMBER DEFAULT NULL
  ,NPRICE             IN NUMBER DEFAULT NULL
  ,NARTICLE           IN NUMBER DEFAULT NULL
  ,SSERNUMB           IN VARCHAR2 DEFAULT NULL
  ,DBEGINDATE         IN DATE     DEFAULT NULL
  ,DENDDATE           IN DATE     DEFAULT NULL
  ,RROW               OUT RINVTOSUPSPECS%ROWTYPE 
  ) 
  is
    sMessage      pkg_std.tlstring; 
  BEGIN
    BEGIN
      SELECT *
        INTO rRow
        FROM RINVTOSUPSPECS T
       WHERE T.PRN                   = NPRN
         AND (NVL(T.NOMMODIF, 0)     = NVL(NNOMMODIF, 0) OR (NNOMMODIF IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.NOMNMODIFPACK, 0) = NVL(NNOMMODIFPACK, 0) OR (NNOMMODIFPACK IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.TAXGR, 0)        = NVL(NTAXGR, 0) OR (NTAXGR IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.QUANT, 0)        = NVL(NQUANT, 0) OR (NQUANT IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.QUANTALT, 0)     = NVL(NQUANTALT, 0) OR (NQUANTALT IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.PRICE, 0)        = NVL(NPRICE, 0) OR (NPRICE IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.ARTICLE, 0)      = NVL(NARTICLE, 0) OR (NARTICLE IS NULL AND NFLAG_OPTION = 1))
         AND (NVL(T.SERNUMB, 0)      = NVL(SSERNUMB, 0) OR (SSERNUMB IS NULL AND NFLAG_OPTION = 1))
         AND ((T.BEGINDATE = DBEGINDATE OR (T.BEGINDATE IS NULL AND DBEGINDATE IS NULL)) OR (DBEGINDATE IS NULL AND NFLAG_OPTION = 1))
         AND ((T.ENDDATE   = DENDDATE   OR (T.ENDDATE   IS NULL AND DENDDATE   IS NULL)) OR (DENDDATE   IS NULL AND NFLAG_OPTION = 1))
         ;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF NFLAGSMART = 0 THEN
          usr_pkg_document.spec_get_message(ncompany    => 90521
                                           ,sunitcode   => 'PaymentAccountsIn'
                                           ,nprn        => NPRN
                                           ,nnommodif   => NNOMMODIF
                                           ,ntaxgr      => NTAXGR
                                           ,nquant      => NQUANT
                                           ,nprice      => NPRICE
                                           ,ssernumb    => SSERNUMB 
                                           ,dbegindate  => DBEGINDATE
                                           ,denddate    => DENDDATE
                                           ,smessage    => sMessage);
          p_exception(0 , 'Не найдена спецификация с параметрами: '||sMessage);
        END IF;
      WHEN TOO_MANY_ROWS THEN
        IF NTOO_MANY_ROWS = 0 AND NFLAGSMART = 0 THEN
          usr_pkg_document.spec_get_message(ncompany    => 90521
                                           ,sunitcode   => 'PaymentAccountsIn'
                                           ,nprn        => NPRN
                                           ,nnommodif   => NNOMMODIF
                                           ,ntaxgr      => NTAXGR
                                           ,nquant      => NQUANT
                                           ,nprice      => NPRICE
                                           ,ssernumb    => SSERNUMB 
                                           ,dbegindate  => DBEGINDATE
                                           ,denddate    => DENDDATE
                                           ,smessage    => sMessage);
          p_exception(0 , 'Найдено больше одной спецификации с параметрами: '||sMessage);
        END IF;
      WHEN OTHERS THEN
          usr_pkg_document.spec_get_message(ncompany    => 90521
                                           ,sunitcode   => 'PaymentAccountsIn'
                                           ,nprn        => NPRN
                                           ,nnommodif   => NNOMMODIF
                                           ,ntaxgr      => NTAXGR
                                           ,nquant      => NQUANT
                                           ,nprice      => NPRICE
                                           ,ssernumb    => SSERNUMB 
                                           ,dbegindate  => DBEGINDATE
                                           ,denddate    => DENDDATE
                                           ,smessage    => sMessage);
          p_exception(0 , 'Неопределённая ситуация при поиске спецификации с параметрами: '||sMessage);
    END;
  END RINVTOSUPSPECS_GET_BY_PARAMS;
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              rinvtosupspecs%rowtype;
  begin
    /* Считывание */
    rRow  := rinvtosupspecs_get(nrn => nRN);

    /* ПРОВЕРКИ */
    /* Базовая */
    rinvtosupspecs_check_base(nRN, nCOMPANY);
    /* Есть связь по входу с РН в подразделения */
    if f_doclinks_link_in( sout_unitcode => 'ReturnInvoicesToSuppliers', nout_document => rRow.prn, sin_unitcode => 'GoodsTransInvoicesToDepts' ) is not null then
      p_exception(0, 'Запрещено исправление спецификации, т.к. документ связан по входу с разделом "Расходные накладные на отпуск в подразделения".%s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'ReturnInvoicesToSuppliersSpecs', ndocument => rRow.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'ReturnInvoicesToSuppliers', ndocument => rRow.prn)
                 ); 
    end if;

  end RINVTOSUPSPECS_AINSERT;
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              rinvtosupspecs%rowtype;
  begin
    /* Считывание */
    rRow  := rinvtosupspecs_get(nrn => nRN);
    usr_pkg_pub_const.rrinvtosupspecs := rRow;

  end RINVTOSUPSPECS_BUPDATE;
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              rinvtosupspecs%rowtype;
    bChanged          boolean := false;
  begin
    /* Считывание */
    rRow  := rinvtosupspecs_get(nrn => nRN);
    /* Изменялись ли поля кроме количества и суммм */
    for c in (
              select usr_pkg_pub_const.rrinvtosupspecs.taxgr
                    ,usr_pkg_pub_const.rrinvtosupspecs.goodssupply
                    ,usr_pkg_pub_const.rrinvtosupspecs.nommodif
                    ,usr_pkg_pub_const.rrinvtosupspecs.nomnmodifpack
                    ,usr_pkg_pub_const.rrinvtosupspecs.article
                    ,usr_pkg_pub_const.rrinvtosupspecs.cell
                   /* ,usr_pkg_pub_const.rrinvtosupspecs.price */
                    ,usr_pkg_pub_const.rrinvtosupspecs.pricemeas 
                   /* ,usr_pkg_pub_const.rrinvtosupspecs.quant */
                   /* ,usr_pkg_pub_const.rrinvtosupspecs.quantalt */
                    ,usr_pkg_pub_const.rrinvtosupspecs.coeff
                    ,usr_pkg_pub_const.rrinvtosupspecs.coeff_val_sign
                    ,usr_pkg_pub_const.rrinvtosupspecs.coeff_calc_sign
                   /* ,usr_pkg_pub_const.rrinvtosupspecs.summtax */
                   /* ,usr_pkg_pub_const.rrinvtosupspecs.summ */
                    ,usr_pkg_pub_const.rrinvtosupspecs.begindate
                    ,usr_pkg_pub_const.rrinvtosupspecs.enddate
                   /* ,usr_pkg_pub_const.rrinvtosupspecs.note */
                    ,usr_pkg_pub_const.rrinvtosupspecs.original_name
                    ,usr_pkg_pub_const.rrinvtosupspecs.sernumb
                   /* ,usr_pkg_pub_const.rrinvtosupspecs.summ_nds */
                    ,usr_pkg_pub_const.rrinvtosupspecs.autocalc_sign
                from dual
              minus
              select taxgr
                    ,goodssupply
                    ,nommodif
                    ,nomnmodifpack
                    ,article
                    ,cell
                   /* ,price */
                    ,pricemeas 
                    /* ,quant */
                    /* ,quantalt */
                    ,coeff
                    ,coeff_val_sign
                    ,coeff_calc_sign
                   /* ,summtax */
                   /* ,summ */
                    ,begindate
                    ,enddate
                   /* ,note*/
                    ,original_name
                    ,sernumb
                    /*, summ_nds */
                    ,autocalc_sign
                from rinvtosupspecs
               where rn = rRow.rn
            )
    loop
      bChanged := true;
    end loop;

    /* ПРОВЕРКИ */
    /* Базовая */
    rinvtosupspecs_check_base(nRN, nCOMPANY);
    
    /* Если изменялись поля кроме колчиества и сумм и есть связь по входу с РН в подразделения  */
    if bChanged
    and f_doclinks_link_in( sout_unitcode => 'ReturnInvoicesToSuppliers'
                           ,nout_document => rRow.prn
                           ,sin_unitcode  => 'GoodsTransInvoicesToDepts' ) is not null then
      p_exception(0, 'Запрещено исправление спецификации, т.к. документ связан по входу с разделом "Расходные накладные на отпуск в подразделения".%s%s'
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'ReturnInvoicesToSuppliersSpecs', ndocument => rRow.rn )
                 ,cr||cr||f_docdescrs_get_description( sunitcode => 'ReturnInvoicesToSuppliers', ndocument => rRow.prn ) ); 
    end if;

  end RINVTOSUPSPECS_AUPDATE;
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  is
    rRow              rinvtosupspecs%rowtype;
  begin
    /* Считывание */
    rRow  := rinvtosupspecs_get(nrn => nRN);

    /* ПРОВЕРКИ */
    /* Базовая */
    rinvtosupspecs_check_base(nRN, nCOMPANY);
    /* Есть связь по входу с РН в подразделения */
    /*if f_doclinks_link_in( sout_unitcode => 'ReturnInvoicesToSuppliers', nout_document => rRow.prn, sin_unitcode => 'GoodsTransInvoicesToDepts' ) is not null then
      p_exception(0, 'Запрещено исправление спецификации, т.к. документ связан по входу с разделом "Расходные накладные на отпуск в подразделения".%s%s'
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'ReturnInvoicesToSuppliersSpecs', ndocument => rRow.rn)
                 ,cr||cr||f_docdescrs_get_description(sunitcode => 'ReturnInvoicesToSuppliers', ndocument => rRow.prn)
                 ); 
    end if;*/

  end RINVTOSUPSPECS_BDELETE;
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN       in number
  ,nCOMPANY  in number
  ) 
  IS
    rRow              rinvtosupspecs%rowtype;
  begin
    null;
    /* Считывание */
    /*rRow      := rinvtosupspecs_get(nrn => nRN);*/

    /* ИСПРАВЛЕНИЯ */
    
  end RINVTOSUPSPECS_CHECK_BASE;
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_INSERT
  /*
  Спецификация. Добавление
  */
  (
   rV_ROW         in v_rinvtosupspecs%rowtype
  ,rV_RINVTOSUP   in v_rinvtosup%rowtype
  ,nDUP_RN        in number          /* Размножение калькуляции */
  ,nRN            in out number      /* если не null, то это размножение */
  ,sMSG           out varchar2
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_rinvtosupspecs_insert(ncompany         => rV_ROW.NCOMPANY
                             ,nprn             => rV_ROW.NPRN
                             ,staxgr           => rV_ROW.STAXGR
                             ,snomen           => rV_ROW.SNOMEN
                             ,snommodif        => rV_ROW.SNOMMODIF
                             ,snomnmodifpack   => rV_ROW.SNOMNMODIFPACK
                             ,sarticle         => rV_ROW.SARTICLE
                             ,sstore           => rV_RINVTOSUP.SSTORE
                             ,scell            => rV_ROW.SCELL
                             ,sindoc           => rV_RINVTOSUP.SPARTY
                             ,ssernumb         => rV_ROW.SSERNUMB
                             ,scountry         => rV_ROW.SCOUNTRY
                             ,sgtd             => rV_ROW.SGTD
                             ,nprice           => rV_ROW.NPRICE
                             ,npricemeas       => rV_ROW.NPRICEMEAS
                             ,nquant           => rV_ROW.NQUANT
                             ,nquantalt        => rV_ROW.NQUANTALT
                             ,ncoeff           => rV_ROW.NCOEFF
                             ,ncoeff_val_sign  => rV_ROW.NCOEFF_VAL_SIGN
                             ,ncoeff_calc_sign => rV_ROW.NCOEFF_CALC_SIGN
                             ,nsummtax         => rV_ROW.NSUMMTAX
                             ,nsumm            => rV_ROW.NSUMM
                             ,nsumm_nds        => rV_ROW.NSUMM_NDS
                             ,nautocalc_sign   => rV_ROW.NAUTOCALC_SIGN
                             ,dbegindate       => rV_ROW.DBEGINDATE
                             ,denddate         => rV_ROW.DENDDATE
                             ,snote            => rV_ROW.SNOTE
                             ,soriginal_name   => rV_ROW.SORIGINAL_NAME
                             ,ndup_rn          => nDUP_RN
                             ,nrn              => nRN
                             ,smsg             => sMSG);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_exception(0, 'Неиспользуемый режим выполнения <%s>', nMODE); 
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end RINVTOSUPSPECS_INSERT;
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_UPDATE
  /*
  Спецификация. Исправление
  */
  (
   rV_ROW         in v_rinvtosupspecs%rowtype
  ,rV_RINVTOSUP   in v_rinvtosup%rowtype
  ,sMSG           out varchar2
  ,nMODE          in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_rinvtosupspecs_update(nrn              => RV_ROW.NRN
                             ,ncompany         => RV_ROW.NCOMPANY
                             ,nprn             => RV_ROW.NPRN
                             ,staxgr           => RV_ROW.STAXGR
                             ,snomen           => RV_ROW.SNOMEN
                             ,snommodif        => RV_ROW.SNOMMODIF
                             ,snomnmodifpack   => RV_ROW.SNOMNMODIFPACK
                             ,sarticle         => RV_ROW.SARTICLE
                             ,sstore           => rV_RINVTOSUP.SSTORE
                             ,scell            => RV_ROW.SCELL
                             ,sindoc           => rV_RINVTOSUP.SPARTY
                             ,ssernumb         => RV_ROW.SSERNUMB
                             ,scountry         => RV_ROW.SCOUNTRY
                             ,sgtd             => RV_ROW.SGTD
                             ,nprice           => RV_ROW.NPRICE
                             ,npricemeas       => RV_ROW.NPRICEMEAS
                             ,nquant           => RV_ROW.NQUANT
                             ,nquantalt        => RV_ROW.NQUANTALT
                             ,ncoeff           => RV_ROW.NCOEFF
                             ,ncoeff_val_sign  => RV_ROW.NCOEFF_VAL_SIGN
                             ,ncoeff_calc_sign => RV_ROW.NCOEFF_CALC_SIGN
                             ,nsummtax         => RV_ROW.NSUMMTAX
                             ,nsumm            => RV_ROW.NSUMM
                             ,nsumm_nds        => RV_ROW.NSUMM_NDS
                             ,nautocalc_sign   => RV_ROW.NAUTOCALC_SIGN
                             ,dbegindate       => RV_ROW.DBEGINDATE
                             ,denddate         => RV_ROW.DENDDATE
                             ,snote            => RV_ROW.SNOTE
                             ,soriginal_name   => RV_ROW.SORIGINAL_NAME
                             ,smsg             => sMSG);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_exception(0, 'Неиспользуемый режим выполнения <%s>', nMODE); 
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end RINVTOSUPSPECS_UPDATE;
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_BASE_INSERT
  /*
  Спецификация. Добавление базовое
  */
  (
   rROW     in rinvtosupspecs%rowtype
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ,nRN      out number
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_rinvtosupspecs_base_insert(ncompany         => rROW.COMPANY
                                  ,nprn             => rROW.PRN
                                  ,ntaxgr           => rROW.TAXGR
                                  ,ngoodssupply     => rROW.GOODSSUPPLY
                                  ,ssernumb         => rROW.SERNUMB
                                  ,nnommodif        => rROW.NOMMODIF
                                  ,nnomnmodifpack   => rROW.NOMNMODIFPACK
                                  ,narticle         => rROW.ARTICLE
                                  ,ncell            => rROW.CELL
                                  ,nprice           => rROW.PRICE
                                  ,npricemeas       => rROW.PRICEMEAS
                                  ,nquant           => rROW.QUANT
                                  ,nquantalt        => rROW.QUANTALT
                                  ,ncoeff           => rROW.COEFF
                                  ,ncoeff_val_sign  => rROW.COEFF_VAL_SIGN
                                  ,ncoeff_calc_sign => rROW.COEFF_CALC_SIGN
                                  ,nsummtax         => rROW.SUMMTAX
                                  ,nsumm            => rROW.SUMM
                                  ,nsumm_nds        => rROW.SUMM_NDS
                                  ,nautocalc_sign   => rROW.AUTOCALC_SIGN
                                  ,dbegindate       => rROW.BEGINDATE
                                  ,denddate         => rROW.ENDDATE
                                  ,snote            => rROW.NOTE
                                  ,soriginal_name   => rROW.ORIGINAL_NAME
                                  ,nrn              => nRN);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_exception(0, 'Неиспользуемый режим выполнения <%s>', nMODE); 
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end RINVTOSUPSPECS_BASE_INSERT;
  /* ######################################################################################################### */

  procedure RINVTOSUPSPECS_BASE_UPDATE
  /*
  Спецификация. Исправление базовое
  */
  (
   rROW     in rinvtosupspecs%rowtype
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_rinvtosupspecs_base_update(nrn              => rROW.RN
                                  ,ncompany         => rROW.COMPANY
                                  ,nprn             => rROW.PRN
                                  ,ntaxgr           => rROW.TAXGR
                                  ,ngoodssupply     => rROW.GOODSSUPPLY
                                  ,ssernumb         => rROW.SERNUMB
                                  ,nnommodif        => rROW.NOMMODIF
                                  ,nnomnmodifpack   => rROW.NOMNMODIFPACK
                                  ,narticle         => rROW.ARTICLE
                                  ,ncell            => rROW.CELL
                                  ,nprice           => rROW.PRICE
                                  ,npricemeas       => rROW.PRICEMEAS
                                  ,nquant           => rROW.QUANT
                                  ,nquantalt        => rROW.QUANTALT
                                  ,ncoeff           => rROW.COEFF
                                  ,ncoeff_val_sign  => rROW.COEFF_VAL_SIGN
                                  ,ncoeff_calc_sign => rROW.COEFF_CALC_SIGN
                                  ,nsummtax         => rROW.SUMMTAX
                                  ,nsumm            => rROW.SUMM
                                  ,nsumm_nds        => rROW.SUMM_NDS
                                  ,nautocalc_sign   => rROW.AUTOCALC_SIGN
                                  ,dbegindate       => rROW.BEGINDATE
                                  ,denddate         => rROW.ENDDATE
                                  ,snote            => rROW.NOTE
                                  ,soriginal_name   => rROW.ORIGINAL_NAME);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_exception(0, 'Неиспользуемый режим выполнения <%s>', nMODE); 
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end RINVTOSUPSPECS_BASE_UPDATE;
  /* ######################################################################################################### */

  procedure RINVTOSUPCLC_BASE_INSERT
  /*
  Калькуляция. Добавление базовое
  */
  (
   rROW     in rinvtosupclc%rowtype
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ,nRN      out number
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_rinvtosupclc_base_insert(ncompany      => rROW.COMPANY
                                ,nprn          => rROW.PRN
                                ,snumb         => rROW.NUMB
                                ,ncost_article => rROW.COST_ARTICLE
                                ,ncost_place   => rROW.COST_PLACE
                                ,ncost_plan    => rROW.COST_PLAN
                                ,ncost_fact    => rROW.COST_FACT
                                ,npriority     => rROW.PRIORITY
                                ,nfaceacc      => rROW.FACEACC
                                ,ngraphpoint   => rROW.GRAPHPOINT
                                ,nfinoper_type => rROW.FINOPER_TYPE
                                ,nquant_plan   => rROW.QUANT_PLAN
                                ,nquant_fact   => rROW.QUANT_FACT
                                ,nsubdiv       => rROW.SUBDIV
                                ,nrn           => nRN);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_exception(0, 'Неиспользуемый режим выполнения <%s>', nMODE); 
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end RINVTOSUPCLC_BASE_INSERT;
  /* ######################################################################################################### */

  procedure RINVTOSUPCLC_BASE_UPDATE
  /*
  Калькуляция. Исправление базовое
  */
  (
   rROW     in rinvtosupclc%rowtype
  ,nMODE    in number default 0  /* Режим выполнения: 0 - штатный, 1 - пользовательский */
  ) 
  is
  begin
    /* Режим выполнения: 0 - штатный */
    if nMODE = 0 then
      p_rinvtosupclc_base_update(nrn           => rROW.RN
                                ,ncompany      => rROW.COMPANY
                                ,snumb         => rROW.NUMB
                                ,ncost_article => rROW.COST_ARTICLE
                                ,ncost_place   => rROW.COST_PLACE
                                ,ncost_plan    => rROW.COST_PLAN
                                ,ncost_fact    => rROW.COST_FACT
                                ,npriority     => rROW.PRIORITY
                                ,nfaceacc      => rROW.FACEACC
                                ,ngraphpoint   => rROW.GRAPHPOINT
                                ,nfinoper_type => rROW.FINOPER_TYPE
                                ,nquant_plan   => rROW.QUANT_PLAN
                                ,nquant_fact   => rROW.QUANT_FACT
                                ,nsubdiv       => rROW.SUBDIV);
    /* Режим выполнения: 1 - пользовательский */
    elsif nMODE = 1 then
      p_exception(0, 'Неиспользуемый режим выполнения <%s>', nMODE); 
    else
      p_exception(0, 'Неизвестный режим выполнения <%s>', nMODE); 
    end if;

  end RINVTOSUPCLC_BASE_UPDATE;
  /* ######################################################################################################### */


end USR_PKG_RINVTOSUP;
/
