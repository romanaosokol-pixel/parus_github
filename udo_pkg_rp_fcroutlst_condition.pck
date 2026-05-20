create or replace package UDO_PKG_RP_FCROUTLST_CONDITION
is
  -- Author  : A.KHOKHRYAKOV
  -- Created : 14.09.2022 13:09:33
  -- Purpose : Отчет "Состояние производства продукции"
  /* Формирование отчета */
  procedure XLS_MAKE
  (
    NCOMPANY  in number,  -- Организация
    NIDENT    in number,  -- ИД помеченных записей  
    sRazd     in varchar2,-- Раздел в котором запускается отчет
    sTheme    in varchar2,-- Тема 
    sIzd      in varchar2,-- Изделие ради которого запускается отчет
    sZakaz    in varchar2,-- Заказ
    sOper     in varchar2,-- Операция
    bTree     in integer  -- Смотреть всё дерево изделия
  );

end UDO_PKG_RP_FCROUTLST_CONDITION;
/

create or replace package body UDO_PKG_RP_FCROUTLST_CONDITION is
  -- Initialization
  SHEET_DATA         PKG_STD.tSTRING := 'TDSheet';   -- Лист.

  C_sTheme        constant PKG_STD.tSTRING := 'sTheme';
  C_sZakaz        constant PKG_STD.tSTRING := 'sZakaz';
  C_sWork         constant PKG_STD.tSTRING := 'sWork';

  C_sBuyer        constant PKG_STD.tSTRING := 'sBuyer';
  C_sDog          constant PKG_STD.tSTRING := 'sDog';
  C_sDogDate      constant PKG_STD.tSTRING := 'sDogDate';

  C_sZayav        constant PKG_STD.tSTRING := 'sZayav';
  C_sZakaz1       constant PKG_STD.tSTRING := 'sZakaz1';
  C_sStage        constant PKG_STD.tSTRING := 'sStage';
  C_sOTK          constant PKG_STD.tSTRING := 'sOTK';
  C_sCond         constant PKG_STD.tSTRING := 'sCond';

  C_sIzdelie      constant PKG_STD.tSTRING := 'sIzdelie';
  C_sKol          constant PKG_STD.tSTRING := 'sKol';
  C_sGotovo       constant PKG_STD.tSTRING := 'sGotovo';

  C_sUpak         constant PKG_STD.tSTRING := 's_Upak';
  C_sKolUpak      constant PKG_STD.tSTRING := 's_KolUpak';

  --LINE_ZAKAZ         PKG_STD.tSTRING := 'L_ZAKAZ';
  --LINE_LETTER        PKG_STD.tSTRING := 'L_LETTER';
  --LINE_ZAYAV         PKG_STD.tSTRING := 'L_ZAYAV';
  --LINE_TOP           PKG_STD.tSTRING := 'L_TOP';
  LINE_DATA          PKG_STD.tSTRING := 'L_LINE';    -- Линия отчета с данными
  --LINE_UPAK          PKG_STD.tSTRING := 'L_UPAK';    -- Линия про упаковку
  iLINE_DATA_BEG     integer := 10;                  -- Номер начальной строки строковых данных

  /* Выбор листа и Объявление ячеек листа  */
  procedure CELL_DESCRIBE_SHEET_DATA
  is
  begin
    PRSG_EXCEL.SHEET_SELECT(SHEET_DATA);
    /* Параметры отчета */
    --PRSG_EXCEL.LINE_DESCRIBE(LINE_ZAKAZ);
    --PRSG_EXCEL.LINE_DESCRIBE(LINE_LETTER);
    --PRSG_EXCEL.LINE_DESCRIBE(LINE_ZAYAV);
    --PRSG_EXCEL.LINE_DESCRIBE(LINE_TOP);
    PRSG_EXCEL.LINE_DESCRIBE(LINE_DATA);
    --PRSG_EXCEL.LINE_DESCRIBE(LINE_UPAK);

    PRSG_EXCEL.CELL_DESCRIBE(C_sTheme);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZakaz);
    PRSG_EXCEL.CELL_DESCRIBE(C_sWork);

    PRSG_EXCEL.CELL_DESCRIBE(C_sBuyer);
    PRSG_EXCEL.CELL_DESCRIBE(C_sDog);
    PRSG_EXCEL.CELL_DESCRIBE(C_sDogDate);

    PRSG_EXCEL.CELL_DESCRIBE(C_sZakaz1);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZayav);
    PRSG_EXCEL.CELL_DESCRIBE(C_sStage);
    PRSG_EXCEL.CELL_DESCRIBE(C_sOTK);
    PRSG_EXCEL.CELL_DESCRIBE(C_sCond);

    PRSG_EXCEL.CELL_DESCRIBE(C_sIzdelie);
    PRSG_EXCEL.CELL_DESCRIBE(C_sKol);
    PRSG_EXCEL.CELL_DESCRIBE(C_sGotovo);

    PRSG_EXCEL.CELL_DESCRIBE(C_sUpak);
    PRSG_EXCEL.CELL_DESCRIBE(C_sKolUpak);

  end;  

  /* Запись значения ячеек строки таблицы */
  procedure TABCELL_WRITE
  (
    nCOLUMN           in varchar2,        -- Имя колонки в отчете
    sROW_NAME         in varchar2,        -- Имя строки в отчете
    sVALUE            in varchar2 :=null, -- Значение (строка)
    nVALUE            in number   :=null, -- Значение (число)
    sFORMULA          in varchar2 :=null  -- формула
  ) 
  is
   sXLSNAME PKG_STD.tSTRING; -- Имя ячейки на Excel-листе
  begin
    sXLSNAME := nCOLUMN||sROW_NAME;
    PRSG_EXCEL.CELL_DESCRIBE(sXLSNAME); 
   case
      when sVALUE is not null then
        PRSG_EXCEL.CELL_VALUE_WRITE(sXLSNAME, sVALUE);
      when nVALUE is not null then
        PRSG_EXCEL.CELL_VALUE_WRITE(sXLSNAME, nVALUE);
      when sFORMULA is not null then
        PRSG_EXCEL.CELL_FORMULA_WRITE(sXLSNAME, sFORMULA);
      else
        null;
    end case;
 
  end TABCELL_WRITE;
    
 procedure SHEET_DATA_MAKE
  (
    NCOMPANY  in number,   -- Организация
    NRN       in number,   -- Рег.номер изделия
    sThemeIn  in varchar2, -- Тема 
    sIzdIn    in varchar2, -- Изделие ради которого запускается отчет
    sZakazIn  in varchar2, -- Заказ
    sOperIn   in varchar2, -- Операция
    bTree     in integer   -- Смотреть всё дерево изделия
  )
  is
    NPP               PKG_STD.tNUMBER:=0;  -- Порядковый номер записи
    iXLSNAME          PKG_STD.tNUMBER;     -- Номер ячейки 
    nLINE_CONT        PKG_STD.tNUMBER;     -- Порядковый номер линии   
    --DSYSDAT           PKG_STD.tSTRING := to_char(sysdate, 'dd.mm.yyyy');

    nTot              number := 0;
    nUpak             number := 0;
    bDate             number := 0;
    sIzd              FCMATRESOURCE.NAME%TYPE := '';
    --nFace             FACEACC.Numb%TYPE := '';
    sFaceAcc          varchar2(2048) := '';
    sShifr            varchar2(1024) := '';
    sZakaz            varchar2(2048) := '';
    sOtv              AGNLIST.AGNFAMILYNAME%type := '-';
    sOper             FCROUTLSTSP.Oper_Uk%type   := '-';
    sSGP              varchar(1024) := null;
    sSklad            AZSAZSLISTMT.AZS_NUMBER%type := null;
    sZayav            varchar(1024) := null;
    sOTK              varchar(512) := null;
    sStage            varchar(1024) := null;
    sDogNum           varchar2(128) := ' ';
    sDogDate          varchar2(128) := ' ';

    sTMP              varchar(4000) := null;

  begin

    --begin
