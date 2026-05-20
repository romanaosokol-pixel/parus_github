create or replace procedure UDO_P_PRJSTG_ARTCL_PLAN_INS
/*
   Клиентское добавление в раздел "Планы и отчеты по статьям"
  */
(
  NCRN         number --рег. номер каталога
 ,NCOMPANY     number --рег. номер организации
 ,SPROJECT     varchar2 --мнемокод проекта
 ,SSTAGE       varchar2 --номер этапа проекта
 ,SPERIOD      varchar2 --мнемокод расчетного периода (год)
 ,SCALC_SCHEMA varchar2 --мнемокод схемы калькуляции
 ,NSUMM        number --сумма на период
 ,SLIMITART    varchar2 --контрольная статья
 ,NRN          out number --рег. номер добавленной записи
) as
  NPROJECT     number(17); --рег. номер проекта
  NSTAGE       number(17); --рег. номер этапа проекта
  NPERIOD      number(17); --рег. номер расчетного периода
  NLIMITART    number(17); --рег. номер контрольной статьи
  NCALC_SCHEMA number(17); --рег. номер схемы калькуляции
begin
  --разыменуем ссылки
  UDO_P_PRJSTG_ARTCL_PLAN_JOINS(NCOMPANY     => NCOMPANY
                               ,SPROJECT     => SPROJECT
                               ,SSTAGE       => SSTAGE
                               ,SPERIOD      => SPERIOD
                               ,SCALC_SCHEMA => SCALC_SCHEMA
                               ,SLIMITART    => SLIMITART
                               ,NPROJECT     => NPROJECT
                               ,NSTAGE       => NSTAGE
                               ,NPERIOD      => NPERIOD
                               ,NCALC_SCHEMA => NCALC_SCHEMA
                               ,NLIMITART    => NLIMITART);
  --проверим соответствие периода планирования периоду этапа проекта
  declare
    NPYEAR  number; --год выбранного периода планирования
    NPTYPE  number; --тип выбранного периода планирования
    NSYEARB number; --год начала планируемого этапа
    NSYEARE number; --год окончания планируемого этапа
  begin
    select TO_NUMBER(TO_CHAR(T.STARTDATE
                            ,'yyyy'))
          ,T.PERTYPE
      into NPYEAR
          ,NPTYPE
      from ENPERIOD T
     where T.RN = NPERIOD;
    select TO_NUMBER(TO_CHAR(PS.BEGPLAN
                            ,'yyyy'))
          ,TO_NUMBER(TO_CHAR(PS.ENDPLAN
                            ,'yyyy'))
      into NSYEARB
          ,NSYEARE
      from PROJECTSTAGE PS
     where PS.RN = NSTAGE;
    if (NPTYPE <> 3)
    then
      P_EXCEPTION(0
                 ,'Расчетный период должен иметь тип "Год"!');
    end if;
    if (not (NPYEAR between NSYEARB - 1 and NSYEARE))
    then
      P_EXCEPTION(0
                 ,'Указанный расчетный период не в ходит в период проведения работ по этапу!');
    end if;
  end;
  --регистрация начала действия
  PKG_ENV.PROLOGUE(NCOMPANY => NCOMPANY
                  ,NVERSION => null
                  ,NCATALOG => NCRN
                  ,SUNIT    => 'PrjArtclsPlanReps'
                  ,SACTION  => 'UDO_P_PRJSTG_ARTCL_PLAN_INS'
                  ,STABLE   => 'UDO_T_PRJSTG_ARTCL_PLAN');
  --добавим данные в таблицу
  UDO_P_PRJSTG_ARTCL_PLAN_B_INS(NCRN         => NCRN
                               ,NCOMPANY     => NCOMPANY
                               ,NPROJECT     => NPROJECT
                               ,NSTAGE       => NSTAGE
                               ,NPERIOD      => NPERIOD
                               ,NCALC_SCHEMA => NCALC_SCHEMA
                               ,NSUMM        => NSUMM
                               ,NLIMITART    => NLIMITART
                               ,NRN          => NRN);
  --регистрация окончания действия
  PKG_ENV.EPILOGUE(NCOMPANY  => NCOMPANY
                  ,NVERSION  => null
                  ,NCATALOG  => NCRN
                  ,SUNIT     => 'PrjArtclsPlanReps'
                  ,SACTION   => 'UDO_P_PRJSTG_ARTCL_PLAN_INS'
                  ,STABLE    => 'UDO_T_PRJSTG_ARTCL_PLAN'
                  ,NDOCUMENT => NRN);
end UDO_P_PRJSTG_ARTCL_PLAN_INS;
/*
  create or replace public synonym UDO_P_PRJSTG_ARTCL_PLAN_INS for UDO_P_PRJSTG_ARTCL_PLAN_INS;
  grant execute on UDO_P_PRJSTG_ARTCL_PLAN_INS to public;
  */
/

