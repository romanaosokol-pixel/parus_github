create or replace procedure UDO_REP_DEPORDDIR_CHANGE(
       nCOMPANY   in number,   -- Организация
       sRAZDEL    in varchar2, -- Раздел из которого запускается отчет
       nIDENT     in number,   -- Выбранная строка
       sIspol     in varchar2, -- Исполнитель
       sOMTS      in varchar2, -- Начальник подразделения
       sKonstr    in varchar2, -- Главный конструктор
       sPodr      in varchar2  -- Подразделение
) is
-- Отчет Ведомость замен. KHOK
  C_SLIST     constant PKG_STD.TSTRING := 'TDSheet'; -- Лист
-- Шапка
  C_sPodr     constant PKG_STD.TSTRING := 'sPodr';
  C_sZakaz    constant PKG_STD.TSTRING := 'sZakaz';
  C_sIzdelie  constant PKG_STD.TSTRING := 'sIzdelie';
  C_sName     constant PKG_STD.TSTRING := 'sName';
  C_sZav      constant PKG_STD.TSTRING := 'sZav';
  C_sNameLong constant PKG_STD.TSTRING := 'sNameLong';

  C_sIspol    constant PKG_STD.TSTRING := 'sIsp';
  C_sOMTS     constant PKG_STD.TSTRING := 'sOMTS';
  C_sKonstr   constant PKG_STD.TSTRING := 'sKonstr';
  C_sNach     constant PKG_STD.TSTRING := 'sNach';

  LL_LINE     constant PKG_STD.TSTRING := 'L_LINE';
  C_nPP       constant PKG_STD.TSTRING := 'nPP';
  C_sFrom     constant PKG_STD.TSTRING := 'sFrom';
  C_sTo       constant PKG_STD.TSTRING := 'sTo';
  C_nKol      constant PKG_STD.TSTRING := 'nKol';
  C_sAdd      constant PKG_STD.TSTRING := 'sAdd';

  L_SECOND    constant PKG_STD.TSTRING := 'L_SECOND';
  L_HEAD      constant PKG_STD.TSTRING := 'L_HEAD';
  LL_LINE2    constant PKG_STD.TSTRING := 'L_LINE2';
  C_nPP2      constant PKG_STD.TSTRING := 'nPP_2';
  C_sFrom2    constant PKG_STD.TSTRING := 'sFrom_2';
  C_sTo2      constant PKG_STD.TSTRING := 'sTo_2';
  C_nKol2     constant PKG_STD.TSTRING := 'nKol_2';
  C_sAdd2     constant PKG_STD.TSTRING := 'sAdd2';

  nSTR        number;
  nSTR2       number;
  sSheetName  varchar2(64);
  nSheet      number := 0;
  nRows       number := 0;
  nMax        number := 10;
  --nMax2       number := 30; -- Если придется разбивать основной массив строк на страницы
  nFishRN     number := 0;
  nProdPRN    number := 0;
  nProdOrder  number := 0;
  nNest       number := 0;
  nPrnNode    number := 0;
  
  sZak     varchar2(1024);
  --sTmp     varchar2(1024);
  sIzd1    FCMATRESOURCE.NAME%type;
  sIzd2    FCMATRESOURCE.NAME%type;
  sNameIzd varchar2(512);
  sIzd     varchar2(256);
  sCode    varchar2(256);

  /* Инициализация и заголовки */
  procedure HEAD_WRITE
  (
    sSheetName    in varchar2, -- Имя колонки в отчете
    sMainProd     in varchar2, -- Заказ
    sIzd          in varchar2, -- Изделие
    f_numb        in varchar2, -- 
    CODE          in varchar2, --
    S42326178     in varchar2, -- 
    sNameLong     in varchar2
  ) 
  is
  begin
    PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM   => 'TDSheet',
                          sSHEET_NAME_TO     => sSheetName,
                          sSHEET_NAME_BEFORE => null,
                          nMOVE_TO_END       => 1);
    -- Установка текущего рабочего листа
    PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sSheetName);
    -- Описываем имена ячеек в шапке
    PRSG_EXCEL.CELL_DESCRIBE(C_sPodr);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZakaz);
    PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie);
    PRSG_EXCEL.CELL_DESCRIBE(C_sName);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZav);
    PRSG_EXCEL.CELL_DESCRIBE(C_sNameLong);

    PRSG_EXCEL.CELL_DESCRIBE(C_sIspol);
    PRSG_EXCEL.CELL_DESCRIBE(C_sOMTS);
    PRSG_EXCEL.CELL_DESCRIBE(C_sKonstr);
    PRSG_EXCEL.CELL_DESCRIBE(C_sNach);

    -- Описываем строки спецификации 
    PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);
    PRSG_EXCEL.LINE_DESCRIBE(L_SECOND);
    PRSG_EXCEL.LINE_DESCRIBE(L_HEAD);
    PRSG_EXCEL.LINE_DESCRIBE(LL_LINE2);
    -- Описываем имена ячеек в строках
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sFrom);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sTo);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nKol);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sAdd);

    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_nPP2);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_sFrom2);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_sTo2);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_nKol2);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE2, C_sAdd2);


    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPodr,   sPodr);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIspol,  sIspol);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sOMTS,   sOMTS);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sKonstr, sKonstr);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sNach,   'Начальник ' || sPodr);

    if instr(sMainProd, '(') > 0 then
         sZak := SUBSTR(sMainProd, INSTR(sMainProd, '(')+1, LENGTH(sMainProd) - INSTR(sMainProd, '(')-1);
    else sZak := sMainProd;
    end if;

    if instr(sIzd, '(000') > 0 then
         sIzd1 := SUBSTR(sIzd, 0, INSTR(sIzd, '(000')-1);
    else sIzd1 := sIzd;
    end if;

    if length(sZak) > 0 then
         PRSG_EXCEL.CELL_VALUE_WRITE(C_sZakaz, f_numb || ' / ' || sZak);
    else PRSG_EXCEL.CELL_VALUE_WRITE(C_sZakaz, f_numb);
    end if;
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie,  sIzd1);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sName,     CODE);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZav,      S42326178);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sNameLong, sNameLong);
  end;

  procedure LINE_WRITE
  (
    nRows     in number, 
    sNomen    in varchar2,
    sModif    in varchar2,
    sChange   in varchar2,
    sModifNew in varchar2,
    nQuant    in number
   ,sAdd      in varchar2
  ) is
  sModif1     varchar2(128);
  sModifNew1  varchar2(128);
  begin
      if instr(sNomen, '(000') > 0 then
           sIzd1 := trim(SUBSTR(sNomen, 0, INSTR(sNomen, '(000')-1));
      else sIzd1 := sNomen;
      end if;
      if instr(sChange, '(000') > 0 then
           sIzd2 := trim(SUBSTR(sChange, 0, INSTR(sChange, '(000')-1));
      else sIzd2 := sChange;
      end if;

      if INSTR(sModif, '_') = 12 then 
        sModif1 := SUBSTR(sModif, INSTR(sModif, '_')+1);
      end if;
      if INSTR(sModifNew, '_') = 12 then 
        sModifNew1 := SUBSTR(sModifNew, INSTR(sModifNew, '_')+1);
      end if;
      if trim(sIzd1) = trim(sIzd2) then
        sIzd1 := sIzd1 || ' (' || sModif1    || ')';
        sIzd2 := sIzd2 || ' (' || sModifNew1 || ')';
      end if;

      if nRows <= nMax then
        nSTR := PRSG_EXCEL.LINE_APPEND(LL_LINE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,   0, nSTR, nRows);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sFrom, 0, nSTR, sIzd1);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sTo,   0, nSTR, sIzd2);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nKol,  0, nSTR, nQuant);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sAdd,  0, nSTR, sAdd);
      else
        nSTR2 := PRSG_EXCEL.LINE_APPEND(LL_LINE2);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP2,   0, nSTR2, nRows);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sFrom2, 0, nSTR2, sIzd1);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sTo2,   0, nSTR2, sIzd2);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nKol2,  0, nSTR2, nQuant);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sAdd2,  0, nSTR2, sAdd);
      end if;
  end;

