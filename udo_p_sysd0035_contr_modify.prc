create or replace procedure UDO_P_SYSD0035_CONTR_MODIFY
/*
  Процедура изменения реквизитов утвержденного договора
  KHOK
  */
(
  nCOMPANY      in number
 ,nRN           in number
 ,sDOCTYPE_CODE in varchar2
 ,dDOC_DATE     in date
 ,sDOC_EXTNUMB  in varchar2
 ,dDOC_BEG      in date
 ,dDOC_END      in date
 ,sDOC_SUBJECT  in varchar2
 ,dDOC_REG      in date
 ,sDOC_AGNCODE  in varchar2
 ,nSUMM         in number        -- Сумма
 ,sTAXGR        in varchar2      -- Налоговая группа
 ,sCURR         in varchar2      -- Валюта
 ,sACC_CODE     in varchar2      ---Р/С контрагента договора
) as
  nOLD_DOCTYPE      number;
  sOLD_DOCTYPE_CODE doctypes.doccode%type;
  dOLD_DOCDATE      date;
  nDOC_TYPE         number;
  sDOC_PREF         contracts.doc_pref%type;
  sDOC_NUMB         contracts.doc_numb%type;
  --tFACEACC          udo_tp_sys0007_numtable;
  nJUR_PERS         number;
  sExt_number       contracts.ext_number%type;
  nEXT_numb         number:=0;
  nAGNRN            number;
  nOLD_AGNRN        number;
  nOLD_SUMM         number(17,2);
  nSUMM_TAX         number(17,2) := 0;
  nTAXRN            DICTAXGR.RN%type := null;
  nCURR             CURNAMES.RN%type := null;
  nStageNum         number := 0;
  nACC_AGENT_RN     number;  -- Контрагента
  sCONTAGENT        AGNLIST.AGNABBR%type;
  nCheck            number := 0;

  --sOLD_AGNCODE      agnacc.strcode%type;
  sMAIN_TEXT          varchar2(1024) := null;
  sFULL_TEXT          varchar2(1024) := null;
  sCALL_STACK         varchar2(1024) := null;

  CRETCUR       PKG_CURSORS.CurType;
  type          tCALC_CUR is record
  (
  NSUMM                PKG_STD.tLNUMBER,
  NSUMMWITHAXS         PKG_STD.tLNUMBER,
  NSUMMWITHTAX         PKG_STD.tLNUMBER,
  NSUMMWITOUTNDS       PKG_STD.tLNUMBER,
  NSUMMWITHOUTNCP      PKG_STD.tLNUMBER,
  NAXCISE_SUM          PKG_STD.tLNUMBER,
  NAXCISE_PRC          PKG_STD.tLNUMBER,
  NAXCISE_RET          PKG_STD.tLNUMBER,
  NNDS_SUM             PKG_STD.tLNUMBER,
  NNDS_PRC             PKG_STD.tLNUMBER,
  NNDS_RET             PKG_STD.tLNUMBER,
  NGSM_SUM             PKG_STD.tLNUMBER,
  NGSM_PRC             PKG_STD.tLNUMBER,
  NGSM_RET             PKG_STD.tLNUMBER,
  NNCP_SUM             PKG_STD.tLNUMBER,
  NNCP_PRC             PKG_STD.tLNUMBER,
  NNCP_RET             PKG_STD.tLNUMBER
  );
  RRETCUR       tCALC_CUR;

