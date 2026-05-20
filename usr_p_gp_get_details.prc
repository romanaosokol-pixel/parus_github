create or replace procedure USR_P_GP_GET_DETAILS
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
  rMtlgDetRec             usr_pkg_pub_const.tmtlgdetrec;
  sManual                 pkg_std.tstring := 'Нет'; /* Количество присоединённых документов Руководство */
  sSpecs                  pkg_std.tstring := 'Нет'; /* Количество присоединённых документов Характеристики */
  sListOfDevicesExist     pkg_std.tstring := 'Нет'; /* Присутствует в перечне приборов */
  sListOfIndicatorsExist  pkg_std.tstring := 'Нет'; /* Присутствует в перечне индикаторов */
  sListOfDevicesLSExist   pkg_std.tstring := 'Нет'; /* Присутствует в перечне индикаторов длительного храниния */

  nNumber                 pkg_std.tnumber; 
begin
  /* Считывание значений */
  usr_pkg_goodsparties_add.get_vals(ngoodsparties => nRN, rmtlgdetrec => rMtlgDetRec);

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
             'Ответственный в бух.учёте: '   ||rMtlgDetRec.sAcc_Resp||cr||
             'Основные средства: '           ||rMtlgDetRec.sFixed_Assets||cr||
             'На поверке: '                  ||rMtlgDetRec.sOn_Verif||cr||
             'Свидетельство поверки: '       ||rMtlgDetRec.sVerif_Cert||cr||
             'Производитель: '               ||rMtlgDetRec.sProducer||cr||
             'Дата изготовления: '           ||decode_date(ddate => rMtlgDetRec.dProd_date)||cr||
             'Руководство: '                 ||rMtlgDetRec.sManual||cr||
             'Характеристики: '              ||rMtlgDetRec.sSpecs||cr||
             'В перечне приборов: '          ||rMtlgDetRec.sListOfDevicesExist||cr||
             'В перечне индикаторов: '       ||rMtlgDetRec.sListOfIndicatorsExist ||cr||
             'В перечне приборов длительного хранения: '  ||rMtlgDetRec.sListOfDevicesLSExist
             ;
end USR_P_GP_GET_DETAILS;
/
