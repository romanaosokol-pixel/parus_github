create or replace procedure usr_p_matres_num_base_insert
(
  ncompany in number
 ,ncrn     in number
 ,snote    in varchar2
 ,nrn      out number
) is

  nnmb usr_tab_matres_numeration.nmb_gr%type;

begin

  nrn := gen_id;

  select nvl(max(t.nmb_gr)
            ,0) + 1
    into nnmb
    from usr_tab_matres_numeration t
   where t.company = ncompany;

  insert into usr_tab_matres_numeration
    (rn
    ,company
    ,crn
    ,nmb_gr
    ,note)
  values
    (nrn
    ,ncompany
    ,ncrn
    ,nnmb
    ,snote);

end;
/
