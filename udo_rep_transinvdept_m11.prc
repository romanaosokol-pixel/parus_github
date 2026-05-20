create or replace procedure udo_rep_transinvdept_m11
(
  ncompany in number,   -- Организация
  nident   in number,   -- Отмеченные записи накладных
  srazd    in varchar2, -- Раздел из которого запускается отчет
  sklad    in varchar2, -- Кладовщик
  stech    in varchar2  -- Получил
) is
  /*
   02/06/2025 Степанов М. Переделка заводских номеров головного изделия 
   24/01/2023 Марков МВ. При печати документа в качестве даты указывается дата отработки в учете!!!!
   20/10/2023 Степанов М. При печати из РН в подразделения, если вид отгрузки Ремонт, то в поле серия печатается заводской номер изделия 
   29/11/2023 Степанов М. Убрал запрет печати неотработанных, т.к. перенёс в пакет 
  */
  ----Переменные отчета "Требование-Накладная (Форма М-11)"
  c_slist constant pkg_std.tstring := 'TDSheet'; -- Лист

  c_smainnum       constant pkg_std.tstring := 'sMainNum';
  c_ddate          constant pkg_std.tstring := 'dDate';
  c_sfrom          constant pkg_std.tstring := 'sFrom';
  c_sto            constant pkg_std.tstring := 'sTo';
  c_sinord         constant pkg_std.tstring := 'sInOrd';
  с_sheard_barcode constant pkg_std.tstring := 'sHEARD_BARCODE';

  c_sizdelie constant pkg_std.tstring := 'sIzdelie';
  c_skol     constant pkg_std.tstring := 'sKol';
  c_stheme   constant pkg_std.tstring := 'sTheme';
  c_szakaz   constant pkg_std.tstring := 'sZakaz';
  c_szayav   constant pkg_std.tstring := 'sZayav';

  ll_line     constant pkg_std.tstring := 'L_Line';
  c_sname     constant pkg_std.tstring := 'sName';
  c_snom      constant pkg_std.tstring := 'sNom';
  c_skod      constant pkg_std.tstring := 'sKod';
  c_sizm      constant pkg_std.tstring := 'sIzm';
  c_nrequest  constant pkg_std.tstring := 'nRequest';
  c_nreleased constant pkg_std.tstring := 'nReleased';
  /*  C_nPrice       constant PKG_STD.tSTRING := 'nPrice';
  C_nSum         constant PKG_STD.tSTRING := 'nSum';*/

  c_sklad       constant pkg_std.tstring := 'sKlad';
  c_skladpos    constant pkg_std.tstring := 'sKladPos';
  c_stech       constant pkg_std.tstring := 'sTech';
  c_stechpos    constant pkg_std.tstring := 'sTechPos';
  c_SheepType   constant pkg_std.tstring := 'sSheepType';
  c_SpecBarCode constant pkg_std.tstring := 'sSpecBarCode';
  
  V_MAIN_IZD varchar2(2000);

  nstr       number;
  nsheet     integer := 0;
  ssheetname varchar2(32);
  --nOrdRn         number := 0;
  --nOrdSpecRn     number := 0;
  nfacaacc number := 0;
  sdate    varchar2(32);
  --sShifr         varchar2(256);
  sextnum   varchar2(256) := '-';
  sunitcode varchar2(256);
  ndocument number := 0;
  ndeporder number := 0;
  nincorder number := 0;

  sinord     varchar2(2048) := '-';
  stheme     varchar2(1024) := '';
  szayav     varchar2(1024) := '';
  szakaz     varchar2(1024) := '';
  setap      varchar2(1024) := '';
  sizdelie   varchar2(2048) := ''; /* ВнутрПерем, 2025-12048, 29.04.2025 */
  sizdelie_1 varchar2(1024) := '';
  sSklad     AGNLIST.AGNABBR%type;
  
  ssernumb   goodsparties.sernumb%type := '';
  MNF_NUMB   RLARTICLES.Code%type;
  
  
  nkolvo     number := 0;
  sname      varchar2(240);
  slname     varchar2(240);
  sposttech  agnlist.emppost%type := null;
  spostklad  agnlist.emppost%type := null;
  emp_cnt    integer;
  sazsname1  varchar2(240);
  sazsname2  varchar2(240);
  

  ord_rn        inorders.rn%type;
  s4_rn         payaccin.rn%type;
  nUserReposrt  pkg_std.tref; 
  sSerZamen     pkg_std.tSTRING;

  procedure make_sheet_head
  (
    ssheetname in varchar2
   ,docdate    in varchar2
   ,azs_name1  in varchar2
   ,azs_name2  in varchar2
   ,sizdelie   in varchar2
   ,nkolvo     in number
   ,stheme     in varchar2
   ,szakaz     in varchar2
   ,setap      in varchar2
   ,szayav     in varchar2
   ,sinord     in varchar2
   ,sextnum    in varchar2
   ,ndoc       in number
   ,sSheepType in varchar2
  ) as
  begin
