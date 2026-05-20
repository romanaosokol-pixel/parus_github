create or replace procedure USR_P_BR_SET_STATUS_INI(nrn in number, sstatus out varchar2) is

begin

with st as
 (select t.note
        ,t.num_value 
    from extra_dicts_values t
   where t.prn = 245549878)

select 'st.note' 
  into sstatus 
  from usr_t_budget_allocation br 
  join st on st.num_value = br.status 
  where br.rn = nrn;

---sstatus:='';

end;
/
