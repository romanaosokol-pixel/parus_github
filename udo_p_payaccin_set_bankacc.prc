create or replace procedure UDO_P_PAYACCIN_SET_BANKACC
(
  nCompany in number
 ,nRN in number -- RN записи 
 ,sAGNACC in varchar2
 ,sJURPERS in varchar2
 ,sSEPACCOP in varchar2 /*default 'Расход Собств.'*/ --132166 -- Расход Собств.
 ,nPERCEN  in number default 100
 ,nPaySum  in number default 0
 ,nSIGNCOPY in number default 0  -- 1 Копируем запись журнала платежей
) is
  /* Изменение реквизита платильщика во Входящем счете и плановом платеже */
  nAgnacc_in number;
  nTOOLSRN     number;
  dDOC_DATE    date;
  dPay_date    date;
  nlPERCENT    number(17,5);
  PAYIN        PAYACCIN%rowtype;
  PAYNT        PAYNOTES%rowtype;
  sCOMMENT     CLNEVNHIST.EVENT_DESCR%type;
  tCLHIST      CLNEVNHIST%rowtype;
  nTMP         number;
  nCLNOTETYP   number;
  nClntEvent   number;
  nCLNOTERN    number;
  nSetEvent    number := 0;
  nPAY_RN      number;
  nPAYCOUNT    number;
  nSEPACCOP    PKG_STD.tREF;
  nGOVCNTRID   PKG_STD.tREF;
  rGOVCNTRID   govcntrid%rowtype;
begin
  
   FIND_SEPACCOP_CODE
      (
        nFLAG_SMART   => 1,      -- признак генерации исключения (0 - да, 1 - нет)
        nFLAG_OPTION  => 1,      -- признак генерации исключения для пустого sCODE (0 - да, 1 - нет)
        nCOMPANY      => nCompany,
        sCODE         => sSEPACCOP,
        nRN           => nSEPACCOP
      );
  
   select * into PAYIN from PAYACCIN where RN = nRN;

   FIND_AGNACC_CODE_EX
      (
        nFLAG_SMART   => 0,            -- признак генерации исключения (0 - да, 1 - нет)
        nFLAG_OPTION  => 1,            -- признак генерации исключения для пустого sCODE (0 - да, 1 - нет)
        nCOMPANY      => nCompany,
        nAGENT        => 92146,        -- регистрационный номер контрагента
        sAGENT        => null,         -- мнемокод контрагента
        sCODE         => sAGNACC,      -- код строки реквизитов
        nRN           => nAgnacc_in    -- регистрационный номер реквизитов
      );
      
      /* Проверим правильность РС и назначения платежа */
     
    begin
      select t.*
        into rGOVCNTRID
        from GOVCNTRIDBANKS   gb
            ,GOVCNTRID        t
       where gb.prn = t.rn
         and gb.agnacc = nAgnacc_in;
    exception 
      when no_data_found then
        nGOVCNTRID := 0;
      when too_many_rows then
        nGOVCNTRID := 0;
    when others then
      p_exception(0,'Неопределённая ситуация при поиске реквизита банковского счета с RN: <%s> для ИГК <%s>'
                  ,nAgnacc_in
                  ,rGOVCNTRID.code); 
    end;
    
    if  nvl(nGOVCNTRID, 0) <> 0 then  
     /* РС с ИГК*/
      if nvl(nSEPACCOP, 0) = 0 then
        P_exception(0,'Расчётный счет с ИГК. Необходимо указать опрерацию по Отд. счету! %s'
                    ,nGOVCNTRID); 
      end if;
    else
      /* обычный РС */
      nSEPACCOP := null;
    end if;    
    
      
