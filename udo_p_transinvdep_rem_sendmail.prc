create or replace procedure UDO_P_TRANSINVDEP_REM_SENDMAIL
(
  nCOMPANY in number, -- организация
  nRN      in number  -- рег.номер расходной накладной
) as
  /*
    30/05/2023 Марков МВ.
    Формирование уведомления по почте технологам о передаче ремонтного изделия в производство
    Неименованный блок (автоматический) на отработку расходной накладной в Ремонт
  */

  rROW TRANSINVDEPT%rowtype;
  sSHIP constant DICSHPVW.CODE%type := 'Ремонт'; -- вид отгрузки Ремонт
  nSHIP    number(17);
  sNOMEN   DICNOMNS.NOMEN_NAME%type;
  sARTICLE varchar2(40);
  sTMP     varchar2(2000);
  /* Сообщение */
  CTEXT       PKG_STD.tSTRING := 'Добрый день!' || chr(10) || 'Передано изделие в ремонт.';
  CTEXT2      PKG_STD.tSTRING;
  /* Тема */
  STITLE      PKG_STD.tSTRING := 'Ремонт';
  STO_LIST    PKG_STD.tSTRING; -- Перечень E-mail адресов
  STO_LIST2   PKG_STD.tSTRING := 'r.surov@module.ru;a.bogdanov@module.ru'; /* Перечень E-mail адресов для экономистов */
  
  nFcRoutLst          pkg_std.tref; 
  rFcRoutLst          fcroutlst%rowtype;
  rPerFCMatResource   fcmatresource%rowtype;
  rRlArticles         rlarticles%rowtype;
  nProject            pkg_std.tref; 
  rProject            project%rowtype;
  rFaceacc            faceacc%rowtype;
  sProjectFinAccAgn   agnlist.agnabbr%type;
  nProjectFinAccAgn   pkg_std.tref; 
  rProjectFinAccAgn   agnlist%rowtype;
  sSpecification      pkg_std.tstring;
  sCt_details         pkg_std.tlstring;
  sPJ_faceacc         pkg_std.tlstring;
  
  nNumber             pkg_std.tnumber; 
