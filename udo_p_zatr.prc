create or replace procedure UDO_P_ZATR(
nIDENT in number,
dDocDate in date
)
--Процедура отчета "Отпуск товаров"
as
  nSum      number(17,2) := 0;
  nTotal    number(17,2) := 0;

  ----Переменные отчета
  C_SLIST    constant PKG_STD.TSTRING := 'Sheet1'; -- Лист
  L_lStr     constant PKG_STD.TSTRING := 'Stroka';
  --L_lStrSum  constant PKG_STD.TSTRING := 'Summa';
  
  C_sName    constant PKG_STD.TSTRING := 'Zagolovok';
  C_sData    constant PKG_STD.TSTRING := 'Data';
  C_sKontr   constant PKG_STD.TSTRING := 'Kontragent';
  C_sDoc     constant PKG_STD.TSTRING := 'Dogovor';
  C_nQuant   constant PKG_STD.TSTRING := 'Quant';
  C_sNomenkl constant PKG_STD.TSTRING := 'Nomenkl';
  C_sPeriod  constant PKG_STD.TSTRING := 'Period';
  C_sShifr   constant PKG_STD.TSTRING := 'shifr';

  C_nMat_e   constant PKG_STD.TSTRING := 'mat_e';
  C_nMat_s   constant PKG_STD.TSTRING := 'mat_s';
  C_nPki_e   constant PKG_STD.TSTRING := 'pki_e';
  C_nPki_s   constant PKG_STD.TSTRING := 'pki_s';
  C_nZarp_e  constant PKG_STD.TSTRING := 'zarp_e';
  C_nZarp_s  constant PKG_STD.TSTRING := 'zarp_s';
  C_nOsn_e   constant PKG_STD.TSTRING := 'osn_e';
  C_nOsn_s   constant PKG_STD.TSTRING := 'osn_s';
  C_nDop_e   constant PKG_STD.TSTRING := 'dop_e';
  C_nDop_s   constant PKG_STD.TSTRING := 'dop_s';
  C_nSoc_o_e constant PKG_STD.TSTRING := 'soc_o_e';
  C_nSoc_o_s constant PKG_STD.TSTRING := 'soc_o_s';
  C_nSoc_s_e constant PKG_STD.TSTRING := 'soc_s_e';
  C_nSoc_s_s constant PKG_STD.TSTRING := 'soc_s_s';
  C_nSpecO_e constant PKG_STD.TSTRING := 'speco_e';
  C_nSpecO_s constant PKG_STD.TSTRING := 'speco_s';
  C_nSpec_e constant PKG_STD.TSTRING := 'spec_e';
  C_nSpec_s constant PKG_STD.TSTRING := 'spec_s';
  C_nNakl_e constant PKG_STD.TSTRING := 'nakl_e';
  C_nNakl_s constant PKG_STD.TSTRING := 'nakl_s';
  C_nKom_e constant PKG_STD.TSTRING := 'kom_e';
  C_nKom_s constant PKG_STD.TSTRING := 'kom_s';
  C_nKontr_e constant PKG_STD.TSTRING := 'kontr_e';
  C_nKontr_s constant PKG_STD.TSTRING := 'kontr_s';
  C_nPrSeb_e constant PKG_STD.TSTRING := 'pr_seb_e';
  C_nPrSeb_s constant PKG_STD.TSTRING := 'pr_seb_s';
  C_nComm_e constant PKG_STD.TSTRING := 'komm_e';
  C_nComm_s constant PKG_STD.TSTRING := 'komm_s';
  C_nSeb_e constant PKG_STD.TSTRING := 'seb_e';
  C_nSeb_s constant PKG_STD.TSTRING := 'seb_s';
  C_nPrib_e constant PKG_STD.TSTRING := 'prib_e';
  C_nPrib_s constant PKG_STD.TSTRING := 'prib_s';
  C_nPrice_e constant PKG_STD.TSTRING := 'price_e';
  C_nPrice_s constant PKG_STD.TSTRING := 'price_s';
  C_nNds_e constant PKG_STD.TSTRING := 'nds_e';
  C_nNds_s constant PKG_STD.TSTRING := 'nds_s';
  C_nPriceNds_e constant PKG_STD.TSTRING := 'price_nds_e';
  C_nPriceNds_s constant PKG_STD.TSTRING := 'price_nds_s';
  C_nPolSeb_e constant PKG_STD.TSTRING := 'pol_seb_e';
  C_nPolSeb_s constant PKG_STD.TSTRING := 'pol_seb_s';
  C_nOther_e constant PKG_STD.TSTRING := 'other_e';
  C_nOther_s constant PKG_STD.TSTRING := 'other_s';
  
  C_nTotal   constant PKG_STD.TSTRING := 'Total';
  C_nItogo   constant PKG_STD.TSTRING := 'Itogo';
 
  nSTR    number(17) := 1;

begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.CELL_DESCRIBE(C_sName);
  PRSG_EXCEL.CELL_DESCRIBE(C_sData);
  PRSG_EXCEL.CELL_DESCRIBE(C_nItogo);
  PRSG_EXCEL.CELL_DESCRIBE(C_sPeriod);

  -- Описываем ячейки спецификации материалов
  PRSG_EXCEL.LINE_DESCRIBE(L_lStr);
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sKontr);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sDoc);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nQuant);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sShifr);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_sNomenkl);
  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nMat_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nMat_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPki_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPki_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nZarp_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nZarp_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nOsn_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nOsn_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nDop_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nDop_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nSoc_o_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nSoc_o_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nSoc_s_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nSoc_s_s);  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nSpecO_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nSpecO_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nSpec_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nSpec_s);  
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nNakl_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nNakl_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nKom_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nKom_s); 
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nKontr_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nKontr_s); 
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPrSeb_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPrSeb_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nComm_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nComm_s); 
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nSeb_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nSeb_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPrib_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPrib_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPrice_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPrice_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nNds_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nNds_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPriceNds_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPriceNds_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPolSeb_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nPolSeb_s);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nOther_e);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nOther_s); 
  PRSG_EXCEL.LINE_CELL_DESCRIBE(L_lStr, C_nTotal);

  ---Заполнение шапки отчета
