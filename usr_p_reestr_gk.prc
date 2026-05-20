create or replace procedure usr_p_reestr_gk
(
  pin_com       in number
 ,pin_gk_cust   in varchar2
 ,pin_beg_nomen in varchar2
 ,pin_d1        in date
 ,pin_d2        in date
 ,pin_dz1       in date
 ,pin_dz2       in date
 ,pin_vis_rn    in number
) is

  ch constant pkg_std.tstring := 'X';

  cell_rep_name constant pkg_std.tstring := 'REP_NAME';

  line_itg1 constant pkg_std.tstring := 'LINE_ITG1';
  line_det  constant pkg_std.tstring := 'LINE_DET';
  idx_itg integer;
  idx_det integer;

  ncatrn number(17) := 0;

  v_stage_pay_s_all number(17,2);
  v_stage_pay_s_do_end number(17,2);
                      
                      

  cell_1_1a constant pkg_std.tstring := 'CELL_1_1A';

  cell_1_1  constant pkg_std.tstring := 'CELL_1_1';
  cell_1_2  constant pkg_std.tstring := 'CELL_1_2';
  cell_1_3  constant pkg_std.tstring := 'CELL_1_3';
  cell_1_4  constant pkg_std.tstring := 'CELL_1_4';
  cell_1_5  constant pkg_std.tstring := 'CELL_1_5';
  cell_1_6  constant pkg_std.tstring := 'CELL_1_6';
  cell_1_7  constant pkg_std.tstring := 'CELL_1_7';
  cell_1_8  constant pkg_std.tstring := 'CELL_1_8';
  cell_1_9  constant pkg_std.tstring := 'CELL_1_9';
  cell_1_10 constant pkg_std.tstring := 'CELL_1_10';
  cell_1_11 constant pkg_std.tstring := 'CELL_1_11';
  cell_1_12 constant pkg_std.tstring := 'CELL_1_12';
  cell_1_13 constant pkg_std.tstring := 'CELL_1_13';
  cell_1_14 constant pkg_std.tstring := 'CELL_1_14';
  cell_1_15 constant pkg_std.tstring := 'CELL_1_15';
  cell_1_16 constant pkg_std.tstring := 'CELL_1_16';
  cell_1_17 constant pkg_std.tstring := 'CELL_1_17';
  cell_1_18 constant pkg_std.tstring := 'CELL_1_18';
  cell_1_19 constant pkg_std.tstring := 'CELL_1_19';

  cell_det1  constant pkg_std.tstring := 'CELL_DET1';
  cell_det2  constant pkg_std.tstring := 'CELL_DET2';
  cell_det3  constant pkg_std.tstring := 'CELL_DET3';
  cell_det4  constant pkg_std.tstring := 'CELL_DET4';
  cell_det5  constant pkg_std.tstring := 'CELL_DET5';
  cell_det6  constant pkg_std.tstring := 'CELL_DET6';
  cell_det7  constant pkg_std.tstring := 'CELL_DET7';
  cell_det8  constant pkg_std.tstring := 'CELL_DET8';
  cell_det9  constant pkg_std.tstring := 'CELL_DET9';
  cell_det10 constant pkg_std.tstring := 'CELL_DET10';
  cell_det11 constant pkg_std.tstring := 'CELL_DET11';
  cell_det12 constant pkg_std.tstring := 'CELL_DET12';
  cell_det13 constant pkg_std.tstring := 'CELL_DET13';
  cell_det14 constant pkg_std.tstring := 'CELL_DET14';
  cell_det15 constant pkg_std.tstring := 'CELL_DET15';
  cell_det16 constant pkg_std.tstring := 'CELL_DET16';
  cell_det17 constant pkg_std.tstring := 'CELL_DET17';
  cell_det18 constant pkg_std.tstring := 'CELL_DET18';
  cell_det19 constant pkg_std.tstring := 'CELL_DET19';

  col_18 constant pkg_std.tstring := 'COL_18';

  val_1  varchar2(240);
  val_2  number(4) := 0;
  val_3  number(15, 2) := 0;
  val_4  number(4) := 0;
  val_5  number(10, 2) := 0;
  val_6  number(4) := 0;
  val_7d number(10, 2) := 0;
  val_7  number(10, 2) := 0;

  val_8 number(10, 2) := 0;
  val_9 number(10, 2) := 0;

  val_12 number(4) := 0;
  val_13 number(10, 2) := 0;

  val_10 number(10, 2) := 0;
  val_16 number(10, 2) := 0;

