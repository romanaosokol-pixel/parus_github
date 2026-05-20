create or replace procedure UDO_P_TRINVDPTSRESVBUF_REPLACE
(
  nCOMPANY                    in number, -- Рег. номер организации 
  nINVDPTSPBUF                in number, -- Рег. номер спецификации буфера
  nINVDPTSP                   in number  -- Рег. номер спецификации расходной накладной
)
is
/*
  Процедура привязки резервов, связанных со строкой буфера, к спецификации расходной накладной 
  и распределение ТЗ по местам хранения на основе этих резервов
*/
begin
  /* Цикл по спецификации резервов связанных со строкой буфера  */            
  for cur in (select * from UDO_TRINVDEPTSP_RSRVBUF t where t.prn = nINVDPTSPBUF)
  loop
    /* Формируем связь: ЖР - спецификация РНОПодр */
    p_linksall_link_direct(nCOMPANY          => nCOMPANY,
                           sIN_UNITCODE      => 'ReservationJournal',
                           nIN_DOCUMENT      => Cur.Rsrv,
                           nIN_PRN_DOCUMENT  => null,
                           dIN_IN_DATE       => sysdate,
                           nIN_STATUS        => 0,
                           sOUT_UNITCODE     => 'GoodsTransInvoicesToDeptsSpecs',
                           nOUT_DOCUMENT     => nINVDPTSP,
                           nOUT_PRN_DOCUMENT => null,
                           dOUT_IN_DATE      => sysdate,
                           nOUT_STATUS       => 0,
                           nBREAKUP_KIND     => 1);
                           
    /* подбор мест хранения по ЖР */
    UDO_P_TRANSINVDEPTSP_FILL_RSRV(nTRANSINVDEPTSP => nINVDPTSP,nRSRV => Cur.Rsrv);
  end loop;    
  
  /* подчистка */
  delete from  UDO_TRINVDEPTSP_RSRVBUF t where t.prn = nINVDPTSPBUF;
  
end;
/

