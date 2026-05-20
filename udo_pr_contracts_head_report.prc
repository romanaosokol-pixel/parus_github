create or replace procedure UDO_PR_CONTRACTS_HEAD_REPORT
(
nCompany in number,
nIDENT   in number,
sUser    in varchar,
NStage   in number,          --- 1 Печать этапов
nPrint_PRJ  in number,
nPRODACT    in number default 0
) as

  ----Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'Лист1'; -- Лист

  LL_CONTR    constant PKG_STD.TSTRING := 'L_CONTR';
  LL_Stages   constant PKG_STD.TSTRING := 'L_Stages';
  LL_Stage_H  constant PKG_STD.TSTRING := 'L_Stage_H';
  LL_Contr_H  constant PKG_STD.TSTRING := 'L_Contr_H';

  C_sCONTR_NAME         constant PKG_STD.TSTRING := 'sCONTR_NAME';
  C_CONTR_NUMBER        constant PKG_STD.TSTRING := 'CONTR_NUMBER';
  C_CONTR_TYPE          constant PKG_STD.TSTRING := 'CONTR_TYPE';
  C_CONTR_AGENT         constant PKG_STD.TSTRING := 'CONTR_AGENT';
  C_CONTR_DOGNUMB       constant PKG_STD.TSTRING := 'CONTR_DOGNUMB';
  C_CONTR_ORDER         constant PKG_STD.TSTRING := 'CONTR_ORDER';
  C_CONTR_MAINRUK       constant PKG_STD.TSTRING := 'CONTR_MAINRUK';
  C_CONTR_RUK           constant PKG_STD.TSTRING := 'CONTR_RUK';
  C_CONTR_ECONOM        constant PKG_STD.TSTRING := 'CONTR_ECONOM';
  C_ORDER_URIST         constant PKG_STD.TSTRING := 'ORDER_URIST';
  C_CONTRACTS_DATE      constant PKG_STD.TSTRING := 'CONTRACTS_DATE';
  C_CONTR_TKPA          constant PKG_STD.TSTRING := 'CONTR_TKPA';
  C_CONTR_ZAM_GK        constant PKG_STD.TSTRING := 'CONTR_ZAM_GK';
  C_CONTR_PRODUCT       constant PKG_STD.TSTRING := 'CONTR_PRODUCT';

  C_STAGE_NAME          constant PKG_STD.TSTRING := 'STAGE_NAME';
  C_STEGE_NUMER         constant PKG_STD.TSTRING := 'STEGE_NUMER';
  C_STAGE_dSTART        constant PKG_STD.TSTRING := 'STAGE_dSTART';
  C_STAGE_dEND          constant PKG_STD.TSTRING := 'STAGE_dEND';
  C_STAGE_STATUS        constant PKG_STD.TSTRING := 'STAGE_STATUS';
  C_STAGE_STATE         constant PKG_STD.TSTRING := 'STAGE_STATE';
  C_STAGE_PRODUCT       constant PKG_STD.TSTRING := 'STAGE_PRODUCT';



  nSTR       number(17) := 1;
  dRep_date  date;
  sPRJ_TYPE PRJTYPE.NAME%type;
  sTransCust PKG_STD.tSTRING;
  nNumb      number:=0;
  sTKPA      Agnlist.Agnname%type;
  sPRODUCT      PKG_STD.tSTRING;
  sSTRING_TMP   PKG_STD.tSTRING;

 /*function Get_AGENT(
    nlRN        in number,
    nlRole      in number,
    dlRep_DATE  date
    ) return varchar
  as

    slAGENT       AGNLIST.FULLNAME%type;
  begin
    for rp in(
     select pex.sAGNABBR
       from UDO_V_PRJEXEC_LIST pex
       where pex.nPRN = nlRN
         and pex.nEXEC_ROLE = nlRole  -- Ответственный за ТКПА
         and dlRep_DATE between pex.dBEG_DATE and nvl(pex.dEND_DATE, dlRep_DATE)
    ) loop
      if slAGENT is null then
       slAGENT := rp.sAGNABBR;
      else
        if length(slAGENT||'; '||rp.sAGNABBR) <= 1000 then
         slAGENT := slAGENT||'; '||rp.sAGNABBR;
        else
          return (slAGENT);
        end if;
      end if;

    end loop;
     return (slAGENT);
  end ;
*/

