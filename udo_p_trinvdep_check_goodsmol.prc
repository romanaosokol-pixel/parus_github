create or replace procedure udo_p_trinvdep_check_goodsmol
(
  ncompany in number
 ,nrn      in number
) is
  /* Контроль остатков ТМЦ для МОЛ по складу "Внутреннее перемещение" после отработки расходной накладной на отпуск в подразделения */
  /* rdoc         transinvdept%rowtype;
  nstore       pkg_std.tref; -- Склад внутреннего перемещения
  nrquant      number; -- Количество в ОЕИ (остаток)
  nrquantalt   number; -- Количество в ДЕИ (остаток)
  novrquant    number; -- Превышение доступного остатка в ОЕИ
  novrquantalt number; -- Превышение доступного остатка в ДЕИ*/

  v_txt varchar2(2000) := ' '; -- Часть предупредительного сообшения про партию и серию

begin

  for cur in (select t.company
                    ,t.mol
                    ,t.store
                    ,ts.nommodif
                    ,ts.goodsparty gprn
                    ,ts.quant
                    ,nvl(usr_f_base_remns_for_mol(ncompany => 90521, nmol => t.mol, nstore => t.store, nnommodif => ts.nommodif, ngprn => ts.goodsparty, ssernumb => TS.article), 0) 
                     + ts.quant as ost_oei  -- Для вывода остатка прибавляем к остатку данные из документа, чтоб показать остаток ДО создания данного документа
                     , ts.article
                from transinvdept t
                join TRANSINVDEPTSPECS ts
                  on ts.prn = t.rn
               where t.rn = nrn)
  loop

    if cur.quant > cur.ost_oei and cur.store = 20300310  -- Только по складу 'ВремПеремещение'
      then

      --- Разрешение ссылок
      if cur.gprn is not null then
        select 'серия : ' || gp.sernumb || ' партия: ' || par.code
          into v_txt
          from goodsparties gp
          join incomdoc par
            on par.rn = gp.indoc
         where gp.rn = cur.gprn;

      end if;

      for res in (with mol as
                     (select m.agnabbr mol
                       from agnlist m
                      where m.rn = cur.mol),
                    skl as
                     (select s.azs_number
                       from azsazslistmt s
                      where s.rn = cur.store),
                    nm as
                     (select t.modif_code
                           ,t.modif_name
                       from nommodif t
                      where t.rn = cur.nommodif)

                    select mol.mol
                          ,skl.azs_number
                          ,nm.modif_code
                          ,nm.modif_name
                      from mol
                          ,skl
                          ,nm)
      loop

        p_exception(0, 'Количество по спецификации %s для номенклатуры "%s (код: "%s"),' || chr(10) ||
                     v_txt || chr(10) ||
                     'превышает доступное количество для МОЛ "%s" (в ОЕИ: %s).', cur.quant, res.modif_name, res.modif_code, res.mol, cur.ost_oei);

      end loop;
    end if;

  end loop;

  --if nRN = 61903234 then return; end if;
  /* Считывание записи */
  /*begin
    select t.*
           into rDOC
           from transinvdept t
           where t.company = nCOMPANY
             and t.rn      = nRN;
    exception when NO_DATA_FOUND then
                   PKG_MSG.RECORD_NOT_FOUND(0, nRN, 'GoodsTransInvoicesToDepts');
    end;

    \* Определение склада *\
    FIND_DICSTORE_NUMB(0, nCOMPANY, 'ВремПеремещение', nSTORE);

    \* Проверка *\
    if rDOC.Status <> 0 and rDOC.Store = nSTORE then
      \* Обязательность МОЛ *\
      if rDOC.Mol is null then
        p_exception(0, 'Для склада "%s" указание МОЛ в расходной накладной на отпуск в подразделение обязательно.', F_DICSTORE_GET_NUMB(rDOC.Store));
      end if;

      \* Цикл по спецификации накладной *\
      for spec in (
          select m.prn          as NOMEN,
                 ts.nommodif    as MODIF,
                 m.modif_code   as MODIF_CODE,
                 m.modif_name   as MODIF_NAME,
                 sj.goodssupply as GOODSSUPPLY,
                 sj.quant       as QUANT,
                 sj.quantalt    as QUANTALT
                 from transinvdeptspecs ts,
                      doclinks          d,
                      storeoperjourn    sj,
                      nommodif          m
                 where ts.prn = rDOC.Rn
                   and ts.rn  = d.in_document
                   and d.in_unitcode  = 'GoodsTransInvoicesToDeptsSpecs'
                   and d.out_unitcode = 'StoreOpersJournal'
                   and d.out_document = sj.rn
                   and ts.nommodif    = m.rn
          ) loop
          \* Определяем остаток *\
          UDO_P_GOODSMOL_BASE_GET_REMNS(
              nCOMPANY          => nCOMPANY,
              nMOL              => rDOC.Mol,
              nGOODSUPPLY       => spec.goodssupply,
              nGOODSPARTY       => null,
              nMODIF            => null,
              nMODIFPACK_MODE   => 0,  -- (0-не проверять, 1-проверять) упаковку модификации
              nMODIFPACK        => null,
              nPARTY            => null,
              sSERNUMB          => null,
              nSTORE            => nSTORE,
              nQUANT            => nRQUANT,
              nQUANTALT         => nRQUANTALT,
              dDATE             => rDOC.Work_Date
              );
          \* Контроль остатков *\
          if (nRQUANT < 0 or nRQUANTALT < 0 ) --and utilizer not in ('CITK_MARKOV', 'KHOK')
             then
            p_exception(0, 'Количество по спецификации для номенклатуры "%s" модификация "%s" (код: "%s"), партия "%s"'||chr(10)||
                           'превышает доступное количество для МОЛ "%s" на дату отработки (в ОЕИ:%s, в ДЕИ:%s).',
                            GET_DICNOMNS_CODE_ID(1, spec.nomen),
                            spec.modif_name, spec.modif_code,
                            UDO_GET_GOODSSUPPLY_CODE_ID(1, spec.goodssupply),
                            GET_AGNLIST_AGNABBR_ID(1, rDOC.Mol),
                            nRQUANT, nRQUANTALT );
          end if;

          \* Определяем обороты товарного запаса после даты отработки *\
          with tDATA as (
               select sj.*,
                      case when sj.unitcode = 'GoodsTransInvoicesToDepts' and sj.oper_type = 1 then t.in_mol
                           when sj.unitcode = 'GoodsTransInvoicesToDepts' and sj.oper_type = 0 then t.mol
                           when sj.unitcode = 'IncomFromDeps' then r.agent
                      else null end as MOL
                      from STOREOPERJOURN      sj
                           join GOODSSUPPLY    gs on ( gs.rn = sj.goodssupply)
                           join DOCLINKS       dl on ( dl.out_unitcode = 'StoreOpersJournal' and dl.out_document = sj.rn
                                                       and dl.in_unitcode in ('GoodsTransInvoicesToDepts', 'IncomFromDeps'))
                      left join TRANSINVDEPT   t  on ( t.rn = dl.in_document and sj.unitcode = 'GoodsTransInvoicesToDepts' )
                      left join INCOMEFROMDEPS r  on ( r.rn = dl.in_document and sj.unitcode = 'IncomFromDeps' )
                      where sj.goodssupply = spec.goodssupply
                        and sj.operdate    > rDOC.Work_Date
                        and sj.signplan    = 2 -- Факт
                        and gs.store       = nSTORE
               )
          select abs(nvl(min(RESTQUANT),0)),
                 abs(nvl(min(RESTQUANTALT),0))
                 into nOVRQUANT, nOVRQUANTALT
            from (
                 select w.*,
                        w.operdate,
                        w.goodssupply,
                        ((2 * w.oper_type - 1) * w.QUANT) as QUANT,
                        sum ( (2 * w.oper_type - 1) * w.QUANT) over (partition by w.goodssupply order by w.operdate) - spec.quant as RESTQUANT,
                        (2 * w.oper_type - 1) * w.QUANTALT as QUANTALT,
                        sum ( (2 * w.oper_type - 1) * w.QUANTALT - 0) over (partition by w.goodssupply order by w.operdate) - spec.quantalt as RESTQUANTALT
                        from tDATA w
                        where w.MOL = rDOC.Mol)
            where ( RESTQUANT < 0 or RESTQUANTALT < 0 );
  --if utilizer in ('CITK_MARKOV') then p_exception(0, 'nOVRQUANT = %s, spec.quant = %s', nOVRQUANT, nRQUANT); end if;
          \* Контроль оборотов товарного запаса после даты отработки *\
          -- 12/05/2023 Марков МВ. Контроль ПОСЛЕ отработки, значит надо вычитать количество спецификации
          if (nOVRQUANT - spec.quant) > 0 or nOVRQUANTALT > 0 then
            p_exception(0, 'Существуют записи журнала складских операций позднее даты отработки для номенклатуры "%s" модификация "%s" (код: "%s") партия "%s".'||chr(10)||
                           'Превышение доступного количество для МОЛ "%s" на дату отработки составляет (в ОЕИ:%s, в ДЕИ:%s).',
                            GET_DICNOMNS_CODE_ID(1, spec.nomen),
                            spec.modif_name, spec.modif_code,
                            UDO_GET_GOODSSUPPLY_CODE_ID(1, spec.goodssupply),
                            GET_AGNLIST_AGNABBR_ID(1, rDOC.Mol),
                            (nOVRQUANT - spec.quant), nOVRQUANTALT );
          end if;
      end loop;
    end if;*/

end udo_p_trinvdep_check_goodsmol;
/
