create or replace procedure UDO_P_PRJSTAGE_DEL_HIERARCHY
(
NRN in number -- RN  этапа проекта
) as

begin
  
 EXECUTE IMMEDIATE 'ALTER TRIGGER T_PROJECTSTAGE_BUPDATE DISABLE';

  
  update PROJECTSTAGE pp
   set pp.hrn = null,
       pp.hier_level = 1
  where pp.rn = NRN;     

  EXECUTE IMMEDIATE 'ALTER TRIGGER T_PROJECTSTAGE_BUPDATE ENABLE';

end UDO_P_PRJSTAGE_DEL_HIERARCHY;

/*
grant execute on UDO_P_PRJSTAGE_DEL_HIERARCHY to public;  
*/
/

