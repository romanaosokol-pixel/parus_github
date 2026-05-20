CREATE OR REPLACE PROCEDURE udo_p_prjstg_ecustcontr_crt_fi
(
  ncompany            IN NUMBER,
  nident              IN NUMBER,
  sjur_pers           OUT VARCHAR2,
  sjur_agent          OUT VARCHAR2,
  sagent              OUT VARCHAR2,
  ngovdeford_exec     OUT NUMBER,
  sgovcntrid          OUT VARCHAR2,
  sexecutive          OUT VARCHAR2,
  ssubdiv             OUT VARCHAR2,
  scurrency           OUT VARCHAR2,
  ncurcours           OUT NUMBER,
  sbcurrency          OUT VARCHAR2,
  ncurbase            OUT NUMBER,
  ssubject            OUT VARCHAR2,
  dstbegin_date       OUT DATE,
  dstend_date         OUT DATE,
  sfaceacc            OUT VARCHAR2,
  sfaexecutive        OUT VARCHAR2,
  sfasubdiv           OUT VARCHAR2,
  nstage_sum          OUT NUMBER,
  nstage_sumtax       OUT NUMBER,
  nstage_sum_nds      OUT NUMBER,
  sdescription        OUT VARCHAR2,
  scomments           OUT VARCHAR2
)
IS
/* Инициализация полей формы параметров формирования договора с внешним заказчиком из этапа проекта */
BEGIN
   udo_pkg_prjstg.p_extcust_contrcat_creat_finit(ncompany, nident, sjur_pers, sjur_agent, sagent, ngovdeford_exec, sgovcntrid, 
                                                 sexecutive, ssubdiv, scurrency, ncurcours, sbcurrency, ncurbase, ssubject,
                                                 dstbegin_date, dstend_date, sfaceacc, sfaexecutive, sfasubdiv, nstage_sum, nstage_sumtax, nstage_sum_nds, sdescription, scomments);
END udo_p_prjstg_ecustcontr_crt_fi;
/

