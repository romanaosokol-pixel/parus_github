create or replace package usr_pkg_docs_props_vals is
/*
Пакет для значений свойств документов
12/03/2024 Степанов М.
*/
  /*#########################################################################################################*/

 /* Считывание значения по RN свойства */
  procedure get_val
  (
   nDOC_PROP  in number
  ,sunitcode  in varchar2 
  ,nDOCUMENT  in number
  ,sVAL       out varchar2
  ,nVAL       out number
  ,dVAL       out date
  );
  
   /*#########################################################################################################*/
  /* Считывание значения по RN свойства */
  procedure get_val
  (
   nDOC_PROP  in number
  ,nDOCUMENT  in number
  ,sVAL       out varchar2
  ,nVAL       out number
  ,dVAL       out date
  );
  
   /*#########################################################################################################*/

  /* Считывание значения по Мнемокоду свойства */
  procedure  get_val
  (
   sPROP_CODE in varchar2
  ,ncompany   in number default 90521
  ,sunitcode  in varchar2
  ,nDOCUMENT  in number
  ,sVAL       out varchar2
  ,nVAL       out number
  ,dVAL       out date
  );
  
  /*#########################################################################################################*/
  
  /* Считывание значения по RN свойства (строкового) */
  function get_val_str
  (
   nDOC_PROP in varchar2
  ,sunitcode in varchar2 
  ,nDOCUMENT in number
  ) 
  return varchar2;
  /*#########################################################################################################*/
  
  /* Считывание значения по RN свойства (строкового) */
  function get_val_str
  (
   nDOC_PROP in varchar2
  ,nDOCUMENT in number
  ) 
  return varchar2;
  /*#########################################################################################################*/
  
  /* Считывание значения по коду свойства (строкового) */
  function get_val_str
  (
   sPROP_CODE in varchar2
  ,nCOMPANY   in number default 90521
  ,sUNITCODE  in varchar2
  ,nDOCUMENT  in number 
  ) 
  return varchar2;
   /*#########################################################################################################*/
   
   /* Считывание значения по RN свойства (числового) */
   function get_val_num
  (
    ndoc_prop in number
   ,sunitcode in varchar2
   ,ndocument in number
  ) 
  return number;
  /*#########################################################################################################*/
  
  /* Считывание значения по коду свойства (числового) */
  function get_val_num
  (
   sPROP_CODE in varchar2
  ,nCOMPANY   in number default 90521
  ,sUNITCODE  in varchar2
  ,nDOCUMENT  in number
  )
  return number;
  /*#########################################################################################################*/
  
  /* Считывание значения по RN свойства (числового) */
  function get_val_num
  (
   nDOC_PROP in varchar2
  ,nDOCUMENT in number
  ) 
  return number;
  /*#########################################################################################################*/
   
  /* Считывание значения по RN свойства (датского) */
  function get_val_date
  (
   nDOC_PROP in varchar2
  ,sunitcode in varchar2 
  ,nDOCUMENT in number
  ) 
  return date;
  /*#########################################################################################################*/
  
  
  /* Считывание значения по коду свойства (датского) */
  function get_val_date
  (
   sPROP_CODE in varchar2
  ,nCOMPANY   in number default 90521
  ,sUNITCODE  in varchar2
  ,nDOCUMENT  in number
  ) 
  return date;
  /*#########################################################################################################*/
    
  /* Считывание значения по RN свойства (датского) */
  function get_val_date
  (
   nDOC_PROP in varchar2
  ,nDOCUMENT in number
  ) 
  return date;
  /*#########################################################################################################*/
  
  procedure get_vals_document_type
  /*
  Процедура считывания коллекции свойств записи
  */
  (
   nDOCUMENT    in number
  ,aPROPVALS    out usr_pkg_pub_const.tdocs_props_vals
  );
  /*#########################################################################################################*/

  procedure get_val_from_type
  /*
  Процедура возвращает значение заданного свойства из массива по RN
  */
  (
   nPROPERTY      in  docs_props.rn%type   
  ,aPROPVALS      in  usr_pkg_pub_const.tdocs_props_vals
  ,sSTR_VALUE     out docs_props_vals.str_value%type
  ,nNUM_VALUE     out docs_props_vals.num_value%type
  ,dDATE_VALUE    out docs_props_vals.date_value%type
  );
  /*#########################################################################################################*/

  procedure get_val_from_type
  /*
  Процедура возвращает значение заданного свойства из массива по мнемокожду
  */
  (
   sPROPERTY      in  docs_props.code%type 
  ,aPROPVALS      in  usr_pkg_pub_const.tdocs_props_vals
  ,sSTR_VALUE     out docs_props_vals.str_value%type
  ,nNUM_VALUE     out docs_props_vals.num_value%type
  ,dDATE_VALUE    out docs_props_vals.date_value%type
  );
  /*#########################################################################################################*/

  function get_val_from_type_str
  /*
  Функция возвращает строковое значения из массива по RN
  */
  (
   nPROPERTY  in docs_props.rn%type 
  ,aPROPVALS  in usr_pkg_pub_const.tdocs_props_vals
  ) 
  return docs_props_vals.str_value%type;
  /*#########################################################################################################*/

  function get_val_from_type_str
  /*
  Функция возвращает строковое значения из массива по мнемокоду
  */
  (
   sPROPERTY  in docs_props.code%type 
  ,aPROPVALS  in usr_pkg_pub_const.tdocs_props_vals
  ) 
  return docs_props_vals.str_value%type;
  /*#########################################################################################################*/

  function get_val_from_type_num
  /*
  Функция возвращает числовое значения из массива по RN
  */
  (
   nPROPERTY  in docs_props.rn%type   
  ,aPROPVALS  in usr_pkg_pub_const.tdocs_props_vals
  ) 
  return docs_props_vals.num_value%type;
  /*#########################################################################################################*/

  function get_val_from_type_num
  /*
  Функция возвращает числовое значения из массива по мнемокоду
  */
  (
   sPROPERTY  in docs_props.code%type 
  ,aPROPVALS  in usr_pkg_pub_const.tdocs_props_vals
  ) 
  return docs_props_vals.num_value%type;
  /*#########################################################################################################*/

  function get_val_from_type_date
  /*
  Функция возвращает датское значения из массива по RN
  */
  (
   nPROPERTY  in docs_props.rn%type
  ,aPROPVALS  in usr_pkg_pub_const.tdocs_props_vals
  ) 
  return docs_props_vals.date_value%type;
  /*#########################################################################################################*/

  function get_val_from_type_date
  /*
  Функция возвращает датское значения из массива по мнемокоду
  */
  (
   sPROPERTY  in docs_props.code%type
  ,aPROPVALS  in usr_pkg_pub_const.tdocs_props_vals
  ) 
  return docs_props_vals.date_value%type;
  /*#########################################################################################################*/

  procedure modify_val_from_type
  /*
  Процедура исправляет значение заданного свойства в массиве по RN. 
  Если значение в массиве не найдено, то добавляет
  Если массив пустой, то добавляет 
  */
  (
   nPROPERTY      in docs_props.rn%type  /* RN свойства документа */
  ,sSTR_VALUE     in docs_props_vals.str_value%type  default null 
  ,nNUM_VALUE     in docs_props_vals.num_value%type  default null 
  ,dDATE_VALUE    in docs_props_vals.date_value%type default null 
  ,aPROPVALS      in out usr_pkg_pub_const.tdocs_props_vals
  );
  /*#########################################################################################################*/

  procedure modify_val_from_type
  /*
  Процедура исправляет значение заданного свойства в массиве по мнемокоду
  Если значение в массиве не найдено, то добавляет
  Если массив пустой, то добавляет 
  */
  (
   sPROPERTY      in docs_props.code%type /* код свойства документа */
  ,sSTR_VALUE     in docs_props_vals.str_value%type  default null 
  ,nNUM_VALUE     in docs_props_vals.num_value%type  default null 
  ,dDATE_VALUE    in docs_props_vals.date_value%type default null 
  ,aPROPVALS      in out usr_pkg_pub_const.tdocs_props_vals
  );
  /*#########################################################################################################*/

  procedure modify_vals_document_type
  /*
  Процедура исправления коллекции свойств записи
  */
  (
   nDOCUMENT    in number
  ,sUNITCODE    in varchar2
  ,aPROPVALS    in usr_pkg_pub_const.tdocs_props_vals
  );
  /*#########################################################################################################*/

