create or replace procedure usr_p_faceacc_replace_cre2_clc
(
  pin_doc       in fcroutlstsp.rn%type
 ,pin_com       in fcroutlstsp.company%type
 ,pin_doc_type  in doctypes.doccode%type
 ,pin_doc_pref  in udo_faceacc_replace.docpref%type
 ,out_doc_nmb   out udo_faceacc_replace.docnumb%type
 ,out_doc_date  out udo_faceacc_replace.docdate%type
 ,pin_face_from in faceacc.numb%type
 ,pin_face_to   in faceacc.numb%type
 ,out_txt_err   out varchar2
  
) is

  v_jp_code jurpersons.code%type;
  sCONTAINER constant PKG_STD.tSTRING := 'UDO_CONTCACHE_DELIVSH'; -- Имя контейнера
  nrn FCDELIVSH.rn%type:= PKG_CONTCACHE.GETN(sCONTAINER, 'DELIVSHSP_PRN', false); -- RN  Комплектовочной ведомости

begin
  out_doc_date := trunc(sysdate);

  begin
    --- Найдем юридическое лицо
  
   select J.CODE
   into v_jp_code
      from  FCDELIVSH KV
      join jurpersons J on J.rn = KV.JUR_PERS
      where KV.RN = nrn;
  
  end;
  --- Найдем номер документа перенос
  udo_p_faceacc_replace_getnextn(pin_com, v_jp_code, pin_doc_type, pin_doc_pref, out_doc_nmb);

  if pin_face_from = pin_face_to then
    out_txt_err := 'Лицевой счет "Откуда" совпадает с лицевым счетом "Куда".';
  else
    out_txt_err := '';
  end if;

end;
/
