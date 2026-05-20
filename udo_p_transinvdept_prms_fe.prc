create or replace procedure UDO_P_TRANSINVDEPT_PRMS_FE
(
  N_RN         in number, -- Рег. номер записи
  NCOMPANY     in number, -- Рег. номер организации
  NRN          in number, -- рег номер родителя
  SATRIB       in varchar2, -- Изменение атрибута
  SSTORE       out varchar2, -- Мнемокод Склада
  SSTORE_ND    in out number, -- Доступность Склада
  SCELL        in out varchar2, -- Мнемокод ячейки
  SCELL_ND     in out number, -- Доступность ячейки
  SCELL_NN     in out number, -- Обязательность ячейки
  nRETURN      in out number, -- признак возвратной накладной
  nRETURN_ND   in out number, -- Доступность признак возвратной накладной
  nRES_TYPE_ND in out number, -- Доступность тип резервирования (0 - приход, 1 - расход)
  nREPLACE     in out number, -- с заменой
  nREPLACE_ND  in out number, -- Доступность с заменой
  nRES_TYPE    in out number  -- тип резервирования (0 - приход, 1 - расход)
) as
  /*
    ЦИТК Парус.
    Расходные накладные на отпуск в подразделения (спецификация)
    Действие "Массовое резервирование по местам хранения"
    Инициализация формы, пересчеты
    
    /* Городецкий 17-04-2025 Переделал Чтоб автоматически выбирался режим nRES_TYPE (если на складу расхода есть места хранения, то ставим галочку
       -- Если по приходу делаем распределение, то автоматически проставляется место хранения на котором эта номенклатура хранилась ранее
    
  */
begin
  
--- Если по складу расхода есть места хранения, то ставим галочку на расход -1 
begin
  select 1
    into nres_type
    from transinvdept t
    join azsazslistmt skl
      on skl.rn = t.store
   where t.rn = nrn
     and exists (select 1 from stplracks mh where mh.store = skl.rn);
exception
  when no_data_found then
    nres_type := 0; --- Приход
end;

--if user = 'STEPANOV_MV' then p_exception(0, nres_type ||' = '|| skl_t.azs_number ||' = '|| skl_f.azs_number);  end if; 
 begin
 select case nres_type
           when 0 then --- Приход
            skl_t.azs_number
           else -- расход
            skl_f.azs_number
         end
    into SSTORE
  
    from /*transinvdeptspecs ts
    join */transinvdept t
      ---on t.rn = ts.prn
    join azsazslistmt skl_f
      on skl_f.rn = t.store
    left join azsazslistmt skl_t
      on skl_t.rn = t.in_store
   where t.rn = NRN;
   
  --- exception when no_data_found then nres_type :=0; --- Для случая Степанова М.
  end; 

   SSTORE_ND :=0; -- А зачем нам тут менять склад?
  
 /*  ---Пользовательская форма 
  UDO_PKG_STRPLRESJRNL_MASS_INS .TRANSINVDEPT_PRMS_FE(NCOMPANY     => NCOMPANY,
                                                     NRN          => NRN,
                                                     SATRIB       => SATRIB,
                                                     SSTORE       => SSTORE,
                                                     SSTORE_ND    => SSTORE_ND,
                                                     SCELL        => SCELL,
                                                     SCELL_ND     => SCELL_ND,
                                                     SCELL_NN     => SCELL_NN,
                                                     nRETURN      => nRETURN,
                                                     nRETURN_ND   => nRETURN_ND,
                                                     nRES_TYPE_ND => nRES_TYPE_ND,
                                                     nREPLACE     => nREPLACE,
                                                     nREPLACE_ND  => nREPLACE_ND,
                                                     nRES_TYPE    => nRES_TYPE);*/
                                                     
   ---- Подберем место хранения
   if nres_type = 0  then 

   SCELL_NN :=1;
   SCELL_ND :=1;
   
     begin
     --- Найдем место хранения. Если позиция хранится на нескольких местах,то берем с максимальным количеством (последнее место по RN)
   select trim(cel.pref) || '-' || trim(cel.numb)
   into SCELL
     
  from transinvdeptspecs sp
  join goodsparties gp
    on gp.rn = sp.goodsparty
  join transinvdept t
    on t.rn = sp.prn
  join goodssupply gy
    on gy.prn = gp.rn
   and gy.store =  t.in_store                  
  join stplgoodssupply mgy
    on mgy.goodssupply = gy.rn
  join stplcells cel
    on cel.rn = mgy.cell
 where sp.rn = N_RN
   and mgy.rn =
       (select max(mgy1.rn)
          from stplgoodssupply mgy1
         where mgy1.goodssupply = gy.rn
           and mgy1.quant =
               (select max(mgy2.quant) from stplgoodssupply mgy2 where mgy2.goodssupply = gy.rn));
   
   exception when no_data_found then SCELL:=null;
   
   
   end;
   
   else  --- При расходе ячейки явно не задаем
     SCELL := null;
     SCELL_NN :=0;
     SCELL_ND :=0;
     
   end if;
  
  --- Если нет склада, то и ячейки выбирать нет смысла
  if SSTORE is null then 
   SCELL_NN :=0;
   SCELL_ND :=0;  
  end if;                                                   
  
end UDO_P_TRANSINVDEPT_PRMS_FE;
-- grant execute on UDO_P_TRANSINVDEPT_PRMS_FE to public;
/
