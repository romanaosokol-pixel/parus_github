create or replace procedure usr_p_dog_stages_2025_1(nident in number
                                                    --- ,ddocdate in date
                                                   ,
                                                    --- nZakaz     in number,
                                                    srazd in varchar2)

  /* Версия отчета от 20-06-2025 */

  ---- Процедура отчета "Этапы договоров"
 as
  ---- Переменные отчета
  ch constant pkg_std.tstring := 'X'; -- Лист

  c_sname constant pkg_std.tstring := 'Zagolovok';
  c_sdata constant pkg_std.tstring := 'Data';

  /*LINE_GEN constant pkg_std.tstring := 'LINE_GEN';
  c_General_inf constant pkg_std.tstring := 'General_inf ';*/
  line_b  constant pkg_std.tstring := 'LINE_B';
  line_dg constant pkg_std.tstring := 'LINE_DG';

  cell_d1  constant pkg_std.tstring := 'CELL_D1';
  cell_d2  constant pkg_std.tstring := 'CELL_D2';
  cell_d3  constant pkg_std.tstring := 'CELL_D3';
  cell_d4  constant pkg_std.tstring := 'CELL_D4';
  cell_d5  constant pkg_std.tstring := 'CELL_D5';
  cell_d6  constant pkg_std.tstring := 'CELL_D6';
  cell_d7  constant pkg_std.tstring := 'CELL_D7';
  cell_d8  constant pkg_std.tstring := 'CELL_D8';
  cell_d9  constant pkg_std.tstring := 'CELL_D9';
  cell_d10 constant pkg_std.tstring := 'CELL_D10';
  cell_d11 constant pkg_std.tstring := 'CELL_D11';
  cell_d12 constant pkg_std.tstring := 'CELL_D12';
  cell_d13 constant pkg_std.tstring := 'CELL_D13';
  cell_d14 constant pkg_std.tstring := 'CELL_D14';
  cell_d15 constant pkg_std.tstring := 'CELL_D15';
  cell_d16 constant pkg_std.tstring := 'CELL_D16';
  cell_d17 constant pkg_std.tstring := 'CELL_D17';
  cell_d18 constant pkg_std.tstring := 'CELL_D18';
  cell_d19 constant pkg_std.tstring := 'CELL_D19';
  cell_d20 constant pkg_std.tstring := 'CELL_D20';
  cell_d21 constant pkg_std.tstring := 'CELL_D21';
  cell_d22 constant pkg_std.tstring := 'CELL_D22';

  cell_d_i6  constant pkg_std.tstring := 'CELL_D_I6';
  cell_d_i10 constant pkg_std.tstring := 'CELL_D_I10';
  cell_d_i12 constant pkg_std.tstring := 'CELL_D_I12';

  line_isp    constant pkg_std.tstring := 'LINE_ISP';
  cell_isp_1  constant pkg_std.tstring := 'CELL_ISP_1';
  cell_isp_2  constant pkg_std.tstring := 'CELL_ISP_2';
  cell_isp_3  constant pkg_std.tstring := 'CELL_ISP_3';
  cell_isp_4  constant pkg_std.tstring := 'CELL_ISP_4';
  cell_isp_5  constant pkg_std.tstring := 'CELL_ISP_5';
  cell_isp_6  constant pkg_std.tstring := 'CELL_ISP_6';
  cell_isp_7  constant pkg_std.tstring := 'CELL_ISP_7';
  cell_isp_8  constant pkg_std.tstring := 'CELL_ISP_8';
  cell_isp_9  constant pkg_std.tstring := 'CELL_ISP_9';
  cell_isp_10 constant pkg_std.tstring := 'CELL_ISP_10';
  cell_isp_11 constant pkg_std.tstring := 'CELL_ISP_11';
  cell_isp_12 constant pkg_std.tstring := 'CELL_ISP_12';
  cell_isp_13 constant pkg_std.tstring := 'CELL_ISP_13';

  cell_isp_16 constant pkg_std.tstring := 'CELL_ISP_16';

  cell_isp_d2 constant pkg_std.tstring := 'CELL_ISP_D2';
  cell_isp_d3 constant pkg_std.tstring := 'CELL_ISP_D3';
  cell_isp_d4 constant pkg_std.tstring := 'CELL_ISP_D4';
  cell_isp_d5 constant pkg_std.tstring := 'CELL_ISP_D5';
  cell_isp_d6 constant pkg_std.tstring := 'CELL_ISP_D6';

  line_isp_sp   constant pkg_std.tstring := 'LINE_ISP_SP';
  cell_isp_sp_1 constant pkg_std.tstring := 'CELL_ISP_SP_1';
  cell_isp_sp_2 constant pkg_std.tstring := 'CELL_ISP_SP_2';
  cell_isp_sp_3 constant pkg_std.tstring := 'CELL_ISP_SP_3';
  cell_isp_sp_4 constant pkg_std.tstring := 'CELL_ISP_SP_4';
  cell_isp_sp_5 constant pkg_std.tstring := 'CELL_ISP_SP_5';
  cell_isp_sp_6 constant pkg_std.tstring := 'CELL_ISP_SP_6';
  cell_isp_sp_7 constant pkg_std.tstring := 'CELL_ISP_SP_7';
  cell_isp_sp_8 constant pkg_std.tstring := 'CELL_ISP_SP_8';
  cell_isp_sp_9 constant pkg_std.tstring := 'CELL_ISP_SP_9';

  cell_isp_sp_16 constant pkg_std.tstring := 'CELL_ISP_SP_16';

  line_1 constant pkg_std.tstring := 'Stroka';

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
  cell_21 constant pkg_std.tstring := 'CELL_21';
  cell_22 constant pkg_std.tstring := 'CELL_22';

  idx_dg  integer;
  idx_sp  integer;
  idx_isp integer;
  idx_b   integer;

  v_sp_pay_av number(17, 2);
  v_sp_pay_ok number(17, 2);

  v_isp_pay_av number(17, 2);
  v_isp_pay_ok number(17, 2);

  v_18_itg number(17, 2);
  v_19_itg number(17, 2);
  v_21_itg number(17, 2);
  v_i6     number(17, 2);
  v_i10    number(17, 2);
  v_i12    number(17, 2);

