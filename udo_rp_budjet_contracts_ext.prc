create or replace procedure UDO_RP_BUDJET_CONTRACTS_EXT(
sPeriod in varchar,
SPERSON in varchar,
sGROUP_CODE in varchar,
sGROUP_CODE_NOT in varchar,
nPerQWARD in number   -- Номер квартала

) 
is
  ---- Процедура отчета "Тематический бюджет"
  -- Использовать UDO_V_FINPLAN_ARTS ???
    ---- Переменные отчета
  C_SLIST   constant PKG_STD.TSTRING := 'Лист1'; -- Лист
  L_GROUP   constant PKG_STD.TSTRING := 'Line_Group'; -- Наименование бюджета
  L_PRJ1    constant PKG_STD.TSTRING := 'Line_PRJ1'; -- Наименование бюджета
  L_PRJ2    constant PKG_STD.TSTRING := 'Line_PRJ2'; -- Наименование раздела/Приход
  L_PRJ3    constant PKG_STD.TSTRING := 'Line_PRJ3'; -- Расход
  L_STAGE1  constant PKG_STD.TSTRING := 'Line_STAGE1'; -- Наименование подраздела
  L_STAGE2  constant PKG_STD.TSTRING := 'Line_STAGE2'; -- Строки...
  L_AGENT   constant PKG_STD.TSTRING := 'Line_AGENT'; -- Строки...
  L_GSUM    constant PKG_STD.TSTRING := 'Line_GROUP_SUM'; -- Итого по п.
  L_Itog    constant PKG_STD.TSTRING := 'Line_ITOG'; -- Итого по п.
  
--  L_lStrSum  constant PKG_STD.TSTRING := 'Vsego'; -- Всего по Разделу

  C_sHEARD_NAME      constant PKG_STD.TSTRING := 'sHEARD_NAME';
  C_SHD_GROUP_1      constant PKG_STD.TSTRING := 'SHD_GROUP_1';
  C_SHD_GROUP_2      constant PKG_STD.TSTRING := 'SHD_GROUP_2';
  C_SHD_GROUP_3      constant PKG_STD.TSTRING := 'SHD_GROUP_3';
  C_SHD_GROUP_4      constant PKG_STD.TSTRING := 'SHD_GROUP_4';
--L_GROUP
  C_sGROUP_NAME      constant PKG_STD.TSTRING := 'sGROUP_NAME';

--L_PRJ1
  C_sPRJ_RUK      constant PKG_STD.TSTRING := 'sPRJ_RUK';     
  C_sAGENT_NAME   constant PKG_STD.TSTRING := 'sAGENT_NAME';        
  C_sPRJ_CODE     constant PKG_STD.TSTRING := 'sPRJ_CODE';    
  C_sCOMMENT      constant PKG_STD.TSTRING := 'sCOMMENT';   
  C_sEconomist    constant PKG_STD.TSTRING := 'sEconomist';   
  C_sNDS          constant PKG_STD.TSTRING := 'sNDS';   
  C_PRJ_CODE      constant PKG_STD.TSTRING := 'PRJ_CODE';  
  C_npp           constant PKG_STD.TSTRING := 'nPP';  
   
     
  C_nSUM1_PLAN    constant PKG_STD.TSTRING := 'nSUM1_PLAN'; 
  C_nSUM1_FACT    constant PKG_STD.TSTRING := 'nSUM1_FACT';
  C_nSUM2_PLAN    constant PKG_STD.TSTRING := 'nSUM2_PLAN';
  C_nSUM2_FACT    constant PKG_STD.TSTRING := 'nSUM2_FACT';
  C_nSUM3_PLAN    constant PKG_STD.TSTRING := 'nSUM3_PLAN'; 
  C_nSUM3_FACT    constant PKG_STD.TSTRING := 'nSUM3_FACT';
  C_nSUM4_PLAN    constant PKG_STD.TSTRING := 'nSUM4_PLAN';
  C_nSUM4_FACT    constant PKG_STD.TSTRING := 'nSUM4_FACT';
  C_nSUM_PRJ_PLAN constant PKG_STD.TSTRING := 'nSUM_PRJ_PLAN';
  C_nSUM_PRJ_FACT constant PKG_STD.TSTRING := 'nSUM_PRJ_FACT';
  
 
--L_PRJ2
  C_sPRJ_NAME    constant PKG_STD.TSTRING := 'sPRJ_NAME';
  C_sPRJ_SHEFR   constant PKG_STD.TSTRING := 'sPRJ_SHEFR'; 

  C_nSUM1_PLAN_PIN    constant PKG_STD.TSTRING := 'nSUM1_PLAN_PIN'; 
  C_nSUM2_PLAN_PIN    constant PKG_STD.TSTRING := 'nSUM2_PLAN_PIN';
  C_nSUM3_PLAN_PIN    constant PKG_STD.TSTRING := 'nSUM3_PLAN_PIN'; 
  C_nSUM4_PLAN_PIN    constant PKG_STD.TSTRING := 'nSUM4_PLAN_PIN';
  C_nSUM1_FACT_PIN    constant PKG_STD.TSTRING := 'nSUM1_FACT_PIN';
  C_nSUM2_FACT_PIN    constant PKG_STD.TSTRING := 'nSUM2_FACT_PIN';
  C_nSUM3_FACT_PIN    constant PKG_STD.TSTRING := 'nSUM3_FACT_PIN';
  C_nSUM4_FACT_PIN    constant PKG_STD.TSTRING := 'nSUM4_FACT_PIN';
  C_nSUM_PRJ_PLAN_IN  constant PKG_STD.TSTRING := 'nSUM_PRJ_PLAN_IN';
  C_nSUM_PRJ_FACT_IN  constant PKG_STD.TSTRING := 'nSUM_PRJ_FACT_IN';

--L_PRJ3
  C_nSUM1_PLAN_POUT    constant PKG_STD.TSTRING := 'nSUM1_PLAN_POUT'; 
  C_nSUM2_PLAN_POUT    constant PKG_STD.TSTRING := 'nSUM2_PLAN_POUT';
  C_nSUM3_PLAN_POUT    constant PKG_STD.TSTRING := 'nSUM3_PLAN_POUT'; 
  C_nSUM4_PLAN_POUT    constant PKG_STD.TSTRING := 'nSUM4_PLAN_POUT';
  C_nSUM1_FACT_POUT    constant PKG_STD.TSTRING := 'nSUM1_FACT_POUT';
  C_nSUM2_FACT_POUT    constant PKG_STD.TSTRING := 'nSUM2_FACT_POUT';
  C_nSUM3_FACT_POUT    constant PKG_STD.TSTRING := 'nSUM3_FACT_POUT';
  C_nSUM4_FACT_POUT    constant PKG_STD.TSTRING := 'nSUM4_FACT_POUT';
  C_nSUM_PRJ_PLAN_OUT  constant PKG_STD.TSTRING := 'nSUM_PRJ_PLAN_OUT';
  C_nSUM_PRJ_FACT_OUT  constant PKG_STD.TSTRING := 'nSUM_PRJ_FACT_OUT';
   
--L_STAGE1
  C_sStage_NUMB     constant PKG_STD.TSTRING := 'sStage_NUMB';
  C_sStage_NAME     constant PKG_STD.TSTRING := 'sStage_NAME';
  C_sPAY_TYPE       constant PKG_STD.TSTRING := 'sPAY_TYPE';  
  C_PRJ_CODE_ST     constant PKG_STD.TSTRING := 'PRJ_CODE_ST';  


  C_nSUM1_ST_PLAN   constant PKG_STD.TSTRING := 'nSUM1_ST_PLAN';
  C_nSUM2_ST_PLAN   constant PKG_STD.TSTRING := 'nSUM2_ST_PLAN';
  C_nSUM3_ST_PLAN   constant PKG_STD.TSTRING := 'nSUM3_ST_PLAN';
  C_nSUM4_ST_PLAN   constant PKG_STD.TSTRING := 'nSUM4_ST_PLAN';
  C_nSUM1_ST_FACT   constant PKG_STD.TSTRING := 'nSUM1_ST_FACT';
  C_nSUM2_ST_FACT   constant PKG_STD.TSTRING := 'nSUM2_ST_FACT';
  C_nSUM3_ST_FACT   constant PKG_STD.TSTRING := 'nSUM3_ST_FACT';
  C_nSUM4_ST_FACT   constant PKG_STD.TSTRING := 'nSUM4_ST_FACT';

  C_nSUM_ST_PAY      constant PKG_STD.TSTRING := 'nSUM_ST_PAY';  
  C_nSUM_ST_PLAN     constant PKG_STD.TSTRING := 'nSUM_ST_PLAN';
  C_nSUM_ST_FACT     constant PKG_STD.TSTRING := 'nSUM_ST_FACT';
  
-- Line_AGENT 
  C_sEXEC_NAME      constant PKG_STD.TSTRING := 'sEXEC_NAME';
  C_sAGENT_PRIM     constant PKG_STD.TSTRING := 'sAGENT_PRIM';
  C_sAGN_PAY_TYPE   constant PKG_STD.TSTRING := 'sAGN_PAY_TYPE';

  C_nSUM1_AG_PLAN   constant PKG_STD.TSTRING := 'nSUM1_AG_PLAN';
  C_nSUM2_AG_PLAN   constant PKG_STD.TSTRING := 'nSUM2_AG_PLAN';
  C_nSUM3_AG_PLAN   constant PKG_STD.TSTRING := 'nSUM3_AG_PLAN';
  C_nSUM4_AG_PLAN   constant PKG_STD.TSTRING := 'nSUM4_AG_PLAN';
  C_nSUM1_AG_FACT   constant PKG_STD.TSTRING := 'nSUM1_AG_FACT';
  C_nSUM2_AG_FACT   constant PKG_STD.TSTRING := 'nSUM2_AG_FACT';
  C_nSUM3_AG_FACT   constant PKG_STD.TSTRING := 'nSUM3_AG_FACT';
  C_nSUM4_AG_FACT   constant PKG_STD.TSTRING := 'nSUM4_AG_FACT';
  
  C_nSUM_AG_PAY      constant PKG_STD.TSTRING := 'nSUM_AG_PAY';
  C_nSUM_AG_PLAN     constant PKG_STD.TSTRING := 'nSUM_AG_PLAN';
  C_nSUM_AG_FACT     constant PKG_STD.TSTRING := 'nSUM_AG_FACT';

--L_GSUM

  C_sITOG_GNAME     constant PKG_STD.TSTRING := 'sITOG_GROUP_NAME';
  C_sITOG_GSUM      constant PKG_STD.TSTRING := 'sITOG_SUM_NAME';
  
  C_nSUM1_GR_PLAN   constant PKG_STD.TSTRING := 'nSUM1_GR_PLAN';
  C_nSUM2_GR_PLAN   constant PKG_STD.TSTRING := 'nSUM2_GR_PLAN';
  C_nSUM3_GR_PLAN   constant PKG_STD.TSTRING := 'nSUM3_GR_PLAN';
  C_nSUM4_GR_PLAN   constant PKG_STD.TSTRING := 'nSUM4_GR_PLAN';
  C_nSUM1_GR_FACT   constant PKG_STD.TSTRING := 'nSUM1_GR_FACT';
  C_nSUM2_GR_FACT   constant PKG_STD.TSTRING := 'nSUM2_GR_FACT';
  C_nSUM3_GR_FACT   constant PKG_STD.TSTRING := 'nSUM3_GR_FACT';
  C_nSUM4_GR_FACT   constant PKG_STD.TSTRING := 'nSUM4_GR_FACT';

  C_nSUM_PGROUP    constant PKG_STD.TSTRING := 'nSUM_PGROUP';
  C_nSUM_FGROUP    constant PKG_STD.TSTRING := 'nSUM_FGROUP';
  
