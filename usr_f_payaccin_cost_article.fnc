create or replace function usr_f_payaccin_cost_article(nfaceacc number) return fcarticle.code%type is
  v_res fcarticle.code%type;
begin
  /* Ёлемент затрат вход€щего счета */
  begin
    select ee.code
      into v_res
      from faceacc f
      join fpdartcl sz
        on sz.rn = f.ieelement
      join fcarticle ee
        on ee.rn = sz.cost_article
     where f.rn = nfaceacc;
  exception
    when no_data_found then
      return null;
  end;
  return v_res;
end;
/
