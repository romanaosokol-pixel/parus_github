create or replace procedure UDO_P_SYSP0007_STAGE_ACC_MAKE
/*
  Проверка/добавление л/с этапа внешнего заказчика при добавлении/исправлении проекта/этапа
  */
(
  PNRN     in PKG_STD.TREF -- рег. номер этапа/проекта (в зависимости от PSUNIT)
 ,PSACTION in varchar2 -- код действия
 ,PSUNIT   in varchar2 -- код раздела

) is
  NACCFROMSTAGE  PKG_STD.TREF; -- счёт из этапа
  DPLANBEGIN     date; -- плановая дата начала этапа
  SACC       FACEACC.NUMB%type; -- сформированный по правилам л/с
  NACC           PKG_STD.TREF; -- рег. номер нового л/с
  NACC_CUST      PKG_STD.TREF; -- рег. номер нового л/с
  NCRN           PKG_STD.TREF; -- каталог нового л/с
  NCOMPANY       PKG_STD.TREF; -- организация
  SCOMPANY_AGENT AGNLIST.AGNABBR%type; -- наименование организации
  SAGENT         AGNLIST.AGNABBR%type; -- заказчик проекта
  SSUBDIV        INS_DEPARTMENT.CODE%type; -- подразделение-ответственный проекта (мнемокод)
  NSUBDIV        INS_DEPARTMENT.RN%type; -- подразделение-ответственный проекта (рег. номер)
  SPRJTYPE       PRJTYPE.CODE%type; -- тип проекта
  SFACEAGENT     AGNLIST.AGNABBR%type; -- контрагент ЛС
  SFACESUBDIV    INS_DEPARTMENT.CODE%type; -- подразделение ЛС
  NACC_KIND      FACEACC.ACC_KIND%type; -- вид ЛС
  NACC_CLASS     FACEACC.ACC_CLASS%type; -- тип ЛС
  SPREFSYMB      varchar2(1) := GET_OPTIONS_STR('PrefSymb'); -- разделитель номера заказа и этапа
  SCUR           CURNAMES.INTCODE%type; --код валюты проекта - для указания в ЛС
  NCURFACEACC    FACEACC.RN%type; --рег. номер текущего ЛС этапа
  SAUTOSIGN      varchar2(80) := 'Создан автоматически для этапа '; --признак автоматического создания ЛС (для отражения в примечании)
  SEXTSIGN       DOCS_PROPS_VALS.STR_VALUE%type; -- признак внешнего проекта
  SEXTSIGN_TRUE  varchar2(2) := 'ДА'; -- значение признака внешнего проекта для внешнего проекта
  NTMP           number(17); --буферная переменная
  nRES           number(17);
  sGOVCNTRID     varchar(100);
  sAGNIDNUMB     varchar(20);
  nAGNNUMB       number;
  NFACEACCCUST   number;
  NCOMPANY_AGENT number;
  DPLANEND       date;
  sJURS          JURPERSONS.CODE%type;
