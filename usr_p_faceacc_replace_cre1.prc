create or replace procedure usr_p_faceacc_replace_cre1

  /* Создание переноса между темами из строки партии, доступной для резервирования, буфера формирования Заказы подразделений (спецификация) */
(
  pin_com          in companies.rn%type --- := 90521;
 ,pin_doc          in udo_v_depordsbuf_supply_rsrv.rn%type ---:=16874759; -- Создается динамически при формировании буфера ---GOODSSUPPLY.rn%type := 167391549; --- оно же UDO_DEPORDSBUF.PRN%type;   ТехПаспорт, 2025-50, 24.02.2025 (167391549)
 ,pin_cat          in acatalog.name%type -- := 'ОМТС';
 ,pin_doc_type     in doctypes.doccode%type --:= 'Перенос' --( ссылка UDO_FACEACC_REPLACE.DOCTYPE )
 ,pin_doc_pref     in udo_faceacc_replace.docpref%type --:= '2025';
 ,pin_doc_nmb      in udo_faceacc_replace.docnumb%type
 ,pin_doc_date     in udo_faceacc_replace.docdate%type --:= trunc(sysdate);
 ,pin_valid_doc    in udo_faceacc_replace.valid_doc%type --:= 'Документ основания';  
 ,pin_faceacc_from in faceacc.numb%type --:= '12124/1';
 ,pin_faceacc_to   in faceacc.numb%type --:= '80028/2';
 ,pin_fcdelivsh_to in fcdelivsh.rn%type --:= 157826388; -- Комплектовочны ведомости (указываем КУДА, на какое конкретно изделие, снимаем)
 ,pin_note         in udo_faceacc_replace.note%type -- := 'Заведено процедурой'
 ,pin_kv_doc_type  in varchar2 -- Параметры дл яотображения на форме характеристик комплектовочной ведомости
 ,pin_kv_doc_pref  in varchar2
 ,pin_kv_doc_nmb   in varchar2
 ,pin_kv_doc_date  in date
 ,pin_kv_izd_name  in varchar2
 ,pin_jur          in varchar2 --- Принадлежность
 ,pin_depart       in number -- RN Заказа подразделений
 ,pin_prod         in number -- RN Заказа на производство
 ,pin_q            in number --- Количество для переноса
 ,pin_IN_TECH_LPM  in number ---  Признак "Включать количество на нужды ЛПМ" 
 ,PIN_Q_TECH_LPM   in number --- Количество на тех нужды ЛПМ
  /* Поля нужны для размещения на форме, т.к. реализовано не действием, а пользовательской процедурой*/
 ,ord_doc_type in varchar2
 ,ord_doc_pref in varchar2
 ,ord_doc_nmb  in varchar2
 ,ord_doc_date in date
 ,zp_doc_type  in varchar2
 ,zp_doc_pref  in varchar2
 ,zp_doc_nmb   in varchar2
 ,zp_doc_date  in date
  
) is

  v_gp_rn goodsparties.rn%type;

  v_crn     udo_faceacc_replace.crn%type; -- Перенос между темами
  v_nrn     udo_faceacc_replace.rn%type;
  v_nrn1    udo_faceacc_replace_sp.rn%type;
  v_numb    udo_faceacc_replace.docnumb%type;
  v_jp_code jurpersons.code%type;
  
  V_Q_LPM  number(15,2):= case pin_IN_TECH_LPM when 1 then  nvl(PIN_Q_TECH_LPM,0) else 0 end;

begin

/*Городецкий О.И. Перенос между темами из буфера резервирования Заказа подразделений */

  begin
    begin
      select gp.ngoodsparties
            ,jp.code
        into v_gp_rn
            ,v_jp_code
        from udo_depordsbuf t
        join departmentords zps
          on zps.rn = t.depords
        join udo_v_depordsbuf_supply_rsrv gp
          on gp.nnommodif = zps.nom_modif
        join jurpersons jp
          on jp.rn = gp.njurpers
       where gp.rn = pin_doc
         and t.authid = utilizer;
    exception
      when no_data_found then
        p_exception(0
                   ,pin_doc);
    end;
  end;

  begin
    --- Найдем каталог
  
    select a.rn
      into v_crn
      from acatalog a
     where a.name = pin_cat
       and a.docname = 'UdoFaceAccountReplace'
       and a.company = pin_com;
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Не найден каталог "%s" в разделе "Переносы между темами"'
                 ,pin_cat);
  end;

  --- Найдем Номер переноса
  if pin_doc_nmb is null
  then
    begin
      udo_p_faceacc_replace_getnextn(pin_com
                                    ,v_jp_code
                                    ,pin_doc_type
                                    ,pin_doc_pref
                                    ,v_numb);
    end;
  else
    v_numb := pin_doc_nmb;
  end if;

  udo_pkg_faceacc_replace.doc_insert(ncompany           => pin_com
                                    ,ncrn               => v_crn
                                    ,sjur_pers_code     => v_jp_code
                                    ,sdoctype_code      => pin_doc_type
                                    ,sdocpref           => pin_doc_pref
                                    ,sdocnumb           => v_numb
                                    ,ddocdate           => pin_doc_date
                                    ,svalid_doc         => pin_valid_doc
                                    ,sfaceacc_from_code => pin_faceacc_from
                                    ,sfaceacc_to_code   => pin_faceacc_to
                                    ,nfcdelivsh_to      => pin_fcdelivsh_to
                                    ,ndepartmentord_to  => pin_depart
                                    ,nproductord_to     => pin_prod
                                    ,snote              => pin_note
                                    ,nrn                => v_nrn);

  --- Перенесем спецификацию (через буфер)
  begin
    udo_pkg_faceacc_replace.sp_insert(nprn      => v_nrn
                                     ,ngparty   => v_gp_rn
                                     ,ngsupply  => pin_doc
                                     ,nquant    => pin_q + V_Q_LPM
                                     ,nquantalt => null
                                     ,snote     => null
                                     ,nrn       => v_nrn1);
  end;

end;
/
