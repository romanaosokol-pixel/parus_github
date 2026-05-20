create or replace procedure UDO_P_SYS_LST_1C_PARUS
(
  nCOMPANY in number,
  nIDENT   in number
) as
  /*
    11/12/2022 Марков МВ.
    Маршрутные листы. Пользовательская процедура.
    Перенос КВ с МЛ по 1С на МЛ Паруса.
    Необходимо отметить два МЛ - 1С и Парус.
    Будет осуществлен перенос линков с МЛ от 1С на МЛ Паруса.
  */
  nLST_NEW number(17);
  nLST_OLD number(17);
begin
  if utilizer not in ('CITK_MARKOV') then p_exception(0, 'Ошибка прав доступа.'); end if;
  --
  begin
    select lst.rn
      into nLST_NEW
      from fcroutlst  lst,
           selectlist sl
     where sl.ident = nIDENT
       and sl.document = lst.rn
       and exists (select null
              from doclinks l
             where l.out_document = lst.rn
               and l.out_unitcode = 'CostRouteLists'
               and l.in_unitcode = 'CostProductPlansSpecs');
  exception
    when no_data_found then
      p_exception(0, 'МЛ паруса не найден.');
  end;
  begin
    select lst.rn
      into nLST_OLD
      from fcroutlst  lst,
           selectlist sl
     where sl.ident = nIDENT
       and sl.document = lst.rn
       and not exists (select null
              from doclinks l
             where l.out_document = lst.rn
               and l.out_unitcode = 'CostRouteLists'
               and l.in_unitcode = 'CostProductPlansSpecs');
  exception
    when no_data_found then
      p_exception(0, 'МЛ 1C не найден.');
  end;
  -- перенос КВ от 1С на КВ паруса
  for rec in (select l.* from doclinks l where l.in_document = nLST_OLD) loop
    pkg_doclinks.remove(sIN_UNITCODE  => rec.in_unitcode,
                        nIN_DOCUMENT  => rec.in_document,
                        sOUT_UNITCODE => rec.out_unitcode,
                        nOUT_DOCUMENT => rec.out_document);
    pkg_doclinks.link(nFLAG_SMART   => 0,
                      nCOMPANY      => 90521,
                      sIN_UNITCODE  => rec.in_unitcode,
                      nIN_DOCUMENT  => nLST_NEW,
                      sOUT_UNITCODE => rec.out_unitcode,
                      nOUT_DOCUMENT => rec.out_document);
  end loop;

  -- скомплектовано из КВ 1С в КВ Парус
  --for rrc in(select from 
end;
/

