create or replace package USR_PKG_INTEGRACT IS
  /*
  Степанов М. 13/07/2023
  Предназначен для работы с разделом "Акты комплектации/разукомплектации". 
  IntegrationActs        IA
  IntegrationActsSpecs   IAS
  */
  --#########################################################################################################

  function INTEGRACT_GET
  /*
  Заголовок. Считывание
  */
  (
   NRN       in number
  ) 
  return INTEGRACT%ROWTYPE;
  --#########################################################################################################

  procedure INTEGRACT_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACT_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACT_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACT_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACT_BPROCESS
  /*
  Заголовок. Проверка перед отработкой
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACT_APROCESS
  /*
  Заголовок. Проверка после отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACT_BCANCEL
  /*
  Заголовок. Проверка до снятия отработки
 */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACT_ACANCEL
  /*
  Заголовок. Проверка после снятия отработки
 */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  function INTEGRACTS_GET
  /*
  Спецификация. Считывание заголовка
  */
  (
   NRN       in number
  ) 
  return INTEGRACTS %ROWTYPE;
  --#########################################################################################################

  procedure INTEGRACTS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACTS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACTS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACTS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACTS_ADELETE
  /*
  Спецификация. Проверка после удаления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

  procedure INTEGRACTS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  );
  --#########################################################################################################

end USR_PKG_INTEGRACT;

/*
CREATE PUBLIC SYNONYM USR_PKG_INTEGRACT FOR USR_PKG_INTEGRACT;
GRANT EXECUTE ON USR_PKG_INTEGRACT TO PUBLIC;
*/
/