--if utilizer = 'KHOK' then p_exception(0,nvl(sinord, '?')); end if;          
    prsg_excel.sheet_copy(ssheet_name_from   => 'TDSheet'
                         ,ssheet_name_to     => ssheetname
                         ,ssheet_name_before => null
                         ,nmove_to_end       => 1);
    prsg_excel.sheet_select(ssheet_name => ssheetname);
  
    prsg_excel.cell_describe(c_smainnum);
    prsg_excel.cell_describe(c_ddate);
    prsg_excel.cell_describe(c_sfrom);
    prsg_excel.cell_describe(c_sto);
  
    prsg_excel.cell_describe(c_sizdelie);
    prsg_excel.cell_describe(c_skol);
    prsg_excel.cell_describe(c_stheme);
    prsg_excel.cell_describe(c_szakaz);
    prsg_excel.cell_describe(c_szayav);
  
    prsg_excel.cell_describe(c_sinord);
    prsg_excel.cell_describe(с_sheard_barcode);
  
    prsg_excel.cell_describe(c_sklad);
    prsg_excel.cell_describe(c_skladpos);
    prsg_excel.cell_describe(c_stech);
    prsg_excel.cell_describe(c_stechpos);
    prsg_excel.cell_describe(c_sheeptype);

    -- Описываем ячейки спецификации 
    prsg_excel.line_describe(ll_line);
  
    -- Описываем имена ячеек в шапке и подвале
    prsg_excel.line_cell_describe(ll_line, c_sname);
    prsg_excel.line_cell_describe(ll_line, c_snom);
    prsg_excel.line_cell_describe(ll_line, c_skod);
    prsg_excel.line_cell_describe(ll_line, c_sizm);
    prsg_excel.line_cell_describe(ll_line, c_nrequest);
    prsg_excel.line_cell_describe(ll_line, c_nreleased);
    prsg_excel.line_cell_describe(ll_line, c_SpecBarCode);
  
    prsg_excel.cell_value_write(c_smainnum
                               ,case nUserReposrt /* RN шаблбона */
                                  when 8019811   then 'ТРЕБОВАНИЕ-НАКЛАДНАЯ № ' /* Шаблбон "Требование-Накладная (М-11)" */
                                  when 195012776 then 'ВНУТРЕННЯЯ НАКЛАДНАЯ № ' /* Шаблбон "Внутренняя накладная " */
                                end || ssheetname
                               );
    prsg_excel.cell_value_write(c_ddate   , docdate);
    prsg_excel.cell_value_write(c_sfrom   , azs_name1);
    prsg_excel.cell_value_write(c_sto     , azs_name2);
  
    prsg_excel.cell_value_write(c_sizdelie, sizdelie);
    prsg_excel.cell_value_write(c_skol    , nkolvo);
    prsg_excel.cell_value_write(c_stheme  , stheme);
    prsg_excel.cell_value_write(c_szakaz  , szakaz);
    prsg_excel.cell_value_write(c_szayav  , setap || ' ' || szayav);
    prsg_excel.cell_value_write(с_sheard_barcode, ndoc);
    prsg_excel.cell_value_write(c_SheepType, sSheepType);
  
    if ('-' != sextnum) then
      prsg_excel.cell_value_write(c_sinord, sinord || ', Входящий счет: ' || sextnum);
    else
      prsg_excel.cell_value_write(c_sinord, sinord);
    end if;
  end; -- MAKE_SHEET_HEAD

  procedure make_sheet_lines
  (
    sdate       in varchar2
   ,snomenname  in varchar2
   ,ssernumb    in varchar2
   ,s13459633   in varchar2
   ,code_okei   in varchar2
   ,spricemeas  in varchar2
   ,nquant      in number
   ,nquant_fact in number
   ,nparty      in number default null
  ) as
  begin
    nstr := prsg_excel.line_continue(ll_line);
    if sdate is not null then
      prsg_excel.cell_value_write(c_sname, 0, nstr, snomenname || ' (' || sdate || ')');
    else
      prsg_excel.cell_value_write(c_sname, 0, nstr, snomenname);
    end if;
    if ssernumb is not null then
      prsg_excel.cell_value_write(c_snom, 0, nstr, ssernumb);
    else
      prsg_excel.cell_value_write(c_snom, 0, nstr, s13459633);
    end if;
    prsg_excel.cell_value_write(c_skod, 0, nstr, code_okei);
    prsg_excel.cell_value_write(c_sizm, 0, nstr, spricemeas);
    prsg_excel.cell_value_write(c_nrequest, 0, nstr, nquant);
    prsg_excel.cell_value_write(c_nreleased, 0, nstr, nquant_fact);
    if nUserReposrt = 195012776 then  /* RN шаблбона */
      prsg_excel.cell_value_write( c_SpecBarCode, 0, nstr, to_char(nparty) );
    end if ;

  end; -- MAKE_SHEET_LINES

