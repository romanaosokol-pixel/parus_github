create or replace procedure usr_p_transinvdept_ini
(
  nrn          in number
 ,out_doc_date out date
 ,is_ok        out number
) is
begin

  is_ok := 0;
  begin
    select trunc(t.docdate) into out_doc_date from transinvdept t where t.rn = nrn;
  exception
    when no_data_found then
      p_exception(0
                 ,'Процедура запускается только по одной расходной накладной на отпуск в подразделения. ');
    
  end;

end;
/
