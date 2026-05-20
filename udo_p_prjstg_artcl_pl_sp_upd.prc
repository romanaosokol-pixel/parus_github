create or replace procedure UDO_P_PRJSTG_ARTCL_PL_SP_UPD
/*
   Клиентское исправление в разделе "Планы и отчеты по статьям (спецификация)"
  */
(
  NRN           number --рег. номер исправляемой записи
 ,SPRJSTG_ARTCL varchar2 --мнемокод статьи этапа заказа
 ,SPERIOD       varchar2 --мнемокод расчетного периода
 ,SSTATE        varchar2 --мнемокод состояния
 ,NSUMM         number --сумма
 ,DACT_FROM     date --дата начала действия показателей
 ,NCHECK_LINKS  number --проверять связи (0 - нет, 1 - да)
) as
  NPRJSTG_ARTCL number(17); --рег. номер статьи этапа заказа
  NPERIOD       number(17); --рег. номер расчетного периода
  NSTATE        number(17); --рег. номер состояния
  PREC          UDO_T_PRJSTG_ARTCL_PLAN%rowtype; --родительская запись
  REC           UDO_T_PRJSTG_ARTCL_PLAN_SP%rowtype; --исправляемая запись
begin
  --считаем исправляемую запись
  begin
    select T.*
      into REC
      from UDO_T_PRJSTG_ARTCL_PLAN_SP T
     where T.RN = NRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(0, NRN, 'UDO_T_PRJSTG_ARTCL_PLAN_SP');
  end;
  --считаем родительскую запись
  begin
    select T.*
      into PREC
      from UDO_T_PRJSTG_ARTCL_PLAN T
     where T.RN = REC.PRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(0, REC.PRN, 'UDO_T_PRJSTG_ARTCL_PLAN');
  end;
  --проверим её состояние
  if (PREC.STATE <> 0)
  then
    P_EXCEPTION(0, 'Исправление невозможно - документ утвержден!');
  end if;
  --проверим связи по входам и выходам
  if (NCHECK_LINKS = 1)
  then
    PKG_DOCLINKS_SMART.HARD_CHECK(PREC.COMPANY, 'PrjArtclsPlanRepsSp', REC.RN);
  end if;
  --разыменуем ссылки
  UDO_P_PRJSTG_ARTCL_PL_SP_JOINS(NCOMPANY      => PREC.COMPANY
                                ,NPRN          => PREC.RN
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
    select T.STARTDATE, T.ENDDATE, T.PERTYPE
      into DPB, DPE, NPTYPE
      from ENPERIOD T
     where T.RN = NPERIOD;
    
    select T.STARTDATE, T.ENDDATE
      into DPPB, DPPE
      from ENPERIOD T
     where T.RN = PREC.PERIOD;
    
    if (NPTYPE <> 0)
    then
      P_EXCEPTION(0, 'Расчетный период должен иметь тип "Месяц"!');
    end if;
    if (not ((DPB >= DPPB) and (DPE <= DPPE)))
    then
      P_EXCEPTION(0, 'Указанный расчетный период ("' || SPERIOD || '") не в ходит в период заголовка отчета!');
    end if;
  end;
  
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,SUNIT     => 'PrjArtclsPlanRepsSp'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PL_SP_UPD'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN_SP'
                  ,NDOCUMENT => REC.RN);
  --исправим данные в таблице
  UDO_P_PRJSTG_ARTCL_PL_SP_B_UPD(NRN           => REC.RN
                                ,NPRJSTG_ARTCL => NPRJSTG_ARTCL
                                ,NPERIOD       => NPERIOD
                                ,NSTATE        => NSTATE
                                ,NSUMM         => NSUMM
                                ,DACT_FROM     => DACT_FROM);
  --регистрация окончания действия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,SUNIT     => 'PrjArtclsPlanRepsSp'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PL_SP_UPD'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN_SP'
                  ,NDOCUMENT => REC.RN);
end;
/

