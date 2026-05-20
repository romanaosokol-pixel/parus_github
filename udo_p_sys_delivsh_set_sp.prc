create or replace procedure UDO_P_SYS_DELIVSH_SET_SP
(
  nIDENT   in number,
  nCOMPANY in number
) as
  /*
    25/09/2022 Марков МВ.
    Комплектовочные ведомости
    По старым КВ из 1С указывает ссылку на строку спецификации изделия.
  */
begin
  --
  if utilizer not in ('CITK_MARKOV') then
    p_exception(0, '');
  end if;
  --
  for rec in (select MR.NAME,
                     SP.QUANT_SPEC,
                     SP.PRODLSTSP,
                     SP.RN,
                     (select LS.RN
                        from FCPRODLST   L,
                             FCPRODLSTSP LS
                       where LS.PRN = L.RN
                         and L.MTR_RES = SH.MATRES
                         and LS.COMPLETE = SP.MATRES) sp_rn
                from FCDELIVSH     SH,
                     FCDELIVSHSP   SP,
                     FCMATRESOURCE MR
               where SH.RN in (select DOCUMENT from SELECTLIST where IDENT = nIDENT) --= nRN --22648305
                 and SP.PRN = SH.RN
                 and SP.MATRES = MR.RN
                 and SP.PRODLSTSP is null
                 and SH.COMPANY = nCOMPANY
               order by MR.NAME) loop
    update FCDELIVSHSP S set S.PRODLSTSP = rec.sp_rn where S.RN = rec.rn;
  end loop;
end;
/

