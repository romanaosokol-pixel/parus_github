create or replace procedure usr_rep_storelabel
(
  sunitcode  in unitlist.unitcode%type
 ,nident     in number
 ,sstore     in varchar2
 ,sstellaj   in varchar2
 ,npagebreak in number
 ,njoint     in number
 ,gprn       in number -- RN товарного запаса, для выбора ячейки на форме
 ,ncell      in number -- Rn стеллажа
 ,ncelltype  in number /* Места хранения для списания тип резервирования (0 - приход, 1 - расход) */
 ,prn_direct in number -- Сразу печатать на принтер
) is
  --2025/П1685;2025/П1688
  ---grant execute on  usr_rep_storelabel to public;
  ch          constant pkg_std.tstring := 'X';
  line_l      constant pkg_std.tstring := 'LINE_L';
  l_barcode1  constant pkg_std.tstring := 's_BARCODE1';
  l_contr1    constant pkg_std.tstring := 'S_Contr1';
  l_contr2    constant pkg_std.tstring := 'S_Contr2';
  l_date1     constant pkg_std.tstring := 'S_Date1';
  l_dprov1    constant pkg_std.tstring := 'S_DProv1';
  l_gost      constant pkg_std.tstring := 's_GOST';
  l_kol       constant pkg_std.tstring := 'S_Kol';
  l_name1     constant pkg_std.tstring := 'S_Name1';
  l_name2     constant pkg_std.tstring := 'S_Name2';
  l_name3     constant pkg_std.tstring := 'S_Name3';
  l_nomcode   constant pkg_std.tstring := 'S_NomCode';
  l_seria1    constant pkg_std.tstring := 'S_Serial';
  l_storezone constant pkg_std.tstring := 'S_StoreZone';
  l_top       constant pkg_std.tstring := 'S_Top';
  l_name_ser  constant pkg_std.tstring := 'name_ser';
  
  CELL_PRINTER constant pkg_std.tstring := 'PRINTER_NAME';
  

  v_supplier varchar2(2000);

  idx integer;

  procedure goodsparties_label is
  
  begin
  
    insert into usr_tab_storelabel
      (
       
       select gp.company
              ,d.nomen_code
              ,d.nomen_name
              ,null prod_nmb
              ,nvl(mgy.quant, gy.restfact)
              ,ei.meas_mnemo
              ,gp.sernumb
               
              ,r.rn racks_rn
              ,r.pref
              ,r.numb
              ,cel.rn
              ,cel.pref
              ,cel.numb
              ,gp.rn goodsparties_rn
              ,trim(cel.pref) || '.' || trim(to_char(cel.tier, '00')) || '.' || trim(cel.numb) cell_addr
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 12114824) manufacture_date
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 134301298) verification_date
              ,
               
               case
                 when instr(nm.modif_name, 'ГОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ГОСТ'))
                 when instr(nm.modif_name, 'ОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ОСТ'))
                 when instr(nm.modif_name, 'ТУ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ТУ'))
                 else
                  null
               end gost
              ,(select ag.agnname
                  from inorders i
                  join agnlist ag
                    on ag.rn = i.contragent
                 where i.party = gp.indoc) supplier
         from selectlist sl
         join goodsparties gp
           on gp.rn = sl.document
         join nommodif nm
           on nm.rn = gp.nommodif
         join dicnomns d
           on d.rn = nm.prn
         join dicmunts ei
           on ei.rn = d.umeas_main
         join goodssupply gy
           on gy.prn = gp.rn
         join azsazslistmt skl
           on skl.rn = gy.store
         left join stplgoodssupply mgy
           on mgy.goodssupply = gy.rn
          and mgy.quant != 0
       
         left join stplcells cel
           on cel.rn = mgy.cell
         left join stplracks r
           on r.rn = cel.prn
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
             ---    and sl.company = ncompany
          and nvl(mgy.quant, gy.restfact) > 0
          and (sstore is null or skl.azs_number = sstore)
          and (ncell is null or cel.rn = ncell)
       
       );
  
  end;

  procedure goodssupply_label is
  
  begin
  
    insert into usr_tab_storelabel
      (
       
       select gp.company
              ,d.nomen_code
              ,d.nomen_name
              ,null prod_nmb
              ,nvl(mgy.quant, gy.restfact)
              ,ei.meas_mnemo
              ,gp.sernumb
              ,r.rn racks_rn
              ,r.pref
              ,r.numb
              ,cel.rn
              ,cel.pref
              ,cel.numb
              ,gp.rn goodsparties_rn
              ,trim(cel.pref) || '.' || trim(to_char(cel.tier, '00')) || '.' || trim(cel.numb) cell_addr
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 12114824) manufacture_date
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 134301298) verification_date
              ,
               
               case
                 when instr(nm.modif_name, 'ГОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ГОСТ'))
                 when instr(nm.modif_name, 'ОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ОСТ'))
                 when instr(nm.modif_name, 'ТУ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ТУ'))
                 else
                  null
               end gost
              ,(select ag.agnname
                  from inorders i
                  join agnlist ag
                    on ag.rn = i.contragent
                 where i.party = gp.indoc) supplier
         from selectlist sl
         join goodssupplyhist gyh
           on gyh.rn = sl.document
         join goodssupply gy
           on gy.rn = gyh.prn
         join goodsparties gp
           on gp.rn = gy.prn
         join nommodif nm
           on nm.rn = gp.nommodif
         join dicnomns d
           on d.rn = nm.prn
         join dicmunts ei
           on ei.rn = d.umeas_main
         join azsazslistmt skl
           on skl.rn = gy.store
         left join stplgoodssupply mgy
           on mgy.goodssupply = gy.rn
          and mgy.quant != 0
       
         left join stplcells cel
           on cel.rn = mgy.cell
         left join stplracks r
           on r.rn = cel.prn
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
             ---  and sl.company = ncompany
          and nvl(mgy.quant, gy.restfact) > 0
          and (ncell is null or cel.rn = ncell)
       
       );
  
  end;

  procedure storageplaces_label is
  begin
  
    insert into usr_tab_storelabel
      (select gp.company
             ,d.nomen_code
             ,d.nomen_name
             ,null prod_nmb
             ,nvl(mgy.quant, gy.restfact)
             ,ei.meas_mnemo
             ,gp.sernumb
              
             ,r.rn racks_rn
             ,r.pref
             ,r.numb
             ,cel.rn
             ,cel.pref
             ,cel.numb
             ,gp.rn goodsparties_rn
             ,trim(cel.pref) || '.' || trim(to_char(cel.tier, '00')) || '.' || trim(cel.numb) cell_addr
             ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                 ,nflagsmart  => 1
                                                                 ,ndocs_props => 12114824) manufacture_date
             ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                 ,nflagsmart  => 1
                                                                 ,ndocs_props => 134301298) verification_date
             ,case
                when instr(nm.modif_name, 'ГОСТ') > 0 then
                 substr(nm.modif_name, instr(nm.modif_name, 'ГОСТ'))
                when instr(nm.modif_name, 'ОСТ') > 0 then
                 substr(nm.modif_code, instr(nm.modif_name, 'ОСТ'))
                when instr(nm.modif_name, 'ТУ') > 0 then
                 substr(nm.modif_name, instr(nm.modif_name, 'ТУ'))
                else
                 null
              end gost
             ,(select ag.agnname
                 from inorders i
                 join agnlist ag
                   on ag.rn = i.contragent
                where i.party = gp.indoc) supplier
         from selectlist sl
         join stplgssupplyhist sgyh
           on sgyh.rn = sl.document
         join stplgoodssupply sgy
           on sgy.rn = sgyh.prn
         join goodssupply gy
           on gy.rn = sgy.goodssupply
         join goodsparties gp
           on gp.rn = gy.prn
         join nommodif nm
           on nm.rn = gp.nommodif
         join dicnomns d
           on d.rn = nm.prn
         join dicmunts ei
           on ei.rn = d.umeas_main
         join azsazslistmt skl
           on skl.rn = gy.store
         left join stplgoodssupply mgy
           on mgy.goodssupply = gy.rn
          and mgy.quant != 0
       
         left join stplcells cel
           on cel.rn = mgy.cell
         left join stplracks r
           on r.rn = cel.prn
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
             --- and sl.company = ncompany
          and nvl(mgy.quant, gy.restfact) > 0);
  
  end;

  procedure todepts_label is
  begin
  
    insert into usr_tab_storelabel
      (
       
       select nvl(gp.rn, gpa.rn) rn
              ,d.nomen_code
              ,d.nomen_name
              ,case njoint
                 when 1 then
                  null
                 else
                  udo_f_transinvdept_main_numb(sp.prn)
               end prod_nmb
              ,jrm.quant
              ,ei.meas_mnemo
              ,nvl(gp.sernumb, gpa.sernumb)
              ,r.rn racks_rn
              ,r.pref
              ,r.numb
              ,cel.rn
              ,cel.pref
              ,cel.numb
              ,nvl(gp.rn, gpa.rn) goodsparties_rn
              ,trim(cel.pref) || '.' || trim(to_char(cel.tier, '00')) || '.' || trim(cel.numb) cell_addr
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => nvl(gp.rn, gpa.rn)
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 12114824) as manufacture_date
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => nvl(gp.rn, gpa.rn)
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 134301298) as verification_date
              ,case
                 when instr(nm.modif_name, 'ГОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ГОСТ'))
                 when instr(nm.modif_name, 'ОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ОСТ'))
                 when instr(nm.modif_name, 'ТУ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ТУ'))
                 else
                  null
               end gost
              ,coalesce(udo_f_transinvdept_main_prod(sp.prn), da.nomen_name) supplier -- Вместо поставщика выводим наименование номенклатуры изделия*/
       
         from selectlist sl
         join transinvdeptspecs sp
           on sp.prn = sl.document
         left join doclinks dl
           on dl.in_document = sp.rn
          and dl.out_unitcode = 'StoragePlacesResJournal'
          and dl.in_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
         left join strplresjrnl jrm
           on jrm.rn = dl.out_document          
         left join stplcells cel
           on cel.rn = jrm.cell
         left join stplracks r
           on r.rn = cel.prn
          and r.rn = jrm.rack
         left join goodsparties gp
           on gp.rn = sp.goodsparty
         join nommodif nm
           on nm.rn = sp.nommodif
         join dicnomns d
           on d.rn = nm.prn
         join dicmunts ei
           on ei.rn = d.umeas_main
         left join articlessupply sa
           on sa.article = sp.article
          and sa.company = sp.company
         left join goodssupply gsa
           on gsa.rn = sa.prn
         left join goodsparties gpa
           on gpa.rn = gsa.prn
         left join nommodif nma
           on nma.rn = gpa.nommodif
         left join dicnomns da
           on da.rn = nma.prn
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
          and jrm.res_type = ncelltype
       
       );
  
  end;

  procedure todeptsspecs_label is
  begin
  
    insert into usr_tab_storelabel
      (
       
       select nvl(gp.rn, gpa.rn) rn
              ,d.nomen_code
              ,d.nomen_name
              ,case njoint
                 when 1 then
                  null
                 else
                  udo_f_transinvdept_main_numb(sp.prn)
               end prod_nmb
              ,jrm.quant
              ,ei.meas_mnemo
              ,nvl(gp.sernumb, gpa.sernumb)
              ,r.rn racks_rn
              ,r.pref
              ,r.numb
              ,cel.rn
              ,cel.pref
              ,cel.numb
              ,nvl(gp.rn, gpa.rn) goodsparties_rn
              ,trim(cel.pref) || '.' || trim(to_char(cel.tier, '00')) || '.' || trim(cel.numb) cell_addr
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => nvl(gp.rn, gpa.rn)
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 12114824) manufacture_date
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => nvl(gp.rn, gpa.rn)
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 134301298) verification_date
              ,
               
               case
                 when instr(nm.modif_name, 'ГОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ГОСТ'))
                 when instr(nm.modif_name, 'ОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ОСТ'))
                 when instr(nm.modif_name, 'ТУ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ТУ'))
                 else
                  null
               end gost
              ,coalesce(udo_f_transinvdept_main_prod(sp.prn), da.nomen_name) supplier -- Вместо поставщика выводим наименование номенклатуры изделия*/
       
         from selectlist sl
         join transinvdeptspecs sp
           on sp.rn = sl.document
         left join doclinks dl
           on dl.in_document = sp.rn
          and dl.out_unitcode = 'StoragePlacesResJournal'
          and dl.in_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
         left join strplresjrnl jrm
           on jrm.rn = dl.out_document
          
         left join stplcells cel
           on cel.rn = jrm.cell
         left join stplracks r
           on r.rn = cel.prn
          and r.rn = jrm.rack
         left join goodsparties gp
           on gp.rn = sp.goodsparty
         join nommodif nm
           on nm.rn = sp.nommodif
         join dicnomns d
           on d.rn = nm.prn
         join dicmunts ei
           on ei.rn = d.umeas_main
         left join articlessupply sa
           on sa.article = sp.article
          and sa.company = sp.company
         left join goodssupply gsa
           on gsa.rn = sa.prn
         left join goodsparties gpa
           on gpa.rn = gsa.prn
         left join nommodif nma
           on nma.rn = gpa.nommodif
         left join dicnomns da
           on da.rn = nma.prn
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
          and jrm.res_type = ncelltype
       
       );
  
  end;

  procedure inorders_label is
  
  begin
  
    insert into usr_tab_storelabel
      (
       
       select gp.rn
              ,d.nomen_code
              ,d.nomen_name
              ,null prod_nmb
              ,jrm.quant
              ,ei.meas_mnemo
              ,gp.sernumb
               
              ,r.rn racks_rn
              ,r.pref
              ,r.numb
              ,cel.rn
              ,cel.pref
              ,cel.numb
              ,gp.rn goodsparties_rn
              ,trim(cel.pref) || '.' || trim(to_char(cel.tier, '00')) || '.' || trim(cel.numb) cell_addr
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 12114824) as manufacture_date
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 134301298) verification_date
              ,case
                 when instr(nm.modif_name, 'ГОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ГОСТ'))
                 when instr(nm.modif_name, 'ОСТ') > 0 then
                  substr(nm.modif_code, instr(nm.modif_name, 'ОСТ'))
                 when instr(nm.modif_name, 'ТУ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ТУ'))
                 else
                  null
               end gost
              ,(select ag.agnname
                  from inorders i
                  join agnlist ag
                    on ag.rn = i.contragent
                 where i.party = gp.indoc
                   and rownum = 1) supplier
       
         from selectlist sl
         join inorderspecs sp
           on sp.prn = sl.document
         left join doclinks dl
           on dl.in_document = sp.rn
          and dl.out_unitcode = 'StoragePlacesResJournal'
          and dl.in_unitcode = 'IncomingOrdersSpecs'
         left join strplresjrnl jrm
           on jrm.rn = dl.out_document
          
         left join stplcells cel
           on cel.rn = jrm.cell
         left join stplracks r
           on r.rn = cel.prn
          and r.rn = jrm.rack
         join goodssupply gy
           on gy.rn = sp.goodssupply
         join goodsparties gp
           on gp.rn = gy.prn
         join nommodif nm
           on nm.rn = sp.nommodif
         join dicnomns d
           on d.rn = nm.prn
         join dicmunts ei
           on ei.rn = d.umeas_main
       
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
          and upper(trim(d.nomen_name)) not like '%ДОСТАВКА%'
          and upper(trim(d.nomen_name)) != 'ТАРА'
         --- and jrm.res_type = 0 -- приходное место хранения
       ----          
       
       );
  end;

  procedure inordersspecs_label is
  
  begin
    insert into usr_tab_storelabel
      (
       
       select gp.rn
              ,d.nomen_code
              ,d.nomen_name
              ,null prod_nmb
              ,jrm.quant
              ,ei.meas_mnemo
              ,gp.sernumb
              ,r.rn racks_rn
              ,r.pref
              ,r.numb
              ,cel.rn
              ,cel.pref
              ,cel.numb
              ,gp.rn goodsparties_rn
              ,trim(cel.pref) || '.' || trim(to_char(cel.tier, '00')) || '.' || trim(cel.numb) cell_addr
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 12114824) as manufacture_date
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 134301298) as verification_date
              ,
               
               case
                 when instr(nm.modif_name, 'ГОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ГОСТ'))
                 when instr(nm.modif_name, 'ОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ОСТ'))
                 when instr(nm.modif_name, 'ТУ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ТУ'))
                 else
                  null
               end gost
              ,(select ag.agnname
                  from inorders i
                  join agnlist ag
                    on ag.rn = i.contragent
                 where i.party = gp.indoc
                   and rownum = 1) supplier
       
         from selectlist sl
         join inorderspecs sp
           on sp.rn = sl.document
         left join doclinks dl
           on dl.in_document = sp.rn
          and dl.out_unitcode = 'StoragePlacesResJournal'
          and dl.in_unitcode = 'IncomingOrdersSpecs'
         left join strplresjrnl jrm
           on jrm.rn = dl.out_document
          
         left join stplcells cel
           on cel.rn = jrm.cell
         left join stplracks r
           on r.rn = cel.prn
          and r.rn = jrm.rack
         join goodssupply gy
           on gy.rn = sp.goodssupply
         join goodsparties gp
           on gp.rn = gy.prn
         join nommodif nm
           on nm.rn = sp.nommodif
         join dicnomns d
           on d.rn = nm.prn
         join dicmunts ei
           on ei.rn = d.umeas_main
       
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
          and upper(trim(d.nomen_name)) not like '%ДОСТАВКА%'
          and upper(trim(d.nomen_name)) != 'ТАРА'
        ---  and jrm.res_type = 0 -- приходное место хранения
       ----          
       
       );
  end;

  procedure invsheet_label is
  
  begin
    insert into usr_tab_storelabel
      (
       
       select gp.rn
              ,d.nomen_code
              ,d.nomen_name
              ,null prod_nmb
              ,sp.factquant
              ,ei.meas_mnemo
              ,gp.sernumb
               
              ,r.rn racks_rn
              ,r.pref
              ,r.numb
              ,cel.rn
              ,cel.pref
              ,cel.numb
              ,gp.rn goodsparties_rn
              ,trim(cel.pref) || '.' || trim(to_char(cel.tier, '00')) || '.' || trim(cel.numb) cell_addr
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 12114824)
               
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 134301298) verification_date
              ,
               
               case
                 when instr(nm.modif_name, 'ГОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ГОСТ'))
                 when instr(nm.modif_name, 'ОСТ') > 0 then
                  substr(nm.modif_code, instr(nm.modif_name, 'ОСТ'))
                 when instr(nm.modif_name, 'ТУ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ТУ'))
                 else
                  null
               end gost
              ,(select ag.agnname
                  from inorders i
                  join agnlist ag
                    on ag.rn = i.contragent
                 where i.party = gp.indoc
                   and rownum = 1) as supplier
         from selectlist sl
         join rlinvsheetspec sp
           on sp.prn = sl.document
         join goodssupply gy
           on gy.rn = sp.goodssupply
         join goodsparties gp
           on gp.rn = gy.prn
         join nommodif nm
           on nm.rn = gp.nommodif
         join dicnomns d
           on d.rn = nm.prn
         join dicmunts ei
           on ei.rn = d.umeas_main
         left join stplcells cel
           on cel.rn = sp.cell
         left join stplracks r
           on r.rn = cel.prn
       
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
       /*sp.prn = 165803538*/
       
       ----          
       
       );
  end;

  procedure invsheetspec_label is
  
  begin
    insert into usr_tab_storelabel
      (
       
       select gp.rn
              ,d.nomen_code
              ,d.nomen_name
              ,null prod_nmb
              ,sp.factquant
              ,ei.meas_mnemo
              ,gp.sernumb
               
              ,r.rn racks_rn
              ,r.pref
              ,r.numb
              ,cel.rn
              ,cel.pref
              ,cel.numb
              ,gp.rn goodsparties_rn
              ,trim(cel.pref) || '.' || trim(to_char(cel.tier, '00')) || '.' || trim(cel.numb) cell_addr
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 12114824) manufacture_date
              ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                  ,nflagsmart  => 1
                                                                  ,ndocs_props => 134301298) verification_date
              ,
               
               case
                 when instr(nm.modif_name, 'ГОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ГОСТ'))
                 when instr(nm.modif_name, 'ОСТ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ОСТ'))
                 when instr(nm.modif_name, 'ТУ') > 0 then
                  substr(nm.modif_name, instr(nm.modif_name, 'ТУ'))
                 else
                  null
               end gost
              ,(select ag.agnname
                  from inorders i
                  join agnlist ag
                    on ag.rn = i.contragent
                 where i.party = gp.indoc
                   and rownum = 1) supplier
         from selectlist sl
         join rlinvsheetspec sp
           on sp.rn = sl.document
         join goodssupply gy
           on gy.rn = sp.goodssupply
         join goodsparties gp
           on gp.rn = gy.prn
         join nommodif nm
           on nm.rn = gp.nommodif
         join dicnomns d
           on d.rn = nm.prn
         join dicmunts ei
           on ei.rn = d.umeas_main
         left join stplcells cel
           on cel.rn = sp.cell
         left join stplracks r
           on r.rn = cel.prn
       
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
       ---- 
       );
  end;

