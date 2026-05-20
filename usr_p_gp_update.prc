create or replace procedure USR_P_GP_UPDATE
/*
Приходные партии товара
Процедура исправления данных метрологии
04/10/2023 Степанов М.
*/
(
 nGOODSPARTIES    in number /* Товареный запас. RN (GOODSPARTIES) */
,nIDENT           in number 
,nCOMPANY         in number
,sPRODUCER        in varchar2 /* Приходные партии товара. Производитель */
,dEXPIRY_DATE     in date     /* Приходные партии товара. Срок годности */
,nSTORAGE_TIME    in number   /* Приходные партии товара. Срок хранения */
,sUMEAS_STORAGE   in varchar2 /* Приходные партии товара. Единица измерения срока хранения*/
,sCERTIFICATE     in varchar2 /* Приходные партии товара. Сертификаты */
,sBARCODE         in varchar2 /* Приходные партии товара. Штрих-код   */
,dPROD_DATE       in date     /* Приходные партии товара. Дата изготовления */
,dWARRANTY        in date     /* Сертификаты. Дата окончания гарантии */
,sSTORE_CARD      in varchar2 /* Сертификаты. Склаская карточка */
,sFACTORY_NUMB    in varchar2 /* Сертификаты. Заводской номер*/
,sINV_NUMB        in varchar2 /* Сертификаты. Инвентарный номер*/
,sEQUIPMENT       in varchar2 /* Сертификаты. Комплектность */
,sSTATE_REG_NUMB  in varchar2 /* Сертификаты. Номер в госреестре */
,sNOTE            in varchar2 /* Сертификаты. Примечание */
,dFACT_CHECK_DATE in date     /* Сертификаты. Фактическая поверка. Дата */
,dPLAN_CHECK_DATE in date     /* Сертификаты. Плановая поверка. Дата */
,sPLAN_CHECK_AGN  in varchar2 /* Сертификаты. Плановая поверка. Контрагент */
,nCHECK_INTERVAL  in number   /* Сертификаты. Интервал поверки */
,sACC_RESP        in varchar2 /* Сертификаты. Ответственный в бух.учёте */
,sFIXED_ASSETS    in varchar2 /* Сертификаты. Основные средства */
,sON_VERIF        in varchar2 /* Сертификаты. На поверке */
,sVERIF_CERT      in varchar2 /* Сертификаты. Свидетельство поверки */
,nWIDTH           in number   /* Номенклатор. Ширина. Ширина */
,nHEIGHT          in number   /* Номенклатор. Высота. Высота */
,nLENGTH          in number   /* Номенклатор. Длина. Длина */
,sMU_SIZE         in varchar2 /* Номенклатор. ЕИ размера. */
,nWEIGHT          in number   /* Номенклатор. Вес. */
,sMU_WEIGHT       in varchar2 /* Номенклатор. ЕИ веса*/
) 
is
  nJUR_PERS     pkg_std.tref;
  rMtlgDetRec   usr_pkg_pub_const.tmtlgdetrec;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_GP_UPDATE');

  /* Проверка превышения отмеченных записей */
  begin
    select null into nJUR_PERS from selectlist where ident = nIDENT;
  exception
    when no_data_found then
      p_exception(0, 'Не найдены отмеченные записи в разделе %s.'
                  , f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'GOODSPARTIES')));
    when too_many_rows then
      p_exception(0, 'Отмечено больше одной записи в разделе %s.'
                  , f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'GOODSPARTIES')));
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске количества отмеченных записей в разделе %s.%s'
                  , f_unitlist_getname(get_unitlist_code_table(nflag_smart => 1, stable_name => 'GOODSPARTIES'))
                  ,cr||sqlerrm);
  end;

  /* Поиск записи */
  p_goodsparties_exists(ncompany => nCOMPANY, nrn => nGOODSPARTIES, njur_pers => nJUR_PERS);

  /* Проверка прав доступа */
  /*pkg_env.prologue(ncompany  => nCOMPANY
                  ,nversion  => null
                  ,ncatalog  => null
                  ,njur_pers => nJUR_PERS
                  ,sunit     => 'GoodsParties'
                  ,saction   => 'GOODSPARTIES_UPDATE'
                  ,stable    => 'GOODSPARTIES'
                  ,ndocument => nGOODSPARTIES);*/

  /* Заполнение переменных */
  rMtlgDetRec.ngoodsparties    := nGOODSPARTIES;
  rMtlgDetRec.sproducer        := usr_f_trim(sPRODUCER);
  rMtlgDetRec.dexpiry_date     := dEXPIRY_DATE;
  rMtlgDetRec.nstorage_time    := nSTORAGE_TIME;
  rMtlgDetRec.sumeas_storage   := sUMEAS_STORAGE;
  rMtlgDetRec.scertificate     := usr_f_trim(sCERTIFICATE);
  rMtlgDetRec.sbarcode         := usr_f_trim(sBARCODE);
  rMtlgDetRec.dprod_date       := dPROD_DATE;
  rMtlgDetRec.dwarranty        := dWARRANTY;
  rMtlgDetRec.sstore_card      := usr_f_trim(sSTORE_CARD);
  rMtlgDetRec.sfactory_numb    := usr_f_trim(sFACTORY_NUMB);
  rMtlgDetRec.sinv_numb        := usr_f_trim(sINV_NUMB);
  rMtlgDetRec.sequipment       := usr_f_trim(sEQUIPMENT);
  rMtlgDetRec.sstate_reg_numb  := usr_f_trim(sSTATE_REG_NUMB);
  rMtlgDetRec.snote            := usr_f_trim(sNOTE);
  rMtlgDetRec.dfact_check_date := dFACT_CHECK_DATE;
  rMtlgDetRec.dplan_check_date := dPLAN_CHECK_DATE;
  rMtlgDetRec.splan_check_agn  := sPLAN_CHECK_AGN;
  rMtlgDetRec.ncheck_interval  := nCHECK_INTERVAL;
  rMtlgDetRec.sacc_resp        := sACC_RESP;
  rMtlgDetRec.sfixed_assets    := sFIXED_ASSETS;
  rMtlgDetRec.son_verif        := usr_f_trim(sON_VERIF);
  rMtlgDetRec.sverif_cert      := usr_f_trim(sVERIF_CERT);
  rMtlgDetRec.nwidth           := nWIDTH;
  rMtlgDetRec.nheight          := nHEIGHT;
  rMtlgDetRec.nlength          := nLENGTH;
  rMtlgDetRec.smu_size         := sMU_SIZE;
  rMtlgDetRec.nweight          := nWEIGHT;
  rMtlgDetRec.smu_weight       := sMU_WEIGHT;

  /* Исправление */
  usr_pkg_goodsparties_add.update_vals(rmtlgdetrec => rMtlgDetRec);

  /* фиксация окончания выполнение действия */
  /*pkg_env.epilogue(ncompany  => nCOMPANY
                  ,nversion  => null
                  ,ncatalog  => null
                  ,njur_pers => nJUR_PERS
                  ,sunit     => 'GoodsParties'
                  ,saction   => 'GOODSPARTIES_UPDATE'
                  ,stable    => 'GOODSPARTIES'
                  ,ndocument => nGOODSPARTIES);*/

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_GP_UPDATE;
/
