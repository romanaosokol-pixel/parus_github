create or replace procedure usr_p_iivs_update
/*
Приходные накладные (спецификация). Исправить
05/12/2025 Степанов М.
*/
(
 nRN              in number
,sNOMEN           in varchar2
,sMODIF           in varchar2
,sTAXGR           in varchar2
,nQUANT           in number
,nPRICE           in number
,nNSUMM           in number
,nNSUMM_NDS       in number
,nSUMMTAX         in number
,nRECALC_SUMMS    in number
,sORIGINAL_NAME   in varchar2
,sNOTE            in varchar2
,nOUT_DOC_UPDATE  in number  /* Исправлять выходные документы (приходный ордер, сертификация): 0 - нет , 1 - да  */
)
is
  rRow              ininvoicesspecs%rowtype;
  rInInvoices       ininvoices%rowtype;
  nNomen            pkg_std.tref;  
  nModif            pkg_std.tref;  
  nTaxGr            pkg_std.tref;  
  bExistsAllRights  boolean := false;
  
  nNumber           pkg_std.tnumber; 
begin
  /* Открытие процесса */
  usr_pkg_process.process_open(sname => 'USR_P_IIVS_UPDATE');

  /* СЧИТЫВАНИЕ */
  rRow        := usr_pkg_ininvoices.ininvoicesspecs_get( nrn => nRN );
  rInInvoices := usr_pkg_ininvoices.ininvoices_get( nrn => rRow.prn );
  /* Наличие у пользователя роли 'Все права' */
  for c in ( select null from userroles where authid = utilizer and roleid = 90519 )
  loop
    bExistsAllRights := true;
    exit;
  end loop;
  /* Определение RN для входных переменных */
  /* Номенклатура */
  if sNOMEN is not null then
    find_dicnomns_by_code( nflag_smart => 0, ncompany => rRow.company, snomen_code => sNOMEN, nrn => nNomen );
  end if;                       
  /* Модификация */
  if sMODIF is not null then
    find_nommodif_by_code(nprn => nNomen, scode => sMODIF, nfrn => nModif);
  end if;                       
  /* Налоговая группа */
  if sTAXGR is not null then
    find_dictaxgr_code(nflag_smart => 0, ncompany => rRow.company, scode => sTAXGR, nrn => nTaxGr); 
  end if;                       

  /* ПРОВЕРКИ */
  /* Если исправляется номенклатура, модификация, количество */
  if sNOMEN||sMODIF||nQUANT is not null then
    /* Нет роли Все права */
    if not bExistsAllRights then
      p_exception(0, 'У вас нет прав для исправления номенклатуры, модификации, количества.'); 
    end if;
    /* Проверка выходных документов */
    usr_pkg_ininvoices.ininvoicesspecs_check_out_docs( rrow => rRow );
  end if;

  /* Если исправлять выходные документы */
  /*if cmp_num( nOUT_DOC_UPDATE, 1 ) = 1 then
    \* Нет роли Все права *\
    if not bExistsAllRights then
      p_exception(0, 'У вас нет прав для исправления выходных документов.'); 
    end if;
  end if;*/

  /* Если исправляется суммы или цена */
  if nPRICE||nNSUMM||nSUMMTAX||nNSUMM_NDS is not null then
    /* Устанавливаем фалаг для обхода проверок */
    pkg_flag.set_flag;
    /* Если исправление больше 5 копеек и нет роли Все права */
    if (  abs( nPRICE     - rRow.price    ) > 2
       or abs( nNSUMM     - rRow.summ     ) > 2
       or abs( nSUMMTAX   - rRow.summtax  ) > 2
       or abs( nNSUMM_NDS - rRow.summ_nds ) > 2 ) 
    and not bExistsAllRights then
      p_exception(0, 'Разрешено исправлять суммы только в пределах 5 копеек.'); 
    end if;
    /* Если Пересчитывать суммы и заданы другие суммы кроме "с НДС" */
    if cmp_num( nRECALC_SUMMS, 1 ) = 1 and nPRICE||nNSUMM||nNSUMM_NDS is not null then
      p_exception(0, 'Установлен признак пересчитывать суммы. В этом случае разрешено заполнять только Сумма с НДС.'); 
    end if;
  end if;

  /* Заполнение переменных */
  rRow.nomen         := nvl( nNomen        , rRow.nomen );
  rRow.modif         := nvl( nModif        , rRow.modif );
  rRow.taxgr         := nvl( nTaxGr        , rRow.taxgr );
  rRow.quant         := nvl( nQUANT        , rRow.quant );
  rRow.price         := nvl( nPRICE        , rRow.price );
  rRow.summ          := nvl( nNSUMM        , rRow.summ );
  rRow.summtax       := nvl( nSUMMTAX      , rRow.summtax );
  rRow.summ_nds      := nvl( nNSUMM_NDS    , rRow.summ_nds );
  rRow.original_name := nvl( sORIGINAL_NAME, rRow.original_name );
  rRow.note          := nvl( sNOTE         , rRow.note );

  /* Если Пересчитывать суммы  */
  if cmp_num ( nRECALC_SUMMS, 1 ) = 1 then
    usr_pkg_dictaxgr.dictaxis_calc_base( nflagsmart   => 0
                                        ,ncompany     => rRow.company
                                        ,ddate        => rInInvoices.doc_date
                                        ,ntaxgr       => rRow.taxgr
                                        ,ninsumm      => rRow.summtax
                                        ,nquant       => 1
                                        ,nsumm        => rRow.summ
                                        ,nsummwithnds => rRow.summtax
                                        ,nsumm_nds    => rRow.summ_nds
                                        ,nprice       => rRow.price );
  end if;

  /* Исправление */
  /*usr_pkg_ininvoices.ininvoicesspecs_bupdate( nrn => rRow.rn, ncompany => rRow.company );*/
  usr_pkg_ininvoices.ininvoicesspecs_base_update( rrow                => rRow
                                                 ,nsumm_ininvoices    => nNumber
                                                 ,nsummtax_ininvoices => nNumber
                                                 ,nout_doc_update     => nOUT_DOC_UPDATE
                                                 ,nmode               => 1 );
  /*usr_pkg_ininvoices.ininvoicesspecs_aupdate( nrn => rRow.rn, ncompany => rRow.company );*/

  /* Удаляем фалаг */
  pkg_flag.reset_flag;


  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;

end;
/
