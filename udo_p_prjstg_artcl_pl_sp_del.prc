create or replace procedure UDO_P_PRJSTG_ARTCL_PL_SP_DEL
/*
   Клиентское удаление в разделе "Планы и отчеты по статьям (спецификация)"
  */
(NRN number --рег. номер удаляемой записи
 ) as
  PREC UDO_T_PRJSTG_ARTCL_PLAN%rowtype; --родительская запись
  REC  UDO_T_PRJSTG_ARTCL_PLAN_SP%rowtype; --удаляемая запись
begin
  --считаем удаляемую запись
  begin
    select T.*
      into REC
      from UDO_T_PRJSTG_ARTCL_PLAN_SP T
     where T.RN = NRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NRN
                              ,SUNIT_TABLE => 'UDO_T_PRJSTG_ARTCL_PLAN_SP');
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
               ,'Удаление невозможно - документ утвержден!');
  end if;
  --проверим связи по входам и выходам
  PKG_DOCLINKS_SMART.HARD_CHECK(NCOMPANY  => PREC.COMPANY
                               ,SUNITCODE => 'PrjArtclsPlanRepsSp'
                               ,NDOCUMENT => REC.RN);
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,SUNIT     => 'PrjArtclsPlanRepsSp'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PL_SP_DEL'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN_SP'
                  ,NDOCUMENT => REC.RN);
  --удалим данные в таблице
  UDO_P_PRJSTG_ARTCL_PL_SP_B_DEL(NRN => REC.RN);
  --регистрация окончания действия
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,SUNIT     => 'PrjArtclsPlanRepsSp'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PL_SP_DEL'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN_SP'
                  ,NDOCUMENT => REC.RN);
end UDO_P_PRJSTG_ARTCL_PL_SP_DEL;
/*
  create or replace public synonym UDO_P_PRJSTG_ARTCL_PL_SP_DEL for UDO_P_PRJSTG_ARTCL_PL_SP_DEL;
  grant execute on UDO_P_PRJSTG_ARTCL_PL_SP_DEL to public;
  */
/

