create or replace procedure UDO_P_REP_STAGE_KARTZATR_NEW(
       nIDENT in number, --идентификатор помеченных записей -- Этапы проекта или договора
       sAgn_main in varchar
       --dDocDate in date
)
--Процедура для отчета "Калькуляция затрат"
as
  --nSum      number(17,2) := 0;
  nPlan0201   number(17,2) := 0;
  sTMP        varchar(100) :='';
  sManager    varchar(100);
  nNIR_Total  number(17,2) := 0;

 /* sWork_Sheefr_   varchar(2000);
  sMaterial_      varchar(2000):='1. Материалы';
  sPKI_           varchar(2000):='2. ПКИ';
  sSpecObor_      varchar(2000):='3. Спецоборудование';
  sProchie_       varchar(2000):='7. Прочие расходы, в т.ч. командировочные расходы' ;
  sKontragent_    varchar(2000):='';
  */
  
  ----Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := '2 план кальк';  -- Лист 'Калк'; 
  C_SLIST1   constant PKG_STD.TSTRING := '20 (20д) приб'; -- Лист '20Д';  
  C_SLIST2   constant PKG_STD.TSTRING := 'Пояснительная'; -- Лист 'Пояснительная'
  C_SLIST3   constant PKG_STD.TSTRING := 'Прил. № 5 Ф1(1д) прот'; -- Лист 'Протокол';
  C_SLIST4   constant PKG_STD.TSTRING := '9 (9д) ОЗП НИР(ОКР)'; -- Лист '9 (9д) ОЗП НИР(ОКР)' '9(9Д)'; 
  C_SLIST5   constant PKG_STD.TSTRING := '7(7д) работы(усл) НИР(ОКР)'; -- Лист '7(7д) работы(усл) НИР(ОКР) '

  L_lStr     constant PKG_STD.TSTRING := 'L_Stroka';
  L_lStrNIR  constant PKG_STD.TSTRING := 'Stroka7_NIR';

  C_sRep_yare         constant PKG_STD.TSTRING := 'sRep_yare';
  C_sWork_name        constant PKG_STD.TSTRING := 'sWork_name';
  C_sOKP_OKPD2_CODE   constant PKG_STD.TSTRING := 'sOKP_OKPD2_CODE';
  C_sSTAGE_NAME       constant PKG_STD.TSTRING := 'sSTAGE_NAME';
  C_sTechnik_DOC      constant PKG_STD.TSTRING := 'sTechnik_DOC';
  
  --C_sPlan_yare  constant PKG_STD.TSTRING := 'sPlan_yare';
  --C_sFact_yare  constant PKG_STD.TSTRING := 'sFact_yare';
  
  C_nPlan_0100   constant PKG_STD.TSTRING := 'nPlan_0100';
  C_nPlan_0101   constant PKG_STD.TSTRING := 'nPlan_0101';
  C_nPlan_0102   constant PKG_STD.TSTRING := 'nPlan_0102';
  C_nPlan_0103   constant PKG_STD.TSTRING := 'nPlan_0103';
  C_nPlan_0104   constant PKG_STD.TSTRING := 'nPlan_0104';
  C_nPlan_0105   constant PKG_STD.TSTRING := 'nPlan_0105';
  C_nPlan_0106   constant PKG_STD.TSTRING := 'nPlan_0106';
  C_nPlan_0107   constant PKG_STD.TSTRING := 'nPlan_0107';
  C_nPlan_0108   constant PKG_STD.TSTRING := 'nPlan_0108';
  C_nPlan_0109   constant PKG_STD.TSTRING := 'nPlan_0109';
  C_nPlan_0110   constant PKG_STD.TSTRING := 'nPlan_0110';
  C_nPlan_0200   constant PKG_STD.TSTRING := 'nPlan_0200';
  C_nPlan_0201   constant PKG_STD.TSTRING := 'nPlan_0201';
  C_nPlan_0202   constant PKG_STD.TSTRING := 'nPlan_0202';
  C_nPlan_0203   constant PKG_STD.TSTRING := 'nPlan_0203';
  C_nPlan_0300   constant PKG_STD.TSTRING := 'nPlan_0300';
  C_nPlan_0400   constant PKG_STD.TSTRING := 'nPlan_0400';
  C_nPlan_0401   constant PKG_STD.TSTRING := 'nPlan_0401';
  C_nPlan_0402   constant PKG_STD.TSTRING := 'nPlan_0402';
  C_nPlan_0500   constant PKG_STD.TSTRING := 'nPlan_0500';
  C_nPlan_0600   constant PKG_STD.TSTRING := 'nPlan_0600';
  C_nPlan_0700   constant PKG_STD.TSTRING := 'nPlan_0700';
  C_nPlan_0800   constant PKG_STD.TSTRING := 'nPlan_0800';
  C_nPlan_0900   constant PKG_STD.TSTRING := 'nPlan_0900';
  C_nPlan_1000   constant PKG_STD.TSTRING := 'nPlan_1000';
  C_nPlan_1100   constant PKG_STD.TSTRING := 'nPlan_1100';
  C_nPlan_1200   constant PKG_STD.TSTRING := 'nPlan_1200';
  C_nPlan_1300   constant PKG_STD.TSTRING := 'nPlan_1300';
  C_nPlan_1400   constant PKG_STD.TSTRING := 'nPlan_1400';
  C_nPlan_1500   constant PKG_STD.TSTRING := 'nPlan_1500';
  C_nPlan_1600   constant PKG_STD.TSTRING := 'nPlan_1600';
  C_nPlan_1700   constant PKG_STD.TSTRING := 'nPlan_1700';
  C_nPlan_1800   constant PKG_STD.TSTRING := 'nPlan_1800';
  C_nPlan_1900   constant PKG_STD.TSTRING := 'nPlan_1900';
  
  C_nPlan_trud      constant PKG_STD.TSTRING := 'nPlan_trud';
  C_sKL_Podpisant   constant PKG_STD.TSTRING := 'sKL_Podpisant';
  C_sKL_Podp_EMPPOST   constant PKG_STD.TSTRING := 'sKL_Podp_EMPPOST';
  

  -- По второму листк
  C_sWork_stage       constant PKG_STD.TSTRING := 'sWork_stage';
  C_sWork_Sheefr      constant PKG_STD.TSTRING := 'sWork_Sheefr';
  C_sArticle_name     constant PKG_STD.TSTRING := 'sArticle_name';
  C_nArticle_Sum      constant PKG_STD.TSTRING := 'nArticle_Sum';
  C_sRESPONSIBLE      constant PKG_STD.TSTRING := 'sRESPONSIBLE';
  C_sMANAGER          constant PKG_STD.TSTRING := 'sMANAGER';

  C_sPers_ROLE        constant PKG_STD.TSTRING := 'sPers_ROLE';
  C_sPers_EMPPOST     constant PKG_STD.TSTRING := 'sPers_EMPPOST';
  C_sMAN_EMPPOST      constant PKG_STD.TSTRING := 'sMAN_EMPPOST';

  --- Протокол
  C_sPr_Agent_name    constant PKG_STD.TSTRING := 'sPr_Agent_name';
  C_nPr_Stage_num     constant PKG_STD.TSTRING := 'nPr_Stage_num';
  C_sPr_Work_name     constant PKG_STD.TSTRING := 'sPr_Work_name';
  C_sPr_Date_start    constant PKG_STD.TSTRING := 'sPr_Date_start';
  C_sPr_Date_end      constant PKG_STD.TSTRING := 'sPr_Date_end';
  C_nPr_Sum_wotNDS    constant PKG_STD.TSTRING := 'nPr_Sum_wotNDS';
  C_sPr_Podpisant     constant PKG_STD.TSTRING := 'sPr_Podpisant';
  C_sPr_Podp_EMPPOST  constant PKG_STD.TSTRING := 'sPr_Podp_EMPPOST';
  
  --- Зарплата
  C_sZP_WorkName1     constant PKG_STD.TSTRING := 'sZP_WorkName1';
  C_sZP_WorkName2     constant PKG_STD.TSTRING := 'sZP_WorkName2';
  C_sZP_Stage_numb    constant PKG_STD.TSTRING := 'sZP_Stage_numb';
  C_sZP_Work_period   constant PKG_STD.TSTRING := 'sZP_Work_period';
  C_sZP_Podpisant     constant PKG_STD.TSTRING := 'sZP_Podpisant';
  C_sZP_Podp_EMPPOST  constant PKG_STD.TSTRING := 'sZP_Podp_EMPPOST';
 
  -- C_SLIST1 20Д
  C_s20D_Podpisant    constant PKG_STD.TSTRING := 's20D_Podpisant';
  C_s20D_Podp_EMPPOST constant PKG_STD.TSTRING := 's20D_Podp_EMPPOST';
  
  -- C_SLIST5 7(7д) работы(усл) НИР(ОКР)
  C_nNIR_N      constant PKG_STD.TSTRING := 'NIR_N';
  C_sNIR_Org    constant PKG_STD.TSTRING := 'NIR_Org';
  C_sNIR_Shifr  constant PKG_STD.TSTRING := 'NIR_Shifr';
  C_nNIR_Sum    constant PKG_STD.TSTRING := 'NIR_Sum';
  C_sNIR_Plan   constant PKG_STD.TSTRING := 'NIR_Plan';
  C_sNIR_Fact   constant PKG_STD.TSTRING := 'NIR_Fact';
  C_nNIR_Doc    constant PKG_STD.TSTRING := 'NIR_Doc';
  C_nNIR_Date   constant PKG_STD.TSTRING := 'NIR_Date';
  C_nNIR_Total  constant PKG_STD.TSTRING := 'NIR_Total';
  C_sNIR_Stage_numb constant PKG_STD.TSTRING := 'sNIR_Stage_numb';
 

  nSTR      number(17) := 1;
  nSTR_N    number(17) := 1;
  nPrint_header number := 0;
  nEtap         number := 0;
  sAgentName  AGNLIST.AGNNAME%type;
  sStageNumb  STAGES.NUMB%type := '';
  sWork_name  STAGES.DESCRIPTION%type;
  dDateStart  date;
  dDateEnd    date;
  nSum_WithotNDS number(17,2);
  sPodpisant  AGNLIST.AGNNAME%type;
  sPodpEMPPOS AGNLIST.EMPPOST%type;
  
  nCostSum UDO_PRJSTG_PRCLC.COST_SUM%type; --number(17,2);
  --rec_numb UDO_PRJSTG_PRCLC.NUMB%type;      --VARCHAR2(10)

