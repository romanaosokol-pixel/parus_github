create or replace procedure USR_P_GP_INSERT_PAS
/*
Приходные партии товара
Добавить в счёт на оплату
03/04/2024 Степанов М.
*/
(
 nRN            in number
,nPAYACC        in number
,sTAXGR         in varchar2
,sVERIFICATION  in varchar2 /* Подлежит поверке */
)
is
  nRN2            pkg_std.tref := nRN;
  rV_Row          v_goodsparties%rowtype;
  rV_payaccspecs  v_payaccspecs%rowtype;
  nPayaccSpecs    pkg_std.tref; 

  nNumber   pkg_std.tnumber;
  dDate     date;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_GP_INSERT_PAS');

  /* Считывание текущей записи */
  begin
    select * into rV_Row from v_goodsparties where nrn = nRN2;
  exception
    when no_data_found then
      pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'GOODSPARTIES');
    when others then
      p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                 ,NRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'GOODSPARTIES')));
  end;

  /* Заполнение переменных */
  rV_payaccspecs.ncompany         := rV_Row.ncompany;
  rV_payaccspecs.nprn             := nPAYACC;
  rV_payaccspecs.staxgr           := sTAXGR;
  rV_payaccspecs.snomen           := rV_Row.snomen;
  rV_payaccspecs.snommodif        := rV_Row.snommodif;
  rV_payaccspecs.ssernumb         := rV_Row.ssernumb;
  rV_payaccspecs.scountry         := rV_Row.scountry;
  rV_payaccspecs.sgtd             := rV_Row.sgtd; 
  rV_payaccspecs.sgoodsparty      := rV_Row.scode;
  rV_payaccspecs.nprice           := 0;
  rV_payaccspecs.ndiscount        := 0;
  rV_payaccspecs.nquant           := 0;
  rV_payaccspecs.nquantalt        := 0;
  rV_payaccspecs.ncoeff           := 0;
  rV_payaccspecs.ncoeff_val_sign  := 0;
  rV_payaccspecs.ncoeff_calc_sign := 0;
  rV_payaccspecs.npricemeas       := 0;
  rV_payaccspecs.nsumm            := 0;
  rV_payaccspecs.nsummwithnds     := 0;
  rV_payaccspecs.nsumm_nds        := 0;
  rV_payaccspecs.nautocalc_sign   := 0;

  /* Добавление спецификации счёта на оплату */
  usr_pkg_payacc.payaccspecs_insert(rv_row => rV_payaccspecs, nrn => nPayaccSpecs);
  
  /* Свойство Подлежит поверке */
  pkg_docs_props_vals.modify(nproperty   => 122611206
                            ,sunitcode   => 'PaymentAccountsSpecs'
                            ,ndocument   => nPayaccSpecs
                            ,sstr_value  => sVERIFICATION
                            ,nnum_value  => nNumber
                            ,ddate_value => dDate
                            ,nrn         => nNumber);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_GP_INSERT_PAS;
/