begin
  
  select count(sl.rn) into nCheck 
    from selectlist sl
   where sl.unitcode = 'Contracts' and sl.authid = USER;
   if nCheck > 1 then
     p_exception(0,'Выбрано ' || nCheck || ' строк!');
   end if;

  -- Разрешаем ссылки
  if sDOCTYPE_CODE is not null then
    find_doctypes_code_ex(0, 0, nCOMPANY, sDOCTYPE_CODE, nDOC_TYPE);
  end if;

  -- Считываем запись
  begin
    select t.doc_type
          ,d.doccode
          ,t.doc_date
          ,t.jur_pers
          ,t.ext_number
          ,t.jur_acc
          ,t.doc_sum
          ,ag.agnabbr
      into nOLD_DOCTYPE
          ,sOLD_DOCTYPE_CODE
          ,dOLD_DOCDATE
          ,nJUR_PERS
          ,sext_number
          ,nOLD_AGNRN
          ,nOLD_SUMM
          ,sCONTAGENT
      from contracts t
          ,doctypes  d
          ,AGNLIST   ag
     where t.rn = nRN
       and t.doc_type = d.rn
       and ag.rn = t.agent;
  exception
    when NO_DATA_FOUND then
      pkg_msg.RECORD_NOT_FOUND(0, nRN, 'Contracts');
  end;
--p_exception(0,'Выбрана ' || nRN);

  -- Можно изменить только нулевую сумму
/*  if (nOLD_SUMM != 0 and nSUMM > 0) then
    p_exception(0,' Сумма договора ненулевая. Для ее изменения обратитесь к Администратору!');
  end if;*/
  -- Налоговая группа может быть только одна
  begin
  if (instr(sTAXGR, ';') > 0) then
    P_MSGBOX_TEXT(sSQL_CODE   => '0',
                  sSQL_ERRM   => 'Превышено допустимое количество отмеченных записей налоговой группы.',
                  sMAIN_TEXT  => sMAIN_TEXT,
                  sFULL_TEXT  => sFULL_TEXT,
                  sCALL_STACK => sCALL_STACK);
    p_exception(0,'Налоговая группа может быть выбрана только одна!');
  else
    if nSUMM is not NULL then
      FIND_DICTAXGR_CODE(nFLAG_SMART => 0,
                         nCOMPANY    => nCOMPANY,
                         sCODE       => sTAXGR,
                         nRN         => nTAXRN);
      begin
        PKG_DICTAXIS_CALC.P_RESULT_CURSOR(nFLAG_SMART => 1,
                                          nCOMPANY    => nCOMPANY,
                                          dDATE       => sysdate,
                                          nSUMM_SIGN  => 1,
                                          nINSUMM     => nSUMM,
                                          sTAXGR      => sTAXGR,
                                          nQUANT      => 0,
                                          nNCP_SIGN   => 1,
                                          cRETCUR     => CRETCUR);
        if CRETCUR%ISOPEN then
          loop
            fetch CRETCUR into RRETCUR;
            if CRETCUR%NOTFOUND then
              exit;
            end if;
  --p_exception(0,' NSUMMWITHAXS ' || RRETCUR.NSUMMWITHTAX || '; NSUMM ' || RRETCUR.NSUMM || '; NNDS_SUM ' || RRETCUR.NNDS_SUM);
    --              NSTAGE_SUM := RRETCUR.NSUMMWITHAXS;
    --              NSTAGE_SUMTAX := RRETCUR.NSUMMWITHTAX;
    --              NSTAGE_SUM_NDS := RRETCUR.NNDS_SUM;
                  nSUMM_TAX := RRETCUR.NNDS_SUM;

          end loop;
          close CRETCUR;
        end if;
      end;
    end if;
  end if;
  end;
  
  if sCURR is not null then -- Ищем RN Валюты
    FIND_CURRENCY_BY_CODE(COMPANY => nCOMPANY,
                          CODE    => sCURR,
                          RN      => nCURR);
--p_exception(0,' sCURR ' || sCURR || '; nCURR ' || nCURR);
  end if;
  
  if sDOC_AGNCODE is not null then -- Ищем RN реквизита
    find_agnacc_code(nFLAG_SMART => 0,
                     COMPANY     => nCOMPANY,
                     MNEMO       => 'МОДУЛЬ',
                     CODE        => trim(sDOC_AGNCODE),
                     RN          => nAGNRN);
