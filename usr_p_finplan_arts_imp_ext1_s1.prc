create or replace procedure usr_p_finplan_arts_imp_ext1_s1(art_numb         in varchar2
                                                          ,code             in varchar2
                                                          ,name             in varchar2
                                                          ,mes_all          in varchar2
                                                          ,mes_01           in varchar2
                                                          ,mes_02           in varchar2
                                                          ,mes_03           in varchar2
                                                          ,mes_04           in varchar2
                                                          ,mes_05           in varchar2
                                                          ,mes_06           in varchar2
                                                          ,mes_07           in varchar2
                                                          ,mes_08           in varchar2
                                                          ,mes_09           in varchar2
                                                          ,mes_10           in varchar2
                                                          ,mes_11           in varchar2
                                                          ,mes_12           in varchar2
                                                          ,stype_production in varchar2
                                                          ,sdivision_using  in varchar2
                                                          ,spurpose_product in varchar2
                                                          ,squant           in varchar2
                                                          ,saccept_period   in varchar2
                                                          ,srequest         in varchar2
                                                          ,snote            in varchar2
                                                          ,sanalog          in varchar2
                                                          ,shpz             in varchar2
                                                           
                                                           ) is

  /*Шаг записи в таблицу */

  rec usr_t_finplan_arts_imp_ext1%rowtype; --Куда пишем

  procedure prov(sval in varchar2
                ,smes in varchar2
                ,nval out number) is
  
  begin
  
    nval := to_number(replace(trim(replace(replace(trim(sval), ' ', ''), ',', '.'))
                              
                             ,'-'
                             ,''));
  
  exception
    when others then
      p_exception(0
                 ,'По строке № %s , c кодом %s, Наименованием %s , ' || smes ||
                  ' - Заведено не числовое значение (%s). Исправьте файл импорта'
                 ,art_numb
                 ,code
                 ,name
                 ,replace(trim(replace(replace(trim(sval), ' ', ''), ',', '.')), '-', ''));
    
  end;

begin

  rec.sauthid         := utilizer;
  rec.art_numb        := substr(art_numb, 1, 2000);
  rec.code            := code;
  rec.name            := name;
  rec.type_production := stype_production;
  rec.division_using  := sdivision_using;
  rec.purpose_product := spurpose_product;
  rec.accept_period   := saccept_period;
  rec.request         := srequest;
  rec.snote           := snote;
  rec.analog          := sanalog;
  rec.shpz            := shpz;

  /* Преобразуем сумму по месяцам в число */

  if squant is not null
  then
    prov(squant, 'В колонке количество', rec.quant);
  else
    rec.quant := 0;
  end if;

  if mes_all is not null
  then
    prov(mes_all, 'Всего по статье', rec.mes_all);
  else
    rec.mes_all := 0;
  end if;

  if mes_01 is not null
  then
    prov(mes_01, 'В месяце Январь', rec.mes_01);
  else
    rec.mes_01 := 0;
  end if;

  if mes_02 is not null
  then
    prov(mes_02, 'В месяце Февраль', rec.mes_02);
  else
    rec.mes_02 := 0;
  
  end if;

  if mes_03 is not null
  then
    prov(mes_03, 'В месяце Март', rec.mes_03);
  else
    rec.mes_03 := 0;
  end if;

  if mes_04 is not null
  then
    prov(mes_04, 'В месяце Апрель', rec.mes_04);
  else
    rec.mes_04 := 0;
  end if;

  if mes_05 is not null
  then
    prov(mes_05, 'В месяце Май', rec.mes_05);
  else
    rec.mes_05 := 0;
  end if;

  if mes_06 is not null
  then
    prov(mes_06, 'В месяце Июнь', rec.mes_06);
  else
    rec.mes_06 := 0;
  end if;

  if mes_07 is not null
  then
    prov(mes_07, 'В месяце Июль', rec.mes_07);
  else
    rec.mes_07 := 0;
  end if;

  if mes_08 is not null
  then
    prov(mes_08, 'В месяце Август', rec.mes_08);
  else
    rec.mes_08 := 0;
  
  end if;

  if mes_09 is not null
  then
    prov(mes_09, 'В месяце Сентябрь', rec.mes_09);
  else
    rec.mes_09 := 0;
  
  end if;

  if mes_10 is not null
  then
    prov(mes_10, 'В месяце Октябрь', rec.mes_10);
  else
    rec.mes_10 := 0;
  
  end if;

  if mes_11 is not null
  then
    prov(mes_11, 'В месяце Ноябрь', rec.mes_11);
  else
    rec.mes_11 := 0;
  end if;

  if mes_12 is not null
  then
    prov(mes_12, 'В месяце Декабрь', rec.mes_12);
  else
    rec.mes_12 := 0;
  end if;

  insert into usr_t_finplan_arts_imp_ext1
  values rec;

end;
/
