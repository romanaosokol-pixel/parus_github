create or replace procedure usr_p_filelinksunits_insert
/*
Все разделы.
Процедура "Установить связь с присоединённым документом"
28/04/2025 Степанов М.
*/
(
 nCOMPANY        in number
,nRN             in number    /* RN текущей записи */
,sUNITCODE       in varchar2  /* Код раздела записи */
,sFILELINKS_CODE in varchar2  /* Код присоединённого документа */
)
as
  rFileLinks      filelinks%rowtype;
  
begin
  /* Считывание параметров присоединённого документа */
  find_filelinks_code(nflag_smart => 0
                     ,ncompany    => nCOMPANY
                     ,scode       => sFILELINKS_CODE
                     ,nrn         => rFileLinks.rn
                     ,nfile_type  => rFileLinks.file_type
                     ,snote       => rFileLinks.note
                     ,sfile_path  => rFileLinks.file_path
                     ,dload_date  => rFileLinks.load_date
                     ,ncrn        => rFileLinks.crn);
  /* Добавление связи присоединённого документа с текущей записью */
  p_filelinksunits_insert(ncompany       => nCOMPANY
                         ,nfilelinks_prn => rFileLinks.rn
                         ,ntable_prn     => nRN
                         ,sunitcode      => sUNITCODE
                         ,nrn            => rFileLinks.rn);
end;
/
