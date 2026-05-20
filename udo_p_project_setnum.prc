create or replace procedure UDO_P_PROJECT_SETNUM
(
  nCOMPANY  in number,
  sPRJTYPE  in varchar,
  dBEGPLAN  in date,
  sCODE     out varchar
)
as
  sPRJ_type varchar(5);
  sPRJ_year varchar(5);
  sPRJ_max  varchar(20);
  sPRJBUF_max  varchar(20);
  nPRJ_max  number;
begin
   sPRJ_type := GET_OPTIONS_STR('Projects_Type', nCOMPANY);
   sPRJ_year := to_char(sysdate, 'YY');

   if sPRJTYPE is not null then sPRJ_type := sPRJTYPE; end if;
   if dBEGPLAN is not null then sPRJ_year := to_char(dBEGPLAN, 'YY'); end if;


   sCODE := sPRJ_type||'.'||sPRJ_year||'.';
   begin
    select max(substr(pr.code,7,3))
    into sPRJ_max
    from PROJECT pr
    where pr.code like sCODE||'%';
   exception when NO_DATA_FOUND then
     sPRJ_max := '000';
   end;
   
    if sPRJ_max is null then sPRJ_max := '000'; end if;
    /* генерация номера заголовка ордера */
    nPRJ_max := to_number(sPRJ_max) +1;
    sCODE := sCODE ||trim(to_char(nPRJ_max,'009'));

end UDO_P_PROJECT_SETNUM;
/

