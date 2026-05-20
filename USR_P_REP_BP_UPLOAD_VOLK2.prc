create or replace procedure USR_P_REP_BP_UPLOAD_VOLK2
/*Пользовательский отчет. Выгрузка №2 План закупок*/
(
  nIDENT_PROCESS in number
 ,nIDENT         in number
) as
  nCountColumn number;
begin
  udo_pkg_excel_report_xml.p_initialize(pnshowhiddencolumns => 0, pbbtemplate => to_blob(null));

  udo_pkg_excel_report_xml.p_row_begin;
  /*Заголовок плана закупок*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'УМТС. Ответственный закупщик');       
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'План (тип, №, дата)');       

  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Состояние');                     
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Дата смены состояния');          
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Период планирования');           
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Дата начала периода');           
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Дата окончания периода');        
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Валюта');                                                                         
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Сумма планируемая');                                                            
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Сумма согласованная');            
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Подразделение');                                                               
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Склад');                                                                 
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Примечание');                                                           
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Идентификатор государственного контракта');                                                                                                                  
  /*Спецификация*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Классификационная группа ТМЦ');               
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Номенклатура');                  
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Дата включения в план закупок'); 
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Наименование номеклатуры');      
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество в ОЕИ планируемое');  
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Упаковка номенклатуры');             
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Наименование упаковки номенклатуры');                                                                
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Модификация');                   
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Наименование модификации');      
                                                  
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Упаковка модификации');                                                                
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Наименование упаковки модификации');                                                                                                                                                                    
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Основная ЕИ количества');        
                                                  
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество в ДЕИ планируемое');                                                                  
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество в упаковках планируемое');                                                                                                                                                               
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество в ОЕИ согласованное');
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество в ДЕИ согласованное');                                                                
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество в упаковках согласованное');                                                                                                                                                              
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Срок поставки плановый');        
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Срок поставки согласованный');   
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Цена планируемая');              
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Цена согласованная');            
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'ЕИ цены');      
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Сумма планируемая');             
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Сумма согласованная');           
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Склад доставки');                
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Адрес склада');                  
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Поставщик');                                                                    
  /*Допы для Волкоморова*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Место возникновения затрат');                     
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Примечание');                     
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => '#Включено в ЗП');                     
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => '#Остаток к включению в ЗП');                                                                                                                       
  udo_pkg_excel_report_xml.p_row_end;

  for c in (
    select
      NVL(USR_F_BUYPLANESP_UMTS_BUYER(bps.RN), '—') as BPS_BUYER,                                          -- УМТС. Ответственный закупщик
      substr((select dt2.DOCCODE from DOCTYPES dt2 where dt2.RN = bp.DOCTYPE), 4) || ', '||
      trim(bp.PREF) || '-' || trim(bp.NUMB) ||', '|| to_char(bp.DOCDATE, 'dd.mm.yyyy') as BP_TYPE_N_DATE, -- План (тип, №, дата)
      substr(F_BUYPLANE_STATE(bp.STATE), 1, 20) as BP_STATE,                                              -- состояние
      bp.STATE_DATE as date_change_state,                                                                 -- дата смены состояния
      (select ep.name from ENPERIOD ep where ep.RN = bp.ENPERIOD) as PERIOD_PLANIROV,                     -- Период планирования
      bp.BEGIN_PERIOD as PERIOD_DATE_BEGIN,                                                               -- Дата начала периода
      bp.END_PERIOD as PERIOD_DATE_END,                                                                   -- Дата окончания периода
      vbp.SCURRENCY as CURRENCY,                                                                          -- Валюта
      bp.SUMM_PLAN as SUMM_PLAN,                                                                          -- Сумма планируемая
      bp.SUMM_ACC as SUMM_ACC,                                                                            -- Сумма согласованная
      vbp.ssubdiv as DEPARTAMENT,                                                                         -- Подразделение
      vbp.sstore as STORE,                                                                                -- Склад
      vbp.snote as NOTE,                                                                                  -- Примечание
      vbp.sgovcntrid as IGK,                                                                              -- Идентификатор государственного контракта
      vbps.snomencls as TMC,                                                                              -- Классификационная группа ТМЦ      
      (select dn.NOMEN_CODE from DICNOMNS dn where dn.rn = bps.NOMEN) as nomen,                           -- Номенклатура 
      bps.INCL_DATE as incl_date,                                                                         -- Дата включения в ПЗ  
      vbps.snomen_name as nomen_name,                                                                     -- Наименование номенклатуры
      bps.QUANT_PLAN as QUANT_PLAN,                                                                       -- Количество в ОЕИ планируемое
      vbps.snomnpack as PACK,                                                                             -- Упаковка номенклатуры
      vbps.snomnpack_name as PACK_NAME,                                                                   -- Наименование упаковки номенклатуры
      (select nmdf.MODIF_CODE from NOMMODIF nmdf where nmdf.RN = bps.NOMMODIF) as modif,                  -- Модификация
      vbps.snommodif_name as MODIF_NAME,                                                                  -- Имя модификации
      vbps.snomnmodifpack as MODIF_PACK,                                                                  -- Упаковка модификации
      vbps.snomnmodifpack_name as MODIF_PACK_NAME,                                                        -- Наименование упаковки модификации
      vbps.SUMEAS_MAIN as UMEAS_MAIN,                                                                     -- Основная ЕИ количества
      vbps.NQUANTALT_PLAN as QUANTALT_PLAN,                                                               -- Количество в ДЕИ планируемое
      vbps.NQUANTPACK_PLAN as QUANTPACK_PLAN,                                                             -- Количество в упаковках планируемое    
      vbps.nquant_acc as QUANT_ACC,                                                                       -- Количество в ОЕИ согласованное
      vbps.NQUANTALT_ACC as QUANTALT_ACC,                                                                 -- Количество в ДЕИ согласованное
      vbps.NQUANTPACK_ACC as QUANTPACK_ACC,                                                               -- Количество в упаковках согласованное     
      vbps.dshipment_plan as SHIPMENT_PLAN,                                                               -- Срок поставки плановый
      vbps.dshipment_acc as SHIPMENT_ACC,                                                                 -- Срок поставки согласованный       
      vbps.nprice_plan as price_plane,                                                                    -- Цена планируемая
      vbps.nprice_acc as price_accept,                                                                    -- Цена согласованная 
      vbps.sumeas_main as price_ei,                                                                       -- ЕИ цены
      vbps.nsumm_plan as sum_plan_spec,                                                                   -- Сумма планируемая
      vbps.nsumm_acc as sum_accept_spec,                                                                  -- Сумма согласованная
      vbps.sstore as store_spec,                                                                          -- Склад доставки
      vbps.sstore_address as STORE_SPEC_ADRESS,                                                           -- Адрес склада
      vbps.sagent as SAGENT,                                                                              -- Поставщик
      vbps.SCOST_PLACE as COST_PLACE,                                                                     -- Место возникновения затрат
      vbps.snote as snote,                                                                                -- Примечание
      udo_f_buyplanesp_quant_cntr(bps.rn) as INCUDED_ZP,                                                  -- #Включено в ЗП
      UDO_F_BUYPLANESP_QUANT_CNTR_R(bps.RN) as INCUDED_ZP_OST                                             -- #Остаток к включению в ЗП    

    from SELECTLIST sl
    join BUYPLANE bp on bp.RN = sl.DOCUMENT
    join BUYPLANESP bps on bp.RN = bps.PRN
    join V_BUYPLANESP vbps on vbps.nrn = bps.RN
    join V_BUYPLANE vbp on vbp.nrn = bp.rn
    where sl.IDENT = nIDENT
  )

  loop
    nCountColumn := 0;
    udo_pkg_excel_report_xml.p_row_begin;
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.BPS_BUYER);          /*0 УМТС. Ответственный закупщик*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.BP_TYPE_N_DATE);          /*1 Тип номер дата*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.BP_STATE);            /*4 Статус*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.date_change_state
                                                                       ,'dd.mm.yyyy')); /*5 Дата смены */
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PERIOD_PLANIROV);     /*6 Период*/

    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.PERIOD_DATE_BEGIN
                                                                       ,'dd.mm.yyyy')); /*7 Дата начала периода*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.PERIOD_DATE_END
                                                                       ,'dd.mm.yyyy')); /*8 Дата окончания периода*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.CURRENCY);            /*8 Валюта*/ 
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.SUMM_PLAN);            /*8 Суума план*/                                                     
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.SUMM_ACC);            /*8 Сумма согласованная*/                                                     
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.DEPARTAMENT);         /*8 Подразделение*/  
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.STORE);               /*8 Склад*/                                                                                                        
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.NOTE);            /*8 Примечание*/                                                     
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.IGK);            /*8 Идентификатор государственного контракта*/                                                                                                                           
    /*Спецификация*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.TMC);            /*8 Группа ТМЦ*/       
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.NOMEN);               /*9 Номенклатура*/
                                                    
                                                    
                                                    
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.incl_date, 'dd.mm.yyyy'));  /*10 Дата вкючения спецификации в план закупок*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.NOMEN_NAME);          /*11 Наименование номеклатуры*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANT_PLAN);          /*12 Планируемое количество*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PACK);            /*8 Упаковка*/                                                     
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PACK_NAME);            /*8 Наименование упаковки*/                                                                                                      
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.modif);               /*13 Модификация*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.MODIF_NAME);          /*14 Наименование модификации*/
                                                    
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.MODIF_PACK);            /*8 Упаковка модификации*/ 
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.MODIF_PACK_NAME);            /*8 Упаковка модификации*/                                                     
                                                                                                        
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.UMEAS_MAIN);          /*15 Основная ЕИ Количества*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANTALT_PLAN);            /*8 Количество в ДЕИ планируемое*/ 
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANTPACK_PLAN);            /*8 Количество в упаковках планируемое*/ 

    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANT_ACC);           /*16 Количество ОЕИ согласованое*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANTALT_ACC);            /*8 Количество в ДЕИ согласованное*/                                                     
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANTPACK_ACC);            /*8 Количество в упаковках согласованное*/                                                                                                       
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.SHIPMENT_PLAN
                                                                       ,'dd.mm.yyyy')); /*17 Срок поставки плавоый*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.SHIPMENT_ACC
                                                                       ,'dd.mm.yyyy')); /*18 Срок поставки согласованный*/                                                                       
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PRICE_PLANE);         /*20 Цена планируемая*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PRICE_ACCEPT);        /*21 Цена согласованная*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PRICE_EI);            /*22 ЕИ цены*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.SUM_PLAN_SPEC);       /*23 Сумма планируемая*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.SUM_ACCEPT_SPEC);     /*24 Сумма согласованная*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.STORE_SPEC);          /*25 Склад доставки*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.STORE_SPEC_ADRESS);   /*26 Адресс склада*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.SAGENT);              /*19 Поставщик*/                                                   
    /*Допы для Волкоморова*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.COST_PLACE);              /*19 Место возникновения затрат*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.SNOTE);              /*19 Примечание*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.INCUDED_ZP);              /*19 #Включено в ЗП*/      
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.INCUDED_ZP_OST);              /*19 #Остаток к включению в ЗП*/                                                                                                  
    udo_pkg_excel_report_xml.p_row_end;

  end loop;

  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка №2 План закупок.xls'
                                        ,pnident    => nIDENT_PROCESS);
  udo_pkg_excel_report_xml.p_finalize;

exception
  when others then
    udo_pkg_excel_report_xml.p_finalize;
    raise;
end;
/
