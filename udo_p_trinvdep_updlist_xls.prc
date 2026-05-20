create or replace procedure UDO_P_TRINVDEP_UPDLIST_XLS
(
  nCOMPANY in number, -- организация
  sUNIT    in varchar2, -- код раздела
  nIDENT   in number, -- отмеченные записи
  dBEG     in date, -- начало периода
  dEND     in date -- окончание периода
) as
  /*
    08/04/2023 Марков МВ.
    Отчет "Журнал регистрации для Расходных накладных в производство"
    UDO_TRINVDEP_UPDLIST_TMP
    UDO_TRINVDEP_UPDLIST_DETAILS
    UDO_TRINVDEP_UPDLIST_DOCUM
  */
  -- описание отчета
  cFORM  constant varchar2(20) := 'накладные';
  cPRINT constant varchar2(20) := 'печать';
  cUNIT  constant varchar2(20) := 'раздел';
  cPRD   constant varchar2(20) := 'период';
  --
  cLINE   constant varchar2(20) := 'строка';
  cD_OTR  constant varchar2(20) := 'д_отр';
  cD_SN   constant varchar2(20) := 'д_сн';
  cOPER   constant varchar2(20) := 'операция';
  cD_OPER constant varchar2(20) := 'д_опер';
  cAUTH   constant varchar2(20) := 'автор';
  cNOMEN  constant varchar2(20) := 'номен';
  cSERNUM constant varchar2(20) := 'серия';
  cQ_ADD  constant varchar2(20) := 'к_доб';
  cQ_OPER constant varchar2(20) := 'к_опер';
  cPREF   constant varchar2(20) := 'префикс';
  cNUMB   constant varchar2(20) := 'номер';

  n    integer;
  sTMP varchar2(2000);

begin
  -- инициалиазция данных
  delete from UDO_TRINVDEP_UPDLIST_TMP;
  delete from UDO_TRINVDEP_UPDLIST_DETAILS;
  delete from UDO_TRINVDEP_UPDLIST_DOCUM;
  --p_exception(0, 'sUNIT = %s', sUNIT);
  if sUNIT = 'CostDeliverySheets' then
    -- по отмеченным КВ
    UDO_P_TRINVDEP_UPDLISTSH_TMP(nCOMPANY => nCOMPANY, nIDENT => nIDENT, dBEG => dBEG, dEND => dEND);
  elsif sUNIT = 'GoodsTransInvoicesToDepts' then
    -- по отмеченным накладным
    UDO_P_TRINVDEP_UPDLISTTRD_TMP(nCOMPANY => nCOMPANY, nIDENT => nIDENT, dBEG => dBEG, dEND => dEND);
  else
    -- за период
    UDO_P_TRINVDEP_UPDLIST_TMP(nCOMPANY => nCOMPANY, nIDENT => nIDENT, dBEG => dBEG, dEND => dEND);
  end if;

  -- описание отчета
  PRSG_EXCEL.PREPARE;
  PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => cFORM);
  --
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cPRINT);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cUNIT);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cPRD);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cD_OTR);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cD_SN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cOPER);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cD_OPER);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cAUTH);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cNOMEN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cSERNUM);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cQ_ADD);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cQ_OPER);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cPREF);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cNUMB);

  -- печать
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cPRINT, sCELL_VALUE => to_char(sysdate, 'dd.mm.yyyy'));
  if sUNIT = 'CostDeliverySheets' then
    -- по отмеченным КВ
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME  => cUNIT,
                                sCELL_VALUE => 'Комплектовочные ведомости');
  elsif sUNIT = 'GoodsTransInvoicesToDepts' then
    -- по отмеченным накладным
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cUNIT, sCELL_VALUE => 'Расходные накладные');
  else
    -- за период
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cUNIT, sCELL_VALUE => 'По всем разделам');
  end if;
  sTMP := 'За период с ' || to_char(dBEG, 'dd.mm.yyyy') || 'по ' || to_char(dEND, 'dd.mm.yyyy');
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cPRD, sCELL_VALUE => sTMP);
  -- по действиям
  for rec in (select t.s_date,
                     t.us_date,
                     decode(d.operation, 'D', 'Удаление', 'U', 'Исправление', 'Прочее') as operation,
                     d.modifdate,
                     d.authid,
                     case
                       when d.i_modif is not null then
                        (select nm.nomen_name
                           from nommodif md,
                                dicnomns nm
                          where md.rn = d.i_modif
                            and md.prn = nm.rn)
                       else
                        null
                     end as i_nomen,
                     case
                       when d.i_goodsparty is not null then
                        (select gp.sernumb from goodsparties gp where gp.rn = d.i_goodsparty)
                       else
                        null
                     end as i_sernumb,
                     d.i_quant,
                     d.quant,
                     (select trim(replace(strtok(source => arc.note, delimeter => ',', item => 2), 'PREF:'))
                        from updatelist_arc arc
                       where arc.tablern = d.tableprn
                         and arc.operation = 'I') as pref,
                     (select trim(replace(strtok(source => arc.note, delimeter => ',', item => 3), 'NUMB:'))
                        from updatelist_arc arc
                       where arc.tablern = d.tableprn
                         and arc.operation = 'I') as numb
                from udo_trinvdep_updlist_tmp     t,
                     udo_trinvdep_updlist_details d
               where d.tableprn = t.trinvdep
                 and d.authid in ('DZYALOSHINSKAYA_AI', 'MARANICHENKO_AP', 'MURZENKOVA_MN', 'SERGEEVA_MV')
                 and t.ident = nIDENT
                 and d.ident = t.ident
               order by d.modifdate) loop
    n := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cD_OTR,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => rec.s_date);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cD_SN,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => rec.us_date);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cOPER,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => rec.operation);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cD_OPER,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => rec.modifdate);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cAUTH, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => rec.authid);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cNOMEN,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => rec.i_nomen);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cSERNUM,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => rec.i_sernumb);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQ_ADD,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                nCELL_VALUE   => rec.i_quant);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQ_OPER,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                nCELL_VALUE   => rec.quant);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cPREF, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => rec.pref);
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cNUMB, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => rec.numb);
  
  end loop;

  -- подчистка строк
  PRSG_EXCEL.LINE_DELETE(cLINE);

end;
/