begin
  /* RN Пользовательского отчёта */
  nUserReposrt := PKG_USERREPORTS_INT.ENV_REPORT_ID;  

  begin
    udo_p_docauthor_full(sname => sname, slname => slname);
  end;
  if sklad is not null then
    if trim(sklad) = 'Лукашина М.А.' then 
         sSklad := 'Фролов С.М.'; 
    else sSklad := sklad;
    end if;
    begin
      select ag.emppost into spostklad from agnlist ag where ag.agnabbr = sSklad; --sklad;
    exception
      when no_data_found then
        p_exception(0, 'Сотрудник "%s" не найден.', sklad);
    end;
  end if;
  if stech is not null then
    begin
      select ag.emppost into sposttech from agnlist ag where ag.agnabbr = stech;
    exception
      when no_data_found then
        p_exception(0, 'Сотрудник "%s" не определён.', stech);
    end;
  end if;
  --if utilizer = 'KHOK' then P_EXCEPTION(0, 'Должности: ' || sPostKlad ||' - '||sPostTech); end if;

  ---Инициализация
  -- Готовим шаблон
  prsg_excel.prepare;
  --  select us.name into sSheetName from userlist us where us.authid = USER;
  --p_exception(0,USER||' - '||sSheetName);

  if 'GoodsTransInvoicesToDepts' = srazd then
    -- Расходные накладные на отпуск в подразделения (TRANSINVDEPT)
    for rec in (select tran.rn     tran_nrn
                      , /*tran.in_mol,*/ag1.agnabbr agnabbr_kl
                      ,ag1.emppost emppost_kl
                      ,ag2.agnabbr
                      ,ag2.emppost
                      ,
                       --UDO_PKG_REPORT_M4_XLS.GET_TEMETPZAK(UDO_REP_TRANSINVDEPT_M11.nCOMPANY, tran.faceacc, null, 1) sFullTheme, 
                       tran.rn
                      ,tran.pref
                      ,tran.numb
                      ,tran.docdate
                      ,tran.work_date
                      ,tran.faceacc
                      , --tran.sfaceacc,
                       (select num_value
                          from v_docs_props_vals_shadow
                         where docs_prop_rn = 12090086
                           and unitcode = 'GoodsTransInvoicesToDepts'
                           and unit_rn = tran.rn) n12090086
                      ,(select str_value
                          from v_docs_props_vals_shadow
                         where docs_prop_rn = 12090061
                           and unitcode = 'GoodsTransInvoicesToDepts'
                           and unit_rn = tran.rn) s12090061
                      ,udo_pkg_report_m4_xls.get_temetpzak(ncompany => tran.company
                                                          ,nfaceacc => tran.faceacc
                                                          ,nnr_po   => tran.rn
                                                          ,ntype    => 0
                                                          ,npriem   => null) stheme
                      ,tran.store
                      ,az1.azs_name azs_name1
                      ,tran.in_store
                      ,az2.azs_name azs_name2
                      ,udo_f_transinvdept_main_prod(tran.rn) sizdelie
                      ,udo_f_transinvdept_main_numb(tran.rn) szakaz
                      ,ind.code ind_code
                      ,tran.stoper
                      ,tran.status
                      ,tran.sheepview
                      ,tran.jur_pers
                      ,tran.company
                      ,tran.crn
                  from selectlist     sl
                      ,transinvdept   tran
                      ,azsazslistmt   az1
                      ,azsazslistmt   az2
                      ,agnlist        ag1
                      ,agnlist        ag2
                      ,ins_department ind
                 where sl.ident = nident
                   and sl.document = tran.rn
                   and tran.company = udo_rep_transinvdept_m11.ncompany
                   and tran.store = az1.rn(+)
                   and tran.in_store = az2.rn(+)
                   and tran.in_mol = ag2.rn(+)
                   and tran.mol = ag1.rn(+)
                   and tran.subdiv = ind.rn(+)
                --and tran.status != 0
                --and rownum = 1
                 order by tran.docdate)
    loop
      
       
      -- Отчет печатается только для отработанных накладных (Исключение - возврат из Производства и Входной контроль)
      if rec.status = 0 
         and rec.stoper  != 50233858 
         and nUserReposrt = 8019811 /* Шаблбон "Требование-Накладная (М-11)" */
      then
        /* Проверка права "Печать неотработанного документа" */
        pkg_env.access(ncompany   => rec.company
                      ,nversion   => null
                      ,ncatalog   => rec.crn
                      ,sunit      => 'GoodsTransInvoicesToDepts'
                      ,saction    => 'USR_TRANSINVDEPT_PRINT_NOT_WORKED');
      end if;
    
      nkolvo := rec.n12090086;

  --sIzdelie := F_DICNOMNS_GET_NAME_BY_CODE(rec.s12090061);
  --- Найдем головные изделия накладной
  v_main_izd := ';';

  for izd in (
     with p as
 (select pp.rn
        ,pp.prn
        ,pp.party_numb
        ,min(substr(rl.code, instr(rl.code, '_') + 1)) zn_min
        ,max(substr(rl.code, instr(rl.code, '_') + 1)) zn_max
        ,udo_f_fcdelivsh_mainprod_num(nrn => dl1.in_document) as sFcDElivSh /* 02/06/2025 Степанов М. Переделка заводских номеров головного изделия */
    from transinvdept     t
    join doclinks         dl1
      on dl1.out_document = t.rn
     and dl1.in_unitcode  = 'CostDeliverySheets'
     and dl1.out_unitcode = 'GoodsTransInvoicesToDepts'
    join doclinks         dl2
      on dl2.out_document = dl1.in_document
     and dl2.in_unitcode  = 'CostRouteLists'
     and dl2.out_unitcode = dl1.in_unitcode
    join doclinks         dl3
      on dl3.out_document = dl2.in_document
     and dl3.in_unitcode  = 'CostProductPlansSpecs'
     and dl3.out_unitcode = dl2.in_unitcode
    join fcprodplansp     pp
      on pp.rn            = dl3.in_document
    left join fcroutlstsernumb fn /* 21/08/2025 KHOK. Заводского номера может не быть. Например, Упаковка ЮФКВ. */
      on fn.prn           = dl2.in_document
    left join rlarticles  rl
      on rl.rn            = fn.article
  
   where t.rn = rec.tran_nrn
   group by pp.rn
           ,pp.prn
           ,pp.party_numb
           ,udo_f_fcdelivsh_mainprod_num(nrn => dl1.in_document) /* 02/06/2025 Степанов М. Переделка заводских номеров головного изделия */
 )

 (select mr.code
        ,mr.name || /*case
                      when p.zn_min is null then
                       ''
                      else
                       case
                         when p.zn_min = p.zn_max then
                          ' (' || p.zn_min || ')'
                         else
                          ' (' || p.zn_min || '-' || p.zn_max || ')'
                       end
                    end */
                    ' ('|| p.sFcDElivSh ||') ' name  /* 02/06/2025 Степанов М. Переделка заводских номеров головного изделия */
    from p
        ,fcprodplansp pp
    join fcmatresource mr
      on mr.rn = pp.per_matres
  
   where pp.prn = p.prn
     and pp.party_numb = p.party_numb
     and level = 1
  
  connect by prior pp.per_matres = pp.matres
   start with pp.rn = p.rn))
  
  loop
   if length(v_main_izd) < 1800 then 

    v_main_izd:= v_main_izd||';'||izd.name;
    
   end if;
  
  end loop;

  v_main_izd:= substr(v_main_izd,3);

  if v_main_izd is not null then 
    rec.sizdelie := v_main_izd||cr||' ('||rec.sizdelie||')';
  end if;
  

      if 50233858 = rec.stoper then
        -- ПриходВозвр
        begin
          select udo_f_transinvdept_main_prod(m.rn)
                ,udo_f_transinvdept_main_numb(m.rn)
            into sizdelie
                ,szakaz
            from transinvdept m
           where ncompany = udo_rep_transinvdept_m11.ncompany
             and m.rn in (select ndocument
                            from v_doclinks_inout_out_ext
                           where nout_document = rec.tran_nrn
                             and sout_unitcode = 'GoodsTransInvoicesToDepts'
                             --and rownum = 1
                             and sunitcode = 'GoodsTransInvoicesToDepts');
        exception
          when no_data_found then
            sizdelie := null;
          when too_many_rows then
                p_exception(0
                 ,'Для расходной накладной #RN %s найдено более одного связанного исходного документа. '
                 || 'Проверьте корректность связей в документах или обратитесь к администратору.'
                 , rec.tran_nrn);
        end;
      else
        sizdelie := rec.sizdelie;
        szakaz   := rec.szakaz;
      end if;
    
   
  
      if szakaz is not null then
        if instr(sizdelie, '(000') > 0 then
          sizdelie := substr(sizdelie, 0, instr(sizdelie, '(000')) || 'зав.№ ' || szakaz || ')';
        else
         -- if user = 'GOR' then p_exception(0, sizdelie); end if;
          sizdelie := sizdelie || ' (зав.№ ' || szakaz || ')';
        end if;
      end if;

      begin
        select listagg(TT.SZAYAV, '; ') WITHIN GROUP(order by TT.SZAYAV), TT.ORD_RN, TT.S4_RN
          into szayav
              ,ord_rn
              ,s4_rn
          from (select distinct udo_f_payaccinsp_ext_depord(sps.rn) as szayav, 
                                dl1.in_document as ord_rn, 
                                dl3.in_document as s4_rn
                  from doclinks dl1
                  join doclinks dl2 on dl2.out_document = dl1.in_document
                  join doclinks dl3 on dl3.out_document = dl2.in_document
                  join payaccinspec sps      on sps.prn = dl3.in_document
                  join transinvdeptspecs spn on spn.prn = dl1.out_document
                 where dl1.out_document = rec.tran_nrn
                   and dl1.out_unitcode = 'GoodsTransInvoicesToDepts'
                   and dl1.in_unitcode  = 'IncomingOrders'
                   and dl2.out_unitcode = dl1.in_unitcode
                   and dl2.in_unitcode  = 'IncomingInvoices'
                   and dl3.out_unitcode = dl2.in_unitcode
                   and dl3.in_unitcode  = 'PaymentAccountsIn'
                   and sps.nommodif = spn.nommodif
                   /*25/07/2025 KHOK. Возможны строки Спецификации счета без привязки к Заказу подразделения */
                   and udo_f_payaccinsp_ext_depord(sps.rn) is not null) TT
      group by TT.ORD_RN, TT.S4_RN;
      exception
        when no_data_found then
          szayav := null; -- Не нашли Входящий счет содержащий модификации номенклатур накладной в подразделения
        when too_many_rows then
          p_exception(0, 'В спецификации накладной присутствуют позиции из разных заявок. Для печати обратитесь в техническую поддержку.');
      end;
    
      begin
        select dto.doccode || ': ' || trim(ord.indocpref) || '-' || trim(ord.indocnumb) || ' от ' ||
               to_char(ord.indocdate, 'DD.MM.YYYY') || --ord.sseller_name ||
               nvl(dtn.doccode, '; ПН') || ': ' || trim(ord.invdocnumb) || ' от ' ||
               to_char(ord.invdocdate, 'DD.MM.YYYY') || '; ' || agn.agnname
          into sinord
          from inorders ord
          join doctypes dto
            on dto.rn = ord.indoctype
          left join doctypes dtn
            on dtn.rn = ord.invdoctype
          join agnlist agn
            on agn.rn = ord.contragent
         where ord.rn = ord_rn;
      exception
        when no_data_found then
        
          begin
            select dl2.in_document --- Через входной контроль
              into nincorder
              from doclinks dl1
              join doclinks dl2
                on dl2.out_document = dl1.in_document
             where dl1.out_document = rec.tran_nrn
               and dl1.in_unitcode = 'UdoProdCull'
               and dl1.out_unitcode = 'GoodsTransInvoicesToDepts'
               and dl2.in_unitcode = 'IncomingOrders'
               and dl2.out_unitcode = dl1.in_unitcode;
          exception
            when no_data_found then
              sinord := null;
          end;
      end;
      
        begin
          select dto.doccode || ': ' || trim(ord.indocpref) || '-' || trim(ord.indocnumb) || ' от ' ||
                 to_char(ord.indocdate, 'DD.MM.YYYY') || --ord.sseller_name ||
                 nvl(dtn.doccode, '; ПН') || ': ' || trim(ord.invdocnumb) || ' от ' ||
                 to_char(ord.invdocdate, 'DD.MM.YYYY') || '; ' || agn.agnname
            into sinord
            from inorders ord
                ,agnlist  agn
                ,doctypes dto
                ,doctypes dtn
           where ord.rn = nincorder
             and ord.contragent = agn.rn
             and dto.rn = ord.indoctype
             and dtn.rn(+) = ord.invdoctype;
        exception
          when no_data_found then
            nincorder := 0;
        end;
      


    
      begin
        select s4.ext_numb into sextnum from payaccin s4 where s4.rn = s4_rn;
      exception
        when no_data_found then
          null;
      end;
    
      begin
        select dl.in_document
              ,dl.in_unitcode
          into ndocument
              ,sunitcode
          from doclinks      dl
              ,udo_prod_cull ord
         where dl.out_document = rec.tran_nrn
           and dl.out_unitcode = 'GoodsTransInvoicesToDepts'
           and ord.rn(+) = dl.in_document
           and dl.in_unitcode = 'UdoProdCull';
      exception
        when no_data_found then
          begin
            select dl.in_document
                  ,dl.in_unitcode
              into ndocument
                  ,sunitcode
              from doclinks  dl
                  ,fcdelivsh ord
             where dl.out_document = rec.tran_nrn
               and dl.out_unitcode = 'GoodsTransInvoicesToDepts'
               and ord.rn(+) = dl.in_document
               and dl.in_unitcode = 'CostDeliverySheets';
          exception
            when no_data_found then
              begin
                select dl.in_document
                      ,dl.in_unitcode
                  into ndocument
                      ,sunitcode
                  from doclinks       dl
                      ,fcdeliverylist ord
                 where dl.out_document = rec.tran_nrn
                   and dl.out_unitcode = 'GoodsTransInvoicesToDepts'
                   and ord.rn(+) = dl.in_document
                   and dl.in_unitcode = 'CostDeliveryLists';
              exception
                when no_data_found then
                  begin
                    select dl.in_document
                          ,dl.in_unitcode
                      into ndocument
                          ,sunitcode
                      from doclinks      dl
                          ,departmentord ord
                     where dl.out_document = rec.tran_nrn
                       and dl.out_unitcode = 'GoodsTransInvoicesToDepts'
                       and ord.rn(+) = dl.in_document
                       and dl.in_unitcode = 'DepartmentsOrders';
                    ndeporder := ndocument;
                  exception
                    when no_data_found then
                      begin
                        select dl.in_document
                              ,dl.in_unitcode
                          into ndocument
                              ,sunitcode
                          from doclinks dl
                              ,inorders ord
                         where dl.out_document = rec.tran_nrn
                           and dl.out_unitcode = 'GoodsTransInvoicesToDepts'
                           and ord.rn(+) = dl.in_document
                           and dl.in_unitcode = 'IncomingOrders';
                        nincorder := ndocument;
                      exception
                        when no_data_found then
                          ndocument := 0;
                          ndeporder := 0;
                          nincorder := 0;
                          sunitcode := '';
                      end;
                  end;
              end;
          end;
      end;
   
      if 'UdoProdCull' = sunitcode then
        begin
          select dl.in_document
                ,dl.in_unitcode
            into nincorder
                ,sunitcode
            from doclinks dl
                ,inorders ord
           where dl.out_document = ndocument
             and dl.out_unitcode = 'UdoProdCull'
             and ord.rn(+) = dl.in_document
             and dl.in_unitcode = 'IncomingOrders';
        exception
          when no_data_found then
            nincorder := null;
            sunitcode := '?';
        end;
      elsif 'CostDeliverySheets' = sunitcode then
        begin
          select udo_f_fcdelivsh_product_num(t.rn)
                , /*'', F2.NAME,*/t.quant
            into szayav
                , /*sZakaz, sIzdelie,*/nkolvo
            from fcdelivsh     t
                ,fcmatresource f2
           where t.rn = ndocument
             and t.matres = f2.rn;
        exception
          when too_many_rows then
            szayav := '?'; /*sZakaz := '?';*/
            nkolvo := 0;
        end;
      elsif 'CostDeliveryLists' = sunitcode then
        begin
          select udo_f_fcdelivlist_product_num(lst.rn)
                ,lst.prod_order
                ,lst.quant --, lst.smatres_name
            into szayav
                ,szakaz
                ,nkolvo --, sIzdelie
            from fcdeliverylist lst
           where lst.rn = ndocument;
        exception
          when too_many_rows then
            szayav := '?';
            szakaz := '?';
            nkolvo := 0;
        end;
      
        begin
          select oi.ndocument
            into ndeporder
            from v_doclinks_inout_out oi
                ,inorders             ord
           where nout_document = rec.tran_nrn
             and sout_unitcode = 'GoodsTransInvoicesToDepts'
             and ord.rn(+) = oi.ndocument
             and sunitcode = 'DepartmentsOrders';
        exception
          when no_data_found then
            ndeporder := 0;
        end;
      
      end if;
      --if utilizer = 'KHOK' then p_exception(0, sUnitCode || ' - ' ||nIncOrder); end if;
    
      if 'DepartmentsOrders' = sunitcode
      /*or 0 != ndeporder */
       then
      
        begin
          select (select str_value
                    from v_docs_props_vals_shadow
                   where docs_prop_rn = 8027721
                     and unitcode = 'DepartmentsOrders'
                     and unit_rn = t.rn)
                ,
                 /*t.sfaceacc,*/trim(udo_f_departmentord_shefr(t.rn) /*, UDO_F_DEPORD_MAINPROD_NAME(nRN)*/)
            into szayav
                , /*sZakaz,*/stheme --, sIzdelie
            from departmentord t
           where t.rn = ndeporder; --nDocument;
        exception
          when no_data_found then
            begin
              select udo_pkg_report_m4_xls.get_temetpzak(ncompany => udo_rep_transinvdept_m11.ncompany
                                                        ,nfaceacc => t.faceaccount
                                                        ,nnr_po   => null
                                                        ,ntype    => 1
                                                        ,npriem   => null)
                    ,t.faceaccount
                into szayav
                    ,nfacaacc
                from inorderspecsclc t
               where t.prn = ndeporder;
            exception
              when no_data_found then
                szayav := '-'; --sZakaz := '-';
            end;
        end;
      
        begin
          select oi.ndocument
            into nincorder
            from v_doclinks_inout_out oi
                ,inorders             ord
           where nout_document = rec.tran_nrn
             and sout_unitcode = 'GoodsTransInvoicesToDepts'
             and ord.rn(+) = oi.ndocument
             and sunitcode = 'IncomingOrders';
        exception
          when no_data_found then
            nincorder := 0;
        end;
       
        begin
          select dto.doccode || ': ' || trim(ord.indocpref) || '-' || trim(ord.indocnumb) || ' от ' ||
                 to_char(ord.indocdate, 'DD.MM.YYYY') || --ord.sseller_name ||
                 nvl(dtn.doccode, '; ПН') || ': ' || trim(ord.invdocnumb) || ' от ' ||
                 to_char(ord.invdocdate, 'DD.MM.YYYY') || '; ' || agn.agnname
            into sinord
            from inorders ord
                ,agnlist  agn
                ,doctypes dto
                ,doctypes dtn
           where ord.rn = nincorder
             and ord.contragent = agn.rn
             and dto.rn = ord.indoctype
             and dtn.rn(+) = ord.invdoctype;
        exception
          when no_data_found then
            nincorder := 0;
        end;
      
      end if;
    
      if instr(rec.stheme, '/') > 0 then
        stheme := substr(rec.stheme, 0, instr(rec.stheme, '/') - 1);
        szakaz := substr(rec.stheme, instr(rec.stheme, '/') + 1);
        setap  := substr(szakaz, instr(szakaz, '/') + 1);
        szakaz := substr(szakaz, 0, instr(szakaz, '/') - 1);
      end if;
    
      if instr(szayav, '(') > 0 then
        szayav := substr(szayav, instr(szayav, '('));
      end if;
    
      nsheet     := nsheet + 1;
      ssheetname := trim(rec.pref) || '-' || trim(replace(rec.numb, '/', '_'));
    
      begin
        select count(rn)
          into emp_cnt
          from azsazslistmt d
         where crn in ('21648829')
           and company = 90521
           and rn = rec.store;
        if emp_cnt > 0
           and instr(rec.azs_name1, 'Производство') = 0 then
          sazsname1 := 'Производство (из ' || rec.azs_name1 || ')';
        else
          sazsname1 := rec.azs_name1;
        end if;
      end;
      begin
        select count(rn)
          into emp_cnt
          from azsazslistmt d
         where crn in ('21648829')
           and company = 90521
           and rn = rec.in_store;
        if emp_cnt > 0
           and instr(rec.azs_name2, 'Производство') = 0 then
          sazsname2 := 'Производство (в ' || rec.azs_name2 || ')';
        else
          sazsname2 := rec.azs_name2;
        end if;
      end;
   
      if 50233858 = rec.stoper then
        -- ПриходВозвр
        make_sheet_head(ssheetname
                       ,to_char(nvl(case
                                      when rec.work_date > rec.docdate then
                                       rec.work_date
                                      else
                                       rec.docdate
                                    end
                                   ,rec.docdate)
                               ,'DD.MM.YYYY')
                       ,nvl(rec.ind_code, sazsname2)
                       ,sazsname1
                       ,sizdelie
                       ,nkolvo
                       ,stheme
                       ,szakaz
                       ,setap
                       ,szayav
                       ,sinord
                       ,sextnum
                       ,rec.rn
                       ,null);
      else
        -- = 12078561 -- РасхПерем 
        make_sheet_head(ssheetname
                       ,to_char(nvl(case when rec.work_date > rec.docdate then rec.work_date else
                                    rec.docdate end
                                   ,rec.docdate)
                               ,'DD.MM.YYYY')
                       ,sazsname1
                       ,sazsname2
                       ,sizdelie
                       ,nkolvo
                       ,stheme
                       ,szakaz
                       ,setap
                       ,szayav
                       ,sinord
                       ,sextnum
                       ,rec.rn
                       ,null);
      end if;
      
      
        
      sizdelie := null;
    
      for spec in (select mat.name mat_name, nom.original_name
                         ,sp.*
                         ,dic.code_okei
                         ,(select str_value
                             from v_docs_props_vals_shadow
                            where docs_prop_rn = 13459633
                              and unitcode = 'GoodsTransInvoicesToDeptsSpecs'
                              and unit_rn = nrn) s13459633
                     from v_transinvdeptspecs sp
                         ,fcmatresource mat
                         ,dicmunts      dic
                         ,DICNOMNS      nom
                    where sp.nprn = rec.tran_nrn                         
                      and mat.nomen_modif(+) = sp.nnommodif
                      and sp.nmeas_main(+) = dic.rn
                      and nom.rn = sp.nnomen
                      and trim(sp.snomenname) != 'Тара'
                         -- Оставляем только нормальные серийные номера, скрывая свои четырехзначные (кроме возвратных накладных)
                      and (sp.ssernumb is null or length(sp.ssernumb) != 4 or rec.stoper = 50233858 
                       or (length(sp.ssernumb) = 4 and substr(sp.sgoodsparty, 0, 2) in ('10', '11', '12', '13'))) /* 11.06.2025 KHOK. Нормальные старые запасы */
                    order by mat.name
                            ,sp.ssernumb
                            ,sp.nquant desc -- Сортировка должна соответствовать выгрузке в отчете UDO_REP_TRANSINVCUST_TO_1C
                   )
      loop


