create or replace procedure UDO_P_MARK_ATTR_U_FORM_INIT
/*
   Инициализация формы исправления атрибута в разделе "Показатели (атрибуты)"
  */
(
  NRN              number --рег. номер атрибута показателя
 ,SNAME            out varchar2 --наименование атрибута показателя
 ,NDATA_TYPE       out number --тип данных (см. константы UDO_PKG_TYPE_ATTR.NDATA_TYPE_*)
 ,NLNK_TYPE        out number --тип связи (см. константы UDO_PKG_TYPE_ATTR.NLNK_TYPE_*)
 ,SVAL_STR         out varchar2 --строковое значение
 ,NVAL_NUMB        out number --числовое значение
 ,DVAL_DATE        out date --значение типа дата
 ,SUNIT            out varchar2 --раздел привязки
 ,SMETHOD          out varchar2 --метод вызова привязки
 ,SPRM_IN          out varchar2 --наименование входного параметра привязки
 ,SPRM_OUT         out varchar2 --наименование выходного параметра привязки
 ,SVAL_PARENT      out varchar2 --значение родительского параметра
 ,SVAL_CHILD_QUERY out varchar2 --запрос на выборку дочерних значений
 ,NEX_DICT         out number --рег. номер дополнительного словаря
) is
begin
  --выполним инициализацию
  UDO_PKG_MARK.MARK_ATTR_U_FORM_INIT(NRN              => NRN
                                    ,SNAME            => SNAME
                                    ,NDATA_TYPE       => NDATA_TYPE
                                    ,NLNK_TYPE        => NLNK_TYPE
                                    ,SVAL_STR         => SVAL_STR
                                    ,NVAL_NUMB        => NVAL_NUMB
                                    ,DVAL_DATE        => DVAL_DATE
                                    ,SUNIT            => SUNIT
                                    ,SMETHOD          => SMETHOD
                                    ,SPRM_IN          => SPRM_IN
                                    ,SPRM_OUT         => SPRM_OUT
                                    ,SVAL_PARENT      => SVAL_PARENT
                                    ,SVAL_CHILD_QUERY => SVAL_CHILD_QUERY
                                    ,NEX_DICT         => NEX_DICT);
end;
--grant execute on UDO_P_MARK_ATTR_U_FORM_INIT to public;
/

