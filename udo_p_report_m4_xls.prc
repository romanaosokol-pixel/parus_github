create or replace procedure UDO_P_REPORT_M4_XLS
/*Пользовательский отчет ПРИХОДНЫЙ ОРДЕР (М-4)*/
(
  NCOMPANY    in number, -- Организация
  NIDENT      in number,
  SPODPISANT1 in varchar2, -- Подписант   
  SKLADOVSHIK in varchar2, -- Кладовщик
  NFLAG       in number, -- 1 - в подписи "Сдал" печатать отвенственного по Вх. счету
  NNOTE       in number, -- 0- не выводить примечание 1 - выводить
  SSKLADPRIKHOD in varchar2, -- Склад приходования
  nreturn      in number -- Учесть возвраты
) is
begin
  UDO_PKG_REPORT_M4_XLS.XLS_MAKE(NCOMPANY    => NCOMPANY,
                                 NIDENT      => NIDENT,
                                 SPODPISANT1 => SPODPISANT1,
                                 SKLADOVSHIK => SKLADOVSHIK,
                                 NFLAG       => NFLAG,
                                 NNOTE       => NNOTE,
                                 SSKLADPRIKHOD => SSKLADPRIKHOD,
                                 nreturn => nreturn);
end;
-- grant execute on UDO_P_REPORT_M4_XLS to public
/
