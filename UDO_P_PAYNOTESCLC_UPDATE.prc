create or replace procedure UDO_P_PAYNOTESCLC_UPDATE
(
  nRN                       in number,       -- Регистрационный номер
  nCOMPANY                  in number,       -- Организация
  sNUMB                     in varchar2,     -- Номер строки
  sCOST_ARTICLE             in varchar2,     -- Мнемокод статьи затрат
  sCOST_PLACE               in varchar2,     -- Мнемокод места возникновения затрат
  nSUM_PLAN                 in number,       -- Сумма затрат план
  nSUM_FACT                 in number,       -- Сумма затрат факт
  nPRIORITY                 in number,       -- Приоритет
  sFACEACCOUNT              in varchar2,     -- Номер лицевого счёта
  sGRAPHPOINT               in varchar2,     -- Мнемокод точки графика лицевого счета
  sFINOPER_TYPE             in varchar2,     -- Мнемокод вида финансовой операции
  sSUBDIV                   in varchar2      -- Мнемокод подразделения
)
as
  nCRN                      PKG_STD.tREF;    -- Каталог
  nJUR_PERS                 PKG_STD.tREF;    -- Юридическое лицо
  nCOST_ARTICLE             PKG_STD.tREF;    -- Статья затрат
  nCOST_PLACE               PKG_STD.tREF;    -- Место возникновения затрат
  nFACEACCOUNT              PKG_STD.tREF;    -- Лицевой счёт
  nGRAPHPOINT               PKG_STD.tREF;    -- Точка графика лицевого счета
  nFINOPER_TYPE             PKG_STD.tREF;    -- Вид финансовой операции
  nSUBDIV                   PKG_STD.tREF;    -- Подразделение
begin
  /* считывание записи */
  P_PAYNOTESCLC_EXISTS(nRN, nCOMPANY, nCRN, nJUR_PERS);


  /* Разрешение ссылок */
  P_PAYNOTESCLC_JOINS
  (
    nCOMPANY,
    sCOST_ARTICLE,
    sCOST_PLACE,
    sFACEACCOUNT,
    sGRAPHPOINT,
    sFINOPER_TYPE,
    sSUBDIV,
    nCOST_ARTICLE,
    nCOST_PLACE,
    nFACEACCOUNT,
    nGRAPHPOINT,
    nFINOPER_TYPE,
    nSUBDIV
  );

  /* Базовое исправление */
  P_PAYNOTESCLC_BASE_UPDATE
  (
    nRN,
    nCOMPANY,
    sNUMB,
    nCOST_ARTICLE,
    nCOST_PLACE,
    nSUM_PLAN,
    nSUM_FACT,
    nPRIORITY,
    nFACEACCOUNT,
    nGRAPHPOINT,
    nFINOPER_TYPE,
    nSUBDIV
  );


end;
/
