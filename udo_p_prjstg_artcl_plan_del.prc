create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_DEL
/*
   Клиентское удаление в разделе "Планы и отчеты по статьям"
  */
(NRN number --рег. номер удалемой записи
 ) as
  REC UDO_T_PRJSTG_ARTCL_PLAN%rowtype; --удаляемая запись
begin
  --считаем удаляемую запись
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
  --проверим её состояние
  if (REC.STATE <> 0)
  then
    P_EXCEPTION(0
               ,'Удаление невозможно - документ утвержден!');
  end if;
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,SUNIT     => 'PrjArtclsPlanReps'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PLAN_DEL'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN'
                  ,NDOCUMENT => REC.RN);
  --удалим данные в таблице
  UDO_P_PRJSTG_ARTCL_PLAN_B_DEL(NRN => REC.RN);
  --регистрация окончания действия
  PKG_ENV.EPILOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,SUNIT     => 'PrjArtclsPlanReps'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PLAN_DEL'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN'
                  ,NDOCUMENT => REC.RN);
end UDO_P_PRJSTG_ARTCL_PLAN_DEL;
/*
  create or replace public synonym UDO_P_PRJSTG_ARTCL_PLAN_DEL for UDO_P_PRJSTG_ARTCL_PLAN_DEL;
  grant execute on UDO_P_PRJSTG_ARTCL_PLAN_DEL to public;
  */
/

