create or replace procedure USR_P_REP_M_15
(
 nCOMPANY            in number      
,nIDENT              in number      /* Идентификатор помеченных записей*/
,sUNITCODE           in varchar2    /* Код раздела */
,nNUMB_LINES_FIRST   in number      /* Количество строк на первой странице */
,nNUMB_LINES_LAST    in number      /* Максимальное количество строк на последней странице */
,nNUMB_LINES         in number      /* Максимальное количество строк на остальных страницах */
,nPRINT_SUMMS        in number      /* Печатать суммы */
,nSUMM_WITH_TAX      in number default 1     /* Суммы с налогами */

)
as
  rDoc                usr_pkg_pub_const.tdoc_base_values_rec;
  rAccDoc             usr_pkg_pub_const.tdoc_base_values_rec;
  sAccUnitCode        unitlist.unitcode%type := case sUNITCODE 
                                                  when 'ReturnInvoicesToSuppliers' then 'PaymentAccountsIn' 
                                                  when 'GoodsTransInvoicesToConsumers' then 'PaymentAccounts' 
                                                end ;
  rFaceAcc            faceacc%rowtype;
  rSellerAgn          agnlist%rowtype;
  rSellerAcc          agnacc%rowtype;
  rPayerAgn           agnlist%rowtype;
  rPayerAcc           agnacc%rowtype;
  rShipperAgn         agnlist%rowtype;
  rShipperAcc         agnacc%rowtype;
  rStore              azsazslistmt%rowtype;
  rIn_Store           azsazslistmt%rowtype;
  rAgnFiFoAgn         agnlist%rowtype;
  rAgnFiFoAcc         agnacc%rowtype;
  rStages             stages%rowtype;
  nStagesCount        pkg_std.tnumber := 0; 
  rContracts          contracts%rowtype;
  rMOLAgn             agnlist%rowtype;
  rAccAgn             agnlist%rowtype;
  rSubDiv             ins_department%rowtype;
  rIn_SubDiv          ins_department%rowtype;
  rGovCntrId          govcntrid%rowtype;

  nNumber       pkg_std.tnumber; 
  sVarchar      pkg_std.tstring; 
  dDate         date;

  scell       constant varchar2(40) := '_s';

  /* Лист */
  SHEET1          constant PKG_STD.tSTRING := 'ТН';
  /* Шапка */
  SH1_HEAD        constant PKG_STD.tSTRING := 'Шапка';
  SH1_PAGE2       constant PKG_STD.tSTRING := 'Лист_2';
  SH1_LAST_PAGE   constant PKG_STD.tSTRING := 'СтрСтр';
  /* Строка */
  SH1_LINE1       constant PKG_STD.tSTRING := 'Строка_1';
  /* Строка Итого */
  SH1_LINE_ITOG   constant PKG_STD.tSTRING := 'Строка_Итого';
  /* Строка Всего по накладной */
  SH1_LINE_ALL    constant PKG_STD.tSTRING := 'Строка_Всего';

  /* Переменные */
  sTMP            PKG_STD.tSTRING;
  iLINE           integer;
  nQUANT          PKG_STD.tQUANT;
  nPRICE          PKG_STD.tSUMM;
  sMEAS           PKG_STD.tSTRING;
  nPASK_QUANT     PKG_STD.tSQUANT;
  nREC_QUANT      PKG_STD.tNUMBER := 0;
  nPASK_ALL       PKG_STD.tNUMBER := 0;
  nPASK_IT        PKG_STD.tSQUANT := 0;
  nQUANT_IT       PKG_STD.tSQUANT := 0;
  nQUANT_ALL      PKG_STD.tSQUANT := 0;
  nSUMM           PKG_STD.tSUMM;
  nNDS            PKG_STD.tSUMM;
  nSUMM_NDS       PKG_STD.tSUMM;
  nSUMM_IT        PKG_STD.tSUMM := 0;
  nSUMM_ALL       PKG_STD.tSUMM := 0;
  nNDS_IT         PKG_STD.tSUMM := 0;
  nNDS_ALL        PKG_STD.tSUMM := 0;
  nSUMM_NDS_IT    PKG_STD.tSUMM := 0;
  nSUMM_NDS_ALL   PKG_STD.tSUMM := 0;
  /* разбивка на страницы */
  nNUMB_LINES1        PKG_STD.tNUMBER;
  nNUMB_LINES_FIRST1  PKG_STD.tNUMBER;
  nNUMB_LINES_LAST1   PKG_STD.tNUMBER;
  nNUMB_DATA_LINE     PKG_STD.tNUMBER;
  nNUMB_DATA_PAGE     PKG_STD.tNUMBER;
  nNUMB_LINES_PAGE    PKG_STD.tNUMBER;
  nDIVPAGE            PKG_STD.tNUMBER;
  nNEWPAGE            PKG_STD.tNUMBER;
  nITPAGE             PKG_STD.tNUMBER;

