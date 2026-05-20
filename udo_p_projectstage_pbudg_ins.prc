create or replace procedure UDO_P_PROJECTSTAGE_PBUDG_INS
(
  NPRN               in number,       -- Регистрационный номер родителя
  NCOMPANY           in number,       -- Организация
  SFPDARTCL          in varchar2,       -- статья
  SPERIOD            in varchar2,       -- период
  NPLANSUM           in number,       -- Cумма план
  NFACTSUM           in number,       -- Cумма факт
  SNOTE              in varchar2,     -- Примечание
  NRN                out number       -- Регистрационный номер
)
is
  NCRN               PKG_STD.tREF;
  NJUR_PERS          PKG_STD.tREF;
begin
  P_PROJECTSTAGE_EXISTS(NRN       => NPRN,
                        NCOMPANY  => NCOMPANY,
                        NJUR_PERS => NJUR_PERS,
                        NCRN      => NCRN);
  /* фиксация начала выполнения действия */
  PKG_ENV.PROLOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'ProjectsStagesPlanBudget', 'UDO_PROJECTSTAGE_PBUDG_INSERT', 'UDO_PROJECTSTAGE_PBUDG' );

  UDO_PKG_PROJECTSTAGE_PBUDG.PROJECTSTAGE_PBUDG_INS(NPRN      => NPRN,
                                                    NCOMPANY  => NCOMPANY,
                                                    SFPDARTCL => SFPDARTCL,
                                                    SPERIOD   => SPERIOD,
                                                    NPLANSUM  => NPLANSUM,
                                                    NFACTSUM  => NFACTSUM,
                                                    SNOTE     => SNOTE,
                                                    NRN       => NRN);
  /* фиксация окончания выполнения действия */
  PKG_ENV.EPILOGUE( nCOMPANY, null, nCRN, nJUR_PERS, 'ProjectsStagesPlanBudget', 'UDO_PROJECTSTAGE_PBUDG_INSERT', 'UDO_PROJECTSTAGE_PBUDG', nRN );

end UDO_P_PROJECTSTAGE_PBUDG_INS;
-- grant execute on UDO_P_PROJECTSTAGE_PBUDG_INS to public;
/