/* Городецкий закомментировал 25-03-2025 */
  /*      begin
          select udo_f_prod_cull_sp_mainprod(m.rn) -- Заводской номер уже внутри
            into sizdelie_1
            from udo_prod_cull_sp m
           where ncompany = udo_rep_transinvdept_m11.ncompany
             and m.prn in (select in_document
                             from doclinks
                            where out_document = rec.tran_nrn
                              and out_unitcode = 'GoodsTransInvoicesToDepts'
                              and in_unitcode = 'UdoProdCull')
             and m.modif = spec.nnommodif --(!!!)
             and rownum = 1;
          \*PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie, sIzdelie);*\
        exception
          when no_data_found then
            sizdelie_1 := null;
        end;

     if user = 'GOR' then
     P_Exception(0, sizdelie_1);
   end if;
        --end if;
        if length(sizdelie_1) > 0 
           and sizdelie is null then
          sizdelie := sizdelie_1;
        elsif instr(sizdelie, sizdelie_1) = 0 and  trim (sizdelie_1) != trim(sizdelie) then
          sizdelie := sizdelie || '; ' || sizdelie_1;
        end if;*/
        
 ---if user = 'GOR' then p_exception(0, '865! '||sizdelie); end if;  
      
        szakaz := null;
        begin
          select g.sernumb, '('||UDO_F_GOODSPARTIES_MNF_NUMB(g.rn)||')'    
            into ssernumb,
                 MNF_NUMB
            from doclinks       dl
                ,storeoperjourn jrn
                ,goodssupply    s
                ,goodsparties   g
           where dl.in_document = spec.nprn
             and dl.out_unitcode = 'StoreOpersJournal'
             and dl.in_unitcode = 'GoodsTransInvoicesToDepts'
             and dl.out_document = jrn.rn
             and jrn.article = spec.narticle
             and jrn.oper_type = 0 -- Расход
             and jrn.goodssupply = s.rn
             and s.prn = g.rn;
        exception
          when no_data_found then
            ssernumb := '';
        end;
        
        
        make_sheet_lines(sdate      => sdate
                        ,snomenname => case
                                          when trim(spec.original_name) is not null and 
                                               upper(trim(spec.snomenname)) != upper(trim(spec.original_name)) then
                                            nvl(spec.mat_name||' / '||trim(spec.original_name), spec.snomenname||' / '||trim(spec.original_name))||' '||MNF_NUMB
                                          else
                                            nvl(spec.mat_name, spec.snomenname)||' '||MNF_NUMB
                                        end
                         /* 20/10/2023 Степанов М. */
                        ,ssernumb    => case
                                          when rec.sheepview = 76021955 then /* Ремонт */
                                            substr(spec.sarticle, instr(spec.sarticle, '_', -1) + 1) /* символы после последнего "_" из номера изделия */
                                          else
                                            coalesce( spec.ssernumb, ssernumb, udo_f_rlarticles_mnf_numb(spec.narticle) ) 
                                        end
                        ,s13459633   => spec.s13459633
                        ,code_okei   => spec.code_okei
                        ,spricemeas  => spec.spricemeas
                        ,nquant      => spec.nquant
                        ,nquant_fact => spec.nquant
                        ,nparty      => spec.nparty);
      end loop;
       
      
      if length(sizdelie) > 0 then
        prsg_excel.cell_value_write(c_sizdelie, sizdelie);
      end if;
    
      --удаляем техническую строку
      prsg_excel.line_delete(ll_line);
    
      if 12101790 = rec.store then
        -- Изолятор брака
        if stech is not null
           and sklad is not null then
          prsg_excel.cell_value_write(c_sklad, sSklad /*sklad*/);
          prsg_excel.cell_value_write(c_skladpos, spostklad);
          prsg_excel.cell_value_write(c_stech, stech);
          prsg_excel.cell_value_write(c_stechpos, sposttech);
        end if;
      else
        if 50233858 = rec.stoper then
          -- ПриходВозвр
          prsg_excel.cell_value_write(c_stech, rec.agnabbr_kl); -- не даем менять фамилии в отчете!
          prsg_excel.cell_value_write(c_stechpos, rec.emppost_kl);
          prsg_excel.cell_value_write(c_sklad, rec.agnabbr);
          prsg_excel.cell_value_write(c_skladpos, rec.emppost);
        else
          prsg_excel.cell_value_write(c_sklad, rec.agnabbr_kl); -- не даем менять фамилии в отчете!
          prsg_excel.cell_value_write(c_skladpos, rec.emppost_kl);
          prsg_excel.cell_value_write(c_stech, rec.agnabbr);
          prsg_excel.cell_value_write(c_stechpos, rec.emppost);
        end if;
      end if;
    
    end loop;
  
  elsif 'IncomFromDeps' = srazd then
    -- Приход из подразделений (INCOMEFROMDEPS)
  
    for rec in (select tran.rn tran_nrn
                      ,tran.store
                      ,tran.out_store
                      ,al.agnabbr
                      ,al.emppost
                      ,tran.rn
                      ,tran.doc_pref
                      ,tran.doc_numb
                      ,tran.doc_date
                      ,tran.out_faceacc
                      , --tran.sfaceacc,
                       (select num_value
                          from v_docs_props_vals_shadow
                         where docs_prop_rn = 12090086
                           and unitcode = 'GoodsTransInvoicesToDepts'
                           and unit_rn = tran.rn) n12090086
                      ,(select str_value
                          from v_docs_props_vals_shadow
                         where docs_prop_rn = 12090061
                           and unitcode = 'GoodsTransInvoicesToDepts'
                           and unit_rn = tran.rn) s12090061
                      ,udo_pkg_report_m4_xls.get_temetpzak(ncompany => 90521
                                                          ,nfaceacc => tran.out_faceacc
                                                          ,nnr_po   => tran.rn
                                                          ,ntype    => 0
                                                          ,npriem   => null) stheme
                      ,d.code /*az1.azs_name*/ azs_name1
                      ,az2.azs_name azs_name2
                      ,
                       /*UDO_F_TRANSINVDEPT_MAIN_PROD(tran.RN)*/'' sprod
                      ,
                       /*UDO_F_TRANSINVDEPT_MAIN_NUMB(tran.RN)*/'' szakaz
                  from selectlist     sl
                      ,incomefromdeps tran
                      ,
                       --AZSAZSLISTMT az1, 
                       azsazslistmt   az2
                      ,ins_department d
                      ,agnlist        al
                 where sl.ident = nident
                   and sl.document = tran.rn
                   and tran.company = udo_rep_transinvdept_m11.ncompany
                      --and az1.rn (+)= tran.out_store
                   and az2.rn(+) = tran.store
                   and tran.out_department = d.rn(+)
                   and tran.agent = al.rn
                --and rownum = 1
                 order by tran.doc_date)
    loop
    
      if instr(rec.stheme, '/') > 0 then
        stheme := substr(rec.stheme, 0, instr(rec.stheme, '/') - 1);
        szakaz := substr(rec.stheme, instr(rec.stheme, '/') + 1);
        setap  := substr(szakaz, instr(szakaz, '/') + 1);
        szakaz := substr(szakaz, 0, instr(szakaz, '/') - 1);
      end if;
    
      if instr(szayav, '(') > 0 then
        szayav := substr(szayav, instr(szayav, '('));
      end if;
    
      nsheet     := nsheet + 1;
      ssheetname := trim(rec.doc_pref) || '-' || trim(replace(rec.doc_numb, '/', '_'));
      make_sheet_head(ssheetname
                     ,to_char(rec.doc_date, 'DD.MM.YYYY')
                     ,rec.azs_name1
                     ,rec.azs_name2
                     ,sizdelie
                     ,1 /*nKolvo*/
                     ,stheme
                     ,szakaz
                     ,setap
                     ,szayav
                     ,sinord
                     ,sextnum
                     ,rec.rn
                     ,null);
    
      for spec in (select mat.name mat_name
                         ,dic.code_okei
                         ,(select str_value
                             from v_docs_props_vals_shadow
                            where docs_prop_rn = 13459633
                              and unitcode = 'GoodsTransInvoicesToDeptsSpecs'
                              and unit_rn = nrn) s13459633
                         ,sp.*
                     from v_incomefromdepsspec sp
                         ,fcmatresource        mat
                         ,nommodif             nm
                         ,dicnomns             n
                         ,dicmunts             dic
                    where sp.nprn = rec.tran_nrn
                      and mat.nomen_modif(+) = sp.nnommodif
                      and sp.nnommodif = nm.rn
                      and n.rn = nm.prn
                      and n.umeas_main = dic.rn
                  
                    order by mat.name, sp.ssernumb 
                   )
      loop
      
        make_sheet_lines(sdate
                        ,nvl(spec.mat_name, spec.snomenname)
                        ,spec.ssernumb
                        ,spec.s13459633
                        ,spec.code_okei
                        ,spec.spricemeas
                        ,spec.nquant_plan
                        ,spec.nquant_fact);
      end loop;
      --удаляем техническую строку
      prsg_excel.line_delete(ll_line);
    
      prsg_excel.cell_value_write(c_sklad, sSklad /*sklad*/);
      if stech is not null then
        prsg_excel.cell_value_write(c_stech, stech);
        prsg_excel.cell_value_write(c_stechpos, sposttech);
      else
        prsg_excel.cell_value_write(c_stech, rec.agnabbr);
        prsg_excel.cell_value_write(c_stechpos, rec.emppost);
      end if;
    
    end loop;
  
  elsif 'ReturnInvoicesToSuppliers' = srazd then
    -- Расходные накладные на возврат поставщикам (RINVTOSUP)
  
    for rec in (select tran.rn      tran_nrn
                      , /*tran.in_mol,*/ag.agnabbr
                      ,ag.emppost
                      ,tran.pref
                      ,tran.numb
                      ,tran.docdate
                      , --tran.work_date, --tran.faceacc, --tran.sfaceacc,
                       az1.azs_name azs_name1
                      ,ag2.agnname  azs_name2
                       --IND.CODE ind_code, 
                      ,tran.storeoper -- ВозврПост 24035960
                      ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 193749297 , ndocument => tran.rn) as sSheepType /* Вид отгрузки из свойства */
                  from selectlist   sl
                      ,rinvtosup    tran
                      ,azsazslistmt az1
                      ,agnlist      ag 
                      --AZSAZSLISTMT az2,
                      ,agnlist      ag2
                       --, INS_DEPARTMENT IND
                 where sl.ident = nident
                   and sl.document = tran.rn
                   and tran.company = udo_rep_transinvdept_m11.ncompany
                   and tran.store = az1.rn(+)
                   --and tran.in_store = az2.rn(+)
                   and tran.mol = ag.rn(+)
                   and tran.supplier = ag2.rn(+)
                   --and tran.SUBDIV = IND.RN(+)
                 order by tran.docdate)
    loop
    
      if instr(szayav, '(') > 0 then
        szayav := substr(szayav, instr(szayav, '('));
      end if;

      /* 06/10/2025 KHOK. ПО для накладной Возврата поставщику. */
      begin
        select oi.ndocument
          into nincorder
          from v_doclinks_inout_out oi
              ,inorders             ord
         where nout_document = rec.tran_nrn
           and sout_unitcode = 'ReturnInvoicesToSuppliers'
           and ord.rn(+) = oi.ndocument
           and sunitcode = 'IncomingOrders';
      exception
        when no_data_found then
          nincorder := 0;
      end;

      begin
        select dto.doccode || ': ' || trim(ord.indocpref) || '-' || trim(ord.indocnumb) || ' от ' ||
               to_char(ord.indocdate, 'DD.MM.YYYY') || --ord.sseller_name ||
               nvl(dtn.doccode, '; ПН') || ': ' || trim(ord.invdocnumb) || ' от ' ||
               to_char(ord.invdocdate, 'DD.MM.YYYY') || '; ' || agn.agnname
          into sinord
          from inorders ord
              ,agnlist  agn
              ,doctypes dto
              ,doctypes dtn
         where ord.rn = nincorder
           and ord.contragent = agn.rn
           and dto.rn = ord.indoctype
           and dtn.rn(+) = ord.invdoctype;
      exception
        when no_data_found then
          nincorder := 0;
      end;
      /* 06/10/2025 KHOK. */

      nsheet     := nsheet + 1;
      ssheetname := trim(rec.pref) || '-' || trim(replace(rec.numb, '/', '_'));

      make_sheet_head(ssheetname
                     ,to_char(rec.docdate, 'DD.MM.YYYY')
                     ,rec.azs_name1
                     ,rec.azs_name2
                     ,'Возврат поставщикам' /*sIzdelie*/
                     ,1 /*nKolvo*/
                     ,stheme
                     ,szakaz
                     ,setap
                     ,szayav
                     ,sinord
                     ,sextnum
                     ,rec.tran_nrn
                     ,case when cmp_vc2( rec.sSheepType, 'Замена серии' ) = 1 then  rec.sSheepType end );
    
      for spec in (select mat.name mat_name
                         ,dic.code_okei
                         ,sp.*
                     from v_rinvtosupspecs sp
                         ,fcmatresource    mat
                         ,nommodif         nm
                         ,dicnomns         n
                         ,dicmunts         dic
                    where sp.nprn = rec.tran_nrn
                      and mat.nomen_modif(+) = sp.nnommodif
                      and sp.nnommodif = nm.rn
                      and n.rn = nm.prn
                      and n.umeas_main = dic.rn
                    order by sp.snomenname, sp.ssernumb --, sp.dbegindate, sp.nquant desc
                   )
      loop
      
        make_sheet_lines(sdate
                        ,nvl(spec.mat_name, spec.snomenname)
                        ,spec.ssernumb
                        ,' '
                        , --spec.S13459633, 
                         spec.code_okei
                        ,spec.spricemeas
                        ,spec.nquant
                        ,spec.nquant);
      end loop;
      --удаляем техническую строку
      prsg_excel.line_delete(ll_line);
    
      prsg_excel.cell_value_write(c_sklad, sSklad /*sklad*/);
      if stech is not null then
        prsg_excel.cell_value_write(c_stech, stech);
        prsg_excel.cell_value_write(c_stechpos, sposttech);
      else
        prsg_excel.cell_value_write(c_stech, rec.agnabbr);
        prsg_excel.cell_value_write(c_stechpos, rec.emppost);
      end if;
    
    end loop;
  
  elsif 'GoodsTransInvoicesToConsumers' = srazd then
    -- Расходные накладные на отпуск потребителям (TRANSINVCUST)
  
    for rec in (select tran.rn      tran_nrn
                      ,ag1.agnabbr  agnabbr_kl
                      ,ag1.emppost  emppost_kl
                      ,ag2.agnabbr
                      ,ag2.emppost
                      ,tran.pref
                      ,tran.numb
                      ,tran.docdate
                      , --tran.work_date, --tran.faceacc, --tran.sfaceacc,
                       az1.azs_name azs_name1
                      ,ag2.agnname  azs_name2
                      ,tran.stoper -- ОтпМатНаСт 52567102
                  from selectlist     sl
                      ,transinvcust   tran
                      ,azsazslistmt   az1
                      , --AZSAZSLISTMT az2,
                       agnlist        ag1
                      ,agnlist        ag2
                      ,agnlist        ag3
                      ,ins_department ind
                 where sl.ident = nident
                   and sl.document = tran.rn -- 64471339
                   and tran.company = udo_rep_transinvdept_m11.ncompany
                   and tran.store = az1.rn(+)
                   and tran.acc_agent = ag1.rn(+)
                   and tran.mol = ag2.rn(+)
                   and tran.agent = ag3.rn(+)
                   and tran.subdiv = ind.rn(+)
                 order by tran.docdate)
    loop
    
      if instr(szayav, '(') > 0 then
        szayav := substr(szayav, instr(szayav, '('));
      end if;
    
      nsheet     := nsheet + 1;
      ssheetname := trim(rec.pref) || '-' || trim(replace(rec.numb, '/', '_'));
      make_sheet_head(ssheetname
                     ,to_char(rec.docdate, 'DD.MM.YYYY')
                     ,rec.azs_name1
                     ,rec.azs_name2
                     ,'Отпуск потребителям' /*sIzdelie*/
                     ,1 /*nKolvo*/
                     ,stheme
                     ,szakaz
                     ,setap
                     ,szayav
                     ,sinord
                     ,sextnum
                     ,rec.tran_nrn
                     ,null);
    
      for spec in (select mat.name mat_name
                         ,dic.code_okei
                         ,sp.*
                     from v_transinvcustspecs sp
                         ,fcmatresource       mat
                         ,nommodif            nm
                         ,dicnomns            n
                         ,dicmunts            dic
                    where sp.nprn = rec.tran_nrn
                      and mat.nomen_modif(+) = sp.nnommodif
                      and sp.nnommodif = nm.rn
                      and n.rn = nm.prn
                      and n.umeas_main = dic.rn                 
                    order by mat.name, sp.ssernumb
                   )
      loop
      
        make_sheet_lines(sdate
                        ,nvl(spec.mat_name, spec.snomenname)
                        ,spec.ssernumb
                        ,' '
                        ,spec.code_okei
                        ,spec.spricemeas
                        ,spec.nquant
                        ,spec.nquant);
      end loop;
      --удаляем техническую строку
      prsg_excel.line_delete(ll_line);
    
      prsg_excel.cell_value_write(c_sklad, rec.agnabbr_kl); -- не даем менять фамилии в отчете!
      prsg_excel.cell_value_write(c_skladpos, rec.emppost_kl);     
      prsg_excel.cell_value_write(c_stech, rec.agnabbr);
      prsg_excel.cell_value_write(c_stechpos, rec.emppost);
     
    
    end loop;

   /* Приходные ордера */
  elsif 'IncomingOrders' = srazd then
  
    for rec in (select tran.rn tran_nrn
                      ,tran.store
                      ,al.agnabbr
                      ,al.emppost
                      ,tran.rn
                      ,tran.indocpref
                      ,tran.indocnumb
                      ,tran.indocdate
                      ,tran.faceacc
                      ,(select num_value
                          from v_docs_props_vals_shadow
                         where docs_prop_rn = 12090086
                           and unitcode = 'GoodsTransInvoicesToDepts'
                           and unit_rn = tran.rn) n12090086
                      ,(select str_value
                          from v_docs_props_vals_shadow
                         where docs_prop_rn = 12090061
                           and unitcode = 'GoodsTransInvoicesToDepts'
                           and unit_rn = tran.rn) s12090061
                      ,udo_pkg_report_m4_xls.get_temetpzak(ncompany => udo_rep_transinvdept_m11.ncompany
                                                          ,nfaceacc => tran.faceacc
                                                          ,nnr_po   => tran.rn
                                                          ,ntype    => 0
                                                          ,npriem   => null) stheme
                      ,null         as azs_name1
                      ,az2.azs_name as azs_name2
                      ,''           as sprod
                      ,''           as szakaz
                      ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 193749297, ndocument => tran.rn) as sSheepType  /* Вид отгрузки из свойства */
                  from selectlist     sl
                      ,inorders       tran
                      ,azsazslistmt   az2
                      ,agnlist        al
                 where sl.ident             = nident
                   and sl.document          = tran.rn
                   and tran.company         = udo_rep_transinvdept_m11.ncompany
                   and az2.rn(+)            = tran.store
                   and tran.agent           = al.rn
                 order by tran.indocdate)
    loop
    
      if instr(rec.stheme, '/') > 0 then
        stheme := substr(rec.stheme, 0, instr(rec.stheme, '/') - 1);
        szakaz := substr(rec.stheme, instr(rec.stheme, '/') + 1);
        setap  := substr(szakaz, instr(szakaz, '/') + 1);
        szakaz := substr(szakaz, 0, instr(szakaz, '/') - 1);
      end if;
    
      if instr(szayav, '(') > 0 then
        szayav := substr(szayav, instr(szayav, '('));
      end if;
      
      begin
      select LISTAGG(TT.SERNUMB, ';') WITHIN GROUP (order by TT.SERNUMB)
        into sSerZamen
        from (select distinct gp.sernumb 
                from GOODSPARTIES   gp,
                     GOODSSUPPLY    gs,
                     RINVTOSUPSPECS sp,
                     DOCLINKS       dl1,
                     ININVOICES     inv,
                     DOCLINKS       dl2,
                     INORDERSPECS   ord
               where gp.rn = gs.prn
                 and gs.rn = sp.goodssupply
                 and sp.PRN = dl1.in_document
                 and inv.rn = dl1.out_document
                 and inv.rn = dl2.in_document
                 and dl2.out_document = ord.prn
                 and ord.nommodif = sp.nommodif
                 and ord.prn = rec.tran_nrn) TT;
      exception
        when NO_DATA_FOUND then
          sSerZamen := null;
      end;

      nsheet     := nsheet + 1;
      ssheetname := trim(rec.indocpref) || '-' || trim(replace(rec.indocnumb, '/', '_'));
      make_sheet_head(ssheetname
                     ,to_char(rec.indocdate, 'DD.MM.YYYY')
                     ,rec.azs_name1
                     ,rec.azs_name2
                     ,sizdelie
                     ,1 /*nKolvo*/
                     ,stheme
                     ,szakaz
                     ,setap
                     ,szayav
                     ,sinord
                     ,sextnum
                     ,rec.rn
                     ,case when cmp_vc2( rec.sSheepType, 'Замена серии' ) = 1 then  rec.sSheepType || ': ' || sSerZamen end );
    
      for spec in (select mat.name mat_name
                         ,dic.code_okei
                         ,(select str_value
                             from v_docs_props_vals_shadow
                            where docs_prop_rn = 13459633
                              and unitcode = 'GoodsTransInvoicesToDeptsSpecs'
                              and unit_rn = nrn) s13459633
                         ,sp.*
                     from v_inorderspecs       sp
                         ,fcmatresource        mat
                         ,nommodif             nm
                         ,dicnomns             n
                         ,dicmunts             dic
                    where sp.nprn             = rec.tran_nrn
                      and mat.nomen_modif(+)  = sp.nnommodif
                      and sp.nnommodif        = nm.rn
                      and n.rn                = nm.prn
                      and n.umeas_main        = dic.rn
                    order by mat.name, sp.ssernumb
                   )
      loop
      
        make_sheet_lines(sdate
                        ,nvl(spec.mat_name, spec.snomenname)
                        ,spec.ssernumb
                        ,spec.s13459633
                        ,spec.code_okei
                        ,spec.spricemeas
                        ,spec.nplanquant
                        ,spec.nfactquant );
      end loop;
      --удаляем техническую строку
      prsg_excel.line_delete(ll_line);
    
      prsg_excel.cell_value_write(c_sklad, sSklad /*sklad*/);
      if stech is not null then
        prsg_excel.cell_value_write(c_stech, stech);
        prsg_excel.cell_value_write(c_stechpos, sposttech);
      else
        prsg_excel.cell_value_write(c_stech, rec.agnabbr);
        prsg_excel.cell_value_write(c_stechpos, rec.emppost);
      end if;
    
    end loop;
    
  else
    p_exception(0, 'Из раздела ' || srazd || ' печатать Требование-Накладную пока невозможно.');
  end if;

  /* Удаление листа шаблона */
  if nsheet > 0 then
    prsg_excel.sheet_delete(ssheet_name => c_slist);
  end if;

  /* Включение защиты от редактирования */
  prsg_excel.execute_macros(smacros_name => 'sheet_protect');

end udo_rep_transinvdept_m11;
/
