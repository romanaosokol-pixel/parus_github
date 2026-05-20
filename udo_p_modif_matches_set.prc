create or replace procedure UDO_P_MODIF_MATCHES_SET
(
  nPRN                        in number,  -- рег. номер моификации номенклатуры
  nEXT_ID                     in number   -- ID номенклатуры из внешней системы (ИНТЕРМЕХ)
) is
  /*
    Процедура установки соответствия между номенклатурами Парус и Интермех.
  */
  nPRN_                       pkg_std.tREF;  
  nEXT_ID_                    pkg_std.tREF;         
  sNOMEN_CUR                  pkg_std.tSTRING;
  sNOMEN                      pkg_std.tSTRING;
  tATTR                       UDO_TP_MODIF_ATTR;
  sLOAD_DOC                   pkg_std.tSTRING;
begin 
  /* если соответсвие задано, то добавляем запись */
  if nEXT_ID is not null then 
    /* поиск модификации для ID*/
    begin 
      select t.prn
        into nPRN_
        from udo_modif_matches t
       where t.ext_id = nEXT_ID; 
    exception when no_data_found then 
      
      begin
        select t.ext_id,
               (select trim(l.doc_pref)||'-'||trim(l.doc_numb) from udo_loadext_ord_sp sp, udo_loadext_ord l
                 where sp.prn = l.rn and sp.ext_id = to_char(t.ext_id) and rownum < 2)
          into nEXT_ID_,
               sLOAD_DOC
          from udo_modif_matches t
         where t.prn = nPRN; 
      exception when no_data_found then
        nEXT_ID_ := null;
      end;  
      /* проверка на соответствие модификации номенклатуры */
      if nEXT_ID_ != nEXT_ID and nEXT_ID_ is not null then 
        
        select n.nomen_code
          into sNOMEN_CUR  
          from dicnomns n,
               nommodif nm
         where nm.prn = n.rn 
           and nm.rn  = nPRN;  
        
        p_exception(0 ,'Номенклатура "%s" привязываемая к номенклатуре ИНТЕРМЕХ с ID "%s" уже связан с номенклатурой ИНТЕРМЕХ с ID "%s". Привязка невозможна.'||chr(10)||
                       'Предыдущая загрузка %s',
                      sNOMEN_CUR, nEXT_ID,nEXT_ID_, sLOAD_DOC);
      --elsif nEXT_ID_ = nEXT_ID then  
      --  p_exception(0 ,'nPRN_:'||nPRN_ ||' nPRN:'||nPRN||' nEXT_ID:'||nEXT_ID);
      end if; 
    
      /* добавление */
      insert into udo_modif_matches
             (prn,ext_id)  
      values (nPRN,nEXT_ID);
      nPRN_ := nPRN;
    end;
  
    /* */  
    if nPRN_ !=  nPRN  then 
      
      select n.nomen_code
        into sNOMEN_CUR  
        from dicnomns n,
             nommodif nm
       where nm.prn = n.rn 
         and nm.rn  = nPRN; 
                
       select n.nomen_code
        into sNOMEN  
        from dicnomns n,
             nommodif nm
       where nm.prn = n.rn 
         and nm.rn  = nPRN_;  
             
      p_exception(0 ,'Номенклатура ИНТЕРМЕХ с ID "%s" уже связан с номенклатурой "%s". Привязка к номенклатруре "%s" не возможна.', nEXT_ID, sNOMEN_CUR, sNOMEN);

    end if;                                                                                                                                    
    
  /* иначе удаляем запись*/  
  else 
    tATTR := UDO_TP_MODIF_ATTR();
    
    delete udo_modif_matches t where t.prn = nPRN; 
    
    /* подчищаем атрибуты для модификации */
    udo_p_modif_attrs_set(nPRN => nPRN, tATTR => tATTR);
  end if;  
end ;
/