create or replace package body USR_PKG_INTEGRACT is

  --#########################################################################################################

  function INTEGRACT_GET
  /*
  Заголовок. Считывание 
  */
  (
   NRN      in number -- RN записи
  ) 
  return INTEGRACT%rowtype
  is
    rRow INTEGRACT%rowtype;
  begin
    begin
      select T.*
        into rRow
        from INTEGRACT t
        where t.rn = NRN;
    exception
      when no_data_found then
        PKG_MSG.RECORD_NOT_FOUND(NRN, GET_UNITLIST_CODE_TABLE(1, 'INTEGRACT'));
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(NRN), 'Не задан')||'> '||
        'в разделе <'||F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'INTEGRACT'))||'>.');
    end;
    return(rRow);
  end INTEGRACT_GET;
  --#########################################################################################################

  procedure INTEGRACT_AINSERT
  /*
  Заголовок. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow     INTEGRACT%ROWTYPE;
  begin
    null;
    -- ПРОВЕРКИ 
    -- базовая
    INTEGRACT_CHECK_BASE(NRN, NCOMPANY);

    -- Заголовок  
    -- rRow := INTEGRACT_GET(NRN);

    -- префикса и номера
    -- INTEGRACT_CHECK_PREF_NUMB(rRow);

  end INTEGRACT_AINSERT;
  --#########################################################################################################

  procedure INTEGRACT_BUPDATE
  /*
  Заголовок. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;    
    -- Считывание
    -- usr_pkg_pub_const.rINTEGRACT := INTEGRACT_GET(NRN); 

  end INTEGRACT_BUPDATE;
  --#########################################################################################################

  procedure INTEGRACT_AUPDATE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow     INTEGRACT%rowtype;
  begin
    -- Проверка базовая
    INTEGRACT_CHECK_BASE(NRN, NCOMPANY);

    -- Заголовок  
    -- rRow := INTEGRACT_GET(NRN);

  end INTEGRACT_AUPDATE;
  --#########################################################################################################

  procedure INTEGRACT_BDELETE
  /*
  Заголовок. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rIntegrAct      integract%rowtype;
    rIntegrActs     integracts%rowtype;
    rGoodsParties   goodsparties%rowtype;
  begin
    -- Заголовок
    rIntegrAct := INTEGRACT_GET(NRN);
    
    -- ИСПРАВЛЕНИЕ
    -- Если акт разукомплектации 
    if rIntegrAct.acttype = 1 then
      null;
      /*-- Очистка партии детали в текущей записи
      if rIntegrAct.detalparty is not null then
        update integract set detalparty = null where rn = rIntegrAct.rn;
      end if;

      -- По спецификациям
      for c in (select * from integracts where prn = NRN)
      loop
        -- Если акт разукомплектации 
        if rIntegrAct.acttype = 1 then
          -- если задана приходная партия
          if c.goodsparty is not null then
            -- считывание приходной партии
            select * into rGoodsParties from goodsparties where rn = c.goodsparty; 
            -- если указана серия
            if rGoodsParties.sernumb is not null then
             -- удаление её из спец.таблицы
             udo_p_ininvoice_rmv_sernumb(nrn      => c.rn
                                        ,ncompany => c.company
                                        ,sunit    => 'IntegrationActsSpecs');
            end if;
            -- очистка партии в текущей записи
            update integracts set goodsparty = null where rn = c.rn;
            -- удаление приходной партии 
            p_goodsparties_base_delete(ncompany => rGoodsParties.company, nrn => rGoodsParties.rn);
            -- удаление партии товара
            p_incomdoc_base_delete(ncompany => rGoodsParties.company, nrn => rGoodsParties.indoc);
          end if;
        end if;
      end loop;*/
    end if;    
    
    -- ПРОВЕРКИ
    
  end INTEGRACT_BDELETE;
  --#########################################################################################################

  procedure INTEGRACT_BPROCESS
  /*
  Заголовок. Проверка перед отработкой
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    nNumber   PKG_STD.tNUMBER;  
  begin
    null;    
    -- ИСПРАВЛЕНИЯ
    -- 

    -- ПРОВЕРКИ 
    -- базовая
    INTEGRACT_CHECK_BASE(NRN, NCOMPANY);
    
  end INTEGRACT_BPROCESS;
  --#########################################################################################################

  procedure INTEGRACT_APROCESS
  /*
  Заголовок. Проверка после отработки
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rIntegrAct      integract%rowtype;
    rGoodsParties   goodsparties%rowtype;
  begin
    null;
    -- Заголовок
    rIntegrAct := INTEGRACT_GET(NRN);
    
    -- ИСПРАВЛЕНИЕ
    -- По спецификациям
    for c in (select * from integracts where prn = rIntegrAct.rn)
    loop
      -- если акт разукомплектации 
      if rIntegrAct.acttype = 1 then
        null;
        /*-- если задана приходная партия
        if c.goodsparty is not null then
          -- считывание приходной партии
          select * into rGoodsParties from goodsparties where rn = c.goodsparty; 
          -- если указана серия
          if rGoodsParties.sernumb is not null then
            -- добавление её в спец.таблицу
            udo_p_ininvoice_set_sernumb(nrn      => c.rn
                                       ,ncompany => c.company
                                       ,sunit    => 'IntegrationActsSpecs'
                                       ,nprn     => c.prn
                                       ,ssernumb => rGoodsParties.sernumb);
          end if;
        end if;*/
      end if;
    end loop;
  end INTEGRACT_APROCESS;
  --#########################################################################################################

  procedure INTEGRACT_BCANCEL
  /*
  Заголовок. Проверка до снятия отработки
 */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow     INTEGRACT%ROWTYPE;
    rFaceacc faceacc%rowtype;
  begin
    null;
   
  end INTEGRACT_BCANCEL;
  --#########################################################################################################

  procedure INTEGRACT_ACANCEL
  /*
  Заголовок. Проверка после снятия отработки
 */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rIntegrAct      integract%rowtype;
    rGoodsParties   goodsparties%rowtype;
  begin
    null;
  end INTEGRACT_ACANCEL;
  --#########################################################################################################

  procedure INTEGRACT_CHECK_BASE
  /*
  Заголовок. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
    rRow     INTEGRACT%rowtype;
  begin
    null;
    -- Заголовок  
    rRow := INTEGRACT_GET(NRN);

    -- ИСПРАВЛЕНИЯ
    /*-- Удаление пробелов и переносов строк
    if rRow.note != TRIM(REPLACE(rRow.note, CHR(13)||CHR(10), ' ')) THEN
      update INTEGRACT t
         set t.note = TRIM(REPLACE(t.note, chr(13)||chr(10), ' '))
       where t.rn = rRow.rn;
    end if;*/

    -- ПРОВЕРКИ
    
  end INTEGRACT_CHECK_BASE;
  --#########################################################################################################

  function INTEGRACTS_GET
  /*
  Спецификация. Считывание
  */
  (
   NRN      in number -- RN записи
  ) 
  return INTEGRACTS%ROWTYPE
  is
    rRow INTEGRACTS%ROWTYPE;
  begin
    begin
      select t.*
        into rRow
        from INTEGRACTS t
        where t.rn = NRN;
    exception
      when no_data_found then
        PKG_MSG.RECORD_NOT_FOUND(NRN, GET_UNITLIST_CODE_TABLE(1, 'INTEGRACTS'));
      when others then
        P_EXCEPTION(0, 'Неопределённая ситуация при считывании документа с RN <'||nvl(to_char(NRN), 'Не задан')||'> '||
        'в разделе <'||F_UNITLIST_GETNAME(GET_UNITLIST_CODE_TABLE(1, 'INTEGRACTS'))||'>.');
    end;
    return(rRow);
  end INTEGRACTS_GET;
  
  --#########################################################################################################

  procedure INTEGRACTS_AINSERT
  /*
  Спецификация. Проверка после добавления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    -- Проверка базовая
    INTEGRACTS_CHECK_BASE(NRN, NCOMPANY);
  end INTEGRACTS_AINSERT;
  --#########################################################################################################

  procedure INTEGRACTS_BUPDATE
  /*
  Спецификация. Проверка перед исправлением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end INTEGRACTS_BUPDATE;
  --#########################################################################################################

  procedure INTEGRACTS_AUPDATE
  /*
  Спецификация. Проверка после исправления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    -- Проверка базовая
    INTEGRACTS_CHECK_BASE(NRN, NCOMPANY);
  end INTEGRACTS_AUPDATE;
  --#########################################################################################################

  procedure INTEGRACTS_BDELETE
  /*
  Спецификация. Проверка перед удалением
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end INTEGRACTS_BDELETE;
  --#########################################################################################################

  procedure INTEGRACTS_ADELETE
  /*
  Спецификация. Проверка после удаления
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  is
  begin
    null;
  end INTEGRACTS_ADELETE;
  --#########################################################################################################

  procedure INTEGRACTS_CHECK_BASE
  /*
  Спецификация. Проверка общая
  */
  (
   NRN       in number
  ,NCOMPANY  in number
  ) 
  IS
    rRow         INTEGRACTS%rowtype;
    nAcc_Cur     pkg_std.tquant; 
    nDoc_Base    pkg_std.tquant; 
  begin
    -- Считывание 
    rRow  := INTEGRACTS_get(NRN);

    -- ИСПРАВЛЕНИЯ
    /*-- Удаление пробелов и переносов строк
    if rRow.note != TRIM(REPLACE(rRow.note, CHR(13)||CHR(10), ' ')) THEN
      update INTEGRACTS t
         set t.note = TRIM(REPLACE(T.NOTE, CHR(13)||CHR(10), ' '))
       where t.rn = rRow.rn;
    end IF;*/

    -- ПРОВЕРКИ
 
  end INTEGRACTS_CHECK_BASE;
  --#########################################################################################################

end USR_PKG_INTEGRACT;
/*
CREATE PUBLIC SYNONYM USR_PKG_INTEGRACT FOR USR_PKG_INTEGRACT;
GRANT EXECUTE ON USR_PKG_INTEGRACT TO PUBLIC;
*/
/

