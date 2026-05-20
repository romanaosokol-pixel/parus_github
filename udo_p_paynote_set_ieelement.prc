create or replace procedure udo_p_paynote_set_ieelement(
       NCOMPANY in number,
       nIDENT   in number, 
       nArticle in number
) is
  /* Изменение Элемента дохода и расхода журнала платежей
     KHOK. 14.08.2024
  */
  nTmp     number := 0;
begin
  if utilizer not in ('KUROEDOVA_AB', 'KHOK') then 
    p_exception(0,'Необходимо спросить разрешение.'); 
  end if;  

  select count(art.rn)
    into nTmp
    from FPDARTCL art
   where art.rn = nArticle
     and art.CRN in (select RN from ACATALOG connect by prior RN = CRN start with CRN = '6171728'); -- БДДС*/

  if nTmp = 0 then p_exception(0, 'Выбрана статья затрат не из БДДС.'); end if;

  for cc in (
    select FI.RN, FA.IEELEMENT, FA.NUMB
      from PAYNOTES    PN,
           FINPAYNOTES FI,
           FPDARTCL    ART,
           FACEACC     FA
      where PN.COMPANY = NCOMPANY
        and PN.RN in (select sl.document from SELECTLIST sl where sl.ident = nIDENT) 
        and FI.PAYRN = PN.RN
        and PN.FACEACC = FA.RN
        and FI.IEELEMENT = ART.RN
  ) loop

  if nArticle != cc.ieelement then
    p_exception(0, 'Статья затрат ЛС ' || cc.numb || ' отличается от выбранной.');
  else
    update FINPAYNOTES pp set pp.IEELEMENT = nArticle where pp.rn = cc.rn;
  end if;

  end loop;  

end UDO_P_PAYNOTE_SET_IEELEMENT;
/
