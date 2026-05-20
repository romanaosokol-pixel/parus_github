create or replace procedure UDO_P_PRJSTG_ARTCL_INIT
/*
   Инициализация статьи этапа проекта
  */
(
  NRN   number --рег. номер статьи
 ,NMODE number --режим инициализации (1 - инициализация про добавлении, 2 - снятие инициализации при удалении)
) as
  NRN_     number := NRN; --экранирующая переменная с рег. номером статьи
  NPRSTRRN number; --рег. номер статьи структуры цены
  NCOMPANY number; --рег. номер организации
  NPRJTYPE number; --рег. номер типа проекта
  SPROJECT PROJECT.CODE%type; --код проекта
  SSTAGE   PROJECTSTAGE.NUMB%type; --номер этапа
  REC      UDO_V_PRJSTG_ARTCL%rowtype; --инициализируемая запись
begin
  -- считаем инициализируемую запись
  begin
    select T.*
      into REC
      from UDO_V_PRJSTG_ARTCL T
     where T.NRN = NRN_;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(NFLAG_SMART => 0
                              ,NDOCUMENT   => NRN
                              ,SUNIT_TABLE => 'UDO_T_PRJSTG_ARTCL');
  end;
  -- считаем орагнизацию, мнемокод проекта, мнемокод этапа
  begin
    select P.COMPANY
          ,P.CODE
          ,PS.NUMB
          ,P.PRJTYPE
      into NCOMPANY
          ,SPROJECT
          ,SSTAGE
          ,NPRJTYPE
      from PROJECTSTAGE PS
          ,PROJECT      P
     where PS.RN = REC.NPRN
       and P.RN = PS.PRN;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0
                 ,'Неудалось определить этап и проект инициализируемой статьи!');
  end;
  -- если это начальная инициализация
  if (NMODE = 1)
  then
    -- если это была статья структуры цены - добавим её в структуру цены
    if (REC.NSIGN = 1)
    then
      NULL;
      /*UDO_P_PRICE_STRUCT_INSERT(NPRN          => REC.NPRN
                               ,SPRJSTG_ARTCL => REC.SFPDARTCL
                               ,NSUMM         => 0
                               ,DACT_FROM     => REC.DACT_FROM
                               ,SBDOC_TYPE    => null
                               ,SBDOC_NUMB    => null
                               ,DBDOC_DATE    => null
                               ,NRN           => NPRSTRRN);*/
    end if;
    --сформируем планы для этапа (если этап относится к проекту, который подлежит планированию)
    if (UPPER(UDO_F_GET_DOC_PROP_VAL(NDOC  => NPRJTYPE
                                    ,SPROP => 'ПланСебест')) = 'ДА')
    then
      UDO_P_PRJSTG_ARTCL_PLAN_CREATE(NCRN     => null
                                    ,NCOMPANY => NCOMPANY
                                    ,SPROJECT => SPROJECT
                                    ,SSTAGE   => SSTAGE);
      -- пройдем по всем планам и отчетам данного этапа и сформируем там сведения по этой статье
      for PLANS in (select T.RN
                      from UDO_T_PRJSTG_ARTCL_PLAN T
                     where T.STAGE = REC.NPRN)
      loop
        UDO_P_PRJSTG_ARTCL_PL_SP_INIT(NPRN          => PLANS.RN
                                     ,NPRJSTG_ARTCL => REC.NRN
                                     ,NMODE         => NMODE);
      end loop;
    end if;
  end if;
  -- если это снятие инициализации перед удалением
  if (NMODE = 2)
  then
    -- если это была статья структуры цены - удалим её из структуры цены
    if (REC.NSIGN = 1)
    then
      for C in (select T.RN
                  from UDO_T_PRICE_STRUCT T
                 where T.PRN = REC.NPRN
                   and T.PRJSTG_ARTCL = REC.NRN)
      loop
        NULL;
        /*UDO_P_PRICE_STRUCT_DELETE(NRN => C.RN);*/
      end loop;
    end if;
    -- пройдем по всем планам и отчетам данного этапа и удалим оттуда сведения по этой статье
    for PLANS in (select T.RN
                    from UDO_T_PRJSTG_ARTCL_PLAN T
                   where T.STAGE = REC.NPRN)
    loop
      UDO_P_PRJSTG_ARTCL_PL_SP_INIT(NPRN          => PLANS.RN
                                   ,NPRJSTG_ARTCL => REC.NRN
                                   ,NMODE         => NMODE);
    end loop;
    -- пройдем по всем планам эьлшл этапа и удалим пустые
    for PLANS in (select T.RN
                    from UDO_T_PRJSTG_ARTCL_PLAN T
                   where T.STAGE = REC.NPRN
                     and (select count(SP.RN)
                            from UDO_T_PRJSTG_ARTCL_PLAN_SP SP
                           where SP.PRN = T.RN) = 0
                     and (select count(R.RN)
                            from UDO_T_PRJSTG_ARTCL_PLAN_RS R
                           where R.PRN = T.RN) = 0)
    loop
      UDO_P_PRJSTG_ARTCL_PLAN_DEL(NRN => PLANS.RN);
    end loop;
  end if;
end UDO_P_PRJSTG_ARTCL_INIT;
/

