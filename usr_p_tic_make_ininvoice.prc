create or replace procedure usr_p_tic_make_ininvoice
/*
Расходные накладные на отпуск потребителям
Формирование буфера приходной накладной
( по мотивам P_TRANSINVCUST_MAKEINVOICE )
31/03/2026 Степанов М.
*/
(
 nRN          in number  
,nIDENT       in number  
,sCATALOG     in varchar2
,sDOCTYPE     in varchar2
,sPREF        in varchar2
,dDOCDATE     in date
,sEXT_NUMB    in varchar2
,dDEXT_DATE   in date
,sSTORE       in varchar2
,sSTOREOPER   in varchar2
,sFACEACC     in varchar2
)
as
  rRow                transinvcust%rowtype;
  rInInvoicesBuff     ininvoicesbuff%rowtype;
  rInInvoicesSpBuff   ininvoicesspbuff%rowtype;
  rFaceAcc            faceacc%rowtype;
begin
  /* Считывание */
  rRow := usr_pkg_transinvcust.transinvcust_get( nrn => nRN );

  /* Проверка на отработку */
  if rRow.status != 1 then
    p_exception( 0, 'Документ не отработан.%s'
               ,cr||cr|| f_docdescrs_get_description( sunitcode => 'GoodsTransInvoicesToConsumers', ndocument => rRow.rn ) ); 
  end if;

  /* буфер для наследования документов: конструктор */
  pkg_inhier.constructor_ext( ncompany => rRow.company, nident => nIDENT );
  /* подготовка к привязке документа */
  pkg_inhier.prep_link( nident => nIDENT );
  /* регистрация входного раздела */
  pkg_inhier.set_in_unit( nident      => nIDENT
                         ,nlevel      => 0
                         ,sunitcode   => 'GoodsTransInvoicesToConsumers'
                         ,saction     => 'TRANSINVCUST_MAKEININV'
                         ,stablename  => 'TRANSINVCUST' );
  /* регистрация входного раздела 1 */
  pkg_inhier.set_in_unit( nident => nIDENT, nlevel => 1, sunitcode => 'GoodsTransInvoicesToConsumersSpecs' );
  /* регистрация выходного раздела */
  pkg_inhier.set_out_unit( nident => nIDENT, nlevel => 0, sunitcode => 'IncomingInvoices' );
  /* регистрация выходного раздела 1 */
  pkg_inhier.set_out_unit( nident => nIDENT, nlevel => 1, sunitcode => 'IncomingInvoicesSpecs' );
  /* установка входного документа */
  pkg_inhier.set_in_doc( nident => nIDENT, nlevel => 0, ndocument => rRow.rn, ncatalog => rRow.crn );
  
  /* Заполнение переменных */
  rInInvoicesBuff.source_rn       := rRow.rn;
  rInInvoicesBuff.source_unitcode := 'GoodsTransInvoicesToConsumers';
  rInInvoicesBuff.company         := rRow.company;
  find_acatalog_name(nflag_smart => 0
                    ,ncompany    => rInInvoicesBuff.company
                    ,nversion    => null
                    ,sunitcode   => 'IncomingInvoices'
                    ,sname       => sCATALOG
                    ,nrn         => rInInvoicesBuff.crn );
  rInInvoicesBuff.ident         := nIDENT;
  rInInvoicesBuff.jur_pers      := rRow.jur_pers;

  if sDOCTYPE is not null then
    find_doctypes_code_ex( nflag_smart  => 0
                          ,nflag_option => 0
                          ,ncompany     => rInInvoicesBuff.company
                          ,scode        => sDOCTYPE
                          ,nrn          => rInInvoicesBuff.doctype );
  else                        
    rInInvoicesBuff.doctype     := rRow.doctype;
  end if;

  rInInvoicesBuff.pref          := sPREF;
  rInInvoicesBuff.doc_date      := dDOCDATE;
  p_ininvoices_base_nextnumb( ncompany  => rInInvoicesBuff.company
                             ,njur_pers => rInInvoicesBuff.jur_pers
                             ,ddoc_date => rInInvoicesBuff.doc_date
                             ,ndoctype =>  rInInvoicesBuff.doctype
                             ,spref     => rInInvoicesBuff.pref
                             ,snumb     => rInInvoicesBuff.numb );
  rInInvoicesBuff.servact_sign  := rRow.servact_sign;
  rInInvoicesBuff.ext_numb      := sEXT_NUMB;
  rInInvoicesBuff.ext_date      := dDEXT_DATE;
  rInInvoicesBuff.valid_doctype := null;
  rInInvoicesBuff.valid_docnumb := null;
  rInInvoicesBuff.valid_docdate := null;

  if sSTORE is not null then
    find_dicstore_numb( nflag_smart => 0
                       ,ncompany    => rInInvoicesBuff.company
                       ,snumb       => sSTORE
                       ,nrn         => rInInvoicesBuff.store );
  else                     
    rInInvoicesBuff.store       := rRow.store;
  end if;

  rInInvoicesBuff.party         := null;
  
  if sFACEACC is not null then
    find_faceacc_by_numb( ncompany => rInInvoicesBuff.company, snumber => sFACEACC, nrn => rFaceAcc.rn );
    rFaceAcc := usr_pkg_faceacc.faceacc_get( nrn => rFaceAcc.rn );
    rInInvoicesBuff.faceacc     := rFaceAcc.rn;
    rInInvoicesBuff.agent       := rFaceAcc.agent;
  else
    rInInvoicesBuff.faceacc     := rRow.faceacc;
    rInInvoicesBuff.agent       := rRow.agent;
  end if;

  rInInvoicesBuff.graphpoint    := rRow.graphpoint;
  rInInvoicesBuff.currency      := rRow.currency;
  find_dicstopr_code( nsmart_flag => 0
                     ,ncompany    => rInInvoicesBuff.company
                     ,scode       => sSTOREOPER
                     ,nrn         => rInInvoicesBuff.storeoper );
  rInInvoicesBuff.curcours      := rRow.curcours;
  rInInvoicesBuff.curbasecours  := rRow.curbase;
  rInInvoicesBuff.signtax       := 1;
  rInInvoicesBuff.note          := rRow.comments;
  rInInvoicesBuff.fa_cours      := rRow.fa_cours;
  rInInvoicesBuff.fa_basecours  := rRow.fa_basecours;
  rInInvoicesBuff.agnfifo       := rRow.agnfifo;
  rInInvoicesBuff.discount      := rRow.discount;
  rInInvoicesBuff.barcode       := rRow.barcode;
  rInInvoicesBuff.payconf_type  := null;
  rInInvoicesBuff.payconf_numb  := null;
  rInInvoicesBuff.payconf_date  := null;
  rInInvoicesBuff.reg_agent     := rRow.reg_agent;

  /* Добавление заголовка в буфер */
  usr_pkg_ininvoices.InInvoicesBuff_base_insert( rrow => rInInvoicesBuff, nrn => rInInvoicesBuff.rn );

  /* установка буферного документа */
  pkg_inhier.set_buff_doc( nident => nIDENT, nlevel => 0, ndocument => rInInvoicesBuff.rn );

  /* По спецификациям текущего документа */
  for c in ( select t.* 
                   ,nm.prn            as nm_prn
                   ,gp.sernumb        as gp_sernumb
                   ,gp.country        as gp_country
                   ,gp.gtd            as gp_gtd
                   ,gp.producer       as gp_producer
                   ,gp.barcode        as gp_barcode
                   ,gp.expiry_date    as gp_expiry_date
                   ,gp.certificate    as gp_certificate
                   ,gp.storage_time   as gp_storage_time
                   ,gp.umeas_storage  as gp_umeas_storage
                   ,gp.original_name  as gp_original_name
                   ,gp.prod_date      as gp_prod_date
              from transinvcustspecs t
              join nommodif          nm on nm.rn = t.nommodif
              join goodsparties      gp on gp.rn = t.goodsparty
             where t.prn = rROW.rn )
  loop
    /* установка входного документа 1 */
    pkg_inhier.set_in_doc( nident => nIDENT, nlevel => 1, ndocument => c.rn );
    
    /* Заполнение переменных */
    rInInvoicesSpBuff.company            := c.company;
    rInInvoicesSpBuff.prn                := rInInvoicesBuff.rn;
    rInInvoicesSpBuff.crn                := rInInvoicesBuff.crn;
    rInInvoicesSpBuff.ident              := nIDENT;
    rInInvoicesSpBuff.nomen              := c.nm_prn;
    rInInvoicesSpBuff.modif              := c.nommodif;
    rInInvoicesSpBuff.pack               := c.nomnmodifpack;
    rInInvoicesSpBuff.article            := c.article;
    rInInvoicesSpBuff.taxgr              := c.taxgr;
    rInInvoicesSpBuff.store              := null;
    rInInvoicesSpBuff.quant              := c.quant;
    rInInvoicesSpBuff.quantalt           := c.quantalt;
    rInInvoicesSpBuff.price              := c.price;
    rInInvoicesSpBuff.pricemeas          := c.pricemeas;
    rInInvoicesSpBuff.summ               := c.summ;
    rInInvoicesSpBuff.summtax            := c.summwithnds;
    rInInvoicesSpBuff.summ_nds           := c.summ_nds;
    rInInvoicesSpBuff.autocalc_sign      := c.autocalc_sign;
    rInInvoicesSpBuff.srok               := c.gp_expiry_date;
    rInInvoicesSpBuff.sertificate        := c.gp_certificate;
    rInInvoicesSpBuff.note               := c.note;
    rInInvoicesSpBuff.begindate          := c.begindate;
    rInInvoicesSpBuff.enddate            := c.enddate;
    rInInvoicesSpBuff.sernumb            := c.gp_sernumb;
    rInInvoicesSpBuff.barcode            := c.gp_barcode;
    rInInvoicesSpBuff.country            := c.gp_country;
    rInInvoicesSpBuff.gtd                := c.gp_gtd;
    rInInvoicesSpBuff.producer           := c.gp_producer;
    rInInvoicesSpBuff.storage_time       := c.gp_storage_time;
    rInInvoicesSpBuff.umeas_storage      := c.gp_umeas_storage;
    rInInvoicesSpBuff.discount           := c.discount;
    rInInvoicesSpBuff.original_name      := c.gp_original_name;
    rInInvoicesSpBuff.prod_date          := c.gp_prod_date;

    /* Добавление спецификации в буфер */
    usr_pkg_ininvoices.ininvoicesspbuff_base_insert(rrow => rInInvoicesSpBuff, nrn => rInInvoicesSpBuff.rn );

    /* установка буферного документа 1 */
    pkg_inhier.set_buff_doc( nident => nIDENT, nlevel => 1, ndocument => rInInvoicesSpBuff.rn );
    /* привязка входного документа к буферному */
    pkg_inhier.link_in( nident => nIDENT );

  end loop;

  /* без спецификации */
  if ( rInInvoicesSpBuff.rn is null ) then
    /* привязка входного документа к буферному, если не формировалась спецификация */
    pkg_inhier.link_in( nident => nIDENT, nin_level => 0, nout_level => 0 );
  end if;

end;
/
