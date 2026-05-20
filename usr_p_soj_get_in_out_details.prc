create or replace procedure usr_p_soj_get_in_out_details
/*
Журнал складских операций
Возвращает данные связанного документа
*/
(
 nRN          in number   /* Журнал складских операций */
,nFLAGSMART   in number
,nSTORE_0     out number  /* Расход. Склад */
,nMOL_0       out number  /* Расход. МОЛ */
,nSOT_0       out number  /* Расход. Складская операция */
,nFACEACC_0   out number  /* Расход. Лицевой счёт */
,nSTORE_1     out number  /* Приход. Склад */
,nMOL_1       out number  /* Приход. МОЛ */
,nSOT_1       out number  /* Приход. Складская операция */
,nFACEACC_1   out number  /* Приход. Лицевой счёт */
)
is
  rStoreOperJourn     storeoperjourn%rowtype;
  nDocument           pkg_std.tref;
  rDocument           usr_pkg_pub_const.tdoc_base_values_rec;
  rStoreOper          azsgsmwaystypes%rowtype;
begin
  /* Считывание текущей записи журнала складских операций */
  select * into rStoreOperJourn from storeoperjourn where rn = nRN;

  /* Определение RN связанного документа */
  nDocument := f_doclinks_link_in_doc( sout_unitcode => 'StoreOpersJournal'
                                      ,nout_document => rStoreOperJourn.rn
                                      ,sin_unitcode  => rStoreOperJourn.unitcode );

  /* Считывание полей товарного документа */
  rDocument := usr_pkg_document.get_tdoc_values( nrn => nDocument, sunitcode => rStoreOperJourn.unitcode );

  /* Считывание складской операции документа */
  select * into rStoreOper from azsgsmwaystypes where rn = rDocument.nstoreoper;

  /* Направление складской операции */
  case rStoreOper.gsmways_type
    /* Расход */
    when 0 then
      nSTORE_0    := rDocument.nstore;
      nMOL_0      := rDocument.nmol;
      nSOT_0      := rDocument.nstoreoper;
      nSTORE_1    := rDocument.nin_store;
      nMOL_1      := rDocument.nin_mol;
      nSOT_1      := rDocument.nin_storeoper;
      nFACEACC_1  := rDocument.nfaceacc;
    /* Приход */
    when 1 then
      nSTORE_0    := rDocument.nin_store;
      nMOL_0      := rDocument.nin_mol;
      nSOT_0      := rDocument.nin_storeoper;
      nFACEACC_0  := rDocument.nfaceacc;
      nSTORE_1    := rDocument.nstore;
      nMOL_1      := rDocument.nmol;
      nSOT_1      := rDocument.nstoreoper;
  else
    p_exception(nFLAGSMART, 'Неверное значение направления складской операции с RN <%s>.',  rStoreOper.rn);
  end case;

end usr_p_soj_get_in_out_details;
/
