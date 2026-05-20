create or replace procedure UDO_P_SYSD0035_STAGE_MODIFY(
/*
  Процедура изменения Этапа утвержденного договора
  KHOK
  */
  nCOMPANY      in number
 ,nRN           in number
 ,nSUMM         in number
 ,sTAXGR        in varchar2
 ,sCURR         in varchar2
 ,dDOC_BEG      in date
 ,dDOC_END      in date
 ,sDESCR        in varchar2 
 ,sNOTE         in varchar2
)  is
  nOLD_SUMM         number(17,2);
  nSUMM_TAX         number(17,2) := 0;
  nFACEACC          STAGES.Faceacc%type := null;
  nTAXRN            DICTAXGR.RN%type := null;
  nCURR             CURNAMES.RN%type := null;
  --sDESC             STAGES.Description%TYPE;
  --sPRIM             STAGES.Comments%TYPE;

  sMAIN_TEXT          varchar2(1024) := null;
  sFULL_TEXT          varchar2(1024) := null;
  sCALL_STACK         varchar2(1024) := null;

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
  -- Считываем запись
  begin
    select t.stage_sum, t.faceacc --, t.description, t.comments
      into nOLD_SUMM, nFACEACC--, sDESC, sPRIM 
      from stages t where t.rn = nRN;
  exception
    when NO_DATA_FOUND then
      pkg_msg.RECORD_NOT_FOUND(0, nRN, 'Stages');
  end;
    
  -- Можно изменить только нулевую сумму
/*  if (nOLD_SUMM != 0 and nSUMM > 0) then
    p_exception(0,' Сумма этапа ненулевая. Для ее изменения обратитесь к Администратору!');
  end if;*/

  -- Налоговая группа может быть только одна
  begin
  if (instr(sTAXGR, ';') > 0) then
    P_MSGBOX_TEXT(sSQL_CODE   => '1',
                  sSQL_ERRM   => 'Превышено допустимое количество отмеченных записей налоговой группы.',
                  sMAIN_TEXT  => sMAIN_TEXT,
                  sFULL_TEXT  => sFULL_TEXT,
                  sCALL_STACK => sCALL_STACK);
    p_exception(0,'Налоговая группа может быть выбрана только одна!');
  else
    if nSUMM is not NULL then
      FIND_DICTAXGR_CODE(nFLAG_SMART => 0,
                         nCOMPANY    => nCOMPANY,
                         sCODE       => sTAXGR,
                         nRN         => nTAXRN);
      begin
        PKG_DICTAXIS_CALC.P_RESULT_CURSOR(nFLAG_SMART => 1,
                                          nCOMPANY    => nCOMPANY,
                                          dDATE       => sysdate,
                                          nSUMM_SIGN  => 1,
                                          nINSUMM     => nSUMM,
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
    end if;

    if sCURR is not null then -- Ищем RN Валюты
      FIND_CURRENCY_BY_CODE(COMPANY => nCOMPANY,
                            CODE    => sCURR,
                            RN      => nCURR);
--  p_exception(0,' sCURR ' || sCURR || '; nCURR ' || nCURR || '; nFACEACC ' || nFACEACC);
      begin
        update FACEACC fa
           set fa.currency = nvl(nCURR, fa.currency)
           where fa.RN = nFACEACC;

           if ( SQL%NOTFOUND ) then
             PKG_MSG.RECORD_NOT_FOUND(nRN, 'ContractsStages');
           end if;
      end; 
    end if;

    /* исправление записи Этапа */
    begin
--  p_exception(0,' RN ' || nRN || ' nTAXRN ' || nTAXRN || ' nSUMM ' || nSUMM || ' nSUMM_TAX ' || nSUMM_TAX);
         update STAGES st
         set 
           st.TAXGR         = nvl(nTAXRN, st.taxgr)
          ,st.SUM_TYPE      = 0 --nSUM_TYPE вручную,
          ,st.STAGE_SUMTAX  = nvl(nSUMM, st.stage_sumtax)
          ,st.STAGE_SUM_NDS = nvl(nSUMM_TAX, st.stage_sum_nds)
          ,st.STAGE_SUM     = nvl(nSUMM-nSUMM_TAX, st.stage_sum)
          ,st.BEGIN_DATE    = nvl(dDOC_BEG, st.begin_date)
          ,st.END_DATE      = nvl(dDOC_END, st.end_date)
          ,st.DESCRIPTION   = nvl(sDESCR, st.description)
          ,st.COMMENTS      = nvl(sNOTE, st.comments)
         where st.RN = nRN;

         if ( SQL%NOTFOUND ) then
           PKG_MSG.RECORD_NOT_FOUND(nRN, 'ContractsStages');
         end if;
    end;  
  end if;
  end;
      
end UDO_P_SYSD0035_STAGE_MODIFY;
/

