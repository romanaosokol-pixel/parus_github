create or replace procedure UDO_P_PAIN_UNITSTMOD_SEDN
(
  COMPANY           in number,         -- Рег. номер организации
  DOCUMENT          in number,         -- Рег номер События
  RESULT            out number         -- Результат
)
is
  NREZ              PKG_STD.tNUMBER;
begin
  if (utilizer <> 'KHOK' ) then -- чтобы не отправлять письма на согласование повторно.
  UDO_P_PAIN_UNITSTMOD_SED_MAIL(NCOMPANY => COMPANY,
                                NDOCUMENT => DOCUMENT,
                                nRESULT => NREZ);
  case NREZ
    when 0 then
    RESULT := 1;
    when 1 then
      p_exception(0,'По событию с RN - "%s" не получилось определить ВСО',DOCUMENT);
    when 2 then
      p_exception(0,'По событию с RN - "%s" найдено несколько ВСО',DOCUMENT);
    when 3 then
      p_exception(0,'При отправке e-mail по событию с RN - "%s" произошла ошибка',DOCUMENT);
    else
      p_exception(0,'При отправке e-mail по событию с RN - "%s произошла невредвиденная ошибка',DOCUMENT);
  end case;
  end if;
end;
-- grant execute on UDO_P_PAIN_UNITSTMOD_SEDN to public;
/

