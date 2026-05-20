create or replace procedure usr_p_shpz_get_get(ncompany          in number default 90521
                                              ,nfaceacc          in stages.rn%type /*RN Лицевого счета этапа договора  */
                                              ,nalloc_art_rn     in faceacc.rn%type /*Подстатья - RN Лицевого счета, номер которого является номером подстатьи */
                                              ,out_sfaceacc_shpz out faceacc.numb%type /* Номер лицевого счета эапа проекта */) is

  /* Поиск лицевого счета этапа проекта (ШПЗ) для куалькуляции 
  Городецкий 2026-02-20
  */

begin

  /* 1 ШПЗ привязан Подстатье */
  begin
    select brd.faceacc_cost_nmb
      into out_sfaceacc_shpz
      from usr_t_alloc_arts_det brd
     where brd.prn = nalloc_art_rn;
  
  exception
    when no_data_found then
      return;
    when too_many_rows then
      return;
    
      if out_sfaceacc_shpz is null
      then
      
        /* 2. Берем Лицевой счет (заказ) из этапа проекта,  либо лицевой счет задан в одной из строк "Исполнители этапа" проекта*/
      
        out_sfaceacc_shpz := usr_f_stages_sgpz(nfaceacc => nfaceacc);
      
      end if;
    
  end;

end;
/