begin
--p_exception(0,'C_SLIST3! sAgn_main: ' || sAgn_main || '; nIDENT: ' || nIDENT);

  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.CELL_DESCRIBE(C_sRep_yare);
  PRSG_EXCEL.CELL_DESCRIBE(C_sWork_name);
  PRSG_EXCEL.CELL_DESCRIBE(C_sOKP_OKPD2_CODE);
  PRSG_EXCEL.CELL_DESCRIBE(C_sSTAGE_NAME);
  PRSG_EXCEL.CELL_DESCRIBE(C_sTechnik_DOC);

--  PRSG_EXCEL.CELL_DESCRIBE(C_sPlan_yare);
--  PRSG_EXCEL.CELL_DESCRIBE(C_sFact_yare);
  
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0100);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0101);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0102);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0103);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0104);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0105);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0106);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0107);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0108);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0109);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0110);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0200);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0201);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0202);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0203);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0300);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0400);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0401);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0402);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0500);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0600);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0700);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0800);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_0900);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_1000);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_1100);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_1200);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_1300);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_1400);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_1500);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_1600);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_1700);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_1800);
  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_1900);

  PRSG_EXCEL.CELL_DESCRIBE(C_nPlan_trud);
  PRSG_EXCEL.CELL_DESCRIBE(C_sKL_Podpisant);
  PRSG_EXCEL.CELL_DESCRIBE(C_sKL_Podp_EMPPOST);

  -- Описываем ячейки спецификации материалов
