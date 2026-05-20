create or replace procedure UDO_REP_UPDATELIST_CHANGE(
  nCOMPANY  in number,     -- Организация
  sUser     in varchar2,   -- Пользователь
  sRazd     in varchar2,   -- Раздел в котором поработал
--  sDates    in varchar2  -- интервал времени
  dDATEBGN  in date,       -- дата с
  dDATEEND  in date,       -- дата по
  nADD      in numeric,    -- Добавленное
  nUPD      in numeric,    -- Измененное
  nDEL      in numeric,    -- Удаленное
  nTotal    in numeric     -- Обобщение
) is
----Переменные отчета "Активность сотрудника"
  C_SLIST    constant PKG_STD.TSTRING := 'Лист1'; -- Лист
  C_sUser    constant PKG_STD.TSTRING := 'sUser';
  C_dDate    constant PKG_STD.TSTRING := 'dDate';

  LL_LINE    constant PKG_STD.TSTRING := 'L_Line';
  C_nPP      constant PKG_STD.TSTRING := 'nPP';
  C_sRazd    constant PKG_STD.TSTRING := 'sRazd';
  C_nRN      constant PKG_STD.TSTRING := 'nRN';
  C_sAct     constant PKG_STD.TSTRING := 'sAct';
  C_sDate    constant PKG_STD.TSTRING := 'sDate';
  C_sNote    constant PKG_STD.TSTRING := 'sNote';

  nSTR         number;
  nPP          number := 0;
  sNote        varchar2(1024) := '';
  dDate        varchar2(64) := null;
  nRN          number := 0;

begin
  ---Инициализация
  -- Готовим шаблон
  PRSG_EXCEL.PREPARE;

  -- Установка текущего рабочего листа
  PRSG_EXCEL.SHEET_SELECT(C_SLIST);

  PRSG_EXCEL.CELL_DESCRIBE(C_sUser);
  PRSG_EXCEL.CELL_DESCRIBE(C_dDate);

  -- Описываем строки и ячейки спецификации 
  PRSG_EXCEL.LINE_DESCRIBE(LL_LINE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nPP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sRazd);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_nRN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sAct);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sDate);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(LL_LINE, C_sNote);

  PRSG_EXCEL.CELL_VALUE_WRITE(C_sUser, sUser);
  PRSG_EXCEL.CELL_VALUE_WRITE(C_dDate, 'С ' || to_char(dDATEBGN, 'DD.MM.YYYY') || ' по ' || to_char(dDATEEND, 'DD.MM.YYYY'));

