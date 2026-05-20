create or replace procedure udo_rep_ininvoices_sticker4
(
  ncompany  in number
 , -- Организация
  sunitcode in varchar2
 , -- Раздел из которого запускается отчет
  nident    in number
 , -- Отмеченные записи
  njoint    in number
 , -- Суммирование количества (Без учета заводских номеров)
  sstore    in varchar2 -- Для печати из приходных партий товаров 
 , nTypeCell in number -- 1  По распределению 
) is
  -- Печать этикеток для Приходной накладной
  ----Переменные отчета
  c_slist constant pkg_std.tstring := 'TDSheet'; -- Лист

  ll_contr     constant pkg_std.tstring := 'L_CONTR';
  с_stop1     constant pkg_std.tstring := 'S_Top1';
  с_stop2     constant pkg_std.tstring := 'S_Top2';
  c_scontr1    constant pkg_std.tstring := 'S_Contr1';
  c_scontr2    constant pkg_std.tstring := 'S_Contr2';
  ll_name      constant pkg_std.tstring := 'L_NAME';
  c_sname1     constant pkg_std.tstring := 'S_Name1';
  c_sname2     constant pkg_std.tstring := 'S_Name2';
  c_nomcode1   constant pkg_std.tstring := 'S_NomCode1';
  c_nomcode2   constant pkg_std.tstring := 'S_NomCode2';
  ll_gost      constant pkg_std.tstring := 'L_GOST';
  c_sgost1     constant pkg_std.tstring := 'S_Gost1';
  c_sgost2     constant pkg_std.tstring := 'S_Gost2';
  ll_kol       constant pkg_std.tstring := 'L_KOL';
  c_skol1      constant pkg_std.tstring := 'S_Kol1';
  c_skol2      constant pkg_std.tstring := 'S_Kol2';
  ll_shifr     constant pkg_std.tstring := 'L_SHIFR';
  с_snum1     constant pkg_std.tstring := 'S_Num1';
  с_snum2     constant pkg_std.tstring := 'S_Num2';
  c_sshifr1    constant pkg_std.tstring := 'S_Shifr1';
  c_sshifr2    constant pkg_std.tstring := 'S_Shifr2';
  c_barser1    constant pkg_std.tstring := 'BarSerNumb1';
  c_barser2    constant pkg_std.tstring := 'BarSerNumb2';
  c_barzone1   constant pkg_std.tstring := 'BarZone1';
  c_barzone2   constant pkg_std.tstring := 'BarZone2';
  ll_nomen     constant pkg_std.tstring := 'L_NOMEN';
  c_sseria1    constant pkg_std.tstring := 'S_Seria1';
  c_sseria2    constant pkg_std.tstring := 'S_Seria2';
  c_snomen1    constant pkg_std.tstring := 'S_Nomenkl1';
  c_snomen2    constant pkg_std.tstring := 'S_Nomenkl2';
  c_storezone1 constant pkg_std.tstring := 'S_StoreZone1';
  c_storezone2 constant pkg_std.tstring := 'S_StoreZone2';
  ll_date      constant pkg_std.tstring := 'L_DATE';
  c_sdate1     constant pkg_std.tstring := 'S_Date1';
  c_sdate2     constant pkg_std.tstring := 'S_Date2';
  ll_prov      constant pkg_std.tstring := 'L_PROV';
  c_sdprov1    constant pkg_std.tstring := 'S_DProv1';
  c_sdprov2    constant pkg_std.tstring := 'S_DProv2';
  c_barcode1   constant pkg_std.tstring := 'S_BARCODE1';
  c_barcode2   constant pkg_std.tstring := 'S_BARCODE2';

  c_buh_code1 constant pkg_std.tstring := 'BUH_CODE1';
  c_buh_code2 constant pkg_std.tstring := 'BUH_CODE2';
  c_prj_code1 constant pkg_std.tstring := 'PRJ_CODE1';
  c_prj_code2 constant pkg_std.tstring := 'PRJ_CODE2';

  ll_gap constant pkg_std.tstring := 'L_GAP';

  npp       number := 0;
  nstr      number;
  nstr1     number;
  nstr2     number;
  nstr12    number;
  nstr22    number;
  nstr3     number;
  nstr4     number;
  nstr5     number;
  nstr6     number;
  nstr7     number;
  nstr8     number;
  szakaz    varchar2(2048);
  sshifr    varchar2(256);
  szayav    varchar2(256);
  stmp      varchar2(1024);
  ndocument number := 0;

  nstore azsazslistmt.rn%type;

  function store_zones(ncel in number) return varchar as
    sres pkg_std.tstring;
  begin
    begin
      select trim(cel.pref) || '.' || trim(to_char(cel.tier, '00')) || '.' || trim(cel.numb)
        into sres
        from stplcells cel
       where cel.rn = ncel;
    exception
      when others then
        return null;
    end;
    return sres;
  end;

  function print_numb(nquant in number) return varchar as
    sres varchar(20);
  begin
    if nquant - trunc(nquant, 0) > 0 then
      sres := to_char(nquant, '999999990.999');
    else
      sres := to_char(nquant);
    end if;
    return sres;
  end;

  procedure print_stiker as
    stmp        pkg_std.tstring;
    sstore_zone pkg_std.tstring;
    npp         number;
  begin
    npp := 1;
    for prn in (select sum(st.quant) as quant
                      ,st.check_date as check_date
                      ,st.prod_date as prod_date
----                      ,st.prod_doc as   prod_doc
                      ,st.store_zone as nstore_zone
                      ,st.sernumb as sernumb
                      ,st.title as stitle
                      ,st.goodsparty as nparty
                      ,fc.numb as sfaceacc
                      ,dn.nomen_name as snomen_name
                      ,dn.nomen_code as snomen_code
                      ,nm.modif_name as smodif_code
                      ,ms.meas_mnemo as smeas_mnemo
                      ,case njoint
                         when 0 then
                          st.prod_numb
                         else
                          null
                       end as sprod_numb
                      ,udo_f_faceacc_get_shefr(fc.rn) as ssheefr
                  from udo_tmp_sticker st
                      ,faceacc         fc
                      ,nommodif        nm
                      ,dicnomns        dn
                      ,dicmunts        ms
                 where fc.rn(+) = st.faceacc
                   and nm.rn = st.nom_modif
                   and dn.rn = nm.prn
                   and ms.rn(+) = dn.umeas_main
                 group by st.check_date
                         ,st.prod_date
                        -- ,st.prod_doc
                         ,st.store_zone
                         ,st.sernumb
                         ,st.title
                         ,st.goodsparty
                         ,fc.numb
                         ,fc.rn
                         ,dn.nomen_name
                         ,dn.nomen_code
                         ,nm.modif_name
                         ,ms.meas_mnemo
                         ,case njoint
                            when 0 then
                             st.prod_numb
                            else
                             null
                          end
                 order by st.title
                         ,dn.nomen_name)
    loop
      ---if sunitcode in
        --- ('GoodsTransInvoicesToDepts', 'GoodsTransInvoicesToDeptsSpecs', 'StoragePlacesGoodsSupply') then
      
   
      
       if  prn.nstore_zone is not null then 
        sstore_zone := store_zones(prn.nstore_zone);
        --   prn.sFACEACC := null;
      end if;
    
   
      if njoint = 0 then
        if prn.sprod_numb is not null then
          prn.stitle := prn.stitle || ' (зав.№' || prn.sprod_numb || ')';
        end if;
      end if;
      prn.sfaceacc := nvl(prn.sfaceacc, '  ');
    
      if instr(prn.smodif_code, 'ГОСТ') > 0 then
        stmp := substr(prn.smodif_code, instr(prn.smodif_code, 'ГОСТ'));
      elsif instr(prn.smodif_code, 'ОСТ') > 0 then
        stmp := substr(prn.smodif_code, instr(prn.smodif_code, 'ОСТ'));
      elsif instr(prn.smodif_code, 'ТУ') > 0 then
        stmp := substr(prn.smodif_code, instr(prn.smodif_code, 'ТУ'));
      else
        stmp := null;
      end if;
    
      if 1 = mod(npp, 2) then
        nstr1 := prsg_excel.line_continue(ll_contr);
        nstr2 := prsg_excel.line_continue(ll_name);
        nstr3 := prsg_excel.line_continue(ll_gost);
        nstr4 := prsg_excel.line_continue(ll_kol);
        nstr5 := prsg_excel.line_continue(ll_shifr);
        nstr6 := prsg_excel.line_continue(ll_nomen);
        nstr7 := prsg_excel.line_continue(ll_date);
        nstr8 := prsg_excel.line_continue(ll_prov);
      
        prsg_excel.cell_value_write(с_snum1
                                   ,0
                                   ,nstr5
                                   , /*'Штрих код'*/'Номер заказа');
        prsg_excel.cell_value_write(с_snum2
                                   ,0
                                   ,nstr5
                                   , /*'Штрих код'*/'Номер заказа');
        if sunitcode in ('GoodsTransInvoicesToDepts', 'GoodsTransInvoicesToDeptsSpecs') then
          prsg_excel.cell_value_write(с_stop1, 0, nstr1, 'Изделие');
          prsg_excel.cell_value_write(с_stop2, 0, nstr1, 'Изделие');
          prsg_excel.cell_value_write(c_sseria1, 0, nstr6, 'Серия/Место хр.');
          prsg_excel.cell_value_write(c_sseria2, 0, nstr6, 'Серия/Место хр.');
        end if;
      
        prsg_excel.cell_value_write(c_scontr1, 0, nstr1, prn.stitle);
        prsg_excel.cell_value_write(c_nomcode1, 0, nstr2, prn.snomen_code);
        prsg_excel.cell_value_write(c_sname1, 0, nstr2, prn.snomen_name);
        prsg_excel.cell_value_write(c_sgost1, 0, nstr3, stmp);
        prsg_excel.cell_value_write(c_skol1
                                   ,0
                                   ,nstr4
                                   ,print_numb(prn.quant) || '   ' || prn.smeas_mnemo);
        prsg_excel.cell_value_write(c_barser1, 0, nstr5, prn.sernumb);
        prsg_excel.cell_value_write(c_barzone1, 0, nstr5, prn.nstore_zone /*sSTORE_ZONE*/);
        prsg_excel.cell_value_write(c_buh_code1, 0, nstr5, prn.sfaceacc);
        prsg_excel.cell_value_write(c_prj_code1, 0, nstr5, prn.ssheefr);
      
        prsg_excel.cell_value_write(c_snomen1, 0, nstr6, prn.sernumb);
        prsg_excel.cell_value_write(c_storezone1, 0, nstr6, sstore_zone);
        prsg_excel.cell_value_write(c_sdate1, 0, nstr7, prn.prod_date);
        prsg_excel.cell_value_write(c_sdprov1, 0, nstr8, prn.check_date);
        prsg_excel.cell_value_write(c_barcode1, 0, nstr8, prn.nparty);
      else
        prsg_excel.cell_value_write(c_scontr2, 0, nstr1, prn.stitle);
        prsg_excel.cell_value_write(c_nomcode2, 0, nstr2, prn.snomen_code);
        prsg_excel.cell_value_write(c_sname2, 0, nstr2, prn.snomen_name);
        prsg_excel.cell_value_write(c_sgost2, 0, nstr3, stmp);
        prsg_excel.cell_value_write(c_skol2
                                   ,0
                                   ,nstr4
                                   ,print_numb(prn.quant) || '   ' || prn.smeas_mnemo);
        prsg_excel.cell_value_write(c_barser2, 0, nstr5, prn.sernumb);
        prsg_excel.cell_value_write(c_barzone2, 0, nstr5, prn.nstore_zone /*sSTORE_ZONE*/);
        prsg_excel.cell_value_write(c_buh_code2, 0, nstr5, prn.sfaceacc);
        prsg_excel.cell_value_write(c_prj_code2, 0, nstr5, prn.ssheefr);
      
        prsg_excel.cell_value_write(c_storezone2, 0, nstr6, sstore_zone);
        prsg_excel.cell_value_write(c_snomen2, 0, nstr6, prn.sernumb);
        prsg_excel.cell_value_write(c_sdate2, 0, nstr7, prn.prod_date);
        prsg_excel.cell_value_write(c_sdprov2, 0, nstr8, prn.check_date);
        prsg_excel.cell_value_write(c_barcode2, 0, nstr8, prn.nparty);
      
        nstr := prsg_excel.line_continue(ll_gap);
        nstr := prsg_excel.line_continue(ll_gap);
        /* Подгоняем до целого листа */
        if 0 = mod(npp, 10) then
          nstr := prsg_excel.line_continue(ll_gap);
        end if;
      end if;
      npp := npp + 1;
    end loop;
  
  end print_stiker;

