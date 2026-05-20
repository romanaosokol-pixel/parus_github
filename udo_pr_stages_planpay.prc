create or replace procedure udo_pr_stages_planpay
/*
Договор, 1/23-32, 27.12.2023
График 7
Расчёт колонки Материалы: 3108114,66 (стр. 0100) /7301974,93 (стр. 1900 Цена без НДС) * 5297105,3 ( неотгруженный остаток без НДС )
*/
(
 nCOMPANY     in number /* Организация */
,nIDENT       in number /* Отмеченные записи Договора */
,nPARAM       in number  /* 1 по всем договорам */
,dREPORT_DATE in date    /* Отчет по состоянию на */
) 
is
  c_slist constant pkg_std.tstring := 'Лист1'; -- Лист

  ll_line constant pkg_std.tstring := 'L_Line';
  ll_gap  constant pkg_std.tstring := 'L_Gap';
  ll_sum  constant pkg_std.tstring := 'L_SUM';
  ll_tot  constant pkg_std.tstring := 'L_TOT';

  c_npp         constant pkg_std.tstring := 'nPP';
  c_sagent_name constant pkg_std.tstring := 'sAgent_NAME';
  c_sshifr      constant pkg_std.tstring := 'sShifr';
  c_sdog_numb   constant pkg_std.tstring := 'sDOG_numb';
  c_Nomen_Modif constant pkg_std.tstring := 'sNomen_Modif';
  c_smonrt      constant pkg_std.tstring := 'sMonrt';
  c_dfactdate   constant pkg_std.tstring := 'dFactDate';
  c_nFAOP_Quant  constant pkg_std.tstring := 'nFAOP_Quant';
  c_sprj_numb   constant pkg_std.tstring := 'sPRJ_Numb';
  c_sotv        constant pkg_std.tstring := 'sOtv';

  c_su4etnmb constant pkg_std.tstring := 'sU4etNmb';
  c_setapnmb constant pkg_std.tstring := 'sEtapNMB';
  c_stgrfnmb constant pkg_std.tstring := 'sTGrfNmb';

  c_nsum_wonds   constant pkg_std.tstring := 'nSUM_WONDS';
  c_nsum_withnds constant pkg_std.tstring := 'nSUM_WITHNDS';

  c_nsum_material constant pkg_std.tstring := 'nSum_Material';
  c_nsum_fot      constant pkg_std.tstring := 'nSum_FOT';
  c_nsum_nalog    constant pkg_std.tstring := 'nSum_Nalog';
  c_nsum_naklad   constant pkg_std.tstring := 'nSum_Naklad';
  c_nsum_nproizv  constant pkg_std.tstring := 'nSum_NProizv';
  c_nsum_ka       constant pkg_std.tstring := 'nSum_KA';
  с_nsum_spec     constant pkg_std.tstring := 'nSum_Spec';
  с_nsum_oborud   constant pkg_std.tstring := 'nSum_Oborud';
  с_nsum_other   constant pkg_std.tstring := 'nSum_Other';
  c_nsum_sebst    constant pkg_std.tstring := 'nSum_Sebst';
  c_nsum_prib     constant pkg_std.tstring := 'nSum_Prib';
  c_nsum_nds      constant pkg_std.tstring := 'nSum_NDS';
  c_npay_summ     constant pkg_std.tstring := 'nPay_summ';
  c_nsum_cost     constant pkg_std.tstring := 'nSum_COST';

  c_npp_tot    constant pkg_std.tstring := 'nPP_Tot';
  c_sagent_tot constant pkg_std.tstring := 'sAgent_NAME_Tot';
  c_sshifr_tot constant pkg_std.tstring := 'sShifr_Tot';
  c_sdog_tot   constant pkg_std.tstring := 'sDOG_numTot';
  c_sprj_tot   constant pkg_std.tstring := 'sPRJ_Numb_Tot';


  c_nsum_wonds_t   constant pkg_std.tstring := 'nSUM_WONDS_T';
  c_nsum_withnds_t constant pkg_std.tstring := 'nSUM_WITHNDS_T';
  c_nFAOP_Quant_T   constant pkg_std.tstring := 'nFAOP_Quant_T';

  c_nsum_material_t constant pkg_std.tstring := 'nSum_Material_T';
  c_nsum_fot_t      constant pkg_std.tstring := 'nSum_FOT_T';
  c_nsum_nalog_t    constant pkg_std.tstring := 'nSum_Nalog_T';
  c_nsum_naklad_t   constant pkg_std.tstring := 'nSum_Naklad_T';
  c_nsum_nproizv_t  constant pkg_std.tstring := 'nSum_NProizv_T';
  c_nsum_ka_t       constant pkg_std.tstring := 'nSum_KA_T';
  с_nsum_spec_t     constant pkg_std.tstring := 'nSum_Spec_T';
  с_nsum_oborud_t   constant pkg_std.tstring := 'nSum_Oborud_T';
  с_nsum_other_t    constant pkg_std.tstring := 'nSum_Other_T';
  c_nsum_sebst_t    constant pkg_std.tstring := 'nSum_Sebst_T';
  c_nsum_prib_t     constant pkg_std.tstring := 'nSum_Prib_T';
  c_nsum_nds_t      constant pkg_std.tstring := 'nSum_NDS_T';
  c_npay_summ_t     constant pkg_std.tstring := 'nPay_summ_T';

  c_nsum_wonds_tot   constant pkg_std.tstring := 'nSUM_WONDS_TOT';
  c_nsum_withnds_tot constant pkg_std.tstring := 'nSUM_WITHNDS_TOT';
  c_nFAOP_Quant_Tot   constant pkg_std.tstring := 'nFAOP_Quant_Tot';

  c_nsum_material_tot constant pkg_std.tstring := 'nSum_Material_TOT';
  c_nsum_fot_tot      constant pkg_std.tstring := 'nSum_FOT_TOT';
  c_nsum_nalog_tot    constant pkg_std.tstring := 'nSum_Nalog_TOT';
  c_nsum_naklad_tot   constant pkg_std.tstring := 'nSum_Naklad_TOT';
  c_nsum_nproizv_tot  constant pkg_std.tstring := 'nSum_NProizv_TOT';
  c_nsum_ka_tot       constant pkg_std.tstring := 'nSum_KA_TOT';
  с_nsum_spec_tot     constant pkg_std.tstring := 'nSum_Spec_TOT';
  с_nsum_oborud_tot   constant pkg_std.tstring := 'nSum_Oborud_TOT';
  с_nsum_other_tot    constant pkg_std.tstring := 'nSum_Other_TOT';
  c_nsum_sebst_tot    constant pkg_std.tstring := 'nSum_Sebst_TOT';
  c_nsum_prib_tot     constant pkg_std.tstring := 'nSum_Prib_TOT';
  c_nsum_nds_tot      constant pkg_std.tstring := 'nSum_NDS_TOT';
  c_npay_summ_tot     constant pkg_std.tstring := 'nPay_summ_TOT';

  nStr  number;
  nStr1 number;
  nStr2 number;
  nPPtot       number := 1;
  nSt_Prn      number := 0;

  nPay_summ   number(17, 2) := 0;
  nSum_NDS    pkg_std.tsumm;
  sAgent      varchar2(256) := null;
  sShifr      varchar2(256) := null;
  sDog        varchar2(256) := '';
  sPrj        varchar2(256) := '';

  nCount_graf number; /* Есть ли графики отгрузки с калькуляцией у этапа договора */

  nSum_WoNDST    number := 0;
  nSum_WithNDST  number := 0;
  nFAOP_Quant_T   number := 0;
  nSum_MaterialT number := 0;
  nSum_FotT      number := 0;
  nSum_NalogT    number := 0;
  nSum_NakladT   number := 0;
  nSum_NproizvT  number := 0;
  nSum_KAT       number := 0;
  nSum_SpecT     number := 0;
  nSum_OborudT   number := 0;
  nSum_OtherT    number := 0;
  nSum_SebstT    number := 0;
  nSum_PribT     number := 0;
  nSum_NDST      number := 0;
  nPay_SummT     number := 0;

  nSum_WoNDSTot    number := 0;
  nSum_WithNDSTot  number := 0;
  nFAOP_Quant_Tot   number := 0;
  nSum_MaterialTot number := 0;
  nSum_FotTot      number := 0;
  nSum_NalogTot    number := 0;
  nSum_NakladTot   number := 0;
  nSum_NproizvTot  number := 0;
  nSum_KaTot       number := 0;
  nSum_SpecTot     number := 0;
  nSum_OborudTot   number := 0;
  nSum_OtherTot    number := 0;
  nSum_SebstTot    number := 0;
  nSum_PribTot     number := 0;
  nSum_NDSTot      number := 0;
  nPay_SummTot     number := 0;

  sFOT_Codes        pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_ОЗП') ||';'|| 
                                       udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_ДЗП' ); 
  sSoc_Codes        pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_СОЦ') ||';'|| 
                                       udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_СОЦ_СОТРУДН' ); 
  sSoc_Codes2       pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_СОЦ') ; 
  sMat_Codes        pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_МАТЕРИАЛЫ' ) ||';'|| 
                                       udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_ТОВАР_СОИСПОЛН' ); 
  sMat_Codes2       pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_МАТЕРИАЛЫ' ); 
  sNakl_Codes       pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_НАКЛАДНЫЕ' ); 
  sProizv_Codes     pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_ОБЩПРОИЗВ' ); 
  sKA_Codes         pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_УСЛУГИ_СОИСПОЛН' ); 
  sSebst_Codes      pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_СЕБ' ) ||';'|| 
                                       udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_ПОИЗВ_СЕБ' ) ||';'|| 
                                       udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_ПОЛН_СЕБ' ); 
  sPrib_Codes       pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_ПРИБЫЛЬ' ); 
  sSpec_Codes       pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_СПЕЦИАЛЬНЫЕ' ); 
  sOborud_Codes     pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_СПЕЦОБОРУДОВАНИЕ' ); 
  sOther_Codes      pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_ПРОЧИЕ') ||';'|| 
                                       udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_КОМАНДИРОВКИ' ); 
  sSumWO_Codes      pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_ЦЕНА_БЕЗ_НДС' ); 
  sSumW_NDS_Codes   pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_ЦЕНА' ); 
  sSum_NDS_Codes    pkg_std.tstring := udo_f_constlst_str( ncompany => nCOMPANY, sname => 'СТАТЬЯ_НДС' ); 
  nGraf_Coeff       pkg_std.tlcoeff; 
