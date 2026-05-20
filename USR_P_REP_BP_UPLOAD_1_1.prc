create or replace procedure USR_P_REP_BP_UPLOAD_1_1
/*Пользовательский отчет. Выгрузка №1.1 План закупок*/
(
  nIDENT_PROCESS in number
 --,nIDENT         in number
 ,dDATE_FROM in date
 ,dDATE_TO in date
) as
  nCountColumn number;
begin
  udo_pkg_excel_report_xml.p_initialize(pnshowhiddencolumns => 0, pbbtemplate => to_blob(null));

  udo_pkg_excel_report_xml.p_row_begin;
  /*Заголовок плана закупок*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'УМТС. Ответственный закупщик');       /*0*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Тип ПЗ');       /*1*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Номер ПЗ');     /*2*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'Дата ПЗ');      /*3*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Состояние');                     /*4*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Дата смены состояния');          /*5*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Период планирования');           /*6*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Дата начала периода');           /*7*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Дата окончания периода');        /*8*/
  /*Спецификация*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Номенклатура');                  /*9*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Дата включения в план закупок'); /*10*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Наименование номеклатуры');      /*11*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество в ОЕИ планируемое');  /*12*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Модификация');                   /*13*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Наименование модификации');      /*14*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Основная ЕИ количества');        /*15*/
/*  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество в ОЕИ согласованное');\*16*\*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Срок поставки плановый');        /*17*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Срок поставки согласованный');   /*18*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Поставщик');                     /*19*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Цена планируемая');              /*20*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Цена согласованная');            /*21*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null, psvalue => 'ЕИ цены');      /*22*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Сумма планируемая');             /*23*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Сумма согласованная');           /*24*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Склад доставки');                /*25*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Адрес склада');                  /*26*/
  /*Допы для Волкоморова*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество в заказе постащику'); /*27*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Количество во входящем счете');  /*28*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Заказ поставщику. Префикс-номер');/*29*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Заказ поставщику. Дата');        /*30*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Входящий счет. Префикс-номер');  /*31*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Входящий счет. Дата');           /*32*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Заказ поставщику. Добавил');     /*33*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Заказ поставщику. Ответственный');/*34*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Входящий счёт. Добавил');        /*35*/
  udo_pkg_excel_report_xml.p_add_cell_value_string(psstyle => null
                                                  ,psvalue => 'Входящий счёт. Инициатор');      /*36*/

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
      NVL(usr_f_dscr_get_insert_details(do.RN), '—') as DOS_INI,
      NVL((select ag.AGNABBR from AGNLIST ag where ag.RN = do.ACC_AGENT), '—') as DO_AGENT,
      NVL(usr_f_dscr_get_insert_details(pa.RN), '—') as PAYACC_ADD,
      NVL(UDO_F_PAYACCIN_AUTHOR(pa.RN), '—') as PAYACC_INI,
      NVL(USR_F_BUYPLANESP_UMTS_BUYER(bps.RN), '—') as BPS_BUYER

    /*from SELECTLIST sl
    join BUYPLANE bp on bp.RN = sl.DOCUMENT*/
    from BUYPLANE bp
    join BUYPLANESP bps on bp.RN = bps.PRN
    left join DOCLINKS dl1 on dl1.IN_DOCUMENT = bps.RN
      and dl1.OUT_UNITCODE = 'DeliveryOrders'  /*связь только с заказами поставщикам*/
    join V_BUYPLANESP vbps on vbps.nrn = bps.RN

    /*Связь с Заказами поставщику*/
    left join DELIVERYORD do on do.RN = dl1.OUT_DOCUMENT
    left join DELIVERYORDS dos
      on dos.PRN = do.RN
      and dos.NOMEN = bps.NOMEN
      and dos.NOM_MODIF = bps.NOMMODIF

    /*Связь с ВХ*/
    left join DOCLINKS dl2 on dl2.IN_DOCUMENT = do.RN
      and dl2.OUT_UNITCODE = 'PaymentAccountsIn'  /*связь только с входящими счетами, исключаем ведомость замен*/
    left join PAYACCIN pa on dl2.OUT_DOCUMENT = pa.RN
    left join PAYACCINSPEC pas
      on pas.PRN = pa.RN
      and pas.NOMEN = bps.NOMEN
      and pas.NOMMODIF = bps.NOMMODIF

    where bp.DOCDATE between dDATE_FROM and dDATE_TO
    --sl.IDENT = nIDENT
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
                                                    ,psvalue => c.BP_DOCTYPE);          /*1 Тип*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.BP_PREFNUMB);         /*2 Префикс номер*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.BP_DATE, 'dd.mm.yyyy'));/*3 Дата ПЗ*/
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
    /*Спецификация*/
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
                                                    ,psvalue => c.modif);               /*13 Модификация*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.MODIF_NAME);          /*14 Наименование модификации*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.UMEAS_MAIN);          /*15 Основная ЕИ Количества*/
/*    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANT_ACC);           \*16 Количество согласованое*\*/
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
                                                    ,psvalue => c.SAGENT);              /*19 Поставщик*/

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
    /*Допы для Волкоморова*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANT_DOS);           /*27 Количество в ЗП*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.QUANT_PAS);           /*28 Количество во ВХ*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.DO_PREFNUMB);         /*29 ЗП Префикс-номер*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.DO_DATE
                                                                       ,'dd.mm.yyyy')); /*30 Заказ дата*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PA_PREFNUMB);         /*31 ВХ префикс номер*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => to_char(c.PA_DATE
                                                                       ,'dd.mm.yyyy')); /*32 ВХ дата*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.DOS_INI);             /*33 Заказ инициатор*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.DO_AGENT);            /*34 Заказ добавил*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PAYACC_ADD);          /*35 Добавил ВХ*/
    nCountColumn := nCountColumn + 1;
    udo_pkg_excel_report_xml.p_add_cell_value_string(pnindex => nCountColumn
                                                    ,psstyle => null
                                                    ,psvalue => c.PAYACC_INI);          /*36 Инициатор ВХ*/

    udo_pkg_excel_report_xml.p_row_end;

  end loop;

  udo_pkg_excel_report_xml.p_save_result(psfilename => 'Выгрузка №1 План закупок.xls'
                                        ,pnident    => nIDENT_PROCESS);
  udo_pkg_excel_report_xml.p_finalize;

exception
  when others then
    udo_pkg_excel_report_xml.p_finalize;
    raise;
end;
/