--  PRSG_EXCEL.LINE_DESCRIBE(L_lStr);
/*  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sKontr);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sDoc);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nQuant);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sShifr);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sNomenkl);*/

  ---Заполнение шапки отчета
 -- PRSG_EXCEL.CELL_VALUE_WRITE(C_sName, 'Плановые затраты по статьям ');
 -- PRSG_EXCEL.CELL_VALUE_WRITE(C_sData, 'Сегодня ' || to_char(SYSDATE, 'DD.MM.YYYY'));  
 
 -- Сформируем подписанта
  sPodpisant := UDO_F_FIO_NAME_PODPISANT(sAgn_main);
  begin
    select ag.emppost into sPodpEMPPOS from AGNLIST ag where trim(ag.agnabbr) = trim(sAgn_main);
  exception when others then
    sPodpEMPPOS := null;
  end;
--p_exception(0,'nIDENT: ' || nIDENT);

  For proj in (
    select --trim(sta.NUMB)         as NUMB, sta.COST_SUM, 
          pst.rn                  as pst_rn
          ,pst.LAB_STAG 
          ,pst.name               as Work_name
          ,trim(pst.numb)         as Stage_numb
          ,pst.expected_res
          ,extract(year from str.date_from) as nDoc_Yare 
          ,ag.agnname             as Agent_Name
          ,pst.begplan            as DateStart
          ,pst.endplan            as DateEnd
--udo_f_price_struct_getfact(sta.RN)
  
    from  PROJECT             prj
        , PROJECTSTAGE        pst
        , UDO_PRJSTG_PRSTRUCT str
        --, UDO_PRJSTG_PRCLC    sta
        , AGNLIST             ag
        , selectlist     sl
 
    where sl.ident = nIDENT 
        and pst.RN = sl.document
        and prj.rn = pst.prn
        and str.prn = pst.rn
        --and sta.prn = str.rn
        and str.sign_act = 1
        and ag.rn = prj.ext_cust
     
    union
    
    select --trim(sta.NUMB)        as NUMB, sta.COST_SUM,
          cst.rn                 as pst_rn
          ,0                     as LAB_STAG 
          ,cst.description       as Work_name
          ,trim(cst.numb)        as Stage_numb
          ,null                  as expected_res
          ,extract(year from str.date_from) as nDoc_Yare 
          ,ag.agnname            as Agent_Name
          ,cst.begin_date        as DateStart
          ,cst.end_date          as DateEnd
  
    from  CONTRACTS             cnt
        , STAGES                cst
        , CONTRPRSTRUCT         str
        --, CONTRPRCLC            sta V_CONTRPRCLC 
        , AGNLIST               ag
        , selectlist     sl
 
    where sl.ident = nIDENT 
        and cst.RN = sl.document
        and cnt.rn = cst.prn
        and str.prn = cst.rn
        --and sta.prn = str.rn
        and str.sign_act = 1
        and ag.rn = cnt.agent
                
    order by stage_numb --numb
      
    ) loop
