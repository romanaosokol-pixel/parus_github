create or replace procedure usr_p_faceacc_replace_cre2_ini(pin_doc              in goodsparties.rn%type
                                                          ,pin_com              in goodsparties.company%type
                                                          ,pin_unit             in varchar2 /*Код раздела из которого вызвана процедура*/
                                                          ,pin_doc_type         out doctypes.doccode%type
                                                          ,pin_doc_pref         out udo_faceacc_replace.docpref%type
                                                          ,out_doc_nmb          out udo_faceacc_replace.docnumb%type
                                                          ,out_doc_date         out udo_faceacc_replace.docdate%type
                                                          ,out_face_from_sql    out varchar2 -- Запрос для выбора ЛС
                                                          ,out_face_from_def    out varchar2 -- Первый попавшийся ЛС из выборки
                                                          ,out_face_to          out varchar2 -- Лицевой счет из заказа подразделений
                                                          ,out_txt_err          out varchar2 -- Сообщение об ошибках
                                                          ,out_jur              out varchar2 -- Юр. Лицо
                                                          ,out_q                out number -- Передаваемое количество
                                                          ,out_q_tech_lpm       out number -- Количество на тех нужды
                                                          ,out_vis_q_tech_lpm   out number -- Признак доступности Количество на тех нужды
                                                          ,out_txt_q_tech_lpm   out varchar2 --Текст  Признак доступности Количество на тех нужды
                                                          ,out_prz_q_tech_lpm   in out number -- Значение признака Тех нужды ЛПМ
                                                          ,out_vis_prz_tech_lpm out number -- Видимость признака Тех нужды ЛПМ
                                                          ,out_depart           out number --- RN Заказа подразделений
                                                          ,ord_doc_type         out varchar2 --- Тип заказа подразделения Куда
                                                          ,ord_doc_pref         out varchar2 -- Префикс заказа подразделения Куда
                                                          ,ord_doc_nmb          out varchar2 -- Номер заказа подразделения Куда
                                                          ,ord_doc_date         out date --Дата заказа подразделения Куда
                                                           
                                                          ,out_kv_doc_type  out varchar2
                                                          ,out_kv_doc_pref  out varchar2
                                                          ,out_kv_doc_nmb   out varchar2
                                                          ,out_kv_doc_date  out date
                                                          ,out_fcdelivsh_to out number
                                                          ,out_note         out varchar2
                                                           
                                                           ) is

  v_jp_code jurpersons.code%type;
  scontainer constant pkg_std.tstring := 'UDO_CONTCACHE_DELIVSH'; -- Имя контейнера
  nrn fcdelivsh.rn%type := pkg_contcache.getn(scontainer, 'DELIVSHSP_PRN', false); -- RN  Комплектовочной ведомости

begin
  out_doc_date := trunc(sysdate);
  pin_doc_type := 'Перенос';
  pin_doc_pref := to_char(extract(year from sysdate));

  begin
    select zk.numb
      into out_face_to
      from fcdelivsh kv
      join faceacc zk
        on zk.rn = kv.prod_order
     where kv.rn = nrn;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Процедура запускается только после переходв в раздел "Товарные запасы" из комплектовочной ведомости');
    
  end;

  --- Если тех нужды ЛПМ = 0, то признак "Включать тех нужды 

  if nvl(out_q_tech_lpm, 0) = 0
  then
  
    out_vis_q_tech_lpm   := 0;
    out_prz_q_tech_lpm   := 0;
    out_vis_prz_tech_lpm := 0;
    out_txt_q_tech_lpm   := '';
  
  else
  
    out_vis_q_tech_lpm   := 1;
    out_vis_prz_tech_lpm := 1;
    out_txt_q_tech_lpm   := 'Кол-во на тех. нужды';
  
  end if;

  --- Найдем номер документа перенос
  udo_p_faceacc_replace_getnextn(pin_com, v_jp_code, pin_doc_type, pin_doc_pref, out_doc_nmb);

  case pin_unit
    when 'GoodsSupply' then
    
      -- Запрос для выбора лицевых счетов  
      out_face_from_sql := 'select column_value  from TABLE(usr_f_goodssupply_faceacc(' || pin_doc || '))';
    
      begin
        select column_value
          into out_face_from_def
          from table(usr_f_goodssupply_faceacc(pin_doc))
         where rownum = 1;
      exception
        when no_data_found then
          out_face_from_def := null;
      end;
    
    when 'GoodsParties' then
    
      -- Запрос для выбора лицевых счетов  
      out_face_from_sql := 'select column_value  from TABLE(usr_f_gp_faceacc(' || pin_doc || '))';
    
      begin
        select column_value
          into out_face_from_def
          from table(usr_f_gp_faceacc(pin_doc))
         where rownum = 1;
      exception
        when no_data_found then
          out_face_from_def := null;
      end;
    
  end case;

  if out_face_from_def = out_face_to
  then
  
    out_txt_err := 'Лицевой счет "Откуда" совпадает с лицевым счетом "Куда".';
  else
    out_txt_err := '';
  end if;

  out_kv_doc_type  := null;
  out_kv_doc_pref  := null;
  out_kv_doc_nmb   := null;
  out_kv_doc_date  := null;
  out_fcdelivsh_to := null;

  ---if user = 'GOR' then P_exception(0, out_face_from_def||' '||out_face_from_sql||' '||PIN_DOC); end if;
end;
/
