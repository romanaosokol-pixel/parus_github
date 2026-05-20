create or replace procedure usr_p_stages_update_clc(nrn            in number
                                                   ,ncompany       in number
                                                   ,sparam         in varchar2
                                                   ,sdictaxgr      in out varchar2
                                                   ,nstage_sum     in out number
                                                   ,nstage_sumtax  in out number
                                                   ,nstage_sum_nds in out number) is

  dstage_date date;
  np_value    dictaxis.p_value%type;

begin

  select st.begin_date into dstage_date from stages st where st.rn = nrn;

  /* Найдем ставку НДС на дату начала этапа */

  begin
  
    select dxv.p_value
      into np_value
      from dictaxgr dxg
      join compverlist v
        on v.version = dxg.version
       and v.company = ncompany
       and v.unitcode = 'TaxiesGroups'
      join dictaxis dxv
        on dxv.tax_group = dxg.rn
     where dxg.code = sdictaxgr
       and dxv.beg_date = (select max(t.beg_date)
                             from dictaxis t
                            where t.tax_group = dxg.rn
                              and t.beg_date <= dstage_date);
  
  exception
    when no_data_found then
      p_exception(0
                 ,'Не найдена ставка налоговой группы "%s" на дату %s'
                 ,sdictaxgr
                 ,to_char(dstage_date, 'DD.MM.YYYY'));
    
  end;

  case sparam
    when 'SDICTAXGR' then
      /*Считаем от суммы без НДС  nstage_sum*/
    
      nstage_sum_nds := round(nstage_sum * np_value / 100, 2);
      nstage_sumtax  := nstage_sum_nds + nstage_sum;
    
    when 'NSTAGE_SUM' then
      /*Считаем от суммы без НДС  nstage_sum*/
    
      nstage_sum_nds := round(nstage_sum * np_value / 100, 2);
      nstage_sumtax  := nstage_sum_nds + nstage_sum;
    
    when 'NSTAGE_SUMTAX' then
    
      /*Считаем от суммы с НДС*/
    
      nstage_sum_nds := round(nstage_sumtax * np_value / (np_value + 100), 2);
      nstage_sum     := nstage_sumtax - nstage_sum_nds;
    
    else
      /*Суммц НДС менять не дадим , она расчетная! */
      p_exception(0, 'Изменение параметра "%s" не поддерживается!');
  end case;

end;
/
