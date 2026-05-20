create or replace procedure UDO_P_PAYACCINSP_DO_BINSERT
(
  nPRN                        in number,   -- Рег. номер специфкации ВСО
  sROWID_1C                   in varchar2, -- GUID записи 1С
  nQNT                        in number,   -- Количество 
  nRN                         out number   -- Рег. номер записи 
) is
  /*
    Процедура базового добавления в таблицу детализации спецификации ВСО по заявкам
  */
begin
  nRN := gen_id;
  
  insert into udo_payaccinspec_depord
    (rn, prn, rowid_1c, qnt)
  values
    (nRN, nPRN, sROWID_1C, nQNT); 

end UDO_P_PAYACCINSP_DO_BINSERT;
/