--p_exception(0,NRN || ', ' || sZakaz);
    delete from IDLIST ls where ls.hid = NRN;
    sFaceAcc := sZakazIn;

    begin
    select trim(m.doc_pref)||'-'||trim(m.doc_numb), to_char(m.doc_date, 'DD.MM.YYYY')
      into sDogNum, sDogDate
      from CONTRACTS M 
     where COMPANY = NCOMPANY 
       and rownum  = 1
       and exists (select * from V_DOCS_PROPS_VALS_SHADOW DPC 
                   where (DPC.UNIT_RN=M.RN) and (DPC.DOCS_PROP_RN=1076177) and (DPC.UNITCODE='Contracts') 
                     and upper(DPC.STR_VALUE) like sFaceAcc/*||'%'*/);
    exception when NO_DATA_FOUND then
      sDogNum := ' '; sDogDate := ' ';
    end;

    for fac in(
      select sum(lst.quant) nQuant, S.name, F.NUMB, F.RN,
             UDO_F_FCROUTLST_PRODUCT_NUM(lst.RN) S19486627
        --into nTot, sIzd, nFace
        from FCROUTLST lst 
        left outer join FACEACC F on lst.faceacc = F.RN
        inner      join FCMATRESOURCE S  on lst.matres = S.RN
       where lst.MATRES = NRN 
         and (F.NUMB = sZakazIn or sZakazIn is null)
       group by S.name, F.NUMB, F.RN, UDO_F_FCROUTLST_PRODUCT_NUM(lst.RN)
       order by S.name, F.NUMB
     ) loop
