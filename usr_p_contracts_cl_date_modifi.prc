create or replace procedure usr_p_contracts_cl_date_modifi(nrn             in number
                                                          ,out_dclose_date out date
                                                          ,out_dog_date    out date
                                                          ,out_vis_close_d out number
                                                          ,out_text        out varchar2
                                                          ,out_ext_nmb     out varchar2
                                                          ,out_doc_typ     out varchar2
                                                          ,out_doc_prf     out varchar2
                                                          ,out_doc_nmb     out varchar2
                                                          ,out_conf_date out date
                                                          ,out_vis_conf_date out number
                                                          
                                                          ) is
begin
  /*Инициализация процедуры Исправление договора */
  begin
    select case dog.status
             when 2 then
              1
             else
              0
           end
          ,dog.close_date
          ,dog.reg_date /*Дата договора в дате регистрации!*/
          ,dog.ext_number
          ,dt.doccode
          ,trim(dog.doc_pref)
          ,trim(dog.doc_numb)
          ,dog.confirm_date
          ,case dog.status
             when 0 then
              0
             else
              1
           end         
      into out_vis_close_d
          ,out_dclose_date
          ,out_dog_date
          ,out_ext_nmb
          ,out_doc_typ
          ,out_doc_prf
          ,out_doc_nmb
          ,out_conf_date
          ,out_vis_conf_date
      from contracts dog
      join doctypes dt
        on dt.rn = dog.doc_type
     where dog.rn = nrn;
  exception
    when no_data_found then
      out_vis_close_d := 0;
      out_vis_conf_date:=0;
      
  end;
  if out_vis_close_d = 0
  then
    out_text := 'Изменить дату закрытия можно только у договора в состоянии "Закрыт"';    
  end if;
  
end;
/