--L_ITOGI
  C_nItog1_P   constant PKG_STD.TSTRING := 'nItog1_P';
  C_nItog2_P   constant PKG_STD.TSTRING := 'nItog2_P';
  C_nItog3_P   constant PKG_STD.TSTRING := 'nItog3_P';
  C_nItog4_P   constant PKG_STD.TSTRING := 'nItog4_P';
  C_nItog1_F   constant PKG_STD.TSTRING := 'nItog1_F';
  C_nItog2_F   constant PKG_STD.TSTRING := 'nItog2_F';
  C_nItog3_F   constant PKG_STD.TSTRING := 'nItog3_F';
  C_nItog4_F   constant PKG_STD.TSTRING := 'nItog4_F';
  C_nItog      constant PKG_STD.TSTRING := 'nItog'; 
  C_nItog_P    constant PKG_STD.TSTRING := 'nItog_P';
  C_nItog_F    constant PKG_STD.TSTRING := 'nItog_F';

  C_nARAY      constant PKG_STD.tNUMBER := 64;



  sARTCL_TEMA      PKG_STD.tSTRING := 'Темат. доходы_Б'; 
  sARTCL_KA        PKG_STD.tSTRING := 'Расходы на КА_Б'; 
  sARTCL_PKI       PKG_STD.tSTRING := 'Расходы на ПКИ_Б'; 
  sARTCL_Proch     PKG_STD.tSTRING := 'Прочие тем.расходы_Б';
  sARTCL_Comers    PKG_STD.tSTRING := 'Коммерческие доходы';
  nARTCLRN_TEMA    PKG_STD.tREF;
  nARTCLRN_KA      PKG_STD.tREF;
  nARTCLRN_PKI     PKG_STD.tREF;
  nARTCLRN_Proch   PKG_STD.tREF;
  nARTCLRN_Comers  PKG_STD.tREF;
  nARTCLRN_Income  PKG_STD.tREF;
  nARTCL_CRN       PKG_STD.tREF;
  sDICIEARTS       PKG_STD.tSTRING;
  nPeriod          number(5) := 2023;
  nParam           number(2);
  nArticle         PKG_STD.tREF;
  sTMP             PKG_STD.TSTRING;

  
  nSTR_Cntr    PKG_STD.tREF := 1;
  nSTR_Cntr2   PKG_STD.tREF := 1;
  nSTR_Cntr3   PKG_STD.tREF := 1;
  nSTR_Staje   PKG_STD.tREF := 1;
  nSTR_AG      PKG_STD.tREF := 1;
  nSTR_GROUP_HED    PKG_STD.tREF := 1;
  nSTR_GROUP        PKG_STD.tREF := 1;
  nSTR_GROUP_in     PKG_STD.tREF := 1;
  nSTR_GROUP_in1    PKG_STD.tREF := 1;
  nSTR_GROUP_in2    PKG_STD.tREF := 1;
  nSTR_GROUP_in3    PKG_STD.tREF := 1;
  nSTR_GROUP_out    PKG_STD.tREF := 1;
  nSTR_GROUP_out1   PKG_STD.tREF := 1;
  nSTR_GROUP_out2   PKG_STD.tREF := 1;
  nSTR_GROUP_out3   PKG_STD.tREF := 1;
 


  nPrint       number(2) :=0;
  nEMPTY_GROUP number (2):=0;
  dRep_date    date;
  dStart_date  date;
  dEnd_date    date;
  nPRJ_RN      PKG_STD.tREF;
  sPRJ_Shefr   PKG_STD.tSTRING;
  sPrim        PKG_STD.tSTRING;
  nPP          PKG_STD.tREF := 1;

  sGROUP_in_name   PKG_STD.TSTRING;
  sGROUP_out_name  PKG_STD.TSTRING;
--  sACC_type        PKG_STD.TSTRING;
  nPAY_SUM_FACT    PKG_STD.tSUMM := 0;
  i                PKG_STD.tREF;
  
  
  nSUMM1_P PKG_STD.tSUMM := 0;
  nSUMM1_F PKG_STD.tSUMM := 0;
  nSUMM2_P PKG_STD.tSUMM := 0;
  nSUMM2_F PKG_STD.tSUMM := 0;
  nSUMM3_P PKG_STD.tSUMM := 0;
  nSUMM3_F PKG_STD.tSUMM := 0;
  nSUMM4_P PKG_STD.tSUMM := 0;
  nSUMM4_F PKG_STD.tSUMM := 0;
  
  nSUMM_P  PKG_STD.tSUMM := 0;
  nSUMM_F  PKG_STD.tSUMM := 0;
  
  
  nGROUP1_Pin  PKG_STD.tSUMM := 0;
  nGROUP2_Pin  PKG_STD.tSUMM := 0;
  nGROUP3_Pin  PKG_STD.tSUMM := 0;
  nGROUP4_Pin  PKG_STD.tSUMM := 0;

  nGROUP1_Pout  PKG_STD.tSUMM := 0;
  nGROUP2_Pout  PKG_STD.tSUMM := 0;
  nGROUP3_Pout  PKG_STD.tSUMM := 0;
  nGROUP4_Pout  PKG_STD.tSUMM := 0;
  
  nGROUP1_Fin  PKG_STD.tSUMM := 0;
  nGROUP2_Fin  PKG_STD.tSUMM := 0;
  nGROUP3_Fin  PKG_STD.tSUMM := 0;
  nGROUP4_Fin  PKG_STD.tSUMM := 0;
  
  nGROUP1_Fout  PKG_STD.tSUMM := 0;
  nGROUP2_Fout  PKG_STD.tSUMM := 0;
  nGROUP3_Fout  PKG_STD.tSUMM := 0;
  nGROUP4_Fout  PKG_STD.tSUMM := 0;

  nGROUP_all PKG_STD.tSUMM := 0;


  
  TYPE SUM_ARRAY IS TABLE OF number(17,2);
  
  ITOG_SUM    SUM_ARRAY ;
  SUM_Local   SUM_ARRAY ;
  GROUP_SUM   SUM_ARRAY ;
  


function CALC_Indx(nDirect in number, nGROUP in number, nPeriod in number, nFact in number) return number
  /*
  nIn      - 0 - Итоги приход, 1 - Итоги расход, 2 - локальные суммы приход, 3 - локальные суммы расход
  nGROUP   - 0 - всего по РС, 1 - Расчетный, 2 - Специальный, 3 УФК 
  nPeriod  - 1 - первый кв., 2 - второй кв. и т.д.
  nFact    - 0 - План, 1 - факт
  */
  as
  nRes PKG_STD.tREF;
  begin
    nRes :=  nPeriod + nFact * 4 + nGROUP * 8  + nDirect * 8* 4;
    return nRes; 
  end CALC_Indx;

procedure SET_SUM(nIn in number, nGROUP in number, nPeriod in number, nFact in number, nsum in number)
  /*
  nIn      - 0 - Итоги приход, 1 - Итоги расход, 2 - локальные суммы приход, 3 - локальные суммы расход
  nGROUP   - 0 - всего по РС, 1 - Расчетный, 2 - Специальный, 3 УФК 
  nPeriod  - 1 - первый кв., 2 - второй кв. и т.д.
  nFact    - 0 - План, 1 - факт
  */
  as
  nRN PKG_STD.tREF;
  begin
    nRN := CALC_Indx(nIn, nGROUP, nPeriod, nFact);
    begin
      ITOG_SUM(nRN) := nvl(ITOG_SUM(nRN),0) + NVL(nsum, 0);
    exception when others then
      P_exception(0,'err= '||nRN||' '||error_text);
    end;
    
  end SET_SUM;

procedure SET_SUML(nDirect in number, nGROUP in number, nPeriod in number, nFact in number, nsum in number)
  /*
  nIn      - 0 - Итоги приход, 1 - Итоги расход
  nGROUP   - 0 - всего по РС, 1 - Расчетный, 2 - Специальный, 3 - УФК 
  nPeriod  - 1 - первый кв., 2 - второй кв. и т.д.
  nFact    - 0 - План, 1 - факт
  */
  as
  nRN PKG_STD.tREF;
  begin
    nRN := CALC_Indx(nDirect, nGROUP, nPeriod, nFact);
    begin
      SUM_Local(nRN) := nvl( SUM_Local(nRN), 0) + NVL( nsum, 0);
    exception when others then
      P_exception(0,'err= '||nRN||' '||error_text);
    end;
    
  end SET_SUML;

procedure SET_SUMG(nIn in number, nGROUP in number, nPeriod in number, nFact in number, nsum in number)
  /*
  nIn      - 0 - приход, - расход
  nGROUP   - 0 - всего по РС, 1 - Расчетный, 2 - Специальный, 3 УФК 
  nPeriod  - 1 - первый кв., 2 - второй кв. и т.д.
  nFact    - 0 - План, 1 - факт
  */
  as
  nRN PKG_STD.tREF;
  begin
    nRN := CALC_Indx(nIn, nGROUP, nPeriod, nFact);
    begin
      GROUP_SUM(nRN) := nvl(GROUP_SUM(nRN),0) + NVL(nsum, 0);
    exception when others then
      P_exception(0,'err= '||nRN||' '||error_text);
    end;
    
  end SET_SUMG;

    
procedure GET_SUM(nIn in number, nGROUP in number, nPeriod in number, nFact in number, nRes out number) 
  as
  nRN PKG_STD.tREF;
 /* nRes PKG_STD.tSUMM;*/
  begin
    nRN := CALC_Indx(nIn, nGROUP, nPeriod, nFact);
    nRes := nvl(ITOG_SUM(nRN),0);
    
  end GET_SUM;  


procedure GET_SUMG(nIn in number, nGROUP in number, nPeriod in number, nFact in number, nRes out number) 
  as
  nRN PKG_STD.tREF;
 /* nRes PKG_STD.tSUMM;*/
  begin
    nRN := CALC_Indx(nIn, nGROUP, nPeriod, nFact);
    nRes := nvl(GROUP_SUM(nRN),0);
    
  end GET_SUMG;  

procedure CALC_MARK_SUM (
     nlFACE      in number
    ,nlCost_FACE in number
    ,nlARTCL     in number
    ,nlARTCL_CRN in number default 0 
    ,slDICIEARTS in varchar default '0'
    ,nlPeriod    in number
    ,nlPerQWARD in number default null  --null  период - год, иначе квартал и номер = № квартала
    ,nDirect     in number
    ,nStage_Oper in number
    ,nlSUMM1_P out PKG_STD.tSUMM  
    ,nlSUMM1_F out PKG_STD.tSUMM  
    ,nlSUMM2_P out PKG_STD.tSUMM  
    ,nlSUMM2_F out PKG_STD.tSUMM  
    ,nlSUMM3_P out PKG_STD.tSUMM  
    ,nlSUMM3_F out PKG_STD.tSUMM  
    ,nlSUMM4_P out PKG_STD.tSUMM  
    ,nlSUMM4_F out PKG_STD.tSUMM
    ,nlSUM_P   out PKG_STD.tSUMM
    ,nlSUM_F   out PKG_STD.tSUMM
    ,sPrim_art  out PKG_STD.tSTRING
  
  )
