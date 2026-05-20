create or replace procedure UDO_P_PRODCOST_ORD_XLS_XML(nCOMPANY       in number,
                                                       nIDENT         in number, -- отмеченные записи
                                                       nIDENT_process in number,
                                                       sSERNUMB       in varchar2 default null, -- заводской номер (только для МЛ)
                                                       sUNIT          in varchar2 -- код раздела, из которого вызван отчет
                                                       ) as
  /*
    12/04/2023 Марков МВ.
    Отчет "Акт коплектования" (для ФЭО)
    Формируется по отмеченным заказам на производство (желательно по одному)
    
    Спецификация изделия формируется по постребности для заказа на производство.
    Сгруппированные покупные комплектующие и материалы
    
    Фактические данные формируются в следующем порядке:
    - по данным комплектовочных ведомостей (комплектование)
    - по данным резервов в связанных заказах подразделений
    - по закупке для всего проекта
    
    поиск осуществляется для потребности по заказу на производство
    учитываются ведомости замен для связанных заказов подразделений
    
  */

  --описание отчета
  /*  cFORM  constant varchar2(20) := 'Акт';
  cPRINT constant varchar2(20) := 'принт';
  cZAKAZ constant varchar2(20) := 'заказ';
  cTEMA  constant varchar2(20) := 'тема';
  --
  cSPEC  constant varchar2(20) := 'спецификация';
  cART   constant varchar2(20) := 'изделие';
  cQUANT constant varchar2(20) := 'количество';
  --
  cLINE constant varchar2(20) := 'строка';
  cSP_N constant varchar2(20) := 'спец_н';
  cSP_Q constant varchar2(20) := 'спец_к';
  cF_DF constant varchar2(20) := 'замена';
  cF_SR constant varchar2(20) := 'серия';
  cF_Q  constant varchar2(20) := 'закупка_к';
  cF_S  constant varchar2(20) := 'закупка_с';
  cF_SN constant varchar2(20) := 'закупка_сн';
  cF_AG constant varchar2(20) := 'закупка_п';
  cF_ND constant varchar2(20) := 'закупка_нд';
  cF_DD constant varchar2(20) := 'закупка_дд';*/

  --
  nCRN      PKG_STD.tREF;
  nJUR_PERS PKG_STD.tREF;

  ncount_ord number;

  NCOL_COUNT number;

  SFORMATSTRING_TITLE     varchar2(20) := 's69';
  SFORMATSTRING_TITLE_VAL varchar2(20) := 's72';
  SFORMATNUMBER_TITLE_VAL varchar2(20) := 's71';
  SFORMATSTRING           varchar2(20) := 's65';

  SFORMATSTRING_HEAD  varchar2(20) := 's62';
  SFORMATNUMBER_QUANT varchar2(20) := 's66';
  SFORMATNUMBER_SUM   varchar2(20) := 's67';

  procedure print_head_po(nPRODORD in number) is
  
    sDOCNUMB varchar2(240);
    sZAKAZ   varchar2(240);
  
  begin
    -- параметры заказа
    begin
      select trim(P.ORD_PREF) || '-' || trim(P.ORD_NUMB), FA.NUMB
        into sDOCNUMB, sZAKAZ
        from PRODUCTORD P, FACEACC FA
       where P.RN = nPRODORD
         and P.FACEACC = FA.RN;
    exception
      when no_data_found then
        p_exception(0,
                    'Заказ на производство не найден.' || chr(10) ||
                    'RN: %s',
                    nPRODORD);
    end;
  
    -- Создаем новый лист
    --PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM => cFORM, sSHEET_NAME_TO => sDOCNUMB);
    --PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sDOCNUMB);
    -- печать
    --PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cPRINT, sCELL_VALUE => to_char(sysdate, 'dd.mm.yyyy'));
    --PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cZAKAZ, sCELL_VALUE => sZAKAZ);
    --PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cTEMA,  sCELL_VALUE => );
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE,
                                                     PSVALUE => 'Заказ:');
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE_VAL,
                                                     PSVALUE => sDOCNUMB);
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE,
                                                     PSVALUE => 'Тема:');
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE_VAL,
                                                     PSVALUE => sZAKAZ);
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
  
    -- список изделий по заказу
    for rra in (select PS.MAIN_QUANT,
                       NM.NOMEN_NAME,
                       case
                         when PS.NOM_MODIF is not null then
                          (select MR.NAME
                             from FCMATRESOURCE MR
                            where MR.NOMEN_MODIF = PS.NOM_MODIF)
                         else
                          null
                       end as MTR_NAME
                  from PRODUCTORDS PS, DICNOMNS NM, NOMMODIF MD
                 where PS.PRN = nPRODORD
                   and nm.rn = ps.nomen
                   and md.rn = ps.nom_modif) loop
      /*n := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cSPEC);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cART,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => nvl(rra.mtr_name, rra.nomen_name));
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQUANT,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  nCELL_VALUE   => rra.main_quant);*/
      UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
    
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE,
                                                       PSVALUE => 'Изделие:');
    
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE_VAL,
                                                       PSVALUE => rra.nomen_name);
    
      UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
    
      UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
    
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE,
                                                       PSVALUE => 'Количество:');
    
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATNUMBER_TITLE_VAL,
                                                       PSVALUE => rra.main_quant);
    
      UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
    end loop;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PNMERGE_ACROSS => 1,
                                                     PSSTYLE        => SFORMATSTRING_HEAD,
                                                     PSVALUE        => 'Спецификация');
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PNMERGE_ACROSS => 7,
                                                     PSSTYLE        => SFORMATSTRING_HEAD,
                                                     PSVALUE        => 'Фактические данные');
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Наименование по спецификации');
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Кол-во');
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Наименование замены');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Серия');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Кол-во закупки');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Сумма без НДС');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Сумма с НДС');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Поставщик');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Номер документа');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Дата документа');
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
  end print_head_po;

  procedure print_head_lst(nLST in number) is
  
    sDOCNUMB varchar2(240);
    sZAKAZ   varchar2(240);
  
  begin
    -- параметры маршратного листа
    begin
      select trim(LST.DOCPREF) || '-' || trim(LST.DOCNUMB), FA.NUMB
        into sDOCNUMB, sZAKAZ
        from FCROUTLST LST, FACEACC FA
       where LST.RN = nLST
         and LST.FACEACC = FA.RN;
    exception
      when no_data_found then
        p_exception(0,
                    'маршрутный лист не найден.' || chr(10) ||
                    'RN: %s',
                    nLST);
    end;
  
    -- Создаем новый лист
    --PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM => cFORM, sSHEET_NAME_TO => sDOCNUMB);
    --PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sDOCNUMB);
    -- печать
    --PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cPRINT, sCELL_VALUE => to_char(sysdate, 'dd.mm.yyyy'));
    --PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cZAKAZ, sCELL_VALUE => sZAKAZ);
    --PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cTEMA,  sCELL_VALUE => );
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE,
                                                     PSVALUE => 'Маршрутный лист:');
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE_VAL,
                                                     PSVALUE => sDOCNUMB);
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE,
                                                     PSVALUE => 'Тема:');
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE_VAL,
                                                     PSVALUE => sZAKAZ);
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
  
    -- изделие по МЛ
    for rra in (select LST.QUANT as MAIN_QUANT,
                       NM.NOMEN_NAME,
                       MR.NAME   as MTR_NAME,
                       udo_f_fcroutlst_sernumb(NRN => LST.RN) as SERNUMB
                  from FCROUTLST     LST, 
                       FCMATRESOURCE MR,
                       DICNOMNS      NM, 
                       NOMMODIF      MD
                 where LST.RN = nLST
                   and LST.MATRES = MR.RN
                   and nm.rn = mr.nomenclature
                   and md.rn = mr.nomen_modif) loop
      
      UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
    
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE,
                                                       PSVALUE => 'Изделие:');
    
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE_VAL,
                                                       PSVALUE => rra.nomen_name||' (№ '||rra.sernumb||')');
    
      UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
    
      UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
    
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_TITLE,
                                                       PSVALUE => 'Количество:');
    
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATNUMBER_TITLE_VAL,
                                                       PSVALUE => rra.main_quant);
    
      UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
      
    end loop;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PNMERGE_ACROSS => 1,
                                                     PSSTYLE        => SFORMATSTRING_HEAD,
                                                     PSVALUE        => 'Спецификация');
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PNMERGE_ACROSS => 7,
                                                     PSSTYLE        => SFORMATSTRING_HEAD,
                                                     PSVALUE        => 'Фактические данные');
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Наименование по спецификации');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Кол-во');
    /*UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Кол-во на спец.');*/
  
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Наименование замены');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Серия');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Кол-во закупки');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Сумма без НДС');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Сумма с НДС');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Поставщик');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Номер документа');
    UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PSSTYLE => SFORMATSTRING_HEAD,
                                                     PSVALUE => 'Дата документа');
  
    UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
  end print_head_lst;

  -- печать листа
  procedure print_list(nDOCUMENT in number) is
  begin
    if sUNIT = 'ProductionOrders' then
      print_head_po(nPRODORD => nDOCUMENT);
    elsif sUNIT = 'CostRouteLists' then
      print_head_lst(nLST => nDOCUMENT);
    else
      p_exception(0,
                  'Для данного раздела (%s) отчет не разработан. Обратитесь к Администратору', sUNIT);
    end if;
  
    -- список комплектующих
    for rsp in ( select mr.name as name,
                       mtr.quant as sp_quant,
                       case
                         when ser.modif is not null and
                              mr.nomen_modif != ser.modif then
                          (select mrr.name
                             from fcmatresource mrr, nommodif mdd
                            where mrr.nomen_modif = ser.modif
                              and mrr.nomen_modif = mdd.rn)
                         else
                          null
                       end as name_diff,
                       ser.sernum,
                       ser.in_quant,
                       ser.in_sum,
                       ser.in_sumtax,
                       a.agnname,
                       ser.trdoc_numb,
                       ser.trdoc_date
                  from udo_prodcost_tmp_mtr mtr,
                       fcmatresource        mr,
                       udo_prodcost_tmp_ser ser,
                       agnlist              a
                 where mtr.matres = mr.rn
                   and mtr.prod_sign = 1
                   and mtr.ident = ser.ident
                   and mtr.matres = ser.matres(+)
                   and ser.rec_type > 9
                   and ser.agn_rn = a.rn(+)
                   and mtr.ident = nIDENT
                   
                   
                union
                select mr.name   as name,
                       mtr.quant as sp_quant,
                       null      as name_diff,
                       null      as sernum,
                       null      as in_quant,
                       null      as in_sum,
                       null      as in_sumtax,
                       null      as agnname,
                       null      as trdoc_numb,
                       null      as trdoc_date
                  from udo_prodcost_tmp_mtr mtr, fcmatresource mr
                 where mtr.prod_sign = 1
                   and mtr.ident = nIDENT
                   and mtr.matres = mr.rn
                   and not exists (select null
                          from udo_prodcost_tmp_ser ser
                         where ser.ident = mtr.ident
                           and ser.matres = mtr.matres
                           and ser.rec_type > 9)
                 order by name) loop
      /*n := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cSP_N, -- 'спец_н';
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => rsp.name);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cSP_Q, -- 'спец_к';
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  nCELL_VALUE   => rsp.sp_quant);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cF_DF, -- 'замена';
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => rsp.name_diff);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cF_SR, -- 'серия';
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => rsp.sernum);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cF_Q, -- 'закупка_к';
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  nCELL_VALUE   => rsp.in_quant);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cF_S, -- 'закупка_с';
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  nCELL_VALUE   => rsp.in_sum);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cF_SN, -- 'закупка_сн';
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  nCELL_VALUE   => rsp.in_sumtax);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cF_AG, -- 'закупка_п';
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => rsp.agnname);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cF_ND, -- 'закупка_нд';
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => rsp.trdoc_numb);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cF_DD, -- 'закупка_дд';
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => to_char(rsp.trdoc_date, 'dd.mm.yyy'));*/
    
      NCOL_COUNT := 0;
    
      UDO_PKG_EXCEL_REPORT_XML.P_ROW_BEGIN;
    
      NCOL_COUNT := NCOL_COUNT + 1;
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PNINDEX => NCOL_COUNT,
                                                       PSSTYLE => SFORMATSTRING,
                                                       PSVALUE => rsp.name);
    
      NCOL_COUNT := NCOL_COUNT + 1;
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_NUMBER(PNINDEX => NCOL_COUNT,
                                                       PSSTYLE => SFORMATNUMBER_QUANT,
                                                       PNVALUE => rsp.sp_quant);
      /*NCOL_COUNT := NCOL_COUNT + 1;
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_NUMBER(PNINDEX => NCOL_COUNT,
                                                       PSSTYLE => SFORMATNUMBER_QUANT,
                                                       PNVALUE => rsp.sp_quant);*/
    
      NCOL_COUNT := NCOL_COUNT + 1;
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PNINDEX => NCOL_COUNT,
                                                       PSSTYLE => SFORMATSTRING,
                                                       PSVALUE => rsp.name_diff);
    
      NCOL_COUNT := NCOL_COUNT + 1;
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PNINDEX => NCOL_COUNT,
                                                       PSSTYLE => SFORMATSTRING,
                                                       PSVALUE => rsp.sernum);
    
      NCOL_COUNT := NCOL_COUNT + 1;
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_NUMBER(PNINDEX => NCOL_COUNT,
                                                       PSSTYLE => SFORMATNUMBER_QUANT,
                                                       PNVALUE => rsp.in_quant);
    
      NCOL_COUNT := NCOL_COUNT + 1;
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_NUMBER(PNINDEX => NCOL_COUNT,
                                                       PSSTYLE => SFORMATNUMBER_SUM,
                                                       PNVALUE => rsp.in_sum);
    
      NCOL_COUNT := NCOL_COUNT + 1;
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_NUMBER(PNINDEX => NCOL_COUNT,
                                                       PSSTYLE => SFORMATNUMBER_SUM,
                                                       PNVALUE => rsp.in_sumtax);
    
      NCOL_COUNT := NCOL_COUNT + 1;
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PNINDEX => NCOL_COUNT,
                                                       PSSTYLE => SFORMATSTRING,
                                                       PSVALUE => rsp.agnname);
    
      NCOL_COUNT := NCOL_COUNT + 1;
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PNINDEX => NCOL_COUNT,
                                                       PSSTYLE => SFORMATSTRING,
                                                       PSVALUE => rsp.trdoc_numb);
    
      NCOL_COUNT := NCOL_COUNT + 1;
      UDO_PKG_EXCEL_REPORT_XML.P_ADD_CELL_VALUE_STRING(PNINDEX => NCOL_COUNT,
                                                       PSSTYLE => SFORMATSTRING,
                                                       PSVALUE => to_char(rsp.trdoc_date,
                                                                          'dd.mm.yyyy'));
    
      UDO_PKG_EXCEL_REPORT_XML.P_ROW_END;
    end loop;
  
    -- подчистка
    --PRSG_EXCEL.LINE_DELETE(sLINE_NAME => cSPEC);
    --PRSG_EXCEL.LINE_DELETE(sLINE_NAME => cLINE);
  end print_list;

