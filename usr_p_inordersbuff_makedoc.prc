create or replace procedure usr_p_inordersbuff_makedoc
/*
–асходные накладные на отпуск потребител€м
ѕеренос буфера приходной накладной
( по мотивам P_TRANSINVCUSTBUF_MAKEINVBUF )
31/03/2026 —тепанов ћ.
*/
(
 nCOMPANY     in number
,nIDENT       in number
)
as
  rInOrders         inorders%rowtype;
  rInOrderSpecs     inorderspecs%rowtype;
  sINUNIT           unitlist.unitcode%type;
  sINUNIT1          unitlist.unitcode%type;

  nNumber   pkg_std.tnumber;
begin
  /* проверка прав доступа и уточнение параметров св€зывани€ */
  if ( pkg_inhier.check_proc( nident => nIDENT ) = 1) then 
    pkg_inhier.link_prologue( nident => nIDENT );
  end if;

  /* ѕо заголовкам буфера */
  for c in ( select * from inordersbuff where ident = nIDENT )
  loop
    /* «аполнение переменных */
    rInOrders.company       := c.company;
    rInOrders.crn           := c.crn;
    rInOrders.jur_pers      := c.jur_pers;
    rInOrders.contragent    := c.contragent;
    rInOrders.faceacc       := c.faceacc;
    rInOrders.graphpoint    := c.graphpoint;
    rInOrders.party_code    := c.party_code;
    rInOrders.party         := null;
    rInOrders.store         := c.store;
    rInOrders.stopertype    := c.stopertype;
    rInOrders.indoctype     := c.indoctype;
    rInOrders.indocpref     := c.indocpref;
    rInOrders.indocnumb     := c.indocnumb;
    rInOrders.indocdate     := c.indocdate;
    rInOrders.directdoctype := c.directdoctype;
    rInOrders.directdocnumb := c.directdocnumb;
    rInOrders.directdocdate := c.directdocdate;
    rInOrders.invdoctype    := c.invdoctype;
    rInOrders.invdocnumb    := c.invdocnumb;
    rInOrders.invdocdate    := c.invdocdate;
    rInOrders.confdoctype   := c.confdoctype;
    rInOrders.confdocnumb   := c.confdocnumb;
    rInOrders.confdocdate   := c.confdocdate;
    rInOrders.signtax       := c.signtax;
    rInOrders.currency      := c.currency;
    rInOrders.curcours      := c.curcours;
    rInOrders.curbasecours  := c.curbasecours;
    rInOrders.acc_cours     := c.acc_cours;
    rInOrders.acc_basecours := c.acc_basecours;
    rInOrders.fa_cours      := c.fa_cours;
    rInOrders.fa_basecours  := c.fa_basecours;
    rInOrders.agent         := c.agent;
    rInOrders.comments      := c.comments;
    rInOrders.agnfifo       := c.agnfifo;
    rInOrders.barcode       := c.barcode;
    rInOrders.payconf_type  := c.payconf_type;
    rInOrders.payconf_numb  := c.payconf_numb;
    rInOrders.payconf_date  := c.payconf_date;
    rInOrders.reg_agent     := c.reg_agent;
    rInOrders.order_type    := c.order_type;
    rInOrders.customer      := c.customer;        
    rInOrders.place         := c.place;           
    rInOrders.ship_doctype  := c.ship_doctype;
    rInOrders.ship_docnumb  := c.ship_docnumb;    
    rInOrders.ship_docdate  := c.ship_docdate;    
    rInOrders.insured       := c.insured;         
    rInOrders.period_from   := c.period_from;
    rInOrders.period_to     := c.period_to;      
    rInOrders.building      := c.building;       
    rInOrders.object_name   := c.object_name;    
    rInOrders.object_code   := c.object_code;    
    rInOrders.sum_work      := c.sum_work;       
    rInOrders.sum_year      := c.sum_year;       
    rInOrders.sum_period    := c.sum_period;

    /* ƒобавление заголовка */
    usr_pkg_inorders.inorders_base_insert( rrow => rInOrders, nrn => rInOrders.rn );

    /* создание св€зей */
    if ( pkg_inhier.check_proc( nident => nIDENT ) = 1) then
      pkg_inhier.get_in_doc( nident       => nIDENT
                            ,nbuff_level  => 0
                            ,nbuff_doc    => c.rn
                            ,nin_level    => 0
                            ,sin_unit     => sINUNIT
                            ,nin_doc      => nNumber );
      if ( sINUNIT != 'FaceAccounts' ) then
        /* прив€зка буферного документа к выходному */
        pkg_inhier.link_buff( nident    => nIDENT
                             ,nlevel    => 0
                             ,nbuff_doc => c.rn
                             ,nout_doc  => rInOrders.rn );
        /* прив€зка входного и выходного документов через документооборот */
        pkg_inhier.link_docs( nident => nIDENT, nlevel => 0, nout_doc => rInOrders.rn );
      end if;
    end if;

    /* ѕо спецификаци€м буфера */
    for c1 in ( select * from inordspbuff where ident = nIDENT and prn = c.rn )
    loop
      /* «аполнение переменных */
      rInOrderSpecs.company         := c1.company;
      rInOrderSpecs.prn             := rInOrders.rn;
      rInOrderSpecs.nommodif        := c1.nommodif;
      rInOrderSpecs.nomnmodifpack   := c1.nomnmodifpack;
      rInOrderSpecs.article         := c1.article;
      rInOrderSpecs.cell            := c1.cell;
      rInOrderSpecs.taxgr           := c1.taxgr;
      rInOrderSpecs.planquant       := c1.planquant;
      rInOrderSpecs.factquant       := c1.factquant;
      rInOrderSpecs.planquantalt    := c1.planquantalt;
      rInOrderSpecs.factquantalt    := c1.factquantalt;
      rInOrderSpecs.price           := c1.price;
      rInOrderSpecs.pricemeas       := c1.pricemeas;
      rInOrderSpecs.price_calc_rule := c1.price_calc_rule;
      rInOrderSpecs.nds_coeff_sign  := c1.nds_coeff_sign;
      rInOrderSpecs.nds_coeff       := c1.nds_coeff;
      rInOrderSpecs.acc_price       := c1.acc_price;
      rInOrderSpecs.acc_pricemeas   := c1.acc_pricemeas;
      rInOrderSpecs.expiry_date     := c1.expiry_date;
      rInOrderSpecs.certificate     := c1.certificate;
      rInOrderSpecs.note            := c1.note;
      rInOrderSpecs.plansum         := c1.plansum;
      rInOrderSpecs.plansumtax      := c1.plansumtax;
      rInOrderSpecs.plansumnds      := c1.plansumnds;
      rInOrderSpecs.factsum         := c1.factsum;
      rInOrderSpecs.factsumtax      := c1.factsumtax;
      rInOrderSpecs.factsumnds      := c1.factsumnds;
      rInOrderSpecs.autocalc_sign   := c1.autocalc_sign;
      rInOrderSpecs.sernumb         := c1.sernumb;
      rInOrderSpecs.barcode         := c1.barcode;
      rInOrderSpecs.country         := c1.country;
      rInOrderSpecs.gtd             := c1.gtd;
      rInOrderSpecs.producer        := c1.producer;
      rInOrderSpecs.storage_time    := c1.storage_time;
      rInOrderSpecs.umeas_storage   := c1.umeas_storage;
      rInOrderSpecs.original_name   := c1.original_name;
      rInOrderSpecs.prod_date       := c1.prod_date;
      rInOrderSpecs.cardnumb        := c1.cardnumb;
      rInOrderSpecs.mdmnomen        := c1.mdmnomen;
      rInOrderSpecs.str_code        := c1.str_code;
      rInOrderSpecs.brak_quant      := c1.brak_quant;
      rInOrderSpecs.brak_sum        := c1.brak_sum;
      rInOrderSpecs.country_doc     := c1.country_doc;
      rInOrderSpecs.country_fact    := c1.country_fact;
      rInOrderSpecs.reg_num         := c1.reg_num;
      rInOrderSpecs.mismatch        := c1.mismatch;
      rInOrderSpecs.other           := c1.other;

      /* ƒобавление спецификации */
      usr_pkg_inorders.inorderspecs_base_insert( rrow => rInOrderSpecs, ndup_rn => null, ndup_clc => 1, nrn => rInOrderSpecs.rn );

      /* копирование свойств из спецификации приходной накладной */
      if ( c.source_unitcode = 'IncomingInvoices' ) then
        pkg_docs_props_vals.copy( sunitcode_from => 'IncomingInvoicesSpecs'
                                 ,ndocument_from => c1.source_rn
                                 ,sunitcode_to   => 'IncomingOrdersSpecs'
                                 ,ndocument_to   => rInOrderSpecs.rn );
      /* ... спецификации образцов товарных документов */
      elsif ( c.source_unitcode = 'GoodsTransInvoicesToConsumersModels' ) then
        pkg_docs_props_vals.copy( sunitcode_from => 'GoodsTransInvoicesToConsumersModelsSpecs'
                                 ,ndocument_from => c1.source_rn
                                 ,sunitcode_to   => 'IncomingOrdersSpecs'
                                 ,ndocument_to   => rInOrderSpecs.rn );
      end if;

      /* перенос калькул€ции строк */
      p_inordspclcbuff_replace( ncompany => rInOrderSpecs.company
                               ,nident   => nIDENT
                               ,nbuf_prn => c1.rn
                               ,nprn     => rInOrderSpecs.rn );

      /* создание св€зей */
      if ( pkg_inhier.check_proc( nident => nIDENT ) = 1 ) then
        pkg_inhier.get_in_doc( nident       => nIDENT
                              ,nbuff_level  => 1
                              ,nbuff_doc    => c1.rn
                              ,nin_level    => 1
                              ,sin_unit     => sINUNIT1
                              ,nin_doc      => nNumber );
        if ( sINUNIT !='FaceAccounts' ) and
           ( ( pkg_inordersbuff_param.vinord_param.nis_oth_company = 0) or ( sINUNIT != 'GoodsTransInvoicesToConsumers') ) then
          /* прив€зка буферного документа к выходному */
          pkg_inhier.link_buff( nident => nIDENT, nlevel => 1, nbuff_doc => c1.rn, nout_doc => rInOrderSpecs.rn );
          /* прив€зка входных документов и выходного документа 1 через документооборот */
          pkg_inhier.link_docs( nident => nIDENT, nlevel => 1, nout_doc => rInOrderSpecs.rn );
        end if;
      end if;

    end loop;

    if ( c.source_unitcode = 'GoodsTransInvoicesToConsumersModels' ) then
      /* фиксаци€ начала выполнени€ действи€ */
      pkg_env.epilogue( ncompany  => nCOMPANY
                       ,nversion  => null
                       ,ncatalog  => C.CRN
                       ,sunit     => 'IncomingOrders'
                       ,saction   => 'INORDERS_INSERT'
                       ,stable    => 'INORDERS'
                       ,ndocument => rInOrders.rn );
    end if;
  end loop;

  /* окончание прив€зки документов */
  if ( pkg_inhier.check_proc( nident => nIDENT ) = 1) then
    if ( sINUNIT != 'FaceAccounts' ) and
       ( ( pkg_inordersbuff_param.vinord_param.nis_oth_company = 0) or (sINUNIT != 'GoodsTransInvoicesToConsumers') ) then
      /* наследование свойств документов */
      pkg_inhier.inhr_props( nident => nIDENT );
    end if;
    /* фиксаци€ окончани€ прив€зки входного и выходного документов через документооборот */
    pkg_inhier.link_epilogue( nident => nIDENT );
    /* вызов деструктора */
    pkg_inhier.destructor( nident => nIDENT );
  end if;

  /* очистка буфера */
  pkg_inordersbuff_param.clear_param;

end;
/
