create or replace procedure UDO_P_PRODLSTSP_SETPOS
(
  nIDENT   in number,
  nCOMPANY in number
) as
  /*
    08/10/2022 Марков МВ. Создать примечание по позиционным местам.
  */
  sNOTE FCPRODLSTSP.NOTE%type;
begin
  if utilizer not in ('CITK_MARKOV') then
    p_exception(0,
                'У Вас нет прав на выполнение процедупы. Обратитесь к Администратору!!!');
  end if;
  for rec in (select DOCUMENT from SELECTLIST where IDENT = nIDENT) loop
    UDO_PKG_FCPRODLST_BASE.P_ORDSP_POS_CONTEXT(nPRN => rec.document, nCOMPANY => nCOMPANY);
    sNOTE := UDO_PKG_FCPRODLST_BASE.F_ORDSP_POS_GET_CONTEXT(nPRN => rec.document);
    update FCPRODLSTSP SP set SP.NOTE = sNOTE where SP.RN = rec.document;
  end loop;
end;
/

