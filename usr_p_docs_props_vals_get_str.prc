create or replace procedure usr_p_docs_props_vals_get_str
/*
Процедура получения значения строкового свойства документа
create public synonym usr_p_docs_props_vals_get_str for usr_p_docs_props_vals_get_str;
grant execute on usr_p_docs_props_vals_get_str to public;
*/
(
 nDOC_PROP in number
,nDOCUMENT in number
,sVAL      out varchar2
)
as
  /*sVal docs_props_vals.str_value%type;*/
  nVal docs_props_vals.num_value%type;
  dVal docs_props_vals.date_value%type;
begin
  usr_pkg_docs_props_vals.get_val(ndoc_prop => nDOC_PROP
                                 ,ndocument => nDOCUMENT
                                 ,sval      => sVAL
                                 ,nval      => nVal
                                 ,dval      => dVal);
end;
/
