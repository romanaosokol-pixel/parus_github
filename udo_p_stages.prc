create or replace procedure UDO_P_STAGES(nIDENT in number)
  --Процедура отчета "Этапы договоров"
  as
    ----Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'Sheet1'; -- Лист
  L_lStr     constant PKG_STD.TSTRING := 'Stroka';
  
  C_sName    constant PKG_STD.TSTRING := 'Zagolovok';
  C_sData    constant PKG_STD.TSTRING := 'Data';
  C_sKontr   constant PKG_STD.TSTRING := 'DocText';
  C_sDoc     constant PKG_STD.TSTRING := 'DocNum';
  C_nStage   constant PKG_STD.TSTRING := 'Stage';
  C_sShifr   constant PKG_STD.TSTRING := 'Shifr';
  C_dBegin   constant PKG_STD.TSTRING := 'Begin_Date';
  C_dEnd     constant PKG_STD.TSTRING := 'End_Date';
  C_nStoim   constant PKG_STD.TSTRING := 'Stoim';
  C_nStoimNds constant PKG_STD.TSTRING := 'Stoim_nds';
  C_sIspol    constant PKG_STD.TSTRING := 'Ispol';
  C_sIspolT   constant PKG_STD.TSTRING := 'Ispol_Text';
  C_nIspolStage constant PKG_STD.TSTRING := 'Ispol_Stage';
  C_sIspolStart constant PKG_STD.TSTRING := 'Ispol_Start';
  C_sIspolEnd   constant PKG_STD.TSTRING := 'Ispol_End';
  

  C_nPos     constant PKG_STD.TSTRING := 'Pos';
  nSTR       number(17) := 1;
  nPos       number(17) := 0;
  
  sExtN      varchar2(2000);
  sDog       varchar2(2000);
  nStage     number(17) := 0;

  begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.CELL_DESCRIBE(C_sName);
  PRSG_EXCEL.CELL_DESCRIBE(C_sData);
  --PRSG_EXCEL.CELL_DESCRIBE(C_nItogo);
  --PRSG_EXCEL.CELL_DESCRIBE(C_sPeriod);

  -- Описываем ячейки спецификации материалов
  PRSG_EXCEL.LINE_DESCRIBE(L_lStr);
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPos);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sDoc);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sKontr);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nStage);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sShifr);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_dBegin);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_dEnd);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nStoim);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nStoimNds);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sIspol);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sIspolT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nIspolStage);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sIspolStart);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sIspolEnd);
  
  ---Заполнение шапки отчета
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sName, 'Этапы договоров');
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sData, 'Сегодня ' || to_char(SYSDATE, 'DD.MM.YYYY'));      

--p_exception(0,'error' || nIDENT);

  For rec in (
    select --pla.rn pla_rn, pla.quant pla_quant, 
    UDO_F_GET_USL_NAME(con.RN) name_usl, --pr.NAME_USL, 
    dense_rank() over(order by con.doc_pref) G_Pos, nvl(st.numb, '') S_Pos, 
    nvl(con.ext_number,'???') ext_number,
    st.begin_date, st.end_date, st.stage_sum, st.stage_sum_nds,
    prst.numb prst_numb, prst.name prst_name, prst.begplan, prst.endplan, --, staff.reason
    --row_number() over(partition by trim(con.doc_pref) || '-' || trim(con.doc_numb) order by trim(con.doc_pref) || '-' || trim(con.doc_numb), st.begin_date) S_Pos,
     ag.agnabbr,
    --pay.pay_sum,
    trim(con.doc_pref) || '-' || trim(con.doc_numb) doc_num, con.doc_date, --d_nom.nomen_code, 
    nvl(F_DOCS_PROPS_GET_STR_VALUE(1076177, 'FaceAccounts', fc.RN), '-') shifr_bu
from --project pr, DOCLINKS doc,
 CONTRACTS con
, STAGES st
, FACEACC fc
--, PAYNOTES pay
, PROJECTSTAGE prst
, PROJECTSTAGEPF staff
, AGNLIST ag
--, FCACPAYPLANS ppla
--, FCACOPERPLANS pla
--, DICNOMNS d_nom
, selectlist sl
 
where sl.ident = nIDENT and con.RN = sl.document
    /*and doc.in_unitcode = 'Projects'
    and doc.out_document = con.rn and doc.out_unitcode = 'Contracts'
    and pr.rn = doc.in_document*/
        and con.rn = st.prn
        and st.faceacc  = fc.rn
        --and pay.faceacc (+) = fc.rn
      and prst.faceacccust (+) = fc.rn
      and staff.prn (+) = prst.rn
      and ag.rn = staff.PERFORMER
      --and ppla.prn (+) = fc.rn
      --and fc.rn =  pla.prn
      --and con.agent = ag.rn
      --and pla.nomen = d_nom.rn
      order by --agnabbr, 
      con.doc_pref, con.doc_numb, st.numb --, st.begin_date, st.end_date--, nomen_code--, pla.begin_date
    ) loop

    nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStr);
    --if (nPos != rec.G_Pos) then
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nPos, 0, nSTR, rec.G_Pos);
    --end if;
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sKontr, 0, nSTR, trim(rec.name_usl)); 
    --if (sExtN != rec.EXT_NUMBER) then
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sDoc, 0, nSTR, trim(rec.ext_number));
    --end if;
    --if (nStage != rec.S_Pos) then
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nStage, 0, nSTR, rec.S_Pos);
    --end if;
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sShifr, 0, nSTR, trim(rec.shifr_bu));
    --PRSG_EXCEL.CELL_VALUE_WRITE(C_sNomenkl, 0, nSTR, trim(rec.nomen_code));
    PRSG_EXCEL.CELL_VALUE_WRITE(C_dBegin, 0, nSTR, trim(rec.begin_date));
    PRSG_EXCEL.CELL_VALUE_WRITE(C_dEnd, 0, nSTR, trim(rec.end_date));
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nStoim, 0, nSTR, rec.stage_sum);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nStoimNds, 0, nSTR, rec.stage_sum_nds);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIspol, 0, nSTR, rec.agnabbr);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIspolT, 0, nSTR, rec.prst_name);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nIspolStage, 0, nSTR, rec.prst_numb);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIspolStart, 0, nSTR, rec.begplan);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIspolEnd, 0, nSTR, rec.endplan);

    --nPos := rec.G_Pos;
    sExtN := trim(rec.EXT_NUMBER);
    sDog := trim(rec.EXT_NUMBER);
    nStage := rec.S_Pos;

    nPos := nPos + 1;
    end loop;

    PRSG_EXCEL.LINE_DELETE(L_lStr);
  
end UDO_P_STAGES;
/

