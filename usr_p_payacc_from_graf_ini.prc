create or replace procedure usr_p_payacc_from_graf_ini(pin_doc in number /*:= 176590524; -- Rn документа*/
                                                      ,pin_com in companies.rn%type /* := 90521;*/
                                                      ,pin_uni in varchar2 -- Код раздела
                                                      ,out_jur out jurpersons.code%type /*--- := 'Модуль'; --- Найти на форме*/
                                                       
                                                      ,out_fact_sign     out varchar2 -- аванс/по факту (только для отображения на форме)
                                                      ,out_cat           out acatalog.name%type /* --- := 'Аванс'; */
                                                      ,out_spaytype      out azsgsmpaymentstypes.gsmpayments_mnemo%type /* --- := 'ПредоплатаБезнал'; -- Вид оплаты*/
                                                      ,out_starif        out dictarif.code%type /*--- := 'Общий'; --- Тариф*/
                                                      ,out_ssheepview    out dicshpvw.code%type /*-- := 'ОтгрПродукции'; -- Вид отгрузки*/
                                                      ,out_sum_with_tax  out payaccspecs.summwithnds%type /*--- := 500; -- Сумма по строке спецификации счета (c НДС)*/
                                                      ,out_sum_out_tax   out payaccspecs.summ%type /* Сумма по строке спецификации счета (БЕЗ НДС)*/
                                                      ,out_sum_tax       out payaccspecs.summ_nds%type /* Сумма  НДС)*/
                                                      ,out_grf_rn        out fcacpayplans.rn%type -- Если запускаем не из графика платежей, то Rn надо выбрать
                                                      ,out_vis_grf_rn    out number
                                                      ,out_doc_type      out doctypes.doccode%type /*--- := 'СчОпл'; --- Тип документа счета*/
                                                      ,out_doc_prf       out payacc.pref%type /*--- := '2025';*/
                                                      ,out_doc_date      out payacc.accdate%type /*--- := trunc(sysdate);*/
                                                      ,out_doc_nmb       out payacc.numb%type /*--- := '1230'; --- Вычисляется на форме!*/
                                                      ,out_comments      out payacc.comments%type /*---; --- Комментарий*/
                                                      ,out_jur_agent     out agnlist.agnabbr%type /* Контрагент юр. лица, для выбора расчетного счета */
                                                      ,out_jur_acc       out agnacc.strcode%type /*-- := 'И-376985'; --- Найти на форме  --- Лицевой счет (реквизит) организации юр. лица*/
                                                      ,out_faceacc       out faceacc.numb%type
                                                      ,out_nomen         out dicnomns.nomen_code%type /*-- := 'Аванс за товары'; -- Код номенклатуры для услуг.*/
                                                      ,out_tax_gr        out dictaxgr.code%type /*--- := 'НДС 20'; -- Налоговая группа*/
                                                      ,out_modif         out nommodif.modif_code%type /*--- := 'Авансирование';*/
                                                      ,out_respons       out agnlist.agnabbr%type /* --- := 'Немова О.В.'; --- Ответственный (Из догоовра взять?) -- Вычисляется на формме*/
                                                      ,out_scost_article out fpdartcl .code%type --- Статья затрат
                                                      ,out_clc_lic       out faceacc.numb%type --- Лицевой счет затрат
                                                       
                                                       ) is
  v_options  options%rowtype;
  v_f_rn     faceacc.rn%type;
  v_tax_rate dictaxis.p_value%type; --- Ставка налога на дату счета

