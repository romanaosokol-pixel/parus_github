create or replace procedure usr_p_iiv_create_inorder
/*
Расходные накладные на отпуск потребителям
Формирование буфера приходной накладной 
( по мотивам P_ININVOICES_CREATE_INORDER )
31/03/2026 Степанов М.
*/
(
 nRN                  in number
,nIDENT               in number
,sSTORE               in varchar2   /* склад получения */
,nORDER_TYPE          in number     /* тип ордера (0 - Приходный ордер, 1 - Акт приёмки товаров, работ, услуг) */
)
as
  rRow                ininvoices%rowtype;
  rV_Row              v_ininvoices%rowtype;
  rInOrdersBuff       inordersbuff%rowtype;
  rInordSpBuff        inordspbuff%rowtype;
  sCatalog            pkg_std.tstring; 
begin
  /* Считывание */
  rRow := usr_pkg_ininvoices.ininvoices_get( nrn => nRN );

  /* Проверка на отработку */
  if rRow.status != 2 then
    p_exception( 0, 'Документ не отработан.%s'
               ,cr||cr|| f_docdescrs_get_description( sunitcode => 'IncomingInvoices', ndocument => rRow.rn ) );
  end if;

  /* буфер для наследования документов: конструктор */
  pkg_inhier.constructor_ext( ncompany => rRow.company, nident => nIDENT );
  /* подготовка к привязке документа */
  pkg_inhier.prep_link( nident => nIDENT );
  /* регистрация входного раздела */
  pkg_inhier.set_in_unit( nident      => nIDENT
                         ,nlevel      => 0
                         ,sunitcode   => 'IncomingInvoices'
                         ,saction     => 'ININVOICES_MAKEINORDERS'
                         ,stablename  => 'ININVOICES' );
  /* регистрация входного раздела 1 */
  pkg_inhier.set_in_unit( nident => nIDENT, nlevel => 1, sunitcode => 'IncomingInvoicesSpecs' );
  /* установка входного документа */
  pkg_inhier.set_in_doc( nident => nIDENT, nlevel => 0, ndocument => rRow.rn, ncatalog => rRow.crn );

  /* регистрация выходного раздела */
  pkg_inhier.set_out_unit( nident => nIDENT, nlevel => 0, sunitcode => 'IncomingOrders' );
  /* регистрация выходного раздела 1 */
  pkg_inhier.set_out_unit( nident => nIDENT, nlevel => 1, sunitcode => 'IncomingOrdersSpecs' );


  /* Заполнение переменных */
  rInOrdersBuff.company := rRow.company;
  sCatalog := get_options_str( scode => 'Realiz_Inorders_Catalog', ncomp_vers => rInOrdersBuff.company );
  find_acatalog_name(nflag_smart => 0
                    ,ncompany    => rInOrdersBuff.company
                    ,nversion    => null
                    ,sunitcode   => 'IncomingOrders'
                    ,sname       => sCatalog
                    ,nrn         => rInOrdersBuff.crn );
  rInOrdersBuff.jur_pers        := rRow.jur_pers;
  rInOrdersBuff.source_crn      := rRow.crn;
  rInOrdersBuff.source_unitcode := 'IncomingInvoices';
  rInOrdersBuff.source_rn       := rRow.rn;
  rInOrdersBuff.ident           := nIDENT;
  rInOrdersBuff.contragent      := rRow.agent;
  rInOrdersBuff.faceacc         := rRow.faceacc;
  rInOrdersBuff.graphpoint      := rRow.graphpoint;
  rInOrdersBuff.party_code      := rRow.party;
  if sSTORE is not null then
    find_dicstore_numb( nflag_smart => 0
                       ,ncompany    => rInOrdersBuff.company
                       ,snumb       => sSTORE
                       ,nrn         => rInOrdersBuff.store );
  else                     
    rInOrdersBuff.store := rRow.store;
  end if;
  rV_Row.sstoreoper := get_options_str( scode => 'Realiz_Inorders_StoreOper', ncomp_vers => rInOrdersBuff.company );
  find_dicstopr_code( nsmart_flag => 0
                     ,ncompany    => rInOrdersBuff.company
                     ,scode       => rV_Row.sstoreoper
                     ,nrn         => rInOrdersBuff.stopertype );

  rV_Row.sdoctype := get_options_str( scode => 'Realiz_Inorders_DocType', ncomp_vers => rInOrdersBuff.company );
  find_doctypes_code_ex( nflag_smart  => 0
                        ,nflag_option => 0
                        ,ncompany     => rInOrdersBuff.company
                        ,scode        => rV_Row.sdoctype
                        ,nrn          => rInOrdersBuff.indoctype );
  rInOrdersBuff.indocpref := get_options_str( scode => 'Realiz_Inorders_Prefix', ncomp_vers => rInOrdersBuff.company );
  rInOrdersBuff.indocdate := rRow.doc_date;
  p_inorders_base_nextnumb( ncompany   => rInOrdersBuff.company
                           ,njur_pers  => rInOrdersBuff.jur_pers
                           ,dindocdate => rInOrdersBuff.indocdate
                           ,nindoctype => rInOrdersBuff.indoctype
                           ,sindocpref => rInOrdersBuff.indocpref
                           ,sindocnumb => rInOrdersBuff.indocnumb );
  rInOrdersBuff.directdoctype   := null;
  rInOrdersBuff.directdocnumb   := null;
  rInOrdersBuff.directdocdate   := null;
  rInOrdersBuff.invdoctype      := rRow.valid_doctype;
  rInOrdersBuff.invdocnumb      := rRow.valid_docnumb;
  rInOrdersBuff.invdocdate      := rRow.valid_docdate;
  rInOrdersBuff.confdoctype     := null;
  rInOrdersBuff.confdocnumb     := null;
  rInOrdersBuff.confdocdate     := null;
  rInOrdersBuff.signtax         := rRow.signtax;
  rInOrdersBuff.currency        := rRow.currency;
  rInOrdersBuff.curcours        := rRow.curcours;
  rInOrdersBuff.curbasecours    := rRow.curbasecours;
  rInOrdersBuff.acc_cours       := rRow.curcours;
  rInOrdersBuff.acc_basecours   := rRow.curbasecours;
  rInOrdersBuff.fa_cours        := rRow.fa_cours;
  rInOrdersBuff.fa_basecours    := rRow.fa_basecours;
  rInOrdersBuff.agent           := rRow.agent;
  rInOrdersBuff.comments        := rRow.note;
  rInOrdersBuff.agnfifo         := rRow.agnfifo;
  rInOrdersBuff.barcode         := rRow.barcode;
  rInOrdersBuff.payconf_type    := rRow.payconf_type;
  rInOrdersBuff.payconf_numb    := rRow.payconf_numb;
  rInOrdersBuff.payconf_date    := rRow.payconf_date;
  rInOrdersBuff.reg_agent       := rRow.reg_agent;
  rInOrdersBuff.order_type      := nORDER_TYPE;
  rInOrdersBuff.customer        := null;
  rInOrdersBuff.place           := null;
  rInOrdersBuff.ship_doctype    := null;
  rInOrdersBuff.ship_docnumb    := null;
  rInOrdersBuff.ship_docdate    := null;
  rInOrdersBuff.insured         := null;
  rInOrdersBuff.period_from     := null;
  rInOrdersBuff.period_to       := null;
  rInOrdersBuff.building        := null;
  rInOrdersBuff.object_name     := null;
  rInOrdersBuff.object_code     := null;
  rInOrdersBuff.sum_work        := null;
  rInOrdersBuff.sum_year        := null;
  rInOrdersBuff.sum_period      := null;

  /* Добавление заголовка */
  usr_pkg_inorders.inordersbuff_base_insert( rrow => rInOrdersBuff, nrn => rInOrdersBuff.rn );

  /* установка буферного документа */
  pkg_inhier.set_buff_doc( nident => nIDENT, nlevel => 0, ndocument => rInOrdersBuff.rn );

  /* По спецификациям текущего документа */
  for c in ( select t.* 
                   ,nm.prn            as nm_prn
              from ininvoicesspecs  t
              join nommodif         nm on nm.rn = t.modif
             where t.prn = rRow.rn )
  loop
    /* установка входного документа 1 */
    pkg_inhier.set_in_doc( nident => nIDENT, nlevel => 1, ndocument => c.rn );
    
    /* Заполнение переменных */
    rInordSpBuff.company         := c.company;
    rInordSpBuff.prn             := rInOrdersBuff.rn;
    rInordSpBuff.nomen           := c.nm_prn;
    rInordSpBuff.nomnpack        := null;
    rInordSpBuff.nommodif        := c.modif;
    rInordSpBuff.nomnmodifpack   := c.pack;
    rInordSpBuff.article         := c.article;
    rInordSpBuff.cell            := null;
    rInordSpBuff.taxgr           := c.taxgr;
    rInordSpBuff.planquant       := c.quant;
    rInordSpBuff.factquant       := c.quant;
    rInordSpBuff.planquantalt    := c.quantalt;
    rInordSpBuff.factquantalt    := c.quantalt;
    rInordSpBuff.price           := c.price;
    rInordSpBuff.pricemeas       := c.pricemeas;
    rInordSpBuff.price_calc_rule := 0;
    rInordSpBuff.nds_coeff_sign  := 0;
    rInordSpBuff.nds_coeff       := null;
    rInordSpBuff.acc_price       := c.price;
    rInordSpBuff.acc_pricemeas   := c.pricemeas;
    rInordSpBuff.expiry_date     := null;
    rInordSpBuff.certificate     := c.sertificate;
    rInordSpBuff.note            := c.note;
    rInordSpBuff.plansum         := c.summ;
    rInordSpBuff.plansumtax      := c.summtax;
    rInordSpBuff.plansumnds      := c.summ_nds;
    rInordSpBuff.factsum         := c.summ;
    rInordSpBuff.factsumtax      := c.summtax;
    rInordSpBuff.factsumnds      := c.summ_nds;
    rInordSpBuff.autocalc_sign   := c.autocalc_sign;
    rInordSpBuff.sernumb         := c.sernumb;
    rInordSpBuff.barcode         := c.barcode;
    rInordSpBuff.country         := c.country;
    rInordSpBuff.gtd             := c.gtd;
    rInordSpBuff.producer        := c.producer;
    rInordSpBuff.storage_time    := c.storage_time;
    rInordSpBuff.umeas_storage   := c.umeas_storage;
    rInordSpBuff.original_name   := c.original_name;
    rInordSpBuff.prod_date       := c.prod_date;
    rInordSpBuff.cardnumb        := null;
    rInordSpBuff.mdmnomen        := c.mdmnomen;
    rInordSpBuff.str_code        := null;
    rInordSpBuff.brak_quant      := null;
    rInordSpBuff.brak_sum        := null;
    rInordSpBuff.country_doc     := null;
    rInordSpBuff.country_fact    := null;
    rInordSpBuff.reg_num         := null;
    rInordSpBuff.mismatch        := null;
    rInordSpBuff.other           := null;

    /* Добавление спецификации в буфер */
    usr_pkg_inorders.inordspbuff_base_insert( rrow => rInordSpBuff, nsource_rn => c.rn, nrn => rInordSpBuff.rn );

    /* Добавление калькуляуции */
    p_ininvoicesspc_make_doc( ncompany    => rInordSpBuff.company
                             ,nprn        => c.rn
                             ,sunitcode   => 'IncomingOrdersSpecsCalcs'
                             ,nbuf_prn    => rInordSpBuff.rn
                             ,nsign_quant => 0
                             ,nquant      => rInordSpBuff.planquant );

    /* установка буферного документа 1 */
    pkg_inhier.set_buff_doc( nident => nIDENT, nlevel => 1, ndocument => rInordSpBuff.rn );
    /* привязка входного документа к буферному */
    pkg_inhier.link_in( nident => nIDENT );

  end loop;

  /* без спецификации */
  if ( rInordSpBuff.rn is null ) then
    /* привязка входного документа к буферному, если не формировалась спецификация */
    pkg_inhier.link_in( nident => nIDENT, nin_level => 0, nout_level => 0 );
  end if;

end;
/
