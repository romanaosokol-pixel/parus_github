create or replace procedure UDO_P_TRANSINVDEPT_CHECK_WORK
(
  COMPANY           in number,         -- Рег. номер организации
  DOCUMENT          in number         -- Рег номер События
  --RESULT            out number         -- Результат
)
is
  NREZ              PKG_STD.tNUMBER;
begin
  -- Проверка наличия связей
  P_TRANSINVDEPT_BCHECK(nCOMPANY => COMPANY, nRN => DOCUMENT);

  select t.status 
    into NREZ
    from TRANSINVDEPT t 
   where t.RN = DOCUMENT;

  case NREZ
    --when 0 then RESULT := 1;
    when 1 then p_exception(0,'Расходная накладная с RN - "%s" должна иметь статус "Не отработана"',DOCUMENT);
  end case;
    
end UDO_P_TRANSINVDEPT_CHECK_WORK;
-- grant execute on UDO_P_TRANSINVDEPT_CHECK_WORK to public;
/

