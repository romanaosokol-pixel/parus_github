create or replace procedure UDO_P_PRJSTG_ARTCL_DELETE
/*
  Клиентская процедура удаления записи из раздела "Статьи" этапа проекта
  */
(NRN number --рег. номер удаляемой записи
 ) as
  REC UDO_T_PRJSTG_ARTCL%rowtype; --удаляемая запись
  PREC PROJECTSTAGE%rowtype; --родительская запись
begin
  -- считаем удаляемую запись
  begin
    select T.*
      into REC
      from UDO_T_PRJSTG_ARTCL T
     where T.RN = NRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NRN
                              ,SUNIT_TABLE => 'UDO_T_PRJSTG_ARTCL');
  end;
  -- считаем родительскую запись
  begin
    select P.*
      into PREC
      from PROJECTSTAGE P
     where P.RN = REC.PRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => REC.PRN
                              ,SUNIT_TABLE => 'PROJECTSTAGE');
  end;
  -- снимаем инициализацию со статьи
  UDO_P_PRJSTG_ARTCL_INIT(NRN   => REC.RN
                         ,NMODE => 2);
  -- фиксируем начало действия
  PKG_ENV.PROLOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,NJUR_PERS => PREC.JUR_PERS
                  ,SUNIT     => 'ProjectsStagesArts'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_DELETE'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL'
                  ,NDOCUMENT => REC.RN);
  --удалим запись
  UDO_P_PRJSTG_ARTCL_BASE_DELETE(NRN => REC.RN);
  -- фиксация окончания выполнения действия 
  PKG_ENV.EPILOGUE(NCOMPANY  => PREC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => PREC.CRN
                  ,NJUR_PERS => PREC.JUR_PERS
                  ,SUNIT     => 'ProjectsStagesArts'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_DELETE'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL'
                  ,NDOCUMENT => REC.RN);
end UDO_P_PRJSTG_ARTCL_DELETE;
/

