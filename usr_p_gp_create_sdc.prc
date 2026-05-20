create or replace procedure USR_P_GP_CREATE_SDC
/*
Раздел: Приходные партии товара. 
Формирование Распоряжения на отгрузку потребителям по отмечанным записям
12/12/2023 Степанов М.
*/
(
 nCOMPANY       in number
,nIDENT         in number
,sSTORE         in varchar2
)
is
  sACatalog             pkg_std.tstring; 
  nStore                pkg_std.tref; 
  nCRN                  pkg_std.tref;
  nSheepDirsCust        pkg_std.tref;
  rSheepDirsCust        sheepdirscust%rowtype;
  sDocType              pkg_std.tstring; 
  rSheepDirsCustSpecs   sheepdirscustspecs%rowtype;
  rFcAcOperPlans        fcacoperplans%rowtype;
  sMessage              pkg_std.tstring; 
  nCount                pkg_std.tnumber := 0; 

  nNumber         pkg_std.tnumber; 
begin
  /* Склад RN */
  find_dicstore_numb(nflag_smart => 0
                    ,ncompany    => nCOMPANY
                    ,snumb       => sSTORE
                    ,nrn         => nStore);
  /* Каталог распоряжений */
  sACatalog := get_options_str(scode => 'Realiz_DirectCust_Catalog', ncomp_vers => nCOMPANY);
  find_acatalog_name(nflag_smart => 0
                    ,ncompany    => nCOMPANY
                    ,nversion    => null
                    ,sunitcode   => 'SheepDirectToConsumers'
                    ,sname       => sACatalog
                    ,nrn         => nCRN);

