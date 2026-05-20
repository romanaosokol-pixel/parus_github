create or replace procedure udo_p_transinvcustsp_setlink
/*
Процедура ручной привязки расходных накладных потребителю с графиком отпуска  
Столярский Е.З. 04/12/2023 
17/02/2025 Степанов М. Переделка на калькуляции
*/
(
  /*
  nIDENT    in number,
  nCOMPANY  in number,
  snumb     in varchar,
  nparam in number
,*/
 nRN      in number
,nFACEACC in number
,sFAOP    in varchar2 
,nFAOOP   in number
) 
is
  nfc_rn   pkg_std.tref;
  nnuw_rn  pkg_std.tref;
  nsum     pkg_std.tsumm;
  nface_rn pkg_std.tref;
  SFACEACC PKG_STD.tSTRING := null;
 
  nFAOOP2         pkg_std.tref := nFAOOP; 
  rV_Row          v_transinvcustspecs%rowtype;
  rV_FAOOP        v_fcacoperplans%rowtype;
  
  nNumber         pkg_std.tnumber; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open( sname => 'UDO_P_TRANSINVCUSTSP_SETLINK' );
  
  /* Если пустая тектовая переменная графика, то обнуляем RN */
  if sFAOP is null then
    nFAOOP2 := null;
  end if;

  /* СТАРАЯ СХЕМА */

  /*if snumb is null
  then
    return;
  end if;*/
  
  /*if SFACEACC is not null then
    FIND_FACEACC_BY_NUMB
        (
          nCOMPANY   => nCOMPANY,
          sNUMBER    => SFACEACC,
          nRN        => nface_rn
        );
  end if;*/

  /*for sp in (select tr.faceacc
                   ,trs.nommodif
                   ,trs.rn
                   ,trs.prn
               from transinvcustspecs trs
                   ,transinvcust      tr
              where tr.rn = trs.prn
                and trs.rn in (select sl.document from selectlist sl where sl.ident = nident))
  loop
    if nface_rn is null then
      nface_rn := sp.faceacc;
    end if;*/

    /* проверим/подберем строку графика отпуска*/
    /*if snumb <> 'null'
    then
      begin
        select fp.rn
          into nfc_rn
          from fcacoperplans fp
         where fp.prn = nface_rn
           and (fp.nommodif = sp.nommodif or nparam = 1)
           and trim(fp.numb) = trim(snumb);
      exception
        when no_data_found then
          p_exception(0
                     ,'Модификации расходной не равна модификации графика для строки с номером %s.'
                     ,snumb);
      end;
      nnuw_rn := null;*/

  if nFAOOP2 is not null then
    /* Проверим наличие расширения */
    begin
      select ex.rn into nnuw_rn from udo_t_transinvcustspecs_ex ex where ex.prn = /*sp.rn*/ nRN;
    exception
      when others then
        nnuw_rn := null;
    end;
    /* пропишем в связи */
    if nnuw_rn is null
    then
      nnuw_rn := gen_id;
      insert into udo_t_transinvcustspecs_ex
        (rn
        ,prn
        ,fcacoperplans)
      values
        (nnuw_rn
        ,/*sp.rn*/nRN
        ,/*nfc_rn*/nFAOOP2);
    else
      update udo_t_transinvcustspecs_ex ee set ee.fcacoperplans = nfc_rn where ee.rn = nnuw_rn;
    end if;
  else
    delete from udo_t_transinvcustspecs_ex ex where ex.prn = /*sp.rn*/nRN;
  end if;
  
  /*end loop;*/


  /* Пересчитаем все графики ЛС */
  /*for ss in (select * from fcacoperplans ff where ff.prn = nface_rn)
  loop
    \* пересчитаем кол-во исполнения в графике *\
    select sum(trs.quant)
      into nsum
      from udo_t_transinvcustspecs_ex ee
          ,transinvcustspecs          trs
     where ee.fcacoperplans = ss.rn
       and trs.rn = ee.prn;
  
    update fcacoperplans spp
       set spp.fact_quant = nvl(nsum,0)
          ,spp.plan_quant = nvl(nsum,0)
     where spp.rn = ss.rn;
  
  end loop;
  \* Проставим цены из графика отпуска *\
  for cur in (select distinct trs.prn
                from selectlist sl
                join transinvcustspecs trs
                  on trs.rn = sl.document
               where sl.ident = nident
                 and sl.unitcode = 'GoodsTransInvoicesToConsumersSpecs'
                 and sl.authid = utilizer)
  
  loop
    null;
    udo_p_trancost_set_prise(nrn => cur.prn);
  end loop;*/

  /* НОВАЯ СХЕМА */
  /* Считывание текущей записи */
  select * into rV_Row   from v_transinvcustspecs where nrn = udo_p_transinvcustsp_setlink.nrn;

  /* Если график задан */
  if nFAOOP2 is not null then
    /* Считывание графика */
    select * into rV_FAOOP from v_fcacoperplans where nrn = nFAOOP2;
    /* Добавление калькуляции */
    usr_pkg_transinvcust.tics_ticsc_insert( rv_row => rV_Row, rv_faoop => rV_FAOOP, nticsc => nNumber );
  else
    /* Удаление всех калькуляций */
    for c in ( select rn, company from trinvcustclc where prn = rV_Row.nrn )
    loop
      p_trinvcustclc_delete( nrn => c.rn, ncompany => c.company );
    end loop;
  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;
end;
/
