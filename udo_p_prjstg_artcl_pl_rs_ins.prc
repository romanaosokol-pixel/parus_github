create or replace procedure UDO_P_PRJSTG_ARTCL_PL_RS_INS
/*
   Клиентское добавление в раздел "Планы и отчеты по статьям (остатки)"
  */
(
  NPRN          number --рег. номер родительской записи
 ,SPRJSTG_ARTCL varchar2 --мнемокод статьи этапа заказа
 ,SSTATE        varchar2 --мнемокод состояния
 ,NRESTB        number --сумма остатка на начало
 ,NRESTE        number --сумма остатка на конец
 ,DACT_FROM     date --дата начала действия показателей
 ,NRN           out number --рег. номер добавленной записи
) as
  NPRJSTG_ARTCL number(17); --рег. номер статьи этапа заказа
  NSTATE        number(17); --рег. номер состояния
  PREC          UDO_T_PRJSTG_ARTCL_PLAN%rowtype; --родительская запись
begin
  --считаем родительскую запись
  begin
    select T.*
      into PREC
      from UDO_T_PRJSTG_ARTCL_PLAN T
     where T.RN = NPRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NPRN
                              ,SUNIT_TABLE => 'UDO_T_PRJSTG_ARTCL_PLAN');
  end;
  --проверим её состояние
  if (PREC.STATE <> 0)
  then
    P_EXCEPTION(0
               ,'Добавление невозможно - документ утвержден!');
  end if;
  --разыменуем ссылки
  UDO_P_PRJSTG_ARTCL_PL_RS_JOINS(NCOMPANY      => PREC.COMPANY
                                ,NSTAGE        => /*PREC.STAGE*/prec.calc_schema
                                ,SPRJSTG_ARTCL => SPRJSTG_ARTCL
                                ,SSTATE        => SSTATE
                                ,NPRJSTG_ARTCL => NPRJSTG_ARTCL
                                ,NSTATE        => NSTATE);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY => PREC.COMPANY
                  ,NVERSION => null
                  ,NCATALOG => PREC.CRN
                  ,SUNIT    => 'PrjArtclsPlanRepsRs'
                  ,SACTION  => 'UDO_P_PRJSTG_ARTCL_PL_RS_INS'
                  ,STABLE   => 'UDO_T_PRJSTG_ARTCL_PLAN_RS');
  --добавим данные в таблицу
  UDO_P_PRJSTG_ARTCL_PL_RS_B_INS(NPRN          => NPRN
                                ,NPRJSTG_ARTCL => NPRJSTG_ARTCL
                                ,NSTATE        => NSTATE
                                ,NRESTB        => NRESTB
                                ,NRESTE        => NRESTE
                                ,NRN           => NRN
                                ,DACT_FROM     => DACT_FROM);
  --регистрация окончания действия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,SUNIT     => 'PrjArtclsPlanRepsRs'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PL_RS_INS'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN_RS'
                  ,NDOCUMENT => NRN);
end;
/*
  create or replace public synonym UDO_P_PRJSTG_ARTCL_PL_RS_INS for UDO_P_PRJSTG_ARTCL_PL_RS_INS;
  grant execute on UDO_P_PRJSTG_ARTCL_PL_RS_INS to public;
  */
/

