create or replace procedure UDO_P_WUDP100_EXEC_PERSON_LIST(SUSER varchar2) as
  /*
    grant execute on UDO_P_WUDP100_EXEC_PERSON_LIST to public;
    APEX. Формирование списка, сотрудников исполнителей, для выбора
  */
  type TTEXEC_PERSON_LIST is table of UDO_T_WUDP100_EXEC_PERSON_LIST%rowtype;
  TEXEC_PERS TTEXEC_PERSON_LIST;
  I          number;
begin
  -- Стираем старый
  delete from UDO_T_WUDP100_EXEC_PERSON_LIST T
   where T.USER_NAME = SUSER;
  -- Создаем новый
  begin
    with TSUBDIVS_LIST as -- Получаем строковый список подразделений
     (select /*- MATERIALIZE */
       CP.COMPANY
      ,UDO_F_GET_DOC_PROP_VAL_STR('РукПодразделением'
                                 ,'ClientPostDepart'
                                 ,T.PSDEPRN) STR
        from CLNPERSONS    CP
            ,CLNPSPFM      T
            ,CLNPSPFMTYPES CPSPFM
       where CP.PERS_AUTHID = SUSER
         and T.PERSRN = CP.RN
         and T.CLNPSPFMTYPES = CPSPFM.RN
         and CPSPFM.IS_PRIMARY = 1 -- основное исполнение
         and TRUNC(sysdate) between T.BEGENG and NVL(T.ENDENG, TRUNC(sysdate))
         and T.DEPTRN is not null),
    TSUBDIV as -- Получаем список подразделений
     (select /*+ MATERIALIZE */
       D.*
        from INS_DEPARTMENT D
            ,(select T.COMPANY
                    ,REGEXP_SUBSTR(STR, '[^;]+', 1, level) SUBDIV_CODE
                from TSUBDIVS_LIST T
              connect by INSTR(trim(';' from STR), ';', 1, level - 1) > 0
                     and prior COMPANY = COMPANY
                     and prior DBMS_RANDOM.VALUE is not null) S
       where S.COMPANY = D.COMPANY
         and S.SUBDIV_CODE = D.CODE),
    TSUBDIV_HIER as -- Иерархия подразделений
     (select /*+ MATERIALIZE */
       D.*
        from INS_DEPARTMENT D
            ,TSUBDIV        S
       where D.RN = S.RN(+)
         and D.HIER_LEVEL in (2, 3, 4, 5)
      connect by prior D.RN = D.PRN
       start with D.RN = S.RN)
    select distinct null
                   ,null
                   ,AG.AGNABBR AGN_CODE
                   ,CP.RN RN_PERSON
                   ,SUBSTR(F_CLNPERSONS_FORMAT_CODE(CP.COMPANY, CP.CODE), 0, 255) PERSON_CODE
      bulk collect
      into TEXEC_PERS
      from CLNPSPFM      T
          ,TSUBDIV_HIER  D
          ,CLNPSPFMTYPES CPSPFM
          ,CLNPERSONS    CP
          ,AGNLIST       AG
     where TRUNC(sysdate) between T.BEGENG and NVL(T.ENDENG, TRUNC(sysdate))
       and T.DEPTRN = D.RN
       and T.PERSRN = CP.RN
       and CP.PERS_AUTHID is not null
       and CP.PERS_AGENT = AG.RN
       and T.CLNPSPFMTYPES = CPSPFM.RN
       and CPSPFM.IS_PRIMARY = 1 -- основное исполнение
     order by 1;
  exception
    when NO_DATA_FOUND then
      null;
  end;
  -- Добавляем
  forall I in 1 .. TEXEC_PERS.COUNT
    insert into UDO_T_WUDP100_EXEC_PERSON_LIST
      (RN
      ,USER_NAME
      ,AGN_CODE
      ,RN_PERSON
      ,PERSON_CODE)
    values
      (GEN_ID
      ,SUSER
      ,TEXEC_PERS(I).AGN_CODE
      ,TEXEC_PERS(I).RN_PERSON
      ,TEXEC_PERS(I).PERSON_CODE);
  -- Дополняем списком рассылки
  for D in (select CF.rn              RN_PERSON
                  ,CF.FCODE           PERSON_CODE
                  ,CF.PERS_AGENT_CODE AGN_CODE
              from udo_v_clnpersons_docflow cf --UDO_V_CLNPERSONS_LIST_FILL CF
            )
  loop
    insert into UDO_T_WUDP100_EXEC_PERSON_LIST
      (RN
      ,USER_NAME
      ,AGN_CODE
      ,RN_PERSON
      ,PERSON_CODE)
    values
      (GEN_ID
      ,SUSER
      ,D.AGN_CODE
      ,D.RN_PERSON
      ,D.PERSON_CODE);
  end loop;
end;
/

