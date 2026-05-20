create or replace procedure UDO_REP_TRANSINVCUST_TO_1C(
  nCOMPANY           in number,   -- Организация
  sRazd              in varchar2, -- Раздел из которого запускается отчет
  dBeg_Date          in date,     -- Начало периода
  dEnd_Date          in date      -- Конец периода
) is
  -- 28/03/2023 KHOK.
 ----Переменные отчета "Выгрузка  ТН"
  C_SLIST    constant PKG_STD.tSTRING := 'Лист1'; -- Лист
  LL_LINE    constant PKG_STD.tSTRING := 'L_LINE';
  C_sNum     constant PKG_STD.tSTRING := 'sNum';
  C_sRN      constant PKG_STD.tSTRING := 'sRN';
  C_sDate    constant PKG_STD.tSTRING := 'sDate';
  C_nIzd     constant PKG_STD.tSTRING := 'nIzd';
  C_sIzd     constant PKG_STD.tSTRING := 'sIzd';
  C_nKolIzd  constant PKG_STD.tSTRING := 'nKolIzd';
  C_sZakaz   constant PKG_STD.tSTRING := 'sZakaz';
  C_sEtap    constant PKG_STD.tSTRING := 'sEtap';
  C_nNomen   constant PKG_STD.tSTRING := 'nNomen';
  C_sNomen   constant PKG_STD.tSTRING := 'sNomen';
  C_nKol     constant PKG_STD.tSTRING := 'nKol';
  C_nPrice   constant PKG_STD.tSTRING := 'nPrice';
  C_nSum     constant PKG_STD.tSTRING := 'nSum';
  C_sFromRN  constant PKG_STD.tSTRING := 'sFromRN';
  C_sFrom    constant PKG_STD.tSTRING := 'sFrom';
  C_sToRN    constant PKG_STD.tSTRING := 'sToRN';
  C_sTo      constant PKG_STD.tSTRING := 'sTo';

  nSTR       number;
  sZakaz     varchar2(40) := '';
  sEtap      varchar2(40) := '';

begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;  
  PRSG_EXCEL.SHEET_SELECT( C_SLIST );
  -- Описываем строку спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);
  -- Описываем имена ячеек в строке
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sNum);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sRN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sDate);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nIzd);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sIzd);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nKolIzd);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sZakaz);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sEtap);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nNomen);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sNomen);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nKol);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPrice);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nSum);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sFromRN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sFrom);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sToRN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sTo);

  if 'GoodsTransInvoicesToDepts' = sRazd then -- Расходные накладные на отпуск в подразделения (TRANSINVDEPT)
    for rec in(
      select tran.rn tran_nrn, tran.doctype, tran.work_date, --tran.docdate,
             dt.doccode || ', ' ||trim(tran.pref) || '-' || trim(tran.numb) sNumb, 
             fa.numb fa_numb, 
             spec.rn sp_rn, spec.price, spec.quant, spec.summwithnds, -- spec.nommodif, spec.goodsparty,
             N.NOMEN_CODE, mat.name as NOMEN_NAME, 
             UDO_F_TRANSINVDEPT_MAIN_NUMB(tran.rn) nIzd, UDO_F_TRANSINVDEPT_MAIN_PROD(tran.rn) sIzd, --fc.quant fc_quant,
             decode(spec.ARTICLE, null, GP.SERNUMB, GPA.SERNUMB) sSERNUMB,
             tran.mol, AGN1.AGNABBR sMol, tran.in_mol, AGN2.AGNABBR sInMol,
             A.NAME,
             -- Количество изделий
            (select fc.quant 
               from DOCLINKS  dl, 
                    FCDELIVSH fc
              where dl.out_document = tran.rn
                and dl.out_unitcode = 'GoodsTransInvoicesToDepts'
                and dl.in_unitcode  = 'CostDeliverySheets'
                and dl.in_document  = fc.rn) fc_quant
      from TRANSINVDEPT      tran,
           TRANSINVDEPTSPECS spec,
           FCMATRESOURCE     mat,
           DOCTYPES          dt,
           FACEACC           fa,
           NOMMODIF          M,
           DICNOMNS          N,
           GOODSPARTIES      GP,
           -- изделие на складе
           ARTICLESSUPPLY    SA,
           GOODSSUPPLY       GSA,
           GOODSPARTIES      GPA,
           AGNLIST           AGN1, -- MOL
           AGNLIST           AGN2, -- IN_MOL
           RLARTICLES        A
      where tran.company = UDO_REP_TRANSINVCUST_TO_1C.nCOMPANY
        and tran.rn      = spec.prn
        and mat.nomen_modif (+)= spec.nommodif
        --and tran.doctype = 1074554 -- ТН только такие?
        and dt.rn = tran.doctype
        and tran.faceacc = fa.rn
        and ((dBeg_Date is not null and dEnd_Date is not null and tran.work_date between dBeg_Date and dEnd_Date)
         or  (dBeg_Date is not null and dEnd_Date is null and tran.work_date >= dBeg_Date)
         or  (dEnd_Date is not null and dBeg_Date is null and tran.work_date < dEnd_Date+1)
         or  (dBeg_Date is null and dEnd_Date is null)
         )
        and spec.NOMMODIF   = M.RN
        and M.PRN           = N.RN
        and spec.GOODSPARTY = GP.RN (+)
        -- изделие на складе
        and spec.COMPANY    = SA.COMPANY(+)
        and spec.ARTICLE    = SA.ARTICLE(+)
        and SA.PRN          = GSA.RN(+)
        and GSA.PRN         = GPA.RN(+)
        -- ФИО
        and tran.mol        = AGN1.RN
        and tran.in_mol     = AGN2.RN
        and spec.ARTICLE    = A.RN (+)
        and (decode(spec.ARTICLE, null, GP.SERNUMB, GPA.SERNUMB) is null 
            or length(decode(spec.ARTICLE, null, GP.SERNUMB, GPA.SERNUMB)) > 4) -- короткие внутренние номера исключаем
      order by sNumb, mat.name, sSERNUMB, spec.quant -- Сортировка должна соответствовать выгрузке в отчете UDO_REP_TRANSINVDEPT_M11
    ) loop

    if INSTR(rec.fa_numb, '/') > 0 then
      sZakaz := SUBSTR(rec.fa_numb, 0, INSTR(rec.fa_numb, '/')-1);
      sEtap := SUBSTR(rec.fa_numb, INSTR(rec.fa_numb, '/')+1);
    elsif INSTR(rec.fa_numb, '\') > 0 then
      sZakaz := SUBSTR(rec.fa_numb, 0, INSTR(rec.fa_numb, '\')-1);
      sEtap := SUBSTR(rec.fa_numb, INSTR(rec.fa_numb, '\')+1);
    else --if INSTR(rec.fa_numb, '-') > 0 then
      sZakaz := SUBSTR(rec.fa_numb, 0, INSTR(rec.fa_numb, '-')-1);
      sEtap := SUBSTR(rec.fa_numb, INSTR(rec.fa_numb, '-')+1);
    end if;

    nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sNum,    0, nSTR, rec.tran_nrn);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sRN,     0, nSTR, rec.sNumb);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate,   0, nSTR, rec.work_date /*docdate*/);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nIzd,    0, nSTR, rec.nIzd);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzd,    0, nSTR, rec.sIzd);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nKolIzd, 0, nSTR, rec.fc_quant);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZakaz,  0, nSTR, sZakaz);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sEtap,   0, nSTR, sEtap);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nNomen,  0, nSTR, nvl(rec.sSERNUMB, rec.NAME));
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sNomen,  0, nSTR, rec.nomen_name);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nKol,    0, nSTR, rec.quant);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nPrice,  0, nSTR, rec.price);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSum,    0, nSTR, rec.summwithnds);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sFromRN, 0, nSTR, rec.mol);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sFrom,   0, nSTR, rec.sMol);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sToRN,   0, nSTR, rec.in_mol);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sTo,     0, nSTR, rec.sInMol);
    
    end loop;

  elsif 'GoodsTransInvoicesToConsumers' = sRazd then -- Расходные накладные на отпуск потребителям (TRANSINVCUST)
