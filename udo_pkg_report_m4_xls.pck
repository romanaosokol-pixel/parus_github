create or replace package udo_pkg_report_m4_xls is

  function get_temetpzak
  (
    ncompany in number
   , -- Организация
    nfaceacc in number
   ,nnr_po   in number
   ,ntype    in number
   , -- 0 - TEM/ЗАК; 1 - Заяв/ЭТАП 
    npriem   in number -- Приемка из спецификации Приходного ордера n13884319
  ) return varchar2;

  /* Формирование отчета */
  procedure xls_make
  (
    ncompany      in number
   , -- Организация
    nident        in number
   ,spodpisant1   in varchar2
   , -- Подписант
    skladovshik   in varchar2
   , -- Кладовщик
    nflag         in number
   , -- выводить инициатора счета в подпись
    nnote         in number
   , -- 0- не выводить примечание 1 - выводить
    sskladprikhod in varchar2
   , -- Склад оприходования
    nreturn       in number
  );

  procedure sheet_data_make
  (
    ncompany      in number
   , -- Организация
    nrn           in number
   , -- Рег. номер ПО
    spodpisant1   in varchar2
   , -- Подписант
    skladovshik   in varchar2
   , -- Кладовщик
    nflag         in number
   , -- выводить инициатора счета в подпись
    nsheet        in number
   ,nnote         in number
   , -- 0- не выводить примечание 1 - выводить
    sskladprikhod in varchar2
   , -- Выбор склада-оприходования
    nreturn       in number --- учесть возвраты  
  );

