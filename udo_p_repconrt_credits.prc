create or replace procedure UDO_P_REPCONRT_CREDITS(
nIDENT in number, --идентификатор помеченных записей -- Этапы проекта
dDate  in date,    -- Отчет на дату
sArticle in varchar
--dDocDate in date
)
--Процедура для отчета "Калькуляция затрат"
as
  nSum      number(17,2) := 0;
  nTotal    number(17,2) := 0;
  sTMP      varchar(100) :='';
  sManager  varchar(100);
  
  ----Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'Справка'; -- Лист
  L_lStr     constant PKG_STD.TSTRING := 'L_stroka';
  --L_lStrSum  constant PKG_STD.TSTRING := 'Summa';
  
  C_sMain_header      constant PKG_STD.TSTRING := 'sMain_header';
  
  C_nLine_numb        constant PKG_STD.TSTRING := 'nLine_numb';
  C_sAgent_name       constant PKG_STD.TSTRING := 'sAgent_name';
  C_sDog_numb         constant PKG_STD.TSTRING := 'sDog_numb';
  C_sStage_period     constant PKG_STD.TSTRING := 'sStage_period';
  C_sStage_Stavka     constant PKG_STD.TSTRING := 'sStage_Stavka';
  C_sStage_limit      constant PKG_STD.TSTRING := 'sStage_limit';
  C_sStage_summ       constant PKG_STD.TSTRING := 'sStage_summ';
  C_sStage_coment     constant PKG_STD.TSTRING := 'sStage_coment';


 
  nSTR    number(17) := 1;
  nLine_Nub number := 0;

begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.CELL_DESCRIBE(C_sMain_header);

  -- Описываем ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(L_lStr);
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nLine_numb);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sAgent_name);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sDog_numb);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sStage_period);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sStage_Stavka);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sStage_limit);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sStage_summ);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sStage_coment);
  

 
  ---Заполнение шапки отчета
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sMain_header, 'Справка о кредитном портфеле ЗАО НТЦ «Модуль» по состоянию на '||to_char(dDate, 'dd.mm.yyyy') );
 -- PRSG_EXCEL.CELL_VALUE_WRITE(C_sData, 'Сегодня ' || to_char(SYSDATE, 'DD.MM.YYYY'));                          

  For rec in (
    select 
           ag.agnname
          ,dt.doccode||' №'||trim(cnt.ext_number)||' от '||to_char(cnt.doc_date,'dd.mm.yyyy') as sContr_numb
          ,to_char(cst.begin_date, 'dd.mm.yyyy')||' - '||to_char(cst.end_date, 'dd.mm.yyyy')      as sStage_period
          ,cst.stage_sum   as nStage_limit
          ,(select sum(pn.pay_sum) from PAYNOTES pn where pn.faceacc = cst.faceacc and pn.pay_date <= dDate and pn.signplan = 0) as nSrage_sum
          ,cst.comments
          ,cst.description
          ,' (Эт.№'||trim(cst.numb)||')' as sStage_numb
          ,cnt.rn                        as nCNT_rn
          ,F_DOCS_PROPS_GET_STR_VALUE(6807920,'Contracts', cnt.rn) as sDoc_dopCond

    from  CONTRACTS           cnt
        , STAGES              cst
        , AGNLIST             ag
        , DOCTYPES            dt
        , FACEACC             fc
        , FPDARTCL            fa
        , selectlist     sl
 
  where sl.ident = nIDENT 
      and cnt.RN = sl.document
      and cnt.rn = cst.prn
      and ag.rn = cnt.agent
      and dt.rn = cnt.doc_type
      and cst.faceacc = fc.rn
      and fc.ieelement = fa.rn (+)
      and sArticle like '%'||fa.code||'%'
      and fa.code is not null
      
    ) loop
    
      nLine_Nub := nLine_Nub +1;
      nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStr);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nLine_numb,    0, nSTR, nLine_Nub);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAgent_name,   0, nSTR, rec.agnname);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sDog_numb,     0, nSTR, rec.sContr_numb||rec.sStage_numb);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sStage_period, 0, nSTR, rec.sStage_period);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sStage_Stavka, 0, nSTR, rec.sDoc_dopCond);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sStage_limit,  0, nSTR, rec.nStage_limit);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sStage_summ,   0, nSTR, rec.nSrage_sum);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sStage_coment, 0, nSTR, rec.description ||' '||rec.comments);
     

  end loop;
 
     --удаляем техническую строку
     PRSG_EXCEL.LINE_DELETE(L_lStr);
     --PRSG_EXCEL.LINE_DELETE(L_lStrSum);
     
end UDO_P_REPCONRT_CREDITS;
/

