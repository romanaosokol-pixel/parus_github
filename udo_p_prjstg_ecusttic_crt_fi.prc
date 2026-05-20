CREATE OR REPLACE PROCEDURE udo_p_prjstg_ecusttic_crt_fi
(
  ncompany       IN NUMBER,
  nrn            IN NUMBER,
  ddocdate       OUT DATE
)
IS
/* Инициализация полей формы параметров формирования накладной потребителям по этапу проекта */
BEGIN
   udo_pkg_prjstg.p_extcust_tic_create_finit(ncompany, nrn, ddocdate);
END udo_p_prjstg_ecusttic_crt_fi;
/

