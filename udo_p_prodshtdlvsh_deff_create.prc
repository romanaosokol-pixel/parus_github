create or replace procedure UDO_P_PRODSHTDLVSH_DEFF_CREATE
(
  nIDENT   in number,
  nCOMPANY in number
) as
  /*
    05/04/2024 Ìàğêîâ ÌÂ.
    Ñîñòîÿíèå ïğîèçâîäñòâà
    Äåéñòâèå "Äåôèöèò ÊÂ"
  
    grant execute on UDO_P_PRODSHTDLVSH_DEFF_CREATE to public;
  */
  nID  number(17);
  nTMP number(17);
begin
  -- ñîáåğåì îòìå÷åííûå ÊÂ
  for rec in (select SH.DELIVSH
                from UDO_PRODSHTDLVSH_EX SH,
                     SELECTLIST          SL
               where SL.IDENT = nIDENT
                 and SL.DOCUMENT = SH.RN
                 and SH.DELIVSH is not null) loop
    -- ñîõğàíèì
    p_selectlist_insert_ex(nIDENT    => nIDENT,
                           nDOCUMENT => rec.delivsh,
                           sUNITCODE => 'CostDeliverySheets',
                           nCRN      => null,
                           nRN       => nTMP);
  end loop;
  -- î÷èñòêà
  UDO_PKG_FCDELIVSH_UTL.DELIVSH_DEFF_CLEAR;
  -- ôîğìèğîâàíèå
  UDO_PKG_FCDELIVSH_UTL.DELIVSH_DEFF_CREATE(nIDENT => nIDENT, nCOMPANY => nCOMPANY, nID => nID, nSIGN_DOC => 0);
end;
/
