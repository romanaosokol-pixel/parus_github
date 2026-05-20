create or replace procedure UDO_P_PRJSTG_SHEET_FORMEDIT
(
  nRN                         in number,
  nFIRST                      in out number,
  sNOMEN_CODE                 in out varchar2, -- номенклатура
  sNOMEN_NAME                 in out  varchar2, -- наименование
  sMODIF_CODE                 in out  varchar2, -- модификация
  sMODIF_NAME                 in out  varchar2, -- наименование
  sSIGN_TYPE                  in out  varchar2, -- Вид приемки
  sEXEC_TYPE                  in out  varchar2, -- Тип исполнения
  sCERT_TYPE                  in out  varchar2 -- Сертификация
) is
  rec                         UDO_PROJECTSTAGE_SHT%rowtype;
  /*
    Процедура для формы ввода раздела "Проекты - Ведомости производства"
    
    grant execute on UDO_P_PRJSTG_SHEET_FORMEDIT to public;
  */ 
begin
  if nFIRST = 1 then 
    /* считываем запись строки ведомости */
    rec := UDO_PKG_PRJSTG_SHEET.F_PRJSTG_SHEET_GET(nFLAG_SMART => 0,nRN => nRN);
    
    /* атрибуты МР */
    begin 
      select n.nomen_code,
             n.nomen_name,
             nm.modif_code,
             nm.modif_name
        into sNOMEN_CODE,
             sNOMEN_NAME,
             sMODIF_CODE,
             sMODIF_NAME
        from fcmatresource mr,
             dicnomns n,
             nommodif nm
       where mr.rn = rec.matres 
         and mr.nomenclature = n.rn
         and mr.nomen_modif = nm.rn;
    exception when no_data_found then
      sNOMEN_CODE := null;  
      sNOMEN_NAME := null; 
      sMODIF_CODE := null;
      sMODIF_NAME := null; 
    end;     
    /* атрибуты строки ведомости */
    if rec.sign_type is not null then
      begin
        select EV.STR_VALUE
          into sSIGN_TYPE
          from EXTRA_DICTS_VALUES EV
         where EV.RN = rec.sign_type;
      exception
        when no_data_found then
          p_exception(0, 'В доп.словаре "Приемка" не найдено значение %s', rec.sign_type);
      end;
    end if;
    --
    if rec.exec_type is not null then
      begin
        select EV.STR_VALUE
          into sEXEC_TYPE
          from EXTRA_DICTS_VALUES EV
         where EV.RN = rec.exec_type;
      exception
        when no_data_found then
          p_exception(0, 'В доп.словаре "Тип исполнения изделий" не найдено значение %s', rec.exec_type);
      end;
    end if;
    
    if rec.cert_type is not null then
      begin
        select EV.STR_VALUE
          into sCERT_TYPE
          from EXTRA_DICTS_VALUES EV
         where EV.RN = rec.cert_type;
      exception
        when no_data_found then
          p_exception(0, 'В доп.словаре "Сертификация" не найдено значение %s', rec.cert_type);
      end;
    end if;
    
    nFIRST := 0;
  end if;  
end ;
/