is

  nlSUMM    PKG_STD.tSUMM := 0;
  nLPAN_RN  PKG_STD.tREF; 
--  sPRIM     PKG_STD.tSTRING;
  nlSartMonth  PKG_STD.tREF; 
  nlEndMonth   PKG_STD.tREF; 
  nTYPE_OPER   PKG_STD.tREF;
  nPer_TYPE    PKG_STD.tREF;
  i            PKG_STD.tREF;
  nSign        PKG_STD.tNUMBER := 1;


begin
  nlSUMM1_P := 0;
  nlSUMM1_F := 0;
  nlSUMM2_P := 0;
  nlSUMM2_F := 0;
  nlSUMM3_P := 0;
  nlSUMM3_F := 0;
  nlSUMM4_P := 0;
  nlSUMM4_F := 0;  

  nlSUM_P := 0;
  nlSUM_F := 0;
  
  for i in 1 .. C_nARAY loop
    SUM_Local(i) := 0;
  end loop;  
  
  if nlPerQWARD is not null then
    nlSartMonth := ((nlPerQWARD-1) * 3) +1;
    nlEndMonth  :=   nlPerQWARD * 3;
  end if;
 
--  if nlFACE is not null then
  for fct in 0..1 loop
    if fct = 0 then 
      nLPAN_RN := 132176; -- plan
    else
      nLPAN_RN := 132177; --fact
    end if;
    /* Обход по переиодам */
    for clc in (
      select pr.STARTDATE
            ,pr.ENDDATE
            ,extract(month from pr.startdate) as nMON_numb
            ,pr.pertype
      from ENPERIOD  pr
      where (pr.pertype = 2 and nlPerQWARD is null or 
             pr.pertype = 0 and extract(month from pr.startdate) between nlSartMonth and nlEndMonth)  --квартал
        and extract(year from pr.startdate) = nlPeriod 
    ) loop
     --  nlSUMM := 0;
   
      for mrk in (
       select sum(pm.val)       as nlSUMM, 
              do.typoper_mnemo  as sTYPE_OPER
              ,pm.fpdartcl
              ,do.typoper_direct   --Направление средств операции  0 - приход, 1-расход
              ,fa.code
--         into nlSUMM, nACC_TYPE
         from UDO_T_MARK pm, DICTOPER do, FPDARTCL fa
        where (pm.cost_faceacc = nlCOST_FACE or nlCOST_FACE is null)
          and pm.finoper = do.rn (+) 
          and fa.rn (+) = pm.fpdartcl
          and (cmp_num(pm.faceacc, nlFACE) = 1 or 
          /* собирем все ЛС, кроме поименованных в соисполнителях */
                (nlFACE = 0 and 
                 (not (exists (select null 
                                 from PROJECTSTAGEPF apf 
                                where apf.faceacc = pm.faceacc) or 
                       exists (select null 
                                 from UDO_CO_EXECUTORS coex
                                where coex.faceacc = pm.faceacc))))  
                )
                           
          and ( pm.fpdartcl = nlARTCL or 
                exists ( select null from FPDARTCL fa, DICIEARTS da 
                          where fa.rn = pm.fpdartcl  and fa.crn  = nlARTCL_CRN 
                            and da.rn = fa.IEARTICLE and da.code = slDICIEARTS ) )
          and pm.finstate = nLPAN_RN  -- план
          and pm.mark_date between clc.STARTDATE and clc.ENDDATE
          group by do.typoper_mnemo, pm.fpdartcl, do.typoper_direct, fa.code
        ) loop  
 
           case mrk.sTYPE_OPER when 'Приход на ИГК' then nTYPE_OPER := 2;
                               when 'Расход с ИГК'  then nTYPE_OPER := 2;
                               when 'Приход КЗН'    then nTYPE_OPER := 3;
                               when 'Расходы КЗН'   then nTYPE_OPER := 3;
                               when 'Расход Собст'  then nTYPE_OPER := 1;
                               when 'Приход Собст'  then nTYPE_OPER := 1;
                               else nTYPE_OPER := nStage_Oper; 
           end case;
           nSign := 1;
           /* Доходы */
           if mrk.code = 'Темат. доходы_Б' then
             if mrk.typoper_direct = 1 then
               nSign := -1; 
             end if; 
           else
             /* Расходы */
             if mrk.typoper_direct = 0 then
               nSign := -1;
             end if;
           end if;   
       
           mrk.nlSUMM := NVL(mrk.nlSUMM, 0) * nSign;
         if clc.pertype = 2 then
           if fct = 0 then
             if clc.nMON_numb = 1 then
               nPer_TYPE := 1;
               nlSUMM1_P := nlSUMM1_P + mrk.nlSUMM;
             elsif clc.nMON_numb = 4 then
               nlSUMM2_P := nlSUMM2_P + mrk.nlSUMM;
               nPer_TYPE := 2;
             elsif clc.nMON_numb = 7 then
               nlSUMM3_P := nlSUMM3_P + mrk.nlSUMM;
               nPer_TYPE := 3;
             else 
               nlSUMM4_P := nlSUMM4_P + mrk.nlSUMM;
               nPer_TYPE := 4;
             end if;
             nlSUM_P := nlSUM_P + mrk.nlSUMM;
           else
             if clc.nMON_numb = 1 then
               nlSUMM1_F := nlSUMM1_F + mrk.nlSUMM;
               nPer_TYPE := 1;
             elsif clc.nMON_numb = 4 then
               nlSUMM2_F := nlSUMM2_F + mrk.nlSUMM;
               nPer_TYPE := 2;
             elsif clc.nMON_numb = 7 then
               nlSUMM3_F := nlSUMM3_F + mrk.nlSUMM;
               nPer_TYPE := 3;
             else 
               nlSUMM4_F := nlSUMM4_F + mrk.nlSUMM;
               nPer_TYPE := 4;
             end if;
             nlSUM_F := nlSUM_F + mrk.nlSUMM;   
           end if;
         else
          if fct = 0 then
             if clc.nMON_numb in (1, 4, 7, 10) then
               nlSUMM1_P := mrk.nlSUMM;
               nPer_TYPE := 1;
             elsif clc.nMON_numb in (2, 5, 8, 11) then
               nlSUMM2_P := mrk.nlSUMM;
               nPer_TYPE := 2;
             elsif clc.nMON_numb in (3, 6, 9, 12) then
               nlSUMM3_P := mrk.nlSUMM;
               nPer_TYPE := 3;
             else 
               nlSUMM4_P := 0;
               nPer_TYPE := 4;
             end if;
             nlSUM_P := nlSUM_P + mrk.nlSUMM;
           else
             if clc.nMON_numb in (1, 4, 7, 10) then
               nlSUMM1_F := mrk.nlSUMM;
               nPer_TYPE := 1;
             elsif clc.nMON_numb in (2, 5, 8, 11) then
               nlSUMM2_F := mrk.nlSUMM;
               nPer_TYPE := 2;
             elsif clc.nMON_numb in (3, 6, 9, 12) then
               nlSUMM3_F := mrk.nlSUMM;
               nPer_TYPE := 3;
             else 
               nlSUMM4_F := 0;
               nPer_TYPE := 4;
             end if;
             nlSUM_F := nlSUM_F + mrk.nlSUMM;   
           end if;         
         end if;
         /* суммы по типам счетов */
         SET_SUML(nDirect , nTYPE_OPER, nPer_TYPE, fct, mrk.nlSUMM);
         /* сумма общая */
         SET_SUML(nDirect , 0, nPer_TYPE, fct, mrk.nlSUMM);

      end loop; 
    end loop;
    
      
  end loop; 
  
  for prm in (
    select distinct pm.note
    from UDO_T_MARK pm, UDO_T_MARK_SRC src
    where extract(year from  pm.mark_date) = nlPeriod
      and (pm.cost_faceacc = nlFACE or pm.faceacc = nlFACE)
      and pm.fpdartcl in ( nlARTCL)
  --    and pm.finstate = nLPAN_RN
      and pm.finstate = 132176  -- Только по плановым показателям
      and src.prn (+) = pm.rn
      and src.src_doc_code <> 'PayNotes'  -- и документ основания не журнал платежей
    ) loop
      if sPrim_art is null then
        sPrim_art := prm.note;
      else
        sPrim_art := sPrim_art ||','||CR||prm.note;
      end if;   
  end loop;
--  sPrim_art := nvl(sPrim_art,''); 
  
  
--  end if;
end CALC_MARK_SUM;


procedure CALC_FACT_SUM (
     dlStart_DATE   in date
    ,nlFACEACC      in number
    ,nSUM           out PKG_STD.tSUMM
    ) 
is
begin 
  select sum(pn.pay_sum)
    into nSUM
    from PAYNOTES pn
   where pn.faceacc = nlFACEACC
     and pn.pay_date < dlStart_DATE
     and pn.SIGNPLAN = 0;  
  
end CALC_FACT_SUM;


procedure PRINT_GROUP(
  sMAIN_AG      in varchar,
  slPERSON      in varchar,
  dlStart_date  in date,
  dlEnd_date    in date,
  nlPrint       in number,
  slACC_type    in varchar
)
is
  nSUM1_P_in PKG_STD.tSUMM := 0;
  nSUM2_P_in PKG_STD.tSUMM := 0;
  nSUM3_P_in PKG_STD.tSUMM := 0;
  nSUM4_P_in PKG_STD.tSUMM := 0;
  nSUM1_F_in PKG_STD.tSUMM := 0;
  nSUM2_F_in PKG_STD.tSUMM := 0;
  nSUM3_F_in PKG_STD.tSUMM := 0;
  nSUM4_F_in PKG_STD.tSUMM := 0;
  
  nSUM1_P_out PKG_STD.tSUMM := 0;
  nSUM2_P_out PKG_STD.tSUMM := 0;
  nSUM3_P_out PKG_STD.tSUMM := 0;
  nSUM4_P_out PKG_STD.tSUMM := 0;
  nSUM1_F_out PKG_STD.tSUMM := 0;
  nSUM2_F_out PKG_STD.tSUMM := 0;
  nSUM3_F_out PKG_STD.tSUMM := 0;
  nSUM4_F_out PKG_STD.tSUMM := 0;
  
  sArticle  PKG_STD.TSTRING;
  nStage_Oper PKG_STD.tNUMBER;