begin
--P_exception(0,'!!!'||PSUNIT||' - '||PSACTION);  

  -- если вызов из этапов проекта
  if (PSUNIT = 'ProjectsStages')
  then
    -- считаем д/с и "соберём" новый л/с, выясним валюту проекта
    begin
      select P.COMPANY
            ,trim(P.CODE) || /*SPREFSYMB*/ '\'|| trim(S.NUMB)
           -- ,AG.AGNIDNUMB
            ,S.FACEACC
          --  ,S.FACEACCCUST
            ,C.INTCODE
            ,S.FACEACC
            ,AG.AGNABBR 
            ,D.CODE
            ,D.RN
            ,PT.CODE
            ,S.BEGPLAN
            ,S.ENDPLAN
            ,gi.code
            ,p.EXT_CUST
            ,j.code
        into NCOMPANY
            ,SACC
          --  ,sAGNIDNUMB
            ,NACCFROMSTAGE
         --   ,NFACEACCCUST
            ,SCUR
            ,NCURFACEACC
            ,SAGENT
            ,SSUBDIV
            ,NSUBDIV
            ,SPRJTYPE
            ,DPLANBEGIN
            ,DPLANEND
            ,sGOVCNTRID
            ,nAGNNUMB
            ,sJURS
        from PROJECT        P
            ,PROJECTSTAGE   S
            ,CURNAMES       C
            ,AGNLIST        AG
            ,PRJTYPE        PT
            ,INS_DEPARTMENT D
            ,GOVCNTRID gi
            ,JURPERSONS     J
       where S.RN = PNRN
         and P.RN = S.PRN
         and gi.rn(+)=p.govcntrid
         and C.RN = P.CURNAMES
         and P.EXT_CUST = AG.RN(+)
         and P.PRJTYPE = PT.RN
         and S.SUBDIV_RESP = D.RN(+)
         and P.JUR_PERS = J.RN;
    exception
      when NO_DATA_FOUND then
         PKG_MSG.RECORD_NOT_FOUND(0
                                ,PNRN);
      when others then
        P_EXCEPTION(0
                   ,'Ошибка получения параметров этапа: ' || ERROR_TEXT);
    end;


    -- определим контрагента организации
    GET_COMPANY_AGENT(NFLAG_SMART => 0
                     ,NCOMPANY    => NCOMPANY
                     ,SAGENT      => SCOMPANY_AGENT);

    GET_COMPANY_AGENT_RN(NFLAG_SMART => 0
                        ,NCOMPANY    => NCOMPANY
                        ,NAGENT      => NCOMPANY_AGENT);
    -- проверим, что внешний заказчик проекта указан, и указан корректно
   /* if (SAGENT is null)
    then
      P_EXCEPTION(0
                 ,'Для проекта не задан контрагент заказчик!');
    end if;*/

    SFACEAGENT  := SCOMPANY_AGENT;
    SFACESUBDIV := SSUBDIV;
    NACC_KIND   := 0; -- вид - потребление/закупка
    NACC_CLASS  := 3; -- тип - внутренний




  /*  end if;*/
    --если это добавление и ЛС не указан вручную
    if ((PSACTION = 'PROJECTSTAGE_INSERT' or PSACTION = 'PROJECTSTAGE_UPDATE') and ((NCURFACEACC is null )))
    then
      -- проверим наличие "нового"
      FIND_FACEACC_NUMB(NFLAG_SMART  => 1
                       ,NFLAG_OPTION => 0
                       ,NCOMPANY     => NCOMPANY
                       ,SNUMB        => SACC
                       ,NRN          => NACC);
       -- P_EXCEPTION(0,'Ошибка ' || NCOMPANY||'  --  '||NACC||'  '||SACC);

      -- если не нашлось л/с - добавим
      if (NACC is null)
      then
        -- определим каталог
        NCRN := UDO_F_SYSP0014_CRN_BY_PRJTYPE(NCOMPANY => NCOMPANY
                                             ,SUNIT    => 'FaceAccounts'
                                             ,STYPE    => SPRJTYPE);


        -- проверим указанность плановой даты открытия
        if (DPLANBEGIN is null)
        then
          P_EXCEPTION(0
                     ,'Не указана плановая дата начала этапа!');
        end if;

        -- добавим л/с
       -- if USER = 'PARUS' then p_exception(0,'Тест SACC='||SACC); end if;
       -- формируем  Л/С
        P_FACEACC_INSERT(NCOMPANY         => NCOMPANY
                        ,NCRN             => NCRN
                        ,sJUR_PERS        => sJURS
                        ,NPRN             => null
                        ,SAGENT           => SCOMPANY_AGENT
                        ,SFINERULE        => null
                        ,SNUMBER          => SACC
                        ,NACC_KIND        => NACC_KIND
                        ,NACC_CLASS       => NACC_CLASS
                        ,NORDER_SIGN      => 0
                        ,SVALID_DOCTYPE   => null
                        ,SVALID_DOCNUMB   => null
                        ,DVALID_DOCDATE   => null
                        ,DPLAN_OPEN_DATE  => DPLANBEGIN
                        ,DFACT_OPEN_DATE  => DPLANBEGIN
                        ,DPLAN_CLOSE_DATE => DPLANEND
                        ,DFACT_CLOSE_DATE => null
                        ,SEXECUTIVE       => null
                        ,SCURRENCY        => SCUR
                        ,NCREDIT_SUM      => 0
                        ,NBEGIN_SUM       => 0
                        ,SFCACGR          => null
                        ,SAGNACC          => null
                        ,SAGNFI           => null
                        ,SAGNFO           => null
                        ,SAGN_TRANS       => null
                        ,SSUBDIV          => SFACESUBDIV
                        ,STARIF           => null
                        ,NDISCOUNT        => 0
                        ,SPAY_TYPE        => null
                        ,SSHIP_TYPE       => null
                        ,NPRICE_TYPE      => 0
                        ,DPRICE_DATE      => null
                        ,NSIGNTAX         => 0     -- 0 - цена не включает налоги
                        ,NSAME_NOMN       => 0
                        ,SFINACCNT        => null
                        ,SRESPMANAGER     => null
                        ,SIEELEMENT       => null
                        ,SFINSOURCE       => null
                        ,SPAYTOOL         => null
                        ,SPAYPRIOR        => null
                        ,SPAYRULE         => null
                        ,NCHECK_BAL_SIGN  => 1
                        ,SSPEC_MARK       => null
                        ,NSERV_PERCENT    => null
                        ,SNOTE            => SAUTOSIGN || SACC
                        ,sGOVCNTRID       => sGOVCNTRID
                        ,sADDR_AGENT      => null      --обновление 28/09/18
                        ,sADDR_AGNACC     => null      --обновление 28/09/18
                        ,NDUP_RN          => null
                        ,NRN              => NACC);

        P_FACEACC_OPEN(NCOMPANY   => NCOMPANY
                      ,SNUMBER    => SACC
                      ,DOPEN_DATE => DPLANBEGIN);
      
      else
        -- если ЛС нашелся, убедимся, что он не занят другими этапами
        declare
          NCNT number;
        begin
          select count(*)
            into NCNT
            from PROJECTSTAGE PS
           where PS.COMPANY = NCOMPANY
             and PS.FACEACC = NACC;
          if (NCNT > 0)
          then
            P_EXCEPTION(0
                       ,'Лицевой счет ШПЗ"' || SACC ||
                        '" уже занят другим этапом заказа!');
          end if;
        end;
      end if;

            -- теперь сверим ,правильный ли был введён л/с
      if (NACCFROMSTAGE is null)
      -- если л/с не было - вставим
      then

          update PROJECTSTAGE S
             set S.FACEACC = NACC
           where S.RN = PNRN;

      elsif NACCFROMSTAGE != NACC
      -- если был введён неверный л/с
      then
        P_EXCEPTION(0
                   ,'Некорректно выбран лицевой счет!  ');
      else
        -- если был выбран верный л/с - ничего
        null;
      end if;

    else
      --если ЛС указан вручную, то проверим, что он не указан больше нигде

        begin
          select count(PS.RN)
            into NTMP
            from PROJECTSTAGE PS
           where PS.FACEACC = NCURFACEACC
             and PS.RN <> PNRN;
        exception
          when others then
            P_EXCEPTION(0
                       ,'Не удалось проверить корректность указания ЛС!');
        end;
        if (NTMP > 0)
        then
          P_EXCEPTION(0
                     ,'Указанный лицевой счет уже занят другим этапом заказа!');
        end if;
    end if;

  
    --если это исправление и в этапе есть ЛС
    if (PSACTION = 'PROJECTSTAGE_UPDATE')
    then

      begin
        if (NCURFACEACC is not null ) then
        --убедимся что это автоматический ЛС
            select T.RN
              into NCURFACEACC
              from FACEACC T
             where T.RN = NCURFACEACC
               and T.NOTE like SAUTOSIGN || '%';
        end if;

        --если да, то поменяем его параметры согласно этапу

     if NCURFACEACC is not null
        then
           for cc in (
                 select pr.endplan ,
                        fc.plan_close_date,
                        fc.numb,
                        fc.rn,
                        fc.plan_open_date,
                        pr.begplan
                   from projectstage pr
                       ,faceacc      fc
                  where fc.rn = pr.faceacc
                    and (   pr.endplan <> fc.plan_close_date
                         or fc.plan_close_date is null
                         or fc.plan_open_date <> pr.begplan )
                    and  pr.begplan is not null
                    and  pr.endplan is not null
                    and fc.rn = NCURFACEACC
              ) loop
                update faceacc f
                    set f.plan_close_date = cc.endplan,
                        f.plan_open_date  = cc.begplan
                  where f.rn = cc.rn;
              end loop;


      /*   Begin
            For r in (Select t.* ,
                             f.numb
                        from docs_props_vals t,
                             faceacc         f
                       where t.source      = f.rn
                         and f.numb        != t.str_value
                         and f.rn          = NCURFACEACC
                         )
            loop
              PKG_DOCS_PROPS_VALS.MODIFY( nPROPERTY         => r.DOCS_PROP_RN,          -- регистрационный номер записи свойства
                                          sUNITCODE         => r.UNITCODE,        -- код раздела документа
                                          nDOCUMENT         => r.UNIT_RN,          -- регистрационный номер записи документа
                                          sSTR_VALUE        => r.numb,        -- строковое значение свойства
                                          nNUM_VALUE        => null,          -- числовое значение свойства
                                          dDATE_VALUE       => null,            -- датское значение свойства
                                          nRN               => nRES          -- регистрационный номер записи значения свойства
                                        );

            end loop;
          end;
*/

      end if;
      exception
        when NO_DATA_FOUND then
          null;
      end;
    end if;
    --если это удаление и ЛС задан
    if ((PSACTION = 'PROJECTSTAGE_DELETE') and (NCURFACEACC is not null))
    then
      --убедимся что это автоматический ЛС
      begin
        select T.RN
          into NCURFACEACC
          from FACEACC T
         where T.RN = NCURFACEACC
           and T.NOTE like SAUTOSIGN || '%';
        --если этап закрыт, откроем, всё равно удалять
        for C in (select RN
                    from PROJECTSTAGE
                   where RN = PNRN
                     and STATE in (2
                                  ,3))
        loop
          update PROJECTSTAGE PS
             set PS.STATE = 1
           where PS.RN = C.RN;
        end loop;
        --если да, то скажем что он не задан
        update PROJECTSTAGE PS
           set PS.FACEACC = null
         where PS.RN = PNRN;
        update PROJECTSTAGEHS PSH
           set PSH.FACEACC = null
         where PSH.PRN = PNRN
           and PSH.FACEACC = NCURFACEACC;
        --удалим его
        P_FACEACC_DELETE(NRN      => NCURFACEACC
                        ,NCOMPANY => NCOMPANY);
      exception
        when NO_DATA_FOUND then
          null;
      end;
    end if;




  end if;
  -- если вызов из проектов
  if (PSUNIT = 'Projects')
  then
    -- если изменился проект
    if (PSACTION = 'PROJECT_UPDATE')
    then
      -- идем по всем этапам данного проекта с заполненным ЛС, сформированным автоматически
      for C in (select F.RN
                      ,F.NUMB
                      ,F.AGENT       FACC_AGENT
                      ,F.SUBDIV      FACC_SUBDIV
                      ,F.ACC_CLASS   FACC_CLASS
                      ,F.ACC_KIND    ACC_KIND
                      ,trim(P.CODE)  PROJECT
                      ,trim(PS.NUMB) STAGE
                      ,P.EXT_CUST    PRJ_CUST
                      ,Ps.SUBDIV_RESP PRJ_SUBDIV
                     /* ,UDO_F_GET_DOC_PROP_VAL(PT.RN
                                             ,'ВнешнийПроект') EXTSIGN*/
                      ,PT.CODE       PRJTCODE
                      ,p.govcntrid
                      ,ps.rn         PROJECTSTAGE_rn
                  from PROJECT      P
                      ,PROJECTSTAGE PS
                      ,FACEACC      F
                      ,PRJTYPE      PT
                 where P.RN = PNRN
                   and PS.PRN = P.RN
                   and PS.FACEACC = F.RN
                   and P.PRJTYPE = PT.RN
                   and F.NOTE like SAUTOSIGN || '%')
      loop

        -- проверим, что не поменялось ответственное подразделение проекта (важно только для внутренних заказов, для внешних - подразделение в ЛС не указываем)
          if (C.FACC_SUBDIV <> C.PRJ_SUBDIV)
          then
            null;
          --  P_exception(0,'!!! '||C.FACC_SUBDIV||' - '||C.PRJ_SUBDIV||' - '|| C.STAGE);
         /*   P_EXCEPTION(0
                       ,'У проекта уже есть этапы с лицевыми счетами, сформированными автоматически - изменение ответственного подразделения невозможно!');*/
          end if;
      /*  end if;*/

        -- соберем новый номер ЛС
        SACC := C.PROJECT || SPREFSYMB || C.STAGE;
        -- если номер ЛС этапа не соответствует новому коду проекта - переименуем
        if (SACC <> C.NUMB )
        then
   --       P_exception(0,'!!! '||SACC||' - '||C.NUMB||' - '|| C.STAGE);
         Begin
              update faceacc fc
              set fc.numb = SACC
              where fc.rn = C.RN;

              For r in (Select t.* ,
                               f.numb
                          from docs_props_vals t,
                               faceacc         f
                         where t.source      = f.rn
                         --  and t.str_value   = f.numb  -- меняем все свойства по данному ЛС
                           and f.rn          = C.RN
                           )
              loop
                PKG_DOCS_PROPS_VALS.MODIFY( nPROPERTY         => r.DOCS_PROP_RN,          -- регистрационный номер записи свойства
                                            sUNITCODE         => r.UNITCODE,        -- код раздела документа
                                            nDOCUMENT         => r.UNIT_RN,          -- регистрационный номер записи документа
                                            sSTR_VALUE        => SACC, --r.numb,        -- строковое значение свойства
                                            nNUM_VALUE        => null,          -- числовое значение свойства
                                            dDATE_VALUE       => null,            -- датское значение свойства
                                            nRN               => nRES          -- регистрационный номер записи значения свойства
                                          );

              end loop;
            end;
        end if;

       

      end loop;
    end if;
  end if;

end;
/*
  create or replace public synonym UDO_P_SYSP0007_STAGE_ACC_MAKE for UDO_P_SYSP0007_STAGE_ACC_MAKE;
  grant execute on UDO_P_SYSP0007_STAGE_ACC_MAKE to public;
  */
/

