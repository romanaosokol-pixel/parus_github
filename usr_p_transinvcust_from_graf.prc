create or replace procedure usr_p_transinvcust_from_graf
(
  pin_doc          in number /* := 158842227; -- RN Документа по которому формируем акт*/
 ,pin_com          in transinvcust.company%type /*:= 90521;*/
 ,pin_uni          in unitlist.unitcode%type /*Код раздела из которого вызвали*/
 ,pin_cat          in acatalog.name%type /* := 'Расходные накладные на отпуск потребителям';*/
 ,pin_jur          in jurpersons.code%type /*:= 'Модуль';*/
 ,pin_jur_agent    in agnlist.agnabbr%type /* Контрагент юр. лица, для выбора расчетного счета */
 ,pin_jur_acc      in agnacc.strcode%type /*-- := 'И-376985'; --- Найти на форме  --- Лицевой счет (реквизит) организации юр. лица*/
 ,pin_doc_type     in doctypes.doccode%type /*:= 'АктВыпРаб';*/
 ,pin_doc_pref     in transinvcust.pref%type /*:= 'TEST';*/
 ,pin_doc_nmb      in transinvcust.numb%type /*:= '78';*/
 ,pin_doc_date     in transinvcust.docdate%type /*:= trunc(sysdate);*/
 ,pin_sstoper      in azsgsmwaystypes.gsmways_mnemo%type /*:= 'РасходВнеш';*/
 ,pin_starif       in dictarif.code%type /*:= 'Общий'; /*--- Тариф*/
 ,pin_spaytype     in azsgsmpaymentstypes.gsmpayments_mnemo%type /*:= 'ПредоплатаБезнал'; /*-- Вид оплаты*/
 ,pin_sheepview    in dicshpvw .code%type /*:= 'ВыпРабИсп'; /*--- Вид отгнрузки */
 ,pin_tax_gr       in dictaxgr.code%type /*:= 'НДС 20'; /*-- Налоговая группа*/
 ,pin_sum_with_tax in transinvcust.summwithnds%type /*:= 500;*/
 ,pin_sum_out_tax  in stages.stage_sum%type /*:= 500;*/
 ,pin_sum_tax      in stages.stage_sum_nds%type /*:= 500;*/
 ,pin_nomen        in dicnomns.nomen_code%type /*:= 'Аванс за товары'; /* Код номенклатуры для услуг. */
 ,pin_modif        in nommodif.modif_code%type /*:= 'Авансирование'; /* Модификация */
 ,pin_comments     in transinvcust.comments%type
 ,pin_tek_nmb      in number  --- Параметр для автогенерацииномера на форме
) is
  ---- Формирование акта (Расходная накладная на отпуск потребителям)

  v_ncrn         transinvcust.crn%type;
  v_sfaceacc     faceacc.numb%type; -- Лицевой счет этапа
  v_sbuyer_agent agnlist.agnabbr%type; -- из faceacc.agent Контрагент - покупатель
  v_sbuyer_aсс agnacc.strcode%type; --- Лицевой счет (реквизит) организации покупателя
  v_tax_rate     dictaxis.p_value%type; --- Ставка налога на дату счета
  v_cur          curnames.intcode%type;
  dpay_beg       transinvcustspecs.begindate%type; --- Из графика
  dpay_end       transinvcustspecs.enddate%type; --- Из графика

  v_akt_rn    transinvcust.rn%type;
  v_akt_sp_rn transinvcustspecs.rn%type;
  smsg        varchar2(2000);
  nIDENT_MSG  number(17);