-- PRSG_EXCEL.CELL_VALUE_WRITE(C_sName, 'Плановые затраты по статьям (начиная с ' || TO_CHAR(dDocDate, 'DD FMMonth YYYY', 'nls_date_language=russian') ||')');
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sName, 'Плановые затраты по статьям (начиная с ' || TO_CHAR(dDocDate, 'dd.mm.yyyy') ||')');
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sData, 'Сегодня ' || to_char(SYSDATE, 'DD.MM.YYYY'));                          

  For rec in (
    select pla.rn pla_rn, pla.quant pla_quant, ag.rn AG_RN, AGNNAME, 
    con.doc_pref, con.doc_numb, con.doc_date, d_nom.nomen_code, 
    nvl(F_DOCS_PROPS_GET_STR_VALUE(1076177, 'FaceAccounts', fc.RN), '-') shifr_bu
from CONTRACTS con
, STAGES st
, FACEACC fc
, FCACOPERPLANS pla
, AGNLIST ag
, DICNOMNS d_nom
, selectlist sl
 
where sl.ident = nIDENT and con.RN = sl.document
      and con.rn = st.prn
      and st.faceacc  = fc.rn
      and fc.rn =  pla.prn
      and con.agent = ag.rn
      and pla.nomen = d_nom.rn
      and doc_date >= dDocDate
      order by agnabbr, con.doc_pref, con.doc_numb, nomen_code, pla.begin_date
    ) loop
    
      nTotal := 0;
      nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStr);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sKontr, 0, nSTR, trim(rec.AGNNAME));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sDoc, 0, nSTR, trim(rec.doc_pref) || '-' || trim(rec.doc_numb));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sShifr, 0, nSTR, trim(rec.shifr_bu));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sNomenkl, 0, nSTR, trim(rec.nomen_code));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nQuant, 0, nSTR, trim(rec.pla_quant));

      For calc in (
          select art.CODE, cost_plan, clc.COST_ARTICLE costs 
          from FCACOPERPLANSCLC clc, FPDARTCL art
          where clc.PRN = rec.pla_rn
          and clc.COST_ARTICLE = art.RN
          order by prn, numb
      ) loop
      
      nSum := calc.cost_plan*rec.pla_quant;
      nTotal := nTotal + nSum;
      
      if calc.costs = 501000 then -- Материальные затраты
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nMat_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nMat_s, 0, nSTR, nSum);
       --nSumMat := nSumMat + nSum;
      elsif calc.costs = 501036 then -- ПКИ
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nPki_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nPki_s, 0, nSTR, nSum);
       --nSumPki := nSumPki + nSum;
     elsif calc.costs = 6266518 then -- Затраты на оплату труда
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nZarp_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nZarp_s, 0, nSTR, nSum);
        --nSumZarp := nSumZarp + nSum;
      elsif calc.costs = 500981 then -- - основная заработная плата
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nOsn_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nOsn_s, 0, nSTR, nSum);
        --nSumOsn := nSumOsn + nSum;
      elsif calc.costs = 500982 then -- - дополнительная заработная плата
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nDop_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nDop_s, 0, nSTR, nSum);
        --nSumDop := nSumDop + nSum;
      elsif calc.costs = 6298142 then -- Страховые взносы на обязательное социальное страхование
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nSoc_o_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nSoc_o_s, 0, nSTR, nSum);
        --nSumSoc_o := nSumSoc_o + nSum;
      elsif calc.costs = 500983 then -- - социальные отчисления от заработной платы сотрудников
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nSoc_s_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nSoc_s_s, 0, nSTR, nSum);
        --nSumSoc_s := nSumSoc_s + nSum;
      elsif calc.costs = 500980 then -- Затраты на специальное оборудование для научных (экспериментальных) работ
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nSpecO_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nSpecO_s, 0, nSTR, nSum);
        --nSumSpecO := nSumSpecO + nSum;
      elsif calc.costs = 1073155 then -- Специальные затраты
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nSpec_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nSpec_s, 0, nSTR, nSum);
        --nSumSpec := nSumSpec + nSum;
      elsif calc.costs = 500987 then -- Общехозяйственные расходы
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nNakl_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nNakl_s, 0, nSTR, nSum);
        --nSumNakl := nSumNakl + nSum;
      elsif calc.costs = 500984 then -- Затраты на командировки
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nKom_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nKom_s, 0, nSTR, nSum);
        --nSumKom := nSumKom + nSum;
      elsif calc.costs = 500985 then -- Контрагенты. Затраты по работам (услугам), выполняемым (оказанным) сторонними организациями
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nKontr_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nKontr_s, 0, nSTR, nSum);
        --nSumKontr := nSumKontr + nSum;
      elsif calc.costs = 500988 then -- Производственная себестоимость
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nPrSeb_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nPrSeb_s, 0, nSTR, nSum);
        --nSumPrSeb := nSumPrSeb + nSum;
      elsif calc.costs = 500990 then -- Коммерческие (внепроизводственные) затраты
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nComm_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nComm_s, 0, nSTR, nSum);
        --nSumComm := nSumComm + nSum;
      elsif calc.costs = 6266533 then -- Себестоимость продукции
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nSeb_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nSeb_s, 0, nSTR, nSum);
        --nSumSeb := nSumSeb + nSum;
      elsif calc.costs = 500991 then -- Прибыль
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nPrib_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nPrib_s, 0, nSTR, nSum);
        --nSumPrib := nSumPrib + nSum;
      elsif calc.costs = 500992 then -- Цена продукции (без НДС)
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nPrice_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nPrice_s, 0, nSTR, nSum);
        --nSumPrice := nSumPrice + nSum;
      elsif calc.costs = 500993 then -- НДС
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nNds_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nNds_s, 0, nSTR, nSum);
        --nSumNds := nSumNds + nSum;
      elsif calc.costs = 500994 then -- Цена продукции (с НДС)
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nPriceNds_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nPriceNds_s, 0, nSTR, nSum);
        --nSumPriceNds := nSumPriceNds + nSum;
      elsif calc.costs = 1073174 then -- Полная себестоимость
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nPolSeb_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nPolSeb_e, 0, nSTR, nSum);
        --nSumPolSeb := nSumPolSeb + nSum;
      else --calc.costs = 500986 then -- Прочие прямые затраты
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nOther_e, 0, nSTR, calc.cost_plan);
       PRSG_EXCEL.CELL_VALUE_WRITE(C_nOther_s, 0, nSTR, nSum);                                                                    
        --nSumOther := nSumOther + nSum;
      end if;

    end loop;
    
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nTotal, 0, nSTR, nTotal);                                                                    

  end loop;
 
  --PRSG_EXCEL.CELL_VALUE_WRITE(C_nItogo, 90);

     /*nSTR := PRSG_EXCEL.LINE_CONTINUE(L_lStrSum);
     PRSG_EXCEL.CELL_VALUE_WRITE(C_nSumMat, 0, nSTR, nSumMat);
     PRSG_EXCEL.CELL_VALUE_WRITE(C_nSumPki, 0, nSTR, nSumPki);
     ... */
  
     --PRSG_EXCEL.LINE_DELETE(L_lStrSum);
     PRSG_EXCEL.LINE_DELETE(L_lStr);
     
end UDO_P_ZATR;
/

