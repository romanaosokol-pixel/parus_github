create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_INIT
/*
   Начальная инициализация статей этапа проекта в разделе "Планы и отчеты по статьям"
  */
(
  NRN   number --рег. номер иницируемой записи
 ,NMODE number --режим работы (1 - инициализация при добавлении, 2 - снятие инициализации)
) as
  REC UDO_T_PRJSTG_ARTCL_PLAN%rowtype;
begin
  --считаем запись
  begin
    select T.*
      into REC
      from UDO_T_PRJSTG_ARTCL_PLAN T
     where T.RN = NRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(0, NRN, 'UDO_T_PRJSTG_ARTCL_PLAN');
  end;
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,SUNIT     => 'PrjArtclsPlanReps'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PLAN_INIT'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN'
                  ,NDOCUMENT => REC.RN);
  --пройдем по всем статьям этапа и инициализируем их
  for ARTS in (/*select T.RN
                 from UDO_T_PRJSTG_ARTCL T
                where T.PRN = REC.STAGE*/
                
               SELECT spsa.rn
                 FROM udo_prjstg_prstruct sps
                      JOIN udo_prjstg_prclc spsa ON sps.rn = spsa.prn
                WHERE sps.prn = rec.stage AND
                      sps.sign_act = 1               
               )
  loop
    UDO_P_PRJSTG_ARTCL_PL_SP_INIT( REC.RN, ARTS.RN, NMODE);
  end loop;
  --регистрация окончания действия
  PKG_ENV.EPILOGUE(NCOMPANY  => REC.COMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => REC.CRN
                  ,SUNIT     => 'PrjArtclsPlanReps'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PLAN_INIT'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN'
                  ,NDOCUMENT => REC.RN);
end UDO_P_PRJSTG_ARTCL_PLAN_INIT;
/*
   create public synonym UDO_P_PRJSTG_ARTCL_PLAN_INIT for UDO_P_PRJSTG_ARTCL_PLAN_INIT;
   grant execute on UDO_P_PRJSTG_ARTCL_PLAN_INIT to public;
  */
/

