create or replace procedure USR_P_BUDGET_ALLOC_BASE_DEL(nrn in number) is
begin

delete USR_T_BUDGET_ALLOCATION where rn = nrn;

end;
/
