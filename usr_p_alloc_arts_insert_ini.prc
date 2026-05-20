create or replace procedure usr_p_alloc_arts_insert_ini(nprn          in usr_t_alloc_arts_v.prn%type
                                                       ,ncompany      in number
                                                       ,nrn           in usr_t_alloc_arts_v.rn%type
                                                       ,nfinplan      out udo_t_finplan.rn%type
                                                       ,sfaceacc_cost out faceacc.numb%type
                                                       ,nart_numb     out number
                                                       ,soei_code     out varchar2) is
  nfaceacc faceacc.rn%type;
begin

  /* RN для отбора по статьям конкретного бюджета */
  select t.finplan into nfinplan from usr_t_budget_allocation t where t.rn = nprn;

  nart_numb := null; --- Узнаем только после выбора статьи

  /*Определяется уточняемой статьей а она еще не задана */
  sfaceacc_cost := null;

  soei_code := 'шт';

end;
/
