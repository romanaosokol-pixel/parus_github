create or replace procedure UDO_P_PRJSTG_ARTCL_PL_SP_INS
/*
   Клиентское добавление в раздел "Планы и отчеты по статьям (спецификация)"
  */
(
  NPRN          number --рег. номер родительской записи
 ,SPRJSTG_ARTCL varchar2 --мнемокод статьи этапа заказа
 ,SPERIOD       varchar2 --мнемокод расчетного периода
 ,SSTATE        varchar2 --мнемокод состояния
 ,NSUMM         number --сумма
 ,DACT_FROM     date --дата начала действия показателей
 ,NRN           out number --рег. номер добавленной записи
) as
  NPRJSTG_ARTCL number(17); --рег. номер статьи этапа заказа
  NPERIOD       number(17); --рег. номер расчетного периода
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
  UDO_P_PRJSTG_ARTCL_PL_SP_JOINS(NCOMPANY      => PREC.COMPANY
                                ,NPRN          => PREC.STAGE
                                ,SPRJSTG_ARTCL => SPRJSTG_ARTCL
                                ,SPERIOD       => SPERIOD
                                ,SSTATE        => SSTATE
                                ,NPRJSTG_ARTCL => NPRJSTG_ARTCL
                                ,NPERIOD       => NPERIOD
                                ,NSTATE        => NSTATE);
  --проверим соответствие периода планирования статьи, периоду планирования заголовка
  declare
    DPB    date; --дата начала периода планирования
    DPE    date; --дата окончания периода планирования
    DPPB   date; --дата начала периода планирования родителя
    DPPE   date; --дата окончания периода планирования родителя
    NPTYPE number; --тип расчетного периода
  begin
    select T.STARTDATE
          ,T.ENDDATE
          ,T.PERTYPE
      into DPB
          ,DPE
          ,NPTYPE
      from ENPERIOD T
     where T.RN = NPERIOD;
    select T.STARTDATE
          ,T.ENDDATE
      into DPPB
          ,DPPE
      from ENPERIOD T
     where T.RN = PREC.PERIOD;
    if (NPTYPE <> 0)
    then
      P_EXCEPTION(0
                 ,'Расчетный период должен иметь тип "Месяц"!');
    end if;
    if (not ((DPB >= DPPB) and (DPE <= DPPE)))
    then
      P_EXCEPTION(0
                 ,'Указанный расчетный период не в ходит в период заголовка отчета!');
    end if;
  end;
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY => PREC.COMPANY
                  ,NVERSION => null
                  ,NCATALOG => PREC.CRN
                  ,SUNIT    => 'PrjArtclsPlanRepsSp'
                  ,SACTION  => 'UDO_P_PRJSTG_ARTCL_PL_SP_INS'
                  ,STABLE   => 'UDO_T_PRJSTG_ARTCL_PLAN_SP');
  --добавим данные в таблицу
  UDO_P_PRJSTG_ARTCL_PL_SP_B_INS(NPRN          => NPRN
                                ,NPRJSTG_ARTCL => NPRJSTG_ARTCL
                                ,NPERIOD       => NPERIOD
                                ,NSTATE        => NSTATE
                                ,NSUMM         => NSUMM
                                ,DACT_FROM     => DACT_FROM
                                ,NRN           => NRN);
  --регистрация окончания действия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,SUNIT     => 'PrjArtclsPlanRepsSp'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PL_SP_INS'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN_SP'
                  ,NDOCUMENT => NRN);
end UDO_P_PRJSTG_ARTCL_PL_SP_INS;
/*
  create or replace public synonym UDO_P_PRJSTG_ARTCL_PL_SP_INS for UDO_P_PRJSTG_ARTCL_PL_SP_INS;
  grant execute on UDO_P_PRJSTG_ARTCL_PL_SP_INS to public;
  */
/