--p_exception(0,' nCOMPANY ' || nCOMPANY || '; sDOC_AGNCODE ' || sDOC_AGNCODE || '; nAGNRN ' || nAGNRN);
  end if;

  if sACC_CODE is not null then
    begin
    find_agnacc_code(nFLAG_SMART => 0,
                     COMPANY     => nCOMPANY,
                     MNEMO       => sCONTAGENT,
                     CODE        => sACC_CODE,
                     RN          => nACC_AGENT_RN); 
    exception when others then
      p_exception(0,'У контрагента %s нет реквизита %s',sCONTAGENT, sACC_CODE);
    end;                    
  end if;

  -- Если изменился тип документа или год, то получаем новый префикс и внутренний номер
  -- !!! Не меняем сам номер договора, а только дату !!!
/*  if (nDOC_TYPE is not null and nDOC_TYPE != nOLD_DOCTYPE) or
     (dDOC_DATE is not null and
     to_char(dDOC_DATE, 'yyyy') != to_char(dOLD_DOCDATE, 'yyyy'))
  then
    sDOC_PREF := to_char(dDOC_DATE, 'yyyy'); --- ??? формирование номера ???
    p_contracts_getnextnumb(nCOMPANY => nCOMPANY
                           ,sJUR_PERS => get_jurpersons_code_id(0, nJUR_PERS)
                           ,dDOC_DATE => dDOC_DATE
                           ,sDOC_TYPE => nvl(sDOCTYPE_CODE, sOLD_DOCTYPE_CODE)
                           ,sDOC_PREF => sDOC_PREF
                           ,sDOC_NUMB => sDOC_NUMB);
  end if;*/

  sext_number := nvl(trim(sDOC_EXTNUMB), sext_number);
  if sDOC_EXTNUMB is not null then
    sext_number := trim(sDOC_EXTNUMB);
  end if;
  if sext_number is not null then
    nEXT_numb := 0;
  else
    nEXT_numb := 1;
  end if;

  -- Изменяем шапку договора
  begin
  update contracts t
     set t.doc_type   = nvl(nDOC_TYPE, t.doc_type)
        ,t.doc_pref   = nvl(sDOC_PREF, t.doc_pref)
        ,t.doc_numb   = nvl(sDOC_NUMB, t.doc_numb)
        ,t.doc_date   = nvl(dDOC_DATE, t.doc_date)
        ,t.ext_number = sext_number
        ,t.inout_sign = nEXT_numb
        ,t.begin_date = nvl(dDOC_BEG, t.begin_date)
        ,t.end_date   = nvl(dDOC_END, t.end_date)
        ,t.subject    = nvl(sDOC_SUBJECT, t.subject)
        ,t.reg_date   = nvl(dDOC_REG, t.reg_date)
        ,t.jur_acc    = nvl(nAGNRN, t.jur_acc) -- Этапы обновляются автоматически
        ,t.taxgr      = nvl(nTAXRN, t.taxgr)
        ,t.currency   = nvl(nCURR, t.currency)
        ,t.doc_sumtax = nvl(nSUMM, t.doc_sumtax)
        ,t.doc_sum_nds= nvl(nSUMM_TAX, t.doc_sum_nds)
        ,t.doc_sum    = nvl(nSUMM-nSUMM_TAX, t.doc_sum)
        ,t.agnacc     = nvl(nACC_AGENT_RN, t.agnacc)
   where t.rn = nRN;
   exception when others then
     p_exception(0,'!! '||sext_number||' - '||error_text);
   end;

  /* исправление записи Этапа, если он всего один */
  begin
  if (nOLD_SUMM = 0 and nSUMM > 0) then
     select count(*) into nStageNum from STAGES where PRN = nRN;
