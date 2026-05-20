create or replace procedure USR_P_TID_MAKE_SAFE_RECIEPT
/*
Раздел: "Расходные накладные на отпуск в подразделения"
Процедура: Сформировать документ "Сохранная расписка" из текущего документа.
06/03/2024 Степанов М.
create public synonym USR_P_TID_MAKE_SAFE_RECIEPT for USR_P_TID_MAKE_SAFE_RECIEPT;
grant execute on USR_P_TID_MAKE_SAFE_RECIEPT to public;
*/
(
 nRN              in number
,dDATE            in date
,sFACEACC         in varchar2
,sIN_MOL          in varchar2
,sCOMMENTS        in varchar2
)
is
  nRN2          pkg_std.tref := nRN;
  rV_Row        v_transinvdept%rowtype; /* Источник */
  rV_RowNew     v_transinvdept%rowtype; /* Приёмник */

  sVarchar      pkg_std.tstring;
  nNumber       pkg_std.tnumber; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_TID_MAKE_SAFE_RECIEPT');

  /* Считывание текущего документа */
  select * into rV_Row from v_transinvdept where nrn = nRN2;
  /* Копирование в переменную для нового документа */
  rV_RowNew := rV_Row;

  /* Проверка */
  /* Документ-источник является перемещение между МХ */
  if cmp_vc2(rV_RowNew.sstore, rV_RowNew.sin_store) != 1 then
    p_exception(0, 'Исходная накладная не является перемещением между местами хранения, т.к. склад-отправитель <%s> не равен складу-получателю <%s>. %s'
               ,rV_RowNew.sstore
               ,rV_RowNew.sin_store
               ,cr||f_docdescrs_get_description(sunitcode => 'GoodsTransInvoicesToDepts', ndocument => rV_Row.nrn)); 
  end if;

  /* Заполнение переменных для документа-приёмника */
  rV_RowNew.ncrn     := 119834020;
  rV_RowNew.ddocdate := nvl( trunc( dDATE ), rV_RowNew.ddocdate);
  rV_RowNew.sdoctype := 'Сохранная';
  p_transinvdept_getnextnumb(ncompany  => rV_RowNew.ncompany
                            ,sjur_pers => rV_RowNew.sjur_pers
                            ,ddocdate  => rV_RowNew.ddocdate
                            ,stype     => rV_RowNew.sdoctype
                            ,spref     => rV_RowNew.spref
                            ,snumb     => rV_RowNew.snumb);
  rV_RowNew.sstore     := rV_RowNew.sin_store;
  rV_RowNew.smol       := rV_RowNew.sin_mol;
  rV_RowNew.sfaceacc   := sFACEACC;
  rV_RowNew.ssubdiv    := 'ПДО';
  rV_RowNew.sin_store  := null;
  rV_RowNew.sin_mol    := sIN_MOL;
  rV_RowNew.ssheepview := 'Рез.Сохр.Расп.';
  rV_RowNew.scomments  := sCOMMENTS;
  
  usr_pkg_transinvdept.transinvdept_insert(rv_row => rV_RowNew, smsg => sVarchar);
  /* Копирование с исходного документа */
  /*p_transinvdept_insert(ncompany       => rV_RowNew.ncompany
                       ,ncrn           => rV_RowNew.ncrn
                       ,sjur_pers      => rV_RowNew.sjur_pers
                       ,sdoctype       => rV_RowNew.sdoctype
                       ,spref          => rV_RowNew.spref
                       ,snumb          => rV_RowNew.snumb
                       ,ddocdate       => rV_RowNew.ddocdate
                       ,sdirdoc        => rV_RowNew.sdirdoc
                       ,sdirnumb       => rV_RowNew.sdirnumb
                       ,ddirdate       => rV_RowNew.ddirdate
                       ,sstoper        => rV_RowNew.sstoper
                       ,sfaceacc       => rV_RowNew.sfaceacc
                       ,sgraphpoint    => rV_RowNew.sgraphpoint
                       ,sstore         => rV_RowNew.sstore
                       ,smol           => rV_RowNew.smol
                       ,ssheepview     => 'Рез.Сохр.Расп.'
                       ,sagent         => rV_RowNew.sagent
                       ,ssubdiv        => rV_RowNew.ssubdiv
                       ,scurrency      => rV_RowNew.scurrency
                       ,ncurcours      => rV_RowNew.ncurcours
                       ,ncurbase       => rV_RowNew.ncurbase
                       ,nsummwithnds   => rV_RowNew.nsummwithnds
                       ,srecipdoc      => rV_RowNew.srecipdoc
                       ,srecipnumb     => rV_RowNew.srecipnumb
                       ,drecipdate     => rV_RowNew.drecipdate
                       ,sferryman      => rV_RowNew.sferryman
                       ,sgetconfirm    => rV_RowNew.sgetconfirm
                       ,swaybladenumb  => rV_RowNew.swaybladenumb
                       ,sdriver        => rV_RowNew.sdriver
                       ,scar           => rV_RowNew.scar
                       ,sroute         => rV_RowNew.sroute
                       ,strailer1      => rV_RowNew.strailer1
                       ,strailer2      => rV_RowNew.strailer2
                       ,nfa_curcours   => rV_RowNew.nfa_curcours
                       ,nfa_curbase    => rV_RowNew.nfa_curbase
                       ,sin_store      => rV_RowNew.sin_store
                       ,sin_mol        => rV_RowNew.sin_mol
                       ,sin_stoper     => rV_RowNew.sin_stoper
                       ,sin_party      => rV_RowNew.sin_party
                       ,nin_curcours   => rV_RowNew.nin_curcours
                       ,nin_curbase    => rV_RowNew.nin_curbase
                       ,svalid_doctype => rV_RowNew.svalid_doctype
                       ,svalid_docnumb => rV_RowNew.svalid_docnumb
                       ,dvalid_docdate => rV_RowNew.dvalid_docdate
                       ,scomments      => rV_RowNew.scomments
                       ,sbarcode       => rV_RowNew.sbarcode
                       ,sORD_DOCTYPE   => rV_RowNew.sord_doctype   -- Тип приказа   ---Обновление 2024/03/28
                       ,sORD_DOCNUMB   => rV_RowNew.sord_docnumb   -- Номер приказа ---Обновление 2024/03/28
                       ,dORD_DOCDATE   => rV_RowNew.dord_docdate   -- Дата приказа  ---Обновление 2024/03/28
                       ,nNEED_UTIL     => rV_RowNew.nneed_util     -- Необходимость уничтожения (утилизации)  ---Обновление 2024/03/28                       ,nrn            => rV_RowNew.nrn \* in out *\
                       ,nrn            => rV_RowNew.nrn \* in out *\
                       ,smsg           => sVarchar);*/

  /* Копирование мест хранения для распределения из документа-источника в места хранения для списания в документ-приёмник */
  usr_pkg_transinvdept.transinvdept_sprj_copy_other( nrn_from => rV_Row.nrn, nrn_to  => rV_RowNew.nrn, dreserving_date => sysdate );

  /* Резервирование документа-приёмника */
  p_selectlist_insert(nident => rV_RowNew.nrn, ndocument => rV_RowNew.nrn, sunitcode => 'GoodsTransInvoicesToDepts', nrn => nNumber);
  p_transinvdept_reserv(ncompany     => rV_RowNew.ncompany
                       ,nident       => rV_RowNew.nrn
                       ,nreserv      => 1
                       ,dres_date    => rV_RowNew.ddocdate
                       ,dres_date_to => rV_RowNew.ddocdate
                       ,nsign_warn   => 1
                       ,nsign_party  => 0
                       ,smsg         => sVarchar);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_TID_MAKE_SAFE_RECIEPT;
/
