create or replace procedure usr_p_docs_update_gp_det_calc
/*
Документы. Спецификация. Исправить доп.данные приходной партии.
Пересчёт параметров на форме
11/08/2025 Степанов М.
grant execute on usr_p_docs_update_gp_det_calc to public;
*/
(
 dPROD_DATE       in out date       /* Дата производства (поле) */
,sPROD_DATE       in out varchar    /* Дата производства (свойство) */
,sMM_YYYY         in out varchar    /* Дата производства. Шаблон */
,sYYWW            in out varchar    /* Дата производства. Шаблон */
,sDD_MM_YYYY      in out varchar    /* Дата производства. Шаблон */
,sYY              in out varchar    /* Дата производства. Шаблон */
)
is
  sParams1        pkg_std.tstring := sMM_YYYY||sYYWW||sDD_MM_YYYY||sYY; 
begin
  /* Вычисление даты производства по текстовым шаблонам */
  if sMM_YYYY is not null then
    sPROD_DATE  := sMM_YYYY;
    dPROD_DATE  := usr_pkg_common.get_date_from_template( nmode => 0, svalue => sMM_YYYY );
    if replace( sParams1, sMM_YYYY ) is not null then
      p_exception(0, 'Заполнено больше одного шаблона для "Дата производства". Удалите значения из других шаблонов.'); 
    end if;
  elsif sYYWW is not null then
    sPROD_DATE := sYYWW;
    dPROD_DATE  := usr_pkg_common.get_date_from_template( nmode => 1, svalue => sYYWW );
    if replace( sParams1, sYYWW ) is not null then
      p_exception(0, 'Заполнено больше одного шаблона для "Дата производства". Удалите значения из других шаблонов.'); 
    end if;
  elsif sDD_MM_YYYY is not null then
    sPROD_DATE := sDD_MM_YYYY;
    dPROD_DATE  := usr_pkg_common.get_date_from_template( nmode => 2, svalue => sDD_MM_YYYY );
    if replace( sParams1, sDD_MM_YYYY ) is not null then
      p_exception(0, 'Заполнено больше одного шаблона для "Дата производства". Удалите значения из других шаблонов.'); 
    end if;
  elsif sYY is not null then
    sPROD_DATE := sYY||'+';
    dPROD_DATE  := usr_pkg_common.get_date_from_template( nmode => 3, svalue => sYY );
    if replace( sParams1, sYY ) is not null then
      p_exception(0, 'Заполнено больше одного шаблона для "Дата производства". Удалите значения из других шаблонов.'); 
    end if;
  /* если текстовые шаблоны даты не заданы */
  else
    /* обнуляем значения */
    dPROD_DATE := null;
    sPROD_DATE := null;
  end if;
  
end;
/
