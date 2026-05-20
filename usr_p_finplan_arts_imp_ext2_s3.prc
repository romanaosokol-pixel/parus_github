create or replace procedure usr_p_finplan_arts_imp_ext2_s3(nbr_rn      in number
                                                          ,out_err_txt out varchar2) is

  ncompany     number(17) := 90521;
  nrn          number(17);
  v_faceacc_rn faceacc.rn%type;
  v_fcrn       faceacc.crn%type; --- Каталог лицевого счета
  v_njur_pers  jurpersons.rn%type := 92147; /*Модуль*/

begin

  for cur in (select t.finplan_rn
                    ,t.parent_art_code
                    ,replace(t.art_code, '_', '.') art_numb
                    ,t.art_name
                    ,t.art_note
                    ,t.type_production
                    ,t.division_using
                    ,t.purpose_product                    
                    ,t.quant
                    ,t.oei
                    ,t.dept_code
                    ,t.art_nn
                    ,t.mes_01
                    ,t.mes_02
                    ,t.mes_03
                    ,t.mes_04
                    ,t.mes_05
                    ,t.mes_06
                    ,t.mes_07
                    ,t.mes_08
                    ,t.mes_09
                    ,t.mes_10
                    ,t.mes_11
                    ,t.mes_12
                   ,T.analog
                from usr_t_finplan_arts_imp_ext2 t
              where t.sauthid = utilizer
              )
  loop
  
    /* Если строки бюджета нет, то заведем ее*/
  
    begin
    
      select brs.rn
        into nrn
        from udo_t_finplan_arts brs
       where brs.prn = nbr_rn
         and brs.art_numb = cur.art_numb;
    
    exception
      when no_data_found then
        /* Проверим наличие лицевого счета с номером = Номер cur.art_numb  */
      
        begin
          select f.rn
            into v_faceacc_rn
            from faceacc f
           where f.numb = cur.art_numb
             and f.company = ncompany;
        exception
          when no_data_found then
          
            /* Проверим, что каталог лицевых счетов, с наименованием, равным наименованию Кода отдела есть, если нет, то заведем его*/
          
            usr_p_faceacc_crn_create(ncompany => ncompany, cat_name => cur.dept_code, cat_parent_name => 'ШПЗ', nrn => v_fcrn);
          
            p_faceacc_base_insert(ncompany         => ncompany
                                 ,ncrn             => v_fcrn
                                 ,njur_pers        => v_njur_pers
                                 ,nprn             => null
                                 ,nagent           => null
                                 ,nfinerule        => null
                                 ,snumber          => cur.art_numb
                                 ,nacc_kind        => 0 /*Потребление/Закупка*/
                                 ,nacc_class       => 3 /* Внутренний */
                                 ,noper_flag       => 0 /**/
                                 ,nsign_contract   => 0
                                 ,nsign_stage      => 0
                                 ,norder_sign      => 0
                                 ,nvalid_doctype   => null
                                 ,svalid_docnumb   => null
                                 ,dvalid_docdate   => null
                                 ,dplan_open_date  => trunc(sysdate)
                                 ,dfact_open_date  => trunc(sysdate)
                                 ,dplan_close_date => null
                                 ,dfact_close_date => null
                                 ,nexecutive       => null
                                 ,ncurrency        => 91318 /* Рубль */
                                 ,ncredit_sum      => 0
                                 ,nbegin_sum       => 0
                                 ,ncurrent_sum     => 0
                                 ,nplan_sum        => 0
                                 ,nfcacgr          => null
                                 ,nagnacc          => null
                                 ,nagnfi           => null
                                 ,nagnfo           => null
                                 ,nagn_trans       => null
                                 ,nsubdiv          => null /* Подумать, а не задавать ли подразделение */
                                 ,ntarif           => null
                                 ,ndiscount        => 0
                                 ,npay_type        => null
                                 ,nship_type       => null
                                 ,nprice_type      => 1
                                 ,dprice_date      => null
                                 ,nsigntax         => 1
                                 ,nsame_nomn       => 0
                                 ,ndoc_serv        => 0
                                 ,nplan_serv       => 0
                                 ,nfact_serv       => 0
                                 ,ndoc_ship        => 0
                                 ,nplan_ship       => 0
                                 ,nfact_ship       => 0
                                 ,ndoc_income      => 0
                                 ,nplan_income     => 0
                                 ,nfact_income     => 0
                                 ,nfact_deficit    => 0
                                 ,ndoc_posted      => 0
                                 ,nplan_posted     => 0
                                 ,nfact_posted     => 0
                                 ,ndoc_payed       => 0
                                 ,nplan_payed      => 0
                                 ,nfact_payed      => 0
                                 ,nfinaccnt        => null
                                 ,nrespmanager     => null
                                 ,nieelement       => null
                                 ,nfinsource       => null
                                 ,npaytool         => null
                                 ,npayprior        => null
                                 ,npayrule         => null
                                 ,ncheck_bal_sign  => 1
                                 ,nspec_mark       => null
                                 ,nbudgexpend_sp   => null
                                 ,nserv_sum        => 0
                                 ,nserv_percent    => 0
                                 ,nfinplanrest     => 0
                                 ,snote            => null
                                 ,nexpstruct       => null
                                 ,nincomeclass     => null
                                 ,neconclass       => null
                                 ,ndicbunts        => null
                                 ,naccfndsrc       => null
                                 ,ngovcntrid       => null
                                 ,naddr_agent      => null
                                 , -- Адресат платежа
                                  naddr_agnacc     => null
                                 , -- Реквизиты адресата платежа
                                  nrn              => v_faceacc_rn);
        end;
      
        /* Завели строку бюджета */
        usr_p_alloc_arts_insert(nprn             => nbr_rn                 
                               ,ncompany         => ncompany
                               ,nfinrn           => cur.finplan_rn
                               ,sfinplan_arts    => cur.parent_art_code
                               ,art_numb         => cur.art_nn
                               ,sname            => cur.art_name
                               ,snote            => cur.art_note
                               ,sfaceacc_cost    => cur.art_numb
                               ,stype_production => cur.type_production
                               ,sdivision_using  => cur.division_using
                               ,spurpose_product => cur.purpose_product
                               ,nquant           => cur.quant
                               ,soei_code        => cur.oei
                               ,sACCEPT_PERIOD => null
                               ,sRequest => null                               
                               ,sanalog => cur.analog
                               ,nrn              => nrn);
      
        /*Расставили суммы по месяцам */
      
        if cur.mes_01 != 0
        then
          update usr_t_alloc_arts_v vt
             set vt.val = cur.mes_01
           where vt.prn = nrn
             and vt.numb = 1;
        end if;
      
        if cur.mes_02 != 0
        then
          update usr_t_alloc_arts_v vt
             set vt.val = cur.mes_02
           where vt.prn = nrn
             and vt.numb = 2;
        end if;
      
        if cur.mes_03 != 0
        then
          update usr_t_alloc_arts_v vt
             set vt.val = cur.mes_03
           where vt.prn = nrn
             and vt.numb = 3;
        end if;
      
        if cur.mes_04 != 0
        then
          update usr_t_alloc_arts_v vt
             set vt.val = cur.mes_01
           where vt.prn = nrn
             and vt.numb = 4;
        end if;
      
        if cur.mes_05 != 0
        then
          update usr_t_alloc_arts_v vt
             set vt.val = cur.mes_01
           where vt.prn = nrn
             and vt.numb = 5;
        end if;
      
        if cur.mes_06 != 0
        then
          update usr_t_alloc_arts_v vt
             set vt.val = cur.mes_01
           where vt.prn = nrn
             and vt.numb = 6;
        end if;
      
        if cur.mes_07 != 0
        then
          update usr_t_alloc_arts_v vt
             set vt.val = cur.mes_01
           where vt.prn = nrn
             and vt.numb = 7;
        end if;
      
        if cur.mes_08 != 0
        then
          update usr_t_alloc_arts_v vt
             set vt.val = cur.mes_01
           where vt.prn = nrn
             and vt.numb = 8;
        end if;
      
        if cur.mes_09 != 0
        then
          update usr_t_alloc_arts_v vt
             set vt.val = cur.mes_01
           where vt.prn = nrn
             and vt.numb = 9;
        end if;
      
        if cur.mes_10 != 0
        then
          update usr_t_alloc_arts_v vt
             set vt.val = cur.mes_01
           where vt.prn = nrn
             and vt.numb = 10;
        end if;
      
        if cur.mes_11 != 0
        then
          update usr_t_alloc_arts_v vt
             set vt.val = cur.mes_01
           where vt.prn = nrn
             and vt.numb = 11;
        end if;
      
        if cur.mes_12 != 0
        then
          update usr_t_alloc_arts_v vt
             set vt.val = cur.mes_01
           where vt.prn = nrn
             and vt.numb = 12;
        end if;
      
    end;
  end loop;

end;
/
