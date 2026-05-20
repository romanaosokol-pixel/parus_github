create or replace procedure UDO_P_PROC_REPORT_A_D_COPY
(
  NRN      in number,
  NCOMPANY in number
) is

  /*Процедура копирования строк (детали) из эталонной строки (сборки) во все строки (сборки)
  Раздел: Отчет перераблтчика (сборки)*/

  NPRN number(17); --PRN эталонной строки (сборки)
  NRN1 number(17); -- RN новой строки (детали)


begin

  -- Опредеелние PRN эталонной строки (сборки)
  select UP.PRN
    into NPRN
    from UDO_T_PROCESSOR_REPORT_ASS UP
   where UP.RN = NRN
     and UP.COMPANY = NCOMPANY;

  -- Цикл по строкам (сборки)

  for C in (select UPA.RN
            from UDO_T_PROCESSOR_REPORT_ASS UPA
           where UPA.PRN = NPRN
             and UPA.RN <> NRN -- эталонная трока не меняется
          and not exists (select U.RN from UDO_T_PROCESSOR_REPORT_A_D U where UPA.RN = U.PRN)-- заполненные строки не меняются
          )
  loop
  
  -- Копирование параметров строк (детали) и запись их строки (сборки)
  for R in (select DN.NOMEN_CODE,
                   NM.MODIF_CODE,
                   UPR.SUPPLY,
                   UPR.QUANT,
                   UPR.QUANTALT,
                   UPR.MATRES,
                   UPR.FCPRODCMPSP
            
              from UDO_T_PROCESSOR_REPORT_A_D UPR,
                   DICNOMNS                   DN,
                   NOMMODIF                   NM
             where UPR.NOMEN = DN.RN
               and UPR.MODIF = NM.RN
               and UPR.PRN = NRN
               and UPR.COMPANY = NCOMPANY)
  

    loop
    
/*      begin
        select UPRA.RN into NRN1 from UDO_T_PROCESSOR_REPORT_A_D UPRA where C.RN = UPRA.PRN and rownum = 1;
      exception
        when NO_DATA_FOUND then
          NRN1 := null;
      end;*/
    
     /* if NRN1 is null then*/
      
        UDO_PKG_PROCESSOR_REPORT.P_PROCESSOR_REPORT_A_D_INSERT(NCOMPANY     => NCOMPANY /*Организация*/,
                                                               NPRN         => C.RN /*Регистрационный номер родителя*/,
                                                               SNOMEN       => R.NOMEN_CODE /*Номенклатура*/,
                                                               SMODIF       => R.MODIF_CODE /*Модификация*/,
                                                               NSUPPLY      => R.SUPPLY /*Партия*/,
                                                               NQUANT       => R.QUANT /*Количество ОЕИ*/,
                                                               NQUANTALT    => R.QUANTALT /*Количество ДЕИ*/,
                                                               NMATRES      => R.MATRES /*Материальный ресурс*/,
                                                               NFCPRODCMPSP => R.FCPRODCMPSP /*Строка производственного состава*/,
                                                               NRN          => NRN1 /*Регистрационный номер записи*/);
      
      
      
     /* end if;*/
    
    end loop;
  end loop;

end UDO_P_PROC_REPORT_A_D_COPY;
/