begin

      
      for i in 1 .. C_nARAY loop
        GROUP_SUM(i):= 0;
      end loop;
      

      if nlPrint = 1 then    
        if  nEMPTY_GROUP = 0 then
          nSTR_GROUP_HED := PRSG_EXCEL.LINE_CONTINUE(L_GROUP);
        end if;
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sGROUP_NAME, 0, nSTR_GROUP_HED,  'Группа: '||sMAIN_AG);
      end if;
            
  
      For cntr in (select distinct  pr.*
                     from 
                     /* По договорам */
           (select cnr.rn                           as nCN_RN
                  ,null                             as nPRJ_RN
                  ,cnr.subject                      as sCN_SUBJECT
                  ,trim(cnr.doc_pref)||'-'||trim(cnr.doc_numb) as sCN_NUMB
                  ,F_DOCS_PROPS_GET_STR_VALUE (
                            nPROPERTY     => 7359003,              -- Заместитель ГД
                            sUNITCODE     => 'Contracts',
                            nDOCUMENT     => cnr.RN ) as sMain_Ruk
                  ,AG.AGNNAME                         as sAGENT_NAME
                  ,F_DOCS_PROPS_GET_STR_VALUE (
                            nPROPERTY     => 1076177,              -- Шифр по БУ
                            sUNITCODE     => 'Contracts',
                            nDOCUMENT     => cnr.RN ) as sCONTR_Shefr
                  ,F_DOCS_PROPS_GET_STR_VALUE (
                            nPROPERTY     => 6454955,              -- Заказчик работ
                            sUNITCODE     => 'Contracts',
                            nDOCUMENT     => cnr.RN ) as sMain_Customer
                  ,btyp.code                          as sBank_Type
                  ,UDO_F_PRJCONT_DOCPROP(SPROP => 'Сотрудник',
                                         nRN   => cnr.rn)  as sEconomist
                  ,UDO_F_GET_CONT_ACATALOG(cnr.CRN)  as nCNTR_CRN
              from CONTRACTS      cnr
                  ,AGNLIST        ag
                  ,AGNACC         acc
                  ,BANKACCTYPES   btyp
                  
             where ag.rn = cnr.agent
               and acc.rn (+) = cnr.jur_acc
               and btyp.rn (+) = acc.bankacc_type
               and (F_DOCS_PROPS_GET_STR_VALUE (
                            nPROPERTY     => 6454955,              -- Заказчик работ
                            sUNITCODE     => 'Contracts',
                            nDOCUMENT     => cnr.RN ) = sMAIN_AG or 
                    F_DOCS_PROPS_GET_STR_VALUE (
                            nPROPERTY     => 6454955,              -- Заказчик работ
                            sUNITCODE     => 'Contracts',
                            nDOCUMENT     => cnr.RN ) is null and sMAIN_AG = 'Заказчик не указан' or sMAIN_AG = 'ВСЁ')
--               and (slACC_type = btyp.code or btyp.code = '0')             
               and exists(select null from STAGES st, FACEACC fc where st.prn = cnr.rn and st.faceacc = fc.rn and fc.acc_kind =1 )
               
               and (exists (select null 
                             from UDO_T_MARK pm, STAGES st 
                            where st.prn = cnr.rn
                              and pm.faceacc = st.faceacc
                              and pm.fpdartcl in (nARTCLRN_TEMA)
                              and pm.val <> 0
                              and pm.mark_date between dlStart_date and dlEnd_DATE
                       --       and pm.RN = 42797312
                                          
                              )
                     or exists (select null 
                                from UDO_T_MARK pm, STAGES st, PROJECTSTAGE   ps 
                            where st.prn = cnr.rn
                              and ps.faceacccust (+)  = st.faceacc
                              and pm.cost_faceacc = nvl(ps.faceacc, UDO_F_STAGES_GET_FACE_PROP(st.RN))
                              and pm.val <> 0
                              and pm.mark_date between dlStart_date and dlEnd_DATE
                              and pm.fpdartcl in ( nARTCLRN_KA, nARTCLRN_PKI, nARTCLRN_Proch) 
                       --       and pm.RN = 42797312
                                ))
                  and (UDO_F_PRJCONT_DOCPROP(SPROP => 'Сотрудник',
                                             nRN   => cnr.rn) = slPERSON or slPERSON is null)  
                            
               union  
               /* по проектам */                 
            select null                             as nCN_RN
                  ,prj.rn                           as nPRJ_RN
                  ,prj.expected_res                 as sCN_SUBJECT
                  ,null                             as sCN_NUMB
                  ,null                             as sMain_Ruk
                  ,AG.AGNNAME                       as sAGENT_NAME
                  ,null                             as sCONTR_Shefr
                  ,nvl(F_DOCS_PROPS_GET_STR_VALUE (
                            nPROPERTY     => 6454955,              -- Заказчик работ
                            sUNITCODE     => 'Projects',
                            nDOCUMENT     => prj.RN ), 'Инициативные') as sMain_Customer                    
                  ,'Расчетный'                      as sBank_Type
                  ,UDO_F_PRJCONT_DOCPROP(SPROP => 'Сотрудник',
                                          nRN   => prj.rn) as sEconomist
                  ,3 as  nCNTR_CRN
              from PROJECT        prj
                  ,AGNLIST        ag
             where ag.rn = prj.ext_cust
               and prj.rn not in (56843983, 6991954, 6991743)

               and not exists (select null from PROJECTSTAGE prjs where prjs.prn = prj.rn and prjs.faceacccust is not null)
               and     exists (select null 
                                 from UDO_T_MARK pm, PROJECTSTAGE   ps 
                                where ps.prn  = prj.rn
                                  and pm.cost_faceacc = ps.faceacc
                                  and pm.val <> 0
                                  and pm.mark_date between dlStart_date and dlEnd_DATE
                                  and pm.fpdartcl in (nARTCLRN_KA, nARTCLRN_PKI, nARTCLRN_Proch, nARTCLRN_TEMA) 
                       --      and pm.RN = 42797312
                                )  
               and (nvl(F_DOCS_PROPS_GET_STR_VALUE (
                            nPROPERTY     => 6454955,              -- Заказчик работ
                            sUNITCODE     => 'Projects',
                            nDOCUMENT     => prj.RN ), 'Инициативные') = sMAIN_AG or sMAIN_AG = 'ВСЁ')
               and (UDO_F_PRJCONT_DOCPROP(SPROP => 'Сотрудник',
                                             nRN   => prj.rn) = slPERSON or slPERSON is null)                                                        
         ) pr
         order by  pr.nCNTR_CRN, pr.sMain_Ruk

       
       ) loop

         cntr.smain_customer := nvl(cntr.smain_customer,' -- ');
         
         if sMAIN_AG  = 'Маркетинг' then 
           nARTCLRN_Income := nARTCLRN_Comers;
           nARTCL_CRN := 6252594; -- каталог III_Коммерческие 
           sDICIEARTS := 'Приход';
         else 
           nARTCLRN_Income := nARTCLRN_TEMA;
           nARTCL_CRN := 0;
         end if;
           
         
       /*  if sOldGROUP <> cntr.smain_customer \*or sOldGROUP is null*\ then        
            nEMPTY_GROUP := 1;
            sOldGROUP := cntr.smain_customer;
            P_SELECTLIST_CLEAR(nIDENT_GROUP);
           
         end if; */
       
         if cntr.ncn_rn is not null then
           begin
             select distinct ps.prn
               into cntr.nPRJ_RN
                  from STAGES st, PROJECTSTAGE   ps 
                  where ps.faceacccust = st.faceacc
                    and st.prn = cntr.ncn_rn;
           exception when others then
             cntr.nPRJ_RN:= null;
           end;
         end if;
         
         sPRJ_Shefr := F_DOCS_PROPS_GET_STR_VALUE (
                        nPROPERTY     => 1076177,              -- Шифр по БУ
                        sUNITCODE     => 'Projects',
                        nDOCUMENT     => cntr.nPRJ_RN);


          
          nSUM1_P_in := 0;
          nSUM2_P_in := 0;
          nSUM3_P_in := 0;
          nSUM4_P_in := 0;
          nSUM1_F_in := 0;
          nSUM2_F_in := 0;
          nSUM3_F_in := 0;
          nSUM4_F_in := 0;

          nSUM1_P_out := 0;
          nSUM2_P_out := 0;
          nSUM3_P_out := 0;
          nSUM4_P_out := 0;
          nSUM1_F_out := 0;
          nSUM2_F_out := 0;
          nSUM3_F_out := 0;
          nSUM4_F_out := 0;

          if nlPrint = 1 then  
            nSTR_Cntr := PRSG_EXCEL.LINE_CONTINUE(L_PRJ1);

            PRSG_EXCEL.CELL_VALUE_WRITE(C_sPRJ_RUK,    0, nSTR_Cntr, nvl(UDO_F_PROJECT_Get_AGENT(cntr.nPRJ_RN, 1, dRep_date), cntr.sMain_Ruk));
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT_NAME, 0, nSTR_Cntr, cntr.sAGENT_NAME);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sEconomist,  0, nSTR_Cntr, cntr.sEconomist);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_npp,         0, nSTR_Cntr, nPP);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_PRJ_CODE,    0, nSTR_Cntr, cntr.sCN_NUMB);
            nPP := nPP +1;

           

            nSTR_Cntr2 := PRSG_EXCEL.LINE_CONTINUE(L_PRJ2);
            nSTR_Cntr3 := PRSG_EXCEL.LINE_CONTINUE(L_PRJ3);
        --    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPRJ_SHEFR,   0, nSTR_Cntr2, '('||UDO_F_FACEACC_GET_SHEFR(cntr.nst_faceacc)||')');
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sPRJ_NAME,    0, nSTR_Cntr2, cntr.sCN_SUBJECT);
          end if;

          for stg in (
            select * from (
            /*По этапам договора*/
            select ps.prn         as nPRJ_RN
                  ,st.PRN         as nST_PNR
                  ,st.rn          as nST_RN
                  ,st.Faceacc     as nST_FACEACC
                  ,st.numb        as sST_NUMB
                  ,st.description as sST_Descr
                  ,ps.rn          as nPRST_RN
                  ,ps.faceacc     as nPS_FACEACC
                  ,fc.numb        as sFC_NUMB
                  ,btyp.code      as sBType
             from STAGES st, FACEACC fc, PROJECTSTAGE   ps
                 ,AGNACC         acc
                 ,BANKACCTYPES   btyp
            where ps.faceacccust (+) = st.faceacc
              and st.prn = cntr.nCN_RN 
              and fc.agnacc = acc.rn (+)
              and btyp.rn (+) = acc.bankacc_type
              and cntr.nCN_RN is not null
              and fc.rn (+) = ps.faceacc
           --   and st.status in (1, 3) --- открыт или  согласован 
-- and st.rn = 79828241          
              and (exists (select null 
                         from UDO_T_MARK pm 
                        where pm.faceacc = st.faceacc
                          and pm.val <> 0
                          and pm.fpdartcl  in (nARTCLRN_Income)
                          and pm.mark_date between dStart_date and dEnd_DATE
             --             and pm.RN = 42797312
                          )
                     or exists (select null 
                            from UDO_T_MARK pm
                        where pm.cost_faceacc = nvl(ps.faceacc, UDO_F_STAGES_GET_FACE_PROP(st.rn))
                          and pm.val <> 0
                          and pm.fpdartcl in ( nARTCLRN_KA, nARTCLRN_PKI, nARTCLRN_Proch)
                          and pm.mark_date between dStart_date and dEnd_DATE
              --            and pm.RN = 42797312
                            ))
          union 
          /* по этапам проекта, если нет связи с договором */
            select ps.prn         as nPRJ_RN
                  ,null           as nST_PNR
                  ,null           as nST_RN
                  ,0              as nST_FACEACC
                  ,ps.numb        as sST_NUMB
                  ,ps.name        as sST_Descr
                  ,ps.rn          as nPRST_RN
                  ,ps.faceacc     as nPS_FACEACC
                  ,fc.numb        as sFC_NUMB
                  ,null           as sBType
             from PROJECTSTAGE   ps, FACEACC fc 
            where (cntr.nCN_RN is null or exists (select null from STAGES st, PROJECTSTAGE pp --для случая субсидий, договор на часть этапов проекта
                                                   where pp.faceacccust = st.faceacc 
                                                     and st.prn = cntr.nCN_RN 
                                                     and pp.prn = ps.prn))
              and ps.prn = cntr.nPRJ_RN
              and fc.rn = ps.faceacc
              and ps.faceacccust is null

              and exists (select null 
                            from UDO_T_MARK pm
                        where pm.cost_faceacc = ps.faceacc
                          and pm.val <> 0
                           and pm.fpdartcl in (nARTCLRN_Income, nARTCLRN_KA, nARTCLRN_PKI, nARTCLRN_Proch, nARTCLRN_TEMA)
                          and pm.mark_date between dStart_date and dEnd_DATE

                            ) 
              )  ttt                    
              order by ttt.sST_NUMB
          ) loop

            if nlPrint = 1 then
              PRSG_EXCEL.CELL_VALUE_WRITE(C_sPRJ_CODE ,   0, nSTR_Cntr,  nvl(UDO_F_FACEACC_GET_SHEFR(stg.nST_FACEACC), UDO_F_FACEACC_GET_SHEFR(stg.nPS_FACEACC)) );
              PRSG_EXCEL.CELL_VALUE_WRITE(C_sPRJ_SHEFR,   0, nSTR_Cntr2, '('|| nvl(cntr.sCONTR_Shefr, sPRJ_Shefr)||')'||'['||cntr.scn_numb||']');
            
              nSTR_Staje := PRSG_EXCEL.LINE_CONTINUE(L_STAGE1);

              PRSG_EXCEL.CELL_VALUE_WRITE(C_sStage_NUMB, 0, nSTR_Staje, /*stg.sFC_NUMB||' / '||*/'Этап №'||Trim(stg.sST_NUMB));
              PRSG_EXCEL.CELL_VALUE_WRITE(C_sStage_NAME, 0, nSTR_Staje, stg.sST_Descr);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_sPAY_TYPE,   0, nSTR_Staje, cntr.sbank_type);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_PRJ_CODE_ST, 0, nSTR_Staje, stg.sFC_NUMB);

              
            end if; 
            
            case stg.sBType when 'Расчетный'   then nStage_Oper := 1;
                            when 'Специальный' then nStage_Oper := 2;
                            when 'УФК'         then nStage_Oper := 3;
                                               else nStage_Oper := 1;
            end case;           
            /* Для случая серийной поставки */
            stg.nPS_FACEACC := nvl(stg.nPS_FACEACC, UDO_F_STAGES_GET_FACE_PROP(stg.nST_RN));
            
            /* Суммы поступления по этапу */
            CALC_MARK_SUM (
               nlFACE      => stg.nST_FACEACC
              ,nlCost_FACE => stg.nPS_FACEACC 
              ,nlARTCL     => nARTCLRN_Income 
              ,nlARTCL_CRN => nARTCL_CRN
              ,slDICIEARTS => sDICIEARTS
              ,nlPeriod    => nPeriod
              ,nDirect     => 0  -- Приход 
              ,nStage_Oper => nStage_Oper
              ,nlPerQWARD  => nPerQWARD
              ,nlSUMM1_P   => nSUMM1_P  
              ,nlSUMM1_F   => nSUMM1_F
              ,nlSUMM2_P   => nSUMM2_P 
              ,nlSUMM2_F   => nSUMM2_F 
              ,nlSUMM3_P   => nSUMM3_P 
              ,nlSUMM3_F   => nSUMM3_F
              ,nlSUMM4_P   => nSUMM4_P
              ,nlSUMM4_F   => nSUMM4_F
              ,nlSUM_P     => nSUMM_P
              ,nlSUM_F     => nSUMM_F
              ,sPrim_art   => sPrim
            );
            
            for i in 1 .. C_nARAY loop
              GROUP_SUM(i) := GROUP_SUM(i) + SUM_Local(i);
            end loop;
            
            CALC_FACT_SUM (
                   dlStart_DATE   => dStart_date
                  ,nlFACEACC      => stg.nST_FACEACC
                  ,nSUM           => nPAY_SUM_FACT
                  );
            
            if nlPrint = 1 then
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_ST_PLAN, 0, nSTR_Staje, nSUMM1_P);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_ST_PLAN, 0, nSTR_Staje, nSUMM2_P);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_ST_PLAN, 0, nSTR_Staje, nSUMM3_P);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_ST_PLAN, 0, nSTR_Staje, nSUMM4_P);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_ST_FACT, 0, nSTR_Staje, nSUMM1_F);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_ST_FACT, 0, nSTR_Staje, nSUMM2_F);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_ST_FACT, 0, nSTR_Staje, nSUMM3_F);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_ST_FACT, 0, nSTR_Staje, nSUMM4_F);

              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_ST_PLAN,   0, nSTR_Staje, nSUMM_P);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_ST_FACT,   0, nSTR_Staje, nSUMM_F);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_ST_PAY,    0, nSTR_Staje, nPAY_SUM_FACT);
              nPrint := 1;
            end if;
            
            cntr.sBank_Type := nvl(cntr.sBank_Type, 'Расчетный');
                
                                 
         --   if slACC_type = cntr.sBank_Type or slACC_type = '0' then
            nSUM1_P_in := nSUM1_P_in + NVL(nSUMM1_P, 0);
            nSUM2_P_in := nSUM2_P_in + NVL(nSUMM2_P, 0);
            nSUM3_P_in := nSUM3_P_in + NVL(nSUMM3_P, 0);
            nSUM4_P_in := nSUM4_P_in + NVL(nSUMM4_P, 0);
            nSUM1_F_in := nSUM1_F_in + NVL(nSUMM1_F, 0);
            nSUM2_F_in := nSUM2_F_in + NVL(nSUMM2_F, 0);
            nSUM3_F_in := nSUM3_F_in + NVL(nSUMM3_F, 0);
            nSUM4_F_in := nSUM4_F_in + NVL(nSUMM4_F, 0);
        --    end if;


            for nParam in 1..3 loop  
             nArticle :=  case nParam when 1 then nARTCLRN_KA
                                      when 2 then nARTCLRN_Proch
                                      when 3 then nARTCLRN_PKI end;      
             sArticle :=  case nParam when 1 then ' (ст. Контр.)'
                                      when 2 then ' (ст. Прочие)'
                                      when 3 then ' (ст. ПКИ)' end;      
        
            /*обход договоров с КА*/
             for agn in (
               select ag.agnname as sAG_NAME
                     ,btp.code   as sAG_BANK_TYPE
                     ,ast.description as sAG_DESCR
                     ,ast.faceacc     as AGN_FACE
                     ,trim(acn.doc_pref)||'-'||trim(acn.doc_numb)||' от '||to_char(acn.doc_date,'dd.mm.yyyy') as sCont_NUMB
                     ,' Эт.'||trim(ast.numb)        as sStage_numb
               from CONTRACTS acn
                  , STAGES    ast
                  , AGNLIST   ag
                  , AGNACC    acc
                  , BANKACCTYPES   btp
               where acn.rn = ast.prn
                 and ( exists (select null from PROJECTSTAGEPF apf where apf.faceacc = ast.faceacc) or 
                       exists (select null from UDO_CO_EXECUTORS coex where coex.faceacc = ast.faceacc)
                     )  
              --   and ast.status in (1, 3) --- открыт или  согласован 
                 and ast.faceacc in (select pm.faceacc 
                                     from UDO_T_MARK pm
                                    where pm.cost_faceacc =  stg.nPS_FACEACC
                                      and pm.fpdartcl = nArticle
                                      and (pm.faceacc <> stg.nST_FACEACC or stg.nST_FACEACC is null)
                                      and pm.val <> 0
                                      and pm.mark_date between dStart_date and dEnd_DATE)
                 and ag.rn = acn.agent
                 and acc.rn (+) = acn.agnacc
                 and btp.rn (+) = acc.bankacc_type
               --  and (slACC_type = nvl(btp.code, 'Расчетный') or slACC_type = '0')             
                   
                 
             ) loop
         /*       if nPrint = 1 then
            --      nSTR_AG := PRSG_EXCEL.LINE_CONTINUE(L_STAGE2);
                  nPrint := 0;
                end if;*/
               
                if nlPrint = 1 then
                  nSTR_AG := PRSG_EXCEL.LINE_CONTINUE(L_AGENT);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_sEXEC_NAME,     0, nSTR_AG, agn.sAG_NAME ||sArticle);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGN_PAY_TYPE,  0, nSTR_AG, agn.sAG_BANK_TYPE);
                end if;
                
                CALC_MARK_SUM (
                   nlFACE      => agn.AGN_FACE
                  ,nlCost_FACE => stg.nPS_FACEACC
                  ,nlARTCL     => nArticle
                  ,nlPeriod    => nPeriod
                  ,ndirect     => 1
                  ,nStage_Oper => nStage_Oper
                  ,nlPerQWARD  => nPerQWARD
                  ,nlSUMM1_P   => nSUMM1_P  
                  ,nlSUMM1_F   => nSUMM1_F
                  ,nlSUMM2_P   => nSUMM2_P 
                  ,nlSUMM2_F   => nSUMM2_F 
                  ,nlSUMM3_P   => nSUMM3_P 
                  ,nlSUMM3_F   => nSUMM3_F
                  ,nlSUMM4_P   => nSUMM4_P
                  ,nlSUMM4_F   => nSUMM4_F
                  ,nlSUM_P     => nSUMM_P
                  ,nlSUM_F     => nSUMM_F
                  ,sPrim_art   => sPrim
                );
                    
                for i in 1 .. C_nARAY loop
                  GROUP_SUM(i) := GROUP_SUM(i) + SUM_Local(i);
                end loop;

                CALC_FACT_SUM (
                   dlStart_DATE   => dStart_date
                  ,nlFACEACC      => agn.AGN_FACE
                  ,nSUM           => nPAY_SUM_FACT
                  );


 --if nArticle = 6172154 then 
