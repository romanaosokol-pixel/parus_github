create or replace procedure usr_p_docs_props_vals_get_dat
/*
Процедура получения значения датского свойства документа
create public synonym usr_p_docs_props_vals_get_dat for usr_p_docs_props_vals_get_dat;
grant execute on usr_p_docs_props_vals_get_dat to public;
*/
(
 nDOC_PROP in number
,nDOCUMENT in number
,dVAL      out date
)
as
  sVal docs_props_vals.str_value%type;
  nVal docs_props_vals.num_value%type;
  /*dVal docs_props_vals.date_value%type;*/
begin
  usr_pkg_docs_props_vals.get_val(ndoc_prop => nDOC_PROP
                                 ,ndocument => nDOCUMENT
                                 ,sval      => sVal
                                 ,nval      => nVal
                                 ,dval      => dVAL);
end;
/