end usr_pkg_docs_props_vals;
/
create or replace package body usr_pkg_docs_props_vals is

  /*#########################################################################################################*/

  /* Считывание значения по RN свойства Для эффективности добавлен UNITCODE*/
  procedure get_val
  (
   nDOC_PROP  in number  
  ,sunitcode  in varchar2
  ,nDOCUMENT  in number  
  ,sVAL       out varchar2
  ,nVAL       out number
  ,dVAL       out date
  ) as
   begin
     select 
             t.str_value, t.num_value, t.date_value
        into sVAL, nVAL, dVAL
        from docs_props_vals t
       where t.docs_prop_rn = nDOC_PROP
         and T.Unitcode = sunitcode
         and t.unit_rn      = nDOCUMENT;
    exception
      when no_data_found then
        sVAL  := null;
        nVAL  := null;
        dVAL := null;
    end;
   
   
  
   /*#########################################################################################################*/
  /* Считывание значения по RN свойства */
  procedure get_val
  (
   nDOC_PROP  in number
  ,nDOCUMENT  in number
  ,sVAL       out varchar2
  ,nVAL       out number
  ,dVAL       out date
  ) 
  as
  begin
    begin
      select /*+ index(docs_props_vals i_docs_props_vals_doc) */ 
             str_value, num_value, date_value
        into sVAL, nVAL, dVAL
        from docs_props_vals
       where docs_prop_rn = nDOC_PROP
         and unit_rn      = nDOCUMENT;
    exception
      when no_data_found then
        sVAL  := null;
        nVAL  := null;
        dVAL := null;
    end;
  end get_val;
 
 /*#########################################################################################################*/

 /* Считывание значения по Мнемокоду свойства */
  
  procedure get_val
  (
   sPROP_CODE in varchar2
  ,ncompany   in number default 90521
  ,sunitcode  in varchar2
  ,nDOCUMENT  in number
  ,sVAL       out varchar2
  ,nVAL       out number
  ,dVAL       out date
  )
  AS 
  
 begin
   begin
     select zsv.str_value
           ,zsv.num_value
           ,zsv.date_value
       into sval
           ,nval
           ,dval
       from docs_props sv
       join compverlist v1
         on v1.company = ncompany
        and sv.version = v1.version
        and v1.unitcode = 'DocsProperties'
       join docs_props_vals zsv
         on zsv.docs_prop_rn = sv.rn
        and zsv.unit_rn = ndocument
        and zsv.unitcode = sunitcode
      where sv.code = sprop_code;
   
   exception
     when no_data_found then
       null; -- Значит такого свойства нет.
   
   end;
 
 end;
  
  
  /*#########################################################################################################*/
  
   /* Считывание значения по RN свойства (строкового) (Для эффективности добавлен Unitcode)*/
  function get_val_str
  (
    ndoc_prop in varchar2
   ,sunitcode in varchar2
   ,ndocument in number
  ) 
  return varchar2 
  as
    sval docs_props_vals.str_value%type;
    nval docs_props_vals.num_value%type;
    dval docs_props_vals.date_value%type;
  begin
    get_val(ndoc_prop => ndoc_prop
           ,sunitcode => sunitcode
           ,ndocument => ndocument
           ,sval      => sval
           ,nval      => nval
           ,dval      => dval);
    return sval;
  
  end;  
  
  /*#########################################################################################################*/
  
  /* Считывание значения по RN свойства (строкового) */
  function get_val_str
  (
   nDOC_PROP in varchar2
  ,nDOCUMENT in number
  ) 
  return varchar2 
  as
    sVal docs_props_vals.str_value%type;
    nVal docs_props_vals.num_value%type;
    dVal docs_props_vals.date_value%type;
  begin
    get_val(ndoc_prop => nDOC_PROP
           ,ndocument => nDOCUMENT
           ,sval      => sVal
           ,nval      => nVal
           ,dval      => dVal);
    return sVal;
  end get_val_str;
  /*#########################################################################################################*/
  
   /* Считывание значения по коду свойства (строкового) */
  function get_val_str
  (
   sPROP_CODE in varchar2
  ,nCOMPANY   in number default 90521
  ,sUNITCODE  in varchar2
  ,nDOCUMENT  in number
  ) return varchar2 as
    sVAL docs_props_vals.str_value%type;
    nVAL docs_props_vals.num_value%type;
    dVAL docs_props_vals.date_value%type;
  begin
    get_val(sPROP_CODE => sPROP_CODE
           ,ncompany   => nCOMPANY
           ,sunitcode  => sUNITCODE
           ,ndocument  => nDOCUMENT
           ,sval       => sVAL
           ,nval       => nVAL
           ,dval       => dVAl);
    return sval;
  end;
  /*#########################################################################################################*/
  
   
   /* Считывание значения по RN свойства ((Числового)) (Для эффективности добавлен Unitcode)*/
  function get_val_num
  (
    ndoc_prop in number
   ,sunitcode in varchar2
   ,ndocument in number
  ) 
  return number 
  as
    sval docs_props_vals.str_value%type;
    nval docs_props_vals.num_value%type;
    dval docs_props_vals.date_value%type;
  begin
    get_val(ndoc_prop => ndoc_prop
           ,sunitcode => sunitcode
           ,ndocument => ndocument
           ,sval      => sval
           ,nval      => nval
           ,dval      => dval);
    return nval;
  
  end;  
  
  /*#########################################################################################################*/
    /* Считывание значения по коду свойства (Числового) */
  function get_val_num
  (
   sPROP_CODE in varchar2
  ,nCOMPANY   in number default 90521
  ,sUNITCODE  in varchar2
  ,nDOCUMENT  in number
  ) return number as
    sVAL docs_props_vals.str_value%type;
    nVAL docs_props_vals.num_value%type;
    dVAL docs_props_vals.date_value%type;
  begin
    get_val(sPROP_CODE => sPROP_CODE
           ,ncompany   => nCOMPANY
           ,sunitcode  => sUNITCODE
           ,ndocument  => nDOCUMENT
           ,sval       => sVAL
           ,nval       => nVAL
           ,dval       => dVAl);
    return nVAL;
  end;
  
   /*#########################################################################################################*/
  
   /* Считывание значения по RN свойства (числового) */
  function get_val_num
  (
   nDOC_PROP in varchar2
  ,nDOCUMENT in number
  ) 
  return number 
  as
    sVal docs_props_vals.str_value%type;
    nVal docs_props_vals.num_value%type;
    dVal docs_props_vals.date_value%type;
  begin
    get_val(ndoc_prop => nDOC_PROP
           ,ndocument => nDOCUMENT
           ,sval      => sVal
           ,nval      => nVal
           ,dval      => dVal);
    return nval;
  end get_val_num;
  /*#########################################################################################################*/
   
   /* Считывание значения по RN свойства (Дата) (Для эффективности добавлен Unitcode)*/
  function get_val_date
  (
    ndoc_prop in varchar2
   ,sunitcode in varchar2
   ,ndocument in number
  ) 
  return date 
  as
    sval docs_props_vals.str_value%type;
    nval docs_props_vals.num_value%type;
    dval docs_props_vals.date_value%type;
  begin
    get_val(ndoc_prop => ndoc_prop
           ,sunitcode => sunitcode
           ,ndocument => ndocument
           ,sval      => sval
           ,nval      => nval
           ,dval      => dval);
    return dval;
  
  end;  
  
  /*#########################################################################################################*/
    /* Считывание значения по коду свойства (Дата) */
  function get_val_date
  (
   sPROP_CODE in varchar2
  ,nCOMPANY   in number default 90521
  ,sUNITCODE  in varchar2
  ,nDOCUMENT  in number
  ) return date as
    sVAL docs_props_vals.str_value%type;
    nVAL docs_props_vals.num_value%type;
    dVAL docs_props_vals.date_value%type;
  begin
    get_val(sPROP_CODE => sPROP_CODE
           ,ncompany   => nCOMPANY
           ,sunitcode  => sUNITCODE
           ,ndocument  => nDOCUMENT
           ,sval       => sVAL
           ,nval       => nVAL
           ,dval       => dVAl);
    return dVAL;
  end;
  
  /*#########################################################################################################*/
   
  /* Считывание значения по RN свойства (датского) */
  function get_val_date
  (
   nDOC_PROP in varchar2
  ,nDOCUMENT in number
  ) 
  return date
  as
    sVal docs_props_vals.str_value%type;
    nVal docs_props_vals.num_value%type;
    dVal docs_props_vals.date_value%type;
  begin
    get_val(ndoc_prop => nDOC_PROP
           ,ndocument => nDOCUMENT
           ,sval      => sVal
           ,nval      => nVal
           ,dval      => dVal);
    return dval;
  end get_val_date;
  /*#########################################################################################################*/

  procedure get_vals_document_type
  /*
  Процедура считывания коллекции свойств записи
  */
  (
   nDOCUMENT    in number
  ,aPROPVALS    out usr_pkg_pub_const.tdocs_props_vals
  )
  as
  begin

    begin
      select dp.rn          as nprop_rn
            ,dp.code        as sprop_code
            ,dpv.str_value  as sstr_value
            ,dpv.num_value  as nnum_value
            ,dpv.date_value as ddate_value
            bulk collect
        into aPROPVALS
        from docs_props_vals  dpv
            ,docs_props       dp
       where dpv.docs_prop_rn = dp.rn
         and dpv.unit_rn      = nDOCUMENT;
    end;
    
  end get_vals_document_type;
  /*#########################################################################################################*/

  procedure get_val_from_type
  /*
  Процедура возвращает значение заданного свойства из массива по RN
  */
  (
   nPROPERTY      in  docs_props.rn%type   
  ,aPROPVALS      in  usr_pkg_pub_const.tdocs_props_vals
  ,sSTR_VALUE     out docs_props_vals.str_value%type
  ,nNUM_VALUE     out docs_props_vals.num_value%type
  ,dDATE_VALUE    out docs_props_vals.date_value%type
  )
  as
  begin
    /* Если массив не пустой */
    if aPROPVALS.FIRST is not null then

      /* По массиву */
      for i in aPROPVALS.FIRST .. aPROPVALS.LAST loop

        /* Если текущий RN в массиве равен параметру */
        if cmp_num(aPROPVALS(i).NPROP_RN, nPROPERTY) = 1 then
          SSTR_VALUE  := aPROPVALS(i).SSTR_VALUE;
          NNUM_VALUE  := aPROPVALS(i).NNUM_VALUE;
          DDATE_VALUE := aPROPVALS(i).DDATE_VALUE;
          exit;
        else
          /* не задан RN в параметре */
          if nPROPERTY is null then
            p_exception(0, 'В параметрах не задано искомое свойство.'); 
          end if;
        end if;

      end loop;
    end if;
    
  end get_val_from_type;
  /*#########################################################################################################*/

  procedure get_val_from_type
  /*
  Процедура возвращает значение заданного свойства из массива по мнемокожду
  */
  (
   sPROPERTY      in  docs_props.code%type 
  ,aPROPVALS      in  usr_pkg_pub_const.tdocs_props_vals
  ,sSTR_VALUE     out docs_props_vals.str_value%type
  ,nNUM_VALUE     out docs_props_vals.num_value%type
  ,dDATE_VALUE    out docs_props_vals.date_value%type
  )
  as
  begin
    /* Если массив не пустой */
    if aPROPVALS.FIRST is not null then

      /* По массиву */
      for i in aPROPVALS.FIRST .. aPROPVALS.LAST loop

        /* Если текущий мнемокод в массиве равен параметру */
        if cmp_vc2(aPROPVALS(i).SPROP_CODE, sPROPERTY) = 1 then
          SSTR_VALUE  := aPROPVALS(i).SSTR_VALUE;
          NNUM_VALUE  := aPROPVALS(i).NNUM_VALUE;
          DDATE_VALUE := aPROPVALS(i).DDATE_VALUE;
          exit;
        else
          /* не задан и мнемокод в параметре*/
          if sPROPERTY is null then
            p_exception(0, 'В параметрах не задано искомое свойство.'); 
          end if;
        end if;

      end loop;
    end if;
    
  end get_val_from_type;
  /*#########################################################################################################*/

  function get_val_from_type_str
  /*
  Функция возвращает строковое значения из массива по RN
  */
  (
   nPROPERTY  in docs_props.rn%type 
  ,aPROPVALS  in usr_pkg_pub_const.tdocs_props_vals
  ) 
  return docs_props_vals.str_value%type 
  is
    sStr_value    docs_props_vals.str_value%type; 
    nNum_value    docs_props_vals.num_value%type; 
    dDate_value   docs_props_vals.date_value%type; 
  begin
    get_val_from_type
    (
     nProperty   => nPROPERTY
    ,aPropVals   => aPROPVALS
    ,sstr_value  => sStr_value
    ,nnum_value  => nNum_value
    ,ddate_value => dDate_value
    );

    return(sstr_value);

  end get_val_from_type_str;
  /*#########################################################################################################*/

  function get_val_from_type_str
  /*
  Функция возвращает строковое значения из массива по мнемокоду
  */
  (
   sPROPERTY  in docs_props.code%type 
  ,aPROPVALS  in usr_pkg_pub_const.tdocs_props_vals
  ) 
  return docs_props_vals.str_value%type 
  is
    sStr_value    docs_props_vals.str_value%type; 
    nNum_value    docs_props_vals.num_value%type; 
    dDate_value   docs_props_vals.date_value%type; 
  begin
    get_val_from_type
    (
     sProperty   => sPROPERTY
    ,aPropVals   => aPROPVALS
    ,sstr_value  => sStr_value
    ,nnum_value  => nNum_value
    ,ddate_value => dDate_value
    );

    return(sstr_value);

  end get_val_from_type_str;
  /*#########################################################################################################*/

  function get_val_from_type_num
  /*
  Функция возвращает числовое значения из массива по RN
  */
  (
   nPROPERTY  in docs_props.rn%type   
  ,aPROPVALS  in usr_pkg_pub_const.tdocs_props_vals
  ) 
  return docs_props_vals.num_value%type 
  is
    sStr_value  docs_props_vals.str_value%type; 
    nNum_value  docs_props_vals.num_value%type; 
    dDate_value docs_props_vals.date_value%type; 
  begin

    get_val_from_type
    (
     nProperty   => nPROPERTY
    ,aPropVals   => aPROPVALS
    ,sstr_value  => sStr_value
    ,nnum_value  => nNum_value
    ,ddate_value => dDate_value
    );

    return(nnum_value);

  end get_val_from_type_num;
  /*#########################################################################################################*/

  function get_val_from_type_num
  /*
  Функция возвращает числовое значения из массива по мнемокоду
  */
  (
   sPROPERTY  in docs_props.code%type 
  ,aPROPVALS  in usr_pkg_pub_const.tdocs_props_vals
  ) 
  return docs_props_vals.num_value%type 
  is
    sStr_value  docs_props_vals.str_value%type; 
    nNum_value  docs_props_vals.num_value%type; 
    dDate_value docs_props_vals.date_value%type; 
  begin
    get_val_from_type
    (
     sProperty   => sPROPERTY
    ,aPropVals   => aPROPVALS
    ,sstr_value  => sStr_value
    ,nnum_value  => nNum_value
    ,ddate_value => dDate_value
    );

    return(nnum_value);

  end get_val_from_type_num;
  /*#########################################################################################################*/

  function get_val_from_type_date
  /*
  Функция возвращает датское значения из массива по RN
  */
  (
   nPROPERTY  in docs_props.rn%type
  ,aPROPVALS  in usr_pkg_pub_const.tdocs_props_vals
  ) 
  return docs_props_vals.date_value%type 
  is
    sStr_value  docs_props_vals.str_value%type; 
    nNum_value  docs_props_vals.num_value%type; 
    dDate_value docs_props_vals.date_value%type; 
  begin
    get_val_from_type
    (
     nProperty   => nPROPERTY
    ,aPropVals   => aPROPVALS
    ,sstr_value  => sStr_value
    ,nnum_value  => nNum_value
    ,ddate_value => dDate_value
    );

    return(ddate_value);

  end get_val_from_type_date;
  /*#########################################################################################################*/

  function get_val_from_type_date
  /*
  Функция возвращает датское значения из массива по мнемокоду
  */
  (
   sPROPERTY  in docs_props.code%type
  ,aPROPVALS  in usr_pkg_pub_const.tdocs_props_vals
  ) 
  return docs_props_vals.date_value%type 
  is
    sStr_value  docs_props_vals.str_value%type; 
    nNum_value  docs_props_vals.num_value%type; 
    dDate_value docs_props_vals.date_value%type; 
  begin
    get_val_from_type
    (
     sProperty   => sPROPERTY
    ,aPropVals   => aPROPVALS
    ,sstr_value  => sStr_value
    ,nnum_value  => nNum_value
    ,ddate_value => dDate_value
    );

    return(ddate_value);

  end get_val_from_type_date;
  /*#########################################################################################################*/

  procedure modify_val_from_type
  /*
  Процедура исправляет значение заданного свойства в массиве по RN. 
  Если значение в массиве не найдено, то добавляет
  Если массив пустой, то добавляет 
  */
  (
   nPROPERTY      in docs_props.rn%type   /* RN свойства документа */
  ,sSTR_VALUE     in docs_props_vals.str_value%type  default null 
  ,nNUM_VALUE     in docs_props_vals.num_value%type  default null 
  ,dDATE_VALUE    in docs_props_vals.date_value%type default null 
  ,aPROPVALS      in out usr_pkg_pub_const.tdocs_props_vals
  )
  as
    nCount  pkg_std.tnumber := 0; 
  begin
    /* Если массив НЕ пустой */
    if aPROPVALS.FIRST is not null then

      /* Цикл по массиву */
      for i in aPROPVALS.FIRST .. aPROPVALS.LAST loop

        /* если в массиве есть свойство с заданным RN или мнемокодом */
        if (cmp_num(aPROPVALS(i).NPROP_RN  , nPROPERTY) = 1 and nPROPERTY is not null) then
          /* заменяем его значение */
          aPROPVALS(i).SSTR_VALUE  := sSTR_VALUE;
          aPROPVALS(i).NNUM_VALUE  := nNUM_VALUE;
          aPROPVALS(i).DDATE_VALUE := dDATE_VALUE;
          exit;

        /* если в массиве нет свойства */
        else
          /* добавляем в массив RN, мнемокод, значения из параметров */
          nCount := aPROPVALS.LAST + 1;
          aPROPVALS(nCount).nPROP_RN    := nPROPERTY;
          aPROPVALS(nCount).SSTR_VALUE  := sSTR_VALUE;
          aPROPVALS(nCount).NNUM_VALUE  := nNUM_VALUE;
          aPROPVALS(nCount).DDATE_VALUE := dDATE_VALUE;
        end if;       
      end loop;

    /* Если массив пустой */
    else 
      /* добавляем в массив значения из параметров */
      aPROPVALS(1).NPROP_RN    := nPROPERTY;
      aPROPVALS(1).SSTR_VALUE  := sSTR_VALUE;
      aPROPVALS(1).NNUM_VALUE  := nNUM_VALUE;
      aPROPVALS(1).DDATE_VALUE := dDATE_VALUE;
    end if;
    
  end modify_val_from_type;
  /*#########################################################################################################*/

  procedure modify_val_from_type
  /*
  Процедура исправляет значение заданного свойства в массиве по мнемокоду
  Если значение в массиве не найдено, то добавляет
  Если массив пустой, то добавляет 
  */
  (
   sPROPERTY      in docs_props.code%type  /* код свойства документа */
  ,sSTR_VALUE     in docs_props_vals.str_value%type  default null 
  ,nNUM_VALUE     in docs_props_vals.num_value%type  default null 
  ,dDATE_VALUE    in docs_props_vals.date_value%type default null 
  ,aPROPVALS      in out usr_pkg_pub_const.tdocs_props_vals
  )
  as
    nCount  pkg_std.tnumber := 0; 
  begin
    /* Если массив НЕ пустой */
    if aPROPVALS.FIRST is not null then

      /* Цикл по массиву */
      for i in aPROPVALS.FIRST .. aPROPVALS.LAST loop

        /* если в массиве есть свойство с заданным мнемокодом */
        if (cmp_vc2(aPROPVALS(i).SPROP_CODE, sPROPERTY) = 1 and sPROPERTY is not null) then
          /* заменяем его значение */
          aPROPVALS(i).SSTR_VALUE  := sSTR_VALUE;
          aPROPVALS(i).NNUM_VALUE  := nNUM_VALUE;
          aPROPVALS(i).DDATE_VALUE := dDATE_VALUE;
          exit;

        /* если в массиве нет свойства */
        else
          /* добавляем в массив мнемокод, значения из параметров */
          nCount := aPROPVALS.LAST + 1;
          aPROPVALS(nCount).SPROP_CODE  := sPROPERTY;
          aPROPVALS(nCount).SSTR_VALUE  := sSTR_VALUE;
          aPROPVALS(nCount).NNUM_VALUE  := nNUM_VALUE;
          aPROPVALS(nCount).DDATE_VALUE := dDATE_VALUE;
        end if;       
      end loop;

    /* Если массив пустой */
    else 
      /* добавляем в массив значения из параметров */
      aPROPVALS(1).SPROP_CODE  := sPROPERTY;
      aPROPVALS(1).SSTR_VALUE  := sSTR_VALUE;
      aPROPVALS(1).NNUM_VALUE  := nNUM_VALUE;
      aPROPVALS(1).DDATE_VALUE := dDATE_VALUE;
    end if;
    
  end modify_val_from_type;
  /*#########################################################################################################*/

  procedure modify_vals_document_type
  /*
  Процедура исправления свойств записи значениями из массива
  */
  (
   nDOCUMENT    in number
  ,sUNITCODE    in varchar2
  ,aPROPVALS    in usr_pkg_pub_const.tdocs_props_vals
  )
  as
    nNumber pkg_std.tref; 
  begin
    /* Если массив НЕ пустой */
    if aPROPVALS.FIRST is not null then

      /* Цикл по массиву */
      for i in aPROPVALS.FIRST .. aPROPVALS.LAST loop

        /* Если RN в массиве не пустой */
        if apropvals(i).nprop_rn is not null then

          /* исправление значения по RN */
          pkg_docs_props_vals.modify
          (
           nproperty   => apropvals(i).nprop_rn
          ,sunitcode   => sunitcode
          ,ndocument   => ndocument
          ,sstr_value  => apropvals(i).sstr_value
          ,nnum_value  => apropvals(i).nnum_value
          ,ddate_value => apropvals(i).ddate_value
          ,nrn         => nNumber
          );

        /* Если мнемокод в массиве не пустой */
        elsif apropvals(i).sprop_code is not null then

          /* исправление значения по мнемокоду */
          pkg_docs_props_vals.modify
          (
           sproperty   => apropvals(i).sprop_code
          ,sunitcode   => sunitcode
          ,ndocument   => ndocument
          ,sstr_value  => apropvals(i).sstr_value
          ,nnum_value  => apropvals(i).nnum_value
          ,ddate_value => apropvals(i).ddate_value
          ,nrn         => nNumber
          );
        /* Если RN и мнемокод в массиве пустые */
        else
          p_exception(0, 'Не задан RN или мнемокод свойства в массиве свойств для документа с RN: <%s> в разделе <%s>.'
                     ,nDOCUMENT, f_unitlist_getname(sunitcode => sUNITCODE)); 
        end if;
      end loop;
    end if;

  end modify_vals_document_type;
  /*#########################################################################################################*/

end usr_pkg_docs_props_vals;
/
