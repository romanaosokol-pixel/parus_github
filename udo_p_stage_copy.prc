create or replace procedure UDO_P_STAGE_COPY(

NIDENT in number,
nPRJRN in number,
sUNITCODE in varchar


) is
  tPRJST  PROJECTSTAGE%ROWtype;
--  tSTAG   STAGES%ROWtype;
  tPRJCT    PROJECT%ROWtype;
  tFECACC FACEACC%rowtype;
  sBUH_numb  varchar(20);
  nPRJ_RN    number;
  nTMP_RN    number;
  
  nFaceRN  PKG_STD.tREF;
begin
/*  if sUNITCODE = 'Projects' then
   for tPRJST in (
       select ps.*
       -- into tPRJST
        from PROJECTSTAGE ps, SELECTLIST sl
        where ps.rn = sl.document
        and sl.ident = NIDENT
   ) loop 

       sBUH_numb := F_DOCS_PROPS_GET_STR_VALUE(
                              nPROPERTY     => 1076177,              -- Шифр_поБУ
                              sUNITCODE     => 'Projects',           
                              nDOCUMENT     => tPRJST.Prn );
    
       begin
         select *
         into tSTAG 
         from STAGES st
         where st.faceacc = tPRJST.Faceacccust;
       exception when others then
         tSTAG.rn := null;
       end; 
       
       if  tSTAG.rn is not null then
         P_PROJECTSTAGE_BASE_UPDATE
              (
                nRN                       => tPRJST.Rn,            -- Регистрационный номер
                nCOMPANY                  => tPRJST.Company,            -- Организация
                nJUR_PERS                 => tPRJST.Jur_Pers,            -- Юридическое лицо
                sNUMB                     => tSTAG.Numb,          -- Номер
                sNAME                     => nvl(tSTAG.Description, tPRJST.Name),          -- Наименование
                sEXPECTED_RES             => tPRJST.Expected_Res,          -- Ожидаемые результаты
                nFACEACC                  => tPRJST.Faceacc,            -- Лицевой счет затрат
                nGR_PNT_COST              => tPRJST.Gr_Pnt_Cost,            -- Точка графика лицевого счета затрат
                nSUBDIV_RESP              => tPRJST.Subdiv_Resp,            -- Подразделение-ответственный
                nRESPONSIBLE              => tPRJST.Responsible,            -- Ответственный
                nSTATE                    => tPRJST.State,            -- Состояние
                dBEGPLAN                  => tSTAG.Begin_Date,              -- Дата начала план
                dBEGFACT                  => tSTAG.Begin_Date,              -- Дата начала факт
                dENDPLAN                  => tPRJST.Endplan,              -- Дата окончания план
                dENDFACT                  => tPRJST.Endfact,              -- Дата окончания факт
                nCOST_SUM                 => tSTAG.Stage_Sum,            -- Стоимость этапа
                sNOTE                     => 'Перенесено из договора.',          -- Примечание
                dDO_ACT_FROM              => tSTAG.Begin_Date,              -- Действует с
                nRFLCT_HS                 => tPRJST.Rflct_Hs,            -- Отражать в истории изменений
                nLAB_STAG                 => tPRJST.Lab_Stag,            -- Трудоемкость этапа
                nLAB_PLAN                 => tPRJST.Lab_Plan,            -- Трудоемкость план
                nLAB_FACT                 => tPRJST.Lab_Fact,            -- Трудоемкость факт
                nLAB_PART                 => tPRJST.Lab_Part,            -- % выполнения по трудоемкости
                nLAB_MEAS                 => tPRJST.Lab_Meas,            -- ЕИ трудоемкости
                sCHNG_BASE                => tPRJST.Chng_Base,          -- Основание изменения
                nFACEACCCUST              => tPRJST.Faceacccust,            -- Лицевой счет заказчика
                nGR_PNT_CUST              => tPRJST.Gr_Pnt_Cust,            -- Точка графика лицевого счета заказчика
                nCOST_CALC_TYPE           => tPRJST.Cost_Calc_Type,            -- Расчет затрат
                nLAB_CALC_TYPE            => tPRJST.Lab_Calc_Type,            -- Расчет трудоемкости
                nLAB_UNITCOST             => tPRJST.Lab_Unitcost,            -- Стоимость единицы трудоемкости
                nLAB_CURRENCY             => tPRJST.Lab_Currency,            -- Валюта трудоемкости
                nCOST_SUM_BASECURR        => tSTAG.Stage_Sum,            -- Стоимость в базовой валюте
                nPLANE_RATE               => tPRJST.Plane_Rate,            -- Плановый курс
                nCOST_PLAN                => tPRJST.Cost_Plan,            -- Сумма затрат план
                nCOST_FACT                => tPRJST.Cost_Fact             -- Сумма затрат факт
              );
          
         if sBUH_numb is not null then  
           begin  
              update FACEACC fc
              set fc.numb = trim(sBUH_numb)||'/'||trim(tSTAG.Numb)
              where fc.rn = tPRJST.Faceacc;    
           exception when others then
             null;
           end;
         end if; 
       end if; 
     end loop;
   end if;*/
   if sUNITCODE = 'Contracts' then
 /*     sBUH_numb := F_DOCS_PROPS_GET_STR_VALUE(
                      nPROPERTY     => 1076177,              -- Шифр_поБУ
                      sUNITCODE     => 'Contracts',           
                      nDOCUMENT     => NIDENT );
     if sBUH_numb is null then
       p_exception(0,'Не заполнено свойство Шифр по БУ!!');
     end if;     */
     
     nPRJ_RN := nPRJRN;
     
     if nPRJ_RN is not null then
       
       select pr.*
        into tPRJCT
        from PROJECT pr
        where pr.rn = nPRJ_RN;
        
        sBUH_numb := trim(tPRJCT.Code);  
             
       for stg in (
           select st.*          
            from STAGES st
            where st.prn = NIDENT
       ) loop 

          select fc.*
          into tFECACC
          from FACEACC fc
          where fc.rn = stg.Faceacc;
            
          tPRJST.rn := null;
          begin
            select prst.*
              into tPRJST
              from PROJECTSTAGE prst
             where prst.faceacccust = stg.faceacc;
          exception when others then
            tPRJST.rn := null;
          end;  
          if tPRJST.rn is null then
            begin
              select prs.*
              into tPRJST
              from PROJECTSTAGE prs
              where prs.prn = nPRJ_RN
              and trim(prs.numb) = trim(stg.Numb); 
            exception when others then
              tPRJST.rn := null;
            end;           
          end if;

        /* Если этапа проекта нет то добавим */
         if tPRJST.rn is null then 
          /*UDO_P_STAGE_COPY сходим за ШПЗ в свойство этапа договора */
          tPRJST.Faceacc := UDO_F_STAGES_GET_FACE_PROP(stg.rn);
          /* Проверим ЛС по мнемокоду */
          if tPRJST.Faceacc is null then
            begin 
              select fc.rn
              into tPRJST.Faceacc
              from FACEACC fc 
              where fc.numb = trim(sBUH_numb) ||'/'||trim(stg.Numb)
              and fc.company = stg.company;
            exception when others then
              tPRJST.Faceacc := null;
            end;   
          end if;
         
          /* если ШПЗ пустой то добавим ЛС */
          if tPRJST.Faceacc is null then         
           P_FACEACC_BASE_INSERT(
                    nCOMPANY         => stg.company,
                    nCRN             => 12047553,
                    nJUR_PERS        => stg.jur_pers,
                    nPRN             => null,
                    nAGENT           => 92146,
                    nFINERULE        => null,
                    sNUMBER          => trim(sBUH_numb) ||'/'||trim(stg.Numb),
                    nACC_KIND        => 1,
                    nACC_CLASS       => 3,
                    nOPER_FLAG       => 0,
                    nSIGN_CONTRACT   => 0,
                    nSIGN_STAGE      => 0,
                    nORDER_SIGN      => 0,
                    nVALID_DOCTYPE   => null,
                    sVALID_DOCNUMB   => null,
                    dVALID_DOCDATE   => null,
                    dPLAN_OPEN_DATE  => stg.begin_date,
                    dFACT_OPEN_DATE  => null,
                    dPLAN_CLOSE_DATE => stg.end_date,
                    dFACT_CLOSE_DATE => null,
                    nEXECUTIVE       => null,
                    nCURRENCY        => 91318,
                    nCREDIT_SUM      => 0,
                    nBEGIN_SUM       => 0,
                    nCURRENT_SUM     => 0,
                    nPLAN_SUM        => 0,
                    nFCACGR          => null,
                    nAGNACC          => 1027894,-- cc.agnacc,
                    nAGNFI           => tFECACC.Agnfi,
                    nAGNFO           => tFECACC.Agnfo,
                    nAGN_TRANS       => tFECACC.Agn_Trans,
                    nSUBDIV          => tFECACC.Subdiv,
                    nTARIF           => tFECACC.Tarif,
                    nDISCOUNT        => tFECACC.Discount,
                    nPAY_TYPE        => tFECACC.Pay_Type,
                    nSHIP_TYPE       => tFECACC.Ship_Type,
                    nPRICE_TYPE      => tFECACC.Price_Type,
                    dPRICE_DATE      => tFECACC.Price_Date,
                    nSIGNTAX         => 0,
                    nSAME_NOMN       => 0,
                    nDOC_SERV        => 0,
                    nPLAN_SERV       => 0,
                    nFACT_SERV       => 0,
                    nDOC_SHIP        => 0,
                    nPLAN_SHIP       => 0,
                    nFACT_SHIP       => 0,
                    nDOC_INCOME      => 0,
                    nPLAN_INCOME     => 0,
                    nFACT_INCOME     => 0,
                    nFACT_DEFICIT    => 0,
                    nDOC_POSTED      => 0,
                    nPLAN_POSTED     => 0,
                    nFACT_POSTED     => 0,
                    nDOC_PAYED       => 0,
                    nPLAN_PAYED      => 0,
                    nFACT_PAYED      => 0,
                    nFINACCNT        => null,
                    nRESPMANAGER     => null,
                    nIEELEMENT       => null,
                    nFINSOURCE       => null,
                    nPAYTOOL         => null,
                    nPAYPRIOR        => null,
                    nPAYRULE         => null,
                    nCHECK_BAL_SIGN  => 0,
                    nSPEC_MARK       => null,
                    nBUDGEXPEND_SP   => null,
                    nSERV_SUM        => 0,
                    nSERV_PERCENT    => 0,
                    nFINPLANREST     => 0,
                    sNOTE            => null,
                    nEXPSTRUCT       => null,
                    nINCOMECLASS     => null,
                    nECONCLASS       => null,
                    nDICBUNTS        => null ,
                    nACCFNDSRC       => null,
                    nGOVCNTRID       => null,
                    nADDR_AGENT      => tFECACC.Addr_Agent,
                    nADDR_AGNACC     => tFECACC.addr_agnacc,
                    nRN              => tPRJST.Faceacc);

               /* Проверка после добавления лицевого счёта */
              usr_pkg_faceacc.faceacc_ainsert(nrn => tPRJST.Faceacc, ncompany => stg.company);

             end if;     



            
          /*Добавим этап*/
           P_PROJECTSTAGE_BASE_INSERT
                (
                  nCOMPANY                  => stg.Company,      -- Организация
                  nPRN                      => nPRJ_RN,
                  nHRN                      => null,
                  sNUMB                     => trim(stg.Numb),   -- Номер
                  sNAME                     => nvl(stg.Description,'Добавлено автоматически'),          -- Наименование
                  sEXPECTED_RES             => stg.Description,  -- Ожидаемые результаты
                  nFACEACC                  => tPRJST.Faceacc,   -- Лицевой счет затрат
                  nGR_PNT_COST              => null,             -- Точка графика лицевого счета затрат
                  nSUBDIV_RESP              => null,             -- Подразделение-ответственный
                  nRESPONSIBLE              => null,             -- Ответственный
                  nSTATE                    => 0,                -- Состояние
                  dBEGPLAN                  => stg.begin_date,   -- Дата начала план
                  dBEGFACT                  => null,             -- Дата начала факт
                  dENDPLAN                  => stg.end_date,     -- Дата окончания план
                  dENDFACT                  => null,             -- Дата окончания факт
                  nCOST_SUM                 => 0,    -- Стоимость этапа
                  sNOTE                     => 'Перенесено из договора.',          -- Примечание
                  dDO_ACT_FROM              => stg.Begin_Date,   -- Действует с
                  nRFLCT_HS                 => 1,                -- Отражать в истории изменений
                  nLAB_STAG                 => 0,                -- Трудоемкость этапа
                  nLAB_PLAN                 => 0,                -- Трудоемкость план
                  nLAB_FACT                 => 0,                -- Трудоемкость факт
                  nLAB_PART                 => 0,                -- % выполнения по трудоемкости
                  nLAB_MEAS                 => 510349,           -- ЕИ трудоемкости
                  sCHNG_BASE                => 0,                -- Основание изменения
                  nFACEACCCUST              => stg.Faceacc,      -- Лицевой счет заказчика
                  nGR_PNT_CUST              => null,             -- Точка графика лицевого счета заказчика
                  nCOST_CALC_TYPE           => 0,                -- Расчет затрат
                  nLAB_CALC_TYPE            => 0,                -- Расчет трудоемкости
                  nLAB_UNITCOST             => null,             -- Стоимость единицы трудоемкости
                  nLAB_CURRENCY             => null,             -- Валюта трудоемкости
                  nCOST_SUM_BASECURR        => 0,                -- Стоимость в базовой валюте
                  nPLANE_RATE               => 0,                -- Плановый курс
                  nCOST_PLAN                => 0,                -- Сумма затрат план
                  nCOST_FACT                => 0,                -- Сумма затрат факт
                  nRN                       => tPRJST.Rn         -- Регистрационный номер
                );  
         elsif tPRJST.State not in (2) then
           null;
           P_PROJECTSTAGE_BASE_UPDATE
                (
                  nRN                       => tPRJST.Rn,                 -- Регистрационный номер
                  nCOMPANY                  => tPRJST.Company,            -- Организация
                  nJUR_PERS                 => tPRJST.Jur_Pers,           -- Юридическое лицо
                  sNUMB                     => trim(stg.Numb),          -- Номер
                  sNAME                     => nvl(stg.Description, tPRJST.Name),          -- Наименование
                  sEXPECTED_RES             => tPRJST.Expected_Res,       -- Ожидаемые результаты
                  nFACEACC                  => tPRJST.Faceacc,            -- Лицевой счет затрат
                  nGR_PNT_COST              => tPRJST.Gr_Pnt_Cost,        -- Точка графика лицевого счета затрат
                  nSUBDIV_RESP              => tPRJST.Subdiv_Resp,        -- Подразделение-ответственный
                  nRESPONSIBLE              => tPRJST.Responsible,        -- Ответственный
                  nSTATE                    => tPRJST.State,              -- Состояние
                  dBEGPLAN                  => stg.begin_date,            -- Дата начала план
                  dBEGFACT                  => null,                      -- Дата начала факт
                  dENDPLAN                  => stg.end_date,              -- Дата окончания план
                  dENDFACT                  => null,                      -- Дата окончания факт
                  nCOST_SUM                 => 0,                         -- Стоимость этапа
                  sNOTE                     => 'Перенесено из договора.',          -- Примечание
                  dDO_ACT_FROM              => stg.Begin_Date,            -- Действует с
                  nRFLCT_HS                 => tPRJST.Rflct_Hs,           -- Отражать в истории изменений
                  nLAB_STAG                 => tPRJST.Lab_Stag,           -- Трудоемкость этапа
                  nLAB_PLAN                 => tPRJST.Lab_Plan,           -- Трудоемкость план
                  nLAB_FACT                 => tPRJST.Lab_Fact,           -- Трудоемкость факт
                  nLAB_PART                 => tPRJST.Lab_Part,           -- % выполнения по трудоемкости
                  nLAB_MEAS                 => tPRJST.Lab_Meas,           -- ЕИ трудоемкости
                  sCHNG_BASE                => tPRJST.Chng_Base,          -- Основание изменения
                  nFACEACCCUST              => stg.Faceacc,               -- Лицевой счет заказчика
                  nGR_PNT_CUST              => null,                      -- Точка графика лицевого счета заказчика
                  nCOST_CALC_TYPE           => tPRJST.Cost_Calc_Type,     -- Расчет затрат
                  nLAB_CALC_TYPE            => tPRJST.Lab_Calc_Type,      -- Расчет трудоемкости
                  nLAB_UNITCOST             => tPRJST.Lab_Unitcost,       -- Стоимость единицы трудоемкости
                  nLAB_CURRENCY             => tPRJST.Lab_Currency,       -- Валюта трудоемкости
                  nCOST_SUM_BASECURR        => 0,                         -- Стоимость в базовой валюте
                  nPLANE_RATE               => tPRJST.Plane_Rate,         -- Плановый курс
                  nCOST_PLAN                => tPRJST.Cost_Plan,          -- Сумма затрат план
                  nCOST_FACT                => tPRJST.Cost_Fact           -- Сумма затрат факт
                );
         end if; 

         for cc in (select * from UDO_V_CO_EXECUTORS ut where ut.nprn = stg.faceacc) loop
           null;
           /* Проверим на наличие соисполнителя с этим ЛС в этапе проекта */
           begin
             select pt.rn
             into nTMP_RN
             from PROJECTSTAGEPF pt
             where pt.prn = tPRJST.Rn
               and pt.faceacc = cc.nfaceacc;
           exception when others then
             nTMP_RN := null;
           end;  
           /* Если тако КА с ЛС нет, то добавим PROJECTSTAGEPF */
           if nTMP_RN is null then 
             p_PROJECTSTAGEPF_base_insert (
                        nCOMPANY        => stg.COMPANY,   -- Организация
                        nPRN            => tPRJST.Rn,     -- Родитель
                        nSUBDIV         => null,          -- Подразделение-исполнитель
                        nPERFORMER      => cc.nagent,      -- Внешний исполнитель
                        nHEAD_SIGN      => 0,             -- Признак головного исполнителя
                        nLABOUR         => 0,             -- Трудоемкость этапа
                        nPERCENT        => 0,             -- % участия
                        sREASON         => null,          -- Основание
                        nFACEACC        => cc.nfaceacc,   -- Лицевой счет внешнего исполнителя
                        nGRAPH_POINT    => null,          -- Точка графика лицевого счета внешнего исполнителя
                        nCOST_ARTICLE   => null,          -- Статья затрат
                        nCOST_PLAN      => 0,             -- Сумма затрат план
                        nRN             => nTMP_RN        -- Регистрационный номер
                      );
           end if;                          
         end loop;         
               
       end loop;
     end if;
   end if;
end UDO_P_STAGE_COPY;
/
