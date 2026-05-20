create or replace procedure usr_p_clnpspfm_agnlist_job
(
  pin_com   in companies.rn%type
 ,pin_agent in agnlist.agnabbr%type
) is

  ---Создание исполнения должности по контрагенту (запись сотрудника создается при необходимости)
  v_cprn    clnpersons.rn%type;
  v_cp_pref clnpersons.tab_pref%type := 'Т';
  v_cp_numb clnpersons.tab_numb%type;
  v_pm_pref clnpspfm.pref%type := 'И';
  v_pm_numb clnpspfm.numb%type;
  v_pfmnrn  clnpspfm.rn%type;

begin
  for cur in (select cp.rn            cprn
                    ,pm.rn            pmrn
                    ,ag.rn            agrn
                    ,ag.emp
                    ,ag.agnfamilyname fm --- Фамилия физического лица
                from agnlist ag
                join compverlist v
                  on ag.version = v.version
                 and v.company = 90521
                 and v.unitcode = 'AGNLIST'
                left join clnpersons cp
                  on cp.pers_agent = ag.rn
                left join clnpspfm pm
                  on pm.persrn = cp.rn
               where ag.agnabbr = pin_agent)
  
  loop
  
    if cur.cprn is null then
      --- Создаем сотрудника
    
      p_clnpersons_getnextnumb(ncompany => pin_com
                              ,sowner   => 'МОДУЛЬ'
                              ,spref    => v_cp_pref
                              ,snumb    => v_cp_numb);
    
      p_clnpersons_base_insert(ncompany          => pin_com
                              ,ncrn              => 90675
                              , -- rN каталога сотрудники
                               npers_agent       => cur.agrn
                              ,nowner_agent      => 92146
                              , --- Модуль
                               stab_pref         => v_cp_pref
                              ,stab_numb         => v_cp_numb
                              ,sgni              => null
                              ,nexternal_sign    => 0 -- не внешний совместитель
                              ,ncontract_sign    => 0 -- не работа по договору
                              ,spers_note        => 'Добавлено ' || to_char(sysdate, 'DD.MM.YYYY')
                              ,ntrn_agent        => null
                              ,ntrn_agent_acc    => null
                              ,nfss_agent        => null
                              ,nfss_agent_acc    => null
                              ,nprpaycat         => null
                              ,djobbegin_date    => trunc(sysdate, 'YY')
                              , --- Первое число текущего года
                               dlast_jobbeg_date => null
                              ,ddismiss_date     => null
                              ,ndismiss_motiv    => null
                              ,nrn               => v_cprn);
    
    else
    
      v_cprn := cur.cprn;
    
    end if;
  
    if cur.pmrn is null then
      p_clnpspfm_getnextnumb(ncompany => pin_com, spref => v_pm_pref, snumb => v_pm_numb);
    
      p_clnpspfm_base_insert(ncompany        => pin_com
                            ,ncrn            => 90577
                            ,spref           => v_pm_pref
                            ,snumb           => v_pm_numb
                            ,nclnpspfmtypes  => 13459732
                            ,npersrn         => v_cprn
                            ,npostrn         => null
                            ,ndeptrn         => null
                            ,ntyppostrn      => null
                            ,ntypdeptrn      => null
                            ,npsdeprn        => null
                            ,scommand_numb   => null
                            ,dcommand_date   => null
                            ,dbegeng         => to_date('01-01-2025', 'DD.MM.YYYY')
                            ,dendeng         => null
                            ,nofficercls     => null
                            ,snote           => 'Добавлено ' || to_char(sysdate, 'DD.MM.YYYY')
                            ,ncommand_typ    => null
                            ,ncommand_who    => null
                            ,sout_ord_numb   => null
                            ,dout_ord_date   => null
                            ,nout_ord_typ    => null
                            ,nout_ord_who    => null
                            ,nprlbrlowart    => null
                            ,nprpstnom       => null
                            ,noldpsdep       => null
                            ,nschedule       => null
                            ,nrateacc        => 1
                            ,nleave_len      => 0
                            ,nleave_len_add  => 0
                            ,ncomb_percent   => 0
                            ,scur_problem    => null
                            ,dcontest_date   => null
                            ,scontest_res    => null
                            ,nagncontracts   => null
                            ,naddcontracts   => null
                            ,nneedsumbincinf => 0
                            ,nclnpsdepun     => null
                            ,nrn             => v_pfmnrn
                            ,nskipcheck      => 1);
    
    else
      if cur.fm is null then
        -- НЕ задана фамилия физического лица, поэтому и не находят
      --- Разложим наименованеи физ. лица по полям фамилия, имя, отчество
        for fiz in (select
                     substr(a.agnname, 1, instr(a.agnname, ' ') - 1) as fm
                    ,substr(a.agnname
                           ,instr(a.agnname, ' ') + 1
                           ,instr(a.agnname, ' ', 1, 2) - instr(a.agnname, ' ') - 1) as im
                    ,substr(a.agnname, instr(a.agnname, ' ', -1, 1) + 1) as ot
                      from agnlist a
                     where a.rn = cur.agrn)        
        loop
          update agnlist a
             set a.agnfamilyname = fiz.fm
                ,a.agnfirstname  = fiz.im
                ,a.agnlastname   = fiz.ot
           where a.rn = cur.agrn;
        
        end loop;
      
      else
      
        p_exception(0
                   ,'Для контрагента %s уже существует исполнение должности. Если вы его не видите, обратитесь в тех. поддержку.'
                   ,pin_agent);
      
      end if;
    
    end if;
  
  end loop;

end;
/
