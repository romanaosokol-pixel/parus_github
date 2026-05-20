CREATE OR REPLACE PROCEDURE udo_pr_projects_cashflow_xls
(
	ncompany          IN NUMBER,
	nident            IN NUMBER,
	ddate_fr          IN DATE,
	ddate_to          IN DATE,
	speriod_type      IN VARCHAR2,
  ncontract_data    IN NUMBER,
	sfinstate         IN VARCHAR2,
	scurrency         IN VARCHAR2
)
IS
  /* ТИПЫ */
  -- период отчета
  TYPE  trperiod IS RECORD( sname         VARCHAR2(200),   -- наименование периода
                            ncol          NUMBER(17),      -- колонка хранения периода
                            ddate_fr      DATE,            -- дата начала периода
                            ddate_to      DATE             -- дата окончания периода
                          );
  type ttperiods is table of trperiod;                     -- коллекция периодов отчета
  
	--строка отчета
	TYPE trrpt_line IS RECORD( rperiod        trperiod,      -- период показателя
		                         nincome        NUMBER(17,2),  -- поступления
                             npayment       NUMBER(17,2),  -- выплаты
		                         ncashflow      NUMBER(17,2)   -- Cahs Flow
		                       );
	TYPE ttrpt_lines IS TABLE OF trrpt_line;                 -- коллекция строк отчета
  
  /* ПЕРЕМЕННЫЕ */
  rfst          finstate%ROWTYPE;
  tperiods      ttperiods := ttperiods();      -- таблица периодов отчета
  trpt_lines    ttrpt_lines := ttrpt_lines();  -- таблица строк отчета
  ncurrent_line NUMBER;                        -- очередной номер строки отчета
  srpt_head     VARCHAR2(4000);                -- заголовок отчета
  nfinstate     NUMBER(1);                     -- состояние показателей (0 - факт, 1 - план)
  ncurrent_sum  pkg_std.tsumm:=0;
	ncurrency pkg_std.tref;  
  nRRR     pkg_std.tREF;
  ncurrent_cf   pkg_std.tsumm:=0;
