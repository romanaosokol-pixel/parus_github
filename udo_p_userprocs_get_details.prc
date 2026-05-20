create or replace procedure udo_p_userprocs_get_details
/*
14/08/2023 Степанов М.
Процедура отображения информации о пользовательской процедуре
*/
(
 NRN    in number
,SOUT   out varchar2
) 
as
  rUserProcs    userprocs%rowtype;
begin
  select * into rUserProcs from userprocs where rn = NRN;
  SOUT := 'Текст блока: ' ||cr|| trim(rUserProcs.blocktext);

  for c in (
            select ul.unitname, uf.name, decode(upla.do_before, 1 , 'До') as sbefore, decode(upla.do_after, 1 , 'После') as safter
              from userprocslinks upl
                  ,userprocslinksactions upla
                  ,unitlist ul
                  ,unitfunc uf
             where upl.prn = rUserProcs.rn
               and upla.prn = upl.rn
               and upl.unitcode = ul.unitcode
               and upla.unitfunc = uf.code
           )
  loop
    SOUT := SOUT||cr||'Раздел:    ' || c.unitname
                ||cr||'Действие:  ' || c.name
                ||cr||'Выполнять: ' || strcombine( c.sbefore, c.safter, '/');
  end loop;
end;
/
