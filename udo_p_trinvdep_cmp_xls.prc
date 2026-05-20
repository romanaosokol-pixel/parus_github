create or replace procedure UDO_P_TRINVDEP_CMP_XLS
(
  nCOMPANY in number,
  nIDENT   in number,
  nSVOD    in number -- сводная комплектовочная ведомость
) as
  /*
    07/09/2022 Марков МВ.
    Расходные накладные на отпуск в подразделения
    Отчет "Комплектация"
  */
  -- описание отчета
  cFORM constant varchar2(20) := 'Комплектация';
  cHEAD constant varchar2(20) := 'заголовок';
  --
  cLINE_0 constant varchar2(20) := 'строка_0';
  cDOC    constant varchar2(20) := 'накладная';
  cARTCL  constant varchar2(20) := 'изделие';
  cZAYAV  constant varchar2(20) := 'заявка';
  cQUANT  constant varchar2(20) := 'количество';
  --
  cLINE_1 constant varchar2(20) := 'строка_1';
  cNPP_1  constant varchar2(20) := 'нпп_1';
  cART_1  constant varchar2(20) := 'артикул_1';
  cNAME_1 constant varchar2(20) := 'наименование_1';
  cSER_1  constant varchar2(20) := 'серия_1';
  cQNT_1  constant varchar2(20) := 'количество_1';
  cMEAS_1 constant varchar2(20) := 'еи_1';
  cPLC_1  constant varchar2(20) := 'мх_1';
  --
  cLINE_2 constant varchar2(20) := 'строка_2';
  cNPP_2  constant varchar2(20) := 'нпп_2';
  cART_2  constant varchar2(20) := 'артикул_2';
  cNAME_2 constant varchar2(20) := 'наименование_2';
  cSER_2  constant varchar2(20) := 'серия_2';
  cQNT_2  constant varchar2(20) := 'количество_2';
  cMEAS_2 constant varchar2(20) := 'еи_2';
  cPLC_2  constant varchar2(20) := 'мх_2';
  --
  cLINE_3 constant varchar2(20) := 'строка_3';
  cNPP_3  constant varchar2(20) := 'нпп_3';
  cART_3  constant varchar2(20) := 'артикул_3';
  cNAME_3 constant varchar2(20) := 'наименование_3';
  cSER_3  constant varchar2(20) := 'серия_3';
  cQNT_3  constant varchar2(20) := 'количество_3';
  cMEAS_3 constant varchar2(20) := 'еи_3';
  cPLC_3  constant varchar2(20) := 'мх_3';
  --
  cLINE_99 constant varchar2(20) := 'строка_99';
  cEXEC    constant varchar2(20) := 'ответственный';
  --
  n        integer;
  n1       integer;
  nFACEACC number(17);
  sTMP     varchar2(2000);
  sTMP1    varchar2(2000);
  iCOUNT   integer;
  bCHECK   boolean;
  sEXEC    varchar2(240);
  nCHECK_L number(17);
  sZakaz   varchar2(1024) := '';

  --
  procedure get_zakaz_prm
  (
    nFA_RN  in number,
    sPARAMS out varchar2
  ) is
  begin
    select FA.NUMB into sPARAMS from FACEACC FA where FA.RN = nFA_RN;
  end get_zakaz_prm;

