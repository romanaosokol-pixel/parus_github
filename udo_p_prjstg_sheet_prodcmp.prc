create or replace procedure UDO_P_PRJSTG_SHEET_PRODCMP
(
  nCOMPANY                  in number,  -- ќрганизаци€
  nSHEET                    in number,  -- —трока ведомости производства
  nPRODCMP                  out number  -- ѕроизводственный состав
) is
  /*
  ѕроизводственный состав по св€занному заказу на производство.
  ≈сли св€занного заказа на производство нет или в заказе на производство не указан производственный состав,
  то беретс€ последний по номеру производственный состав с типом документа "ѕ—"
  */
  sDOCTYPE          constant PKG_STD.tSTRING := 'ѕ—';
  dDATE             date := P_TOOLS_NOW; -- дата действи€
  --
  nCRN              PKG_STD.tREF;
  nJUR_PERS         PKG_STD.tREF;
  nMATRES           PKG_STD.tREF;
  nDOCTYPE          PKG_STD.tREF;
  sMTR_RES          PKG_STD.tSTRING;
  iCNT              integer;
begin

  /* —читывание записи */
  begin
  select s.crn, s.jur_pers, t.matres
         into nCRN, nJUR_PERS, nMATRES
         from UDO_PROJECTSTAGE_SHT t,
              PROJECTSTAGE s
         where t.rn = nSHEET
           and t.prn = s.rn;
  exception when NO_DATA_FOUND then
                 PKG_MSG.RECORD_NOT_FOUND(0, nSHEET, 'UDOProjectsStagesSheet');
  end;

  /* проверка прав доступа */
  PKG_ENV.ACCESS( nCOMPANY, null, nCRN, nJUR_PERS, 'UDOProjectsStagesSheet', 'PRJSTG_SHEET_VIEW_PRODCMP');

  /* “ип документа производственного состава */
  FIND_DOCTYPES_CODE_EX(0,0, nCOMPANY, sDOCTYPE, nDOCTYPE);

  /* 23/03/2023 ћарков ћ¬. —начала провер€ем жустко установленный серийный номер */
  select count(*)
    into iCNT
    from UDO_PROJECTSTAGE_SHT_ART SA
   where SA.PRN = nSHEET;
  
  if iCNT > 0 then
    -- из св€занного заводского номера
    for rls in(select LST.PRODCMP
                 from FCROUTLSTSERNUMB LSS,
                      FCROUTLST        LST,
                      DOCTYPES         DT
                where LSS.PRN = LST.RN
                  and LSS.ARTICLE in(select SA.ARTICLE from UDO_PROJECTSTAGE_SHT_ART SA where SA.PRN = nSHEET)
                  and LST.DOCTYPE = DT.RN
                  and DT.DOCCODE = '“ехѕаспорт'
                  ) loop
      nPRODCMP := rls.prodcmp;
    end loop;
    
  else
    -- из заказа на производство
    /* —читывание записи */
    begin
      select distinct ps.prodcmp
             into nPRODCMP
             from UDO_PRODUCTORD_SRC_DOC t,
                  PRODUCTORDS ps
             where t.rn_projectstage_sht = nSHEET
               and t.prn      = ps.prn;
    exception
      when NO_DATA_FOUND then null;
      when TOO_MANY_ROWS then
           p_exception(0, '—в€занный заказ на производство содержит несколько строк в спецификации с различными производственными составами.');
    end;
  end if;

  if nPRODCMP is null then
    begin
    select t.rn into nPRODCMP
      from (
        select t.rn,
               row_number() over (partition by t.mtr_res order by t.use_default desc, cmp_num(t.status, 1) desc, t.numb desc) CNT
          from FCPRODCMP t
          where t.company  = nCOMPANY
            and t.category = 0 -- ѕроизводственный состав
            and t.mtr_res  = nMATRES
            and t.doctype  = nDOCTYPE
        --    and CMP_NUM(PRODCOND, nPRODCOND) = 1
            and t.frm_date <= dDATE
            and t.status <> 2 -- Ќе аннулирован
            ) t
      where cnt = 1;
    exception when NO_DATA_FOUND then null;
    end;
  end if;

  /* производственный состав не найден */
  if ( nPRODCMP is null ) then
    /* считывание матресурса издели€ */
    begin
      select decode(M.MODIF_CODE, null, N.NOMEN_CODE, N.NOMEN_CODE||', '||M.MODIF_CODE )
        into sMTR_RES
        from FCMATRESOURCE T,
             DICNOMNS      N,
             NOMMODIF      M
       where T.RN = nMATRES
         and T.NOMENCLATURE = N.RN
         and T.NOMEN_MODIF  = M.RN(+);
    exception
      when NO_DATA_FOUND then
        PKG_MSG.RECORD_NOT_FOUND( nMATRES, 'CostMaterialResources' );
    end;

    P_EXCEPTION( 0,'Ќе найден производственный состав дл€ издели€ "%s" на дату "%s" с установленным признаком "»спользовать по умолчанию" либо в состо€нии "ѕроизводство".', sMTR_RES, D2S(dDATE) );
  end if;

end UDO_P_PRJSTG_SHEET_PRODCMP;
/

