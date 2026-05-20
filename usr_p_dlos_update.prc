create or replace procedure USR_P_DLOS_UPDATE
/*
Заказ поставщику. Спецификация. Исправление
Если значение какого-либо параметра не задано, то используется текущее значение
07/03/2025 Степанов М.
create public synonym usr_p_dlos_update for usr_p_dlos_update;
*/
(
 nRN              in number
,sTAXGR           in varchar2
,sCOMMENTS        in varchar2
,nSUMMWITHNDS     in number
)
is
  nRN2                  pkg_std.tref := nRN;
  rV_Row                v_deliveryords%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_DLOS_UPDATE');

  /* Считывание текущей записи */
  select * into rV_Row from v_deliveryords where nrn = nRN2;

  /* Подстановка значений */
  rV_Row.stax_group := nvl( sTAXGR      , rV_Row.stax_group );
  rV_Row.snote      := nvl( sCOMMENTS   , rV_Row.snote );
  rV_Row.nsumwtax   := nvl( nSUMMWITHNDS, rV_Row.nsumwtax );

  /* Если заданы параметры, которые могут инициировать пересчёт сумм */
  if nSUMMWITHNDS is not null or sTAXGR is not null then
    pkg_dictaxis_calc.p_calculate(nflag_smart => 0
                                 ,ncompany    => rV_Row.ncompany
                                 ,ddate       => sysdate
                                 ,nsumm_sign  => 1 /* всегда с налогами */
                                 ,ninsumm     => rV_Row.nsumwtax
                                 ,staxgr      => rV_Row.stax_group
                                 ,nquant      => 1
                                 ,nncp_sign   => 1);
  
    rV_Row.nsumwotax     := pkg_dictaxis_calc.f_get_value(nident => 0); /* Сумма без налогов       (0) */
    rV_Row.nsumwtax      := pkg_dictaxis_calc.f_get_value(nident => 2); /* Сумма со всеми налогами (2) */
    rV_Row.nexp_price    := rV_Row.nsumwtax / case rV_Row.nmain_quant when 0 then 1 else rV_Row.nmain_quant end;

    rV_Row.nactswtax     := rV_Row.nsumwtax;
    rV_Row.nactswotax    := rV_Row.nsumwotax;
    rV_Row.ncustswtax    := rV_Row.nsumwtax;
    rV_Row.ncustswotax   := rV_Row.nsumwotax;
  end if;

  /* исправление */
  usr_pkg_deliveryord.deliveryords_update( rv_row => rV_Row, nmode => 1 );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end USR_P_DLOS_UPDATE;
/
