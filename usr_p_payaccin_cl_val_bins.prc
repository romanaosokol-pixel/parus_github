create or replace procedure usr_p_payaccin_cl_val_bins(ncompany  in number
                                                      ,nprn      in number
                                                      ,nalloc_rn in number
                                                      ,nlimit    in number
                                                      ,ncost     in number
                                                      ,nrn       out number) is

  

begin

  /* Базовая процедура добавления бюджетирования по счету */
  
  nrn := gen_id_fix;

  insert into usr_tab_payaccin_cl_val
    (rn
    ,company
    ,prn
    ,alloc_rn
    ,limit
    ,cost
    ,ddate
    ,suser)
  values
    (nrn
    ,ncompany
    ,nprn
    ,nalloc_rn
    ,nlimit
    ,ncost
    ,sysdate
    ,utilizer);

end;
/