begin
  -- Вид отгрузки
  FIND_DICSHPVW_CODE(nFLAG_SMART => 0, nCOMPANY => nCOMPANY, sCODE => sSHIP, nRN => nSHIP);
  -- заголовок
  rROW.Rn := nRN;
  UDO_PKG_TRANSINVDEP_BASE_UTL.P_TRANSINVDEPT_ROW(rROW => rROW);
  --
  if rROW.Sheepview != nSHIP then
    return;
  end if;
  -- контроль наличия ШПЗ
  if rROW.Faceacc is null then
    p_exception(0, 'Не указан лицевой счет в заголовке расходной накладной.');
  end if;
  -- формирование уведомлений только по Ремонтам
  -- Тема
  sTMP := 'Накладная: ' || trim(rROW.Pref) || '-' || trim(rROW.Numb) || ' от ' ||
           to_char(rROW.Docdate, 'dd.mm.yyyy');
  STITLE := STITLE || ' ' || sTMP;
  -- Сообщение
  for rec in (select NM.NOMEN_CODE,
                     NM.NOMEN_NAME,
                     case
                       when TDS.ARTICLE is not null then
                        (select replace(RA.NAME, NM.NOMEN_CODE || '_') from RLARTICLES RA where RA.RN = TDS.ARTICLE)
                       else
                        ''
                     end as ARTICLE_NUMB,
                     TDS.ARTICLE
                from TRANSINVDEPTSPECS TDS,
                     NOMMODIF          MD,
                     DICNOMNS          NM
               where TDS.PRN = nRN
                 and TDS.NOMMODIF = MD.RN
                 and MD.PRN = NM.RN) loop
    sTMP := 'Изделие: ' || rec.nomen_name;
    sTMP := sTMP || chr(10) || 'Заводской номер: ' || rec.article_numb;
    sSpecification := sTMP;
    if length(CTEXT || chr(10) || sTMP) <= 4000 then
      CTEXT := CTEXT || chr(10) || sTMP;
    end if;

    /* ДЛЯ ПИСЬМА В ФИН.ОТДЕЛ*/
    nFcRoutLst  := null;
    rFcRoutLst  := null;
    nProject    := null;
    rProject    := null;
    sProjectFinAccAgn := null;
    nProjectFinAccAgn := null;
    rProjectFinAccAgn := null;
    sCt_details := null;
    sPJ_faceacc := null;


    for c in (
              select distinct ct.sdetails as sct_details, pj.numb as spj_faceacc
                from transinvcustspecs tics
                    ,transinvcust      tic
                    ,azsgsmwaystypes   ds
                    ,(
                      select s.faceacc
                            ,pkg_document.make_number(ndoc_type => h.doc_type
                                                     ,sdoc_pref => h.doc_pref
                                                     ,sdoc_numb => h.doc_numb
                                                     ,ddoc_date => h.doc_date) as sdetails
                        from stages s
                            ,contracts h
                       where s.prn = h.rn
                     ) ct
                    ,(
                      select s.faceacccust
                            ,f.numb
                        from projectstage s
                            ,project h
                            ,faceacc f
                       where s.prn = h.rn
                         and s.faceacc = f.rn(+)
                     ) pj
               where tics.article = rec.article  
                 and tic.rn = tics.prn
                 and tic.status != 0
                 and tic.stoper = ds.rn
                 and ds.keep_sign != 1
                 and tic.faceacc = ct.faceacc(+)
                 and tic.faceacc = pj.faceacccust(+)
              )
    loop
      if strin(c.sct_details, sCt_details) != 1 then
        sCt_details := strcombine(sCt_details, c.sct_details, ';');
      end if;
      if strin(c.sPJ_faceacc, sPJ_faceacc) != 1 then
        sPJ_faceacc := strcombine(sPJ_faceacc, c.sPJ_faceacc, ';');
      end if;
    end loop;
   
    /* Поиск маршрутного листа по изделию */
    usr_pkg_fcroutlst.fcroutlstsernumb_get_by_art(nflagsmart     => 1
                                                 ,ntoo_many_rows => 1
                                                 ,narticle       => rec.article
                                                 ,nrl_doctype    => 12140413
                                                 ,nrn            => nNumber
                                                 ,nprn           => nFcRoutLst);
    /* Если маршрутный лист найден */
    if nFcRoutLst is not null then
      /* Считывание записи маршрутного листа */
      rFcRoutLst := usr_pkg_fcroutlst.fcroutlst_get(nrn => nFcRoutLst);

      /* Считывание мат.ресурса На изделие */
      if rFcRoutLst.per_matres is not null then
        rPerFCMatResource := usr_pkg_fcmatresource.fcmatresource_get(nrn => rFcRoutLst.per_matres);
      end if;

      /* поиск проекта по лицевому счёту маршрутного листа */
      if rFcRoutLst.faceacc is not null then
        nProject := usr_pkg_project.project_get_rn_by_faceacc(nflagsmart => 1, nfaceacc => rFcRoutLst.faceacc);
        rFaceacc := usr_pkg_faceacc.FACEACC_GET(NRN => rFcRoutLst.faceacc);
      end if;
    end if;

    /* Если проект найден */
    if nProject is not null then
      /* Считывание записи проекта */
      rProject := usr_pkg_project.project_get(nrn => nProject);
    end if;

    /* Определяем мнемокод ответственного фин.отдела из свойства */
    sProjectFinAccAgn := usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 1082887, ndocument => rProject.rn);

    /* Определяем RN контрагента ответственного фин.отдела */
    find_agnlist_code(nflag_smart  => 1
                     ,nflag_option => 1
                     ,ncompany     => rRow.company
                     ,scode        => sProjectFinAccAgn
                     ,nrn          => nProjectFinAccAgn);

    /* Если RN контрагента ответственного фин.отдела найден */
    if nProjectFinAccAgn is not null then
      /* считывание контрагента */
      rProjectFinAccAgn := usr_pkg_agnlist.agnlist_get(nrn => nProjectFinAccAgn);
    end if;

    /* Если эл.адрес ответственного фин.отдела найден */
    if rProjectFinAccAgn.mail is not null then
      /* Если эл.адреса ответственного фин.отдела нет в списке адресов */
      if strin(rProjectFinAccAgn.mail, STO_LIST2) != 1 then
        /* добавляем эл.адрес ответственного фин.отдела в список */
        STO_LIST2 := strcombine(STO_LIST2, rProjectFinAccAgn.mail, ';');
      end if;                            
      CTEXT2    := 'Просьба определить шифр затрат по данному ремонту и сообщить его технологам.';
      /* используем эл.адреса администраторов */
    else
      STO_LIST2 := 'a.khokhryakov@module.ru;r.surov@module.ru;a.bogdanov@module.ru';
      CTEXT2    := 'Не удалось определить эл.адрес ответственного ФЭО';
    end if;

    /* Добавление в текст данных */
    CTEXT2    := strcombine(CTEXT2, nvl(sCt_details, 'Не найдено'), cr||'Договоры: ');
    CTEXT2    := strcombine(CTEXT2, nvl(sPJ_faceacc, nvl(rFaceacc.Numb, 'Не найдено')), cr||'ШПЗ: ');
    CTEXT2    := strcombine(CTEXT2, nvl(rPerFCMatResource.code, ' - '), cr||'Мат.ресурс "На изделие" (мнемокод): ');
    CTEXT2    := strcombine(CTEXT2, nvl(rPerFCMatResource.name, ' - '), cr||'Мат.ресурс "На изделие" (наименование): ');
    CTEXT2    := strcombine(CTEXT2, nvl(rProject.code, 'Не найден'), cr||'Проект: ');
