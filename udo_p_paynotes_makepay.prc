create or replace procedure UDO_P_PAYNOTES_MAKEPAY
(
   nCOMPANY    in number   -- организация.
  ,nRN         in number   -- RN товарного документа
--  ,nIDENT      -- для занесения нескольких записей как некоей совокупности
  ,sUNITCODE   in varchar  -- раздел товарного документа
--  ,dDATE       in date     -- дата платежа
  ,nSIGNPLAN   in number   -- признак плановой записи: 0 - факт, 1 - план
  ,nBDoc_RN    in number   -- RN банковского документа. если nSIGNPLAN = 0 - факт
  ,nBDoc_CRN   in number   -- RN каталога  банковского документа 
  ,nPAY_RN     out number  -- RN платежа
  
) is
  InDOC     PAYACCIN%rowtype;
  FAC_DOC   FACEACC%rowtype;
  PAYNT     PAYNOTES%rowtype;
  PAYPLAN   PAYNOTES%rowtype;
  BankDk    BANKDOCS%rowtype;
  InPay     PAYACC%rowtype;
  sCATALOG     ACATALOG.NAME%type;
  sPAY_TYPE     varchar(20) := 'ОкончатРасчет';
  sFINOPER      varchar(20) := null; 
  nFakt_sumIn    number(17,2);
  nFakt_sumBD    number(17,2);
  nPAY_sumRem    number(17,2);
  dPAY_DATE      date;
  nMODL_Agent    number(17) := 92146;  /*ИД Модуля*/
  nTMP           number;
  sTMP           PKG_STD.tLSTRING;

