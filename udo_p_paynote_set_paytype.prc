create or replace procedure UDO_P_PAYNOTE_SET_PAYTYPE(nCOMPANY in number, nIDENT in number, sPAY_CODE in varchar) is
nPAY_TYPE PKG_STD.tREF;
dDate     date;
begin
  
  /*Процедура для раздела журнала платежей. Изменение Вида оплаты */
  /*30/08/2023 Е.Столярский*/
  
  begin
      FIND_DICPAYVW_CODE
          (
            nSMART_FLAG       => 0,
            nCOMPANY          => nCOMPANY,
            sCODE             => sPAY_CODE,
            nRN               => nPAY_TYPE
          );
   exception when others then
     P_exception(0,'Не удается определить Вид оплаты.');
   end;
   for cc in (
     select pn.rn, pn.faceacc, fc.fact_close_date
     from PAYNOTES PN, FACEACC fc
     where fc.rn = pn.faceacc
       and pn.rn in (select sl.document from SELECTLIST sl where sl.ident = nIDENT) 
   ) loop
      if cc.fact_close_date is not null then
        update FACEACC  ff set ff.fact_close_date = null where ff.rn = cc.faceacc;
        update PAYNOTES pp set pp.PAY_TYPE = nPAY_TYPE where pp.rn = cc.rn;
        update FACEACC  ff set ff.fact_close_date = cc.fact_close_date where ff.rn = cc.faceacc;
        
      else
        update PAYNOTES pp set pp.PAY_TYPE = nPAY_TYPE where pp.rn = cc.rn;
      end if;
     
   
   end loop;  
end UDO_P_PAYNOTE_SET_PAYTYPE;
/
