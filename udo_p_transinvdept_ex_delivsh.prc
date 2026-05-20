create or replace procedure UDO_P_TRANSINVDEPT_EX_DELIVSH(
       nCOMPANY             in number,  -- Организация
       nRN                  in number   -- Регистрационный номер записи
       ) is
/* ОТРАЖЕНИЕ ВОЗВРАТНОЙ НАКЛАДНОЙ В КОМПЛЕКТОВОЧНОЙ ВЕДОМОСТИ */
  nCRN            PKG_STD.tREF;   -- Каталог
  nSTATUS         number;         -- Состояние (0 - не отработан, 1 - отработан как факт, 2 - отработан как план)
  dWORK_DATE      date;
  nINDOC          PKG_STD.tREF;   -- Исходная расходная накладная на отпуск в подразделение
  rINSPEC         transinvdeptspecs%rowtype; -- Запись спецификации
  nDELIVSH        PKG_STD.tREF;   -- Комплектовочная ведомость
  nDELIVSHSP      PKG_STD.tREF;   -- Строка комплектовочной ведомости
  nIN_STORE       PKG_STD.tREF;   -- склад пердачи комплектующих (давальческое)
  -- временные
  nTMP            number;
begin

  /* Считывание записи */
  begin
    select t.crn, t.status, t.work_date, t.in_store
      into nCRN, nSTATUS, dWORK_DATE, nIN_STORE
      from transinvdept t
      where t.rn = nRN
        and t.company = nCOMPANY;
  exception
    when NO_DATA_FOUND then
         PKG_MSG.RECORD_NOT_FOUND(0, nRN, 'GoodsTransInvoicesToDepts');
  end;

  /* Поиск исходной расходной накладной на отпуск в подразделение */
  nINDOC := F_DOCLINKS_LINK_IN_DOC('GoodsTransInvoicesToDepts', nRN, 'GoodsTransInvoicesToDepts');
  -- Если это накладная из 1С, то выходим
  for rc in(select 1 as nchk from transinvdept td where td.rn = nINDOC and td.store = 13125639) loop
    return;
  end loop;

  /* Поиск комплектовочной ведомости */
  if nINDOC is not null then
    nDELIVSH := F_DOCLINKS_LINK_IN_DOC('GoodsTransInvoicesToDepts', nINDOC, 'CostDeliverySheets');
  end if;

  /* Проверка состояния */
  if not( nSTATUS in (0,1) and nINDOC is not null and nDELIVSH is not null) then
    return;
  end if;

  /* Цикл по строкам спецификации */
  for rec in (
      select ts.*, m.prn as NOMEN
        from transinvdeptspecs ts,
             nommodif          m
        where ts.prn      = nRN
          and ts.nommodif = m.rn
      ) loop
      
      /* Поиск строки спецификации PRN, NOMMODIF, NOMNMODIFPACK, ARTICLE, GOODSPARTY, SERNUMB_1C */
      begin
        select ts.*
          into rINSPEC
          from transinvdeptspecs ts
          where ts.prn      = nINDOC
            and ts.nommodif = rec.nommodif
            and cmp_num(ts.nomnmodifpack, rec.nomnmodifpack) = 1
            and cmp_num(ts.article, rec.article) = 1
            and cmp_num(ts.goodsparty, rec.goodsparty) = 1;
            -- 21/04/2023 Марков МВ. Кроме 1С. and cmp_vc2(ts.sernumb_1c, rec.sernumb_1c) = 1;
      exception when NO_DATA_FOUND then
                p_exception(0, 'Строка спецификации исходной расходной накладной для номенклатуры "%s" не определена.',
                               UDO_GET_NOMMODIF_NAME_ID(1, rec.nommodif));
      end;

      /* Поиск строки комплектовочной ведомости */
      nDELIVSHSP := F_DOCLINKS_LINK_IN_DOC('GoodsTransInvoicesToDeptsSpecs', rINSPEC.Rn, 'CostDeliverySheetsSpec');


      /* ОБРАБОТКА */

      if nSTATUS = 1 then
          for spec in (
              select tr.*
                from FCDELIVSHSPTRN tr
                where tr.prn = nDELIVSHSP
                  and tr.trnsdptsp = rINSPEC.Rn
                  and not exists(select null from FCDELIVSHSPTRN r where r.prn = nDELIVSHSP and r.trnsdptsp = rec.rn)
              ) loop
              /* Добавление операции "Возврат" */
              P_FCDELIVSHSPTRN_BASE_INSERT(
                  nCOMPANY        => nCOMPANY,
                  nPRN            => nDELIVSHSP,
                  nACT            => 1,  -- Операция возврат (разукомплектование)
                  dACT_DATE       => dWORK_DATE,
                  nMATRES         => spec.matres,
                  nQUANT          => rec.quant,
                  nCOEFF          => spec.coeff,
                  nTRNSDPTSP      => rec.rn,
                  nROUTLST        => spec.routlst,
                  nPARTY          => spec.party,
                  nARTICLE        => spec.article,
                  nSUBDIV         => spec.subdiv,
                  nSTORE          => spec.store,
                  nRN             => nTMP
                  );
          end loop;
          -- 17/08/2023 Марков МВ. Если возврат со склада давальческого материала. то уменьшим Скомплектовано
          -- Модуль-Воронеж
          if nIN_STORE is not null and nIN_STORE in(21648922) then
            update FCDELIVSHSP SP set SP.QUANT_CMPL = SP.QUANT_CMPL - rec.quant where SP.RN = nDELIVSHSP;
            for rcmp in(select CMP.RN from FCDELIVSHSPCMPL CMP where CMP.PRN = nDELIVSHSP and rec.goodsparty is not null and CMP.PARTY = rec.goodsparty) loop
              update FCDELIVSHSPCMPL C set C.NOTE = substr('Возврат ('||to_char(rec.quant)||'). '||C.NOTE, 1, 240) where C.RN = rcmp.rn;
            end loop;
          end if;
          
      elsif nSTATUS = 0 then
          for spec in (
              select tr.*
                from FCDELIVSHSPTRN tr
                where tr.prn = nDELIVSHSP
                  and tr.trnsdptsp = rec.rn
              ) loop
              /* Удаление операции "Возврат" */
              P_FCDELIVSHSPTRN_BASE_DELETE(spec.rn, nCOMPANY);
          end loop;
          -- 17/08/2023 Марков МВ. Если возврат со склада давальческого материала. то вернем Скомплектовано
          -- Модуль-Воронеж
          if nIN_STORE is not null and nIN_STORE in(21648922) then
            update FCDELIVSHSP SP set SP.QUANT_CMPL = SP.QUANT_CMPL + rec.quant where SP.RN = nDELIVSHSP;
            for rcmp in(select CMP.RN from FCDELIVSHSPCMPL CMP where CMP.PRN = nDELIVSHSP and rec.goodsparty is not null and CMP.PARTY = rec.goodsparty) loop
              update FCDELIVSHSPCMPL C set C.NOTE = trim(replace(C.NOTE, 'Возврат ('||to_char(rec.quant)||').')) where C.RN = rcmp.rn;
            end loop;
          end if;
      
      else
        -- как план - не рассматриваем
        null;
      end if;
      
  end loop;

end UDO_P_TRANSINVDEPT_EX_DELIVSH;
/
