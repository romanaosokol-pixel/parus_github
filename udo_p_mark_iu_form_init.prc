create or replace procedure UDO_P_MARK_IU_FORM_INIT
/*
   Иницифализация форм размножения/исправления раздела "Показатели"
  */
(
  NRN           number --рег. номер размножаемой/исправляемой записи показателя (null - если простое добавление)
 ,SJUR_PERS     out varchar2 --мнемокод юр. лица по-умолчанию
 ,SCUR          out varchar2 --мнемокод валюты по умолчанию
 ,NVAL          out number --значение
 ,NVAL_MOD      out number --значение (измененное)
 ,NVAL_DIFF     out number --отклонение расчитанного значения от измененного
 ,NVAL_ACC      out number --значение показателя в валюте договора/лицевого счета (расчитанное системой)
 ,NVAL_MOD_ACC  out number --значение показателя в валюте договора/лицевого счета (измененное пользователем)
 ,NVAL_DIFF_ACC out number --отклонение расчитанного значения от измененного в валюте договора/лицевого счета
 ,NVAL_DOC      out number --значение показателя в валюте документа/платежа/инструмента оплаты (расчитанное системой)
 ,NVAL_MOD_DOC  out number --значение показателя в валюте документа/платежа/инструмента оплаты (измененное пользователем)
 ,NVAL_DIFF_DOC out number --отклонение расчитанного значения от измененного в валюте документа/платежа/инструмента оплаты
 ,DDATE         out date --текущая дата
) is
begin
  --выполним инициализацию
  UDO_PKG_MARK.MARK_IU_FORM_INIT(NRN           => NRN
                                ,SJUR_PERS     => SJUR_PERS
                                ,SCUR          => SCUR
                                ,NVAL          => NVAL
                                ,NVAL_MOD      => NVAL_MOD
                                ,NVAL_DIFF     => NVAL_DIFF
                                ,NVAL_ACC      => NVAL_ACC
                                ,NVAL_MOD_ACC  => NVAL_MOD_ACC
                                ,NVAL_DIFF_ACC => NVAL_DIFF_ACC
                                ,NVAL_DOC      => NVAL_DOC
                                ,NVAL_MOD_DOC  => NVAL_MOD_DOC
                                ,NVAL_DIFF_DOC => NVAL_DIFF_DOC
                                ,DDATE         => DDATE);
end;
--grant execute on UDO_P_MARK_IU_FORM_INIT to public;
/

