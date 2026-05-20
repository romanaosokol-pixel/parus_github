create or replace procedure UDO_P_MODIF_ATTRS_SET
(
  nPRN                        in number,  -- рег. номер моификации номенклатуры
  tATTR                       in UDO_TP_MODIF_ATTR
) is
  /*
    Процедура установки атрибутов ИНТРЕМЕХ для модификации номенклатуры Парус.
  */
  nRN                         pkg_std.tREF;    
   
  /* Поиск атрибута можификации номенклатуры  */
  function attr_get_id
  (
    nPRN                        in number, -- рег. номер модификации 
    nID                         in number  -- Идентификатор атрибута 
  ) return number
  is
    nRES                        pkg_std.tREF; -- результат работы
  begin
    select t.rn 
      into nRES
      from UDO_MODIF_ATTR t
     where t.prn          = nPRN
       and t.attribute_id = nID;
      
     return (nRES);
  exception when no_data_found then 
    return (null);
  end;
  
  /* добавление записи */
  procedure attr_insert
  (
   nPRN                         in number,
   nATTRIBUTE_ID                in number,
   sATTRIBUTE_CODE              in varchar2,
   nINTEGER_VALUE               in number,
   nDOUBLE_VALUE                in number,  
   sSTRING_VALUE                in varchar2, 
   sF_EI                        in varchar2,
   sF_VALUE                     in varchar2,
   nBASE_VALUE                  in number,    
   sBASE_CODE                   in varchar2,
   nRN                          out number
  )
  is
  begin
    nRN := gen_id;
    insert into udo_modif_attr
      (rn,
       prn,
       attribute_id,
       attribute_code,
       integer_value,
       double_value,
       string_value,
       f_ei,
       f_value,
       base_value,
       base_code)
    values 
      (nRN,
       nPRN,
       nattribute_id,
       sattribute_code,
       ninteger_value,
       ndouble_value,
       sstring_value,
       sf_ei,
       sf_value,
       nbase_value,
       sbase_code);
  end;  
    
begin
  
  /* если список атрибутов передан, то обновляем/добавляем данные */
  if tATTR.count != 0 then 
    
    /* цикл по атрибутам */
    for indx in tATTR.first..tATTR.last
    loop  
      /* поиск атрибута */
      nRN := attr_get_id(nPRN => nPRN, nID => tATTR(indx).attribute_id);      
     
      if nRN is null then 
        /* добавление */
        attr_insert(nPRN            => nPRN,
                    nATTRIBUTE_ID   => tATTR(indx).attribute_id,
                    sATTRIBUTE_CODE => tATTR(indx).attribute_code,
                    nINTEGER_VALUE  => tATTR(indx).integer_value,
                    nDOUBLE_VALUE   => tATTR(indx).double_value,
                    sSTRING_VALUE   => tATTR(indx).string_value,
                    sF_EI           => tATTR(indx).f_ei,
                    sF_VALUE        => tATTR(indx).f_value,
                    nBASE_VALUE     => tATTR(indx).base_value,
                    sBASE_CODE      => tATTR(indx).base_code,
                    nRN             => nRN);      
      
      /* обновление */
      else 
        update udo_modif_attr t
          set t.attribute_code = tATTR(indx).attribute_code, 
              t.integer_value  = tATTR(indx).integer_value,
              t.double_value   = tATTR(indx).double_value,
              t.string_value   = tATTR(indx).string_value,
              t.f_ei           = tATTR(indx).f_ei,
              t.f_value        = tATTR(indx).f_value,
              t.base_value     = tATTR(indx).base_value,
              t.base_code      = tATTR(indx).base_code
        where t.rn = nRN;
      end if;     
    end loop;
    
    /* удаление отсутствующих в коллекции атрибутов */
    for cur in (select * 
                  from udo_modif_attr t 
                 where t.prn = nPRN
                   and not exists (select null 
                                     from table(cast(tATTR as UDO_TP_MODIF_ATTR)) ta
                                    where ta.attribute_id = t.attribute_id))
    loop 
      delete udo_modif_attr t where t.rn = cur.rn;
    end loop;
    
  /* иначе удаляем атрибуты */  
  else 
    delete udo_modif_attr t where t.prn = nPRN; 
  end if;  
end ;
/