begin

  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);



      -- Описываем ячейки спецификации
      PRSG_EXCEL.LINE_DESCRIBE(LL_CONTR_H);
      PRSG_EXCEL.LINE_DESCRIBE(LL_CONTR);

      -- Описываем имена ячеек в шапке и подвале
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_sCONTR_NAME);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_CONTR_NUMBER);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_CONTR_TYPE);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_CONTR_AGENT);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_CONTR_DOGNUMB);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_CONTR_ORDER);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_CONTR_MAINRUK);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_CONTR_RUK);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_CONTR_ECONOM);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_ORDER_URIST);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_CONTRACTS_DATE);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_CONTR_TKPA);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_CONTR_ZAM_GK);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_CONTR, C_CONTR_PRODUCT);


      -- Описываем ячейки спецификации
      PRSG_EXCEL.LINE_DESCRIBE(LL_Stages);
      PRSG_EXCEL.LINE_DESCRIBE(LL_Stage_H);

      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_Stages, C_STAGE_NAME);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_Stages, C_STEGE_NUMER);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_Stages, C_STAGE_dSTART);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_Stages, C_STAGE_dEND);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_Stages, C_STAGE_STATUS);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_Stages, C_STAGE_STATE);
      PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_Stages, C_STAGE_PRODUCT);


