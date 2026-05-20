create or replace procedure USR_P_SDCS_SEPAR_BY_ARTICLE
/*
Распоряжения на отгрузку потребителям. Спецификация. 
Разделить спецификацию на несколько по диапазону заводских номеров
02/12/2023 Степанов М.
*/
(
 nRN              in number
,sARTICLE_FROM    in varchar2
,sARTICLE_TO      in varchar2
)
is
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_SDCS_SEPAR_BY_ARTICLE');

  usr_pkg_sheepdirscust.sheepdircs_separ_by_article(nrn           => nRN
                                                   ,sarticle_from => sARTICLE_FROM
                                                   ,sarticle_to   => sARTICLE_TO);

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  
end USR_P_SDCS_SEPAR_BY_ARTICLE;
/