--   P_exception(0,'print st= '||stg.nST_FACEACC|| ' ps= ' ||stg.nPS_FACEACC||' nSUMM_F='||nSUMM_F); 
 --  end if;
 
                agn.sCont_NUMB := agn.sCont_NUMB ||agn.sStage_numb;
                if sPrim is not null then
                  agn.sCont_NUMB := agn.sCont_NUMB ||' - '|| sPrim;
                end if;
                  
                if nlPrint = 1 then
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT_PRIM,    0, nSTR_AG, nvl(agn.sAG_DESCR, agn.sCont_NUMB)); 
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_AG_PLAN,  0, nSTR_AG, nSUMM1_P);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_AG_PLAN,  0, nSTR_AG, nSUMM2_P);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_AG_PLAN,  0, nSTR_AG, nSUMM3_P);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_AG_PLAN,  0, nSTR_AG, nSUMM4_P);
                  
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_AG_FACT,  0, nSTR_AG, nSUMM1_F);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_AG_FACT,  0, nSTR_AG, nSUMM2_F);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_AG_FACT,  0, nSTR_AG, nSUMM3_F);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_AG_FACT,  0, nSTR_AG, nSUMM4_F);

                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_AG_PLAN,  0, nSTR_AG, nSUMM_P);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_AG_FACT,  0, nSTR_AG, nSUMM_F);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_AG_PAY,   0, nSTR_AG, nPAY_SUM_FACT);
                end if;

                nSUM1_P_out := nSUM1_P_out + NVL(nSUMM1_P, 0);
                nSUM2_P_out := nSUM2_P_out + NVL(nSUMM2_P, 0);
                nSUM3_P_out := nSUM3_P_out + NVL(nSUMM3_P, 0);
                nSUM4_P_out := nSUM4_P_out + NVL(nSUMM4_P, 0);
                nSUM1_F_out := nSUM1_F_out + NVL(nSUMM1_F, 0);
                nSUM2_F_out := nSUM2_F_out + NVL(nSUMM2_F, 0);
                nSUM3_F_out := nSUM3_F_out + NVL(nSUMM3_F, 0);
                nSUM4_F_out := nSUM4_F_out + NVL(nSUMM4_F, 0);      
             end loop;
           end loop;
   

              /*обход только показателей */   
           for nParam in 1..3 loop  
                                       
              if nParam = 1 then
                sTMP :=  'Соисполнители';
                nArticle := nARTCLRN_KA;               
              elsif nParam = 2 then
                sTMP :=  'Статья Прочие ';
                nArticle := nARTCLRN_Proch;
              else
                sTMP := 'Статья ПКИ';
                nArticle := nARTCLRN_PKI;
              end if;  
                                          
             for pki in (
               select sum(pm.val) as sum_tmp
                 from UDO_T_MARK pm
                where pm.cost_faceacc = stg.nPS_FACEACC
                  and (pm.faceacc is null or 
                       not (exists (select null from PROJECTSTAGEPF apf where apf.faceacc = pm.faceacc) or
                            exists (select null from UDO_CO_EXECUTORS coex where coex.faceacc = pm.faceacc ))
                      ) 
                  and pm.fpdartcl in nArticle
                  and pm.val <> 0
                  and pm.mark_date between dStart_date and dEnd_DATE
                  and (slACC_type = '0' or slACC_type =  cntr.sBank_Type)
             ) loop
               if pki.sum_tmp >0 then
             

                  if nlPrint = 1 then
                    nSTR_AG := PRSG_EXCEL.LINE_CONTINUE(L_AGENT);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_sEXEC_NAME,     0, nSTR_AG, sTMP);
                  end if;
                  
                  CALC_MARK_SUM (
                     nlFACE   => 0
                    ,nlCost_FACE => stg.nPS_FACEACC
                    ,nlARTCL  => nArticle
                    ,nlPeriod => nPeriod
                    ,ndirect  => 1
                    ,nStage_Oper => nStage_Oper
                    ,nlPerQWARD => nPerQWARD
                    ,nlSUMM1_P => nSUMM1_P  
                    ,nlSUMM1_F => nSUMM1_F
                    ,nlSUMM2_P => nSUMM2_P 
                    ,nlSUMM2_F => nSUMM2_F 
                    ,nlSUMM3_P => nSUMM3_P 
                    ,nlSUMM3_F => nSUMM3_F
                    ,nlSUMM4_P => nSUMM4_P
                    ,nlSUMM4_F => nSUMM4_F
                    ,nlSUM_P   => nSUMM_P
                    ,nlSUM_F   => nSUMM_F
                    ,sPrim_art  => sPrim
                  );

                  for i in 1 .. C_nARAY loop
                    GROUP_SUM(i) := GROUP_SUM(i) + SUM_Local(i);
                  end loop;

                  if nlPrint = 1 then
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT_PRIM,    0, nSTR_AG, sPrim); 
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_AG_PLAN,  0, nSTR_AG, nSUMM1_P);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_AG_PLAN,  0, nSTR_AG, nSUMM2_P);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_AG_PLAN,  0, nSTR_AG, nSUMM3_P);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_AG_PLAN,  0, nSTR_AG, nSUMM4_P);
                    
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_AG_FACT,  0, nSTR_AG, nSUMM1_F);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_AG_FACT,  0, nSTR_AG, nSUMM2_F);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_AG_FACT,  0, nSTR_AG, nSUMM3_F);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_AG_FACT,  0, nSTR_AG, nSUMM4_F);


                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_AG_PLAN,    0, nSTR_AG, nSUMM_P);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_AG_FACT,    0, nSTR_AG, nSUMM_F);
                  end if;
                 
                  
                  nSUM1_P_out := nSUM1_P_out + NVL(nSUMM1_P, 0);
                  nSUM2_P_out := nSUM2_P_out + NVL(nSUMM2_P, 0);
                  nSUM3_P_out := nSUM3_P_out + NVL(nSUMM3_P, 0);
                  nSUM4_P_out := nSUM4_P_out + NVL(nSUMM4_P, 0);
                  nSUM1_F_out := nSUM1_F_out + NVL(nSUMM1_F, 0);
                  nSUM2_F_out := nSUM2_F_out + NVL(nSUMM2_F, 0);
                  nSUM3_F_out := nSUM3_F_out + NVL(nSUMM3_F, 0);
                  nSUM4_F_out := nSUM4_F_out + NVL(nSUMM4_F, 0);      

                end if;
             end loop;
            end loop;  
            
            
         end loop;  --STG.
     
          
         
          if nlPrint = 1 then
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_PLAN_PIN,  0, nSTR_Cntr2, nSUM1_P_in);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_PLAN_PIN,  0, nSTR_Cntr2, nSUM2_P_in);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_PLAN_PIN,  0, nSTR_Cntr2, nSUM3_P_in);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_PLAN_PIN,  0, nSTR_Cntr2, nSUM4_P_in);
              
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_FACT_PIN,  0, nSTR_Cntr2, nSUM1_F_in);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_FACT_PIN,  0, nSTR_Cntr2, nSUM2_F_in);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_FACT_PIN,  0, nSTR_Cntr2, nSUM3_F_in);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_FACT_PIN,  0, nSTR_Cntr2, nSUM4_F_in);
              
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PRJ_PLAN_IN,  0, nSTR_Cntr2, nSUM1_P_in + nSUM2_P_in + nSUM3_P_in + nSUM4_P_in);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PRJ_FACT_IN,  0, nSTR_Cntr2, nSUM1_F_in + nSUM2_F_in + nSUM3_F_in + nSUM4_F_in);           

            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_PLAN_POUT,  0, nSTR_Cntr3, nSUM1_P_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_PLAN_POUT,  0, nSTR_Cntr3, nSUM2_P_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_PLAN_POUT,  0, nSTR_Cntr3, nSUM3_P_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_PLAN_POUT,  0, nSTR_Cntr3, nSUM4_P_out);
              
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_FACT_POUT,  0, nSTR_Cntr3, nSUM1_F_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_FACT_POUT,  0, nSTR_Cntr3, nSUM2_F_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_FACT_POUT,  0, nSTR_Cntr3, nSUM3_F_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_FACT_POUT,  0, nSTR_Cntr3, nSUM4_F_out);   
                     
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PRJ_PLAN_OUT,  0, nSTR_Cntr3, nSUM1_P_out + nSUM2_P_out + nSUM3_P_out + nSUM4_P_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PRJ_FACT_OUT,  0, nSTR_Cntr3, nSUM1_F_out + nSUM2_F_out + nSUM3_F_out + nSUM4_F_out);           

            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_PLAN,  0, nSTR_Cntr, nSUM1_P_in - nSUM1_P_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_PLAN,  0, nSTR_Cntr, nSUM2_P_in - nSUM2_P_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_PLAN,  0, nSTR_Cntr, nSUM3_P_in - nSUM3_P_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_PLAN,  0, nSTR_Cntr, nSUM4_P_in - nSUM4_P_out);
            
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_FACT,  0, nSTR_Cntr, nSUM1_F_in - nSUM1_F_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_FACT,  0, nSTR_Cntr, nSUM2_F_in - nSUM2_F_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_FACT,  0, nSTR_Cntr, nSUM3_F_in - nSUM3_F_out);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_FACT,  0, nSTR_Cntr, nSUM4_F_in - nSUM4_F_out);

            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PRJ_PLAN, 0, nSTR_Cntr, nSUM1_P_in + nSUM2_P_in + nSUM3_P_in + nSUM4_P_in - (nSUM1_P_out + nSUM2_P_out + nSUM3_P_out + nSUM4_P_out));
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PRJ_FACT, 0, nSTR_Cntr, nSUM1_F_in + nSUM2_F_in + nSUM3_F_in + nSUM4_F_in - (nSUM1_F_out + nSUM2_F_out + nSUM3_F_out + nSUM4_F_out));

         end if; 
        
       end loop; --cntr



