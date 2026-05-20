create or replace procedure usr_p_payaccinspclc_AUTO is

begin

/*ѕересчет калькул€ции вход€щего счета на оплату, дл€ прив€зки ее к бюджетам,
если не было прив€зки ранее  */

  for cur in (

              select p.rn pi_rn,  P.Ext_Numb
                from payaccin p
                join payaccinspec ps on ps.prn = P.RN
                join payaccinspclc cl on cl.prn = ps.rn
               where p.doc_date >= to_date('01-01-2026', 'DD.MM.YYYY')
               and cl.cost_article is null


                       )
  loop
  begin
    usr_p_payaccinspclc_cre(cur.pi_rn);
     exception when others then null; /*ќтключим сообщение об ошибках, еслии они будут (неприв€занные калькул€ции) писать их в Ћог таблицу*/
 end;

  end loop;

end;
/
