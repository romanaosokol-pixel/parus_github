create or replace procedure UDO_RP_BUDJET_CONTRACTS(
sPeriod in varchar,
SPERSON in varchar

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
--L_GROUP
  C_sGROUP_NAME      constant PKG_STD.TSTRING := 'sGROUP_NAME';

--L_PRJ1
  C_sPRJ_RUK      constant PKG_STD.TSTRING := 'sPRJ_RUK';     
  C_sAGENT_NAME   constant PKG_STD.TSTRING := 'sAGENT_NAME';        
  C_sPRJ_CODE     constant PKG_STD.TSTRING := 'sPRJ_CODE';    
  C_sPAY_TYPE     constant PKG_STD.TSTRING := 'sPAY_TYPE';   
  C_sCOMMENT      constant PKG_STD.TSTRING := 'sCOMMENT';   
  C_sEconomist    constant PKG_STD.TSTRING := 'sEconomist';   
  C_sNDS          constant PKG_STD.TSTRING := 'sNDS';   
  C_PRJ_CODE      constant PKG_STD.TSTRING := 'PRJ_CODE';  
  C_npp           constant PKG_STD.TSTRING := 'nPP';  
   
     
  C_nSUM1_PLAN    constant PKG_STD.TSTRING := 'nSUM1_PLAN'; 
  C_nSUM1_FACT    constant PKG_STD.TSTRING := 'nSUM1_FACT';
  C_nSUM1_REST    constant PKG_STD.TSTRING := 'nSUM1_REST';
  C_nSUM2_PLAN    constant PKG_STD.TSTRING := 'nSUM2_PLAN';
  C_nSUM2_FACT    constant PKG_STD.TSTRING := 'nSUM2_FACT';
  C_nSUM2_REST    constant PKG_STD.TSTRING := 'nSUM2_REST';
  C_nSUM3_PLAN    constant PKG_STD.TSTRING := 'nSUM3_PLAN'; 
  C_nSUM3_FACT    constant PKG_STD.TSTRING := 'nSUM3_FACT';
  C_nSUM3_REST    constant PKG_STD.TSTRING := 'nSUM3_REST';
  C_nSUM4_PLAN    constant PKG_STD.TSTRING := 'nSUM4_PLAN';
  C_nSUM4_FACT    constant PKG_STD.TSTRING := 'nSUM4_FACT';
  C_nSUM4_REST    constant PKG_STD.TSTRING := 'nSUM4_REST';
  C_nSUM_PRJ_REST constant PKG_STD.TSTRING := 'nSUM_PRJ_REST';
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
  C_nSUM1_REST_PIN    constant PKG_STD.TSTRING := 'nSUM1_REST_PIN';
  C_nSUM2_REST_PIN    constant PKG_STD.TSTRING := 'nSUM2_REST_PIN';
  C_nSUM3_REST_PIN    constant PKG_STD.TSTRING := 'nSUM3_REST_PIN';
  C_nSUM4_REST_PIN    constant PKG_STD.TSTRING := 'nSUM4_REST_PIN';
  C_nSUM_PRJ_REST_IN  constant PKG_STD.TSTRING := 'nSUM_PRJ_REST_IN';
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
  C_nSUM1_REST_POUT    constant PKG_STD.TSTRING := 'nSUM1_REST_POUT';
  C_nSUM2_REST_POUT    constant PKG_STD.TSTRING := 'nSUM2_REST_POUT';
  C_nSUM3_REST_POUT    constant PKG_STD.TSTRING := 'nSUM3_REST_POUT';
  C_nSUM4_REST_POUT    constant PKG_STD.TSTRING := 'nSUM4_REST_POUT';
  C_nSUM_PRJ_REST_OUT  constant PKG_STD.TSTRING := 'nSUM_PRJ_REST_OUT';
  C_nSUM_PRJ_PLAN_OUT  constant PKG_STD.TSTRING := 'nSUM_PRJ_PLAN_OUT';
  C_nSUM_PRJ_FACT_OUT  constant PKG_STD.TSTRING := 'nSUM_PRJ_FACT_OUT';
   
--L_STAGE1
  C_sStage_NUMB     constant PKG_STD.TSTRING := 'sStage_NUMB';
  C_sStage_NAME     constant PKG_STD.TSTRING := 'sStage_NAME';

  C_nSUM1_ST_PLAN   constant PKG_STD.TSTRING := 'nSUM1_ST_PLAN';
  C_nSUM2_ST_PLAN   constant PKG_STD.TSTRING := 'nSUM2_ST_PLAN';
  C_nSUM3_ST_PLAN   constant PKG_STD.TSTRING := 'nSUM3_ST_PLAN';
  C_nSUM4_ST_PLAN   constant PKG_STD.TSTRING := 'nSUM4_ST_PLAN';
  C_nSUM1_ST_FACT   constant PKG_STD.TSTRING := 'nSUM1_ST_FACT';
  C_nSUM2_ST_FACT   constant PKG_STD.TSTRING := 'nSUM2_ST_FACT';
  C_nSUM3_ST_FACT   constant PKG_STD.TSTRING := 'nSUM3_ST_FACT';
  C_nSUM4_ST_FACT   constant PKG_STD.TSTRING := 'nSUM4_ST_FACT';
  C_nSUM1_ST_REST   constant PKG_STD.TSTRING := 'nSUM1_ST_REST';
  C_nSUM2_ST_REST   constant PKG_STD.TSTRING := 'nSUM2_ST_REST';
  C_nSUM3_ST_REST   constant PKG_STD.TSTRING := 'nSUM3_ST_REST';
  C_nSUM4_ST_REST   constant PKG_STD.TSTRING := 'nSUM4_ST_REST';

  C_nSUM_ST_PLAN     constant PKG_STD.TSTRING := 'nSUM_ST_PLAN';
  
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
  C_nSUM1_AG_REST   constant PKG_STD.TSTRING := 'nSUM1_AG_REST';
  C_nSUM2_AG_REST   constant PKG_STD.TSTRING := 'nSUM2_AG_REST';
  C_nSUM3_AG_REST   constant PKG_STD.TSTRING := 'nSUM3_AG_REST';
  C_nSUM4_AG_REST   constant PKG_STD.TSTRING := 'nSUM4_AG_REST';
  
  C_nSUM_AG_PLAN     constant PKG_STD.TSTRING := 'nSUM_AG_PLAN';

--L_GSUM

  C_sITOG_GNAME     constant PKG_STD.TSTRING := 'sITOG_GROUP_NAME';
  C_nSUM1_GR_PLAN   constant PKG_STD.TSTRING := 'nSUM1_GR_PLAN';
  C_nSUM2_GR_PLAN   constant PKG_STD.TSTRING := 'nSUM2_GR_PLAN';
  C_nSUM3_GR_PLAN   constant PKG_STD.TSTRING := 'nSUM3_GR_PLAN';
  C_nSUM4_GR_PLAN   constant PKG_STD.TSTRING := 'nSUM4_GR_PLAN';
  C_nSUM1_GR_FACT   constant PKG_STD.TSTRING := 'nSUM1_GR_FACT';
  C_nSUM2_GR_FACT   constant PKG_STD.TSTRING := 'nSUM2_GR_FACT';
  C_nSUM3_GR_FACT   constant PKG_STD.TSTRING := 'nSUM3_GR_FACT';
  C_nSUM4_GR_FACT   constant PKG_STD.TSTRING := 'nSUM4_GR_FACT';
  C_nSUM1_GR_REST   constant PKG_STD.TSTRING := 'nSUM1_GR_REST';
  C_nSUM2_GR_REST   constant PKG_STD.TSTRING := 'nSUM2_GR_REST';
  C_nSUM3_GR_REST   constant PKG_STD.TSTRING := 'nSUM3_GR_REST';
  C_nSUM4_GR_REST   constant PKG_STD.TSTRING := 'nSUM4_GR_REST';

  C_nSUMM_PGROUP    constant PKG_STD.TSTRING := 'nSUMM_PGROUP';
  C_nSUMM_FGROUP    constant PKG_STD.TSTRING := 'nSUMM_FGROUP';
  
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


  sARTCL_TEMA      PKG_STD.tSTRING := 'Темат. доходы_Б'; 
  sARTCL_KA        PKG_STD.tSTRING := 'Расходы на КА_Б'; 
  sARTCL_PKI       PKG_STD.tSTRING := 'Расходы на ПКИ_Б'; 
  sARTCL_Proch     PKG_STD.tSTRING := 'Прочие тем.расходы_Б';
  nARTCLRN_TEMA    PKG_STD.tREF;
  nARTCLRN_KA      PKG_STD.tREF;
  nARTCLRN_PKI     PKG_STD.tREF;
  nARTCLRN_Proch   PKG_STD.tREF;
  nPeriod          number(5) := 2023;
  nParam           number(2);
  nArticle         PKG_STD.tREF;

  
  nSTR_Cntr    PKG_STD.tREF := 1;
  nSTR_Cntr2   PKG_STD.tREF := 1;
  nSTR_Cntr3   PKG_STD.tREF := 1;
  nSTR_Staje   PKG_STD.tREF := 1;
  nSTR         PKG_STD.tREF := 1;
  nSTR_AG      PKG_STD.tREF := 1;
  nSTR_S       PKG_STD.tREF := 1;  
  nSTR_GROUP   PKG_STD.tREF := 1;
 

  nType    number(17) := -1;
  nConf    number(17) := -1;

  nPrint       number(2) :=0;
  nEMPTY_GROUP number (2):=0;
  dRep_date    date;
  dStart_date  date;
  dEnd_date    date;
  nPRJ_RN      PKG_STD.tREF;
  sPRJ_Shefr   PKG_STD.tSTRING;
  sOldGROUP    PKG_STD.TSTRING :=' - ';
  sPrim        PKG_STD.tSTRING;
  nPP          PKG_STD.tREF := 1;
  nIDENT_GROUP PKG_STD.tREF;
  nIDENT_REP   PKG_STD.tREF;
  
  
  nSUMM1_P PKG_STD.tSUMM := 0;
  nSUMM1_F PKG_STD.tSUMM := 0;
  nSUMM2_P PKG_STD.tSUMM := 0;
  nSUMM2_F PKG_STD.tSUMM := 0;
  nSUMM3_P PKG_STD.tSUMM := 0;
  nSUMM3_F PKG_STD.tSUMM := 0;
  nSUMM4_P PKG_STD.tSUMM := 0;
  nSUMM4_F PKG_STD.tSUMM := 0;
  nSUMM    PKG_STD.tSUMM := 0;
  
  nSumPRJ1_P PKG_STD.tSUMM := 0;
  nSumPRJ1_F PKG_STD.tSUMM := 0;
  nSumPRJ2_P PKG_STD.tSUMM := 0;
  nSumPRJ2_F PKG_STD.tSUMM := 0;
  nSumPRJ3_P PKG_STD.tSUMM := 0;
  nSumPRJ3_F PKG_STD.tSUMM := 0;
  nSumPRJ4_P PKG_STD.tSUMM := 0;
  nSumPRJ4_F PKG_STD.tSUMM := 0;

    
  nItog1_P  PKG_STD.tSUMM := 0;
  nItog2_P  PKG_STD.tSUMM := 0;
  nItog3_P  PKG_STD.tSUMM := 0;
  nItog4_P  PKG_STD.tSUMM := 0;
  nItog1_F  PKG_STD.tSUMM := 0;
  nItog2_F  PKG_STD.tSUMM := 0;
  nItog3_F  PKG_STD.tSUMM := 0;
  nItog4_F  PKG_STD.tSUMM := 0;
  nItog_P   PKG_STD.tSUMM := 0;
  nItog_F   PKG_STD.tSUMM := 0;
   
  nGROUP1_P  PKG_STD.tSUMM := 0;
  nGROUP2_P  PKG_STD.tSUMM := 0;
  nGROUP3_P  PKG_STD.tSUMM := 0;
  nGROUP4_P  PKG_STD.tSUMM := 0;
  nGROUP1_F  PKG_STD.tSUMM := 0;
  nGROUP2_F  PKG_STD.tSUMM := 0;
  nGROUP3_F  PKG_STD.tSUMM := 0;
  nGROUP4_F  PKG_STD.tSUMM := 0;
  nGROUP_P   PKG_STD.tSUMM := 0;
  nGROUP_F   PKG_STD.tSUMM := 0;
  

  nSUM1_P_in PKG_STD.tSUMM := 0;
  nSUM2_P_in PKG_STD.tSUMM := 0;
  nSUM3_P_in PKG_STD.tSUMM := 0;
  nSUM4_P_in PKG_STD.tSUMM := 0;
  nSUM1_F_in PKG_STD.tSUMM := 0;
  nSUM2_F_in PKG_STD.tSUMM := 0;
  nSUM3_F_in PKG_STD.tSUMM := 0;
  nSUM4_F_in PKG_STD.tSUMM := 0;
  nSUM1_R_in PKG_STD.tSUMM := 0;
  nSUM2_R_in PKG_STD.tSUMM := 0;
  nSUM3_R_in PKG_STD.tSUMM := 0;
  nSUM4_R_in PKG_STD.tSUMM := 0;

  nSUM1_P_out PKG_STD.tSUMM := 0;
  nSUM2_P_out PKG_STD.tSUMM := 0;
  nSUM3_P_out PKG_STD.tSUMM := 0;
  nSUM4_P_out PKG_STD.tSUMM := 0;
  nSUM1_F_out PKG_STD.tSUMM := 0;
  nSUM2_F_out PKG_STD.tSUMM := 0;
  nSUM3_F_out PKG_STD.tSUMM := 0;
  nSUM4_F_out PKG_STD.tSUMM := 0;
  nSUM1_R_out PKG_STD.tSUMM := 0;
  nSUM2_R_out PKG_STD.tSUMM := 0;
  nSUM3_R_out PKG_STD.tSUMM := 0;
  nSUM4_R_out PKG_STD.tSUMM := 0;
  
/*  
  nItog09  number(17,2) := 0;
  nItog10  number(17,2) := 0; nItog11  number(17,2) := 0; nItog12  number(17,2) := 0;
  nItogF01  number(17,2) := 0; nItogF02  number(17,2) := 0; nItogF03  number(17,2) := 0;
  nItogF04  number(17,2) := 0; nItogF05  number(17,2) := 0; nItogF06  number(17,2) := 0;
  nItogF07  number(17,2) := 0; nItogF08  number(17,2) := 0; nItogF09  number(17,2) := 0;
  nItogF10  number(17,2) := 0; nItogF11  number(17,2) := 0; nItogF12  number(17,2) := 0;
  
  nSum01  number(17,2) := 0; nSum02  number(17,2) := 0; nSum03  number(17,2) := 0;
  nSum04  number(17,2) := 0; nSum05  number(17,2) := 0; nSum06  number(17,2) := 0;
  nSum07  number(17,2) := 0; nSum08  number(17,2) := 0; nSum09  number(17,2) := 0;
  nSum10  number(17,2) := 0; nSum11  number(17,2) := 0; nSum12  number(17,2) := 0;
  nSumF01  number(17,2) := 0; nSumF02  number(17,2) := 0; nSumF03  number(17,2) := 0;
  nSumF04  number(17,2) := 0; nSumF05  number(17,2) := 0; nSumF06  number(17,2) := 0;
  nSumF07  number(17,2) := 0; nSumF08  number(17,2) := 0; nSumF09  number(17,2) := 0;
  nSumF10  number(17,2) := 0; nSumF11  number(17,2) := 0; nSumF12  number(17,2) := 0;*/
--Расходы на КА
--Расходы на ПКИ
--Тематические доходы
procedure CALC_MARK_SUM (
     nlFACE      in number
    ,nlCost_FACE in number
    ,nlARTCL     in number
--   ,nlARTCL2 in number default 0 
    ,nlPeriod in number
    ,nlSUMM1_P out PKG_STD.tSUMM  
    ,nlSUMM1_F out PKG_STD.tSUMM  
    ,nlSUMM2_P out PKG_STD.tSUMM  
    ,nlSUMM2_F out PKG_STD.tSUMM  
    ,nlSUMM3_P out PKG_STD.tSUMM  
    ,nlSUMM3_F out PKG_STD.tSUMM  
    ,nlSUMM4_P out PKG_STD.tSUMM  
    ,nlSUMM4_F out PKG_STD.tSUMM
    ,nlSUMM_all out PKG_STD.tSUMM
    ,sPrim_art  out PKG_STD.tSTRING
  
  )
is

  nlSUMM    PKG_STD.tSUMM := 0;
  nLPAN_RN  PKG_STD.tREF; 
  sPRIM     PKG_STD.tSTRING;
begin
  nlSUMM1_P := 0;
  nlSUMM1_F := 0;
  nlSUMM2_P := 0;
  nlSUMM2_F := 0;
  nlSUMM3_P := 0;
  nlSUMM3_F := 0;
  nlSUMM4_P := 0;
  nlSUMM4_F := 0;  

  nlSUMM_all := 0;
  
--  if nlFACE is not null then
  for pl in 1..2 loop
    if pl = 1 then 
      nLPAN_RN := 132176; -- plan
    else
      nLPAN_RN := 132177; --fact
    end if;
    /* Обход по переиодам */
    for clc in (
      select pr.STARTDATE
            ,pr.ENDDATE
            ,extract(month from pr.startdate) as nMON_numb
      from ENPERIOD  pr
      where pr.pertype = 2  --квартал
        and extract(year from pr.startdate) = nlPeriod 
    ) loop
       nlSUMM := 0;
   
       select sum(pm.val) 
         into nlSUMM
         from UDO_T_MARK pm
        where (pm.cost_faceacc = nlCOST_FACE or nlCOST_FACE is null)
          and (pm.faceacc = nlFACE or (nlFACE is null and pm.faceacc is null) )
          and pm.fpdartcl in ( nlARTCL)
          and pm.finstate = nLPAN_RN  -- план
          and pm.mark_date between clc.STARTDATE and clc.ENDDATE;
 
       
       nlSUMM := NVL(nlSUMM, 0);
       if pl = 1 then
         if clc.nMON_numb = 1 then
           nlSUMM1_P := nlSUMM;
         elsif clc.nMON_numb = 4 then
           nlSUMM2_P := nlSUMM;
         elsif clc.nMON_numb = 7 then
           nlSUMM3_P := nlSUMM;
         else 
           nlSUMM4_P := nlSUMM;
         end if;
       else
         if clc.nMON_numb = 1 then
           nlSUMM1_F := nlSUMM;
         elsif clc.nMON_numb = 4 then
           nlSUMM2_F := nlSUMM;
         elsif clc.nMON_numb = 7 then
           nlSUMM3_F := nlSUMM;
         else 
           nlSUMM4_F := nlSUMM;
         end if;
       end if;
       nlSUMM_all := nlSUMM_all + nlSUMM;   
    end loop;
    for prm in (
      select distinct pm.note
      from UDO_T_MARK pm
      where extract(year from  pm.mark_date) = nlPeriod
        and (pm.cost_faceacc = nlFACE or pm.faceacc = nlFACE)
        and pm.fpdartcl in ( nlARTCL)
        and pm.finstate = nLPAN_RN
        and pm.finstate = 132176  -- Только по плановым показателям
      ) loop
        if sPrim_art is null then
          sPrim_art := prm.note;
        else
          sPrim_art := sPrim_art ||','||CR||prm.note;
        end if;   
    end loop;  
  end loop; 
--  end if;
end CALC_MARK_SUM;


begin
  
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
  --PRSG_EXCEL.CELL_DESCRIBE(C_sTest);
--  PRSG_EXCEL.CELL_DESCRIBE(C_sData);
--  PRSG_EXCEL.CELL_DESCRIBE(C_sYear);
--L_GROUP
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_sGROUP_NAME);