end PRINT_GROUP;
  
begin
  
  select 0
   bulk collect into ITOG_SUM
  from ENPERIOD;
  
  select 0
   bulk collect into SUM_Local
  from ENPERIOD;

  select 0
   bulk collect into GROUP_SUM
  from ENPERIOD;

 -- where rownum <100;
 
 /* select 0
   bulk collect into SUM_TOTL
  from ENPERIOD;*/
  
 
  
  FIND_FPDARTCL_CODE(nFLAG_SMART  => 0,   -- признак генерации исключения (0 - да, 1 - нет)
                     nCOMPANY     => 90521,   -- организация.
                     sCODE        => sARTCL_TEMA, -- мнемокод
                     nRN          => nARTCLRN_TEMA    -- регистрационный номер записи
                     );

  FIND_FPDARTCL_CODE(nFLAG_SMART  => 0,   -- признак генерации исключения (0 - да, 1 - нет)
                     nCOMPANY     => 90521,   -- организация.
                     sCODE        => sARTCL_KA, -- мнемокод
                     nRN          => nARTCLRN_KA    -- регистрационный номер записи
                     );

  FIND_FPDARTCL_CODE(nFLAG_SMART  => 0,   -- признак генерации исключения (0 - да, 1 - нет)
                     nCOMPANY     => 90521,   -- организация.
                     sCODE        => sARTCL_PKI, -- мнемокод
                     nRN          => nARTCLRN_PKI    -- регистрационный номер записи
                     );

  FIND_FPDARTCL_CODE(nFLAG_SMART  => 0,   -- признак генерации исключения (0 - да, 1 - нет)
                     nCOMPANY     => 90521,   -- организация.
                     sCODE        => sARTCL_Proch, -- мнемокод
                     nRN          => nARTCLRN_Proch    -- регистрационный номер записи
                     );
  
  FIND_FPDARTCL_CODE(nFLAG_SMART  => 0,   -- признак генерации исключения (0 - да, 1 - нет)
                     nCOMPANY     => 90521,   -- организация.
                     sCODE        => sARTCL_Comers, -- мнемокод
                     nRN          => nARTCLRN_Comers    -- регистрационный номер записи
                     );
 ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  -- Описываем имена ячеек в шапке и подвале

  -- Описываем добавляемые строки
  PRSG_EXCEL.LINE_DESCRIBE(L_GROUP);
  PRSG_EXCEL.LINE_DESCRIBE(L_PRJ1);
  PRSG_EXCEL.LINE_DESCRIBE(L_PRJ2);
  PRSG_EXCEL.LINE_DESCRIBE(L_PRJ3);
  PRSG_EXCEL.LINE_DESCRIBE(L_STAGE1);
  PRSG_EXCEL.LINE_DESCRIBE(L_STAGE2);
  PRSG_EXCEL.LINE_DESCRIBE(L_AGENT);
  PRSG_EXCEL.LINE_DESCRIBE(L_Itog);
  PRSG_EXCEL.LINE_DESCRIBE(L_GSUM);
    
  -- Описываем имена ячеек в добавляемых строках
  PRSG_EXCEL.CELL_DESCRIBE(C_sHEARD_NAME);
  PRSG_EXCEL.CELL_DESCRIBE(C_SHD_GROUP_1);
  PRSG_EXCEL.CELL_DESCRIBE(C_SHD_GROUP_2);
  PRSG_EXCEL.CELL_DESCRIBE(C_SHD_GROUP_3);
  PRSG_EXCEL.CELL_DESCRIBE(C_SHD_GROUP_4);
