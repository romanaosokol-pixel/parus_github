create or replace procedure UDO_P_MARK_INSERT
/*
   Клиентское добавление записи в разделе "Показатели"
  */
(
  NCRN             number --рег. номер каталога
 ,NCOMPANY         number --рег. номер организации
 ,SJUR_PERS        varchar2 --юр. лицо
 ,SMARK_VERS       varchar2 --версия показателя
 ,SMARK_TYPE       varchar2 --тип показателя
 ,SMARK_PREF       varchar2 --префикс
 ,SMARK_NUMB       varchar2 --номер
 ,DMARK_DATE       date --дата показателя
 ,DSTATE_DATE      date --дата показателя "по состоянию на"
 ,DDO_ACT_FROM     date --дата начала действия показателя
 ,DDO_ACT_TO       date --дата окончания действия показателя
 ,DDATE_FROM       date --период с
 ,DDATE_TO         date --период по
 ,SSUBDIV          varchar2 --подразделение
 ,SAGENT           varchar2 --контрагент
 ,SAGNACC          varchar2 --реквизит контрагента
 ,SPAYTOOL         varchar2 --инструмент оплаты
 ,SFINFLOWTYPE     varchar2 --вид движения
 ,SFINOPER         varchar2 --финансовая операция
 ,SFINSTATE        varchar2 --состояние
 ,SFPDARTCL        varchar2 --статья
 ,SFACEACC         varchar2 --лицевой счет
 ,SGRAPHPOINT      varchar2 --точка графика
 ,SCOST_PLACE      varchar2 --место возникновения затрат
 ,SCOST_FPDARTCL   varchar2 --статья затрат
 ,SCOST_FACEACC    varchar2 --лицевой счет затрат
 ,SCOST_GRAPHPOINT varchar2 --точка графика затрат
 ,SCOST_GR         varchar2 --группа затрат
 ,NVAL             number --значение
 ,NVAL_MOD         number --значение (измененное)
 ,SMEAS            varchar2 --единица измерения
 ,SCURRENCY        varchar2 --валюта
 ,NVAL_ACC         number --значение показателя в валюте договора/лицевого счета (расчитанное системой)
 ,NVAL_MOD_ACC     number --значение показателя в валюте договора/лицевого счета (измененное пользователем)
 ,SCURRENCY_ACC    varchar2 --валюта договора/лицевого счета
 ,NCURBASE_ACC     number --курс валюты договора/лицевого счета к курсу БВ
 ,NCURCOURS_ACC    number --котировка валюты договора/лицевого счета к БВ
 ,NVAL_DOC         number --значение показателя в валюте документа/платежа/инструмента оплаты (расчитанное системой)
 ,NVAL_MOD_DOC     number --значение показателя в валюте документа/платежа/инструмента оплаты (измененное пользователем)
 ,SCURRENCY_DOC    varchar2 --валюта документа/платежа/инструмента оплаты
 ,NCURBASE_DOC     number --курс валюты документа/платежа/инструмента оплаты к курсу БВ
 ,NCURCOURS_DOC    number --котировка валюты документа/платежа/инструмента оплаты к БВ
 ,SBALUNIT         varchar2 --ПБЕ
 ,SACCOUNT         varchar2 --номер счета
 ,SANALYTIC1       varchar2 --аналитика 1 уровня
 ,SANALYTIC2       varchar2 --аналитика 2 уровня
 ,SANALYTIC3       varchar2 --аналитика 3 уровня
 ,SANALYTIC4       varchar2 --аналитика 4 уровня
 ,SANALYTIC5       varchar2 --аналитика 5 уровня
 ,SPAY_TYPE        varchar2 --вид оплаты
 ,NPAY_SIGN        number --тип платежа
 ,SNOTE            varchar2 --примечание
 ,ALLOC_ARTS_NMB   varchar2 --- Подстатья (сейчас номер лицевого счета)
 ,NDUPRN           number := null --рег. номер размножаемой записи показателя 
 ,NRN              out number --рег. номер показателя
) as --клиентское добавление в разделе "Показатели"
begin
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY  => NCOMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => NCRN
                  ,SJUR_PERS => SJUR_PERS
                  ,SUNIT     => 'Marks'
                  ,SACTION   => 'UDO_P_MARK_INSERT'
                  ,STABLE    => 'UDO_T_MARK');
  --выполним добавление
  UDO_PKG_MARK.MARK_INSERT(NCRN             => NCRN
                          ,NCOMPANY         => NCOMPANY
                          ,SJUR_PERS        => SJUR_PERS
                          ,SMARK_VERS       => SMARK_VERS
                          ,SMARK_TYPE       => SMARK_TYPE
                          ,SMARK_PREF       => SMARK_PREF
                          ,SMARK_NUMB       => SMARK_NUMB
                          ,DMARK_DATE       => DMARK_DATE
                          ,DSTATE_DATE      => DSTATE_DATE
                          ,DDO_ACT_FROM     => DDO_ACT_FROM
                          ,DDO_ACT_TO       => DDO_ACT_TO
                          ,DDATE_FROM       => DDATE_FROM
                          ,DDATE_TO         => DDATE_TO
                          ,SSUBDIV          => SSUBDIV
                          ,SAGENT           => SAGENT
                          ,SAGNACC          => SAGNACC
                          ,SPAYTOOL         => SPAYTOOL
                          ,SFINFLOWTYPE     => SFINFLOWTYPE
                          ,SFINOPER         => SFINOPER
                          ,SFINSTATE        => SFINSTATE
                          ,SFPDARTCL        => SFPDARTCL
                          ,SFACEACC         => SFACEACC
                          ,SGRAPHPOINT      => SGRAPHPOINT
                          ,SCOST_PLACE      => SCOST_PLACE
                          ,SCOST_FPDARTCL   => SCOST_FPDARTCL
                          ,SCOST_FACEACC    => SCOST_FACEACC
                          ,SCOST_GRAPHPOINT => SCOST_GRAPHPOINT
                          ,SCOST_GR         => SCOST_GR
                          ,NVAL             => NVAL
                          ,NVAL_MOD         => NVAL_MOD
                          ,SMEAS            => SMEAS
                          ,SCURRENCY        => SCURRENCY
                          ,NVAL_ACC         => NVAL_ACC
                          ,NVAL_MOD_ACC     => NVAL_MOD_ACC
                          ,SCURRENCY_ACC    => SCURRENCY_ACC
                          ,NCURBASE_ACC     => NCURBASE_ACC
                          ,NCURCOURS_ACC    => NCURCOURS_ACC
                          ,NVAL_DOC         => NVAL_DOC
                          ,NVAL_MOD_DOC     => NVAL_MOD_DOC
                          ,SCURRENCY_DOC    => SCURRENCY_DOC
                          ,NCURBASE_DOC     => NCURBASE_DOC
                          ,NCURCOURS_DOC    => NCURCOURS_DOC
                          ,SBALUNIT         => SBALUNIT
                          ,SACCOUNT         => SACCOUNT
                          ,SANALYTIC1       => SANALYTIC1
                          ,SANALYTIC2       => SANALYTIC2
                          ,SANALYTIC3       => SANALYTIC3
                          ,SANALYTIC4       => SANALYTIC4
                          ,SANALYTIC5       => SANALYTIC5
                          ,SPAY_TYPE        => SPAY_TYPE
                          ,NPAY_SIGN        => NPAY_SIGN
                          ,SNOTE            => SNOTE
                          ,NDUPRN           => NDUPRN
                          ,NRN              => NRN);
  --регистрация окончания дейстия
  PKG_ENV.EPILOGUE(NCOMPANY  => NCOMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => NCRN
                  ,SJUR_PERS => SJUR_PERS
                  ,SUNIT     => 'Marks'
                  ,SACTION   => 'UDO_P_MARK_INSERT'
                  ,STABLE    => 'UDO_T_MARK'
                  ,NDOCUMENT => NRN);
end;
--grant execute on UDO_P_MARK_INSERT to public;
/
