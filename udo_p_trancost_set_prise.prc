create or replace procedure udo_p_trancost_set_prise(nrn in number) is
  ttrans    transinvcust%rowtype;
  nsum_     pkg_std.tsumm;
  nsum_with pkg_std.tsumm;

  nserv_sum_with pkg_std.tsumm;
  nsum_nds       pkg_std.tsumm;
  nfpplan        pkg_std.tref;

  nnumber pkg_std.tnumber;

  smsg       varchar2(2000);
  nident_msg number(17);

begin
p_exception(0, 'Процедура отключена. Используйте процедуру "Исправить" на спецификации' ); 
  /*  Процедура переноса цены изделия из графика отпуска договора */
  /*  Столярский Е.З. 04/12/2023 */
  /*  Городецкий 29-10-2025  Добавил пересчет Журналов отгрузки и складских операций */

  

  begin
    select tr.*
      into ttrans
      from transinvcust tr
          ,doctypes     dt
     where tr.rn = nrn
       and dt.rn = tr.doctype
       and dt.doccode <> 'ОтпМатНаСт';
  exception
    when no_data_found then
    
      return; /* Такие не пересчитываем */
  
  end;

 
                           
 /* 2 Пересчитаем цену спецификации */                          

  for sp in (select ts.rn
                   ,ts.quant as nts_quant
                   ,ts.nommodif
                   ,(select ex.fcacoperplans from udo_t_transinvcustspecs_ex ex where ex.prn = ts.rn) as nfcacoperplans
               from transinvcustspecs ts
              where ts.prn = ttrans.rn
             -- and ts.price = 0
             )
  loop
  
    for fp in (select fpp.price
                     ,fpp.quant
                     ,fpp.summ
                     ,fpp.summwithnds
                     ,fpp.rn
                 from fcacoperplans fpp
                where fpp.prn = ttrans.faceacc
                  and (trunc(fpp.end_date, 'YYYY') = trunc(ttrans.docdate, 'YYYY') and fpp.nommodif = sp.nommodif and
                      sp.nfcacoperplans is null or fpp.rn = sp.nfcacoperplans and sp.nfcacoperplans is not null))
    loop
      nfpplan   := fp.rn;
      nsum_     := round(fp.summ / fp.quant * sp.nts_quant, 2);
      nsum_with := round(fp.summwithnds / fp.quant * sp.nts_quant, 2);
    
      update transinvcustspecs tt
         set tt.price       = fp.price
            ,tt.summ        = nsum_
            ,tt.summwithnds = nsum_with
            ,tt.summ_nds    = nsum_with - nsum_
       where tt.rn = sp.rn;
    
      /* Пересчитаем сумму журнала отгрузок */
      for st in (select dl.out_document
                   from doclinks dl
                  where dl.in_document = sp.rn
                    and dl.out_unitcode = 'StoreOpersJournal'
                    and dl.in_unitcode = 'GoodsTransInvoicesToConsumersSpecs')
      loop
        update storeoperjourn t
           set t.regprice     = fp.price
              ,t.regsumm      = nsum_with
              ,t.price        = fp.price
              ,t.summtax      = nsum_with
              ,t.summ         = nsum_
              ,t.summ_nds     = nsum_with - nsum_
              ,t.summtax_base = nsum_with
              ,t.summ_base    = nsum_
              ,t.summtax_acc  = nsum_with
              ,t.summ_acc     = nsum_
         where t.rn = st.out_document;
      
      end loop;
    
    end loop;
    
    
    
    
    
    nsum_with := 0;
    /* Пересчитаем сумму исполнения графика */
    select sum(ssp.summwithnds)
      into nsum_with
      from transinvcustspecs          ssp
          ,udo_t_transinvcustspecs_ex ex
     where ssp.rn = ex.prn
       and ex.fcacoperplans = nfpplan;
  
    nsum_with := nvl(nsum_with, 0);
    if nsum_with > 0
    then
      update fcacoperplans fpp
         set fpp.fact_sum = nsum_with
            ,fpp.plan_sum = nsum_with
       where fpp.rn = nfpplan;
    end if;
  end loop;

  nsum_     := 0;
  nsum_with := 0;
  nsum_nds  := 0;
  /* Пересчитаем сумму графика */
  select sum(ts.summ)
        ,sum(ts.summwithnds)
        ,sum(ts.summ_nds)
    into nsum_
        ,nsum_with
        ,nsum_nds
    from transinvcustspecs ts
   where ts.prn = ttrans.rn;

  update transinvcust th
     set th.summ        = nsum_
        ,th.summwithnds = nsum_with
   where th.rn = ttrans.rn;

  /* Пересчитаем сумму журнала отгрузок */

  for nk in (select t.summ
                   ,t.summwithnds
                   ,t.serv_summ
                   ,t.serv_summ_nds
                   ,dl.out_document
               from transinvcust t
               join doclinks dl
                 on dl.in_document = t.rn
                and dl.out_unitcode = 'LiabilitiesNotes'
                and dl.in_unitcode = 'GoodsTransInvoicesToConsumers'
              where t.rn = ttrans.rn)
  loop
    update liabilitynotes l
       set l.load_sum_notax = nk.summ
          ,l.load_sum       = nk.summwithnds
          ,l.base_sum_notax = nk.summ
          ,l.base_sum       = nk.summwithnds
          ,l.load_sum_acc   = nk.summwithnds
    -- ,l.serv_sum_notax = nk.serv_summ - nk.serv_summ_nds
    -- ,l.serv_sum       = nk.serv_summ
    --- ,l.serv_base_sum  = nk.summ
    -- ,l.serv_sum_acc   = nk.summ
     where l.rn = nk.out_document;
  
  end loop;

  nsum_with := 0;
  /* Пересчитаем сумму ЛС по товарам */
  select sum(tr.summwithnds)
  
    into nsum_with
    from transinvcust tr
   where tr.faceacc = ttrans.faceacc
     and tr.status = 1
     and tr.servact_sign = 0;

  nserv_sum_with := 0;
  /* Пересчитаем сумму ЛС по услугам */
  select sum(tr.summwithnds)
    into nserv_sum_with
    from transinvcust tr
   where tr.faceacc = ttrans.faceacc
     and tr.status = 1
     and tr.servact_sign = 1;

  nserv_sum_with := nvl(nserv_sum_with, 0);

  update faceacc fc
     set fc.fact_serv   = nserv_sum_with
        ,fc.plan_serv   = nserv_sum_with
        ,fc.fact_ship   = nsum_with
        ,fc.plan_ship   = nsum_with
        ,fc.plan_sum    = fc.begin_sum + fc.plan_income - nsum_with - nserv_sum_with + fc.plan_payed - fc.plan_posted
        ,fc.current_sum = fc.begin_sum + fc.fact_income - nsum_with - nserv_sum_with + fc.fact_payed - fc.fact_posted
   where fc.rn = ttrans.faceacc;

  usr_pkg_faceacc.faceacc_check_over_ship(nflagsmart => 0, nrn => ttrans.faceacc, ddate => ttrans.docdate, ndiff => nnumber);

end udo_p_trancost_set_prise;
/