begin
  /* Проверка параметров */
  if dREPORT_DATE is null then
    p_exception(0, 'Не задано значение параметра <dREPORT_DATE>.'); 
  end if;

  /* Инициализация */
  prsg_excel.prepare;

  -- Установка текущего рабочего листа
  prsg_excel.sheet_select(c_slist);
  
  -- Описываем строки и ячейки спецификации 
  prsg_excel.line_describe(ll_gap);

  prsg_excel.line_describe(ll_line);
  prsg_excel.line_cell_describe(ll_line, c_npp);
  prsg_excel.line_cell_describe(ll_line, c_sagent_name);
  prsg_excel.line_cell_describe(ll_line, c_sshifr);
  prsg_excel.line_cell_describe(ll_line, c_sdog_numb);
  prsg_excel.line_cell_describe(ll_line, c_Nomen_Modif);
  prsg_excel.line_cell_describe(ll_line, c_smonrt);
  prsg_excel.line_cell_describe(ll_line, c_dfactdate);
  prsg_excel.line_cell_describe(ll_line, c_sprj_numb);
  prsg_excel.line_cell_describe(ll_line, c_sotv);

  prsg_excel.line_cell_describe(ll_line, c_nsum_wonds);
  prsg_excel.line_cell_describe(ll_line, c_nsum_withnds);
  prsg_excel.line_cell_describe(ll_line, c_nFAOP_Quant);
  prsg_excel.line_cell_describe(ll_line, c_nsum_material);
  prsg_excel.line_cell_describe(ll_line, c_nsum_fot);
  prsg_excel.line_cell_describe(ll_line, c_nsum_nalog);
  prsg_excel.line_cell_describe(ll_line, c_nsum_naklad);
  prsg_excel.line_cell_describe(ll_line, c_nsum_nproizv);
  prsg_excel.line_cell_describe(ll_line, c_nsum_ka);
  prsg_excel.line_cell_describe(ll_line, с_nsum_spec);
  prsg_excel.line_cell_describe(ll_line, с_nsum_oborud);
  prsg_excel.line_cell_describe(ll_line, с_nsum_other);
  prsg_excel.line_cell_describe(ll_line, c_nsum_sebst);
  prsg_excel.line_cell_describe(ll_line, c_nsum_prib);
  prsg_excel.line_cell_describe(ll_line, c_nsum_nds);
  prsg_excel.line_cell_describe(ll_line, c_npay_summ);
  prsg_excel.line_cell_describe(ll_line, c_nsum_cost);
  prsg_excel.line_cell_describe(ll_line, c_su4etnmb);
  prsg_excel.line_cell_describe(ll_line, c_setapnmb);
  prsg_excel.line_cell_describe(ll_line, c_stgrfnmb);

  prsg_excel.line_describe(ll_sum);
  prsg_excel.line_cell_describe(ll_sum, c_npp_tot);
  prsg_excel.line_cell_describe(ll_sum, c_sagent_tot);
  prsg_excel.line_cell_describe(ll_sum, c_sshifr_tot);
  prsg_excel.line_cell_describe(ll_sum, c_sdog_tot);
  prsg_excel.line_cell_describe(ll_sum, c_sprj_tot);
  prsg_excel.line_cell_describe(ll_sum, c_nsum_wonds_t);
  prsg_excel.line_cell_describe(ll_sum, c_nsum_withnds_t);
  prsg_excel.line_cell_describe(ll_sum, c_nFAOP_Quant_T);
  prsg_excel.line_cell_describe(ll_sum, c_nsum_material_t);
  prsg_excel.line_cell_describe(ll_sum, c_nsum_fot_t);
  prsg_excel.line_cell_describe(ll_sum, c_nsum_nalog_t);
  prsg_excel.line_cell_describe(ll_sum, c_nsum_naklad_t);
  prsg_excel.line_cell_describe(ll_sum, c_nsum_nproizv_t);
  prsg_excel.line_cell_describe(ll_sum, c_nsum_ka_t);
  prsg_excel.line_cell_describe(ll_sum, с_nsum_spec_t);
  prsg_excel.line_cell_describe(ll_sum, с_nsum_oborud_t);
  prsg_excel.line_cell_describe(ll_sum, с_nsum_other_t);
  prsg_excel.line_cell_describe(ll_sum, c_nsum_sebst_t);
  prsg_excel.line_cell_describe(ll_sum, c_nsum_prib_t);
  prsg_excel.line_cell_describe(ll_sum, c_nsum_nds_t);
  prsg_excel.line_cell_describe(ll_sum, c_npay_summ_t);

  prsg_excel.line_describe(ll_tot);
  prsg_excel.line_cell_describe(ll_tot, c_nsum_wonds_tot);
  prsg_excel.line_cell_describe(ll_tot, c_nsum_withnds_tot);
  prsg_excel.line_cell_describe(ll_tot, c_nFAOP_Quant_Tot);
  prsg_excel.line_cell_describe(ll_tot, c_nsum_material_tot);
  prsg_excel.line_cell_describe(ll_tot, c_nsum_fot_tot);
  prsg_excel.line_cell_describe(ll_tot, c_nsum_nalog_tot);
  prsg_excel.line_cell_describe(ll_tot, c_nsum_naklad_tot);
  prsg_excel.line_cell_describe(ll_tot, c_nsum_nproizv_tot);
  prsg_excel.line_cell_describe(ll_tot, c_nsum_ka_tot);
  prsg_excel.line_cell_describe(ll_tot, с_nsum_spec_tot);
  prsg_excel.line_cell_describe(ll_tot, с_nsum_oborud_tot);
  prsg_excel.line_cell_describe(ll_tot, с_nsum_other_tot);
  prsg_excel.line_cell_describe(ll_tot, c_nsum_sebst_tot);
  prsg_excel.line_cell_describe(ll_tot, c_nsum_prib_tot);
  prsg_excel.line_cell_describe(ll_tot, c_nsum_nds_tot);
  prsg_excel.line_cell_describe(ll_tot, c_npay_summ_tot);
  
  for ss in (select prs.faceacc                                   as prj_faceacc
                   ,st.rn
                   ,st.prn
                   ,st.numb
                   ,st.end_date
                   ,st.faceacc
                   ,st.stage_sum_nds
                   ,st.stage_sumtax
                   ,st.stage_sum
                   ,udo_f_stages_buhnum(st.rn)                    as st_buhnum
                   ,pfc.numb                                      as prst_buhnum
                   ,trim(cn.doc_pref) || '-' || trim(cn.doc_numb) as dog_numb
                   ,ag.agnname                                    as agent_name
                   ,udo_f_get_usl_name(cn.rn)                     as name_usl
                   ,age.agnabbr
                   ,( select str_value from docs_props_vals where docs_prop_rn = 1082887 and unit_rn = st.prn ) as sOtv
                   ,prj.code                                                                          as s1076177
                   ,st.dalt_enddate                                                                   as dAlt_EndDate
                   ,( select str_value from docs_props_vals where docs_prop_rn = 6000371 and unit_rn = cn.rn ) as U4_NMB       /* Учетный номер договора */
                   ,fc.nFA_FactSheepSum 
                   ,st.stage_sumtax - fc.nFA_FactSheepSum                                             as nStageSumRest
                   ,( 
                     select nvl( sum( pn.pay_sum ), 0)
                       from paynotes   pn
                      where pn.faceacc   = fc.rn
                        and pn.signplan  = 0
                        and pn.pay_date <= coalesce(dREPORT_DATE, st.end_date, pn.pay_date) 
                    ) as nPay_summ    /* Сумма фактических платежей */
                   ,( 
                     select count(*)
                       from fcacoperplans
                      where prn                    = st.faceacc 
                        and inexp_sign             = 1 
                        and nvl( summwithnds, 0 ) != 0
                    ) as nCount_Graf  /* Наличие у лицевого счёта графиков отпуска с ненулевой стоимостью с НДС  */
                   ,cpstr.*
               from contracts cn
                   ,agnlist   ag
                   ,( 
                     select t.*
                           ,( select date_value from docs_props_vals where docs_prop_rn = 7526416 and unit_rn = t.rn ) as dalt_enddate  /* РЕАЛЬНАЯ ДАТА */
                       from stages t 
                      where t.sign_sum = 1
                    ) st
                   ,( 
                     select t.*
                           ,( 
                             select nvl( sum( tic.summwithnds + tic.serv_summ_nds ), 0 )
                               from transinvcust tic
                              where tic.faceacc  = t.rn
                                and tic.docdate <= dREPORT_DATE 
                                and tic.doctype  not in ( 52567222 ) /* кроме тип документа "ОтпМатНаСт" */
                            ) as nFA_FactSheepSum /* Фактчиески отгружено по ЛС на дату отчёта. Сумма */
                       from faceacc t 
                    ) fc
                   ,projectstage  prs
                   ,project       prj
                   ,agnlist       age
                   ,faceacc       pfc
                   ,(
                     select t.rn  as cpstr_rn
                           ,t.prn as cpstr_prn
                           ,(select cn.cost_sum 
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sSoc_Codes2, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_Soc
                           ,(select sum(nvl(cn.cost_sum, 0))
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sFOT_Codes, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_FOT
                           ,(select cn.cost_sum
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sMat_Codes2, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_Material
                           ,(select cn.cost_sum
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sNakl_Codes, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_Naklad
                           ,(select cn.cost_sum
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sKA_Codes, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_KA
                           ,(select max(nvl(cn.cost_sum, 0))
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sSebst_Codes, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_Sebst
                           ,(select cn.cost_sum
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sPrib_Codes, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_Prib
                           ,(select cn.cost_sum
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sSpec_Codes, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_Spec
                           ,(select cn.cost_sum
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sOborud_Codes, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_Oborud
                           ,(select sum(nvl(cn.cost_sum, 0))
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sOther_Codes, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_Other
                           ,(select cn.cost_sum
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sProizv_Codes, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_NProizv
                           ,(select cn.cost_sum
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sSumW_NDS_Codes, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_WNDS
                           ,(select cn.cost_sum
                               from contrprclc cn
                                   ,fpdartcl   fp
                              where cn.cost_article = fp.rn
                                and strin( ssubstr => fp.code, ssource => sSum_NDS_Codes, sdelim => ';' ) = 1
                                and cn.prn = t.rn
                            ) as nSum_NDS
                       from contrprstruct t
                      where t.sign_act    = 1
                    ) cpstr
              where ( cn.rn in (select sl.document from selectlist sl where sl.ident = nident) 
                     or
                     nPARAM = 1 )
                and ag.rn         = cn.agent
                and fc.rn         = st.faceacc
                and st.faceacc    = prs.faceacccust(+)
                and cn.rn         = st.prn
                and prj.rn(+)     = prs.prn
                and pfc.rn(+)     = prs.faceacc
                and fc.ieelement  in ( 110949068, 6172145, 6172140 ) /* 'СубсидииРазработки_Б;Продажа товаров вСНГ;Темат. доходы_Б' */
                and cn.executive  = age.rn(+)
                and st.rn         = cpstr.cpstr_prn(+)
                and ( cn.close_date      is null or cn.close_date      >= dREPORT_DATE ) /* Дата закрытия договора больше или равна дате отчёта */
                and ( fc.fact_close_date is null or fc.fact_close_date >= dREPORT_DATE ) /* Дата закрытия лицевого счёта этапа больше или равна дате отчёта */
                and abs( st.stage_sumtax - fc.nFA_FactSheepSum ) > 100                   /* Сумма недоотгрузки по этапу больше 100 руб. */
                and cn.crn               not in (57479246)   /* Исключить каталог "Перспективные "*/
                and nvl( ( select num_value from docs_props_vals where docs_prop_rn = 212921797 and unit_rn = cn.rn ), 0 ) != 1  /* Исключить со свойством Признак "Отказ" */
-- and ( st.rn = 7464791 or user != 'STEPANOV_MV' )
              order by ag.agnname, s1076177, st.prn, st.numb 
           )
  loop
    /* Проверим актуальность вывода заголовка (итоги по Договору) */
    if (0 != nSt_Prn and ss.prn != nSt_Prn ) then
    
      /* Новая строка */
      nstr1 := prsg_excel.line_continue(ll_sum);
      /* Выводим итог по договору */
      prsg_excel.cell_value_write(c_npp_tot         , 0, nstr1, nPptot);
      prsg_excel.cell_value_write(c_sagent_tot      , 0, nstr1, sAgent);
      prsg_excel.cell_value_write(c_sshifr_tot      , 0, nstr1, sShifr);
      prsg_excel.cell_value_write(c_sdog_tot        , 0, nstr1, sDog);
      prsg_excel.cell_value_write(c_sprj_tot        , 0, nstr1, sPrj);    
      prsg_excel.cell_value_write(c_npay_summ_t     , 0, nstr1, nPay_SummT);
      prsg_excel.cell_value_write(c_nsum_nds_t      , 0, nstr1, nSum_NDST);
      prsg_excel.cell_value_write(c_nsum_wonds_t    , 0, nstr1, nSum_WoNDST);
      prsg_excel.cell_value_write(c_nsum_withnds_t  , 0, nstr1, nSum_WithNDST);
      prsg_excel.cell_value_write(c_nFAOP_Quant_T    , 0, nstr1, nFAOP_Quant_T);
      prsg_excel.cell_value_write(c_nsum_fot_t      , 0, nstr1, nSum_FOTT);
      prsg_excel.cell_value_write(c_nsum_nalog_t    , 0, nstr1, nSum_NalogT);
      prsg_excel.cell_value_write(c_nsum_material_t , 0, nstr1, nSum_MaterialT);
      prsg_excel.cell_value_write(c_nsum_naklad_t   , 0, nstr1, nSum_NakladT);
      prsg_excel.cell_value_write(c_nsum_nproizv_t  , 0, nstr1, nSum_NproizvT);
      prsg_excel.cell_value_write(c_nsum_ka_t       , 0, nstr1, nSum_KAT);
      prsg_excel.cell_value_write(с_nsum_spec_t     , 0, nstr1, nSum_SpecT);
      prsg_excel.cell_value_write(с_nsum_oborud_t   , 0, nstr1, nSum_OborudT);
      prsg_excel.cell_value_write(с_nsum_other_t    , 0, nstr1, nSum_OtherT);
      prsg_excel.cell_value_write(c_nsum_sebst_t    , 0, nstr1, nSum_SebstT);
      prsg_excel.cell_value_write(c_nsum_prib_t     , 0, nstr1, nSum_PribT);

      npptot := npptot + 1;
      nstr2  := prsg_excel.line_continue(ll_gap);

      /* Считаем итоги по отчету */
      nSum_MaterialTot := nSum_MaterialTot  + nSum_MaterialT;
      nSum_FotTot      := nSum_FotTot       + nSum_FotT;
      nSum_NalogTot    := nSum_NalogTot     + nSum_NalogT;
      nSum_NakladTot   := nSum_NakladTot    + nSum_NakladT;
      nSum_NproizvTot  := nSum_NproizvTot   + nSum_NproizvT;
      nSum_KATot       := nSum_KATot        + nSum_KAT;
      nSum_SpecTot     := nSum_SpecTot      + nSum_SpecT;
      nSum_OborudTot   := nSum_OborudTot    + nSum_OborudT;
      nSum_OtherTot    := nSum_OtherTot     + nSum_OtherT;
      nSum_SebstTot    := nSum_SebstTot     + nSum_SebstT;
      nSum_PribTot     := nSum_PribTot      + nSum_PribT;
      nSum_NDSTot      := nSum_NDSTot       + nSum_NDST;
      nPay_SummTot     := nPay_SummTot      + nPay_SummT;
      /* ОбНуляем итоги по договору */
      nSum_WondsT    := 0;
      nSum_WithNDST  := 0;
      nFAOP_Quant_T   := 0;
      nSum_MaterialT := 0;
      nSum_FOTT      := 0;
      nSum_NalogT    := 0;
      nSum_NakladT   := 0;
      nSum_NproizvT  := 0;
      nSum_KAT       := 0;
      nSum_SpecT     := 0;
      nSum_OborudT   := 0;
      nSum_OtherT    := 0;
      nSum_SebstT    := 0;
      nSum_PribT     := 0;
      nSum_NDST      := 0;
      nPay_SummT     := 0;
    end if;  /* конец вывода итгов по договору */
  
    /* Выводим строки по договору */
    nstr := prsg_excel.line_continue(ll_line);

    /* Номер по порядку */
    prsg_excel.cell_value_write(c_npp, 0, nstr, npptot || '.' || trim(ss.numb));
    
    /* Контрагент */
    if sagent is null or sagent != ss.agent_name then
      prsg_excel.cell_value_write(c_sagent_name, 0, nstr, ss.agent_name);
    end if;
    /* Шифр */
    if sshifr is null or sshifr != ss.name_usl then
      prsg_excel.cell_value_write(c_sshifr, 0, nstr, ss.name_usl);
    end if;
    
    /* Запись в первые колонки */
    prsg_excel.cell_value_write(c_sdog_numb , 0, nstr, ss.dog_numb);
    prsg_excel.cell_value_write(c_sprj_numb , 0, nstr, nvl(ss.prst_buhnum, ' - '));
    prsg_excel.cell_value_write(c_smonrt    , 0, nstr, to_char(ss.end_date, 'dd.mm.yyyy'));
    prsg_excel.cell_value_write(c_sotv      , 0, nstr, ss.agnabbr || ' (' || ss.sotv || ')');
    prsg_excel.cell_value_write(c_npay_summ , 0, nstr, ss.nPay_Summ);
    prsg_excel.cell_value_write(c_nsum_nds  , 0, nstr, ss.Stage_Sum_NDS);
    prsg_excel.cell_value_write(c_dfactdate , 0, nstr, to_char(ss.dalt_enddate, 'dd.mm.yyyy'));
    prsg_excel.cell_value_write(c_su4etnmb  , 0, nstr, ss.U4_NMB); 
    prsg_excel.cell_value_write(c_setapnmb  , 0, nstr, ss.numb); 
    nPay_Summt := nPay_SummT + nPay_Summ;

    /*Есть график отгрузки с калькуляцией! Печатаем по плану отгрузки из графиков */
    if ss.nCount_Graf != 0 then 
      for grf in (select tt.numb
                        ,tt.fp_Nomen_Modif
                        ,dalt_grenddate
                        ,sum( tt.nSum_Prib )        as nSum_Prib
                        ,sum( tt.nSum_Sebst )       as nSum_Sebst
                        ,sum( tt.nSum_Ka )          as nSum_Ka
                        ,sum( tt.nSum_Spec )        as nSum_Spec
                        ,sum( tt.nSum_Oborud )      as nSum_Oborud
                        ,sum( tt.nSum_Other )       as nSum_Other
                        ,sum( tt.nSum_Naklad )      as nSum_Naklad
                        ,sum( tt.nSum_Nproizv )     as nSum_Nproizv
                        ,sum( tt.nSum_Material )    as nSum_Material
                        ,sum( tt.nSum_Soc )         as nSum_Soc
                        ,sum( tt.nSum_Fot )         as nSum_Fot
                        ,sum( tt.nSum_1700 )        as nSum_1700
                        ,sum( tt.nSum_1900 )        as nSum_1900
                        ,sum( tt.nSum_Woutnds )     as nSum_WoutNDS
                        ,sum( tt.nSum_Wnds )        as nSum_WithNDS
                        ,sum( tt.nSum_Nds )         as nSum_Nds
                        ,sum( tt.fp_nSumm_NDS )     as fp_nSumm_NDS
                        ,sum( tt.fp_nSummWithNDS )  as fp_nSummWithNDS
                        ,sum( tt.fp_nSumm )         as fp_nSumm
                        ,sum( tt.fp_nQuant )        as fp_nQuant
                        ,max( tt.end_date )         as dEnd_Date
                        ,sum( tt.nTrans_SummWNDS )  as nTrans_SummWNDS
                        ,sum( tt.nTrans_Summ )      as nTrans_Summ
                        ,sum( tt.fp_nSummWithNDS - tt.nTrans_SummWNDS ) as nFAOP_RestSumWithNDS
                        ,sum( tt.fp_nSumm        - tt.nTrans_Summ )     as nFAOP_RestSumWoNDS
                        ,sum( tt.fp_nQuant       - tt.nTrans_Quant )    as nFAOP_RestQuant
                        ,min( tt.nCount_Graf_Calc )                     as nCount_Graf_Calc
                    from (select fp.end_date
                                ,(
                                  select nvl( sum( fpc.cost_plan * fp.quant ), 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sFOT_Codes, sdelim => ';' ) = 1
                                  ) as nSum_FOT
                                ,(select nvl( max( fpc.cost_plan * fp.quant ), 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sSoc_Codes, sdelim => ';' ) = 1
                                 ) as nSum_Soc
                                ,(select nvl( max( fpc.cost_plan * fp.quant ), 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sMat_Codes, sdelim => ';' ) = 1
                                 ) as nSum_Material
                                ,(select nvl( fpc.cost_plan * fp.quant, 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sNakl_Codes, sdelim => ';' ) = 1
                                 ) as nSum_Naklad
                                ,(select nvl( fpc.cost_plan * fp.quant, 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sProizv_Codes, sdelim => ';' ) = 1
                                 ) as nSum_Nproizv
                                ,(select nvl( fpc.cost_plan * fp.quant, 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sKA_Codes, sdelim => ';' ) = 1
                                 ) as nSum_KA
                                ,(select nvl( max( fpc.cost_plan * fp.quant ), 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sSebst_Codes, sdelim => ';' ) = 1
                                 ) as nSum_Sebst
                                ,(select nvl( max( fpc.cost_plan * fp.quant), 0 )
                                    from fcacoperplansclc fpc
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = 6266533 /* стр. 1700 Себестоимость */
                                 ) as nSum_1700
                                ,(select nvl( max( fpc.cost_plan * fp.quant), 0 )
                                    from fcacoperplansclc fpc
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = 500992 /* стр. 1900 Цена без НДС */
                                 ) as nSum_1900
                                ,(select nvl( fpc.cost_plan * fp.quant, 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sPrib_Codes, sdelim => ';' ) = 1
                                 ) as nSum_Prib
                                ,(select nvl( fpc.cost_plan * fp.quant, 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sSpec_Codes, sdelim => ';' ) = 1
                                 ) as nSum_Spec
                                ,(select nvl( fpc.cost_plan * fp.quant, 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sOborud_Codes, sdelim => ';' ) = 1
                                 )  as nSum_Oborud
                                ,(select nvl( sum( fpc.cost_plan * fp.quant ), 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sOther_Codes, sdelim => ';' ) = 1
                                 )  as nSum_Other
                                ,(select nvl( fpc.cost_plan * fp.quant, 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sSumWO_Codes, sdelim => ';' ) = 1
                                 )  as nSum_WOutNDS
                                ,(select nvl( fpc.cost_plan * fp.quant, 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sSumW_NDS_Codes, sdelim => ';' ) = 1
                                 )  as nSum_WNDS
                                ,(select nvl( fpc.cost_plan * fp.quant, 0 )
                                    from fcacoperplansclc fpc
                                        ,fpdartcl         fa
                                   where fpc.prn          = fp.rn
                                     and fpc.cost_article = fa.rn
                                     and strin( ssubstr => fa.code, ssource => sSum_NDS_Codes, sdelim => ';' ) = 1
                                 )  as nSum_NDS
                                ,extract( month from fp.end_date )  as nMonth
                                ,extract( year  from fp.end_date )  as nYear
                                ,fp.numb
                                ,fp.dalt_grenddate
                                ,fp.summ                          as fp_nSumm
                                ,fp.summwithnds                   as fp_nSummWithNDS
                                ,fp.summ_nds                      as fp_nSumm_NDS
                                ,fp.quant                         as fp_nQuant
                                ,(
                                  select nvl( sum( trs.summwithnds ), 0 )
                                    from transinvcust               th
                                        ,transinvcustspecs          trs
                                        ,udo_t_transinvcustspecs_ex ex
                                   where ex.prn           = trs.rn
                                     and ex.fcacoperplans = fp.rn
                                     and th.rn            = trs.prn
                                     and th.docdate      <= dREPORT_DATE
                                     and th.doctype       not in ( 52567222 ) /* кроме тип документа "ОтпМатНаСт" */
                                 )  as nTrans_SummWNDS
                                ,(
                                  select nvl( sum( trs.summ ), 0 )
                                    from transinvcust               th
                                        ,transinvcustspecs          trs
                                        ,udo_t_transinvcustspecs_ex ex
                                   where ex.prn           = trs.rn
                                     and ex.fcacoperplans = fp.rn
                                     and th.rn            = trs.prn
                                     and th.docdate      <= dREPORT_DATE
                                     and th.doctype       not in ( 52567222 ) /* кроме тип документа "ОтпМатНаСт" */
                                 )  as nTrans_Summ
                                ,(
                                  select nvl( sum( trs.quant ), 0 )
                                    from transinvcust               th
                                        ,transinvcustspecs          trs
                                        ,udo_t_transinvcustspecs_ex ex
                                   where ex.prn           = trs.rn
                                     and ex.fcacoperplans = fp.rn
                                     and th.rn            = trs.prn
                                     and th.docdate      <= dREPORT_DATE
                                     and th.doctype       not in ( 52567222 ) /* кроме тип документа "ОтпМатНаСт" */
                                 )  as nTrans_Quant
                                ,( 
                                  select nvl( count(*), 0 )
                                    from fcacoperplansclc
                                   where prn = fp.rn 
                                 ) as nCount_Graf_Calc
                                ,fp.nomen_modif as fp_Nomen_Modif
                            from (
                                  select t.*
                                        ,( select date_value from docs_props_vals where docs_prop_rn = 7526416 and unit_rn = t.rn ) as dalt_grenddate /* Ожидаемая дата накладной */
                                        ,dnm.nomen_name /*||', '|| nmd.modif_name*/ as Nomen_Modif
                                    from fcacoperplans  t 
                                    join dicnomns       dnm on dnm.rn = t.nomen
                                    join nommodif       nmd on nmd.rn = t.nommodif
                                 )  fp
                           where fp.prn         = ss.faceacc
                             and fp.inexp_sign  = 1
                             ) tt
                      where abs( tt.fP_nSummWithNDS - tt.nTrans_SummWNDS ) > 100
                   group by tt.numb
                           ,tt.nyear
                           ,tt.nmonth
                           ,tt.dalt_grenddate
                           ,tt.fp_nomen_modif
                   order by tt.numb
                           ,tt.nyear
                           ,tt.nmonth )
      loop
        /* Меняем цвет */
        if  grf.dalt_grenddate is not null 
        and grf.dalt_grenddate > grf.dend_date then
          prsg_excel.cell_attribute_set(scell_name => c_dfactdate, sattribute_name => 'Interior.ColorIndex', sattribute_value => 3);
        else
          prsg_excel.cell_attribute_set(scell_name => c_dfactdate, sattribute_name  => 'Interior.ColorIndex', sattribute_value => 2);
        end if;

        /* Новая строка */
        nstr := prsg_excel.line_continue(ll_line);
        
        /* Если у графика есть калькуляции */
        if grf.nCount_Graf_Calc != 0 then
          /* Другие колонки */
          prsg_excel.cell_value_write(c_npp           , 0, nstr, npptot || '.' || trim(ss.numb) || '.' || trim(grf.numb));
          prsg_excel.cell_value_write(c_stgrfnmb      , 0, nstr, grf.numb);
          prsg_excel.cell_value_write(c_Nomen_Modif   , 0, nstr, grf.fp_Nomen_Modif);
          prsg_excel.cell_value_write(c_smonrt        , 0, nstr, to_char( grf.dend_date     , 'dd.mm.yyyy' ));
          prsg_excel.cell_value_write(c_dfactdate     , 0, nstr, to_char( grf.dalt_grenddate, 'dd.mm.yyyy' ));
          prsg_excel.cell_value_write(c_sprj_numb     , 0, nstr, nvl(ss.prst_buhnum, ' - '));
          /* Колонки "Выручка  не обл НДС" и "Выручка обл НДС с НДС" */
          /* если в графике нет НДС, то выводим сумму без НДС*/
          if grf.fP_nSumm_NDS = 0 then
            prsg_excel.cell_value_write(c_nsum_wonds, 0, nstr, grf.nFAOP_RestSumWoNDS);
          /* иначе с НДС*/
          else
            prsg_excel.cell_value_write(c_nsum_withnds, 0, nstr, grf.nFAOP_RestSumWithNDS);
          end if;
          prsg_excel.cell_value_write(c_nFAOP_Quant, 0, nstr, grf.nFAOP_RestQuant);

          prsg_excel.cell_value_write(c_nsum_fot      , 0, nstr, grf.nSum_fot       * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) );
          prsg_excel.cell_value_write(c_nsum_nalog    , 0, nstr, grf.nSum_soc       * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) );
          prsg_excel.cell_value_write(c_nsum_material , 0, nstr, grf.nSum_material  * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) );
          prsg_excel.cell_value_write(c_nsum_naklad   , 0, nstr, grf.nSum_naklad    * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) );
          prsg_excel.cell_value_write(c_nsum_nproizv  , 0, nstr, grf.nSum_nproizv   * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) );
          prsg_excel.cell_value_write(c_nsum_ka       , 0, nstr, grf.nSum_ka        * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) );
          prsg_excel.cell_value_write(с_nsum_spec     , 0, nstr, grf.nSum_spec      * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) );
          prsg_excel.cell_value_write(с_nsum_oborud   , 0, nstr, grf.nSum_oborud    * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) );
          prsg_excel.cell_value_write(с_nsum_other    , 0, nstr, grf.nSum_other     * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) );
          prsg_excel.cell_value_write(c_nsum_sebst    , 0, nstr, grf.nSum_sebst     * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) );
          prsg_excel.cell_value_write(c_nsum_prib     , 0, nstr, grf.nSum_prib      * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) );
          prsg_excel.cell_value_write(c_nsum_nds      , 0, nstr, grf.nSum_nds       * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) );
          prsg_excel.cell_value_write(c_su4etnmb      , 0, nstr, ss.U4_NMB); 
          prsg_excel.cell_value_write(c_setapnmb      , 0, nstr, ss.numb); 
          prsg_excel.cell_value_write(c_sdog_numb     , 0, nstr, ss.dog_numb);
          prsg_excel.cell_value_write(c_sotv          , 0, nstr, ss.agnabbr || ' (' || ss.sotv || ')' );
          
          /* Колонки "Выручка  не обл НДС" и "Выручка обл НДС с НДС" */
          /* если в графике есть НДС, то выводим сумму без НДС*/
          if grf.fP_nSumm_NDS = 0 then
            nSum_WoNDSTot     := nSum_WoNDSTot + grf.nFAOP_RestSumWoNDS;
            nSum_WoNDST       := nSum_WoNDST   + grf.nFAOP_RestSumWoNDS;
          /* иначе сумму с НДС*/
          else
            nSum_WithNDST     := nSum_WithNDST   + grf.nFAOP_RestSumWithNDS;
            nSum_WithNDSTot   := nSum_WithNDSTot + grf.nFAOP_RestSumWithNDS;
          end if;