end udo_pkg_report_m4_xls;
/
create or replace package body udo_pkg_report_m4_xls is
  /* 
  30/04/2025 Переделал вычитывание связей, т.к. началася too_many_rows с появлением связей с РН на возврат поставщикам 
  09/01/2024 Степанов М. "Структурное подразделение". Если в складе заполнено подразделение, берём его, иначе "Отдел снабжения" 
  12/10/2023 Степанов М. Добавил номер изделия к колонке "наименование, сорт, размер, марка". 
  В качестве номера берутся символы после последнего подчёркивания из RLARTICLES.CODE, заключённые в скобки. 
  */

  sheet_data pkg_std.tstring := 'TDSheet'; -- Титульный лист.
  --SZAG_PR            PKG_STD.tSTRING := 'ПЕРИОД';    -- Заголовок
  line_data      pkg_std.tstring := 'ЛИНДАН'; -- Линия отчета с данными
  iline_data_beg integer := 16; -- Номер начальной строки
  -- 16/11/2022 Марков МВ. доп. ячейки для прихова давальческого материала
  sdaval       pkg_std.tstring := 'давальческое';
  sagent       pkg_std.tstring := 'контрагент';
  nmodif       pkg_std.tnumber;
  cell_sreturn pkg_std.tstring := 'sreturn';

  /* Выбор листа и Объявление ячеек листа  */
  procedure cell_describe_sheet_data(ssheet_data in varchar2) is
  begin
    prsg_excel.sheet_select(ssheet_data);
    /* Параметры отчета */
    --PRSG_EXCEL.CELL_DESCRIBE(SZAG_PR);
    prsg_excel.line_describe(line_data);
    -- 16/11/2022 Марков МВ.
    -- доп. ячейки для прихова давальческого материала
    prsg_excel.cell_describe(scell_name => sdaval);
    prsg_excel.cell_describe(scell_name => sagent);
    prsg_excel.cell_describe(scell_name => cell_sreturn);
  end;

  /* Запись значения ячеек строки таблицы */
  procedure tabcell_write
  (
    ncolumn   in varchar2
   , -- Имя колонки в отчете
    srow_name in varchar2
   , -- Имя строки в отчете
    svalue    in varchar2 := null
   , -- Значение (строка)
    nvalue    in number := null
   , -- Значение (число)
    sformula  in varchar2 := null -- формула
  ) is
    sxlsname pkg_std.tstring; -- Имя ячейки на Excel-листе
  begin
    sxlsname := ncolumn || srow_name;
    prsg_excel.cell_describe(sxlsname);
    case
      when svalue is not null then
        prsg_excel.cell_value_write(sxlsname, svalue);
      when nvalue is not null then
        prsg_excel.cell_value_write(sxlsname, nvalue);
      when sformula is not null then
        prsg_excel.cell_formula_write(sxlsname, sformula);
      else
        null;
    end case;
  
  end tabcell_write;

  function get_zayav -- Аналог UDO_F_INORDERS_DEPORD_NUMB только с учетом Модификации
  (
    nrn    in number
   ,nmodif in number
  ) return varchar2 is
    sres pkg_std.tstring;
  begin
    for cc in (select '' as sname
                     ,udo_f_payaccinsp_ext_depord(pspec.rn) as sname2
                 from doclinks     dl_pn
                     ,doclinks     dl_pi
                     ,payaccinspec pspec
                where dl_pn.out_document = nrn
                  and dl_pn.out_unitcode = 'IncomingOrders'
                  and dl_pn.in_unitcode = 'IncomingInvoices'
                  and dl_pi.out_document = dl_pn.in_document
                  and dl_pi.in_unitcode = 'PaymentAccountsIn'
                  and dl_pi.in_document = pspec.prn
                  and pspec.nommodif = nmodif
               union all
               select trim(dpo.ord_pref) || '-' || trim(dpo.ord_numb) as sname
                     ,udo_f_get_doc_prop_val(ndoc => dpo.rn, sprop => 'НОМ_ЗЯВКИ') as sname2
                 from departmentord dpo
                     ,doclinks      dl
                where dl.in_document = dpo.rn
                  and dl.in_unitcode = 'DepartmentsOrders'
                  and dl.out_unitcode = 'IncomingOrders'
                  and dl.out_document = nrn
                order by sname
                        ,sname2)
    loop
      if sres is null
         or cc.sname2 is not null
         and instr(sres, cc.sname2) = 0 then
        -- частично избавимся от дублей. KHOK 21/11/2023
        if cc.sname2 is not null then
          cc.sname := cc.sname || ' (' || cc.sname2 || ')';
        end if;
      end if;
      if sres is null then
        sres := cc.sname;
      elsif sres like '%' || cc.sname || '%' then
        null;
      elsif length(sres || ', ' || cc.sname) < 400 then
        sres := sres || ', ' || cc.sname;
      end if;
    end loop;
    return sres;
  
    /*    exception
      when NO_DATA_FOUND then
    return RTRIM(SREZ, ';');*/
  end get_zayav;

  function get_temetpzak
  (
    ncompany in number
   , -- Организация
    nfaceacc in number
   ,nnr_po   in number
   ,ntype    in number
   , -- 0 - TEM/ЗАК; 1 - Заяв/ЭТАП; 2- Приемка
    npriem   in number -- Приемка из спецификации Приходного ордера
  ) return varchar2 is
    srez pkg_std.tstring;
    stem pkg_std.tstring;
    setp pkg_std.tstring;
    szak pkg_std.tstring;
    szay pkg_std.tstring;
    sprm pkg_std.tstring;
  begin
    --for data_ in (select c.faceaccount from INORDERSPECSCLC c where c.PRN = INORDERSPECS and c.quant_plan > 0 )loop
    /* Поиск по проектам */
    begin
      select trim(p.name_usl) tem
            ,trim(sp.numb) etp
            ,trim(f.numb) zak
        into stem
            ,setp
            ,szak
        from projectstage sp
            ,project      p
            ,faceacc      f
       where sp.faceacc /*cust*/
             = nfaceacc /*data_.faceaccount*/
         and sp.company = ncompany
         and sp.prn = p.rn
         and sp.faceacc = f.rn;
    exception
      when no_data_found then
        /* Поиск по договорам */
        begin
          select udo_f_get_doc_prop_val(ndoc  => st.prn
                                       ,sprop => 'Условное наименовани') tem
                ,trim(st.numb) etp
                ,f.numb /*udo_f_get_doc_prop_val(NDOC => st.rn,SPROP => 'ШПЗ')*/ zak
            into stem
                ,setp
                ,szak
            from stages  st
                ,faceacc f
           where f.rn = nfaceacc /*data_.faceaccount*/
             and st.company = ncompany
             and f.numb = udo_f_get_doc_prop_val(ndoc => st.rn, sprop => 'ШПЗ');
        exception
          when no_data_found then
            stem := '-';
            setp := '-';
            szak := '-';
        end;
    end;
  
    -- ПРИЕМКА, сначала из строки ПО
    for do in (select --UDO_F_GET_DOC_PROP_VAL(NDOC => DL_DPO.IN_DOCUMENT, SPROP => 'НОМ_ЗЯВКИ') ZAY,
                udo_f_get_doc_prop_val(ndoc => dl_dpo.in_document, sprop => 'ПРИЕМКА') prm
                 from doclinks dl_pn
                     ,doclinks dl_pi
                     ,doclinks dl_do
                     ,doclinks dl_dpo
                where dl_pn.out_document = nnr_po
                  and dl_pn.out_unitcode = 'IncomingOrders'
                  and dl_pn.in_unitcode = 'IncomingInvoices'
                  and dl_pi.out_document = dl_pn.in_document
                  and dl_pi.in_unitcode = 'PaymentAccountsIn'
                  and dl_pi.in_document = dl_do.out_document
                  and dl_do.in_unitcode = 'DeliveryOrders'
                  and dl_do.in_document = dl_dpo.out_document
                  and dl_dpo.in_unitcode = 'DepartmentsOrders'
               union all
               select --UDO_F_GET_DOC_PROP_VAL(NDOC => DL_PN.IN_DOCUMENT, SPROP => 'НОМ_ЗЯВКИ') ZAY,
                udo_f_get_doc_prop_val(ndoc => dl_pn.in_document, sprop => 'ПРИЕМКА') prm
                 from doclinks dl_pn
                where dl_pn.out_document = nnr_po
                  and dl_pn.out_unitcode = 'IncomingOrders'
                  and dl_pn.in_unitcode = 'DepartmentsOrders')
    loop
      --SZAY := DO.ZAY || ';' || SZAY;
      sprm := do.prm || ';' || sprm;
    end loop;
  
    case npriem
      when 1 then
        sprm := sprm || 'ОТК';
      when 5 then
        sprm := sprm || 'ВП';
      when 7 then
        sprm := sprm || 'ОСМ';
      when 9 then
        sprm := sprm || 'ОС';
      else
        if npriem is not null then
          sprm := sprm || ' ' || npriem;
        end if;
    end case;
  
    szay := trim(udo_f_inorders_depord_numb(nnr_po));
    case ntype
      when 2 then
        srez := '(' || rtrim(sprm, ';') || ')';
      when 1 then
        srez := szay || '/ ' || cr || setp || ';'; --||sREZ;
      else
        srez := stem || '/ ' || szak || ';'; --||sREZ;
    end case;
  
    return rtrim(srez, ';');
  end get_temetpzak;

  procedure sheet_data_make
  (
    nCOMPANY      in number-- Организация
   ,nRN           in number -- Рег. номер ПО
   ,sPODPISANT1   in varchar2 -- Подписант
   ,sKLADOVSHIK   in varchar2 -- Кладовщик
   ,nFLAG         in number --условие вывода в поле "Сдал" инициатора счета (0 -не выводим, 1 -выводим)
   ,nSHEET        in number
   ,nNOTE         in number -- 0- не выводить примечание 1 - выводить
   ,sSKLADPRIKHOD in varchar2 -- Выбор склада-оприходования
   ,nRETURN       in number --- учесть возвраты  
  ) 
  is
    npp          pkg_std.tnumber := 0; -- Порядковый номер записи контрактов
    ixlsname     pkg_std.tnumber := 0; -- Номер ячейки 
    nline_cont   pkg_std.tnumber := 0; -- Порядковый номер линии договоров  
    nlinebeg_f   pkg_std.tnumber := iline_data_beg; -- Начальный адрес для формулы
    nlineend_f   pkg_std.tnumber := iline_data_beg; -- Конечный адрес для формулы
    svalue_      pkg_std.tstring;
    skladovshik1 agnlist.agnabbr%type; -- Кладовщик
    spodpisant   agnlist.agnabbr%type; -- Сдал ТМЦ
    semppost     agnlist.emppost%type; -- Должность сдавшего ТМЦ
    semppostklad agnlist.emppost%type; -- Должность кладовщика
    nklad        agnlist.rn%type;
    nlock        userlist.acc_lock%type := 0;
    /*SKLADOVSHIK2      AGNLIST.AGNABBR%type;*/ -- Кладовщик - МОЛ из выдранного склада прихлода
    --sShifr            varchar2(256) := '';
    --sZayav            varchar2(256) := '';
    --sREG_AGENT        varchar2(20)  := '';
    ssheetname  varchar2(32);
    svalue_n    pkg_std.tstring;
    nvalue_tax  pkg_std.tsumm; 
    nvalue_nds  pkg_std.tsumm; 
    nvalue_s    pkg_std.tsumm; 
    nvalue_q    pkg_std.tquant;
    factsum_    pkg_std.tsumm := 0;
    factsumnds_ pkg_std.tsumm := 0;
    factsumtax_ pkg_std.tsumm := 0;
    nrec        pkg_std.tref;
    nPayAccIn   pkg_std.tref;
    rPayAccIn   payaccin%rowtype;
    rPayType    azsgsmpaymentstypes%rowtype;

  begin
    ssheetname := sheet_data || '_' || nsheet;
    prsg_excel.sheet_copy(ssheet_name_from   => sheet_data
                         ,ssheet_name_to     => ssheetname
                         ,ssheet_name_before => null
                         ,nmove_to_end       => 1);
    /* Объявление ячеек */
    cell_describe_sheet_data(ssheetname);
  
    /* Заполним заголовок */
    --SPERIOD := ' За период с ' || to_char(DBEG, 'dd.mm.yyyy') || ' по ' ||
    --           to_char(DEND, 'dd.mm.yyyy');
    --SDPRINT := 'дата печати ' || to_char(sysdate, 'dd.mm.yyyy') || 'г.';
    --PRSG_EXCEL.CELL_VALUE_WRITE(SZAG_PR, SPERIOD);
    --PRSG_EXCEL.CELL_VALUE_WRITE(SRANGE_DATEPRINT, SDPRINT);

    /* Входящйи счёт на оплату */
    nPayAccIn := f_doclinks_link_in_recurs_doc( nflag_mode    => 1
                                               ,sout_unitcode => 'IncomingOrders'
                                               ,nout_document => nRN
                                               ,sin_unitcode  => 'PaymentAccountsIn' );
    if nPayAccIn is not null then                                               
      rPayAccIn := usr_pkg_payaccin.payaccin_get( nrn => nPayAccIn );
    end if;
    
    if rPayAccIn.paytype is not null then
      select * into rPayType from azsgsmpaymentstypes where rn = rPayAccIn.paytype;
    end if;
  
    /*Определение Кладовщика и его должности*/
    if skladovshik is not null then
      --Должность, если "руками" указан кладовщик
      begin
        select trim(al.emppost)
              ,al.rn
          into semppostklad
              ,nklad
          from agnlist al
         where al.agnabbr = skladovshik;
      exception
        when no_data_found then
          semppostklad := null;
      end;
    else
      if sskladprikhod is not null then
        -- Если "руками" указан Склад приходования, то МОЛ Склада
        begin
          select trim(al.agnabbr)
                ,trim(al.emppost)
                ,al.rn
            into skladovshik1
                ,semppostklad
                ,nklad
            from azsazslistmt az
                ,agnlist      al
           where az.azs_agent = al.rn
             and az.azs_number = sskladprikhod
             and rownum = 1;
        exception
          when no_data_found then
            skladovshik1 := null;
            semppostklad := null;
        end;
      elsif sskladprikhod is null then
        -- Если склад приходования не указан, то МОЛ из Приходного Ордера
        begin
          select trim(al.agnabbr)
                ,trim(al.emppost)
                ,al.rn
            into skladovshik1
                ,semppostklad
                ,nklad
            from inorders     i
                ,azsazslistmt az
                ,agnlist      al
           where az.azs_agent = al.rn
             and i.store = az.rn
             and i.rn = nrn
             and al.agnabbr not in ('Администратор', 'Автомат WEB API')
             and rownum = 1;
        exception
          when no_data_found then
            skladovshik1 := null;
            semppostklad := null;
        end;
      end if;
    end if;
  
    /* Вывод Кладовщика и его должности*/
    if skladovshik is not null then
      -- Если "руками" указан кладовщик, то подпись его
      -- Проверим блокировку пользователя
      begin
        select ul.acc_lock
          into nlock
          from userlist   ul
              ,clnpersons cp
              ,agnlist    ag
         where ag.agnabbr = skladovshik
           and cp.pers_agent = ag.rn
           and ul.authid = cp.pers_authid;
      exception
        when no_data_found then
          nlock := 0;
      end;
      if 1 = nlock then
        tabcell_write(ncolumn => 'S', srow_name => 19, svalue => ' ');
      else
        tabcell_write(ncolumn => 'S', srow_name => 19, svalue => skladovshik);
      end if;
    
    else
      /* if sSKLADPRIKHOD is null then*/ -- Если "руками" не указан кладовщик и "руками" не указан Склад приходования, то подпись МОЛ из ПО     
      tabcell_write(ncolumn => 'S', srow_name => 19, svalue => skladovshik1);
      /*else
        TABCELL_WRITE(nCOLUMN   => 'S', -- Если "руками" не указан кладовщик и указан Склад приходования, то подпись МОЛ из Склада
                  sROW_NAME => 19,
                  sVALUE    => SKLADOVSHIK2);
      end if;*/
    end if;
  
    if 1 = nlock then
      tabcell_write(ncolumn => 'E', srow_name => 19, svalue => ' ');
    else
      tabcell_write(ncolumn => 'E', srow_name => 19, svalue => semppostklad);
    end if;
  
    /* Штрих-код */
    tabcell_write(ncolumn => 'A', srow_name => 2, nvalue => nrn);
  
    /* Подпись Сдал */
  
    /*    if SPODPISANT1 is not null then
       TABCELL_WRITE(nCOLUMN => 'S', sROW_NAME => 21, sVALUE => SPODPISANT1);
       --TABCELL_WRITE(nCOLUMN => 'E', sROW_NAME => 21, sVALUE => data_Z.emppost);
    end if;*/
  
    /* Шапка */
    for data_dd in (select s.rn
                          ,trim(s.indocpref) || '-' || trim(s.indocnumb) indocnumb
                          ,get_agnlist_agnname_id(nflag_smart => 0
                                                 ,nrn         => get_jurpersons_agent(ncompany  => s.company
                                                                                     ,njur_pers => aa.rn)) sagent
                          ,to_char(s.indocdate, 'dd.mm.yyyy') indocdate
                          ,so.gsmways_mnemo
                          ,st.azs_name
                           --.azs_number,
                          ,a.agnname
                          ,a.agnidnumb
                           --agnabbr,
                           --dcon.doccode || ' №' || s.confdocnumb || ' от ' || to_char(s.confdocdate, 'dd.mm.yyyy') confdocnumb,
                          ,dinv.doccode || ' № ' || s.invdocnumb invdocnumb
                           /* nvl(agen.agnabbr, 'PaymentAccountsIn') Reg_Agent,
                                 nvl(agen.emppost, 'Ведущий инженер') Emppost, */
                          ,s.factsumtax
                          ,s.docstatus
                          ,nvl(div.name, 'Отдел снабжения') as div_name
                          ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 193749297, ndocument => s.rn) as sSheepType /* Вид отгрузки */
                      from inorders        s
                          ,doctypes        dcon
                          ,doctypes        dinv
                          ,agnlist         a
                          ,jurpersons      aa
                          ,azsazslistmt    st
                          ,azsgsmwaystypes so 
                          /*,AGNLIST         agen*/
                          ,ins_department  div
                     where s.rn           = nRN
                       and s.company      = nCOMPANY
                       and s.confdoctype  = dcon.rn(+)
                       and s.invdoctype   = dinv.rn(+)
                       and s.contragent   = a.rn
                       and s.store        = st.rn
                       and s.stopertype   = so.rn
                       and s.jur_pers     = aa.rn
                       -- and s.reg_agent (+)= agen.rn
                       -- and s.reg_agent = agen.rn(+)
                       and st.department  = div.rn(+))
    loop
      /* Запрет печати по документу с видом отгрузки 'Замена серии' */
      if cmp_vc2( data_dd.sSheepType, 'Замена серии' ) = 1 then
        p_exception(0, 'Запрещена печать шаблона "Приходный ордер М-4" по документу с видом отгрузки "%s". Используйте шаблон "Требование М-11". %s'
                   ,data_dd.sSheepType
                   ,cr||f_docdescrs_get_description( sunitcode => 'IncomingOrders', ndocument => data_dd.rn ) ); 
      end if;
    
      if nreturn = 1 then
        prsg_excel.cell_value_write(scell_name  => cell_sreturn
                                   ,scell_value => 'C учетом возвратов');
      
      end if;
      
      
      --sREG_AGENT := data_Z.Reg_Agent;
      /*      if 0 = NPP then \* Подпись Сдал из ПО *\
        if SPODPISANT1 is null then
          TABCELL_WRITE(nCOLUMN => 'S', sROW_NAME => 21, sVALUE => data_dd.Reg_Agent);
        end if;
        TABCELL_WRITE(nCOLUMN => 'E', sROW_NAME => 21, sVALUE => data_dd.Emppost);
      end if; */
      /*if data_GP.ETSNG is not null and data_GP.STATIONTO is not null and
      data_GP.CONSIGNEE is not null then*/
      --p_exception(0,'Минутку! Идет тестирование: "' || data_z.confdocnumb || '" : "' || data_z.confdocnumb_new|| '"');     
    
      /* 16/11/2022 Марков МВ. для прихода давальческого материала */
      if data_dd.gsmways_mnemo in ('ПриходДавальч') then
        prsg_excel.cell_value_write(scell_name  => sdaval
                                   ,scell_value => 'ДАВАЛЬЧЕСКОЕ');
        prsg_excel.cell_value_write(scell_name => sagent, scell_value => 'Организация');
      end if;
      --<<
    
      /* заполняем Шапку */
      tabcell_write(ncolumn => 'K', srow_name => 3, svalue => data_dd.indocnumb);
      tabcell_write(ncolumn => 'F', srow_name => 5, svalue => data_dd.sagent);
      tabcell_write(ncolumn => 'B', srow_name => 11, svalue => data_dd.indocdate);
      tabcell_write(ncolumn => 'C', srow_name => 11, svalue => data_dd.gsmways_mnemo);
    
      if sskladprikhod is not null then
        --Печать склада
        tabcell_write(ncolumn => 'D', srow_name => 11, svalue => sskladprikhod);
      else
        tabcell_write(ncolumn => 'D', srow_name => 11, svalue => data_dd.azs_name); --azs_number);
      end if;
    
      tabcell_write(ncolumn => 'J', srow_name => 11, svalue => data_dd.agnname);
      tabcell_write(ncolumn => 'T', srow_name => 11, svalue => data_dd.agnidnumb); --, agnabbr);
      /* if data_dd.confdocnumb_new is null then
           TABCELL_WRITE(nCOLUMN   => 'V',
                         sROW_NAME => 11,
                         sVALUE    => data_dd.confdocnumb);
      else */
      
      tabcell_write(ncolumn => 'V', srow_name => 11, svalue => trim(rPayAccIn.ext_numb) || ', от ' || to_char(rPayAccIn.reg_date, 'DD.MM.YYYY') /*data_dd.confdocnumb_new*/);
      /*end if;  */
    
      if instr(/*data_dd*/rPayType.gsmpayments_name, 'аличн') > 0 then
        tabcell_write(ncolumn   => 'AE'
                     ,srow_name => 11
                     ,svalue    => trim(data_dd.invdocnumb || ' (' || /*data_dd.*/rPayType.gsmpayments_name || ')'));
      else
        tabcell_write(ncolumn => 'AE', srow_name => 11, svalue => trim(data_dd.invdocnumb));
      end if;
    
      if nflag = 1 then
        spodpisant := udo_f_payaccin_author( nrn => rPayAccIn.rn ) /*data_dd.podpisant*/ ; --Если отмечен "Сдал инициатор счета", то выводим его
      elsif spodpisant1 is not null then
        spodpisant := spodpisant1; -- Иначе выбранный пользователем
      end if;
    
      /* 09/01/2024 Степанов М. "Структурное подразделение". Если в складе заполнено подразделение, берём его, иначе "Отдел снабжения" */
      tabcell_write(ncolumn => 'F', srow_name => 7, svalue => data_dd.div_name);
    
      -- Проверим блокировку пользователя
      begin
        select ul.acc_lock
          into nlock
          from userlist   ul
              ,clnpersons cp
              ,agnlist    ag
         where ag.agnabbr = spodpisant
           and cp.pers_agent = ag.rn
           and ul.authid = cp.pers_authid;
      exception
        when no_data_found then
          nlock := 0;
      end;
    
      if 1 = nlock then
        spodpisant := null;
        semppost   := ' ';
      elsif spodpisant in ('Администратор', 'Автомат WEB API') then
        spodpisant := null;
      end if;
    
      -- Определение должности подписанта        
      begin
        select al.emppost into semppost from agnlist al where al.agnabbr = spodpisant;
      exception
        when no_data_found then
          semppost := ' ';
      end;
    
      tabcell_write(ncolumn => 'S', srow_name => 21, svalue => spodpisant);
      tabcell_write(ncolumn => 'E', srow_name => 21, svalue => semppost);
    
      ------ Строки Ордера
      for data_d in (select (select num_value
                               from v_docs_props_vals_shadow
                              where docs_prop_rn = 13884319
                                and unitcode = 'IncomingOrdersSpecs'
                                and unit_rn = sp.rn) n13884319
                           ,(select str_value
                               from v_docs_props_vals_shadow
                              where docs_prop_rn = 8027724
                                and unitcode = 'IncomingOrdersSpecs'
                                and unit_rn = sp.rn) s8027724
                           ,sp.rn
                           ,sp.original_name
                           ,n.nomen_name
                           ,sp.note
                           ,sp.nommodif
                           ,
                            /*n.nomen_name || ' (' ||
                            (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 12114824 and UNITCODE = 'IncomingOrdersSpecs' and UNIT_RN = sp.rn)  || ')' Nomen_Name_F, */sp.sernumb
                           , --n.nomen_code,
                            d.code_okei
                           ,d.meas_mnemo
                           ,sp.planquant - nvl(vz.quant, 0) planquant
                           ,sp.factquant - nvl(vz.quant, 0) factquant
                           ,round(sp.factsum / sp.factquant, 2) price
                           ,
                            --round(sp.price, 2) price,
                            sp.factsum - nvl(vz.summ, 0) factsum
                           ,sp.factsumnds
                           ,sp.factsumtax
                           ,cl.rn clc_rn
                           ,nvl(cl.quant_plan, 0) - nvl(vz.quant, 0) quant_plan
                           ,nvl(cl.quant_fact, 0) - nvl(vz.quant, 0) quant_fact
                           ,cl.cost_plan
                           ,cl.quant_plan * sp.factsum / sp.factquant cl_plansum
                           ,cl.quant_fact * sp.factsum / sp.factquant cl_factsum
                           ,
                            --cl.quant_plan*sp.price/*cl.quant_plan*/ cl_plansum,
                            sp.factsumnds * nvl(cl.quant_plan, 0) / sp.factquant cl_plansumnds
                           ,sp.factsumnds * nvl(cl.quant_fact, 0) / sp.factquant cl_factsumnds
                           ,sp.factsumtax * nvl(cl.quant_plan, 0) / sp.factquant cl_plansumtax
                           ,sp.factsumtax * nvl(cl.quant_fact, 0) / sp.factquant cl_factsumtax
                           ,cl.faceaccount
                           ,
                            -- (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 8027721 and UNITCODE = 'DepartmentsOrders' and UNIT_RN = sp.rn) sZayav
                            0 as nuslugi
                           ,decode(ra.code
                                  ,null
                                  ,null
                                  ,'(' || substr(ra.code, instr(ra.code, '_', -1) + 1) || ')') as sarticle_num /*12/10/2023 Степанов М. Добавил номер изделия к колонке "наименование, сорт, размер, марка". */
                       from inorderspecs sp
                       left join inorderspecsclc cl
                         on sp.rn = cl.prn
                       left join nommodif m
                         on sp.nommodif = m.rn
                       left join dicnomns n
                         on m.prn = n.rn
                       left join dicmunts d
                         on d.rn = n.umeas_main
                       left join rlarticles ra
                         on ra.rn = sp.article /*12/10/2023 Степанов М. Добавил номер изделия к колонке "наименование, сорт, размер, марка". */
                       left join (select dl.in_document rn
                                       ,vps.nommodif
                                       ,vps.quant
                                       ,vps.summtax
                                       ,vps.summ
                                       ,vps.sernumb
                                       ,vps.summ_nds
                                   from doclinks dl
                                   join rinvtosup vp
                                     on vp.rn = dl.out_document
                                   join rinvtosupspecs vps
                                     on vps.prn = vp.rn
                                  where nreturn = 1 -- Если учитываем 
                        
                                  ---dl.in_document = 44084073 and 
                              and dl.out_unitcode = 'ReturnInvoicesToSuppliers'
                              and dl.in_unitcode = 'IncomingOrders'
                              and vp.status = 1) vz
                         on vz.rn = sp.prn
                        and sp.nommodif = vz.nommodif
                        and nvl(vz.sernumb, '_!_') = nvl(sp.sernumb, '_!_')
                      where  sp.prn = data_dd.rn
                        and sp.company = ncompany
                     --    and CL.QUANT_PLAN is not null -- ??? Может пусть 0 то же выходят 
                     --    and CL.QUANT_PLAN > 0 -- ???
                     union -- Услуги
                     select (select num_value
                               from v_docs_props_vals_shadow
                              where docs_prop_rn = 13884319
                                and unitcode = 'IncomingOrdersSpecs'
                                and unit_rn = pn.rn) n13884319
                           ,null s8027724
                           ,pn.rn
                           ,pn.original_name
                           ,n.nomen_name
                           ,null note
                           ,0 nommodif
                           ,pn.sernumb
                           ,d.code_okei
                           ,d.meas_mnemo
                           ,pn.quant planquant
                           ,pn.quant factquant
                           ,pn.summ / pn.quant price
                           ,pn.summ factsum
                           ,pn.summ_nds factsumnds
                           ,pn.summtax factsumtax
                           ,null clc_rn
                           ,pn.quant quant_plan
                           ,pn.quant quant_fact
                           ,null cost_plan
                           ,null cl_plansum
                           ,pn.summ cl_factsum
                           ,null cl_plansumnds
                           ,pn.summ_nds cl_factsumnds
                           ,null cl_plansumtax
                           ,pn.summtax cl_factsumtax
                           ,null faceaccount
                           ,1 as nuslugi
                           ,null as sarticle_num /*12/10/2023 Степанов М. Добавил номер изделия к колонке "наименование, сорт, размер, марка". */
                       from ininvoicesspecs pn
                           ,doclinks        dl
                           ,nommodif        m
                           ,dicnomns        n
                           ,dicmunts        d
                      where dl.in_document = pn.prn
                        and dl.in_unitcode = 'IncomingInvoices'
                        and dl.out_unitcode = 'IncomingOrders'
                        and dl.out_document = data_dd.rn
                        and pn.company = ncompany
                        and pn.nomen = n.rn
                        and pn.modif = m.rn
                        and m.prn = n.rn
                        and n.nomen_type = 2 --in (2, 3) -- Услуга, Тара
                        and n.umeas_main = d.rn(+)
                      order by nuslugi
                              ,n13884319
                              ,original_name
                              ,sernumb /*,
                                                                         FACEACCOUNT*/
                     )
      loop
        nmodif := data_d.nommodif;
      
        if nvl(nrec, 0) != data_d.rn then
          nrec := data_d.rn;
        
          factsum_    := data_d.factsum;
          factsumnds_ := data_d.factsumnds;
          factsumtax_ := data_d.factsumtax;
        end if;
        /* Формирование номера строки */
        case npp
          when 0 then
            nline_cont := prsg_excel.line_append(line_data);
          else
            nline_cont := prsg_excel.line_continue(line_data);
        end case;
        npp      := npp + 1;
        ixlsname := iline_data_beg + nline_cont;
      
        case nnote
          when 1 then
            svalue_n := data_d.nomen_name || '/ ' || data_d.original_name || ' (' ||
                        trim(data_d.note) || ')';
          else
            svalue_n := data_d.nomen_name || '/ ' || data_d.original_name;
            svalue_n := strcombine(svalue_n, data_d.sarticle_num, '/ '); /*12/10/2023 Степанов М. Добавил номер изделия к колонке "наименование, сорт, размер, марка". */
        end case;
        tabcell_write(ncolumn => 'B', srow_name => ixlsname, svalue => svalue_n); --data_D.Nomen_Name||' ('||data_D.original_name||')');
        tabcell_write(ncolumn => 'G', srow_name => ixlsname, svalue => nvl(data_d.sernumb, '-')); --nomen_code);
        tabcell_write(ncolumn => 'H', srow_name => ixlsname, svalue => data_d.code_okei);
        tabcell_write(ncolumn => 'J', srow_name => ixlsname, svalue => data_d.meas_mnemo);
        tabcell_write(ncolumn   => 'N'
                     ,srow_name => ixlsname
                     ,nvalue    => nvl(data_d.quant_plan, data_d.factquant));
      
        if nvl(data_d.quant_fact, 0) != 0 then
          nvalue_q := data_d.quant_fact;
        else
          nvalue_q := data_d.quant_plan;
        end if;
        tabcell_write(ncolumn => 'P', srow_name => ixlsname, nvalue => nvalue_q); --nvl(data_d.quant_plan,Data_d.factquant));
        tabcell_write(ncolumn => 'Q', srow_name => ixlsname, nvalue => data_d.price);
      
        if data_dd.docstatus != 0
           or data_d.nuslugi = 1 --data_d.quant_fact > 0 /*NVL(data_d.factsum,0) !=0 */ 
         then
          nvalue_s   := data_d.cl_factsum;
          nvalue_nds := data_d.cl_factsumnds;
          nvalue_tax := data_d.cl_factsumtax;
        else
          nvalue_s   := data_d.cl_plansum;
          nvalue_nds := data_d.cl_plansumnds;
          nvalue_tax := data_d.cl_plansumtax;
        end if;
      
        factsum_    := factsum_ - nvalue_s;
        factsumnds_ := factsumnds_ - nvalue_nds;
        factsumtax_ := factsumtax_ - nvalue_tax;
      
        if (factsum_ < 0 or (factsum_ < 0.03 and factsum_ > 0)) then
          nvalue_s := nvalue_s + factsum_;
        end if;
        tabcell_write(ncolumn => 'U', srow_name => ixlsname, nvalue => nvalue_s); --NVL(data_d.cl_plansum,data_d.factsum));
      
        if (factsumnds_ < 0 or (factsumnds_ < 0.03 and factsumnds_ > 0)) then
          nvalue_nds := nvalue_nds + factsumnds_;
        end if;
        tabcell_write(ncolumn => 'W', srow_name => ixlsname, nvalue => nvalue_nds); -- NVL(data_d.cl_plansumnds, data_d.factsumnds));
      
        if (factsumtax_ < 0 or (factsumtax_ < 0.03 and factsumtax_ > 0)) then
          nvalue_tax := nvalue_tax + factsumtax_;
        end if;
        tabcell_write(ncolumn => 'AA', srow_name => ixlsname, nvalue => nvalue_tax); --NVL(data_d.cl_plansumtax, data_d.factsumtax));
      
        tabcell_write(ncolumn   => 'AD'
                     ,srow_name => ixlsname
                     ,svalue    => get_temetpzak(ncompany, data_d.faceaccount, null, 0, null));
      
        if data_d.faceaccount is not null then
          if data_d.s8027724 is not null then
            svalue_ := get_zayav(data_dd.rn, data_d.nommodif) --UDO_F_INORDERS_DEPORD_NUMB(DATA_D.RN)
                      --GET_TEMETPZAK(NCOMPANY, DATA_D.FACEACCOUNT, DATA_DD.RN, 1, null) 
                       || ' ' || data_d.s8027724;
          else
            svalue_ := get_zayav(data_dd.rn, data_d.nommodif) --UDO_F_INORDERS_DEPORD_NUMB(DATA_D.RN)
                      --GET_TEMETPZAK(NCOMPANY, DATA_D.FACEACCOUNT, DATA_DD.RN, 1, null) 
                       ;
            --if utilizer = 'KHOK' then p_exception(0, data_d.n12114820 || ' - ' || data_d.s8027724 || ' - ' || data_d.FACEACCOUNT || ' !!! ' || SVALUE_); end if;
          end if;
        
        else
          svalue_ := null;
        end if;
      
        tabcell_write(ncolumn => 'AG', srow_name => ixlsname, svalue => svalue_); --GET_TEMETPZAK(ncompany,data_d.FACEACCOUNT,data_z.rn,1)||' '||GET_TEMETPZAK(ncompany,data_d.FACEACCOUNT,data_z.rn,2));
      
        /* TABCELL_WRITE(nCOLUMN   => 'AG',
                                sROW_NAME => iXLSNAME,
                                SVALUE    => trim(sZayav) \*|| ' / ' || GET_TEMETPZAK(ncompany,data_d.FACEACCOUNT,1)*\);
        */
        /*TABCELL_WRITE(nCOLUMN   => 'V',
                      sROW_NAME => iXLSNAME,
                      sVALUE    => data_w.PAYER); -- note
        TABCELL_WRITE(nCOLUMN   => 'W',
                      sROW_NAME => iXLSNAME,
                      sVALUE    => TO_CHAR(data_w.DOCDATE, 'dd.mm.yyyy')); -- note*/
        nlineend_f := ixlsname;
        if nrec != data_d.rn then
        
          factsum_    := 0;
          factsumnds_ := 0;
          factsumtax_ := 0;
        end if;
      end loop;
    
      /*case NPP
        when 0 then
          nLINE_CONT := PRSG_EXCEL.LINE_APPEND(LINE_DATA);
          NPP        := NPP + 1;
        else
          nLINE_CONT := PRSG_EXCEL.LINE_CONTINUE(LINE_DATA);
          NPP        := NPP + 1;
      end case;*/
      ixlsname := nlineend_f + 1;
      /* Формулы */
      /*TABCELL_WRITE(nCOLUMN   => 'P',
                    sROW_NAME => iXLSNAME,
                    sVALUE    => 'Итого по группе');
      PRSG_EXCEL.CELL_DESCRIBE('H' || iXLSNAME);
      PRSG_EXCEL.MERGE_CELLS(sCELL_NAME_FROM => 'A' || iXLSNAME,
                             sCELL_NAME_TO   => 'H' || iXLSNAME);*/
      tabcell_write(ncolumn   => 'P'
                   ,srow_name => ixlsname
                   ,sformula  => '=СУММ(P' || nlinebeg_f || ':P' || nlineend_f || ')');
      tabcell_write(ncolumn   => 'U'
                   ,srow_name => ixlsname
                   ,sformula  => '=СУММ(U' || nlinebeg_f || ':U' || nlineend_f || ')');
      tabcell_write(ncolumn   => 'W'
                   ,srow_name => ixlsname
                   ,sformula  => '=СУММ(W' || nlinebeg_f || ':W' || nlineend_f || ')');
      tabcell_write(ncolumn   => 'AA'
                   ,srow_name => ixlsname
                   ,sformula  => '=СУММ(AA' || nlinebeg_f || ':AA' || nlineend_f || ')');
    
    /*PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => 'A' || iXLSNAME,
                                                  sATTRIBUTE_NAME  => 'Font.FontStyle',
                                                  sATTRIBUTE_VALUE => 'bold');
                    PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => 'I' || iXLSNAME,
                                                  sATTRIBUTE_NAME  => 'Font.FontStyle',
                                                  sATTRIBUTE_VALUE => 'bold');
                    PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => 'J' || iXLSNAME,
                                                  sATTRIBUTE_NAME  => 'Font.FontStyle',
                                                  sATTRIBUTE_VALUE => 'bold');
                    PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => 'K' || iXLSNAME,
                                                  sATTRIBUTE_NAME  => 'Font.FontStyle',
                                                  sATTRIBUTE_VALUE => 'bold');
                    PRSG_EXCEL.CELL_ATTRIBUTE_SET(sCELL_NAME       => 'M' || iXLSNAME,
                                                  sATTRIBUTE_NAME  => 'Font.FontStyle',
                                                  sATTRIBUTE_VALUE => 'bold');*/
    --  end if;
    end loop;
  
    prsg_excel.line_delete(line_data);
  end sheet_data_make;

  /* Формирование отчет */
  procedure xls_make
  (
    ncompany      in number
   , -- Организация
    nident        in number
   , -- ИД помеченных записей  
    spodpisant1   in varchar2
   , -- Подписант
    skladovshik   in varchar2
   , -- Кладовщик
    nflag         in number
   , -- 1 - выводить инициатора счета в подпись
    nnote         in number
   , -- 0- не выводить примечание 1 - выводить
    sskladprikhod in varchar2
   , -- Склад приходования
    nreturn       in number --- учесть возвраты  
  ) is
    sunitcode pkg_std.tstring := 'IncomingOrders';
    nsheet    number := 0;
  begin
    for dd in (select s.document
                 from selectlist s
                where s.ident = nident
                  and s.unitcode = sunitcode
               /*and rownum = 1*/
               )
    loop
      nsheet := nsheet + 1;
    
      sheet_data_make(ncompany      => ncompany
                     ,nrn           => dd.document
                     ,spodpisant1   => spodpisant1
                     ,skladovshik   => skladovshik
                     ,nflag         => nflag
                     ,nsheet        => nsheet
                     ,nnote         => nnote
                     ,sskladprikhod => sskladprikhod
                     ,nreturn       => nreturn);
    end loop;
    /* Удаление листа шаблона */
    if nsheet > 0 then
      prsg_excel.sheet_delete(ssheet_name => sheet_data);
    end if;
  end xls_make;

end udo_pkg_report_m4_xls;
/
