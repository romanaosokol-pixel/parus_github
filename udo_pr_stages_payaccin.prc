create or replace procedure UDO_PR_STAGES_PAYACCIN
(
  NCOMPANY           in number,   -- Организация
  sRazd              in varchar2, -- Раздел
  nIDENT             in number    -- Отмеченные записи Договора/Этапа договора
)
is
 ----Переменные отчета "Перечень материалов по тематике"
  C_SLIST    constant PKG_STD.TSTRING := 'Лист1'; -- Лист

  LL_LINE    constant PKG_STD.TSTRING := 'L_Line';
   
  C_nPP                constant PKG_STD.TSTRING := 'nPP';
  C_sNomen_NAME        constant PKG_STD.TSTRING := 'sNomen_NAME';
  C_nQUANT             constant PKG_STD.TSTRING := 'nQUANT';
  C_nPrice             constant PKG_STD.TSTRING := 'nPrice';
  C_nSUMNDS            constant PKG_STD.TSTRING := 'nSUMNDS';
  C_nSUMWITHNDS        constant PKG_STD.TSTRING := 'nSUMWITHNDS';
  C_sAGENT             constant PKG_STD.TSTRING := 'sAGENT';
  C_sPAY_NUMB          constant PKG_STD.TSTRING := 'sPAY_NUMB';
  C_dPAY_DATE          constant PKG_STD.TSTRING := 'dPAY_DATE';
  C_sWork_n            constant PKG_STD.TSTRING := 'sWork_n';
    
  C_sWORK_NUMB         constant PKG_STD.TSTRING := 'sWORK_NUMB';
  C_sDate              constant PKG_STD.TSTRING := 'S_Date';
  
  nSTR number;
  nPP  number := 1;
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

    for prn in (
      select pa.ext_numb
            ,pa.reg_date
            ,dn.nomen_name
            ,nm.modif_name
            ,pc.quant_fact
            ,ag.agnname
            ,ps.summ
            ,ps.summwithnds
            ,ps.summ_nds
            ,ps.quant
      from PAYACCIN      pa
          ,PAYACCINSPEC  ps
          ,PAYACCINSPCLC pc
          ,DICNOMNS      dn
          ,NOMMODIF      nm
          ,AGNLIST       ag
      where pa.rn = ps.prn
        and ps.rn = pc.prn    
        and (UDO_F_PAYACCINSPEC_DOGNUMB(ps.rn) = sShifr or upper(UDO_F_PAYACCIN_TEMA(pa.rn)) = upper(usl_name))
        --and ((pc.faceaccount = faceacc or faceacc is null) or (pc.faceaccount = prj_faceacc or prj_faceacc is null))
        --and (pc.faceaccount = faceacc or (pc.faceaccount = prj_faceacc and prj_faceacc is not null))
        and dn.rn = ps.nomen
        and nm.rn = ps.nommodif
        and nm.prn = dn.rn
        and ag.rn = pa.supplier
        and PA.DOC_STATE = 1
      order by dn.nomen_name, nm.modif_name, ag.agnname, pa.reg_date
     ) loop

      nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,         0, nSTR, nPP);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sNomen_NAME, 0, nSTR, prn.nomen_name);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nQUANT,      0, nSTR, prn.quant_fact);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nPrice,      0, nSTR, prn.summ / prn.quant);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUMNDS,     0, nSTR, prn.summ_nds * prn.quant_fact / prn.quant);
      PRSG_EXCEL.CELL_VALUE_WRITE(C_nSUMWITHNDS, 0, nSTR, prn.summwithnds * prn.quant_fact / prn.quant);
      if ('' != prst_buhnum) then 
           PRSG_EXCEL.CELL_VALUE_WRITE(C_sWork_n,0, nSTR, prst_buhnum);
      else PRSG_EXCEL.CELL_VALUE_WRITE(C_sWork_n,0, nSTR, st_buhnum);
      end if;
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sAGENT,      0, nSTR, trim(prn.agnname));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_sPAY_NUMB,   0, nSTR, trim(prn.ext_numb));
      PRSG_EXCEL.CELL_VALUE_WRITE(C_dPAY_DATE,   0, nSTR, prn.reg_date);

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
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sNomen_NAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nQUANT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPrice);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSUMNDS);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSUMWITHNDS);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sAGENT);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sPAY_NUMB);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_dPAY_DATE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sWork_n); -- Тема

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

end UDO_PR_STAGES_PAYACCIN;
/

