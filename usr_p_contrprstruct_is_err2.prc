create or replace procedure usr_p_contrprstruct_is_err2
(
  nrn       in contrprstruct.rn%type
 ,nsign_act in contrprstruct.sign_act%type
 ,out_res   out varchar2
) is

  /*  
  
  Nomen_Type тип номерклатуры (1 - товар, 2 - услуга, 3 - тара)
  CALC_INDIR Расчет косвенных затрат (0 - По прямым статьям, 1 - По калькуляции)
  
  nsign_act -- 1 Действующая, 
  
  C 15-04-2025 по согласованию с Куроедовой А.Б. Если позиция включена в план отгрузкок, то структура цены ОБЯЗАТЕЛЬНО по калькуляции, вне зависимости от позиции
  
  */

begin
  for cur in (select ct.calc_indir
                    ,trim(st.numb) numb
                    ,st.prn
                from contrprstruct ct
                join stages st
                  on st.rn = ct.prn
                join FCACOPERPLANS FP on FP.PRN = st.faceacc and FP.PRICE!=0 --- Cуществует план отгрузок cненулевой ценой 
               where ct.rn = nrn
                 and ct.calc_indir = 0
                 )
  loop
    out_res := 'В Графике отпуска товаров и услуг № ' || cur.numb ||
               ' следует установить на закладке "Структура цены", признак "Расчет косвенных затрат" - "По калькуляции". При этом калькуляции должны быть заданы в учетных ценах. ' ||
               'В строках графика отпуска строки калькуляции формируются действием "Переформирование строк калькуляции по учетным ценам" ' || cr ||
               'RN договора' || cur.prn;
  end loop;

end;
/