--p_exception(0, sJURPERS || ' - ' || sAGNACC || ' - ' || nAgnacc_in);

   if nAgnacc_in is not null then 

     dDOC_DATE := sysdate/* + 2*/;
     
     update PAYACCIN pc
        set pc.payeracc = nAgnacc_in
      where pc.rn = nRN;
     
     begin
       select ft.rn
         into nTOOLSRN 
         from FINPAYTOOL ft
        where ft.payer = 92146
          and ft.payer_acc = nAgnacc_in;
     exception when others then
       nTOOLSRN := null;
     end;
   end if;
   
   begin
     select ev.rn
       into nClntEvent
       from CLNEVENTS  ev 
     where ev.linked_rn = nRN
       and rownum = 1;     

     select eh.* 
       into tCLHIST
       from CLNEVENTS  ev 
           ,CLNEVNHIST eh       
     where ev.rn = nClntEvent
       and eh.event_stat = ev.event_stat
       and eh.prn = ev.rn
       and rownum = 1;     
   exception when others then
     tCLHIST.rn := null;
   end;
     
     
     /*перенесли из НБ - автоматического формирования планового платежа при утверждении счета */
     begin
         select count(pt.rn)
         into nPAYCOUNT
           from DOCLINKS dl, PAYNOTES pt 
          where dl.in_document = nRN
            and dl.in_unitcode = 'PaymentAccountsIn'
            and dl.out_unitcode = 'PayNotes'
            and dl.out_document = pt.rn     
            and pt.signplan = 1;
     exception when others then
       nPAYCOUNT := 0;
     end; 

     if nPAYCOUNT = 0 then
        UDO_P_PAYNOTES_MAKEPAY(
             nCOMPANY    => nCOMPANY      -- организация.
            ,nRN         => NRN           -- RN товарного документа
            ,sUNITCODE   => 'PaymentAccountsIn'    -- раздел товарного документа
            ,nSIGNPLAN   => 1             -- признак плановой записи: 0 - факт, 1 - план
            ,nBDoc_RN    => null
            ,nPAY_RN     => nPAY_RN       -- RN платежа
            ,nBDoc_CRN   => null      -- RN каталога платежа  
          );
     end if;  

     for PAY in (
       select pt.rn
       from DOCLINKS dl, PAYNOTES pt 
      where dl.in_document = nRN
        and dl.in_unitcode = 'PaymentAccountsIn'
        and dl.out_unitcode = 'PayNotes'
        and dl.out_document = pt.rn     
        and pt.signplan = 1
        and rownum = 1
        /*нет фактических платежей ????? */
       /* and not exists (select pt2.rn from DOCLINKS dl2, PAYNOTES pt2 
                         where dl2.in_document = nRN
                           and dl2.in_unitcode = 'PaymentAccountsIn'
                           and dl2.out_unitcode = 'PayNotes'
                           and dl2.out_document = pt2.rn     
                           and pt2.signplan = 0
                           and pt2.pay_plan = pt.rn)*/
      ) loop   

        select pn.* into PAYNT from PAYNOTES pn where pn.rn = PAY.RN;
         
        dPay_date:= PAYNT.pay_date;
        if nPERCEN <> 100 then
          nlPERCENT := nvl(nPERCEN,100)/100;
          PAYIN.SUMMWITHNDS := round(PAYIN.SUMMWITHNDS * nlPERCENT, 2);
          PAYIN.SUMM        := round(PAYIN.SUMM * nlPERCENT, 2);
          if nlPERCENT > 1 then p_exception(0,'Ошибка в проценте: '||nPERCEN); end if;
        elsif nPaySum > 0 then
          PAYIN.SUMM        := round(PAYIN.SUMM * nPaySum/PAYIN.SUMMWITHNDS, 2);
          PAYIN.SUMMWITHNDS := nPaySum;
        end if;
        
        
        if nPERCEN <> 100 or nPaySum > 0 or nSIGNCOPY = 1 or sAGNACC is not null then 
          if nSIGNCOPY = 0 then
            if nClntEvent is not null then  
              sCOMMENT := to_char(sysdate,'dd.mm.yyyy hh24.mi') || ': Новая сумма платежа: '|| PAYIN.SUMMWITHNDS;
              nSetEvent := 1;
            end if;
          else
            sCOMMENT := to_char(sysdate,'dd.mm.yyyy hh24.mi') || ': Добавлен плановый платеж на сумму: '|| PAYIN.SUMMWITHNDS;
            nSetEvent := 1;
          end if;
          if sAGNACC is not null then
            if sCOMMENT is null then
                 sCOMMENT := to_char(sysdate,'dd.mm.yyyy hh24.mi') ||': Изменен реквизит р/с оплаты на: '||sAGNACC;
            else sCOMMENT := sCOMMENT|| ' Изменен реквизит р/с оплаты на: '||sAGNACC;
            end if;
          end if; 

          if nSetEvent = 1 then 
            begin

                FIND_CLNEVNTYPENOTES_CODE
                  (
                    nFLAG_SMART            => 0,
                    nCOMPANY               => nCOMPANY,
                    sEVENT_TYPE            => 'ВходящиеСчета',
                    sEVENT_NOTE_TITLE      => 'ВхСчет_ИзмСумм',
                    nRN                    => nCLNOTETYP
                  );
              
                P_CLNEVNOTES_BASE_INSERT
                  (
                    nCOMPANY          => nCOMPANY,
                    nPRN              => nClntEvent, --tCLHIST.rn,
                    nHEADER           => nCLNOTETYP,
                    sNOTE             => sCOMMENT,
                    nRN               => nCLNOTERN
                  );

                P_CLNEVNHIST_BASE_INSERT
                  (
                    nPRN                  => nClntEvent,
                    sACTION_CODE          => 'CLNEVNOTES_INSERT',
                    nEVENT_STAT           => tCLHIST.Event_Stat,
                    nPERF_MARK            => tCLHIST.Perf_Mark,
                    nUSER_PROC            => tCLHIST.User_Proc,
                    nACTION_UNDO          => null,
                    nCLIENT_CLIENT        => tCLHIST.Client_Client,
                    nCLIENT_PERSON        => tCLHIST.Client_Person,
                    nSEND_CLIENT          => tCLHIST.Send_Client,
                    nSEND_DIVISION        => tCLHIST.Send_Division,
                    nSEND_POST            => tCLHIST.Send_Post,
                    nSEND_PERFORM         => tCLHIST.Send_Perform,
                    nSEND_PERSON          => tCLHIST.Send_Person,
                    nSEND_STAFFGRP        => tCLHIST.Send_Staffgrp,
                    nSEND_USER_GROUP      => tCLHIST.Send_User_Group,
                    sSEND_USER_AUTHID     => tCLHIST.Send_User_Authid,
                    sEVENT_DESCR          => null,
                    nNOTE                 => nCLNOTERN,
                    nACTION_REC           => tCLHIST.Action_Rec,
                    sLINKED_ACTION        => tCLHIST.Linked_Action,
                    sREASON               => tCLHIST.Reason,
                    nRN                   => nTMP
                  );


                 update PAYACCIN  pc
                    set pc.comments = sCOMMENT||CR||pc.comments
                  where pc.rn = nRN;

              exception when others then
                  P_exception(0,' !! '||nClntEvent||'  '||sCOMMENT||' - '||error_text);
              end;
          end if;
        end if;
        
        PAYNT.PAY_SUM     := PAYIN.SUMMWITHNDS;
        PAYNT.PAY_SUM_ACC := PAYIN.SUMMWITHNDS;
        PAYNT.PAY_SUM_TRD := PAYIN.SUMMWITHNDS;
        PAYNT.Tax_Sum     := PAYIN.SUMMWITHNDS - PAYIN.Summ;
        
        if (dPay_date is not null and dPay_date < dDOC_DATE) or (dPay_date is null) then
          dPay_date := dDOC_DATE;
        end if;  
            
        PAYNT.COMPANY  := nCOMPANY;
        PAYNT.PAY_DATE := dPay_date;
        PAYNT.PAYTOOL  := nTOOLSRN;
        PAYNT.AGNACC   := nAgnacc_in;

