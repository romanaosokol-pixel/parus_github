create or replace procedure UDO_P_SHOWDOCUMENTS_USERPROC(
       sIN_UNITCODE         in varchar2,  -- Раздел документа
       sSHOW_UNITCODE       in varchar2,  -- Отображаемый раздел
       cTABLEQUERY          out clob,     -- Таблица/Подзапрос (для конструкции FROM)
       cSUBQUERY            out clob,     -- Подзапрос (для конструкции WHERE)
       sCOLUMN_PK           out varchar2, -- Поле первичного ключа таблицы/подзапроса
       sCOLUMN_UNIT         out varchar2, -- Поле содержащее код отображаемого раздела
       sCOLUMN_DOC          out varchar2, -- Поле содержащее рег.номер документа отображаемого раздела
       nSIGN_MASTER         out number    -- Преобразовывать в записи мастер раздела
       ) is
begin

cTABLEQUERY := empty_clob();
cSUBQUERY   := empty_clob();

-- Определяем колонку
case sIN_UNITCODE
     when 'Contracts' then
           if sSHOW_UNITCODE = 'FileLinks' then
              sCOLUMN_DOC := 'FILELINKS_PRN';
              sCOLUMN_PK := 'PRN';
              cTABLEQUERY := 'select u.filelinks_prn, t.prn from filelinksunits u inner join stages t on u.table_prn in (t.prn, t.rn)';
           end if;
     /*when 'P47DocumentsContract' then
          if sSHOW_UNITCODE = 'Contracts' then
              sCOLUMN_DOC := 'CONTRACT';
              sCOLUMN_PK := 'RN';
          end if;
     when 'P47DocumentsStorageDetail' then
           sCOLUMN_DOC := 'UNIT_RN';
           sCOLUMN_UNIT := 'UNITCODE';
           nSIGN_MASTER := 1;*/
     /* Вызов из раздела комплектовочные ведомости */
     when 'CostDeliverySheets' then 
        /* Отобразить заказы на производство */
        if sSHOW_UNITCODE = 'ProductionOrders' then
          cTABLEQUERY := 'PRODUCTORD';
          sCOLUMN_DOC := 'RN';
          sCOLUMN_PK := 'RN';
          
          cSUBQUERY := 'select column_value from table(UDO_FP_DELIVSH_PIPE_ORDER(s.document,0))';  
        /* Отобразить заказы подразделений */  
        elsif sSHOW_UNITCODE = 'DepartmentsOrders' then
          cTABLEQUERY := 'DEPARTMENTORD';
          sCOLUMN_DOC := 'RN';
          sCOLUMN_PK := 'RN';
          
          cSUBQUERY := 'select column_value from table(UDO_FP_DELIVSH_PIPE_ORDER(s.document,1))';  
        end if; 
     /* Вызов из раздела комплектовочные ведомости - места хранения  */
     when 'CostDeliverySheetsSpecCompletionSPGS' then  
       /* Отобразить РНОПодр */
        if sSHOW_UNITCODE = 'GoodsTransInvoicesToDepts' then
          cTABLEQUERY := 'TRANSINVDEPT'; 
          sCOLUMN_DOC := 'RN';
          sCOLUMN_PK := 'RN';
          
          cSUBQUERY := 'select dl.in_document as rn
                          from STRPLRESJRNL  M,
                               STPLGOODSSUPPLY sg,
                               doclinks        dl 
                         where sg.cell = m.cell
                           and sg.goodssupply = m.goodssupply
                           and sg.rn = s.document
                           and dl.in_unitcode  = ''GoodsTransInvoicesToDepts''
                           and dl.out_unitcode = ''StoragePlacesResJournal''
                           and dl.out_document = m.rn';  
        end if;
     /* Приходные партии товара */
     when 'GoodsParties' then
       /* Раздел для перехода */
       case sSHOW_UNITCODE 
         /* Присоединённые документы */
         when 'FileLinks' then
          sCOLUMN_DOC := 'FILELINKS_PRN';
          cTABLEQUERY := 'select t.rn, flu.filelinks_prn from filelinksunits flu, goodsparties t where flu.table_prn = t.rn';
         /* Номенклатор */
         when 'Nomenclator' then
          sCOLUMN_DOC := 'PRN';
          cTABLEQUERY := 'select t.rn, nm.prn from goodsparties t, nommodif nm where t.nommodif = nm.rn';
       else 
         null;
       end case;
else null;
end case;

end UDO_P_SHOWDOCUMENTS_USERPROC;
/
