create or replace procedure UDO_P_PAYACCINSPCLC_INSERT
(
  nCOMPANY                  in number,       -- Организация
  nPRN                      in number,       -- Родитель
  sNUMB                     in varchar2,     -- Номер строки
  sCOST_ARTICLE             in varchar2,     -- Мнемокод статьи затрат
  sCOST_PLACE               in varchar2,     -- Мнемокод места возникновения затрат
  nCOST_PLAN                in number,       -- Затраты на единицу план
  nCOST_FACT                in number,       -- Затраты на единицу факт
  nPRIORITY                 in number,       -- Приоритет
  sFACEACCOUNT              in varchar2,     -- Номер лицевого счёта
  sGRAPHPOINT               in varchar2,     -- Мнемокод точки графика лицевого счета
  sFINOPER_TYPE             in varchar2,     -- Мнемокод вида финансовой операции
  nQUANT_PLAN               in number,       -- Количество план
  nQUANT_FACT               in number,       -- Количество факт
  sSUBDIV                   in varchar2,     -- Мнемокод подразделения
  nRN                       out number       -- Регистрационный номер
)
as
  nCRN                      PKG_STD.tREF;    -- Каталок
  nCOST_ARTICLE             PKG_STD.tREF;    -- Статья затрат
  nCOST_PLACE               PKG_STD.tREF;    -- Место возникновения затрат
  nFACEACCOUNT              PKG_STD.tREF;    -- Лицевой счёт
  nGRAPHPOINT               PKG_STD.tREF;    -- Точка графика лицевого счета
  nFINOPER_TYPE             PKG_STD.tREF;    -- Вид финансовой операции
  nSUBDIV                   PKG_STD.tREF;    -- Подразделение
begin
  /* поиск записи */
  begin
    select CRN
      into nCRN
      from PAYACCINSPEC
     where RN = nPRN;
  exception
    when NO_DATA_FOUND then
      PKG_MSG.RECORD_NOT_FOUND(nRN, 'PaymentAccountsInSpecs');
  end;

  /* фиксация начала выполнения действия */
  ---PKG_ENV.PROLOGUE( nCOMPANY,null,nCRN,null,null,'PaymentAccountsInSpecsCalcs','PAYACCINSPCLC_INSERT','PAYACCINSPCLC' );

  /* Разрешение ссылок */
  P_PAYACCINSPCLC_JOINS
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
  P_PAYACCINSPCLC_BASE_INSERT
  (
    nCOMPANY,
    nPRN,
    sNUMB,
    nCOST_ARTICLE,
    nCOST_PLACE,
    nCOST_PLAN,
    nCOST_FACT,
    nPRIORITY,
    nFACEACCOUNT,
    nGRAPHPOINT,
    nFINOPER_TYPE,
    nQUANT_PLAN,
    nQUANT_FACT,
    nSUBDIV,
    nRN
  );

  /* фиксация окончания выполнения действия */
 --- PKG_ENV.EPILOGUE( nCOMPANY,null,nCRN,null,null,'PaymentAccountsInSpecsCalcs','PAYACCINSPCLC_INSERT','PAYACCINSPCLC',nRN );
end;
/
