create or replace procedure UDO_P_PROJECTSTAGE_PBUDG_UPD
(
  NRN                in number,       -- Регистрационный номер
  NPRN               in number,       -- Регистрационный номер родителя
  NCOMPANY           in number,       -- Организация
  SFPDARTCL          in varchar2,     -- статья
  SPERIOD            in varchar2,     -- период
  NPLANSUM           in number,       -- Cумма план
  NFACTSUM           in number,       -- Cумма факт
  SNOTE              in varchar2      -- Примечание
)
is
  NCRN               PKG_STD.tREF;
  NPRN_              PKG_STD.tREF;
  NJUR_PERS          PKG_STD.tREF;
begin
  UDO_PKG_PROJECTSTAGE_PBUDG.P_PROJECTSTAGE_PBUDG_EXISTS(NRN       => NRN,
                                                         NCOMPANY  => NCOMPANY,
                                                         NPRN      => NPRN_,
                                                         NJUR_PERS => NJUR_PERS,
                                                         NCRN      => NCRN);

  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY,null,nCRN,nJUR_PERS,'ProjectsStagesPlanBudget','UDO_PROJECTSTAGE_PBUDG_UPDATE','UDO_PROJECTSTAGE_PBUDG',nRN );

  UDO_PKG_PROJECTSTAGE_PBUDG.PROJECTSTAGE_PBUDG_UPD(NRN       => NRN,
                                                    NPRN      => NPRN,
                                                    NCOMPANY  => NCOMPANY,
                                                    SFPDARTCL => SFPDARTCL,
                                                    SPERIOD   => SPERIOD,
                                                    NPLANSUM  => NPLANSUM,
                                                    NFACTSUM  => NFACTSUM,
                                                    SNOTE     => SNOTE);
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY,null,nCRN,nJUR_PERS,'ProjectsStagesPlanBudget','UDO_PROJECTSTAGE_PBUDG_UPDATE','UDO_PROJECTSTAGE_PBUDG',nRN );

end UDO_P_PROJECTSTAGE_PBUDG_UPD;
-- grant execute on UDO_P_PROJECTSTAGE_PBUDG_UPD to public;
/

