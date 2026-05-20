create or replace procedure UDO_P_PRODUCTORD_MTR_REST_XLS
(
  nCOMPANY   in number,
  nPROCESS   in number, -- идентификатор процесса
  sUNIT      in varchar2, -- код раздела вызова отчета
  sTEMA_LIST in varchar2, -- отбор остатков по конкретным темам
  nSIGN_ALL  in number -- остатки по всем темам
) as
  /*
    14/06/2024 Марков МВ.
    Заказы на производство.
    Пользовательский отчет "Потребность по остаткам на складах"
      
    Оценка потребности в ТМЦ по остаткам на складах ЭРИ и ДСЕ.
    Пока только на этих складах.
      
    UDO_PRODORD_MTR_REST - потребность по ПС
    UDO_PRODORD_MTR_REST_SUPPLY - остатки
    UDO_PRODORD_MTR_REST_CMPSP - входимость по ПС
    UDO_PRODORD_MTR_REST_D28 - возможные замены (все)
    UDO_PRODORD_MTR_REST_TMP - сводная таблица по остаткам
        
    grant execute on UDO_P_PRODUCTORD_MTR_REST_XLS to public;
        
  */
  -- описание отчета
  cFORM constant varchar2(20) := 'Потребность';
  cATR  constant varchar2(20) := 'изделие';
  cTEMA constant varchar2(20) := 'тема';
  cLINE constant varchar2(20) := 'строка';
  cCODE constant varchar2(20) := 'код';
  cNAME constant varchar2(20) := 'наименование';
  cQ_SP constant varchar2(20) := 'кол_сп';
  cQ_ST constant varchar2(20) := 'кол_склад';
  cDIR  constant varchar2(20) := 'замена';
  cDIRN constant varchar2(20) := 'замена_наим';
  cQ_DP constant varchar2(20) := 'замена_скл';
  cTYPE constant varchar2(20) := 'тип';
  cINCL constant varchar2(20) := 'входимость';
  cTEMS constant varchar2(20) := 'темы';
  cCOL  constant varchar2(20) := 'ост_темы';

  n         integer;
  sART_NAME varchar2(2000);
  sTEMA     varchar2(2000);
  bDIR      boolean;
  nIDENT    number(17);

