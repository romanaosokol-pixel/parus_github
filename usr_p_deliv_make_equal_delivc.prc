create or replace procedure usr_p_deliv_make_equal_delivc(
 nIDENT       in number
,sMSG         out varchar2
)
is
/*
    28/08/2025 KHOK
    Заказ поставщикам (спецификации). Приравнять количество в калькуляции количеству в "Согласованное количество в ОЕИ"
*/

  nCount            pkg_std.tnumber := 0;
  r_deliveryordcs   deliveryordcs%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_PAIS_MAKE_EQUAL_PAISC');

  /* По спецификаицям */
  for c in ( select pais.rn, dps.actm_quant, dps.p_factm_quant,
                    dnm.nomen_code, dnm.nomen_name, nm.modif_code, nm.modif_name
               from selectlist    sl
                   ,DELIVERYORDS  pais
                   ,DELIVERYORDPS dps
                   ,dicnomns      dnm
                   ,nommodif      nm
              where sl.ident      = nIDENT
                and pais.rn       = sl.document
                and dps.prn       = pais.rn 
                and pais.nomen    = dnm.rn
                and pais.nom_modif = nm.rn(+) )
  loop
    /* По калькуляциям спецификации */
    for c1 in ( select paisc.rn, count(*) over() as ncount, paisc.prn, lead(paisc.prn, 1) over(order by paisc.prn) as nlead_prn
                  from DELIVERYORDCS paisc
                 where paisc.prn = c.rn )
    loop
      /* Калькуляциий для спецификации больше одной */
      if c1.ncount != 1 then
        P_exception(0,'Калькуляция строки спецификации состоит из нескольких строк. Однозначно определить в какую строку переносить калькуляцию невозможно.'
                    ||' Отредактируйте калькуляцию вручную.');
--        ||' Отредактируйте калькуляцию вручную. Строки с расхождениями видно по колонке "Дельта калькуляции".');
        /* Следующая спецификация не равна текущей */
        if c1.prn != nvl(c1.nlead_prn, 0) then
          /* Добавляем спецификацию в сообщение */
          sMSG := substr(strcombine(sMSG, c.nomen_code ||', '|| c.nomen_name ||', '|| nvl(c.modif_code, 'null')  ||', '|| nvl(c.modif_name, 'null')  ||cr||cr), 0, 3999);
        end if;
      else
        /* Считывание калькуляции */
        select * into r_deliveryordcs from DELIVERYORDCS where rn = c1.rn;
        r_deliveryordcs.quant_plan := c.actm_quant;
        r_deliveryordcs.quant_fact := c.p_factm_quant;
        /* Исправление калькуляции */
        USR_PKG_DELIVERYORD.DELIVERYORDCS_BASE_UPDATE(rROW => r_deliveryordcs);
      end if;

    end loop;
  end loop;

  /* Сообщение */  
  if sMSG is not null then 
    sMSG := 'Невозможно исправить калькуляции в спецификациях:'||cr||cr||sMSG;
  else    
    sMSG := 'Все калькуляции спецификаций исправлены.';
  end if;

  /* Закрываем процесс */
  usr_pkg_process.process_close;

exception
  when others then
  usr_pkg_process.process_close;
  raise;  

end USR_P_DELIV_MAKE_EQUAL_DELIVC;
/
