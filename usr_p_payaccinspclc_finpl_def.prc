create or replace procedure usr_p_payaccinspclc_finpl_def

(nrn             in payaccin.rn%type
, --:= 261475094;
 ncompany        in companies.rn%type
, ---:= 90521;
 speriod         in out enperiod.code%type
,sbudj_code      out udo_t_finplan.fp_code%type
,finplan_rn      out udo_t_finplan.rn%type
,sdepord         in out ins_department.code%type
,sbudj_art_nmb   out fpdartcl.code%type
,finplan_arts_rn out udo_t_finplan_arts.rn%type
,payin_FACEACC     out Payaccin.Faceacc%type) is

  v_sz       fpdartcl.code%type;
  v_reg_year varchar2(4) := usr_pkg_docs_props_vals.get_val_str(ndoc_prop => 7457584, sunitcode => 'PaymentAccountsIn', ndocument => nrn);
  v_reg_date date;

begin
  --- Находим состав затрат из лицевого счета входящего счета
  v_sz := udo_f_payaccin_faceacc_article(nrn);

  case /* Если в свойстве задан год, то  период определяется значением своства*/
    when v_reg_year is null then
      v_reg_date := null;
    else
      v_reg_date := to_date('01-01-' || v_reg_year, 'DD.MM.YYYY');
  end case;

  /* Находим период если нужно */
  if speriod is null
  
  then
  
    begin
      select per.code, P.Faceacc
        into speriod, payin_FACEACC
        from payaccin p
        join enperiod per
          on coalesce(v_reg_date, p.reg_date, P.DOC_DATE) between per.startdate and per.enddate
       where p.rn = nrn
         and per.pertype = 3
         and per.enddate - per.startdate > 360
         and per.code != 'Произвольный период'
         and rownum = 1;
    
    exception
      when no_data_found then
        speriod := null;
        return; /* Нет периода, то дальше искать нет смысла */
    end;
  
  end if;
  /* Найдем бюджет, если статья в этом периоде только в одном бюджете */

  begin
    select t.fp_code
          ,t.rn
          ,dep.code
          ,ts.art_numb
          ,ts.rn
      into sbudj_code
          ,finplan_rn
          ,sdepord
          ,sbudj_art_nmb
          ,finplan_arts_rn
      from udo_t_finplan t
      join enperiod per
        on per.rn = t.fp_period
      join doctypes dt
        on dt.rn = t.fp_type
      join dicsmrks gb
        on gb.rn = t.groupbudg
      join ins_department dep
        on dep.rn = t.depord
      join udo_t_finplan_arts ts
        on ts.prn = t.rn
      join fpdartcl sz
        on sz.rn = ts.fpdartcl
      join ins_department dep
        on dep.rn = t.depord
     where per.code = speriod
       and t.company = ncompany
       and dt.doccode = 'БДДСП_подр'
       and gb.smark_mnemo = 'ПЛАН'
          ---and (sdepord is null or dep.code = sdepord)
       and sz.code = v_sz
       and sz.version = 91451;
  exception
    when no_data_found then
      sbudj_code := null;
      finplan_rn := null;
      sdepord    := null;
    when too_many_rows then
      /* Подумать, что делать, у разных бюджетов возможна одна статья. Как выбор, задавать Отдел в пармаметре */
      sbudj_code := null;
      finplan_rn := null;
      sdepord    := null;
    
  end;
  ---if user = 'GOR' then P_exception(0, sdepord ); end if;

end;
/
