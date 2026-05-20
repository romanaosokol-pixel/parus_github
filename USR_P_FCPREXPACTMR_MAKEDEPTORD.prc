create or replace procedure usr_p_fcprexpactmr_makedeptord
(
  ncompany        in number /*Регистрационный номер организации*/
 ,nident          in number /*-- Идентификатор процесса  (Это отмеченные позиции спецификации портебности)*/
 ,ddate           in date /* Дата формируемых заказов подразделений */
 ,ngrby_order     in number /*-- Группировать по заказу(ЛС) (0-все в одну, 1-делятся по заказам(ЛС))*/
 ,sspl_subdiv     in varchar2 /*-- Подразделение-поставщик*/
 ,ngrby_subdiv    in number /*-- Признак группировки по подразделение-поставщик*/
 ,ngrby_store     in number /*-- Признак группировки по складу отгрузки*/
 ,ngrby_subdiv_in in number /*-- Признак группировки по подразделению-получателю*/
 ,ngrby_store_in  in number /*-- Признак группировки по складу-получателю*/
 ,ngrby_nom_group in number /*-- Признак группировки по группе ТМЦ*/
 ,ngrby_period    in number /*-- Признак группировки по расчетному периоду*/
 ,ngrby_exec_date in number /*-- Признак группировки по дате поставки*/
 ,nshop_rest      in number /*-- Признак "За вычетом остатков на цеховых складах" (0 - нет, 1 - да)*/
 ,nsub_mtr        in number /*-- Замена материала ( 0 - только используемая замена, 1 - с учетом наличия на складах )*/
 ,nskip_action    in number /* -- Пропустить проверку права на действие ( 0 или null - нет, 1 - да )*/
 ,ddate_from      in date /*-- Период поставки с даты*/
 ,ddate_to        in date /*-- Период поставки до даты*/
 ,nreform_sign    in number /*-- Признак "Переформировать ранее созданные заказы"*/
 ,nshowerr        out number
 ,nidenterr       out number
) as
  nidentz       pkg_std.tlnumber := gen_ident;
  nrectypez     pkg_std.tlnumber := 0;
  smsg_text_yes pkg_std.tstring := 'Сформирован заказ подразделений.';
  smsg_text_no  pkg_std.tstring := 'Нет данных для формирования заказа подразделений.';
  nrnz          pkg_std.tlnumber;
  ntrue_rec     pkg_std.tlnumber;

  ndoc_ident selectlist.ident%type := gen_ident; -- Идент Потребности в которой отметили записи
  v_ndoc_rn  fcprexpact.rn%type; --- RN потребности 
  v_nrn      selectlist.rn%type;

begin

  /* 
  Формирование заказов подразделений 
  По отмеченным позициям спецификации потребности
  09-06-2025 Городецкий О.И.   
  */

  /* Найдем RN потребности */

  select sp.prn
    into v_ndoc_rn
    from selectlist sl
    join fcprexpactmr sp
      on sp.rn = sl.document
   where sl.ident = nident
     and sl.authid = utilizer
     and sl.unitcode = 'CostProductExpenseActsMatRes'
     and rownum = 1;

  /*Создаем Ident документа */

  p_selectlist_insert(nident => ndoc_ident, ndocument => v_ndoc_rn, sunitcode => 'CostProductExpenseActs', nrn => v_nrn);

  p_fcprexpact_makedeptord(ncompany        => ncompany
                          ,nident          => ndoc_ident
                          , --- Это идент документа
                           ddate           => ddate
                          ,ngrby_order     => ngrby_order
                          ,sspl_subdiv     => sspl_subdiv
                          ,ngrby_subdiv    => ngrby_subdiv
                          ,ngrby_store     => ngrby_store
                          ,ngrby_subdiv_in => ngrby_subdiv_in
                          ,ngrby_store_in  => ngrby_store_in
                          ,ngrby_nom_group => ngrby_nom_group
                          ,ngrby_period    => ngrby_period
                          ,ngrby_exec_date => ngrby_exec_date
                          ,nshop_rest      => nshop_rest
                          ,nsub_mtr        => nsub_mtr
                          ,nskip_action    => nskip_action
                          ,ddate_from      => ddate_from
                          ,ddate_to        => ddate_to
                          ,nreform_sign    => nreform_sign
                          ,ntrue_rec       => ntrue_rec
                          ,nspec_ident     => nident --- Это идент отмеченных позиций спецификации
                           );
  /*Очищаем Selectlist */
  p_selectlist_clear(nident => ndoc_ident);

  /* Если на выходе в параметре nTRUE_REC получили null или 0 то выводим сообщение об ошибке */
  if (ntrue_rec is null)
     or (ntrue_rec = 0)
  then
    nidenterr := nidentz;
    nshowerr  := 1;
    p_msgjournal_base_insert(nidentz, nrectypez, smsg_text_no, nrnz);
    /* Иначе выводим сообщение об успешном формировании заказа */
  else
    p_msgjournal_base_insert(nidentz, nrectypez, smsg_text_yes, nrnz);
    nshowerr := 0;
  end if;

end;
/
