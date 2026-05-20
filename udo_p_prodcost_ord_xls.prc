create or replace procedure UDO_P_PRODCOST_ORD_XLS
(
  nCOMPANY in number,
  nIDENT   in number
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
  cFORM  constant varchar2(20) := 'Акт';
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
  cF_DD constant varchar2(20) := 'закупка_дд';

  --
  nCRN PKG_STD.tREF;

  -- печать листа
  procedure print_list(nPRODORD in number) is
    n        integer;
    sDOCNUMB varchar2(240);
    sZAKAZ   varchar2(240);
  begin
    -- параметры заказа
    begin
      select trim(P.ORD_PREF) || '-' || trim(P.ORD_NUMB),
             FA.NUMB
        into sDOCNUMB,
             sZAKAZ
        from PRODUCTORD P,
             FACEACC    FA
       where P.RN = nPRODORD
         and P.FACEACC = FA.RN;
    exception
      when no_data_found then
        p_exception(0, 'Заказ на производство не найден.' || chr(10) || 'RN: %s', nPRODORD);
    end;
    -- Создаем новый лист
    PRSG_EXCEL.SHEET_COPY(sSHEET_NAME_FROM => cFORM, sSHEET_NAME_TO => sDOCNUMB);
    PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => sDOCNUMB);
    -- печать
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cPRINT, sCELL_VALUE => to_char(sysdate, 'dd.mm.yyyy'));
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cZAKAZ, sCELL_VALUE => sZAKAZ);
    --PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cTEMA,  sCELL_VALUE => );
  
    -- список изделий по заказу
    for rra in (select PS.MAIN_QUANT,
                       NM.NOMEN_NAME,
                       case
                         when PS.NOM_MODIF is not null then
                          (select MR.NAME from FCMATRESOURCE MR where MR.NOMEN_MODIF = PS.NOM_MODIF)
                         else
                          null
                       end as MTR_NAME
                  from PRODUCTORDS PS,
                       DICNOMNS    NM,
                       NOMMODIF    MD
                 where PS.PRN = nPRODORD) loop
      n := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cSPEC);
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cART,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => nvl(rra.mtr_name, rra.nomen_name));
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQUANT,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  nCELL_VALUE   => rra.main_quant);
    end loop;
  
    -- список комплектующих
    for rsp in (select mr.name as name,
                       mtr.quant as sp_quant,
                       case
                         when ser.modif is not null and
                              mr.nomen_modif != ser.modif then
                          (select mrr.name
                             from fcmatresource mrr,
                                  nommodif      mdd
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
                  from udo_prodcost_tmp_mtr mtr,
                       fcmatresource        mr
                 where mtr.prod_sign = 1
                   and mtr.matres = mr.rn
                   and not exists (select null
                          from udo_prodcost_tmp_ser ser
                         where ser.ident = mtr.ident
                           and ser.matres = mtr.matres
                           and ser.rec_type > 9)
                 order by name) loop
      n := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE);
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
                                  sCELL_VALUE   => to_char(rsp.trdoc_date, 'dd.mm.yyy'));
    
    end loop;
  
    -- подчистка
    PRSG_EXCEL.LINE_DELETE(sLINE_NAME => cSPEC);
    PRSG_EXCEL.LINE_DELETE(sLINE_NAME => cLINE);
  end print_list;

begin
  -- по всем отмеченным записям сформируем данные
  for rec in (select DOCUMENT from SELECTLIST where IDENT = nIDENT) loop
    -- запись заказа на производство
    P_PRODUCTORD_EXISTS(nCOMPANY => nCOMPANY, nRN => rec.document, nCRN => nCRN);
    -- формирование данных
    UDO_P_PRODCOST_ORD(nCOMPANY => nCOMPANY, nIDENT => nIDENT, nSIGN_PROJECT => 1, nPRODORD => rec.document);
  end loop;

  -- описание отчета
  PRSG_EXCEL.PREPARE;
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
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cF_DD);

  -- печать (для каждого заказа отдельный лист)
  for rls in (select distinct T.DOCUMENT from UDO_PRODCOST_TMP T where T.IDENT = nIDENT) loop
    -- печать листа
    print_list(nPRODORD => rls.document);
  end loop;

  -- подчистка
  PRSG_EXCEL.SHEET_DELETE(sSHEET_NAME => cFORM);

end;
/