begin

   if nSIGNPLAN = 0 and nBDoc_RN is not null then
  

     /* считаем банковский документ */
      select * 
      into BankDk
      from BANKDOCS bd
      where bd.rn = nBDoc_RN;
      
      if   upper(BankDk.Pay_Info) like '%АВАНС%' 
        or upper(BankDk.Pay_Info) like '%ПРЕДОПЛАТА%'
        then 
        sPAY_TYPE := 'ПредоплатаБезнал';
      end if;
          
      /*найдем фактический платеж для банковского документа. Должен быть один для связки */  
      begin
         select pnt.*
           into PAYNT
           from PAYNOTES pnt, DOCLINKS dl3, DOCLINKS dl2
          where pnt.signplan     = 0
            and DL3.IN_DOCUMENT  = nBDoc_RN
            and dl3.in_unitcode  = 'BankDocuments'
            and dl3.out_unitcode = 'PayNotes'
            and dl3.out_document = pnt.rn
            and DL2.IN_DOCUMENT  = nRN
            and dl2.in_unitcode  = sUNITCODE
            and dl2.out_unitcode = 'PayNotes'
            and dl2.out_document = pnt.rn;
      exception 
         when NO_DATA_FOUND then
           PAYNT.rn := 0;
         when TOO_MANY_ROWS THEN
           PAYNT.rn := 0;
           p_exception(0, 'Для банковского документа и счета найдено несколько фактических платежей.');
      end;

  /*    if PAYNT.rn = 0 then  
        PAYNT.PAYER        := InPay.AGENT; 
        PAYNT.PAYER_AGNACC := BankDk.Agent_To_Acc;         
        PAYNT.AGNACC       := BankDk.Agent_From_Acc;
      else
        PAYNT.PAYER        := InPay.AGENT; 
        PAYNT.PAYER_AGNACC := BankDk.Agent_From_Acc;         
        PAYNT.AGNACC       := BankDk.Agent_To_Acc;
      end if;*/
   elsif nSIGNPLAN = 1 then
     /*Для планового платежа найдем связь со счетом */
       begin
         select pnt.*
           into PAYNT
           from PAYNOTES pnt, DOCLINKS dl2
          where pnt.signplan     = 1
            and DL2.IN_DOCUMENT  = nRN
            and dl2.in_unitcode  = sUNITCODE
            and dl2.out_unitcode = 'PayNotes'
            and dl2.out_document = pnt.rn;
      exception 
         when NO_DATA_FOUND then
           PAYNT.rn := 0;
         when TOO_MANY_ROWS THEN
           PAYNT.rn := 0;
           p_exception(0, 'Для банковского документа и счета найдено несколько фактических платежей.');
      end;  
   end if; 

     if PAYNT.rn = 0 then

      
        /* поиск каталога платежа из настроек ЖП */
        sCATALOG := GET_OPTIONS_STR('Realiz_PayNotes_Catalog', nCOMPANY);
        if rtrim(sCATALOG) is null then
          P_EXCEPTION( 0,'В настройках системы не определен каталог журнала платежей по умолчанию.' );
        else
          FIND_ACATALOG_NAME ( 0, nCOMPANY, null, 'PayNotes', sCATALOG, PAYNT.CRN );
        end if;

       /* */
        PAYNT.SERV_PAY            := 0;
        PAYNT.Curr_Rate           := 1;
        PAYNT.Curr_Rate_Base      := 1;
        PAYNT.CURR_RATE_ACC       := 1;
        PAYNT.Curr_Rate_Pay_Acc   := 1;
        PAYNT.Curr_Rate_Trd       := 1;
        PAYNT.Curr_Rate_Base_Trd  := 1;
        PAYNT.SIGNACNT            := 1;
        PAYNT.SIGNSPENT           := 0;
        PAYNT.SIGNACTIVE          := 1;
        PAYNT.EDITABLE            := 1;
        PAYNT.SIGNOPACC           := 1;
        PAYNT.SIGNPLAN            := nSIGNPLAN;
          
          
        if nBDoc_RN is null then
          PAYNT.FDOC_TYPE    := null;
          PAYNT.FDOC_NUMB    := null;
          PAYNT.FDOC_DATE    := null;
        else
          PAYNT.FDOC_TYPE    := BankDk.From_Doctype;
          PAYNT.FDOC_NUMB    := trim(BankDk.From_Numb);
          PAYNT.FDOC_DATE    := BankDk.From_Date;
          
       /*   PAYNT.PAYER        := BankDk.; 
          PAYNT.PAYER_AGNACC := BankDk.;
          PAYNT.AGNACC       := BankDk.;*/
          PAYNT.FINOPER      := BankDk.TYPE_OPER;   
        end if;
          
         /*Входящий счет на оплату, расход денег */ 
       if sUNITCODE = 'PaymentAccountsIn' then 

          begin
            select pyn.* 
            into InDOC
            from PAYACCIN pyn
            where pyn.rn = nRN;
          exception when others then
            InDOC.rn := null;
       --     p_exception(0,'err = '||error_text);
          end;

         
          if InDOC.rn is not null then
            select * 
            into FAC_DOC
            from FACEACC fc
            where fc.rn = InDOC.Faceacc;
          end if;


          PAYNT.PAY_DATE := nvl(BankDk.Bank_Docdate, nvl(InDOC.Pay_Date,InDoc.Doc_Date));

          if nSIGNPLAN = 1 then
            PAYNT.PAYER        := InDOC.Supplier; 
            PAYNT.PAYER_AGNACC := InDOC.SUPPLACC;
            PAYNT.AGNACC       := InDOC.Payeracc;
            PAYNT.Curr_Rate_Base:=InDOC.Curbase;

            begin
              select a.strcode into sTMP from agnacc a where a.rn like PAYNT.AGNACC;
            exception
              when NO_DATA_FOUND then sTMP := '';
            end;
            if   UPPER(SUBSTR(sTMP, 0, 3)) = 'ЛС-' then -- BANKACC_TYPE = 6525523
                 sFINOPER      := 'Расходы КЗН';
            elsif UPPER(SUBSTR(sTMP, 0, 2)) = 'И-' then -- BANKACC_TYPE = 1080004
                 sFINOPER      := 'Расход с ИГК';
            else sFINOPER      := 'Расход Собст';       -- 535778
            end if;

          else
            PAYNT.PAYER        := BankDk.Agent_To; 
            PAYNT.PAYER_AGNACC := BankDk.Agent_To_Acc;
            PAYNT.AGNACC       := BankDk.Agent_From_Acc;
            sFINOPER           := null;
            PAYNT.FINOPER      := BankDk.TYPE_OPER;
          end if;

         
          PAYNT.PAY_PURP     := BankDk.Pay_Info; --InDOC.Comments;                 
          PAYNT.CURRENCY     := InDOC.Currency;
          PAYNT.TDOC_TYPE    := InDOC.Doc_Type;
          PAYNT.TDOC_NUMB    := trim(InDOC.Doc_Numb);
          PAYNT.TDOC_DATE    := InDOC.Doc_Date;
          PAYNT.COMMENTS     := 'Сформированно автоматически для Вход.Счета.';
          if InDOC.Summ > 0 then
            PAYNT.TAX_PERCENT  := (InDOC.Summwithnds - InDOC.Summ)*100 / InDOC.Summ; 
          else
            PAYNT.TAX_PERCENT  := 0;
          end if;

        /* ставка НДС*/
        begin
          select distinct ps.taxgr
          into PAYNT.TAXGROUP
          from PAYACCINSPEC PS
          where ps.prn = nRN
          and rownum = 1;
        exception 
          when TOO_MANY_ROWS then
            PAYNT.TAXGROUP := null;
          when NO_DATA_FOUND then
            PAYNT.TAXGROUP := null;
        end;
        /*Счет на оплату Приход денег*/
       elsif sUNITCODE = 'PaymentAccounts' then
          begin
            select * 
            into InPay
            from PAYACC pn
            where pn.rn = nRN;
          exception when others then
            InPay.rn := null;
          end;
          PAYNT.PAY_DATE := nvl(BankDk.Bank_Docdate, nvl(InPay.Saledate,InPay.Accdate));
          PAYNT.Graphpoint  := InPay.Graphpoint;

          if InPay.rn is not null then
            select * 
            into FAC_DOC
            from FACEACC fc
            where fc.rn = InPay.Faceacc;
          end if;      

          begin
            select ft.rn 
            into PAYNT.PAYTOOL
            from FINPAYTOOL ft
            where ft.payer_acc = BankDk.Agent_to_Acc
              and ft.payer     = BankDk.Agent_To;
          exception when others then
            PAYNT.PAYTOOL := null;
          end;
          
          if nSIGNPLAN = 1 then
            PAYNT.PAYER        := InPay.AGENT; 
            PAYNT.PAYER_AGNACC := InPay.AGNACC;
            PAYNT.AGNACC       := InPay.SELF_AGNACC;

            begin
              select a.strcode into sTMP from agnacc a where a.rn like PAYNT.AGNACC;
            exception
              when NO_DATA_FOUND then sTMP := '';
            end;
            if   UPPER(SUBSTR(sTMP, 0, 3)) = 'ЛС-' then
                 sFINOPER      := 'Приход КЗН';
            elsif UPPER(SUBSTR(sTMP, 0, 2)) = 'И-' then
                 sFINOPER      := 'Приход на ИГК';
            else sFINOPER      := 'Приход Собст';
            end if;

          else
            PAYNT.PAYER        := BankDk.Agent_From; 
            PAYNT.PAYER_AGNACC := BankDk.Agent_From_Acc;
            PAYNT.AGNACC       := BankDk.Agent_To_Acc;
            sFINOPER           := null;
            PAYNT.FINOPER      := BankDk.TYPE_OPER;
                            
          end if;
          
          PAYNT.PAY_PURP     := BankDk.Pay_Info;     
          PAYNT.CURRENCY     := InPay.Currency;
          PAYNT.TDOC_TYPE    := InPay.DOCTYPE;
          PAYNT.TDOC_NUMB    := trim(InPay.NUMB);
          PAYNT.TDOC_DATE    := InPay.ACCDATE;
          PAYNT.COMMENTS     := 'Сформированно автоматически для Исх.Счета.';    
          if  InPay.Summ > 0 then   
            PAYNT.TAX_PERCENT  := (InPay.Summwithnds - InPay.Summ)*100 / InPay.Summ; 
          else
            PAYNT.TAX_PERCENT  := 0;
          end if;
          InDOC.summwithnds  := InPay.Summwithnds;  

        /* ставка НДС*/
        begin
          select distinct ps.taxgr
          into PAYNT.TAXGROUP
          from PAYACCSPECS  PS
          where ps.prn = nRN
          and rownum = 1;
        exception 
          when TOO_MANY_ROWS then
            PAYNT.TAXGROUP := null;
          when NO_DATA_FOUND then
            PAYNT.TAXGROUP := null;
        end;
              
       elsif sUNITCODE = 'FaceAccounts' then
          begin
            select * 
            into FAC_DOC
            from FACEACC fc
            where fc.rn = nRN;
          exception when others then
            FAC_DOC.rn := null;
          end;
          PAYNT.PAY_DATE := nvl(BankDk.Bank_Docdate, nvl(InPay.Saledate,InPay.Accdate));
          
          if BankDk.Agent_From = nMODL_Agent then
            /*Расход денег*/
            PAYNT.PAYER        := BankDk.Agent_To; 
            PAYNT.PAYER_AGNACC := BankDk.Agent_To_Acc;
            PAYNT.AGNACC       := BankDk.Agent_From_Acc;
          else
            /*Приход денег*/
            PAYNT.PAYER        := BankDk.Agent_From; 
            PAYNT.PAYER_AGNACC := BankDk.Agent_From_Acc;
            PAYNT.AGNACC       := BankDk.Agent_To_Acc;
          end if;
          sFINOPER           := null;
          PAYNT.FINOPER      := BankDk.TYPE_OPER;
          
          PAYNT.PAY_PURP     := BankDk.Pay_Info;
          PAYNT.CURRENCY     := FAC_DOC.Currency;
          PAYNT.TDOC_TYPE    := null;
          PAYNT.TDOC_NUMB    := null;
          PAYNT.TDOC_DATE    := null;
          PAYNT.COMMENTS     := 'Сформированно автоматически для лицевого счета.';        
          PAYNT.TAX_PERCENT  := 0;            
          PAYNT.TAXGROUP     := null;
          InPay.Summwithnds  := 0;

       end if;
       /* Найдем плановый платеж */
       if sUNITCODE in ('PaymentAccounts','PaymentAccountsIn') then
          if nRN is not null then
            PAYPLAN.rn := null;
            /* Поиск полного совпадения */
            for pln in (
              select pn.*,
                      /* сумма фактических платежей связанных с планом */
                     (select sum(ft.pay_sum) from PAYNOTES ft where ft.pay_plan = pn.rn and ft.signplan = 0) as nSUM_FACT
                from DOCLINKS dl1, PAYNOTES pn
                where dl1.in_document = nRN
                  and dl1.in_unitcode = sUNITCODE
                  and dl1.out_unitcode = 'PayNotes'
                  and dl1.out_document = pn.rn
                  and pn.signplan      = 1
                  order by PN.PAY_DATE 
                 -- and rownum = 1
            ) loop
              pln.nSUM_FACT := nvl(pln.nSUM_FACT,0);
              if pln.nSUM_FACT = 0 and pln.PAY_SUM = PAYNT.PAY_SUM then
                PAYPLAN.rn       := pln.rn;
                PAYPLAN.SEPACCOP := pln.sepaccop;
                exit;            
              end if;
            end loop; 
            if PAYPLAN.rn is null then
              /* Поиск частичного совпадения, остаток от плана равен факту */
              for pln in (
                select pn.*,
                        /* сумма фактических платежей связанных с планом */
                       (select sum(ft.pay_sum) from PAYNOTES ft where ft.pay_plan = pn.rn and ft.signplan = 0) as nSUM_FACT
                  from DOCLINKS dl1, PAYNOTES pn
                  where dl1.in_document = nRN
                    and dl1.in_unitcode = sUNITCODE
                    and dl1.out_unitcode = 'PayNotes'
                    and dl1.out_document = pn.rn
                    and pn.signplan      = 1
                    order by PN.PAY_DATE
                   -- and rownum = 1
              ) loop
                pln.nSUM_FACT := nvl(pln.nSUM_FACT,0);
                if pln.nSUM_FACT < pln.PAY_SUM then 
                  if (pln.PAY_SUM - pln.nSUM_FACT) = PAYNT.PAY_SUM then
                    PAYPLAN.rn       := pln.rn;
                    PAYPLAN.SEPACCOP := pln.sepaccop;
                    exit;            
                  end if;
                end if;
              end loop;  

            end if;
            
            if PAYPLAN.rn is null then
              /* Поиск частичного совпадения, остатка от плана достаточно дляя факта */
              for pln in (
                select pn.*,
                        /* сумма фактических платежей связанных с планом */
                       (select sum(ft.pay_sum) from PAYNOTES ft where ft.pay_plan = pn.rn and ft.signplan = 0) as nSUM_FACT
                  from DOCLINKS dl1, PAYNOTES pn
                  where dl1.in_document = nRN
                    and dl1.in_unitcode = sUNITCODE
                    and dl1.out_unitcode = 'PayNotes'
                    and dl1.out_document = pn.rn
                    and pn.signplan      = 1
                    order by PN.PAY_DATE
                   -- and rownum = 1
              ) loop
                pln.nSUM_FACT := nvl(pln.nSUM_FACT,0);
                if pln.nSUM_FACT < pln.PAY_SUM then 
                  if (pln.PAY_SUM - pln.nSUM_FACT) <= PAYNT.PAY_SUM then
                    PAYPLAN.rn       := pln.rn;
                    PAYPLAN.SEPACCOP := pln.sepaccop;
                    exit;            
                  end if;
                end if;
              end loop;  

            end if;
            if PAYPLAN.rn is null then
              return;
            end if; 
          end if;
       end if;
       
        PAYNT.PAY_PLAN := PAYPLAN.rn;
        /* Заполним фин.операцию по отдельному счету*/
        PAYNT.SEPACCOP := nvl(PAYPLAN.SEPACCOP, BankDk.Sepaccop);
        /* Если в банке операция пустая - добавим */
        if PAYPLAN.SEPACCOP is not null then
          update BANKDOCS bd set bd.sepaccop = PAYPLAN.SEPACCOP where bd.rn = BankDk.rn; 
        end if;
         
         /* из лицевого счета*/  
        PAYNT.FACEACC      := FAC_DOC.RN;
        PAYNT.VDOC_TYPE    := FAC_DOC.VALID_DOCTYPE;
        PAYNT.VDOC_NUMB    := trim(FAC_DOC.VALID_DOCNUMB);
        PAYNT.VDOC_DATE    := FAC_DOC.VALID_DOCDATE;
        PAYNT.GOVCNTRID    := FAC_DOC.GOVCNTRID;
       /*Юридическое лицо*/    
        PAYNT.JUR_PERS := FAC_DOC.Jur_Pers;

       /* поиск префикса платежа из настроек ЖП */
        PAYNT.PAY_PREFIX := GET_OPTIONS_STR('Realiz_PayNotes_Prefix', nCOMPANY);
        if rtrim(PAYNT.PAY_PREFIX) is null then
          P_EXCEPTION( 0,'В настройках системы не определен префикс платежей по умолчанию.' );
          PAYNT.PAY_NUMBER := null;
        else
          /* генерация номера платежа */
          P_PAYNOTESACCBUF_BASE_NEXTNUMB( nCOMPANY, null, PAYNT.JUR_PERS, PAYNT.PAY_DATE, PAYNT.PAY_PREFIX, PAYNT.PAY_NUMBER );
        end if;
        
       /* вид финансовой операции */
        if ( rtrim( sFINOPER ) is not null ) then
          P_FIND_DICTOPER_BY_MNEMO ( nCOMPANY, sFINOPER, PAYNT.FINOPER );
