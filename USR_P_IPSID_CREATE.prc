create or replace procedure USR_P_IPSID_CREATE(ips_id in varchar2, Q_ISH in varchar2, IPS_NAME in varchar2) is
begin

if REGEXP_LIKE (ips_id,'^[[:digit:]]+$') then   

begin
  insert into USR_TAB_TMP_IPSID
  (IPS_ID, SAUTHID, Q_ISH, IPS_NAME)
  values
  (ips_id, user, Q_ISH, IPS_NAME);
  exception when others then p_exception(0, ips_id);
end;  
  
end if;  
end;
/
