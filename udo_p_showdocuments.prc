create or replace procedure UDO_P_SHOWDOCUMENTS
(
  nIN_IDENT            in number,   -- Идентификатор помеченых записей исходного раздела
  sSHOW_UNITCODE       in out varchar2, -- Отображаемый раздел
  nSHOW_IDENT          out number   -- Идентификатор помеченных записей отображаемых разделов
) is
/*
  Процедура для приложения "Перейти к документу"
  
 grant execute on UDO_P_SHOWDOCUMENTS to public;
*/

sIN_UNITCODE unitlist.unitcode%type; -- Раздел исходного документа
rUNIT unitlist%rowtype; -- Запись раздела
sTABLENAME unitlist.table_name%type;
sCOLUMN_PK varchar2(40);
sCOLUMN_DOC varchar2(40); -- Колонка таблицы раздела
sCOLUMN_UNIT varchar2(40); -- Колонка таблицы раздела
cTABLEQUERY clob;     -- Таблица/Подзапрос (для конструкции FROM)
cSUBQUERY   clob;     -- Подзапрос (для конструкции WHERE)
cSQL_TEXT clob := empty_clob();
type trDOCUMENT is record (
     UNITCODE   unitlist.unitcode%type,
     DOC_RN     number
     );
type ttDOCUMENT is table of trDOCUMENT;
tDOCUMENT ttDOCUMENT;
--
nSIGN_MASTER number;
sMASTER_UNIT PKG_STD.tSTRING;
nMASTER_DOC  number;
nTMP number;
begin

-- Определяем исходный раздел
begin
select distinct s.unitcode 
       into sIN_UNITCODE
       from selectlist s 
       where s.ident = nIN_IDENT;  
exception when NO_DATA_FOUND then
          p_exception(0, 'Нет данных для отображения.');
end;
--sIN_UNITCODE := 'CostDeliverySheets';

-- Считываем запись
P_UNITLIST_EXISTS(null, sIN_UNITCODE, rUNIT);

-- Идентификатор
nSHOW_IDENT := gen_ident;

-- Определяем параметры
if OBJECT_EXISTS('UDO_P_SHOWDOCUMENTS_USERPROC','PROCEDURE') <> 0 then
    execute immediate
    'begin UDO_P_SHOWDOCUMENTS_USERPROC(:sIN_UNITCODE, :sSHOW_UNITCODE, :cTABLEQUERY, :cSUBQUERY, :sCOLUMN_PK, :sCOLUMN_UNIT, :sCOLUMN_DOC, :nSIGN_MASTER); end;'
    using in sIN_UNITCODE, in sSHOW_UNITCODE,
          out cTABLEQUERY, out cSUBQUERY, out sCOLUMN_PK, out sCOLUMN_UNIT, out sCOLUMN_DOC, out nSIGN_MASTER;
end if;

-- Если таблица/запрос не определена, то считываем из параметров раздела
if cTABLEQUERY = empty_clob() then
   
    -- Определяем параметры формирования данных для открытия раздела
    sTABLENAME := rUNIT.Table_Name;

    if sTABLENAME is null then
          p_exception(0, 'Для раздела "%s" не указана таблица', sIN_UNITCODE);
    end if;

    cTABLEQUERY := sTABLENAME;

else
    cTABLEQUERY := '('|| cTABLEQUERY || ')';
end if;

if cSUBQUERY != empty_clob() then
  cSUBQUERY := '('|| cSUBQUERY || ')';
end if;   
   
-- определяем колонку первичного ключа
if sCOLUMN_PK is null then
    begin
    select r.COLUMN_NAME
           into sCOLUMN_PK
           from user_constraints  t,
                user_cons_columns r
           where t.TABLE_NAME = sTABLENAME
             and t.CONSTRAINT_TYPE = 'P' -- первичный ключ
             and r.CONSTRAINT_NAME = t.CONSTRAINT_NAME
             and r.TABLE_NAME = t.TABLE_NAME;
    exception when NO_DATA_FOUND then
                   sCOLUMN_PK := 'RN';
                   --p_exception(0, 'Первичный ключ для таблицы "%s" не найден.', sTABLENAME);
              when TOO_MANY_ROWS then null;
    end;

    if sCOLUMN_PK is null then return;
    end if;
end if;

-- Формируем текст запроса
if cSUBQUERY = empty_clob() then 
  if sCOLUMN_UNIT is not null then
      cSQL_TEXT := 'select distinct t.'|| sCOLUMN_UNIT ||' UNITCODE, t.'|| sCOLUMN_DOC ||' RN from selectlist s, '|| cTABLEQUERY ||' t where s.ident = :nIN_IDENT and t.'|| sCOLUMN_PK ||' = s.document';
  else
      cSQL_TEXT := 'select distinct '''|| sSHOW_UNITCODE ||''' UNITCODE, t.'|| sCOLUMN_DOC ||' RN from selectlist s, '|| cTABLEQUERY ||' t where s.ident = :nIN_IDENT and t.'|| sCOLUMN_PK ||' = s.document';
  end if;
else 
  if sCOLUMN_UNIT is not null then
      cSQL_TEXT := 'select distinct t.'|| sCOLUMN_UNIT ||' UNITCODE, t.'|| sCOLUMN_DOC ||' RN from selectlist s, '|| cTABLEQUERY ||' t where s.ident = :nIN_IDENT and t.'|| sCOLUMN_PK ||' in '|| cSUBQUERY ;
  else
      cSQL_TEXT := 'select distinct '''|| sSHOW_UNITCODE ||''' UNITCODE, t.'|| sCOLUMN_DOC ||' RN from selectlist s, '|| cTABLEQUERY ||' t where s.ident = :nIN_IDENT and t.'|| sCOLUMN_PK ||' in '|| cSUBQUERY ;
  end if;

end if;
--p_exception(0, cSQL_TEXT);

-- Получаем выборку
execute immediate cSQL_TEXT bulk collect into tDOCUMENT using nIN_IDENT;

-- Формируем данные для открытия раздела
if tDOCUMENT.Count > 0 then
  for indx in tDOCUMENT.First .. tDOCUMENT.Last
    loop
    sMASTER_UNIT := null;
    nMASTER_DOC := null;
    if nvl(nSIGN_MASTER,0) = 1 then
        UDO_P_GET_MASTERDOC(
           nFLAG_SMART          => 1,    -- признак генерации исключения (0 - да, 1 - нет)
           sUNITCODE            => tDOCUMENT(indx).UNITCODE,  -- Код раздела
           nDOCUMENT            => tDOCUMENT(indx).DOC_RN,    -- Рег. номер документа
           sMASTER_UNIT         => sMASTER_UNIT, -- Код мастер раздела
           nMASTER_DOC          => nMASTER_DOC    -- Рег. номер мастер документа
           );
    end if;
        
    -- Добавление в список
    P_SELECTLIST_INSERT(nSHOW_IDENT, nvl(nMASTER_DOC, tDOCUMENT(indx).DOC_RN), nvl(sMASTER_UNIT, tDOCUMENT(indx).UNITCODE), nTMP);
  end loop;
end if;

if sSHOW_UNITCODE is null then
    begin
    select distinct s.unitcode
           into sSHOW_UNITCODE
           from selectlist s
           where s.ident = nSHOW_IDENT;
    exception when NO_DATA_FOUND then 
                   p_exception(0,'Не удалось определить код отображаемого раздела.');
              when TOO_MANY_ROWS then 
                   p_exception(0,'Одновременное открытие разнородных документов недопустимо.');
    end;
end if;

end UDO_P_SHOWDOCUMENTS;
/

