create or replace procedure UDO_P_STATMODE_PAYACCIN_CS
(
  nCOMPANY                    in number,    -- Организация
  nDOCUMENT  	                in number,    -- Рег. номер документа
  sMODE                       in varchar2,  -- Тип запуска
  sACTION                     in varchar2   -- Код действия
) is
  /*
    Процедура для неименованного блока в разделе "События". 
    Срабатывает при изменении состояния для статусной модели в разделе "Входящие счета на оплату".
    При переходе в состояние "ПроверкаПостоплаты" выполняется проверка типа документа ВСО. 
    Если ВСО - постоплатный, то остаемся в текущей точке маршрута, иначе переходим в состояние "ОплатаСчета".   
  */
  
  rEVENT                        CLNEVENTS%rowtype;                       -- Запись события
  rROUTE                        EVROUTES%rowtype;                        -- Запись маршрута
  rPAYACCIN                     PAYACCIN%rowtype;                        -- Запись ВСО
  sEVRTPOINTS                   Pkg_std.tSTRING;                         -- Мнемокод текущего статуса события
  sROUTE                        Pkg_std.tSTRING := 'ВходСчетаОплат';     -- Мнемокод маршрута статусной модели для раздела ВСО
  sEVENT_STAT                   Pkg_std.tSTRING := 'ПроверкаПостоплаты'; -- Текщая точка маршрута     
  --sEVENT_STAT_NEXT              Pkg_std.tSTRING := 'ОплатаСчета';        -- Следующая точка маршрута
  sEVENT_STAT_NEXT              Pkg_std.tSTRING := 'СоглГлавБухг';       -- 19/07/2022 Марков МВ. Следующая точка маршрута
  sPAYACCIN_DocType             Pkg_std.tSTRING := 'ВхСчОплПос';         -- Мнемокод типа документа для постоплатного ВСО  
  nCNT                          Pkg_std.tREF;	                           -- Кол-во записей
  sEVENT_INF_STAT               Pkg_std.tSTRING := 'ИнформЗаказчика';    -- Текщая точка маршрута     
  sEVENT_INF_STAT_NEXT          Pkg_std.tSTRING := 'Отработан';          -- Следующая точка маршрута
  
  /* Перевод состояния для события (права доступа на возможгость перехода проверяются штатно) */
  procedure CHANGE_NEXT_STATE
  (
    sEVENT_STAT_NEXT in varchar2,         -- Точка маршрута, в которую необходимо перейти 
    rEVENT_          in CLNEVENTS%rowtype -- запись события
  ) 
  is 
    nEVENT_STAT_NEXT Pkg_std.tREF;
    nEVENT_STAT      Pkg_std.tREF;
  begin 
    /* статус следующего события */
      FIND_CLNEVNSTATS_CODE( 0,nCOMPANY,sEVENT_STAT_NEXT,nEVENT_STAT_NEXT );
      begin
        select RN
          into nEVENT_STAT
          from CLNEVNTYPSTS
         where PRN = rEVENT_.EVENT_TYPE
           and EVENT_STATUS = nEVENT_STAT_NEXT;
      exception
        when NO_DATA_FOUND then
          P_EXCEPTION( 0,'Статус "'||sEVENT_STAT_NEXT||'" события для маршрута не определен.' );
      end;
          
      /* Перевод состояния в след точку маршрута */
      DBMS_LOCK.SLEEP(0.5);
      P_CLNEVENTS_UPDATE_INT(nCOMPANY         => rEVENT_.COMPANY,
                             nRN              => rEVENT_.RN,
                             nCRN             => rEVENT_.CRN,
                             nREMOTE_ACCESS   => null,       
                             dCHANGE_DATE     => rEVENT_.CHANGE_DATE /*systimestamp*/,   -- Обновление 2024/08/30  /* 07/20/2024 Степанов М. заменил sysdate, т.к. он обрезается */
                             nEVENT_TYPE      => rEVENT_.EVENT_TYPE,
                             nEVENT_STATUS    => nEVENT_STAT,
                             nCLIENT_CLIENT   => null,
                             nCLIENT_PERSON   => null,
                             nSND_CLIENT      => null,
                             nSND_DIVISION    => null,
                             nSND_POST        => null,
                             nSND_PERFORM     => null,
                             nSND_PERSON      => null,
                             nSND_STAFFGRP    => null,
                             nSND_USER_GROUP  => null,
                             sSND_USER_AUTHID => null,
                             sEVENT_DESCR     => null --'Автоматически переход в событие "ПроверкаПостоплаты" для ожидания поступления ТМЦ от поставщика.'
                            );   
  end;
               
