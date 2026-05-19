create or replace function USR_F_RESJOURNAL_DEPORD_RN(nrn in number) return number is

/*Городецкий RN Заказа подразделений по которому создана строка журнала резервирования */

nres DEPARTMENTORD.rn%type;

begin

select max(zps.prn)
  into nres
  from resjournal rj
  join udo_depords_prf dp
    on dp.rsrv = rj.rn
  join departmentords zps
    on zps.rn = dp.dordsp
 where rj.rn = nrn;
return nres;
end;
/
