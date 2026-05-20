create or replace package USR_PKG_JOBS_DAILY is
  /*
  Степанов М. 06/09/2024
  Пакет для процедур, выполняемых в ночных JOB
  */

  /*#########################################################################################################*/

  procedure MAKE_DOCS_BY_MODEL
  /* 
  Формирование документов по образцам 
  */
  (
   dDATE    in date 
  )
  ;
  /*#########################################################################################################*/

  procedure MAILING_001
  /* 
  Рассылка по накладным с входного контроля, не отработанных складом. НЕ ПРОВЕРЯЛ!!!
  */
  ;
  /*#########################################################################################################*/

  procedure MAILING_002
  /* 
  Рассылка. Приходные ордера, по которым не сформированы полностью накладные с входного контроля на склад 
  */
  ;
  
   /*#########################################################################################################*/

  procedure MAILING_003
  /* 
  Рассылка. Договоры, по которым не сформированы Структура цены Этапа договора и строки калькуляции Графика отпуска товаров и услуг этапа договора
  */
  ;
  /*#########################################################################################################*/

   procedure MAILING_004
  /* 
  Рассылка. Калькуляции структуры цены, которые требуют перещета. !!!  Отключить, когда все имправят !!!
  */
  ;
  /*#########################################################################################################*/

  procedure MAILING_005
  /* 
  Рассылка. Приходные накладные, отработанные больше недели назад, у которых нет присоиденённых документов
  */
  ;
  /*#########################################################################################################*/

  procedure MAILING_006
  /* 
  Рассылка. Исправления договоров по заданным условиям
  */
  (
   nCOMPANY   in number
  ,dDATE      in date
  );
  /*#########################################################################################################*/

  procedure MAILING_007
  /* 
  Рассылка о расходных накладных потребителям, неразнесённых по графикам отпуска. 
  */
  ;
  /*#########################################################################################################*/

  procedure MAILING_008
  /* 
  Рассылка о договорах с расхождением суммы "Отгружено". 
  */
  ;
  /*#########################################################################################################*/

