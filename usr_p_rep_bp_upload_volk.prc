create or replace procedure usr_p_rep_bp_upload_volk
(
  nIDENT_PROCESS in number
 ,nIDENT         in number -- по отмеченным записям
  --,dFROM          in date
  --,dTO            in date
) as
  nCountColumn number;
  --sFormatQuant varchar2(20) := 'nQuant';
begin
  udo_pkg_excel_report_xml.p_initialize(pnshowhiddencolumns => 0, pbbtemplate => to_blob(null));

  udo_pkg_excel_report_xml.p_row_begin;
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Тип ПЗ'); -- 18
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номер ПЗ'); -- 19   
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Дата ПЗ'); --  20
/*  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'План (тип, №, дата)'); -- 1*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Состояние'); -- 2                                              
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Дата смены состояния'); -- 3
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Период планирования'); -- 4                                                 
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Дата начала периода'); -- 5   
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Дата окончания периода'); -- 6   
  -------------------------------------------------------------------------------------------- Спецификация 
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Номенклатура'); -- 7
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Дата включения в план закупок'); -- 8                                                  
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Наименование номеклатуры'); --  9
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество в ОЕИ планируемое'); --  10
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Модификация'); --  11
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Наименование модификации'); --  12
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Основная ЕИ количества'); -- 13
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество в ОЕИ согласованное'); -- 14
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Срок поставки плановый'); -- 15
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Срок поставки согласованный'); -- 16
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Поставщик'); -- 17
  -------------------------------------------------------------------------------------------- 

  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Цена планируемая'); -- 21
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Цена согласованная'); -- 22
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'ЕИ цены'); -- 23
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Сумма планируемая'); -- 24
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Сумма согласованная'); -- 25
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Склад доставки'); -- 26
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Адрес склада'); -- 27
  -------------------------------------------------------------------------------------------- Допы    
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество в заказе постащику'); -- 28 Количество в ЗП
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество во входящем счете'); -- 29 Количество в ЗП
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Заказ поставщику. Префикс-номер'); --  30 ПЗ номер
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Заказ поставщику. Дата'); --  Дата ПЗ
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Входящий счет. Префикс-номер'); --  ВХ номер 
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Входящий счет. Дата'); --  ВХ Дата ПЗ                                                                                                    
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Заказ поставщику. Добавил'); -- 31
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Заказ поставщику. Ответственный'); -- 32
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Входящий счёт. Добавил'); -- 33
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Входящий счёт. Инициатор'); -- 34

  udo_pkg_excel_report_xml.p_row_end;

  for c in (
    select
      substr((select dt2.DOCCODE from DOCTYPES dt2 where dt2.RN = bp.DOCTYPE), 4) as BP_DOCTYPE,
      trim(bp.PREF) || '-' || trim(bp.NUMB) as BP_PREFNUMB,
      bp.DOCDATE as BP_DATE,
      substr(F_BUYPLANE_STATE(bp.STATE), 1, 20) as BP_STATE,
      bp.STATE_DATE as date_change_state,
      (select ep.name from ENPERIOD ep where ep.RN = bp.ENPERIOD) as PERIOD_PLANIROV,
      bp.BEGIN_PERIOD as PERIOD_DATE_BEGIN,
      bp.END_PERIOD as PERIOD_DATE_END,

      (select dn.NOMEN_CODE from DICNOMNS dn where dn.rn = bps.NOMEN) as nomen,
      bps.INCL_DATE as incl_date,
      vbps.snomen_name as nomen_name,
      bps.QUANT_PLAN as QUANT_PLAN,
      (select nmdf.MODIF_CODE from NOMMODIF nmdf where nmdf.RN = bps.NOMMODIF) as modif,
      vbps.snommodif_name as modif_name,
      vbps.SUMEAS_MAIN as UMEAS_MAIN,
      vbps.nquant_acc as QUANT_ACC,
      vbps.dshipment_plan as SHIPMENT_PLAN,
      vbps.dshipment_acc as SHIPMENT_ACC,
      vbps.sagent as SAGENT,

      vbps.nprice_plan as price_plane,
      vbps.nprice_acc as price_accept,
      vbps.sumeas_main as price_ei,
      vbps.nsumm_plan as sum_plan_spec,
      vbps.nsumm_acc as sum_accept_spec,
      vbps.sstore as store_spec,
      vbps.sstore_address as store_spec_adress,

      NVL(dos.MAIN_QUANT, 0) as quant_dos,
      NVL(pas.QUANT, 0) as quant_pas,
      NVL(trim(do.ORD_PREF) || '-' || trim(do.ORD_NUMB), '—') as DO_PREFNUMB,
      do.ORD_DATE as DO_DATE,
      NVL(trim(pa.DOC_PREF) || '-' || trim(pa.DOC_NUMB), '—') as PA_PREFNUMB,
      pa.DOC_DATE as PA_DATE,
      NVL(usr_f_dscr_get_insert_details(dos.RN), '—') as DOS_INI,
      NVL((select ag.AGNABBR from AGNLIST ag where ag.RN = do.ACC_AGENT), '—') as DO_AGENT,
      NVL(usr_f_dscr_get_insert_details(pas.RN), '—') as PAYACC_ADD,
      NVL(UDO_F_PAYACCIN_AUTHOR(pa.RN), '—') as PAYACC_INI

    from SELECTLIST sl
    join BUYPLANE bp on bp.RN = sl.DOCUMENT
    join BUYPLANESP bps on bp.RN = bps.PRN
    left join DOCLINKS dl1 on dl1.IN_DOCUMENT = bps.RN
      and dl1.OUT_UNITCODE = 'DeliveryOrders' -- связь только с заказами поставщикам
    join V_BUYPLANESP vbps on vbps.nrn = bps.RN

    -- Связь с Заказами поставщику (опционально)
    left join DELIVERYORD do on do.RN = dl1.OUT_DOCUMENT
    left join DELIVERYORDS dos 
      on dos.PRN = do.RN 
      and dos.NOMEN = bps.NOMEN 
      and dos.NOM_MODIF = bps.NOMMODIF

    -- Связь с ВХ (только через ЗП, опционально)
    left join DOCLINKS dl2 on dl2.IN_DOCUMENT = do.RN
      and dl2.OUT_UNITCODE = 'PaymentAccountsIn' -- связь только с входящими счетами
    left join PAYACCIN pa on dl2.OUT_DOCUMENT = pa.RN
    left join PAYACCINSPEC pas 
      on pas.PRN = pa.RN 
      and pas.NOMEN = bps.NOMEN 
      and pas.NOMMODIF = bps.NOMMODIF

    where sl.IDENT = nIDENT
  )
  
  loop
    nCountColumn := 0;
    udo_pkg_excel_report_xml.p_row_begin;
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.BP_DOCTYPE); -- 18 Тип
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.BP_PREFNUMB); -- 19 Префикс номер
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.BP_DATE, 'dd.mm.yyyy')); -- 20 Дата
/*    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.BP_PLANE_PREF_NUMB); -- 1*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.BP_STATE); -- 2
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.date_change_state
                                                                       ,'dd.mm.yyyy')); -- 3
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PERIOD_PLANIROV); -- 4  
  
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.PERIOD_DATE_BEGIN
                                                                       ,'dd.mm.yyyy')); -- 5
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.PERIOD_DATE_END
                                                                       ,'dd.mm.yyyy')); -- 6                                                   
    ------------------------------------------------------------------------------------------ Спецификация         
  
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.NOMEN); -- 7
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.incl_date, 'dd.mm.yyyy')); -- 8 Дата вкючения спецификации в план закупок        
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.NOMEN_NAME); -- 9
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANT_PLAN); -- 10                                                    
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.modif); -- 11                                                    
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.MODIF_NAME); -- 12                                                  
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.UMEAS_MAIN); -- 13           
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANT_ACC); -- 14
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.SHIPMENT_PLAN
                                                                       ,'dd.mm.yyyy')); -- 15
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.SHIPMENT_ACC
                                                                       ,'dd.mm.yyyy')); -- 16 
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.SAGENT); -- 17 Поставщик
    --------------------------------------------------------------------------------------------- 

    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PRICE_PLANE); -- 21 Цена планируемая
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PRICE_ACCEPT); -- 22 Цена согласованная
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PRICE_EI); -- 23 ЕИ цены
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.SUM_PLAN_SPEC); -- 24 Сумма планируемая
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.SUM_ACCEPT_SPEC); -- 25 Сумма согласованная
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.STORE_SPEC); -- 26 Склад доставки
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.STORE_SPEC_ADRESS); -- 27 Адресс склада
    --------------------------------------------------------------------------------------------- Допы
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANT_DOS); -- Количество в ЗП
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANT_PAS); -- Количество во ВХ
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.DO_PREFNUMB); -- ЗП
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.DO_DATE
                                                                       ,'dd.mm.yyyy')); -- 16     
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PA_PREFNUMB); -- ВХ префикс номер 
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.PA_DATE
                                                                       ,'dd.mm.yyyy')); -- ВХ дата   
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.DOS_INI);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.DO_AGENT);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PAYACC_ADD);
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PAYACC_INI);
  
    udo_pkg_excel_report_xml.p_row_end;
  
  end loop;

  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка №1 План закупок.xls'
                                        ,pnident    => nIDENT_PROCESS);
  udo_pkg_excel_report_xml.p_finalize;

exception
  when others then
    udo_pkg_excel_report_xml.p_finalize;
    raise;
end usr_p_rep_bp_upload_volk;
/
