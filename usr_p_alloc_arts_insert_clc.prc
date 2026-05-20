create or replace procedure usr_p_alloc_arts_insert_clc(ncompany      in number
                                                       ,nrn           in number
                                                       ,nprn          in number
                                                       ,sfinplan_arts in varchar2 /*Номер уточняемой статьи */
                                                       ,nart_numb     out number /* Номер уточняющей статьи */
                                                       ,sfaceacc_cost out faceacc.numb%type
                                                       ,SB_CODE  out varchar2
                                                       ,SB_NAME out varchar2
                                                       ) is
  nfaceacc faceacc.rn%type;
  ncrn     acatalog.rn%type;
begin
  /*24-11-2025  Городецкий О.И. Процедура пересчета формы действия "Добавление" строки бюджетного распределения */
  /* Максимальный номер в рамках уточняемой статьи */
  select nvl(max(ar.art_numb), 0) + 1
    into nart_numb
    from usr_t_alloc_arts ar
    join udo_t_finplan_arts arn on arn.rn = ar.finplan_arts
   where /*ar.prn = nprn
       and*/
   arn.art_numb = (select art.art_numb
                        from usr_t_budget_allocation br
                        join udo_t_finplan_arts art
                          on art.prn = br.finplan
                         and art.art_numb = sfinplan_arts
                       where br.rn = nprn);
  /*Найдем код и наменование уточняемойц статьи бюджета*/                     
  
  select ARN.CODE, arn.name
    into SB_CODE,  SB_NAME
    from USR_T_BUDGET_ALLOCATION BR
    join udo_t_finplan_arts arn on arn.prn = br.finplan and arn.art_numb = sfinplan_arts
   where br.rn = nprn; 
                       
  /*Найдем лицевой счет, сномером равным <Номер уточняемой статьи>/<Номер уточняющей статьи>*/
  sfaceacc_cost := sfinplan_arts || '/' || to_char(nart_numb);
  /* Проверим, что такой лицовой счет существует */
  begin
    select f.rn
      into nfaceacc
      from faceacc f
     where f.numb = sfaceacc_cost
       and f.company = ncompany;
  exception
    when no_data_found then
      /*Найдем каталог лицевых счетов*/
      begin
        select a.rn
          into ncrn
          from acatalog a
         where a.name = get_options_str(scode => 'Realiz_FaceAcc_Catalog', ncomp_vers => ncompany)
           and a.docname = 'FaceAccounts'
           and a.company = ncompany;
      exception
        when no_data_found then
          ncrn := 1028958; -- Каталог "ШПЗ"
      end;
      p_faceacc_insert(ncompany         => ncompany
                      ,ncrn             => ncrn
                      ,sjur_pers        => 'Модуль' -- Модуль  Взять из бюджета
                      ,nprn             => null
                      ,sagent           => 'МОДУЛЬ' --- Взять из юр. лица
                      ,sfinerule        => null
                      ,snumber          => sfaceacc_cost
                      ,nacc_kind        => 0
                      ,nacc_class       => 3
                      ,norder_sign      => 0
                      ,svalid_doctype   => null
                      ,svalid_docnumb   => null
                      ,dvalid_docdate   => null
                      ,dplan_open_date  => trunc(sysdate)
                      ,dfact_open_date  => trunc(sysdate)
                      ,dplan_close_date => null
                      ,dfact_close_date => null
                      ,sexecutive       => null
                      ,scurrency        => 'RUB' --- Взять из бюджета
                      ,ncredit_sum      => 0
                      ,nbegin_sum       => 0
                      ,sfcacgr          => null
                      ,sagnacc          => null
                      ,sagnfi           => null
                      ,sagnfo           => null
                      ,sagn_trans       => null
                      ,ssubdiv          => null
                      ,starif           => null
                      ,ndiscount        => 0
                      ,spay_type        => null
                      ,sship_type       => null
                      ,nprice_type      => null
                      ,dprice_date      => null
                      ,nsigntax         => null
                      ,nsame_nomn       => null
                      ,sfinaccnt        => null
                      ,srespmanager     => null
                      ,sieelement       => null
                      ,sfinsource       => null
                      ,spaytool         => null
                      ,spayprior        => null
                      ,spayrule         => null
                      ,ncheck_bal_sign  => 1
                      ,sspec_mark       => null
                      ,nserv_percent    => null
                      ,snote            => null
                      ,sgovcntrid       => null
                      ,saddr_agent      => null
                      ,saddr_agnacc     => null
                      ,ndup_rn          => null
                      ,nrn              => nfaceacc);
  end;
end;
/
