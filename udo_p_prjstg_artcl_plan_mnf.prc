create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_MNF
/*
   ‘ормирование фактических показателей по стать€м (помес€чно)
   в разделе "ѕланы и отчеты по стать€м"
  */
(
  NRN           number --рег. номер статьи
 ,NPRN          number --рег. номер плана
 ,NCOMPANY      number --рег. номер организации
 ,SPRJSTG_ARTCL varchar2 --код статьи
 ,NSUMM_1       number --сумма за 1-й мес€ц
 ,NSUMM_2       number --сумма за 2-й мес€ц
 ,NSUMM_3       number --сумма за 3-й мес€ц
 ,NSUMM_4       number --сумма за 4-й мес€ц
 ,NSUMM_5       number --сумма за 5-й мес€ц
 ,NSUMM_6       number --сумма за 6-й мес€ц
 ,NSUMM_7       number --сумма за 7-й мес€ц
 ,NSUMM_8       number --сумма за 8-й мес€ц
 ,NSUMM_9       number --сумма за 9-й мес€ц
 ,NSUMM_10      number --сумма за 10-й мес€ц
 ,NSUMM_11      number --сумма за 11-й мес€ц
 ,NSUMM_12      number --сумма за 12-й мес€ц
) as
  NPRJSTG_ARTCL number; --рег. номер статьи
  NFINSTATE     number; --рег. номер планового состо€ни€
  NSUMMS        UDO_TP_NUMTABLE := UDO_TP_NUMTABLE(); --массив дл€ хранени€ значений
begin
  --найдем рег. номер статьи
  begin
    select SP.PRJSTG_ARTCL
      into NPRJSTG_ARTCL
      from UDO_T_PRJSTG_ARTCL_PLAN_SP SP
          --,UDO_T_PRJSTG_ARTCL         A
          ,udo_prjstg_prclc a
          ,FPDARTCL                   F
     where SP.PRJSTG_ARTCL = A.RN
       and A.COST_ARTICLE = F.RN
       and F.CODE = SPRJSTG_ARTCL
       and SP.PRN = NPRN
       and ROWNUM <= 1;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Ќеудалось определить статью планировани€!');
  end;
  --найдем рег. номер планового состо€ни€
  FIND_FINSTATE_CODE(0, NCOMPANY, UDO_F_SYS0006_GET_CONST_VAL(NCOMPANY, '—ќ—“_‘ј “'), NFINSTATE);
  --соберем переданные значени€ в массив
  NSUMMS.EXTEND;
  NSUMMS(NSUMMS.LAST) := NVL(NSUMM_1, 0);
  NSUMMS.EXTEND;
  NSUMMS(NSUMMS.LAST) := NVL(NSUMM_2, 0);
  NSUMMS.EXTEND;
  NSUMMS(NSUMMS.LAST) := NVL(NSUMM_3, 0);
  NSUMMS.EXTEND;
  NSUMMS(NSUMMS.LAST) := NVL(NSUMM_4, 0);
  NSUMMS.EXTEND;
  NSUMMS(NSUMMS.LAST) := NVL(NSUMM_5, 0);
  NSUMMS.EXTEND;
  NSUMMS(NSUMMS.LAST) := NVL(NSUMM_6, 0);
  NSUMMS.EXTEND;
  NSUMMS(NSUMMS.LAST) := NVL(NSUMM_7, 0);
  NSUMMS.EXTEND;
  NSUMMS(NSUMMS.LAST) := NVL(NSUMM_8, 0);
  NSUMMS.EXTEND;
  NSUMMS(NSUMMS.LAST) := NVL(NSUMM_9, 0);
  NSUMMS.EXTEND;
  NSUMMS(NSUMMS.LAST) := NVL(NSUMM_10, 0);
  NSUMMS.EXTEND;
  NSUMMS(NSUMMS.LAST) := NVL(NSUMM_11, 0);
  NSUMMS.EXTEND;
  NSUMMS(NSUMMS.LAST) := NVL(NSUMM_12, 0);
  --выполним изменение планов
  UDO_P_PRJSTG_ARTCL_PL_SP_PLAN(NPRN, NPRJSTG_ARTCL, NFINSTATE, NSUMMS, 1);
end UDO_P_PRJSTG_ARTCL_PLAN_MNF;
/*
   create public synonym UDO_P_PRJSTG_ARTCL_PLAN_MNF for UDO_P_PRJSTG_ARTCL_PLAN_MNF;
   grant execute on UDO_P_PRJSTG_ARTCL_PLAN_MNF to public;
  */
/

