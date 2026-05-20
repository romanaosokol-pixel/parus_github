create or replace procedure UDO_P_PRJSTAGE_SHTART_INSERT
(
  nPRN     in number,
  sARTICLE in varchar2,
  nSIGN_DEL in number -- с заменой (очисткой)
) as
  /*
    29/03/2023 Марков МВ.
    Ведомость производства по проекту
    Указать заводской номер по изделию
  */
  nARTICLE number(17);
  nRN      number(17);
  
begin
  
  --
  if nvl(nSIGN_DEL, 0) > 0 then
    delete from UDO_PROJECTSTAGE_SHT_ART where PRN = nPRN;
  end if;
  --
  begin
    select RA.RN
      into nARTICLE
      from RLARTICLES           RA,
           UDO_PROJECTSTAGE_SHT SH,
           FCMATRESOURCE        MR,
           DICNOMNS             NM
     where SH.RN = nPRN
       and SH.MATRES =  MR.RN
       and MR.NOMENCLATURE = NM.RN
       and RA.NOMMODIF = MR.NOMEN_MODIF
       and replace(RA.CODE, NM.NOMEN_CODE||'_') = sARTICLE;
  exception
    when no_data_found then
      p_exception(0, 'Заводской номер %s не найден.', sARTICLE);
  end;
  
  nRN := gen_id;
  insert into UDO_PROJECTSTAGE_SHT_ART
    (RN,
     PRN,
     ARTICLE)
  values
    (nRN,
     nPRN,
     nARTICLE);
end;
/

