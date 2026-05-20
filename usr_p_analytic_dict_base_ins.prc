create or replace procedure usr_p_analytic_dict_base_ins(ncompany in number
                                                        ,ncrn     in number
                                                        ,scode    in varchar2
                                                        ,sname    in varchar2                                                        
                                                        ,nrn      out number) is

  rec usr_tab_analytic_dict%rowtype; --Куда пишем

begin
  nrn         := gen_id;
  rec.rn      := nrn;
  rec.company := ncompany;
  rec.crn     := ncrn;
  rec.code    := scode;
  rec.name    := sname;
 

  insert into usr_tab_analytic_dict values rec;

end;
/
