create or replace procedure usr_p_ininvoices_chg_ini
(
  nrn          in ininvoices.rn%type
 ,out_doc_date out ininvoices.doc_date%type
) is

begin
  begin
    select nk.doc_date into out_doc_date from ininvoices nk where nk.rn = nrn;  
  exception
    when no_data_found then
      p_exception(0
                 ,'Процедура должна запускаться на одной отмеченной накладной!');
  end;

end;
/
