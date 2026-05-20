create or replace procedure UDO_P_PRJSTG_PRSTRUCT_CALC
/*
    лиентска€ процедура расчета значений статей структуры цены

   grant execute on UDO_P_PRJSTG_PRSTRUCT_CALC to public;
  */
(
  NRN          in number, -- –егистрационный номер
  NCOMPANY     in number, -- ќрганизаци€
  SART         in varchar2 default null, --расчитываема€ стать€ (null дл€ всех, можно чере разделитель SeqSymb)
  NSIGN_RECALC in number default 1 -- признак пересчета калькул€ции по процентам указанным в схеме (0- текущие проценты,1-проценты из схемы калькул€ции)
) is
begin
  UDO_PKG_PRJSTG_PRSTRUCT.STRUCT_CALC(NRN          => NRN
                                     ,NCOMPANY     => NCOMPANY
                                     ,SART         => SART
                                     ,NSIGN_RECALC => NSIGN_RECALC
                                      );
end;
/

