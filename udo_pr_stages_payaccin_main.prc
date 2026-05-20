create or replace procedure UDO_PR_STAGES_PAYACCIN_main
(
  NCOMPANY           in number,   -- Организация
  sRazd              in varchar2, -- Раздел
  nIDENT             in number    -- Отмеченные записи Договора/Этапа договора
)
is
 ----Переменные отчета "Оплата счетов по теме"
  C_SLIST    constant PKG_STD.TSTRING := 'Лист1'; -- Лист

  LL_LINE    constant PKG_STD.TSTRING := 'L_Line';
   
  C_nPP                constant PKG_STD.TSTRING := 'nPP';
  C_sAGENT             constant PKG_STD.TSTRING := 'sAGENT';
  C_sPAY_NUMB          constant PKG_STD.TSTRING := 'sPAY_NUMB';
  C_dPAY_DATE          constant PKG_STD.TSTRING := 'dPAY_DATE';
  C_sWork_n            constant PKG_STD.TSTRING := 'sWork_n';

  C_dPay_Sum           constant PKG_STD.TSTRING := 'dPAY_SUM';
  C_dReal_Pay          constant PKG_STD.TSTRING := 'dREAL_PAY';
  C_dSumm              constant PKG_STD.TSTRING := 'dSUMM';  
   C_sPAY_DOCS         constant PKG_STD.TSTRING := 'sPAY_DOCS';
      
  C_sWORK_NUMB         constant PKG_STD.TSTRING := 'sWORK_NUMB';
  C_sDate              constant PKG_STD.TSTRING := 'S_Date';
  C_nPRJ_Summ          constant PKG_STD.TSTRING := 'nPRJ_Summ';
  C_sPay_ACC           constant PKG_STD.TSTRING := 'sPay_ACC';
  
  nSTR number;
  nPP  number := 1;
  dRealDate   varchar2(128); --date; --varchar2(32) := '';
  nPaySum     number(17,2) := 0;
  nSum_prj    number(17,2) := 0;
  sPay_data   varchar2(1000);
  sPay_ACC    varchar2(1000);
  sUslName    varchar2(256) := '';
  sBuhNum     varchar2(256) := '';

procedure PRINT_ROWS(usl_name in varchar2, 
                    st_buhnum in varchar2, 
                  prst_buhnum in varchar2,
                      /*faceacc in varchar2,
                  prj_faceacc in varchar2,*/
                       sShifr in varchar2)
as
begin
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sWORK_NUMB, 'Тема: ' || usl_name);

    for pyrn in (
      select pa.ext_numb
            ,pa.reg_date       
            ,ag.agnname
            ,pa.summ
            ,pa.summwithnds
            ,pa.rn pa_rn
            ,plc.nSumm as nPRJSUMM
            ,(select sum(psu.summ) as nSumm                
                from PAYACCINSPEC psu, DICNOMNS dn
               where psu.prn = pa.rn
                 and dn.rn = psu.nomen
                 and dn.NOMEN_TYPE = 2
                 and UDO_F_PAYACCINSPEC_DOGNUMB(psu.rn) = sShifr
                 and not exists (select null from PAYACCINSPCLC puc where puc.prn = psu.rn ) ) as nSumm_Deliv
               
      from PAYACCIN      pa
          ,AGNLIST       ag
          ,(select sum(pc.cost_plan * pc.quant_plan) as nSumm 
                 ,ps.prn
                 ,pc.faceaccount
             from PAYACCINSPCLC pc 
                 ,PAYACCINSPEC  ps
             where pc.prn = ps.rn
             group by ps.prn, pc.faceaccount  
           ) PLC    
      where pa.doc_state =  1 
        and ag.rn = pa.supplier
        and upper(UDO_F_PAYACCIN_TEMA(pa.rn)) = upper(usl_name)
        --and ((plc.faceaccount = faceacc or faceacc is null) or (plc.faceaccount = prj_faceacc or prj_faceacc is null))
        --and (plc.faceaccount = faceacc or (plc.faceaccount = prj_faceacc and prj_faceacc is not null))
        and plc.prn = pa.rn
      order by ag.agnname, pa.ext_numb
     ) loop

      nSum_prj := nvl(pyrn.nPRJSUMM, 0);

      sPay_data := '!';
      dRealDate := '';
      nPaySum   := 0;
      sPay_ACC  := null;
      for pay in (
        select TO_CHAR(pn.pay_date, 'DD.MM.YYYY') pay_date,
               pn.pay_sum,
               pn.pay_number,
               trim(pa.strcode) as strcode
        from DOCLINKS dl
            ,PAYNOTES pn
            ,AGNACC   PA
        where dl.in_document = pyrn.pa_rn
          and dl.in_unitcode = 'PaymentAccountsIn'
          and dl.out_unitcode = 'PayNotes'
          and dl.out_document = pn.rn
          and pa.rn = pn.AGNACC
          and pn.signplan = 0        
       ) loop
       
        if sPay_ACC is null then
          sPay_ACC := pay.strcode; 
        else
          if sPay_ACC not like '%'||pay.strcode||'%' then
            sPay_ACC := sPay_ACC ||', '|| pay.strcode;
          end if;
        end if;  

        if '!' = sPay_data then
          sPay_data := 'ПП '|| trim(pay.pay_number) ||', от '||pay.pay_date||
                        ', '|| trim(TO_CHAR(Pay.PAY_SUM,'999G999G999G999G999G990D99'
                                                     ,'nls_numeric_characters='', '''));
          dRealDate := pay.pay_date;
          nPaySum   := pay.pay_sum;
        else
          sPay_data := sPay_data ||'; ПП '||trim(pay.pay_number)||', от '||pay.pay_date||
                                      ', '||trim(TO_CHAR(Pay.PAY_SUM,'999G999G999G999G999G990D99'
                                                                    ,'nls_numeric_characters='', '''));
          nPaySum   := nPaySum + pay.pay_sum;
        end if;

      end loop;
      if '!' = sPay_data then sPay_data := ''; end if;
      
      pyrn.nSumm_Deliv := nvl(pyrn.nSumm_Deliv,0);
     
    /*  if pyrn.nSumm_Deliv > 0 then 
        pyrn.nSumm_Deliv := pyrn.nSumm_Deliv * nvl(nSum_prj,0) /(pyrn.summ - pyrn.nSumm_Deliv);
      end if;*/