end USR_PKG_JOBS_DAILY;
/
create or replace package body USR_PKG_JOBS_DAILY is

  /*#########################################################################################################*/

  procedure MAKE_DOCS_BY_MODEL
  /* 
  Формирование документов по образцам 
  */
  (
   dDATE    in date 
  )
  as
    nNumber   pkg_std.tnumber; 
  begin
    /* По образцам у которых 
     - свойство Периодичность равно Месяц и текущий номер дня в месяце равен номеру дня в месяце из свойства
       или 
     - свойство Периодичность равно Квартал и текущей номер дня в месяце равен номеру дня в месяце из свойства, и текущий месяц третий в квартале */
    for c in (
              select *
                from (
                      select t.nrn
                            ,t.smodel_name
                            ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 20813858 , ndocument => t.nrn) as sfrequency
                            ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 7356488  , ndocument => t.nrn) as sunitcode
                            ,usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 134513999, ndocument => t.nrn) as scatalog
                            ,usr_pkg_docs_props_vals.get_val_num(ndoc_prop => 134542891, ndocument => t.nrn) as nday_numb
                            ,usr_pkg_docs_props_vals.get_val_num(ndoc_prop => 157635564, ndocument => t.nrn) as nmonth_numb
                            ,to_number(to_char(dDATE, 'dd')) as ncurrent_day_numb
                            ,(select mail from agnlist where rn = t.nacc_agent) as sacc_mail
                       from v_transinvcust_mdl t
                     ) a
               where ( nvl( a.sfrequency, 'null' ) = ( 'Месяц' )
                       and a.ncurrent_day_numb = a.nday_numb and a.nday_numb is not null )
                     or 
                     ( nvl( a.sfrequency, 'null' ) = 'Квартал'
                       and a.ncurrent_day_numb = a.nday_numb and a.nday_numb is not null
                       and decode(mod(to_number(to_char(dDATE, 'MM')), 3), 0, 3, 1, 1, 2, 2) = 3 ) /* текщий месяц третий в квартале */
                     or 
                     ( nvl( a.sfrequency, 'null' ) = 'Год'
                       and a.ncurrent_day_numb = a.nday_numb and a.nday_numb is not null
                       and to_number( to_char( dDATE, 'MM' ) ) = a.nmonth_numb and a.nday_numb is not null )
             )
    loop
      /* Свойство "Раздел" в образце */
      case c.sunitcode
        /* "Входящие счета на оплату" */
        when 'PaymentAccountsIn' then
          /* добавление документа по образцу */
          usr_pkg_payaccin.payaccin_make_by_model(nmodel => c.nrn, ddate => dDATE, nrn => nNumber);
      else
        null;
      end case;
    end loop;

  end MAKE_DOCS_BY_MODEL;
  /*#########################################################################################################*/

  procedure MAILING_001
  /* 
  Рассылка по накладным с входного контроля, не отработанных складом. НЕ ПРОВЕРЯЛ!!!
  */
  as
    sTo_List  pkg_std.tstring;
    cText     clob;
    sTitle    pkg_std.tstring;
  begin
    /* Рассылка */
    for c in (
              select pkg_document.make_number(ndoc_type => tid.doctype, sdoc_pref => tid.pref, sdoc_numb => tid.numb, ddoc_date => tid.docdate) || ' Создана: ' || d2s(tid.modifdate) as stid_det
                    ,pkg_document.make_number(ndoc_type => io.indoctype, sdoc_pref => io.indocpref, sdoc_numb => io.indocnumb, ddoc_date => io.indocdate) as sio_det
                    ,pkg_document.make_number(ndoc_type => iiv.doctype, sdoc_pref => iiv.pref, sdoc_numb => iiv.numb, ddoc_date => iiv.doc_date) as siiv_det
                    ,pkg_document.make_number(ndoc_type => pai.doc_type, sdoc_pref => pai.doc_pref, sdoc_numb => pai.doc_numb, ddoc_date => pai.doc_date) as spai_det
                    ,al.agnabbr
                    ,lead(al.agnabbr, 1) over(order by al.agnabbr) as lead_agnabbr
                    ,al.mail
                from inorders       io
                    ,doclinks       dl_2
                    ,udo_prod_cull  pc
                    ,doclinks       dl_3
                    ,(
                      select h.*, r.modifdate
                        from transinvdept h
                            ,(
                              select a.tablern, max(a.modifdate) as modifdate
                                from (
                                      select *
                                        from (
                                              select ul.tablern, ul.modifdate
                                                from updatelist ul
                                               where ul.operation = 'I'
                                                 
                                              union
                                              select ula.tablern, ula.modifdate
                                                from updatelist_arc ula
                                               where ula.operation = 'I'
                                              order by modifdate desc
                                             ) e
                                     ) a
                               group by a.tablern
                             ) r
                       where h.status = 0
                         and r.tablern = h.rn
                     ) tid
                     ,doclinks           dl_4
                     ,ininvoices         iiv
                     ,doclinks           dl_5
                     ,payaccin           pai
                     ,clnevents          ce
                     ,clnpersons         cp
                     ,agnlist            al
               where io.docstatus        != 0
                 and cmp_dat_minmax(to_date(tid.modifdate), sysdate) < 0
                 and dl_2.in_document    = io.rn
                 and dl_2.out_document   = pc.rn
                 and pc.crn              = 16117920
                 and dl_3.in_document    = pc.rn
                 and dl_3.out_document   = tid.rn
                 and dl_4.out_document   = io.rn
                 and dl_4.in_document    = iiv.rn(+)
                 and dl_5.out_document   = iiv.rn
                 and dl_5.in_document    = pai.rn
                 and ce.linked_rn        = pai.rn
                 and ce.linked_unit      = 'PaymentAccountsIn'
                 and cp.rn               = ce.init_person
                 and al.rn               = cp.pers_agent
              order by al.agnabbr
             )
    loop
      /* Формирование списка документов */
      cText := strcombine(cText, c.sio_det , cr);
      cText := strcombine(cText, c.stid_det, ', '); 
      cText := strcombine(cText, c.spai_det, ', ');

      /* Если следующий контрагент сотрудника не равен текущему */
      if cmp_vc2(c.agnabbr, c.lead_agnabbr) != 1 then
        /* Заполнение параметров для письма */
        sTo_List := nvl(c.mail, 'i.kanaev@module.ru' /*'v.starostina@module.ru'*/);
        sTo_List := strcombine(sTo_List, 'a.khokhryakov@module.ru', ';');
        sTo_List := strcombine(sTo_List, 'm.stepanov@module.ru', ';');
        sTitle   := 'Список неотработанных накладных с входного контроля на склад для сотрудника '||c.agnabbr;
        /* Отправка E-mail */
        usr_pkg_maillst.maillst_insert_exs_ext_send(ncompany        => 90521
                                                   ,sdescription    => 'Рассылка по накладным с входного контроля, не отработанных складом'
                                                   ,sto_list        => sTo_List
                                                   ,stitle          => sTitle
                                                   ,ctext           => cText
                                                   ,nrn             => usr_pkg_pub_const.nref);
        /* Очистка переменных */
        sTo_List := null;
        sTitle   := null;
        cText    := null;
      end if;
    end loop;           
    
    /* Очистка констант */
    usr_pkg_pub_const.nref := null;

  end MAILING_001;
  /*#########################################################################################################*/

  procedure MAILING_002
  /* 
  Рассылка. Приходные ордера, по которым не сформированы полностью накладные с входного контроля на склад 
  */
  as
    dCheck_date date := sysdate - 5;
    sTo_List    pkg_std.tstring;
    cText       clob;
    sTitle      pkg_std.tstring;
  begin
    /* Рассылка */
    for c in (
              select io.rn  as io_rn
                    ,pkg_document.make_number(ndoc_type => io.indoctype, sdoc_pref => io.indocpref, sdoc_numb => io.indocnumb, ddoc_date => io.indocdate) as sio_det
                    ,decode(pc.quant_tid, 0, 'Нет', 'Частично') as sio_pc_status
                    ,pkg_document.make_number(ndoc_type => pc.doc_type, sdoc_pref => pc.doc_pref, sdoc_numb => pc.doc_numb, ddoc_date => pc.doc_date) || ', Создан: '||d2s(pc.modifdate) as spc_det
                    ,al.agnabbr
                    ,lead(al.agnabbr, 1) over(order by al.agnabbr) as lead_agnabbr
                    ,al.mail
                from inorders       io
                    ,doclinks       dl_2
                    ,(select h.rn, h.crn, h.doc_type, h.doc_pref, h.doc_numb, h.doc_date
                            ,usr_pkg_updatelist.updatelist_get_last_date(nflagsmart => 1, nrn => h.rn, soperation => 'I') as modifdate
                            ,sum(s.quant)                                       as quant
                            ,sum(nvl(usr_f_pcus_get_tids_incl(nrn => s.rn), 0)) as quant_tid
                        from udo_prod_cull    h
                            ,udo_prod_cull_sp s
                       where s.prn = h.rn
                      group by h.rn, h.crn, h.doc_type, h.doc_pref, h.doc_numb
                              ,h.doc_date, usr_pkg_updatelist.updatelist_get_last_date(nflagsmart => 1, nrn => h.rn, soperation => 'I') ) pc
                     ,doclinks    dl_4
                     ,ininvoices  iiv
                     ,doclinks    dl_5
                     ,payaccin    pai
                     ,clnevents   ce
                     ,clnpersons  cp
                     ,agnlist     al
               where io.docstatus       != 0
                 and dl_2.in_document    = io.rn
                 and dl_2.out_document   = pc.rn
                 and pc.crn              = 16117920
                 and nvl( pc.quant, 0 ) != nvl( pc.quant_tid, 0 )
                 and cmp_dat_minmax(to_date(pc.modifdate), dCheck_date) < 0
                 and dl_4.out_document   = io.rn
                 and dl_4.in_document    = iiv.rn
                 and dl_5.out_document   = iiv.rn
                 and dl_5.in_document    = pai.rn
                 and ce.linked_rn        = pai.rn
                 and ce.linked_unit      = 'PaymentAccountsIn'
                 and cp.rn               = ce.init_person
                 and al.rn               = cp.pers_agent
              order by al.agnabbr
             )
    loop
      /* Формирование списка документов */
      cText := strcombine(cText, c.sio_det                , ' '||cr);
      cText := strcombine(cText, lpad(c.sio_pc_status, 20), ' '); 
      cText := strcombine(cText, lpad(c.spc_det, 70)      , ' ');

      /* Если следующий контрагент сотрудника не равен текущему */
      if cmp_vc2(c.agnabbr, c.lead_agnabbr) != 1 then
        /* Заполнение параметров для письма */
        /* если адрес не задан, то отправляем Старостиной */
        sTo_List := nvl(c.mail, 'i.kanaev@module.ru'/*'v.starostina@module.ru'*/);
        sTitle   := 'Приходные ордера, по которым не сформированы полностью накладные с входного контроля на склад.';
        cText    := 'Автор: ' || c.agnabbr || ', Дата: ' || decode_date(dCheck_date) || cr || cText;
        /* Отправка E-mail */
        usr_pkg_maillst.maillst_insert_exs_ext_send(ncompany        => 90521
                                                   ,sdescription    => 'Рассылка. Приходные ордера, по которым не сформированы полностью накладные с входного контроля на склад'
                                                   ,sto_list        => sTo_List
                                                   ,stitle          => sTitle
                                                   ,ctext           => cText
                                                   ,nrn             => usr_pkg_pub_const.nref);
        /* Очистка переменных */
        sTo_List := null;
        sTitle   := null;
        cText    := null;
      end if;
    end loop;           

    /* Очистка констант */
    usr_pkg_pub_const.nref := null;

  end MAILING_002;
  /*#########################################################################################################*/
  
  procedure MAILING_003 as
  
    zag0 varchar2(350) := 'Контроль правильности структуры цены в договорах по статьям затрат:' ||
                          '"01 Продажа товаров в СНГ", "02 Экспорт услуг за рубеж", "03 Экспорт товаров","Тематические доходы (Бюджет)"' || cr || cr ||
                          'Контролируются только открытые этапы с видом лицевого счета "Продажа"';
    zag1 varchar2(350) := cr ||
                          'Открытые этапы договоров по которым не созданы строки калькуляции графика отпуска товаров и услуг и не создана калькуляция структуры цены этапа' || cr || cr;
    zag2 varchar2(350) := cr ||
                          'Открытые этапы договоров по которым созданы строки калькуляции графика отпуска товаров и услуг, но не создана калькуляция структуры цены этапа' || cr || cr;
  
    ctext0 clob;
    ctext1 clob;
    ctext2 clob;
  
    sto_list pkg_std.tstring;
    stitle   pkg_std.tstring;
  
    sdef_mail pkg_std.tstring := 'anna@module.ru';
    sdef_econ pkg_std.tstring := 'Экономист ПЭО не задан';
  
  begin
    ctext0 := ' ';
    ctext1 := ' ';
    ctext2 := ' ';
  
    for cur in (select dog.rn
                      ,fpa.code sz_code
                      ,dt.doccode doc_type
                      ,trim(st.numb) st_nmb
                      ,trim(dog.doc_pref) || '-' || trim(dog.doc_numb) dog_nmb
                      ,to_char(dog.doc_date, 'DD.MM.YYYY') dog_date
                      ,coalesce(mn.agnabbr, sdef_econ) agnabbr
                      ,coalesce(mn.mail, sdef_mail) mail
                      ,lead(coalesce(mn.mail, sdef_mail)) over(order by coalesce(mn.mail, sdef_mail)) as lead_mail
                      ,(select 1
                          from contrprstruct str
                         where str.prn = st.rn
                           and rownum = 1) is_str
                      ,(select 1
                          from fcacoperplans fp
                          join fcacoperplansclc fpc
                            on fpc.prn = fp.rn
                         where fp.prn = f.rn
                           and rownum = 1) is_plan
                  from stages st
                  join faceacc f
                    on f.rn = st.faceacc
                  join fpdartcl fpa
                    on fpa.rn = f.ieelement
                  join contracts dog
                    on dog.rn = st.prn
                  join doctypes dt
                    on dt.rn = dog.doc_type
                  left join docs_props_vals zsv
                    on zsv.docs_prop_rn = 1082887 /*Сотрудник*/
                   and zsv.unitcode = 'Contracts'
                   and zsv.unit_rn = dog.rn
                  left join agnlist mn
                    on mn.rn = zsv.source
                
                 where f.fact_close_date is null /*лицевой счет открыт*/
                   and st.status = 1 /*этап открыт*/
                   and f.acc_kind = 1 /*Лицевой счет "Продажа"*/
                      /*Статьи затрат: 
                                "01 Продажа товаров в СНГ "
                                "02 Экспорт услуг за рубеж"
                                "03 Экспорт товаров"
                                "Тематические доходы (Бюджет)"
                      */
                   and fpa.rn in (6172145, 6172139, 6172148, 6172140)
                   and (not exists (select 1 from contrprstruct str where str.prn = st.rn) /* Нет структуры цены" */
                       )
                
                 order by coalesce(mn.mail, sdef_mail)
                         ,coalesce(mn.agnabbr, sdef_econ))
    loop
    
      /* Формирование списка документов */
      if cur.is_plan is null
         and cur.is_str is null then
        ctext1 := ctext1 || 'RN ' || lpad(cur.rn, 14, ' ') || ' ' || cur.doc_type || ' №' ||
                  cur.dog_nmb || ' от ' || cur.dog_date || '  № этапа ' || cur.st_nmb ||
                  ' состав затрат: ' || cur.sz_code || cr || chr(160);
      
      end if;
    
      if cur.is_plan is not null
         and cur.is_str is null then
      
        ctext2 := ctext2 || 'RN ' || lpad(cur.rn, 14, ' ') || ' ' || cur.doc_type || ' №' ||
                  cur.dog_nmb || ' от ' || cur.dog_date || '  № этапа ' || cur.st_nmb ||
                  ' состав затрат: ' || cur.sz_code || cr || chr(160);
      end if;
    
      /* Если следующий контрагент сотрудника не равен текущему */
    
      if cmp_vc2(cur.mail, cur.lead_mail) != 1 then
      
        ctext0 := zag0 || cr || 'Экономист ПЭО: ' || cur.agnabbr || cr || cr;
      
        if ctext1 != ' ' then
          ctext0 := ctext0 || zag1 || ctext1;
        
        end if;
      
        if length(ctext2) > 1 then
        
          ctext0 := ctext0 || zag2 || ctext2;
        end if;
      
        sto_list := cur.mail;
        --- sto_list := 'o.gorodetskiy@module.ru';
        stitle := 'Контроль правильности структуры цены в договорах по статьям затрат ' ||
                  cur.agnabbr;
      
        pkg_exs_ext_mail.send_by_list(sto_list => sto_list
                                     ,stitle   => stitle
                                     ,ctext    => ctext0
                                     ,nformat  => pkg_exs_ext_mail.nformat_text);
      
        ctext0 := ' ';
        ctext1 := ' ';
        ctext2 := ' ';
      
      end if;    
    end loop; 
  end;
     
  
  /*#########################################################################################################*/
 