dRep_date := sysdate;

  for cnt in (select  cn.nrn  as nContr_RN
                     ,null    as nPROJ_RN
                     ,cn.sdoc_pref
                     ,cn.sdoc_type
                     ,cn.sext_number
                     ,cn.sdoc_numb
                     ,cn.ssubject
                     ,cn.sAGENTNAME as sagent
                     ,cn.sexecutive
                     ,cn.ddoc_date
                     ,F_DOCS_PROPS_GET_DATE_VALUE
                              (
                                nPROPERTY     => 7359001,              --Дата приказа
                                sUNITCODE     => 'Contracts',
                                nDOCUMENT     => cn.nRN ) as dORDER
                     ,F_DOCS_PROPS_GET_STR_VALUE
                              (
                                nPROPERTY     => 7358999,              -- приказа
                                sUNITCODE     => 'Contracts',
                                nDOCUMENT     => cn.nRN ) as sORDER

                     ,F_DOCS_PROPS_GET_STR_VALUE
                              (
                                nPROPERTY     => 1082887,              --Экономист ПЭО
                                sUNITCODE     => 'Contracts',
                                nDOCUMENT     => cn.nRN ) as sECONOM
                     ,F_DOCS_PROPS_GET_STR_VALUE
                              (
                                nPROPERTY     => 1076177,              --Шифр по БУ 1076177
                                sUNITCODE     => 'Contracts',
                                nDOCUMENT     => cn.nRN ) as sID_Buh
                     ,F_DOCS_PROPS_GET_STR_VALUE
                              (
                                nPROPERTY     => 7359003,              -- Заместитель ГД
                                sUNITCODE     => 'Contracts',
                                nDOCUMENT     => cn.nRN ) as sMain_Ruk
                     ,F_DOCS_PROPS_GET_STR_VALUE
                              (
                                nPROPERTY     => 11844373,              --Ответственный за ТКПА 11844373
                                sUNITCODE     => 'Contracts',
                                nDOCUMENT     => cn.nRN )  as sTKPA

                     ,UDO_F_GET_USL_NAME(cn.nrn)  as sUSL_Name
                     ,(select count (ppr.rn) from PROJECTSTAGE ppr, STAGES sst where sst.prn = cn.nrn and sst.faceacc = ppr.faceacccust) as nCProJ
                     ,(select count (sst.rn) from STAGES sst where sst.prn = cn.nrn 
                                 and F_DOCS_PROPS_GET_STR_VALUE
                                        (
                                          nPROPERTY     => 12047550,              --ШПЗ 12047550
                                          sUNITCODE     => 'ContractsStages',
                                          nDOCUMENT     => sst.RN ) is not null)  as nCSer
                     , F_DOCS_PROPS_GET_STR_VALUE
                                        (
                                          nPROPERTY     => 1076177,              --Шифр по БУ
                                          sUNITCODE     => 'Contracts',
                                          nDOCUMENT     => cn.nRN )               as scKomers                     
                from V_CONTRACTS cn 
                where cn.dbegin_date <= dRep_date
                  and (nPRODACT = 0 and exists (select null from SELECTLIST sl where sl.ident = nIDENT and cn.nrn =  sl.document) or
                       nPRODACT = 1 and (   exists (select null from PRODUCTORD prd, STAGES stg where prd.faceacc = UDO_F_STAGES_GET_FACE_PROP(stg.rn) and stg.prn = cn.nrn)
                                         or exists (select null from PRODUCTORD prd, STAGES stg,PROJECTSTAGE pst where prd.faceacc = pst.faceacc and pst.faceacccust = stg.faceacc and stg.prn = cn.nrn) )  )
                  and cn.ncompany = nCompany
                  and cn.nstatus <> 2 -- договор НЕ закрыт
                  and exists (select null from STAGES st, FACEACC fc where st.prn = cn.nrn and fc.rn = st.faceacc and fc.ACC_KIND = 1)
                  /*Продажа товаров вСНГ, Темат. доходы_Б*/
                  and (exists (select null from STAGES sst, FACEACC ffc where sst.prn = cn.nrn and sst.faceacc = ffc.rn and ffc.ieelement in (6172140, 6172145)) )
                  and (F_DOCS_PROPS_GET_STR_VALUE
                              (
                                nPROPERTY     => 1082887,              --Сотрудник ПЭО
                                sUNITCODE     => 'Contracts',
                                nDOCUMENT     => cn.nRN ) = sUser or sUser is null)

            union
          /* Инициативные работы. Проекты без договора */
              select null                 as nContr_RN
                     ,prj.nrn             as nPROJ_RN
                     ,null                as sdoc_pref
                     ,pt.name             as sdoc_type
                     ,null                as sext_number
                     ,null                as sdoc_numb
                     ,prj.sname           as ssubject
                     ,ag.agnname          as sagent
                     ,prj.sresponsible    as sexecutive
                     ,prj.dbegplan         as ddoc_date
                     ,F_DOCS_PROPS_GET_DATE_VALUE
                              (
                                nPROPERTY     => 7359001,              --Дата приказа
                                sUNITCODE     => 'Projects',
                                nDOCUMENT     => prj.nRN ) as dORDER

                     ,F_DOCS_PROPS_GET_STR_VALUE
                              (
                                nPROPERTY     => 7358999,              -- приказа
                                sUNITCODE     => 'Projects',
                                nDOCUMENT     => prj.nRN ) as sORDER

                     ,F_DOCS_PROPS_GET_STR_VALUE
                              (
                                nPROPERTY     => 1082887,              --Экономист ПЭО
                                sUNITCODE     => 'Projects',
                                nDOCUMENT     => prj.nRN ) as sECONOM
                     ,F_DOCS_PROPS_GET_STR_VALUE
                              (
                                nPROPERTY     => 1076177,              --Шифр по БУ 1076177
                                sUNITCODE     => 'Projects',
                                nDOCUMENT     => prj.nRN ) as sID_Buh

                     ,null   as sMain_Ruk
                     ,null   as sTKPA


                     ,prj.sname_usl     as sUSL_Name
                     ,0
                     ,0
                     ,null
                from v_PROJECT    prj, PRJTYPE pt, AGNLIST ag
                where nvl(prj.dbegplan,dRep_date) <= dRep_date
                  and prj.ncompany  = nCompany
                  and prj.nprjtype = pt.rn
                  and ag.rn (+) = prj.next_cust
--and prj.nRN = 6864740
                  and nPrint_PRJ = 1
                  and prj.nstate <> 3 -- проект НЕ закрыт
                  and not exists (select null from PROJECTSTAGE pst where pst.prn = prj.nrn and pst.faceaccCUST is not null )
                  and (F_DOCS_PROPS_GET_STR_VALUE
                              (
                                nPROPERTY     => 1082887,              --Сотрудник ПЭО
                                sUNITCODE     => 'Projects',
                                nDOCUMENT     => prj.nRN ) = sUser or sUser is null)


             )
  loop

      if cnt.sdoc_pref is not null then
        cnt.sext_number := cnt.sext_number||' ('||trim(cnt.sdoc_pref)||'-'||trim(cnt.sdoc_numb)||')';
      end if;

      if cnt.nContr_RN is not null then
        begin
          select distinct prs.prn
          into cnt.nPROJ_RN
            from PROJECTSTAGE prs,
                 STAGES       st
           where prs.faceacccust = st.faceacc
             and st.prn = cnt.nContr_RN
             /*and rownum = 1*/;
        exception when NO_DATA_FOUND then
          null;
        when others then
          p_exception(0,' err. '|| cnt.nContr_RN||' - '||error_text);
        end;
      end if;

      begin
       select distinct pt.name
         into sPRJ_TYPE
         from project pr, PRJTYPE pt
        where PR.RN = cnt.nPROJ_RN
          and pt.rn = pr.prjtype;
      exception when NO_DATA_FOUND then
        sPRJ_TYPE := null;
      end;

  --    sPRJ_TYPE := nvl(sPRJ_TYPE, cnt.sdoc_type);
      
      if cnt.ncproj > 0 then 
        sPRJ_TYPE := 'НИОКР- '||sPRJ_TYPE;
      elsif cnt.ncser > 0 then
        sPRJ_TYPE := 'Поставка - '|| cnt.sdoc_type;
      elsif cnt.sckomers is not null then
         sPRJ_TYPE := 'Ком. - '|| cnt.sdoc_type;
      else
        sPRJ_TYPE := null;
      end if;   
      

      if NStage = 1 or nNumb = 0 then
        nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_CONTR_H);
      end if;
      nNumb := 1;

      /* Оставим ответственных только из проекта*/
      if cnt.nPROJ_RN is not null then
        cnt.sMain_Ruk  := null;
        cnt.sTKPA      := null;
        cnt.sexecutive := null;
      end if;

      sPRODUCT := null;
      if cnt.nPROJ_RN is not null then
        for sh in (
          select sum(sht.nQUANT_PLAN) as nQUANT_PLAN,
                 sht.sNOMEN_NAME
          from UDO_V_PROJECTSTAGE_SHT sht
              ,PROJECTSTAGE           pst
          where pst.PRN = cnt.nPROJ_RN
            and sht.nPRN = pst.rn
        --    and pst.begplan <= dRep_date
            group by sht.sNOMEN_NAME
          ) loop
       --   p_exception(0,'!!! ');
          sSTRING_TMP := trim(sh.sNOMEN_NAME)||' - '||sh.nQUANT_PLAN||' шт'; 
          if sPRODUCT is null then
            sPRODUCT := sSTRING_TMP;
          elsif length(sPRODUCT||','||CR||sSTRING_TMP) < 3000 then
            sPRODUCT := sPRODUCT||','||CR||sSTRING_TMP;
          end if;
        end loop;
      else
        for sh in (
          select sum(fcp.quant)       as nQUANT_PLAN,
                 dn.nomen_name        as sNOMEN_NAME
          from FCACOPERPLANS    fcp
              ,STAGES           st
              ,DICNOMNS         dn
          where st.PRN = cnt.nContr_RN
            and st.FACEACC = fcp.prn
            and fcp.nomen = dn.rn
         --   and st.begin_date <= dRep_date
            group by dn.nomen_name
          ) loop
       --   p_exception(0,'!!! ');
          sSTRING_TMP := trim(sh.sNOMEN_NAME)||' - '||sh.nQUANT_PLAN||' шт';
          if sPRODUCT is null then
            sPRODUCT := sSTRING_TMP;
          elsif length(sPRODUCT||','||CR||sSTRING_TMP) < 3500 then
            sPRODUCT := sPRODUCT||','||CR||sSTRING_TMP;
          end if;
        end loop;
      end if;


      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_CONTR);

      PRSG_EXCEL.CELL_VALUE_WRITE(C_sCONTR_NAME,    0, nSTR, cnt.ssubject);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTR_NUMBER,   0, nSTR, cnt.sID_Buh);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTR_TYPE,     0, nSTR, sPRJ_TYPE);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTR_AGENT,    0, nSTR, cnt.sagent);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTR_DOGNUMB,  0, nSTR, cnt.sext_number);
      if cnt.sORDER is not null and cnt.dORDER is not null then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTR_ORDER,  0, nSTR, cnt.sORDER||' от '||to_char(cnt.dORDER,'dd.mm.yyyy'));
      elsif cnt.sORDER is not null then
        PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTR_ORDER,  0, nSTR, cnt.sORDER);
      end if;
      PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTR_MAINRUK,  0, nSTR, nvl(UDO_F_PROJECT_Get_AGENT(cnt.nPROJ_RN, 1, dRep_date), cnt.sMain_Ruk));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTR_RUK,      0, nSTR, nvl(UDO_F_PROJECT_Get_AGENT(cnt.nPROJ_RN, 0, dRep_date), cnt.sexecutive));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTR_ZAM_GK,   0, nSTR,     UDO_F_PROJECT_Get_AGENT(cnt.nPROJ_RN, 3, dRep_date));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTR_ECONOM,   0, nSTR, cnt.sECONOM);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_ORDER_URIST,    0, nSTR, cnt.sUSL_Name);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTRACTS_DATE, 0, nSTR, cnt.ddoc_date);

      PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTR_TKPA,     0, nSTR, nvl(UDO_F_PROJECT_Get_AGENT(cnt.nPROJ_RN, 2, dRep_date), cnt.sTKPA));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_CONTR_PRODUCT,  0, nSTR, sPRODUCT);


     if NStage =1 then
          nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_Stage_H);
        /* Приоритет выборки по этапам договора */
       /*  if cnt.nContr_RN is not null then
           cnt.nPROJ_RN := null;
         end if;*/

         for stg in (select  st.faceacc    as faceacc
                            ,null          as FACEACCCUST
                            ,st.description
                            ,st.numb
                            ,st.begin_date
                            ,st.end_date
                            ,st.rn        as STAGE_rn
                            ,null         as PRJST_rn
                            ,F_DOCS_PROPS_GET_STR_VALUE
                                  (
                                    nPROPERTY     => 7358407,              -- Статусы работ
                                    sUNITCODE     => 'ContractsStages',
                                    nDOCUMENT     => st.RN ) as sSTAGE_State
                            ,case st.status when 0 then 'Закрыт ' ||to_char(nvl(fc.fact_close_date, st.end_date),'dd.mm.yyyy')
                                            when 1 then 'Открыт'
                                            when 2 then 'Анулирован'  
                                                   else 'Согласован' end as sSTAGE_STATUS   
                            ,null as PRJ_STATUS 
                       from STAGES    st,
                            FACEACC   fc
                     where st.prn = cnt.nContr_RN
                       and fc.rn = st.faceacc
                       and cnt.nPROJ_RN is null
               --      and st.begin_date <= dRep_date
                  union
                     select  pst.faceacc     as faceacc
                            ,pst.faceaccCUST as FACEACCCUST
                            ,pst.name        as description
                            ,pst.numb        as numb
                            ,pst.begplan     as begin_date
                            ,pst.endplan     as end_date
                            ,null            as STAGE_rn
                            ,pst.rn          as PRJST_rn
                            ,null            as sSTAGE_State
                            ,case st.status when 0 then 'Закрыт ' ||to_char(nvl(fc.fact_close_date,st.end_date),'dd.mm.yyyy')
                                            when 1 then 'Открыт'
                                            when 2 then 'Анулирован'  
                                                   else 'Согласован' end  as sSTAGE_STATUS                       
                            ,case pst.STATE  when 0 then 'Зарегистрирован'  
                                             when 1 then 'Открыт'
                                             when 2 then 'Закрыт ' ||to_char(pst.ENDFACT,'dd.mm.yyyy')
                                             when 3 then 'Согласован' 
                                                    else 'Прекращен' end  as  PRJ_STATUS   
                       from PROJECTSTAGE  pst,
                            STAGES        st,
                            FACEACC       fc
                     where pst.prn = cnt.nPROJ_RN
                       and st.faceacc (+) = pst.faceacccust 
                       and fc.rn (+) = pst.faceacccust
                   /* Приоритет выборки по этапам договора */
                    --   and pst.begplan <= dRep_date
                     )
         loop
           /* Расходные накладные */
          sTransCust := null;
          for trs in (
            select tr.docdate, dt.docname, trim(tr.numb) as numb,
                   dt.doccode
            from TRANSINVCUST tr, DOCTYPES dt
            where tr.faceacc = stg.faceacc
              and dt.rn = tr.doctype
          ) loop
            sSTRING_TMP := trs.doccode||' № '||trs.numb ||' от ' ||to_char(trs.docdate,'dd.mm.yyyy');
            if sTransCust is null then
              sTransCust := sSTRING_TMP;
            elsif length (sTransCust ||', '||sSTRING_TMP) < 3500 then
              sTransCust := sTransCust ||', '||sSTRING_TMP;
            end if;
          end loop;
          /* Изготовление */
          sPRODUCT := null;
          /* Приоритет данным из проектов */
          if cnt.nPROJ_RN is not null then
            for sh in (
              select sht.*
              from UDO_V_PROJECTSTAGE_SHT sht
               --   ,PROJECTSTAGE           pst
              where /*pst.faceacccust = stg.FACEACCCUST
                and*/ sht.nPRN = stg.PRJST_rn
              ) loop
           --   p_exception(0,'!!! ');
              sSTRING_TMP := trim(sh.sNOMEN_NAME)||' - '||sh.nQUANT_PLAN||' шт';
              if sPRODUCT is null then
                sPRODUCT := sSTRING_TMP;
              elsif length(sPRODUCT||','||CR||sSTRING_TMP)< 3500 then
                sPRODUCT := sPRODUCT||','||CR||sSTRING_TMP;
              end if;
            end loop;
          else
            for sh in (
              select sum(fcp.quant)       as nQUANT_PLAN,
                     dn.nomen_name        as sNOMEN_NAME
              from FCACOPERPLANS    fcp
                  ,STAGES           st
                  ,DICNOMNS         dn
              where st.RN = stg.STAGE_rn
                and st.FACEACC = fcp.prn
                and fcp.nomen = dn.rn
       --         and st.begin_date <= dRep_date
                group by dn.nomen_name
              ) loop
           --   p_exception(0,'!!! ');
              if sPRODUCT is null then
                sPRODUCT := trim(sh.sNOMEN_NAME)||' - '||sh.nQUANT_PLAN||' шт';
              else
                sPRODUCT := sPRODUCT||','||CR||trim(sh.sNOMEN_NAME)||' - '||sh.nQUANT_PLAN||' шт';
              end if;
            end loop;
          end if;

          -- Описываем ячейки спецификации
          nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_Stages);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_STAGE_NAME,    0, nSTR, stg.description);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_STEGE_NUMER,   0, nSTR, trim(stg.numb));
          PRSG_EXCEL.CELL_VALUE_WRITE(C_STAGE_dSTART,  0, nSTR, stg.begin_date);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_STAGE_dEND,    0, nSTR, stg.end_date);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_STAGE_PRODUCT, 0, nSTR, sPRODUCT);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_STAGE_STATUS,  0, nSTR, nvl(stg.sSTAGE_STATUS, stg.PRJ_STATUS));

           if sTransCust is not null then
             PRSG_EXCEL.CELL_VALUE_WRITE(C_STAGE_STATE,  0, nSTR, sTransCust);
           elsif stg.sSTAGE_State is not null then
             PRSG_EXCEL.CELL_VALUE_WRITE(C_STAGE_STATE,  0, nSTR, stg.sSTAGE_State);
           else
             PRSG_EXCEL.CELL_VALUE_WRITE(C_STAGE_STATE,  0, nSTR, '!! Нет информации. ');
           end if;

         end loop;
     end if;
  end loop;

     --удаляем техническую строку
     PRSG_EXCEL.LINE_DELETE(LL_CONTR_H);
     PRSG_EXCEL.LINE_DELETE(LL_Stage_H);
     PRSG_EXCEL.LINE_DELETE(LL_CONTR);
     PRSG_EXCEL.LINE_DELETE(LL_Stages);
end UDO_PR_CONTRACTS_HEAD_REPORT;
/

