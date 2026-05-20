create or replace procedure UDO_P_TRANSINVDEPT_INDEP
(
  NIDENT   in number,
  NCOMPANY in number
)
  /*Пользователский отчет "Накладная на перемещение. Форма ТОРГ-13" для раздела 
  "Расходные накладные на отпуск в подразделения"*/
 is
  --Лист
  LIST1  constant PKG_STD.TSTRING := 'TDSheet';
  CELL1  constant PKG_STD.TSTRING := 'cell1';
  CELL2  constant PKG_STD.TSTRING := 'cell2';
  CELL3  constant PKG_STD.TSTRING := 'cell3';
  CELL4  constant PKG_STD.TSTRING := 'cell4';
  CELL5D constant PKG_STD.TSTRING := 'cell5_d';
  CELL5  constant PKG_STD.TSTRING := 'cell5';
  CELL6D constant PKG_STD.TSTRING := 'cell6_d';
  CELL6  constant PKG_STD.TSTRING := 'cell6';

  -- Строка
  LINE1 constant PKG_STD.TSTRING := 'line1';
  ILINE_IDX integer;

  -- Ячейки строки
  CELL1_1 constant PKG_STD.TSTRING := 'cell1_1';
  CELL1_2 constant PKG_STD.TSTRING := 'cell1_2';
  CELL1_3 constant PKG_STD.TSTRING := 'cell1_3';
  CELL1_4 constant PKG_STD.TSTRING := 'cell1_4';
  CELL1_5 constant PKG_STD.TSTRING := 'cell1_5';
  CELL1_6 constant PKG_STD.TSTRING := 'cell1_6';
  CELL1_7 constant PKG_STD.TSTRING := 'cell1_7';

  -- Переменные
/*  SDOCNUMB varchar2(1024);
  SDOCDATE varchar2(20);
  SDEP_OUT varchar2(1024);
  SDEP_IN  varchar2(1024);
  SAUTHOR  AGNLIST.AGNABBR%type;
  SMOL_IN  varchar2(40);*/

begin
  --1. Описание
  PRSG_EXCEL.PREPARE;

  -- 1.1 Описание листа
  PRSG_EXCEL.SHEET_SELECT(SSHEET_NAME => LIST1);

  -- 1.2 Описание ячеек параметров
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => CELL1);
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => CELL2);
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => CELL3);
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => CELL4);
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => CELL5D);
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => CELL5);
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => CELL6D);
  PRSG_EXCEL.CELL_DESCRIBE(SCELL_NAME => CELL6);

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

  -- 2. Наполнение отчета
  -- 2.1. Заголовок документа
  for rec in (
    select trim(DP.DOCCODE) || ', ' || trim(TID.PREF) || '-' || trim(TID.NUMB) SDOCNUMB,
           trim(TO_CHAR(TID.DOCDATE, 'dd.mm.yyyy')) SDOCDATE,
           AL.AZS_NAME SDEP_OUT,
           UDO_TRANSINVDEPT_MOLORSTORE(NRN => TID.RN) SDEP_IN, -- Функция по определнию склада получателя
           ag1.agnabbr abbr_in, ag1.emppost post_in,
           ag2.agnabbr abbr_out, ag2.emppost post_out
      from SELECTLIST   S,
           TRANSINVDEPT TID,
           DOCTYPES     DP,
           AZSAZSLISTMT AL,
           AGNLIST ag1,
           AGNLIST ag2
     where TID.COMPANY = NCOMPANY
       and S.DOCUMENT = TID.RN
       and S.IDENT = NIDENT
       and TID.DOCTYPE = DP.RN
       and TID.STORE = AL.RN
       and ag1.RN = TID.IN_MOL
       and ag2.RN = TID.MOL
    ) loop
  --2.1.1. Автор документа
/*  begin
    select A.AGNABBR
      into SAUTHOR
      from USERLIST   U,
           CLNPERSONS P,
           AGNLIST    A
     where U.AUTHID = P.PERS_AUTHID
       and P.PERS_AGENT = A.RN
       and U.AUTHID = user; --текущий пользователь системы
  exception
    when NO_DATA_FOUND then
      SAUTHOR := null;
  end;*/

    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => CELL1,  SCELL_VALUE => rec.SDOCNUMB);
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => CELL2,  SCELL_VALUE => rec.SDOCDATE);
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => CELL3,  SCELL_VALUE => rec.SDEP_OUT);
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => CELL4,  SCELL_VALUE => rec.SDEP_IN);
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => CELL5D, SCELL_VALUE => rec.post_out);
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => CELL5,  SCELL_VALUE => rec.abbr_out);
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => CELL6D, SCELL_VALUE => rec.post_in);
    PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME => CELL6,  SCELL_VALUE => rec.abbr_in);

    --2.2. Заполнение таблицы
    for CUR in (select N.NOMEN_NAME || ', ' || M.MODIF_NAME || CHR(13) || '(' ||
                       UDO_F_TRINVDEPSPECS_SERNUMB(NRN => TSP.RN) || ')' as PROD,
                       UDO_F_RLARTICLES_MNF_NUMB(TSP.ARTICLE)            as SMNF_NUMB,
                       DM.MEAS_MNEMO,
                       DM.CODE_OKEI,
                       TSP.QUANT,
                       UDO_F_FCDELIVERYLIST_PROJ(NRN => T.FACEACC) as TEMA, --функция для определения темы проекта по лицевому счету
                       F.NUMB
                  from SELECTLIST        S,
                       TRANSINVDEPT      T,
                       TRANSINVDEPTSPECS TSP,
                       NOMMODIF          M,
                       DICNOMNS          N,
                       DICMUNTS          DM,
                       FACEACC           F
                 where T.COMPANY = NCOMPANY
                   and S.DOCUMENT = T.RN
                   and S.IDENT = NIDENT
                   and T.RN = TSP.PRN
                   and TSP.NOMMODIF = M.RN
                   and M.PRN = N.RN
                   and T.FACEACC = F.RN(+)
                   and N.UMEAS_MAIN = DM.RN(+)
                   order by n.nomen_name, UDO_F_RLARTICLES_MNF_NUMB(TSP.ARTICLE) 
    ) loop
      ILINE_IDX := PRSG_EXCEL.LINE_APPEND(SLINE_NAME => LINE1);
    
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_1,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  SCELL_VALUE   => CUR.PROD);
    
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_2,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  SCELL_VALUE   => CUR.MEAS_MNEMO);
    
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_3,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  SCELL_VALUE   => CUR.CODE_OKEI);
    
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_4,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  NCELL_VALUE   => CUR.QUANT);
    
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_5,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  SCELL_VALUE   => CUR.TEMA);
    
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_6,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  SCELL_VALUE   => CUR.NUMB);
                                  
      PRSG_EXCEL.CELL_VALUE_WRITE(SCELL_NAME    => CELL1_7,
                                  ICELL_INDEX_X => 0,
                                  ICELL_INDEX_Y => ILINE_IDX,
                                  SCELL_VALUE   => CUR.SMNF_NUMB);
    end loop;
  end loop;

  -- 3. Подчистка шаблона
  PRSG_EXCEL.LINE_DELETE(SLINE_NAME => LINE1);

  if NVL(ILINE_IDX, 0) = 0 then
    P_EXCEPTION(0, 'Данных для отчета не найдено.');
  end if;

end UDO_P_TRANSINVDEPT_INDEP;
/

