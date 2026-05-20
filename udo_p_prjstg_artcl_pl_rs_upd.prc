create or replace procedure UDO_P_PRJSTG_ARTCL_PL_RS_UPD
/*
   Клиентское исправление в разделе "Планы и отчеты по статьям (остатки)"
  */
(
  NRN           number --рег. номер исправляемой записи
 ,SPRJSTG_ARTCL varchar2 --мнемокод статьи этапа заказа
 ,SSTATE        varchar2 --мнемокод состояния
 ,NRESTB        number --сумма остатка на начало
 ,NRESTE        number --сумма остатка на конец
 ,DACT_FROM     date --дата начала действия показателей
) as
  NPRJSTG_ARTCL number(17); --рег. номер статьи этапа заказа
  NSTATE        number(17); --рег. номер состояния
  PREC          UDO_T_PRJSTG_ARTCL_PLAN%rowtype; --родительская запись
  REC           UDO_T_PRJSTG_ARTCL_PLAN_RS%rowtype; --исправляемая запись
begin
  --считаем исправляемую запись
  begin
    select T.*
      into REC
      from UDO_T_PRJSTG_ARTCL_PLAN_RS T
     where T.RN = NRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NRN
                              ,SUNIT_TABLE => 'UDO_T_PRJSTG_ARTCL_PLAN_RS');
  end;
  --считаем родительскую запись
  begin
    select T.*
      into PREC
      from UDO_T_PRJSTG_ARTCL_PLAN T
     where T.RN = REC.PRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => REC.PRN
                              ,SUNIT_TABLE => 'UDO_T_PRJSTG_ARTCL_PLAN');
  end;
  --проверим её состояние
  if (PREC.STATE <> 0)
  then
    P_EXCEPTION(0
               ,'Исправление невозможно - документ утвержден!');
  end if;
  --проверим связи по входам и выходам
  PKG_DOCLINKS_SMART.HARD_CHECK(NCOMPANY  => PREC.COMPANY
                               ,SUNITCODE => 'PrjArtclsPlanRepsRs'
                               ,NDOCUMENT => REC.RN);
  --разыменуем ссылки
  UDO_P_PRJSTG_ARTCL_PL_RS_JOINS(NCOMPANY      => PREC.COMPANY
                                ,NSTAGE        => /*PREC.STAGE*/prec.calc_schema
                                ,SPRJSTG_ARTCL => SPRJSTG_ARTCL
                                ,SSTATE        => SSTATE
                                ,NPRJSTG_ARTCL => NPRJSTG_ARTCL
                                ,NSTATE        => NSTATE);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,SUNIT     => 'PrjArtclsPlanRepsRs'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PL_RS_UPD'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN_RS'
                  ,NDOCUMENT => REC.RN);
  --исправим данные в таблице
  UDO_P_PRJSTG_ARTCL_PL_RS_B_UPD(NRN           => REC.RN
                                ,NPRJSTG_ARTCL => NPRJSTG_ARTCL
                                ,NSTATE        => NSTATE
                                ,NRESTB        => NRESTB
                                ,NRESTE        => NRESTE
                                ,DACT_FROM     => DACT_FROM);
  --регистрация окончания действия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,SUNIT     => 'PrjArtclsPlanRepsRs'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PL_RS_UPD'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN_RS'
                  ,NDOCUMENT => REC.RN);
end;
/*
  create or replace public synonym UDO_P_PRJSTG_ARTCL_PL_RS_UPD for UDO_P_PRJSTG_ARTCL_PL_RS_UPD;
  grant execute on UDO_P_PRJSTG_ARTCL_PL_RS_UPD to public;
  */
/

