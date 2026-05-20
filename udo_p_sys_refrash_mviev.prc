create or replace procedure UDO_P_SYS_REFRASH_MVIEV
as
begin
    dbms_mview.refresh('UDO_M_INFIN_TRANSINVCUST');
    dbms_mview.refresh('UDO_M_INFIN_TRANSINVCUSTSPEC ');
    dbms_mview.refresh('UDO_M_INFIN_GOVCNTRID');
    dbms_mview.refresh('UDO_M_INFIN_AGNLIST');
    dbms_mview.refresh('UDO_M_INFIN_PAYACC');
    dbms_mview.refresh('UDO_M_INFIN_DOGNUM');
    dbms_mview.refresh('UDO_M_INFIN_DOGNUM1022');

end UDO_P_SYS_REFRASH_MVIEV;
/

