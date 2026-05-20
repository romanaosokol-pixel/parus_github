create or replace procedure usr_p_fcacoperplans_sum_cntrl
(
  nrn     in stages.rn%type
 ,ndelta  in number default 2 -- Не выдавать расхождения меньшие чем дельта
 ,out_res out varchar2
) is
  /*grant execute on usr_p_fcacoperplans_sum_cntrl to public;*/

  /* Процедура контролирует соответствие "суммы с налогами" этапа договора и суммы ОСНОВНОЙ строки калькуляции структуры цены этапа */

begin

  for cur in (select ctc.cost_sum str_s
                    ,(select sum(fp.summwithnds) from fcacoperplans fp where fp.prn = st.faceacc) et_s
                    ,trim(st.numb) et_nmb
                    ,dog.rn dog_rn
                    ,trim(dog.doc_pref) || '-' || trim(dog.doc_numb) dog_nmb
                    ,to_char(dog.doc_date) dog_date
                from stages st
                join contrprstruct ct
                  on ct.prn = st.rn
                join contrprclc ctc
                  on ctc.prn = ct.rn
                join contracts dog
                  on dog.rn = st.prn
               where st.rn = nrn
                 and ct.sign_act = 1 -- Действующая
                 and ctc.sign_main = 1 -- Оновная
              )
  loop
  
    if abs(cur.str_s - cur.et_s) > ndelta then
      out_res := 'Договор: ' || cur.dog_nmb || ' от ' || cur.dog_date || ' RN (' || cur.dog_rn || cr ||
                 'сумма этапа № ' || cur.et_nmb || ' (' || cur.et_s ||
                 ') не равна сумме основной строки калькуляции структуры цены этапа (' || cur.str_s || ')';
    
    end if;
  
  end loop;

end;

  --- select t.*, t.rowid from V_CONTRPRCLC t where t.npRN = 154399084
/
