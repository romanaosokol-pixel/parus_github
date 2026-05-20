create or replace procedure USR_P_GET_INSERT_DETAILS
/*
Все разделы. Для окна просмотра
Получить данные о добавлении документа из журнала регистрации: дату и автора
Степанов М.В. 20/09/2024
*/
(
 nRN                in number
,sRESULT            out varchar2
)
is
  dModifDate    date;
  sAuthID       userlist.authid%type;
  nPers_Agent   pkg_std.tref; 
begin
  /* Дата и authid автора */
  usr_pkg_updatelist.updatelist_get_last_details(nflagsmart => 1
                                                ,nrn        => nRN
                                                ,soperation => 'I'
                                                ,dmodifdate => dModifDate
                                                ,sauthid    => sAuthID);
  /* Контрагент по authid */
  find_agnlist_authid_ex(nflag_option => 1
                        ,ncompany     => 90521
                        ,sauthid      => sAuthID
                        ,ddate        => sysdate
                        ,nagent       => nPers_Agent);
  /* Результат */
  sRESULT := strcombine(to_char(dModifDate, 'dd.mm.yyyy hh24:mi:ss'), get_agnlist_agnabbr_id(nflag_smart => 1, nrn => nPers_Agent), ', ' );
  
end USR_P_GET_INSERT_DETAILS;
/
