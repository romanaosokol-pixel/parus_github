create or replace procedure usr_p_stage_modify_ini
(
  nrn      in stages.rn%type
 ,staxgr   out dictaxgr.code%type
 ,nsumm    out stages.stage_sumtax%type
 ,ddoc_beg out stages.begin_date%type
 ,ddoc_end out stages.end_date%type
 ,sdescr   out stages.description%type
 ,snote    out stages.comments%type
 ,scurr    out curnames.intcode%type
) is
begin
  begin
    select tg.code
          ,st.stage_sumtax
          ,st.begin_date
          ,st.end_date
          ,st.description
          ,st.comments
          ,vl.intcode
      into staxgr
          ,nsumm
          ,ddoc_beg
          ,ddoc_end
          ,sdescr
          ,snote
          ,scurr
      from stages st
      join dictaxgr tg
        on tg.rn = st.taxgr
      join faceacc f
        on f.rn = st.faceacc
      join curnames vl
        on vl.rn = f.currency
    
     where st.rn = nrn;
  exception
    when no_data_found then
      staxgr := null;
  end;
end;
/
