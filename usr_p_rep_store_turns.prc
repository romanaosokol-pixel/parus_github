create or replace procedure usr_p_rep_store_turns
(
 nIDENT             in number
,dBEGIN             in date
,dEND               in date
,sSTORE             in varchar2
,sSTORE_CAT         in varchar2
,sSTORE_KIND        in varchar2
,sNOMEN_CAT         in varchar2
,sNOMEN_GROUP       in varchar2
,nGROUP             in number /* Дополнительная группировка: 0 - нет, 1 - группа номенклатуры */
,NDETAILS_ARTTICLE  in number
,NDETAILS_PARTY     in number
)
/*
Отчет "Оборотная ведомость по товарным запасам склада". 17/04/2023 Степанов М.
create public synonym usr_p_rep_store_turns for usr_p_rep_store_turns;
grant execute on usr_p_rep_store_turns to public;
*/
as
  dBEGIN2         date := nvl(dBEGIN, to_date('01.01.2000', 'dd.mm.yyyy'));
  dEND2           date := nvl(dEND  , to_date('01.01.2099', 'dd.mm.yyyy'));
  rRow            usr_t_temp%rowtype;
  bLoop           boolean := false;
begin
  /* Очистка таблицы */
  delete from usr_t_temp t where t.authid = utilizer;

  /* Заполнение значений для заголовка */
  rRow.ident   := nIDENT;
  rRow.authid  := utilizer();
  rRow.s002     := 'Параметры:';
  rRow.s002     := strcombine(rRow.s002, sSTORE, CR||'- Склады: ');
  rRow.s002     := strcombine(rRow.s002, sSTORE_CAT, CR||'- Склады (каталоги): ');
  rRow.s002     := strcombine(rRow.s002, sSTORE_KIND, CR||'- Склады (виды): ');
  rRow.s002     := strcombine(rRow.s002, sNOMEN_CAT, CR||'- номенклатура (каталоги): ');
  rRow.s002     := strcombine(rRow.s002, sNOMEN_GROUP, CR||'- Номенклатура (группы): ');
  rRow.s002     := strcombine(rRow.s002, case nGROUP when 1 then 'Да' else 'Нет' end, CR||'- Группировка по номенклатуре: ');
  rRow.s002     := strcombine(rRow.s002, 'с '||nvl(to_char(dBEGIN, 'dd.mm.yyyy'), '...')||' по '||nvl(to_char(dEND, 'dd.mm.yyyy'), '...'), CR||'- Период: ');
  -- Заполнение
  for c in (
            select ds.azs_number    as sazs
                  ,ds.azs_name      as azs_name
                  ,ac_ds.name       as sazs_cat
                  ,dsk.code         as sazs_kind
                  ,dnm.nomen_code   as snomen_code
                  ,dnm.nomen_name   as snomen_name
                  ,nm.modif_code    as smodif_code
                  ,nm.modif_name    as smodif_name
                  ,ac_nm.name       as smodif_cat
                  ,dng.group_code   as smodif_group
                  ,(select str_value 
                      from docs_props_vals 
                     where docs_prop_rn = 19579777 
                       and  unit_rn = dnm.rn)               as sumts_group
                  ,decode(NDETAILS_ARTTICLE, 1, a.ra_code ) as sra_code
                  ,decode(NDETAILS_PARTY   , 1, a.icd_code) as sicd_code
                  ,decode(NDETAILS_PARTY   , 1, a.sernumb ) as ssernumb
                  ,a.quant_beg      as nquant_beg
                  ,a.quant_in       as nquant_in
                  ,a.quant_out      as nquant_out
                  ,a.quant_end      as nquant_end
              from azsazslistmt  ds
                  ,acatalog      ac_ds
                  ,stkind        dsk
                  ,nommodif      nm
                  ,dicnomns      dnm
                  ,acatalog      ac_nm
                  ,dicgnomn      dng
                  ,(select gp.nommodif, gs.store
                          ,decode(NDETAILS_ARTTICLE, 1, gs.ra_code) as ra_code
                          ,decode(NDETAILS_PARTY   , 1, icd.code  ) as icd_code
                          ,decode(NDETAILS_PARTY   , 1, gp.sernumb) as sernumb
                          ,nvl(sum(gs.quant_beg), 0)                as quant_beg
                          ,nvl(sum(gs.quant_in) , 0)                as quant_in
                          ,nvl(sum(gs.quant_out), 0)                as quant_out
                          ,nvl(sum(gs.quant_end), 0)                as quant_end
                      from (select t.store, t.prn, ra.code as ra_code
                                  ,(select nvl(sum(restfact), 0)
                                      from goodssupplyhist
                                     where  prn = t.rn
                                       and date_from <= dBEGIN2 -1 /* предыдущий день от даты начала */
                                       and (date_to  >= dBEGIN2 -1 or date_to is null)
                                       and  restfact != 0) quant_beg
                                  ,(select nvl(sum(quant), 0)
                                      from storeoperjourn
                                     where operdate   >= dBEGIN2
                                       and operdate   <= dEND2
                                       and oper_type   = 1
                                       and goodssupply = t.rn) quant_in
                                  ,(select nvl(sum(quant), 0)
                                      from storeoperjourn
                                     where operdate   >= dBEGIN2
                                       and operdate   <= dEND2
                                       and oper_type   = 0
                                       and goodssupply = t.rn) quant_out
                                  ,(select nvl(sum(restfact), 0)
                                      from goodssupplyhist
                                     where  prn        = t.rn
                                       and  date_from <= dEND2
                                       and (date_to   >= dEND2 or date_to is null)
                                       and  restfact  != 0) quant_end
                              from goodssupply      t
                                  ,articlessupply   ars
                                  ,rlarticles       ra
                             where t.rn        = ars.prn(+)
                               and ars.article = ra.rn(+) ) gs
                          ,goodsparties gp
                          ,incomdoc     icd
                     where gp.rn    = gs.prn
                       and gp.indoc = icd.rn
                       and gs.quant_beg + gs.quant_in + gs.quant_out + gs.quant_end != 0
                    group by gp.nommodif, gs.store
                            ,decode(NDETAILS_ARTTICLE, 1, gs.ra_code)
                            ,decode(NDETAILS_PARTY, 1, icd.code)
                            ,decode(NDETAILS_PARTY, 1, gp.sernumb) ) a
            where (strin(ds.azs_number, sSTORE, ';') = 1 or sSTORE is null)
              and  ds.crn = ac_ds.rn
              and (strin(ac_ds.name, sSTORE_CAT, ';') = 1 or sSTORE_CAT is null)
              and  ds.stkind = dsk.rn(+)
              and (strin(dsk.code, sSTORE_KIND, ';') = 1 or sSTORE_KIND is null)
              --
              and  nm.prn = dnm.rn
              and  nm.crn = ac_nm.rn
              and (strin(ac_nm.name, sNOMEN_CAT, ';') = 1 or sNOMEN_CAT is null)
              and  dnm.group_code = dng.rn
              and (strin(dng.group_code, sNOMEN_GROUP, ';') = 1 or sNOMEN_GROUP is null)
              and  nm.rn = a.nommodif
              and  ds.rn = a.store
          )
  loop
    /* добавление значений с переменную */
    rRow.ident   := rRow.ident;
    rRow.authid  := rRow.authid;
    rRow.s002    := rRow.s002;
    rRow.s003    := c.sazs;
    rRow.s004    := c.azs_name;
    rRow.s005    := c.sazs_cat;
    rRow.s006    := c.sazs_kind;
    rRow.s007    := c.snomen_code;
    rRow.s008    := c.snomen_name;
    rRow.s009    := c.smodif_cat;
    rRow.s010    := c.smodif_group;
    rRow.s011    := c.smodif_name;
    rRow.s012    := c.sumts_group;
    rRow.s013    := c.sra_code;
    rRow.s014    := strcombine(c.sicd_code, c.ssernumb, ' / ');

    rRow.n001    := c.nquant_beg;
    rRow.n002    := c.nquant_in;
    rRow.n003    := c.nquant_out;
    rRow.n004    := c.nquant_end;

    /* запись в таблицу */
    insert into usr_t_temp values rRow;
    /* признак, что заходили сюда */
    bLoop := true;
  end loop;

  /* Если в цикл не заходили. добавляем одну запись с сообщением */
  if not bLoop then
    rRow.s100 := 'Данные не найдены'; /* Сообщение об ошибке */
    insert into usr_t_temp values rRow;
  end if;

  -- Сохранение идента
  delete from usr_t_ident t where t.authid = utilizer();
  insert into usr_t_ident t (t.authid, t.ident) values (utilizer(), nIDENT);

exception
  when others then
    /* удаляем записи, записанные отчётом во временную таблицу */
    delete from usr_t_temp t where t.ident = rRow.ident;

    /* обнуляем переменную */
    rRow := null;

    /* записываем таблицу значения для сообщения об ошибке */
    rRow.ident   := nIDENT;
    rRow.authid  := utilizer();
    rRow.s100     := substr(replace(sqlerrm, 'ORA'||sqlcode||': '), 1, 2000); /* Сообщение об ошибке */
    insert into usr_t_temp values rRow;

    /* сохранение идента */
    delete from usr_t_ident t where t.authid = utilizer();
    insert into usr_t_ident t (t.authid, t.ident) values (utilizer(), nIDENT);

end usr_p_rep_store_turns;
/
