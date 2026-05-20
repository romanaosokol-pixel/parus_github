create or replace procedure UDO_P_REMAIN_MOL_CRT
(
  nCOMPANY in number,
  sCRN     in varchar2,
  dDATE    in date
) as
  /*
    Марков МВ.
    Разовая процедура формирования прихода по остаткам МОЛ
    update udo_modul_remains_mol m set m.ser_numb = case when instr(substr(m.nomenclature, 15), ', ') > 0 then
         substr(substr(m.nomenclature, 15), instr(substr(m.nomenclature, 15), ', ')+2, 1000)
    else '' end where m.mol like 'Комаров%' and m.ser_numb is null and m.mnf_numb is null;
  */
  nIDENT    number(17) := 94756590; --93974501;
  nCRN      number(17);
  nPRN      number(17);
  nRN       number(17);
  sJUR_PERS JURPERSONS.CODE%type;
  nJUR_PERS number(17);
  sDOC_NUMB INCOMEFROMDEPS.DOC_PREF%type;
  nSUPPLY   number(17);
  nPARTY    number(17);
  nSPEC     number(17);
  sCODE     INCOMDOC.CODE%type;
  iCNT      integer;

  -- проставить ссылки на номенклатор
  procedure set_nomen is
    nNOMEN number(17);
    nMODIF number(17);
  begin
    for rec in (select *
                  from udo_modul_remains_mol t
                 where t.ident = nIDENT
                   and rtrim(t.nomen_code) is not null
                   and rtrim(t.modif_code) is not null
                   and t.nomen is null) loop
      find_nomenclature_by_code(COMPANY => nCOMPANY, CODE => rec.nomen_code, RN => nNOMEN);
      find_nommodif_by_code(nPRN => nNOMEN, sCODE => rec.modif_code, nFRN => nMODIF);
      update udo_modul_remains_mol m
         set m.nomen = nNOMEN,
             m.modif = nMODIF
       where m.rn = rec.rn;
    end loop;
  end set_nomen;

  -- указать МОЛ
  procedure set_agent is
    nMOL number(17);
  begin
    for rec in (select t.rn, trim(t.mol) as mol
                  from udo_modul_remains_mol t
                 where t.ident = nIDENT
                   and rtrim(t.mol) is not null
                   and t.agn_rn is null) loop
      find_agnlist_by_mnemo(nFLAG_SMART => 0, nCOMPANY => nCOMPANY, sAGNABBR => rec.mol, nRN => nMOL);
      update udo_modul_remains_mol m set m.agn_rn = nMOL where m.rn = rec.rn;
    end loop;
  end set_agent;

  -- указать л/с
  procedure set_faceacc is
    nFA number(17);
  begin
    for rec in (select *
                  from udo_modul_remains_mol t
                 where t.ident = nIDENT
                   and rtrim(t.theme) is not null
                   and t.fa_rn is null) loop
      begin
        select min(FA.RN)
          into nFA
          from FACEACC FA
         where FA.COMPANY = nCOMPANY
           and FA.NUMB like rec.theme || '%';
      exception
        when no_data_found then
          nFA := to_number(null);
      end;
      update udo_modul_remains_mol m set m.fa_rn = nFA where m.rn = rec.rn;
    end loop;
  end set_faceacc;

  /* указать серийный номер изделия */
  procedure set_article is
  begin
    for rec in (select t.nomen_name,
                       t.rn,
                       nm.nomen_code,
                       t.mnf_numb,
                       nm.nomen_code || '_' || t.mnf_numb as art_numb,
                       t.modif,
                       (select ra.rn
                          from rlarticles ra
                         where ra.nommodif = t.modif
                           and ra.code = nm.nomen_code || '_' || t.mnf_numb) ra_rn
                  from udo_modul_remains_mol t,
                       dicnomns              nm
                 where t.ident = nIDENT
                   and t.nomen = nm.rn
                   and length(t.mnf_numb) = 3
                   and t.modif is not null
                   and t.mnf_numb is not null
                   and t.article_rn is null) loop
      if rec.ra_rn is null then
        p_rlarticles_base_insert(nCOMPANY    => nCOMPANY,
                                 nCRN        => 92065,
                                 sCODE       => rec.art_numb,
                                 sNAME       => rec.art_numb,
                                 nNOMMODIF   => rec.modif,
                                 nQUANT      => 0,
                                 nSIGN_PRICE => 0,
                                 nRN         => rec.ra_rn);
      end if;
      update udo_modul_remains_mol m set m.article_rn = rec.ra_rn where m.rn = rec.rn;
    end loop;
  end set_article;

