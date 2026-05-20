create or replace procedure usr_p_payacc_from_graf
(
  pin_doc          in number /*:= 176590524; -- Rn документа*/
 ,pin_grf_rn       in fcacpayplans.rn%type -- Если запускаем не из графика платежей, то Rn надо выбрать
 ,pin_uni          in varchar2 -- Код раздела
 ,pin_fact_sign    in varchar2 -- аванс/по факту (только для отображения на форме)
 ,pin_com          in companies.rn%type /* := 90521;*/
 ,pin_cat          in acatalog.name%type /* --- := 'Аванс'; */
 ,pin_jur          in jurpersons.code%type /*--- := 'Модуль'; --- Найти на форме*/
 ,pin_jur_agent    in agnlist.agnabbr%type /* Контрагент юр. лица, для выбора расчетного счета */
 ,pin_jur_acc      in agnacc.strcode%type /*-- := 'И-376985'; --- Найти на форме  --- Лицевой счет (реквизит) организации юр. лица*/
 ,pin_ssheepview   in dicshpvw.code%type /*-- := 'ОтгрПродукции'; -- Вид отгрузки*/
 ,pin_spaytype     in azsgsmpaymentstypes.gsmpayments_mnemo%type /* --- := 'ПредоплатаБезнал'; -- Вид оплаты*/
 ,pin_starif       in dictarif.code%type /*--- := 'Общий'; --- Тариф*/
 ,pin_doc_type     in doctypes.doccode%type /*--- := 'СчОпл'; --- Тип документа счета*/
 ,pin_doc_prf      in payacc.pref%type /*--- := '2025';*/
 ,pin_doc_nmb      in payacc.numb%type /*--- := '1230'; --- Вычисляется на форме!*/
 ,pin_doc_date     in payacc.accdate%type /*--- := trunc(sysdate);*/
 ,pin_comments     in payacc.comments%type /*---; --- Комментарий*/
 ,pin_respons      in agnlist.agnabbr%type /* --- := 'Немова О.В.'; --- Ответственный (Из догоовра взять?) -- Вычисляется на формме*/
 ,pin_sdept        in ins_department.code%type /*-- := 'IT'; --- Уточнить необходимость*/
 ,pin_nomen        in dicnomns.nomen_code%type /*-- := 'Аванс за товары'; -- Код номенклатуры для услуг.*/
 ,pin_modif        in nommodif.modif_code%type /*--- := 'Авансирование';*/
 ,pin_sum_with_tax in payaccspecs.summwithnds%type /*--- := 500; -- Сумма по строке спецификации счета (c НДС)*/
 ,pin_sum_out_tax  in payaccspecs.summ%type /*--- := 500; -- Сумма по строке спецификации счета (БЕЗ НДС)*/
 ,pin_sum_tax      in payaccspecs.summ_nds%type /*--- := 500; -- Сумма  НДС)*/
  
 ,pin_tax_gr  in dictaxgr.code%type /*--- := 'НДС 20'; -- Налоговая группа*/
 ,pin_faceacc in faceacc.numb%type --- Лицевой счет (Только для справки )
  --- Калькуляция
 ,pin_scost_article in fpdartcl .code%type --- Статья затрат
 ,pin_clc_lic       in faceacc.numb%type --- Лицевой счет затрат ШПЗ
  
) is
  /* Формирование счета на оплату из графика платежей */

  ---grant execute on usr_p_payacc_from_graf to public;

  svdoc_type              doctypes.doccode%type; --- Документ основания contracts.doc_type%
  svdoc_numb              varchar2(255); --- Префикс + номер договора
  dvdoc_date              contracts.doc_date%type; --- дата договора
  v_ncrn                  payacc.crn%type;
  v_sbuyer_agent          agnlist.agnabbr%type; -- из faceacc.agent Контрагент - покупатель
  v_sbuyer_aсс          agnacc.strcode%type; --- Лицевой счет (реквизит) организации покупателя
  v_sfaceacc              faceacc.numb%type; -- Лицевой счет этапа
  v_scurnames             curnames.curcode%type; --- Валюта этапа  (пока считаем, что совпадает с валютой счета)
  v_py_nrn                payacc.rn%type;
  smsg                    varchar2(2000);
  v_ps_rn                 payaccspecs.rn%type;
  nsumm_base_delta        number(17, 2);
  nsummwithnds_base_delta number(17, 2);
  nsumm_payacc            number(17, 2);
  nsummwithnds_payacc     number(17, 2);
  dpay_beg                payaccspecs.begindate%type; --- Из графика
  dpay_end                payaccspecs.enddate%type; --- Из графика

  v_doc_rn fcacpayplans.rn%type;
  v_clc_rn payaccinspclc.rn%type;