begin

  ---Инициализация
  -- Готовим шаблон
  prsg_excel.prepare;
  -- Установка текущего рабочего листа
  prsg_excel.sheet_select(c_slist);

  prsg_excel.line_describe(ll_contr);
  prsg_excel.line_cell_describe(ll_contr, c_scontr1);
  prsg_excel.line_cell_describe(ll_contr, c_scontr2);
  --PRSG_EXCEL.LINE_DESCRIBE(LL_CONTR2);
  prsg_excel.line_cell_describe(ll_contr, с_stop1);
  prsg_excel.line_cell_describe(ll_contr, с_stop2);

  prsg_excel.line_describe(ll_name);
  prsg_excel.line_cell_describe(ll_name, c_sname1);
  prsg_excel.line_cell_describe(ll_name, c_sname2);
  --PRSG_EXCEL.LINE_DESCRIBE(LL_NAME2);
  prsg_excel.line_cell_describe(ll_name, c_nomcode1);
  prsg_excel.line_cell_describe(ll_name, c_nomcode2);
  prsg_excel.line_describe(ll_gost);
  prsg_excel.line_cell_describe(ll_gost, c_sgost1);
  prsg_excel.line_cell_describe(ll_gost, c_sgost2);
  prsg_excel.line_describe(ll_kol);
  prsg_excel.line_cell_describe(ll_kol, c_skol1);
  prsg_excel.line_cell_describe(ll_kol, c_skol2);

  prsg_excel.line_describe(ll_shifr);
  prsg_excel.line_cell_describe(ll_shifr, с_snum1);
  prsg_excel.line_cell_describe(ll_shifr, с_snum2);

  prsg_excel.line_cell_describe(ll_shifr, c_barser1);
  prsg_excel.line_cell_describe(ll_shifr, c_barser2);
  prsg_excel.line_cell_describe(ll_shifr, c_barzone1);
  prsg_excel.line_cell_describe(ll_shifr, c_barzone2);
  prsg_excel.line_cell_describe(ll_shifr, c_buh_code1);
  prsg_excel.line_cell_describe(ll_shifr, c_buh_code2);
  prsg_excel.line_cell_describe(ll_shifr, c_prj_code1);
  prsg_excel.line_cell_describe(ll_shifr, c_prj_code2);

  prsg_excel.line_describe(ll_nomen);
  prsg_excel.line_cell_describe(ll_nomen, c_sseria1);
  prsg_excel.line_cell_describe(ll_nomen, c_sseria2);
  prsg_excel.line_cell_describe(ll_nomen, c_snomen1);
  prsg_excel.line_cell_describe(ll_nomen, c_snomen2);
  prsg_excel.line_cell_describe(ll_nomen, c_storezone1);
  prsg_excel.line_cell_describe(ll_nomen, c_storezone2);

  prsg_excel.line_describe(ll_date);
  prsg_excel.line_cell_describe(ll_date, c_sdate1);
  prsg_excel.line_cell_describe(ll_date, c_sdate2);
  prsg_excel.line_cell_describe(ll_date, c_sdprov1);
  prsg_excel.line_cell_describe(ll_date, c_sdprov2);
  prsg_excel.line_describe(ll_prov);
  prsg_excel.line_cell_describe(ll_prov, c_barcode1);
  prsg_excel.line_cell_describe(ll_prov, c_barcode2);

  prsg_excel.line_describe(ll_gap);

  npp := 1;

  if sstore is not null then
    begin
      select skl.rn
        into nstore
        from azsazslistmt skl
       where skl.azs_number = sstore
         and skl.company = ncompany;
    exception
      when no_data_found then
        p_exception(0
                   ,'Склад с кодом %s не найден. Выберте корректное значение через словарь'
                   ,sstore);
    end;
  end if;

  /* Подготовим данные */
  if sunitcode in ('IncomingOrders', 'IncomingOrdersSpecs') then
    for rec in (select spec.nommodif
                      ,spec.planquant
                      ,spec.factquant
                      ,(select max(clc.faceaccount) from inorderspecsclc clc where clc.prn = spec.rn) as faceacc
                      ,spec.sernumb
                      ,
                       --  spec.pricemeas,
                       ag.agnname
                      ,gs.prn as goodsparty
                      ,udo_f_inorders_depord_numb(inv.rn) as sprod_doc
                      ,to_number(null) as store_zone
                      ,udo_f_get_doc_prop_val(ndoc  => spec.rn
                                             ,sprop => 'Дата производства') as ddate
                      ,f_docs_props_get_str_value(nproperty => 134301298
                                                 ,sunitcode => 'IncomingOrdersSpecs'
                                                 ,ndocument => spec.rn) as sifds
                
                  from inorders     inv
                      ,inorderspecs spec
                      ,nommodif     md
                      ,dicnomns     dn
                      ,agnlist      ag
                      ,goodssupply  gs
                 where (inv.rn in (select sl.document
                                     from selectlist sl
                                    where sunitcode = 'IncomingOrders'
                                      and sl.ident = nident) or
                       spec.rn in (select sl.document
                                      from selectlist sl
                                     where sunitcode = 'IncomingOrdersSpecs'
                                       and sl.ident = nident))
                   and inv.company = ncompany
                   and inv.rn = spec.prn
                   and upper(trim(dn.nomen_name)) not like '%ДОСТАВКА%'
                   and upper(trim(dn.nomen_name)) not like 'ТАРА'
                   and spec.nommodif = md.rn
                   and dn.rn = md.prn
                   and ag.rn = inv.contragent
                   and gs.rn = spec.goodssupply
                   and gs.store = inv.store
                
                )
    loop
    
      insert into udo_tmp_sticker
        (rn
        ,nom_modif
        ,quant
        ,faceacc
        ,sernumb
        ,store_zone
        ,title
        ,prod_doc
        ,prod_numb
        ,prod_date
        ,check_date
        ,goodsparty)
      values
        (npp
        ,rec.nommodif
        ,rec.factquant
        ,rec.faceacc
        ,rec.sernumb
        ,rec.store_zone
        ,rec.agnname
        ,rec.sprod_doc
        ,null
        ,rec.ddate
        ,rec.sifds
        ,rec.goodsparty);
    
      npp := npp + 1;
    end loop;
  
    print_stiker;
  
  elsif sunitcode in ('GoodsTransInvoicesToDepts', 'GoodsTransInvoicesToDeptsSpecs') then
  
    for rec in (
      
      with vp as (select dlin.in_document
                              ,vpl.cell
                              ,vpl.quant
                              ,vpl.res_type
                          from STRPLRESJRNL vpl
                              ,doclinks     dlin
                         where ---vpl.res_type = 1 and 
                           dlin.in_unitcode = 'GoodsTransInvoicesToDeptsSpecs'
                           and dlin.out_unitcode = 'StoragePlacesResJournal'
                           and dlin.out_document = vpl.rn)
      
      select nvl(vp.quant, ivs.quant) as nquant
                      ,ivs.nommodif as nommodif
                      ,gp.sernumb as sernumb
                      ,ivs.faceacc as faceacc
                      ,vp.cell as store_zone 
                      ,gp.rn as goodsparty
                      ,udo_f_trindeptspecs_provdate(ivs.rn) as sdate
                      ,udo_f_transinvdept_main_prod(ivs.prn) as smain_prod
                      ,udo_f_transinvdept_main_numb(ivs.prn) as sprod_numb
                      ,udo_f_invdept_depord(ivs.prn) as sprod_doc
                      ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                          ,nflagsmart  => 1
                                                                          ,ndocs_props => 134301298) as sifds -- План.поверка. Дата         
                  from nommodif md
                      ,dicnomns dn
                      ,goodsparties gp
                      ,(select spec.rn
                              ,spec.nommodif
                              ,spec.goodsparty
                              ,inv.rn as prn
                              ,inv.faceacc
                              ,spec.pricemeas
                              ,spec.quant
                              ,inv.IN_STATUS
                          from transinvdept      inv
                              ,transinvdeptspecs spec
                         where inv.rn = spec.prn
                           and inv.company = ncompany
                           and inv.rn in (select sl.document
                                            from selectlist sl
                                           where sl.ident = nident
                                             and sunitcode = 'GoodsTransInvoicesToDepts')
                        --  or  spec.RN in (select SL.DOCUMENT from SELECTLIST SL where SL.IDENT = nIdent and sUNITCODE = 'GoodsTransInvoicesToDeptsSpecs'))
                        union all
                        select spec.rn
                              ,spec.nommodif
                              ,spec.goodsparty
                              ,inv.rn as prn
                              ,inv.faceacc
                              ,spec.pricemeas
                              ,spec.quant
                              ,inv.IN_STATUS
                          from transinvdept      inv
                              ,transinvdeptspecs spec
                         where inv.rn = spec.prn
                           and inv.company = ncompany
                           and spec.rn in
                               (select sl.document
                                  from selectlist sl
                                 where sl.ident = nident
                                   and sunitcode = 'GoodsTransInvoicesToDeptsSpecs')
                        
                        ) ivs
                      left join vp on vp.in_document = ivs.rn and ((vp.res_type = 1 and nTypeCell = 0) or ( nTypeCell = 1 and vp.res_type = 0))
                 where ivs.nommodif = md.rn
                   and dn.rn = md.prn
                   and gp.rn = ivs.goodsparty
                   
                
                )
    loop
      --  p_exception(0,'err= 0');
      insert into udo_tmp_sticker
        (rn
        ,nom_modif
        ,quant
        ,faceacc
        ,sernumb
        ,store_zone
        ,title
        ,prod_doc
        ,prod_numb
        ,prod_date
        ,check_date
        ,goodsparty)
      values
        (npp
        ,rec.nommodif
        ,rec.nquant
        ,rec.faceacc
        ,rec.sernumb
        ,rec.store_zone
        ,rec.smain_prod
        ,rec.sprod_doc
        ,rec.sprod_numb
        ,rec.sdate
        ,rec.sifds
        ,rec.goodsparty);
    
      npp := npp + 1;
    end loop;
  
    print_stiker;
  
  elsif sunitcode in ('GoodsParties') then
  
    for rec in (
      /*select null as nquant
                      ,gp.nommodif as nommodif
                      ,gp.rn gprn
                      ,gp.sernumb as sernumb
                      ,null as faceacc
                      ,null as store_zone
                      ,gp.rn as goodsparty
                      ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                          ,nflagsmart  => 1
                                                                          ,ndocs_props => 12114824) as sdate
                      ,null as smain_prod
                      ,null as sprod_numb
                      ,null as sprod_doc
                      ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                          ,nflagsmart  => 1
                                                                          ,ndocs_props => 134301298) as sifds
                  from nommodif     md
                      ,dicnomns     dn
                      ,goodsparties gp
                 where gp.rn in (select document
                                   from selectlist
                                  where ident = nident
                                    and sunitcode = sunitcode)
                   and md.rn = gp.nommodif
                   and dn.rn = md.prn*/
                   select mgy.quant nquant,
       nm.rn nommodif,
       GP.rn gprn,
       gp.sernumb as sernumb
                      ,null as faceacc
                      ,mgy.cell as store_zone
                      ,gp.rn as goodsparty
                      ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                          ,nflagsmart  => 1
                                                                          ,ndocs_props => 12114824) as sdate
                      ,null as smain_prod
                      ,null as sprod_numb
                      ,null as sprod_doc
                      ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                          ,nflagsmart  => 1
                                                                          ,ndocs_props => 134301298) as sifds
  from selectlist SL
  join goodsparties GP  on gp.rn = sl.document
  join nommodif NM on nm.rn = gp.nommodif
  join goodssupply gy on gy.prn = gp.rn 
  left join STPLGOODSSUPPLY mgy on mgy.goodssupply = gy.rn and mgy.quant !=0
 where sl.ident = nident and sl.unitcode = sunitcode and sl.authid = utilizer