--p_exception(0,' PRN ' || nRN || ' nStageNum ' || nStageNum);
     if nStageNum = 1 then
       update STAGES st
       set --NUMB          = sNUMB,
         --BEGIN_DATE    = dBEGIN_DATE,
         --END_DATE      = dEND_DATE,
         --DIRECTOR      = nDIRECTOR,
         TAXGR         = nvl(nTAXRN, st.taxgr),
         SUM_TYPE      = 0, --nSUM_TYPE вручную,
         STAGE_SUMTAX  = nvl(nSUMM, st.stage_sumtax),
         STAGE_SUM_NDS = nvl(nSUMM_TAX, st.stage_sum_nds),
         STAGE_SUM     = nvl(nSUMM-nSUMM_TAX, st.stage_sum)
         --AUTOCALC_SIGN = nAUTOCALC_SIGN,
         --DESCRIPTION   = sDESCRIPTION,
         --COMMENTS      = sCOMMENTS,
         --EXT_AGREEMENT = nEXT_AGREEMENT,
         --SIGN_SUM      = nSIGN_SUM,
         --JUR_ACC       = nJUR_ACC
       where PRN = nRN;

       if ( SQL%NOTFOUND ) then
         PKG_MSG.RECORD_NOT_FOUND(nRN, 'ContractsStages');
       end if;
     end if;
  end if;
  end;
  
  -- Если изменился тип документа или год, то получаем новый префикс и внутренний номер
  if (nDOC_TYPE is not null and nDOC_TYPE != nOLD_DOCTYPE) or
     (dDOC_DATE is not null and dDOC_DATE != dOLD_DOCDATE)
     then

   -- 01.04.2016 Добавлено обновление документа основания ЛС
   -- Лицевые счета
/*         DT.DOCCODE||' '|| nvl(trim(cn.ext_number),trim(cn.doc_pref)||'-'||trim(cn.doc_numb)) ||
             ', Эт.'||trim(st.numb)||', c '||to_char(st.begin_date,'dd.mm.yyyy') ||', по '||to_char(st.end_date,'dd.mm.yyyy')
*/
    for rec in(
      select st.faceacc
            ,trim(cn.doc_pref) as sPrev_DOC_PREF
            ,trim(cn.doc_numb) as sPrev_DOC_NUMB
            ,trim(st.numb)     as sPrev_STAGE_NUMB
        from STAGES st, CONTRACTS cn
       where cn.rn  = nRN
         and st.prn = cn.rn
         and cn.company = nCOMPANY
    ) loop
--p_exception(0,' sDOC_PREF ' || rec.sPrev_DOC_PREF || '; sDOC_NUMB ' || rec.sPrev_DOC_NUMB || '; sSTAGE_NUMB ' || rec.sPrev_STAGE_NUMB);

       update faceacc t
          set t.valid_doctype = nvl(nDOC_TYPE, t.valid_doctype)
--          ,t.valid_docnumb = nvl(UDO_F_CHEK_NUM_CONTACT (NRN => t.rn,UNIT =>'FaceAccounts' ,sEXT_NUMBER => sDOC_EXTNUMB) , t.valid_docnumb)
          ,t.valid_docnumb = nvl(rec.sPrev_DOC_PREF||'-'||rec.sPrev_DOC_NUMB||' Эт.'||rec.sPrev_STAGE_NUMB, t.valid_docnumb)
          ,t.valid_docdate = nvl(dDOC_DATE, t.valid_docdate)
       where t.rn = rec.faceacc;
--       where exists (select null from table(tFACEACC) r where r.column_value = t.rn);
    end loop;
  end if;

  -- Изменяем подчиненные документы