--------------------
begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  if 'UdoDepordDir' = sRAZDEL then --Распоряжения об изменении заказов подразделений
--if USER != 'KHOK' then p_exception(0, 'Отчет в процессе модификации. Немного подождите.'); end if;

  for sel in (
    select dir.*, trim(dir.doc_pref)||'-'||trim(replace(dir.doc_numb, '/', '_')) sNumb,
           fa.numb, to_char(d.ord_date, 'DD.MM.YYYY') ord_date,
           nvl(UDO_F_DEPORD_MAINPROD_NAME(d.RN), '-') sMainProd,
        (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 8027721 and UNITCODE = 'DepartmentsOrders' and UNIT_RN = dir.depord) sZak
      from SELECTLIST sl, 
           UDO_DEPORDDIR dir,
           DEPARTMENTORD d,
           faceacc       fa
     where sl.unitcode = sRAZDEL and sl.authid = USER
         and dir.rn = sl.document
         and dir.company = UDO_REP_DEPORDDIR_CHANGE.nCOMPANY 
         and dir.depord  = d.rn
         and d.faceacc   = fa.rn (+)
     order by dir.doc_pref, dir.doc_numb
  ) loop

    if instr(sel.sMainProd, 'ЮФКВ') > 0 then
         sIzd  := SUBSTR(sel.sMainProd, 0, INSTR(sel.sMainProd, 'ЮФКВ')-1);
         sCODE := SUBSTR(sel.sMainProd, INSTR(sel.sMainProd, 'ЮФКВ'));
    else sCODE := sel.sMainProd; sIzd := sel.sMainProd;
    end if;

    if 0 = nSheet then
      nSheet := nSheet + 1;
      HEAD_WRITE(sel.sNumb, '', sIzd, sel.numb ||' / '|| sel.szak ||' от '|| sel.ord_date, sCODE, '-', sel.sMainProd);
    end if;

    nRows := 0;
    for rec in (
      select sp.*, strcombine(decode(sp.nsign_permcard, 1, 'КР'), strcombine(decode(sp.nd28, 1, 'Д28'), decode(sp.nd28, 1, 'АН'))) as sAdd
        from UDO_V_DEPORDDIR_SP sp
       where sp.nprn = sel.rn
       order by sp.sNOMEN_NAME
    ) loop
