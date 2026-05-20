create or replace procedure usr_p_docs_props_vals_get_num
/*
Процедура получения значения числового свойства документа
create public synonym usr_p_docs_props_vals_get_num for usr_p_docs_props_vals_get_num;
grant execute on usr_p_docs_props_vals_get_num to public;
*/
(
 nDOC_PROP in number
,nDOCUMENT in number
,nVAL      out number
)
as
  sVal docs_props_vals.str_value%type;
  /*nVal docs_props_vals.num_value%type;*/
  dVal docs_props_vals.date_value%type;
begin
  usr_pkg_docs_props_vals.get_val(ndoc_prop => nDOC_PROP
                                 ,ndocument => nDOCUMENT
                                 ,sval      => sVal
                                 ,nval      => nVAL
                                 ,dval      => dVal);
end;
/