BEGIN
  /* ПОДГОТОВКА ДАННЫХ */
  -- валюта
  find_currency_iso(0, ncompany, scurrency, ncurrency);
	--определим числовое представление состояния показателей (0 - факт, 1 - план)
  find_finstate_params(1, ncompany, sfinstate, rfst.type, rfst.per_relate, rfst.rn);
	nfinstate := 1 - rfst.type;
	--сформируем заголовок  
	srpt_head := 'Cash Flow проекту ';
  
	--строим список периодов
  DECLARE
    dcurrent_fr   DATE;               -- текущая дата "c"
    dcurrent_to   DATE;               -- текущая дата "по"
    nperiod_cnt   NUMBER(17) := 0;    -- счетчик периодов
    scurrent_name VARCHAR2(200);      -- текущее наименование периода
  BEGIN
		dcurrent_to := ddate_fr - 1;
		LOOP
			dcurrent_fr := dcurrent_to + 1;
			nperiod_cnt      := nperiod_cnt + 1;
			CASE speriod_type
				WHEN 'Год' THEN
					dcurrent_to   := add_months(dcurrent_fr, 12) - 1;
					scurrent_name := to_char(dcurrent_fr, 'yyyy');
				WHEN 'Квартал' THEN
					dcurrent_to   := add_months(dcurrent_fr, 3) - 1;
					scurrent_name := 'Квартал ' || scurrent_name;
				WHEN 'Месяц' THEN
					dcurrent_to   := add_months(dcurrent_fr, 1) - 1;
					scurrent_name := f_smonth_base(nvalue => extract(MONTH FROM dcurrent_fr)) || ' ' || to_char(dcurrent_fr, 'yyyy') || ' г.';
				WHEN 'Декада' THEN
					dcurrent_to   := dcurrent_fr + 10;
					scurrent_name := 'Декада ' || scurrent_name;
				WHEN 'Неделя' THEN
					dcurrent_to   := dcurrent_fr + 7;
					scurrent_name := 'Неделя ' || scurrent_name;
				WHEN 'День' THEN
					dcurrent_to   := dcurrent_fr;
					scurrent_name := to_char(dcurrent_fr, 'dd.mm.yyyy');
				ELSE
					p_exception(0, 'Группировка "%s" не поддерживается!', nvl(speriod_type, 'Не указана'));
			END CASE;
			tperiods.extend;
			tperiods(tperiods.last).sname    := scurrent_name;
			tperiods(tperiods.last).ddate_fr := dcurrent_fr;
			tperiods(tperiods.last).ddate_to := dcurrent_to;
			EXIT WHEN dcurrent_to + 1 >= ddate_to;
		END LOOP;
	END;
  
  --готовим данные по периодам (если они есть)
  IF ((tperiods IS NOT NULL) AND (tperiods.count > 0))
  THEN
    FOR i IN tperiods.first .. tperiods.last
    LOOP
      trpt_lines.extend;
      trpt_lines(trpt_lines.last).rperiod  := tperiods(i);
      trpt_lines(trpt_lines.last).nincome  := 0;
      trpt_lines(trpt_lines.last).npayment := 0;
      trpt_lines(i).nincome   := 0;
      trpt_lines(i).npayment  := 0;
      trpt_lines(i).ncashflow := 0;
      
      FOR cstg IN (SELECT ps.rn, ps.faceacccust
                    FROM project p
                         JOIN  projectstage ps ON p.rn = ps.prn
                   WHERE p.company = ncompany AND
                         p.rn IN (SELECT sl.document FROM selectlist sl WHERE sl.ident = nident /*AND sl.company = ncompany*/) AND
                         p.curnames = ncurrency AND
                       ( ps.begplan <= ddate_to and       ---EZST Изменил Период действия этапа проекта 
                         ps.endplan >= ddate_fr  )
                   )
      LOOP  
        IF ncontract_data = 0 -- план/факт
        THEN
          -- поступления
          SELECT nvl(SUM (pn.pay_sum), 0)
            INTO ncurrent_sum
            FROM paynotes pn
                 JOIN dictoper fop ON pn.Finoper = fop.rn AND fop.typoper_direct = 0 /* приход */
           WHERE pn.faceacc  = cstg.faceacccust AND
                 pn.signplan = nfinstate AND
                 pn.pay_date BETWEEN trpt_lines(i).rperiod.ddate_fr AND trpt_lines(i).rperiod.ddate_to;
          trpt_lines(i).nincome  := trpt_lines(i).nincome + ncurrent_sum;
          ncurrent_sum := 0;
          -- оплаты
          SELECT nvl(SUM (pn.pay_sum), 0)
            INTO ncurrent_sum
            FROM projectstagepf psp
                 JOIN paynotes pn ON psp.faceacc = pn.faceacc AND
                                     pn.signplan = nfinstate AND
                                     pn.pay_date BETWEEN trpt_lines(i).rperiod.ddate_fr AND trpt_lines(i).rperiod.ddate_to
                      JOIN dictoper fop ON pn.Finoper = fop.rn AND fop.typoper_direct = 1 /* расход */
           WHERE psp.prn = cstg.rn;
          trpt_lines(i).npayment := trpt_lines(i).npayment - ncurrent_sum;
          ncurrent_sum := 0;
        ELSE -- по договору
          -- поступления
          SELECT nvl(SUM (pn.pay_sum), 0)
            INTO ncurrent_sum
            FROM fcacpayplans pn
           WHERE pn.prn  = cstg.faceacccust AND
                 pn.inexp_sign = 0 AND/* приход */
                 pn.end_date BETWEEN trpt_lines(i).rperiod.ddate_fr AND trpt_lines(i).rperiod.ddate_to;
          trpt_lines(i).nincome  := trpt_lines(i).nincome + ncurrent_sum;
          pkg_trace.REGISTER(trpt_lines(i).rperiod.ddate_fr||' '||trpt_lines(i).rperiod.ddate_to||' '||ncurrent_sum);
          ncurrent_sum := 0;
          
          -- оплаты
          SELECT nvl(SUM (pn.pay_sum), 0)
            INTO ncurrent_sum
            FROM projectstagepf psp
                 JOIN fcacpayplans pn ON psp.faceacc = pn.prn AND
                                         pn.inexp_sign = 1 /* расход */ AND
                                         pn.end_date BETWEEN trpt_lines(i).rperiod.ddate_fr AND trpt_lines(i).rperiod.ddate_to
           WHERE psp.prn = cstg.rn;
          trpt_lines(i).npayment := trpt_lines(i).npayment - ncurrent_sum;
          ncurrent_sum := 0;
        END IF;        
          
        -- cash-flow
        trpt_lines(i).ncashflow := (trpt_lines(i).nincome + trpt_lines(i).npayment);
      END LOOP;
      trpt_lines(i).ncashflow := trpt_lines(i).ncashflow + ncurrent_cf;
      ncurrent_cf := trpt_lines(i).ncashflow;
    END LOOP;
  ELSE
    p_exception(0, 'Не найдено данных для формирования отчета!');
  END IF;
  /* ПЕЧАТЬ ОТЧЕТА */
  --инициируем отчет
  prsg_excel.prepare();
  --описываем шаблон
  prsg_excel.sheet_select(ssheet_name => 'CF');
  prsg_excel.cell_describe(scell_name => 'SREPT_HEAD');
  prsg_excel.cell_describe(scell_name => 'DDATE_FR');
  prsg_excel.cell_describe(scell_name => 'DDATE_TO');
  prsg_excel.cell_describe(scell_name => 'SPERIOD_TYPE');
  prsg_excel.cell_describe(scell_name => 'SFINSTATE');
  prsg_excel.line_describe(sline_name => 'RLINE');
  prsg_excel.line_cell_describe(sline_name => 'RLINE', scell_name => 'SPERIOD');
  prsg_excel.line_cell_describe(sline_name => 'RLINE', scell_name => 'DPERIOD_FR');
  prsg_excel.line_cell_describe(sline_name => 'RLINE', scell_name => 'DPERIOD_TO');
  prsg_excel.line_cell_describe(sline_name => 'RLINE', scell_name => 'NINCOME');
  prsg_excel.line_cell_describe(sline_name => 'RLINE', scell_name => 'NPAYMENT');
  prsg_excel.line_cell_describe(sline_name => 'RLINE', scell_name => 'NCASHFLOW');
  prsg_excel.line_cell_describe(sline_name => 'RLINE', scell_name => 'SCURRENCY');
  --выводим заголовок
  prsg_excel.cell_value_write(scell_name => 'SREPT_HEAD',   scell_value => srpt_head);
  prsg_excel.cell_value_write(scell_name => 'DDATE_FR',     scell_value => ''''||to_char(ddate_fr, 'dd.mm.yyyy'));
  prsg_excel.cell_value_write(scell_name => 'DDATE_TO',     scell_value => ''''||to_char(ddate_to, 'dd.mm.yyyy'));
  prsg_excel.cell_value_write(scell_name => 'SPERIOD_TYPE', scell_value => speriod_type);
  IF ncontract_data = 0
  THEN
    prsg_excel.cell_value_write(scell_name => 'SFINSTATE',     scell_value => sfinstate);
  ELSE
    prsg_excel.cell_value_write(scell_name => 'SFINSTATE',     scell_value => 'По договору');
  END IF;
  --выводим коллекцию
  IF ((trpt_lines IS NOT NULL) AND (trpt_lines.count() > 0))
  THEN
    FOR i IN trpt_lines.first .. trpt_lines.last
    LOOP
      --определимся с номером строки
      IF (i = trpt_lines.first)
      THEN
        ncurrent_line := 0;
      ELSE
        ncurrent_line := prsg_excel.line_append(sline_name => 'RLINE');
      END IF;
      --период
      prsg_excel.cell_value_write(scell_name => 'SPERIOD', icell_index_x => 0, icell_index_y => ncurrent_line, scell_value => trpt_lines(i).rperiod.sname);
      prsg_excel.cell_value_write(scell_name => 'DPERIOD_FR', icell_index_x => 0, icell_index_y => ncurrent_line, scell_value => '''' || to_char(trpt_lines(i).rperiod.ddate_fr, 'dd.mm.yyyy'));
      prsg_excel.cell_value_write(scell_name => 'DPERIOD_TO',   icell_index_x => 0, icell_index_y => ncurrent_line, scell_value => '''' || to_char(trpt_lines(i).rperiod.ddate_to, 'dd.mm.yyyy'));
      --приходы
      prsg_excel.cell_value_write(scell_name => 'NINCOME', icell_index_x => 0, icell_index_y => ncurrent_line, ncell_value => trpt_lines(i).nincome);
      --выплаты
      prsg_excel.cell_value_write(scell_name => 'NPAYMENT',  icell_index_x => 0, icell_index_y => ncurrent_line, ncell_value => trpt_lines(i).npayment);
      --cf
      prsg_excel.cell_value_write(scell_name => 'NCASHFLOW', icell_index_x => 0, icell_index_y => ncurrent_line, ncell_value => trpt_lines(i).ncashflow);
      --валюта
      prsg_excel.cell_value_write(scell_name => 'SCURRENCY', icell_index_x => 0, icell_index_y => ncurrent_line, scell_value => scurrency);
    END LOOP;
  ELSE
    p_exception(0, 'Не найдено данных для формирования отчета!');
  END IF;
  
END udo_pr_projects_cashflow_xls;
/

