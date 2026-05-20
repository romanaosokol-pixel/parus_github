create or replace procedure UDO_P_PAYACCINSPCLC_COPY_DL
(
  NCOMPANY           in number,
  NRN                in number
)
is
 tmp                 PKG_STD.tREF;
  nQUANT_PLAN_PN     PKG_STD.tQUANT;
  nQUANT_PLAN_PO     PKG_STD.tQUANT;
  NREC_PN            PKG_STD.tREF;
  NREC_PO            PKG_STD.tREF;
  nQUANT_PN          PKG_STD.tQUANT;
  nQUANT_PO          PKG_STD.tQUANT; 
begin 
  FOR VSO in (select DISTINCT (ps.prn) ps_prn, PS.NOMEN, PS.NOMMODIF, UM.MEAS_TYPE
                from PAYACCINSPEC PS, PAYACCINSPCLC C, DICNOMNS N, DICMUNTS UM 
               where ps.Rn = c.prn
               and ps.prn = NRN
               and ps.company = NCOMPANY
               and PS.Nomen = N.RN
               and N.UMEAS_MAIN = UM.RN) loop

    for DL_RN in (select sp.company, SP.RN SP_RN, SP_PO.RN SP_PO_RN, sp.quant, SP_PO.FACTQUANT
                    From ININVOICESSPECS SP, DOCLINKS DL, INORDERSPECS SP_PO, DOCLINKS DL_PO
                   where DL.IN_DOCUMENT = VSO.PS_PRN
                     and DL.IN_UNITCODE = 'PaymentAccountsIn'
                     and DL.OUT_UNITCODE = 'IncomingInvoices'
                     and SP.PRN = DL.OUT_DOCUMENT
                     and ((VSO.NOMMODIF is not null and SP.MODIF = VSO.NOMMODIF)
                      or (VSO.NOMMODIF is null and SP.NOMEN = VSO.NOMEN))
                     and SP_PO.NOMMODIF = SP.MODIF
                     and DL_PO.IN_DOCUMENT = DL.OUT_DOCUMENT
                     and SP_PO.PRN = DL_PO.OUT_DOCUMENT
                     and DL_PO.OUT_UNITCODE = 'IncomingOrders'
                     and DL_PO.IN_UNITCODE = DL.OUT_UNITCODE
                     and SP.Sernumb = sp_PO.Sernumb
                     and SP.COMPANY = SP_PO.COMPANY) loop
      NREC_PN := DL_RN.SP_RN;
      NREC_PO := DL_RN.SP_PO_RN;
      
      nQUANT_PN :=  DL_RN.QUANT;
      nQUANT_PO :=  DL_RN.FACTQUANT;
      /* Очистим калькуляцию*/
      P_ININVOICESSPC_DELETE_CALC(nCOMPANY => DL_RN.COMPANY,
                                  nPRN     => DL_RN.SP_RN);

      P_INORDERSPECSCLC_DELETE_CALC(nCOMPANY => DL_RN.COMPANY,
                                  nPRN     => DL_RN.SP_PO_RN);

      for data_CLC in (select PS.QUANT, (c.quant_plan * 100)/PS.QUANT  kf, c.*
                         from PAYACCINSPEC PS, PAYACCINSPCLC C
                        where ps.Rn = c.prn
                          and PS.PRN = VSO.PS_PRN
                          and ((VSO.NOMMODIF is not null and PS.NOMMODIF = VSO.NOMMODIF)
                           or (VSO.NOMMODIF is null and PS.NOMEN = VSO.NOMEN)) 
                          ) loop
         case VSO.MEAS_TYPE
           when 1 then
             nQUANT_PLAN_PN := round((DL_RN.QUANT * data_CLC.Kf)/100);
           else
             nQUANT_PLAN_PN := round((DL_RN.QUANT * data_CLC.Kf)/100,3);
           end case;
           
           nQUANT_PN :=  nQUANT_PN - nQUANT_PLAN_PN; 
           if (nQUANT_PN < 0 or (nQUANT_PN <= 1 and nQUANT_PN > 0))then
             nQUANT_PLAN_PN := nQUANT_PLAN_PN + nQUANT_PN;
           end if;
        /* Загрузим заново */
        P_ININVOICESSPC_BASE_INSERT(nCOMPANY      => DL_RN.COMPANY,
                                    nPRN          => DL_RN.SP_RN,-- Родитель
                                    sNUMB         => data_CLC.NUMB, -- Номер строки
                                    nCOST_ARTICLE => data_CLC.COST_ARTICLE, -- Статья затрат
                                    nCOST_PLACE   => data_CLC.COST_PLACE, -- Место возникновения затрат
                                    nCOST_PLAN    => data_CLC.COST_PLAN, -- Затраты на единицу план
                                    nCOST_FACT    => data_CLC.COST_FACT, -- Затраты на единицу факт
                                    nPRIORITY     => data_CLC.PRIORITY, -- Приоритет
                                    nFACEACCOUNT  => data_CLC.FACEACCOUNT, -- Лицевой счёт
                                    nGRAPHPOINT   => data_CLC.GRAPHPOINT, -- Точка графика лицевого счета
                                    nFINOPER_TYPE => data_CLC.FINOPER_TYPE, -- Вид финансовой операции
                                    nQUANT_PLAN   => nQUANT_PLAN_PN, -- Количество план
                                    nQUANT_FACT   => nQUANT_PLAN_PN, -- Количество факт
                                    nSUBDIV       => data_CLC.SUBDIV, -- Подразделение
                                    nRN           => tmp -- Регистрационный номер
                                    );
 
         case VSO.MEAS_TYPE
           when 1 then
             nQUANT_PLAN_PO := round((DL_RN.FACTQUANT * data_CLC.Kf)/100);
            else
              nQUANT_PLAN_PO := round((DL_RN.FACTQUANT * data_CLC.Kf)/100,3);
           end case;   
           nQUANT_PO :=  nQUANT_PO - nQUANT_PLAN_PO; 
      if (nQUANT_PO < 0 or (nQUANT_PO <= 1 and nQUANT_PO > 0))then
             nQUANT_PLAN_PO := nQUANT_PLAN_PO + nQUANT_PO;
          end if;

      P_INORDERSPECSCLC_BASE_INSERT(nCOMPANY      => DL_RN.COMPANY,
                                    nPRN          => DL_RN.SP_PO_RN, -- Родитель
                                    sNUMB         => data_CLC.NUMB, -- Номер строки
                                    nCOST_ARTICLE => data_CLC.COST_ARTICLE, -- Статья затрат
                                    nCOST_PLACE   => data_CLC.COST_PLACE, -- Место возникновения затрат
                                    nCOST_PLAN    => data_CLC.COST_PLAN, -- Затраты на единицу план
                                    nCOST_FACT    => data_CLC.COST_FACT, -- Затраты на единицу факт
                                    nPRIORITY     => data_CLC.PRIORITY, -- Приоритет
                                    nFACEACCOUNT  => data_CLC.FACEACCOUNT, -- Лицевой счёт
                                    nGRAPHPOINT   => data_CLC.GRAPHPOINT, -- Точка графика лицевого счета
                                    nFINOPER_TYPE => data_CLC.FINOPER_TYPE, -- Вид финансовой операции
                                    nQUANT_PLAN   => nQUANT_PLAN_PO, -- Количество план
                                    nQUANT_FACT   => nQUANT_PLAN_PO, -- Количество факт
                                    nSUBDIV       => data_CLC.SUBDIV, -- Подразделение
                                    nRN           => tmp -- Регистрационный номер
                                    );
      end loop;
    if NREC_PN != DL_RN.SP_RN then

          nQUANT_PN     := 0;
     end if;
     if NREC_PO != DL_RN.SP_PO_RN then

          nQUANT_PO  := 0;
     end if;
    
     
     end loop;

  end loop;
end UDO_P_PAYACCINSPCLC_COPY_DL;
-- grant execute on UDO_P_PAYACCINSPCLC_COPY_DL to public;
/

