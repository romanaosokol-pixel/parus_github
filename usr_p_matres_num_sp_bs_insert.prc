create or replace procedure usr_p_matres_num_sp_bs_insert
(
  nprn     in number
 ,ncompany in number
 ,ncrn     in number
 ,nmatres  in number
 ,nmodif   in number
 ,snote    in varchar2
 ,nrn      out number
) is

begin

  nrn := gen_id;

  insert into usr_tab_matres_numeration_sp
    (rn
    ,prn
    ,company
    ,crn
    ,matres
    ,nommodif
    ,reg_date
    ,reg_user
    ,note)
  values
    (nrn
    ,nprn
    ,ncompany
    ,ncrn
    ,nmatres
    ,nmodif
    ,sysdate
    ,utilizer
    ,snote);

end;
/
