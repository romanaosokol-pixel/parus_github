create or replace procedure usr_p_rep_inv_19
(
 nCOMPANY            in number
,nIDENT              in number
,sUNITCODE           in varchar2
,nNUMB_LINES_FIRST   in number    /* Количество строк на первой странице */
,nNUMB_LINES_LAST    in number    /* Максимальное количество строк на последней странице */
,nNUMB_LINES         in number    /* Максимальное количество строк на остальных страницах */
)
as
  rDoc                usr_pkg_pub_const.tdoc_base_values_rec;
  rAccDoc             usr_pkg_pub_const.tdoc_base_values_rec;
  sAccUnitCode        unitlist.unitcode%type := case sUNITCODE
                                                  when 'ReturnInvoicesToSuppliers'     then 'PaymentAccountsIn'
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
  rAgnFiFoAgn         agnlist%rowtype;
  rAgnFiFoAcc         agnacc%rowtype;
  rStages             stages%rowtype;
  nStagesCount        pkg_std.tnumber := 0;
  rContracts          contracts%rowtype;
  rMOLAgn             agnlist%rowtype;
  rAccAgn             agnlist%rowtype;
  rSubDiv             ins_department%rowtype;
  rGovCntrId          govcntrid%rowtype;
  nClnEvents          pkg_std.tref;
  rClnEvents          clnevents%rowtype;
  rClnPersons         clnpersons%rowtype;

  nNumber       pkg_std.tnumber;
  sVarchar      pkg_std.tstring;
  dDate         date;

  scell           constant varchar2(2) := '_s';

  /* Лист */
  SHEET1          constant PKG_STD.tSTRING := 'Лист_1';
  /* Шапка */
  SH1_HEAD        constant PKG_STD.tSTRING := 'Шапка';
  SH1_PAGE2       constant PKG_STD.tSTRING := 'Лист_2';   /* 2-я страница формы № ИНВ-19 */
  SH1_LAST_PAGE   constant PKG_STD.tSTRING := 'СтрСтр';   /* строка под первой таблицей */
  SH1_PAGE_NUM    constant PKG_STD.tSTRING := 'Номер_страницы';   
  /* Строка */
  SH1_LINE1       constant PKG_STD.tSTRING := 'Строка_1';
  /* Строка Итого */
  SH1_LINE_ITOG   constant PKG_STD.tSTRING := 'Строка_Итого';
  /* Строка Всего по накладной */
  SH1_LINE_ALL    constant PKG_STD.tSTRING := 'Строка_Всего';

  /* Переменные */
  sTMP            PKG_STD.tSTRING;
  iLINE           integer;
  nPRICE          PKG_STD.tSUMM;
  sMEAS           PKG_STD.tSTRING;
  nQUANT          PKG_STD.tQUANT;
  nQUANT_IT       PKG_STD.tSQUANT := 0;
  nQUANT_ALL      PKG_STD.tSQUANT := 0;
  nLoss_Quant     PKG_STD.tQUANT;
  nLoss_Quant_IT  PKG_STD.tSQUANT := 0;
  nLoss_Quant_ALL PKG_STD.tSQUANT := 0;
  nPASK_QUANT     PKG_STD.tSQUANT;
  nREC_QUANT      PKG_STD.tNUMBER := 0;
  nPASK_ALL       PKG_STD.tNUMBER := 0;
  nPASK_IT        PKG_STD.tSQUANT := 0;

  nSUMM              PKG_STD.tSUMM;
  nNDS               PKG_STD.tSUMM;
  nSUMM_NDS          PKG_STD.tSUMM;
  nSUMM_IT           PKG_STD.tSUMM := 0;
  nSUMM_ALL          PKG_STD.tSUMM := 0;
  nNDS_IT            PKG_STD.tSUMM := 0;
  nNDS_ALL           PKG_STD.tSUMM := 0;
  nSUMM_NDS_IT       PKG_STD.tSUMM := 0;
  nSUMM_NDS_ALL      PKG_STD.tSUMM := 0;
  nLoss_SUMM         PKG_STD.tSUMM;
  nLoss_NDS          PKG_STD.tSUMM;
  nLoss_SUMM_NDS     PKG_STD.tSUMM;
  nLoss_SUMM_IT      PKG_STD.tSUMM := 0;
  nLoss_SUMM_ALL     PKG_STD.tSUMM := 0;
  nLoss_NDS_IT       PKG_STD.tSUMM := 0;
  nLoss_NDS_ALL      PKG_STD.tSUMM := 0;
  nLoss_SUMM_NDS_IT  PKG_STD.tSUMM := 0;
  nLoss_SUMM_NDS_ALL PKG_STD.tSUMM := 0;
  nAccSum            PKG_STD.tSUMM := 0;
  nFactSum           PKG_STD.tSUMM := 0;

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

  /* Пролог */
  prsg_excel.prepare;

  /* Лист1 */
  /* копирование листа */
  prsg_excel.sheet_copy( ssheet_name_from => SHEET1, ssheet_name_to => nIDENT );
  /* установка текущего рабочего листа */
  prsg_excel.sheet_select( ssheet_name => nIDENT );

  /* Таблица */
  /* Шапка */
  prsg_excel.line_describe( sline_name => SH1_HEAD ); /* 'Шапка' */
  prsg_excel.line_cell_describe( sline_name => SH1_HEAD, scell_name => SH1_PAGE2 );
  prsg_excel.line_cell_describe( sline_name => SH1_HEAD, scell_name => SH1_PAGE_NUM );

  /* Описание ячеек строки "Строка_1" */
  prsg_excel.line_describe( sline_name => SH1_LINE1 );
  for Idx in 16 .. 32 loop
    prsg_excel.line_cell_describe( sline_name => SH1_LINE1, scell_name => scell||lpad(to_char(Idx), 4, '0') );
  end loop;

  /* Строка Итого */
  prsg_excel.line_describe( sline_name => SH1_LINE_ITOG );
  for Idx in 33 .. 40 loop
    prsg_excel.line_cell_describe( sline_name => SH1_LINE_ITOG, scell_name => scell||lpad(to_char(Idx), 4, '0') );
  end loop;

  /* Строка Всего по накладной */
  prsg_excel.line_describe( sline_name => SH1_LINE_ALL );
  for Idx in 70 .. 73 loop
    prsg_excel.line_cell_describe( sline_name => SH1_LINE_ALL, scell_name => scell||lpad(to_char(Idx), 4, '0') );
  end loop;

  /* Описание ячеек заголовка */
  for Idx in 1 .. 15 loop
    prsg_excel.cell_describe(scell||lpad(to_char(Idx), 4, '0'));
  end loop;
  for Idx in 61 .. 61 loop
    prsg_excel.cell_describe(scell||lpad(to_char(Idx), 4, '0'));
  end loop;

  /* Описание ячеек подписной части */
  for Idx in 41 .. 60 loop
    prsg_excel.cell_describe( scell_name => scell||lpad(to_char(Idx), 4, '0') );
  end loop;


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
                                               ,sin_unitcode  => sAccUnitCode );
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

  /* Лицевой счёт */
  if rDoc.nfaceacc is not null then
    rFaceAcc := usr_pkg_faceacc.faceacc_get(nrn => rDoc.nfaceacc);
  end if;

  /* Контрагент юр.лица продавца */
  if rDoc.njur_pers is null then
    find_jurpersons_main(nflag_smart => 0
                        ,ncompany    => rDoc.ncompany
                        ,sjur_pers   => sVarchar
                        ,njur_pers   => rDoc.njur_pers);
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
  end if;
  /* Определение договора, этапа */
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

  /* Считывание записи контрагента */
  if rDoc.nagent is not null then
    rPayerAgn := usr_pkg_agnlist.agnlist_get(nrn => rDoc.nagent);
  end if;
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
  /* если заполнен в родительском документе */
  if rAccDoc.nacc_agent is not null then
    rAccAgn := usr_pkg_agnlist.agnlist_get(nrn => rAccDoc.nacc_agent);
  /* если НЕ заполнен в родительском документе */
  else
    /* RN события */
    nClnEvents := usr_pkg_document.get_clnevents( nflagsmart => 1, nrn => rAccDoc.nrn );
    /* если найден RN события */
    if nClnEvents is not null then
      /* считывание события */
      rClnEvents  := usr_pkg_clnevents.clnevents_get(nrn => nClnEvents);
      /* считывание сотрудника */
      rClnPersons := udo_pkg_get.row_clnpersons(nrn => rClnEvents.init_person);
      /* считывание контрагента */
      rAccAgn     := usr_pkg_agnlist.agnlist_get(nrn => rClnPersons.pers_agent);
    end if;
  end if;

  /* ЗАПИСЬ ЗНАЧЕНИЙ */

  /* Заголовок */
  /* Организация */
  prsg_excel.cell_value_write( scell_name => scell||'0001', scell_value => usr_pkg_agnlist.agnlist_get_str_details(nflagsmart  => 1
                                                                                                                  ,ragn        => rShipperAgn
                                                                                                                  ,ragnacc     => rShipperAcc
                                                                                                                  ,ddate       => rDoc.ddate
                                                                                                                  ,sparam_list => '1;2;3') );
  /* по ОКПО */
  prsg_excel.cell_value_write( scell_name => scell||'0002', scell_value => rShipperAgn.orgcode );
  /* Структурное подразделение */
  prsg_excel.cell_value_write(scell_name =>  scell||'0003', scell_value => nvl( rSubDiv.name, rStore.azs_name ) );
  /* Грузополучатель */
  prsg_excel.cell_value_write( scell_name => scell||'0004', scell_value => usr_pkg_agnlist.agnlist_get_str_details(nflagsmart  => 1
                                                                                                                 ,ragn        => rAgnFiFoAgn
                                                                                                                 ,ragnacc     => rAgnFiFoAcc
                                                                                                                 ,ddate       => rDoc.ddate
                                                                                                                 ,sparam_list => '1;2;3') );
  /* Основание */
  /* Основание номер */
  /*prsg_excel.cell_value_write( scell_name => scell||'0011', scell_value =>  null );*/
  /* Основание дата */
  /*prsg_excel.cell_value_write( scell_name => scell||'0012', scell_value => null );*/
  /* Номер */
  prsg_excel.cell_value_write( scell_name => scell||'0010', scell_value => pkg_document.make_number( sdoc_pref => rDoc.sprefix, sdoc_numb => rDoc.snumber ));
  /* Дата */
  prsg_excel.cell_value_write( scell_name => scell||'0011', scell_value => to_char(rDoc.ddate, 'dd.mm.yyyy'));
  /* Должность */
  prsg_excel.cell_value_write( scell_name => scell||'0012', scell_value => rMOLAgn.emppost);
  /* ФИО */
  prsg_excel.cell_value_write( scell_name => scell||'0013', scell_value => rMOLAgn.agnabbr);


  /* Таблица */
  /* Шапка */
  iLINE := prsg_excel.line_append( sline_name => SH1_HEAD );
  prsg_excel.cell_value_write( scell_name => SH1_PAGE2   ,  icell_index_x => 0, icell_index_y => iLINE, scell_value => '2-я страница формы № ИНВ-19');
  prsg_excel.cell_value_write( scell_name => SH1_PAGE_NUM,  icell_index_x => 0, icell_index_y => iLINE, scell_value => 'Стр. '||usr_f_n2si(nvl(nNUMB_DATA_PAGE, 0)+1));

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
  /* Расходные накладные на отпуск потребителям */
  for c in (
            /* Ведомости инвентаризации */
            select dnm.nomen_code     as sNomen_Code
                  ,dnm.nomen_name     as sNomen_Name
                  ,dnm.nomen_type     as nNomen_Type
                  ,nm.modif_code      as sModif_Code
                  ,nm.modif_name      as sModif_Name
                  ,t.pricemeas        as nPrice_Meas
                  ,0                  as nDiscount
                  ,dmu1.meas_mnemo    as sMeas_Main
                  ,dmu2.meas_mnemo    as sMeas_Alt
                  ,dmu3.meas_mnemo    as sMeas_Pack
                  ,dmu1.code_okei     as sMeas_Main_OKEI
                  ,dmu2.code_okei     as sMeas_Alt_OKEI
                  ,dmu3.code_okei     as sMeas_Pack_OKEI
                  ,np.code            as sModifPack
                  ,t.note             as sNote
                  ,null               as nTax_Group
                  ,null               as nTax_Value
                  ,ra.code            as sArticle_List
                  ,gp.sernumb         as sSernumb_List
                  ,case when t.accquant - t.factquant < 0 
                     then ( t.factquant - t.accquant ) 
                     else 0 
                   end                as nIncome_Quant
                  ,case when t.accquant - t.factquant > 0 
                     then ( t.accquant - t.factquant )
                     else 0 
                   end                as nLoss_Quant
                  ,t.factquantalt     as nQuant_Alt
                  ,np.quant           as nQuant_Pack
                  ,t.accsum 
                  ,t.factsum
                  ,t.accquant 
                  ,t.factquant
                  ,t.price
              from rlinvsheetspec    t
                  ,dicnomns          dnm
                  ,nommodif          nm
                  ,dicmunts          dmu1
                  ,dicmunts          dmu2
                  ,nomnpack          np
                  ,nomnmodifpack     nmp
                  ,dicmunts          dmu3
                  ,rlarticles        ra
                  ,goodsparties      gp
                  ,goodssupply       gs
             where sunitcode        = 'RealizationInventorySheet'
               and t.prn            = rDoc.nrn
               and t.nommodif       = nm.rn
               and nm.prn           = dnm.rn
               and t.nommodifpack   = nmp.rn(+)
               and nmp.nomenpack    = np.rn(+)
               and dnm.umeas_main   = dmu1.rn
               and dnm.umeas_alt    = dmu2.rn(+)
               and np.umeas         = dmu3.rn(+)
               and t.article        = ra.rn(+)
               and t.goodssupply    = gs.rn(+)
               and gs.prn           = gp.rn(+)
               and t.accquant      != t.factquant
           )
  loop
    nSUMM := 0;
    nLoss_SUMM := 0;
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
        /*if nITPAGE = 1 then
          \* Строка Итого *\
          iLINE := prsg_excel.line_append( sline_name => SH1_LINE_ITOG, scurrent_line_name => SH1_LINE1 );
\*          if nPASK_IT <> 0 then
            prsg_excel.cell_value_write( scell_name => scell||'0050',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nPASK_IT );
          end if;*\
          if nQUANT_IT <> 0 then
            prsg_excel.cell_value_write( scell_name => scell||'0033', icell_index_x => 0, icell_index_y => iLINE, scell_value => nQUANT_IT );
          end if;
          if nSUMM_IT <> 0 then
            prsg_excel.cell_value_write( scell_name => scell||'0034',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nSUMM_IT );
          end if;
          if nLoss_Quant_IT <> 0 then
           prsg_excel.cell_value_write( scell_name => scell||'0035',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nLoss_QUANT_IT );
          end if;
          if nLoss_SUMM_IT <> 0 then
            prsg_excel.cell_value_write( scell_name => scell||'0036',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nLoss_SUMM_IT );
          end if;
          nPASK_IT     := 0;
          nQUANT_IT    := 0;
          nSUMM_IT     := 0;
          nNDS_IT      := 0;
          nSUMM_NDS_IT := 0;
          nLoss_QUANT_IT    := 0;
          nLoss_SUMM_IT     := 0;
          nLoss_NDS_IT      := 0;
          nLoss_SUMM_NDS_IT := 0;
        end if;*/
        if nNUMB_DATA_PAGE = 1 and nNUMB_LINES_FIRST1 = 0 then
          prsg_excel.line_page_break(scurrent_line_name => SH1_HEAD);
        else
          iLINE := prsg_excel.line_continue( sline_name => SH1_HEAD );
          prsg_excel.line_page_break( scurrent_line_name => SH1_HEAD );
          /*if nNUMB_DATA_PAGE = 1 then*/
            /*prsg_excel.cell_value_write( scell_name => SH1_PAGE2,  icell_index_x => 0, icell_index_y => iLINE, scell_value => '2-я страница формы № ИНВ-19' ||' = '|| nNUMB_DATA_PAGE ||' = '||  nNUMB_LINES_FIRST1);*/
            prsg_excel.cell_value_write( scell_name => SH1_PAGE_NUM,  icell_index_x => 0, icell_index_y => iLINE, scell_value => 'Стр. '||usr_f_n2si(nvl(nNUMB_DATA_PAGE, 0) +1));
          /*end if;*/
        end if;
        nNUMB_LINES_PAGE := 1;
        nNUMB_DATA_PAGE  := nNUMB_DATA_PAGE + 1;
      else
        nNUMB_LINES_PAGE := nNUMB_LINES_PAGE + 1;
      end if;
      nNUMB_DATA_LINE    := nNUMB_DATA_LINE + 1;
    end if;

    /* Строка таблицы */
    iLINE := prsg_excel.line_continue( sline_name => SH1_LINE1 );

    /* Номер пп */
    nREC_QUANT := nREC_QUANT + 1;
    prsg_excel.cell_value_write( scell_name => scell||'0016',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nREC_QUANT );

    /* Товар_наим */
    sTMP := strcombine( c.sNomen_Name, c.sNote, ' ');
    prsg_excel.cell_value_write( scell_name => scell||'0017',  icell_index_x =>  0, icell_index_y => iLINE, scell_value => sTMP );

    /* Товар_код */
    if c.sArticle_List is null and c.sSernumb_List is null then
      p_exception(0, 'В спецификации не заполнены ни номер изделия, ни серия.%s'
                 ,cr||c.sNomen_Code||', '||c.sModif_Code ||', кол-во: '||coalesce(c.nIncome_quant, c.nloss_quant)||', сумма: '||coalesce(c.accsum, c.factsum) );
    else
      sTMP := null;
      sTMP := usr_pkg_common.get_list_distinct(slist => nvl( c.sArticle_List, c.sSernumb_List ));
      sTMP := usr_pkg_common.make_period_from_list(slist => sTMP, slist_delim => ', ');
    end if;
    prsg_excel.cell_value_write( scell_name => scell||'0018',  icell_index_x => 0, icell_index_y => iLINE, scell_value => sTMP );

    /* Ед_изм_наим */
    if c.nPrice_Meas = 0 then
      sMEAS := c.sMeas_Main;
    elsif c.nPrice_Meas = 1 then
      sMEAS := c.sMeas_Alt;
    else
      sMEAS := c.sMeas_Pack;
    end if;
    prsg_excel.cell_value_write( scell_name => scell||'0020',  icell_index_x => 0, icell_index_y => iLINE, scell_value => sMEAS );

    /* Ед_изм_ОКЕИ */
    if c.nPrice_Meas = 0 then
      sMEAS := c.sMeas_Main_OKEI;
    elsif c.nPrice_Meas = 1 then
      sMEAS := c.sMeas_Alt_OKEI;
    else
      sMEAS := c.sMeas_Pack_OKEI;
    end if;
    prsg_excel.cell_value_write( scell_name => scell||'0019',  icell_index_x => 0, icell_index_y => iLINE, scell_value => sMEAS );

    /* Вид_упаковки */
    /*prsg_excel.cell_value_write( scell_name => scell||'0035',  icell_index_x => 0, icell_index_y => iLINE, scell_value => c.sModifPack );*/

    /* Кол_в_месте */
    /*if nvl(c.nQuant_Pack,0) <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0035',  icell_index_x => 0, icell_index_y => iLINE, scell_value => c.nQuant_Pack );
    end if;*/

    /* Количество_мест */
    /*nPASK_QUANT := c.nQuant;
    if nPASK_QUANT <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0037',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nPASK_QUANT );
    end if;
    nPASK_IT := nPASK_IT + nPASK_QUANT;
    nPASK_ALL := nPASK_ALL + nPASK_QUANT;*/

    /* Количество */
    if c.nPrice_Meas = 0 then
      nQUANT      := c.nIncome_quant;
      nLoss_QUANT := c.nLoss_Quant;
    elsif c.nPrice_Meas = 1 then
      nQUANT      := c.nQuant_Alt;
    else
      nQUANT := nPASK_QUANT;
    end if;

    nQUANT := nvl( nQUANT, 0 );
    if nQUANT <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0023',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nQUANT );
      /* Суммы */
      p_rlinvsheetspec_calc_sum(nflag_smart   => 0
                               ,ncompany      => rDoc.ncompany
                               ,snomen        => c.snomen_code
                               ,snommodif     => c.smodif_code
                               ,snommodifpack => null
                               ,nnommodifpack => null
                               ,naccquant     => c.accquant
                               ,naccquantalt  => null
                               ,nfactquant    => c.factquant
                               ,nfactquantalt => null
                               ,nmiscalc      => 0
                               ,nmiscalcalt   => null
                               ,nprice        => c.price
                               ,npricemeas    => c.nprice_meas
                               ,naccsum       => nAccSum
                               ,nfactsum      => nFactSum);
      /* Сумма Излишек */                               
      nSUMM := nFactSum - nAccSum;
    end if;
    nQUANT_IT := nQUANT_IT + nQUANT;
    nQUANT_ALL := nQUANT_ALL + nQUANT;

    nLoss_QUANT := nvl( nLoss_QUANT, 0 );
    if nLoss_QUANT <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0025',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nLoss_QUANT );
      /* Суммы */
      p_rlinvsheetspec_calc_sum(nflag_smart   => 0
                               ,ncompany      => rDoc.ncompany
                               ,snomen        => c.snomen_code
                               ,snommodif     => c.smodif_code
                               ,snommodifpack => null
                               ,nnommodifpack => null
                               ,naccquant     => c.accquant
                               ,naccquantalt  => null
                               ,nfactquant    => c.factquant
                               ,nfactquantalt => null
                               ,nmiscalc      => 0
                               ,nmiscalcalt   => null
                               ,nprice        => c.price
                               ,npricemeas    => c.nprice_meas
                               ,naccsum       => nAccSum
                               ,nfactsum      => nFactSum);
      /* Сумма Недостача */                               
      nLoss_SUMM := nAccSum - nFactSum;
    end if;
    nLoss_QUANT_IT  := nLoss_QUANT_IT  + nLoss_QUANT;
    nLoss_QUANT_ALL := nLoss_QUANT_ALL + nLoss_QUANT;

    /* Цена */
    /*If nQUANT <> 0 then
      nPRICE := pkg_dictaxis_calc.f_get_value(nident => 0) * \*rTRINC.CURBASE*\ 1 / nQUANT;
    else
      nPRICE := pkg_dictaxis_calc.f_get_value(nident => 0) * \*rTRINC.CURBASE*\ 1 *(1-(\*rTRINC.DISCOUNT*\ 0 + c.nDiscount) / 100 );
    end if;
    nPRICE := nvl(nPRICE,0);
    if nPRICE <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0039',  icell_index_x => 0, icell_index_y => iLINE, ncell_value => nPRICE );
    end if;*/

    nSUMM := nvl(nSUMM,0);
    if nSUMM <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0024',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nSUMM );
    end if;
    nSUMM_IT := nSUMM_IT + nSUMM;
    nSUMM_ALL := nSUMM_ALL + nSUMM;

    nLoss_SUMM := nvl(nLoss_SUMM,0);
    if nLoss_SUMM <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0026',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nLoss_SUMM );
    end if;
    nLoss_SUMM_IT  := nLoss_SUMM_IT  + nLoss_SUMM;
    nLoss_SUMM_ALL := nLoss_SUMM_ALL + nLoss_SUMM;


    /* НДС_Ставка */
    /*if nvl( c.nTax_Value, 0 ) <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0041',  icell_index_x => 0, icell_index_y => iLINE, scell_value => c.nTax_Value );
    end if;

     НДС_Сумма 
    nNDS := pkg_dictaxis_calc.f_get_value(nident => 8) * \*rTRINC.CURBASE*\ 1;
    nNDS := nvl(nNDS,0);
    if nNDS <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0025',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nNDS );
    end if;
    nNDS_IT := nNDS_IT + nNDS;
    nNDS_ALL := nNDS_ALL + nNDS;

    \* Сумма_с_НДС *\
    nSUMM_NDS := c.nSumm_With_NDS * \*rTRINC.CURBASE*\ 1; 
    nSUMM_NDS := nvl(nSUMM_NDS,0);
    if nSUMM_NDS <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0026',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nSUMM_NDS );
    end if;
    nSUMM_NDS_IT  := nSUMM_NDS_IT + nSUMM_NDS;
    nSUMM_NDS_ALL := nSUMM_NDS_ALL + nSUMM_NDS;*/
  end loop;

  nNEWPAGE := 0;
  if nNUMB_DATA_PAGE = 1 then
    nNEWPAGE := 1;
  else
    if nNUMB_LINES_PAGE > nNUMB_LINES_LAST1 then
      nNEWPAGE := 1;
    end if;
  end if;
  /*if nNEWPAGE != 1 then
    PRSG_EXCEL.LINE_PAGE_BREAK(SH1_LAST_PAGE);
  end if;*/

  if nREC_QUANT > 0 then
    /* Итоги таблицы */

    /* Строка Итого */
    iLINE := prsg_excel.line_append( sline_name => SH1_LINE_ITOG, scurrent_line_name => SH1_LINE1 );
    /*if nPASK_IT <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0050',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nPASK_IT );
    end if;
    if nQUANT_IT <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0033',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nQUANT_IT );
    end if;
    if nSUMM_IT <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0034',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nSUMM_IT );
    end if;
    if nLoss_QUANT_IT <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0035',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nLoss_QUANT_IT );
    end if;
    if nLoss_SUMM_IT <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0036',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nLoss_SUMM_IT );
    end if;*/

    /* Строка Всего по накладной */
    iLINE := prsg_excel.line_append( sline_name => SH1_LINE_ALL );
    /*if nPASK_ALL <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0055',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nPASK_ALL );
    end if;*/
    if nQUANT_ALL <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0070',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nQUANT_ALL );
    end if;
    if nSUMM_ALL <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0071',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nSUMM_ALL );
    end if;
    if nLoss_QUANT_ALL <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0072',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nLoss_QUANT_ALL );
    end if;
    if nLoss_SUMM_ALL <> 0 then
      prsg_excel.cell_value_write( scell_name => scell||'0073',  icell_index_x => 0, icell_index_y => iLINE, scell_value => nLoss_SUMM_ALL );
    end if;

    /* Итоги */
    /* Порядковых номеров */
    /*prsg_excel.cell_value_write( scell_name => scell||'0060', scell_value => NUM2TEXT(nREC_QUANT));
    \* Всего мест *\
    prsg_excel.cell_value_write( scell_name => scell||'0061', scell_value => NUM2TEXT(nPASK_ALL) );
    \* Всего отпущено *\
    prsg_excel.cell_value_write( scell_name => scell||'0062'
                               , scell_value => f_money_sum_str( ncompany => rDoc.ncompany
                                                               , nvalue => nSUMM_NDS_ALL
                                                               , \*rTRINC.CURRENCY*\ siso => get_curnames_iso_id( nflag_smart => 1, nrn => rDoc.ncurrency)) );*/
    /* Удаление итоговых строк */
    prsg_excel.line_delete( sline_name => SH1_LINE1 );
    prsg_excel.line_delete( sline_name => SH1_LINE_ITOG );
    prsg_excel.line_delete( sline_name => SH1_LINE_ALL );
  end if;

  /* Удаление строки Шапка  */
  prsg_excel.line_delete( sline_name => SH1_HEAD );

  /* Подписи */
  /*prsg_excel.cell_value_write( scell_name => scell||'0070', scell_value => rAccAgn.emppost);
  prsg_excel.cell_value_write( scell_name => scell||'0071', scell_value => rAccAgn.agnabbr);
  prsg_excel.cell_value_write( scell_name => scell||'0072', scell_value => prsg_rptf.smanager( nagn_rn => rSellerAgn.rn, ddate => rDoc.dDATE, nposition => 0) );
  prsg_excel.cell_value_write( scell_name => scell||'0078', scell_value => rMOLAgn.emppost );
  prsg_excel.cell_value_write( scell_name => scell||'0079', scell_value => rMOLAgn.agnabbr );

  \* Получил *\
  prsg_excel.cell_value_write( scell_name => scell||'0073', scell_value => \*rTRINC.RECIPNUMB*\ null );
  prsg_excel.cell_value_write( scell_name => scell||'0074', scell_value =>  \*DATE_STR(rTRINC.RECIPDATE)*\ null );
  prsg_excel.cell_value_write( scell_name => scell||'0075', scell_value => null );
  prsg_excel.cell_value_write( scell_name => scell||'0076', scell_value => null);
  prsg_excel.cell_value_write( scell_name => scell||'0077', scell_value => null);*/

  /* Макрос */
  /*prsg_excel.execute_macros( smacros_name => 'SortSheets' );*/

  /* Удаление листа */
  prsg_excel.sheet_delete(ssheet_name => SHEET1);

end;
/
