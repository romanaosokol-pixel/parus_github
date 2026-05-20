create or replace procedure usr_p_dlos_update_quant
/*
Заказ поставщику. Спецификация. Исправить количество
09/02/2026 Степанов М.
*/
(
 nRN                  in number
,nPROC_TECH_QUANT     in number   /* Процент на Технужды */
,nADD_CERTIF_QUANT    in number   /* Добавлять сертификацию: 0-нет, 1-да */
,nADD_LPM_QUANT       in number   /* Добавлять ЛПМ: 0-нет, 1-да */
)
is
  rV_Row              v_deliveryords%rowtype;
  nQuant_New          pkg_std.tnumber; 
  nSum_New            pkg_std.tnumber; 
  rDicNomns           dicnomns%rowtype;
  rDicMUnts           dicmunts%rowtype;

  nNumber             pkg_std.tnumber; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_DLOS_UPDATE_QUANT');

  /* Считывание */
  select * into rV_Row from v_deliveryords where nrn = USR_P_DLOS_UPDATE_QUANT.nrn;
  /* Номенклатура */
  rDicNomns := usr_pkg_dicnomns.dicnomns_get( nrn => rV_Row.nnomen );
  /* Единица измерения */
  select * into rDicMUnts from dicmunts where rn = rDicNomns.umeas_main;

  /* Проверки */
  if rV_Row.nord_state != 0 then
    p_exception(0, 'Статус документа <%s>. Исправление запрещено. %s'
               ,usr_pkg_deliveryord.deliveryord_get_status_name( nord_state => rV_Row.nord_state )
               ,cr||cr||f_docdescrs_get_description( sunitcode => 'DeliveryOrders', ndocument => rV_Row.nprn ) ); 
  end if;

  /* Новое количество */
  nQuant_New := rV_Row.nmain_quant;
    
  /* Если указан процент на технужды */
  if nPROC_TECH_QUANT is not null then
    nQuant_New := nQuant_New * ( 1 + nPROC_TECH_QUANT / 100 );
  end if;
  /* Если Добавлять сертификацию */
  if nADD_CERTIF_QUANT = 1 then
    nQuant_New := nQuant_New + nvl( udo_f_deliveryords_crtqnt( nrn => rV_Row.nrn ), 0 );
  end if;
  /* Если Добавлять ЛПМ */
  if nADD_LPM_QUANT = 1 then
    nQuant_New := nQuant_New + nvl( udo_f_deliveryords_tech_lpm( nrn => rV_Row.nrn ), 0 );
  end if;

  /* Округление */
  nQuant_New := round( nQuant_New, case rDicMUnts.meas_type when 1 then 0 else 10 end );
  
  /* Новая сумма с НДС */
  nSum_New := rV_Row.nsumwtax / rV_Row.nmain_quant * nQuant_New;

  /* Пересчёт сумм */
  usr_pkg_dictaxgr.dictaxis_calc_base( nflagsmart   => 1
                                      ,ncompany     => rV_Row.ncompany
                                      ,ddate        => rV_Row.dord_date
                                      ,ntaxgr       => rV_Row.ntax_group
                                      ,ninsumm      => nSum_New
                                      ,nquant       => nQuant_New
                                      ,nsumm        => rV_Row.nsumwotax
                                      ,nsummwithnds => rV_Row.nsumwtax
                                      ,nsumm_nds    => nNumber
                                      ,nprice       => rV_Row.nexp_price );
  /* Заполнение переменных */
  rV_Row.nactswtax     := rV_Row.nsumwtax;
  rV_Row.nactswotax    := rV_Row.nsumwotax;
  rV_Row.ncustswtax    := rV_Row.nsumwtax;
  rV_Row.ncustswotax   := rV_Row.nsumwotax;
  rV_Row.nmain_quant   := nQuant_New;
  rV_Row.nactm_quant   := nQuant_New;
  rV_Row.ncustm_quant  := nQuant_New;
  rV_Row.nexecm_quant  := nQuant_New;

  /* исправление */
  usr_pkg_deliveryord.deliveryords_update( rv_row => rV_Row, nmode => 1 );

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end;
/