--p_exception(0,NRN || fac.numb);
        insert into IDLIST (ID, HID) values (fac.rn, NRN);
        nTot := nTot + fac.nQuant;

        if sZakazIn is null /*or nTot > 0*/ then
          if sFaceAcc is null then
               sIzd := fac.name;
               sFaceAcc := fac.numb;
          else sFaceAcc := sFaceAcc || '; ' || fac.numb;
          end if;
        end if;
        
        if INSTR(sIzd,'(000') > 0 then
             sIzd := SUBSTR(sIzd, 1, INSTR(sIzd,'(000')-1);
        else sIzd := fac.name; --sIzdIn;
        end if;

        if fac.s19486627 is not null then
          sTMP := SUBSTR(fac.s19486627, INSTR(fac.s19486627, '(')+1);
          sTMP := SUBSTR(sTMP, 1, INSTR(sTMP, ')')-1);
          if sZayav is null then
               sZayav := sTMP;
          else sZayav := sZayav || '; ' || sTMP;
          end if;
        end if;

    end loop;

    begin
    select LISTAGG(f_numb, '; ') WITHIN GROUP (ORDER BY f_numb)
      into sZakaz 
      from(select distinct SUBSTR(F.NUMB, 1, INSTR(F.NUMB, '/')-1) f_numb
             from FCROUTLST lst
             left outer join FACEACC F on lst.faceacc = F.RN(+) 
            where lst.MATRES = NRN
              and (F.NUMB = sZakazIn or sZakazIn is null));
    exception when NO_DATA_FOUND then
      sZakaz := '???';
    end;

    begin
    select LISTAGG(f_numb, '; ') WITHIN GROUP (ORDER BY f_numb) 
      into sStage
      from(select distinct SUBSTR(F.NUMB, INSTR(F.NUMB, '/')+1) f_numb
             from FCROUTLST lst
             left outer join FACEACC F on lst.faceacc = F.RN(+) 
            where lst.MATRES = NRN
              and (F.NUMB = sZakazIn or sZakazIn is null));
    exception when NO_DATA_FOUND then
      sStage := '???';
    end;

    begin    
    select LISTAGG(SVP, '; ') WITHIN GROUP (ORDER BY SVP) 
      into sOTK
      from (select distinct STR_VALUE as SVP from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 8027724 and UNITCODE = 'CostRouteLists' 
                   and UNIT_RN in (select rn from FCROUTLST lst where lst.MATRES = NRN) );
    exception when NO_DATA_FOUND then
      sOTK := '???';
    end;

    begin    
    select LISTAGG(Shifr, '; ') WITHIN GROUP (ORDER BY Shifr) 
      into sShifr
      from (select UDO_F_FACEACC_GET_SHEFR(fa.rn) Shifr from FACEACC fa
             where fa.rn in (select L.ID from IDLIST L where L.HID = NRN) );
    exception when NO_DATA_FOUND then
      sShifr := '???';
    end;
