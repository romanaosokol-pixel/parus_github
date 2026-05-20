create or replace procedure UDO_P_PRJSTG_PRSTRUCT_SET_ST
/*
   Клиентская процедура изменения сотояния структуры цены

   grant execute on UDO_P_PRJSTG_PRSTRUCT_SET_ST to public;
  */
(
  NCOMPANY    in number
 ,NRN         in number
 ,NSTATE      in number
 , -- Состояние
  DSTATE_DATE in date -- Дата смены состояния
) is
begin
  UDO_PKG_PRJSTG_PRSTRUCT.STRUCT_SET_STATE(NRN         => NRN
                                          ,NCOMPANY    => NCOMPANY
                                          ,NSTATE      => NSTATE
                                          ,DSTATE_DATE => DSTATE_DATE);
end;
/

