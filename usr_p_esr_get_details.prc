create or replace procedure usr_p_esr_get_details
/*
Приходные партии товара
Процедура получения данных приходной партии
04/10/2023 Степанов М.
*/
(
 nRN          in number    /* Приходная партия товара */
,sRESULT      out varchar2
)
is
  nGoodsParty             pkg_std.tref;
  rMtlgDetRec             usr_pkg_pub_const.tmtlgdetrec;
  sManual                 pkg_std.tstring := 'Нет'; /* Количество присоединённых документов Руководство */
  sSpecs                  pkg_std.tstring := 'Нет'; /* Количество присоединённых документов Характеристики */
  sListOfDevicesExist     pkg_std.tstring := 'Нет'; /* Присутствует в перечне приборов */
  sListOfIndicatorsExist  pkg_std.tstring := 'Нет'; /* Присутствует в перечне индикаторов */
  sListOfDevicesLSExist   pkg_std.tstring := 'Нет'; /* Присутствует в перечне индикаторов длительного храниния */

  nNumber                 pkg_std.tnumber;
begin
  /* RN приходной партии */
  begin
    select goodsparty
      into nGoodsParty
      from udo_employees_azsrests
     where rn = nRN;
  exception
    when no_data_found then
      return;
    when others then
      p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.'
                 ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'UDO_EMPLOYEES_AZSRESTS')));
  end;
  /* Считывание значений */
  usr_pkg_goodsparties_add.get_vals(ngoodsparties => nGoodsParty, rmtlgdetrec => rMtlgDetRec);

  begin
    select 'Да'
      into sManual
      from filelinks fl
          ,filelinksunits flu
          ,goodsparties gp
     where flu.filelinks_prn = fl.rn
       and fl.file_type      = 122299697 /* !!!!!! Руков.по экспл. */
       and gp.nommodif       = flu.table_prn
       and gp.rn             = nRN;
  exception
    when no_data_found then
      null;
    when too_many_rows then
      null;
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске присоединённого документа с типом "Руков.по экспл." для приходной партии с RN: %s', nRN);
  end;

  begin
    select 'Да'
      into sSpecs
      from filelinks fl
          ,filelinksunits flu
          ,goodsparties gp
     where flu.filelinks_prn = fl.rn
       and fl.file_type      = 122299756 /* !!!!!! Характеристики */
       and gp.nommodif       = flu.table_prn
       and gp.rn             = nRN;
  exception
    when no_data_found then
      null;
    when too_many_rows then
      null;
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске присоединённого документа с типом "Характеристики" для приходной партии с RN: %s', nRN);
  end;

  begin
    select 'Да'
      into sListOfDevicesExist
      from payaccspecs  pas
          ,payacc       pa
     where pas.goodsparty = nRN
       and pa.rn          = pas.prn
       and pa.doctype     = 122611152
       and cmp_vc2(to_char(pa.accdate, 'YYYY'), to_char(current_date, 'YYYY')) = 1
    ;
  exception
    when no_data_found then
      null;
    when too_many_rows then
      p_exception(0, 'Найдено больше одного документа "Перечень приборов" %s года, в который включена приходная партия с RN: %s'
                 ,to_char(current_date, 'YYYY'), nRN);
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске документа "Перечень приборов" %s года, в который включена приходная партия с RN: %s'
                 ,to_char(current_date, 'YYYY'), nRN);
  end;

  begin
    select 'Да'
      into sListOfIndicatorsExist
      from payaccspecs  pas
          ,payacc       pa
     where pas.goodsparty = nRN
       and pa.rn          = pas.prn
       and pa.doctype     = 122611093
       and cmp_vc2(to_char(pa.accdate, 'YYYY'), to_char(current_date, 'YYYY')) = 1
    ;
  exception
    when no_data_found then
      null;
    when too_many_rows then
      p_exception(0, 'Найдено больше одного документа "Перечень индикаторов" %s года, в который включена приходная партия с RN: %s'
                 ,to_char(current_date, 'YYYY'), nRN);
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске документа "Перечень индикаторов" %s года, в который включена приходная партия с RN: %s'
                 ,to_char(current_date, 'YYYY'), nRN);
  end;

  begin
    select 'Да'
      into sListOfDevicesLSExist
      from payaccspecs  pas
          ,payacc       pa
     where pas.goodsparty = nRN
       and pa.rn          = pas.prn
       and pa.doctype     = 122611171
       and cmp_vc2(to_char(pa.accdate, 'YYYY'), to_char(current_date, 'YYYY')) = 1
    ;
  exception
    when no_data_found then
      null;
    when too_many_rows then
      p_exception(0, 'Найдено больше одного документа "Перечень приборов длительного хранения" %s года, в который включена приходная партия с RN: %s'
                 ,to_char(current_date, 'YYYY'), nRN);
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске документа "Перечень приборов длительного хранения" %s года, в который включена приходная партия с RN: %s'
                 ,to_char(current_date, 'YYYY'), nRN);
  end;

  /* Результат */
  sRESULT := 'Складская карточка: '          ||rMtlgDetRec.sStore_card||cr||
             'Заводской номер: '             ||rMtlgDetRec.sFactory_numb||cr||
             'Инвентарный номер: '           ||rMtlgDetRec.sInv_numb||cr||
             'Дата окончания гарантии: '     ||decode_date(ddate => rMtlgDetRec.dWarranty)||cr||
             'Комплектность: '               ||rMtlgDetRec.sEquipment||cr||
             'Номер в госреестре: '          ||rMtlgDetRec.sState_reg_numb||cr||
             'Примечание: '                  ||rMtlgDetRec.sNote||cr||
             'Фактическая поверка. Дата: '   ||decode_date(ddate => rMtlgDetRec.dfact_check_date)||cr||
             'Плановая поверка. Дата: '      ||decode_date(ddate => rMtlgDetRec.dPlan_check_date)||cr||
             'Плановая поверка. Контрагент: '||rMtlgDetRec.sPlan_check_agn||cr||
             'Интервал поверки: '            ||trim(n2ss(rMtlgDetRec.nCheck_interval))||cr||
             'Фактическая поверка. Дата: '   ||decode_date(udo_f_dscr_gp_add_df_chk_date(nrn => nrn))||cr||
             'Ответственный в бух.учёте: '   ||rMtlgDetRec.sAcc_Resp||cr||
             'Основные средства: '           ||rMtlgDetRec.sFixed_Assets||cr||
             'На поверке: '                  ||rMtlgDetRec.sOn_Verif||cr||
             'Свидетельство поверки: '       ||rMtlgDetRec.sVerif_Cert||cr||
             'Производитель: '               ||rMtlgDetRec.sProducer||cr||
             'Дата изготовления: '           ||decode_date(ddate => rMtlgDetRec.dProd_date)||cr||
             'Руководство: '                 ||sManual||cr||
             'Характеристики: '              ||sSpecs||cr||
             'В перечне приборов: '          ||sListOfDevicesExist||cr||
             'В перечне индикаторов: '       ||sListOfIndicatorsExist ||cr||
             'В перечне приборов длительного хранения: '  ||sListOfDevicesLSExist
             ;
end USR_P_ESR_GET_DETAILS;
/