/*        else
          PAYNT.FINOPER := null;*/
        end if;
           
       /* тип финансовой операции */
        if ( rtrim( sPAY_TYPE ) is not null ) then
          FIND_DICPAYVW_CODE( 0, nCOMPANY, sPAY_TYPE, PAYNT.PAY_TYPE );
        else
          PAYNT.PAY_TYPE := null;
        end if;
        
        begin
          select ft.rn 
            into PAYNT.PAYTOOL
            from FINPAYTOOL ft
           where ft.payer_acc = PAYNT.AGNACC
             and ft.payer     = 92146; /*BankDk.Agent_From;*/
        exception when others then
          PAYNT.PAYTOOL := null;
        end;                    

     end if;         



     
      /* Сумма всех фактических платежей на счете */
      begin
        select sum(pnt.pay_sum)
          into nFakt_sumIn 
         from PAYNOTES pnt, DOCLINKS dl3
        where pnt.signplan     = 0
          and DL3.IN_DOCUMENT  = nRN
          and dl3.out_document = pnt.rn
          and dl3.in_unitcode  = sUNITCODE
          and dl3.out_unitcode = 'PayNotes'
          and pnt.rn != PAYNT.rn;
     exception when others then
       nFakt_sumIn := 0;
     end; 
       
        /* Сумма всех фактических платежей на банковском документе */
      if  nBDoc_RN is not null then 
        begin
          select sum(pnt.pay_sum)
            into nFakt_sumBD 
           from PAYNOTES pnt, DOCLINKS dl3
          where pnt.signplan     = 0
            and DL3.IN_DOCUMENT  = nBDoc_RN
            and dl3.out_document = pnt.rn
            and dl3.in_unitcode  = 'BankDocuments'
            and dl3.out_unitcode = 'PayNotes'
            and pnt.rn != PAYNT.rn;
       exception when others then
         nFakt_sumBD := 0;
       end; 
     else
        nFakt_sumBD := 0;
     end if;

     nFakt_sumIn := nvl(nFakt_sumIn,0);
     InDOC.summwithnds := nvl(InDOC.summwithnds,0);
     
     nPAY_sumRem := InDOC.summwithnds  - nFakt_sumIn; 
     nFakt_sumBD := BankDk.Pay_Sum     - nvl(nFakt_sumBD,0); 

       
     /* Доступная сумма для платежа */
     if nPAY_sumRem > nFakt_sumBD and nSIGNPLAN = 0 or  sUNITCODE = 'FaceAccounts'  then
       nPAY_sumRem := nFakt_sumBD;
     end if; 
      
     PAYNT.PAY_SUM      := nPAY_sumRem;
     PAYNT.PAY_SUM_ACC  := nPAY_sumRem;
     PAYNT.PAY_SUM_TRD  := nPAY_sumRem;
     PAYNT.TAX_SUM      := nPAY_sumRem - Round(nPAY_sumRem * 100/(100 + PAYNT.TAX_PERCENT),2);
      
     if PAYNT.TAX_PERCENT < 0 then
        PAYNT.TAX_PERCENT := 0;
     end if;
     if  PAYNT.TAX_SUM < 0 then
        PAYNT.TAX_SUM := 0;
     end if;
