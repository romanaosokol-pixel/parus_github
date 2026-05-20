create or replace procedure usr_p_paynotes_crn_def(nrn  in paynotes.rn%type
                                                  ,ncrn in out paynotes.crn%type) is

begin

  /* 
  Процедура определяет каталог платежа по правилам  
  Городецкий О.И. 05-05-2026
  */

  /* 1. Платеж ФАКТИЧЕСКИЙ у которого финансовая операция с признаком ВОЗВРАТ будет помещен в  тот же каталог,
  где лежит последний по дате фактический платеж с прямой операцией по тому же лицевому счету 
  
  Городецкий О.И. 05-05-2026
   */

  begin
  
    for cur in (with pnd as
                   (select p.rn
                         ,p.crn
                         ,p.faceacc
                         ,p.pay_number
                     from paynotes p
                     join dictoper fo
                       on fo.rn = p.finoper
                    where fo.factret_sign = 0 /* Прямая */
                      and p.signplan = 0
                      and p.pay_date = (select max(pd.pay_date) /* Последнняя прямая операция */
                                          from paynotes pd
                                          join dictoper fod
                                            on fod.rn = pd.finoper
                                         where pd.faceacc = p.faceacc
                                           and fod.factret_sign = 0 /* Прямая */
                                           and pd.signplan = 0)
                   
                   )
                  select distinct pn.rn
                                 ,pnd.crn cat_direct_rn
                    from paynotes pn
                    join dictoper fo
                      on fo.rn = pn.finoper
                    join pnd
                      on pnd.faceacc = pn.faceacc
                    join acatalog a1
                      on a1.rn = pn.crn
                    join acatalog a2
                      on a2.rn = pnd.crn
                   where pn.rn = nrn /* Только для одного платежа */
                     and fo.factret_sign = 1 /* Возврат */
                     and pn.crn != pnd.crn
                     and pn.signplan = 0)
    loop
    
      /* Изменим выходной параметр */
      ncrn := cur.cat_direct_rn;
    
      update paynotes t
         set t.crn = ncrn
       where t.rn = cur.rn;
    
    end loop;
    return; /* Выходим чтоб остальные правила, если они будут, не рассматривалась.*/
  end;

end;
/