--p_exception(0,'pst_rn: ' || proj.pst_rn);

    for rec in (
      select 1 as from_pr, prs.nrn prs_nrn, scmp.fpdartcl s_art, trim(scmp.numb) numb,
             scmp.kind, scmp.rn scmp_rn, scmp.prn scmp_prn, nvl(scmp.percent, 100) percent 
      from UDO_V_PRJSTG_PRSTRUCT prs, PRJCALCSCHMSP scmp
      where prs.NPRN = proj.pst_rn and scmp.prn = prs.nCALCSCHM
        
      union 
      
      select 0 as from_pr, prs.nrn prs_nrn, scmp.fpdartcl s_art, trim(scmp.numb) numb,
             scmp.kind, scmp.rn scmp_rn, scmp.prn scmp_prn, nvl(scmp.percent, 100) percent 
      from V_CONTRPRSTRUCT prs, PRJCALCSCHMSP scmp
      where prs.NPRN = proj.pst_rn and scmp.prn = prs.nCALCSCHM
        
      order by numb 
    ) loop

--p_exception(0,'pst_rn: ' || proj.pst_rn || '; rec.prs_nrn: ' || rec.prs_nrn || '; rec.s_art: ' || rec.s_art);
/*if (6298194 = rec.scmp_rn) then 
  p_exception(0,'scmp_rn: ' || rec.scmp_rn);
end if;*/
        UDO_P_PRJSTG_PRCLC_COST_SUM(rec.prs_nrn, rec.s_art, rec.kind, rec.scmp_rn, rec.scmp_prn, rec.from_pr, nCostSum/*, rec.numb*/);

        nCostSum := nCostSum * rec.percent / 100;
      
      if    rec.numb = '0100' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0100, nCostSum);
      elsif rec.numb = '0101' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0101, nCostSum);
      elsif rec.numb = '0102' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0102, nCostSum);
      elsif rec.numb = '0103' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0103, nCostSum);
      elsif rec.numb = '0104' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0104, nCostSum);
      elsif rec.numb = '0105' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0105, nCostSum);
      elsif rec.numb = '0106' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0106, nCostSum);
      elsif rec.numb = '0107' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0107, nCostSum);
      elsif rec.numb = '0108' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0108, nCostSum);
      elsif rec.numb = '0109' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0109, nCostSum);
      elsif rec.numb = '0110' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0110, nCostSum);
      elsif rec.numb = '0200' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0200, nCostSum);
      elsif rec.numb = '0201' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0201, nCostSum);
        nPlan0201 := nCostSum;
      elsif rec.numb = '0202' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0202, nCostSum);
      elsif rec.numb = '0203' then -- добавляем к Основной зарплате
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0201, nPlan0201+nCostSum);
      elsif rec.numb = '0300' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0300, nCostSum);
      elsif rec.numb = '0400' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0400, nCostSum);
      elsif rec.numb = '0401' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0401, nCostSum);
      elsif rec.numb = '0402' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0402, nCostSum);
      elsif rec.numb = '0500' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0500, nCostSum);
      elsif rec.numb = '0600' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0600, nCostSum);
      elsif rec.numb = '0700' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0700, nCostSum);
      elsif rec.numb = '0800' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0800, nCostSum);
      elsif rec.numb = '0900' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_0900, nCostSum);
      elsif rec.numb = '1000' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_1000, nCostSum);
      elsif rec.numb = '1100' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_1100, nCostSum);
      elsif rec.numb = '1200' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_1200, nCostSum);
      elsif rec.numb = '1300' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_1300, nCostSum);
      elsif rec.numb = '1400' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_1400, nCostSum);
      elsif rec.numb = '1500' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_1500, nCostSum);
      elsif rec.numb = '1600' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_1600, nCostSum);
      elsif rec.numb = '1700' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_1700, nCostSum);
      elsif rec.numb = '1800' then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_1800, nCostSum);
      elsif rec.numb = '1900' then
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_1900, rec.cost_sum);
        nSum_WithotNDS := nCostSum;
      end if;

      if nPrint_header = 0 then
        nPrint_header := 1;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPlan_trud,      proj.LAB_STAG);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sRep_yare,  'на '||proj.nDoc_Yare ||' г.');
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sWork_name,      proj.Work_name);
    --    PRSG_EXCEL.CELL_VALUE_WRITE(C_sOKP_OKPD2_CODE, rec.);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sSTAGE_NAME, 'Этап '|| proj.Stage_numb);
     --   PRSG_EXCEL.CELL_VALUE_WRITE(C_sTechnik_DOC,    rec.LAB_PLAN);

