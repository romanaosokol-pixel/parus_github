create or replace procedure USR_P_RLS_INSERT
/*
Раздел: "Ведомость инвентаризации"
Процедура: Добавить.
06/03/2024 Степанов М.
*/
(
 nCOMPANY         in number
,sCATALOG         in varchar2
,sDOCTYPE         in varchar2
,sPREF            in varchar2
,dDOCDATE         in date
,sSTORE           in varchar2
,sMOL             in varchar2
,sNOTE            in varchar2
)
is
  sNumb         pkg_std.tstring; 
  nCRN          pkg_std.tref; 
  
  nNumber       pkg_std.tnumber; 
begin 
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_RLS_INSERT');

  /* RN каталога */
  find_acatalog_name(nflag_smart => 0
                    ,ncompany    => nCOMPANY
                    ,nversion    => null
                    ,sunitcode   => 'RealizationInventorySheet'
                    ,sname       => sCATALOG
                    ,nrn         => nCRN);
  /* Номер */
  p_rlinvsheet_getnextnumb(ncompany  => ncompany
                          ,sstore    => sSTORE
                          ,ddoc_date => dDOCDATE
                          ,stype     => sDOCTYPE
                          ,spref     => sPREF
                          ,snumb     => sNumb);
  /* Добавление заголовка */
  p_rlinvsheet_insert(ncompany  => nCOMPANY
                     ,ncrn      => nCRN
                     ,sdoctype  => sDOCTYPE
                     ,spref     => sPREF
                     ,snumb     => sNumb
                     ,ddocdate  => dDOCDATE
                     ,svdoctype => null
                     ,svdocnumb => null
                     ,dvdocdate => null
                     ,sstore    => sSTORE
                     ,scell     => null
                     ,smol      => sMOL
                     ,scurrency => 'RUB'
                     ,sdirector => null
                     ,naccsum   => 0
                     ,nfactsum  => 0
                     ,nmoresum  => 0
                     ,nmisssum  => 0
                     ,snote     => sNOTE
                     ,nrn       => nNumber);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_RLS_INSERT;
/