--if utilizer = 'KHOK' then p_exception(0, sJURPERS || ' - ' || sAGNACC || ' - ' || nSEPACCOP); end if;
        if SUBSTR(sAGNACC, 0, 2) = 'И-' then -- Надо бы еще добавить проверку типа счета. KHOK
          PAYNT.FINOPER  := 7036719; -- Расход с ИГК
          PAYNT.SEPACCOP := nSEPACCOP;
        else
          PAYNT.FINOPER  := 132166;  -- Расход Собств.
        end if;
        
        PKG_DOCLINKS_SMART.SMART_LINK(/*nCOMPANY => nCompany,*/ sUNITCODE => 'PayNotes', nDOCUMENT => PAYNT.RN);
        
        if nSIGNCOPY = 0  then
          UDO_P_PAYNOTES_BASE_UPDATE(PAYNT);
        else
          P_PAYNOTES_BASE_GETNEXTNUMB
                (
                  nCOMPANY      => PAYNT.COMPANY,
                  nJUR_PERS     => PAYNT.JUR_PERS,
                  dPAY_DATE     => PAYNT.PAY_DATE,
                  sPAY_PREF     => PAYNT.PAY_PREFIX,
                  sPAY_NUMB     => PAYNT.PAY_NUMBER
                );
           P_PAYNOTES_BASE_INSERT (             
                   nCOMPANY            => PAYNT.COMPANY
                  ,nCRN                => PAYNT.CRN
                  ,nJUR_PERS           => PAYNT.JUR_PERS 
                  ,sPAY_PREFIX         => PAYNT.PAY_PREFIX
                  ,sPAY_NUMBER         => PAYNT.PAY_NUMBER
                  ,nPAYER              => PAYNT.PAYER
                  ,dPAY_DATE           => PAYNT.PAY_DATE
                  ,nPAY_TYPE           => PAYNT.PAY_TYPE 
                  ,nSERV_PAY           => PAYNT.SERV_PAY
                  ,nFACEACC            => PAYNT.FACEACC
                  ,nGRAPHPOINT         => PAYNT.GRAPHPOINT
                  ,nFINOPER            => PAYNT.FINOPER
                  ,nPAYTOOL            => PAYNT.PAYTOOL
                  ,nVDOC_TYPE          => PAYNT.VDoc_Type
                  ,sVDOC_NUMB          => PAYNT.VDoc_Numb
                  ,dVDOC_DATE          => PAYNT.VDoc_Date
                  ,nFDOC_TYPE          => PAYNT.FDoc_type
                  ,sFDOC_NUMB          => PAYNT.FDOC_Numb
                  ,dFDOC_DATE          => PAYNT.FDOC_Date
                  ,nESCORT_DOCTYPE     => PAYNT.ESCORT_DOCTYPE
                  ,sESCORT_DOCNUMB     => PAYNT.ESCORT_DOCNUMB
                  ,dESCORT_DOCDATE     => PAYNT.ESCORT_DOCDATE
                  ,nCURRENCY           => PAYNT.CURRENCY
                  ,nCURR_RATE          => PAYNT.CURR_RATE
                  ,nCURR_RATE_BASE     => PAYNT.CURR_RATE_BASE
                  ,nCURR_RATE_ACC      => PAYNT.CURR_RATE_ACC
                  ,nCURR_RATE_PAY_ACC  => PAYNT.CURR_RATE_PAY_ACC
                  ,nCURR_RATE_TRD      => PAYNT.CURR_RATE_TRD
                  ,nCURR_RATE_BASE_TRD => PAYNT.CURR_RATE_BASE_TRD
                  ,nUPD_COURSE         => PAYNT.UPD_COURSE      ---Обновление 2024/03/28
                  ,nPAY_SUM            => PAYNT.PAY_SUM
                  ,nPAY_SUM_ACC        => PAYNT.PAY_SUM_ACC
                  ,nPAY_SUM_TRD        => PAYNT.PAY_SUM_TRD
                  ,nFINSPEC            => PAYNT.FINSPEC
                  ,nINTRDEBT           => PAYNT.INTRDEBT
                  ,nEDITABLE           => PAYNT.EDITABLE 
                  ,nSIGNPLAN           => PAYNT.SIGNPLAN 
                  ,nPAY_PLAN           => PAYNT.PAY_PLAN
                  ,nSIGNACNT           => PAYNT.SIGNACNT
                  ,nSIGNSPENT          => PAYNT.SIGNSPENT 
                  ,nSIGNACTIVE         => PAYNT.SIGNACTIVE
                  ,nTAXGROUP           => PAYNT.TAXGROUP
                  ,nSIGNOPACC          => PAYNT.SIGNOPACC
                  ,nTDOC_TYPE          => PAYNT.TDoc_Type
                  ,sTDOC_NUMB          => PAYNT.TDoc_Numb
                  ,dTDOC_DATE          => PAYNT.tDoc_Date
                  ,nTAX_SUM            => PAYNT.TAX_SUM
                  ,nTAX_PERCENT        => PAYNT.TAX_PERCENT
                  ,sCOMMENTS           => PAYNT.COMMENTS
                  ,sALTSIGN1           => PAYNT.ALTSIGN1
                  ,sALTSIGN2           => PAYNT.ALTSIGN2
                  ,sALTSIGN3           => PAYNT.ALTSIGN3
                  ,sALTSIGN4           => PAYNT.ALTSIGN4
                  ,sALTSIGN5           => PAYNT.ALTSIGN5
                  ,sALTSIGN6           => PAYNT.ALTSIGN6
                  ,sALTSIGN7           => PAYNT.ALTSIGN7
                  ,sALTSIGN8           => PAYNT.ALTSIGN8
                  ,sALTSIGN9           => PAYNT.ALTSIGN9
                  ,sALTSIGN10          => PAYNT.ALTSIGN10
                  ,sPAY_PURP           => PAYNT.PAY_PURP
                  ,nGOVCNTRID          => PAYNT.GOVCNTRID
                  ,nSEPACCOP           => PAYNT.SEPACCOP        -- Операция по отдельному счету
                  ,nAGNACC             => PAYNT.AGNACC          -- Реквизиты контрагента юридического лица
                  ,nPAYER_AGNACC       => PAYNT.PAYER_AGNACC    -- Реквизиты контрагента
                  ,nRN                 => PAYNT.rn
                  );
                  
             PKG_DOCLINKS.LINK(
                 nFLAG_SMART       => 1                      -- признак генерации исключения при дублировании связи (0 - да, 1 - нет)
                ,nCOMPANY          => PAYNT.COMPANY          -- регистрационный номер записи организации
                ,sIN_UNITCODE      => 'PaymentAccountsIn'    -- код раздела входного документа
                ,nIN_DOCUMENT      => nRN                    -- регистрационный номер записи входного документа
                ,sOUT_UNITCODE     => 'PayNotes'             -- код раздела выходного документа
                ,nOUT_DOCUMENT     => PAYNT.rn               -- регистрационный номер записи выходного документа
             );  

             /*  P_PAYNOTES_BASE_GDOC_SETLINKS            
                (
                  nCOMPANY      => PAYNT.COMPANY ,    -- организация.
                  nRN           => PAYNT.rn,    -- RN платежа
                  nGDOC_RN      => nRN,    -- RN товарного документа
                  sUNITCODE     => 'PaymentAccountsIn',  -- раздел товарного документа
                  nSIGN         => 0,    
                  \* признак разнесения превышения фактическим платежем неоплаченного остатка по товарному документу:
                      0 - не разносить остаток (при превышении выдать nRESULT = 1 или 2, для отката)
                      1 - не относить превышение на ТД и оставить его в виде несвязанного платежа
                      2 - отнести превышение на последний плановый платеж, связанный с ТД
                      3 - сформировать из превышения отдельный фактический платеж связанный с ТД и не связанный с плановым платежом *\
                  nRESULT     => nTMP     
                  \* признак того, что фактический платеж превышает неоплаченный остаток по товарному документу
                      и он разнесен по плановым платежам, с ним связанным:
                      0 - полностью
                      1 - частично (если нет плановых платежей = 2)
                      2 - не разнесен совсем *\
                );             */
       end if;  
          select sum (pn.PAY_SUM)
            into PAYNT.PAY_SUM
            from PAYNOTES pn, DOCLINKS dl
           where pn.rn = dl.out_document
             and dl.in_document = nRN
             and pn.signplan = 1;
             
            update PAYACCIN pc
               set pc.planpaysumm = /*pc.planpaysumm +*/ PAYNT.PAY_SUM
            where pc.rn = nRN;   
                       
       PKG_DOCLINKS_SMART.HARD_LINK(/*nCOMPANY => nCompany,*/ sUNITCODE => 'PayNotes', nDOCUMENT => PAYNT.RN);
      
      /*
        \* сохранение старых значений полей для управления финансами *\
        PKG_PAYNOTES.SET_PREV_STATE_FP(PAYNT.RN, PAYNT.FACEACC, PAYNT.FINOPER, PAYNT.PAY_SUM, PAYNT.PAY_SUM_ACC, PAYNT.CURRENCY, PAYNT.PAY_DATE);
        PKG_PAYNOTES.SET_PREV_PAY_PLAN(PAYNT.PAY_PLAN);
        PKG_PAYNOTES.SET_PREV_PAYTOOL(PAYNT.PAYTOOL);
        

         
        update PAYNOTES ppn
        set ppn.agnacc   =  nAgnacc_in,
            ppn.PAYTOOL  =  nTOOLSRN,
            ppn.pay_date =  dPay_date
        where ppn.rn = PAYNT.RN;*/
       
      end loop; 
  -- end if;
end UDO_P_PAYACCIN_SET_BANKACC;
/
