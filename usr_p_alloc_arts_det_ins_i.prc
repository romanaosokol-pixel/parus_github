create or replace procedure usr_p_alloc_arts_det_ins_i(nrn               in number /* Идентификатор докуменита, на котором вызвано действие */
                                                      ,nprn              in usr_t_alloc_arts_v.rn%type
                                                      ,unitcode          in unitlist.unitcode%type
                                                      ,dep_code          out ins_department.code%type
                                                      ,speriod_code      out enperiod.code%type
                                                      ,sbudg_code        out udo_t_finplan.fp_code%type
                                                      ,sbudg_rn          out udo_t_finplan.rn%type
                                                      ,sbudg_art_code    out udo_t_finplan_arts.code%type
                                                      ,sfaceacc_cost_nmb in out faceacc.numb%type /* --> USR_T_ALLOC_ARTS.FACEACC_COST */
                                                      ,finplan_arts      out udo_t_finplan_arts.rn%type
                                                       -- ,ALLOC_ART_RN          out USR_T_ALLOC_ARTS.rn%type
                                                      ,proj_code             out project.code%type
                                                      ,proj_rn               out project.rn%type
                                                      ,sproject_stage_fc     out faceacc.numb%type /*--> projectstage.faceacc */
                                                      ,dep_code_enb          out number
                                                      ,speriod_code_enb      out number
                                                      ,sbudg_code_enb        out number
                                                      ,sbudg_rn_end          out number
                                                      ,sbudg_art_code_enb    out number
                                                      ,sfaceacc_cost_nmb_enb out number
                                                      ,finplan_arts_enb      out number
                                                      ,serr_txt              out varchar2
                                                      ,is_ok                 out number) is
  /*
  
   Городецкий 2026-04-13
   Процедура Валидатор INI для действия Добавить а разделе "Бюджетное распределение (Статьи Детализация)"
  
  */
begin
  serr_txt := '';

  case unitcode
    when 'BUDGET_ALLOCATION_SP_DET' then
      select dep.code
            ,per.code
            ,bj.rn
            ,bj.fp_code
            ,bjs.code
            ,fa.numb
            ,bjs.rn
      ---    ,brs.rn
        into dep_code
            ,speriod_code
            ,sbudg_rn
            ,sbudg_code
            ,sbudg_art_code
            ,sfaceacc_cost_nmb
            ,finplan_arts
      --   ,ALLOC_ART_RN  /* RN статьи бюджетного распределения, в данном случае = nPRN */
        from usr_t_alloc_arts brs
        join udo_t_finplan_arts bjs
          on bjs.rn = brs.finplan_arts
        join udo_t_finplan bj
          on bj.rn = bjs.prn
        join enperiod per
          on per.rn = bj.fp_period
        join ins_department dep
          on dep.rn = bj.depord
        join faceacc fa
          on fa.rn = brs.faceacc_cost
       where brs.rn = nprn;
      dep_code_enb          := 0;
      speriod_code_enb      := 0;
      sbudg_art_code_enb    := 0;
      sfaceacc_cost_nmb_enb := 0;
      finplan_arts_enb      := 0;
      sbudg_code_enb        := 0;
      sbudg_rn_end          := 0;
    else
      dep_code_enb          := 1;
      speriod_code_enb      := 1;
      sbudg_art_code_enb    := 1;
      sfaceacc_cost_nmb_enb := 1;
      finplan_arts_enb      := 1;
      sbudg_code_enb        := 1;
      sbudg_rn_end          := 1;
  end case;

  is_ok := 0; /* При открыти ни лицевой счет ни лицевой счет этапа проекта не заполнены, поэтому кнопка ОК недоступна !*/

end;
/
