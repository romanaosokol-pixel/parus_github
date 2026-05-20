create or replace procedure usr_p_ticbuf_make_ininvoicebuf
/*
–асходные накладные на отпуск потребител€м
ѕеренос буфера приходной накладной
( по мотивам P_TRANSINVCUSTBUF_MAKEINVBUF )
31/03/2026 —тепанов ћ.
*/
(
 nCOMPANY       in number
,nIDENT       in number
)
as
  rInInvoices       ininvoices%rowtype;
  rInInvoicesSpecs  ininvoicesspecs%rowtype;
  sINUNIT           unitlist.unitcode%type;
  sINUNIT1          unitlist.unitcode%type;

  nNumber   pkg_std.tnumber;
begin
  /* проверка прав доступа и уточнение параметров св€зывани€ */
  if ( pkg_inhier.check_proc( nident => nIDENT ) = 1) then -- только если документы будут св€зыватьс€
    pkg_inhier.link_prologue( nident => nIDENT );
  end if;

  /* ѕо заголовкам буфера */
  for c in ( select * from ininvoicesbuff where ident = nIDENT )
  loop
    /* «аполнение переменных */
    rInInvoices.company       := c.company;
    rInInvoices.crn           := c.crn;
    rInInvoices.jur_pers      := c.jur_pers;
    rInInvoices.doctype       := c.doctype;
    rInInvoices.pref          := c.pref;
    rInInvoices.numb          := c.numb;
    rInInvoices.doc_date      := c.doc_date;
    rInInvoices.servact_sign  := c.servact_sign;
    rInInvoices.ext_numb      := c.ext_numb;
    rInInvoices.ext_date      := c.ext_date;
    rInInvoices.valid_doctype := c.valid_doctype;
    rInInvoices.valid_docnumb := c.valid_docnumb;
    rInInvoices.valid_docdate := c.valid_docdate;
    rInInvoices.store         := c.store;
    rInInvoices.party         := c.party;
    rInInvoices.faceacc       := c.faceacc;
    rInInvoices.graphpoint    := c.graphpoint;
    rInInvoices.agent         := c.agent;
    rInInvoices.currency      := c.currency;
    rInInvoices.storeoper     := c.storeoper;
    rInInvoices.curcours      := c.curcours;
    rInInvoices.curbasecours  := c.curbasecours;
    rInInvoices.signtax       := c.signtax;
    rInInvoices.note          := c.note;
    rInInvoices.fa_cours      := c.fa_cours;
    rInInvoices.fa_basecours  := c.fa_basecours;
    rInInvoices.agnfifo       := c.agnfifo;
    rInInvoices.discount      := c.discount;
    rInInvoices.barcode       := c.barcode;
    rInInvoices.payconf_type  := c.payconf_type;
    rInInvoices.payconf_numb  := c.payconf_numb;
    rInInvoices.payconf_date  := c.payconf_date;
    rInInvoices.reg_agent     := c.reg_agent;

    /* ƒобавление заголовка */
    usr_pkg_ininvoices.ininvoices_base_insert( rrow => rInInvoices, nrn => rInInvoices.rn );

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
                             ,nout_doc  => rInInvoices.rn );
        /* прив€зка входного и выходного документов через документооборот */
        pkg_inhier.link_docs( nident    => nIDENT
                             ,nlevel    => 0
                             ,nout_doc  => rInInvoices.rn );

      end if;
    end if;

    /* ѕо спецификаци€м буфера */
    for c1 in ( select * from ininvoicesspbuff where ident = nIDENT and prn = c.RN )
    loop
      /* «аполнение переменных */
      rInInvoicesSpecs.company            := c1.company;
      rInInvoicesSpecs.prn                := rInInvoices.rn;
      rInInvoicesSpecs.nomen              := c1.nomen;
      rInInvoicesSpecs.modif              := c1.modif;
      rInInvoicesSpecs.pack               := c1.pack;
      rInInvoicesSpecs.article            := c1.article;
      rInInvoicesSpecs.taxgr              := c1.taxgr;
      rInInvoicesSpecs.store              := c1.store;
      rInInvoicesSpecs.quant              := c1.quant;
      rInInvoicesSpecs.quantalt           := c1.quantalt;
      rInInvoicesSpecs.price              := c1.price;
      rInInvoicesSpecs.pricemeas          := c1.pricemeas;
      rInInvoicesSpecs.summ               := c1.summ;
      rInInvoicesSpecs.summtax            := c1.summtax;
      rInInvoicesSpecs.summ_nds           := c1.summ_nds;
      rInInvoicesSpecs.autocalc_sign      := c1.autocalc_sign;
      rInInvoicesSpecs.srok               := c1.srok;
      rInInvoicesSpecs.sertificate        := c1.sertificate;
      rInInvoicesSpecs.note               := c1.note;
      rInInvoicesSpecs.begindate          := c1.begindate;
      rInInvoicesSpecs.enddate            := c1.enddate;
      rInInvoicesSpecs.sernumb            := c1.sernumb;
      rInInvoicesSpecs.barcode            := c1.barcode;
      rInInvoicesSpecs.country            := c1.country;
      rInInvoicesSpecs.gtd                := c1.gtd;
      rInInvoicesSpecs.producer           := c1.producer;
      rInInvoicesSpecs.storage_time       := c1.storage_time;
      rInInvoicesSpecs.umeas_storage      := c1.umeas_storage;
      rInInvoicesSpecs.discount           := c1.discount;
      rInInvoicesSpecs.original_name      := c1.original_name;
      rInInvoicesSpecs.prod_date          := c1.prod_date;
      rInInvoicesSpecs.mdmnomen           := c1.mdmnomen;

      /* ƒобавление спецификации */
      usr_pkg_ininvoices.ininvoicesspecs_base_insert( rrow => rInInvoicesSpecs, nrn => rInInvoicesSpecs.rn, nsumm_ininvoices => nNumber, nsummtax_ininvoices => nNumber );

      /* создание св€зей */
      if ( pkg_inhier.check_proc( nident => nIDENT ) = 1 ) then
        pkg_inhier.get_in_doc( nident       => nIDENT
                              ,nbuff_level  => 1
                              ,nbuff_doc    => c1.rn
                              ,nin_level    => 1
                              ,sin_unit     => sINUNIT1
                              ,nin_doc      => nNumber );

        if ( sINUNIT1 = 'GoodsTransInvoicesToConsumersSpecs' ) then
          /* прив€зка буферного документа к выходному */
          pkg_inhier.link_buff( nident => nIDENT, nlevel => 1, nbuff_doc => c1.rn, nout_doc => rInInvoicesSpecs.rn );
          /* прив€зка входных документов и выходного документа 1 через документооборот */
          pkg_inhier.link_docs( nident => nIDENT, nlevel => 1, nout_doc => rInInvoicesSpecs.rn );
        end if;
      end if;

    end loop;
  end loop;

  /* окончание прив€зки документов */
  if ( pkg_inhier.check_proc( nident => nIDENT ) = 1) then
    if ( sINUNIT != 'FaceAccounts' ) then
      /* наследование свойств документов */
      pkg_inhier.inhr_props( nident => nIDENT );
    end if;
    /* фиксаци€ окончани€ прив€зки входного и выходного документов через документооборот */
    pkg_inhier.link_epilogue( nident => nIDENT );
    /* вызов деструктора */
    pkg_inhier.destructor( nident => nIDENT );
  end if;

  /* очистка буфера */
  p_ininvoicesbuff_clean( nident => nIDENT, ncompany => nCOMPANY );

end;
/
