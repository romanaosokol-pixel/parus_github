create or replace procedure UDO_P_PAYNOTES_CALC_MARK(nCOMPANY in number, NRN  in number) is
/*
  09/11/2022 Столярский Е.
  Процедура вызывает пересчет показателя по одной записе журнала платежей.
*/
    sVERSHION         PKG_STD.tSTRING;  -- Версия бюджета
    sSTATE            PKG_STD.tSTRING;  -- Сосотояние бюджета        
    sTYPE             PKG_STD.tSTRING;  -- Тип показателей
    sFORMPLAN         PKG_STD.tSTRING;  -- Ajhvf gkfybhjdfybz
    nENPERIOD         PKG_STD.tREF;     -- RN периода
    nTMP              PKG_STD.tREF;     -- RN периода
    ---nFINSTATE         PKG_STD.tREF;     --
    sYear  varchar2(4); -- Год бюджета
begin
    /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'UDO_P_PAYNOTES_CALC_MARK');
    
    delete from UDO_T_TMPREF; 
   
      
    select pr.rn,  extract(year from pr.startdate)
    into nENPERIOD, sYear
    from ENPERIOD pr, PAYNOTES pn
    where pn.rn = NRN
      and pr.PERTYPE = 3
      and pr.name like '%'||extract(year from pn.pay_date)||'%'
      and pn.pay_date between pr.startdate and pr.enddate;

   ---&&&&&&????????  
    UDO_PKG_MFINPLAN_MAKE2.GET_PARAM
             (nCOMPANY  => nCOMPANY,
              nRN       => 56760287,  -- Фактический сводный Бюждет 2023 года 
              sVERSHION => sVERSHION,
              sSTATE    => sSTATE,
              sTYPE     => sTYPE,
              sFORMPLAN => sFORMPLAN, 
              nENPERIOD => nTMP);
              
    UDO_PKG_MFINPLAN_MAKE2.PAYNOTES_MARK_MAKE
              (nCOMPANY     => nCOMPANY,
               sVERSHION    => 'Версия 1',
               sSTATE       => 'Факт',
               sTYPE        => 'БДДС',
               nENPERIOD    => nENPERIOD,
               nPAYNOTES_RN => NRN);
               
    UDO_PKG_MFINPLAN_MAKE2.CLEARE_MARK
             (nCOMPANY      => nCOMPANY,    -- Организация 
              sVERSHION     => 'Версия 1',  -- Версия бюджета
              sSTATE        => 'Факт',      -- Сосотояние бюджета        
              sTYPE         => 'БДДС',      -- Тип показателей  
              nENPERIOD     => nENPERIOD,    -- Период бюджета
              nRN_PAYNOTE   => NRN  --RN для перерасчета одного платежа    -- Период бюджета
             );  
    UDO_PKG_MFINPLAN_MAKE2.PAYNOTES_MARK_MAKE
              (nCOMPANY     => nCOMPANY,
               sVERSHION    => 'Версия 1',
               sSTATE       => 'План',
               sTYPE        => 'БДДС',
               nENPERIOD    => nENPERIOD,
               nPAYNOTES_RN => NRN);
               
    UDO_PKG_MFINPLAN_MAKE2.CLEARE_MARK
             (nCOMPANY      => nCOMPANY,    -- Организация 
              sVERSHION     => 'Версия 1',  -- Версия бюджета
              sSTATE        => 'План',      -- Сосотояние бюджета        
              sTYPE         => 'БДДС',      -- Тип показателей  
              nENPERIOD     => nENPERIOD,    -- Период бюджета
              nRN_PAYNOTE   => NRN  --RN для перерасчета одного платежа    -- Период бюджета
             );  
   delete from UDO_T_TMPREF;      
   
   /* Пересчитаем исполнение бюджета */
   usr_p_alloc_arts_v_ispoln_all(pin_year => sYear);
   
    /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
    usr_pkg_process.process_close;
    raise;
               
end UDO_P_PAYNOTES_CALC_MARK;
/
