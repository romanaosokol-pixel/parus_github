create or replace procedure usr_p_fcroutlst_reestr_isp
(
  pin_d1   in date
 ,pin_d2   in date
 ,pin_cust in varchar2
) is

  ch constant pkg_std.tstring := 'X';

  line_1 constant pkg_std.tstring := 'LINE_1';

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
  cell_13 constant pkg_std.tstring := 'CELL_13';
  cell_14 constant pkg_std.tstring := 'CELL_14';
  cell_15 constant pkg_std.tstring := 'CELL_15';
  cell_16 constant pkg_std.tstring := 'CELL_16';
  cell_17 constant pkg_std.tstring := 'CELL_17';
  cell_18 constant pkg_std.tstring := 'CELL_18';
  cell_19 constant pkg_std.tstring := 'CELL_19';
  cell_20 constant pkg_std.tstring := 'CELL_20';

begin

  prsg_excel.prepare;
  prsg_excel.sheet_select(ch);
  prsg_excel.line_describe(line_1);

  for i in 1 .. 20
  loop
  
    prsg_excel.line_cell_describe(line_1, 'CELL_' || i);
  
  end loop;

  for cur in (
    with his as (select fh.state
                       ,fh.prn
                      ,to_char(fh.state_date,'DD.MM.YYYY') sdate
                      ,ag.agnfamilyname || ' ' || substr(ag.agnfirstname, 1, 1) || '.' || substr(ag.agnlastname, 1, 1) || '.' fio
                      ,fh.spec nspec
                  from udo_fcroutlst_hist fh
                  join clnpersons cp
                    on cp.rn = fh.clnperson
                  join agnlist ag
                    on ag.rn = cp.pers_agent
                 /*where fh.spec = cur.nspec*/)
    select rl.rn
                   --- ,rls.rn nspec                     
                    ,fz.numb lic_nmb
                    ,udo_f_fcroutlst_product_num(nrn => rl.rn) zakaz
                    ,dep.code otdel
                    ,rls.oper_numb
                    ,trim(rls.oper_numb) || ', ' || trim(nvl((select o.name from fcopertypes o where rls.oper_tps = o.rn), rls.oper_uk)) sroutshtsp_name                     
                    ,d1.nomen_name mat_res_1
                    ,udo_f_fcroutlst_sernumb(nrn => rl.rn) ser_numb --- ïåğåäåëàòü íà èíôó èç èñòîğèè äâèæåíèÿ
                    ,rl.quant q --- Íóæíî ëè ıòî âûâîäèòü?                     
                    ,ei.meas_mnemo oei
                    ,udo_f_fcroutlst_sgp(rl.rn) nakl_sklad --- /Ïåğåäåëàòü, íóæåí òèï è äàòà                      
                    ,(select trim(dog.doc_pref) || '-' || trim(dog.doc_numb)
                        from stages st
                        join contracts dog
                          on dog.rn = st.prn
                       where st.faceacc = ps.faceacccust) dog_nmb
                    ,zak.agnname cust_NAME
                    ,zak.agnabbr cust_code
                    ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'ÒÊÏÀ', sunitcode => 'CostRouteLists', ndocument => rl.rn) otv
                    ,udo_f_fcroutlist_mainprod_num(nrn => rl.rn) snum_per_mr
                    ,f6.name sper_matres_name
                    ,udo_f_fcroutlst_tema(rl.faceacc) stema
                    ,HIS.state
                    ,his.sdate
                    ,his.fio
                from fcroutlst rl
                join projectstage ps
                  on ps.faceacc = rl.faceacc
                join faceacc fz
                  on fz.rn = rl.faceacc
                join fcroutlstsp rls
                  on rls.prn = rl.rn
                left join ins_department dep
                  on dep.rn = rls.subdiv
                join fcmatresource mr1
                  on mr1.rn = rl.matres
                join dicnomns d1
                  on d1.rn = mr1.nomenclature
                join dicmunts ei
                  on d1.umeas_main = ei.rn
              
                join faceacc fc
                  on fc.rn = ps.faceacccust
                join agnlist zak
                  on fc.agent = zak.rn
                left outer join fcmatresource f6
                  on rl.per_matres = f6.rn
                left join his on his.nspec = rls.rn   and his.prn = rl.rn
              
               where --rl.rn = 153152050
               rl.docdate between pin_d1 and pin_d2
               and (pin_cust is null or zak.agnabbr = pin_cust)
               
               order by rl.rn, rls.numb
               )
  
  loop
    idx := prsg_excel.line_continue(line_1);
  
    prsg_excel.cell_value_write(cell_1, 0, idx, cur.lic_nmb);
    prsg_excel.cell_value_write(cell_2, 0, idx, cur.zakaz);
    prsg_excel.cell_value_write(cell_3, 0, idx, cur.otdel);
    prsg_excel.cell_value_write(cell_4, 0, idx, cur.sroutshtsp_name);
  
    prsg_excel.cell_value_write(cell_7, 0, idx, cur.sper_matres_name);
    prsg_excel.cell_value_write(cell_8, 0, idx, cur.snum_per_mr);
    prsg_excel.cell_value_write(cell_9, 0, idx, cur.mat_res_1);
    prsg_excel.cell_value_write(cell_10, 0, idx, cur.ser_numb);
    prsg_excel.cell_value_write(cell_11, 0, idx, cur.q);
  
    prsg_excel.cell_value_write(cell_13, 0, idx, cur.oei);
    prsg_excel.cell_value_write(cell_14, 0, idx, cur.nakl_sklad);
    prsg_excel.cell_value_write(cell_15, 0, idx, cur.dog_nmb);
    prsg_excel.cell_value_write(cell_16, 0, idx, cur.otv);
  
    prsg_excel.cell_value_write(cell_19, 0, idx, cur.cust_Name);
    prsg_excel.cell_value_write(cell_20, 0, idx, cur.stema);
  
    --- Âûâîäèì èñïîëíèòåëåé
    
     if cur.state = 0 /* íà÷àëî */
        then 
          prsg_excel.cell_value_write(cell_5, 0, idx, cur.sdate);
          prsg_excel.cell_value_write(cell_6, 0, idx, cur.fio);
          
        else /* êîíåö */
          prsg_excel.cell_value_write(cell_17, 0, idx, cur.sdate);
          prsg_excel.cell_value_write(cell_18, 0, idx, cur.fio);  
        
      end if;
    
  
   /* for his in (select fh.state
                      ,to_char(fh.state_date,'DD.MM.YYYY') sdate
                      ,ag.agnfamilyname || ' ' || substr(ag.agnfirstname, 1, 1) || '.' || substr(ag.agnlastname, 1, 1) || '.' fio
                  from udo_fcroutlst_hist fh
                  join clnpersons cp
                    on cp.rn = fh.clnperson
                  join agnlist ag
                    on ag.rn = cp.pers_agent
                 where fh.spec = cur.nspec)
    
    loop
      if his.state = 0 \* íà÷àëî *\
        then 
          prsg_excel.cell_value_write(cell_5, 0, idx, his.sdate);
          prsg_excel.cell_value_write(cell_6, 0, idx, his.fio);
          
        else \* êîíåö *\
          prsg_excel.cell_value_write(cell_17, 0, idx, his.sdate);
          prsg_excel.cell_value_write(cell_18, 0, idx, his.fio);  
        
      end if;
        
    end loop;*/
  
  end loop;

  prsg_excel.line_delete(sline_name => line_1);

end;
/