--p_exception(0,' !!! '|| PAYNT.rn);       

     if PAYNT.PAY_SUM > 0 then
    /* Формирование платежа*/
     if PAYNT.rn = 0 then
       IF nPAY_sumRem < 0 then p_exception(0, 'Сумма платежа меньше 0. !! RN= '||nRN||' Unit='||nFakt_sumIn||' -- '||InDoc.Rn); end if;
       begin
        P_PAYNOTES_BASE_INSERT
          (
             nCOMPANY            => nCOMPANY
            ,nCRN                => PAYNT.CRN
            ,nJUR_PERS           => PAYNT.JUR_PERS 
            ,sPAY_PREFIX         => PAYNT.PAY_PREFIX
            ,sPAY_NUMBER         => PAYNT.PAY_NUMBER
            ,nPAYER              => PAYNT.PAYER
            ,dPAY_DATE           => PAYNT.Pay_Date
            ,nPAY_TYPE           => PAYNT.PAY_TYPE 
            ,nSERV_PAY           => PAYNT.SERV_PAY
            ,nFACEACC            => PAYNT.Faceacc
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
            ,nUPD_COURSE         => PAYNT.UPD_COURSE
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
            ,nSEPACCOP           => PAYNT.SEPACCOP
            ,nAGNACC             => PAYNT.AGNACC            -- Реквизиты контрагента юридического лица
            ,nPAYER_AGNACC       => PAYNT.PAYER_AGNACC      -- Реквизиты контрагента
            ,nRN                 => PAYNT.rn
           -- ,nBILL               => InDOC.  in number default null
          );
          nPAY_RN := PAYNT.rn;
          exception when others then 
            p_exception(0,'!! '||error_text);
          end;
        end if;
        if  nPAY_RN  is not null then
          if  nBDoc_RN is not null then
             update BANKDOCS bbd
                set bbd.crn = nvl(nBDoc_CRN, bbd.crn), 
                    bbd.valid_doctype = PAYNT.VDoc_Type,
                    bbd.valid_docnumb = PAYNT.VDoc_Numb,
                    bbd.valid_docdate = PAYNT.VDoc_Date
              where bbd.rn = nBDoc_RN;  
              
              if  nSIGNPLAN = 0  then
                  PKG_DOCLINKS.LINK
                    (
                      nFLAG_SMART       => 1,                  -- признак генерации исключения при дублировании связи (0 - да, 1 - нет)
                      nCOMPANY          => nCOMPANY,           -- регистрационный номер записи организации
                      sIN_UNITCODE      => 'BankDocuments',      -- код раздела входного документа
                      nIN_DOCUMENT      => nBDoc_RN,           -- регистрационный номер записи входного документа

                      sOUT_UNITCODE     => 'PayNotes',         -- код раздела выходного документа
                      nOUT_DOCUMENT     => nPAY_RN             -- регистрационный номер записи выходного документа

                    ); 
                  
              end if;                
               
          end if;


    /*                  
          if sUNITCODE in ('PaymentAccountsIn', 'PaymentAccounts') then 
              PKG_DOCLINKS.LINK
                (
                  nFLAG_SMART       => 1,                     -- признак генерации исключения при дублировании связи (0 - да, 1 - нет)
                  nCOMPANY          => nCOMPANY,              -- регистрационный номер записи организации
                  sIN_UNITCODE      => sUNITCODE,             -- код раздела входного документа
                  nIN_DOCUMENT      => nRN,                   -- регистрационный номер записи входного документа

                  sOUT_UNITCODE     => 'PayNotes',            -- код раздела выходного документа
                  nOUT_DOCUMENT     => nPAY_RN                -- регистрационный номер записи выходного документа

                ); 

          end if;
          
          if sUNITCODE ='PaymentAccountsIn' then
            if nSIGNPLAN = 0 then
              update PAYACCIN pc
                 set pc.factpaysumm = nFakt_sumIn + PAYNT.PAY_SUM
              where pc.rn = nRN;   
            else
              update PAYACCIN pc
                 set pc.planpaysumm = pc.planpaysumm + PAYNT.PAY_SUM
              where pc.rn = nRN;           
            end if;  
          elsif sUNITCODE = 'PaymentAccounts' then
            if nSIGNPLAN = 0 then
              update PAYACC pc
                 set pc.factpaysumm = nFakt_sumIn + PAYNT.PAY_SUM
              where pc.rn = nRN;   
            else
              update PAYACC pc
                 set pc.planpaysumm = pc.planpaysumm + PAYNT.PAY_SUM
              where pc.rn = nRN;           
            end if;            
            
          end if; 
          \* Пересчет сумм ЛС *\  
          P_FACEACC_SET_PAYSUMS(  
                nCOMPANY        => nCOMPANY,            -- Организация
                nRN             => PAYNT.Faceacc,       -- Лицевой счет
                nPAY            => nPAY_RN,             -- Регистрационный номер платежа
                dPAY_DATE_NEW   => PAYNT.Pay_Date,      -- Дата платежа - новое значение
                dPAY_DATE_OLD   => null,                -- Дата платежа - старое значение
                nCHANGE_KIND    => 0                    -- Изменение при отработке/снятии отработки распоряжения (0 - нет, 1 - да)
             );
             */
          if  nSIGNPLAN = 0  then            
            if sUNITCODE in ('PaymentAccountsIn', 'PaymentAccounts') then 
              begin              
                P_PAYNOTES_BASE_GDOC_SETLINKS
              
                    (
                      nCOMPANY      => nCOMPANY,    -- организация.
                      nRN           => nPAY_RN,    -- RN платежа
                      nGDOC_RN      => nRN,    -- RN товарного документа
                      sUNITCODE     => sUNITCODE,  -- раздел товарного документа
                      nSIGN         => 0,    
                      /* признак разнесения превышения фактическим платежем неоплаченного остатка по товарному документу:
                          0 - не разносить остаток (при превышении выдать nRESULT = 1 или 2, для отката)
                          1 - не относить превышение на ТД и оставить его в виде несвязанного платежа
                          2 - отнести превышение на последний плановый платеж, связанный с ТД
                          3 - сформировать из превышения отдельный фактический платеж связанный с ТД и не связанный с плановым платежом */
                      nRESULT     => nTMP     
                      /* признак того, что фактический платеж превышает неоплаченный остаток по товарному документу
                          и он разнесен по плановым платежам, с ним связанным:
                          0 - полностью
                          1 - частично (если нет плановых платежей = 2)
                          2 - не разнесен совсем */
                    );
                exception when others then 
                  null;
                end;
      --        else
                
              end if;
            else
              if sUNITCODE in ('PaymentAccountsIn', 'PaymentAccounts') then 
                  PKG_DOCLINKS.LINK
                    (
                      nFLAG_SMART       => 0,                     -- признак генерации исключения при дублировании связи (0 - да, 1 - нет)
                      nCOMPANY          => nCOMPANY,              -- регистрационный номер записи организации
                      sIN_UNITCODE      => sUNITCODE,             -- код раздела входного документа
                      nIN_DOCUMENT      => nRN,                   -- регистрационный номер записи входного документа

                      sOUT_UNITCODE     => 'PayNotes',            -- код раздела выходного документа
                      nOUT_DOCUMENT     => nPAY_RN                -- регистрационный номер записи выходного документа

                    ); 
                if sUNITCODE ='PaymentAccountsIn' then
                 
                    update PAYACCIN pc
                       set pc.planpaysumm = pc.planpaysumm + PAYNT.PAY_SUM
                    where pc.rn = nRN;           
                 
                elsif sUNITCODE = 'PaymentAccounts' then
                 
                    update PAYACC pc
                       set pc.planpaysumm = pc.planpaysumm + PAYNT.PAY_SUM
                    where pc.rn = nRN;           
                end if;               
              end if;
              
            end if;
            /*Перенос записи Журнала платежей в каталог аналогичного счету*/
            if sUNITCODE in ('PaymentAccountsIn', 'PaymentAccounts') then 

              UDO_P_PAYNOUT_SETCRN(nPAY_RN);
            end if;  
         end if; 
      end if;
end UDO_P_PAYNOTES_MAKEPAY;
/
