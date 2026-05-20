create or replace procedure USR_P_GET_REST_QUANT
/*
Получение остатков по параметрам: приходная партия, номенклатура, модификация, склад, дата
*/
(
 nGOODSPARTIES  in number default null
,nDICNOMNS      in number default null
,nNOMMODIF      in number default null
,nSTORE         in number default null
,dDATE          in date   default null
,nRESTFACT      out number
,nRESERV        out number
,nSALE          out number  /* к продаже */
)
is
  sQuery   pkg_std.tstring; 
begin
  /* Формирование запроса */
  sQuery :=         'select nvl(sum(h.restfact), 0) as n1, nvl(sum(h.reserv), 0) as n2, nvl(sum(h.restfact), 0) - nvl(sum(h.reserv), 0) as n3 ';
  sQuery := sQuery||'  from goodsparties gp, goodssupply sup, goodssupplyhist h, dicnomns dnm, nommodif nm ';
  sQuery := sQuery||' where  sup.rn       = h.prn
                        and  sup.prn      = gp.rn 
                        and  gp.nommodif  = nm.rn 
                        and  nm.prn       = dnm.rn';
  if dDATE is not null then
    sQuery := sQuery||' and  h.date_from <= '''||dDATE||'''
                        and (h.date_to   >= '''||dDATE||''' or h.date_to is null)';
  else
    sQuery := sQuery||' and  h.date_to    is null';
  end if;
  if nSTORE is not null then
    sQuery := sQuery||' and sup.store     = '||nSTORE;
  end if;
  if nNOMMODIF is not null then
    sQuery := sQuery||' and gp.nommodif   = '||nNOMMODIF;
  end if;
  if nDICNOMNS is not null then
    sQuery := sQuery||' and dnm.rn        = '||nDICNOMNS;
  end if;
  if nGOODSPARTIES is not null then
    sQuery := sQuery||' and gp.rn         = '||nGOODSPARTIES;
  end if;

  /* Выполнение */
  begin
    execute immediate sQuery
       into nRESTFACT, nRESERV, nSALE;
  exception
    when others then
      p_exception(0, 'Неопределённая ситуация при вычислении остатка с параметрами: %s %s %s %s.'
                 ,get_dicnomns_code_id(nflag_smart => 1, nrn => nDICNOMNS)
                 ,cr||usr_pkg_dicnomns.nommodif_get_code_by_rn(nflagsmart => 1, nrn => nNOMMODIF)
                 ,cr||f_dicstore_get_numb(nstore => nSTORE)
                 ,cr||decode_date(dDATE));
  end;

end USR_P_GET_REST_QUANT;
/
