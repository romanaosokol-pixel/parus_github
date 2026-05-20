create or replace procedure usr_p_contr_modify_clc(nrn in number
                                                   -- ,ncompany      in number
                                                  ,sdoctype_code  in varchar2
                                                  ,sdoc_pref      in varchar2
                                                  ,sdoc_nmb       in varchar2
                                                  ,ddoc_date      in date --- Это дата регистрации!
                                                  ,ddoc_beg       in date
                                                  ,ddoc_end       in date
                                                  ,ddoc_conf      in date
                                                  ,dclose_date    in date
                                                  ,nsumm          in number
                                                  ,scurr          in varchar2
                                                  ,sdoc_extnumb   in varchar2
                                                  ,pin_otv_ek     in varchar2
                                                  ,sigk           in varchar2
                                                  ,sdoc_agn       in varchar2
                                                  ,sdoc_agncode   in varchar2
                                                  ,sacc           in varchar2
                                                  ,sacc_code      in varchar2
                                                  ,sdoc_subject   in varchar2
                                                  ,spbu_code      in varchar2
                                                  ,svid_dog       in varchar2
                                                  ,nsum_type      in number
                                                  ,nautocalc_sign in number
                                                   
                                                  ,is_ok out number) is

  v_sdoctype_code  varchar2(40);
  v_sdoc_pref      contracts.doc_pref%type;
  v_sdoc_nmb       contracts.doc_numb%type;
  v_ddoc_date      date;
  v_sdoc_extnumb   varchar2(80);
  v_ddoc_beg       date;
  v_ddoc_end       date;
  v_dclose_date    date;
  v_ddoc_conf      date;
  v_sdoc_subject   varchar2(2000);
  v_sdoc_agn       varchar2(40);
  v_sdoc_agncode   varchar2(40);
  v_nsumm          number(15, 2);
  v_scurr          varchar2(40);
  v_sacc           varchar2(40);
  v_sacc_code      varchar2(40);
  v_sigk           varchar2(40);
  v_pin_otv_ek     varchar2(40);
  v_spbu_code      varchar2(80);
  v_svid_dog       varchar2(80);
  v_nsum_type      number(1);
  v_nautocalc_sign number(1);

begin
  begin
    select dt.doccode
          ,trim(dog.doc_pref)
          ,trim(dog.doc_numb)
          ,dog.reg_date
          ,dog.ext_number
          ,dog.begin_date
          ,dog.end_date
          ,dog.confirm_date
          ,dog.close_date
          ,dog.subject
          ,my.agnabbr
          ,mya.strcode
          ,dog.doc_sumtax
          ,vl.intcode
          ,ag.agnabbr
          ,aga.strcode
          ,igk.code
          ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 1082887, sunitcode => 'Contracts', ndocument => dog.rn) /*Свойство "Сотрудник" */
          ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 1076177, sunitcode => 'Contracts', ndocument => dog.rn) /*Свойство "Шифр_поБУ" */
          ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 45150801, sunitcode => 'Contracts', ndocument => dog.rn) /*Свойство "УМТС_ВидДоговора" */
          ,dog.sum_type
          ,dog.autocalc_sign
      into v_sdoctype_code
          ,v_sdoc_pref
          ,v_sdoc_nmb
          ,v_ddoc_date
          ,v_sdoc_extnumb
          ,v_ddoc_beg
          ,v_ddoc_end
          ,v_ddoc_conf
          ,v_dclose_date
          ,v_sdoc_subject
          ,v_sdoc_agn
          ,v_sdoc_agncode
          ,v_nsumm
          ,v_scurr
          ,v_sacc
          ,v_sacc_code
          ,v_sigk
          ,v_pin_otv_ek
          ,v_spbu_code
          ,v_svid_dog
          ,v_nsum_type
          ,v_nautocalc_sign
    
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

  if
  
   cmp_vc2(sdoctype_code, v_sdoctype_code) = 0
   or cmp_vc2(sdoc_pref, v_sdoc_pref) = 0
   or cmp_vc2(sdoc_nmb, v_sdoc_nmb) = 0
   or cmp_dat(ddoc_date, v_ddoc_date) = 0
   or cmp_vc2(sdoc_extnumb, v_sdoc_extnumb) = 0
   or cmp_dat(ddoc_beg, v_ddoc_beg) = 0
   or cmp_dat(ddoc_end, v_ddoc_end) = 0
   or cmp_dat(ddoc_conf, v_ddoc_conf) = 0
   or cmp_dat(dclose_date, v_dclose_date) = 0
   or cmp_vc2(sdoc_subject, v_sdoc_subject) = 0
   or cmp_vc2(sdoc_agn, v_sdoc_agn) = 0
   or cmp_vc2(sdoc_agncode, v_sdoc_agncode) = 0
   or cmp_num(nsumm, v_nsumm) = 0
   or cmp_vc2(scurr, v_scurr) = 0
   or cmp_vc2(sacc, v_sacc) = 0
   or cmp_vc2(sacc_code, v_sacc_code) = 0
   or cmp_vc2(sigk, v_sigk) = 0
   or cmp_vc2(spbu_code, v_spbu_code) = 0
   or cmp_vc2(svid_dog, v_svid_dog) = 0
   or cmp_vc2(pin_otv_ek, v_pin_otv_ek) = 0
   or cmp_num(nsum_type, v_nsum_type) = 0
   or cmp_num(nautocalc_sign, v_nautocalc_sign) = 0
  
  then
    is_ok := 1;
  
  else
    is_ok := 0;
  end if;

end;
/
