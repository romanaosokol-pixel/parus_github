create or replace procedure usr_p_payaccin_cntrl(nrn in payaccin.rn%type) is

begin
  
/* Для счетов , заведенных в каталоге "Служба ГИ", контролируется наличие калькуляции для всех строк спецификации перед утверждением счета. */

  for cur in (select p.crn
                    ,nm.modif_code
                    ,a.name
                from payaccin p
                join payaccinspec ps
                  on ps.prn = p.rn
                join nommodif nm
                  on nm.rn = ps.nommodif
                join acatalog a
                  on a.rn = p.crn
                left join payaccinspclc psc
                  on psc.prn = ps.rn
               where p.crn = 7551201 /*Каталог "Служба ГИ"*/
                 and p.rn = nrn
                 and psc.rn is null)
  loop
  
    p_exception(0
               ,'Для счетов из каталога "%s" обязательно заводить калькуляцию для всех строк спецификации. Для строки спецификации по "%s" калькуляция не задана. Задайте калькуляцию для все строк спецификации счета перед утверждением.'
               ,cur.name
               ,cur.modif_code
               );
  
  end loop;

end;
/
