create or replace procedure UDO_P_PAYACCIN_SETSTATUS
(
  NCOMPANY           in number,  -- Организация
  nIDENT             in number
  
)
is
 nTarCRN     number;
 nTarStatus  number;
 nOldCRN     number;
 nOldStatus  number;
 nSetStatus  number := 1;   -- 1 -Утвердить 0 -- Снять с утверждения
 
  nCRN_FULLPAY number := 7232042;  -- Полностью оплаченные
  nCRN_PARTPAY number := 7578029;  -- Частично оплаченные
  nCRN_APPRPAY number := 6947664;  -- Загруженные (без ошибок)
  nCRN_ERROR   number := 6868349;  -- Загруженные (с ошибками)
  
begin
    if nSetStatus = 1 then
       nTarCRN     := nCRN_APPRPAY; -- Утвержденные
       nOldCRN     := nCRN_ERROR; -- Загруженные (1С)
       nTarStatus  := 1;
       nOldStatus  := 0;
    else
       nTarCRN     := nCRN_ERROR;  -- Загруженные (1С)
       nOldCRN     := nCRN_APPRPAY;  -- Утвержденные
       nTarStatus  := 0;
       nOldStatus  := 1;      
    end if;

   if nIDENT > 0 then

      for pn in ( 
      select pp.*
      from PAYACCIN pp, SELECTLIST sl
      where sl.ident = nIDENT
        and sl.document = pp.rn
        and sl.company  = NCOMPANY
        and pp.DOC_STATE = nOldStatus
        and pp.company = NCOMPANY
        and pp.crn = nOldCRN
        and pp.reg_date is not null
        and not exists (select null from PAYACCINSPEC ps where ps.prn = pp.rn and ps.comments is not null)
      ) loop 
       /* переместим счета распознанные без ошибок */
       begin
        update PAYACCIN pt
         set pt.crn = nTarCRN
         where pt.rn = pn.rn;
       exception when others then
         null;
       end;
       
        /* Установка нового статуса для входящего счета */
       /*  update PAYACCIN pt 
         set pt.DOC_STATE = nTarStatus
         where pt.rn = pn.rn;
        
         \* Добавим плановый платеж *\
        UDO_P_PAYNOTES_GEN_PLAN(NCOMPANY, pn.rn);
         */
       
      end loop;
       /* Массовая отработка*/
    elsif nIDENT = 0 then
      for pnt in ( 
        select pp.*
             ,(select count(ps.rn) from PAYACCINSPEC ps where ps.prn = pp.rn and ps.comments is not null) as nERR_COUNT
        from PAYACCIN pp
        where pp.company  = NCOMPANY
         -- and pp.DOC_STATE = nOldStatus
          and pp.crn in (nOldCRN, nTarCRN)
          and pp.reg_date is not null
          
        ) loop 
          /* Установка нового статуса для платежа при массовой отработке*/
         /*  if pnt.doc_state = nOldStatus then
             update PAYACCIN pt 
             set pt.DOC_STATE = nTarStatus
             where pt.rn = pnt.rn;
             \* Добавим плановый платеж *\
             UDO_P_PAYNOTES_GEN_PLAN(NCOMPANY, pnt.rn);
           end if; */
           
           /* если нет ошибок распознования */
           if pnt.nERR_COUNT = 0 and pnt.crn = nOldCRN then

              /* Переносим в каталог */
             begin
               update PAYACCIN pt 
               set pt.crn = nTarCRN
               where pt.rn = pnt.rn; 
             exception when others then
               null;             
             end; 
             
           end if;       
             
        end loop; 
      /* Переносим в каталог "Утвержденные" счета прошедшие проверку */ 
      for pr in ( 
        select pp.*
        from PAYACCIN pp
        where pp.company  = NCOMPANY
          and pp.DOC_STATE = nOldStatus
          and pp.crn in (nTarCRN)
          and pp.reg_date is not null
          and exists (select null from PAYACCINSPEC ps where ps.prn = pp.rn and ps.comments is not null)
        ) loop 
           update PAYACCIN pt 
              set pt.crn = nOldCRN
            where pt.rn = pr.rn;
                         
      end loop;  
      
      /* Переносим в каталог "Оплаченные"  */  
      for pk in ( 
        select pp.*
        from PAYACCIN pp
        where pp.company  = NCOMPANY
          and pp.DOC_STATE = 1
          and pp.crn in (nCRN_APPRPAY, nCRN_PARTPAY)
          and pp.reg_date is not null
      --    and not exists (select null from PAYACCINSPEC ps where ps.prn = pp.rn and ps.comments is not null)
          and PP.SUMMWITHNDS = pp.factpaysumm
        ) loop 
           update PAYACCIN pt 
              set pt.crn = nCRN_FULLPAY
            where pt.rn = pk.rn;
                         
      end loop;  
      
       /* Переносим в каталог "Оплач.Частично"  */           
      for pf in ( 
        select pp.*
        from PAYACCIN pp
        where pp.company  = NCOMPANY
          and pp.DOC_STATE = 1
          and pp.crn in (nCRN_APPRPAY)
          and pp.reg_date is not null
      --    and not exists (select null from PAYACCINSPEC ps where ps.prn = pp.rn and ps.comments is not null)
          and PP.SUMMWITHNDS > PP.FACTPAYSUMM
          and PP.FACTPAYSUMM > 0
        ) loop 
           update PAYACCIN pt 
              set pt.crn = nCRN_PARTPAY
            where pt.rn = pf.rn;
                         
      end loop;  
         
    end if;
end UDO_P_PAYACCIN_SETSTATUS;
/

