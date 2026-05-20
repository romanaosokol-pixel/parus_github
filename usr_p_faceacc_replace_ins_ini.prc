create or replace procedure usr_p_faceacc_replace_ins_ini
(
  in_faceacc_to         in varchar2
 ,pin_zp_rn             in number
 ,pin_ord_rn            in number
 ,pin_fcdel_rn          in number
 ,out_fcdelivsh_to_vis  out number
 ,out_fcdel_doc_to_vis  out number
 ,out_fcdel_prf_to_vis  out number
 ,out_fcdel_nmb_to_vis  out number
 ,out_fcdel_date_to_vis out number
 ,out_ord_rn_vis        out number
 ,out_ord_doc_type_vis  out number
 ,out_ord_prf_vis       out number
 ,out_ord_nmb_vis       out number
 ,out_ord_date_vis      out number
 ,out_zp_rn_vis         out number
 ,out_zp_doc_type_vis   out number
 ,out_zp_prf_vis        out number
 ,out_zp_nmb_vis        out number
 ,out_zp_date_vis       out number
 ,out_fc_txt_vis        out number
 ,out_ord_txt_vis       out number
 ,out_zp_txt_vis        out number
 ,out_err_txt out varchar2
 ,pout_is_ok  in out number
) is
  ---grant execute on  usr_f_faceacc_replace_ins_clc to public;
begin
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
    if coalesce(pin_zp_rn, pin_ord_rn, pin_fcdel_rn) is null
    then
      out_err_txt := 'Обязательно укажите хотябы одно из: "Комплектовочную ведомость", "Заказ на производство", "Заказ подразделений" на который осуществляется перенос.';
      pout_is_ok  := 0;
    else
      out_err_txt := null;
      pout_is_ok  := 1;
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
    pout_is_ok            := 0;
  end if;
end;
/
