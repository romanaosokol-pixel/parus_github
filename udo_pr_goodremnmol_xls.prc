create or replace procedure UDO_PR_GOODREMNMOL_XLS
(
  nCOMPANY                  in number,  -- Организация
  dREPDATE                  in date,    -- Дата отчета
  sMOL                      in varchar2, -- МОЛ (отбор)
  sSERIA                    in varchar2, -- Серия
  sNOMEN                    in varchar2 -- Номенклатура
) is
  /* ФОРМИРОВАНИЕ ОТЧЕТА: Остатки ТМЦ по складу "Внутреннее перемещение" по МОЛам */

  -- Лист
  sSHEET_FORM               constant PKG_STD.tSTRING := 'BLANK';
  -- Титульник
  sCELL_STORE               constant PKG_STD.tSTRING := '_STORE';         -- Склад
  sCELL_REPDATE             constant PKG_STD.tSTRING := '_REPDATE';       -- Дата отчета

  -- Таблица (Группировка)
  sLINE_GROUP               constant PKG_STD.tSTRING := '_GROUP';         --
  sCELL_GROUP_MOL           constant PKG_STD.tSTRING := '_GROUP_MOL';     -- МОЛ

  -- Таблица (Спецификация)
  sLINE_SPEC                constant PKG_STD.tSTRING := '_SPEC';          --
  sCELL_SPEC_CODE           constant PKG_STD.tSTRING := '_SPEC_CODE';     -- Мнемокод номенклатуры
  sCELL_SPEC_NAME           constant PKG_STD.tSTRING := '_SPEC_NAME';     -- Наименование номенклатуры
  sCELL_SPEC_UMEAS          constant PKG_STD.tSTRING := '_SPEC_UMEAS';    -- ЕИ
  sCELL_SPEC_PARTY          constant PKG_STD.tSTRING := '_SPEC_PARTY';    -- Партия
  sCELL_SPEC_SERNUMB        constant PKG_STD.tSTRING := '_SPEC_SERNUMB';  -- Серия
  sCELL_SPEC_QUANT          constant PKG_STD.tSTRING := '_SPEC_QUANT';    -- Количество
  --

  nIDENT_MOL                PKG_STD.tREF; -- Идентфиикатор отбора
  nSTORE                    PKG_STD.tREF;
  dREPDATE_                 date;
  nMOL                      PKG_STD.tREF;
  nLINE                     number;
  bFIRST                    boolean := true;
  sSERNUMB                  varchar2(200);

  /* Фильтр по МОЛ */
  procedure MOL_BASE_COND
  (
    nIDENT                  in number,  -- Идентификатор процесса
    nCOMPANY                in number,  -- Организация
    sCODE                   in varchar2 -- Мнемокод
  ) is
  begin
    PKG_COND_BROKER.PROLOGUE(PKG_COND_BROKER.MODE_HARD_, nIDENT, true);
    PKG_COND_BROKER.TRACE_NONE;
    /* Организация */
    PKG_COND_BROKER.SET_COMPANY(nCOMPANY);
    PKG_COND_BROKER.SET_CONDITION_STR('Code', sCODE);
    /* Установка главной таблицы */
    PKG_COND_BROKER.SET_TABLE('AGNLIST');
    PKG_COND_BROKER.ADD_CONDITION_CODE('AGNABBR', 'Code');
    PKG_COND_BROKER.EPILOGUE;
  end MOL_BASE_COND;

  /* Описание листа */
  procedure SHEET_DESCRIBE
  is
  begin
    /* описание строк и ячеек */
    -- Титульник
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_STORE );
    PRSG_EXCEL.CELL_DESCRIBE( sCELL_REPDATE );

    -- Таблица (Группировка)
    PRSG_EXCEL.LINE_DESCRIBE( sLINE_GROUP );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_GROUP, sCELL_GROUP_MOL );

    -- Таблица (Спецификация)
    PRSG_EXCEL.LINE_DESCRIBE( sLINE_SPEC );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_CODE );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_NAME );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_UMEAS );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_PARTY );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_SERNUMB );
    PRSG_EXCEL.LINE_CELL_DESCRIBE( sLINE_SPEC, sCELL_SPEC_QUANT );

  end SHEET_DESCRIBE;