begin

  prsg_excel.prepare;
  -- Установка текущего рабочего листа
  prsg_excel.sheet_select(ch);
  -- Описываем имена ячеек в шапке и подвале
  prsg_excel.cell_describe(c_sname);
  prsg_excel.cell_describe(c_sdata);

  /*prsg_excel.line_describe(LINE_GEN);
  prsg_excel.line_cell_describe(LINE_GEN, c_General_inf);*/

  prsg_excel.line_describe(line_1);
  prsg_excel.line_describe(line_b);
  prsg_excel.line_describe(line_dg);
  prsg_excel.line_describe(line_isp);
  prsg_excel.line_describe(line_isp_sp);

  for i in 1 .. 22
  loop
  
    prsg_excel.line_cell_describe(line_1, 'CELL_' || i);
    prsg_excel.line_cell_describe(line_dg, 'CELL_D' || i);
  
  end loop;
  --- Итоги сосиполнителей по догоору
  prsg_excel.line_cell_describe(line_dg, cell_d_i6);
  prsg_excel.line_cell_describe(line_dg, cell_d_i10);
  prsg_excel.line_cell_describe(line_dg, cell_d_i12);

  for i in 1 .. 13
  loop
  
    prsg_excel.line_cell_describe(line_isp, 'CELL_ISP_' || i);
    prsg_excel.line_cell_describe(line_isp, 'CELL_ISP_SP_' || i);
  
  end loop;

  prsg_excel.line_cell_describe(line_isp, cell_isp_16);
  prsg_excel.line_cell_describe(line_isp, cell_isp_sp_16);

  prsg_excel.line_cell_describe(line_isp, cell_isp_d2);
  prsg_excel.line_cell_describe(line_isp, cell_isp_d3);
  prsg_excel.line_cell_describe(line_isp, cell_isp_d4);
  prsg_excel.line_cell_describe(line_isp, cell_isp_d5);
  prsg_excel.line_cell_describe(line_isp, cell_isp_d6);

  ---Заполнение шапки отчета
  prsg_excel.cell_value_write(c_sname, 'Этапы договоров');
  prsg_excel.cell_value_write(c_sdata, 'На ' || to_char(sysdate, 'DD.MM.YYYY'));

  /* Цикл по договорам */

  for dg in (select dog.rn
                   ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Заказчик работ'
                                                       ,sunitcode  => 'Contracts'
                                                       ,ndocument  => dog.rn) zr
                   ,nvl(ag.fullname, ag.agnname) agent
                   ,nvl(dog.ext_number, '???') ext_number
                   ,to_char(dog.doc_date, 'DD.MM.YYYY') dd
                   ,udo_f_get_usl_name(dog.rn) name_usl
                   ,dog.subject
                   ,to_char(dog.begin_date, 'DD.MM.YYYY') begin_date
                   ,to_char(dog.end_date, 'DD.MM.YYYY') end_date
                   ,to_char(dog.close_date, 'DD.MM.YYYY') close_date
                   ,dog.doc_sumtax
                   ,dog.doc_sum
                   ,dog.doc_sum_nds
                   ,dog.fact_inpay_sum in_pay_sum
                   ,dog.fact_outgood_sum out_otg_sum
                   ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Сотрудник', sunitcode => 'Contracts', ndocument => dog.rn) sotr
                   ,usr_pkg_docs_props_vals.get_val_str(sprop_code => 'Заместитель ГД'
                                                       ,sunitcode  => 'Contracts'
                                                       ,ndocument  => dog.rn) zam_gd
                   ,usr_f_dscr_ct_prj_code(nrn => dog.rn) zakaz
               from selectlist sl
               join contracts dog
                 on dog.rn = sl.document
               join agnlist ag
                 on ag.rn = dog.agent
              where sl.ident = nident
                and sl.authid = utilizer
                and sl.unitcode = srazd)
  loop
  
    idx_dg := prsg_excel.line_continue(sline_name => line_dg);
  
    prsg_excel.cell_value_write(cell_d1, 0, idx_dg, idx_dg);
    prsg_excel.cell_value_write(cell_d2, 0, idx_dg, dg.zr);
    prsg_excel.cell_value_write(cell_d3, 0, idx_dg, dg.agent);
    prsg_excel.cell_value_write(cell_d4, 0, idx_dg, dg.ext_number || ' от ' || dg.dd);
    prsg_excel.cell_value_write(cell_d5, 0, idx_dg, dg.dd);
    prsg_excel.cell_value_write(cell_d6
                               ,0
                               ,idx_dg
                               ,dg.subject || case when dg.name_usl is not null then ' (' || dg.name_usl || ')' else '' end);
  
    prsg_excel.cell_value_write(cell_d9, 0, idx_dg, dg.zakaz);
  
    prsg_excel.cell_value_write(cell_d10, 0, idx_dg, trim(to_char(dg.doc_sumtax, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''')));
    prsg_excel.cell_value_write(cell_d11
                               ,0
                               ,idx_dg
                               ,trim(to_char(dg.doc_sum_nds, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=''. ''')));
  
    prsg_excel.cell_value_write(cell_d12, 0, idx_dg, dg.begin_date);
    prsg_excel.cell_value_write(cell_d13, 0, idx_dg, dg.end_date);
    prsg_excel.cell_value_write(cell_d14, 0, idx_dg, dg.close_date);
  
    prsg_excel.cell_value_write(cell_d16, 0, idx_dg, dg.sotr);
    prsg_excel.cell_value_write(cell_d17, 0, idx_dg, dg.zam_gd);
  
    v_18_itg := 0;
    v_19_itg := 0;
    v_21_itg := 0;
    v_i6     := 0;
    v_i10    := 0;
    v_i12    := 0;
    for st in (
               
               select st.rn
                      ,st.faceacc
                      ,trim(st.numb) numb
                      ,st.description name
                      ,udo_f_stages_buhnum(st.rn) nmb_zak
                      ,st.stage_sumtax
                      ,st.stage_sum_nds
                      ,to_char(f.fact_close_date, 'DD.MM.YYYY') close_date
                      ,to_char(st.begin_date, 'DD.MM.YYYY') begin_date
                      ,to_char(st.end_date, 'DD.MM.YYYY') end_date
                      ,to_char(usr_pkg_docs_props_vals.get_val_date(sprop_code => 'Реальная дата'
                                                                   ,sunitcode  => 'ContractsStages'
                                                                   ,ndocument  => st.rn)
                              ,'DD.MM.YYYY') akt_date
                      ,lead(st.rn) over(order by st.numb) nn
               
                 from stages st
                 join faceacc f
                   on f.rn = st.faceacc
               
                where st.prn = dg.rn
               
                order by st.numb)
    loop
    
      idx_sp := prsg_excel.line_continue(sline_name => line_1);
    
      prsg_excel.cell_value_write(cell_1, 0, idx_sp, idx_dg || '.' || idx_sp);
      prsg_excel.cell_value_write(cell_7, 0, idx_sp, st.numb);
      prsg_excel.cell_value_write(cell_8, 0, idx_sp, st.name);
      prsg_excel.cell_value_write(cell_9, 0, idx_sp, st.nmb_zak);
      prsg_excel.cell_value_write(cell_10, 0, idx_sp, st.stage_sumtax);
      prsg_excel.cell_value_write(cell_11, 0, idx_sp, st.stage_sum_nds);
      prsg_excel.cell_value_write(cell_12, 0, idx_sp, st.begin_date);
      prsg_excel.cell_value_write(cell_13, 0, idx_sp, st.end_date);
      prsg_excel.cell_value_write(cell_14, 0, idx_sp, st.close_date);
      prsg_excel.cell_value_write(cell_15, 0, idx_sp, st.akt_date); --- /* Ожидаемая дата отгрузки */
      prsg_excel.cell_value_write(cell_16, 0, idx_sp, dg.sotr);
    
      /*Протягиваем значения из договора */
    
      prsg_excel.cell_value_write(cell_2, 0, idx_sp, dg.zr);
      prsg_excel.cell_value_write(cell_3, 0, idx_sp, dg.agent);
      prsg_excel.cell_value_write(cell_4, 0, idx_sp, dg.ext_number || ' от ' || dg.dd);
      prsg_excel.cell_value_write(cell_5, 0, idx_sp, dg.dd);
      prsg_excel.cell_value_write(cell_6
                                 ,0
                                 ,idx_sp
                                 ,dg.subject || case when dg.name_usl is not null then ' (' || dg.name_usl || ')' else '' end);
    
      /* Платежи */
    
      v_sp_pay_av := 0;
      v_sp_pay_ok := 0;
    
      for pay in (select case vp.gsmpayments_mnemo
                           when 'ПредоплатаБезнал' then
                            0 --- Аванс
                           else
                            1 -- окончательный расчет
                         end is_fin_opl
                        ,sum(pn.pay_sum * (1 - 2 * op.typoper_direct)) pay_sum
                        ,to_char(max(pn.pay_date), 'DD.MM.YYYY') pay_date
                    from paynotes pn
                    join azsgsmpaymentstypes vp
                      on vp.rn = pn.pay_type
                    join dictoper op
                      on op.rn = pn.finoper
                  
                   where pn.faceacc = st.faceacc
                     and pn.signplan = 0
                  
                   group by case vp.gsmpayments_mnemo
                              when 'ПредоплатаБезнал' then
                               0 --- Аванс
                              else
                               1 -- окончательный расчет
                            end)
      loop
      
        if pay.is_fin_opl = 0
        then
          /* Это аванс */
          prsg_excel.cell_value_write(cell_19, 0, idx_sp, pay.pay_sum);
          prsg_excel.cell_value_write(cell_20, 0, idx_sp, pay.pay_date);
          v_sp_pay_av := v_sp_pay_av + pay.pay_sum;
        else
          prsg_excel.cell_value_write(cell_21, 0, idx_sp, pay.pay_sum);
          prsg_excel.cell_value_write(cell_22, 0, idx_sp, pay.pay_date);
          v_sp_pay_ok := v_sp_pay_ok + pay.pay_sum;
        end if;
      
      end loop;
    
      prsg_excel.cell_value_write(cell_18, 0, idx_sp, v_sp_pay_av + v_sp_pay_ok);
    
      v_18_itg := v_18_itg + v_sp_pay_av + v_sp_pay_ok; -- Собираем итоги по договору
      v_19_itg := v_19_itg + v_sp_pay_av;
      v_21_itg := v_21_itg + v_sp_pay_ok;
      /*Выводим договор соисполниеля конкретного этапа*/
    
      for isp in (select nvl(ag.fullname, ag.agnname) agent
                        ,nvl(dg.ext_number, '???') ext_number
                        ,to_char(dg.doc_date, 'DD.MM.YYYY') dd
                        ,dg.subject || chr(10) || udo_f_get_usl_name(dg.rn) subject
                        ,trim(s.numb) stage_nmb
                        ,to_char(dg.begin_date, 'DD.MM.YYYY') begin_date
                        ,to_char(dg.end_date, 'DD.MM.YYYY') end_date
                        ,s.stage_sumtax
                        ,nvl(to_char(fc.fact_close_date, 'DD.MM.YYYY'), '-') fact_close_date
                        ,s.faceacc
                    from projectstage ps
                    join projectstagepf ip
                      on ip.prn = ps.rn
                    join stages s
                      on s.faceacc = ip.faceacc
                    join contracts dg
                      on dg.rn = s.prn
                    join faceacc fc
                      on fc.rn = s.faceacc
                    join agnlist ag
                      on ag.rn = dg.agent
                  
                   where ps.faceacccust = st.faceacc)
      loop
      
        idx_isp := prsg_excel.line_continue(sline_name => line_isp);
      
        prsg_excel.cell_value_write(cell_isp_1, 0, idx_isp, idx_dg || '.' || idx_sp || '.' || idx_isp);
        prsg_excel.cell_value_write(cell_isp_2, 0, idx_isp, isp.agent);
        prsg_excel.cell_value_write(cell_isp_3, 0, idx_isp, isp.ext_number || ' от ' || isp.dd);
        prsg_excel.cell_value_write(cell_isp_4, 0, idx_isp, isp.subject);
        prsg_excel.cell_value_write(cell_isp_5, 0, idx_isp, isp.stage_nmb);
        prsg_excel.cell_value_write(cell_isp_6, 0, idx_isp, isp.stage_sumtax);
        prsg_excel.cell_value_write(cell_isp_7, 0, idx_isp, isp.begin_date);
        prsg_excel.cell_value_write(cell_isp_8, 0, idx_isp, isp.end_date);
        prsg_excel.cell_value_write(cell_isp_9, 0, idx_isp, isp.fact_close_date);
      
        prsg_excel.cell_value_write(cell_isp_16, 0, idx_isp, dg.sotr);
      

        prsg_excel.cell_value_write(CELL_ISP_D2, 0, idx_isp, dg.zr);
        prsg_excel.cell_value_write(CELL_ISP_D3, 0, idx_isp, dg.agent);
        prsg_excel.cell_value_write(CELL_ISP_D4, 0, idx_isp, dg.ext_number || ' от ' || dg.dd);
        prsg_excel.cell_value_write(CELL_ISP_D5, 0, idx_isp, dg.dd);
        prsg_excel.cell_value_write(CELL_ISP_D6
                                   ,0
                                   ,idx_isp
                                   ,dg.subject || case when dg.name_usl is not null then ' (' || dg.name_usl || ')' else '' end);
      
        v_i6 := v_i6 + isp.stage_sumtax;
      
        /* Платежи соисполнителям*/
      
        v_isp_pay_av := 0;
        v_isp_pay_ok := 0;
      
        for ispay in (select case vp.gsmpayments_mnemo
                               when 'ПредоплатаБезнал' then
                                0 --- Аванс
                               else
                                1 -- окончательный расчет
                             end is_fin_opl
                            ,-sum(pn.pay_sum * (1 - 2 * op.typoper_direct)) pay_sum -- C обратным знаком
                            ,to_char(max(pn.pay_date), 'DD.MM.YYYY') pay_date
                        from paynotes pn
                        left join azsgsmpaymentstypes vp
                          on vp.rn = pn.pay_type
                        join dictoper op
                          on op.rn = pn.finoper
                      
                       where pn.faceacc = isp.faceacc
                         and pn.signplan = 0
                      
                       group by case vp.gsmpayments_mnemo
                                  when 'ПредоплатаБезнал' then
                                   0 --- Аванс
                                  else
                                   1 -- окончательный расчет
                                end)
        loop
        
          if ispay.is_fin_opl = 0
          then
            /* Это аванс */
            prsg_excel.cell_value_write(cell_isp_10, 0, idx_isp, ispay.pay_sum);
            prsg_excel.cell_value_write(cell_isp_11, 0, idx_isp, ispay.pay_date);
            v_isp_pay_av := v_isp_pay_av + ispay.pay_sum;
          else
            prsg_excel.cell_value_write(cell_isp_13, 0, idx_isp, ispay.pay_date); -- Последняя дата окончат расчета
            v_isp_pay_ok := v_isp_pay_ok + ispay.pay_sum;
          end if;
        
        end loop;
        prsg_excel.cell_value_write(cell_isp_12, 0, idx_isp, v_isp_pay_av + v_isp_pay_ok);
      
        v_i10 := v_i10 + v_isp_pay_av;
        v_i12 := v_i12 + v_isp_pay_av + v_isp_pay_ok;
      
      end loop; --- Соисполнители                
    
    end loop; --- Конец этапа
  
    prsg_excel.cell_value_write(cell_d18, 0, idx_dg, v_18_itg);
    prsg_excel.cell_value_write(cell_d19, 0, idx_dg, v_19_itg);
    prsg_excel.cell_value_write(cell_d21, 0, idx_dg, v_21_itg);
    prsg_excel.cell_value_write(cell_d_i6, 0, idx_dg, v_i6);
    prsg_excel.cell_value_write(cell_d_i10, 0, idx_dg, v_i10);
    prsg_excel.cell_value_write(cell_d_i12, 0, idx_dg, v_i12);
  
---    idx_b := prsg_excel.line_continue(sline_name => line_b);  /*Не хотят жирную строку, неудобно фильтр накладывать */
  end loop;

  prsg_excel.line_delete(line_1);
  prsg_excel.line_delete(line_b);
  prsg_excel.line_delete(line_dg);
  prsg_excel.line_delete(line_isp);
  prsg_excel.line_delete(line_isp_sp);

end;
/
