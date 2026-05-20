create or replace procedure USR_P_IOSB_SIGNTAX_UPDATE
/*
Приходные ордера (буфер). Спецификация. Исправить признак "Цены включают налоги" на правильные значения
08/04/2022 Степанов М.
*/
(
 nRN          in number
)
is
begin
  USR_PKG_INORDERS.INORDSPBUFF_UPDATE_PCR(nFLAGSMART => 1, NRN => nRN, nPRICE_CALC_RULE => 1);
end USR_P_IOSB_SIGNTAX_UPDATE;
/
