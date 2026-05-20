create or replace procedure UDO_REP_TRANSINVDEPT_OTK
(
  NIDENT   in number,
  NCOMPANY in number
  
  
) is

  /*Отчет "Карта контроля" для раздела "Расходные накладные на отпуск в подразделения*/

  /*  --Лист
  LIST1 constant PKG_STD.tSTRING := 'TDSheet';*/

  --Ячейки листа
  CELL1 constant PKG_STD.TSTRING := 'cell1';
  CELL2 constant PKG_STD.TSTRING := 'cell2';
  CELL3 constant PKG_STD.TSTRING := 'cell3';
  CELL4 constant PKG_STD.TSTRING := 'cell4';

  -- Строка
  LINE1 constant PKG_STD.TSTRING := 'line1';
  ILINE_IDX integer;

  -- Ячейки строки
  CELL1_1  constant PKG_STD.TSTRING := 'cell1_1';
  CELL1_2  constant PKG_STD.TSTRING := 'cell1_2';
  CELL1_3  constant PKG_STD.TSTRING := 'cell1_3';
  CELL1_4  constant PKG_STD.TSTRING := 'cell1_4';
  CELL1_5  constant PKG_STD.TSTRING := 'cell1_5';
  CELL1_6  constant PKG_STD.TSTRING := 'cell1_6';
  CELL1_7  constant PKG_STD.TSTRING := 'cell1_7';
  CELL1_8  constant PKG_STD.TSTRING := 'cell1_8';
  CELL1_9  constant PKG_STD.TSTRING := 'cell1_9';
  CELL1_10 constant PKG_STD.TSTRING := 'cell1_10';
  CELL1_11 constant PKG_STD.TSTRING := 'cell1_11';
  CELL1_12 constant PKG_STD.TSTRING := 'cell1_12';
  CELL1_13 constant PKG_STD.TSTRING := 'cell1_13';
  CELL1_14 constant PKG_STD.TSTRING := 'cell1_14';
  CELL1_15 constant PKG_STD.TSTRING := 'cell1_15';

  -- Переменные
  /*  SDOCUMENT varchar2(240);*/
  SDOCNUMB   varchar2(240);
  SDOCDATE   varchar2(240);
  SPROD      varchar2(240);
  SNUMB      varchar2(240);
  STEMA      varchar2(240);
  SORDER     varchar2(240);
  SVALUE     varchar2(240);
  NNUMB      integer;
  SSHEETNAME varchar2(240);

begin

  --1. Описание
  PRSG_EXCEL.PREPARE;


  -- 2. Наполнение отчета
  -- 2.1. Заголовок документа
  for REC in (select T.RN,
                     trim(T.PREF) || '-' || trim(T.NUMB) as SDOCNUMB,
                     TO_CHAR(T.DOCDATE, 'dd.mm.yyyy') as SDOCDATE,
                     UDO_F_TRANSINVDEPT_MAIN_PROD(NRN => T.RN) as SPROD,
                     UDO_F_TRANSINVDEPT_MAIN_NUMB(NRN => T.RN) as SNUMB,
                     /*UDO_F_FCDELIVERYLIST_PROJ(nRN => T.FACEACC)||'/'||*/
                     GET_FACEACC_NUMB_ID(1, T.FACEACC) as STEMA,
                     UDO_F_INVDEPT_DEPORD(NRN => T.RN) as SORDER
              
                from SELECTLIST   S,
                     TRANSINVDEPT T
               where S.IDENT = NIDENT
                 and S.DOCUMENT = T.RN
                 and T.COMPANY = NCOMPANY)
  loop
    NNUMB      := 1;
    SSHEETNAME := REC.SDOCNUMB;
  
    PRSG_EXCEL.SHEET_COPY(SSHEET_NAME_FROM   => 'TDSheet',
                          SSHEET_NAME_TO     => SSHEETNAME,
                          SSHEET_NAME_BEFORE => null,
                          NMOVE_TO_END       => 1);
    -- 1.1 Описание листа
  
    PRSG_EXCEL.SHEET_SELECT(SSHEET_NAME => SSHEETNAME);
  
    -- 1.2 Описание ячеек параметров
    PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => CELL1);
    PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => CELL2);
    PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => CELL3);
    PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => CELL4);
  
    -- 1.3 Описание строки
    PRSG_EXCEL.LINE_DESCRIBE(SLINE_NAME => LINE1);
  
    -- 1.4 Описание ячеек строки
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_1);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_2);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_3);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_4);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_5);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_6);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_7);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_8);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_9);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_10);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_11);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_12);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_13);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_14);
    PRSG_EXCEL.LINE_CELL_DESCRIBE(SLINE_NAME => LINE1, SCELL_NAME => CELL1_15);
  
  
  
  
    if REC.SNUMB is not null then
      if INSTR(REC.SPROD, '(000') > 0 then
        SVALUE := SUBSTR(REC.SPROD, 0, INSTR(REC.SPROD, '(000')) || 'зав.№ ' || REC.SNUMB || ')';
      else
        SVALUE := REC.SPROD || ' (зав.№' || REC.SNUMB || ')';
      end if;
    else
      SVALUE := REC.SPROD;
    end if;
  
  
  
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => CELL1, SCELL_VALUE => SVALUE);
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => CELL2, SCELL_VALUE => REC.SDOCNUMB || ' от ' || REC.SDOCDATE);
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => CELL3, SCELL_VALUE => REC.STEMA);
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => CELL4, SCELL_VALUE => REC.SORDER);
  
    --2.2. Заполнение таблицы
    for CUR in (select N.NOMEN_NAME || ', ' || M.MODIF_NAME as MOMEN,
                       UDO_PKG_TRINVDEPSPECS_PROPS.SERNUMBER(NRN => TSP.RN) as SERIA,
                       TSP.QUANT,
                       UDO_PKG_TRINVDEPSPECS_PROPS.PARTY(NRN => TSP.RN) as PARTY,
                       UDO_PKG_TRINVDEPSPECS_PROPS.PRODUCER(NRN => TSP.RN) as PRODUCER,
                       UDO_F_TRINDEPTSPECS_PROVDATE(NRN => TSP.RN) as PROD_DATE
                
                
                  from TRANSINVDEPTSPECS TSP,
                       NOMMODIF          M,
                       DICNOMNS          N
                
                 where REC.RN = TSP.PRN
                   and TSP.NOMMODIF = M.RN
                   and M.PRN = N.RN)
    
    loop
    
      ILINE_IDX := PRSG_EXCEL.LINE_APPEND(SLINE_NAME => LINE1);
    
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_1,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  NCELL_VALUE   => NNUMB);
    
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_2,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  SCELL_VALUE   => CUR.MOMEN);
    
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_3,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  SCELL_VALUE   => CUR.SERIA);
      /* ***/
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_4,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  NCELL_VALUE   => CUR.QUANT);
    
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_5,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  SCELL_VALUE   => CUR.PRODUCER);
    
    
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_6,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  SCELL_VALUE   => CUR.PARTY);
    
    
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_7,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  SCELL_VALUE   => CUR.PROD_DATE);
    
      NNUMB := NNUMB + 1;
    
    end loop;
  
    -- 3. Подчистка шаблона
    PRSG_EXCEL.LINE_DELETE(SLINE_NAME => LINE1);
  
  end loop;

  PRSG_EXCEL.SHEET_DELETE('TDSheet');

  /*  if NVL(ILINE_IDX, 0) = 0 then
    P_EXCEPTION(0, 'Данных для отчета не найдено.');
  end if;*/

end UDO_REP_TRANSINVDEPT_OTK;
/

