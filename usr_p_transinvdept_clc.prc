create or replace procedure usr_p_transinvdept_clc
(
  nrn          in number
 ,pin_doc_date in date
 ,is_ok        out number
) is

  v_doc_date transinvdept.docdate%type;
begin

  begin
    select trunc(t.docdate) into v_doc_date from transinvdept t where t.rn = nrn;
  exception
    when no_data_found then
      p_exception(0
                 ,'Процедура запускается только по одной расходной накладной на отпуск в подразделения. ');
    
  end;

  if cmp_dat(v_doc_date
            ,pin_doc_date) = 1
  then
    is_ok := 0;
  else
    is_ok := 1;
  end if;

end;
/