procedure mailing_004 as
  ctext0 clob;
  sto_list pkg_std.tstring;
  stitle   pkg_std.tstring;
  sdef_mail pkg_std.tstring := 'o.gorodetskiy@module.ru';
  sdef_econ pkg_std.tstring := 'Экономист ПЭО не задан';
  zag0 varchar2(350) := 'Список договоров и структур цен, которые требуется пересчитать'|| cr || cr; 
  
begin



  /* Подготовим список непересчитанных калькуляций */
  
 

  for doc in (select t.rn
                    ,t.company
                    , dog.doc_date
                from CONTRPRSTRUCT t
                join stages ST on st.rn = t.prn
                join CONTRACTS DOG on dog.rn = st.prn
                where t.SIGN_ACT = 1
                and dog.status != 2 -- Закрытые нас не интересуют
                and dog.doc_date >= to_date('01-01-2023','DD.MM.YYYY')
               )
  loop
  
    usr_p_contrprstruct_is_err(doc.rn);
  
  end loop;

 ctext0 := ' ';
  for cur in (select rpad('RN ' || dog.rn, 17, ' ') || ' ' || dt.doccode || ' № ' ||
                     lpad(trim(dog.doc_pref) || '-' || trim(dog.doc_numb) || ' от ' ||
                          to_char(dog.doc_date, 'DD.MM.YYYY')
                         ,30
                         ,' ') || lpad(' Этап №' || trim(st.numb), 12, ' ') || ' ' || 'Вид цены: "' ||
                     fs.code || '" Структура цены: "' || hm.code || '" с ' ||
                     to_char(str.date_from, 'DD.MM.YYYY') || ' по ' ||
                     to_char(str.date_to, 'DD.MM.YYYY') str
                    ,coalesce(mn.agnabbr,sdef_econ) agnabb
                    ,coalesce(mn.mail, sdef_mail) mail
                    ,lead(coalesce(mn.mail, sdef_mail)) over(order by coalesce(mn.mail, sdef_mail)) as lead_mail
                from usr_t_tmp_is_err t
                join contrprstruct str
                  on str.rn = t.nrn
                join prjcalcschm hm
                  on hm.rn = str.calcschm
                join finstate fs
                  on fs.rn = str.price_kind
                join stages st
                  on st.rn = str.prn
                join contracts dog
                  on dog.rn = st.prn
                join doctypes dt
                  on dt.rn = dog.doc_type
                left join docs_props_vals zsv
                  on zsv.docs_prop_rn = 1082887 /*Сотрудники*/
                 and zsv.unitcode = 'Contracts'
                 and zsv.unit_rn = dog.rn
                left join agnlist mn
                  on mn.rn = zsv.source
              
               order by coalesce(mn.agnabbr,sdef_econ))
  loop
    
  ctext0:=ctext0||cr||chr(160)||cur.str|| cr || chr(160);
  
  
    if cmp_vc2(cur.mail, cur.lead_mail) != 1 then
      
    ctext0:= zag0||ctext0;
    
        sto_list := cur.mail;
       --- sto_list := 'o.gorodetskiy@module.ru';
        
        stitle := 'Структуры цены которые требуется пересчитать (выполнить на них действие "Сформировать").';
      
        pkg_exs_ext_mail.send_by_list(sto_list => sto_list
                                     ,stitle   => stitle
                                     ,ctext    => ctext0
                                     ,nformat  => pkg_exs_ext_mail.nformat_text);
      
        ctext0 := ' ';
    
    
    end if;
  
  end loop;