--L_GROUP
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_sGROUP_NAME);

--L_PRJ1
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_sPRJ_RUK);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_sAGENT_NAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_sPRJ_CODE);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_npp);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_PRJ_CODE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_sEconomist);
  
  
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM1_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM1_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM2_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM2_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM3_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM3_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM4_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM4_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM_PRJ_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM_PRJ_FACT);
  
--L_PRJ2
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_sPRJ_NAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_sPRJ_SHEFR);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM1_PLAN_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM1_FACT_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM2_PLAN_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM2_FACT_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM3_PLAN_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM3_FACT_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM4_PLAN_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM4_FACT_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM_PRJ_PLAN_IN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM_PRJ_FACT_IN);

--L_PRJ3

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM1_PLAN_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM1_FACT_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM2_PLAN_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM2_FACT_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM3_PLAN_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM3_FACT_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM4_PLAN_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM4_FACT_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM_PRJ_PLAN_OUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM_PRJ_FACT_OUT);

--L_STAGE1
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_sStage_NUMB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_sStage_NAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_sPAY_TYPE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_PRJ_CODE_ST);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM1_ST_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM2_ST_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM3_ST_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM4_ST_PLAN);
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM1_ST_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM2_ST_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM3_ST_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM4_ST_FACT);


  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM_ST_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM_ST_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM_ST_PAY);
  
  
-- Line_AGENT 
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_sEXEC_NAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_sAGENT_PRIM);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_sAGN_PAY_TYPE); 
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM1_AG_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM2_AG_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM3_AG_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM4_AG_PLAN);
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM1_AG_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM2_AG_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM3_AG_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM4_AG_FACT);


  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM_AG_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM_AG_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM_AG_PAY);

-- Line_Itog
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_Itog, C_nItog1_P);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_Itog, C_nItog2_P);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_Itog, C_nItog3_P);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_Itog, C_nItog4_P);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_Itog, C_nItog1_F);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_Itog, C_nItog2_F);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_Itog, C_nItog3_F);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_Itog, C_nItog4_F);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_Itog, C_nItog_P);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_Itog, C_nItog_F);
  
-- Line_GROUP 
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_sITOG_GNAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_sITOG_GSUM);
   
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM1_GR_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM2_GR_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM3_GR_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM4_GR_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM1_GR_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM2_GR_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM3_GR_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM4_GR_FACT);  

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM_PGROUP);  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM_FGROUP);  
  
    
  ---Заполнение шапки отчета
     
      if nPerQWARD is not null then 
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SHD_GROUP_1, 'Месяц: '||to_char(nPerQWARD*3 -2) );
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SHD_GROUP_2, 'Месяц: '||to_char(nPerQWARD*3 -1) );
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SHD_GROUP_3, 'Месяц: '||to_char(nPerQWARD*3   ) );
          PRSG_EXCEL.CELL_VALUE_WRITE(C_SHD_GROUP_4, ' ');
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sHEARD_NAME, 'Итого поступления/расходы за '||nPerQWARD ||' квартал');
      else
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sHEARD_NAME, 'Итого поступления/расходы за '||nPeriod ||' год');
      end if;
       
       nPeriod := to_number(sPeriod);
       
       if nPerQWARD is not null and nPerQWARD not in (1,2,3,4) then
         P_exception(0,'Значение квартала должно быть в пределах от 1 до 4.');  
       end if;
 
       dRep_date := sysdate;
       nEMPTY_GROUP := 0;
       
       begin
         select p.startdate, p.enddate
         into dStart_date, dEnd_date
         from ENPERIOD p
         where (p.pertype = 3 and nPerQWARD is null or 
                p.pertype = 2 and (trunc(extract(month from p.startdate)/3)+ 1) = nPerQWARD )  
           and extract(year from p.startdate) = nPeriod; 
       exception when others then
         P_exception(0,'Период %s не определен.', sPeriod);
       end;
       
   /*верхний цикл по группам заказчиков*/
  for MainAG in (select t.* 
                   from EXTRA_DICTS_VALUES t 
                  where t.pRN = 6454950 
                    and (t.str_value = sGROUP_CODE or sGROUP_CODE is null) 
                    and (t.str_value <> sGROUP_CODE_not or sGROUP_CODE_not is null) 
                  order by t.note
  ) loop 
  
      PRINT_GROUP(
              sMAIN_AG      => MainAG.Str_Value,
              slPERSON      => SPERSON,
              dlStart_date  => dStart_date,
              dlEnd_date    => dEnd_date,
              nlPrint       => 1,
              slACC_type    => '0'
            );  
  
            nGROUP_all := 0;
            for i in 1 .. C_nARAY loop
              ITOG_SUM(i) := ITOG_SUM(i) + GROUP_SUM(i);
              nGROUP_all := nGROUP_all + GROUP_SUM(i);
            end loop;
 

    for prin in 0..3 loop
      if prin = 0 then 
        sGROUP_in_name  := 'ИТОГО приход: ';
        sGROUP_out_name := 'ИТОГО расход: ';
      elsif prin = 2 then
        sGROUP_in_name  := '__ИТОГО приход Специальный: ';
        sGROUP_out_name := '__ИТОГО расход Специальный: ';
--        sACC_type := 'Специальный';
        
      elsif prin = 3 then
        sGROUP_in_name  := '__ИТОГО приход УФК: ';
        sGROUP_out_name := '__ИТОГО расход УФК: ';
--        sACC_type := 'УФК';
--        nPrint_en := 0;
        
      elsif prin = 1 then
        sGROUP_in_name  := '__ИТОГО приход Расчетный: ';
        sGROUP_out_name := '__ИТОГО расход Расчетный: ';