/* Основная процедура */
begin

  /* Пролог */
  PRSG_EXCEL.PREPARE;

  /* Определение склада */
  FIND_DICSTORE_NUMB(0, nCOMPANY, 'ВремПеремещение', nSTORE);

  /* На дату */
  dREPDATE_ := nvl(dREPDATE, P_TOOLS_NOW);

  /* Отбор перечня МОЛ */
  if rtrim(sMOL) is not null then
    P_GENIDENT(nIDENT_MOL);
    MOL_BASE_COND( nIDENT_MOL, nCOMPANY, sMOL);
  end if;

  /* Выбор листа */
  PRSG_EXCEL.SHEET_SELECT(sSHEET_FORM);

  /* Описание листа */
  SHEET_DESCRIBE;

  -- Титульник
  --PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_STORE, sDOC_NUMB );
  PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_REPDATE, to_char(dREPDATE_, 'DD.MM.YYYY') );
  
  if sSERIA is not null then
    sSERNUMB := trim(sSERIA);
  end if;

  for rec in (
      with tDATA as (
           select gs.store,
                  gs.prn         as GOODSPARTY,
                  sj.oper_type   as OPER_TYPE,
                  case when sj.oper_type = 1 then t.in_mol else t.mol end as MOL,
                  sj.quant 
                  from STOREOPERJOURN     sj,
                       GOODSSUPPLY        gs,
                       doclinks           dl,
                       transinvdept       t,
                       transinvdeptspecs  ts
                  where sj.goodssupply  = gs.rn
                    and gs.store        = nSTORE
                    and sj.operdate     <= dREPDATE_
                    and dl.out_unitcode = 'StoreOpersJournal'
                    and dl.out_document = sj.rn
                    and dl.in_unitcode  = 'GoodsTransInvoicesToDeptsSpecs'
                    and dl.in_document  = ts.rn
                    and ts.prn          = t.rn
            union all
             select GS.RN          nGOODSSUPPLY,
                    GS.PRN         nGOODSPARTY,
                    SJ.OPER_TYPE   nOPER_TYPE,
                    T.AGENT as nMOL,
                    SJ.QUANT       nQUANT
                    from STOREOPERJOURN     SJ,
                         GOODSSUPPLY        GS,
                         DOCLINKS           DL,
                         INCOMEFROMDEPS     T,
                         INCOMEFROMDEPSSPEC  TS
                    where SJ.COMPANY      = nCOMPANY
                      --and SJ.JUR_PERS     = rAZS.JUR_PERS
                      and SJ.OPERDATE     <= dREPDATE_
                      and SJ.GOODSSUPPLY  = GS.RN
                      and GS.STORE        = nSTORE
                      and DL.OUT_UNITCODE = 'StoreOpersJournal'
                      and DL.OUT_DOCUMENT = SJ.RN
                      and DL.IN_UNITCODE  = 'IncomFromDepsSpecs'
                      and DL.IN_DOCUMENT  = TS.RN
                      and TS.PRN          = T.RN
           ),
           tSUMMARY as (
           select t.GOODSPARTY, t.mol,
                  sum( (2 * t.OPER_TYPE - 1) * t.QUANT ) as QUANT
                  from tDATA   t
                  where ( nIDENT_MOL is null or exists(select null from cond_broker_idhard r where r.ident = nIDENT_MOL and r.id = t.mol) )
                  group by t.mol, t.GOODSPARTY
           )
      select w.mol          as MOL,
             a.agnname      as AGNNAME, 
             w.GOODSPARTY   as GOODSPARTY,
             gp.NOMMODIF    as MODIF,
             m.modif_code   as MODIF_CODE,
             n.nomen_name/*m.modif_name*/   as MODIF_NAME,
             mm.meas_mnemo  as SUMEAS,
             p.code         as PARTY,
             gp.SERNUMB     as SERNUMB,
             w.QUANT        as QUANT
             from tSUMMARY w,
                  GOODSPARTIES gp,
                  INCOMDOC     p,
                  nommodif     m,
                  dicnomns     n,
                  dicmunts     mm,
                  agnlist      a
               where w.goodsparty = gp.rn
                 and gp.nommodif  = m.rn
                 and m.prn        = n.rn
                 and n.umeas_main = mm.rn
                 and gp.indoc     = p.rn
                 and (sSERIA is null or trim(gp.sernumb) = sSERNUMB)
                 and (sNOMEN is null or n.nomen_code = sNOMEN)
                 
                 and w.mol        = a.rn (+)
                 and w.quant      <> 0 -- Не нулевые остатки
             order by a.agnname, mm.meas_mnemo, n.nomen_name, gp.sernumb nulls first
      ) loop 

      if cmp_num(nMOL, rec.mol) = 0 or bFIRST then
        nMOL := rec.mol;
        -- Новая группа
        nLINE := PRSG_EXCEL.LINE_APPEND(sLINE_GROUP, sCURRENT_LINE_NAME => sLINE_SPEC);
        /* МОЛ */
        PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_GROUP_MOL,  0, nLINE, nvl(rec.AGNNAME,'(пусто)'));

        -- Первая строка группы
        nLINE := PRSG_EXCEL.LINE_APPEND(sLINE_SPEC, sCURRENT_LINE_NAME => sLINE_GROUP);
        bFIRST := false;
      else
        -- Последующие строки группы
        nLINE := PRSG_EXCEL.LINE_APPEND(sLINE_SPEC);
      end if;
      
      /* Мнемокод */
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_CODE,  0, nLINE, rec.MODIF_CODE);
      /* Наименование */
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_NAME,  0, nLINE, rec.MODIF_NAME);
      /* ЕИ */
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_UMEAS,  0, nLINE, rec.SUMEAS);
      /* Серия */
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_SERNUMB, 0, nLINE, rec.SERNUMB);
      /* Партия*/
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_PARTY,  0, nLINE, rec.PARTY);
      /* Количество */
      PRSG_EXCEL.CELL_VALUE_WRITE( sCELL_SPEC_QUANT, 0, nLINE, rec.QUANT);
      
  end loop;
  
  /* Удаление образцов строк */
  PRSG_EXCEL.LINE_DELETE(sLINE_GROUP);
  PRSG_EXCEL.LINE_DELETE(sLINE_SPEC);

end UDO_PR_GOODREMNMOL_XLS;
/

