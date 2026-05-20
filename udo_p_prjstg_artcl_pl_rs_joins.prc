create or replace procedure UDO_P_PRJSTG_ARTCL_PL_RS_JOINS
/*
   Разыменование ссылок в разделе "Планы и отчеты по статьям (остатки)"
  */
(
  NCOMPANY      number --рег. номер организации
 ,NSTAGE        number --рег. номер СТРУКТУРЫ ЦЕНЫ  этапа проекта
 ,SPRJSTG_ARTCL varchar2 --мнемокод статьи этапа заказа
 ,SSTATE        varchar2 --мнемокод состояния
 ,NPRJSTG_ARTCL out number --рег. номер статьи этапа заказа
 ,NSTATE        out number --рег. номер состояния
) as
begin
  --найдем рег. номер статьи этапа проекта
  begin
    select T.RN
      into NPRJSTG_ARTCL
      from --UDO_T_PRJSTG_ARTCL T
           udo_prjstg_prclc   t
          ,FPDARTCL           A
     where T.PRN = NSTAGE
       and T.COST_ARTICLE = A.RN
       and A.CODE = SPRJSTG_ARTCL;
  exception
    when NO_DATA_FOUND then
      P_EXCEPTION(0, 'Статья этапа проекта с мнемокодом "' || SPRJSTG_ARTCL || '" не определена!');
  end;
  --найдем рег. номер состояния
  FIND_FINSTATE_CODE(NFLAG_SMART => 0
                    ,NCOMPANY    => NCOMPANY
                    ,SCODE       => SSTATE
                    ,NRN         => NSTATE);
end;
/