--p_exception(0,sRazd);
  if 0 = nTotal then
  for ss in(
    select UA.tablern, to_char(UA.modifdate, 'DD.MM.YYYY HH:MM:SS') modifdate, UA.note, 
           trim(UA.TABLENAME) TABLENAME,
           cast(F_UPDATELIST_OPER_TYPE(UA.OPERATION) as varchar2(20)) sOper,
           (select trim(TB.TABLENOTE) from TABLELIST TB where TB.TABLENAME = UA.TABLENAME) sTableName
      from UPDATELIST_ARC UA
     where ua.Company = nCOMPANY and UA.AUTHID = sUser
       and UA.MODIFDATE between dDATEBGN and dDATEEND+1
       and ((ua.operation = 'I' and 1 = nADD)
         or (ua.operation = 'U' and 1 = nUPD)
         or (ua.operation = 'D' and 1 = nDEL))
     union all
    select U.tablern, to_char(U.modifdate, 'DD.MM.YYYY HH:MM:SS') modifdate, U.note, 
           trim(U.TABLENAME) TABLENAME, 
           cast(F_UPDATELIST_OPER_TYPE(U.OPERATION) as varchar2(20)) sOper,
           (select trim(TB.TABLENOTE) from TABLELIST TB where TB.TABLENAME = U.TABLENAME) sTableName
      from UPDATELIST U 
     where u.Company = nCOMPANY and U.AUTHID = sUser
       and U.MODIFDATE between dDATEBGN and dDATEEND+1 --'14-SEP-22' and '16-SEP-22'
       and ((u.operation = 'I' and 1 = nADD)
         or (u.operation = 'U' and 1 = nUPD)
         or (u.operation = 'D' and 1 = nDEL))
      order by sTableName, modifdate 
    ) loop
      sNote := '---';
      begin
        
        if ss.TABLENAME = 'FCPRODLST' then
          select t.name into sNote from FCMATRESOURCE t, FCPRODLST p where p.rn = ss.tablern and p.mtr_res = t.rn;
        elsif ss.TABLENAME = 'FCROUTLST' then
          select 'Техпаспорт '||trim(t.docpref) ||'-'||trim(t.docnumb) into sNote from FCROUTLST t where t.rn = ss.tablern;
        elsif ss.TABLENAME = 'DICNOMNS' then
          select t.nomen_name into sNote from DICNOMNS t where t.rn = ss.tablern;
        elsif ss.TABLENAME = 'FCMATRESOURCE' then
          select t.name into sNote from FCMATRESOURCE t where t.rn = ss.tablern;
        elsif ss.TABLENAME = 'DEPARTMENTORD' then
          select 'Заказ '||trim(t.ord_pref) ||'-'||trim(t.ord_numb) into sNote from DEPARTMENTORD t where t.rn = ss.tablern;
        elsif ss.TABLENAME = 'PRODUCTORD' then
          select 'Заказ '||trim(t.ord_pref) ||'-'||trim(t.ord_numb) into sNote from PRODUCTORD t where t.rn = ss.tablern;
        elsif ss.TABLENAME = 'PRODUCTORDS' then
          select t.nomen_name into sNote from DICNOMNS t, PRODUCTORDS ord where ord.rn = ss.tablern and ord.nomen = t.rn;
        else sNote := ss.note;
        end if;
      exception
        when NO_DATA_FOUND 
          then sNote := ss.note;
      end;

      if dDate is not NULL and dDate != ss.modifdate and nRN != ss.tablern then
        nPP := nPP + 1;
        nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,   0, nSTR, nPP);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sRazd, 0, nSTR, ss.sTableName);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nRN,   0, nSTR, ss.tablern);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sAct,  0, nSTR, ss.sOper);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate, 0, nSTR, ss.modifdate);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sNote, 0, nSTR, sNote);
      end if;
      nRN := ss.tablern;
      dDate := ss.modifdate;

  end loop;

  else -- Только количество операций

  for ss in (
    select sum(tt.nCount) as nCount, 
           trim(TB.TABLENOTE) TABLENOTE,
           F_UPDATELIST_OPER_TYPE(tt.OPERATION) sOper
      from (
          select count(ua.rn) as nCount, UA.OPERATION, trim(UA.TABLENAME) TABLENAME
            from UPDATELIST_ARC UA
           where ua.Company = nCOMPANY and UA.AUTHID = sUser
             and UA.MODIFDATE between dDATEBGN and dDATEEND+1
             and ((ua.operation = 'I' and 1 = nADD)
               or (ua.operation = 'U' and 1 = nUPD)
               or (ua.operation = 'D' and 1 = nDEL))
            group by TABLENAME, OPERATION 
          union all
          select count(u.rn) as nCount, U.OPERATION, trim(U.TABLENAME) TABLENAME
            from UPDATELIST U 
           where u.Company = nCOMPANY and U.AUTHID = sUser
             and U.MODIFDATE between dDATEBGN and dDATEEND+1
             and ((u.operation = 'I' and 1 = nADD)
               or (u.operation = 'U' and 1 = nUPD)
               or (u.operation = 'D' and 1 = nDEL))
            group by TABLENAME, OPERATION 
          ) tt,
           TABLELIST TB
     where TB.TABLENAME = tt.TABLENAME
     group by TABLENOTE, tt.OPERATION
     order by TABLENOTE, sOper 
    ) loop

        nPP := nPP + 1;
        nSTR := PRSG_EXCEL.LINE_CONTINUE(LL_LINE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nPP,   0, nSTR, nPP);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sRazd, 0, nSTR, ss.TABLENOTE);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_nRN,   0, nSTR, ss.nCount);
        PRSG_EXCEL.CELL_VALUE_WRITE(C_sAct,  0, nSTR, ss.sOper);
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_sDate, 0, nSTR, ss.modifdate);
        --PRSG_EXCEL.CELL_VALUE_WRITE(C_sNote, 0, nSTR, sNote);

  end loop;

  end if;
--select * from UDO_INTEMEH_INFDATA T where T.AUTHID = ‘MARANICHENKO_AP’;


  --удаляем технические строки
  PRSG_EXCEL.LINE_DELETE(LL_LINE);
      
end UDO_REP_UPDATELIST_CHANGE;
/

