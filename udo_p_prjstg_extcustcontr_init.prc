CREATE OR REPLACE PROCEDURE udo_p_prjstg_extcustcontr_init
  (
   ncompany     IN NUMBER,
   nident       IN NUMBER,
   sjur_pers    OUT VARCHAR2,
   sstage_agent OUT VARCHAR2,
   sfaceacc     IN OUT VARCHAR2,
   sdocument    OUT VARCHAR2
   )
IS
/* »нициализаци€ полей действи€ UDO_EXTCUSTCONTR_SET в этапах проекта*/
BEGIN
  udo_pkg_prjstg.p_extcust_contract_finit(ncompany, nident, sjur_pers, sstage_agent, sfaceacc, sdocument);
END udo_p_prjstg_extcustcontr_init;
/

