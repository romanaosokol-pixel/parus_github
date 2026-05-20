create or replace procedure UDO_P_PAYACCINSPEC_SETARTICL
/* 
08/10/2024 Степанов М. добавление проверок
30/08/2023 Степанов М. исправление ошибки 
08/09/2023 Е.Столярский изменил условие добавления калькуляции.
*/
(
  sUNITCODE in varchar,
  nIDENT    in number,  -- отмеченные записи 
  nCOMPANY  in number,
  sARTICLE  in varchar2, -- Статья затрат
  sFACEACC  in varchar2,  -- ЛС Темы
  nSUM_ARICLE in number
--  nSingl    in number   -- 1 - формируем только одну строку калькуляции
 
) as

/* добавление записи только если помечена 1 строка и сумма больше нуля  */
  nArticle number;
  nFACEACC number;
  nTMP_RN  number;
  nCount   number;
  nCNTSelect number;
  tPAYCLC    PAYACCINSPCLC%rowtype; 
 begin
   if sARTICLE is not null then
     begin
       select fa.rn
       into nArticle
       from FPDARTCL fa
       where fa.code = sARTICLE;
     exception when others then
       p_exception(0, 'Не удалось подобрать статью '||sARTICLE);
     end;
   end if;

 if sFACEACC is not null then
   begin
     select fc.rn
     into nFACEACC
     from FACEACC fc
     where fc.numb = sFACEACC;
   exception when others then
     p_exception(0, 'Не удалось подобрать лицевой счет для '||sFACEACC);
   end;
 else
   nFACEACC := null;
 end if;
 
 if  nArticle is null and nFACEACC is null then
   return;
 end if;
 
   select count(sl.rn)
   into nCNTSelect
   from SELECTLIST sl
   where sl.ident = nIDENT;
  
  if sUNITCODE = 'PaymentAccountsInSpecs' then
      for ss in (
        select sp.*
        from PAYACCINSPEC sp
            ,SELECTLIST   sl
        where sl.ident = nIDENT
          and sl.document = sp.rn
          
        ) loop
           nCount := 0;
          /*Если выбрана одна строка, то можем изменить сумму*/
          
          if nvl(nSUM_ARICLE,0) > 0 and nCNTSelect = 1 then
            begin
              select count (clc.rn), max(clc.rn)
                into  nCount, nTMP_RN
                from PAYACCINSPCLC clc
               where clc.prn = ss.rn
                 and cmp_num (clc.COST_ARTICLE, nArticle) = 1
                 and cmp_num (clc.faceaccount, nFACEACC) = 1;
            exception when others then
              nCount := 0;
            end;
            ss.summwithnds := nSUM_ARICLE ;
          else
            select count (clc.rn), max(clc.rn)
              into nCount, nTMP_RN
              from PAYACCINSPCLC clc
             where clc.prn = ss.rn;
              
          end if;
          if nCount = 0 then
            P_PAYACCINSPCLC_BASE_INSERT
              (nCOMPANY       => nCOMPANY
              ,nPRN           => ss.rn
              ,sNUMB          => '1'
              ,nCOST_ARTICLE  => nArticle
              ,nCOST_PLACE    => null
              ,nCOST_PLAN     => ss.summwithnds/ss.quant
              ,nCOST_FACT     => ss.summwithnds/ss.quant
              ,nPRIORITY      => 1
              ,nFACEACCOUNT   => nFACEACC
              ,nGRAPHPOINT    => null
              ,nFINOPER_TYPE  => null
              ,nQUANT_PLAN    => ss.quant
              ,nQUANT_FACT    => ss.quant
              ,nSUBDIV        => null
              ,nRN            => nTMP_RN);
            /* Проверка после добавления */
            usr_pkg_payaccin.payaccinspclc_ainsert(nrn => nTMP_RN, ncompany => nCOMPANY);
          elsif nCount = 1 then
          
            select clc.*
            into tPAYCLC
            from PAYACCINSPCLC clc
            where clc.rn = nTMP_RN;
            /* Проверка до исправления */
            usr_pkg_payaccin.payaccinspclc_bupdate(nrn => nTMP_RN, ncompany => nCOMPANY);
            P_PAYACCINSPCLC_BASE_UPDATE
              (nRN            => nTMP_RN
              ,nCOMPANY       => nCOMPANY
              ,sNUMB          => '1'
              ,nCOST_ARTICLE  => nvl(nArticle, tPAYCLC.Cost_Article)
              ,nCOST_PLACE    => null
              ,nCOST_PLAN     => ss.summwithnds/ss.quant
              ,nCOST_FACT     => ss.summwithnds/ss.quant
              ,nPRIORITY      => 1
              ,nFACEACCOUNT   => nvl(nFACEACC, tPAYCLC.Faceaccount)
              ,nGRAPHPOINT    => null
              ,nFINOPER_TYPE  => null
              ,nQUANT_PLAN    => ss.quant
              ,nQUANT_FACT    => ss.quant
              ,nSUBDIV        => null);          
            /* Проверка после исправления */
            usr_pkg_payaccin.payaccinspclc_aupdate(nrn => nTMP_RN, ncompany => nCOMPANY);
          else
            for cll in (
              select clc.*
                from PAYACCINSPCLC clc
               where clc.prn = ss.rn 
            ) loop 
              /* Проверка до исправления */
              usr_pkg_payaccin.payaccinspclc_bupdate(nrn => cll.rn, ncompany => nCOMPANY);
              P_PAYACCINSPCLC_BASE_UPDATE
                (nRN            => cll.rn
                ,nCOMPANY       => cll.COMPANY
                ,sNUMB          => cll.numb
                ,nCOST_ARTICLE  => nvl(nARTICLE, cll.cost_article)
                ,nCOST_PLACE    => cll.cost_place
                ,nCOST_PLAN     => cll.cost_plan
                ,nCOST_FACT     => cll.cost_fact
                ,nPRIORITY      => cll.priority
                ,nFACEACCOUNT   => nvl(nFACEACC, cll.faceaccount)
                ,nGRAPHPOINT    => cll.graphpoint
                ,nFINOPER_TYPE  => cll.finoper_type
                ,nQUANT_PLAN    => cll.quant_plan
                ,nQUANT_FACT    => cll.quant_fact
                ,nSUBDIV        => cll.subdiv );
              /* Проверка после исправления */
              usr_pkg_payaccin.payaccinspclc_aupdate(nrn => cll.rn, ncompany => nCOMPANY);
            end loop;  
          end if;
        end loop;
    elsif sUNITCODE = 'IncomingInvoicesSpecs'   then
      for ss in (
        select sp.*
        from ININVOICESSPECS  sp
            ,SELECTLIST   sl
        where sl.ident = nIDENT
          and sl.document = sp.rn
          
        ) loop
        if nvl(nSUM_ARICLE, 0) > 0 and nCNTSelect = 1 then
          begin
            select count (clc.rn), max(clc.rn)
              into nCount, nTMP_RN
              from ININVOICESSPC  clc
             where clc.prn = ss.rn
               and cmp_num (clc.COST_ARTICLE, nArticle) = 1
               and cmp_num (clc.faceaccount, nFACEACC) = 1;
          exception when others then
            nCount := 0;
          end;
        /*Если выбрана одна строка, то можем изменить сумму*/
          ss.summtax := nSUM_ARICLE ;
        else
          begin
            select count (clc.rn), max(clc.rn)
              into nCount, nTMP_RN
              from ININVOICESSPC  clc
             where clc.prn = ss.rn;
          exception when others then
            nCount := 0;
          end;          
        end if;
        if nCount =0 then
            P_ININVOICESSPC_BASE_INSERT
              (nCOMPANY       => nCOMPANY
              ,nPRN           => ss.rn
              ,sNUMB          => '1'
              ,nCOST_ARTICLE  => nArticle
              ,nCOST_PLACE    => null
              ,nCOST_PLAN     => ss.summtax/ss.quant
              ,nCOST_FACT     => ss.summtax/ss.quant
              ,nPRIORITY      => 1
              ,nFACEACCOUNT   => nFACEACC
              ,nGRAPHPOINT    => null
              ,nFINOPER_TYPE  => null
              ,nQUANT_PLAN    => ss.quant
              ,nQUANT_FACT    => ss.quant
              ,nSUBDIV        => null
              ,nRN            => nTMP_RN);
            /* Проверка после добавления */
            usr_pkg_ininvoices.ininvoicesspc_ainsert(nrn => nTMP_RN, ncompany => nCOMPANY);
          elsif nCount =1 then 
          
            select clc.*
            into tPAYCLC
            from PAYACCINSPCLC clc
            where clc.rn = nTMP_RN;
            /* Проверка до исправления */
            usr_pkg_ininvoices.ininvoicesspc_bupdate(nrn => nTMP_RN, ncompany => nCOMPANY);
            P_ININVOICESSPC_BASE_UPDATE
              (
               nRN            => nTMP_RN
              ,nCOMPANY       => nCOMPANY
              ,sNUMB          => '1'
              ,nCOST_ARTICLE  => nvl(nArticle, tPAYCLC.Cost_Article)
              ,nCOST_PLACE    => null
              ,nCOST_PLAN     => ss.summtax/ss.quant
              ,nCOST_FACT     => ss.summtax/ss.quant
              ,nPRIORITY      => 1
              ,nFACEACCOUNT   => nvl(nFACEACC, tPAYCLC.Faceaccount)
              ,nGRAPHPOINT    => null
              ,nFINOPER_TYPE  => null
              ,nQUANT_PLAN    => ss.quant
              ,nQUANT_FACT    => ss.quant
              ,nSUBDIV        => null);          
            /* Проверка после исправления */
            usr_pkg_ininvoices.ininvoicesspc_aupdate(nrn => nTMP_RN, ncompany => nCOMPANY);
          else
            for cll in (
               select *
                 from ININVOICESSPC  clc
                where clc.prn = ss.rn
            ) loop 
              /* Проверка до исправления */
              usr_pkg_ininvoices.ininvoicesspc_bupdate(nrn => cll.rn, ncompany => nCOMPANY);
              /* 30/08/2023 Степанов М. исправление ошибки */
              P_ININVOICESSPC_BASE_UPDATE
                (nRN            => cll.rn
                ,nCOMPANY       => cll.COMPANY
                ,sNUMB          => cll.numb
                ,nCOST_ARTICLE  => nvl(nARTICLE, cll.cost_article)
                ,nCOST_PLACE    => cll.cost_place
                ,nCOST_PLAN     => cll.cost_plan
                ,nCOST_FACT     => cll.cost_fact
                ,nPRIORITY      => cll.priority
                ,nFACEACCOUNT   => nvl(nFACEACC, cll.faceaccount)
                ,nGRAPHPOINT    => cll.graphpoint
                ,nFINOPER_TYPE  => cll.finoper_type
                ,nQUANT_PLAN    => cll.quant_plan
                ,nQUANT_FACT    => cll.quant_fact
                ,nSUBDIV        => cll.subdiv );
              /* Проверка после исправления */
              usr_pkg_ininvoices.ininvoicesspc_aupdate(nrn => cll.rn, ncompany => nCOMPANY);
            end loop;  
          end if;
      end loop;     
    elsif sUNITCODE = 'IncomFromDepsSpecs' then  
      for ss in (
        select sp.*
        from INCOMEFROMDEPSSPEC   sp
            ,SELECTLIST   sl
        where sl.ident = nIDENT
          and sl.document = sp.rn
          
      ) loop
        /*Если выбрана одна строка, то можем изменить сумму*/
        if nvl(nSUM_ARICLE, 0) > 0 and nCNTSelect = 1 then
        
          begin
            select count (clc.rn), max(clc.rn)
              into nCount, nTMP_RN
              from INCFDEPSPCLC  clc
             where clc.prn = ss.rn
               and cmp_num (clc.COST_ARTICLE, nArticle) = 1
               and cmp_num (clc.faceaccount, nFACEACC) = 1;
          exception when others then
            nCount := 0;
          end;
      
          ss.summ_fact := nSUM_ARICLE ;
        else
          begin
            select count (clc.rn), max(clc.rn)
              into nCount, nTMP_RN
              from INCFDEPSPCLC  clc
             where clc.prn = ss.rn;
          exception when others then
            nCount := 0;
          end;            
        end if;

        if nCount = 0 then
          P_INCFDEPSPCLC_BASE_INSERT
            (nCOMPANY       => nCOMPANY
            ,nPRN           => ss.rn
            ,sNUMB          => '1'
            ,nCOST_ARTICLE  => nArticle
            ,nCOST_PLACE    => null
            ,nCOST_PLAN     => ss.summ_fact/ss.quant_fact
            ,nCOST_FACT     => ss.summ_fact/ss.quant_fact
            ,nPRIORITY      => 1
            ,nFACEACCOUNT   => nFACEACC
            ,nGRAPHPOINT    => null
            ,nFINOPER_TYPE  => null
            ,nQUANT_PLAN    => ss.quant_fact
            ,nQUANT_FACT    => ss.quant_fact
            ,nSUBDIV        => null
            ,nRN            => nTMP_RN);
        elsif nCount = 1 then
        
            select clc.*
            into tPAYCLC
            from PAYACCINSPCLC clc
            where clc.rn = nTMP_RN;

          P_INCFDEPSPCLC_BASE_UPDATE (
             nRN            => nTMP_RN
            ,nCOMPANY       => nCOMPANY
            ,sNUMB          => '1'
            ,nCOST_ARTICLE  => nvl(nArticle, tPAYCLC.Cost_Article)
            ,nCOST_PLACE    => null
            ,nCOST_PLAN     => ss.summ_fact/ss.quant_fact
            ,nCOST_FACT     => ss.summ_fact/ss.quant_fact
            ,nPRIORITY      => 1
            ,nFACEACCOUNT   => nvl(nFACEACC, tPAYCLC.Faceaccount)
            ,nGRAPHPOINT    => null
            ,nFINOPER_TYPE  => null
            ,nQUANT_PLAN    => ss.quant_fact
            ,nQUANT_FACT    => ss.quant_fact
            ,nSUBDIV        => null);        
        else
          for cll in (
             select *
             from INCFDEPSPCLC  clc
             where clc.prn = ss.rn            
         ) loop
            P_INCFDEPSPCLC_BASE_UPDATE
              (nRN            => cll.rn
              ,nCOMPANY       => cll.COMPANY
              ,sNUMB          => cll.numb
              ,nCOST_ARTICLE  => nvl(nARTICLE, cll.cost_article)
              ,nCOST_PLACE    => cll.cost_place
              ,nCOST_PLAN     => cll.cost_plan
              ,nCOST_FACT     => cll.cost_fact
              ,nPRIORITY      => cll.priority
              ,nFACEACCOUNT   => nvl(nFACEACC, cll.faceaccount)
              ,nGRAPHPOINT    => cll.graphpoint
              ,nFINOPER_TYPE  => cll.finoper_type
              ,nQUANT_PLAN    => cll.quant_plan
              ,nQUANT_FACT    => cll.quant_fact
              ,nSUBDIV        => cll.subdiv );
          end loop;  
        end if;
      end loop;
    end if;
 end UDO_P_PAYACCINSPEC_SETARTICL;
/
