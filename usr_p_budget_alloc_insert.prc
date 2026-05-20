create or replace procedure usr_p_budget_alloc_insert(ncompany    in number
                                                     ,sjur_pers   in varchar2 -- Юридическое лицо
                                                     ,ncrn        in number
                                                     ,doc_code    in varchar2
                                                     ,ddocdate    in date
                                                     ,sfp_code    in varchar2 -- Код бюджета
                                                     ,sdedpcode   in varchar2 -- Код отдела
                                                     ,nfinplan_rn in number -- RN бюджета к которому делаем распределение
                                                     ,sgroupbudg  in varchar2 --группа бюджета
                                                     ,nfp_vers    in number --версия бюджета 
                                                     ,nrn         out number) is
  ndoctypes usr_t_budget_allocation.doctypes % type;
  nfinplan  usr_t_budget_allocation.finplan % type;
  ndocnumb  usr_t_budget_allocation.docnumb % type;

begin
  /*Городецкий 20-11-2025 
  Клиентская процедура создания бюджетного распределения
  */

  /* Разрешим ссылки */
  usr_p_budget_alloc_joins(ncompany   => ncompany
                          ,nbr        => nfinplan_rn
                          ,sdoctypes  => doc_code
                          ,sjur_pers  => sjur_pers
                          ,sfp_code   => sfp_code
                          ,sdedpcode  => sdedpcode
                          ,sgroupbudg => sgroupbudg
                          ,nfp_vers   => nfp_vers
                          ,ndoctypes  => ndoctypes
                          ,nfinplan   => nfinplan);

  /*Найдем максимальный номер в организации, по Типу документа,  за период (Определяется бюджетом на основе которого сформировано распределение)*/
  usr_p_budget_alloc_nmb(ncompany => ncompany, nfinplan => nfinplan, ndoctypes => ndoctypes, ndocnumb => ndocnumb);

  /* Создаем запись распределения */
  usr_p_budget_alloc_base_insert(ncompany  => ncompany
                                ,ncrn      => ncrn
                                ,ndoctypes => ndoctypes
                                ,ndocnumb  => ndocnumb
                                ,ddocdate  => ddocdate
                                ,nfinplan  => nfinplan
                                ,nrn       => nrn);

end;
/
