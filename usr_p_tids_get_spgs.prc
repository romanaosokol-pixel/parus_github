create or replace procedure USR_P_TIDS_GET_SPGS
/*
Раздел: Расходные накладные на отпуск в подразделения (спецификация)
Процедура для получения мест хранения по спецификации. Предназначена для использования в окне просмотра.
*/
(
 nRN    in number
,sOUT   out varchar2
)
as
  rRow    transinvdeptspecs%rowtype;
  rHead   transinvdept%rowtype;
begin
  /* Считывание */
  rRow  := usr_pkg_transinvdept.transinvdeptspecs_get(nrn => nRN);
  rHead := usr_pkg_transinvdept.transinvdept_get(nrn => rRow.prn);
  /* Расчёт */
  for c in (
            select a.quant, udo_f_stplcells_sfullcell(ncompany => a.company, nrn => a.cell) as scell
              from stplgoodssupply a
                  ,stplcells       b
                  ,goodssupply     gs
             where a.cell        = b.rn
               and a.quant      != 0
               and a.goodssupply = gs.rn
               and gs.prn        = rRow.goodsparty
               and gs.store      = rHead.store
             )
  loop
    sOUT := STRCOMBINE(sOUT, 'Место: '||c.scell||', количество: '||trim(n2sq(c.quant)), cr); 
  end loop;
end USR_P_TIDS_GET_SPGS;
/
