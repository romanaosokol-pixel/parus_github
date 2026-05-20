create or replace procedure UDO_P_TRANSINVDEPT_CERT_FRM
(
  nRN      in number,
  sDOCTYPE out varchar2,
  sCRN     out varchar2,
  dDOCDATE out date,
  sAGENT   out varchar2,
  sSTORE_B out varchar2,
  sOPER_B  out varchar2
) as
  /*
    11/04/2023 Марков МВ.
    Расходные накладные на отпуск в подразделение
    Формировать сертификацию
    Инициализация формы.
  */
  nSTKIND number(17);
begin
  -- строка 
  begin
    select ST.STKIND,
           A.AGNABBR,
           TD.WORK_DATE
      into nSTKIND,
           sAGENT,
           dDOCDATE
      from TRANSINVDEPT TD,
           AZSAZSLISTMT ST,
           AGNLIST      A
     where TD.RN = nRN
       and TD.IN_STORE = ST.RN
       and ST.AGENT = A.RN;
  exception
    when no_data_found then
      p_exception(0, 'Не указан склад контрагента-сертификации.');
  end;
  --
  sCRN     := 'Сертификация';
  sDOCTYPE := 'СЕРТИФ';
  sSTORE_B := 'Изолятор брака';
  sOPER_B  := 'ПриходВнутр';
end;
/

