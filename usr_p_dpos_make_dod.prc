create or replace procedure USR_P_DPOS_MAKE_DOD
/*
Заказы подразделений (спецификация)
Сформировать распоряжение об изменении заказа подразделения по отмеченным записям
09/09/2024 Степанов М.
grant execute on USR_P_DPOS_MAKE_DOD to public;
*/
(
 nIDENT         in number
,sACATALOG      in varchar2
,sREASON        in varchar2  /* Причины отступления */
,sBASIS         in varchar2  /* Обоснование */
,sNOTE          in varchar2  /* Примечание */
)
is
  sDoc_Type_Code    pkg_std.tstring := 'ВЗ'; 
  sDoc_Pref         pkg_std.tstring := d_year(sysdate); 
  dDoc_Date         date := trunc(sysdate);
  nDoc_Type_Code    pkg_std.tref;
  sDoc_Numb         pkg_std.tstring; 
  nAcatalog         pkg_std.tref;
  nDepartmentOrd    pkg_std.tref;
  nPers_Agent       pkg_std.tref; 
  rAgnList          agnlist%rowtype;

  nNumber           pkg_std.tnumber;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_DPOS_MAKE_DOD');

  /* По отмеченным спецификациям */
  for c in (select h.ncompany, h.sjur_pers, h.sord_doctype, h.sord_pref, h.sord_numb, h.dord_date, h.sacc_agent 
                   ,s.snomen, s.snom_modif, s.nmain_quant, s.numeas_main
                   ,rownum
               from selectlist sl, v_departmentords s, v_departmentord h
              where sl.ident = nIDENT
                and s.nrn    = sl.document
                and h.nrn    = s.nprn )
  loop
    /* Если первая запись в цикле */
    if c.rownum = 1 then

      /* RN каталога по параметру */
      find_acatalog_name(nflag_smart => 0
                        ,ncompany    => c.ncompany
                        ,nversion    => null
                        ,sunitcode   => 'UdoDepordDir'
                        ,sname       => sACATALOG
                        ,nrn         => nAcatalog);

      /* RN типа документа по параметру */
      find_doctypes_code(ncompany  => c.ncompany
                        ,sdoccode  => sDOC_TYPE_CODE
                        ,sunitcode => 'UdoDepordDir'
                        ,nstype    => 0
                        ,nrn       => nDoc_Type_Code);

      /* Последний номер в разделе */
      select max(t.doc_numb)
        into sDoc_Numb
        from udo_deporddir t
       where t.doc_type = nDoc_Type_Code
         and cmp_vc2(trim(t.doc_pref), sDOC_PREF) = 1;
       
      /* Расчёт следующего номера */
      pkg_document.next_number(sin => sDoc_Numb, ilength => 80, sout => sDoc_Numb);

      /* Контрагент текущего пользователя */
      find_clnpersons_authid_ex(ncompany     => c.ncompany
                               ,ddate        => current_date
                               ,spers_authid => utilizer
                               ,npers_agent  => nPers_Agent);

      /* Считывание контрагента текущего пользователя */
      rAgnList := usr_pkg_agnlist.agnlist_get(nrn => nPers_Agent);

      /* Добавление заголовка */
      udo_pkg_deporddir.dir_insert(ncompany          => c.ncompany
                                  ,ncrn              => nAcatalog
                                  ,sjur_pers_code    => c.sjur_pers
                                  ,sdoc_type_code    => sDoc_Type_Code
                                  ,sdoc_pref         => sDoc_Pref
                                  ,sdoc_numb         => sDoc_Numb
                                  ,ddoc_date         => dDoc_Date
                                  ,sord_doctype_code => c.sord_doctype
                                  ,sord_pref         => c.sord_pref
                                  ,sord_numb         => c.sord_numb
                                  ,sresp_agent_code  => rAgnList.agnabbr /*c.sacc_agent*/
                                  ,scard_numb        => null
                                  ,dcard_date        => null
                                  ,sreason           => sREASON
                                  ,sbasis            => sBASIS
                                  ,snote             => sNOTE
                                  ,sbarcode          => null
                                  ,ncopy_ordsp       => 0
                                  ,ndup_rn           => null
                                  ,nrn               => nDepartmentOrd);
    end if;

    /* Добавление спецификаций */
    udo_pkg_deporddir.sp_insert(ncompany         => c.ncompany
                               ,nprn             => nDepartmentOrd
                               ,snumb            => c.rownum
                               ,nkind            => 0 /* Вид изменения: Изменить */
                               ,snomen_code      => c.snomen
                               ,smodif_code      => c.snom_modif
                               ,nqnt             => c.nmain_quant
                               ,snomen_chng_code => null /*c.snomen*/
                               ,smodif_chng_code => null /*c.snom_modif */
                               ,nqnt_chng        => null /*c.nmain_quant */
                               ,ncoeff_chng      => null
                               ,nqnt_mainmeas    => null /* c.numeas_main */
                               ,sresp_agent_code => null
                               ,nanalog          => null
                               ,nd28             => null
                               ,nsign_permcard   => null
                               ,snote            => null
                               ,nrn              => nNumber);
  end loop;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_DPOS_MAKE_DOD;
/
