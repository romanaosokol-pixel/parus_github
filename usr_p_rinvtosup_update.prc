create or replace procedure USR_P_RINVTOSUP_UPDATE
/*
Расходные накладные на возврат поставщикам. Заголовок. Исправление
09/02/2024 Степанов М.
*/
(
 nRN            in number
,sDOCTYPE       in varchar2
,sPREF          in varchar2
,sNUMB          in varchar2
,dDATE          in date
/*,sFACEACC       in varchar2 */
,sSTOREOPER     in varchar2
,sSTORE         in varchar2
,sMOL           in varchar2
,sINCOMDOC      in varchar2
,sNOTE          in varchar2
)
is
  rV_Row            v_rinvtosup%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_RINVTOSUP_UPDATE');

  /* Считывание текущей записи */
  select * into rV_Row from v_rinvtosup where nrn = usr_p_rinvtosup_update.nrn;
  
  /* Подмена переменных */
  rV_Row.sdoctype   := sDOCTYPE;
  rV_Row.spref      := sPREF;
  rV_Row.snumb      := sNUMB;
  rV_Row.ddocdate   := dDATE;
/*  rV_Row.sfaceacc   := sFACEACC;*/
  rV_Row.sstoreoper := sSTOREOPER;
  rV_Row.sstore     := sSTORE;
  rV_Row.smol       := sMOL;
  rV_Row.sparty     := sINCOMDOC;
  rV_Row.snote      := sNOTE;
  
  /* Исправление */
  usr_pkg_rinvtosup.rinvtosup_update(rv_row => rV_Row, nmode => 0);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_RINVTOSUP_UPDATE;
/
