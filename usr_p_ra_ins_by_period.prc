create or replace procedure USR_P_RA_INS_BY_PERIOD
/*
Изделия. Добавление по периоду номеров
02/09/2024 Степанов М.
*/
(
 nCOMPANY     in number
,sNOMEN       in varchar2
,sNOMMODIF    in varchar2
,sCODE_FROM   in varchar2 /* Номер с */
,sCODE_TO     in varchar2 /* Номер по */
)
is
  sNextNumb   pkg_std.tstring := sCODE_FROM; /* Следующй номер. Присваиваем значение "Номер с" */
  
  nNumber     pkg_std.tnumber; 
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_RA_INS_BY_PERIOD');

  /* Добавление первой записи */
  p_rlarticles_insert(ncompany    => nCOMPANY
                     ,ncrn        => 92065 /* корневой */
                     ,scode       => sNextNumb
                     ,sname       => sNextNumb
                     ,snomen      => sNOMEN
                     ,snommodif   => sNOMMODIF
                     ,nsign_price => 0
                     ,nquant      => 1
                     ,nrn         => nNumber);

  /* Пока Следующий номер не будет равен Номер по */
  while cmp_vc2(sCODE_TO, sNextNumb) != 1
  loop

    /* Генерация следующего номера не будет равен Номер по */
    pkg_document.next_number(sin => sNextNumb, ilength => 32, sout => sNextNumb);

    /* Добавление */
    p_rlarticles_insert(ncompany    => nCOMPANY
                       ,ncrn        => 92065 /* корневой */
                       ,scode       => sNextNumb
                       ,sname       => sNextNumb
                       ,snomen      => sNOMEN
                       ,snommodif   => sNOMMODIF
                       ,nsign_price => 0
                       ,nquant      => 1
                       ,nrn         => nNumber);
  end loop;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_RA_INS_BY_PERIOD;
/
