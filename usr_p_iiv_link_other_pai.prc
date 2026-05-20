create or replace procedure USR_P_IIV_LINK_OTHER_PAI
/*
Приходные накладные. Заголовок. Привязать к другому входящему счёту. Входным документом может быть как вх.счёт, так и заказ поставщикам
16/10/2023 Степанов М.
*/
(
 nCOMPANY     in number
,nRN          in number
,nPAYACCIN    in number
)
is
  bExistsAllRights  boolean := false;
  rInInvoices   ininvoices%rowtype;
  nInOrders   pkg_std.tref;

  nNumber     pkg_std.tnumber;
  sVarchar    pkg_std.tstring;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_IIV_LINK_OTHER_PAI');

  /* Проверка наличия роли Все права */
  for c in (select null from userroles where authid = utilizer and roleid = 90519)
  loop
    bExistsAllRights := true;
    exit;
  end loop;
  if not bExistsAllRights then
    p_exception(0, 'Нет прав.');
  end if;

  /* Считывание заголовка */
  rInInvoices := usr_pkg_ininvoices.ininvoices_get(nrn => nRN);

  /* Удалить связь приходной накладной с приходным ордером */
  for c in (select distinct t.*, rownum
              from doclinks t
             where t.in_document = rInInvoices.rn
               and t.out_unitcode = 'IncomingOrders')
  loop
    if c.rownum > 1 then
      p_exception(0, 'С накладной связанно по выходу больше одного приходного ордера.');
    end if;
    pkg_doclinks.remove(sin_unitcode  => c.in_unitcode
                       ,nin_document  => c.in_document
                       ,sout_unitcode => c.out_unitcode
                       ,nout_document => c.out_document);
    /* сохранение приходного ордера */
    nInOrders := c.out_document;
  end loop;

  /* Снять отработку с приходной накладной */
  p_ininvoices_bset_status(ncompany   => nCOMPANY
                          ,nrn        => rInInvoices.rn
                          ,nstatus    => 0
                          ,dwork_date => rInInvoices.work_date
                          ,nwarning   => nNumber
                          ,smsg       => sVarchar);

  /* Отвязать приходную накладную от вх.счёта */
  for c in (select distinct t.*, count(*)over() as ncount
              from doclinks t
             where t.out_document = rInInvoices.rn
               and t.in_unitcode  in ('PaymentAccountsIn', 'DeliveryOrders'))
  loop
    if c.ncount > 1 then
      p_exception(0, 'С накладной связанно по входу больше одного документа.');
    end if;
    pkg_doclinks.remove(sin_unitcode  => c.in_unitcode
                       ,nin_document  => c.in_document
                       ,sout_unitcode => c.out_unitcode
                       ,nout_document => c.out_document);
  end loop;

  /* Привязать приходную накладную к другому вх.счёту */
  pkg_doclinks.link(nflag_smart   => 0
                   ,ncompany      => nCOMPANY
                   ,sin_unitcode  => 'PaymentAccountsIn'
                   ,nin_document  => nPAYACCIN
                   ,sout_unitcode => 'IncomingInvoices'
                   ,nout_document => rInInvoices.rn);

  /* Отработать накладную */
  p_ininvoices_bset_status(ncompany   => ncompany
                          ,nrn        => rInInvoices.rn
                          ,nstatus    => 2
                          ,dwork_date => rInInvoices.work_date
                          ,nwarning   => nNumber
                          ,smsg       => sVarchar);

  /* Привязать отвязанный ранее приходный ордер */
  if nInOrders is not null then 
    pkg_doclinks.link(nflag_smart   => 0
                     ,ncompany      => ncompany
                     ,sin_unitcode  => 'IncomingInvoices'
                     ,nin_document  => rInInvoices.rn
                     ,sout_unitcode => 'IncomingOrders'
                     ,nout_document => nInOrders);
  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  

end USR_P_IIV_LINK_OTHER_PAI;
/
