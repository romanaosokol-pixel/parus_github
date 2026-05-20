create or replace procedure UDO_P_PROJECTST_SETBUH
(
--  nRN       in number,              -- регистрационный номер записи
  nIDENT      in number,               -- идентификатор помеченных записей
  nCOMPANY  in number
)
-- Процедура заполнения в ЛС этапа проекта свойства "Шифр_поБУ" по шаблону Код/номер
as
  sBUH_code varchar(20);
  sBUH_numb varchar(20);
  nTMP      number;
 /* sREG_NUMB varchar(20);
  sREG2_NUMB varchar(20);
  sDog_numb  varchar(40);
  nCount    number;*/
  
begin

  for sll in (
    select sl.document
          ,pr.rn    as nRN
          ,pr.CRN   as nCRN
--          ,(select count(st.rn) from STAGES st where st.prn = cn.rn) as nCount
          ,ps.numb
          ,fc.rn    as fc_rn
--          ,
      from PROJECT      pr
          ,PROJECTSTAGE ps
          ,FACEACC      fc 
          ,SELECTLIST   sl
    where sl.ident = nIDENT
      and sl.document = pr.rn
      and sl.unitcode = 'Projects'
      and ps.prn      = pr.rn
      and fc.rn       = ps.faceacc
  ) loop  
  
      sBUH_code := F_DOCS_PROPS_GET_STR_VALUE(
          nPROPERTY    =>  1076177,              -- регистрационный номер записи свойства
          sUNITCODE    => 'Projects',            -- код раздела документа
          nDOCUMENT    =>  sll.nRN               -- регистрационный номер записи документа   
        );
     if sBUH_code is not null then
      sBUH_numb := F_DOCS_PROPS_GET_STR_VALUE(
          nPROPERTY    =>  1076177,              -- регистрационный номер записи свойства
          sUNITCODE    => 'FaceAccounts',            -- код раздела документа
          nDOCUMENT    =>  sll.fc_rn               -- регистрационный номер записи документа   
        ); 
      if  sBUH_numb is null then 
          
        sBUH_numb := sBUH_code ||'-'||trim(sll.numb);
           
     
        begin
             P_DOCS_PROPS_VALS_MODIFY(
                   nCOMPANY          => nCOMPANY             --in number,          -- НЕ ИСПОЛЬЗУЕТСЯ
                  ,nDOCUMENT         => sll.fc_rn                  -- in number,          -- регистрационный номер записи документа
                  ,sUNITCODE         => 'FaceAccounts'            -- in varchar2,        -- код раздела документа
                  ,sPROPCODE         => 'Шифр_поБУ'            -- in varchar2,        -- мнемокод свойства документа
                  ,sSTR_VALUE        => sBUH_numb            --- in varchar2,        -- значение свойства (строка)
                  ,nNUM_VALUE        => null                   -- in number,          -- значение свойства (число)
                  ,dDATE_VALUE       => null                   -- in date,            -- значение свойства (дата)
                  ,nRN               => nTMP                   -- in out number    
              ); 
        exception when others then
          P_exception(0,'!! '||Error_text);
        end;  
      end if;     
      sBUH_numb := F_DOCS_PROPS_GET_STR_VALUE(
          nPROPERTY    =>  6994207,          --'Шифр_по1С'    -- регистрационный номер записи свойства
          sUNITCODE    => 'FaceAccounts',            -- код раздела документа
          nDOCUMENT    =>  sll.fc_rn               -- регистрационный номер записи документа   
        ); 
        
      if  sBUH_numb is null then 
          
        sBUH_numb := sBUH_code ||'/'||trim(sll.numb);
           
     
        begin
             P_DOCS_PROPS_VALS_MODIFY(
                   nCOMPANY          => nCOMPANY             --in number,          -- НЕ ИСПОЛЬЗУЕТСЯ
                  ,nDOCUMENT         => sll.fc_rn                  -- in number,          -- регистрационный номер записи документа
                  ,sUNITCODE         => 'FaceAccounts'            -- in varchar2,        -- код раздела документа
                  ,sPROPCODE         => 'Шифр_по1С'            -- in varchar2,        -- мнемокод свойства документа
                  ,sSTR_VALUE        => sBUH_numb            --- in varchar2,        -- значение свойства (строка)
                  ,nNUM_VALUE        => null                   -- in number,          -- значение свойства (число)
                  ,dDATE_VALUE       => null                   -- in date,            -- значение свойства (дата)
                  ,nRN               => nTMP                   -- in out number    
              ); 
        exception when others then
          P_exception(0,'!! '||Error_text);
        end;      
         --   end if;          
       end if; 
     end if;  
   end loop;
end UDO_P_PROJECTST_SETBUH;
/

