create or replace procedure usr_p_budget_alloc_status_i(nrn     in number
                                                       ,sstatus out varchar2) is

begin
  /*Статус Бюджетного распределения */
  begin
    with s as
     (select t.note
            ,t.num_value
        from extra_dicts_values t
       where t.prn = 245549878)
    select s.note into sstatus from usr_t_budget_allocation br join s on s.num_value = br.status where br.rn = nrn;
  exception
    when no_data_found then
      select t.note
        into sstatus
        from extra_dicts_values t
       where t.prn = 245549878
         and t.num_value = 0;
    
  end;

end;
/
