create or replace procedure UDO_P_STAGES_ACC_KIND
(
  nCOMPANY  in number,
  nACC_KIND out number
) as
 /*
   17/11/2022 Марков МВ. Хохряков А.В.
   Пользовательские пересчеты.
   Договор (этапы)
   Указать тип л/с для определенных пользователей
 */
 nCatalog  USERLIST.CRN%type; -- Подразделение пользователя
begin

  begin
    select t.cRN into nCatalog from USERLIST t where t.authid = utilizer;
  exception
    when NO_DATA_FOUND then nCatalog := 0;
  end;

  if nCatalog in (7553331, 7595112, 7614765, 7629012, 7168915, 7551160, 8021744, 7390528) then 
       nACC_KIND := 0; -- Закупка у: ВЭД, ОМТС, Кооперация, Сертификация, Служба IT, Служба ГИ, Управделами, Юридический
  else nACC_KIND := 1; -- Продажа (по-умолчанию)
  end if;

end;
/

