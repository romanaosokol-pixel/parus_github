create or replace procedure usr_p_fcplans_update_s_ini(nrn in number,
NSUMM out number,
NPERSENT out number,
DDATEFR  out date,
DDATETO out date) is

begin

select nvl(fp.percent
          ,100)
      ,fp.begin_date
      ,fp.end_date
      ,FP.PAY_SUM
  into npersent
      ,ddatefr
      ,ddateto
      ,NSUMM
  from fcacpayplans fp
 where fp.rn = nrn;

end;
/