--p_exception(0,NRN || ', ' || sFaceAcc || ', ' || sIzd || ', ' || nFace);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sWork,    ' ');

    PRSG_EXCEL.CELL_VALUE_WRITE(C_sDog,     sDogNum);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sDogDate, ' от '||sDogDate);

    PRSG_EXCEL.CELL_VALUE_WRITE(C_sTheme,   sShifr);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZakaz,   sZakaz);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZakaz1,  sFaceAcc);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZayav,   sZayav);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sStage,   sStage);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sOTK,     sOTK);
    if sOperIn is not null then
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sCond,  sOperIn);
    end if;

    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzdelie, sIzd);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sKol,     nTot);

    PRSG_EXCEL.CELL_VALUE_WRITE(C_sUpak, ' ');

    if 1 = bTree then
      p_exception(0, NRN);
    /* Данные */
/*    for rec IN (
      select UDO_F_FCPRODCMPSP_CMPL_NAME(MTR_RES) smtr_res_name, sp.*
      --, UDO_F_FCPRODCMPSP_HIER_LEVEL(HIER_LEVEL) N40335018 
        from FCPRODCMPSP sp
       where SIGN_RES=2 -- Собственные 
         and PRN=21038371  -- FCROUTLST RN 21129072
       order by sp.hier_level, sp.prodlist_numb, smtr_res_name
    ) loop

    end loop;*/

    else

    /* Данные */
    for rec IN (
      select lst.rn lst_rn, mat.name, lst.quant, lst.rel_date, lst.exec_date, 
             UDO_F_FACEACC_GET_SHEFR(lst.faceacc) sProject,
             UDO_F_FCROUTLST_SERNUMB(lst.RN) sZav,
             (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 13459633 and UNITCODE = 'CostRouteLists' and UNIT_RN = lst.RN) sOldZav,
             (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 13459635 and UNITCODE = 'CostRouteLists' and UNIT_RN = lst.RN) sOldOper,
             (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 8027730/*11844373*/ and UNITCODE = 'CostRouteLists' and UNIT_RN = lst.RN) sOldOtv
             --(select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 8027724 and UNITCODE = 'CostRouteLists' and UNIT_RN = NRN) SVP -- Приемка
        from FCROUTLST lst, FCMATRESOURCE mat
       where lst.COMPANY = SHEET_DATA_MAKE.NCOMPANY and lst.MATRES = NRN 
         and mat.rn = lst.matres
         and lst.faceacc in (select L.ID from IDLIST L where L.HID = NRN) --nFace
         --and (sp.oper_uk   = sOperIn or sOperIn is null)
      order by sZav, lst.docpref, lst.docnumb
    ) loop

      if sOperIn is null then
        if INSTR(sOper, 'паков') > 1 or INSTR(rec.sOldOper, 'паков') > 1 then
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sUpak, 'Упаковывание');
          nUpak := nUpak + 1;
        end if;
      else PRSG_EXCEL.CELL_VALUE_WRITE(C_sUpak, sOperIn);
      end if;

      if 0 = bDate and rec.rel_date is not null then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sGotovo, rec.rel_date);
        bDate := 1;
      end if;

      sOtv := '-';
      sOper := '-';
      --begin
      for otv in (
        select AGN.AGNFAMILYNAME, sp.OPER_UK 
          --into sOtv, sOper
          from FCROUTLSTSP sp,
               CLNPSPFM    C2,
               CLNPERSONS  C3,
               AGNLIST     AGN
         where sp.PRN = rec.lst_rn
           --and sp.numb        = m.numb
           and (sp.oper_uk   = sOperIn or sOperIn is null)
           and sp.rlplan_date is not null
           and sp.CLNPSPFM   = C2.RN(+)
           and C2.PERSRN     = C3.RN(+)
           and C3.PERS_AGENT = AGN.RN(+)
           order by sp.rlplan_date desc
/*      exception
        when NO_DATA_FOUND then
          --p_exception(0, 'Выберите изделие.'); 
          sOtv := '-';
          sOper := '-';
      end;*/
    ) loop
      if otv.agnfamilyname is not null and sOper = '-' then
        sOper := otv.OPER_UK;
        sOtv  := otv.agnfamilyname;
      end if;
    end loop;

      begin
      select DT.DOCCODE || ', ' || trim(dep.doc_pref) || '-' || trim(dep.doc_numb) || ', ' || to_char(dep.doc_date, 'DD.MM.YYYY'),
             AZS.AZS_NUMBER
             --|| ' (Партия ' || NVL(IC.CODE,dep.PARTY) || ')'
        into sSGP, sSklad
        from INCOMEFROMDEPS dep, 
             DOCLINKS       DL,
             DOCTYPES       DT,
             AZSAZSLISTMT   AZS
             --INCOMDOC IC
       where dl.IN_DOCUMENT  = rec.lst_rn
         and dl.in_unitcode  ='CostRouteLists'
         and dl.out_unitcode = 'IncomFromDeps'
         and dep.rn          = dl.out_document
         and dep.DOC_TYPE    = DT.RN
         and dep.STORE       = AZS.RN;
      exception
        when NO_DATA_FOUND then
          sSGP := '-';
          sSklad := '-';
      end;       

      if sOperIn is null or sOper != '-' then
        case NPP /* Формирование номера строки */
          when 0 then
               nLINE_CONT := PRSG_EXCEL.LINE_APPEND(LINE_DATA);
          else nLINE_CONT := PRSG_EXCEL.LINE_CONTINUE(LINE_DATA);
        end case;
        NPP := NPP + 1;

        sIzd := rec.name; --SUBSTR(rec.name, 1, INSTR(rec.name,'(000')-1);

        iXLSNAME := iLINE_DATA_BEG + nLINE_CONT;
        TABCELL_WRITE(nCOLUMN   => 'A', sROW_NAME => iXLSNAME, sVALUE => sIzd); --rec.name);
        TABCELL_WRITE(nCOLUMN   => 'I', sROW_NAME => iXLSNAME, sVALUE => rec.quant);
        TABCELL_WRITE(nCOLUMN   => 'K', sROW_NAME => iXLSNAME, sVALUE => rec.sZav);      -- Заводской номер
        TABCELL_WRITE(nCOLUMN   => 'U', sROW_NAME => iXLSNAME, sVALUE => rec.exec_date); -- Старт в производство

        if sOper != '-' then
             TABCELL_WRITE(nCOLUMN   => 'X', sROW_NAME => iXLSNAME, sVALUE => sOper);    -- Операция
        elsif length(trim(rec.sOldOper)) > 0 then
             TABCELL_WRITE(nCOLUMN   => 'X', sROW_NAME => iXLSNAME, sVALUE => rec.sOldOper);
        else TABCELL_WRITE(nCOLUMN   => 'X', sROW_NAME => iXLSNAME, sVALUE => ' ');
        end if;
        if sOtv != '-' then
             TABCELL_WRITE(nCOLUMN   => 'AC', sROW_NAME => iXLSNAME, sVALUE => sOtv);    -- Исполнитель
        elsif length(trim(rec.sOldOtv)) > 0 then
             TABCELL_WRITE(nCOLUMN   => 'AC', sROW_NAME => iXLSNAME, sVALUE => rec.sOldOtv);
        else TABCELL_WRITE(nCOLUMN   => 'AC', sROW_NAME => iXLSNAME, sVALUE => sOtv);
        end if;
        TABCELL_WRITE(nCOLUMN   => 'AF', sROW_NAME => iXLSNAME, sVALUE => sSGP);     -- Накладная
        TABCELL_WRITE(nCOLUMN   => 'AI', sROW_NAME => iXLSNAME, sVALUE => sSklad);   -- Склад
      end if;

    end loop;
    end if;
    PRSG_EXCEL.LINE_DELETE(LINE_DATA);
    
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sKolUpak, nUpak);

  end SHEET_DATA_MAKE;