begin
  /* Проверка параметров вызова неименованного блока */
  if sACTION = 'CLNEVENTS_CHANGE_STATE' and sMODE = 'AFTER' then 
   
     /* Запись события */
     begin
     select *
       into rEVENT
       from CLNEVENTS
      where COMPANY = nCOMPANY
        and RN = nDOCUMENT; 
     exception
       when NO_DATA_FOUND then
         rEVENT.Rn := null;
     end;  
    
     /* Определим маршрут, соответствующий событию. */
     begin
       select *
         into rROUTE
         from EVROUTES
        where EVENT_TYPE = rEVENT.Event_Type
          and COMPANY = nCOMPANY;
     exception
       when NO_DATA_FOUND then
         rROUTE := null;
     end;  
    
     /* Текущая точка маршрута */  
     begin
       select CEs.Evnstat_Code
         into sEVRTPOINTS
         from CLNEVNTYPES CET,
              CLNEVNTYPSTS CEST,
              CLNEVNSTATS CES,
              CLNEVNTYPSTS CETS,
              EVRTPOINTS EP
        where CET.RN            = rEVENT.EVENT_TYPE
          and CEST.RN           = rEVENT.EVENT_STAT
          and CEST.EVENT_STATUS = CES.RN
          and CETS.PRN          = CET.RN
          and CETS.EVENT_STATUS = CES.RN
          and EP.EVENT_STATUS   = CETS.RN;
     exception
       when NO_DATA_FOUND then
         sEVRTPOINTS := null; 
     end; 
        
     /* если раздел статусной модели, маршрут и точка маршрута соответствуют условиям, то выполняем действия */
     if rEVENT.Linked_Unit = 'PaymentAccountsIn' and 
       rEVENT.Linked_Rn is not null and 
       rROUTE.Code = sROUTE and 
       sEVRTPOINTS = sEVENT_STAT then 
         
       /* ВСО */
       begin
        select p.* 
          into rPAYACCIN 
           from PAYACCIN p
         where p.rn = rEVENT.Linked_Rn;
         
         select count(iv.rn) 
           into nCNT    
           from ininvoices iv, 
                doclinks dl 
          where dl.in_document  = rPAYACCIN.rn 
            and dl.in_unitcode  = 'PaymentAccountsIn'  
            and dl.out_document = iv.rn
            and dl.out_unitcode = 'IncomingInvoices';
            
        exception
          when NO_DATA_FOUND then
            rPAYACCIN := null;
            nCNT      := 0;
        end; 
         
       /* если ВСО не имеет постоплатный тип или ВСО имеет постоплатный тип и из него создана хотя бы одна приходная накладная, 
          то переводим в состояние ожидания поступления ТМЦ (исполнитель-создатель события), 
          иначе останавливаемся в точке перехода */
       if get_doctypes_code_id(nFLAG_SMART => 1, nRN => rPAYACCIN.Doc_Type) != sPAYACCIN_DocType or 
         (get_doctypes_code_id(nFLAG_SMART => 1, nRN => rPAYACCIN.Doc_Type) = sPAYACCIN_DocType and nvl(nCNT,0) > 0) then 
         
         CHANGE_NEXT_STATE(sEVENT_STAT_NEXT => sEVENT_STAT_NEXT, rEVENT_ => rEVENT);                 
       end if;
    elsif rEVENT.Linked_Unit = 'PaymentAccountsIn' and 
          rEVENT.Linked_Rn is not null and 
          rROUTE.Code = sROUTE and 
          sEVRTPOINTS = sEVENT_INF_STAT  then 
       
       /* ВСО */
       begin
        select p.* 
          into rPAYACCIN 
           from PAYACCIN p
         where p.rn = rEVENT.Linked_Rn;


       exception
          when NO_DATA_FOUND then
            rPAYACCIN.rn := null;
            nCNT         := 0;
       end;
       /* если сумма с налогами ВСО совпадает с суммой по факту то
          то переводим в состояние Отработан, 
          иначе останавливаемся в точке перехода */
       if rPAYACCIN.Summwithnds = rPAYACCIN.Factpaysumm and rPAYACCIN.Rn is not null then 
         
         CHANGE_NEXT_STATE(sEVENT_STAT_NEXT => sEVENT_INF_STAT_NEXT, rEVENT_ => rEVENT);                 
       end if;                           
    end if; 
  end if; 
end UDO_P_STATMODE_PAYACCIN_CS;
/
