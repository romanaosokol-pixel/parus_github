CREATE OR REPLACE PROCEDURE udo_p_prjstg_extperfcontr_init
  (
   ncompany     IN NUMBER,
   nprn         IN NUMBER,
   sjur_pers    OUT VARCHAR2,
   slabour_meas OUT VARCHAR2
   )
IS
/* »нициализаци€ полей действи€ UDO_PRJSTG_EXTPERFCONTRACT_SET в этапах проекта*/
BEGIN
  udo_pkg_prjstg.p_extperf_contract_finit(ncompany, nprn, sjur_pers, slabour_meas);
END udo_p_prjstg_extperfcontr_init;
/