begin

  prsg_excel.prepare;
  prsg_excel.sheet_select(ch);
  prsg_excel.line_describe(line_itg1);
  prsg_excel.line_describe(line_det);
  prsg_excel.column_describe(col_18);

  if pin_vis_rn = 0
  then
    prsg_excel.column_delete(col_18);
  end if;

  prsg_excel.line_cell_describe(line_itg1
                               ,cell_1_1a);

  for i in 1 .. 19
  loop
  
    prsg_excel.line_cell_describe(line_itg1
                                 ,'CELL_1_' || i);
    prsg_excel.line_cell_describe(line_det
                                 ,'CELL_DET' || i);
  
  end loop;

  --- 
  for cur in (with cat as
                 (select a.rn
                       ,a.name
                   from acatalog a
                  where a.docname = 'Contracts'
                    and a.company = pin_com
                 connect by prior a.rn = a.crn
                  start with a.name = 'Коммерция')
                
                select cat.rn catrn
                      ,case
                         when nvl(dog.reg_date
                                 ,dog.doc_date) between pin_dz1 and pin_dz2 then
                          1
                         else
                          0
                       end in_period
                      ,cat.name cat_name
                      ,nvl(dog.ext_number
                          ,trim(dog.doc_pref) || '-' || trim(dog.doc_numb)) ext_number
                      ,nvl(dog.reg_date
                          ,dog.doc_date) dog_reg_date_d
                      ,to_char(nvl(dog.reg_date
                                  ,dog.doc_date)
                              ,'DD.MM.YYYY') dog_reg_date_s
                      ,udo_f_contract_coperplan(nrn => dog.rn) nomen_code
                      , /*usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Заказчик работ'
                                                                                                                                                                             ,sunitcode  => 'Contracts'
                                                                                                                                                                             ,ndocument  => dog.rn)*/usr_f_contracts_gkcust(dog.rn) zr
                      ,dog.doc_sumtax
                      ,dog.rn
                
                  from contracts dog
                  join cat
                    on cat.rn = dog.crn
                 where ---dog.rn = 160712877 and ---( 122539728,113829317,122539540,145456855,162993979,166072136) and 
                
                 dog.status != 0 --- Не утвержденные нам не нужны
             and dog.status != 3 --- не утвержденные и просто согалсованные НИКОГДА не попадают
                
             and ((dog.status = 1 and
                     dog.begin_date <=  pin_d2 -- Утвержденные начались не позднее даты окончания отчета. Само утверждение не позже даты окончания отчета
                     and dog.confirm_date <= pin_d2)
                 
                 or (dog.status = 2 and dog.close_date >= pin_d1 ) -- Закрытые после даты начала отчета
                 )
                
             and (pin_beg_nomen is null or udo_f_contract_coperplan(nrn => dog.rn) like pin_beg_nomen || '%')
             and usr_f_contracts_gkcust(dog.rn) = pin_gk_cust
                
             and exists (select 1 -- Хотя бы один этап с типом "Продажа"
                    from stages st
                    join faceacc f
                      on f.rn = st.faceacc
                   where st.prn = dog.rn
                     and f.acc_kind = 1 -- Продажа
                  )
                
              ---  and (  user = 'GOR' and dog.rn = 75088873   )
                 order by cat.name
                         ,dog.doc_date
                         ,dog.ext_number
                
              )
  loop
  
    if ncatrn != cur.catrn
    
    then
      idx_itg := prsg_excel.line_continue(line_itg1);
    
      if ncatrn != 0 /* Первый раз итогине выводим */
      then
      
        prsg_excel.cell_value_write(cell_1_1
                                   ,0
                                   ,idx_itg - 1
                                   ,val_1);
        val_1 := cur.cat_name;
        prsg_excel.cell_value_write(cell_1_1a
                                   ,0
                                   ,idx_itg - 1
                                   ,' ');
        prsg_excel.cell_value_write(cell_1_2
                                   ,0
                                   ,idx_itg - 1
                                   ,val_2);
        prsg_excel.cell_value_write(cell_1_3
                                   ,0
                                   ,idx_itg - 1
                                   ,val_3);
        if cur.in_period = 1
        then
          prsg_excel.cell_value_write(cell_1_4
                                     ,0
                                     ,idx_itg - 1
                                     ,val_4);
          prsg_excel.cell_value_write(cell_1_5
                                     ,0
                                     ,idx_itg - 1
                                     ,val_5);
        end if;
      
        prsg_excel.cell_value_write(cell_1_6
                                   ,0
                                   ,idx_itg - 1
                                   ,val_6);
        prsg_excel.cell_value_write(cell_1_7
                                   ,0
                                   ,idx_itg - 1
                                   ,val_7);
        prsg_excel.cell_value_write(cell_1_8
                                   ,0
                                   ,idx_itg - 1
                                   ,val_8);
        prsg_excel.cell_value_write(cell_1_9
                                   ,0
                                   ,idx_itg - 1
                                   ,val_9);
        prsg_excel.cell_value_write(cell_1_12
                                   ,0
                                   ,idx_itg - 1
                                   ,1); --- Всегда 1
        prsg_excel.cell_value_write(cell_1_13
                                   ,0
                                   ,idx_itg - 1
                                   ,val_13);
      
        val_2  := 0;
        val_3  := 0;
        val_4  := 0;
        val_5  := 0;
        val_6  := 0;
        val_7  := 0;
        val_8  := 0;
        val_9  := 0;
        val_12 := 0;
        val_13 := 0;
      
      else
      
        val_1 := cur.cat_name;
      end if;
      ncatrn := cur.catrn;
    end if;
  
    idx_det := prsg_excel.line_continue(line_det);
  
    if pin_vis_rn = 1
    then
      prsg_excel.cell_value_write(cell_det18
                                 ,0
                                 ,idx_det
                                 ,cur.rn);
    end if;
  
    prsg_excel.cell_value_write(cell_det1
                               ,0
                               ,idx_det
                               , /*cur.RN||' '||*/cur.ext_number || ' от ' || cur.dog_reg_date_s);
    prsg_excel.cell_value_write(cell_det2
                               ,0
                               ,idx_det
                               ,1);
    val_2 := val_2 + 1;
    prsg_excel.cell_value_write(cell_det3
                               ,0
                               ,idx_det
                               ,round(cur.doc_sumtax / 1000
                                     ,2));
    val_3 := val_3 + round(cur.doc_sumtax / 1000
                          ,2);
  
    if cur.dog_reg_date_d between pin_d1 and pin_d2
    then
    
      prsg_excel.cell_value_write(cell_det4
                                 ,0
                                 ,idx_det
                                 ,1);
      val_4 := val_4 + 1;
      prsg_excel.cell_value_write(cell_det5
                                 ,0
                                 ,idx_det
                                 ,round(cur.doc_sumtax / 1000
                                       ,2));
      val_5 := val_5 + round(cur.doc_sumtax / 1000
                            ,2);
    
    end if;
  
    --- Выбираем платежи
    val_7d        := 0;
    v_stage_pay_s_all := 0;
    v_stage_pay_s_do_end := 0;
    
    for pay in (select st.prn
                      ,case vp.gsmpayments_mnemo
                         when 'ПредоплатаБезнал' then
                          0 --- Аванс
                         else
                          1 -- окончательный расчет
                       end is_fin_opl
                       /* OP.TYPOPER_DIRECT NAPR -- Направление средств операции  0 - приход, 1-расход */
                      ,sum(case
                             when pn.pay_date between pin_d1 and pin_d2 then
                              pn.pay_sum * (1 - 2 * op.typoper_direct)
                             else
                              0
                           end) pay_sum_in_per
                      ,sum(pn.pay_sum * (1 - 2 * op.typoper_direct)) pay_sum_ALL
                      ,sum(case when pn.pay_date <= PIN_d2 then pn.pay_sum * (1 - 2 * op.typoper_direct) else null end) pay_sum_do_end
                      
                  from stages st
                  join paynotes pn
                    on pn.faceacc = st.faceacc
                  join azsgsmpaymentstypes vp
                    on vp.rn = pn.pay_type
                  join dictoper op
                    on op.rn = pn.finoper
                
                 where st.prn = cur.rn
                   and pn.signplan = 0
                                      --and pn.pay_date <= PIN_d2
                 group by st.prn
                         ,case vp.gsmpayments_mnemo
                            when 'ПредоплатаБезнал' then
                             0 --- Аванс
                            else
                             1 -- окончательный расчет
                          end)
    loop
      v_stage_pay_S_All := v_stage_pay_S_ALL + nvl(pay.pay_sum_ALL,0);
      v_stage_pay_s_do_end:=v_stage_pay_s_do_end + nvl(pay.pay_sum_do_end,0);
      
     
    
      val_7d := val_7d + round(pay.pay_sum_in_per / 1000
                              ,2);
    
      if pay.is_fin_opl = 0
      then
        /* Это Аванс */
      
        prsg_excel.cell_value_write(cell_det9
                                   ,0
                                   ,idx_det
                                   ,round(pay.pay_sum_in_per / 1000
                                         ,2));
        val_9 := val_9 + round(pay.pay_sum_in_per / 1000
                              ,2);
      
        ---  prsg_excel.cell_value_write(cell_det15, 0, idx_det, round(pay.pay_sum / 1000, 2));
      
      else
        /* Окончательная оплата */
      
        prsg_excel.cell_value_write(cell_det8
                                   ,0
                                   ,idx_det
                                   ,round(pay.pay_sum_in_per / 1000
                                         ,2));
        val_8 := val_8 + round(pay.pay_sum_in_per / 1000
                              ,2);
      
        -- prsg_excel.cell_value_write(cell_det17, 0, idx_det, round(pay.pay_sum / 1000, 2));
      
      end if;
    
    end loop;
  
    if val_7d != 0
    then
      prsg_excel.cell_value_write(cell_det6
                                 ,0
                                 ,idx_det
                                 ,1);
      val_6 := val_6 + 1;
      prsg_excel.cell_value_write(cell_det7
                                 ,0
                                 ,idx_det
                                 ,val_7d);
      val_7 := val_7 + val_7d;
    
    end if;
  
    /* Исполнено */
  
    for isp in (select z.isp_s_all
                      ,z.isp_q_all
                      ,z.stage_sumtax
                      ,(select sum(fp.quant)
                          from fcacoperplans fp
                         where fp.prn = z.faceacc
                           and fp.inexp_sign = 1) stage_quant
                  from (select nvl(sum(jr.summtax * (1 - 2 * op.gsmways_type))
                                  ,0) isp_s_all
                              ,nvl(sum(jr.quant * (1 - 2 * op.gsmways_type))
                                  ,0) isp_q_all
                              ,st.stage_sumtax
                              ,st.faceacc
                          from stages st
                          join storeoperjourn jr
                            on st.faceacc = jr.faceacc
                          join azsgsmwaystypes op
                            on op.rn = jr.stoper
                         where st.prn = cur.rn
                           and jr.signplan != 1
                           and jr.operdate <= pin_d2 --- Отгрузки До даты окончания отчета
                         group by st.stage_sumtax
                                 ,st.faceacc) z
                
                )
    loop
    
  ---  P_exception(0,'isp.isp_q_all = %s, isp.stage_quant = %s',isp.isp_q_all , isp.stage_quant);
      if isp.isp_q_all = isp.stage_quant /*Только полностью отгруженные */
      then
       
      
        v_stage_pay_s_do_end:=nvl(v_stage_pay_s_do_end,0);
        
       --- P_exception(0,'v_stage_pay_s_do_end = %s, isp.stage_sumtax = %s',v_stage_pay_s_do_end , isp.stage_sumtax);
  
        if v_stage_pay_s_do_end != isp.stage_sumtax
        then
          /*Сумма фактических платежей не равна сумме этапа */
          if v_stage_pay_s_do_end != 0 then 
          prsg_excel.cell_value_write(cell_det19
                                     ,0
                                     ,idx_det
                                     ,1);-- Не полностью оплаченные
          end if;                           
          
          

          prsg_excel.cell_value_write(cell_det16
                                     ,0
                                     ,idx_det
                                     ,round((isp.stage_sumtax - v_stage_pay_s_do_end/*v_stage_pay_S_All*/) / 1000
                                           ,2));
          val_16 := val_16 + round((isp.stage_sumtax - v_stage_pay_s_do_end/*v_stage_pay_S_All*/) / 1000
                                  ,2);
        
        else
        
          prsg_excel.cell_value_write(cell_det12
                                     ,0
                                     ,idx_det
                                     ,1/*isp.isp_q_all*/); -- Всегда 1, так захотели
          val_12 := val_12 + isp.isp_q_all;
        
          prsg_excel.cell_value_write(cell_det13
                                     ,0
                                     ,idx_det
                                     ,round(isp.isp_s_all / 1000
                                           ,2));
          val_13 := val_13 + round(isp.isp_s_all / 1000
                                  ,2);
        end if;
        else
           if isp.isp_q_all !=0 then -- Не полностью отгруженные
           prsg_excel.cell_value_write(cell_det19
                                     ,0
                                     ,idx_det
                                     ,2);
          end if;                           
        
      end if;
    
    end loop;
  
  /* Задолженность */
  /* Оплачено меньше отгружено */
  /*if val_7d < round(cur.otgr / 1000, 2) then 
                      
                    elsif */
  
  ---prsg_excel.cell_value_write(cell_det10, 0, idx_det, cur.rn);
  end loop;
  if idx_itg is not null
  then
    prsg_excel.cell_value_write(cell_1_1
                               ,0
                               ,idx_itg
                               ,val_1);
    prsg_excel.cell_value_write(cell_1_1a
                               ,0
                               ,idx_itg
                               ,' ');
    prsg_excel.cell_value_write(cell_1_2
                               ,0
                               ,idx_itg
                               ,val_2);
    prsg_excel.cell_value_write(cell_1_3
                               ,0
                               ,idx_itg
                               ,val_3);
    prsg_excel.cell_value_write(cell_1_4
                               ,0
                               ,idx_itg
                               ,val_4);
    prsg_excel.cell_value_write(cell_1_5
                               ,0
                               ,idx_itg
                               ,val_5);
    prsg_excel.cell_value_write(cell_1_6
                               ,0
                               ,idx_itg
                               ,val_6);
    prsg_excel.cell_value_write(cell_1_7
                               ,0
                               ,idx_itg
                               ,val_7);
    prsg_excel.cell_value_write(cell_1_8
                               ,0
                               ,idx_itg
                               ,val_8);
    prsg_excel.cell_value_write(cell_1_9
                               ,0
                               ,idx_itg
                               ,val_9);
    prsg_excel.cell_value_write(cell_1_12
                               ,0
                               ,idx_itg -- Не выводим!
                               ,1);
    prsg_excel.cell_value_write(cell_1_13
                               ,0
                               ,idx_itg
                               ,val_13);
    prsg_excel.cell_value_write(cell_1_16
                               ,0
                               ,idx_itg
                               ,val_16);
  end if;
  prsg_excel.line_delete(sline_name => line_det);
  prsg_excel.line_delete(sline_name => line_itg1);

end;
/
