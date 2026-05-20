create or replace procedure usr_p_contr_modify_ini(nrn            in number ---
                                                  ,sdoctype_code  out varchar2 ---
                                                  ,sdoc_pref      out varchar2 ---
                                                  ,sdoc_nmb       out varchar2 ---
                                                  ,ddoc_date      out date --- Это дата регистрации!
                                                  ,ddoc_beg       out date --
                                                  ,ddoc_end       out date --
                                                  ,dconf_date     out date ---
                                                  ,dclose_date    out date --
                                                  ,nsumm          out number --
                                                  ,scurr          out varchar2 --
                                                  ,sdoc_extnumb   out varchar2 --
                                                  ,pin_otv_ek     out varchar2 --
                                                  ,sigk           out varchar2 --
                                                  ,sdoc_agn       out varchar2 --- Мы
                                                  ,sdoc_agncode   out varchar2 -- Наши реквизиты
                                                  ,sacc           out varchar2 -- Контрагент
                                                  ,sacc_code      out varchar2 -- Реквизиты контрагента
                                                  ,sdoc_subject   out varchar2 --
                                                  ,spbu_code      out varchar2 -- ПБУ код, для договоров, не связанных с проектом по доклинкс (старые договора) 
                                                  ,svid_dog       out varchar2 -- Вид договора
                                                  ,nsum_type      out number  
                                                  ,nautocalc_sign out number
                                                  ,options_vis    out number /*Видеть закладку "Настройки" */
                                                  ,err_txt        out varchar2
                                                  ,is_ok          out number) is

begin
  begin
    select dt.doccode
          ,trim(dog.doc_pref)
          ,trim(dog.doc_numb)
          ,nvl(dog.reg_date, dog.doc_date)
          ,dog.begin_date
          ,dog.end_date
          ,dog.confirm_date
          ,dog.close_date
          ,dog.doc_sumtax
          ,vl.intcode
          ,dog.ext_number
          ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 1082887, sunitcode => 'Contracts', ndocument => dog.rn) /*Свойство "Сотрудник" */
          ,igk.code
          ,my.agnabbr
          ,mya.strcode
          ,ag.agnabbr
          ,aga.strcode
          ,dog.subject
          ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 1076177, sunitcode => 'Contracts', ndocument => dog.rn) /*Свойство "Шифр_поБУ" */
          ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 45150801, sunitcode => 'Contracts', ndocument => dog.rn) /*Свойство "УМТС. Вид договора" */
          ,dog.sum_type
          ,dog.autocalc_sign
      into sdoctype_code
          ,sdoc_pref
          ,sdoc_nmb
          ,ddoc_date
          ,ddoc_beg
          ,ddoc_end
          ,dconf_date
          ,dclose_date
          ,nsumm
          ,scurr
          ,sdoc_extnumb
          ,pin_otv_ek
          ,sigk
          ,sdoc_agn
          ,sdoc_agncode
          ,sacc
          ,sacc_code
          ,sdoc_subject
          ,spbu_code
          ,svid_dog
          ,nsum_type
          ,nautocalc_sign
      from contracts dog
      join doctypes dt
        on dt.rn = dog.doc_type
      join jurpersons j
        on j.rn = dog.jur_pers
      join agnlist my
        on my.rn = j.agent
      left join agnacc mya
        on mya.rn = dog.jur_acc
      join curnames vl
        on vl.rn = dog.currency
      join agnlist ag
        on ag.rn = dog.agent
      join agnacc aga
        on aga.rn = dog.agnacc
      left join govcntrid igk
        on igk.rn = dog.govcntrid
    
     where dog.rn = nrn;
  exception
    when no_data_found then
      p_exception(0, 'Процедура выполняется только из раздела "Договоры"!');
    
  end;
  is_ok   := 0; -- Пока ничего не поменяли, нечего и ОК жать!
  err_txt := '';

  begin
    begin
      select 1
        into options_vis
        from userroles ur
        join roles r
          on r.rn = ur.roleid
       where ur.authid = utilizer
         and r.rolename = 'Все права';
    exception
      when no_data_found then
        options_vis := 0;
    end;
  
  end;

end;
/
