create or replace procedure udo_pp_transspec_upd is
nIDENT pkg_std.tref;
nTMP pkg_std.tref;
nIDENT2 pkg_std.tref;


begin
p_exception(0, 'Процедура редактируется.');
  P_SELECTLIST_GENIDENT (nIDENT);
  for cc in (
    select ex.prn, 
           trim(pl.numb) as snumb,
           trs.prn as ntrs_prn,
           pl.company
      from UDO_T_TRANSINVCUSTSPECS_EX ex, FCACOPERPLANS pl, TRANSINVCUSTSPECS trs
     where pl.rn = ex.fcacoperplans
       and trs.rn = ex.prn
       --and pl.rn = 115480499 ???
  ) loop
      P_SELECTLIST_INSERT
      (
        nIDENT            => nIDENT,         -- идентификатор процесса
        nDOCUMENT         => cc.prn,         -- документ 0
        sUNITCODE         => 'GoodsTransInvoicesToConsumersSpecs',       -- код раздела документа 0
        nRN               => nTMP          -- регистрационный номер записи
      );
/* 20/02/2026 Степанов М. Закомментировал, т.к. переделал эту процедуру
      begin
        UDO_P_TRANSINVCUSTSP_SETLINK(nIDENT   => nIDENT,
                                     nCOMPANY => cc.company,
                                     snumb    => cc.snumb, -- line NPP
                                     nparam   => null);

      exception when others then
        null;
      end;
*/
      
      P_SELECTLIST_CLEAR
      (
        nIDENT 
      );
  end loop;
  
  for cc in ( 
    select distinct trs.prn as ntrs_prn
    from UDO_T_TRANSINVCUSTSPECS_EX ex, FCACOPERPLANS pl, TRANSINVCUSTSPECS trs
    where pl.rn = ex.fcacoperplans
    and trs.rn = ex.prn
       and pl.rn = 115480499
  ) loop
    udo_p_trancost_set_prise (cc.ntrs_prn);
  end loop;  

end udo_pp_transspec_upd;
/
