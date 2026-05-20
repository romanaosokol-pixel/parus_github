create or replace package UDO_PKG_SYSW0002_UTILS as

  /*
   Набор дополнительных процедур и функций для работы WEB-интерфейса
  */

  --транслитерация русской строки в английскую
  function STR_TRANSLATE(SSTR_RU varchar2 --строка с русскими символами (CL8MSWIN1251)
                         ) return varchar2;

  --проверка прав доступа на просмотр персональных данных
  function F_PEOPLE_OPIS_DOK(NCOMPANY number --рег. номер организации
                             ) return number;

  --оклад/тарифная ставка работника в штате на текущую дату
  function F_SCHTAT_OKLTS
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number;

  --оклад/тарифная ставка работника в штате на заданную дату чистый (как есть)
  function F_SCHTAT_OKLTS_D_NOREG
  (
    NRN      in number --рег. номер исполнения
   ,DDATE    in date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number;

  --оклад/тарифная ставка работника в штате на заданную дату с учетом режима работы
  function F_SCHTAT_OKLTS_D
  (
    NRN      in number --рег. номер исполнения
   ,DDATE    in date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number;

  --оклад/тарифная ставка работника в штате на заданную дату с учетом режима работы
  --последнее значение на дату
  function F_SCHTAT_OKLTS_DLAST
  (
    NRN      in number --рег. номер исполнения
   ,DDATE    in date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number;

  --процент(коэфф) в ФОТе для Оклада или ТС
  function F_SCHTAT_REGIM_D
  (
    NRN      in number --рег. номер исполнения
   ,DDATE    in date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number;

  --режим работы работника в штате на текущую дату (задается как процент(коэфф) в ФОТе для оклада или тарифной ставки)
  function F_SCHTAT_PROCENT(NRN in number --рег. номер исполнения
                            ) return number;

  --режим работы работника в штате на заданную дату (задается как процент(коэфф) в ФОТе для оклада или тарифной ставки)
  function F_SCHTAT_PROCENT_D
  (
    NRN   in number --рег. номер исполнения
   ,DDATE in date --дата
  ) return number;

  --режим работы работника в штате на заданную дату (задается как процент(коэфф) в ФОТе для оклада или тарифной ставки)
  --последнее значение на дату
  function F_SCHTAT_PROCENT_DLAST
  (
    NRN   in number --рег. номер исполнения
   ,DDATE in date --дата
  ) return number;

  --фонд оплаты труда сотдрудника по рег. номеру исполнения
  function F_FOT
  (
    NRN      in number --рег. номер исполнения должности
   ,DDATE    in date --дата
   ,SKOD     in varchar --код по нашей з/п
   ,NTYPERET in number --возвращаемое значение: 0 - сумма, 1 - процент
   ,NREGIM   in number --режим: 0 - последнее значение для даты, 1 - точное значение для даты
  ) return number;

  --Персональная надбавка сотдрудника по рег. номеру исполнения
  function F_FOT_PERS
  (
    NRN    in number --рег. номер исполнения должности
   ,DDATE  in date --дата
   ,SKOD   in varchar --код дохода
   ,NREGIM in number --режим: 0 - последнее значение для даты, 1 - точное значение для даты
  ) return number;

  --ученая степень работника в штате на заданную дату
  function F_SCHTAT_UCHST_D
  (
    NRN      in number --рег. номер исполнения
   ,DDATE    in date --дата
   ,NCOMPANY number --рег. номер орагниазации
  ) return number;

  --значение ежемесячной премии
  function F_FOT063
  (
    NRN    in number --рег. номеер исполнения должности
   ,DDATE  in date --дата
   ,NREGIM in number --режим: 0 - последнее значение для даты, 1 - точное значение для даты
  ) return number;

  --расчет суммы фонда оплаты труда исполнения должности на дату
  function F_SCHTAT_FOT
  (
    NCOMPANY in number --рег. номер организации
   ,NPFMRN   in number --рег. номер исполнения должности
   ,DDATE    in date --дата на дату
  ) return number;

  --расчет суммы персональной надбавки исполнения должности на дату
  function F_SCHTAT_PERS
  (
    NPFMRN in number --рег. номер исполнения должности
   ,DDATE  in date --дата на дату
  ) return number;

  --расчет суммы выплаты по подразделению за указанный месяц
  function F_DEP_PAY
  (
    NCOMPANY in number --рег. номер организации
   ,NDEPRN   in number --рег. номер подразделения
   ,NYEAR    in number --год
   ,NMONTH   in number --месяц
   ,SCODEPAY in varchar2 --код выплаты (или null для всех)
   ,SCODERB  in varchar --код раздела бюджета (или null если все)
  ) return number;

  --расчет суммы фонда оплаты труда подразделения на дату
  function F_DEP_FOT
  (
    NCOMPANY in number --рег. номер организации
   ,NDEPRN   in number --рег. номер подразделения
   ,DDATE    in date --дата
   ,SCODERB  in varchar --код раздела бюджета (или null если все)
  ) return number;

  --расчет суммы выплаченной (фактической) персональной надбавки подразделения за период
  function F_DEP_PERS_PAY
  (
    NCOMPANY in number --рег. номер организации
   ,NDEPRN   in number --рег. номер подразделения
   ,NYEAR    in number --год
   ,NMONTH   in number --месяц
   ,SCODERB  in varchar --код раздела бюджета (или null если все)
  ) return number;

  --расчет суммы персональной надбавки подразделения на дату
  function F_DEP_PERS
  (
    NCOMPANY in number --рег. номер организации
   ,NDEPRN   in number --рег. номер подразделения
   ,DDATE    in date --дата
   ,SCODERB  in varchar --код раздела бюджета (или null если все)
  ) return number;

  --должность работника в штате
  function F_SCHTAT_DOLG
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return varchar;

  --кол-во ставок исполнения должности в штате на текущую дату
  function F_SCHTAT_COUNTFACT
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number;

  --разряд рабочего в штате на текущую дату
  function F_SCHTAT_RAZRAD
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number;

  --разряд рабочего в штате на заданную дату
  function F_SCHTAT_RAZRAD_D
  (
    NRN      in number --рег. номер исполнения
   ,DDATE    in date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number;

  --кол-во ставок должности в штатном расписании на текущую дату
  function F_SCHTATR_COUNT
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер штатной должности
  ) return number;

  --кол-во ставок должности в штатном расписании на дату
  function F_SCHTATR_COUNT_D
  (
    NRN      in number --рег. номер штатной должности
   ,DDATE    date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number;

  --кол-во ставок исполнения должности в штатном расписании на текущую дату
  function F_SCHTATR_COUNTFACT
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер штатной должности
  ) return number;

  --кол-во ставок исполнения должности в штатном расписании на дату
  function F_SCHTATR_COUNTFACT_D
  (
    NRN      in number --рег. номер шатной должности
   ,DDATE    date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number;

  --категория должности в штатном расписании
  function F_SCHTATR_KATEGOR
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер должности
  ) return varchar;

  --ФИО работника (спецификации для табеля)
  function F_TABELSP_FIO
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return varchar;

  --Вид исполнения работника (Рук, Спец, Рабочий ...) (спецификации для табеля)
  function F_TABELSP_KATEGOR
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return varchar;

  --Вид исполнения работника (спецификации для табеля)
  function F_TABELSP_VIDISP
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return varchar;

  --График работы работника (спецификации для табеля)
  function F_TABELSP_GRAFIK
  (
    NCOMPANY number --рег. номер организации
   ,NPFMRN   number --рег. номер исполнения
   ,NTMBRDRN number --рег. номер табеля
  ) return varchar;

  --рабочих дней (тип дня не задан или это "Я")
  function F_TABELSP_DAY
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number;

  --дней неявки по табелю (тип дня задан и это не "Я"и не "В")
  function F_TABELSP_DAYNO
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return varchar;

  --дней неявки по основному и дополнительному табелю (тип дня задан и это не "Я"и не "В")
  function F_TABELSP_DAYNO_ALL
  (
    NCOMPANY number --рег. номер организации
   ,NRN_F    in number --рег. номер исполнения основного табеля
   ,NRN      in number --рег. номер исполнения дополнительного табеля
  ) return varchar;

  --всего часов по табелю
  function F_TABELSP_HOUR_ALL
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number;

  --часов по табелю (по заданному типу)
  function F_TABELSP_HOUR_SETCODE
  (
    NCOMPANY  number --рег. номер организации
   ,NRN       in number --рег. номер исполнения
   ,SCODEHOUR in varchar2 --код типов часов
  ) return number;

  --дневные часы по табелю
  function F_TABELSP_HOUR_DAY
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number;

  --ночные часы по табелю
  function F_TABELSP_HOUR_NIGHT
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number;

  --выходные и праздничные часы по табелю
  function F_TABELSP_HOUR_WEEK
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number;

  --сверурочные часы по табелю
  function F_TABELSP_HOUR_SVERH
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number;

  --признак и группа инвалидности  (спецификации для табеля)
  function F_TABELSP_INVALID
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return varchar;

  --получение ранга должности
  function F_POST_RANK(NPOST number --рег. номер должности
                       ) return number RESULT_CACHE deterministic;

  --возраст сотрудника
  function F_PERSON_AGE(NPERSON number --рег. номер сотрудника
                        ) return varchar2;

  --стаж работы
  function F_PERSON_STAGE(NPERSON number --рег. номер сотрудника
                          ) return varchar2;

  --ученая степень
  function F_PERSON_EDUC(NPERSON number --рег. номер сотрудника
                         ) return varchar2;

end;
/

create or replace package body UDO_PKG_SYSW0002_UTILS as

  /*
   Набор дополнительных процедур и функций для работы WEB-интерфейса
  */

  --транслитерация русской строки в английскую
  function STR_TRANSLATE(SSTR_RU varchar2 --строка с русскими символами (CL8MSWIN1251)
                         ) return varchar2 is
    SRES varchar2(4000);
  begin
    SRES := TRANSLATE(UPPER(SSTR_RU)
                     ,'АБВГДЕЗИЙКЛМНОПРСТУФЬЫЪЭ'
                     ,'ABVGDEZIJKLMNOPRSTUF''Y''E');
    SRES := replace(SRES
                   ,'Ж'
                   ,'ZH');
    SRES := replace(SRES
                   ,'Х'
                   ,'KH');
    SRES := replace(SRES
                   ,'Ц'
                   ,'TS');
    SRES := replace(SRES
                   ,'Ч'
                   ,'CH');
    SRES := replace(SRES
                   ,'Ш'
                   ,'SH');
    SRES := replace(SRES
                   ,'Щ'
                   ,'SH');
    SRES := replace(SRES
                   ,'Ю'
                   ,'YU');
    SRES := replace(SRES
                   ,'Я'
                   ,'YA');
    return SRES;
  end;

 --проверка прав доступа на просмотр персональных данных
  function F_PEOPLE_OPIS_DOK(NCOMPANY number --рег. номер организации
                             ) return number is
    NRES number := 0;
  begin
    select count(UR.RN)
      into NRES
      from USERROLES UR
          ,ROLES     R
     where UR.AUTHID = UDO_F_SYSW0001_GET_USER(NCOMPANY)
       and UR.ROLEID = R.RN
       and R.ROLENAME =
           UDO_F_GET_CONST_VAL(NCOMPANY
                                      ,'WEB_РОЛЬ_ПРОСМ_ОПИС_ДОК_ШТАТ');
    return NRES;
  exception
    when others then
      return NRES;
  end;

  --оклад/тарифная ставка работника в штате на текущую дату
  function F_SCHTAT_OKLTS
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number is
    NRES CLNPSPFMGS.CLNRATE%type;
  begin
    --проверка полномочий (роль 'КАДРЫ Просмотр значений описателей документов')
    if F_PEOPLE_OPIS_DOK(NCOMPANY => NCOMPANY) = 0
    then
      return null;
    end if;
    --
    NRES := F_SCHTAT_OKLTS_D(NRN      => NRN
                            ,DDATE    => sysdate
                            ,NCOMPANY => NCOMPANY);
    return NRES;
  exception
    when others then
      return null;
  end;

  --оклад/тарифная ставка работника в штате на заданную дату чистый (как есть)
  function F_SCHTAT_OKLTS_D_NOREG
  (
    NRN      in number --рег. номер исполнения
   ,DDATE    in date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number is
    NRES          CLNPSPFMGS.CLNRATE%type;
    GSCODE_CONST1 CONSTLST.NAME%type := 'КФОТ_ОКЛАД';
    GSCODE_CONST2 CONSTLST.NAME%type := 'КФОТ_ОКЛАДТС';
    GSCODE_CONST3 CONSTLST.NAME%type := 'КФОТ_ЧСВРЕМТС';
    GSCODE_CONST4 CONSTLST.NAME%type := 'КФОТ_ЧССДЕЛТС';
    GSCODE_1      GRSALARY.CODE%type;
    GSCODE_2      GRSALARY.CODE%type;
    GSCODE_3      GRSALARY.CODE%type;
    GSCODE_4      GRSALARY.CODE%type;
    NGS_1         GRSALARY.RN%type;
    NGS_2         GRSALARY.RN%type;
    NGS_3         GRSALARY.RN%type;
    NGS_4         GRSALARY.RN%type;
    NTMP          number;
    DTMP          date;
  begin
    --поиск рег. номера оклада
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST1
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_1
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_1
                      ,NRN          => NGS_1);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST2
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_2
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_2
                      ,NRN          => NGS_2);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST3
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_3
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_3
                      ,NRN          => NGS_3);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST4
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_4
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_4
                      ,NRN          => NGS_4);
    begin
      --вычисление суммы
      select sum(CG.CLNRATE)
        into NRES
        from CLNPSPFMGS CG
            ,GRSALARY   GS
       where CG.PRN = NRN
         and GS.RN = CG.GRSALARY
         and GS.RN in (NGS_1
                      ,NGS_2
                      ,NGS_3
                      ,NGS_4)
         and CG.DO_ACT_FROM <= TRUNC(DDATE)
         and (CG.DO_ACT_TO >= TRUNC(DDATE) or CG.DO_ACT_TO is null); -- действующее исполнение
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return NRES;
  exception
    when others then
      return null;
  end;

  --оклад/тарифная ставка работника в штате на заданную дату c учетом режима раб
  function F_SCHTAT_OKLTS_D
  (
    NRN      in number --рег. номер исполнения
   ,DDATE    in date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number is
    NPROC         CLNPSPFMGS.CLNRATE%type;
    NRES          CLNPSPFMGS.CLNRATE%type;
    GSCODE_CONST1 CONSTLST.NAME%type := 'КФОТ_ОКЛАД';
    GSCODE_CONST2 CONSTLST.NAME%type := 'КФОТ_ОКЛАДТС';
    GSCODE_CONST3 CONSTLST.NAME%type := 'КФОТ_ЧСВРЕМТС';
    GSCODE_CONST4 CONSTLST.NAME%type := 'КФОТ_ЧССДЕЛТС';
    GSCODE_1      GRSALARY.CODE%type;
    GSCODE_2      GRSALARY.CODE%type;
    GSCODE_3      GRSALARY.CODE%type;
    GSCODE_4      GRSALARY.CODE%type;
    NGS_1         GRSALARY.RN%type;
    NGS_2         GRSALARY.RN%type;
    NGS_3         GRSALARY.RN%type;
    NGS_4         GRSALARY.RN%type;
    NTMP          number;
    DTMP          date;
  begin
    --поиск рег. номера оклада
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST1
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_1
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_1
                      ,NRN          => NGS_1);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST2
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_2
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_2
                      ,NRN          => NGS_2);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST3
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_3
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_3
                      ,NRN          => NGS_3);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST4
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_4
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_4
                      ,NRN          => NGS_4);
    begin
      --вычисление суммы
      select sum(CG.CLNRATE)
        into NRES
        from CLNPSPFMGS CG
            ,GRSALARY   GS
       where CG.PRN = NRN
         and GS.RN = CG.GRSALARY
         and GS.RN in (NGS_1
                      ,NGS_2
                      ,NGS_3
                      ,NGS_4)
         and CG.DO_ACT_FROM <= TRUNC(DDATE)
         and (CG.DO_ACT_TO >= TRUNC(DDATE) or CG.DO_ACT_TO is null); -- действующее исполнение
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    --отрабатываем процентовку в ФОТе
    NPROC := F_SCHTAT_REGIM_D(NRN
                             ,DDATE
                             ,NCOMPANY);
    if NPROC = 0 or NPROC = 100 or NPROC is null
    then
      --полная отработка
      return NRES;
    else
      --умножим на процент
      return NRES * NPROC / 100;
    end if;
  exception
    when others then
      return null;
  end;

  --оклад/тарифная ставка работника в штате на заданную дату c учетом режима раб
  --последнее значение на дату
  function F_SCHTAT_OKLTS_DLAST
  (
    NRN      in number --рег. номер исполнения
   ,DDATE    in date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number is
    NRES          CLNPSPFMGS.CLNRATE%type;
    GSCODE_CONST1 CONSTLST.NAME%type := 'КФОТ_ОКЛАД';
    GSCODE_CONST2 CONSTLST.NAME%type := 'КФОТ_ОКЛАДТС';
    GSCODE_CONST3 CONSTLST.NAME%type := 'КФОТ_ЧСВРЕМТС';
    GSCODE_CONST4 CONSTLST.NAME%type := 'КФОТ_ЧССДЕЛТС';
    GSCODE_1      GRSALARY.CODE%type;
    GSCODE_2      GRSALARY.CODE%type;
    GSCODE_3      GRSALARY.CODE%type;
    GSCODE_4      GRSALARY.CODE%type;
    NGS_1         GRSALARY.RN%type;
    NGS_2         GRSALARY.RN%type;
    NGS_3         GRSALARY.RN%type;
    NGS_4         GRSALARY.RN%type;
    NTMP          number;
    DTMP          date;
  begin
    --поиск рег. номера оклада
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST1
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_1
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_1
                      ,NRN          => NGS_1);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST2
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_2
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_2
                      ,NRN          => NGS_2);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST3
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_3
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_3
                      ,NRN          => NGS_3);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST4
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_4
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_4
                      ,NRN          => NGS_4);
    begin
      --вычисление суммы
      select T.CGCLNRATE
        into NRES
        from (select CG.CLNRATE CGCLNRATE
                from CLNPSPFMGS CG
                    ,GRSALARY   GS
               where CG.PRN = NRN
                 and GS.RN = CG.GRSALARY
                 and GS.RN in (NGS_1
                              ,NGS_2
                              ,NGS_3
                              ,NGS_4)
                 and CG.DO_ACT_FROM <= TRUNC(DDATE) -- действующее исполнение
              --and (CG.DO_ACT_TO >= TRUNC(DDATE) or CG.DO_ACT_TO is null)
               order by CG.DO_ACT_FROM desc) T
       where ROWNUM = 1;
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return NRES;
  exception
    when others then
      return null;
  end;

  --процент(коэфф) в ФОТе для Оклада или ТС
  function F_SCHTAT_REGIM_D
  (
    NRN      in number
   ,DDATE    in date
   ,NCOMPANY number
  ) return number is
    NRES          CLNPSPFMGS.CLNRATE%type;
    GSCODE_CONST1 CONSTLST.NAME%type := 'КФОТ_ОКЛАД';
    GSCODE_CONST2 CONSTLST.NAME%type := 'КФОТ_ОКЛАДТС';
    GSCODE_CONST3 CONSTLST.NAME%type := 'КФОТ_ЧСВРЕМТС';
    GSCODE_CONST4 CONSTLST.NAME%type := 'КФОТ_ЧССДЕЛТС';
    GSCODE_1      GRSALARY.CODE%type;
    GSCODE_2      GRSALARY.CODE%type;
    GSCODE_3      GRSALARY.CODE%type;
    GSCODE_4      GRSALARY.CODE%type;
    NGS_1         GRSALARY.RN%type;
    NGS_2         GRSALARY.RN%type;
    NGS_3         GRSALARY.RN%type;
    NGS_4         GRSALARY.RN%type;
    NTMP          number;
    DTMP          date;
  begin
    --поиск рег. номера оклада
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NVL(NCOMPANY
                                          ,GET_SESSION_COMPANY)
                         ,SNAME     => GSCODE_CONST1
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_1
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NVL(NCOMPANY
                                          ,GET_SESSION_COMPANY)
                      ,SCODE        => GSCODE_1
                      ,NRN          => NGS_1);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NVL(NCOMPANY
                                          ,GET_SESSION_COMPANY)
                         ,SNAME     => GSCODE_CONST2
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_2
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NVL(NCOMPANY
                                          ,GET_SESSION_COMPANY)
                      ,SCODE        => GSCODE_2
                      ,NRN          => NGS_2);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NVL(NCOMPANY
                                          ,GET_SESSION_COMPANY)
                         ,SNAME     => GSCODE_CONST3
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_3
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NVL(NCOMPANY
                                          ,GET_SESSION_COMPANY)
                      ,SCODE        => GSCODE_3
                      ,NRN          => NGS_3);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NVL(NCOMPANY
                                          ,GET_SESSION_COMPANY)
                         ,SNAME     => GSCODE_CONST4
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_4
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NVL(NCOMPANY
                                          ,GET_SESSION_COMPANY)
                      ,SCODE        => GSCODE_4
                      ,NRN          => NGS_4);
    begin
      --вычисление процента
      select sum(CG.COEFFIC)
        into NRES
        from CLNPSPFMGS CG
            ,GRSALARY   GS
       where CG.PRN = NRN
         and GS.RN = CG.GRSALARY
         and GS.RN in (NGS_1
                      ,NGS_2
                      ,NGS_3
                      ,NGS_4)
         and CG.DIMCOEFF = 0
         and CG.DO_ACT_FROM <= TRUNC(DDATE)
         and (CG.DO_ACT_TO >= TRUNC(DDATE) or CG.DO_ACT_TO is null); -- действующее исполнение на дату
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return NRES;
  exception
    when others then
      return null;
  end;

  --режим работы работника в штате на текущую дату
  function F_SCHTAT_PROCENT(NRN in number --рег. номер исполнения
                            ) return number is
    NRES CLNPSPFMGS.CLNRATE%type;
  begin
    NRES := F_SCHTAT_PROCENT_D(NRN   => NRN
                              ,DDATE => sysdate);
    return NRES;
  exception
    when others then
      return null;
  end;

  --режим работы работника в штате на заданную дату (задается как процент(коэфф) в ФОТе для оклада или тарифной ставки)
  function F_SCHTAT_PROCENT_D
  (
    NRN   in number --рег. номер исполнения
   ,DDATE in date --дата
  ) return number is
    SCATALOG    ACATALOG.NAME%type;
    SCODE       SLSCHEDULE.CODE%type;
    NSCHEDULERN CLNPSPFMHS.SCHEDULE%type;
    NHOUR       SLSCHEDDATE.HOURS_RATE%type;
    NBAZA       SLSCHEDDATE.HOURS_RATE%type := 40; --база 40 часовая рабочая неделя
    NRES        number;
  begin
    begin
      --декретный отпуск
      --
      select SL.CODE
            ,CH.SCHEDULE
            ,AC.NAME
        into SCODE
            ,NSCHEDULERN
            ,SCATALOG
        from CLNPSPFMHS CH
            ,SLSCHEDULE SL
            ,ACATALOG   AC
       where CH.PRN = NRN
         and CH.DO_ACT_FROM <= TRUNC(DDATE)
         and (CH.DO_ACT_TO >= TRUNC(DDATE) or CH.DO_ACT_TO is null) -- действующее исполнение на дату
         and SL.RN = CH.SCHEDULE
         and SL.CRN = AC.RN;
      --если особый случай
      if SCATALOG = 'Суммированный учет' or SCATALOG = 'Графики сменности' or
         SCATALOG = 'Среднегодовая норма' or
         SCATALOG = 'Среднеквартальная норма' or SCODE = 'инвалиды 35ч'
      then
        return null;
      end if;
      --иначе считаем часы и вычисляем процент
      select sum(SD.HOURS_RATE)
        into NHOUR
        from SLSTRSCHEDULE SLD
            ,SLSCHEDDATE   SD
       where SLD.PRN = NSCHEDULERN
         and SLD.RN = SD.PRN(+);
      if NHOUR = NBAZA
      then
        return null;
      else
        NRES := NHOUR * 100 / NBAZA;
      end if;
    exception
      when NO_DATA_FOUND then
        return 0;
    end;
    return NRES;
  end;

  --режим работы работника в штате на заданную дату (задается как процент(коэфф) в ФОТе для оклада или тарифной ставки)
  --последнее значение на дату
  function F_SCHTAT_PROCENT_DLAST
  (
    NRN   in number --рег. номер исполнения
   ,DDATE in date --дата
  ) return number is
    SCATALOG    ACATALOG.NAME%type;
    SCODE       SLSCHEDULE.CODE%type;
    NSCHEDULERN CLNPSPFMHS.SCHEDULE%type;
    NHOUR       SLSCHEDDATE.HOURS_RATE%type;
    NBAZA       SLSCHEDDATE.HOURS_RATE%type := 40; --база 40 часовая рабочая неделя
    NRES        number;
  begin
    begin
      --декретный отпуск
      --
      select T.SLCODE
            ,T.CHSCHEDULE
            ,T.ACNAME
        into SCODE
            ,NSCHEDULERN
            ,SCATALOG
        from (select SL.CODE     SLCODE
                    ,CH.SCHEDULE CHSCHEDULE
                    ,AC.NAME     ACNAME
                from CLNPSPFMHS CH
                    ,SLSCHEDULE SL
                    ,ACATALOG   AC
               where CH.PRN = NRN
                 and CH.DO_ACT_FROM <= TRUNC(DDATE)
                    --and (CH.DO_ACT_TO >= TRUNC(DDATE) or CH.DO_ACT_TO is null) -- действующее исполнение на дату
                 and SL.RN = CH.SCHEDULE
                 and SL.CRN = AC.RN
               order by CH.DO_ACT_FROM desc) T
       where ROWNUM = 1;
      --если особый случай
      if SCATALOG = 'Суммированный учет' or SCATALOG = 'Графики сменности' or
         SCATALOG = 'Среднегодовая норма' or
         SCATALOG = 'Среднеквартальная норма' or SCODE = 'инвалиды 35ч'
      then
        return null;
      end if;
      --иначе считаем часы и вычисляем процент
      select sum(SD.HOURS_RATE)
        into NHOUR
        from SLSTRSCHEDULE SLD
            ,SLSCHEDDATE   SD
       where SLD.PRN = NSCHEDULERN
         and SLD.RN = SD.PRN(+);
      if NHOUR = NBAZA
      then
        return null;
      else
        NRES := NHOUR * 100 / NBAZA;
      end if;
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return NRES;
  end;

  --фонд оплаты труда сотдрудника по рег. номеру исполнения
  function F_FOT
  (
    NRN      in number --рег. номер исполнения должности
   ,DDATE    in date --дата
   ,SKOD     in varchar --код по нашей з/п
   ,NTYPERET in number --возвращаемое значение: 0 - сумма, 1 - процент
   ,NREGIM   in number --режим: 0 - последнее значение для даты, 1 - точное значение для даты
  ) return number is
    NRET_VALUE SLPAYGRNDPRM.NUM_VALUE%type;
  begin
    if NREGIM = 1
    then
      --точное значение для даты
      select SPPRM.NUM_VALUE
        into NRET_VALUE
        from SLPAYGRND     SP
            ,SLPAYGRNDPRM  SPPRM
            ,SLCOMPCHARGES SC
       where SP.PRN = NRN
         and SP.BGNDATE <= DDATE
         and (SP.ENDDATE is null or SP.ENDDATE >= DDATE)
         and SC.RN = SP.SLCOMPCHARGES
         and trim(SC.NUMB) = SKOD
         and SPPRM.PRN = SP.RN
         and ((NTYPERET = 0 and
             (SPPRM.CODE = 'RATEVALUE' or SPPRM.CODE = 'SUM')) --если сумма
             or (NTYPERET = 1 and SPPRM.CODE = 'PRC')); --если процент
    end if;
    if NREGIM = 0
    then
      --последнее значение для даты
      select T.NUM_VALUE
        into NRET_VALUE
        from (select SPPRM.NUM_VALUE
                from SLPAYGRND     SP
                    ,SLPAYGRNDPRM  SPPRM
                    ,SLCOMPCHARGES SC
               where SP.PRN = NRN
                 and SP.BGNDATE <= DDATE
                 and SC.RN = SP.SLCOMPCHARGES
                 and trim(SC.NUMB) = SKOD
                 and SPPRM.PRN = SP.RN
                 and ((NTYPERET = 0 and
                     (SPPRM.CODE = 'RATEVALUE' or SPPRM.CODE = 'SUM')) --если сумма
                     or (NTYPERET = 1 and SPPRM.CODE = 'PRC')) --если процент
               order by SP.BGNDATE desc) T
       where ROWNUM <= 1;
    end if;
    return NRET_VALUE;
  exception
    when others then
      return null;
  end;

  --Персональная надбавка сотдрудника по рег. номеру исполнения
  function F_FOT_PERS
  (
    NRN    in number --рег. номер исполнения должности
   ,DDATE  in date --дата
   ,SKOD   in varchar --код дохода
   ,NREGIM in number --режим: 0 - последнее значение для даты, 1 - точное значение для даты
  ) return number as
    NRET_VALUE SLPAYGRNDPRM.NUM_VALUE%type;
    NRNPODR    CLNPSPFM.DEPTRN%type;
    NRNSOTR    CLNPSPFM.PERSRN%type;
  begin
    if NREGIM = 1
    then
      --точное значение для даты (для текущего исполнения должности)
      select SPPRM.NUM_VALUE
        into NRET_VALUE
        from SLPAYGRND     SP
            ,SLPAYGRNDPRM  SPPRM
            ,SLCOMPCHARGES SC
       where SP.PRN = NRN
         and SP.BGNDATE <= DDATE
         and (SP.ENDDATE is null or SP.ENDDATE >= DDATE)
         and SC.RN = SP.SLCOMPCHARGES
         and trim(SC.NUMB) = SKOD
         and SPPRM.PRN = SP.RN
         and (SPPRM.CODE = 'RATEVALUE' or SPPRM.CODE = 'SUM');
    end if;
    if NREGIM = 0
    then
      --для сотрудника находящегося в данном подразделении
      select CF.DEPTRN
            ,CF.PERSRN
        into NRNPODR
            ,NRNSOTR
        from CLNPSPFM CF
       where CF.RN = NRN;
      --последнее значение для даты
      select T.NUM_VALUE
        into NRET_VALUE
        from (select SPPRM.NUM_VALUE
                from CLNPSPFM      CF
                    ,SLPAYGRND     SP
                    ,SLPAYGRNDPRM  SPPRM
                    ,SLCOMPCHARGES SC
               where CF.DEPTRN = NRNPODR
                 and CF.PERSRN = NRNSOTR
                 and SP.PRN = CF.RN
                 and SP.BGNDATE <= DDATE
                 and SC.RN = SP.SLCOMPCHARGES
                 and trim(SC.NUMB) = SKOD
                 and SPPRM.PRN = SP.RN
                 and (SPPRM.CODE = 'RATEVALUE' or SPPRM.CODE = 'SUM')
               order by SP.BGNDATE desc) T
       where ROWNUM = 1;
    end if;
    return NRET_VALUE;
  exception
    when others then
      return null;
  end;

  --ученая степень работника в штате на заданную дату
  function F_SCHTAT_UCHST_D
  (
    NRN      in number --рег. номер исполнения
   ,DDATE    in date --дата
   ,NCOMPANY number --рег. номер орагниазации
  ) return number is
    NRES               CLNPSPFMGS.COEFFIC%type;
    GSCODE_UCHST_CONST CONSTLST.NAME%type := 'КФОТ_УЧСТЕПЕНЬ';
    GSCODE_UCHST       GRSALARY.CODE%type;
    NGS_UCHST          GRSALARY.RN%type;
    NTMP               number;
    DTMP               date;
  begin
    --поиск рег. номера ученой степени
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_UCHST_CONST
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_UCHST
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_UCHST
                      ,NRN          => NGS_UCHST);
    begin
      --вычисление суммы
      select sum(CG.COEFFIC)
        into NRES
        from CLNPSPFMGS CG
            ,GRSALARY   GS
       where CG.PRN = NRN
         and GS.RN = CG.GRSALARY
         and GS.RN = NGS_UCHST
         and CG.DO_ACT_FROM <= TRUNC(DDATE)
         and (CG.DO_ACT_TO >= TRUNC(DDATE) or CG.DO_ACT_TO is null); -- действующее исполнение
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return NRES;
  exception
    when others then
      return null;
  end;

  --значение ежемесячной премии
  function F_FOT063
  (
    NRN    in number --рег. номеер исполнения должности
   ,DDATE  in date --дата
   ,NREGIM in number --режим: 0 - последнее значение для даты, 1 - точное значение для даты
  ) return number is
    NRET_VALUE SLPAYGRNDPRM.NUM_VALUE%type;
    NVAL       SLPAYGRNDPRM.NUM_VALUE%type;
    NPROC      SLPAYGRNDPRM.NUM_VALUE%type;
  begin
    if NREGIM = 1
    then
      --точное значение для даты
      select (select SPPRM.NUM_VALUE
                from SLPAYGRNDPRM SPPRM
               where SPPRM.PRN = SP.RN
                 and SPPRM.CODE = 'PRC')
            ,(select SPPRM.NUM_VALUE
               from SLPAYGRNDPRM SPPRM
              where SPPRM.PRN = SP.RN
                and SPPRM.CODE = 'NUMERATOR')
        into NVAL
            ,NPROC
        from SLPAYGRND     SP
            ,SLCOMPCHARGES SC
       where SP.PRN = NRN
         and SP.BGNDATE <= DDATE
         and (SP.ENDDATE is null or SP.ENDDATE >= DDATE)
         and SC.RN = SP.SLCOMPCHARGES
         and trim(SC.NUMB) = '063';
    end if;
    if NREGIM = 0
    then
      --последнее значение для даты
      select T.N_VAL
            ,T.N_PROC
        into NVAL
            ,NPROC
        from (select (select SPPRM.NUM_VALUE
                        from SLPAYGRNDPRM SPPRM
                       where SPPRM.PRN = SP.RN
                         and SPPRM.CODE = 'PRC') as N_VAL
                    ,(select SPPRM.NUM_VALUE
                        from SLPAYGRNDPRM SPPRM
                       where SPPRM.PRN = SP.RN
                         and SPPRM.CODE = 'NUMERATOR') as N_PROC
                from SLPAYGRND     SP
                    ,SLCOMPCHARGES SC
               where SP.PRN = NRN
                 and SP.BGNDATE <= DDATE
                 and SC.RN = SP.SLCOMPCHARGES
                 and trim(SC.NUMB) = '063'
               order by SP.BGNDATE desc) T
       where ROWNUM <= 1;
    end if;
    NVAL       := NVL(NVAL
                     ,0);
    NPROC      := NVL(NPROC
                     ,100);
    NRET_VALUE := ROUND(NVAL * NPROC / 100
                       ,2);
    return NVL(NRET_VALUE
              ,0);
  exception
    when others then
      return null;
  end;

  --расчет суммы фонда оплаты труда исполнения должности на дату
  function F_SCHTAT_FOT
  (
    NCOMPANY in number ----рег. номер организации
   ,NPFMRN   in number --рег. номер исполнения должности
   ,DDATE    in date --дата на дату
  ) return number is
    NSUMFOT   number := 0;
    NOKLADTS  number; --оклад/ТС
    NWORKPRS  number; --режим работы
    NSREDHOUR number := 166; --среднемесячно часов
  begin
    NOKLADTS := NVL(F_SCHTAT_OKLTS_D(NPFMRN
                                    ,DDATE
                                    ,NCOMPANY)
                   ,0);
    NWORKPRS := NVL(F_SCHTAT_PROCENT_D(NPFMRN
                                      ,DDATE)
                   ,100);
    if NOKLADTS < 1000
    then
      --это тарифная ставка
      NOKLADTS := NOKLADTS * NSREDHOUR * NWORKPRS / 100;
    else
      --это оклад
      NOKLADTS := NOKLADTS * NWORKPRS / 100;
    end if;
    --добавили окладный фонд с учетом режима работы
    NSUMFOT := NSUMFOT + NOKLADTS;
    --надбавку за секретность
    NSUMFOT := NSUMFOT + NOKLADTS * NVL(F_FOT(NPFMRN
                                             ,DDATE
                                             ,'035'
                                             ,1
                                             ,1)
                                       ,0) / 100;
    --учетную степень
    NSUMFOT := NSUMFOT + NOKLADTS * NVL(F_SCHTAT_UCHST_D(NPFMRN
                                                        ,DDATE
                                                        ,NCOMPANY)
                                       ,0) / 100;
    --бригадирские
    NSUMFOT := NSUMFOT +
               (NVL(F_FOT(NPFMRN
                         ,DDATE
                         ,'022'
                         ,0
                         ,1)
                   ,0) + NVL(F_FOT(NPFMRN
                                   ,DDATE
                                   ,'019'
                                   ,0
                                   ,1)
                             ,0)) * NWORKPRS / 100;
    --персональную надбавку (последнее значение для даты)
    /*    NSUMFOT := NSUMFOT + NVL(F_FOT(NPFMRN
          ,DDATE
          ,'013'
          ,0
          ,0)
    ,0) * NWORKPRS / 100;*/
    --Журавлев 31.10.2012
    NSUMFOT := NSUMFOT + NVL(F_FOT_PERS(NPFMRN
                                       ,DDATE
                                       ,'013'
                                       ,0)
                            ,0) * NWORKPRS / 100;
    --НГД
    NSUMFOT := NSUMFOT + NVL(F_FOT(NPFMRN
                                  ,DDATE
                                  ,'014'
                                  ,0
                                  ,1)
                            ,0) * NWORKPRS / 100;
    --РЗО
    NSUMFOT := NSUMFOT + NVL(F_FOT(NPFMRN
                                  ,DDATE
                                  ,'051'
                                  ,0
                                  ,1)
                            ,0) * NWORKPRS / 100;
    --ежемесячную премию (точное значение для даты)
    NSUMFOT := NSUMFOT + NOKLADTS * NVL(F_FOT063(NPFMRN
                                                ,DDATE
                                                ,1)
                                       ,0) / 100;
    --единовременную премию
    NSUMFOT := NSUMFOT + NVL(F_FOT(NPFMRN
                                  ,DDATE
                                  ,'064'
                                  ,0
                                  ,1)
                            ,0);
    return NVL(NSUMFOT
              ,0);
  end;

  --расчет суммы персональной надбавки исполнения должности на дату
  function F_SCHTAT_PERS
  (
    NPFMRN in number --рег. номер исполнения должности
   ,DDATE  in date --дата на дату
  ) return number is
    NSUMFOT  number := 0;
    NWORKPRS number; --режим работы
  begin
    NWORKPRS := NVL(F_SCHTAT_PROCENT_D(NPFMRN
                                      ,DDATE)
                   ,100);
    --персональную надбавку (последнее значение для даты)
    /*    NSUMFOT := NVL(F_FOT(NPFMRN
                            ,DDATE
                            ,'013'
                            ,0
                            ,0)
                      ,0) * NWORKPRS / 100;
    */
    --Журавлев 31.10.2012
    NSUMFOT := NVL(F_FOT_PERS(NPFMRN
                             ,DDATE
                             ,'013'
                             ,0)
                  ,0) * NWORKPRS / 100;
    return NVL(NSUMFOT
              ,0);
  end;

  --расчет суммы выплаты по подразделению за указанный месяц
  function F_DEP_PAY
  (
    NCOMPANY in number --рег. номер организации
   ,NDEPRN   in number --рег. номер подразделения
   ,NYEAR    in number --год
   ,NMONTH   in number --месяц
   ,SCODEPAY in varchar2 --код выплаты (или null для всех)
   ,SCODERB  in varchar --код раздела бюджета (или null если все)
  ) return number is
    NSUMPAY number := 0;
    NRB     number := 0;
    SRBUDCF varchar2(50);
    DDATEB  date;
    DDATEE  date;
  begin
    --определим даты начала и окончания месяца
    DDATEB := TO_DATE('01.' || LPAD(NMONTH
                                   ,2
                                   ,'0') || '.' || NYEAR
                     ,'dd.mm.yyyy');
    DDATEE := LAST_DAY(DDATEB);
    --идем по выплатам
    /*for PAY in (select FM.RN NCFRN --рег. номер исполнения
                      ,INSD.RN NIDRN --рег. номер подразделения
                      ,P.SUM NSUMM --сумма
                      ,UDO_F_GET_DOC_PROP_VAL(FM.RN
                                             ,'РазделБюджета') SRBUD --раздел бюджета исполнения должности
                  from SLPAYS         P
                      ,SLCOMPCHARGES  CH
                      ,CLNPSPFM       FM
                      ,CLNPSDEP       PSD
                      ,INS_DEPARTMENT INSD
                 where P.SLCOMPCHARGES = CH.RN
                   and P.CLNPSPFM = FM.RN
                   and P.YEARFOR = NYEAR
                   and P.MONTHFOR = NMONTH
                   and P.COMPANY = NCOMPANY
                   and ((SCODEPAY is null) or
                       ((SCODEPAY is not null) and (trim(CH.NUMB) = SCODEPAY)))
                   and FM.PSDEPRN = PSD.RN
                   and PSD.DEPTRN = INSD.RN
                   and INSD.RN in
                       (select T.RN
                          from INS_DEPARTMENT T
                         where T.COMPANY = NCOMPANY
                           and T.BGNDATE <= DDATEB
                           and (T.ENDDATE >= DDATEE or (T.ENDDATE is null))
                        connect by prior T.RN = T.PRN
                         start with T.RN = NDEPRN))
    loop
      --если раздел(ы) бюджета задан
      if (SCODERB is null)
      then
        NRB := 1;
      else
        --опредили раздел бюджета тек. исполнения должности
        if (PAY.SRBUD is not null)
        then
          --если раздел задан как доп.свойство
          SRBUDCF := PAY.SRBUD;
        else
          --иначе определяем по подразделению
          begin
            select U.SRB
              into SRBUDCF
              from (select UDO_P_OFZ407_DEPART_RB(TT.RN
                                                 ,DDATEE) SRB
                      from INS_DEPARTMENT TT
                     where UDO_P_OFZ407_DEPART_RB(TT.RN
                                                 ,DDATEE) is not null
                    connect by prior TT.PRN = TT.RN
                     start with TT.RN = PAY.NIDRN) U
             where ROWNUM = 1;
          exception
            when NO_DATA_FOUND then
              SRBUDCF := 'РАЗДЕЛ НЕ ОПРЕДЕЛЕН';
          end;
        end if;
        --проверяем принадлежность к указанному разделу бюджета
        if (trim(SCODERB) = trim(SRBUDCF))
        then
          NRB := 1;
        end if;
      end if;
      if (NRB = 1)
      then
        --по каждому исполнению должности
        NSUMPAY := NSUMPAY + PAY.NSUMM;
      end if;
    end loop;*/
    return NSUMPAY;
  exception
    when others then
      return 0;
  end;

  --расчет суммы фонда оплаты труда подразделения на дату
  function F_DEP_FOT
  (
    NCOMPANY in number --рег. номер организации
   ,NDEPRN   in number --рег. номер подразделения
   ,DDATE    in date --дата
   ,SCODERB  in varchar --код раздела бюджета (или null если все)
  ) return number is
    NSUMFOT number := 0;
    NRB     number := 0;
    SRBUDCF varchar2(50);
  begin
    --цикл по исполнениям внутри заданного подразделения на дату (с вложением)
    /*for C in (select CF.RN NCFRN --рег. номер исполнения
                    ,ID.RN NIDRN --рег. номер подразделения
                    ,UDO_F_GET_DOC_PROP_VAL(CF.RN
                                           ,'РазделБюджета') SRBUD --раздел бюджета исполнения должности
                from CLNPSPFM       CF
                    ,CLNPSPFMHS     CFH
                    ,INS_DEPARTMENT ID
               where CF.COMPANY = NCOMPANY
                 and CF.BEGENG <= DDATE
                 and (CF.ENDENG >= DDATE or CF.ENDENG is null)
                 and CFH.PRN = CF.RN
                 and (TRUNC(CFH.DO_ACT_FROM) <= DDATE and
                     (TRUNC(CFH.DO_ACT_TO) >= DDATE or CFH.DO_ACT_TO is null))
                 and CF.DEPTRN = ID.RN
                 and CF.DEPTRN in
                     (select T.RN
                        from INS_DEPARTMENT T
                       where T.COMPANY = NCOMPANY
                         and T.BGNDATE <= DDATE
                         and (T.ENDDATE >= DDATE or (T.ENDDATE is null))
                      connect by prior T.RN = T.PRN
                       start with T.RN = NDEPRN))
    loop
      --обнулим
      NRB := 0;
      --если раздел(ы) бюджета задан
      if SCODERB is null
      then
        NRB := 1;
      else
        --опредили раздел бюджета тек. исполнения должности
        if C.SRBUD is not null
        then
          --если раздел задан как доп.свойство
          SRBUDCF := C.SRBUD;
        else
          --иначе определяем по подразделению
          begin
            select U.SRB
              into SRBUDCF
              from (select UDO_P_OFZ407_DEPART_RB(TT.RN
                                                 ,DDATE) SRB
                      from INS_DEPARTMENT TT
                     where UDO_P_OFZ407_DEPART_RB(TT.RN
                                                 ,DDATE) is not null
                    connect by prior TT.PRN = TT.RN
                     start with TT.RN = C.NIDRN) U
             where ROWNUM = 1;
          exception
            when NO_DATA_FOUND then
              SRBUDCF := 'РАЗДЕЛ НЕ ОПРЕДЕЛЕН';
          end;
        end if;
        --проверяем принадлежность к указанному разделу бюджета
        if trim(SCODERB) = trim(SRBUDCF)
        then
          NRB := 1;
        end if;
      end if;
      if NRB = 1
      then
        --по каждому исполнению должности
        NSUMFOT := NSUMFOT + F_SCHTAT_FOT(NCOMPANY => NCOMPANY
                                         ,NPFMRN   => C.NCFRN
                                         ,DDATE    => DDATE);
      end if;
    end loop;*/
    return NVL(NSUMFOT
              ,0);
  exception
    when others then
      return 0;
  end;

  --расчет суммы выплаченной (фактической) персональной надбавки подразделения за период
  function F_DEP_PERS_PAY
  (
    NCOMPANY in number --рег. номер организации
   ,NDEPRN   in number --рег. номер подразделения
   ,NYEAR    in number --год
   ,NMONTH   in number --месяц
   ,SCODERB  in varchar --код раздела бюджета (или null если все)
  ) return number is
  begin
    return F_DEP_PAY(NCOMPANY => NCOMPANY
                    ,NDEPRN   => NDEPRN
                    ,NYEAR    => NYEAR
                    ,NMONTH   => NMONTH
                    ,SCODEPAY => '013'
                    ,SCODERB  => SCODERB);
  end;

  --расчет суммы персональной надбавки подразделения на дату
  function F_DEP_PERS
  (
    NCOMPANY in number --рег. номер организации
   ,NDEPRN   in number --рег. номер подразделения
   ,DDATE    in date --дата
   ,SCODERB  in varchar --код раздела бюджета (или null если все)
  ) return number is
    NSUMFOT number := 0;
    NRB     number := 0;
    SRBUDCF varchar2(50);
  begin
    --цикл по исполнениям внутри заданного подразделения на дату (с вложением)
    /*for C in (select CF.RN NCFRN --рег. номер исполнения
                    ,ID.RN NIDRN --рег. номер подразделения
                    ,UDO_F_GET_DOC_PROP_VAL(CF.RN
                                           ,'РазделБюджета') SRBUD --раздел бюджета исполнения должности
                from CLNPSPFM       CF
                    ,CLNPSPFMHS     CFH
                    ,INS_DEPARTMENT ID
               where CF.COMPANY = NCOMPANY
                 and CF.BEGENG <= DDATE
                 and (CF.ENDENG >= DDATE or CF.ENDENG is null)
                 and CFH.PRN = CF.RN
                 and (TRUNC(CFH.DO_ACT_FROM) <= DDATE and
                     (TRUNC(CFH.DO_ACT_TO) >= DDATE or CFH.DO_ACT_TO is null))
                 and CF.DEPTRN = ID.RN
                 and CF.DEPTRN in
                     (select T.RN
                        from INS_DEPARTMENT T
                       where T.COMPANY = NCOMPANY
                         and T.BGNDATE <= DDATE
                         and (T.ENDDATE >= DDATE or (T.ENDDATE is null))
                      connect by prior T.RN = T.PRN
                       start with T.RN = NDEPRN))
    loop
      --обнулим
      NRB := 0;
      --если раздел(ы) бюджета задан
      if (SCODERB is null)
      then
        NRB := 1;
      else
        --опредили раздел бюджета тек. исполнения должности
        if (C.SRBUD is not null)
        then
          --если раздел задан как доп.свойство
          SRBUDCF := C.SRBUD;
        else
          --иначе определяем по подразделению
          begin
            select U.SRB
              into SRBUDCF
              from (select UDO_P_OFZ407_DEPART_RB(TT.RN
                                                 ,DDATE) SRB
                      from INS_DEPARTMENT TT
                     where UDO_P_OFZ407_DEPART_RB(TT.RN
                                                 ,DDATE) is not null
                    connect by prior TT.PRN = TT.RN
                     start with TT.RN = C.NIDRN) U
             where ROWNUM = 1;
          exception
            when NO_DATA_FOUND then
              SRBUDCF := 'РАЗДЕЛ НЕ ОПРЕДЕЛЕН';
          end;
        end if;
        --проверяем принадлежность к указанному разделу бюджета
        if (trim(SCODERB) = trim(SRBUDCF))
        then
          NRB := 1;
        end if;
      end if;
      if NRB = 1
      then
        --по каждому исполнению должности
        NSUMFOT := NSUMFOT + F_SCHTAT_PERS(NPFMRN => C.NCFRN
                                          ,DDATE  => DDATE);
      end if;
    end loop;*/
    return NVL(NSUMFOT
              ,0);
  exception
    when others then
      return 0;
  end;

  --должность работника в штате
  function F_SCHTAT_DOLG
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return varchar is
    SRES CLNPSDEP.PSDEP_NAME%type := '';
  begin
    begin
      select CD.PSDEP_NAME
        into SRES
        from CLNPSPFM CF
            ,CLNPSDEP CD
       where CF.RN = NRN
         and CD.RN = CF.PSDEPRN
         and CD.COMPANY = NCOMPANY;
    exception
      when NO_DATA_FOUND then
        return '';
    end;
    return SRES;
  exception
    when others then
      return '';
  end;

  --кол-во ставок исполнения должности в штате на текущую дату
  function F_SCHTAT_COUNTFACT
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number is
    NRES CLNPSPFMHS.RATEACC%type;
  begin
    begin
      select sum(CH.RATEACC)
        into NRES
        from CLNPSPFMHS CH
       where CH.PRN = NRN
         and CH.COMPANY = NCOMPANY
         and CH.DO_ACT_FROM <= TRUNC(sysdate)
         and (CH.DO_ACT_TO is null or CH.DO_ACT_TO >= TRUNC(sysdate)); -- действующее исполнение
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    if NRES = 0
    then
      return null;
    else
      return NRES;
    end if;
  exception
    when others then
      return null;
  end;

  --разряд рабочего в штате на текущую дату
  function F_SCHTAT_RAZRAD
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number is
    NRES CLNPSPFMGS.CLNGRADE%type;
  begin
    --проверка полномочий (роль 'КАДРЫ Просмотр значений описателей документов')
    if F_PEOPLE_OPIS_DOK(NCOMPANY => NCOMPANY) = 0
    then
      return null;
    end if;
    --
    NRES := F_SCHTAT_RAZRAD_D(NRN      => NRN
                             ,DDATE    => sysdate
                             ,NCOMPANY => NCOMPANY);
    return NRES;
  exception
    when others then
      return null;
  end;

  --разряд рабочего в штате на заданную дату
  function F_SCHTAT_RAZRAD_D
  (
    NRN      in number --рег. номер исполнения
   ,DDATE    in date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number is
    NRES          CLNPSPFMGS.CLNGRADE%type;
    GSCODE_CONST1 CONSTLST.NAME%type := 'КФОТ_ОКЛАДТС';
    GSCODE_1      GRSALARY.CODE%type;
    NGS_1         GRSALARY.RN%type;
    GSCODE_CONST2 CONSTLST.NAME%type := 'КФОТ_ЧСВРЕМТС';
    GSCODE_2      GRSALARY.CODE%type;
    NGS_2         GRSALARY.RN%type;
    GSCODE_CONST3 CONSTLST.NAME%type := 'КФОТ_ЧССДЕЛТС';
    GSCODE_3      GRSALARY.CODE%type;
    NGS_3         GRSALARY.RN%type;
    NTMP          number;
    DTMP          date;
  begin
    --поиск рег. номера тарифной ставки
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST1
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_1
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_1
                      ,NRN          => NGS_1);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST2
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_2
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_2
                      ,NRN          => NGS_2);
    FIND_CONSTANT_BY_NAME(NCOMPANY  => NCOMPANY
                         ,SNAME     => GSCODE_CONST3
                         ,DFROM     => null
                         ,CHECKONLY => 0
                         ,NTYPE     => NTMP
                         ,NVALUE    => NTMP
                         ,SVALUE    => GSCODE_3
                         ,DVALUE    => DTMP);
    FIND_GRSALARY_CODE(NFLAG_SMART  => 1
                      ,NFLAG_OPTION => 1
                      ,NCOMPANY     => NCOMPANY
                      ,SCODE        => GSCODE_3
                      ,NRN          => NGS_3);
    begin
      --берем значение разряда
      select CG.CLNGRADE
        into NRES
        from CLNPSPFMGS CG
            ,GRSALARY   GS
       where CG.PRN = NRN
         and GS.RN = CG.GRSALARY
         and GS.RN in (NGS_1
                      ,NGS_2
                      ,NGS_3)
         and CG.DO_ACT_FROM <= TRUNC(DDATE)
         and (CG.DO_ACT_TO >= TRUNC(DDATE) or CG.DO_ACT_TO is null); -- действующее исполнение
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return NRES;
  exception
    when others then
      return null;
  end;

  --кол-во ставок должности в штатном расписании на текущую дату
  function F_SCHTATR_COUNT
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер штатной должности
  ) return number is
    NRES CLNPSDEPHS.RATEACC%type;
  begin
    NRES := F_SCHTATR_COUNT_D(NRN      => NRN
                             ,DDATE    => sysdate
                             ,NCOMPANY => NCOMPANY);
    return NRES;
  end;

  --кол-во ставок должности в штатном расписании на дату
  function F_SCHTATR_COUNT_D
  (
    NRN      in number --рег. номер штатной должности
   ,DDATE    date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number is
    NRES CLNPSDEPHS.RATEACC%type;
  begin
    begin
      select CS.RATEACC
        into NRES
        from CLNPSDEPHS CS
       where CS.PRN = NRN
         and CS.COMPANY = NCOMPANY
         and CS.DO_ACT_FROM <= TRUNC(DDATE)
         and (CS.DO_ACT_TO >= TRUNC(DDATE) or CS.DO_ACT_TO is null); -- действующее исполнение
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    if NRES = 0
    then
      return null;
    else
      return NRES;
    end if;
  exception
    when others then
      return null;
  end;

  --кол-во ставок исполнения должности в штатном расписании на текущую дату
  function F_SCHTATR_COUNTFACT
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер штатной должности
  ) return number is
    NRES CLNPSPFMHS.RATEACC%type;
  begin
    NRES := F_SCHTATR_COUNTFACT_D(NRN      => NRN
                                 ,DDATE    => sysdate
                                 ,NCOMPANY => NCOMPANY);
    return NRES;
  end;

  --кол-во ставок исполнения должности в штатном расписании на дату
  function F_SCHTATR_COUNTFACT_D
  (
    NRN      in number --рег. номер шатной должности
   ,DDATE    date --дата
   ,NCOMPANY number --рег. номер организации
  ) return number is
    NRES   CLNPSPFMHS.RATEACC%type := 0;
    NVAC   number; --признак что должность вакантна
    NVACNO number; --признак что должность занята
  begin
    for C in (select CP.RN
                    ,CH.RATEACC
                from CLNPSPFM   CP
                    ,CLNPSPFMHS CH
               where CP.PSDEPRN = NRN
                 and CP.COMPANY = NCOMPANY
                 and CP.RN = CH.PRN
                 and CP.BEGENG <= TRUNC(DDATE)
                 and (CP.ENDENG >= TRUNC(DDATE) or CP.ENDENG is null)
                 and CH.DO_ACT_FROM <= TRUNC(DDATE)
                 and (CH.DO_ACT_TO >= TRUNC(DDATE) or CH.DO_ACT_TO is null))
    loop
      --поиск записи в состоянии исполнения что на дату должность вакантна
      select count(CS.RN)
        into NVAC
        from CLNPSPFMST CS
       where CS.PRN = C.RN
         and CS.BEGIN_DATE <= TRUNC(DDATE)
         and (CS.END_DATE >= TRUNC(DDATE) or CS.END_DATE is null)
         and CS.VACANT = 1
         and CS.REVERSE_ENTRY = 0;
      --
      select count(CS.RN)
        into NVACNO
        from CLNPSPFMST CS
       where CS.PRN = C.RN
         and CS.BEGIN_DATE <= TRUNC(DDATE)
         and (CS.END_DATE >= TRUNC(DDATE) or CS.END_DATE is null)
         and CS.VACANT = 0
         and CS.REVERSE_ENTRY = 1;
      --
      if NVAC - NVACNO = 0
      then
        NRES := NRES + C.RATEACC;
      end if;
    end loop;
    if NRES = 0
    then
      return null;
    else
      return NRES;
    end if;
  exception
    when others then
      return null;
  end;

  --категория должности в штатном расписании
  function F_SCHTATR_KATEGOR
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер должности
  ) return varchar is
    SRES OFFICERCLS.CODE%type;
  begin
    begin
      select OFF.CODE
        into SRES
        from CLNPSDEP   CD
            ,OFFICERCLS OFF
       where CD.RN = NRN
         and CD.COMPANY = NCOMPANY
         and OFF.RN = CD.OFFICERCLS;
      return SRES;
    exception
      when NO_DATA_FOUND then
        return null;
    end;
  end;

  --ФИО работника (спецификации для табеля)
  function F_TABELSP_FIO
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return varchar is
    SRES AGNLIST.AGNFAMILYNAME%type;
  begin
    begin
      select trim(AG.AGNFAMILYNAME) || ' ' ||
             SUBSTR(AG.AGNFIRSTNAME
                   ,1
                   ,1) || '.' || SUBSTR(AG.AGNLASTNAME
                                       ,1
                                       ,1) || '.'
        into SRES
        from CLNPSPFM   CF
            ,CLNPERSONS PR
            ,AGNLIST    AG
       where CF.RN = NRN
         and CF.COMPANY = NCOMPANY
         and PR.RN = CF.PERSRN
         and PR.PERS_AGENT = AG.RN;
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return SRES;
  exception
    when others then
      return null;
  end;

  --Вид исполнения работника (Рук, Спец, Рабочий ...) (спецификации для табеля)
  function F_TABELSP_KATEGOR
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return varchar is
    SRES OFFICERCLS.CODE%type;
  begin
    begin
      select OL.CODE
        into SRES
        from CLNPSPFM   CF
            ,OFFICERCLS OL
       where CF.COMPANY = NCOMPANY
         and CF.RN = NRN
         and OL.RN = CF.OFFICERCLS;
      return SRES;
    exception
      when others then
        return null;
    end;
  end;

  --Вид исполнения работника (спецификации для табеля)
  function F_TABELSP_VIDISP
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return varchar is
    SRES CLNPSPFMTYPES.CODE%type;
  begin
    begin
      select CFT.CODE
        into SRES
        from CLNPSPFM      CF
            ,CLNPSPFMTYPES CFT
       where CF.COMPANY = NCOMPANY
         and CF.RN = NRN
         and CFT.RN = CF.CLNPSPFMTYPES;
      return SRES;
    exception
      when others then
        return null;
    end;
  end;

  --График работы работника (спецификации для табеля)
  function F_TABELSP_GRAFIK
  (
    NCOMPANY number --рег. номер организации
   ,NPFMRN   number --рег. номер исполнения
   ,NTMBRDRN number --рег. номер табеля
  ) return varchar is
    SRES SLSCHEDULE.CODE%type;
  begin
    begin
      select M.SSLCODE
        into SRES
        from (select CH.DO_ACT_FROM DMAXFROM
                    ,SL.CODE        SSLCODE
                from CLNPSPFMHS CH
                    ,SLSCHEDULE SL
               where CH.PRN = NPFMRN
                 and CH.COMPANY = NCOMPANY
                 and TRUNC(CH.DO_ACT_FROM) <=
                     TRUNC((select TM.ENDDATE --дата конца периода табеля
                             from TMBOARD TM
                            where TM.RN = NTMBRDRN))
                 and CH.SCHEDULE = SL.RN
               order by 1 desc) M
       where ROWNUM = 1;
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return SRES;
  end;

  --рабочих дней (тип дня не задан или это "_")
  function F_TABELSP_DAY
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number is
    NRES number;
  begin
    select count(D.RN)
      into NRES
      from TMBOARDDAY D
          ,SLDAYSTYPE T
     where D.COMPANY = NCOMPANY
       and D.PRN = NRN
       and D.DAYSTYPE = T.RN(+)
       and (D.DAYSTYPE is null or
           (D.DAYSTYPE is not null and trim(T.CODE) = '_'));
    return NRES;
  exception
    when others then
      return null;
  end;

  --дней неявки по табелю (тип дня задан и это не "_" и не "В")
  function F_TABELSP_DAYNO
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return varchar is
    SRES   varchar(50) := '';
    NCOUNT number;
  begin
    for C in (select distinct D.DAYSTYPE NDAYSTYPE
                             ,T.CODE     SCODE
                from TMBOARDDAY D
                    ,SLDAYSTYPE T
               where D.PRN = NRN
                 and D.DAYSTYPE = T.RN
                 and T.ABSENCE_SIGN = 1
                 and trim(T.CODE) not in ('_'
                                         ,'В'))
    loop
      select count(D.RN)
        into NCOUNT
        from TMBOARDDAY D
       where D.COMPANY = NCOMPANY
         and D.PRN = NRN
         and D.DAYSTYPE = C.NDAYSTYPE;
      SRES := SRES || trim(TO_CHAR(NCOUNT)) || '_' || trim(LOWER(C.SCODE)) || ' ';
    end loop;
    return SRES;
  exception
    when others then
      return null;
  end;

  --дней неявки по основному и дополнительному табелю (тип дня задан и это не "_" и не "В")
  function F_TABELSP_DAYNO_ALL
  (
    NCOMPANY number --рег. номер организации
   ,NRN_F    in number --рег. номер исполнения основного табеля
   ,NRN      in number --рег. номер исполнения дополнительного табеля
  ) return varchar is
    SRES   varchar(50) := '';
    NCOUNT number;
  begin
    for C in (select distinct D.DAYSTYPE NDAYSTYPE
                             ,T.CODE     SCODE
                from TMBOARDDAY D
                    ,SLDAYSTYPE T
               where D.PRN in (NRN
                              ,NRN_F)
                 and D.DAYSTYPE = T.RN
                 and trim(T.CODE) not in ('_'
                                         ,'В'))
    loop
      select count(D.RN)
        into NCOUNT
        from TMBOARDDAY D
       where D.COMPANY = NCOMPANY
         and D.PRN in (NRN
                      ,NRN_F)
         and D.DAYSTYPE = C.NDAYSTYPE;
      SRES := SRES || trim(TO_CHAR(NCOUNT)) || '_' || trim(LOWER(C.SCODE)) || ' ';
    end loop;
    return SRES;
  exception
    when others then
      return null;
  end;

  --всего часов по табелю
  function F_TABELSP_HOUR_ALL
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number is
    NRES number := 0;
  begin
    begin
      select sum(H.WORKEDHOURS)
        into NRES
        from TMBOARDDAY  D
            ,TMBOARDHOUR H
       where D.COMPANY = NCOMPANY
         and D.PRN = NRN
         and H.PRN = D.RN;
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return NRES;
  exception
    when others then
      return null;
  end;

  --часов по табелю (по заданному типу)
  function F_TABELSP_HOUR_SETCODE
  (
    NCOMPANY  number --рег. номер организации
   ,NRN       in number --рег. номер исполнения
   ,SCODEHOUR in varchar2 --код типов часов
  ) return number is
    NRES number := 0;
  begin
    begin
      select sum(H.WORKEDHOURS)
        into NRES
        from TMBOARDDAY     D
            ,TMBOARDHOUR    H
            ,SL_HOURS_TYPES HT
       where D.COMPANY = NCOMPANY
         and D.PRN = NRN
         and H.PRN = D.RN
         and HT.RN = H.HOURSTYPE
         and trim(HT.CODE) = SCODEHOUR;
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return NRES;
  exception
    when others then
      return null;
  end;

  --дневные часы по табелю
  function F_TABELSP_HOUR_DAY
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number is
    NRES number := 0;
  begin
    begin
      select sum(H.WORKEDHOURS)
        into NRES
        from TMBOARDDAY     D
            ,TMBOARDHOUR    H
            ,SL_HOURS_TYPES HT
       where D.COMPANY = NCOMPANY
         and D.PRN = NRN
         and H.PRN = D.RN
         and HT.RN = H.HOURSTYPE
         and trim(HT.CODE) = 'Дневные';
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return NRES;
  exception
    when others then
      return null;
  end;

  --ночные часы по табелю
  function F_TABELSP_HOUR_NIGHT
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number is
    NRES number := 0;
  begin
    begin
      select sum(H.WORKEDHOURS)
        into NRES
        from TMBOARDDAY     D
            ,TMBOARDHOUR    H
            ,SL_HOURS_TYPES HT
       where D.COMPANY = NCOMPANY
         and D.PRN = NRN
         and H.PRN = D.RN
         and HT.RN = H.HOURSTYPE
         and trim(HT.CODE) = 'Ночные';
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return NRES;
  exception
    when others then
      return null;
  end;

  --выходные и праздничные часы по табелю
  function F_TABELSP_HOUR_WEEK
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number is
    NRES number := 0;
  begin
    begin
      select sum(H.WORKEDHOURS)
        into NRES
        from TMBOARDDAY     D
            ,TMBOARDHOUR    H
            ,SL_HOURS_TYPES HT
       where D.COMPANY = NCOMPANY
         and D.PRN = NRN
         and H.PRN = D.RN
         and HT.RN = H.HOURSTYPE
         and trim(HT.CODE) in ('Вых. и праздн. Д'
                              ,'Вых. и праздн. Н');
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return NRES;
  exception
    when others then
      return null;
  end;

  --сверурочные часы по табелю
  function F_TABELSP_HOUR_SVERH
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return number is
    NRES number := 0;
  begin
    begin
      select sum(H.WORKEDHOURS)
        into NRES
        from TMBOARDDAY     D
            ,TMBOARDHOUR    H
            ,SL_HOURS_TYPES HT
       where D.COMPANY = NCOMPANY
         and D.PRN = NRN
         and H.PRN = D.RN
         and HT.RN = H.HOURSTYPE
         and trim(HT.CODE) in ('Сверхурочные до 2ч'
                              ,'Сверхурочные от 2ч');
    exception
      when NO_DATA_FOUND then
        return null;
    end;
    return NRES;
  exception
    when others then
      return null;
  end;

  --признак и группа инвалидности  (спецификации для табеля)
  function F_TABELSP_INVALID
  (
    NCOMPANY number --рег. номер организации
   ,NRN      in number --рег. номер исполнения
  ) return varchar is
    NRES AGNDISABLED.GRPDISABLED%type;
  begin
    begin
      select AD.GRPDISABLED
        into NRES
        from CLNPSPFM    CF
            ,CLNPERSONS  CL
            ,AGNDISABLED AD --инвалиды
       where CF.COMPANY = NCOMPANY
         and CF.RN = NRN
         and CL.RN = CF.PERSRN
         and AD.PRN = CL.PERS_AGENT
         and TRUNC(AD.DATEBEG) <= TRUNC(sysdate)
         and (TRUNC(AD.DATEEND) >= TRUNC(sysdate) or AD.DATEEND is null)
         and ROWNUM = 1;
      case
        when NRES = 0 then
          return 'I группа';
        when NRES = 1 then
          return 'II группа';
        when NRES = 2 then
          return 'III группа';
        else
          return '? группа';
      end case;
    exception
      when others then
        return null;
    end;
  end;

  --получение ранга должности
  function F_POST_RANK(NPOST number --рег. номер должности
                       ) return number RESULT_CACHE deterministic is
    NRES number := 1000;
  begin
    select TO_NUMBER(REGEXP_REPLACE(P.CODE
                                   ,'[[:alpha:][:space:][:punct:]]'
                                   ,''))
      into NRES
      from CLNPOSTS P
          ,INS_POST M
     where P.RN = NPOST
       and P.TYPPOSTRN = M.RN(+)
       and LOWER(M.CODE) not like 'раб%';
    return NRES;
  exception
    when others then
      return NRES;
  end;

  --возраст сотрудника
  function F_PERSON_AGE(NPERSON number --рег. номер сотрудника
                        ) return varchar2 is
    SRES     varchar2(2000) := null;
    NCOMPANY COMPANIES.RN%type;
  begin
    --найдем организацию
    select T.COMPANY
      into NCOMPANY
      from CLNPERSONS T
     where T.RN = NPERSON;
    --проверка полномочий (роль 'КАДРЫ Просмотр значений описателей документов')
    if (F_PEOPLE_OPIS_DOK(NCOMPANY => NCOMPANY)) = 0
    then
      return SRES;
    end if;
    --вычислим возразст
    select TRUNC(MONTHS_BETWEEN(sysdate
                               ,A.AGNBURN) / 12) || '/' ||
           TRUNC((MONTHS_BETWEEN(sysdate
                                ,A.AGNBURN) -
                 TRUNC(MONTHS_BETWEEN(sysdate
                                      ,A.AGNBURN) / 12) * 12))
      into SRES
      from CLNPERSONS P
          ,AGNLIST    A
     where P.RN = NPERSON
       and P.PERS_AGENT = A.RN;
    return SRES;
  exception
    when others then
      return SRES;
  end;

  --стаж работы
  function F_PERSON_STAGE(NPERSON number --рег. номер сотрудника
                          ) return varchar2 is
    SRES     varchar2(2000) := null;
    NCOMPANY COMPANIES.RN%type;
  begin
    --найдем организацию
    select T.COMPANY
      into NCOMPANY
      from CLNPERSONS T
     where T.RN = NPERSON;
    --проверка полномочий (роль 'КАДРЫ Просмотр значений описателей документов')
    if (F_PEOPLE_OPIS_DOK(NCOMPANY => NCOMPANY)) = 0
    then
      return SRES;
    end if;
    --найдем стаж работы
    select TRUNC(MONTHS_BETWEEN(sysdate
                               ,P.JOBBEGIN_DATE) / 12) || '/' ||
           TRUNC((MONTHS_BETWEEN(sysdate
                                ,P.JOBBEGIN_DATE) -
                 TRUNC(MONTHS_BETWEEN(sysdate
                                      ,P.JOBBEGIN_DATE) / 12) * 12))
      into SRES
      from CLNPERSONS P
     where P.RN = NPERSON;
    return SRES;
  exception
    when others then
      return SRES;
  end;

  --ученая степень
  function F_PERSON_EDUC(NPERSON number --рег. номер сотрудника
                         ) return varchar2 is
    SRES PRACDDGR.NAME%type;
  begin
    begin
      select US.US_NAME
        into SRES
        from (select T.RN       US_RN
                    ,GR.NAME    US_NAME
                    ,T.DOC_SER  US_DOKSER
                    ,T.DOC_NUMB US_DOKNUM
                    ,T.DOC_WHEN US_DOKDATE
                from CLNPERSONS P
                    ,AGNEDUC    T
                    ,PRACDDGR   GR
               where P.RN = NPERSON
                 and T.PRN = P.PERS_AGENT
                 and T.EDUC_TYPE = 5
                 and T.ACAD_DEGREE = GR.RN(+)
               order by 1 desc) US
       where ROWNUM = 1;
    exception
      when others then
        SRES := null;
    end;
    return SRES;
  end;

end;
/

