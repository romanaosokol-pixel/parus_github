create or replace procedure UDO_P_PAYACCIN_CHECK_APPROVE(
  COMPANY          in number,
  CATALOG          in number  default null,
  DOCUMENT         in number,
  RESULT           out number)
is
/* 
  14/08/2023 KHOK
  Проверка утверждения счета и наличия присоединенного документа перед его переадресацией по Статусной модели 
*/
 nDocState PAYACCIN.Doc_State%type := 0;
 sRes      varchar(10);
 --sAuthor   AGNLIST.AGNABBR%type;
begin
  begin
    select pa.DOC_STATE, UDO_F_FILELINKS_HAVE_DOCS(pa.RN)--, UDO_F_PAYACCIN_AUTHOR(pa.rn)
      into nDocState, sRes--, sAuthor
      from PAYACCIN pa,
           CLNEVENTS cl
     where cl.RN = DOCUMENT 
       and cl.linked_unit = 'PaymentAccountsIn'
       and cl.linked_rn = pa.rn
       and pa.company = UDO_P_PAYACCIN_CHECK_APPROVE.COMPANY;
  exception
    when no_data_found then -- не наше событие
      nDocState := 1;
  end;
--if utilizer = 'KHOK' then p_exception(0,sAuthor); end if;   
  if nDocState != 1 then
    RESULT := 0;
    p_exception(0, 'Ошибка! Счет должен быть в статусе "Утвержден".');
  end if;
  if sRes is null then
    RESULT := 0;
    p_exception(0, 'Ошибка! Отсутствует присоединенный документ.');
  end if;
  RESULT := 1;

end UDO_P_PAYACCIN_CHECK_APPROVE;
/
