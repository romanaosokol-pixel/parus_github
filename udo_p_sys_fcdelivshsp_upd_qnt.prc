create or replace procedure UDO_P_SYS_FCDELIVSHSP_UPD_QNT
(
  nCOMPANY in number,
  nIDENT   in number
) as
  /*
    27/05/2023 Марков МВ,
    КВ.
    Инициализация количества ПЛАН
  */
begin
  if utilizer not in('CITK_MARKOV') then p_exception(0, 'Errors. Fataling!!!'); end if;
  update fcdelivshsp sp
     set sp.quant_plan = sp.quant_spec * (select sh.quant
                                            from fcdelivsh sh
                                           where sh.rn = sp.prn
                                             and sh.company = nCOMPANY)
   where sp.rn in (select DOCUMENT from SELECTLIST where IDENT = nIDENT);
end;
/

