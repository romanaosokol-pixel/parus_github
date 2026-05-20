CREATE OR REPLACE PROCEDURE udo_p_prjstg_extperfcontr_rclc
  (
   ncompany     IN NUMBER,
   nprn         IN NUMBER,
   sattrib      IN VARCHAR2,
   nperf_labour IN OUT NUMBER,
   npercent     IN OUT NUMBER,
   sfaceacc     IN OUT VARCHAR2,
   sagent       IN OUT VARCHAR2,
   sgraphpoint  IN OUT VARCHAR2,
   nfaceacc     OUT NUMBER,
   scontract    OUT VARCHAR2
   )
IS
/* Пересчет полей действия UDO_PRJSTG_EXTPERFCONTRACT_SET в этапах проекта*/
BEGIN
  udo_pkg_prjstg.p_extperf_contract_frclc(ncompany, nprn, sattrib, nperf_labour, npercent, sfaceacc, sagent, sgraphpoint, nfaceacc, scontract );
END udo_p_prjstg_extperfcontr_rclc;
/

