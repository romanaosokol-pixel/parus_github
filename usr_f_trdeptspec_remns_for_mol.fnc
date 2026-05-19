create or replace function usr_f_trdeptspec_remns_for_mol(nrn number) return number is
begin
  /* Доп колонка выводящая текущий остаток по МОЛ в спецификации расходной накданой на отпуск подразделения */

  for cur in (select 
    usr_f_base_remns_for_mol(ncompany => t.company, nmol => t.mol, nstore => t.store, nnommodif => ts.nommodif, ngprn => ts.goodsparty, ssernumb => ts.article) q
                from transinvdeptspecs ts
                join transinvdept t
                  on ts.prn = t.rn
               where ts.rn = nrn)
  loop
    return cur.q;
  end loop;
  return null;
end;
/
