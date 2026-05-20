create or replace procedure UDO_RP_DOG_PRODUCT is


  ---- Процедура отчета ""
  -- Использовать UDO_V_FINPLAN_ARTS ???
    ---- Переменные отчета
 
  C_SLIST   constant PKG_STD.TSTRING := 'Лист1'; -- Лист
  L_GROUP   constant PKG_STD.TSTRING := 'Line'; -- Наименование бюджета

--
  C_nPP            constant PKG_STD.TSTRING := 'nPP';     
  C_sDOG_WORK      constant PKG_STD.TSTRING := 'sDOG_WORK';        
  C_sAGENT         constant PKG_STD.TSTRING := 'sAGENT';    
  C_sDOG_NUMB      constant PKG_STD.TSTRING := 'sDOG_NUMB';      
  C_sDOG_REZALT    constant PKG_STD.TSTRING := 'sDOG_REZALT';   
  C_sDOG_ORIG      constant PKG_STD.TSTRING := 'sDOG_ORIG';   
  C_sSHEFR         constant PKG_STD.TSTRING := 'sSHEFR';   

  nSTR_GROUP       PKG_STD.tREF;
  nPP_count        PKG_STD.tREF;
  sProduct         PKG_STD.tSTRING;
  slProd           PKG_STD.tSTRING;
  nCount           PKG_STD.tREF;
  nfaceacc         PKG_STD.tREF;

begin
 ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  -- Описываем имена ячеек в шапке и подвале

  -- Описываем добавляемые строки
  PRSG_EXCEL.LINE_DESCRIBE(L_GROUP);
 

  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_sDOG_WORK);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_sAGENT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_sDOG_NUMB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_sDOG_REZALT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_sDOG_ORIG);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_GROUP, C_sSHEFR);

  nPP_count := 1;

   for dog in (
     select dt.doccode
           ,nvl(cn.ext_number,trim(cn.doc_pref)||'-'||trim(cn.doc_numb))   as ext_number
           ,cn.doc_date
           ,cn.subject
           ,ag.agnname 
           ,trim(cn.doc_pref)||'-'||trim(cn.doc_numb)||' Эт.'   as sDOG_ORIG_NUMB
           ,cn.rn
     from CONTRACTS      cn
         ,DOCTYPES       dt
         ,AGNLIST        ag
     where ag.rn = cn.agent
       and dt.rn = cn.doc_type
     --  and cn.rn = 7525328
       and exists (select null from STAGES ss, FACEACC fc 
                    where ss.prn = cn.rn and extract (year from ss.end_date) >= 2022
                      and ss.FACEACC = fc.rn and fc.ACC_KIND = 1)
        
     ) loop
          nSTR_GROUP := PRSG_EXCEL.LINE_CONTINUE(L_GROUP);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,         0, nSTR_GROUP, nPP_count);         
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sDOG_WORK,   0, nSTR_GROUP, dog.subject);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sDOG_ORIG,   0, nSTR_GROUP, dog.sDOG_ORIG_NUMB);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT,      0, nSTR_GROUP, dog.agnname);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sDOG_NUMB,   0, nSTR_GROUP, dog.doccode ||' №'||dog.ext_number||' от '||to_char(dog.doc_date,'dd.mm.yyyy') );
          sProduct := null;
          nfaceacc := NULL;
          for st in (select dn.nomen_name,
                            nm.modif_name,
                           '  Эт.'|| trim(st.numb) as sStage_numb,
                           st.FACEACC  as st_Faceacc,
                           ps.faceacc  as ps_Faceacc
                 from STAGES         st
                     ,FCACOPERPLANS  fc
                     ,DICNOMNS       dn
                     ,NOMMODIF       nm
                     ,PROJECTSTAGE   PS
                where dog.rn = st.prn
                  and st.faceacc = fc.prn (+)
                  and fc.nomen = dn.rn (+)
                  and extract (year from st.end_date) >= 2022
                --  and nm.prn = dn.rn
                  and fc.nommodif = nm.rn(+)
                  AND PS.FACEACCCUST (+) = ST.faceacc
                   
          ) loop
            nCount := instr(st.modif_name,'_');
            if nCount > 0 then
              slProd := substr(st.modif_name, instr(st.modif_name,'_')+1) ;
              slProd := st.nomen_name ||' '|| trim(slProd);
            else
              slProd := st.nomen_name;
            end if;  
          
            if sProduct is null then
              sProduct := slProd;
            elsif sProduct not like '%'||slProd||'%' then
              if length(sProduct||', '||slProd ) < 3000 then
               sProduct := sProduct||', '||CR||slProd;
              end if;
            end if;
            nfaceacc := nvl(nvl(st.ps_Faceacc, st.st_Faceacc), nfaceacc);
          end loop;
          
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sDOG_REZALT, 0, nSTR_GROUP, sProduct);
          PRSG_EXCEL.CELL_VALUE_WRITE(C_sSHEFR,      0, nSTR_GROUP,  UDO_F_FACEACC_GET_SHEFR(nfaceacc));
          if dog.subject is null then
            PRSG_EXCEL.CELL_VALUE_WRITE(C_sDOG_WORK,   0, nSTR_GROUP, sProduct);
          end if;
           

          nPP_count := nPP_count +1;

     end loop;
end UDO_RP_DOG_PRODUCT;
/

