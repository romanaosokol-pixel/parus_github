create or replace procedure UDO_P_PROJECTSTAGE_PBUDG_DEL
(
  NRN                in number,       -- Регистрационный номер
  NCOMPANY           in number        -- Организация
)
is
  NCRN               PKG_STD.tREF;
  NPRN               PKG_STD.tREF;
  NJUR_PERS          PKG_STD.tREF;
begin
  UDO_PKG_PROJECTSTAGE_PBUDG.P_PROJECTSTAGE_PBUDG_EXISTS(NRN       => NRN,
                                                         NCOMPANY  => NCOMPANY,
                                                         NPRN      => NPRN,
                                                         NJUR_PERS => NJUR_PERS,
                                                         NCRN      => NCRN);
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY,null,nCRN,nJUR_PERS,'ProjectsStagesPlanBudget','UDO_PROJECTSTAGE_PBUDG_DELETE','UDO_PROJECTSTAGE_PBUDG',nRN );

  UDO_PKG_PROJECTSTAGE_PBUDG.PROJECTSTAGE_PBUDG_DEL(NRN      => NRN,
                                                    NCOMPANY => NCOMPANY);

  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY,null,nCRN,nJUR_PERS,'ProjectsStagesPlanBudget','UDO_PROJECTSTAGE_PBUDG_DELETE','UDO_PROJECTSTAGE_PBUDG',nRN );

end UDO_P_PROJECTSTAGE_PBUDG_DEL;
-- grant execute on UDO_P_PROJECTSTAGE_PBUDG_DEL to public;
/

