create or replace procedure usr_p_agnacc_bank_clc1
(
  nrn      in agnacc.rn%type
 ,ncompany in companies.rn%type
 ,agg_type in bankacctypes.code%type
) is
  /*grant execute on usr_p_agnacc_bank_clc1 to public;*/

  n_rn agnacc.bankacc_type%type;

begin

  begin
    select bt.rn
      into n_rn
      from bankacctypes bt
      join compverlist v
        on v.version = bt.version
       and v.company = ncompany
       and v.unitcode = 'BankAccountTypes'
     where bt.code = agg_type;
  exception
    when no_data_found then
      p_exception(0
                 ,'Тип счета с кодом "%s" не существует. Выберите корректный счет через справочник. '
                 ,agg_type);
    
  end;

end;
/
