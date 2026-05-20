create or replace package usr_pkg_unitlist is
  /*
  Package предназначен для работы с разделом "Классы". Городецкий О.И. 21/11/2025
  DMSClasses             UNITLIST         UL
  DMSClassesAttributes   DMSCLATTRS    ULA
  */

  --#########################################################################################################

  /* Проверка наличия поля в таблице при заведении аттрибута с признаком "Физический" */

  procedure ula_chek_is_physical(nrn in dmsclattrs.rn%type);

  --#########################################################################################################

  procedure dmsclattrs_ainsert(nrn in dmsclattrs.rn%type);
  --#########################################################################################################

  procedure dmsclattrs_aupdate(nrn in dmsclattrs.rn%type);
  --#########################################################################################################

end;
/
create or replace package body usr_pkg_unitlist is

  --######################################################################################################### 

  /* Проверка наличия поля в таблице при заведении аттрибута с признаком "Физический" */

  procedure ula_chek_is_physical(nrn in dmsclattrs.rn%type) is
  
  begin
    for ch in ( /* KIND тип атрибута:
                                                                              0 - физический,
                                                                              1 - логический,
                                                                              2 - получен по связи */
               select atr.column_name
                      ,ul.table_name
                      ,atr.kind        type_attr
                      ,utc.table_name  is_tabl
                 from dmsclattrs atr
                 join unitlist ul
                   on ul.rn = atr.prn
                 left join user_tab_columns utc
                   on utc.table_name = ul.table_name
                  and utc.column_name = atr.column_name
                where atr.rn = nrn)
    loop
      if ch.type_attr = 0
         and ch.is_tabl is null
      then
        --- Поле физического атрибута отсутствует в таблице
        p_exception(0, 'Поле %s Физического атрибута отсутвует в таблице %s. Скорее всего данный атрибут должен быть логическим.',
                    ch.column_name, ch.table_name);
      end if;
    
    end loop;
  
  end;

  --#########################################################################################################

  procedure dmsclattrs_ainsert(nrn in dmsclattrs.rn%type) is
  begin
    --Проверка наличия поля в таблице при заведении физического параметра
    ula_chek_is_physical(nrn => nrn);
  
  end;

  --#########################################################################################################
  procedure dmsclattrs_aupdate(nrn in dmsclattrs.rn%type) is
  begin
  
    null;
  
  end;

--#########################################################################################################  

end;
/
