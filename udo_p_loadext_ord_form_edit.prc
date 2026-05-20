create or replace procedure UDO_P_LOADEXT_ORD_FORM_EDIT
(
  NCOMPANY                  in number,                -- Организация
  NRN                       in out number,            -- Регистрационный номер
  SATTRIB                   in varchar2,              -- Измененный атрибут
  NFIRST                    in out number,            -- Первое обращение
  NMODE                     in out number,            -- Действие (0 - добавление, 1 - размножение, 2 - исправление)
  SDOC_TYPE                 in out varchar2,          -- Значение атрибута "Тип документа"
  SDOC_PREF                 in out varchar2,          -- Значение атрибута "Префикс документа"
  SDOC_NUMB                 in out varchar2,          -- Значение атрибута "Номер документа"
  DDOC_DATE                 in out date,              -- Значение атрибута "Дата документа"
  SPRODUCT                  in out varchar2,          -- Значение атрибута "Изделие"
  SPRODUCT_NAME             in out varchar2           -- Значение атрибута "Наименование изделия"
)
/*
   Процедура для пересчета формы раздела "Загрузка заявки на закупку из внешних источников"
   grant execute on UDO_P_LOADEXT_ORD_FORM_EDIT to public;
*/
as

  /*Установка значений по умолчанию для вставки*/
  procedure INIT_INS
  (
    NCOMPANY           in number,     -- Организация
    SDOC_TYPE          out varchar2,  -- Значение атрибута "Тип документа"
    SDOC_PREF          out varchar2,  -- Значение атрибута "Префикс"
    SDOC_NUMB          out varchar2,  -- Значение атрибута "Номер"
    DDOC_DATE          out varchar2   -- Значение атрибута "Дата"
  )
   is
    DDATE              date := trunc(sysdate); -- Текущая дата
  begin
    /* Дата ведомости */
    DDOC_DATE := DDATE;

    /* Тип документа */
    SDOC_TYPE := 'Заявка';

    /* Префикс */
    SDOC_PREF := to_char(d_year(DDOC_DATE)); --GET_OPTIONS_STR(SCODE => 'UdoWdDistib_Pref', NCOMP_VERS => NCOMPANY);

    /* Номер */
    UDO_P_LOADEXT_ORD_GETNEXTNUMB(nCOMPANY  => nCOMPANY,
                                  SDOC_TYPE => SDOC_TYPE,
                                  sPREF     => SDOC_PREF,
                                  sNUMB     => SDOC_NUMB);
  end;

begin
  /* Исправление атрибута "Подразделение "*/
  if SATTRIB = 'SPRODUCT' or  (NMODE = 2 and NFIRST = 1)  then
     if SPRODUCT is null then
       SPRODUCT_NAME    := null;
     else
       begin
         select mr.name
           into SPRODUCT_NAME
           from fcmatresource mr
          where mr.company = NCOMPANY
            and mr.code    = SPRODUCT
            and rownum     = 1;
       exception when no_data_found then
         SPRODUCT_NAME := null;
       end;
     end if;
  end if;

  /* добавление/размножение */
  if NMODE in (0, 1) then

    /* установка действия размножение */
    if NRN is not null then
      NMODE := 1;

      /* Номер */
      UDO_P_LOADEXT_ORD_GETNEXTNUMB(nCOMPANY  => nCOMPANY,
                                    SDOC_TYPE => SDOC_TYPE,
                                    sPREF     => SDOC_PREF,
                                    sNUMB     => SDOC_NUMB);
    else
      if NFIRST = 1 then
        /*Установка значений по умолчанию*/
        INIT_INS(NCOMPANY  => NCOMPANY,
                 SDOC_TYPE => SDOC_TYPE,
                 SDOC_PREF => SDOC_PREF,
                 SDOC_NUMB => SDOC_NUMB,
                 DDOC_DATE => DDOC_DATE);
        NFIRST := 0;
      end if;
    end if;

    /* исправление */
  elsif NMODE = 2 then
     NFIRST := 0;
  end if;
end;
/

