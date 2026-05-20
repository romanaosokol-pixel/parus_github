create or replace procedure UDO_P_PRJSTG_MAKE_CONTRPRSTR
(
  NPRJSTG in number,
  NSTG    in number
) is
  /*
    ѕеренос структур цены (перенос только действующей структуры цены)
  */
  NCONTRPRCLC    number;
  NCONTRPRSTRUCT number;
begin
  for PR in (select *
               from UDO_PRJSTG_PRSTRUCT P
              where P.PRN = NPRJSTG
                and P.SIGN_ACT = 1)
  loop
    begin
      select T.RN
        into NCONTRPRSTRUCT
        from CONTRPRSTRUCT T
       where T.PRN = NSTG
         and T.PRICE_KIND = PR.PRICE_KIND
      /*and CMP_DAT(T.DATE_FROM
      ,PR.DATE_FROM) = 1*/
      ;
    exception
      when NO_DATA_FOUND then
        NCONTRPRSTRUCT := null;
      when TOO_MANY_ROWS then
        P_EXCEPTION(0
                   ,'¬ этапе договора не однозначно определена структура цены "%s". ”далите некорректную запись'
                   ,UDO_GET_FINSTATE_CODE_ID(1
                                            ,PR.PRICE_KIND));
    end;
    if NCONTRPRSTRUCT is null
    then
      P_CONTRPRSTRUCT_BASE_INSERT(NCOMPANY    => PR.COMPANY
                                 ,NPRN        => NSTG
                                 ,NPRICE_KIND => PR.PRICE_KIND
                                 ,NCALCSCHM   => PR.CALCSCHM
                                 ,DDATE_FROM  => PR.DATE_FROM
                                 ,DDATE_TO    => PR.DATE_TO
                                 ,NSUMM       => PR.SUMM
                                 ,NSUMM_BASE  => PR.SUMM_BASE
                                 ,nCALC_INDIR => 0                       --- обновление 28/05/2020
                                 ,NRN         => NCONTRPRSTRUCT);
    else
      P_CONTRPRSTRUCT_BASE_UPDATE(NRN         => NCONTRPRSTRUCT
                                 ,NCOMPANY    => PR.COMPANY
                                 ,NPRICE_KIND => PR.PRICE_KIND
                                 ,NCALCSCHM   => PR.CALCSCHM
                                 ,DDATE_FROM  => PR.DATE_FROM
                                 ,DDATE_TO    => PR.DATE_TO
                                 ,nCALC_INDIR => 0);                     --- обновление 28/05/2020
      update CONTRPRSTRUCT ct set ct.summ = PR.SUMM, ct.summ_base = PR.SUMM_BASE where ct.rn = NCONTRPRSTRUCT;    -- EZST —умма не заполн€етс€ после переотработки структуры цены                       
    end if;
    for CLC in (select *
                  from UDO_PRJSTG_PRCLC PC
                 where PC.PRN = PR.RN)
    loop
      begin
        select T.RN
          into NCONTRPRCLC
          from CONTRPRCLC T
         where T.PRN = NCONTRPRSTRUCT
           and T.COST_ARTICLE = CLC.COST_ARTICLE;
      exception
        when NO_DATA_FOUND then
          NCONTRPRCLC := null;
      end;
      if NCONTRPRCLC is null
      then
        P_CONTRPRCLC_BASE_INSERT(NCOMPANY      => CLC.COMPANY
                                ,NPRN          => NCONTRPRSTRUCT
                                ,SNUMB         => CLC.NUMB
                                ,NCOST_ARTICLE => CLC.COST_ARTICLE
                                ,NSIGN_MAIN    => CLC.SIGN_MAIN
                                ,NEXP_TYPE     => CLC.EXP_TYPE
                                ,NCOST_SUM     => CLC.COST_SUM
                                ,nPERCENT_PLAN => 0                       --- обновление 28/05/2020
                                ,nPERCENT_FACT => 0                       --- обновление 28/05/2020
                                ,NRN           => NCONTRPRCLC);
      else
        P_CONTRPRCLC_BASE_UPDATE(NRN           => NCONTRPRCLC
                                ,NCOMPANY      => CLC.COMPANY
                                ,SNUMB         => CLC.NUMB
                                ,NCOST_ARTICLE => CLC.COST_ARTICLE
                                ,NEXP_TYPE     => CLC.EXP_TYPE
                                ,NCOST_SUM     => CLC.COST_SUM
                                ,nPERCENT_PLAN => 0                       --- обновление 28/05/2020
                                ,nPERCENT_FACT => 0);                     --- обновление 28/05/2020
        if CLC.SIGN_MAIN = 1
        then
          P_CONTRPRCLC_SET_MAIN(NCOMPANY   => CLC.COMPANY
                               ,NRN        => NCONTRPRCLC
                               ,NSIGN_MAIN => CLC.SIGN_MAIN);
        end if;
      end if;
    end loop;
    -- подчищаем статьи отстутствующие с исходной структуре цены
    for CUR in (select *
                  from CONTRPRCLC T
                 where T.RN = NCONTRPRSTRUCT
                   and not exists (select null
                          from UDO_PRJSTG_PRCLC PC
                         where PC.PRN = PR.RN
                           and PC.COST_ARTICLE = T.COST_ARTICLE))
    loop
      P_CONTRPRCLC_BASE_DELETE(NRN      => CUR.RN
                              ,NCOMPANY => CUR.COMPANY);
    end loop;
    -- утверждение —÷
    P_CONTRPRSTRUCT_SET_STATE(NCOMPANY    => PR.COMPANY
                             ,NRN         => NCONTRPRSTRUCT
                             ,NSTATE      => PR.STATE
                             ,DSTATE_DATE => PR.STATE_DATE);
    -- устанновка признака действующа€
    if PR.SIGN_ACT = 1
    then
      P_CONTRPRSTRUCT_SET_ACT(NCOMPANY  => PR.COMPANY
                             ,NRN       => NCONTRPRSTRUCT
                             ,NSIGN_ACT => PR.SIGN_ACT
                             ,DDATE     => PR.DATE_FROM);
    end if;
  end loop;
end;
/

