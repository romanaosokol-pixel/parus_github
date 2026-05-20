create or replace procedure UDO_P_PAYNOTES_BASE_UPDATE(PAYNT PAYNOTES%rowtype) is
begin
         p_paynotes_base_update
          (
             nRN                 => PAYNT.RN
            ,nCOMPANY            => PAYNT.COMPANY
            ,nJUR_PERS           => PAYNT.JUR_PERS 
            ,sPAY_PREFIX         => PAYNT.PAY_PREFIX
            ,sPAY_NUMBER         => PAYNT.PAY_NUMBER
            ,nPAYER              => PAYNT.PAYER
            ,dPAY_DATE           => PAYNT.Pay_Date
            ,nPAY_TYPE           => PAYNT.PAY_TYPE 
            ,nSERV_PAY           => PAYNT.SERV_PAY
            ,nFACEACC            => PAYNT.Faceacc
            ,nGRAPHPOINT         => PAYNT.GRAPHPOINT
            ,nFINOPER            => PAYNT.FINOPER
            ,nPAYTOOL            => PAYNT.PAYTOOL
            ,nVDOC_TYPE          => PAYNT.VDoc_Type
            ,sVDOC_NUMB          => PAYNT.VDoc_Numb
            ,dVDOC_DATE          => PAYNT.VDoc_Date
            ,nFDOC_TYPE          => PAYNT.FDoc_type
            ,sFDOC_NUMB          => PAYNT.FDOC_Numb
            ,dFDOC_DATE          => PAYNT.FDOC_Date
            ,nESCORT_DOCTYPE     => PAYNT.ESCORT_DOCTYPE
            ,sESCORT_DOCNUMB     => PAYNT.ESCORT_DOCNUMB
            ,dESCORT_DOCDATE     => PAYNT.ESCORT_DOCDATE
            ,nCURRENCY           => PAYNT.CURRENCY
            ,nCURR_RATE          => PAYNT.CURR_RATE
            ,nCURR_RATE_BASE     => PAYNT.CURR_RATE_BASE
            ,nCURR_RATE_ACC      => PAYNT.CURR_RATE_ACC
            ,nCURR_RATE_PAY_ACC  => PAYNT.CURR_RATE_PAY_ACC
            ,nCURR_RATE_TRD      => PAYNT.CURR_RATE_TRD
            ,nCURR_RATE_BASE_TRD => PAYNT.CURR_RATE_BASE_TRD
            ,nPAY_SUM            => PAYNT.PAY_SUM
            ,nPAY_SUM_ACC        => PAYNT.PAY_SUM_ACC
            ,nPAY_SUM_TRD        => PAYNT.PAY_SUM_TRD
            ,nFINSPEC            => PAYNT.FINSPEC
            ,nINTRDEBT           => PAYNT.INTRDEBT
            ,nEDITABLE           => PAYNT.EDITABLE 
            ,nSIGNPLAN           => PAYNT.SIGNPLAN 
            ,nPAY_PLAN           => PAYNT.PAY_PLAN
            ,nSIGNACNT           => PAYNT.SIGNACNT
            ,nSIGNSPENT          => PAYNT.SIGNSPENT 
            ,nSIGNACTIVE         => PAYNT.SIGNACTIVE
            ,nTAXGROUP           => PAYNT.TAXGROUP
            ,nSIGNOPACC          => PAYNT.SIGNOPACC
            ,nTDOC_TYPE          => PAYNT.TDoc_Type
            ,sTDOC_NUMB          => PAYNT.TDoc_Numb
            ,dTDOC_DATE          => PAYNT.tDoc_Date
            ,nTAX_SUM            => PAYNT.TAX_SUM
            ,nTAX_PERCENT        => PAYNT.TAX_PERCENT
            ,sCOMMENTS           => PAYNT.COMMENTS
            ,sALTSIGN1           => PAYNT.ALTSIGN1
            ,sALTSIGN2           => PAYNT.ALTSIGN2
            ,sALTSIGN3           => PAYNT.ALTSIGN3
            ,sALTSIGN4           => PAYNT.ALTSIGN4
            ,sALTSIGN5           => PAYNT.ALTSIGN5
            ,sALTSIGN6           => PAYNT.ALTSIGN6
            ,sALTSIGN7           => PAYNT.ALTSIGN7
            ,sALTSIGN8           => PAYNT.ALTSIGN8
            ,sALTSIGN9           => PAYNT.ALTSIGN9
            ,sALTSIGN10          => PAYNT.ALTSIGN10
            ,sPAY_PURP           => PAYNT.PAY_PURP
            ,nGOVCNTRID          => PAYNT.GOVCNTRID
            ,nSEPACCOP           => PAYNT.SEPACCOP
            ,nAGNACC             => PAYNT.AGNACC            -- Реквизиты контрагента юридического лица
            ,nPAYER_AGNACC       => PAYNT.PAYER_AGNACC      -- Реквизиты контрагента
           -- ,nBILL               => InDOC.  in number default null
          );
end UDO_P_PAYNOTES_BASE_UPDATE;
/

