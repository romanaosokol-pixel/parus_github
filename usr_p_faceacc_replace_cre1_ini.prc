create or replace procedure usr_p_faceacc_replace_cre1_ini
(
  pin_doc           in fcroutlstsp.rn%type
 ,pin_com           in fcroutlstsp.company%type
 ,pin_doc_type      in doctypes.doccode%type
 ,pin_doc_pref      in udo_faceacc_replace.docpref%type
 ,out_doc_nmb       out udo_faceacc_replace.docnumb%type
 ,out_doc_date      out udo_faceacc_replace.docdate%type
 ,out_face_from_sql out varchar2 -- Запрос для выбора ЛС
 ,out_face_from_def out varchar2 -- Первый попавшийся ЛС из выборки
 ,out_face_to       out varchar2 -- Лицевой счет из заказа подразделений
 ,OUT_TXT_ERR       out varchar2 -- Сообщение об ошибках
 ,out_JUR           out varchar2 -- Юр. Лицо
 ,out_Q             out number  -- Передаваемое количество
 ,OUT_Q_TECH_LPM  out number       -- Количество на тех нужды
 ,OUT_VIS_Q_TECH_LPM  out number       -- Признак доступности Количество на тех нужды
 ,OUT_TXT_Q_TECH_LPM  out varchar2       --Текст  Признак доступности Количество на тех нужды
 ,OUT_PRZ_Q_TECH_LPM in out number -- Значение признака Тех нужды ЛПМ
 ,OUT_VIS_PRZ_TECH_LPM out number -- Видимость признака Тех нужды ЛПМ
 ,out_DEPART    out number --- RN Заказа подразделений
 ,ORD_DOC_TYPE  out varchar2 --- Тип заказа подразделения Куда
 ,ORD_DOC_PREF  out varchar2 -- Префикс заказа подразделения Куда
 ,ORD_DOC_NMB   out varchar2 -- Номер заказа подразделения Куда
 ,ORD_DOC_DATE  out date  --Дата заказа подразделения Куда
 
 ,out_kv_doc_type out varchar2
 ,OUT_KV_DOC_PREF out varchar2
 ,OUT_KV_DOC_NMB out varchar2
 ,OUT_KV_DOC_DATE out date
 ,OUT_FCDELIVSH_TO out number
 ,out_NOTE   out varchar2 
 
  
) is

  v_jp_code jurpersons.code%type;

begin
  out_doc_date := trunc(sysdate);

  begin
    --- Найдем юридическое лицо
  
    select jp.code
          ,zpf.numb
          ,JP.CODE
          ,GP.NSALE
          ,ZP.rn
          , trim(ZP.ORD_PREF)
          , trim(ZP.ORD_NUMB)
          ,ZDT.DOCCODE  
          ,ZP.Ord_Date        
          ,UDO_F_DEPORDS_IN_MATRES(nRN => zps.rn)  
          ,(select DV.NUM_VALUE
     from FCMATRESOURCE MR,
          DOCS_PROPS_VALS DV
     where MR.NOMEN_MODIF = gp.nnommodif
       and DV.UNIT_RN = MR.RN
       and DV.DOCS_PROP_RN = 157488441) -- ТехН_ЛПМ                  
      into v_jp_code
          ,out_face_to
          ,out_JUR
          ,OUT_Q
          ,out_DEPART
          ,ORD_DOC_PREF          
          ,ORD_DOC_NMB
          ,ORD_DOC_TYPE
          ,ORD_DOC_DATE
          ,out_NOTE
          ,OUT_Q_TECH_LPM
      from udo_v_depordsbuf_supply_rsrv gp
      join departmentords zps
        on zps.nom_modif = gp.nnommodif
       and zps.company = gp.company
      join udo_depordsbuf bf
        on bf.depords = zps.rn
       and bf.authid = utilizer
      join jurpersons jp
        on jp.rn = gp.njurpers
      join departmentord zp
        on zp.rn = zps.prn
      join faceacc zpf
        on zpf.rn = zp.faceacc
      join departmentord ZP on zp.rn = ZPS.prn 
      join doctypes ZDT on ZDT.RN = ZP.Ord_Doctype
             
     where gp.rn = pin_doc;
  
  end;
  
  --- Если тех нужды ЛПМ = 0, то признак "Включать тех нужды 
  
  if nvl(OUT_Q_TECH_LPM,0) = 0 then 

   OUT_VIS_Q_TECH_LPM :=0;
   OUT_PRZ_Q_TECH_LPM :=0;
   OUT_VIS_PRZ_TECH_LPM := 0;
   OUT_TXT_Q_TECH_LPM :='';
   
   else
   
   OUT_VIS_Q_TECH_LPM :=1;
   OUT_VIS_PRZ_TECH_LPM := 1;
   OUT_TXT_Q_TECH_LPM :='Кол-во на тех. нужды';
  
   end if;
  
  --- Найдем номер документа перенос
  udo_p_faceacc_replace_getnextn(pin_com, v_jp_code, pin_doc_type, pin_doc_pref, out_doc_nmb);

  --- Запрос для выбора лицевых счетов  
  out_face_from_sql := 'select column_value  from TABLE(usr_f_goodssupply_faceacc(' || pin_doc || '))';

  select column_value
    into out_face_from_def
    from table(usr_f_goodssupply_faceacc(pin_doc))
   where rownum = 1;
   
 if  out_face_from_def = out_face_to then 
   
   OUT_TXT_ERR  :='Лицевой счет "Откуда" совпадает с лицевым счетом "Куда".';
 else
   OUT_TXT_ERR  :='';
 end if;  
 
 /*begin  \*Покажем заказ подразделений на который был перенос в последний раз по данной комбинации лицевых счетов.*\
 select dt.doccode
     \* ,trim(dp.ord_pref)
      ,trim(dp.ord_numb)
      ,dp.ord_date*\
      into ORD_DOC_TYPE 
           \*,ORD_DOC_PREF 
           ,ORD_DOC_NMB  
           ,ORD_DOC_DATE *\
  from udo_faceacc_replace t
  left join departmentord dp
    on dp.rn = t.depord
  left join doctypes dt
    on dt.rn = dp.ord_doctype

 where t.faceacc_to = out_face_to
   and t.faceacc_from = out_face_from_def
   and t.rn = (select max(tt.rn)
                 from udo_faceacc_replace tt
                where tt.faceacc_to = out_face_to
                  and tt.faceacc_from = out_face_from_def);
     exception when no_data_found then null;             
                  
  end ;       */         

 
 


out_kv_doc_type :=null;
OUT_KV_DOC_PREF :=null;
OUT_KV_DOC_NMB  :=null;
OUT_KV_DOC_DATE :=null;   
OUT_FCDELIVSH_TO :=null;


end;
/