begin
  
  -- определение IDENT
  if sUNIT = 'UdoProductArticleMatResRest' then
    -- вызов из Оценки потребности
    nIDENT := UDO_PKG_PRODORD_MTR_REST_ART.F_GET_CONTCACHE_IDENT(sCONTAINER => 'PRODUCTORD_MTR_REST');
    -- параметры печати
    for rin in(select ART.TEMA_LIST, ART.SIGN_ALL
       from UDO_PRODORD_MTR_REST_ART ART where ART.IDENT = nIDENT) loop
      -- темы
      -- признак остатков
      if nvl(rin.sign_all, 0) = 0 then
        -- смотрим остатки по конкретным темам
        if rtrim(rin.tema_list) is null then
          -- тема указана в заголовке
          for rec in (select UDO_F_FACEACC_GET_SHEFR(NRN => ORD.FACEACC) as TEMA
                        from UDO_PRODORD_MTR_REST_ART ART,
                             PRODUCTORD ORD
                       where ART.IDENT = nIDENT
                         and ART.PRODORD = ORD.RN) loop
            if sTEMA is null then
              sTEMA := rec.tema;
            else
              if length(sTEMA || ';' || rec.tema) <= 2000 then
                sTEMA := sTEMA || ';' || rec.tema;
              end if;
            end if;
          end loop;
          --
          if sTEMA is null then
            p_exception(0,
                        'Необходимо выбрать темы или признак "По всем темам".');
          end if;
        
        else
          -- задан список тем для остатков
          for rtm in (select L.SNAME as TEMA from UDO_V_SHEME_LIST L where strinlike(L.SCODE, sTEMA_LIST) = 1) loop
            if sTEMA is null then
              sTEMA := rtm.tema;
            else
              if length(sTEMA || ';' || rtm.tema) <= 2000 then
                sTEMA := sTEMA || ';' || rtm.tema;
              end if;
            end if;
          end loop;
        end if;
        --
        if length(sTEMA || '. Остатки по теме') <= 2000 then
          sTEMA := sTEMA || '. Остатки по теме';
        end if;
      
      else
        -- смотрим остатки по всем темам
        if length(sTEMA || '. Остатки по всем темам') <= 2000 then
          sTEMA := sTEMA || '. Остатки по всем темам';
        end if;
      end if;
      --
      exit;
    end loop;
  
  else
    -- вызов из Заказов на производство
    nIDENT := nPROCESS;
  
  -- темы
  -- признак остатков
  if nvl(nSIGN_ALL, 0) = 0 then
    -- смотрим остатки по конкретным темам
    if rtrim(sTEMA_LIST) is null then
      -- тема указана в заголовке
      for rec in (select UDO_F_FACEACC_GET_SHEFR(NRN => ORD.FACEACC) as TEMA
                    from SELECTLIST SL,
                         PRODUCTORD ORD
                   where SL.IDENT = nIDENT
                     and SL.DOCUMENT = ORD.RN) loop
        if sTEMA is null then
          sTEMA := rec.tema;
        else
          if length(sTEMA || ';' || rec.tema) <= 2000 then
            sTEMA := sTEMA || ';' || rec.tema;
          end if;
        end if;
      end loop;
      --
      if sTEMA is null then
        p_exception(0,
                    'Необходимо выбрать темы или признак "По всем темам".');
      end if;
    
    else
      -- задан список тем для остатков
      for rtm in (select L.SNAME as TEMA from UDO_V_SHEME_LIST L where strinlike(L.SCODE, sTEMA_LIST) = 1) loop
        if sTEMA is null then
          sTEMA := rtm.tema;
        else
          if length(sTEMA || ';' || rtm.tema) <= 2000 then
            sTEMA := sTEMA || ';' || rtm.tema;
          end if;
        end if;
      end loop;
    end if;
    --
    if length(sTEMA || '. Остатки по теме') <= 2000 then
      sTEMA := sTEMA || '. Остатки по теме';
    end if;
  
  else
    -- смотрим остатки по всем темам
    if length(sTEMA || '. Остатки по всем темам') <= 2000 then
      sTEMA := sTEMA || '. Остатки по всем темам';
    end if;
  end if;

  -- расчет данных
  --UDO_P_PRODUCTORD_MTR_REST(nCOMPANY => nCOMPANY, nIDENT => nIDENT, sTEMA_LIST => sTEMA_LIST, nSIGN_ALL => nSIGN_ALL, nSIGN_DIFF => 0);
  UDO_PKG_PRODORD_MTR_REST_ART.P_PRODUCTORD_MTR_REST_TMP(nCOMPANY   => nCOMPANY, 
                                                         nIDENT     => nIDENT, 
                                                         sTEMA_LIST => sTEMA_LIST, 
                                                         nSIGN_ALL  => nSIGN_ALL, 
                                                         nSIGN_DIFF => 0);
  end if;
  
  -- описание отчета
  PRSG_EXCEL.PREPARE;
  PRSG_EXCEL.SHEET_SELECT(sSHEET_NAME => cFORM);
  --
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cATR);
  PRSG_EXCEL.CELL_DESCRIBE(sCELL_NAME => cTEMA);
  --
  PRSG_EXCEL.LINE_DESCRIBE(sLINE_NAME => cLINE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cCODE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cNAME);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cQ_SP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cQ_ST);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cDIR);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cDIRN);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cQ_DP);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cTYPE);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cINCL);
  PRSG_EXCEL.LINE_CELL_DESCRIBE(sLINE_NAME => cLINE, sCELL_NAME => cTEMS);
  --
  PRSG_EXCEL.COLUMN_DESCRIBE(sCOLUMN_NAME => cCOL);

  -- изделия
  for rsp in (select NM.NOMEN_NAME
                from SELECTLIST  SL,
                     PRODUCTORDS ORDS,
                     DICNOMNS    NM
               where SL.IDENT = nIDENT
                 and SL.DOCUMENT = ORDS.PRN
                 and ORDS.NOMEN = NM.RN) loop
    if sART_NAME is null then
      sART_NAME := rsp.nomen_name;
    else
      if length(sART_NAME || ';' || rsp.nomen_name) <= 2000 then
        sART_NAME := sART_NAME || ';' || rsp.nomen_name;
      end if;
    end if;
  end loop;

  -- печать
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cATR, sCELL_VALUE => sART_NAME);
  PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME => cTEMA, sCELL_VALUE => sTEMA);
  -- ПКИ
  bDIR := false;
  for rmtr in (select case
                        when t.modif_chng is null then
                         mr.code
                        else
                         ''
                      end as code,
                      case
                        when t.modif_chng is null then
                         mr.name
                        else
                         ''
                      end as name,
                      case
                        when t.modif_chng is null then
                         t.prod_quant
                        else
                         null
                      end as prod_quant,
                      case
                        when t.modif_chng is null then
                         (t.quant_tema_rest - t.quant_tema_reserv) -- за вычетом резерва по КВ
                        else
                         0
                      end as quant_tema_rest,
                      case
                        when t.modif_chng is null then
                         ''
                        else
                         (select nm.nomen_name || case
                                   when instr(md.modif_name, '_') > 0 then
                                    ' ' || substr(md.modif_name, instr(md.modif_name, '_') + 1)
                                   else
                                    ''
                                 end
                            from nommodif md,
                                 dicnomns nm
                           where md.rn = t.modif_chng
                             and md.prn = nm.rn)
                      end as CHNG_NAME,
                      case
                        when t.modif_chng is null then
                         ''
                        else
                         (select nm.nomen_code
                            from nommodif md,
                                 dicnomns nm
                           where md.rn = t.modif_chng
                             and md.prn = nm.rn)
                      end as CHNG_CODE,
                      case
                        when t.modif_chng is not null then
                         (t.quant_tema_rest - t.quant_tema_reserv) -- за вычетом резерва по КВ
                        else
                         null
                      end as QUANT_CHNG,
                      (select gn.group_code
                         from dicnomns nm,
                              dicgnomn gn
                        where nm.rn = mr.nomenclature
                          and nm.group_code = gn.rn) as grp_code,
                      t.tema_rest,
                      t.include_mtr
                 from udo_prodord_mtr_rest_tmp t,
                      fcmatresource            mr
                where t.ident = nIDENT
                  and t.matres = mr.rn
                  and (t.modif_chng is null or t.quant_tema_rest > 0)
                order by mr.name,
                         decode(t.modif_chng, null, 0, 1),
                         t.modif_chng) loop
    if rmtr.code is not null then
      -- новая позиция по спецификации
      n := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE);
      -- мнемокод
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cCODE,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => rmtr.code);
      -- наименование
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cNAME,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => rmtr.name);
      -- на спецификацию
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQ_SP,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  nCELL_VALUE   => rmtr.prod_quant);
      -- остаток на складе (по теме)
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQ_ST,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  nCELL_VALUE   => rmtr.quant_tema_rest);
      bDIR := true;
    
    else
      if bDIR then
        -- печать замены в этой же строке
        PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cDIR,
                                    iCELL_INDEX_X => 0,
                                    iCELL_INDEX_Y => n,
                                    sCELL_VALUE   => rmtr.chng_code);
        PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cDIRN,
                                    iCELL_INDEX_X => 0,
                                    iCELL_INDEX_Y => n,
                                    sCELL_VALUE   => rmtr.chng_name);
        PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQ_DP,
                                    iCELL_INDEX_X => 0,
                                    iCELL_INDEX_Y => n,
                                    nCELL_VALUE   => rmtr.quant_chng);
        bDIR := false;
      else
        -- более одной замены
        -- новая позиция
        n := PRSG_EXCEL.LINE_CONTINUE(sLINE_NAME => cLINE);
        -- печать замены
        PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cDIR,
                                    iCELL_INDEX_X => 0,
                                    iCELL_INDEX_Y => n,
                                    sCELL_VALUE   => rmtr.chng_code);
        PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cDIRN,
                                    iCELL_INDEX_X => 0,
                                    iCELL_INDEX_Y => n,
                                    sCELL_VALUE   => rmtr.chng_name);
        PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cQ_DP,
                                    iCELL_INDEX_X => 0,
                                    iCELL_INDEX_Y => n,
                                    nCELL_VALUE   => rmtr.quant_chng);
      end if;
    
    end if;
  
    -- группа ТМЦ
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cTYPE,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => rmtr.grp_code);
    -- входимость
    PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cINCL,
                                iCELL_INDEX_X => 0,
                                iCELL_INDEX_Y => n,
                                sCELL_VALUE   => rmtr.include_mtr);
    -- темы остатков
    if nvl(nSIGN_ALL, 0) = 1 then
      PRSG_EXCEL.CELL_VALUE_WRITE(sCELL_NAME    => cTEMS,
                                  iCELL_INDEX_X => 0,
                                  iCELL_INDEX_Y => n,
                                  sCELL_VALUE   => rmtr.tema_rest);
    end if;
  end loop;

  /* Удаление образцов строк */
  PRSG_EXCEL.LINE_DELETE(sLINE_NAME => cLINE);

  /* удаление колонки */
  if nvl(nSIGN_ALL, 0) = 0 then
    PRSG_EXCEL.COLUMN_DELETE(sCOLUMN_NAME => cCOL);
  end if;

end;
/
