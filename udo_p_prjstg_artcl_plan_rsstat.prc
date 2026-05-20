create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_RSSTAT
/*
   Снятие состояния "Утвержден" для раздела "Планы и отчеты по статьям"
  */
(
  NRN   number --рег. номер плана
 ,DDATE date --дата смены состояния
) as
  REC UDO_T_PRJSTG_ARTCL_PLAN%rowtype; --исправляемая запись
begin
  --считаем исправляемую запись
  begin
    select T.*
      into REC
      from UDO_T_PRJSTG_ARTCL_PLAN T
     where T.RN = NRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NRN
                              ,SUNIT_TABLE => 'UDO_T_PRJSTG_ARTCL_PLAN');
  end;
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,SUNIT     => 'PrjArtclsPlanReps'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PLAN_RSSTAT'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN'
                  ,NDOCUMENT => REC.RN);
  --изменим состояние
  update UDO_T_PRJSTG_ARTCL_PLAN T
     set T.STATE      = 0
        ,T.STATE_DATE = DDATE
   where T.RN = REC.RN;
  --регистрация окончания действия
  PKG_ENV.EPILOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,SUNIT     => 'PrjArtclsPlanReps'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PLAN_RSSTAT'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN'
                  ,NDOCUMENT => REC.RN);
end UDO_P_PRJSTG_ARTCL_PLAN_RSSTAT;
/*
   create public synonym UDO_P_PRJSTG_ARTCL_PLAN_RSSTAT for UDO_P_PRJSTG_ARTCL_PLAN_RSSTAT;
   grant execute on UDO_P_PRJSTG_ARTCL_PLAN_RSSTAT to public;
  */
/