begin
  --
  begin
    select count(*)
      into n
      from TRANSINVDEPT TD
     where TD.COMPANY = nCOMPANY
       and TD.RN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)
       and exists (select null
              from DOCLINKS L
             where L.OUT_DOCUMENT = TD.RN
               and L.OUT_UNITCODE = 'GoodsTransInvoicesToDepts'
               and L.IN_UNITCODE = 'CostDeliverySheets');
  exception
    when no_data_found then
      n := 0;
  end;
  --
  if n <= 0 then
    p_exception(0, 'Печать комплектации возможна только для накладных, связанных с комплектовочной ведомостью.');
  end if;

  -- описание отчета
  PRSG_EXCEL.PREPARE;
  PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => cFORM);
  --
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cHEAD);
  --

  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE_0);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_0, sCELL_NAME => cDOC);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_0, sCELL_NAME => cARTCL);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_0, sCELL_NAME => cZAYAV);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_0, sCELL_NAME => cQUANT);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE_1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => cNPP_1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => cART_1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => cNAME_1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => cSER_1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => cQNT_1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => cMEAS_1);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_1, sCELL_NAME => cPLC_1);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cNPP_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cART_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cNAME_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cSER_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cQNT_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cMEAS_2);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_2, sCELL_NAME => cPLC_2);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE_3);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_3, sCELL_NAME => cNPP_3);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_3, sCELL_NAME => cART_3);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_3, sCELL_NAME => cNAME_3);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_3, sCELL_NAME => cSER_3);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_3, sCELL_NAME => cQNT_3);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_3, sCELL_NAME => cMEAS_3);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_3, sCELL_NAME => cPLC_3);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE_99);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE_99, sCELL_NAME => cEXEC);

  -- печать
  begin
    select distinct TD.FACEACC
      into nFACEACC
      from TRANSINVDEPT TD
     where TD.COMPANY = nCOMPANY
       and TD.RN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT);
  exception
    when no_data_found then
      p_exception(0, 'Данные для отчета не найдены.');
    when too_many_rows then
      if nvl(nSVOD, 0) > 0 then
        nFACEACC := -1;
      else
        p_exception(0, 'Отмечены накладные более чем по одному заказу.');
      end if;
  end;
  --
  if nvl(nSVOD, 0) > 0 then
    nCHECK_L := 0;
    sTMP     := to_char(null);
    for rfa in (select distinct TD.FACEACC
                  from TRANSINVDEPT TD
                 where TD.COMPANY = nCOMPANY
                   and TD.RN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT)) loop
      get_zakaz_prm(nFA_RN => rfa.FACEACC, sPARAMS => sTMP1);
      if instr(sTMP1, '/') > 0 then
        sTMP1 := substr(sTMP1, 1, instr(sTMP1, '/') - 1);
      end if;
      if sTMP is null then
        sTMP := sTMP1;
      else
        if instr(sTMP, sTMP1) > 0 then
          null;
        else
          sTMP := sTMP || ';' || sTMP1;
        end if;
      end if;
    end loop;
    sTMP := 'Комплектация изделия по заказам № ' || sTMP;
  else
    nCHECK_L := 1;
    get_zakaz_prm(nFA_RN => nFACEACC, sPARAMS => sTMP);
    sTMP := 'Комплектация изделия по заказу № ' || sTMP;
  end if;
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cHEAD, sCELL_VALUE => sTMP);

  if nvl(nSVOD, 0) > 0 then
    -- печать сводного отчета
    null;
  else
    -- отмеченные накладные
    iCOUNT := 0;
    for rec in (select TD.RN,
                       TD.STORE,
                       trim(TD.PREF) || '-' || trim(TD.NUMB) || ' от ' || to_char(TD.DOCDATE, 'dd.mm.yyyy') as NUMB,
                       UDO_F_TRANSINVDEPT_MAIN_PROD(TD.RN) sProd,
                       UDO_F_TRANSINVDEPT_MAIN_NUMB(TD.RN) sZakaz
                  from TRANSINVDEPT TD,
                       SELECTLIST   SL
                 where SL.IDENT = nIDENT
                   and SL.DOCUMENT = TD.RN
                   and TD.COMPANY = nCOMPANY) loop
      --
      if rec.sZakaz is not null then
        if INSTR(rec.sProd, '(000') > 0 then
             sZakaz := SUBSTR(rec.sProd, 0, INSTR(rec.sProd, '(000')) || 'зав.№' || rec.sZakaz || ')';
        else sZakaz := rec.sProd || ' (зав.№' || rec.sZakaz || ')';
        end if;
      else sZakaz := rec.sProd;
      end if;

      if nvl(nSVOD, 0) = 0 or
         nCHECK_L = 0 then
        n := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE_0);
        PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cZAYAV, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, 
                                    sCELL_VALUE => UDO_F_INVDEPT_DEPORD(rec.rn));
        if nvl(nSVOD, 0) = 0 then
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cDOC,
                                      iCELL_INDEX_X => 0,
                                      iCELL_INDEX_Y => n,
                                      sCELL_VALUE   => rec.numb);
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cARTCL, 
                                      iCELL_INDEX_X => 0, 
                                      iCELL_INDEX_Y => n, 
                                      sCELL_VALUE => sZakaz); --rec.sProd || ' ' || rec.sZakaz);
        end if;
        nCHECK_L := 1;
      end if;


      -- спецификация
      if nvl(nSVOD, 0) = 0 then
        iCOUNT := 0;
      end if;
      for recs in (select TDS.RN,
                          TDS.QUANT,
                          TDS.GOODSPARTY,
                          upper(MD.MODIF_NAME) as MODIF_CODE,
                          NM.NOMEN_NAME,
                          MU.MEAS_MNEMO,
                          GP.SERNUMB
                     from TRANSINVDEPTSPECS TDS,
                          NOMMODIF          MD,
                          DICNOMNS          NM,
                          DICMUNTS          MU,
                          GOODSPARTIES      GP
                    where TDS.PRN = rec.rn
                      and TDS.NOMMODIF = MD.RN
                      and MD.PRN = NM.RN
                      and NM.UMEAS_MAIN = MU.RN
                      and GP.RN (+)= TDS.GOODSPARTY
        ) loop
        -- по местам хранения
        bCHECK := true;
        for rpl in (select trim(CEL.PREF) || '.' || trim(CEL.TIER) || '.' || trim(CEL.NUMB) CELL,
                           VPL.nQUANT
                      from V_STRPLRESJRNL_DOCS VPL,
                           STPLCELLS           CEL
                     where VPL.nres_type = 1
                       and VPL.ncell = CEL.RN
                       and exists (select *
                              from V_DOCLINKS_INOUT_IN_EXT DLIN
                             where (DLIN.NIN_DOCUMENT = recs.rn)
                               and (DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs')
                               and (DLIN.NDOCUMENT = VPL.NRN))) loop
          iCOUNT := iCOUNT + 1;
          bCHECK := false;
          n1     := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE_2);
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cNPP_2,
                                      iCELL_INDEX_X => 0,
                                      iCELL_INDEX_Y => n1,
                                      sCELL_VALUE   => to_char(iCOUNT));
          if instr(recs.modif_code, 'ГОСТ') > 0 then
            sTMP := substr(recs.modif_code, instr(recs.modif_code, 'ГОСТ'));
            PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cART_2,
                                        iCELL_INDEX_X => 0,
                                        iCELL_INDEX_Y => n1,
                                        sCELL_VALUE   => sTMP);
          end if;
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cNAME_2,
                                      iCELL_INDEX_X => 0,
                                      iCELL_INDEX_Y => n1,
                                      sCELL_VALUE   => recs.nomen_name);
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cSER_2,
                                      iCELL_INDEX_X => 0,
                                      iCELL_INDEX_Y => n1,
                                      sCELL_VALUE   => recs.sernumb);
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQNT_2,
                                      iCELL_INDEX_X => 0,
                                      iCELL_INDEX_Y => n1,
                                      nCELL_VALUE   => rpl.nquant);
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cMEAS_2,
                                      iCELL_INDEX_X => 0,
                                      iCELL_INDEX_Y => n1,
                                      sCELL_VALUE   => recs.meas_mnemo);
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cPLC_2,
                                      iCELL_INDEX_X => 0,
                                      iCELL_INDEX_Y => n1,
                                      sCELL_VALUE   => rpl.cell);
        end loop;
        --
        if bCHECK then
          iCOUNT := iCOUNT + 1;
          n1     := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE_2);
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cNPP_2,
                                      iCELL_INDEX_X => 0,
                                      iCELL_INDEX_Y => n1,
                                      sCELL_VALUE   => to_char(iCOUNT));
          if instr(recs.modif_code, 'ГОСТ') > 0 then
            sTMP := substr(recs.modif_code, instr(recs.modif_code, 'ГОСТ'));
            PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cART_2,
                                        iCELL_INDEX_X => 0,
                                        iCELL_INDEX_Y => n1,
                                        sCELL_VALUE   => sTMP);
          end if;
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cNAME_2,
                                      iCELL_INDEX_X => 0,
                                      iCELL_INDEX_Y => n1,
                                      sCELL_VALUE   => recs.nomen_name);
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cSER_2,
                                      iCELL_INDEX_X => 0,
                                      iCELL_INDEX_Y => n1,
                                      sCELL_VALUE   => recs.sernumb);
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQNT_2,
                                      iCELL_INDEX_X => 0,
                                      iCELL_INDEX_Y => n1,
                                      nCELL_VALUE   => recs.quant);
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cMEAS_2,
                                      iCELL_INDEX_X => 0,
                                      iCELL_INDEX_Y => n1,
                                      sCELL_VALUE   => recs.meas_mnemo);
          PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cPLC_2, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n1, sCELL_VALUE => '');
        end if;
      
      end loop;
    
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cQUANT, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, nCELL_VALUE => iCOUNT);
    
    end loop;
  end if;
  --
  n := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE_99);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cEXEC, iCELL_INDEX_X => 0, iCELL_INDEX_Y => n, sCELL_VALUE => sEXEC);

  -- 
  PRSG_EXCEL.LINE_DELETE(cLINE_0);
  PRSG_EXCEL.LINE_DELETE(cLINE_1);
  PRSG_EXCEL.LINE_DELETE(cLINE_2);
  PRSG_EXCEL.LINE_DELETE(cLINE_3);
  PRSG_EXCEL.LINE_DELETE(cLINE_99);

end;
/

