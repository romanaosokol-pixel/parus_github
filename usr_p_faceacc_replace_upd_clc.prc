create or replace procedure usr_p_faceacc_replace_upd_clc
(
  nrn                   in number
 ,in_faceacc_to         in varchar2
 ,in_fcdelivsh_to       in number
 ,in_param              in varchar2 --- Изменяемый парметр
 ,out_fcdelivsh_to      out number
 ,out_fcdelivsh_to_vis  out number
 ,out_fcdel_doc_to_vis  out number
 ,out_fcdel_prf_to_vis  out number
 ,out_fcdel_nmb_to_vis  out number
 ,out_fcdel_date_to_vis out number
 ,out_matres_to         out varchar2
 ,out_fcdel_doc_to      in out varchar2
 ,out_fcdel_prf_to      in out varchar2
 ,out_fcdel_nmb_to      in out varchar
 ,out_fcdel_date_to     in out date
 ,out_ord_rn_vis        out number
 ,out_ord_doc_type_vis  out number
 ,out_ord_prf_vis       out number
 ,out_ord_nmb_vis       out number
 ,out_ord_date_vis      out number
 ,out_ord_rn            in out number -- in out чтоб не обнулялось при изменении других полей
 ,out_ord_doc_type      in out varchar2
 ,out_ord_prf           in out varchar2
 ,out_ord_nmb           in out varchar2
 ,out_ord_date          in out date
 ,out_zp_rn_vis         out number
 ,out_zp_doc_type_vis   out number
 ,out_zp_prf_vis        out number
 ,out_zp_nmb_vis        out number
 ,out_zp_date_vis       out number
 ,out_zp_rn             in out number
 ,out_zp_doc_type       in out varchar2
 ,out_zp_prf            in out varchar2
 ,out_zp_nmb            in out varchar2
 ,out_zp_date           in out date
 ,out_fc_txt_vis        out number
 ,out_ord_txt_vis       out number
 ,out_zp_txt_vis        out number
 ,out_err_txt           out varchar2
 ,pout_is_ok            out number
) is
  ---grant execute on  usr_f_faceacc_replace_ins_clc to public;
begin
  ---if user = 'GOR' then P_exception(0,'46 '|| in_param); end if;
  begin
    -- Если лицевой счет (Куда) заполнен, то можно заполнить и комплектовочную ведомость
    select t.fcdelivsh into out_fcdelivsh_to from udo_faceacc_replace t where t.rn = nrn;
  exception
    when no_data_found then
      out_fcdelivsh_to := null;
  end;
  out_err_txt := null;
  if in_faceacc_to is not null
  then
    out_fcdelivsh_to_vis  := 1;
    out_fcdel_doc_to_vis  := 1;
    out_fcdel_prf_to_vis  := 1;
    out_fcdel_nmb_to_vis  := 1;
    out_fcdel_date_to_vis := 1;
    out_ord_rn_vis        := 1;
    out_ord_doc_type_vis  := 1;
    out_ord_prf_vis       := 1;
    out_ord_nmb_vis       := 1;
    out_ord_date_vis      := 1;
    out_zp_rn_vis         := 1;
    out_zp_doc_type_vis   := 1;
    out_zp_prf_vis        := 1;
    out_zp_nmb_vis        := 1;
    out_zp_date_vis       := 1;
    out_fc_txt_vis        := 1;
    out_ord_txt_vis       := 1;
    out_zp_txt_vis        := 1;
    if coalesce(out_zp_rn, out_ord_rn, in_fcdelivsh_to) is null
    then
      out_err_txt := 'Обязательно укажите хотя бы одно из: "Комплектовочную ведомость", "Заказ на производство", "Заказ подразделений" на который осуществляется перенос.';
      pout_is_ok  := 0;
    else
      out_err_txt := null;
      pout_is_ok  := 1;
    end if;
    if in_param = 'SFACEACC_TO_CODE'
    then
      -- Если лицевой счет (Куда) Изменен, то обнулим значения 
      out_fcdelivsh_to  := null;
      out_fcdel_doc_to  := null;
      out_fcdel_prf_to  := null;
      out_fcdel_nmb_to  := null;
      out_fcdel_date_to := null;
      out_matres_to     := null;
      out_ord_rn        := null;
      out_ord_doc_type  := null;
      out_ord_prf       := null;
      out_ord_nmb       := null;
      out_ord_date      := null;
      out_zp_rn         := null;
      out_zp_doc_type   := null;
      out_zp_prf        := null;
      out_zp_nmb        := null;
      out_zp_date       := null;
      out_err_txt       := 'Обязательно укажите хотя бы одно из: "Комплектовочную ведомость", "Заказ на производство", "Заказ подразделений" на который осуществляется перенос.';
      pout_is_ok        := 0;
      --- if user = 'GOR' then P_exception(0,'109 '|| in_param||' '||out_err_txt); end if;
    else
      begin
        select kv.rn
              ,dt.doccode
              ,trim(kv.pref)
              ,trim(kv.numb)
              ,kv.docdate
              ,mr.name
          into out_fcdelivsh_to
              ,out_fcdel_doc_to
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
          out_fcdelivsh_to := null;
          out_matres_to    := null;
      end;
    end if;
  else
    out_fcdelivsh_to_vis  := 0;
    out_fcdel_doc_to_vis  := 0;
    out_fcdel_prf_to_vis  := 0;
    out_fcdel_nmb_to_vis  := 0;
    out_fcdel_date_to_vis := 0;
    out_ord_rn_vis        := 0;
    out_ord_doc_type_vis  := 0;
    out_ord_prf_vis       := 0;
    out_ord_nmb_vis       := 0;
    out_ord_date_vis      := 0;
    out_zp_rn_vis         := 0;
    out_zp_doc_type_vis   := 0;
    out_zp_prf_vis        := 0;
    out_zp_nmb_vis        := 0;
    out_zp_date_vis       := 0;
    out_fc_txt_vis        := 0;
    out_ord_txt_vis       := 0;
    out_zp_txt_vis        := 0;
    out_err_txt           := null;
    pout_is_ok            := 0;
  end if;
end;
/
