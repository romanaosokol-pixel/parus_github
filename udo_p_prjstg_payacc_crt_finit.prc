CREATE OR REPLACE PROCEDURE udo_p_prjstg_payacc_crt_finit
  (
    ncompany       IN NUMBER,
    nrn            IN NUMBER,
    ddocdate       OUT DATE,
    ndocsumm       OUT NUMBER,
    scurrency      OUT VARCHAR2
  )
IS
/* Инициализация полей формы параметров формирования счета на оплату по этапу проекта */
BEGIN
  udo_pkg_prjstg.p_extcust_payacc_create_finit(ncompany, nrn, ddocdate, ndocsumm, scurrency);
END udo_p_prjstg_payacc_crt_finit;
/

