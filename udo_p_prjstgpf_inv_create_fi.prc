CREATE OR REPLACE PROCEDURE udo_p_prjstgpf_inv_create_fi
(
  ncompany       IN NUMBER,
  nrn            IN NUMBER,
  ddocdate       OUT DATE
)
IS
/* Инициализация полей формы параметров формирования приходной накладной по исполнителю этапа проекта */
BEGIN
   udo_pkg_prjstg.p_extperf_ininv_create_finit(ncompany, nrn, ddocdate);
END udo_p_prjstgpf_inv_create_fi;
/