end;

  /*#########################################################################################################*/

  procedure MAILING_005
  /* 
  Рассылка. Приходные накладные, отработанные больше недели назад, у которых нет присоиденённых документов
  */
  as
    sTitle      pkg_std.tstring := 'Приходные накладные без присоединённых документов.';
    sTo_List    pkg_std.tlstring;
    cText       clob; 
  begin
    /* Рассылка */
    for c in ( select a.*, lead(a.siiv_mail, 1) over(order by a.siiv_mail) as slead_iiv_mail 
                 from ( select pkg_document.make_number( ndoc_type => iiv.doctype
                                                        ,sdoc_pref => iiv.pref
                                                        ,sdoc_numb => iiv.numb
                                                        ,ddoc_date => iiv.doc_date ) as siiv
                              ,iiv.agnabbr  as siiv_agnabbr
                              ,iiv.mail     as siiv_mail
                              ,nvl(pkg_document.make_number( ndoc_type => pai.doc_type
                                                            ,sdoc_pref => pai.doc_pref
                                                            ,sdoc_numb => pai.doc_numb
                                                            ,ddoc_date => pai.doc_date )
                                  , 'Нет' ) as spai
                              ,pai.agnabbr  as spai_agnabbr
                              ,pai.mail     as spai_mail
                          from ( select b.*, t.*
                                   from ininvoices t
                                       ,( select cp.pers_authid, al.agnabbr, al.mail
                                            from clnpersons cp
                                                ,agnlist    al
                                           where cp.pers_agent  = al.rn ) b
                                   where usr_pkg_updatelist.updatelist_get_last_authid( nflagsmart => 1
                                                                                       ,nrn        => t.rn
                                                                                       ,soperation => 'I' ) = b.pers_authid(+) 
                               ) iiv
                              ,azsgsmwaystypes  sot
                              ,( select dl.out_document, b.*, t.*
                                   from doclinks  dl
                                       ,payaccin  t
                                       ,( select ce.linked_rn, al.agnabbr, al.mail
                                            from clnevents  ce
                                                ,clnpersons cp
                                                ,agnlist    al
                                           where ( (ce.init_person is not null and ce.init_person = cp.rn)
                                                 or 
                                                   (ce.init_authid is not null and ce.init_authid = cp.pers_authid) )
                                             and cp.pers_agent  = al.rn ) b
                                  where dl.in_document = t.rn
                                    and t.rn           = b.linked_rn(+) ) pai
                         where iiv.status     != 0
                           and iiv.storeoper  = sot.rn
                           and sot.keep_sign  = 0 
                           and iiv.rn         = pai.out_document(+)
                           and iiv.crn        not in ( 7152379 ) /* Служба IT */
                           and iiv.work_date  < sysdate - 2
                           and iiv.doc_date   >= to_date('01.01.2025', 'dd.mm.yyyy') 
                           and not exists     ( select null from filelinksunits flu where flu.table_prn =  iiv.rn ) ) a 
                 order by a.siiv_mail )
    loop
      /* Формирование списка документов */
      cText := cText || rpad(c.siiv, 40); 
      cText := cText || rpad(c.spai, 40); 
      cText := cText || c.spai_agnabbr || cr ;

      /* Формирование списка адресов получателей */
      sTo_List := strcombine(sTo_List
                            ,case when c.siiv_mail in ('a.zaytsev@module.ru', 'm.lukashina@module.ru', 'a.gribin@module.ru', 'a.saprykin@module.ru')
                                 then 'v.starostina@module.ru;d.nikolenko@module.ru'
                                 else c.siiv_mail
                               end 
                               ||';'|| 
                               case when c.spai_mail in ('a.zaytsev@module.ru', 'm.lukashina@module.ru', 'a.gribin@moduleru', 'a.saprykin@module.ru')
                                    then 'v.starostina@module.ru;d.nikolenko@module.ru'
                                    else c.spai_mail
                                  end 
                               , ';');
      /* Исключение повторяющихся адресов получателей */
      sTo_List := usr_pkg_common.get_list_distinct(slist => sTo_List);

      /* Если следующий контрагент сотрудника не равен текущему */
      if cmp_vc2(c.siiv_mail, c.slead_iiv_mail) != 1 then

        /* Отправка E-mail */
        usr_pkg_maillst.maillst_insert_exs_ext_send( ncompany     => 90521
                                                    ,sdescription => sTitle || ' Создатель накладной: '||c.siiv_agnabbr
                                                    ,sto_list     => sTo_List
                                                    ,stitle       => sTitle || ' Создатель накладной: '||c.siiv_agnabbr
                                                    ,ctext        => cText 
                                                    ,nrn          => usr_pkg_pub_const.nref );
        /* Очистка переменных */
        sTo_List := null;
        cText    := null;

      end if;
    end loop;           
    
    /* Очистка констант */
    usr_pkg_pub_const.nref := null;

  end MAILING_005;
  /*#########################################################################################################*/

  procedure MAILING_006
  /* 
  Рассылка. Исправления договоров по заданным условиям
  */
  (
   nCOMPANY   in number
  ,dDATE      in date
  )
  as
    sTitle      pkg_std.tstring  := 'Изменение реквизитов договоров с префиксами: 1/*, 2/*, 020-*';
    sTo_List    pkg_std.tlstring := 'a.kuroedova@module.ru;k.bykova@module.ru';
    cText       clob; 
    nCount      pkg_std.tnumber := 0; 
  begin
    /* По архиву журнала регистрации */
    for c in ( 
              select ul.tablern
                    ,lead(ul.tablern, 1) over(order by ul.tablern) as lead_tablern
                    ,pkg_document.make_number(ndoc_type => ct.doc_type
                                             ,sdoc_pref => ct.doc_pref
                                             ,sdoc_numb => ct.doc_numb
                                             ,ddoc_date => ct.doc_date) as sContract
                    ,ct.ext_number  as ct_ext_number
                    ,ct.rn          as ct_rn
                    ,usr_pkg_document.get_dmsclattrs_caption( nflagsmart   => 1
                                                             ,stable_name  => ula.table_name
                                                             ,scolumn_name => ula.column_name ) as scol_name
                    ,get_doctypes_code_id(nflag_smart => 1, nrn => ula.upd_num_value )          as supd_doc_type
                    ,get_doctypes_code_id(nflag_smart => 1, nrn => ula.num_value )              as sdoc_type
                    ,trim( ula.upd_str_value ) as upd_str_value
                    ,trim( ula.str_value )     as str_value
                    ,ula.upd_date_value
                    ,ula.date_value   
                    ,ul.modifdate
                    ,ul.authid
                    ,ul.osuser
                from updatelist_detail_arc  ula
                    ,updatelist_arc         ul
                    ,(
                      select distinct h.tablern
                        from updatelist_detail_arc  t
                            ,updatelist_arc         h
                       where t.prn            = h.rn
                         and t.table_name     = 'CONTRACTS'
                         and t.oper_type      = 'U'
                         and ( t.column_name  = 'DOC_PREF' 
                             and (  trim( t.upd_str_value ) like '1/%' 
                                 or trim( t.upd_str_value ) like '2/%' 
                                 or trim( t.upd_str_value ) like '020-%' 
                                 or trim( t.str_value )     like '1/%' 
                                 or trim( t.str_value )     like '2/%' 
                                 or trim( t.str_value )     like '020-%' 
                                 )
                             )
                         and t.reg_date > dDate
                      ) a
                    ,contracts  ct
               where ul.tablern       = a.tablern
                 and ula.prn          = ul.rn
                 and ula.column_name  in ( 'DOC_TYPE', 'DOC_PREF', 'DOC_NUMB', 'DOC_DATE' )
                 and ula.reg_date     > dDate
                 and ul.tablern       = ct.rn
              order by ul.tablern, decode( ula.column_name, 'DOC_TYPE', '0', 'DOC_PREF', '1', 'DOC_NUMB', '2', 'DOC_DATE', '3' ) 
             )
    loop
      nCount := nCount +1;
      /* Заголовок */
      if nCount = 1 or cmp_num( c.tablern, c.lead_tablern ) != 1 then
        cText := case when nCount != 1 then cText ||cr||cr end ||
                 c.scontract ||', '|| c.ct_ext_number ||', '|| c.ct_rn ; 
      end if;
      /* Колонки */
      if c.supd_doc_type||c.sdoc_type is not null then
        cText := cText ||cr||  
                 c.scol_name ||': '|| nvl( c.supd_doc_type, 'пусто' ) ||' => '|| nvl( c.sdoc_type, 'пусто' ) 
                 ||' ('||dts2s( c.modifdate ) ||', '|| c.authid ||', '|| c.osuser ||')'; 
      elsif c.upd_str_value||c.str_value is not null then
        cText := cText ||cr||  
                 c.scol_name ||': '|| nvl( c.upd_str_value, 'пусто' ) ||' => '|| nvl( c.str_value, 'пусто' ) 
                 ||' ('||dts2s( c.modifdate ) ||', '|| c.authid ||', '|| c.osuser ||')'; 
      elsif c.upd_date_value||c.date_value is not null then
        cText := cText ||cr||  
                 c.scol_name ||': '|| nvl( decode_date( c.upd_date_value ), 'пусто' ) ||' => '|| nvl( decode_date( c.date_value ), 'пусто' )
                 ||' ('||dts2s( c.modifdate ) ||', '|| c.authid ||', '|| c.osuser ||')'; 
      end if;

    end loop;           

    /* Если найдены записи изменения */
    if nCount != 0 then
      /* Исключение повторяющихся адресов получателей */
      sTo_List := usr_pkg_common.get_list_distinct(slist => sTo_List);
      /* Отправка E-mail */
      usr_pkg_maillst.maillst_insert_exs_ext_send( ncompany     => nCOMPANY
                                                  ,sdescription => sTitle
                                                  ,sto_list     => sTo_List
                                                  ,stitle       => sTitle
                                                  ,ctext        => cText 
                                                  ,nrn          => nCount );
    end if;

  end MAILING_006;
  /*#########################################################################################################*/

  procedure MAILING_007
  /* 
  Рассылка о расходных накладных потребителям, неразнесённых по графикам отпуска. 
  */
  as
    sTitle      pkg_std.tstring  := 'Разнести накладную по строкам графика отпуска.';
    sTo_List    pkg_std.tlstring;
    cText       clob; 
    nNumber     pkg_std.tnumber; 

    /* Заголовок (наименования колонок) */
    procedure p_header
    as
    begin
      cText := cText || 'Накладная / '; 
      cText := cText || 'Разнесено / '; 
      cText := cText || 'Договор / '; 
      cText := cText || 'Этап / '; 
      cText := cText || 'Контрагент';
      cText := cText || cr;
    end;

  begin
    /* Добавление в текст заголовка первого письма */
    p_header;
    
    /* По РН потребителям */
    for c in ( 
              select a.*
                    ,lead( a.mail, 1 ) over( order by a.mail ) as lead_mail
                from (
                      select tic.company
                            ,pkg_document.make_number( ndoc_type => tic.doctype
                                                      ,sdoc_pref => tic.pref
                                                      ,sdoc_numb => tic.numb
                                                      ,ddoc_date => tic.docdate )  as tic_det
                            ,usr_f_tic_get_faoop_work_sum( nrn => tic.rn )         as status
                            ,pkg_document.make_number( ndoc_type => ct.doc_type
                                                      ,sdoc_pref => ct.doc_pref
                                                      ,sdoc_numb => ct.doc_numb
                                                      ,ddoc_date => ct.doc_date )  as ct_det
                            ,trim( st.numb )                                       as st_numb
                            ,fa.numb                                               as fa_numb
                            ,al.agnname                                            as al_agnname
                            ,coalesce( al_ex.mail
                                      ,al_ec.mail
                                      ,'a.kuroedova@module.ru' )                   as mail
                        from transinvcust     tic
                        join faceacc          fa    on  fa.rn          = tic.faceacc
                        join stages           st    on  st.faceacc     = fa.rn
                        left join agnlist     al_ec on  al_ec.agnabbr  = usr_pkg_docs_props_vals.get_val_str( ndoc_prop => 1082887, ndocument => st.prn ) 
                                                    and exists ( select null
                                                                   from userlist ul
                                                                  where ul.authid   = f_agnlist_get_authid(nflag_smart => 1, ncompany => tic.company, nrn => al_ec.rn )
                                                                    and ul.acc_lock = 0 ) 
                        join contracts        ct    on  ct.rn          = st.prn
                        join agnlist          al    on  al.rn          = ct.agent
                        left join agnlist     al_ex on  al_ex.rn       = ct.executive 
                                                    and al_ex.crn      in ( 1084000, 91106444 ) /* ПЭО, Коммерция*/
                                                    and exists ( select null
                                                                   from userlist ul
                                                                  where ul.authid   = f_agnlist_get_authid(nflag_smart => 1, ncompany => tic.company, nrn => al_ex.rn )
                                                                    and ul.acc_lock = 0 ) 
                        join azsgsmwaystypes  sot   on  sot.rn         = tic.stoper   
                                                    and sot.keep_sign  = 0
                       where tic.doctype           = 1074554 /* ТН */
                         and trunc( tic.docdate ) >= to_date('01.01.2025', 'dd.mm.yyyy') 
                         and tic.status            = 1
                         and nvl( usr_f_tic_get_faoop_work_sum( nrn => tic.rn ), 'null' ) != 'Полностью' 
                     ) a
            order by 8, 6, 3, 4           
           )
    loop
      /* Формирование списка документов */
      cText := strcombine( cText, rpad( c.tic_det   , 35  ), null ); 
      cText := strcombine( cText, rpad( c.status    , 10  ), null ); 
      cText := strcombine( cText, rpad( c.ct_det    , 40  ), null ); 
      cText := strcombine( cText, rpad( c.st_numb   , 10  ), null ); 
      cText := strcombine( cText, c.al_agnname, null ); 
      cText := strcombine( cText, cr, null ); 

      /* Если следующий контрагент сотрудника не равен текущему */
      if cmp_vc2( c.mail, c.lead_mail ) != 1 then

        /* Инструкция в конце сообщения */
        cText := strcombine( cText, 'Для установки связи с графиком используйте пользовательскую процедуру "Проставление связи расходной накладной с графиком",'||
                                    ' которая выполняется в разделе "Расходные накладные на отпуск потребителям (спецификация)."', cr||cr ); 

        /* Отправка E-mail */
        usr_pkg_maillst.maillst_insert_exs_ext_send( ncompany     => c.company
                                                    ,sdescription => sTitle
                                                    ,sto_list     => c.mail
                                                    ,stitle       => sTitle
                                                    ,ctext        => cText 
                                                    ,nrn          => nNumber );
        /* Очистка получателей и текста */
        sTo_List := null;
        cText    := null;

        /* Добавление в текст заголовка следующего письма */
        p_header;

      end if;

    end loop;           
    
  end MAILING_007;
  /*#########################################################################################################*/

  procedure MAILING_008
  /* 
  Рассылка о договорах с расхождением суммы "Отгружено". 
  */
  as
    sTitle      pkg_std.tstring  := 'Договоры с расхождением суммы "Отгружено".';
    sTo_List    pkg_std.tlstring := 'm.stepanov@module.ru';
    cText       clob; 

    nNumber     pkg_std.tnumber; 
  begin
    /* По договорам, у которых Отгружено не равно с Отгружено по этапам */
    for c in ( select *
                 from ( select ct.company
                              ,pkg_document.make_number(ndoc_type => ct.doc_type,
                                                        sdoc_pref => ct.doc_pref,
                                                        sdoc_numb => ct.doc_numb,
                                                        ddoc_date => ct.doc_date) as ct_num
                              ,ct.fact_outgood_sum
                              ,sum( fa.fact_ship ) as fa_fact_ship
                          from contracts ct
                          join stages st   on st.prn = ct.rn
                          join faceacc fa  on fa.rn  = st.faceacc
                         group by ct.rn, ct.company, ct.fact_outgood_sum, ct.doc_type, ct.doc_pref, ct.doc_numb, ct.doc_date ) a
                where a.fact_outgood_sum != a.fa_fact_ship )
    loop
      /* Формирование списка документов */
      cText := strcombine( cText, c.ct_num ||', '|| usr_f_n2ss( c.fact_outgood_sum ) ||', '|| usr_f_n2ss( c.fa_fact_ship ), cr ); 
      /* Отправка E-mail */
      usr_pkg_maillst.maillst_insert_exs_ext_send( ncompany     => c.company
                                                  ,sdescription => sTitle
                                                  ,sto_list     => sTo_List
                                                  ,stitle       => sTitle
                                                  ,ctext        => cText 
                                                  ,nrn          => nNumber );
    end loop;           
    
  end MAILING_008;
  /*#########################################################################################################*/

end USR_PKG_JOBS_DAILY;
/