/* Начало формирования отчета */
  procedure XLS_MAKE
  (
    NCOMPANY  in number,  -- Организация
    NIDENT    in number,  -- ИД помеченных записей  
    sRazd     in varchar2,-- Раздел в котором запускается отчет 
    sTheme    in varchar2,-- Тема 
    sIzd      in varchar2,-- Изделие ради которого запускается отчет
    sZakaz    in varchar2,-- Заказ
    sOper     in varchar2,-- Операция
    bTree     in integer  -- Смотреть всё дерево изделия
  )  
  is
  --sUNITCODE   PKG_STD.tSTRING := sRazd; --'CostProductLists', 'CostRouteLists';
  nDocument   number;

  begin
--if p_exception(0, sIzd);
    /* Объявление ячеек */
    CELL_DESCRIBE_SHEET_DATA;

    --if sTheme is not null and trim(sTheme) != '' then
/*      for fac in(
        select numb from 
              (select v.numb, UDO_F_FACEACC_PRJCODE(v.RN) S6405965 
                 from FACEACC v 
                where v.COMPANY = 90521 and v.agent = 92146)
        where upper(S6405965) like '%'||upper(sTheme)||'%' --or sTheme is NULL
          and (INSTR(sZakaz, numb) > 0 or sZakaz is null)
        order by NUMB
      ) loop*/
