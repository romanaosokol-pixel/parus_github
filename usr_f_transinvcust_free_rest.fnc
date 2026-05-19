create or replace function usr_f_transinvcust_free_rest(nrn number) return number is

  v_res goodssupplyhist.min_restplan%type;

begin
  begin
  
    select least(gyh.min_restplan, gyh.min_restfact)
      into v_res
      from transinvcustspecs ts
      left join goodsparties gp
        on gp.rn = ts.goodsparty
      join transinvcust t
        on t.rn = ts.prn
      left join rlarticles izd
        on izd.rn = ts.article
      left join articlessupply izp
        on izp.article = izd.rn
      left join goodssupply gy
        on gy.prn = gp.rn
       and gy.store = t.store
      left join goodssupply gyi
        on gyi.rn = izp.prn
      join goodssupplyhist gyh
        on gyh.prn = nvl(gy.rn, gyi.rn)
      join nommodif nm
        on nm.rn = ts.nommodif
     where ts.rn = nrn
       and gyh.date_from = (select max(h.date_from) from goodssupplyhist h where h.prn = nvl(gy.rn, gyi.rn));
  
  exception
    when no_data_found then
      v_res := 0;
  end;
  return v_res;
end;
/
