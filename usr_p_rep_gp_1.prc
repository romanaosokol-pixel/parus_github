create or replace procedure usr_p_rep_gp_1
(
 nIDENT       in number
,dBEGIN       in date
,dEND         in date
,nMODE        in number /* Режим печати: 0 - по текущей партии, 1 - по номенклатуре текущей партии, 2 - по серии текущей партии */
)
/*
Отчет "Движение по номенклатуре партии товара". 29/03/2023 Степанов М.
create public synonym usr_p_rep_gp_1 for usr_p_rep_gp_1;
grant execute on usr_p_rep_gp_1 to public;
*/
as
  rRow            usr_t_temp%rowtype;
  rGoodsParties   goodsparties%rowtype;
  rDicNomns       dicnomns%rowtype;
  rNomModif       nommodif%rowtype;
  bLoop           boolean := false;
  nRest           pkg_std.tquant := 0;
begin
  /* Очистка таблицы */
  delete from usr_t_temp t where t.authid = utilizer;

  /* Считывание текущего документа по селектлисту */
  begin
    select gp.*
      into rGoodsParties
      from selectlist   sl
      join goodsparties gp  on gp.rn = sl.document
     where sl.ident = nIDENT;
    exception
    when no_data_found then
      p_exception(0, 'Не найден документ с IDENT <%s> в разделе <%s>.', nIDENT, f_unitlist_getname(get_unitlist_code_table(1, 'GOODSPARTIES'))||'>.');
    when too_many_rows THEN
      p_exception(0, 'Отмечено больше одного документа с IDENT <%s> в разделе <%s>');
    when others then
      p_exception(0, 'Неопределённая ситуация при поиске документа с IDENT <%s> в разделе <%s>.', nIDENT, f_unitlist_getname(get_unitlist_code_table(1, 'GOODSPARTIES'))||'>.');
  end;
  
  /* Номенклатура и модификация */
  select * into rNomModif from nommodif where rn = rGoodsParties.nommodif;
  select * into rDicNomns from dicnomns where rn = rNomModif.prn;

  /* Остаток на начало */
  begin
    select sum(h.restfact)
      into rRow.n003
      from goodsparties     gp
      join goodssupply      sup on   sup.prn      = gp.rn
      join goodssupplyhist  h   on   h.prn        = sup.rn
                               and   h.date_from <= dBEGIN - 1                        and dBEGIN is not null   /* предыдущий день от даты начала */
                               and ( h.date_to   >= dBEGIN - 1 or h.date_to is null ) and dBEGIN is not null
                               and   h.restfact  != 0
     where ( gp.rn       = rGoodsParties.rn       and nMODE = 0
            or
             gp.nommodif = rGoodsParties.nommodif and nMODE = 1
            or
             gp.rn       in ( select rn from goodsparties where sernumb = rGoodsParties.sernumb ) and nMODE = 2 );
  exception
    when no_data_found then
      rRow.n003 := 0;
    when others then
      p_exception(0, 'Неопределённая ситуация при определении остатка по модификации %s на дату %s', rNomModif.modif_name, dBEGIN);
  end;

  /* Сохранение остатка на начало для расчёта остатка на конец */
  nRest := nvl(rRow.n003, 0);

  /* Заполнение переменных для заголовка */
  rRow.ident   := rGoodsParties.rn;
  rRow.authid  := utilizer();
  rRow.s002    := 'Параметры:';
  rRow.s002     := strcombine(rRow.s002, rDicNomns.nomen_code||', '||rDicNomns.nomen_name||', '||rNomModif.modif_code||', '||rNomModif.modif_name, CR||'- Номенклатура: ');
  rRow.s002     := strcombine(rRow.s002, 'с '||nvl(to_char(dBEGIN, 'dd.mm.yyyy'), '...')||' по '||nvl(to_char(dEND, 'dd.mm.yyyy'), '...'), CR||'- Период: ');
  rRow.n003     := nvl(rRow.n003, 0);
  rRow.n004     := nvl(rRow.n004, 0);

  /* Заполнение */
  for c in (
            select usr_pkg_common.get_unit_name_short(d.unitcode)   as sunit_name
                  ,dt.doccode||', '||trim(d.doc_pref)||'-'||trim(d.doc_numb)||', '||to_char(d.doc_date, 'dd.mm.yy') as sdoc_details
                  ,to_char(d.operdate, 'dd.mm.yy')  as doperdate
                  ,nvl(ds_0.azs_number, fa.numb)    as sstore_0
                  ,al_0.agnabbr                     as smol_0
                  ,nvl(ds_1.azs_number, fa.numb)    as sstore_1
                  ,al_1.agnabbr                     as smol_1
                  ,sot_0.gsmways_mnemo              as ssot_0
                  ,sot_1.gsmways_mnemo              as ssot_1
                  ,icd.code                         as sparty
                  ,gp.sernumb                       as ssernumb
                  ,ra.code                          as sra_code
                  ,d.quant_1                        as nquant_1
                  ,d.quant_0                        as nquant_0
                  ,to_char(d.operdate, 'yyyymmdd')||d.soj_rn  as nsort
              from (
                    select a.in_document
                          ,max(a.soj_rn)        as soj_rn
                          ,a.unitcode
                          ,a.gs_prn
                          ,a.operdate
                          ,b.doc_type
                          ,b.doc_pref
                          ,b.doc_numb
                          ,b.doc_date
                          ,min(a.store_0)       as store_0
                          ,min(b.mol_0)         as mol_0
                          ,min(a.store_1)       as store_1
                          ,min(b.mol_1)         as mol_1
                          ,b.faceacc
                          ,sum(a.goodssupply_1) as goodssupply_1
                          ,sum(a.goodssupply_0) as goodssupply_0
                          ,min(a.oper_type_1)   as oper_type_1
                          ,min(a.oper_type_0)   as oper_type_0
                          ,min(a.stoper_1)      as stoper_1
                          ,min(a.stoper_0)      as stoper_0
                          ,a.article
                          ,sum(a.quant_1)       as quant_1
                          ,sum(a.quant_0)       as quant_0

                      from (
                            select dl.in_document
                                  ,soj.rn          as soj_rn
                                  ,soj.unitcode
                                  ,gs.prn          as gs_prn
                                  ,soj.operdate
                                  ,gs.store        as store_0
                                  ,null            as store_1
                                  ,soj.goodssupply as goodssupply_0
                                  ,null            as goodssupply_1
                                  ,soj.oper_type   as oper_type_0
                                  ,null            as oper_type_1
                                  ,soj.stoper      as stoper_0
                                  ,null            as stoper_1
                                  ,soj.article
                                  ,soj.quant       as quant_0
                                  ,null            as quant_1
                              from storeoperjourn soj
                              join goodssupply    gs  on gs.rn           = soj.goodssupply
                              join doclinks       dl  on dl.out_document = soj.rn 
                             where soj.oper_type  = 0
                            union all
                            select dl.in_document
                                  ,soj.rn          as soj_rn
                                  ,soj.unitcode
                                  ,gs.prn          as gs_prn
                                  ,soj.operdate
                                  ,null            as store_0
                                  ,gs.store        as store_1
                                  ,null            as goodssupply_0
                                  ,soj.goodssupply as goodssupply_1
                                  ,null            as oper_type_0
                                  ,soj.oper_type   as oper_type_1
                                  ,null            as stoper_0
                                  ,soj.stoper      as stoper_1
                                  ,soj.article
                                  ,null            as quant_0
                                  ,soj.quant       as quant_1
                              from storeoperjourn soj
                              join goodssupply    gs  on gs.rn           = soj.goodssupply
                              join doclinks       dl  on dl.out_document = soj.rn
                             where soj.oper_type  = 1
                           ) a
                          ,(
                            select rn, indoctype as doc_type, indocpref as doc_pref, indocnumb as doc_numb, indocdate as doc_date
                                  ,faceacc as faceacc
                                  ,null  as mol_0
                                  ,agent as mol_1
                              from inorders
                            union all
                            select rn, doc_type as doc_type, doc_pref as doc_pref, doc_numb as doc_numb, doc_date as doc_date
                                  ,out_faceacc  as faceacc
                                  ,null         as mol_0
                                  ,agent        as mol_1
                              from incomefromdeps
                            union all
                            select rn, doctype as doc_type, pref as doc_pref, numb as doc_numb, docdate as doc_date
                                  ,faceacc as faceacc
                                  ,mol     as mol_0
                                  ,in_mol  as mol_1
                              from transinvdept
                            union all
                            select rn, doctype as doc_type, pref as doc_pref, numb as doc_numb, docdate as doc_date
                                  ,faceacc  as faceacc
                                  ,mol      as mol_0
                                  ,null     as mol_1
                              from transinvcust
                            union all
                            select rn, doctype as doc_type, docpref as doc_pref, docnumb as doc_numb, docdate as doc_date
                                  ,faceacc as faceacc
                                  ,decode((select gsmways_type from azsgsmwaystypes t where t.rn = stoper), 0, agent) as mol_0
                                  ,decode((select gsmways_type from azsgsmwaystypes t where t.rn = stoper), 1, agent) as mol_1
                              from wroffacts
                            union all
                            select rn, doctype as doc_type, pref as doc_pref, numb as doc_numb, docdate as doc_date
                                  ,faceacc  as faceacc
                                  ,null     as mol_0
                                  ,mol      as mol_1
                              from rinvtosup
                            union all
                            select rn, doctype as doc_type, docprefix as doc_pref, docnumb as doc_numb, docdate as doc_date
                                  ,null as faceacc
                                  ,mol  as mol_0
                                  ,null as mol_1
                              from integract
                           ) b
                      where a.in_document = b.rn
                     group by a.in_document
                             ,a.unitcode
                             ,a.gs_prn
                             ,a.operdate
                             ,b.doc_type
                             ,b.doc_pref
                             ,b.doc_numb
                             ,b.doc_date
                             ,a.article
                             ,b.faceacc
                   ) d
              join goodsparties     gp    on gp.rn    = d.gs_prn
              join incomdoc         icd   on icd.rn   = gp.indoc
              join doctypes         dt    on dt.rn    = d.doc_type
         left join azsazslistmt     ds_0  on ds_0.rn  = d.store_0
         left join agnlist          al_0  on al_0.rn  = d.mol_0 
         left join azsazslistmt     ds_1  on ds_1.rn  = d.store_1
         left join agnlist          al_1  on al_1.rn  = d.mol_1 
         left join faceacc          fa    on fa.rn    = d.faceacc
         left join azsgsmwaystypes  sot_0 on sot_0.rn = d.stoper_0
         left join azsgsmwaystypes  sot_1 on sot_1.rn = d.stoper_1
         left join rlarticles      ra     on ra.rn    = d.article
                where ( gp.rn       = rGoodsParties.rn       and nMODE = 0
                       or
                        gp.nommodif = rGoodsParties.nommodif and nMODE = 1
                       or
                        gp.rn       in ( select rn from goodsparties where sernumb = rGoodsParties.sernumb ) and nMODE = 2 )
                  and ( d.operdate  >= dBEGIN or dBEGIN is null )
                  and ( d.operdate  <= dEND   or dEND   is null )
              order by to_char( d.operdate, 'yyyymmdd' )||d.soj_rn
          )
  loop
    /* добавлени значений с переменную */
    rRow.ident   := rRow.ident;
    rRow.authid  := rRow.authid;
    rRow.s001    := rRow.s001;
    rRow.s002    := rRow.s002;
    rRow.n003    := rRow.n003;
    rRow.n004    := rRow.n004;
    --
    rRow.s003    := c.sstore_0;
    rRow.s004    := null;
    rRow.s005    := strcombine(c.sparty, c.ssernumb, ' / ');
    rRow.s006    := null;
    rRow.s007    := c.sdoc_details;
    rRow.s009    := c.sstore_0;
    rRow.s010    := c.sstore_1;
    rRow.s011    := c.doperdate;
    rRow.s012    := null;
    rRow.s013    := c.ssot_0;
    rRow.s014    := c.sunit_name;
    rRow.s015    := c.sra_code;
    rRow.s016    := c.smol_0;
    rRow.s017    := c.smol_1;

    rRow.n001    := c.nquant_1;
    rRow.n002    := c.nquant_0;
    rRow.n010    := c.nsort;
    nRest        := nRest + nvl(rRow.n001, 0) - nvl(rRow.n002, 0);
    rRow.n005    := nRest;
    rRow.n004    := nRest;

    /* запись в таблицу */
    insert into usr_t_temp values rRow;
    /* признак, что заходили сюда */
    bLoop := true;
  end loop;

  /* Если в цикле ничего не записано и остатки нулевые. добавляем одну запись с тем, что было записано ранее, для печати заголовка и остатков */
  if not bLoop then
    if rRow.n003 = 0 and rRow.n004 = 0 then
      rRow.s100 := 'Данные не найдены'; /* Сообщение об ошибке */
    end if;
    insert into usr_t_temp values rRow;
  end if;

  /* Сохранение идента */
  delete from usr_t_ident t where t.authid = utilizer();
  insert into usr_t_ident t (t.authid, t.ident) values (utilizer(), rRow.ident);

exception
  when others then
    /* удаляем записи, записанные отчётом во временную таблицу */
    delete from usr_t_temp t where t.ident = rRow.ident;

    /* обнуляем переменную */
    rRow := null;

    /* записываем таблицу значения для сообщения об ошибке */
    rRow.ident   := rGoodsParties.rn;
    rRow.authid  := utilizer();
    rRow.s100     := substr(replace(sqlerrm, 'ORA' || sqlcode || ': '), 1, 2000); /* Сообщение об ошибке */
    insert into usr_t_temp values rRow;

    /* сохранение идента */
    delete from usr_t_ident t where t.authid = utilizer();
    insert into usr_t_ident t (t.authid, t.ident) values (utilizer(), rGoodsParties.rn);

end;
/