/*select min(M.pay_date), sum(m.pay_sum) into dRealDate, nPaySum --M.*--, UDO_F_PAYNOTES_ARTICLE(NRN) S6431513, UDO_F_PAYNOTES_FACT_BY_PLAN(NRN) N6858508 
from PAYNOTES M where M.COMPANY=NCOMPANY and M.signplan = 0 and
M.RN in (select NDOCUMENT from V_DOCLINKS_INOUT_IN_EXT where NIN_DOCUMENT=prn.pa_rn and SIN_UNITCODE='PaymentAccountsIn' and SUNITCODE='PayNotes');
*/
      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,         0, nSTR, nPP);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT,      0, nSTR, trim(pyrn.agnname));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sPAY_NUMB,   0, nSTR, trim(pyrn.ext_numb));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_dPAY_DATE,   0, nSTR, pyrn.reg_date);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_dSumm,       0, nSTR, pyrn.summwithnds );
      PRSG_EXCEL.CELL_VALUE_WRITE(C_dPay_Sum,    0, nSTR, nPaySum);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sPAY_DOCS,   0, nSTR, sPay_data);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sPay_ACC,    0, nSTR, sPay_ACC );
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nPRJ_Summ,   0, nSTR, nPaySum * nSum_prj / ( pyrn.summ - pyrn.nSumm_Deliv) );  /* суммы без НДС */
      if ('' != prst_buhnum) then 
           PRSG_EXCEL.CELL_VALUE_WRITE(C_sWork_n,0, nSTR, prst_buhnum);
      else PRSG_EXCEL.CELL_VALUE_WRITE(C_sWork_n,0, nSTR, st_buhnum);
      end if;
      
      nPP := nPP + 1;     

     end loop;
end;

begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  PRSG_EXCEL.CELL_DESCRIBE(C_sDate);
  PRSG_EXCEL.CELL_DESCRIBE(C_sWORK_NUMB);

  -- Описываем ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);

  -- Описываем имена ячеек в шапке и подвале
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sAGENT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPAY_NUMB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dPAY_DATE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sWork_n); -- Тема

  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dPay_Sum);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dReal_Pay);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dSumm);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPRJ_Summ);

  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPAY_DOCS);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPay_ACC);
  
  PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate, 'На ' || to_char(SYSDATE, 'DD.MM.YYYY'));

if 'Contracts' = sRazd then

    select UDO_F_GET_USL_NAME(con.rn), 
           (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 1076177 and UNITCODE = 'Contracts' and UNIT_RN = con.rn)
      into sUslName, sBuhNum
      from SELECTLIST sl,
           CONTRACTS con
     where sl.ident = nIDENT
       and sl.document = con.rn;

     PRINT_ROWS(sUslName, sBuhNum, '', /*null, null,*/ null);

else

  for ss in(
    select --st.faceacc st_faceacc, prs.faceacc prs_faceacc
           UDO_F_GET_USL_NAME(st.prn) usl_name,
           udo_f_stages_buhnum(st.rn) st_buhnum,
           udo_f_projectstage_buhnum(prs.rn) prst_buhnum,
           (select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 12047550 and UNITCODE = 'ContractsStages' and UNIT_RN = st.RN) sShifr
    from SELECTLIST sl,
         STAGES st,
         PROJECTSTAGE prs
   where sl.ident = nIDENT
     and sl.document = st.rn     
     and prs.faceacccust (+) = st.faceacc
     and st.company = NCOMPANY
   order by st.prn,st.faceacc
  ) loop

  PRINT_ROWS(ss.usl_name, ss.st_buhnum, ss.prst_buhnum, /*ss.st_faceacc, ss.prs_faceacc,*/ ss.sShifr);

  end loop;

end if;
  --удаляем техническую строку
  PRSG_EXCEL.LINE_DELETE(LL_LINE);

end UDO_PR_STAGES_PAYACCIN_main;
/