--p_exception(0, rec.nrn);
      nRows := nRows + 1;
      LINE_WRITE(nRows, trim(rec.snomen_name), '', trim(rec.snomen_chng_name), '', rec.nqnt_chng, rec.sAdd);

    end loop; 
    --удаляем технические строки
    if nRows > 0 then PRSG_EXCEL.LINE_DELETE(LL_LINE); end if;
    PRSG_EXCEL.LINE_DELETE(LL_LINE2); 
    if nRows < nMax then 
      PRSG_EXCEL.LINE_DELETE(L_HEAD); 
      PRSG_EXCEL.LINE_DELETE(L_SECOND); 
    end if;

  end loop;

  elsif 'CostDeliverySheets' = sRAZDEL then -- Комплектовочная ведомость

  for sel in (
    select dir.rn nFishRN, dir.prod_order,
           trim(dir.pref)||'-'||trim(replace(dir.numb, '/', '_')) sNumb,
           F2.CODE, F2.NAME sIzd, F.NUMB f_numb,
           UDO_F_FCDELIVSH_MAIN_NUMB(dir.rn) S42326178,
           UDO_F_FCDELIVSH_PRODUCT_NUM(dir.rn) sMainProd
           --nvl(UDO_F_DEPORD_MAINPROD_NAME(d.RN), '-') sMainProd
      from SELECTLIST    sl, 
           FCDELIVSH     dir,
           FCMATRESOURCE F2,
           FACEACC       F
     where sl.unitcode = sRAZDEL and sl.authid = USER
         and dir.rn = sl.document and dir.company = UDO_REP_DEPORDDIR_CHANGE.nCOMPANY 
         and dir.MATRES   = F2.RN
         and dir.PROD_ORDER = F.RN(+)
     order by dir.pref, dir.numb
  ) loop
    --sSheetName := sel.sNumb || '_' || nSheet;