/*
  \* Пролог *\
  pkg_env.prologue(ncompany   => rRow.company
                  ,nversion   => null
                  ,ncatalog   => rRow.crn
                  ,njur_pers  => rRow.jur_pers
                  ,nhierarchy => null
                  ,sunit      => 'Contracts'
                  ,saction    => 'CONTRACTS_UPDATE'
                  ,stable     => 'CONTRACTS'
                  ,ndocument  => rRow.rn);
*/

  /* Заполнение полей для заголовков */
  rSheepDirsCust.company    := nCOMPANY;
  rSheepDirsCust.crn        := nCRN;
  sDocType := get_options_str(scode => 'Realiz_DirectCust_DocType', ncomp_vers => nCOMPANY);
  find_doctypes_code(ncompany  => nCOMPANY
                    ,sdoccode  => sDocType
                    ,sunitcode => 'SheepDirectToConsumers'
                    ,nstype    => 0
                    ,nrn       => rSheepDirsCust.doctype);
  rSheepDirsCust.pref           := get_options_str(scode => 'Realiz_DirectCust_Prefix', ncomp_vers => nCOMPANY);
  rSheepDirsCust.docdate        := current_date;
  rSheepDirsCust.auto_curcours  := 1;
  rSheepDirsCust.saledate       := current_date;
  rSheepDirsCust.store          := nStore;
  find_agnlist_code(nflag_smart  => 0
                   ,nflag_option => 0
                   ,ncompany     => nCOMPANY
                   ,scode        => get_options_str(scode => 'Realiz_DirectCust_Director', ncomp_vers => nCOMPANY)
                   ,nrn          => rSheepDirsCust.director);
  find_dicstopr_code(nsmart_flag => 0
                    ,ncompany    => nCOMPANY
                    ,scode       => get_options_str(scode => 'Realiz_DirectCust_StoreOper', ncomp_vers => nCOMPANY)
                    ,nrn         => rSheepDirsCust.stoper);
  find_dicshpvw_code(nflag_smart => 0
                    ,ncompany    => nCOMPANY
                    ,scode       => get_options_str(scode => 'Realiz_DirectCust_ShipType', ncomp_vers => nCOMPANY)
                    ,nrn         => rSheepDirsCust.sheepview);
  find_dicpayvw_code(nsmart_flag => 0
                    ,ncompany    => nCOMPANY
                    ,scode       => get_options_str(scode => 'Realiz_DirectCust_PayType', ncomp_vers => nCOMPANY)
                    ,nrn         => rSheepDirsCust.paytype);
  find_dictarif_code(nflag_smart => 0
                    ,ncompany    => nCOMPANY
                    ,scode       => get_options_str(scode => 'Realiz_DirectCust_Tariff', ncomp_vers => nCOMPANY)
                    ,nfrn        => rSheepDirsCust.tarif);
  rSheepDirsCust.curcours     := 1;
  rSheepDirsCust.curbase      := 1;
  rSheepDirsCust.fa_cours     := 1;
  rSheepDirsCust.fa_basecours := 1;
  rSheepDirsCust.discount     := 0;
  rSheepDirsCust.summ         := 0;
  rSheepDirsCust.summwithnds  := 0;
  rSheepDirsCust.sheepsumm    := 0;
  find_agnlist_by_mnemo(nflag_smart => 0
                       ,ncompany    => nCOMPANY
                       ,sagnabbr    => get_options_str(scode => 'Realiz_DirectCust_MOL', ncomp_vers => nCOMPANY)
                       ,nrn         => rSheepDirsCust.acc_agent);
  find_subdivs_code(nflag_smart => 0
                   ,ncompany    => nCOMPANY
                   ,scode       => get_options_str(scode => 'Realiz_DirectCust_SubDiv', ncomp_vers => nCOMPANY)
                   ,nrn         => rSheepDirsCust.subdiv);

  /* По отмеченным приходным партиям товара с ненулевым остатком */
  for c in (
            select gsc.faceacc_cust
                  ,lead(gsc.faceacc_cust, 1) over(order by gsc.faceacc_cust) as faceacc_cust_next
                  ,gsc.faceacc_cust_agent
                  ,gsc.faceacc_cust_currency
                  ,gsc.st_taxgr
                  ,gsc.faceacc
                  ,gssa.article
                  ,icd.code as icd_code
                  ,gs.restfact
                  ,gp.*
              from selectlist     sl
                  ,goodsparties   gp
                  ,incomdoc       icd
                  ,goodssupply    gs
                  ,articlessupply gssa
                  ,(
                    select t.prn
                          ,fa.rn        as faceacc
                          ,fa.agent     as faceacc_cust_agent
                          ,fa.currency  as faceacc_cust_currency
                          ,st.taxgr     as st_taxgr
                          ,coalesce(
                                    (select faceacccust
                                       from projectstage
                                      where faceacc = t.faceacc)
                                   ,(select faceacc
                                       from stages
                                      where rn = udo_f_stages_get_fc(nrn => t.faceacc))
                                   ) as faceacc_cust
                      from goodssupplyclc t
                          ,faceacc        fa
                          ,stages         st
                     where t.faceacc = fa.rn
                       and fa.rn     = st.faceacc(+)
                   ) gsc
             where sl.ident     = nIDENT
               and gp.rn        = sl.document
               and icd.rn       = gp.indoc
               and gs.prn       = gp.rn
               and gs.store     = nStore
               and gs.restfact != 0
               and gs.rn        = gsc.prn(+)
               and gs.rn        = gssa.prn(+)
             order by gsc.faceacc_cust
           )
  loop
    /* Счётчик */
    nCount := nCount + 1;

    /* Не найден лицевой счёт продажи */
    if c.faceacc_cust is null then
      sMessage := cr||'Приходная партия RN: '||c.rn;
      sMessage := strcombine(sMessage, usr_pkg_dicnomns.nommodif_get_code_by_rn(nflagsmart => 1, nrn => c.nommodif), cr||'Модификация: ');
      sMessage := strcombine(sMessage, c.restfact, cr||'Количество: ');
      sMessage := strcombine(sMessage, f_rlarticles_get_code(narticle => c.article), cr||'Изделие: ');
      sMessage := strcombine(sMessage, c.icd_code, cr||'Партия: ');
      sMessage := strcombine(sMessage, c.sernumb, cr||'Серия: ');
      sMessage := strcombine(sMessage, get_faceacc_numb_id(nflag_smart => 1, nrn => c.faceacc), cr||'Лицевой счёт затрат: ');
      p_exception(0, 'Невозможно определить лицевой счёт договора продажи для товарного запаса. %s', sMessage); 
    end if;

    /* Добавление заголовка */
    /* если в следующей записи другой ЛС и не пустой или первая запись */
    if (cmp_num(c.faceacc_cust, c.faceacc_cust_next) != 1 and c.faceacc_cust_next is not null) or nCount = 1 then
      rSheepDirsCust.jur_pers   := c.jur_pers;
      p_sheepdirscust_getnextnumb(ncompany => rSheepDirsCust.company
                                 ,stype    => sDocType
                                 ,spref    => rSheepDirsCust.pref
                                 ,snumb    => rSheepDirsCust.numb);
      rSheepDirsCust.faceacc  := c.faceacc_cust;
      rSheepDirsCust.agent    := c.faceacc_cust_agent;
      rSheepDirsCust.currency := c.faceacc_cust_currency;
      usr_pkg_sheepdirscust.sheepdirscust_base_insert(rrow         => rSheepDirsCust
                                                     ,nreserv_sign => 0
                                                     ,nrn          => nSheepDirsCust);
    end if;

    /* Добавление спецификации */
    rSheepDirsCustSpecs.company     := rSheepDirsCust.company;
    rSheepDirsCustSpecs.prn         := nSheepDirsCust;
    rSheepDirsCustSpecs.taxgr       := c.st_taxgr;
    rSheepDirsCustSpecs.goodsparty  := c.rn;
    rSheepDirsCustSpecs.nommodif    := c.nommodif;
    rSheepDirsCustSpecs.article     := c.article;
