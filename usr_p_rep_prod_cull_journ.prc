create or replace procedure usr_p_rep_prod_cull_journ
/*
17/09/2025 Ñòåïàíîâ Ì.
Ïğîöåäóğà äëÿ îò÷¸òà "Æóğíàë âõîäíîãî êîíòğîëÿ"
create public synonym usr_p_rep_prod_cull_journ for usr_p_rep_prod_cull_journ;
grant execute on usr_p_rep_prod_cull_journ to public;
*/
(
 nCOMPANY         in number
,dDATE            in date       /* Äàòà */
,sAGENT           in varchar2   /* Êîíòğàãåíò ïîëüçîâàòåëÿ */
)
as
  sline01     constant varchar2(40) := '_sline01';
  scell       constant varchar2(40) := '_s';

  nAgent                  pkg_std.tref; 
  sUser                   pkg_std.tstring; 
  nInOrders               pkg_std.tref;
  rInOrders               inorders%rowtype;
  nPayAccInSpec           pkg_std.tref; 
  sProjectName_Usl_List   pkg_std.tstring;     

  n           pkg_std.tnumber;
begin
  prsg_excel.prepare;
  prsg_excel.sheet_select( 'Ëèñò1' );
  prsg_excel.line_describe( sline01 );

  /* Ïğîâåğêà ïàğàìåòğîâ */
  if dDATE is null then
    p_exception(0, 'Íå çàäàíà äàòà îò÷¸òà.');
  end if;
  
  find_agnlist_code(nflag_smart  => 0
                   ,nflag_option => 0
                   ,ncompany     => nCOMPANY
                   ,scode        => sAGENT
                   ,nrn          => nAgent);
  sUser := f_agnlist_get_authid( nflag_smart => 0
                                ,ncompany    => nCOMPANY
                                ,nrn         => nAgent
                                ,ddate       => dDATE );

  /* Îïèñàíèå ÿ÷ååê çàãîëîâêà */
  for Idx in 1 .. 16 loop
    prsg_excel.line_cell_describe(sline01, scell||lpad(to_char(Idx), 3, '0'));
  end loop;

  /* Çàïîëíåíèå ÿ÷ååê  */
  /* 0=Ñåğòèôèöèğîâàííûå / ïğîâåğåííûå ÒÌÖ;1=Íåãîäíûå (áğàê) ÒÌÖ;2=Ñåğòèôèêàöèÿ ğàñïğîñòğàíÿåòñÿ íà ïàğòèş;3=Ïğîøëè ñïåöïğîâåğêó;
     4=Âîçâğàò áåç ñåğòèôèêàöèè;5=Ïîòåíöèàëüíî íåíàäåæíûå;6=Ñåğòèôèöèğîâàííûå íåãîäíûå ÒÌÖ;7=ĞÔÀ íåãîäíûå ÒÌÖ */
  for c in ( select t.*
                   ,decode( t.nsign_out, 1, t.nquant ) as nquant_deffect
                   ,s.nrn             as s_nrn
                   ,s.nprn            as s_nprn
                   ,s.nquant          as s_nquan
                   ,s.ssupplier_party as s_ssupplier_party
                   ,s.sprod_date_s    as s_sprod_date_s
                   ,udo_pkg_prod_cull.cull_out_get_result( nsign_out => t.nsign_out, nshort => 1 ) as s_result
                   ,decode( t.saccept_type, 'ÂÏ', 'V' ) as swar_accept_symb
               from udo_v_prod_cull_out t
               join udo_v_prod_cull_sp  s on t.nprn = s.nrn
               join doclinks            dl  on dl.in_document = t.nrn
                                           and trunc( dl.in_date )  = dDATE 
                                           and dl.out_unitcode      = 'GoodsTransInvoicesToDeptsSpecs'
                                           and usr_pkg_updatelist.updatelist_get_last_authid(nflagsmart => 1, nrn => dl.out_document, soperation => 'I' ) = sUser
              /*where trunc( udo_pkg_prod_cull.cull_out_get_block_date( nrn => t.nrn, ddate => dDATE ) ) = dDATE 
                and udo_pkg_prod_cull.cull_out_get_block_user ( nrn => t.nrn, ddate => dDATE ) = sUser
                and udo_pkg_prod_cull.cull_out_get_block_state( nrn => t.nrn, ddate => dDATE + 1 ) = 1*/ 
                )
  loop
    n := prsg_excel.line_append( sline_name => sline01 );

    /* Ïîèñê ïğèõîäíîãî îğäåğà ïî ñåğèè */
    nInOrders :=   usr_pkg_goodsparties.goodsparties_get_indocs_data( ssernumb       => c.ssernumb
                                                                    , nflagsmart     => 1
                                                                    , ntoo_many_rows => 1
                                                                    , sparam         => 'nIO' );
    if nInOrders is not null then
      rInOrders := usr_pkg_inorders.inorders_get( nrn => nInOrders );
    end if;
    /* Ïîèñê ñïåöèôèêàöèè âõîäÿùåãî ñ÷¸òà ïî ñåğèè */
    nPayAccInSpec := usr_pkg_goodsparties.goodsparties_get_indocs_data( ssernumb       => c.ssernumb
                                                                      , nflagsmart     => 1
                                                                      , ntoo_many_rows => 1
                                                                      , sparam         => 'nPAIS' );
    /* Ïîèñê ñïèñêà òåì íà çàêóïêó â ñïåöèôèêàöèè âõîäÿùåãî ñ÷¸òà */
    begin
      select listagg( pj.name_usl, ';' ) within group( order by pj.rn )
        into sProjectName_Usl_List
        from payaccinspclc t 
            ,projectstage  pjs
            ,project       pj
       where t.prn         = nPayAccInSpec
         and t.faceaccount = pjs.faceacc
         and pjs.prn       = pj.rn ;
    exception
      when no_data_found then                  
        null;
      when others then                  
        p_exception(0, 'Íåîïğåäåë¸ííàÿ ñèòóàöèÿ ïğè ïîèñêå íàèìåíîâàíèé ïğîåêòîâ äëÿ ñïåöèôèêàöèè âõîäÿùåãî ñ÷¸òà %s. %s%s'
                   ,f_docdescrs_get_description( sunitcode => 'PaymentAccountsInSpecs', ndocument => nPayAccInSpec )
                   ,cr||cr||f_docdescrs_get_description( sunitcode => 'UdoProdCullSp', ndocument => c.s_nrn )
                   ,cr||cr||f_docdescrs_get_description( sunitcode => 'UdoProdCull'  , ndocument => c.s_nprn ) ); 
    end;

    /* Íàèìåíîâàíèå èçäåëèÿ,  çàâîäñêîé íîìåğ  */
    prsg_excel.cell_value_write( scell_name => scell||'001'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value => c.snomen_name ||', '|| c.ssernumb || cr || usr_pkg_common.get_list_distinct( sProjectName_Usl_List, cr )
                               ); 
    /* Äîêóìåíò íà ïîñòàâêó, ïîñòàâùèê */
    prsg_excel.cell_value_write( scell_name    => scell||'002'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   => pkg_document.make_number( ndoc_type => rInOrders.indoctype
                                                                          , sdoc_pref => rInOrders.indocpref
                                                                          , sdoc_numb => rInOrders.indocnumb
                                                                          , ddoc_date => rInOrders.indocdate )
                                                  ||cr|| get_agnlist_agnname_id( nflag_smart => 1, nrn => rInOrders.contragent ) ); 
    /* Íîìåğ ïàğòèè / êîëè÷åñòâî èçäåëèé */
    prsg_excel.cell_value_write( scell_name => scell||'003'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value => nvl( c.s_ssupplier_party, '-' ) ||' / '|| c.s_nquan ); 
    /* Äàòà èçãîòîâëåíèÿ */                               
    prsg_excel.cell_value_write( scell_name    => scell||'004'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   =>  c.s_sprod_date_s ); 
    /* Âèäû èñïûòàíèé, äàòà ïğîâåäåíèÿ èñïûòàíèé è ğàñõîä ğåñóğñà  */                               
    prsg_excel.cell_value_write( scell_name => scell||'005'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   => c.scheck_types ); 
    /* Íîìåğ è äàòà ïğîòîêîëà èñïûòàíèé  */                               
    prsg_excel.cell_value_write( scell_name    => scell||'006'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   => '-' ); 
    /* Êîëè÷åñòâî ïğîâåğåííûõ  îáğàçöîâ  */                               
    prsg_excel.cell_value_write( scell_name    => scell||'007'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   => c.nquant ); 
    /* Êîëè÷åñòâî çàáğàêîâàííûõ  îáğàçöîâ  */                               
    prsg_excel.cell_value_write( scell_name    => scell||'008'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   => c.nquant_deffect ); 
    /* Èñïûòàíèÿ, ïğè êîòîğûõ âûÿâëåí áğàê  */                               
    prsg_excel.cell_value_write( scell_name    => scell||'009'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   => c.scheck_defective ); 
    /* Íîìåğ è äàòà ñîñòàâëåíèÿ ğåêëàìàöèé */                               
    prsg_excel.cell_value_write( scell_name    => scell||'010'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   => null ); 
    /* Ïğè÷èíà ğåêëàìàöèè, ïóíêò ñòàíäàğòà, ÒÓ è ìåğû ïî óäîâëåòâîğåíèş ğåêëàìàöèé */                               
    prsg_excel.cell_value_write( scell_name    => scell||'011'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   => null ); 
    /* Ìåğîïğèÿòèÿ ïîñòàâùèêà ïî çàêğûòèş ğåêëàìàöèé */                               
    prsg_excel.cell_value_write( scell_name    => scell||'012'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   => null ); 
    /* Èçìåğåííûå ïàğàìåòğû ÏÊÈ (İÊÁ) â ñîîòâåòñòâèè ñ Ïåğå÷íåì  */                               
    prsg_excel.cell_value_write( scell_name    => scell||'013'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   => c.smeas_params ); 
    /* Ğåçóëüòàòû âõîäíîãî êîíòğîëÿ (ñîîòâåòñòâóåò / íå ñîîòâåòñòâóåò) */                               
    prsg_excel.cell_value_write( scell_name    => scell||'014'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   => c.s_result ); 
    /* Ğîñïèñü ïğîâîäèâøåãî ïğîâåğêó. Ïğåäñòàâèòåëÿ ÂÏ */                               
    prsg_excel.cell_value_write( scell_name    => scell||'016'
                               , icell_index_x => 0
                               , icell_index_y => n
                               , scell_value   => c.swar_accept_symb ); 
  end loop;

  /* Î÷èñòêà */
  prsg_excel.line_delete( sline_name => sline01 );

end;
/
