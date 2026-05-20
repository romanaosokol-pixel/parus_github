create or replace procedure UDO_P_SET_DOCSPROPS_FROM_DOG(nIDENT in number/*, NRN in number*/)
is
    nTMP number;
--    sPROS pkg_std.tSTRING;
 
procedure set_props(
  nCOMPANY in number,
  sUNITCODE in varchar,
  nDOCS     in number,
  sProps_PRM    in varchar,
  sProps_SRT    in varchar,
  sProps_OBR    in varchar
  )
  as
    sPROS pkg_std.tSTRING;
    nTMP number;
  begin

          if sProps_PRM is not null then
            sPROS :=  prsg_prop.SGET(nCOMPANY  => nCOMPANY,
                            nVERSION  => to_number(null),
                            sUNITCODE => sUNITCODE,
                            nDOCUMENT => nDOCS,
                            sPROPCODE => 'ПРИЕМКА');
            if sPROS is null then                
            PKG_DOCS_PROPS_VALS.MODIFY( nPROPERTY   => 8027724,               -- свойство
                                        sUNITCODE   => sUNITCODE,    -- код раздела
                                        nDOCUMENT   => nDOCS,           -- документ
                                        sSTR_VALUE  => sProps_PRM,           -- значение (строка)
                                        nNUM_VALUE  => null,                  -- значение (число)
                                        dDATE_VALUE => null,                  -- значение (дата)
                                        nRN         => ntmp                   -- регистрационный номер записи значения свойства
                                        );
             end if;                         
          end if;                            
          if sProps_SRT is not null then
            sPROS :=  prsg_prop.SGET(nCOMPANY  => nCOMPANY,
                            nVERSION  => to_number(null),
                            sUNITCODE => sUNITCODE,
                            nDOCUMENT => nDOCS,
                            sPROPCODE => 'Сертификация');

            if sPROS is null then                
            PKG_DOCS_PROPS_VALS.MODIFY( nPROPERTY   => 68734548,               -- свойство
                                        sUNITCODE   => sUNITCODE,    -- код раздела
                                        nDOCUMENT   => nDOCS,           -- документ
                                        sSTR_VALUE  => sProps_SRT,           -- значение (строка)
                                        nNUM_VALUE  => null,                  -- значение (число)
                                        dDATE_VALUE => null,                  -- значение (дата)
                                        nRN         => ntmp                   -- регистрационный номер записи значения свойства
                                        );
             end if;                         
          end if;                            
          if sProps_OBR is not null then
            sPROS :=  prsg_prop.SGET(nCOMPANY  => nCOMPANY,
                            nVERSION  => to_number(null),
                            sUNITCODE => sUNITCODE,
                            nDOCUMENT => nDOCS,
                            sPROPCODE => 'ТипОбразца');
            if sPROS is null then                
            PKG_DOCS_PROPS_VALS.MODIFY( nPROPERTY   => 7387012,               -- свойство
                                        sUNITCODE   => sUNITCODE,    -- код раздела
                                        nDOCUMENT   => nDOCS,           -- документ
                                        sSTR_VALUE  => sProps_OBR,           -- значение (строка)
                                        nNUM_VALUE  => null,                  -- значение (число)
                                        dDATE_VALUE => null,                  -- значение (дата)
                                        nRN         => ntmp                   -- регистрационный номер записи значения свойства
                                        );
             end if;                         
          end if;                            

  end;

