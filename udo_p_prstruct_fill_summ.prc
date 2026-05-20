create or replace procedure UDO_P_PRSTRUCT_FILL_SUMM
(
NRN in number -- RN записи
)
as
  nSumm number (17,2);
  nSTAGE_RN number;
  RES PROJECTSTAGE%rowtype;
begin
   select pst.summ, pst.prn
   into nSumm, nSTAGE_RN
   from UDO_PRJSTG_PRSTRUCT pst
   where pst.rn = NRN;

   select *
   into RES
   from PROJECTSTAGE ps
   where ps.rn = nSTAGE_RN;

   RES.COST_SUM           := nSumm;
   RES.COST_SUM_BASECURR  := nSumm;

    P_PROJECTSTAGE_BASE_UPDATE
    (
       nRN                       => RES.RN               --in number,            -- Регистрационный номер
      ,nCOMPANY                  => RES.COMPANY          --in number,            -- Организация
      ,nJUR_PERS                 => RES.JUR_PERS         --in number,            -- Юридическое лицо
      ,sNUMB                     => RES.NUMB             --in varchar2,          -- Номер
      ,sNAME                     => RES.NAME             --in varchar2,          -- Наименование
      ,sEXPECTED_RES             => RES.EXPECTED_RES     --in varchar2,          -- Ожидаемые результаты
      ,nFACEACC                  => RES.FACEACC          --in number,            -- Лицевой счет затрат
      ,nGR_PNT_COST              => RES.GR_PNT_COST      --in number,            -- Точка графика лицевого счета затрат
      ,nSUBDIV_RESP              => RES.SUBDIV_RESP      --in number,            -- Подразделение-ответственный
      ,nRESPONSIBLE              => RES.RESPONSIBLE      --in number,            -- Ответственный
      ,nSTATE                    => RES.STATE            --in number,            -- Состояние
      ,dBEGPLAN                  => RES.BEGPLAN          --in date,              -- Дата начала план
      ,dBEGFACT                  => RES.BEGFACT          --in date,              -- Дата начала факт
      ,dENDPLAN                  => RES.ENDPLAN          --in date,              -- Дата окончания план
      ,dENDFACT                  => RES.ENDFACT          --in date,              -- Дата окончания факт
      ,nCOST_SUM                 => RES.COST_SUM         --in number,            -- Стоимость этапа
      ,sNOTE                     => RES.NOTE             --in varchar2,          -- Примечание
      ,dDO_ACT_FROM              => RES.DO_ACT_FROM      --in date,              -- Действует с
      ,nRFLCT_HS                 => RES.RFLCT_HS         --in number,            -- Отражать в истории изменений
      ,nLAB_STAG                 => RES.LAB_STAG         --in number,            -- Трудоемкость этапа
      ,nLAB_PLAN                 => RES.LAB_PLAN         --in number,            -- Трудоемкость план
      ,nLAB_FACT                 => RES.LAB_FACT         --in number,            -- Трудоемкость факт
      ,nLAB_PART                 => RES.LAB_PART         --in number,            -- % выполнения по трудоемкости
      ,nLAB_MEAS                 => RES.LAB_MEAS         --in number,            -- ЕИ трудоемкости
      ,sCHNG_BASE                => RES.CHNG_BASE        --in varchar2,          -- Основание изменения
      ,nFACEACCCUST              => RES.FACEACCCUST      --in number,            -- Лицевой счет заказчика
      ,nGR_PNT_CUST              => RES.GR_PNT_CUST      --in number,            -- Точка графика лицевого счета заказчика
      ,nCOST_CALC_TYPE           => RES.COST_CALC_TYPE   --in number,            -- Расчет затрат
      ,nLAB_CALC_TYPE            => RES.LAB_CALC_TYPE    --in number,            -- Расчет трудоемкости
      ,nLAB_UNITCOST             => RES.LAB_UNITCOST     --in number,            -- Стоимость единицы трудоемкости
      ,nLAB_CURRENCY             => RES.LAB_CURRENCY     --in number,            -- Валюта трудоемкости
      ,nCOST_SUM_BASECURR        => RES.COST_SUM_BASECURR    --in number,            -- Стоимость в базовой валюте
      ,nPLANE_RATE               => RES.PLANE_RATE       --in number,            -- Плановый курс
      ,nCOST_PLAN                => RES.COST_PLAN        --in number,            -- Сумма затрат план
      ,nCOST_FACT                => RES.COST_FACT        --in number             -- Сумма затрат факт
    );

end UDO_P_PRSTRUCT_FILL_SUMM;
/

