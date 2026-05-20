create or replace procedure usr_p_faceacc_replace_cre1_clc
(
  pin_doc      in fcroutlstsp.rn%type
 ,pin_com      in fcroutlstsp.company%type
 ,pin_doc_type in doctypes.doccode%type
 ,pin_doc_pref in udo_faceacc_replace.docpref%type
 ,out_doc_nmb  out udo_faceacc_replace.docnumb%type
 ,out_doc_date out udo_faceacc_replace.docdate%type
  
) is

  v_jp_code jurpersons.code%type;

begin
  out_doc_date := trunc(sysdate);

  begin
    --- Найдем юридическое лицо
  
    select jp.code
      into v_jp_code
      from udo_v_depordsbuf_supply_rsrv gp
      join departmentords zps
        on zps.nom_modif = gp.nnommodif
       and zps.company = gp.company
      join udo_depordsbuf bf
        on bf.depords = zps.rn
       and bf.authid = utilizer
      join jurpersons jp
        on jp.rn = gp.njurpers
     where gp.rn = pin_doc;
  
  end;
--- Найдем номер документа перенос
  udo_p_faceacc_replace_getnextn(pin_com, v_jp_code, pin_doc_type, pin_doc_pref, out_doc_nmb);

end;
/
