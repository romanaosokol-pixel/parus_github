create or replace procedure usr_p_payaccin_igk_cnt(nrn in payaccin.rn%type) is

begin
  /* Если и реквизит плательщика и реквизит поставщика привязаны к ИГК,
  то ИГК должен быть одмнаковым */
  for cur in (select t.ext_numb
                    ,to_char(t.doc_date
                            ,'DD.MM.YYYY') doc_date
                    ,trim(t.doc_pref) || '-' || trim(t.doc_numb) numb
                    ,acf.strcode from_acc
                    ,igkf.rn from_igk_rn
                    ,igkf.code from_igk
                    ,act.strcode to_acc
                    ,igkt.rn to_igk_rn
                    ,igkt.code to_igk
                from payaccin t
                join govcntridbanks gbf
                  on gbf.agnacc = t.payeracc
                join govcntrid igkf
                  on igkf.rn = gbf.prn
                join govcntridbanks gbt
                  on gbt.agnacc = t.supplacc
                join govcntrid igkt
                  on igkt.rn = gbt.prn
                join agnacc acf
                  on acf.rn = t.payeracc
                join agnacc act
                  on act.rn = t.supplacc
              
               where t.rn = nrn
                 and igkf.rn != igkt.rn)
  loop
  
    p_exception(0
               ,'Для входящего счета %s от %s внешний номер %s реквизит плательщика %s связан с ИГК %s, а реквизит поставщика %s связан с ИГК %s. Они должны быть связаны с одним ИГК. Если остались вопросы, обращайтесь в ПЭО.'
               ,cur.numb
               ,cur.doc_date
               ,cur.ext_numb
               ,cur.from_acc
               ,cur.from_igk
               ,cur.to_acc
               ,cur.to_igk);
  
  end loop;

end;
/