begin

  if pin_uni != 'ContractsStages'
  then
    p_exception(0, 'Процедура запускается только из этапов договоров!');
  end if;

  --- Найдем каталог
  begin
  
    select a.rn
      into v_ncrn
      from acatalog a
     where a.name = pin_cat
       and a.docname = 'GoodsTransInvoicesToConsumers'
       and a.company = pin_com;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Каталог %s не найден в разделе "Расходные накладные на отпуск потребителям". Выберите корректное значение через словарь.'
                 ,pin_cat);
  end;

  --- Найдем лицевой счет и другие реквизиты их этапа договора

  select f.numb
        ,ag.agnabbr
        ,ac.strcode
        ,cur.intcode ---, GR.SUMMWITHNDS - GR.PLAN_SUM
        ,st.begin_date
        ,st.end_date
    into v_sfaceacc
        ,v_sbuyer_agent
        ,v_sbuyer_aсс
        ,v_cur
        ,dpay_beg
        ,dpay_end
    from stages st
    join faceacc f
      on f.rn = st.faceacc
    join agnlist ag
      on ag.rn = f.agent
    join agnacc ac
      on ac.rn = f.agnacc
    join curnames cur
      on cur.rn = f.currency
  
   where st.rn = pin_doc;

  p_transinvcust_insert(ncompany       => pin_com
                       ,ncrn           => v_ncrn
                       ,sjur_pers      => pin_jur
                       ,sdoctype       => pin_doc_type
                       ,spref          => pin_doc_pref
                       ,snumb          => pin_doc_nmb
                       ,ddocdate       => pin_doc_date
                       ,nauto_curcours => 1
                       ,dsaledate      => pin_doc_date
                       ,saccdoc        => null
                       ,saccnumb       => null
                       ,daccdate       => null
                       ,sdirdoc        => null
                       ,sdirnumb       => null
                       ,ddirdate       => null
                       ,sstoper        => pin_sstoper
                       ,sfaceacc       => v_sfaceacc
                       ,sgraphpoint    => null
                       ,sagent         => v_sbuyer_agent
                       ,starif         => pin_starif
                       ,nservact_sign  => 1 /* Признак акта приема работ (услуг) ( 0 - не явлется актом, 1 - акт премки) */
                       ,sstore         => null
                       ,smol           => null
                       ,ssheepview     => pin_sheepview
                       ,spaytype       => pin_spaytype
                       ,ndiscount      => 0
                       ,scurrency      => v_cur /* Валюта лицевого счета (пока всегда рубли)*/
                       ,ncurcours      => 1
                       ,ncurbase       => 1
                       ,nfa_cours      => 1
                       ,nfa_basecours  => 1
                       ,nsumm          => pin_sum_out_tax
                       ,nsummwithnds   => pin_sum_with_tax
                       ,srecipdoc      => null
                       ,srecipnumb     => null
                       ,drecipdate     => null
                       ,sferryman      => null
                       ,sshipper       => null
                       ,sagnfifo       => null
                       ,sforwarder     => null
                       ,swaybladenumb  => null
                       ,sdriver        => null
                       ,scar           => null
                       ,sroute         => null
                       ,strailer1      => null
                       ,strailer2      => null
                       ,scomments      => pin_comments
                       ,sacc_agent     => null
                       ,ssubdiv        => null
                       ,sbarcode       => null
                       ,spayconf_type  => null /*-- Тип платежного документа*/
                       ,spayconf_numb  => null /* Номер платежного документа*/
                       ,dpayconf_date  => null /* Дата платежного документа*/
                       ,sreg_agent     => null /*-- Ответственный за оформление*/
                       ,ndup_rn        => null
                       ,nrn            => v_akt_rn
                       ,smsg           => smsg);

  ---- Заводим спецификацию

  p_transinvcustspecs_insert(ncompany         => pin_com
                            ,nprn             => v_akt_rn
                            ,staxgr           => pin_tax_gr
                            ,sgoodsparty      => null
                            ,snomen           => pin_nomen
                            ,snommodif        => pin_modif
                            ,snomnmodifpack   => null
                            ,sarticle         => null
                            ,scell            => null
                            ,shlcargoclass    => null
                            ,ntemperature     => null
                            ,nprice           => pin_sum_with_tax
                            ,ndiscount        => 0
                            ,nquant           => 1
                            ,nquantalt        => 0
                            ,ncoeff           => 0
                            ,ncoeff_val_sign  => 1
                            ,ncoeff_calc_sign => 1
                            ,npricemeas       => 0 -- За основную ЕИ
                            ,nsumm            => pin_sum_out_tax
                            ,nsummwithnds     => pin_sum_with_tax
                            ,nsumm_nds        => pin_sum_tax
                            ,nautocalc_sign   => 1
                            ,dbegindate       => dpay_beg
                            ,denddate         => dpay_beg
                            ,ssernumb         => null
                            ,scountry         => null
                            ,sgtd             => null
                            ,snote            => null
                            ,nrn              => v_akt_sp_rn /*если не null, то это размножение*/
                            ,smsg             => smsg);

  /* Отработаем накладную */

  p_transinvcust_set_status(ncompany   => pin_com
                           ,nrn        => v_akt_rn
                           ,nstatus    => 2 /* -- 0 - снять отработку, 1 - отработать как план, 2 - отработать как факт*/
                           ,dwork_date => pin_doc_date
                           ,smsg       => smsg
                           ,nIDENT_MSG =>  nIDENT_MSG /* Идентификатор записей журнала сообщений (null, 0 - нет сообщений)*/
                           );

end;
/
