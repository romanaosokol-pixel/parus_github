create or replace package USR_PKG_FACEACC_REPLACE is
  /*
  Package предназначен для работы с разделом "Переносы между темами". 
  UdoFaceAccountReplace     UDO_FACEACC_REPLACE       FAR     Переносы между темами
  UdoFaceAccountReplaceSp   UDO_FACEACC_REPLACE_SP    FARS    Переносы между темами (Спецификация ТМЦ)
  UdoFaceAccountReplaceHist UDO_FACEACC_REPLACE_HIST  FARH    Переносы между темами (История согласования)
  */
  --#########################################################################################################

  function FACEACC_REPLACE_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return udo_faceacc_replace%rowtype;
  --#########################################################################################################

  procedure FACEACC_REPLACE_GET_RESP_LIST
  /*
  Заголовок. Получить список ответственных документа
  */
  (
   nFLAGSMART   in number
  ,nRN          in number
  ,aRNLIST      out udo_tp_numtable 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_BUPDATE
  /*
  Заголовок. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_AAPPROV
  /*
  Заголовок. Согласование. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_ACONF
  /*
  Заголовок. Отработать. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_AUCONF
  /*
  Заголовок. Снять отработку. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_AFORM
  /*
  Заголовок. Cформировать по теме. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  function FACEACC_REPLACE_SP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return udo_faceacc_replace_sp%rowtype;
  --#########################################################################################################

  procedure FACEACC_REPLACE_SP_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_SP_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_SP_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_SP_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_SP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );




  --#########################################################################################################

  function FACEACC_REPLACE_HIST_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return udo_faceacc_replace_hist%rowtype;
  --#########################################################################################################

  procedure FACEACC_REPLACE_HIST_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_HIST_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_HIST_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_HIST_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  );
  --#########################################################################################################

  procedure FACEACC_REPLACE_HIST_CHK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  );
  --#########################################################################################################

end USR_PKG_FACEACC_REPLACE;
/
create or replace package body USR_PKG_FACEACC_REPLACE is

  --#########################################################################################################

  function FACEACC_REPLACE_GET
  /*
  Заголовок. Считывание
  */
  (
   nRN      in number 
  ) 
  return udo_faceacc_replace%rowtype
  is
    rRow udo_faceacc_replace%rowtype;
  begin
    begin
      select t.* into rRow from udo_faceacc_replace t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'FACEACC_REPLACE');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'FACEACC_REPLACE')));
    end;
    return(rRow);
  end FACEACC_REPLACE_GET;
  --#########################################################################################################

  procedure FACEACC_REPLACE_GET_RESP_LIST
  /*
  Заголовок. Получить список ответственных документа
  */
  (
   nFLAGSMART   in number
  ,nRN          in number
  ,aRNLIST      out udo_tp_numtable 
  ) 
  is
    nFcMatResource    pkg_std.tref; 
  begin
    /* По спецификациям документа. Ищем заказ подразделения по серии, затем мат.ресурс по заказу подразделения. */
    for c in ( select distinct usr_pkg_fcmatresource.fcmatresource_get_by_dpo
                               ( nflagsmart     => 1
                                ,ntoo_many_rows => 1
                                ,ndepartmentord => usr_pkg_departmentord.departmentord_get_by_sernumb
                                                   ( nflagsmart     => 1
                                                    ,ntoo_many_rows => 1
                                                    ,ssernumb       => gp.sernumb ) ) as nFcMatResource
                 from udo_faceacc_replace_sp t
                     ,goodsparties           gp
                where t.prn = nRN
                  and gp.rn = t.gparty )
    loop
      nFcMatResource := c.nFcMatResource;
      /* выходим при первом найденом мат.ресурсе */
      exit;
    end loop;                    
         
    /* Контрагенты ответственных за проекты */
    begin
      select a.rn bulk collect
        into aRNLIST
        from (
              select udo_f_faceacc_get_agent(nrn => faceacc_from, nmatresource => nFcMatResource) as rn
                from udo_faceacc_replace
               where rn = nRN
              union
              select udo_f_faceacc_get_agent(nrn => faceacc_to, nmatresource => nFcMatResource) as rn
                from udo_faceacc_replace
               where rn = nRN
              union
              select udo_f_faceacc_get_respon(nrn => faceacc_from) as rn
                from udo_faceacc_replace
               where rn = nRN
              union
              select udo_f_faceacc_get_respon(nrn => faceacc_to) as rn
                from udo_faceacc_replace
               where rn = nRN
             ) a ;
    end;

  end FACEACC_REPLACE_GET_RESP_LIST;
  --#########################################################################################################

  procedure FACEACC_REPLACE_AINSERT
  /*
  Заголовок. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow                  udo_faceacc_replace%rowtype;
  begin
    /* Заголовок */
    /*rRow   := FACEACC_REPLACE_GET(nRN);*/

    /* ИСПРАВЛЕНИЕ */

    /* ПРОВЕРКИ */
    /* Базовая*/
    faceacc_replace_check_base(nrn => nRN, ncompany => nCOMPANY);

    /* Очистка констант */
    /*usr_pkg_pub_const.rfaceacc_replace := null;*/

  end FACEACC_REPLACE_AINSERT;
  --#########################################################################################################

  procedure FACEACC_REPLACE_BUPDATE
  /*
  Заголовок. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end FACEACC_REPLACE_BUPDATE;
  --#########################################################################################################

  procedure FACEACC_REPLACE_AUPDATE
  /*
  Заголовок. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow    udo_faceacc_replace%rowtype;
  begin
    /* Запись */
    /*rRow := faceacc_replace_get(nRN => nRN);*/
    
    /* ПРОВЕРКИ */
    /* Базовая */
    faceacc_replace_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FACEACC_REPLACE_AUPDATE;
  --#########################################################################################################

  procedure FACEACC_REPLACE_BDELETE
  /*
  Заголовок. Удаление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    /* Проверка спецификаций */
    for c in (select * from udo_faceacc_replace_sp where prn = nRN)
    loop
      faceacc_replace_sp_bdelete(nrn => c.rn, ncompany => c.company);
    end loop;

  end FACEACC_REPLACE_BDELETE;
  --#########################################################################################################

  procedure FACEACC_REPLACE_AAPPROV
  /*
  Заголовок. Согласование. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow          udo_faceacc_replace%rowtype;
    nClnEvents    pkg_std.tref;
    sSperf_mark   pkg_std.tstring; 
    sNote         pkg_std.tstring; 
    
    nNumber       pkg_std.tnumber; 
 begin
   /* Считывание */
   rrow := faceacc_replace_get(nrn => nrn);
 
   /* Событие статусной модели */
   nclnevents := usr_pkg_document.get_clnevents(nflagsmart => 1, nrn => rrow.rn);
 
   /* Если событие найдено */
   if nclnevents is not null
   then
   
     /* Статус и примечание согласования */
     begin
       select decode(state, 0, 'Не согласовано', 1, 'Согласовано')
             ,note
         into ssperf_mark
             ,snote
         from (select * from udo_faceacc_replace_hist order by rn desc)
        where prn = rrow.rn
          and rownum = 1;
     exception
       when no_data_found then
         pkg_msg.record_not_found(nflag_smart => 0, ndocument => nrn, sunit_table => 'UDO_FACEACC_REPLACE_HIST');
       when others then
         p_exception(0, 'Неопределённая ситуация при считывании документа с RN <%s> в разделе <%s>.', nrn, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'UDO_FACEACC_REPLACE_HIST')));
     end;

     /* Установка отметки об исполнении в событии */
     usr_pkg_clnevents.clnevents_perf_mark_set(ncompany => rrow.company, nrn => nclnevents, sperf_mark => ssperf_mark, nmode => 1);
     /* Добавление примечания в событие */
     usr_pkg_clnevents.clnevnotes_insert(ncompany => rrow.company, nprn => nclnevents, snote_header => 'Примечание', snote => snote, nrn => nnumber, nmode => 1);
   end if;

   /* ПРОВЕРКИ */
   if ssperf_mark = 'Не согласовано' then /* 22/10/2025 KHOK. если "Не согласовано", то проверять ничего не надо. */
     return;
   end if;
 
   /* Базовая */
   faceacc_replace_check_base(nrn => nrn, ncompany => ncompany);
 
   /*Проконтролируем, что на момент согласования на складе есть достаточное количество для передачи */
   for cur in (select skl.azs_number
                     ,nm.modif_code
                     ,nm.modif_name
                     ,sp.quant q_pmt
                     ,least(gyh.min_restplan, gyh.min_restfact) rest_fact
                 from udo_faceacc_replace t
                 join udo_faceacc_replace_sp sp
                   on sp.prn = t.rn  and sp.rec_type != 2
                 join goodssupply gy
                   on gy.rn = sp.gsupply
                 join goodssupplyhist gyh
                   on gyh.prn = gy.rn
                  and gyh.date_to is null
                 join goodsparties gp
                   on gp.rn = gy.prn
                 join nommodif nm
                   on nm.rn = gp.nommodif
                 join azsazslistmt skl
                   on skl.rn = gy.store
                where t.rn = nrn
                  and least(gyh.min_restplan, gyh.min_restfact) - sp.quant < 0)
   loop
     p_exception(0, 'Недостаточное количество для передачи на складе %s по номенклатуре %s. В наличии %s, а вы передаете %s. ', cur.azs_number, cur.modif_name, cur.rest_fact, cur.q_pmt);
   end loop;

 end faceacc_replace_aapprov;
  --#########################################################################################################
           
  procedure FACEACC_REPLACE_ACONF
  /*
  Заголовок. Отработать. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
        
    null;
  end FACEACC_REPLACE_ACONF;
  --#########################################################################################################

  procedure FACEACC_REPLACE_AUCONF
  /*
  Заголовок. Снять отработку. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end FACEACC_REPLACE_AUCONF;
  --#########################################################################################################

  procedure FACEACC_REPLACE_AFORM
  /*
  Заголовок. Cформировать по теме. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end FACEACC_REPLACE_AFORM;
  --#########################################################################################################

  procedure FACEACC_REPLACE_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow              udo_faceacc_replace%rowtype;
  begin
    /* Заголовок */
    rRow := faceacc_replace_get(nRN => nRN);
    
    /* ПРОВЕРКИ */

    /* Лицевой счёт От кого - ремонтный */
    if cmp_num(rRow.faceacc_from, 83660497) = 1 then
      p_exception(0, 'Запрещено использовать лицевой счёт <%s>. %s'
                 ,get_faceacc_numb_id(nflag_smart => 1, nrn => rRow.faceacc_from)
                 ,cr||f_docdescrs_get_description(sunitcode => 'UdoFaceAccountReplace', ndocument => rRow.rn)); 
    end if;

    /* Лицевой счёт Кому - ремонтный */
    if cmp_num(rRow.faceacc_to, 83660497) = 1 then
      p_exception(0, 'Запрещено использовать лицевой счёт <%s>. %s'
                 ,get_faceacc_numb_id(nflag_smart => 1, nrn => rRow.faceacc_to)
                 ,cr||f_docdescrs_get_description(sunitcode => 'UdoFaceAccountReplace', ndocument => rRow.rn)); 
    end if;
    
  end FACEACC_REPLACE_CHECK_BASE;
  --#########################################################################################################

  function FACEACC_REPLACE_SP_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return udo_faceacc_replace_sp%rowtype
  is
    rRow udo_faceacc_replace_sp%rowtype;
  begin
    begin
      select * into rRow from udo_faceacc_replace_sp t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'UDO_FACEACC_REPLACE_SP');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'UDO_FACEACC_REPLACE_SP')));
    end;
    return(rRow);
  end FACEACC_REPLACE_SP_GET;
  --#########################################################################################################

  procedure FACEACC_REPLACE_SP_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         udo_faceacc_replace_sp%rowtype;
  begin
    /* Спецификация */
    /*rRow := faceacc_replace_sp_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    faceacc_replace_sp_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FACEACC_REPLACE_SP_AINSERT;
  --#########################################################################################################

  procedure FACEACC_REPLACE_SP_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end FACEACC_REPLACE_SP_BUPDATE;
  --#########################################################################################################

  procedure FACEACC_REPLACE_SP_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            udo_faceacc_replace_sp%rowtype;
    rGoodsSupply    goodssupply%rowtype;
  begin
    /* Заголовок */
    /* rRow := faceacc_replace_sp_get(nrn => nRN); */
    
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    faceacc_replace_sp_check_base(nrn => nRN, ncompany => nCOMPANY);

  end FACEACC_REPLACE_SP_AUPDATE;
  --#########################################################################################################

  procedure FACEACC_REPLACE_SP_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
    rRow            udo_faceacc_replace_sp%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow := faceacc_replace_sp_get(nrn => nRN);*/
    
  end FACEACC_REPLACE_SP_BDELETE;
  --#########################################################################################################

  procedure FACEACC_REPLACE_SP_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  rRow          udo_faceacc_replace_sp%rowtype;
  rGoodsSupply  goodssupply%rowtype;
  rStore        azsazslistmt%rowtype;
  --rRow_V        UDO_V_FACEACC_REPLACE_SP%rowtype;
  --rGoodsParties goodsparties%rowtype;

  rParent  udo_faceacc_replace%rowtype;
  SAGMAIL  PKG_STD.tSTRING := 'a.khokhryakov@module.ru';
  STO_LIST PKG_STD.tSTRING; -- Перечень E-mail адресов ответственных
  CTEXT    PKG_STD.tSTRING := 'Необходимо согласовать перенос между темами.' || CR;
  STITLE   PKG_STD.tSTRING := 'Перенос между темами';
  begin
    /* Заголовок */
    rRow := faceacc_replace_sp_get(nrn => nRN);
    /* Товарный запас */
    rGoodsSupply := usr_pkg_goodsparties.goodssupply_get(nrn => rRow.gsupply);
    /* Склад */
    rStore := udo_pkg_get.row_store(nrn => rGoodsSupply.store, nsmart => 0);
    /* ПРОВЕРКИ */
    /* Если склад товарного запаса не в каталогах СГП, ЭРИ, ДСЕ, Микроэлектроника */
    if usr_pkg_common.is_crn_in_hiercrn(ncrn => rStore.crn, shier_crn_list2 => '12152556;12047487;11924895;161976963') != 1 
      /*and utilizer not in ('STRIZHOVA_TN', 'KHOK')*/ then
      p_exception(0, 'Запрещено добавлять товарные запасы, склад которых находится в каталоге <%s>. %s'
                 ,get_acatalog_name_id(nflag_smart => 1, nrn => rStore.crn)
                 ,cr||f_docdescrs_get_description(sunitcode => 'UdoFaceAccountReplaceSp', ndocument => rRow.rn)); 
    end if;

    -- Отправим сообщение согласующим
    if rtrim(SAGMAIL) is not null then
      -- получатель
      STO_LIST := SAGMAIL;

      rParent := FACEACC_REPLACE_GET(nRN => rRow.Prn);
      --rGoodsParties := usr_pkg_goodsparties.GOODSPARTIES_GET(nRN => rGoodsSupply.Prn, nFLAGSMART => 0);
