create or replace procedure usr_p_contrprclc_insz
(
  nrn  in number
 ,sres out varchar2
) is
  /*grant execute on usr_p_CONTRPRCLC_insz to public;*/
  /* Процедура выводит список статей затрат в которые входит статья с RN = nRN Для строки калькуляции этапа договора */

begin

  for cur in (select sk.rn
                from contrprclc t
                join contrprstruct sp
                  on sp.rn = t.prn
                join prjcalcschmsp sk
                  on sk.prn = sp.calcschm
                 and sk.fpdartcl = t.cost_article
               where t.rn = nrn)
  loop

    usr_p_prjcalcschmsp_insz(nrn => cur.rn, sres => sres);

  end loop;

end;
/