--          nFA     := nSum_WithNDST   + grf.nFAOP_RestSumWithNDS;

          nFAOP_Quant_T   := nFAOP_Quant_T   + grf.nFAOP_RestQuant;
          nFAOP_Quant_Tot := nFAOP_Quant_Tot + grf.nFAOP_RestQuant;

          nSum_FOTT      := nSum_FotT       + grf.nSum_FOT      * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 );
          nSum_NalogT    := nSum_NalogT     + grf.nSum_Soc      * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 );
          nSum_MaterialT := nSum_MaterialT  + grf.nSum_Material * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 );
          nSum_NakladT   := nSum_NakladT    + grf.nSum_Naklad   * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 );
          nSum_NproizvT  := nSum_NproizvT   + grf.nSum_Nproizv  * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 );
          nSum_KAT       := nSum_KAT        + grf.nSum_KA       * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 );
          nSum_SpecT     := nSum_SpecT      + grf.nSum_Spec     * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 );
          nSum_OborudT   := nSum_OborudT    + grf.nSum_Oborud   * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 );
          nSum_OtherT    := nSum_OtherT     + grf.nSum_Other    * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 );
          nSum_SebstT    := nSum_SebstT     + grf.nSum_Sebst    * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 );
          nSum_PribT     := nSum_PribT      + grf.nSum_Prib     * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 );
          nSum_NDST      := nSum_NDST       + grf.nSum_NDS      * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 );

        /* Если у графика нет калькуляци */
        else
          /* Удельный вес графика в сумме этапа */
          nGraf_Coeff := grf.fP_nSummWithNDS / ss.nsum_wnds;
          /* Другие колонки */
          prsg_excel.cell_value_write(c_npp           , 0, nstr, npptot || '.' || trim(ss.numb) || '.' || trim(grf.numb));
          prsg_excel.cell_value_write(c_stgrfnmb      , 0, nstr, grf.numb);
          prsg_excel.cell_value_write(c_Nomen_Modif   , 0, nstr, grf.fp_Nomen_Modif);
          prsg_excel.cell_value_write(c_smonrt        , 0, nstr, to_char( grf.dend_date     , 'dd.mm.yyyy' ));
          prsg_excel.cell_value_write(c_dfactdate     , 0, nstr, to_char( grf.dalt_grenddate, 'dd.mm.yyyy' ));
          prsg_excel.cell_value_write(c_sprj_numb     , 0, nstr, nvl(ss.prst_buhnum, ' - '));
          /* Колонки "Выручка  не обл НДС" и "Выручка обл НДС с НДС" */
          /* если в графике нет НДС, то выводим сумму без НДС*/
          if grf.nsum_nds = 0 then
            prsg_excel.cell_value_write(c_nsum_wonds, 0, nstr, grf.nFAOP_RestSumWoNDS);
          /* иначе с НДС*/
          else
            prsg_excel.cell_value_write(c_nsum_withnds, 0, nstr, grf.nFAOP_RestSumWithNDS);
          end if;

          prsg_excel.cell_value_write(c_nFAOP_Quant, 0, nstr, grf.nFAOP_RestQuant);

          prsg_excel.cell_value_write(c_nsum_fot      , 0, nstr, ss.nSum_FOT       * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff );
          prsg_excel.cell_value_write(c_nsum_nalog    , 0, nstr, ss.nSum_Soc       * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff );
          prsg_excel.cell_value_write(c_nsum_material , 0, nstr, ss.nSum_Material  * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff );
          prsg_excel.cell_value_write(c_nsum_naklad   , 0, nstr, ss.nSum_Naklad    * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff );
          prsg_excel.cell_value_write(c_nsum_nproizv  , 0, nstr, ss.nSum_Nproizv   * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff );
          prsg_excel.cell_value_write(c_nsum_ka       , 0, nstr, ss.nSum_KA        * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff );
          prsg_excel.cell_value_write(с_nsum_spec     , 0, nstr, ss.nSum_Spec      * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff );
          prsg_excel.cell_value_write(с_nsum_oborud   , 0, nstr, ss.nSum_Oborud    * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff );
          prsg_excel.cell_value_write(с_nsum_other    , 0, nstr, ss.nSum_Other     * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff );
          prsg_excel.cell_value_write(c_nsum_sebst    , 0, nstr, ss.nSum_Sebst     * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff );
          prsg_excel.cell_value_write(c_nsum_prib     , 0, nstr, ss.nSum_Prib      * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff );
          prsg_excel.cell_value_write(c_nsum_nds      , 0, nstr, ss.nSum_NDS       * grf.nFAOP_RestSumWoNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff );
          prsg_excel.cell_value_write(c_su4etnmb      , 0, nstr, ss.U4_NMB); 
          prsg_excel.cell_value_write(c_setapnmb      , 0, nstr, ss.numb); 
          prsg_excel.cell_value_write(c_sdog_numb     , 0, nstr, ss.dog_numb);
          prsg_excel.cell_value_write(c_sotv          , 0, nstr, ss.agnabbr || ' (' || ss.sotv || ')' );
          
          /* Колонки "Выручка  не обл НДС" и "Выручка обл НДС с НДС" */
          /* если в графике есть НДС, то выводим сумму без НДС*/
          if grf.nsum_nds = 0 then
            nSum_WoNDSTot     := nSum_WoNDSTot + grf.nFAOP_RestSumWoNDS;
            nSum_WoNDST       := nSum_WoNDST   + grf.nFAOP_RestSumWoNDS;
          /* иначе сумму с НДС*/
          else
            nSum_WithNDST     := nSum_WithNDST   + grf.nFAOP_RestSumWithNDS;
            nSum_WithNDSTot   := nSum_WithNDSTot + grf.nFAOP_RestSumWithNDS;
          end if;
          nFAOP_Quant_T       := nFAOP_Quant_T   + grf.nFAOP_RestQuant;
          nFAOP_Quant_Tot     := nFAOP_Quant_Tot + grf.nFAOP_RestQuant;

          nSum_FOTT      := nSum_FotT       + ss.nSum_FOT      * grf.nFAOP_RestSumWithNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff ;
          nSum_NalogT    := nSum_NalogT     + ss.nSum_Soc      * grf.nFAOP_RestSumWithNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff ;
          nSum_MaterialT := nSum_MaterialT  + ss.nSum_Material * grf.nFAOP_RestSumWithNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff ;
          nSum_NakladT   := nSum_NakladT    + ss.nSum_Naklad   * grf.nFAOP_RestSumWithNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff ;
          nSum_NproizvT  := nSum_NproizvT   + ss.nSum_Nproizv  * grf.nFAOP_RestSumWithNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff ;
          nSum_KAT       := nSum_KAT        + ss.nSum_KA       * grf.nFAOP_RestSumWithNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff ;
          nSum_SpecT     := nSum_SpecT      + ss.nSum_Spec     * grf.nFAOP_RestSumWithNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff ;
          nSum_OborudT   := nSum_OborudT    + ss.nSum_Oborud   * grf.nFAOP_RestSumWithNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff ;
          nSum_OtherT    := nSum_OtherT     + ss.nSum_Other    * grf.nFAOP_RestSumWithNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff ;
          nSum_SebstT    := nSum_SebstT     + ss.nSum_Sebst    * grf.nFAOP_RestSumWithNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff ;
          nSum_PribT     := nSum_PribT      + ss.nSum_Prib     * grf.nFAOP_RestSumWithNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff ;
          nSum_NDST      := nSum_NDST       + ss.nSum_NDS      * grf.nFAOP_RestSumWithNDS / zero2null( grf.nSum_1900 ) * nGraf_Coeff ;
        end if;
      end loop;
  
    /* Если есть графики отпуска, то структуру не печатаем */
    else

      /* Неотгруженный остаток этапа */
      if (ss.stage_sum_nds > 0) then
        /* Записываем неотгруженный остаток этапа */
        prsg_excel.cell_value_write(c_nsum_wonds  , 0, nstr, '--');
        prsg_excel.cell_value_write(c_nsum_withnds, 0, nstr, ss.nStageSumRest);
        /* Суммируем неотгруженный остаток этапа */
        nsum_withndst   := nsum_withndst   + ss.nStageSumRest;
        nsum_withndstot := nsum_withndstot + ss.nStageSumRest;
      else
        /* Записываем неотгруженный остаток этапа */
        prsg_excel.cell_value_write(c_nsum_wonds  , 0, nstr, ss.nStageSumRest);
        prsg_excel.cell_value_write(c_nsum_withnds, 0, nstr, '--');
        /* Суммируем неотгруженный остаток этапа */
        nsum_wondst   := nsum_wondst   + ss.nStageSumRest;
        nsum_wondstot := nsum_wondstot + ss.nStageSumRest;
      end if;
 
      prsg_excel.cell_value_write(c_nsum_fot      , 0, nstr, ss.nsum_fot      * ss.nStageSumRest / zero2null( ss.nsum_wnds ) );
      prsg_excel.cell_value_write(c_nsum_nalog    , 0, nstr, ss.nsum_soc      * ss.nStageSumRest / zero2null( ss.nsum_wnds ) );
      prsg_excel.cell_value_write(c_nsum_material , 0, nstr, ss.nsum_material * ss.nStageSumRest / zero2null( ss.nsum_wnds ) );
      prsg_excel.cell_value_write(c_nsum_naklad   , 0, nstr, ss.nsum_naklad   * ss.nStageSumRest / zero2null( ss.nsum_wnds ) );
      prsg_excel.cell_value_write(c_nsum_nproizv  , 0, nstr, ss.nsum_nproizv  * ss.nStageSumRest / zero2null( ss.nsum_wnds ) );
      prsg_excel.cell_value_write(c_nsum_ka       , 0, nstr, ss.nsum_ka       * ss.nStageSumRest / zero2null( ss.nsum_wnds ) );
      prsg_excel.cell_value_write(с_nsum_spec     , 0, nstr, ss.nsum_spec     * ss.nStageSumRest / zero2null( ss.nsum_wnds ) );
      prsg_excel.cell_value_write(с_nsum_oborud   , 0, nstr, ss.nsum_oborud   * ss.nStageSumRest / zero2null( ss.nsum_wnds ) );
      prsg_excel.cell_value_write(с_nsum_other    , 0, nstr, ss.nsum_other    * ss.nStageSumRest / zero2null( ss.nsum_wnds ) );
      prsg_excel.cell_value_write(c_nsum_sebst    , 0, nstr, ss.nsum_sebst    * ss.nStageSumRest / zero2null( ss.nsum_wnds ) );
      prsg_excel.cell_value_write(c_nsum_prib     , 0, nstr, ss.nsum_prib     * ss.nStageSumRest / zero2null( ss.nsum_wnds ) );

      nsum_fott      := nsum_fott       + ss.nsum_fot      * ss.nStageSumRest / zero2null( ss.nsum_wnds ) ;
      nsum_nalogt    := nsum_nalogt     + ss.nsum_soc      * ss.nStageSumRest / zero2null( ss.nsum_wnds ) ;
      nsum_materialt := nsum_materialt  + ss.nsum_material * ss.nStageSumRest / zero2null( ss.nsum_wnds ) ;
      nsum_nakladt   := nsum_nakladt    + ss.nsum_naklad   * ss.nStageSumRest / zero2null( ss.nsum_wnds ) ;
      nsum_nproizvt  := nsum_nproizvt   + ss.nsum_nproizv  * ss.nStageSumRest / zero2null( ss.nsum_wnds ) ;
      nsum_kat       := nsum_kat        + ss.nsum_ka       * ss.nStageSumRest / zero2null( ss.nsum_wnds ) ;
      nsum_spect     := nsum_spect      + ss.nsum_spec     * ss.nStageSumRest / zero2null( ss.nsum_wnds ) ;
      nsum_oborudt   := nsum_oborudt    + ss.nsum_oborud   * ss.nStageSumRest / zero2null( ss.nsum_wnds ) ;
      nsum_othert    := nsum_othert     + ss.nsum_other    * ss.nStageSumRest / zero2null( ss.nsum_wnds ) ;
      nsum_sebstt    := nsum_sebstt     + ss.nsum_sebst    * ss.nStageSumRest / zero2null( ss.nsum_wnds ) ;
      nsum_pribt     := nsum_pribt      + ss.nsum_prib     * ss.nStageSumRest / zero2null( ss.nsum_wnds ) ;
      /*nsum_ndst      := nsum_ndst       + */

    end if;

    nst_prn := ss.prn;
    sagent  := ss.agent_name;
    sshifr  := ss.name_usl;
    sdog    := ss.dog_numb;
    sprj    := ss.s1076177;
  end loop;

  /* Печатаем итоги по отчету */
  if nst_prn != 0 then
  
    nstr1 := prsg_excel.line_continue(ll_sum);
    
    /* тут надо печатать последние  итоги по Договору и итоги по Отчету. */
    prsg_excel.cell_value_write(c_npp_tot   , 0, nstr1, npptot);
    prsg_excel.cell_value_write(c_sagent_tot, 0, nstr1, sAgent);
    prsg_excel.cell_value_write(c_sshifr_tot, 0, nstr1, sShifr);
    prsg_excel.cell_value_write(c_sdog_tot  , 0, nstr1, sDog);
    prsg_excel.cell_value_write(c_sprj_tot  , 0, nstr1, sPrj);
  
    prsg_excel.cell_value_write(c_npay_summ_t     , 0, nstr1, nPay_summt);
    prsg_excel.cell_value_write(c_nsum_nds_t      , 0, nstr1, nSum_ndst);
    prsg_excel.cell_value_write(c_nsum_wonds_t    , 0, nstr1, nSum_wondst);
    prsg_excel.cell_value_write(c_nsum_withnds_t  , 0, nstr1, nSum_withndst);  
    prsg_excel.cell_value_write(c_nFAOP_Quant_T   , 0, nstr1, nFAOP_Quant_T);  
    prsg_excel.cell_value_write(c_nsum_fot_t      , 0, nstr1, nSum_fott);
    prsg_excel.cell_value_write(c_nsum_nalog_t    , 0, nstr1, nSum_nalogt);
    prsg_excel.cell_value_write(c_nsum_material_t , 0, nstr1, nSum_materialt);
    prsg_excel.cell_value_write(c_nsum_naklad_t   , 0, nstr1, nSum_nakladt);
    prsg_excel.cell_value_write(c_nsum_nproizv_t  , 0, nstr1, nSum_nproizvt);
    prsg_excel.cell_value_write(c_nsum_ka_t       , 0, nstr1, nSum_kat);
    prsg_excel.cell_value_write(с_nsum_spec_t     , 0, nstr1, nSum_spect);
    prsg_excel.cell_value_write(с_nsum_oborud_t   , 0, nstr1, nSum_oborudt);
    prsg_excel.cell_value_write(с_nsum_other_t    , 0, nstr1, nSum_othert);
    prsg_excel.cell_value_write(c_nsum_sebst_t    , 0, nstr1, nSum_sebstt);
    prsg_excel.cell_value_write(c_nsum_prib_t     , 0, nstr1, nSum_pribt);
  
    nSum_MaterialTot := nSum_MaterialTot  + nSum_MaterialT;
    nSum_FotTot      := nSum_FotTot       + nSum_FOTT;
    nSum_NalogTot    := nSum_NalogTot     + nSum_NalogT;
    nSum_NakladTot   := nSum_NakladTot    + nSum_NakladT;
    nSum_NproizvTot  := nSum_NproizvTot   + nSum_NproizvT;
    nSum_KATot       := nSum_KATot        + nSum_KAT;
    nSum_SpecTot     := nSum_SpecTot      + nSum_SpecT;
    nSum_OborudTot   := nSum_OborudTot    + nSum_OborudT;
    nSum_OtherTot    := nSum_OtherTot     + nSum_OtherT;
    nSum_SebstTot    := nSum_SebstTot     + nSum_SebstT;
    nSum_PribTot     := nSum_PribTot      + nSum_PribT;
    nSum_NdsTot      := nSum_NdsTot       + nSum_NDST;
    nPay_SummTot     := nPay_SummTot      + nPay_SummT;
  
    nstr1 := prsg_excel.line_continue(ll_tot);
    prsg_excel.cell_value_write(c_npay_summ_tot     , 0, nstr1, nPay_SummTot);
    prsg_excel.cell_value_write(c_nsum_nds_tot      , 0, nstr1, nSum_NdsTot);
    prsg_excel.cell_value_write(c_nsum_wonds_tot    , 0, nstr1, nSum_WondsTot);
    prsg_excel.cell_value_write(c_nsum_withnds_tot  , 0, nstr1, nSum_WithndsTot);
    prsg_excel.cell_value_write(c_nFAOP_Quant_Tot   , 0, nstr1, nFAOP_Quant_Tot);
    prsg_excel.cell_value_write(c_nsum_fot_tot      , 0, nstr1, nSum_FotTot);
    prsg_excel.cell_value_write(c_nsum_nalog_tot    , 0, nstr1, nSum_NalogTot);
    prsg_excel.cell_value_write(c_nsum_material_tot , 0, nstr1, nSum_MaterialTot);
    prsg_excel.cell_value_write(c_nsum_naklad_tot   , 0, nstr1, nSum_NakladTot);
    prsg_excel.cell_value_write(c_nsum_nproizv_tot  , 0, nstr1, nSum_NproizvTot);
    prsg_excel.cell_value_write(c_nsum_ka_tot       , 0, nstr1, nSum_KaTot);
    prsg_excel.cell_value_write(с_nsum_spec_tot     , 0, nstr1, nSum_SpecTot);
    prsg_excel.cell_value_write(с_nsum_oborud_tot   , 0, nstr1, nSum_OborudTot);
    prsg_excel.cell_value_write(с_nsum_other_tot    , 0, nstr1, nSum_OtherTot);
    prsg_excel.cell_value_write(c_nsum_sebst_tot    , 0, nstr1, nSum_SebstTot);
    prsg_excel.cell_value_write(c_nsum_prib_tot     , 0, nstr1, nSum_PribTot);
  end if;

  /* Удаляем технические строки */
  prsg_excel.line_delete(ll_line);
  prsg_excel.line_delete(ll_gap);
  prsg_excel.line_delete(ll_sum);
  prsg_excel.line_delete(ll_tot);

end udo_pr_stages_planpay;
/
