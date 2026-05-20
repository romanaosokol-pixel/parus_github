create or replace procedure usr_p_faceacc_alloc_arts_ini(ncompany     in number
                                                        ,speriod_code out varchar2) is

begin

  usr_p_enperiod_code_get(ncompany => ncompany, sper_year => extract(year from sysdate), sper_code => speriod_code);

end;
/
