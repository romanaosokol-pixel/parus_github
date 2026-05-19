create or replace function usr_f_prst_sht_producttype_get(NNOMEN_RN in DICNOMNS.RN%type) return varchar2 is

begin
  /* Вывод значения свойства PrProductType "Тип продукции" номенклатуры ведомости производства этапа проета*/

return usr_pkg_docs_props_vals.get_val_str(nDOC_PROP => 219295664, sunitcode => 'Nomenclator', nDOCUMENT => NNOMEN_RN);

end;
/