--        PRSG_EXCEL.CELL_VALUE_WRITE(C_sPlan_yare,      rec.nDoc_Yare||' г.');
--        PRSG_EXCEL.CELL_VALUE_WRITE(C_sFact_yare,      rec.nDoc_Yare||' г.');
        
        sAgentName := proj.AGENT_NAME;
        --if ('' = sStageNumb) then 
          sStageNumb := trim(proj.Stage_numb);
        --else sStageNumb := sStageNumb || ',' || trim(rec.Stage_numb);
        --end if;
        sWork_name := proj.Work_name;
        dDateStart := proj.DATESTART;
        dDateEnd   := proj.DATEEND;
        nPlan0201 := 0;
      end if;
--p_exception(0,'rec.numb: ' || rec.numb || '; rec.cost_sum: ' || rec.cost_sum);
      end loop;
      
  end loop;
  --PRSG_EXCEL.CELL_VALUE_WRITE(C_sSTAGE_NAME, 'Этап '|| sStageNumb);

--if (true) then
--  PRSG_EXCEL.CELL_VALUE_WRITE(C_sKL_Podpisant, '________________ '||sPodpisant);
--  PRSG_EXCEL.CELL_VALUE_WRITE(C_sKL_Podp_EMPPOST, sPodpEMPPOS);

  -- Установка текущего рабочего листа "Пояснительная"
  PRSG_EXCEL.SHEET_SELECT(C_SLIST2);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.CELL_DESCRIBE(C_sWork_stage);
  PRSG_EXCEL.CELL_DESCRIBE(C_sWork_Sheefr);
  PRSG_EXCEL.CELL_DESCRIBE(C_sRESPONSIBLE);
  PRSG_EXCEL.CELL_DESCRIBE(C_sMANAGER);

  PRSG_EXCEL.CELL_DESCRIBE(C_sPers_ROLE);
  PRSG_EXCEL.CELL_DESCRIBE(C_sPers_EMPPOST);
  PRSG_EXCEL.CELL_DESCRIBE(C_sMAN_EMPPOST);

 
    -- Описываем ячейки спецификации материалов
  PRSG_EXCEL.LINE_DESCRIBE(L_lStr);
 
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sArticle_name);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nArticle_Sum);

  nPrint_header := 0; nEtap := 0;
  For rd in (
    select trim(sta.NUMB) as NUMB
          ,sta.COST_SUM 
          ,fa.name        as Article_name
          ,pst.LAB_STAG 
          ,pst.name       as Work_name
          ,trim(pst.numb) as Stage_numb
          ,pst.expected_res
          ,extract(year from str.date_from) as nDoc_Yare 
          ,pt.code        as Prj_code
          ,prj.name_usl
          ,UDO_F_FIO_RN_PODPISANT(pst.RESPONSIBLE) as agnname  
          ,F_DOCS_PROPS_GET_STR_VALUE(1082887,'Projects', prj.rn)   as sManager 
          ,ag1.emppost                                    as Pers_emppost
          ,ag2.emppost                                    as Manag_emppost
    from  PROJECT             prj
        , PROJECTSTAGE        pst
        , UDO_PRJSTG_PRSTRUCT str
        , UDO_PRJSTG_PRCLC    sta
        , selectlist          sl
        , FPDARTCL            fa
        , PRJTYPE             pt
        , AGNLIST             ag1
        , AGNLIST             ag2
       
  where sl.ident = nIDENT 
      and pst.RN = sl.document
      and prj.rn = pst.prn
      and str.prn = pst.rn
      and sta.prn = str.rn
      and str.sign_act = 1
      and pt.rn = prj.prjtype
      and fa.rn = sta.cost_article
      and ag1.rn (+) = pst.RESPONSIBLE
      and ag2.agnabbr (+) = F_DOCS_PROPS_GET_STR_VALUE(1082887,'Projects', prj.rn)
   --   and substr(trim(sta.NUMB),4,1) = '0'
      and trim(sta.NUMB) in ('0100','0200','0300','0600','0900','1000','1100','1200','1400')
      order by sta.NUMB
    ) loop
    
     nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStr);
     PRSG_EXCEL.CELL_VALUE_WRITE(C_nArticle_Sum, 0, nSTR, rd.COST_SUM);
       
     rd.Article_name := rd.NUMB ||' - '|| rd.Article_name;
     if rd.COST_SUM > 0 then
       PRSG_EXCEL.CELL_VALUE_WRITE(C_sArticle_name, 0, nSTR, rd.Article_name);
     else
       PRSG_EXCEL.CELL_VALUE_WRITE(C_sArticle_name, 0, nSTR, rd.Article_name||', не предусмотрено');
     end if;  
     
     if nPrint_header = 0 then 
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sWork_stage, 'по затратам Этапа '||rd.Stage_numb);
        if rd.Prj_code = '15' or rd.Prj_code = '12' then
          sTMP := ' НИР: ';
        elsif rd.Prj_code = '14' or rd.Prj_code = '11'  then
          sTMP := ' ОКР: ';
        else
          sTMP := ': ';
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sWork_Sheefr, 'Шифр'||sTMP|| rd.name_usl);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sRESPONSIBLE, rd.agnname);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sPers_ROLE, 'Руководитель '||sTMP);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sPers_EMPPOST, rd.Pers_emppost);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sMAN_EMPPOST,  rd.Manag_emppost);
         
        if rd.smanager is not null then
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sMANAGER, UDO_F_FIO_NAME_PODPISANT(rd.smanager));
        end if;

      end if;
    end loop;
    
    PRSG_EXCEL.LINE_DELETE(L_lStr);

    -- Установка текущего рабочего листа "Протокол" 'Прил. № 5 Ф1(1д) прот'
    PRSG_EXCEL.SHEET_SELECT(C_SLIST3);
    nEtap := nEtap + 1;

    -- Описываем имена ячеек в шапке и подвале
    PRSG_EXCEL.CELL_DESCRIBE(C_sPr_Agent_name);
    PRSG_EXCEL.CELL_DESCRIBE(C_nPr_Stage_num);
    PRSG_EXCEL.CELL_DESCRIBE(C_sPr_Work_name);
    PRSG_EXCEL.CELL_DESCRIBE(C_sPr_Date_start);
    PRSG_EXCEL.CELL_DESCRIBE(C_sPr_Date_end);
    PRSG_EXCEL.CELL_DESCRIBE(C_nPr_Sum_wotNDS);
    PRSG_EXCEL.CELL_DESCRIBE(C_sPr_Podpisant); 
    PRSG_EXCEL.CELL_DESCRIBE(C_sPr_Podp_EMPPOST); 

    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPr_Agent_name, sAgentName);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nPr_Stage_num,  nEtap); -- sStageNumb
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPr_Work_name,  sWork_name);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPr_Date_start, to_char(dDateStart,'dd.mm.yyyy'));
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPr_Date_end,   to_char(dDateEnd, 'dd.mm.yyyy'));
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nPr_Sum_wotNDS, nSum_WithotNDS);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPr_Podpisant,  sPodpisant);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPr_Podp_EMPPOST, sPodpEMPPOS);


    -- Установка текущего рабочего листа Зарплата "9 (9д) ОЗП НИР(ОКР)"
    PRSG_EXCEL.SHEET_SELECT(C_SLIST4);

    -- Описываем имена ячеек в шапке и подвале
    PRSG_EXCEL.CELL_DESCRIBE(C_sZP_WorkName1);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZP_WorkName2);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZP_Stage_numb);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZP_Work_period);
    PRSG_EXCEL.CELL_DESCRIBE(C_sZP_Podpisant); 
    PRSG_EXCEL.CELL_DESCRIBE(C_sZP_Podp_EMPPOST); 

    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZP_WorkName1,  sWork_name);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZP_WorkName1,  sWork_name);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZP_Stage_numb, 'Этап '||sStageNumb);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZP_Work_period, to_char(dDateStart,'dd.mm.yyyy')||' - '||  to_char(dDateEnd, 'dd.mm.yyyy'));
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZP_Podpisant, '________________ '|| sPodpisant);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZP_Podp_EMPPOST, sPodpEMPPOS);

