create or replace procedure usr_p_rep_m4
(
  pin_idn in number
 ,pin_com in number
 ,pin_uni in varchar2
) is

  ch constant pkg_std.tstring := 'X';

  line_1 constant pkg_std.tstring := 'LINE';

  idx integer;

  cell_1  constant pkg_std.tstring := 'CELL_1';
  cell_2  constant pkg_std.tstring := 'CELL_2';
  cell_3  constant pkg_std.tstring := 'CELL_3';
  cell_4  constant pkg_std.tstring := 'CELL_4';
  cell_5  constant pkg_std.tstring := 'CELL_5';
  cell_6  constant pkg_std.tstring := 'CELL_6';
  cell_7  constant pkg_std.tstring := 'CELL_7';
  cell_8  constant pkg_std.tstring := 'CELL_8';
  cell_9  constant pkg_std.tstring := 'CELL_9';
  cell_10 constant pkg_std.tstring := 'CELL_10';
  cell_11 constant pkg_std.tstring := 'CELL_11';
  cell_12 constant pkg_std.tstring := 'CELL_12';

  cell_date_sost   constant pkg_std.tstring := 'DATE_SOST';
  cell_doc_nmb     constant pkg_std.tstring := 'DOC_NMB';
  cell_doc_rn      constant pkg_std.tstring := 'DOC_RN';
  cell_postav_code constant pkg_std.tstring := 'POSTAV_CODE';
  cell_postav_name constant pkg_std.tstring := 'POSTAV_NAME';
  cell_prin_dol    constant pkg_std.tstring := 'PRIN_DOL';
  cell_prin_fio    constant pkg_std.tstring := 'PRIN_FIO';
  cell_sdal_dol    constant pkg_std.tstring := 'SDAL_DOL';
  cell_sdal_fio    constant pkg_std.tstring := 'SDAL_FIO';
  cell_sklad       constant pkg_std.tstring := 'SKLAD';
  cell_vid_oper    constant pkg_std.tstring := 'VID_OPER';
  cell_comments    constant pkg_std.tstring := 'COMMENTS';
  cell_okpo        constant pkg_std.tstring := 'OKPO';

begin
  prsg_excel.prepare;
  prsg_excel.sheet_select(ch);

  prsg_excel.cell_describe(cell_date_sost);
  prsg_excel.cell_describe(cell_doc_nmb);
  prsg_excel.cell_describe(cell_doc_rn);
  prsg_excel.cell_describe(cell_postav_code);
  prsg_excel.cell_describe(cell_postav_name);
  prsg_excel.cell_describe(cell_prin_dol);
  prsg_excel.cell_describe(cell_prin_fio);
  prsg_excel.cell_describe(cell_sdal_dol);
  prsg_excel.cell_describe(cell_sdal_fio);
  prsg_excel.cell_describe(cell_sklad);
  prsg_excel.cell_describe(cell_vid_oper);
  prsg_excel.cell_describe(cell_comments);
  prsg_excel.cell_describe(cell_okpo);

  prsg_excel.line_describe(line_1);

  for i in 1 .. 12
  loop
  
    prsg_excel.line_cell_describe(line_1, 'CELL_' || i);
  
  end loop;

  for cur in (select doc.rn
                    ,trim(doc.docpref) || '-' || trim(doc.docnumb) doc_nmb
                    ,to_char(doc.docdate, 'DD.MM.YYYY') doc_date
                    ,doc.docdate ddate
                    ,my.fullname my_name
                    ,my.orgcode okpo
                    ,skl.azs_number
                    ,skl.azs_name skl_name
                    ,dep.name dep_name
                    ,doc.comments
                from selectlist sl
                join wroffacts doc
                  on doc.rn = sl.document
                join jurpersons jp
                  on jp.rn = doc.jur_pers
                join agnlist my
                  on my.rn = jp.agent
                join azsazslistmt skl
                  on skl.rn = doc.store
                left join ins_department dep
                  on dep.rn = skl.department
                join azsgsmwaystypes sop
                  on sop.rn = doc.stoper
              
               where sl.ident = pin_idn
                 and sl.authid = utilizer
                 and sl.unitcode = pin_uni
                 and sl.company = pin_com
                 and sop.gsmways_type = 1 --- Только приход!
              )
  loop
    prsg_excel.cell_value_write(cell_okpo, cur.okpo);
    prsg_excel.cell_value_write(cell_doc_rn, cur.rn);
    prsg_excel.cell_value_write(cell_date_sost, cur.doc_date);
    prsg_excel.cell_value_write(cell_sklad, cur.skl_name);
  
    for spe in (select d.nomen_code tov_code
                      ,d.nomen_name tov_name
                      ,ei.meas_mnemo oei
                      ,ei.code_okei
                      ,sp.quant q
                      ,rp.price p --- Учетная цена                      
                      ,case rp.price_calc_rule
                         when 0 then
                          1 -- Цена включают налоги
                         else
                          0 -- Не включают налоги
                       end prz
                      ,txr.p_value nds
                      ,udo_f_goodssplclc_shefr(nrn => gy.rn) tema
                  from wroffactspecs sp
                  join nommodif nm
                    on nm.rn = sp.nommodif
                  join dicnomns d
                    on d.rn = nm.prn
                  join dicmunts ei
                    on ei.rn = d.umeas_main
                  join goodssupply gy
                    on gy.rn = sp.goodssupply
                  join goodssupplyhist h
                    on h.prn = gy.rn
                  left join regprice rp
                    on rp.prn = gy.rn
                  left join dictaxgr tax
                    on tax.rn = rp.taxgr
                  left join dictaxis txr
                    on txr.tax_group = tax.rn
                
                 where sp.prn = cur.rn
                   and h.date_from = (select max(hh.date_from) from goodssupplyhist hh where hh.prn = gy.rn)
                   and (rp.adate is null or rp.adate = (select max(rp1.adate)
                                                          from regprice rp1
                                                         where rp1.prn = h.prn
                                                           and rp1.adate <= cur.ddate))
                   and (txr.beg_date is null or txr.beg_date = (select max(tx1.beg_date)
                                                                  from dictaxis tx1
                                                                 where tx1.tax_group = tax.rn
                                                                   and tx1.beg_date <= cur.ddate)))
    
    loop
    
      idx := prsg_excel.line_continue(line_1);
      prsg_excel.cell_value_write(cell_1, 0, idx, spe.tov_name);
      prsg_excel.cell_value_write(cell_2, 0, idx, spe.tov_code);
      prsg_excel.cell_value_write(cell_3, 0, idx, spe.code_okei);
      prsg_excel.cell_value_write(cell_4, 0, idx, spe.oei);
      prsg_excel.cell_value_write(cell_5, 0, idx, spe.q);
      prsg_excel.cell_value_write(cell_6, 0, idx, spe.q);
      prsg_excel.cell_value_write(cell_7, 0, idx, spe.p);
      prsg_excel.cell_value_write(cell_11, 0, idx, spe.tema);
    
      if spe.prz = 0
      then
        -- цена без НДС
        prsg_excel.cell_value_write(cell_8, 0, idx, round(spe.p * spe.q, 2));
        prsg_excel.cell_value_write(cell_9, 0, idx, round(round(spe.p * spe.q, 2) * spe.nds / 100, 2));
        prsg_excel.cell_value_write(cell_10, 0, idx, round(round(spe.p * spe.q, 2) * (1 + spe.nds / 100), 2));
      
      else
        null;
      
      end if;
    
    end loop;
    prsg_excel.line_delete(line_1);
  end loop;

end;
/