/*    usr_pkg_faceacc.fcacoperplans_get_by_params(ntoo_many_rows => 1
                                               ,nprn           => rSheepDirsCust.faceacc
                                               ,ninexp_sign    => 1
                                               ,nnommodif      => c.nommodif
                                               ,ntaxgr         => c.st_taxgr
                                               ,rrow           => rFcAcOperPlans);
    pkg_dictaxis_calc.p_calculate_base(nflag_smart => 0
                                      ,ncompany    => c.company
                                      ,ddate       => current_date
                                      ,nsumm_sign  => 1
                                      ,ninsumm     => rFcAcOperPlans.summwithnds
                                      ,ntaxgr      => c.st_taxgr
                                      ,nquant      => 1
                                      ,nncp_sign   => 1);*/
    rSheepDirsCustSpecs.price    := /*pkg_dictaxis_calc.f_get_value(nident => 0) / c.restfact*/0;
    rSheepDirsCustSpecs.discount := 0;
    rSheepDirsCustSpecs.quant    := c.restfact;
    rSheepDirsCustSpecs.quantalt := 0;
    rSheepDirsCustSpecs.coeff    := 0;
    rSheepDirsCustSpecs.coeff_val_sign  := 0;
    rSheepDirsCustSpecs.coeff_calc_sign := 0;
    rSheepDirsCustSpecs.pricemeas       := 0; 
    rSheepDirsCustSpecs.summ        := pkg_dictaxis_calc.f_get_value(nident => 0);
    rSheepDirsCustSpecs.summwithnds := pkg_dictaxis_calc.f_get_value(nident => 2);
    rSheepDirsCustSpecs.summ_nds    := pkg_dictaxis_calc.f_get_value(nident => 8);
    rSheepDirsCustSpecs.autocalc_sign := 1; 
    usr_pkg_sheepdirscust.sheepdirscustspecs_base_insert(rrow => rSheepDirsCustSpecs, nrn => nNumber);
  end loop;

/*  \* Эпилог *\
  pkg_env.epilogue(ncompany   => rRow.company
                  ,nversion   => null
                  ,ncatalog   => rRow.crn
                  ,njur_pers  => rRow.jur_pers
                  ,nhierarchy => null
                  ,sunit      => 'Contracts'
                  ,saction    => 'CONTRACTS_UPDATE'
                  ,stable     => 'CONTRACTS'
                  ,ndocument  => rRow.rn);*/
end USR_P_GP_CREATE_SDC;
/