--    CTEXT2    := strcombine(CTEXT2, rProject.name_usl, ' - ');
    CTEXT2    := strcombine(CTEXT2, nvl(to_char(rProjectFinAccAgn.agnabbr), 'Не найдено'), cr||'Ответственный фин.отдела: ');
    CTEXT2    := strcombine(CTEXT2, rec.nomen_code, cr||'Номенклатура (мнемокод): ');
    CTEXT2    := strcombine(CTEXT2, rec.nomen_name, cr||'Номенклатура (наименование): ');
    CTEXT2    := strcombine(CTEXT2, nvl(to_char(rec.article_numb), 'Не найдено'), cr||'Изделие (зав.№): ');
    CTEXT2    := strcombine(CTEXT2, nvl(pkg_document.make_number(ndoc_type => rFcRoutLst.doctype
                                                                ,sdoc_pref => rFcRoutLst.docpref
                                                                ,sdoc_numb => rFcRoutLst.docnumb
                                                                ,ddoc_date => rFcRoutLst.docdate)
                                       ,'Не найдено')
                           ,cr||'Маршрутный лист выпуска: ');

  end loop;

  --
  STO_LIST := 'i.yastrebova@module.ru;v.talanova@module.ru;m.markov@module.ru';

  -- получатели
  if length(CTEXT || chr(10) || 'Получатели:' || chr(10) || STO_LIST) <= 4000 then
    CTEXT := CTEXT || chr(10) || chr(10) || 'Получатели:';
    CTEXT := CTEXT || chr(10) || 'i.yastrebova@module.ru';
    CTEXT := CTEXT || chr(10) || 'v.talanova@module.ru';
    -- CTEXT := CTEXT || chr(10) || 'r.surov@module.ru';
  end if;

  /* Отправка E-mail сообщения (по списку получателей) */
  PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => STO_LIST, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                STITLE   => STITLE, -- Тема
                                CTEXT    => CTEXT,
                                --NFILE_BUFFER_IDENT      in number := null, -- Прикладываемые документы (идентификатор файлового буфера)
                                NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);

  /* Отправка E-mail экономисту или администраторам */
  PKG_EXS_EXT_MAIL.SEND_BY_LIST(STO_LIST => STO_LIST2, -- Список e-mail'ов получателей (разделитель - параметр "SeqSymb")
                                STITLE   => STITLE, -- Тема
                                CTEXT    => CTEXT2,
                                --NFILE_BUFFER_IDENT      in number := null, -- Прикладываемые документы (идентификатор файлового буфера)
                                NFORMAT => PKG_EXS_EXT_MAIL.NFORMAT_TEXT);
end;
/
