create or replace procedure UDO_P_PRODUCTORD_SET_NOM_REQV(nIDENT in number, sCOMENT in varchar) is
/*23/11/2022 Столярский Е.З.*/
/*Процедура заполнения свойства Заявка в заказах на производство по выделенным записям */

nTMP PKG_STD.tREF;
begin
  if trim(sCOMENT) is not null then
    for st in (
      select pd.rn
      from SELECTLIST sl
          ,PRODUCTORD  pd
      where sl.ident = nIDENT
        and pd.rn = sl.document
       ) loop 
         PKG_DOCS_PROPS_VALS.MODIFY
            (
              sPROPERTY         => 'НОМ_ЗЯВКИ',          -- мнемокод свойства
              sUNITCODE         => 'ProductionOrders',   -- код раздела
              nDOCUMENT         => st.rn,                -- документ
              sSTR_VALUE        => trim(sCOMENT),        -- значение (строка)
              nNUM_VALUE        => null,                 -- значение (число)
              dDATE_VALUE       => null,                 -- значение (дата)
              nRN               => nTMP                  -- регистрационный номер записи значения свойства
            );
  
    end loop;
  end if;  
end UDO_P_PRODUCTORD_SET_NOM_REQV;
/