/*      select T.* into rRow_V 
        from UDO_V_FACEACC_REPLACE_SP T
       where T.NRN = nRN
         and rownum < 2;*/
--if utilizer = 'KHOK' then p_exception(0,rRow.gsupply || nRN); end if;
      for rec in (
        select NM.NOMEN_NAME, GP.SERNUMB, DO.CODE, DM.MEAS_MNEMO
          from GOODSPARTIES GP,
               INCOMDOC     DO,
               NOMMODIF     MD,
               DICNOMNS     NM,
               DICMUNTS     DM
         where GP.COMPANY = nCOMPANY
           and GP.RN = rGoodsSupply.Prn
           and DO.RN = GP.INDOC
           and MD.RN = GP.NOMMODIF
           and NM.RN = MD.PRN
           and DM.RN = NM.UMEAS_MAIN
      ) loop  
      -- Сообщение
      if rParent.Doctype = 11930679 then CTEXT := 'Инвентаризация темы' || CR; end if;
      CTEXT := CTEXT || CR || 'Перенос: ' || trim(rParent.Docpref) || '-' || trim(rParent.Docnumb);

      if rParent.Doctype = 11930679 then /* 19/11/2025 KHOK. Инвентаризация темы */
      CTEXT := CTEXT || CR || 'C темы <' || nvl(rParent.Theme_Code, UDO_F_GOODSSPLCLC_INORDER(NCOMPANY, rGoodsSupply.Prn)) || '> на Свободный остаток' || CR;
      else
      CTEXT := CTEXT || CR || 'C темы: <' || nvl(UDO_F_FACEACC_PRJCODE(nRN => rParent.FACEACC_FROM), UDO_F_GOODSSPLCLC_INORDER(NCOMPANY, rGoodsSupply.Prn)) ||
                           '> на тему: <' || UDO_F_FACEACC_PRJCODE(nRN => rParent.FACEACC_TO) || '>' || CR;
      end if;

      CTEXT := CTEXT || CR || 'Номенклатура: ' || rec.NOMEN_NAME || ' в количестве: ' || rRow.Quant || ' ' || rec.MEAS_MNEMO
                     || CR || 'Серия: ' || rec.SERNUMB || '. Партия: ' || rec.CODE;
                            --' Серия: ' || rRow_V.sGPARTY_SERNUMB || ' Партия: ' || rRow_V.sGPARTY_CODE;
      --CTEXT := CTEXT || CR || 'Остаток на складе: ' || rRow_V.nRESTFACT || CR;
      CTEXT := CTEXT || CR || 'Основание: ' || rParent.Valid_Doc || CR;
      CTEXT := CTEXT || CR || 'Примечание: '|| rParent.Note || CR;
      CTEXT := CTEXT || CR || 'Данное сообщение сформировано автоматически, не отвечайте на сообщение.';
      /* Отправка E-mail сообщения (по списку получателей) */
      PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => STO_LIST, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                    STITLE   => STITLE, -- Тема
                                    CTEXT    => CTEXT,
                                    --NFILE_BUFFER_IDENT in number := null, -- Прикладываемые документы (идентификатор файлового буфера)
                                    NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
      end loop;
    end if;
  end FACEACC_REPLACE_SP_CHECK_BASE;
  --#########################################################################################################




  --#########################################################################################################

  function FACEACC_REPLACE_HIST_GET
  /*
  Спецификация. Считывание
  */
  (
   nRN      in number
  ) 
  return udo_faceacc_replace_hist%rowtype
  is
    rRow udo_faceacc_replace_hist%rowtype;
  begin
    begin
      select * into rRow from udo_faceacc_replace_hist t where t.rn = nRN;
    exception
      when no_data_found then
        pkg_msg.record_not_found(nflag_smart => 0, ndocument => nRN, sunit_table => 'UDO_FACEACC_REPLACE_HIST');
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN %s в разделе %s.'
                   ,nRN, f_unitlist_getname(sunitcode => get_unitlist_code_table(nflag_smart => 1, stable_name => 'UDO_FACEACC_REPLACE_HIST')));
    end;
    return(rRow);
  end FACEACC_REPLACE_HIST_GET;
  --#########################################################################################################

  procedure FACEACC_REPLACE_HIST_AINSERT
  /*
  Спецификация. Добавление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow         udo_faceacc_replace_hist%rowtype;
  begin
    /* Спецификация */
    /*rRow := faceacc_replace_hist_get(nrn => nRN);*/
    
    /* ИСПРАВЛЕНИЯ */
    
    /* ПРОВЕРКИ */
    /* Базовая */
    faceacc_replace_hist_chk_base(nrn => nRN, ncompany => nCOMPANY);

  end FACEACC_REPLACE_HIST_AINSERT;
  --#########################################################################################################

  procedure FACEACC_REPLACE_HIST_BUPDATE
  /*
  Спецификация. Исправление. До
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
  begin
    null;
  end FACEACC_REPLACE_HIST_BUPDATE;
  --#########################################################################################################

  procedure FACEACC_REPLACE_HIST_AUPDATE
  /*
  Спецификация. Исправление. После
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow            udo_faceacc_replace_hist%rowtype;
    rGoodsSupply    goodssupply%rowtype;
  begin
    /* Заголовок */
    /* rRow := faceacc_replace_hist_get(nrn => nRN); */
    
    /* ИСПРАВЛЕНИЯ */

    /* ПРОВЕРКИ */
    /* Базовая */
    faceacc_replace_hist_chk_base(nrn => nRN, ncompany => nCOMPANY);

  end FACEACC_REPLACE_HIST_AUPDATE;
  --#########################################################################################################

  procedure FACEACC_REPLACE_HIST_BDELETE
  /*
  Спецификация. Удаление. До
  */
  (
   nRN        in number
  ,nCOMPANY   in number 
  ) 
  is
    rRow            udo_faceacc_replace_hist%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow := faceacc_replace_hist_get(nrn => nRN);*/
    
  end FACEACC_REPLACE_HIST_BDELETE;
  --#########################################################################################################

  procedure FACEACC_REPLACE_HIST_CHK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   nRN      in number
  ,nCOMPANY in number 
  ) 
  is
    rRow          udo_faceacc_replace_hist%rowtype;
  begin
    null;
    /* Заголовок */
    /*rRow := faceacc_replace_hist_get(nrn => nRN);*/

  end FACEACC_REPLACE_HIST_CHK_BASE;
  --#########################################################################################################

  
end USR_PKG_FACEACC_REPLACE;
/