and (nstore is null or GY.store = nstore)
)
                   
                   
                   
                   
    loop
      --- Найдем место хранения, если указан склад (пока найдем то место хранения, на котором максимальное количество на остатке)
    
 /*     if nstore is not null then
      
        select mgy.cell
          into rec.store_zone
          from goodssupply gy
          join stplgoodssupply mgy
            on mgy.goodssupply = gy.rn
         where gy.prn = rec.gprn
           and gy.store = nstore
           and mgy.quant =
               (select max(tt.quant) from stplgoodssupply tt where tt.goodssupply = gy.rn)
           and rownum = 1;
      
      end if;*/
    
      insert into udo_tmp_sticker
        (rn
        ,nom_modif
        ,quant
        ,faceacc
        ,sernumb
        ,store_zone
        ,title
        ,prod_doc
        ,prod_numb
        ,prod_date
        ,check_date
        ,goodsparty)
      values
        (npp
        ,rec.nommodif
        ,rec.nquant
        ,rec.faceacc
        ,rec.sernumb
        ,rec.store_zone
        ,rec.smain_prod
        ,rec.sprod_doc
        ,rec.sprod_numb
        ,rec.sdate
        ,rec.sifds
        ,rec.goodsparty);
    
      npp := npp + 1;
    end loop;
  
    print_stiker;
  
    /* Товарные запасы по местам хранения (товарные запасы) */
  elsif sunitcode in ('StoragePlacesGoodsSupply') then
    for rec in (select t.nquant as nquant
                      ,t.nnommodif as nommodif
                      ,t.ssernumb as sernumb
                      ,null as faceacc
                      ,t.ncell as store_zone
                      ,t.ngoodsparty as goodsparty
                      ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => t.ngoodsparty
                                                                          ,nflagsmart  => 1
                                                                          ,ndocs_props => 12114824) as sdate
                      ,null as smain_prod
                      ,null as sprod_numb
                      ,null as sprod_doc
                      ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => t.ngoodsparty
                                                                          ,nflagsmart  => 1
                                                                          ,ndocs_props => 134301298) as sifds
                  from v_stplgoodssupply_rackcells t
                      ,selectlist                  sl
                 where t.nhs = sl.document
                   and sl.unitcode = sunitcode)
    loop
      insert into udo_tmp_sticker
        (rn
        ,nom_modif
        ,quant
        ,faceacc
        ,sernumb
        ,store_zone
        ,title
        ,prod_doc
        ,prod_numb
        ,prod_date
        ,check_date
        ,goodsparty)
      values
        (npp
        ,rec.nommodif
        ,rec.nquant
        ,rec.faceacc
        ,rec.sernumb
        ,rec.store_zone
        ,rec.smain_prod
        ,rec.sprod_doc
        ,rec.sprod_numb
        ,rec.sdate
        ,rec.sifds
        ,rec.goodsparty);
    
      npp := npp + 1;
    end loop;
  
    print_stiker;
  
  elsif sunitcode in ('RealizationInventorySheet', 'RealizationInventorySheetSpec') then
  
    for rec in (select nvl(vp.quant, ivs.quant) as nquant
                      ,ivs.nommodif as nommodif
                      ,gp.sernumb as sernumb
                      ,ivs.faceacc as faceacc
                      ,vp.cell as store_zone
                      ,gp.rn as goodsparty
                      ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                          ,nflagsmart  => 1
                                                                          ,ndocs_props => 12114824) as sdate
                      , /*udo_f_transinvdept_main_prod(ivs.prn)*/null as smain_prod
                      , /*udo_f_transinvdept_main_numb(ivs.prn)*/null as sprod_numb
                      , /*udo_f_invdept_depord(ivs.prn)*/null as sprod_doc
                      ,usr_pkg_goodsparties.goodsparties_get_iivs_ifds_prp(nrn         => gp.rn
                                                                          ,nflagsmart  => 1
                                                                          ,ndocs_props => 134301298) as sifds -- План.поверка. Дата
                  from nommodif md
                      ,dicnomns dn
                      ,goodsparties gp
                      ,(select spec.rn
                              ,spec.nommodif
                              ,gs.prn         as goodsparty
                              ,inv.rn         as prn
                              ,null           as faceacc
                              ,spec.pricemeas
                              ,spec.factquant as quant
                          from rlinvsheet     inv
                              ,rlinvsheetspec spec
                              ,goodssupply    gs
                         where inv.rn = spec.prn
                           and inv.rn in (select document
                                            from selectlist
                                           where ident = nident
                                             and sunitcode = 'RealizationInventorySheet')
                           and spec.goodssupply = gs.rn
                        union
                        select spec.rn
                              ,spec.nommodif
                              ,gs.prn         as goodsparty
                              ,inv.rn         as prn
                              ,null           as faceacc
                              ,spec.pricemeas
                              ,spec.factquant as quant
                          from rlinvsheet     inv
                              ,rlinvsheetspec spec
                              ,goodssupply    gs
                         where inv.rn = spec.prn
                           and spec.rn in
                               (select document
                                  from selectlist
                                 where ident = nident
                                   and sunitcode = 'RealizationInventorySheetSpec')
                           and spec.goodssupply = gs.rn) ivs
                      ,(select dlin.in_document
                              ,vpl.cell
                              ,vpl.quant
                          from strplresjrnl vpl
                              ,doclinks     dlin
                         where vpl.res_type = 1
                           and dlin.in_unitcode = 'RealizationInventorySheetSpec'
                           and dlin.out_unitcode = 'StoragePlacesResJournal'
                           and dlin.out_document = vpl.rn) vp
                 where ivs.nommodif = md.rn
                   and dn.rn = md.prn
                   and gp.rn = ivs.goodsparty
                   and vp.in_document(+) = ivs.rn)
    loop
      --  p_exception(0,'err= 0');
      insert into udo_tmp_sticker
        (rn
        ,nom_modif
        ,quant
        ,faceacc
        ,sernumb
        ,store_zone
        ,title
        ,prod_doc
        ,prod_numb
        ,prod_date
        ,check_date
        ,goodsparty)
      values
        (npp
        ,rec.nommodif
        ,rec.nquant
        ,rec.faceacc
        ,rec.sernumb
        ,rec.store_zone
        ,rec.smain_prod
        ,rec.sprod_doc
        ,rec.sprod_numb
        ,rec.sdate
        ,rec.sifds
        ,rec.goodsparty);
    
      npp := npp + 1;
    end loop;
  
    print_stiker;
  
  else
    p_exception(0
               ,'Печать отчёта из раздела <%s> не предусмотрена.'
               ,sunitcode);
  end if;

  --удаляем технические строки
  prsg_excel.line_delete(ll_contr);
  -- PRSG_EXCEL.LINE_DELETE(LL_CONTR2);
  prsg_excel.line_delete(ll_name);
  -- PRSG_EXCEL.LINE_DELETE(LL_NAME2);
  prsg_excel.line_delete(ll_gost);
  prsg_excel.line_delete(ll_kol);
  prsg_excel.line_delete(ll_shifr);
  prsg_excel.line_delete(ll_nomen);
  prsg_excel.line_delete(ll_date);
  prsg_excel.line_delete(ll_prov);

  prsg_excel.line_delete(ll_gap);

end udo_rep_ininvoices_sticker4;
/
