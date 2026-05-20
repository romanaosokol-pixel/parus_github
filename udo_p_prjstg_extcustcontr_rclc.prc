CREATE OR REPLACE PROCEDURE udo_p_prjstg_extcustcontr_rclc
  (
   ncompany     IN NUMBER,
   sfaceacc     IN OUT VARCHAR2,
   sdocument    OUT VARCHAR2
   )
IS
/* »нициализаци€ полей действи€ UDO_EXTCUSTCONTR_SET в этапах проекта*/
BEGIN
  udo_pkg_prjstg.p_extcust_contract_frclc(ncompany, sfaceacc, sdocument);
END udo_p_prjstg_extcustcontr_rclc;
/

