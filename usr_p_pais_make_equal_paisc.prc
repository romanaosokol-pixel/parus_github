create or replace procedure USR_P_PAIS_MAKE_EQUAL_PAISC
/*
Входящие счета на оплату (спецификации). Приравнять количество в калькуляции количеству в спецификации
08/04/2022 Степанов М.
*/
(
 nIDENT       in number
,sMSG         out varchar2
)
is
  nCount            pkg_std.tnumber := 0;
  rV_PayAccInSpClc  v_payaccinspclc%rowtype;
begin
  /* Отрываем процесс */
  usr_pkg_process.process_open(sname => 'USR_P_PAIS_MAKE_EQUAL_PAISC');

  /* По спецификаицям */
  for c in ( select pais.rn, pais.quant, pais.factquant,
                    dnm.nomen_code, dnm.nomen_name, nm.modif_code, nm.modif_name
               from selectlist    sl
                   ,payaccinspec  pais
                   ,dicnomns      dnm
                   ,nommodif      nm
              where sl.ident      = nIDENT
                and pais.rn       = sl.document 
                and pais.nomen    = dnm.rn
                and pais.nommodif = nm.rn(+) )
  loop
    /* По калькуляциям спецификаиции */
    for c1 in ( select paisc.nrn, count(*) over() as ncount, paisc.nprn, lead(paisc.nprn, 1) over(order by paisc.nprn) as nlead_prn
                  from v_payaccinspclc paisc
                 where paisc.nprn = c.rn )
    loop
      /* Калькуляциий для спецификации больше одной */
      if c1.ncount != 1 then
        P_exception(0,'Калькуляция строки спецификации счета состоит из нескольких строк. Однозначно определить в какую строку переносить калькуляцию невозможно.'||
        ' Отредактируйте калькуляцию вручную. Строки с расхождениями видно по колонке "Дельта калькуляции".');
        /* Следующая спецификация не равна текущей */
        if c1.nprn != nvl(c1.nlead_prn, 0) then
          /* Добавляем спецификацию в сообщение */
          sMSG := substr(strcombine(sMSG, c.nomen_code ||', '|| c.nomen_name ||', '|| nvl(c.modif_code, 'null')  ||', '|| nvl(c.modif_name, 'null')  ||cr||cr), 0, 3999);
        end if;
      else
        /* Считывание калькуляции */
        select * into rV_PayAccInSpClc from v_payaccinspclc where nrn = c1.nrn;
        rV_PayAccInSpClc.nquant_plan := c.quant;
        rV_PayAccInSpClc.nquant_fact := c.factquant;
        /* Исправление калькуляции */
        usr_pkg_payaccin.payaccinspclc_update(rv_row => rV_PayAccInSpClc);
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

end;
/