begin

  case pin_uni
    when 'FaceAccountsPayPlans' then
      v_doc_rn := pin_doc;
    else
    
      p_exception(0, 'Из данного раздела процедуру запустить нельзя.');
  end case;

  --- Найдем каталог

  begin
    -- p_options_get(sCODE => 'Realiz_PayAcc_Catalog', nCOMP_VERS => PIN_COM, rRES =>
    select a.rn
      into v_ncrn
      from acatalog a
     where a.name = pin_cat
       and a.docname = 'PaymentAccounts'
       and a.company = pin_com;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Каталог %s не найден. Выберите корректное значение через словарь.'
                 ,pin_cat);
  end;

  --- Найдем реквизиты продавца из лицевого счета этапа

  begin
    select ag.agnabbr
          ,ac.strcode
          ,f.numb
          ,cur.curcode
          ,dt.doccode
          ,trim(dog.doc_pref) || '-' || trim(dog.doc_numb)
          ,dog.doc_date
          ,fpl.begin_date
          ,fpl.end_date
      into v_sbuyer_agent
          ,v_sbuyer_aсс
          ,v_sfaceacc
          ,v_scurnames
          ,svdoc_type
          ,svdoc_numb
          ,dvdoc_date
          ,dpay_beg
          ,dpay_end
      from fcacpayplans fpl
      join faceacc f
        on f.rn = fpl.prn
      join agnlist ag
        on ag.rn = f.agent
      join agnacc ac
        on ac.rn = f.agnacc
      join curnames cur
        on cur.rn = f.currency
      join stages st
        on st.faceacc = fpl.prn
      join contracts dog
        on dog.rn = st.prn
      join doctypes dt
        on dt.rn = dog.doc_type
     where fpl.rn = v_doc_rn;
  
  end;

  p_payacc_insert(ncompany      => pin_com
                 ,ncrn          => v_ncrn
                 ,sjur_pers     => pin_jur -- Покупатель юр. лицо
                 ,sself_agnacc  => pin_jur_acc -- Покупатель реквизит
                 ,sagent        => v_sbuyer_agent --
                 ,sagnacc       => v_sbuyer_aсс
                 ,sfaceacc      => v_sfaceacc
                 ,sgraphpoint   => null --/* Точка графика лицевого счета */
                 ,scurrency     => v_scurnames
                 ,ssheepview    => pin_ssheepview
                 ,spaytype      => pin_spaytype
                 ,starif        => pin_starif
                 ,sfifo         => null
                 , /* Ид грузополучателя */sstore        => null
                 , --
                  sdoctype      => pin_doc_type
                 ,spref         => pin_doc_prf
                 ,snumb         => pin_doc_nmb
                 ,daccdate      => pin_doc_date
                 ,dsaledate     => pin_doc_date
                 ,dwork_date    => trunc(sysdate)
                 , -- Дата смены состояния
                  ncurcours     => 1
                 ,ncurbase      => 1
                 ,nfa_cours     => 1
                 ,nfa_basecours => 1
                 ,ndiscount     => 0
                 ,svdoc_type    => svdoc_type
                 ,svdoc_numb    => svdoc_numb
                 ,dvdoc_date    => dvdoc_date
                 ,scomments     => pin_comments
                 ,sacc_agent    => pin_respons
                 ,ssubdiv       => pin_sdept
                 ,sbarcode      => null
                 ,nrn           => v_py_nrn
                 ,smsg          => smsg);

  --- Добавим к счету позицию спецификации (позиция определяется на форме ввода параметров)

  p_payaccspecs_insert(ncompany                => pin_com
                      ,nprn                    => v_py_nrn
                      ,staxgr                  => pin_tax_gr
                      ,snomen                  => pin_nomen
                      ,snommodif               => pin_modif
                      ,snomnmodifpack          => null
                      ,ssernumb                => null
                      ,scountry                => null
                      ,sgtd                    => null
                      ,sarticle                => null
                      ,sgoodsparty             => null
                      ,sstore                  => null
                      ,nprice                  => pin_sum_with_tax
                      ,ndiscount               => 0
                      ,nquant                  => 1
                      ,nquantalt               => 0
                      ,ncoeff                  => 0
                      ,ncoeff_val_sign         => 1
                      ,ncoeff_calc_sign        => 1
                      ,npricemeas              => 0 -- За основную ЕИ
                      ,nsumm                   => pin_sum_out_tax
                      ,nsummwithnds            => pin_sum_with_tax
                      ,nsumm_nds               => pin_sum_tax
                      ,nautocalc_sign          => 1
                      ,dbegindate              => dpay_beg
                      ,denddate                => dpay_end
                      ,snote                   => null
                      ,ndup_rn                 => null
                      ,nrn                     => v_ps_rn
                      ,smsg                    => smsg
                      ,nsumm_base_delta        => nsumm_base_delta
                      ,nsummwithnds_base_delta => nsummwithnds_base_delta
                      ,nsumm_payacc            => nsumm_payacc
                      ,nsummwithnds_payacc     => nsummwithnds_payacc);

  --- Добавим калькуляцию                      
  -- Мнемокод статьи затрат
if v_ps_rn is not null then  --- Е
 
  p_payaccspclc_insert(ncompany      => pin_com /* Организация */
                        ,nprn          => v_ps_rn /* Родитель */
                        ,snumb         => '1' /* Номер строки */
                        ,scost_article => pin_scost_article /* Мнемокод статьи затрат */
                        ,scost_place   => null /* Мнемокод места возникновения затрат */
                        ,ncost_plan    => null /* Затраты на единицу план */
                        ,ncost_fact    => null /* Затраты на единицу факт */
                        ,npriority     => null /* Приоритет */
                        ,sfaceaccount  => pin_clc_lic /* Номер лицевого счёта */
                        ,sgraphpoint   => null /* Мнемокод точки графика лицевого счета */
                        ,sfinoper_type => null /* Мнемокод вида финансовой операции */
                        ,nquant_plan   => 1 /* Количество план */
                        ,nquant_fact   => null /* Количество факт */
                        ,ssubdiv       => null /* Мнемокод подразделения */
                        ,nrn           => v_clc_rn);
 end if;                       

end;
/
