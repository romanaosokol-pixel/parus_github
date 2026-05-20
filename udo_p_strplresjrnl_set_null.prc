create or replace procedure UDO_P_STRPLRESJRNL_SET_NULL(nIDENT in number) is

/* Временная для отработки склада. */
begin
for  dd in ( select st.rn
  from SELECTLIST sl
     , STRPLRESJRNL  st
  where st.rn = sl.document
  and sl.ident = nIDENT
  ) loop
  update  STRPLRESJRNL tt set tt.quant = 0 where tt.rn = dd.rn;
  end loop;
    
end UDO_P_STRPLRESJRNL_SET_NULL;
/

