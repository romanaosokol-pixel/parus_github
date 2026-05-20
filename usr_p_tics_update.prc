create or replace procedure USR_P_TICS_UPDATE
/*
Раздел: "Расходные накладные на отпуск потребителям (спецификация)"
Процедура: Исправить.
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
  usr_pkg_process.process_open( sname => 'USR_P_TICS_UPDATE' );

  usr_pkg_transinvcust.transinvcustspecs_update( nrn                => nRN
                                                ,STAXGR             => sTAXGR
                                                ,NSUMMWITHNDS       => nSUMMWITHNDS
                                                ,NGET_PRICE_FROM_FA => nGET_PRICE_FROM_FA
                                                ,NUPDATE_WORKED     => nUPDATE_WORKED );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end;
/
