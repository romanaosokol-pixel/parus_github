create or replace procedure USR_P_FAOOP_TICS_UPDATE
/*
Раздел: Лицевые счета (план расхода)
Процедура: Исправить спецификации расходных накладных потребителям.
14/10/2024 Степанов М.
*/
(
 nRN                  in number
,sTAXGR               in varchar2
,nSUMMWITHNDS         in number
,nGET_PRICE_FROM_FA   in number     /* Использовать цену из графика отпуска */
,nUPDATE_WORKED       in number     /* Исправлять отработанный документ */
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open( sname => 'USR_P_FAOOP_TICS_UPDATE' );

  for c in ( select ticsc.prn
               from fcacoperplans   faoop
               join fcacgraphpoints fgp   on fgp.rn = faoop.graphpoint
               join trinvcustclc    ticsc on ticsc.graphpoint = fgp.rn
              where faoop.rn = nRN )
  loop
    usr_pkg_transinvcust.transinvcustspecs_update( nrn                => c.prn
                                                  ,STAXGR             => sTAXGR
                                                  ,NSUMMWITHNDS       => nSUMMWITHNDS
                                                  ,NGET_PRICE_FROM_FA => nGET_PRICE_FROM_FA
                                                  ,NUPDATE_WORKED     => nUPDATE_WORKED );
  end loop;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end;
/
