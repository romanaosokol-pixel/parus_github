create or replace procedure UDO_P_PAYACCIN_SET_ARTICLE
(
NRN in number,
sARTICLE in varchar
) is
 nARTICLE      number;
 PAYN          PAYACCIN%rowtype;
 nFACE_RN      number;
 sVALID_DOC    FACEACC.VALID_DOCNUMB%type;
 sVALID_TYPE   DOCTYPES.DOCCODE%type;
 dVAID_DATE    date;
 /* Процедура подмены фиктивных ЛС во Входящих счетах на оплату*/
begin
  /* Определяем новую статью затрат  */
  begin
    select fa.RN
    into nARTICLE
    from FPDARTCL fa
    where fa.code = sARTICLE;
  exception when NO_DATA_FOUND then
    P_exception(0, 'Не удалось подобрать статью затрат для '||sARTICLE);
  end;
  
  /*считываем данные счета*/
  select p.*
  into PAYN
  from PAYACCIN p
  where p.rn = NRN;
  
  /* Проверим существующий ЛС на договор*/
  begin 
    select dt.doccode, fc.valid_docnumb, fc.valid_docdate, fc.rn
      into sVALID_TYPE, sVALID_DOC, dVAID_DATE, nFACE_RN
      from FACEACC fc, DOCTYPES dt, STAGES st
     where fc.rn  = PAYN.FACEACC
       and dt.rn = fc.valid_doctype
       and fc.rn = st.faceacc;
    exception when NO_DATA_FOUND then
      nFACE_RN := null;
    end;
    if nFACE_RN is not null then
      P_exception(0,'Счет сформирован на основании документа "%s" от %s. Изменение статьи невозможно.', sVALID_TYPE||' '||sVALID_DOC, to_char(dVAID_DATE, 'dd.mm.yyyy') );      
    end if;
  
  /* Подбираем новый ЛС с искомой статьёй */
  begin
    select fc.rn
    into nFACE_RN
    from FACEACC fc
    where fc.agent            = PAYN.SUPPLIER
      and fc.Ieelement        = nARTICLE
      and fc.valid_doctype    is null
      and fc.valid_docnumb    is null
      and fc.valid_docdate    is null
      and fc.fact_close_date  is null;
  exception 
    when NO_DATA_FOUND then
      nFACE_RN := null;
      P_exception(0,'Не удалось подобрать лицевой счет для статьи '||sARTICLE);
    when TOO_MANY_ROWS then
      nFACE_RN := null;
      P_exception(0,'Найдено больше одного лицевого счёта для статьи '||sARTICLE);
    when others then
      nFACE_RN := null;
      P_exception(0,'Неопределённая ситуация при поиске лицевого счёта для статьи '||sARTICLE);
  end;
  
  PAYN.Faceacc := nFACE_RN;
  
  update PAYACCIN pp
  set pp.faceacc = PAYN.Faceacc
  where pp.rn = PAYN.RN;
   
end UDO_P_PAYACCIN_SET_ARTICLE;
/