begin
  select count(1) into ncount_ord from SELECTLIST where IDENT = nIDENT;

  if (ncount_ord > 1) then
    if sUNIT = 'ProductionOrders' then
      p_exception(0,
                  'Необходимо выбрать только один заказ на производство.');
    elsif sUNIT = 'CostRouteLists' then
      p_exception(0,
                  'Необходимо выбрать только один маршрутный лист готового изделия.');
    else
      p_exception(0,
                  'Для данного раздела (%s) отчет не разработан. Обратитесь к Администратору', sUNIT);
    end if;
  end if;

  -- по всем отмеченным записям сформируем данные
  for rec in (select DOCUMENT from SELECTLIST where IDENT = nIDENT) loop
    if sUNIT = 'ProductionOrders' then
    -- запись заказа на производство
    P_PRODUCTORD_EXISTS(nCOMPANY => nCOMPANY,
                        nRN      => rec.document,
                        nCRN     => nCRN);
    -- формирование данных
    UDO_P_PRODCOST_ORD(nCOMPANY      => nCOMPANY,
                       nIDENT        => nIDENT,
                       nSIGN_PROJECT => 1,
                       nPRODORD      => rec.document);
    elsif sUNIT = 'CostRouteLists' then
      -- запись маршртуного листа
      P_FCROUTLST_EXISTS(nRN       => rec.document,
                         nCOMPANY  => nCOMPANY,
                         nCRN      => nCRN,
                         nJUR_PERS => nJUR_PERS);
      -- формирование данных
      UDO_P_LSTCOST_SERNUM(nCOMPANY      => nCOMPANY,
                           nIDENT        => nIDENT,
                           nSIGN_PROJECT => 1,
                           sSERNUMB      => sSERNUMB);
    else
      p_exception(0,
                  'Для данного раздела (%s) отчет не разработан. Обратитесь к Администратору', sUNIT);
    end if;
  end loop;

  -- описание отчета
  /*PRSG_EXCEL.PREPARE;
  PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => cFORM);
  --
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cPRINT);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cZAKAZ);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cTEMA);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cSPEC);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cSPEC, sCELL_NAME => cART);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cSPEC, sCELL_NAME => cQUANT);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cSP_N);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cSP_Q);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cF_DF);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cF_SR);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cF_Q);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cF_S);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cF_SN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cF_AG);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cF_ND);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cF_DD);*/

  /* Готовим шаблон */
  UDO_PKG_EXCEL_REPORT_XML.P_INITIALIZE(PNSHOWHIDDENCOLUMNS => 0,
                                        PBBTEMPLATE         => TO_BLOB(null));

  -- печать (для каждого заказа отдельный лист)
  for rls in (select distinct T.DOCUMENT
                from UDO_PRODCOST_TMP T
               where T.IDENT = nIDENT) loop
    -- печать листа
    print_list(nDOCUMENT => rls.document);
  end loop;

  /* Записываем результат формирования отчета */
  UDO_PKG_EXCEL_REPORT_XML.P_SAVE_RESULT(PSFILENAME => 'Акт комплектования.xls',
                                         PNIDENT    => nIDENT_process);
  /* Освобождаем ресурсы отчета */
  UDO_PKG_EXCEL_REPORT_XML.P_FINALIZE;

  -- подчистка
  --PRSG_EXCEL.SHEET_DELETE(sSHEET_NAME => cFORM);

end UDO_P_PRODCOST_ORD_XLS_XML;
/

