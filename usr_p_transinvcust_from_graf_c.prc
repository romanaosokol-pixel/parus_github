create or replace procedure usr_p_transinvcust_from_graf_c(nrn              in stages.rn%type /* Rn этапа */
                                                          ,pin_tax_gr       in dictaxgr.code%type
                                                          ,pin_com          in stages.company%type
                                                          ,pin_sum_with_tax in stages.stage_sumtax%type /*:= 500;*/
                                                          ,pin_doc_date     in out date /*Дата акта */
                                                          ,out_sum_out_tax  out stages.stage_sum%type /*:= 500;*/
                                                          ,out_sum_tax      out stages.stage_sum_nds%type /*:= 500;*/
                                                          ,out_tex_err      out varchar2 /*Сообщение об ошибках*/
                                                          ,out_is_ok        out number /* Доступность кнопки ОК */) is

  v_tax_rate dictaxis.p_value%type;
  v_direct   varchar2(20);

begin

  /* Городецкий 2026-04-09 Валидатор формирования акта из этапа договора */

  /* Найдем налоговую ставку */
  begin
    select dx.p_value
      into v_tax_rate
      from dictaxgr dg
      join compverlist v
        on v.company = pin_com
       and v.version = dg.version
       and v.unitcode = 'TaxiesGroups'
      join dictaxis dx
        on dx.tax_group = dg.rn
     where dg.code = pin_tax_gr
       and dx.company = v.company
       and dx.kind = 1
       and dx.beg_date = (select max(t.beg_date)
                            from dictaxis t
                           where t.tax_group = dx.tax_group
                             and t.kind = dx.kind
                             and t.company = pin_com);
  exception
    when no_data_found then
      v_tax_rate := 0;
  end;

  out_sum_tax := round(pin_sum_with_tax * v_tax_rate / (100 + v_tax_rate), 2);

  out_sum_out_tax := pin_sum_with_tax - out_sum_tax;

  /*Проверим , что Статья калькуляции состава затрат лицевого счета задана и равна Доход !*/
  
  usr_p_graf_cntrl(nrn => nrn, out_tex_err => out_tex_err, out_is_ok => out_is_ok);

  if pin_doc_date is null or out_tex_err is not null
  then
    out_is_ok := 0;
    else
    out_is_ok := 1;
  end if;

end;
/