begin

  prsg_excel.prepare;
  prsg_excel.sheet_select(ch);
  prsg_excel.line_describe(line_l);
  prsg_excel.line_cell_describe(line_l, l_barcode1);
  prsg_excel.line_cell_describe(line_l, l_contr1);
  prsg_excel.line_cell_describe(line_l, l_contr2);
  prsg_excel.line_cell_describe(line_l, l_date1);
  prsg_excel.line_cell_describe(line_l, l_dprov1);
  prsg_excel.line_cell_describe(line_l, l_gost);
  prsg_excel.line_cell_describe(line_l, l_kol);
  prsg_excel.line_cell_describe(line_l, l_name1);
  prsg_excel.line_cell_describe(line_l, l_name2);
  prsg_excel.line_cell_describe(line_l, l_name3);
  prsg_excel.line_cell_describe(line_l, l_nomcode);
  prsg_excel.line_cell_describe(line_l, l_seria1);
  prsg_excel.line_cell_describe(line_l, l_storezone);
  prsg_excel.line_cell_describe(line_l, l_top);

  prsg_excel.cell_describe(scell_name => l_name_ser);
  prsg_excel.cell_describe(scell_name => CELL_PRINTER);
  
  prsg_excel.CELL_VALUE_WRITE(CELL_PRINTER, get_options_str(sCODE => 'DirectPrinterName'));

  case
    when sunitcode in ('GoodsTransInvoicesToDepts', 'GoodsTransInvoicesToDeptsSpecs') then
      case
        when ncelltype = 0 then
          prsg_excel.cell_value_write(scell_name  => l_name_ser
                                     ,scell_value => 'Место хранения для распределения');
        when ncelltype = 1 then
          prsg_excel.cell_value_write(scell_name  => l_name_ser
                                     ,scell_value => 'Место хранения для списания');
      end case;
    
    else
    
      if njoint = 1 then
      
        prsg_excel.cell_value_write(scell_name  => l_name_ser
                                   ,scell_value => 'Место хранения');
      end if;
  end case;

  --- Формируем данные  
  case sunitcode
    when 'GoodsParties' then
      goodsparties_label;
    
    when 'GoodsSupply' then
      goodssupply_label;
    
    when 'StoragePlacesGoodsSupply' then
      storageplaces_label;
    
    when 'GoodsTransInvoicesToDepts' then
      todepts_label;
    
    when 'GoodsTransInvoicesToDeptsSpecs' then
      todeptsspecs_label;
    
    when 'IncomingOrders' then
      inorders_label;
    
    when 'IncomingOrdersSpecs' then
      inordersspecs_label;
    
    when 'RealizationInventorySheet' then
      invsheet_label;
    
    when 'RealizationInventorySheetSpec' then
      invsheetspec_label;
    
    else
      p_exception(0
                 ,'Из раздела %s печать отчета еще не реализована'
                 ,sunitcode);
    
  end case;

  --- Выводим данные

  for cur in (select sum(t.nquant) quant                     
                    ,t.goodsparties_rn
                    ,t.supplier
                    ,t.nomen_name
                    ,t.nomen_code
                    ,t.gost
                    ,t.oei
                    ,t.sernumb
                    ,t.cell_addr
                    ,t.manufacture_date
                    ,t.verification_date
                    ,t.prod_nmb
                from usr_tab_storelabel t
               group by t.goodsparties_rn
                       ,t.supplier
                       ,t.nomen_name
                       ,t.nomen_code
                       ,t.gost
                       ,t.oei
                       ,t.sernumb
                       ,t.cell_addr
                       ,t.manufacture_date
                       ,t.verification_date
                       ,t.prod_nmb
              
              )
  loop
 --- if user = 'GOR' then P_exception(0, cur.gost); end if;
    case
      when cur.supplier is not null then
        case
          when cur.prod_nmb is not null then
            v_supplier := cur.supplier || ' (зав №' || cur.prod_nmb || ')';
          else
            v_supplier := cur.supplier;
        end case;
      else
        v_supplier := null;
    end case;
  
    idx := prsg_excel.line_continue(line_l);
    prsg_excel.cell_value_write(l_barcode1, 0, idx, cur.goodsparties_rn); -- Штрик код - RN goodsparty   
    if  v_supplier is not null then 
    prsg_excel.cell_value_write(l_contr1, 0, idx, ''''||substr(V_supplier, 1, 31));
    prsg_excel.cell_value_write(l_contr2, 0, idx, ''''||substr(V_supplier, 32, 31));
    end if;
    prsg_excel.cell_value_write(l_name1, 0, idx, ''''||substr(cur.nomen_name, 1, 30));
    prsg_excel.cell_value_write(l_name2, 0, idx, ''''||substr(cur.nomen_name, 31, 30));
    prsg_excel.cell_value_write(l_name3, 0, idx, ''''||substr(cur.nomen_name, 62, 30));
    prsg_excel.cell_value_write(l_nomcode, 0, idx, ''''||cur.nomen_code);
    prsg_excel.cell_value_write(l_gost, 0, idx, cur.gost);
    prsg_excel.cell_value_write(l_kol
                               ,0
                               ,idx
                               ,case when cur.quant < 1 then '0' || to_char(cur.quant) else
                                to_char(cur.quant) end || ' ' || cur.oei);
    prsg_excel.cell_value_write(l_seria1, 0, idx, cur.sernumb);
    prsg_excel.cell_value_write(l_storezone, 0, idx, cur.cell_addr);
    prsg_excel.cell_value_write(l_date1, 0, idx, cur.manufacture_date);
    prsg_excel.cell_value_write(l_dprov1, 0, idx, cur.verification_date);
  
    if sunitcode in ('GoodsTransInvoicesToDepts', 'GoodsTransInvoicesToDeptsSpecs') then
      prsg_excel.cell_value_write(l_top, 0, idx, 'Изделие');
    end if;
  
    if npagebreak = 1 then
      prsg_excel.line_page_break(line_l); --- После каждой карточки разрыв страницы
    end if;
  
  end loop;

  if idx is null then
    p_exception(0
               ,'Данных для формирования отчета не найдено!');
  end if;

  prsg_excel.line_delete(line_l);
  
  if prn_direct =1 then 
    PRSG_EXCEL.EXECUTE_MACROS('PRINT_DIRECT');
  end if;  
  
end;
/
