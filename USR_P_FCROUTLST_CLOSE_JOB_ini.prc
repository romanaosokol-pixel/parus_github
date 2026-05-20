create or replace procedure USR_P_FCROUTLST_CLOSE_JOB_ini
(
  out_sjob      out fcopertypes.code%type
 ,out_snote     out udo_fcroutlst_hist.notes%type
 ,out_dopendate out udo_fcroutlst_hist.begdate%type
) is

  
  ---grant execute on usr_p_fcroutlst_open_job_ini to public;
  /* Инициализация формы "Начало указанной работы по всем отмеченным маршрутным листам, по всем заводским номерам" */

begin

  out_snote     := null;
  out_dopendate := sysdate;
  --- Временно только одна операция --- "Комплектование"
  out_sjob := 'Комплектование';

end;
/
