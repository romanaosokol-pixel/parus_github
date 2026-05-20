create or replace procedure UDO_P_TRANSINVDEPT_DLT_STRJRN
(
  nRN                         in number -- Рег. номер РН
) is
/*
  Процедура удаления распределний по местам хранения при удалении заголовка РН 
  
  grant execute on UDO_P_TRANSINVDEPT_DLT_STRJRN to public;
*/
begin  
  /* Удаление распределения по местам хранения, связанным с РН */
  for lnk in (select *
                from STRPLRESJRNL t
               where exists (select null
                               from V_DOCLINKS_INOUT_IN_EXT DLIN,
                                    transinvdeptspecs ts
                              where ts.prn= UDO_P_TRANSINVDEPT_DLT_STRJRN.nRN 
                                and DLIN.NIN_DOCUMENT = ts.rn
                                and DLIN.SIN_UNITCODE = 'GoodsTransInvoicesToDeptsSpecs'
                                and DLIN.NDOCUMENT = t.RN))
  loop                       
    P_STRPLRESJRNL_BASE_DELETE(nCOMPANY => lnk.company, nRN => lnk.rn);
  end loop; 
end ;
/

