create or replace procedure usr_p_contracts_cl_date_modif(nrn              in number
                                                         ,dclose_date      in date
                                                         ,ddog_date        in date
                                                         ,pin_ext_nmb      in varchar2
                                                         ,pin_dog_typ      in varchar2
                                                         ,pin_dog_prf      in varchar2
                                                         ,pin_dog_nmb      in varchar2
                                                         ,pin_confirm_date in date) is
begin
/* Исправленеи договора 
Городецкий 2026-04-20 
*/


  for cur in (select dog.close_date
                    ,dog.status
                    ,dog.doc_date
                    ,dog.reg_date
                    ,dog.ext_number
                    ,dt.doccode
                    ,dog.confirm_date
                    ,dt.rn dog_typ_rn
                    ,trim(dog.doc_pref) pref
                    ,trim(dog.doc_numb) numb
                from contracts dog
                join doctypes dt
                  on dt.rn = dog.doc_type
               where dog.rn = nrn)
  loop
    /* Только для уже закрытого договора, можно изменить дату закрытиия, но не обнулить её */
    if cur.status = 2
       and cmp_dat(cur.close_date, dclose_date) = 0
       and dclose_date is not null
    then
      update contracts d
         set d.close_date = dclose_date
       where d.rn = nrn;
    end if;
    /* 
    Исправляем дату договора, но не даем ее обнулить.  
    Дата договора хранится у нас в и дате регистрации! так решили в ПЭО
    */
    if (cmp_dat(cur.doc_date, ddog_date) = 0 or cmp_dat(cur.reg_date, ddog_date) = 0)
       and ddog_date is not null
    then
      update contracts d
         set d.doc_date = ddog_date
            ,d.reg_date = ddog_date
       where d.rn = nrn;
    end if;
    if cmp_vc2(pin_ext_nmb, cur.ext_number) = 0
       and pin_ext_nmb is not null /*Обнулить не дадим */
    then
      update contracts d
         set d.ext_number = pin_ext_nmb
       where d.rn = nrn;
    end if;
    if cmp_vc2(pin_dog_typ, cur.doccode) = 0
       or cmp_vc2(pin_dog_prf, cur.pref) = 0
       or cmp_vc2(pin_dog_nmb, cur.numb) = 0
    then
      update contracts d
         set d.doc_type = cur.dog_typ_rn
            ,d.doc_pref = lpad(pin_dog_prf, 80, ' ')
            ,d.doc_numb = lpad(pin_dog_nmb, 80, ' ')
       where d.rn = nrn;
    end if;
    if cmp_dat(cur.confirm_date, pin_confirm_date) = 0
       and pin_confirm_date is not null
    then
      update contracts dog
         set dog.confirm_date = pin_confirm_date
       where dog.rn = nrn;
    end if;
  end loop;
end;
/