--L_PRJ1
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_sPRJ_RUK);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_sAGENT_NAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_sPRJ_CODE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_sPAY_TYPE);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_npp);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_PRJ_CODE);
  
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM1_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM1_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM1_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM2_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM2_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM2_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM3_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM3_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM3_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM4_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM4_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM4_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM_PRJ_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM_PRJ_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ1, C_nSUM_PRJ_FACT);
  
--L_PRJ2
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_sPRJ_NAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_sPRJ_SHEFR);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM1_PLAN_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM1_FACT_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM1_REST_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM2_PLAN_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM2_FACT_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM2_REST_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM3_PLAN_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM3_FACT_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM3_REST_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM4_PLAN_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM4_FACT_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM4_REST_PIN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM_PRJ_REST_IN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM_PRJ_PLAN_IN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ2, C_nSUM_PRJ_FACT_IN);

--L_PRJ3

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM1_PLAN_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM1_FACT_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM1_REST_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM2_PLAN_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM2_FACT_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM2_REST_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM3_PLAN_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM3_FACT_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM3_REST_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM4_PLAN_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM4_FACT_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM4_REST_POUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM_PRJ_REST_OUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM_PRJ_PLAN_OUT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_PRJ3, C_nSUM_PRJ_FACT_OUT);

--L_STAGE1
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_sStage_NUMB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_sStage_NAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM1_ST_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM2_ST_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM3_ST_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM4_ST_PLAN);
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM1_ST_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM2_ST_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM3_ST_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM4_ST_FACT);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM1_ST_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM2_ST_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM3_ST_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM4_ST_REST);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_STAGE1, C_nSUM_ST_PLAN);
  
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

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM1_AG_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM2_AG_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM3_AG_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM4_AG_REST);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_AGENT, C_nSUM_AG_PLAN);

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
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM1_GR_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM2_GR_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM3_GR_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM4_GR_PLAN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM1_GR_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM2_GR_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM3_GR_FACT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM4_GR_FACT);  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM1_GR_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM2_GR_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM3_GR_REST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUM4_GR_REST);  

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUMM_PGROUP);  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GSUM, C_nSUMM_FGROUP);  
  
    
 /*   
  ---Заполнение шапки отчета
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sData, 'Отчет на ' || to_char(SYSDATE, 'DD.MM.YYYY'));
--  PRSG_EXCEL.CELL_VALUE_WRITE(C_sYear, 'План бюджета на ' || to_char(SYSDATE, 'YYYY') || 'г. ЗАО НТЦ "Модуль"');
  select god.name into sPeriodName from UDO_T_FINPLAN prn_id, ENPERIOD god, selectlist sl 
    where sl.ident = nIDENT and prn_id.RN = sl.document 
    and god.rn = prn_id.fp_period and rownum <= 1;
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sYear, 'План бюджета на ' || sPeriodName || ', АО НТЦ "Модуль"');*/
      
 nPeriod := to_number(sPeriod);
       dRep_date := sysdate;
       nEMPTY_GROUP := 1;
       
       begin
         select p.startdate, p.enddate
         into dStart_date, dEnd_date
         from ENPERIOD p
         where p.pertype = 3
           and extract(year from p.startdate) = nPeriod; 
       exception when others then
         P_exception(0,'Период %s не определен.', sPeriod);
       end;
       
       p_selectlist_genident(nIDENT => nIDENT_GROUP);
       p_selectlist_genident(nIDENT => nIDENT_REP);
   /*верхний цикл по группам заказчиков*/
  for MainAG in (select t.* from EXTRA_DICTS_VALUES t where t.pRN = 6454950 order by t.note) loop 
       
    -- P_exception(0,'Период %s не определен.%s', dStart_date, dEnd_DATE);
      For cntr in (select pr.*
                     from 
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

              from CONTRACTS      cnr
                  ,AGNLIST        ag
                  ,AGNACC         acc
                  ,BANKACCTYPES   btyp
             where ag.rn = cnr.agent
               and acc.rn (+) = cnr.jur_acc
               and btyp.rn (+) = acc.bankacc_type
               and F_DOCS_PROPS_GET_STR_VALUE (
                            nPROPERTY     => 6454955,              -- Заказчик работ
                            sUNITCODE     => 'Contracts',
                            nDOCUMENT     => cnr.RN ) = MainAG.str_value
               and exists(select null from STAGES st, FACEACC fc where st.prn = cnr.rn and st.faceacc = fc.rn and fc.acc_kind =1 )
             --  and cnr.RN = 20944646
               
               and (exists (select null 
                             from UDO_T_MARK pm, STAGES st 
                            where st.prn = cnr.rn
                              and pm.faceacc = st.faceacc
                              and pm.fpdartcl in (nARTCLRN_TEMA)
                              and pm.val <> 0
                              and pm.mark_date between dStart_date and dEnd_DATE
                       --       and pm.RN = 42797312
                                          
                              )
                     or exists (select null 
                                from UDO_T_MARK pm, STAGES st, PROJECTSTAGE   ps 
                            where st.prn = cnr.rn
                              and ps.faceacccust (+)  = st.faceacc
                              and pm.cost_faceacc = nvl(ps.faceacc, UDO_F_STAGES_GET_FACE_PROP(st.RN))
                              and pm.val <> 0
                              and pm.mark_date between dStart_date and dEnd_DATE
                              and pm.fpdartcl in ( nARTCLRN_KA, nARTCLRN_PKI, nARTCLRN_Proch) 
                       --       and pm.RN = 42797312
                                ))
                  and (UDO_F_PRJCONT_DOCPROP(SPROP => 'Сотрудник',
                                             nRN   => cnr.rn) = SPERSON or SPERSON is null)              
               union                   
            select null                             as nCN_RN
                  ,prj.rn                           as nPRJ_RN
                  ,prj.expected_res                 as sCN_SUBJECT
                  ,null                             as sCN_NUMB
                  ,null                             as sMain_Ruk
                  ,AG.AGNNAME                       as sAGENT_NAME
                  ,null                             as sCONTR_Shefr
                  ,'Инициативные'                   as sMain_Customer
                  ,null                             as sBank_Type

              from PROJECT        prj
                  ,AGNLIST        ag
             where ag.rn = prj.ext_cust
              -- and 1=2
               and not exists (select null from PROJECTSTAGE prjs where prjs.prn = prj.rn and prjs.faceacccust is not null)
               and     exists (select null 
                                from UDO_T_MARK pm, PROJECTSTAGE   ps 
                            where ps.prn  = prj.rn
                              and pm.cost_faceacc = ps.faceacc
                              and pm.val <> 0
                              and pm.mark_date between dStart_date and dEnd_DATE
                              and pm.fpdartcl in (nARTCLRN_KA, nARTCLRN_PKI, nARTCLRN_Proch) 
                       --      and pm.RN = 42797312
                                )  
               and MainAG.Str_Value = 'Инициативные'                 
               and (UDO_F_PRJCONT_DOCPROP(SPROP => 'Сотрудник',
                                             nRN   => prj.rn) = SPERSON or SPERSON is null)                                                        
         ) pr
         order by pr.sMain_Customer, pr.sMain_Ruk
       
       ) loop

         cntr.smain_customer := nvl(cntr.smain_customer,' -- ');
         
         if sOldGROUP <> cntr.smain_customer /*or sOldGROUP is null*/ then
           
           
            if nEMPTY_GROUP = 0 then
              nSTR_GROUP := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_sITOG_GNAME,   0, nSTR_GROUP, 'ИТОГО по группе: '|| sOldGROUP);         
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_PLAN, 0, nSTR_GROUP, nGROUP1_P);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_PLAN, 0, nSTR_GROUP, nGROUP2_P);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_PLAN, 0, nSTR_GROUP, nGROUP3_P);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_PLAN, 0, nSTR_GROUP, nGROUP4_P);

              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_FACT, 0, nSTR_GROUP, nGROUP1_F);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_FACT, 0, nSTR_GROUP, nGROUP2_F);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_FACT, 0, nSTR_GROUP, nGROUP3_F);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_FACT, 0, nSTR_GROUP, nGROUP4_F);

              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_REST, 0, nSTR_GROUP, nGROUP1_P - nGROUP1_F);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_REST, 0, nSTR_GROUP, nGROUP2_P - nGROUP2_F);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_REST, 0, nSTR_GROUP, nGROUP3_P - nGROUP3_F);
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_REST, 0, nSTR_GROUP, nGROUP4_P - nGROUP4_F);

              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUMM_PGROUP,  0, nSTR_GROUP, nGROUP_P);   
              PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUMM_FGROUP,  0, nSTR_GROUP, nGROUP_F);   
            
            end if;
            
            nEMPTY_GROUP := 1;
            nGROUP1_P := 0;
            nGROUP2_P := 0;
            nGROUP3_P := 0;
            nGROUP4_P := 0;
            nGROUP1_F := 0;
            nGROUP2_F := 0;
            nGROUP3_F := 0;
            nGROUP4_F := 0; 
            nGROUP_P  := 0;
            nGROUP_F  := 0;
            
            sOldGROUP := cntr.smain_customer;
            P_SELECTLIST_CLEAR(nIDENT_GROUP);
                  
            nSTR_GROUP := PRSG_EXCEL.LINE_CONTINUE(L_GROUP);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sGROUP_NAME, 0, nSTR_GROUP,  'Группа: '||cntr.smain_customer);
           
         end if; 
       
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

    /*      nSumPRJ1_P := 0;
          nSumPRJ1_F := 0;
          nSumPRJ2_P := 0;
          nSumPRJ2_F := 0;
          nSumPRJ3_P := 0;
          nSumPRJ3_F := 0;
          nSumPRJ4_P := 0;
          nSumPRJ4_F := 0;*/
          
          nSUM1_P_in := 0;
          nSUM2_P_in := 0;
          nSUM3_P_in := 0;
          nSUM4_P_in := 0;
          nSUM1_F_in := 0;
          nSUM2_F_in := 0;
          nSUM3_F_in := 0;
          nSUM4_F_in := 0;
          nSUM1_R_in := 0;
          nSUM2_R_in := 0;
          nSUM3_R_in := 0;
          nSUM4_R_in := 0;

          nSUM1_P_out := 0;
          nSUM2_P_out := 0;
          nSUM3_P_out := 0;
          nSUM4_P_out := 0;
          nSUM1_F_out := 0;
          nSUM2_F_out := 0;
          nSUM3_F_out := 0;
          nSUM4_F_out := 0;
          nSUM1_R_out := 0;
          nSUM2_R_out := 0;
          nSUM3_R_out := 0;
          nSUM4_R_out := 0;
            
          nSTR_Cntr := PRSG_EXCEL.LINE_CONTINUE(L_PRJ1);

          PRSG_EXCEL.CELL_VALUE_WRITE(C_sPRJ_RUK,    0, nSTR_Cntr, nvl(UDO_F_PROJECT_Get_AGENT(cntr.nPRJ_RN, 1, dRep_date), cntr.sMain_Ruk));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT_NAME, 0, nSTR_Cntr, cntr.sAGENT_NAME);
     --     PRSG_EXCEL.CELL_VALUE_WRITE(C_sPRJ_CODE,   0, nSTR_Cntr, nvl(cntr.sCONTR_Shefr, sPRJ_Shefr));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sPAY_TYPE,   0, nSTR_Cntr, cntr.sbank_type);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_npp,         0, nSTR_Cntr, nPP);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_PRJ_CODE,    0, nSTR_Cntr, cntr.sCN_NUMB);
          nPP := nPP +1;

      --    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPRJ_CODE,   0, nSTR_B, cntr.doc_numb);
          

          nSTR_Cntr2 := PRSG_EXCEL.LINE_CONTINUE(L_PRJ2);
          nSTR_Cntr3 := PRSG_EXCEL.LINE_CONTINUE(L_PRJ3);
      --    PRSG_EXCEL.CELL_VALUE_WRITE(C_sPRJ_SHEFR,   0, nSTR_Cntr2, '('||UDO_F_FACEACC_GET_SHEFR(cntr.nst_faceacc)||')');
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sPRJ_NAME,    0, nSTR_Cntr2, cntr.sCN_SUBJECT);


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
             from STAGES st, FACEACC fc, PROJECTSTAGE   ps
            where ps.faceacccust (+) = st.faceacc
              and st.prn = cntr.nCN_RN 
              and cntr.nCN_RN is not null
              and fc.rn = st.faceacc
           --   and st.status in (1, 3) --- открыт или  согласован 
              and (exists (select null 
                         from UDO_T_MARK pm 
                        where pm.faceacc = st.faceacc
                          and pm.val <> 0
                          and pm.fpdartcl  in (nARTCLRN_TEMA)
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
                  ,ps.faceacc     as nST_FACEACC
                  ,ps.numb        as sST_NUMB
                  ,ps.name        as sST_Descr
                  ,ps.rn          as nPRST_RN
                  ,ps.faceacc     as nPS_FACEACC
                  ,fc.numb        as sFC_NUMB
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
                          and pm.fpdartcl in (nARTCLRN_KA, nARTCLRN_PKI, nARTCLRN_Proch)
                          and pm.mark_date between dStart_date and dEnd_DATE

              --            and pm.RN = 42797312
                            ) 
              )  ttt                    
              order by ttt.sST_NUMB
          ) loop

            PRSG_EXCEL.CELL_VALUE_WRITE(C_sPRJ_SHEFR,   0, nSTR_Cntr2, UDO_F_FACEACC_GET_SHEFR(nvl(stg.nST_FACEACC, stg.nPS_FACEACC)) );
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sPRJ_CODE,    0, nSTR_Cntr, UDO_F_FACEACC_GET_SHEFR(nvl(stg.nST_FACEACC, stg.nPS_FACEACC))||' ('|| nvl(cntr.sCONTR_Shefr, sPRJ_Shefr)||')'||'['||cntr.scn_numb||']');
          
            nSTR_Staje := PRSG_EXCEL.LINE_CONTINUE(L_STAGE1);

            PRSG_EXCEL.CELL_VALUE_WRITE(C_sStage_NUMB, 0, nSTR_Staje, /*stg.sFC_NUMB||' / '||*/'Этап №'||Trim(stg.sST_NUMB));
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sStage_NAME, 0, nSTR_Staje, stg.sST_Descr);
            /* Для случая серийной поставки */
            stg.nPS_FACEACC := nvl(stg.nPS_FACEACC, UDO_F_STAGES_GET_FACE_PROP(stg.nST_RN));

            CALC_MARK_SUM (
               nlFACE      => stg.nST_FACEACC
              ,nlCost_FACE => null
              ,nlARTCL     => nARTCLRN_TEMA
              ,nlPeriod    => nPeriod
              ,nlSUMM1_P   => nSUMM1_P  
              ,nlSUMM1_F   => nSUMM1_F
              ,nlSUMM2_P   => nSUMM2_P 
              ,nlSUMM2_F   => nSUMM2_F 
              ,nlSUMM3_P   => nSUMM3_P 
              ,nlSUMM3_F   => nSUMM3_F
              ,nlSUMM4_P   => nSUMM4_P
              ,nlSUMM4_F   => nSUMM4_F
              ,nlSUMM_all  => nSUMM
              ,sPrim_art   => sPrim
             );
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_ST_PLAN, 0, nSTR_Staje, nSUMM1_P);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_ST_PLAN, 0, nSTR_Staje, nSUMM2_P);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_ST_PLAN, 0, nSTR_Staje, nSUMM3_P);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_ST_PLAN, 0, nSTR_Staje, nSUMM4_P);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_ST_FACT, 0, nSTR_Staje, nSUMM1_F);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_ST_FACT, 0, nSTR_Staje, nSUMM2_F);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_ST_FACT, 0, nSTR_Staje, nSUMM3_F);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_ST_FACT, 0, nSTR_Staje, nSUMM4_F);

            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_ST_REST, 0, nSTR_Staje, nSUMM1_P - nSUMM1_F);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_ST_REST, 0, nSTR_Staje, nSUMM2_P - nSUMM2_F);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_ST_REST, 0, nSTR_Staje, nSUMM3_P - nSUMM3_F);
            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_ST_REST, 0, nSTR_Staje, nSUMM4_P - nSUMM4_F);

            PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_ST_PLAN,   0, nSTR_Staje, nSUMM);

            nSUM1_P_in := nSUM1_P_in + NVL(nSUMM1_P, 0);
            nSUM2_P_in := nSUM2_P_in + NVL(nSUMM2_P, 0);
            nSUM3_P_in := nSUM3_P_in + NVL(nSUMM3_P, 0);
            nSUM4_P_in := nSUM4_P_in + NVL(nSUMM4_P, 0);
            nSUM1_F_in := nSUM1_F_in + NVL(nSUMM1_F, 0);
            nSUM2_F_in := nSUM2_F_in + NVL(nSUMM2_F, 0);
            nSUM3_F_in := nSUM3_F_in + NVL(nSUMM3_F, 0);
            nSUM4_F_in := nSUM4_F_in + NVL(nSUMM4_F, 0);

            nPrint := 1;

            for nParam in 1..3 loop  
             nArticle :=  case nParam when 1 then nARTCLRN_KA
                                      when 2 then nARTCLRN_Proch
                                      when 3 then nARTCLRN_PKI end;      
            /*обход договоров с КА*/
             for agn in (
               select ag.agnname as sAG_NAME
                     ,btp.code   as sAG_BANK_TYPE
                     ,ast.description as sAG_DESCR
                     ,ast.faceacc     as AGN_FACE
               from CONTRACTS acn
                  , STAGES    ast
                  , AGNLIST   ag
                  , AGNACC    acc
                  , BANKACCTYPES   btp
               where acn.rn = ast.prn
                 and ast.status in (1, 3) --- открыт или  согласован 
                 and ast.faceacc in (select pm.faceacc 
                                     from UDO_T_MARK pm
                                    where pm.cost_faceacc =  stg.nPS_FACEACC
                                      and pm.fpdartcl = nArticle
                                      and pm.faceacc <> stg.nST_FACEACC
                                      and pm.val <> 0
                                      and pm.mark_date between dStart_date and dEnd_DATE)
                 and ag.rn = acn.agent
                 and acc.rn (+) = acn.agnacc
                 and btp.rn (+) = acc.bankacc_type
                   
                 
             ) loop
                if nPrint = 1 then
            --      nSTR_AG := PRSG_EXCEL.LINE_CONTINUE(L_STAGE2);
                  nPrint := 0;
                end if;
                nSTR_AG := PRSG_EXCEL.LINE_CONTINUE(L_AGENT);

                PRSG_EXCEL.CELL_VALUE_WRITE(C_sEXEC_NAME,     0, nSTR_AG, agn.sAG_NAME);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGN_PAY_TYPE,  0, nSTR_AG, agn.sAG_BANK_TYPE);
                CALC_MARK_SUM (
                   nlFACE      => agn.AGN_FACE
                  ,nlCost_FACE => stg.nPS_FACEACC
                  ,nlARTCL     => nArticle
                  ,nlPeriod    => nPeriod
                  ,nlSUMM1_P   => nSUMM1_P  
                  ,nlSUMM1_F   => nSUMM1_F
                  ,nlSUMM2_P   => nSUMM2_P 
                  ,nlSUMM2_F   => nSUMM2_F 
                  ,nlSUMM3_P   => nSUMM3_P 
                  ,nlSUMM3_F   => nSUMM3_F
                  ,nlSUMM4_P   => nSUMM4_P
                  ,nlSUMM4_F   => nSUMM4_F
                  ,nlSUMM_all  => nSUMM
                  ,sPrim_art   => sPrim
                 );

                PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT_PRIM,    0, nSTR_AG, nvl(agn.sAG_DESCR, sPrim)); 
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_AG_PLAN,  0, nSTR_AG, nSUMM1_P);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_AG_PLAN,  0, nSTR_AG, nSUMM2_P);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_AG_PLAN,  0, nSTR_AG, nSUMM3_P);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_AG_PLAN,  0, nSTR_AG, nSUMM4_P);
                
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_AG_FACT,  0, nSTR_AG, nSUMM1_F);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_AG_FACT,  0, nSTR_AG, nSUMM2_F);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_AG_FACT,  0, nSTR_AG, nSUMM3_F);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_AG_FACT,  0, nSTR_AG, nSUMM4_F);

                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_AG_REST,  0, nSTR_AG, nSUMM1_P - nSUMM1_F);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_AG_REST,  0, nSTR_AG, nSUMM2_P - nSUMM2_F);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_AG_REST,  0, nSTR_AG, nSUMM3_P - nSUMM3_F);
                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_AG_REST,  0, nSTR_AG, nSUMM4_P - nSUMM4_F);

                PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_AG_PLAN,  0, nSTR_AG, nSUMM);
          

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
              nArticle :=  case nParam when 1 then nARTCLRN_KA
                                       when 2 then nARTCLRN_Proch
                                       when 3 then nARTCLRN_PKI end;      
             for pki in (
               select sum(pm.val) as sum_tmp
                 from UDO_T_MARK pm
                where pm.cost_faceacc = stg.nPS_FACEACC
                  and pm.faceacc is null
                  and pm.fpdartcl in nArticle
                  and pm.val <> 0
                  and pm.mark_date between dStart_date and dEnd_DATE
             ) loop
               if pki.sum_tmp >0 then
             
                  if nPrint = 1 then
             --       nSTR_AG := PRSG_EXCEL.LINE_CONTINUE(L_STAGE2);
                    nPrint := 0;
                  end if;
                  nSTR_AG := PRSG_EXCEL.LINE_CONTINUE(L_AGENT);
                  if nParam = 1 then
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_sEXEC_NAME,     0, nSTR_AG, 'Соисполнители');
                  elsif nParam = 2 then
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_sEXEC_NAME,     0, nSTR_AG, 'Статья Прочие ');
                  else
                    PRSG_EXCEL.CELL_VALUE_WRITE(C_sEXEC_NAME,     0, nSTR_AG, 'Статья ПКИ');
                  end if;  
                  CALC_MARK_SUM (
                     nlFACE   => null
                    ,nlCost_FACE => stg.nPS_FACEACC
                    ,nlARTCL  => nArticle
                    ,nlPeriod => nPeriod
                    ,nlSUMM1_P => nSUMM1_P  
                    ,nlSUMM1_F => nSUMM1_F
                    ,nlSUMM2_P => nSUMM2_P 
                    ,nlSUMM2_F => nSUMM2_F 
                    ,nlSUMM3_P => nSUMM3_P 
                    ,nlSUMM3_F => nSUMM3_F
                    ,nlSUMM4_P => nSUMM4_P
                    ,nlSUMM4_F => nSUMM4_F
                    ,nlSUMM_all => nSUMM
                    ,sPrim_art  => sPrim
                  );

                  PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT_PRIM,    0, nSTR_AG, sPrim); 
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_AG_PLAN,  0, nSTR_AG, nSUMM1_P);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_AG_PLAN,  0, nSTR_AG, nSUMM2_P);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_AG_PLAN,  0, nSTR_AG, nSUMM3_P);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_AG_PLAN,  0, nSTR_AG, nSUMM4_P);
                  
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_AG_FACT,  0, nSTR_AG, nSUMM1_F);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_AG_FACT,  0, nSTR_AG, nSUMM2_F);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_AG_FACT,  0, nSTR_AG, nSUMM3_F);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_AG_FACT,  0, nSTR_AG, nSUMM4_F);

                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_AG_REST,  0, nSTR_AG, nSUMM1_P - nSUMM1_F);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_AG_REST,  0, nSTR_AG, nSUMM2_P - nSUMM2_F);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_AG_REST,  0, nSTR_AG, nSUMM3_P - nSUMM3_F);
                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_AG_REST,  0, nSTR_AG, nSUMM4_P - nSUMM4_F);

                  PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_AG_PLAN,    0, nSTR_AG, nSUMM);

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
          end loop;
          
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_PLAN,  0, nSTR_Cntr, nSUM1_P_in - nSUM1_P_out);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_PLAN,  0, nSTR_Cntr, nSUM2_P_in - nSUM2_P_out);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_PLAN,  0, nSTR_Cntr, nSUM3_P_in - nSUM3_P_out);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_PLAN,  0, nSTR_Cntr, nSUM4_P_in - nSUM4_P_out);
          
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_FACT,  0, nSTR_Cntr, nSUM1_F_in - nSUM1_F_out);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_FACT,  0, nSTR_Cntr, nSUM2_F_in - nSUM2_F_out);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_FACT,  0, nSTR_Cntr, nSUM3_F_in - nSUM3_F_out);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_FACT,  0, nSTR_Cntr, nSUM4_F_in - nSUM4_F_out);

          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_PLAN_PIN,  0, nSTR_Cntr2, nSUM1_P_in);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_PLAN_PIN,  0, nSTR_Cntr2, nSUM2_P_in);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_PLAN_PIN,  0, nSTR_Cntr2, nSUM3_P_in);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_PLAN_PIN,  0, nSTR_Cntr2, nSUM4_P_in);
          
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_FACT_PIN,  0, nSTR_Cntr2, nSUM1_F_in);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_FACT_PIN,  0, nSTR_Cntr2, nSUM2_F_in);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_FACT_PIN,  0, nSTR_Cntr2, nSUM3_F_in);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_FACT_PIN,  0, nSTR_Cntr2, nSUM4_F_in);

          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_PLAN_POUT,  0, nSTR_Cntr3, nSUM1_P_out);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_PLAN_POUT,  0, nSTR_Cntr3, nSUM2_P_out);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_PLAN_POUT,  0, nSTR_Cntr3, nSUM3_P_out);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_PLAN_POUT,  0, nSTR_Cntr3, nSUM4_P_out);
          
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_FACT_POUT,  0, nSTR_Cntr3, nSUM1_F_out);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_FACT_POUT,  0, nSTR_Cntr3, nSUM2_F_out);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_FACT_POUT,  0, nSTR_Cntr3, nSUM3_F_out);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_FACT_POUT,  0, nSTR_Cntr3, nSUM4_F_out);
          
          nItog1_P := nItog1_P + nSUM1_P_in - nSUM1_P_out;
          nItog2_P := nItog2_P + nSUM2_P_in - nSUM2_P_out;
          nItog3_P := nItog3_P + nSUM3_P_in - nSUM3_P_out;
          nItog4_P := nItog4_P + nSUM4_P_in - nSUM4_P_out;
          
          nItog1_F := nItog1_F + nSUM1_F_in - nSUM1_F_out;
          nItog2_F := nItog2_F + nSUM2_F_in - nSUM2_F_out;
          nItog3_F := nItog3_F + nSUM3_F_in - nSUM3_F_out;
          nItog4_F := nItog4_F + nSUM4_F_in - nSUM4_F_out;
          
          
          nGROUP1_P := nGROUP1_P + nSUM1_P_in - nSUM1_P_out;
          nGROUP2_P := nGROUP2_P + nSUM2_P_in - nSUM2_P_out;
          nGROUP3_P := nGROUP3_P + nSUM3_P_in - nSUM3_P_out;
          nGROUP4_P := nGROUP4_P + nSUM4_P_in - nSUM4_P_out;
          
          nGROUP1_F := nGROUP1_F + nSUM1_F_in - nSUM1_F_out;
          nGROUP2_F := nGROUP2_F + nSUM2_F_in - nSUM2_F_out;
          nGROUP3_F := nGROUP3_F + nSUM3_F_in - nSUM3_F_out;
          nGROUP4_F := nGROUP4_F + nSUM4_F_in - nSUM4_F_out;    
          
          if nGROUP1_P <> 0 or 
             nGROUP2_P <> 0 or 
             nGROUP3_P <> 0 or 
             nGROUP4_P <> 0 or 
             nGROUP1_F <> 0 or 
             nGROUP2_F <> 0 or 
             nGROUP3_F <> 0 or 
             nGROUP4_F <> 0    
           then         
             nEMPTY_GROUP := 0;
           end if;   
         
          nSumPRJ1_P := nSumPRJ1_P + nSumPRJ2_P + nSumPRJ3_P + nSumPRJ4_P;
          nSumPRJ1_F := nSumPRJ1_F + nSumPRJ2_F + nSumPRJ3_F + nSumPRJ4_F;
          
          nGROUP_P := nGROUP_P + nSumPRJ1_P;
          nGROUP_F := nGROUP_F + nSumPRJ1_F;

          nItog_P := nItog_P + nSumPRJ1_P;
          nItog_F := nItog_F + nSumPRJ1_F;

          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PRJ_REST,  0, nSTR_Cntr, nSumPRJ1_P + nSumPRJ1_F);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PRJ_PLAN,  0, nSTR_Cntr, nSumPRJ1_P);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM_PRJ_FACT,  0, nSTR_Cntr, nSumPRJ1_F);

       end loop;
   end loop;
   if nEMPTY_GROUP = 0 then
   /* По последней группе*/   
    nSTR_GROUP := PRSG_EXCEL.LINE_CONTINUE(L_GSUM);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sITOG_GNAME,   0, nSTR_GROUP, 'ИТОГО по группе: '|| sOldGROUP);         
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_PLAN, 0, nSTR_GROUP, nGROUP1_P);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_PLAN, 0, nSTR_GROUP, nGROUP2_P);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_PLAN, 0, nSTR_GROUP, nGROUP3_P);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_PLAN, 0, nSTR_GROUP, nGROUP4_P);
    
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM1_GR_FACT, 0, nSTR_GROUP, nGROUP1_F);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM2_GR_FACT, 0, nSTR_GROUP, nGROUP2_F);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM3_GR_PLAN, 0, nSTR_GROUP, nGROUP3_F);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUM4_GR_FACT, 0, nSTR_GROUP, nGROUP4_F); 
      
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUMM_PGROUP,  0, nSTR_GROUP, nGROUP_P);   
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUMM_FGROUP,  0, nSTR_GROUP, nGROUP_F);   
   end if; 
   
    /* Итоги */
    nSTR_AG := PRSG_EXCEL.LINE_CONTINUE(L_Itog);

    PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog1_P,  0, nSTR_AG, nItog1_P);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog2_P,  0, nSTR_AG, nItog2_P);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog3_P,  0, nSTR_AG, nItog3_P);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog4_P,  0, nSTR_AG, nItog4_P);
    
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog1_F,  0, nSTR_AG, nItog1_F);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog2_F,  0, nSTR_AG, nItog2_F);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog3_F,  0, nSTR_AG, nItog3_F);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog4_F,  0, nSTR_AG, nItog4_F);
    
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog_P,   0, nSTR_AG, nItog_P);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nItog_F,   0, nSTR_AG, nItog_F);

   
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
      
end UDO_RP_BUDJET_CONTRACTS;
/

