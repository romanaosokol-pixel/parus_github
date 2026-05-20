create or replace procedure UDO_P_PAYNOTESCLC_INSERT
(
  nCOMPANY                  in number,       -- Организация
  nPRN                      in number,       -- Родитель
  sNUMB                     in varchar2,     -- Номер строки
  sCOST_ARTICLE             in varchar2,     -- Мнемокод статьи затрат
  sCOST_PLACE               in varchar2,     -- Мнемокод места возникновения затрат
  nSUM_PLAN                 in number,       -- Сумма затрат план
  nSUM_FACT                 in number,       -- Сумма затрат факт
  nPRIORITY                 in number,       -- Приоритет
  sFACEACCOUNT              in varchar2,     -- Номер лицевого счёта
  sGRAPHPOINT               in varchar2,     -- Мнемокод точки графика лицевого счета
  sFINOPER_TYPE             in varchar2,     -- Мнемокод вида финансовой операции
  sSUBDIV                   in varchar2,     -- Мнемокод подразделения
  nRN                       out number       -- Регистрационный номер
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

/* Стандартная процедура добавления калькуляции журнала платежей, но без пролога и эпилога 
для нашего действия "Добавить калькуляцию 
*/

  /* считывание записи */
  P_PAYNOTES_EXISTS(nCOMPANY, nPRN, nCRN, nJUR_PERS);


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

  /* Базовое добавление */
  P_PAYNOTESCLC_BASE_INSERT
  (
    nCOMPANY,
    nPRN,
    sNUMB,
    nCOST_ARTICLE,
    nCOST_PLACE,
    nSUM_PLAN,
    nSUM_FACT,
    nPRIORITY,
    nFACEACCOUNT,
    nGRAPHPOINT,
    nFINOPER_TYPE,
    nSUBDIV,
    nRN
  );

end;
/
