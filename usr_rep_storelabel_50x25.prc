create or replace procedure usr_rep_storelabel_50x25
(
  sunitcode  in unitlist.unitcode%type
 ,nident     in number
 ,npagebreak in number
) is
  --2025-05-27
  ---grant execute on  usr_rep_storelabel_50x25 to public;
  ch         constant pkg_std.tstring := 'X';
  line_l     constant pkg_std.tstring := 'LINE_1';
  cell_gp_rn constant pkg_std.tstring := 'GOODSPARTIES_RN';
  cell_s011  constant pkg_std.tstring := '_s011';
  idx integer;
  procedure goodsparties_label is
  begin
    insert into usr_tab_storelabel
      (select null
             ,null
             ,null
             ,null prod_nmb
             ,null
             ,null
             ,gp.sernumb
             ,null
             ,null
             ,null
             ,null
             ,null
             ,null
             ,gp.rn goodsparties_rn
             ,null
             ,null
             ,null
             ,null
             ,null
         from selectlist sl
         join goodsparties gp
           on gp.rn = sl.document
       /*join nommodif nm
         on nm.rn = gp.nommodif
       join dicnomns d
         on d.rn = nm.prn
       join dicmunts ei
         on ei.rn = d.umeas_main*/
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
       /*   and (sstore is null or skl.azs_number = sstore)
       and (ncell is null or cel.rn = ncell)*/
       );
  end;

  procedure goodssupply_label is
  begin
    insert into usr_tab_storelabel
      (select null
             ,null
             ,null
             ,null       prod_nmb
             ,null
             ,null
             ,gp.sernumb
             ,null
             ,null
             ,null
             ,null
             ,null
             ,null
             ,gp.rn      goodsparties_rn
             ,null
             ,null
             ,null
             ,null
             ,null
         from selectlist sl
         join goodssupplyhist gyh
           on gyh.rn = sl.document
         join goodssupply gy
           on gy.rn = gyh.prn
         join goodsparties gp
           on gp.rn = gy.prn
       /* join nommodif nm
         on nm.rn = gp.nommodif
       join dicnomns d
         on d.rn = nm.prn
       join dicmunts ei
         on ei.rn = d.umeas_main
       join azsazslistmt skl
         on skl.rn = gy.store*/
         left join stplgoodssupply mgy
           on mgy.goodssupply = gy.rn
          and mgy.quant != 0
       /*left join stplcells cel
         on cel.rn = mgy.cell
       left join stplracks r
         on r.rn = cel.prn*/
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
             ---  and sl.company = ncompany
          and nvl(mgy.quant, gy.restfact) > 0
       ---          and (ncell is null or cel.rn = ncell)
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
             ,null
             ,null
             ,null
             ,null
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
      (select null
             ,null
             ,null
             ,null
             ,null
             ,null
             ,gp.sernumb
             ,null
             ,null
             ,null
             ,null
             ,null
             ,null
             ,nvl(gp.rn, gpa.rn) goodsparties_rn
             ,null
             ,null
             ,null
             ,null
             ,null
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
         left join articlessupply sa
           on sa.article = sp.article
          and sa.company = sp.company
         left join goodssupply gsa
           on gsa.rn = sa.prn
         left join goodsparties gpa
           on gpa.rn = gsa.prn
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
       ---          and jrm.res_type = ncelltype
       );
  end;

  procedure todeptsspecs_label is
  begin
    insert into usr_tab_storelabel
      (select null
             ,null
             ,null
             ,null
             ,null
             ,null
             ,gp.sernumb
             ,null
             ,null
             ,null
             ,null
             ,null
             ,null
             ,nvl(gp.rn, gpa.rn) goodsparties_rn
             ,null
             ,null
             ,null
             ,null
             ,null
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
       /*join nommodif nm
         on nm.rn = sp.nommodif
       join dicnomns d
         on d.rn = nm.prn
       join dicmunts ei
         on ei.rn = d.umeas_main*/
         left join articlessupply sa
           on sa.article = sp.article
          and sa.company = sp.company
         left join goodssupply gsa
           on gsa.rn = sa.prn
         left join goodsparties gpa
           on gpa.rn = gsa.prn
       /*left join nommodif nma
         on nma.rn = gpa.nommodif
       left join dicnomns da
         on da.rn = nma.prn*/
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
       --          and jrm.res_type = ncelltype
       );
  end;

  procedure inorders_label is
  begin
    insert into usr_tab_storelabel
      (select null
             ,null
             ,null
             ,null       prod_nmb
             ,null
             ,null
             ,gp.sernumb
             ,null
             ,null
             ,null
             ,null
             ,null
             ,null
             ,gp.rn      goodsparties_rn
             ,null
             ,null
             ,null
             ,null
             ,null
         from selectlist sl
         join inorderspecs sp
           on sp.prn = sl.document
       /*left join doclinks dl
         on dl.in_document = sp.rn
        and dl.out_unitcode = 'StoragePlacesResJournal'
        and dl.in_unitcode = 'IncomingOrdersSpecs'
       left join strplresjrnl jrm
         on jrm.rn = dl.out_document
        
       left join stplcells cel
         on cel.rn = jrm.cell
       left join stplracks r
         on r.rn = cel.prn
        and r.rn = jrm.rack*/
         join goodssupply gy
           on gy.rn = sp.goodssupply
         join goodsparties gp
           on gp.rn = gy.prn
         join nommodif nm
           on nm.rn = sp.nommodif
         join dicnomns d
           on d.rn = nm.prn
       /*       join dicmunts ei
       on ei.rn = d.umeas_main*/
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
      (select null
             ,null
             ,null
             ,null       prod_nmb
             ,null
             ,null
             ,gp.sernumb
             ,null
             ,null
             ,null
             ,null
             ,null
             ,null
             ,gp.rn      goodsparties_rn
             ,null
             ,null
             ,null
             ,null
             ,null
         from selectlist sl
         join inorderspecs sp
           on sp.rn = sl.document
       /*left join doclinks dl
         on dl.in_document = sp.rn
        and dl.out_unitcode = 'StoragePlacesResJournal'
        and dl.in_unitcode = 'IncomingOrdersSpecs'
       left join strplresjrnl jrm
         on jrm.rn = dl.out_document
        
       left join stplcells cel
         on cel.rn = jrm.cell
       left join stplracks r
         on r.rn = cel.prn
        and r.rn = jrm.rack*/
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
      (select gp.rn
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
             ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn => gp.rn, nflagsmart => 1, ndocs_props => 12114824)
             ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn => gp.rn, nflagsmart => 1, ndocs_props => 134301298) verification_date
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
      (select gp.rn
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
             ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn => gp.rn, nflagsmart => 1, ndocs_props => 12114824) manufacture_date
             ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn => gp.rn, nflagsmart => 1, ndocs_props => 134301298) verification_date
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

  procedure ininvoicesspecs_label is
    /* При печати из накладной выводим тоько серию, т..к партии еще нет */
  begin
    insert into usr_tab_storelabel
      (select -1 --gp.rn
             ,null --d.nomen_code
             ,null ---d.nomen_name
             ,null       prod_nmb
             ,null ---sp.quant
             ,null ---ei.meas_mnemo
             ,sp.sernumb
             ,null -- racks_rn
             ,null -- r.pref
             ,null -- ,r.numb
             ,null -- ,cel.rn
             ,null -- ,cel.pref
             ,null -- ,cel.numb
             ,-1 ---gp.rn goodsparties_rn
             ,null -- ,trim(cel.pref) || '.' || trim(to_char(cel.tier, '00')) || '.' || trim(cel.numb) cell_addr
             ,null --- manufacture_date
             ,null       verification_date
             ,null ---gost
             ,null --sup.agnname supplier
         from selectlist sl
         join ininvoicesspecs sp
           on sp.rn = sl.document
        where sl.ident = nident
          and sl.authid = utilizer
          and sl.unitcode = sunitcode
       --sp.rn = 226215359
       );
  end;

begin
  prsg_excel.prepare;
  prsg_excel.sheet_select(ch);
  prsg_excel.line_describe(line_l);
  prsg_excel.line_cell_describe(line_l, cell_gp_rn);
  prsg_excel.line_cell_describe(line_l, cell_s011);
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
    when 'IncomingInvoicesSpecs' then
      ininvoicesspecs_label;
    else
      p_exception(0, 'Из раздела %s печать отчета еще не реализована', sunitcode);
  end case;
  --- Выводим данные
  for cur in (select t.goodsparties_rn
                    ,t.sernumb
                from usr_tab_storelabel t)
  loop
    idx := prsg_excel.line_continue(line_l);
    prsg_excel.cell_value_write(cell_gp_rn, 0, idx, case cur.goodsparties_rn when - 1 then cur.sernumb else cur.goodsparties_rn end); -- Штрик код - RN goodsparty   
    prsg_excel.cell_value_write(cell_s011, 0, idx,
                                case when cur.goodsparties_rn is not null then cur.sernumb else '__________Документ не отработан' end); -- Штрик код - RN goodsparty   
    if npagebreak = 1
    then
      prsg_excel.line_page_break(line_l); --- После каждой карточки разрыв страницы
    end if;
  end loop;
  if idx is null
  then
    p_exception(0, 'Данных для формирования отчета не найдено!');
  end if;
  prsg_excel.line_delete(line_l);
end;
/