--select t.*, t.rowid from FCDELIVSHSPCMPL t where t.RN = 48309347
--select t.*, t.rowid from UDO_FCDELIVSHSUB t where t.RN = 50504076
      if instr(sel.sIzd, 'ЮФКВ') > 0 then
           sIzd  := SUBSTR(sel.sIzd, 0, INSTR(sel.sIzd, 'ЮФКВ')-1);
           sCODE := SUBSTR(sel.sIzd, INSTR(sel.sIzd, 'ЮФКВ'));
      else sCODE := sel.sIzd; sIzd := sel.sIzd;
      end if;

      begin
         select mtr.name 
           into sNameIzd
           from doclinks     dl,
                FCROUTLST    ml,
                FCPRODCMP    prod,
                FCMATRESOURCE mtr
          where dl.out_document = sel.nFishRN
            and dl.out_unitcode = 'CostDeliverySheets'
            and ml.rn = dl.in_document
            and prod.rn = ml.prodcmp
            and mtr.rn = prod.mtr_res;
      exception 
         when NO_DATA_FOUND then sNameIzd := '-';
      end;

      if 0 = nSheet then
        nProdPRN := sel.prod_order;
          
        delete from IDLIST ls where ls.hid = nProdPRN;

        HEAD_WRITE(sel.code, sel.sMainProd, sIzd, sel.f_numb, sCODE, sel.S42326178, sNameIzd);
        nSheet := nSheet + 1;
      end if;

      insert into IDLIST ( ID, HID ) values ( sel.nFishRN, nProdPRN );

    end loop;

    nRows := 0;
    for sp in (
/*        select distinct trim(F1.NAME) snomen_name, trim(F2.NAME) snomen_chng_name, sub.quant
          from FCDELIVSHSP hsp,      FCMATRESOURCE F1,
               UDO_FCDELIVSHSUB sub, FCMATRESOURCE F2
         where hsp.prn in (select L.ID from IDLIST L where L.HID = nProdPRN)
           and F1.RN      = hsp.MATRES
           and hsp.rn     = sub.prn
           and sub.MATRES = F2.RN
         order by snomen_name, snomen_chng_name*/
        select distinct trim(F1.NAME) snomen_name, trim(NM1.MODIF_NAME) sModif1,
                   trim(F2.NAME) snomen_chng_name, trim(NM2.MODIF_NAME) sModif2, 
               sub.quant sub_quant
          from FCDELIVSHSP hsp,     FCMATRESOURCE F1, NOMMODIF NM1,
               FCDELIVSHSPCMPL sub, FCMATRESOURCE F2, NOMMODIF NM2 
         where hsp.prn in (select L.ID from IDLIST L where L.HID = nProdPRN)
           and F1.RN      = hsp.MATRES
           and F1.NOMEN_MODIF = NM1.RN (+)
           and hsp.rn     = sub.prn and hsp.MATRES != sub.MATRES
           and sub.MATRES = F2.RN
           and F2.NOMEN_MODIF = NM2.RN (+)
         order by snomen_name, snomen_chng_name         
    ) loop

      nRows := nRows + 1;
      LINE_WRITE(nRows, sp.snomen_name, sp.sModif1, sp.snomen_chng_name, sp.sModif2, sp.sub_quant, null);

    end loop; 
    --удаляем технические строки
    if nRows > 0 then PRSG_EXCEL.LINE_DELETE(LL_LINE); end if;
    PRSG_EXCEL.LINE_DELETE(LL_LINE2); 
    if nRows < nMax then 
      PRSG_EXCEL.LINE_DELETE(L_HEAD); 
      PRSG_EXCEL.LINE_DELETE(L_SECOND); 
    end if;

  elsif 'CostProductPlansSpecs' = sRAZDEL then -- Планы и отчеты производства изделий (спецификация)

    select prod.prn, prod.prod_order, prod.nesting_level, prod.prn_node 
      into nProdPRN, nProdOrder, nNest, nPrnNode
      from FCPRODPLANSP prod,
           SELECTLIST sl
     where sl.ident = nIDENT and sl.authid = USER and sl.unitcode = sRAZDEL --'CostProductPlansSpecs'
       and prod.rn = sl.document;

--UDO_F_FCPRODPLANSP_RTLST_NUMB(NRN) S20299837 -- номера Маршрутных листов
      delete from IDLIST ls where ls.hid = nProdPRN;

      for sel in (
        select dir.rn nFishRN, 
               trim(dir.pref)||'-'||trim(replace(dir.numb, '/', '_')) sNumb,
               F2.CODE, F2.NAME sIzd, F.NUMB f_numb,
               UDO_F_FCDELIVSH_MAIN_NUMB(dir.rn) S42326178,
               UDO_F_FCDELIVSH_PRODUCT_NUM(dir.rn) sMainProd
          from FCDELIVSH     dir,
               DOCLINKS      dl2,
               DOCLINKS      dl1,
               FCPRODPLANSP  sp,
               FCMATRESOURCE F2,
               FACEACC       F 
         where sp.PRN = nProdPRN
           and sp.prod_order = nProdOrder
           --and sp.nesting_level >= nNest -- ??? найдет и головное изделие
           --and sp.prn_node = nPrnNode
           and dir.company = UDO_REP_DEPORDDIR_CHANGE.nCOMPANY 
           and dl1.in_document = sp.rn
           and dl1.out_unitcode = 'CostRouteLists'
           and dl2.in_document = dl1.out_document
           and dl2.out_unitcode = 'CostDeliverySheets'
           and dir.rn = dl2.out_document
           and dir.MATRES   = F2.RN
           and dir.PROD_ORDER = F.RN(+)
      order by sp.nesting_level, sIzd, S42326178 desc
      ) loop
