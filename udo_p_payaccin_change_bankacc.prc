create or replace procedure UDO_P_PAYACCIN_CHANGE_BANKACC(
  nCompany        in number
 ,nRN             in number   -- RN записи 
 ,sJURPERS        in varchar2 --  онтрагент
 ,sAGNACC         in varchar2 -- –еквизит контрагента
)
is
  /* »зменение реквизита получател€ во ¬ход€щем счете и плановом платеже */
  nAgnlist     number;
  nAgnacc_in   number;

  PAYIN        PAYACCIN%rowtype;
  PAYNT        PAYNOTES%rowtype;
  sCOMMENT     CLNEVNHIST.EVENT_DESCR%type;
  tCLHIST      CLNEVNHIST%rowtype;
  nClntEvent   number;

begin
   FIND_AGNLIST_CODE(nFLAG_SMART  => 0,
                     nFLAG_OPTION => 0,
                     nCOMPANY     => nCompany,
                     sCODE        => sJURPERS,
                     nRN          => nAgnlist);
   
   select * into PAYIN from PAYACCIN where RN = nRN;

   if nAgnlist != PAYIN.SUPPLIER then
     p_exception(0, '¬ыбран неправильный контрагент "' || sJURPERS || '" !!!');
   end if;
  
   FIND_AGNACC_CODE_EX (
        nFLAG_SMART   => 0,              -- признак генерации исключени€ (0 - да, 1 - нет)
        nFLAG_OPTION  => 1,              -- признак генерации исключени€ дл€ пустого sCODE (0 - да, 1 - нет)
        nCOMPANY      => nCompany,
        nAGENT        => PAYIN.SUPPLIER, -- регистрационный номер контрагента
        sAGENT        => null,           -- мнемокод контрагента
        sCODE         => sAGNACC,        -- код строки реквизитов
        nRN           => nAgnacc_in      -- регистрационный номер реквизитов
      );
--p_exception(0, sJURPERS || ' - ' || sAGNACC || ' - ' || nAgnlist || ' - ' ||  PAYIN.SUPPLIER || ' - ' || nAgnacc_in);
   
   update PAYACCIN pc set pc.supplacc = nAgnacc_in where pc.rn = nRN; -- мен€ем ¬ход€щий счет

   begin
     select ev.rn
       into nClntEvent
       from CLNEVENTS  ev
     where ev.linked_rn = nRN
       and rownum = 1;

/*     select eh.* -- ? историю не мен€ем ?
       into tCLHIST
       from CLNEVENTS  ev
           ,CLNEVNHIST eh
     where ev.rn = nClntEvent
       and eh.event_stat = ev.event_stat
       and eh.prn = ev.rn
       and rownum = 1;*/
   exception when others then
     tCLHIST.rn := null;
   end;

   for PAY in (
       select pt.rn
       from DOCLINKS dl, PAYNOTES pt 
      where dl.in_document = nRN
        and dl.in_unitcode = 'PaymentAccountsIn'
        and dl.out_unitcode = 'PayNotes'
        and dl.out_document = pt.rn     
        and pt.signplan = 1
        and rownum = 1
   ) loop
--p_exception(0, sJURPERS || ' - ' || sAGNACC || ' - ' || nAgnacc_in || ' - ' ||  nClntEvent || ' - ' || PAY.RN);
   
     select pn.* into PAYNT from PAYNOTES pn where pn.rn = PAY.RN;
         
     if sAGNACC is not null then
       sCOMMENT := to_char(sysdate,'dd.mm.yyyy hh24.mi') ||': »зменен реквизит р/с оплаты на: '||sAGNACC;

       --if nSetEvent = 1 then 
         begin
/*           FIND_CLNEVNTYPENOTES_CODE (
                nFLAG_SMART            => 0,
                nCOMPANY               => nCOMPANY,
                sEVENT_TYPE            => '¬ход€щие—чета',
                sEVENT_NOTE_TITLE      => '¬х—чет_»зм—умм',
                nRN                    => nCLNOTETYP
           );
              
           P_CLNEVNOTES_BASE_INSERT (
                nCOMPANY          => nCOMPANY,
                nPRN              => nClntEvent, --tCLHIST.rn,
                nHEADER           => nCLNOTETYP,
                sNOTE             => sCOMMENT,
                nRN               => nCLNOTERN
           );

           P_CLNEVNHIST_BASE_INSERT (
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
            );*/

            update PAYACCIN  pc
               set pc.comments = sCOMMENT||CR||pc.comments
             where pc.rn = nRN;

         exception when others then
           p_exception(0,' !! '||nClntEvent||'  '||sCOMMENT||' - '||error_text);
         end;
       --end if;
     end if;
        
     PAYNT.COMPANY      := nCOMPANY;
     PAYNT.PAYER_AGNACC := nAgnacc_in;
        
     PKG_DOCLINKS_SMART.SMART_LINK(/*nCOMPANY => nCompany,*/ sUNITCODE => 'PayNotes', nDOCUMENT => PAYNT.RN);
        
     UDO_P_PAYNOTES_BASE_UPDATE(PAYNT); -- ћен€ем все плановые платежи по счету

     PKG_DOCLINKS_SMART.HARD_LINK(/*nCOMPANY => nCompany,*/ sUNITCODE => 'PayNotes', nDOCUMENT => PAYNT.RN);

   end loop;

end UDO_P_PAYACCIN_CHANGE_BANKACC;
/