if utilizer != 'KHOK' then p_exception(0, 'Отчет в процессе совершенствования. Звоните #137!'); end if;
    for rec in(
      select tran.rn tran_nrn, tran.doctype, tran.work_date, --tran.docdate,
             dt.doccode || ', ' ||trim(tran.pref) || '-' || trim(tran.numb) sNumb, 
             fa.numb fa_numb,
             --(select STR_VALUE from V_DOCS_PROPS_VALS_SHADOW where DOCS_PROP_RN = 12047550 and UNITCODE = 'ContractsStages' and UNIT_RN = st.RN) S12047550,
             spec.rn sp_rn, spec.price, spec.quant, spec.summ, spec.summwithnds, --spec.nommodif, spec.goodsparty,
             N.NOMEN_CODE, N.NOMEN_NAME, 
             A.NAME nIzd,
             tran.mol, AGN1.AGNABBR sMol, tran.agent, AGN2.AGNNAME sInMol
      from TRANSINVCUST      tran,
           TRANSINVCUSTSPECS spec,
           DOCTYPES          dt,
           --STAGES            st,
           FACEACC           fa,
           NOMMODIF          M,
           DICNOMNS          N,
           RLARTICLES        A,
           AGNLIST           AGN1, -- MOL
           AGNLIST           AGN2  -- IN_MOL
      where tran.company = UDO_REP_TRANSINVCUST_TO_1C.nCOMPANY
        and tran.rn      = spec.prn
        --and tran.doctype = 1074554 -- ТН только такие?
        and dt.rn = tran.doctype
        and tran.faceacc = fa.rn
        and ((dBeg_Date is not null and dEnd_Date is not null and tran.work_date between dBeg_Date and dEnd_Date)
         or  (dBeg_Date is not null and dEnd_Date is null and tran.work_date >= dBeg_Date)
         or  (dEnd_Date is not null and dBeg_Date is null and tran.work_date < dEnd_Date+1)
         or  (dBeg_Date is null and dEnd_Date is null)
         )
        and spec.NOMMODIF = M.RN
        and M.PRN         = N.RN
        and spec.ARTICLE  = A.RN(+)
        -- ФИО
        and tran.mol      = AGN1.RN
        and tran.agent    = AGN2.RN
       order by trim(tran.numb), n.nomen_name
    ) loop
    if INSTR(rec.fa_numb, '/') > 0 then
      sZakaz := SUBSTR(rec.fa_numb, 0, INSTR(rec.fa_numb, '/')-1);
      sEtap := SUBSTR(rec.fa_numb, INSTR(rec.fa_numb, '/')+1);
    elsif INSTR(rec.fa_numb, '\') > 0 then
      sZakaz := SUBSTR(rec.fa_numb, 0, INSTR(rec.fa_numb, '\')-1);
      sEtap := SUBSTR(rec.fa_numb, INSTR(rec.fa_numb, '\')+1);
    else --if INSTR(rec.fa_numb, '-') > 0 then
      sZakaz := SUBSTR(rec.fa_numb, 0, INSTR(rec.fa_numb, '-')-1);
      sEtap := SUBSTR(rec.fa_numb, INSTR(rec.fa_numb, '-')+1);
    end if;
    
    nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sNum,    0, nSTR, rec.sNumb);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sRN,     0, nSTR, rec.tran_nrn);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate,   0, nSTR, rec.work_date /*docdate*/);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nIzd,    0, nSTR, rec.nIzd);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sIzd,    0, nSTR, rec.nomen_name);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nKolIzd, 0, nSTR, rec.quant);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sZakaz,  0, nSTR, sZakaz);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sEtap,   0, nSTR, sEtap);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nNomen,  0, nSTR, rec.nomen_code);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sNomen,  0, nSTR, rec.nomen_name);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nKol,    0, nSTR, rec.quant);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nPrice,  0, nSTR, rec.price);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_nSum,    0, nSTR, rec.summwithnds);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sFromRN, 0, nSTR, rec.mol);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sFrom,   0, nSTR, rec.sMol);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sToRN,   0, nSTR, rec.agent);
    PRSG_EXCEL.CELL_VALUE_WRITE(C_sTo,     0, nSTR, rec.sInMol);    
    end loop;
  end if;
  --удаляем техническую строку
  PRSG_EXCEL.LINE_DELETE(LL_LINE);

end UDO_REP_TRANSINVCUST_TO_1C;
/
