create or replace procedure usr_p_transinvcust_from_graf_i
(
  pin_doc          in number /* := 158842227; -- RN Документа по которому формируем акт*/
 ,pin_com          in transinvcust.company%type /*:= 90521;*/
 ,pin_uni          in unitlist.unitcode%type /*Код раздела из которого вызвали*/
 ,out_cat          out acatalog.name%type /* := 'Расходные накладные на отпуск потребителям';*/
 ,out_jur          out jurpersons.code%type /*:= 'Модуль';*/
 ,out_jur_agent    out agnlist.agnabbr%type /* Контрагент юр. лица, для выбора расчетного счета */
 ,out_jur_acc      out agnacc.strcode%type /*-- := 'И-376985'; --- Найти на форме  --- Лицевой счет (реквизит) организации юр. лица*/
 ,out_doc_type     out doctypes.doccode%type /*:= 'АктВыпРаб';*/
 ,out_doc_pref     out transinvcust.pref%type /*:= 'TEST';*/
 ,out_doc_nmb      out transinvcust.numb%type /*:= '78';*/
 ,out_doc_date     out transinvcust.docdate%type /*:= trunc(sysdate);*/
 ,out_sstoper      out azsgsmwaystypes.gsmways_mnemo%type /*:= 'РасходВнеш';*/
 ,out_starif       out dictarif.code%type /*:= 'Общий'; /*--- Тариф*/
 ,out_spaytype     out azsgsmpaymentstypes.gsmpayments_mnemo%type /*:= 'ПредоплатаБезнал'; /*-- Вид оплаты*/
 ,out_sheepview    out dicshpvw .code%type /*:= 'ВыпРабИсп'; /*--- Вид отгнрузки */
 ,out_tax_gr       out dictaxgr.code%type /*:= 'НДС 20'; /*-- Налоговая группа*/
 ,out_sum_with_tax out stages.stage_sumtax%type /*:= 500;*/
 ,out_sum_out_tax  out stages.stage_sum%type /*:= 500;*/
 ,out_sum_tax      out stages.stage_sum_nds%type /*:= 500;*/
 ,out_nomen        out dicnomns.nomen_code%type /*:= 'Аванс за товары'; /* Код номенклатуры для услуг. */
 ,out_modif        out nommodif.modif_code%type /*:= 'Авансирование'; /* Модификация */
 ,out_comments     out transinvcust.comments%type
 ,OUT_tek_nmb      out number -- Эмуляция кнопки для генерации номера
 ,out_tex_err      out varchar2
 ,out_is_ok        out number   
) is

  --v_options options%rowtype;

begin

  out_doc_date := null;/*trunc(sysdate);*/
  
  OUT_tek_nmb:=0;

  out_comments := null; -- Очищаем предыдущее значение
  
  usr_p_graf_cntrl(nrn => pin_doc, out_tex_err => out_tex_err, out_is_ok => out_is_ok);
  

  --- p_options_get(scode => 'Realiz_InvCust_Catalog', ncomp_vers => pin_com, rres => v_options);
  ---out_cat := coalesce(v_options.str_value, 'Акты');
  out_cat := 'Акты';

  select jp.code
        ,ja.agnabbr
        ,jac.strcode
        ,st.stage_sumtax
        ,st.stage_sum
        ,st.stage_sum_nds
        ,nvl(tg.code,'НДС 20')
    into out_jur
        ,out_jur_agent
        ,out_jur_acc
        ,out_sum_with_tax
        ,out_sum_out_tax
        ,out_sum_tax
        ,out_tax_gr
    from stages st
    join jurpersons jp
      on jp.rn = st.jur_pers
    join agnlist ja
      on ja.rn = jp.agent
    left join agnacc jac
      on jac.rn = st.jur_acc
    left join dictaxgr tg
      on tg.rn = st.taxgr
  
   where st.rn = pin_doc;

  /*  p_options_get(scode => 'Realiz_InvCust_Catalog', ncomp_vers => pin_com, rres => v_options);
  out_cat := coalesce(v_options.str_value, 'Акты');*/

  out_doc_type := 'АктВыпРаб';
  out_doc_pref := to_char(sysdate, 'YYYY');
  
  P_TRANSINVCUST_GETNEXTNUMB(nCOMPANY => PIN_COM, sJUR_PERS => out_jur, dDOCDATE => sysdate, sTYPE => out_doc_type, sPREF => out_doc_pref, sNUMB => out_doc_nmb);
---  out_doc_nmb  := null;

  out_nomen := '00000139366';
  out_modif := '00000139366';

  out_sstoper   := 'РасходВнеш';
  out_starif    := 'Общий';
  out_spaytype  := 'ОкончатРасчет';
  out_sheepview := 'ВыпРабИсп';

end;
/
