create or replace procedure usr_p_gs_get_completed_docs
/*
  Товарные запасы
  Процедура возвращает текстовый список реквизитов расходных накладных в подразделения в статусе "Скомплектовано".
  21/10/2024 Степанов М.
  */
(
  nrn   in number
 ,sdocs out varchar2
  
)

 is
  v_res varchar2(2000); --- Примечание из события 
begin
  /* При вызове из раздела "Товарные запасы", вызванного из спецификации "Расходные накладные на отпуск в подразделения В процедуру передается реальные RN Goodssupply
  Городецкий 23-06-2025  
  */
  for c in (select pkg_document.make_number(ndoc_type => h.doctype
                                           ,sdoc_pref => h.pref
                                           ,sdoc_numb => h.numb
                                           ,ddoc_date => h.docdate) as sdoc
                  ,s.quant
                  ,h.rn
              from goodssupply       gs
                  ,transinvdeptspecs s
                  ,transinvdept      h
             where gs.rn in (f_goodssupply_by_rownum(nrownum => nrn)
                            ,nrn)
               and s.goodsparty = gs.prn
               and h.rn = s.prn
               and h.store = gs.store
               and usr_pkg_transinvdept.transinvdept_is_completed(nrn => h.rn) = 1)
  loop
    sdocs := strcombine(sdocs
                       ,c.sdoc || ', кол-во: ' || trim(n2sq(c.quant) || '.'));
  
    v_res := null;
  
    for cur in (select nh.note
                  from clnevnotes cn
                  join clnevnoteshist nh
                    on nh.prn = cn.rn
                 where cn.prn = usr_pkg_document.get_clnevents(nflagsmart => 1
                                                              ,nrn        => c.rn) ---  206464622
                )
    loop
    if cur.note is not null then 
      strconcat(sleft      => v_res
               ,sright     => cur.note
               ,sdelimiter => ';');
    end if;           
    
    end loop;
  
    sdocs := strcombine(sdocs
                       ,case
                          when v_res is not null then
                           ' ( ' || v_res || ' )'||cr
                          else
                           cr
                        end
                       );
  
  end loop;

end;
--GoodsSupply
/