begin
  begin
    select case fp.fact_sign
             when 1 then
              'По факту'
             when 0 then
              'Аванс'
             else
              'None'
           end
          ,tp.gsmpayments_mnemo
          ,fp.pay_sum - fp.fact_pays
          ,jp.code
          ,f.numb
          ,ag.agnabbr
          ,ac.strcode
          ,coalesce(usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 1082887, ndocument => dog.rn), ex.agnabbr)
          ,f.rn
          ,sz.code
          ,usr_f_stages_sgpz(st.faceacc) --- ШПЗ по лицевому счету
          ,tg.code    
      into out_fact_sign /* Признак Аванс/по факту*/
          ,out_spaytype /* Вид оплаты */
          ,out_sum_with_tax /*Сумма с налогами */
          ,out_jur
          ,out_faceacc
          ,out_jur_agent
          ,out_jur_acc
          ,out_respons
          ,v_f_rn
          ,out_scost_article
          ,out_clc_lic
          ,out_tax_gr
      from fcacpayplans fp
      left join azsgsmpaymentstypes tp
        on tp.rn = fp.pay_type
      join jurpersons jp
        on jp.rn = fp.jur_pers
      join stages st
        on st.faceacc = fp.prn
      join faceacc f
        on f.rn = fp.prn
      join agnlist ag
        on ag.rn = jp.agent
      left join agnacc ac
        on ac.rn = st.jur_acc
      join contracts dog
        on dog.rn = st.prn
      left join agnlist ex
        on ex.rn = dog.executive
      left join fpdartcl sz
        on sz.rn = f.ieelement
      join dictaxgr tg
        on tg.rn = st.taxgr
    
     where fp.rn = pin_doc;
  
  exception
    when no_data_found then
      null;
    
  end;

  out_doc_date := null; ---trunc(sysdate);

  out_comments := null; -- Очищаем предыдущее значение

  p_options_get(scode => 'Realiz_PayAcc_Catalog', ncomp_vers => pin_com, rres => v_options);
  out_cat := coalesce(v_options.str_value, 'Счета на оплату');

  p_options_get(scode => 'Realiz_PayAcc_Tariff', ncomp_vers => pin_com, rres => v_options);
  out_starif := coalesce(v_options.str_value, 'Общий');

  p_options_get(scode => 'Realiz_PayAcc_DocType', ncomp_vers => pin_com, rres => v_options);
  out_doc_type := coalesce(v_options.str_value, 'СчОпл');
  /*Вид отгрузки */
  p_options_get(scode => 'Realiz_PayAcc_ShipType', ncomp_vers => pin_com, rres => v_options);
  out_ssheepview := coalesce(v_options.str_value, 'Продажа МЦ');

  out_doc_prf := to_char(sysdate, 'YYYY'); -- Четыре символа года всегда

  /* p_payacc_getnextnumb(ncompany  => pin_com
  ,sjur_pers => out_jur
  ,daccdate  => out_doc_date
  ,stype     => out_doc_type
  ,spref     => out_doc_prf
  ,snumb     => out_doc_nmb);*/

  out_doc_nmb := null; -- Он присваивается в бухгалтерии, считать его не нужно                    

  if out_fact_sign = 'Аванс'
  then
  
    out_nomen := 'Аванс за товары';
    out_modif := 'Авансирование';
  
  else
    out_nomen := '00000139366';
    out_modif := '00000139366';
  
  end if;

  -- Найдем ставку налога

  begin
  
    select dx.p_value
      into v_tax_rate
      from dictaxgr dxg
      join compverlist v
        on v.version = dxg.version
      join dictaxis dx
        on dx.tax_group = dxg.rn
     where dxg.code = out_tax_gr
       and v.unitcode = 'TaxiesGroups'
       and v.company = pin_com
       and dx.beg_date = (select max(t.beg_date)
                            from dictaxis t
                           where t.tax_group = dxg.rn
                             and t.beg_date <= sysdate);
  
  exception
    when no_data_found then
      p_exception(0
                 ,'На дату %s не найдено значение ставки налога %s обратитесь в ПЭО для заведения корректной ставки налога.'
                 ,sysdate
                 ,out_tax_gr);
    
  end;

  out_sum_out_tax := round(out_sum_with_tax / (1 + v_tax_rate / 100), 2);
  out_sum_tax     := out_sum_with_tax - out_sum_out_tax;

  if pin_uni = 'FaceAccountsPayPlans'
  then
    out_vis_grf_rn := 0; --- НЕ Показываем поле
    out_grf_rn     := pin_doc;
  else
    out_vis_grf_rn := 1; --- Показываем поле для выбора графика
  end if;

end;
/
