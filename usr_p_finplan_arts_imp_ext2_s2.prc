create or replace procedure usr_p_finplan_arts_imp_ext2_s2
(
  finplan_rn      in varchar2
 ,dept_code       in varchar2
 ,syyyy           in varchar2
 ,art_code        in varchar2
 ,art_name        in varchar2
 ,art_note        in varchar2
 ,type_production in varchar2
 ,division_using  in varchar2
 ,purpose_product in varchar2
 ,quant           in varchar2
 ,oei             in varchar2
 ,mes_01          in varchar2
 ,mes_02          in varchar2
 ,mes_03          in varchar2
 ,mes_04          in varchar2
 ,mes_05          in varchar2
 ,mes_06          in varchar2
 ,mes_07          in varchar2
 ,mes_08          in varchar2
 ,mes_09          in varchar2
 ,mes_10          in varchar2
 ,mes_11          in varchar2
 ,mes_12          in varchar2
 ,SHPZ            in varchar2
 ,out_err_txt     out varchar2
) is
  rec usr_t_finplan_arts_imp_ext2%rowtype; --Куда пишем
  ---nart_rn_parent   udo_t_finplan_arts.rn%type; /* RN Строки бюджета в которую будем добавлять номер */
  sart_code_parent udo_t_finplan_arts.code%type; /* Код строки бюджета в который собираемся грузить, полученный из файла */

  procedure err_txt_1(smonth in varchar2) is
  begin
    out_err_txt := 'По строке c кодом ' || art_code || ', Наименованием ' || art_name || ', в месяце ' || smonth ||
                   '- Заведено не числовое значение. Исправьте файл импорта';
    return;
  end;

begin
  rec.sauthid         := utilizer;
 --- rec.finplan_rn      := finplan_rn;
  rec.dept_code       := dept_code; --- Проверено на предыдущем шаге загрузки
  rec.syyyy           := syyyy; --- Проверено на предыдущем шаге загрузки
  rec.art_code        := art_code; -- Просто поля для информации
  rec.art_name        := art_name; -- Просто поля для информации
  rec.art_note        := art_note; -- Просто поля для информации
  rec.type_production := type_production; -- Просто поля для информации
  rec.division_using  := division_using; -- Просто поля для информации
  rec.purpose_product := purpose_product; -- Просто поля для информации
  rec.quant           := quant; -- Просто поля для информации
  rec.oei             := nvl(oei,'шт'); -- Просто поля для информации
  rec.shpz := SHPZ; --- ШПЗ
  
  
  /* Заменим разделитель _ на . */
  
  /*!!!  Уговорить разделить в файле номер статьи бюджета и доп статью !!! */
  sart_code_parent := replace(srcstr => art_code, oldsub => '_', newsub => '.');
  
  rec.art_nn   :=substr(sart_code_parent,instr(sart_code_parent, '.', -1)+1); 
  
  /* Проверим, что статья в которую грузим существует */
  begin
    select t.rn, t.prn, T.ART_NUMB
      into rec.PARENT_ART_RN, rec.finplan_rn, rec.parent_art_code
      from USR_T_BUDGET_ALLOCATION br
      join udo_t_finplan_arts t on t.prn = br.finplan
     where br.rn = finplan_rn
       and t.art_numb = substr(sart_code_parent, 1, instr(sart_code_parent, '.', -1) - 1);
  exception
    when no_data_found then
      out_err_txt := 'Не найден номе статьи в бюджете "' || substr(sart_code_parent, 1, instr(sart_code_parent, '.', -1) - 1) || '"';
      return;
  end;
  /* Преобразуем сумму по месяцам в число */
  if mes_01 is not null
  then
    begin
      rec.mes_01 := to_number(mes_01);
    exception
      when others then
        err_txt_1('Январь');
    end;
  end if;
  if mes_02 is not null
  then
    begin
      rec.mes_02 := to_number(mes_02);
    exception
      when others then
        err_txt_1('Февраль');
    end;
  end if;
  if mes_03 is not null
  then
    begin
      rec.mes_03 := to_number(mes_03);
    exception
      when others then
        err_txt_1('Март');
    end;
  end if;
  if mes_04 is not null
  then
    begin
      rec.mes_04 := to_number(mes_04);
    exception
      when others then
        err_txt_1('Апрель');
    end;
  end if;
  if mes_05 is not null
  then
    begin
      rec.mes_05 := to_number(mes_05);
    exception
      when others then
        err_txt_1('Май');
    end;
  end if;
  if mes_06 is not null
  then
    begin
      rec.mes_06 := to_number(mes_06);
    exception
      when others then
        err_txt_1('Июнь');
    end;
  end if;
  if mes_07 is not null
  then
    begin
      rec.mes_07 := to_number(mes_07);
    exception
      when others then
        err_txt_1('Июль');
    end;
  end if;
  if mes_08 is not null
  then
    begin
      rec.mes_08 := to_number(mes_08);
    exception
      when others then
        err_txt_1('Август');
    end;
  end if;
  if mes_09 is not null
  then
    begin
      rec.mes_09 := to_number(mes_09);
    exception
      when others then
        err_txt_1('Сентябрь');
    end;
  end if;
  if mes_10 is not null
  then
    begin
      rec.mes_10 := to_number(mes_10);
    exception
      when others then
        err_txt_1('Октябрь');
    end;
  end if;
  if mes_11 is not null
  then
    begin
      rec.mes_11 := to_number(mes_11);
    exception
      when others then
        err_txt_1('Ноябрь');
    end;
  end if;
  if mes_12 is not null
  then
    begin
      rec.mes_12 := to_number(mes_12);
    exception
      when others then
        err_txt_1('Декабрь');
    end;
  end if;
  insert into usr_t_finplan_arts_imp_ext2 values rec;
end;
/