--p_exception(0, sZakaz || ', ' || sTheme || ', ' || fac.numb);
      
      if 'CostProductLists' = sRazd then -- Спецификация изделий

        for dd in (select lst.mtr_res DOCUMENT --sl.DOCUMENT
                     from SELECTLIST sl, FCPRODLST lst
                    where sl.ident = nIDENT
                      and lst.rn = sl.document
                      --S.IDENT = NIDENT
                      --and S.UNITCODE = sUNITCODE
                      /*and rownum = 1*/
        ) loop
  --p_exception(0, 'В процессе разработки "' || dd.document || '" : ' ||sRazd);

          SHEET_DATA_MAKE (
              NCOMPANY => NCOMPANY,  
              NRN      => dd.document,
              sThemeIn => sTheme,
              sIzdIn   => sIzd,
              sZakazIn => sZakaz, --fac.numb --sZakaz
              sOperIn  => sOper,
              bTree    => bTree
          );
        end loop;

      else -- 'CostRouteLists' Маршрутные листы
--select t.*, t.rowid from FCROUTLST t where t.RN = 14396145
--select t.*, t.rowid from FCMATRESOURCE t where t.RN = 11160322
        if sIzd is null then 
          begin
            select t.matres--, F.NUMB 
              into nDocument
              from SELECTLIST sl, 
                   FCROUTLST t 
             where sl.ident = nIDENT
               and t.RN = sl.document; --14430064;
          exception
            when NO_DATA_FOUND then
              p_exception(0, 'Выберите изделие.'); 
          end;
        else
/*          FIND_DICNOMNS_BY_CODE( 0, nCOMPANY, sIzd, nDocument );
p_exception(0, nDocument || ' - ' || sIzd);

          FIND_FCMATRES_BY_NOM_AND_MODIF(nFLAG_SMART   => 0,
                                         nCOMPANY      => NCOMPANY,
                                         sNOMENCLATURE => sIzd,
                                         sNOMEN_MODIF  => null,
                                         nRN           => nDocument);*/
          begin
            select t.rn 
              into nDocument
              from FCMATRESOURCE t 
             where t.code = sIzd;
          exception
            when NO_DATA_FOUND then
              p_exception(0, 'Изделие ненайдено.');
          end;
        end if;
--p_exception(0,nDocument || ' - ' || sIzd);

          SHEET_DATA_MAKE (
              NCOMPANY => NCOMPANY,  
              NRN      => nDocument,
              sThemeIn => sTheme,
              sIzdIn   => sIzd,
              sZakazIn => sZakaz, --fac.numb --sZakaz
              sOperIn  => sOper,
              bTree    => bTree
          );

      end if;
      --end if;

      --end loop;
    --end if;

  end XLS_MAKE;  

end UDO_PKG_RP_FCROUTLST_CONDITION;
/