begin
  /* параметры разбивки на страницы */
  nNUMB_LINES1 := nvl(nNUMB_LINES,0);
  if nNUMB_LINES1 < 0 then
    p_exception( 0, 'Максимальное количество строк на остальных страницах не может быть отрицательным.' );
  end if;
  nNUMB_LINES_FIRST1 := nvl(nNUMB_LINES_FIRST,0);
  if nNUMB_LINES_FIRST1 < 0 then
    p_exception( 0, 'Количество строк на первой странице не может быть отрицательным.' );
  end if;
  nNUMB_LINES_LAST1 := nvl(nNUMB_LINES_LAST,0);
  if nNUMB_LINES_LAST1 < 0 then
    p_exception( 0, 'Максимальное количество строк на последней странице не может быть отрицательным.' );
  end if;
  if nNUMB_LINES1 = 0 and nNUMB_LINES_LAST1 = 0 then
    /* Не разделять на страницы */
    nDIVPAGE := 0;
  else
    nDIVPAGE := 1;
    if nNUMB_LINES1 = 0 then
      nNUMB_LINES1 := nNUMB_LINES_LAST1;
    end if;
  end if;

  /* пролог */
  prsg_excel.prepare;

  /* Лист1 */
  /* копирование листа */
  prsg_excel.sheet_copy( ssheet_name_from => SHEET1, ssheet_name_to => nIDENT);
  /* установка текущего рабочего листа */
  prsg_excel.sheet_select( ssheet_name =>  nIDENT);
  /* Шапка */
  prsg_excel.line_describe( sline_name => SH1_HEAD );
  prsg_excel.line_cell_describe( sline_name => SH1_HEAD, scell_name => SH1_PAGE2 );
  prsg_excel.line_describe( sline_name => SH1_LAST_PAGE );

  /* Описание ячеек строки */
  prsg_excel.line_describe( sline_name => SH1_LINE1 );
  for Idx in 20 .. 40 loop
    prsg_excel.line_cell_describe( sline_name => SH1_LINE1, scell_name => scell||lpad(to_char(Idx), 4, '0') );
  end loop;

  /* Описание ячеек заголовка */
  for Idx in 1 .. 19 loop
    prsg_excel.cell_describe(scell||lpad(to_char(Idx), 4, '0'));
  end loop;

  /* Описание ячеек подписной части */
  for Idx in 60 .. 99 loop
    prsg_excel.cell_describe( scell_name => scell||lpad(to_char(Idx), 4, '0') );
  end loop;

  /* Строка Итого */
  /*prsg_excel.line_describe( SH1_LINE_ITOG );*/
  /* Строка Всего по накладной */
  /*prsg_excel.line_describe( 'SH1_LINE_ALL' );*/

  /* RN документа */
  begin
    select document into rDoc.nrn from selectlist where ident = nIDENT;
  exception
    when no_data_found then
      p_exception(0, 'Не найден документ для печати в разделе <%s>.', f_unitlist_getname(sunitcode => sUNITCODE) );
    when too_many_rows then
      p_exception(0, 'Отмечено больше одного документа для печати в разделе <%s>.', f_unitlist_getname(sunitcode => sUNITCODE) );
    when others then
      p_exception(0, 'Неопределённая ситуация при определении документа для печати в разделе <%s>.', f_unitlist_getname(sunitcode => sUNITCODE) );
  end;

  /* Считывание записи документа */
  rDoc := usr_pkg_document.get_base_values( nflagsmart => 0
                                           ,nrn        => rDoc.nrn
                                           ,ncompany   => nCOMPANY
                                           ,sunitcode  => sUNITCODE );
  /* Входные документы */
  rAccDoc.nrn := f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                               ,sout_unitcode => sUNITCODE
                                               ,nout_document => rDoc.nrn
                                               ,sin_unitcode  => sAccUnitCode 
                                               ,ntotal_depth  => 5 );
  rAccDoc := usr_pkg_document.get_base_values( nflagsmart => 1
                                              ,nrn        => rAccDoc.nrn
                                              ,ncompany   => rAccDoc.ncompany
                                              ,sunitcode  => sAccUnitCode );
  /* Склад-отправитель */
  rStore := udo_pkg_get.row_store(nrn => rDoc.nstore);
  if rStore.department is not null then
    /* Подразделение-отправитель */
    rSubDiv := usr_pkg_ins_department.ins_department_get(nrn => rStore.department);
  end if;
  /* МОЛ-отправитель */
  if rDoc.nmol is not null then
    rMOLAgn := usr_pkg_agnlist.agnlist_get(nrn => rDoc.nmol);
  end if;

  /* Склад-получатель */
  /* если печать из расходных накладных в подразделения */
  if sUNITCODE = 'GoodsTransInvoicesToDepts' then
    rIn_Store := udo_pkg_get.row_store(nrn => rDoc.nin_store);
  end if;
  /* Подразделение-получатель */
  if rIn_Store.department is not null then
    rIn_SubDiv := usr_pkg_ins_department.ins_department_get(nrn => rIn_Store.department);
  end if;

  /* Лицевой счёт */
  if rDoc.nfaceacc is not null then 
    rFaceAcc := usr_pkg_faceacc.faceacc_get(nrn => rDoc.nfaceacc);
  end if;

  /* Контрагент юр.лица продавца */
  find_jurpersons_all(nflag_smart  => 0
                     ,nflag_option => 0
                     ,ncompany     => rDoc.ncompany
                     ,scode        => null
                     ,nrn          => rDoc.njur_pers
                     ,njrn         => nNumber
                     ,sjcode       => sVarchar
                     ,sjname       => sVarchar
                     ,njagent      => rSellerAgn.rn
                     ,sjagent      => sVarchar);

  /* Определение договора, этапа */
  if rFaceAcc.rn is not null then 
    find_contracts_faceacc(nflag_smart  => 1
                          ,ncompany     => rFaceAcc.company
                          ,nfaceacc     => rFaceAcc.rn
                          ,sfaceacc     => null
                          ,ncontract    => null
                          ,ncontractout => rContracts.rn
                          ,sdoc_type    => sVarchar
                          ,sdoc_pref    => sVarchar
                          ,sdoc_numb    => sVarchar
                          ,ddoc_date    => dDate
                          ,nstage       => rStages.rn
                          ,sstagenumb   => sVarchar
                          ,sfaceaccout  => sVarchar);
  end if;
  /* Если договор найден */
  if rContracts.rn is not null then
    /* Считывание договора, этапа */
    rContracts := usr_pkg_contracts.contracts_get(nrn => rContracts.rn, nflag_smart => 0);
    rStages    := usr_pkg_contracts.stages_get(nrn => rStages.rn, nflag_smart => 0);
    /* ИГК */
    if rContracts.govcntrid is not null then
      rGovCntrId := udo_pkg_get.row_govcntrid(nrn => rContracts.govcntrid, nsmart => 0);
    end if;
    /* Количество этапов в договоре */
    select count(*) into nStagesCount from stages where prn = rContracts.rn;
  end if;

  /* Считывание записи юр.лица */
  rSellerAgn := usr_pkg_agnlist.agnlist_get(nrn => rSellerAgn.rn);
  /* Реквизиты юр.лица  */
  /* родительского документа */
  if rAccDoc.njur_pers_acc is not null then
    rSellerAcc := usr_pkg_agnlist.agnacc_get(nrn => rAccDoc.njur_pers_acc);
  /* из этапа договора */
  elsif rStages.jur_acc is not null then
    rSellerAcc := usr_pkg_agnlist.agnacc_get(nrn => rStages.jur_acc);
  end if;

  /* Раздел печати */
  case sUNITCODE 
    /* Расходные накладные в подразедления */
    when 'GoodsTransInvoicesToDepts' then
      /* Считывание записи контрагента из контрагента склада-получателя */
      rPayerAgn := usr_pkg_agnlist.agnlist_get(nrn => rIn_Store.agent);
    /* Расходные накладные потребителям */
    when 'GoodsTransInvoicesToConsumers' then
      /* Считывание записи контрагента документа */
      rPayerAgn := usr_pkg_agnlist.agnlist_get(nrn => rDoc.nagent);
  else
    null;
  end case;    

  /* Реквизиты контрагента  */
  /* из родительского документа */
  if rAccDoc.nagnacc is not null then
    rPayerAcc := usr_pkg_agnlist.agnacc_get(nrn => rAccDoc.nagnacc);
  /* из лицевого счёта */
  elsif rFaceAcc.agnacc is not null then
    rPayerAcc := usr_pkg_agnlist.agnacc_get(nrn => rFaceAcc.agnacc);
  end if;

  /* Грузоотправитель равен продавцу */
  rShipperAgn := rSellerAgn;
  rShipperAcc := rSellerAcc;

  /* Грузополучатель равен покупателю */
  rAgnFiFoAgn := rPayerAgn;
  rAgnFiFoAcc := rPayerAcc;

  /* Ответственный за оформление */
  if rDoc.nacc_agent is not null then
    rAccAgn := usr_pkg_agnlist.agnlist_get(nrn => rDoc.nacc_agent);
  end if;

  /* ЗАПИСЬ ЗНАЧЕНИЙ */

  /* Заголовок */
  /* Организация */
  prsg_excel.cell_value_write( scell_name => scell||'0006', scell_value => usr_pkg_agnlist.agnlist_get_str_details( nflagsmart  => 1
                                                                                                                   ,ragn        => rSellerAgn
                                                                                                                   ,ragnacc     => rSellerAcc
                                                                                                                   ,ddate       => rDoc.ddate
                                                                                                                   ,sparam_list => '1;2') );
  /* Отправитель. Структурное подразделение */
  prsg_excel.cell_value_write(scell_name =>  scell||'0003', scell_value => nvl( rSubDiv.name, rStore.azs_name ) );

  /* Кому */
  prsg_excel.cell_value_write( scell_name => scell||'0004', scell_value => usr_pkg_agnlist.agnlist_get_str_details( nflagsmart  => 1
                                                                                                                   ,ragn        => rPayerAgn
                                                                                                                   ,ragnacc     => rPayerAcc
                                                                                                                   ,ddate       => rDoc.ddate
                                                                                                                   ,sparam_list => '1;2') );
  /* Основание */
  prsg_excel.cell_value_write( scell_name => scell||'0010', scell_value => rDoc.snote );

  /* Основание номер */
  /*prsg_excel.cell_value_write( _s0011, c.accnumb);*/
  /* Основание дата */
  /*prsg_excel.cell_value_write( _s0014, to_char(c.ACCDATE,'DD.MM.YYYY'));*/

  /* Номер накладной */
  prsg_excel.cell_value_write( scell_name => scell||'0012', scell_value => trim(rDoc.snumber) );
  /* Дата накладной */
  prsg_excel.cell_value_write( scell_name =>  scell||'0013', scell_value => to_char(rDoc.ddate, 'dd.mm.yyyy'));

  /* Таблица */
  /* Шапка */
  iLINE := prsg_excel.line_append( sline_name => SH1_HEAD );
  /* Если есть разбивка на страницы */
  if nDIVPAGE = 1 then
    /* Номер строки */
    nNUMB_DATA_LINE := 1;
    /* Номер страницы */
    nNUMB_DATA_PAGE := 1;
    /* Номер строки на странице */
    nNUMB_LINES_PAGE := 1;
  end if;

  /* Строка */
  /* По спецификациям */
  /* Расходные накладные на отпуск в подразделения */
  for c in ( 
            select dnm.nomen_name      as sNomen_Name
                  ,dnm.nomen_type      as nNomen_Type
                  ,nm.modif_code       as sModif_Code
                  ,nm.modif_name       as sModif_Name
                  ,t.pricemeas         as nPrice_Meas
                  ,0                   as nDiscount
                  ,mm.meas_mnemo       as sMeas_Main
                  ,am.meas_mnemo       as sMeas_Alt
                  ,null                as sMeas_Pack
                  ,mm.code_okei        as sMeas_Main_OKEI
                  ,am.code_okei        as sMeas_Alt_OKEI
                  ,null                as sMeas_Pack_OKEI
                  ,null                as sModifPack
                  ,t.note                     as sNote
                  ,nvl(dnm.tax_group, 502994) as tax_group
                  ,f_get_taxis_value( nflag_smart => 1
                                    , ncompany    => t.company
                                    , ntax_group  => nvl(dnm.tax_group, 502994)
                                    , ddate       => rDoc.ddate
                                    , nkind       => 1 ) as nTax_Value
                  ,round(t.summwithnds / t.quant, 2) /* для разделения спецификаций по ценам расчитываем её от суммы и округляем */
                  ,listagg(usr_pkg_rlarticles.rlarticles_get_short_numb(snumb => ra.code), ';') within group (order by ra.code)                             as sArticle_List
                  ,listagg(gp.sernumb, ';') within group (order by gp.sernumb)                                                                              as sSernumb_List
                  ,sum(t.quant)                                               as nQuant
                  ,sum(t.quantalt)                                            as nQuant_Alt
                  ,0                                                          as nQuant_Pack
                  ,decode(nvl(nPRINT_SUMMS, 0), 1, sum(t.summwithnds), 0, 0)  as nSumm_With_NDS 
              from transinvdeptspecs  t
                  ,nommodif           nm
                  ,dicnomns           dnm
                  ,dicmunts           mm
                  ,dicmunts           am
                  ,rlarticles         ra
                  ,goodsparties       gp
             where sUNITCODE      = 'GoodsTransInvoicesToDepts'
               and t.prn          = rDoc.nrn
               and t.nommodif     = nm.rn
               and nm.prn         = dnm.rn         
               and dnm.umeas_main = mm.rn
               and dnm.umeas_alt  = am.rn(+)
               and t.article      = ra.rn(+)
               and t.goodsparty   = gp.rn(+)
            group by dnm.nomen_name  
                    ,dnm.nomen_type    
                    ,nm.modif_code     
                    ,nm.modif_name     
                    ,t.pricemeas       
                    ,0                 
                    ,mm.meas_mnemo     
                    ,am.meas_mnemo     
                    ,null              
                    ,mm.code_okei      
                    ,am.code_okei      
                    ,null              
                    ,null              
                    ,t.note                    
                    ,nvl(dnm.tax_group, 502994)
                    ,f_get_taxis_value( nflag_smart => 1
                                      , ncompany    => t.company
                                      , ntax_group  => nvl(dnm.tax_group, 502994)
                                      , ddate       => rDoc.ddate
                                      , nkind       => 1 ) 
                    ,round(t.summwithnds / t.quant, 2) 
            union
  /* Расходные накладные на отпуск в потребителям */
            select dnm.nomen_name      as sNomen_Name
                  ,dnm.nomen_type      as nNomen_Type
                  ,nm.modif_code       as sModif_Code
                  ,nm.modif_name       as sModif_Name
                  ,t.pricemeas         as nPrice_Meas
                  ,0                   as nDiscount
                  ,mm.meas_mnemo       as sMeas_Main
                  ,am.meas_mnemo       as sMeas_Alt
                  ,null                as sMeas_Pack
                  ,mm.code_okei        as sMeas_Main_OKEI
                  ,am.code_okei        as sMeas_Alt_OKEI
                  ,null                as sMeas_Pack_OKEI
                  ,null                as sModifPack
                  ,t.note                     as sNote
                  ,nvl(dnm.tax_group, 502994) as tax_group
                  ,f_get_taxis_value( nflag_smart => 1
                                    , ncompany    => t.company
                                    , ntax_group  => t.taxgr
                                    , ddate       => rDoc.ddate
                                    , nkind       => 1 ) as nTax_Value
                  ,round(t.summwithnds / t.quant, 2) /* для разделения спецификаций по ценам расчитываем её от суммы и округляем */
                  ,listagg(usr_pkg_rlarticles.rlarticles_get_short_numb(snumb => ra.code), ';') within group (order by ra.code)                             as sArticle_List
                  ,listagg(gp.sernumb, ';') within group (order by gp.sernumb)                                                                              as sSernumb_List
                  ,sum(t.quant)                                               as nQuant
                  ,sum(t.quantalt)                                            as nQuant_Alt
                  ,0                                                          as nQuant_Pack
                  ,decode(nvl(nPRINT_SUMMS, 0), 1, sum(t.summwithnds), 0, 0)  as nSumm_With_NDS 
              from transinvcustspecs  t
                  ,nommodif           nm
                  ,dicnomns           dnm
                  ,dicmunts           mm
                  ,dicmunts           am
                  ,rlarticles         ra
                  ,goodsparties       gp
             where sUNITCODE      = 'GoodsTransInvoicesToConsumers'
               and t.prn          = rDoc.nrn
               and t.nommodif     = nm.rn
               and nm.prn         = dnm.rn         
               and dnm.umeas_main = mm.rn
               and dnm.umeas_alt  = am.rn(+)
               and t.article      = ra.rn(+)
               and t.goodsparty   = gp.rn(+)
            group by dnm.nomen_name  
                    ,dnm.nomen_type    
                    ,nm.modif_code     
                    ,nm.modif_name     
                    ,t.pricemeas       
                    ,0                 
                    ,mm.meas_mnemo     
                    ,am.meas_mnemo     
                    ,null              
                    ,mm.code_okei      
                    ,am.code_okei      
                    ,null              
                    ,null              
                    ,t.note                    
                    ,nvl(dnm.tax_group, 502994)
                    ,f_get_taxis_value( nflag_smart => 1
                                      , ncompany    => t.company
                                      , ntax_group  => t.taxgr
                                      , ddate       => rDoc.ddate
                                      , nkind       => 1 ) 
                    ,round(t.summwithnds / t.quant, 2) 
          )
  loop
    /* Если есть разбивка на страницы */
    if nDIVPAGE = 1 then
      nNEWPAGE := 0;
      nITPAGE := 0;
      /* Если первая страница */
      if nNUMB_DATA_PAGE = 1 then
        /* Если на первой странице нет строк */
        if nNUMB_LINES_FIRST1 = 0 then
          nNEWPAGE := 1;
        else
          /* Переход на вторую страницу */
          if nNUMB_LINES_PAGE > nNUMB_LINES_FIRST1 then
            nNEWPAGE := 1;
            nITPAGE := 1;
          end if;
        end if;
      else
        /* Переход на следующую страницу */
        if nNUMB_LINES_PAGE >= nNUMB_LINES1 then
          nNEWPAGE := 1;
          nITPAGE := 1;
        end if;
      end if;
      /* Новая страница */
      if nNEWPAGE = 1 then
        /* Итоги на предыдущей странице */
        if nITPAGE = 1 then
          /* Строка Итого */
          /*iLINE := PRSG_EXCEL.LINE_APPEND( SH1_LINE_ITOG, SH1_LINE1 );
          if nPASK_IT <> 0 then
            PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0051',  0, iLINE, nPASK_IT );
          end if;
          if nQUANT_IT <> 0 then
            PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0052',  0, iLINE, nQUANT_IT );
          end if;
          if nSUMM_IT <> 0 then
            PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0053',  0, iLINE, nSUMM_IT );
          end if;
          if nNDS_IT <> 0 then
            PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0054',  0, iLINE, nNDS_IT );
          end if;
          if nSUMM_NDS_IT <> 0 then
            PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0055',  0, iLINE, nSUMM_NDS_IT );
          end if;*/
          nPASK_IT := 0;
          nQUANT_IT := 0;
          nSUMM_IT := 0;
          nNDS_IT := 0;
          nSUMM_NDS_IT := 0;
        end if;
        if nNUMB_DATA_PAGE = 1 and nNUMB_LINES_FIRST1 = 0 then
          prsg_excel.line_page_break(scurrent_line_name => SH1_HEAD);
        else
          iLINE := prsg_excel.line_continue( sline_name => SH1_HEAD );
          prsg_excel.line_page_break( scurrent_line_name => SH1_HEAD );
          if nNUMB_DATA_PAGE = 1 then
            prsg_excel.cell_value_write( scell_name => SH1_PAGE2,  icell_index_x => 0, icell_index_y => iLINE, scell_value => 'Оборотная сторона формы № М-15' );
          end if;
        end if;
        nNUMB_LINES_PAGE := 1;
        nNUMB_DATA_PAGE := nNUMB_DATA_PAGE + 1;
      else
        nNUMB_LINES_PAGE := nNUMB_LINES_PAGE + 1;
      end if;
      nNUMB_DATA_LINE := nNUMB_DATA_LINE + 1;
    end if;

    /* Строка таблицы */
    iLINE := prsg_excel.line_continue( sline_name => SH1_LINE1 );

    /* Номер пп */
    nREC_QUANT := nREC_QUANT + 1;
    /*prsg_excel.cell_value_write( scell_name => scell||'0020',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nREC_QUANT );*/

    /* Товар_наим */
    sTMP := strcombine( c.sNomen_Name, c.sNote, cr); /* примечание к спецификации */
    prsg_excel.cell_value_write( scell_name => scell||'0021',  icell_index_x => 0, icell_index_y => iLINE, scell_value => sTMP );

    /* Товар_код */
    if c.sArticle_List is null and c.sSernumb_List is null then
      p_exception(0, 'В спецификации не заполнены ни номер изделия, ни серия номенклатуры.%s%s'
                 ,scell||'0021' ||', кол-во: '||c.nQuant||', сумма: '||c.nSumm_With_NDS );
    else
      sTMP := null;
      sTMP := usr_pkg_common.get_list_distinct(slist => nvl( c.sArticle_List, c.sSernumb_List ));      
      sTMP := usr_pkg_common.make_period_from_list(slist => sTMP, slist_delim => ', ');
    end if;
    prsg_excel.cell_value_write( scell_name => scell||'0022',  icell_index_x => 0, icell_index_y => iLINE, scell_value => sTMP );

    /* Ед_изм_наим */
    if c.nPrice_Meas = 0 then
      sMEAS := c.sMeas_Main;
    elsif c.nPrice_Meas = 1 then
      sMEAS := c.sMeas_Alt;
    else
      sMEAS := c.sMeas_Pack;
    end if;
    prsg_excel.cell_value_write( scell_name => scell||'0023',  icell_index_x => 0, icell_index_y => iLINE, scell_value => sMEAS );

    /* Ед_изм_ОКЕИ */
    if c.nPrice_Meas = 0 then
      sMEAS := c.sMeas_Main_OKEI;
    elsif c.nPrice_Meas = 1 then
      sMEAS := c.sMeas_Alt_OKEI;
    else
      sMEAS := c.sMeas_Pack_OKEI;
    end if;
    prsg_excel.cell_value_write( scell_name => scell||'0024',  icell_index_x => 0, icell_index_y => iLINE, scell_value => sMEAS );

    /* Вид_упаковки */
    /*PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0025',  0, iLINE, c.sModifPack );*/
    /* Кол_в_месте */
    /*if nvl(c.nQuant_Pack,0) <> 0 then
      PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0026',  0, iLINE, c.nQuant_Pack );
    end if;*/

    /* Количество_мест */
    if c.nQuant_Pack is not null and c.nQuant_Pack <> 0 then
      nPASK_QUANT := c.nQuant / c.nQuant_Pack;
    else
      nPASK_QUANT := 0;
    end if;
    nPASK_QUANT := nvl(nPASK_QUANT ,0) ;
    if nPASK_QUANT <> 0 then
      null;
      /*PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0027',  0, iLINE, nPASK_QUANT );*/
    end if;
    nPASK_IT  := nPASK_IT + nPASK_QUANT;
    nPASK_ALL := nPASK_ALL + nPASK_QUANT;

    /* Количество */
    if c.nPrice_Meas = 0 then
      nQUANT := c.nQuant;
    elsif c.nPrice_Meas = 1 then
      nQUANT := c.nQuant_Alt;
    else
      nQUANT := nPASK_QUANT;
    end if;
    nQUANT := nvl(nQUANT,0);
    if nQUANT <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0028',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nQUANT );
    end if;
    nQUANT_IT  := nQUANT_IT + nQUANT;
    nQUANT_ALL := nQUANT_ALL + nQUANT;

    /* Расчёт сумм спецификации от поля Цена с НДС */
    pkg_dictaxis_calc.p_calculate_base( nflag_smart => 0
                                       ,ncompany    => rDoc.ncompany
                                       ,ddate       => rDoc.ddate
                                       ,nsumm_sign  => case sUNITCODE 
                                                         when 'GoodsTransInvoicesToDepts'     then 0
                                                         when 'GoodsTransInvoicesToConsumers' then 1
                                                       end
                                       ,ninsumm     => c.nSumm_With_NDS
                                       ,ntaxgr      => c.tax_group
                                       ,nquant      => 1
                                       ,nncp_sign   => 1 );
    /* Цена от суммы без НДС */ 
    If nQUANT <> 0 then
      nPRICE := pkg_dictaxis_calc.f_get_value(nident => 0) * /*c.CURBASE*/ 1 / nQUANT; 
    else
      nPRICE := pkg_dictaxis_calc.f_get_value(nident => 0) * /*c.CURBASE*/ 1 *(1 - (0 + c.nDiscount) / 100); 
    end if;
    nPRICE := nvl(nPRICE, 0);
    if nPRICE <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0029',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nPRICE );
    end if;

    /* Сумма без НДС */
    nSUMM := pkg_dictaxis_calc.f_get_value(nident => 0) * /*c.CURBASE*/ 1;
    nSUMM := nvl(nSUMM,0);
    if nSUMM <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0030',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nSUMM );
    end if;
    nSUMM_IT := nSUMM_IT + nSUMM;
    nSUMM_ALL := nSUMM_ALL + nSUMM;

    /* НДС_Ставка */
    if nvl(c.nTax_Value,0) <> 0 then
      null;
      /*PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0031',  0, iLINE, c.nTax_Value );*/
    end if;

    /* НДС_Сумма */
    nNDS := pkg_dictaxis_calc.f_get_value(nident => 8) * /*c.CURBASE*/ 1;
    nNDS := nvl(nNDS,0);
    if nNDS <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0032',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nNDS );
    end if;
    nNDS_IT := nNDS_IT + nNDS;
    nNDS_ALL := nNDS_ALL + nNDS;

    /* Сумма_с_НДС */
    nSUMM_NDS := pkg_dictaxis_calc.f_get_value(nident => 2) * /*c.CURBASE*/ 1;
    nSUMM_NDS := nvl(nSUMM_NDS,0);
    if nSUMM_NDS <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0033',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nSUMM_NDS );
    end if;
    nSUMM_NDS_IT := nSUMM_NDS_IT + nSUMM_NDS;
    nSUMM_NDS_ALL := nSUMM_NDS_ALL + nSUMM_NDS;

  end loop;

  nNEWPAGE := 0;
  if nNUMB_DATA_PAGE = 1 then
    nNEWPAGE := 1;
  else
    if nNUMB_LINES_PAGE > nNUMB_LINES_LAST1 then
      nNEWPAGE := 1;
    end if;
  end if;
  if nNEWPAGE != 1 then
    prsg_excel.line_page_break(scurrent_line_name => SH1_LAST_PAGE);
  end if;

  if nREC_QUANT > 0 then
    /* Итоги таблицы */
    /* Строка Итого */
    /*iLINE := PRSG_EXCEL.LINE_APPEND( SH1_LINE_ITOG, SH1_LINE1 );
    if nPASK_IT <> 0 then
      PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0051',  0, iLINE, nPASK_IT );
    end if;
    if nQUANT_IT <> 0 then
      PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0052',  0, iLINE, nQUANT_IT );
    end if;
    if nSUMM_IT <> 0 then
      PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0053',  0, iLINE, nSUMM_IT );
    end if;
    if nNDS_IT <> 0 then
      PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0054',  0, iLINE, nNDS_IT );
    end if;
    if nSUMM_NDS_IT <> 0 then
      PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0055',  0, iLINE, nSUMM_NDS_IT );
    end if;*/
    /* Строка Всего по накладной */
    /*iLINE := PRSG_EXCEL.LINE_APPEND( SH1_LINE_ALL );
    if nPASK_ALL <> 0 then
      PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0057',  0, iLINE, nPASK_ALL );
    end if;
    if nQUANT_ALL <> 0 then
      PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0058',  0, iLINE, nQUANT_ALL );
    end if;
    if nSUMM_ALL <> 0 then
      PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0059',  0, iLINE, nSUMM_ALL );
    end if;*/
    if nNDS_ALL <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0060',  scell_value => nNDS_ALL );
    end if;

    /*if nSUMM_NDS_ALL <> 0 then
      PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0061',  0, iLINE, nSUMM_NDS_ALL );
    end if;*/
    /* Итоги */
    /* Порядковых номеров */
    prsg_excel.cell_value_write( scell_name => scell||'0062', scell_value => num2text(nREC_QUANT) );
    /* Всего мест */
    /*PRSG_EXCEL.CELL_VALUE_WRITE( scell||'0063', NUM2TEXT(nPASK_ALL));*/
    /* Всего отпущено */
    prsg_excel.cell_value_write( scell_name => scell||'0064' 
                               , scell_value => f_money_sum_str(ncompany => rDoc.ncompany
                                                               ,nvalue   => nSUMM_NDS_ALL
                                                               ,siso     => get_curnames_iso_id(nflag_smart => 1, nrn => rDoc.ncurrency)) );

    prsg_excel.line_delete( sline_name => SH1_LINE1 );
  end if;
  prsg_excel.line_delete( sline_name => SH1_HEAD );

  /* Подписи */
  PRSG_EXCEL.CELL_VALUE_WRITE( scell_name => scell||'0080', scell_value => rAccAgn.emppost );
  PRSG_EXCEL.CELL_VALUE_WRITE( scell_name => scell||'0081', scell_value => rAccAgn.agnabbr );
  PRSG_EXCEL.CELL_VALUE_WRITE( scell_name => scell||'0082', scell_value => prsg_rptf.smanager(nagn_rn => rSellerAgn.rn, ddate => rDoc.dDATE, nposition => 0) );
  prsg_excel.cell_value_write( scell_name => scell||'0088', scell_value => rMOLAgn.emppost);
  prsg_excel.cell_value_write( scell_name => scell||'0089', scell_value => rMOLAgn.agnabbr);

  prsg_excel.execute_macros( smacros_name => 'SortSheets' );
  prsg_excel.sheet_delete( ssheet_name => SHEET1);

end;
/
