create or replace procedure usr_p_alloc_arts_det_ins_u(nrn               in number /* Идентификатор документа, на котором вызвано действие */
                                                      ,sfaceacc          in varchar2
                                                      ,sproject_stage_fc in varchar2
                                                      ,is_ok             out number
                                                      ,err_txt           out varchar2
                                                      ) is

begin

  if not (sfaceacc is null and sproject_stage_fc is null)
  then
    is_ok := 1;
  else
    is_ok := 0;
  end if;

  /*Проверим, что ни Лицевой счет (заказ) -- ссылка на этап проекта, ни лицевой счет -- Ссылка на докумен не привязаны к другим подстатьям в году */
  
  


end;
/
