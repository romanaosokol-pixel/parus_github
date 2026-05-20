create or replace procedure usr_p_calc_one_subitems_get(finplan_arts_rn    in udo_t_finplan.rn%type
                                                       ,o_salloc_art_nmb   out varchar2
                                                       ,o_allocation_sp_rn out number
                                                       ,o_salloc_art_lic   out varchar2
                                                       ,o_SALLOC_ART_RN    out number
                                                       ,o_err_txt          out varchar2) is

  /* Если подстатья у статьи единственная, то вернем ее */
begin
  begin
    select brs.art_numb
          ,brs.rn
          ,f.numb
          ,brs.faceacc_cost
      into o_salloc_art_nmb
          ,o_allocation_sp_rn
          ,o_salloc_art_lic
          ,o_SALLOC_ART_RN
      from usr_t_alloc_arts brs
      join faceacc f
        on f.rn = brs.faceacc_cost
     where brs.finplan_arts = finplan_arts_rn;
  
  exception
    when no_data_found then
      o_err_txt := 'Подстатья не найдена!';
    when too_many_rows then
      o_err_txt := 'Выберите подстатью';
  end;

  ---if user = 'GOR' then P_exception(0, finplan_rn||' '||o_salloc_art_nmb||' '||o_err_txt); end if;

end;
/
