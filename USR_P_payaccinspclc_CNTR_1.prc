create or replace procedure USR_P_payaccinspclc_CNTR_1(nrn payaccinspclc.rn%type) is
begin

/*
Городецкий О.И. 30-05-2025
Контроль на запрет использование статей затрат из каталога "01 КВ"
в калькуляциях входящих счтеов на оплату из каталогов "Коммерция" и "ОТД"

Обращение Быковой Ксении 260525/18617 от 26-05-2025

*/
 
  for cur in (select a.name
                from payaccinspclc cl
                join payaccinspec ps
                  on ps.rn = cl.prn
                join fpdartcl sz
                  on sz.rn = cl.cost_article
                join acatalog a
                  on a.rn = cl.crn

               where cl.rn = nrn
                 and ps.crn in ( /*Каталог входящих счетов */ 7814512 /*Коммерция*/, 50190777 /*ОТД*/)
                    /*Каталог состава затрат */
                 and sz.crn = 6252667 /*IV_Тематические*/
              )
  loop

    p_exception(0
               ,'В калькуляции входящих счетов на оплату, созданных в каталоге "%s",  нельзя использовать статьи затрат из каталога "IV_Тематические".' || cr ||
                'Если у вас есть вопросы по выбору статьи затрат обратитесь в ПЭО', cur.name);

  end loop;

end;
/
