create or replace procedure UDO_P_OPERPLANS_MODIFY(
/*
  Процедура изменения строки Графика отпуска товаров/услуг для утвержденного договора
  */
  nCOMPANY      in number
 ,nRN           in number
 ,nQuant        in number    -- Количество
 ,nPrice        in number    -- Цена
 ,sTAXGR        in varchar2  -- Налоговая группа
 ,sRazd         in varchar2  -- Наименование раздела
)
is
  nSUMM_TAX         number(17,2) := 0;
  nTAXRN            number := null;

  sMAIN_TEXT          varchar2(1024) := null;
  sFULL_TEXT          varchar2(1024) := null;
  sCALL_STACK         varchar2(1024) := null;
  tFCPLANS            FCACOPERPLANS%rowtype;
  
  CRETCUR       PKG_CURSORS.CurType;
  type          tCALC_CUR is record
  (
  NSUMM                PKG_STD.tLNUMBER,
  NSUMMWITHAXS         PKG_STD.tLNUMBER,
  NSUMMWITHTAX         PKG_STD.tLNUMBER,
  NSUMMWITOUTNDS       PKG_STD.tLNUMBER,
  NSUMMWITHOUTNCP      PKG_STD.tLNUMBER,
  NAXCISE_SUM          PKG_STD.tLNUMBER,
  NAXCISE_PRC          PKG_STD.tLNUMBER,
  NAXCISE_RET          PKG_STD.tLNUMBER,
  NNDS_SUM             PKG_STD.tLNUMBER,
  NNDS_PRC             PKG_STD.tLNUMBER,
  NNDS_RET             PKG_STD.tLNUMBER,
  NGSM_SUM             PKG_STD.tLNUMBER,
  NGSM_PRC             PKG_STD.tLNUMBER,
  NGSM_RET             PKG_STD.tLNUMBER,
  NNCP_SUM             PKG_STD.tLNUMBER,
  NNCP_PRC             PKG_STD.tLNUMBER,
  NNCP_RET             PKG_STD.tLNUMBER
  );
  RRETCUR       tCALC_CUR;
  
begin
  /* 17-03-2025 Отключил ограничение на работу процедуры */
  --p_exception(0, 'Процедура временно отключена, если вам нужно исправить график отпуска, напишите обращение в техническую поддержку.'); -- FaceAccountsOperOutPlans
  -- Налоговая группа может быть только одна
    select fc.*
      into tFCPLANS
      from FCACOPERPLANS fc
      where fc.rn = nRN;

  begin
  if (instr(sTAXGR, ';') > 0) then
    P_MSGBOX_TEXT(sSQL_CODE   => '1',
                  sSQL_ERRM   => 'Превышено допустимое количество отмеченных записей налоговой группы.',
                  sMAIN_TEXT  => sMAIN_TEXT,
                  sFULL_TEXT  => sFULL_TEXT,
                  sCALL_STACK => sCALL_STACK);
    p_exception(0,'Налоговая группа может быть выбрана только одна!');
  else
    
    FIND_DICTAXGR_CODE(nFLAG_SMART => 0,
                       nCOMPANY    => nCOMPANY,
                       sCODE       => sTAXGR,
                       nRN         => nTAXRN);
    if nPrice <> 0 then
      tFCPLANS.Price := nPrice; 
    end if;
    
    
    
    begin
      PKG_DICTAXIS_CALC.P_RESULT_CURSOR(nFLAG_SMART => 1,
                                        nCOMPANY    => nCOMPANY,
                                        dDATE       => sysdate,
                                        nSUMM_SIGN  => 0,
                                        nINSUMM     => tFCPLANS.Price * nQuant,
                                        sTAXGR      => sTAXGR,
                                        nQUANT      => 0,
                                        nNCP_SIGN   => 1,
                                        cRETCUR     => CRETCUR);
      if CRETCUR%ISOPEN then
        loop
          fetch CRETCUR into RRETCUR;
          if CRETCUR%NOTFOUND then
            exit;
          end if;
--p_exception(0,' NSUMMWITHAXS ' || RRETCUR.NSUMMWITHTAX || '; NSUMM ' || RRETCUR.NSUMM || '; NNDS_SUM ' || RRETCUR.NNDS_SUM);
  --              NSTAGE_SUM := RRETCUR.NSUMMWITHAXS;
  --              NSTAGE_SUMTAX := RRETCUR.NSUMMWITHTAX;
  --              NSTAGE_SUM_NDS := RRETCUR.NNDS_SUM;
                nSUMM_TAX := RRETCUR.NNDS_SUM;

        end loop;
        close CRETCUR;
      end if;
    end;
     tFCPLANS.QUANT         := nvl(nQuant, tFCPLANS.quant);
     tFCPLANS.QUANT_MAIN    := nvl(nQuant, tFCPLANS.quant);
     tFCPLANS.TAXGR         := nvl(nTAXRN, tFCPLANS.taxgr);
     tFCPLANS.SUMM_NDS      := nvl(nSUMM_TAX, tFCPLANS.summ_nds);
     tFCPLANS.SUMM          := nvl(nQuant * tFCPLANS.Price, tFCPLANS.summ);
     tFCPLANS.SUMMWITHNDS   := nvl(nQuant * tFCPLANS.Price + nSUMM_TAX, tFCPLANS.summwithnds);

--p_exception(0,' RN ' || nRN || ' nTAXRN ' || nTAXRN || ' nSUMM ' || nQuant*nPrice || ' nSUMM_TAX ' || nSUMM_TAX || ' SUMMWITHNDS ' || nQuant*nPrice+nSUMM_TAX);
   --  tFCPLANS.PRICE         := nvl(tFCPLANS.Price, tFCPLANS.price);
    /* исправление записи Графика */
    begin     
       update FCACOPERPLANS tt set
         tt.QUANT         = tFCPLANS.QUANT,
         tt.QUANT_MAIN    = tFCPLANS.QUANT_MAIN,
         tt.PRICE         = tFCPLANS.PRICE,
         tt.TAXGR         = tFCPLANS.TAXGR,
         tt.SUMM_NDS      = tFCPLANS.SUMM_NDS,
         tt.SUMM          = tFCPLANS.SUMM,
         tt.SUMMWITHNDS   = tFCPLANS.SUMMWITHNDS
       where tt.rn = tFCPLANS.Rn;
       
  /* пересчет сумм л/с по планам операций */
    P_FACEACC_SET_OPERSUMS(tFCPLANS.COMPANY, tFCPLANS.PRN, tFCPLANS.RN/*nOPER*/, sysdate/*dOPER_DATE_NEW*/, tFCPLANS.BEGIN_DATE/*dOPER_DATE_OLD*/, 1/*nCHANGE_KIND*/, 0);       

       if ( SQL%NOTFOUND ) then
         PKG_MSG.RECORD_NOT_FOUND(nRN, 'ContractsStages');
       end if;
         
    end;
  end if;
  end;
        
end UDO_P_OPERPLANS_MODIFY;
/
