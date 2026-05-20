create or replace procedure UDO_P_MARK_COND
/*
   Серверный отбор в разделе "Показатели"
  */
 as
begin
  --установка главной таблицы
  PKG_COND_BROKER.SET_TABLE(STABLE_NAME => 'UDO_T_MARK');
  --юридическое лицо
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE'
                                    ,SCONDITION_NAME => 'JurPers'
                                    ,SJOINS          => 'JUR_PERS <- RN;JURPERSONS');

 --- Группа номенклатор
  PKG_COND_BROKER.SET_GROUP( 'MARKS_NOMEN','UDO_V_MARK_NOMEN','NPRN','RN' );
  
  -- Отбор по номенклатуре 
  ---PKG_COND_BROKER.ADD_GROUP_CONDITION_COMPARE( 'MARKS_NOMEN','snomen_name','=','SNomenName' ); ---строго по значению наименования номенклатуры без спецсимволов
  
  PKG_COND_BROKER.ADD_GROUP_CONDITION_CODE(   'MARKS_NOMEN','NOMEN_NAME','SNomenName','snomen_name <- NOMEN_NAME;DICNOMNS' );

  PKG_COND_BROKER.ADD_GROUP_CONDITION_BETWEEN(sGROUP_NAME => 'MARKS_NOMEN',
                                              sCOLUMN_NAME =>   'NPRICE',
                                              sCONDITION_NAME_FROM => 'nPriceFrom',
                                              sCONDITION_NAME_TO => 'nPriceTo');
                                    
  --версия показателя
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE'
                                    ,SCONDITION_NAME => 'Version'
                                    ,SJOINS          => 'MARK_VERS <- RN;UDO_T_MARK_VERS');
  --тип показателя
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE'
                                    ,SCONDITION_NAME => 'Type'
                                    ,SJOINS          => 'MARK_TYPE <- RN;UDO_T_MARK_TYPE');
  --префикс (диапазон)
  PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'MARK_PREF'
                                       ,SCONDITION_NAME_FROM => 'PrefFrom'
                                       ,SCONDITION_NAME_TO   => 'PrefTo');
  --номер (диапазон)
  PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'MARK_NUMB'
                                       ,SCONDITION_NAME_FROM => 'NumbFrom'
                                       ,SCONDITION_NAME_TO   => 'NumbTo');
  --дата (диапазон)
  PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'MARK_DATE'
                                       ,SCONDITION_NAME_FROM => 'DateFrom'
                                       ,SCONDITION_NAME_TO   => 'DateTo');
  --по состоянию на (диапазон)
  PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'STATE_DATE'
                                       ,SCONDITION_NAME_FROM => 'StateDateFrom'
                                       ,SCONDITION_NAME_TO   => 'StateDateTo');
  --начало периода показателя (диапазон)
  PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'DATE_FROM'
                                       ,SCONDITION_NAME_FROM => 'PeriodStartDateFrom'
                                       ,SCONDITION_NAME_TO   => 'PeriodStartDateTo');
  --окончание периода показателя (диапазон)
  PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'DATE_TO'
                                       ,SCONDITION_NAME_FROM => 'PeriodFinishDateFrom'
                                       ,SCONDITION_NAME_TO   => 'PeriodFinishDateTo');
  --значение
  PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'VAL'
                                       ,SCONDITION_NAME_FROM => 'ValFrom'
                                       ,SCONDITION_NAME_TO   => 'ValTo');
  --валюта
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'INTCODE'
                                    ,SCONDITION_NAME => 'Cur'
                                    ,SJOINS          => 'CURRENCY <- RN;CURNAMES');
  --единица измерения
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'MEAS_MNEMO'
                                    ,SCONDITION_NAME => 'Meas'
                                    ,SJOINS          => 'MEAS <- RN;DICMUNTS');
  --значение в валюте договора (диапазон)
  PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'VAL_ACC'
                                       ,SCONDITION_NAME_FROM => 'ValAccFrom'
                                       ,SCONDITION_NAME_TO   => 'ValAccTo');
  --валюта договора
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'INTCODE'
                                    ,SCONDITION_NAME => 'CurAcc'
                                    ,SJOINS          => 'CURRENCY_ACC <- RN;CURNAMES');
  --значение в валюте платежа (диапазон)
  PKG_COND_BROKER.ADD_CONDITION_BETWEEN(SCOLUMN_NAME         => 'VAL_DOC'
                                       ,SCONDITION_NAME_FROM => 'ValDocFrom'
                                       ,SCONDITION_NAME_TO   => 'ValDocTo');
  --валюта платежа
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'INTCODE'
                                    ,SCONDITION_NAME => 'CurDoc'
                                    ,SJOINS          => 'CURRENCY_DOC <- RN;CURNAMES');
  --подразделение
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE'
                                    ,SCONDITION_NAME => 'Subdiv'
                                    ,SJOINS          => 'SUBDIV <- RN;INS_DEPARTMENT');
  --контрагент
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'AGNABBR'
                                    ,SCONDITION_NAME => 'Agent'
                                    ,SJOINS          => 'AGENT <- RN;AGNLIST');
  --инструмент оплаты
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE'
                                    ,SCONDITION_NAME => 'PayTool'
                                    ,SJOINS          => 'PAYTOOL <- RN;FINPAYTOOL');
  --финансовая операция
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'TYPOPER_MNEMO'
                                    ,SCONDITION_NAME => 'FinOper'
                                    ,SJOINS          => 'FINOPER <- RN;DICTOPER');
  --состояние
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE'
                                    ,SCONDITION_NAME => 'FinState'
                                    ,SJOINS          => 'FINSTATE <- RN;FINSTATE');
  --группа затрат
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE'
                                    ,SCONDITION_NAME => 'CostGroup'
                                    ,SJOINS          => 'COST_GR <- RN;UDO_COSTGR');
  --вид движения
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE'
                                    ,SCONDITION_NAME => 'FinFlowType'
                                    ,SJOINS          => 'FINFLOWTYPE <- RN;FINFLOWTYPE');
  --статья движения
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE'
                                    ,SCONDITION_NAME => 'Art'
                                    ,SJOINS          => 'FPDARTCL <- RN;FPDARTCL');
  --лицевой счет движения
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'NUMB'
                                    ,SCONDITION_NAME => 'FaceAcc'
                                    ,SJOINS          => 'FACEACC <- RN;FACEACC');
  --место возникновения затрат
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE'
                                    ,SCONDITION_NAME => 'CostPlace'
                                    ,SJOINS          => 'COST_PLACE <- RN;FPDACCNT');
  --статья затрат
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'CODE'
                                    ,SCONDITION_NAME => 'CostArt'
                                    ,SJOINS          => 'COST_FPDARTCL <- RN;FPDARTCL');
  --лицевой счет затрат
  PKG_COND_BROKER.ADD_CONDITION_CODE(SCOLUMN_NAME    => 'NUMB'
                                    ,SCONDITION_NAME => 'CostFaceAcc'
                                    ,SJOINS          => 'COST_FACEACC <- RN;FACEACC');
end;
--grant execute on UDO_P_MARK_COND to public;
/
