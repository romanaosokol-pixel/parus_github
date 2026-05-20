create or replace procedure usr_p_tid_make_tid
/*
Раздел: Расходные накладные на отпуск в подразделения
Процедура: Сформировать расходную накладную в подразделения.
04/04/2025 Степанов М.
*/
(
 nRN                  in number
,nCRN                 in number
,dDATE                in date
,sMOL                 in varchar2
,nMOL_FROM_STORE      in number default 0   /* Использовать МОЛ-отправителя из склада-отправителя: 0-нет, 1-да */
,sSHEEPVIEW           in varchar2
,sIN_STORE            in varchar2
,sIN_MOL              in varchar2
,nIN_MOL_FROM_STORE   in number default 0   /* Использовать МОЛ-получателя из склада-получателя: 0-нет, 1-да */
,sIN_STOPER           in varchar2
,sFACEACC             in varchar2
,sSUBDIV              in varchar2
,nSTPJ_MINS           in number default 0   /* Списать с мест хранения: 0-нет, 1-да */
,nWORK                in number default 0   /* Отработать: 0-нет, 1-да */
)
is
  rV_Row          v_transinvdept%rowtype;
  rV_Row2         v_transinvdept%rowtype;
  rV_Store        v_dicstore%rowtype;
  rV_In_Store     v_dicstore%rowtype;
  nIn_Status      pkg_std.tnumber := 0; 

  sVarchar        pkg_std.tstring; 
  nNumber         pkg_std.tnumber; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TID_MAKE_TID');

  /* Считывание текущей записи */
  begin select * into rV_Row from v_transinvdept where nrn = usr_p_tid_make_tid.nRN; end;
  rV_Row2 := rV_Row;

  /* Проверка отработки */
  if rV_Row2.nstatus = 0 then 
    p_exception(0, 'Документ должен быть отработан. %s%s'
               ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rV_Row.nrn)); 
  end if;
  
  /* Копирование документа */
  usr_pkg_transinvdept.transinvdept_insert(rV_Row => rV_Row2, smsg => sVarchar);


  /* Подмена значений переменных */

  /* Каталог */
  rV_Row2.ncrn := nvl( nCRN, rV_Row2.ncrn ) ;

  /* Дата */
  rV_Row2.ddocdate := coalesce( trunc( dDATE ), /*rV_Row2.ddocdate*/trunc( sysdate ));

  /* Расчёт номера */
  p_transinvdept_getnextnumb(ncompany  => rV_Row2.ncompany
                            ,sjur_pers => rV_Row2.sjur_pers
                            ,ddocdate  => rV_Row2.ddocdate
                            ,stype     => rV_Row2.sdoctype
                            ,spref     => rV_Row2.spref
                            ,snumb     => rV_Row2.snumb);
  /* Переопределение складов */
  rV_Row2.sstore := rV_Row2.sin_store;
  rV_Row2.smol   := rV_Row2.sin_mol;
  rV_Row2.sin_store := null;
  rV_Row2.sin_mol   := null;

  /* Подстановка значений в переменную */
  /* Если использовать МОЛ склада-отправителя */
  if nvl(nMOL_FROM_STORE, 0) = 1 then
    /* Считываем склад-отправитель */
    select * into rV_Store from v_dicstore where snumb = rV_Row2.sstore;
    /* Используем МОЛ склада-отправителя */
    rV_Row2.smol := rV_Store.skeeper;
  else
    rV_Row2.smol := nvl(sMOL, rV_Row2.smol);
  end if;

  /* Если задан МОЛ получателя в параметре */
  rV_Row2.sin_mol := nvl(sIN_MOL, rV_Row2.sin_mol);

  /* Если указан склад-получатель */
  if sIN_STORE is not null then
    /* Считываем склад-получатель */
    select * into rV_In_Store from v_dicstore where snumb = sIN_STORE;
    rV_Row2.sin_store := rV_In_Store.snumb;
    /* Если использовать МОЛ склада-получателя */
    if nvl(nIN_MOL_FROM_STORE, 0) = 1 then
      rV_Row2.sin_mol := rV_In_Store.skeeper;
    end if;
  end if;

  /* Складская операция получателя */
  rV_Row2.sin_stoper := nvl(sIN_STOPER, rV_Row2.sin_stoper);
  /* Вид отгрузки */
  rV_Row2.ssheepview := nvl(sSHEEPVIEW, rV_Row2.ssheepview);
  /* Лицевой счёт */
  rV_Row2.sfaceacc   := nvl(sFACEACC, rV_Row2.sfaceacc);
  /* Лицевой счёт */
  rV_Row2.ssubdiv    := nvl(sSUBDIV, rV_Row2.ssubdiv);

  /* Исправление документа */
  usr_pkg_transinvdept.transinvdept_update(rV_Row => rV_Row2);
  /* Считывание после исправления */
  begin select * into rV_Row2 from v_transinvdept where nrn = rV_Row2.nrn; end;

  /* Установка связи с исходным документом */
  pkg_doclinks.link(nflag_smart       => 0
                   ,ncompany          => rV_Row2.ncompany
                   ,sin_unitcode      => 'GoodsTransInvoicesToDepts'
                   ,nin_document      => rV_Row.nrn
                   ,sout_unitcode     => 'GoodsTransInvoicesToDepts'
                   ,nout_document     => rV_Row2.nrn);

  /* Списание с мест хранения */
  if nvl(nSTPJ_MINS, 0) = 1 then
    usr_pkg_transinvdept.transinvdept_sprj_mins(ncompany => rV_Row2.ncompany, nrn => rV_Row2.nrn, dreservingdate => rV_Row2.ddocdate, noutnote => nNumber);
  end if;

  /* Отработка */
  if nvl(nWORK, 0) = 1 then
    /* Если заполнен склад-получатель, то отработка с приходом */
    if rV_Row2.sin_store is not null then
      nIn_Status := 1; 
    end if;
    /* Отработка */
    p_transinvdept_set_status(ncompany      => rV_Row2.ncompany
                             ,nrn           => rV_Row2.nrn
                             ,nstatus       => 2
                             ,nin_status    => nIn_Status
                             ,din_work_date => rV_Row2.ddocdate
                             ,dwork_date    => rV_Row2.ddocdate
                             ,smsg          => sVarchar
                             ,sconfirm      => sVarchar
                             ,nident_msg    => nNumber);
  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  

end;
/