begin
   for cc in (
      select  pr.rn as nProd_rn
             ,fp.rn as nFC_rn 
             ,fc.company
            , prsg_prop.SGET(nCOMPANY  => fc.company,
                            nVERSION  => to_number(null),
                            sUNITCODE => 'FaceAccountsOperOutPlans',
                            nDOCUMENT => fp.rn,
                            sPROPCODE => 'ПРИЕМКА') as sPriemka
           , prsg_prop.SGET(nCOMPANY  => fc.company,
                            nVERSION  => to_number(null),
                            sUNITCODE => 'FaceAccountsOperOutPlans',
                            nDOCUMENT => fp.rn,
                            sPROPCODE => 'Сертификация') as sSertfk
            , prsg_prop.SGET(nCOMPANY  => fc.company,
                            nVERSION  => to_number(null),
                            sUNITCODE => 'FaceAccountsOperOutPlans',
                            nDOCUMENT => fp.rn,
                            sPROPCODE => 'ТипОбразца') as sObrazec
           ,(select sl.str_value from EXTRA_DICTS_VALUES  sl where sl.rn = sht.sign_type) as sign_type
           ,(select sl.str_value from EXTRA_DICTS_VALUES  sl where sl.rn = sht.exec_type) as exec_type
           ,(select sl.str_value from EXTRA_DICTS_VALUES  sl where sl.rn = sht.cert_type) as cert_type               
      from faceacc fc,
           FCACOPERPLANS fp,
           UDO_PRODUCTORD_SRC_DOC  dl,
           PRODUCTORD              pr,
           UDO_PROJECTSTAGE_SHT    sht
        where fc.rn = fp.prn
        and dl.rn_operplan = fp.rn
        and pr.rn = dl.prn
        and sht.rn (+) = dl.rn_projectstage_sht
        and (fp.rn in (select sel.document from SELECTLIST sel where sel.IDENT = NIDENT) /*or fc.rn = NRN*/)
      ) loop
      
        set_props(
          nCOMPANY  => cc.company,
          sUNITCODE => 'ProductionOrders',
          nDOCS     => cc.nprod_rn,
          sProps_PRM  => nvl(cc.spriemka,cc.sign_type),
          sProps_SRT  => nvl(cc.sSertfk, cc.cert_type),
          sProps_OBR  => nvl(cc.sObrazec, cc.exec_type)
          );

         for potr in( select dl.out_document from doclinks dl 
                       where dl.in_document = cc.nProd_rn 
                         and dl.in_unitcode = 'ProductionOrders'
                         and dl.out_unitcode = 'CostProductExpenseActs' )
         loop
          
            set_props(
              nCOMPANY  => cc.company,
              sUNITCODE => 'CostProductExpenseActs',
              nDOCS     => potr.out_document,
              sProps_PRM  => nvl(cc.spriemka,cc.sign_type),
              sProps_SRT  => nvl(cc.sSertfk, cc.cert_type),
              sProps_OBR  => nvl(cc.sObrazec, cc.exec_type)
              ); 
        
         end loop;
     
         for ml in( select dl2.out_document from PRODUCTORDS prds, doclinks dl, FCPRODPLANSP fc, doclinks dl2
                     where prds.prn = cc.nProd_rn
                       and dl.in_document = prds.rn 
                       and dl.in_unitcode = 'ProductionOrdersSpecs'
                       and dl.out_unitcode = 'CostProductPlansSpecs' 
                       and dl.out_document = fc.PRN_NODE 
                       and fc.rn = dl2.in_document 
                       and dl2.in_unitcode = 'CostProductPlansSpecs'
                       and dl2.out_unitcode = 'CostRouteLists'
                    )
         loop

            set_props(
              nCOMPANY  => cc.company,
              sUNITCODE => 'CostRouteLists',
              nDOCS     => ml.out_document,
              sProps_PRM  => nvl(cc.spriemka,cc.sign_type),
              sProps_SRT  => nvl(cc.sSertfk, cc.cert_type),
              sProps_OBR  => nvl(cc.sObrazec, cc.exec_type)
              ); 
  
            
            for kv in (select dl.out_document from DOCLINKS dl 
                        where dl.in_document = ml.out_document 
                          and dl.in_unitcode = 'CostRouteLists'
                          and dl.out_unitcode = 'CostDeliverySheets'
            ) loop
                     
              set_props(
                nCOMPANY  => cc.company,
                sUNITCODE => 'CostDeliverySheets',
                nDOCS     => kv.out_document,
                sProps_PRM  => nvl(cc.spriemka,cc.sign_type),
                sProps_SRT  => nvl(cc.sSertfk, cc.cert_type),
                sProps_OBR  => nvl(cc.sObrazec, cc.exec_type)
                ); 
          end loop;              
          
     end loop;           

  end loop; 

  
end UDO_P_SET_DOCSPROPS_FROM_DOG;
/