begin
  -- проставить ссылки на номенклатор
  --set_nomen;
  -- указать МОЛ
  --set_agent;
  -- указать л/с
  --set_faceacc;
  -- указать серийный номер изделия
  --set_article;
  --
  --return;
  --
  find_acatalog_name(nFLAG_SMART => 0,
                     nCOMPANY    => nCOMPANY,
                     nVERSION    => null,
                     sUNITCODE   => 'IncomFromDeps',
                     sNAME       => sCRN,
                     nRN         => nCRN);
  find_jurpersons_main(nFLAG_SMART => 0, nCOMPANY => nCOMPANY, sJUR_PERS => sJUR_PERS, nJUR_PERS => nJUR_PERS);
  --
  for rr in (select distinct t.agn_rn
               from udo_modul_remains_mol t
              where t.ident = nIDENT
                and t.agn_rn = 7387498 -- 
                and t.ifs_rn is null
                --and t.fa_rn is not null
                ) loop
    p_incomefromdeps_base_nextnumb(nCOMPANY  => nCOMPANY,
                                   nJUR_PERS => nJUR_PERS,
                                   dDOC_DATE => dDATE,
                                   nDOC_TYPE => 23957885, -- АктОпрИнв
                                   sDOC_PREF => '2022',
                                   sDOC_NUMB => sDOC_NUMB);
    -- заголовок
    p_incomefromdeps_base_insert(nCOMPANY          => nCOMPANY,
                                 nCRN              => nCRN,
                                 nJUR_PERS         => nJUR_PERS,
                                 nDOC_TYPE         => 23957885, -- АктОпрИнв
                                 sDOC_PREF         => '2022',
                                 sDOC_NUMB         => sDOC_NUMB,
                                 dDOC_DATE         => dDATE,
                                 nVALID_DOCTYPE    => null,
                                 sVALID_DOCNUMB    => null,
                                 dVALID_DOCDATE    => null,
                                 nOUT_DEPARTMENT   => null,
                                 nOUT_FACEACC      => null,
                                 nOUT_GRAPHPOINT   => null,
                                 nOUT_STORE        => null,
                                 nPARTY_AGENT      => null,
                                 nSTORE            => 20300310, --ВремПеремещение
                                 nAGENT            => rr.agn_rn,
                                 nCURRENCY         => 91318,
                                 nSTORE_OPER       => 11935240,
                                 sPARTY            => null,
                                 sNOTE             => 'Остатки по подотчетникам',
                                 nCURCOURS         => 1,
                                 nCURBASECOURS     => 1,
                                 nCURCOURS_DOC     => 1,
                                 nCURBASECOURS_DOC => 1,
                                 sBARCODE          => null,
                                 nRN               => nPRN);
    -- спецификация
    for rs in (select t.article_rn,
                      t.mnf_numb,
                      t.ser_numb,
                      t.nomen,
                      t.modif,
                      sum(t.quant) as quant
                 from udo_modul_remains_mol t,
                      dicnomns              nm
                where t.ident = nIDENT
                  and t.agn_rn = rr.agn_rn
                  and t.agn_rn is not null
                  and t.ifs_rn is null
                  --and t.fa_rn is not null
                  and t.nomen = nm.rn
                  and (nm.sign_serial = 0 or (nm.sign_serial = 1 and t.article_rn is not null))
                group by t.article_rn,
                         t.mnf_numb,
                         t.ser_numb,
                         t.nomen,
                         t.modif) loop
      if rs.quant > 0 then
        -- партия
        p_incomdoc_getnextnumb(nCOMPANY => nCOMPANY, sNUMBER => sCODE);
        p_incomdoc_base_insert(nCOMPANY     => nCOMPANY,
                               nJUR_PERS    => nJUR_PERS,
                               sCODE        => sCODE,
                               nAGENT       => 92146,
                               nSUBDIV      => null,
                               dENTRY_DATE  => s2d('31.12.2022'),
                               nOUT_PARTY   => 0,
                               nSTOR_SIGN   => 0,
                               nCOMMIS_SIGN => 0,
                               nRN          => nPARTY);
        -- приходная партия
        p_goodsparties_base_insert(nCOMPANY       => nCOMPANY,
                                   nINDOC         => nPARTY,
                                   nNOMMODIF      => rs.modif,
                                   nNOMNMODIFPACK => null,
                                   nSIGNBREAK     => 0,
                                   dEXPIRY_DATE   => null,
                                   sCERTIFICATE   => null,
                                   sSERNUMB       => nvl(rs.mnf_numb, rs.ser_numb),
                                   sBARCODE       => null,
                                   nCOUNTRY       => null,
                                   sGTD           => null,
                                   nPRODUCER      => null,
                                   nSTORAGE_TIME  => null,
                                   nUMEAS_STORAGE => null,
                                   sORIGINAL_NAME => null,
                                   dPROD_DATE     => null,
                                   nRN            => nPARTY);
      
        -- товарный запас
        p_goodssupply_base_insert(nCOMPANY  => nCOMPANY,
                                  nPRN      => nPARTY,
                                  nSTORE    => 20300310,
                                  sCARDNUMB => null,
                                  nRN       => nSUPPLY);
        -- строка
        P_INCOMEFROMDPSPEC_BASE_INSERT(nCOMPANY        => nCOMPANY,
                                       nPRN            => nPRN,
                                       nNOMMODIF       => rs.modif,
                                       nPACK           => null,
                                       nARTICLE        => rs.article_rn,
                                       nCELL           => null,
                                       nPARTY_AGENT    => null,
                                       nSUPPLY         => nSUPPLY,
                                       nQUANT_PLAN     => rs.quant,
                                       nQUANT_FACT     => rs.quant,
                                       nQUANT_PLAN_ALT => 0,
                                       nQUANT_FACT_ALT => 0,
                                       dSROK           => null,
                                       sSERTIFICATE    => null,
                                       nPRICE          => 0,
                                       nPRICEMEAS      => 0,
                                       nSUMM_PLAN      => 0,
                                       nSUMM_FACT      => 0,
                                       sNOTE           => null,
                                       sSERNUMB        => nvl(rs.mnf_numb, rs.ser_numb),
                                       sBARCODE        => null,
                                       nCOUNTRY        => null,
                                       sGTD            => null,
                                       nPRODUCER       => null,
                                       nSTORAGE_TIME   => null,
                                       nUMEAS_STORAGE  => null,
                                       dPROD_DATE      => null,
                                       sCARDNUMB       => null,
                                       nRN             => nSPEC);
        -- добавить калькуляцию
        iCNT := 0;
        for rc in (select t.fa_rn,
                          sum(t.quant) as quant
                     from udo_modul_remains_mol t
                    where t.ident = nIDENT
                      and t.agn_rn = rr.agn_rn
                      and t.agn_rn is not null
                      and t.ifs_rn is null
                      and t.fa_rn is not null
                      and ((t.article_rn is null and rs.article_rn is null) or
                          (t.article_rn is not null and t.article_rn = rs.article_rn))
                      and ((t.mnf_numb is null and rs.mnf_numb is null) or
                          (t.mnf_numb is not null and t.mnf_numb = rs.mnf_numb))
                      and ((t.ser_numb is null and rs.ser_numb is null) or
                          (t.ser_numb is not null and t.ser_numb = rs.ser_numb))
                      and t.nomen = rs.nomen
                      and t.modif = rs.modif
                    group by t.fa_rn) loop
          iCNT := iCNT + 1;
          p_incfdepspclc_base_insert(nCOMPANY      => nCOMPANY,
                                     nPRN          => nSPEC,
                                     sNUMB         => to_char(iCNT),
                                     nCOST_ARTICLE => null,
                                     nCOST_PLACE   => null,
                                     nCOST_PLAN    => null,
                                     nCOST_FACT    => null,
                                     nPRIORITY     => null,
                                     nFACEACCOUNT  => rc.fa_rn,
                                     nGRAPHPOINT   => null,
                                     nFINOPER_TYPE => null,
                                     nQUANT_PLAN   => rc.quant,
                                     nQUANT_FACT   => rc.quant,
                                     nSUBDIV       => null,
                                     nRN           => nRN);
        end loop;
          -- ссылка на спецификацию
          update udo_modul_remains_mol t
             set t.ifs_rn = nSPEC
           where t.ident = nIDENT
             and t.agn_rn = rr.agn_rn
             and t.agn_rn is not null
             and t.ifs_rn is null
             --and t.fa_rn is null
             and ((t.article_rn is null and rs.article_rn is null) or
                 (t.article_rn is not null and t.article_rn = rs.article_rn))
             and ((t.mnf_numb is null and rs.mnf_numb is null) or (t.mnf_numb is not null and t.mnf_numb = rs.mnf_numb))
             and ((t.ser_numb is null and rs.ser_numb is null) or (t.ser_numb is not null and t.ser_numb = rs.ser_numb))
             and t.nomen = rs.nomen
             and t.modif = rs.modif;
      end if;
    end loop;
  end loop;
end;
/

