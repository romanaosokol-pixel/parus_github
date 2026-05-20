create or replace procedure usr_p_fcdelivshsp_select(i_nrn in fcdelivshsp.prn%type
                                                     ---                                                    ,i_company      in fcdelivshsp.company%type
                                                    ,i_s_nomen_type in varchar2 /*Условие отбора по Парусным правилам *;! */) is
  --- Определяем параметры макроподстановки
  sblank     varchar2(20) := get_options_str('EmptySymb');
  sdelimiter varchar2(20) := get_options_str('SeqSymb');
  sstar      varchar2(20) := get_options_str('StarSymb');
  squestsymb varchar2(20) := get_options_str('QuestSymb');
  snotsymb   varchar2(20) := get_options_str('NotSymb');


  v_nrn    docs_props_vals.rn%type;

  /* Заменяем Парусные символы макроподстановок на Оракловые*/
  sel_nomen_type varchar2(80) := replace(replace(i_s_nomen_type, sstar, '%'), squestsymb, '_');

begin



  for cur in (select kvs.rn
                    ,udo_f_fcdelivshsp_nomen_type(nrn => kvs.rn) snomen_type
                from fcdelivshsp kvs
               where kvs.prn = i_nrn)
  loop
  
    if usr_f_strinlike(cur.snomen_type, sel_nomen_type, sdelimiter, sblank, snotsymb) = 1
    then
    
      pkg_docs_props_vals.modify(sproperty   => 'ОТБОР_КОМПВЕД_СТР'
                                ,sunitcode   => 'CostDeliverySheetsSpec'
                                ,ndocument   => cur.rn
                                ,sstr_value  => '1'
                                ,ddate_value => null
                                ,nnum_value  => null
                                ,nrn         => v_nrn);
    
    else
    
      pkg_docs_props_vals.modify(sproperty   => 'ОТБОР_КОМПВЕД_СТР'
                                ,sunitcode   => 'CostDeliverySheetsSpec'
                                ,ndocument   => cur.rn
                                ,sstr_value  => '0'
                                ,ddate_value => null
                                ,nnum_value  => null
                                ,nrn         => v_nrn);
    
    end if;
  
  end loop;

end;
/
