create or replace procedure USR_P_GS_MAKE_TID_REFUND
/*
Раздел Товарные запасы
Формирование возвратных накладных в подразделения по текущему товарному запасу и заданным параметрам
27/09/2023 Степанов М.
*/
(
 nRN             in number      /* Товарный запас goodssupply */
/* Для отбора документов-источников. Если пусто, то все */
,dPRM_BEGIN      in date        /* Дата начала периода */
,dPRM_END        in date        /* Дата окончания периода */
,sPRM_CATALOG    in varchar2    /* Каталоги */
,sPRM_SHEEPVIEW  in varchar2    /* Виды отгрузки */
,sPRM_FACEACC    in varchar2    /* Лицевые счета */
,sPRM_IN_STORE   in varchar2    /* Склады-получатели */
/* Пармаметры формируемых документов. Если не заданы, то используются из документа-источника */
,dDOCDATE        in date        /* Дата */
,sCATALOG        in varchar2    /* Каталог */
,sSTORE          in varchar2    /* Склад-отправитель */
)
is
  aPrm_CatalogRNList     udo_tp_numtable := udo_tp_numtable();
  aPrm_SheepViewRNList   udo_tp_numtable := udo_tp_numtable();
  aPrm_FaceAccRNList     udo_tp_numtable := udo_tp_numtable();
  aPrm_In_StoreRNList    udo_tp_numtable := udo_tp_numtable();
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_GS_MAKE_TID_REFUND');

  /* Списки RN параметров */
  if sPRM_CATALOG is not null then
    aPrm_CatalogRNList := usr_pkg_common.get_rn_list_by_code(scode => sPRM_CATALOG, stable_name => 'ACATALOG', scolumn_name => 'NAME');
  end if;
  if sPRM_SHEEPVIEW is not null then
    aPrm_SheepViewRNList := usr_pkg_common.get_rn_list_by_code(scode => sPRM_SHEEPVIEW, stable_name => 'DICSHPVW', scolumn_name => 'NAME');
  end if;
  if sPRM_FACEACC is not null then
    aPrm_FaceAccRNList := usr_pkg_common.get_rn_list_by_code(scode => sPRM_FACEACC, stable_name => 'FACEACC', scolumn_name => 'NUMB');
  end if;
  if sPRM_IN_STORE is not null then
    aPrm_In_StoreRNList := usr_pkg_common.get_rn_list_by_code(scode => sPRM_IN_STORE, stable_name => 'AZSAZSLISTMT', scolumn_name => 'AZS_NUMBER');
  end if;
  /* Запрос */
  for c in (
            select tid.*, gs.prn as ngoodsparties
              from goodssupply    gs
                  ,storeoperjourn soj
                  ,doclinks       dl
                  ,transinvdept   tid
             where gs.rn           = nRN
               and soj.goodssupply = gs.rn
               and dl.out_document = soj.rn
               and tid.rn          = dl.in_document
               and (tid.docdate   >= dPRM_BEGIN or dPRM_BEGIN is null)
               and (tid.docdate   <= dPRM_END   or dPRM_END   is null)
               and (tid.crn       in (select column_value from table(cast(aPrm_CatalogRNList   as udo_tp_numtable))) or sPRM_CATALOG   is null)
               and (tid.sheepview in (select column_value from table(cast(aPrm_SheepViewRNList as udo_tp_numtable))) or sPRM_SHEEPVIEW is null)
               and (tid.faceacc   in (select column_value from table(cast(aPrm_FaceAccRNList   as udo_tp_numtable))) or sPRM_FACEACC   is null)
               and (tid.in_store  in (select column_value from table(cast(aPrm_In_StoreRNList  as udo_tp_numtable))) or sPRM_IN_STORE  is null)
           )
  loop
    /* формирование */
    usr_pkg_transinvdept.transinvdept_make_tid(nrn           => c.rn
                                              ,ncompany      => c.company
                                              ,ddocdate      => dDOCDATE
                                              ,scatalog      => sCATALOG
                                              ,sstore        => sSTORE
                                              ,ngoodsparties => c.ngoodsparties);
  end loop;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_GS_MAKE_TID_REFUND;
/
