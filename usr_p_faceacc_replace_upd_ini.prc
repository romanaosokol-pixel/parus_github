create or replace procedure usr_p_faceacc_replace_upd_ini
(
  nrn                   in number
 ,in_fcdelivsh_to       in out number
 ,in_nproductord_to     in out number -- RN заказа на производства 
 ,in_ndepartmentord_to  in out number -- RN заказа подразделения  
 ,in_faceacc_to         in out varchar2
 ,out_fcdelivsh_to_vis  out number
 ,out_fcdel_doc_to_vis  out number
 ,out_fcdel_prf_to_vis  out number
 ,out_fcdel_nmb_to_vis  out number
 ,out_fcdel_date_to_vis out number
 ,out_matres_to         out varchar2
 ,out_fcdel_doc_to      out varchar2
 ,out_fcdel_prf_to      out varchar2
 ,out_fcdel_nmb_to      out varchar
 ,out_fcdel_date_to     out date
 ,out_depord_doc_to     out varchar2
 ,out_depord_prf_to     out varchar2
 ,out_depord_nmb_to     out varchar
 ,out_depord_date_to    out date
 ,out_zp_doc_to         out varchar2
 ,out_zp_prf_to         out varchar2
 ,out_zp_nmb_to         out varchar
 ,out_zp_date_to        out date
 ,out_err_txt out varchar2
 ,pout_is_ok  in out number
) is
  ---grant execute on  usr_f_faceacc_replace_ins_clc to public;
begin
  out_err_txt := null;
  ---P_exception(0, '28');
  if in_faceacc_to is not null
  then
    out_fcdelivsh_to_vis  := 1;
    out_fcdel_doc_to_vis  := 1;
    out_fcdel_prf_to_vis  := 1;
    out_fcdel_nmb_to_vis  := 1;
    out_fcdel_date_to_vis := 1;
    if coalesce(in_fcdelivsh_to, in_nproductord_to, in_ndepartmentord_to) is null
    then
      out_err_txt := 'Обязательно укажите хотя бы одно из: "Комплектовочную ведомость", "Заказ на производство", "Заказ подразделений" на который осуществляется перенос.';
      pout_is_ok  := 0;
    else
      out_err_txt := null;
      pout_is_ok  := 1;
      if in_fcdelivsh_to is not null
      then
        begin
          -- Если лицевой счет (Куда) заполнен, то можно заполнить и комплектовочную ведомость
          select dt.doccode
                ,trim(kv.pref)
                ,trim(kv.numb)
                ,kv.docdate
                ,mr.name
            into out_fcdel_doc_to
                ,out_fcdel_prf_to
                ,out_fcdel_nmb_to
                ,out_fcdel_date_to
                ,out_matres_to
            from fcdelivsh kv
            left join doctypes dt
              on dt.rn = kv.doctype
            left join fcmatresource mr
              on mr.rn = kv.matres
           where kv.rn = in_fcdelivsh_to;
        exception
          when no_data_found then
            out_fcdel_doc_to  := null;
            out_fcdel_prf_to  := null;
            out_fcdel_nmb_to  := null;
            out_fcdel_date_to := null;
            out_matres_to     := null;
        end;
      end if;
      /*Заказ на производство*/
      if in_nproductord_to is not null
      then
        begin
          select dt.doccode
                ,trim(zd.ord_pref)
                ,trim(zd.ord_numb)
                ,zd.ord_date
            into out_zp_doc_to
                ,out_zp_prf_to
                ,out_zp_nmb_to
                ,out_zp_date_to
            from productord zd
            join doctypes dt
              on dt.rn = zd.ord_doctype
           where zd.rn = in_nproductord_to;
        exception
          when no_data_found then
            out_zp_doc_to  := 'null';
            out_zp_prf_to  := null;
            out_zp_nmb_to  := null;
            out_zp_date_to := null;
        end;
      end if;
      /* Заказ подразделений */
      if in_ndepartmentord_to is not null
      then
        begin
          select dt.doccode
                ,trim(zdep.ord_pref)
                ,trim(zdep.ord_numb)
                ,zdep.ord_date
            into out_depord_doc_to
                ,out_depord_prf_to
                ,out_depord_nmb_to
                ,out_depord_date_to
            from departmentord zdep
            join doctypes dt
              on dt.rn = zdep.ord_doctype
           where zdep.rn = in_ndepartmentord_to;
        exception
          when no_data_found then
            out_depord_doc_to  := null;
            out_depord_prf_to  := null;
            out_depord_nmb_to  := null;
            out_depord_date_to := null;
        end;
      end if;
      /* if user = 'GOR'
      then
        p_exception(0, out_zp_doc_to);
      end if;*/
    end if;
  else
    out_fcdelivsh_to_vis  := 0;
    out_fcdel_doc_to_vis  := 0;
    out_fcdel_prf_to_vis  := 0;
    out_fcdel_nmb_to_vis  := 0;
    out_fcdel_date_to_vis := 0;
  end if;
end;
/
