create or replace procedure usr_p_transinvdept_chg
(
  nrn          in number
 ,pin_doc_date in date
) is
begin

  update transinvdept t set t.docdate = pin_doc_date where t.rn = nrn;

end;
/
