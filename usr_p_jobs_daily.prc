create or replace procedure USR_P_JOBS_DAILY
/*
Раздел: Пользовательские задания
Ежедневные задания
05/07/2024 Степанов М.
*/
(
 nCOMPANY         in number
)
is
  nNumber   pkg_std.tref; 
begin
  /* Перекомпиляция инвалидных объектов */
  pkg_locpchobj_ddl.compile_invalid_objects;
  
  /* Формирование документов по образцам */
  usr_pkg_jobs_daily.make_docs_by_model( ddate => sysdate );
  commit;
  
  /* Корректировка истории исполнения и сумм исполнения лицевых счетов с расхождениями */
  /* запись RN лицевых счетов в selectlist */
  for c in ( 
            select t.rn, t.company
              from faceacc t
             where usr_pkg_faceacc.faceacc_check_summ_correct( nrn => t.rn ) = 1 
           )
  loop
    p_selectlist_insert( nident    => c.company
                        ,ndocument => c.rn
                        ,sunitcode => 'FaceAccounts'
                        ,nrn       => nNumber );
  end loop;
  /* корректировка */
  usr_pkg_faceacc.faceacc_inithist(ncompany => nCOMPANY, nident => nCOMPANY);
  /* очистка selectlist */
  p_selectlist_clear( nident => nCOMPANY );
  commit;

  /* Если текущий день не выходной */
  if  to_char(sysdate, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') not in ('SAT', 'SUN') then
    /* Рассылка по накладным с входного контроля, не отработанных складом */
    usr_pkg_jobs_daily.mailing_002;
    /* Рассылка по договорам, где не заполнена калькуляция структуры цены */
    usr_pkg_jobs_daily.mailing_003;
    /* Рассылка по договорам, где не пересчитана калькуляция структуры цены */
    usr_pkg_jobs_daily.mailing_004;
    /* Рассылка по РН потребителям, не разнесённых по графикам отпуска */
    usr_pkg_jobs_daily.mailing_007;
    /* Рассылка о договорах с расхождением суммы "Отгружено" */
    usr_pkg_jobs_daily.mailing_008;

  /* Если текущий день Воскресенье */
  elsif to_char(sysdate, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') in ('SUN') then
    /* Рассылка приходных накладных без присоединённых документов */
    usr_pkg_jobs_daily.mailing_005;
    /* Удаление из FILE_BUFFER кроме последних 100 записей */
    delete 
      from file_buffer t
     where t.rn not in ( select a.rn
                           from ( select * from file_buffer order by rn desc ) a
                          where rownum < 100 );
  end if;

  /* Рассылка. Исправления договоров по заданным условиям */
  usr_pkg_jobs_daily.mailing_006( ncompany => nCOMPANY, ddate => sysdate - 1 );

exception
  when others then
    /* Уведомление об ошибке админам */
    usr_pkg_maillst.maillst_insert_exs_ext_send(ncompany      => nCOMPANY
                                               ,sdescription  => 'Парус. Ошибка при выполнении ночного JOB'
                                               ,sto_list      => 'm.stepanov@module.ru;a.khokhryakov@module.ru;o.gorodetskiy@module.ru'
                                               ,stitle        => 'Парус. Ошибка при выполнении ночного JOB'
                                               ,ctext         => 'Текст ошибки: '||sqlerrm ||cr|| dbms_utility.format_call_stack
                                               ,nrn           => nNumber);
end USR_P_JOBS_DAILY;
/
