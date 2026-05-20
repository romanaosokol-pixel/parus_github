create or replace procedure UDO_P_SYSW0001_MK_INSD_TREE
(
  PNIDENT     number --идентификатор процесса
 ,PNCOMPANY   number --рег. номер организации
 ,PSPRIV_UNIT varchar2 --код раздела для проверки прав доступа
) as
  /*
    grant execute on UDO_P_SYSW0001_MK_INSD_TREE to public;
    Формирование дерева подразделений, согласно правам доступа пользователя
    к указанному разделу
  */
  sUSER userlist.authid%type; -- Пользователь
begin
  -- Определяем пользователя
  sUSER := UDO_F_SYSW0001_GET_USER(PNCOMPANY);
  --удалим старые подразделения
  delete from UDO_T_SYSW0001_INSD_TREE T
   where T.IDENT = PNIDENT
     and T.UNIT = PSPRIV_UNIT;
  --добавим новые, согласно правам доступа
  insert into UDO_T_SYSW0001_INSD_TREE
    (IDENT
    ,INSD
    ,UNIT)
    select /*+ RULE*/
     PNIDENT
    ,T.RN
    ,PSPRIV_UNIT
      from V_SUBDIVSSLR_HIER T
     where T.COMPANY = PNCOMPANY
       and T.UNITCODE = 'INS_DEPARTMENT'
       and T.BGNDATE <= sysdate
       and ((T.ENDDATE is null) or (T.ENDDATE >= sysdate))
       and ((T.SIGNS = 0) or (exists (select DP.RN
                                        from INS_DEPARTMENT DP
                                       where DP.RN = T.RN
                                         and DP.STAFF_SIGN = 1)))
       and (((T.CRN = 0) or (T.CRN is null)) or
           ((T.CRN <> 0) and (T.CRN is not null) and
           (exists (select null
                        from UDO_T_USERPRIV_SUBDIV TA
                            ,UNITLIST              UL
                       where TA.USERCODE = sUSER --UDO_F_SYSW0001_GET_USER(T.COMPANY)
                         and TA.UNIT = UL.RN
                         and UL.UNITCODE = PSPRIV_UNIT
                         and ((TA.SUBDIV is null) or
                             ((TA.SUBDIV is not null) and
                             (TA.SUBDIV in (select II.RN
                                                from INS_DEPARTMENT II
                                              connect by prior II.PRN = II.RN
                                               start with II.RN = T.RN))))))));
  /*+ opt_param('_optimizer_connect_by_cost_based' 'false') */
end;
/

