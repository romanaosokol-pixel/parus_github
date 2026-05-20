create or replace procedure USR_P_UM_SEL_PROC
/*
Раздел: Статусные модели разделов
Процедура подбора статусной модели (типа события)

Наименования параметров должны быть именно такими. 
*/
(
 nDOCUMENT      in number
,nCOMPANY       in number  
,sUNITCODE      in varchar2
,nEVENT_TYPE    out number /* CLNEVNTYPES */
)
is
  rDocument         usr_pkg_pub_const.tdoc_base_values_rec;
begin
  /* Считывание основных полей документа */
  rDocument := usr_pkg_document.get_base_values(nflagsmart => 0
                                               ,nrn        => nDOCUMENT
                                               ,ncompany   => nCOMPANY
                                               ,sunitcode  => sUNITCODE);
  /* Раздел */
  case sUNITCODE 

    /* Заказы на производство */
    when 'ProductionOrders' then

      /* В зависимости от каталога документа */
      if rDocument.ncrn = 170968741 then
        nEVENT_TYPE := 171221902;
      end if;

  else
    null;
  end case;

end;
/
