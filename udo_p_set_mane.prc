create or replace procedure udo_p_set_mane
/*
  15/11/2023 Степанов М. Убрал исправление даты счёта
  26/01/2026  Городецкий Добавил исправление валюты счета
  */
(nrn in number
,
 /*  dAccDate in date,         -- Дата счета*/snumber  in varchar2
, -- Внешний номер
 dregdate in date
, -- Дата счета
 dpaydate in date
, -- Дата платежа
 --- nClear   in integer,      -- Очистить дату платежа
 ngarant in integer
, -- Перенос в каталог Гарантийные письма
 scurenc in varchar2 --- Валюты 
 ) is

  ncurrency     payaccin.currency%type;
  ncurrency_old payaccin.currency%type;

begin

  begin
    select v.rn into ncurrency from curnames v where v.intcode = scurenc;
  exception
    when no_data_found then
      p_exception(0
                 ,'Валюта с кодом %s  не найдена, выберите корректное значение через словарь.');
  end;

  --- найдем курс валюты на дату счета

  begin
    select p.currency into ncurrency_old from payaccin p where p.rn = nrn;
  end;

  update payaccin pp -- на форме текущие значения
     set pp.ext_numb = snumber
        ,pp.reg_date = dregdate
        ,pp.pay_date = dpaydate
  ---         pp.currency = nCurrency
   where pp.rn = nrn;

  if 1 = ngarant
  then
    update payaccin pp set pp.crn = 51648414 where pp.rn = nrn; -- Каталог "Гарантийные письма"
  end if;

  if cmp_num (v1 => ncurrency, v2 => ncurrency_old) = 0
  then
  
    update payaccin pp -- Испрвим валюту счета
       set pp.currency = ncurrency
     where pp.rn = nrn;
  
    /* Исправим валюту плановых платежей */
  
    for pay in (select pn.rn
                  from doclinks dl
                  join paynotes pn
                    on pn.rn = dl.out_document
                 where dl.in_document = nrn
                   and dl.out_unitcode = 'PayNotes'
                   and dl.in_unitcode = 'PaymentAccountsIn'
                   and pn.signplan = 1 /*Только плановые платежи*/
                   ) 
    loop
      update paynotes pn set pn.currency = ncurrency where pn.rn = pay.rn;
    
    end loop;
  
  end if;

end;
/
