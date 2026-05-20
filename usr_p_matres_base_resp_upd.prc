create or replace procedure usr_p_matres_base_resp_upd(nrn            in number
                                                      ,nresponse_type in extra_dicts_values.rn%type /*“ип ответсвенного */
                                                      ,nresponse_agn  in agnlist.rn%type /* —сылка на контрагента ответсвенного */
                                                      ,ddate_beg      in date
                                                      ,ddate_end      in date
                                                      ,snote          in varchar2) is

begin

  update usr_tab_matres_response t
     set t.response_type = nresponse_type
        ,t.response_agn  = nresponse_agn
        ,t.date_beg      = ddate_beg
        ,t.date_end      = ddate_end
        ,t.note          = snote
   where rn = nrn;

end;
/
