create or replace procedure UDO_P_REMAINS_MOL_LOAD
(
  nCOMPANY         in number,        -- Организация
  nPROCESS         in number,        -- идентификатор процесса
  SMSG             out varchar2      -- RN загрузки
)
is
-- Автор  : ЦИТК Парус (Селиванов А.Е.)
-- Создан : 27.01.2023
-- Purpose : Загрузка в таблицу Oracle данных остатков по подотчетным лицам
-- User pack -- UDO_PKG_REMAINS_MOL_LOAD;
begin
 /* Загрузка данных в формате XML(Эксель) */
  UDO_PKG_REMAINS_MOL_LOAD.FILE_LOAD
  (
    nCOMPANY         => nCOMPANY,        -- Организация
    nPROCESS         => nPROCESS,        -- идентификатор процесса
    SMSG             => SMSG                -- RN загрузки
  );

end UDO_P_REMAINS_MOL_LOAD;
-- grant execute on UDO_P_REMAINS_MOL_LOAD to public;
/

