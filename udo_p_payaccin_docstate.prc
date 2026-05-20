create or replace procedure UDO_P_PAYACCIN_DOCSTATE
(
  NCOMPANY  in number, -- рег. номер организации
  SUNITCODE in varchar2,
  NDOCUMENT in number, -- рег. номер ВСО
  SUNITFUNC in varchar2
) is

  NDOCSTATE PAYACCIN.DOC_STATE%type;
  NRN constant number(17) := NDOCUMENT;

begin

  select P.DOC_STATE
    into NDOCSTATE
    from PAYACCIN P
   where P.RN = NRN
     and P.COMPANY = NCOMPANY;

  if NDOCSTATE = 0 then
    P_EXCEPTION(0, 'Счет должен быть утвержден!');
  end if;

exception
  when NO_DATA_FOUND then
    return;
  


end;
/