--        sACC_type := 'Расчетный';
--        nPrint_en := 0;
        
      end if;
       
        GET_SUMG(0, prin, 1, 0, nGROUP1_Pin);
        GET_SUMG(0, prin, 2, 0, nGROUP2_Pin);
        GET_SUMG(0, prin, 3, 0, nGROUP3_Pin);
        GET_SUMG(0, prin, 4, 0, nGROUP4_Pin);

        GET_SUMG(0, prin, 1, 1, nGROUP1_Fin);
        GET_SUMG(0, prin, 2, 1, nGROUP2_Fin);
        GET_SUMG(0, prin, 3, 1, nGROUP3_Fin);
        GET_SUMG(0, prin, 4, 1, nGROUP4_Fin);

        GET_SUMG(1, prin, 1, 0, nGROUP1_Pout);
        GET_SUMG(1, prin, 2, 0, nGROUP2_Pout);
        GET_SUMG(1, prin, 3, 0, nGROUP3_Pout);
        GET_SUMG(1, prin, 4, 0, nGROUP4_Pout);

        GET_SUMG(1, prin, 1, 1, nGROUP1_Fout);
        GET_SUMG(1, prin, 2, 1, nGROUP2_Fout);
        GET_SUMG(1, prin, 3, 1, nGROUP3_Fout);
        GET_SUMG(1, prin, 4, 1, nGROUP4_Fout);

        nEMPTY_GROUP := 0;
        --  if prin = 1 then          
            if nGROUP_all <> 0    
             then         
               nEMPTY_GROUP := 0;
             else 
               nEMPTY_GROUP := 1;
             end if;   
       --    end if;
    -- P_exception(0,'Период %s не определен.%s', dStart_date, dEnd_DATE);
       --   if nEMPTY_GROUP = 0 then
         /* По последней группе*/  
          if nEMPTY_GROUP = 0 then
            if prin = 0 then 
              nSTR_GROUP      := PRSG_EXCEL.LINE_CONTINUE(L_GSUM); 
              nSTR_GROUP_in   := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
              nSTR_GROUP_in1  := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
              nSTR_GROUP_in2  := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
              nSTR_GROUP_in3  := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
              nSTR_GROUP_out  := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
              nSTR_GROUP_out1 := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
              nSTR_GROUP_out2 := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
              nSTR_GROUP_out3 := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
            elsif prin = 1 then  
              nSTR_GROUP_in   := nSTR_GROUP_in1;
              nSTR_GROUP_out  := nSTR_GROUP_out1;
            elsif prin = 2 then    
              nSTR_GROUP_in   := nSTR_GROUP_in2;
              nSTR_GROUP_out  := nSTR_GROUP_out2;
            elsif prin = 3 then
              nSTR_GROUP_in   := nSTR_GROUP_in3;
              nSTR_GROUP_out  := nSTR_GROUP_out3;
            end if;  

            if prin = 1 then
              PRSG_EXCEL.CELL_VALUE_WRITE(C_sITOG_GNAME,   0, nSTR_GROUP, 'ИТОГО по группе: '|| MainAG.Str_Value);         

              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_PLAN, 0, nSTR_GROUP, nGROUP1_Pin - nGROUP1_Pout);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_PLAN, 0, nSTR_GROUP, nGROUP2_Pin - nGROUP2_Pout);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_PLAN, 0, nSTR_GROUP, nGROUP3_Pin - nGROUP3_Pout);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_PLAN, 0, nSTR_GROUP, nGROUP4_Pin - nGROUP4_Pout);
              
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_FACT, 0, nSTR_GROUP, nGROUP1_Fin - nGROUP1_Fout);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_FACT, 0, nSTR_GROUP, nGROUP2_Fin - nGROUP2_Fout);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_PLAN, 0, nSTR_GROUP, nGROUP3_Fin - nGROUP3_Fout);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_FACT, 0, nSTR_GROUP, nGROUP4_Fin - nGROUP4_Fout); 

              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PGROUP,   0, nSTR_GROUP, nGROUP1_Pin + nGROUP2_Pin + nGROUP3_Pin + nGROUP4_Pin - nGROUP1_Pout - nGROUP2_Pout - nGROUP3_Pout - nGROUP4_Pout);   
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_FGROUP,   0, nSTR_GROUP, nGROUP1_Fin + nGROUP2_Fin + nGROUP3_Fin + nGROUP4_Fin - nGROUP1_Fout - nGROUP2_Fout - nGROUP3_Fout - nGROUP4_Fout); 
            end if;
            
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sITOG_GSUM,   0, nSTR_GROUP_in, sGROUP_in_name);         

            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_PLAN, 0, nSTR_GROUP_in, nGROUP1_Pin);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_PLAN, 0, nSTR_GROUP_in, nGROUP2_Pin);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_PLAN, 0, nSTR_GROUP_in, nGROUP3_Pin);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_PLAN, 0, nSTR_GROUP_in, nGROUP4_Pin);
            


            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_FACT, 0, nSTR_GROUP_in, nGROUP1_Fin);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_FACT, 0, nSTR_GROUP_in, nGROUP2_Fin);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_FACT, 0, nSTR_GROUP_in, nGROUP3_Fin);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_FACT, 0, nSTR_GROUP_in, nGROUP4_Fin); 



            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PGROUP,   0, nSTR_GROUP_in, nGROUP1_Pin + nGROUP2_Pin + nGROUP3_Pin + nGROUP4_Pin);   
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_FGROUP,   0, nSTR_GROUP_in, nGROUP1_Fin + nGROUP2_Fin + nGROUP3_Fin + nGROUP4_Fin); 

            PRSG_EXCEL.CELL_VALUE_WRITE(C_sITOG_GSUM,   0, nSTR_GROUP_out, sGROUP_out_name);         

            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_PLAN, 0, nSTR_GROUP_out, nGROUP1_Pout);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_PLAN, 0, nSTR_GROUP_out, nGROUP2_Pout);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_PLAN, 0, nSTR_GROUP_out, nGROUP3_Pout);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_PLAN, 0, nSTR_GROUP_out, nGROUP4_Pout);
            
 

            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_FACT, 0, nSTR_GROUP_out, nGROUP1_Fout);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_FACT, 0, nSTR_GROUP_out, nGROUP2_Fout);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_FACT, 0, nSTR_GROUP_out, nGROUP3_Fout);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_FACT, 0, nSTR_GROUP_out, nGROUP4_Fout); 


            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PGROUP,   0, nSTR_GROUP_out, nGROUP1_Pout + nGROUP2_Pout + nGROUP3_Pout + nGROUP4_Pout);   
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_FGROUP,   0, nSTR_GROUP_out, nGROUP1_Fout + nGROUP2_Fout + nGROUP3_Fout + nGROUP4_Fout); 
 
          end if;
 
    end loop;                     
          
 
  end loop;
  
      if nSTR_GROUP_HED is not null and 1=2 then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sITOG_GNAME, 0, nSTR_GROUP_HED, ' ');         
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sGROUP_NAME, 0, nSTR_GROUP_HED, ' ');  
      end if;
      nSTR_GROUP_HED      := PRSG_EXCEL.LINE_CONTINUE(L_Itog); 
      if sGROUP_CODE is null then        
          for prin in 0..3 loop
            if prin = 0 then 
              sGROUP_in_name  := 'ВСЕГО приход: ';
              sGROUP_out_name := 'ВСЕГО расход: ';
        --        nPrint_en := 1;
        --      sACC_type := '0';
            elsif prin = 2 then
              sGROUP_in_name  := '__ВСЕГО приход Специальный: ';
              sGROUP_out_name := '__ВСЕГО расход Специальный: ';
        --      sACC_type := 'Специальный';
        --        nPrint_en := 0;
                
            elsif prin = 3 then
              sGROUP_in_name  := '__ВСЕГО приход УФК: ';
              sGROUP_out_name := '__ВСЕГО расход УФК: ';
        --      sACC_type := 'УФК';
        --        nPrint_en := 0;
                
            elsif  prin = 1 then 
              sGROUP_in_name  := '__ВСЕГО приход Расчетный: ';
              sGROUP_out_name := '__ВСЕГО расход Расчетный: ';
        --      sACC_type := 'Расчетный';
        --        nPrint_en := 0;
                
            end if;
               

                  GET_SUM(0, prin, 1, 0, nGROUP1_Pin);
                  GET_SUM(0, prin, 2, 0, nGROUP2_Pin);
                  GET_SUM(0, prin, 3, 0, nGROUP3_Pin);
                  GET_SUM(0, prin, 4, 0, nGROUP4_Pin);


                  GET_SUM(0, prin, 1, 1, nGROUP1_Fin);
                  GET_SUM(0, prin, 2, 1, nGROUP2_Fin);
                  GET_SUM(0, prin, 3, 1, nGROUP3_Fin);
                  GET_SUM(0, prin, 4, 1, nGROUP4_Fin);

                  GET_SUM(1, prin, 1, 0, nGROUP1_Pout);
                  GET_SUM(1, prin, 2, 0, nGROUP2_Pout);
                  GET_SUM(1, prin, 3, 0, nGROUP3_Pout);
                  GET_SUM(1, prin, 4, 0, nGROUP4_Pout);


                  GET_SUM(1, prin, 1, 1, nGROUP1_Fout);
                  GET_SUM(1, prin, 2, 1, nGROUP2_Fout);
                  GET_SUM(1, prin, 3, 1, nGROUP3_Fout);
                  GET_SUM(1, prin, 4, 1, nGROUP4_Fout);

                  if prin = 0 then 
                    nSTR_GROUP      := PRSG_EXCEL.LINE_CONTINUE(L_GSUM); 
                    nSTR_GROUP_in   := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
                    nSTR_GROUP_in1  := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
                    nSTR_GROUP_in2  := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
                    nSTR_GROUP_in3  := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
                    nSTR_GROUP_out  := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
                    nSTR_GROUP_out1 := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
                    nSTR_GROUP_out2 := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
                    nSTR_GROUP_out3 := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
                  elsif prin = 1 then  
                    nSTR_GROUP_in   := nSTR_GROUP_in1;
                    nSTR_GROUP_out  := nSTR_GROUP_out1;
                  elsif prin = 2 then    
                    nSTR_GROUP_in   := nSTR_GROUP_in2;
                    nSTR_GROUP_out  := nSTR_GROUP_out2;
                  elsif prin = 3 then 
                    nSTR_GROUP_in   := nSTR_GROUP_in3;
                    nSTR_GROUP_out  := nSTR_GROUP_out3;
                
                  end if;  

                  if prin = 0 then
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_PLAN, 0, nSTR_GROUP, 'ВСЕГО: ');         

                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_PLAN, 0, nSTR_GROUP, nGROUP1_Pin - nGROUP1_Pout);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_PLAN, 0, nSTR_GROUP, nGROUP2_Pin - nGROUP2_Pout);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_PLAN, 0, nSTR_GROUP, nGROUP3_Pin - nGROUP3_Pout);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_PLAN, 0, nSTR_GROUP, nGROUP4_Pin - nGROUP4_Pout);
                      
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_FACT, 0, nSTR_GROUP, nGROUP1_Fin - nGROUP1_Fout);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_FACT, 0, nSTR_GROUP, nGROUP2_Fin - nGROUP2_Fout);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_PLAN, 0, nSTR_GROUP, nGROUP3_Fin - nGROUP3_Fout);
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_FACT, 0, nSTR_GROUP, nGROUP4_Fin - nGROUP4_Fout); 

                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PGROUP,   0, nSTR_GROUP, nGROUP1_Pin + nGROUP2_Pin + nGROUP3_Pin + nGROUP4_Pin - nGROUP1_Pout - nGROUP2_Pout - nGROUP3_Pout - nGROUP4_Pout);   
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_FGROUP,   0, nSTR_GROUP, nGROUP1_Fin + nGROUP2_Fin + nGROUP3_Fin + nGROUP4_Fin - nGROUP1_Fout - nGROUP2_Fout - nGROUP3_Fout - nGROUP4_Fout); 

                  end if;
                    
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_sITOG_GSUM,   0, nSTR_GROUP_in, sGROUP_in_name);         

                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_PLAN, 0, nSTR_GROUP_in, nGROUP1_Pin);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_PLAN, 0, nSTR_GROUP_in, nGROUP2_Pin);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_PLAN, 0, nSTR_GROUP_in, nGROUP3_Pin);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_PLAN, 0, nSTR_GROUP_in, nGROUP4_Pin);
                    
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_FACT, 0, nSTR_GROUP_in, nGROUP1_Fin);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_FACT, 0, nSTR_GROUP_in, nGROUP2_Fin);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_FACT, 0, nSTR_GROUP_in, nGROUP3_Fin);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_FACT, 0, nSTR_GROUP_in, nGROUP4_Fin); 

                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PGROUP,   0, nSTR_GROUP_in, nGROUP1_Pin + nGROUP2_Pin + nGROUP3_Pin + nGROUP4_Pin);   
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_FGROUP,   0, nSTR_GROUP_in, nGROUP1_Fin + nGROUP2_Fin + nGROUP3_Fin + nGROUP4_Fin); 

                  PRSG_EXCEL.CELL_VALUE_WRITE(C_sITOG_GSUM,   0, nSTR_GROUP_out, sGROUP_out_name);         

                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_PLAN, 0, nSTR_GROUP_out, nGROUP1_Pout);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_PLAN, 0, nSTR_GROUP_out, nGROUP2_Pout);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_PLAN, 0, nSTR_GROUP_out, nGROUP3_Pout);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_PLAN, 0, nSTR_GROUP_out, nGROUP4_Pout);
                    
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_FACT, 0, nSTR_GROUP_out, nGROUP1_Fout);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_FACT, 0, nSTR_GROUP_out, nGROUP2_Fout);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_FACT, 0, nSTR_GROUP_out, nGROUP3_Fout);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_FACT, 0, nSTR_GROUP_out, nGROUP4_Fout); 

                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PGROUP,   0, nSTR_GROUP_out, nGROUP1_Pout + nGROUP2_Pout + nGROUP3_Pout + nGROUP4_Pout);   
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_FGROUP,   0, nSTR_GROUP_out, nGROUP1_Fout + nGROUP2_Fout + nGROUP3_Fout + nGROUP4_Fout);
           
         
          end loop;   
        end if;
  
     --удаляем техническую строку
     PRSG_EXCEL.LINE_DELETE(L_GROUP);
     PRSG_EXCEL.LINE_DELETE(L_PRJ1);
     PRSG_EXCEL.LINE_DELETE(L_PRJ2);          
     PRSG_EXCEL.LINE_DELETE(L_PRJ3);          
     PRSG_EXCEL.LINE_DELETE(L_STAGE1);
     PRSG_EXCEL.LINE_DELETE(L_STAGE2);  
     PRSG_EXCEL.LINE_DELETE(L_AGENT);  
     PRSG_EXCEL.LINE_DELETE(L_Itog);  
     PRSG_EXCEL.LINE_DELETE(L_GSUM);
      
end UDO_RP_BUDJET_CONTRACTS_EXT;
/