--if utilizer = 'KHOK' then p_exception(0,sel.nFishRN  || ': ' || sel.CODE || ' - ' || sel.sIzd  ); end if;
      begin
         select mtr.name 
           into sNameIzd
           from doclinks     dl,
                FCROUTLST    ml,
                FCPRODCMP    prod,
                FCMATRESOURCE mtr
          where dl.out_document = sel.nFishRN
            and dl.out_unitcode = 'CostDeliverySheets'
            and ml.rn = dl.in_document
            and prod.rn = ml.prodcmp
            and mtr.rn = prod.mtr_res;
      exception 
         when NO_DATA_FOUND then sNameIzd := '-';
      end;

      if instr(sel.sIzd, 'ЮФКВ') > 0 then
           sIzd  := SUBSTR(sel.sIzd, 0, INSTR(sel.sIzd, 'ЮФКВ')-1);
           sCODE := SUBSTR(sel.sIzd, INSTR(sel.sIzd, 'ЮФКВ'));
      else sCODE := sel.sIzd; sIzd := sel.sIzd;
      end if;
      
      insert into IDLIST ( ID, HID ) values ( sel.nFishRN, nProdPRN );

      if 0 = nSheet then
        nSheet := nSheet + 1;
        HEAD_WRITE(/*nSheet||*/ sel.code, sel.sMainProd, sIzd, sel.f_numb, sCODE, sel.S42326178, sNameIzd);
--sTmp := sTmp || '; ' ||  sel.nFishRN;
      end if;

    end loop;
--if utilizer = 'KHOK' then p_exception(0,'sTmp: ' ||  sTmp); end if;

    nRows := 0;
    for sp in (
      /*select distinct trim(F1.NAME) snomen_name, trim(F2.NAME) snomen_chng_name, sub.quant
        from FCDELIVSHSP hsp,      FCMATRESOURCE F1,
             UDO_FCDELIVSHSUB sub, FCMATRESOURCE F2
       where hsp.prn in (select L.ID from IDLIST L where L.HID = nProdPRN)
         and F1.RN      = hsp.MATRES
         and hsp.rn     = sub.prn
         and sub.MATRES = F2.RN
       order by snomen_name, snomen_chng_name*/
      select distinct trim(F1.NAME) snomen_name, trim(NM1.MODIF_NAME) sModif1,
                 trim(F2.NAME) snomen_chng_name, trim(NM2.MODIF_NAME) sModif2, 
             sub.quant sub_quant
        from FCDELIVSHSP hsp,     FCMATRESOURCE F1, NOMMODIF NM1,
             FCDELIVSHSPCMPL sub, FCMATRESOURCE F2, NOMMODIF NM2 
       where hsp.prn in (select L.ID from IDLIST L where L.HID = nProdPRN)
         and F1.RN      = hsp.MATRES
         and F1.NOMEN_MODIF = NM1.RN (+)
         and hsp.rn     = sub.prn and hsp.MATRES != sub.MATRES
         and sub.MATRES = F2.RN
         and F2.NOMEN_MODIF = NM2.RN (+)
       order by snomen_name, snomen_chng_name         
    ) loop

      nRows := nRows + 1;
      LINE_WRITE(nRows, sp.snomen_name, sp.sModif1, sp.snomen_chng_name, sp.sModif2, sp.sub_quant, null);

    end loop; 
    --удаляем технические строки
    if nRows > 0 then 
      PRSG_EXCEL.LINE_DELETE(LL_LINE);
      PRSG_EXCEL.LINE_DELETE(LL_LINE2); 
      if nRows < nMax then 
        PRSG_EXCEL.LINE_DELETE(L_HEAD); 
        PRSG_EXCEL.LINE_DELETE(L_SECOND); 
      end if;
    end if;

  else p_exception(0, 'Печать отчета Ведомость замен не предусмотрена из раздела ' || sRAZDEL);
  end if; -- sRAZDEL

  /* Удаление листа шаблона */
  if nSheet > 0 then
     PRSG_EXCEL.SHEET_DELETE(sSHEET_NAME => C_SLIST);
  end if;

  delete from IDLIST ls where ls.hid = nProdPRN;

end UDO_REP_DEPORDDIR_CHANGE;
/
