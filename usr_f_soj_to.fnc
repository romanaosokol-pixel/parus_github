create or replace function usr_f_soj_to
/*
Журнал складских операций.
Функция возвращает данные "Кому": Склад (Лицевой счёт) / Лицевой счёт, МОЛ
create public synonym usr_f_soj_to for usr_f_soj_to;
grant execute on usr_f_soj_to to public;
*/
(
 nRN        in number
)
return varchar2
is
  nStore      pkg_std.tref;
  nMOL        pkg_std.tref;
  nFaceAcc    pkg_std.tref;

  nNumber       pkg_std.tnumber;
  sVarchar      pkg_std.tstring;
begin
  /* Получение значений из документа */
  usr_p_soj_get_in_out_details(nrn        => nRN
                              ,nflagsmart => 1
                              ,nstore_0   => nNumber
                              ,nmol_0     => nNumber
                              ,nsot_0     => nNumber
                              ,nfaceacc_0 => nNumber
                              ,nstore_1   => nStore
                              ,nmol_1     => nMOL
                              ,nsot_1     => nNumber
                              ,nfaceacc_1 => nFaceAcc
                              );
  /* Определение мнемокодов и формирование выходного значения */
  /* склад */
  if nStore is not null then
    sVarchar := strcombine(sVarchar, f_dicstore_get_numb(nstore => nStore));
  end if;
  /* МОЛ */
  sVarchar := strcombine(sVarchar, get_agnlist_agnabbr_id(nflag_smart => 1, nrn => nMOL), ', ');
  /* лицевой счёт */
  sVarchar := strcombine(sVarchar, get_faceacc_numb_id(nflag_smart => 1, nrn => nFaceAcc), ', ');

  return sVarchar;

end usr_f_soj_to;
/
