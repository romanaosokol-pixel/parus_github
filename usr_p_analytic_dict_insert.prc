create or replace procedure usr_p_analytic_dict_insert(ncompany in number
                                                      ,ncrn     in number
                                                      ,scode    in varchar2
                                                      ,sname    in varchar2                                                     
                                                      ,nrn      out varchar2) is


begin

  /*ntype := case stype
             when 'число' then
              1
             when 'строка' then
              2
             when 'дата' then
              3
             else
              0
           end;*/

  usr_p_analytic_dict_base_ins(ncompany => ncompany, ncrn => ncrn, scode => scode, sname => sname,  nrn => nrn);

end;
/