/*  if (nDOC_TYPE is not null and nDOC_TYPE != nOLD_DOCTYPE) or
     (dDOC_DATE is not null and dDOC_DATE != dOLD_DOCDATE) or
     (nAGNRN is not null and nAGNRN != nOLD_AGNRN)
  then
    --null;

    -- Получаем перечень лицевых счетов
    begin
      select s.faceacc bulk collect
        into tFACEACC
        from contracts t
            ,stages    s
       where t.rn = nRN
         and t.rn = s.prn;
    end;

    -- Входящие счета на оплату
    update payaccin t
       set t.vdoc_type = nvl(nDOC_TYPE, t.vdoc_type)
         --01.04.2016 Исправлен алгоритм формирования документа основания для документа (используется принцип генерации документа основания для ЛС)
       --   ,t.vdoc_num  = nvl(trim(sDOC_PREF) || trim(sDOC_NUMB), t.vdoc_num)
       --   ,t.vdoc_num  = nvl(UDO_F_CHEK_NUM_CONTACT (NRN => t.faceacc,UNIT =>'FaceAccounts' ,sEXT_NUMBER => sDOC_EXTNUMB) , t.vdoc_num)
          ,t.vdoc_date = nvl(dDOC_DATE, t.vdoc_date)
     where exists (select null
              from table(tFACEACC) r
             where r.column_value = t.faceacc);
    -- Счета на оплату
    update payacc t
       set t.vdoc_type = nvl(nDOC_TYPE, t.vdoc_type)
          --01.04.2016 Исправлен алгоритм формирования документа основания для документа (используется принцип генерации документа основания для ЛС)
          --,t.vdoc_numb = nvl(trim(sDOC_PREF) || trim(sDOC_NUMB), t.vdoc_numb)
          ,t.vdoc_numb = nvl(UDO_F_CHEK_NUM_CONTACT (NRN => t.faceacc,UNIT =>'FaceAccounts' ,sEXT_NUMBER => sDOC_EXTNUMB), t.vdoc_numb)
          ,t.vdoc_date = nvl(dDOC_DATE, t.vdoc_date)
     where exists (select null
              from table(tFACEACC) r
             where r.column_value = t.faceacc);
    -- Приходные накладные
    update ininvoices t
       set t.valid_doctype = nvl(nDOC_TYPE, t.valid_doctype)
           --01.04.2016 Исправлен алгоритм формирования документа основания для документа (используется принцип генерации документа основания для ЛС)
          --,t.valid_docnumb = nvl(trim(sDOC_PREF) || trim(sDOC_NUMB),t.valid_docnumb)
          ,t.valid_docnumb = nvl(UDO_F_CHEK_NUM_CONTACT (NRN => t.faceacc,UNIT =>'FaceAccounts' ,sEXT_NUMBER => sDOC_EXTNUMB),t.valid_docnumb)
          ,t.valid_docdate = nvl(dDOC_DATE, t.valid_docdate)
     where exists (select null
              from table(tFACEACC) r
             where r.column_value = t.faceacc);
    -- Расходные накладные
    update transinvcust t
       set t.accdoc  = nvl(nDOC_TYPE, t.accdoc)
       --01.04.2016 Исправлен алгоритм формирования документа основания для документа (используется принцип генерации документа основания для ЛС)
       -- ,t.accnumb = nvl(trim(sDOC_PREF) || trim(sDOC_NUMB), t.accnumb)
          ,t.accnumb = nvl(UDO_F_CHEK_NUM_CONTACT (NRN => t.faceacc,UNIT =>'FaceAccounts' ,sEXT_NUMBER => sDOC_EXTNUMB), t.accnumb)
          ,t.accdate = nvl(dDOC_DATE, t.accdate)
     where exists (select null
              from table(tFACEACC) r
             where r.column_value = t.faceacc);
    -- Журнал платежей
    update paynotes t
       set t.vdoc_type = nvl(nDOC_TYPE, t.vdoc_type)
           --01.04.2016 Исправлен алгоритм формирования документа основания для документа (используется принцип генерации документа основания для ЛС)
           --,t.vdoc_numb = nvl(trim(sDOC_PREF) || trim(sDOC_NUMB), t.vdoc_numb)
          ,t.vdoc_numb = nvl(UDO_F_CHEK_NUM_CONTACT (NRN => t.faceacc,UNIT =>'FaceAccounts' ,sEXT_NUMBER => sDOC_EXTNUMB) , t.vdoc_numb)
          ,t.vdoc_date = nvl(dDOC_DATE, t.vdoc_date)
     where exists (select null
              from table(tFACEACC) r
             where r.column_value = t.faceacc);

  end if;
*/

end UDO_P_SYSD0035_CONTR_MODIFY;
/

