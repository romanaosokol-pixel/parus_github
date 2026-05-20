create or replace procedure usr_p_stages_update_ini(nrn            in number
                                                   ,sdictaxgr      out varchar2
                                                   ,nstage_sum     out number
                                                   ,nstage_sumtax  out number
                                                   ,nstage_sum_nds out number) is
begin

  select gr.code
        ,st.stage_sum
        ,st.stage_sumtax
        ,st.stage_sum_nds
    into sdictaxgr
        ,nstage_sum
        ,nstage_sumtax
        ,nstage_sum_nds
    from stages st
    left join dictaxgr gr
      on gr.rn = st.taxgr
   where st.rn = nrn;

end;
/