--end if;

  -- Установка текущего рабочего листа "7(7д) работы(усл) НИР(ОКР) "
  PRSG_EXCEL.SHEET_SELECT(C_SLIST5);
  
  PRSG_EXCEL.LINE_DESCRIBE(L_lStrNIR);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrNIR, C_nNIR_N);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrNIR, C_sNIR_Org);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrNIR, C_sNIR_Shifr);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrNIR, C_nNIR_Sum);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrNIR, C_sNIR_Plan);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrNIR, C_sNIR_Fact);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrNIR, C_nNIR_Doc);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStrNIR, C_nNIR_Date);
  
  PRSG_EXCEL.CELL_DESCRIBE(C_nNIR_Total);
  PRSG_EXCEL.CELL_DESCRIBE(C_sNIR_Stage_numb);

--p_exception(0,'sStageNumb: ' || sStageNumb);
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sNIR_Stage_numb, sStageNumb);

  For staff in (
    select row_number() over (order by pspf.nprn, pspf.sperformer) r_n, 
           udo_f_projectstage_buhnum(pspf.NPRN) BuhNum,
           con.sdoc_type||', '||trim(con.sdoc_pref)||'-'||trim(con.sdoc_numb)||', '||nvl(TO_CHAR(con.ddoc_date, 'DD.MM.YYYY'), '...') DocNum,
           nvl(TO_CHAR(st.dbegin_date, 'DD.MM.YYYY'), '...') ||'-'|| nvl(TO_CHAR(st.dend_date, 'DD.MM.YYYY'), '-') StDate,
           pspf.* 
    from V_PROJECTSTAGEPF pspf, V_STAGES_SHADOW st, V_CONTRACTS con, selectlist sl
    where sl.ident = nIDENT and pspf.NPRN = sl.document 
          and pspf.nfaceacc = st.nfaceacc
          and con.nrn = st.nprn
    order by pspf.nprn, pspf.sperformer, pspf.nfaceacc
    ) loop

        nSTR_N := PRSG_EXCEL.LINE_CONTINUE(L_lStrNIR);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nNIR_N, 0, nSTR_N, staff.r_n);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sNIR_Org, 0, nSTR_N, staff.sperformer);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sNIR_Shifr, 0, nSTR_N, staff.BuhNum);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nNIR_Sum, 0, nSTR_N, staff.ncost_plan);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nNIR_Doc, 0, nSTR_N, staff.DocNum);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nNIR_Date, 0, nSTR_N, staff.StDate);
        
        nNIR_Total := nNIR_Total + staff.ncost_plan;

    end loop;

    PRSG_EXCEL.CELL_VALUE_WRITE(C_nNIR_Total, nNIR_Total);
    
    PRSG_EXCEL.LINE_DELETE(L_lStrNIR);


    -- Установка текущего рабочего листа "20 (20д) приб"
    PRSG_EXCEL.SHEET_SELECT(C_SLIST1);

    -- Описываем имена ячеек в шапке и подвале
    PRSG_EXCEL.CELL_DESCRIBE(C_s20D_Podpisant);
    PRSG_EXCEL.CELL_DESCRIBE(C_s20D_Podp_EMPPOST);
   
    PRSG_EXCEL.CELL_VALUE_WRITE(C_s20D_Podpisant, '________________ '|| sPodpisant);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_s20D_Podp_EMPPOST, sPodpEMPPOS);
    
    PRSG_EXCEL.SHEET_SELECT(C_SLIST);

end UDO_P_REP_STAGE_KARTZATR_NEW;
/

