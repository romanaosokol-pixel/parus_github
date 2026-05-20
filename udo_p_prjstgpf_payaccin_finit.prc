CREATE OR REPLACE PROCEDURE udo_p_prjstgpf_payaccin_finit
  (
    ncompany       IN NUMBER,
    nrn            IN NUMBER,
    ddocdate       OUT DATE,
    ndocsumm       OUT NUMBER,
    scurrency      OUT VARCHAR2
  )
IS
/* Инициализация полей формы параметров формирования входящего счета на оплату по исполнителю этапа проекта */
BEGIN
  udo_pkg_prjstg.p_extperf_pai_create_finit(ncompany, nrn, ddocdate, ndocsumm, scurrency);
END udo_p_prjstgpf_payaccin_finit;
/

